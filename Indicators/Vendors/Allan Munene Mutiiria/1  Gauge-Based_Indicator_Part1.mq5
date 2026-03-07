//+-----------------------------------------------------------------------+
//|                           1. Gauge-Based RSI Indicator Part1.mq5      |
//|                           Copyright 2025, Allan Munene Mutiiria.      |
//|                            https://www.mql5.com/en/users/29210372     |
//+-----------------------------------------------------------------------+
//| Creating Custom Indicators                                            |
//| Building a Gauge-Style RSI Display with Canvas and Needle Mechanics   |
//| https://www.mql5.com/en/articles/20632                                |
//+-----------------------------------------------------------------------+
#property copyright "Copyright 2025, Allan Munene Mutiiria."
#property link "https://t.me/Forex_Algo_Trader"
#property version "1.00"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots 1
#property indicator_type1 DRAW_LINE
#property indicator_color1 clrDodgerBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2
#property indicator_label1 "RSI"
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_level1 30
#property indicator_level2 70
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DOT

#include <Canvas\Canvas.mqh>

//+------------------------------------------------------------------+
//| Circle Structure                                                 |
//+------------------------------------------------------------------+
struct Struct_Circle {                     // Define circle structure
   int centerX;                            // Store center X coordinate
   int centerY;                            // Store center Y coordinate
   int radius;                             // Store radius
   color clr;                              // Store color
   bool display;                           // Store display flag
};

//+------------------------------------------------------------------+
//| Arc Structure                                                    |
//+------------------------------------------------------------------+
struct Struct_Arc {                        // Define arc structure
   int centerX;                            // Store center X coordinate
   int centerY;                            // Store center Y coordinate
   int radius;                             // Store radius
   double startAngle;                      // Store start angle in radians
   double endAngle;                        // Store end angle in radians
   color clr;                              // Store color
   bool display;                           // Store display flag
};

//+------------------------------------------------------------------+
//| Line Structure                                                   |
//+------------------------------------------------------------------+
struct Struct_Line {                       // Define line structure
   int startX;                             // Store start X coordinate
   int startY;                             // Store start Y coordinate
   int endX;                               // Store end X coordinate
   int endY;                               // Store end Y coordinate
   color clr;                              // Store color
};

//+------------------------------------------------------------------+
//| Dot Structure                                                    |
//+------------------------------------------------------------------+
struct Struct_Dot {                        // Define dot structure
   int x;                                  // Store X coordinate
   int y;                                  // Store Y coordinate
   color clr;                              // Store color
};

//+------------------------------------------------------------------+
//| Pie/Sector Structure                                             |
//+------------------------------------------------------------------+
struct Struct_Pie {                        // Define pie structure
   int centerX;                            // Store center X coordinate
   int centerY;                            // Store center Y coordinate
   int radius;                             // Store radius
   int eraseRadius;                        // Store erase radius
   double startAngle;                      // Store start angle in radians
   double endAngle;                        // Store end angle in radians
   double eraseStartAngle;                 // Store erase start angle in radians
   double eraseEndAngle;                   // Store erase end angle in radians
   color clr;                              // Store color
   color eraseClr;                         // Store erase color
};

//+------------------------------------------------------------------+
//| Range Structure                                                  |
//+------------------------------------------------------------------+
struct Struct_Range {                      // Define range structure
   bool active;                            // Store active status
   double startValue;                      // Store start value
   double endValue;                        // Store end value
   color clr;                              // Store color
   Struct_Pie pie;                         // Store pie structure
};

//+------------------------------------------------------------------+
//| Case Structure                                                   |
//+------------------------------------------------------------------+
struct Struct_Case {                       // Define case structure
   bool display;                           // Store display flag
   Struct_Circle circle;                   // Store circle structure
};

//+------------------------------------------------------------------+
//| Scale Marks Structure                                            |
//+------------------------------------------------------------------+
struct Struct_ScaleMarks {                 // Define scale marks structure
   double minValue;                        // Store minimum value
   double maxValue;                        // Store maximum value
   double valueRange;                      // Store value range
   bool forwardDirection;                  // Store forward direction flag
   int nullMarkPosition;                   // Store null mark position
   double nullMarkAngle;                   // Store null mark angle
   int decimalPlaces;                      // Store decimal places
   int majorTickLength;                    // Store major tick length
   int mediumTickLength;                   // Store medium tick length
   int minorTickLength;                    // Store minor tick length
   double minAngle;                        // Store minimum angle
   double maxAngle;                        // Store maximum angle
   double angleRange;                      // Store angle range
   double multiplier;                      // Store multiplier
   string gaugeName;                       // Store gauge name
   string currentValue;                    // Store current value
   string units;                           // Store units
   int tickFontSize;                       // Store tick font size
   string tickFontName;                    // Store tick font name
   uint tickFontFlags;                     // Store tick font flags
   int tickFontGap;                        // Store tick font gap
};

//+------------------------------------------------------------------+
//| Label Area Size Structure                                        |
//+------------------------------------------------------------------+
struct Struct_LabelAreaSize {              // Define label area size structure
   int height;                             // Store height
   int width;                              // Store width
   int diagonal;                           // Store diagonal
};

//+------------------------------------------------------------------+
//| Gauge Legend Parameters Structure                                |
//+------------------------------------------------------------------+
struct Struct_GaugeLegendParams {          // Define gauge legend parameters structure
   bool enable;                            // Store enable flag
   string text;                            // Store text
   uint radius;                            // Store radius
   double angle;                           // Store angle
   uint fontSize;                          // Store font size
   string fontName;                        // Store font name
   bool italic;                            // Store italic flag
   bool bold;                              // Store bold flag
   color textColor;                        // Store text color
};

//+------------------------------------------------------------------+
//| Gauge Legend String Structure                                    |
//+------------------------------------------------------------------+
struct Struct_GaugeLegendString {          // Define gauge legend string structure
   string text;                            // Store text
   int radius;                             // Store radius
   double angle;                           // Store angle
   int fontSize;                           // Store font size
   string fontName;                        // Store font name
   uint fontFlags;                         // Store font flags
   color textColor;                        // Store text color
   color backgroundColor;                  // Store background color
   uint decimalPlaces;                     // Store decimal places
   uint x;                                 // Store x coordinate
   uint y;                                 // Store y coordinate
   bool draw;                              // Store draw flag
};

//+------------------------------------------------------------------+
//| Gauge Label Structure                                            |
//+------------------------------------------------------------------+
struct Struct_GaugeLabel {                 // Define gauge label structure
   Struct_GaugeLegendString description;   // Store description
   Struct_GaugeLegendString units;         // Store units
   Struct_GaugeLegendString multiplier;    // Store multiplier
   Struct_GaugeLegendString value;         // Store value
};

//+------------------------------------------------------------------+
//| Scale Layer Structure                                            |
//+------------------------------------------------------------------+
struct Struct_ScaleLayer {                 // Define scale layer structure
   string objectName;                      // Store object name
   CCanvas obj_Canvas;                     // Store canvas object
   uchar transparency;                     // Store transparency
   color caseColor;                        // Store case color
   Struct_Case externalCase;               // Store external case
   int borderSize;                         // Store border size
   Struct_Case internalCase;               // Store internal case
   int borderGap;                          // Store border gap
   int externalLabelArea;                  // Store external label area
   int externalScaleGap;                   // Store external scale gap
   Struct_Arc scaleArc;                    // Store scale arc
   int internalScaleGap;                   // Store internal scale gap
   int internalLabelArea;                  // Store internal label area
   Struct_ScaleMarks scaleMarks;           // Store scale marks
   Struct_GaugeLabel gaugeLabel;           // Store gauge label
   Struct_Range ranges[4];                 // Store ranges array
};

//+------------------------------------------------------------------+
//| Needle Structure                                                 |
//+------------------------------------------------------------------+
struct Struct_Needle {                     // Define needle structure
   int tipRadius;                          // Store tip radius
   int tailRadius;                         // Store tail radius
   int x[4];                               // Store x coordinates array
   int y[4];                               // Store y coordinates array
   int fillStyle;                          // Store fill style
   color clr;                              // Store color
};

//+------------------------------------------------------------------+
//| Needle Layer Structure                                           |
//+------------------------------------------------------------------+
struct Struct_NeedleLayer {                // Define needle layer structure
   string objectName;                      // Store object name
   CCanvas obj_Canvas;                     // Store canvas object
   uchar transparency;                     // Store transparency
   Struct_Arc needleCenter;                // Store needle center
   Struct_Needle needle;                   // Store needle
};

//+------------------------------------------------------------------+
//| Range Parameters Structure                                       |
//+------------------------------------------------------------------+
struct Struct_RangeParams {                // Define range parameters structure
   bool enable;                            // Store enable flag
   double start;                           // Store start value
   double end;                             // Store end value
   color clr;                              // Store color
};

//+------------------------------------------------------------------+
//| Gauge Input Parameters Structure                                 |
//+------------------------------------------------------------------+
struct Struct_GaugeInputParams {           // Define gauge input parameters structure
   int xOffset;                            // Store x offset
   int yOffset;                            // Store y offset
   int anchorCorner;                       // Store anchor corner
   int relativeMode;                       // Store relative mode
   string relativeObjectName;              // Store relative object name
   int scaleAngleRange;                    // Store scale angle range
   int rotationAngle;                      // Store rotation angle
   color scaleColor;                       // Store scale color
   int scaleStyle;                         // Store scale style
   bool displayScaleArc;                   // Store display scale arc flag
   double minScaleValue;                   // Store minimum scale value
   double maxScaleValue;                   // Store maximum scale value
   int scaleMultiplier;                    // Store scale multiplier
   int tickStyle;                          // Store tick style
   int tickSize;                           // Store tick size
   double majorTickInterval;               // Store major tick interval
   int mediumTicksPerMajor;                // Store medium ticks per major
   int minorTicksPerInterval;              // Store minor ticks per interval
   int tickFontSize;                       // Store tick font size
   string tickFontName;                    // Store tick font name
   bool tickFontItalic;                    // Store tick font italic flag
   bool tickFontBold;                      // Store tick font bold flag
   color tickFontColor;                    // Store tick font color
   Struct_RangeParams ranges[4];           // Store ranges array
   color caseColor;                        // Store case color
   int borderStyle;                        // Store border style
   color borderColor;                      // Store border color
   int borderGapSize;                      // Store border gap size
   Struct_GaugeLegendParams description;   // Store description
   Struct_GaugeLegendParams units;         // Store units
   Struct_GaugeLegendParams multiplier;    // Store multiplier
   Struct_GaugeLegendParams value;         // Store value
   int needleCenterStyle;                  // Store needle center style
   color needleCenterColor;                // Store needle center color
   color needleColor;                      // Store needle color
   int needleFillStyle;                    // Store needle fill style
};

