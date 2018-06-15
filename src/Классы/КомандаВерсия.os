
///////////////////////////////////////////////////////////////////////////////////////////////////
// Прикладной интерфейс

Процедура ЗарегистрироватьКоманду(Знач ИмяКоманды, Знач Парсер) Экспорт
	ОписаниеКоманды = Парсер.ОписаниеКоманды(ИмяКоманды, "Вывод версии приложения");
	Парсер.ДобавитьКоманду(ОписаниеКоманды);
КонецПроцедуры

Функция ВыполнитьКоманду(Знач ПараметрыКоманды) Экспорт
    
	Сообщить(ПараметрыСистемы.ВерсияПродукта());

	Возврат 0;

КонецФункции

Процедура ПоказатьСправкуПоКоманде(Знач Парсер, Знач ИмяКоманды)

	Парсер.ВывестиСправкуПоКоманде(ИмяКоманды);

КонецПроцедуры
