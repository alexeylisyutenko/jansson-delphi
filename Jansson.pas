unit Jansson;

{$ALIGN ON}
{$Z+}

interface

const
  libjansson = 'libjansson.dll';

type
  va_list = Pointer;
  psize_t = ^size_t;
  size_t = Cardinal;

  
(* version *)

const
  JANSSON_MAJOR_VERSION = 2;
  JANSSON_MINOR_VERSION = 13;
  JANSSON_MICRO_VERSION = 1;

(* Micro version is omitted if it's 0 *)
JANSSON_VERSION: PAnsiChar = '2.13.1';

(* Version as a 3-byte hex number, e.g. 0x010201 == 1.2.1. Use this
   for numeric comparisons, e.g. #if JANSSON_VERSION_HEX >= ... *)
JANSSON_VERSION_HEX = (JANSSON_MAJOR_VERSION shl 16) or (JANSSON_MINOR_VERSION shl 8)
                      or (JANSSON_MICRO_VERSION shl 0);

(* types *)

type
  TJsonType = (
    JSON_OBJECT_T,
    JSON_ARRAY_T,
    JSON_STRING_T,
    JSON_INTEGER_T,
    JSON_REAL_T,
    JSON_TRUE_T,
    JSON_FALSE_T,
    JSON_NULL_T
  );

  PJson = ^TJson;
  TJson = record
    _type: TJsonType;
    refcount: size_t;
  end;

  TJsonInt = Int64;


(* some macros definitions *)

function json_typeof(json: PJson): TJsonType;
function json_is_object(json: PJson): Boolean;
function json_is_array(json: PJson): Boolean;
function json_is_string(json: PJson): Boolean;
function json_is_integer(json: PJson): Boolean;
function json_is_real(json: PJson): Boolean;
function json_is_number(json: PJson): Boolean;
function json_is_true(json: PJson): Boolean;
function json_is_false(json: PJson): Boolean;
function json_boolean_value(json: PJson): Integer;
function json_is_boolean(json: PJson): Boolean;
function json_is_null(json: PJson): Boolean;


(* construction, destruction, reference counting *)

function json_object: PJson; cdecl; external libjansson;
function json_array: PJson; cdecl; external libjansson;
function json_string(value: PAnsiChar): PJson; cdecl; external libjansson;
function json_stringn(value: PAnsiChar; len: size_t): PJson; cdecl; external libjansson;
function json_string_nocheck(value: PAnsiChar): PJson; cdecl; external libjansson;
function json_stringn_nocheck(value: PAnsiChar; len: size_t): PJson; cdecl; external libjansson;
function json_integer(value: TJsonInt): PJson; cdecl; external libjansson;
function json_real(value: Double): PJson; cdecl; external libjansson;
function json_true: PJson; cdecl; external libjansson;
function json_false: PJson; cdecl; external libjansson;
function json_boolean(val: Boolean): PJson; overload;
function json_boolean(val: Integer): PJson; overload;
function json_null: PJson; cdecl; external libjansson;
function json_incref(json: PJson): PJson;

(* do not call json_delete directly *)
procedure json_delete(json: PJson); cdecl; external libjansson;
procedure json_decref(json: PJson);


(* error reporting *)

const
  JSON_ERROR_TEXT_LENGTH = 160;
  JSON_ERROR_SOURCE_LENGTH = 80;

type
  PJsonError = ^TJsonError;
  TJsonError = record
    line: Integer;
    column: Integer;
    position: Integer;
    source: array[0..JSON_ERROR_SOURCE_LENGTH - 1] of AnsiChar;
    text: array[0..JSON_ERROR_TEXT_LENGTH - 1] of AnsiChar;
  end;

  TJsonErrorCode = (
    json_error_unknown,
    json_error_out_of_memory,
    json_error_stack_overflow,
    json_error_cannot_open_file,
    json_error_invalid_argument,
    json_error_invalid_utf8,
    json_error_premature_end_of_input,
    json_error_end_of_input_expected,
    json_error_invalid_syntax,
    json_error_invalid_format,
    json_error_wrong_type,
    json_error_null_character,
    json_error_null_value,
    json_error_null_byte_in_key,
    json_error_duplicate_key,
    json_error_numeric_overflow,
    json_error_item_not_found,
    json_error_index_out_of_range
  );

function json_error_code(e: PJsonError): TJsonErrorCode;


(* getters, setters, manipulation *)

procedure json_object_seed(seed: size_t); cdecl; external libjansson;
function json_object_size(_object: PJson): size_t; cdecl; external libjansson;
function json_object_get(_object: PJson; key: PAnsiChar): PJson; cdecl; external libjansson;
function json_object_set_new(_object: PJson; key: PAnsiChar; value: PJson): Integer; cdecl; external libjansson;
function json_object_set_new_nocheck(_object: PJson; key: PAnsiChar; value: PJson): Integer; cdecl; external libjansson;
function json_object_del(_object: PJson; key: PAnsiChar): Integer; cdecl; external libjansson;
function json_object_clear(_object: PJson): Integer; cdecl; external libjansson;
function json_object_update(_object: PJson; other: PJson): Integer; cdecl; external libjansson;
function json_object_update_existing(_object: PJson; other: PJson): Integer; cdecl; external libjansson;
function json_object_update_missing(_object: PJson; other: PJson): Integer; cdecl; external libjansson;
function json_object_update_recursive(_object: PJson; other: PJson): Integer; cdecl; external libjansson;
function json_object_iter(_object: PJson): Pointer; cdecl; external libjansson;
function json_object_iter_at(_object: PJson; key: PAnsiChar): Pointer; cdecl; external libjansson;
function json_object_key_to_iter(key: PAnsiChar): Pointer; cdecl; external libjansson;
function json_object_iter_next(_object: PJson; iter: Pointer): Pointer; cdecl; external libjansson;
function json_object_iter_key(iter: Pointer): PAnsiChar; cdecl; external libjansson;
function json_object_iter_value(iter: Pointer): PJson; cdecl; external libjansson;
function json_object_iter_set_new(_object: PJson; iter: Pointer; value: PJson): Integer; cdecl; external libjansson;
function json_object_set(_object: PJson; key: PAnsiChar; value: PJson): Integer;
function json_object_set_nocheck(_object: PJson; key: PAnsiChar; value: PJson): Integer;
function json_object_iter_set(_object: PJson; iter: Pointer; value: PJson): Integer;
function json_object_update_new(_object: PJson; other: PJson): Integer;
function json_object_update_existing_new(_object: PJson; other: PJson): Integer;
function json_object_update_missing_new(_object: PJson; other: PJson): Integer;
function json_array_size(_array: PJson): size_t; cdecl; external libjansson;
function json_array_get(_array: PJson; index: size_t): PJson; cdecl; external libjansson;
function json_array_set_new(_array: PJson; index: size_t; value: PJson): Integer; cdecl; external libjansson;
function json_array_append_new(_array: PJson; value: PJson): Integer; cdecl; external libjansson;
function json_array_insert_new(_array: PJson; index: size_t; value: PJson): Integer; cdecl; external libjansson;
function json_array_remove(_array: PJson; index: size_t): Integer; cdecl; external libjansson;
function json_array_clear(_array: PJson): Integer; cdecl; external libjansson;
function json_array_extend(_array: PJson; other: PJson): Integer; cdecl; external libjansson;
function json_array_set(_array: PJson; ind: size_t; value: PJson): Integer;
function json_array_append(_array: PJson; value: PJson): Integer;
function json_array_insert(_array: PJson; ind: size_t; value: PJson): Integer;
function json_string_value(_string: PJson): PAnsiChar; cdecl; external libjansson;
function json_string_length(_string: PJson): size_t; cdecl; external libjansson;
function json_integer_value(_integer: PJson): TJsonInt; cdecl; external libjansson;
function json_real_value(real: PJson): Double; cdecl; external libjansson;
function json_number_value(json: PJson): Double; cdecl; external libjansson;
function json_string_set(_string: PJson; value: PAnsiChar): Integer; cdecl; external libjansson;
function json_string_setn(_string: PJson; value: PAnsiChar; len: size_t): Integer; cdecl; external libjansson;
function json_string_set_nocheck(_string: PJson; value: PAnsiChar): Integer; cdecl; external libjansson;
function json_string_setn_nocheck(_string: PJson; value: PAnsiChar; len: size_t): Integer; cdecl; external libjansson;
function json_integer_set(_integer: PJson; value: TJsonInt): Integer; cdecl; external libjansson;
function json_real_set(real: PJson; value: Double): Integer; cdecl; external libjansson;


(* pack, unpack *)

function json_pack(fmt: PAnsiChar {args}): PJson; cdecl; varargs; external libjansson;
function json_pack_ex(error: PJsonError; flags: size_t; fmt: PAnsiChar {args}): PJson; cdecl; varargs; external libjansson;
function json_vpack_ex(error: PJsonError; flags: size_t; fmt: PAnsiChar; ap: va_list): PJson; cdecl; external libjansson;

const
  JSON_VALIDATE_ONLY = $01;
  JSON_STRICT = $02;

function json_unpack(root: PJson; fmt: PAnsiChar {args}): Integer; cdecl; varargs; external libjansson;
function json_unpack_ex(root: PJson; error: PJsonError; flags: size_t; fmt: PAnsiChar {args}): Integer; cdecl; varargs; external libjansson;
function json_vunpack_ex(root: PJson; error: PJsonError; flags: size_t; fmt: PAnsiChar; ap: va_list): Integer; cdecl; external libjansson;


(* sprintf *)

function json_sprintf(fmt: PAnsiChar {args}): PJson; cdecl; varargs; external libjansson;
function json_vsprintf(fmt: PAnsiChar; ap: va_list): PJson; cdecl; external libjansson;


(* equality *)

function json_equal(value1: PJson; value2: PJson): Integer; cdecl; external libjansson;


(* copying *)

function json_copy(value: PJson): PJson; cdecl; external libjansson;
function json_deep_copy(value: PJson): PJson; cdecl; external libjansson;


(* decoding *)

const
  JSON_REJECT_DUPLICATES = $01;
  JSON_DISABLE_EOF_CHECK = $02;
  JSON_DECODE_ANY = $04;
  JSON_DECODE_INT_AS_REAL = $08;
  JSON_ALLOW_NUL = $10;

type
  TJsonLoadCallback = function(buffer: Pointer; buflen: size_t; data: Pointer): size_t; cdecl;

function json_loads(input: PAnsiChar; flags: size_t; error: PJsonError): PJson; cdecl; external libjansson;
function json_loadb(buffer: PAnsiChar; buflen: size_t; flags: size_t; error: PJsonError): PJson; cdecl; external libjansson;
function json_loadf(input: Pointer; flags: size_t; error: PJsonError): PJson; cdecl; external libjansson;
function json_loadfd(input: Integer; flags: size_t; error: PJsonError): PJson; cdecl; external libjansson;
function json_load_file(path: PAnsiChar; flags: size_t; error: PJsonError): PJson; cdecl; external libjansson;
function json_load_callback(callback: TJsonLoadCallback; data: Pointer; flags: size_t; error: PJsonError): PJson; cdecl; external libjansson;


(* encoding *)

const
  JSON_MAX_INDENT = $1F;
  JSON_COMPACT = $20;
  JSON_ENSURE_ASCII = $40;
  JSON_SORT_KEYS= $80;
  JSON_PRESERVE_ORDER = $100;
  JSON_ENCODE_ANY = $200;
  JSON_ESCAPE_SLASH = $400;
  JSON_EMBED = $10000;

function JSON_INDENT(n: size_t): size_t;
function JSON_REAL_PRECISION(n: size_t): size_t;

type
  TJsonDumpCallback = function(buffer: PAnsiChar; size: size_t; data: Pointer): Integer; cdecl;

function json_dumps(json: PJson; flags: size_t): PAnsiChar; cdecl; external libjansson;
function json_dumpb(json: PJson; buffer: PAnsiChar; size: size_t; flags: size_t): size_t; cdecl; external libjansson;
function json_dumpf(json: PJson; output: Pointer; flags: size_t): Integer; cdecl; external libjansson;
function json_dumpfd(json: PJson; output: Integer; flags: size_t): Integer; cdecl; external libjansson;
function json_dump_file(json: PJson; path: PAnsiChar; flags: size_t): Integer; cdecl; external libjansson;
function json_dump_callback(json: PJson; callback: TJsonDumpCallback; data: Pointer; flags: size_t): Integer; cdecl; external libjansson;


(* custom memory allocation *)

type
  PJsonMalloc = ^TJsonMalloc;
  TJsonMalloc = function(size: size_t): Pointer; cdecl;
  PJsonFree = ^TJsonFree;
  TJsonFree = function(pBlock: Pointer): Pointer; cdecl;

procedure json_set_alloc_funcs(malloc_fn: TJsonMalloc; free_fn: TJsonFree); cdecl; external libjansson;
procedure json_get_alloc_funcs(malloc_fn: PJsonMalloc; free_fn: PJsonFree); cdecl; external libjansson;

(* custom memory allocation *)

function delphi_json_malloc(size: size_t): Pointer; cdecl;
procedure delphi_json_free(pBlock: Pointer); cdecl;

(* runtime version checking *)

function jansson_version_str: PAnsiChar; cdecl; external libjansson;
function jansson_version_cmp(major: Integer; minor: Integer; micro: Integer): Integer; cdecl; external libjansson;

implementation

function json_typeof(json: PJson): TJsonType; inline;
begin
  Result := json._type;
end;

function json_is_object(json: PJson): Boolean; inline;
begin
  Result := (json <> nil) and (json_typeof(json) = JSON_OBJECT_T);
end;

function json_is_array(json: PJson): Boolean; inline;
begin
  Result := (json <> nil) and (json_typeof(json) = JSON_ARRAY_T);
end;

function json_is_string(json: PJson): Boolean; inline;
begin
  Result := (json <> nil) and (json_typeof(json) = JSON_STRING_T);
end;

function json_is_integer(json: PJson): Boolean; inline;
begin
  Result := (json <> nil) and (json_typeof(json) = JSON_INTEGER_T);
end;

function json_is_real(json: PJson): Boolean; inline;
begin
  Result := (json <> nil) and (json_typeof(json) = JSON_REAL_T);
end;

function json_is_number(json: PJson): Boolean; inline;
begin
  Result := json_is_integer(json) or json_is_real(json);
end;

function json_is_true(json: PJson): Boolean; inline;
begin
  Result := (json <> nil) and (json_typeof(json) = JSON_TRUE_T);
end;

function json_is_false(json: PJson): Boolean; inline;
begin
  Result := (json <> nil) and (json_typeof(json) = JSON_FALSE_T);
end;

function json_boolean_value(json: PJson): Integer; inline;
begin
  if (json <> nil) and (json_typeof(json) = JSON_TRUE_T) then begin
    Result := 1;
  end else begin
    Result := 0;
  end;
end;

function json_is_boolean(json: PJson): Boolean; inline;
begin
  Result := json_is_true(json) or json_is_false(json);
end;

function json_is_null(json: PJson): Boolean; inline;
begin
  Result := (json <> nil) and (json_typeof(json) = JSON_NULL_T);
end;

function json_boolean(val: Boolean): PJson; inline;
begin
  if (val) then begin
    Result := json_true;
  end else begin
    Result := json_false;
  end;
end;

function json_boolean(val: Integer): PJson; inline;
begin
  if (val <> 0) then begin
    Result := json_true;
  end else begin
    Result := json_false;
  end;
end;

function json_incref(json: PJson): PJson; inline;
begin
  if (json <> nil) and (json.refcount <> size_t(-1)) then begin
    Inc(json.refcount);
  end;
  Result := json;
end;

procedure json_decref(json: PJson); inline;
begin
  if (json <> nil) and (json.refcount <> size_t(-1)) then begin
    Dec(json.refcount);
    if json.refcount = 0 then begin
      json_delete(json);
    end;
  end;
end;

function json_object_set(_object: PJson; key: PAnsiChar; value: PJson): Integer; inline;
begin
  Result := json_object_set_new(_object, key, json_incref(value));
end;

function json_object_set_nocheck(_object: PJson; key: PAnsiChar; value: PJson): Integer; inline;
begin
  Result := json_object_set_new_nocheck(_object, key, json_incref(value));
end;

function json_object_iter_set(_object: PJson; iter: Pointer; value: PJson): Integer; inline;
begin
  Result := json_object_iter_set_new(_object, iter, json_incref(value));
end;

function json_array_set(_array: PJson; ind: size_t; value: PJson): Integer; inline;
begin
  Result := json_array_set_new(_array, ind, json_incref(value));
end;

function json_array_append(_array: PJson; value: PJson): Integer; inline;
begin
  Result := json_array_append_new(_array, json_incref(value));
end;

function json_array_insert(_array: PJson; ind: size_t; value: PJson): Integer; inline;
begin
  Result := json_array_insert_new(_array, ind, json_incref(value));
end;

function JSON_INDENT(n: size_t): size_t; inline;
begin
  Result := n and JSON_MAX_INDENT;
end;

function JSON_REAL_PRECISION(n: size_t): size_t; inline;
begin
  Result := (n and $1F) shl 11;
end;

function json_error_code(e: PJsonError): TJsonErrorCode; inline;
begin
  Result := TJsonErrorCode(e.text[JSON_ERROR_TEXT_LENGTH - 1]);
end;

function json_object_update_new(_object: PJson; other: PJson): Integer; inline;
begin
  Result := json_object_update(_object, other);
  json_decref(other);
end;

function json_object_update_existing_new(_object: PJson; other: PJson): Integer; inline;
begin
  Result := json_object_update_existing(_object, other);
  json_decref(other);
end;

function json_object_update_missing_new(_object: PJson; other: PJson): Integer; inline;
begin
  Result := json_object_update_missing(_object, other);
  json_decref(other);
end;

function delphi_json_malloc(size: size_t): Pointer; cdecl;
begin
  try
    GetMem(Result, size);
  except
    Result := nil;
  end;
end;

procedure delphi_json_free(pBlock: Pointer); cdecl;
begin
  FreeMem(pBlock);
end;

initialization
  json_set_alloc_funcs(@delphi_json_malloc, @delphi_json_free);

end.
