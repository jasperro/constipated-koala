# frozen_string_literal: true

class ButtonComponent < ViewComponent::Base
  def initialize(text:, icon:)
    @text = text
    @icon = icon
  end

end
