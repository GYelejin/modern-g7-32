/*
 * Вспомогательные функции для создания страницы "Список исполнителей".
 *
 * Этот модуль реализует логику для формирования списка исполнителей
 * в соответствии с ГОСТ 7.32-2017, включая группировку по организациям
 * и разделение на исполнителей и соисполнителей.
 */
#import "headings.typ": structural-heading-titles
#import "../utils.typ": sign-field, fetch-field

// Функция `fetch-performers` для обработки и стандартизации данных об исполнителях.
#let fetch-performers(performers) = {
  // Ожидаемые аргументы для каждого исполнителя.
  let performers-args = ("name*", "position*", "co-performer", "part", "organization")
  // Если исполнители переданы в виде массива.
  if type(performers) == array {
    // Текущая организация (для группировки).
    let current-organization = none;
    // Результирующий массив.
    let result = ()
    // Итерация по элементам массива.
    for (i, performer) in performers.enumerate() {
      // Если элемент - строка, считаем его названием организации.
      if type(performer) == str {
        current-organization = performer
        continue
      }
      // Извлекаем поля для исполнителя.
      let performer = fetch-field(performer, performers-args, default: (co-performer: false), hint: "исполнителя №" + str(i + 1))
      // Присваиваем текущую организацию.
      performer.organization = current-organization
      // Добавляем в результат.
      result.push(performer)
    }
    return result
  } 
  // Если исполнитель передан в виде словаря.
  else if type(performers) == dictionary {
    // Извлекаем поля.
    let performer = fetch-field(performers, performers-args, default: (co-performer: false), hint: "исполнителя")
    // Возвращаем как массив из одного элемента.
    return (performer, )
  } 
  // Если тип не поддерживается, вызываем ошибку.
  else {
    panic("Некорректный тип поля исполнителей")
  }
}

/*
 * Функция `group-organizations` для группировки исполнителей по организациям.
 *
 * ГОСТ 7.32-2017, п. 6.11: "Для соисполнителей из других организаций следует указывать наименование организации-соисполнителя."
 */
#let group-organizations(performers) = {
  // Устанавливаем межстрочный интервал для списка.
  set par(spacing: 0.5em)
  // Получаем уникальный список организаций.
  let organizations = performers.map(performer => performer.organization).dedup().filter(org => org != none)
  // Создаем словарь "организация: [исполнители]".
  let organizations-with-performers = organizations.map(organization => (organization, performers.filter(performer => performer.organization == organization))).to-dict()
  // Получаем список исполнителей без организации.
  let without-organization = performers.filter(performer => performer.organization == none)
  // Выводим исполнителей без организации.
  for performer in without-organization {
    [#sign-field(performer.name, performer.position, part: performer.part)]
  }
  // Выводим исполнителей, сгруппированных по организациям.
  for (organization, performers) in organizations-with-performers.pairs() {
    [#block([#organization:])] // Название организации.
    for performer in performers {
      // Поле для подписи каждого исполнителя.
      sign-field(performer.name, performer.position, part: performer.part)
    }
  }
}

/*
 * Функция `performers-page` для создания страницы "Список исполнителей".
 *
 * ГОСТ 7.32-2017, п. 5.2.1: "В список исполнителей должны быть включены фамилии и инициалы, должности, ученые степени, ученые звания и подписи руководителей НИР, ответственных исполнителей, исполнителей и соисполнителей, принимавших непосредственное участие в выполнении работы, с указанием их роли в подготовке отчета."
 * ГОСТ 7.32-2017, п. 6.11: "Сведения об исполнителях следует располагать столбцом. Слева указывают должности, ученые степени, ученые звания руководителя НИР, ответственных исполнителей, исполнителей, соисполнителей, затем оставляют свободное поле для подлинных подписей, справа указывают инициалы и фамилии."
 */
#let performers-page(performers) = {
  /*
   * ГОСТ 7.32-2017, п. 6.2.1: "Наименования структурных элементов отчета: "СПИСОК ИСПОЛНИТЕЛЕЙ" ... служат заголовками структурных элементов отчета."
   */
  heading(structural-heading-titles.performers, outlined: false)

  // Разделяем на основных исполнителей и соисполнителей.
  let not-co-performers = performers.filter(performer => performer.co-performer == false)
  let co-performers = performers.filter(performer => performer.co-performer == true)

  // Выводим основных исполнителей.
  group-organizations(not-co-performers)

  // Проверяем, есть ли соисполнители.
  let contains-co-performers = performers.any(performer =>
    ( if "co-performer" in performer.keys() and performer.co-performer != none {
      performer.co-performer
    } else {
      false
    })
  )

  // Если есть соисполнители, выводим их под соответствующим подзаголовком.
  if contains-co-performers {
    block[Соисполнители:]
    group-organizations(co-performers)
  }
}
