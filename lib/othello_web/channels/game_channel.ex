defmodule OthelloWeb.GameChannel do
  use OthelloWeb, :channel
  alias Othello.Game
  alias Phoenix.Socket

  def join("game:" <> gname, payload, socket) do
    game = Game.get(gname)
    state = game|>Map.get(:state);
    IO.inspect(game)
    if authorized?(payload) do
      IO.puts "socket id-----------------"
      IO.inspect socket
      socket = socket
      |> Socket.assign(:name, gname)
      |> Socket.assign(:user, payload["user"])
      IO.puts "socket id-----------------"
      IO.inspect socket
      # broadcast socket, "chess", state
      {:ok, %{ "game" => game, "page_user" => payload["user"]}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("chess", %{"state" => state}, socket) do
    IO.puts("broadcsat!!!!!!!")
    gname = socket.assigns[:name]
    user  = socket.assigns[:user]
    game =  %{ name: gname, host: user, state: state }
    Game.put(gname, game)
    cond do
      is_nil(user) ->
        IO.inspect {"invalid user", socket.assigns[:user]}
        {:reply, {:ok, %{}}, socket}
      is_nil(game) ->
        IO.inspect {"invalid game", socket.assigns[:name]}
        {:reply, {:ok, %{}}, socket}
      true ->
        broadcast socket, "chess", state
        {:reply, {:ok, %{}}, socket}
    end
  end

  def handle_in("click", %{"state" => state, "index" => index}, socket) do
    game = Game.click(state, index)
    socket = assign(socket, :game, game)
     {:reply, {:ok, %{ "game" => game}}, socket}
  end

  def handle_in("aiplay", %{"state" => state, "index" => index}, socket) do
    game = Game.aiplay(state, index)
    gname = socket.assigns[:name]
    user  = socket.assigns[:user]
    game =  %{ name: gname, host: user, state: state }
    broadcast socket, "chess", state
    {:reply, {:ok, %{}}, socket}
  end

  def handle_in("restart", _params, socket) do
    game = Game.new()
    gname = socket.assigns[:name]
    user  = socket.assigns[:user]
    game =  %{ name: gname, host: user, state: state }
    Game.put(gname, game)
    broadcast socket, "chess", state
    {:reply, {:ok, %{}}, socket}
  end


  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
