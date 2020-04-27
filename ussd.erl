-module(ussd).
-export([start/0, pack/1]).

start() ->
  Table = [
    {$@, 0}, {$Δ, 16}, {$ , 32}, {$0, 48}, {$¡, 64}, {$P, 80}, {$¿, 96}, {$p, 112},
    {$£, 1}, {$_, 17}, {$!, 33}, {$1, 49}, {$A, 65}, {$Q, 81}, {$a, 97}, {$q, 113},
    {$$, 2}, {$Φ, 18}, {$", 34}, {$2, 50}, {$B, 66}, {$R, 82}, {$b, 98}, {$r, 114},
    {$¥, 3}, {$Γ, 19}, {$#, 35}, {$3, 51}, {$C, 67}, {$S, 83}, {$c, 99}, {$s, 115},
    {$è, 4}, {$Λ, 20}, {$¤, 36}, {$4, 52}, {$D, 68}, {$T, 84}, {$d, 100}, {$t, 116},
    {$é, 5}, {$Ω, 21}, {$%, 37}, {$5, 53}, {$E, 69}, {$U, 85}, {$e, 101}, {$u, 117},
    {$ù, 6}, {$Π, 22}, {$&, 38}, {$6, 54}, {$F, 70}, {$V, 86}, {$f, 102}, {$v, 118},
    {$ì, 7}, {$Ψ, 23}, {$', 39}, {$7, 55}, {$G, 71}, {$W, 87}, {$g, 103}, {$w, 119},
    {$ò, 8}, {$Σ, 24}, {$(, 40}, {$8, 56}, {$H, 72}, {$X, 88}, {$h, 104}, {$x, 120},
    {$Ç, 9}, {$Θ, 25}, {$), 41}, {$9, 57}, {$I, 73}, {$Y, 89}, {$i, 105}, {$y, 121},
    {$\n, 10}, {$Ξ, 26}, {$*, 42}, {$:, 58}, {$J, 74}, {$Z, 90}, {$j, 106}, {$z, 122},
    {$Ø, 11}, {$\e, 27}, {$+, 43}, {$;, 59}, {$K, 75}, {$Ä, 91}, {$k, 107}, {$ä, 123},
    {$ø, 12}, {$Æ, 28}, {$,, 44}, {$<, 60}, {$L, 76}, {$Ö, 92}, {$l, 108}, {$ö, 124},
    {$\r, 13}, {$æ, 29}, {$-, 45}, {$=, 61}, {$M, 77}, {$Ñ, 93}, {$m, 109}, {$ñ, 125},
    {$Å, 14}, {$ß, 30}, {$., 46}, {$>, 62}, {$N, 78}, {$Ü, 94}, {$n, 110}, {$ü, 126},
    {$å, 15}, {$É, 31}, {$/, 47}, {$?, 63}, {$O, 79}, {$§, 95}, {$o, 111}, {$à, 127}
  ],
  ets:new(chrs_table, [protected, set, named_table, {keypos, 1}]),
  ets:insert(chrs_table, Table).

pack(S) when is_list(S) ->
  pack(S, [], 0);
pack(_) ->
  io:fwrite("Invalid String!").

pack([H | T], P, Nth) when Nth =:= 0 ->
  case ets:lookup(chrs_table, H) of
    [] ->
      io:fwrite("Invalid String!");
    [{_Key, Value}] ->
      pack(T, [<<0:1, Value:7>> | P], Nth + 1)
  end;
pack([H | T], P, Nth) when 1 =< Nth, Nth =< 5 ->
  case ets:lookup(chrs_table, H) of
    [] ->
      io:fwrite("Invalid String!");
    [{_Key, Value}] ->
      NewWSize = 7 - Nth,
      PadSize = Nth + 1,
      PreWSize = 8 - Nth,
      <<NewW:NewWSize, AddPreW:Nth>> = <<Value:7>>,
      [<<PreW>> | R] = P,
      pack(
        T,
        [<<0:PadSize, NewW:NewWSize>>, <<AddPreW:Nth, PreW:PreWSize>> | R],
        Nth + 1
      )
  end;
pack([H | T], P, Nth) when Nth =:= 6 ->
  case ets:lookup(chrs_table, H) of
    [] ->
      io:fwrite("Invalid String!");
    [{_Key, Value}] ->
      <<NewW:1, AddPreW:6>> = <<Value:7>>,
      [<<PreW>> | R] = P,
      pack(T, [<<13:7, NewW:1>>, <<AddPreW:6, PreW:2>> | R], Nth + 1)
  end;
pack([H | T], P, Nth) when Nth =:= 7 ->
  case ets:lookup(chrs_table, H) of
    [] ->
      io:fwrite("Invalid String!");
    [{_Key, Value}] ->
      [<<PreW>> | R] = P,
      pack(T, [<<Value:7, PreW:1>> | R], 0)
  end;
pack([], P, _Nth) ->
  io:fwrite("~w~n", [lists:reverse(P)]).