//+------------------------------------------------------------------+
//| Base Gauge Class                                                 |
//+------------------------------------------------------------------+
class CGaugeBase                           // Define base gauge class
{
private:
   int relativeX;                          //--- Store relative X
   int relativeY;                          //--- Store relative Y
   int centerX;                            //--- Store center X
   int centerY;                            //--- Store center Y
   double currentValue;                    //--- Store current value
   bool initializationComplete;            //--- Store initialization complete flag
   void Draw();                            //--- Declare draw method
   void CalculateNeedle();                 //--- Declare calculate needle method
   void RedrawNeedle(double value);        //--- Declare redraw needle method
   void CalculateAndDrawLegends();         //--- Declare calculate and draw legends method
   void CalculateAndDrawLegendString(Struct_GaugeLegendString &legendString); //--- Declare calculate and draw legend string method
   void RedrawScaleMarks(Struct_Case &internalCase, Struct_Arc &scaleArc, int borderGap); //--- Declare redraw scale marks method
   void CalculateRanges(int borderGap);    //--- Declare calculate ranges method
   bool IsValidRange(int index);           //--- Declare check valid range method
   void NormalizeRangeValues(double &minValue, double &maxValue, double val0, double val1); //--- Declare normalize range values method
   void CalculateRangePie(Struct_Range &range, int innerRadius, int radialGap, int outerRadius, double rangeStart, double rangeEnd, color rangeClr, color caseClr); //--- Declare calculate range pie method
   void DrawRanges();                      //--- Declare draw ranges method
   void DrawRange(Struct_Range &range);    //--- Declare draw range method
   void CalculateInnerOuterRadii(int &innerRadius, int &outerRadius, int baseRadius, int tickLength, int tickStyle); //--- Declare calculate inner outer radii method
   bool DrawTick(double angle, int length, Struct_Arc &scaleArc); //--- Declare draw tick method
   double CalculateAngleDelta(double angle1, double angle2, int direction); //--- Declare calculate angle delta method
   bool GetLabelAreaSize(Struct_LabelAreaSize &areaSize, Struct_GaugeLegendString &legendString); //--- Declare get label area size method
   bool EraseLegendString(Struct_GaugeLegendString &legendString, color eraseClr); //--- Declare erase legend string method
   bool RedrawValueDisplay(double value);  //--- Declare redraw value display method
   void SetLegendStringParams(Struct_GaugeLegendString &legendString, Struct_GaugeLegendParams &param, int minRadius, int radiusDelta); //--- Declare set legend string params method
   void CalculateCaseElements(Struct_Case &externalCase, Struct_Case &internalCase, int borderSize, int borderGap); //--- Declare calculate case elements method
   void DrawCaseElements(Struct_Case &externalCase, Struct_Case &internalCase); //--- Declare draw case elements method
protected:
   Struct_GaugeInputParams inputParams;    //--- Store input parameters
   Struct_ScaleLayer scaleLayer;           //--- Store scale layer
   Struct_NeedleLayer needleLayer;         //--- Store needle layer
   int m_radius;                           //--- Store radius
public:
   bool Create(string name, int x, int y, int size, string relativeObjectName, int relativeMode, int corner, bool background, uchar scaleTransparency, uchar needleTransparency); //--- Declare create method
   bool CalculateLocation();               //--- Declare calculate location method
   void Redraw();                          //--- Declare redraw method
   void NewValue(double value);            //--- Declare new value method
   void Delete();                          //--- Declare delete method
   void SetScaleParameters(int angleRange, int rotation, double minValue, double maxValue, int multiplier, int style, color scaleClr, bool displayArc = false); //--- Declare set scale parameters method
   void SetTickParameters(int style, int size, double majorInterval, int mediumPerMajor, int minorPerInterval); //--- Declare set tick parameters method
   void SetTickLabelFont(int fontSize, string fontName, bool italic, bool bold, color fontClr = clrBlack); //--- Declare set tick label font method
   void SetCaseParameters(color caseClr, int borderStyle, color borderClr, int borderGapSize); //--- Declare set case parameters method
   void SetLegendParameters(int legendType, bool enable, string text, int radius, double angle, uint fontSize, string fontName, bool italic, bool bold, color textClr = clrDarkGray); //--- Declare set legend parameters method
   void SetLegendParam(Struct_GaugeLegendParams &legendParam, bool enable, string text, int radius, double angle, uint fontSize, string fontName, bool italic, bool bold, color textClr = clrDarkGray); //--- Declare set legend param method
   void SetRangeParameters(int index, bool enable, double start, double end, color rangeClr); //--- Declare set range parameters method
   void SetNeedleParameters(int centerStyle, color centerClr, color needleClr, int fillStyle); //--- Declare set needle parameters method
};

//+------------------------------------------------------------------+
//| Create Gauge                                                     |
//+------------------------------------------------------------------+
bool CGaugeBase::Create(string name, int x, int y, int size, string relativeObjectName, int relativeMode, int corner, bool background, uchar scaleTransparency, uchar needleTransparency) {
   initializationComplete = false;         //--- Set initialization complete flag to false
   m_radius = size / 2;                    //--- Calculate radius
   inputParams.xOffset = x;                //--- Set x offset
   inputParams.yOffset = y;                //--- Set y offset
   inputParams.anchorCorner = corner;      //--- Set anchor corner
   inputParams.relativeMode = relativeMode;//--- Set relative mode
   inputParams.relativeObjectName = relativeObjectName; //--- Set relative object name
   if(!CalculateLocation())                //--- Check location calculation
      return false;                        //--- Return false if failed
   int canvasWidthHeight = (m_radius + 5) * 2; //--- Calculate canvas size
   scaleLayer.objectName = name + "_s";    //--- Set scale layer object name
   ObjectDelete(0, scaleLayer.objectName); //--- Delete scale layer object
   if(!scaleLayer.obj_Canvas.CreateBitmapLabel(scaleLayer.objectName, centerX, centerY, canvasWidthHeight, canvasWidthHeight, COLOR_FORMAT_ARGB_NORMALIZE)) //--- Create scale canvas
      return false;                        //--- Return false if failed
   ObjectSetInteger(0, scaleLayer.objectName, OBJPROP_CORNER, inputParams.anchorCorner); //--- Set corner property
   ObjectSetInteger(0, scaleLayer.objectName, OBJPROP_ANCHOR, ANCHOR_CENTER); //--- Set anchor property
   ObjectSetInteger(0, scaleLayer.objectName, OBJPROP_BACK, background); //--- Set back property
   needleLayer.objectName = name + "_n";   //--- Set needle layer object name
   ObjectDelete(0, needleLayer.objectName);//--- Delete needle layer object
   if(!needleLayer.obj_Canvas.CreateBitmapLabel(needleLayer.objectName, centerX, centerY, canvasWidthHeight, canvasWidthHeight, COLOR_FORMAT_ARGB_NORMALIZE)) //--- Create needle canvas
      return false;                        //--- Return false if failed
   ObjectSetInteger(0, needleLayer.objectName, OBJPROP_CORNER, inputParams.anchorCorner); //--- Set corner property
   ObjectSetInteger(0, needleLayer.objectName, OBJPROP_ANCHOR, ANCHOR_CENTER); //--- Set anchor property
   ObjectSetInteger(0, needleLayer.objectName, OBJPROP_BACK, background); //--- Set back property
   scaleLayer.transparency = 255 - scaleTransparency; //--- Set scale transparency
   needleLayer.transparency = 255 - needleTransparency; //--- Set needle transparency
   return true;                            //--- Return true
}

//+------------------------------------------------------------------+
//| Calculate Gauge Center Location                                  |
//+------------------------------------------------------------------+
bool CGaugeBase::CalculateLocation() {
   bool locationChanged = false;           //--- Initialize location changed flag
   int cX = m_radius;                      //--- Set initial X
   int cY = m_radius;                      //--- Set initial Y
   cX += inputParams.xOffset;              //--- Add X offset
   cY += inputParams.yOffset;              //--- Add Y offset
   if(centerX != cX || centerY != cY) {    //--- Check if position changed
      centerX = cX;                        //--- Update center X
      centerY = cY;                        //--- Update center Y
      locationChanged = true;              //--- Set changed flag
   }
   return locationChanged;                 //--- Return changed flag
}

//+------------------------------------------------------------------+
//| Set Scale Parameters                                             |
//+------------------------------------------------------------------+
void CGaugeBase::SetScaleParameters(int angleRange, int rotation, double minValue, double maxValue, int multiplier, int style, color scaleClr, bool displayArc) {
   inputParams.scaleAngleRange = angleRange; //--- Set scale angle range
   inputParams.rotationAngle = rotation;   //--- Set rotation angle
   inputParams.minScaleValue = minValue;   //--- Set minimum scale value
   inputParams.maxScaleValue = maxValue;   //--- Set maximum scale value
   inputParams.scaleMultiplier = multiplier; //--- Set scale multiplier
   inputParams.scaleStyle = style;         //--- Set scale style
   inputParams.scaleColor = scaleClr;      //--- Set scale color
   inputParams.displayScaleArc = displayArc; //--- Set display scale arc flag
}

