//+------------------------------------------------------------------+
//|                                                 TestControls.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

//+------------------------------------------------------------------+
// | Included Libraries |
//+------------------------------------------------------------------+
//#include "Controls\Base_En.mqh"
#include <Vendors\Anhnt\3. MVC Table\17960 Base graphical element Lib\Base_EN_Working.mqh>
  
CCanvasBase *obj1=NULL;       // Pointer to the first graphic element
CCanvasBase *obj2=NULL;       // Pointer to the second graphic element
  
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   // // === DIRECT CANVAS TEST ===
      // CCanvas test_canvas;
      // test_canvas.CreateBitmapLabel(0, 0, "DirectTest", 200, 100, 150, 150, COLOR_FORMAT_ARGB_NORMALIZE);
      // test_canvas.Erase(ColorToARGB(clrRed, 200));
      // test_canvas.Update(true);
      // Sleep(3000);
      // test_canvas.Destroy();
      // // === END TEST ===

   // --- Create the first graphic element
      obj1=new CCanvasBase(0,0,"TestScr1",100,40,160,160);
      obj1.SetAlpha(250);        // Transparency
      obj1.SetBorderWidth(6);    // Frame width
   // --- Fill the background with color and draw a frame with an indent of one pixel from the set frame width
      obj1.Fill(clrDodgerBlue,false);      
      // // Debug Check actual bitmap size on chart
         //    Print("XSIZE = ", ObjectGetInteger(0, obj1.NameBG(), OBJPROP_XSIZE)," YSIZE = ", ObjectGetInteger(0, obj1.NameBG(), OBJPROP_YSIZE));        
         //    Print("XDISTANCE = ", ObjectGetInteger(0, obj1.NameBG(), OBJPROP_XDISTANCE)," YDISTANCE = ", ObjectGetInteger(0, obj1.NameBG(), OBJPROP_YDISTANCE));       
         
         // // Debug Ẩn foreground để xem background có đúng không
         // ObjectSetInteger(0, obj1.NameFG(), OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
         // ChartRedraw(0);     
      uint wd=obj1.BorderWidth();
      obj1.GetBackground().Rectangle(wd-2,wd-2,obj1.Width()-wd+1,obj1.Height()-wd+1,ColorToARGB(clrWheat));
      //obj1.GetForeground().Erase(0x00000000);
      obj1.Update(false);
      //obj1.Update(true);//Force Redraw
   // --- Set the name and identifier of the element and display its description in the log
      obj1.SetName("Rectangle 1");
      obj1.SetID(1);
      obj1.Print();   
      // // DEBUG - DEBUG obj1
         //    Print("=== DEBUG obj1 ===");
         //    Print("Alpha = ", obj1.Alpha(),"Width = ", obj1.Width()," Height = ", obj1.Height());     
         //    Print("X = ", obj1.X()," Y = ", obj1.Y());     
         //    Print("ObjectWidth = ", obj1.GetBackground().Width()," ObjectHeight = ", obj1.GetBackground().Height());      
         //    Print("NameBG = ", obj1.NameBG()," Visible BG = ", ObjectGetInteger(0, obj1.NameBG(), OBJPROP_TIMEFRAMES));    
         //    Print("Hidden = ", obj1.IsHidden()," ColorToARGB result = ", ColorToARGB(clrDodgerBlue, 250)," Expected ~= 0xFA1E90FF");
   
      // --- Create a second element inside the first one, set transparency for it
   // --- and specify the first element as the container for the second element
      int shift=10;
      int x=obj1.X()+shift;
      int y=obj1.Y()+shift;
      int w=obj1.Width()-shift*2;
      int h=obj1.Height()-shift*2;
      obj2=new CCanvasBase(0,0,"TestScr2",x,y,w,h);
      obj2.SetAlpha(250);
      obj2.SetContainerObj(obj1);
   // --- Initialize the background color, specify the color for the blocked element
   // --- and make the element's current background color the default background color
      obj2.InitBackColors(clrLime);
      obj2.InitBackColorBlocked(clrLightGray);
      obj2.BackColorToDefault();

   // --- Initialize the foreground color, specify the color for the blocked element
   // --- and make the element's current foreground color the default text color
      obj2.InitForeColors(clrBlack);
      obj2.InitForeColorBlocked(clrDimGray);
      obj2.ForeColorToDefault();
   // --- Initialize the frame color, specify the color for the blocked element
   // --- and make the current border color of the element the default border color
      obj2.InitBorderColors(clrBlue);
      obj2.InitBorderColorBlocked(clrSilver);
      obj2.BorderColorToDefault();
   // --- Set the name and identifier of the element,
   // --- display its description in the log and draw the element
      obj2.SetName("Rectangle 2");
      obj2.SetID(2);
      obj2.Print();
      //Add here
      obj2.Fill(obj2.BackColor(), false);
      //obj2.GetForeground().Erase(0x00000000);
      obj2.Draw(true);      
   // --- Let's check whether the element is trimmed along the boundaries of its container
      int ms=1;         // Offset delay in milliseconds
      int total=obj1.Width()-shift; // Number of offset loop iterations
      
   // --- Wait a second and move the inner object beyond the left edge of the container
      Sleep(1000);
      ShiftHorisontal(-1,total,ms);
   // --- Wait a second and return the internal object to its original place
      Sleep(1000);
      ShiftHorisontal(1,total,ms);

   // --- Wait a second and move the inner object beyond the right edge of the container
      Sleep(1000);
      ShiftHorisontal(1,total,ms);
   // --- Wait a second and return the internal object to its original place
      Sleep(1000);
      ShiftHorisontal(-1,total,ms);      
   // --- Wait a second and move the inner object beyond the top edge of the container
      Sleep(1000);
      ShiftVertical(-1,total,ms);
   // --- Wait a second and return the internal object to its original place
      Sleep(1000);
      ShiftVertical(1,total,ms);
      
   // --- Wait a second and move the inner object beyond the bottom edge of the container
      Sleep(1000);
      ShiftVertical(1,total,ms);
   // --- Wait a second and return the internal object to its original place
      Sleep(1000);
      ShiftVertical(-1,total,ms);

   // --- Wait a second and set the internal object to a blocked element flag
      Sleep(1000);
      obj2.Block(true);

   // --- After three seconds, before completing the work, we clean up after ourselves
      Sleep(3000);
      delete obj1;
      delete obj2;
}
//+------------------------------------------------------------------+
// | Shifts an object horizontally |
//+------------------------------------------------------------------+
void ShiftHorisontal(const int dx, const int total, const int delay)
{
   for(int i=0;i<total;i++)
     {
      if(obj2.ShiftX(dx))
      {
         obj2.Fill(obj2.BackColor(), false);
         ChartRedraw();
      }         
      Sleep(delay);
     }
}
//+------------------------------------------------------------------+
// | Shifts an object vertically |
//+------------------------------------------------------------------+
void ShiftVertical(const int dy, const int total, const int delay)
{
   for(int i=0;i<total;i++)
     {
      if(obj2.ShiftY(dy))
      {
         obj2.Fill(obj2.BackColor(), false);
         ChartRedraw();
      }         
      Sleep(delay);
     }
}
//+------------------------------------------------------------------+
