//+------------------------------------------------------------------+
//|                                                TableCellView.mqh |
//+------------------------------------------------------------------+
#property strict

#ifndef CTABLECELLVIEW_MQH
#define CTABLECELLVIEW_MQH
 #include "..\..\..\GBases\GElement.mqh"
 #include "..\Model\TableCell.mqh"
#ifndef CTABLECELLVIEW_MQH_DECLARATION
#define CTABLECELLVIEW_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Draws its model cell on the table canvas: icon + formatted text  |
//+------------------------------------------------------------------+
class CTableCellView : public CGBaseObj
 {
  private:
    CTableCell       *m_cell;
    ENUM_TYPE_CELL    m_cell_type;
    CImage            m_images[];
    int               m_selected_image;
    bool              m_direction_mode;
    bool              m_direction_colors;
    color             m_color_inc;
    color             m_color_dec;
    color             m_color_same;
    color             m_text_color;
    color             m_back_color;
    string            m_value_list[];
    CImage            m_combobox_arrow;

    int               CurrentImage(void);
    string            CorrectingText(CCanvas &canvas,const string text,const int max_width);
  public:
    void              Bind(CTableCell *cell)                     { this.m_cell=cell;          }
    CTableCell       *Cell(void)                           const { return(this.m_cell);       }
    void              CellType(const ENUM_TYPE_CELL type);
    ENUM_TYPE_CELL    CellType(void)                       const { return(this.m_cell_type);  }
    void              SetImages(const uint &resource_index[]);
    int               ImagesTotal(void)                    const { return(::ArraySize(this.m_images)); }
    void              ChangeImage(const int index);
    int               SelectedImage(void)                  const { return(this.m_selected_image); }
    void              DirectionImages(const bool mode)           { this.m_direction_mode=mode; }
    void              TextColor(const color clr);
    color             TextColor(void)                      const { return(this.m_text_color); }
    void              BackColor(const color clr);
    void              DirectionColors(const color clr_inc,const color clr_dec,const color clr_same);
    color             BackColor(void)                      const { return(this.m_back_color); }
    void              SetValueList(const string &array[]);
    int               ValueListTotal(void)                 const { return(::ArraySize(this.m_value_list)); }
    string            ValueListItem(const int index)       const { return(index>=0 && index<::ArraySize(this.m_value_list) ? this.m_value_list[index] : ""); }
    int               ValueListIndex(void);
    void              DrawCell(CCanvas &canvas,const int x,const int y,const int w,const int h,const color back,const color text,
                               const ENUM_ALIGN_MODE align,const int text_x_offset,const int image_x_offset,const bool selected);
                     CTableCellView(void);
                    ~CTableCellView(void) {}
 };
#endif // CTABLECELLVIEW_MQH_DECLARATION
#ifndef CTABLECELLVIEW_MQH_IMPLEMENTATION
#define CTABLECELLVIEW_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| clrNONE colors = the row decides                                 |
//+------------------------------------------------------------------+
CTableCellView::CTableCellView(void) : m_cell(NULL),
                                       m_cell_type(CELL_SIMPLE),
                                       m_selected_image(0),
                                       m_direction_mode(false),
                                       m_direction_colors(false),
                                       m_color_inc(clrNONE),
                                       m_color_dec(clrNONE),
                                       m_color_same(clrNONE),
                                       m_text_color(clrNONE),
                                       m_back_color(clrNONE)
 {
 }
