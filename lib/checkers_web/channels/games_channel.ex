defmodule CheckersWeb.GamesChannel do
  use CheckersWeb, :channel

  alias Checkers.Game

  #def join("games:lobby", payload, socket) do
  #  if authorized?(payload) do
  #    {:ok, socket}
  #  else
  #    {:error, %{reason: "unauthorized"}}
  #  end
  #end

  def join("games:" <> name, payload, socket) do
    if authorized?(payload) do
      IO.inspect(payload)
      #[gamename, playername] = String.split(name, " ")
      game = Checkers.GameBackup.load(name) || Game.new()
      #if (game.player1 == "none" or game.player2 == "none") do
      #    game = Game.assignPlayer(game,payload.playername)
      #end
      socket = socket
      |> assign(:game, game)
      |> assign(:name, name)
      Checkers.GameBackup.save(socket.assigns[:name],game)
      {:ok, %{"join" => name, "game" => Game.client_view(game)}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("assignPlayer", %{"id" => id}, socket) do
     IO.inspect("inside gamechannel assignplayer")
     game = Checkers.GameBackup.load(socket.assigns[:name])
     game1 = Game.assignPlayer(game,id)
     Checkers.GameBackup.save(socket.assigns[:name],game1)
     socket = assign(socket, :game, game1)
     broadcast! socket, "assignPlayer", %{ "game" => Game.client_view(game1)}
     {:reply, {:ok, %{ "game" => Game.client_view(game1)}}, socket}
  end

  def handle_in("movepawn", %{"id" => id, "pawn_id" => pawn_id, "color" => color}, socket) do
    IO.inspect("inside channel movePawn")
    IO.inspect(socket)

    game = Checkers.GameBackup.load(socket.assigns[:name])
    game1 = Game.movepawn(game,id,pawn_id,color)
    IO.inspect('this is in handlein_movepawn')
    IO.inspect(socket.assigns[:name])
    Checkers.GameBackup.save(socket.assigns[:name],game1)
    socket = assign(socket, :game, game1)
    broadcast! socket, "movepawn", %{ "game" => Game.client_view(game1)}
    {:reply, {:ok, %{ "game" => Game.client_view(game1)}}, socket}

  end

  def handle_in("getNextPos", %{"id" => id, "color" => color}, socket) do
    IO.inspect("inside channel getNextPos")
    game0 = Checkers.GameBackup.load(socket.assigns[:name]) ||  Game.new()
    game1 = Game.getNextPos(game0,id,color)
    IO.inspect('this is in handlein_getNextPos')
    IO.inspect(socket.assigns[:name])
    Checkers.GameBackup.save(socket.assigns[:name],game1)
    socket = assign(socket, :game, game1)
    broadcast! socket, "getNextPos", %{ "game" => Game.client_view(game1)}
    {:reply, {:ok, %{ "game" => Game.client_view(game1)}}, socket}

  end



  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (games:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
