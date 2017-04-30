defmodule PitchIn.Web.AskView do
  use PitchIn.Web, :view
  use PitchIn.Web.NextStepView
  use PitchIn.Web.ArchivableView

  alias PitchIn.Web.SharedView

  def unarchive_button(conn, campaign, ask) do
    render(
      SharedView,
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
