# Concept RiskManagement

RiskManagement cũng là một Strategy: nó dùng Trading Setting cùng các Event liên quan để đưa ra quyết định theo phạm vi áp dụng. Trading Setting rộng hơn `Setting_Risk`; xem [Concept_Strategy.md](Concept_Strategy.md). RiskManagement không phải nguồn Event đứng ngoài Strategy để một Strategy khác quyết định thay.

RiskManagement có ba phạm vi:

- **Trade (Order):** rủi ro của một lệnh/Position.
- **Basket:** rủi ro của tất cả lệnh thuộc một Strategy Entry, nhận diện bằng `StrategyId()`.
- **Portfolio:** rủi ro tổng thể của account.

Basket không phải Position group. Position group là một lần vào lệnh cùng các lệnh thêm (grid/averaging), thường cùng hướng và đóng chung; một Strategy có thể có nhiều Position group.

Trading thực hiện quyết định của Strategy và chịu trách nhiệm về cách đặt lệnh, gồm cả lot. Cơ chế Event và quan hệ thành phần xem [Concept_Event.md](Concept_Event.md) và [Concept_ParentChild.md](Concept_ParentChild.md).

Chi tiết hiện trạng: [Imp_RiskManagement.md](../Implementaion/Imp_RiskManagement.md).
