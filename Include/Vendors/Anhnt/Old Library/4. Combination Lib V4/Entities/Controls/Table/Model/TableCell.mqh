//+------------------------------------------------------------------+
//|                                                    TableCell.mqh |
//| MVC table cell (articles 17653..20596) on CBaseObjExt tracking   |
//+------------------------------------------------------------------+
#property strict

#ifndef CTABLECELL_MQH
#define CTABLECELL_MQH
 #include "..\..\..\Bases\BaseObjExt.mqh"
 #define CELL_PROP_LONG    (0)
 #define CELL_PROP_DOUBLE  (1)
#ifndef CTABLECELL_MQH_DECLARATION
#define CTABLECELL_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Raw typed value; numbers tracked for INC/DEC/LEVEL, IsEvent()    |
//| = changed since the view last drew it                            |
//+------------------------------------------------------------------+
class CTableCell : public CBaseObjExt
 {
  private:
    ENUM_DATATYPE     m_datatype;
    string            m_value_s;
    int               m_digits;
    uint              m_time_flags;
    CObject          *m_object;

    void              SetLong(const long value,const bool type_changed);
    void              SetDouble(const double value,const bool type_changed);
  public:
    void              SetValue(const double value);
    void              SetValue(const long value);
    void              SetValue(const datetime value);
    void              SetValue(const string value);
    double            ValueD(void)                        const { return(this.GetPropDoubleValue(CELL_PROP_DOUBLE)); }
    long              ValueL(void)                        const { return(this.GetPropLongValue(CELL_PROP_LONG));     }
    string            ValueS(void)                        const { return(this.m_value_s);   }
    string            Value(void);
    ENUM_DATATYPE     Datatype(void)                      const { return(this.m_datatype);  }
    void              SetDigits(const int digits)               { this.m_digits=digits;     }
    int               Digits(void)                        const { return(this.m_digits);    }
    void              SetDatetimeFlags(const uint flags)        { this.m_time_flags=flags;  }
    uint              DatetimeFlags(void)                 const { return(this.m_time_flags); }
    void              AssignObject(CObject *object)             { this.m_object=object;     }
    void              UnassignObject(void)                      { this.m_object=NULL;       }
    CObject          *AssignedObject(void)                const { return(this.m_object);    }
    void              SetLevel(const double level)              { this.SetControlledValueLEVEL(CELL_PROP_DOUBLE,level); }
    bool              IsIncreased(void)                   const { return(this.m_datatype==TYPE_DOUBLE ? this.GetPropDoubleFlagINC(CELL_PROP_DOUBLE)!=0 : this.GetPropLongFlagINC(CELL_PROP_LONG)!=0); }
    bool              IsDecreased(void)                   const { return(this.m_datatype==TYPE_DOUBLE ? this.GetPropDoubleFlagDEC(CELL_PROP_DOUBLE)!=0 : this.GetPropLongFlagDEC(CELL_PROP_LONG)!=0); }
    bool              IsMore(void)                        const { return(this.GetPropDoubleFlagMORE(CELL_PROP_DOUBLE)!=0); }
    bool              IsLess(void)                        const { return(this.GetPropDoubleFlagLESS(CELL_PROP_DOUBLE)!=0); }
                     CTableCell(void);
                    ~CTableCell(void) {}
 };
#endif // CTABLECELL_MQH_DECLARATION
#ifndef CTABLECELL_MQH_IMPLEMENTATION
#define CTABLECELL_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| One long + one double controlled property, any change counts     |
//+------------------------------------------------------------------+
CTableCell::CTableCell(void) : m_datatype(TYPE_STRING),
                               m_value_s(""),
                               m_digits(0),
                               m_time_flags(TIME_DATE|TIME_MINUTES),
                               m_object(NULL)
 {
  this.SetControlDataArraySizeLong(1);
  this.SetControlDataArraySizeDouble(1);
  this.ResetControlsParams();
  this.ResetChangesParams();
  this.SetControlledValueINC(CELL_PROP_LONG,0);
  this.SetControlledValueDEC(CELL_PROP_LONG,0);
  this.SetControlledValueINC(CELL_PROP_DOUBLE,0.0);
  this.SetControlledValueDEC(CELL_PROP_DOUBLE,0.0);
 }
//+------------------------------------------------------------------+
//| A type switch (e.g. "N/A" back to a number) always redraws       |
//+------------------------------------------------------------------+
void CTableCell::SetValue(const double value)
 {
  bool type_changed=(this.m_datatype!=TYPE_DOUBLE);
  this.m_datatype=TYPE_DOUBLE;
  this.SetDouble(value,type_changed);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTableCell::SetValue(const long value)
 {
  bool type_changed=(this.m_datatype!=TYPE_LONG);
  this.m_datatype=TYPE_LONG;
  this.SetLong(value,type_changed);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTableCell::SetValue(const datetime value)
 {
  bool type_changed=(this.m_datatype!=TYPE_DATETIME);
  this.m_datatype=TYPE_DATETIME;
  this.SetLong((long)value,type_changed);
 }
//+------------------------------------------------------------------+
//| Same value = nothing; else Refresh (INC/DEC) and mark changed    |
//+------------------------------------------------------------------+
void CTableCell::SetLong(const long value,const bool type_changed)
 {
  if(!this.m_first_start && value==this.ValueL())
    {
     if(type_changed)
        this.SetEventFlag(true);
     return;
    }
  this.m_long_prop_event[0][3]=value;
  this.Refresh();
  this.SetEventFlag(true);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTableCell::SetDouble(const double value,const bool type_changed)
 {
  if(!this.m_first_start && value==this.ValueD())
    {
     if(type_changed)
        this.SetEventFlag(true);
     return;
    }
  this.m_double_prop_event[0][3]=value;
  this.Refresh();
  this.SetEventFlag(true);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTableCell::SetValue(const string value)
 {
  if(this.m_datatype==TYPE_STRING && value==this.m_value_s)
     return;
  this.m_datatype=TYPE_STRING;
  this.m_value_s =value;
  this.SetEventFlag(true);
 }
//+------------------------------------------------------------------+
//| Display string by data type                                      |
//+------------------------------------------------------------------+
string CTableCell::Value(void)
 {
  switch(this.m_datatype)
    {
     case TYPE_DOUBLE:
        return(::DoubleToString(this.ValueD(),this.m_digits));
     case TYPE_DATETIME:
        return(::TimeToString((datetime)this.ValueL(),this.m_time_flags));
     case TYPE_STRING:
        return(this.m_value_s);
     default:
        return(::IntegerToString(this.ValueL()));
    }
 }
#endif // CTABLECELL_MQH_IMPLEMENTATION
#endif // CTABLECELL_MQH
