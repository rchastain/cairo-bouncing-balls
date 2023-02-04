
unit Geometry;

interface

uses
  Classes, SysUtils;

function Tan(x: extended): extended;
function Hypot(x, y: extended): extended;
function DegToRad(x: extended): extended;
function RadToDeg(x: extended): extended;
function Tangens(x: extended): extended;
function Sinus(x: extended): extended;
function Cosinus(x: extended): extended;
function ArcTangens(x, y: extended): extended;

implementation

function Tan(x: extended): extended;
begin
  Tan := Sin(x) / Cos(x);
end;

function Hypot(x, y: extended): extended;
var
  z: extended;
begin
  x := Abs(x);
  y := Abs(y);
  if x > y then
  begin
    z := x;
    x := y;
    y := z;
  end;
  if x = 0 then
    result := y
  else // y > x, x <> 0, so y > 0
    result := y * Sqrt(1 + Sqr(x / y));
end;

function DegToRad(x: extended): extended;
begin
  result := x * (PI / 180);
end;

function RadToDeg(x: extended): extended;
begin
  result := x * (180 / PI);
end;

function Tangens(x: extended): extended;
begin
  result := Tan(DegToRad(x));
end;

function Sinus(x: extended): extended;
begin
  result := Sin(DegToRad(x));
end;

function Cosinus(x: extended): extended;
begin
  result := Cos(DegToRad(x));
end;

function ArcTangens(x, y: extended): extended;
begin
  result := 0;
  if x = 0 then
  begin
    if y >= 0 then
      result :=  90
    else
      result := 270;
  end else
  begin
    result := RadToDeg(ArcTan(y / x));
    if (x < 0) and (y > 0) or (x < 0) and (y <= 0) then
      result := 180 + result;
    if (x > 0) and (y < 0) then
      result := 360 + result;
  end;
end;

end.

