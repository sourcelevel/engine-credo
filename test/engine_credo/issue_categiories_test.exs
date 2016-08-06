defmodule EngineCredo.IssueCategoriesTest do
  use ExUnit.Case

  alias EngineCredo.IssueCategories

  test "gets a list of code climate issues for a known credo check" do

    cateogries = IssueCategories.for_check(Credo.Check.Warning.IExPry)

    assert cateogries == ["Bug Risk"]
  end
end
