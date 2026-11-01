//+------------------------------------------------------------------+
//|                                                   GLayerItem.mqh |
//+------------------------------------------------------------------+
#ifndef __GLAYERITEM_MQH__
#define __GLAYERITEM_MQH__
ulong g_dbg_invalidate_n = 0, g_dbg_c_children = 0, g_dbg_c_check = 0, g_dbg_c_redraw = 0, g_dbg_c_redraw_n = 0, g_dbg_p_readable = 0, g_dbg_p_connected = 0, g_dbg_p_connected_n = 0, g_dbg_c_bring_n = 0;   //Print Debug
 #include <Canvas\Canvas.mqh>
 #include "GBaseObj.mqh"
#ifndef CGLAYERITEM_MQH_DECLARATION
#define CGLAYERITEM_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| A child of CGraphElementsCollection that has no canvas of its    |
 //| own: it paints itself on the shared layer the collection owns    |
 //| (chart pixel coordinates = layer coordinates)                    |
 //+------------------------------------------------------------------+
 class CGLayerItem : public CGBaseObj
  {
   private:
     static bool       m_layer_invalid;     //CGLayerItem owns: set by Invalidate, read and cleared by CGraphElementsCollection through ConsumeInvalidated
   public:
   //--- Draw on the shared layer, nothing when not shown
     virtual void      Paint(CCanvas *canvas)                    { }
   //--- True when the chart pixel x,y is on this item
     virtual bool      HitTest(const int x,const int y)          { return false; }
   //--- The layer is cleared and painted again by the collection on its next timer event
     static void       Invalidate(void)                          { m_layer_invalid=true; g_dbg_invalidate_n++; }   //Print Debug
     static bool       ConsumeInvalidated(void);
  };
#endif // CGLAYERITEM_MQH_DECLARATION
#ifndef CGLAYERITEM_MQH_IMPLEMENTATION
#define CGLAYERITEM_MQH_IMPLEMENTATION
 bool CGLayerItem::m_layer_invalid=false;
 bool CGLayerItem::ConsumeInvalidated(void)
  {
   bool res=m_layer_invalid;
   m_layer_invalid=false;
   return res;
  }
#endif // CGLAYERITEM_MQH_IMPLEMENTATION
#endif // __GLAYERITEM_MQH__
