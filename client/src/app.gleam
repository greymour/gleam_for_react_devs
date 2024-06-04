import gleam/dict
import gleam/dynamic
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/uri.{type Uri}

import lustre
import lustre/attribute.{class, disabled, name, type_, value}
import lustre/effect.{type Effect}
import lustre/element.{type Element, fragment, text}
import lustre/element/html.{div, form, h1, p}
import lustre/event.{on_click, on_input, on_submit}
import modem

import components.{alert, button, input, navigation}
import routes.{type Route}

import model.{type Model, type User, Model, User}
import msg.{
  type Msg, AlertClosed, AlertOpened, CounterLimit, CounterMsg, OnRouteChange,
  OtherMsg, UserMsg,
}
import user/user_msg.{
  UserCreatedAccount, UserDeletedAccount, UserSignedOut, UserSubmittedLoginForm,
  UserSubmittedLoginFormError, UserSubmittedLoginFormSuccess, UserUpdatedAccount,
}

import user/register_form.{register_form}
import user/user.{update_user, user_card}

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Nil
}

fn init(_flags) {
  let model =
    Model(
      user: None,
      show_alert: False,
      alert_text: "",
      user_name: "",
      user_username: "",
      user_email: "",
      user_password: "",
      current_route: routes.Home,
      // sample data
      user_store: dict.from_list([
        #(
          1,
          User(
            id: 1,
            name: "Astarion",
            username: "the_most_handsome_vamp",
            email: "astarion@baldursgate.com",
            password: "ihatecazador",
          ),
        ),
        #(
          2,
          User(
            id: 2,
            name: "Shadowheart",
            username: "gods_favourite_princess",
            email: "shadowheart@sharmail.com",
            password: "mommy_shar",
          ),
        ),
        #(
          3,
          User(
            id: 3,
            name: "Chuck",
            username: "evil_chuck",
            email: "chuck@death.com",
            password: "spirit-crusher",
          ),
        ),
        #(
          4,
          User(
            id: 4,
            name: "Aragorn",
            username: "elendil",
            email: "aragorn@gondor.gov",
            password: "arwen",
          ),
        ),
      ]),
    )
  #(model, modem.init(on_route_change))
}

fn on_route_change(uri: Uri) -> Msg {
  case uri.path_segments(uri.path) {
    ["register"] -> OnRouteChange(routes.CreateAccount)
    ["dashboard"] -> OnRouteChange(routes.UserDashboard)
    _ -> OnRouteChange(routes.Home)
  }
}

fn update(model: Model, msg: Msg) {
  case msg {
    UserMsg(inner) -> update_user(model, inner)
    OtherMsg -> #(model, effect.none())
    AlertOpened(text) -> {
      io.debug("alert opened")
      #(Model(..model, alert_text: text, show_alert: True), effect.none())
    }
    AlertClosed -> {
      io.debug("alert closed")
      #(Model(..model, alert_text: "", show_alert: False), effect.none())
    }
    CounterMsg(msg) -> {
      io.debug(#("counter message!", msg))
      #(model, effect.none())
    }
    CounterLimit(val) -> {
      io.debug(#("counter message!", val))
      #(model, effect.none())
    }
    OnRouteChange(route) -> {
      #(Model(..model, current_route: route), effect.none())
    }
  }
}

fn view(model: Model) {
  case model.current_route {
    routes.Home -> view_home(model)
    routes.UserDashboard -> view_dashboard(model)
    routes.CreateAccount -> view_register(model)
  }
}

fn layout(model: Model, children: Element(a)) {
  fragment([
    navigation(model.current_route),
    html.main([class("pt-20")], [children]),
  ])
}

fn view_home(model: Model) {
  layout(
    model,
    div([class("container")], [
      button(
        [
          on_click(case model.user {
            Some(user) -> UserMsg(UserDeletedAccount(user.id))
            None -> UserMsg(UserDeletedAccount(420))
          }),
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
        True -> alert(model.alert_text, AlertClosed)
        False -> element.none()
      },
    ]),
  )
}

fn view_register(model: Model) {
  let handle_register_submit = fn(
    name: String,
    username: String,
    email: String,
    password: String,
  ) {
    io.debug(#("register submit: ", name, username, email, password))
    case
      dict.values(model.user_store)
      |> list.find(fn(user: User) { user.email == email })
    {
      Ok(_) -> {
        io.debug("User already exists")
        // UserMsg(UserSubmittedRegisterFormError)
        OtherMsg
      }
      Error(_) -> {
        io.debug("no user found!")
        // UserMsg(UserSubmittedRegisterFormSuccess)
        OtherMsg
      }
    }
  }
  layout(
    model,
    div([class("container")], [
      h1([], [text("Register")]),
      register_form([event.on("Submit", handle_register_submit)]),
    ]),
  )
}

fn view_dashboard(model: Model) {
  case model.user {
    Some(user) -> {
      layout(
        model,
        div([class("container")], [
          div([], [
            h1([], [text("Dashboard")]),
            p([], [text("Welcome " <> user.name)]),
          ]),
        ]),
      )
    }
    None -> {
      layout(model, div([], [h1([], [text("no user found")])]))
    }
  }
}
