/*
 * Реестр шаблонов титульных листов.
 *
 * Этот модуль управляет доступными шаблонами титульных листов,
 * как встроенными, так и пользовательскими. Он использует "фабричный" подход
 * для унификации интерфейса вызова различных шаблонов.
 */
#let template-names = ("default", "mai-university-lab", "bmstu-university")

// Фабричная функция для создания унифицированного интерфейса вызова шаблона.
// Возвращает функцию, которая принимает аргументы и передает их в функцию-шаблон.
#let title-template-factory(template, arguments-function) = {
  return (..arguments) => template(..arguments-function(..arguments))
}

/*
 * Функция для создания шаблона из пользовательского модуля.
 *
 * Позволяет пользователям определять собственные титульные листы,
 * соответствующие специфическим требованиям их организаций,
 * придерживаясь при этом общих положений ГОСТ 7.32-2017.
 */
#let custom-title-template(module) = {
  title-template-factory(module.template, module.arguments)
}

/*
 * Словарь, содержащий все доступные шаблоны титульных листов.
 *
 * ГОСТ 7.32-2017, Приложение А: "Примеры оформления титульных листов отчета о НИР".
 * Этот словарь позволяет выбирать различные варианты оформления,
 * включая примеры, подобные приведенным в ГОСТ.
 */
#let templates = {
  let result = (:)
  for template in template-names {
    import "/src/title-templates/" + template + ".typ" as module
    result.insert(template, title-template-factory(
      module.template,
      module.arguments,
    ))
  }
  result
}
