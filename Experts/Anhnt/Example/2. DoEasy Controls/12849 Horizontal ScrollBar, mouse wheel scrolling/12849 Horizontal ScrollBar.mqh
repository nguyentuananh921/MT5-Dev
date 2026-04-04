//+--------------------------------------------------------------------------+
//|                                                     TstDE132.mq5         |
//|                                     https://mql5.com/en/users/artmedia70 |
//+--------------------------------------------------------------------------+
//|                                                 DoEasy. Controls         |
//|           32. Horizontal ScrollBar, mouse wheel scrolling                |
//|                          https://www.mql5.com/en/articles/12849          |
//+--------------------------------------------------------------------------+
#include <Vendors\Anhnt\CFramework\Old\Engine.mqh>
//--- defines
    #define  FORMS_TOTAL (1)   // Number of created forms
    #define  START_X     (4)   // Initial X coordinate of the shape
    #define  START_Y     (4)   // Initial Y coordinate of the shape
    #define  KEY_LEFT    (65)  // (A) Left
    #define  KEY_RIGHT   (68)  // (D) Right
    #define  KEY_UP      (87)  // (W) Up
    #define  KEY_DOWN    (88)  // (X) Down
    #define  KEY_FILL    (83)  // (S) Filling
    #define  KEY_ORIGIN  (90)  // (Z) Default
    #define  KEY_INDEX   (81)  // (Q) By index

