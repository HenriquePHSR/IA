//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+

//--- available signals
#include <Expert\Signal\SignalAC.mqh>
//--- available trailing
#include <Expert\Trailing\TrailingNone.mqh>
//--- available money management
#include <Expert\Money\MoneyFixedLot.mqh>
#define EXPERT_MAGIC Expert_MagicNumber
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string Expert_Title         ="order_handler"; // Document name
ulong        Expert_MagicNumber   =23805;          // 
bool         Expert_EveryTick     =false;          // 
//--- inputs for main signal
input int    Signal_ThresholdOpen =10;             // Signal threshold value to open [0...100]
input int    Signal_ThresholdClose=10;             // Signal threshold value to close [0...100]
input double Signal_PriceLevel    =0.0;            // Price level to execute a deal
input double Signal_StopLevel     =0.50;           // Stop Loss level (in points)
input double Signal_TakeLevel     =1000.0;           // Take Profit level (in points)
input int    Signal_Expiration    =4;              // Expiration of pending orders (in bars)
input double Signal_AC_Weight     =1.0;            // Accelerator Oscillator Weight [0...1.0]
//--- inputs for money
input double Money_FixLot_Lots=1.0;            // Fixed volume
int fh_comm;
int quote;
int bought_pos = 0;
int sell_pos = 0;
//+------------------------------------------------------------------+
//| Global expert object                                             |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Initialization function of the expert                            |
//+------------------------------------------------------------------+
int OnInit()
  {
  
   EventSetTimer(1);
//--- Initializing expert
   
//--- ok
   Print("INIT_SUCCEEDED");
   return 0;
  }
//+------------------------------------------------------------------+
//| Deinitialization function of the expert                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   
  }
//+------------------------------------------------------------------+
//| "Tick" event handler function                                    |
//+------------------------------------------------------------------+
void OnTick()
  {
   
   
  }
//+------------------------------------------------------------------+
//| "Trade" event handler function                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
   
  }
//+------------------------------------------------------------------+
//| "Timer" event handler function                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   fh_comm=FileOpen("buffer_1", FILE_READ|FILE_BIN);
   quote=FileReadFloat(fh_comm);
   FileClose(fh_comm);
   //PositionsTotal() == 0
   if (quote>0 && bought_pos==0 && sell_pos==0) {
         
         
         //--- Atualização e inicialização do pedido e o seu resultado
         MqlTradeRequest request={0};
         MqlTradeResult  result={0};
//--- parâmetros do pedido
         request.action   =TRADE_ACTION_DEAL;                     // tipo de operação de negociação
         request.symbol   =Symbol();                              // símbolo
         request.volume   =1.0;                                   // volume de 1.0 lotes
         request.type     =ORDER_TYPE_BUY;                        // tipo de ordem
         request.price    =SymbolInfoDouble(Symbol(),SYMBOL_ASK); // preço para abertura
         //request.sl       =SymbolInfoDouble(Symbol(),SYMBOL_ASK) - 2.5; stoploss
         request.deviation=5;                                     // desvio permitido do preço
         request.magic    =EXPERT_MAGIC;                          // MagicNumber da ordem
//--- envio do pedido
         if(!OrderSend(request,result)) {
              PrintFormat("OrderSend error %d",GetLastError());     
         }
         else {
            bought_pos = 1;
            //Print("a_buy_order_command");
         }
         // se não for possível enviar o pedido, sairá um código de erro
//--- informação sobre a operação
         Print("a_buy_order_command");
         PrintFormat("order price=%.3e", request.price);
         PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
         
         
         
   }
   if (quote<0 && bought_pos==0 && sell_pos==0) {
         
         
         MqlTradeRequest request={0};
         MqlTradeResult  result={0};
//--- parâmetros do pedido
         request.action   =TRADE_ACTION_DEAL;                     // tipo de operação de negociação
         request.symbol   =Symbol();                              // símbolo
         request.volume   =1.0;                                   // volume de 0.2 lotes
         request.type     =ORDER_TYPE_SELL;                       // tipo da ordem
         request.price    =SymbolInfoDouble(Symbol(),SYMBOL_BID); // preço para a abertura
         request.deviation=5;                                     // desvio permitido do preço
         request.magic    =EXPERT_MAGIC;                          // MagicNumber da ordem
//--- envio do pedido
         if(!OrderSend(request,result)) {
            PrintFormat("OrderSend error %d",GetLastError());
         }
         else {
            sell_pos = 1;
            //Print("a_sell_order_command");
            
         }   // se não for possível enviar o pedido, exibir um código de erro
//--- informação sobre a operação
         Print("a_sell_order_command");
         PrintFormat("order price=%.3e", request.price);
         //PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
         
         
         
   }
   if (quote<=0 && bought_pos==1) {
         
         
         MqlTradeRequest request={0};
         MqlTradeResult  result={0};
//--- parâmetros do pedido
         request.action   =TRADE_ACTION_DEAL;                     // tipo de operação de negociação
         request.symbol   =Symbol();                              // símbolo
         request.volume   =1.0;                                   // volume de 0.2 lotes
         request.type     =ORDER_TYPE_SELL;                       // tipo da ordem
         request.price    =SymbolInfoDouble(Symbol(),SYMBOL_BID); // preço para a abertura
         request.deviation=5;                                     // desvio permitido do preço
         request.magic    =EXPERT_MAGIC;                          // MagicNumber da ordem
//--- envio do pedido
         if(!OrderSend(request,result)) {
            PrintFormat("OrderSend error %d",GetLastError());     
         }
         else {
            bought_pos = 0;
            //Print("a_sell_order_command");
         }
         // se não for possível enviar o pedido, exibir um código de erro
//--- informação sobre a operação
         Print("a_sell_order_command");
         PrintFormat("order price=%.3e", request.price);
         //PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
         
         
         
   }
   if (quote>=0 && sell_pos==1) {
         
         
         //--- Atualização e inicialização do pedido e o seu resultado
         MqlTradeRequest request={0};
         MqlTradeResult  result={0};
//--- parâmetros do pedido
         request.action   =TRADE_ACTION_DEAL;                     // tipo de operação de negociação
         request.symbol   =Symbol();                              // símbolo
         request.volume   =1.0;                                   // volume de 1.0 lotes
         request.type     =ORDER_TYPE_BUY;                        // tipo de ordem
         request.price    =SymbolInfoDouble(Symbol(),SYMBOL_ASK); // preço para abertura
         //request.sl       =SymbolInfoDouble(Symbol(),SYMBOL_ASK) - 2.5; stoploss
         request.deviation=5;                                     // desvio permitido do preço
         request.magic    =EXPERT_MAGIC;                          // MagicNumber da ordem
//--- envio do pedido
         if(!OrderSend(request,result)){
               PrintFormat("OrderSend error %d",GetLastError());     
         }
         else {
            sell_pos = 0;
            //Print("a_buy_order_command");
         }
         // se não for possível enviar o pedido, sairá um código de erro
//--- informação sobre a operação
         Print("a_buy_order_command");
         PrintFormat("order price=%.3e", request.price);
         //PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
         
         
         
   }
  
   
  }
