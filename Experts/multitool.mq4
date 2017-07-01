//+------------------------------------------------------------------+
//|                                                     Channels.mq4 |
//|                        Twisted                                   |
//|This is a zigzag based multi-timeframe multi channel EA, default  |
//|times are 15,60,240 mins,setting in inputs t1,t2,t3 and are       |
//| consolidated and persistant                                      |
//| on the TF you are viewing. Redraw on new 5 min Bar               |
//|2 Fibs are drawn up and down.                                     |
//|from swing 2 & 3 of your selected TF e.g 1,2 or 3.                |
//|Daily Pivots are standard, Fibs &  Piovots may be turned off      |
//|by setting  DrawFib &/or DailyPivot to 0                           |
//+------------------------------------------------------------------+
#property copyright "You"
#import "scripts/GannFan.ex4"

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
#define MAGICMA  1111111111

extern int showProfit=1;
extern int DailyPivot=1;         //Draw Pivots 0 for False 1 for True
extern int PivotDays=1;          //Number of Pivot days to plot 
extern int WeeklyPivot=1;        // WeeklyPivots 
extern int MonthlyPivot=1;        //Monthly Pivots
extern double WeeklyPivotLength=3;
extern double MonthlyPivotLength=3;
extern int WeeklyPivotStyle=2;   // Solid,Dash,Dash-Dot etc
extern int MonthlyPivotStyle=4;
extern int WeeklyPivotWidth=1;
extern int MonthlyPivotWidth=1;
extern int PivotWidth=2;         //Visual width of Pivot        
extern int drawChannels=0;       // Draw Channels 0 =off  1=on
extern int ChanAllTF=0;
extern int t1=15;               //Time Frame for 1st Channel in Minutes
extern int t2=60;               //Time Frame for 2nd Channel in Minutes
extern int t3=240;              //Time Frame for 3nd Channel in Minutes
extern int DrawFib=0;           // Draw Fibs 0 for false 1 for True
extern int FibTimeRef=3;        // Which Time frame to Bind Fibs to 1,2 or 3
extern int extendFib=0;
extern color Fib1Color=Sienna;
extern color Fib2Color=DarkSeaGreen;
extern int drawFib1=1;          // Drawn Fib1 0 for false 1 for True
extern int drawFib2=1;          //Darw Fib2  0 for false 1 for True
extern int drawGannFan=0;
extern int GannTimeRef=3;
extern color Fan1Color=White;
extern color Fan2Color=PowderBlue;
extern int ChannelThickness=2;  //visual Channel Thickness


extern color Tens=Yellow;
extern color Fifties=Lime;
extern color Hundreds=Lime;
extern color EightyTwenty=Teal;



double pivots[10][3][10];       // Multi Dim array for future implementation


string pivotNames[]={"Daily","WeekLy","Monthly"}; 
string pivotLines[]={"R4","R3","R2","R1","PP","S1","S2","S3","S4"};
color  pivotColors[]={Crimson,Red,FireBrick,FireBrick,PowderBlue,Lime,Green,DarkGreen,DarkGreen};
int    pivotTimes[]={1440,10080,43200};
int periods[]={1,5,15,30,60,240,1440,PERIOD_W1,PERIOD_MN1};
//int periods[]={60,240,1440,10080,43200};
double fibLevels[]={-4.236,-3.5,-3,-2.618,-2,-1.618,-1.382,-1.27,-1,-0.764,-0.618,-0.50,-0.382,-0.236,0,0.236,0.38,0.50,0.618,0.764,1,1.27,1.382,1.618,3,2.618,3,3.5,4.236};//29

double Lots= 0.1;                //For use with Trade orders
bool  breakEven=false;           //For use with Trade orders
int lastOrder,count;             //For use with Trade orders



