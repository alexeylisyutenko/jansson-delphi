unit TestCopy;

interface

uses
  TestFramework;

type
  TTestCopy = class(TTestCase)
  published
    procedure TestCopySimple;
    procedure TestDeepCopySimple;
    procedure TestCopyArray;
    procedure TestDeepCopyArray;
    procedure TestCopyObject;
    procedure TestDeepCopyObject;
    procedure TestDeepCopyCircularReferences;
  end;

implementation

uses
  Jansson, SysUtils;

{ TTestCopy }

procedure TTestCopy.TestCopyArray;
const
  json_array_text: PAnsiChar = '[1, "foo", 3.141592, {"foo": "bar"}]';
var
  LArray: PJson;
  LCopy: PJson;
  I: Integer;
begin
  LArray := json_loads(json_array_text, 0, nil);
  if LArray = nil then begin
    Fail('unable to parse an array');
  end;

  LCopy := json_copy(LArray);
  if LCopy = nil then begin
    Fail('unable to copy an array');
  end;
  if LCopy = LArray then begin
    Fail('copying an array doesn''t copy');
  end;
  if json_equal(LCopy, LArray) = 0 then begin
    Fail('copying an array produces an inequal copy');
  end;

  for I := 0 to json_array_size(LCopy) - 1 do begin
    if json_array_get(LArray, I) <> json_array_get(LCopy, I) then begin
      Fail('copying an array modifies its elements');
    end;
  end;

  json_decref(LArray);
  json_decref(LCopy);
end;

procedure TTestCopy.TestCopyObject;
const
  json_object_text: PAnsiChar = '{"foo": "bar", "a": 1, "b": 3.141592, "c": [1,2,3,4]}';
  keys: array[0..3] of PAnsiChar = ('foo', 'a', 'b', 'c');
var
  LObject: PJson;
  LCopy: PJson;
  LIter: Pointer;
  I : Integer;
  LKey: PAnsiChar;
  LValue1: PJson;
  LValue2: PJson;
begin
  LObject := json_loads(json_object_text, 0, nil);
  if LObject = nil then begin
    Fail('unable to parse an object');
  end;

  LCopy := json_copy(LObject);
  if LCopy = nil then begin
    Fail('unable to copy an object');
  end;
  if LCopy = LObject then begin
    Fail('copying an object doesn''t copy');
  end;
  if json_equal(LCopy, LObject) = 0 then begin
    Fail('copying an object produces an inequal copy');
  end;

  I := 0;
  LIter := json_object_iter(LObject);
  while (LIter <> nil) do begin
      LKey := json_object_iter_key(LIter);
      LValue1 := json_object_iter_value(LIter);
      LValue2 := json_object_get(LCopy, LKey);

      if LValue1 <> LValue2 then begin 
        Fail('copying an object modifies its items');
      end;

      if StrComp(LKey, keys[i]) <> 0 then begin 
        Fail('copying an object doesn''t preserve key order');
      end;

      LIter := json_object_iter_next(LObject, LIter);
      Inc(I);
  end;

  json_decref(LObject);
  json_decref(LCopy);
end;

procedure TTestCopy.TestCopySimple;
var
  LValue: PJson;
  LCopy: PJson;
