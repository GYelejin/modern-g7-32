/*
 * Вспомогательные функции для титульных листов.
 *
 * Этот модуль предоставляет низкоуровневые строительные блоки для создания
 * титульных листов в соответствии с ГОСТ 7.32-2017, раздел 7.
 * Он включает функции для полей подписей, грифов утверждения и согласования,
 * а также утилиты для компоновки элементов.
 */
#import "../utils.typ": fetch-field, unbreak-name
#import "performers.typ": performers-page

/*
 * Функция `detailed-sign-field` для создания детализированного поля подписи (УТВЕРЖДАЮ, СОГЛАСОВАНО).
 *
 * ГОСТ 7.32-2017, п. 6.10.1: "Гриф согласования и утверждения состоит из слов: "СОГЛАСОВАНО" и "УТВЕРЖДАЮ" (без кавычек),
 * наименования должности, ученой степени, ученого звания лица, согласовавшего и утвердившего отчет, личной подписи ...,
 * расшифровки подписи (инициалы и фамилия), даты согласования и утверждения отчета."
 */
#let detailed-sign-field(title, name, position, year) = {
    // Проверки типов входных данных.
    assert(type(name) == str, message: "Некорректный тип поля name в detailed-sign-field, должен быть строкой")
    assert(type(position) == str, message: "Некорректный тип поля position в detailed-sign-field, должен быть строкой")
    assert(type(year) in (int, type(none)), message: "Некорректный тип поля year в detailed-sign-field, должен быть целым числом")
    // Переменная для ячейки с годом.
    let year-cell = []
    // Переменная для определения конца линии подписи.
    let line-end = 7
    // Если год указан, создать ячейку и скорректировать линию.
    if year != none {
      year-cell = table.cell(align: right)[#year г.]
      line-end = 6
    }
    // Создание таблицы для форматирования поля.
    table(
        stroke: none, // Без видимых границ.
        align: left, // Выравнивание по левому краю.
        inset: (x: 0%), // Без внутренних отступов.
        columns: (8pt, 2fr, 2pt, 10pt, 2fr, auto, 45pt), // Определение колонок.
        table.cell(colspan: 7)[#upper(title)], // Заголовок поля (УТВЕРЖДАЮ).
        table.cell(colspan: 7)[#position], // Должность.
        table.cell(colspan: 5)[], table.cell(colspan: 2, align: right)[#unbreak-name(name)], // ФИО с неразрывными пробелами.
        table.hline(start: 0, end: 5), // Линия для подписи.
        table.cell(align: right)[«], [], table.cell(align: left)[»], [], [], [], year-cell, // Кавычки для даты и ячейка с годом.
        table.hline(start: 1, end: 2), table.hline(start: 4, end: line-end) // Линии для даты.
    )
}

// Псевдоним для функции выравнивания.
#let align-function = align

// Функция `per-line` для размещения элементов в строку с условным отображением.
#let per-line(align: center, indent: 1fr, force-indent: false, ..values) = {
  // Результирующий массив элементов для отображения.
  let result = ()
  // Итерация по переданным значениям.
  for value in values.pos() {
    // Флаг, показывать ли элемент.
    let rule = false
    // Если элемент - массив или словарь, обработать его по сложным правилам.
    if type(value) in (array, dictionary) {
      let data = fetch-field(value, ("value*", "when-rule", "when-present", "rule"), default: (when-present: "always", when-rule: "always", rule: array.all), hint: "линии")
      assert(not (data.when-rule != "always" and data.when-present != "always"), message: "Должно быть выбрано только одно правило пояивления when-rule или when-present")
      if data.when-rule != "always" {
        rule = data.when-rule
      }
      if data.when-present != "always" {
        rule = (data.rule)((data.when-present, ).flatten(), elem => elem != none)
      }
      if data.when-rule == "always" and data.when-present == "always" {
        rule = true
      }
      value = data.value
    } else {
      // Иначе, показывать, если элемент не пустой.
      rule = value != none
    }
    // Если правило выполнено, добавить элемент в результат.
    if rule {
      result.push(value)
    }
  }

  // Если есть что отображать, создать грид с элементами.
  if result != () {
    align-function(align)[
      #grid[#for elem in result {[#elem \ ]}]
    ]
  }
  // Добавить вертикальный отступ, если требуется.
  if force-indent or result != () {
    v(indent)
  }
}

// Функция `if-present` для условного отображения блока, если цели не пустые.
#let if-present(rule: array.all, indent: v(1fr), ..targets, body) = {
  // Проверка, что правило корректно (все или любой).
  assert(rule in (array.all, array.any), message: "Правило сравнения указано неверно, должно быть array.all или array.any")
  // Функция для проверки, что цель не пустая.
  let check = (target => target != none)
  // Если правило выполняется для переданных целей.
  if rule(targets.pos(), check) {
    // Отобразить тело блока и добавить отступ.
    body
    indent
  }
}

/*
 * Функция `approved-field` для создания поля "СОГЛАСОВАНО".
 *
 * ГОСТ 7.32-2017, п. 6.10.1: "Гриф СОГЛАСОВАНО размещается на титульном листе слева..."
 */
#let approved-field(approved-by) = {
  if approved-by.name != none [
    #detailed-sign-field("согласовано", approved-by.name, approved-by.position, approved-by.year)
  ]
}

/*
 * Функция `agreed-field` для создания поля "УТВЕРЖДАЮ".
 *
 * ГОСТ 7.32-2017, п. 6.10.1: "...а УТВЕРЖДАЮ - справа."
 */
#let agreed-field(agreed-by) = {
  if agreed-by.name != none [
    #detailed-sign-field("утверждаю", agreed-by.name, agreed-by.position, agreed-by.year)
  ]
}

/*
 * Функция `approved-and-agreed-fields` для размещения полей "СОГЛАСОВАНО" и "УТВЕРЖДАЮ" рядом.
 *
 * ГОСТ 7.32-2017, п. 6.10.1: "Гриф СОГЛАСОВАНО размещается на титульном листе слева, а УТВЕРЖДАЮ - справа."
 */
#let approved-and-agreed-fields(approved-by, agreed-by) = {
  // Отобразить, если есть хотя бы одно из имен.
  if-present(rule: array.any, approved-by.name, agreed-by.name)[
    // Использовать грид для размещения в две колонки.
    #grid(
      columns: (1fr, 1fr), // Две равные колонки.
      align: (left, right), // Выравнивание в колонках.
      gutter: 15%, // Промежуток между колонками.
      approved-field(approved-by), // Поле "СОГЛАСОВАНО".
      agreed-field(agreed-by) // Поле "УТВЕРЖДАЮ".
    )
  ]
}
