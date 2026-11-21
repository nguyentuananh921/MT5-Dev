# Update Note

  Ghi lại các bản cũ của từng module theo từng lần để làm Document.
  History update
 - EA                                      Library                                        
                                            2. DoEasy. Service functions Lib
    - 4. Combination EA                     4. Combination Lib 
    - 4. Combination EA V2                  4. Combination Lib V2
    - 4. Combination EA V3 Old              4. Combination Lib V3
    - 4. Combination EA V3                  4. Combination Lib V3 
    - 4. Combination EA V4                  4. Combination Lib V4
    - 4. Combination EA V5                  4. Combination Lib V5

## EA Module

 - **4. Combination EA:** (D:\MT5-Dev\Experts\Anhnt\Example EA\4. Combination EA)
 - **4. Combination EA V2:** (D:\MT5-Dev\Experts\Anhnt\Example EA\4. Combination EA V2)
 - **4. Combination EA V3 Old:** (D:\MT5-Dev\Experts\Anhnt\Example EA\4. Combination EA V3 Old)
 - **4. Combination EA V3:** (D:\MT5-Dev\Experts\Anhnt\Example EA\4. Combination EA V3)
 - **4. Combination EA V4:** (D:\MT5-Dev\Experts\Anhnt\Example EA\4. Combination EA V4)
 -

## EA Web

## Library

  Các bản Library được lưu lại làm tài liệu ở đây.
- [2. DoEasy. Service functions Lib] (D:\MT5-Dev\Include\Vendors\Anhnt\2. DoEasy. Service functions Lib)
- [3. EasyAndFastGUI 19703](D:\MT5-Dev\Include\Vendors\Anhnt\3. EasyAndFastGUI 19703)
- [4. Combination Lib](D:\MT5-Dev\Include\Vendors\Anhnt\4. Combination Lib)
- [4. Combination Lib V2](D:\MT5-Dev\Include\Vendors\Anhnt\4. Combination Lib V2)
- [4. Combination Lib V3](D:\MT5-Dev\Include\Vendors\Anhnt\4. Combination Lib V3)
- [4. Combination Lib V4](D:\MT5-Dev\Include\Vendors\Anhnt\4. Combination Lib V4)
- [Current Version](D:\MT5-Dev\Library)

### Library\Python

## Database

## Implemenatation note.
 ### Automation Trading
 []- Automating Trading Strategies [Automating Trading Strategies] `D:\MT5-Dev\Experts\Allan Munene Mutiiria\Automating Trading Strategies`
 - Đã implemenation 2 strategy
 ### RiskManagement
 []-Reference Series 1 [Risk Management] 
 `D:\MT5-Dev\Experts\Solomon Anietie Sunday\Risk Management`
 -Đã implemenation vừa chưa test được.
 - **Đi tắt:** lẽ ra mỗi Automation phải backtest kiểm chứng rồi mới bật ([gate 0](../AGENTS.md#rules-gate-mục-tiêu-tối-thượng)).
   - Đi tắt vì backtest xong cũng chỉ đổi Strategy này sang Strategy khác, parameter này sang parameter khác; cơ chế Automation không đổi.
   - Mới có 2 strategy nên quá ít Position được mở tự động, Risk chưa có việc để làm.
   - Vì thế tab Trading có các control Manual (Manual Buy / Sell, Manual Order Type, Manual Close All) để mở Position cật lực; lệnh Manual mang StrategyID 0 trong magic.
   - Manual không qua ngưỡng spread (`MaxSpreadPips`, ngưỡng của Entry tự động); Risk tự làm việc theo Basket và Portfolio.
 []-Reference Series 2 [Risk Management] 
 `D:\MT5-Dev\Experts\Niquel Mendoza\Risk Management`
 -Chưa làm.

 

