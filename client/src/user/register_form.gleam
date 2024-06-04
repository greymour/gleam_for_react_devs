import gleam/dict
import gleam/io
import gleam/json.{object, string}

import lustre
import lustre/attribute.{type Attribute, class, name as html_name, type_, value}
import lustre/effect
import lustre/element.{text}
import lustre/element/html.{form}
import lustre/event.{on_input, on_submit}

import components.{button, input}
import model.{type User, User}

pub const name = "user-register-form"

pub type Model {
  Model(name: String, username: String, email: String, password: String)
}

pub opaque type Msg {
  UserEnteredName(String)
  UserEnteredUsername(String)
  UserEnteredEmail(String)
  UserEnteredPassword(String)
  UserSubmittedRegisterForm(
    name: String,
    username: String,
    email: String,
    password: String,
  )
}

pub fn register_form(attributes: List(Attribute(a))) {
  let on_attribute_change = dict.new()
  let component = lustre.component(init, update, view, on_attribute_change)
  let _ = case lustre.is_registered(name) {
    True -> Ok(Nil)
    False -> {
      let assert Ok(_) = lustre.register(component, name)
    }
  }
  element.element(name, attributes, [])
}

fn init(_flags) {
  #(Model("", "", "", ""), effect.none())
}

pub fn update(model: Model, msg: Msg) {
  case msg {
    UserEnteredName(val) -> #(Model(..model, name: val), effect.none())
    UserEnteredUsername(val) -> #(Model(..model, username: val), effect.none())
    UserEnteredEmail(val) -> #(Model(..model, email: val), effect.none())
    UserEnteredPassword(val) -> #(Model(..model, password: val), effect.none())
    UserSubmittedRegisterForm(name, username, email, password) -> {
      io.debug(#("register form submitted", name, username, email, password))
      #(
        model,
        effect.event(
          "Submit",
          object([
            #("name", string(name)),
            #("username", string(username)),
            #("email", string(email)),
            #("password", string(password)),
          ]),
        ),
      )
    }
  }
}

pub fn view(model: Model) {
  form(
    [
      class("mx-auto flex flex-col items-center"),
      on_submit(UserSubmittedRegisterForm(
        model.name,
        model.username,
        model.email,
        model.password,
      )),
    ],
    [
      input(
        [
          value(model.name),
          on_input(fn(val) { UserEnteredName(val) }),
          html_name("name"),
        ],
        "Name",
      ),
      input(
        [
          value(model.username),
          on_input(fn(val) { UserEnteredUsername(val) }),
          html_name("username"),
        ],
        "Username",
      ),
      input(
        [
          value(model.email),
          on_input(fn(val) { UserEnteredEmail(val) }),
          html_name("email"),
        ],
        "Email",
      ),
      input(
        [
          value(model.password),
          on_input(fn(val) { UserEnteredPassword(val) }),
          html_name("password"),
        ],
        "Password",
      ),
      button([class("mt-2"), type_("submit")], [text("Submit")]),
    ],
  )
}
