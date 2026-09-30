//+------------------------------------------------------------------+
//|                                                     TreeItem.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|Library base on Link https://www.mql5.com/en/code/19703           |
//+------------------------------------------------------------------+
#property strict

#ifndef CTREEITEM_MQH
#define CTREEITEM_MQH
 #include <Canvas\Canvas.mqh>
 #include "..\GBases\GBaseObj.mqh"
 #include "..\Properties\Image.mqh"
 #include "..\..\Services\Colors.mqh"
#ifndef CTREEITEM_MQH_DECLARATION
#define CTREEITEM_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Tree node without canvas, drawn on the tree view canvas          |
//+------------------------------------------------------------------+
class CTreeItem : public CGBaseObj
 {
  private:
    CImage            m_icon;
    string            m_item_text;
    bool              m_item_state;
    bool              m_is_active;

    void              DrawIcon(CCanvas &canvas,CImage &image,const int x,const int y);
  public:
    CTreeItem        *ParentItem(void)                          { return dynamic_cast<CTreeItem *>(this.m_parent); }
    CTreeItem        *ChildItem(const int index)                { return dynamic_cast<CTreeItem *>(this.Child(index)); }
    int               NodeLevel(void);
    int               ArrowXGap(void)                           { return(5+12*this.NodeLevel()); }
    void              LabelText(const string text)              { this.m_item_text=text;   }
    string            LabelText(void)                     const { return(this.m_item_text); }
    void              IconFile(const uint resource_index);
    void              ItemState(const bool state)               { this.m_item_state=state;  }
    bool              ItemState(void)                     const { return(this.m_item_state); }
    void              IsActive(const bool state)                { this.m_is_active=state;   }
    bool              IsActive(void)                      const { return(this.m_is_active); }
    void              DrawItem(CCanvas &canvas,const int y,const int height,const color text_color);
                     CTreeItem(void);
                    ~CTreeItem(void) {}
 };
#endif // CTREEITEM_MQH_DECLARATION
#ifndef CTREEITEM_MQH_IMPLEMENTATION
#define CTREEITEM_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTreeItem::CTreeItem(void) : m_item_text(""),m_item_state(false),m_is_active(false)
 {
 }
//+------------------------------------------------------------------+
//| 0 = top level, the hidden root of the tree returns -1            |
//+------------------------------------------------------------------+
int CTreeItem::NodeLevel(void)
 {
  CGBaseObj *node=this.m_parent;
  if(node==NULL)
     return(-1);
  int level=0;
  while(node.Parent()!=NULL)
    {
     level++;
     node=node.Parent();
    }
  return(level);
 }
//+------------------------------------------------------------------+
//| INT_MAX = no icon                                                |
//+------------------------------------------------------------------+
void CTreeItem::IconFile(const uint resource_index)
 {
  this.m_icon.DeleteImageData();
  this.m_icon.ReadImageData(resource_index);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTreeItem::DrawIcon(CCanvas &canvas,CImage &image,const int x,const int y)
 {
  uint height=image.Height();
  uint width =image.Width();
  for(uint ly=0,p=0; ly<height; ly++)
    {
     for(uint lx=0; lx<width; lx++,p++)
       {
        if((image.Data(p)>>24)==0)
           continue;
        uint background=::ColorToARGB(canvas.PixelGet(x+lx,y+ly));
        canvas.PixelSet(x+lx,y+ly,::ColorToARGB(CColors::BlendColors(background,image.Data(p))));
       }
    }
 }
//+------------------------------------------------------------------+
//| Kazharski layout: arrow at 5+12*level, icon after it, then text; |
//| a leaf's icon takes the arrow slot (Kazharski TI_SIMPLE)         |
//+------------------------------------------------------------------+
void CTreeItem::DrawItem(CCanvas &canvas,const int y,const int height,const color text_color)
 {
  int arrow_x=this.ArrowXGap();
  int text_x=arrow_x+18;
  if(this.ChildrenTotal()>0)
    {
     CImage arrow;
     if(this.m_item_state)
        arrow.ReadImageData(this.m_is_active ? IMAGE_RESOURCE_BMP16_ARROWDOWN_BLUE_BMP : IMAGE_RESOURCE_BMP16_ARROWDOWN_BMP);
     else
        arrow.ReadImageData(this.m_is_active ? IMAGE_RESOURCE_BMP16_ARROWRIGHT_BLUE_BMP : IMAGE_RESOURCE_BMP16_ARROWRIGHT_BMP);
     this.DrawIcon(canvas,arrow,arrow_x,y+(height-(int)arrow.Height())/2);
     if(this.m_icon.Width()>0)
       {
        this.DrawIcon(canvas,this.m_icon,arrow_x+16,y+(height-(int)this.m_icon.Height())/2);
        text_x=arrow_x+16+(int)this.m_icon.Width()+4;
       }
    }
  else if(this.m_icon.Width()>0)
     this.DrawIcon(canvas,this.m_icon,arrow_x,y+(height-(int)this.m_icon.Height())/2);
  canvas.TextOut(text_x,y+height/2,this.m_item_text,::ColorToARGB(text_color,255),TA_LEFT|TA_VCENTER);
 }
#endif // CTREEITEM_MQH_IMPLEMENTATION
#endif // CTREEITEM_MQH
