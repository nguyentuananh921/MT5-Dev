//+------------------------------------------------------------------+
//|                                           PositionManagement.mqh |
//|                                        Copyright 2025, Your name.|
//|                                             https://www.mql5.com |
//|Part 1                        https://www.mql5.com/en/articles/16820|
//|Part 2                        https://www.mql5.com/en/articles/16985|
//|Part 3                        https://www.mql5.com/en/articles/17249|
//|Part 4                        https://www.mql5.com/en/articles/17508|
//|Part 5                        https://www.mql5.com/en/articles/17640|
//|EA Part 1                     https://www.mql5.com/en/articles/17957|
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Your name."
#property link      "https://www.mql5.com"
#property strict

#include "Risk_Management.mqh"
//+------------------------------------------------------------------+
//| Break Even Structs                                               |
//+------------------------------------------------------------------+
struct position_be
 {
  ulong              ticket;          //Position Ticket
  double             breakeven_price; //Be price
  double             price_to_beat;   //Price to exceed to reach break even
  ENUM_POSITION_TYPE type;            //Position type
 };

enum ENUM_BREAKEVEN_TYPE
 {
  BREAKEVEN_TYPE_RR = 0,           //By RR
  BREAKEVEN_TYPE_FIXED_POINTS = 1, //By FixedPoints
  BREAKEVEN_TYPE_ATR = 2           //By Atr
 };

enum ENUM_BREAKEVEN_MODE
 {
  BREAKEVEN_MODE_AUTOMATIC,
  BREAKEVEN_MODE_MANUAL
 };


//+------------------------------------------------------------------+
//| Main class to apply break even                                   |
//+------------------------------------------------------------------+
class CBreakEvenBase
 {
protected:
  CTrade             obj_trade;       //CTrade object
  MqlTick            tick;            //tick structure
  string             symbol;          //current symbol
  double             point_value;     //value of the set symbol point
  position_be        PostionsBe[];    //array of positions of type Positions
  ulong              magic;           //magic number of positions to make break even
  bool               pause;           //Boolean variable to activate the pause of the review, this is used to prevent the array from going out of range
  int                num_params;      //Number of parameters the class needs
  ENUM_BREAKEVEN_MODE breakeven_mode; //Break even mode, manual or automatic
  bool               allow_extra_logs;

public:
                     CBreakEvenBase(string symbol_, ulong magic_, ENUM_BREAKEVEN_MODE mode_);
                    ~CBreakEvenBase();

  virtual inline int GetNumParams() const final { return num_params; }
  virtual bool       Add(ulong post_ticket, double open_price, double sl_price, ENUM_POSITION_TYPE position_type) = 0;
  virtual void       BreakEven() final;
  virtual void       OnTradeTransactionEvent(const MqlTradeTransaction& trans) final;
  virtual void       Set(MqlParam &params[]) = 0;
  virtual void       SetExtraLogs(bool allow_extra_logs_) final { this.allow_extra_logs = allow_extra_logs_; }
 };

//+------------------------------------------------------------------+
//| OnTradeTransactionEvent                                          |
//+------------------------------------------------------------------+
void CBreakEvenBase::OnTradeTransactionEvent(const MqlTradeTransaction &trans)
 {
  if(trans.type != TRADE_TRANSACTION_DEAL_ADD)
    return;

  HistoryDealSelect(trans.deal);
  ENUM_DEAL_ENTRY entry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(trans.deal, DEAL_ENTRY);
  bool pos = PositionSelectByTicket(trans.position);


  if(breakeven_mode == BREAKEVEN_MODE_AUTOMATIC)
   {
    ulong position_magic = (ulong)HistoryDealGetInteger(trans.deal, DEAL_MAGIC);

    if(entry == DEAL_ENTRY_IN && pos && (this.magic == position_magic || this.magic == NOT_MAGIC_NUMBER))
     {
      if(Add(trans.position, PositionGetDouble(POSITION_PRICE_OPEN), PositionGetDouble(POSITION_SL), (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)))
        {
        if(this.allow_extra_logs)
          printf("%s:: The %I64u ticket has been added to the position array.", __FUNCTION__, trans.position);
        }    
      return;
     }
   }

  if(entry == DEAL_ENTRY_OUT && pos == false)
   {
    this.pause = true;

    if(ExtraFunctions::RemoveIndexFromAnArrayOfPositions(PostionsBe, trans.position))
      if(this.allow_extra_logs)
        printf("%s:: The %I64u ticket has been removed from the array of positions.", __FUNCTION__, trans.position);

    this.pause = false;
   }
 }

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CBreakEvenBase::~CBreakEvenBase()
 {
  ArrayFree(PostionsBe);
 }

