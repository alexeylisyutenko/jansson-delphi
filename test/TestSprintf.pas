unit TestSprintf;

interface

uses
  TestFramework;

type
  TTestSprintf = class(TTestCase)
  published
    procedure TestSprintf;
  end;

implementation

uses
  Jansson, SysUtils;

{ TTestSprintf }

procedure TTestSprintf.TestSprintf;
var
  LStr: PJson;
begin
  LStr := json_sprintf('foo bar %d', 42);
  if LStr = nil then begin
    Fail('json_sprintf returned NULL');
  end;
  if not json_is_string(LStr) then begin
    Fail('json_sprintf didn''t return a JSON string');
  end;
  if StrComp(json_string_value(LStr), 'foo bar 42') <> 0 then begin
    Fail('json_sprintf generated an unexpected string');
  end;

  json_decref(LStr);

  LStr := json_sprintf('%s', PAnsiChar(''));
  if LStr = nil then begin
    Fail('json_sprintf returned NULL');
  end;
  if not json_is_string(LStr) then begin
    Fail('json_sprintf didn''t return a JSON string');
  end;
  if json_string_length(LStr) <> 0 then begin
    Fail('string is not empty');
  end;
  json_decref(LStr);

  if json_sprintf('%s', Chr($FF) + Chr($FF)) <> nil then begin
    Fail('json_sprintf unexpected success with invalid UTF');
  end;
end;

initialization
  RegisterTest(TTestSprintf.Suite);

end.
