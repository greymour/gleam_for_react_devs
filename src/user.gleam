import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result

import lustre/attribute.{class, style}
import lustre/element.{text}
import lustre/element/html.{div, p}

import model.{type User, Model, User}

pub type UserMsg {
  UserCreatedAccount(user: User)
  UserUpdatedAccount(user: User)
  UserDeletedAccount(id: Int)
  UserSignedIn
  UserSignedOut
  UserEnteredUsername(username: String)
  UserEnteredPassword(password: String)
  UserSubmittedLoginForm(username: String, password: String)
  UserSubmittedLoginFormSuccess
  UserSubmittedLoginFormError
  LoginFormUsernameError
  LoginFormPasswordError
  UserSubmittedLoginForm2
}

fn user_card_styles(signed_in: Bool) {
  style([
    #("border", "1px solid #CCCCCC"),
    #("border-radius", "1rem"),
    #("padding", "1rem"),
    #("margin", "1rem"),
    case signed_in {
      True -> #("background-color", "#FFFFFF")
      False -> #("background-color", "#F0F0F0")
    },
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
    UserCreatedAccount(user) ->
      Model(
        ..model,
        user: Some(user),
        user_store: dict.insert(model.user_store, user.id, user),
      )
    UserUpdatedAccount(user) ->
      Model(
        ..model,
        user: Some(user),
        user_store: dict.insert(
          dict.delete(model.user_store, user.id),
          user.id,
          user,
        ),
      )
    UserDeletedAccount(id) ->
      Model(..model, user: None, user_store: dict.delete(model.user_store, id))
    UserSignedIn ->
      Model(..model, show_alert: True, alert_text: "You have signed in")
    // we don't use the ..model syntax here because we set all the possible fields on the model
    UserSignedOut ->
      Model(
        ..model,
        show_alert: True,
        alert_text: "You have signed out",
        user: None,
        user_username: "",
        user_password: "",
      )
    UserEnteredUsername(val) -> Model(..model, user_username: val)
    UserEnteredPassword(val) -> Model(..model, user_password: val)
    UserSubmittedLoginForm(username, password) -> {
      io.debug("login form submitted")
      case
        dict.values(model.user_store)
        |> list.find(fn(user: User) { user.username == username })
      {
        Ok(user) -> {
          case user.password == password {
            True -> io.debug("should login user")
            False -> io.debug("do not login user")
          }
        }
        Error(_) -> io.debug("no user found!")
      }
      model
    }
    LoginFormUsernameError -> model
    LoginFormPasswordError -> model
    UserSubmittedLoginFormSuccess -> {
      io.debug("success login!")
      model
    }
    UserSubmittedLoginFormError -> {
      io.debug("login fail!")
      model
    }
    UserSubmittedLoginForm2 -> {
      io.debug("form submitted! again!")
      model
    }
  }
}
