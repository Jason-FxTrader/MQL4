//+------------------------------------------------------------------+
//|                                                  CDictionary.mqh |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Vasiliy Sokolov."
#property link      "http://www.mql4.com"

#include <Object.mqh>
#include <Arrays\List.mqh>
//+------------------------------------------------------------------+
//| Êîíòåéíåð äëÿ õðàíåíèÿ ýëåìåíòîâ CObject                         |
//+------------------------------------------------------------------+
class KeyValuePair : public CObject
  {
private:
   string            m_string_key;    // Õðàíèò ñòðîêîâûé êëþ÷.
   double            m_double_key;    // Õðàíèò êëþ÷ ñ ïëàâàþùåé çàïÿòîé.
   ulong             m_ulong_key;     // Õðàíèò áåçíàêîâûé öåëî÷èñëåííûé êëþ÷.
   ulong             m_hash;
   bool              m_free_mode;     // Ðåæèì îñâîáîæäåíèÿ ïàìÿòè îáúåêòà
public:
   CObject          *object;
   KeyValuePair     *next_kvp;
   KeyValuePair     *prev_kvp;
   template<typename T>
                     KeyValuePair(T key,ulong hash,CObject *obj);
                    ~KeyValuePair();
   template<typename T>
   bool              EqualKey(T key);
   template<typename T>
   void              GetKey(T &gkey);
   ulong             GetHash(){return m_hash;}
   void              FreeMode(bool free_mode){m_free_mode=free_mode;}
   bool              FreeMode(void){return m_free_mode;}
  };
