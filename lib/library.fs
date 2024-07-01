: .r >r s>d r> drop . ;
: 2+ 1 1 + + ;
: 2- 1 1 - - ;
: 3Dmul dup >r * rot r@ * rot r> * rot ; ( x y z n -- nx ny nz )
: 3dup 2 pick 2 pick 2 pick ; ( a b c -- a b c a b c ) 
: 4dup 2over 2over ; ( a b c d -- a b c d a b c d ) 
: binary 2 base ! ; ( -- ) 
: c ( n[°f] -- n[°c] ) 9 5 */ 32 + . ;
: clearstack depth 0 do drop loop ;		
: clearstack depth 0 do drop loop ;		
: clearstack depth dup 0 > if 0 do drop loop then ; ( n...N -- ) 
: cube dup square * ; ( n -- n^3 ) 
: dump base @ >r hex cr ." addr: " over . cr over + swap do i c@ . loop r> base ! ; ( adr n ) 
: even? 2 mod if true else false then ; ( n -- flag ) 
: f ( n[°c] -- n[°f] ) 32 - 5 9 */ . ;
: fourth square square ; ( n -- n^4 ) 
: loopy rot rot ?do i . dup +loop drop ; ( n m l -- [n;m] l steped) 
: odd? 2 mod if false else true then ; ( n -- flag ) 
: percent * 100 / ; 
: print-keycode begin key dup . 32 = until ; ( keybaord -- keycode ) 
: s>d dup 0< ;
: say-even 110 101 118 over 4 0 do emit loop ;			
: say-odd 100 dup dup 11 + 3 0 do emit loop ;           
: sigma dup 0= if exit then 0 swap 0 do i + loop ; ( n .. m -- n+ N+1 ...M )
: sqrt 0 tuck do 1+ dup 2* 1+ +loop ; ( n -- squaredroot[n] ) 
: square dup * ; ( n -- n*n ) 
: sumstack depth dup 0> if 1- 0 do + loop then ; ( n..z -- N ) 
: syracuse begin dup and if 3 * 1+ else 2/ then dup . dup 1 until drop cr ; ( n -- n...1 ) 