void Brackets()
{
     double start=0.5;
     double end=2.5;
     double bidFac=0.0005;
     if(Bid > 50)
     {
         start=80;
         end=200;
         bidFac=0.1;
     }
      
      while(start <=end)
      {
      
            if(Period() <30)
            {
            if(StringSubstr(DoubleToStr(start,6),5,1)=="0")
            {
                  ObjectDelete("ARJ-"+"Brk"+"Level:"+DoubleToStr(start,5));
                   ObjectCreate("ARJ-"+"Brk"+"Level:"+DoubleToStr(start,5),OBJ_HLINE,0,0,start);
                  ObjectSet("ARJ-"+"Brk"+"Level:"+DoubleToStr(start,5),OBJPROP_STYLE,STYLE_DASHDOT);
                  ObjectSet("ARJ-"+"Brk"+"Level:"+DoubleToStr(start,5),OBJPROP_COLOR,Tens);
                   ObjectSet("ARJ-"+"Brk"+"Level:"+DoubleToStr(start,5),OBJPROP_BACK,true);
                   ObjectSet("ARJ-"+"Brk"+"Level:"+DoubleToStr(start,5),OBJPROP_ANCHOR,true);
            }
            }
            if(Period() <240)
            {
            if(StringSubstr(DoubleToStr(start,5),4,2)=="00" )
            {
                  ObjectDelete("ARJ-"+"Brk"+"Level:"+DoubleToStr(start,5));
                  ObjectCreate("ARJ-"+"Brk"+"Level:"+DoubleToStr(start,5),OBJ_HLINE,0,0,start);
                  ObjectSet("ARJ-"+"Brk"+"Level:"+DoubleToStr(start,5),OBJPROP_STYLE,STYLE_SOLID);
                  ObjectSet("ARJ-"+"Brk"+"Level:"+DoubleToStr(start,5),OBJPROP_COLOR,Hundreds);
                  ObjectSet("ARJ-"+"Brk"+"Level:"+DoubleToStr(start,5),OBJPROP_BACK,true);
                  ObjectSet("ARJ-"+"Brk"+"Level:"+DoubleToStr(start,5),OBJPROP_ANCHOR,true);
            }
            
            }
            
             if(StringSubstr(DoubleToStr(start,5),4,2)=="20"  ||StringSubstr(DoubleToStr(start,5),4,2)=="80" )
            {
                  ObjectDelete("ARJ-"+"Brk"+"Level:"+DoubleToStr(start,5));
                  ObjectCreate("ARJ-"+"Brk"+"Level:"+DoubleToStr(start,5),OBJ_HLINE,0,0,start);
                  ObjectSet("ARJ-"+"Brk"+"Level:"+DoubleToStr(start,5),OBJPROP_STYLE,STYLE_DASHDOT);
                  ObjectSet("ARJ-"+"Brk"+"Level:"+DoubleToStr(start,5),OBJPROP_COLOR,EightyTwenty);
                  ObjectSet("ARJ-"+"Brk"+"Level:"+DoubleToStr(start,5),OBJPROP_BACK,true);
                  ObjectSet("ARJ-"+"Brk"+"Level:"+DoubleToStr(start,5),OBJPROP_ANCHOR,true);
            }
            if(StringSubstr(DoubleToStr(start,5),4,2)=="50")
            {
                  ObjectDelete("ARJ-"+"Brk"+"Level:"+DoubleToStr(start,5));
                  ObjectCreate("ARJ-"+"Brk"+"Level:"+DoubleToStr(start,5),OBJ_HLINE,0,0,start);
                  ObjectSet("ARJ-"+"Brk"+"Level:"+DoubleToStr(start,5),OBJPROP_STYLE,STYLE_DASHDOT);
                  ObjectSet("ARJ-"+"Brk"+"Level:"+DoubleToStr(start,5),OBJPROP_COLOR,Fifties);
                  ObjectSet("ARJ-"+"Brk"+"Level:"+DoubleToStr(start,5),OBJPROP_BACK,true);
                  ObjectSet("ARJ-"+"Brk"+"Level:"+DoubleToStr(start,5),OBJPROP_ANCHOR,true);
            }
            
            start=start+bidFac;
      }
      
      return;


}



