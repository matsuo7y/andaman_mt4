//+------------------------------------------------------------------+
//|                                           PipsLabelProcessor.mqh |
//|                                     Copyright 2020, Yuki Matsuo. |
//+------------------------------------------------------------------+
#include "PipsLabel.mqh"
#include "HashMap.mqh"
#include <Arrays\List.mqh>
#include <stdlib.mqh>

class CPipsLabelProcessor
  {
private:
   CHashMap     *m_hash_map;
   CList        *m_list;

   double       m_total_pips;
   double       m_total_profit;
   double       m_total_commission;

   long         m_chart;
   string       m_name;
   int          m_subwin;
   int          m_x1;
   int          m_y1;
   int          m_x2;
   int          m_y2;

public:
                CPipsLabelProcessor(void);
                ~CPipsLabelProcessor(void);

   bool         OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   void         PipsLabelCreateParam(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);

   void         Update(void);
   double       GetTotalPips(void);
   color        GetTotalStatusColor(void);

   void         Clear(void);

private:
   CPipsLabel   *Add(int ticket);
   CPipsLabel   *Get(int ticket);
   color        GetStatusColor(double pips, double commission);
   void         ClearTradeValues();
   void         PrintLastError();
  };

CPipsLabelProcessor::CPipsLabelProcessor(void) : m_total_pips(0)
  {
   m_hash_map = new CHashMap;
   m_list = new CList;
  }

CPipsLabelProcessor::~CPipsLabelProcessor(void)
  {
   delete m_hash_map;
   delete m_list;
  }

bool CPipsLabelProcessor::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   CPipsLabel *pips_label = dynamic_cast<CPipsLabel*>(m_list.GetFirstNode());

   while(pips_label != NULL) {
      pips_label.OnEvent(id, lparam, dparam, sparam);
      pips_label = dynamic_cast<CPipsLabel*>(m_list.GetNextNode());
   }

   return(true);
  }

void CPipsLabelProcessor::PipsLabelCreateParam(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {
   m_chart = chart;
   m_name = name;
   m_subwin = subwin;
   m_x1 = x1;
   m_y1 = y1;
   m_x2 = x2;
   m_y2 = y2;
  }

void CPipsLabelProcessor::Update(void)
  {
   ClearTradeValues();

   for(int i=0; i<OrdersTotal(); i++) {
      if(!OrderSelect(i, SELECT_BY_POS)) {
         PrintLastError();      
         continue;
      }

      if(OrderSymbol() != Symbol())
         continue;

      double profit = OrderProfit();
      double commission = OrderCommission();

      double pips = (profit/OrderLots())/1000.0;

      m_total_pips += pips;
      m_total_profit += profit;
      m_total_commission += commission;

      color clr = GetStatusColor(profit, commission);

      int ticket = OrderTicket();
      CPipsLabel *pips_label = Get(ticket);
      if(pips_label == NULL)
         pips_label = Add(ticket);

      pips_label.Pips(pips);
      pips_label.Color(clr);
   }
  }

double CPipsLabelProcessor::GetTotalPips(void)
  {
   return m_total_pips;
  }

color CPipsLabelProcessor::GetTotalStatusColor(void)
  {
   return GetStatusColor(m_total_profit, m_total_commission);
  }

void CPipsLabelProcessor::Clear(void)
  {
   m_hash_map.Clear();
   m_list.Clear();
   ClearTradeValues();
  }

CPipsLabel* CPipsLabelProcessor::Add(int ticket)
  {
   CPipsLabel *pips_label = new CPipsLabel;
   pips_label.Create(m_chart, m_name+IntegerToString(ticket), m_subwin, m_x1, m_y1, m_x2, m_y2);

   m_hash_map.Add(ticket, pips_label);
   m_list.Add(pips_label);

   return pips_label;
  }

CPipsLabel* CPipsLabelProcessor::Get(int ticket)
  {
   return m_hash_map.Get(ticket);
  }

color CPipsLabelProcessor::GetStatusColor(double profit, double commission)
  {
   if(profit + commission >= 0) {
         return Blue;
      } else {
         if(profit >= 0) {
            return Gold;
         } else {
            return Red;
         }
      }
  }

void CPipsLabelProcessor::ClearTradeValues(void)
  {
   m_total_pips = 0;
   m_total_profit = 0;
   m_total_commission = 0;
  }

void CPipsLabelProcessor::PrintLastError(void)
  {
   int error = GetLastError();
   Print(ErrorDescription(error));
  }
