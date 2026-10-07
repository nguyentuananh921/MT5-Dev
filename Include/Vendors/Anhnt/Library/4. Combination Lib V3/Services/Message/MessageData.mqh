//+------------------------------------------------------------------+
//|                                                  MessageData.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//| Service functions                                                |
//| Outside Bar pattern                                              |
//| Link                     https://www.mql5.com/en/articles/10237  |
//| Topic link https://www.mql5.com/en/articles/14710                |
//+------------------------------------------------------------------+
#ifndef __MESSAGE_DATA_MQH__
#define __MESSAGE_DATA_MQH__
 //+------------------------------------------------------------------+
 //| Macro substitutions                                              |
 //+------------------------------------------------------------------+
 #define INPUT_SEPARATOR                (",")    // Separator in the inputs string
 #define TOTAL_LANG                     (2)      // Number of used languages
 //+------------------------------------------------------------------+
  //| List of the library's text message indices                       |
  //+------------------------------------------------------------------+
  enum ENUM_MESSAGES_LIB
    {
      MSG_LIB_PARAMS_LIST_BEG=ERR_USER_ERROR_FIRST,      // Beginning of the parameter list
      MSG_LIB_SYS_ERROR,                                 // Error
      MSG_LIB_SYS_ERROR_CODE_OUT_OF_RANGE,               // Return code out of range of error codes
      MSG_LIB_TEXT_TERMINAL_NOT_MAIL_ENABLED,            // Sending emails disabled in terminal
      MSG_LIB_TEXT_TERMINAL_NOT_PUSH_ENABLED,            // Sending push notifications disabled in terminal
      MSG_LIB_TEXT_TERMINAL_NOT_FTP_ENABLED,             // Sending files to FTP address disabled in terminal
      MSG_LIB_TEXT_TS_TEXT_UNKNOWN_TIMEFRAME,            // Unknown timeframe
      MSG_GRAPH_STD_OBJ_ERR_NOT_FIND_SUBWINDOW,          // Failed to find the chart subwindow
    };
 //+------------------------------------------------------------------+
 //| Array of execution time error messages (0, 4001 - 4025)          |
 //| (1) in user's country language                                   |
 //| (2) in the international language                                |
 //+------------------------------------------------------------------+
 string messages_runtime[][TOTAL_LANG]=
  {
   {"Операция выполнена успешно","Operation completed successfully"},                                                                          // 0
   {"Неожиданная внутренняя ошибка","Unexpected internal error"},                                                                                  // 4001
   {"Ошибочный параметр при внутреннем вызове функции клиентского терминала","Wrong parameter in inner call of client terminal function"}, // 4002
   {"Ошибочный параметр при вызове системной функции","Wrong parameter when calling system function"},                                         // 4003
   {"Недостаточно памяти для выполнения системной функции","Not enough memory to perform system function"},                                    // 4004
   {
    "Структура содержит объекты строк и/или динамических массивов и/или структуры с такими объектами и/или классы",                                // 4005
    "Structure contains objects of strings and/or dynamic arrays and/or structure of such objects and/or classes"
   },                                                                                                                                                    
   {
    "Массив неподходящего типа, неподходящего размера или испорченный объект динамического массива",                                               // 4006
    "Array of wrong type, wrong size, or damaged object of dynamic array"
   },
   {
    "Недостаточно памяти для перераспределения массива либо попытка изменения размера статического массива",                                       // 4007
    "Not enough memory for relocation of array, or attempt to change size of static array"
   },
   {"Недостаточно памяти для перераспределения строки","Not enough memory for relocation of string"},                                          // 4008
   {"Неинициализированная строка","Not initialized string"},                                                                                       // 4009
   {"Неправильное значение даты и/или времени","Invalid date and/or time"},                                                                        // 4010
   {"Общее число элементов в массиве не может превышать 2147483647","Total amount of elements in array cannot exceed 2147483647"},             // 4011
   {"Ошибочный указатель","Wrong pointer"},                                                                                                        // 4012
   {"Ошибочный тип указателя","Wrong type of pointer"},                                                                                            // 4013
   {"Системная функция не разрешена для вызова","Function not allowed for call"},                                                               // 4014
   {"Совпадение имени динамического и статического ресурсов","Names of dynamic and static resource match"},                            // 4015
   {"Ресурс с таким именем в EX5 не найден","Resource with this name not found in EX5"},                                                  // 4016
   {"Неподдерживаемый тип ресурса или размер более 16 MB","Unsupported resource type or its size exceeds 16 Mb"},                                  // 4017
   {"Имя ресурса превышает 63 символа","Resource name exceeds 63 characters"},                                                                 // 4018
   {"При вычислении математической функции произошло переполнение ","Overflow occurred when calculating math function "},                          // 4019
   {"Выход за дату окончания тестирования после вызова Sleep()","Out of test end date after calling Sleep()"},                                     // 4020
   {"Неизвестный код ошибки (4021)","Unknown error code (4021)"},                                                                         // 4021
   {
    "Тестирование было прекращено принудительно извне. Например, прервана оптимизацию, или закрыто окно визуального тестирования, или остановлен агент тестирования",
    "Test forcibly stopped from the outside. For example, optimization interrupted, visual testing window closed or testing agent stopped"},       // 4022
   {"Неподходящий тип","Invalid type"},                                                                                                            // 4023
   {"Невалидный хендл","Invalid handle"},                                                                                                          // 4024
   {"Пул объектов заполнен","Object pool filled out"},                                                                                             // 4025
  }; 
 //+------------------------------------------------------------------+
 //| Array of execution time error messages (4101 - 4116)             |
 //| (Charts)                                                         |
 //| (1) in user's country language                                   |
 //| (2) in the international language                                |
 //+------------------------------------------------------------------+
 string messages_runtime_charts[][TOTAL_LANG]=
  {
   {"Ошибочный идентификатор графика","Wrong chart ID"},                                                                                           // 4101
   {"График не отвечает","Chart does not respond"},                                                                                                // 4102
   {"График не найден","Chart not found"},                                                                                                         // 4103
   {"У графика нет эксперта, который мог бы обработать событие","No Expert Advisor in chart that could handle event"},                     // 4104
   {"Ошибка открытия графика","Chart opening error"},                                                                                              // 4105
   {"Ошибка при изменении для графика символа и периода","Failed to change chart symbol and period"},                                              // 4106
   {"Ошибочное значение параметра для функции по работе с графиком","Error value of parameter for function of working with charts"},       // 4107
   {"Ошибка при создании таймера","Failed to create timer"},                                                                                       // 4108
   {"Ошибочный идентификатор свойства графика","Wrong chart property ID"},                                                                         // 4109
   {"Ошибка при создании скриншота","Error creating screenshots"},                                                                                 // 4110
   {"Ошибка навигации по графику","Error navigating through chart"},                                                                               // 4111
   {"Ошибка при применении шаблона","Error applying template"},                                                                                    // 4112
   {"Подокно, содержащее указанный индикатор, не найдено","Subwindow containing indicator not found"},                                     // 4113
   {"Ошибка при добавлении индикатора на график","Error adding indicator to chart"},                                                            // 4114
   {"Ошибка при удалении индикатора с графика","Error deleting indicator from chart"},                                                      // 4115
   {"Индикатор не найден на указанном графике","Indicator not found on specified chart"},                                                      // 4116
  };
  //+------------------------------------------------------------------+
 //| Array of execution time error messages (4201 - 4205)             |
 //| (Graphical objects)                                              |
 //| (1) in user's country language                                   |
 //| (2) in the international language                                |
 //+------------------------------------------------------------------+
 string messages_runtime_graph_obj[][TOTAL_LANG]=
  {
   {"Ошибка при работе с графическим объектом","Error working with graphical object"},                                                           // 4201
   {"Графический объект не найден","Graphical object not found"},                                                                              // 4202
   {"Ошибочный идентификатор свойства графического объекта","Wrong ID of graphical object property"},                                            // 4203
   {"Невозможно получить дату, соответствующую значению","Unable to get date corresponding to value"},                                         // 4204
   {"Невозможно получить значение, соответствующее дате","Unable to get value corresponding to date"},                                         // 4205
  };
 //+------------------------------------------------------------------+
 //| Array of runtime error messages  (4301 - 4307)                   |
 //| (MarketInfo)                                                     |
 //| (1) in user's country language                                   |
 //| (2) in the international language                                |
 //+------------------------------------------------------------------+
 string messages_runtime_market[][TOTAL_LANG]=
  {
   {"Неизвестный символ","Unknown symbol"},                                                                                                        // 4301
   {"Символ не выбран в MarketWatch","Symbol not selected in MarketWatch"},                                                                     // 4302
   {"Ошибочный идентификатор свойства символа","Wrong identifier of symbol property"},                                                           // 4303
   {"Время последнего тика неизвестно (тиков не было)","Time of the last tick not known (no ticks)"},                                           // 4304
   {"Ошибка добавления или удаления символа в MarketWatch","Error adding or deleting symbol in MarketWatch"},                                    // 4305
   {"Превышен лимит выбранных символов в MarketWatch","Exceeded the limit of selected symbols in MarketWatch"},                                    // 4306
   {
    "Неправильный индекс сессии при вызове функции SymbolInfoSessionQuote/SymbolInfoSessionTrade",                                                 // 4307
    "Wrong session ID when calling the SymbolInfoSessionQuote/SymbolInfoSessionTrade function"    
   },                                                                                             
  };
 //+------------------------------------------------------------------+
 //| Array of execution time error messages (4401 - 4407)             |
 //| (Access to history)                                              |
 //| (1) in user's country language                                   |
 //| (2) in the international language                                |
 //+------------------------------------------------------------------+
 string messages_runtime_history[][TOTAL_LANG]=
  {
   {"Запрашиваемая история не найдена","Requested history not found"},                                                                             // 4401
   {"Ошибочный идентификатор свойства истории","Wrong ID of history property"},                                                                // 4402
   {"Превышен таймаут при запросе истории","Exceeded history request timeout"},                                                                    // 4403
   {"Количество запрашиваемых баров ограничено настройками терминала","Number of requested bars limited by terminal settings"},                    // 4404
   {"Множество ошибок при загрузке истории","Multiple errors when loading history"},                                                               // 4405
   {"Неизвестный код ошибки (4406)","Unknown error code (4406)"},                                                                         // 4406
   {"Принимающий массив слишком мал чтобы вместить все запрошенные данные","Receiving array too small to store all requested data"},            // 4407
  };
 //+------------------------------------------------------------------+
 //| Array of execution time error messages (4501 - 4524)             |
 //| (Global Variables)                                               |
 //| (1) in user's country language                                   |
 //| (2) in the international language                                |
 //+------------------------------------------------------------------+
 string messages_runtime_global[][TOTAL_LANG]=
  {
   {"Глобальная переменная клиентского терминала не найдена","Global variable of client terminal not found"},                               // 4501
   {
    "Глобальная переменная клиентского терминала с таким именем уже существует",                                                                   // 4502
    "Global variable of client terminal with the same name already exists"
   },
   {"Не было модификаций глобальных переменных","Global variables not modified"},                                                             // 4503
   {"Не удалось открыть и прочитать файл со значениями глобальных переменных","Cannot read file with global variable values"},                     // 4504
   {"Не удалось записать файл со значениями глобальных переменных","Cannot write file with global variable values"},                               // 4505
   
   {"Неизвестный код ошибки (4506)","Unknown error code (4506)"},                                                                         // 4506
   {"Неизвестный код ошибки (4507)","Unknown error code (4507)"},                                                                         // 4507
   {"Неизвестный код ошибки (4508)","Unknown error code (4508)"},                                                                         // 4508
   {"Неизвестный код ошибки (4509)","Unknown error code (4509)"},                                                                         // 4509
   
   {"Не удалось отправить письмо","Email sending failed"},                                                                                         // 4510
   {"Не удалось воспроизвести звук","Sound playing failed"},                                                                                       // 4511
   {"Ошибочный идентификатор свойства программы","Wrong identifier of program property"},                                                      // 4512
   {"Ошибочный идентификатор свойства терминала","Wrong identifier of terminal property"},                                                     // 4513
   {"Не удалось отправить файл по ftp","File sending via ftp failed"},                                                                             // 4514
   {"Не удалось отправить уведомление","Failed to send notification"},                                                                           // 4515
   {
    "Неверный параметр для отправки уведомления – в функцию SendNotification() передали пустую строку или NULL",                                   // 4516
    "Invalid parameter for sending notification – empty string or NULL passed to SendNotification() function"
   },
   {
    "Неверные настройки уведомлений в терминале (не указан ID или не выставлено разрешение)",                                                      // 4517
    "Wrong settings of notifications in terminal (ID not specified or permission not set)"
   },
   {"Слишком частая отправка уведомлений","Too frequent sending of notifications"},                                                                // 4518
   {"Не указан FTP сервер","FTP server not specified"},                                                                                         // 4519
   {"Не указан FTP логин","FTP login not specified"},                                                                                           // 4520
   {"Не найден файл в директории MQL5\\Files для отправки на FTP сервер","File not found in MQL5\\Files directory to send on FTP server"},     // 4521
   {"Ошибка при подключении к FTP серверу","FTP connection failed"},                                                                               // 4522
   {"На FTP сервере не найдена директория для выгрузки файла ","FTP path not found on server"},                                                    // 4523
   {"Подключение к FTP серверу закрыто","FTP connection closed"},                                                                                  // 4524
  };
 //+------------------------------------------------------------------+
 //| Array of execution time error messages (4601 - 4603)             |
 //| (Custom indicator buffers and properties)                        |
 //| (1) in user's country language                                   |
 //| (2) in the international language                                |
 //+------------------------------------------------------------------+
 string messages_runtime_custom_indicator[][TOTAL_LANG]=
  {
   {"Недостаточно памяти для распределения индикаторных буферов","Not enough memory for distribution of indicator buffers"},                   // 4601
   {"Ошибочный индекс своего индикаторного буфера","Wrong indicator buffer index"},                                                                // 4602
   {"Ошибочный идентификатор свойства пользовательского индикатора","Wrong ID of custom indicator property"},                                  // 4603
  };
 //+------------------------------------------------------------------+
 //| Array of execution time error messages (4701 - 4758)             |
 //| (Account)                                                        |
 //| (1) in user's country language                                   |
 //| (2) in the international language                                |
 //+------------------------------------------------------------------+
 string messages_runtime_account[][TOTAL_LANG]=
  {
   {"Ошибочный идентификатор свойства счета","Wrong account property ID"},                                                                         // 4701
   
   {"Неизвестный код ошибки (4702)","Unknown error code (4702)"},                                                                         // 4702
   {"Неизвестный код ошибки (4703)","Unknown error code (4703)"},                                                                         // 4703
   {"Неизвестный код ошибки (4704)","Unknown error code (4704)"},                                                                         // 4704
   {"Неизвестный код ошибки (4705)","Unknown error code (4705)"},                                                                         // 4705
   {"Неизвестный код ошибки (4706)","Unknown error code (4706)"},                                                                         // 4706
   {"Неизвестный код ошибки (4707)","Unknown error code (4707)"},                                                                         // 4707
   {"Неизвестный код ошибки (4708)","Unknown error code (4708)"},                                                                         // 4708
   {"Неизвестный код ошибки (4709)","Unknown error code (4709)"},                                                                         // 4709
   {"Неизвестный код ошибки (4710)","Unknown error code (4710)"},                                                                         // 4710
   {"Неизвестный код ошибки (4711)","Unknown error code (4711)"},                                                                         // 4711
   {"Неизвестный код ошибки (4712)","Unknown error code (4712)"},                                                                         // 4712
   {"Неизвестный код ошибки (4713)","Unknown error code (4713)"},                                                                         // 4713
   {"Неизвестный код ошибки (4714)","Unknown error code (4714)"},                                                                         // 4714
   {"Неизвестный код ошибки (4715)","Unknown error code (4715)"},                                                                         // 4715
   {"Неизвестный код ошибки (4716)","Unknown error code (4716)"},                                                                         // 4716
   {"Неизвестный код ошибки (4717)","Unknown error code (4717)"},                                                                         // 4717
   {"Неизвестный код ошибки (4718)","Unknown error code (4718)"},                                                                         // 4718
   {"Неизвестный код ошибки (4719)","Unknown error code (4719)"},                                                                         // 4719
   {"Неизвестный код ошибки (4720)","Unknown error code (4720)"},                                                                         // 4720
   {"Неизвестный код ошибки (4721)","Unknown error code (4721)"},                                                                         // 4721
   {"Неизвестный код ошибки (4722)","Unknown error code (4722)"},                                                                         // 4722
   {"Неизвестный код ошибки (4723)","Unknown error code (4723)"},                                                                         // 4723
   {"Неизвестный код ошибки (4724)","Unknown error code (4724)"},                                                                         // 4724
   {"Неизвестный код ошибки (4725)","Unknown error code (4725)"},                                                                         // 4725
   {"Неизвестный код ошибки (4726)","Unknown error code (4726)"},                                                                         // 4726
   {"Неизвестный код ошибки (4727)","Unknown error code (4727)"},                                                                         // 4727
   {"Неизвестный код ошибки (4728)","Unknown error code (4728)"},                                                                         // 4728
   {"Неизвестный код ошибки (4729)","Unknown error code (4729)"},                                                                         // 4729
   {"Неизвестный код ошибки (4730)","Unknown error code (4730)"},                                                                         // 4730
   {"Неизвестный код ошибки (4731)","Unknown error code (4731)"},                                                                         // 4731
   {"Неизвестный код ошибки (4732)","Unknown error code (4732)"},                                                                         // 4732
   {"Неизвестный код ошибки (4733)","Unknown error code (4733)"},                                                                         // 4733
   {"Неизвестный код ошибки (4734)","Unknown error code (4734)"},                                                                         // 4734
   {"Неизвестный код ошибки (4735)","Unknown error code (4735)"},                                                                         // 4735
   {"Неизвестный код ошибки (4736)","Unknown error code (4736)"},                                                                         // 4736
   {"Неизвестный код ошибки (4737)","Unknown error code (4737)"},                                                                         // 4737
   {"Неизвестный код ошибки (4738)","Unknown error code (4738)"},                                                                         // 4738
   {"Неизвестный код ошибки (4739)","Unknown error code (4739)"},                                                                         // 4739
   {"Неизвестный код ошибки (4740)","Unknown error code (4740)"},                                                                         // 4740
   {"Неизвестный код ошибки (4741)","Unknown error code (4741)"},                                                                         // 4741
   {"Неизвестный код ошибки (4742)","Unknown error code (4742)"},                                                                         // 4742
   {"Неизвестный код ошибки (4743)","Unknown error code (4743)"},                                                                         // 4743
   {"Неизвестный код ошибки (4744)","Unknown error code (4744)"},                                                                         // 4744
   {"Неизвестный код ошибки (4745)","Unknown error code (4745)"},                                                                         // 4745
   {"Неизвестный код ошибки (4746)","Unknown error code (4746)"},                                                                         // 4746
   {"Неизвестный код ошибки (4747)","Unknown error code (4747)"},                                                                         // 4747
   {"Неизвестный код ошибки (4748)","Unknown error code (4748)"},                                                                         // 4748
   {"Неизвестный код ошибки (4749)","Unknown error code (4749)"},                                                                         // 4749
   {"Неизвестный код ошибки (4750)","Unknown error code (4750)"},                                                                         // 4750
   
   {"Ошибочный идентификатор свойства торговли","Wrong trade property ID"},                                                                        // 4751
   {"Торговля для эксперта запрещена","Trading by Expert Advisors prohibited"},                                                                    // 4752
   {"Позиция не найдена","Position not found"},                                                                                                    // 4753
   {"Ордер не найден","Order not found"},                                                                                                          // 4754
   {"Сделка не найдена","Deal not found"},                                                                                                         // 4755
   {"Не удалось отправить торговый запрос","Trade request sending failed"},                                                                        // 4756
   {"Неизвестный код ошибки (4757)","Unknown error code (4757"},                                                                          // 4757
   {"Не удалось вычислить значение прибыли или маржи","Failed to calculate profit or margin"},                                                     // 4758
  };
 //+------------------------------------------------------------------+
 //| Array of execution time error messages (4801 - 4812)             |
 //| (Indicators)                                                     |
 //| (1) in user's country language                                   |
 //| (2) in the international language                                |
 //+------------------------------------------------------------------+
 string messages_runtime_indicator[][TOTAL_LANG]=
  {
   {"Неизвестный символ","Unknown symbol"},                                                                                                        // 4801
   {"Индикатор не может быть создан","Indicator cannot be created"},                                                                               // 4802
   {"Недостаточно памяти для добавления индикатора","Not enough memory to add indicator"},                                                     // 4803
   {"Индикатор не может быть применен к другому индикатору","Indicator cannot be applied to another indicator"},                               // 4804
   {"Ошибка при добавлении индикатора","Error applying indicator to chart"},                                                                    // 4805
   {"Запрошенные данные не найдены","Requested data not found"},                                                                                   // 4806
   {"Ошибочный хэндл индикатора","Wrong indicator handle"},                                                                                        // 4807
   {"Неправильное количество параметров при создании индикатора","Wrong number of parameters when creating indicator"},                         // 4808
   {"Отсутствуют параметры при создании индикатора","No parameters when creating indicator"},                                                   // 4809
   {
    "Первым параметром в массиве должно быть имя пользовательского индикатора",                                                                    // 4810
    "First parameter in array should be name of custom indicator"
   },
   {"Неправильный тип параметра в массиве при создании индикатора","Invalid parameter type in array when creating indicator"},              // 4811
   {"Ошибочный индекс запрашиваемого индикаторного буфера","Wrong index of requested indicator buffer"},                                       // 4812
  };
 //+------------------------------------------------------------------+
 //| Array of execution time error messages (4901 - 4904)             |
 //| (Market depth)                                                   |
 //| (1) in user's country language                                   |
 //| (2) in the international language                                |
 //+------------------------------------------------------------------+
 string messages_runtime_books[][TOTAL_LANG]=
  {
   {"Стакан цен не может быть добавлен","Depth Of Market cannot be added"},                                                                       // 4901
   {"Стакан цен не может быть удален","Depth Of Market cannot be removed"},                                                                       // 4902
   {"Данные стакана цен не могут быть получены","Data from Depth Of Market cannot be obtained"},                                              // 4903
   {"Ошибка при подписке на получение новых данных стакана цен","Error in subscribing to receive new data from Depth Of Market"},                  // 4904
  };
 //+------------------------------------------------------------------+
 //| Array of execution time error messages (5001 - 5027)             |
 //| (File operations)                                                |
 //| (1) in user's country language                                   |
 //| (2) in the international language                                |
 //+------------------------------------------------------------------+
 string messages_runtime_files[][TOTAL_LANG]=
  {
   {"Не может быть открыто одновременно более 64 файлов","More than 64 files cannot be opened at the same time"},                                  // 5001
   {"Недопустимое имя файла","Invalid file name"},                                                                                                 // 5002
   {"Слишком длинное имя файла","Too long file name"},                                                                                             // 5003
   {"Ошибка открытия файла","File opening error"},                                                                                                 // 5004
   {"Недостаточно памяти для кеша чтения","Not enough memory for cache to read"},                                                                  // 5005
   {"Ошибка удаления файла","File deleting error"},                                                                                                // 5006
   {"Файл с таким хэндлом уже был закрыт, либо не открывался вообще","File with this handle was closed or was not opening at all"},             // 5007
   {"Ошибочный хэндл файла","Wrong file handle"},                                                                                                  // 5008
   {"Файл должен быть открыт для записи","File must be opened for writing"},                                                                   // 5009
   {"Файл должен быть открыт для чтения","File must be opened for reading"},                                                                   // 5010
   {"Файл должен быть открыт как бинарный","File must be opened as binary one"},                                                             // 5011
   {"Файл должен быть открыт как текстовый","File must be opened as text"},                                                                  // 5012
   {"Файл должен быть открыт как текстовый или CSV","File must be opened as text or CSV"},                                                   // 5013
   {"Файл должен быть открыт как CSV","File must be opened as CSV"},                                                                           // 5014
   {"Ошибка чтения файла","File reading error"},                                                                                                   // 5015
   {"Должен быть указан размер строки, так как файл открыт как бинарный","String size must be specified, because the file opened as binary"},   // 5016
   {
    "Для строковых массивов должен быть текстовый файл, для остальных – бинарный",                                                                 // 5017
    "Text file must be for string arrays, for other arrays - binary"
   },
   {"Это не файл, а директория","This is not file, this is directory"},                                                                        // 5018
   {"Файл не существует","File does not exist"},                                                                                                   // 5019
   {"Файл не может быть переписан","File cannot be rewritten"},                                                                                   // 5020
   {"Ошибочное имя директории","Wrong directory name"},                                                                                            // 5021
   {"Директория не существует","Directory does not exist"},                                                                                        // 5022
   {"Это файл, а не директория","This is file, not directory"},                                                                                // 5023
   {"Директория не может быть удалена","Directory cannot be removed"},                                                                         // 5024
   {
    "Не удалось очистить директорию (возможно, один или несколько файлов заблокированы)",                                                          // 5025
    "Failed to clear directory (probably one or more files blocked)"
   },
   {"Не удалось записать ресурс в файл","Failed to write resource to file"},                                                                   // 5026
   {
    "Не удалось прочитать следующую порцию данных из CSV-файла, так как достигнут конец файла",                                                    // 5027
    "Unable to read next piece of data from CSV file, since end of file reached"
   },
  };
 //+------------------------------------------------------------------+
 //| Array of execution time error messages (5030 - 5044)             |
 //| (String conversion)                                              |
 //| (1) in user's country language                                   |
 //| (2) in the international language                                |
 //+------------------------------------------------------------------+
 string messages_runtime_string[][TOTAL_LANG]=
  {
   {"В строке нет даты","No date in string"},                                                                                                  // 5030
   {"В строке ошибочная дата","Wrong date in string"},                                                                                         // 5031
   {"В строке ошибочное время","Wrong time in string"},                                                                                        // 5032
   {"Ошибка преобразования строки в дату","Error converting string to date"},                                                                      // 5033
   {"Недостаточно памяти для строки","Not enough memory for string"},                                                                          // 5034
   {"Длина строки меньше, чем ожидалось","String length less than expected"},                                                               // 5035
   {"Слишком большое число, больше, чем ULONG_MAX","Too large number, more than ULONG_MAX"},                                                       // 5036
   {"Ошибочная форматная строка","Invalid format string"},                                                                                         // 5037
   {"Форматных спецификаторов больше, чем параметров","Amount of format specifiers more than parameters"},                                     // 5038
   {"Параметров больше, чем форматных спецификаторов","Amount of parameters more than format specifiers"},                                     // 5039
   {"Испорченный параметр типа string","Damaged parameter of string type"},                                                                        // 5040
   {"Позиция за пределами строки","Position outside string"},                                                                                  // 5041
   {"К концу строки добавлен 0, бесполезная операция","0 added to string end, useless operation"},                                           // 5042
   {"Неизвестный тип данных при конвертации в строку","Unknown data type when converting to string"},                                            // 5043
   {"Испорченный объект строки","Damaged string object"},                                                                                          // 5044
  };
 //+------------------------------------------------------------------+
 //| Array of execution time error messages (5050 - 5063)             |
 //| (Working with arrays)                                            |
 //| (1) in user's country language                                   |
 //| (2) in the international language                                |
 //+------------------------------------------------------------------+
 string messages_runtime_array[][TOTAL_LANG]=
  {
   {"Копирование несовместимых массивов","Copying incompatible arrays"},                                                                           // 5050
   {
    "Приемный массив объявлен как AS_SERIES, и он недостаточного размера",                                                                         // 5051
    "Receiving array declared as AS_SERIES, and it is of insufficient size"
   },
   {"Слишком маленький массив, стартовая позиция за пределами массива","Too small array, starting position outside the array"},             // 5052
   {"Массив нулевой длины","Array of zero length"},                                                                                             // 5053
   {"Должен быть числовой массив","Must be numeric array"},                                                                                      // 5054
   {"Должен быть одномерный массив","Must be one-dimensional array"},                                                                            // 5055
   {"Таймсерия не может быть использована","Timeseries cannot be used"},                                                                           // 5056
   {"Должен быть массив типа double","Must be array of double type"},                                                                           // 5057
   {"Должен быть массив типа float","Must be array of float type"},                                                                             // 5058
   {"Должен быть массив типа long","Must be array of long type"},                                                                               // 5059
   {"Должен быть массив типа int","Must be array of int type"},                                                                                 // 5060
   {"Должен быть массив типа short","Must be array of short type"},                                                                             // 5061
   {"Должен быть массив типа char","Must be array of char type"},                                                                               // 5062
   {"Должен быть массив типа string","String array only"},                                                                                         // 5063
  };
 //+------------------------------------------------------------------+
 //| Array of execution time error messages (5100 - 5114)             |
 //| (Working with OpenCL)                                            |
 //| (1) in user's country language                                   |
 //| (2) in the international language                                |
 //+------------------------------------------------------------------+
 string messages_runtime_opencl[][TOTAL_LANG]=
  {
   {"Функции OpenCL на данном компьютере не поддерживаются","OpenCL functions not supported on this computer"},                                // 5100
   {"Внутренняя ошибка при выполнении OpenCL","Internal error occurred when running OpenCL"},                                                      // 5101
   {"Неправильный хэндл OpenCL","Invalid OpenCL handle"},                                                                                          // 5102
   {"Ошибка при создании контекста OpenCL","Error creating OpenCL context"},                                                                   // 5103
   {"Ошибка создания очереди выполнения в OpenCL","Failed to create run queue in OpenCL"},                                                       // 5104
   {"Ошибка при компиляции программы OpenCL","Error occurred when compiling OpenCL program"},                                                   // 5105
   {"Слишком длинное имя точки входа (кернел OpenCL)","Too long kernel name (OpenCL kernel)"},                                                     // 5106
   {"Ошибка создания кернел - точки входа OpenCL","Error creating OpenCL kernel"},                                                              // 5107
   {
    "Ошибка при установке параметров для кернел OpenCL (точки входа в программу OpenCL)",                                                          // 5108
    "Error occurred when setting parameters for OpenCL kernel"
   },
   {"Ошибка выполнения программы OpenCL","OpenCL program runtime error"},                                                                          // 5109
   {"Неверный размер буфера OpenCL","Invalid size of OpenCL buffer"},                                                                          // 5110
   {"Неверное смещение в буфере OpenCL","Invalid offset in OpenCL buffer"},                                                                    // 5111
   {"Ошибка создания буфера OpenCL","Failed to create OpenCL buffer"},                                                                          // 5112
   {"Превышено максимальное число OpenCL объектов","Too many OpenCL objects"},                                                                     // 5113
   {"Ошибка выбора OpenCL устройства","OpenCL device selection error"},                                                                            // 5114
  };
 //+------------------------------------------------------------------+
 //| Array of execution time error messages  (5120 - 5130)            |
 //| (Working with databases)                                         |
 //| (1) in user's country language                                   |
 //| (2) in the international language                                |
 //+------------------------------------------------------------------+
 string messages_runtime_database[][TOTAL_LANG]=
  {
   {"Внутренняя ошибка базы данных","Internal database error"},                                                                                    // 5120
   {"Невалидный хендл базы данных","Invalid database handle"},                                                                                     // 5121
   {"Превышено максимально допустимое количество объектов Database","Exceeded the maximum acceptable number of Database objects"},                 // 5122
   {"Ошибка подключения к базе данных","Database connection error"},                                                                               // 5123
   {"Ошибка выполнения запроса","Request execution error"},                                                                                        // 5124
   {"Ошибка создания запроса","Request generation error"},                                                                                         // 5125
   {"Данных для чтения больше нет","No more data to read"},                                                                                        // 5126
   {"Ошибка перехода к следующей записи запроса","Failed to move to the next request entry"},                                                      // 5127
   {"Данные для чтения результатов запроса еще не готовы","Data for reading request results are not ready yet"},                                   // 5128
   {"Ошибка автоподстановки параметров в SQL-запрос","Failed to auto substitute parameters to an SQL request"},                                    // 5129
   {"Запрос базы данных не только для чтения","Database query not read only"},                                                                     // 5130
  };
 //+------------------------------------------------------------------+
 //| Array of execution time error messages (5200 - 5203)             |
 //| (Working with WebRequest())                                      |
 //| (1) in user's country language                                   |
 //| (2) in the international language                                |
 //+------------------------------------------------------------------+
 string messages_runtime_webrequest[][TOTAL_LANG]=
  {
   {"URL не прошел проверку","Invalid URL"},                                                                                                       // 5200
   {"Не удалось подключиться к указанному URL","Failed to connect to specified URL"},                                                              // 5201
   {"Превышен таймаут получения данных","Timeout exceeded"},                                                                                       // 5202
   {"Ошибка в результате выполнения HTTP запроса","HTTP request failed"},                                                                          // 5203
  };
 //+------------------------------------------------------------------+
 //| Array of execution time error messages (5270 - 5275)             |
 //| (Working with network (sockets))                                 |
 //| (1) in user's country language                                   |
 //| (2) in the international language                                |
 //+------------------------------------------------------------------+
 string messages_runtime_netsocket[][TOTAL_LANG]=
  {
   {"В функцию передан неверный хэндл сокета","Invalid socket handle passed to function"},                                                         // 5270
   {"Открыто слишком много сокетов (максимум 128)","Too many open sockets (max 128)"},                                                             // 5271
   {"Ошибка соединения с удаленным хостом","Failed to connect to remote host"},                                                                    // 5272
   {"Ошибка отправки/получения данных из сокета","Failed to send/receive data from socket"},                                                       // 5273
   {"Ошибка установления защищенного соединения (TLS Handshake)","Failed to establish secure connection (TLS Handshake)"},                         // 5274
   {"Отсутствуют данные о сертификате, которым защищено подключение","No data on certificate protecting connection"},                          // 5275
  };
 //+------------------------------------------------------------------+
 //| Array of execution time error messages (5300 - 5310)             |
 //| (Custom symbols)                                                 |
 //| (1) in user's country language                                   |
 //| (2) in the international language                                |
 //+------------------------------------------------------------------+
 string messages_runtime_custom_symbol[][TOTAL_LANG]=
  {
   {"Должен быть указан пользовательский символ","Custom symbol must be specified"},                                                             // 5300
   {"Некорректное имя пользовательского символа","Name of custom symbol invalid"},                                                      // 5301
   {"Слишком длинное имя для пользовательского символа","Name of custom symbol too long"},                                              // 5302
   {"Слишком длинный путь для пользовательского символа","Path of custom symbol too long"},                                             // 5303
   {"Пользовательский символ с таким именем уже существует","Custom symbol with the same name already exists"},                                  // 5304
   {
    "Ошибка при создании, удалении или изменении пользовательского символа",                                                                       // 5305
    "Error occurred while creating, deleting or changing custom symbol"
   },
   {"Попытка удалить пользовательский символ, выбранный в обзоре рынка","You are trying to delete custom symbol selected in Market Watch"},      // 5306
   {"Неправильное свойство пользовательского символа","Invalid custom symbol property"},                                                        // 5307
   {"Ошибочный параметр при установке свойства пользовательского символа","Wrong parameter while setting property of custom symbol"},      // 5308
   {
    "Слишком длинный строковый параметр при установке свойства пользовательского символа",                                                         // 5309
    "Too long string parameter while setting property of custom symbol"
   },
   {"Не упорядоченный по времени массив тиков","Ticks in array not arranged in order of time"},                                        // 5310
  };
 //+------------------------------------------------------------------+
 //| Array of execution time error messages (5400 - 5402)             |
 //| (Economic calendar)                                              |
 //| (1) in user's country language                                   |
 //| (2) in the international language                                |
 //+------------------------------------------------------------------+
 string messages_runtime_calendar[][TOTAL_LANG]=
  {
   {"Размер массива недостаточен для получения описаний всех значений","Array size insufficient for receiving descriptions of all values"},     // 5400
   {"Превышен лимит запроса по времени","Request time limit exceeded"},                                                                            // 5401
   {"Страна не найдена","Country not found"},                                                                                                   // 5402
  };
 //+------------------------------------------------------------------+
 //| Array of execution time error messages  (5601 - 5626)            |
 //| (Working with databases)                                         |
 //| (1) in user's country language                                   |
 //| (2) in the international language                                |
 //+------------------------------------------------------------------+
 string messages_runtime_sqlite[][TOTAL_LANG]=
  {
   {"Общая ошибка","Generic error"},                                                                                                               // 5601
   {"Внутренняя логическая ошибка в SQLite","SQLite internal logic error"},                                                                        // 5602
   {"Отказано в доступе","Access denied"},                                                                                                         // 5603
   {"Процедура обратного вызова запросила прерывание","Callback routine requested abort"},                                                         // 5604
   {"Файл базы данных заблокирован","Database file locked"},                                                                                       // 5605
   {"Таблица в базе данных заблокирована ","Database table locked"},                                                                               // 5606
   {"Сбой malloc()","Insufficient memory for completing operation"},                                                                               // 5607
   {"Попытка записи в базу данных, доступной только для чтения ","Attempt to write to readonly database"},                                         // 5608
   {"Операция прекращена с помощью sqlite3_interrupt() ","Operation terminated by sqlite3_interrupt()"},                                           // 5609
   {"Ошибка дискового ввода-вывода","Disk I/O error"},                                                                                             // 5610
   {"Образ диска базы данных испорчен","Database disk image corrupted"},                                                                           // 5611
   {"Неизвестный код операции в sqlite3_file_control()","Unknown operation code in sqlite3_file_control()"},                                       // 5612
   {"Ошибка вставки, так как база данных заполнена ","Insertion failed because database is full"},                                                 // 5613
   {"Невозможно открыть файл базы данных","Unable to open the database file"},                                                                     // 5614
   {"Ошибка протокола блокировки базы данных ","Database lock protocol error"},                                                                    // 5615
   {"Только для внутреннего использования","Internal use only"},                                                                                   // 5616
   {"Схема базы данных изменена","Database schema changed"},                                                                                       // 5617
   {"Строка или BLOB превышает ограничение по размеру","String or BLOB exceeds size limit"},                                                       // 5618
   {"Прервано из-за нарушения ограничения","Abort due to constraint violation"},                                                                   // 5619
   {"Несоответствие типов данных","Data type mismatch"},                                                                                           // 5620
   {"Ошибка неправильного использования библиотеки","Library used incorrectly"},                                                                   // 5621
   {"Использование функций операционной системы, не поддерживаемых на хосте","Uses OS features not supported on host"},                            // 5622
   {"Отказано в авторизации","Authorization denied"},                                                                                              // 5623
   {"Не используется ","Not used "},                                                                                                               // 5624
   {"2-й параметр для sqlite3_bind находится вне диапазона","Bind parameter error, incorrect index"},                                              // 5625
   {"Открытый файл не является файлом базы данных","File opened that is not database file"},                                                       // 5626
  };
 //+------------------------------------------------------------------+
 //| Array of execution time error messages  (5700 - 5706)            |
 //| (Matrix and vector methods)                                      |
 //| (1) in user's country language                                   |
 //| (2) in the international language                                |
 //+------------------------------------------------------------------+
 string messages_runtime_matrix_vector[][TOTAL_LANG]=
  {
   {"Внутренняя ошибка исполняющей подсистемы матриц/векторов","Internal error of the matrix/vector executing subsystem"},                         // 5700
   {"Матрица/вектор не инициализирован","Matrix/vector not initialized"},                                                                          // 5701
   {"Несогласованный размер матриц/векторов в операции","Inconsistent size of matrices/vectors in operation"},                                     // 5702
   {"Некорректный размер матрицы/вектора","Invalid matrix/vector size"},                                                                           // 5703
   {"Некорректный тип матрицы/вектора","Invalid matrix/vector type"},                                                                              // 5704
   {"Функция недоступна для данной матрицы/вектора","Function not available for this matrix/vector"},                                              // 5705
   {"Матрица/вектор содержит нечисла (Nan/Inf)","Matrix/vector contains non-numbers (Nan/Inf)"},                                                   // 5706
  };  
 //+------------------------------------------------------------------+
 //| Array of execution time error messages  (5800 - 5808)            |
 //| (ONNX models)                                                    |
 //| (1) in user's country language                                   |
 //| (2) in the international language                                |
 //+------------------------------------------------------------------+
 string messages_runtime_onnx[][TOTAL_LANG]=
  {
   {"Внутренняя ошибка ONNX стандарта","ONNX internal error"},                                                                                     // 5800
   {"Ошибка инициализации ONNX Runtime API","ONNX Runtime API initialization error"},                                                              // 5801
   {"Свойство или значение неподдерживаются языком MQL5","Property or value not supported by MQL5"},                                               // 5802
   {"Ошибка запуска ONNX runtime API","ONNX runtime API run error"},                                                                               // 5803
   {"В OnnxRun передано неверное количество параметров ","Invalid number of parameters passed to OnnxRun"},                                        // 5804
   {"Некорректное значение параметра","Invalid parameter value"},                                                                                  // 5805
   {"Некорректный тип параметра","Invalid parameter type"},                                                                                        // 5806
   {"Некорректный размер параметра","Invalid parameter size"},                                                                                     // 5807
   {"Размерность тензора не задана или указана неверно","Tensor dimension not set or invalid"},                                                    // 5808
  };  
 //+------------------------------------------------------------------+
