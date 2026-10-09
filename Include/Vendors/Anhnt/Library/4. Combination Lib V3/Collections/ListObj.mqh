//+------------------------------------------------------------------+
//|                                                      ListObj.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|Topic link: https://www.mql5.com/en/articles/6211                 |
//|Lib https://www.mql5.com/en/articles/14710                        |

//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Include files                                                    |
//+------------------------------------------------------------------+
#ifndef __LISTOBJ_MQH__
#define __LISTOBJ_MQH__
 #include <Arrays\ArrayObj.mqh>
 //+------------------------------------------------------------------+
 //| Collections lists class                                          |
 //+------------------------------------------------------------------+
#ifndef CLISTOBJ_MQH_DECLARATION
#define CLISTOBJ_MQH_DECLARATION
class CListObj : public CArrayObj
  {
   private:
    int               m_type;                    // List type
    public:
     bool              DetachElement(const int index);                       
     void              Type(const int type)       { this.m_type=type;     }
     virtual int       Type(void)           const { return(this.m_type);  }
     //--- Collection list IDs in CommonDefines.mqh 
                       CListObj()                 { this.m_type=0x7778;   }
  };
#endif // CLISTOBJ_MQH_DECLARATION
#ifndef CLISTOBJ_MQH_IMPLEMENTATION
#define CLISTOBJ_MQH_IMPLEMENTATION
 bool CListObj::DetachElement(const int index)
   {
    CObject *obj=CArrayObj::Detach(index);
    if(obj==NULL)
      return false;
    obj=NULL;
    return true;
   }
//+------------------------------------------------------------------+
#endif // CLISTOBJ_MQH_IMPLEMENTATION
#endif // __LISTOBJ_MQH__


