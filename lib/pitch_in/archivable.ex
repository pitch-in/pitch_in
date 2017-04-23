defprotocol PitchIn.Archivable do
  @doc "Implement for models with an archive_reason."
  def archived?(struct)
  def archived_for?(struct, reasons)
end

defimpl PitchIn.Archivable, for: Any do
  def archived?(struct), do: !!struct.archived_reason

  def archived_for?(%{archived_reason: false}, _), do: false
  def archived_for?(struct, reasons) do
    Enum.member?(reasons, struct.archived_reason)
  end
end
