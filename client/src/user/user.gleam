import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}

import lustre/attribute.{class, style}
import lustre/effect.{type Effect}
import lustre/element.{text}
import lustre/element/html.{div, p}

import model.{type Model, type User, Model, User}
import user/user_msg.{
  type UserMsg, LoginFormPasswordError, LoginFormUsernameError,
  UserCreatedAccount, UserDeletedAccount, UserSignedIn, UserSignedOut,
  UserSubmittedLoginForm, UserSubmittedLoginFormError,
  UserSubmittedLoginFormSuccess, UserUpdatedAccount,
}

pub fn user_card_styles(signed_in: Bool) {
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

pub fn update_user(model, msg: UserMsg) -> #(Model, Effect(msg)) {
  case msg {
    UserCreatedAccount(user) -> #(
      Model(
        ..model,
        user: Some(user),
        user_store: dict.insert(model.user_store, user.id, user),
      ),
      effect.none(),
    )
    UserUpdatedAccount(user) -> #(
      Model(
        ..model,
        user: Some(user),
        user_store: dict.insert(
          dict.delete(model.user_store, user.id),
          user.id,
          user,
        ),
      ),
      effect.none(),
    )
    UserDeletedAccount(id) -> #(
      Model(..model, user: None, user_store: dict.delete(model.user_store, id)),
      effect.none(),
    )
    UserSignedIn -> #(
      Model(..model, show_alert: True, alert_text: "You have signed in"),
      effect.none(),
    )
    // we don't use the ..model syntax here because we set all the possible fields on the model
    UserSignedOut -> #(
      Model(
        ..model,
        show_alert: True,
        alert_text: "You have signed out",
        user: None,
        user_username: "",
        user_password: "",
      ),
      effect.none(),
    )
    // UserSubmittedLoginForm(email, password) -> {
    //   io.debug(#("login form submitted", email, password))
    //   case
    //     dict.values(model.user_store)
    //     |> list.find(fn(user: User) { user.email == email })
    //   {
    //     Ok(user) -> {
    //       case user.password == password {
    //         True -> io.debug("should login user")
    //         False -> io.debug("do not login user")
    //       }
    //     }
    //     Error(_) -> io.debug("no user found!")
    //   }
    //   #(model, effect.none())
    // }
    LoginFormUsernameError -> #(model, effect.none())
    LoginFormPasswordError -> #(model, effect.none())
    UserSubmittedLoginForm(email, password) -> {
      io.debug(#("login form submitted", email, password))
      #(model, effect.none())
    }
    UserSubmittedLoginFormSuccess -> {
      io.debug("success login!")
      #(model, effect.none())
    }
    UserSubmittedLoginFormError -> {
      io.debug("login fail!")
      #(model, effect.none())
    }
    // UserSubmittedRegisterForm(name, username, email, password) -> {
    //   io.debug(#("login form submitted", name, username, email, password))
    //   case
    //     dict.values(model.user_store)
    //     |> list.find(fn(user: User) { user.email == email })
    //   {
    //     Ok(_) -> {
    //       // @TODO: send messagggeeee
    //       io.debug("user already registered!")
    //       #(model, effect.none())
    //     }
    //     Error(_) -> {
    //       io.debug("no user found!")
    //       let user =
    //         User(
    //           id: 5,
    //           name: name,
    //           username: username,
    //           email: email,
    //           password: password,
    //         )
    //       let user_store = dict.insert(model.user_store, user.id, user)
    //       #(Model(..model, user_store: user_store), effect.none())
    //     }
    //   }
    // }
    // UserSubmittedRegisterFormSuccess -> #(model, effect.none())
    // UserSubmittedRegisterFormError -> #(model, effect.none())
  }
}
