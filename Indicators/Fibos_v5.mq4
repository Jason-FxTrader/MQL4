//+------------------------------------------------------------------+
//|                                                     Fibos_v5.mq4 |
//|                                        Developed by Coders' Guru |
//|                                            http://www.xpworx.com |
//+------------------------------------------------------------------+

#property copyright "Coders' Guru"
#property link      "http://www.xpworx.com"
string   ver  = "Last Modified: 2010.10.16 02:35";

#property indicator_chart_window
#property  indicator_buffers 8

extern bool  HighToLow  = true;
extern double Fibo_Level_1 = 0.236;
extern double Fibo_Level_2 = 0.382;
extern double Fibo_Level_3 = 0.500;
extern double Fibo_Level_4 = 0.618;
extern double Fibo_Level_5 = 0.764;
extern double Fibo_Level_6 = 0.886;
extern int    StartBar     = 0;
extern int    BarsBack     = 20;
extern bool   Pause        = false;

double Fibo_Level_0 = 0.000;
double Fibo_Level_7 = 1.000;
color VerticalLinesColor = Blue;
color FiboLinesColors = Yellow;

double f_1[];
double f_2[];
double f_3[];
double f_4[];
double f_5[];
double f_6[];
double f_7[];
double f_8[];

int init()
{
  DeleteAllObjects();
  
  SetIndexBuffer(0,f_1);
  SetIndexBuffer(1,f_2);
  SetIndexBuffer(2,f_3);
  SetIndexBuffer(3,f_4);
  SetIndexBuffer(4,f_5);
  SetIndexBuffer(5,f_6);
  SetIndexBuffer(6,f_7);
  SetIndexBuffer(7,f_8);
  SetIndexLabel(0,"Fibo_"+DoubleToStr(Fibo_Level_0,4));
  SetIndexLabel(1,"Fibo_"+DoubleToStr(Fibo_Level_1,4));
  SetIndexLabel(2,"Fibo_"+DoubleToStr(Fibo_Level_2,4));
  SetIndexLabel(3,"Fibo_"+DoubleToStr(Fibo_Level_3,4));
  SetIndexLabel(4,"Fibo_"+DoubleToStr(Fibo_Level_4,4));
  SetIndexLabel(5,"Fibo_"+DoubleToStr(Fibo_Level_5,4));
  SetIndexLabel(6,"Fibo_"+DoubleToStr(Fibo_Level_6,4));
  SetIndexLabel(7,"Fibo_"+DoubleToStr(Fibo_Level_7,4));
  return(0);
}

int deinit()
{
   DeleteAllObjects();
   return (0);
}

int start()
{
  if(Pause==false) CalcFibo();
  return(0);
}

void DeleteAllObjects()
{
   int objs = ObjectsTotal();
   string name;
   for(int cnt=ObjectsTotal()-1;cnt>=0;cnt--)
   {
      if(HighToLow)
      {
         name=ObjectName(cnt);
         if (StringFind(name,"v_u_hl",0)>-1) ObjectDelete(name);
         if (StringFind(name,"v_l_hl",0)>-1) ObjectDelete(name);
         if (StringFind(name,"Fibo_hl",0)>-1) ObjectDelete(name);
         if (StringFind(name,"trend_hl",0)>-1) ObjectDelete(name);
         WindowRedraw();
      }
      else
      {
         name=ObjectName(cnt);
         if (StringFind(name,"v_u_lh",0)>-1) ObjectDelete(name);
         if (StringFind(name,"v_l_lh",0)>-1) ObjectDelete(name);
         if (StringFind(name,"Fibo_lh",0)>-1) ObjectDelete(name);
         if (StringFind(name,"trend_lh",0)>-1) ObjectDelete(name);
         WindowRedraw();
      }
   }
}

