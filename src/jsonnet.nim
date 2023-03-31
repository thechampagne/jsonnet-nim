##  The version string of th Jsonnet interpreter.
##
##  This is currently grepped out of this file by setup.py, Makefile, and CMakeLists.txt so be aware
##  of that when making changes.
##
##  If this isn't the sae as jsonnet_version() then you've got a mismatched binary / header.
##

const
  LIB_JSONNET_VERSION* = "v0.19.1"

type
  ##  Jsonnet virtual machine context.
  JsonnetVm* {.bycopy.} = object
  ##  An opaque type which can only be utilized via the jsonnet_json_* family of functions.
  JsonnetJsonValue* {.bycopy.} = object

##  Return the version string of the Jsonnet interpreter.  Conforms to semantic versioning
##  https://semver.org/ If this does not match LIB_JSONNET_VERSION then there is a mismatch between
##  header and compiled library.
##

proc jsonnet_version*(): cstring {.importc.}

proc jsonnet_make*(): ptr JsonnetVm {.importc.}
##  Set the maximum stack depth.

proc jsonnet_max_stack*(vm: ptr JsonnetVm, v: cuint) {.importc.}
##  Set the number of objects required before a garbage collection cycle is allowed.

proc jsonnet_gc_min_objects*(vm: ptr JsonnetVm, v: cuint) {.importc.}
##  Run the garbage collector after this amount of growth in the number of objects.

proc jsonnet_gc_growth_trigger*(vm: ptr JsonnetVm, v: cdouble) {.importc.}
##  Expect a string as output and don't JSON encode it.

proc jsonnet_string_output*(vm: ptr JsonnetVm, v: cint) {.importc.}
##  Callback used to load imports.
##
##  The returned char* should be allocated with jsonnet_realloc.  It will be cleaned up by
##  libjsonnet when no-longer needed.
##
##  \param ctx User pointer, given in jsonnet_import_callback.
##  \param base The directory containing the code that did the import.
##  \param rel The path imported by the code.
##  \param found_here Set this byref param to path to the file, absolute or relative to the
##      process's CWD.  This is necessary so that imports from the content of the imported file can
##      be resolved correctly.  Allocate memory with jsonnet_realloc.  Only use when *success = 1.
##  \param success Set this byref param to 1 to indicate success and 0 for failure.
##  \param buf Set this byref param to the content of the imported file, or an error message.  Allocate memory with jsonnet_realloc.  Do not include a null terminator byte.
##  \param buflen Set this byref param to the length of the data returned in buf.
##  \returns 0 to indicate success and 1 for failure.  On success, the content is in *buf.  On failure, an error message is in *buf.
##

type
  JsonnetImportCallback* = proc (ctx: pointer, base: cstring, rel: cstring,
                              found_here: cstringArray, buf: cstringArray,
                              buflen: ptr csize_t): cint {.cdecl.}


proc jsonnet_json_extract_string*(vm: ptr JsonnetVm, v: ptr JsonnetJsonValue): cstring {.importc.}
##  If the value is a number, return 1 and store the number in out, otherwise return 0.
##

proc jsonnet_json_extract_number*(vm: ptr JsonnetVm, v: ptr JsonnetJsonValue,
                                 `out`: ptr cdouble): cint {.importc.}
##  Return 0 if the value is false, 1 if it is true, and 2 if it is not a bool.
##

proc jsonnet_json_extract_bool*(vm: ptr JsonnetVm, v: ptr JsonnetJsonValue): cint {.importc.}
##  Return 1 if the value is null, else 0.
##

proc jsonnet_json_extract_null*(vm: ptr JsonnetVm, v: ptr JsonnetJsonValue): cint {.importc.}
##  Convert the given UTF8 string to a JsonnetJsonValue.
##

proc jsonnet_json_make_string*(vm: ptr JsonnetVm, v: cstring): ptr JsonnetJsonValue {.importc.}
##  Convert the given double to a JsonnetJsonValue.
##

proc jsonnet_json_make_number*(vm: ptr JsonnetVm, v: cdouble): ptr JsonnetJsonValue {.importc.}
##  Convert the given bool (1 or 0) to a JsonnetJsonValue.
##

proc jsonnet_json_make_bool*(vm: ptr JsonnetVm, v: cint): ptr JsonnetJsonValue {.importc.}
##  Make a JsonnetJsonValue representing null.
##

proc jsonnet_json_make_null*(vm: ptr JsonnetVm): ptr JsonnetJsonValue {.importc.}
##  Make a JsonnetJsonValue representing an array.
##
##  Assign elements with jsonnet_json_array_append.
##

proc jsonnet_json_make_array*(vm: ptr JsonnetVm): ptr JsonnetJsonValue {.importc.}
##  Add v to the end of the array.
##

proc jsonnet_json_array_append*(vm: ptr JsonnetVm, arr: ptr JsonnetJsonValue,
                               v: ptr JsonnetJsonValue) {.importc.}
##  Make a JsonnetJsonValue representing an object with the given number of fields.
##
##  Every index of the array must have a unique value assigned with jsonnet_json_array_element.
##