void drawLabels()
{
         int dy=15;
         int wy=175;
         int my=340;
         
        
        datetime weekStart=iTime(NULL,1,(WeeklyPivotLength)*1440);
        datetime monthStart=iTime(NULL,1,(MonthlyPivotLength)*1440);
      
        datetime end =iTime(NULL,1440,0)+1440*60;//iTime(NULL,1,0)+240;
        
        
        ObjectDelete("MT"+"DailyPivot");     
        
        
        ObjectDelete("MT"+"WeeklyPivot");     
        
        
         ObjectDelete("MT"+"MonthlyPivot");     
        
         
      
      
      
      for(int i=0;i<9;i++)
      {
         ObjectDelete("MT"+"D"+"PivotLable"+i);
         ObjectDelete("MT"+"W"+"PivotLable"+i);
         ObjectDelete("MT"+"M"+"PivotLable"+i);
         ObjectDelete("MT"+pivotNames[1]+pivotLines[i]);
      }
      if(DailyPivot==1)
      {
               ObjectCreate("MT"+"DailyPivot", OBJ_LABEL, 0, 0, 0);
               ObjectSet("MT"+"DailyPivot", OBJPROP_CORNER, 1);
               ObjectSet("MT"+"DailyPivot", OBJPROP_XDISTANCE, 40);
               ObjectSet("MT"+"DailyPivot", OBJPROP_YDISTANCE, dy);
        
               ObjectSetText("MT"+"DailyPivot", "DailyPivot -- ON", 10, "Impact", Lime);
               dy=20;
               for(i=0;i<9;i++)
               {
                     
                      ObjectCreate("MT"+"D"+"PivotLable"+i, OBJ_LABEL, 0, 0, 0);
                      ObjectSet("MT"+"D"+"PivotLable"+i, OBJPROP_CORNER, 1);
                      ObjectSet("MT"+"D"+"PivotLable"+i, OBJPROP_XDISTANCE, 30);
                      ObjectSet("MT"+"D"+"PivotLable"+i, OBJPROP_YDISTANCE, dy+15);
                       ObjectSetText("MT"+"D"+"PivotLable"+i,pivotLines[i]+" : "+ DoubleToStr(pivots[0][0][i],6), 10, "Courier", pivotColors[i]); 
                       dy=dy+15;
                     
               }
      }
      if(WeeklyPivot==1)
      {
               ObjectCreate("MT"+"WeeklyPivot", OBJ_LABEL, 0, 0, 0);
               ObjectSet("MT"+"WeeklyPivot", OBJPROP_CORNER, 1);
               ObjectSet("MT"+"WeeklyPivot", OBJPROP_XDISTANCE, 30);
               ObjectSet("MT"+"WeeklyPivot", OBJPROP_YDISTANCE, wy);
        
               ObjectSetText("MT"+"WeeklyPivot", "WeeklyPivot -- ON", 10, "Impact", Yellow);
               double WeekHigh=iHigh(NULL,PERIOD_W1,1);
               double WeekLow=iLow(NULL,PERIOD_W1,1);
               double WeekOpen=iOpen(NULL,PERIOD_W1,1);
               double WeekCLose=iClose(NULL,PERIOD_W1,1);
            
               double PP=(WeekHigh+WeekLow+WeekCLose)/3;
               double range=WeekHigh-WeekLow;
            
            pivots[0][1][4]=PP;              //Main Pivot
            pivots[0][1][5]=(2*PP)-WeekHigh;  //S1
            pivots[0][1][6]=PP-range ;       //S2
            pivots[0][1][7]=PP-(range*2);    //S3
            pivots[0][1][8]=PP-(range*3);    //S4
            
            pivots[0][1][3]=(2*PP)-WeekLow;   //R1
            pivots[0][1][2]=PP + range ;     //R2
            pivots[0][1][1]=PP+(range*2);    //R3
            pivots[0][1][0]=PP+(range*3);    //R4
            
            
               
            for(int j=0;j<=9;j++)
            {
                  ObjectDelete("MT"+pivotNames[1]+pivotLines[j]);
                  
                     ObjectCreate("MT"+pivotNames[1]+pivotLines[j],OBJ_TREND,0,weekStart,pivots[0][1][j],end,pivots[0][1][j]);
                     ObjectSet("MT"+pivotNames[1]+pivotLines[j],OBJPROP_RAY,0);
                     ObjectSet("MT"+pivotNames[1]+pivotLines[j],OBJPROP_COLOR,pivotColors[j]);
                     ObjectSet("MT"+pivotNames[1]+pivotLines[j],OBJPROP_WIDTH,WeeklyPivotWidth);
                     ObjectSet("MT"+pivotNames[1]+pivotLines[j],OBJPROP_STYLE,WeeklyPivotStyle);
                  
            }   
               
             wy=185;
               for(i=0;i<9;i++)
               {
                     
                      ObjectCreate("MT"+"W"+"PivotLable"+i, OBJ_LABEL, 0, 0, 0);
                      ObjectSet("MT"+"W"+"PivotLable"+i, OBJPROP_CORNER, 1);
                      ObjectSet("MT"+"w"+"PivotLable"+i, OBJPROP_XDISTANCE, 30);
                      ObjectSet("MT"+"W"+"PivotLable"+i, OBJPROP_YDISTANCE, wy+15);
                       ObjectSetText("MT"+"W"+"PivotLable"+i,pivotLines[i]+" : "+ DoubleToStr(pivots[0][1][i],6), 1, "Courier", pivotColors[i]); 
                       wy=wy+15;
                     
               }  
               
               
               
               
      }
      if(MonthlyPivot==1)
      {
               ObjectCreate("MT"+"MonthlyPivot", OBJ_LABEL, 0, 0, 0);
               ObjectSet("MT"+"MonthlyPivot", OBJPROP_CORNER, 1);
               ObjectSet("MT"+"MonthlyPivot", OBJPROP_XDISTANCE, 30);
               ObjectSet("MT"+"MonthlyPivot", OBJPROP_YDISTANCE, my);
               ObjectSetText("MT"+"MonthlyPivot", "MonthlyPivot -- ON", 10, "Impact", Red); 
               double MonthHigh=iHigh(NULL,PERIOD_MN1,1);
               double MonthLow=iLow(NULL,PERIOD_MN1,1);
               double MonthOpen=iOpen(NULL,PERIOD_MN1,1);
               double MonthCLose=iClose(NULL,PERIOD_MN1,1);
            
               double MPP=(MonthHigh+MonthLow+MonthCLose)/3;
               double Mrange=MonthHigh-MonthLow;
            
            pivots[0][2][4]=MPP;              //Main Pivot
            pivots[0][2][5]=(2*MPP)-MonthHigh;  //S1
            pivots[0][2][6]=MPP-Mrange ;       //S2
            pivots[0][2][7]=MPP-(Mrange*2);    //S3
            pivots[0][2][8]=MPP-(Mrange*3);    //S4
            
            pivots[0][2][3]=(2*MPP)-MonthLow;   //R1
            pivots[0][2][2]=MPP + Mrange ;     //R2
            pivots[0][2][1]=MPP+(Mrange*2);    //R3
            pivots[0][2][0]=MPP+(Mrange*3);    //R4
            
            
               
            for(j=0;j<=9;j++)
            {
                  ObjectDelete("MT"+pivotNames[2]+pivotLines[j]);
                  
                     ObjectCreate("MT"+pivotNames[2]+pivotLines[j],OBJ_TREND,0,monthStart,pivots[0][2][j],end,pivots[0][2][j]);
                     ObjectSet("MT"+pivotNames[2]+pivotLines[j],OBJPROP_RAY,0);
                     ObjectSet("MT"+pivotNames[2]+pivotLines[j],OBJPROP_COLOR,pivotColors[j]);
                     ObjectSet("MT"+pivotNames[2]+pivotLines[j],OBJPROP_WIDTH,MonthlyPivotWidth);
                     ObjectSet("MT"+pivotNames[2]+pivotLines[j],OBJPROP_STYLE,MonthlyPivotStyle);
                  
            }   
               
             my=355;
               for(i=0;i<9;i++)
               {
                     
                      ObjectCreate("MT"+"M"+"PivotLable"+i, OBJ_LABEL, 0, 0, 0);
                      ObjectSet("MT"+"M"+"PivotLable"+i, OBJPROP_CORNER, 1);
                      ObjectSet("MT"+"M"+"PivotLable"+i, OBJPROP_XDISTANCE, 30);
                      ObjectSet("MT"+"M"+"PivotLable"+i, OBJPROP_YDISTANCE, my+15);
                       ObjectSetText("MT"+"M"+"PivotLable"+i,pivotLines[i]+" : "+DoubleToStr( pivots[0][2][i],6), 1, "Courier", pivotColors[i]); 
                       my=my+15;
                     
               }  
               
               
               
               
      }


}

