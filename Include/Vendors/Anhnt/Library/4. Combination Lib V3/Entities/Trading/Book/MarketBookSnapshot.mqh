//+------------------------------------------------------------------+
//|                                           MarketBookSnapshot.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//|Link                       https://www.mql5.com/en/articles/9146  |
//|Lib                       https://www.mql5.com/en/articles/14710  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#ifndef __MARKETBOOKSNAPSHOT_MQH__
#define __MARKETBOOKSNAPSHOT_MQH__
#property strict    // Necessary for mql4
//+------------------------------------------------------------------+
//| Include files                                                    |
//+------------------------------------------------------------------+
 #include <Arrays\ArrayObj.mqh>
 #include "..\..\Defines\CommonDefines.mqh"
 #include "..\..\..\Services\DELib\CommonDELib.mqh" 
 #include "MarketBook\MarketBookBuy.mqh"
 #include "MarketBook\MarketBookSell.mqh"
 #include "MarketBook\MarketBookBuyMarket.mqh"
 #include "MarketBook\MarketBookSellMarket.mqh"
#ifndef CMARKETBOOKSNAPSHOT_MQH_DECLARATION
#define CMARKETBOOKSNAPSHOT_MQH_DECLARATION
 //+------------------------------------------------------------------+
 //| "DOM snapshot" class                                             |
 //+------------------------------------------------------------------+
 class CMBookSnapshot : public CBaseObj
  {
   private:
    string            m_symbol;                  // Symbol
    long              m_time;                    // Snapshot time
    int               m_digits;                  // Symbol's Digits
    long              m_volume_buy;              // DOM buy volume
    long              m_volume_sell;             // DOM sell volume
    double            m_volume_buy_real;         // DOM buy volume with an increased accuracy
    double            m_volume_sell_real;        // DOM sell volume with an increased accuracy
    CArrayObj         m_list;                    // List of DOM order objects
   public:
   //--- Return (1) itself and (2) the list of DOM order objects
    CMBookSnapshot   *GetObject(void)                                    { return &this;   }
    CArrayObj        *GetList(void)                                      { return &m_list; }

   //--- (1) Return the DOM order object by index in the list and (2) the order list size
    CMarketBookOrd   *GetMBookByListIndex(const uint index)              { return this.m_list.At(index);  }
    int               DataTotal(void)                              const { return this.m_list.Total();    }
   //--- The comparison method for searching and sorting DOM snapshot objects by time
    virtual int       Compare(const CObject *node,const int mode=0) const 
                       {   
                        const CMBookSnapshot *compared_obj=node;
                        return(this.Time()<compared_obj.Time() ? -1 : this.Time()>compared_obj.Time() ? 1 : 0);
                       } 
   //--- Return the DOM snapshot change
    string            Header(void);
   //--- Display (1) description and (2) short description of a DOM snapshot
    virtual void      Print(const bool full_prop=false,const bool dash=false);
    virtual void      PrintShort(const bool dash=false,const bool symbol=false);
   //--- Constructors
    CMBookSnapshot(){ this.m_type=OBJECT_DE_TYPE_BOOK_SNAPSHOT; }
    CMBookSnapshot(const string symbol,const long time,MqlBookInfo &book_array[]);
   //+----------------------------------------------------------------------+ 
   //|Methods of a simplified access to the DOM snapshot object properties  |
   //+----------------------------------------------------------------------+
   //--- Set (1) a symbol, (2) a DOM snapshot time and (3) the specified time for all DOM orders
    void              SetSymbol(const string symbol)   { this.m_symbol=(symbol==NULL || symbol=="" ? ::Symbol() : symbol); }
    void              SetTime(const long time_msc)     { this.m_time=time_msc; }
    void              SetTimeToOrders(const long time_msc);
   //--- Return (1) a DOM symbol, (2) symbol's Digits and (3) a snapshot time
   //--- (4) buy and (5) sell DOM snapshot volume
   //--- with increased accuracy for (6) buying and (7) selling,
    string            Symbol(void)               const { return this.m_symbol;             }
    int               Digits(void)               const { return this.m_digits;             }
    long              Time(void)                 const { return this.m_time;               }
    long              VolumeBuy(void)            const { return this.m_volume_buy;         }
    long              VolumeSell(void)           const { return this.m_volume_sell;        }
    double            VolumeBuyReal(void)        const { return this.m_volume_buy_real;    }
    double            VolumeSellReal(void)       const { return this.m_volume_sell_real;   }
   //--- Return the description of DOM (1) buy and (2) sell volume
    string            VolumeBuyDescription(void);
    string            VolumeSellDescription(void);
   
  };
