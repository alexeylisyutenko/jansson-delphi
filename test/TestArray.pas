unit TestArray;

interface

uses
  TestFramework;

type
  TTestArray = class(TTestCase)
  published
    procedure TestMisc;
    procedure TestInsert;
    procedure TestRemove;
    procedure TestClear;
    procedure TestExtend;
    procedure TestCircular;
    procedure TestArrayForeach;
    procedure TestBadArgs;
  end;

implementation

uses
  Jansson;

procedure TTestArray.TestArrayForeach;
var
  LArray1: PJson;
  LArray2: PJson;
  LValue: PJson;
  LIndex: Integer;
begin
  LArray1 := json_pack('[sisisi]', 'foo', 1, 'bar', 2, 'baz', 3);
  LArray2 := json_array();

  // replacement loop for json_array_foreach macros
  LIndex := 0;
  while LIndex < json_array_size(LArray1) do begin
    LValue := json_array_get(LArray1, LIndex);
    if (LValue = nil) then begin
    Break;
    end;

    // action
    json_array_append(LArray2, LValue);

    Inc(LIndex);
  end;

  if json_equal(LArray1, LArray2) = 0 then begin
    Fail('json_array_foreach failed to iterate all elements');
  end;

  json_decref(LArray1);
  json_decref(LArray2);
end;

procedure TTestArray.TestBadArgs;
var
  LArr: PJson;
  LNum: PJson;
begin
  LArr := json_array();
  LNum := json_integer(1);

  if (LArr = nil) or (LNum = nil) then begin
    Fail('failed to create required objects');
  end;

  if json_array_size(nil) <> 0 then begin
    Fail('NULL array has nonzero size');
  end;
  if json_array_size(LNum) <> 0 then begin
    Fail('non-array has nonzero array size');
  end;

  if json_array_get(nil, 0) <> nil then begin
    Fail('json_array_get did not return NULL for non-array');
  end;
  if json_array_get(LNum, 0) <> nil then begin
    Fail('json_array_get did not return NULL for non-array');
  end;

  if json_array_set_new(nil, 0, json_incref(LNum)) = 0 then begin
    Fail('json_array_set_new did not return error for non-array');
  end;
  if json_array_set_new(LNum, 0, json_incref(LNum)) = 0 then begin
    Fail('json_array_set_new did not return error for non-array');
  end;
  if json_array_set_new(LArr, 0, nil) = 0 then begin
    Fail('json_array_set_new did not return error for NULL value');
  end;
  if json_array_set_new(LArr, 0, json_incref(LArr)) = 0 then begin
    Fail('json_array_set_new did not return error for value == array');
  end;

  if json_array_remove(nil, 0) = 0 then begin
    Fail('json_array_remove did not return error for non-array');
  end;
  if json_array_remove(LNum, 0) = 0 then begin
    Fail('json_array_remove did not return error for non-array');
  end;

  if json_array_clear(nil) = 0 then begin
    Fail('json_array_clear did not return error for non-array');
  end;
  if json_array_clear(LNum) = 0 then begin
    Fail('json_array_clear did not return error for non-array');
  end;

  if json_array_append_new(nil, json_incref(LNum)) = 0 then begin
    Fail('json_array_append_new did not return error for non-array');
  end;
  if json_array_append_new(LNum, json_incref(LNum)) = 0 then begin
    Fail('json_array_append_new did not return error for non-array');
  end;
  if json_array_append_new(LArr, nil) = 0 then begin
    Fail('json_array_append_new did not return error for NULL value');
  end;
  if json_array_append_new(LArr, json_incref(LArr)) = 0 then begin
    Fail('json_array_append_new did not return error for value == array');
  end;

  if json_array_insert_new(nil, 0, json_incref(LNum)) = 0 then begin
    Fail('json_array_insert_new did not return error for non-array');
  end;
  if json_array_insert_new(LNum, 0, json_incref(LNum)) = 0 then begin
    Fail('json_array_insert_new did not return error for non-array');
  end;
  if json_array_insert_new(LArr, 0, nil) = 0 then begin
    Fail('json_array_insert_new did not return error for NULL value');
  end;
  if json_array_insert_new(LArr, 0, json_incref(LArr)) = 0 then begin
    Fail('json_array_insert_new did not return error for value == array');
  end;

  if json_array_extend(nil, LArr) = 0 then begin
    Fail('json_array_extend did not return error for first argument '
          +'non-array');
  end;
  if json_array_extend(LNum, LArr) = 0 then begin
    Fail('json_array_extend did not return error for first argument '
          +'non-array');
  end;
  if json_array_extend(LArr, nil) = 0 then begin
    Fail('json_array_extend did not return error for second argument '
          +'non-array');
  end;
  if json_array_extend(LArr, LNum) = 0 then begin
    Fail('json_array_extend did not return error for second argument '
          +'non-array');
  end;

  if LNum.refcount <> 1 then begin
    Fail('unexpected reference count on num');
  end;
  if LArr.refcount <> 1 then begin
    Fail('unexpected reference count on arr');
  end;

  json_decref(LNum);
  json_decref(LArr);
