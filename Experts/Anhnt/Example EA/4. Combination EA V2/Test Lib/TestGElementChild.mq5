//+------------------------------------------------------------------+
//|                                            TestGElementChild.mq5 |
//| Click Left / Right moves the panel; its children must follow     |
//+------------------------------------------------------------------+
#property version "1.00"

#include <Vendors\Anhnt\Library\4. Combination Lib V2\Entities\Controls\Button.mqh>

CGElement m_panel;
CLabel    m_label;
CButton   m_btn_left;
CButton   m_btn_right;

int OnInit(void)
  {
   const long chart_id=::ChartID();
   if(!m_panel.Create(chart_id,0,"TestPanel",50,50,220,90))
      return INIT_FAILED;
   m_panel.AddChild(&m_label);
   m_panel.AddChild(&m_btn_left);
   m_panel.AddChild(&m_btn_right);
   m_label.SetText("Panel - click < or >");
   m_btn_left.SetText("Left");
   m_btn_right.SetText("Right");
   m_btn_left.IconFile(IMAGE_RESOURCE_BMP16_ARROWLEFT_BMP);
   m_btn_right.IconFile(IMAGE_RESOURCE_BMP16_ARROWRIGHT_BMP);
   if(!m_label.Create(chart_id,0,"TestLabel",10,8,200,20))
      return INIT_FAILED;
   if(!m_btn_left.Create(chart_id,0,"TestBtnLeft",10,40,95,20))
      return INIT_FAILED;
   if(!m_btn_right.Create(chart_id,0,"TestBtnRight",115,40,95,20))
      return INIT_FAILED;
   ::ChartRedraw(chart_id);
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
  }

void OnTick(void)
  {
  }

void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   m_panel.OnChartEvent(id,lparam,dparam,sparam);

   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON)
     {
      int step=0;
      if(lparam==m_btn_left.ObjectID())
         step=-20;
      if(lparam==m_btn_right.ObjectID())
         step=20;
      if(step==0)
         return;
      m_panel.Move(m_panel.X()+step,m_panel.Y());
      ::ChartRedraw();
      ::Print("MY DEBUG TestGElementChild::OnChartEvent: click id=",lparam," text=",sparam,
              " panel=(",m_panel.X(),",",m_panel.Y(),") left=(",m_btn_left.X(),",",m_btn_left.Y(),
              ") right=(",m_btn_right.X(),",",m_btn_right.Y(),")");
     }
  }
