//+------------------------------------------------------------------+
//|                                                    BaseObj.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//|First See in              https://www.mql5.com/en/articles/17960  |
//|Current                    https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| Basic class of graphic elements |
//+------------------------------------------------------------------+
#ifndef __BASEOBJ_MQH__
#define __BASEOBJ_MQH__
   //+------------------------------------------------------------------+
   //| Included Standard Libraries                                      |
   //+------------------------------------------------------------------+
   //#include <Arrays\List.mqh>
   //+------------------------------------------------------------------+
   //| Included Custome Libraries                                       |
   //+------------------------------------------------------------------+
   #include "CommonManager.mqh"
   #include "..\Services\FunctionLib.mqh"   
   class CBaseObj : public CObject
   {
      protected:
         int               m_id;                                     // Identifier
         ushort            m_name[];                                 // Name
         
      public:
      // --- Sets (1) name, (2) identifier
         void              SetName(const string name)                { ::StringToShortArray(name,this.m_name);          }
         virtual void      SetID(const int id)                       { this.m_id=id;                                    }
      // --- Returns (1) name, (2) identifier
         string            Name(void)                          const { return ::ShortArrayToString(this.m_name);        }
         int               ID(void)                            const { return this.m_id;                                }

      // --- Returns the coordinates of the cursor
         int               CursorX(void)                       const { return CCommonManager::GetInstance().CursorX();  }
         int               CursorY(void)                       const { return CCommonManager::GetInstance().CursorY();  }

      // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
         virtual int       Compare(const CObject *node,const int mode=0) const;
         virtual bool      Save(const int file_handle);
         virtual bool      Load(const int file_handle);
         virtual int       Type(void)                          const { return(ELEMENT_TYPE_BASE); }
         
      // --- (1) Returns, (2) logs a description of the object
         virtual string    Description(void);
         virtual void      Print(void);
         
      // --- Constructor/destructor
                        CBaseObj (void) : m_id(-1) { this.SetName(""); }
                        ~CBaseObj (void) {}
   };
   #ifndef CBASEOBJ_IMPLEMENTATION
   #define CBASEOBJ_IMPLEMENTATION
      //+------------------------------------------------------------------+
      // | CBaseObj::Comparing two objects |
      //+------------------------------------------------------------------+
      int CBaseObj::Compare(const CObject *node,const int mode=0) const
      {
         if(node==NULL)
            return -1;
         const CBaseObj *obj=node;
         switch(mode)
         {
            case 0   :  return(this.ID()  >obj.ID()   ? 1 : this.ID()  <obj.ID()   ? -1 : 0);
            default  :  return(this.Name()>obj.Name() ? 1 : this.Name()<obj.Name() ? -1 : 0);
         }
      }
      //+------------------------------------------------------------------+
      // | CBaseObj::Returns the object description |
      //+------------------------------------------------------------------+
      string CBaseObj::Description(void)
      {
         string nm=this.Name();
         string name=(nm!="" ? ::StringFormat(" \"%s\"",nm) : nm);
         return ::StringFormat("%s%s ID %d",ElementDescription((ENUM_ELEMENT_TYPE)this.Type()),name,this.ID());
      }
      //+------------------------------------------------------------------+
      // | CBaseObj::Logs a description of an object |
      //+------------------------------------------------------------------+
      void CBaseObj::Print(void)
      {
         ::Print(this.Description());
      }
      //+------------------------------------------------------------------+
      // | CBaseObj::Saving to file |
      //+------------------------------------------------------------------+
      bool CBaseObj::Save(const int file_handle)
      {
      // --- Checking the handle
         if(file_handle==INVALID_HANDLE)
            return false;
      // --- Save the data start marker - 0xFFFFFFFFFFFFFFFF
         if(::FileWriteLong(file_handle,-1)!=sizeof(long))
            return false;
      // --- Save the object type
         if(::FileWriteInteger(file_handle,this.Type(),INT_VALUE)!=INT_VALUE)
            return false;

      // --- Save the ID
         if(::FileWriteInteger(file_handle,this.m_id,INT_VALUE)!=INT_VALUE)
            return false;
      // --- Save the name
         if(::FileWriteArray(file_handle,this.m_name)!=sizeof(this.m_name))
            return false;
         
      // --- Everything is successful
         return true;
      }
      //+------------------------------------------------------------------+
      // | CBaseObj::Loading from file |
      //+------------------------------------------------------------------+
      bool CBaseObj::Load(const int file_handle)
      {
      // --- Checking the handle
         if(file_handle==INVALID_HANDLE)
            return false;
      // --- Load and check the data start marker - 0xFFFFFFFFFFFFFFFF
         if(::FileReadLong(file_handle)!=-1)
            return false;
      // --- Loading the object type
         if(::FileReadInteger(file_handle,INT_VALUE)!=this.Type())
            return false;

      // --- Loading ID
         this.m_id=::FileReadInteger(file_handle,INT_VALUE);
      // --- Loading the name
         if(::FileReadArray(file_handle,this.m_name)!=sizeof(this.m_name))
            return false;
         
      // --- Everything is successful
         return true;
      }
      //+------------------------------------------------------------------+
   #endif // DECLARATION_IMPLEMENTATION
#endif // __BASEOBJ_MQH__
