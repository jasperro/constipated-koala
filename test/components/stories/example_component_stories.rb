class ExampleComponentStories < ViewComponent::Storybook::Stories
  story :hello_world do
    constructor(title: "my title") do
      "Hello World!"
    end
  end
end
