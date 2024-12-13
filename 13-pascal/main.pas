program Main;
uses
  Classes, SysUtils, Math;

const
  TOLERANCE = 0.0001;
  SHIFT = 10000000000000;

procedure SplitText(const delim, s: String; parts: TStringList);
begin
  parts.LineBreak := delim;
  parts.Text := s;
end;

procedure ReadMachine(const subdelim: String; var rx, ry: Int64);
var
  line: String;
  parts: TStringList;
  subparts: TStringList;
begin
  parts := TStringList.Create;
  subparts := TStringList.Create;

  ReadLn(line);
  SplitText(',', line, parts);
  SplitText(subdelim, parts[0], subparts);
  rx := StrToInt64(subparts[1]);
  SplitText(subdelim, parts[1], subparts);
  ry := StrToInt64(subparts[1]);
end;

procedure SolveMachine(const ax, ay, bx, by, tx, ty: Int64; var total: Int64);
var
  a, b, num, den: Int64;
begin
  num := ax * ty - ay * tx;
  den := ax * by - ay * bx;
  b := num div den;
  if (num mod den = 0) and ((tx - bx * b) mod ax = 0) then
  begin
    a := (tx - bx * b) div ax;
    total := total + 3 * a + b;
  end;
end;

var
  puzzle1, puzzle2, ax, ay, bx, by, tx, ty: Int64;
begin
  puzzle1 := 0;
  puzzle2 := 0;

  while not eof do
  begin
    ReadMachine('+', ax, ay);
    ReadMachine('+', bx, by);
    ReadMachine('=', tx, ty);
    ReadLn();
    SolveMachine(ax, ay, bx, by, tx, ty, puzzle1);
    SolveMachine(ax, ay, bx, by, tx + SHIFT, ty + SHIFT, puzzle2);
  end;

  WriteLn('Puzzle 1: ', puzzle1);
  WriteLn('Puzzle 2: ', puzzle2);
end.
