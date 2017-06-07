//+------------------------------------------------------------------+
//|                                                     Fractals.mq4 |
//|                                Copyright © 2009, Хлыстов Владимр |
//|                                                сmillion@narod.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Хлыстов Владимр"
#property link      "сmillion@narod.ru"
 
#property indicator_chart_window
//double Fr_Buffer[];
double Fr_UPPER,Fr_LOWER,High_Fr_LOWER,High_Fr_LOWER_2;
double High_Win,Low_Win,shift_X,shift_Y;
   int per,T_Fr_LOWER,T_Fr_UPPER,Low_Fr_UPPER,Low_Fr_UPPER_2,Level_new;
string текст,ПЕРИОД;
extern color ЦВЕТ_UP=Yellow;
extern color ЦВЕТ_DN=Magenta;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   del();
   Level_new=MarketInfo(Symbol(),MODE_STOPLEVEL);           //Находим минимально допустимый TakeProft и StopLoss
   per =Period();
   ПЕРИОД=string_пер(per);
   Comment("ФРАКТАЛЫ    "+ПЕРИОД+"    "+время(CurTime()));
   return(0);
  }
//+------------------------------------------------------------------+
 
//жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж
//////////////////////////////////////////////////////////////////////
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int start()
  {
   Fr_UPPER=0;
   Fr_LOWER=100000;
   High_Win = WindowPriceMax();
   Low_Win  = WindowPriceMin();
   shift_X = WindowBarsPerChart()/80*per;
   shift_Y = (High_Win-Low_Win) / 50;
   int s=0;
   for(int n=WindowBarsPerChart(); n>=0; n--)
      Fractal(n);
      
 
/*      if (Fractal(n)!=0)
      {
         s++;
         ObjectDelete ("Name1 "+s);
         ObjectCreate ("Name1 "+s, OBJ_LABEL, 0, 0, 0);// Создание объ.
         ObjectSetText("Name1 "+s, n+" "+DoubleToStr(Fr_UPPER,Digits)+" "+DoubleToStr(Fr_LOWER,Digits)     ,8,"Arial");
         ObjectSet    ("Name1 "+s, OBJPROP_CORNER, 3);
         ObjectSet    ("Name1 "+s, OBJPROP_XDISTANCE, 10);
         ObjectSet    ("Name1 "+s, OBJPROP_YDISTANCE, 10+10*s);
         ObjectSet    ("Name1 "+s, OBJPROP_COLOR, White);    // Цвет 
      }*/
 
   return;                                      // Выход из deinit()
}
//*////////////////////////////////////////////////////////////////*//
//жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж
 
//жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж
//////////////////////////////////////////////////////////////////////
int Fractal(int br)
{
   double Fr_Up = iFractals(NULL, 0, MODE_UPPER, br+3);
   double Fr_Dn = iFractals(NULL, 0, MODE_LOWER, br+3);
   if (Fr_Dn==0 && Fr_Up==0) return(0);
   string sTime = время(Time[br+3])+" "+ПЕРИОД;
   int сила=0,рычаг=0,i;
   //----------------------------------- нижний фрактал ---------------------------------------------------------------------------------------------------   
   if (Fr_Dn!=0 && Fr_LOWER > Fr_Dn)
   {
      Fr_LOWER = Fr_Dn;      High_Fr_LOWER=High[br+3];      High_Fr_LOWER_2=High[br+2];      T_Fr_LOWER=Time[br+3];
      if (Fr_UPPER>0 && (Fr_UPPER-Open[br])>(Open[br]-Fr_LOWER))//формирование перелома
      {
         ObjectCreate("Fr "+sTime+" LOWER ", OBJ_ARROW,0,Time[br+3],Fr_Dn-shift_Y*2,0,0,0,0);
         ObjectSet   ("Fr "+sTime+" LOWER ", OBJPROP_ARROWCODE,218);
         ObjectSet   ("Fr "+sTime+" LOWER ", OBJPROP_COLOR,ЦВЕТ_DN );
         ObjectCreate("Fr sl "+sTime+" start_LOWER", OBJ_TREND, 0 ,T_Fr_UPPER,Fr_UPPER, T_Fr_LOWER,Fr_LOWER);      
         ObjectSet   ("Fr sl "+sTime+" start_LOWER", OBJPROP_COLOR, ЦВЕТ_DN);    // Цвет   
         ObjectSet   ("Fr sl "+sTime+" start_LOWER", OBJPROP_STYLE, STYLE_DOT);// Стиль   
         ObjectSet   ("Fr sl "+sTime+" start_LOWER", OBJPROP_BACK, true);
         ObjectSet   ("Fr sl "+sTime+" start_LOWER", OBJPROP_RAY,   false);     // Луч   
         сила=0;
         for (i=1; i<=5; i++) {color_bar(per,br+i,Fr_Dn-shift_Y); if (Свечa_цвет(per,br+i)==1||Свечa_цвет(per,br+i)==4) сила++;}
         рычаг=(Fr_UPPER-Fr_LOWER)/Point/Level_new;
         текст =  "Fr "+sTime+" LOWERсила"+"  р "+DoubleToStr(рычаг,0)+"-"+DoubleToStr((Open[br]-Fr_LOWER)/Point/Level_new,0)+" бар "+DoubleToStr((T_Fr_LOWER-T_Fr_UPPER)/per/60,0)+" MACD "+DoubleToStr(iMACD(NULL,per,5,34,5,PRICE_CLOSE,MODE_MAIN  ,br+3),Digits)+ " с "+DoubleToStr(сила,0)+" "+string_пер(per);
         ObjectDelete (текст);
         ObjectCreate (текст, OBJ_TEXT,0,Time[br+3],Fr_Dn-shift_Y*3.2,0,0,0,0);
         ObjectSetText(текст,DoubleToStr(iMACD(NULL,per,5,34,5,PRICE_CLOSE,MODE_MAIN  ,br+3),Digits)+" "+DoubleToStr(iMFI(NULL,per,15,br+3),0),8,"Arial");
         ObjectSet    (текст, OBJPROP_COLOR, ЦВЕТ_DN);
         Fr_UPPER=0;T_Fr_UPPER=0;Low_Fr_UPPER=0;Low_Fr_UPPER_2=0;
         return(1);
      }
   }
   //----------------------------------- верхний фрактал ---------------------------------------------------------------------------------------------------   
   if (Fr_Up!=0 && Fr_UPPER < Fr_Up)
   {
      Fr_UPPER=Fr_Up;      Low_Fr_UPPER=Low[br+3];      Low_Fr_UPPER_2=Low[br+2];      T_Fr_UPPER=Time[br+3];
      if (Fr_LOWER<100000 && (Fr_UPPER-Open[br])<(Open[br]-Fr_LOWER))//формирование перелома
      {
         ObjectCreate("Fr "+sTime+" UPPER", OBJ_ARROW,0,Time[br+3],Fr_Up+shift_Y*2,0,0,0,0);
         ObjectSet   ("Fr "+sTime+" UPPER", OBJPROP_ARROWCODE,217);
         ObjectSet   ("Fr "+sTime+" UPPER", OBJPROP_COLOR,ЦВЕТ_UP );
         ObjectCreate("Fr su "+sTime+" start_UPPER", OBJ_TREND, 0, T_Fr_LOWER,Fr_LOWER ,T_Fr_UPPER,Fr_UPPER);      
         ObjectSet   ("Fr su "+sTime+" start_UPPER", OBJPROP_COLOR, ЦВЕТ_UP);    // Цвет   
         ObjectSet   ("Fr su "+sTime+" start_UPPER", OBJPROP_STYLE, STYLE_SOLID);// Стиль   
         ObjectSet   ("Fr su "+sTime+" start_UPPER", OBJPROP_BACK, true);
         ObjectSet   ("Fr su "+sTime+" start_UPPER", OBJPROP_RAY,   false);     // Луч   
         сила=0;
         for (i=1; i<=5; i++) {color_bar(per,br+i,Fr_Up+shift_Y);if (Свечa_цвет(per,br+i)==1||Свечa_цвет(per,br+i)==4) сила++;}
         рычаг=(Fr_UPPER-Fr_LOWER)/Point/Level_new;
         текст="Fr "+sTime+" UPPERсила"+"  р "+DoubleToStr(рычаг,0)+"-"+DoubleToStr((Fr_UPPER-Open[br])/Point/Level_new,0)+" бар "+DoubleToStr((T_Fr_UPPER-T_Fr_LOWER)/per/60,0)+" MACD "+" с "+DoubleToStr(сила,0)+" "+string_пер(per);
         ObjectDelete (текст);
         ObjectCreate (текст, OBJ_TEXT,0,Time[br+3],Fr_Up+shift_Y*3.0,0,0,0,0);
         ObjectSetText(текст, DoubleToStr(iMACD(NULL,per,5,34,5,PRICE_CLOSE,MODE_MAIN  ,br+3),Digits)+" "+DoubleToStr(iMFI(NULL,per,15,br+3),0)   ,8,"Arial");
         ObjectSet    (текст, OBJPROP_COLOR, ЦВЕТ_UP);
         Fr_LOWER=100000;T_Fr_LOWER=0;High_Fr_LOWER=0;High_Fr_LOWER_2=0;
         return(-1);
      }
   }
//----------------------------
return(0);
}
//////////////////////////////////////////////////////////////////////
// Fractal
//////////////////////////////////////////////////////////////////////
//жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж
 
//жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж
//*////////////////////////////////////////////////////////////////*//
 
int deinit()                                    // Спец. ф-ия deinit()
{
   del();
   return;                                      // Выход из deinit()
}
//*////////////////////////////////////////////////////////////////*//
//жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж
 
//жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж
//*////////////////////////////////////////////////////////////////*//
int del()                                    // Спец. ф-ия deinit()
{
   for(int n=ObjectsTotal()-1; n>=0; n--) 
     {
      string Obj_Name=ObjectName(n);
      if (StringFind(Obj_Name,"Fr",0) != -1)
      {
         ObjectDelete(Obj_Name);
      }
   }
   return;                                      // Выход из deinit()
}
//*////////////////////////////////////////////////////////////////*//
//жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж
 
//жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж
///////////////////////////////////////////////////////////////////
string время(int taim)
{
   string sTaim;
   //int YY=TimeYear(taim);   // Year         
   int MN=TimeMonth(taim);  // Month                  
   int DD=TimeDay(taim);    // Day         
   int HH=TimeHour(taim);   // Hour                  
   int MM=TimeMinute(taim); // Minute   
 
   if (DD<10) sTaim = "0"+DoubleToStr(DD,0);
   else sTaim = DoubleToStr(DD,0);
   sTaim = sTaim+"/";
   if (MN<10) sTaim = sTaim+"0"+DoubleToStr(MN,0);
   else sTaim = sTaim+DoubleToStr(MN,0);
   sTaim = sTaim+" ";
   if (HH<10) sTaim = sTaim+"0"+DoubleToStr(HH,0);
   else sTaim = sTaim+DoubleToStr(HH,0);
   if (MM<10) sTaim = sTaim+":0"+DoubleToStr(MM,0);
   else sTaim = sTaim+":"+DoubleToStr(MM,0);
   return(sTaim);
}
//*////////////////////////////////////////////////////////////////*//
//жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж
 
//жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж
//////////////////////////////////////////////////////////////////////
// раскраска бара
//-------------------------------------------------------------------
int color_bar(int per, int br, double Y)
{
   int X           = iTime ( NULL, per, br);
   string sTime = время(Time[br]);
   color ЦВЕТ;
   switch(Свечa_цвет(per,br))//цвет свечи MFI 
   {
      case 1 ://Зеленый
         ЦВЕТ=Lime;break;
      case 2 ://Увядающий
         ЦВЕТ=Sienna;break;
      case 3 ://Фальшивый
         ЦВЕТ=Blue;break;
      case 4 ://Приседающий}
         ЦВЕТ=DeepPink;break;
      default:
         ЦВЕТ=White;
   }
   ObjectDelete("Fr color_bar "+sTime);
   ObjectCreate("Fr color_bar "+sTime, OBJ_ARROW,0,X,Y,0,0,0,0);
   ObjectSet   ("Fr color_bar "+sTime, OBJPROP_ARROWCODE,117);
   ObjectSet   ("Fr color_bar "+sTime, OBJPROP_COLOR,ЦВЕТ );
   ObjectSet   ("Fr color_bar "+sTime, OBJPROP_WIDTH, 0);
   ObjectSet   ("Fr color_bar "+sTime, OBJPROP_BACK, true);
}
//////////////////////////////////////////////////////////////////////
//жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж
 
//жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж
//////////////////////////////////////////////////////////////////////
int Свечa_цвет(int per, int br)
{
   if ( iVolume(NULL, per, br) > iVolume(NULL, per, br+1) && iBWMFI(NULL, per, br) > iBWMFI(NULL, per, br+1) ) return(1); //Зеленый
   if ( iVolume(NULL, per, br) < iVolume(NULL, per, br+1) && iBWMFI(NULL, per, br) < iBWMFI(NULL, per, br+1) ) return(2); //Увядающий
   if ( iVolume(NULL, per, br) < iVolume(NULL, per, br+1) && iBWMFI(NULL, per, br) > iBWMFI(NULL, per, br+1) ) return(3); //Фальшивый
   if ( iVolume(NULL, per, br) > iVolume(NULL, per, br+1) && iBWMFI(NULL, per, br) < iBWMFI(NULL, per, br+1) ) return(4); //Приседающий
   return(0);//ошибка
}
//////////////////////////////////////////////////////////////////////
//жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж
 
//жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж
//*////////////////////////////////////////////////////////////////*//
string string_пер(int per)
{
   switch(per)
   {
      case 1    : return("M_1");   //1 минута
         break;
      case 5    : return("M_5");   //5 минут 
         break;
      case 15   : return("M15");  //15 минут
         break;
      case 30   : return("M30");  //30 минут
         break;
      case 60   : return("H 1");   //1 час
         break;
      case 240  : return("H_4");   //4 часа
         break;
      case 1440 : return("D_1");   //1 день
         break;
      case 10080: return("W_1");   //1 неделя
         break;
      case 43200: return("MN1");  //1 месяц
         break;
   }
return("ошибка периода");
}
//*////////////////////////////////////////////////////////////////*//
//жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж