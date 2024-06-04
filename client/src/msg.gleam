import components/counter
import routes.{type Route}
import user/user_msg.{type UserMsg}

pub type Msg {
  UserMsg(UserMsg)
  OtherMsg
  AlertOpened(text: String)
  AlertClosed
  CounterMsg(counter.Msg)
  CounterLimit(val: Int)
  OnRouteChange(route: Route)
}
