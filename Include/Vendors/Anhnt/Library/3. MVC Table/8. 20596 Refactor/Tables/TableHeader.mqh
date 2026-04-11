//+------------------------------------------------------------------+
//|                                                TableHeader.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//| First See in             https://www.mql5.com/en/articles/17653  |
//| Current                   https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| Table header class                                               |
//+------------------------------------------------------------------+
#ifndef __TABLEHEADER_MQH__
#define __TABLEHEADER_MQH__ 
   //+------------------------------------------------------------------+
   //| Included Standard Libraries                                      |
   //+------------------------------------------------------------------+
   #include <Arrays\List.mqh>
   //+------------------------------------------------------------------+
   //| Included Custome Libraries                                       |
   //+------------------------------------------------------------------+

   #include "..\Defines\TableDefines.mqh"
   #include "..\Defines\TableEnums.mqh"
   #include "..\Base\BaseObj.mqh"
   #include "ColumnCaption.mqh"  
   class CTableHeader : public CObject
   {
      protected:
         CColumnCaption    m_caption_tmp;                         // Column header object to search in list
         CListObj          m_list_captions;                       // List of column headers
         
      // --- Adds the specified header to the end of the list
         bool              AddNewColumnCaption(CColumnCaption *caption);
      // --- Creates a table header from a string array
         void              CreateHeader(string &array[]);
      // --- Sets the column position of all column headers
         void              ColumnPositionUpdate(void);
         
      public:
      // --- Creates a new title and adds it to the end of the list
         CColumnCaption   *CreateNewColumnCaption(const string caption);
         
      // --- Returns (1) the header by index, (2) the number of column headers
         CColumnCaption   *GetColumnCaption(const uint index)        { return this.m_list_captions.GetNodeAtIndex(index);  }
         uint              ColumnsTotal(void)                  const { return this.m_list_captions.Total();                }
         
      // --- Sets the value of the specified column header
         void              ColumnCaptionSetValue(const uint index,const string value);
         
      // --- (1) Sets, (2) returns the data type for the specified column header
         void              ColumnCaptionSetDatatype(const uint index,const ENUM_DATATYPE type);
         ENUM_DATATYPE     ColumnCaptionDatatype(const uint index);
         
      // --- (1) Removes (2) moves the column header
         bool              ColumnCaptionDelete(const uint index);
         bool              ColumnCaptionMoveTo(const uint caption_index, const uint index_to);
         
      // --- Clears column header data
         void              ClearData(void);

      // --- Clears the list of column headers
         void              Destroy(void)                             { this.m_list_captions.Clear();                       }

      // --- (1) Returns, (2) logs a description of the object
         virtual string    Description(void);
         void              Print(const bool detail, const bool as_table=false, const int column_width=CELL_WIDTH_IN_CHARS);

      // --- Virtual methods (1) compare, (2) save to file, (3) load from file, (4) object type
         virtual int       Compare(const CObject *node,const int mode=0)   const { return -1;            }
         virtual bool      Save(const int file_handle);
         virtual bool      Load(const int file_handle);
         virtual int       Type(void)                          const { return(OBJECT_TYPE_TABLE_HEADER); }
         
      // --- Constructors/destructor
                           CTableHeader(void) {}
                           CTableHeader(string &array[]) { this.CreateHeader(array);   }
                        ~CTableHeader(void){}
   };
   //+------------------------------------------------------------------+
   //| Creates a new title and adds it to the end of the list           |
   //+------------------------------------------------------------------+
   CColumnCaption *CTableHeader::CreateNewColumnCaption(const string caption)
   {
      // --- Create a new header object
         CColumnCaption *caption_obj=new CColumnCaption(this.ColumnsTotal(),caption);
         if(caption_obj==NULL)
         {
            ::PrintFormat("%s: Error. Failed to create new column caption at position %u",__FUNCTION__, this.ColumnsTotal());
            return NULL;
         }
      // --- Add the created title to the end of the list
         if(!this.AddNewColumnCaption(caption_obj))
         {
            delete caption_obj;
            return NULL;
         }
      // --- Return a pointer to the object
         return caption_obj;
   }
   //+------------------------------------------------------------------+
   //| Adds a title to the end of the list                              |
   //+------------------------------------------------------------------+
   bool CTableHeader::AddNewColumnCaption(CColumnCaption *caption)
   {
      // --- If an empty object is passed, we report and return false
         if(caption==NULL)
         {
            ::PrintFormat("%s: Error. Empty CColumnCaption object passed",__FUNCTION__);
            return false;
         }
      // --- Set the title index in the list and add the created title to the end of the list
         caption.SetColumn(this.ColumnsTotal());
         if(this.m_list_captions.Add(caption)==WRONG_VALUE)
         {
            ::PrintFormat("%s: Error. Failed to add caption (%u) to list",__FUNCTION__,this.ColumnsTotal());
            return false;
         }
      // --- Successfully
         return true;
   }
   //+------------------------------------------------------------------+
   //| Creates a table header from a string array                       |
   //+------------------------------------------------------------------+
   void CTableHeader::CreateHeader(string &array[])
   {
      // --- Get the number of table columns from the array properties
         uint total=array.Size();
      // --- Looping through the array size
      // --- create all the headers, adding each new one to the end of the list
         for(uint i=0; i<total; i++)
            this.CreateNewColumnCaption(array[i]);
   }
   //+------------------------------------------------------------------+
   //| Sets the value to the specified column header                    |
   //+------------------------------------------------------------------+
   void CTableHeader::ColumnCaptionSetValue(const uint index,const string value)
   {
      // --- We get the desired header from the list and write a new value into it
      CColumnCaption *caption=this.GetColumnCaption(index);
      if(caption!=NULL)
         caption.SetValue(value);
   }
   //+------------------------------------------------------------------+
   //| Sets the data type for the specified column header               |
   //+------------------------------------------------------------------+
   void CTableHeader::ColumnCaptionSetDatatype(const uint index,const ENUM_DATATYPE type)
   {
      // --- We get the desired header from the list and write a new value into it
      CColumnCaption *caption=this.GetColumnCaption(index);
      if(caption!=NULL)
         caption.SetDatatype(type);
   }
   //+------------------------------------------------------------------+
   //| Returns the data type of the specified column header             |
   //+------------------------------------------------------------------+
   ENUM_DATATYPE CTableHeader::ColumnCaptionDatatype(const uint index)
   {
      // --- We get the desired header from the list and return the column data type from it
      CColumnCaption *caption=this.GetColumnCaption(index);
      return(caption!=NULL ? caption.Datatype() : (ENUM_DATATYPE)WRONG_VALUE);
   }
   //+------------------------------------------------------------------+
   //| Removes the header of the specified column                       |
   //+------------------------------------------------------------------+
   bool CTableHeader::ColumnCaptionDelete(const uint index)
   {
      // --- Delete a title in the list by index
         if(!this.m_list_captions.Delete(index))
            return false;
      // --- Update the indexes for the remaining titles in the list
         this.ColumnPositionUpdate();
         return true;
   }
   //+------------------------------------------------------------------+
   //| Moves the column header to the specified position                |
   //+------------------------------------------------------------------+
   bool CTableHeader::ColumnCaptionMoveTo(const uint caption_index,const uint index_to)
   {
      // --- Get the desired title by index in the list, making it current
         CColumnCaption *caption=this.GetColumnCaption(caption_index);
      // --- Move the current title to the specified position in the list
         if(caption==NULL || !this.m_list_captions.MoveToIndex(index_to))
            return false;
      // --- Update the indexes of all titles in the list
         this.ColumnPositionUpdate();
         return true;
   }
   //+------------------------------------------------------------------+
   //| Sets column positions for all headers                            |
   //+------------------------------------------------------------------+
   void CTableHeader::ColumnPositionUpdate(void)
   {
      // --- Loop through all titles in the list
      for(int i=0;i<this.m_list_captions.Total();i++)
      {
         // --- get the next header and set the column index to it
         CColumnCaption *caption=this.GetColumnCaption(i);
         if(caption!=NULL)
            caption.SetColumn(this.m_list_captions.IndexOf(caption));
      }
   }
   //+------------------------------------------------------------------+
   //| Clears column header data in a list                              |
   //+------------------------------------------------------------------+
   void CTableHeader::ClearData(void)
   {
      // --- Loop through all titles in the list
      for(uint i=0;i<this.ColumnsTotal();i++)
      {
         // --- get the next header and set it to an empty value
         CColumnCaption *caption=this.GetColumnCaption(i);
         if(caption!=NULL)
            caption.ClearData();
      }
   }
   //+------------------------------------------------------------------+
   //| Returns the description of the object                            |
   //+------------------------------------------------------------------+
   string CTableHeader::Description(void)
   {
      // --- Get the formatted object type from the static helper
      string typeStr = CBaseObj::FormatObjectType((ENUM_OBJECT_TYPE)this.Type());
   
      // --- Return the row description including index and count of cells
      return ::StringFormat("%s: Captions total: %u", 
                            typeStr, this.ColumnsTotal());
      // return(::StringFormat("%s: Captions total: %u",
      //                      TypeDescription((ENUM_OBJECT_TYPE)this.Type()),this.ColumnsTotal()));
   }
   //+------------------------------------------------------------------+
   //| Logs a description of an object                                  |
   //+------------------------------------------------------------------+
   void CTableHeader::Print(const bool detail, const bool as_table=false, const int column_width=CELL_WIDTH_IN_CHARS)
   {
      // --- Number of titles
         int total=(int)this.ColumnsTotal();
         
      // --- If the output is in tabular form
         string res="";
         if(as_table)
         {
            // --- create a table row from the values ​​of all headers
            res="|";
            for(int i=0;i<total;i++)
            {
               CColumnCaption *caption=this.GetColumnCaption(i);
               if(caption==NULL)
                  continue;
               res+=::StringFormat("%*s |",column_width,caption.Value());
            }
            // --- We output the line to the log and leave
            ::Print(res);
            return;
         }
         
      // --- Output the title as a line description
         ::Print(this.Description()+(detail ? ":" : ""));
         
      // --- If detailed description
         if(detail)
         {
            // --- In a loop through the list of row headers
            for(int i=0; i<total; i++)
            {
               // --- get the current title and add its description to the final line
               CColumnCaption *caption=this.GetColumnCaption(i);
               if(caption!=NULL)
                  res+="  "+caption.Description()+(i<total-1 ? "\n" : "");
            }
            // --- Log the line created in the loop
            ::Print(res);
         }
   }
   //+------------------------------------------------------------------+
   //| Saving to file                                                   |
   //+------------------------------------------------------------------+
   bool CTableHeader::Save(const int file_handle)
   {
      // --- Checking the handle
         if(file_handle==INVALID_HANDLE)
            return(false);
      // --- Save the data start marker - 0xFFFFFFFFFFFFFFFF
         if(::FileWriteLong(file_handle,MARKER_START_DATA)!=sizeof(long))
            return(false);
      // --- Save the object type
         if(::FileWriteInteger(file_handle,this.Type(),INT_VALUE)!=INT_VALUE)
            return(false);

      // --- Save the list of titles
         if(!this.m_list_captions.Save(file_handle))
            return(false);
         
      // --- Successfully
         return true;
   }
   //+------------------------------------------------------------------+
   //| Loading from file                                                |
   //+------------------------------------------------------------------+
   bool CTableHeader::Load(const int file_handle)
   {
      // --- Checking the handle
         if(file_handle==INVALID_HANDLE)
            return(false);
      // --- Load and check the data start marker - 0xFFFFFFFFFFFFFFFF
         if(::FileReadLong(file_handle)!=MARKER_START_DATA)
            return(false);
      // --- Loading the object type
         if(::FileReadInteger(file_handle,INT_VALUE)!=this.Type())
            return(false);

      // --- Loading the list of titles
         if(!this.m_list_captions.Load(file_handle))
            return(false);
         
      // --- Successfully
         return true;
   }
   //+------------------------------------------------------------------+
#endif // __TABLEHEADER_MQH__


