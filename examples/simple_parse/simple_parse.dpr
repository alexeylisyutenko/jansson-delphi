program simple_parse;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Jansson in '..\..\Jansson.pas';

(* forward refs *)

procedure PrintJson(ARoot: PJson); forward;
procedure PrintJsonAux(AElement: PJson; AIndent: Integer); forward;
procedure PrintJsonIndent(AIndent: Integer); forward;
function JsonPlural(ACount: Integer): AnsiString; forward;
procedure PrintJsonObject(AElement: PJson; AIndent: Integer); forward;
procedure PrintJsonArray(AElement: PJson; AIndent: Integer); forward;
procedure PrintJsonString(AElement: PJson; AIndent: Integer); forward;
procedure PrintJsonInteger(AElement: PJson; AIndent: Integer); forward;
procedure PrintJsonReal(AElement: PJson; AIndent: Integer); forward;
procedure PrintJsonTrue(AElement: PJson; AIndent: Integer); forward;
procedure PrintJsonFalse(AElement: PJson; AIndent: Integer); forward;
procedure PrintJsonNull(AElement: PJson; AIndent: Integer); forward;
function LoadJson(AText: AnsiString): PJson; forward;
function ReadJsonLine: AnsiString; forward;



procedure PrintJson(ARoot: PJson);
begin
  PrintJsonAux(ARoot, 0);
end;

procedure PrintJsonAux(AElement: PJson; AIndent: Integer);
begin
  case (json_typeof(AElement)) of
    JSON_OBJECT_T:
      PrintJsonObject(AElement, AIndent);
    JSON_ARRAY_T:
      PrintJsonArray(AElement, AIndent);
    JSON_STRING_T:
      PrintJsonString(AElement, AIndent);
    JSON_INTEGER_T:
      PrintJsonInteger(AElement, AIndent);
    JSON_REAL_T:
      PrintJsonReal(AElement, AIndent);
    JSON_TRUE_T:
      PrintJsonTrue(AElement, AIndent);
    JSON_FALSE_T:
      PrintJsonFalse(AElement, AIndent);
    JSON_NULL_T:
      PrintJsonNull(AElement, AIndent);
    else
      WriteLn(Format('unrecognized JSON type %d', [Ord(json_typeof(AElement))]));
  end;
end;

procedure PrintJsonIndent(AIndent: Integer);
var
  I: Integer;
begin
  for I := 0 to AIndent - 1 do begin
    Write(' ');
  end;
end;

function JsonPlural(ACount: Integer): AnsiString;
begin
  if ACount = 1 then begin
    Result := '';
  end else begin
    Result := 's';
  end;
end;

procedure PrintJsonObject(AElement: PJson; AIndent: Integer);
var
  LSize: size_t;
  LKey: PAnsiChar;
  LValue: PJson;
begin
  PrintJsonIndent(AIndent);
  LSize := json_object_size(AElement);

  WriteLn(Format('JSON Object of %d pair%s:', [LSize, JsonPlural(LSize)]));
  LKey := json_object_iter_key(json_object_iter(AElement));
  while (LKey <> nil) do begin
    LValue := json_object_iter_value(json_object_key_to_iter(LKey));

    PrintJsonIndent(AIndent + 2);
    Writeln(Format('JSON Key: "%s"', [LKey]));
    PrintJsonAux(LValue, AIndent + 2);
    
    LKey := json_object_iter_key(json_object_iter_next(AElement, json_object_key_to_iter(LKey)));
  end;  
end;

procedure PrintJsonArray(AElement: PJson; AIndent: Integer);
var
  LSize: size_t;
  I: Integer;
begin
  LSize := json_array_size(AElement); 
  PrintJsonIndent(AIndent);

  WriteLn(Format('JSON Array of %d element%s:', [LSize, JsonPlural(LSize)]));
  for I := 0 to LSize - 1 do begin
    PrintJsonAux(json_array_get(AElement, I), AIndent + 2);    
  end;
end;

procedure PrintJsonString(AElement: PJson; AIndent: Integer);
begin
  PrintJsonIndent(AIndent);
  WriteLn(Format('JSON String: "%s"', [json_string_value(AElement)]));  
end;

procedure PrintJsonInteger(AElement: PJson; AIndent: Integer);
begin
  PrintJsonIndent(AIndent);
  WriteLn(Format('JSON Integer: %d', [json_integer_value(AElement)]));
end;

procedure PrintJsonReal(AElement: PJson; AIndent: Integer);
begin
  PrintJsonIndent(AIndent);
  WriteLn(Format('JSON Real: %f', [json_real_value(AElement)]));    
end;

procedure PrintJsonTrue(AElement: PJson; AIndent: Integer);
begin
  PrintJsonIndent(AIndent);
  WriteLn('JSON True');    
end;

procedure PrintJsonFalse(AElement: PJson; AIndent: Integer);
begin
  PrintJsonIndent(AIndent);
  WriteLn('JSON False');    
end;

procedure PrintJsonNull(AElement: PJson; AIndent: Integer);
begin
  PrintJsonIndent(AIndent);
  WriteLn('JSON Null');    
end;

function LoadJson(AText: AnsiString): PJson;
var
  LRoot: PJson;
  LError: TJsonError;
begin
  LRoot := json_loads(PAnsiChar(AText), 0, @LError);
  if (LRoot <> nil) then begin
    Result := LRoot;
  end else begin
    WriteLn(Format('json error on line %d: %s', [LError.line, LError.text]));
    Result := nil;
  end;
end;

function ReadJsonLine: AnsiString;
var
  LLine: String;
begin
  Write('Type some JSON > ');
  ReadLn(LLine);
  Result := LLine;
end;

(* main *)

var
  Line: AnsiString;
  Root: PJson;
  
begin
  ReportMemoryLeaksOnShutdown := True;

  if (ParamCount <> 0) then begin
    WriteLn(Format('Usage: %s', [ExtractFileName(ParamStr(0))]));
    ReadLn;
    Exit;
  end;

  while True do begin
    Line := ReadJsonLine;
    if Line = '' then begin
      Break;
    end;

    Root := LoadJson(Line);
    if Root <> nil then begin
      PrintJson(Root);
      json_decref(Root);
    end;
  end;
  
end.
