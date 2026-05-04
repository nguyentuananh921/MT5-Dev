//+------------------------------------------------------------------+
//|                                                        Fonts.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//| Introduction at https://www.mql5.com/en/articles/2829            |
//|Lib Link https://www.mql5.com/en/code/19703                       |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// | Class for working with fonts |
//+------------------------------------------------------------------+
#ifndef __FONTS_MQH__
#define __FONTS_MQH__
class CFonts
  {
   private:
    //Private properties:
     // --- Font array
      string            m_fonts[];
     //Private methods:
      // --- Initializing the font array
      void              InitializeFontsArray(void);
   public:
                        CFonts(void);
                     ~CFonts(void);
    // --- Returns the number of fonts
      int               FontsTotal(void) const { return(::ArraySize(m_fonts)); }
    // --- Returns the font by index
      string            FontsByIndex(const uint index);      
  };
 #ifndef CFONTS_MQH_IMPLEMENTATION
 #define CFONTS_MQH_IMPLEMENTATION
   //+------------------------------------------------------------------+
   //| Constructor                                                      |
   //+------------------------------------------------------------------+
   CFonts::CFonts(void)
     {
      // --- Initializing the font array
         InitializeFontsArray();
     }
   //+------------------------------------------------------------------+
   //| Destructor                                                       |
   //+------------------------------------------------------------------+
   CFonts::~CFonts(void)
     {
      ::ArrayFree(m_fonts);
     }
   //+------------------------------------------------------------------+
   // | Returns the font by index |
   //+------------------------------------------------------------------+
   string CFonts::FontsByIndex(const uint index)
     {
      // --- Array size
         uint array_size=FontsTotal();
      // --- Adjustment in case of leaving the range
         uint i=(index>=array_size)? array_size-1 : index;
      // --- Restore font
         return(m_fonts[i]);
     }
   //+------------------------------------------------------------------+
   // | Initializing the font array |
   //+------------------------------------------------------------------+
   void CFonts::InitializeFontsArray(void)
     {
         ::ArrayResize(m_fonts,187);
         m_fonts[0]="@Malgun Gothic";
         m_fonts[1]="@Malgun Gothic Semilight";
         m_fonts[2]="@Microsoft JhengHei";
         m_fonts[3]="@Microsoft JhengHei Light";
         m_fonts[4]="@Microsoft JhengHei UI";
         m_fonts[5]="@Microsoft JhengHei UI Light";
         m_fonts[6]="@Microsoft YaHei";
         m_fonts[7]="@Microsoft YaHei Light";
         m_fonts[8]="@Microsoft YaHei UI";
         m_fonts[9]="@Microsoft YaHei UI Light";
      //---
         m_fonts[10]="@MingLiU_HKSCS-ExtB";
         m_fonts[11]="@MingLiU-ExtB";
         m_fonts[12]="@MS Gothic";
         m_fonts[13]="@MS PGothic";
         m_fonts[14]="@MS UI Gothic";
         m_fonts[15]="@NSimSun";
         m_fonts[16]="@PMingLiU-ExtB";
         m_fonts[17]="@SimSun";
         m_fonts[18]="@SimSun-ExtB";
         m_fonts[19]="@Yu Gothic";
      //---
         m_fonts[20]="@Yu Gothic Light";
         m_fonts[21]="@Yu Gothic Medium";
         m_fonts[22]="@Yu Gothic UI";
         m_fonts[23]="@Yu Gothic UI Light";
         m_fonts[24]="@Yu Gothic UI Semibold";
         m_fonts[25]="@Yu Gothic UI Semilight";
         m_fonts[26]="Algerian";
         m_fonts[27]="Arial";
         m_fonts[28]="Arial Black";
         m_fonts[29]="Arial Narrow";
      //---
         m_fonts[30]="Baskerville Old Face";
         m_fonts[31]="Bauhaus 93";
         m_fonts[32]="Bell MT";
         m_fonts[33]="Berlin Sans FB";
         m_fonts[34]="Berlin Sans FB Demi";
         m_fonts[35]="Bernard MT Condensed";
         m_fonts[36]="Bodoni MT Poster Compressed";
         m_fonts[37]="Book Antiqua";
         m_fonts[38]="Bookman Old Style";
         m_fonts[39]="Bookshelf Symbol 7";
      //---
         m_fonts[40]="Britannic Bold";
         m_fonts[41]="Broadway";
         m_fonts[42]="Brush Script MT";
         m_fonts[43]="Calibri";
         m_fonts[44]="Calibri Light";
         m_fonts[45]="Californian FB";
         m_fonts[46]="Cambria";
         m_fonts[47]="Cambria Math";
         m_fonts[48]="Candara";
         m_fonts[49]="Centaur";
      //---
         m_fonts[50]="Century";
         m_fonts[51]="Century Gothic";
         m_fonts[52]="Chiller";
         m_fonts[53]="Colonna MT";
         m_fonts[54]="Comic Sans MS";
         m_fonts[55]="Consolas";
         m_fonts[56]="Constantia";
         m_fonts[57]="Cooper Black";
         m_fonts[58]="Corbel";
         m_fonts[59]="Courier";
      //---
         m_fonts[60]="Courier New";
         m_fonts[61]="Ebrima";
         m_fonts[62]="Fixedsys";
         m_fonts[63]="Footlight MT Light";
         m_fonts[64]="Franklin Gothic Medium";
         m_fonts[65]="Freestyle Script";
         m_fonts[66]="Gabriola";
         m_fonts[67]="Gadugi";
         m_fonts[68]="Garamond";
         m_fonts[69]="Georgia";
      //---
         m_fonts[70]="Harlow Solid Italic";
         m_fonts[71]="Harrington";
         m_fonts[72]="High Tower Text";
         m_fonts[73]="Impact";
         m_fonts[74]="Informal Roman";
         m_fonts[75]="Javanese Text";
         m_fonts[76]="Jokerman";
         m_fonts[77]="Juice ITC";
         m_fonts[78]="Kristen ITC";
         m_fonts[79]="Kunstler Script";
      //---
         m_fonts[80]="Leelawadee UI";
         m_fonts[81]="Leelawadee UI Semilight";
         m_fonts[82]="Lucida Bright";
         m_fonts[83]="Lucida Calligraphy";
         m_fonts[84]="Lucida Console";
         m_fonts[85]="Lucida Fax";
         m_fonts[86]="Lucida Handwriting";
         m_fonts[87]="Lucida Sans Unicode";
         m_fonts[88]="Magneto";
         m_fonts[89]="Malgun Gothic";
      //---
         m_fonts[90]="Malgun Gothic Semilight";
         m_fonts[91]="Marlett";
         m_fonts[92]="Matura MT Script Capitals";
         m_fonts[93]="Microsoft Himalaya";
         m_fonts[94]="Microsoft JhengHei";
         m_fonts[95]="Microsoft JhengHei Light";
         m_fonts[96]="Microsoft JhengHei UI";
         m_fonts[97]="Microsoft JhengHei UI Light";
         m_fonts[98]="Microsoft New Tai Lue";
         m_fonts[99]="Microsoft PhagsPa";
      //---
         m_fonts[100]="Microsoft Sans Serif";
         m_fonts[101]="Microsoft Tai Le";
         m_fonts[102]="Microsoft Uighur";
         m_fonts[103]="Microsoft YaHei";
         m_fonts[104]="Microsoft YaHei Light";
         m_fonts[105]="Microsoft YaHei UI";
         m_fonts[106]="Microsoft YaHei UI Light";
         m_fonts[107]="Microsoft Yi Baiti";
         m_fonts[108]="MingLiU_HKSCS-ExtB";
         m_fonts[109]="MingLiU-ExtB";
      //---
         m_fonts[110]="Mistral";
         m_fonts[111]="Modern";
         m_fonts[112]="Modern No. 20";
         m_fonts[113]="Mongolian Baiti";
         m_fonts[114]="Monotype Corsiva";
         m_fonts[115]="MS Gothic";
         m_fonts[116]="MS PGothic";
         m_fonts[117]="MS Reference Sans Serif";
         m_fonts[118]="MS Reference Specialty";
         m_fonts[119]="MS Sans Serif";
      //---
         m_fonts[120]="MS Serif";
         m_fonts[121]="MS UI Gothic";
         m_fonts[122]="MT Extra";
         m_fonts[123]="MV Boli";
         m_fonts[124]="Myanmar Text";
         m_fonts[125]="Niagara Engraved";
         m_fonts[126]="Niagara Solid";
         m_fonts[127]="Niagara UI";
         m_fonts[128]="Niagara UI Semilight";
         m_fonts[129]="NSimSun";
      //---
         m_fonts[130]="Old English Text MT";
         m_fonts[131]="Onix";
         m_fonts[132]="Palatino Linotype";
         m_fonts[133]="Parchment";
         m_fonts[134]="Playbill";
         m_fonts[135]="PMingLiU-ExtB";
         m_fonts[136]="Poor Richard";
         m_fonts[137]="Ravie";
         m_fonts[138]="Roman";
         m_fonts[139]="Script";
      //---
         m_fonts[140]="Segoe MDL2 Assets";
         m_fonts[141]="Segoe Print";
         m_fonts[142]="Segoe Script";
         m_fonts[143]="Segoe UI";
         m_fonts[144]="Segoe UI Black";
         m_fonts[145]="Segoe UI Emoji";
         m_fonts[146]="Segoe UI Historic";
         m_fonts[147]="Segoe UI Light";
         m_fonts[148]="Segoe UI Semibold";
         m_fonts[149]="Segoe UI Semilight";
      //---
         m_fonts[150]="Segoe UI Symbol";
         m_fonts[151]="Showcard Gothic";
         m_fonts[152]="SimSun";
         m_fonts[153]="SimSun-ExtB";
         m_fonts[154]="Sitka Banner";
         m_fonts[155]="Sitka Display";
         m_fonts[156]="Sitka Heading";
         m_fonts[157]="Sitka Small";
         m_fonts[158]="Sitka Subheading";
         m_fonts[159]="Sitka Text";
      //---
         m_fonts[160]="Small Fonts";
         m_fonts[161]="Snap ITC";
         m_fonts[162]="Stencil";
         m_fonts[163]="Sylfaen";
         m_fonts[164]="Symbol";
         m_fonts[165]="System";
         m_fonts[166]="Tahoma";
         m_fonts[167]="Tempus Sans ITC";
         m_fonts[168]="Terminal";
         m_fonts[169]="Times New Roman";
      //---
         m_fonts[170]="Trebuchet MS";
         m_fonts[171]="Verdana";
         m_fonts[172]="Viner Hand ITC";
         m_fonts[173]="Vivaldi";
         m_fonts[174]="Vladimir Script";
         m_fonts[175]="Webdings";
         m_fonts[176]="Wide Latin";
         m_fonts[177]="Wingdings";
         m_fonts[178]="Wingdings 2";
         m_fonts[179]="Wingdings 3";
      //---
         m_fonts[180]="Yu Gothic";
         m_fonts[181]="Yu Gothic Light";
         m_fonts[182]="Yu Gothic Medium";
         m_fonts[183]="Yu Gothic UI";
         m_fonts[184]="Yu Gothic UI Light";
         m_fonts[185]="Yu Gothic UI Semibold";
         m_fonts[186]="Yu Gothic UI Semilight";
     }
   //+------------------------------------------------------------------+
 #endif // CFONTS_MQH_IMPLEMENTATION
#endif // __FONTS_MQH__
