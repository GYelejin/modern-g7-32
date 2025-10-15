#import "../component/title.typ": detailed-sign-field, per-line, approved-and-agreed-fields
#import "../utils.typ": fetch-field, unbreak-name, sign-field

#let sign-field-new(position: none, fields: ((content: none, details: "подпись, дата"))) = {
  // Один блок подписей: позиция + несколько полей.
  let n = fields.len() + 1
  table(
    columns: n * (1fr,),
    rows: 2,
    row-gutter: 1mm,
    column-gutter: 5mm,
    align: center,
    stroke: (x, y) => if x != 0 and y == 0 { (bottom: 0.5pt + black) },

    // Первая строка блока: должность + содержимое полей
    table.cell(align: left)[#text(size: 11pt)[#position]],
    ..fields.map(field => table.cell(align: bottom + center, inset: (y: 1mm))[#text(size: 11pt)[#field.content]]),
    // Вторая строка: пустая ячейка под должностью + детали полей
    [],
    ..fields.map(field => table.cell(align: top + center, inset: (y: 0pt))[#text(size: 10pt)[#field.details]]),
  )
}

#let many-sign-fields(signs: ((position: none, fields: ((content: none, details: "подпись, дата"))))) = {
  // Если нет записей — ничего не рисуем.
  // Accept nested arrays or single entries by flattening to a single array
  let signs = if type(signs) == array { signs.flatten() } else { (signs,) }

  if signs.len() == 0 {
    []
  } else {
    // вычисляем максимальную длину полей среди всех signs
    let maxf = signs.map(s => s.fields.len()).reduce((a, b) => if a > b { a } else { b })

    // собираем итеративно: для каждого sign добавляем
    // 1 cтрока должность + field.content
    // 2 строка пустая строка +  details
    let cells = ()
    for s in signs {
      // должностью
      cells = cells + ( table.cell(align: left)[#text(size: 11pt)[#s.position]], )
      // дополняем пустыми ячейками
      cells = cells + ((table.cell(stroke: none)[],) * (maxf - s.fields.len()))
      // содержимое полей
      for field in s.fields {
        cells = cells + ( table.cell(align: bottom + center, inset: (y: 2pt))[#text(size: 11pt)[#field.content]], )
      }
      
      // дополняем пустыми ячейками
      cells = cells + ((table.cell(stroke: none)[],) * (maxf - s.fields.len() + 1))
      // детали полей
      for field in s.fields {
        cells = cells + ( table.cell(align: top + center, inset: (y: 0pt))[#text(size: 10pt)[#field.details]], )
      }
      
    }

    // строим таблицу: количество колонок = 1 + maxf, строк = signs.len() * 2
    table(
      columns: (1fr,) * (1 + maxf),
      rows: signs.len() * 2,
      row-gutter: 1mm,
      column-gutter: 5mm,
      align: center,
      stroke: (x, y) => if x != 0 and calc.even(y) { (bottom: 0.5pt + black) },
      ..cells,
    )
  }
}

#let hline() = {
  line(length: 100%, stroke: 0.9mm)
  v(-4.6mm)
  line(length: 100%, stroke: 0.2mm)
}

#let header(ministry: "", organization: "", institute: "", department: "", program: "") = {
  set text(size: 11pt)
  grid(
    columns: (17%, 83%),
    align: (left, center),
    box[
      #image("logo/bmstu.svg", width: 90%)
    ],
    box[
      #set text(weight: "bold")
      #set par(leading: 0.5em)
      #per-line(
                indent: 0pt,
                ministry,
                (value: [#organization.full],
                    when-present: organization.full),
                (value: [#organization.short],
                    when-present: organization.short),
            )
    ],
  )
  v(-2.5mm)
  hline()
  v(-2.5mm)
  table(
      stroke: (x, y) => if x == 1 {
      (bottom: 0.5pt + black)
    },
    align: (x, y) => (
      left
    ),
    inset: (x: 0pt, y: 3pt), 
    columns: (1fr, 3fr),
    [ФАКУЛЬТЕТ], ["#institute.name"],
    [КАФЕДРА], ["#department.name"],
  )
  v(20mm)
}

#let body(font_size: 14pt, content) = {
  set text(size: font_size)
  set par(leading: 1em)
  content
}

#let footer(content: grid()) = { place(bottom, dy: -3cm, content) }

#let arguments(..args, year: auto) = {
  let args = args.named()
  args.organization = fetch-field(
      args.at("organization", default: none), 
      ("*full", "short"), 
      default: (
        full: [Федеральное государственное автономное образовательное учреждение \ высшего образования \ "Московский государственный технический университет имени Н.~Э.~Баумана \ (национальный исследовательский университет)"], 
        short: [(МГТУ им. Н.~Э.~Баумана)]
        ),
      hint: "организации"
    )
  args.institute = fetch-field(
      args.at("institute", default: none), 
      ("*number", "name"),
      default: (name: ""),
      hint: "института"
    )
  args.department = fetch-field(
      args.at("department", default: none), 
      ("*number", "name"),
      default: (name: ""), 
      hint: "кафедры"
    )

  args.program = fetch-field(
      args.at("program", default: none),
      ("*id", "name"),
      default: (name: ""),
      hint: "направления подготовки"
    )

  args.approved-by = fetch-field(
        args.at("approved-by", default: none),
        ("*name", "position", "year"),
        default: (year: auto),
        hint: "согласования"
    )
    args.agreed-by = fetch-field(
        args.at("agreed-by", default: none),
        ("*name", "*position", "year"),
        default: (year: auto),
        hint: "утверждения"
    )
    args.stage = fetch-field(args.at(
        "stage", default: none),
        ("*type", "num"),
        hint: "этапа"
    )
  let raw_managers = args.at("managers", default: none)
  if raw_managers == none {
    args.managers = none
  } else if type(raw_managers) == array {
    args.managers = raw_managers.map(m => fetch-field(m, ("*position", "*name"), default: (position: none, name: none), hint: "руководителя"))
  } else {
    args.managers = (fetch-field(raw_managers, ("*position", "*name"), default: (position: none, name: none), hint: "руководителя"),)
  }

    if args.approved-by.year == auto {
        args.approved-by.year = year
    }
    if args.agreed-by.year == auto {
        args.agreed-by.year = year
    }

  return args
}

#let template(
  ministry: "Министерство науки и высшего образования Российской Федерации",
  organization: (
    full: [Федеральное государственное автономное образовательное учреждение \ высшего образования \ "Московский государственный технический университет имени Н.~Э.~Баумана \ (национальный исследовательский университет)"], 
    short: "(МГТУ им. Н. Э. Баумана)"
    ),
  institute: (number: none, name: none),
  department: (number: none, name: none),
  program: none,
  udk: none,
  research-number: none,
  report-number: none,
  approved-by: (name: none, position: none, year: auto),
  agreed-by: (name: none, position: none, year: auto),
  report-type: "Отчёт",
  about: "О лабораторной работе",
  discipline: none,
  part: none,
  bare-subject: false,
  research: none,
  subject: none,
  stage: none,
  managers: none,
  students: none,
  performer: none,
) = {
  
  header(ministry: ministry, organization: organization, institute: institute, department: department, program: program)

  per-line(
        align: center,
        indent: 2fr,
        (value: text(size: 22pt)[#upper(report-type)], when-present: report-type),
        (value: text(size: 20pt, style:"italic")[#upper(about)], when-present: about),
        (value: text(size: 20pt)[по курсу: "#discipline"], when-present: discipline),
        (value: text(size: 20pt, style:"italic")[#upper("на тему:")], when-rule: not bare-subject),
        (value: text(size: 20pt)["#upper(subject)"], when-present: subject),
    )

    many-sign-fields(signs: (
      if students != none {
        students.map(p => (
          position: if p.position != none { p.position } else { "Cтудент" },
          fields: (
            (content: unbreak-name(p.group), details: "(группа)"),
            (content: none, details: "(подпись, дата)"),
            (content: unbreak-name(p.name), details: " (Фамилия И.О.)"),
          )
        ))
      } else if performer != none {
        (position: if performer.position != none { performer.position } else { "Cтудент" },
          fields: (
            (content: unbreak-name(performer.group), details: "(группа)"),
            (content: none, details: "(подпись, дата)"),
            (content: unbreak-name(performer.name), details: " (Фамилия И.О.)"),
          )
        )
      } else {
        ()
      },
      if managers != none {
        managers.map(m => (
          position: if m.position != none { m.position } else { "Преподаватель" },
          fields: (
            (content: none, details: "(подпись, дата)"),
            (content: unbreak-name(m.name), details: " (Фамилия И.О.)"),
          )
        ))
      }
    ))
  v(0.5fr)
}
