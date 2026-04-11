//+------------------------------------------------------------------+
//|                                             RowCaptionView.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//| First See in             https://www.mql5.com/en/articles/18221  |
//| Current                   https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| Class for visual representation of table row header |
//+------------------------------------------------------------------+
#ifndef __ROWCAPTIONVIEW_MQH__
#define __ROWCAPTIONVIEW_MQH__
   //+------------------------------------------------------------------+
   //| Included Standard Libraries                                      |
   //+------------------------------------------------------------------+
   #include <Arrays\List.mqh>
   //+------------------------------------------------------------------+
   //| Included Custome Libraries                                       |
   //+------------------------------------------------------------------+
   #include "CaptionView.mqh"   
 class CRowCaptionView : public CCaptionView
  {
   protected:
      
   public:
   // ---Draws the appearance
      virtual void      Draw(const bool chart_redraw);

   public:  
   // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
      virtual int       Compare(const CObject *node,const int mode=0)const { return CButton::Compare(node,mode);        }
      virtual bool      Save(const int file_handle);
      virtual bool      Load(const int file_handle);
      virtual int       Type(void)                                   const { return(ELEMENT_TYPE_TABLE_ROW_CAPTION_VIEW);}

   // --- Initializing a class object
      void              Init(const string text);
      
   // --- Returns a description of the object
      virtual string    Description(void);
      
   // --- Constructors/destructor
                        CRowCaptionView(void);
                        CRowCaptionView(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h); 
                        ~CRowCaptionView (void){}
  };
  #ifndef CROWCAPTIONVIEW_IMPLEMENTATION
  #define CROWCAPTIONVIEW_IMPLEMENTATION
   //+------------------------------------------------------------------+
   // | CRowCaptionView::Default constructor. Builds an object |
   // | in the main window of the current chart at coordinates 0,0 |
   // | with default sizes |
   //+------------------------------------------------------------------+
   CRowCaptionView::CRowCaptionView(void) : CCaptionView("RowCaption","Caption",::ChartID(),0,0,0,DEF_PANEL_W,DEF_TABLE_ROW_H)
    {
     // ---Initialization
      this.Init("Caption");
      this.SetID(0);
      this.SetIndex(-1);
      this.SetName("RowCaption");
      this.SetTextShiftH(8);
    }
   //+------------------------------------------------------------------+
   // | CRowCaptionView::Parametric constructor.                    |
   // | Plots an object in the specified window of the specified chart with |
   // | specified text, coordinates and dimensions |
   //+------------------------------------------------------------------+
   CRowCaptionView::CRowCaptionView(const string object_name, const string text, const long chart_id, const int wnd, const int x, const int y, const int w, const int h) :
      CCaptionView(object_name,text,chart_id,wnd,x,y,w,h)
   {
    // ---Initialization
      this.Init(text);
      this.SetID(0);
      this.SetIndex(-1);
      this.SetTextShiftH(8);
   }
   //+------------------------------------------------------------------+
   // | CRowCaptionView::Initializing |
   //+------------------------------------------------------------------+
   void CRowCaptionView::Init(const string text)
    {
     // --- Initializing the parent object
      CCaptionView::Init(text);
     // --- Dimensions are not changeable
      this.SetResizable(false);
      this.SetMovable(false);
    }
   //+------------------------------------------------------------------+
   // | CRowCaptionView::Draws the appearance |
   //+------------------------------------------------------------------+
   void CRowCaptionView::Draw(const bool chart_redraw)
    {
     // --- If the object is outside its container, we leave
      if(this.IsOutOfContainer())
         return;

     // --- Fill the object with the background color, draw a light vertical line on the left, and a dark one on the right
      this.Fill(this.BackColor(),false);
      this.m_background.Rectangle(this.AdjX(2),this.AdjY(0),this.AdjX(this.Width()-1),this.AdjY(this.Height()-1),::ColorToARGB(this.BorderColor(),this.AlphaBG()));
     // --- updating the background canvas
      this.m_background.Update(false);
      
     // --- Output title text
      CLabel::Draw(false);
         
     // --- If indicated, update the schedule
      if(chart_redraw)
         ::ChartRedraw(this.m_chart_id);
    }
   //+------------------------------------------------------------------+
   // | CRowCaptionView::Returns the description of the object |
   //+------------------------------------------------------------------+
   string CRowCaptionView::Description(void)
    {
      //--- 1. Get unified base info: "Row Caption View: Name (ID 123)"
      string baseDesc = CBaseObj::Description();
      
      //--- 2. Append area coordinates
      return ::StringFormat("%s, Area: [X %d, Y %d, W %d, H %d]",
                           baseDesc,
                           this.X(), this.Y(), this.Width(), this.Height());
      //-------------------
      // string nm=this.Name();
      // string name=(nm!="" ? ::StringFormat(" \"%s\"",nm) : nm);
      // return ::StringFormat("%s%s ID %d, X %d, Y %d, W %d, H %d",ElementDescription((ENUM_ELEMENT_TYPE)this.Type()),name,this.ID(),this.X(),this.Y(),this.Width(),this.Height());
    }
   //+------------------------------------------------------------------+
   // | CRowCaptionView::Save to file |
   //+------------------------------------------------------------------+
   bool CRowCaptionView::Save(const int file_handle)
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
   // | CRowCaptionView::Loading from file |
   //+------------------------------------------------------------------+
   bool CRowCaptionView::Load(const int file_handle)
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
  #endif // CROWCAPTIONVIEW_IMPLEMENTATION
#endif // __ROWCAPTIONVIEW_MQH__