//| Array of predefined library messages                             |
//| (1) in user's country language                                   |
//| (2) in the international language (English)                      |
//| (3) any additional language.                                     |
//|  The default languages are English and Russian.                  |
//|  To add the necessary number of other languages, simply          |
//|  set the total number of used languages in TOTAL_LANG            |
//|  and add the necessary translation after the English text        |
//+------------------------------------------------------------------+
 string messages_library[][TOTAL_LANG]=
  {
   {"Начало списка параметров","The beginning of the parameter list"},  // MSG_LIB_PARAMS_LIST_BEG
   {"Ошибка ","Error "},  // MSG_LIB_SYS_ERROR
   {"Код возврата вне заданного диапазона кодов ошибок","Return code out of range of error codes"},  // MSG_LIB_SYS_ERROR_CODE_OUT_OF_RANGE
   {"В терминале нет разрешения на отправку e-mail","Terminal does not have permission to send e-mail"},  // MSG_LIB_TEXT_TERMINAL_NOT_MAIL_ENABLED
   {"В терминале нет разрешения на отправку Push-уведомлений","Terminal does not have permission to send push notifications"},  // MSG_LIB_TEXT_TERMINAL_NOT_PUSH_ENABLED
   {"В терминале нет разрешения на отправку файлов на FTP-адрес","Terminal does not have permission to send files to FTP address"},  // MSG_LIB_TEXT_TERMINAL_NOT_FTP_ENABLED
   {"Неизвестный таймфрейм","Unknown timeframe"},  // MSG_LIB_TEXT_TS_TEXT_UNKNOWN_TIMEFRAME
   {"Не удалось найти подокно графика","Could not find chart subwindow"},  // MSG_GRAPH_STD_OBJ_ERR_NOT_FIND_SUBWINDOW
  };
 //+------------------------------------------------------------------+
 string messages_ts_ret_code[][TOTAL_LANG]=
  {
   {"Реквота","Requote"},                                                                                                                          // 10004
   {"Неизвестный код возврата торгового сервера","Unknown trading server return code"},                                                   // 10005
   {"Запрос отклонен","Request rejected"},                                                                                                         // 10006
   {"Запрос отменен трейдером","Request canceled by trader"},                                                                                      // 10007
   {"Ордер размещен","Order placed"},                                                                                                              // 10008
   {"Заявка выполнена","Request completed"},                                                                                                       // 10009
   {"Заявка выполнена частично","Only part of the request completed"},                                                                         // 10010
   {"Ошибка обработки запроса","Request processing error"},                                                                                        // 10011
   {"Запрос отменен по истечению времени","Request canceled by timeout"},                                                                          // 10012
   {"Неправильный запрос","Invalid request"},                                                                                                      // 10013
   {"Неправильный объем в запросе","Invalid volume in request"},                                                                               // 10014
   {"Неправильная цена в запросе","Invalid price in request"},                                                                                 // 10015
   {"Неправильные стопы в запросе","Invalid stops in request"},                                                                                // 10016
   {"Торговля запрещена","Trade disabled"},                                                                                                     // 10017
   {"Рынок закрыт","Market closed"},                                                                                                            // 10018
   {"Нет достаточных денежных средств для выполнения запроса","There is not enough money to complete request"},                                // 10019
   {"Цены изменились","Prices changed"},                                                                                                           // 10020
   {"Отсутствуют котировки для обработки запроса","There are no quotes to process request"},                                                   // 10021
   {"Неверная дата истечения ордера в запросе","Invalid order expiration date in request"},                                                    // 10022
   {"Состояние ордера изменилось","Order state changed"},                                                                                          // 10023
   {"Слишком частые запросы","Too frequent requests"},                                                                                             // 10024
   {"В запросе нет изменений","No changes in request"},                                                                                            // 10025
   {"Автотрейдинг запрещен сервером","Autotrading disabled by server"},                                                                            // 10026
   {"Автотрейдинг запрещен клиентским терминалом","Autotrading disabled by client terminal"},                                                      // 10027
   {"Запрос заблокирован для обработки","Request locked for processing"},                                                                          // 10028
   {"Ордер или позиция заморожены","Order or position frozen"},                                                                                    // 10029
   {"Указан неподдерживаемый тип исполнения ордера по остатку","Invalid order filling type"},                                                      // 10030
   {"Нет соединения с торговым сервером","No connection with trade server"},                                                                   // 10031
   {"Операция разрешена только для реальных счетов","Operation allowed only for live accounts"},                                                // 10032
   {"Достигнут лимит на количество отложенных ордеров","Number of pending orders reached limit"},                                      // 10033
   {"Достигнут лимит на объем ордеров и позиций для данного символа","Volume of orders and positions for symbol reached limit"},   // 10034
   {"Неверный или запрещённый тип ордера","Incorrect or prohibited order type"},                                                                   // 10035
   {"Позиция с указанным идентификатором уже закрыта","Position with specified identifier already closed"},                           // 10036
   {"Неизвестный код возврата торгового сервера","Unknown trading server return code"},                                                   // 10037
   {"Закрываемый объем превышает текущий объем позиции","Close volume exceeds the current position volume"},                                     // 10038
   {"Для указанной позиции уже есть ордер на закрытие","Close order already exists for specified position"},                                   // 10039
   {"Достигнут лимит на количество открытых позиций","Number of positions reached limit"},                                             // 10040
   {
    "Запрос на активацию отложенного ордера отклонен, а сам ордер отменен",                                                                        // 10041
    "Pending order activation request rejected, order canceled"
   },
   {
    "Запрос отклонен, так как на символе установлено правило \"Разрешены только длинные позиции\"",                                                // 10042
    "Request rejected, because \"Only long positions are allowed\" rule set for symbol"
   },
   {
    "Запрос отклонен, так как на символе установлено правило \"Разрешены только короткие позиции\"",                                               // 10043
    "Request rejected, because \"Only short positions are allowed\" rule set for symbol"
   },
   {
    "Запрос отклонен, так как на символе установлено правило \"Разрешено только закрывать существующие позиции\"",                                 // 10044
    "Request rejected because \"Only position closing is allowed\" rule set for symbol"
   },
   {
    "Запрос отклонен, так как для торгового счета установлено правило \"Разрешено закрывать существующие позиции только по правилу FIFO\"",        // 10045
    "Request rejected, because \"Position closing is allowed only by FIFO rule\" flag set for trading account"
   },
   {
    "Запрос отклонен, так как для торгового счета установлено правило \"Запрещено открывать встречные позиции по одному символу\"",                // 10046
    "The request is rejected, because the \"Opposite positions on a single symbol are disabled\" rule is set for the trading account"
   },
  };
 #ifdef __MQL4__
  //+------------------------------------------------------------------+
  //| Array of messages for MQL4 trade server return codes (0 - 150)   |
  //| (1) in user's country language                                   |
  //| (2) in the international language                                |
  //+------------------------------------------------------------------+
  string messages_ts_ret_code_mql4[][TOTAL_LANG]=
    {
     {"Нет ошибки","No error returned"},                                                             // 0
     {"Нет ошибки, но результат неизвестен","No error returned, but result unknown"},         // 1
     {"Общая ошибка","Common error"},                                                                // 2
     {"Неправильные параметры","Invalid trade parameters"},                                          // 3
     {"Торговый сервер занят","Trade server busy"},                                               // 4
     {"Старая версия клиентского терминала","Old version of client terminal"},                   // 5
     {"Нет связи с торговым сервером","No connection with trade server"},                            // 6
     {"Недостаточно прав","Not enough rights"},                                                      // 7
     {"Слишком частые запросы","Too frequent requests"},                                             // 8
     {"Недопустимая операция, нарушающая функционирование сервера","Malfunctional trade operation"}, // 9
     
     {"Счет заблокирован","Account disabled"},                                                       // 64
     {"Неправильный номер счета","Invalid account"},                                                 // 65
   
     {"Истек срок ожидания совершения сделки","Trade timeout"},                                      // 128
     {"Неправильная цена","Invalid price"},                                                          // 129
     {"Неправильные стопы","Invalid stops"},                                                         // 130
     {"Неправильный объем","Invalid trade volume"},                                                  // 131
     {"Рынок закрыт","Market closed"},                                                            // 132
     {"Торговля запрещена","Trade disabled"},                                                     // 133
     {"Недостаточно денег для совершения операции","Not enough money"},                              // 134
     {"Цена изменилась","Price changed"},                                                            // 135
     {"Нет цен","Off quotes"},                                                                       // 136
     {"Брокер занят","Broker busy"},                                                              // 137
     {"Новые цены","Requote"},                                                                       // 138
     {"Ордер заблокирован и уже обрабатывается","Order locked"},                                  // 139
     {"Разрешена только покупка","Buy orders only allowed"},                                         // 140
     {"Слишком много запросов","Too many requests"},                                                 // 141
     {"Неизвестный код возврата торгового сервера","Unknown trading server return code"},     // 142
     {"Неизвестный код возврата торгового сервера","Unknown trading server return code"},     // 143
     {"Неизвестный код возврата торгового сервера","Unknown trading server return code"},     // 144
     {
      "Модификация запрещена, так как ордер слишком близок к рынку",                                 // 145
      "Modification denied because order too close to market"
     }, 
     {"Подсистема торговли занята","Trade context busy"},     // 146
     {"Использование даты истечения ордера запрещено брокером","Expirations denied by broker"},  // 147
     {
      "Количество открытых и отложенных ордеров достигло предела, установленного брокером",          // 148
      "Amount of open and pending orders reached limit set by broker"
     },
     {
      "Попытка открыть противоположный ордер в случае, если хеджирование запрещено",                 // 149
      "Attempt to open order opposite to existing one when hedging disabled"
     },
     {
      "Попытка закрыть позицию по инструменту в противоречии с правилом FIFO",                       // 150
      "Attempt to close order contravening FIFO rule"
     },
    };
  //+------------------------------------------------------------------+
  //| Array of MQL4 execution time error messages (4000 - 4030)        |
  //| (1) in user's country language                                   |
  //| (2) in the international language                                |
  //+------------------------------------------------------------------+
  string messages_runtime_4000_4030[][TOTAL_LANG]=
  {
   {"Нет ошибки","No error returned"},                                                             // 4000
   {"Неправильный указатель функции","Wrong function pointer"},                                    // 4001
   {"Индекс массива - вне диапазона","Array index out of range"},                               // 4002
   {"Нет памяти для стека функций","No memory for function call stack"},                           // 4003
   {"Переполнение стека после рекурсивного вызова","Recursive stack overflow"},                    // 4004
   {"На стеке нет памяти для передачи параметров","Not enough stack for parameter"},               // 4005
   {"Нет памяти для строкового параметра","No memory for parameter string"},                       // 4006
   {"Нет памяти для временной строки","No memory for temp string"},                                // 4007
   {"Неинициализированная строка","Not initialized string"},                                       // 4008
   {"Неинициализированная строка в массиве","Not initialized string in array"},                    // 4009
   {"Нет памяти для строкового массива","No memory for array string"},                             // 4010
   {"Слишком длинная строка","Too long string"},                                                   // 4011
   {"Остаток от деления на ноль","Remainder from zero divide"},                                    // 4012
   {"Деление на ноль","Zero divide"},                                                              // 4013
   {"Неизвестная команда","Unknown command"},                                                      // 4014
   {"Неправильный переход","Wrong jump (never generated error)"},                                  // 4015
   {"Неинициализированный массив","Not initialized array"},                                        // 4016
   {"Вызовы DLL не разрешены","DLL calls not allowed"},                                        // 4017
   {"Невозможно загрузить библиотеку","Cannot load library"},                                      // 4018
   {"Невозможно вызвать функцию","Cannot call function"},                                          // 4019
   {"Вызовы внешних библиотечных функций не разрешены","Expert function calls not allowed"},   // 4020
   {
    "Недостаточно памяти для строки, возвращаемой из функции",                                     // 4021
    "Not enough memory for temp string returned from function"
   },
   {"Система занята","System busy (never generated error)"},                                    // 4022
   {"Критическая ошибка вызова DLL-функции","DLL function call critical error"},                   // 4023
   {"Внутренняя ошибка","Internal error"},                                                         // 4024
   {"Нет памяти","Out of memory"},                                                                 // 4025
   {"Неверный указатель","Invalid pointer"},                                                       // 4026
   {
    "Слишком много параметров форматирования строки",                                              // 4027
    "Too many formatters in format function"
   },
   {
    "Число параметров превышает число параметров форматирования строки",                           // 4028
    "Parameters count exceeds formatters count"
   },
   {"Неверный массив","Invalid array"},                                                            // 4029
   {"График не отвечает","No reply from chart"},                                                   // 4030
  };
  //+------------------------------------------------------------------+
  //| Array of MQL4 execution time error messages (4050 - 4075)        |
  //| (1) in user's country language                                   |
  //| (2) in the international language                                |
  //+------------------------------------------------------------------+
  string messages_runtime_4050_4075[][TOTAL_LANG]=
  {
   {"Неправильное количество параметров функции","Invalid function parameters count"},             // 4050
   {"Недопустимое значение параметра функции","Invalid function parameter value"},                 // 4051
   {"Внутренняя ошибка строковой функции","String function internal error"},                       // 4052
   {"Ошибка массива","Some array error"},                                                          // 4053
   {"Неправильное использование массива-таймсерии","Incorrect series array using"},                // 4054
   {"Ошибка пользовательского индикатора","Custom indicator error"},                               // 4055
   {"Массивы несовместимы","Arrays incompatible"},                                             // 4056
   {"Ошибка обработки глобальных переменных","Global variables processing error"},                 // 4057
   {"Глобальная переменная не обнаружена","Global variable not found"},                            // 4058
   {"Функция не разрешена в тестовом режиме","Function not allowed in testing mode"},           // 4059
   {"Функция не разрешена","Function not allowed for call"},                                    // 4060
   {"Ошибка отправки почты","Send mail error"},                                                    // 4061
   {"Ожидается параметр типа string","String parameter expected"},                                 // 4062
   {"Ожидается параметр типа integer","Integer parameter expected"},                               // 4063
   {"Ожидается параметр типа double","Double parameter expected"},                                 // 4064
   {"В качестве параметра ожидается массив","Array as parameter expected"},                        // 4065
   {
    "Запрошенные исторические данные в состоянии обновления",                                      // 4066
    "Requested history data in updating state"
   },
   {"Ошибка при выполнении торговой операции","Internal trade error"},                             // 4067
   {"Ресурс не найден","Resource not found"},                                                      // 4068
   {"Ресурс не поддерживается","Resource not supported"},                                          // 4069
   {"Дубликат ресурса","Duplicate resource"},                                                      // 4070
   {"Ошибка инициализации пользовательского индикатора","Custom indicator cannot initialize"},     // 4071
   {"Ошибка загрузки пользовательского индикатора","Cannot load custom indicator"},                // 4072
   {"Нет исторических данных","No history data"},                                                  // 4073
   {"Не хватает памяти для исторических данных","No memory for history data"},                     // 4074
   {"Не хватает памяти для расчёта индикатора","Not enough memory for indicator calculation"},     // 4075
  };
  //+------------------------------------------------------------------+
  //| Array of MQL4 execution time error messages (4099 - 4112)        |
  //| (1) in user's country language                                   |
  //| (2) in the international language                                |
  //+------------------------------------------------------------------+
  string messages_runtime_4099_4112[][TOTAL_LANG]=
  {
   {"Конец файла","End of file"},                                                                  // 4099
   {"Ошибка при работе с файлом","Some file error"},                                               // 4100
   {"Неправильное имя файла","Wrong file name"},                                                   // 4101
   {"Слишком много открытых файлов","Too many opened files"},                                      // 4102
   {"Невозможно открыть файл","Cannot open file"},                                                 // 4103
   {"Несовместимый режим доступа к файлу","Incompatible access to file"},                        // 4104
   {"Ни один ордер не выбран","No order selected"},                                                // 4105
   {"Неизвестный символ","Unknown symbol"},                                                        // 4106
   {"Неправильный параметр цены для торговой функции","Invalid price"},                            // 4107
   {"Неверный номер тикета","Invalid ticket"},                                                     // 4108
   {
    "Торговля не разрешена. Необходимо включить опцию \"Разрешить советнику торговать\" в свойствах эксперта", // 4109
    "Trading not allowed. Enable \"Allow live trading\" checkbox in Expert Advisor properties"
   },
   {
    "Ордера на покупку не разрешены. Необходимо проверить свойства эксперта",                      // 4110
    "Longs not allowed. Check Expert Advisor properties"
   },
   {
    "Ордера на продажу не разрешены. Необходимо проверить свойства эксперта",                      // 4111
    "Shorts not allowed. Check Expert Advisor properties"
   },
   {
    "Автоматическая торговля с помощью экспертов/скриптов запрещена на стороне сервера",           // 4112
    "Automated trading by Expert Advisors/Scripts disabled by trade server"
   },
  };
  //+------------------------------------------------------------------+
  //| Array of MQL4 execution time error messages (4200 - 4220)        |
  //| (1) in user's country language                                   |
  //| (2) in the international language                                |
  //+------------------------------------------------------------------+
  string messages_runtime_4200_4220[][TOTAL_LANG]=
  {
   {"Объект уже существует","Object already exists"},                                              // 4200
   {"Запрошено неизвестное свойство объекта","Unknown object property"},                           // 4201
   {"Объект не существует","Object does not exist"},                                               // 4202
   {"Неизвестный тип объекта","Unknown object type"},                                              // 4203
   {"Нет имени объекта","No object name"},                                                         // 4204
   {"Ошибка координат объекта","Object coordinates error"},                                        // 4205
   {"Не найдено указанное подокно","No specified subwindow"},                                      // 4206
   {"Ошибка при работе с объектом","Graphical object error"},                                      // 4207
   {"Неизвестный код ошибки","Unknown error code"},                                       // 4208
   {"Неизвестный код ошибки","Unknown error code"},                                       // 4209
   {"Неизвестное свойство графика","Unknown chart property"},                                      // 4210
   {"График не найден","Chart not found"},                                                         // 4211
   {"Не найдено подокно графика","Chart subwindow not found"},                                     // 4212
   {"Индикатор не найден","Chart indicator not found"},                                            // 4213
   {"Неизвестный код ошибки","Unknown error code"},                                       // 4214
   {"Неизвестный код ошибки","Unknown error code"},                                       // 4215
   {"Неизвестный код ошибки","Unknown error code"},                                       // 4216
   {"Неизвестный код ошибки","Unknown error code"},                                       // 4217
   {"Неизвестный код ошибки","Unknown error code"},                                       // 4218
   {"Неизвестный код ошибки","Unknown error code"},                                       // 4219
   {"Ошибка выбора инструмента","Symbol select error"},                                            // 4220
  };
  //+------------------------------------------------------------------+
  //| Array of MQL4 execution time error messages (4250 - 4266)        |
  //| (1) in user's country language                                   |
  //| (2) in the international language                                |
  //+------------------------------------------------------------------+
  string messages_runtime_4250_4266[][TOTAL_LANG]=
  {
   {"Ошибка отправки push-уведомления","Notification error"},                                      // 4250
   {"Ошибка параметров push-уведомления","Notification parameter error"},                          // 4251
   {"Уведомления запрещены","Notifications disabled"},                                             // 4252
   {"Слишком частые запросы отсылки push-уведомлений","Notification send too frequent"},           // 4253
   {"Неизвестный код ошибки","Unknown error code"},                                       // 4254
   {"Неизвестный код ошибки","Unknown error code"},                                       // 4255
   {"Неизвестный код ошибки","Unknown error code"},                                       // 4256
   {"Неизвестный код ошибки","Unknown error code"},                                       // 4257
   {"Неизвестный код ошибки","Unknown error code"},                                       // 4258
   {"Неизвестный код ошибки","Unknown error code"},                                       // 4259
   {"Не указан FTP сервер","FTP server not specified"},                                         // 4260
   {"Не указан FTP логин","FTP login not specified"},                                           // 4261
   {"Ошибка при подключении к FTP серверу","FTP connection failed"},                               // 4262
   {"Подключение к FTP серверу закрыто","FTP connection closed"},                                  // 4263
   {"На FTP сервере не найдена директория для выгрузки файла ","FTP path not found on server"},    // 4264
   {
    "Не найден файл в директории MQL4\\Files для отправки на FTP сервер",                          // 4265
    "File not found in MQL4\\Files directory to send to FTP server"
   }, 
   {"Ошибка при передаче файла на FTP сервер","Common error during FTP data transmission"},        // 4266
  };
  //+------------------------------------------------------------------+
  //| Array of MQL4 execution time error messages (5001 - 5029)        |
  //| (1) in user's country language                                   |
  //| (2) in the international language                                |
  //+------------------------------------------------------------------+
  string messages_runtime_5001_5029[][TOTAL_LANG]=
  {
   {"Слишком много открытых файлов","Too many opened files"},                                      // 5001
   {"Неверное имя файла","Wrong file name"},                                                       // 5002
   {"Слишком длинное имя файла","Too long file name"},                                             // 5003
   {"Ошибка открытия файла","Cannot open file"},                                                   // 5004
   {"Ошибка размещения буфера текстового файла","Text file buffer allocation error"},              // 5005
   {"Ошибка удаления файла","Cannot delete file"},                                                 // 5006
   {
    "Неверный хендл файла (файл закрыт или не был открыт)",                                        // 5007
    "Invalid file handle (file closed or not opened)"
   },
   {
    "Неверный хендл файла (индекс хендла отсутствует в таблице)",                                  // 5008
    "Wrong file handle (handle index out of handle table)"
   },
   {"Файл должен быть открыт с флагом FILE_WRITE","File must be opened with FILE_WRITE flag"},     // 5009
   {"Файл должен быть открыт с флагом FILE_READ","File must be opened with FILE_READ flag"},       // 5010
   {"Файл должен быть открыт с флагом FILE_BIN","File must be opened with FILE_BIN flag"},         // 5011
   {"Файл должен быть открыт с флагом FILE_TXT","File must be opened with FILE_TXT flag"},         // 5012
   {
    "Файл должен быть открыт с флагом FILE_TXT или FILE_CSV",                                      // 5013
    "File must be opened with FILE_TXT or FILE_CSV flag"
   },
   {"Файл должен быть открыт с флагом FILE_CSV","File must be opened with FILE_CSV flag"},         // 5014
   {"Ошибка чтения файла","File read error"},                                                      // 5015
   {"Ошибка записи файла","File write error"},                                                     // 5016
   {
    "Размер строки должен быть указан для двоичных файлов",                                        // 5017
    "String size must be specified for binary file"
   },
   {
    "Неверный тип файла (для строковых массивов-TXT, для всех других-BIN)",                        // 5018
    "Incompatible file (for string arrays-TXT, for others-BIN)"
   },
   {"Файл является директорией","File is directory not file"},                                     // 5019
   {"Файл не существует","File does not exist"},                                                   // 5020
   {"Файл не может быть перезаписан","File cannot be rewritten"},                                  // 5021
   {"Неверное имя директории","Wrong directory name"},                                             // 5022
   {"Директория не существует","Directory does not exist"},                                        // 5023
   {"Указанный файл не является директорией","Specified file is not directory"},                   // 5024
   {"Ошибка удаления директории","Cannot delete directory"},                                       // 5025
   {"Ошибка очистки директории","Cannot clean directory"},                                         // 5026
   {"Ошибка изменения размера массива","Array resize error"},                                      // 5027
   {"Ошибка изменения размера строки","String resize error"},                                      // 5028
   {
    "Структура содержит строки или динамические массивы",                                          // 5029
    "Structure contains strings or dynamic arrays"
   },
  };
  //+------------------------------------------------------------------+
  //| Array of MQL4 execution time error messages (5200 - 5203)        |
  //| (1) in user's country language                                   |
  //| (2) in the international language                                |
  //+------------------------------------------------------------------+
  string messages_runtime_5200_5203[][TOTAL_LANG]=
  {
   {"URL не прошел проверку","Invalid URL"},                                                       // 5200
   {"Не удалось подключиться к указанному URL","Failed to connect to specified URL"},              // 5201
   {"Превышен таймаут получения данных","Timeout exceeded"},                                       // 5202
   {"Ошибка в результате выполнения HTTP запроса","HTTP request failed"},                          // 5203
  };
#endif 
#endif // __DATA_MQH__