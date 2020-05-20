unit TestObject;

interface

uses
  TestFramework;

type
  TTestObject = class(TTestCase)
  published
    procedure TestMisc;
    procedure TestClear;
    procedure TestUpdate;
    procedure TestSetManyKeys;
    procedure TestConditionalUpdates;
    procedure TestCircular;
    procedure TestSetNoCheck;
    procedure TestIterators;
    procedure TestPreserveOrder;
    procedure TestObjectForeach;
    procedure TestObjectForeachSafe;
    procedure TestBadArgs;
  end;

implementation

uses
  Jansson, Util, Math, SysUtils;

{ TTestObject }

procedure TTestObject.TestBadArgs;
var
  LObj: PJson;
  LNum: PJson;
  LIter: Pointer;
begin
  LObj := json_object();
  LNum := json_integer(1);

  if (LObj = nil) or (LNum = nil) then begin
    Fail('failed to allocate test objects');
  end;

  if json_object_set(LObj, 'testkey', json_null()) <> 0 then begin
    Fail('failed to set testkey on object');
  end;

  LIter := json_object_iter(LObj);
  if LIter = nil then begin
    Fail('failed to retrieve test iterator');
  end;

  if json_object_size(nil) <> 0 then begin 
    Fail('json_object_size with non-object argument returned non-zero');
  end;
  if json_object_size(LNum) <> 0 then begin
    Fail('json_object_size with non-object argument returned non-zero');
  end;

  if json_object_get(nil, 'test') <> nil then begin 
    Fail('json_object_get with non-object argument returned non-NULL');
  end;
  if json_object_get(LNum, 'test') <> nil then begin
    Fail('json_object_get with non-object argument returned non-NULL');
  end;
  if json_object_get(LObj, nil) <> nil then begin
    Fail('json_object_get with NULL key returned non-NULL');
  end;

  if json_object_set_new_nocheck(nil, 'test', json_null()) = 0 then begin 
    Fail('json_object_set_new_nocheck with non-object argument did not return error');
  end;
  if json_object_set_new_nocheck(LNum, 'test', json_null()) = 0 then begin
    Fail('json_object_set_new_nocheck with non-object argument did not return error');
  end;
  if json_object_set_new_nocheck(LObj, 'test', json_incref(LObj)) = 0 then begin
    Fail('json_object_set_new_nocheck with object == value did not return error');
  end;
  if json_object_set_new_nocheck(LObj, nil, json_object()) = 0 then begin
    Fail('json_object_set_new_nocheck with NULL key did not return error');
  end;

  if json_object_del(nil, 'test') = 0 then begin 
    Fail('json_object_del with non-object argument did not return error');
  end;
  if json_object_del(LNum, 'test') = 0 then begin
    Fail('json_object_del with non-object argument did not return error');
  end;
  if json_object_del(LObj, nil) = 0 then begin
    Fail('json_object_del with NULL key did not return error');
  end;

  if json_object_clear(nil) = 0 then begin 
    Fail('json_object_clear with non-object argument did not return error');
  end;
  if json_object_clear(LNum) = 0 then begin
    Fail('json_object_clear with non-object argument did not return error');
  end;

  if json_object_update(nil, LObj) = 0 then begin
    Fail('json_object_update with non-object first argument did not return error');
  end;
  if json_object_update(LNum, LObj) = 0 then begin
    Fail('json_object_update with non-object first argument did not return error');
  end;
  if json_object_update(LObj, nil) = 0 then begin
    Fail('json_object_update with non-object second argument did not return error');
  end;
  if json_object_update(LObj, LNum) = 0 then begin
    Fail('json_object_update with non-object second argument did not return error');
  end;

  if json_object_update_existing(nil, LObj) = 0 then begin
    Fail('json_object_update_existing with non-object first argument did not return error');
  end;
  if json_object_update_existing(LNum, LObj) = 0 then begin
    Fail('json_object_update_existing with non-object first argument did not return error');
  end;
  if json_object_update_existing(LObj, nil) = 0 then begin
    Fail('json_object_update_existing with non-object second argument did not return error');
  end;
  if json_object_update_existing(LObj, LNum) = 0 then begin
    Fail('json_object_update_existing with non-object second argument did not return error');
  end;

  if json_object_update_missing(nil, LObj) = 0 then begin
    Fail('json_object_update_missing with non-object first argument did not return error');
  end;
  if json_object_update_missing(LNum, LObj) = 0 then begin
    Fail('json_object_update_missing with non-object first argument did not return error');
  end;
  if json_object_update_missing(LObj, nil) = 0 then begin
    Fail('json_object_update_missing with non-object second argument did not return error');
  end;
  if json_object_update_missing(LObj, LNum) = 0 then begin
    Fail('json_object_update_missing with non-object second argument did not return error');
  end;

  if json_object_iter(nil) <> nil then begin 
    Fail('json_object_iter with non-object argument returned non-NULL');
  end;
  if json_object_iter(LNum) <> nil then begin
    Fail('json_object_iter with non-object argument returned non-NULL');
  end;

  if json_object_iter_at(nil, 'test') <> nil then begin 
    Fail('json_object_iter_at with non-object argument returned non-NULL');
  end;
  if json_object_iter_at(LNum, 'test') <> nil then begin
    Fail('json_object_iter_at with non-object argument returned non-NULL');
  end;
  if json_object_iter_at(LObj, nil) <> nil then begin
    Fail('json_object_iter_at with NULL iter returned non-NULL');
  end;

  if json_object_iter_next(LObj, nil) <> nil then begin
    Fail('json_object_iter_next with NULL iter returned non-NULL');
  end;
  if json_object_iter_next(LNum, LIter) <> nil then begin
    Fail('json_object_iter_next with non-object argument returned non-NULL');
  end;

  if json_object_iter_key(nil) <> nil then begin 
    Fail('json_object_iter_key with NULL iter returned non-NULL');
  end;

  if json_object_key_to_iter(nil) <> nil then begin 
    Fail('json_object_key_to_iter with NULL iter returned non-NULL');
  end;

  if json_object_iter_value(nil) <> nil then begin 
    Fail('json_object_iter_value with NULL iter returned non-NULL');
  end;

  if json_object_iter_set_new(nil, LIter, json_incref(LNum)) = 0 then begin
    Fail('json_object_iter_set_new with non-object argument did not return error');
  end;
  if json_object_iter_set_new(LNum, LIter, json_incref(LNum)) = 0 then begin
    Fail('json_object_iter_set_new with non-object argument did not return error');
  end;
  if json_object_iter_set_new(LObj, nil, json_incref(LNum)) = 0 then begin
    Fail('json_object_iter_set_new with NULL iter did not return error');
  end;
  if json_object_iter_set_new(LObj, LIter, nil) = 0 then begin
    Fail('json_object_iter_set_new with NULL value did not return error');
  end;

  if LObj.refcount <> 1 then begin
    Fail('unexpected reference count for obj');
  end;

  if LNum.refcount <> 1 then begin
    Fail('unexpected reference count for num');
  end;

  json_decref(LObj);
  json_decref(LNum);
