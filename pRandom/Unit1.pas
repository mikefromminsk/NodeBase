unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, Math, ExtCtrls, TeeProcs, TeEngine, Chart,
  Series;

type
  TForm1 = class(TForm)
    SG: TStringGrid;
    Button1: TButton;
    Chart1: TChart;
    Series1: TLineSeries;
    Button2: TButton;
    SG2: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses Types;



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


procedure TForm1.FormCreate(Sender: TObject);
var i: Integer;
begin
  Randomize;

  for i:=0 to SG2.ColCount-1 do
    SG2.Cells[i,0] := IntToStr(Random(100));

  for i:=0 to SG2.ColCount-1 do
  begin
    SetLength(A, High(A)+2);
    A[i] := StrToIntDef(SG2.Cells[i,0], 0);
  end;

end;


function Draw(): Integer;
var
  i: Integer;
begin
  with Form1 do
  begin
  Series1.Clear;
  for i:=0 to SG.ColCount -1 do
    Series1.Add(StrToIntDef(SG.Cells[i,0], 0));
  end;
end;


procedure TForm1.Button1Click(Sender: TObject);
var
  i: Integer;
  s,range: Integer;
begin
  for i:=0 to 100 do
  begin
    range := 10;
    s := CauchyRandom(range) + range;
    SG.Cells[s,0] := IntToStr(StrToIntDef(SG.Cells[s,0], 0)+1);
  end;
  Draw;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  i, n: Integer;
begin
  for i:=0 to 100 do
  begin
    n := RandomArr(A);
    sg.Cells[n,0] := IntToStr(StrToIntDef(sg.Cells[n,0],0)+1);
  end;
  Draw;
end;

end.
