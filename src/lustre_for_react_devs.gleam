import gleam/io
import gleam/option.{None, Some}

import lustre
import lustre/attribute.{class, disabled, href, style, value}
import lustre/element.{fragment, text}
import lustre/element/html.{a, button, div, form, input, li, nav, p, ul}
import lustre/event.{on_click, on_input, on_submit}

import model.{type Model, Model}
import msg.{type Msg, AlertClosed, AlertOpened, OtherMsg, UserMsg}
import user.{
  UserCreatedAccount, UserDeletedAccount, UserEnteredPassword,
  UserEnteredUsername, UserSignedOut, UserSubmittedLoginForm, UserUpdatedAccount,
  update_user, user_card,
}

pub fn main() {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Nil
}

fn init(_flags) {
  Model(
    user: None,
    show_alert: False,
    alert_text: "",
    user_username: "",
    user_password: "",
    // this should be a dict, not a list
    user_store: [],
  )
}

fn update(model: Model, msg: Msg) {
  case msg {
    UserMsg(inner) -> update_user(model, inner)
    OtherMsg -> model
    AlertOpened(text) -> {
      io.debug("alert opened")
      Model(..model, alert_text: text, show_alert: True)
    }
    AlertClosed -> {
      io.debug("alert closed")
      Model(..model, alert_text: "", show_alert: False)
    }
  }
}

fn alert(alert_text: String) {
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
          button([on_click(AlertClosed)], [text("close")]),
        ],
      ),
    ],
  )
}

fn header() {
  div(
    [class("fixed top-0 py-3 px-2 bottom-auto w-full bg-slate-100 shadow-sm")],
    [
      nav([class("container mx-auto")], [
        ul([class("flex flex-row align-center justify-center")], [
          li([class("mr-2")], [a([href("/home/")], [text("Home")])]),
          li([], [a([href("/blog/")], [text("Blog")])]),
        ]),
      ]),
    ],
  )
}

fn view(model: Model) {
  fragment([
    header(),
    html.main([class("pt-20")], [
      div([class("container")], [
        form(
          [
            on_submit(UserMsg(UserSubmittedLoginForm)),
            class("login-form shadow-sm"),
          ],
          [
            p([], [text("Username")]),
            input([
              value(model.user_username),
              on_input(fn(val) { UserMsg(UserEnteredUsername(val)) }),
            ]),
            p([], [text("Password")]),
            input([
              value(model.user_password),
              on_input(fn(val) { UserMsg(UserEnteredPassword(val)) }),
            ]),
            button([on_click(UserMsg(UserSubmittedLoginForm))], [
              text("sign in"),
            ]),
          ],
        ),
        button([on_click(UserMsg(UserCreatedAccount))], [text("create user")]),
        button([on_click(UserMsg(UserUpdatedAccount))], [text("update user")]),
        button(
          [
            on_click(UserMsg(UserDeletedAccount)),
            disabled(case model.user {
              Some(_) -> False
              None -> True
            }),
          ],
          [text("delete user")],
        ),
        button(
          [
            on_click(UserMsg(UserSignedOut)),
            disabled(case model.user {
              Some(_) -> False
              None -> True
            }),
          ],
          [text("sign out")],
        ),
        button([on_click(AlertOpened("Hello!"))], [text("open alert")]),
        user_card(model.user),
        case model.show_alert {
          True -> alert(model.alert_text)
          False -> fragment([])
        },
      ]),
    ]),
  ])
}
