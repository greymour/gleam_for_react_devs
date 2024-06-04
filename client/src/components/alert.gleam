import components/button.{button}
import lustre/attribute.{class, style}
import lustre/element.{text}
import lustre/element/html.{div, p}
import lustre/event.{on_click}

pub fn alert(alert_text: String, close_msg: msg) {
  div(
    [
      style([
        #("display", "flex"),
        #("align-items", "center"),
        #("justify-content", "center"),
        #("width", "100vw"),
        #("height", "100vh"),
        #("position", "absolute"),
        #("top", "0"),
        #("right", "0"),
        #("left", "0"),
        #("bottom", "0"),
        #("background", "rgba(0, 0, 0, 0.5)"),
      ]),
    ],
    [
      div(
        [
          style([#("width", "400px"), #("height", "400px")]),
          class(
            "flex flex-col align-center items-center justify-center bg-slate-200 p-2 border-2 border-slate-500 rounded width-10 height-10 font-bold",
          ),
        ],
        [
          p([], [text(alert_text)]),
          button([on_click(close_msg)], [text("close")]),
        ],
      ),
    ],
  )
}