end;

procedure TTestObject.TestCircular;
var
  LObject1: PJson;
  LObject2: PJson;
begin
  LObject1 := json_object();
  LObject2 := json_object();
  if (LObject1 = nil) or (LObject2 = nil) then begin
    Fail('unable to create object');
  end;

  (* the simple case is checked *)
  if json_object_set(LObject1, 'a', LObject1) = 0 then begin
    Fail('able to set self');
  end;

  (* create circular references *)
  if (json_object_set(LObject1, 'a', LObject2) <> 0) or
      (json_object_set(LObject2, 'a', LObject1) <> 0) then begin
    Fail('unable to set value');
  end;

  (* circularity is detected when dumping *)
  if json_dumps(LObject1, 0) <> nil then begin
    Fail('able to dump circulars');
  end;

  (* decref twice to deal with the circular references *)
  json_decref(LObject1);
  json_decref(LObject2);
  json_decref(LObject1);
end;

procedure TTestObject.TestClear;
var
  LObject: PJson;
  LTen: PJson;
begin
  LObject := json_object();
  LTen := json_integer(10);

  if LObject = nil then begin
    Fail('unable to create object');
  end;
  if LTen = nil then begin
    Fail('unable to create integer');
  end;

  if (json_object_set(LObject, 'a', LTen) <> 0) or (json_object_set(LObject, 'b', LTen) <> 0) or
      (json_object_set(LObject, 'c', LTen) <> 0) or (json_object_set(LObject, 'd', LTen) <> 0) or
      (json_object_set(LObject, 'e', LTen) <> 0) then begin
    Fail('unable to set value');
  end;

  if json_object_size(LObject) <> 5 then begin
    Fail('invalid size');
  end;

  json_object_clear(LObject);

  if json_object_size(LObject) <> 0 then begin
    Fail('invalid size after clear');
  end;

  json_decref(LTen);
  json_decref(LObject);
