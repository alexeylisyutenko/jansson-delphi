unit TestDump;

interface

uses
  TestFramework, Jansson;

type
  TTestDump = class(TTestCase)
  published
    procedure TestEncodeNull;
    procedure TestEncodeTwice;
    procedure TestCircularReferences;
    procedure TestEncodeOtherThanArrayOrObject;
    procedure TestEscapeSlashes;
    procedure TestEncodeNulByte;
    procedure TestDumpFile;
    procedure TestDumpb;
    procedure TestEmbed;
  end;

function encode_null_callback(buffer: PAnsiChar; size: size_t; data: Pointer): Integer; cdecl;

implementation

uses
  SysUtils, Windows;

function encode_null_callback(buffer: PAnsiChar; size: size_t; data: Pointer): Integer; cdecl;
begin
  Result := 0;
end;

{ TTestDump }

procedure TTestDump.TestCircularReferences;
var
  LJson: PJson;
  LResult: PAnsiChar;
begin
  (* Construct a JSON object/array with a circular reference:
     object: {"a": {"b": {"c": <circular reference to $.a>}}}
     array: [[[<circular reference to the $[0] array>]]]
     Encode it, remove the circular reference and encode again.
  *)

  LJson := json_object();
  json_object_set_new(LJson, 'a', json_object());
  json_object_set_new(json_object_get(LJson, 'a'), 'b', json_object());
  json_object_set(json_object_get(json_object_get(LJson, 'a'), 'b'), 'c',
                  json_object_get(LJson, 'a'));

  if json_dumps(LJson, 0) <> nil then begin
    Fail('json_dumps encoded a circular reference!');
  end;

  json_object_del(json_object_get(json_object_get(LJson, 'a'), 'b'), 'c');

  LResult := json_dumps(LJson, 0);
  if (LResult = nil) or (StrComp(LResult, '{"a": {"b": {}}}') <> 0) then begin
    Fail('json_dumps failed!');
  end;
  delphi_json_free(LResult);

  json_decref(LJson);

  LJson := json_array();
  json_array_append_new(LJson, json_array());
  json_array_append_new(json_array_get(LJson, 0), json_array());
  json_array_append(json_array_get(json_array_get(LJson, 0), 0),
                    json_array_get(LJson, 0));

  if json_dumps(LJson, 0) <> nil then begin
    Fail('json_dumps encoded a circular reference!');
  end;

  json_array_remove(json_array_get(json_array_get(LJson, 0), 0), 0);

  LResult := json_dumps(LJson, 0);
  if (LResult = nil) or (StrComp(LResult, '[[[]]]') <> 0) then begin
    Fail('json_dumps failed!');
  end;
  delphi_json_free(LResult);

  json_decref(LJson);
end;

procedure TTestDump.TestDumpb;
var
  LBuf: array[0..1] of AnsiChar;
  LObj: PJson;
  LSize: size_t;
begin
  LObj := json_object();

  LSize := json_dumpb(LObj, LBuf, SizeOf(LBuf), 0);
  if (LSize <> 2) or (StrLComp(LBuf, '{}', 2) <> 0) then begin
    Fail('json_dumpb failed');
  end;

  json_decref(LObj);
  LObj := json_pack('{s:s}', 'foo', 'bar');

  LSize := json_dumpb(LObj, LBuf, SizeOf(LBuf), JSON_COMPACT);
  if LSize <> 13 then begin
    Fail('json_dumpb size check failed');
  end;

  json_decref(LObj);
end;

procedure TTestDump.TestDumpFile;
var
  LJson: PJson;
  LResult: Integer;
begin
  LResult := json_dump_file(nil, '', 0);
  if LResult <> -1 then begin
    Fail('json_dump_file succeeded with invalid args');
  end;

  LJson := json_object();
  LResult := json_dump_file(LJson, 'json_dump_file.json', 0);
  if LResult <> 0 then begin
    Fail('json_dump_file failed');
  end;

  json_decref(LJson);
  DeleteFile('json_dump_file.json');
end;

procedure TTestDump.TestEmbed;
const
  plains: array[0..3] of PAnsiChar = ('{"bar":[],"foo":{}}', '[[],{}]', '{}', '[]');
var
  I: Integer;
  plain: PAnsiChar;
  parse: PJson;
  embed: PAnsiChar;
  psize: size_t;
  esize: size_t;
begin
  for I := 0 to Length(plains) - 1 do begin
    plain := plains[i];
    parse:= nil;
    embed := nil;
    psize := 0;
    esize := 0;

    psize := Strlen(plain) - 2;
    embed := AllocMem(psize);
    parse := json_loads(plain, 0, nil);
    esize := 
        json_dumpb(parse, embed, psize, JSON_COMPACT or JSON_SORT_KEYS or JSON_EMBED);
    json_decref(parse);
    if esize <> psize then begin
      Fail('json_dumpb(JSON_EMBED) returned an invalid size');
    end;
    if StrLComp(plain + 1, embed, esize) <> 0 then begin
      Fail('json_dumps(JSON_EMBED) returned an invalid value');
    end;
    FreeMem(embed);
  end;
end;

procedure TTestDump.TestEncodeNulByte;
var
  LJson: PJson;
  LResult: PAnsiChar;
