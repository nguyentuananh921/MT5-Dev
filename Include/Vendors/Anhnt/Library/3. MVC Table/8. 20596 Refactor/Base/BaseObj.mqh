//+------------------------------------------------------------------+
//|                                                    BaseObj.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//| First See in                                                     |
//|       Base graphical element                                     |
//|                           https://www.mql5.com/en/articles/17960 |
//| Update in                                                        |
//|       Simple controls                                            |
//|                           https://www.mql5.com/en/articles/18221 |  

//| Update in                             Resizable elements         |
//|                           https://www.mql5.com/en/articles/18941 |
//| Update in                                                        |
//|       Integrating the Model Component into the View Component    |
//|                           https://www.mql5.com/en/articles/19288 |
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
#include "..\Defines\BaseEnums.mqh"
#include "..\Defines\TableEnums.mqh"
#include "..\Defines\ControlsEnums.mqh"

   
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
      //| Update in                                                        |
      //|       Simple controls                                            |
      //|                           https://www.mql5.com/en/articles/18221 | 
         virtual bool      Save(const int file_handle);
         virtual bool      Load(const int file_handle);
      virtual int       Type(void)                          const { return(ELEMENT_TYPE_BASE); }
      //Virtual method to move function to class
         // --- Virtual method to get short name replace ElementShortName function
         virtual string    ShortName(void) const { return CBaseObj::FormatElementShortName((ENUM_ELEMENT_TYPE)this.Type()); }
         // --- Helper for element short names (Replacing ElementShortName)
         static string     FormatElementShortName(const ENUM_ELEMENT_TYPE type);
         // --- Helper for standard MT5 object types (Replacing TypeDescription) Returns the object type as a string
         static string            FormatObjectType(const ENUM_OBJECT_TYPE type);   
         // --- Helper for library element types (Replacing ElementDescription) Returns the element type as a string
         static string            FormatElementType(const ENUM_ELEMENT_TYPE type); 
         // --- Static helper to split element names by delimiter 
         static int        GetElementNames(string value, string sep, string &array[]);  
      //| Update in                                                        |
      //|       Simple controls                                            |
      //|                           https://www.mql5.com/en/articles/18221 |  
         // --- (1) Returns, (2) logs a description of the object
         virtual string    Description(void);
         virtual void      Print(void);
      
   // --- Constructor/destructor
                     CBaseObj (void) : m_id(-1) { this.SetName(""); }
                     ~CBaseObj (void) {}
  };
