//+------------------------------------------------------------------+
//|                                                       WndInd.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|Topic link:  https://www.mql5.com/en/articles/9260                |
//|Lib          https://www.mql5.com/en/articles/14710               |
//+------------------------------------------------------------------+
//--- An indicator of a chart window. Methods come from V3 one by one when a class asks for them
#ifndef CWNDIND_MQH
#define CWNDIND_MQH
 #include <Object.mqh>
 #include "..\Defines\CommonDefines.mqh"
#ifndef CWNDIND_MQH_DECLARATION
#define CWNDIND_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Chart window indicator: its short name and its identity, the     |
 //| type and the parameters. No handle is kept: MT5 reuses handles   |
 //+------------------------------------------------------------------+
 class CWndInd : public CObject
  {
   private:
      string            m_name;                             // Indicator short name
      int               m_index;                            // Indicator index in the chart window
      int               m_window_num;                       // Indicator subwindow index
      ENUM_INDICATOR    m_type_indicator;                   // Identity: indicator type
      MqlParam          m_params[];                         // Identity: indicator parameters
   public:
     //--- Return (1) indicator name, (2) index in the chart window, (3) subwindow index and (4) indicator type
      string            Name(void)                    const { return this.m_name;           }
      int               Index(void)                   const { return this.m_index;          }
      int               WindowNum(void)               const { return this.m_window_num;     }
      ENUM_INDICATOR    TypeIndicator(void)           const { return this.m_type_indicator; }
     //--- Copy out the identity (type + parameters), false when the chart did not tell it
      bool              GetIdentity(ENUM_INDICATOR &type,MqlParam &params[]) const;
     //--- The other indicator has the same name, type and parameters
      bool              SameIdentity(const CWndInd *other) const;
     //--- Return an object type
      virtual int       Type(void)                    const { return OBJECT_DE_TYPE_CHART_WND_IND; }
     //--- Constructor: the indicator of a chart window, its name, type and parameters are read from the chart
                        CWndInd(const long chart_id,const int win_num,const int index);
  };
#endif // CWNDIND_MQH_DECLARATION
#ifndef CWNDIND_MQH_IMPLEMENTATION
#define CWNDIND_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| The handle is only a way to ask MT5 for the identity (type +     |
 //| params). Not released: MT5 may give the slot of a CIndicatorDE,  |
 //| only ~CIndicatorDE releases (a Get again returns the same slot)  |
 //+------------------------------------------------------------------+
 CWndInd::CWndInd(const long chart_id,const int win_num,const int index) : m_index(index),m_window_num(win_num),m_type_indicator(IND_CUSTOM)
  {
   this.m_name=::ChartIndicatorName(chart_id,win_num,index);
   int handle=::ChartIndicatorGet(chart_id,win_num,this.m_name);
   if(handle==INVALID_HANDLE)
      return;
   if(::IndicatorParameters(handle,this.m_type_indicator,this.m_params)<0)
     {
      this.m_type_indicator=IND_CUSTOM;
      ::ArrayResize(this.m_params,0);
     }
  }
 //+------------------------------------------------------------------+
 //| Copy out the identity: false when the chart did not tell it      |
 //+------------------------------------------------------------------+
 bool CWndInd::GetIdentity(ENUM_INDICATOR &type,MqlParam &params[]) const
  {
   type=this.m_type_indicator;
   int total=::ArraySize(this.m_params);
   ::ArrayResize(params,total);
   for(int i=0;i<total;i++)
      params[i]=this.m_params[i];
   return(this.m_type_indicator!=IND_CUSTOM || total>0);
  }
 //+------------------------------------------------------------------+
 //| The same indicator: the name, the type and every parameter       |
 //+------------------------------------------------------------------+
 bool CWndInd::SameIdentity(const CWndInd *other) const
  {
   if(other==NULL || this.m_name!=other.m_name || this.m_type_indicator!=other.m_type_indicator ||
      ::ArraySize(this.m_params)!=::ArraySize(other.m_params))
      return false;
   for(int i=0;i<::ArraySize(this.m_params);i++)
     {
      if(this.m_params[i].type!=other.m_params[i].type)
         return false;
      if(this.m_params[i].integer_value!=other.m_params[i].integer_value ||
         this.m_params[i].double_value!=other.m_params[i].double_value ||
         this.m_params[i].string_value!=other.m_params[i].string_value)
         return false;
     }
   return true;
  }
#endif // CWNDIND_MQH_IMPLEMENTATION
#endif // CWNDIND_MQH
