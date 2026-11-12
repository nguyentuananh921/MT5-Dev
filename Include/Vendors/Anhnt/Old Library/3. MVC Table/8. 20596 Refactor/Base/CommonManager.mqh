//+------------------------------------------------------------------+
//|                                              CommonManager.mqh   |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//| MVC Paradigm in MQL5                                             |
//| First See in   Containers                                        |
//|                           https://www.mql5.com/en/articles/18658 |
//| Update in      Resizable elements                                |
//|                           https://www.mql5.com/en/articles/18941 |
//| Current                   https://www.mql5.com/ru/articles/20596 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
// | Singleton class for common flags and events of graphic elements |
//+------------------------------------------------------------------+
#ifndef __CCOMMONMANAGER_MQH__
#define __CCOMMONMANAGER_MQH__
   //+------------------------------------------------------------------+
   //| Included Standard Libraries                                      |
   //+------------------------------------------------------------------+
   #include <Arrays\List.mqh>
   //+------------------------------------------------------------------+
   //| Included Custome Libraries                                       |
   //+------------------------------------------------------------------+
   #include "..\Defines\BaseDefines.mqh"
   #include "..\Defines\BaseEnums.mqh"   
 class CCommonManager
  {
   private:
      static CCommonManager *m_instance;                          // Class Instance
      string            m_element_name;                           // Active element name
    //| Update in: Resizable elements                                    |
    //|                           https://www.mql5.com/en/articles/18941 |
      int               m_cursor_x;                               // X coordinate of cursor
      int               m_cursor_y;                               // Cursor Y coordinate
      bool              m_resize_mode;                            // Resizing mode
      ENUM_CURSOR_REGION m_resize_region;                         // The edge of the element beyond which to resize
      
   // --- Constructor/destructor
                     CCommonManager(void) : m_element_name("") {}
                     ~CCommonManager() {}
   public:
   // --- Method to get a Singleton instance
      static CCommonManager *GetInstance(void)
                        {
                           if(m_instance==NULL)
                              m_instance=new CCommonManager();
                           return m_instance;
                        }
   // --- Method for destroying a Singleton instance
      static void       DestroyInstance(void)
                        {
                           if(m_instance!=NULL)
                           {
                              delete m_instance;
                              m_instance=NULL;
                           }
                        }
   // --- (1) Sets, (2) returns the name of the active current element
      void              SetElementName(const string name)            { this.m_element_name=name;   }
      string            ElementName(void)                      const { return this.m_element_name; }
      
   // --- (1) Sets, (2) returns the X coordinate of the cursor
      void              SetCursorX(const int x)                      { this.m_cursor_x=x;          }
      int               CursorX(void)                          const { return this.m_cursor_x;     }
      
   // --- (1) Sets, (2) returns the Y coordinate of the cursor
      void              SetCursorY(const int y)                      { this.m_cursor_y=y;          }
      int               CursorY(void)                          const { return this.m_cursor_y;     }
   //| Update in: Resizable elements                                    |
   //|                           https://www.mql5.com/en/articles/18941 |   
      // --- (1) Sets, (2) returns resizing mode
         void              SetResizeMode(const bool flag)               { this.m_resize_mode=flag;    }
         bool              ResizeMode(void)                       const { return this.m_resize_mode;  }
         
      // --- (1) Sets, (2) returns the element's face
         void              SetResizeRegion(const ENUM_CURSOR_REGION edge){ this.m_resize_region=edge; }
         ENUM_CURSOR_REGION ResizeRegion(void)                    const { return this.m_resize_region;}

  };
 #ifndef CCOMMONMANAGER_IMPLEMENTATION
 #define CCOMMONMANAGER_IMPLEMENTATION
   // ---Initializing a static class instance variable
   CCommonManager* CCommonManager::m_instance=NULL;
 #endif // CCOMMONMANAGER_IMPLEMENTATION
#endif // __CCOMMONMANAGER_MQH__