proc jsonnet_json_make_object*(vm: ptr JsonnetVm): ptr JsonnetJsonValue {.importc.}
##  Add the field f to the object, bound to v.
##
##  This replaces any previous binding of the field.
##

proc jsonnet_json_object_append*(vm: ptr JsonnetVm, obj: ptr JsonnetJsonValue,
                                f: cstring, v: ptr JsonnetJsonValue) {.importc.}
##  Clean up a JSON subtree.
##
##  This is useful if you want to abort with an error mid-way through building a complex value.
##

proc jsonnet_json_destroy*(vm: ptr JsonnetVm, v: ptr JsonnetJsonValue) {.importc.}
##  Callback to provide native extensions to Jsonnet.
##
##  The returned JsonnetJsonValue* should be allocated with jsonnet_realloc.  It will be cleaned up
##  along with the objects rooted at argv by libjsonnet when no-longer needed.  Return a string upon
##  failure, which will appear in Jsonnet as an error.  The argv pointer is an array whose size
##  matches the array of parameters supplied when the native callback was originally registered.
##
##  \param ctx User pointer, given in jsonnet_native_callback.
##  \param argv Array of arguments from Jsonnet code.
##  \param success Set this byref param to 1 to indicate success and 0 for failure.
##  \returns The content of the imported file, or an error message.
##

type
  JsonnetNativeCallback* = proc (ctx: pointer, argv: ptr ptr JsonnetJsonValue,
                              success: ptr cint): ptr JsonnetJsonValue {.cdecl.}

##  Allocate, resize, or free a buffer.  This will abort if the memory cannot be allocated.  It will
##  only return NULL if sz was zero.
##
##  \param buf If NULL, allocate a new buffer.  If an previously allocated buffer, resize it.
##  \param sz The size of the buffer to return.  If zero, frees the buffer.
##  \returns The new buffer.
##

proc jsonnet_realloc*(vm: ptr JsonnetVm, buf: cstring, sz: csize_t): cstring {.importc.}
##  Override the callback used to locate imports.
##

proc jsonnet_import_callback*(vm: ptr JsonnetVm, cb: JsonnetImportCallback,
                             ctx: pointer) {.importc.}
##  Register a native extension.
##
##  This will appear in Jsonnet as a function type and can be accessed from std.nativeExt("foo").
##
##  DO NOT register native callbacks with side-effects!  Jsonnet is a lazy functional language and
##  will call your function when you least expect it, more times than you expect, or not at all.
##
##  \param vm The vm.
##  \param name The name of the function as visible to Jsonnet code, e.g. "foo".
##  \param cb The PURE function that implements the behavior you want.
##  \param ctx User pointer, stash non-global state you need here.
##  \param params NULL-terminated array of the names of the params.  Must be valid identifiers.
##

proc jsonnet_native_callback*(vm: ptr JsonnetVm, name: cstring,
                             cb: JsonnetNativeCallback, ctx: pointer,
                             params: cstringArray) {.importc.}
##  Bind a Jsonnet external var to the given string.
##
##  Argument values are copied so memory should be managed by caller.
##

proc jsonnet_ext_var*(vm: ptr JsonnetVm, key: cstring, val: cstring) {.importc.}
##  Bind a Jsonnet external var to the given code.
##
##  Argument values are copied so memory should be managed by caller.
##

proc jsonnet_ext_code*(vm: ptr JsonnetVm, key: cstring, val: cstring) {.importc.}
##  Bind a string top-level argument for a top-level parameter.
##
##  Argument values are copied so memory should be managed by caller.
##

proc jsonnet_tla_var*(vm: ptr JsonnetVm, key: cstring, val: cstring) {.importc.}
##  Bind a code top-level argument for a top-level parameter.
##
##  Argument values are copied so memory should be managed by caller.
##

proc jsonnet_tla_code*(vm: ptr JsonnetVm, key: cstring, val: cstring) {.importc.}
##  Set the number of lines of stack trace to display (0 for all of them).

proc jsonnet_max_trace*(vm: ptr JsonnetVm, v: cuint) {.importc.}
##  Add to the default import callback's library search path.
##
##  The search order is last to first, so more recently appended paths take precedence.
##

proc jsonnet_jpath_add*(vm: ptr JsonnetVm, v: cstring) {.importc.}
##  Evaluate a file containing Jsonnet code, return a JSON string.
##
##  The returned string should be cleaned up with jsonnet_realloc.
##
##  \param filename Path to a file containing Jsonnet code.
##  \param error Return by reference whether or not there was an error.
##  \returns Either JSON or the error message.
##

proc jsonnet_evaluate_file*(vm: ptr JsonnetVm, filename: cstring, error: ptr cint): cstring {.importc.}
##  Evaluate a string containing Jsonnet code, return a JSON string.
##
##  The returned string should be cleaned up with jsonnet_realloc.
##
##  \param filename Path to a file (used in error messages).
##  \param snippet Jsonnet code to execute.
##  \param error Return by reference whether or not there was an error.
##  \returns Either JSON or the error message.
##

proc jsonnet_evaluate_snippet*(vm: ptr JsonnetVm, filename: cstring, snippet: cstring,
                              error: ptr cint): cstring {.importc.}
