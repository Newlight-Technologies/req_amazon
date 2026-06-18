defmodule ReqAmazon.SpApi.Token.Provider do
  @moduledoc """
  Behaviour for minting Login with Amazon access tokens.

  The default implementation, `ReqAmazon.SpApi.Token.Lwa`, exchanges credentials
  with Amazon's token endpoint. Applications that manage tokens elsewhere (a
  shared cache, a secrets service) can supply their own:

      config :req_amazon, token_provider: MyApp.TokenProvider

  Implementations are called behind `ReqAmazon.SpApi.Token.Cache`, which handles
  caching and single-flight refresh, so a provider only needs to perform one
  exchange per call.
  """

  alias ReqAmazon.SpApi.Error

  @typedoc """
  The OAuth grant to exchange:

  - `{:refresh_token, refresh_token}` - a seller/vendor authorization.
  - `{:client_credentials, scope}` - a grantless operation (e.g. Notifications).
  """
  @type grant :: {:refresh_token, String.t()} | {:client_credentials, String.t()}

  @callback fetch(grant(), ReqAmazon.SpApi.credentials(), keyword(), pid()) ::
              {:ok, String.t(), DateTime.t()} | {:error, Error.t()}
end
