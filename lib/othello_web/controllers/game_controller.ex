defmodule OthelloWeb.GameController do
  use OthelloWeb, :controller
  alias Othello.Game

  def show(conn, %{"gname" => gname}) do
    user = get_session(conn, :user)
    IO.puts "------xx------"
    IO.inspect conn;
    game = Game.get(gname)

    state = game[:state]
    player1 = Map.get(state, "player1");
    player2 = Map.get(state, "player2");
    curr = Map.get(state, "current");

    host = (user == game[:host])

    if !is_nil(user) and !is_nil(game) do
      render conn, "show.html", user: user, host: host, game: gname, state: game[:state]
    else
      conn
      |> put_flash(:error, "Bad user or game chosen")
      |> redirect(to: "/")
    end
  end

  def ai(conn, _params) do
    render conn, "ai.html"
  end

  def join(conn, %{"join_data" => join}) do

    available_rooms = Game.get_available_rooms()
    busy_rooms = Game.get_busy_rooms();

    IO.puts "@@@@@@@@@@@@"
    IO.inspect join;
    game_name = join["game"];
    game_user = join["user"];

    user_valid = String.length(game_user)!=0;
    game_valid = String.length(game_name)!=0;

    valid = user_valid and game_valid;


    if valid do
      game = Game.join(join["game"], join["user"]);
      conn
      |> put_session(:user, join["user"])
      |> redirect(to: "/g/" <> join["game"])
    else
      conn|>put_flash(:error, "form information incomplete.")
      |>redirect(to: "/");
    end
  end


end
