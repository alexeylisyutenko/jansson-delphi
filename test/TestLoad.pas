unit TestLoad;

interface

uses
  TestFramework;

type
  TTestLoad = class(TTestCase)
  published
    procedure TestFileNotFound;
    procedure TestVeryLongFileName;
    procedure TestRejectDuplicates;
    procedure TestDisableEofCheck;
    procedure TestDecodeAny;
    procedure TestDecodeIntAsReal;
    procedure TestAllowNul;
    procedure TestLoadWrongArgs;
    procedure TestPosition;
    procedure TestErrorCode;
  end;

implementation

uses
  Jansson, SysUtils, Util, Math;
  
{ TTTestLoad }

procedure TTestLoad.TestAllowNul;
var
  LText: PAnsiChar;
  LExpected: PAnsiChar;
  LLen: size_t;
  LJson: PJson;
begin
  LText := '"nul byte \u0000 in string"';
  LExpected := 'nul byte '#0' in string';
  LLen := 20;

  LJson := json_loads(LText, JSON_ALLOW_NUL or JSON_DECODE_ANY, nil);
  if (LJson = nil) or (not json_is_string(LJson)) then begin
    Fail('unable to decode embedded NUL byte');
  end;

  if json_string_length(LJson) <> LLen then begin
    Fail('decoder returned wrong string length');
  end;

  if not CompareMem(json_string_value(LJson), LExpected, LLen + 1) then begin
    Fail('decoder returned wrong string content');
  end;

  json_decref(LJson);
end;

procedure TTestLoad.TestDecodeAny;
var
  LJson: PJson;
  LError: TJsonError;
begin
  LJson := json_loads('"foo"', JSON_DECODE_ANY, @LError);
  if (LJson = nil) or (not json_is_string(LJson)) then begin
    Fail('json_load decoded any failed - string');
  end;
  json_decref(LJson);

  LJson := json_loads('42', JSON_DECODE_ANY, @LError);
  if (LJson = nil) or (not json_is_integer(LJson)) then begin
    Fail('json_load decoded any failed - integer');
  end;
  json_decref(LJson);

  LJson := json_loads('true', JSON_DECODE_ANY, @LError);
  if (LJson = nil) or (not json_is_true(LJson)) then begin
    Fail('json_load decoded any failed - boolean');
  end;
  json_decref(LJson);

  LJson := json_loads('null', JSON_DECODE_ANY, @LError);
  if (LJson = nil) or (not json_is_null(LJson)) then begin
    Fail('json_load decoded any failed - null');
  end;
  json_decref(LJson);
end;

procedure TTestLoad.TestDecodeIntAsReal;
var
  LJson: PJson;
  LError: TJsonError;
  LImprecise: PAnsiChar;
  LExpected: TJsonInt;
  LBig: array[0..310] of AnsiChar;
begin
  LJson := json_loads(PAnsIChar('42'), JSON_DECODE_INT_AS_REAL or JSON_DECODE_ANY, @LError);
  if (LJson = nil) or (not json_is_real(LJson)) or (CompareValue(json_real_value(LJson), 42.0, 0.0000001) <> 0) then begin
    Fail('json_load decode int as real failed - int');
  end;
  json_decref(LJson);

  (* This number cannot be represented exactly by a double *)
  LImprecise := '9007199254740993';
  LExpected := 9007199254740992;

  LJson := json_loads(LImprecise, JSON_DECODE_INT_AS_REAL or JSON_DECODE_ANY, @&LError);
  if (LJson = nil) or (not json_is_real(LJson)) or (LExpected <> Round(json_real_value(LJson))) then begin
    Fail('json_load decode int as real failed - expected imprecision');
  end;
  json_decref(LJson);

  (* 1E309 overflows. Here we create 1E309 as a decimal number, i.e.
     1000...(309 zeroes)...0. *)
  LBig[0] := '1';
  FillChar(LBig[1], 309, '0');
  LBig[310] := Chr(0);

  LJson := json_loads(@LBig[0], JSON_DECODE_INT_AS_REAL or JSON_DECODE_ANY, @LError);
  if (LJson <> nil) or (StrComp(LError.text, 'real number overflow') <> 0) or
      (json_error_code(@LError) <> json_error_numeric_overflow) then begin
    Fail('json_load decode int as real failed - expected overflow');
  end;
  json_decref(LJson);
end;

procedure TTestLoad.TestDisableEofCheck;
var
  LError: TJsonError;
  LJson: PJson;
  LText: PAnsiChar;
begin
  LText := '{"foo": 1} garbage';

  if json_loads(LText, 0, @LError) <> nil then begin
    Fail('json_loads did not detect garbage after JSON text');
  end;
  check_error(@LError, json_error_end_of_input_expected, 'end of file expected near ''garbage''',
              '<string>', 1, 18, 18);

  LJson := json_loads(LText, JSON_DISABLE_EOF_CHECK, @LError);
  if LJson = nil then begin
    Fail('json_loads failed with JSON_DISABLE_EOF_CHECK');
  end;

  json_decref(LJson);
