//+------------------------------------------------------------------+
//|                                                SplitContainer.mqh |
//+------------------------------------------------------------------+
#ifndef __SPLITCONTAINER_MQH__
#define __SPLITCONTAINER_MQH__
#include "..\Element.mqh"
#include "Pointer.mqh"
#include "SeparateLine.mqh"
//+------------------------------------------------------------------+
class CSplitContainer : public CElement
  {
   private:
      int               m_split_x;
      CPointer          m_x_resize;
      CElement         *m_panel1;
      CElement         *m_panel2;
      CSeparateLine     m_separator;
      void              InitializeProperties(const int x_gap, const int y_gap);
      bool              CreateCanvas(void);
      void              CheckXResizePointer(const int x, const int y);
      void              UpdateXSize(const int x);
      void              RepositionPanels(void);
   public:
                        CSplitContainer(void);
                       ~CSplitContainer(void);
      bool              CreateSplitContainer(const int x_gap, const int y_gap);
      void              SetPanel1(CElement &obj) { m_panel1 = ::GetPointer(obj); CElement::AddToArray(obj); RepositionPanels(); }
      void              SetPanel2(CElement &obj) { m_panel2 = ::GetPointer(obj); CElement::AddToArray(obj); RepositionPanels(); }
      void              SplitX(const int x)        { m_split_x = x; RepositionPanels(); }
      int               SplitX(void)          const { return (m_split_x); }
      void              SeparatorColors(const color dark, const color light) { m_separator.DarkColor(dark); m_separator.LightColor(light); }
      virtual void      Draw(void);
      virtual void      OnEvent(const int id, const long &lparam, const double &dparam, const string &sparam);
      virtual void      ChangeWidthByRightWindowSide(void);
      virtual void      ChangeHeightByBottomWindowSide(void);
  };
#ifndef CSPLITCONTAINER_MQH_IMPLEMENTATION
#define CSPLITCONTAINER_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
CSplitContainer::CSplitContainer(void) : m_split_x(150),
                                          m_panel1(NULL), m_panel2(NULL)
  {
   CElementBase::ClassName(CLASS_NAME);
  }
CSplitContainer::~CSplitContainer(void) {}
//+------------------------------------------------------------------+
bool CSplitContainer::CreateSplitContainer(const int x_gap, const int y_gap)
  {
   if(!CElement::CheckMainPointer())
      return (false);
   InitializeProperties(x_gap, y_gap);
   if(!CreateCanvas())
      return (false);
   // --- Separator is its OWN object (CSeparateLine), not a line drawn onto this
   // container's shared background canvas — avoids Z-order/repaint conflicts
   // with whatever sits near the split boundary (e.g. a child's scrollbar).
   m_separator.MainPointer(::GetPointer(this));
   m_separator.TypeSepLine(V_SEP_LINE);
   if(!m_separator.CreateSeparateLine(m_split_x, 0, 4, m_y_size))
      return (false);
   CElement::AddToArray(m_separator);
   // --- m_separator is never registered via CWndContainer::AddToElementsArray
   // --- (only added to this container's own internal m_elements[] above), so
   // --- the framework's top-level CWndEvents::Update() draw cascade never
   // --- reaches it. Without this explicit call, CSeparateLine::Draw() (which
   // --- paints the dark/light two-tone line) never runs, so its bitmap stays
   // --- blank forever even though its on-chart position is correct.
   m_separator.Update(true);
   // --- Resize pointer (con trỏ kéo, giống CTreeView::m_x_resize)
    m_x_resize.Type(MP_X_RESIZE);
    m_x_resize.MainPointer(::GetPointer(this));    
    if(!m_x_resize.CreatePointer(m_chart_id, m_subwin))
       return (false);  
    //New add for Mouse Pointer
      m_x_resize.State(false);   // --- ADDED: force state false so the first State(true) on actual click/hover triggers Draw()+Update()
   return (true);
  }
//+------------------------------------------------------------------+
void CSplitContainer::InitializeProperties(const int x_gap, const int y_gap)
  {
   m_x = CElement::CalculateX(x_gap);
   m_y = CElement::CalculateY(y_gap);
   m_x_size = (m_x_size < 1 || m_auto_xresize_mode)
               ? m_main.X2() - CElementBase::X() - m_auto_xresize_right_offset
               : m_x_size;
   m_y_size = (m_y_size < 1 || m_auto_yresize_mode)
               ? m_main.Y2() - CElementBase::Y() - m_auto_yresize_bottom_offset
               : m_y_size;
   m_back_color = (m_back_color != clrNONE) ? m_back_color : clrWhite;
   CElementBase::XGap(x_gap);
   CElementBase::YGap(y_gap);
  }
//+------------------------------------------------------------------+
bool CSplitContainer::CreateCanvas(void)
  {
   string name = CElementBase::ElementName("splitcontainer");
   if(!CElement::CreateCanvas(name, m_x, m_y, m_x_size, m_y_size))
      return (false);
   return (true);
  }
//+------------------------------------------------------------------+
void CSplitContainer::Draw(void)
  {
   CElement::DrawBackground();
  }
