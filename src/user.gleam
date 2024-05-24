import gleam/int
import gleam/io
import gleam/option.{type Option, Some, None}

import lustre/element.{text}
import lustre/element/html.{div, p}
import lustre/attribute.{class, style}

import model.{type User, User, Model}

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

pub fn update_user(model, msg: UserMsg) {
  case msg {
    UserCreatedAccount -> Model(..model, user: Some(User(id: 1, name: "Alice")))
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
