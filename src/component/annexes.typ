/*
 * Поддержка приложений.
 *
 * Этот модуль обеспечивает корректное оформление приложений в соответствии с ГОСТ 7.32-2017,
 * включая нумерацию, заголовки и сброс счетчиков для вложенных элементов.
 */
#import "../utils.typ": heading-numbering

// Функция `is-heading-in-annex` проверяет, находится ли заголовок внутри блока приложений.
#let is-heading-in-annex(heading) = state("annexes", false).at(heading.location())

/*
 * Функция `get-element-numbering` формирует сквозную нумерацию для элементов внутри приложения (например, А.1, Б.2).
 *
 * ГОСТ 7.32-2017, п. 6.5.5: "Иллюстрации каждого приложения обозначают отдельной нумерацией арабскими цифрами с добавлением перед цифрой обозначения приложения: Рисунок А.3."
 * ГОСТ 7.32-2017, п. 6.6.4: "Таблицы каждого приложения обозначаются отдельной нумерацией арабскими цифрами с добавлением перед цифрой обозначения приложения."
 * ГОСТ 7.32-2017, п. 6.8.5: "Формулы, помещаемые в приложениях, нумеруются арабскими цифрами в пределах каждого приложения с добавлением перед каждой цифрой обозначения приложения: (В.1)."
 */
#let get-element-numbering(current-heading-numbering, element-numbering) = {
  if (current-heading-numbering.first() <= 0 or element-numbering <= 0) {
    return
  }
  let current-numbering = heading-numbering(current-heading-numbering.first())
  (current-numbering, numbering("1.1", element-numbering)).join(".")
}

// Функция `annex-heading` для создания заголовка приложения с определенным статусом (например, "обязательное").
#let annex-heading(status, level: 1, body) = {
  heading(level: level)[(#status)\ #body]
}

/*
 * Основная функция `annexes` для обертывания содержимого приложений.
 *
 * ГОСТ 7.32-2017, раздел 8: "Приложения".
 */
#let annexes(content) = {
  /*
   * ГОСТ 7.32-2017, п. 6.17.4: "Приложения обозначают прописными буквами кириллического алфавита, начиная с А, за исключением букв Ё, З, Й, О, Ч, Ъ, Ы, Ь."
   */
  set heading(
    numbering: heading-numbering,
    hanging-indent: 0pt
  )

  /*
   * ГОСТ 7.32-2017, п. 6.17.3: "Каждое приложение следует размещать с новой страницы с указанием в центре верхней части страницы слова "ПРИЛОЖЕНИЕ". Приложение должно иметь заголовок, который записывают с прописной буквы, полужирным шрифтом, отдельной строкой по центру без точки в конце."
   */
  show heading: set align(center)
  show heading: it => {
    assert(it.numbering != none, message: "В приложениях не может быть структурных заголовков или заголовков без нумерации")
    counter("annex").step()
    block[#upper([приложение]) #numbering(it.numbering, ..counter(heading).at(it.location())) \ #text(weight: "medium")[#it.body]]
  }

  // Правило для заголовков первого уровня внутри приложений.
  show heading.where(level: 1): it => context {
    // Сброс счетчиков для каждого нового приложения.
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: raw)).update(0)
    counter(math.equation).update(0)

    /*
     * ГОСТ 7.32-2017, п. 6.17.3: "Каждое приложение следует размещать с новой страницы..."
     */
    if query(<modern-g7-32-parameters>).first().value.pagebreaks {
      pagebreak(weak: true)
    }
    it
  }

  // Установка правила нумерации для рисунков и таблиц внутри приложений.
  set figure(numbering: it => {
    let current-heading = counter(heading).get()
    get-element-numbering(current-heading, it)
  })

  // Установка правила нумерации для формул внутри приложений.
  set math.equation(numbering: it => {
    let current-heading = counter(heading).get()
    [(#get-element-numbering(current-heading, it))]
  })

  // Установка состояния "внутри блока приложений" в true.
  state("annexes").update(true)
  // Сброс счетчика заголовков для нумерации с начала (А, Б, В...).
  counter(heading).update(0)
  // Отображение содержимого блока приложений.
  content
}