//+------------------------------------------------------------------+
string GetTickDescription(MqlTick &tick) { 
   string desc=StringFormat("%s:%03d",
                            TimeToString(tick.time),tick.time_msc%1000); //
//--- Checando flags 
   bool buy_tick=((tick.flags&TICK_FLAG_BUY)==TICK_FLAG_BUY); 
   bool sell_tick=((tick.flags&TICK_FLAG_SELL)==TICK_FLAG_SELL); 
   bool ask_tick=((tick.flags&TICK_FLAG_ASK)==TICK_FLAG_ASK); 
   bool bid_tick=((tick.flags&TICK_FLAG_BID)==TICK_FLAG_BID); 
   bool last_tick=((tick.flags&TICK_FLAG_LAST)==TICK_FLAG_LAST); 
   bool volume_tick=((tick.flags&TICK_FLAG_VOLUME)==TICK_FLAG_VOLUME); 
//--- Verificar flags de negociação num primeiro tick 
   if(buy_tick || sell_tick) 
     { 
      //--- Formando uma saída para o tick de negociação 
      desc=desc+(buy_tick?StringFormat(",%G,%G,%G,%G,Buy",tick.bid,tick.ask,tick.last,tick.volume):"");               
      desc=desc+(sell_tick?StringFormat(",%G,%G,%G,%G,Sell",tick.bid,tick.ask,tick.last,tick.volume):"");
      
      /*
      desc=desc+(buy_tick?StringFormat("Buy Tick: Last=%G Volume=%d ",tick.last,tick.volume):""); 
      desc=desc+(sell_tick?StringFormat("Sell Tick: Last=%G Volume=%d ",tick.last,tick.volume):""); 
      desc=desc+(ask_tick?StringFormat("Ask=%G ",tick.ask):""); 
      desc=desc+(bid_tick?StringFormat("Bid=%G ",tick.ask):""); 
      desc=desc+"(Trade tick)"; */
     } 
   else 
     { 
      //--- Forme uma saída diferente para um tick de informação 
      
      desc = "";
      
      /*
      desc=desc+(ask_tick?StringFormat("Ask=%G ",tick.ask):""); 
      desc=desc+(bid_tick?StringFormat("Bid=%G ",tick.ask):""); 
      desc=desc+(last_tick?StringFormat("Last=%G ",tick.last):""); 
      desc=desc+(volume_tick?StringFormat("Volume=%d ",tick.volume):""); 
      desc=desc+"(Info tick)";*/
       
     } 
//--- Retornando descrição do tick 
   return desc; 
  } 
//+------------------------------------------------------------------+