//+------------------------------------------------------------------+
//| Set Tick Parameters                                              |
//+------------------------------------------------------------------+
void CGaugeBase::SetTickParameters(int style, int size, double majorInterval, int mediumPerMajor, int minorPerInterval) {
   inputParams.tickStyle = style;          //--- Set tick style
   inputParams.tickSize = size;            //--- Set tick size
   inputParams.majorTickInterval = majorInterval; //--- Set major tick interval
   inputParams.mediumTicksPerMajor = mediumPerMajor; //--- Set medium ticks per major
   inputParams.minorTicksPerInterval = minorPerInterval; //--- Set minor ticks per interval
}

//+------------------------------------------------------------------+
//| Set Tick Label Font                                              |
//+------------------------------------------------------------------+
void CGaugeBase::SetTickLabelFont(int fontSize, string fontName, bool italic, bool bold, color fontClr) {
   inputParams.tickFontSize = fontSize;    //--- Set tick font size
   inputParams.tickFontName = fontName;    //--- Set tick font name
   inputParams.tickFontItalic = italic;    //--- Set tick font italic flag
   inputParams.tickFontBold = bold;        //--- Set tick font bold flag
   inputParams.tickFontColor = fontClr;    //--- Set tick font color
}

//+------------------------------------------------------------------+
//| Set Case Parameters                                              |
//+------------------------------------------------------------------+
void CGaugeBase::SetCaseParameters(color caseClr, int borderStyle, color borderClr, int borderGapSize) {
   inputParams.caseColor = caseClr;        //--- Set case color
   inputParams.borderStyle = borderStyle;  //--- Set border style
   inputParams.borderColor = borderClr;    //--- Set border color
   inputParams.borderGapSize = borderGapSize; //--- Set border gap size
}

//+------------------------------------------------------------------+
//| Set Legend Parameters                                            |
//+------------------------------------------------------------------+
void CGaugeBase::SetLegendParameters(int legendType, bool enable, string text, int radius, double angle, uint fontSize, string fontName, bool italic, bool bold, color textClr) {
   switch(legendType) {                    //--- Switch on legend type
   case 0:                                 //--- Handle description
      SetLegendParam(inputParams.description, enable, text, radius, angle, fontSize, fontName, italic, bold, textClr); //--- Set description param
      break;                               //--- Break
   case 1:                                 //--- Handle units
      SetLegendParam(inputParams.units, enable, text, radius, angle, fontSize, fontName, italic, bold, textClr); //--- Set units param
      break;                               //--- Break
   case 2:                                 //--- Handle multiplier
      SetLegendParam(inputParams.multiplier, enable, text, radius, angle, fontSize, fontName, italic, bold, textClr); //--- Set multiplier param
      break;                               //--- Break
   case 3:                                 //--- Handle value
      SetLegendParam(inputParams.value, enable, text, radius, angle, fontSize, fontName, italic, bold, textClr); //--- Set value param
      break;                               //--- Break
   }
}

//+------------------------------------------------------------------+
//| Set Individual Legend Parameter                                  |
//+------------------------------------------------------------------+
void CGaugeBase::SetLegendParam(Struct_GaugeLegendParams &legendParam, bool enable, string text, int radius, double angle, uint fontSize, string fontName, bool italic, bool bold, color textClr) {
   legendParam.enable = enable;            //--- Set enable flag
   legendParam.text = text;                //--- Set text
   legendParam.radius = radius;            //--- Set radius
   legendParam.angle = angle;              //--- Set angle
   legendParam.fontSize = fontSize;        //--- Set font size
   legendParam.fontName = fontName;        //--- Set font name
   legendParam.italic = italic;            //--- Set italic flag
   legendParam.bold = bold;                //--- Set bold flag
   legendParam.textColor = textClr;        //--- Set text color
}

//+------------------------------------------------------------------+
//| Set Range Parameters                                             |
//+------------------------------------------------------------------+
void CGaugeBase::SetRangeParameters(int index, bool enable, double start, double end, color rangeClr) {
   if(index >= 0 && index < 4) {           //--- Check index range
      inputParams.ranges[index].enable = enable; //--- Set enable flag
      inputParams.ranges[index].start = start; //--- Set start
      inputParams.ranges[index].end = end; //--- Set end
      inputParams.ranges[index].clr = rangeClr; //--- Set color
   }
}

//+------------------------------------------------------------------+
//| Set Needle Parameters                                            |
//+------------------------------------------------------------------+
void CGaugeBase::SetNeedleParameters(int centerStyle, color centerClr, color needleClr, int fillStyle) {
   inputParams.needleCenterStyle = centerStyle; //--- Set needle center style
   inputParams.needleCenterColor = centerClr; //--- Set needle center color
   inputParams.needleColor = needleClr;    //--- Set needle color
   inputParams.needleFillStyle = fillStyle;//--- Set needle fill style
}

//+------------------------------------------------------------------+
//| Redraw Gauge                                                     |
//+------------------------------------------------------------------+
void CGaugeBase::Redraw() {
   Draw();                                 //--- Call draw
   initializationComplete = true;          //--- Set initialization complete
}

//+------------------------------------------------------------------+
//| Draw Scale and Needle                                            |
//+------------------------------------------------------------------+
void CGaugeBase::Draw() {
   double diameter = m_radius * 2.0;       //--- Calculate diameter
   scaleLayer.scaleMarks.majorTickLength = (int)((diameter * 10.0) / 100.0); //--- Set major tick length
   scaleLayer.scaleMarks.mediumTickLength = (int)((diameter * 7.5) / 100.0); //--- Set medium tick length
   scaleLayer.scaleMarks.minorTickLength = (int)((diameter * 5.0) / 100.0); //--- Set minor tick length
   scaleLayer.scaleMarks.tickFontName = inputParams.tickFontName; //--- Set tick font name
   scaleLayer.scaleMarks.tickFontFlags = 0; //--- Initialize tick font flags
   if(inputParams.tickFontItalic)          //--- Check italic flag
      scaleLayer.scaleMarks.tickFontFlags |= FONT_ITALIC; //--- Add italic flag
   if(inputParams.tickFontBold)            //--- Check bold flag
      scaleLayer.scaleMarks.tickFontFlags |= FW_BOLD; //--- Add bold flag
   scaleLayer.scaleMarks.tickFontSize = (int)((diameter * 6.5) / 100.0); //--- Set tick font size
   scaleLayer.scaleMarks.tickFontGap = GetTickFontGap(scaleLayer.scaleMarks, 3); //--- Set tick font gap
   scaleLayer.externalLabelArea = 0;       //--- Set external label area
   scaleLayer.internalLabelArea = 0;       //--- Set internal label area
   GetTickLabelAreaSize(scaleLayer.internalLabelArea, scaleLayer.scaleMarks, 3); //--- Get tick label area size
   scaleLayer.borderSize = (int)((diameter * 2) / 100.0); //--- Set border size
   scaleLayer.borderGap = (int)((diameter * 3.0) / 100.0); //--- Set border gap
   scaleLayer.externalScaleGap = 0;        //--- Set external scale gap
   scaleLayer.internalScaleGap = scaleLayer.scaleMarks.majorTickLength; //--- Set internal scale gap
   if(inputParams.scaleAngleRange < 30)    //--- Check min angle range
      inputParams.scaleAngleRange = 30;    //--- Set min angle range
   if(inputParams.scaleAngleRange > 320)   //--- Check max angle range
      inputParams.scaleAngleRange = 320;   //--- Set max angle range
   int halfAngleRange = inputParams.scaleAngleRange / 2; //--- Calculate half angle range
   int startAngle = 90 + halfAngleRange + inputParams.rotationAngle; //--- Calculate start angle
   int endAngle = 90 - halfAngleRange + inputParams.rotationAngle; //--- Calculate end angle
   scaleLayer.scaleArc.centerX = m_radius + 5; //--- Set scale arc center X
   scaleLayer.scaleArc.centerY = m_radius + 5; //--- Set scale arc center Y
   scaleLayer.scaleArc.radius = m_radius - (scaleLayer.borderSize + scaleLayer.borderGap + scaleLayer.externalLabelArea + scaleLayer.externalScaleGap); //--- Set scale arc radius
   scaleLayer.scaleArc.startAngle = NormalizeRadians(DegreesToRadians(endAngle)); //--- Set start angle
   scaleLayer.scaleArc.endAngle = NormalizeRadians(DegreesToRadians(startAngle) - 0.0001); //--- Set end angle
   scaleLayer.scaleArc.clr = inputParams.scaleColor; //--- Set scale arc color
   needleLayer.needleCenter.radius = (int)((diameter * 5) / 100.0); //--- Set needle center radius
   needleLayer.needleCenter.display = true; //--- Set display flag
   needleLayer.needleCenter.centerX = scaleLayer.scaleArc.centerX; //--- Set needle center X
   needleLayer.needleCenter.centerY = scaleLayer.scaleArc.centerY; //--- Set needle center Y
   needleLayer.needleCenter.clr = inputParams.needleCenterColor; //--- Set needle center color
   int maxLegendRadius = m_radius - (scaleLayer.borderSize + scaleLayer.borderGap); //--- Calculate max legend radius
   int minLegendRadius = needleLayer.needleCenter.radius; //--- Set min legend radius
   int legendRadiusDelta = maxLegendRadius - minLegendRadius; //--- Calculate legend radius delta
   SetLegendStringParams(scaleLayer.gaugeLabel.description, inputParams.description, minLegendRadius, legendRadiusDelta); //--- Set description params
   SetLegendStringParams(scaleLayer.gaugeLabel.units, inputParams.units, minLegendRadius, legendRadiusDelta); //--- Set units params
   SetLegendStringParams(scaleLayer.gaugeLabel.multiplier, inputParams.multiplier, minLegendRadius, legendRadiusDelta); //--- Set multiplier params
   SetLegendStringParams(scaleLayer.gaugeLabel.value, inputParams.value, minLegendRadius, legendRadiusDelta); //--- Set value params
   CalculateCaseElements(scaleLayer.externalCase, scaleLayer.internalCase, scaleLayer.borderSize, scaleLayer.borderGap); //--- Calculate case elements
   scaleLayer.caseColor = inputParams.caseColor; //--- Set case color
   DrawCaseElements(scaleLayer.externalCase, scaleLayer.internalCase); //--- Draw case elements
   if(inputParams.displayScaleArc)         //--- Check display scale arc
      scaleLayer.obj_Canvas.Arc(scaleLayer.scaleArc.centerX, scaleLayer.scaleArc.centerY, scaleLayer.scaleArc.radius, scaleLayer.scaleArc.radius, scaleLayer.scaleArc.startAngle, scaleLayer.scaleArc.endAngle, ColorToARGB(scaleLayer.scaleArc.clr, scaleLayer.transparency)); //--- Draw scale arc
   RedrawScaleMarks(scaleLayer.internalCase, scaleLayer.scaleArc, scaleLayer.borderGap); //--- Redraw scale marks
   CalculateAndDrawLegends();              //--- Calculate and draw legends
   CalculateNeedle();                      //--- Calculate needle
   scaleLayer.obj_Canvas.Update(true);     //--- Update scale canvas
   needleLayer.obj_Canvas.Update(true);    //--- Update needle canvas
}

