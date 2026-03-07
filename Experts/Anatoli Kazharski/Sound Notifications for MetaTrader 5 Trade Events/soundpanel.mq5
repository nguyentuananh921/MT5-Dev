//+------------------------------------------------------------------+
//|                                                   SoundPanel.mq5 |
//|            Copyright 2013, https://login.mql5.com/en/users/tol64 |
//|                                  Site, http://tol64.blogspot.com |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2013, http://tol64.blogspot.com"
#property link        "http://tol64.blogspot.com"
#property description "email: hello.tol64@gmail.com"
#property version     "1.0"
//--- Array size
#define ARRAY_SIZE 26
//--- Sound files
#resource "\\Files\\Sounds\\alert.wav"
#resource "\\Files\\Sounds\\AHOOGA.wav"
#resource "\\Files\\Sounds\\APPLAUSE.wav"
#resource "\\Files\\Sounds\\BONK.wav"
#resource "\\Files\\Sounds\\CARBRAKE.wav"
#resource "\\Files\\Sounds\\CASHREG.wav"
#resource "\\Files\\Sounds\\CLAP.wav"
#resource "\\Files\\Sounds\\CORKPOP.wav"
#resource "\\Files\\Sounds\\DOG.wav"
#resource "\\Files\\Sounds\\DRIVEBY.wav"
#resource "\\Files\\Sounds\\DRUMROLL.wav"
#resource "\\Files\\Sounds\\EXPLODE.wav"
#resource "\\Files\\Sounds\\FINALBEL.wav"
#resource "\\Files\\Sounds\\FROG.wav"
#resource "\\Files\\Sounds\\GLASS.wav"
#resource "\\Files\\Sounds\\GUNSHOT.wav"
#resource "\\Files\\Sounds\\LASER.wav"
#resource "\\Files\\Sounds\\LATNWHIS.wav"
#resource "\\Files\\Sounds\\PIG.wav"
#resource "\\Files\\Sounds\\RICOCHET.wav"
#resource "\\Files\\Sounds\\RINGIN.wav"
#resource "\\Files\\Sounds\\SIREN.wav"
#resource "\\Files\\Sounds\\TRAIN.wav"
#resource "\\Files\\Sounds\\UH_OH.wav"
#resource "\\Files\\Sounds\\VERYGOOD.wav"
#resource "\\Files\\Sounds\\WHOOSH.wav"
//--- Sound file location
string sound_paths[ARRAY_SIZE]=
  {
   "::Files\\Sounds\\alert.wav",
   "::Files\\Sounds\\AHOOGA.wav",
   "::Files\\Sounds\\APPLAUSE.wav",
   "::Files\\Sounds\\BONK.wav",
   "::Files\\Sounds\\CARBRAKE.wav",
   "::Files\\Sounds\\CASHREG.wav",
   "::Files\\Sounds\\CLAP.wav",
   "::Files\\Sounds\\CORKPOP.wav",
   "::Files\\Sounds\\DOG.wav",
   "::Files\\Sounds\\DRIVEBY.wav",
   "::Files\\Sounds\\DRUMROLL.wav",
   "::Files\\Sounds\\EXPLODE.wav",
   "::Files\\Sounds\\FINALBEL.wav",
   "::Files\\Sounds\\FROG.wav",
   "::Files\\Sounds\\GLASS.wav",
   "::Files\\Sounds\\GUNSHOT.wav",
   "::Files\\Sounds\\LASER.wav",
   "::Files\\Sounds\\LATNWHIS.wav",
   "::Files\\Sounds\\PIG.wav",
   "::Files\\Sounds\\RICOCHET.wav",
   "::Files\\Sounds\\RINGIN.wav",
   "::Files\\Sounds\\SIREN.wav",
   "::Files\\Sounds\\TRAIN.wav",
   "::Files\\Sounds\\UH_OH.wav",
   "::Files\\Sounds\\VERYGOOD.wav",
   "::Files\\Sounds\\WHOOSH.wav"
  };
//--- Names of graphical objects
string sound_names[ARRAY_SIZE]=
  {
   "sound_button01","sound_button02",
   "sound_button03","sound_button04",
   "sound_button05","sound_button06",
   "sound_button07","sound_button08",
   "sound_button09","sound_button10",
   "sound_button11","sound_button12",
   "sound_button13","sound_button14",
   "sound_button15","sound_button16",
   "sound_button17","sound_button18",
   "sound_button19","sound_button20",
   "sound_button21","sound_button22",
   "sound_button23","sound_button24",
   "sound_button25","sound_button26"
  };
