require IEx

defmodule PitchIn.AskView do
  use PitchIn.Web, :view
  use PitchIn.NextStepView

  def unarchive_button(conn, campaign, ask) do
    render("_unarchive.html", conn: conn, campaign: campaign, ask: ask)
  end

  def archive_button(conn, campaign, ask, opts \\ []) do
    opts =
      Keyword.merge([
        to: campaign_ask_path(conn, :edit, campaign, ask, archive: true),
        class: "alert button"],
        opts 
      )
    
    if !ask.archived_reason do
      link("Archive", opts)
    end
  end
end
