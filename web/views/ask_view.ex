require IEx

defmodule PitchIn.AskView do
  use PitchIn.Web, :view

  @colors List.to_tuple(~w(red green yellow, cyan))

  def campaign_logo(campaign) do
    color = campaign_logo_color(campaign)

    content_tag(:div, "", class: "campaign-logo #{color}")
  end

  defp name_to_number(name) do
    name
    |> to_charlist
    |> Enum.reduce(&+/2)
  end

  defp campaign_logo_color(%{name: name}) do
    index = 
      name
      |> name_to_number
      |> rem(tuple_size(@colors))

     elem(@colors, index)
  end
end
