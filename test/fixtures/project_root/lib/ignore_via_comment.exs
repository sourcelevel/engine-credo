defmodule IgnoreViaComment do
  @moduledoc false

  def fun do
    # credo:disable-for-next-line Credo.Check.Design.TagTODO
    # TODO: This TODO should not be reported
  end
end
