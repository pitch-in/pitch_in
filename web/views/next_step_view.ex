defmodule PitchIn.NextStepView do
  use PitchIn.Web, :view
  alias PitchIn.NextSteps

  defmacro __using__(_) do
    quote do
      import PitchIn.NextStepView, only: [next_step: 3, next_step: 2, next_step: 1, next_steps: 4]
    end
  end

  def next_step(link_text), do: next_step(link_text, [], [do: ""])
  def next_step(link_text, do: _ = block_opts), do: next_step(link_text, [], block_opts)
  def next_step(link_text, opts), do: next_step(link_text, opts, [do: ""])
  def next_step(link_text, opts, do: text) do
    opts = 
      Keyword.merge([
        to: "/",
        color: "primary",
        text: text,
        link_text: link_text
      ], opts)

    render "_next_step.html", opts 
  end

  def next_steps(model, struct, thanks, block) do
    render("index.html", model: model, struct: struct, thanks: thanks, block: block)
  end
end
