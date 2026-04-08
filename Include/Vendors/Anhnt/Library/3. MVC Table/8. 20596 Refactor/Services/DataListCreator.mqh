//+------------------------------------------------------------------+
//|                                            DataListCreator.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//|                                                                  |
//|                           https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| Class for creating lists of data                                 |
//+------------------------------------------------------------------+
#ifndef __DATALIST_CREATOR_MQH__
#define __DATALIST_CREATOR_MQH__
   //+------------------------------------------------------------------+
   // | Included Libraries |
   //+------------------------------------------------------------------+
   #include "..\Tables\MqlParamObj.mqh"
  
   class DataListCreator
   {
   public:
   // --- Adds a new row to the CList list_data
      static CList     *AddNewRowToDataList(CList *list_data)
                        {
                           CList *row=new CList;
                           if(row==NULL || list_data.Add(row)<0)
                              return NULL;
                           return row;
                        }
   // --- Creates a new parameters object CMqlParamObj and adds it to the CList
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
#endif // __DATALIST_CREATOR_MQH__

