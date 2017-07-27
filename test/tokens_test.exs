defmodule PitchIn.Tags.TokensTest do
  use PitchIn.DataCase

  alias PitchIn.Tokens

  describe "tokens" do
    test "returns a 32-character string by default" do
      assert String.length(Tokens.token()) === 32
    end

    test "returns a 6-character string if requested" do
      assert String.length(Tokens.token(6)) === 6
    end
  end
end

