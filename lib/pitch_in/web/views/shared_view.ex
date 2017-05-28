defmodule PitchIn.Web.SharedView do
  use PitchIn.Web, :view

  def unarchive_text(nil, archived_reason) do
    if archived_reason == "Accepted" do
      "Withdraw Acceptance"
    else
      "Unarchive"
    end
  end
  def unarchive_text(text, _) do
    text
  end
end
