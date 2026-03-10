//+------------------------------------------------------------------+
//|                                                      BaseObj.mqh |
//+------------------------------------------------------------------+
//|                   Tables in the MVC Paradigm in MQL5             |
//|                Customizable and sortable table columns           |
//|                           https://www.mql5.com/en/articles/19979 |
//+------------------------------------------------------------------+
#ifndef __BASEOBJ_MQH__
#define __BASEOBJ_MQH__
//+------------------------------------------------------------------+
//| Base class for graphical elements                                |
//+------------------------------------------------------------------+
//|Include stadard library                                           |
//+------------------------------------------------------------------+
#include <Object.mqh>  

//+------------------------------------------------------------------+
//|Include Custome library                                           |
//+------------------------------------------------------------------+
#include "CommonManager.mqh"
#include "BaseEnums.mqh"

class CBaseObj : public CObject
  {
protected:
   int               m_id;         // Identifier
   ushort            m_name[];     // Name
   
public:

//--- Set (1) name, (2) identifier
   void              SetName(const string name) { ::StringToShortArray(name,this.m_name); }
   virtual void      SetID(const int id) { this.m_id=id; }

//--- Return (1) name, (2) identifier
   string            Name(void) const { return ::ShortArrayToString(this.m_name); }
   int               ID(void)   const { return this.m_id; }

//--- Return cursor coordinates
   int               CursorX(void) const { return CCommonManager::GetInstance().CursorX(); }
   int               CursorY(void) const { return CCommonManager::GetInstance().CursorY(); }

//--- Virtual methods
   virtual int       Compare(const CObject *node,const int mode=0) const;
   virtual bool      Save(const int file_handle);
   virtual bool      Load(const int file_handle);
   virtual int       Type(void) const { return(ELEMENT_TYPE_BASE); }

//--- (1) Return, (2) print object description
   virtual string    Description(void);
   virtual void      Print(void);

//--- Constructor / destructor
                     CBaseObj (void) : m_id(-1) { this.SetName(""); }
                    ~CBaseObj (void) {}
  };

//+------------------------------------------------------------------+
//| CBaseObj::Compare two objects                                    |
//+------------------------------------------------------------------+
int CBaseObj::Compare(const CObject *node,const int mode=0) const
  {
   if(node==NULL)
      return -1;

   const CBaseObj *obj=node;

   switch(mode)
     {
      case 0:
         return(this.ID()>obj.ID()?1:this.ID()<obj.ID()?-1:0);

      default:
         return(this.Name()>obj.Name()?1:this.Name()<obj.Name()?-1:0);
     }
  }

//+------------------------------------------------------------------+
//| CBaseObj::Return object description                              |
//+------------------------------------------------------------------+
string CBaseObj::Description(void)
  {
   string nm=this.Name();
   string name=(nm!="" ? ::StringFormat(" \"%s\"",nm) : nm);
   return ::StringFormat("%s%s ID %d",ElementDescription((ENUM_ELEMENT_TYPE)this.Type()),name,this.ID());
  }

//+------------------------------------------------------------------+
//| CBaseObj::Print object description to log                        |
//+------------------------------------------------------------------+
void CBaseObj::Print(void)
  {
   ::Print(this.Description());
  }

//+------------------------------------------------------------------+
//| CBaseObj::Save to file                                           |
//+------------------------------------------------------------------+
bool CBaseObj::Save(const int file_handle)
  {
   if(file_handle==INVALID_HANDLE)
      return false;

//--- Save data start marker
   if(::FileWriteLong(file_handle,-1)!=sizeof(long))
      return false;

//--- Save object type
   if(::FileWriteInteger(file_handle,this.Type(),INT_VALUE)!=INT_VALUE)
      return false;

//--- Save identifier
   if(::FileWriteInteger(file_handle,this.m_id,INT_VALUE)!=INT_VALUE)
      return false;

//--- Save name
   if(::FileWriteArray(file_handle,this.m_name)!=sizeof(this.m_name))
      return false;

   return true;
  }