//+------------------------------------------------------------------+
//| Êîíñòðóêòîð ïî óìîë÷àíèþ.                                        |
//+------------------------------------------------------------------+
template<typename T>
void KeyValuePair::KeyValuePair(T key,ulong hash,CObject *obj)
  {
   m_hash=hash;
   string name=typename(key);
   if(name=="string")
      m_string_key=(string)key;
   else if(name=="double" || name=="float")
      m_double_key=(double)key;
   else
      m_ulong_key=(ulong)key;
   object=obj;
   m_free_mode=true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
KeyValuePair::GetKey(T &gkey)
  {
   string name=typename(gkey);
   if(name=="string")
      gkey=(T)m_string_key;
   else if(name=="double" || name=="float")
      gkey=(T)m_double_key;
   else
      gkey=(T)m_ulong_key;
  }
//+------------------------------------------------------------------+
//| Äèñòðóêòîð.                                                      |
//+------------------------------------------------------------------+
KeyValuePair::~KeyValuePair()
  {
   if(m_free_mode)
      delete object;
  }
//+------------------------------------------------------------------+
//| Âîçâðàùàåò èñòèíó, åñëè êëþ÷è ðàâíû.                             |
//+------------------------------------------------------------------+
template<typename T>
bool KeyValuePair::EqualKey(T key)
  {
   string name=typename(key);
   if(name=="string")
      return m_string_key == (string)key;
   if(name=="double" || name=="float")
      return m_double_key == (double)key;
   else
      return m_ulong_key == (ulong)key;
  }
//+------------------------------------------------------------------+
//| Àññîöèàòèâíûé ìàññèâ èëè ñëîâàðü, õðàíÿùèé ýëåìåíòû â âèäå       |
//| <êëþ÷ - çíà÷åíèå>. Ãäå êëþ÷îì ìîæåò ÿâëÿòüñÿ ëþáîé áàçîâûé òèï,  |
//| à çíà÷åíèåì - îáúåêò òèïà CObject.                               |
//+------------------------------------------------------------------+
class CDictionary
  {
private:
   int               m_array_size;
   int               m_total;
   bool              m_free_mode;
   bool              m_auto_free;
   int               m_index;
   ulong             m_hash;
   CList            *m_array[];

//MH removed structs to cope with MT4 build 1090
   double dValue;
   ulong lValue;

   KeyValuePair     *m_first_kvp;
   KeyValuePair     *m_current_kvp;
   KeyValuePair     *m_last_kvp;

   ulong             Adler32(string line);
   int               GetIndexByHash(ulong hash);
   template<typename T>
   ulong             GetHashByKey(T key);
   void              Resize();
   int               FindNextSimpleNumber(int number);
   int               FindNextLevel();
   void              Init(int capacity);

public:
                     CDictionary();
                     CDictionary(int capacity);
                    ~CDictionary();
   void              Compress(void);
   ///
   /// Returns the total number of items.
   ///
   int Total(void){return m_total;}
   /// Returns the element at key    
   template<typename T>
   CObject          *GetObjectByKey(T key);
   template<typename T>
   bool              AddObject(T key,CObject *value);
   template<typename T>
   bool              DeleteObjectByKey(T key);
   template<typename T>
   bool              ContainsKey(T key);
   template<typename T>
   void              GetCurrentKey(T &key);
   bool              DeleteCurrentNode(void);
   bool              FreeMode(void) { return(m_free_mode); }
   void              FreeMode(bool free_mode);
   void              AutoFreeMemory(bool autoFree){m_auto_free=autoFree;}
   void              Clear();

   CObject          *GetNextNode(void);
   CObject          *GetPrevNode(void);
   CObject          *GetCurrentNode(void);
   CObject          *GetFirstNode(void);
   CObject          *GetLastNode(void);

  };
//+------------------------------------------------------------------+
//| Êîíñòðóêòîð ïî óìîë÷àíèþ.                                        |
//+------------------------------------------------------------------+
CDictionary::CDictionary()
  {
   Init(3);
   m_auto_free=true;
  }
//+------------------------------------------------------------------+
//| Ñîçäàåò ñëîâàðü, ñ çàðàíåå îïðåäåëåííîé åìêîñòüþ capacity.       |
//+------------------------------------------------------------------+
CDictionary::CDictionary(int capacity)
  {
   Init(capacity);
   m_auto_free=true;
  }
//+------------------------------------------------------------------+
//| Äèñòðóêòîð.                                                      |
//+------------------------------------------------------------------+
CDictionary::~CDictionary()
  {
   Clear();
  }
//+------------------------------------------------------------------+
//| Ðåæèì óñòàíàâëèâàåò ðåæèì ïàìÿòè äëÿ âñåõ ïîäóçëîâ               |
//+------------------------------------------------------------------+  
void CDictionary::FreeMode(bool free_mode)
  {
   if(free_mode==m_free_mode)
      return;
   m_free_mode=free_mode;
   for(int i=0; i<ArraySize(m_array); i++)
     {
      CList *list=m_array[i];
      if(CheckPointer(list)==POINTER_INVALID)
         continue;
      for(KeyValuePair *kvp=list.GetFirstNode(); kvp!=NULL; kvp=list.GetNextNode())
         kvp.FreeMode(m_free_mode);
     }
  }
//+------------------------------------------------------------------+
//| Âûïîëíÿåò èíèöèàëèçàöèþ ñëîâàðÿ.                                 |
//+------------------------------------------------------------------+
void CDictionary::Init(int capacity)
  {
   m_array_size=ArrayResize(m_array,capacity);
   m_index= 0;
   m_hash = 0;
   m_total=0;
  }
//+------------------------------------------------------------------+
//| Íàõîäèò ñëåäóþùèé ðàçìåð äëÿ ñëîâàðÿ.                            |
//+------------------------------------------------------------------+
int CDictionary::FindNextLevel()
  {
   double value=4;
   for(int i=2; i<=31; i++)
     {
      value=MathPow(2.0,(double)i);
      if(value > m_total)return (int)value;
     }
   return (int)value;
  }
//+------------------------------------------------------------------+
//| Ïðèíèìàåò ñòðîêó è âîçâðàùàåò õýøèðóþùåå 32 áèòíîå ÷èñëî,        |
//| õàðàêòåðèçóþùåå ýòó ñòðîêó.                                      |
//+------------------------------------------------------------------+
ulong CDictionary::Adler32(string line)
  {
   ulong s1 = 1;
   ulong s2 = 0;
   uint buflength=StringLen(line);
   uchar char_array[];
   ArrayResize(char_array,buflength,0);
   StringToCharArray(line,char_array,0,-1,CP_ACP);
   for(uint n=0; n<buflength; n++)
     {
      s1 = (s1 + char_array[n]) % 65521;
      s2 = (s2 + s1)     % 65521;
     }
   return ((s2 << 16) + s1);
  }
//+------------------------------------------------------------------+
//| Ðàññ÷èòûâàåò õýø íà îñíîâå ïåðåäàííîãî êëþ÷à. Êëþ÷îì ìîæåò áûòü  |
//| ëþáîé áàçîâûé MQL òèï.
//+------------------------------------------------------------------+
template<typename T>
ulong CDictionary::GetHashByKey(T key)
  {
   ulong ukey = 0;
   string name=typename(key);
   if(name=="string")
      return Adler32((string)key);
   if(name=="double" || name=="float")
     {
//MH Changed to complie for MT4 build 1090
      dValue=(double)key;
      lValue=(ulong)dValue;
      ukey=lValue;
      //dValue.value=(double)key;
      //lValue=(ULongValue)dValue;
      //ukey=lValue.value;
     }
   else
      ukey=(ulong)key;
   return ukey;
  }
//+------------------------------------------------------------------+
//| Âîçâðàùàåò êëþ÷ òåêóùåãî ýëåìåíòà.                               |
//+------------------------------------------------------------------+
template<typename T>
void CDictionary::GetCurrentKey(T &key)
  {
   m_current_kvp.GetKey(key);
  }
//+------------------------------------------------------------------+
//| Âîçâðàùàåò èíäåêñ ïî êëþ÷ó.                                      |
//+------------------------------------------------------------------+
int CDictionary::GetIndexByHash(ulong key)
  {
   return (int)(key%m_array_size);
  }
//+------------------------------------------------------------------+
//| Î÷èùàåò ñëîâàðü îò âñåõ çíà÷åíèé.                                |
//+------------------------------------------------------------------+
void CDictionary::Clear(void)
  {
   int size=ArraySize(m_array);
   for(int i=0; i<size; i++)
     {
      if(CheckPointer(m_array[i])!=POINTER_INVALID)
        {
         m_array[i].FreeMode(true); // Ýëåìåíòû òèïà KeyValuePair óäàëÿþòñÿ âñåãäà
         delete m_array[i];
        }
     }
   ArrayFree(m_array);
   if(m_auto_free)
      Init(3);
   else
      Init(size);
   m_first_kvp=m_last_kvp=m_current_kvp=NULL;
  }
//+------------------------------------------------------------------+
//int MH_ArrayCopy(
//   void&        dst_array[],         // destination array 
//   const void&  src_array[])         // source array 
//+------------------------------------------------------------------+
template <typename T> // to cope with different types

int MH_ArrayCopy(
   T& dst_array[],  // destination array 
   T& src_array[])  // source array 
{
   ArrayFree(dst_array);
   int n = ArraySize(src_array);
   ArrayResize(dst_array, n);
   for (int i=0; i<n; i++)
      dst_array[i] = src_array[i];
   return (n);   
}   
//+------------------------------------------------------------------+
//| Replaced the following function Resize due to MT4 build 1090 error|
//+------------------------------------------------------------------+
void CDictionary::Resize(void)
  {
   int level=FindNextLevel();
   int n=level;
   CList *temp_array[];
   MH_ArrayCopy(temp_array,m_array);
   ArrayFree(m_array);
   m_array_size=ArrayResize(m_array,n);
   int total=ArraySize(temp_array);
   KeyValuePair *kv=NULL;
   for(int i=0; i<total; i++)
     {
      if(temp_array[i]==NULL)continue;
      CList *list=temp_array[i];
      int count=list.Total();
      list.FreeMode(false);
      kv=list.GetFirstNode();
      while(kv!=NULL)
        {
         int index=GetIndexByHash(kv.GetHash());
         if(CheckPointer(m_array[index])==POINTER_INVALID)
           {
            m_array[index]=new CList();
            m_array[index].FreeMode(true);   // Ýëåìåíòû KeyValuePair óäàëÿþòñÿ âñåãäà
           }
         list.DetachCurrent();
         m_array[index].Add(kv);
         kv=list.GetCurrentNode();
        }
      delete list;
     }
   int size=ArraySize(temp_array);
   ArrayFree(temp_array);
  }
////+------------------------------------------------------------------+
////| Ïåðåðàçìå÷àåò êîíòåéíåð õðàíåíèÿ äàííûõ.                         |
////+------------------------------------------------------------------+
//void CDictionary::Resize(void)
//  {
//   int level=FindNextLevel();
//   int n=level;
//   CList *temp_array[];
//   ArrayCopy(temp_array,m_array);
//   ArrayFree(m_array);
//   m_array_size=ArrayResize(m_array,n);
//   int total=ArraySize(temp_array);
//   KeyValuePair *kv=NULL;
//   for(int i=0; i<total; i++)
//     {
//      if(temp_array[i]==NULL)continue;
//      CList *list=temp_array[i];
//      int count=list.Total();
//      list.FreeMode(false);
//      kv=list.GetFirstNode();
//      while(kv!=NULL)
//        {
//         int index=GetIndexByHash(kv.GetHash());
//         if(CheckPointer(m_array[index])==POINTER_INVALID)
//           {
//            m_array[index]=new CList();
//            m_array[index].FreeMode(true);   // Ýëåìåíòû KeyValuePair óäàëÿþòñÿ âñåãäà
//           }
//         list.DetachCurrent();
//         m_array[index].Add(kv);
//         kv=list.GetCurrentNode();
//        }
//      delete list;
//     }
//   int size=ArraySize(temp_array);
//   ArrayFree(temp_array);
//  }
//+------------------------------------------------------------------+
//| Ñæèìàåò ñëîâàðü.                                                 |
//+------------------------------------------------------------------+
CDictionary::Compress(void)
  {
   if(!m_auto_free)return;
   double koeff=m_array_size/(double)(m_total+1);
   if(koeff < 2.0 || m_total <= 4)return;
   Resize();
  }
//+------------------------------------------------------------------+
//| Âîçâðàùåò îáúåêò ïî êëþ÷ó.                                       |
//+------------------------------------------------------------------+
template<typename T>
CObject *CDictionary::GetObjectByKey(T key)
  {
   if(!ContainsKey(key))
      return NULL;
   CObject *obj=m_current_kvp.object;
   return obj;
  }
//+------------------------------------------------------------------+
//| Ïðîâåðÿåò ñîäåðæèò ëè ñëîâàðü êëþ÷ ïðîèçâîëüíîãî òèïà T.         |
//| RETURNS:                                                         |
//|   Âîçâðàùàåò èñòèíó, åñëè îáúåêò ñ òàêèì êëþ÷îì óæå ñóùåñòâóåò   |
//|   è ëîæü â ïðîòèâíîì ñëó÷àå.                                     |
//+------------------------------------------------------------------+
template<typename T>
bool CDictionary::ContainsKey(T key)
  {
   m_hash=GetHashByKey(key);
   m_index=GetIndexByHash(m_hash);
   if(CheckPointer(m_array[m_index])==POINTER_INVALID)
      return false;
   CList *list=m_array[m_index];
   KeyValuePair *current_kvp=list.GetCurrentNode();
   if(current_kvp == NULL)return false;
   if(current_kvp.EqualKey(key))
     {
      m_current_kvp=current_kvp;
      return true;
     }
   current_kvp=list.GetFirstNode();
   while(true)
     {
      if(current_kvp.EqualKey(key))
        {
         m_current_kvp=current_kvp;
         return true;
        }
      current_kvp=list.GetNextNode();
      if(current_kvp==NULL)
         return false;
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Äîáàâëÿåò â ñëîâàðü ýëåìåíò òèïà CObject ñ êëþ÷îì T key.         |
//| INPUT PARAMETRS:                                                 |
//|   T key - ëþáîé áàçîâûé òèï, íàïðèìåð int, double èëè string.    |
//|   value - êëàññ, ïðîèçâîäíûé îò CObject.                         |
//| RETURNS:                                                         |
//|   Èñòèíà, åñëè ýëåìåíò áûë äîáàâëåí è ëîæü â ïðîòèâíîì ñëó÷àå.   |
//+------------------------------------------------------------------+
template<typename T>
bool CDictionary::AddObject(T key,CObject *value)
  {
   if(ContainsKey(key))
      return false;
   if(m_total==m_array_size)
     {
      Resize();
      ContainsKey(key);
     }
   if(CheckPointer(m_array[m_index])==POINTER_INVALID)
     {
      m_array[m_index]=new CList();
      m_array[m_index].FreeMode(true);   // Ýëåìåíòû KeyValuePair óäàëÿþòñÿ âñåãäà
     }
   KeyValuePair *kv=new KeyValuePair(key,m_hash,value);
   kv.FreeMode(m_free_mode);
   if(m_array[m_index].Add(kv)!=-1)
      m_total++;
   if(CheckPointer(m_current_kvp)==POINTER_INVALID)
     {
      m_first_kvp=kv;
      m_current_kvp=kv;
      m_last_kvp=kv;
     }
   else
     {
      //äîáàâëÿåì â ñàìûé êîíåö, ò.ê. òåêóùèé óçåë ìîæåò áûòü ãäå óãîäíî
      while(m_current_kvp.next_kvp!=NULL)
         m_current_kvp=m_current_kvp.next_kvp;
      m_current_kvp.next_kvp=kv;
      kv.prev_kvp=m_current_kvp;
      m_current_kvp=kv;
      m_last_kvp=kv;
     }
   return true;
  }
//+------------------------------------------------------------------+
//| Âîçâðàùàåò òåêóùèé îáúåêò. Åñëè îáúåêò íå âûáðàí âîçâðàùàåò      |
//| NULL.                                                            |
//+------------------------------------------------------------------+
CObject *CDictionary::GetCurrentNode(void)
  {
   if(m_current_kvp==NULL)
      return NULL;
   return m_current_kvp.object;
  }
//+------------------------------------------------------------------+
//| Âîçâðàùàåò ïðåäûäóùèé îáúåêò. Ïîñëå âûçîâà ìåòîäà òåêóùèé        |
//| îáúåêò ñòàíîâèòüñÿ ïðåäûäóùèì. Åñëè îáúåêò íå âûáðàí, âîçâðàùàåò |
//| NULL.                                                            |
//+------------------------------------------------------------------+
CObject *CDictionary:: GetPrevNode(void)
  {
   if(m_current_kvp==NULL)
      return NULL;
   if(m_current_kvp.prev_kvp==NULL)
      return NULL;
   KeyValuePair *kvp=m_current_kvp.prev_kvp;
   m_current_kvp=kvp;
   return kvp.object;
  }
//+------------------------------------------------------------------+
//| Âîçâðàùàåò ñëåäóþùèé îáúåêò. Ïîñëå âûçîâà ìåòîäà òåêóùèé         |
//| îáúåêò ñòàíîâèòüñÿ ñëåäóþùèì. Åñëè îáúåêò íå âûáðàí, âîçâðàùàåò  |
//| NULL.                                                            |
//+------------------------------------------------------------------+
CObject *CDictionary::GetNextNode(void)
  {
   if(m_current_kvp==NULL)
      return NULL;
   if(m_current_kvp.next_kvp==NULL)
      return NULL;
   m_current_kvp=m_current_kvp.next_kvp;
   return m_current_kvp.object;
  }
//+------------------------------------------------------------------+
//| Âîçâðàùàåò ïåðâûé óçåë â ñïèñêå óçëîâ. Åñëè â ñëîâàðå óçëîâ íåò, |
//| âîçâðàùàåò NULL.                                                 |
//+------------------------------------------------------------------+
CObject *CDictionary::GetFirstNode(void)
  {
   if(m_first_kvp==NULL)
      return NULL;
   m_current_kvp=m_first_kvp;
   return m_first_kvp.object;
  }
//+------------------------------------------------------------------+
//| Âîçâðàùàåò ïîñëåäíèé óçåë â ñïèñêå óçëîâ. Åñëè â ñëîâàðå óçëîâ   |
//| íåò âîçâðàùàåò NULL.                                             |
//+------------------------------------------------------------------+
CObject *CDictionary::GetLastNode(void)
  {
   if(m_last_kvp==NULL)
      return NULL;
   m_current_kvp=m_last_kvp;
   return m_last_kvp.object;
  }
//+------------------------------------------------------------------+
//| Óäàëÿåò òåêóùèé óçåë                                             |
//+------------------------------------------------------------------+
bool CDictionary::DeleteCurrentNode(void)
  {
   if(m_current_kvp==NULL)
      return false;
//Log(__LINE__, __FUNCTION__, "() m_current_kvp!=NULL");
   KeyValuePair* p_kvp = m_current_kvp.prev_kvp;
   KeyValuePair* n_kvp = m_current_kvp.next_kvp;
   if(CheckPointer(p_kvp)!=POINTER_INVALID)
{
//Log(__LINE__, __FUNCTION__, "() CheckPointer(p_kvp)!=POINTER_INVALID");
      p_kvp.next_kvp=n_kvp;
}
   if(CheckPointer(n_kvp)!=POINTER_INVALID)
{
//Log(__LINE__, __FUNCTION__, "() CheckPointer(n_kvp)!=POINTER_INVALID");
      n_kvp.prev_kvp=p_kvp;
}
   m_array[m_index].FreeMode(m_free_mode);
//Log(__LINE__, __FUNCTION__, "() m_array[m_index].FreeMode(m_free_mode);");
   bool res=m_array[m_index].DeleteCurrent();
//Log(__LINE__, __FUNCTION__, "() bool res=m_array[m_index].DeleteCurrent();");
   if(res)
     {
      m_total--;
      Compress();
     }
   return res;
  }
//+------------------------------------------------------------------+
//| Óäàëÿåò îáúåêò ñ êëþ÷îì key èç ñëîâàðÿ.                          |
//+------------------------------------------------------------------+
template<typename T>
bool CDictionary::DeleteObjectByKey(T key)
  {
//Log(__LINE__, __FUNCTION__, "() Current Key: #"+key+", now attempting to find it");
   if(!ContainsKey(key))
      return false;
//Log(__LINE__, __FUNCTION__, "() Current Key: #"+key+", key found, now attempting to delete current node");
   return DeleteCurrentNode();
  }

#define FOREACH_DICT(dict) for(CObject* node = (dict).GetFirstNode(); node != NULL; node = (dict).GetNextNode())
//+------------------------------------------------------------------+
