require IEx

defmodule PitchIn.Web.ViewHelpers do
  import PitchIn.Web.Router.Helpers
  use Phoenix.HTML

  alias PitchIn.Web.Ask

  @moduledoc """
  This module holds random shared helpers for the views.
  """

  @doc """
  Convert an enum to an options list for a select input.
  """
  def enum_to_options(enum_module) do
    enum_module.__enum_map__()
    |> Keyword.keys
    |> Enum.reverse
    |> Enum.reduce([], fn atom, acc ->
      Keyword.put(acc, String.to_atom(titleize_key(atom)), atom)
    end)
  end

  @doc """
  Converts a snake case atom or string to a capitalized string with spaces.
  """
  def titleize_key(atom) when is_atom(atom), do: titleize_key(Atom.to_string(atom))
  def titleize_key(key) do
    key
    |> String.split("_")
    |> Enum.map_join(" ", &String.capitalize/1)
  end

  def webpack_path(conn, path) do
    if Enum.member?([:dev, :test], Mix.env) do
      "http://localhost:4001#{path}"
    else
      base_url(conn, static_path(conn, path))
    end
  end

  def us_date_input(form, field, opts \\ []) do
    value = input_value(form, field)

    formatted_value = 
      case value do
        nil ->
          nil
        value when is_binary(value) -> 
          value
        value -> 
          value
          |> Timex.format!("{M}/{D}/{YYYY}")
      end

    opts = 
      case fetch_and_delete(opts, :no_datepicker) do
        {:ok, true, opts} -> opts
        _ -> Keyword.merge(opts, data_toggle: "datepicker")
      end

    text_input(
      form,
      field,
      Keyword.merge(opts, value: formatted_value)
    )
  end

  def profession_options do
    professions = [
      "",
      "Web Development",
      "Data",
      "Design",
      "None of those"
    ]

    List.zip([professions, professions])
  end

  ##############
  # Formatters #
  ##############
  def format_date(nil), do: ""
  def format_date(""), do: ""
  def format_date(date) do
    Timex.format!(date, "%m/%d/%Y", :strftime)
  end

  def format_url(nil), do: ""
  def format_url(""), do: ""
  def format_url(url) do
    link(url, to: url)
  end

  def base_url(conn), do: base_url(conn, "")
  def base_url(PitchIn.Web.Endpoint, path) do
    "https://www.pitch-in.us" <> path
  end
  def base_url(%Plug.Conn{scheme: scheme, host: host, port: port}, path) do
    url = "#{scheme}://#{host}"

    url =
      if Mix.env == :prod do
        url
      else
        "#{url}:#{Integer.to_string(port)}"
      end

    url <> path
  end

  def twitter_to_handle(nil), do: ""
  def twitter_to_handle(twitter) do
    case Regex.run(~r/@?(.+)/, twitter) do
      [_, handle] -> "@#{handle}"
      _ -> ""
    end
  end

  def twitter_to_url(nil), do: ""
  def twitter_to_url(twitter) do
    case Regex.run(~r/@?(.+)/, twitter) do
      [_, handle] -> "https://twitter.com/#{handle}"
      _ -> ""
    end
  end

  def display_skills(%Ask{} = ask) do
    if Ecto.assoc_loaded?(ask.skills) do
      ask.skills
      |> Enum.map_join(",", fn skill -> skill.skill end)
    else
      ""
    end
  end

  ##############
  # Components #
  ##############
  def optional_label(form, field, text \\ nil) do
    note_label(form, field, "optional", text)
  end
  
  def required_label(form, field, text \\ nil) do
    note_label(form, field, "required", text)
  end

  def note_label(form, field, note, text \\ nil) do
    optional_tag = content_tag(:span, " (#{note})", class: "input-description")

    label(form, field) do
      [text || humanize(field), optional_tag]
    end
  end

  defp get_and_delete(keywords, key) when is_list(keywords) do
    case Keyword.fetch(keywords, key) do
      {:ok, value} -> {value, Keyword.delete(keywords, key)}
      _ -> {nil, keywords}
    end
  end

  defp fetch_and_delete(keywords, key) when is_list(keywords) do
    case Keyword.fetch(keywords, key) do
      {:ok, value} -> {:ok, value, Keyword.delete(keywords, key)}
      _ -> :error
    end
  end

  defp fetch_and_delete!(keywords, key) when is_list(keywords) do
    value = Keyword.fetch!(keywords, key)

    {value, Keyword.delete(keywords, key)}
  end
end
