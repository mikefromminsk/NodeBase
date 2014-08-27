unit GeneratorUtils;

interface

uses
  Math;

type
  TIntegerDynArray = array of Integer;

function Random(Range: Integer): Integer; overload;
function Random(Arr: TIntegerDynArray; var InnerIndex: Integer): Integer;  overload;
function Random(Arr: TIntegerDynArray): Integer; overload;
function Random(const Arr: array of integer): Integer; overload;
function CauchyRandom(BeginRange, CenterRange, EndRange: Integer): Integer;
function IfThen(AValue: Boolean; const ATrue: Integer; const AFalse: Integer = 0): Integer;

var
  RandomVariable: Integer;

implementation


function Random(Range: Integer): Integer; overload;
begin
  Inc(RandomVariable);
  Result := RandomVariable mod Range;
end;

function Random(Arr: TIntegerDynArray; var InnerIndex: Integer): Integer;  overload;
var i: Integer;
begin
  InnerIndex := Random(MaxInt) mod SumInt(Arr);
  for i:=0 to High(Arr) do
  begin
    if InnerIndex - Arr[i] < 0 then
    begin
      Result := i;
      Exit;
    end;
    InnerIndex := InnerIndex - Arr[i];
  end;
end;

function Random(Arr: TIntegerDynArray): Integer; overload;
var InnerIndex: Integer;
begin
  Result := Random(Arr, InnerIndex);
end;

function CauchyRandom(BeginRange, CenterRange, EndRange: Integer): Integer;
var MaxRange, MinRange: Integer;
begin
  repeat
    MaxRange := Max(CenterRange - BeginRange, EndRange - CenterRange);
    MinRange := Min(CenterRange - BeginRange, EndRange - CenterRange);
    Result := Round(Tan(PI * (Random(MaxInt) / MaxInt - 0.5)));
    Result := Result mod (MaxRange + 1);
    Result := Result + CenterRange;
  until (Result >= BeginRange) and (Result <= EndRange);
end;

function IfThen(AValue: Boolean; const ATrue: Integer; const AFalse: Integer): Integer;
begin
  if AValue then
    Result := ATrue
  else
    Result := AFalse;
end;


function Random(const Arr: array of integer): Integer; overload;
var
  i, InnerIndex: Integer;
  DynArr: TIntegerDynArray;
begin
  SetLength(DynArr, Length(Arr));
  for i := 0{Low(Arr)} to High(Arr) do
    DynArr[i] := Arr[i];
  Result := Random(DynArr, InnerIndex);
  SetLength(DynArr, 0);
end;

initialization
  RandomVariable := 1;
end.
