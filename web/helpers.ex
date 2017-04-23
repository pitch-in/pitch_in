defmodule PitchIn.Helpers do
  @moduledoc """
  Helpers imported into all module types.
  """

  import PitchIn.Router.Helpers

  def any_answer_path(conn, type, campaign) when type in [:new, :index, :create] do
    campaign_answer_path(conn, type, campaign)
  end
  def any_answer_path(conn, type, campaign, ask) when type in [:new, :index, :create] do
    campaign_answer_path(conn, type, campaign, ask)
  end
  def any_answer_path(conn, type, campaign, nil) when type in [:new, :index, :create] do
    campaign_answer_path(conn, type, campaign)
  end
  def any_answer_path(conn, type, answer) do 
    any_answer_path(conn, type, answer, [])
  end
  def any_answer_path(conn, type, answer, opts) when is_list(opts) do 
    cond do 
      answer.direct_campaign_id ->
        campaign_answer_path(conn, type, answer.direct_campaign_id, answer, opts)
      answer.ask == nil ->
        campaign_answer_path(conn, type, answer.campaign, answer, opts)
      true ->
        campaign_ask_answer_path(conn, type, answer.ask.campaign, answer.ask, answer, opts)
    end
  end
  def any_answer_path(conn, type, campaign, answer) do
    campaign_answer_path(conn, type, campaign, answer)
  end
  def any_answer_path(conn, type, campaign, nil, answer) do
    campaign_answer_path(conn, type, campaign, answer)
  end
  def any_answer_path(conn, type, campaign, ask, answer) do
    campaign_ask_answer_path(conn, type, campaign, ask, answer)
  end
end
