
///////////////////////////////////////////////////////////////////////////////////////////////////
// Прикладной интерфейс

Перем Лог;
Перем ИспользуемаяВерсияПлатформы;

// Интерфейсная процедура, выполняет регистрацию команды и настройку парсера командной строки
//   
// Параметры:
//   ИмяКоманды 	- Строка										- Имя регистрируемой команды
//   Парсер 		- ПарсерАргументовКоманднойСтроки (cmdline)		- Парсер командной строки
//
Процедура ЗарегистрироватьКоманду(Знач ИмяКоманды, Знач Парсер) Экспорт
	
	ОписаниеКоманды = Парсер.ОписаниеКоманды(ИмяКоманды, "Создает cf-файл из последней версии указанного хранилища");

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-params",
		"Файлы JSON содержащие значения параметров,
		|могут быть указаны несколько файлов разделенные "";""
		|(параметры командной строки имеют более высокий приоритет)");

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-storage-path",
		"Адрес хранилища конфигурации");

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-storage-user",
		"Пользователь хранилища конфигурации");
	
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-storage-pwd",
		"Пароль пользователя хранилища конфигурации");

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-cf-path",
		"Путь к выгружаемому cf-файлу обновления");

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-v8version",
		"Версия платформы 1С");

    Парсер.ДобавитьКоманду(ОписаниеКоманды);

КонецПроцедуры //ЗарегистрироватьКоманду()

// Интерфейсная процедура, выполняет текущую команду
//   
// Параметры:
//   ПараметрыКоманды 	- Соответствие						- Соответствие параметров команды и их значений
//
// Возвращаемое значение:
//	Число - код возврата команды
//
Функция ВыполнитьКоманду(Знач ПараметрыКоманды) Экспорт
    
	ЗапускПриложений.ПрочитатьПараметрыКомандыИзФайла(ПараметрыКоманды["-params"], ПараметрыКоманды);
	
	Хранилище_Адрес					= ПараметрыКоманды["-storage-path"];
	Хранилище_Пользователь			= ПараметрыКоманды["-storage-user"];
	Хранилище_ПарольПользователя	= ПараметрыКоманды["-storage-pwd"];
	ПутьКФайлуОбновления			= ПараметрыКоманды["-cf-path"];

	ВозможныйРезультат = МенеджерКомандПриложения.РезультатыКоманд();

	Если ПустаяСтрока(Хранилище_Адрес) Тогда
		Лог.Ошибка("Не указан адрес хранилища конфигурации");
		Возврат ВозможныйРезультат.НеверныеПараметры;
	КонецЕсли;

	Если ПустаяСтрока(Хранилище_Пользователь) Тогда
		Лог.Ошибка("Не указан пользователь хранилища конфигурации");
		Возврат ВозможныйРезультат.НеверныеПараметры;
	КонецЕсли;

	Если ПустаяСтрока(ПутьКФайлуОбновления) Тогда
		Лог.Информация("Не указан путь к выгружаемому cf-файлу обновления, файл будет выгружен во временный каталог");
	КонецЕсли;

	Лог.Информация("Начало создания файла обновления");

	Попытка
		СоздатьФайлОбновления(Хранилище_Адрес
							, Хранилище_Пользователь
							, Хранилище_ПарольПользователя
							, ПутьКФайлуОбновления
							, ИспользуемаяВерсияПлатформы);

		Возврат ВозможныйРезультат.Успех;
	Исключение
		Лог.Ошибка(ОписаниеОшибки());
		Возврат ВозможныйРезультат.ОшибкаВремениВыполнения;
	КонецПопытки;

КонецФункции

// Выгружает cf-файл, соответствующий последней версии хранилища
//   
// Параметры:
//   Хранилище_Адрес				- Строка - Адрес хранилища конфигурации
//   Хранилище_ИмяПользователя	 	- Строка - Пользователь хранилища конфигурации
//   Хранилище_ПарольПользователя 	- Строка - Пароль пользователя хранилища конфигурации
//   ПутьКФайлуОбновления	 		- Строка - Путь к выгружаемому cf-файлу обновления
//
Процедура СоздатьФайлОбновления(Хранилище_Адрес
							  , Хранилище_ИмяПользователя
							  , Хранилище_ПарольПользователя
							  , ПутьКФайлуОбновления
							  , ИспользуемаяВерсияПлатформы)
	
	РабочийКаталог = ОбъединитьПути(КаталогВременныхФайлов(), ПолучитьИмяВременногоФайла(""));

	Конфигуратор = ЗапускПриложений.НастроитьКонфигуратор(РабочийКаталог, , , , ИспользуемаяВерсияПлатформы);
	
	Лог.Информация("Создана временная база");

	Конфигуратор.ПодключитьсяКХранилищу(Хранилище_Адрес
									  , Хранилище_ИмяПользователя
									  , Хранилище_ПарольПользователя
									  , Истина);

	Лог.Информация("Выполнено подключение к хранилищу");

	КаталогВыгрузки = ОбъединитьПути(РабочийКаталог, "cf");

	УдалитьРабочийКаталог = Истина;

	Если ПустаяСтрока(ПутьКФайлуОбновления) Тогда
		ПутьКФайлуОбновления = ОбъединитьПути(РабочийКаталог, "1cv8.cf");

		УдалитьРабочийКаталог = Ложь;
	
	КонецЕсли;

	Конфигуратор.ВыгрузитьКонфигурациюВФайл(ПутьКФайлуОбновления);
	
	Лог.Информация("Выгружен cf-файл конфигурации """ + ПутьКФайлуОбновления + """");

	Если УдалитьРабочийКаталог Тогда
		ЗапускПриложений.УдалитьРабочийКаталог(РабочийКаталог);
	Иначе
		ЗапускПриложений.УдалитьРабочийКаталог(КаталогВыгрузки);
	КонецЕсли;

КонецПроцедуры //СоздатьФайлОбновления()

Лог = Логирование.ПолучитьЛог("ktb.app.yadt");