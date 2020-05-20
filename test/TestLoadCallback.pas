unit TestLoadCallback;

interface

uses
  TestFramework, Jansson;

type
  TTestLoadCallback = class(TTestCase)
  published
    procedure TestTestLoadCallback;
  end;

  TMySource = record
    buf: PAnsiChar;
    off: size_t;
    cap: size_t;
  end;

const
  MyStr: PAnsiChar = '["A", {"B": "C", "e": false}, 1, null, "foo"]';

function greedy_reader(buffer: Pointer; buflen: size_t; data: Pointer): size_t; cdecl;

implementation

uses
  SysUtils, Windows;

function greedy_reader(buffer: Pointer; buflen: size_t; data: Pointer): size_t; cdecl;
var
  LSource: ^TMySource;
begin
  LSource := data;
  if buflen > (LSource.cap - LSource.off) then begin
    buflen := LSource.cap - LSource.off;
  end;
  if buflen > 0 then begin
    CopyMemory(buffer, Pointer(NativeInt(LSource.buf) + LSource.off), buflen);
    Inc(LSource.off, buflen);    Result := buflen;  end else begin    Result := 0;  end;
end;

{ TTestLoadCallback }

procedure TTestLoadCallback.TestTestLoadCallback;
var
  LSource: TMySource;
  LJson: PJson;
  LError: TJsonError;
begin
  LSource.off := 0;
  LSource.cap := StrLen(MyStr);
  LSource.buf := MyStr;

  LJson := json_load_callback(@greedy_reader, @LSource, 0, @LError);

  if LJson = nil then begin
    Fail('json_load_callback failed on a valid callback');
  end;
  json_decref(LJson);

  LSource.off := 0;
  LSource.cap := StrLen(MyStr) - 1;
  LSource.buf := MyStr;

  LJson := json_load_callback(@greedy_reader, @LSource, 0, @LError);
  if LJson <> nil then begin
    json_decref(LJson);
    Fail('json_load_callback should have failed on an incomplete stream, '
           +'but it didn''t');
  end;

  if StrComp(LError.source, '<callback>') <> 0 then begin
    Fail('json_load_callback returned an invalid error source');
  end;
  if StrComp(LError.text, ''']'' expected near end of file') <> 0 then begin
    Fail('json_load_callback returned an invalid error message for an '
           +'unclosed top-level array');
  end;

  LJson := json_load_callback(nil, nil, 0, @LError);
  if LJson <> nil then begin
    json_decref(LJson);
    Fail('json_load_callback should have failed on NULL load callback, but '
           +'it didn''t');
  end;
  if StrComp(LError.text, 'wrong arguments') <> 0 then begin
    Fail('json_load_callback returned an invalid error message for a NULL '
          +'load callback');
  end;
end;



initialization
  RegisterTest(TTestLoadCallback.Suite);

end.