//+------------------------------------------------------------------+
//| Contructor                                                       |
//+------------------------------------------------------------------+
CBreakEvenBase::CBreakEvenBase(string symbol_, ulong magic_, ENUM_BREAKEVEN_MODE mode_)
  : pause(false), allow_extra_logs(false)
 {
  if(magic_ != NOT_MAGIC_NUMBER)
    obj_trade.SetExpertMagicNumber(magic_);

  if(mode_ != BREAKEVEN_MODE_MANUAL && mode_ != BREAKEVEN_MODE_AUTOMATIC)
   {
    printf("%s:: Critical error break even %s mode is invalid.", __FUNCTION__, EnumToString(mode_));
    ExpertRemove();
   }

  this.symbol = symbol_;
  this.num_params = 0;
  this.magic = magic_;
  this.breakeven_mode = mode_;
  this.point_value = SymbolInfoDouble(symbol_, SYMBOL_POINT);
 }

//+------------------------------------------------------------------+
//| Function to make break even                                      |
//+------------------------------------------------------------------+
void CBreakEvenBase::BreakEven(void)
 {
  if(this.PostionsBe.Size() < 1 || pause)
    return;

  SymbolInfoTick(this.symbol, tick);

  int indices_to_remove[];

  for(int i = 0 ; i < ArraySize(this.PostionsBe) ; i++)
   {
    if((this.PostionsBe[i].type == POSITION_TYPE_BUY && tick.ask >= this.PostionsBe[i].price_to_beat) ||
       (this.PostionsBe[i].type == POSITION_TYPE_SELL && tick.bid <= this.PostionsBe[i].price_to_beat))
     {
      if(!PositionSelectByTicket(this.PostionsBe[i].ticket))
       {
        printf("%s:: Error when selecting ticket %I64u", __FUNCTION__, this.PostionsBe[i].ticket);
        ExtraFunctions::AddArrayNoVerification(indices_to_remove, i);
        continue;
       }

      double position_tp = PositionGetDouble(POSITION_TP);
      obj_trade.PositionModify(this.PostionsBe[i].ticket, this.PostionsBe[i].breakeven_price, position_tp);
      ExtraFunctions::AddArrayNoVerification(indices_to_remove, i);
     }
   }

  ExtraFunctions::RemoveMultipleIndexes(this.PostionsBe, indices_to_remove);
 }


//+------------------------------------------------------------------+
//| class CBreakEvenSimple                                           |
//+------------------------------------------------------------------+
class CBreakEvenSimple : public CBreakEvenBase
 {
private:
  int                extra_points_be, points_be;

public:
                     CBreakEvenSimple(string symbol_, ulong magic_, ENUM_BREAKEVEN_MODE mode_)
    :                CBreakEvenBase(symbol_, magic_, mode_) { this.extra_points_be = 0; this.points_be = 0; this.num_params = 2;}


  bool               Add(ulong post_ticket, double open_price, double sl_price, ENUM_POSITION_TYPE position_type) override;
  void               Set(MqlParam &params[]) override;
  void               SetSimple(int points_be_, int extra_points_be_);
 };

//+----------------------------------------------------------------------------------------------+
//| Create a new structure and add it to the main array using the 'AddToArrayBe' function        |
//+----------------------------------------------------------------------------------------------+
bool CBreakEvenSimple::Add(ulong post_ticket, double open_price, double sl_price, ENUM_POSITION_TYPE position_type)
 {
  position_be new_pos;
  new_pos.breakeven_price =  position_type == POSITION_TYPE_BUY ? open_price + (point_value * extra_points_be) : open_price - (point_value * extra_points_be);
  new_pos.type =  position_type;
  new_pos.price_to_beat = position_type == POSITION_TYPE_BUY ? open_price + (point_value * points_be) : open_price - (point_value * points_be) ;
  new_pos.ticket = post_ticket;
  ExtraFunctions::AddArrayNoVerification(this.PostionsBe, new_pos);
  return true;
 }

//+------------------------------------------------------------------+
//| Set attributes of CBreakEvenSimple class with MqlParam array     |
//+------------------------------------------------------------------+
void CBreakEvenSimple::Set(MqlParam &params[])
 {
  if(params.Size() < 2)
   {
    printf("%s:: Error setting simple break-even, the size of the params array %I32u to less than 2", __FUNCTION__, params.Size());
    return;
   }

  SetSimple(int(params[0].integer_value), int(params[1].integer_value));
 }

//+------------------------------------------------------------------+
//| Function to set member variables without using MalParams         |
//+------------------------------------------------------------------+
void CBreakEvenSimple::SetSimple(int points_be_, int extra_points_be_)
 {
  if(points_be_ <= 0)
   {
    printf("%s:: Error when setting the break even value for fixed points, be points %I32d are invalid.", __FUNCTION__, extra_points_be_);
    ExpertRemove();
    return;
   }

  if(extra_points_be_ < 0)
   {
    printf("%s:: Error when setting the break even value for fixed points, extra points %I32d are invalid.", __FUNCTION__, extra_points_be_);
    ExpertRemove();
    return;
   }

  if(extra_points_be_ >= points_be_)
   {
    printf("%s:: Warning: The break even points (breakeven_price) is greater than the breakeven points (price_to_beat)\nTherefore the value of the extra breakeven points will be modified 0.",
           __FUNCTION__);
    this.points_be = points_be_; //0
    this.extra_points_be = 0; //1
    return;
   }

  this.points_be = points_be_; //0
  this.extra_points_be = extra_points_be_; //1
 }
//+------------------------------------------------------------------+
