defmodule IgnoreViaAttribute do
  @moduledoc false

  @lint {Credo.Check.Design.TagTODO, false}
  def fun do
    # TODO: This TODO should not be reported
  end
end
