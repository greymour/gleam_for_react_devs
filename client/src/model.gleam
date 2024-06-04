import gleam/dict.{type Dict}
import gleam/option.{type Option}
import routes.{type Route}

pub type User {
  User(id: Int, name: String, username: String, email: String, password: String)
}

pub type Model {
  Model(
    user: Option(User),
    show_alert: Bool,
    alert_text: String,
    user_name: String,
    user_username: String,
    user_password: String,
    user_email: String,
    user_store: Dict(Int, User),
    current_route: Route,
  )
}
