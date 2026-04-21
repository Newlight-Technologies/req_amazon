defmodule ReqAmazon.SpApi.FinancesV2 do
  @moduledoc """
  Compatibility wrapper for the current Finances Transactions API.

  Prefer `ReqAmazon.SpApi.FinancesV20240619` for new code. This module remains
  available so existing callers do not break while the library standardizes on
  date-based versioned module names.
  """

  alias ReqAmazon.SpApi.FinancesV20240619

  @doc false
  @deprecated "Use ReqAmazon.SpApi.FinancesV20240619.list_transactions/2 instead."
  @spec list_transactions(Req.Request.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  defdelegate list_transactions(req, opts), to: FinancesV20240619
end