void CalcFibo()
{
  
  //DeleteAllObjects();
  
  int LowBar = 0, HighBar= 0;
  double LowValue = 0 ,HighValue = 0;
  
  int lowest_bar = iLowest(NULL,0,MODE_LOW,BarsBack,StartBar);
  int highest_bar = iHighest(NULL,0,MODE_HIGH,BarsBack,StartBar);
  
  double higher_point = 0;
  double lower_point = 0;
  HighValue=High[highest_bar];
  LowValue=Low[lowest_bar];
  
  if(HighToLow)
  {
        DrawVerticalLine("v_u_hl",highest_bar,VerticalLinesColor);
        DrawVerticalLine("v_l_hl",lowest_bar,VerticalLinesColor);
        
        if(ObjectFind("trend_hl")==-1)
        ObjectCreate("trend_hl",OBJ_TREND,0,Time[highest_bar],HighValue,Time[lowest_bar],LowValue);
        ObjectSet("trend_hl",OBJPROP_TIME1,Time[highest_bar]);
        ObjectSet("trend_hl",OBJPROP_TIME2,Time[lowest_bar]);
        ObjectSet("trend_hl",OBJPROP_PRICE1,HighValue);
        ObjectSet("trend_hl",OBJPROP_PRICE2,LowValue);
        ObjectSet("trend_hl",OBJPROP_STYLE,STYLE_DOT);
        ObjectSet("trend_hl",OBJPROP_RAY,false);
        
        if(ObjectFind("Fibo_hl")==-1)
        ObjectCreate("Fibo_hl",OBJ_FIBO,0,0,HighValue,0,LowValue);  
        ObjectSet("Fibo_hl",OBJPROP_PRICE1,HighValue);
        ObjectSet("Fibo_hl",OBJPROP_PRICE2,LowValue);
        ObjectSet("Fibo_hl",OBJPROP_LEVELCOLOR,FiboLinesColors);
        ObjectSet("Fibo_hl",OBJPROP_FIBOLEVELS,8);
        ObjectSet("Fibo_hl",OBJPROP_FIRSTLEVEL+0,Fibo_Level_0);   ObjectSetFiboDescription("Fibo_hl",0,DoubleToStr(Fibo_Level_0,4));
        ObjectSet("Fibo_hl",OBJPROP_FIRSTLEVEL+1,Fibo_Level_1);   ObjectSetFiboDescription("Fibo_hl",1,DoubleToStr(Fibo_Level_1,4));
        ObjectSet("Fibo_hl",OBJPROP_FIRSTLEVEL+2,Fibo_Level_2);   ObjectSetFiboDescription("Fibo_hl",2,DoubleToStr(Fibo_Level_2,4));
        ObjectSet("Fibo_hl",OBJPROP_FIRSTLEVEL+3,Fibo_Level_3);   ObjectSetFiboDescription("Fibo_hl",3,DoubleToStr(Fibo_Level_3,4));
        ObjectSet("Fibo_hl",OBJPROP_FIRSTLEVEL+4,Fibo_Level_4);   ObjectSetFiboDescription("Fibo_hl",4,DoubleToStr(Fibo_Level_4,4));
        ObjectSet("Fibo_hl",OBJPROP_FIRSTLEVEL+5,Fibo_Level_5);   ObjectSetFiboDescription("Fibo_hl",5,DoubleToStr(Fibo_Level_5,4));
        ObjectSet("Fibo_hl",OBJPROP_FIRSTLEVEL+6,Fibo_Level_6);   ObjectSetFiboDescription("Fibo_hl",6,DoubleToStr(Fibo_Level_6,4));
        ObjectSet("Fibo_hl",OBJPROP_FIRSTLEVEL+7,Fibo_Level_7);   ObjectSetFiboDescription("Fibo_hl",7,DoubleToStr(Fibo_Level_7,4));
        ObjectSet("Fibo_hl",OBJPROP_RAY,true);
        WindowRedraw();
        
        
        for(int i=0; i<100; i++)
        {
           f_8[i] = NormalizeDouble(LowValue+(HighValue-LowValue)*Fibo_Level_7,Digits);
           f_7[i] = NormalizeDouble(LowValue+(HighValue-LowValue)*Fibo_Level_6,Digits);
           f_6[i] = NormalizeDouble(LowValue+(HighValue-LowValue)*Fibo_Level_5,Digits);
           f_5[i] = NormalizeDouble(LowValue+(HighValue-LowValue)*Fibo_Level_4,Digits);
           f_4[i] = NormalizeDouble(LowValue+(HighValue-LowValue)*Fibo_Level_3,Digits);
           f_3[i] = NormalizeDouble(LowValue+(HighValue-LowValue)*Fibo_Level_2,Digits);
           f_2[i] = NormalizeDouble(LowValue+(HighValue-LowValue)*Fibo_Level_1,Digits);
           f_1[i] = NormalizeDouble(LowValue+(HighValue-LowValue)*Fibo_Level_0,Digits);
        }
  }
  else
  {
        DrawVerticalLine("v_u_lh",highest_bar,VerticalLinesColor);
        DrawVerticalLine("v_l_lh",lowest_bar,VerticalLinesColor);
        
        if(ObjectFind("trend_hl")==-1)
        ObjectCreate("trend_lh",OBJ_TREND,0,Time[lowest_bar],LowValue,Time[highest_bar],HighValue);
        ObjectSet("trend_lh",OBJPROP_TIME1,Time[lowest_bar]);
        ObjectSet("trend_lh",OBJPROP_TIME2,Time[highest_bar]);
        ObjectSet("trend_lh",OBJPROP_PRICE1,LowValue);
        ObjectSet("trend_lh",OBJPROP_PRICE2,HighValue);
        ObjectSet("trend_lh",OBJPROP_STYLE,STYLE_DOT);
        ObjectSet("trend_lh",OBJPROP_RAY,false);


        if(ObjectFind("Fibo_lh")==-1)
        ObjectCreate("Fibo_lh",OBJ_FIBO,0,0,LowValue,0,HighValue);   
        ObjectSet("Fibo_lh",OBJPROP_PRICE1,LowValue);
        ObjectSet("Fibo_lh",OBJPROP_PRICE2,HighValue);
        ObjectSet("Fibo_lh",OBJPROP_LEVELCOLOR,FiboLinesColors);
        ObjectSet("Fibo_lh",OBJPROP_FIBOLEVELS,8);
        ObjectSet("Fibo_lh",OBJPROP_FIRSTLEVEL+0,Fibo_Level_0);   ObjectSetFiboDescription("Fibo_lh",0,DoubleToStr(Fibo_Level_0,4));
        ObjectSet("Fibo_lh",OBJPROP_FIRSTLEVEL+1,Fibo_Level_1);   ObjectSetFiboDescription("Fibo_lh",1,DoubleToStr(Fibo_Level_1,4));
        ObjectSet("Fibo_lh",OBJPROP_FIRSTLEVEL+2,Fibo_Level_2);   ObjectSetFiboDescription("Fibo_lh",2,DoubleToStr(Fibo_Level_2,4));
        ObjectSet("Fibo_lh",OBJPROP_FIRSTLEVEL+3,Fibo_Level_3);   ObjectSetFiboDescription("Fibo_lh",3,DoubleToStr(Fibo_Level_3,4));
        ObjectSet("Fibo_lh",OBJPROP_FIRSTLEVEL+4,Fibo_Level_4);   ObjectSetFiboDescription("Fibo_lh",4,DoubleToStr(Fibo_Level_4,4));
        ObjectSet("Fibo_lh",OBJPROP_FIRSTLEVEL+5,Fibo_Level_5);   ObjectSetFiboDescription("Fibo_lh",5,DoubleToStr(Fibo_Level_5,4));
        ObjectSet("Fibo_lh",OBJPROP_FIRSTLEVEL+6,Fibo_Level_6);   ObjectSetFiboDescription("Fibo_lh",6,DoubleToStr(Fibo_Level_6,4));
        ObjectSet("Fibo_lh",OBJPROP_FIRSTLEVEL+7,Fibo_Level_7);   ObjectSetFiboDescription("Fibo_lh",7,DoubleToStr(Fibo_Level_7,4));
        ObjectSet("Fibo_lh",OBJPROP_RAY,true);        
        WindowRedraw();
        
        for(i=0; i<100; i++)
        {
           f_1[i] = NormalizeDouble(HighValue,4);
           f_2[i] = NormalizeDouble(HighValue-((HighValue-LowValue)*Fibo_Level_1),Digits);
           f_3[i] = NormalizeDouble(HighValue-((HighValue-LowValue)*Fibo_Level_2),Digits);
           f_4[i] = NormalizeDouble(HighValue-((HighValue-LowValue)*Fibo_Level_3),Digits);
           f_5[i] = NormalizeDouble(HighValue-((HighValue-LowValue)*Fibo_Level_4),Digits);
           f_6[i] = NormalizeDouble(HighValue-((HighValue-LowValue)*Fibo_Level_5),Digits);
           f_7[i] = NormalizeDouble(HighValue-((HighValue-LowValue)*Fibo_Level_6),Digits);
           f_8[i] = NormalizeDouble(LowValue,4);
        }
         
  }
}

void DrawVerticalLine(string name , int bar , color clr)
{
   if(ObjectFind(name)==-1)
   {
      ObjectCreate(name,OBJ_VLINE,0,Time[bar],0);
      ObjectSet(name,OBJPROP_COLOR,clr);
      ObjectSet(name,OBJPROP_STYLE,STYLE_DASH);
      ObjectSet(name,OBJPROP_WIDTH,1);
      WindowRedraw();
   }
   else
   {
      ObjectDelete(name);
      ObjectCreate(name,OBJ_VLINE,0,Time[bar],0);
      ObjectSet(name,OBJPROP_COLOR,clr);
      ObjectSet(name,OBJPROP_STYLE,STYLE_DASH);
      ObjectSet(name,OBJPROP_WIDTH,1);
      WindowRedraw();
   }

}


