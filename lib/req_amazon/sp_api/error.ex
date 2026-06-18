defmodule ReqAmazon.SpApi.Error do
  @moduledoc """
  Exception raised for SP-API failures.
  """

  alias ReqAmazon.SpApi.Headers

  defexception [:status, :errors, :message, :request_id, :retry_after, :rate_limit]

  @type error_item :: map()

  @type t :: %__MODULE__{
          status: integer() | nil,
          errors: [error_item()],
          message: String.t(),
          request_id: String.t() | nil,
          retry_after: non_neg_integer() | nil,
          rate_limit: float() | nil
        }

  @spec from_response(integer() | nil, term(), keyword()) :: t()
  def from_response(status, body, meta \\ [])

  def from_response(status, %{"errors" => errors}, meta) when is_list(errors) do
    %__MODULE__{
      status: status,
      errors: errors,
      message: build_message(status, errors),
      request_id: meta[:request_id],
      retry_after: meta[:retry_after],
      rate_limit: meta[:rate_limit]
    }
  end

  def from_response(status, body, meta) do
    %__MODULE__{
      status: status,
      errors: [],
      message: build_generic_message(status, body),
      request_id: meta[:request_id],
      retry_after: meta[:retry_after],
      rate_limit: meta[:rate_limit]
    }
  end

  @spec wrap(term()) :: t()
  def wrap(%__MODULE__{} = error), do: error

  def wrap(%Req.Response{status: status, body: body} = response) do
    from_response(status, body,
      request_id: Headers.request_id(response),
      retry_after: Headers.retry_after(response),
      rate_limit: Headers.rate_limit(response)
    )
  end

  def wrap(%{__exception__: true} = exception) do
    %__MODULE__{
      status: nil,
      errors: [],
      message: Exception.message(exception)
    }
  end

  def wrap(other) do
    %__MODULE__{
      status: nil,
      errors: [],
      message: inspect(other)
    }
  end

  defp build_message(status, errors) do
    summary =
      errors
      |> Enum.map(&format_error/1)
      |> Enum.reject(&(&1 == ""))
      |> Enum.join("; ")

    case {status, summary} do
      {nil, ""} -> "Amazon SP-API request failed"
      {nil, _} -> summary
      {_status, ""} -> "Amazon SP-API request failed with status #{status}"
      {_status, _} -> "Amazon SP-API request failed with status #{status}: #{summary}"
    end
  end

  defp build_generic_message(nil, body), do: "Amazon SP-API request failed: #{inspect(body)}"

  defp build_generic_message(status, body),
    do: "Amazon SP-API request failed with status #{status}: #{inspect(body)}"

  defp format_error(%{"code" => code, "message" => message})
       when is_binary(code) and is_binary(message) do
    "#{code}: #{message}"
  end

  defp format_error(%{"message" => message}) when is_binary(message), do: message
  defp format_error(_error), do: ""
end