end;

procedure TTestObject.TestConditionalUpdates;
var
  LObject: PJson;
  LOther: PJson;
begin
  LObject := json_pack('{sisi}', 'foo', 1, 'bar', 2);
  LOther := json_pack('{sisi}', 'foo', 3, 'baz', 4);

  if json_object_update_existing(LObject, LOther) <> 0 then begin 
    Fail('json_object_update_existing failed');
  end;

  if json_object_size(LObject) <> 2 then begin 
    Fail('json_object_update_existing added new items');
  end;

  if json_integer_value(json_object_get(LObject, 'foo')) <> 3 then begin 
    Fail('json_object_update_existing failed to update existing key');
  end;

  if json_integer_value(json_object_get(LObject, 'bar')) <> 2 then begin 
    Fail('json_object_update_existing updated wrong key');
  end;

  json_decref(LObject);

  LObject := json_pack('{sisi}', 'foo', 1, 'bar', 2);

  if json_object_update_missing(LObject, LOther) <> 0 then begin 
    Fail('json_object_update_missing failed');
  end;

  if json_object_size(LObject) <> 3 then begin 
    Fail('json_object_update_missing didn''t add new items');
  end;

  if json_integer_value(json_object_get(LObject, 'foo')) <> 1 then begin 
    Fail('json_object_update_missing updated existing key');
  end;

  if json_integer_value(json_object_get(LObject, 'bar')) <> 2 then begin 
    Fail('json_object_update_missing updated wrong key');
  end;

  if json_integer_value(json_object_get(LObject, 'baz')) <> 4 then begin 
    Fail('json_object_update_missing didn''t add new items');
  end;

  json_decref(LObject);
  json_decref(LOther);
end;

procedure TTestObject.TestIterators;
var
  LObject: PJson;
  LFoo: PJson;
  LBar: PJson;
  LBaz: PJson;
  LIter: Pointer;
