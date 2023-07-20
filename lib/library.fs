: binary 2 base ! ;  ( -- ) \ change base to 2
: square dup * ; ( n -- n*n ) \ math
: cube dup square * ;  ( n -- n^3 ) \ math
: fourth  square square ;  ( n -- n^3 ) \ math
: 3dup 2 pick 2 pick 2 pick ;  ( a b c -- a b c a b c ) \ stack
: 4dup 2over 2over ; ( a b c d -- a b c d a b c d ) \ stack
: print-keycode begin key dup . 32 = until ; ( keybaord -- keycode ) \ until space is pressed