//--- Text displayed on graphical objects
string sound_texts[ARRAY_SIZE]=
  {
   "ALERT","AHOOGA","APPLAUSE","BONK","CARBRAKE","CASHREG",
   "CLAP","CORKPOP","DOG","DRIVEBY","DRUMROLL","EXPLODE","FINALBEL",
   "FROG","GLASS","GUNSHOT","LASER","LATNWHIS","PIG",
   "RICOCHET","RINGIN","SIREN","TRAIN","UH_OH","VERYGOOD","WHOOSH"
  };
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- Set the sound panel
   SetSoundPanel();
  }
//+------------------------------------------------------------------+
//| Deinitialization function of the expert                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Delete the sound panel
   DeleteSoundPanel();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void OnChartEvent(const int     id,     // Event identifier  
                  const long&   lparam, // Parameter of the event of type long
                  const double& dparam, // Parameter of the event of type double
                  const string& sparam) // Parameter of the event of type string
  {
//--- If there was an event of left-clicking on the object
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      //--- If the object name contains "sound_button"
      if(StringFind(sparam,"sound_button",0)>=0)
        {
         //--- Play the sound based on the object name
         //    5019 - ERR_FILE_NOT_EXIST - The file does not exist
         if(!PlaySound(GetSoundPath(sparam)))
            Print("Error: ",GetLastError());
         //--- Change colors of all buttons
         ChangeColorsOnSoundPanel();
        }
     }
  }
//+------------------------------------------------------------------+
//| Adding the sound panel to the chart                              |
//+------------------------------------------------------------------+
void SetSoundPanel()
  {
   int   column_count =0;       // Column counter
   int   x_dist       =10;      // Indent from the left side of the chart
   int   y_dist       =15;      // Indent from the top of the chart
   int   x_size       =100;     // Button width
   int   y_size       =20;      // Button height
   color button_color =clrNONE; // Button color
//--- Set the objects
   for(int i=0; i<ARRAY_SIZE; i++)
     {
      //--- Increase the column counter
      column_count++;
      //--- Get the button color
      button_color=GetRandomColor();
      //--- Draw a button
      CreateButton(0,0,sound_names[i],sound_texts[i],
                   ANCHOR_LEFT_UPPER,CORNER_LEFT_UPPER,"Arial",8,
                   clrWhite,button_color,button_color,x_size,y_size,x_dist,y_dist,1);
      //--- If two buttons have already been set in the same row
      if(column_count==2)
        {
         x_dist=10;        // Move the X-coordinate to the initial position
         y_dist+=20;       // Set the Y-coordinate for the next row
         column_count=0;   // Zero out the counter
        }
      else
      //--- Set the X-coordinate for the next button 
         x_dist+=x_size;
     }
//--- Refresh the chart
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//| Changing colors on the sound panel                               |
//+------------------------------------------------------------------+
void ChangeColorsOnSoundPanel()
  {
   color clr=clrNONE; // Button color
//--- Iterate over all buttons in a loop and change their color
   for(int i=0; i<ARRAY_SIZE; i++)
     {
      //--- Get the new color
      clr=GetRandomColor();
      //--- Set the border color
      ObjectSetInteger(0,sound_names[i],OBJPROP_BGCOLOR,clr);
      //--- Set the background color
      ObjectSetInteger(0,sound_names[i],OBJPROP_BORDER_COLOR,clr);
      //--- Unclicked button
      ObjectSetInteger(0,sound_names[i],OBJPROP_STATE,false);
      //--- Refresh the chart
      ChartRedraw(0);
      //--- Wait for 20 ms (lag)
      Sleep(20);
     }
  }
//+------------------------------------------------------------------+
//| Creating the Button object                                       |
//+------------------------------------------------------------------+
void CreateButton(long              chart_id,         // chart id
                  int               sub_window,       // window number
                  string            name,             // object name
                  string            text,             // displayed name
                  ENUM_ANCHOR_POINT anchor,           // anchor point
                  ENUM_BASE_CORNER  corner,           // chart corner
                  string            font_name,        // font
                  int               font_size,        // font size
                  color             font_color,       // font color
                  color             background_color, // background color
                  color             border_color,     // border color
                  int               x_size,           // width
                  int               y_size,           // height
                  int               x_distance,       // X-coordinate
                  int               y_distance,       // Y-coordinate
                  long              z_order)          // Z-order
  {
//--- Creating an object
   if(ObjectCreate(chart_id,name,OBJ_BUTTON,sub_window,0,0))
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);                  // setting name
      ObjectSetString(chart_id,name,OBJPROP_FONT,font_name);             // setting font
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,font_color);          // setting font color
      ObjectSetInteger(chart_id,name,OBJPROP_BGCOLOR,background_color);  // setting background color
      ObjectSetInteger(chart_id,name,OBJPROP_BORDER_COLOR,border_color); // setting border color
      ObjectSetInteger(chart_id,name,OBJPROP_ANCHOR,anchor);             // setting anchor point
      ObjectSetInteger(chart_id,name,OBJPROP_CORNER,corner);             // setting chart corner
      ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,font_size);        // setting font size
      ObjectSetInteger(chart_id,name,OBJPROP_XSIZE,x_size);              // setting width X
      ObjectSetInteger(chart_id,name,OBJPROP_YSIZE,y_size);              // setting height Y
      ObjectSetInteger(chart_id,name,OBJPROP_XDISTANCE,x_distance);      // setting X-coordinate
      ObjectSetInteger(chart_id,name,OBJPROP_YDISTANCE,y_distance);      // setting Y-coordinate
      ObjectSetInteger(chart_id,name,OBJPROP_SELECTABLE,false);          // cannot select the object if FALSE
      ObjectSetInteger(chart_id,name,OBJPROP_STATE,false);               // button state (clicked/unclicked)
      ObjectSetInteger(chart_id,name,OBJPROP_ZORDER,z_order);            // higher/lower Z-order
      ObjectSetString(chart_id,name,OBJPROP_TOOLTIP,"\n");               // no tooltip if "\n"
     }
  }