#ifndef __CBASEOBJ_IMPLEMENTATION__
#define __CBASEOBJ_IMPLEMENTATION__
 //+------------------------------------------------------------------+
 //| Returns an array of element hierarchy names                      |
 //| Splits a string by delimiter and handles errors                  |
 //+------------------------------------------------------------------+
 int CBaseObj::GetElementNames(string value, string sep, string &array[])
  {
   if(value == "" || value == NULL)
   {
      ::PrintFormat("%s: Error. Empty string passed", __FUNCTION__);
      return 0;
   }
   ::ResetLastError();
   int res = ::StringSplit(value, ::StringGetCharacter(sep, 0), array);
   if(res == WRONG_VALUE)
   {
      ::PrintFormat("%s: StringSplit() failed. Error %d", __FUNCTION__, ::GetLastError());
      return WRONG_VALUE;
   }
   return res;
  }
 //+------------------------------------------------------------------+
 //| Returns the short name of the element type                       |
 //+------------------------------------------------------------------+
 string CBaseObj::FormatElementShortName(const ENUM_ELEMENT_TYPE type)
  {
      switch(type)
      {
         case ELEMENT_TYPE_ELEMENT_BASE            :  return "BASE";
         case ELEMENT_TYPE_HINT                    :  return "HNT";
         case ELEMENT_TYPE_LABEL                   :  return "LBL";
         case ELEMENT_TYPE_BUTTON                  :  return "SBTN";
         case ELEMENT_TYPE_BUTTON_TRIGGERED        :  return "TBTN";
         case ELEMENT_TYPE_BUTTON_ARROW_UP         :  return "BTARU";
         case ELEMENT_TYPE_BUTTON_ARROW_DOWN       :  return "BTARD";
         case ELEMENT_TYPE_BUTTON_ARROW_LEFT       :  return "BTARL";
         case ELEMENT_TYPE_BUTTON_ARROW_RIGHT      :  return "BTARR";
         case ELEMENT_TYPE_CHECKBOX                :  return "CHKB";
         case ELEMENT_TYPE_RADIOBUTTON             :  return "RBTN";
         case ELEMENT_TYPE_SCROLLBAR_THUMB_H       :  return "THMBH";
         case ELEMENT_TYPE_SCROLLBAR_THUMB_V       :  return "THMBV";
         case ELEMENT_TYPE_SCROLLBAR_H             :  return "SCBH";
         case ELEMENT_TYPE_SCROLLBAR_V             :  return "SCBV";
         case ELEMENT_TYPE_TABLE_CELL_VIEW         :  return "TCELL";
         case ELEMENT_TYPE_TABLE_ROW_VIEW          :  return "TROW";
         case ELEMENT_TYPE_TABLE_CAPTION_VIEW      :  return "TCAPT";
         case ELEMENT_TYPE_TABLE_COLUMN_CAPTION_VIEW: return "TCCAPT";
         case ELEMENT_TYPE_TABLE_ROW_CAPTION_VIEW   :  return "TRCAPT";
         case ELEMENT_TYPE_TABLE_HEADER_VIEW       :  return "TCHDR";
         case ELEMENT_TYPE_TABLE_ROWS_HEADER_VIEW  :  return "TRHDR";
         case ELEMENT_TYPE_TABLE_VIEW              :  return "TABLE";
         case ELEMENT_TYPE_TABLE_CONTROL_VIEW      :  return "TBLCTRL";
         case ELEMENT_TYPE_PANEL                   :  return "PNL";
         case ELEMENT_TYPE_GROUPBOX                :  return "GRBX";
         case ELEMENT_TYPE_CONTAINER               :  return "CNTR";
         default                                   :  return "UNKN";
      }
  }
 string CBaseObj::FormatObjectType(const ENUM_OBJECT_TYPE type)
  {
   string enumStr = EnumToString(type); // Trích xuất chuỗi từ ENUM_OBJECT_TYPE
   string array[];
   int total = StringSplit(enumStr, StringGetCharacter("_", 0), array);
   string result = "";
   for(int i = 2; i < total; i++)
   {
      array[i].Lower();
      if(StringLen(array[i]) > 0) array[i].SetChar(0, ushort(array[i].GetChar(0) - 0x20));
      result += array[i] + " ";
   }
   StringTrimRight(result);
   return result;
  }
 string CBaseObj::FormatElementType(const ENUM_ELEMENT_TYPE type)
  {
   string enumStr = EnumToString(type); // Trích xuất chuỗi từ ENUM_ELEMENT_TYPE
   string array[];
   int total = StringSplit(enumStr, StringGetCharacter("_", 0), array);
   
   if(total > 0)
   {
      // Fix logic V/H của tác giả
      if(array[total-1] == "V") array[total-1] = "Vertical";
      if(array[total-1] == "H") array[total-1] = "Horizontal";
   }
   
   string result = "";
   for(int i = 2; i < total; i++)
   {
      array[i].Lower();
      if(StringLen(array[i]) > 0) array[i].SetChar(0, ushort(array[i].GetChar(0) - 0x20));
      result += array[i] + " ";
   }
   StringTrimRight(result);
   return result;
  }
 //+------------------------------------------------------------------+
 //| CBaseObj::Comparing two objects |
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
      //--- 1. Get properties
   string name = this.Name();
   int    id   = this.ID();   
   //--- 2. Get formatted Type Name using the Element Helper
   //--- (This handles the split, capitalization, and V/H logic)
   string typeStr = this.FormatElementType((ENUM_ELEMENT_TYPE)this.Type());
   
   //--- 3. Format the name with quotes if not empty
   string formattedName = (name != "" ? ::StringFormat(" \"%s\"", name) : "");
   
   //--- 4. Return unified string
   return ::StringFormat("%s%s ID %d", typeStr, formattedName, id);
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
#endif // __CBASEOBJ_IMPLEMENTATION__
#endif // __BASEOBJ_MQH__
