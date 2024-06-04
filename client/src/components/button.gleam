import lustre/attribute.{type Attribute, class}
import lustre/element.{type Element}
import lustre/element/html

pub fn button(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.button(
    [
      class(
        "bg-indigo-600 px-2 py-1 text-neutral-100 hover:bg-indigo-800 disabled:bg-slate-500 disabled:text-neutral-300",
      ),
      ..attributes
    ],
    children,
  )
}
