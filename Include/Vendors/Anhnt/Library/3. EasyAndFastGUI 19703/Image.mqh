//+------------------------------------------------------------------+
//|                                                        Image.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//| Library link https://www.mql5.com/en/code/19703                  |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Class for storing image data |
//+------------------------------------------------------------------+
#ifndef __IMAGE_MQH__
#define __IMAGE_MQH__
 #include "Enums.mqh"
 #include "Defines.mqh"
 #include "Fonts.mqh"
 #include "Colors.mqh"
 #include <Graphics\Graphic.mqh>
 #include <ChartObjects\ChartObjectSubChart.mqh>
 #include "Resources.mqh"
 class CImage
  {
protected:
   CResources        m_resources;
   
   uint              m_image_data[];   // Array of picture pixels (colors)
   uint              m_image_width;    // Image width
   uint              m_image_height;   // Image height
   string            m_bmp_path;       // Path to image file
   uint              m_resource_index; // Index to resource
   //---
public:
                     CImage(void);
                    ~CImage(void);
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
   void              BmpPath(const string bmp_file_path)         { m_bmp_path=bmp_file_path;          }
   string            BmpPath(void)                               { return(m_bmp_path);                }
   // --- Set/return index to image
   void              ResourceIndex(const uint resource_index)    { m_resource_index=resource_index;   }
   uint              ResourceIndex(void)                         { return(m_resource_index);          }
   
   // --- Reads and saves the transferred image data (resource path)
   bool              ReadImageData(const string bmp_file_path);
   // --- Reads and saves the transferred image data (index to the resource)
   bool              ReadImageData(const uint resource_index);
   // --- Copies the transferred image data
   void              CopyImageData(CImage &array_source);
   // ---Deletes image data
   void              DeleteImageData(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CImage::CImage(void) : m_image_width(0),
                       m_image_height(0),
                       m_bmp_path(""),
                       m_resource_index(INT_MAX)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CImage::~CImage(void)
  {
   DeleteImageData();
  }
//+------------------------------------------------------------------+
// | Saves the passed image (path to the resource) to an array |
//+------------------------------------------------------------------+
bool CImage::ReadImageData(const string bmp_file_path)
 {
  // --- Exit if empty line
   if(bmp_file_path=="")
      return(false);
  // --- Save the path to the image
   m_bmp_path=bmp_file_path;
  // --- Reset last error
   ::ResetLastError();
  // --- Read and save image data
   if(!::ResourceReadImage("::"+m_bmp_path,m_image_data,m_image_width,m_image_height))
     {
      ::Print(__FUNCTION__," > Error reading image ("+m_bmp_path+"): ",::GetLastError());
      return(false);
     }
  //---
   return(true);
 }
//+------------------------------------------------------------------+
// | Saves the passed image (index to the resource) into an array |
//+------------------------------------------------------------------+
bool CImage::ReadImageData(const uint resource_index)
 {
  // --- Exit if empty line
   if(resource_index == INT_MAX)
      return(false);
  // --- Save the index to the resource
   m_resource_index=resource_index;
  // --- Reset last error
   ::ResetLastError();
  // --- Read and save image data
   if(m_resources.GetData(resource_index, m_image_data, m_image_width, m_image_height) == "")
     return(false);
  //---
   return(true);
 }
//+------------------------------------------------------------------+
// | Copies the transferred image data |
//+------------------------------------------------------------------+
void CImage::CopyImageData(CImage &array_source)
 {
  // --- Get the size of the source array
   uint source_data_total =array_source.DataTotal();
  // --- Change the size of the destination array
   ::ArrayResize(m_image_data,source_data_total);
  // --- Copying data
   for(uint i=0; i<source_data_total; i++)
      m_image_data[i]=array_source.Data(i);
 }
//+------------------------------------------------------------------+
// | Deletes image data |
//+------------------------------------------------------------------+
void CImage::DeleteImageData(void)
 {
   ::ArrayFree(m_image_data);
   m_image_width  =0;
   m_image_height =0;
   m_bmp_path     ="";
 }

#endif // __IMAGE_MQH__
