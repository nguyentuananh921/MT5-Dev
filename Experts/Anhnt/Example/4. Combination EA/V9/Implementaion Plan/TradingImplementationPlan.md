# Trading Implementation Plan

## Overview
Mục tiêu: xây dựng kế hoạch thực hiện giao dịch chung cho hệ thống, cho phép trade được kích hoạt từ nhiều nguồn khác nhau.

Sources: Nguồn thực hiện Trading
- Mobile app / mobile signal source
- EA trên PC (Expert Advisor)
- Có thể mở rộng thêm: web service, manual input, bot khác
- Mục tiêu cần biết trước khi Push một trading command
  SYMBOL_TRADE_STOPS_LEVEL
  SYMBOL_BID/SYMBOL_ASK 
  SYMBOL_POINT
  SYMBOL_TRADE_TICK_VALUE->Bước nhẩy nhỏ nhất của giá.
-Lot size: Cần Combobox ->Cái này CTable có hỗ trợ đặt một Combobox vào trong cell (chưa Implementation)
    SYMBOL_VOLUME_MIN
    SYMBOL_VOLUME_MAX
    SYMBOL_VOLUME_STEP 
  
- Set SL on ->CTextEdit ->Set m_slPip
 - Min SL (Price) = SYMBOL_TRADE_STOPS_LEVEL * SYMBOL_POINT
 - Fix SL: //FixPip=50
     For Sell: slPrice = Ask + FixedPip * Pip(); 
     For Buy:  slPrice = Bid - FixedPip * Pip();  
 - Dynamic SL: Calculation base on ATR
     - double GetAverageATR()
       {
          double atrVals[];
          ArraySetAsSeries(atrVals, true);
          if(CopyBuffer(h_atr, 0, 1, 5, atrVals) <= 0) return 0.0;          
          double sum = 0;
          for(int i = 0; i < 5; i++)
            sum += atrVals[i];
          return sum / 5.0;
       }
     - slPips = atrAvg * ATR_Multiplier / Pip(); //ATR_Multiplier=1.2 set ở trên.

- Set Trailling on
   
Khi gửi một lệnh trading lên Server, chúng ta cần

1. Thông tin lệnh cơ bản
  - symbol (cặp tiền / tài sản) ->Combobox
  - direction (BUY / SELL) ->2 CButton
  - Order_type (MARKET / LIMIT / STOP / STOP_LIMIT)->Combobox
  - volume / lot_size->Editbox
  - price (giá vào lệnh nếu LIMIT/STOP)->Editbox
  - stop_loss->Editbox
  - take_profit->Editbox
  - Trailling
2. 
2. Thông tin xác thực & định danh
account_id / client_id
strategy_id hoặc source_id (EA, Mobile, manual, bot)
request_id / correlation_id để trace
timestamp

3. Điều kiện rủi ro & hợp lệ
Kiểm tra symbol có được phép trade không
Kiểm tra volume phù hợp với step / min / max
Kiểm tra SL/TP có khoảng cách hợp lệ so với giá hiện tại
Kiểm tra margin khả dụng / risk limit / drawdown limit
Kiểm tra cặp có vào được tại thời điểm này (giờ, thanh khoản, tin tức)

4. Khai báo hành vi order
time_in_force (GTC / IOC / FOK)
expiration nếu có
comment hoặc note để biết lệnh từ nguồn nào
auto_close / trailing / quản lý động nếu cần

5. Truyền dữ liệu bổ sung để theo dõi
trade_plan_id hoặc signal_id
source_type (Mobile, EA trên PC, manual)
risk_parameters (max_risk_percent, max_loss_value)
trade_category (scalp/swing/hedge)


## Scope
- Định nghĩa các nguồn trade hợp lệ
- Thiết kế luồng dữ liệu và giao tiếp giữa source và engine
- Xác định cách đồng bộ kế hoạch trade, quản lý lệnh và thực thi
- Giữ nguyên hệ thống hiện tại của EA, mở rộng thêm khả năng nhận tín hiệu từ nguồn ngoài

## Requirements
1. Hỗ trợ đa nguồn signal:
   - Mobile: nhận lệnh hoặc tín hiệu từ file/JSON/REST/IPC
   - EA trên PC: ra lệnh nội bộ từ logic indicator/price action
