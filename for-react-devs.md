# Lustre for React developers

In some ways React and Lustre share the same DNA. But in a lot of other ways they
can be quite different! This guide is for React developers who are new to Lustre
and want to get up to speed quickly.

## How do I...?

### Setup a new project

**In React** you are encouraged to use a meta framework like Next.js or Remix. To
start a barebones project you need to run `npm install react react-dom`. You will
typically use a bundler that can transpile JSX like `npm install --save-dev vite`.
Many modern projects use TypeScript as well: `npm install --save-dev typescript`.
A simple hello world might look like this:

```jsx
// src/index.js
import { createRoot } from "react-dom/client";

const root = createRoot(document.getElementById("app"));

root.render(<h1>Hello, world</h1>);
```

To run the project you could use Vite's development server with `npx vite`.

**In Lustre** you need to install the `lustre` package with `gleam add lustre`.
Most Lustre projects will add the dev tools too with `gleam add --dev lustre_dev_tools`.
A simple hello world might look like this:

```gleam
// main.gleam
import lustre
import lustre/element/html

pub fn main() {
  let app = lustre.element(html.h1([], [html.text("Hello, world")]))
  let assert Ok(_) = lustre.start(app, "#app", Nil)
}
```

### Render some HTML

**In React** you can use JSX to render HTML elements. JSX is a syntax extension
for JavaScript that looks like HTML that lets you interpolate JavaScript expressions
into your markup. Here's an example:

```jsx
<button className="primary">Click me</button>
```

**In Lustre** HTML is rendered by calling functions (this is what JSX compiles to
as well).

```gleam
button([class("primary")], [text("Click me")])
```

### Render some text

**In React** a string is a valid type of React node, so you can render text by
just writing it in your JSX:

```jsx
Hello;
```

To concatenate text with other variables or expressions, you can use curly braces:

```jsx
Hello {name}
```

**In Lustre** because of Gleam's type system, all elements must be Lustre's `Element`
type. To render text you need to use the `text` function:

```gleam
text("Hello")
text("Hello" <> name)
```

### Manage state

**In React**...

**In Lustre**...
#### The equivalent of `useState` (or lack thereof)
Lustre by design doesn't have an equivalent of React's `useState`, owing to its adherence to the model-view-update architecture. Instead, your components should simply take in arguments, and optionally dispatch events. However, for complex components with high levels of interactivity it makes perfect sense to encapsulate those into stateful Lustre components! Generally, if you would create a reducer and pass a context to an equivalent React component, a stateful Lustre component is what you need.

### Handle events

**In React**...

