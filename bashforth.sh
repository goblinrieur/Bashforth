#!/bin/bash
set -u
# set -x
# required bash 2.04 or more recent, but probably depends on bash 3.x now, since v0.54
version="0.63c"
# bashforth - forth interpreter in bash
# v0.03 20030219 ls added bool, logical, constants, fixed nip and other
# v0.04 20030219 ls added ?dup, fixed 0branch
# v0.05 20030220 ls reviewed auto-inc/dec addressing modi, fixed 0branch again
# v0.06 20030220 ls constants redone
# v0.07 20030220 ls added lshift rshift
# v0.08 20030220 ls emit outputs correctly decimal numbers on stack. thanks dufflebunk
# v0.09 20030220 ls simplified asc table building.
# v0.10 20030220 ls accept works. uses external command  cut  right now.
# v0.11 20030220 ls added pad c@ @ c! ! count
# v0.12 20030221 ls key and accept return asciis, rather than chars.
#                        emit, type, find work on asciis
# v0.13 20030221 ls word,  input stream parser, query, interpret, quit added
#                        this enables multiple words on input line
# v0.14 20030221 ls ?number added, extended interpreter. numbers work, but
#                         only decimal
# v0.15 20030221 ls added deferred words, improved error handler. first
#                        defining words. creation of variables works.
# v0.16 20030221 ls immediate, colon definitions work
# v0.17 20030222 ls improved prompt, added ' and ['], compiles numbers
#                        find returns the word#, can get to xt, name and header flags.
#                        added 2*, 2/, negate, begin..again  begin..until
# v0.18 20030222 ls if..then, if..else..then begin..while..repeat work. structure is tested
# v0.19 20030222 ls do..loop, i, j, negative numbers input, commented out debug output
#                        from virtual machine for 50% speed improvement
# v0.20 20030223 ls added  does>  2+
# v0.21 20030223 ls hide, reveal, constant. started redoing error handler. loops broken
# v0.22 20030223 ls loops fixed. ?comp
# v0.23 20030223 ls added  catch throw ?exec  . fixed key (space). ctrl chars return asc of space too.
# v0.24 20030224 ls added  ." , s" , $, .(      fixed bug in word .  tests stack underflow
# v0.26 20030225 ls added s( \ (
# v0.27 20030225 ls errorhandler through throw. top level error handler catches gracefully
# v0.28 20030225 ls speed increase of about 50 %
# v0.29 20030225 ls exit, outputs asciis 0...31, speeded up compares, improved move
# v0.30 20030225 ls .. outputs decimal (quick), . respects base (slower), number input respects base
#                        added hex, decimal, binary
# v0.31 20030226 ls pictured number output added ( <# # #s #> #>type sign )
# v0.31a20030226 ls hold (forgotten, pictured number output), rot, -rot
# v0.32 20030226 ls system (shells to command), pack ( a n -- x ) packs string to string on tos,
#                        unpack (explodes tos string to memory), cleaned up messy accept and name
# v0.33 20030226 ls added bash, fixed does>, started include.  sent out for does> fix
# v0.34 20030226 ls first rough version of include works. no nesting yet. thanks deltab for getting the source into vars
# v0.35 20030226 ls fixed backslash bug in include.
# this is for the time being the last version of bashforth. i'm now busy working on a target translator which allows to generate source
# for several languages, including bash
# v0.36 20030305 ls added pick, found a way to split input stream into chars w/o requiring external cut, as a result
#                        including source files works much quicker. bashforth is "pure" now.
# v0.37 20030309 ls number output with . doesn't complain about zero-string stack elements.
#                        stack order  reversed.  added */  */mod  ?do  leave . speeded up type
# v0.37a20030310 ls fixed include, broken in 0.37 because of changed do
# v0.37b20030310 ls fixed include again. * in source was expanded to file list
# v0.37c20030310 ls fixed ." which had cr appended
# v0.38 20030310 ls added skip, scan, tuck, compare
# v0.39 20030310 ls added min max abs fill doc,   abort throws,  removed ?exec
# v0.40 20030311 ls bugfix for 2.05a, hopefully for 2.04 too. incompatible with 2.03
# v0.41 20030311 ls redone doc. this implementation writes line number to word body. added rnd +! cell cells chars
# v0.42 20030311 ls more consistent use of addressing modes, added
#                date&time.fixed negative number big introduced with .40
# v0.42a20030313 ls changed email address. verified function on bash 2.04. thanks, stepan
# v0.42b20030315 ls fixed sign bug, result of v0.40, added >name
# v0.43 20030316 ls added .name, roll, improved locate and >name, last points now to cfa of last word
# v0.44 20030316 ls added cell+ char +loop ?leave **
# v0.45 20030316 ls added 2>r 2r>, cleaned up code, speeded up some words (type, #, words)
# v0.46 20030316 ls added literal, compiling, addressing modes optimizations
# v0.46a20030316 ls bugfix addressing modes v0.46. untested with bash 2.04
# v0.47 20030319 ls added black yellow green red blue magenta cyan white fg bg colors
# v0.47a20030320 ls added normal bold underscore reverse attr@ attr!
# v0.47b20030320 ls added at home
# v0.47c20030325 ls added ?at (doesn't work yet) number /string right$ left$
# v0.48 20030325 ls added system2 2swap dup$ drop$ depth$ 2dup$ swap$ over$ nip$ rot$ push$ pop$ append$
#                        modified left$ right$, these work on stop string stack element now
#                        modified doc to show word description, besides stack effect. optimized does>
# v0.48a20030325 ls added/modified descriptions
# v0.48b20030526 ls replaced hide/reveal against versions by h-peter recktenwald. these ones seem
#                        to be less sensitive for the used version of bash
# v0.48c20030527 ls bug fix "hold", bug discovered by h-peter recktenwald
# v0.48d20030530 ls merged with h-peter recktenwald's patches: info, hold, immediate
#                        hi-level . is about 50 % slower than former primitive version
#                        (output 1000 number 7.5 rather than 4.7 seconds now)
# v0.48e20030808 ls attempted fix of ?number, number and * for bash v2.04 on BEOS
# v0.49 20030809 ls fixed time&date, broken after 2.04 fix in 0.48e
# v0.49a20030809 ls fixed loop +loop for 2.04
# v0.49b20030818 ls found a better fix for time&date
# v0.49c20031019 ls fixed : foo ." *" ;  bug which displayed current directory
# v0.49d20031019 ls added for .. next, compatible with i j  , added spaces.
#                        made count tolerant for non-initialized memory locations
# v0.49e20031019 ls attempt to include nonexisting file throws -38
# 0.50  20031028 ls added see  (does not decompile, shows script source instead)
# 0.50a 20040101 ls fixed : $structured, not structured in until
# 0.50b 20040928 ls optional doc <word> uses sed rather than tail - recently tail args were changed.
# 0.51  20041004 ls added 2@ and 2!, suggested by Antonio Maschio
# 0.52  20041116 ls slow (1sec) version of key?, added secs and epoche
# 0.52a 20041123 ls can emit ascii <32 correctly
# 0.53  20041217 ls ***STACK EFFECT OF 'WORD' HAS CHANGED***  previously ( c -- a n ), it is now ( c -- cstring ), with string at HERE
#                        previous a was pointing into input stream. STREAM was added, providing function of former WORD. new WORD uses STREAM.
#                        added :noname  . bugfix compare .
# 0.53a 20041220 ls trapped Ctrl-C: warm start
# 0.53b 20041220 ls added >body body>
# 0.53c 20041222 ls include appends .bashforth extension and retries if file not found
# 0.54  20050119 ls fixed bug in move
# 0.54a 20050222 ls added ?
# 0.54b 20050331 ls div/0 exception
# 0.55  20060314 ls unhandled exceptions quit, not warmstart, leaving radix untouched
# 0.55a 20061003 lsls removed unnecessary cat in see
# 0.55b 20071220 ls reversed logic in key?
#                changed comparison against empty string to -z test in exception and 2 other
#                speeded up by using [[ or (( instead of [
#                simplified logic here and there
# 0.55c20071223 ls exception accepts literal
# 0.56 20071229 ls line numbers (for doc and see) dont't require info #LINENO per word anymore
#                        changed all function foo { } to  foo() { }
#                        passed command line is executed
#                        string stack underflow detected
#                        string stack emptied on warm and cold
#                        fixed bug in include
#                        string stack operators testing for underflow
#                        first mac debian package
# 0.56a 20071231 ls fix in key (returns ascii for space now)
#                        added nanoseconds, time (measures execution time)
#                        made distance between HERE and PAD a config variable: PADAWAY
#                        tib size configurable too
#                        simplified some logic
#                        changed find to resemble a bit more the standard
#                        using new find in interpreter loop
#                        using printf instead of echo
#                        misc small speedups (or rather, removed a few slowdowns)
# 0.56b intermediate testing speed improvements
# 0.56c 20080114 ls added control characters in output ascii table
#                        using (( cond )) && action where appropriate
#         changing spacing to accommodate fte syntax highlighting better
#         some more arithmetic optimisations
# 0.57 20091005 ls  key?, needs bash 4, waits 1ms. single char buffer,
#                        read by key?, used by key and accept.
# 0.57a 20101022 ls fixed bug in (s") which must have slipped into with
#                          a recent version
#        slight optimisation of abs
# 0.57b 20101101 ls added env, removed "upload" handling, which went into a source file by the same name.
#                          renamed "timestamp" to "epoche"
#                          renamed "merge$" to "append$"
#           attempts to source ~/.bashforthrc, use to set variables:
#                              sources=/path/to/sourcefiles     # "include" reads source files from that dir,
#                                                               # and defaults to current directory if unset.
#                          added "type$"
# 0.57c 20101112 ls simplified exception, and some style improvements sprinkled all over the code
#                          user interrupt (ctrl-c) improved
# 0.57d 20101127 ls removed load and loadfrom. reversed logic on -z string tests.
#                          removed -n from string tests.
# 0.58  20101220 ls replaced right$. simpler, shorter, faster
#           changed result generation of key?
#                          bug fix number - may have another, dropping sign with hex -ff
# 0.58a  20110819 ls fixed bug with multiple consecutive revealheader
# 0.58b  20120312 ls multi line compound arithmetic expressions problem with bash 4.2-1 at hash
# 0.58c  20170609 ls A syntax error affecting bash v4.4 was fixed.
#            ASCII to char translation array initialised with char(1) now.
# 0.59   20190806 ls uses $EPOCHSECONDS instead of $(date +%s) for epoche when running under bash 5+
# 0.59a  20190821 ls some more quoting, removed saving IFS contents in key and key?
#                    changed !(( to ! (( to pacify shellcheck.
# 0.60   20190830 ls added restore, restore-from, save-system, saveas, contributed by quaraman-me
#                    type$ didn't drop top string stack element. Fixed
#                    changed output of .s$ to vertical. top of string stack is uppermost output line.
#                    Fixed error in type when outputting % char.
# 0.60a  20190830 ls .s$ autodecrements
# 0.60b  20190830 ls added nlimit, producing highest signed number.
#                    fixed rshift: making it logical right shift while bash does arithmetic right shift.
#                    partially (attempted to fix) sign problem in #
# 0.60c  20190830 ls see prevented from mangling output lines.
# 0.60d  20190830 ls fixed expanding * in restore.
# 0.60e  20190830 ls fixed: number input accepting some non numeric chars. A side effect is that digits > 10 are now case insensitive.
#                    added: 2swap d= sub$
#                    changed: left$ and right$ call sub$, ?number uses (fixed) number
# 0.60f  20190831 ls fixed: wrong number output when outputting a number with only msb set (nlimit+1)
#                    changed (already in a previous version): executing save-system and restore without file name write to/read from $sources directory
# 0.61   20190831 ls functionally reverted to 0.60f, undoing changes to floored modulo and division, causing more damage than benefits
# 0.61a  20190831 ls fixed: (s") bug from 0.57a again, seems to have reinstroduced when reverting.
# 0.62   20190909 ls added: !sourcepath complements sourcepath
#                    changed: set working variables in compare to local
# 0.63   20190909 ls changed: words attempts to break lines
# 0.63a  20201121 ls fixed: exposed one superfluous "epoche" header 
# 0.63a  20230719 fp added few words & forked project & changed editor to standard vim 
# 0.63b  20230720 fp 0> -! hidecursor showcursor was missing & add few full forth words in lib/ default library file 
#					 add colors for terminal without breaking fg/bg funtions 
# 0.63c  20240709 libs/* few examples and a main library update
#   known bugs:
#     catch:   doesn't return the thrown value correctly sometimes
#     include: max line length in source files isn't checked against TIBSIZE
#     env: without name abort with "invalid variable name"
#     see: doesn't look into included source files
#     /:  while modulo and divison of /mod and */mod are floored,  / isn't.