#endif // CMARKETBOOKSNAPSHOT_MQH_DECLARATION
#ifndef CMARKETBOOKSNAPSHOT_MQH_IMPLEMENTATION
#define CMARKETBOOKSNAPSHOT_MQH_IMPLEMENTATION
 //+------------------------------------------------------------------+
 //| Parametric constructor                                           |
 //+------------------------------------------------------------------+
 CMBookSnapshot::CMBookSnapshot(const string symbol,const long time,MqlBookInfo &book_array[]) : m_time(time)
  {
   this.m_type=OBJECT_DE_TYPE_BOOK_SNAPSHOT;
   //--- Set a symbol
    this.SetSymbol(symbol);
   //--- Clear the list
    this.m_list.Clear();
   //--- In the loop by the structure array
    int total=::ArraySize(book_array);
    this.m_volume_buy=this.m_volume_sell=0;
    this.m_volume_buy_real=this.m_volume_sell_real=0;
    for(int i=0;i<total;i++)
     {
      //--- Create order objects of the current DOM snapshot depending on the order type
      CMarketBookOrd *mbook_ord=NULL;
      switch(book_array[i].type)
        {
         case BOOK_TYPE_BUY         : mbook_ord=new CMarketBookBuy(this.m_symbol,book_array[i]);         break;
         case BOOK_TYPE_SELL        : mbook_ord=new CMarketBookSell(this.m_symbol,book_array[i]);        break;
         case BOOK_TYPE_BUY_MARKET  : mbook_ord=new CMarketBookBuyMarket(this.m_symbol,book_array[i]);   break;
         case BOOK_TYPE_SELL_MARKET : mbook_ord=new CMarketBookSellMarket(this.m_symbol,book_array[i]);  break;
         default: break;
        }
      if(mbook_ord==NULL)
         continue;
      //--- Set the DOM snapshot time for the order
      mbook_ord.SetTime(this.m_time);

      //--- Set the sorted list flag for the list (by the price value) and add the current order object to it
      //--- If failed to add the object to the DOM order list, remove the order object
      this.m_list.Sort(SORT_BY_MBOOK_ORD_PRICE);
      if(!this.m_list.InsertSort(mbook_ord))
         delete mbook_ord;
      //--- If the order object is successfully added to the DOM order list, supplement the total snapshot volumes
      else
        {
         switch(mbook_ord.TypeOrd())
           {
            case BOOK_TYPE_BUY         : 
              this.m_volume_buy+=mbook_ord.Volume(); 
              this.m_volume_buy_real+=mbook_ord.VolumeReal();
              break;
            case BOOK_TYPE_SELL        : 
              this.m_volume_sell+=mbook_ord.Volume(); 
              this.m_volume_sell_real+=mbook_ord.VolumeReal();
              break;
            case BOOK_TYPE_BUY_MARKET  : 
              this.m_volume_buy+=mbook_ord.Volume(); 
              this.m_volume_buy_real+=mbook_ord.VolumeReal();
              break;
            case BOOK_TYPE_SELL_MARKET : 
              this.m_volume_buy+=mbook_ord.Volume(); 
              this.m_volume_buy_real+=mbook_ord.VolumeReal();
              break;
            default: break;
           }
        }
     }
  }
 //+------------------------------------------------------------------+
 //| Return the object short name                                     |
 //+------------------------------------------------------------------+
 string CMBookSnapshot::Header(void)
  {
   return CMessage::Text(MSG_MBOOK_SNAP_TEXT_SNAPSHOT)+" \""+this.Symbol()+"\"";
  }
 //+------------------------------------------------------------------+
 //| Display a short description of the object in the journal         |
 //+------------------------------------------------------------------+
 void CMBookSnapshot::PrintShort(const bool dash=false,const bool symbol=false)
  {
   string vol_buy="Buy vol: "+(this.VolumeBuyReal()>0 ? ::DoubleToString(this.VolumeBuyReal(),2) : (string)this.VolumeBuy());
   string vol_sell="Sell vol: "+(this.VolumeSellReal()>0 ? ::DoubleToString(this.VolumeSellReal(),2) : (string)this.VolumeSell());
   ::Print(this.Header()," ",vol_buy,", ",vol_sell," ("+TimeMSCtoString(this.m_time),")");
  }
 //+------------------------------------------------------------------+
 //| Display object properties in the journal                         |
 //+------------------------------------------------------------------+
 void CMBookSnapshot::Print(const bool full_prop=false,const bool dash=false)
  {
   string vol_buy=CMessage::Text(MSG_MBOOK_SNAP_VOLUME_BUY)+": "+(this.VolumeBuyReal()>0 ? ::DoubleToString(this.VolumeBuyReal(),2) : (string)this.VolumeBuy());
   string vol_sell=CMessage::Text(MSG_MBOOK_SNAP_VOLUME_SELL)+": "+(this.VolumeSellReal()>0 ? ::DoubleToString(this.VolumeSellReal(),2) : (string)this.VolumeSell());
   ::Print(this.Header(),": ",vol_buy,", ",vol_sell," ("+TimeMSCtoString(this.m_time),"):");
   this.m_list.Sort(SORT_BY_MBOOK_ORD_PRICE);
   for(int i=this.m_list.Total()-1;i>WRONG_VALUE;i--)
     {
      CMarketBookOrd *ord=this.m_list.At(i);
      if(ord==NULL)
         continue;
      ::Print("- ",ord.Header());
     }
  }
 //+------------------------------------------------------------------+
 //| Set the specified time to all DOM orders                         |
 //+------------------------------------------------------------------+
 void CMBookSnapshot::SetTimeToOrders(const long time_msc)
  {
   int total=this.m_list.Total();
   for(int i=0;i<total;i++)
     {
      CMarketBookOrd *ord=this.m_list.At(i);
      if(ord==NULL)
         continue;
      ord.SetTime(time_msc);
     }
  }
 //+------------------------------------------------------------------+
 //| Return the DOM buy volume description                            |
 //+------------------------------------------------------------------+
 string CMBookSnapshot::VolumeBuyDescription(void)
  {
   return(CMessage::Text(MSG_MBOOK_SNAP_VOLUME_BUY)+": "+(this.VolumeBuyReal()>0 ? ::DoubleToString(this.VolumeBuyReal(),2) : (string)this.VolumeBuy()));
  }
 //+------------------------------------------------------------------+
 //| Return the DOM sell volume description                           |
 //+------------------------------------------------------------------+
 string CMBookSnapshot::VolumeSellDescription(void)
  {
   return(CMessage::Text(MSG_MBOOK_SNAP_VOLUME_SELL)+": "+(this.VolumeSellReal()>0 ? ::DoubleToString(this.VolumeSellReal(),2) : (string)this.VolumeSell()));
  }
 //+------------------------------------------------------------------+

#endif // CMARKETBOOKSNAPSHOT_MQH_IMPLEMENTATION
#endif // __MARKETBOOKSNAPSHOT_MQH__