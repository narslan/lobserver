defmodule Lobserver.Router do
  use Plug.Router
  use Plug.Debugger
  require Logger

  plug(Plug.Logger)

  plug(:redirect_index)
  plug(:match)
  # plug(Corsica, origins: "*", allow_headers: :all, allow_methods: :all)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: JSON
  )

  plug(:dispatch)

  get "/_memory" do
    conn
    |> WebSockAdapter.upgrade(Lobserver.WebSocket.Memory, [], timeout: 60_000)
    |> halt()
  end

  forward("/dist", to: Lobserver.Router.StaticResources)
  forward("/assets", to: Lobserver.Router.AssetResources)

  match _ do
    send_resp(conn, 404, "not found")
  end

  def redirect_index(%Plug.Conn{path_info: path} = conn, _opts) do
    # IO.inspect(path, label: "path")

    case path do
      [] ->
        %{conn | path_info: ["dist", "index.html"]}

      ["assets", file] ->
        %{conn | path_info: ["assets", file]}

      _ ->
        conn
    end
  end
end
