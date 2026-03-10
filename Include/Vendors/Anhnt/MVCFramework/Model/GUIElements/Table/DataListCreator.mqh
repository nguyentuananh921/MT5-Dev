//+------------------------------------------------------------------+
//|                                          DataListCreator.mqh     |
//+------------------------------------------------------------------+
//|                    Tables in the MVC Paradigm in MQL5             |
//|                 Customizable and sortable table columns           |
//|                          https://www.mql5.com/en/articles/19979  |
//+------------------------------------------------------------------+
#ifndef DATALISTCREATOR_MQH
#define DATALISTCREATOR_MQH
//+------------------------------------------------------------------+
//| Class for creating data lists                                    |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Table column caption class                                       |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|Include stadard library                                           |
//+------------------------------------------------------------------+
#include <Arrays/List.mqh>
//+------------------------------------------------------------------+
//|Include Custome library                                           |
//+------------------------------------------------------------------+
#include "MqlParamObj.mqh"
class DataListCreator
  {
public:
//--- Adds a new row to the CList list_data
   static CList     *AddNewRowToDataList(CList *list_data)
                       {
                        CList *row=new CList;
                        if(row==NULL || list_data.Add(row)<0)
                           return NULL;
                        return row;
                       }
//--- Creates a new CMqlParamObj parameter object and adds it to CList
   static bool       AddNewCellParamToRow(CList *row,MqlParam &param)
                       {
                        CMqlParamObj *cell=new CMqlParamObj(param);
                        if(cell==NULL)
                           return false;
                        if(row.Add(cell)<0)
                          {
                           delete cell;
                           return false;
                          }
                        return true;
                       }
  };

#endif // DATALISTCREATOR_MQH