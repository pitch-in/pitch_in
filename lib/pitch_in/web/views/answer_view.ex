defmodule PitchIn.Web.AnswerView do
  use PitchIn.Web, :view
  use PitchIn.Web.NextStepView
  use PitchIn.Web.ArchivableView

  alias PitchIn.Web.Campaign
  alias PitchIn.Web.Ask
  alias PitchIn.Web.SocialView
  alias PitchIn.Web.SharedView

  @reason_texts %{
    "Accepted" => "Accept Answer"
  }

  def archive_button(conn, answer, reason, button_class) do
    path = any_answer_path(conn, :update, answer)
    render_archive_button(conn, path, answer, reason, button_class)
  end
  def archive_button(conn, campaign, answer, reason, button_class) do
    archive_button(conn, campaign, nil, answer, reason, button_class)
  end
  def archive_button(conn, campaign, ask, answer, reason, button_class) do
    path = any_answer_path(conn, :update, campaign, ask, answer)
    render_archive_button(conn, path, answer, reason, button_class)
  end

  def archive_link(conn, answer, opts \\ []) do
    unless answer.archived_reason do
      class = Keyword.get(opts, :class, "alert button")
      text = Keyword.get(opts, :text, "Remove Answer")

      link(text, to: any_answer_path(conn, :edit, answer, archive: "true"), class: class)
    end
  end

  def unarchive_button(conn, answer, opts \\ []) do
    class = Keyword.get(opts, :class, "warning button")
    allowed_reasons = Keyword.get(opts, :allowed_reasons, nil)

    render(
      SharedView,
      "_unarchive_button.html",
      conn: conn,
      data: answer,
      type: :answer, 
      class: class,
      action: any_answer_path(conn, :update, answer),
      allowed_reasons: allowed_reasons
    )
  end

  def card(conn, campaign, ask, answer, do: buttons) do
    render "_card.html", conn: conn, campaign: campaign, ask: ask, answer: answer, buttons: buttons
  end

  defp render_archive_button(conn, path, answer, reason, button_class) do
    render "_archive_reason_button.html", conn: conn, path: path, answer: answer, reason: reason, reason_text: @reason_texts[reason] || reason, button_class: button_class
  end
end
