unit TestUnpack;

interface

uses
  TestFramework;

type
  TTestUnpack = class(TTestCase)
  published
    procedure TestUnpack;
  end;

implementation

uses
  Jansson, Math, SysUtils, Util;

{ TTestUnpack }

procedure TTestUnpack.TestUnpack;
var
  j: PJson;
  j2: PJson;
  i1: Integer;
  i2: Integer;
  i3: Integer;
  BI1: TJsonInt;
  rv: Integer;
  z: size_t;
  f: Double;
  s: PAnsiChar;
  error: TJsonError;
begin
  (*
   * Simple, valid json_pack cases
   *)

  (* true *)
  rv := json_unpack(json_true(), 'b', @i1);
  if (rv <> 0) or (i1 = 0) then begin
    Fail('json_unpack boolean failed');
  end;

  (* false *)
  rv := json_unpack(json_false(), 'b', @i1);
  if (rv <> 0) or (i1 <> 0) then begin
    Fail('json_unpack boolean failed');
  end;

  (* null *)
  if json_unpack(json_null(), 'n') <> 0 then begin
    Fail('json_unpack null failed');
  end;

  (* integer *)
  j := json_integer(42);
  rv := json_unpack(j, 'i', @i1);
  if (rv <> 0) or (i1 <> 42) then begin
    Fail('json_unpack integer failed');
  end;
  json_decref(j);

  (* json_int_t *)
  j := json_integer(5555555);
  rv := json_unpack(j, 'I', @BI1);
  if (rv <> 0) or (BI1 <> 5555555) then begin
    Fail('json_unpack json_int_t failed');
  end;
  json_decref(j);

  (* real *)
  j := json_real(1.7);
  rv := json_unpack(j, 'f', @f);
  if (rv <> 0) or (CompareValue(f, 1.7, 0.0000001) <> 0) then begin
    Fail('json_unpack real failed');
  end;
  json_decref(j);

  (* number *)
  j := json_integer(12345);
  rv := json_unpack(j, 'F', @f);
  if (rv <> 0) or (f <> 12345.0) then begin
    Fail('json_unpack (real or) integer failed');
  end;
  json_decref(j);

  j := json_real(1.7);
  rv := json_unpack(j, 'F', @f);
  if (rv <> 0) or (CompareValue(f, 1.7, 0.0000001) <> 0) then begin
      Fail('json_unpack real (or integer) failed');
  end;
  json_decref(j);

  (* string *)
  j := json_string('foo');
  rv := json_unpack(j, 's', @s);
  if (rv <> 0) or (StrComp(s, 'foo') <> 0) then begin
    Fail('json_unpack string failed');
  end;
  json_decref(j);

  (* string with length (size_t) *)
  j := json_string('foo');
  rv := json_unpack(j, 's%', @s, @z);
  if (rv <> 0) or (StrComp(s, 'foo') <> 0) or (z <> 3) then begin
    Fail('json_unpack string with length (size_t) failed');
  end;
  json_decref(j);

  (* empty object *)
  j := json_object();
  if json_unpack(j, '{}') <> 0 then begin
    Fail('json_unpack empty object failed');
  end;
  json_decref(j);

  (* empty list *)
  j := json_array();
  if json_unpack(j, '[]') <> 0 then begin
    Fail('json_unpack empty list failed');
  end;
  json_decref(j);

  (* non-incref'd object *)
  j := json_object();
  rv := json_unpack(j, 'o', @j2);
  if (rv <> 0) or (j2 <> j) or (j.refcount <> 1) then begin
    Fail('json_unpack object failed');
  end;
  json_decref(j);

  (* incref'd object *)
  j := json_object();
  rv := json_unpack(j, 'O', @j2);
  if (rv <> 0) or (j2 <> j) or (j.refcount <> 2) then begin
    Fail('json_unpack object failed');
  end;
  json_decref(j);
  json_decref(j);

  (* simple object *)
  j := json_pack('{s:i}', 'foo', 42);
  rv := json_unpack(j, '{s:i}', 'foo', @i1);
  if (rv <> 0) or (i1 <> 42) then begin
    Fail('json_unpack simple object failed');
  end;
  json_decref(j);

  (* simple array *)
  j := json_pack('[iii]', 1, 2, 3);
  rv := json_unpack(j, '[i,i,i]', @i1, @i2, @i3);
  if (rv <> 0) or (i1 <> 1) or (i2 <> 2) or (i3 <> 3) then begin
    Fail('json_unpack simple array failed');
  end;
  json_decref(j);

  (* object with many items & strict checking *)
  j := json_pack('{s:i, s:i, s:i}', AnsiString('a'), 1, AnsiString('b'), 2, AnsiString('c'), 3);
  rv := json_unpack(j, '{s:i, s:i, s:i}', AnsiString('a'), @i1, AnsiString('b'), @i2, AnsiString('c'), @i3);
  if (rv <> 0) or (i1 <> 1) or (i2 <> 2) or (i3 <> 3) then begin
    Fail('json_unpack object with many items failed');
  end;
  json_decref(j);

  (*
   * Invalid cases
   *)

  j := json_integer(42);
  if json_unpack_ex(j, @error, 0, AnsiString('z')) = 0 then begin
    Fail('json_unpack succeeded with invalid format character');
  end;
  check_error(@error, json_error_invalid_format, 'Unexpected format character ''z''', '<format>',
              1, 1, 1);

  if json_unpack_ex(nil, @error, 0, '[i]') = 0 then begin
    Fail('json_unpack succeeded with NULL root');
  end;
  check_error(@error, json_error_null_value, 'NULL root value', '<root>', -1, -1, 0);
  json_decref(j);

  (* mismatched open/close array/object *)
  j := json_pack('[]');
  if json_unpack_ex(j, @error, 0, '[}') = 0 then begin
    Fail('json_unpack failed to catch mismatched '']''');
  end;
  check_error(@error, json_error_invalid_format, 'Unexpected format character ''}''', '<format>',
              1, 2, 2);
  json_decref(j);

  j := json_pack('{}');
  if json_unpack_ex(j, @error, 0, '{]') = 0 then begin
    Fail('json_unpack failed to catch mismatched ''}''');
  end;
  check_error(@error, json_error_invalid_format, 'Expected format ''s'', got '']''', '<format>', 1,
              2, 2);
  json_decref(j);

  (* missing close array *)
  j := json_pack('[]');
  if json_unpack_ex(j, @error, 0, '[') = 0 then begin
    Fail('json_unpack failed to catch missing '']''');
  end;
  check_error(@error, json_error_invalid_format, 'Unexpected end of format string', '<format>',
              1, 2, 2);
  json_decref(j);

  (* missing close object *)
  j := json_pack('{}');
  if json_unpack_ex(j, @error, 0, '{') = 0 then begin
    Fail('json_unpack failed to catch missing ''}''');
  end;
  check_error(@error, json_error_invalid_format, 'Unexpected end of format string', '<format>',
              1, 2, 2);
  json_decref(j);

  (* garbage after format string *)
  j := json_pack('[i]', 42);
  if json_unpack_ex(j, @error, 0, '[i]a', @i1) = 0 then begin
    Fail('json_unpack failed to catch garbage after format string');
  end;
  check_error(@error, json_error_invalid_format, 'Garbage after format string', '<format>', 1,
              4, 4);
  json_decref(j);

  j := json_integer(12345);
  if json_unpack_ex(j, @error, 0, 'ia', @i1) = 0 then begin
    Fail('json_unpack failed to catch garbage after format string');
  end;
  check_error(@error, json_error_invalid_format, 'Garbage after format string', '<format>', 1,
              2, 2);
  json_decref(j);

  (* NULL format string *)
  j := json_pack('[]');
  if json_unpack_ex(j, @error, 0, nil) = 0 then begin
    Fail('json_unpack failed to catch null format string');
  end;
  check_error(@error, json_error_invalid_argument, 'NULL or empty format string', '<format>',
              -1, -1, 0);
  json_decref(j);

  (* NULL string pointer *)
  j := json_string('foobie');
  if json_unpack_ex(j, @error, 0, 's', nil) = 0 then begin
    Fail('json_unpack failed to catch null string pointer');
  end;
  check_error(@error, json_error_null_value, 'NULL string argument', '<args>', 1, 1, 1);
  json_decref(j);

  (* invalid types *)
  j := json_integer(42);
  j2 := json_string('foo');
  if json_unpack_ex(j, @error, 0, 's') = 0 then begin
    Fail('json_unpack failed to catch invalid type');
  end;
  check_error(@error, json_error_wrong_type, 'Expected string, got integer', '<validation>', 1,
              1, 1);

  if json_unpack_ex(j, @error, 0, 'n') = 0 then begin
    Fail('json_unpack failed to catch invalid type');
  end;
  check_error(@error, json_error_wrong_type, 'Expected null, got integer', '<validation>', 1, 1,
              1);

  if json_unpack_ex(j, @error, 0, 'b') = 0 then begin
      Fail('json_unpack failed to catch invalid type');
  end;
  check_error(@error, json_error_wrong_type, 'Expected true or false, got integer',
              '<validation>', 1, 1, 1);

  if json_unpack_ex(j2, @error, 0, 'i') = 0 then begin
    Fail('json_unpack failed to catch invalid type');
  end;
  check_error(@error, json_error_wrong_type, 'Expected integer, got string', '<validation>', 1,
              1, 1);

  if json_unpack_ex(j2, @error, 0, 'I') = 0 then begin
    Fail('json_unpack failed to catch invalid type');
  end;
  check_error(@error, json_error_wrong_type, 'Expected integer, got string', '<validation>', 1,
              1, 1);

  if json_unpack_ex(j, @error, 0, 'f') = 0 then begin
    Fail('json_unpack failed to catch invalid type');
  end;
  check_error(@error, json_error_wrong_type, 'Expected real, got integer', '<validation>', 1, 1,
              1);

  if json_unpack_ex(j2, @error, 0, 'F') = 0 then begin
    Fail('json_unpack failed to catch invalid type');
  end;
  check_error(@error, json_error_wrong_type, 'Expected real or integer, got string',
              '<validation>', 1, 1, 1);

  if json_unpack_ex(j, @error, 0, '[i]') = 0 then begin
    Fail('json_unpack failed to catch invalid type');
  end;
  check_error(@error, json_error_wrong_type, 'Expected array, got integer', '<validation>', 1,
              1, 1);

  if json_unpack_ex(j, @error, 0, '{si}', 'foo') = 0 then begin
    Fail('json_unpack failed to catch invalid type');
  end;
  check_error(@error, json_error_wrong_type, 'Expected object, got integer', '<validation>', 1,
              1, 1);

  json_decref(j);
  json_decref(j2);

  (* Array index out of range *)
  j := json_pack('[i]', 1);
  if json_unpack_ex(j, @error, 0, '[ii]', @i1, @i2) = 0 then begin
    Fail('json_unpack failed to catch index out of array bounds');
  end;
  check_error(@error, json_error_index_out_of_range, 'Array index 1 out of range',
              '<validation>', 1, 3, 3);
  json_decref(j);

  (* NULL object key *)
  j := json_pack('{si}', 'foo', 42);
  if json_unpack_ex(j, @error, 0, '{si}', nil, @i1) = 0 then begin
    Fail('json_unpack failed to catch null string pointer');
  end;
  check_error(@error, json_error_null_value, 'NULL object key', '<args>', 1, 2, 2);
  json_decref(j);

  (* Object key not found *)
  j := json_pack('{si}', 'foo', 42);
  if json_unpack_ex(j, @error, 0, '{si}', 'baz', @i1) = 0 then begin
    Fail('json_unpack failed to catch null string pointer');
  end;
  check_error(@error, json_error_item_not_found, 'Object item not found: baz', '<validation>',
              1, 3, 3);
  json_decref(j);

  (*
   * Strict validation
   *)

  j := json_pack('[iii]', 1, 2, 3);
  rv := json_unpack(j, '[iii!]', @i1, @i2, @i3);
  if (rv <> 0) or (i1 <> 1) or (i2 <> 2) or (i3 <> 3) then begin
    Fail('json_unpack array with strict validation failed');
  end;
  json_decref(j);

  j := json_pack('[iii]', 1, 2, 3);
  if json_unpack_ex(j, @error, 0, '[ii!]', @i1, @i2) = 0 then begin
    Fail('json_unpack array with strict validation failed');
  end;
  check_error(@error, json_error_end_of_input_expected, '1 array item(s) left unpacked',
              '<validation>', 1, 5, 5);
  json_decref(j);

  (* Like above, but with JSON_STRICT instead of '!' format *)
  j := json_pack('[iii]', 1, 2, 3);
  if json_unpack_ex(j, @error, JSON_STRICT, '[ii]', @i1, @i2) = 0 then begin
      Fail('json_unpack array with strict validation failed');
  end;
  check_error(@error, json_error_end_of_input_expected, '1 array item(s) left unpacked',
              '<validation>', 1, 4, 4);
  json_decref(j);

  j := json_pack('{s:s, s:i}', 'foo', 'bar', 'baz', 42);
  rv := json_unpack(j, '{sssi!}', 'foo', @s, 'baz', @i1);
  if (rv <> 0) or (StrComp(s, 'bar') <> 0) or (i1 <> 42) then begin
    Fail('json_unpack object with strict validation failed');
  end;
  json_decref(j);

  (* Unpack the same item twice *)
  j := json_pack('{s:s, s:i, s:b}', 'foo', 'bar', 'baz', 42, 'quux', 1);
  if json_unpack_ex(j, @error, 0, '{s:s,s:s!}', 'foo', @s, 'foo', @s) = 0 then begin
    Fail('json_unpack object with strict validation failed');
  end;
  check_errors(@error, json_error_end_of_input_expected,
        ['2 object item(s) left unpacked: baz, quux', '2 object item(s) left unpacked: quux, baz'], '<validation>', 1, 10, 10);
  json_decref(j);

  j := json_pack('[i,{s:i,s:n},[i,i]]', 1, 'foo', 2, 'bar', 3, 4);
  if json_unpack_ex(j, nil, JSON_STRICT or JSON_VALIDATE_ONLY, '[i{sisn}[ii]]', 'foo',
                     'bar') <> 0 then begin
    Fail('json_unpack complex value with strict validation failed');
  end;
  json_decref(j);

  (* ! and * must be last *)
  j := json_pack('[ii]', 1, 2);
  if json_unpack_ex(j, @error, 0, '[i!i]', @i1, @i2) = 0 then begin
    Fail('json_unpack failed to catch ! in the middle of an array');
  end;
  check_error(@error, json_error_invalid_format, 'Expected '']'' after ''!'', got ''i''', '<format>',
              1, 4, 4);

  if json_unpack_ex(j, @error, 0, '[i*i]', @i1, @i2) = 0 then begin
    Fail('json_unpack failed to catch * in the middle of an array');
  end;
  check_error(@error, json_error_invalid_format, 'Expected '']'' after ''*'', got ''i''', '<format>',
              1, 4, 4);
  json_decref(j);

  j := json_pack('{sssi}', 'foo', 'bar', 'baz', 42);
  if json_unpack_ex(j, @error, 0, '{ss!si}', 'foo', @s, 'baz', @i1) = 0 then begin
    Fail('json_unpack failed to catch ! in the middle of an object');
  end;
  check_error(@error, json_error_invalid_format, 'Expected ''}'' after ''!'', got ''s''', '<format>',
              1, 5, 5);

  if json_unpack_ex(j, @error, 0, '{ss*si}', 'foo', @s, 'baz', @i1) = 0 then begin
    Fail('json_unpack failed to catch ! in the middle of an object');
  end;
  check_error(@error, json_error_invalid_format, 'Expected ''}'' after ''*'', got ''s''', '<format>',
              1, 5, 5);
  json_decref(j);

  (* Error in nested object *)
  j := json_pack('{s{snsn}}', 'foo', 'bar', 'baz');
  if json_unpack_ex(j, @error, 0, '{s{sn!}}', 'foo', 'bar') = 0 then begin
    Fail('json_unpack nested object with strict validation failed');
  end;
  check_error(@error, json_error_end_of_input_expected, '1 object item(s) left unpacked: baz',
              '<validation>', 1, 7, 7);
  json_decref(j);

  (* Error in nested array *)
  j := json_pack('[[ii]]', 1, 2);
  if json_unpack_ex(j, @error, 0, '[[i!]]', @i1) = 0 then begin
    Fail('json_unpack nested array with strict validation failed');
  end;
  check_error(@error, json_error_end_of_input_expected, '1 array item(s) left unpacked',
              '<validation>', 1, 5, 5);
  json_decref(j);

  (* Optional values *)
  j := json_object();
  i1 := 0;
  if json_unpack(j, '{s?i}', 'foo', @i1) <> 0 then begin
    Fail('json_unpack failed for optional key');
  end;
  if i1 <> 0 then begin
    Fail('json_unpack unpacked an optional key');
  end;
  json_decref(j);

  i1 := 0;
  j := json_pack('{si}', 'foo', 42);
  if json_unpack(j, '{s?i}', 'foo', @i1) <> 0 then begin
    Fail('json_unpack failed for an optional value');
  end;
  if i1 <> 42 then begin
    Fail('json_unpack failed to unpack an optional value');
  end;
  json_decref(j);

  j := json_object();
  i1 := 0;
  i2 := 0;
  i3 := 0;
  if json_unpack(j, '{s?[ii]s?{s{si}}}', 'foo', @i1, @i2, 'bar', 'baz', 'quux', @i3) <> 0 then begin
    Fail('json_unpack failed for complex optional values');
  end;
  if (i1 <> 0) or (i2 <> 0) or (i3 <> 0) then begin
    Fail('json_unpack unexpectedly unpacked something');
  end;
  json_decref(j);

  j := json_pack('{s{si}}', 'foo', 'bar', 42);
  if json_unpack(j, '{s?{s?i}}', 'foo', 'bar', @i1) <> 0 then begin
    Fail('json_unpack failed for complex optional values');
  end;
  if i1 <> 42 then begin
    Fail('json_unpack failed to unpack');
  end;
  json_decref(j);

  (* Combine ? and ! *)
  j := json_pack('{si}', 'foo', 42);
  i1 := 0;
  i2 := 0;
  if json_unpack(j, '{sis?i!}', 'foo', @i1, 'bar', @i2) <> 0 then begin
    Fail('json_unpack failed for optional values with strict mode');
  end;
  if i1 <> 42 then begin
    Fail('json_unpack failed to unpack');
  end;
  if i2 <> 0 then begin
    Fail('json_unpack failed to unpack');
  end;
  json_decref(j);

  (* But don't compensate a missing key with an optional one. *)
  j := json_pack('{sisi}', 'foo', 42, 'baz', 43);
  i1 := 0;
  i2 := 0;
  i3 := 0;
  if json_unpack_ex(j, @error, 0, '{sis?i!}', 'foo', @i1, 'bar', @i2) = 0 then begin
    Fail('json_unpack failed for optional values with strict mode and '
           +'compensation');
  end;
  check_error(@error, json_error_end_of_input_expected, '1 object item(s) left unpacked: baz',
              '<validation>', 1, 8, 8);
  json_decref(j);
end;

initialization
  RegisterTest(TTestUnpack.Suite);

end.
