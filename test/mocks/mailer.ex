defmodule PitchIn.Test.Mocks.Mail.Mailer do
  def deliver_later(email) do
    send self(), {:deliver_later, email}
  end
end
