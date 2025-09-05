/*
 * modern-g7-32 :: утилиты
 *
 * Этот модуль содержит вспомогательные функции, используемые в других частях шаблона.
 * Функции предназначены для обработки данных, форматирования текста и генерации нумерации.
 */

// Функция `small-text` применяет к своему содержимому (body) малый размер шрифта,
// который задан в глобальных параметрах шаблона.
#let small-text = body => context {
  // Запрашивает параметры шаблона, сохраненные в метаданных.
  let target-size = query(<modern-g7-32-parameters>).first().value.small-text-size
  // Устанавливает полученный размер текста для содержимого.
  set text(size: target-size)
  // Возвращает отформатированное содержимое.
  body
}

// Функция `fetch-field` для гибкого извлечения значений из различных структур данных (словарь, массив, строка).
// Позволяет задавать обязательные ключи и значения по умолчанию.
#let fetch-field(field, expected-keys, default: (:), hint: "") = {
  let expected-keys-arg-error = "Ожидаемые ключи должны быть списком строк, например '(arg1*, arg2), здесь arg1 - обязательный агрумент, а arg2 - необязательный'"

  assert(type(expected-keys) == array, message: expected-keys-arg-error)
  assert(expected-keys.map(elem => type(elem)).all(elem => elem == str), message: expected-keys-arg-error)

  assert(type(default) == dictionary, message: "Стандартные значения должны быть определены в словаре, например: 'default: (arg1: false)'")
  assert(default.len() <= expected-keys.len(), message: "Количество стандартных значений должно быть не больше числа ожидаемых аргументов")

  let get-default(key) = (key, default.at(key, default: none))

  let clean-expected-keys = expected-keys.map(key => key.replace("*", ""))
  let required-keys = expected-keys.filter(key => key.at(-1) == "*").map(key => key.slice(0, -1))
  let not-required-keys = expected-keys.filter(key => key.at(-1) != "*")

  if type(field) == type(none) {
    let result = (:)
    for key in clean-expected-keys {
      result.insert(key, default.at(key, default: none))
    }
    return result
  }

  if type(field) == dictionary {
    let result = (:)
    for key in clean-expected-keys {
      result.insert(key, field.at(key, default: default.at(key, default: none)))
    }

    for key in required-keys {
      assert(key in field.keys(), message: "Обязательное поле '" + key + "' не было найдено в словаре " + hint)
    }

    return result
  } else if type(field) == array {
    let result = (:)
    for (i, key) in clean-expected-keys.enumerate() {
      result.insert(key, field.at(i, default: default.at(key, default: none)))
    }

    for key in required-keys {
      assert(clean-expected-keys.find(it => it == key) < field.len(), message: "Обязательное поле '" + key + "' не было найдено в массиве " + hint)
    }

    return result
  } else if type(field) in (str, int, length) {
    let result = (:)
    let first-key = clean-expected-keys.first()
    result.insert(first-key, field)
    for key in clean-expected-keys.slice(1) {
      result.insert(key, default.at(key, default: none))
    }
    return result
  } else {
    panic("Некорректный тип поля " + hint)
  }
}

/*
 * ГОСТ 7.32-2017, п. 6.1.4: "Фамилии, наименования учреждений, организаций, фирм, наименования изделий и другие имена собственные в отчете приводят на языке оригинала. Допускается транслитерировать имена собственные..."
 * Эта функция помогает сохранить целостность имен, предотвращая их разрыв при переносе строк.
 */
#let unbreak-name(name) = {
  if name == none { return }
  return name.replace(" ", "\u{00A0}")
}

// Функция `sign-field` создает блок для подписи (должность, ФИО).
#let sign-field(name, position, part: none, details: "подпись, дата") = {
  let part-cell = []
  if part != none {
    part-cell = table.cell(align: left)[#part]
  }

  set par(justify: false)
  table(
    stroke: none,
    inset: (x: 0pt, y: 3pt),
    columns: (5fr, 1fr, 3fr, 1fr, 3fr),
    [#position], [], [], [], table.cell(align: bottom)[#unbreak-name(name)],
    table.hline(start: 2, end: 3),
    [], [], table.cell(align: center)[#small-text[#details]], [], part-cell
  )
}

/*
 * ГОСТ 7.32-2017, п. 6.17.4: "Приложения обозначают прописными буквами кириллического алфавита, начиная с А, за исключением букв Ё, З, Й, О, Ч, Ъ, Ы, Ь."
 */
#let get-numbering-alphabet(number) = {
  let alphabet = ("а", "б", "в", "г", "д", "е", "ж", "з", "и", "к", "л", "м", "н", "о", "п", "р", "с", "т", "у", "ф", "х", "ц", "ч", "ш", "щ", "э", "ю", "я")
  let result = ""

  while number > 0 {
    result = alphabet.at(calc.rem(number - 1, 28)) + result
    number = calc.floor(number / 28)
  }

  return result
}

#let heading-numbering(..nums) = {
  nums = nums.pos()
  let letter = upper(get-numbering-alphabet(nums.first()))
  let rest = nums.slice(1).map(elem=>str(elem))
  if rest != none {
    return (letter, rest).flatten().join(".")
  }
  return letter
}

#let enum-numbering(number) = {
  return [#get-numbering-alphabet(number))]
}
