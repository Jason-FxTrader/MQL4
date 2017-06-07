//+------------------------------------------------------------------+
//|                                     CS method mod by KUSKUS v2.0 |
//|          (complete rewrite and name change of pattern alert)     |
//|                                                                  |
//|                 Copyright Š 2005, Jason Robinson mod by kuskus   |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright Š 2007, Jason Robinson mod by kuskus"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 LimeGreen

extern bool Show_Alert = true;
extern bool Display_Bearish_Engulfing = false;
extern bool Display_Hanging_Man_Hammer = true;
extern bool Display_Three_Outside_Down = false;
extern bool Display_Three_Inside_Down = false;
extern bool Display_Dark_Cloud_Cover = true;
extern bool Display_Evening_Doji_Star = true;
extern bool Display_Three_Black_Crows = true;
extern bool Display_Bullish_Engulfing = false;
extern bool Display_I_Hammer_S_Star = true;
extern bool Display_Three_Outside_Up = false;
extern bool Display_Three_Inside_Up = false;
extern bool Display_Piercing_Line = true;
extern bool Display_Three_White_Soldiers = true;
extern bool Display_Doji = true;
extern bool Display_Abandon_Baby = true;
extern bool Display_Stars = true;
extern bool Display_Harami = true;

//---- buffers
double upArrow[];
double downArrow[];
string PatternText[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() {

//---- indicators
   
   SetIndexStyle(0,DRAW_ARROW, EMPTY);
   SetIndexArrow(0,234);
   SetIndexBuffer(0, downArrow);
      
   SetIndexStyle(1,DRAW_ARROW, EMPTY);
   SetIndexArrow(1,233);
   SetIndexBuffer(1, upArrow);
      
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit() {
   ObjectsDeleteAll(0, OBJ_TEXT);
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start(){

   double Range, AvgRange;
   int counter, setalert;
   static datetime prevtime = 0;
   int shift;
   int shift1;
   int shift2;
   int shift3;
   string pattern, period;
   int setPattern = 0;
   int alert = 0;
   int arrowShift;
   int textShift;
   double O, O1, O2, C, C1, C2, L, L1, L2, H, H1, H2;
     
   if(prevtime == Time[0]) {
      return(0);
   }
   prevtime = Time[0];
   ArrayResize(PatternText,Bars);
   
   switch (Period()) {
      case 1:
         period = "M1";
         break;
      case 5:
         period = "M5";
         break;
      case 15:
         period = "M15";
         break;
      case 30:
         period = "M30";
         break;      
      case 60:
         period = "H1";
         break;
      case 240:
         period = "H4";
         break;
      case 1440:
         period = "D1";
         break;
      case 10080:
         period = "W1";
         break;
      case 43200:
         period = "MN";
         break;
   }
   
   for (int j = 0; j < Bars; j++) { 
         PatternText[j] = "pattern-" + j;
   }
   
   for (shift = 0; shift < Bars; shift++) {
      ObjectDelete(PatternText[shift]);
      
      setalert = 0;
      counter=shift;
      Range=0;
      AvgRange=0;
      for (counter=shift ;counter<=shift+9;counter++) {
         AvgRange=AvgRange+MathAbs(High[counter]-Low[counter]);
      }
      Range=AvgRange/10;
      shift1 = shift + 1;
      shift2 = shift + 2;
      shift3 = shift + 3;
         downArrow[shift1] = EMPTY_VALUE;
         upArrow[shift1] = EMPTY_VALUE;
      
      O = Open[shift1];
      O1 = Open[shift2];
      O2 = Open[shift3];
      H = High[shift1];
      H1 = High[shift2];
      H2 = High[shift3];
      L = Low[shift1];
      L1 = Low[shift2];
      L2 = Low[shift3];
      C = Close[shift1];
      C1 = Close[shift2];
      C2 = Close[shift3];
         
   // Bearish Patterns
   
      // Check for Bearish Engulfing pattern
      if ((C1>O1)&&(O>C)&&(O>=C1)&&(O1>=C)&&((O-C)>(C1-O1))) {
         if (Display_Bearish_Engulfing == true) {
            ObjectCreate(PatternText[shift], OBJ_TEXT, 0, Time[shift1], High[shift1] + Range*1.5);
            ObjectSetText(PatternText[shift], "EG", 8, "Times New Roman", RoyalBlue);
            downArrow[shift1] = High[shift1] + Range*0.5;
         }
         if (setalert == 0 && Show_Alert == true) {
            pattern = "Bearish Engulfing Pattern";
            setalert = 1;
         }
      }         
      
      // Check for Hanging Man
      if (((H-L)>4*(O-C))&&((C-L)/(0.001+H-L)>=0.75)&&((O-L)/(0.001+H-L)>=0.75))
         if (Display_Hanging_Man_Hammer == true) {   
            ObjectCreate(PatternText[shift], OBJ_TEXT, 0, Time[shift1], High[shift1] + Range*1.5);
            ObjectSetText(PatternText[shift], "HM & HR", 8, "Times New Roman", Gold);
            downArrow[shift1] = High[shift1] + Range*0.5;
            upArrow[shift1] = Low[shift1] - Range*0.5;
         }
         if (shift == 0 && Show_Alert == true) {
            pattern="H Man @ Hammer";
            setalert = 1;
         }
            
      // Check for a Three Outside Down pattern
      if ((C2>O2)&&(O1>C1)&&(O1>=C2)&&(O2>=C1)&&((O1-C1)>(C2-O2))&&(O>C)&&(C<C1)) {
         if (Display_Three_Outside_Down == true) {   
            ObjectCreate(PatternText[shift], OBJ_TEXT, 0, Time[shift1], High[shift1] + Range*1.5);
            ObjectSetText(PatternText[shift], "TO", 8, "Times New Roman", White);
            downArrow[shift1] = High[shift1] + Range*0.5;
         }
         if (setalert == 0 && Show_Alert == true) {
            pattern="Three Oustide Down Pattern";
            setalert = 1;
         }
      }
      
      // Check for a Dark Cloud Cover pattern
      if ((C1>O1)&&(((C1+O1)/2)>C)&&(O>C)&&(O>C1)&&(C>O1)&&((O-C)/(0.001+(H-L))>0.6)) {
         if (Display_Dark_Cloud_Cover == true) {   
            ObjectCreate(PatternText[shift], OBJ_TEXT, 0, Time[shift1], High[shift1] + Range*1.5);
            ObjectSetText(PatternText[shift], "DC", 8, "Times New Roman", White);
            downArrow[shift1] = High[shift1] + Range*0.5;
         }
         if (setalert == 0 && Show_Alert == true) {
            pattern="Dark Cloud Cover Pattern";
            setalert = 1;
         }
      }
      
      // Check for Evening Doji Star pattern
      if ((C2>O2)&&((C2-O2)/(0.001+H2-L2)>0.6)&&(C2<O1)&&(C1>O1)&&((H1-L1)>(3*(C1-O1)))&&(O>C)&&(O<O1)) {
         if (Display_Stars == true) {
            ObjectCreate(PatternText[shift], OBJ_TEXT, 0, Time[shift1], High[shift1] + Range*1.5);
            ObjectSetText(PatternText[shift], "EDS", 8, "Times New Roman", White);
            downArrow[shift1] = High[shift1] + Range*0.5;
         }
         if (setalert == 0 && Show_Alert == true) {
            pattern="Evening Doji Star Pattern";
            setalert = 1;
         }
      }
      
      // Check for Bearish Harami pattern
      
      if ((C1>O1)&&(O>C)&&(O<=C1)&&(O1<=C)&&((O-C)<(C1-O1))) {
         if (Display_Harami == true) {   
            ObjectCreate(PatternText[shift], OBJ_TEXT, 0, Time[shift1], High[shift1] + Range*1.2);
            ObjectSetText(PatternText[shift], "Sell", 8, "Calibri", Gold);
            ObjectSetDouble(ChartID(), PatternText[shift], OBJPROP_ANGLE, 90);
            ObjectSetInteger(ChartID(), PatternText[shift], OBJPROP_ANCHOR, ANCHOR_BOTTOM);
            downArrow[shift1] = High[shift1] + Range*0.5;
         }
         if (shift == 0 && Show_Alert == true) {
            pattern="Sell Signal";
            setalert = 1;
         }
      }
      
      // Check for Three Inside Down pattern
      
      if ((C2>O2)&&(O1>C1)&&(O1<=C2)&&(O2<=C1)&&((O1-C1)<(C2-O2))&&(O>C)&&(C<C1)&&(O<O1)) {
         if (Display_Three_Inside_Down == true) {   
            ObjectCreate(PatternText[shift], OBJ_TEXT, 0, Time[shift1], High[shift1] + Range*1.5);
            ObjectSetText(PatternText[shift], "TI", 8, "Times New Roman", White);
            downArrow[shift1] = High[shift1] + Range*0.5;
         }
         if (shift == 0 && Show_Alert == true) {
            pattern="Three Inside Down Pattern";
            setalert = 1;
         }
      }
      
      // Check for Three Black Crows pattern
      
      if ((O > C * 0.001)&&(O1 > C1 * 0.01)&&(O2 > C2*0.001)&&(C < C1)&&(C1 < C2)&&(O > C1)&&(O < O1)&&(O1 > C2)&&(O1 < O2)&&(((C - L)/(H - L))<0.6)&&(((C1 - L1)/(H1 - L1))<0.6)&&(((C2 - L2)/(H2 - L2))<0.6)){
         if (Display_Three_Black_Crows == true){   
            ObjectCreate(PatternText[shift], OBJ_TEXT, 0, Time[shift1], High[shift1] + Range*1.5);
            ObjectSetText(PatternText[shift], "TBC", 8, "Times New Roman", White);
            downArrow[shift1] = High[shift1] + Range*0.5;
         }
         if (shift == 0 && Show_Alert == true) {
            pattern="Three Black Crows Pattern";
            setalert = 1;
         }
      }
      // Check for Evening Star Pattern
      
      if ((C2>O2)&&((C2-O2)/(0.001+H2-L2)>0.2)&&(C2<O1)&&(C1>O1)&&((H1-L1)>(3*(C1-O1)))&&(O>C)&&(O<O1)) {
         if (Display_Stars == true) {   
            ObjectCreate(PatternText[shift], OBJ_TEXT, 0, Time[shift1], High[shift1] + Range*1.5);
            ObjectSetText(PatternText[shift], "ES", 8, "Times New Roman", White);
            downArrow[shift1] = High[shift1] + Range*0.5;
         }
         if (shift == 0 && Show_Alert == true) {
            pattern = "Evening Star Pattern";
            setalert = 1;
         }
      }
   // End of Bearish Patterns
   
   // Bullish Patterns
   
      // Check for Bullish Engulfing pattern
      
      if ((O1>C1)&&(C>O)&&(C>=O1)&&(C1>=O)&&((C-O)>(O1-C1))) {
         if (Display_Bullish_Engulfing) {   
            ObjectCreate(PatternText[shift], OBJ_TEXT, 0, Time[shift1], Low[shift1] - Range*1.5);
            ObjectSetText(PatternText[shift], "EG", 8, "Times New Roman", RoyalBlue);
            upArrow[shift1] = Low[shift1] - Range*0.5;
         }
         if (shift == 0 && Show_Alert == true) {
            pattern="Bullish Engulfing Pattern";
            setalert = 1;
         }
      }
      
       
      // Check for Inverted Hammer and Shooting Star
      
      if (((H-L)>3*(O-C))&&((H-C)/(0.001+H-L)>0.6)&&((H-O)/(0.001+H-L)>0.6))
         if (Display_I_Hammer_S_Star) {   
            ObjectCreate(PatternText[shift], OBJ_TEXT, 0, Time[shift1], Low[shift1] - Range*1.5);
            ObjectSetText(PatternText[shift], "IH & SS", 8, "Times New Roman", Gold);
            upArrow[shift1] = Low[shift1] - Range*0.5;
            downArrow[shift1] = High[shift1] + Range*0.5;
         }
         if (shift == 0 && Show_Alert == true) {
            pattern="I Hammer @ S Star";
            setalert = 1;
         }
      
      // Check for Three Outside Up pattern
      
      if ((O2>C2)&&(C1>O1)&&(C1>=O2)&&(C2>=O1)&&((C1-O1)>(O2-C2))&&(C>O)&&(C>C1)) {
         if (Display_Three_Outside_Up == true) {   
            ObjectCreate(PatternText[shift], OBJ_TEXT, 0, Time[shift1], Low[shift1] - Range*1.5);
            ObjectSetText(PatternText[shift], "TO", 8, "Times New Roman", White);
            upArrow[shift1] = Low[shift1] - Range*0.5;
         }
         if (shift == 0 && Show_Alert == true) {
            pattern="Three Outside Up Pattern";
            setalert = 1;
         }
      }
      
      // Check for Bullish Harami pattern
      
      if ((O1>C1)&&(C>O)&&(C<=O1)&&(C1<=O)&&((C-O)<(O1-C1))) {
         if (Display_Harami == true) {   
            ObjectCreate(PatternText[shift], OBJ_TEXT, 0, Time[shift1], Low[shift1] - Range*1.9);
            ObjectSetText(PatternText[shift], "Buy", 8, "Calibri", DeepSkyBlue);
            ObjectSetDouble(ChartID(), PatternText[shift], OBJPROP_ANGLE, 90);
            ObjectSetInteger(ChartID(), PatternText[shift], OBJPROP_ANCHOR, ANCHOR_BOTTOM);
            
            
            ObjectCreate(PatternText[shift]+"_upper", OBJ_TEXT, 0, Time[shift1], High[shift1] + Range*1.9);
            ObjectSetText(PatternText[shift]+"_upper", "Buy upper", 8, "Calibri", DeepSkyBlue);
            ObjectSetDouble(ChartID(), PatternText[shift]+"_upper", OBJPROP_ANGLE, 270);
            ObjectSetInteger(ChartID(), PatternText[shift]+"_upper", OBJPROP_ANCHOR, ANCHOR_LEFT);
            
            
            upArrow[shift1] = Low[shift1] - Range*0.5;
         }
         if (shift == 0 && Show_Alert == true) {
            pattern="Buy Signal";
            setalert = 1;
         }
      }
      
      // Check for Three Inside Up pattern
      
      if ((O2>C2)&&(C1>O1)&&(C1<=O2)&&(C2<=O1)&&((C1-O1)<(O2-C2))&&(C>O)&&(C>C1)&&(O>O1)) {
         if (Display_Three_Inside_Up == true) {   
            ObjectCreate(PatternText[shift], OBJ_TEXT, 0, Time[shift1], Low[shift1] - Range*1.5);
            ObjectSetText(PatternText[shift], "TI", 8, "Times New Roman", White);
            upArrow[shift1] = Low[shift1] - Range*0.5;
         }
         if (shift == 0 && Show_Alert == true) {
            pattern="Three Inside Up Pattern";
            setalert = 1;
         }
      }
      
      // Check for Piercing Line pattern
      
      if ((C1<O1)&&(((O1+C1)/2)<C)&&(O<C)&&(O<C1)&&(C<O1)&&((C-O)/(0.001+(H-L))>0.6)) {
         if (Display_Piercing_Line == true) {   
            ObjectCreate(PatternText[shift], OBJ_TEXT, 0, Time[shift1], Low[shift1] - Range*1.5);
            ObjectSetText(PatternText[shift], "PL", 8, "Times New Roman", White);
            upArrow[shift1] = Low[shift1] - Range*0.5;
         }
         if (shift == 0 && Show_Alert == true) {
            pattern="Piercing Line Pattern";
            setalert = 1;
         }
      }
      
      // Check for Three White Soldiers pattern
      
      if ((C>O*0.001)&&(C1>O1*0.001) &&(C2>O2*0.001) &&(C>C1) &&(C1>C2) &&(O<C1&&O>O1) &&(O1<C2&&O1>O2) &&(((H-C)/(H-L))<0.2) &&(((H1-C1)/(H1-L1))<0.2)&&(((H2-C2)/(H2-L2))<0.2)) {
         if (Display_Three_White_Soldiers == true) {   
            ObjectCreate(PatternText[shift], OBJ_TEXT, 0, Time[shift1], Low[shift1] - Range*1.5);
            ObjectSetText(PatternText[shift], "TWS", 8, "Times New Roman", White);
            upArrow[shift1] = Low[shift1] - Range*0.5;
         }
         if (shift == 0 && Show_Alert == true) {
            pattern="Three White Soldiers Pattern";
            setalert = 1;
         }
      }
      // Check for Doji
      if (C==O)
         if (Display_Doji== true) {  
            ObjectCreate(PatternText[shift], OBJ_TEXT, 0, Time[shift1], Low[shift1] - Range*2.5);
            ObjectSetText(PatternText[shift], "Neutral", 8, "Calibri", Orchid);
            ObjectSetDouble(ChartID(), PatternText[shift], OBJPROP_ANGLE, 90);
            ObjectSetInteger(ChartID(), PatternText[shift], OBJPROP_ANCHOR, ANCHOR_BOTTOM);
            upArrow[shift1] = Low[shift1] - Range*0.5;
            downArrow[shift1] = High[shift1] + Range*0.5;
         }
         if (shift == 0 && Show_Alert == true) {
            pattern="Neutral Signal";
            setalert = 1;
         }
      }  
      
      // Check for Abandon Baby
      if ((C1==O1)&&(C2>O2)&&(O>C)&&(L1>H2)&&(L1>H))
      if ((C1==O1)&&(O2>C2)&&(C>O)&&(L2>H1)&&(L>H1))
         if (Display_Abandon_Baby== true) {   
            ObjectCreate(PatternText[shift], OBJ_TEXT, 0, Time[shift1], Low[shift1] - Range*1.5);
            ObjectSetText(PatternText[shift], "AB", 8, "Times New Roman", White);
            upArrow[shift1] = Low[shift1] - Range*0.5;
         }
         if (shift == 0 && Show_Alert == true) {
            pattern="Abandon Baby";
            setalert = 1;
         }
            
                
      // Check for Morning Doji Star
      
      if ((O2>C2)&&((O2-C2)/(0.001+H2-L2)>0.6)&&(C2>O1)&&(O1>C1)&&((H1-L1)>(3*(C1-O1)))&&(C>O)&&(O>O1)) {
         if (Display_Stars == true) {   
            ObjectCreate(PatternText[shift], OBJ_TEXT, 0, Time[shift1], Low[shift1] - Range*1.5);
            ObjectSetText(PatternText[shift], "MDS", 8, "Times New Roman", White);
            upArrow[shift1] = Low[shift1] - Range*0.5;
         }
         if (shift == 0 && Show_Alert == true) {
            pattern="Morning Doji Star Pattern";
            setalert = 1;
         }
      }
           
      
      if (setalert == 1 && shift == 0) {
         Alert(Symbol(), " ", period, " ", pattern);
         setalert = 0;
      }
   } // End of for loop
     
   
    

//+------------------------------------------------------------------+
