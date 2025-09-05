/*
 * Ре-экспорт публичного API для потребителей пакета.
 *
 * Этот файл служит "фасадом", собирая и предоставляя основные функции
 * и переменные из других модулей пакета. Это упрощает импорт
 * необходимых компонентов в основном документе пользователя.
 */

// Импорт основной функции `gost` из `lib.typ`.
#import "lib.typ": gost
// Импорт словаря с шаблонами титульных листов из `component/title-templates.typ`.
#import "component/title-templates.typ": templates as title-templates
// Импорт функции `abstract` для создания реферата из `component/abstract.typ`.
#import "component/abstract.typ": abstract
// Импорт функций `annexes` и `annex-heading` для работы с приложениями из `component/annexes.typ`.
#import "component/annexes.typ": annexes, annex-heading
// Импорт функции `structure-heading` для создания структурных заголовков из `component/headings.typ`.
#import "component/headings.typ": structure-heading
// Импорт модуля для работы с пользовательскими шаблонами титульных листов.
#import "component/custom-title-template.typ"
// Импорт функции `enum-numbering` для нумерации перечислений из `utils.typ`.
#import "utils.typ": enum-numbering
