import lustre/attribute.{type Attribute}
import lustre/element.{type Element}

import components/alert
import components/button
import components/counter
import components/input
import components/navigation
import routes.{type Route}

pub const input: fn(List(Attribute(msg)), String) -> Element(msg) = input.input

pub const alert: fn(String, msg) -> Element(msg) = alert.alert

pub const button: fn(List(Attribute(msg)), List(Element(msg))) -> Element(msg) = button.button

pub const counter: fn(List(Attribute(msg)), Int) -> Element(msg) = counter.counter

pub const navigation: fn(Route) -> Element(msg) = navigation.navigation
