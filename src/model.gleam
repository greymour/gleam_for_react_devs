import gleam/option.{type Option}

pub type User {
  User(
    id: Int,
    name: String,
  )
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
