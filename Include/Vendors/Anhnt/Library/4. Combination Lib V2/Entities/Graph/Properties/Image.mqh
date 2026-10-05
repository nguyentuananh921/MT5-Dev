//+------------------------------------------------------------------+
//|                                                        Image.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//| Library link https://www.mql5.com/en/code/19703                  |
//+------------------------------------------------------------------+
#ifndef __IMAGE_MQH__
#define __IMAGE_MQH__
 #include <Canvas\Canvas.mqh>
 #include "..\..\Defines\ImageDataDefine.mqh"
 #include "..\..\..\Services\Colors.mqh"
//+------------------------------------------------------------------+
//| One picture: pixel data read from ImageDataDefine or a resource  |
//+------------------------------------------------------------------+
class CImage
  {
   private:
     static SImage     s_store[];
     static bool       s_loaded[];
     static bool       EnsureLoaded(const uint index);
   protected:
     uint              m_image_data[];
     uint              m_image_width;
     uint              m_image_height;
     string            m_bmp_path;
     uint              m_resource_index;
   public:
                       CImage(void);
                      ~CImage(void);
     uint              DataTotal(void)                             { return(::ArraySize(m_image_data)); }
     uint              Data(const uint data_index)                 { return(m_image_data[data_index]);  }
     void              Data(const uint data_index,const uint data) { m_image_data[data_index]=data;     }
     void              Width(const uint width)                     { m_image_width=width;               }
     uint              Width(void)                                 { return(m_image_width);             }
     void              Height(const uint height)                   { m_image_height=height;             }
     uint              Height(void)                                { return(m_image_height);            }
     void              BmpPath(const string bmp_file_path)         { m_bmp_path=bmp_file_path;          }
     string            BmpPath(void)                               { return(m_bmp_path);                }
     void              ResourceIndex(const uint resource_index)    { m_resource_index=resource_index;   }
     uint              ResourceIndex(void)                         { return(m_resource_index);          }
     bool              ReadImageData(const string bmp_file_path);
     bool              ReadImageData(const uint resource_index);
     void              CopyImageData(CImage &array_source);
     void              DeleteImageData(void);
     void              Draw(CCanvas &canvas,const int x,const int y);
  };
#ifndef CIMAGE_MQH_IMPLEMENTATION
#define CIMAGE_MQH_IMPLEMENTATION
SImage CImage::s_store[];
bool   CImage::s_loaded[];
//+------------------------------------------------------------------+
//| Loads one image into the shared store on first request only      |
//+------------------------------------------------------------------+
bool CImage::EnsureLoaded(const uint index)
  {
   if(index>=IMAGE_RESOURCE_TOTAL)
      return false;
   if(::ArraySize(s_loaded)!=(int)IMAGE_RESOURCE_TOTAL)
     {
      ::ArrayResize(s_store,IMAGE_RESOURCE_TOTAL);
      ::ArrayResize(s_loaded,IMAGE_RESOURCE_TOTAL);
      for(uint i=0; i<IMAGE_RESOURCE_TOTAL; i++)
         s_loaded[i]=false;
     }
   if(!s_loaded[index])
      s_loaded[index]=LoadImageData(index,s_store[index]);
   return s_loaded[index];
  }
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
//| Reads image data from a resource path                            |
//+------------------------------------------------------------------+
bool CImage::ReadImageData(const string bmp_file_path)
  {
   if(bmp_file_path=="")
      return(false);
   m_bmp_path=bmp_file_path;
   if(!::ResourceReadImage("::"+m_bmp_path,m_image_data,m_image_width,m_image_height))
     {
      ::Print(__FUNCTION__," > Error reading image at Path ("+m_bmp_path+"): ",::GetLastError());
      return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| Reads image data from an ImageDataDefine index                   |
//+------------------------------------------------------------------+
bool CImage::ReadImageData(const uint resource_index)
  {
   if(resource_index==INT_MAX)
      return(false);
   if(!EnsureLoaded(resource_index))
     {
      ::Print(__FUNCTION__," > Image not found in ImageDataDefine at index: ",resource_index);
      return(false);
     }
   m_resource_index=resource_index;
   m_image_width   =s_store[resource_index].width;
   m_image_height  =s_store[resource_index].height;
   ::ArrayCopy(m_image_data,s_store[resource_index].data);
   return(true);
  }
//+------------------------------------------------------------------+
//| Copies the transferred image data                                |
//+------------------------------------------------------------------+
void CImage::CopyImageData(CImage &array_source)
  {
   uint source_data_total=array_source.DataTotal();
   ::ArrayResize(m_image_data,source_data_total);
   for(uint i=0; i<source_data_total; i++)
      m_image_data[i]=array_source.Data(i);
  }
//+------------------------------------------------------------------+
//| Deletes image data                                               |
//+------------------------------------------------------------------+
void CImage::DeleteImageData(void)
  {
   ::ArrayFree(m_image_data);
   m_image_width =0;
   m_image_height=0;
   m_bmp_path    ="";
  }
//+------------------------------------------------------------------+
//| Blends onto the canvas, fully transparent pixels skipped         |
//+------------------------------------------------------------------+
void CImage::Draw(CCanvas &canvas,const int x,const int y)
  {
   for(uint ly=0,p=0; ly<m_image_height; ly++)
     {
      for(uint lx=0; lx<m_image_width; lx++,p++)
        {
         if((m_image_data[p]>>24)==0)
            continue;
         uint background=::ColorToARGB(canvas.PixelGet(x+lx,y+ly));
         canvas.PixelSet(x+lx,y+ly,::ColorToARGB(CColors::BlendColors(background,m_image_data[p])));
        }
     }
  }
#endif // CIMAGE_MQH_IMPLEMENTATION
#endif // __IMAGE_MQH__