//+------------------------------------------------------------------+
//| Calculate Case Elements                                          |
//+------------------------------------------------------------------+
void CGaugeBase::CalculateCaseElements(Struct_Case &externalCase, Struct_Case &internalCase, int borderSize, int borderGap) {
   if(borderSize > 0) {                    //--- Check border size
      externalCase.circle.centerX = scaleLayer.scaleArc.centerX; //--- Set external center X
      externalCase.circle.centerY = scaleLayer.scaleArc.centerY; //--- Set external center Y
      externalCase.circle.radius = m_radius; //--- Set external radius
      externalCase.circle.clr = inputParams.borderColor; //--- Set external color
      externalCase.display = true;         //--- Set display flag
   } else                                  //--- Handle no border
      externalCase.display = false;        //--- Set display flag false
   internalCase.circle.centerX = scaleLayer.scaleArc.centerX; //--- Set internal center X
   internalCase.circle.centerY = scaleLayer.scaleArc.centerY; //--- Set internal center Y
   internalCase.circle.radius = m_radius - borderSize; //--- Set internal radius
   internalCase.circle.clr = inputParams.caseColor; //--- Set internal color
   internalCase.display = true;            //--- Set display flag
}

//+------------------------------------------------------------------+
//| Draw Case Elements                                               |
//+------------------------------------------------------------------+
void CGaugeBase::DrawCaseElements(Struct_Case &externalCase, Struct_Case &internalCase) {
   if(externalCase.display)                //--- Check external display
      scaleLayer.obj_Canvas.FillCircle(externalCase.circle.centerX, externalCase.circle.centerY, externalCase.circle.radius, ColorToARGB(externalCase.circle.clr, scaleLayer.transparency)); //--- Fill external circle
   if(internalCase.display)                //--- Check internal display
      scaleLayer.obj_Canvas.FillCircle(internalCase.circle.centerX, internalCase.circle.centerY, internalCase.circle.radius, ColorToARGB(internalCase.circle.clr, scaleLayer.transparency)); //--- Fill internal circle
}

//+------------------------------------------------------------------+
//| Calculate Needle                                                 |
//+------------------------------------------------------------------+
void CGaugeBase::CalculateNeedle() {
   int innerRadius = 0, outerRadius = 0;   //--- Initialize radii
   if(inputParams.minorTicksPerInterval > 0) //--- Check minor ticks
      CalculateInnerOuterRadii(innerRadius, outerRadius, scaleLayer.scaleArc.radius, scaleLayer.scaleMarks.minorTickLength, inputParams.tickStyle); //--- Calculate for minor
   else if(inputParams.mediumTicksPerMajor > 0) //--- Check medium ticks
      CalculateInnerOuterRadii(innerRadius, outerRadius, scaleLayer.scaleArc.radius, scaleLayer.scaleMarks.mediumTickLength, inputParams.tickStyle); //--- Calculate for medium
   else if(inputParams.majorTickInterval > 0) //--- Check major ticks
      CalculateInnerOuterRadii(innerRadius, outerRadius, scaleLayer.scaleArc.radius, scaleLayer.scaleMarks.majorTickLength, inputParams.tickStyle); //--- Calculate for major
   needleLayer.needle.tipRadius = outerRadius; //--- Set tip radius
   needleLayer.needle.clr = inputParams.needleColor; //--- Set needle color
   needleLayer.needle.fillStyle = inputParams.needleFillStyle; //--- Set fill style
   needleLayer.needle.tailRadius = needleLayer.needleCenter.radius * 2; //--- Set tail radius
}

//+------------------------------------------------------------------+
//| Redraw Needle                                                    |
//+------------------------------------------------------------------+
void CGaugeBase::RedrawNeedle(double value) {
   needleLayer.obj_Canvas.Erase();         //--- Erase canvas
   double normalizedValue = 0;             //--- Initialize normalized value
   if(scaleLayer.scaleMarks.minValue < scaleLayer.scaleMarks.maxValue) { //--- Check direct order
      if(value < scaleLayer.scaleMarks.minValue) //--- Check min value
         value = scaleLayer.scaleMarks.minValue; //--- Clamp to min
      if(value > scaleLayer.scaleMarks.maxValue) //--- Check max value
         value = scaleLayer.scaleMarks.maxValue; //--- Clamp to max
      normalizedValue = value - scaleLayer.scaleMarks.minValue; //--- Normalize
   } else {                                //--- Handle inverse order
      if(value > scaleLayer.scaleMarks.minValue) //--- Check min value
         value = scaleLayer.scaleMarks.minValue; //--- Clamp to min
      if(value < scaleLayer.scaleMarks.maxValue) //--- Check max value
         value = scaleLayer.scaleMarks.maxValue; //--- Clamp to max
      normalizedValue = scaleLayer.scaleMarks.minValue - value; //--- Normalize
   }
   if(scaleLayer.scaleMarks.valueRange == 0) //--- Check value range
      return;                              //--- Return if zero
   double currentAngle = NormalizeRadians(scaleLayer.scaleMarks.minAngle - ((normalizedValue * scaleLayer.scaleMarks.angleRange) / scaleLayer.scaleMarks.valueRange)); //--- Calculate current angle
   needleLayer.needle.x[0] = (int)(scaleLayer.scaleArc.centerX - needleLayer.needle.tipRadius * MathCos(M_PI - currentAngle)); //--- Set x0
   needleLayer.needle.y[0] = (int)(scaleLayer.scaleArc.centerY - needleLayer.needle.tipRadius * MathSin(M_PI - currentAngle)); //--- Set y0
   double bufferX[3], bufferY[3];          //--- Declare buffers
   bufferX[0] = scaleLayer.scaleArc.centerX - needleLayer.needle.tipRadius * MathCos(M_PI - currentAngle); //--- Set bufferX0
   bufferY[0] = scaleLayer.scaleArc.centerY - needleLayer.needle.tipRadius * MathSin(M_PI - currentAngle); //--- Set bufferY0
   double tailX = scaleLayer.scaleArc.centerX - needleLayer.needle.tailRadius * MathCos(2 * M_PI - currentAngle); //--- Calculate tail X
   double tailY = scaleLayer.scaleArc.centerY - needleLayer.needle.tailRadius * MathSin(2 * M_PI - currentAngle); //--- Calculate tail Y
   int r = (int)(needleLayer.needle.tailRadius / 3.0); //--- Calculate r
   bufferX[1] = tailX - r * MathCos(0.5 * M_PI - currentAngle); //--- Set bufferX1
   bufferY[1] = tailY - r * MathSin(0.5 * M_PI - currentAngle); //--- Set bufferY1
   bufferX[2] = tailX - r * MathCos(1.5 * M_PI - currentAngle); //--- Set bufferX2
   bufferY[2] = tailY - r * MathSin(1.5 * M_PI - currentAngle); //--- Set bufferY2
   uint clr = ColorToARGB(needleLayer.needle.clr, needleLayer.transparency); //--- Get color
   needleLayer.obj_Canvas.LineAA((int)bufferX[0], (int)bufferY[0], (int)bufferX[1], (int)bufferY[1], clr); //--- Draw line AA 0-1
   needleLayer.obj_Canvas.LineAA((int)bufferX[1], (int)bufferY[1], (int)bufferX[2], (int)bufferY[2], clr); //--- Draw line AA 1-2
   needleLayer.obj_Canvas.LineAA((int)bufferX[2], (int)bufferY[2], (int)bufferX[0], (int)bufferY[0], clr); //--- Draw line AA 2-0
   double centroidX = (bufferX[0] + bufferX[1] + bufferX[2]) / 3.0; //--- Calculate centroid X
   double centroidY = (bufferY[0] + bufferY[1] + bufferY[2]) / 3.0; //--- Calculate centroid Y
   needleLayer.obj_Canvas.Fill((int)centroidX, (int)centroidY, clr); //--- Fill
   needleLayer.obj_Canvas.LineAA(scaleLayer.scaleArc.centerX, scaleLayer.scaleArc.centerY, (int)bufferX[0], (int)bufferY[0], clr); //--- Draw line AA center to 0
   if(needleLayer.needleCenter.display)    //--- Check display
      needleLayer.obj_Canvas.FillCircle(needleLayer.needleCenter.centerX, needleLayer.needleCenter.centerY, needleLayer.needleCenter.radius, ColorToARGB(needleLayer.needleCenter.clr, needleLayer.transparency)); //--- Fill needle center
}

//+------------------------------------------------------------------+
//| Calculate and Draw Legends                                       |
//+------------------------------------------------------------------+
void CGaugeBase::CalculateAndDrawLegends() {
   if(inputParams.description.enable)      //--- Check description enable
      CalculateAndDrawLegendString(scaleLayer.gaugeLabel.description); //--- Calculate and draw description
   if(inputParams.units.enable)            //--- Check units enable
      CalculateAndDrawLegendString(scaleLayer.gaugeLabel.units); //--- Calculate and draw units
   if(inputParams.multiplier.enable) {     //--- Check multiplier enable
      scaleLayer.gaugeLabel.multiplier.text = scaleMultiplierStrings[inputParams.scaleMultiplier]; //--- Set multiplier text
      CalculateAndDrawLegendString(scaleLayer.gaugeLabel.multiplier); //--- Calculate and draw multiplier
   }
   if(inputParams.value.enable) {          //--- Check value enable
      scaleLayer.gaugeLabel.value.decimalPlaces = 0; //--- Set decimal places
      if(inputParams.value.text != "" ) {  //--- Check text
         int digits = (int)StringToInteger(inputParams.value.text); //--- Get digits
         if(digits >= 1 && digits <= 8)    //--- Check digits range
            scaleLayer.gaugeLabel.value.decimalPlaces = (uint)digits; //--- Set decimal places
      }
      scaleLayer.gaugeLabel.value.text = " "; //--- Set text
      CalculateAndDrawLegendString(scaleLayer.gaugeLabel.value); //--- Calculate and draw value
   }
}

