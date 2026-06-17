defmodule ReqAmazon.SpApi.Invoices do
  @moduledoc """
  Invoices v2024-06-19 operations.
  """

  import ReqAmazon

  @base_path "/tax/invoices/2024-06-19"

  @spec get_invoices_attributes(Req.Request.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_invoices_attributes(%Req.Request{} = req, opts) when is_list(opts) do
    marketplace_id = Keyword.fetch!(opts, :marketplace_id)
    params = %{} |> put_param("marketplaceId", marketplace_id)

    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/attributes", params: params)
  end

  @spec get_invoices_document(Req.Request.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_invoices_document(%Req.Request{} = req, invoices_document_id, _opts \\ [])
      when is_binary(invoices_document_id) do
    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/documents/#{path_segment(invoices_document_id)}"
    )
  end

  @spec create_invoices_export(Req.Request.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def create_invoices_export(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(req, :post, "#{@base_path}/exports", json: payload)
  end

  @spec get_invoices_exports(Req.Request.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_invoices_exports(%Req.Request{} = req, opts) when is_list(opts) do
    marketplace_id = Keyword.fetch!(opts, :marketplace_id)

    params =
      %{}
      |> put_param("marketplaceId", marketplace_id)
      |> put_param("dateStart", Keyword.get(opts, :date_start))
      |> put_param("dateEnd", Keyword.get(opts, :date_end))
      |> put_param("status", Keyword.get(opts, :status))
      |> put_param("pageSize", Keyword.get(opts, :page_size))
      |> put_param("nextToken", Keyword.get(opts, :next_token))

    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/exports", params: params)
  end

  @spec get_invoices_export(Req.Request.t(), String.t()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_invoices_export(%Req.Request{} = req, export_id) when is_binary(export_id) do
    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/exports/#{path_segment(export_id)}"
    )
  end

  @spec get_invoices(Req.Request.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_invoices(%Req.Request{} = req, opts) when is_list(opts) do
    marketplace_id = Keyword.fetch!(opts, :marketplace_id)
    transaction_identifier_name = Keyword.fetch!(opts, :transaction_identifier_name)
    transaction_identifier_id = Keyword.fetch!(opts, :transaction_identifier_id)

    params =
      %{}
      |> put_param("marketplaceId", marketplace_id)
      |> put_param("transactionIdentifierName", transaction_identifier_name)
      |> put_param("transactionIdentifierId", transaction_identifier_id)
      |> put_param("nextToken", Keyword.get(opts, :next_token))

    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/invoices", params: params)
  end

  @spec get_invoice(Req.Request.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_invoice(%Req.Request{} = req, invoice_id, opts)
      when is_binary(invoice_id) and is_list(opts) do
    marketplace_id = Keyword.fetch!(opts, :marketplace_id)
    params = %{} |> put_param("marketplaceId", marketplace_id)

    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/invoices/#{path_segment(invoice_id)}",
      params: params
    )
  end
end
