# Jansson-Delphi

Jansson-Delphi - a Delphi binding for Jansson library, which is a C library for encoding, decoding and manipulating JSON data.

Jansson-Delphi consists of a Jansson's prebuilt dynamic-link library (DLL) and a PAS file with all required declarations which are required to use Jansson's API.

You can build the DLL on your own by following this manual: https://jansson.readthedocs.io/en/latest/gettingstarted.html#compiling-and-installing-jansson 

Original Jansson github project: https://github.com/akheron/jansson

## Version

Current version of Jansson-Delphi is `2.13.1`, which means that it is based on corresponding version of the Jansson library.

Jansson-Delphi was developed and tested on the following systems:

 * Borland Delphi 2006, Win32
 
It can also be used in newer Delphi versions. To make sure that it works correctly, build and run DUnit tests from the `test` directory.
 
## Documentation

Original API reference: https://jansson.readthedocs.io/en/latest/apiref.html

## Some useful code snippets

The original Jansson header contains following macro definitions for iteration over objects and arrays:

 * json_object_foreach(object, key, value) 
 * json_object_foreach_safe(object, n, key, value) 
 * json_array_foreach(array, index, value)
 
You can use these code snippets to replace the macroses:

```
//#define json_object_foreach(object, key, value) \
//    for(key = json_object_iter_key(json_object_iter(object)); \
//        key && (value = json_object_iter_value(json_object_key_to_iter(key))); \
//        key = json_object_iter_key(json_object_iter_next(object, json_object_key_to_iter(key))))
var
  LKey: PAnsiChar;
  LObject: PJson;
  LValue: PJson;

----------

LKey := json_object_iter_key(json_object_iter(LObject));
while (LKey <> nil) do begin
  LValue := json_object_iter_value(json_object_key_to_iter(LKey));
  if (LValue = nil) then begin
    Break;
  end;

  // Do something here with LKey and LValue.

  LKey := json_object_iter_key(json_object_iter_next(LObject, json_object_key_to_iter(LKey)));
end;
```
```
//#define json_object_foreach_safe(object, n, key, value)     \
//    for(key = json_object_iter_key(json_object_iter(object)), \
//            n = json_object_iter_next(object, json_object_key_to_iter(key)); \
//        key && (value = json_object_iter_value(json_object_key_to_iter(key))); \
//        key = json_object_iter_key(n), \
//            n = json_object_iter_next(object, json_object_key_to_iter(key)))
var
  LObject: PJson;
  LKey: PAnsiChar;
  LN: Pointer;
  LValue: PJson;

----------

LKey := json_object_iter_key(json_object_iter(LObject));
LN := json_object_iter_next(LObject, json_object_key_to_iter(LKey));
while (LKey <> nil) do begin
  LValue := json_object_iter_value(json_object_key_to_iter(LKey));
  if (LValue = nil) then begin
    Break;
  end;

  // Do something here with LKey and LValue.

  LKey := json_object_iter_key(LN);
  LN := json_object_iter_next(LObject, json_object_key_to_iter(LKey));
end;
```
```
//#define json_array_foreach(array, index, value) \
//	for(index = 0; \
//		index < json_array_size(array) && (value = json_array_get(array, index)); \
//		index++)
var
  LIndex: Integer;
  LValue: PJson;

----------

LIndex := 0;
while LIndex < json_array_size(AArray) do begin
  LValue := json_array_get(AArray, LIndex);
  if (LValue = nil) then begin
    Break;
  end;

  // Do something here with LValue.

  Inc(LIndex);
end;
```

## License 

Jansson is released under the MIT license. (LICENSE.C.txt)

Jansson-Delphi is released under the MIT license. (LICENSE.DELPHI.txt)