//+------------------------------------------------------------------+
//| CBaseObj::Load from file                                         |
//+------------------------------------------------------------------+
bool CBaseObj::Load(const int file_handle)
  {
   if(file_handle==INVALID_HANDLE)
      return false;

//--- Check start marker
   if(::FileReadLong(file_handle)!=-1)
      return false;

//--- Check type
   if(::FileReadInteger(file_handle,INT_VALUE)!=this.Type())
      return false;

//--- Load identifier
   this.m_id=::FileReadInteger(file_handle,INT_VALUE);

//--- Load name
   if(::FileReadArray(file_handle,this.m_name)!=sizeof(this.m_name))
      return false;

   return true;
  }
string ElementDescription(const ENUM_ELEMENT_TYPE type)
{
   string array[];
   int total=StringSplit(EnumToString(type),StringGetCharacter("_",0),array);

   if(array[array.Size()-1]=="V")
      array[array.Size()-1]="Vertical";

   if(array[array.Size()-1]=="H")
      array[array.Size()-1]="Horisontal";

   string result="";

   for(int i=2;i<total;i++)
     {
      array[i]+=" ";
      array[i].Lower();
      array[i].SetChar(0,ushort(array[i].GetChar(0)-0x20));
      result+=array[i];
     }

   result.TrimLeft();
   result.TrimRight();

   return result;
}

//+------------------------------------------------------------------+
//| Returns short element name by type                               |
//+------------------------------------------------------------------+
string ElementShortName(const ENUM_ELEMENT_TYPE type)
{
   switch(type)
     {
      case ELEMENT_TYPE_ELEMENT_BASE               :  return "BASE";    
      case ELEMENT_TYPE_HINT                       :  return "HNT";     
      case ELEMENT_TYPE_LABEL                      :  return "LBL";     
      case ELEMENT_TYPE_BUTTON                     :  return "SBTN";    
      case ELEMENT_TYPE_BUTTON_TRIGGERED           :  return "TBTN";    
      case ELEMENT_TYPE_BUTTON_ARROW_UP            :  return "BTARU";   
      case ELEMENT_TYPE_BUTTON_ARROW_DOWN          :  return "BTARD";   
      case ELEMENT_TYPE_BUTTON_ARROW_LEFT          :  return "BTARL";   
      case ELEMENT_TYPE_BUTTON_ARROW_RIGHT         :  return "BTARR";   
      case ELEMENT_TYPE_CHECKBOX                   :  return "CHKB";    
      case ELEMENT_TYPE_RADIOBUTTON                :  return "RBTN";    
      case ELEMENT_TYPE_SCROLLBAR_THUMB_H          :  return "THMBH";   
      case ELEMENT_TYPE_SCROLLBAR_THUMB_V          :  return "THMBV";   
      case ELEMENT_TYPE_SCROLLBAR_H                :  return "SCBH";    
      case ELEMENT_TYPE_SCROLLBAR_V                :  return "SCBV";    
      case ELEMENT_TYPE_TABLE_CELL_VIEW            :  return "TCELL";   
      case ELEMENT_TYPE_TABLE_ROW_VIEW             :  return "TROW";    
      case ELEMENT_TYPE_TABLE_COLUMN_CAPTION_VIEW  :  return "TCAPT";   
      case ELEMENT_TYPE_TABLE_HEADER_VIEW          :  return "THDR";    
      case ELEMENT_TYPE_TABLE_VIEW                 :  return "TABLE";   
      case ELEMENT_TYPE_TABLE_CONTROL_VIEW         :  return "TBLCTRL"; 
      case ELEMENT_TYPE_PANEL                      :  return "PNL";     
      case ELEMENT_TYPE_GROUPBOX                   :  return "GRBX";    
      case ELEMENT_TYPE_CONTAINER                  :  return "CNTR";    
      default                                      :  return "Unknown";
     }
}

//+------------------------------------------------------------------+
//| Returns hierarchy element names array                            |
//+------------------------------------------------------------------+
int GetElementNames(string value,string sep,string &array[])
{
   if(value=="" || value==NULL)
     {
      PrintFormat("%s: Error. Empty string passed");
      return 0;
     }

   ResetLastError();

   int res=StringSplit(value,StringGetCharacter(sep,0),array);

   if(res==WRONG_VALUE)
     {
      PrintFormat("%s: StringSplit() failed. Error %d",__FUNCTION__,GetLastError());
      return WRONG_VALUE;
     }

   return res;
}
#endif