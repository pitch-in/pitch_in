defmodule PitchIn.StagingAuth do
  def init(_opts) do
    BasicAuth.init(use_config: {:pitch_in, :staging_auth})
  end

  def call(conn, opts) do
    if Application.get_env(:pitch_in, :server_env) == "staging" do
      conn
      |> BasicAuth.call(opts)
    else
      conn
    end
  end
end
