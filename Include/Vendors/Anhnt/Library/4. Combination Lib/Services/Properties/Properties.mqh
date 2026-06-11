

//+------------------------------------------------------------------+
//|                                                   Properties.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#property strict    // Necessary for mql4
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Data class of the current and previous properties                |
//+------------------------------------------------------------------+
#ifndef CPROPERTIES_MQH
#define CPROPERTIES_MQH
#ifndef CPROPERTIES_MQH_DECLARATION
#define CPROPERTIES_MQH_DECLARATION
#include <Object.mqh>
#include <Arrays\ArrayObj.mqh>
#include "DataPropObj.mqh"
#include "ChangeHistory.mqh"
#include "..\DELib\GraphicDELib.mqh"
class CProperties : public CObject
  {
private:
   CArrayObj         m_list;  // List for storing the pointers to property objects
public:
   CDataPropObj     *Curr;    // Pointer to the current properties object
   CDataPropObj     *Prev;    // Pointer to the previous properties object
   CChangeHistory   *History; // Pointer to the change history object
//--- Set the array size ('size') in the specified dimension ('range')
   bool              SetSizeRange(const int range,const int size)
                       {
                        return(this.Curr.SetSizeRange(range,size) && this.Prev.SetSizeRange(range,size) ? true : false);
                       }
//--- Return the size of the specified array of the (1) current and (2) previous first dimension data
   int               CurrSize(const int range)  const { return Curr.Size(range); }
   int               PrevSize(const int range)  const { return Prev.Size(range); }
//--- Copy the current data to the previous one
   void              CurrentToPrevious(void)
                       {
                        //--- Copy all integer properties
                        for(int i=0;i<this.Curr.Long().Total();i++)
                           for(int r=0;r<this.Curr.Long().Size(i);r++)
                              this.Prev.Long().Set(i,r,this.Curr.Long().Get(i,r));
                        //--- Copy all real properties
                        for(int i=0;i<this.Curr.Double().Total();i++)
                           for(int r=0;r<this.Curr.Double().Size(i);r++)
                              this.Prev.Double().Set(i,r,this.Curr.Double().Get(i,r));
                        //--- Copy all string properties
                        for(int i=0;i<this.Curr.String().Total();i++)
                           for(int r=0;r<this.Curr.String().Size(i);r++)
                              this.Prev.String().Set(i,r,this.Curr.String().Get(i,r));
                       }
//--- Return the amount of graphical object changes since the start of recording them
   int               TotalChanges(void)   { return this.History.TotalChanges();  }
                       
//--- Constructor
                     CProperties(const int prop_int_total,const int prop_double_total,const int prop_string_total)
                       {
                        //--- Create new objects of the current and previous properties
                        this.Curr=new CDataPropObj(prop_int_total,prop_double_total,prop_string_total);
                        this.Prev=new CDataPropObj(prop_int_total,prop_double_total,prop_string_total);
                        //--- Add newly created objects to the list
                        this.m_list.Add(this.Curr);
                        this.m_list.Add(this.Prev);
                        //--- Create the change history object
                        this.History=new CChangeHistory();
                       }
//--- Destructor
                    ~CProperties()
                       {
                        this.m_list.Clear();
                        this.m_list.Shutdown();
                        if(this.History!=NULL)
                           delete this.History;
                       }
  };
#endif // CPROPERTIES_MQH_DECLARATION
#ifndef CPROPERTIES_MQH_IMPLEMENTATION
#define CPROPERTIES_MQH_IMPLEMENTATION
#endif // CPROPERTIES_MQH_IMPLEMENTATION
#endif // CPROPERTIES_MQH




