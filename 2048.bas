' 2048 Game
' Version 1.0.0 for CMMD by William M Leue 22-Feb-2048
' original game created in 2014 by Gabrielle Cirulli.

option default integer
option base 1

' Constants
const SIDE   = 4
const CSIZE  = 88
const BWIDTH = 10
const BW     = SIDE*CSIZE
const BH     = SIDE*CSIZE
const CX     = mm.hres\2 - BW\2
const CY     = mm.vres\2 - BH\2

' Color Indices in Palette
const BCX    = 1
const CCX    = 2

' Commands
const UP    = 128
const DOWN  = 129
const LEFT  = 130
const RIGHT = 131
const ESC   = 27
const HOME  = 134

' Globals
dim board(SIDE, SIDE)
dim patterns(SIDE*SIDE, SIDE)
dim highest_power = 0
dim running = 0

' Main Prgram
open "debug.txt" for output as #1
MakePallette
ReadPatterns
ShowHelp
InitGame
HandleEvents
end

' Make Color Pallette
sub MakePallette
  map(BCX) = rgb(179, 135, 0)
  map(CCX) = rgb(255, 211, 76)
  map set
end sub

' Read Patterns for Movement
sub ReadPatterns
  local i, j
  for i = 1 to SIDE*SIDE
    for j = 1 to SIDE
      read patterns(i, j)
    next j
  next i
end sub
  
' Initialize a Game
sub InitGame
  local row, col
  for row = 1 to SIDE
    for col = 1 to SIDE
      board(row, col) = 0
    next col
  next row
  highest_power = 1
  CreateRandomValue
  CreateRandomValue
  running = 1
  cls
  DrawBoard
end sub

' Create a random 1 or 2 power in a random vacant cell, if one exists.
sub CreateRandomValue
  if BoardFull() then exit sub
  do
    row = RandInt(1, side)
    col = RandInt(1, side)
  loop until board(row, col) = 0
  board(row, col) = RandInt(1, 2)
  if board(row, col) > highest_power then highest_power = board(row, col)
end sub

' Draw the Board
sub DrawBoard
  local row, col, x, y, s, c, v$
  s = CSIZE + 2*BWIDTH
  s2 = CSIZE + BWIDTH
  for row = 1 to SIDE
    y = CY + (row-1)*s2
    for col = 1 to SIDE
      x = CX + (col-1)*s2
      c = GetCellColor(row, col)
      v$ = GetValue$(row, col)
      DrawCell x, y, s, v$, c
    next col
  next row
end sub

' Draw a Cell of the Board
sub DrawCell x, y, s, v$, c
  local nx, ny
  box x, y, s, s,, map(BCX), map(BCX)
  box x+BWIDTH, y+BWIDTH, CSIZE, CSIZE,, c, c
  nx = x + BWIDTH+CSIZE\2
  ny = y + BWIDTH+CSIZE\2
  if len(v$) > 0 then
    text nx, ny, v$, "CM", 5,, rgb(black), -1
    text nx+1, ny, v$, "CM", 5,, rgb(black), -1
  end if
end sub

' Assign a color to a board cell depending on its current value
function GetCellColor(row, col)
  local float h, s, v
  local r, g, b, p
  local c = MAP(CCX)
  GetCellColor = c
  p = board(row, col)
  if p > 0 then
    h = 240.0 - 240*((1.0*p)/11.0)
    s = 1.0
    v = 1.0
    HSV2RGB h, s, v, r, g, b
    GetCellColor = rgb(r, g, b)
  end if
end function

' return the string numeric value of a board cell
' if that cell's power >= 1, else return the empty string.
function GetValue$(row, col)
  local nx, ny, p, v
  p = board(row, col)
  if p > 0 then
    v = 2^p
    GetValue$ = str$(v)
  else
    GetValue$ = ""
  end if
end function

' Get User Keyboard Inputs
sub HandleEvents
  local z$, cmd
  z$ = INKEY$
  do
    do
      z$ = INKEY$
    loop until z$ <> ""
    cmd = asc(UCASE$(z$))
    if cmd = ESC then
      cls
      end
    end if
    if cmd = HOME then
      InitGame
    end if
    if running then
      select case cmd
        case UP
          Merge(UP)
        case DOWN
          Merge(DOWN)
        case LEFT
          Merge(LEFT)
        case RIGHT
          Merge(RIGHT)
      end select
      DrawBoard
    end if
    if GameOver() then
      running = 0
      ShowGameOver
    end if
  loop
end sub

' Shift Values and Merge in the specified direction
sub Merge cmd
  local row, col
  select case cmd
    case UP
      PushCellsUp
    case DOWN
      PushCellsDown
    case LEFT
      PushCellsLeft
    case RIGHT
      PushCellsRight
  end select
  CreateRandomValue
end sub

