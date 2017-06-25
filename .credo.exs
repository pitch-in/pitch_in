%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/pitch_in/"]
      },
      checks: [
        {Credo.Check.Readability.ModuleDoc, false},
        # Temporary, while I get windows line endings straightened out.
        {Credo.Check.Consistency.LineEndings, false}
      ]
    }
  ]
}