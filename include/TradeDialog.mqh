//+------------------------------------------------------------------+
//|                                                  TradeDialog.mqh |
//|                                     Copyright 2020, Yuki Matsuo. |
//+------------------------------------------------------------------+
#include <Controls\Dialog.mqh>
#include <Controls\Button.mqh>
#include <stdlib.mqh>

#include "PipsLabelProcessor.mqh"

#define DIALOG_LEFT                         (1500)
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

class CTradeDialogState
  {
private:
   int                     m_left;
   int                     m_top;
   CPipsLabelProcessor     *m_pips_label_processor;

public:
                           CTradeDialogState(void);
                           ~CTradeDialogState(void);

   int                     Left(void) { return m_left; };
   void                    Left(int left) { m_left = left; };
   int                     Top(void) { return m_top; };
   void                    Top(int top) { m_top = top; };

   CPipsLabelProcessor     *PipsLabelProcessor(void) { return m_pips_label_processor; };

   void                    Update(int left, int top) { Left(left); Top(top); };
  };

CTradeDialogState::CTradeDialogState(void) : m_left(DIALOG_LEFT),
                                             m_top(DIALOG_TOP)
  {
   m_pips_label_processor = new CPipsLabelProcessor;
  }

CTradeDialogState::~CTradeDialogState(void)
  {
   delete m_pips_label_processor;
  }

class CTradeDialog : public CAppDialog
  {
private:
   CEdit                   m_total_pips_label;
   CButton                 m_close_all_button;
   CButton                 m_close_current_button;
   CButton                 m_delete_pips_button;

   CPipsLabelProcessor     *m_pips_label_processor;

   CTradeDialogState       *m_state;

public:
                           CTradeDialog(CTradeDialogState *state);
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

   void                    OnClickCloseAllButton(void);
   void                    OnClickCloseCurrentButton(void);
   void                    OnClickDeletePipsButton(void);
   bool                    OnDefault(const int id,const long &lparam,const double &dparam,const string &sparam);

private:
   void                    CloseOrders(bool all);
   bool                    UpdateTotalPipsLabel(void);
  };

EVENT_MAP_BEGIN(CTradeDialog)
ON_EVENT(ON_CLICK,m_close_all_button,OnClickCloseAllButton)
ON_EVENT(ON_CLICK,m_close_current_button,OnClickCloseCurrentButton)
ON_EVENT(ON_CLICK,m_delete_pips_button,OnClickDeletePipsButton)
ON_OTHER_EVENTS(OnDefault)
EVENT_MAP_END(CAppDialog)

CTradeDialog::CTradeDialog(CTradeDialogState *state)
  {
     m_state = state;
  }

CTradeDialog::~CTradeDialog(void)
  {
  }

bool CTradeDialog::Create(const long chart,const string name,const int subwin)
  {
   int x1 = m_state.Left();
   int y1 = m_state.Top();

   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x1+DIALOG_WIDTH,y1+DIALOG_HEIGHT))
      return(false);

   m_pips_label_processor = m_state.PipsLabelProcessor();
   m_pips_label_processor.PipsLabelCreateParam(m_chart_id, m_name, m_subwin, Left(), Top() + DIALOG_HEIGHT + PIPS_LABEL_GAP_Y);
   
   if(!CreateTotalPipsLabel())
      return(false);
   if(!CreateCloseAllButton())
      return(false);
   if(!CreateCloseCurrentButton())
      return(false);
   if(!CreateDeletePipsButton())
      return(false);
   
   return(true);
  }

void CTradeDialog::Destroy(const int reason)
  {
   m_state.Update(Left(), Top());

   CAppDialog::Destroy(reason);
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
   CAppDialog::ChartEvent(id, lparam, dparam, sparam);
   m_pips_label_processor.ChartEvent(id, lparam, dparam, sparam);
  }

void CTradeDialog::UpdatePips(void)
  {
   m_pips_label_processor.Update();
   UpdateTotalPipsLabel();
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

bool CTradeDialog::OnDefault(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   return(false);
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

   for(i=0; i<total; i++) {
      int ticket = tickets[i];
      if(!OrderSelect(ticket, SELECT_BY_TICKET)) {
         Print(ErrorDescription(GetLastError()));
         continue;
      }

      if(!all && OrderSymbol() != Symbol())
         continue;

      double close_price;
      switch(OrderType()) {
      case OP_BUY:
         close_price = Bid;
         break;
      case OP_SELL:
         close_price = Ask;
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
