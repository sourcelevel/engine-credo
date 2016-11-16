defmodule EngineCredo.IssueCategoriesTest do
  use ExUnit.Case

  alias EngineCredo.IssueCategories

  test "gets a list of code climate issues for a known credo check" do
    categories = IssueCategories.for_check(Credo.Check.Warning.IExPry)

    assert categories == "Bug Risk"
  end
end
