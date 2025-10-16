/*
 * Модуль-мост для передачи пользовательского модуля шаблона титульного листа во время выполнения.
 *
 * Этот модуль позволяет пользователям определять и использовать свои собственные шаблоны титульных листов,
 * предоставляя им набор утилит для упрощения верстки.
 */

#import "../utils.typ": fetch-field, sign-field

#import "title.typ": (
  agreed-field,
  approved-and-agreed-fields,
  approved-field,
  detailed-sign-field,
  if-present,
  per-line,
)
#import "title-templates.typ": custom-title-template as from-module

#let title-utils = (
  per-line,
  if-present,
  fetch-field,
  sign-field,
  detailed-sign-field,
  agreed-field,
  approved-field,
  approved-and-agreed-fields,
)
