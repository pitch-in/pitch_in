require IEx

defmodule PitchIn.AskView do
  use PitchIn.Web, :view
  use PitchIn.NextStepView

  @colors List.to_tuple(~w(alert success cyan warning))

  def campaign_logo(campaign) do
    color = campaign_color(campaign)

    content_tag(:div, "", class: "campaign-logo #{color}")
  end

  def pitch_in_color(campaign) do
    campaign_color(campaign, 1)
  end

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

  defp name_to_number(name) do
    name
    |> to_charlist
    |> Enum.reduce(&+/2)
  end

  defp campaign_color(%{name: name}, offset \\ 0) do
    index = 
      name
      |> name_to_number
      |> (&(&1 + offset)).()
      |> rem(tuple_size(@colors))

     elem(@colors, index)
  end
end
