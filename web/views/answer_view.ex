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

  def archive_button(conn, answer, reason, button_class) do
    path = any_answer_path(conn, :update, answer)
    render_archive_button(conn, path, reason, button_class)
  end
  def archive_button(conn, campaign, answer, reason, button_class) do
    archive_button(conn, campaign, nil, answer, reason, button_class)
  end
  def archive_button(conn, campaign, ask, answer, reason, button_class) do
    path = any_answer_path(conn, :update, campaign, ask, answer)
    render_archive_button(conn, path, reason, button_class)
  end

  def archive_link(conn, answer) do
    link("Remove Answer", to: any_answer_path(conn, :edit, answer, archive: "true"), class: "alert button")
  end

  def unarchive_button(conn, answer) do
    render(
      PitchIn.SharedView,
      "_unarchive_button.html",
      conn: conn,
      data: answer,
      type: :answer, 
      action: any_answer_path(conn, :update, answer)
    )
  end

  def card(conn, campaign, ask, answer, do: buttons) do
    render "_card.html", conn: conn, campaign: campaign, ask: ask, answer: answer, buttons: buttons
  end

  defp render_archive_button(conn, path, reason, button_class) do
    render "_archive_reason_button.html", conn: conn, path: path, reason: reason, reason_text: @reason_texts[reason], button_class: button_class
  end
end
