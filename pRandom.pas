{Cauchy distribution
1             _
             / \
           _/   \_
          /       \
     ____/         \____
-n__/      -1 0 1       \__n }

function CauchyRandom(Range: Integer = MaxInt): Integer;
begin
  {while True do
  begin
    try}
      Result := Random($FFFF);
      Result := Result shl 16;
      Result := Result or Random($FFFF);
      Result := Result xor GetTickCount;
      Result := Round(Tan(PI * (Result / MaxInt - 0.5)));
      Result := Result mod Range;
      {Break;
    except
    end;
  end; }
end;
//-------------------------------------------------------------------------



var A: TIntegerDynArray;

{Arrays distribution
80, 40, 20, 10, 1
 _
80|
  |_
  40|
    |_
    20|_
        |______
 0 1 2 3 4  Index -}

function RandomArr(A: TIntegerDynArray): Integer;
var i: Integer;
begin
  Result := Random(MaxInt);
  Result := Result mod SumInt(A);
  for i:=0 to High(A) do
  begin
    Result := Result - A[i];
    if Result <= 0 then
    begin
      Result := i;
      Exit;
    end;
  end;
end;
//-------------------------------------------------------------------------