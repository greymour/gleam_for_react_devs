import gleam/string

import lustre/attribute.{type Attribute, class, for}
import lustre/element.{text}
import lustre/element/html.{div}

pub fn input(attributes: List(Attribute(a)), label: String) {
  let input_id = string.lowercase(label)
  div([], [
    html.label([for(input_id)], [text(label)]),
    html.input([
      class("border-2 border-indigo-600 hover:border-indigo-800 flex flex-col"),
      ..attributes
    ]),
  ])
}