void calcPivots()  //Plot Standard Pivot Points for Last selected days
{
      
      double TH=iHigh(NULL,1440,0);
      double TL=iLow(NULL,1440,0);
      double TC=Bid;
      double TPivot =(TH+TL+TC)/3;
      
      double MH=iHigh(NULL,PERIOD_MN1,0);
      double ML=iLow(NULL,PERIOD_MN1,0);
      double MC=Bid;
      double MPivot =(MH+ML+MC)/3;
      
      double WH=iHigh(NULL,PERIOD_W1,0);
      double WL=iLow(NULL,PERIOD_W1,0);
      double WC=Bid;
      double WPivot =(WH+WL+WC)/3;
      
      
      // Projected Pivot for tommoro with todays high and low
      ObjectDelete("MT"+"TomPivot");
      ObjectCreate("MT"+"TomPivot",OBJ_TREND,0,iTime(NULL,1440,0)+1440*60,  TPivot,iTime(NULL,1440,0)+1800*60,TPivot);
      ObjectSet("MT"+"TomPivot",OBJPROP_RAY,0);
      ObjectSet("MT"+"TomPivot",OBJPROP_COLOR,Red);
      ObjectSet("MT"+"TomPivot",OBJPROP_WIDTH,2);
      
      ObjectDelete("MT"+"MonthPivot");
      ObjectCreate("MT"+"MonthPivot",OBJ_TREND,0,iTime(NULL,1440,0)+1440*60,  MPivot,iTime(NULL,1440,0)+1800*60,MPivot);
      ObjectSet("MT"+"MonthPivot",OBJPROP_RAY,0);
      ObjectSet("MT"+"MonthPivot",OBJPROP_COLOR,Yellow);
      ObjectSet("MT"+"MonthPivot",OBJPROP_WIDTH,2);
      
      ObjectDelete("MT"+"WeekPivot");
      ObjectCreate("MT"+"WeekPivot",OBJ_TREND,0,iTime(NULL,1440,0)+1440*60,  WPivot,iTime(NULL,1440,0)+1800*60,WPivot);
      ObjectSet("MT"+"WeekPivot",OBJPROP_RAY,0);
      ObjectSet("MT"+"WeekPivot",OBJPROP_COLOR,Green);
      ObjectSet("MT"+"WeekPivot",OBJPROP_WIDTH,2);
      
      
      for(int i=PivotDays-1;i>=0;i--)
      {
            int today=TimeDayOfWeek(iTime(NULL,PERIOD_D1,i));
            int yesterday=i+1;
            
            if(today==1) //calculation for Sunday and saturday
            {
               yesterday=i+1;
            }
            
            double dayHigh=iHigh(NULL,PERIOD_D1,yesterday);
            double dayLow=iLow(NULL,PERIOD_D1,yesterday);
            double dayOpen=iOpen(NULL,PERIOD_D1,yesterday);
            double dayCLose=iClose(NULL,PERIOD_D1,yesterday);
            
            double PP=(dayHigh+dayLow+dayCLose)/3;
            double range=dayHigh-dayLow;
            
            pivots[i][0][4]=PP;              //Main Pivot
            pivots[i][0][5]=(2*PP)-dayHigh;  //S1
            pivots[i][0][6]=PP-range ;       //S2
            pivots[i][0][7]=PP-(range*2);    //S3
            pivots[i][0][8]=PP-(range*3);    //S4
            
            pivots[i][0][3]=(2*PP)-dayLow;   //R1
            pivots[i][0][2]=PP + range ;     //R2
            pivots[i][0][1]=PP+(range*2);    //R3
            pivots[i][0][0]=PP+(range*3);    //R4
            
            datetime start=iTime(NULL,1440,i);
            datetime end =start+1430*60;
            
            
            for(int j=0;j<=9;j++)
            {
                  ObjectDelete("MT"+i+pivotNames[0]+pivotLines[j]);
                  if(DailyPivot==1)
                  {
                     ObjectCreate("MT"+i+pivotNames[0]+pivotLines[j],OBJ_TREND,0,start,pivots[i][0][j],end,pivots[i][0][j]);
                     ObjectSet("MT"+i+pivotNames[0]+pivotLines[j],OBJPROP_RAY,0);
                     ObjectSet("MT"+i+pivotNames[0]+pivotLines[j],OBJPROP_COLOR,pivotColors[j]);
                     ObjectSet("MT"+i+pivotNames[0]+pivotLines[j],OBJPROP_WIDTH,PivotWidth);
                  }
            }
            
         }
         
         
      drawLabels();
      
}

