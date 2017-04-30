defmodule PitchIn.Web.SearchView do
  use PitchIn.Web, :view

  @colors List.to_tuple(~w(alert success cyan warning))

  def page_data("index.html", assigns) do
    if assigns.current_user do
      %{
        title: "Search Needs",
        description: "Search for ways to best help progressive campaigns around the country.",
       }
    end
  end

  def campaign_logo(campaign) do
    color = campaign_color(campaign)

    content_tag(:div, "", class: "campaign-logo #{color}")
  end

  def pitch_in_color(campaign) do
    campaign_color(campaign, 1)
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

