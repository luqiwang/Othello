defmodule Othello.Game do

  # A Game is a map with the following keys:
  #  - :name - the name of the game
  #  - :host - the name of the user who's currently drawing
  #  - :word - the word to be drawn

  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def put(gname, game) do
    Agent.update(__MODULE__, &Map.put(&1, gname, game))
    game
  end

  def get(gname) do
    Agent.get(__MODULE__, &Map.get(&1, gname))
  end

  def get_rooms do
    room_name_list = Agent.get(__MODULE__, &(&1))
                      |> Map.keys
    list_to_key_value_pair(room_name_list);
  end

  def get_available_rooms do
    all_rooms = Agent.get(__MODULE__, &(&1))|>Map.values();
    available_rooms = Enum.filter(all_rooms, fn(x) -> x|>Map.get(:state)|>Map.get("player2") == "" end)
    room_name_list = Enum.map(available_rooms, &(Map.get(&1,:name)))
    # IO.puts "^^^^^^^^^^^^^^^^^"
    # IO.inspect list_to_key_value_pair(room_name_list);
    list_to_key_value_pair(room_name_list);
  end

  def get_busy_rooms do
    all_rooms = Agent.get(__MODULE__, &(&1))|>Map.values();
    available_rooms = Enum.filter(all_rooms, fn(x) -> x|>Map.get(:state)|>Map.get("player2") != "" end)
    room_name_list = Enum.map(available_rooms, &(Map.get(&1,:name)))
    # IO.puts "^^^^^^^^^^^^^^^^^"
    # IO.inspect list_to_key_value_pair(room_name_list);
    list_to_key_value_pair(room_name_list);
  end

  def list_to_key_value_pair(lst) do
    lst = lst|>Enum.map(fn(x) -> {x, x} end);
    map = for {key, val} <- lst, into: %{}, do: {String.to_atom(key), val}
    map|>Map.to_list();
  end

  def join(gname, user) do
    game = get(gname)

    if game do
      game
    else
      game = %{ name: gname, host: user, state: init_state() }
      put(gname, game)
    end
  end

  def init_state do
      %{
        availables: [ [5, 4, 3, 4], [3, 2, 3, 4], [2, 3, 4 ,3], [4, 5, 4, 3] ],
        tiles: [0,0,0,0,0,0,0,0,
                0,0,0,0,0,0,0,0,
                0,0,0,0,0,0,0,0,
                0,0,0,2,1,0,0,0,
                0,0,0,1,2,0,0,0,
                0,0,0,0,0,0,0,0,
                0,0,0,0,0,0,0,0,
                0,0,0,0,0,0,0,0],
        current: 1,
        blackScore: 2,
        whiteScore: 2,
        player1: "",
        player2: "",
      }
  end

  def click (game index)do
    %{availables: availables,
    tiles: tiles,
    current: current,
    blackScore: blackScore,
    whiteScore: whiteScore,
    player1: player1,
    player2: player2 } = game
    move = [index / 8, index % 8];
    tiles = tiles;
    board = list2Arr(tiles, 8);
    currAvailables = availables;
    pid = (current==1)?1:2;
    oid = (current==1)?2:1;
    nextB = nextBoard(board, move, currAvailables, pid);
    nextA = nextAvailables(nextB, oid);
    nextTiles = arr2List(nextB, 8)
    if pid == 1 do
      blackScore = getScore(nextB, pid)
      whiteScore = getScore(nextB, oid)
      newState = %{current: 2, blackScore: blackScore,
                      whiteScore: whiteScore, tiles: nextTiles,
                      availables: nextA, player1: player1,
                      player2:
                      player2}
    else
      blackScore = getScore(nextB, oid)
      whiteScore = getScore(nextB, pid)
      newState = %{current: 1, blackScore: blackScore,
                      whiteScore: whiteScore, tiles: nextTiles,
                      availables: nextA, player1: player1,
                      player2: player2}
    end
    newState
  end

  def aiplay(game, index) do
    %{availables: availables,
    tiles: tiles,
    current: current,
    blackScore: blackScore,
    whiteScore: whiteScore,
    player1: player1,
    player2: player2 } = game
    move = [index / 8, index % 8];
    board = list2Arr(tiles, 8);
    currAvailables = availables;
    nextB = nextBoard(board, move, currAvailables, 1);
    nextA = nextAvailables(nextB, 2);
    nextTiles = arr2List(nextB, 8);
    blackScore = getScore(nextB, 1)
    whiteScore = getScore(nextB, 2)
    newState = %{current: 2, blackScore: blackScore,
                    whiteScore: whiteScore, tiles: nextTiles,
                    availables: nextA};
    if length(nextA) == 0 do
      newState['current'] = 1
      nextA = nextAvailables(nextB, 1);
      if length(nextA) == 0 do
        newState[end] = true
      end
    end
    newState
  end

  def searchPos(curr, pos, dir) do
    i = Enum.at(pos, 0)
    j = Enum.at(pos, 1)
    oid =  Enum.at[curr, i] |> Enum.at(j)
    cond do
      dir == 1 ->
        m = i-1;
        n = j-1;
        if m>=0 && n>=0 do
          m = m - 1
          n = n - 1
        end
      dir == 2 ->
        m = i-1;
        n = j;
        if m>=0 && n>=0 do
          m = m - 1
      dir == 3 ->
        m = i-1;
        n = j+1;
        if m>=0 && n<size do
          m = m - 1
          n = n + 1
        end
      dir == 4 ->
        m = i-1;
        n = j;
        if m>=0 && n>=0 do
          m = m - 1
      dir == 5 ->
        m = i-1;
        n = j;
        if m>=0 && n>=0 do
          m = m - 1
        end
      dir == 6 ->
        m = i-1;
        n = j;
        if m>=0 && n>=0 do
          m = m - 1
        end
      dir == 7 ->
        m = i-1;
        n = j;
        if m>=0 && n>=0 do
          m = m - 1
          n = n - 1
        end
      dir == 8 ->
        m = i-1;
        n = j + 1;
        if m>=0 && n>=0 do
          m = m - 1
          n = n + 1
        end
      true ->
    end
    [m, n]
  end

  def getScore(curr, pid) do
      size = len(curr)
      socre = Enum.reduce(curr, 0)
  end

  def nextBoard(board, move, currAvailables, current) do
    size = length(cur)
    oid = 1
    if pid == 1 do
      oid = 2
    end
    positions = []
    pos1 = searchPos(curr, [0,0], 0)
    pos2 = searchPos(curr, [0,0], 8)
    pos3 = searchPos(curr, [0,0], 8)
    cond do
      length(pos1) != 0 ->
        pos1 =  List.insert_at(pos1, 0, 0)
        pos1 =List.insert_at(pos1, 0, 0)
        boards =List.insert_at(positions, 0, pos1)
      length(pos2) != 0 ->
        pos2 =  List.insert_at(pos2, 0, 0)
        pos2 =List.insert_at(pos2, 0, 0)
        boards =List.insert_at(positions, 0, pos2)
      length(pos3) != 0 ->
        pos3 =  List.insert_at(pos3, 0, 0)
        pos3 =List.insert_at(pos3, 0, 0)
        boards =List.insert_at(positions, 0, pos3)
      true ->
    end
    now =  Enum.at(curr, 0) |> Enum.at(size - 1)
    if now == pid do
      length(pos1) != 0 ->
        pos1 =  List.insert_at(pos1, 0, 0)
        pos1 =List.insert_at(pos1, size - 1, 0)
        boards =List.insert_at(positions, 0, pos1)
      length(pos2) != 0 ->
        pos2 =  List.insert_at(pos2, 0, 0)
        pos2 =List.insert_at(pos2, size - 1, 0)
        boards =List.insert_at(positions, 0, pos2)
      length(pos3) != 0 ->
        pos3 =  List.insert_at(pos3, 0, 0)
        pos3 =List.insert_at(pos3, size - 1, 0)
        boards =List.insert_at(positions, 0, pos3)
      true ->
    else
      length(pos1) != 0 ->
        pos1 =  List.insert_at(pos1, size - 1, 0)
        pos1 =List.insert_at(pos1, 0, 0)
        boards =List.insert_at(positions, 0, pos1)
      length(pos2) != 0 ->
        pos2 =  List.insert_at(pos2, size - 1, 0)
        pos2 =List.insert_at(pos2, 0, 0)
        boards =List.insert_at(positions, 0, pos2)
      length(pos3) != 0 ->
        pos3 =  List.insert_at(pos3, size - 1, 0)
        pos3 =List.insert_at(pos3, 0, 0)
        boards =List.insert_at(positions, 0, pos3)
      true ->
    end
    boards
  end

  def nextAvailables(nextB, current) do
    size = length(cur)
    oid = 1
    if pid == 1 do
      oid = 2
    end
    positions = []
    pos1 = searchPos(curr, [0,0], 0)
    pos2 = searchPos(curr, [0,0], 8)
    pos3 = searchPos(curr, [0,0], 8)
    cond do
      length(pos1) != 0 ->
        pos1 =  List.insert_at(pos1, 0, 0)
        pos1 =List.insert_at(pos1, 0, 0)
        positions =List.insert_at(positions, 0, pos1)
      length(pos2) != 0 ->
        pos2 =  List.insert_at(pos2, 0, 0)
        pos2 =List.insert_at(pos2, 0, 0)
        positions =List.insert_at(positions, 0, pos2)
      length(pos3) != 0 ->
        pos3 =  List.insert_at(pos3, 0, 0)
        pos3 =List.insert_at(pos3, 0, 0)
        positions =List.insert_at(positions, 0, pos3)
      true ->
    end
    now =  Enum.at(curr, 0) |> Enum.at(size - 1)
    if now == pid do
      length(pos1) != 0 ->
        pos1 =  List.insert_at(pos1, 0, 0)
        pos1 =List.insert_at(pos1, size - 1, 0)
        positions =List.insert_at(positions, 0, pos1)
      length(pos2) != 0 ->
        pos2 =  List.insert_at(pos2, 0, 0)
        pos2 =List.insert_at(pos2, size - 1, 0)
        positions =List.insert_at(positions, 0, pos2)
      length(pos3) != 0 ->
        pos3 =  List.insert_at(pos3, 0, 0)
        pos3 =List.insert_at(pos3, size - 1, 0)
        positions =List.insert_at(positions, 0, pos3)
      true ->
    else
      length(pos1) != 0 ->
        pos1 =  List.insert_at(pos1, size - 1, 0)
        pos1 =List.insert_at(pos1, 0, 0)
        positions =List.insert_at(positions, 0, pos1)
      length(pos2) != 0 ->
        pos2 =  List.insert_at(pos2, size - 1, 0)
        pos2 =List.insert_at(pos2, 0, 0)
        positions =List.insert_at(positions, 0, pos2)
      length(pos3) != 0 ->
        pos3 =  List.insert_at(pos3, size - 1, 0)
        pos3 =List.insert_at(pos3, 0, 0)
        positions =List.insert_at(positions, 0, pos3)
      true ->
    end
    positions
  end


  def minMaxDecision do
    i = Enum.at(pos, 0)
    j = Enum.at(pos, 1)
    oid =  Enum.at[curr, i] |> Enum.at(j)
    cond do
      dir == 1 ->
        m = i-1;
        n = j-1;
        if m>=0 && n>=0 do
          m = m - 1
          n = n - 1
        end
      dir == 2 ->
        m = i-1;
        n = j;
        if m>=0 && n>=0 do
          m = m - 1
      dir == 3 ->
        m = i-1;
        n = j+1;
        if m>=0 && n<size do
          m = m - 1
          n = n + 1
        end
      dir == 4 ->
        m = i-1;
        n = j;
        if m>=0 && n>=0 do
          m = m - 1
      dir == 5 ->
        m = i-1;
        n = j;
        if m>=0 && n>=0 do
          m = m - 1
        end
      dir == 6 ->
        m = i-1;
        n = j;
        if m>=0 && n>=0 do
          m = m - 1
        end
      dir == 7 ->
        m = i-1;
        n = j;
        if m>=0 && n>=0 do
          m = m - 1
          n = n - 1
        end
      dir == 8 ->
        m = i-1;
        n = j + 1;
        if m>=0 && n>=0 do
          m = m - 1
          n = n + 1
        end
      true ->
    end
    [m,n]
  end

  def aimove(game, index) do
    %{availables: availables,
    tiles: tiles,
    current: current,
    blackScore: blackScore,
    whiteScore: whiteScore,
    player1: player1,
    player2: player2 } = game
    move = [index / 8, index % 8];
    board = list2Arr(tiles, 8);
    currAvailables = availables;
    nextB = nextBoard(board, move, currAvailables, 1);
    nextA = nextAvailables(nextB, 2);
    nextTiles = arr2List(nextB, 8);
    blackScore = getScore(nextB, 1)
    whiteScore = getScore(nextB, 2)
    newState = %{current: 2, blackScore: blackScore,
                    whiteScore: whiteScore, tiles: nextTiles,
                    availables: nextA};
    if length(nextA) == 0 do
      newState['current'] = 1
      nextA = nextAvailables(nextB, 1);
      if length(nextA) == 0 do
        newState[end] = true
      end
    end
    newState
  end

  def isGameEnd(board, player) do
    zeroCount = 0
    Enum.reduce(board, fn(x, acc) -> Enum.reduce(row, fn(x, acc) -> x + acc end, 0), 0)
    oid = 1
    if pid == 1 do
      oid = 2
    end
    bothNoMove = length(nextAvailables(board, currPlayer)) == 0
                  && lenth(nextAvailables(board, opponent)) == 0
    zeroCount == 0 || bothNoMove
  end
end
