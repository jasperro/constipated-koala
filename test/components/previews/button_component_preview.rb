# @label Basic Button
# @display bg_color "#fff"
class ButtonComponentPreview < ViewComponent::Preview

  # Primary button
  # ---------------
  # This is the button style you should use for most things.
  #
  # @label Primary
  def default
    render ButtonComponent.new(text: "Primary", icon: "banana") do
      "Click me"
    end
  end
end