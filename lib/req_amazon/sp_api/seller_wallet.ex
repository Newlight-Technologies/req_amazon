defmodule ReqAmazon.SpApi.SellerWallet do
  @moduledoc """
  Seller Wallet v2024-03-01 operations.
  """

  import ReqAmazon

  @base_path "/finances/transfers/wallet/2024-03-01"

  @spec list_accounts(Req.Request.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def list_accounts(%Req.Request{} = req, opts \\ []) when is_list(opts) do
    params =
      %{}
      |> put_param("nextPageToken", Keyword.get(opts, :next_page_token))

    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/accounts", params: params)
  end

  @spec get_account(Req.Request.t(), String.t()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_account(%Req.Request{} = req, account_id) when is_binary(account_id) do
    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/accounts/#{path_segment(account_id)}"
    )
  end

  @spec get_account_balance(Req.Request.t(), String.t()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_account_balance(%Req.Request{} = req, account_id) when is_binary(account_id) do
    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/accounts/#{path_segment(account_id)}/balance"
    )
  end

  @spec get_transfer_preview(Req.Request.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_transfer_preview(%Req.Request{} = req, opts) when is_list(opts) do
    source_account_id = Keyword.fetch!(opts, :source_account_id)
    destination_account_id = Keyword.fetch!(opts, :destination_account_id)
    transfer_amount_value = Keyword.fetch!(opts, :transfer_amount_value)
    transfer_amount_currency_code = Keyword.fetch!(opts, :transfer_amount_currency_code)

    params =
      %{}
      |> put_param("sourceAccountId", source_account_id)
      |> put_param("destinationAccountId", destination_account_id)
      |> put_param("transferAmount.value", transfer_amount_value)
      |> put_param("transferAmount.currencyCode", transfer_amount_currency_code)

    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/transferPreview", params: params)
  end

  @spec list_transactions(Req.Request.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def list_transactions(%Req.Request{} = req, account_id, opts \\ [])
      when is_binary(account_id) and is_list(opts) do
    params =
      %{}
      |> put_param("nextPageToken", Keyword.get(opts, :next_page_token))

    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/accounts/#{path_segment(account_id)}/transactions",
      params: params
    )
  end

  @spec create_transaction(Req.Request.t(), String.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def create_transaction(%Req.Request{} = req, account_id, payload)
      when is_binary(account_id) and is_map(payload) do
    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/accounts/#{path_segment(account_id)}/transactions",
      json: payload
    )
  end
end
