//+------------------------------------------------------------------+
//|                                                        Image.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//| Library link https://www.mql5.com/en/code/19703                  |
//+------------------------------------------------------------------+
#ifndef __IMAGE_MQH__
#define __IMAGE_MQH__
 #include "..\Defines\GUIDefines.mqh"
 #include "Fonts.mqh"
 #include <Graphics\Graphic.mqh>
 #include <ChartObjects\ChartObjectSubChart.mqh>
 #include "..\Defines\ImageDataDefine.mqh"
 //+------------------------------------------------------------------+
 //| Class for storing image data                                     |
 //+------------------------------------------------------------------+
 class CImage
  {
   private:
     static CImage    *s_instance;
   protected:
     SImage            m_image_store[];  // All image data from ImageDataDefine
     uint              m_image_data[];   // Active image pixel array
     uint              m_image_width;    // Active image width
     uint              m_image_height;   // Active image height
     string            m_bmp_path;       // Path to image file
     uint              m_resource_index; // Index to resource
   public:
                       CImage(void);
                       ~CImage(void);
     // --- Singleton access
       static CImage    *Instance(void);
       static void       Destroy(void);
     // --- (1) Data array size, (2) set/return data (pixel color)
       uint              DataTotal(void)                             { return(::ArraySize(m_image_data)); }
       uint              Data(const uint data_index)                 { return(m_image_data[data_index]);  }
       void              Data(const uint data_index,const uint data) { m_image_data[data_index]=data;     }
     // --- Set/return image width
       void              Width(const uint width)                     { m_image_width=width;               }
       uint              Width(void)                                 { return(m_image_width);             }
     // --- Set/return image height
       void              Height(const uint height)                   { m_image_height=height;             }
       uint              Height(void)                                { return(m_image_height);            }
     // --- Set/return image path
       void              BmpPath(const string bmp_file_path)        { m_bmp_path=bmp_file_path;          }
       string            BmpPath(void)                              { return(m_bmp_path);                }
     // --- Set/return index to image
       void              ResourceIndex(const uint resource_index)   { m_resource_index=resource_index;   }
       uint              ResourceIndex(void)                        { return(m_resource_index);          }
     // --- Get image data by index (backward-compat with CImageResources::GetData)
       string            GetData(const uint index, uint &image_data[], uint &image_width, uint &image_height);
     // --- Reads and saves the transferred image data (resource path)
       bool              ReadImageData(const string bmp_file_path);
     // --- Reads and saves the transferred image data (index to ImageDataDefine)
       bool              ReadImageData(const uint resource_index);
     // --- Copies the transferred image data
       void              CopyImageData(CImage &array_source);
     // --- Deletes image data
       void              DeleteImageData(void);
  };
 #ifndef CIMAGE_MQH_IMPLEMENTATION
 #define CIMAGE_MQH_IMPLEMENTATION
  CImage* CImage::s_instance = NULL;
  //+------------------------------------------------------------------+
  //| Singleton: returns shared instance                               |
  //+------------------------------------------------------------------+
  CImage* CImage::Instance(void)
   {
    if(s_instance == NULL)
       s_instance = new CImage();
    return(s_instance);
   }
  //+------------------------------------------------------------------+
  //| Singleton: destroys shared instance                              |
  //+------------------------------------------------------------------+
  void CImage::Destroy(void)
   {
    if(s_instance != NULL)
      {
       delete s_instance;
       s_instance = NULL;
      }
   }
  //+------------------------------------------------------------------+
  //| Get image data by index (backward-compat with CImageResources)   |
  //+------------------------------------------------------------------+
  string CImage::GetData(const uint index, uint &image_data[], uint &image_width, uint &image_height)
   {
    if((int)index >= ArraySize(m_image_store))
      {
       ::Print(__FUNCTION__, " > Image not found in ImageDataDefine at index: ", index);
       return("");
      }
    ArrayFree(image_data);
    image_width  = m_image_store[index].width;
    image_height = m_image_store[index].height;
    ArrayCopy(image_data, m_image_store[index].data);
    return(m_image_store[index].name);
   }
  //+------------------------------------------------------------------+
  //| Constructor                                                      |
  //+------------------------------------------------------------------+
  CImage::CImage(void) : m_image_width(0),
                         m_image_height(0),
                         m_bmp_path(""),
                         m_resource_index(INT_MAX)
   {
    InitImageData(m_image_store);
   }
  //+------------------------------------------------------------------+
  //| Destructor                                                       |
  //+------------------------------------------------------------------+
  CImage::~CImage(void)
   {
    DeleteImageData();
   }
  //+------------------------------------------------------------------+
  //| Reads and saves image data from file path                        |
  //+------------------------------------------------------------------+
  bool CImage::ReadImageData(const string bmp_file_path)
   {
    if(bmp_file_path == "")
       return(false);
    m_bmp_path = bmp_file_path;
    if(!::ResourceReadImage("::" + m_bmp_path, m_image_data, m_image_width, m_image_height))
      {
       ::Print(__FUNCTION__, " > Error reading image at Path (" + m_bmp_path + "): ", ::GetLastError());
       return(false);
      }
    return(true);
   }
  //+------------------------------------------------------------------+
  //| Reads and saves image data from ImageDataDefine index            |
  //+------------------------------------------------------------------+
  bool CImage::ReadImageData(const uint resource_index)
   {
    if(resource_index == INT_MAX)
       return(false);
    if((int)resource_index >= ArraySize(m_image_store))
      {
       ::Print(__FUNCTION__, " > Image not found in ImageDataDefine at index: ", resource_index);
       return(false);
      }
    m_resource_index = resource_index;
    m_image_width    = m_image_store[resource_index].width;
    m_image_height   = m_image_store[resource_index].height;
    ArrayCopy(m_image_data, m_image_store[resource_index].data);
    return(true);
   }
  //+------------------------------------------------------------------+
  //| Copies the transferred image data                                |
  //+------------------------------------------------------------------+
  void CImage::CopyImageData(CImage &array_source)
   {
    uint source_data_total = array_source.DataTotal();
    ::ArrayResize(m_image_data, source_data_total);
    for(uint i = 0; i < source_data_total; i++)
       m_image_data[i] = array_source.Data(i);
   }
  //+------------------------------------------------------------------+
  //| Deletes image data                                               |
  //+------------------------------------------------------------------+
  void CImage::DeleteImageData(void)
   {
    ::ArrayFree(m_image_data);
    m_image_width  = 0;
    m_image_height = 0;
    m_bmp_path     = "";
   }
 #endif // CIMAGE_MQH_IMPLEMENTATION
#endif // __IMAGE_MQH__