' Push cells up and merge
sub PushCellsUp
  local row, col, p
  local pat(SIDE)
  for col = 1 to SIDE
    row = 1
    MatchPattern row, col, 1, 0, pat()
    for row = 1 to SIDE
      p = pat(row)
      if p > 0 then
        board(row-p, col) = board(row, col)
        board(row, col) = 0
      end if
    next row
    MergeUp col
  next col
end sub

' Merge matching cells upwards
sub MergeUp col
  local row, nrow
  for row = 1 to SIDE-1
  if board(row, col) > 0 then
      if board(row+1, col) = board(row, col) then
        inc board(row, col)
        if board(row, col) > highest_power then highest_power = board(row, col)
        for nrow = row+2 to side
          board(nrow-1, col) = board(nrow, col)
        next nrow
        board(SIDE, col) = 0
      end if
    end if
  next row
end sub

' Push cells down and merge
sub PushCellsDown
  local row, col, p
  local pat(SIDE)
  for col = 1 to SIDE
    row = SIDE
    MatchPattern row, col, -1, 0, pat()
    for row = SIDE to 1 step -1
      p = pat(row)
      if p > 0 then
        board(row+p, col) = board(row, col)
        board(row, col) = 0
      end if
    next row
    MergeDown col
  next col
end sub

' Merge matching cells downwards
sub MergeDown col
  local row, nrow
  for row = SIDE to 2 step -1
  if board(row, col) > 0 then
      if board(row-1, col) = board(row, col) then
        inc board(row, col)
        if board(row, col) > highest_power then highest_power = board(row, col)
        for nrow = row-2 to 1 step -1
          board(nrow+1, col) = board(nrow, col)
        next nrow
        board(1, col) = 0
      end if
    end if
  next row
end sub

' Push cells Left and merge
sub PushCellsLeft
  local row, col, p
  local pat(SIDE)
  for row = 1 to SIDE
    col = 1
    MatchPattern row, col, 0, 1, pat()
    for col = 1 to SIDE
      p = pat(col)
      if p > 0 then
        board(row, col-p) = board(row, col)
        board(row, col) = 0
      end if
    next col
    MergeLeft row
  next row
end sub

' Merge matching cells leftwards
sub MergeLeft row
  local col, ncol
  for col = 1 to SIDE-1
  if board(row, col) > 0 then
      if board(row, col+1) = board(row, col) then
        inc board(row, col)
        if board(row, col) > highest_power then highest_power = board(row, col)
        for ncol = col+2 to SIDE
          board(row, ncol-1) = board(row, ncol)
        next ncol
        board(row, SIDE) = 0
      end if
    end if
  next col
end sub

' Push cells right and merge
sub PushCellsRight
  local row, col, p
  local pat(SIDE)
  for row = 1 to SIDE
    col = SIDE
    MatchPattern row, col, 0, -1, pat()
    for col = SIDE to 1 step -1
      p = pat(col)
      if p > 0 then
        board(row, col+p) = board(row, col)
        board(row, col) = 0
      end if
    next col
    MergeRight row
  next row
end sub

' Merge matching cells rightwards
sub MergeRight row
  local col, ncol
  for col = SIDE to 2 step -1
  if board(row, col) > 0 then
      if board(row, col-1) = board(row, col) then
        inc board(row, col)
        if board(row, col) > highest_power then highest_power = board(row, col)
        for ncol = col-2 to 1 step -1
          board(row, ncol+1) = board(row, ncol)
        next ncol
        board(row, 1) = 0
      end if
    end if
  next col
end sub

' Find the pattern of values that matches a template.
' We add up the non-zero cells not by their values, but
' by the powers of 2 that match their location. This yields
' an index into the template array which gives the spaces
' to be shifted during a move in any direction.
sub MatchPattern row, col, dr, dc, pat()
  local i, index, p = 3, crow, ccol, px
  index = 0 : crow = row : ccol = col
  for i = 1 to SIDE
    if board(crow, ccol) > 0 then
      inc index, 2^p
    end if
    inc crow, dr : inc ccol, dc : inc p, -1
  next i
  inc index, 1
  if dr <> 0 then
    px = row  
  else
    px = col
  end if
  for i= 1 to 4
    pat(px) = patterns(index, i)
    if dr <> 0 then
      inc px, dr
    else
      inc px, dc
    end if
  next i
end sub

' Returns 1 if board is full or zero if not
function BoardFull()
  local row, col
  for row = 1 to SIDE
    for col = 1 to SIDE
      if board(row, col) = 0 then
        BoardFull = 0
        exit function
      end if
    next col
  next row
  BoardFull = 1
end function

' The game is over when all cells have non-zero values and
' no cells can be merged
function GameOver()
  local row, col, p1, p2, f
  GameOver = 0
  f = BoardFull()
  if f then
    for row = 1 to SIDE
      for col = 1 to SIDE-1
        p1 = board(row, col)
        p2 = board(row, col+1)
        if p1 = p2 then exit function
      next col
    next row
    for col = 1 to SIDE
      for row = 1 to SIDE-1
        p1 = board(row, col)
        p2 = board(row+1, col)
        if p1 = p2 then exit function
      next row
    next col
    GameOver = 1
  end if
