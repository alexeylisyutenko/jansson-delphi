unit Util;

interface

uses
  Jansson, TestFramework;

procedure check_errors(AError: PJsonError; ACode: TJsonErrorCode; ATexts: array of PAnsiChar;
  ASource: PAnsiChar; ALine: Integer; AColumn: Integer; APosition: Integer);

procedure check_error(AError: PJsonError; ACode: TJsonErrorCode; AText: PAnsiChar;
  ASource: PAnsiChar; ALine: Integer; AColumn: Integer; APosition: Integer);

implementation

uses
  SysUtils;

procedure check_errors(AError: PJsonError; ACode: TJsonErrorCode; ATexts: array of PAnsiChar;
  ASource: PAnsiChar; ALine: Integer; AColumn: Integer; APosition: Integer);
var
  LNum: Integer;
  LFound: Boolean;
  I: Integer;
begin
  if json_error_code(AError) <> ACode then begin
    raise ETestFailure.Create(Format('code: %d != %d', [Ord(json_error_code(AError)), Ord(ACode)])) at CallerAddr;
  end;
  LNum := Length(ATexts);
  LFound := False;
  for I := Low(ATexts) to High(ATexts) do begin
    if StrComp(AError.text, ATexts[I]) = 0 then begin
      LFound := True;
      Break;
    end;
  end;
  if not LFound then begin
    if LNum = 1 then begin
      raise ETestFailure.Create(Format('text: \"%s\" != \"%s\"', [AError.text, ATexts[0]])) at CallerAddr;
    end else begin
      raise ETestFailure.Create(Format('text: \"%s\" does not match', [AError.text])) at CallerAddr;
    end;
  end;
  if StrComp(AError.source, ASource) <> 0 then begin
    raise ETestFailure.Create(Format('source: \"%s\" != \"%s\"', [AError.source, ASource])) at CallerAddr;
  end;
  if AError.line <> ALine then begin
    raise ETestFailure.Create(Format('line: %d != %d', [AError.line, ALine])) at CallerAddr;
  end;
  if AError.column <> AColumn then begin
    raise ETestFailure.Create(Format('column: %d != %d', [AError.column, AColumn])) at CallerAddr;
  end;
  if AError.position <> APosition then begin
    raise ETestFailure.Create(Format('position: %d != %d', [AError.position, APosition])) at CallerAddr;
  end;
end;

procedure check_error(AError: PJsonError; ACode: TJsonErrorCode; AText: PAnsiChar;
  ASource: PAnsiChar; ALine: Integer; AColumn: Integer; APosition: Integer);
begin
  check_errors(AError, ACode, [AText], ASource, ALine, AColumn, APosition);
end;

end.
