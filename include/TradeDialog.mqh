//+------------------------------------------------------------------+
//|                                                  TradeDialog.mqh |
//|                                     Copyright 2020, Yuki Matsuo. |
//+------------------------------------------------------------------+
#include <Controls\Dialog.mqh>
#include <Controls\Button.mqh>

#include "PipsLabel.mqh"

#define DIALOG_WIDTH                        (200)
#define DIALOG_HEIGHT                       (140)

#define INDENT_LEFT                         (5) 
#define INDENT_TOP                          (5)
#define INDENT_RIGHT                        (5)
#define INDENT_BOTTOM                       (5)

#define CTL_GAP_Y                           (5)

#define BUTTON_HEIGHT                       (30)

class CTradeDialog : public CAppDialog
  {
private:
   CButton           m_close_all_button;
   CButton           m_close_current_button;
   CButton           m_delete_pips_button;

   CPipsLabel*        m_pips_label;

public:
                     CTradeDialog(void);
                    ~CTradeDialog(void);

   virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);

   void              ChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);

protected:
   bool              CreateCloseAllButton(void);
   bool              CreateCloseCurrentButton(void);
   bool              CreateDeletePipsButton(void);

   void              OnClickCloseAllButton(void);
   void              OnClickCloseCurrentButton(void);
   void              OnClickDeletePipsButton(void);
   bool              OnDefault(const int id,const long &lparam,const double &dparam,const string &sparam);
  };

EVENT_MAP_BEGIN(CTradeDialog)
ON_EVENT(ON_CLICK,m_close_all_button,OnClickCloseAllButton)
ON_EVENT(ON_CLICK,m_close_current_button,OnClickCloseCurrentButton)
ON_EVENT(ON_CLICK,m_delete_pips_button,OnClickDeletePipsButton)
ON_OTHER_EVENTS(OnDefault)
EVENT_MAP_END(CAppDialog)

CTradeDialog::CTradeDialog(void)
  {
  }

CTradeDialog::~CTradeDialog(void)
  {
   if(m_pips_label)
      delete m_pips_label;
  }

bool CTradeDialog::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {
   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x1+DIALOG_WIDTH,y1+DIALOG_HEIGHT))
      return(false);
   if(!CreateCloseAllButton())
      return(false);
   if(!CreateCloseCurrentButton())
      return(false);
   if(!CreateDeletePipsButton())
      return(false);
   return(true);
  }

bool CTradeDialog::CreateCloseAllButton(void)
  {
   int x1 = INDENT_LEFT;
   int y1 = INDENT_TOP;
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
   int y1 = INDENT_TOP + BUTTON_HEIGHT + CTL_GAP_Y;
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
   int y1 = INDENT_TOP + 2*(BUTTON_HEIGHT + CTL_GAP_Y);
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
   if(m_pips_label)
      m_pips_label.OnEvent(id, lparam, dparam, sparam);
  }


void CTradeDialog::OnClickCloseAllButton(void)
  {
   if(m_pips_label)
      return;

   m_pips_label = new CPipsLabel;

   m_pips_label.Create(m_chart_id,m_name+"PipsLabel",m_subwin,Left(),Top()+DIALOG_HEIGHT+50,0,0);
  }

void CTradeDialog::OnClickCloseCurrentButton(void)
  {
   Print(__FUNCTION__);
  }

void CTradeDialog::OnClickDeletePipsButton(void)
  {
   delete m_pips_label;
   m_pips_label = NULL;
  }

bool CTradeDialog::OnDefault(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   return(false);
  }