# global variables:
# ip           virtual machine instruction pointer
# w            virtual machine word pointer.
# sp           data stack pointer
# rp           return stack pointer
# wc           word count, number of headers. used as name field address
# temp         scratch. never used to carry data across words/functions
# tos          top of stack, stack cache
# dp           dictionary pointer, "here". new words are added at this address
# state        compile/interpret switch
# catchframe   pointer to latest frame
# ssp          string stack pointer
# global variable arrays:
# m            memory
# s            data stack
# r            return stack
# h            headers (word names)
# hf           header flags (precedence bit, smudge bit)
# x            execution tokens
# asc          characters array, indexed by decimal ascii
# ss           string stack

################################# example primitive #####################################
# # ( -- ) description  # stack diagram, description
# revealheader "foo"    # name in forth vocabulary
# code foo foo          # name in bash, call of executable
#          --------- executable may follow, but may also be seperated ----------
# foo() {               # executable implementated as function
#    s[++sp]=$tos       # stack push
#    tos=${s[sp--]}     # stack pop
# }                     # empty lines follows
#
#########################################################################################

################################# example hi-level word #####################################
# # ( -- ) description  # stack diagram, description
# revealheader "foo"    # name in forth vocabulary
# colon foo           \ # name in bash. line continuation
#   $word $word $word \ # compiled words, line continuation
#   $word $word         # last line does not need continuation, empty line follows
#
#########################################################################################

# -------------------------------------------------------------------------
# ---                           configuration                           ---
# -------------------------------------------------------------------------
PADAWAY=256                      # distance between HERE and PAD
TIBSIZE=256
PROMPT="ok"
LOADING=""
EDITOR=vim
# -------------------------------------------------------------------------
# ---                  allocate memory / initialize vars                ---
# -------------------------------------------------------------------------
m=()                             # memory
s=()                             # data stack
r=()                             # return stack
h=()                             # headers, wordcount
hf=()                            # header flags, corresponding to headers
x=()                             # execution tokens, corresponding to headers
ss=()                            # string stack

declare -i ip w                  # instruction and word pointer of virtual machine
declare -i s0=0 sp               # data stack origin and pointer
declare -i r0=0 rp               # return stack origin and pointer
declare -i ss0=0 ssp             # string stack origin and pointer
declare -i dp=0                  # dictionary pointer
declare -i wc=0                  # word count
declare -i state=0               # compiler/interpreter switch
declare -i catchframe=0          # pointer to latest catch frame, or 0

sources="."                      # unless overwritten from .bashforthrc or !sourcepath

# ---- bitmasks ------------------------------------------------------------

# declared as read-only, integer
declare -ri precedencebit=1      # immediate words
declare -ri smudgebit=2          # hide/reveal headers

# --------------- build decimal>ascii lookup table for emit ----------------
asc=()
for i in {1..255}; do
   asc[i]=$(echo -en "\\x$(printf '%x' $i)")  # ascii 0-255
done

# ------------------------------- "macros" ---------------------------------

# --- array of variables and functions which will be removed after the script has been loaded ---
# --- only to use with words which help building bashforth, but aren't required at runtime ---
remove=()

