defmodule ReqAmazon.SpApi.Response do
  @moduledoc """
  Normalized result of a successful SP-API call.

  `body` is the decoded response with Amazon's `payload` envelope stripped (when
  present) and is otherwise untouched. The remaining fields surface metadata
  Amazon returns on every response that callers previously had to recover by
  hand:

  - `next_token` - the pagination continuation token, normalized across Amazon's
    inconsistent casing and nesting (see `ReqAmazon.SpApi.Pagination`). `nil`
    when there is no next page.
  - `rate_limit` - the per-operation rate from `x-amzn-RateLimit-Limit`
    (requests/second), or `nil` when Amazon omits the header (it is not sent on
    every response).
  - `request_id` - Amazon's `x-amzn-RequestId`, the value to quote in support
    cases.
  - `status` / `headers` - the raw HTTP status and response headers.
  """

  alias ReqAmazon.SpApi.{Headers, Pagination}

  defstruct [:body, :status, :headers, :next_token, :rate_limit, :request_id]

  @type t :: %__MODULE__{
          body: term(),
          status: non_neg_integer(),
          headers: %{optional(String.t()) => [String.t()]},
          next_token: String.t() | nil,
          rate_limit: float() | nil,
          request_id: String.t() | nil
        }

  @doc false
  @spec from_req(Req.Response.t()) :: t()
  def from_req(%Req.Response{status: status, body: raw_body, headers: headers} = response) do
    # `next_token` is read from the raw envelope, before the `payload` wrapper is
    # stripped, because FBA Inventory nests `pagination` beside `payload`.
    %__MODULE__{
      body: ReqAmazon.unwrap_payload(raw_body),
      status: status,
      headers: headers,
      next_token: Pagination.next_token(raw_body),
      rate_limit: Headers.rate_limit(response),
      request_id: Headers.request_id(response)
    }
  end
end
