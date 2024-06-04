import model.{type User}
import user/register_form.{type Msg}

pub type UserMsg {
  UserCreatedAccount(user: User)
  UserUpdatedAccount(user: User)
  UserDeletedAccount(id: Int)
  UserSignedIn
  UserSignedOut
  UserSubmittedLoginForm(email: String, password: String)
  UserSubmittedLoginFormSuccess
  UserSubmittedLoginFormError
  LoginFormUsernameError
  LoginFormPasswordError
}
