//-----------------------------------------------------------------------------------------------------------------------------------------
// MH PLOT FUNCTIONS
//-----------------------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------------------
// PLOT MH VERSION OF MTF STOCHASTIC INDICATOR IN SUBWINDOW (to be called only at start of bar)
//-----------------------------------------------------------------------------------------------------------------------------------------
void MHStoch_PlotAll()
{
   static string LastKName;
   LastKName = Line_Plot(SubWin, iTime(NULL,period1,1), K1_1, iTime(NULL,period1,0), K1, clrBlue, false);
   LastKName = Line_Plot(SubWin, iTime(NULL,period1,1), K2_1, iTime(NULL,period1,0), K2, clrRed, false);
   LastKName = Line_Plot(SubWin, iTime(NULL,period1,1), K3_1, iTime(NULL,period1,0), K3, clrGreen, false);
   LastKName = Line_Plot(SubWin, iTime(NULL,period1,1), K4_1, iTime(NULL,period1,0), K4, clrBlack, false);
   LastKName = Line_Plot(SubWin, iTime(NULL,period1,1), K5_1, iTime(NULL,period1,0), K5, clrBlack, false);
   LastKName = Line_Plot(SubWin, iTime(NULL,period1,1), K6_1, iTime(NULL,period1,0), K6, clrBlack, false);
   LastKName = Line_Plot(SubWin, iTime(NULL,period1,1), K7_1, iTime(NULL,period1,0), K7, clrRed, false);
   LastKName = Line_Plot(SubWin, iTime(NULL,period1,1), K8_1, iTime(NULL,period1,0), K8, clrBlue, false);
   LastKName = Line_Plot(SubWin, iTime(NULL,period1,1), K9_1, iTime(NULL,period1,0), K9, clrGreen, false);

   //LastKName = Line_Plot(iTime(NULL,period1,1), D1_1, iTime(NULL,period1,0), D1, clrBlue, true);
   //LastKName = Line_Plot(iTime(NULL,period1,1), D2_1, iTime(NULL,period1,0), D2, clrRed, true);
   //LastKName = Line_Plot(iTime(NULL,period1,1), D3_1, iTime(NULL,period1,0), D3, clrGreen, true);
   //LastKName = Line_Plot(iTime(NULL,period1,1), D4_1, iTime(NULL,period1,0), D4, clrBlack, true);
   //LastKName = Line_Plot(iTime(NULL,period1,1), D5_1, iTime(NULL,period1,0), D5, clrBlack, true);
   //LastKName = Line_Plot(iTime(NULL,period1,1), D6_1, iTime(NULL,period1,0), D6, clrBlack, true);
   //LastKName = Line_Plot(iTime(NULL,period1,1), D7_1, iTime(NULL,period1,0), D7, clrRed, true);
   //LastKName = Line_Plot(iTime(NULL,period1,1), D8_1, iTime(NULL,period1,0), D8, clrBlue, true);
   //LastKName = Line_Plot(iTime(NULL,period1,1), D9_1, iTime(NULL,period1,0), D9, clrBlack, true);
}
////-----------------------------------------------------------------------------------------------------------------------------------------
//// PLOT MH VERSION OF MTF STOCHASTIC INDICATOR IN SUBWINDOW
////-----------------------------------------------------------------------------------------------------------------------------------------
////Differs from Indicator_Plot, in that it plots the stoch from the current tick in the bar, not the last close.  So it is right up to date.
//void Stoch_PlotAll()
//{
//   static string LastK1Name = "";                           //remember Last KName so it can be deleted if necessary
//   static string LastD1Name = "";                           //remember Last DName so it can be deleted if necessary
//   static datetime LastP1OpenTime = iTime(NULL,period1,0);  //remember time of the open of the last bar - must be static so as to remember the last value between calls to start(). Initialise to current bar
//   Stoch_Plot(LastK1Name, LastD1Name, LastP1OpenTime, K1_1, D1_1, K1, D1, period1, clrBlue);
//
//   static string LastK2Name = "";                           //remember Last KName so it can be   deleted if necessary
//   static string LastD2Name = "";                           //remember Last DName so it can be deleted if necessary
//   static datetime LastP2OpenTime = iTime(NULL,period1,0);  //remember time of the open of the last bar - must be static so as to remember the last value between calls to start(). Initialise to current bar
//   Stoch_Plot(LastK2Name, LastD2Name, LastP2OpenTime, K2_1, D2_1, K2, D2, period1, clrRed);  //note period 1 to display higher period stoch value every bar
//
//   static string LastK3Name = "";                           //remember Last KName so it can be deleted if necessary
//   static string LastD3Name = "";                           //remember Last DName so it can be deleted if necessary
//   static datetime LastP3OpenTime = iTime(NULL,period1,0);  //remember time of the open of the last bar - must be static so as to remember the last value between calls to start(). Initialise to current bar
//   Stoch_Plot(LastK3Name, LastD3Name, LastP3OpenTime, K3_1, D3_1, K3, D3, period1, clrBlack);
//}
//
////-----------------------------------------------------------------------------------------------------------------------------------------
//// Plot the indicator
////-----------------------------------------------------------------------------------------------------------------------------------------
//void Indicator_Plot() //called every tick
//{
////Print("For Indicator: every tick iStochastic(period1(shift 0, 1)): DateTime=", TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS), ", K1_1=", K1_1, ", D1_1=", D1_1, ", K1=", K1, ", D1=", D1);
//
//   static string LastK1Name = "";                           //remember Last KName so it can be deleted if necessary
//   static string LastD1Name = "";                           //remember Last DName so it can be deleted if necessary
//   static datetime LastP1OpenTime = iTime(NULL,period1,0);  //remember time of the open of the last bar - must be static so as to remember the last value between calls to start(). Initialise to current bar
//   Stoch_Plot(LastK1Name, LastD1Name, LastP1OpenTime, K1_1, D1_1, K1, D1, period1, clrBlue);
///*
//   static string LastK2Name = "";                           //remember Last KName so it can be   deleted if necessary
//   static string LastD2Name = "";                           //remember Last DName so it can be deleted if necessary
//   static datetime LastP2OpenTime = iTime(NULL,period2,0);  //remember time of the open of the last bar - must be static so as to remember the last value between calls to start(). Initialise to current bar
//   Stoch_Plot(LastK2Name, LastD2Name, LastP2OpenTime, K2_1, D2_1, K2, D2, period2, clrRed);
//
//   static string LastK3Name = "";                           //remember Last KName so it can be deleted if necessary
//   static string LastD3Name = "";                           //remember Last DName so it can be deleted if necessary
//   static datetime LastP3OpenTime = iTime(NULL,period3,0);  //remember time of the open of the last bar - must be static so as to remember the last value between calls to start(). Initialise to current bar
//   Stoch_Plot(LastK3Name, LastD3Name, LastP3OpenTime, K3_1, D3_1, K3, D3, period3, clrBlack);
//
//   static string LastK4Name = "";                           //remember Last KName so it can be deleted if necessary
//   static string LastD4Name = "";                           //remember Last DName so it can be deleted if necessary
//   static datetime LastP4OpenTime = iTime(NULL,period4,0);  //remember time of the open of the last bar - must be static so as to remember the last value between calls to start(). Initialise to current bar
//   Stoch_Plot(LastK4Name, LastD4Name, LastP4OpenTime, K4_1, D4_1, K4, D4, period4, clrDarkGreen);
//*/
//}
//------------------------------------------------------------------------------
void Stoch_Plot(string &LastKName, string &LastDName, datetime &LastPOpenTime, double K_1, double D_1, double Ka, double Da, int p, color Clr)
{ //Print("Stoch_Plot(LastKName=", LastKName, ", LastDName=", LastDName, ", LastPOpenTime=", TimeToStr(LastPOpenTime,TIME_DATE|TIME_SECONDS), ", K_1=", K_1, ", D_1=", D_1, ", Ka=", Ka, ", Da=", Da, ", p=", p, ")");
   datetime POpenTime = iTime(NULL,p,0);
   if (POpenTime > LastPOpenTime)   //if new bar
      LastPOpenTime = POpenTime;          //new bar so save the time of the Open of the current bar
   else //not first tick within bar, delete the last tick temporary trend lines
   {
      if (!ObjectDelete(LastKName))   //delete it (the very first time through will fail as previous object won't exist)
         LOG(": "+StringFormat("ObjectDelete(%s): %s", LastKName, Error_Get()));
      if (!ObjectDelete(LastDName))   //delete it (the very first time through will fail as previous object won't exist)
         LOG(": "+StringFormat("ObjectDelete(%s): %s", LastDName, Error_Get()));
   }
   LastKName = Line_Plot(SubWin, iTime(NULL,p,1), K_1, iTime(NULL,p,0), Ka, Clr, false);
   LastDName = Line_Plot(SubWin, iTime(NULL,p,1), D_1, iTime(NULL,p,0), Da, Clr, true);   
}
//----------------------------------------------------------------------------------------------------------------------------------------------------
void FibRet_Plot()   // MH Plot Fib retracements
{
   int bar;
   if (IsTesting())
      bar = 200;  //arbitararily chosen 200 bars to scan for high and low
   else
      bar = WindowFirstVisibleBar();
      
   int shiftLowest = iLowest(NULL, 0, MODE_LOW, bar, 0);
   int shiftHighest = iHighest(NULL, 0, MODE_HIGH, bar, 0);
   double h = High[shiftHighest];
   double l = Low[shiftLowest];
   
   static double q[6], r[6];
   q[0] = r[0];   //save value from last time through 0.0
   q[1] = r[1];   //save value from last time through 0.382
   q[2] = r[2];   //save value from last time through 0.500
   q[3] = r[3];   //save value from last time through 0.618
   q[4] = r[4];   //save value from last time through 0.786
   q[5] = r[5];   //save value from last time through 1.0

   if (shiftHighest > shiftLowest)  //slope down from left to right
   {
    r[0] = l;
    r[1] = ((h - l)*0.382)+l;
    r[2] = ((h - l)*0.500)+l;
    r[3] = ((h - l)*0.618)+l;
    r[4] = ((h - l)*0.786)+l;
    r[5] = h;
    Line_Plot(0, Time[shiftHighest], h, Time[shiftLowest], l, clrDarkBlue, true);  //plot the high-low line
    }
   else                             //slope up from left to right
   {
    r[0] = h;
    r[1] = h - ((h - l)*0.382);
    r[2] = h - ((h - l)*0.500);
    r[3] = h - ((h - l)*0.618);
    r[4] = h - ((h - l)*0.786);
    r[5] = l;
    Line_Plot(0, Time[shiftLowest], l, Time[shiftHighest], h, clrDarkGreen, true); //plot the low-high line
   }
   
//Plot ID for top of retracement slope
//Plot Date
   string m = "FibTop1";
   ObjectDelete(m);  //delete any prev obj with this name
   ObjectCreate(m, OBJ_TEXT, 0, Time[shiftHighest], High[shiftHighest]+3);
   ObjectSetString(0, m, OBJPROP_TEXT, (string)(Time[shiftHighest]));
//   ObjectSetInteger(0, m, OBJPROP_ANCHOR, ANCHOR_BOTTOM);

//Plot no. trading bars (days)
   m = "FibTop2";
   ObjectDelete(m);  //delete any prev obj with this name
   ObjectCreate(m, OBJ_TEXT, 0, Time[shiftHighest], High[shiftHighest]+2);
   ObjectSetString(0, m, OBJPROP_TEXT, (string)MathAbs(shiftHighest - shiftLowest)+"TB");
//   ObjectSetInteger(0, m, OBJPROP_ANCHOR, ANCHOR_BOTTOM);

//Plot Arrow Down
   m = "FibArrowDn";
   ObjectDelete(m);  //delete any prev obj with this name
   ObjectCreate(0,m,OBJ_ARROW,0,0,0,0,0);          // Create an arrow 
   ObjectSetInteger(0,m,OBJPROP_ARROWCODE,226);    // Set the arrow code 
   ObjectSetInteger(0,m,OBJPROP_TIME,Time[shiftHighest]);        // Set time 
   ObjectSetDouble(0,m,OBJPROP_PRICE,High[shiftHighest]+1);// Set price
   ObjectSetInteger(0, m, OBJPROP_COLOR, clrGray);
//----------
//Plot ID for bottom of retracement slope
//Plot Date
   m = "FibTop3";
   ObjectDelete(m);  //delete any prev obj with this name
   ObjectCreate(m, OBJ_TEXT, 0, Time[shiftLowest], Low[shiftLowest]-3);
   ObjectSetString(0, m, OBJPROP_TEXT, (string)(Time[shiftLowest]));
//   ObjectSetInteger(0, m, OBJPROP_ANCHOR, ANCHOR_BOTTOM);

//Plot no. trading bars (days)
   m = "FibTop4";
   ObjectDelete(m);  //delete any prev obj with this name
   ObjectCreate(m, OBJ_TEXT, 0, Time[shiftLowest], Low[shiftLowest]-2);
   ObjectSetString(0, m, OBJPROP_TEXT, (string)MathAbs(shiftHighest - shiftLowest)+"TB");
//   ObjectSetInteger(0, m, OBJPROP_ANCHOR, ANCHOR_BOTTOM);

//Plot Arrow Up
   m = "FibArrowUp";
   ObjectDelete(m);  //delete any prev obj with this name
   ObjectCreate(0,m,OBJ_ARROW,0,0,0,0,0);          // Create an arrow 
   ObjectSetInteger(0,m,OBJPROP_ARROWCODE,225);    // Set the arrow code 
   ObjectSetInteger(0,m,OBJPROP_TIME,Time[shiftLowest]);        // Set time 
   ObjectSetDouble(0,m,OBJPROP_PRICE,Low[shiftLowest]-1);// Set price 
   ObjectSetInteger(0, m, OBJPROP_COLOR, clrGray);


   ChartSetInteger(0,CHART_SCALEFIX, 0, TRUE);//scales chart to create vertical space to enable object to be shown
   ChartSetDouble(0,CHART_FIXED_MAX,High[shiftHighest]+10);//scales chart to create vertical space to enable object to be shown
   ChartSetDouble(0,CHART_FIXED_MIN,Low[shiftLowest]-10); //scales chart to create vertical space to enable object to be shown
//----------
   
   LineLabel_Plot("Fib0", Time[1], q[0], Time[0], r[0], clrRed, true, "Ret 0.000");  //plot the 0% retracement
   LineLabel_Plot("Fib1", Time[1], q[1], Time[0], r[1], clrOrange, true, "Ret 0.382");  //plot the 38.2% retracement
   LineLabel_Plot("Fib2", Time[1], q[2], Time[0], r[2], clrGreen, true, "Ret 0.500");  //plot the 50% retracement
   LineLabel_Plot("Fib3", Time[1], q[3], Time[0], r[3], clrBlue, true, "Ret 0.618");  //plot the 61.8% retracement
   LineLabel_Plot("Fib4", Time[1], q[4], Time[0], r[4], clrIndigo, true, "Ret 0.786");  //plot the 78.6% retracement
   LineLabel_Plot("Fib5", Time[1], q[5], Time[0], r[5], clrViolet, true, "Ret 1.000");  //plot the 100% retracement
}   
////----------------------------------------------------------------------------------------------------------------------------------------------------
//void LineSlope_Plot(string n, datetime t1, double p1, datetime t2, double p2, color clr, bool dot, string lbl)
//{
//   Line_Plot(0, t1, p1, t2, p2, clr, dot);
//   // Draw Date and Trading Bars (trading days) since first date in Fib   
////---------
////For Top Price
////Plot Date
//   string m = name+"1";
//   ObjectDelete(m);  //delete any prev obj with this name
//   ObjectCreate(m, OBJ_TEXT, 0, Time[shiftHighest], High[shiftHighest]+2);
//   ObjectSetString(0, m, OBJPROP_TEXT, (string)(Time[shiftHighest]));
//   ObjectSetInteger(0, m, OBJPROP_FONTSIZE, 7);
//   ObjectSetInteger(0, m, OBJPROP_COLOR, clrBlack);
//   ObjectSetInteger(0, m, OBJPROP_ANCHOR, ANCHOR_BOTTOM);
//
////Plot no. trading bars (days)
//   string p = name+"2";
//   ObjectDelete(p);  //delete any prev obj with this name
//   ObjectCreate(p, OBJ_TEXT, 0, Time[shiftHighest], High[shiftHighest]+1);
//   ObjectSetString(0, p, OBJPROP_TEXT, (string)MathAbs(shiftHighest - shiftLowest)+"TB");
//   ObjectSetInteger(0, p, OBJPROP_FONTSIZE, 7);
//   ObjectSetInteger(0, p, OBJPROP_COLOR, clrBlack);
//   ObjectSetInteger(0, p, OBJPROP_ANCHOR, ANCHOR_BOTTOM);
//
////----------
////For Bottom Price
////Plot Date
//   string n = name+"3";
//   ObjectDelete(n);  //delete any prev obj with this name
//   ObjectCreate(n, OBJ_TEXT, 0, Time[shiftLowest], Low[shiftLowest]-2);
//   ObjectSetString(0, n, OBJPROP_TEXT, (string)(Time[shiftLowest]));
//   ObjectSetInteger(0, n, OBJPROP_FONTSIZE, 7);
//   ObjectSetInteger(0, n, OBJPROP_COLOR, clrBlack);
//   ObjectSetInteger(0, n, OBJPROP_ANCHOR, ANCHOR_BOTTOM);
//
////Plot no. trading bars (days)
//   string q = name+"4";
//   ObjectDelete(q);  //delete any prev obj with this name
//   ObjectCreate(q, OBJ_TEXT, 0, Time[shiftLowest], Low[shiftLowest]-1);
//   ObjectSetString(0, q, OBJPROP_TEXT, (string)MathAbs(shiftHighest - shiftLowest)+"TB");
//   ObjectSetInteger(0, q, OBJPROP_FONTSIZE, 7);
//   ObjectSetInteger(0, q, OBJPROP_COLOR, clrBlack);
//   ObjectSetInteger(0, q, OBJPROP_ANCHOR, ANCHOR_BOTTOM);
//
//   ChartSetDouble(0,CHART_FIXED_MAX,High[shiftHighest]+10);//scales chart to create vertical space to enable object to be shown
//   ChartSetDouble(0,CHART_FIXED_MIN,Low[shiftLowest]-10); //scales chart to create vertical space to enable object to be shown
//
//}
//----------------------------------------------------------------------------------------------------------------------------------------------------
void LineLabel_Plot(string n, datetime t1, double p1, datetime t2, double p2, color clr, bool dot, string lbl)
{
   Line_Plot(0, t1, p1, t2, p2, clr, dot);
   
   ObjectDelete(n);

   //ObjectCreate(n, OBJ_ARROW, 0, t2, p2);
   //ObjectSet(n, OBJPROP_ARROWCODE, SYMBOL_RIGHTPRICE);      
   //ObjectSet(n, OBJPROP_COLOR, clr);
   
   ObjectCreate(n, OBJ_TEXT, 0, t2, p2);
   ObjectSetString(0, n, OBJPROP_TEXT, StringFormat("%.1f %s", p2, lbl));
//   ObjectSetInteger(0, n, OBJPROP_FONTSIZE, 7);
   ObjectSetInteger(0, n, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, n, OBJPROP_ANCHOR, ANCHOR_LEFT);

}
//----------------------------------------------------------------------------------------------------------------------------------------------------
//|  Draw Fibonacci Time Zones
void FibTimeZone_Plot()
  {
   string name = "FibTzId";
   ObjectDelete(name);

   int bar;
   if (IsTesting())
      bar = 200;  //arbitararily chosen 200 bars to scan for high and low
   else
      bar = WindowFirstVisibleBar();
   
   // If price breaking out to new highs or lows, don't redraw the fib until the next bar
   // That's what the -1 and 1 are for.
   int shiftLowest = iLowest(NULL, 0, MODE_LOW, bar - 1, 1);
   int shiftHighest = iHighest(NULL, 0, MODE_HIGH, bar - 1, 1);       
    
   bool isSwingDown = shiftHighest > shiftLowest;
   
   if (isSwingDown == true)
      ObjectCreate(name, OBJ_FIBOTIMES, 0, Time[shiftHighest], High[shiftHighest], Time[shiftLowest], Low[shiftLowest]);
   else
      ObjectCreate(name, OBJ_FIBOTIMES, 0, Time[shiftLowest], Low[shiftLowest], Time[shiftHighest], High[shiftHighest]);
   
   
   ObjectSet(name,OBJPROP_FIBOLEVELS,3);
   //ObjectSet(name, OBJPROP_FIRSTLEVEL+0,   1.382);
   //ObjectSet(name, OBJPROP_FIRSTLEVEL+1,   1.618);
   //ObjectSet(name, OBJPROP_FIRSTLEVEL+2,   2.000);
   ObjectSet(name, OBJPROP_FIRSTLEVEL+0,   1.000);
   ObjectSet(name, OBJPROP_FIRSTLEVEL+1,   1.500);
   ObjectSet(name, OBJPROP_FIRSTLEVEL+2,   2.000);
//---
   ObjectSet(name,OBJPROP_LEVELCOLOR,clrRed);
   ObjectSet(name,OBJPROP_LEVELWIDTH,2);
   ObjectSet(name,OBJPROP_LEVELSTYLE,2);
   ObjectSet(name,OBJPROP_COLOR,clrRed);
//--- Note labels are as per Miner.  So Miner's 0.382 is equivalent to MT4 1.382
   //ObjectSetFiboDescription (name, 0, "0.382");
   //ObjectSetFiboDescription (name, 1, "0.618");
   //ObjectSetFiboDescription (name, 2, "1.000");
   ObjectSetFiboDescription (name, 0, "1.000");
   ObjectSetFiboDescription (name, 1, "1.500");
   ObjectSetFiboDescription (name, 2, "2.000");
}
//-----------------------------------------------------------------------------------------------------------------------------------------
string Line_Plot(int w, datetime t1, double val1, datetime t2, double val2, color clr, bool dot)
{ //Print("Line_Plot(t1=", TimeToStr(t1,TIME_DATE|TIME_SECONDS), ", val1=", val1, ", t2=", TimeToStr(t2,TIME_DATE|TIME_SECONDS), ", val2=", val2, ")");
   string Name = IntegerToString(ObjGUID++);
   
//MAKE SURE THE SAVED MT4 CHART TEMPLATES DO NOT HAVE OBJECTS EMBEDDED WITH THEM OR THEY WILL CLASH WITH THE NEWLY PLOTTED ONES
//   if (ObjectFind(Name) > 0)  //check whether object already exists with this name
//      Log(string(__LINE__)+": "+StringFormat("Object already exists in Window: %d, with Name: %s, Object Type: %d", ObjectFind(Name), Name, ObjectType(Name)));

   if(!ObjectCreate(Name,OBJ_TREND,w, t1, val1, t2, val2))
      LOG(": "+StringFormat("ObjectCreate(%s, OBJ_TREND): %s", Name, Error_Get()));

   if(!ObjectSet(Name,OBJPROP_RAY,false))
      LOG(": "+StringFormat("ObjectSet(%s, OBJPROP_RAY): %s", Name, Error_Get()));

   ObjectSet(Name,OBJPROP_COLOR,clr);
   if (dot)
      ObjectSet(Name,OBJPROP_STYLE, STYLE_DOT);

//    ChartRedraw();
   return(Name);
}
//-----------------------------------------------------------------------------------------------------------------------------------------
//Plot a vertical line at current time
void VLine_Plot(color clr)
{
   string Name = IntegerToString(ObjGUID++);

   if(!ObjectCreate(Name,OBJ_VLINE,MainWin, TimeCurrent(), 0))
      LOG(": "+StringFormat("ObjectCreate(%s, OBJ_VLINE): %s", Name, Error_Get()));

   ObjectSet(Name,OBJPROP_COLOR,clr);
}
//-----------------------------------------------------------------------------------------------------------------------------------------
// Plot text (s) below bottom of last completed bar, and vertical
//-----------------------------------------------------------------------------------------------------------------------------------------
void Text_Plot(string s, int w)
{
   string t="";
   string n = IntegerToString(ObjGUID++);
   string on;  //object name
   int ot=ObjectsTotal();  //objects total
   
   for(int i = 0; i < ot; i++) //concatenate with any previous string targetted for this location, to build a composite string
   { 
      on = ObjectName(i);
      if(ObjectGet(on, OBJPROP_TIME1) == Time[0] && ObjectType(on)== OBJ_TEXT)
      {
         ObjectGetString(w, on, OBJPROP_TEXT, 0, t);      //get text of existing object
//Log(__LINE__, __FUNCTION__, on);
//Log(__LINE__, __FUNCTION__, TimeToString(ObjectGet(on, OBJPROP_TIME1)));
//Log(__LINE__, __FUNCTION__, "t: " + t);
         t += "; " + s;  //add in the delimiter and the new text string
         ObjectSetString(w, on, OBJPROP_TEXT, t); 
         break;
      }
   }
   if (t == "")   //object not found, create one
   {
      ObjectCreate(n, OBJ_TEXT, w, Time[0], Low[0]-10);
      ObjectSetString(w, n, OBJPROP_TEXT, s); 
//Log(__LINE__, __FUNCTION__, "s: " + s);
      ObjectSetInteger(w, n, OBJPROP_FONTSIZE, 7);
      ObjectSetInteger(w, n, OBJPROP_COLOR, clrBlack);
      ObjectSetDouble(w, n, OBJPROP_ANGLE, -90);   //vertical text
      ObjectSetInteger(w, n, OBJPROP_ANCHOR, ANCHOR_BOTTOM);
   }
}
//------------------------------------------------------------------------------
void StoVal_Plot(double k, double d, double k_1, double d_1, int r)
{
   double v;   //value on Y axis (note: not pixels)
   string n = IntegerToString(ObjGUID++);

   switch(r)   //Row on chart
   {
      case 1:
         v = 6;
         break;
      case 2:
         v = 11;
         break;
      case 3:
         v = 16;
         break;
      case 4:
         v = 21;
         break;
      case 5:
         v = 26;
         break;
      case 6:
         v = 31;
         break;
      default:
         v = 6;
         break;
   }
   ObjectCreate(n, OBJ_TEXT, SubWin, Time[0], 50);
   ObjectSetString(MainWin, n, OBJPROP_TEXT, DoubleToString(k, 4)+"/"+DoubleToString(d, 4)+" ("+DoubleToString(k_1, 4)+"/"+DoubleToString(d_1, 4)+")"); 
   ObjectSetInteger(MainWin, n, OBJPROP_FONTSIZE, 7);
   ObjectSetInteger(MainWin, n, OBJPROP_COLOR, clrBlack);  
   ObjectSetDouble(MainWin,n,OBJPROP_ANGLE,90.0);
}
//------------------------------------------------------------------------------
void Arrow_Plot(int sig, int r)
{
   double v;   //value on Y axis (note: not pixels)
   string Name = IntegerToString(ObjGUID++);

   switch(r)   //Row on chart
   {
      case 1:
         v = 36;
         break;
      case 2:
         v = 41;
         break;
      case 3:
         v = 46;
         break;
      case 4:
         v = 51;
         break;
      case 5:
         v = 56;
         break;
      case 6:
         v = 61;
         break;
      case 7:
         v = 66;
         break;
      case 8:
         v = 71;
         break;
      default:
         v = 6;
         break;
   }

   if (sig == SIGNAL_LONG)
   {
      ObjectCreate(Name, OBJ_ARROW_UP, SubWin, Time[0], v);
      ObjectSet(Name, OBJPROP_COLOR, clrGreen);
    }
   else
   {
      ObjectCreate(Name,OBJ_ARROW_DOWN,SubWin,Time[0],v);
      ObjectSet(Name,OBJPROP_COLOR,clrRed);
   }
}
//-----------------------------------------------------------------------------------------------------------------------------------------
// Plot window label (s) to top left of indicator window
//-----------------------------------------------------------------------------------------------------------------------------------------
void Label_Plot(string s, int w, int r)
{
   string n = IntegerToString(ObjGUID++);
   double v;   //value on Y axis (pixels)

   switch(r)   //Row on chart
   {
      case 1:
         v = 0;
         break;
      case 2:
         v = 8;
         break;
      case 3:
         v = 16;
         break;
      case 4:
         v = 24;
         break;
      case 5:
         v = 32;
         break;
      case 6:
         v = 40;
         break;
      case 10:
         v = 100;
         break;
      default:
         v = 100;
         break;
   }

   ObjectCreate(n,OBJ_LABEL,w,0,v);
   ObjectSetText(n,s,7,NULL,clrBlack);
   ObjectSet(n,OBJPROP_CORNER,CORNER_LEFT_LOWER);
   ObjectSetInteger(w, n,OBJPROP_ANCHOR,ANCHOR_LEFT_LOWER);
   ObjectSet(n,OBJPROP_XDISTANCE,0);
   ObjectSet(n,OBJPROP_YDISTANCE,v);//pixels
}