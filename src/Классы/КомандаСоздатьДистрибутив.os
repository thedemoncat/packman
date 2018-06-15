
#Использовать v8runner
#Использовать logos

Перем Лог;

///////////////////////////////////////////////////////////////////////////////////////////////////
// Прикладной интерфейс

Процедура ЗарегистрироватьКоманду(Знач ИмяКоманды, Знач Парсер) Экспорт
    
    ОписаниеКоманды = Парсер.ОписаниеКоманды(ИмяКоманды, "Создание дистрибутива по манифесту EDF");
    // TODO - с помощью tool1cd можно получить из хранилища
    // на больших историях версий получается массивный xml дамп таблицы
    Парсер.ДобавитьПозиционныйПараметрКоманды(ОписаниеКоманды, "ФайлМанифеста", "Путь к манифесту сборки");
    Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "-out", "Выходной каталог");
    Парсер.ДобавитьПараметрФлагКоманды(ОписаниеКоманды, "-setup", "Собирать дистрибутив вида setup.exe");
    Парсер.ДобавитьПараметрФлагКоманды(ОписаниеКоманды, "-files", "Собирать дистрибутив вида 'файлы поставки'");
    Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "-option", "Вариант поставки");
	Парсер.ДобавитьПараметрКоллекцияКоманды(ОписаниеКоманды, "-prop-files", "Файлы с переменными сборки (дополнительные)");
    Парсер.ДобавитьКоманду(ОписаниеКоманды);
     
КонецПроцедуры

// Выполняет логику команды
// 
// Параметры:
//   ПараметрыКоманды - Соответствие ключей командной строки и их значений
//
Функция ВыполнитьКоманду(Знач ПараметрыКоманды) Экспорт
    
    Параметры = РазобратьПараметры(ПараметрыКоманды);
    УправлениеКонфигуратором = ОкружениеСборки.ПолучитьКонфигуратор();
    ВыполнитьСборку(
        УправлениеКонфигуратором,
        Параметры.ФайлМанифеста,
        Параметры.СобиратьИнсталлятор,
        Параметры.СобиратьФайлыПоставки,
        Параметры.ВариантПоставки,
        Параметры.ВыходнойКаталог,
		Параметры.ФайлыСвойств);
    
КонецФункции

Процедура ВыполнитьСборку(Знач УправлениеКонфигуратором, Знач ФайлМанифеста, Знач СобиратьИнсталлятор, Знач СобиратьФайлыПоставки, Знач ВариантПоставки, Знач ВыходнойКаталог, Знач ФайлыСвойств) Экспорт
    
    Информация = СобратьИнформациюОКонфигурации(УправлениеКонфигуратором, ФайлыСвойств);
    СоздатьДистрибутивПоМанифесту(УправлениеКонфигуратором, ФайлМанифеста, Информация, СобиратьИнсталлятор, СобиратьФайлыПоставки, ВариантПоставки, ВыходнойКаталог);
    
КонецПроцедуры

