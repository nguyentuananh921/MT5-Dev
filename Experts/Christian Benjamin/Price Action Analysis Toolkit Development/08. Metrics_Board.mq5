//+------------------------------------------------------------------+
//|                                                 Metrics Board.mql5|
//|                                   Copyright 2026, MetaQuotes Ltd.|
//|                          https://www.mql5.com/en/users/lynnchris |
//+------------------------------------------------------------------+
//|               Price Action Analysis Toolkit Development          |
//|               Metrics Board                                      |
//|               https://www.mql5.com/en/articles/16584             |
//+------------------------------------------------------------------+
#property copyright "2025, MetaQuotes Software Corp."
#property link      "https://www.mql5.com/en/users/lynnchris"
#property version   "1.0"
#property strict

#include <Trade\Trade.mqh>
#include <Controls\Dialog.mqh>
#include <Controls\Button.mqh>
#include <Controls\Label.mqh>
#include <Controls\Panel.mqh>

// Metrics Board Class
class CMetricsBoard : public CAppDialog
  {
private:
   CButton           m_btnClose; // Close Button
   CButton           m_btnHighLowAnalysis;
   CButton           m_btnVolumeAnalysis;
   CButton           m_btnTrendAnalysis;
   CButton           m_btnVolatilityAnalysis;
   CButton           m_btnMovingAverage;
   CButton           m_btnSupportResistance;
   CPanel            m_panelResults;
   CLabel            m_lblResults;

public:
                     CMetricsBoard(void);
                    ~CMetricsBoard(void);
   virtual bool      Create(const long chart, const string name, const int subwin, const int x1, const int y1, const int x2, const int y2);
   virtual void      Minimize();
   virtual bool      Run(); // Declaration of Run method
   virtual bool      OnEvent(const int id, const long &lparam, const double &dparam, const string &sparam);
   virtual bool      ChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam);
   virtual void      Destroy(const int reason = REASON_PROGRAM); // Override Destroy method

private:
   bool              CreateButtons(void);
   bool              CreateResultsPanel(void);
   void              OnClickButtonClose(); // New close button handler
   void              PerformHighLowAnalysis(void);
   void              PerformVolumeAnalysis(void);
   void              PerformTrendAnalysis(void);
   void              PerformVolatilityAnalysis(void);
   void              PerformMovingAverageAnalysis(void);
   void              PerformSupportResistanceAnalysis(void);
   double            CalculateMovingAverage(int period);
  };

CMetricsBoard::CMetricsBoard(void) {}

CMetricsBoard::~CMetricsBoard(void) {}

// Override Destroy method
void CMetricsBoard::Destroy(const int reason)
  {
// Call base class Destroy method to release resources
   CAppDialog::Destroy(reason);
  }

//+------------------------------------------------------------------+
//| Create a control dialog                                          |
//+------------------------------------------------------------------+
bool CMetricsBoard::Create(const long chart, const string name, const int subwin, const int x1, const int y1, const int x2, const int y2)
  {
   if(!CAppDialog::Create(chart, name, subwin, x1, y1, x2, y2))
     {
      Print("Failed to create CAppDialog instance.");
      return false; // Failed to create the dialog
     }

   if(!CreateResultsPanel())
     {
      Print("Failed to create results panel.");
      return false; // Failed to create the results panel
     }

   if(!CreateButtons())
     {
      Print("Failed to create buttons.");
      return false; // Failed to create buttons
     }

   Show(); // Show the dialog after creation
   return true; // Successfully created the dialog
  }

//+------------------------------------------------------------------+
//| Minimize the control window                                      |
//+------------------------------------------------------------------+
void CMetricsBoard::Minimize()
  {
   CAppDialog::Minimize();
  }

//+------------------------------------------------------------------+
//| Run the control.                                                |
//+------------------------------------------------------------------+
bool CMetricsBoard::Run()
  {
// Assuming Run makes the dialog functional
   if(!Show())
     {
      Print("Failed to show the control.");
      return false; // Could not show the control
     }
// Additional initialization or starting logic can be added here
   return true; // Successfully run the control
  }

//+------------------------------------------------------------------+
//| Create the results panel                                         |
//+------------------------------------------------------------------+
bool CMetricsBoard::CreateResultsPanel(void)
  {
   if(!m_panelResults.Create(0, "ResultsPanel", 0, 10, 10, 330, 60))
      return false;

   m_panelResults.Color(clrLightGray);
   Add(m_panelResults);

   if(!m_lblResults.Create(0, "ResultsLabel", 0, 15, 15, 315, 30))
      return false;

   m_lblResults.Text("Results will be displayed here.");
   m_lblResults.Color(clrBlack);
   m_lblResults.FontSize(12);
   Add(m_lblResults);

   return true;
  }

