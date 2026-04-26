//+------------------------------------------------------------------+
//|                                                BaseObjExt.mqh    |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|Lib https://www.mql5.com/en/articles/14710                        |
//|              Pure data — no changes from original                |
//|              Extracted from: BaseObj.mqh                         |
//+------------------------------------------------------------------+
#ifndef __CBASEOBJEXT_MQH__
#define __CBASEOBJEXT_MQH__
    // TODO: review includes
    #include <Arrays\ArrayObj.mqh>
    #include "BaseObj.mqh"
    #include "EventBaseObj.mqh"
    #include "BaseEvent.mqh"
    #include "..\Notify\Message.mqh"
    #define CONTROLS_TOTAL  (10)

 #ifndef CBASEOBJEXT_MQH_DECLARATION
 #define CBASEOBJEXT_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Extended base object class for all library objects                |
//+------------------------------------------------------------------+
class CBaseObjExt : public CBaseObj
  {
private:
   int                    m_long_prop_total;
   int                    m_double_prop_total;
   template<typename T> bool FillPropertySettings(const int index,T &array[][CONTROLS_TOTAL],T &array_prev[][CONTROLS_TOTAL],int &event_id);
   
protected:
   CArrayObj              m_list_events_base;
   CArrayObj              m_list_events;
   MqlTick                m_tick;
   double                 m_hash_sum;
   double                 m_hash_sum_prev;
   int                    m_digits_currency;
   bool                   m_is_event;
   int                    m_event_code;
   int                    m_event_id;
   // [index][0]=INC  [1]=DEC  [2]=LEVEL  [3]=Value  [4]=Change
   // [5]=FlagINC  [6]=FlagDEC  [7]=FlagMORE  [8]=FlagLESS  [9]=FlagEQUAL
   long                   m_long_prop_event[][CONTROLS_TOTAL];
   double                 m_double_prop_event[][CONTROLS_TOTAL];
   long                   m_long_prop_event_prev[][CONTROLS_TOTAL];
   double                 m_double_prop_event_prev[][CONTROLS_TOTAL];

   long              TickTime(void) const
                       {
                        #ifdef __MQL5__
                           return m_tick.time_msc;
                        #else
                           return m_tick.time*1000;
                        #endif
                       }
   ushort            MSCfromTime(const long time_msc) const
                       {
                        #ifdef __MQL5__
                           return ushort(TickTime()%1000);
                        #else
                           return 0;
                        #endif
                       }
   bool              IsPresentEventFlag(const int change_code) const { return(m_event_code & change_code)==change_code; }
   int               DigitsCurrency(void) const                      { return m_digits_currency;                        }
   int               GetDigits(const double value) const;
   bool              SetControlDataArraySizeLong(const int size);
   bool              SetControlDataArraySizeDouble(const int size);
   bool              CheckControlDataArraySize(bool check_long=true);
   void              CheckEvents(void);
   long              UshortToLong(const ushort ushort_value,const uchar to_byte,long &long_value);
   long              UshortToByte(const ushort value,const uchar to_byte) const;

public:
   template<typename T> void SetControlledValueINC(const int property,const T value);
   template<typename T> void SetControlledValueDEC(const int property,const T value);
   template<typename T> void SetControlledValueLEVEL(const int property,const T value);

   long              GetControlledLongValueINC(const int p)     const { return m_long_prop_event[p][0];                         }
   double            GetControlledDoubleValueINC(const int p)   const { return m_double_prop_event[p-m_long_prop_total][0];     }
   long              GetControlledLongValueDEC(const int p)     const { return m_long_prop_event[p][1];                         }
   double            GetControlledDoubleValueDEC(const int p)   const { return m_double_prop_event[p-m_long_prop_total][1];     }
   long              GetControlledLongValueLEVEL(const int p)   const { return m_long_prop_event[p][2];                         }
   double            GetControlledDoubleValueLEVEL(const int p) const { return m_double_prop_event[p-m_long_prop_total][2];     }
   long              GetPropLongValue(const int p)              const { return m_long_prop_event[p][3];                         }
   double            GetPropDoubleValue(const int p)            const { return m_double_prop_event[p-m_long_prop_total][3];     }
   long              GetPropLongChangedValue(const int p)       const { return m_long_prop_event[p][4];                         }
   double            GetPropDoubleChangedValue(const int p)     const { return m_double_prop_event[p-m_long_prop_total][4];     }
   long              GetPropLongFlagINC(const int p)            const { return m_long_prop_event[p][5];                         }
   double            GetPropDoubleFlagINC(const int p)          const { return m_double_prop_event[p-m_long_prop_total][5];     }
   long              GetPropLongFlagDEC(const int p)            const { return m_long_prop_event[p][6];                         }
   double            GetPropDoubleFlagDEC(const int p)          const { return m_double_prop_event[p-m_long_prop_total][6];     }
   long              GetPropLongFlagMORE(const int p)           const { return m_long_prop_event[p][7];                         }
   double            GetPropDoubleFlagMORE(const int p)         const { return m_double_prop_event[p-m_long_prop_total][7];     }
   long              GetPropLongFlagLESS(const int p)           const { return m_long_prop_event[p][8];                         }
   double            GetPropDoubleFlagLESS(const int p)         const { return m_double_prop_event[p-m_long_prop_total][8];     }
   long              GetPropLongFlagEQUAL(const int p)          const { return m_long_prop_event[p][9];                         }
   double            GetPropDoubleFlagEQUAL(const int p)        const { return m_double_prop_event[p-m_long_prop_total][9];     }

   void              ResetChangesParams(void);
   virtual void      ResetControlsParams(void);
   bool              EventAdd(const ushort event_id,const long lparam,const double dparam,const string sparam);
   bool              EventBaseAdd(const int event_id,const ENUM_BASE_EVENT_REASON reason,const double value);
   void              SetEventFlag(const bool flag)  { m_is_event=flag;              }
   bool              IsEvent(void)          const   { return m_is_event;            }
   CArrayObj        *GetListEvents(void)            { return &m_list_events;        }
   int               GetEventCode(void)     const   { return m_event_code;          }
   CEventBaseObj    *GetEvent(const int shift=WRONG_VALUE,const bool check_out=true);
   CBaseEvent       *GetEventBase(const int index);
   int               GetEventsTotal(void)   const   { return m_list_events.Total(); }
   virtual void      Refresh(void);
   string            EventDescription(const int property,const ENUM_BASE_EVENT_REASON reason,
                                      const int source,const string value,
                                      const string property_descr,const int digits);
   void              SetGroupID1(const uchar group,uint &magic)  { magic&=0xFFF0FFFF; magic|=uint(ConvToXX(group,0)<<16); }
   void              SetGroupID2(const uchar group,uint &magic)  { magic&=0xFF0FFFFF; magic|=uint(ConvToXX(group,1)<<16); }
   void              SetPendReqID(const uchar id,uint &magic)    { magic&=0x00FFFFFF; magic|=(uint)id<<24;                }
   uchar             ConvToXX(const uchar number,const uchar index) const { return((number>15?15:number)<<(4*(index>1?1:index))); }
   ushort            GetMagicID(const uint magic)  const { return ushort(magic&0xFFFF);          }
   uchar             GetGroupID1(const uint magic) const { return uchar(magic>>16)&0x0F;          }
   uchar             GetGroupID2(const uint magic) const { return uchar((magic>>16)&0xF0)>>4;     }
   uchar             GetPendReqID(const uint magic)const { return uchar(magic>>24)&0xFF;           }
                     CBaseObjExt();
  };