end;

procedure TTestArray.TestCircular;
var
  LArray1: PJson;
  LArray2: PJson;
begin
  (* the simple cases are checked *)
  LArray1 := json_array();
  if LArray1 = nil then begin
    Fail('unable to create array');
  end;

  if json_array_append(LArray1, LArray1) = 0 then begin
    Fail('able to append self');
  end;

  if json_array_insert(LArray1, 0, LArray1) = 0 then begin
    Fail('able to insert self');
  end;

  if json_array_append_new(LArray1, json_true()) <> 0 then begin
    Fail('failed to append true');
  end;

  if json_array_set(LArray1, 0, LArray1) = 0 then begin
    Fail('able to set self');
  end;

  json_decref(LArray1);

  (* create circular references *)

  LArray1 := json_array();
  LArray2 := json_array();
  if (LArray1 = nil) or (LArray2 = nil) then begin
    Fail('unable to create array');
  end;

  if (json_array_append(LArray1, LArray2) <> 0) or (json_array_append(LArray2, LArray1) <> 0) then begin
    Fail('unable to append');
  end;

  (* circularity is detected when dumping *)
  if json_dumps(LArray1, 0) <> nil then begin
    Fail('able to dump circulars');
  end;

  (* decref twice to deal with the circular references *)
  json_decref(LArray1);
  json_decref(LArray2);
  json_decref(LArray1);
end;

procedure TTestArray.TestClear;
var
  LArray: PJson;
  LFive: PJson;
  LSeven: PJson;
  I: Integer;
begin
  LArray := json_array();
  LFive := json_integer(5);
  LSeven := json_integer(7);

  if LArray = nil then begin
    Fail('unable to create array');
  end;
  if (LFive = nil) or (LSeven = nil) then begin
    Fail('unable to create integer');
  end;

  for I := 0 to 9 do begin
    if json_array_append(LArray, LFive) <> 0 then begin
      Fail('unable to append');
    end;
  end;
  for I := 0 to 9 do begin
    if json_array_append(LArray, LSeven) <> 0 then begin
      Fail('unable to append');
    end;
  end;

  if json_array_size(LArray) <> 20 then begin
    Fail('array size is invalid after appending');
  end;

  if json_array_clear(LArray) <> 0 then begin
    Fail('unable to clear');
  end;

  if json_array_size(LArray) <> 0 then begin
    Fail('array size is invalid after clearing');
  end;

  json_decref(LFive);
  json_decref(LSeven);
  json_decref(LArray);
end;

procedure TTestArray.TestExtend;
var
  LArray1: PJson;
  LArray2: PJson;
  LFive: PJson;
  LSeven: PJson;
  I: Integer;
begin
  LArray1 := json_array();
  LArray2 := json_array();
  LFive := json_integer(5);
  LSeven := json_integer(7);

  if  (LArray1 = nil) or (LArray2 = nil) then begin
    Fail('unable to create array');
  end;
  if (LFive = nil) or (LSeven = nil) then begin
    Fail('unable to create integer');
  end;

  for I := 0 to 9 do begin
    if json_array_append(LArray1, LFive) <> 0 then begin
      Fail('unable to append');
    end;
  end;
  for I := 0 to 9 do  begin
    if json_array_append(LArray2, LSeven) <> 0 then begin
      Fail('unable to append');
    end;
  end;

  if (json_array_size(LArray1) <> 10) or (json_array_size(LArray2) <> 10) then begin
    Fail('array size is invalid after appending');
  end;

  if json_array_extend(LArray1, LArray2) <> 0 then begin
    Fail('unable to extend');
  end;

  for I := 0 to 9 do  begin
    if json_array_get(LArray1, i) <> LFive then begin
      Fail('invalid array contents after extending');
    end;
  end;
  for I := 10 to 19 do begin
    if json_array_get(LArray1, i) <> LSeven then begin
      Fail('invalid array contents after extending');
    end;
  end;

  json_decref(LFive);
  json_decref(LSeven);
  json_decref(LArray1);
  json_decref(LArray2);
