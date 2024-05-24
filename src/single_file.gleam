import gleam/io
import gleam/option.{type Option, Some, None}
import gleam/int

import lustre
import lustre/event.{on_click, on_input}
import lustre/element.{text, fragment}
import lustre/attribute.{style, value, class}
import lustre/element/html.{div, p, button, input}

pub type User {
  User(
    id: Int,
    name: String,
  )
}

pub type UserMsg {
  UserCreatedAccount
  UserUpdatedAccount
  UserDeletedAccount
  UserSignedIn
  UserSignedOut
  UserEnteredUsername(String)
  UserEnteredPassword(String)
  UserSubmittedLoginForm
}



pub type Msg {
  UserMsg(UserMsg)
  OtherMsg
  AlertOpened(text: String)
  AlertClosed
}
pub type Model {
  Model(
    user: Option(User),
    show_alert: Bool,
    alert_text: String,
    user_username: String,
    user_password: String,
  )
}

fn sum_list_loop(l: List(Int), count) {
  case l {
    [head, ..tail] -> sum_list_loop(tail, count + head)
    [] -> count
  }
}

fn sum_list(l: List(Int)) -> Int {
  sum_list_loop(l, 0)
}

pub fn main() {
  let app =  lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  let sum = sum_list([4, 5, 7]) // 16
  io.debug(#("sum: ", sum))
  Nil
}

fn init(_flags) {
  Model(user: None, show_alert: False, alert_text: "", user_username: "", user_password: "")
}

pub fn update_user(model: Model, msg: UserMsg) {
  case msg {
    UserCreatedAccount -> {
      case model.user {
        Some(user) -> Model(..model, user: Some(User(..user, name: "Alice")))
        None -> Model(..model, user: Some(User(id: 1, name: "Alice")))
      }
    }
    UserUpdatedAccount -> Model(..model, user: Some(User(id: 1, name: "Bob")))

    UserDeletedAccount -> Model(..model, user: None)
    UserSignedIn -> Model(..model, show_alert: True, alert_text: "You have signed in")
    // we don't use the ..model syntax here because we set all the possible fields on the model
    UserSignedOut -> Model(show_alert: True, alert_text: "You have signed out", user: None, user_username: "", user_password: "")
    UserEnteredUsername(val) -> Model(..model, user_username: val)
    UserEnteredPassword(val) -> Model(..model, user_password: val)
    UserSubmittedLoginForm -> {
      io.debug("login form submitted")
      case model.user_password {
        "hunter2" -> Model(..model, user: Some(User(id: 0, name: model.user_username)), show_alert: True, alert_text: "You have signed in")
        _ -> {
          io.debug("incorrect password")
          Model(..model, user_password: "", user_username: "", show_alert: True, alert_text: "Incorrect password")
        }
      }
    }
  }
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
fn user_card_styles(signed_in: Bool) {
  style([
    #("border","1px solid #CCCCCC"),
    #("border-radius","1rem"),
    #("padding","1rem"),
    #("margin","1rem"),
    case signed_in {
      True -> #("background-color", "#FFFFFF")
      False -> #("background-color", "#F0F0F0")
    }
  ])
}

pub fn user_card(user: Option(User)) {
  let params = case user {
    Some(user) -> #(True, int.to_string(user.id), user.name)
    None -> #(False, "n/a", "n/a")
  }
  div([class("card"), user_card_styles(params.0)], [
    p([], [text("ID: " <> params.1)]),
    p([], [text("Name: " <> params.2)]),
  ])
}

fn view(model: Model) {
  let id_text = case model.user {
    Some(user) -> int.to_string(user.id) <> " " <> user.name
    None -> "No user"
  }
  div([], [
    p([], [text("User ID: " <> id_text)]),
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