2. Quy trình trade nhất quán:
   - Source cung cấp kế hoạch vào lệnh
   - Kiểm tra rủi ro / xác thực param
   - Xác định kích thước lot và stop loss/take profit
   - Gửi sang module thực thi lệnh chung
3. Bảo toàn trạng thái:
   - Ghi nhận nguồn phát lệnh
   - Lưu thông tin giao dịch để review, thống kê, debug
4. Tách bạch logic:
   - Source logic chỉ tạo kế hoạch trade
   - Execution engine chịu trách nhiệm gửi lệnh
   - Risk manager kiểm tra giới hạn và điều chỉnh

## Conceptual architecture

### Source layer
- `MobileSource`
  - Nhận tín hiệu từ mobile. Có thể qua file cấu hình, JSON, socket, clipboard, API.
  - Mỗi lệnh chứa: symbol, direction, entry type, stop loss, take profit, size, comment, source id.
- `EA Source`
  - Logic EA trên PC ra tín hiệu nội bộ theo indicator hoặc rule.
  - Có thể dùng trực tiếp trong code EA và gửi vào engine qua cùng interface.

### Trading plan layer
- `TradingPlan` object / struct
  - symbol
  - direction (BUY/SELL)
  - entry method (market/limit)
  - size / lot
  - stop loss
  - take profit
  - source type (Mobile, EA)
  - timestamp, reference id
  - risk params
- `TradingPlanValidator`
  - Kiểm tra tính hợp lệ của plan
  - So sánh với danh sách cặp, kích thước tối đa, rules
- `RiskManager`
  - Tính toán lot size theo vốn hiện tại
  - Áp giới hạn rủi ro mỗi lệnh
  - Từ chối lệnh nếu vượt mức drawdown hoặc volume

### Execution layer
- `ExecutionEngine`
  - Nhận `TradingPlan` đã validated
  - Chuyển thành lệnh MQL5 `OrderSend`/`OrderSendAsync`
  - Ghi log nguồn và thông tin trade
  - Quản lý lệnh mở, trailing, đóng
- `ExecutionState`
  - Lưu trạng thái lệnh đã gửi
  - Kết nối với bảng thống kê / review sau trade

## Integration points
- `FeatureNote` / design note cho việc:
  - thêm `TradingPlan` object
  - thêm list các nguồn trade
  - xác định luồng nhận tín hiệu và thực thi
- `EA` code hiện tại cần một interface chung để nhận `TradingPlan` từ cả 2 nguồn.
- Mobile source cần định nghĩa format truyền vào, cơ chế đồng bộ.

## Implementation options

### Option A: Central shared engine trong EA
- `EA` giữ một module `TradingEngine`
- Mobile source xuất file/JSON vào thư mục chung
- EA đọc file, parse thành `TradingPlan`
- Ưu điểm: đơn giản, không cần thay đổi kiến trúc MT5 quá nhiều
- Nhược điểm: cần polling / đồng bộ file, độ trễ

### Option B: Mobile signal gắn trực tiếp vào EA qua API
- Mobile app gửi request tới PC/EA qua cổng nội bộ, socket hoặc dịch vụ trung gian
- EA nhận và chuyển thành `TradingPlan`
- Ưu điểm: nhanh, kiểm soát tốt
- Nhược điểm: cần triển khai thêm kết nối, phức tạp hơn

### Option C: Mô-đun kế hoạch riêng biệt
- `TradingPlan` được xây dựng và lưu trong cấu trúc chung
- Các source (Mobile, EA) đều gọi vào API `SubmitTradingPlan(plan)`
- Engine duy trì queue plan và xử lý tuần tự
- Dễ mở rộng thêm source khác

## Recommended next step
1. Chốt format `TradingPlan`
2. Chọn cơ chế input cho Mobile
3. Thiết kế API/queue nội bộ cho EA
4. Triển khai `TradingPlanValidator` + `RiskManager`
5. Tạo note thảo luận chi tiết trong `FeatureNote/TradingImplementationPlan.md`

## Discussion points
- Mobile source dùng định dạng file hay dùng kết nối trực tiếp?
- Lệnh từ Mobile có được tự động thực thi hay chỉ tạo kế hoạch và chờ confirm?
- Nên phân biệt rõ `trade signal` và `trade order` trong hệ thống.
- Cần log/trace nguồn để phân tích sau này.
