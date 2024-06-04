import gleam/list

import lustre/attribute.{class, href}
import lustre/element.{text}
import lustre/element/html.{a, div, li, nav, ul}

import routes.{type Route, CreateAccount, Home, UserDashboard}

pub fn navigation(current_url: Route) {
  let menu_items = [
    #(Home, "/", "Home"),
    #(CreateAccount, "/register/", "Register"),
    #(UserDashboard, "/dashboard/", "Dashboard"),
  ]

  div(
    [class("fixed top-0 py-3 px-2 bottom-auto w-full bg-slate-100 shadow-sm")],
    [
      nav([class("container mx-auto")], [
        ul(
          [class("flex flex-row align-center justify-center")],
          list.map(menu_items, fn(item) {
            let menu_item_classes = case item.0 == current_url {
              True -> "mx-1 text-indigo-600 pointer-events-none"
              False -> "mx-1 hover:text-indigo-600"
            }
            li([class(menu_item_classes)], [a([href(item.1)], [text(item.2)])])
          }),
        ),
      ]),
    ],
  )
}
