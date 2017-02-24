require IEx

defmodule PitchIn.ViewHelpers do
  import PitchIn.Router.Helpers
  use Phoenix.HTML

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
    if Mix.env == :dev do
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

    text_input(
      form,
      field,
      Keyword.merge(opts, data_toggle: "datepicker", value: formatted_value)
    )
  end

  def profession_options do
    professions = [
      "Other",
      "Campaign Finance",
      "Communications",
      "Data Manager",
      "Designer/Artist",
      "Lawyer",
      "Organizer",
      "Project Manager",
      "Web Developer"
    ]

    List.zip([professions, professions])
  end

  ##############
  # Formatters #
  ##############
  def format_date(date) do
    Timex.format!(date, "%m/%d/%Y", :strftime)
  end

  def format_phone(phone) do
    [_ | parts] = Regex.run(~r/(\d\d\d)(\d\d\d)(\d\d\d\d)/, phone)
    Enum.join(parts, "-")
  end

  def format_url(nil), do: ""
  def format_url(""), do: ""
  def format_url(url) do
    link(url, to: url)
  end

  def base_url(conn, path \\ "") do
    scheme = "#{conn.scheme}://"

    url = "#{scheme}#{conn.host}"
    url = if Mix.env != :prod, do: url <> "#{conn.port}", else: url
    url <> path
  end

  ##############
  # Components #
  ##############
  def optional_label(form, field, text \\ nil) do
    optional_tag = content_tag(:span, " (optional)", class: "input-description")

    label(form, field) do
      [text || humanize(field), optional_tag]
    end
  end
end