#endif // CBASEOBJEXT_MQH_DECLARATION

#ifndef CBASEOBJEXT_MQH_IMPLEMENTATION
#define CBASEOBJEXT_MQH_IMPLEMENTATION

CBaseObjExt::CBaseObjExt() : m_hash_sum(0),m_hash_sum_prev(0),
                              m_is_event(false),m_event_code(WRONG_VALUE),
                              m_long_prop_total(0),m_double_prop_total(0)
  {
   m_type=OBJECT_DE_TYPE_BASE_EXT;
   ::ArrayResize(m_long_prop_event,0,100);
   ::ArrayResize(m_double_prop_event,0,100);
   ::ArrayResize(m_long_prop_event_prev,0,100);
   ::ArrayResize(m_double_prop_event_prev,0,100);
   ::ZeroMemory(m_tick);
   m_digits_currency=(
      #ifdef __MQL5__
         (int)::AccountInfoInteger(ACCOUNT_CURRENCY_DIGITS)
      #else
         2
      #endif
   );
   m_list_events.Clear();       m_list_events.Sort();
   m_list_events_base.Clear();  m_list_events_base.Sort();
  }

void CBaseObjExt::Refresh(void)
  {
   if(!CheckControlDataArraySize() || !CheckControlDataArraySize(false))
      return;
   m_is_event=false;
   m_list_events.Clear();       m_list_events.Sort();
   m_list_events_base.Clear();  m_list_events_base.Sort();
   for(int i=0;i<m_long_prop_total;i++)
      if(!FillPropertySettings(i,m_long_prop_event,m_long_prop_event_prev,m_event_id))
         continue;
   for(int i=0;i<m_double_prop_total;i++)
      if(!FillPropertySettings(i,m_double_prop_event,m_double_prop_event_prev,m_event_id))
         continue;
   if(m_first_start)
     {
      ::ArrayCopy(m_long_prop_event_prev,m_long_prop_event);
      ::ArrayCopy(m_double_prop_event_prev,m_double_prop_event);
      m_hash_sum_prev=m_hash_sum;
      m_first_start=false;
      m_is_event=false;
      m_list_events_base.Clear(); m_list_events_base.Sort();
      return;
     }
  }

