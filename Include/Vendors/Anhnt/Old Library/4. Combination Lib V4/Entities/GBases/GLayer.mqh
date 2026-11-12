//+------------------------------------------------------------------+
//|                                                       GLayer.mqh |
//+------------------------------------------------------------------+
#ifndef __GLAYER_MQH__
#define __GLAYER_MQH__
 #include <Canvas\Canvas.mqh>
#ifndef CGLAYER_MQH_DECLARATION
#define CGLAYER_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| One transparent canvas over the whole chart: the items paint on |
 //| it instead of every item owning a canvas object. Not selectable, |
 //| it never takes a click or the chart's scrolling                  |
 //+------------------------------------------------------------------+
 class CGLayer
  {
   private:
     CCanvas           m_canvas;
     long              m_chart_id;
     string            m_name;
     bool              m_created;
   public:
     bool              Create(const long chart_id,const string name);
     bool              IsCreated(void) const { return this.m_created;    }
     long              ChartID(void)   const { return this.m_chart_id;   }
   //--- Same size as the chart: true when it changed
     bool              FitChart(void);
     void              Clear(void)           { this.m_canvas.Erase(0);   }
     void              Commit(void)          { this.m_canvas.Update(false); }
     CCanvas          *Canvas(void)          { return ::GetPointer(this.m_canvas); }
                       CGLayer(void) : m_chart_id(0),m_name(""),m_created(false) { }
                      ~CGLayer(void);
  };
#endif // CGLAYER_MQH_DECLARATION
#ifndef CGLAYER_MQH_IMPLEMENTATION
#define CGLAYER_MQH_IMPLEMENTATION
 bool CGLayer::Create(const long chart_id,const string name)
  {
   if(this.m_created)
      return true;
   int w=(int)::ChartGetInteger(chart_id,CHART_WIDTH_IN_PIXELS);
   int h=(int)::ChartGetInteger(chart_id,CHART_HEIGHT_IN_PIXELS);
   ::ObjectDelete(chart_id,name);   // left over by a program that did not exit cleanly
   if(!this.m_canvas.CreateBitmapLabel(chart_id,0,name,0,0,(w<1 ? 1 : w),(h<1 ? 1 : h),COLOR_FORMAT_ARGB_NORMALIZE))
      return false;
   ::ObjectSetInteger(chart_id,name,OBJPROP_SELECTABLE,false);
   ::ObjectSetInteger(chart_id,name,OBJPROP_SELECTED,false);
   ::ObjectSetInteger(chart_id,name,OBJPROP_HIDDEN,true);
   ::ObjectSetInteger(chart_id,name,OBJPROP_ZORDER,0);
   ::ChartSetInteger(chart_id,CHART_EVENT_MOUSE_MOVE,true);
   this.m_chart_id=chart_id;
   this.m_name=name;
   this.m_created=true;
   return true;
  }
 bool CGLayer::FitChart(void)
  {
   if(!this.m_created)
      return false;
   int w=(int)::ChartGetInteger(this.m_chart_id,CHART_WIDTH_IN_PIXELS);
   int h=(int)::ChartGetInteger(this.m_chart_id,CHART_HEIGHT_IN_PIXELS);
   if(w<1 || h<1 || (w==this.m_canvas.Width() && h==this.m_canvas.Height()))
      return false;
   this.m_canvas.Resize(w,h);
   ::ObjectSetInteger(this.m_chart_id,this.m_name,OBJPROP_XSIZE,w);
   ::ObjectSetInteger(this.m_chart_id,this.m_name,OBJPROP_YSIZE,h);
   return true;
  }
 CGLayer::~CGLayer(void)
  {
   if(this.m_created)
      this.m_canvas.Destroy();
  }
#endif // CGLAYER_MQH_IMPLEMENTATION
#endif // __GLAYER_MQH__