//--- enumerations by compilation language
#ifdef COMPILE_EN

    enum ENUM_AUTO_SIZE_MODE
    {
    AUTO_SIZE_MODE_GROW=CANV_ELEMENT_AUTO_SIZE_MODE_GROW,                               // Grow
    AUTO_SIZE_MODE_GROW_SHRINK=CANV_ELEMENT_AUTO_SIZE_MODE_GROW_SHRINK                  // Grow and Shrink
    };
    enum ENUM_BORDER_STYLE
    {
    BORDER_STYLE_NONE=FRAME_STYLE_NONE,                                                 // None
    BORDER_STYLE_SIMPLE=FRAME_STYLE_SIMPLE,                                             // Simple
    BORDER_STYLE_FLAT=FRAME_STYLE_FLAT,                                                 // Flat
    BORDER_STYLE_BEVEL=FRAME_STYLE_BEVEL,                                               // Embossed (bevel)
    BORDER_STYLE_STAMP=FRAME_STYLE_STAMP,                                               // Embossed (stamp)
    };
    enum ENUM_CHEK_STATE
    {
    CHEK_STATE_UNCHECKED=CANV_ELEMENT_CHEK_STATE_UNCHECKED,                             // Unchecked
    CHEK_STATE_CHECKED=CANV_ELEMENT_CHEK_STATE_CHECKED,                                 // Checked
    CHEK_STATE_INDETERMINATE=CANV_ELEMENT_CHEK_STATE_INDETERMINATE,                     // Indeterminate
    };
    enum ENUM_ELEMENT_ALIGNMENT
    {
    ELEMENT_ALIGNMENT_TOP=CANV_ELEMENT_ALIGNMENT_TOP,                                   // Top
    ELEMENT_ALIGNMENT_BOTTOM=CANV_ELEMENT_ALIGNMENT_BOTTOM,                             // Bottom
    ELEMENT_ALIGNMENT_LEFT=CANV_ELEMENT_ALIGNMENT_LEFT,                                 // Left
    ELEMENT_ALIGNMENT_RIGHT=CANV_ELEMENT_ALIGNMENT_RIGHT,                               // Right
    };
    enum ENUM_ELEMENT_TAB_SIZE_MODE
    {
    ELEMENT_TAB_SIZE_MODE_NORMAL=CANV_ELEMENT_TAB_SIZE_MODE_NORMAL,                     // Fit to tab title text width
    ELEMENT_TAB_SIZE_MODE_FIXED=CANV_ELEMENT_TAB_SIZE_MODE_FIXED,                       // Fixed size
    ELEMENT_TAB_SIZE_MODE_FILL=CANV_ELEMENT_TAB_SIZE_MODE_FILL,                         // Fit TabControl Size
    };
    enum ENUM_ELEMENT_PROGRESS_BAR_STYLE
    {
    ELEMENT_PROGRESS_BAR_STYLE_BLOCKS=CANV_ELEMENT_PROGRESS_BAR_STYLE_BLOCKS,           // Blocks
    ELEMENT_PROGRESS_BAR_STYLE_CONTINUOUS=CANV_ELEMENT_PROGRESS_BAR_STYLE_CONTINUOUS,   // Continuous
    ELEMENT_PROGRESS_BAR_STYLE_MARQUEE=CANV_ELEMENT_PROGRESS_BAR_STYLE_MARQUEE,         // Marquee
    };  
    #else 
    enum ENUM_AUTO_SIZE_MODE
    {
    AUTO_SIZE_MODE_GROW=CANV_ELEMENT_AUTO_SIZE_MODE_GROW,                               // Increase only
    AUTO_SIZE_MODE_GROW_SHRINK=CANV_ELEMENT_AUTO_SIZE_MODE_GROW_SHRINK                  // Increase and decrease
    };
    enum ENUM_BORDER_STYLE
    {
    BORDER_STYLE_NONE=FRAME_STYLE_NONE,                                                 // No frame
    BORDER_STYLE_SIMPLE=FRAME_STYLE_SIMPLE,                                             // Simple frame
    BORDER_STYLE_FLAT=FRAME_STYLE_FLAT,                                                 // Flat frame
    BORDER_STYLE_BEVEL=FRAME_STYLE_BEVEL,                                               // Embossed (convex)
    BORDER_STYLE_STAMP=FRAME_STYLE_STAMP,                                               // Embossed (concave)
    };
    enum ENUM_CHEK_STATE
    {
    CHEK_STATE_UNCHECKED=CANV_ELEMENT_CHEK_STATE_UNCHECKED,                             // Unchecked
    CHEK_STATE_CHECKED=CANV_ELEMENT_CHEK_STATE_CHECKED,                                 // Checked
    CHEK_STATE_INDETERMINATE=CANV_ELEMENT_CHEK_STATE_INDETERMINATE,                     // Undefined
    };
    enum ENUM_ELEMENT_ALIGNMENT
    {
    ELEMENT_ALIGNMENT_TOP=CANV_ELEMENT_ALIGNMENT_TOP,                                   // Top
    ELEMENT_ALIGNMENT_BOTTOM=CANV_ELEMENT_ALIGNMENT_BOTTOM,                             // Bottom
    ELEMENT_ALIGNMENT_LEFT=CANV_ELEMENT_ALIGNMENT_LEFT,                                 // Left
    ELEMENT_ALIGNMENT_RIGHT=CANV_ELEMENT_ALIGNMENT_RIGHT,                               // Right
    };
    enum ENUM_ELEMENT_TAB_SIZE_MODE
    {
    ELEMENT_TAB_SIZE_MODE_NORMAL=CANV_ELEMENT_TAB_SIZE_MODE_NORMAL,                     // By tab header width
    ELEMENT_TAB_SIZE_MODE_FIXED=CANV_ELEMENT_TAB_SIZE_MODE_FIXED,                       // Fixed size
    ELEMENT_TAB_SIZE_MODE_FILL=CANV_ELEMENT_TAB_SIZE_MODE_FILL,                         // By TabControl size
    };
    enum ENUM_ELEMENT_PROGRESS_BAR_STYLE
    {
    ELEMENT_PROGRESS_BAR_STYLE_BLOCKS=CANV_ELEMENT_PROGRESS_BAR_STYLE_BLOCKS,           // Segmented blocks
    ELEMENT_PROGRESS_BAR_STYLE_CONTINUOUS=CANV_ELEMENT_PROGRESS_BAR_STYLE_CONTINUOUS,   // Continuous bar
    ELEMENT_PROGRESS_BAR_STYLE_MARQUEE=CANV_ELEMENT_PROGRESS_BAR_STYLE_MARQUEE,         // Continuous scrolling
    };  
#endif 
class CCreateGUI
{
   private:
      CEngine              *m_engine;      
      color                m_array_clr[];
      bool                 m_movable;
      ENUM_INPUT_YES_NO    m_autosize;
      ENUM_AUTO_SIZE_MODE  m_autosizemode;
   //Private Method
      void                 InitColors();
      void                 SetupScrollBars(CPanel *pnl);
   public:
   // Constructor & Destructor
      CCreateGUI()      { m_engine = NULL; }
      ~CCreateGUI()     { }

}
void CCreateGUI::InitColors()
{
   ArrayResize(m_array_clr, 2);
   m_array_clr[0] = C'26,100,128';
   m_array_clr[1] = C'35,133,169';
}
void CCreateGUI::SetupScrollBars(CPanel *pnl)
{
   CScrollBarVertical *sbv = pnl.GetScrollBarVertical();
   if(sbv != NULL)
   {
      // Cấu hình thêm cho SB dọc nếu cần
   }
   
   CScrollBarHorisontal *sbh = pnl.GetScrollBarHorisontal();
   if(sbh != NULL) 
   {
      // Cấu hình thêm cho SB ngang nếu cần
   }
}



