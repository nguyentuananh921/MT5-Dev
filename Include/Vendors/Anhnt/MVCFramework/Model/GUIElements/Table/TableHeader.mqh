//+------------------------------------------------------------------+
//|                                                  TableHeader.mqh |
//+------------------------------------------------------------------+
//|                   Tables in the MVC Paradigm in MQL5             |
//|                Customizable and sortable table columns           |
//|            https://www.mql5.com/en/articles/19979                |
//+------------------------------------------------------------------+
#ifndef TABLEHEADER_MQH
#define TABLEHEADER_MQH
//+------------------------------------------------------------------+
//| Table header class                                               |
//+------------------------------------------------------------------+
//|Include standard library                                          |
//+------------------------------------------------------------------+
#include <Object.mqh>

//+------------------------------------------------------------------+
//|Include custom library                                            |
//+------------------------------------------------------------------+
#include "TableDefines.mqh"    // constants
#include "TableEnums.mqh"      // enums
#include "ListObj.mqh"         // CListObj
#include "ColumnCaption.mqh"   // CColumnCaption

CColumnCaption m_caption_tmp;
CListObj       m_list_captions;

class CTableHeader : public CObject
  {
protected:
   CColumnCaption    m_caption_tmp;        // Temporary column caption object used for search
   CListObj          m_list_captions;      // List of column captions
   
//--- Adds the specified caption to the end of the list
   bool              AddNewColumnCaption(CColumnCaption *caption);

//--- Creates table header from string array
   void              CreateHeader(string &array[]);

//--- Updates column position for all captions
   void              ColumnPositionUpdate(void);
   
public:
//--- Creates a new caption and adds it to the end of the list
   CColumnCaption   *CreateNewColumnCaption(const string caption);

//--- Returns (1) caption by index, (2) number of column captions
   CColumnCaption   *GetColumnCaption(const uint index) { return this.m_list_captions.GetNodeAtIndex(index); }
   uint              ColumnsTotal(void) const { return this.m_list_captions.Total(); }

//--- Sets value for specified column caption
   void              ColumnCaptionSetValue(const uint index,const string value);

//--- (1) Sets, (2) returns datatype of specified column caption
   void              ColumnCaptionSetDatatype(const uint index,const ENUM_DATATYPE type);
   ENUM_DATATYPE     ColumnCaptionDatatype(const uint index);

//--- (1) Deletes (2) moves column caption
   bool              ColumnCaptionDelete(const uint index);
   bool              ColumnCaptionMoveTo(const uint caption_index,const uint index_to);

//--- Clears caption data
   void              ClearData(void);

//--- Clears caption list
   void              Destroy(void) { this.m_list_captions.Clear(); }

//--- (1) Returns, (2) prints object description
   virtual string    Description(void);
   void              Print(const bool detail,const bool as_table=false,const int column_width=CELL_WIDTH_IN_CHARS);

//--- Virtual methods
   virtual int       Compare(const CObject *node,const int mode=0) const { return -1; }
   virtual bool      Save(const int file_handle);
   virtual bool      Load(const int file_handle);
   virtual int       Type(void) const { return(OBJECT_TYPE_TABLE_HEADER); }

//--- Constructors / destructor
                     CTableHeader(void) {}
                     CTableHeader(string &array[]) { this.CreateHeader(array); }
                    ~CTableHeader(void){}
  };
  //+------------------------------------------------------------------+
//| Creates a new caption and adds it to the end of the list         |
//+------------------------------------------------------------------+
CColumnCaption *CTableHeader::CreateNewColumnCaption(const string caption)
  {
//--- Create a new caption object
   CColumnCaption *caption_obj=new CColumnCaption(this.ColumnsTotal(),caption);
   if(caption_obj==NULL)
     {
      ::PrintFormat("%s: Error. Failed to create new column caption at position %u",__FUNCTION__, this.ColumnsTotal());
      return NULL;
     }
//--- Add the created caption to the end of the list
   if(!this.AddNewColumnCaption(caption_obj))
     {
      delete caption_obj;
      return NULL;
     }
//--- Return pointer to the object
   return caption_obj;
  }
//+------------------------------------------------------------------+
//| Adds a caption to the end of the list                            |
//+------------------------------------------------------------------+
bool CTableHeader::AddNewColumnCaption(CColumnCaption *caption)
  {
//--- If an empty object is passed - report and return false
   if(caption==NULL)
     {
      ::PrintFormat("%s: Error. Empty CColumnCaption object passed",__FUNCTION__);
      return false;
     }
//--- Set the caption index in the list and add the created caption to the end of the list
   caption.SetColumn(this.ColumnsTotal());
   if(this.m_list_captions.Add(caption)==WRONG_VALUE)
     {
      ::PrintFormat("%s: Error. Failed to add caption (%u) to list",__FUNCTION__,this.ColumnsTotal());
      return false;
     }
//--- Success
   return true;
  }
//+------------------------------------------------------------------+
//| Creates a table header from a string array                       |
//+------------------------------------------------------------------+
void CTableHeader::CreateHeader(string &array[])
  {
//--- Get the number of table columns from array properties
   uint total=array.Size();
//--- In a loop by array size
//--- create all captions, adding each new one to the end of the list
   for(uint i=0; i<total; i++)
      this.CreateNewColumnCaption(array[i]);
  }
//+------------------------------------------------------------------+
//| Sets the value in the specified column caption                   |
//+------------------------------------------------------------------+
void CTableHeader::ColumnCaptionSetValue(const uint index,const string value)
  {
//--- Get the required caption from the list and write a new value to it
   CColumnCaption *caption=this.GetColumnCaption(index);
   if(caption!=NULL)
      caption.SetValue(value);
  }
