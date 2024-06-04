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

import components/button.{button}

pub type Model(msg) {
  Model(value: Int, limit: Int)
}

pub type Msg {
  Increment
  Decrement
  LimitMsg
}

pub const name = "lustre-counter"

// fix the decoders here (which means actually make decoders :D)
pub fn counter(attributes: List(Attribute(a)), limit: Int) {
  let on_attribute_change = dict.new()
  dict.insert(on_attribute_change, "onCounterLimit", fn(handler) {
    io.debug(#("onCounterLimit handler: ", handler))
    Ok(LimitMsg)
  })
  dict.insert(on_attribute_change, "CounterLimit", fn(handler) {
    io.debug(#("CounterLimit handler: ", handler))
    Ok(LimitMsg)
  })
  let component =
    lustre.component(fn(_) { init(limit) }, update, view, on_attribute_change)
  let _ = case lustre.is_registered(name) {
    True -> Ok(Nil)
    False -> {
      let assert Ok(_) = lustre.register(component, name)
    }
  }
  // when the event fires the view disappears, idk
  element.element(name, attributes, [])
}

fn init(limit: Int) {
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
    LimitMsg -> {
      io.debug(#("counter limit event hit in counter", msg))
      #(model, effect.none())
    }
  }
}

pub fn view(model: Model(msg)) -> element.Element(Msg) {
  let count = int.to_string(model.value)

  html.div([], [
    html.div([id("counter-view")], [
      button([event.on_click(Increment)], [element.text("+")]),
      element.text(count),
      button([event.on_click(Decrement)], [element.text("-")]),
    ]),
  ])
}