end;

procedure TTestArray.TestInsert;
var
  LArray: PJson;
  LFive: PJson;
  LSeven: PJson;
  LEleven: PJson;
  LValue: PJson;
  I: Integer;
begin
  LArray := json_array;
  LFive := json_integer(5);
  LSeven := json_integer(7);
  LEleven := json_integer(11);

  if LArray = nil then begin
    Fail('unable to create array');
  end;
  if (LFive = nil) or (LSeven = nil) or (LEleven = nil) then begin
    Fail('unable to create integer');
  end;

  if json_array_insert(LArray, 1, LFive) = 0 then begin
  Fail('able to insert value out of bounds');
  end;

  if json_array_insert(LArray, 0, LFive) <> 0 then begin
    Fail('unable to insert value in an empty array');
  end;

  if json_array_get(LArray, 0) <> LFive then begin
    Fail('json_array_insert works incorrectly');
  end;

  if json_array_size(LArray) <> 1 then begin
    Fail('array size is invalid after insertion');
  end;

  if json_array_insert(LArray, 1, LSeven) <> 0 then begin
    Fail('unable to insert value at the end of an array');
  end;

  if json_array_get(LArray, 0) <> LFive then begin
    Fail('json_array_insert works incorrectly');
  end;

  if json_array_get(LArray, 1) <> LSeven then begin
    Fail('json_array_insert works incorrectly');
  end;

  if json_array_size(LArray) <> 2 then begin
    Fail('array size is invalid after insertion');
  end;

  if json_array_insert(LArray, 1, LEleven) <> 0 then begin
    Fail('unable to insert value in the middle of an array');
  end;

  if json_array_get(LArray, 0) <> LFive then begin
    Fail('json_array_insert works incorrectly');
  end;

  if json_array_get(LArray, 1) <> LEleven then begin
    Fail('json_array_insert works incorrectly');
  end;

  if json_array_get(LArray, 2) <> LSeven then begin
    Fail('json_array_insert works incorrectly');
  end;

  if json_array_size(LArray) <> 3 then begin
    Fail('array size is invalid after insertion');
  end;

  if json_array_insert_new(LArray, 2, json_integer(123)) <> 0 then begin
    Fail('unable to insert value in the middle of an array');
  end;

  LValue := json_array_get(LArray, 2);
  if (not json_is_integer(LValue)) or (json_integer_value(LValue) <> 123) then begin
    Fail('json_array_insert_new works incorrectly');
  end;

  if json_array_size(LArray) <> 4 then begin
    Fail('array size is invalid after insertion');
  end;

  for I := 0 to 19 do begin
    if json_array_insert(LArray, 0, LSeven) <> 0 then begin
      Fail('unable to insert value at the beginning of an array');
    end
  end;

  for I := 0 to 19 do begin
    if json_array_get(LArray, I) <> LSeven then begin
      Fail('json_aray_insert works incorrectly');
    end
  end;

  if json_array_size(LArray) <> 24 then begin
    Fail('array size is invalid after loop insertion');
  end;

  json_decref(LFive);
  json_decref(LSeven);
  json_decref(LEleven);
  json_decref(LArray);
end;

procedure TTestArray.TestMisc;
var
  LArray: PJson;
  LFive: PJson;
  LSeven: PJson;
  LValue: PJson;
  I: Integer;
