defmodule EngineCredo.IssueCategories do
  @moduledoc """
  Mapping of categories from Credo to Code Climate.

  Additional configuration is provided by the Code Climate engine config, which
  is a JSON file (`/config.json`) residing at the container root by default.
  """

  @lookup_table %{
    Credo.Check.Consistency.ExceptionNames => ["Style"],
    Credo.Check.Consistency.LineEndings => ["Style"],
    Credo.Check.Consistency.SpaceAroundOperators => ["Style"],
    Credo.Check.Consistency.SpaceInParentheses => ["Style"],
    Credo.Check.Consistency.TabsOrSpaces => ["Style"],

    Credo.Check.Design.AliasUsage => ["Clarity"],
    Credo.Check.Design.DuplicatedCode => ["Duplication"],
    Credo.Check.Design.TagFIXME => ["Bug Risk"],
    Credo.Check.Design.TagTODO => ["Bug Risk"],

    Credo.Check.Readability.FunctionNames => ["Style"],
    Credo.Check.Readability.LargeNumbers => ["Style"],
    Credo.Check.Readability.MaxLineLength => ["Style"],
    Credo.Check.Readability.ModuleAttributeNames => ["Style"],
    Credo.Check.Readability.ModuleDoc => ["Clarity"],
    Credo.Check.Readability.ModuleNames => ["Style"],
    Credo.Check.Readability.ParenthesesInCondition => ["Style"],
    Credo.Check.Readability.PredicateFunctionNames => ["Style"],
    Credo.Check.Readability.TrailingBlankLine => ["Style"],
    Credo.Check.Readability.TrailingWhiteSpace => ["Style"],
    Credo.Check.Readability.VariableNames => ["Style"],

    Credo.Check.Refactor.ABCSize => ["Complexity"],
    Credo.Check.Refactor.CondStatements => ["Complexity"],
    Credo.Check.Refactor.CyclomaticComplexity => ["Complexity"],
    Credo.Check.Refactor.FunctionArity => ["Complexity"],
    Credo.Check.Refactor.MatchInCondition => ["Complexity"],
    Credo.Check.Refactor.NegatedConditionsInUnless => ["Style"],
    Credo.Check.Refactor.NegatedConditionsWithElse => ["Style"],
    Credo.Check.Refactor.Nesting => ["Complexity"],
    Credo.Check.Refactor.PipeChainStart => ["Clarity"],
    Credo.Check.Refactor.UnlessWithElse => ["Style"],

    Credo.Check.Warning.BoolOperationOnSameValues => ["Bug Risk"],
    Credo.Check.Warning.IExPry => ["Bug Risk"],
    Credo.Check.Warning.IoInspect => ["Bug Risk"],
    Credo.Check.Warning.NameRedeclarationByAssignment => ["Bug Risk"],
    Credo.Check.Warning.NameRedeclarationByCase => ["Bug Risk"],
    Credo.Check.Warning.NameRedeclarationByDef => ["Bug Risk"],
    Credo.Check.Warning.NameRedeclarationByFn => ["Bug Risk"],
    Credo.Check.Warning.OperationOnSameValues => ["Bug Rusk"],
    Credo.Check.Warning.OperationWithConstantResult => ["Clarity"],
    Credo.Check.Warning.UnusedEnumOperation => ["Bug Risk"],
    Credo.Check.Warning.UnusedKeywordOperation => ["Bug Risk"],
    Credo.Check.Warning.UnusedListOperation => ["Bug Risk"],
    Credo.Check.Warning.UnusedStringOperation => ["Bug Risk"],
    Credo.Check.Warning.UnusedTupleOperation => ["Bug Risk"]
  }

  @doc """
  Get a list of Code Climate issue categories based on the given `Credo.Check`.

  Possible issue categories:

  * Bug Risk
  * Clarity
  * Compatibility
  * Complexity
  * Duplication
  * Performance
  * Security
  * Style
  """
  def for_check(nil), do: []
  def for_check(credo_check) do
    # TODO: currently, if an unknown check is found, the whole analysis will
    #       fail. A more robust alternative would be registering the miss in
    #       the error log and carrying on with the partial analysis.
    Map.fetch!(@lookup_table, credo_check)
  end
end
