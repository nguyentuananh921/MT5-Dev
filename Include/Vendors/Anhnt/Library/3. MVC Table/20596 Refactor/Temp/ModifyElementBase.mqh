#ifndef __ELEMENTBASE_MQH__
#define __ELEMENTBASE_MQH__

#include "..\Base\CanvasBase.mqh"   
#include "..\Base\ImagePainter.mqh"
#include "..\Collections\ListElm.mqh"

class CVisualHint; // Forward declaration — chỉ đủ cho class declaration

class CElementBase : public CCanvasBase
{
   // ... khai báo tất cả members và methods như cũ ...
};

// ✅ NHÓM 1: Implement các method KHÔNG gọi method của CVisualHint
// (chỉ dùng CVisualHint* như pointer thuần — cast, NULL check, trả về)
// Forward decl là đủ cho nhóm này
CElementBase::CElementBase(...) { ... }
int  CElementBase::Compare(...)  { ... }
string CElementBase::Description() { ... }
void CElementBase::SetResizable(...) { ... }  // chỉ gọi AddHintsArrowed/DeleteHintsArrowed
bool CElementBase::Save(...)    { ... }
bool CElementBase::Load(...)    { ... }
// GetHintAt, GetHint(id), GetHint(name), AddHintToList
// InsertNewTooltip, InsertTooltip
// OnResizeZoneEvent, ResizeActionDragHandler

// ✅ INCLUDE VisualHint SAU KHI class CElementBase đã hoàn chỉnh
#include "VisualHint.mqh"

// ✅ NHÓM 2: Implement các method GỌI method của CVisualHint
// Cần full definition — đặt SAU include
CVisualHint* CElementBase::CreateNewHint(...)        { ... new CVisualHint(...) ... }
CVisualHint* CElementBase::CreateAndAddNewHint(...)  { ... obj.SetImageBound() ... }
CVisualHint* CElementBase::AddHint(...)              { ... obj.Move() ... obj.SetContainerObj() ... }
bool         CElementBase::AddHintsArrowed()         { ... obj.Hide() ... obj.Draw() ... }
bool         CElementBase::DeleteHintsArrowed()      { ... obj.HintType() ... }
void         CElementBase::ShowHintArrowed(...)       { ... obj.HintType() ... hint.Draw() ... }
void         CElementBase::HideHintsAll(...)          { ... obj.Hide() ... }
bool         CElementBase::ShowCursorHint(...)        { ... hint.Move() ... }
bool         CElementBase::ResizeZoneRightHandler(...)   { ... hint.Move() ... }
// ... tất cả ResizeZone*Handler còn lại

#endif // __ELEMENTBASE_MQH__