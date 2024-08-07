%
% Factorial
%

-module(factorial).
-export([start/0]).

%
% -- Public -- 
%
start() ->
  io:format("fac1(10) = " ++ integer_to_list(fac1(5)) ++ "~n"),
  io:format("fac2(10) = " ++ integer_to_list(fac2(5)) ++ "~n"),
  io:format("fac3(10) = " ++ integer_to_list(fac3(5)) ++ "~n").

%
% -- Private -- 
%   
fac1(0) -> 1;
fac1(N) -> N * fac1(N-1).

fac2(0) -> 1;
fac2(N) -> N * fac2(N-1).

fac3(N) when (N >  0) -> N * fac3(N-1);
fac3(N) when (N =< 0) -> 1.
