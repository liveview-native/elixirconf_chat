defmodule ElixirconfChatWeb.Styles.AppStyles do
  use LiveViewNative.Stylesheet, :swiftui

  ~SHEET"""
  "button-style-" <> button_style do
    buttonStyle(to_ime(button_style))
  end

  "p-" <> padding do
    padding(to_integer(padding))
  end

  "ph-" <> padding do
    padding(.horizontal, to_integer(padding))
  end

  "pv-" <> padding do
    padding(.vertical, to_integer(padding))
  end

  "w-full" do
    frame(maxWidth: .infinity)
  end

  "w-" <> width do
    frame(width: to_integer(width))
  end

  "h-full" do
    frame(maxHeight: .infinity)
  end

  "h-" <> height do
    frame(height: to_integer(height))
  end

  "offset-x-" <> offset do
    offset(x: to_integer(offset), y: 0)
  end

  "offset-y-" <> offset do
    offset(x: 0, y: to_integer(offset))
  end

  "hidden" do
    hidden(true)
  end

  "stretch" do
    resizable(resizingMode: .stretch)
  end

  "italic" do
    italic(true)
  end

  "capitalize" do
    textCase(.uppercase)
  end

  "type-size-" <> size do
    dynamicTypeSize(to_ime(size))
  end

  "kerning-" <> kerning do
    kerning(to_float(kerning))
  end

  "tracking-" <> tracking do
    tracking(to_float(tracking))
  end

  "font-weight-" <> weight do
    fontWeight(to_ime(weight))
  end

  "font-" <> font do
    font(to_ime(font))
  end

  "line-spacing-" <> line_spacing do
    lineSpacing(to_float(line_spacing))
  end

  "scroll-disabled" do
    scrollDisabled(true)
  end

  "align-" <> alignment do
    frame(maxWidth: .infinity, alignment: to_ime(alignment))
    multilineTextAlignment(to_ime(alignment))
  end

  "autocapitalize-" <> autocapitalization do
    textInputAutocapitalization(to_ime(autocapitalization))
  end

  "disable-autocorrect" do
    autocorrectionDisabled(true)
  end

  "text-field-" <> style do
    textFieldStyle(to_ime(style))
  end

  "background:" <> content do
    background(content: to_atom(content))
  end

  "overlay:" <> content do
    overlay(content: to_atom(content))
  end

  "fg-color-" <> fg_color do
    foregroundStyle(to_ime(fg_color))
  end

  "fg-color:" <> fg_color do
    foregroundStyle(Color(fg_color))
  end

  "tint-" <> tint do
    tint(to_ime(tint))
  end

  "tint:" <> tint do
    tint(Color(tint))
  end

  "border-" <> border_color do
    border(to_ime(border_color), width: 1)
  end

  "border:" <> border_color do
    border(Color(border_color), width: 1)
  end

  "stroke-" <> stroke_color do
    stroke(to_ime(stroke_color), lineWidth: 1)
  end

  "stroke:" <> stroke_color do
    stroke(Color(stroke_color), lineWidth: 1)
  end

  "line-limit-" <> number do
    lineLimit(to_integer(number))
  end

  "keyboard-type-" <> keyboard_type do
    keyboardType(to_ime(keyboard_type))
  end

  "opacity-" <> opacity do
    opacity(to_float(opacity))
  end

  "full-screen-cover:" <> content do
    fullScreenCover(content: to_atom(content), isPresented: attr("showing"))
  end

  "image-scale-" <> image_scale do
    imageScale(to_ime(image_scale))
  end
  """

  def class(_, _), do: {:unmatched, []}
end
