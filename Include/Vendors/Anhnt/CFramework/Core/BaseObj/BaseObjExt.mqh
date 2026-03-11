//+------------------------------------------------------------------+
//|                                                   BaseObjExt.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Software Corp."
#property link      "nguyentuananh921@gmail.com"
#property version   "1.00"
#property strict    // Necessary for mql4
//+------------------------------------------------------------------+
//| Include files                                                    |
//+------------------------------------------------------------------+
#include <Arrays\ArrayObj.mqh>
/*
#include "..\Services\DELib.mqh"
#include "..\Objects\Graph\GraphElmControl.mqh"
*/

#include <Vendors/Anhnt/CFramework/Core/BaseObj/BaseObj.mqh>
#include <Vendors/Anhnt/CFramework/Core/BaseObj/EventBaseObj.mqh>

#include <Vendors/Anhnt/CFramework/Old/Services/DELib.mqh>
#include <Vendors/Anhnt/CFramework/Core/BaseGraph/GraphElmControl.mqh>
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Extended base object class for all library objects               |
//+------------------------------------------------------------------+
#define  CONTROLS_TOTAL    (10)
class CBaseObjExt : public CBaseObj
  {
private:
   int               m_long_prop_total;
   int               m_double_prop_total;
   //--- Fill in the object property array
   template<typename T> bool  FillPropertySettings(const int index,T &array[][CONTROLS_TOTAL],T &array_prev[][CONTROLS_TOTAL],int &event_id);
protected:
   CArrayObj         m_list_events_base;                       // Object base event list
   CArrayObj         m_list_events;                            // Object event list
   MqlTick           m_tick;                                   // Tick structure for receiving quote data
   double            m_hash_sum;                               // Object data hash sum
   double            m_hash_sum_prev;                          // Object data hash sum during the previous check
   int               m_digits_currency;                        // Number of decimal places in an account currency
   bool              m_is_event;                               // Object event flag
   int               m_event_code;                             // Object event code
   int               m_event_id;                               // Event ID (equal to the object property value)

//--- Data for storing, controlling and returning tracked properties:
//--- [Property index][0] Controlled property increase value
//--- [Property index][1] Controlled property decrease value
//--- [Property index][2] Controlled property value level
//--- [Property index][3] Property value
//--- [Property index][4] Property value change
//--- [Property index][5] Flag of a property change exceeding the increase value
//--- [Property index][6] Flag of a property change exceeding the decrease value
//--- [Property index][7] Flag of a property increase exceeding the control level
//--- [Property index][8] Flag of a property decrease being less than the control level
//--- [Property index][9] Flag of a property value being equal to the control level
   long              m_long_prop_event[][CONTROLS_TOTAL];         // The array for storing object's integer properties values and controlled property change values
   double            m_double_prop_event[][CONTROLS_TOTAL];       // The array for storing object's real properties values and controlled property change values
   long              m_long_prop_event_prev[][CONTROLS_TOTAL];    // The array for storing object's controlled integer properties values during the previous check
   double            m_double_prop_event_prev[][CONTROLS_TOTAL];  // The array for storing object's controlled real properties values during the previous check

//--- Return (1) time in milliseconds, (2) milliseconds from the MqlTick time value
   long              TickTime(void)                            const { return #ifdef __MQL5__ this.m_tick.time_msc #else this.m_tick.time*1000 #endif ;  }
   ushort            MSCfromTime(const long time_msc)          const { return #ifdef __MQL5__ ushort(this.TickTime()%1000) #else 0 #endif ;              }
//--- return the flag of the event code presence in the event object
   bool              IsPresentEventFlag(const int change_code) const { return (this.m_event_code & change_code)==change_code; }
//--- Return the number of decimal places of the account currency
   int               DigitsCurrency(void)                      const { return this.m_digits_currency; }
//--- Returns the number of decimal places in the 'double' value
   int               GetDigits(const double value)             const;

//--- Set the size of the array of controlled (1) integer and (2) real object properties
   bool              SetControlDataArraySizeLong(const int size);
   bool              SetControlDataArraySizeDouble(const int size);
//--- Check the array size of object properties
   bool              CheckControlDataArraySize(bool check_long=true);
   
//--- Check the list of object property changes and create an event
   void              CheckEvents(void);
   
//--- (1) Pack a 'ushort' number to a passed 'long' number
   long              UshortToLong(const ushort ushort_value,const uchar to_byte,long &long_value);
   
protected:
//--- (1) convert a 'ushort' value to a specified 'long' number byte
   long              UshortToByte(const ushort value,const uchar to_byte)  const;
   
public:
//--- Set the value of the pbject property controlled (1) increase, (2) decrease, (3) control level
   template<typename T> void  SetControlledValueINC(const int property,const T value);
   template<typename T> void  SetControlledValueDEC(const int property,const T value);
   template<typename T> void  SetControlledValueLEVEL(const int property,const T value);

//--- Return the set value of the controlled (1) integer and (2) real object properties increase
   long              GetControlledLongValueINC(const int property)      const { return this.m_long_prop_event[property][0];                           }
   double            GetControlledDoubleValueINC(const int property)    const { return this.m_double_prop_event[property-this.m_long_prop_total][0];  }
//--- Return the set value of the controlled (1) integer and (2) real object properties decrease
   long              GetControlledLongValueDEC(const int property)      const { return this.m_long_prop_event[property][1];                           }
   double            GetControlledDoubleValueDEC(const int property)    const { return this.m_double_prop_event[property-this.m_long_prop_total][1];  }
//--- Return the specified control level of object's (1) integer and (2) real properties
   long              GetControlledLongValueLEVEL(const int property)    const { return this.m_long_prop_event[property][2];                           }
   double            GetControlledDoubleValueLEVEL(const int property)  const { return this.m_double_prop_event[property-this.m_long_prop_total][2];  }

//--- Return the current value of the object (1) integer and (2) real property
   long              GetPropLongValue(const int property)               const { return this.m_long_prop_event[property][3];                           }
   double            GetPropDoubleValue(const int property)             const { return this.m_double_prop_event[property-this.m_long_prop_total][3];  }
//--- Return the change value of the controlled (1) integer and (2) real object property
   long              GetPropLongChangedValue(const int property)        const { return this.m_long_prop_event[property][4];                           }
   double            GetPropDoubleChangedValue(const int property)      const { return this.m_double_prop_event[property-this.m_long_prop_total][4];  }
//--- Return the flag of an (1) integer and (2) real property value change exceeding the increase value
   long              GetPropLongFlagINC(const int property)             const { return this.m_long_prop_event[property][5];                           }
   double            GetPropDoubleFlagINC(const int property)           const { return this.m_double_prop_event[property-this.m_long_prop_total][5];  }
//--- Return the flag of an (1) integer and (2) real property value change exceeding the decrease value
   long              GetPropLongFlagDEC(const int property)             const { return this.m_long_prop_event[property][6];                           }
   double            GetPropDoubleFlagDEC(const int property)           const { return this.m_double_prop_event[property-this.m_long_prop_total][6];  }
//--- Return the flag of an (1) integer and (2) real property value increase exceeding the control level
   long              GetPropLongFlagMORE(const int property)            const { return this.m_long_prop_event[property][7];                           }
   double            GetPropDoubleFlagMORE(const int property)          const { return this.m_double_prop_event[property-this.m_long_prop_total][7];  }
//--- Return the flag of an (1) integer and (2) real property value decrease being less than the control level
   long              GetPropLongFlagLESS(const int property)            const { return this.m_long_prop_event[property][8];                           }
   double            GetPropDoubleFlagLESS(const int property)          const { return this.m_double_prop_event[property-this.m_long_prop_total][8];  }
//--- Return the flag of an (1) integer and (2) real property being equal to the control level
   long              GetPropLongFlagEQUAL(const int property)           const { return this.m_long_prop_event[property][9];                           }
   double            GetPropDoubleFlagEQUAL(const int property)         const { return this.m_double_prop_event[property-this.m_long_prop_total][9];  }

//--- Reset the variables of (1) tracked and (2) controlled object data (can be reset in the descendants)
   void              ResetChangesParams(void);
   virtual void      ResetControlsParams(void);
//--- Add the (1) object event and (2) the object event reason to the list
   bool              EventAdd(const ushort event_id,const long lparam,const double dparam,const string sparam);
   bool              EventBaseAdd(const int event_id,const ENUM_BASE_EVENT_REASON reason,const double value);
//--- Set/return the occurred event flag to the object data
   void              SetEventFlag(const bool flag)                   { this.m_is_event=flag;                   }
   bool              IsEvent(void)                             const { return this.m_is_event;                 }
//--- Return (1) the list of events and (2) the object event code
   CArrayObj        *GetListEvents(void)                             { return &this.m_list_events;             }
   int               GetEventCode(void)                        const { return this.m_event_code;               }
//--- Return (1) an event object and (2) a base event by its number in the list
   CEventBaseObj    *GetEvent(const int shift=WRONG_VALUE,const bool check_out=true);
   CBaseEvent       *GetEventBase(const int index);
//--- Return the number of (1) object events
   int               GetEventsTotal(void)                      const { return this.m_list_events.Total();      }
//--- Update the object data to search for changes (Calling from the descendants: CBaseObj::Refresh())
   virtual void      Refresh(void);
//--- Return an object event description
   string            EventDescription(const int property,
                                      const ENUM_BASE_EVENT_REASON reason,
                                      const int source,
                                      const string value,
                                      const string property_descr,
                                      const int digits);

//--- Data location in the magic number int value
      //-----------------------------------------------------------
      //  bit   32|31       24|23       16|15        8|7         0|
      //-----------------------------------------------------------
      //  byte    |     3     |     2     |     1     |     0     |
      //-----------------------------------------------------------
      //  data    |   uchar   |   uchar   |         ushort        |
      //-----------------------------------------------------------
      //  descr   |pend req id| id2 | id1 |          magic        |
      //-----------------------------------------------------------
      
//--- Set the ID of the (1) first group, (2) second group, (3) pending request to the magic number value
   void              SetGroupID1(const uchar group,uint &magic)            { magic &=0xFFF0FFFF; magic |= uint(this.ConvToXX(group,0)<<16);  }
   void              SetGroupID2(const uchar group,uint &magic)            { magic &=0xFF0FFFFF; magic |= uint(this.ConvToXX(group,1)<<16);  }
   void              SetPendReqID(const uchar id,uint &magic)              { magic &=0x00FFFFFF; magic |= (uint)id<<24;                      }
//--- Convert the value of 0 - 15 into the necessary uchar number bits (0 - lower, 1 - upper ones)
   uchar             ConvToXX(const uchar number,const uchar index)  const { return((number>15 ? 15 : number)<<(4*(index>1 ? 1 : index)));   }
//--- Return (1) the specified magic number, the ID of (2) the first group, (3) second group, (4) pending request from the magic number value
   ushort            GetMagicID(const uint magic)                    const { return ushort(magic & 0xFFFF);                                  }
   uchar             GetGroupID1(const uint magic)                   const { return uchar(magic>>16) & 0x0F;                                 }
   uchar             GetGroupID2(const uint magic)                   const { return uchar((magic>>16) & 0xF0)>>4;                            }
   uchar             GetPendReqID(const uint magic)                  const { return uchar(magic>>24) & 0xFF;                                 }

//--- Constructor
                     CBaseObjExt();
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CBaseObjExt::CBaseObjExt() : m_hash_sum(0),m_hash_sum_prev(0),
                             m_is_event(false),m_event_code(WRONG_VALUE),
                             m_long_prop_total(0),
                             m_double_prop_total(0)
  {
   this.m_type=OBJECT_DE_TYPE_BASE_EXT;
   ::ArrayResize(this.m_long_prop_event,0,100);
   ::ArrayResize(this.m_double_prop_event,0,100);
   ::ArrayResize(this.m_long_prop_event_prev,0,100);
   ::ArrayResize(this.m_double_prop_event_prev,0,100);
   ::ZeroMemory(this.m_tick);
   this.m_digits_currency=(#ifdef __MQL5__ (int)::AccountInfoInteger(ACCOUNT_CURRENCY_DIGITS) #else 2 #endif);
   this.m_list_events.Clear();
   this.m_list_events.Sort();
   this.m_list_events_base.Clear();
   this.m_list_events_base.Sort();
  }
//+------------------------------------------------------------------+
//| Update the object data to search changes in them                 |
//| Call from descendants: CBaseObj::Refresh()                       |
//+------------------------------------------------------------------+
void CBaseObjExt::Refresh(void)
  {
//--- Check the size of the arrays, Exit if it is zero
   if(!this.CheckControlDataArraySize() || !this.CheckControlDataArraySize(false))
      return;
//--- Reset the event flag and clear all lists
   this.m_is_event=false;
   this.m_list_events.Clear();
   this.m_list_events.Sort();
   this.m_list_events_base.Clear();
   this.m_list_events_base.Sort();
//--- Fill in the array of integer properties and control their changes
   for(int i=0;i<this.m_long_prop_total;i++)
      if(!this.FillPropertySettings(i,this.m_long_prop_event,this.m_long_prop_event_prev,this.m_event_id))
         continue;
//--- Fill in the array of real properties and control their changes
   for(int i=0;i<this.m_double_prop_total;i++)
      if(!this.FillPropertySettings(i,this.m_double_prop_event,this.m_double_prop_event_prev,this.m_event_id))
         continue;
//--- First launch
   if(this.m_first_start)
     {
      ::ArrayCopy(this.m_long_prop_event_prev,this.m_long_prop_event);
      ::ArrayCopy(this.m_double_prop_event_prev,this.m_double_prop_event);
      this.m_hash_sum_prev=this.m_hash_sum;
      this.m_first_start=false;
      this.m_is_event=false;
      this.m_list_events_base.Clear();
      this.m_list_events_base.Sort();
      return;
     }
  }
//+------------------------------------------------------------------+
//| Fill in the object property array                                |
//+------------------------------------------------------------------+
template<typename T> bool CBaseObjExt::FillPropertySettings(const int index,T &array[][CONTROLS_TOTAL],T &array_prev[][CONTROLS_TOTAL],int &event_id)
  {
   //--- Data in the array cells
   //--- [Property index][0] Controlled property increase value
   //--- [Property index][1] Controlled property decrease value
   //--- [Property index][2] Controlled property value level
   //--- [Property index][3] Property value
   //--- [Property index][4] Property value change
   //--- [Property index][5] Flag of a property change exceeding the increase value
   //--- [Property index][6] Flag of a property change exceeding the decrease value
   //--- [Property index][7] Flag of a property increase exceeding the control level
   //--- [Property index][8] Flag of a property decrease being less than the control level
   //--- [Property index][9] Flag of a property value being equal to the control level
   
   //--- Set the shift of the 'double' property index and the event ID
   event_id=index+(typename(T)=="double" ? this.m_long_prop_total : 0);
   //--- Reset all event flags
   for(int j=5;j<CONTROLS_TOTAL;j++)
      array[index][j]=false;
   //--- Property change value
   T value=array[index][3]-array_prev[index][3];
   array[index][4]=value;
   //--- If the controlled property increase value is set
   if(array[index][0]<LONG_MAX)
     {
      //--- If the property change value exceeds the controlled increase value - there is an event,
      //--- add the event to the list, set the flag and save the new property value size
      if(value>0 && value>array[index][0])
        {
         if(this.EventBaseAdd(event_id,BASE_EVENT_REASON_INC,value))
           {
            array[index][5]=true;
            array_prev[index][4]=value;
           }
         //--- Save the current property value as a previous one
         array_prev[index][3]=array[index][3];
        }
     }
   //--- If the controlled property decrease value is set
   if(array[index][1]<LONG_MAX)
     {
      //--- If the property change value exceeds the controlled decrease value - there is an event,
      //--- add the event to the list, set the flag and save the new property value size
      if(value<0 && fabs(value)>array[index][1])
        {
         if(this.EventBaseAdd(event_id,BASE_EVENT_REASON_DEC,value))
           {
            array[index][6]=true;
            array_prev[index][4]=value;
           }
         //--- Save the current property value as a previous one
         array_prev[index][3]=array[index][3];
        }
     }
   //--- If the controlled level value is set
   if(array[index][2]<LONG_MAX)
     {
      value=array[index][3]-array[index][2];
      //--- If a property value exceeds the control level, there is an event
      //--- add the event to the list and set the flag
      if(value>0 && array_prev[index][3]<=array[index][2])
        {
         if(this.EventBaseAdd(event_id,BASE_EVENT_REASON_MORE_THEN,array[index][2]))
            array[index][7]=true;
         //--- Save the current property value as a previous one
         array_prev[index][3]=array[index][3];
        }
      //--- If a property value is less than the control level, there is an event,
      //--- add the event to the list and set the flag
      else if(value<0 && array_prev[index][3]>=array[index][2])
        {
         if(this.EventBaseAdd(event_id,BASE_EVENT_REASON_LESS_THEN,array[index][2]))
            array[index][8]=true;
         //--- Save the current property value as a previous one
         array_prev[index][3]=array[index][3];
        }
      //--- If a property value is equal to the control level, there is an event,
      //--- add the event to the list and set the flag
      else if(value==0 && array_prev[index][3]!=array[index][2])
        {
         if(this.EventBaseAdd(event_id,BASE_EVENT_REASON_EQUALS,array[index][2]))
            array[index][9]=true;
         //--- Save the current property value as a previous one
         array_prev[index][3]=array[index][3];
        }
     }
   return true;
  }
//+------------------------------------------------------------------+
//| Set the size of the arrays of the object integer properties      |
//+------------------------------------------------------------------+
bool CBaseObjExt::SetControlDataArraySizeLong(const int size)
  {
   int x=(#ifdef __MQL4__ CONTROLS_TOTAL #else 1 #endif );
   this.m_long_prop_total=::ArrayResize(this.m_long_prop_event,size,100)/x;
   return((::ArrayResize(this.m_long_prop_event_prev,size,100)/x)==size && this.m_long_prop_total==size ? true : false);
  }
//+------------------------------------------------------------------+
//| Set the size of the arrays of the object real properties         |
//+------------------------------------------------------------------+
bool CBaseObjExt::SetControlDataArraySizeDouble(const int size)
  {
   int x=(#ifdef __MQL4__ CONTROLS_TOTAL #else 1 #endif );
   this.m_double_prop_total=::ArrayResize(this.m_double_prop_event,size,100)/x;
   return((::ArrayResize(this.m_double_prop_event_prev,size,100)/x)==size && this.m_double_prop_total==size ? true : false);
  }
//+------------------------------------------------------------------+
//| Check the array size of object properties                        |
//+------------------------------------------------------------------+
bool CBaseObjExt::CheckControlDataArraySize(bool check_long=true)
  {
   string txt1="";
   string txt2="";
   string txt3="";
   string txt4="";
   bool res=true;
   if(check_long)
     {
      if(this.m_long_prop_total==0)
        {
         txt1=CMessage::Text(MSG_LIB_TEXT_ARRAY_DATA_INTEGER_NULL);
         txt2=CMessage::Text(MSG_LIB_TEXT_NEED_SET_INTEGER_VALUE);
         txt3=CMessage::Text(MSG_LIB_TEXT_TODO_USE_INTEGER_METHOD);
         txt4=CMessage::Text(MSG_LIB_TEXT_WITH_NUMBER_INTEGER_VALUE);
         res=false;
        }
     }
   else
     {
      if(this.m_double_prop_total==0)
        {
         txt1=CMessage::Text(MSG_LIB_TEXT_ARRAY_DATA_DOUBLE_NULL);
         txt2=CMessage::Text(MSG_LIB_TEXT_NEED_SET_DOUBLE_VALUE);
         txt3=CMessage::Text(MSG_LIB_TEXT_TODO_USE_DOUBLE_METHOD);
         txt4=CMessage::Text(MSG_LIB_TEXT_WITH_NUMBER_DOUBLE_VALUE);
         res=false;
        }
     }
   if(res)
      return true;
   #ifdef __MQL5__ 
      ::Print(DFUN,"\n",txt1,"\n",txt2,"\n",txt3,"\n",txt4);
   #else 
      ::Print(DFUN);
      ::Print(txt1);
      ::Print(txt2);
      ::Print(txt3);
      ::Print(txt4);
   #endif 
   this.m_global_error=ERR_ZEROSIZE_ARRAY;
   return false;
  }
//+------------------------------------------------------------------+
//| Reset the variables of controlled object data values             |
//+------------------------------------------------------------------+
void CBaseObjExt::ResetControlsParams(void)
  {
   if(!this.CheckControlDataArraySize(true) || !this.CheckControlDataArraySize(false))
      return;
//--- Data in the array cells
//--- [Property index][0] Controlled property increase value
//--- [Property index][1] Controlled property decrease value
//--- [Property index][2] Controlled property value level
   for(int i=this.m_long_prop_total-1;i>WRONG_VALUE;i--)
      for(int j=0; j<3; j++)
         this.m_long_prop_event[i][j]=LONG_MAX;
   for(int i=this.m_double_prop_total-1;i>WRONG_VALUE;i--)
      for(int j=0; j<3; j++)
         this.m_double_prop_event[i][j]=(double)LONG_MAX;
  }
//+------------------------------------------------------------------+
//| Reset the variables of tracked object data                       |
//+------------------------------------------------------------------+
void CBaseObjExt::ResetChangesParams(void)
  {
   if(!this.CheckControlDataArraySize(true) || !this.CheckControlDataArraySize(false))
      return;
   this.m_list_events.Clear();
   this.m_list_events.Sort();
   this.m_list_events_base.Clear();
   this.m_list_events_base.Sort();
//--- Data in the array cells
//--- [Property index][3] Property value
//--- [Property index][4] Property value change
//--- [Property index][5] Flag of a property change exceeding the increase value
//--- [Property index][6] Flag of a property change exceeding the decrease value
//--- [Property index][7] Flag of a property increase exceeding the control level
//--- [Property index][8] Flag of a property decrease being less than the control level
//--- [Property index][9] Flag of a property value being equal to the controlled value
   for(int i=this.m_long_prop_total-1;i>WRONG_VALUE;i--)
      for(int j=3; j<CONTROLS_TOTAL; j++)
         this.m_long_prop_event[i][j]=0;
   for(int i=this.m_double_prop_total-1;i>WRONG_VALUE;i--)
      for(int j=3; j<CONTROLS_TOTAL; j++)
         this.m_double_prop_event[i][j]=0;
  }
//+------------------------------------------------------------------+
//| Add the event object to the list                                 |
//+------------------------------------------------------------------+
bool CBaseObjExt::EventAdd(const ushort event_id,const long lparam,const double dparam,const string sparam)
  {
   CEventBaseObj *event=new CEventBaseObj(event_id,lparam,dparam,sparam);
   if(event==NULL)
      return false;
   this.m_list_events.Sort();
   if(this.m_list_events.Search(event)>WRONG_VALUE)
     {
      delete event;
      return false;
     }
   return this.m_list_events.Add(event);
  }
//+------------------------------------------------------------------+
//| Add the object base event to the list                            |
//+------------------------------------------------------------------+
bool CBaseObjExt::EventBaseAdd(const int event_id,const ENUM_BASE_EVENT_REASON reason,const double value)
  {
   CBaseEvent* event=new CBaseEvent(event_id,reason,value);
   if(event==NULL)
      return false;
   this.m_list_events_base.Sort();
   if(this.m_list_events_base.Search(event)>WRONG_VALUE)
     {
      delete event;
      return false;
     }
   return this.m_list_events_base.Add(event);
  }
//+------------------------------------------------------------------+
//| Return the object event by its index in the list                 |
//+------------------------------------------------------------------+
CEventBaseObj *CBaseObjExt::GetEvent(const int shift=WRONG_VALUE,const bool check_out=true)
  {
   int total=this.m_list_events.Total();
   if(total==0 || (!check_out && shift>total-1))
      return NULL;   
   int index=(shift<=0 ? total-1 : shift>total-1 ? 0 : total-shift-1);
   CEventBaseObj *event=this.m_list_events.At(index);
   return(event!=NULL ? event : NULL);
  }
//+------------------------------------------------------------------+
//| Return a base event by its index in the list                     |
//+------------------------------------------------------------------+
CBaseEvent *CBaseObjExt::GetEventBase(const int index)
  {
   int total=this.m_list_events_base.Total();
   if(total==0 || index<0 || index>total-1)
      return NULL;
   CBaseEvent *event=this.m_list_events_base.At(index);
   return(event!=NULL ? event : NULL);
  }
//+------------------------------------------------------------------+
//| Return the number of decimal places in the 'double' value        |
//+------------------------------------------------------------------+
int CBaseObjExt::GetDigits(const double value) const
  {
   string val_str=(string)value;
   int len=::StringLen(val_str);
   int n=len-::StringFind(val_str,".",0)-1;
   if(::StringSubstr(val_str,len-1,1)=="0")
      n--;
   return n;
  }
//+------------------------------------------------------------------+
//| Methods of setting descendant object controlled parameters       |
//+------------------------------------------------------------------+
//--- Data for storing, controlling and returning tracked properties:
//--- [Property index][0] Controlled property increase value
//--- [Property index][1] Controlled property decrease value
//--- [Property index][2] Controlled property value level
//--- [Property index][3] Property value
//--- [Property index][4] Property value change
//--- [Property index][5] Flag of a property change exceeding the increase value
//--- [Property index][6] Flag of a property change exceeding the decrease value
//--- [Property index][7] Flag of a property increase exceeding the control level
//--- [Property index][8] Flag of a property decrease being less than the control level
//--- [Property index][9] Flag of a property value being equal to the control level
//+------------------------------------------------------------------+
//| Set the value of the controlled increase of object properties    |
//+------------------------------------------------------------------+
template<typename T> void CBaseObjExt::SetControlledValueINC(const int property,const T value)
  {
   if(property<this.m_long_prop_total)
      this.m_long_prop_event[property][0]=(long)value;
   else
      this.m_double_prop_event[property-this.m_long_prop_total][0]=(double)value;
  }  
//+------------------------------------------------------------------+
//| Set the value of the controlled decrease of object properties    |
//+------------------------------------------------------------------+
template<typename T> void CBaseObjExt::SetControlledValueDEC(const int property,const T value)
  {
   if(property<this.m_long_prop_total)
      this.m_long_prop_event[property][1]=(long)value;
   else
      this.m_double_prop_event[property-this.m_long_prop_total][1]=(double)value;
  }  
//+------------------------------------------------------------------+
//| Set the control level of object properties                       |
//+------------------------------------------------------------------+
template<typename T> void CBaseObjExt::SetControlledValueLEVEL(const int property,const T value)
  {
   if(property<this.m_long_prop_total)
      this.m_long_prop_event[property][2]=(long)value;
   else
      this.m_double_prop_event[property-this.m_long_prop_total][2]=(double)value;
  }
//+------------------------------------------------------------------+
//| Pack a 'ushort' number to a passed 'long' number                 |
//+------------------------------------------------------------------+
long CBaseObjExt::UshortToLong(const ushort ushort_value,const uchar to_byte,long &long_value)
  {
   if(to_byte>3)
     {
      ::Print(DFUN,CMessage::Text(MSG_LIB_SYS_ERROR_INDEX));
      return 0;
     }
   return(long_value |= this.UshortToByte(ushort_value,to_byte));
  }
//+------------------------------------------------------------------+
//| Convert a 'ushort' value to a specified 'long' number byte       |
//+------------------------------------------------------------------+
long CBaseObjExt::UshortToByte(const ushort value,const uchar to_byte) const
  {
   return(long)value<<(16*to_byte);
  }
//+------------------------------------------------------------------+
//| Check the list of object property changes and create an event    |
//+------------------------------------------------------------------+
void CBaseObjExt::CheckEvents(void)
  {
   int total=this.m_list_events_base.Total();
   if(total==0)
      return;
   
   for(int i=0;i<total;i++)
     {
      CBaseEvent *event=this.GetEventBase(i);
      if(event==NULL)
         continue;
      long lvalue=0;
      this.UshortToLong(this.MSCfromTime(this.TickTime()),0,lvalue);
      this.UshortToLong(event.Reason(),1,lvalue);
      this.UshortToLong((ushort)this.m_type,2,lvalue);
      if(this.EventAdd((ushort)event.ID(),lvalue,event.Value(),this.m_name))
         this.m_is_event=true;
     }
  }  
//+------------------------------------------------------------------+
//| Return an object event description                               |
//+------------------------------------------------------------------+
string CBaseObjExt::EventDescription(const int property,
                                  const ENUM_BASE_EVENT_REASON reason,
                                  const int source,
                                  const string value,
                                  const string property_descr,
                                  const int digits)
  {
//--- Depending on the collection ID, create th object type description
   string type=
     (
      this.Type()==COLLECTION_SYMBOLS_ID     ? CMessage::Text(MSG_LIB_TEXT_SYMBOL)     :
      this.Type()==COLLECTION_ACCOUNT_ID     ?  CMessage::Text(MSG_LIB_TEXT_ACCOUNT)   :
      this.Type()==COLLECTION_CHARTS_ID      ?  CMessage::Text(MSG_LIB_TEXT_CHART)     :
      this.Type()==COLLECTION_CHART_WND_ID   ?  CMessage::Text(MSG_LIB_TEXT_CHART_WND) :
      ""
     );
//--- Depending on the property type, create the property change value description
   string level=
     (
      property<this.m_long_prop_total ? 
      ::DoubleToString(this.GetControlledLongValueLEVEL(property),digits) :
      ::DoubleToString(this.GetControlledDoubleValueLEVEL(property),digits)
     );
//--- Depending on the event reason, create the event description text
   string res=
     (
      reason==BASE_EVENT_REASON_INC       ?  CMessage::Text(MSG_LIB_TEXT_PROP_VALUE)+type+property_descr+CMessage::Text(MSG_LIB_TEXT_INC_BY)+value    :
      reason==BASE_EVENT_REASON_DEC       ?  CMessage::Text(MSG_LIB_TEXT_PROP_VALUE)+type+property_descr+CMessage::Text(MSG_LIB_TEXT_DEC_BY)+value    :
      reason==BASE_EVENT_REASON_MORE_THEN ?  CMessage::Text(MSG_LIB_TEXT_PROP_VALUE)+type+property_descr+CMessage::Text(MSG_LIB_TEXT_MORE_THEN)+level :
      reason==BASE_EVENT_REASON_LESS_THEN ?  CMessage::Text(MSG_LIB_TEXT_PROP_VALUE)+type+property_descr+CMessage::Text(MSG_LIB_TEXT_LESS_THEN)+level :
      reason==BASE_EVENT_REASON_EQUALS    ?  CMessage::Text(MSG_LIB_TEXT_PROP_VALUE)+type+property_descr+CMessage::Text(MSG_LIB_TEXT_EQUAL)+level     :
      CMessage::Text(MSG_LIB_TEXT_BASE_OBJ_UNKNOWN_EVENT)+type
     );
//--- Return the object name+created event description text
   return this.m_name+": "+res;
  }
//+------------------------------------------------------------------+