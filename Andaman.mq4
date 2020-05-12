//+------------------------------------------------------------------+
//|                                                      Andaman.mq4 |
//|                                     Copyright 2020, Yuki Matsuo. |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Yuki Matsuo."
#property link      ""
#property version   "1.00"
#property strict

#include "include/TradeDialog.mqh"

CTradeDialog *trade_dialog;

int OnInit(void)
  {
   if(trade_dialog == NULL) {
      trade_dialog = new CTradeDialog;

      if(!trade_dialog.Create(0,"Trade Controller",0))
         return(INIT_FAILED);

      if(!trade_dialog.Run())
         return(INIT_FAILED);
   }
   
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   switch(reason) 
     {
      case REASON_PROGRAM:
      case REASON_REMOVE:
      case REASON_RECOMPILE:
      case REASON_CHARTCLOSE:
      case REASON_PARAMETERS:
      case REASON_INITFAILED:
         trade_dialog.Destroy(reason);
         delete trade_dialog;
         trade_dialog = NULL;
         break;

      default:
         break;
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