transient()  {
   remove[${#remove[@]}]=$1
}

transient remove              # remove must either be non-transient, or the first transient.
transient transient
transient compile

compile() {
   for nextword in $*
   do
      m[dp++]="${nextword}"
   done
}

transient code
code()  {
   (( $1 = dp ))
   shift
   m[dp++]="$*"
}

dovar()   {
   s[++sp]="$tos"
   tos="$w"
}

transient var
var() {
   (( $1 = dp ))
   compile dovar 0
}

var lastxt

header() {
   m[lastxt+1]=$dp
   x[wc]=$dp
   hf[wc]=0
   h[wc++]="$1"                  # word name
}

reveal() {
   ((hf[wc-1] |= smudgebit))
}

hide() {
   ((hf[wc-1] &= ~smudgebit))
}

transient revealheader
revealheader() {
   ((m[dp++]=BASH_LINENO[0]-1))  # source line number - consider to put file/line into an array with source locations
   header "$1"
   reveal
}

transient semicolon
semicolon() {
   compile "$unnest"
   reveal
}

transient colon
colon()  {
   (( $1 = dp ))
   shift 1
   compile nest
   compile "$*"
   semicolon
}

doconst() {
   s[++sp]=$tos
   tos=${m[w]}
}

transient constant
constant() {
   (( $1 = dp ))
   shift
   compile doconst "$1"
}

dodefer() {  ip=$w; }

transient defer
defer() {
   (( $1 = dp ))
   compile dodefer 0
}

# -----------------------------------------------------------------------------
# -------------------------------- system start -------------------------------
# -----------------------------------------------------------------------------

revealheader ""

# warm start vector
# ( ??? -- ) init stacks and vars, restart interpreter
revealheader "warm"
defer warm

# -------------------------------------------------------------------------
# ---                      ctrl-c: user interrupt                       ---
# -------------------------------------------------------------------------

#trap "echo bashforth finished" EXIT
#trap "echo err" ERR
#trap "echo return" RETURN

ctrl-c() {
   tos=-28
   ip=$warm
   printf '%s\n' " ${throw[-tos]}"
   return 0
}
trap  ctrl-c 2

# -----------------------------------------------------------------------------
# ------------------------------ virtual machine ------------------------------
# -----------------------------------------------------------------------------

nest() {
   r[++rp]=$ip
   ip=$w
}

# ( -- ) exits the current definition. compiled by ;
revealheader "exit"
code unnest unnest
unnest() {
   ip=${r[rp--]}
}

# ----------------------------------------------------------------------------
# --------------------------- constants, variables ---------------------------
# ----------------------------------------------------------------------------

msb=1; until ((msb<0)); do ((msb<<=1)); done

# ( -- -1 )
revealheader "true"
constant minone -1

# ( -- -1 )
revealheader "-1"
constant minone -1

# ( -- 0 )
revealheader "false"
constant zero 0

# ( -- 0 )
revealheader "0"
constant zero 0

# ( -- 1 )
revealheader "cell"
constant one 1

# ( -- 1 )
revealheader "1"
constant one 1

# ( -- 2 )
revealheader "2"
constant two 2

# ( -- 3 )
revealheader "3"
constant three 3

# ( -- 4 )
revealheader "4"
constant four 4

# ( -- 5 )
revealheader "5"
constant five 5

# ( -- 6 )
revealheader "6"
constant six 6

# ( -- 27 ) ASCII of Escape char
revealheader "esc"
constant esc 27

# ( -- 32 ) ASCII of space char
revealheader "bl"
constant bl 32

# ( -- x ) highest signed number
revealheader "nlimit"
constant nlimit $((msb-1))

# ( -- a )
revealheader ">in"
var in

# ( -- a ) flags/switches interpret/compile mode
revealheader "state"
var state

# ( -- a ) variable, pointing to cfa of last word
revealheader "last"
constant last $((lastxt+1))

# ( -- a ) a memory area, relative to here, for user purposes
revealheader "tib"
var tib
   ((dp+=TIBSIZE))

# ( -- a ) variable containing the input and output radix
revealheader "base"
var base

# ----------------------------------------------------------------------------
# ------------------------------- run time -----------------------------------
# ----------------------------------------------------------------------------

# ( -- ) run time word - to be compiled by another word
revealheader "branch"
code branch branch
branch() {   ((ip+=m[ip])); }

# ( f -- ) run time word - to be compiled by another word
revealheader "0branch"
code branch0 branch0
branch0() {
   if ((tos)); then
      ((ip++))
   else
      ((ip+=m[ip]))
   fi
   tos=${s[sp--]}
}

# ( f -- ) run time word - compiled internally instead of  0= branch0
code branchx branchx
branchx() {
   if ((tos)); then
      ((ip+=m[ip]))
   else
      ((ip++))
   fi
   tos=${s[sp--]}
}

# ( -- x ) when compiled into a word, the contents of the cell under $ip are pushed to stack and skipped from execution
revealheader "lit"
code lit lit
lit() {
   s[++sp]=$tos
   tos=${m[ip++]}
}

# ( a n -- x ) assembles asciis at m[a] to string in tos
revealheader "pack"
code pack pack
pack() {
   i=$tos
   temp=${s[sp--]}
   unset tos
   while ((i--)); do
      tos+="${asc[m[temp++]]}"
   done
}

#pack() {
#   temp="${s[sp--]}"
#   temp2=$tos
#   tos="$(printf '\x0' $(printf '%x' "${m[@]:temp:temp2}"))"
#   echo ">>> $tos <<<"
#   printf '\x0%x ' "${m[@]:temp:temp2}"
#}

# ( x a -- n ) unpacks string x to ascii ordinals at a
revealheader "unpack"
code unpack unpack
unpack() {
   local string=${s[sp--]}
   len=${#string}
   ((dest=tos+len))
   tos=$len
   for ((; len; len-- )); do
      m[--dest]=$(printf '%d' "'${string:len-1:1}")
   done
}

# ( -- a c ) run time word - to be compiled by s"
revealheader '(s")'
code dosquote dosquote
dosquote() {
   s[++sp]=$tos
   tos=${m[ip++]}
   s[++sp]=$ip
   ((ip+=tos))
}

# ( -- ) run time word - to be compiled by ."
revealheader '(.")'
code dodotquote dodotquote
dodotquote() {
   dosquote
   pack
   printf '%s' "$tos"
   tos=${s[sp--]}
}

# ( limit start -- ) run time word - to be compiled by for
revealheader "(for)"
code dofor dofor
dofor() {
   r[++rp]=$tos
   r[++rp]=$tos
   tos=${s[sp--]}
   ((ip++))
}

# ( -- ) run time word - to be compiled by next
revealheader "(next)"
code donext donext
donext() {
   ((r[rp]--))
   if ((r[rp])); then
      ((ip+=m[ip]))
   else
      ((ip++, rp-=2))
   fi
}

# ( limit start -- ) run time word - to be compiled by do
revealheader "(do)"
code dodo dodo
dodo() {
   r[++rp]=${s[sp--]}
   r[++rp]=$tos
   ((ip++))
   tos=${s[sp--]}
}

# ( limit start -- ) run time word - to be compiled by ?do
revealheader "(?do)"
code doqdo doqdo
doqdo() {
   if (( tos == s[sp] )); then
      ((sp--))
      ((ip+=m[ip]))
   else
      r[++rp]=${s[sp--]}
      r[++rp]=$tos
      ((ip++))
   fi
   tos=${s[sp--]}
}

# ( -- ) run time word - to be compiled by leave
revealheader "(leave)"
code doleave doleave
doleave() {
   ((rp-=2))
   ip=${m[ip]}
   ((ip+=m[ip]))
}

# ( -- ) run time word - to be compiled by ?leave
revealheader "(?leave)"
code doqleave doqleave
doqleave() {
   if ((tos)); then
      doleave
   else
      ((ip++))
   fi
   tos=${s[sp--]}
}

# ( -- ) run time word - to be compiled by loop
revealheader "(loop)"
code doloop doloop
doloop() {
  ((r[rp]++))
   if ((r[rp] - r[rp-1])); then
      ((ip += m[ip]))
   else
      ((ip++, rp -= 2))
   fi
}

# ( -- ) run time word - to be compiled by +loop
revealheader "(+loop)"
code doplusloop doplusloop
doplusloop() {
   ((temp = r[rp] - r[rp-1],
   r[rp] += tos,
   tos = s[sp--]))
   if (( (temp ^ (r[rp] - r[rp-1])) > 0 )); then
      ((ip += m[ip]))
   else
      (( ip++, rp -= 2 ))
   fi
}

# ( ? xt -- ? )
revealheader "execute"
code execute execute
execute() {
   w=$tos
   tos=${s[sp--]}
   ${m[w++]}
}

# -----------------------------------------------------------------------------
# ------------------------------ stack operators ------------------------------
# -----------------------------------------------------------------------------

# ( -- n ) returns number stack elements on data stack
revealheader "depth"
code depth depth
depth() {
   s[++sp]=$tos
   ((tos=sp-s0-1))
}

# ( x -- x x ) duplicate top stack element
revealheader "dup"
code dup dup
dup() {  s[++sp]=$tos; }

# ( x1 x2 -- x1 x2 x1 x2 ) duplicate top two stck elements
revealheader "2dup"
code dup2 dup2
dup2() {
   s[++sp]=$tos
   s[++sp]=${s[sp-1]}
}

# ( 0 -- 0 )  ( x -- x x ) duplicate top stack element only if it is not zero
revealheader "?dup"
code qdup qdup
qdup() {
   ((tos)) && s[++sp]=$tos
}

# ( x -- ) discard top stack element
revealheader "drop"
code drop drop
drop() {
   tos=${s[sp--]}
}

# ( x1 x2 -- ) discard top two stack elements
revealheader "2drop"
code drop2 drop2
drop2() {
   ((sp--))
   tos=${s[sp--]}
}

# ( x1 x2 -- x2 x1 ) swap the top two stack elements with each other
revealheader "swap"
code swap swap
swap() {
   temp=$tos
   tos=${s[sp]}
   s[sp]=$temp
}

# ( x1 x2 x3 x4 -- x3 x4 x1 x2 ) swap top 2 stack items against 3rd and 4th of stack
revealheader "2swap"
code swap2 swap2
swap2() {
   temp=${s[sp-1]}
   s[sp-1]=$tos
   tos=$temp
   temp=${s[sp-2]}
   s[sp-2]=${s[sp]}
   s[sp]=$temp
}

# ( x1 x2 -- x1 x2 x1 ) push copy of second stack element to top
revealheader "over"
code over over
over() {
   s[++sp]=$tos
   tos=${s[sp-1]}
}

# ( x1 x2 x3 x4 -- x1 x2 x3 x4 x1 x2 ) copy 3rd and 4th stack item to stack top
revealheader "2over"
code over2 over2
over2() {
   s[++sp]=$tos
   tos=${s[sp-3]}
   s[++sp]=$tos
   tos=${s[sp-3]}
}

# ( x1 x2 -- x2 ) discard second stack element
revealheader "nip"
code nip nip
nip() {
   ((sp--))
}

# ( x1 x2 -- x2 x1 x2 ) insert a copy of top of stack under second stack element
revealheader "tuck"
code tuck tuck
tuck() {
   temp=${s[sp]}
   s[sp]=$tos
   s[++sp]=$temp
}

# ( x1 x2 x3 -- x2 x3 x1 ) rotate third stack element to top
revealheader "rot"
code rot rot
rot() {
   temp=${s[sp]}
   s[sp]=$tos
   tos=${s[sp-1]}
   s[sp-1]=$temp
}

# ( x1 x2 x3 -- x3 x1 x2 ) rotate top stack element under second stack element
revealheader "-rot"
code minrot minrot
minrot() {
   temp=${s[sp-1]}
   s[sp-1]=$tos
   tos=${s[sp]}
   s[sp]=$temp
}

# ( ... x2 x1  x0 n -- xn ) place a copy of stack element n on top of stack
revealheader "pick"
code pick pick
pick() {  tos=${s[sp-tos]}; }

# ( ... x2 x1  x0 n -- ... x2 x1 x0 xn  ) rotate stack element n to top of stack
revealheader "roll"
code roll roll
roll() {
   temp=${s[sp-tos]}
   for ((; tos; --tos)); do
      s[sp-tos]=${s[sp-tos+1]}
   done
   ((sp--))
   tos=$temp
}

# ( x -- ) moves top of data stack to return stack
revealheader ">r"
code to_r to_r
to_r() {
   r[++rp]=$tos
   tos=${s[sp--]}
}

# ( -- x ) moves top of return stack to data stack
revealheader "r>"
code r_from r_from
r_from() {
   s[++sp]=$tos
   tos=${r[rp--]}
}

# ( -- x ) copies top of return stack to data stack
revealheader "r@"
code r_fetch r_fetch
r_fetch() {
   s[++sp]=$tos
   tos=${r[rp]}
}

# ( -- ) drops top of return stack
revealheader "rdrop"
code rdrop rdrop
rdrop() {
   ((rp--))
}

# ( x1 x2 -- ) moves top two data stack elements to return stack
revealheader "2>r"
code twoto_r twoto_r
twoto_r() {
   r[++rp]=$tos
   r[++rp]=${s[sp--]}
   tos=${s[sp--]}
}

# ( -- x1 x2 ) moves top two return stack elements to data stack
revealheader "2r>"
code twor_from twor_from
twor_from() {
   s[++sp]=$tos
   s[++sp]=${r[rp--]}
   tos=${r[rp--]}
}

# ( -- x ) returns index of innermost loop
revealheader "i"
code i r_fetch

# ( -- x ) returns index of innermost loop
revealheader "j"
code j j
j() {
   s[++sp]=$tos
   tos=${r[rp-2]}
}

# -----------------------------------------------------------------------------
# ------------------------------- catch / throw -------------------------------
# -----------------------------------------------------------------------------

throw[1]="terminated"
throw[2]="aborted"
throw[3]="stack overflow"
throw[4]="stack underflow"
throw[5]="return stack overflow"
throw[6]="return stack underflow"
throw[7]="do loops nested too deeply"
throw[8]="dictionary overflow"
throw[9]="invalid memory address"
throw[10]="division by zero"
throw[11]="result out of range"
throw[12]="argument type mismatch"
throw[13]=" not found"
throw[14]="use only during compilation"
throw[15]="invalid forget"
throw[16]="attempt to use zero-length string as name"
throw[17]="pictured numeric ouput string overflow"
throw[18]="pictured numeric ouput string overflow"
throw[19]="word name too long"
throw[20]="write to a read-only location"
throw[21]="unsupported operation"
throw[22]="unstructured"
throw[23]="address alignment exception"
throw[24]="invalid numeric argument"
throw[25]="return stack imbalance"
throw[26]="loop parameters unavailable"
throw[27]="invalid recursion"
throw[28]="user interrupt"
throw[29]="compiler nesting"
throw[30]="obsolescent feature"
throw[31]=">BODY used on non-CREATEd definition"
throw[32]="invalid name argument"
throw[38]="file not found"
throw[65]="string stack underflow"

# throw without catch frame - top level error handler
code exception exception
exception() {
   (( $tos == -1 )) && exit				# exception one terminates interpreter. other exceptions are dealt with within
   local message="caught $tos"
   ((tos<0)) && message="${throw[-tos]:-$message}"
   printf '%s\n' "$message"
   if ((proceed)); then
      ip=$proceed
      start
   fi
}

code throw0 throw0
throw0() {
   catchframe=${r[rp]}
   sp=${r[--rp]}
   ip=${r[--rp]}
   tos=0
   (( rp-- ))
}
brthrow0=$throw0

# ( a -- n ) part of catch / throw exception handling mechanism
revealheader "catch"
code catch catch
catch() {
   r[++rp]=$ip
   r[++rp]=$sp
   r[++rp]=$catchframe
   catchframe=$rp
   r[++rp]=$brthrow0
   execute
}

# ( n -- ) part of catch / throw exception handling mechanism
revealheader "throw"
defer throw

code realthrow realthrow
realthrow() {
   if ((tos)); then
      if ((catchframe)); then
         rp=$catchframe
         catchframe=${r[rp--]}
         sp=${r[rp--]}
         ip=${r[rp--]}
      else
         proceed=$warm
         exception
         echo continue
      fi
   else
      tos=${s[sp--]}
   fi
   echo "--- realthrow [$tos] ---"
   (( tos )) && {
     echo "something fishy with 0 throw"
     proceed=$warm
     exception
   }
}

# when primitives throw exceptions, they can't easily execute
# a deferred word. Current workaround is to let the code entry
# into throwing check whether it is the deferred handler, and
# flowcontrols accordingly.
# Reason for two different handlings: when interpreting command line,
# errors need to terminate rather than warmstart the interpreter.
code codethrow codethrow
codethrow() {
   : "${tos:=0}"
   if [[ ${m[throw+1]} == $codethrow ]]; then
      printf '\n'
      proceed=0
      (( tos )) && {
         exception
      }
      exit "${tos#-}"
   fi
   realthrow
}
m[throw+1]="$codethrow"

# ( -- ) throw exception -2
revealheader "abort"
colon abort            $lit  -2 $throw
colon stackunderflow   $lit  -4 $throw
colon invalidaddr      $lit  -9 $throw
colon notfound         $lit -13 $throw
colon compileonly      $lit -14 $throw
colon unsupported      $lit -21 $throw
colon unstruc          $lit -22 $throw
colon invalidarg       $lit -24 $throw
colon nolooppars       $lit -26 $throw
colon filenotfound     $lit -38 $throw

# -----------------------------------------------------------------------------
# -------------------------------- arithmetic ---------------------------------
# -----------------------------------------------------------------------------

# ( n1 -- n2 ) increment top of stack by one
revealheader "1+"
code oneplus oneplus
oneplus() {
   ((tos++))
}

# ( n1 -- n2 ) increment top of stack by cell
revealheader "cell+"
code cellplus oneplus

# ( n1 -- n2 ) increment top of stack by two
revealheader "2+"
code twoplus twoplus
twoplus() {
   ((tos+=2))
}
revealheader "2-"
code twoplus twoplus
twoplus() {
   ((tos-=2))
}

# ( n1 -- n2 ) decrement top of stack by one
revealheader "1-"
code oneminus oneminus
oneminus() {
   ((tos--))
}

# ( n1 n2 -- n3 ) add top two stack elements together, leave result
revealheader "+"
code plus plus
plus()  {
   ((tos+=s[sp--]))
}

# ( n1 n2 -- n3 ) subtract tos from nos, leave result
revealheader "-"
code minus minus
minus()  {
   ((tos =s[sp--]-tos))
}

# ( n -- u ) remove sign
revealheader "abs"
code abs abs
abs()  {
   (( tos < 0 )) && (( tos *= -1 ))
#   tos=${tos#-}
}

# ( n1 n2 -- n3 ) multiply top two numbers, leave result
revealheader "*"
code mul mul
mul()  {
   ((tos*=s[sp--]))
}

# ( n1 u -- n2 ) calculate power of n1 ** u, leave result
revealheader "**"
code power power
power()  {
   ((tos=s[sp--]**tos))
}

divzero() {
   tos=-10
   codethrow
}

# ( n1 n2 n3 -- n4 n5 ) multiply n1 with n2, divide by n3, returning remainder n4 and quotient n5
revealheader "*/mod"
code starslashmod starslashmod
starslashmod()  {
   ((tos)) || divzero
   ((temp=s[sp--]*s[sp],
   s[sp]=temp%tos,
   tos=temp/tos))
}

#   ((tos)) || divzero
#   (( temp = s[sp--] * s[sp] ))
#   (( temp2 = tos ))
#   (( s[sp] = temp % tos ))
#   (( tos = temp / tos ))
#   if (( tos < 0 )); then
#      (( tos-- ))
#      (( s[sp] += temp2 ))
#   fi
#}

# ( n1 n2 -- n3 ) return remainder of n1/n2
revealheader "mod"
code mod mod
mod()  {
   ((tos)) || divzero
   ((tos=s[sp--]%tos))
}

#   ((tos=(s[sp--]%tos+tos)%tos))

# ( n1 n2 -- n3 n4 ) return remainder n3 and quotient n4 of n1/n2
revealheader "/mod"
code slashmod slashmod
slashmod()  {
   ((tos)) || divzero
   ((temp=s[sp],
   s[sp]=temp%tos,
   tos=temp/tos))
}

#   ((tos)) || divzero
#   (( temp = s[sp] ))
#   (( temp2 = tos ))
#   (( s[sp] = temp % tos ))
#   (( tos = temp / tos ))
#   if (( tos < 0 )); then
#      (( tos-- ))
#      (( s[sp] += temp2 ))
#   fi

# ( n1 n2 -- n3 ) divide n1 by n2, return result
revealheader "/"
code div div
div()  {
   ((tos)) || divzero
   ((tos=s[sp--]/tos))
}

# ( n1 n2 n3 -- n4 ) multiply n1 with n2, divide by n3
revealheader "*/"
code starslash starslash
starslashmod()  {
   ((tos)) || divzero
   ((tos=s[sp--]*s[sp--]/tos))
}

#   ((tos)) || divzero
#   (( temp = s[sp--] * s[sp] ))
#   (( temp2 = tos ))
#   (( tos = temp / tos ))
#   if (( tos < 0 )); then
#      (( tos-- ))
#   fi

# ( u1 n -- u2 ) shift right u1 by n
revealheader "rshift"
code rshift rshift
rshift()  {
   ((tos=(s[sp--]>>tos) & ~msb))
}

# ( u1 n -- u2 ) shift left u1 by n
revealheader "lshift"
code lshift lshift
lshift()  {
   ((tos="s[sp--]<<tos"))  # quotes defeat faulty syntax highlighting
}

# ( n1 -- n2 ) multiply n1 by 2, implemented as (quicker) shift left by 1
revealheader "2*"
code mul2 mul2
mul2()  {  (("tos<<=1")); }  # quotes help syntax hilighting of editor joe from getting confused

# ( n1 -- n2 ) divide n1 by 2, imeplemented as (quicker) shift right by 1
revealheader "2/"
code div2 div2
div2()  {  ((tos>>=1)); }

# ( n1 -- n2 ) reverse sign of n1
revealheader "negate"
code negate negate
negate()  {  ((tos=-tos)); }

# ( n1 n2 -- n1|n2 ) return the smaller one of two numbers
revealheader "min"
code min min
min() {
   temp=${s[sp--]}
   ((tos>temp)) && tos=$temp
}

# ( n1 n2 -- n1|n2 ) return the greater one of two numbers
revealheader "max"
code max max
max() {
   ((temp=s[sp--]))
   ((tos<temp)) && ((tos=temp))
}

# -----------------------------------------------------------------------------
# ---------------------------- arithmetic compare  ----------------------------
# -----------------------------------------------------------------------------

# ( x1 x2 -- flag ) compare top two stack elements, return true if equal, false otherwise
revealheader "="
code equ equ
equ() { tos=$((-(tos==s[sp--]))); }

# ( x1 x2 -- flag ) compare top two stack elements, return true if unequal, false otherwise
revealheader "<>"
code nequ nequ
nequ() { tos=$((-(tos!=s[sp--]))); }

# ( x -- flag ) compare top stack element with zero, return true if equal, false otherwise
revealheader "0="
code equ0 equ0
equ0() { tos=$((-(tos==0))); }

# ( x -- flag ) return true if top element is less than 0, false otherwise
revealheader "0<"
code less0 less0
less0() {  tos=$((-(tos<0))); }

# ( x -- flag ) return true if top element is more than 0, false otherwise
revealheader "0>"
code more0 more0
more0() {  tos=$((-(tos>0))); }

# ( n1 n2 -- flag ) return true if second stack element is smaller than top element, false otherwise
revealheader "<"
code less less
less() { tos=$((-(s[sp--]<tos))); }

# ( n1 n2 -- flag ) return true if second stack element is greater than top element, false otherwise
revealheader ">"
code greater greater
greater() { tos=$((-(s[sp--]>tos))); }

# ( x1 x2 x3 x4 -- flag ) compare x1,x2 with x3,x4, return true if equal, false otherwise
revealheader "d="
code dequ dequ
dequ() {
   tos=$((-(tos==s[sp-1] & s[sp]==s[sp-2])))
   ((sp-=3))
}

# -----------------------------------------------------------------------------
# ----------------------------------- bool ------------------------------------
# -----------------------------------------------------------------------------

# ( x1 x2 -- x3 ) bitwise and of top two stack elements
revealheader "and"
code and and
and() { ((tos&=s[sp--])); }

# ( x1 x2 -- x3 ) bitwise or of top two stack elements
revealheader "or"
code or or
or() { ((tos|=s[sp--])); }

# ( x1 x2 -- x3 ) bitwise xor of top two stack elements
revealheader "xor"
code xor xor
xor() { ((tos^=s[sp--])); }

# ( x1 -- x2 ) invert all bits of top stack elements
revealheader "invert"
code invert invert
invert() { ((tos=~tos)); }

# -----------------------------------------------------------------------------
# ------------------------ number conversion and i/o --------------------------
# -----------------------------------------------------------------------------

# alternative implementation. different stack effect. if conversion fails, n
# is the number of character not converted. x is the accumulated values of all
#  legal digits up to the offending one
# ( a n -- x 0 | x n ) try to convert n chars at a to number, respecting base
revealheader "number"
code number number
number() {
   local digit sign=0 radix=${m[base+1]}
   (( src = s[sp] ))                      # addr of next digit
   (( s[sp] = 0 ))                        # accumulator
   (( m[src] == 45 )) &&
      (( sign = -1 , src++ , tos-- ))     # strip leading -
   for ((; tos; tos-- )); do              # for all digits
      (( digit=m[src++]-48 ))             # read ascii of digit, convert to numeric
      (( digit < 0 )) && break            # flag chars below 0 as invalid numbers
      (( digit > 9 )) &&  {               # chars above 9 need more attention
         (( digit -= 7 ))                 # convert A... to numeric
         (( digit < 10 )) && break        # flag :...@ as invalid numbers
         (( digit >= 36 )) && {           # chars above Z need more attention
            (( digit -= 32 ))             # convert a... to numeric
            (( digit < 10 )) && break     # flag [...' as invalid numbers
         }
      }
      (( digit >= radix )) && break       # flag chars as invalid number"
      (( s[sp]=s[sp]*radix+digit ))
   done
   (( sign )) && (( s[sp] = -s[sp] ))
}

# conversion with standard stack effect. Uses alternative implementation now.
# ( a n -- x -1 | 0 ) try to convert n chars at a to number, respecting base
revealheader "?number"
colon qnumber  $number $equ0 $qdup $drop

# ( n -- 0 n f ) start pictured number conversion
revealheader "<#"
code lesshash lesshash
lesshash() {
   ((s[++sp]=0))
   if ((tos<0)); then
      ((s[++sp]=-tos, tos=-1))
   else
      ((s[++sp]=tos, tos=0))
   fi
}

# problem with bash 4.2-1:  comma delimited compound arithmetic expressions would segfault
# ( n1 n2 f -- c n3 n4 f  ) pictured number conversion: convert a single digit
revealheader "#"
code hash hash
hash() {
   local radix=${m[base+1]}
   r[++rp]=$tos
   ((r[++rp]=s[sp]/radix))
   ((tos=s[sp--]%radix))
   ((tos<0)) && ((tos*=-1))
   ((tos+=48))
   ((tos>57)) && ((tos+=39))
   s[sp+1]=$((s[sp]+1))
   s[sp++]=$tos
   s[++sp]=${r[rp--]}
   tos=${r[rp--]}
}

# ( n1 n2 f -- ??? n3 n4 f ) pictured number conversion: convert remaining digits
revealheader "#s"
code hashs hashs
hashs() {
   hash
   while ((s[sp])); do
      hash
   done
}

# ( n1 n2 f c -- c n3 n4 f  ) pictured number conversion: insert a specified character
revealheader "hold"
code hold hold
hold() {
   temp=${tos}
   tos=${s[sp]}
   s[sp]=${s[sp-1]}
   s[sp-1]=$((s[sp-2]+1))
   s[sp-2]=${temp}
}

# ( n1 n2 f -- c n3 n4 f  ) pictured number conversion: insert minus sign if converted number is negative
revealheader "sign"
code sign sign
sign() {
   ((tos)) || return
   twoto_r
   ((tos++))
   s[++sp]=45
   twor_from
}

# ( ??? n1 n2 f -- a n3 ) pictured number conversion: end conversion, leaving number, converted to string
revealheader "#>"
code hashgreater hashgreater
hashgreater() {
   ((sp--))
   tos=${s[sp--]}
   i=$tos
   dest=$((dp+PADAWAY-tos))
   temp=$dest
   while ((i--)); do
      m[dest++]=${s[sp--]}
   done
   s[++sp]=$temp
}

# ( n1 -- ) pictured number conversion: output the string to which number has been converted
revealheader "#>type"
code hashgreatertype hashgreatertype
hashgreatertype() {
   ((sp--))
   for ((i=s[sp--]; i; --i)); do
      printf '%s' "${asc[${s[sp--]}]}"
   done
   tos=${s[sp--]}
}

# -----------------------------------------------------------------------------
# ------------------------------------ i/o ------------------------------------
# -----------------------------------------------------------------------------

# ( c -- ) output the character which ascii is on top of stack
revealheader "emit"
code emit emit
emit() {
   printf '%s' "${asc[tos]}"
   tos="${s[sp--]}"
}

# ( -- ) output a space character
revealheader "space"
code space space
space() {
   printf '%1s' " "
}

# ( n -- ) output spaces
revealheader "spaces"
code spaces spaces
spaces() {
   printf "%${tos}s"
   tos="${s[sp--]}"
}

# ( -- ) clear screen
revealheader "page"
code page clear

# ( -- ) clear screen
revealheader "cls"
code cls clear

# ( a n -- ) output the string, which address and len are given on stack
revealheader "type"
code type type
type() {
   pack
   printf '%s' "$tos"
   tos="${s[sp--]}"
}

# ( -- ) output a line feed
revealheader "hidecursor"
code hidecursor printf '\e[?25l'

# ( -- ) output a line feed
revealheader "showcursor"
code showcursor printf '\e[?25h'

# ( -- ) output a line feed
revealheader "cr"
code cr printf '\n'

# ( n -- ) raw output of tos. does not respect base, but can output string in tos.
revealheader ".."
code dotdot dotdot
dotdot() {
   printf '%s ' "$tos"
   tos="${s[sp--]}"
}

# ( n -- ) output the signed number in tos, respecting base
revealheader "."
colon dot      $lesshash $bl $hold $hashs $sign $hashgreatertype

keybuf=""
# ( -- c )  0 or (immediately) ascii of keystroke
# would need to stuff ascii into a key buffer, read by key
revealheader "key?"
code keyq keyq
keyq() {
   [[ -z $keybuf ]] &&
      IFS="" read -rsn1 -t0.001 keybuf
   s[++sp]="$tos"
   tos=$(((${#keybuf}==0)-1))
}

# key: ( -- c ) read one char from input, return ascii
revealheader "key"
code key key
key() {
   s[++sp]="$tos"
   [[ -z $keybuf ]] &&
      IFS="" read -rsn1 keybuf
   tos=$(printf '%d' "'$keybuf")
   keybuf=""
}

# ( a n1 -- n2 ) read n1 chars from input, store at a. number of actually entered chars returned as n2
revealheader "accept"
code accept accept
accept() {
   printf '%s' "$keybuf"
   read -ersn "$tos" buffer
   tos="${keybuf}${buffer}"
   keybuf=""
   swap
   unpack
}

# ( c -- a n ) read word, delimited by c, from input stream. return address and len
revealheader "stream"
code stream stream
stream() {
   local delimiter=$tos temp=${m[in+1]}
   char=${m[temp]}
   if ((delimiter==32)); then
      char=${m[temp]}
      while ((char!=255)); do
        ((char!=delimiter)) && break
        ((temp++))
        char=${m[temp]}
      done
   fi
   s[++sp]=$temp
   tos=-$temp
   while ((char!=255)); do
     ((char==delimiter)) && break
     ((temp++))
     char=${m[temp]}
   done
   ((tos+=temp))
   ((char!=255)) && ((temp++))
   m[in+1]=$temp
}

# ( -- ) output the prompt
revealheader "prompt"
code prompt prompt
prompt() {
   if ((!m[state+1])); then
      printf '%s' " $PROMPT"
      for ((i=sp-s0; i; i--)); do
         printf '%s' "."
      done
      printf '%b' "\\n"
   fi
}

# ( -- ) show numbers on stack
revealheader ".s"
code dot_s dot_s
dot_s() {
   if ((sp)); then
      temp=$s0
      while ((sp>++temp)); do
         printf '%s' "${s[temp+1]} "
      done
      printf '%s' "$tos "
   fi
}

# ( -- ) exit bashforth, return to calling program of command line
revealheader "bye"
code bye exit

# ( -- ) unofficial exit with system status 1 or 0 
revealheader "exit_1" 	# 1 (bye) 
code bye exit 1 
revealheader "exit_0"   # 0 (bye) syntax on some forth 
code bye exit 0 
revealheader "(bye)"   # 0 (bye) syntax on some forth 
code bye exit 0 

# -----------------------------------------------------------------------------
# ------------------------------- dictionary  ---------------------------------
# -----------------------------------------------------------------------------

# ( -- ) modify header of most recently defined word to keep it from being found
revealheader "hide"
code hide hide

# ( -- ) set most recent word "findable"
revealheader "reveal"
code reveal reveal

# ( a n -- ) create a new header with name identical to string passed on stack
revealheader "newheader"
code newheader newheader
newheader() {
   pack
   header $tos
   tos=${s[sp--]}
}

# ( xt -- a ) given xt, return word body address
revealheader ">body"
code tobody oneplus

# ( a -- xt ) given word body address, return xt
revealheader "body>"
code bodyfrom oneminus

# ( xt -- wordnum ) returns word number or 0, opposite of name>.
revealheader ">name"
code toname toname
toname() {
   temp=$wc
   while ((temp)); do
      ((tos==x[--temp])) && break
   done
   tos=$temp
}

# ( wordnum -- xt ) calculate code field address from word number
revealheader "name>"
code name_from name_from
name_from() {  tos=${x[tos]}; }

# ( wordnum -- a n ) return string with name of word, given word number
revealheader "name"
code name name
name() {
   s[++sp]=$dp
   s[++sp]=${h[tos]}
   tos=$dp
   unpack
}

# ( wordnum --  ) output word name, given word number ("nfa")
revealheader ".name"
code dotname dotname
dotname() {
   printf '%s' "${h[tos]}"
   tos=${s[sp--]}
}

# ( word# -- flag ) return true flag if word, specified by word number ("nfa"), is an immediate word
revealheader "?immediate"
code qimm qimm
qimm() {
   ((tos=hf[tos]&precedencebit))
}

# ( -- ) make most recently defined word an immediate word
revealheader "immediate"
code immediate immediate
immediate() {
   ((hf[wc-1]|=precedencebit))
}

# ( a n -- namefield | 0 ) returns 0 or word number of word which name is given as string on stack
revealheader "locate"
code locate locate
locate() {
   pack
   temp=$wc
   while ((temp)); do
      if ((hf[--temp] & smudgebit)); then
         [[ "$tos" == "${h[temp]}" ]] && break
      fi
   done
   tos=$temp
}

# ( -- ) show list of words in vocabulary
revealheader "words"
code words words
words() {
   (( COLUMNS )) || clear                                         # initialize COLUMNS is necessary
   local out=0
   local len
   for ((i=wc; i--;)); do
      len=$(( ${#h[i]}+2 ))
      (( out += len ))
      if (( out >= COLUMNS )); then
         printf '\n%s' "${h[i]}  "
         out=$len
      else
         printf '%s' "${h[i]}  "
      fi
   done
}

# -----------------------------------------------------------------------------
# ------------------------------ compilation ----------------------------------
# -----------------------------------------------------------------------------

# ( x -- )
revealheader ","
code comma comma
comma() {
   m[dp++]="$tos"
   tos="${s[sp--]}"
}

# ( c -- ) compile an 8-bit number to memory at "here"
revealheader "c,"
code ccomma ccomma
ccomma() {
   ((m[dp++]=tos&255))
   tos="${s[sp--]}"
}

# ( -- ) turns compilation off
revealheader "["
code leftbracket leftbracket
leftbracket() {
   m[state+1]=0
}
immediate

# ( -- ) turns compilation on
revealheader "]"
code rightbracket rightbracket
rightbracket() {  m[state+1]=-1; }

# ( n -- ) statically reserve n memory locations
revealheader "allot"
code allot allot
allot() {
   ((dp+=tos))
   tos=${s[sp--]}
}

# ( -- a ) returns end-of-code address
revealheader "here"
code here here
here() {
   s[++sp]=$tos
   tos=$dp
}

# -----------------------------------------------------------------------------
# ----------------------------------- mem -------------------------------------
# -----------------------------------------------------------------------------

# ( a -- x ) read and return contents of address
revealheader "@"
code fetch fetch
fetch() {  tos="${m[tos]}"; }

# ( a -- ) output the contents of address a as signed number.
revealheader "?"
colon dot      $fetch $dot

# ( x a -- ) store x into memory address a
revealheader "!"
code store store
store() {
   m[tos]=${s[sp--]}
   tos=${s[sp--]}
}

# ( a -- c ) read and return 8 bits from memory address a
revealheader "c@"
code cfetch cfetch
cfetch() {
   ((tos=m[tos]&255))
}

# ( c a -- ) write 8 bits to memory at address a
revealheader "c!"
code cstore cstore
cstore() {
   ((m[tos]=s[sp--]&255))
   tos=${s[sp--]}
}

# ( a1 -- a2 c ) a1+1 -> a2,  [a1] -> c
revealheader "count"
code count count
count() {
   ((s[++sp]=tos+1,
   tos=m[tos]&255))
}

# ( a1 -- a2 x ) a1+cell -> a2,  [a1] -> x
revealheader "skim"
code skim skim
skim() {
   ((s[++sp]=tos+1,
   tos=m[tos]))
}

# ( a -- x1 x2 ) fetch two cells from a
revealheader "2@"
colon twofetch   $skim $swap $fetch

# ( x1 x2 a -- ) store cells at a
revealheader "2!"
colon twostore   $tuck $cellplus $store $store

# ( n a -- ) minus n to contents of memory att a
revealheader "-!"
code minusstore minusstore
minusstore() {
   ((m[tos]-=s[sp--]))
   tos=${s[sp--]}
}

# ( n a -- ) add n to contents of memory att a
revealheader "+!"
code plusstore plusstore
plusstore() {
   ((m[tos]+=s[sp--]))
   tos=${s[sp--]}
}

# ( x1 a -- x2 ) read x2 from a, then store x1 in a
revealheader "exchange"
code exchange exchange
exchange() {
   temp=${m[tos]}
   m[tos]=${s[sp--]}
   tos=$temp
}

# ( a n1 c -- n2 ) search for c in string a n1. n2 is len of remainder, including first c
revealheader "scan"
code scan scan
scan() {
   temp=$tos
   tos=${s[sp--]}
   dest=${s[sp--]}
   while ((tos)); do
      [[ "${m[dest++]}" == "$temp" ]] && break
   ((tos--))
   done
}

# ( a n1 c -- n2 ) skip all leading c in atring a n1. n2 is len of remainder
revealheader "skip"
code skip skip
skip() {
   temp=$tos
   tos=${s[sp--]}
   dest=${s[sp--]}
   while ((tos)); do
      [[ "${m[dest++]}" == "$temp" ]] || break
   ((tos--))
   done
}

# ---------- compare   is a bit dirty, because of quick fix ------------
# compare $tos bytes at  $source and $dest
# result of comparison (-1/0/1) in $tos
compare1() {
   while ((tos)); do
      ((temp=m[source++]-m[dest++]))
      if ((temp)); then
         tos="$(( ((temp > 0) << 1) - 1))"
         break
      fi
      ((tos--))
   done
}

# ( a1 n1 a2 n2 -- -1 | 0 | 1 ) compare two strings at a1 and a2.
revealheader "compare"
code compare compare
compare() {             # n2 in tos
   local dest=${s[sp--]}
   local temp=${s[sp--]}
   local source=${s[sp--]}
   if [[ "$temp" = "$tos" ]]; then
      compare1
   else
      temp2=1
      if [[ $temp < $tos ]]; then
         tos=$temp
         temp2=-1
      fi
      compare1
      if ! ((tos)); then
         tos=$temp2
      fi
   fi
}
 
# ( a1 n c -- ) fill n memory locations at a1 with c
revealheader "fill"
code fill fill
fill()  {
   i=${s[sp--]}
   dest=${s[sp--]}
   for ((; i; i--)); do
      m[dest++]=$tos
   done
   tos=${s[sp--]}
}

# ( a1 a2 n -- ) move contents of n memory locations at a1 to a2
revealheader "move"
code move move
move()  {
   if  [[ ${s[sp]} > ${s[sp+1]} ]]; then
      ((dest=s[sp--]+tos,
      src=s[sp--]+tos))
      while ((tos--)); do
         m[--dest]=${m[--src]}
      done
   else
      local dest=${s[sp--]}  src=${s[sp--]}
      while ((tos--)); do
         m[dest++]=${m[src++]}
      done
   fi
   tos=${s[sp--]}
}

# ( a1 n a2 -- ) store string a1 n at a2, with leading count byte
revealheader "move$"
code movestr movestr
movestr()  {
   temp=${s[sp]}
   m[tos++]=$temp
   s[sp]=$tos
   tos=$temp
   move
}

# ( a1 n1 n -- a2 n2 ) clip first n chars off string at a1
revealheader "/string"
code slashstring slashstring
slashstring()  {
   temp=$tos
   tos=${s[sp--]}
   if ((tos<temp)); then
      temp=$tos
   fi
   ((s[sp]+=temp, tos-=temp))
}

# ( c -- a n ) read word, delimited by c, from input stream. return address and len
revealheader "word"
colon word        $stream $here $movestr $here

# -----------------------------------------------------------------------------
# ------------------------------ string stack ---------------------------------
# -----------------------------------------------------------------------------

# ( a n -- ) push string at a to string stack
revealheader "push$"
code pushstr pushstr
pushstr() {
   pack
   ss[++ssp]="$stos"
   stos="$tos"
   tos="${s[sp--]}"; }

# ( -- a n ) pop string from string stack to here
revealheader "pop$"
code popstr popstr
popstr() {
   if ((!ssp)); then
      tos=-65; codethrow
   fi
   s[++sp]="$tos"
   tos=$dp
   s[++sp]=$tos
   s[++sp]="$stos"
   stos="${ss[ssp]}"
   ss[ssp--]=""
   unpack
}

# ( stringstack: string -- ) pop and output string from string stack
revealheader "type$"
code typestr typestr
typestr() {
   if ((!ssp)); then
      tos=-65; codethrow
   fi
   printf '%s' "$stos"
   stos="${ss[ssp]}"
   ((ssp--))
}

# ( -- n ) returns number stack elements on string stack
revealheader "depth$"
code depthstr depthstr
depthstr() {
   s[++sp]=$tos
   tos=$((ssp-ss0))
}

# ( -- ) show strings on string stack
revealheader ".s$"
code dot_sstr dot_sstr
dot_sstr() {
   if ((ssp)); then
      printf '%s\n' "$stos "
      temp=$(( ssp ))
      while ((temp > ss0+1)); do
         printf '%s\n' "${ss[temp--]}"
      done
   fi
}

# ( stringstack: str -- str str ) duplicate top string stack element
revealheader "dup$"
code dupstr dupstr
dupstr() {  ss[++ssp]="$stos"; }

# ( stringstack: x1 x2 -- x1 x2 x1 x2 ) duplicate top two elements of stack element
revealheader "2dup$"
code dup2str dup2str
dup2str() {  ss[++ssp]="$stos"  ss[++ssp]="${ss[ssp-1]}"; }

# ( stringstack: x -- ) drop top stringstack element
revealheader "drop$"
code dropstr dropstr
dropstr() {
   if ((!ssp)); then
      tos=-65; codethrow
   fi
   stos="${ss[ssp]}"
   ss[ssp--]=""
}

# ( stringstack: x1 x2 -- x2 x1 ) swap top two string stack elements
revealheader "swap$"
code swapstr swapstr
swapstr() {
   if ((ssp<2)); then
      tos=-65; codethrow
   fi
   temp="$stos"
   stos="${ss[ssp]}"
   ss[ssp]="$temp"
}

# ( stringstack: x1 x2 -- x1 x2 x1 ) copies next-of-stack of string stack to top
revealheader "over$"
code overstr overstr
overstr() {
   if ((ssp<2)); then
      tos=-65; codethrow
   fi
   ss[++ssp]="$stos"
   stos="${ss[ssp-1]}"
}

# ( stringstack: x1 x2 -- x2 ) discards next-of-stack string stack element
revealheader "nip$"
code nipstr nipstr
nipstr() {
   if ((ssp<2)); then
      tos=-65; codethrow
   fi
   ((ssp--))
}

# ( stringstack: x1 x2 x3 -- x2 x3 x1 ) rotate 3rd string stack element to top
revealheader "rot$"
code rotstr rotstr
rotstr() {
   if ((ssp<3)); then
      tos=-65; codethrow
   fi
   temp="${ss[ssp]}"
   ss[ssp]="$stos"
   stos="${ss[ssp-1]}"
   ss[ssp-1]="$temp"
}

# ( stringstack: "string1" "string2" -- "string1string2" ) joins top two strings
revealheader "append$"
code appendstr appendstr
appendstr() {
   if ((ssp<2)); then
      tos=-65; codethrow
   fi
   stos="${ss[ssp--]}$stos"
}

# ( u1 u2 -- )  ( ss: $1 -- $2 )  cut and return string starting at index u1 (zero based) with max length of u2 chars. negative index counts from end of string
revealheader "sub$"
code substr substr
substr()  {
   if ((!ssp)); then
      tos=-65; codethrow
   fi
   temp=${s[sp--]}
   stos="${stos:$temp:$tos}"
   tos=${s[sp--]}
}

# ( u -- ) ( ss: $1 -- $2 ) modifies string so that leading u chars of string remain
revealheader "left$"
colon leftstr   $zero $swap $substr

# ( u -- ) ( ss: $1 -- $2 ) modifies string so that trailing u chars of string remain
revealheader "right$"
colon rightstr   $dup $negate $swap $substr

# ( a n -- ) creates header. expects ascii array type string
revealheader "create$"
code createstr createstr
createstr() {
   newheader
   m[dp++]=dovar
   reveal
}

# -----------------------------------------------------------------------------
# --------------------------------- does> -------------------------------------
# -----------------------------------------------------------------------------

# executed upon execution of word defined by defining word:
# puts body address of defined word on stack, nests into does> action
# ( -- a )
code dodoes dodoes
dodoes() {
   s[++sp]=$tos
   tos=$w
   r[++rp]=$ip
   ip=$1
}

code setdoes setdoes
setdoes() {  m[m[lastxt+1]]="dodoes $((ip+1))"; }

# ( -- ) define run time action of a compiling word
revealheader "does>"
colon does              \
   $lit $setdoes $comma          \
   $lit $unnest  $comma
immediate

start()  {
while w=${m[ip++]}; do ${m[w++]}
      w=${m[ip++]};    ${m[w++]}
      w=${m[ip++]};    ${m[w++]}
      w=${m[ip++]};    ${m[w++]}
      w=${m[ip++]};    ${m[w++]}
      w=${m[ip++]};    ${m[w++]}
      w=${m[ip++]};    ${m[w++]}
      w=${m[ip++]};    ${m[w++]}
      w=${m[ip++]};    ${m[w++]}
      w=${m[ip++]};    ${m[w++]}
      w=${m[ip++]};    ${m[w++]}
      w=${m[ip++]};    ${m[w++]}
      w=${m[ip++]};    ${m[w++]}
      w=${m[ip++]};    ${m[w++]}
      w=${m[ip++]};    ${m[w++]}
      w=${m[ip++]};    ${m[w++]}
done
}

# -----------------------------------------------------------------------------
# ---------------------------- hi-level words ---------------------------------
# -----------------------------------------------------------------------------

# ( ??? -- ) initialize stacks, return to forth command line interpreter
revealheader "quit"
defer quit

# ( a -- ) set cfa of last word to a
revealheader "use"
colon use              $last $fetch $store

# ( -- f ) returns flag, indicating whether bashforth is compiling (-1) or interpreting (0)
revealheader "compiling"
colon compiling     $state $fetch

# ( -- ) throw exception if in intepreting state
revealheader "?comp"
colon qcomp        $compiling $branchx 2 $compileonly

# ( a n -- a n 0 | xt 1 | xt -1 ) search dictionary, returns name and 0 if not found, xt and precedence (1=imm) if found
revealheader "find"
colon findx            \
   $dup2 $locate       \
   $dup $branch0 10    \
      $nip $nip        \
      $dup $name_from  \
      $swap $qimm      \
      $equ0 $one $or   \


# ( x -- ) immediate word which compile top of stack as number into word
revealheader 'literal'
colon literal       $lit $lit $comma $comma
immediate

# ( <stream> -- a ) return execution token of word which name is read from input stream
revealheader "'"
colon tick               \
   $bl $stream $findx    \
   $branchx 3            \
     $type $notfound

# ( <stream> -- ) compile execution token of next word
revealheader "[']"
colon brackettick  $qcomp $tick $literal
immediate

revealheader "postpone"
colon postpone $tick $comma
immediate

# ( -- ) do nothing
revealheader "nop"   ; code nop : ; immediate

# ( n1 -- n2 ) convert cells to number of memory locations
revealheader "cells" ; code cells : ; immediate

# ( n1 -- n2 ) convert chars to number of memory locations
revealheader "chars" ; code chars : ; immediate

# ( -- ) set number base to 16
revealheader "hex"
colon hex          $lit 16 $base $store

# ( -- ) set number base to 10
revealheader "decimal"
colon decimal      $lit 10 $base $store

# ( -- ) set number base to 2
revealheader "binary"
colon binary       $two $base $store

# ( -- a ) return address of a scratch string space
revealheader "pad"
colon pad          $here $lit $PADAWAY $plus

# ( <stream> -- ) create a new header, name read from input stream
revealheader "create"
colon create       $bl $stream $createstr

# ( <stream> -- ) create a variable
revealheader "2variable"
colon variable     $create  $zero $comma $zero $comma
revealheader "variable"
colon variable     $create  $zero $comma

# ( <stream> x -- ) create a constant
revealheader "constant"
colon constant     $create $comma $lit doconst $use

# ( <stream> -- ) create new high-level word
revealheader ":"
colon hllcolon     $bl $stream $newheader $lit nest $comma  $rightbracket

revealheader ":noname"
colon colnoname    $here $lit nest $comma  $rightbracket

# ( -- ) finish compilation of a high-level word
revealheader ";"
colon hllsemicolon $lit $unnest $comma $leftbracket $reveal
immediate

# ( a n -- ) compile the string, whose address and len is passed on stack
revealheader ',$'
colon commastr     $here $over $oneplus $allot $movestr

# ( <stream> -- ) compile a string from input stream
revealheader ',"'
colon commaquote   $lit 34 $stream $commastr

# ( <stream> -- ) put address and len of string, delimited by ), interactively on stack
revealheader 's('
colon sbracket     $lit 41 $stream $here $movestr $here $count
immediate

# ( <stream> -- ) compile string from input stream into word, return address and len during run time
revealheader 's"'
colon squote       $qcomp  $lit $dosquote $comma $commaquote
immediate

# ( <stream> -- ) output string from input stream, in interpreting mode
revealheader '.('
colon dotbracket   $lit 41 $stream $type
immediate

# ( <stream> -- ) compile string to high-level word, output string at run time
revealheader '."'
colon dotquote     $qcomp $lit $dodotquote $comma $commaquote
immediate

# ( <stream> -- ) ignore text until ) as comment
revealheader '('
colon bracket      $lit 41 $stream $drop2
immediate

# ( <stream> -- ) ignore rest of line as comment
revealheader '\'
colon backslash    $zero $stream $drop2
immediate

# ( <stream> -- ) ignore rest of line as comment
revealheader '#!'
colon shebang      $zero $stream $drop2
immediate

# ( <stream> -- c ) return ascii of next char on stack
revealheader 'char'
colon brchar         $bl $stream $drop $cfetch
immediate

# ( <stream> -- c ) return ascii of next char on stack, or compile as literal
revealheader '[char]'
colon brchar         $brchar $compiling $branch0 2 $literal
immediate

# -----------------------------------------------------------------------------
# -------------------------------- flow control -------------------------------
# -----------------------------------------------------------------------------

colon structured    $nequ $branch0 2 $unstruc
colon qclause       $lit $branch0 $comma
colon clause        $lit $branch $comma
colon resolve       $here $minus $comma
colon mark          $here $zero  $comma
colon resolveback   $here $over  $minus  $swap $store

# ( f -- ) flow control: true/false if ... else ... then    . else part is optional
revealheader "if"
colon fif           $qcomp $qclause $mark  $one
immediate

# ( -- ) flow control:  true/false if ... else ... then
revealheader "else"
colon felse         $qcomp $one $structured  $clause $mark  $swap $resolveback  $two
immediate

# ( -- ) flow control: true/false if ... else ... then     . else part is optional
revealheader "then"
colon fthen         $qcomp $dup $two $equ $plus $one $structured $resolveback
immediate

# ( -- ) flow control:  begin ... true/false until    or    begin ... true/false while ... repeat
revealheader "begin"
colon fbegin        $qcomp $here  $three
immediate

# ( f -- ) flow control:  begin ... true/false while ... repeat
revealheader "while"
colon fwhile        $qcomp $three $structured  $qclause $mark  $four
immediate

# ( -- ) flow control:  begin ... true/false while ... repeat
revealheader "repeat"
colon frepeat       $qcomp $four $structured   $swap $clause $resolve $resolveback
immediate

# ( -- ) flow control:  begin ... again
revealheader "again"
colon fagain        $qcomp $three $structured  $clause $resolve
immediate

# ( f -- ) flow control:  begin ... true/false until
revealheader "until"
colon funtil        $qcomp $three $structured  $qclause $resolve
immediate

var innerloop

# ( start -- ) flow control:  (limit) for ... next  , counts down
revealheader "for"
colon ffor          $qcomp $lit $dofor $comma     \
                    $here $innerloop $exchange    \
                    $here $zero $comma            \
                    $six
immediate

# ( -- ) flow control:  (limit) for ... next , counts down
revealheader "next"
colon floop         $qcomp $six $structured      \
                    $lit $donext $comma          \
                    $dup $oneplus $resolve       \
                    $resolveback                 \
                    $innerloop $store
immediate

# ( limit start -- ) flow control:  (limit) (start) do ... loop
revealheader "do"
colon fdo           $qcomp $lit $dodo $comma \
                    $here $innerloop $exchange    \
                    $here $zero $comma            \
                    $five
immediate

# ( limit start -- ) flow control:  (limit) (start) ?do ... loop
revealheader "?do"
colon fqdo          $qcomp $lit $doqdo $comma \
                    $here $innerloop $exchange     \
                    $here  $zero $comma            \
                    $five
immediate

# ( -- ) flow control:  (limit) (start) do ... loop
revealheader "loop"
colon floop         $qcomp $five $structured    \
                    $lit $doloop $comma    \
                    $dup $oneplus $resolve      \
                    $resolveback                \
                    $innerloop $store
immediate

# ( n -- ) flow control:  (limit) (start) do ... (increment) +loop
revealheader "+loop"
colon fplusloop     $qcomp $five $structured    \
                    $lit $doplusloop $comma    \
                    $dup $oneplus $resolve      \
                    $resolveback                \
                    $innerloop $store
immediate

# ( a -- )
colon putleave    $qcomp $comma $innerloop $fetch $qdup $branch0 3 $comma $unnest $nolooppars

# ( -- ) flow control:  (limit) (start) do ... if ... leave then ... loop
revealheader "leave"
colon leave         $lit $doleave $putleave
immediate

# ( f -- ) flow control:  (limit) (start) do ... (flag) ?leave ... loop
revealheader "?leave"
colon qleave        $lit $doqleave $putleave
immediate

# -----------------------------------------------------------------------------
# -------------------------------- interpreter --------------------------------
# -----------------------------------------------------------------------------

# ( -- ) fill input buffer from standard input
revealheader "query"
colon query          \
   $lit 255          \
   $tib   $dup $in $store     \
   $dup              \
   $lit $((TIBSIZE-1))        \
   $accept           \
   $plus          \
   $cstore

# ( a n -- ) interpreter for a single word
revealheader "interpret1"
colon interpret1        \
   $findx                 \
   $qdup $branch0 17       \
      $oneminus $branch0 7              \
      $compiling $branch0 4      \
      $comma            \
      $branch 7            \
      $execute          \
      $depth $less0 $branch0            \
          2 $stackunderflow $unnest \
   $dup2 $qnumber       \
   $branch0 8           \
      $nip $nip            \
      $compiling        \
      $branch0 2        \
      $literal          \
      $unnest           \
    $type $notfound

# ( -- ) interpret one line of forth source
revealheader "interpret"
colon interpret            \
   $lit 32 $stream         \
   $qdup          \
   $branch0 4           \
   $interpret1          \
   $branch -8           \
   $drop

# ( a n -- ) interpret the string passed on stack
#revealheader "evaluate"
#colon evaluate            \
# string to tib  $interpret

# -----------------------------------------------------------------------------
# ---------------------------------- include ----------------------------------
# -----------------------------------------------------------------------------

# ( a n1 -- n2 )
code from from
from() {
   local i
   pack
   f=(); i=0
   if [[ ! -f "$tos" ]]; then
      tos="${tos}.bashforth"
   fi
   if [[ -f "$tos" ]]; then
      while read -r f[i]
      do
         (( i++ ))
      done < $tos
      tos=$i
   else
     tos=-38; codethrow
   fi
}

# ( a n1 -- n2 )
code endfrom endfrom
endfrom() {
      unset f
}

# ( n -- )
code line line
line() {
   [[ $LOADING ]] && printf '%s' "$LOADING"
   s[++sp]=${f[tos]}   tos=${m[tib+1]}   m[in+1]=$tos
   unpack
   m[tos+${m[tib+1]}]=255   tos=${s[sp--]}
}

revealheader "sourcepath"
code sourcepath sourcepath
sourcepath()  {
   ss[++ssp]="$stos"
   stos="$sources/"
}

revealheader "!sourcepath"
code storesourcepath storesourcepath
storesourcepath()  {
   if ((!ssp)); then
      tos=-65; codethrow
   fi
   sources="$stos"
   stos="${ss[ssp]}"
   ((ssp--))
}

# ( <stream> -- ) read forth source from file
revealheader "include"
colon include           \
   $sourcepath          \
   $bl $stream $pushstr $appendstr  \
   $popstr $from        \
   $zero $dodo 6  \
   $i $line    \
   $interpret     \
   $doloop -4      \
   $endfrom

# ----- file interface -----

#  ( -- x )   a constant for file access method r/o
#revealheader "r/o"
#constant famreadwrite 0

#  ( -- x )   a constant for file access method r/w
#revealheader "r/w"
#constant famreadwrite 1

# ( a n fam -- fileid ior )
#revealheader "create-file"
#code create-file create-file
#create-file()  {
#     r[++rp]=$tos
#     tos=${s[sp]}
#     pack
#     (echo -n > $tos) 2> /dev/null
#     s[sp]="12345678"       # can only use one handle as far
#     tos=$?
#     (( rp-- ))             # ior is not used now
#    if fam=0 then chmod -r filename
#}

# open-file
# read-file
# write-file
# close-file
# file-size
# file-position

# -----------------------------------------------------------------------------  save-system and restore were
# ------------------------------- save-system ---------------------------------  contributed by quaraman-me
# -----------------------------------------------------------------------------

save_array_print() {
   local i
   local inext
   local -n a=$1
   inext=0
   printf 'a0\n'
   for i in "${!a[@]}"; do
      [[ "$inext" != "$i" ]] &&
         printf 'ao %s\n' "$i"
      printf 'a %s\n' "${a[i]}"
      (( inext++ ))
   done
}

# ( a c -- ) writes image of system to file, file name passed as address, count on stack
code saveas saveas
saveas()  {
   local i
   local inext
   local len
   pack
   [[ "$tos" ]] || tos="$sources/saved_system"
   {  printf "version %s\n" "$version"
      printf "wc %s\n" "$wc"
      printf "dp %s\n" "$dp"

      save_array_print m
      save_array_print h
      save_array_print hf
      save_array_print x
   } > "$tos"
   tos=${s[sp--]}
}

# ( <stream> -- ) writes image of system to file, file name taken from input stream. If no name given, "save_system" will be the name.
revealheader "save-system"
colon savesystem    $bl $stream $saveas

# -----------------------------------------------------------------------------
# -------------------------- restore saved system -----------------------------
# -----------------------------------------------------------------------------

# ( a c -- )
code restorefrom restorefrom
restorefrom()  {
   local load_version
   local cmd
   local prg
   local a=0
   local ai=0
   local linenr=0
   pack
   m=()
   h=()
   hf=()
   x=()
   fname="${tos:-$sources/saved_system}"
   tos=${s[sp--]}
   while read -r line; do
      read -a prg <<< "$line"
      cmd="${prg[0]}"
      p1="${prg[1]}"
      p2="${prg[2]}"

      case "$cmd" in
      version)
         load_version="$p1"
         [[ "$load_version" != "$version" ]] &&
            echo "Not same Version : $load_version"
         ;;
      wc)
         wc="$p1"
         ;;
      dp)
         dp="$p1"
         ;;
      a0)
         ai=0
         (( a++ ))
         ;;
      ao)
         ai="$p1"
         ;;
      a)
         case $a in
         1)
            m[ai++]="$p1"
            ;;
         2)
            h[ai++]="$p1"
            ;;
         3)
            hf[ai++]="$p1"
            ;;
         4)
            x[ai++]="$p1"
            ;;
         esac
         ;;
      hlt)
         ai=0
         break;
         ;;
      esac
      (( linenr++ ))
   done < "$fname"
}