##  Evaluate a file containing Jsonnet code, return a number of named JSON files.
##
##  The returned character buffer contains an even number of strings, the filename and JSON for each
##  JSON file interleaved.  It should be cleaned up with jsonnet_realloc.
##
##  \param filename Path to a file containing Jsonnet code.
##  \param error Return by reference whether or not there was an error.
##  \returns Either the error, or a sequence of strings separated by \0, terminated with \0\0.
##

proc jsonnet_evaluate_file_multi*(vm: ptr JsonnetVm, filename: cstring,
                                 error: ptr cint): cstring {.importc.}
##  Evaluate a string containing Jsonnet code, return a number of named JSON files.
##
##  The returned character buffer contains an even number of strings, the filename and JSON for each
##  JSON file interleaved.  It should be cleaned up with jsonnet_realloc.
##
##  \param filename Path to a file containing Jsonnet code.
##  \param snippet Jsonnet code to execute.
##  \param error Return by reference whether or not there was an error.
##  \returns Either the error, or a sequence of strings separated by \0, terminated with \0\0.
##

proc jsonnet_evaluate_snippet_multi*(vm: ptr JsonnetVm, filename: cstring,
                                    snippet: cstring, error: ptr cint): cstring {.importc.}
##  Evaluate a file containing Jsonnet code, return a number of JSON files.
##
##  The returned character buffer contains several strings.  It should be cleaned up with
##  jsonnet_realloc.
##
##  \param filename Path to a file containing Jsonnet code.
##  \param error Return by reference whether or not there was an error.
##  \returns Either the error, or a sequence of strings separated by \0, terminated with \0\0.
##

proc jsonnet_evaluate_file_stream*(vm: ptr JsonnetVm, filename: cstring,
                                  error: ptr cint): cstring {.importc.}
##  Evaluate a string containing Jsonnet code, return a number of JSON files.
##
##  The returned character buffer contains several strings.  It should be cleaned up with
##  jsonnet_realloc.
##
##  \param filename Path to a file containing Jsonnet code.
##  \param snippet Jsonnet code to execute.
##  \param error Return by reference whether or not there was an error.
##  \returns Either the error, or a sequence of strings separated by \0, terminated with \0\0.
##

proc jsonnet_evaluate_snippet_stream*(vm: ptr JsonnetVm, filename: cstring,
                                     snippet: cstring, error: ptr cint): cstring {.importc.}
proc jsonnet_destroy*(vm: ptr JsonnetVm) {.importc.}

proc jsonnet_fmt_indent*(vm: ptr JsonnetVm, n: cint) {.importc.}
##  Indentation level when reformatting (number of spaeces).
##
##  \param n Number of spaces, must be > 0.
##

proc jsonnet_fmt_max_blank_lines*(vm: ptr JsonnetVm, n: cint) {.importc.}
##  Preferred style for string literals ("" or '').
##
##  \param c String style as a char ('d', 's', or 'l' (leave)).
##

proc jsonnet_fmt_string*(vm: ptr JsonnetVm, c: cint) {.importc.}
##  Preferred style for line comments (# or //).
##
##  \param c Comment style as a char ('h', 's', or 'l' (leave)).
##

proc jsonnet_fmt_comment*(vm: ptr JsonnetVm, c: cint) {.importc.}
##  Whether to add an extra space on the inside of arrays.
##

proc jsonnet_fmt_pad_arrays*(vm: ptr JsonnetVm, v: cint) {.importc.}
##  Whether to add an extra space on the inside of objects.
##

proc jsonnet_fmt_pad_objects*(vm: ptr JsonnetVm, v: cint) {.importc.}
##  Use syntax sugar where possible with field names.
##

proc jsonnet_fmt_pretty_field_names*(vm: ptr JsonnetVm, v: cint) {.importc.}
##  Sort top-level imports in alphabetical order
##

proc jsonnet_fmt_sort_imports*(vm: ptr JsonnetVm, v: cint) {.importc.}
##  If set to 1, will reformat the Jsonnet input after desugaring.

proc jsonnet_fmt_debug_desugaring*(vm: ptr JsonnetVm, v: cint) {.importc.}
##  Reformat a file containing Jsonnet code, return a Jsonnet string.
##
##  The returned string should be cleaned up with jsonnet_realloc.
##
##  \param filename Path to a file containing Jsonnet code.
##  \param error Return by reference whether or not there was an error.
##  \returns Either Jsonnet code or the error message.
##

proc jsonnet_fmt_file*(vm: ptr JsonnetVm, filename: cstring, error: ptr cint): cstring {.importc.}
##  Reformat a string containing Jsonnet code, return a Jsonnet string.
##
##  The returned string should be cleaned up with jsonnet_realloc.
##
##  \param filename Path to a file (used in error messages).
##  \param snippet Jsonnet code to execute.
##  \param error Return by reference whether or not there was an error.
##  \returns Either Jsonnet code or the error message.
##

proc jsonnet_fmt_snippet*(vm: ptr JsonnetVm, filename: cstring, snippet: cstring,
                         error: ptr cint): cstring {.importc.}
