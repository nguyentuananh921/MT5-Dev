//+------------------------------------------------------------------+
//|                                                      Label.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//| First See in: Simple controls                                    |
//|                           https://www.mql5.com/en/articles/18221 |
//|        class CLabel : public CCanvasBase                         |
//| Update in: Containers                                            |
//|                           https://www.mql5.com/en/articles/18658 |
//|                          class CLabel : public CElementBase      |
//| Current                   https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| Text Label Class |
//+------------------------------------------------------------------+
#ifndef __LABEL_MQH__
#define __LABEL_MQH__
//+------------------------------------------------------------------+
//| Included Standard Libraries                                      |
//+------------------------------------------------------------------+
//#include <Arrays\List.mqh>
//+------------------------------------------------------------------+
//| Included Custome Libraries                                       |
//+------------------------------------------------------------------+
#include "ElementBase.mqh"   
  class CLabel : public CElementBase
   {
      protected:
         ushort            m_text[];                                 // Text
         ushort            m_text_prev[];                            // Past text
         int               m_text_x;                                 // X coordinate of the text (offset relative to the left edge of the object)
         int               m_text_y;                                 // Y coordinate of the text (offset relative to the top border of the object)

      // --- (1) Sets, (2) returns past text
         void              SetTextPrev(const string text)            { ::StringToShortArray(text,this.m_text_prev);  }
         string            TextPrev(void)                      const { return ::ShortArrayToString(this.m_text_prev);}
            
      // --- Erases text
         void              ClearText(void);

      public:
      // --- (1) Sets, (2) returns text
         void              SetText(const string text)                { ::StringToShortArray(text,this.m_text);       }
         string            Text(void)                          const { return ::ShortArrayToString(this.m_text);     }
         
      // --- Returns the (1) X, (2) Y coordinate of the text
         int               TextX(void)                         const { return this.m_text_x;                         }
         int               TextY(void)                         const { return this.m_text_y;                         }

      // --- Sets the (1) X, (2) Y coordinate of the text
         void              SetTextShiftH(const int x)                { this.ClearText(); this.m_text_x=x;            }
         void              SetTextShiftV(const int y)                { this.ClearText(); this.m_text_y=y;            }
         
      // --- Outputs text
         virtual void      DrawText(const int dx, const int dy, const string text, const bool chart_redraw);
         
      // ---Draws the appearance
         virtual void      Draw(const bool chart_redraw);

      // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
         virtual int       Compare(const CObject *node,const int mode=0) const;
         virtual bool      Save(const int file_handle);
         virtual bool      Load(const int file_handle);
         virtual int       Type(void)                          const { return(ELEMENT_TYPE_LABEL);                   }

      // --- Initialize (1) class object, (2) default object colors
         void              Init(const string text);
         virtual void      InitColors(void){}
         
      // --- Constructors/destructor
                           CLabel(void);
                           CLabel(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h);
                           ~CLabel(void) {}
   };
 #ifndef CLABEL_IMPLEMENTATION
 #define CLABEL_IMPLEMENTATION
   //+------------------------------------------------------------------+
   // | CLabel::Default constructor. Builds a label in the main window |
   // | current chart in coordinates 0,0 with default sizes |
   //+------------------------------------------------------------------+
   CLabel::CLabel(void) : CElementBase("Label","Label",::ChartID(),0,0,0,DEF_LABEL_W,DEF_LABEL_H), m_text_x(0), m_text_y(0)
    {
     // ---Initialization
      this.Init("Label");
    }
   //+-------------------------------------------------------------------+
   // | CLabel::The constructor is parametric. Builds a label in the specified window|
   // | of the specified graphic with the specified text, coordinates and dimensions |
   //+-------------------------------------------------------------------+
   CLabel::CLabel(const string object_name,const string text,const long chart_id,const int wnd,const int x,const int y,const int w,const int h) :
      CElementBase(object_name,text,chart_id,wnd,x,y,w,h), m_text_x(0), m_text_y(0)
    {
      // ---Initialization
      this.Init(text);
    }
   //+------------------------------------------------------------------+
   // | CLabel::Initialization |
   //+------------------------------------------------------------------+
   void CLabel::Init(const string text)
    {
     // --- Set the current and previous text
      this.SetText(text);
      this.SetTextPrev("");
     // --- Background is transparent, foreground is not
      this.SetAlphaBG(255);  //| Modify m_alpha_bg(0) to m_alpha_bg(255) to meet MT5 5716 version |
      this.SetAlphaFG(255);
    }
   //+------------------------------------------------------------------+
   // | CLabel::Comparing two objects |
   //+------------------------------------------------------------------+
   int CLabel::Compare(const CObject *node,const int mode=0) const
    {
      if(node==NULL)
         return -1;
      const CLabel *obj=node;
      switch(mode)
      {
         case ELEMENT_SORT_BY_NAME     :  return(this.Name()         >obj.Name()          ? 1 : this.Name()          <obj.Name()          ? -1 : 0);
         case ELEMENT_SORT_BY_TEXT     :  return(this.Text()         >obj.Text()          ? 1 : this.Text()          <obj.Text()          ? -1 : 0);
         case ELEMENT_SORT_BY_X        :  return(this.X()            >obj.X()             ? 1 : this.X()             <obj.X()             ? -1 : 0);
         case ELEMENT_SORT_BY_Y        :  return(this.Y()            >obj.Y()             ? 1 : this.Y()             <obj.Y()             ? -1 : 0);
         case ELEMENT_SORT_BY_WIDTH    :  return(this.Width()        >obj.Width()         ? 1 : this.Width()         <obj.Width()         ? -1 : 0);
         case ELEMENT_SORT_BY_HEIGHT   :  return(this.Height()       >obj.Height()        ? 1 : this.Height()        <obj.Height()        ? -1 : 0);
         case ELEMENT_SORT_BY_COLOR_BG :  return(this.BackColor()    >obj.BackColor()     ? 1 : this.BackColor()     <obj.BackColor()     ? -1 : 0);
         case ELEMENT_SORT_BY_COLOR_FG :  return(this.ForeColor()    >obj.ForeColor()     ? 1 : this.ForeColor()     <obj.ForeColor()     ? -1 : 0);
         case ELEMENT_SORT_BY_ALPHA_BG :  return(this.AlphaBG()      >obj.AlphaBG()       ? 1 : this.AlphaBG()       <obj.AlphaBG()       ? -1 : 0);
         case ELEMENT_SORT_BY_ALPHA_FG :  return(this.AlphaFG()      >obj.AlphaFG()       ? 1 : this.AlphaFG()       <obj.AlphaFG()       ? -1 : 0);
         case ELEMENT_SORT_BY_STATE    :  return(this.State()        >obj.State()         ? 1 : this.State()         <obj.State()         ? -1 : 0);
         case ELEMENT_SORT_BY_ZORDER   :  return(this.ObjectZOrder() >obj.ObjectZOrder()  ? 1 : this.ObjectZOrder()  <obj.ObjectZOrder()  ? -1 : 0);
         default                       :  return(this.ID()           >obj.ID()            ? 1 : this.ID()            <obj.ID()            ? -1 : 0);
      }
    }
   //+------------------------------------------------------------------+
   // | CLabel::Erases text |
   //+------------------------------------------------------------------+
   void CLabel::ClearText(void)
    {
         int w=0, h=0;
         string text=this.TextPrev();
      // --- Getting the dimensions of the previous text
         if(text!="")
            this.m_foreground.TextSize(text,w,h);
      // --- If the dimensions are obtained, draw a transparent rectangle in place of the text, erasing the text
         if(w>0 && h>0)
            this.m_foreground.FillRectangle(this.AdjX(this.m_text_x),this.AdjY(this.m_text_y),this.AdjX(this.m_text_x+w),this.AdjY(this.m_text_y+h),clrNULL);
      // --- Otherwise, we completely clear the entire foreground
         else
            this.m_foreground.Erase(clrNULL);
    }
   //+------------------------------------------------------------------+
   // | CLabel::Outputs text |
   //+------------------------------------------------------------------+
   void CLabel::DrawText(const int dx,const int dy,const string text,const bool chart_redraw)
    {
      //Print Debug
         if(text != "") 
            ::Print("Label '", this.Name(), "' is drawing text: ", text);
         else
            ::Print("Label '", this.Name(), "' is drawing EMPTY text!");
      
      // --- Clear the previous text and install a new one
         this.ClearText();
         this.SetText(text);
      // --- Output the set text
         //this.m_foreground.TextOut(this.AdjX(dx),this.AdjY(dy),this.Text(),::ColorToARGB(this.ForeColor(),this.AlphaFG()));
         this.m_foreground.TextOut(10, 2, this.Text(), ::ColorToARGB(clrRed, 255));
      // --- If the text extends beyond the right border of the object
         if(this.Width()-dx<this.m_foreground.TextWidth(text))
         {
            // --- Getting the dimensions of the text "ellipsis"
            int w=0,h=0;
            this.m_foreground.TextSize("... ",w,h);
            if(w>0 && h>0)
            {
               // --- Erase the text at the right border of the object according to the text size "ellipsis" and replace the end of the label text with an ellipsis
               this.m_foreground.FillRectangle(this.AdjX(this.Width()-w),this.AdjY(this.m_text_y),this.AdjX(this.Width()),this.AdjY(this.m_text_y+h),clrNULL);
               this.m_foreground.TextOut(this.AdjX(this.Width()-w),this.AdjY(dy),"...",::ColorToARGB(this.ForeColor(),this.AlphaFG()));
            }
         }
      // --- Update the foreground canvas and remember the new text coordinates
         this.m_foreground.Update(chart_redraw);
         this.m_text_x=dx;
         this.m_text_y=dy;
      // --- Remember the drawn text as the previous one
         this.SetTextPrev(text);
    }
   //+------------------------------------------------------------------+
   // | CLabel::Draws appearance |
   //+------------------------------------------------------------------+
   void CLabel::Draw(const bool chart_redraw)
    {
      this.DrawText(this.m_text_x,this.m_text_y,this.Text(),chart_redraw);
    }
   //+------------------------------------------------------------------+
   // | CLabel::Save to file |
   //+------------------------------------------------------------------+
   bool CLabel::Save(const int file_handle)
    {
      // --- Save the data of the parent object
         if(!CElementBase::Save(file_handle))
            return false;
      
      // --- Save the text
         if(::FileWriteArray(file_handle,this.m_text)!=sizeof(this.m_text))
            return false;
      // --- Save the previous text
         if(::FileWriteArray(file_handle,this.m_text_prev)!=sizeof(this.m_text_prev))
            return false;
      // --- Save the X coordinate of the text
         if(::FileWriteInteger(file_handle,this.m_text_x,INT_VALUE)!=INT_VALUE)
            return false;
      // --- Save the Y coordinate of the text
         if(::FileWriteInteger(file_handle,this.m_text_y,INT_VALUE)!=INT_VALUE)
            return false;
         
      // --- Everything is successful
         return true;
    }
   //+------------------------------------------------------------------+
   //| CLabel::Loading from file |
   //+------------------------------------------------------------------+
   bool CLabel::Load(const int file_handle)
    {
      // --- Loading the data of the parent object
         if(!CElementBase::Load(file_handle))
            return false;
            
      // --- Loading text
         if(::FileReadArray(file_handle,this.m_text)!=sizeof(this.m_text))
            return false;
      // --- Loading the previous text
         if(::FileReadArray(file_handle,this.m_text_prev)!=sizeof(this.m_text_prev))
            return false;
      // --- Load the X coordinate of the text
         this.m_text_x=::FileReadInteger(file_handle,INT_VALUE);
      // --- Load the Y coordinate of the text
         this.m_text_y=::FileReadInteger(file_handle,INT_VALUE);
         
      // --- Everything is successful
      return true;
    }
 #endif // CLABEL_IMPLEMENTATION
 //+------------------------------------------------------------------+
#endif // __LABEL_MQH__