//+------------------------------------------------------------------+
//| Create buttons for the panel                                     |
//+------------------------------------------------------------------+
bool CMetricsBoard::CreateButtons(void)
  {
   int x = 20;
   int y = 80;
   int buttonWidth = 300;
   int buttonHeight = 30;
   int spacing = 15;

// Create Close Button
   if(!m_btnClose.Create(0, "CloseButton", 0, x, y, x + buttonWidth, y + buttonHeight))
      return false;

   m_btnClose.Text("Close Panel");
   Add(m_btnClose);
   y += buttonHeight + spacing;

   struct ButtonData
     {
      CButton        *button;
      string         name;
      string         text;
     };

   ButtonData buttons[] =
     {
        {&m_btnHighLowAnalysis, "HighLowButton", "High/Low Analysis"},
        {&m_btnVolumeAnalysis, "VolumeButton", "Volume Analysis"},
        {&m_btnTrendAnalysis, "TrendButton", "Trend Analysis"},
        {&m_btnVolatilityAnalysis, "VolatilityButton", "Volatility Analysis"},
        {&m_btnMovingAverage, "MovingAverageButton", "Moving Average"},
        {&m_btnSupportResistance, "SupportResistanceButton", "Support/Resistance"}
     };

   for(int i = 0; i < ArraySize(buttons); i++)
     {
      if(!buttons[i].button.Create(0, buttons[i].name, 0, x, y, x + buttonWidth, y + buttonHeight))
         return false;

      buttons[i].button.Text(buttons[i].text);
      Add(buttons[i].button);
      y += buttonHeight + spacing;
     }

   return true;
  }

//+------------------------------------------------------------------+
//| Handle events for button clicks                                   |
//+------------------------------------------------------------------+
bool CMetricsBoard::OnEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id == CHARTEVENT_OBJECT_CLICK)
     {
      Print("Event ID: ", id, ", Event parameter (sparam): ", sparam);

      if(sparam == "CloseButton") // Handle close button click
        {
         OnClickButtonClose(); // Call to new close button handler
         return true; // Event processed
        }
      else
         if(sparam == "HighLowButton")
           {
            Print("High/Low Analysis Button Clicked");
            m_lblResults.Text("Performing High/Low Analysis...");
            PerformHighLowAnalysis();
            return true; // Event processed
           }
         else
            if(sparam == "VolumeButton")
              {
               Print("Volume Analysis Button Clicked");
               m_lblResults.Text("Performing Volume Analysis...");
               PerformVolumeAnalysis();
               return true; // Event processed
              }
            else
               if(sparam == "TrendButton")
                 {
                  Print("Trend Analysis Button Clicked");
                  m_lblResults.Text("Performing Trend Analysis...");
                  PerformTrendAnalysis();
                  return true; // Event processed
                 }
               else
                  if(sparam == "VolatilityButton")
                    {
                     Print("Volatility Analysis Button Clicked");
                     m_lblResults.Text("Performing Volatility Analysis...");
                     PerformVolatilityAnalysis();
                     return true; // Event processed
                    }
                  else
                     if(sparam == "MovingAverageButton")
                       {
                        Print("Moving Average Analysis Button Clicked");
                        m_lblResults.Text("Calculating Moving Average...");
                        PerformMovingAverageAnalysis();
                        return true; // Event processed
                       }
                     else
                        if(sparam == "SupportResistanceButton")
                          {
                           Print("Support/Resistance Analysis Button Clicked");
                           m_lblResults.Text("Calculating Support/Resistance...");
                           PerformSupportResistanceAnalysis();
                           return true; // Event processed
                          }
     }

   return false; // If we reach here, the event was not processed
  }

//+------------------------------------------------------------------+
//| Handle chart events                                              |
//+------------------------------------------------------------------+
bool CMetricsBoard::ChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   Print("ChartEvent ID: ", id, ", lparam: ", lparam, ", dparam: ", dparam, ", sparam: ", sparam);

   if(id == CHARTEVENT_OBJECT_CLICK)
     {
      return OnEvent(id, lparam, dparam, sparam);
     }

   return false;
  }

