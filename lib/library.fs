: binary 2 base ! ; ( -- ) 
: square dup * ; ( n -- n*n ) 
: cube dup square * ; ( n -- n^3 ) 
: fourth  square square ; ( n -- n^4 ) 
: 3dup 2 pick 2 pick 2 pick ; ( a b c -- a b c a b c ) 
: 4dup 2over 2over ; ( a b c d -- a b c d a b c d ) 
: print-keycode begin key dup . 32 = until ; ( keybaord -- keycode ) 
: loopy rot rot ?do i . dup +loop drop ; ( n m l -- [n;m] l steped) 
: sqrt 0 tuck do 1+ dup 2* 1+ +loop ; ( n -- squaredroot[n] ) 
: clearstack depth dup 0 > if 0 do drop loop then ; ( n...N -- ) 
: even? 2 mod if true else false then ; ( n -- flag ) 
: odd? 2 mod if false else true then ; ( n -- flag ) 
: sumstack depth dup 0> if 1- 0 do + loop then ; ( n..z -- N ) 
: say-odd 100 dup dup 11 + 3 0 do emit loop ;           
: say-even 110 101 118 over 4 0 do emit loop ;			
: clearstack depth 0 do drop loop ;		
: 3Dmul dup >r * rot r@ * rot r> * rot ; ( x y z n -- nx ny nz )
: sigma dup 0= if exit then 0 swap 0 do i + loop ; ( n .. m -- n+ N+1 ...M )
: c ( n[°f] -- n[°c] ) 9 5 */ 32 + . ;
: f ( n[°c] -- n[°f] ) 32 - 5 9 */ . ;
: clearstack depth 0 do drop loop ;		
