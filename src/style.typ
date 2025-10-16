/*
 * ГОСТ 7.32-2017. Параметры оформления документа.
 */
#import "component/headings.typ": headings, structural-heading-titles
#import "component/appendixes.typ": is-heading-in-appendix
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.8": *
#import "@preview/i-figured:0.2.4"
#import "@preview/lilaq:0.5.0" as lq
#import "@preview/tiptoe:0.3.1"

#import "utils.typ": enum-numbering
#let gost-style(
  year,
  city,
  hide-title,
  text-size,
  small-text-size,
  indent,
  margin,
  title-footer-align,
  pagination-align,
  pagebreaks,
  body,
) = {
  // Устанавливает размер малого текста, если он не задан явно.
  if small-text-size == none { small-text-size = text-size - 4pt }
  [#metadata((
      small-text-size: small-text-size,
      pagebreaks: pagebreaks,
    )) <modern-g7-32-parameters>]

  /*
   * ГОСТ 7.32-2017, п. 6.1.1: "Текст отчета следует печатать, соблюдая следующие размеры полей: левое - 30 мм, правое - 15 мм, верхнее и нижнее - 20 мм."
   */
  set page(margin: margin)

  /*
   * ГОСТ 7.32-2017, п. 6.3.1: "Страницы отчета следует нумеровать арабскими цифрами, соблюдая сквозную нумерацию по всему тексту отчета, включая приложения. Номер страницы проставляется в центре нижней части страницы без точки."
   * ГОСТ 7.32-2017, п. 6.3.2: "Титульный лист включают в общую нумерацию страниц отчета. Номер страницы на титульном листе не проставляют."
   */
  set page(numbering: "1", number-align: pagination-align)

  /*
   * ГОСТ 7.32-2017, п. 6.1.1: "Отчет о НИР должен быть выполнен любым печатным способом на одной стороне листа белой бумаги формата А4 через полтора интервала. ... Цвет шрифта должен быть черным, размер шрифта - не менее 12 пт. Рекомендуемый тип шрифта для основного текста отчета - Times New Roman."
   */
  set text(
    font: "Times New Roman",
    size: text-size,
    lang: "ru",
    hyphenate: false,
  )

  /*
   * ГОСТ 7.32-2017, п. 6.1.1: "Абзацный отступ должен быть одинаковым по всему тексту отчета и равен 1,25 см."
   * ГОСТ 7.32-2017, п. 6.1.1: "...через полтора интервала."
   */
  set par(
    justify: true,
    first-line-indent: (
      amount: indent,
      all: true,
    ),
    spacing: 1.5em,
  )

  /*
   * ГОСТ 7.32-2017, п. 5.4.1: "Содержание включает введение, наименование всех разделов и подразделов, пунктов (если они имеют наименование), заключение, список использованных источников и наименования приложений с указанием номеров страниц, с которых начинаются эти элементы отчета о НИР."
   * ГОСТ 7.32-2017, п. 6.2.1: "Наименования структурных элементов отчета: ... "СОДЕРЖАНИЕ" ... служат заголовками структурных элементов отчета. Заголовки структурных элементов следует располагать в середине строки без точки в конце, прописными буквами, не подчеркивая."
   */
  set outline(title: structural-heading-titles.outline)
  set outline(indent: indent, depth: 3)
  show outline: set block(below: indent / 2)
  show outline.entry: it => {
    show linebreak: [ ]
    if is-heading-in-appendix(it.element) {
      let body = it.element.body
      link(
        it.element.location(),
        it.indented(
          none,
          [ПРИЛОЖЕНИЕ #it.prefix()]
            + sym.space
            + box(width: 1fr, it.fill)
            + sym.space
            + sym.wj
            + it.page(),
        ),
      )
    } else {
      it
    }
  }

  /*
   * ГОСТ 7.32-2017, п. 6.9.1: "Порядковый номер ссылки (отсылки) приводят арабскими цифрами в квадратных скобках в конце текста ссылки."
   */
  set ref(supplement: none)

  /*
   * ГОСТ 7.32-2017, п. 6.5.7: "Слово "Рисунок", его номер и через тире наименование помещают после пояснительных данных и располагают в центре под рисунком без точки в конце."
   * ГОСТ 7.32-2017, п. 6.6.3: "Наименование таблицы, при ее наличии, должно отражать ее содержание, быть точным, кратким. Наименование следует помещать над таблицей слева, без абзацного отступа в следующем формате: Таблица Номер таблицы - Наименование таблицы."
   */
  set figure.caption(separator: " — ")
  show figure.caption: set par(leading: 0.65em, justify: true)

  /*
   * ГОСТ 7.32-2017, п. 6.8.3: "Формулы в отчете следует ... обозначать порядковой нумерацией в пределах всего отчета арабскими цифрами в круглых скобках в крайнем правом положении на строке."
   */
  set math.equation(numbering: "(1)")

  /*
   * ГОСТ 7.32-2017, п. 6.4.1: "Разделы должны иметь порядковые номера в пределах всего отчета, обозначенные арабскими цифрами без точки и расположенные с абзацного отступа."
   */
  set heading(numbering: "1.")

  show: codly-init.with()
  codly(
    display-icon: false,
    display-name: false,
    languages: codly-languages,
    number-align: right,
    skip-line: align(center, "..."),
    skip-number: align(left, "..."),
    smart-skip: true,
    stroke: black + 0.8pt,
    zebra-fill: none,
    breakable: true,
  )
  show raw: set text(size: 10pt)
  /*
   * ГОСТ 7.32-2017, п. 6.5.1: "Иллюстрации ... следует располагать в отчете непосредственно после текста отчета, где они упоминаются впервые, или на следующей странице"
   * ГОСТ 7.32-2017, п. 6.6.2: "Таблицу следует располагать непосредственно после текста, в котором она упоминается впервые, или на следующей странице."
   */
  show figure: pad.with(bottom: 0.5em)

  /*
   * ГОСТ 7.32-2017, п. 6.5.1: "Иллюстрации ... следует располагать в отчете непосредственно после текста отчета, где они упоминаются впервые, или на следующей странице."
   */
  show image: set align(center)

  /*
   * ГОСТ 7.32-2017, п. 6.5.4: "Иллюстрации, за исключением иллюстраций, приведенных в приложениях, следует нумеровать арабскими цифрами сквозной нумерацией. Если рисунок один, то он обозначается: Рисунок 1."
   * ГОСТ 7.32-2017, п. 6.5.7: "Слово "Рисунок", его номер и через тире наименование помещают после пояснительных данных..."
   */
  show figure.where(kind: image): set figure(supplement: [Рисунок])

  let gost-plot-style = it => {

    show lq.selector(lq.label): set align(top + right)
    show: lq.set-label(pad: 1em)
    show: lq.set-legend(
      position: horizon + left,
      dx: 100%,
      pad: .4em,
      stroke: none,
      fill: white
    )
    it
  }
  
  show: gost-plot-style

  /*
   * ГОСТ 7.32-2017, п. 6.6.4: "Таблицы, за исключением таблиц приложений, следует нумеровать арабскими цифрами сквозной нумерацией."
   * ГОСТ 7.32-2017, п. 6.6.3: "Наименование следует помещать над таблицей слева, без абзацного отступа в следующем формате: Таблица Номер таблицы - Наименование таблицы."
   * Таблицу с большим количеством строк допускается переносить на другую страницу. При переносе части таблицы на другую страницу слово "Таблица", ее номер и наименование указывают один раз слева над первой частью таблицы, а над другими частями также слева пишут слова "Продолжение таблицы" и указывают номер таблицы.
   */
  show figure.where(kind: table): it => {
    set block(breakable: true)
    set figure.caption(position: top)
    show figure.caption: set align(left)

    let continuation = counter("continuation")

    v(-0.5em)
    table(
      stroke: none,
      inset: (x: 0em, y: 0.5em),
      columns: 1fr,
      table.header([
        #align(left)[
          #context if continuation.get().at(0) == 0 {
            [
              #continuation.update(1)
              #it.caption
            ]
          } else {
            [
              #set par(justify: true, leading: 0.65em, first-line-indent: 0cm)
              Продолжение таблицы #counter(figure.where(kind: table)).display()
            ]
          }
        ]
      ]),
      [#it.body],
    )
    v(-0.5em)

    context continuation.update(0)
  }

  show figure.where(kind: raw): it => {
    set block(breakable: true)
    set figure.caption(position: bottom)
    show figure.caption: set align(center)

    let continuation = counter(str("continuation" + str(counter(figure.where(kind: raw)).get().at(0))))

    v(-0.5em)
    table(
      stroke: none,
      inset: (x: 0em, y: 0.5em),
      columns: 1fr,
      [#it.body],
      table.footer([
        #align(center)[
          #context [
            #set par(justify: true, leading: 0.65em, first-line-indent: 0cm)
            #continuation.step()
            #counter(figure.where(kind: raw)).step()
            #if continuation.final().at(0) > 1 {  
            [#it.caption.supplement #counter(figure.where(kind: raw)).display() — #it.caption.body, часть #(continuation.get().at(0) + 1) из #continuation.final().at(0)]
            } else {
            it.caption
            }
          ]
        ]
      ]),
    )
    v(-0.5em)
    counter(figure.where(kind: raw)).update(it => it - 1)
  }

  set list(marker: [–], indent: indent, spacing: 1em)
  set enum(indent: indent, spacing: 1em)


  set page(footer: context {
    if counter(page).get() == (1,) and not hide-title {
      align(title-footer-align)[#city #year]
    } else {
      align(pagination-align)[#counter(page).display()]
    }
  })

  set bibliography(
    style: "gost-r-7-0-5-2008-numeric.csl",
    title: structural-heading-titles.bibliography
  )

  /*
   * ГОСТ 7.32-2017, п. 6.4.6: "При необходимости ссылки в тексте отчета на один из элементов перечисления вместо тире ставят строчные буквы русского алфавита со скобкой, начиная с буквы "а" (за исключением букв ё, з, й, о, ч, ъ, ы, ь)."
   * TODO: Нумерация вложенных списков кириллическими буквами
   */

  show list: it => {
    set enum(numbering: enum-numbering)
    it
  }

  set enum(
    indent: 1.25cm,
    numbering: "1.a)",
  )

  // Нумерация вложенных списков кириллическими буквами
  show enum: outer => {
    show enum: inner => {
      set enum(numbering: enum-numbering)
      inner
    }
    outer
  }

  // Применение стилей для заголовков
  show: headings(text-size, indent, pagebreaks)
  body
}