//+------------------------------------------------------------------+
//| Analysis operations                                              |
//+------------------------------------------------------------------+
void CMetricsBoard::PerformHighLowAnalysis(void)
  {
   double high = iHigh(Symbol(), PERIOD_H1, 0);
   double low = iLow(Symbol(), PERIOD_H1, 0);

   Print("Retrieved High: ", high, ", Low: ", low);

   if(high == 0 || low == 0)
     {
      m_lblResults.Text("Failed to retrieve high/low values.");
      return;
     }

   string result = StringFormat("High: %.5f, Low: %.5f", high, low);
   m_lblResults.Text(result);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMetricsBoard::PerformVolumeAnalysis(void)
  {
   double volume = iVolume(Symbol(), PERIOD_H1, 0);
   Print("Retrieved Volume: ", volume);

   if(volume < 0)
     {
      m_lblResults.Text("Failed to retrieve volume.");
      return;
     }

   string result = StringFormat("Volume (Last Hour): %.1f", volume);
   m_lblResults.Text(result);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMetricsBoard::PerformTrendAnalysis(void)
  {
   double ma = CalculateMovingAverage(14);
   Print("Calculated 14-period MA: ", ma);

   if(ma <= 0)
     {
      m_lblResults.Text("Not enough data for moving average calculation.");
      return;
     }

   string result = StringFormat("14-period MA: %.5f", ma);
   m_lblResults.Text(result);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMetricsBoard::PerformVolatilityAnalysis(void)
  {
   int atr_period = 14;
   int atr_handle = iATR(Symbol(), PERIOD_H1, atr_period);

   if(atr_handle == INVALID_HANDLE)
     {
      m_lblResults.Text("Failed to get ATR handle.");
      return;
     }

   double atr_value[];
   if(CopyBuffer(atr_handle, 0, 0, 1, atr_value) < 0)
     {
      m_lblResults.Text("Failed to copy ATR value.");
      IndicatorRelease(atr_handle);
      return;
     }

   string result = StringFormat("ATR (14): %.5f", atr_value[0]);
   m_lblResults.Text(result);
   IndicatorRelease(atr_handle);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMetricsBoard::PerformMovingAverageAnalysis(void)
  {
   double ma = CalculateMovingAverage(50);
   Print("Calculated 50-period MA: ", ma);

   if(ma <= 0)
     {
      m_lblResults.Text("Not enough data for moving average calculation.");
      return;
     }

   string result = StringFormat("50-period MA: %.5f", ma);
   m_lblResults.Text(result);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMetricsBoard::PerformSupportResistanceAnalysis(void)
  {
   double support = iLow(Symbol(), PERIOD_H1, 1);
   double resistance = iHigh(Symbol(), PERIOD_H1, 1);
   Print("Retrieved Support: ", support, ", Resistance: ", resistance);

   if(support == 0 || resistance == 0)
     {
      m_lblResults.Text("Failed to retrieve support/resistance levels.");
      return;
     }

   string result = StringFormat("Support: %.5f, Resistance: %.5f", support, resistance);
   m_lblResults.Text(result);
  }

//+------------------------------------------------------------------+
//| Calculate moving average                                         |
//+------------------------------------------------------------------+
double CMetricsBoard::CalculateMovingAverage(int period)
  {
   if(period <= 0)
      return 0;

   double sum = 0.0;
   int bars = Bars(Symbol(), PERIOD_H1);

   if(bars < period)
     {
      return 0;
     }

   for(int i = 0; i < period; i++)
     {
      sum += iClose(Symbol(), PERIOD_H1, i);
     }
   return sum / period;
  }

// Implementation of OnClickButtonClose
void CMetricsBoard::OnClickButtonClose()
  {
   Print("Close button clicked. Closing the Metrics Board...");
   Destroy();  // This method destroys the panel
  }

CMetricsBoard ExtDialog;

//+------------------------------------------------------------------+
//| Initialize the application                                       |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!ExtDialog.Create(0, "Metrics Board", 0, 10, 10, 350, 500))
     {
      Print("Failed to create Metrics Board.");
      return INIT_FAILED;
     }

   if(!ExtDialog.Run()) // Call Run to make the dialog functional
     {
      Print("Failed to run Metrics Board.");
      return INIT_FAILED; // Call to Run failed
     }

   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Deinitialize the application                                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ExtDialog.Destroy(reason); // Properly call Destroy method
  }

//+------------------------------------------------------------------+
//| Handle chart events                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   ExtDialog.ChartEvent(id, lparam, dparam, sparam);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
