unit TestEqual;

interface

uses
  TestFramework;

type
  TTestEqual = class(TTestCase)
  published
    procedure TestEqualSimple;
    procedure TestEqualArray;
    procedure TestEqualObject;
    procedure TestEqualComplex;
  end;

implementation

uses
  Jansson, Math, SysUtils, Util, Dialogs;
  
{ TTestEqual }

procedure TTestEqual.TestEqualArray;
var
  LArray1: PJson;
  LArray2: PJson;
begin
  LArray1 := json_array();
  LArray2 := json_array();
  if (LArray1 = nil) or (LArray2 = nil) then begin
    Fail('unable to create arrays');
  end;
  if json_equal(LArray1, LArray2) = 0 then begin
    Fail('json_equal fails for two empty arrays');
  end;

  json_array_append_new(LArray1, json_integer(1));
  json_array_append_new(LArray2, json_integer(1));
  json_array_append_new(LArray1, json_string('foo'));
  json_array_append_new(LArray2, json_string('foo'));
  json_array_append_new(LArray1, json_integer(2));
  json_array_append_new(LArray2, json_integer(2));
  if json_equal(LArray1, LArray2) = 0 then begin
    Fail('json_equal fails for two equal arrays');
  end;

  json_array_remove(LArray2, 2);
  if json_equal(LArray1, LArray2) <> 0 then begin
    Fail('json_equal fails for two inequal arrays');
  end;

  json_array_append_new(LArray2, json_integer(3));
  if json_equal(LArray1, LArray2) <> 0 then begin
    Fail('json_equal fails for two inequal arrays');
  end;

  json_decref(LArray1);
  json_decref(LArray2);
end;

procedure TTestEqual.TestEqualComplex;
var
  value1: PJson;
  value2: PJson;
  value3: PJson;
  complex_json: PAnsiChar;
begin
  complex_json := '{'
                 +'    "integer": 1, '
                 +'    "real": 3.141592, '
                 +'    "string": "foobar", '
                 +'    "true": true, '
                 +'    "object": {'
                 +'        "array-in-object": [1,true,"foo",{}],'
                 +'        "object-in-object": {"foo": "bar"}'
                 +'    },'
                 +'    "array": ["foo", false, null, 1.234]'
                 +'}';

  value1 := json_loads(complex_json, 0, nil);
  value2 := json_loads(complex_json, 0, nil);
  value3 := json_loads(complex_json, 0, nil);
  if (value1 = nil) or (value2 = nil) then begin
    Fail('unable to parse JSON');
  end;
  if json_equal(value1, value2) = 0 then begin
    Fail('json_equal fails for two equal objects');
  end;

  json_array_set_new(
      json_object_get(json_object_get(value2, 'object'), 'array-in-object'), 1,
      json_false());
  if json_equal(value1, value2) <> 0 then begin
    Fail('json_equal fails for two inequal objects');
  end;

  json_object_set_new(
      json_object_get(json_object_get(value3, 'object'), 'object-in-object'), 'foo',
      json_string('baz'));
  if json_equal(value1, value3) <> 0 then begin
    Fail('json_equal fails for two inequal objects');
  end;

  json_decref(value1);
  json_decref(value2);
  json_decref(value3);
end;

procedure TTestEqual.TestEqualObject;
var
  LObject1: PJson;
  LObject2: PJson;
