/*
 * Шаблон титульного листа по умолчанию.
 *
 * Этот модуль определяет структуру и содержание титульного листа "по умолчанию",
 * который используется, если пользователь не указал другой шаблон.
 * Он соответствует общим требованиям ГОСТ 7.32-2017 к оформлению титульного листа.
 */
#import "../component/title.typ": detailed-sign-field, per-line, approved-and-agreed-fields
#import "../utils.typ": sign-field, fetch-field

// Функция для обработки и валидации аргументов, переданных в шаблон.
#let arguments(..args, year: auto) = {
    let args = args.named()
    /*
     * ГОСТ 7.32-2017, п. 5.1.2 а), б): "наименование министерства ... наименование (полное и сокращенное) организации - исполнителя НИР"
     */
    args.organization = fetch-field(
        args.at("organization", default: none),
        ("*full", "short"),
        hint: "организации"
    )
    /*
     * ГОСТ 7.32-2017, п. 5.1.2 д): "грифы согласования и утверждения отчета..."
     */
    args.approved-by = fetch-field(
        args.at("approved-by", default: none),
        ("name*", "position*", "year"),
        default: (year: auto),
        hint: "согласования"
    )
    args.agreed-by = fetch-field(
        args.at("agreed-by", default: none),
        ("name*", "position*", "year"),
        default: (year: auto),
        hint: "утверждения"
    )
    /*
     * ГОСТ 7.32-2017, п. 5.1.2 к): "вид отчета (заключительный, промежуточный)"
     */
    args.stage = fetch-field(args.at(
        "stage", default: none),
        ("type*", "num"),
        hint: "этапа"
    )
    /*
     * ГОСТ 7.32-2017, п. 5.1.2 н): "должность, ученую степень, ученое звание, подпись, инициалы и фамилию научного руководителя/руководителей НИР"
     */
    args.manager = fetch-field(
        args.at("manager", default: none),
        ("position*", "name*"),
        hint: "руководителя"
    )

    if args.approved-by.year == auto {
        args.approved-by.year = year
    }
    if args.agreed-by.year == auto {
        args.agreed-by.year = year
    }
    return args
}

// Основная функция-шаблон, которая генерирует титульный лист.
#let template(
    ministry: none,
    organization: (full: none, short: none),
    udk: none,
    research-number: none,
    report-number: none,
    approved-by: (name: none, position: none, year: auto),
    agreed-by: (name: none, position: none, year: none),
    report-type: "Отчёт",
    about: none,
    bare-subject: false,
    research: none,
    subject: none,
    part: none,
    stage: none,
    federal: none,
    manager: (position: none, name: none),
    performer: none,
) = {
    /*
     * ГОСТ 7.32-2017, п. 6.10.1: "наименование министерства ... следует помещать в верхней части титульного листа... Наименование организации - исполнителя НИР приводят прописными буквами, по центру страницы..."
     */
    per-line(
        force-indent: true,
        ministry,
        (value: upper(organization.full), when-present: organization.full),
        (value: upper[(#organization.short)], when-present: organization.short),
    )

    /*
     * ГОСТ 7.32-2017, п. 5.1.2 в), г): "индекс Универсальной десятичной классификации (УДК)... номера, идентифицирующие отчет..."
     * ГОСТ 7.32-2017, п. 6.10.1: "Эти данные размещаются одно под другим на титульном листе слева..."
     */
    per-line(
        force-indent: true,
        align: left,
        (value: [УДК: #udk], when-present: udk),
        (value: [Рег. №: #research-number], when-present: research-number),
        (value: [Рег. № ИКРБС: #report-number], when-present: report-number),
    )

    approved-and-agreed-fields(approved-by, agreed-by)

    /*
     * ГОСТ 7.32-2017, п. 5.1.2 е), ж), и), к), м): "вид документа (отчет о НИР); наименование НИР; наименование отчета; вид отчета (заключительный, промежуточный); номер книги отчета..."
     * ГОСТ 7.32-2017, п. 6.10.1: "Вид документа "ОТЧЕТ О НАУЧНО-ИССЛЕДОВАТЕЛЬСКОЙ РАБОТЕ" приводят прописными буквами по центру страницы..."
     */
    per-line(
        align: center,
        indent: 2fr,
        (value: upper(report-type), when-present: report-type),
        (value: upper(about), when-present: about),
        (value: research, when-present: research),
        (value: [по теме:], when-rule: not bare-subject),
        (value: upper(subject), when-present: subject),
        (
            value: [(#stage.type)],
            when-rule: (stage.type != none and stage.num == none)),
        (
            value: [(#stage.type, этап #stage.num)],
            when-present: (stage.type, stage.num)
        ),
        (value: [\ Книга #part], when-present: part),
        (federal)
    )

    if manager.name != none {
        sign-field(manager.at("name"), [Руководитель НИР,\ #manager.at("position")])
    }

    if performer != none {
        sign-field(performer.at("name", default: none), [Исполнитель НИР,\ #performer.at("position", default: none)], part: performer.at("part", default: none))
    }
}
