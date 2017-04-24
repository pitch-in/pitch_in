defmodule Mix.Tasks.PitchIn.CreateSkills do
  @moduledoc """
  Create ask skills from existing ask professions
  """
  @shortdoc "Create ask skills from existing ask professions"

  use Mix.Task

  import Mix.Ecto
  import PitchIn.Repo
  import Ecto.Query

  alias PitchIn.Repo
  alias PitchIn.Web.Ask
  alias PitchIn.Web.Skill

  def run(_args) do
    [:postgrex, :ecto, :tzdata]
    |> Enum.each(&Application.ensure_all_started/1)
    Repo.start_link

    asks_query = 
      from a in Ask,
      where: not is_nil(a.profession)

    asks = Repo.all(asks_query)

    new_skills = 
      asks
      |> Enum.map(fn ask ->
        %{skill: ask.profession, ask_id: ask.id, inserted_at: Timex.now, updated_at: Timex.now}
      end)
      |> IO.inspect

    Repo.insert_all(Skill, new_skills)
  end
end
