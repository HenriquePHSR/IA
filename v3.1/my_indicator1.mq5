//+------------------------------------------------------------------+
//|                                                 my_indicator.mq5 |
//|                                                   Copyright 2020 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020"
#property link      ""
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots 2

#property indicator_type1 DRAW_ARROW
#property indicator_label1 "label_ind1"
#property indicator_color1 clrDarkBlue
//#property indicator_style1 STYLE_DASH
#property indicator_width1 3

#property indicator_type2 DRAW_ARROW
#property indicator_label2 "label_ind2"
#property indicator_color2 clrDarkGray
//#property indicator_style2 STYLE_DASH
#property indicator_width2 3

int         i_handle[37];           // manipulador do indicador
int         i_handle_M5[37];
int         i_handle_M10[37];
int         i_handle_H1[37];
input ENUM_TIMEFRAMES      custom_period=PERIOD_M1;
input ENUM_TIMEFRAMES      custom_period_M5=PERIOD_M5;
input ENUM_TIMEFRAMES      custom_period_M10=PERIOD_M10;
input ENUM_TIMEFRAMES      custom_period_H1=PERIOD_H1;



double Buffer[];
double Buffer1[];
int aux=0;
double quote;
double quote1;
MqlTick tick_array[];
int retreived;
string tick_txt;
string stg_temp;
int i_handle_lenght = 37;
double i_values[37][1];
int custom_i_list_len = 9;
int custom_i_list[9];
int fh_comm;
int fh_comm_2;
int test = 0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   EventSetTimer(1); // taxa de atualização
   SetIndexBuffer(0,Buffer, INDICATOR_DATA);
   PlotIndexSetInteger(0,PLOT_SHIFT,1);
   PlotIndexSetInteger(0,PLOT_ARROW,240);
