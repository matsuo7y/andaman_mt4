//+------------------------------------------------------------------+
//|                                                  TradeDialog.mqh |
//|                                     Copyright 2020, Yuki Matsuo. |
//+------------------------------------------------------------------+
#include <Controls\Dialog.mqh>
#include <Controls\Button.mqh>
#include <stdlib.mqh>
#include "PipsLabelProcessor.mqh"

#define DIALOG_LEFT                         (1530)
#define DIALOG_TOP                          (30)

#define DIALOG_WIDTH                        (180)
#define DIALOG_HEIGHT                       (180)

#define INDENT_LEFT                         (5) 
#define INDENT_TOP                          (5)
#define INDENT_RIGHT                        (5)
#define INDENT_BOTTOM                       (5)

#define CTL_GAP_Y                           (5)
#define PIPS_LABEL_GAP_Y                    (50)

#define LABEL_HEIGHT                        (35)
#define BUTTON_HEIGHT                       (30)

#define LABEL_FONT_SIZE                     (14)

#define SLIP_PAGE                           (3)

class CTradeDialog : public CDialog
  {
private:
   CEdit                   m_total_pips_label;
   CButton                 m_close_all_button;
   CButton                 m_close_current_button;
   CButton                 m_delete_pips_button;

   CPipsLabelProcessor     *m_pips_label_processor;

   CChart                  m_chart;
   bool                    m_destroyed;

public:
                           CTradeDialog(void);
                           ~CTradeDialog(void);

   bool                    Create(const long chart,const string name,const int subwin);
   virtual bool            OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   virtual void            Destroy(const int reason=REASON_PROGRAM);

   void                    ChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   void                    UpdatePips(void);

protected:
   bool                    CreateTotalPipsLabel(void);
   bool                    CreateCloseAllButton(void);
   bool                    CreateCloseCurrentButton(void);
   bool                    CreateDeletePipsButton(void);

   virtual void            OnClickButtonClose(void);
   void                    OnClickCloseAllButton(void);
   void                    OnClickCloseCurrentButton(void);
   void                    OnClickDeletePipsButton(void);
   bool                    OnDefault(const int id,const long &lparam,const double &dparam,const string &sparam) { return(false); };

private:
   void                    CloseOrders(bool all);
   bool                    UpdateTotalPipsLabel(void);
  };

EVENT_MAP_BEGIN(CTradeDialog)
ON_EVENT(ON_CLICK,m_close_all_button,OnClickCloseAllButton)
ON_EVENT(ON_CLICK,m_close_current_button,OnClickCloseCurrentButton)
ON_EVENT(ON_CLICK,m_delete_pips_button,OnClickDeletePipsButton)
ON_OTHER_EVENTS(OnDefault)
EVENT_MAP_END(CDialog)

CTradeDialog::CTradeDialog(void) : m_destroyed(false)
  {
   m_pips_label_processor = new CPipsLabelProcessor;
  }

CTradeDialog::~CTradeDialog(void)
  {
   delete m_pips_label_processor;
  }

bool CTradeDialog::Create(const long chart,const string name,const int subwin)
  {
   if(m_destroyed)
      return(false);

   int x1 = DIALOG_LEFT;
   int y1 = DIALOG_TOP;

   if(!CDialog::Create(chart,name,subwin,x1,y1,x1+DIALOG_WIDTH,y1+DIALOG_HEIGHT))
      return(false);

   m_chart.Attach(chart);
   if(!m_chart.EventMouseMove())
      return(false);

   m_pips_label_processor.PipsLabelCreateParam(m_chart_id, m_name, m_subwin, x1, y1 + DIALOG_HEIGHT + PIPS_LABEL_GAP_Y);
   
   if(!CreateTotalPipsLabel())
      return(false);
   if(!CreateCloseAllButton())
      return(false);
   if(!CreateCloseCurrentButton())
      return(false);
   if(!CreateDeletePipsButton())
      return(false);

   Id(0);
   
   return(true);
  }

void CTradeDialog::Destroy(int reason)
  {
   if(m_destroyed)
      return;

   m_chart.Detach();
   CDialog::Destroy(reason);
   ExpertRemove();
   m_destroyed = true;
  }

