
//+--------------------------------------------------------------------------+
//|                                                     TstDE132.mq5         |
//|                                     https://mql5.com/en/users/artmedia70 |
//+--------------------------------------------------------------------------+
//|                                                 DoEasy. Controls         |
//|           32. Horizontal ScrollBar, mouse wheel scrolling                |
//|                          https://www.mql5.com/en/articles/12849          |
//+--------------------------------------------------------------------------+

#include "12849 Horizontal ScrollBar.mqh"
class CProgram
{
  private:   
      CEngine m_engine;
      CCreateGUI m_gui;
      //Trafer setting from EA
      bool m_movable;
      ENUM_INPUT_YES_NO m_autosize;
      ENUM_AUTO_SIZE_MODE m_autosizemode;
    void InitEngine();
    void InitEvent();
    void CreateGUI();

  public:
    void OnInitEvent();
    void OnDeinitEvent(const int reason);
    void OnChartEvent(
        const int id,
        const long &lparam,
        const double &dparam,
        const string &sparam
        );
  

}
//Private Method
void CProgram::InitEngine()
    {        
            string array[1]={Symbol()};
            m_engine.SetUsedSymbols(array);
            m_engine.SeriesCreate(Symbol(),Period());
    }    
  void CProgram::InitEvent()
    {  
      EventSetTimer(1);
      SDataCalculate data;
      m_engine.GetTimeSeriesCollection().Refresh(
                                                  Symbol(),
                                                  Period(),
                                                  data
                                              );      
    }
bool CProgram::CreateGUI()
    {
        return m_gui.Create(
          m_engine,
          m_movable,
          m_autosize,
          m_autosizemode
      );
    }
//Public Method
void CProgram::OnInitEvent()
{  
    EventSetTimer(1);
    SDataCalculate data;
    m_engine.GetTimeSeriesCollection().Refresh(
                                                Symbol(),
                                                Period(),
                                                data
                                            );      
}

void CProgram::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
 {

 } 