# ( <stream> -- ) write image of system to file, file name taken from input stream. If no name given, saved_system will be the name.
revealheader "restore"
colon restore    $bl $stream $restorefrom

# -----------------------------------------------------------------------------
# ------------------------------ init / startup -------------------------------
# -----------------------------------------------------------------------------

code init_stacks init_stacks
init_stacks() {
   sp=$s0
   temp=${r[rp]}
   rp=$r0
   r[rp]=$temp
}

# executed by cold and warm
code init_other init_other
init_other() {
   tos=0
   ssp=$ss0
   ss[ssp]=""
   m[base+1]=10
   m[innerloop+1]=0
   m[state+1]=0
}

# ( ??? -- )
revealheader "(quit)"
colon bracketquit          \
   $init_stacks            \
   $zero $innerloop $store \
   $leftbracket            \
   $query                  \
   $interpret              \
   $prompt                 \
   $branch -4

m[quit+1]=$bracketquit            # set deferred quit

# ( ??? -- )
revealheader "(warm)"
colon warmhandler          \
   $init_stacks            \
   $init_other             \
   $decimal                \
   $prompt                 \
   $quit	

m[warm+1]=$warmhandler            # set deferred warm

# ( -- ) prints GPL notice
revealheader "license"
code license license
license() {
   echo "
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
"
}

