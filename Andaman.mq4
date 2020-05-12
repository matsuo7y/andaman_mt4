//+------------------------------------------------------------------+
//|                                                      Andaman.mq4 |
//|                                     Copyright 2020, Yuki Matsuo. |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Yuki Matsuo."
#property link      ""
#property version   "1.00"
#property strict

#include "include/TradeDialog.mqh"

CTradeDialog            *trade_dialog;
CTradeDialogState       *trade_dialog_state;

int OnInit(void)
  {
   if(trade_dialog_state == NULL) {
      trade_dialog_state = new CTradeDialogState;
   }
   trade_dialog = new CTradeDialog(trade_dialog_state);

   if(!trade_dialog.Create(0,"Trade Controller",0))
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
      delete trade_dialog_state;
      trade_dialog_state = NULL;
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
