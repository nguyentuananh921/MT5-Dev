//+------------------------------------------------------------------+
//|                                                      Objects.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "Enums.mqh"
#include "Defines.mqh"
#include "Fonts.mqh"
#include "Colors.mqh"
#include <Graphics\Graphic.mqh>
#include <ChartObjects\ChartObjectSubChart.mqh>
#include "Resources.mqh"
// --- List of classes in the file for quick transition (Alt+G)
class CImage;
class CRectCanvas;
class CSubChart;
//+------------------------------------------------------------------+
// | Class for storing image data |
//+------------------------------------------------------------------+
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
      ::Print(__FUNCTION__," > Ошибка при чтении изображения ("+m_bmp_path+"): ",::GetLastError());
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
//+------------------------------------------------------------------+
// | Class with additional properties for the Rectangle Canvas object |
//+------------------------------------------------------------------+
class CRectCanvas : public CCanvas
  {
protected:
   int               m_x;
   int               m_y;
   int               m_x2;
   int               m_y2;
   int               m_x_gap;
   int               m_y_gap;
   int               m_x_size;
   int               m_y_size;
   bool              m_mouse_focus;
   //---
public:
                     CRectCanvas(void);
                    ~CRectCanvas(void);
   // --- Coordinates
   int               X(void)                      { return(m_x);           }
   void              X(const int x)               { m_x=x;                 }
   int               Y(void)                      { return(m_y);           }
   void              Y(const int y)               { m_y=y;                 }
   int               X2(void)                     { return(m_x+m_x_size);  }
   int               Y2(void)                     { return(m_y+m_y_size);  }
   // --- Indents from the extreme point (xy)
   int               XGap(void)                   { return(m_x_gap);       }
   void              XGap(const int x_gap)        { m_x_gap=x_gap;         }
   int               YGap(void)                   { return(m_y_gap);       }
   void              YGap(const int y_gap)        { m_y_gap=y_gap;         }
   // --- Dimensions
   int               XSize(void)                  { return(m_x_size);      }
   void              XSize(const int x_size)      { m_x_size=x_size;       }
   int               YSize(void)                  { return(m_y_size);      }
   void              YSize(const int y_size)      { m_y_size=y_size;       }
   // ---Focus
   bool              MouseFocus(void)             { return(m_mouse_focus); }
   void              MouseFocus(const bool focus) { m_mouse_focus=focus;   }
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CRectCanvas::CRectCanvas(void) : m_x(0),
                                 m_y(0),
                                 m_x2(0),
                                 m_y2(0),
                                 m_x_gap(0),
                                 m_y_gap(0),
                                 m_x_size(0),
                                 m_y_size(0),
                                 m_mouse_focus(false)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CRectCanvas::~CRectCanvas(void)
  {
  }
//+------------------------------------------------------------------+
// | Class with additional properties for the Sub Chart object |
//+------------------------------------------------------------------+
class CSubChart : public CChartObjectSubChart
  {
protected:
   int               m_x;
   int               m_y;
   int               m_x2;
   int               m_y2;
   int               m_x_gap;
   int               m_y_gap;
   int               m_x_size;
   int               m_y_size;
   bool              m_mouse_focus;
   //---
public:
                     CSubChart(void);
                    ~CSubChart(void);
   // ---Coordinates
   int               X(void)                      { return(m_x);           }
   void              X(const int x)               { m_x=x;                 }
   int               Y(void)                      { return(m_y);           }
   void              Y(const int y)               { m_y=y;                 }
   int               X2(void)                     { return(m_x+m_x_size);  }
   int               Y2(void)                     { return(m_y+m_y_size);  }
   // --- Indents from the extreme point (xy)
   int               XGap(void)                   { return(m_x_gap);       }
   void              XGap(const int x_gap)        { m_x_gap=x_gap;         }
   int               YGap(void)                   { return(m_y_gap);       }
   void              YGap(const int y_gap)        { m_y_gap=y_gap;         }
   // --- Dimensions
   int               XSize(void)                  { return(m_x_size);      }
   void              XSize(const int x_size)      { m_x_size=x_size;       }
   int               YSize(void)                  { return(m_y_size);      }
   void              YSize(const int y_size)      { m_y_size=y_size;       }
   // ---Focus
   bool              MouseFocus(void)             { return(m_mouse_focus); }
   void              MouseFocus(const bool focus) { m_mouse_focus=focus;   }
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSubChart::CSubChart(void) : m_x(0),
                             m_y(0),
                             m_x2(0),
                             m_y2(0),
                             m_x_gap(0),
                             m_y_gap(0),
                             m_x_size(0),
                             m_y_size(0),
                             m_mouse_focus(false)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSubChart::~CSubChart(void)
  {
  }
//+------------------------------------------------------------------+
