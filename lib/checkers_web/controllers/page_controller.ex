defmodule CheckersWeb.PageController do
  use CheckersWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def game(conn, params) do
  	IO.inspect(params)
    render conn, "game.html", game: params["username"], name:  params["pusername"]
  end
end