bool CTradeDialog::CreateTotalPipsLabel(void)
  {
   int x1 = INDENT_LEFT;
   int y1 = INDENT_TOP;
   int x2 = ClientAreaWidth()-INDENT_RIGHT;
   int y2 = y1+LABEL_HEIGHT;

   if(!m_total_pips_label.Create(m_chart_id,m_name+"TotalPipsLabel",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!UpdateTotalPipsLabel())
      return(false);
   if(!m_total_pips_label.FontSize(LABEL_FONT_SIZE))
      return(false);
   if(!m_total_pips_label.ReadOnly(true))
      return(false);
   if(!Add(m_total_pips_label))
      return(false);

   return(true);
  }

bool CTradeDialog::CreateCloseAllButton(void)
  {
   int x1 = INDENT_LEFT;
   int y1 = INDENT_TOP + LABEL_HEIGHT + CTL_GAP_Y;
   int x2 = ClientAreaWidth()-INDENT_RIGHT;
   int y2 = y1+BUTTON_HEIGHT;

   if(!m_close_all_button.Create(m_chart_id,m_name+"CloseAllButton",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_close_all_button.Text("Close All Positions"))
      return(false);
   if(!Add(m_close_all_button))
      return(false);

   return(true);
  }

bool CTradeDialog::CreateCloseCurrentButton(void)
  {
   int x1 = INDENT_LEFT;
   int y1 = INDENT_TOP + LABEL_HEIGHT + BUTTON_HEIGHT + 2*CTL_GAP_Y;
   int x2 = ClientAreaWidth()-INDENT_RIGHT;
   int y2 = y1+BUTTON_HEIGHT;

   if(!m_close_current_button.Create(m_chart_id,m_name+"CloseCurrentButton",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_close_current_button.Text("Close Current Pair"))
      return(false);
   if(!Add(m_close_current_button))
      return(false);

   return(true);
  }

bool CTradeDialog::CreateDeletePipsButton(void)
  {
   int x1 = INDENT_LEFT;
   int y1 = INDENT_TOP + LABEL_HEIGHT + 2*BUTTON_HEIGHT + 3*CTL_GAP_Y;
   int x2 = ClientAreaWidth()-INDENT_RIGHT;
   int y2 = y1+BUTTON_HEIGHT;

   if(!m_delete_pips_button.Create(m_chart_id,m_name+"DeletePipsButton",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_delete_pips_button.Text("Delte Pips Labels"))
      return(false);
   if(!Add(m_delete_pips_button))
      return(false);

   return(true);
  }

void CTradeDialog::ChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   int mouse_x=(int)lparam;
   int mouse_y=(int)dparam;

   switch(id)
     {
      case CHARTEVENT_MOUSE_MOVE:
         OnMouseEvent(mouse_x,mouse_y,(int)StringToInteger(sparam));
         break;

      case CHARTEVENT_CHART_CHANGE:
         UpdatePips();
         break;

      default:
         OnEvent(id, lparam, dparam, sparam);
         break;
     }

   m_pips_label_processor.ChartEvent(id, lparam, dparam, sparam);
  }

void CTradeDialog::UpdatePips(void)
  {
   m_pips_label_processor.Update();
   UpdateTotalPipsLabel();
  }

void CTradeDialog::OnClickButtonClose(void)
  {
   Destroy();
  }

void CTradeDialog::OnClickCloseAllButton(void)
  {
   CloseOrders(true);
  }

void CTradeDialog::OnClickCloseCurrentButton(void)
  {
   CloseOrders(false);
  }

void CTradeDialog::OnClickDeletePipsButton(void)
  {
   m_pips_label_processor.Clear();
  }

void CTradeDialog::CloseOrders(bool all)
  {
   const int total = OrdersTotal();
   if(total == 0) {
      return;
   }

   int tickets[];
   if(ArrayResize(tickets, total) == -1)
      return;
   
   int i;
   for(i=0; i<total; i++) {
      if(!OrderSelect(i, SELECT_BY_POS)) {
         Print(ErrorDescription(GetLastError()));
         tickets[i] = 0;
         continue;
      }

      tickets[i] = OrderTicket();
   }

   PlaySound("ok.wav");

   for(i=0; i<total; i++) {
      int ticket = tickets[i];
      if(!OrderSelect(ticket, SELECT_BY_TICKET)) {
         Print(ErrorDescription(GetLastError()));
         continue;
      }

      string symbol = OrderSymbol();
      if(!all && symbol != Symbol()) {
         continue;
      }

      double close_price;
      switch(OrderType()) {
      case OP_BUY:
         close_price = MarketInfo(symbol, MODE_BID);
         break;
      case OP_SELL:
         close_price = MarketInfo(symbol, MODE_ASK);
         break;
      default: 
         close_price = 0;
         break;
      }

      if(close_price > 0) {
         if(!OrderClose(ticket, OrderLots(), close_price, SLIP_PAGE, CLR_NONE)) {
            Print(ErrorDescription(GetLastError()));
         }
      }
   }

   PlaySound("ok.wav");
   ArrayFree(tickets);
  }

bool CTradeDialog::UpdateTotalPipsLabel(void)
  {
   double total_pips = m_pips_label_processor.GetTotalPips();
   color clr = m_pips_label_processor.GetTotalStatusColor();
   string text = "  Total " + DoubleToStr(total_pips, 1) + " pips";

   if(!m_total_pips_label.Text(text))
      return(false);
   if(!m_total_pips_label.Color(clr))
      return(false);

   return(true);
  }
