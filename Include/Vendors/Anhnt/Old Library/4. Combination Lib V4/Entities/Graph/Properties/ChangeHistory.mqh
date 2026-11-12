//+------------------------------------------------------------------+
//|                                                ChangeHistory.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                             https://mql5.com/en/users/artmedia70 |
//|Link                      https://www.mql5.com/en/articles/10237  |
//|Lib                       https://www.mql5.com/en/articles/14710  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef CCHANGEHISTORY_MQH
#define CCHANGEHISTORY_MQH
 #property strict    // Necessary for mql4
 #include <Arrays\ArrayObj.mqh>
 //+------------------------------------------------------------------+
 //| Include files                                                    |
 //+------------------------------------------------------------------+
  #include "..\..\Defines\GraphDefines.mqh"
  #include "ChangedProps.mqh"
 #ifndef CCHANGEHISTORY_MQH_DECLARATION
 #define CCHANGEHISTORY_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| Class of the history of graphical object property changes        |
 //+------------------------------------------------------------------+
 class CChangeHistory
  {
   private:
     CArrayObj         m_list_changes;                  // List of the property change history

   protected:

   public:
    //--- Constructor/destructor
                     CChangeHistory(void){;}
                    ~CChangeHistory(void){;}

    //--- Return (1) the pointer to the property change history object and (2) the number of changes
     CChangedProps    *GetChangedPropsObj(const string source,const int index);
     int               TotalChanges(void)               { return this.m_list_changes.Total();  }
    //--- Create a new object of the graphical object property change history
     bool              CreateNewElement(CDataPropObj *element,const long time_change);
    //--- Return by index in the list of the graphical object change history object
    //--- the value from the specified index of the (1) long, (2) double and (3) string array
     long              GetLong(const int time_index,const ENUM_GRAPH_OBJ_PROP_INTEGER prop,const int index);
     double            GetDouble(const int time_index,const ENUM_GRAPH_OBJ_PROP_DOUBLE prop,const int index);
     string            GetString(const int time_index,const ENUM_GRAPH_OBJ_PROP_STRING prop,const int index);
  };
 #endif // CCHANGEHISTORY_MQH_DECLARATION
 #ifndef CCHANGEHISTORY_MQH_IMPLEMENTATION
 #define CCHANGEHISTORY_MQH_IMPLEMENTATION
  //+------------------------------------------------------------------+
  //| Return the pointer to the property change history object         |
  //+------------------------------------------------------------------+
  CChangedProps *CChangeHistory::GetChangedPropsObj(const string source,const int index)
   {
      CChangedProps *props=this.m_list_changes.At(index<0 ? 0 : index);
      if(props==NULL)
      CMessage::ToLog(source,MSG_GRAPH_OBJ_FAILED_GET_HIST_OBJ);
      return props;
   }
  //+------------------------------------------------------------------+
  //| Create a new object of the property change history               |
  //+------------------------------------------------------------------+
  bool CChangeHistory::CreateNewElement(CDataPropObj *element,const long time_change)
   {
    //--- Create a new object of the graphical object property snapshot
     CChangedProps *obj=new CChangedProps(element.TotalLong(),element.TotalDouble(),element.TotalString(),time_change);
    //--- If failed to create an object, inform of that and return 'false'
     if(obj==NULL)
      {
       CMessage::ToLog(DFUN,MSG_GRAPH_OBJ_FAILED_CREATE_NEW_HIST_OBJ);
       return false;
      }
    //--- If failed to add the object to the list, inform of that, remove the object and return 'false'
     if(!this.m_list_changes.Add(obj))
      {
       CMessage::ToLog(DFUN,MSG_GRAPH_OBJ_FAILED_ADD_OBJ_TO_HIST_LIST);
       delete obj;
       return false;
      }
    //--- Get the ID of the chart the graphical object is located on
     long chart_id=element.GetLong(GRAPH_OBJ_PROP_CHART_ID,0);
    //--- Set a chart symbol and symbol's Digits for the graphical object property snapshot object
     obj.SetSymbol(::ChartSymbol(chart_id));
     obj.SetDigits((int)::SymbolInfoInteger(obj.Symbol(),SYMBOL_DIGITS));
    //--- Copy all integer properties
     for(int i=0;i<element.TotalLong();i++)
      {
       int total=element.Long().Size(i);
       if(obj.SetSizeRange(i,total))
        {
         for(int r=0;r<total;r++)
            obj.Long().Set(i,r,element.Long().Get(i,r));
        }
       else
         CMessage::ToLog(DFUN,MSG_GRAPH_OBJ_FAILED_INC_ARRAY_SIZE);
      }
    //--- Copy all real properties
     for(int i=0;i<element.TotalDouble();i++)
      {
       int total=element.Double().Size(i);
       if(obj.Double().SetSizeRange(i,total))
        {
         for(int r=0;r<total;r++)
            obj.Double().Set(i,r,element.Double().Get(i,r));
        }
       else
         CMessage::ToLog(DFUN,MSG_GRAPH_OBJ_FAILED_INC_ARRAY_SIZE);
      }
    //--- Copy all string properties
     for(int i=0;i<element.TotalString();i++)
      {
       int total=element.String().Size(i);
       if(obj.String().SetSizeRange(i,total))
        {
         for(int r=0;r<total;r++)
            obj.String().Set(i,r,element.String().Get(i,r));
        }
       else
         CMessage::ToLog(DFUN,MSG_GRAPH_OBJ_FAILED_INC_ARRAY_SIZE);
      }
    return true;
   }
  //+------------------------------------------------------------------+
  //| Return by index the value of the long array                      |
  //+------------------------------------------------------------------+
  long CChangeHistory::GetLong(const int time_index,const ENUM_GRAPH_OBJ_PROP_INTEGER prop,const int index)
   {
    CChangedProps *properties=this.GetChangedPropsObj(DFUN,time_index);
    if(properties==NULL)
      return 0;
    return properties.GetLong(prop,index);
   }
  //+------------------------------------------------------------------+
  //| Return by index the value of the double array                    |
  //+------------------------------------------------------------------+
  double CChangeHistory::GetDouble(const int time_index,const ENUM_GRAPH_OBJ_PROP_DOUBLE prop,const int index)
   {
    CChangedProps *properties=this.GetChangedPropsObj(DFUN,time_index);
    if(properties==NULL)
      return 0;
    return properties.GetDouble(prop,index);
   }
  //+------------------------------------------------------------------+
  //| Return by index the value of the string array                    |
  //+------------------------------------------------------------------+
  string CChangeHistory::GetString(const int time_index,const ENUM_GRAPH_OBJ_PROP_STRING prop,const int index)
   {
    CChangedProps *properties=this.GetChangedPropsObj(DFUN,time_index);
    if(properties==NULL)
      return "";
    return properties.GetString(prop,index);
   }
 #endif // CCHANGEHISTORY_MQH_IMPLEMENTATION
#endif // CCHANGEHISTORY_MQH