void drawFib(datetime pointA,double valA,datetime pointB,double valB,datetime pointC,double valC,datetime pointD,double valD)
{
      
      double diff=MathAbs(valA-valB);
      double diff1=MathAbs(valC-valD);
      
      
      ObjectCreate("MT"+"FibLabel", OBJ_LABEL, 0, 0, 0);
      ObjectSet("MT"+"FibLabel", OBJPROP_CORNER, 0);
      ObjectSet("MT"+"FibLabel", OBJPROP_XDISTANCE, 5);
      ObjectSet("MT"+"FibLabel", OBJPROP_YDISTANCE, 38);
      if(ChanAllTF==1)
      {
         ObjectSetText("MT"+"FibLabel","Fib is set to period:"+ periods[FibTimeRef-1], 1, "Courier", Yellow); 
      }
      else
      {
         int tf=t3;
         if(FibTimeRef==1)
         {
            tf=t1;
         }
         if(FibTimeRef==2)
         {
            tf=t2;
         }
         
         
         ObjectSetText("MT"+"FibLabel","Fib is set to period:"+tf, 1, "Courier", Yellow);
      }
      if(pointA < pointB && drawFib1==1)
      {
         ObjectCreate("MT"+"tradeFib1",OBJ_FIBO,0,pointA,valA,pointB,valB); 
         ObjectSet("MT"+"tradeFib1",OBJPROP_LEVELCOLOR,Fib1Color);
          
      }
      if(pointC < pointD && drawFib2==1)
      {
         ObjectCreate("MT"+"tradeFib2",OBJ_FIBO,0,pointC,valC,pointD,valD);
         ObjectSet("MT"+"tradeFib2",OBJPROP_LEVELCOLOR,Fib2Color);
      }
      int fibLevel=0;
      if(extendFib==0)
      {
               
               fibLevel=14;
      }
      
      ObjectSet("MT"+"tradeFib1",OBJPROP_FIBOLEVELS,29);
      ObjectSet("MT"+"tradeFib1",OBJPROP_RAY,false);
      ObjectSet("MT"+"tradeFib2",OBJPROP_FIBOLEVELS,29);
      ObjectSet("MT"+"tradeFib2",OBJPROP_RAY,false);
      for(int z=fibLevel;z<29;z++)
      {
            if(!ObjectSet("MT"+"tradeFib1",OBJPROP_FIRSTLEVEL+z,fibLevels[z])) Print(" Fibo1 ",GetLastError());
            ObjectSetFiboDescription( "MT"+"tradeFib1", z,DoubleToStr(fibLevels[z]*100,1)); 
            if(!ObjectSet("MT"+"tradeFib2",OBJPROP_FIRSTLEVEL+z,fibLevels[z])) Print(" Fibo2 ",GetLastError());
            ObjectSetFiboDescription( "MT"+"tradeFib2", z,DoubleToStr(fibLevels[z]*100,1)); 
            //fibLevel++;
      }
      
     
}