begin
  if json_object_iter(nil) <> nil then begin 
    Fail('able to iterate over NULL');
  end;

  if json_object_iter_next(nil, nil) <> nil then begin 
    Fail('able to increment an iterator on a NULL object');
  end;

  LObject := json_object();
  LFoo := json_string('foo');
  LBar := json_string('bar');
  LBaz := json_string('baz');
  if (LObject = nil) or (LFoo = nil) or (LBar = nil) or (LBaz = nil) then begin
    Fail('unable to create values');
  end;

  if json_object_iter_next(LObject, nil) <> nil then begin 
    Fail('able to increment a NULL iterator');
  end;

  if (json_object_set(LObject, 'a', LFoo) <> 0) or
      (json_object_set(LObject, 'b', LBar) <> 0) or
      (json_object_set(LObject, 'c', LBaz) <> 0) then begin 
    Fail('unable to populate object');
  end;

  LIter := json_object_iter(LObject);
  if LIter = nil then begin
    Fail('unable to get iterator');
  end;
  if StrComp(json_object_iter_key(LIter), 'a') <> 0 then begin
    Fail('iterating doesn''t yield keys in order');
  end;
  if json_object_iter_value(LIter) <> LFoo then begin
    Fail('iterating doesn''t yield values in order');
  end;

  LIter := json_object_iter_next(LObject, LIter);
  if LIter = nil then begin
    Fail('unable to increment iterator');
  end;
  if StrComp(json_object_iter_key(LIter), 'b') <> 0 then begin
    Fail('iterating doesn''t yield keys in order');
  end;
  if json_object_iter_value(LIter) <> LBar then begin
    Fail('iterating doesn''t yield values in order');
  end;

  LIter := json_object_iter_next(LObject, LIter);
  if LIter = nil then begin 
    Fail('unable to increment iterator');
  end;
  if StrComp(json_object_iter_key(LIter), 'c') <> 0 then begin 
    Fail('iterating doesn''t yield keys in order');
  end;
  if json_object_iter_value(LIter) <> LBaz then begin 
    Fail('iterating doesn''t yield values in order');
  end;

  if json_object_iter_next(LObject, LIter) <> nil then begin 
    Fail('able to iterate over the end');
  end;

  if json_object_iter_at(LObject, 'foo') <> nil then begin 
    Fail('json_object_iter_at() succeeds for non-existent key');
  end;

  LIter := json_object_iter_at(LObject, 'b');
  if LIter = nil then begin 
    Fail('json_object_iter_at() fails for an existing key');
  end;

  if StrComp(json_object_iter_key(LIter), 'b') <> 0 then begin 
    Fail('iterating failed: wrong key');
  end;
  if json_object_iter_value(LIter) <> LBar then begin 
    Fail('iterating failed: wrong value');
  end;

  if json_object_iter_set(LObject, LIter, LBaz) <> 0 then begin 
    Fail('unable to set value at iterator');
  end;

  if StrComp(json_object_iter_key(LIter), 'b') <> 0 then begin 
    Fail('json_object_iter_key() fails after json_object_iter_set()');
  end;
  if json_object_iter_value(LIter) <> LBaz then begin 
    Fail('json_object_iter_value() fails after json_object_iter_set()');
  end;
  if json_object_get(LObject, 'b') <> LBaz then begin 
    Fail('json_object_get() fails after json_object_iter_set()');
  end;

  json_decref(LObject);
  json_decref(LFoo);
  json_decref(LBar);
  json_decref(LBaz);
end;

procedure TTestObject.TestMisc;
var
  LObject: PJson;
  LString: PJson;
  LOtherString: PJson;
  LValue: PJson;
