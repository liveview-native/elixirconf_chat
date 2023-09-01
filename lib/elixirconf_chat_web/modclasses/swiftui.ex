defmodule ElixirconfChatWeb.Modclasses.SwiftUi do
  use LiveViewNative.Modclasses, platform: :swiftui

  def modclass(native, "button-style-" <> button_style, _assigns) do
    button_style(native, style: modclass_value(button_style, :atom))
  end

  def modclass(native, "p-" <> padding, _assigns) do
    padding(native, edges: :all, length: modclass_value(padding, :integer))
  end

  def modclass(native, "ph-" <> padding, _assigns) do
    padding(native, edges: :horizontal, length: modclass_value(padding, :integer))
  end

  def modclass(native, "pv-" <> padding, _assigns) do
    padding(native, edges: :vertical, length: modclass_value(padding, :integer))
  end

  def modclass(native, "w-full", _assigns) do
    frame(native, max_width: :infinity, width: :infinity)
  end

  def modclass(native, "w-" <> width, _assigns) do
    frame(native, width: modclass_value(width, :integer))
  end

  def modclass(native, "h-full", _assigns) do
    frame(native, max_height: :infinity, height: :infinity)
  end

  def modclass(native, "h-" <> height, _assigns) do
    frame(native, height: modclass_value(height, :integer))
  end

  def modclass(native, "offset-x-" <> offset, _assigns) do
    offset(native, x: modclass_value(offset, :integer))
  end

  def modclass(native, "offset-y-" <> offset, _assigns) do
    offset(native, y: modclass_value(offset, :integer))
  end

  def modclass(native, "hidden", _assigns) do
    hidden(native, true)
  end

  def modclass(native, "stretch", _assigns) do
    resizable(native, resizing_mode: :stretch)
  end

  def modclass(native, "italic", _assigns) do
    italic(native, is_active: true)
  end

  def modclass(native, "capitalize", _assigns) do
    text_case(native, :uppercase)
  end

  def modclass(native, "type-size-" <> size, _assigns) do
    dynamic_type_size(native, modclass_value(size, :atom))
  end

  def modclass(native, "kerning-" <> kerning, _assigns) do
    kerning(native, modclass_value(kerning, :float))
  end

  def modclass(native, "tracking-" <> tracking, _assigns) do
    tracking(native, modclass_value(tracking, :float))
  end

  def modclass(native, "font-weight-" <> weight, _assigns) do
    font_weight(native, modclass_value(weight, :atom))
  end

  @fonts %{
    "large-title" => :large_title,
    "title" => :title,
    "title2" => :title2,
    "title3" => :title3,
    "headline" => :headline,
    "subheadline" => :subheadline,
    "body" => :body,
    "callout" => :callout,
    "footnote" => :footnote,
    "caption" => :caption,
    "caption2" => :caption2
  }
  def modclass(native, "font-" <> font, _assigns) do
    font(native, font: {:system, Map.get(@fonts, font)})
  end

  def modclass(native, "line-spacing-" <> line_spacing, _assigns) do
    line_spacing(native, modclass_value(line_spacing, :float))
  end

  def modclass(native, "scroll-disabled", _assigns) do
    scroll_disabled(native, disabled: true)
  end

  def modclass(native, "align-" <> alignment, _assigns) do
    native
    |> frame(max_width: :infinity, alignment: modclass_value(alignment, :atom))
    |> multiline_text_alignment(modclass_value(alignment, :atom))
  end

  def modclass(native, "autocapitalize-" <> autocapitalization, _assigns) do
    text_input_autocapitalization(native, autocapitalization: modclass_value(autocapitalization, :atom))
  end

  def modclass(native, "disable-autocorrect", _assigns) do
    autocorrection_disabled(native, disable: true)
  end

  def modclass(native, "text-field-" <> style, _assigns) do
    text_field_style(native, style: modclass_value(style, :atom))
  end

  def modclass(native, "background:" <> content, _assigns) do
    background(native, content: modclass_value(content, :atom))
  end

  def modclass(native, "overlay:" <> content, _assigns) do
    overlay(native, content: modclass_value(content, :atom))
  end

  def modclass(native, "fg-color-" <> fg_color, _assigns) do
    foreground_color(native, color: modclass_value(fg_color, :atom))
  end

  def modclass(native, "fg-color:" <> fg_color, _assigns) do
    foreground_color(native, color: fg_color)
  end

  def modclass(native, "tint-" <> tint, _assigns) do
    tint(native, color: modclass_value(tint, :atom))
  end

  def modclass(native, "tint:" <> tint, _assigns) do
    tint(native, color: tint)
  end

  def modclass(native, "border-" <> border_color, _assigns) do
    stroke(native, content: {:color, modclass_value(border_color, :atom)}, width: 1)
  end

  def modclass(native, "border:" <> border_color, _assigns) do
    stroke(native, content: {:color, border_color}, width: 1)
  end

  def modclass(native, "stroke-" <> stroke_color, _assigns) do
    stroke(native, content: {:color, modclass_value(stroke_color, :atom)}, style: [line_width: 1])
  end

  def modclass(native, "stroke:" <> stroke_color, _assigns) do
    stroke(native, content: {:color, stroke_color}, style: [line_width: 1])
  end

  def modclass(native, "line-limit-" <> number, _assigns) do
    line_limit(native, number: modclass_value(number, :integer))
  end

  def modclass(native, "keyboard-type-" <> keyboard_type, _assigns) do
    keyboard_type(native, keyboard_type: modclass_value(keyboard_type, :atom))
  end

  def modclass(native, "opacity-" <> number, _assigns) do
    opacity(native, opacity: modclass_value(number, :float))
  end

  def modclass(native, "full-screen-cover:" <> content, assigns) do
    template_id = modclass_value(content, :atom)

    full_screen_cover(native, content: template_id, is_presented: assigns[template_id])
  end

  def modclass(native, "image-scale-" <> image_scale, _assigns) do
    image_scale(native, modclass_value(image_scale, :atom))
  end

  ###

  defp modclass_value(value, :atom) do
    value
    |> String.replace("-", "_")
    |> String.to_existing_atom()
  end

  defp modclass_value(value, :integer) do
    {integer_value, _remainder_of_binary} = Integer.parse(value)

    integer_value
  end

  defp modclass_value(value, :float) do
    {float_value, _remainder_of_binary} = Float.parse(value)

    float_value
  end
end