//---
   SetIndexBuffer(1,Buffer1, INDICATOR_DATA);
   PlotIndexSetInteger(1,PLOT_SHIFT,1);
   PlotIndexSetInteger(1,PLOT_ARROW,240);


   custom_i_list[0] = 1;
   custom_i_list[1] = 28;
   custom_i_list[2] = 22;
   custom_i_list[3] = 31;
   custom_i_list[4] = 36;
   custom_i_list[5] = 16;
   custom_i_list[6] = 0;
   custom_i_list[7] = 26;
   custom_i_list[8] = 11;

   i_handle_M5[0]=iAC(NULL,custom_period_M5); // Accelerator Oscillator
   i_handle_M5[1]=iAD(NULL,custom_period_M5,VOLUME_REAL); // Accumulation/Distribution
   i_handle_M5[2]=iADX(NULL,custom_period_M5,14); // not ready - Average Directional Movement
   i_handle_M5[3]=iADXWilder(NULL,custom_period_M5,14);  // not ready - Average Directional Movement Index por Welles Wilder
   i_handle_M5[4]=iAlligator(NULL,custom_period_M5,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN); // not ready 
   i_handle_M5[5]=iAMA(NULL,custom_period_M5,15,2,30,0,PRICE_MEDIAN); // Adaptive Moving Average
   i_handle_M5[6]=iAO(NULL,custom_period_M5);  // Awesome Oscillator
   i_handle_M5[7]=iATR(NULL,custom_period_M5,14);  // Average True Range
   i_handle_M5[8]=iBearsPower(NULL,custom_period_M5,13); 
   i_handle_M5[9]=iBands(NULL,custom_period_M5,20,0,2.0,PRICE_CLOSE);  // not ready - Bollinger Bands
   i_handle_M5[10]=iBullsPower(NULL,custom_period_M5,13);
   i_handle_M5[11]=iCCI(NULL,custom_period_M5,14,PRICE_TYPICAL);  // Commodity Channel Index
   i_handle_M5[12]=iChaikin(NULL,custom_period_M5,3,10,MODE_EMA,VOLUME_TICK);
   i_handle_M5[13]=iDEMA(NULL,custom_period_M5,14,0,PRICE_CLOSE);  // Double Exponential Moving Average
   i_handle_M5[14]=iDeMarker(NULL,custom_period_M5,14);  // Double DeMarker
   i_handle_M5[15]=iEnvelopes(NULL,custom_period_M5,14,0,MODE_SMA,PRICE_CLOSE,0.1);  // not ready - 
   i_handle_M5[16]=iForce(NULL,custom_period_M5,13,MODE_SMA,VOLUME_TICK);  // indicador Force Index
   i_handle_M5[17]=iFractals(NULL,custom_period_M5);  // not ready
   i_handle_M5[18]=iFrAMA(NULL,custom_period_M5,14,0,PRICE_CLOSE);  // Fractal Adaptive Moving Average
   i_handle_M5[19]=iIchimoku(NULL,custom_period_M5,9,26,52);  // indicador Ichimoku Kinko Hyo
   i_handle_M5[20]=iBWMFI(NULL,custom_period_M5,VOLUME_TICK);  //  indicador Market Facilitation Index
   i_handle_M5[21]=iMomentum(NULL,custom_period_M5,14,PRICE_CLOSE);
   i_handle_M5[22]=iMFI(NULL,custom_period_M5,14,VOLUME_TICK);  // Money Flow Index
   i_handle_M5[23]=iMA(NULL,custom_period_M5,10,0,MODE_SMA,PRICE_CLOSE);  // Moving Average
   i_handle_M5[24]=iOsMA(NULL,custom_period_M5,12,26,9,PRICE_CLOSE); // Moving Average of Oscillator
   i_handle_M5[25]=iMACD(NULL,custom_period_M5,12,26,9,PRICE_CLOSE);  // not ready - indicador Moving Averages Convergence/Divergence
   i_handle_M5[26]=iOBV(NULL,custom_period_M5,VOLUME_TICK);  // On Balance Volume
   i_handle_M5[27]=iSAR(NULL,custom_period_M5,0.02,0.2);  // indicador Parabolic Stop and Reverse system
   i_handle_M5[28]=iRSI(NULL,custom_period_M5,14,PRICE_CLOSE);  // Relative Strength Index
   i_handle_M5[29]=iRVI(NULL,custom_period_M5,10);  // Relative Vigor Index
   i_handle_M5[30]=iStdDev(NULL,custom_period_M5,20,0,MODE_SMA,PRICE_CLOSE);  // Standard Deviation
   i_handle_M5[31]=iStochastic(NULL,custom_period_M5,5,3,3,MODE_SMA,STO_LOWHIGH);  // indicador Stochastic Oscillator
   i_handle_M5[32]=iTEMA(NULL,custom_period_M5,14,0,PRICE_CLOSE);  // indicador Triple Exponential Moving Average
   i_handle_M5[33]=iTriX(NULL,custom_period_M5,14,PRICE_CLOSE);  //  indicador Triple Exponential Moving Averages Oscillator
   i_handle_M5[34]=iWPR(NULL,custom_period_M5,14);  // indicador Larry Williams' Percent Range
   i_handle_M5[35]=iVIDyA(NULL,custom_period_M5,15,12,0,PRICE_CLOSE);  // indicador Variable Index Dynamic Average
   i_handle_M5[36]=iVolumes(NULL,custom_period_M5,VOLUME_TICK);
   
   i_handle_M10[0]=iAC(NULL,custom_period_M10); // Accelerator Oscillator
   i_handle_M10[1]=iAD(NULL,custom_period_M10,VOLUME_REAL); // Accumulation/Distribution
   i_handle_M10[2]=iADX(NULL,custom_period_M10,14); // not ready - Average Directional Movement
   i_handle_M10[3]=iADXWilder(NULL,custom_period_M10,14);  // not ready - Average Directional Movement Index por Welles Wilder
   i_handle_M10[4]=iAlligator(NULL,custom_period_M10,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN); // not ready 
   i_handle_M10[5]=iAMA(NULL,custom_period_M10,15,2,30,0,PRICE_MEDIAN); // Adaptive Moving Average
   i_handle_M10[6]=iAO(NULL,custom_period_M10);  // Awesome Oscillator
   i_handle_M10[7]=iATR(NULL,custom_period_M10,14);  // Average True Range
   i_handle_M10[8]=iBearsPower(NULL,custom_period_M10,13); 
   i_handle_M10[9]=iBands(NULL,custom_period_M10,20,0,2.0,PRICE_CLOSE);  // not ready - Bollinger Bands
   i_handle_M10[10]=iBullsPower(NULL,custom_period_M10,13);
   i_handle_M10[11]=iCCI(NULL,custom_period_M10,14,PRICE_TYPICAL);  // Commodity Channel Index
   i_handle_M10[12]=iChaikin(NULL,custom_period_M10,3,10,MODE_EMA,VOLUME_TICK);
   i_handle_M10[13]=iDEMA(NULL,custom_period_M10,14,0,PRICE_CLOSE);  // Double Exponential Moving Average
   i_handle_M10[14]=iDeMarker(NULL,custom_period_M10,14);  // Double DeMarker
   i_handle_M10[15]=iEnvelopes(NULL,custom_period_M10,14,0,MODE_SMA,PRICE_CLOSE,0.1);  // not ready - 
   i_handle_M10[16]=iForce(NULL,custom_period_M10,13,MODE_SMA,VOLUME_TICK);  // indicador Force Index
   i_handle_M10[17]=iFractals(NULL,custom_period_M10);  // not ready
   i_handle_M10[18]=iFrAMA(NULL,custom_period_M10,14,0,PRICE_CLOSE);  // Fractal Adaptive Moving Average
   i_handle_M10[19]=iIchimoku(NULL,custom_period_M10,9,26,52);  // indicador Ichimoku Kinko Hyo
   i_handle_M10[20]=iBWMFI(NULL,custom_period_M10,VOLUME_TICK);  //  indicador Market Facilitation Index
   i_handle_M10[21]=iMomentum(NULL,custom_period_M10,14,PRICE_CLOSE);
   i_handle_M10[22]=iMFI(NULL,custom_period_M10,14,VOLUME_TICK);  // Money Flow Index
   i_handle_M10[23]=iMA(NULL,custom_period_M10,10,0,MODE_SMA,PRICE_CLOSE);  // Moving Average
   i_handle_M10[24]=iOsMA(NULL,custom_period_M10,12,26,9,PRICE_CLOSE); // Moving Average of Oscillator
   i_handle_M10[25]=iMACD(NULL,custom_period_M10,12,26,9,PRICE_CLOSE);  // not ready - indicador Moving Averages Convergence/Divergence
   i_handle_M10[26]=iOBV(NULL,custom_period_M10,VOLUME_TICK);  // On Balance Volume
   i_handle_M10[27]=iSAR(NULL,custom_period_M10,0.02,0.2);  // indicador Parabolic Stop and Reverse system
   i_handle_M10[28]=iRSI(NULL,custom_period_M10,14,PRICE_CLOSE);  // Relative Strength Index
   i_handle_M10[29]=iRVI(NULL,custom_period_M10,10);  // Relative Vigor Index
   i_handle_M10[30]=iStdDev(NULL,custom_period_M10,20,0,MODE_SMA,PRICE_CLOSE);  // Standard Deviation
   i_handle_M10[31]=iStochastic(NULL,custom_period_M10,5,3,3,MODE_SMA,STO_LOWHIGH);  // indicador Stochastic Oscillator
   i_handle_M10[32]=iTEMA(NULL,custom_period_M10,14,0,PRICE_CLOSE);  // indicador Triple Exponential Moving Average
   i_handle_M10[33]=iTriX(NULL,custom_period_M10,14,PRICE_CLOSE);  //  indicador Triple Exponential Moving Averages Oscillator
   i_handle_M10[34]=iWPR(NULL,custom_period_M10,14);  // indicador Larry Williams' Percent Range
   i_handle_M10[35]=iVIDyA(NULL,custom_period_M10,15,12,0,PRICE_CLOSE);  // indicador Variable Index Dynamic Average
   i_handle_M10[36]=iVolumes(NULL,custom_period_M10,VOLUME_TICK);
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
//--------------------------------
//--------------------------------
   if (aux == 0) {
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN, rates_total - 1);
      aux = 1;
   }
   fh_comm_2=FileOpen("buffer_1", FILE_READ|FILE_BIN);
   quote=FileReadFloat(fh_comm_2);
   FileClose(fh_comm_2);
   if (quote < 0) {
    Buffer[rates_total - 1] = price[rates_total-1] + quote;
    PlotIndexSetInteger(0,PLOT_ARROW,242);
   }
   if (quote > 0) {
      Buffer[rates_total - 1] = price[rates_total-1] + quote;
      PlotIndexSetInteger(0,PLOT_ARROW,241);
   }
   if (quote == 0) {
      Buffer[rates_total - 1] = price[rates_total-1];
      PlotIndexSetInteger(0,PLOT_ARROW,240);
   }
