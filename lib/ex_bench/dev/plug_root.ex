defmodule ExBench.Dev.Plug.Root do
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(%Plug.Conn{request_path: "/"} = conn, _opts) do
    root = """
    <html><body> <a href="/metrics"> metrics </a> </body></html>
    """

    conn = %{conn | resp_headers: [{"content-type", "text/html"}]}
    # |> update_resp_header("x-greeting", greeting, & &1)
    send_resp(conn, 200, root)
  end
end
