//+------------------------------------------------------------------+
//|                                                    ListElm.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//|                                                                  |
//|                           https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| Linked List of Graphics Class                                    |
//+------------------------------------------------------------------+
#ifndef __LISTELM_MQH__
#define __LISTELM_MQH__
   //+------------------------------------------------------------------+
   //| Included Standard Libraries                                      |
   //+------------------------------------------------------------------+
   #include <Arrays\List.mqh>
   //+------------------------------------------------------------------+
   //| Included Custome Libraries                                       |
   //+------------------------------------------------------------------+
   #include "..\Defines\ControlsDefines.mqh"
   #include "..\Defines\ControlsEnums.mqh"
 class CListElm : public CList
  {
   protected:
      ENUM_ELEMENT_TYPE m_element_type;   // The type of the object being created in CreateElement()
   public:
   // --- Setting element type
      void              SetElementType(const ENUM_ELEMENT_TYPE type) { this.m_element_type=type;   }
      
   // --- Virtual method (1) loading a list from a file, (2) creating a list element
      virtual bool      Load(const int file_handle);
      virtual CObject  *CreateElement(void);
  };
 #ifndef CLISTELM_IMPLEMENTATION
 #define CLISTELM_IMPLEMENTATION
   //+------------------------------------------------------------------+
   //| Loading a list from a file |
   //+------------------------------------------------------------------+
  bool CListElm::Load(const int file_handle)
   {
      // --- Variables
         CObject *node;
         bool     result=true;
      // --- Checking the handle
         if(file_handle==INVALID_HANDLE)
            return(false);
      // --- Loading and checking the list start marker - 0xFFFFFFFFFFFFFFFF
         if(::FileReadLong(file_handle)!=MARKER_START_DATA)
            return(false);
      // --- Loading and checking list type
         if(::FileReadInteger(file_handle,INT_VALUE)!=this.Type())
            return(false);
      // --- Read list size (number of objects)
         uint num=::FileReadInteger(file_handle,INT_VALUE);
         
      // --- We sequentially re-create the list elements by calling the Load() method of node objects
         this.Clear();
         for(uint i=0; i<num; i++)
         {
            // --- Read and check the object data start marker - 0xFFFFFFFFFFFFFFFF
            if(::FileReadLong(file_handle)!=MARKER_START_DATA)
               return false;
            // --- Read the object type
            this.m_element_type=(ENUM_ELEMENT_TYPE)::FileReadInteger(file_handle,INT_VALUE);
            node=this.CreateElement();
            if(node==NULL)
               return false;
            this.Add(node);
            // --- Now the file pointer is offset relative to the beginning of the object marker by 12 bytes (8 - marker, 4 - type)
            // --- Let's place a pointer to the beginning of the object's data and load the object's properties from the file using the Load() method of the node element.
            if(!::FileSeek(file_handle,-12,SEEK_CUR))
               return false;
            result &=node.Load(file_handle);
         }
      // --- Result
         return result;
   }
 #endif // CLISTELM_IMPLEMENTATION   
#endif // __LISTELM_MQH__
