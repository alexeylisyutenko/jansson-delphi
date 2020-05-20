unit TestDumpCallback;

interface

uses
  TestFramework, Jansson;

type
  TTestDumpCallback = class(TTestCase)
  published
    procedure TestDumpCallback;
  end;

  TMySink = record
    buf: PAnsiChar;
    off: size_t;
    cap: size_t;
  end;
  
function my_writer(buffer: PAnsiChar; buflen: size_t; data: Pointer): size_t; cdecl;

implementation

uses
  SysUtils, Windows;

function my_writer(buffer: PAnsiChar; buflen: size_t; data: Pointer): size_t; cdecl;
var
  LSink: ^TMySink;
begin
  LSink := data;
  if buflen > (LSink.cap - LSink.off) then begin
    Result := size_t(-1);
    Exit;
  end;
  CopyMemory(Pointer(NativeInt(LSink.buf) + LSink.off), buffer, buflen);
  Inc(LSink.off, buflen);
  Result := 0;
end;


{ TTestDumpCallback }

procedure TTestDumpCallback.TestDumpCallback;
var
  LSink: TMySink;
  LJson: PJson;
  LStr: PAnsiChar;
  LDumpedToString: PAnsiChar;
begin
  LStr := '["A", {"B": "C", "e": false}, 1, null, "foo"]';

  LJson := json_loads(LStr, 0, nil);
  if LJson = nil then begin
    Fail('json_loads failed');
  end; 

  LDumpedToString := json_dumps(LJson, 0);
  if LDumpedToString = nil then begin
    json_decref(LJson);
    Fail('json_dumps failed');
  end;

  LSink.off := 0;
  LSink.cap := StrLen(LDumpedToString);
  LSink.buf := delphi_json_malloc(LSink.cap);
  if LSink.buf = nil then begin
    json_decref(LJson);
    delphi_json_free(LDumpedToString);
    Fail('malloc failed');
  end;

  if json_dump_callback(LJson, @my_writer, @LSink, 0) = -1 then begin
    json_decref(LJson);
    delphi_json_free(LDumpedToString);
    delphi_json_free(LSink.buf);
    Fail('json_dump_callback failed on an exact-length sink buffer');
  end;

  if StrLComp(LDumpedToString, LSink.buf, LSink.off) <> 0 then begin
    json_decref(LJson);
    delphi_json_free(LDumpedToString);
    delphi_json_free(LSink.buf);
    Fail('json_dump_callback and json_dumps did not produce identical '
           +'output');
  end;

  LSink.off := 1;
  if json_dump_callback(LJson, @my_writer, @LSink, 0) <> -1 then begin
    json_decref(LJson);
    delphi_json_free(LDumpedToString);
    delphi_json_free(LSink.buf);
    Fail('json_dump_callback succeeded on a short buffer when it should '
           +'have failed');
  end;

  json_decref(LJson);
  delphi_json_free(LDumpedToString);
  delphi_json_free(LSink.buf);
end;

initialization
  RegisterTest(TTestDumpCallback.Suite);

end.
