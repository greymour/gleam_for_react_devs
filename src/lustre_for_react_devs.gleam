import gleam/io
import gleam/option.{None}

import lustre
import lustre/event.{on_click, on_input}
import lustre/element.{text, fragment}
import lustre/attribute.{style, value}
import lustre/element/html.{div, p, button, input}

import msg.{type Msg, UserMsg, OtherMsg,  AlertOpened, AlertClosed}
import model.{type Model, Model}
import user.{
  update_user,
  user_card,
  UserEnteredUsername,
  UserEnteredPassword,
  UserSubmittedLoginForm,
  UserCreatedAccount,
  UserUpdatedAccount,
  UserDeletedAccount,
  UserSignedOut,
}

pub fn main() {
  let app =  lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Nil
}

fn init(_flags) {
  Model(user: None, show_alert: False, alert_text: "", user_username: "", user_password: "")
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
  div([style([
    #("display", "flex"),
    #("align-items", "center"),
    #("justify-content", "center"),
    #("width", "100%"),
    #("height", "100%"),
    #("position", "absolute"),
    #("top", "2rem"),
    #("right", "auto"),
    #("left", "auto"),
    #("bottom", "auto"),
    #("background", "rgba(0, 0, 0, 0.5)")
  ])], [
    div([
        style([
          #("color", "red"),
          #("font-weight", "bold"),
          #("font-size", "1.25rem"),
          #("padding", "0.75rem"),
          #("background-color", "#F0F0F0"),
          #("border", "1px solid #CCCCCC"),
          #("border-radius", "0.25rem"),
          #("width", "400px"),
          #("height", "400px"),
          #("display", "flex"),
          #("flex-direction", "column"),
          #("align-items", "center"),
          #("justify-content", "center")
        ])
      ],
      [
        button([on_click(AlertClosed)], [text("close")]),
        p([], [text(alert_text)])
      ])
  ])
}

fn view(model: Model) {
  div([], [
    p([], [text("Username")]),
    input(
      [
        value(model.user_username),
        on_input(fn(val) { UserMsg(UserEnteredUsername(val)) })
      ],
    ),
    p([], [text("Password")]),
    input([
      value(model.user_password),
      on_input(fn(val) { UserMsg(UserEnteredPassword(val))})
    ]),
    button([on_click(UserMsg(UserSubmittedLoginForm))], [text("sign in")]),
    button([on_click(UserMsg(UserCreatedAccount))], [text("create user")]),
    button([on_click(UserMsg(UserUpdatedAccount))], [text("update user")]),
    button([on_click(UserMsg(UserDeletedAccount))], [text("delete user")]),
    button([on_click(UserMsg(UserSignedOut))], [text("sign out")]),
    button([on_click(AlertOpened("Hello!"))], [text("open alert")]),
    user_card(model.user),
    case model.show_alert {
      True -> alert(model.alert_text)
      False -> fragment([])
    }
  ])
}