//+------------------------------------------------------------------+
//| Calculate and Draw Legend String                                 |
//+------------------------------------------------------------------+
void CGaugeBase::CalculateAndDrawLegendString(Struct_GaugeLegendString &legendString) {
   if(legendString.text != "") {           //--- Check text
      legendString.draw = true;            //--- Set draw flag
      scaleLayer.obj_Canvas.FontSet(legendString.fontName, legendString.fontSize, legendString.fontFlags, 0); //--- Set font
      double normalizedAngle = NormalizeRadians(DegreesToRadians(legendString.angle + 90)); //--- Normalize angle
      legendString.x = (uint)(scaleLayer.scaleArc.centerX - legendString.radius * MathCos(M_PI - normalizedAngle)); //--- Set x
      legendString.y = (uint)(scaleLayer.scaleArc.centerY - legendString.radius * MathSin(M_PI - normalizedAngle)); //--- Set y
      legendString.backgroundColor = scaleLayer.caseColor; //--- Set background color
      scaleLayer.obj_Canvas.TextOut(legendString.x, legendString.y, legendString.text, ColorToARGB(legendString.textColor, scaleLayer.transparency), TA_CENTER | TA_VCENTER); //--- Draw text
   }
}

//+------------------------------------------------------------------+
//| Redraw Scale Marks                                               |
//+------------------------------------------------------------------+
void CGaugeBase::RedrawScaleMarks(Struct_Case &internalCase, Struct_Arc &scaleArc, int borderGap) {
   int majorIndex, mediumIndex, minorIndex;//--- Declare indices
   double angle = 0, mediumAngle = 0, minorAngle = 0; //--- Declare angles
   scaleLayer.scaleMarks.multiplier = scaleMultipliers[inputParams.scaleMultiplier]; //--- Set multiplier
   if(scaleLayer.scaleMarks.multiplier <= 0) //--- Check multiplier
      scaleLayer.scaleMarks.multiplier = 1.0; //--- Set default multiplier
   scaleLayer.scaleMarks.minValue = inputParams.minScaleValue; //--- Set min value
   scaleLayer.scaleMarks.maxValue = inputParams.maxScaleValue; //--- Set max value
   scaleLayer.scaleMarks.decimalPlaces = 0; //--- Set decimal places
   if(scaleLayer.scaleMarks.maxValue > scaleLayer.scaleMarks.minValue) { //--- Check direct order
      scaleLayer.scaleMarks.forwardDirection = true; //--- Set forward direction
      scaleLayer.scaleMarks.valueRange = scaleLayer.scaleMarks.maxValue - scaleLayer.scaleMarks.minValue; //--- Set value range
   } else {                                //--- Handle inverse order
      scaleLayer.scaleMarks.forwardDirection = false; //--- Set forward direction false
      scaleLayer.scaleMarks.valueRange = scaleLayer.scaleMarks.minValue - scaleLayer.scaleMarks.maxValue; //--- Set value range
   }
   scaleLayer.scaleMarks.nullMarkPosition = 1; //--- Set null mark position
   scaleLayer.scaleMarks.minAngle = scaleArc.endAngle; //--- Set min angle
   scaleLayer.scaleMarks.maxAngle = scaleArc.startAngle; //--- Set max angle
   if(scaleArc.endAngle > scaleArc.startAngle) //--- Check angles
      scaleLayer.scaleMarks.angleRange = NormalizeRadians(scaleArc.endAngle - scaleArc.startAngle); //--- Set angle range
   else                                    //--- Handle wrap around
      scaleLayer.scaleMarks.angleRange = NormalizeRadians(scaleArc.endAngle + (2 * M_PI - scaleArc.startAngle)); //--- Set angle range
   int leftMarkCount = 0;                  //--- Initialize left mark count
   int rightMarkCount = 0;                 //--- Initialize right mark count
   double markBuffer[361][2];              //--- Declare mark buffer
   int bufferCenterIndex = (int)(361 / 2); //--- Set buffer center index
   double tempValue = 0;                   //--- Initialize temp value
   int sign = 0;                           //--- Initialize sign
   double multiplier = scaleMultipliers[inputParams.scaleMultiplier]; //--- Set multiplier
   markBuffer[bufferCenterIndex][0] = 0;   //--- Set zero value
   markBuffer[bufferCenterIndex][1] = scaleLayer.scaleMarks.minAngle; //--- Set zero angle
   tempValue = 0;                          //--- Reset temp value
   sign = scaleLayer.scaleMarks.forwardDirection ? 1 : -1; //--- Set sign
   for(majorIndex = 1; majorIndex < (int)(361 / 2); majorIndex++) { //--- Loop major indices
      tempValue = majorIndex * inputParams.majorTickInterval; //--- Calculate temp value
      if(tempValue <= scaleLayer.scaleMarks.valueRange) { //--- Check range
         markBuffer[bufferCenterIndex + majorIndex][0] = (majorIndex * inputParams.majorTickInterval * sign) / multiplier; //--- Set mark value
         markBuffer[bufferCenterIndex + majorIndex][1] = NormalizeRadians(scaleLayer.scaleMarks.minAngle - ((majorIndex * inputParams.majorTickInterval * scaleLayer.scaleMarks.angleRange) / scaleLayer.scaleMarks.valueRange)); //--- Set mark angle
         rightMarkCount++;                 //--- Increment right count
      } else                                  //--- Handle out of range
         break;                            //--- Break loop
   }
   double majorAngleStep, mediumAngleStep, minorAngleStep; //--- Declare angle steps
   majorAngleStep = (inputParams.majorTickInterval * scaleLayer.scaleMarks.angleRange) / scaleLayer.scaleMarks.valueRange; //--- Set major step
   mediumAngleStep = 0;                    //--- Initialize medium step
   if(inputParams.mediumTicksPerMajor != 0) //--- Check medium ticks
      mediumAngleStep = ((inputParams.majorTickInterval / (inputParams.mediumTicksPerMajor + 1)) * scaleLayer.scaleMarks.angleRange) / scaleLayer.scaleMarks.valueRange; //--- Set medium step
   minorAngleStep = 0;                     //--- Initialize minor step
   if(inputParams.minorTicksPerInterval != 0) { //--- Check minor ticks
      if(mediumAngleStep != 0)             //--- Check medium step
         minorAngleStep = (((inputParams.majorTickInterval / (inputParams.mediumTicksPerMajor + 1)) / (inputParams.minorTicksPerInterval + 1)) * scaleLayer.scaleMarks.angleRange) / scaleLayer.scaleMarks.valueRange; //--- Set minor step with medium
      else                                 //--- Handle no medium
         minorAngleStep = ((inputParams.majorTickInterval / (inputParams.minorTicksPerInterval + 1)) * scaleLayer.scaleMarks.angleRange) / scaleLayer.scaleMarks.valueRange; //--- Set minor step without medium
   }
   CalculateRanges(borderGap);             //--- Calculate ranges
   DrawRanges();                           //--- Draw ranges
   int innerR, outerR;                     //--- Declare radii
   double startX, startY, endX, endY;      //--- Declare coordinates
   int textX, textY;                       //--- Declare text coordinates
   string markText;                        //--- Declare mark text
   int digits;                             //--- Declare digits
   scaleLayer.obj_Canvas.FontSet(scaleLayer.scaleMarks.tickFontName, scaleLayer.scaleMarks.tickFontSize, scaleLayer.scaleMarks.tickFontFlags, 0); //--- Set font
   rightMarkCount++;                       //--- Increment right count
   for(majorIndex = 0; majorIndex < rightMarkCount; majorIndex++) { //--- Loop right marks
      angle = markBuffer[bufferCenterIndex + majorIndex][1]; //--- Get angle
      CalculateInnerOuterRadii(innerR, outerR, (int)scaleArc.radius, scaleLayer.scaleMarks.majorTickLength, inputParams.tickStyle); //--- Calculate radii
      startX = scaleArc.centerX - innerR * MathCos(M_PI - angle); //--- Set start X
      startY = scaleArc.centerY - innerR * MathSin(M_PI - angle); //--- Set start Y
      endX = scaleArc.centerX - outerR * MathCos(M_PI - angle); //--- Set end X
      endY = scaleArc.centerY - outerR * MathSin(M_PI - angle); //--- Set end Y
      textX = (int)(scaleArc.centerX - (outerR - scaleLayer.scaleMarks.tickFontGap) * MathCos(M_PI - angle)); //--- Set text X
      textY = (int)(scaleArc.centerY - (outerR - scaleLayer.scaleMarks.tickFontGap) * MathSin(M_PI - angle)); //--- Set text Y
      scaleLayer.obj_Canvas.LineAA((int)startX, (int)startY, (int)endX, (int)endY, ColorToARGB(scaleArc.clr, scaleLayer.transparency)); //--- Draw line AA
      digits = (markBuffer[bufferCenterIndex + majorIndex][0] == 0) ? 0 : scaleLayer.scaleMarks.decimalPlaces; //--- Set digits
      markText = DoubleToString(markBuffer[bufferCenterIndex + majorIndex][0], digits); //--- Get mark text
      scaleLayer.obj_Canvas.TextOut(textX, textY, markText, ColorToARGB(inputParams.tickFontColor, scaleLayer.transparency), TA_CENTER | TA_VCENTER); //--- Draw text
      if(mediumAngleStep != 0) {           //--- Check medium step
         mediumAngle = angle;              //--- Set medium angle
         for(minorIndex = 1; minorIndex <= inputParams.minorTicksPerInterval; minorIndex++) { //--- Loop minor
            minorAngle = NormalizeRadians(mediumAngle - minorAngleStep * minorIndex); //--- Calculate minor angle
            if(!DrawTick(minorAngle, scaleLayer.scaleMarks.minorTickLength, scaleArc)) //--- Draw minor tick
               break;                      //--- Break if failed
         }
         for(mediumIndex = 1; mediumIndex <= inputParams.mediumTicksPerMajor; mediumIndex++) { //--- Loop medium
            mediumAngle = NormalizeRadians(angle - mediumAngleStep * mediumIndex); //--- Calculate medium angle
            if(!DrawTick(mediumAngle, scaleLayer.scaleMarks.mediumTickLength, scaleArc)) //--- Draw medium tick
               break;                      //--- Break if failed
            for(minorIndex = 1; minorIndex <= inputParams.minorTicksPerInterval; minorIndex++) { //--- Loop minor
               minorAngle = NormalizeRadians(mediumAngle - minorAngleStep * minorIndex); //--- Calculate minor angle
               if(!DrawTick(minorAngle, scaleLayer.scaleMarks.minorTickLength, scaleArc)) //--- Draw minor tick
                  break;                   //--- Break if failed
            }
         }
      } else {                             //--- Handle no medium
         for(minorIndex = 1; minorIndex <= inputParams.minorTicksPerInterval; minorIndex++) { //--- Loop minor
            minorAngle = NormalizeRadians(angle - minorAngleStep * minorIndex); //--- Calculate minor angle
            if(!DrawTick(minorAngle, scaleLayer.scaleMarks.minorTickLength, scaleArc)) //--- Draw minor tick
               break;                      //--- Break if failed
         }
      }
   }
   for(majorIndex = 0; majorIndex < (leftMarkCount + 1); majorIndex++) { //--- Loop left marks
      angle = markBuffer[bufferCenterIndex - majorIndex][1]; //--- Get angle
      CalculateInnerOuterRadii(innerR, outerR, (int)scaleArc.radius, scaleLayer.scaleMarks.majorTickLength, inputParams.tickStyle); //--- Calculate radii
      startX = scaleArc.centerX - innerR * MathCos(M_PI - angle); //--- Set start X
      startY = scaleArc.centerY - innerR * MathSin(M_PI - angle); //--- Set start Y
      endX = scaleArc.centerX - outerR * MathCos(M_PI - angle); //--- Set end X
      endY = scaleArc.centerY - outerR * MathSin(M_PI - angle); //--- Set end Y
      textX = (int)(scaleArc.centerX - (outerR - scaleLayer.scaleMarks.tickFontGap) * MathCos(M_PI - angle)); //--- Set text X
      textY = (int)(scaleArc.centerY - (outerR - scaleLayer.scaleMarks.tickFontGap) * MathSin(M_PI - angle)); //--- Set text Y
      digits = (markBuffer[bufferCenterIndex - majorIndex][0] == 0) ? 0 : scaleLayer.scaleMarks.decimalPlaces; //--- Set digits
      markText = DoubleToString(markBuffer[bufferCenterIndex - majorIndex][0], digits); //--- Get mark text
      if(majorIndex > 0 || (majorIndex == 0 && scaleLayer.scaleMarks.nullMarkPosition == 3)) { //--- Check condition
         scaleLayer.obj_Canvas.LineAA((int)startX, (int)startY, (int)endX, (int)endY, ColorToARGB(scaleArc.clr, scaleLayer.transparency)); //--- Draw line AA
         scaleLayer.obj_Canvas.TextOut(textX, textY, markText, ColorToARGB(inputParams.tickFontColor, scaleLayer.transparency), TA_CENTER | TA_VCENTER); //--- Draw text
      }
      if(mediumAngleStep != 0) {           //--- Check medium step
         mediumAngle = angle;              //--- Set medium angle
         for(minorIndex = 1; minorIndex <= inputParams.minorTicksPerInterval; minorIndex++) { //--- Loop minor
            minorAngle = NormalizeRadians(mediumAngle + minorAngleStep * minorIndex); //--- Calculate minor angle
            if(!DrawTick(minorAngle, scaleLayer.scaleMarks.minorTickLength, scaleArc)) //--- Draw minor tick
               break;                      //--- Break if failed
         }
         for(mediumIndex = 1; mediumIndex <= inputParams.mediumTicksPerMajor; mediumIndex++) { //--- Loop medium
            mediumAngle = NormalizeRadians(angle + mediumAngleStep * mediumIndex); //--- Calculate medium angle
            if(!DrawTick(mediumAngle, scaleLayer.scaleMarks.mediumTickLength, scaleArc)) //--- Draw medium tick
               break;                      //--- Break if failed
            for(minorIndex = 1; minorIndex <= inputParams.minorTicksPerInterval; minorIndex++) { //--- Loop minor
               minorAngle = NormalizeRadians(mediumAngle + minorAngleStep * minorIndex); //--- Calculate minor angle
               if(!DrawTick(minorAngle, scaleLayer.scaleMarks.minorTickLength, scaleArc)) //--- Draw minor tick
                  break;                   //--- Break if failed
            }
         }
      } else {                             //--- Handle no medium
         for(minorIndex = 1; minorIndex <= inputParams.minorTicksPerInterval; minorIndex++) { //--- Loop minor
            minorAngle = NormalizeRadians(angle + minorAngleStep * minorIndex); //--- Calculate minor angle
            if(!DrawTick(minorAngle, scaleLayer.scaleMarks.minorTickLength, scaleArc)) //--- Draw minor tick
               break;                      //--- Break if failed
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Calculate Ranges                                                 |
//+------------------------------------------------------------------+
void CGaugeBase::CalculateRanges(int borderGap) {
   int innerR, outerR;                     //--- Declare radii
   CalculateInnerOuterRadii(innerR, outerR, scaleLayer.scaleArc.radius, scaleLayer.scaleMarks.majorTickLength, inputParams.tickStyle); //--- Calculate radii
   for(int rangeIndex = 0; rangeIndex < 4; rangeIndex++) { //--- Loop ranges
      if(IsValidRange(rangeIndex))         //--- Check valid range
         CalculateRangePie(scaleLayer.ranges[rangeIndex], innerR, borderGap, outerR, inputParams.ranges[rangeIndex].start, inputParams.ranges[rangeIndex].end, inputParams.ranges[rangeIndex].clr, scaleLayer.caseColor); //--- Calculate pie
   }
}

//+------------------------------------------------------------------+
//| Check Valid Range                                                |
//+------------------------------------------------------------------+
bool CGaugeBase::IsValidRange(int index) {
   if(!inputParams.ranges[index].enable)   //--- Check enable
      return false;                        //--- Return false
   if(inputParams.ranges[index].start == inputParams.ranges[index].end) //--- Check start end
      return false;                        //--- Return false
   double paramMin, paramMax, rangeMin, rangeMax; //--- Declare mins maxs
   NormalizeRangeValues(paramMin, paramMax, inputParams.minScaleValue, inputParams.maxScaleValue); //--- Normalize param
   NormalizeRangeValues(rangeMin, rangeMax, inputParams.ranges[index].start, inputParams.ranges[index].end); //--- Normalize range
   if(rangeMin < paramMin && rangeMax < paramMin) //--- Check below param
      return false;                        //--- Return false
   if(rangeMin > paramMax && rangeMax > paramMax) //--- Check above param
      return false;                        //--- Return false
   if(rangeMin < paramMin)                 //--- Check min
      rangeMin = paramMin;                 //--- Clamp min
   if(rangeMax > paramMax)                 //--- Check max
      rangeMax = paramMax;                 //--- Clamp max
   inputParams.ranges[index].start = rangeMin; //--- Set start
   inputParams.ranges[index].end = rangeMax; //--- Set end
   return true;                            //--- Return true
}

//+------------------------------------------------------------------+
//| Normalize Range Values                                           |
//+------------------------------------------------------------------+
void CGaugeBase::NormalizeRangeValues(double &minValue, double &maxValue, double val0, double val1) {
   if(val0 < val1) {                       //--- Check val0 < val1
      minValue = val0;                     //--- Set min
      maxValue = val1;                     //--- Set max
   } else {                                //--- Handle val0 >= val1
      minValue = val1;                     //--- Set min
      maxValue = val0;                     //--- Set max
   }
}

//+------------------------------------------------------------------+
//| Calculate Range Pie                                              |
//+------------------------------------------------------------------+
void CGaugeBase::CalculateRangePie(Struct_Range &range, int innerRadius, int radialGap, int outerRadius, double rangeStart, double rangeEnd, color rangeClr, color caseClr) {
   range.startValue = rangeStart;          //--- Set start value
   range.endValue = rangeEnd;              //--- Set end value
   double rangeStartNorm, rangeEndNorm;    //--- Declare norms
   if(range.startValue > range.endValue) { //--- Check start > end
      rangeStartNorm = range.startValue;   //--- Set start norm
      rangeEndNorm = range.endValue;       //--- Set end norm
   } else if(range.startValue < range.endValue) { //--- Check start < end
      rangeEndNorm = range.startValue;     //--- Set end norm
      rangeStartNorm = range.endValue;     //--- Set start norm
   } else                                  //--- Handle equal
      return;                              //--- Return
   if(scaleLayer.scaleMarks.minValue > scaleLayer.scaleMarks.maxValue) { //--- Check inverse
      double temp = rangeStartNorm;        //--- Temp start
      rangeStartNorm = -rangeEndNorm;      //--- Set start norm
      rangeEndNorm = -temp;                //--- Set end norm
   }
   range.active = true;                    //--- Set active
   range.clr = rangeClr;                   //--- Set color
   range.pie.centerX = scaleLayer.scaleArc.centerX; //--- Set center X
   range.pie.centerY = scaleLayer.scaleArc.centerY; //--- Set center Y
   range.pie.radius = innerRadius;         //--- Set radius
   range.pie.eraseRadius = outerRadius;    //--- Set erase radius
   double angularOffset = MathArcsin(((double)radialGap / (double)range.pie.radius) / 2.0); //--- Calculate offset
   if(scaleLayer.scaleMarks.minValue < scaleLayer.scaleMarks.maxValue) { //--- Check direct
      range.pie.startAngle = NormalizeRadians(scaleLayer.scaleMarks.minAngle - (((rangeStartNorm - scaleLayer.scaleMarks.minValue) * scaleLayer.scaleMarks.angleRange) / scaleLayer.scaleMarks.valueRange)); //--- Set start angle
      range.pie.endAngle = NormalizeRadians(scaleLayer.scaleMarks.minAngle - (((rangeEndNorm - scaleLayer.scaleMarks.minValue) * scaleLayer.scaleMarks.angleRange) / scaleLayer.scaleMarks.valueRange)); //--- Set end angle
      range.pie.eraseStartAngle = NormalizeRadians(scaleLayer.scaleMarks.minAngle - (((rangeStartNorm - scaleLayer.scaleMarks.minValue) * scaleLayer.scaleMarks.angleRange) / scaleLayer.scaleMarks.valueRange) - angularOffset); //--- Set erase start
      range.pie.eraseEndAngle = NormalizeRadians(scaleLayer.scaleMarks.minAngle - (((rangeEndNorm - scaleLayer.scaleMarks.minValue) * scaleLayer.scaleMarks.angleRange) / scaleLayer.scaleMarks.valueRange) + angularOffset); //--- Set erase end
   } else {                                //--- Handle inverse
      range.pie.startAngle = NormalizeRadians(scaleLayer.scaleMarks.minAngle - (((scaleLayer.scaleMarks.minValue + rangeStartNorm) * scaleLayer.scaleMarks.angleRange) / scaleLayer.scaleMarks.valueRange)); //--- Set start angle
      range.pie.endAngle = NormalizeRadians(scaleLayer.scaleMarks.minAngle - (((scaleLayer.scaleMarks.minValue + rangeEndNorm) * scaleLayer.scaleMarks.angleRange) / scaleLayer.scaleMarks.valueRange)); //--- Set end angle
      range.pie.eraseStartAngle = NormalizeRadians(scaleLayer.scaleMarks.minAngle - (((rangeStartNorm + scaleLayer.scaleMarks.minValue) * scaleLayer.scaleMarks.angleRange) / scaleLayer.scaleMarks.valueRange) - angularOffset); //--- Set erase start
      range.pie.eraseEndAngle = NormalizeRadians(scaleLayer.scaleMarks.minAngle - (((rangeEndNorm + scaleLayer.scaleMarks.minValue) * scaleLayer.scaleMarks.angleRange) / scaleLayer.scaleMarks.valueRange) + angularOffset); //--- Set erase end
   }
   range.pie.clr = rangeClr;               //--- Set pie color
   range.pie.eraseClr = caseClr;           //--- Set erase color
}

//+------------------------------------------------------------------+
//| Draw Ranges                                                      |
//+------------------------------------------------------------------+
void CGaugeBase::DrawRanges() {
   for(int i = 0; i < 4; i++)              //--- Loop indices
      DrawRange(scaleLayer.ranges[i]);     //--- Draw range
}

//+------------------------------------------------------------------+
//| Draw Range                                                       |
//+------------------------------------------------------------------+
void CGaugeBase::DrawRange(Struct_Range &range) {
   if(!range.active)                       //--- Check active
      return;                              //--- Return
   int r_min = MathMin(range.pie.radius, range.pie.eraseRadius); //--- Get min r
   int r_max = MathMax(range.pie.radius, range.pie.eraseRadius); //--- Get max r
   for(int r = r_min + 1; r <= r_max; r++) { //--- Loop radii
      double frac = (double)(r - r_min) / (r_max - r_min); //--- Calculate frac
      uchar alpha = (uchar)(scaleLayer.transparency * frac); //--- Calculate alpha
      uint col = ColorToARGB(range.pie.clr, alpha); //--- Get color
      scaleLayer.obj_Canvas.Arc(range.pie.centerX, range.pie.centerY, r, r, range.pie.startAngle, range.pie.endAngle, col); //--- Draw arc
      uint erase_col = ColorToARGB(range.pie.eraseClr, scaleLayer.transparency); //--- Get erase color
      scaleLayer.obj_Canvas.Arc(range.pie.centerX, range.pie.centerY, r, r, range.pie.eraseStartAngle, range.pie.startAngle, erase_col); //--- Draw left erase
      scaleLayer.obj_Canvas.Arc(range.pie.centerX, range.pie.centerY, r, r, range.pie.endAngle, range.pie.eraseEndAngle, erase_col); //--- Draw right erase
   }
}

//+------------------------------------------------------------------+
//| Calculate Inner Outer Radii                                      |
//+------------------------------------------------------------------+
void CGaugeBase::CalculateInnerOuterRadii(int &innerRadius, int &outerRadius, int baseRadius, int tickLength, int tickStyle) {
   innerRadius = baseRadius;               //--- Set inner radius
   outerRadius = baseRadius - tickLength;  //--- Set outer radius
}

//+------------------------------------------------------------------+
//| Draw Tick                                                        |
//+------------------------------------------------------------------+
bool CGaugeBase::DrawTick(double angle, int length, Struct_Arc &scaleArc) {
   int innerR, outerR;                     //--- Declare radii
   double startX, startY, endX, endY;      //--- Declare coordinates
   double arcStartAngle = scaleArc.startAngle; //--- Get start angle
   double arcEndAngle = scaleArc.endAngle; //--- Get end angle
   double deltaToStart = CalculateAngleDelta(arcStartAngle, angle, -1); //--- Calculate delta to start
   double deltaToEnd = CalculateAngleDelta(arcEndAngle, angle, 1); //--- Calculate delta to end
   double totalArcDelta = CalculateAngleDelta(arcStartAngle, arcEndAngle, -1); //--- Calculate total delta
   if(MathAbs(totalArcDelta - (deltaToEnd + deltaToStart)) < (M_PI / 180.0)) //--- Check within arc
      return false;                        //--- Return false
   CalculateInnerOuterRadii(innerR, outerR, scaleArc.radius, length, inputParams.tickStyle); //--- Calculate radii
   startX = scaleArc.centerX - innerR * MathCos(M_PI - angle); //--- Set start X
   startY = scaleArc.centerY - innerR * MathSin(M_PI - angle); //--- Set start Y
   endX = scaleArc.centerX - outerR * MathCos(M_PI - angle); //--- Set end X
   endY = scaleArc.centerY - outerR * MathSin(M_PI - angle); //--- Set end Y
   scaleLayer.obj_Canvas.LineAA((int)startX, (int)startY, (int)endX, (int)endY, ColorToARGB(scaleArc.clr, scaleLayer.transparency)); //--- Draw line AA
   return true;                            //--- Return true
}

//+------------------------------------------------------------------+
//| Calculate Angle Delta                                            |
//+------------------------------------------------------------------+
double CGaugeBase::CalculateAngleDelta(double angle1, double angle2, int direction) {
   double normAngle1 = NormalizeRadians(angle1); //--- Normalize angle1
   double normAngle2 = NormalizeRadians(angle2); //--- Normalize angle2
   double delta1, delta2;                  //--- Declare deltas
   if(normAngle1 == normAngle2)            //--- Check equal
      return 0;                            //--- Return 0
   if(normAngle1 > normAngle2) {           //--- Check angle1 > angle2
      delta1 = normAngle1 - normAngle2;    //--- Set delta1
      delta2 = normAngle2 + (2 * M_PI - normAngle1); //--- Set delta2
   } else {                                //--- Handle angle1 <= angle2
      delta1 = normAngle1 + (2 * M_PI - normAngle2); //--- Set delta1
      delta2 = normAngle2 - normAngle1;    //--- Set delta2
   }
   if(direction < 0)                       //--- Check direction
      return delta1;                       //--- Return delta1
   return delta2;                          //--- Return delta2
}

//+------------------------------------------------------------------+
//| Set Legend String Params                                         |
//+------------------------------------------------------------------+
void CGaugeBase::SetLegendStringParams(Struct_GaugeLegendString &legendString, Struct_GaugeLegendParams &param, int minRadius, int radiusDelta) {
   if(param.enable && param.fontName != "") { //--- Check enable and font
      legendString.text = param.text;      //--- Set text
      legendString.angle = param.angle;    //--- Set angle
      legendString.radius = minRadius + (int)((radiusDelta * param.radius * 10) / 100.0); //--- Set radius
      legendString.fontName = param.fontName; //--- Set font name
      legendString.fontFlags = 0;          //--- Initialize flags
      if(param.italic)                     //--- Check italic
         legendString.fontFlags |= FONT_ITALIC; //--- Add italic
      if(param.bold)                       //--- Check bold
         legendString.fontFlags |= FW_BOLD; //--- Add bold
      legendString.fontSize = (int)(((param.fontSize + 2) * radiusDelta) / 64); //--- Set font size
      legendString.textColor = param.textColor; //--- Set text color
   }
}

//+------------------------------------------------------------------+
//| Delete Gauge                                                     |
//+------------------------------------------------------------------+
void CGaugeBase::Delete() {
   ObjectDelete(0, scaleLayer.objectName); //--- Delete scale object
   ObjectDelete(0, needleLayer.objectName);//--- Delete needle object
}

//+------------------------------------------------------------------+
//| Set New Value                                                    |
//+------------------------------------------------------------------+
void CGaugeBase::NewValue(double value) {
   if(!initializationComplete)             //--- Check initialization
      return;                              //--- Return
   currentValue = value;                   //--- Set current value
   if(scaleLayer.gaugeLabel.value.draw)    //--- Check draw
      RedrawValueDisplay(currentValue);    //--- Redraw value
   RedrawNeedle(currentValue);             //--- Redraw needle
   needleLayer.obj_Canvas.Update(true);    //--- Update canvas
}

//+------------------------------------------------------------------+
//| Get Label Area Size                                              |
//+------------------------------------------------------------------+
bool CGaugeBase::GetLabelAreaSize(Struct_LabelAreaSize &areaSize, Struct_GaugeLegendString &legendString) {
   if(!scaleLayer.obj_Canvas.FontSet(legendString.fontName, legendString.fontSize, legendString.fontFlags, 0)) //--- Set font
      return false;                        //--- Return false
   scaleLayer.obj_Canvas.TextSize(legendString.text, areaSize.width, areaSize.height); //--- Get text size
   if(areaSize.width == 0 || areaSize.height == 0) //--- Check size
      return false;                        //--- Return false
   areaSize.diagonal = (int)MathCeil(MathSqrt((double)(areaSize.width * areaSize.width + areaSize.height * areaSize.height))); //--- Calculate diagonal
   return true;                            //--- Return true
}

//+------------------------------------------------------------------+
//| Erase Legend String                                              |
//+------------------------------------------------------------------+
bool CGaugeBase::EraseLegendString(Struct_GaugeLegendString &legendString, color eraseClr) {
   Struct_LabelAreaSize areaSize;          //--- Declare area size
   if(!GetLabelAreaSize(areaSize, legendString)) //--- Get area size
      return false;                        //--- Return false
   scaleLayer.obj_Canvas.FillRectangle((int)legendString.x - (areaSize.width / 2) - 4, (int)legendString.y - (areaSize.height / 2), (int)legendString.x + (areaSize.width / 2) + 4, (int)legendString.y + (areaSize.height / 2), ColorToARGB(eraseClr, scaleLayer.transparency)); //--- Fill rectangle
   return true;                            //--- Return true
}

//+------------------------------------------------------------------+
//| Redraw Value Display                                             |
//+------------------------------------------------------------------+
bool CGaugeBase::RedrawValueDisplay(double value) {
   if(StringLen(scaleLayer.gaugeLabel.value.text) > 0) { //--- Check text length
      if(!EraseLegendString(scaleLayer.gaugeLabel.value, scaleLayer.gaugeLabel.value.backgroundColor)) //--- Erase string
         return false;                     //--- Return false
   }
   scaleLayer.gaugeLabel.value.text = DoubleToString(value, (int)scaleLayer.gaugeLabel.value.decimalPlaces); //--- Set text
   if(!scaleLayer.obj_Canvas.FontSet(scaleLayer.gaugeLabel.value.fontName, scaleLayer.gaugeLabel.value.fontSize, scaleLayer.gaugeLabel.value.fontFlags, 0)) //--- Set font
      return false;                        //--- Return false
   scaleLayer.obj_Canvas.TextOut(scaleLayer.gaugeLabel.value.x, scaleLayer.gaugeLabel.value.y, scaleLayer.gaugeLabel.value.text, ColorToARGB(scaleLayer.gaugeLabel.value.textColor, scaleLayer.transparency), TA_CENTER | TA_VCENTER); //--- Draw text
   scaleLayer.obj_Canvas.Update(true);     //--- Update canvas
   return true;                            //--- Return true
}

//+------------------------------------------------------------------+
//| Degrees to Radians                                               |
//+------------------------------------------------------------------+
double DegreesToRadians(double degrees) {
   return((M_PI * degrees) / 180.0);      //--- Convert degrees to radians
}

//+------------------------------------------------------------------+
//| Normalize Radians                                                |
//+------------------------------------------------------------------+
double NormalizeRadians(double angle) {
   while(angle < 0.0) angle += 2.0 * M_PI; //--- Adjust negative
   while(angle >= 2.0 * M_PI) angle -= 2.0 * M_PI; //--- Adjust positive
   return(angle);                          //--- Return normalized
}

//+------------------------------------------------------------------+
//| Get Tick Font Gap                                                |
//+------------------------------------------------------------------+
int GetTickFontGap(Struct_ScaleMarks &scaleMarks, int stringLength) {
   int gap = 0;                            //--- Initialize gap
   Struct_LabelAreaSize areaSize;          //--- Declare area size
   CCanvas obj_Canvas_temp;                //--- Declare temp canvas
   if(!obj_Canvas_temp.FontSet(scaleMarks.tickFontName, scaleMarks.tickFontSize, scaleMarks.tickFontFlags, 0)) //--- Set font
      return gap;                          //--- Return gap
   string str = "000";                     //--- Set str
   obj_Canvas_temp.TextSize(str, areaSize.width, areaSize.height); //--- Get text size
   if(areaSize.width == 0 || areaSize.height == 0) //--- Check size
      return gap;                          //--- Return gap
   areaSize.diagonal = (int)MathCeil(MathSqrt((double)(areaSize.width * areaSize.width + areaSize.height * areaSize.height))); //--- Calculate diagonal
   gap = (int)(areaSize.diagonal * 0.5);   //--- Set gap
   return gap;                             //--- Return gap
}

//+------------------------------------------------------------------+
//| Get Tick Label Area Size                                         |
//+------------------------------------------------------------------+
bool GetTickLabelAreaSize(int &areaSize, Struct_ScaleMarks &scaleMarks, int stringLength) {
   CCanvas obj_Canvas_temp;                //--- Declare temp canvas
   int width = 0, height = 0;              //--- Initialize width height
   if(!obj_Canvas_temp.FontSet(scaleMarks.tickFontName, scaleMarks.tickFontSize, scaleMarks.tickFontFlags, 0)) //--- Set font
      return false;                        //--- Return false
   string str = "000";                     //--- Set str
   obj_Canvas_temp.TextSize(str, width, height); //--- Get text size
   if(width == 0 || height == 0)           //--- Check size
      return false;                        //--- Return false
   areaSize = (int)MathCeil(MathSqrt((double)(width * width + height * height))); //--- Calculate area size
   return true;                            //--- Return true
}

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
CGaugeBase gauge;                          //--- Declare gauge object
int rsiHandle;                             //--- Declare RSI handle
double scaleMultipliers[9] = {10000, 1000, 100, 10, 1, 0.1, 0.01, 0.001, 0.0001}; //--- Define scale multipliers array
string scaleMultiplierStrings[9] = {"x10k", "x1k", "x100", "x10", " ", "/10", "/100", "/1k", "/10k"}; //--- Define multiplier strings array
double rsiBuffer[];                        //--- Declare RSI buffer

//+------------------------------------------------------------------+
//| Initialize Indicator                                             |
//+------------------------------------------------------------------+
int OnInit() {
   if(!gauge.Create("rsi_gauge", 30, 30, 250, "", 0, 0, false, 0, 0)) //--- Create gauge
      return(INIT_FAILED);                 //--- Return failed
   gauge.SetCaseParameters(clrMintCream, 1, clrLightSkyBlue, 1); //--- Set case parameters
   gauge.SetScaleParameters(250, 0, 0, 100, 4, 0, clrBlack, false); //--- Set scale parameters
   gauge.SetTickParameters(0, 2, 10, 1, 4); //--- Set tick parameters
   gauge.SetTickLabelFont(1, "Arial", false, false, clrBlack); //--- Set tick label font
   gauge.SetRangeParameters(0, true, 0, 30, clrLimeGreen); //--- Set range 0
   gauge.SetRangeParameters(1, true, 70, 100, clrCoral); //--- Set range 1
   gauge.SetRangeParameters(2, true, 30, 70, clrYellow); //--- Set range 2
   gauge.SetRangeParameters(3, false, 0, 0, clrGray); //--- Set range 3
   gauge.SetLegendParameters(0, true, "RSI", 8, -180, 20, "Arial", false, false, clrBlueViolet); //--- Set legend 0
   gauge.SetLegendParameters(3, true, "2", 4, 180, 13, "Arial", true, false, clrRed); //--- Set legend 3
   gauge.SetNeedleParameters(1, clrBlack, clrDimGray, 1); //--- Set needle parameters
   gauge.Redraw();                         //--- Redraw gauge
   gauge.NewValue(0);                      //--- Set new value 0
   rsiHandle = iRSI(_Symbol, _Period, 14, 4); //--- Get RSI handle
   if(rsiHandle == INVALID_HANDLE)         //--- Check handle
      return(INIT_FAILED);                 //--- Return failed
   SetIndexBuffer(0, rsiBuffer, INDICATOR_DATA); //--- Set index buffer
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE); //--- Set plot empty
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, 14 - 1); //--- Set draw begin
   IndicatorSetInteger(INDICATOR_LEVELS, 2); //--- Set levels
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 0, 30); //--- Set level 0
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 1, 70); //--- Set level 1
   return(INIT_SUCCEEDED);                 //--- Return succeeded
}

