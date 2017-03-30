defmodule PitchIn.AnswerView do
  use PitchIn.Web, :view
  use PitchIn.NextStepView
  alias PitchIn.Campaign
  alias PitchIn.Ask

  @reason_texts %{
    no_campaign_response: "I haven't heard back, yet.",
    remove: "Remove Answer",
    no_volunteer_response: "Can't contact volunteer",
    accept: "Accept Answer",
    reject: "Not Interested",
  }

  def any_answer_path(conn, type, answer) do
    if answer.direct_campaign do
      any_answer_path(conn, type, answer.direct_campaign, answer)
    else
      any_answer_path(conn, type, answer.campaign, answer.ask, answer)
    end
  end
  def any_answer_path(conn, type, campaign, answer) do
    campaign_answer_path(conn, type, campaign, answer)
  end
  def any_answer_path(conn, type, campaign, nil, answer) do
    campaign_answer_path(conn, type, campaign, answer)
  end
  def any_answer_path(conn, type, campaign, ask, answer) do
    campaign_ask_answer_path(conn, type, campaign, ask, answer)
  end

  def archive_button(conn, answer, reason, button_class) do
    path = any_answer_path(conn, :update, answer)
    render_archive(conn, path, reason, button_class)
  end
  def archive_button(conn, campaign, answer, reason, button_class) do
    archive_button(conn, campaign, nil, answer, reason, button_class)
  end
  def archive_button(conn, campaign, ask, answer, reason, button_class) do
    path = any_answer_path(conn, :update, campaign, ask, answer)
    render_archive(conn, path, reason, button_class)
  end

  defp render_archive(conn, path, reason, button_class) do
    render "_archive.html", conn: conn, path: path, reason: reason, reason_text: @reason_texts[reason], button_class: button_class
  end
end
