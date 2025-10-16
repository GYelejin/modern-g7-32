/*
 * modern-g7-32 :: публичный API
 *
 * Этот модуль предоставляет основную функцию `gost(...)` для создания отчета,
 * соответствующего требованиям ГОСТ 7.32-2017. Он управляет структурой документа,
 * включая титульный лист, список исполнителей и основное содержимое.
 */
#import "style.typ": gost-style
#import "utils.typ": fetch-field
#import "component/title-templates.typ": templates
#import "component/performers.typ": fetch-performers, performers-page

#let gost-common(
  title-template,
  title-arguments,
  city,
  year,
  hide-title,
  performers,
  force-performers,
) = {
  set par(justify: false)

  // Преобразуем аргументы для титульного листа в именованные для удобства доступа.
  title-arguments = title-arguments.named()

  // Добавляем год в аргументы титульного листа.
  /*
   * ГОСТ 7.32-2017, п. 5.1.2 п): "место и год составления отчета."
   */
  title-arguments.insert("year", year)

  // Флаг, показывающий, нужно ли отображать отдельную страницу со списком исполнителей.
  let show-performers-page = false
  if performers != none {
    // Обрабатываем и нормализуем данные об исполнителях.
    performers = fetch-performers(performers)
    /*
     * ГОСТ 7.32-2017, п. 5.2.2: "Если отчет выполнен одним исполнителем, его должность, ученую степень, ученое звание, фамилию и инициалы следует указывать на титульном листе отчета. В этом случае структурный элемент отчета "СПИСОК ИСПОЛНИТЕЛЕЙ" не оформляют."
     */
    if (performers.len() > 1 or force-performers) {
      show-performers-page = true
    } else {
      // Если исполнитель один, его данные добавляются на титульный лист.
      title-arguments.insert("performer", performers.first())
    }
  }

  // Если не указано скрыть титульный лист, создаем его.
  if not hide-title {
    /*
     * ГОСТ 7.32-2017, п. 5.1.1: "Титульный лист является первой страницей отчета о НИР..."
     */
    block(
      width: 100%,
      title-template(..title-arguments),
      breakable: false,
    )
  }

  // Если требуется, отображаем страницу "Список исполнителей".
  if show-performers-page { performers-page(performers) }
}

// Основная функция `gost` для создания отчета.
#let gost(
  title-template: templates.default, // Шаблон титульного листа.
  text-size: (default: 14pt, small: 10pt), // Размеры шрифта.
  /*
   * ГОСТ 7.32-2017, п. 6.1.1: "Абзацный отступ должен быть одинаковым по всему тексту отчета и равен 1,25 см."
   */
  indent: 1.25cm,
  /*
   * ГОСТ 7.32-2017, п. 6.1.1: "Текст отчета следует печатать, соблюдая следующие размеры полей: левое - 30 мм, правое - 15 мм, верхнее и нижнее - 20 мм."
   */
  margin: (left: 30mm, right: 15mm, top: 20mm, bottom: 20mm),
  title-footer-align: center, // Выравнивание футера на титульном листе.
  /*
   * ГОСТ 7.32-2017, п. 6.3.1: "Номер страницы проставляется в центре нижней части страницы без точки."
   */
  pagination-align: center,
  /*
   * ГОСТ 7.32-2017, п. 6.2.1: "Каждый структурный элемент и каждый раздел основной части отчета начинают с новой страницы."
   */
  pagebreaks: true,
  city: none, // Город (для титульного листа).
  year: auto, // Год (по умолчанию - текущий).
  hide-title: false, // Скрыть ли титульный лист.
  performers: none, // Список исполнителей.
  force-performers: false, // Принудительно отображать список исполнителей на отдельной странице.
  ..title-arguments, // Остальные аргументы для титульного листа.
  body // Основное содержимое документа.
) = {
  // Инициализация счетчиков.
  let table-counter = counter("table")
  let image-counter = counter("image")
  let citation-counter = counter("citation")
  let appendix-counter = counter("appendix")

  // Правило для автоматического увеличения счетчика рисунков.
  show figure.where(kind: image): it => {
    image-counter.step()
    it
  }
  // Правило для автоматического увеличения счетчика таблиц.
  show figure.where(kind: table): it => {
    table-counter.step()
    it
  }

  // Если год не задан, использовать текущий год.
  if year == auto {
    year = int(datetime.today().display("[year]"))
  }

  // Извлекаем размеры шрифта.
  text-size = fetch-field(text-size, ("default*", "small"))

  // Делегируем всю настройку визуального стиля функции `gost-style` из `style.typ`.
  show: gost-style.with(
    year,
    city,
    hide-title,
    text-size.default,
    text-size.small,
    indent,
    margin,
    title-footer-align,
    pagination-align,
    pagebreaks,
  )

  // Вызываем вспомогательную функцию для обработки титульного листа и исполнителей.
  gost-common(
    title-template,
    title-arguments,
    city,
    year,
    hide-title,
    performers,
    force-performers,
  )

  // Отображаем основное содержимое документа.
  body
}