begin
  LJson := json_stringn('nul byte '#0' in string', 20);
  LResult := json_dumps(LJson, JSON_ENCODE_ANY);
  if (LResult = nil) or (not CompareMem(LResult, PAnsiChar('"nul byte \u0000 in string"'), 27)) then begin
    Fail('json_dumps failed to dump an embedded NUL byte');
  end;

  delphi_json_free(LResult);
  json_decref(LJson);
end;

procedure TTestDump.TestEncodeNull;
begin
  if json_dumps(nil, JSON_ENCODE_ANY) <> nil then begin
    Fail('json_dumps didn''t fail for NULL');
  end;

  if json_dumpb(nil, nil, 0, JSON_ENCODE_ANY) <> 0 then begin
    Fail('json_dumpb didn''t fail for NULL');
  end;

  if json_dumpf(nil, 0, JSON_ENCODE_ANY) <> -1 then begin
    Fail('json_dumpf didn''t fail for NULL');
  end;

  (* Don't test json_dump_file to avoid creating a file *)

  if json_dump_callback(nil, @encode_null_callback, nil, JSON_ENCODE_ANY) <> -1 then begin
    Fail('json_dump_callback didn''t fail for NULL');
  end;
end;

procedure TTestDump.TestEncodeOtherThanArrayOrObject;
var
  LJson: PJson;
  LResult: PAnsiChar;
begin
  (* Encoding anything other than array or object should only
   * succeed if the JSON_ENCODE_ANY flag is used *)

  LJson := json_string('foo');
  if json_dumps(LJson, 0) <> nil then begin
    Fail('json_dumps encoded a string!');
  end;
  if json_dumpf(LJson, nil, 0) = 0 then begin
    Fail('json_dumpf encoded a string!');
  end;
  if json_dumpfd(LJson, -1, 0) = 0 then begin
    Fail('json_dumpfd encoded a string!');
  end;

  LResult := json_dumps(LJson, JSON_ENCODE_ANY);
  if (LResult = nil) or (StrComp(LResult, '"foo"') <> 0) then begin
    Fail('json_dumps failed to encode a string with JSON_ENCODE_ANY');
  end;

  delphi_json_free(LResult);
  json_decref(LJson);

  LJson := json_integer(42);
  if json_dumps(LJson, 0) <> nil then begin
    Fail('json_dumps encoded an integer!');
  end;
  if json_dumpf(LJson, nil, 0) = 0 then begin
    Fail('json_dumpf encoded an integer!');
  end;
  if json_dumpfd(LJson, -1, 0) = 0 then begin
    Fail('json_dumpfd encoded an integer!');
  end;

  LResult := json_dumps(LJson, JSON_ENCODE_ANY);
  if (LResult = nil) or (StrComp(LResult, '42') <> 0) then begin
    Fail('json_dumps failed to encode an integer with JSON_ENCODE_ANY');
  end;

  delphi_json_free(LResult);
  json_decref(LJson);
end;

procedure TTestDump.TestEncodeTwice;
var
  LJson: PJson;
  LResult: PAnsiChar;
begin
 (* Encode an empty object/array, add an item, encode again *)

  LJson := json_object();
  LResult := json_dumps(LJson, 0);
  if (LResult = nil) or (StrComp(LResult, '{}') <> 0) then begin
    Fail('json_dumps failed');
  end;
  delphi_json_free(LResult);

  json_object_set_new(LJson, 'foo', json_integer(5));
  LResult := json_dumps(LJson, 0);
  if (LResult = nil) or (StrComp(LResult, '{"foo": 5}') <> 0) then begin
    Fail('json_dumps failed');
  end;
  delphi_json_free(LResult);

  json_decref(LJson);

  LJson := json_array();
  LResult := json_dumps(LJson, 0);
  if (LResult = nil) or (StrComp(LResult, '[]') <> 0) then begin
    Fail('json_dumps failed');
  end;
  delphi_json_free(LResult);

  json_array_append_new(LJson, json_integer(5));
  LResult := json_dumps(LJson, 0);
  if (LResult = nil) or (StrComp(LResult, '[5]') <> 0) then begin
    Fail('json_dumps failed');
  end;
  delphi_json_free(LResult);

  json_decref(LJson);
end;

procedure TTestDump.TestEscapeSlashes;
var
  LJson: PJson;
  LResult: PAnsiChar;
begin
  (* Test dump escaping slashes *)

  LJson := json_object();
  json_object_set_new(LJson, 'url', json_string('https://github.com/akheron/jansson'));

  LResult := json_dumps(LJson, 0);
  if (LResult = nil) or (StrComp(LResult, '{"url": "https://github.com/akheron/jansson"}') <> 0) then begin
    Fail('json_dumps failed to not escape slashes');
  end;

  delphi_json_free(LResult);

  LResult := json_dumps(LJson, JSON_ESCAPE_SLASH);
  if (LResult = nil) or
      (StrComp(LResult, '{"url": "https:\/\/github.com\/akheron\/jansson"}') <> 0) then begin
    Fail('json_dumps failed to escape slashes');
  end;

  delphi_json_free(LResult);
  json_decref(LJson);
end;

initialization
  RegisterTest(TTestDump.Suite);

end.
