//+------------------------------------------------------------------+
//|                                               CommonManager.mqh  |
//+------------------------------------------------------------------+
//|                   Tables in the MVC Paradigm in MQL5             |
//|                Customizable and sortable table columns           |
//|                           https://www.mql5.com/en/articles/19979 |
//+------------------------------------------------------------------+

#ifndef __COMMONMANAGER_MQH__
#define __COMMONMANAGER_MQH__

//+------------------------------------------------------------------+
//|Include Custome library                                           |
//+------------------------------------------------------------------+
#include "BaseEnums.mqh"
//+------------------------------------------------------------------+
//| Singleton class for common flags and GUI element events          |
//+------------------------------------------------------------------+
class CCommonManager
  {
private:
   static CCommonManager *m_instance;          // Class instance
   string            m_element_name;           // Active element name
   int               m_cursor_x;               // Cursor X coordinate
   int               m_cursor_y;               // Cursor Y coordinate
   bool              m_resize_mode;            // Resize mode
   ENUM_CURSOR_REGION m_resize_region;         // Edge used for resizing
   
//--- Constructor / destructor
                     CCommonManager(void) : m_element_name("") {}
                    ~CCommonManager() {}

public:

//--- Method to get Singleton instance
   static CCommonManager *GetInstance(void)
                       {
                        if(m_instance==NULL)
                           m_instance=new CCommonManager();
                        return m_instance;
                       }

//--- Method to destroy Singleton instance
   static void       DestroyInstance(void)
                       {
                        if(m_instance!=NULL)
                          {
                           delete m_instance;
                           m_instance=NULL;
                          }
                       }

//--- (1) Set, (2) return active element name
   void              SetElementName(const string name)            { this.m_element_name=name;   }
   string            ElementName(void)                      const { return this.m_element_name; }

//--- (1) Set, (2) return cursor X coordinate
   void              SetCursorX(const int x)                      { this.m_cursor_x=x;          }
   int               CursorX(void)                          const { return this.m_cursor_x;     }

//--- (1) Set, (2) return cursor Y coordinate
   void              SetCursorY(const int y)                      { this.m_cursor_y=y;          }
   int               CursorY(void)                          const { return this.m_cursor_y;     }

//--- (1) Set, (2) return resize mode
   void              SetResizeMode(const bool flag)               { this.m_resize_mode=flag;    }
   bool              ResizeMode(void)                       const { return this.m_resize_mode;  }

//--- (1) Set, (2) return resize edge
   void              SetResizeRegion(const ENUM_CURSOR_REGION edge){ this.m_resize_region=edge; }
   ENUM_CURSOR_REGION ResizeRegion(void)                    const { return this.m_resize_region;}

  };

//--- Static instance initialization
CCommonManager* CCommonManager::m_instance=NULL;

#endif