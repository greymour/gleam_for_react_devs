import lustre/attribute.{class}
import lustre/element.{text}
import lustre/element/html.{div, h1, main}

pub fn dashboard() {
  main([], [
    div([class("container")], [h1([], [text("Hello from dashboard!")])]),
  ])
}
