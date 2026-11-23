//+------------------------------------------------------------------+
//|                                                CaptionView.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//| First See in             https://www.mql5.com/en/articles/18221  |
//| Current                   https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
// | Abstract header visual class |
//+------------------------------------------------------------------+
#ifndef __CAPTIONVIEW_MQH__
#define __CAPTIONVIEW_MQH__ 
  //+------------------------------------------------------------------+
  //| Included Standard Libraries                                      |
  //+------------------------------------------------------------------+
  //#include <Arrays\List.mqh>
  //+------------------------------------------------------------------+
  //| Included Custome Libraries                                       |
  //+------------------------------------------------------------------+
  #include "Button.mqh"  
 class CCaptionView : public CButton
  {
    protected:
      CBound           *m_bound_node;                                   // Pointer to title area
      int               m_index;                                        // Index in a list of strings
      
    public:
    // --- Sets the ID
      virtual void      SetID(const int id)                                { this.m_id=id;                              }
    // --- (1) Sets, (2) returns the row index
      void              SetIndex(const int index)                          { this.m_index=index;                        }
      int               Index(void)                                  const { return this.m_index;                       }

    // --- (1) Assigns, (2) returns the title area to which the object is assigned
      void              AssignBoundNode(CBound *bound)                     { this.m_bound_node=bound;                   }
      CBound           *GetBoundNode(void)                                 { return this.m_bound_node;                  }

    // --- Draws (1) appearance, (2) sort direction arrow
      virtual void      Draw(const bool chart_redraw);

    // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
      virtual int       Compare(const CObject *node,const int mode=0)const { return CButton::Compare(node,mode);        }
      virtual bool      Save(const int file_handle);
      virtual bool      Load(const int file_handle);
      virtual int       Type(void)                                   const { return(ELEMENT_TYPE_TABLE_CAPTION_VIEW);   }

    // --- Initialize (1) class object, (2) default object colors
      void              Init(const string text);
      virtual void      InitColors(void);
      
    // --- Returns a description of the object
      virtual string    Description(void);
      
    // --- Constructors/destructor
                        CCaptionView(void);
                        CCaptionView(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h); 
                     ~CCaptionView (void){}
  };
 #ifndef CCAPTIONVIEW_IMPLEMENTATION
 #define CCAPTIONVIEW_IMPLEMENTATION
   //+------------------------------------------------------------------+
   // | CCaptionView::Default constructor. Builds an object |
   // | in the main window of the current chart at coordinates 0,0 |
   // | with default sizes |
   //+------------------------------------------------------------------+
   CCaptionView::CCaptionView(void) : CButton("Caption","Caption",::ChartID(),0,0,0,DEF_PANEL_W,DEF_TABLE_ROW_H), m_index(0)
    {
     // ---Initialization
      this.Init("Caption");
      this.SetID(0);
      this.SetIndex(-1);
      this.SetName("Caption");
    }
   //+------------------------------------------------------------------+
   // | CCaptionView::The constructor is parametric.                       |
   // | Plots an object in the specified window of the specified chart with |
   // | specified text, coordinates and dimensions |
   //+------------------------------------------------------------------+
   CCaptionView::CCaptionView(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h) :
      CButton(object_name,text,chart_id,wnd,x,y,w,h), m_index(0)
    {
     // ---Initialization
      this.Init(text);
      this.SetID(0);
      this.SetIndex(-1);
    }
   //+------------------------------------------------------------------+
   // | CCaptionView::Initializing |
   //+------------------------------------------------------------------+
   void CCaptionView::Init(const string text)
    {
     // --- Default text offsets
      this.m_text_x=4;
      this.m_text_y=2;
     // --- Set the colors of different states
      this.InitColors();
     // --- Can be resized
      this.SetResizable(false);
      this.SetMovable(false);
      this.SetImageBound(this.ObjectWidth()-14,4,8,11);
    }
   //+------------------------------------------------------------------+
   // | CCaptionView::Initialize default object colors |
   //+------------------------------------------------------------------+
   void CCaptionView::InitColors(void)
    {
     // --- Initialize the background colors for normal and activated states and make it the current background color
      this.InitBackColors(C'230,230,230',C'159,213,183',this.GetBackColorControl().NewColor(C'159,213,183',-6,-6,-6),clrSilver);
      this.InitBackColorsAct(C'230,230,230',C'159,213,183',this.GetBackColorControl().NewColor(C'159,213,183',-6,-6,-6),clrSilver);
      this.BackColorToDefault();
      
     // --- Initialize the foreground colors for normal and activated states and make it the current text color
      this.InitForeColors(clrBlack,clrBlack,clrBlack,clrSilver);
      this.InitForeColorsAct(clrBlack,clrBlack,clrBlack,clrSilver);
      this.ForeColorToDefault();
      
     // --- Initialize the border colors for the normal and activated states and make it the current border color
      this.InitBorderColors(clrLightGray,clrLightGray,clrLightGray,clrLightGray);
      this.InitBorderColorsAct(clrLightGray,clrLightGray,clrLightGray,clrLightGray);
      this.BorderColorToDefault();
      
     // --- Initialize the border color and foreground color for the locked element
      this.InitBorderColorBlocked(clrNULL);
      this.InitForeColorBlocked(clrSilver);
    }
   //+------------------------------------------------------------------+
   // | CCaptionView::Draws the appearance |
   //+------------------------------------------------------------------+
   void CCaptionView::Draw(const bool chart_redraw)
    {
     // --- If the object is outside its container, we leave
      if(this.IsOutOfContainer())
         return;

     // --- Fill the object with the background color, draw a light vertical line on the left, and a dark one on the right
      this.Fill(this.BackColor(),false);
      color clr_dark =this.BorderColor();                                                       // "Dark color"
      color clr_light=this.GetBackColorControl().NewColor(this.BorderColor(), 100, 100, 100);   // "Light color"
      this.m_background.Line(this.AdjX(0),this.AdjY(0),this.AdjX(0),this.AdjY(this.Height()-1),::ColorToARGB(clr_light,this.AlphaBG()));                          // Line on the left
      this.m_background.Line(this.AdjX(this.Width()-1),this.AdjY(0),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(clr_dark,this.AlphaBG())); // Line on the right
     // --- updating the background canvas
      this.m_background.Update(false);
      
     // --- Output title text
      CLabel::Draw(false);
         
     // --- If indicated, update the schedule
      if(chart_redraw)
         ::ChartRedraw(this.m_chart_id);
    }
   //+------------------------------------------------------------------+
   // | CCaptionView::Returns the object description |
   //+------------------------------------------------------------------+
   string CCaptionView::Description(void)
    {
      //--- 1. Get the unified base description: "Caption View: Name (ID 123)"
      //--- This replaces ElementDescription, this.Name(), and this.ID() logic
      string baseDesc = CBaseObj::Description();
      
      //--- 2. Append coordinates and dimensions
      //--- Using a clear format for X, Y, Width, and Height
      return ::StringFormat("%s, Area: [X %d, Y %d, W %d, H %d]",
                            baseDesc,
                            this.X(), this.Y(), this.Width(), this.Height());      
      // string nm=this.Name();
      // string name=(nm!="" ? ::StringFormat(" \"%s\"",nm) : nm);
      // return ::StringFormat("%s%s ID %d, X %d, Y %d, W %d, H %d",ElementDescription((ENUM_ELEMENT_TYPE)this.Type()),name,this.ID(),this.X(),this.Y(),this.Width(),this.Height());
    }
   //+------------------------------------------------------------------+
   // | CCaptionView::Save to file |
   //+------------------------------------------------------------------+
   bool CCaptionView::Save(const int file_handle)
    {
     // --- Save the data of the parent object
      if(!CButton::Save(file_handle))
         return false;

     // --- Save the header number
      if(::FileWriteInteger(file_handle,this.m_index,INT_VALUE)!=INT_VALUE)
         return false;
         
     // --- Everything is successful
      return true;
    }
   //+------------------------------------------------------------------+
   // | CCaptionView::Loading from file |
   //+------------------------------------------------------------------+
   bool CCaptionView::Load(const int file_handle)
    {
     // --- Loading the data of the parent object
      if(!CButton::Load(file_handle))
         return false;
         
     // --- Loading the header number
      this.m_index=::FileReadInteger(file_handle,INT_VALUE);
      
     // --- Everything is successful
      return true;
    }
   //+------------------------------------------------------------------+
  #endif // CCAPTIONVIEW_IMPLEMENTATION
#endif // __CAPTIONVIEW_MQH__