//-------------------------------
   fh_comm_2=FileOpen("buffer_3", FILE_READ|FILE_BIN);
   quote1=FileReadFloat(fh_comm_2);
   FileClose(fh_comm_2);
   if (quote1 < 0) {
    Buffer1[rates_total - 1] = price[rates_total-1] + quote1;
    PlotIndexSetInteger(1,PLOT_ARROW,242);
   }
   if (quote1 > 0) {
      Buffer1[rates_total - 1] = price[rates_total-1] + quote1;
      PlotIndexSetInteger(1,PLOT_ARROW,241);
   }
   if (quote1 == 0) {
      Buffer1[rates_total - 1] = price[rates_total-1];
      PlotIndexSetInteger(1,PLOT_ARROW,240);
   }
   Buffer[rates_total - 2] = 0;
   Buffer1[rates_total - 2] = 0;
//--- return value of prev_calculated for next call
   aux = rates_total;
   return(rates_total);
  }
//+------------------------------------------------------------------+}
//void OnTimer() { 
//}
void OnTimer() {
   retreived = CopyTicks(_Symbol,tick_array,COPY_TICKS_ALL,0);
   tick_txt = "";
   for (int k=0; k < ArraySize(i_handle); k++) {
      double temp[];
      CopyBuffer(i_handle_M5[k], 0,0,1,temp);  // copia todos os indicadores
      i_values[k][0] = temp[0];
   }
   tick_txt = StringFormat("%s",GetTickDescription(tick_array[0]));
   stg_temp = "";
   for (int j = 0; j < custom_i_list_len; j++) {   // seleciona somente os usados pelo modelo
      StringConcatenate(stg_temp, stg_temp,"; ", i_values[custom_i_list[j]][0]);  
   }
   StringConcatenate(tick_txt, tick_txt, stg_temp,"; ", test);
   
   
   fh_comm=FileOpen("buffer_0", FILE_WRITE, ' ',CP_UTF8);  // abre canal de envio para o modelo
   FileWrite(fh_comm, tick_txt);
   FileClose(fh_comm);
   
   tick_txt = "";
   for (int k=0; k < ArraySize(i_handle); k++) {
      double temp[];
      CopyBuffer(i_handle_M10[k], 0,0,1,temp);  // copia todos os indicadores
      i_values[k][0] = temp[0];
   }
   tick_txt = StringFormat("%s",GetTickDescription(tick_array[0]));
   stg_temp = "";
   for (int j = 0; j < custom_i_list_len; j++) {   // seleciona somente os usados pelo modelo
      StringConcatenate(stg_temp, stg_temp,"; ", i_values[custom_i_list[j]][0]);  
   }
   StringConcatenate(tick_txt, tick_txt, stg_temp,"; ", test);
   
   
   fh_comm=FileOpen("buffer_2", FILE_WRITE, ' ',CP_UTF8);  // abre canal de envio para o modelo
   FileWrite(fh_comm, tick_txt);
   FileClose(fh_comm);
   
   //Print(quote);
   //Print(quote1);
   test = test + 1; 
}

string GetTickDescription(MqlTick &tick) 
  { 
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