unit TestSimple;

interface

uses
  TestFramework;

type
  TTestSimple = class(TTestCase)
  published
    procedure TestBadArgs;

    (* Call the simple functions not covered by other tests of the public API *)
    procedure TestSimple;
  end;

implementation

uses
  Jansson, SysUtils, Math;

{ TTestSimple }

procedure TTestSimple.TestBadArgs;
var
  LNum: PJson;
  LTxt: PJson;
begin
  LNum := json_integer(1);
  LTxt := json_string('test');

  if (LNum = nil) or (LTxt = nil) then begin
    Fail('failed to allocate test objects');
  end;

  if json_string_nocheck(nil) <> nil then begin
    Fail('json_string_nocheck with NULL argument did not return NULL');
  end;
  if json_stringn_nocheck(nil, 0) <> nil then begin
    Fail('json_stringn_nocheck with NULL argument did not return NULL');
  end;
  if json_string(nil) <> nil then begin
    Fail('json_string with NULL argument did not return NULL');
  end;
  if json_stringn(nil, 0) <> nil then begin
    Fail('json_stringn with NULL argument did not return NULL');
  end;

  if json_string_length(nil) <> 0 then begin
    Fail('json_string_length with non-string argument did not return 0');
  end;
  if json_string_length(LNum) <> 0 then begin
    Fail('json_string_length with non-string argument did not return 0');
  end;

  if json_string_value(nil) <> nil then begin
    Fail('json_string_value with non-string argument did not return NULL');
  end;
  if json_string_value(LNum) <> nil then begin
    Fail('json_string_value with non-string argument did not return NULL');
  end;

  if json_string_setn_nocheck(nil, '', 0) = 0 then begin
    Fail('json_string_setn with non-string argument did not return error');
  end;
  if json_string_setn_nocheck(LNum, '', 0) = 0 then begin
    Fail('json_string_setn with non-string argument did not return error');
  end;
  if json_string_setn_nocheck(LTxt, nil, 0) = 0 then begin
    Fail('json_string_setn_nocheck with NULL value did not return error');
  end;

  if json_string_set_nocheck(LTxt, nil) = 0 then begin
    Fail('json_string_set_nocheck with NULL value did not return error');
  end;
  if json_string_set(LTxt, nil) = 0 then begin
    Fail('json_string_set with NULL value did not return error');
  end;
  if json_string_setn(LTxt, nil, 0) = 0 then begin
    Fail('json_string_setn with NULL value did not return error');
  end;

  if LNum.refcount <> 1 then begin
    Fail('unexpected reference count for num');
  end;
  if LTxt.refcount <> 1 then begin
    Fail('unexpected reference count for txt');
  end;

  json_decref(LNum);
  json_decref(LTxt);
end;

procedure TTestSimple.TestSimple;
var
  LValue: PJson;
