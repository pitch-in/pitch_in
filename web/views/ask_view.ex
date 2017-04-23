defmodule PitchIn.AskView do
  use PitchIn.Web, :view
  use PitchIn.NextStepView
  use PitchIn.ArchivableView

  def unarchive_button(conn, campaign, ask) do
    render(
      PitchIn.SharedView,
      "_unarchive_button.html",
      conn: conn,
      data: ask,
      type: :ask, 
      action: campaign_ask_path(conn, :update, campaign, ask)
    )
  end

  def archive_button(conn, campaign, ask, opts \\ []) do
    opts =
      Keyword.merge(
        [
          to: campaign_ask_path(conn, :edit, campaign, ask, archive: true),
          class: "alert button"
        ],
        opts 
      )
    
    if !ask.archived_reason do
      link("Archive", opts)
    end
  end
end
