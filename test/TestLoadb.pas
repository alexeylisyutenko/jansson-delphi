unit TestLoadb;

interface

uses
  TestFramework;

type
  TTestLoadb = class(TTestCase)
  published
    procedure TestLoadb;
  end;

implementation

uses
  Jansson, SysUtils;

{ TTestLoadb }

procedure TTestLoadb.TestLoadb;
var
  LJson: PJson;
  LError: TJsonError;
  LStr: PAnsiChar;
  LLen: size_t;
begin
  LStr := '["A", {"B": "C"}, 1, 2, 3]garbage';
  LLen := StrLen(LStr) - StrLen('garbage');

  LJson := json_loadb(LStr, LLen, 0, @LError);
  if LJson = nil then begin
    Fail('json_loadb failed on a valid JSON buffer');
  end;
  json_decref(LJson);

  LJson := json_loadb(LStr, LLen - 1, 0, @LError);
  if LJson <> nil then begin
      json_decref(LJson);
      Fail('json_loadb should have failed on an incomplete buffer, but it '
           +'didn''t');
  end;
  if LError.line <> 1 then begin
    Fail('json_loadb returned an invalid line number on fail');
  end;
  if StrComp(LError.text, ''']'' expected near end of file') <> 0 then begin
      Fail('json_loadb returned an invalid error message for an unclosed '
           +'top-level array');
  end;
end;

initialization
  RegisterTest(TTestLoadb.Suite);

end.
