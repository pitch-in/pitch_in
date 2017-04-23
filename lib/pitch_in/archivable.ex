defprotocol PitchIn.Archivable do
  @doc "Implement for models with an archive_reason."
  def archived?(struct)
end

defimpl PitchIn.Archivable, for: Any do
  def archived?(struct), do: !!struct.archived_reason
end
