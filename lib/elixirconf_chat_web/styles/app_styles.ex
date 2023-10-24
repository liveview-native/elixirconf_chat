defmodule ElixirconfChatWeb.Styles.AppStyles do
  use LiveViewNative.Stylesheet, :swiftui

  ~SHEET"""
  "button-style-" <> button_style do
    buttonStyle(style: to_ime(button_style))
  end

  "p-" <> padding do
    padding(edges: .all, length: to_integer(padding))
  end

  "ph-" <> padding do
    padding(edges: .horizontal, length: to_integer(padding))
  end

  "pv-" <> padding do
    padding(edges: .vertical, length: to_integer(padding))
  end

  "w-full" do
    frame(maxWidth: .infinity, width: .infinity)
  end

  "w-" <> width do
    frame(width: to_integer(width))
  end

  "h-full" do
    frame(maxHeight: .infinity, height: .infinity)
  end

  "h-" <> height do
    frame(width: to_integer(height))
  end

  "offset-x-" <> offset do
    offset(x: to_integer(offset))
  end

  "offset-y-" <> offset do
    offset(y: to_integer(offset))
  end

  "hidden" do
    hidden(true)
  end

  "stretch" do
    resizable(resizingMode: .stretch)
  end

  "italic" do
    italic(isActive: true)
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
    scrollDisabled(disabled: true)
  end

  "align-" <> alignment do
    frame(maxWidth: .infinity, alignment: to_ime(alignment))
    multilineTextAlignment(to_ime(alignment))
  end

  "autocapitalize-" <> autocapitalization do
    textInputAutocapitalization(autocapitalization: to_ime(autocapitalization))
  end

  "disable-autocorrect" do
    autocorrectionDisabled(disable: true)
  end

  "text-field-" <> style do
    textFieldStyle(style: to_ime(style))
  end

  "background:" <> content do
    background(content: to_atom(content))
  end

  "overlay:" <> content do
    overlay(content: to_atom(content))
  end

  "fg-color-" <> fg_color do
    foregroundColor(color: to_ime(fg_color))
  end

  "fg-color:" <> fg_color do
    foregroundColor(color: fg_color)
  end

  "tint-" <> tint do
    tint(color: to_ime(tint))
  end

  "tint:" <> tint do
    tint(color: tint)
  end

  "border-" <> border_color do
    border(content: to_ime(border_color), width: 1)
  end

  "border:" <> border_color do
    border(content: to_ime(border_color), width: 1)
  end

  "stroke-" <> stroke_color do
    stroke(content: to_ime(stroke_color), lineWidth: 1)
  end

  "stroke:" <> stroke_color do
    stroke(content: stroke_color, lineWidth: 1)
  end

  "line-limit-" <> number do
    lineLimit(number: to_integer(number))
  end

  "keyboard-type-" <> keyboard_type do
    keyboardType(keyboardType: to_ime(keyboard_type))
  end

  "opacity-" <> opacity do
    opacity(opacity: to_float(opacity))
  end

  "full-screen-cover:" <> content do
    fullScreenCover(content: to_atom(content), isPresented: attr("showing"))
  end

  "image-scale-" <> image_scale do
    imageScale(to_ime(image_scale))
  end
  """
end