begin
  LObject := json_object();
  LString := json_string('test');
  LOtherString := json_string('other');

  if LObject = nil then begin 
    Fail('unable to create object');
  end;
  if (LString = nil) or (LOtherString = nil) then begin 
    Fail('unable to create string');
  end;

  if json_object_get(LObject, 'a') <> nil then begin 
    Fail('value for nonexisting key');
  end;

  if json_object_set(LObject, 'a', LString) <> 0 then begin 
    Fail('unable to set value');
  end;

  if json_object_set(LObject, nil, LString) = 0 then begin 
    Fail('able to set NULL key');
  end;

  if json_object_del(LObject, 'a') <> 0 then begin 
    Fail('unable to del the only key');
  end;

  if json_object_set(LObject, 'a', LString) <> 0 then begin 
    Fail('unable to set value');
  end;
  if json_object_set(LObject, 'a', nil) = 0 then begin
    Fail('able to set NULL value');
  end;

  (* invalid UTF-8 in key *)
  if json_object_set(LObject, 'a' + Chr($EF) + 'z', LString) = 0 then begin 
    Fail('able to set invalid unicode key');
  end;

  LValue := json_object_get(LObject, 'a');
  if LValue = nil then begin 
    Fail('no value for existing key');
  end;
  if LValue <> LString then begin 
    Fail('got different value than what was added');
  end;

  (* "a", "lp" and "px" collide in a five-bucket hashtable *)
  if (json_object_set(LObject, 'b', LString) <> 0) or 
      (json_object_set(LObject, 'lp', LString) <> 0) or 
      (json_object_set(LObject, 'px', LString) <> 0) then begin 
    Fail('unable to set value');
  end;

  LValue := json_object_get(LObject, 'a');
  if LValue = nil then begin 
    Fail('no value for existing key');
  end;
  if LValue <> LString then begin 
    Fail('got different value than what was added');
  end;

  if json_object_set(LObject, 'a', LOtherString) <> 0 then begin 
    Fail('unable to replace an existing key');
  end;

  LValue := json_object_get(LObject, 'a');
  if LValue = nil then begin 
    Fail('no value for existing key');
  end;
  if LValue <> LOtherString then begin 
    Fail('got different value than what was set');
  end;

  if json_object_del(LObject, 'nonexisting') = 0 then begin 
    Fail('able to delete a nonexisting key');
  end;

  if json_object_del(LObject, 'px') <> 0 then begin 
    Fail('unable to delete an existing key');
  end;

  if json_object_del(LObject, 'a') <> 0 then begin 
    Fail('unable to delete an existing key');
  end;

  if json_object_del(LObject, 'lp') <> 0 then begin 
    Fail('unable to delete an existing key');
  end;


  (* add many keys to initiate rehashing *)

  if json_object_set(LObject, 'a', LString) <> 0 then begin 
    Fail('unable to set value');
  end;

  if json_object_set(LObject, 'lp', LString) <> 0 then begin 
    Fail('unable to set value');
  end;

  if json_object_set(LObject, 'px', LString) <> 0 then begin 
    Fail('unable to set value');
  end;

  if json_object_set(LObject, 'c', LString) <> 0 then begin
    Fail('unable to set value');
  end;

  if json_object_set(LObject, 'd', LString) <> 0 then begin 
    Fail('unable to set value');
  end;

  if json_object_set(LObject, 'e', LString) <> 0 then begin 
    Fail('unable to set value');
  end;

  if json_object_set_new(LObject, 'foo', json_integer(123)) <> 0 then begin 
    Fail('unable to set new value');
  end;

  LValue := json_object_get(LObject, 'foo');
  if  (not json_is_integer(LValue)) or (json_integer_value(LValue) <> 123) then begin 
    Fail('json_object_set_new works incorrectly');
  end;

  if json_object_set_new(LObject, nil, json_integer(432)) = 0 then begin 
    Fail('able to set_new NULL key');
  end;

  if json_object_set_new(LObject, 'foo', nil) = 0 then begin 
    Fail('able to set_new NULL value');
  end;

  json_decref(LString);
  json_decref(LOtherString);
  json_decref(LObject);
end;

procedure TTestObject.TestObjectForeach;
var
  LKey: PAnsiChar;
  LObject1: PJson;
  LObject2: PJson;
  LValue: PJson;
begin
  LObject1 := json_pack('{sisisi}', 'foo', 1, 'bar', 2, 'baz', 3);
  LObject2 := json_object();

  LKey := json_object_iter_key(json_object_iter(LObject1));
  while (LKey <> nil) do begin
    LValue := json_object_iter_value(json_object_key_to_iter(LKey));
    if (LValue = nil) then begin
      Break;
    end;

    json_object_set(LObject2, LKey, LValue);
    
    LKey := json_object_iter_key(json_object_iter_next(LObject1, json_object_key_to_iter(LKey)));
  end;  

  if json_equal(LObject1, LObject2) = 0 then begin 
    Fail('json_object_foreach failed to iterate all key-value pairs');
  end;

  json_decref(LObject1);
  json_decref(LObject2);
end;

procedure TTestObject.TestObjectForeachSafe;
var
  LKey: PAnsiChar;
  LTmp: Pointer;
  LObject: PJson;
  LValue: PJson;