begin
  if json_copy(nil) <> nil then begin
    Fail('copying NULL doesn''t return NULL');
  end;

  (* true *)
  LValue := json_true();
  LCopy := json_copy(LValue);
  if LValue <> LCopy then begin
    Fail('copying true failed');
  end;
  json_decref(LValue);
  json_decref(LCopy);

  (* false *)
  LValue := json_false();
  LCopy := json_copy(LValue);
  if LValue <> LCopy then begin
    Fail('copying false failed');
  end;
  json_decref(LValue);
  json_decref(LCopy);

  (* null *)
  LValue := json_null();
  LCopy := json_copy(LValue);
  if LValue <> LCopy then begin
    Fail('copying null failed');
  end;
  json_decref(LValue);
  json_decref(LCopy);

  (* string *)
  LValue := json_string('foo');
  if LValue = nil then begin
    Fail('unable to create a string');
  end;
  LCopy := json_copy(LValue);
  if LCopy = nil then begin
    Fail('unable to copy a string');
  end;
  if LCopy = LValue then begin
    Fail('copying a string doesn''t copy');
  end;
  if json_equal(LCopy, LValue) = 0 then begin
    Fail('copying a string produces an inequal copy');
  end;
  if (LValue.refcount <> 1) or (LCopy.refcount <> 1) then begin
    Fail('invalid refcounts');
  end;
  json_decref(LValue);
  json_decref(LCopy);

  (* integer *)
  LValue := json_integer(543);
  if LValue = nil then begin
    Fail('unable to create an integer');
  end;
  LCopy := json_copy(LValue);
  if LCopy = nil then begin
    Fail('unable to copy an integer');
  end;
  if LCopy = LValue then begin
    Fail('copying an integer doesn''t copy');
  end;
  if json_equal(LCopy, LValue) = 0 then begin
    Fail('copying an integer produces an inequal copy');
  end;
  if (LValue.refcount <> 1) or (LCopy.refcount <> 1) then begin
    Fail('invalid refcounts');
  end;
  json_decref(LValue);
  json_decref(LCopy);

  (* real *)
  LValue := json_real(123e9);
  if LValue = nil then begin
    Fail('unable to create a real');
  end;
  LCopy := json_copy(LValue);
  if LCopy = nil then begin
    Fail('unable to copy a real');
  end;
  if LCopy = LValue then begin
    Fail('copying a real doesn''t copy');
  end;
  if json_equal(LCopy, LValue) = 0 then begin
    Fail('copying a real produces an inequal copy');
  end;
  if (LValue.refcount <> 1) or (LCopy.refcount <> 1) then begin
    Fail('invalid refcounts');
  end;
  json_decref(LValue);
  json_decref(LCopy);
end;

procedure TTestCopy.TestDeepCopyArray;
const
  json_array_text: PAnsiChar = '[1, "foo", 3.141592, {"foo": "bar"}]';
var
  LArray: PJson;
  LCopy: PJson;
  I: Integer;
begin
  LArray := json_loads(json_array_text, 0, nil);
  if LArray = nil then begin
    Fail('unable to parse an array');
  end;

  LCopy := json_deep_copy(LArray);
  if LCopy = nil then begin
    Fail('unable to deep copy an array');
  end;
  if LCopy = LArray then begin
    Fail('deep copying an array doesn''t copy');
  end;
  if json_equal(LCopy, LArray) = 0 then begin
      Fail('deep copying an array produces an inequal copy');
  end;

  for I := 0 to json_array_size(LCopy) - 1 do begin
    if json_array_get(LArray, I) = json_array_get(LCopy, I) then begin
      Fail('deep copying an array doesn''t copy its elements');
    end;
  end;

  json_decref(LArray);
  json_decref(LCopy);
end;

procedure TTestCopy.TestDeepCopyCircularReferences;
var
  json: PJson;
  copy: PJson;
begin
  (* Construct a JSON object/array with a circular reference:
    object: {"a": {"b": {"c": <circular reference to $.a>}}}
    array: [[[<circular reference to the $[0] array>]]]
    Deep copy it, remove the circular reference and deep copy again.
 *)

  json := json_object();
  json_object_set_new(json, 'a', json_object());
  json_object_set_new(json_object_get(json, 'a'), 'b', json_object());
  json_object_set(json_object_get(json_object_get(json, 'a'), 'b'), 'c',
                  json_object_get(json, 'a'));

  copy := json_deep_copy(json);
  if copy <> nil then begin 
    Fail('json_deep_copy copied a circular reference!');
  end;

  json_object_del(json_object_get(json_object_get(json, 'a'), 'b'), 'c');

  copy := json_deep_copy(json);
  if copy = nil then begin 
    Fail('json_deep_copy failed!');
  end;

  json_decref(copy);
  json_decref(json);

  json := json_array();
  json_array_append_new(json, json_array());
  json_array_append_new(json_array_get(json, 0), json_array());
  json_array_append(json_array_get(json_array_get(json, 0), 0),
                    json_array_get(json, 0));

  copy := json_deep_copy(json);
  if copy <> nil then begin
    Fail('json_deep_copy copied a circular reference!');
  end;

  json_array_remove(json_array_get(json_array_get(json, 0), 0), 0);

  copy := json_deep_copy(json);
  if copy = nil then begin
    Fail('json_deep_copy failed!');
  end;

  json_decref(copy);
  json_decref(json);
end;

procedure TTestCopy.TestDeepCopyObject;
const
  json_object_text: PAnsiChar = '{"foo": "bar", "a": 1, "b": 3.141592, "c": [1,2,3,4]}';
  keys: array[0..3] of PAnsiChar = ('foo', 'a', 'b', 'c');
