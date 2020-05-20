unit TestPack;

interface

uses
  TestFramework;

type
  TTestPack = class(TTestCase)
  published
    procedure TestPack;
  end;

implementation

uses
  Jansson, Util, Math, SysUtils;

{ TTestPack }

procedure TTestPack.TestPack;
var
  value: PJSon;
  i: Integer;
  buffer: array[0..3] of AnsiChar;
  error: TJsonError;
  LDouble: Double;
begin
  buffer := 'test';

  (*
   * Simple, valid json_pack cases
   *)
  (* true *)
  value := json_pack('b', 1);
  if not json_is_true(value) then begin
    Fail('json_pack boolean failed');
  end;
  if value.refcount <> size_t(-1) then begin
    Fail('json_pack boolean refcount failed');
  end;
  json_decref(value);

  (* false *)
  value := json_pack('b', 0);
  if not json_is_false(value) then begin
    Fail('json_pack boolean failed');
  end;
  if value.refcount <> size_t(-1) then begin
    Fail('json_pack boolean refcount failed');
  end;
  json_decref(value);

  (* null *)
  value := json_pack('n');
  if not json_is_null(value) then begin
    Fail('json_pack null failed');
  end;
  if value.refcount <> size_t(-1) then begin
    Fail('json_pack null refcount failed');
  end;
  json_decref(value);

  (* integer *)
  value := json_pack('i', 1);
  if (not json_is_integer(value)) or (json_integer_value(value) <> 1) then begin
    Fail('json_pack integer failed');
  end;
  if value.refcount <> size_t(1) then begin
    Fail('json_pack integer refcount failed');
  end;
  json_decref(value);

  (* integer from json_int_t *)
  value := json_pack('I', TJsonInt(555555));
  if (not json_is_integer(value)) or (json_integer_value(value) <> 555555) then begin
    Fail('json_pack json_int_t failed');
  end;
  if value.refcount <> size_t(1) then begin
    Fail('json_pack integer refcount failed');
  end;
  json_decref(value);

  (* real *)
  LDouble := 1.0;
  value := json_pack('f', LDouble);
  if (not json_is_real(value)) or (CompareValue(json_real_value(value), 1.0, 0.0000001) <> 0) then begin
    Fail('json_pack real failed');
  end;
  if value.refcount <> size_t(1) then begin
    Fail('json_pack real refcount failed');
  end;
  json_decref(value);

  (* string *)
  value := json_pack('s', 'test');
  if (not json_is_string(value)) or (StrComp('test', json_string_value(value)) <> 0) then begin
    Fail('json_pack string failed');
  end;
  if value.refcount <> size_t(1) then begin
    Fail('json_pack string refcount failed');
  end;
  json_decref(value);

  (* nullable string (defined case) *)
  value := json_pack('s?', 'test');
  if (not json_is_string(value)) or (StrComp('test', json_string_value(value)) <> 0) then begin
    Fail('json_pack nullable string (defined case) failed');
  end;
  if value.refcount <> size_t(1) then begin
    Fail('json_pack nullable string (defined case) refcount failed');
  end;
  json_decref(value);

  (* nullable string (NULL case) *)
  value := json_pack('s?', nil);
  if not json_is_null(value) then begin
    Fail('json_pack nullable string (NULL case) failed');
  end;
  if value.refcount <> size_t(-1) then begin
    Fail('json_pack nullable string (NULL case) refcount failed');
  end;
  json_decref(value);

  (* nullable string concatenation *)
  if json_pack_ex(@error, 0, 's?+', 'test', 'ing') <> nil then begin
    Fail('json_pack failed to catch invalid format ''s?+''');
  end;
  check_error(@error, json_error_invalid_format, 'Cannot use ''+'' on optional strings',
              '<format>', 1, 2, 2);

  (* nullable string with integer length *)
  if json_pack_ex(@error, 0, 's?#', 'test', 4) <> nil then begin
    Fail('json_pack failed to catch invalid format ''s?#''');
  end;
  check_error(@error, json_error_invalid_format, 'Cannot use ''#'' on optional strings',
              '<format>', 1, 2, 2);

  (* string and length (int) *)
  value := json_pack('s#', 'test asdf', 4);
  if (not json_is_string(value)) or (StrComp('test', json_string_value(value)) <> 0) then begin
    Fail('json_pack string and length failed');
  end;
  if value.refcount <> size_t(1) then begin
    Fail('json_pack string and length refcount failed');
  end;
  json_decref(value);

  (* string and length (size_t) *)
  value := json_pack('s%', 'test asdf', size_t(4));
  if (not json_is_string(value)) or (StrComp('test', json_string_value(value)) <> 0) then begin
    Fail('json_pack string and length failed');
  end;
  if value.refcount <> size_t(1) then begin
    Fail('json_pack string and length refcount failed');
  end;
  json_decref(value);

  (* string and length (int), non-NUL terminated string *)
  value := json_pack('s#', @buffer, 4);
  if (not json_is_string(value)) or (StrComp('test', json_string_value(value)) <> 0) then begin
    Fail('json_pack string and length (int) failed');
  end;
  if value.refcount <> size_t(1) then begin
    Fail('json_pack string and length (int) refcount failed');
  end;
  json_decref(value);

  (* string and length (size_t), non-NUL terminated string *)
  value := json_pack('s%', @buffer, size_t(4));
  if (not json_is_string(value)) or (StrComp('test', json_string_value(value)) <> 0) then begin
    Fail('json_pack string and length (size_t) failed');
  end;
  if value.refcount <> size_t(1) then begin
    Fail('json_pack string and length (size_t) refcount failed');
  end;
  json_decref(value);

  (* string concatenation *)
  if json_pack('s+', 'test', nil) <> nil then begin
    Fail('json_pack string concatenation succeeded with NULL string');
  end;

  value := json_pack('s++', 'te', 'st', 'ing');
  if (not json_is_string(value)) or (StrComp('testing', json_string_value(value)) <> 0) then begin
    Fail('json_pack string concatenation failed');
  end;
  if value.refcount <> size_t(1) then begin
    Fail('json_pack string concatenation refcount failed');
  end;
  json_decref(value);

  (* string concatenation and length (int) *)
  value := json_pack('s#+#+', 'test', 1, 'test', 2, 'test');
  if (not json_is_string(value)) or (StrComp('ttetest', json_string_value(value)) <> 0) then begin
    Fail('json_pack string concatenation and length (int) failed');
  end;
  if value.refcount <> size_t(1) then begin
    Fail('json_pack string concatenation and length (int) refcount failed');
  end;
  json_decref(value);

  (* string concatenation and length (size_t) *)
  value := json_pack('s%+%+', 'test', size_t(1), 'test', size_t(2), 'test');
  if (not json_is_string(value)) or (StrComp('ttetest', json_string_value(value)) <> 0) then begin
    Fail('json_pack string concatenation and length (size_t) failed');
  end;
  if value.refcount <> size_t(1) then begin
    Fail('json_pack string concatenation and length (size_t) refcount '
          +'failed');
  end;
  json_decref(value);

  (* empty object *)
  value := json_pack('{}', 1.0);
  if (not json_is_object(value)) or (json_object_size(value) <> 0) then begin
    Fail('json_pack empty object failed');
  end;
  if value.refcount <> size_t(1) then begin
    Fail('json_pack empty object refcount failed');
  end;
  json_decref(value);

  (* empty list *)
  value := json_pack('[]', 1.0);
  if (not json_is_array(value)) or (json_array_size(value) <> 0) then begin
    Fail('json_pack empty list failed');
  end;
  if value.refcount <> size_t(1) then begin
    Fail('json_pack empty list failed');
  end;
  json_decref(value);

  (* non-incref'd object *)
  value := json_pack('o', json_integer(1));
  if (not json_is_integer(value)) or (json_integer_value(value) <> 1) then begin
    Fail('json_pack object failed');
  end;
  if value.refcount <> size_t(1) then begin
    Fail('json_pack integer refcount failed');
  end;
  json_decref(value);

  (* non-incref'd nullable object (defined case) *)
  value := json_pack('o?', json_integer(1));
  if (not json_is_integer(value)) or (json_integer_value(value) <> 1) then begin
    Fail('json_pack nullable object (defined case) failed');
  end;
  if value.refcount <> size_t(1) then begin
    Fail('json_pack nullable object (defined case) refcount failed');
  end;
  json_decref(value);

  (* non-incref'd nullable object (NULL case) *)
  value := json_pack('o?', nil);
  if not json_is_null(value) then begin
    Fail('json_pack nullable object (NULL case) failed');
  end;
  if value.refcount <> size_t(-1) then begin
    Fail('json_pack nullable object (NULL case) refcount failed');
  end;
  json_decref(value);

  (* incref'd object *)
  value := json_pack('O', json_integer(1));
  if (not json_is_integer(value)) or (json_integer_value(value) <> 1) then begin
    Fail('json_pack object failed');
  end;
  if value.refcount <> size_t(2) then begin
    Fail('json_pack integer refcount failed');
  end;
  json_decref(value);
  json_decref(value);

  (* incref'd nullable object (defined case) *)
  value := json_pack('O?', json_integer(1));
  if (not json_is_integer(value)) or (json_integer_value(value) <> 1) then begin
    Fail('json_pack incref''d nullable object (defined case) failed');
  end;
  if value.refcount <> size_t(2) then begin
    Fail('json_pack incref''d nullable object (defined case) refcount '
          +'failed');
  end;
  json_decref(value);
  json_decref(value);

  (* incref'd nullable object (NULL case) *)
  value := json_pack('O?', nil);
  if not json_is_null(value) then begin
    Fail('json_pack incref''d nullable object (NULL case) failed');
  end;
  if value.refcount <> size_t(-1) then begin
    Fail('json_pack incref''d nullable object (NULL case) refcount failed');
  end;

  (* simple object *)
  value := json_pack('{s:[]}', 'foo');
  if (not json_is_object(value)) or (json_object_size(value) <> 1) then begin
    Fail('json_pack array failed');
  end;
  if not json_is_array(json_object_get(value, 'foo')) then begin
  Fail('json_pack array failed');
  end;
  if json_object_get(value, 'foo').refcount <> size_t(1) then begin
    Fail('json_pack object refcount failed');
  end;
  json_decref(value);

  (* object with complex key *)
  value := json_pack('{s+#+: []}', 'foo', 'barbar', 3, 'baz');
  if (not json_is_object(value)) or (json_object_size(value) <> 1) then begin
    Fail('json_pack array failed');
  end;
  if not json_is_array(json_object_get(value, 'foobarbaz')) then begin
    Fail('json_pack array failed');
  end;
  if json_object_get(value, 'foobarbaz').refcount <> size_t(1) then begin
    Fail('json_pack object refcount failed');
  end;
  json_decref(value);

  (* object with optional members *)
  value := json_pack('{s:s,s:o,s:O}', AnsiString('a'), nil, AnsiString('b'), nil, AnsiString('c'), nil);
  if value <> nil then begin
    Fail('json_pack object optional incorrectly succeeded');
  end;

  value := json_pack('{s:**}', AnsiString('a'), nil);
  if value <> nil then begin
    Fail('json_pack object optional invalid incorrectly succeeded');
  end;

  if json_pack_ex(@error, 0, '{s:i*}', AnsiString('a'), 1) <> nil then begin
    Fail('json_pack object optional invalid incorrectly succeeded');
  end;
  check_error(@error, json_error_invalid_format, 'Expected format ''s'', got ''*''', '<format>', 1,
              5, 5);

  value := json_pack('{s:s*,s:o*,s:O*}', AnsiString('a'), nil, AnsiString('b'), nil, AnsiString('c'), nil);
  if (not json_is_object(value)) or (json_object_size(value) <> 0) then begin
    Fail('json_pack object optional failed');
  end;
  json_decref(value);

  value := json_pack('{s:s*}', 'key', '' + Chr($FF) + Chr($FF));
  if value <> nil then begin
    Fail('json_pack object optional with invalid UTF-8 incorrectly '
          +'succeeded');
  end;

  if json_pack_ex(@error, 0, '{s: s*#}', 'key', 'test', 1) <> nil then begin
    Fail('json_pack failed to catch invalid format ''s*#''');
  end;
  check_error(@error, json_error_invalid_format, 'Cannot use ''#'' on optional strings',
              '<format>', 1, 6, 6);

  if json_pack_ex(@error, 0, '{s: s*+}', 'key', 'test', 'ing') <> nil then begin
    Fail('json_pack failed to catch invalid format ''s*+''');
  end;
  check_error(@error, json_error_invalid_format, 'Cannot use ''+'' on optional strings',
              '<format>', 1, 6, 6);

  (* simple array *)
  value := json_pack('[i,i,i]', 0, 1, 2);
  if (not json_is_array(value)) or (json_array_size(value) <> 3) then begin
    Fail('json_pack object failed');
  end;
  for i := 0 to 2 do begin
      if (not json_is_integer(json_array_get(value, i))) or
          (json_integer_value(json_array_get(value, i)) <> i) then begin
             Fail('json_pack integer array failed');
          end;
  end;
  json_decref(value);

  (* simple array with optional members *)
  value := json_pack('[s,o,O]', nil, nil, nil);
  if value <> nil then begin
    Fail('json_pack array optional incorrectly succeeded');
  end;

  if json_pack_ex(@error, 0, '[i*]', 1) <> nil then begin
    Fail('json_pack array optional invalid incorrectly succeeded');
  end;
  check_error(@error, json_error_invalid_format, 'Unexpected format character ''*''', '<format>',
              1, 3, 3);

  value := json_pack('[**]', nil);
  if value <> nil then begin
    Fail('json_pack array optional invalid incorrectly succeeded');
  end;
  value := json_pack('[s*,o*,O*]', nil, nil, nil);
  if (not json_is_array(value)) or (json_array_size(value) <> 0) then begin
    Fail('json_pack array optional failed');
  end;
  json_decref(value);

  (* Whitespace; regular string *)
  value := json_pack(' s'#9' ', 'test');
  if (not json_is_string(value)) or (StrComp('test', json_string_value(value)) <> 0) then begin
    Fail('json_pack string (with whitespace) failed');
  end;
  json_decref(value);

  (* Whitespace; empty array *)
  value := json_pack('[ ]');
  if (not json_is_array(value)) or (json_array_size(value) <> 0) then begin
    Fail('json_pack empty array (with whitespace) failed');
  end;
  json_decref(value);

  (* Whitespace; array *)
  value := json_pack('[ i , i,  i ] ', 1, 2, 3);
  if (not json_is_array(value)) or (json_array_size(value) <> 3) then begin
    Fail('json_pack array (with whitespace) failed');
  end;
  json_decref(value);

  (*
   * Invalid cases
   *)

  (* newline in format string *)
  if json_pack_ex(@error, 0, '{'#10''#10'1') <> nil then begin
    Fail('json_pack failed to catch invalid format ''1''');
  end;
  check_error(@error, json_error_invalid_format, 'Expected format ''s'', got ''1''', '<format>', 3,
              1, 4);

  (* mismatched open/close array/object *)
  if json_pack_ex(@error, 0, '[}') <> nil then begin
    Fail('json_pack failed to catch mismatched ''}''');
  end;
  check_error(@error, json_error_invalid_format, 'Unexpected format character ''}''', '<format>',
              1, 2, 2);

  if json_pack_ex(@error, 0, '{]') <> nil then begin
    Fail('json_pack failed to catch mismatched '']''');
  end;
  check_error(@error, json_error_invalid_format, 'Expected format ''s'', got '']''', '<format>', 1,
              2, 2);

  (* missing close array *)
  if json_pack_ex(@error, 0, '[') <> nil then begin
    Fail('json_pack failed to catch missing '']''');
  end;
  check_error(@error, json_error_invalid_format, 'Unexpected end of format string', '<format>',
              1, 2, 2);

  (* missing close object *)
  if json_pack_ex(@error, 0, '{') <> nil then begin
    Fail('json_pack failed to catch missing ''}''');
  end;
  check_error(@error, json_error_invalid_format, 'Unexpected end of format string', '<format>',
              1, 2, 2);

  (* garbage after format string *)
  if json_pack_ex(@error, 0, '[i]a', 42) <> nil then begin
    Fail('json_pack failed to catch garbage after format string');
  end;
  check_error(@error, json_error_invalid_format, 'Garbage after format string', '<format>', 1,
              4, 4);

  if json_pack_ex(@error, 0, 'ia', 42) <> nil then begin
    Fail('json_pack failed to catch garbage after format string');
  end;
  check_error(@error, json_error_invalid_format, 'Garbage after format string', '<format>', 1,
              2, 2);

  (* NULL string *)
  if json_pack_ex(@error, 0, 's', nil) <> nil then begin
    Fail('json_pack failed to catch null argument string');
  end;
  check_error(@error, json_error_null_value, 'NULL string', '<args>', 1, 1, 1);

  (* + on its own *)
  if json_pack_ex(@error, 0, '+', nil) <> nil then begin
    Fail('json_pack failed to a lone +');
  end;
  check_error(@error, json_error_invalid_format, 'Unexpected format character ''+''', '<format>',
              1, 1, 1);

  (* Empty format *)
  if json_pack_ex(@error, 0, '') <> nil then begin
    Fail('json_pack failed to catch empty format string');
  end;
  check_error(@error, json_error_invalid_argument, 'NULL or empty format string', '<format>',
              -1, -1, 0);

  (* NULL format *)
  if json_pack_ex(@error, 0, nil) <> nil then begin
    Fail('json_pack failed to catch NULL format string');
  end;
  check_error(@error, json_error_invalid_argument, 'NULL or empty format string', '<format>',
              -1, -1, 0);

  (* NULL key *)
  if json_pack_ex(@error, 0, '{s:i}', nil, 1) <> nil then begin
    Fail('json_pack failed to catch NULL key');
  end;
  check_error(@error, json_error_null_value, 'NULL object key', '<args>', 1, 2, 2);

  (* NULL value followed by object still steals the object's ref *)
  value := json_incref(json_object());
  if json_pack_ex(@error, 0, '{s:s,s:o}', 'badnull', nil, 'dontleak', value) <> nil then begin
    Fail('json_pack failed to catch NULL value');
  end;
  check_error(@error, json_error_null_value, 'NULL string', '<args>', 1, 4, 4);
  if value.refcount <> size_t(1) then begin
    Fail('json_pack failed to steal reference after error.');
  end;
  json_decref(value);

  (* More complicated checks for row/columns *)
  if json_pack_ex(@error, 0, '{ {}: s }', 'foo') <> nil then begin
    Fail('json_pack failed to catch object as key');
  end;
  check_error(@error, json_error_invalid_format, 'Expected format ''s'', got ''{''', '<format>', 1,
              3, 3);

  (* Complex object *)
  if json_pack_ex(@error, 0, '{ s: {},  s:[ii{} }', 'foo', 'bar', 12, 13) <> nil then begin
    Fail('json_pack failed to catch missing ]');
  end;
  check_error(@error, json_error_invalid_format, 'Unexpected format character ''}''', '<format>',
              1, 19, 19);

  (* Complex array *)
  if json_pack_ex(@error, 0, '[[[[[   [[[[[  [[[[ }]]]] ]]]] ]]]]]') <> nil then begin
    Fail('json_pack failed to catch extra }');
  end;
  check_error(@error, json_error_invalid_format, 'Unexpected format character ''}''', '<format>',
              1, 21, 21);

  (* Invalid UTF-8 in object key *)
  if json_pack_ex(@error, 0, '{s:i}', Chr($FF) + Chr($FF), 42) <> nil then begin
    Fail('json_pack failed to catch invalid UTF-8 in an object key');
  end;
  check_error(@error, json_error_invalid_utf8, 'Invalid UTF-8 object key', '<args>', 1, 2, 2);

  (* Invalid UTF-8 in a string *)
  if json_pack_ex(@error, 0, '{s:s}', 'foo', Chr($FF) + Chr($FF)) <> nil then begin
    Fail('json_pack failed to catch invalid UTF-8 in a string');
  end;
  check_error(@error, json_error_invalid_utf8, 'Invalid UTF-8 string', '<args>', 1, 4, 4);

  (* Invalid UTF-8 in an optional '?' string *)
  if json_pack_ex(@error, 0, '{s:s?}', 'foo', Chr($FF) + Chr($FF)) <> nil then begin
    Fail('json_pack failed to catch invalid UTF-8 in an optional ''?'' '
           +'string');
  end;
  check_error(@error, json_error_invalid_utf8, 'Invalid UTF-8 string', '<args>', 1, 5, 5);

  (* Invalid UTF-8 in an optional '*' string *)
  if json_pack_ex(@error, 0, '{s:s*}', 'foo', Chr($FF) + Chr($FF)) <> nil then begin
    Fail('json_pack failed to catch invalid UTF-8 in an optional ''*'' '
          +'string');
  end;
  check_error(@error, json_error_invalid_utf8, 'Invalid UTF-8 string', '<args>', 1, 5, 5);

  (* Invalid UTF-8 in a concatenated key *)
  if json_pack_ex(@error, 0, '{s+:i}', Chr($FF) + Chr($FF), 'concat', 42) <> nil then begin
    Fail('json_pack failed to catch invalid UTF-8 in an object key');
  end;
  check_error(@error, json_error_invalid_utf8, 'Invalid UTF-8 object key', '<args>', 1, 3, 3);

  if json_pack_ex(@error, 0, '{s:o}', 'foo', nil) <> nil then begin
    Fail('json_pack failed to catch nullable object');
  end;
  check_error(@error, json_error_null_value, 'NULL object', '<args>', 1, 4, 4);

  if json_pack_ex(@error, 0, '{s:O}', 'foo', nil) <> nil then begin
    Fail('json_pack failed to catch nullable incref object');
  end;
  check_error(@error, json_error_null_value, 'NULL object', '<args>', 1, 4, 4);

  if json_pack_ex(@error, 0, '{s+:o}', 'foo', 'bar', nil) <> nil then begin
    Fail('json_pack failed to catch non-nullable object value');
  end;
  check_error(@error, json_error_null_value, 'NULL object', '<args>', 1, 5, 5);

  if json_pack_ex(@error, 0, '[1s', 'Hi') <> nil then begin
    Fail('json_pack failed to catch invalid format');
  end;
  check_error(@error, json_error_invalid_format, 'Unexpected format character ''1''', '<format>',
              1, 2, 2);

  if json_pack_ex(@error, 0, '[1s+', 'Hi', 'ya') <> nil then begin
    Fail('json_pack failed to catch invalid format');
  end;
  check_error(@error, json_error_invalid_format, 'Unexpected format character ''1''', '<format>',
              1, 2, 2);

  if json_pack_ex(@error, 0, '[so]', nil, json_object()) <> nil then begin
    Fail('json_pack failed to catch NULL value');
  end;
  check_error(@error, json_error_null_value, 'NULL string', '<args>', 1, 2, 2);
end;

initialization
  RegisterTest(TTestPack.Suite);

end.
