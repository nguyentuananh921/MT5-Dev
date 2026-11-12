//+------------------------------------------------------------------+
//|                                                  TableHeader.mqh |
//+------------------------------------------------------------------+
#property strict

#ifndef CTABLEHEADER_MQH
#define CTABLEHEADER_MQH
 #include "..\..\..\Bases\BaseObj.mqh"
#ifndef CTABLEHEADER_MQH_DECLARATION
#define CTABLEHEADER_MQH_DECLARATION
//+------------------------------------------------------------------+
//| Column captions; their count = the table's column count          |
//+------------------------------------------------------------------+
class CTableHeader : public CBaseObj
 {
  private:
    string            m_captions[];
  public:
    void              SetColumnsTotal(const int total);
    int               ColumnsTotal(void)                     const { return(::ArraySize(this.m_captions)); }
    void              SetCaption(const int column,const string text);
    string            Caption(const int column)              const { return(column>=0 && column<::ArraySize(this.m_captions) ? this.m_captions[column] : ""); }
                     CTableHeader(void) {}
                    ~CTableHeader(void) {}
 };
#endif // CTABLEHEADER_MQH_DECLARATION
#ifndef CTABLEHEADER_MQH_IMPLEMENTATION
#define CTABLEHEADER_MQH_IMPLEMENTATION
//+------------------------------------------------------------------+
//| New columns get an empty caption                                 |
//+------------------------------------------------------------------+
void CTableHeader::SetColumnsTotal(const int total)
 {
  int size=::ArraySize(this.m_captions);
  ::ArrayResize(this.m_captions,::MathMax(total,0));
  for(int i=size; i<total; i++)
     this.m_captions[i]="";
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTableHeader::SetCaption(const int column,const string text)
 {
  if(column>=0 && column<::ArraySize(this.m_captions))
     this.m_captions[column]=text;
 }
#endif // CTABLEHEADER_MQH_IMPLEMENTATION
#endif // CTABLEHEADER_MQH