//+------------------------------------------------------------------+
// | Đặt lại vị trí/độ rộng cho 2 panel con + đường chia theo m_split_x hiện tại |
//+------------------------------------------------------------------+
void CSplitContainer::RepositionPanels(void)
  {
   //Debug
    //Print("My Debug CSplitContainer::RepositionPanels BEFORE separator.Moving obj=", m_separator.CanvasPointer().ChartObjectName());
   // --- Reposition the separator object itself
   m_separator.XGap(m_split_x);
   m_separator.CanvasPointer().XGap(m_split_x);
   m_separator.Moving();
   // --- CanvasPointer().Update(true) only re-uploads whatever is ALREADY in the
   // --- bitmap - it never calls Draw(). Use the element-level Update(true) so the
   // --- two-tone line actually gets (re)painted, not just repositioned.
   m_separator.Update(true);
   ::ObjectSetInteger(m_chart_id, m_separator.CanvasPointer().ChartObjectName(), OBJPROP_BACK, false);
   if(m_panel1 != NULL)
     {
      m_panel1.XGap(0);
      m_panel1.CanvasPointer().XGap(0);
      m_panel1.XSize(m_split_x);
      // --- XSize() above only updates the logical field - it never touches the
      // --- canvas bitmap (confirmed in ElementBase.mqh). Without an explicit
      // --- Resize() here, panel1's bitmap stays at its original creation-time
      // --- size and visually covers/hides the separator.
      m_panel1.CanvasPointer().XSize(m_split_x);
      m_panel1.CanvasPointer().Resize(m_split_x, m_panel1.CanvasPointer().YSize());
      //Debug
        //  Print("My Debug CSplitContainer::RepositionPanels BEFORE panel1.Moving obj=", m_panel1.CanvasPointer().ChartObjectName());
      m_panel1.Moving();
      m_panel1.Draw();
      m_panel1.CanvasPointer().Update(true);
     }
   if(m_panel2 != NULL)
     {
      m_panel2.XGap(m_split_x + 4);
      m_panel2.CanvasPointer().XGap(m_split_x + 4);
      //Debug
       //Print("My Debug CSplitContainer::RepositionPanels BEFORE panel2.Moving obj=", m_panel2.CanvasPointer().ChartObjectName());
      m_panel2.Moving();
      m_panel2.ChangeWidthByRightWindowSide();
     }
    ::ChartRedraw(m_chart_id);
    //Debug native check - xác nhận object THẬT trên chart có đổi X hay không
    //  Print("My Debug CSplitContainer::RepositionPanels NATIVE-CHECK m_split_x=", m_split_x,
    //        " IsVisible=", m_separator.IsVisible(),
    //        " canvas.X()=", m_separator.CanvasPointer().X(),
    //        " OBJPROP_XDISTANCE=", ::ObjectGetInteger(m_chart_id, m_separator.CanvasPointer().ChartObjectName(), OBJPROP_XDISTANCE));
  }
//+------------------------------------------------------------------+
// | Kéo-dịch: theo đúng pattern CheckXResizePointer của CTreeView     |
//+------------------------------------------------------------------+
void CSplitContainer::OnEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id == CHARTEVENT_MOUSE_MOVE)
     {
      int x = m_mouse.RelativeX(m_canvas);
      int y = m_mouse.RelativeY(m_canvas);      
      CheckXResizePointer(x, y);
      if(!m_x_resize.State())
         return;
      m_x_resize.UpdateX(m_mouse.X());
      if(y > 0 && y < m_y_size)
         m_x_resize.UpdateY(m_mouse.Y());
      UpdateXSize(x);
      m_x_resize.Reset();
     }
  }
//+------------------------------------------------------------------+
void CSplitContainer::CheckXResizePointer(const int x, const int y)
  {
   if(!m_x_resize.State() && y > 0 && y < m_y_size && x > m_split_x - 2 && x < m_split_x + 6)
     {
      m_x_resize.Moving(m_mouse.X(), m_mouse.Y());
      m_x_resize.Reset();
      if(m_mouse.IsLeftBtn())
        {
         m_x_resize.State(true);
         m_x_resize.Update(true);
        }
     }
   else
     {
      if(!m_mouse.IsLeftBtn())
        {
         if(!m_x_resize.IsVisible())
            return;
         if(m_x_resize.State())
           {
            m_x_resize.State(false);
            ::ChartRedraw(m_chart_id);
           }
         m_x_resize.Hide();
        }
     }
  }
//+------------------------------------------------------------------+
void CSplitContainer::UpdateXSize(const int x)
  {
   m_split_x = x - 2;
   RepositionPanels();
   CElement::Update(true);
  }
void CSplitContainer::ChangeWidthByRightWindowSide(void)
  {
   if(m_anchor_right_window_side)
      return;
   int x_size = m_main.X2() - m_canvas.X() - m_auto_xresize_right_offset;
   if(x_size == m_x_size)
      return;
   CElementBase::XSize(x_size);
   m_canvas.XSize(x_size);
   m_canvas.Resize(x_size, m_y_size);
   RepositionPanels();
   Draw();
   Moving();
  }
void CSplitContainer::ChangeHeightByBottomWindowSide(void)
  {
   if(m_anchor_bottom_window_side)
      return;
   int y_size = m_main.Y2() - m_canvas.Y() - m_auto_yresize_bottom_offset;
   if(y_size == m_y_size)
      return;
   CElementBase::YSize(y_size);
   m_canvas.YSize(y_size);
   m_canvas.Resize(m_x_size, y_size);
   // --- Let the separator resize its own canvas height too
   m_separator.CanvasPointer().YSize(y_size);
   m_separator.CanvasPointer().Resize(m_separator.CanvasPointer().XSize(), y_size);
   m_separator.Draw();
   m_separator.CanvasPointer().Update(true);
   RepositionPanels();
   Draw();
   Moving();
  }

#endif // CSPLITCONTAINER_MQH_IMPLEMENTATION
#endif // __SPLITCONTAINER_MQH__
