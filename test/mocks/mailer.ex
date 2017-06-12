defmodule PitchIn.Test.Mocks.Mailer do
  def deliver_later(email) do
    send self(), {:deliver_later, email}
  end
end