end function  

' Show the Game Over
sub ShowGameOver
  local m$
  text mm.hres\2, 0, "Game Over", "CT", 5,, rgb(red), -1
  m$ = "Highest Power of 2 Achieved: " + str$(2^highest_power)
  text mm.hres\2, 40, m$, "CT", 4,, rgb(green), -1
  if highest_power >= 11 then
    text mm.hres\2, 60, "*** WINNER ***", "CT", 4,, rgb(100, 100, 255), -1
  end if
  text mm.hres\2, mm.vres-2, "Press Home Key for a New Game", "CB", 4,, rgb(green), -1
end sub

' Offer Help
sub ShowHelp
  local a$
  cls
  print "Need Instructions? (Y,N): ";
  input "", a$
  if LEFT$(UCASE$(a$), 1) <> "Y" then exit sub
  cls
  text mm.hres\2, 0, "Rules for the 2048 Game", "CT", 5,, rgb(green)
  print @(0, 40)
  print "The goal of the 2048 game is to merge cells on a 4x4 board until you get to the value"
  print "of 2048 (or up to 131,072, which is the highest possible value).
  print ""
  print "The board starts out with all cells empty except for 2 random cells, which have the"
  print "values of 2 or 4, randomly chosen. Use the arrow keys to slide cells up, down, left,"
  print "and right. All the cells on the board will be slid as far as possible in the chosen"
  print "direction.
  print ""
  print "Each time you slide cells in a direction, any two cells which are adjacent"
  print "in that direction and which have the same value will be merged into a single cell that"
  print "has the sum of the values of the two cells. So for instance, if you press the LEFT"
  print "arrow and there are two adjacent cells in a row, each having a 2 in them, they will be"
  print "merged into a single cell having a 4 in it."
  print ""
  print "If there are 3 adjacent cells having the same value, only the two cells closest to the"
  print "edge that the cells are sliding towards will get merged. But if there are 4 adjacent"
  print "cells having the same value, then each pair of cells will be merged. However, the"
  print "resulting pair of identical cells of the next higher value will require another key"
  print "press to merge."
  print ""
  print "After each move, an empty cell will be randomly filled with a 2 or a 4."
  print ""
  print "The game is over when all the cells are filled or there are no more adjacent cells"
  print "that can be merged with a move in any direction."
  print ""
  print "You can press the HOME key at any time to start a new game. To quit the program,"
  print "press the ESCAPE key."
  print ""
  print "The 2048 game was invented by Gabriele Cirulli in 2014. This version for the CMM2"
  print "was reverse-engineered by William M. Leue using the Wikipedia description of the game."
  text mm.hres\2, mm.vres-1, "Press Any Key to Continue"
  a$ = INKEY$
  do
    a$ = INKEY$
  loop until a$ <> ""
  cls
end sub

' return a uniformly distributed random integer in the specified closed range
function RandInt(a as integer, b as integer)
  local integer v, c
  c = b-a+1
  do
    v = a + (b-a+2)*rnd()
    if v >= a and v <= b then exit do
  loop
  RandInt = v
end function

' Convert an HSV value to its RGB equivalent
' The S and V values must be in range 0..1; the H value must
' be in range 0..360. The RGB values will be in range 0..255.
sub HSV2RGB h as float, s as float, v as float, r, g, b
  local float i, hh, f, p, q, t, x, c, rp, gp, bp
  c = v*s
  hh = h/60.0
  i = int(hh)
  f = hh - i
  p = v*(1-s)
  q = v*(1-s*f)
  t = v*(1-s*(1-f))
  x = c*(1.0 - hh MOD 2 - 1)
  
  select case i
    case 0
      rp = v : gp = t : bp = p
    case 1
      rp = q : gp = v : bp = p
    case 2
      rp = p : gp = v : bp = t
    case 3
      rp = p : gp = q : bp = v
    case 4
      rp = t : gp = p : bp = v
    case 5
      rp = v : gp = p : bp = q
  end select
  r = rp*255.0 : g = gp*255.0 : b = bp*255.0
end sub

' Cell Population templates for shifting.
data 0, 0, 0, 0
data 0, 0, 0, 3
data 0, 0, 2, 0
data 0, 0, 2, 2
data 0, 1, 0, 0
data 0, 1, 0, 2
data 0, 1, 1, 0
data 0, 1, 1, 1
data 0, 0, 0, 0
data 0, 0, 0, 2
data 0, 0, 1, 0
data 0, 0, 1, 1
data 0, 0, 0, 0
data 0, 0, 0, 1
data 0, 0, 0, 0
data 0, 0, 0, 0

