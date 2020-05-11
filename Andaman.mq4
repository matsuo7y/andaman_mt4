//+------------------------------------------------------------------+
//|                                                      Andaman.mq4 |
//|                                     Copyright 2020, Yuki Matsuo. |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Yuki Matsuo."
#property link      ""
#property version   "1.00"
#property strict

#include "include/TradeDialog.mqh"
#include "include/PipsLabelProcessor.mqh"

#define TD_X (1500)
#define TD_Y (30)

CTradeDialog            *trade_dialog;
CPipsLabelProcessor     *pips_label_processor;

int OnInit(void)
  {
   if(pips_label_processor == NULL) {
      pips_label_processor = new CPipsLabelProcessor;
   }
   trade_dialog = new CTradeDialog(pips_label_processor);

   if(!trade_dialog.Create(0,"Trade Controller",0,TD_X,TD_Y,0,0))
     return(INIT_FAILED);

   if(!trade_dialog.Run())
     return(INIT_FAILED);

   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   trade_dialog.Destroy(reason);
   delete trade_dialog;

   if(reason != REASON_CHARTCHANGE) {
      delete pips_label_processor;
      pips_label_processor = NULL;
   }
  }

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(trade_dialog) {
      trade_dialog.ChartEvent(id,lparam,dparam,sparam);
   }
  }

void OnTick(void)
  {
   if(trade_dialog) {
      trade_dialog.UpdatePips();
   }
  }
