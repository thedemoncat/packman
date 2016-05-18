﻿
&НаСервере
Функция СобратьДанныеОКонфигурации()

	Данные = Новый Структура;
	Данные.Вставить("Версия"   , Метаданные.Версия);
	Данные.Вставить("Поставщик", Метаданные.Поставщик);
	
	Возврат Новый ФиксированнаяСтруктура(Данные);

КонецФункции // СобратьДанныеОКонфигурации()


&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ПутьКОтчету = Новый Файл(ПараметрЗапуска);
	Если ПутьКОтчету.Существует() Тогда
		УдалитьФайлы(ПутьКОтчету);
	КонецЕсли;
	
	Данные = СобратьДанныеОКонфигурации();
	ТекстовыйДокумент = Новый ТекстовыйДокумент;
	Для Каждого КлючИЗначение Из Данные Цикл
		ТекстовыйДокумент.ДобавитьСтроку(КлючИЗначение.Ключ + "=" + КлючИЗначение.Значение);
	КонецЦикла;
	
	ТекстовыйДокумент.Записать(ПутьКОтчету.ПолноеИмя);
	
	ЗавершитьРаботуСистемы(Ложь);
	
КонецПроцедуры