//+------------------------------------------------------------------+
//| Deinitialize Indicator                                           |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   gauge.Delete();                         //--- Delete gauge
   ChartRedraw();                          //--- Redraw chart
}

//+------------------------------------------------------------------+
//| Calculate Indicator                                              |
//+------------------------------------------------------------------+
int OnCalculate(const int ratesTotal,
                const int prevCalculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tickVolume[],
                const long &volume[],
                const int &spread[]) {
   if(CopyBuffer(rsiHandle, 0, 0, ratesTotal, rsiBuffer) < 0) { //--- Copy buffer
      Print("RSI CopyBuffer error for plot"); //--- Print error
      return(0);                           //--- Return 0
   }
   static datetime lastBarTime = 0;        //--- Declare last bar time
   bool isNewBar = (ratesTotal > 0 && time[ratesTotal - 1] != lastBarTime); //--- Check new bar
   if(isNewBar)                            //--- If new bar
      lastBarTime = time[ratesTotal - 1];  //--- Update last bar time
   if(isNewBar) {                          //--- If new bar
      int barsCalculated = BarsCalculated(rsiHandle); //--- Get bars calculated
      if(barsCalculated > 0) {             //--- Check calculated
         double currentRsiValue[1];        //--- Declare current value
         if(CopyBuffer(rsiHandle, 0, 0, 1, currentRsiValue) < 0) //--- Copy buffer
            Print("RSI CopyBuffer error for gauge"); //--- Print error
         else                              //--- Else
            gauge.NewValue(currentRsiValue[0]); //--- Set new value
      }
   }
   return(ratesTotal);                     //--- Return rates total
}