end;

procedure TTestLoad.TestErrorCode;
var
  json: PJson;
  error: TJsonError;
begin
  json := json_loads('[123] garbage', 0, @error);
  if json <> nil then begin
    Fail('json_loads returned not NULL');
  end;
  if StrLen(error.text) >= JSON_ERROR_TEXT_LENGTH then begin
    Fail('error.text longer than expected');
  end;
  if json_error_code(@error) <> json_error_end_of_input_expected then begin
    Fail('json_loads returned incorrect error code');
  end;

  json := json_loads('{"foo": ', 0, @error);
  if json <> nil then begin
      Fail('json_loads returned not NULL');
  end;
  if StrLen(error.text) >= JSON_ERROR_TEXT_LENGTH then begin
    Fail('error.text longer than expected');
  end;
  if json_error_code(@error) <> json_error_premature_end_of_input then begin
    Fail('json_loads returned incorrect error code');
  end;
end;

procedure TTestLoad.TestFileNotFound;
var
  LJson: PJson;
  LError: TJsonError;
  LPos: PAnsiChar;
begin
  LJson := json_load_file('/path/to/nonexistent/file.json', 0, @LError);
  if LJson <> nil then begin
    Fail('json_load_file returned non-NULL for a nonexistent file');
  end;
  if LError.line <> -1 then begin
    Fail('json_load_file returned an invalid line number');
  end;

  (* The error message is locale specific, only check the beginning
     of the error message. *)

  LPos := AnsiStrRScan(LError.text, ':');
  if LPos = nil then begin
    Fail('json_load_file returne an invalid error message');
  end;

  LPos^ := Chr(0);

  if StrComp(LError.text, 'unable to open /path/to/nonexistent/file.json') <> 0 then begin
    Fail('json_load_file returned an invalid error message');
  end;
  if json_error_code(@LError) <> json_error_cannot_open_file then begin
    Fail('json_load_file returned an invalid error code');
  end;
end;

procedure TTestLoad.TestLoadWrongArgs;
var
  LJson: PJson;
  LError: TJsonError;
begin
  LJson := json_loads(nil, 0, @LError);
  if LJson <> nil then begin
    Fail('json_loads should return NULL if the first argument is NULL');
  end;

  LJson := json_loadb(nil, 0, 0, @LError);
  if LJson <> nil then begin
    Fail('json_loadb should return NULL if the first argument is NULL');
  end;

  LJson := json_loadf(nil, 0, @LError);
  if LJson <> nil then begin
    Fail('json_loadf should return NULL if the first argument is NULL');
  end;

  LJson := json_loadfd(-1, 0, @LError);
  if LJson <> nil then begin
    Fail('json_loadfd should return NULL if the first argument is < 0');
  end;

  LJson := json_load_file(nil, 0, @LError);
  if LJson <> nil then begin
    Fail('json_load_file should return NULL if the first argument is NULL');
  end;
end;

procedure TTestLoad.TestPosition;
var
  LJson: PJson;
  LFlags: size_t;
  LError: TJsonError;
begin
  LFlags := JSON_DISABLE_EOF_CHECK;

  LJson := json_loads('{"foo": "bar"}', 0, @LError);
  if LError.position <> 14 then begin
    Fail('json_loads returned a wrong position');
  end;
  json_decref(LJson);

  LJson := json_loads('{"foo": "bar"} baz quux', LFlags, @LError);
  if LError.position <> 14 then begin
    Fail('json_loads returned a wrong position');
  end;
  json_decref(LJson);
end;

procedure TTestLoad.TestRejectDuplicates;
var
  LError: TJsonError;
begin
  if json_loads('{"foo": 1, "foo": 2}', JSON_REJECT_DUPLICATES, @LError) <> nil then begin
    Fail('json_loads did not detect a duplicate key');
  end;
  check_error(@LError, json_error_duplicate_key, 'duplicate object key near ''"foo"''',
              '<string>', 1, 16, 16);
end;

procedure TTestLoad.TestVeryLongFileName;
var
  LJson: PJson;
  LError: TJsonError;
begin
  LJson := json_load_file('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
                        +'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
                        0, @LError);
  if LJson <> nil then begin
    Fail('json_load_file returned non-NULL for a nonexistent file');
  end;
  if LError.line <> -1 then begin
    Fail('json_load_file returned an invalid line number');
  end;

  if StrLComp(LError.source, '...aaa', 6) <> 0 then begin
    Fail('error source was set incorrectly');
  end;
  if json_error_code(@LError) <> json_error_cannot_open_file then begin
    Fail('error code was set incorrectly');
  end;
end;

initialization
  RegisterTest(TTestLoad.Suite);

end.
