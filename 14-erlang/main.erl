-module(main).
-define(ROWS, 103).
-define(COLS, 101).
-define(SECONDS, 100).

% 82 is the appearance of the first "tree". 101 is the cycle time to see the next "tree".
% puzzle 2 starts an infinite loop, user must manually terminate!!
main(_) ->
  Robots = read_robots([]),
  puzzle_1(Robots),
  puzzle_2(Robots, 82).

mod_pos(A, B) ->
  Rem = A rem B,
  if
    Rem < 0 -> Rem + B;
    true -> Rem
  end.

puzzle_1(Robots) ->
  Locations = lists:map(
    fun ({{Px, Py}, {Vx, Vy}}) ->
      {mod_pos(Px + ?SECONDS * Vx, ?COLS), mod_pos(Py + ?SECONDS * Vy, ?ROWS)}
    end,
    Robots
  ),
  Mx = ?COLS div 2,
  My = ?ROWS div 2,
  Q1 = lists:filter(fun ({X, Y}) -> (X < Mx) and (Y < My) end, Locations),
  Q2 = lists:filter(fun ({X, Y}) -> (X > Mx) and (Y < My) end, Locations),
  Q3 = lists:filter(fun ({X, Y}) -> (X < Mx) and (Y > My) end, Locations),
  Q4 = lists:filter(fun ({X, Y}) -> (X > Mx) and (Y > My) end, Locations),
  Total = lists:foldl(fun (Ps, Acc) -> Acc * erlang:length(Ps) end, 1, [Q1, Q2, Q3, Q4]),
  io:format("Puzzle 1: ~w~n", [Total]).

puzzle_2(Robots, Seconds) ->
  Locations = lists:map(
    fun ({{Px, Py}, {Vx, Vy}}) ->
      {mod_pos(Px + Seconds * Vx, ?COLS), mod_pos(Py + Seconds * Vy, ?ROWS)}
    end,
    Robots
  ),
  io:format("~n~n~w~n", [Seconds]),
  print_grid(Locations),
  puzzle_2(Robots, Seconds + 101).

print_grid(Locations) ->
  SLocations = sets:from_list(Locations),
  lists:foreach(
    fun (Y) -> 
      Row = lists:map(
        fun (X) ->
          case sets:is_element({X, Y}, SLocations) of
            true -> "D";
            false -> "."
          end
        end,
        lists:seq(1, ?COLS)
      ),
      io:format("~s~n", [Row])
    end,
    lists:seq(1, ?ROWS)
  ).

read_coords(St) ->
  Trimmed = string:trim(St, both, "\r\n"),
  [_, Coord] = string:lexemes(Trimmed, "="),
  [Xst, Yst] = string:lexemes(Coord, ","),
  {erlang:list_to_integer(Xst), erlang:list_to_integer(Yst)}.

read_robots(Robots) ->
  case io:get_line("") of
    eof -> Robots;
    Line ->
      [Pst, Vst] = string:lexemes(Line, " "),
      {Px, Py} = read_coords(Pst),
      {Vx, Vy} = read_coords(Vst),
      read_robots([{{Px, Py}, {Vx, Vy}} | Robots])
  end.