var
  LObject: PJson;
  LCopy: PJson;
  LIter: Pointer;
  I : Integer;
  LKey: PAnsiChar;
  LValue1: PJson;
  LValue2: PJson;
begin
  LObject := json_loads(json_object_text, 0, nil);
  if LObject = nil then begin
    Fail('unable to parse an object');
  end;

  LCopy := json_deep_copy(LObject);
  if LCopy = nil then begin
    Fail('unable to deep copy an object');
  end;
  if LCopy = LObject then begin
    Fail('deep copying an object doesn''t copy');
  end;
  if json_equal(LCopy, LObject) = 0 then begin
    Fail('deep copying an object produces an inequal copy');
  end;

  I := 0;
  LIter := json_object_iter(LObject);
  while (LIter <> nil) do begin
      LKey := json_object_iter_key(LIter);
      LValue1 := json_object_iter_value(LIter);
      LValue2 := json_object_get(LCopy, LKey);

      if LValue1 = LValue2 then begin
        Fail('deep copying an object doesn''t copy its items');
      end;

      if StrComp(LKey, keys[i]) <> 0 then begin 
        Fail('copying an object doesn''t preserve key order');
      end;

      LIter := json_object_iter_next(LObject, LIter);
      Inc(I);
  end;

  json_decref(LObject);
  json_decref(LCopy);
end;

procedure TTestCopy.TestDeepCopySimple;
var
  LValue: PJson;
  LCopy: PJson;
begin
  if json_deep_copy(nil) <> nil then begin
    Fail('deep copying NULL doesn''t return NULL');
  end;

  (* true *)
  LValue := json_true();
  LCopy := json_deep_copy(LValue);
  if LValue <> LCopy then begin
    Fail('deep copying true failed');
  end;
  json_decref(LValue);
  json_decref(LCopy);

  (* false *)
  LValue := json_false();
  LCopy := json_deep_copy(LValue);
  if LValue <> LCopy then begin
    Fail('deep copying false failed');
  end;
  json_decref(LValue);
  json_decref(LCopy);

  (* null *)
  LValue := json_null();
  LCopy := json_deep_copy(LValue);
  if LValue <> LCopy then begin
    Fail('deep copying null failed');
  end;
  json_decref(LValue);
  json_decref(LCopy);

  (* string *)
  LValue := json_string('foo');
  if LValue = nil then begin
    Fail('unable to create a string');
  end;
  LCopy := json_deep_copy(LValue);
  if LCopy = nil then begin
    Fail('unable to deep copy a string');
  end;
  if LCopy = LValue then begin
    Fail('deep copying a string doesn''t copy');
  end;
  if json_equal(LCopy, LValue) = 0 then begin
    Fail('deep copying a string produces an inequal copy');
  end;
  if (LValue.refcount <> 1) or (LCopy.refcount <> 1) then begin
    Fail('invalid refcounts');
  end;
  json_decref(LValue);
  json_decref(LCopy);

  (* integer *)
  LValue := json_integer(543);
  if LValue = nil then begin
    Fail('unable to create an integer');
  end;
  LCopy := json_deep_copy(LValue);
  if LCopy = nil then begin
    Fail('unale to deep copy an integer');
  end;
  if LCopy = LValue then begin
    Fail('deep copying an integer doesn''t copy');
  end;
  if json_equal(LCopy, LValue) = 0 then begin
    Fail('deep copying an integer produces an inequal copy');
  end;
  if (LValue.refcount <> 1) or (LCopy.refcount <> 1) then begin
    Fail('invalid refcounts');
  end;
  json_decref(LValue);
  json_decref(LCopy);

  (* real *)
  LValue := json_real(123e9);
  if LValue = nil then begin
    Fail('unable to create a real');
  end;
  LCopy := json_deep_copy(LValue);
  if LCopy = nil then begin
    Fail('unable to deep copy a real');
  end;
  if LCopy = LValue then begin
    Fail('deep copying a real doesn''t copy');
  end;
  if json_equal(LCopy, LValue) = 0 then begin
    Fail('deep copying a real produces an inequal copy');
  end;
  if (LValue.refcount <> 1) or (LCopy.refcount <> 1) then begin
    Fail('invalid refcounts');
  end;
  json_decref(LValue);
  json_decref(LCopy);
end;

initialization
  RegisterTest(TTestCopy.Suite);

end.