template<typename T> bool CBaseObjExt::FillPropertySettings(const int index,T &array[][CONTROLS_TOTAL],T &array_prev[][CONTROLS_TOTAL],int &event_id)
  {
   event_id=index+(typename(T)=="double" ? m_long_prop_total : 0);
   for(int j=5;j<CONTROLS_TOTAL;j++) array[index][j]=false;
   T value=array[index][3]-array_prev[index][3];
   array[index][4]=value;
   if(array[index][0]<LONG_MAX)
     {
      if(value>0 && value>array[index][0])
        {
         if(EventBaseAdd(event_id,BASE_EVENT_REASON_INC,value))
           { array[index][5]=true; array_prev[index][4]=value; }
         array_prev[index][3]=array[index][3];
        }
     }
   if(array[index][1]<LONG_MAX)
     {
      if(value<0 && fabs(value)>array[index][1])
        {
         if(EventBaseAdd(event_id,BASE_EVENT_REASON_DEC,value))
           { array[index][6]=true; array_prev[index][4]=value; }
         array_prev[index][3]=array[index][3];
        }
     }
   if(array[index][2]<LONG_MAX)
     {
      value=array[index][3]-array[index][2];
      if(value>0 && array_prev[index][3]<=array[index][2])
        {
         if(EventBaseAdd(event_id,BASE_EVENT_REASON_MORE_THEN,array[index][2]))
            array[index][7]=true;
         array_prev[index][3]=array[index][3];
        }
      else if(value<0 && array_prev[index][3]>=array[index][2])
        {
         if(EventBaseAdd(event_id,BASE_EVENT_REASON_LESS_THEN,array[index][2]))
            array[index][8]=true;
         array_prev[index][3]=array[index][3];
        }
      else if(value==0 && array_prev[index][3]!=array[index][2])
        {
         if(EventBaseAdd(event_id,BASE_EVENT_REASON_EQUALS,array[index][2]))
            array[index][9]=true;
         array_prev[index][3]=array[index][3];
        }
     }
   return true;
  }

