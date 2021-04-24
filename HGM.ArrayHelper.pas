unit HGM.ArrayHelper;

interface

uses
  System.Generics.Collections;

type
  TArrayWalker<T> = reference to procedure(const Item: T; Index: Integer);

  TArrayWalkerWrite<T> = reference to procedure(var Item: T; Index: Integer);

  TFuncCompare<T> = reference to function(const Left, Right: T): Integer;

  TArrayHelp = class(TArray)
  public
    class function Add<T>(var Target: TArray<T>; const Items: array of T): Integer; overload;
    class function Add<T>(var Target: TArray<T>; const Item: T): Integer; overload;
    class function Append<T>(var Target: TArray<T>; Count: Integer = 1): Integer; inline; static;
    class function InArray<T>(Target: TArray<T>; Item: T): Boolean; overload; inline;
    class function Sorted<T>(const Target: TArray<T>; Compare: TFuncCompare<T>): TArray<T>; inline;
    class procedure FreeArrayOfObject<T: class>(var Target: TArray<T>); overload; inline; static;
    class procedure FreeArrayOfArrayOfObject<T: class>(var Target: TArray<TArray<T>>); overload; inline; static;
    class procedure Sort<T>(var Target: TArray<T>; Compare: TFuncCompare<T>); inline;
    class procedure Walk<T>(const Target: TArray<T>; Proc: TArrayWalker<T>; Offset: Integer = 0); overload; inline; static;
    class procedure Walk<T>(const Target: array of T; Proc: TArrayWalker<T>; Offset: Integer = 0); overload; static;
    class procedure Walk<T>(var Target: TArray<T>; Proc: TArrayWalkerWrite<T>; Offset: Integer = 0); overload; inline; static;
    class procedure Walk<T>(var Target: array of T; Proc: TArrayWalkerWrite<T>; Offset: Integer = 0); overload; static;
  end;

implementation

uses
  System.Generics.Defaults;

{ TArrayHelp }

class procedure TArrayHelp.FreeArrayOfObject<T>(var Target: TArray<T>);
  {$IFNDEF AUTOREFCOUNT}
var
  Item: T;
  {$ENDIF}
begin
  {$IFNDEF AUTOREFCOUNT}
  for Item in Target do
    Item.Free;
  SetLength(Target, 0);
  {$ENDIF}
end;

class function TArrayHelp.InArray<T>(Target: TArray<T>; Item: T): Boolean;
var
  i: Integer;
var
  Comparer: IComparer<T>;
begin
  Comparer := TComparer<T>.Default;
  Result := False;
  for i := Low(Target) to High(Target) do
    if Comparer.Compare(Target[i], Item) = 0 then
      Exit(True);
end;

class procedure TArrayHelp.Sort<T>(var Target: TArray<T>; Compare: TFuncCompare<T>);
var
  i, j: Integer;
  Buf: T;
begin
  for j := 0 to High(Target) - 1 do
    for i := 0 to High(Target) - j do
      if Compare(Target[i], Target[i + 1]) <> 0 then
      begin
        Buf := Target[i];
        Target[i] := Target[i + 1];
        Target[i + 1] := Buf;
      end;
end;

class function TArrayHelp.Sorted<T>(const Target: TArray<T>; Compare: TFuncCompare<T>): TArray<T>;
begin
  Result := Target;
  Sort<T>(Result, Compare);
end;

class procedure TArrayHelp.Walk<T>(var Target: array of T; Proc: TArrayWalkerWrite<T>; Offset: Integer);
var
  i: Integer;
  Item: T;
begin
  for i := Low(Target) + Offset to High(Target) do
  begin
    Item := Target[i];
    Proc(Item, i);
    Target[i] := Item;
  end;
end;

class function TArrayHelp.Append<T>(var Target: TArray<T>; Count: Integer): Integer;
begin
  Result := Length(Target);
  SetLength(Target, Result + 1);
end;

class procedure TArrayHelp.Walk<T>(var Target: TArray<T>; Proc: TArrayWalkerWrite<T>; Offset: Integer);
var
  i: Integer;
  Item: T;
begin
  for i := Low(Target) + Offset to High(Target) do
  begin
    Item := Target[i];
    Proc(Item, i);
    Target[i] := Item;
  end;
end;

class procedure TArrayHelp.Walk<T>(const Target: TArray<T>; Proc: TArrayWalker<T>; Offset: Integer);
var
  i: Integer;
begin
  for i := Low(Target) + Offset to High(Target) do
    Proc(Target[i], i);
end;

class procedure TArrayHelp.Walk<T>(const Target: array of T; Proc: TArrayWalker<T>; Offset: Integer);
var
  i: Integer;
begin
  for i := Low(Target) + Offset to High(Target) do
    Proc(Target[i], i);
end;

class function TArrayHelp.Add<T>(var Target: TArray<T>; const Item: T): Integer;
begin
  Result := Add<T>(Target, [Item]);
end;

class function TArrayHelp.Add<T>(var Target: TArray<T>; const Items: array of T): Integer;
var
  i: Integer;
  Item: T;
  Buf: array of T;
begin
  Result := Length(Target);
  SetLength(Target, Length(Target) + Length(Items));
  for i := Low(Target) + (Result - 1) to High(Target) do
  begin
    Target[i] := Items[i - Result];
  end;
  Result := Length(Target);
end;

class procedure TArrayHelp.FreeArrayOfArrayOfObject<T>(var Target: TArray<TArray<T>>);
  {$IFNDEF AUTOREFCOUNT}
var
  Item: T;
  Items: TArray<T>;
  {$ENDIF}
begin
  {$IFNDEF AUTOREFCOUNT}
  for Items in Target do
    for Item in Items do
      Item.Free;
  SetLength(Target, 0);
  {$ENDIF}
end;

end.
