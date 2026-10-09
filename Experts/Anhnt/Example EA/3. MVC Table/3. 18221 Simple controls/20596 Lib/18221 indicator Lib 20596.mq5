//+------------------------------------------------------------------+
//|                                                   iTestLabel.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 0
#property indicator_plots   0

//+------------------------------------------------------------------+
// | Included Libraries |
//+------------------------------------------------------------------+
#include <Arrays\ArrayObj.mqh>
//#include "Controls\Controls_En.mqh"
//#include <Vendors\Anhnt\3. MVC Table\20596 Lib\Controls\Controls_EN.mqh>
#include <Vendors\Anhnt\Library\3. MVC Table\18221 Lib\Controls_EN.mqh>

  
CArrayObj         list;             // List for storing test objects
CCanvasBase      *base =NULL;       // Pointer to the underlying graphic element
CLabel           *label1=NULL;      // Pointer to the Label graphic element
CLabel           *label2=NULL;      // Pointer to the Label graphic element
CLabel           *label3=NULL;      // Pointer to the Label graphic element
CButton          *button1=NULL;     // Pointer to the Button graphic element
CButtonTriggered *button_t1=NULL;   // Pointer to a ButtonTriggered graphic element
CButtonTriggered *button_t2=NULL;   // Pointer to a ButtonTriggered graphic element
CButtonArrowUp   *button_up=NULL;   // Pointer to a CButtonArrowUp graphic element
CButtonArrowDown *button_dn=NULL;   // Pointer to a graphic element CButtonArrowDown
CButtonArrowLeft *button_lt=NULL;   // Pointer to a graphic element CButtonArrowLeft
CButtonArrowRight*button_rt=NULL;   // Pointer to a graphic element CButtonArrowRight
CCheckBox        *checkbox_lt=NULL; // Pointer to a CCheckBox graphic element
CCheckBox        *checkbox_rt=NULL; // Pointer to a CCheckBox graphic element
CRadioButton     *radio_bt_lt=NULL; // Pointer to a graphic element CRadioButton
CRadioButton     *radio_bt_rt=NULL; // Pointer to a graphic element CRadioButton

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   //Due to No CCommonManager in 18221 Lib we need to delete object before creating them 
      CleanGraphicObjects("Label");
      CleanGraphicObjects("Rectangle");
      CleanGraphicObjects("Button");

   // --- Looking for a chart subwindow
      int wnd=ChartWindowFind();
   // --- Create a basic graphic element
      list.Add(base=new CCanvasBase("Rectangle",0,wnd,100,40,260,160));
      base.SetAlphaBG(250);      // Transparency
      base.SetBorderWidth(6);    // Frame width      
   // --- Initialize the background color, specify the color for the blocked element
   // --- and make the element's current background color the default background color
      base.InitBackColors(clrWhiteSmoke);
      base.InitBackColorBlocked(clrLightGray);
      base.BackColorToDefault();
      
   // --- Fill the background with color and draw a frame with an indent of one pixel from the set frame width
      base.Fill(base.BackColor(),false);
      //uint wd=base.BorderWidth();
      uint wd=base.BorderWidthTop(); //Modify to Match 20596 Lib
      base.GetBackground().Rectangle(0,0,base.Width()-1,base.Height()-1,ColorToARGB(clrDimGray));
      base.GetBackground().Rectangle(wd-2,wd-2,base.Width()-wd+1,base.Height()-wd+1,ColorToARGB(clrLightGray));
      base.Update(false);
   // --- Set the name and identifier of the element and display its description in the log
      base.SetName("Rectangle 1");
      base.SetID(1);
      base.Print();
      

   // --- Create a text label inside the base object
   // --- and specify the base element for the label as a container
      string text="Simple button:";
      int shift_x=20;
      int shift_y=8;
      int x=base.X()+shift_x-10;
      int y=base.Y()+shift_y+2;
      int w=base.GetForeground().TextWidth(text);
      int h=DEF_LABEL_H;
      string textlabel1 = "Simple button:";
      label1 = new CLabel("Label 1", textlabel1, 0, wnd, x, y, w, h);
      list.Add(label1);
      //list.Add(label1=new CLabel("Label 1",0,wnd,text,x,y,w,h));
      label1.SetContainerObj(base);
   // --- Set the hover and click color of the element to red
   // --- (this is changing the standard parameters of a text label after its creation).
      label1.InitForeColorFocused(clrRed);   
      label1.InitForeColorPressed(clrRed);
   // --- Set the element identifier, draw the element
   // --- and display its description in the log.
      label1.SetID(2);
      label1.Draw(false);
      //Debug
         Print("Label X: ", label1.X(), " | Label Y: ", label1.Y());
         Print("Base X: ", base.X(), " | Base Y: ", base.Y());
         Print("Base Width: ", base.Width(), " | Base Height: ", base.Height());
      label1.Print();   
         
      // --- Create a simple button inside the base object
      // --- and specify the base element for the button as a container
         x=label1.Right()+shift_x;
         y=label1.Y();
         w=DEF_BUTTON_W;
         h=DEF_BUTTON_H;
         string textbutton1="Simple Button";
         button1=new CButton("Button 1",textbutton1,0, wnd, x, y, w, h);
         list.Add(button1);
         //list.Add(button1=new CButton("Simple Button",0,wnd,"Button 1",x,y,w,h));
         button1.SetContainerObj(base);
      // --- Set the offset of the button text along the X axis
         button1.SetTextShiftH(2);
      // --- Set the element identifier, draw the element
      // --- and display its description in the log.
         button1.SetID(3);
         button1.Draw(false);
         button1.Print();        
         
      // --- Create a text label inside the base object
      // --- and specify the base element for the label as a container
         string textTriggeredLabel="Triggered button:";
         x=label1.X();
         y=label1.Bottom()+shift_y;
         w=base.GetForeground().TextWidth(text);
         h=DEF_LABEL_H;
         label2=new CLabel("Label 2", textTriggeredLabel, 0, wnd, x, y, w, h);
         list.Add(label2);
         //list.Add(label2=new CLabel("Label 2",0,wnd,text,x,y,w,h));
         label2.SetContainerObj(base);
      // --- Set the hover and click color of the element to red
      // --- (this is changing the standard parameters of a text label after its creation).
         label2.InitForeColorFocused(clrRed);
         label2.InitForeColorPressed(clrRed);
      // --- Set the element identifier, draw the element
      // --- and display its description in the log.
         label2.SetID(4);
         label2.Draw(false);
         label2.Print();
         
         
      // // --- Create a two-position button inside the base object
      // // --- and specify the base element for the button as a container
      //    x=button1.X();
      //    y=button1.Bottom()+shift_y;
      //    w=DEF_BUTTON_W;
      //    h=DEF_BUTTON_H;
      //    list.Add(button_t1=new CButtonTriggered("Triggered Button 1",0,wnd,"Button 2",x,y,w,h));
      //    button_t1.SetContainerObj(base);

      // // --- Set the offset of the button text along the X axis
      //    button_t1.SetTextShiftH(2);
      // // --- Set the identifier and activated state of the element,
      // // --- draw the element and display its description in the log.
      //    button_t1.SetID(5);
      //    button_t1.SetState(true);
      //    button_t1.Draw(false);
      //    button_t1.Print();
         
         
      // // --- Create a two-position button inside the base object
      // // --- and specify the base element for the button as a container
      //    x=button_t1.Right()+4;
      //    y=button_t1.Y();
      //    w=DEF_BUTTON_W;
      //    h=DEF_BUTTON_H;
      //    list.Add(button_t2=new CButtonTriggered("Triggered Button 2",0,wnd,"Button 3",x,y,w,h));
      //    button_t2.SetContainerObj(base);

      // // --- Set the offset of the button text along the X axis
      //    button_t2.SetTextShiftH(2);
      // // --- Set the element identifier, draw the element
      // // --- and display its description in the log.
      //    button_t2.SetID(6);
      //    button_t2.Draw(false);
      //    button_t2.Print();
         
         
      // // --- Create a text label inside the base object
      // // --- and specify the base element for the label as a container
      //    text="Arrowed buttons:";
      //    x=label1.X();
      //    y=label2.Bottom()+shift_y;
      //    w=base.GetForeground().TextWidth(text);
      //    h=DEF_LABEL_H;
      //    list.Add(label3=new CLabel("Label 3",0,wnd,text,x,y,w,h));
      //    label3.SetContainerObj(base);
      // // --- Set the hover and click color of the element to red
      // // --- (this is changing the standard parameters of a text label after its creation).
      //    label3.InitForeColorFocused(clrRed);
      //    label3.InitForeColorPressed(clrRed);
      // // --- Set the element identifier, draw the element
      // // --- and display its description in the log.
      //    label3.SetID(7);
      //    label3.Draw(false);
      //    label3.Print();
         
         
      // // --- Inside the base object we create a button with an up arrow
      // // --- and specify the base element for the button as a container
      //    x=button1.X();
      //    y=button_t1.Bottom()+shift_y;
      //    w=DEF_BUTTON_H-1;
      //    h=DEF_BUTTON_H-1;
      //    list.Add(button_up=new CButtonArrowUp("Arrow Up Button","",0,wnd,x,y,w,h));
      //    button_up.SetContainerObj(base);
      // // --- Set the dimensions and offset of the image along the X axis
      //    button_up.SetImageBound(1,1,w-4,h-3);
      // // --- Here you can customize the appearance of the button, for example, remove the frame
      //    //button_up.InitBorderColors(button_up.BackColor(),button_up.BackColorFocused(),button_up.BackColorPressed(),button_up.BackColorBlocked());
      //    //button_up.ColorsToDefault();
      // // --- Set the element identifier, draw the element
      // // --- and display its description in the log.
      //    button_up.SetID(8);
      //    button_up.Draw(false);
      //    button_up.Print();
         
         
      // // --- Inside the base object we create a button with a down arrow
      // // --- and specify the base element for the button as a container
      //    x=button_up.Right()+4;
      //    y=button_up.Y();
      //    w=DEF_BUTTON_H-1;
      //    h=DEF_BUTTON_H-1;
      //    list.Add(button_dn=new CButtonArrowDown("Arrow Down Button","",0,wnd,x,y,w,h));
      //    button_dn.SetContainerObj(base);
      // // --- Set the dimensions and offset of the image along the X axis
      //    button_dn.SetImageBound(1,1,w-4,h-3);
      // // --- Set the element identifier, draw the element
      // // --- and display its description in the log.
      //    button_dn.SetID(9);
      //    button_dn.Draw(false);
      //    button_dn.Print();
         
         
      // // --- Inside the base object we create a button with a left arrow
      // // --- and specify the base element for the button as a container
      //    x=button_dn.Right()+4;
      //    y=button_up.Y();
      //    w=DEF_BUTTON_H-1;
      //    h=DEF_BUTTON_H-1;
      //    list.Add(button_lt=new CButtonArrowLeft("Arrow Left Button","",0,wnd,x,y,w,h));
      //    button_lt.SetContainerObj(base);
      // // --- Set the dimensions and offset of the image along the X axis
      //    button_lt.SetImageBound(1,1,w-3,h-4);
      // // --- Set the element identifier, draw the element
      // // --- and display its description in the log.
      //    button_lt.SetID(10);
      //    button_lt.Draw(false);
      //    button_lt.Print();
         
         
      // // --- Inside the base object we create a button with a right arrow
      // // --- and specify the base element for the button as a container
      //    x=button_lt.Right()+4;
      //    y=button_up.Y();
      //    w=DEF_BUTTON_H-1;
      //    h=DEF_BUTTON_H-1;
      //    list.Add(button_rt=new CButtonArrowRight("Arrow Right Button","",0,wnd,x,y,w,h));
      //    button_rt.SetContainerObj(base);
      // // --- Set the dimensions and offset of the image along the X axis
      //    button_rt.SetImageBound(1,1,w-3,h-4);
      // // --- Set the element identifier, draw the element
      // // --- and display its description in the log.
      //    button_rt.SetID(11);
      //    button_rt.Draw(false);
      //    button_rt.Print();
         
         
      // // --- Inside the base object, create a checkbox with a title on the right (left checkbox)
      // // --- and specify the base element for the button as a container
      //    x=label1.X();
      //    y=label3.Bottom()+shift_y;
      //    w=DEF_BUTTON_W+30;
      //    h=DEF_BUTTON_H;
      //    list.Add(checkbox_lt=new CCheckBox("CheckBoxL",0,wnd,"CheckBox L",x,y,w,h));
      //    checkbox_lt.SetContainerObj(base);
      // // --- Set the coordinates and dimensions of the image area
      //    checkbox_lt.SetImageBound(2,1,h-2,h-2);
      // // --- Set the offset of the button text along the X axis
      //    checkbox_lt.SetTextShiftH(checkbox_lt.ImageRight()+2);
      // // --- Set the element identifier, draw the element
      // // --- and display its description in the log.
      //    checkbox_lt.SetID(12);
      //    checkbox_lt.Draw(false);
      //    checkbox_lt.Print();
         
         
      // // --- Inside the base object, create a checkbox with a title on the left (right checkbox)
      // // --- and specify the base element for the button as a container
      //    x=checkbox_lt.Right()+4;
      //    y=checkbox_lt.Y();
      //    w=DEF_BUTTON_W+30;
      //    h=DEF_BUTTON_H;
      //    list.Add(checkbox_rt=new CCheckBox("CheckBoxR",0,wnd,"CheckBox R",x,y,w,h));
      //    checkbox_rt.SetContainerObj(base);
      // // --- Set the coordinates and dimensions of the image area
      //    checkbox_rt.SetTextShiftH(2);
      // // --- Set the offset of the button text along the X axis
      //    checkbox_rt.SetImageBound(checkbox_rt.Width()-h+2,1,h-2,h-2);
      // // --- Set the identifier and activated state of the element,
      // // --- draw the element and display its description in the log.
      //    checkbox_rt.SetID(13);
      //    checkbox_rt.SetState(true);
      //    checkbox_rt.Draw(false);
      //    checkbox_rt.Print();
         
         
      // // --- Inside the base object, create a radio button with a title on the right (left RadioButton)
      // // --- and specify the base element for the button as a container
      //    x=checkbox_lt.X();
      //    y=checkbox_lt.Bottom()+shift_y;
      //    w=DEF_BUTTON_W+46;
      //    h=DEF_BUTTON_H;
      //    list.Add(radio_bt_lt=new CRadioButton("RadioButtonL",0,wnd,"RadioButton L",x,y,w,h));
      //    radio_bt_lt.SetContainerObj(base);
      // // --- Set the coordinates and dimensions of the image area
      //    radio_bt_lt.SetImageBound(2,1,h-2,h-2);
      // // --- Set the offset of the button text along the X axis
      //    radio_bt_lt.SetTextShiftH(radio_bt_lt.ImageRight()+2);
      // // --- Set the identifier and activated state of the element,
      // // --- draw the element and display its description in the log.
      //    radio_bt_lt.SetID(14);
      //    radio_bt_lt.SetState(true);
      //    radio_bt_lt.Draw(false);
      //    radio_bt_lt.Print();
         
         
      // // --- Inside the base object, create a radio button with a title on the left (right RadioButton)
      // // --- and specify the base element for the button as a container
      //    x=radio_bt_lt.Right()+4;
      //    y=radio_bt_lt.Y();
      //    w=DEF_BUTTON_W+46;
      //    h=DEF_BUTTON_H;
      //    list.Add(radio_bt_rt=new CRadioButton("RadioButtonR",0,wnd,"RadioButton R",x,y,w,h));
      //    radio_bt_rt.SetContainerObj(base);
      // // --- Set the offset of the button text along the X axis
      //    radio_bt_rt.SetTextShiftH(2);
      // // --- Set the coordinates and dimensions of the image area
      //    radio_bt_rt.SetImageBound(radio_bt_rt.Width()-h+2,1,h-2,h-2);
      // // --- Set the element identifier, draw the element
      // // --- and display its description in the log.
      //    radio_bt_rt.SetID(15);
      //    radio_bt_rt.Draw(true);
      //    radio_bt_rt.Print();

   // --- Successful initialization
      return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom deindicator initialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   list.Clear();
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
// --- Call the event handler of each of the created objects
   for(int i=0;i<list.Total();i++)
     {
      CCanvasBase *obj=list.At(i);
      if(obj!=NULL)
         obj.OnChartEvent(id,lparam,dparam,sparam);
     }
     
// --- Emulate the operation of radio buttons in a group ---
// --- If a custom event is received
   if(id>=CHARTEVENT_CUSTOM)
     {
      // --- If the left radio button is pressed
      if(sparam==radio_bt_lt.NameBG())
        {
         // --- If the button state is changed (was not selected)
         if(radio_bt_lt.State())
           {
            // --- make the right radio button unselected and redraw it
            radio_bt_rt.SetState(false);
            radio_bt_rt.Draw(true);
           }
        }
      // --- When the right radio button is pressed
      if(sparam==radio_bt_rt.NameBG())
        {
         // --- If the button state is changed (was not selected)
         if(radio_bt_rt.State())
           {
            // --- make the left radio button unselected and redraw it
            radio_bt_lt.SetState(false);
            radio_bt_lt.Draw(true);
           }
        }
     }
  }
//+------------------------------------------------------------------+

void CleanGraphicObjects(string prefix)
{
   for(int i = ObjectsTotal(0, -1, -1) - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i, -1, -1);
      if(StringFind(name, prefix) == 0) // Nếu tên bắt đầu bằng prefix
      {
         ObjectDelete(0, name);
      }
   }
}
