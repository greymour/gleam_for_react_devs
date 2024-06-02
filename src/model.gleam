import gleam/dict.{type Dict}
import gleam/option.{type Option}

pub type User {
  User(id: Int, name: String, username: String, password: String)
}

pub type Model {
  Model(
    user: Option(User),
    show_alert: Bool,
    alert_text: String,
    user_username: String,
    user_password: String,
    user_store: Dict(Int, User),
  )
}
