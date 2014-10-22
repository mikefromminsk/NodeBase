library fMath;

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
  else Result := a * 0;
end;

function jl(a, b: Double): Double;
begin
  if a < b
  then Result := 1
  else Result := a * 0;
end;

function je(a, b: Double): Double;
begin
  if a = b
  then Result := 1
  else Result := a * 0;
end;

function round(a: Double): Double;
begin
  Result := System.Round(a);
end;

function abs(a: Double): Double; 
begin
  Result := System.Abs(a);
end;


exports
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
  round,
  abs;

begin

end.