//===============================================
//===============================================
//ZIg Zag
//
//===============================================
double permSwing[9][6];
double permIndex[9][6];
double swing[]={0,0,0,0,0,0};
datetime swingTime[]={0,0,0,0,0,0};
int chanTimes[9]={0,0,0,0,0,0,0,0,0};
int chancount=3;
extern string zigzagsettings="12,5,3,0";
void zigZag()
{
      
      for(int j=0;j<chancount;j++)
      {  
                  int found=0;
                  int i=0;
                  while(found < 4)
                  {
                        if(iCustom(NULL,chanTimes[j],"ZigZag",9,5,3,0,i)!=0)
                        {
                              permSwing[j][found]=iCustom(NULL,chanTimes[j],"ZigZag",9,5,3,0,i);
                              permIndex[j][found]=iTime(NULL,chanTimes[j],i);
                              found++;
                        }
                        i++;
                  }
      
      }
}


void channels()  //Channels are based on the Last three swings
{
      int period=Period();
      
      
      chanTimes[0]=t1;
      chanTimes[1]=t2;
      chanTimes[2]=t3;
      chancount=3;
      ObjectDelete("MT"+"ChanLabel");
      for(int i=0;i<9;i++)  //Clean up previously drawn channels
      {
               ObjectDelete("MT"+"Chan-Period"+periods[i]);
       }
      for(int x=0;x<9;x++)
      {
            ObjectDelete("MT"+"Chan-Period"+chanTimes[x]);
      }
      if(drawChannels==1)
      {
            
            ObjectCreate("MT"+"ChanLabel", OBJ_LABEL, 0, 0, 0);
            ObjectSet("MT"+"ChanLabel", OBJPROP_CORNER, 0);
            ObjectSet("MT"+"ChanLabel", OBJPROP_XDISTANCE, 5);
            ObjectSet("MT"+"ChanLabel", OBJPROP_YDISTANCE, 25);
            ObjectSetText("MT"+"ChanLabel","Channel TFs are: "+t1+" : "+t2+ " : "+t3, 1, "Courier", Lime); 
            
            if(ChanAllTF==1)
            {
               for( x=0;x<9;x++)
               {
                  chanTimes[x]=periods[x];
               }
               chancount=9;
               ObjectSetText("MT"+"ChanLabel","Channel is for All TFs", 1, "Courier", Purple);
            }
      
            
            zigZag();
            int style[] = {STYLE_DOT,STYLE_DASH,STYLE_DASHDOTDOT};
            color colors[] = {Lime,DarkGoldenrod,Magenta,Yellow,DarkGreen,SteelBlue,DarkKhaki,Orange,SaddleBrown};
            
            for(int j=0;j<chancount;j++)
            {  
                  
                  ObjectDelete("MT"+"Chan-Period"+chanTimes[j]);
                  ObjectCreate("MT"+"Chan-Period"+chanTimes[j],OBJ_CHANNEL,0,permIndex[j][3],permSwing[j][3],permIndex[j][1],permSwing[j][1],permIndex[j][2],permSwing[j][2]);
                  ObjectSet("MT"+"Chan-Period"+chanTimes[j],OBJPROP_COLOR,colors[j]);
                  ObjectSet("MT"+"Chan-Period"+chanTimes[j],OBJPROP_WIDTH,ChannelThickness);  
                  ObjectSet("MT"+"Chan-Period"+chanTimes[j],OBJPROP_STYLE,STYLE_SOLID); 
      
             }
            
       }
       if(drawChannels==0)
       {
                  chancount=3;
                  zigZag();
        }
        ObjectDelete("MT"+"tradeFib1");
        ObjectDelete("MT"+"tradeFib2");
        ObjectDelete("MT"+"FibLabel");
        if(DrawFib==1)
        {
               int index=t3;
               int fib=0;
               
                  fib=FibTimeRef-1;
               
                  drawFib(permIndex[fib][3],permSwing[fib][3],permIndex[fib][2],permSwing[fib][2],permIndex[fib][2],permSwing[fib][2],permIndex[fib][1],permSwing[fib][1]);
        }  
        ObjectDelete("MT"+"Gann1");
        ObjectDelete("MT"+"Gann2");
       if(drawGannFan==1)
       {
          int gan1scale=45;
          int gan2scale=-45;
          if(permSwing[GannTimeRef-1][1] > permSwing[GannTimeRef-1][2])
          {
               gan1scale=-45;
               gan2scale=45;
          }
          
          ObjectCreate("MT"+"Gann1",OBJ_GANNFAN,0,permIndex[GannTimeRef-1][1],permSwing[GannTimeRef-1][1],permIndex[GannTimeRef-1][0],permSwing[GannTimeRef-1][0]);
          ObjectSet("MT"+"Gann1",OBJPROP_SCALE,gan1scale);
          ObjectSet("MT"+"Gann1",OBJPROP_COLOR,Fan1Color);
          
          ObjectCreate("MT"+"Gann2",OBJ_GANNFAN,0,permIndex[GannTimeRef-1][2],permSwing[GannTimeRef-1][2],permIndex[GannTimeRef-1][1],permSwing[GannTimeRef-1][1]);
          ObjectSet("MT"+"Gann2",OBJPROP_SCALE,gan2scale);
          ObjectSet("MT"+"Gann2",OBJPROP_COLOR,Fan2Color);
          string ganLevels[]={"1/8","1/4","1/3","1/2","1/1","2/1","3/1","4/1","8/1"};
          
       
       }   
}
int init()
  {
//----
         
         channels();
         calcPivots();
         Brackets();
         
        
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
      
         int i, ot=ObjectsTotal()-1;
         string id;

         for(i=ot;i>=0;i--)
         {    
             id=ObjectName(i);
             if(StringSubstr(id,0,2)=="MT")
             {
               ObjectDelete(id);
              }
         }
         
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+




int bar=0;
int start()
  {
//----
         if(bar!= iBars(NULL,5)) //will redraw after new 5 min bar
         {
              channels();
              calcPivots();
              bar=iBars(NULL,5);
              //Comment("Channel TFs are: ",t1," : ",t2, " : ",t3);
         }
         if(showProfit==1)
         {
            testProfit();
         }
            
            
//----
   return(0);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+-------buyOrder(),sellOrder(),trailStop()-------------------------+
//+-------For Future Implementation and added for reference----------+
//+-------Methods are however Functional but not called--------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+



void buyOrder()
{
      string message="Buy";
      double sl = Bid-250*Point;
      double tp = Ask+150*Point;
      double price = Ask;
      message=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,sl,tp,"",MAGICMA,0,Blue);
      
      lastOrder=Bars;
      return (message);
}

void sellOrder()
{
      string message="Sell";
      double sl = Ask+250*Point;
      double tp = Bid-150*Point;
      double price = Bid;
      
     
      message=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,sl,tp,"",MAGICMA,0,Red); 
      lastOrder=Bars;
     
   return (message);
}
string TrailStop()
{
   string message="Trailing Stop";
   
   for(int i=0;i<OrdersTotal();i++)
   {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)        break;
         if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
      
         if(OrderType()==OP_BUY)
         {   
            
            if(Ask-250*Point > OrderStopLoss())
            {
            
             OrderModify(OrderTicket(),Ask,Ask-250*Point,OrderTakeProfit(),0,Red);
            }
           
         }
         if(OrderType()==OP_SELL)
         {
            if(Bid+250*Point < OrderStopLoss())
            {
             
              OrderModify(OrderTicket(),Bid,Bid+250*Point,OrderTakeProfit(),0,Red);
            }
               
         }
      
   }
     return (message);
}


