import gleam/dict
import gleam/int
import gleam/io
import gleam/json.{int, object}

import lustre
import lustre/attribute.{type Attribute, id}
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event

pub type Model(msg) {
  Model(value: Int, limit: Int)
}

pub type Msg {
  Increment
  Decrement
}

pub const name = "lustre-counter"

// fix the decoders here (which means actually make decoders :D)
pub fn counter(attributes: List(Attribute(a)), limit: Int) {
  io.debug(#("counter main called"))
  let on_attribute_change = dict.new()
  let component =
    lustre.component(fn(_) { init(limit) }, update, view, on_attribute_change)
  let r = case lustre.is_registered(name) {
    True -> Ok(Nil)
    False -> {
      let assert Ok(_) = lustre.register(component, name)
    }
  }
  io.debug(#("countered is_registered case result: ", r))
  // when the event fires the view disappears, idk
  let content = element.element(name, attributes, [])
  io.debug(#("content to be rendered: ", content))
  content
}

fn init(limit: Int) {
  io.debug(#("counter init called"))
  #(Model(0, limit), effect.none())
}

pub fn update(model: Model(msg), msg) {
  case msg {
    Increment -> {
      case model.value == model.limit - 1 {
        True -> {
          io.debug(#("val is incrementing to limit"))
          #(
            model,
            effect.event("CounterLimit", object([#("val", int(model.value))])),
          )
        }
        False -> #(Model(..model, value: model.value + 1), effect.none())
      }
    }
    Decrement -> #(Model(..model, value: model.value - 1), effect.none())
  }
}

pub fn view(model: Model(msg)) -> element.Element(Msg) {
  io.debug(#("counter view called"))
  let count = int.to_string(model.value)

  html.div([], [
    html.div([id("counter-view")], [
      html.button([event.on_click(Increment)], [element.text("+")]),
      element.text(count),
      html.button([event.on_click(Decrement)], [element.text("-")]),
    ]),
  ])
}
