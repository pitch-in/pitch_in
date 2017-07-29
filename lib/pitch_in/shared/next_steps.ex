defmodule PitchIn.Web.NextSteps do
  @moduledoc """
  Handles calculating next steps.
  """

  defstruct [name: nil, checker: :show]

  defmacro __using__(_) do
    quote do
      import PitchIn.Web.NextSteps, only: [next_step_list: 1, step: 1, step: 2]
      @next_steps []

      # Wait until just before compiling to set up the next_steps method
      # so all the steps are registered first.
      @before_compile PitchIn.Web.NextSteps
    end
  end

  @doc """
  Filter for valid next steps.
  """
  def check(module, struct, steps) do
    steps
    |> Enum.filter(fn step -> 
      case step.checker do
        :show -> true
        checker -> apply(module, step.checker, [struct])
      end
    end)
  end

  defmacro next_step_list(do: block) do
    quote do
      unquote(block)
    end
  end

  @doc """
  Register a "next step"
  """
  defmacro step(name, checker \\ :show) do
    quote do
      step = struct(
        PitchIn.Web.NextSteps,
        %{name: unquote(name), checker: unquote(checker)}
      )

      @next_steps @next_steps ++ [step]
    end
  end

  @doc false
  defmacro __before_compile__(_env) do
    quote do
      def next_steps(struct) do
        PitchIn.Web.NextSteps.check(__MODULE__, struct, @next_steps)
      end
    end
  end
end

