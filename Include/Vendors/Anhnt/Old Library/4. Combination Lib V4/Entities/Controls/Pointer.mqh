//+------------------------------------------------------------------+
//|                                                      Pointer.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//| Introduction at https://www.mql5.com/en/articles/2763            |
//|Library base on Link https://www.mql5.com/en/code/19703           |
//+------------------------------------------------------------------+
#property strict

#ifndef CPOINTER_MQH
#define CPOINTER_MQH
 #include "..\GBases\GElement.mqh"
#ifndef CPOINTER_MQH_DECLARATION
#define CPOINTER_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Mouse cursor picture drawn at the cursor (not a child, no mouse) |
//+------------------------------------------------------------------+
class CPointer : public CGElement
 {
  private:
    uint              m_file_on;
    uint              m_file_off;
    ENUM_MOUSE_POINTER m_pointer_type;

    void              SetPointerBmp(void);
  protected:
    virtual void      InitColors(void);
  public:
    bool              CreatePointer(const long chart_id,const int subwin,const int w=16,const int h=16);
    void              FileOn(const uint file_index)                { m_file_on=file_index;  }
    void              FileOff(const uint file_index)               { m_file_off=file_index; }
    ENUM_MOUSE_POINTER PointerType(void)                    const { return(m_pointer_type);       }
    void              Type(ENUM_MOUSE_POINTER type)                { m_pointer_type=type;          }
    void              XGap(const int x_gap)                        { m_x_gap=x_gap;        }
    void              YGap(const int y_gap)                        { m_y_gap=y_gap;        }
    void              Moving(const int mouse_x,const int mouse_y)  { this.Move(mouse_x-this.m_x_gap,mouse_y-this.m_y_gap); }
                     CPointer(void);
                    ~CPointer(void) {}
 };
#endif // CPOINTER_MQH_DECLARATION
#ifndef CPOINTER_MQH_IMPLEMENTATION
#define CPOINTER_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CPointer::CPointer(void) : m_file_on(0),
                           m_file_off(0),
                           m_pointer_type(MP_X_RESIZE)
 {
 }
//+------------------------------------------------------------------+
//| Transparent background, only the picture is drawn                |
//+------------------------------------------------------------------+
void CPointer::InitColors(void)
 {
  this.m_color_background.InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
  this.m_color_foreground.InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
  this.m_color_border.InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
  this.m_color_background_act.InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
  this.m_color_foreground_act.InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
  this.m_color_border_act.InitColors(clrNONE,clrNONE,clrNONE,clrNONE);
 }
//+------------------------------------------------------------------+
//| Creates the pointer hidden; x/y gap = hotspot inside the picture |
//+------------------------------------------------------------------+
bool CPointer::CreatePointer(const long chart_id,const int subwin,const int w=16,const int h=16)
 {
  this.SetPointerBmp();
  int x_gap=this.m_x_gap;
  int y_gap=this.m_y_gap;
  if(!this.Create(chart_id,subwin,"pointer_"+(string)this.ObjectID(),0,0,w,h))
     return(false);
  this.m_x_gap=x_gap;
  this.m_y_gap=y_gap;
  this.Hide();
  return(true);
 }
//+------------------------------------------------------------------+
//| Pictures by pointer type (Kazharski SetPointerBmp)               |
//+------------------------------------------------------------------+
void CPointer::SetPointerBmp(void)
 {
  switch(this.m_pointer_type)
    {
     case MP_X_RESIZE :
        this.m_file_on =IMAGE_RESOURCE_BMP16_POINTER_X_RS_BMP;
        this.m_file_off=IMAGE_RESOURCE_BMP16_POINTER_X_RS_BLUE_BMP;
        break;
     case MP_Y_RESIZE :
        this.m_file_on =IMAGE_RESOURCE_BMP16_POINTER_Y_RS_BMP;
        this.m_file_off=IMAGE_RESOURCE_BMP16_POINTER_Y_RS_BLUE_BMP;
        break;
     case MP_XY1_RESIZE :
        this.m_file_on =IMAGE_RESOURCE_BMP16_POINTER_XY1_RS_BMP;
        this.m_file_off=IMAGE_RESOURCE_BMP16_POINTER_XY1_RS_BLUE_BMP;
        break;
     case MP_XY2_RESIZE :
        this.m_file_on =IMAGE_RESOURCE_BMP16_POINTER_XY2_RS_BMP;
        this.m_file_off=IMAGE_RESOURCE_BMP16_POINTER_XY2_RS_BLUE_BMP;
        break;
     case MP_WINDOW_RESIZE :
        this.m_file_on =IMAGE_RESOURCE_BMP16_POINTER_X_RS_BMP;
        this.m_file_off=IMAGE_RESOURCE_BMP16_POINTER_Y_RS_BMP;
        break;
     case MP_X_RESIZE_RELATIVE :
        this.m_file_on =IMAGE_RESOURCE_BMP16_POINTER_X_RS_REL_BMP;
        this.m_file_off=IMAGE_RESOURCE_BMP16_POINTER_X_RS_REL_BMP;
        break;
     case MP_Y_RESIZE_RELATIVE :
        this.m_file_on =IMAGE_RESOURCE_BMP16_POINTER_Y_RS_REL_BMP;
        this.m_file_off=IMAGE_RESOURCE_BMP16_POINTER_Y_RS_REL_BMP;
        break;
     case MP_X_SCROLL :
        this.m_file_on =IMAGE_RESOURCE_BMP16_POINTER_X_SCROLL_BMP;
        this.m_file_off=IMAGE_RESOURCE_BMP16_POINTER_X_SCROLL_BLUE_BMP;
        break;
     case MP_Y_SCROLL :
        this.m_file_on =IMAGE_RESOURCE_BMP16_POINTER_Y_SCROLL_BMP;
        this.m_file_off=IMAGE_RESOURCE_BMP16_POINTER_Y_SCROLL_BLUE_BMP;
        break;
     case MP_TEXT_SELECT :
        this.m_file_on =IMAGE_RESOURCE_BMP16_POINTER_TEXT_SELECT_BMP;
        this.m_file_off=IMAGE_RESOURCE_BMP16_POINTER_TEXT_SELECT_BMP;
        break;
     default :
        break;
    }
  if(this.m_pointer_type==MP_CUSTOM && (this.m_file_on==0 || this.m_file_off==0))
     ::Print(__FUNCTION__," > You need to set pictures for the cursor pointer!");
  if(this.ImagesGroupTotal()<1)
     this.AddImagesGroup(0,0);
  if(this.ImagesTotal(0)<2)
    {
     this.AddImage(0,this.m_file_on);
     this.AddImage(0,this.m_file_off);
    }
  else
    {
     this.SetImage(0,0,this.m_file_on);
     this.SetImage(0,1,this.m_file_off);
    }
  this.ChangeImage(0,0);
 }
#endif // CPOINTER_MQH_IMPLEMENTATION
#endif // CPOINTER_MQH
