import user.{type UserMsg}

pub type Msg {
  UserMsg(UserMsg)
  OtherMsg
  AlertOpened(text: String)
  AlertClosed
}