bool CBaseObjExt::SetControlDataArraySizeLong(const int size)
  {
   int x=(#ifdef __MQL4__ CONTROLS_TOTAL #else 1 #endif);
   m_long_prop_total=::ArrayResize(m_long_prop_event,size,100)/x;
   return((::ArrayResize(m_long_prop_event_prev,size,100)/x)==size && m_long_prop_total==size);
  }

bool CBaseObjExt::SetControlDataArraySizeDouble(const int size)
  {
   int x=(#ifdef __MQL4__ CONTROLS_TOTAL #else 1 #endif);
   m_double_prop_total=::ArrayResize(m_double_prop_event,size,100)/x;
   return((::ArrayResize(m_double_prop_event_prev,size,100)/x)==size && m_double_prop_total==size);
  }

bool CBaseObjExt::CheckControlDataArraySize(bool check_long=true)
  {
   string txt1="",txt2="",txt3="",txt4="";
   bool res=true;
   if(check_long)
     { if(m_long_prop_total==0)   { txt1=CMessage::Text(MSG_LIB_TEXT_ARRAY_DATA_INTEGER_NULL); txt2=CMessage::Text(MSG_LIB_TEXT_NEED_SET_INTEGER_VALUE); txt3=CMessage::Text(MSG_LIB_TEXT_TODO_USE_INTEGER_METHOD); txt4=CMessage::Text(MSG_LIB_TEXT_WITH_NUMBER_INTEGER_VALUE); res=false; } }
   else
     { if(m_double_prop_total==0) { txt1=CMessage::Text(MSG_LIB_TEXT_ARRAY_DATA_DOUBLE_NULL);  txt2=CMessage::Text(MSG_LIB_TEXT_NEED_SET_DOUBLE_VALUE);  txt3=CMessage::Text(MSG_LIB_TEXT_TODO_USE_DOUBLE_METHOD);  txt4=CMessage::Text(MSG_LIB_TEXT_WITH_NUMBER_DOUBLE_VALUE);  res=false; } }
   if(res) return true;
   #ifdef __MQL5__
      ::Print(DFUN,"\n",txt1,"\n",txt2,"\n",txt3,"\n",txt4);
   #else
      ::Print(DFUN); ::Print(txt1); ::Print(txt2); ::Print(txt3); ::Print(txt4);
   #endif
   m_global_error=ERR_ZEROSIZE_ARRAY;
   return false;
  }

void CBaseObjExt::ResetControlsParams(void)
  {
   if(!CheckControlDataArraySize(true) || !CheckControlDataArraySize(false)) return;
   for(int i=m_long_prop_total-1;i>WRONG_VALUE;i--)
      for(int j=0;j<3;j++) m_long_prop_event[i][j]=LONG_MAX;
   for(int i=m_double_prop_total-1;i>WRONG_VALUE;i--)
      for(int j=0;j<3;j++) m_double_prop_event[i][j]=(double)LONG_MAX;
  }

void CBaseObjExt::ResetChangesParams(void)
  {
   if(!CheckControlDataArraySize(true) || !CheckControlDataArraySize(false)) return;
   m_list_events.Clear();       m_list_events.Sort();
   m_list_events_base.Clear();  m_list_events_base.Sort();
   for(int i=m_long_prop_total-1;i>WRONG_VALUE;i--)
      for(int j=3;j<CONTROLS_TOTAL;j++) m_long_prop_event[i][j]=0;
   for(int i=m_double_prop_total-1;i>WRONG_VALUE;i--)
      for(int j=3;j<CONTROLS_TOTAL;j++) m_double_prop_event[i][j]=0;
  }

bool CBaseObjExt::EventAdd(const ushort event_id,const long lparam,const double dparam,const string sparam)
  {
   CEventBaseObj *event=new CEventBaseObj(event_id,lparam,dparam,sparam);
   if(event==NULL) return false;
   m_list_events.Sort();
   if(m_list_events.Search(event)>WRONG_VALUE || !m_list_events.Add(event))
     { delete event; return false; }
   return true;
  }

bool CBaseObjExt::EventBaseAdd(const int event_id,const ENUM_BASE_EVENT_REASON reason,const double value)
  {
   CBaseEvent *event=new CBaseEvent(event_id,reason,value);
   if(event==NULL) return false;
   m_list_events_base.Sort();
   if(m_list_events_base.Search(event)>WRONG_VALUE || !m_list_events_base.Add(event))
     { delete event; return false; }
   return true;
  }

CEventBaseObj *CBaseObjExt::GetEvent(const int shift=WRONG_VALUE,const bool check_out=true)
  {
   int total=m_list_events.Total();
   if(total==0 || (!check_out && shift>total-1)) return NULL;
   int index=(shift<=0 ? total-1 : shift>total-1 ? 0 : total-shift-1);
   CEventBaseObj *event=m_list_events.At(index);
   return(event!=NULL ? event : NULL);
  }

CBaseEvent *CBaseObjExt::GetEventBase(const int index)
  {
   int total=m_list_events_base.Total();
   if(total==0 || index<0 || index>total-1) return NULL;
   CBaseEvent *event=m_list_events_base.At(index);
   return(event!=NULL ? event : NULL);
  }

int CBaseObjExt::GetDigits(const double value) const
  {
   string val_str=(string)value;
   int len=::StringLen(val_str);
   int n=len-::StringFind(val_str,".",0)-1;
   if(::StringSubstr(val_str,len-1,1)=="0") n--;
   return n;
  }

template<typename T> void CBaseObjExt::SetControlledValueINC(const int property,const T value)
  {
   if(property<m_long_prop_total) m_long_prop_event[property][0]=(long)value;
   else m_double_prop_event[property-m_long_prop_total][0]=(double)value;
  }

template<typename T> void CBaseObjExt::SetControlledValueDEC(const int property,const T value)
  {
   if(property<m_long_prop_total) m_long_prop_event[property][1]=(long)value;
   else m_double_prop_event[property-m_long_prop_total][1]=(double)value;
  }

template<typename T> void CBaseObjExt::SetControlledValueLEVEL(const int property,const T value)
  {
   if(property<m_long_prop_total) m_long_prop_event[property][2]=(long)value;
   else m_double_prop_event[property-m_long_prop_total][2]=(double)value;
  }

long CBaseObjExt::UshortToLong(const ushort ushort_value,const uchar to_byte,long &long_value)
  {
   if(to_byte>3) { ::Print(DFUN,CMessage::Text(MSG_LIB_SYS_ERROR_INDEX)); return 0; }
   return(long_value|=UshortToByte(ushort_value,to_byte));
  }

long CBaseObjExt::UshortToByte(const ushort value,const uchar to_byte) const
  { return(long)value<<(16*to_byte); }

void CBaseObjExt::CheckEvents(void)
  {
   int total=m_list_events_base.Total();
   if(total==0) return;
   for(int i=0;i<total;i++)
     {
      CBaseEvent *event=GetEventBase(i);
      if(event==NULL) continue;
      long lvalue=0;
      UshortToLong(MSCfromTime(TickTime()),0,lvalue);
      UshortToLong(event.Reason(),1,lvalue);
      UshortToLong((ushort)m_type,2,lvalue);
      if(EventAdd((ushort)event.ID(),lvalue,event.Value(),m_name))
         m_is_event=true;
     }
  }

string CBaseObjExt::EventDescription(const int property,const ENUM_BASE_EVENT_REASON reason,
                                     const int source,const string value,
                                     const string property_descr,const int digits)
  {
   string type=
     (
      Type()==COLLECTION_SYMBOLS_ID   ? CMessage::Text(MSG_LIB_TEXT_SYMBOL)    :
      Type()==COLLECTION_ACCOUNT_ID   ? CMessage::Text(MSG_LIB_TEXT_ACCOUNT)   :
      Type()==COLLECTION_CHARTS_ID    ? CMessage::Text(MSG_LIB_TEXT_CHART)     :
      Type()==COLLECTION_CHART_WND_ID ? CMessage::Text(MSG_LIB_TEXT_CHART_WND) : ""
     );
   string level=
     (
      property<m_long_prop_total ?
      ::DoubleToString(GetControlledLongValueLEVEL(property),digits) :
      ::DoubleToString(GetControlledDoubleValueLEVEL(property),digits)
     );
   string res=
     (
      reason==BASE_EVENT_REASON_INC       ? CMessage::Text(MSG_LIB_TEXT_PROP_VALUE)+type+property_descr+CMessage::Text(MSG_LIB_TEXT_INC_BY)+value     :
      reason==BASE_EVENT_REASON_DEC       ? CMessage::Text(MSG_LIB_TEXT_PROP_VALUE)+type+property_descr+CMessage::Text(MSG_LIB_TEXT_DEC_BY)+value     :
      reason==BASE_EVENT_REASON_MORE_THEN ? CMessage::Text(MSG_LIB_TEXT_PROP_VALUE)+type+property_descr+CMessage::Text(MSG_LIB_TEXT_MORE_THEN)+level  :
      reason==BASE_EVENT_REASON_LESS_THEN ? CMessage::Text(MSG_LIB_TEXT_PROP_VALUE)+type+property_descr+CMessage::Text(MSG_LIB_TEXT_LESS_THEN)+level  :
      reason==BASE_EVENT_REASON_EQUALS    ? CMessage::Text(MSG_LIB_TEXT_PROP_VALUE)+type+property_descr+CMessage::Text(MSG_LIB_TEXT_EQUAL)+level      :
      CMessage::Text(MSG_LIB_TEXT_BASE_OBJ_UNKNOWN_EVENT)+type
     );
   return m_name+": "+res;
  }

#endif // CBASEOBJEXT_MQH_IMPLEMENTATION
#endif // __CBASEOBJEXT_MQH__