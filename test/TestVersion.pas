unit TestVersion;

interface

uses
  TestFramework;

type
  TTestVersion = class(TTestCase)
  published
    procedure TestVersionStr;
    procedure TestVersionCmp;
  end;

implementation

uses
  Jansson, SysUtils;

{ TTestVersion }

procedure TTestVersion.TestVersionCmp;
begin
  if jansson_version_cmp(JANSSON_MAJOR_VERSION, JANSSON_MINOR_VERSION,
                          JANSSON_MICRO_VERSION) <> 0 then begin
    Fail('jansson_version_cmp equality check failed');
  end;

  if jansson_version_cmp(JANSSON_MAJOR_VERSION - 1, 0, 0) <= 0 then begin
      Fail('jansson_version_cmp less than check failed');
  end;

  if JANSSON_MINOR_VERSION <> 0 then begin
      if jansson_version_cmp(JANSSON_MAJOR_VERSION, JANSSON_MINOR_VERSION - 1,
                              JANSSON_MICRO_VERSION) <= 0 then begin
        Fail('jansson_version_cmp less than check failed');
      end; 
  end;

  if JANSSON_MICRO_VERSION <> 0 then begin
      if jansson_version_cmp(JANSSON_MAJOR_VERSION, JANSSON_MINOR_VERSION,
                              JANSSON_MICRO_VERSION - 1) <= 0 then begin
        Fail('jansson_version_cmp less than check failed');
      end;
  end;

  if jansson_version_cmp(JANSSON_MAJOR_VERSION + 1, JANSSON_MINOR_VERSION,
                          JANSSON_MICRO_VERSION) >= 0 then begin
    Fail('jansson_version_cmp greater than check failed');
  end;

  if jansson_version_cmp(JANSSON_MAJOR_VERSION, JANSSON_MINOR_VERSION + 1,
                          JANSSON_MICRO_VERSION) >= 0 then begin
    Fail('jansson_version_cmp greater than check failed');
  end;

  if jansson_version_cmp(JANSSON_MAJOR_VERSION, JANSSON_MINOR_VERSION,
                          JANSSON_MICRO_VERSION + 1) >= 0 then begin
    Fail('jansson_version_cmp greater than check failed');
  end;
end;

procedure TTestVersion.TestVersionStr;
begin
  if StrComp(jansson_version_str(), JANSSON_VERSION) <> 0 then begin
    Fail('jansson_version_str returned invalid version string');
  end;
end;

initialization
  RegisterTest(TTestVersion.Suite);

end.
