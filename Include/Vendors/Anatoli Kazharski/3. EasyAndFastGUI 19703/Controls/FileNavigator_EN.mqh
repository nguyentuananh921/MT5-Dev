//+------------------------------------------------------------------+
//|                                                FileNavigator.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\Element.mqh"
#include "TreeView.mqh"
//+------------------------------------------------------------------+
// | Class for creating a file navigator |
//+------------------------------------------------------------------+
class CFileNavigator : public CElement
  {
private:
   // --- Objects for creating an element
   CTreeView         m_treeview;
   // --- Basic data storage arrays
   int               m_g_list_index[];           // general index
   int               m_g_prev_node_list_index[]; // general index of the previous node
   string            m_g_item_text[];            // folder/file name
   int               m_g_item_index[];           // local index
   int               m_g_node_level[];           // node level
   int               m_g_prev_node_item_index[]; // local index of the previous node
   int               m_g_items_total[];          // total items in the folder
   int               m_g_folders_total[];        // number of folders in a folder
   bool              m_g_is_folder[];            // folder sign
   bool              m_g_item_state[];           // item status (collapsed/opened)
   // --- Auxiliary arrays for data collection
   int               m_l_prev_node_list_index[];
   string            m_l_item_text[];
   string            m_l_path[];
   int               m_l_item_index[];
   int               m_l_item_total[];
   int               m_l_folders_total[];
   // --- Tree list area width
   int               m_treeview_width;
   // --- Pictures for (1) folders and (2) files
   string            m_file_icon;
   string            m_folder_icon;
   // --- Current path relative to the terminal file sandbox
   string            m_current_path;
   // --- Current full path relative to the file system including the hard disk volume label
   string            m_current_full_path;
   // --- Current directory area
   int               m_directory_area;
   // --- File navigator content mode
   ENUM_FILE_NAVIGATOR_CONTENT m_navigator_content;
   //---
public:
                     CFileNavigator(void);
                    ~CFileNavigator(void);
   // --- Methods for creating a file navigator
   bool              CreateFileNavigator(const int x_gap,const int y_gap);
   //---
private:
   void              InitializeProperties(const int x_gap,const int y_gap);
   bool              CreateCanvas(void);
   bool              CreateTreeView(void);
   //---
public:
   // --- (1) Returns a tree list pointer,
   // (2) navigator mode (Show all/Folders only), (3) navigator content (Shared folder/Local/All)
   CTreeView        *GetTreeViewPointer(void)                                 { return(::GetPointer(m_treeview));          }
   void              NavigatorMode(const ENUM_FILE_NAVIGATOR_MODE mode)       { m_treeview.NavigatorMode(mode);            }
   void              NavigatorContent(const ENUM_FILE_NAVIGATOR_CONTENT mode) { m_navigator_content=mode;                  }
   // --- (1) width of the tree list, (2) setting the file path for files and folders
   void              TreeViewWidth(const int x_size)                          { m_treeview_width=x_size;                   }
   void              FileIcon(const string file_path)                         { m_file_icon=file_path;                     }
   void              FolderIcon(const string file_path)                       { m_folder_icon=file_path;                   }
   // --- Returns (1) the current path and (2) the full path, (3) the selected file
   string            CurrentPath(void)                                  const { return(m_current_path);                    }
   string            CurrentFullPath(void)                              const { return(m_current_full_path);               }
   // --- Returns (1) the directory area and (2) the selected file
   int               DirectoryArea(void)                                const { return(m_directory_area);                  }
   string            SelectedFile(void)                                 const { return(m_treeview.SelectedItemFileName()); }
   //---
public:
   // ---Graph event handler
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   // --- Management
   virtual void      Delete(void);
   // --- Draws an element
   virtual void      Draw(void);
   //---
private:
   // --- Handling the event of selecting a new path in the tree list
   void              OnChangeTreePath(void);

   //--- Заполняет массивы параметрами элементов файловой системы терминала
   void              FillArraysData(void);
   // --- Reads the file system and writes parameters to arrays
   void              FileSystemScan(const int root_index,int &list_index,int &node_level,int &item_index,int search_area);
   // --- Resizes auxiliary arrays relative to the current node level
   void              AuxiliaryArraysResize(const int node_level);
   // --- Determines whether the folder or file name is passed
   bool              IsFolder(const string file_name);
   // --- Returns the number of (1) items and (2) folders in the specified directory
   int               ItemsTotal(const string search_path,const int mode);
   int               FoldersTotal(const string search_path,const int mode);
   // --- Returns the local index of the previous node relative to the passed parameters
   int               PrevNodeItemIndex(const int root_index,const int node_level);

   // --- Adds an item to arrays
   void              AddItem(const int list_index,const string item_text,const int node_level,const int prev_node_item_index,
                             const int item_index,const int items_total,const int folders_total,const bool is_folder);
   //--- Переход на следующий узел
   void              ToNextNode(const int root_index,int list_index,int &node_level,
                                int &item_index,long &handle,const string item_text,const int search_area);

   virtual void      DrawText(void);

   // --- Change the width along the right edge of the window
   virtual void      ChangeWidthByRightWindowSide(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CFileNavigator::CFileNavigator(void) : m_current_path(""),
                                       m_current_full_path(""),
                                       m_treeview_width(200),
                                       m_directory_area(FILE_COMMON),
                                       m_navigator_content(FN_ONLY_MQL),
                                       m_file_icon("Images\\EasyAndFastGUI\\Icons\\bmp16\\text_file_w10.bmp"),
                                       m_folder_icon("Images\\EasyAndFastGUI\\Icons\\bmp16\\folder_w10.bmp")
  {
// --- Save the element class name in the base class
   CElementBase::ClassName(CLASS_NAME);
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CFileNavigator::~CFileNavigator(void)
  {
  }
//+------------------------------------------------------------------+
// | Event Handler |
//+------------------------------------------------------------------+
void CFileNavigator::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
// --- Handling the event "Change path in the tree list"
   if(id==CHARTEVENT_CUSTOM+ON_CHANGE_TREE_PATH)
     {
      OnChangeTreePath();
      // --- Display the current path in the address bar
      Update(true);
      return;
     }
  }
//+------------------------------------------------------------------+
// | Creates a file navigator |
//+------------------------------------------------------------------+
bool CFileNavigator::CreateFileNavigator(const int x_gap,const int y_gap)
  {
// --- Quit if there is no pointer to the main element
   if(!CElement::CheckMainPointer())
      return(false);
//--- Сканируем файловую систему терминала и заносим данные в массивы
   FillArraysData();
// --- Initializing properties
   InitializeProperties(x_gap,y_gap);
// ---Creating an element
   if(!CreateTreeView())
      return(false);
   if(!CreateCanvas())
      return(false);
// --- Display the current path in the address bar
   OnChangeTreePath();
   return(true);
  }
//+------------------------------------------------------------------+
// | Initializing properties |
//+------------------------------------------------------------------+
void CFileNavigator::InitializeProperties(const int x_gap,const int y_gap)
  {
   m_x        =CElement::CalculateX(x_gap);
   m_y        =CElement::CalculateY(y_gap);
   m_x_size   =(m_x_size<1 || m_auto_xresize_mode)? m_main.X2()-CElementBase::X()-m_auto_xresize_right_offset : m_x_size;
   m_y_size   =(m_y_size<1)? 20 : m_y_size;
// ---Default colors
   m_border_color =(m_border_color!=clrNONE)? m_border_color : C'150,170,180';
   m_label_color  =(m_label_color!=clrNONE)? m_label_color : clrBlack;
// --- Indents from the extreme point
   CElementBase::XGap(x_gap);
   CElementBase::YGap(y_gap);
  }
//+------------------------------------------------------------------+
// | Creates an object to draw |
//+------------------------------------------------------------------+
bool CFileNavigator::CreateCanvas(void)
  {
// --- Formation of object name
   string name=CElementBase::ElementName("file_navigator");
// ---Create an object
   if(!CElement::CreateCanvas(name,m_x,m_y,m_treeview.XSize(),m_y_size))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
// | Creates a tree list |
//+------------------------------------------------------------------+
#resource "\\Icons\\bmp16\\folder_w10.bmp"
#resource "\\Icons\\bmp16\\text_file_w10.bmp"
//---
bool CFileNavigator::CreateTreeView(void)
  {
//--- Сохраним указатель на окно
   m_treeview.MainPointer(this);
// --- Coordinates
   int x=0,y=m_y_size-1;
// --- Properties
   m_treeview.XSize(m_x_size);
   m_treeview.TreeViewWidth(m_treeview_width);
   m_treeview.ResizeListMode(true);
   m_treeview.ShowItemContent(true);
   m_treeview.AutoXResizeMode(CElementBase::AutoXResizeMode());
   m_treeview.AutoXResizeRightOffset(0);
   m_treeview.AnchorRightWindowSide(CElementBase::AnchorRightWindowSide());
   m_treeview.AnchorBottomWindowSide(CElementBase::AnchorBottomWindowSide());
// --- Forming tree list arrays
   int items_total=::ArraySize(m_g_item_text);
   for(int i=0; i<items_total; i++)
     {
      // --- Define an image for the item (folder/file)
      string icon_path=(m_g_is_folder[i])? m_folder_icon : m_file_icon;
      // --- If this is a folder, remove the last character ('\') in the line
      if(m_g_is_folder[i])
         m_g_item_text[i]=::StringSubstr(m_g_item_text[i],0,::StringLen(m_g_item_text[i])-1);
      // --- Add an item to the tree list
      m_treeview.AddItem(i,m_g_prev_node_list_index[i],m_g_item_text[i],icon_path,m_g_item_index[i],
                         m_g_node_level[i],m_g_prev_node_item_index[i],m_g_items_total[i],m_g_folders_total[i],false,m_g_is_folder[i]);
     }
// --- Create tree list
   if(!m_treeview.CreateTreeView(x,y))
      return(false);
// --- Add element to array
   CElement::AddToArray(m_treeview);
   return(true);
  }
//+------------------------------------------------------------------+
// | Обработка события выбора нового пути в древовидном списке        |
//+------------------------------------------------------------------+
void CFileNavigator::OnChangeTreePath(void)
  {
// --- Get the current path
   string path=m_treeview.CurrentFullPath();
// --- If this is a shared terminal folder
   if(::StringFind(path,"Common\\Files\\",0)>-1)
     {
      // --- Get the address of the shared terminal folder
      string common_path=::TerminalInfoString(TERMINAL_COMMONDATA_PATH);
      // --- Remove the prefix "Common\" from the line (accepted in the event)
      path=::StringSubstr(path,7,::StringLen(common_path)-7);
      // --- Let's create a path (short and full version)
      m_current_path      =::StringSubstr(path,6,::StringLen(path)-6);
      m_current_full_path =common_path+"\\"+path;
      // --- Save the directory area
      m_directory_area=FILE_COMMON;
     }
//--- Если это локальная папка терминала
   else if(::StringFind(path,"MQL5\\Files\\",0)>-1)
     {
      //--- Получим адрес данных в локальной папке терминала
      string local_path=::TerminalInfoString(TERMINAL_DATA_PATH);
      // --- Let's create a path (short and full version)
      m_current_path      =::StringSubstr(path,11,::StringLen(path)-11);
      m_current_full_path =local_path+"\\"+path;
      // --- Save the directory area
      m_directory_area=0;
     }
  }
//+------------------------------------------------------------------+
// | Fills arrays with parameters of file system elements |
//+------------------------------------------------------------------+
void CFileNavigator::FillArraysData(void)
  {
// --- Counters of (1) general indexes, (2) node levels, (3) local indexes
   int list_index =0;
   int node_level =0;
   int item_index =0;
//--- Если нужно отображать обе директории (Общая (0)/Локальная (1))
   int begin=0,end=1;
//--- Если нужно отображать содержимое только локальной директории
   if(m_navigator_content==FN_ONLY_MQL)
      begin=1;
// --- If you want to display the contents of only the shared directory
   else if(m_navigator_content==FN_ONLY_COMMON)
      begin=end=0;
// --- Let's go through the specified directories
   for(int root_index=begin; root_index<=end; root_index++)
     {
      // --- Define a directory to scan the file structure
      int search_area=(root_index>0) ? 0 : FILE_COMMON;
      // --- Reset the local index counter
      item_index=0;
      //--- Увеличим размер массивов на один элемент (относительно уровня узла)
      AuxiliaryArraysResize(node_level);
      // --- Get the number of files and folders in the specified directory (* - check all files/folders)
      string search_path   =m_l_path[0]+"*";
      m_l_item_total[0]    =ItemsTotal(search_path,search_area);
      m_l_folders_total[0] =FoldersTotal(search_path,search_area);
      // --- Add an item with the name of the root directory to the beginning of the list
      string item_text=(root_index>0)? "MQL5\\Files\\" : "Common\\Files\\";
      AddItem(list_index,item_text,0,0,root_index,m_l_item_total[0],m_l_folders_total[0],true);
      //--- Увеличим счётчики общих индексов и уровней узлов
      list_index++;
      node_level++;
      // --- Increase the size of the arrays by one element (relative to the node level)
      AuxiliaryArraysResize(node_level);
      //--- Инициализация первых элементов для директории локальной папки терминала
      if(root_index>0)
        {
         m_l_item_index[0]           =root_index;
         m_l_prev_node_list_index[0] =list_index-1;
        }
      // --- Scan directories and enter data into arrays
      FileSystemScan(root_index,list_index,node_level,item_index,search_area);
     }
  }
//+------------------------------------------------------------------+
// | Reads the terminal file system and writes |
// | parameters of elements into arrays |
//+------------------------------------------------------------------+
void CFileNavigator::FileSystemScan(const int root_index,int &list_index,int &node_level,int &item_index,int search_area)
  {
   long   search_handle =INVALID_HANDLE; // Folder/file search handle
   string file_name     ="";             // Name of the found item (file/folder)
   string filter        ="*";            // Search filter (* - check all files/folders)
// --- Scan directories and enter data into arrays
   while(!::IsStopped())
     {
      // --- If this is the beginning of the directory list
      if(item_index==0)
        {
         // --- Path to search for all elements
         string search_path=m_l_path[node_level]+filter;
         // --- Get the handle and name of the first file
         search_handle=::FileFindFirst(search_path,file_name,search_area);
         // --- Get the number of files and folders in the specified directory
         m_l_item_total[node_level]    =ItemsTotal(search_path,search_area);
         m_l_folders_total[node_level] =FoldersTotal(search_path,search_area);
        }
      // --- If this node already had an index, move on to the next file
      if(m_l_item_index[node_level]>-1 && item_index<=m_l_item_index[node_level])
        {
         // --- Increase the local index counter
         item_index++;
         // --- Move to the next element
         ::FileFindNext(search_handle,file_name);
         continue;
        }
      // --- If we have reached the end of the list in the root node, we will end the loop
      if(node_level==1 && item_index>=m_l_item_total[node_level])
         break;
      //--- Если дошли до конца списка в любом узле, кроме корневого
      else if(item_index>=m_l_item_total[node_level])
        {
         // --- Move the node counter back one level
         node_level--;
         // --- Reset local index counter to zero
         item_index=0;
         // --- Close the search handle
         ::FileFindClose(search_handle);
         continue;
        }
      // ---If this is a folder
      if(IsFolder(file_name))
        {
         // --- Let's move on to the next node
         ToNextNode(root_index,list_index,node_level,item_index,search_handle,file_name,search_area);
         // --- Increment the total index counter and start a new iteration
         list_index++;
         continue;
        }
      // --- Get the local index of the previous node
      int prev_node_item_index=PrevNodeItemIndex(root_index,node_level);
      // --- Add an item with the specified data to the general arrays
      AddItem(list_index,file_name,node_level,prev_node_item_index,item_index,0,0,false);
      // --- Increase the counter of common indexes
      list_index++;
      // --- Increase the local index counter
      item_index++;
      //--- Переходим к следующему элементу
      ::FileFindNext(search_handle,file_name);
     }
// --- Close the search handle
   ::FileFindClose(search_handle);
  }
//+------------------------------------------------------------------+
// | Изменяет размер вспомогательных массивов                         |
// | relative to the current node level |
//+------------------------------------------------------------------+
void CFileNavigator::AuxiliaryArraysResize(const int node_level)
  {
// --- Resize arrays
   int new_size=node_level+1;
   ::ArrayResize(m_l_prev_node_list_index,new_size);
   ::ArrayResize(m_l_item_text,new_size);
   ::ArrayResize(m_l_path,new_size);
   ::ArrayResize(m_l_item_index,new_size);
   ::ArrayResize(m_l_item_total,new_size);
   ::ArrayResize(m_l_folders_total,new_size);
// --- Initialize last value
   m_l_prev_node_list_index[node_level] =0;
   m_l_item_text[node_level]            ="";
   m_l_path[node_level]                 ="";
   m_l_item_index[node_level]           =-1;
   m_l_item_total[node_level]           =0;
   m_l_folders_total[node_level]        =0;
  }
//+------------------------------------------------------------------+
// | Determines whether the folder or file name is passed |
//+------------------------------------------------------------------+
bool CFileNavigator::IsFolder(const string file_name)
  {
// --- If the name contains "\\" characters, then this is a folder
   if(::StringFind(file_name,"\\",0)>-1)
      return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
// | Counts the number of files in the current directory |
//+------------------------------------------------------------------+
int CFileNavigator::ItemsTotal(const string search_path,const int search_area)
  {
   int    counter       =0;              // element counter
   string file_name     ="";             // file name
   long   search_handle =INVALID_HANDLE; // search handle
// --- Get the first file in the current directory
   search_handle=::FileFindFirst(search_path,file_name,search_area);
// --- If the directory is not empty
   if(search_handle!=INVALID_HANDLE && file_name!="")
     {
      // --- Let's count the number of objects in the current directory
      counter++;
      while(::FileFindNext(search_handle,file_name))
         counter++;
     }
// --- Close the search handle
   ::FileFindClose(search_handle);
   return(counter);
  }
//+------------------------------------------------------------------+
// | Counts the number of folders in the current directory |
//+------------------------------------------------------------------+
int CFileNavigator::FoldersTotal(const string search_path,const int search_area)
  {
   int    counter       =0;              // element counter
   string file_name     ="";             // file name
   long   search_handle =INVALID_HANDLE; // search handle
// --- Get the first file in the current directory
   search_handle=::FileFindFirst(search_path,file_name,search_area);
// --- If not puto, then in a loop we count the number of objects in the current directory
   if(search_handle!=INVALID_HANDLE && file_name!="")
     {
      // --- If this is a folder, increase the counter
      if(IsFolder(file_name))
         counter++;
      // --- Let's go further through the list and count other folders
      while(::FileFindNext(search_handle,file_name))
        {
         if(IsFolder(file_name))
            counter++;
        }
     }
// --- Close the search handle
   ::FileFindClose(search_handle);
   return(counter);
  }
//+------------------------------------------------------------------+
// | Returns the local index of the previous node |
// | relative to the passed parameters |
//+------------------------------------------------------------------+
int CFileNavigator::PrevNodeItemIndex(const int root_index,const int node_level)
  {
   int prev_node_item_index=0;
// --- If not in the root directory
   if(node_level>1)
      prev_node_item_index=m_l_item_index[node_level-1];
   else
     {
      // --- If not the first element of the list
      if(root_index>0)
         prev_node_item_index=m_l_item_index[node_level-1];
     }
// --- Return the local index of the previous node
   return(prev_node_item_index);
  }
//+------------------------------------------------------------------+
// | Adds an item with the specified parameters to arrays |
//+------------------------------------------------------------------+
void CFileNavigator::AddItem(const int list_index,const string item_text,const int node_level,const int prev_node_item_index,
                             const int item_index,const int items_total,const int folders_total,const bool is_folder)
  {
// ---Array reserve size
   int reserve_size=100000;
// --- Increase the size of the arrays by one element
   int array_size =::ArraySize(m_g_list_index);
   int new_size   =array_size+1;
   ::ArrayResize(m_g_prev_node_list_index,new_size,reserve_size);
   ::ArrayResize(m_g_list_index,new_size,reserve_size);
   ::ArrayResize(m_g_item_text,new_size,reserve_size);
   ::ArrayResize(m_g_item_index,new_size,reserve_size);
   ::ArrayResize(m_g_node_level,new_size,reserve_size);
   ::ArrayResize(m_g_prev_node_item_index,new_size,reserve_size);
   ::ArrayResize(m_g_items_total,new_size,reserve_size);
   ::ArrayResize(m_g_folders_total,new_size,reserve_size);
   ::ArrayResize(m_g_is_folder,new_size,reserve_size);
// --- Save the values ​​of the passed parameters
   m_g_prev_node_list_index[array_size] =(node_level==0)? -1 : m_l_prev_node_list_index[node_level-1];
   m_g_list_index[array_size]           =list_index;
   m_g_item_text[array_size]            =item_text;
   m_g_item_index[array_size]           =item_index;
   m_g_node_level[array_size]           =node_level;
   m_g_prev_node_item_index[array_size] =prev_node_item_index;
   m_g_items_total[array_size]          =items_total;
   m_g_folders_total[array_size]        =folders_total;
   m_g_is_folder[array_size]            =is_folder;
  }
//+------------------------------------------------------------------+
// | Go to next node |
//+------------------------------------------------------------------+
void CFileNavigator::ToNextNode(const int root_index,int list_index,int &node_level,
                                int &item_index,long &handle,const string item_text,const int search_area)
  {
// --- Search filter (* - check all files/folders)
   string filter="*";
// --- Let's form a path
   string search_path=m_l_path[node_level]+item_text+filter;
// --- Receive and save data
   m_l_item_total[node_level]           =ItemsTotal(search_path,search_area);
   m_l_folders_total[node_level]        =FoldersTotal(search_path,search_area);
   m_l_item_text[node_level]            =item_text;
   m_l_item_index[node_level]           =item_index;
   m_l_prev_node_list_index[node_level] =list_index;
// --- Get the point index of the previous node
   int prev_node_item_index=PrevNodeItemIndex(root_index,node_level);
// --- Add an item with the specified data to the general arrays
   AddItem(list_index,item_text,node_level,prev_node_item_index,
           item_index,m_l_item_total[node_level],m_l_folders_total[node_level],true);
// --- Increase the node counter
   node_level++;
// --- Increase the size of the arrays by one element
   AuxiliaryArraysResize(node_level);
// --- Receive and save data
   m_l_path[node_level]          =m_l_path[node_level-1]+item_text;
   m_l_item_total[node_level]    =ItemsTotal(m_l_path[node_level]+filter,search_area);
   m_l_folders_total[node_level] =FoldersTotal(m_l_path[node_level]+item_text+filter,search_area);
// --- Reset local index counter to zero
   item_index=0;
// --- Close the search handle
   ::FileFindClose(handle);
  }
//+------------------------------------------------------------------+
// | Removal |
//+------------------------------------------------------------------+
void CFileNavigator::Delete(void)
  {
   CElement::Delete();
// --- Freeing element arrays
   ::ArrayFree(m_g_prev_node_list_index);
   ::ArrayFree(m_g_list_index);
   ::ArrayFree(m_g_item_text);
   ::ArrayFree(m_g_item_index);
   ::ArrayFree(m_g_node_level);
   ::ArrayFree(m_g_prev_node_item_index);
   ::ArrayFree(m_g_items_total);
   ::ArrayFree(m_g_folders_total);
   ::ArrayFree(m_g_item_state);
//---
   ::ArrayFree(m_l_prev_node_list_index);
   ::ArrayFree(m_l_item_text);
   ::ArrayFree(m_l_path);
   ::ArrayFree(m_l_item_index);
   ::ArrayFree(m_l_item_total);
   ::ArrayFree(m_l_folders_total);
// --- Reset variables
   m_current_path="";
  }
//+------------------------------------------------------------------+
// | Draws an element |
//+------------------------------------------------------------------+
void CFileNavigator::Draw(void)
  {
// --- Draw background
   CElement::DrawBackground();
// --- Draw a frame
   CElement::DrawBorder();
// --- Draw text
   DrawText();
  }
//+------------------------------------------------------------------+
// | Draws text |
//+------------------------------------------------------------------+
void CFileNavigator::DrawText(void)
  {
// --- Coordinates
   int x=5,y=m_y_size>>1;
// --- Text properties
   m_canvas.FontSet(CElement::Font(),-CElement::FontSize()*10,FW_NORMAL);
// --- If the path has not yet been set, show the default line
   if(m_current_full_path=="")
      m_current_full_path="Loading. Please wait...";
// --- Display the path in the address bar of the file navigator
   m_canvas.TextOut(x,y,m_current_full_path,::ColorToARGB(m_label_color),TA_LEFT|TA_VCENTER);
  }
//+------------------------------------------------------------------+
// | Change the width along the right edge of the form |
//+------------------------------------------------------------------+
void CFileNavigator::ChangeWidthByRightWindowSide(void)
  {
// --- Exit if snap to right side of window mode is enabled
   if(m_anchor_right_window_side)
      return;
// --- Calculate and set a new size for the element's background
   int x_size=m_main.X2()-CElementBase::X()-m_auto_xresize_right_offset;
// --- Set new size
   CElementBase::XSize(x_size);
   m_canvas.XSize(x_size);
   m_canvas.Resize(x_size,m_y_size);
// --- Redraw element
   Draw();
  }
//+------------------------------------------------------------------+