Функция СобратьИнформациюОКонфигурации(Знач УправлениеКонфигуратором, Знач ФайлыСвойств)
    
    Лог.Информация("Запускаю приложение для сбора информации о метаданных");
    
    ФайлДанных = Новый Файл(ОбъединитьПути(УправлениеКонфигуратором.КаталогСборки(), ОкружениеСборки.ИмяФайлаИнформацииОМетаданных()));
    Если ФайлДанных.Существует() Тогда
        УдалитьФайлы(ФайлДанных.ПолноеИмя);
    КонецЕсли;
    
    ОбработкаСборщик = ПутьКОбработкеСборщикуДанных();
    
    Если Не УправлениеКонфигуратором.ВременнаяБазаСуществует() Тогда
        КаталогВременнойБазы = УправлениеКонфигуратором.ПутьКВременнойБазе();
        Лог.Отладка("Создаю временную базу. Путь "+КаталогВременнойБазы);
        
        УправлениеКонфигуратором.СоздатьФайловуюБазу(КаталогВременнойБазы);
    КонецЕсли;
    
    ПутьКПлатформе = УправлениеКонфигуратором.ПутьКПлатформе1С();
	УправлениеКонфигуратором.ПутьКПлатформе1С(УправлениеКонфигуратором.ПутьКТонкомуКлиенту1С());
    Попытка
		УправлениеКонфигуратором.ЗапуститьВРежимеПредприятия("""" + ФайлДанных.ПолноеИмя + """", Истина, "/Execute""" + ОбработкаСборщик + """");
	Исключение
		УправлениеКонфигуратором.ПутьКПлатформе1С(ПутьКПлатформе);
		ВызватьИсключение;	
	КонецПопытки;
	УправлениеКонфигуратором.ПутьКПлатформе1С(ПутьКПлатформе);

    Возврат ПрочитатьИнформациюОМетаданных(ФайлДанных.ПолноеИмя, ФайлыСвойств);
    
КонецФункции

Функция ПутьКОбработкеСборщикуДанных()

    // prod версия
    ОбработкаСборщик = Новый Файл(ОбъединитьПути(ТекущийСценарий().Каталог, "../../СборИнформацииОМетаданных.epf"));
    Если Не ОбработкаСборщик.Существует() Тогда
        Лог.Отладка(СтрШаблон("Не обнаружена обработка сбора данных в каталоге '%1'", ОбработкаСборщик.ПолноеИмя));
    Иначе 
        Возврат ОбработкаСборщик.ПолноеИмя;
    КонецЕсли;

    // dev версия
    ОбработкаСборщик = Новый Файл(ОбъединитьПути(ТекущийСценарий().Каталог, "../../tools/СборИнформацииОМетаданных.epf"));

    Если Не ОбработкаСборщик.Существует() Тогда
        ВызватьИсключение СтрШаблон("Не обнаружена обработка сбора данных в каталоге '%1'", ОбработкаСборщик.ПолноеИмя);
    КонецЕсли;

    Возврат ОбработкаСборщик.ПолноеИмя;

КонецФункции

Функция ПрочитатьИнформациюОМетаданных(Знач ИмяФайла, Знач ФайлыСвойств = Неопределено) Экспорт
    
	Если ЗначениеЗаполнено(ФайлыСвойств) Тогда
		Запись = Новый ЗаписьТекста(ИмяФайла,,,Истина);
		Попытка
			Для Каждого ФайлДополнения Из ФайлыСвойств Цикл
				ДополнитьФайлСвойствМетаданных(Запись, ФайлДополнения);
			КонецЦикла;
		Исключение
			Запись.Закрыть();
			ВызватьИсключение;
		КонецПопытки;

		Запись.Закрыть();
	КонецЕсли;

	Возврат ОкружениеСборки.ПрочитатьИнформациюОМетаданных(ИмяФайла);
    
КонецФункции // ПрочитатьИнформациюОМетаданных()

Процедура ДополнитьФайлСвойствМетаданных(Знач Запись, Знач ФайлДополнения)
	ФайлПроверка = Новый Файл(ФайлДополнения);
	Если ФайлПроверка.Существует() Тогда
		// дополним исходный файл
		Чтение = Новый ЧтениеТекста(ФайлДополнения);
		Пока Истина Цикл
			Стр = Чтение.ПрочитатьСтроку();
			Если Стр = Неопределено Тогда
				Прервать;
			КонецЕсли;
			Запись.ЗаписатьСтроку(Стр);
		КонецЦикла;
		Чтение.Закрыть();
	КонецЕсли;
КонецПроцедуры

Функция СоздатьДистрибутивПоМанифесту(
    Знач УправлениеКонфигуратором,
    Знач ФайлМанифеста,
    Знач ИнформацияОМетаданных,
    Знач СобиратьИнсталлятор,
    Знач СобиратьФайлыПоставки,
    Знач ВариантПоставки,
    Знач ВыходнойКаталог)
    
	ИмяКаталогаШаблонаВерсии = ОкружениеСборки.ОпределитьСтандартноеИмяКаталогаШаблона(ИнформацияОМетаданных);

    Сборщик = Новый СборщикДистрибутива;
    Сборщик.ФайлМанифеста = ФайлМанифеста;
    Сборщик.СоздаватьИнсталлятор = СобиратьИнсталлятор;
    Сборщик.СоздаватьФайлыПоставки = СобиратьФайлыПоставки;
    Сборщик.ВариантПоставки = ВариантПоставки;
    Сборщик.ВыходнойКаталог = ВыходнойКаталог; 
    
    Сборщик.Собрать(УправлениеКонфигуратором, ИнформацияОМетаданных.Версия, ИмяКаталогаШаблонаВерсии);
    
КонецФункции // СоздатьДистрибутивПоМанифесту(Знач УправлениеКонфигуратором, Знач ПараметрыКоманды)



Функция РазобратьПараметры(Знач ПараметрыКоманды) Экспорт
    
    Результат = Новый Структура;
    
    Если ПустаяСтрока(ПараметрыКоманды["ФайлМанифеста"]) Тогда
        ВызватьИсключение "Не задан путь к манифесту сборки (*.edf)";
    КонецЕсли;
    
    Результат.Вставить("ФайлМанифеста", ПараметрыКоманды["ФайлМанифеста"]);
    Результат.Вставить("СобиратьИнсталлятор", ПараметрыКоманды["-setup"]);
    Результат.Вставить("СобиратьФайлыПоставки", ПараметрыКоманды["-files"]);
    Результат.Вставить("ВариантПоставки", ПараметрыКоманды["-option"]);
    Результат.Вставить("ВыходнойКаталог", ПараметрыКоманды["-out"]);
	Результат.Вставить("ФайлыСвойств", ПараметрыКоманды["-prop-files"]);
    
    Возврат Результат;
    
КонецФункции

///////////////////////////////////////////////////////////////////////////////////

Лог = Логирование.ПолучитьЛог(ПараметрыСистемы.ИмяЛогаСистемы());
