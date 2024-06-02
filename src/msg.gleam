import components/counter
import user.{type UserMsg}

pub type Msg {
  UserMsg(UserMsg)
  OtherMsg
  AlertOpened(text: String)
  AlertClosed
  CounterMsg(counter.Msg)
  CounterLimit(val: Int)
}