//+------------------------------------------------------------------+
//| Returning sound file location by the object name                 |
//+------------------------------------------------------------------+
string GetSoundPath(string object_name)
  {
//--- Iterate over all sound panel objects in a loop
   for(int i=0; i<ARRAY_SIZE; i++)
     {
      //--- If the name of the object clicked in the chart
      //    matches one of those available on the panel, return the file location
      if(object_name==sound_names[i])
         return(sound_paths[i]);
     }
//---
   return("");
  }
//+------------------------------------------------------------------+
//| Deleting the info panel                                          |
//+------------------------------------------------------------------+
void DeleteSoundPanel()
  {
//--- Delete position properties and their values
   for(int i=0; i<ARRAY_SIZE; i++)
      DeleteObjectByName(sound_names[i]);
//--- Redraw the chart
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| Deleting objects by name                                         |
//+------------------------------------------------------------------+
void DeleteObjectByName(string name)
  {
//--- If the object is found
   if(ObjectFind(ChartID(),name)>=0)
     {
      //--- If an error occurred when deleting, print the relevant message
      if(!ObjectDelete(ChartID(),name))
         Print("Error ("+IntegerToString(GetLastError())+") when deleting the object!");
     }
  }
//+------------------------------------------------------------------+
//| Returning a random color                                         |
//+------------------------------------------------------------------+
color GetRandomColor()
  {
//--- initialize random number generator
//   MathSrand(GetTickCount());
//--- Select a random color from 0 to 25
   switch(MathRand()%26)
     {
      case 0  : return(clrOrange);           break;
      case 1  : return(clrGold);             break;
      case 2  : return(clrChocolate);        break;
      case 3  : return(clrChartreuse);       break;
      case 4  : return(clrLime);             break;
      case 5  : return(clrSpringGreen);      break;
      case 6  : return(clrMediumBlue);       break;
      case 7  : return(clrDeepSkyBlue);      break;
      case 8  : return(clrBlue);             break;
      case 9  : return(clrSeaGreen);         break;
      case 10 : return(clrRed);              break;
      case 11 : return(clrSlateGray);        break;
      case 12 : return(clrPeru);             break;
      case 13 : return(clrBlueViolet);       break;
      case 14 : return(clrIndianRed);        break;
      case 15 : return(clrMediumOrchid);     break;
      case 16 : return(clrCrimson);          break;
      case 17 : return(clrMediumAquamarine); break;
      case 18 : return(clrDarkGray);         break;
      case 19 : return(clrSandyBrown);       break;
      case 20 : return(clrMediumSlateBlue);  break;
      case 21 : return(clrTan);              break;
      case 22 : return(clrDarkSalmon);       break;
      case 23 : return(clrBurlyWood);        break;
      case 24 : return(clrHotPink);          break;
      case 25 : return(clrLightSteelBlue);   break;
      //---
      default : return(clrGold);
     }
//---
   return(clrGold);
  }
//+------------------------------------------------------------------+