//+------------------------------------------------------------------+
//| Sets the data type for the specified column caption               |
//+------------------------------------------------------------------+
void CTableHeader::ColumnCaptionSetDatatype(const uint index,const ENUM_DATATYPE type)
  {
//--- Get the required caption from the list and write a new value to it
   CColumnCaption *caption=this.GetColumnCaption(index);
   if(caption!=NULL)
      caption.SetDatatype(type);
  }
//+------------------------------------------------------------------+
//| Returns the data type of the specified column caption            |
//+------------------------------------------------------------------+
ENUM_DATATYPE CTableHeader::ColumnCaptionDatatype(const uint index)
  {
//--- Get the required caption from the list and return the column data type from it
   CColumnCaption *caption=this.GetColumnCaption(index);
   return(caption!=NULL ? caption.Datatype() : (ENUM_DATATYPE)WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| Deletes the specified column caption                             |
//+------------------------------------------------------------------+
bool CTableHeader::ColumnCaptionDelete(const uint index)
  {
//--- Delete the caption in the list by index
   if(!this.m_list_captions.Delete(index))
      return false;
//--- Update indices for the remaining captions in the list
   this.ColumnPositionUpdate();
   return true;
  }
//+------------------------------------------------------------------+
//| Moves the column caption to the specified position               |
//+------------------------------------------------------------------+
bool CTableHeader::ColumnCaptionMoveTo(const uint caption_index,const uint index_to)
  {
//--- Get the required caption by index in the list, making it the current one
   CColumnCaption *caption=this.GetColumnCaption(caption_index);
//--- Move the current caption to the specified position in the list
   if(caption==NULL || !this.m_list_captions.MoveToIndex(index_to))
      return false;
//--- Update indices of all captions in the list
   this.ColumnPositionUpdate();
   return true;
  }
//+------------------------------------------------------------------+
//| Sets the column position for all captions                        |
//+------------------------------------------------------------------+
void CTableHeader::ColumnPositionUpdate(void)
  {
//--- In a loop through all captions in the list
   for(int i=0;i<this.m_list_captions.Total();i++)
     {
      //--- get the next caption and set the column index in it
      CColumnCaption *caption=this.GetColumnCaption(i);
      if(caption!=NULL)
         caption.SetColumn(this.m_list_captions.IndexOf(caption));
     }
  }
//+------------------------------------------------------------------+
//| Clears data of column captions in the list                       |
//+------------------------------------------------------------------+
void CTableHeader::ClearData(void)
  {
//--- In a loop through all captions in the list
   for(uint i=0;i<this.ColumnsTotal();i++)
     {
      //--- get the next caption and set an empty value in it
      CColumnCaption *caption=this.GetColumnCaption(i);
      if(caption!=NULL)
         caption.ClearData();
     }
  }
//+------------------------------------------------------------------+
//| Returns object description                                       |
//+------------------------------------------------------------------+
string CTableHeader::Description(void)
  {
   return(::StringFormat("%s: Captions total: %u",
                         TypeDescription((ENUM_OBJECT_TYPE)this.Type()),this.ColumnsTotal()));
  }
//+------------------------------------------------------------------+
//| Logs the object description                                      |
//+------------------------------------------------------------------+
void CTableHeader::Print(const bool detail, const bool as_table=false, const int column_width=CELL_WIDTH_IN_CHARS)
  {
//--- Number of captions
   int total=(int)this.ColumnsTotal();
   
//--- If output is in tabular form
   string res="";
   if(as_table)
     {
      //--- create a table row from the values of all captions
      res="|";
      for(int i=0;i<total;i++)
        {
         CColumnCaption *caption=this.GetColumnCaption(i);
         if(caption==NULL)
            continue;
         res+=::StringFormat("%*s |",column_width,caption.Value());
        }
      //--- Print the row to the log and exit
      ::Print(res);
      return;
     }
     
//--- Print the header as a row description
   ::Print(this.Description()+(detail ? ":" : ""));
   
//--- If detailed description
   if(detail)
     {
      //--- In a loop through the row caption list
      for(int i=0; i<total; i++)
        {
         //--- get the current caption and add its description to the resulting string
         CColumnCaption *caption=this.GetColumnCaption(i);
         if(caption!=NULL)
            res+="  "+caption.Description()+(i<total-1 ? "\n" : "");
        }
      //--- Print the string created in the loop to the log
      ::Print(res);
     }
  }
//+------------------------------------------------------------------+
//| Saving to a file                                                 |
//+------------------------------------------------------------------+
bool CTableHeader::Save(const int file_handle)
  {
//--- Check the handle
   if(file_handle==INVALID_HANDLE)
      return(false);
//--- Save the start of data marker - 0xFFFFFFFFFFFFFFFF
   if(::FileWriteLong(file_handle,MARKER_START_DATA)!=sizeof(long))
      return(false);
//--- Save the object type
   if(::FileWriteInteger(file_handle,this.Type(),INT_VALUE)!=INT_VALUE)
      return(false);

//--- Save the caption list
   if(!this.m_list_captions.Save(file_handle))
      return(false);
   
//--- Success
   return true;
  }
//+------------------------------------------------------------------+
//| Loading from a file                                              |
//+------------------------------------------------------------------+
bool CTableHeader::Load(const int file_handle)
  {
//--- Check the handle
   if(file_handle==INVALID_HANDLE)
      return(false);
//--- Load and check the start of data marker - 0xFFFFFFFFFFFFFFFF
   if(::FileReadLong(file_handle)!=MARKER_START_DATA)
      return(false);
//--- Load the object type
   if(::FileReadInteger(file_handle,INT_VALUE)!=this.Type())
      return(false);

//--- Load the caption list
   if(!this.m_list_captions.Load(file_handle))
      return(false);
   
//--- Success
   return true;
  }
  #endif //TABLEHEADER_MQH