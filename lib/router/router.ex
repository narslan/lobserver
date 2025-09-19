defmodule Lobserver.Router do
  use Plug.Router
  use Plug.Debugger
  require Logger

  plug(Plug.Logger)

  plug(Plug.Static,
    at: "/",
    from: {:lobserver, "priv/static/web/dist"},
    gzip: false
  )

  plug(:match)
  plug(:dispatch)

  get "/_memory" do
    conn
    |> WebSockAdapter.upgrade(Lobserver.WebSocket.Memory, [], timeout: 60_000)
    |> halt()
  end

  get "/_metrics" do
    conn
    |> WebSockAdapter.upgrade(Lobserver.WebSocket.Metrics, [], timeout: 60_000)
    |> halt()
  end

  # SPA fallback: alle anderen Routen auf index.html
  match _ do
    conn = put_resp_content_type(conn, "text/html")
    send_file(conn, 200, Path.join(:code.priv_dir(:lobserver), "static/web/dist/index.html"))
  end
end
