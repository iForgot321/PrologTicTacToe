% The 3x3 board is represented by a list of 9 integers as shown below
%     0 | 1 | 2
%    ___|___|___
%     3 | 4 | 5
%    ___|___|___
%     6 | 7 | 8  
%       |   |
%
% X is represented by a 1
% O is represented by a -1
% Empty spot is represented by a 0

% Swap players, X becomes O vice versa
flip(N1, N2) :- N2 is N1*(-1).

% Starting board, useful for testing
start_board([0,0,0,0,0,0,0,0,0]).

% All win positions for tic-tac-toe
win_pos(P, [P, P, P, _, _, _, _, _, _]).
win_pos(P, [_, _, _, P, P, P, _, _, _]).
win_pos(P, [_, _, _, _, _, _, P, P, P]).
win_pos(P, [P, _, _, P, _, _, P, _, _]).
win_pos(P, [_, P, _, _, P, _, _, P, _]).
win_pos(P, [_, _, P, _, _, P, _, _, P]).
win_pos(P, [P, _, _, _, P, _, _, _, P]).
win_pos(P, [_, _, P, _, P, _, P, _, _]).

% Is true if there are no 0s (empty values) on the Board
is_full(Board) :- \+ member(0, Board).

% Is true if the game is at an ending state, third argument as the result
game_end(Board, P, P) :- win_pos(P, Board), !.
game_end(Board, _, 0) :- is_full(Board).

% Places a tile (P) on the corresponding square
% Is false if move is invalid
move([0,B,C,D,E,F,G,H,I], P, 0, [P,B,C,D,E,F,G,H,I]).
move([A,0,C,D,E,F,G,H,I], P, 1, [A,P,C,D,E,F,G,H,I]).
move([A,B,0,D,E,F,G,H,I], P, 2, [A,B,P,D,E,F,G,H,I]).
move([A,B,C,0,E,F,G,H,I], P, 3, [A,B,C,P,E,F,G,H,I]).
move([A,B,C,D,0,F,G,H,I], P, 4, [A,B,C,D,P,F,G,H,I]).
move([A,B,C,D,E,0,G,H,I], P, 5, [A,B,C,D,E,P,G,H,I]).
move([A,B,C,D,E,F,0,H,I], P, 6, [A,B,C,D,E,F,P,H,I]).
move([A,B,C,D,E,F,G,0,I], P, 7, [A,B,C,D,E,F,G,P,I]).
move([A,B,C,D,E,F,G,H,0], P, 8, [A,B,C,D,E,F,G,H,P]).

% Creates a list of all possible next moves
possible_moves(Board, Moves) :- possible_moves_helper(Board, Moves, 0).

possible_moves_helper([], [], _).
possible_moves_helper([0|TP], [X|TM], X) :- 
    X2 is X + 1,
    possible_moves_helper(TP, TM, X2), !.
possible_moves_helper([_|TP], TM, X) :- 
    X2 is X + 1,
    possible_moves_helper(TP, TM, X2), !.

% Creates a list of all possible next boards given player value
next_boards(Board, P, NB) :-
   possible_moves(Board, Moves),
   next_boards_helper(Board, P, Moves, NB).

next_boards_helper(_, _, [], []).
next_boards_helper(Board, P, [M|TM], [N|TN]) :- 
    move(Board, P, M, N),
    next_boards_helper(Board, P, TM, TN), !.

% Player function to extract best move from minimax
minimax_player(Board, P, Move) :-
    minimax(Board, P, Move-_).

% Uses basic minimax algorithm to return best move-value pair from possible moves for player P
minimax(Board, P, M-V) :-
    possible_moves(Board, Moves),
    argmax(Board, P, Moves, M-V).

% Returns max move-value pair given list of moves
argmax(Board, P, [M], M-V) :- 
    move_value(Board, P, M, V).
argmax(Board, P, [M|TM], NewM-NewV) :-
    argmax(Board, P, TM, PrevM-PrevV),
    move_value(Board, P, M, V),
    better_move(M,V,PrevM,PrevV,NewM,NewV).
    