begin
  LObject1 := json_object();
  LObject2 := json_object();
  if (LObject1 = nil) or (LObject2 = nil) then begin
    Fail('unable to create objects');
  end;

  if json_equal(LObject1, LObject2) = 0 then begin
    Fail('json_equal fails for two empty objects');
  end;

  json_object_set_new(LObject1, 'a', json_integer(1));
  json_object_set_new(LObject2, 'a', json_integer(1));
  json_object_set_new(LObject1, 'b', json_string('foo'));
  json_object_set_new(LObject2, 'b', json_string('foo'));
  json_object_set_new(LObject1, 'c', json_integer(2));
  json_object_set_new(LObject2, 'c', json_integer(2));
  if  json_equal(LObject1, LObject2) = 0 then begin
    Fail('json_equal fails for two equal objects');
  end;

  json_object_del(LObject2, 'c');
  if json_equal(LObject1, LObject2) <> 0 then begin
    Fail('json_equal fails for two inequal objects');
  end;

  json_object_set_new(LObject2, 'c', json_integer(3));
  if json_equal(LObject1, LObject2) <> 0 then begin
    Fail('json_equal fails for two inequal objects');
  end;

  json_object_del(LObject2, 'c');
  json_object_set_new(LObject2, 'd', json_integer(2));
  if json_equal(LObject1, LObject2) <> 0 then begin
    Fail('json_equal fails for two inequal objects');
  end;

  json_decref(LObject1);
  json_decref(LObject2);
end;

procedure TTestEqual.TestEqualSimple;
var
  LValue1: PJson;
  LValue2: PJson;
begin
  if json_equal(nil, nil) <> 0 then begin
    Fail('json_equal fails for two NULLs');
  end;

  LValue1 := json_true();
  if (json_equal(LValue1, nil) <> 0) or (json_equal(nil, LValue1) <> 0) then begin
    Fail('json_equal fails for NULL');
  end;

  (* this covers true, false and null as they are singletons *)
  if json_equal(LValue1, LValue1) = 0 then begin
    Fail('identical objects are not equal');
  end;
  json_decref(LValue1);

  (* integer *)
  LValue1 := json_integer(1);
  LValue2 := json_integer(1);
  if (LValue1 = nil) or (LValue2 = nil) then begin
    Fail('unable to create integers');
  end;
  if json_equal(LValue1, LValue2) = 0 then begin
    Fail('json_equal fails for two equal integers');
  end;
  json_decref(LValue2);

  LValue2 := json_integer(2);
  if LValue2 = nil then begin
    Fail('unable to create an integer');
  end;
  if json_equal(LValue1, LValue2) <> 0 then begin
    Fail('json_equal fails for two inequal integers');
  end;

  json_decref(LValue1);
  json_decref(LValue2);

  (* real *)
  LValue1 := json_real(1.2);
  LValue2 := json_real(1.2);
  if (LValue1 = nil) or (LValue2 = nil) then begin
    Fail('unable to create reals');
  end;
  if json_equal(LValue1, LValue2) = 0 then begin
    Fail('json_equal fails for two equal reals');
  end;
  json_decref(LValue2);

  LValue2 := json_real(3.141592);
  if LValue2 = nil then begin
    Fail('unable to create an real');
  end;
  if json_equal(LValue1, LValue2) <> 0 then begin
    Fail('json_equal fails for two inequal reals');
  end;

  json_decref(LValue1);
  json_decref(LValue2);

  (* string *)
  LValue1 := json_string('foo');
  LValue2 := json_string('foo');
  if  (LValue1 = nil) or (LValue2 = nil) then begin
    Fail('unable to create strings');
  end;
  if json_equal(LValue1, LValue2) = 0 then begin
    Fail('json_equal fails for two equal strings');
  end;
  json_decref(LValue2);

  LValue2 := json_string('bar');
  if LValue2 =nil then begin
    Fail('unable to create an string');
  end;
  if json_equal(LValue1, LValue2) <> 0 then begin
    Fail('json_equal fails for two inequal strings');
  end;
  json_decref(LValue2);

  LValue2 := json_string('bar2');
  if LValue2 = nil then begin
    Fail('unable to create an string');
  end;
  if json_equal(LValue1, LValue2) <> 0 then begin
    Fail('json_equal fails for two inequal length strings');
  end;

  json_decref(LValue1);
  json_decref(LValue2);
end;

initialization
  RegisterTest(TTestEqual.Suite);

end.