//+------------------------------------------------------------------+
//| Checkbox without own images gets the V2 _G_ checkbox pair,       |
//| combobox gets the down arrow                                     |
//+------------------------------------------------------------------+
void CTableCellView::CellType(const ENUM_TYPE_CELL type)
 {
  this.m_cell_type=type;
  if(type==CELL_CHECKBOX && ::ArraySize(this.m_images)<2)
    {
     uint check[]={IMAGE_RESOURCE_BMP16_CHECKBOX_OFF_G_PNG,IMAGE_RESOURCE_BMP16_CHECKBOX_ON_G_PNG};
     this.SetImages(check);
    }
  if(type==CELL_COMBOBOX && this.m_combobox_arrow.Width()<1)
     this.m_combobox_arrow.ReadImageData(IMAGE_RESOURCE_BMP16_DOWN_THIN_BLACK_BMP);
  if(this.m_cell!=NULL)
     this.m_cell.SetEventFlag(true);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTableCellView::SetImages(const uint &resource_index[])
 {
  int total=::ArraySize(resource_index);
  ::ArrayResize(this.m_images,total);
  for(int i=0; i<total; i++)
    {
     this.m_images[i].DeleteImageData();
     this.m_images[i].ReadImageData(resource_index[i]);
    }
  this.m_selected_image=0;
  if(this.m_cell!=NULL)
     this.m_cell.SetEventFlag(true);
 }
//+------------------------------------------------------------------+
//| Setters below only mark the cell for redraw on a real change     |
//+------------------------------------------------------------------+
void CTableCellView::ChangeImage(const int index)
 {
  if(index==this.m_selected_image)
     return;
  this.m_selected_image=index;
  this.m_cell.SetEventFlag(true);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTableCellView::TextColor(const color clr)
 {
  if(clr==this.m_text_color)
     return;
  this.m_text_color=clr;
  this.m_cell.SetEventFlag(true);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTableCellView::BackColor(const color clr)
 {
  if(clr==this.m_back_color)
     return;
  this.m_back_color=clr;
  this.m_cell.SetEventFlag(true);
 }
//+------------------------------------------------------------------+
//| Text color from the model's INC/DEC (text/"N/A" cells: same)     |
//+------------------------------------------------------------------+
void CTableCellView::DirectionColors(const color clr_inc,const color clr_dec,const color clr_same)
 {
  this.m_direction_colors=true;
  this.m_color_inc =clr_inc;
  this.m_color_dec =clr_dec;
  this.m_color_same=clr_same;
  if(this.m_cell!=NULL)
     this.m_cell.SetEventFlag(true);
 }
//+------------------------------------------------------------------+
//| Choices of a combobox cell (Kazharski m_value_list)              |
//+------------------------------------------------------------------+
void CTableCellView::SetValueList(const string &array[])
 {
  ::ArrayCopy(this.m_value_list,array);
  ::ArrayResize(this.m_value_list,::ArraySize(array));
 }
//+------------------------------------------------------------------+
//| Position of the model text in the choices, WRONG_VALUE if none   |
//+------------------------------------------------------------------+
int CTableCellView::ValueListIndex(void)
 {
  if(this.m_cell==NULL)
     return(WRONG_VALUE);
  string value=this.m_cell.Value();
  for(int i=0; i<::ArraySize(this.m_value_list); i++)
     if(this.m_value_list[i]==value)
        return(i);
  return(WRONG_VALUE);
 }
//+------------------------------------------------------------------+
//| Checkbox: value 0/1; direction mode: 0 up, 1 down, 2 unchanged   |
//+------------------------------------------------------------------+
int CTableCellView::CurrentImage(void)
 {
  int total=::ArraySize(this.m_images);
  if(total<1)
     return(WRONG_VALUE);
  int index=this.m_selected_image;
  if(this.m_cell_type==CELL_CHECKBOX && total>=2)
     index=(this.m_cell.ValueL()!=0 ? 1 : 0);
  else if(this.m_direction_mode && total>=3)
     index=(this.m_cell.IsIncreased() ? 0 : this.m_cell.IsDecreased() ? 1 : 2);
  return(index>=0 && index<total ? index : WRONG_VALUE);
 }
//+------------------------------------------------------------------+
//| Kazharski CorrectingText: cut and end with "..."                 |
//+------------------------------------------------------------------+
string CTableCellView::CorrectingText(CCanvas &canvas,const string text,const int max_width)
 {
  if(max_width<1 || canvas.TextWidth(text)<=max_width)
     return(text);
  for(int len=::StringLen(text)-1; len>0; len--)
    {
     string cut=::StringSubstr(text,0,len)+"...";
     if(canvas.TextWidth(cut)<=max_width)
        return(cut);
    }
  return("");
 }
//+------------------------------------------------------------------+
//| Cell minus grid: back, icon, text after it; selected row wins    |
//+------------------------------------------------------------------+
void CTableCellView::DrawCell(CCanvas &canvas,const int x,const int y,const int w,const int h,const color back,const color text,
                              const ENUM_ALIGN_MODE align,const int text_x_offset,const int image_x_offset,const bool selected)
 {
  if(this.m_cell==NULL)
     return;
  color back_color=(this.m_back_color!=clrNONE && !selected ? this.m_back_color : back);
  canvas.FillRectangle(x,y,x+w-2,y+h-2,::ColorToARGB(back_color,255));
  int text_left=x+text_x_offset;
  int image=this.CurrentImage();
  if(image!=WRONG_VALUE)
    {
     int ix=x+image_x_offset;
     this.m_images[image].Draw(canvas,ix,y+(h-1-(int)this.m_images[image].Height())/2);
     text_left=::MathMax(text_left,ix+(int)this.m_images[image].Width()+4);
    }
  if(this.m_cell_type==CELL_CHECKBOX)
     return;
  int right_limit=x+w-2;
  if(this.m_cell_type==CELL_COMBOBOX && this.m_combobox_arrow.Width()>0)
    {
     right_limit=x+w-2-(int)this.m_combobox_arrow.Width();
     this.m_combobox_arrow.Draw(canvas,right_limit,y+(h-1-(int)this.m_combobox_arrow.Height())/2);
    }
  int  tx=text_left;
  uint anchor=TA_LEFT;
  int  max_width=right_limit-text_left;
  if(align==ALIGN_CENTER)
    {
     tx=x+(right_limit-x)/2;
     anchor=TA_CENTER;
     max_width=right_limit-x-4;
    }
  else if(align==ALIGN_RIGHT)
    {
     tx=right_limit-text_x_offset;
     anchor=TA_RIGHT;
     max_width=tx-text_left;
    }
  color text_color=(this.m_text_color!=clrNONE && !selected ? this.m_text_color : text);
  if(this.m_direction_colors && !selected)
     text_color=(this.m_cell.Datatype()==TYPE_STRING ? this.m_color_same :
                 this.m_cell.IsIncreased() ? this.m_color_inc : this.m_cell.IsDecreased() ? this.m_color_dec : this.m_color_same);
  canvas.TextOut(tx,y+(h-1)/2,this.CorrectingText(canvas,this.m_cell.Value(),max_width),::ColorToARGB(text_color,255),anchor|TA_VCENTER);
 }
#endif // CTABLECELLVIEW_MQH_IMPLEMENTATION
#endif // CTABLECELLVIEW_MQH