begin
  LValue := json_boolean(1);
  if not json_is_true(LValue) then begin
    Fail('json_boolean(1) failed');
  end;
  json_decref(LValue);

  LValue := json_boolean(-123);
  if not json_is_true(LValue) then begin
    Fail('json_boolean(-123) failed');
  end;
  json_decref(LValue);

  LValue := json_boolean(0);
  if not json_is_false(LValue) then begin
    Fail('json_boolean(0) failed');
  end;
  if json_boolean_value(LValue) <> 0 then begin
    Fail('json_boolean_value failed');
  end;
  json_decref(LValue);

  LValue := json_integer(1);
  if json_typeof(LValue) <> JSON_INTEGER_T then begin
    Fail('json_typeof failed');
  end;

  if json_is_object(LValue) then begin
    Fail('json_is_object failed');
  end;

  if json_is_array(LValue) then begin
    Fail('json_is_array failed');
  end;

  if json_is_string(LValue) then begin
    Fail('json_is_string failed');
  end;

  if not json_is_integer(LValue) then begin
    Fail('json_is_integer failed');
  end;

  if json_is_real(LValue) then begin
    Fail('json_is_real failed');
  end;

  if not json_is_number(LValue) then begin
    Fail('json_is_number failed');
  end;

  if json_is_true(LValue) then begin
    Fail('json_is_true failed');
  end;

  if json_is_false(LValue) then begin
    Fail('json_is_false failed');
  end;

  if json_is_boolean(LValue) then begin
    Fail('json_is_boolean failed');
  end;

  if json_is_null(LValue) then begin
    Fail('json_is_null failed');
  end;

  json_decref(LValue);

  LValue := json_string('foo');
  if LValue = nil then begin
    Fail('json_string failed');
  end;
  if StrComp(json_string_value(LValue), 'foo') <> 0 then begin
    Fail('invalid string value');
  end;
  if json_string_length(LValue) <> 3 then begin
    Fail('invalid string length');
  end;

  if json_string_set(LValue, 'barr') <> 0 then begin
    Fail('json_string_set failed');
  end;
  if StrComp(json_string_value(LValue), 'barr') <> 0 then begin
    Fail('invalid string value');
  end;
  if json_string_length(LValue) <> 4 then begin
    Fail('invalid string length');
  end;

  if json_string_setn(LValue, 'hi'#0'ho', 5) <> 0 then begin
    Fail('json_string_set failed');
  end;
  if not CompareMem(json_string_value(LValue), PAnsiChar('hi'#0'ho'#0''), 6) then begin
    Fail('invalid string value');
  end;
  if json_string_length(LValue) <> 5 then begin
    Fail('invalid string length');
  end;

  json_decref(LValue);

  LValue := json_string(nil);
  if LValue <> nil then begin
    Fail('json_string(NULL) failed');
  end;

  (* invalid UTF-8  *)
  LValue := json_string('a' + Chr($EF) + 'z');
  if LValue <> nil then begin
    Fail('json_string(<invalid utf-8>) failed');
  end;

  LValue := json_string_nocheck('foo');
  if LValue = nil then begin
    Fail('json_string_nocheck failed');
  end;
  if StrComp(json_string_value(LValue), 'foo') <> 0 then begin
    Fail('invalid string value');
  end;
  if json_string_length(LValue) <> 3 then begin
    Fail('invalid string length');
  end;

  if json_string_set_nocheck(LValue, 'barr') <> 0 then begin
    Fail('json_string_set_nocheck failed');
  end;
  if StrComp(json_string_value(LValue), 'barr') <> 0 then begin
    Fail('invalid string value');
  end;
  if json_string_length(LValue) <> 4 then begin
    Fail('invalid string length');
  end;

  if json_string_setn_nocheck(LValue, 'hi'#0'ho', 5) <> 0 then begin
    Fail('json_string_set failed');
  end;
  if not CompareMem(json_string_value(LValue), PAnsiChar('hi'#0'ho'#0''), 6) then begin
    Fail('invalid string value');
  end;
  if json_string_length(LValue) <> 5 then begin
    Fail('invalid string length');
  end;

  json_decref(LValue);

  (* invalid UTF-8 *)
  LValue := json_string_nocheck('qu' + Chr($FF));
  if LValue = nil then begin
    Fail('json_string_nocheck failed');
  end;
  if StrComp(json_string_value(LValue), 'qu' + Chr($FF)) <> 0 then begin
    Fail('invalid string value');
  end;
  if json_string_length(LValue) <> 3 then begin
    Fail('invalid string length');
  end;

  if json_string_set_nocheck(LValue, Chr($FD) + Chr($FD) + Chr($FF)) <> 0 then begin
    Fail('json_string_set_nocheck failed');
  end;
  if StrComp(json_string_value(LValue), Chr($FD) + Chr($FD) + Chr($FF)) <> 0 then begin
    Fail('invalid string value');
  end;
  if json_string_length(LValue) <> 3 then begin
    Fail('invalid string length');
  end;

  json_decref(LValue);

  LValue := json_integer(123);
  if LValue = nil then begin
    Fail('json_integer failed');
  end;
  if json_integer_value(LValue) <> 123 then begin
    Fail('invalid integer value');
  end;
  if json_number_value(LValue) <> 123.0 then begin
    Fail('invalid number value');
  end;

  if json_integer_set(LValue, 321) <> 0 then begin
    Fail('json_integer_set failed');
  end;
  if json_integer_value(LValue) <> 321 then begin
    Fail('invalid integer value');
  end;
  if json_number_value(LValue) <> 321.0 then begin
    Fail('invalid number value');
  end;

  json_decref(LValue);

  LValue := json_real(123.123);
  if LValue = nil then begin
    Fail('json_real failed');
  end;
  if CompareValue(json_real_value(LValue), 123.123, 0.0000001) <> 0 then begin
    Fail('invalid integer value');
  end;
  if CompareValue(json_number_value(LValue), 123.123, 0.0000001) <> 0 then begin
    Fail('invalid number value');
  end;

  if json_real_set(LValue, 321.321) <> 0 then begin
    Fail('json_real_set failed');
  end;
  if CompareValue(json_real_value(LValue), 321.321, 0.0000001) <> 0 then begin
    Fail('invalid real value');
  end;
  if CompareValue(json_number_value(LValue), 321.321, 0.0000001) <> 0 then begin
    Fail('invalid number value');
  end;

  json_decref(LValue);

  LValue := json_true();
  if LValue = nil then begin
    Fail('json_true failed');
  end;
  json_decref(LValue);

  LValue := json_false();
  if LValue = nil then begin
    Fail('json_false failed');
  end;
  json_decref(LValue);

  LValue := json_null();
  if LValue = nil then begin
    Fail('json_null failed');
  end;
  json_decref(LValue);

  (* Test reference counting on singletons (true, false, null) *)
  LValue := json_true();
  if LValue.refcount <> size_t(-1) then begin
    Fail('refcounting true works incorrectly');
  end;
  json_decref(LValue);
  if LValue.refcount <> size_t(-1) then begin
    Fail('refcounting true works incorrectly');
  end;
  json_incref(LValue);
  if LValue.refcount <> size_t(-1) then begin
    Fail('refcounting true works incorrectly');
  end;

  LValue := json_false();
  if LValue.refcount <> size_t(-1) then begin
    Fail('refcounting false works incorrectly');
  end;
  json_decref(LValue);
  if LValue.refcount <> size_t(-1) then begin
    Fail('refcounting false works incorrectly');
  end;
  json_incref(LValue);
  if LValue.refcount <> size_t(-1) then begin
    Fail('refcounting false works incorrectly');
  end;

  LValue := json_null();
  if LValue.refcount <> size_t(-1) then begin
    Fail('refcounting null works incorrectly');
  end;
  json_decref(LValue);
  if LValue.refcount <> size_t(-1) then begin
    Fail('refcounting null works incorrectly');
  end;
  json_incref(LValue);
  if LValue.refcount <> size_t(-1) then begin
    Fail('refcounting null works incorrectly');
  end;
end;

initialization
  RegisterTest(TTestSimple.Suite);

end.