void testProfit()
{
      int _GetLastError ;
       
       double profit=0;
       double level=Bid;
       int dist=5000;
       
       if(Period() > 15)
       {
            dist=10000;
       }
       if(Period() >= 60)
       {
            dist=25000;
       }
       if(Period() >= 240)
       {
            dist=100000;
       }
      if(OrdersTotal()>0)
      {
            //Print("Orders=",OrdersTotal());
            for ( int i =OrdersTotal() - 1; i >= 0; i -- )
            {
                  ObjectDelete("Brk"+"Profit"+ Symbol()+i);
                  if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)        break;
                 if( OrderSymbol()!=Symbol()) continue;
                       
                       
                        profit=OrderProfit();
                        //Comment("Profit=",profit);
                        
                        ObjectCreate("Brk"+ "Profit"+ Symbol()+i,OBJ_TEXT,0,Time[0]+dist,level+i*0.0001);
                        if(profit>=0)
                        {
                           ObjectSetText("Brk"+"Profit"+ Symbol()+i, DoubleToStr(profit/(10*OrderLots()),2), 10, "Times New Roman", Lime);
                        }
                        if(profit<0)
                        {
                           ObjectSetText("Brk"+"Profit"+ Symbol()+i, DoubleToStr(profit/(10*OrderLots()),2), 10, "Times New Roman", Tomato);
                        }
                  
                 

            }
      }
}