begin
  LArray := json_array();
  LFive := json_integer(5);
  LSeven := json_integer(7);

  if LArray = nil then begin
    Fail('unable to create array');
  end;
  if (LFive = nil) or (LSeven = nil)then begin
    Fail('unable to create integer');
  end;

  if json_array_size(LArray) <> 0 then begin
    Fail('empty array has nonzero size');
  end;

  if json_array_append(LArray, nil) = 0 then begin
    Fail('able to append NULL');
  end;

  if json_array_append(LArray, LFive) <> 0 then begin
    Fail('unable to append');
  end;

  if json_array_size(LArray) <> 1 then begin
    Fail('wrong array size');
  end;

  LValue := json_array_get(LArray, 0);
  if LValue = nil then begin
    Fail('unable to get item');
  end;
  if LValue <> LFive then begin
    Fail('got wrong value');
  end;

  if json_array_append(LArray, LSeven) <> 0 then begin
    Fail('unable to append value');
  end;

  if json_array_size(LArray) <> 2 then begin
    Fail('wrong array size');
  end;

  LValue := json_array_get(LArray, 1);
  if LValue = nil then begin
    Fail('unable to get item');
  end;
  if LValue <> LSeven then begin
    Fail('got wrong value');
  end;

  if json_array_set(LArray, 0, LSeven) <> 0 then begin
    Fail('unable to set value');
  end;

  if json_array_set(LArray, 0, nil) = 0 then begin
    Fail('able to set NULL');
  end;

  if json_array_size(LArray) <> 2 then begin
    Fail('wrong array size');
  end;

  LValue := json_array_get(LArray, 0);
  if LValue = nil then begin
    Fail('unable to get item');
  end;
  if LValue <> LSeven then begin
    Fail('got wrong value');
  end;

  if json_array_get(LArray, 2) <> nil then begin
    Fail('able to get value out of bounds');
  end;

  if json_array_set(LArray, 2, LSeven) = 0 then begin
    Fail('able to set value out of bounds');
  end;

  for I := 2 to 29 do begin
    if json_array_append(LArray, LSeven) <> 0 then begin
      Fail('unable to append value');
    end;

    if json_array_size(LArray) <> I + 1 then begin
      Fail('wrong array size');
    end;
  end;

  for I := 0 to 29 do begin
    LValue := json_array_get(LArray, I);
    if LValue = nil then begin
      Fail('unable to get item');
    end;
    if LValue <> LSeven then begin
      Fail('got wrong value');
    end;
  end;

  if json_array_set_new(LArray, 15, json_integer(123)) <> 0 then begin
    Fail('unable to set new value');
  end;

  LValue := json_array_get(LArray, 15);
  if (not json_is_integer(LValue)) or (json_integer_value(LValue) <> 123) then begin
    Fail('json_array_set_new works incorrectly');
  end;

  if json_array_set_new(LArray, 15, nil) = 0 then begin
    Fail('able to set_new NULL value');
  end;

  if json_array_append_new(LArray, json_integer(321)) <> 0 then begin
    Fail('unable to append new value');
  end;

  LValue := json_array_get(LArray, json_array_size(LArray) - 1);
  if (not json_is_integer(LValue)) or (json_integer_value(LValue) <> 321) then begin
    Fail('json_array_append_new works incorrectly');
  end;

  if json_array_append_new(LArray, nil) = 0 then begin
    Fail('able to append_new NULL value');
  end;

  json_decref(LFive);
  json_decref(LSeven);
  json_decref(LArray);
end;

procedure TTestArray.TestRemove;
var
  LArray: PJson;
  LFive: PJson;
  LSeven: PJson;
  I: Integer;
begin
  LArray := json_array;
  LFive := json_integer(5);
  LSeven := json_integer(7);

  if LArray = nil then begin
    Fail('unable to create array');
  end;
  if LFive = nil then begin
    Fail('unable to create integer');
  end;
  if LSeven = nil then begin
    Fail('unable to create integer');
  end;

  if json_array_remove(LArray, 0) = 0 then begin
    Fail('able to remove an unexisting index');
  end;

  if json_array_append(LArray, LFive) <> 0 then begin
    Fail('unable to append');
  end;

  if json_array_remove(LArray, 1) = 0 then begin
    Fail('able to remove an unexisting index');
  end;

  if json_array_remove(LArray, 0) <> 0 then begin
    Fail('unable to remove');
  end;

  if json_array_size(LArray) <> 0 then begin
    Fail('array size is invalid after removing');
  end;

  if (json_array_append(LArray, LFive) <> 0) or (json_array_append(LArray, LSeven) <> 0) or
        (json_array_append(LArray, LFive) <> 0) or (json_array_append(LArray, LSeven) <> 0) then begin
    Fail('unable to append');
  end;

  if json_array_remove(LArray, 2) <> 0 then begin
  Fail('unable to remove');
  end;

  if json_array_size(LArray) <> 3 then begin
    Fail('array size is invalid after removing');
  end;

  if (json_array_get(LArray, 0) <> LFive) or (json_array_get(LArray, 1) <> LSeven) or
        (json_array_get(LArray, 2) <> LSeven) then begin
    Fail('remove works incorrectly');
  end;

  json_decref(LArray);

  LArray := json_array();
  for I := 0 to 3 do begin
    json_array_append(LArray, LFive);
    json_array_append(LArray, LSeven);
  end;

  if json_array_size(LArray) <> 8 then begin
    Fail('unable to append 8 items to array');
  end;

  (* Remove an element from a "full" array. *)
  json_array_remove(LArray, 5);

  json_decref(LFive);
  json_decref(LSeven);
  json_decref(LArray);
end;

initialization
  RegisterTest(TTestArray.Suite);
end.