# ( -- ) prints the opening screen
revealheader "hello"
code hello hello
hello() {
   echo -e "\nBashForth v$version
   $(license)
   www:      https://github.com/goblinrieur/Bashforth

   words <enter>       shows a list of available words
   doc word  <enter>   gives description of word
   
   You may need to add at least default library to your code
   include lib/library.fs

"
}

# -----------------------------------------------------------------------------
# ------------------------------ misc optionals -------------------------------
# -----------------------------------------------------------------------------
# these may shell to other programs. in fact, several of the following words do
# ----------------------------------- doc -------------------------------------

# ( xt -- x )
code sourceline sourceline
sourceline() {  tos=${m[tos-1]}; }

# calls cat, sed, cut
# ( -- )
code printdoc printdoc
printdoc() {
     temp=$(sed -n $(( tos+1 ))p $0 | cut -f 2 -d " ")
     NAME=${temp:1:${#temp}-2}
     temp=$(sed -n ${tos}p $0 | sed s/"# "//)
     STACKEFFECT=${temp%%)*}
     DESCRIPTION=${temp#*)}
     echo "$NAME  $STACKEFFECT)"
     temp="sorry, this word hasn't been documented yet"
     echo "${DESCRIPTION:-$temp}"
     tos=${s[sp--]}
}

# ( <stream> -- ) print stack effect and description of word, name taken from input stream
revealheader "doc"
colon doc  $tick $sourceline $printdoc

# ----------------- see ------------------

# calls sed
# ( -- )
code printsource printsource
printsource() {
     echo "in file $0:"
     sed -n "1,${tos}d;p;/^ *$/q" "$0"
     tos=${s[sp--]}
}

# ( <stream> -- ) print source of a word (read from the executed bashforth script file)
revealheader "see"
colon see   $tick $sourceline $printsource

# ---------------------- terminal control ---------------------

# ( -- 0 ) returns color code for color black
revealheader "black"
constant black 0

# ( -- 1 ) returns color code for color red
revealheader "red"
code red red
red() {
		printf '%b' "\e[31m"
}

# ( -- 2 ) returns color code for color green
revealheader "green"
code green green
green() {
		printf '%b' "\e[32m"
}

# ( -- 3 ) returns color code for color yellow
revealheader "yellow"
code yellow yellow
yellow() {
		printf '%b' "\e[33m"
}

# ( -- 4 ) returns color code for color blue
revealheader "blue"
code blue blue
blue() {
		printf '%b' "\e[34m"
}

# ( -- 5 ) returns color code for color magenta
revealheader "magenta"
code magenta magenta
magenta() {
		printf '%b' "\e[35m"
}

# ( -- 6 ) returns color code for color cyan
revealheader "cyan"
code cyan cyan
cyan() {
		printf '%b' "\e[36m"
}
revealheader "grey"
code grey grey
grey() {
		printf '%b' "\e[37m"
}

# ( -- 7 ) returns color code for color white
revealheader "white"
code white white
white() {
		printf '%b' "\e[38m"
}

# fg: 0:3  bg: 4:7  bold: 8  underscore: 9
(( attributes = 112 ))

# ( color -- ) set foreground color
revealheader "fg"
code fg fg
fg() {
  ((tos&=7,
    attributes&=-16,
    attributes|=tos ))
    printf '%b' "\e[3${tos}m"
    tos=${s[sp--]}
}

# ( color -- ) set background color
revealheader "bg"
code bg bg
bg() {
  ((tos &= 7,
    attributes&=-241,
    attributes|=(tos << 4)))
    printf '%b' "\e[4${tos}m"
    tos=${s[sp--]}
}

# ( -- ) reset colors and attributes to normal
revealheader "normal"
code normal normal
normal() {
   attributes=112
   printf '%b' "\e[0m"
}

# ( -- ) set bold attribute
revealheader "bold"
code bold bold
bold() {
   ((attributes&=-257,
   attributes|=256))
   printf '%b' "\e[1m"
}

# ( -- ) set underscore attribute
revealheader "underscore"
code underscore underscore
underscore() {
   ((attributes&=-513,
   attributes|=512))
   printf '%b' "\e[4m"
}

# ( -- ) reverse screen colors
revealheader "reverse"
code reverse reverse
reverse() { colors; fg; bg; }

# ( -- u ) read all screen attributes, incl color
revealheader "attr@"
code attrfetch attrfetch
attrfetch() {
   s[++sp]=$tos
   tos=$attributes
}

# ( u -- ) set all screen attributes, incl color, as read with attr@
revealheader "attr!"
code attrstore attrstore
attrstore() {
   attributes=$tos
   printf '%b' "\e[3$((tos&7));4$(((tos>>4)&7))"
   ((temp=(tos>>8)&1))
   ((temp)) && printf '%b' ";$temp"
   ((temp=(tos>>7)&4))
   ((temp)) && printf '%b' ";$temp"
   echo -n "m"
   tos=${s[sp--]}
}

# ( -- fg bg ) return current colors
revealheader "colors"
code colors colors
colors() {
   ((s[++sp]=tos,
   s[++sp]=attributes&7,
   tos=(attributes>>4)&7))
}

# ( x y -- ) position cursor at x,y
revealheader "at"
code atxy atxy
atxy() {
   printf '%b' "\e[$((tos+1));$((s[sp--]+1))H"
   tos=${s[sp--]}
}

# ( -- ) position cursor at upper left
revealheader "home"
code home home
home() {   printf '%b' "\e[H"; }

# ---------------------------------------------------------------------

# ( n1 -- n2 ) returns random number between 0 and n1-1 (max 2^30-1 = 1073741823)
revealheader "rnd"
code rnd rnd
rnd() { ((tos="((RANDOM<<15)|RANDOM)%tos")); }

# ( -- s m h d m y ) returns system time: seconds minutes hours day month year
revealheader "time&date"
code timeanddate timeanddate
timeanddate() {
   s[++sp]=$tos   temp=( $( date "+%S %M %H %d %m %Y" ) )
   for i in {0..4}; do
      s[++sp]=$( printf '%g' "${temp[i]}" )
   done
   tos=${temp[5]}
}

# -----------------------------------------------------------------------------
# ---------------------------------- shell ------------------------------------
# -----------------------------------------------------------------------------

# ( -- ) shows environment variables
revealheader "set"
code shellset set

# ( -- ) ( string: name -- contents )  replaces name of an environment variable against contents
revealheader "env"
code environment environment
environment() {
   stos="${!stos}"
}

# ( -- ) shells to bash
revealheader "bash"
code shellbash bash

# ( a n1 -- n2 ) shell, string is command + arguments. returns exit code
revealheader "system"
code system system
system() {
   pack
   $tos
   tos=$?
}

# ( a1 n1 a2 n2 -- n3 ) shell, append a2 n2 as arguments to command a1 n1, returns exit code
revealheader "system2"
code system2 system2
system2() {
   pack
   cmdline=$tos
   tos=${s[sp--]}
   pack
   $tos $cmdline
   tos=$?
}

# ( a n  -- ) takes file name from stack and edits file, using external editor
revealheader "(edit)"
code brtextedit brtextedit
brtextedit() {
   pack
   $EDITOR $tos
   tos=${s[sp--]}
}

# ( <stream> -- ) edit the file with name taken from stream
revealheader "edit"
colon textedit $zero $stream $brtextedit

# ( n -- ) sleeps for n seconds
revealheader "secs"
code secs secs
secs() {
   sleep $tos
   tos=${s[sp--]}
}

# ( n -- ) sleeps for n milliseconds
revealheader "ms"
code ms ms
ms() {
   sleep $((tos/1000)).$((tos%1000))
   tos=${s[sp--]}
}

revealheader "epoche"
code epoche epoche

if (( ${BASH_VERSION%%.*} < 5 )); then
# ( -- n ) returns seconds since 1/1/1970
epoche() {
   s[++sp]=$tos
   tos=$(date +%s)
}
else
# ( -- n ) returns seconds since 1/1/1970
code epoche epoche
epoche() {
   s[++sp]=$tos
   tos=$EPOCHSECONDS
}
fi

# ( -- n ) returns nanoseconds since 1/1/1970
revealheader "nanoseconds"
code nanoseconds nanoseconds
nanoseconds() {  s[++sp]=$tos   tos=$(date +%s%N); }

# ( xt -- n ) measures the time in nanoseconds to execute xt, returned as n
revealheader "time"
colon measuretime  \
    $nanoseconds $to_r $execute $nanoseconds $r_from $minus

# -----------------------------------------------------------------------------
# ------------------------- interpreter entry  point --------------------------
# -----------------------------------------------------------------------------

code commandline commandline
commandline() {
   s[++sp]=$tos
   tos=0                                  # assume no command line
   if [[ $COMMANDLINE ]]; then
      s[++sp]="nop $COMMANDLINE"          # unless one received
      ((m[in+1]=tos=tib+1))               # destination, dest becomes input buffer
      unpack                              # convert string to chars
      m[tos+tib+1]=255                    # end of line delimiter at end of buffer works
      unset COMMANDLINE                   # execute only once
      tos=-1                              # indicate "commandline found"
   fi
}

code setrealthrow setrealthrow
setrealthrow()  {
   m[throw+1]="$realthrow"
}

revealheader "cold"
boot=$dp; colon cold \
   $init_stacks      \
   $init_other       \
   $decimal          \
   $commandline      \
   $branch0 8        \
     $tick $interpret $catch $throw $bye \
   $branch 2         \
      $hello         \
   $setrealthrow     \
   $prompt           \
   $query            \
   $interpret        \
   $prompt           \
   $branch -4
# duplicating part of the outer interpreter loop here is done
# to allow command line actions to carry over stack into the
# interactive interpreter - the "quit" outer interpreter
# initializes the stacks

# -----------------------------------------------------------------------------
# ---------------------------- remove transients ------------------------------
# -----------------------------------------------------------------------------

i=${#remove[*]}
while ((i)); do
   unset "${remove[--i]}"
done

# -----------------------------------------------------------------------------
# ----------------------------- start interpreter -----------------------------
# -----------------------------------------------------------------------------

set +u
[[ -f ~/.bashforthrc ]] && source ~/.bashforthrc
if [[ -f "$sources/$1" ]]; then
   COMMANDLINE="include $*"
else
   COMMANDLINE="$*"
fi
ip=$boot
start

# -----------------------------------------------------------------------------
#                               end of shell script
# -----------------------------------------------------------------------------
