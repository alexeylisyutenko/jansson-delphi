unit TestNumber;

interface

uses
  TestFramework;

type
  TTestNumber= class(TTestCase)
  published
    procedure TestBadArgs;
    procedure TestNumber;
  end;

implementation

uses
  Jansson, Math;

{ TTestNumber }

procedure TTestNumber.TestBadArgs;
var
  LTxt: PJson;
begin
  LTxt := json_string('test');

  if json_integer_value(nil) <> 0 then begin
    Fail('json_integer_value did not return 0 for non-integer');
  end;
  if json_integer_value(LTxt) <> 0 then begin
    Fail('json_integer_value did not return 0 for non-integer');
  end;

  if json_integer_set(nil, 0) = 0 then begin
    Fail('json_integer_set did not return error for non-integer');
  end;
  if json_integer_set(LTxt, 0) = 0 then begin
    Fail('json_integer_set did not return error for non-integer');
  end;

  if json_real_value(nil) <> 0.0 then begin
    Fail('json_real_value did not return 0.0 for non-real');
  end;
  if json_real_value(LTxt) <> 0.0 then begin
    Fail('json_real_value did not return 0.0 for non-real');
  end;

  if json_real_set(nil, 0.0) = 0 then begin
    Fail('json_real_set did not return error for non-real');
  end;
  if json_real_set(LTxt, 0.0) = 0 then begin
    Fail('json_real_set did not return error for non-real');
  end;

  if json_number_value(nil) <> 0.0 then begin
    Fail('json_number_value did not return 0.0 for non-numeric');
  end;
  if json_number_value(LTxt) <> 0.0 then begin
    Fail('json_number_value did not return 0.0 for non-numeric');
  end;

  if LTxt.refcount <> 1 then begin
    Fail('unexpected reference count for txt');
  end;

  json_decref(LTxt);
end;

procedure TTestNumber.TestNumber;
var
  LInteger: PJson;
  LReal: PJson;
  i: TJsonInt;
  d: Double;
begin
  LInteger := json_integer(5);
  LReal := json_real(100.1);

  if LInteger = nil then begin
    Fail('unable to create integer');
  end;
  if LReal = nil then begin
    Fail('unable to create real');
  end;

  i := json_integer_value(LInteger);
  if i <> 5 then begin 
    Fail('wrong integer value');
  end;

  d := json_real_value(LReal);
  if CompareValue(d, 100.1, 0.0000001) <> 0 then begin
    Fail('wrong real value');
  end;

  d := json_number_value(LInteger);
  if CompareValue(d, 5.0, 0.0000001) <> 0 then begin
    Fail('wrong number value');
  end;
  d := json_number_value(LReal);
  if CompareValue(d, 100.1, 0.0000001) <> 0 then begin
    Fail('wrong number value');
  end;

  json_decref(LInteger);
  json_decref(LReal);
end;

initialization
  RegisterTest(TTestNumber.Suite);

end.