begin
  LObject := json_pack('{sisisi}', 'foo', 1, 'bar', 2, 'baz', 3);


  LKey := json_object_iter_key(json_object_iter(LObject));
  LTmp := json_object_iter_next(LObject, json_object_key_to_iter(LKey));
  while (LKey <> nil) do begin
    LValue := json_object_iter_value(json_object_key_to_iter(LKey));
    if (LValue = nil) then begin
      Break;
    end;

    json_object_del(LObject, LKey);

    LKey := json_object_iter_key(LTmp);
    LTmp := json_object_iter_next(LObject, json_object_key_to_iter(LKey));
  end;

  if json_object_size(LObject) <> 0 then begin 
    Fail('json_object_foreach_safe failed to iterate all key-value pairs');
  end;

  json_decref(LObject);
end;

procedure TTestObject.TestPreserveOrder;
var
  LObject: PJson;
  LResult: PAnsiChar;
  LExpected: PAnsiChar;
begin
  LExpected := '{"foobar": 1, "bazquux": 6, "lorem ipsum": 3, "sit amet": 5, "helicopter": 7}';

  LObject := json_object();

  json_object_set_new(LObject, 'foobar', json_integer(1));
  json_object_set_new(LObject, 'bazquux', json_integer(2));
  json_object_set_new(LObject, 'lorem ipsum', json_integer(3));
  json_object_set_new(LObject, 'dolor', json_integer(4));
  json_object_set_new(LObject, 'sit amet', json_integer(5));

  (* changing a value should preserve the order *)
  json_object_set_new(LObject, 'bazquux', json_integer(6));

  (* deletion shouldn't change the order of others *)
  json_object_del(LObject, 'dolor');

  (* add a new item just to make sure *)
  json_object_set_new(LObject, 'helicopter', json_integer(7));

  LResult := json_dumps(LObject, JSON_PRESERVE_ORDER);

  if StrComp(LExpected, LResult) <> 0 then begin
    Fail('JSON_PRESERVE_ORDER doesn''t work');
  end;

  FreeMem(LResult);
  json_decref(LObject);
end;

procedure TTestObject.TestSetManyKeys;
var
  LObject: PJson;
  LValue: PJson;
  LKeys: PAnsiChar;
  LBuf: array[0..1] of AnsiChar;
  I: Integer;
begin
  LKeys := 'abcdefghijklmnopqrstuvwxyz';

  LObject := json_object();
  if LObject = nil then begin
    Fail('unable to create object');
  end;

  LValue := json_string('a');
  if LValue = nil then begin
    Fail('unable to create string');
  end;

  LBuf[1] := Chr(0);
  for I := 0 to StrLen(LKeys) - 1 do begin
    LBuf[0] := LKeys[I];
    if json_object_set(LObject, LBuf, LValue) <> 0 then begin
      Fail('unable to set object key');
    end;
  end;

  json_decref(LObject);
  json_decref(LValue);
end;

procedure TTestObject.TestSetNoCheck;
var
  LObject: PJson;
  LString: PJson;
begin
  LObject := json_object();
  LString := json_string('bar');

  if LObject = nil then begin 
    Fail('unable to create object');
  end;
  if LString = nil then begin 
    Fail('unable to create string');
  end;

  if json_object_set_nocheck(LObject, 'foo', LString) <> 0 then begin 
    Fail('json_object_set_nocheck failed');
  end;
  if json_object_get(LObject, 'foo') <> LString then begin 
    Fail('json_object_get after json_object_set_nocheck failed');
  end;

  (* invalid UTF-8 in key *)
  if json_object_set_nocheck(LObject, 'a' + Chr($EF) + 'z', LString) <> 0 then begin 
    Fail('json_object_set_nocheck failed for invalid UTF-8');
  end;
  if json_object_get(LObject, 'a' + Chr($EF) + 'z') <> LString then begin 
    Fail('json_object_get after json_object_set_nocheck failed');
  end;

  if json_object_set_new_nocheck(LObject, 'bax', json_integer(123)) <> 0 then begin 
    Fail('json_object_set_new_nocheck failed');
  end;
  if json_integer_value(json_object_get(LObject, 'bax')) <> 123 then begin 
    Fail('json_object_get after json_object_set_new_nocheck failed');
  end;

  (* invalid UTF-8 in key *)
  if json_object_set_new_nocheck(LObject, 'asdf' + Chr($FE), json_integer(321)) <> 0 then begin 
    Fail('json_object_set_new_nocheck failed for invalid UTF-8');
  end;
  if json_integer_value(json_object_get(LObject, 'asdf' + Chr($FE))) <> 321 then begin 
    Fail('json_object_get after json_object_set_new_nocheck failed');
  end;

  json_decref(LString);
  json_decref(LObject);
end;

procedure TTestObject.TestUpdate;
var
  LObject: PJson;
  LOther: PJson;
  LNine: PJson;
  LTen: PJson;
begin
  LObject := json_object();
  LOther := json_object();

  LNine := json_integer(9);
  LTen := json_integer(10);

  if (LObject = nil) or (LOther = nil) then begin
    Fail('unable to create object');
  end;
  if (LNine = nil) or (LTen = nil) then begin 
    Fail('unable to create integer');
  end;

  (* update an empty object with an empty object *)

  if json_object_update(LObject, LOther) <> 0 then begin
    Fail('unable to update an empty object with an empty object');
  end;

  if json_object_size(LObject) <> 0 then begin
    Fail('invalid size after update');
  end;

  if json_object_size(LOther) <> 0 then begin
    Fail('invalid size for updater after update');
  end;

  (* update an empty object with a nonempty object *)

  if (json_object_set(LOther, 'a', LTen) <> 0) or (json_object_set(LOther, 'b', LTen) <> 0) or
      (json_object_set(LOther, 'c', LTen) <> 0) or (json_object_set(LOther, 'd', LTen) <> 0) or
      (json_object_set(LOther, 'e', LTen) <> 0) then begin
    Fail('unable to set value');
  end;

  if json_object_update(LObject, LOther) <> 0 then begin
    Fail('unable to update an empty object');
  end;

  if json_object_size(LObject) <> 5 then begin
    Fail('invalid size after update');
  end;

  if (json_object_get(LObject, 'a') <> LTen) or (json_object_get(LObject, 'b') <> LTen) or
      (json_object_get(LObject, 'c') <> LTen) or (json_object_get(LObject, 'd') <> LTen) or
      (json_object_get(LObject, 'e') <> LTen) then begin
    Fail('update works incorrectly');
  end;

  (* perform the same update again *)

  if json_object_update(LObject, LOther) <> 0 then begin
    Fail('unable to update a non-empty object');
  end;

  if json_object_size(LObject) <> 5 then begin
    Fail('invalid size after update');
  end;

  if (json_object_get(LObject, 'a') <> LTen) or (json_object_get(LObject, 'b') <> LTen) or
      (json_object_get(LObject, 'c') <> LTen) or (json_object_get(LObject, 'd') <> LTen) or
      (json_object_get(LObject, 'e') <> LTen) then begin
    Fail('update works incorrectly');
  end;

  (* update a nonempty object with a nonempty object with both old
   and new keys *)

  if json_object_clear(LOther) <> 0 then begin
    Fail('clear failed');
  end;

  if (json_object_set(LOther, 'a', LNine) <> 0) or (json_object_set(LOther, 'b', LNine) <> 0) or
      (json_object_set(LOther, 'f', LNine) <> 0) or (json_object_set(LOther, 'g', LNine) <> 0) or
      (json_object_set(LOther, 'h', LNine) <> 0) then begin
    Fail('unable to set value');
  end;

  if json_object_update(LObject, LOther) <> 0 then begin
    Fail('unable to update a nonempty object');
  end;

  if json_object_size(LObject) <> 8 then begin
    Fail('invalid size after update');
  end;

  if (json_object_get(LObject, 'a') <> LNine) or (json_object_get(LObject, 'b') <> LNine) or
      (json_object_get(LObject, 'f') <> LNine) or (json_object_get(LObject, 'g') <> LNine) or
      (json_object_get(LObject, 'h') <> LNine) then begin
    Fail('update works incorrectly');
  end;

  json_decref(LNine);
  json_decref(LTen);
  json_decref(LOther);
  json_decref(LObject);
end;

initialization
  RegisterTest(TTestObject.Suite);

end.
