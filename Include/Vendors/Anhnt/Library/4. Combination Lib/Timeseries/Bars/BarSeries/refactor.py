import codecs

path = r"c:\Users\nguye\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Include\Vendors\Anhnt\Library\4. Combination Lib\Timeseries\Bars\BarSeries\BarSeriesDE.mqh"
with codecs.open(path, "r", "utf-16le") as f:
    content = f.read()

target1 = """   //--- Set the very first date by a period symbol at the moment and the new time of opening the last bar by a period symbol
    void              SetServerDate(void)
                        {
                          this.m_firstdate=(datetime)::SeriesInfoInteger(this.m_symbol,this.m_timeframe,SERIES_FIRSTDATE);
                          this.m_lastbar_date=(datetime)::SeriesInfoInteger(this.m_symbol,this.m_timeframe,SERIES_LASTBAR_DATE);
                        }"""
replacement1 = """   //--- Set the very first date by a period symbol at the moment and the new time of opening the last bar by a period symbol
    void              SetServerDate(void);"""

target2 = """#ifndef CBARSERIESDE_MQH_IMPLEMENTATION
#define CBARSERIESDE_MQH_IMPLEMENTATION"""

replacement2 = """#ifndef CBARSERIESDE_MQH_IMPLEMENTATION
#define CBARSERIESDE_MQH_IMPLEMENTATION
  //+------------------------------------------------------------------+
  //| Set the very first date by a period symbol                       |
  //+------------------------------------------------------------------+
  void CBarSeriesDE::SetServerDate(void)
    {
    this.m_firstdate=(datetime)::SeriesInfoInteger(this.m_symbol,this.m_timeframe,SERIES_FIRSTDATE);
    this.m_lastbar_date=(datetime)::SeriesInfoInteger(this.m_symbol,this.m_timeframe,SERIES_LASTBAR_DATE);
    }"""

if target1 in content and target2 in content:
    content = content.replace(target1, replacement1)
    content = content.replace(target2, replacement2)
    # Write BOM manually if not done by utf-16le, but codecs handles it
    with codecs.open(path, "w", "utf-16") as f:
        f.write(content)
    print("Success")
else:
    print("Could not find targets")
    if target1 not in content:
        print("Target 1 missing")
    if target2 not in content:
        print("Target 2 missing")