**In Lustre**...
@TODO
See the example here: [https://github.com/lustre-labs/lustre/tree/main/examples/04-custom-event-handlers](https://github.com/lustre-labs/lustre/tree/main/examples/04-custom-event-handlers)

### Write a component
**In React**...

**In Lustre**...
"Components" in Gleam are conceptually similar to React components: at their core they're simply functions that return some piece of UI. Where they differ is in how they fit into the overall model-view-update pattern of Lustre. Most Lustre components won't be stateful, and will instead be stateless, pure functions that only receive arguments. Lustre does support ways to create stateful self-contained components, but these should be avoided unless you're absolutely sure that you need some kind of internal state. A helpful mental model for this separation between the two types of components is to think back to React pre-hooks: there were "dumb" function components that only receive props, and stateful class components that could levroerage React's lifecycle methods.


#### Stateless components
To create a stateless component in Lustre, we do the following:
```gleam
// card.gleam
import lustre/attribute.{type Attribute, src}
import lustre/element.{type Element, text}
import lustre/element/html.{div, p, img}

pub type Employee {
  Employee(
    id: Int,
    name: String,
    title: String,
    profile_img_url: String,
    is_admin: Bool,
    has_been_clicked: Bool,
  )
}

pub fn employee_card(attributes: List(Attribute(a)), employee: Employee) -> Element(msg) {
  let styles = [
    #("padding", "1rem"),
    // we can do inline conditional styles, similar to styled-components
    // this value doesn't change
    #("border", case is_admin {
      True -> "2px solid blue"
      False -> "2px solid black"
    }),
    // this value will change in response to a click event
    #("background", case employee.has_been_clicked {
        True -> "#000000"
        False -> "#f2f2f2"
    }),
  ]

  // spreading the attributes works the same as prop spreading in React
  div([styles, ..attributes], [
    p([], [text(employee.name)]),
    p([], [text(employee.title)]),
    img([src(employee.profile_img_url)]),
  ])
}

// app.gleam
import gleam/io
import lustre/event.{on_click}
import lustre/attribute.{type Attribute, src}
import lustre/element.{type Element, text}
import lustre/element/html.{main, div, h1}

import card.{card, Employee}

pub type Msg {
  UserClickedOnEmployeeCard(name: String)
}

pub type Model {
  Model(employees: List(Employee))
}

pub fn init(_flags) {
  let employees = [
    Employee(
        id: 1,
        name: "Jane Doe",
        title: "Actual Human Being",
        profile_img_url: "https://www.cool-site.com/assets/jane-doe.jpg",
        is_admin: True,
        has_been_clicked: False,
    ),
    Employee(
        id: 2,
        name: "Hugh Mann",
        title: "Definitely Not a Robot",
        profile_img_url: "https://www.cool-site.com/assets/robot.jpg",
        is_admin: False,
        has_been_clicked: False,
    )
  ]
  Model(employees: employees)
}


pub fn update(model: Model, msg: Msg) {
  case msg {
    UserClickedOnEmployeeCard(employee: Employee) -> {
        io.debug(#("user clicked on employee: " <> name))
        let employee = Employee(..employee, has_been_clicked: True)
        let employees = list.filter(model.emplooyees, fn(emp) {
            emp.id != employee.id
        })
        Model(employees: employees)
    }
  }
}

pub fn view(model: Model) {
  main([] , [
    div([class ("container")], [
      h1([], [text("Our team")]),
      ..list.map(model.employees, fn(employee) {
        card(
          [class("team-card"), on_click(UserClickedOnEmployeeCard(employee)],
          employee.name,
          employee.title,
          employee.profile_img_url,
        )
      })
    ])
  ])
}
```

This example shows us a few things:
- How to create a reusable stateless component in Gleam
- How to add event handlers to a component and handle events in our `update` function
- How to pass down additional attributes to our component with Gleam's spread operator. You can think of this like spreading additional props onto a React component @TODO write a React component equivalent to this
- How to render a list of components
- How to achieve something equivalent to CSS-in-JS for styling with the `attribute.style` function and Gleam's `case` statement
- And most importantly, how to log things to the browser's console with `io.debug`

#### Conditional rendering
Usually there are two types of conditional rendering: rendering one of two elements based on a condition, or only rendering an element when a condition is true
```gleam
import lustre/attribute.{class, href}
import lustre/element.{fragment, none, text}
import lustre/element/html.{nav, ul, li, a}

import components/modal.{modal}
pub type Model {
    Model(
        show_modal: Bool,
        use_new_dashboard_link: Bool
    )
}

pub fn view(model: Model) {
    fragment([
        nav([class("nav-menu")], [
            ul([],[
                li([], [
                    case model.use_new_dashboard_link {
                        True -> a([href("/dashboard/")], [text("Dashboard")])
                        False -> a([href("/dash/")], [text("Dash")])
                    }

                ])
            ])
        ]),
        case model.show_modal {
            True -> modal()
            False -> element.none()
        }
    ])

}

```

#### Stateful components
Only make something into a stateful component if it also makes sense as a web component or would cause a ton of unnecessary full-app recomputations, eg. a carousel, some kind of drag and drop wrapper, a drop down menu, accordion, some kind of complex form, etc
A good rule of thumb is that if you wouldn't put a piece of data in a Redux store or a context, you probably don't need a message for it, and it should instead be a function parameter
- Because of this ^ using styling solutions like Tailwind or traditional CSS makes development smoother



### Fetch data

**In React**...

**In Lustre**...
@TODO
See the example here: [https://github.com/lustre-labs/lustre/tree/main/examples/05-http-requests](https://github.com/lustre-labs/lustre/tree/main/examples/05-http-requests)

### What causes rerenders
React is somewhat notorious for rerendering, which frequently causes headaches when leveraging hooks like `useEffect`, especially when combined with data fetching. Of course there are tools to mitigate this like `useMemo` and `useCallback`, but it can be hit or miss for whether or not this will solve your problem. Like React, in Lustre your `view` function is recomputed on every `update`, with the key difference being that only the parts of the view that actually changed are updated on the DOM. Additionally, because Lustre's views and components are pure functions, we don't have the same concerns around rerendering like we do in React. You can run your `view` function a thousand times and not cause additional side effects (like network requests), and so long as the elements returned by the view haven't changed, nothing will rerender.

@TODO
### Styling your application
Lustre has out of the box support for Tailwind, and you can also write traditional CSS classes or achieve behaviour similar to CSS-in-JS.

@TODO
# Custom events and event handlers

@TODO
# Side effects
Lustre provides the `lustre/effect` module for using managed side effects
Effects should only be used so that external sources can send messages to your application, *not* to send messages from the app to itself

# Routing
See the example here: [https://github.com/lustre-labs/lustre/tree/main/examples/07-routing](https://github.com/lustre-labs/lustre/tree/main/examples/07-routing)

# Interacting directly with the DOM


# Server components
See the example here: [https://github.com/lustre-labs/lustre/tree/main/examples/99-server-components](https://github.com/lustre-labs/lustre/tree/main/examples/99-server-components)

### Anti-patterns
## Improper use of events and effects
## Overusing stateful components
## Over-reliance on FFI
- FFI is your friend when interacting with runtime targets, but overuse can be a bad thing, and can make it harder for your components to be **isomorphic**

## Where to go next

To walk through setting up a new Lustre project and building your first app, check
out the [quickstart guide](https://hexdocs.pm/lustre/guide/01-quickstart.html).

If you prefer to learn by example, we have a collection of examples that show
off specific features and patterns in Lustre. You can find them in the
[examples directory](https://hexdocs.pm/lustre/reference/examples.html)

If you're having trouble with Lustre or not sure what the right way to do
something is, the best place to get help is the [Gleam Discord server](https://discord.gg/Fm8Pwmy).
You could also open an issue on the [Lustre GitHub repository](https://github.com/lustre-labs/lustre/issues).

#### Recommend reading
- The Lustre docs
- Gleam docs for dynamic, FFI
- The Elm docs for the model-view-update architecture