/*
?- argmax([1,1,0,0,0,-1,0,0,-1], -1, [2,3,4,6,7], M-V).
M = 2,
V = 1.

*/

% Evaluates the value of a move given the current board position
move_value(Board, P, Move, Value) :- 
    move(Board, P, Move, NewBoard),
    board_value(NewBoard, P, Value).

% Helper function for move_value, returns negamax of next search if current board position is not a terminal state
board_value(Board, P, Value) :-
    game_end(Board, P, V),
    Value is V*P.
board_value(Board, P, Value) :-
    flip(P, NextP),
    minimax(Board, NextP, _-V),
    flip(V, Value), !.

% Helper function for arg_max, takes in two pairs and returns the one with a larger value. 
better_move(M1,V1,_,V2,M1,V1) :- V1 >= V2.
better_move(_,V1,M2,V2,M2,V2) :- V1 < V2.

/*
Test Minimax with:

?- start_board(B), minimax(B, 1, M-V).
B = [0, 0, 0, 0, 0, 0, 0, 0, 0],
M = V, V = 0.

?- minimax([1,1,0,0,0,-1,0,0,-1], 1, M-V).
M = 2,
V = 1.

?- minimax([1,1,0,0,0,-1,0,0,-1], -1, M-V).
M = 2,
V = 1.

*/

% Displays board in regular tic-tac-toe fashion
% Test with: display_board([0,1,1,-1,-1,0,1,0,-1]).
display_board([A,B,C,D,E,F,G,H,I]) :- nl,
    write(' '), display(A), write(' | '), 
    display(B), write(' | '), display(C), nl,
    write('-----------'), nl,
    write(' '), display(D), write(' | '), 
    display(E), write(' | '), display(F), nl,
    write('-----------'), nl,
    write(' '), display(G), write(' | '), 
    display(H), write(' | '), display(I), nl.


% Displays the individual tic-tac-toe box
display(0) :- write(' '), !.
display(P) :- P = 1 -> write('X') ; write('O').

% Prompts the User to enter a move
prompt(N) :- 
  display_moves,
  read(N).

% Displays Possible Moves
display_moves :-     
     write('Select an Integer from 0 to 8 inclusive. End your choice with a period ').

% Prompts the User to select if they want to move first or second
start :-
    write('Select [0] to choose X, or [1] to choose O. End your choice with a period'), nl,
    read(N),
    (
        N == end_of_file -> halt(0) ;
        (N \= 0, N \= 1) -> write('Invalid choice'), nl, start ; 
            N = 0 -> play([0,0,0,0,0,0,0,0,0], human, 1) ; 
                     play([0,0,0,0,0,0,0,0,0], computer, 1)
    ).

% Prompts the player (either human or minimax algorithm) to select a move and updates the game state,
% then calls play for the next player
play(Board, human, P) :- display_board(Board), prompt(N),
    (N == end_of_file -> halt(0) ;
    move(Board, P, N, Updated_board) ->
        ((game_end(Updated_board, P, V) -> 
            display_board(Updated_board), !, game_over(V) ;
            flip(P, Q)), play(Updated_board, computer, Q));
        write('Invalid move. \n'),
            play(Board, human, P)).

play(Board, computer, P) :- minimax_player(Board, P, Chosen_move), move(Board, P, Chosen_move, Updated_board), write('The computer made a move \n'), (game_end(Updated_board, P, V) -> 
        display_board(Updated_board), game_over(V) ;
        flip(P, Q), play(Updated_board, human, Q)).

% Displays the game over message and asks the user if they want to play again
game_over(V) :-
  (V = 1 -> write('X won!') ; (V = -1 -> write('O won!') ;    
  write('Tie!'))), nl, nl,
  game_over_2.
    
game_over_2 :-
  write('Do you want to play again?'), nl,
  write('Choose 1 for Yes or 0 for No.'),
  read(M),
  (M = 1 -> start ; M = 0 -> write('Goodbye! \n') ; M == end_of_file -> halt(0) ;  
    write('Invalid choice \n\n'), game_over_2).
