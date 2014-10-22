library fMath;

uses
  Math, SysUtils, Dialogs;

function add(a, b: Double): Double;
begin
  Result := a + b;
end;

function inc(a: Double): Double;
begin
  Result := a + 1;
end;

function sub(a, b: Double): Double;
begin
  Result := a - b;
end;

function mul(a, b: Double): Double;
begin
  Result := a * b;
end;

function fdiv(a, b: Double): Double;
begin
  Result := a / b;
end;

function sqr(a: Double): Double;
begin
  Result := System.Sqr(a);
end;

function sqrt(a: Double): Double;
begin
  Result := System.Sqrt(a);
end;

function jg(a, b: Double): Double;
begin
  if a > b
  then Result := 1
  else Result := 0;
  asm stc end;   //установка флага переноса(CF) в 1
end;

function jl(a, b: Double): Double;
begin
  if a < b
  then Result := 1
  else Result := 0;
  asm stc end;
end;

function je(a, b: Double): Double;
begin
  if a = b
  then Result := 1
  else Result := 0;
  asm stc end;
end;

function roundto(a, b: Double): Double;
var
  Range: TRoundToRange;
begin
  Range := 0;
  if (b >= -37) and (b <= 37) then
    Range := Round(b);
  Result := Math.RoundTo(a, Range);
  asm stc end;
end;

function abs(a: Double): Double;
begin
  Result := System.Abs(a);
end;


exports
  //!!REGISTR
  add,
  inc,
  sub,
  mul,
  fdiv,
  sqr,
  sqrt,
  jg,
  jl,
  je,
  roundto,
  abs;

begin

end.

