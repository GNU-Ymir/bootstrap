# Compiler error codes

Every user-facing diagnostic the compiler raises carries a code, printed next to
its severity:

```text
Error[E4020] : class A has no method named foo
 --> main.yr:(8,15)
```

The code is stable: it is allocated once, never reused and never renumbered. A
message that is deleted retires its code rather than freeing it, and its page here
stays as a tombstone. Rewording a message never changes its code -- the two are
written on the same line of the catalogue, so they cannot drift apart.

The code is not the `(#id)` that verbose diagnostics print. That one is a per-run
counter used to deduplicate a repeated error and to write the "previous error"
back-reference; it changes from run to run and means nothing outside a single
compilation.

A code names the pipeline stage that raises it, so the code alone says where the
check lives:

| Range | Stage | Catalogue | Live codes |
|---|---|---|---|
| `E1xxx` | lexing | `LexingErrorMessage` -- `src/ymirc/lexing/errors.yr` | 25 |
| `E2xxx` | parsing | `SyntaxErrorMessage` -- `src/ymirc/syntax/errors.yr` | 7 |
| `E3xxx` | declaration | `DeclareErrorMessage` -- `src/ymirc/semantic/declarator/errors.yr` | 34 |
| `E4xxx` | validation | `ValidateErrorMessage` -- `src/ymirc/semantic/validator/errors.yr` | 264 |
| `E5xxx` | lowering (YIL) | `SerializeYILErrorMessage` -- `src/ymirc/lint/serialize/errors.yr` | 10 |

Each page carries an example wherever a case in the suite raises the code: the
snippet is quoted from `test_resources/`, so it is one the suite keeps compiling.
`test_resources/diagnostics/` is the category dedicated to that -- one minimal case
per code -- and `test/integration/diagnostics.yr` registers it.

Messages that are not diagnostics of their own -- the context notes a diagnostic
hangs under, such as "when validating ...", "candidate ...", "did you mean ..." --
deliberately carry no code, and have no page here.

## E1xxx -- lexing

| Code | Name | Message |
|---|---|---|
| [E1001](E1001.md) | `UNTERMINATED_STRING` | unterminated string literal <> |
| [E1002](E1002.md) | `UNTERMINATED_COMMENT` | unterminated comment block <> |
| [E1003](E1003.md) | `RETURN_IN_SINGLE_LINE_COMMENT` | line break encountered inside a single-line comment |
| [E1004](E1004.md) | `RETURN_IN_SINGLE_LINE_STRING` | line break encountered inside a single-line string literal |
| [E1005](E1005.md) | `ESCAPE_RETURN_PROHIBITED_STRING` | escaping a line break is prohibited; use a multiline string instead """ |
| [E1006](E1006.md) | `ESCAPE_RETURN_PROHIBITED_COMMENT` | escaping a line break is prohibited; use a multiline comment instead /**/ |
| [E1007](E1007.md) | `ESCAPE_AT_END_OF_STRING` | escape character found at end of string literal |
| [E1008](E1008.md) | `ESCAPE_AT_END_OF_COMMENT` | escape character found at end of comment block |
| [E1009](E1009.md) | `INVALID_HEX_NUMBER` | invalid numeric value formatted in hexadecimal |
| [E1010](E1010.md) | `INVALID_DEC_NUMBER` | invalid numeric value formatted in decimal |
| [E1011](E1011.md) | `INVALID_BIN_NUMBER` | invalid numeric value formatted in binary |
| [E1012](E1012.md) | `INVALID_OCT_NUMBER` | invalid numeric value formatted in octal |
| [E1013](E1013.md) | `MISSING_HEX_FLOAT_SIGN` | expected sign information in hexadecimal floating-point literal |
| [E1014](E1014.md) | `MISSING_SCI_FLOAT_SIGN` | expected sign information in scientific floating-point literal |
| [E1015](E1015.md) | `INVALID_IDENTIFIER` | <> is not a valid identifier; use backquotes for special identifiers(e.g. `<>`) |
| [E1016](E1016.md) | `EMPTY_BIN_NUMBER` | binary number is empty |
| [E1017](E1017.md) | `EMPTY_OCT_NUMBER` | octal number is empty |
| [E1018](E1018.md) | `EMPTY_HEX_NUMBER` | hexadecimal number is empty |
| [E1019](E1019.md) | `EMPTY_EXP_FLOAT_NUMBER` | the exponent part of the floating-point number is empty |
| [E1020](E1020.md) | `EMPTY_DEC_FLOAT_NUMBER` | the fractional part of the floating-point number is empty |
| [E1021](E1021.md) | `MISSING_P_IN_HEX_FLOAT` | missing the exponent part in a floating-point number formatted in hexadecimal |
| [E1022](E1022.md) | `UNTERMINATED_VERSION_BLOCK` | unterminated version block: missing #end |
| [E1023](E1023.md) | `UNMATCHED_VERSION_END` | #<> without matching #if |
| [E1024](E1024.md) | `MISSING_VERSION_CONDITION` | missing version condition: expected identifier or backquoted identifier |
| [E1025](E1025.md) | `UNDEFINED_VERSION_DIRECTIVE` | undefined version directive; expecting if, else or end |

## E2xxx -- parsing

| Code | Name | Message |
|---|---|---|
| [E2001](E2001.md) | `BLOCK_NEVER_CLOSED` | block is never closed |
| [E2002](E2002.md) | `MULTIPLE_ATTRS` | decorator <> is defined multiple times |
| [E2004](E2004.md) | `MULTIPLE_SAME_GUARD` | scope guard <> is declared multiple times |
| [E2006](E2006.md) | `UNDEF_DECORATOR_IN_MATCH` | decorator <> cannot be applied to a subpattern variable |
| [E2007](E2007.md) | `UNEXPECTED` | unexpected <> |
| [E2008](E2008.md) | `UNEXPECTED_ATTRIBUTES` | unexpected attribute list <> |
| [E2009](E2009.md) | `UNEXPECTED_BUT_LST` | read <>, but expected <> |

## E3xxx -- declaration

| Code | Name | Message |
|---|---|---|
| [E3001](E3001.md) | `ABSTRACT_AND_FINAL` | a class cannot be both abstract and final |
| [E3002](E3002.md) | `CONFLICT_MODULES` | module is ambiguously defined in both <> and <> |
| [E3003](E3003.md) | `DECL_GLOB_STATIC_NON_EXTERN` | only external global variables may be declared static |
| [E3004](E3004.md) | `DECL_GLOB_THREAD_EXTERN` | only local global variables may be declared thread-local |
| [E3005](E3005.md) | `DECL_VARIADIC_FUNC` | only external C functions may be variadic |
| [E3006](E3006.md) | `DEFAULT_CTOR_ALREADY_DECLARED` | the ctor built from the fields is already declared |
| [E3007](E3007.md) | `DEFAULT_CTOR_IN_DATA` | the ctor built from the fields is implicit in a data record |
| [E3008](E3008.md) | `DTOR_IN_RECORD` | record types cannot define destructors |
| [E3009](E3009.md) | `MALFORMED_CORE` | core module is malformed |
| [E3010](E3010.md) | `MULTIPLE_DESTRUCTOR` | a class may only define one destructor |
| [E3011](E3011.md) | `NOT_OVERRIDE` | method <> is marked override but does not override any base method |
| [E3012](E3012.md) | `NO_MODULE_NAMED` | no module named <> found inside module <> |
| [E3013](E3013.md) | `NO_SUCH_FILE` | module should be located in <> or <>, but no such file exists or access is denied |
| [E3014](E3014.md) | `NO_SUCH_FILE_ONE` | module should be located in <>, but no such file exists or access is denied |
| [E3015](E3015.md) | `OVERLAID_AND_PACKED` | a record cannot be both overlaid and packed |
| [E3016](E3016.md) | `PRIVATE_IN_THIS_CONTEXT` | <> is private in this context |
| [E3017](E3017.md) | `SELF_USE` | the <> module is imported implicitly; an explicit use is unnecessary |
| [E3018](E3018.md) | `SHADOWING_DECL` | declaration of <> shadows a previous declaration |
| [E3019](E3019.md) | `UNDEFINED_ATTRIBUTE_FOR_CLASS` | custom attribute <> is not valid on classes |
| [E3020](E3020.md) | `UNDEFINED_ATTRIBUTE_FOR_CTOR` | custom attribute <> is not valid on constructors |
| [E3021](E3021.md) | `UNDEFINED_ATTRIBUTE_FOR_FUNCTION` | custom attribute <> is not valid on functions |
| [E3022](E3022.md) | `UNDEFINED_ATTRIBUTE_FOR_GLOBAL` | custom attribute <> is not valid on global variables |
| [E3023](E3023.md) | `UNDEFINED_ATTRIBUTE_FOR_RECORD` | custom attribute <> is not valid on records |
| [E3024](E3024.md) | `UNDEFINED_ATTRIBUTE_FOR_TEMPLATE_METHOD` | custom attribute <> is not valid on template methods |
| [E3025](E3025.md) | `UNDEFINED_ATTRIBUTE_NO_CLASS` | custom attribute <> may only be applied to classes |
| [E3026](E3026.md) | `UNDEFINED_ATTRIBUTE_NO_RECORD` | custom attribute <> may only be applied to records |
| [E3027](E3027.md) | `UNDEF_VAR` | undefined symbol <> |
| [E3028](E3028.md) | `UNEXPECTED_IN_CLASS` | unexpected declaration inside a class |
| [E3029](E3029.md) | `UNEXPECTED_IN_EXTERN` | unexpected declaration inside an extern block |
| [E3030](E3030.md) | `UNEXPECTED_IN_IMPL` | unexpected declaration inside an impl block |
| [E3031](E3031.md) | `UNEXPECTED_IN_MACRO` | unexpected declaration inside a macro |
| [E3032](E3032.md) | `UNEXPECTED_IN_MODULE` | unexpected declaration |
| [E3033](E3033.md) | `UNEXPECTED_IN_TRAIT` | unexpected declaration inside a trait |
| [E3034](E3034.md) | `WRONG_MODULE_NAME` | module <> must be defined in a file named <> |

## E4xxx -- validation

| Code | Name | Message |
|---|---|---|
| [E4001](E4001.md) | `AKA_CLASS_CTOR` | a name alias cannot be created to alias class ctors |
| [E4002](E4002.md) | `ALIAS_INDEX_AFFECT` | class alias operator :[ is prohibited on the left operand of an affectation |
| [E4003](E4003.md) | `ALREADY_CAUGHT` | exception type <> is already caught by another catching pattern of type <> |
| [E4004](E4004.md) | `ALREADY_INIT_BY_CTOR_REDIRECT` | field <> was already initialized by ctor redirection |
| [E4005](E4005.md) | `ARRAY_OVERFLOW` | slice access, index overflow <> (len) <= <> (index) |
| [E4006](E4006.md) | `ARRAY_PATTERN_SIZE` | array pattern match len <> never matches the value len <> |
| [E4007](E4007.md) | `BREAK_NO_LOOP` | break statement is not within a loop |
| [E4008](E4008.md) | `BREAK_SCOPE_GUARD` | cannot break loop inside a scope guard |
| [E4009](E4009.md) | `CONTINUE_NO_LOOP` | continue statement is not within a loop |
| [E4010](E4010.md) | `CONTINUE_SCOPE_GUARD` | cannot continue loop inside a scope guard |
| [E4011](E4011.md) | `CANNOT_CASTTO_BASE_CLASS` | cannot cast derived type <> to base class type <> in that context |
| [E4012](E4012.md) | `CATCH_NOTHING` | catching pattern of type <> catches no exception |
| [E4013](E4013.md) | `CATCH_PATTERN_MULT_OR_VDECL` | the pattern of a catch scope guard must start with a variable declaration or a field deconstructor |
| [E4014](E4014.md) | `CLASS_ALIAS_FIELD` | class alias operator :. is not usable to access fields |
| [E4015](E4015.md) | `CLASS_ALIAS_FIELD_NO_CLASS` | alias operator :. is only usable on class, record, entity or map types, not <> |
| [E4016](E4016.md) | `CLASS_ALIAS_INDEX_NO_CLASS` | class alias operator :[ is only usable on class, record or entity types, not <> |
| [E4017](E4017.md) | `CLASS_FIELD_NOT_VALIDATED_YET` | field <> has not yet been validated |
| [E4018](E4018.md) | `CLASS_NOT_IMPL` | class type <> does not implement trait <> |
| [E4019](E4019.md) | `CLASS_NO_FIELD` | class <> has no field named <> |
| [E4020](E4020.md) | `CLASS_NO_METHOD` | class <> has no method named <> |
| [E4021](E4021.md) | `CLASS_THROW_PTR` | class type expected, not the class object instance type <> (i.e. the & is useless) |
| [E4022](E4022.md) | `CLOSURE_TEMPLATE_LAMBDA` | closure functions cannot be used as template values |
| [E4023](E4023.md) | `COLLIDING_FUNCTION_DEFINITION` | colliding function definitions <> and <> |
| [E4024](E4024.md) | `COLLIDING_METHOD_DEFINITION` | colliding method definitions <> and <> |
| [E4026](E4026.md) | `CONSTRUCT_ABSTRACT_CLASS` | cannot construct an instance of class <> that is abstract |
| [E4027](E4027.md) | `CONST_METHOD` | method <> is defined as constant |
| [E4028](E4028.md) | `CONTAIN_ALIASABLE_TYPE` | type <> cannot be embedded within a union type |
| [E4029](E4029.md) | `CONTAIN_MOVABLE_TYPE` | movable type <> cannot be embedded within another type |
| [E4030](E4030.md) | `CTE_ASSERT_NO_MSG` | cte assertion failed |
| [E4031](E4031.md) | `CTE_ASSERT_WITH_MSG` | cte assertion failed <> |
| [E4033](E4033.md) | `CTOR_CLASS_DCOPY` | using a deep copy instead of a one level copy is prohibited when constructing class <> |
| [E4034](E4034.md) | `CTOR_CLASS_STACK` | creating an instance of class <> on the stack is prohibited |
| [E4035](E4035.md) | `CTOR_INFINITE_REDIRECTION` | infinite constructor redirection calls when calling <> |
| [E4036](E4036.md) | `CTOR_MAP_DCOPY` | using a deep copy instead of a one level copy is prohibited when constructing a map <> |
| [E4037](E4037.md) | `CTOR_MAP_STACK` | creating an instance of map <> on the stack is prohibited |
| [E4038](E4038.md) | `DECLARED_NOT_USED` | the symbol <> was declared but never used |
| [E4039](E4039.md) | `DECLARE_VOID_VAR` | cannot declare a variable of type <> |
| [E4040](E4040.md) | `DECREASING_RANGE_ACCESS` | range index cannot be decreasing for type <>, but goes from <> to <> |
| [E4041](E4041.md) | `DEEPLY_INNER_TYPE` | decorator is not applicable on inner types, already deeply mutable |
| [E4042](E4042.md) | `DEFAULT_VAR_NO_NAME` | parameter with a default value must have a referenceable name |
| [E4043](E4043.md) | `DEFAULT_VAR_REF` | parameter with a default value cannot be a reference |
| [E4044](E4044.md) | `CLASS_FIELD_NO_NAME` | field must have a referenceable name |
| [E4045](E4045.md) | `DISCARD_CONST` | discarding the constant property is prohibited |
| [E4046](E4046.md) | `DIVISION_BY_ZERO` | division by 0 |
| [E4047](E4047.md) | `DOLLAR_OUTSIDE_CONTEXT` | '$' is usable only inside an index operation |
| [E4048](E4048.md) | `DTOR_SELF_NOT_MUT` | the self parameter must be mutable in the destructor |
| [E4049](E4049.md) | `EMPTY_ARRAY_INNER` | array inner type cannot be <> |
| [E4050](E4050.md) | `EMPTY_FORMAT_EMBED` | empty interpolation, expected an expression between ${ and } |
| [E4051](E4051.md) | `EMPTY_METHOD_CALL` | cannot perform a direct call of the method <> that is empty |
| [E4052](E4052.md) | `ENCLOSE_INCOMPLETE_TYPE` | the type <> cannot be enclosed because it is not complete |
| [E4053](E4053.md) | `ENCLOSE_MOVABLE_TYPE` | movable type <> cannot be enclosed within a closure function |
| [E4054](E4054.md) | `EXCEPTION_NOT_CAUGHT` | scope guard does not catch exceptions of type <> |
| [E4055](E4055.md) | `EXIT_SCOPE_NO_THROW` | <> guard cannot be used when guarding a scope that cannot throw |
| [E4056](E4056.md) | `EXIT_SCOPE_VALUE_TYPE` | <> scope guard value must be of type void, not <> |
| [E4057](E4057.md) | `EXTERN_GLOBAL_NO_TYPE` | external global variable must be declared with a type |
| [E4058](E4058.md) | `EXTERN_GLOBAL_WITH_VALUE` | external global variable cannot be declared with a value |
| [E4059](E4059.md) | `FIELD_MATCHER_NO_NAME` | expected a name expression |
| [E4060](E4060.md) | `FIELD_METHOD_ACCESS_NO_RETURN` | field access method must return a value |
| [E4061](E4061.md) | `FIELD_METHOD_ALIAS` | method <> is a field method |
| [E4062](E4062.md) | `FIELD_METHOD_ASSIGN_CONST` | field assign method must be mutable |
| [E4063](E4063.md) | `FIELD_METHOD_ASSIGN_WITH_RETURN` | field assign method must not return a value |
| [E4065](E4065.md) | `FIELD_METHOD_MUTABLE_ALIAS` | field method <> is mutable |
| [E4066](E4066.md) | `FIELD_METHOD_PARAMS` | field method cannot have more than one parameter |
| [E4067](E4067.md) | `FORBID_DECO_FOR_LOOP` | decorators are forbidden for index iterator, on <> iteration |
| [E4068](E4068.md) | `FORWARD_REFERENCE_AKA` | the name alias <> cannot be validated due to forward reference |
| [E4069](E4069.md) | `FORWARD_REFERENCE_TYPE` | the type cannot be validated due to forward reference |
| [E4072](E4072.md) | `FOR_LOOP_CPTR` | overriding the for loop operation on a class type <> |
| [E4073](E4073.md) | `FUNCTION_TO_FPTR_ENTITY` | cannot create a function pointer, entities are not copiable |
| [E4074](E4074.md) | `FUNCTION_TO_FPTR_RECORD` | cannot create a function pointer, it would enclose the record by reference |
| [E4075](E4075.md) | `FUNCTION_TO_FPTR_RECORD_DCOPY` | using a deep copy instead of a one level copy is prohibited when enclosing a record |
| [E4076](E4076.md) | `FUNCTION_TO_FPTR_THROWING` | cannot create a function pointer from the throwing function <> |
| [E4077](E4077.md) | `FUNCTION_TO_FPTR_UNSAFE` | cannot create a function pointer from the unsafe function <> |
| [E4078](E4078.md) | `FUNCTION_TO_OPTION_NO_THROW` | cannot create an option delegate from the non throwing function <> |
| [E4079](E4079.md) | `GEN_CTOR_HIDDEN_FIELD_NO_VALUE` | the field <> is not public, and has no initial value to be constructed from |
| [E4080](E4080.md) | `GLOBAL_NO_VALUE` | local global variable must be declared with a value |
| [E4081](E4081.md) | `IF_COND_NOT_COMPLETE` | the if condition has no else value, so it must produce a void value not a <> |
| [E4082](E4082.md) | `IMMUTABLE_LVALUE` | left operand of type <> is immutable |
| [E4083](E4083.md) | `IMMUTABLE_PARENT` | type must be immutable |
| [E4084](E4084.md) | `IMPLICIT_ADDRESS_FUNCTION` | cannot create a function pointer from <> implicitly |
| [E4085](E4085.md) | `IMPLICIT_ADDRESS_METHOD` | cannot create a delegate from the method <> implicitly |
| [E4086](E4086.md) | `IMPLICIT_CONST_REFERENCE` | ref of type <> must be const, but is mutable |
| [E4087](E4087.md) | `IMPLICIT_LAZY` | cannot construct a lazy value of type <> implicitly |
| [E4088](E4088.md) | `IMPLICIT_MOVE` | implicit move of type <> is prohibited |
| [E4089](E4089.md) | `IMPLICIT_MUT_REFERENCE` | ref of type <> must be mutable, but is const |
| [E4090](E4090.md) | `IMPLICIT_OVERRIDE` | method <> implicitly overrides method <> |
| [E4091](E4091.md) | `IMPLICIT_OVERRIDE_BY_TRAIT` | implicit override of method <> by trait impl |
| [E4092](E4092.md) | `IMPLICIT_REFERENCE` | cannot pass value of type <> as ref |
| [E4093](E4093.md) | `IMPL_MULTIPLE_TIMES` | trait <> is implemented multiple times by <> |
| [E4094](E4094.md) | `IMPL_NO_TRAIT` | impl statement must be followed by a trait, not <> |
| [E4095](E4095.md) | `INCOMPATIBLE_TYPE` | incompatible types <> and <> |
| [E4096](E4096.md) | `INCOMPATIBLE_VALUES` | incompatible values <> and <> |
| [E4097](E4097.md) | `INCOMPLETE_TYPE` | the type <> is not complete |
| [E4099](E4099.md) | `INDEX_ASSIGN_NOT_MUTABLE` | index assignment of a value of type <> requires a mutable value |
| [E4100](E4100.md) | `INFINITE_LOOP` | infinite loop with always true test is not allowed, rather use a loop construct |
| [E4101](E4101.md) | `INHERIT_FINAL_CLASS` | the base class <> is marked as final |
| [E4102](E4102.md) | `INHERIT_NO_CLASS` | the base of a class must be a class, not a <> |
| [E4103](E4103.md) | `INLINE_VIRTUAL_METHOD` | method <> cannot be inline as it is virtual(overridable or inherited) |
| [E4104](E4104.md) | `INVALID_SYMBOLS` | symbol <> has errors |
| [E4105](E4105.md) | `IS_A_METHOD` | <> is a method and must be called from an instance |
| [E4106](E4106.md) | `IS_NATIVE_TYPE` | the identifier <> describes a native type but has no meaning within this context |
| [E4107](E4107.md) | `IS_NOT_CALLABLE` | call operator is not defined for value <> |
| [E4108](E4108.md) | `LAZY_VALIDATION` | validation of lazy closure function fails to generate value of type <> |
| [E4109](E4109.md) | `LIST_COMPR_SIZE_CTE` | the size of the list comprehension, constructed from type <>, must be determinable at compile time |
| [E4110](E4110.md) | `MACRO_CALL_VALIDATION_FAILED` | validation of macro call failed |
| [E4111](E4111.md) | `MACRO_DOES_NOT_MATCH` | macro call with "<>" does not match the rule "<>" |
| [E4112](E4112.md) | `MACRO_REST` | macro validation is not complete, some tokens remain unassociated  <> <> <> |
| [E4113](E4113.md) | `MAIN_FUNCTION_ONE_ARG` | main function takes at most one argument |
| [E4114](E4114.md) | `MAIN_INLINE` | main function cannot be inline |
| [E4115](E4115.md) | `MALFORMED_CHAR` | malformed literal, number of <> is <> |
| [E4116](E4116.md) | `MALFORMED_CORE` | core module is malformed |
| [E4117](E4117.md) | `MALFORMED_FLOAT_LITERAL` | malformed float literal <> |
| [E4118](E4118.md) | `MALFORMED_INT_LITERAL` | malformed int literal <> |
| [E4119](E4119.md) | `MALFORMED_PRAGMA` | malformed __pragma <> |
| [E4120](E4120.md) | `MAP_KEY_MUTABLE` | the type <> that is used as a map key must always be immutable |
| [E4121](E4121.md) | `MAP_KEY_NOT_COMPARABLE` | the type <> cannot be used as a key, it is not comparable |
| [E4122](E4122.md) | `MAP_KEY_NOT_HASHABLE` | the type <> cannot be used as a key, it is not hashable |
| [E4123](E4123.md) | `MATCH_NOT_COMPLETE` | the pattern matching has no default case, so each branch must produce a void value not a <> |
| [E4124](E4124.md) | `MAX_LOOP_ITERATIONS` | reached the maximum number of cte iterations <> > <> |
| [E4125](E4125.md) | `MISMATCH_ALIAS_EXPAND` | cannot alias an expand value, maybe alias and expand keywords are inverted? (expand alias V) |
| [E4126](E4126.md) | `MISMATCH_ALIAS_LAZY` | cannot alias a lazy value, maybe alias and lazy keywords are inverted? (lazy alias V) |
| [E4127](E4127.md) | `MISMATCH_COPY_EXPAND` | cannot copy an expand value, maybe copy and expand keywords are inverted? (expand copy V) |
| [E4128](E4128.md) | `MISMATCH_COPY_LAZY` | cannot copy a lazy value, maybe copy and lazy keywords are inverted? (lazy copy V) |
| [E4129](E4129.md) | `MISMATCH_DCOPY_EXPAND` | cannot copy an expand value, maybe dcopy and expand keywords are inverted? (expand dcopy V) |
| [E4130](E4130.md) | `MISMATCH_DCOPY_LAZY` | cannot copy a lazy value, maybe dcopy and lazy keywords are inverted? (lazy dcopy V) |
| [E4131](E4131.md) | `MISMATCH_TUPLE_ARITY` | mismatch tuple arity <> and <> |
| [E4133](E4133.md) | `MULTIPLE_FIELD_INIT` | field <> is initialized multiple times |
| [E4134](E4134.md) | `MULTIPLE_NAMED_PARAM` | named parameter <> is set multiple times |
| [E4135](E4135.md) | `MULTIPLE_SYMBOL_TYPES` | expression refers to multiple symbols that generate types |
| [E4136](E4136.md) | `MULTIPLE_UNSAFE` | context is already unsafe |
| [E4137](E4137.md) | `MUTABLE_CONST_ITERATOR` | an iterator cannot be mutable, if it is not a reference or does not borrow mutable data |
| [E4138](E4138.md) | `MUTABLE_CONST_PARAM` | a parameter cannot be mutable, if it is not a reference or does not borrow mutable data |
| [E4139](E4139.md) | `MUTABLE_LAMBDA_VAR` | a lambda variable cannot be mutable |
| [E4140](E4140.md) | `MUTABLE_LAZY_VAR` | a lazy variable cannot be mutable, if it does not borrow mutable data |
| [E4141](E4141.md) | `MUTABLE_METHOD` | method <> is defined as mutable |
| [E4142](E4142.md) | `NEGATIVE_INT_INDEX` | index cannot be negative for type <>, but is <> |
| [E4143](E4143.md) | `NEVER_ENTERED_LOOP` | loop test is always false, loop is never entered |
| [E4144](E4144.md) | `NON_ABSTRACT_NOT_COMPLETE` | class <> is not abstract but has empty methods |
| [E4145](E4145.md) | `NOTHING_TO_CATCH` | nothing to catch |
| [E4146](E4146.md) | `NOT_ALIASABLE` | <> is not an aliasable type |
| [E4147](E4147.md) | `NOT_ANCESTOR` | <> is not an ancestor type of <> |
| [E4148](E4148.md) | `NOT_AN_ARRAY` | <> is not an array type |
| [E4149](E4149.md) | `NOT_AN_EXCEPTION_CLASS` | class type <> does not inherit from exception type <> |
| [E4150](E4150.md) | `NOT_A_CLASS` | <> is not a class type |
| [E4151](E4151.md) | `NOT_A_LVALUE` | not a lvalue |
| [E4152](E4152.md) | `NOT_A_LVALUE_CLOSURE` | <> is enclosed, and cannot be used as a lvalue |
| [E4153](E4153.md) | `NOT_A_LVALUE_ITERATOR` | <> is a value iterator, and cannot be used as a lvalue |
| [E4154](E4154.md) | `NOT_A_LVALUE_LAZY` | <> is a lazy variable, and cannot be used as a lvalue |
| [E4155](E4155.md) | `NOT_A_LVALUE_MAP_ACCESS` | <> is a map access, and cannot be used as a lvalue |
| [E4156](E4156.md) | `NOT_A_LVALUE_PARAM` | <> is a value parameter, and cannot be used as a lvalue |
| [E4157](E4157.md) | `NOT_A_LVALUE_TYPE` | value of type <> is not a lvalue |
| [E4158](E4158.md) | `NOT_A_MAP` | <> is not a map type |
| [E4159](E4159.md) | `NOT_A_RECORD` | <> is not a record type |
| [E4160](E4160.md) | `NOT_A_SLICE` | <> is not a slice type |
| [E4161](E4161.md) | `NOT_AN_ENTITY` | <> is not an entity type |
| [E4162](E4162.md) | `NOT_A_TRAIT` | <> is not a trait |
| [E4163](E4163.md) | `NOT_A_TUPLE` | <> is not a tuple type |
| [E4165](E4165.md) | `NOT_MOVABLE` | type <> is not a movable type |
| [E4166](E4166.md) | `NOT_UNSAFE` | an unsafe context is entered, but no unsafe operations are made |
| [E4167](E4167.md) | `NO_COPY_EXIST` | no copy exists for type <> |
| [E4168](E4168.md) | `NO_CTOR_FOUND` | no constructor found for class <> |
| [E4169](E4169.md) | `NO_CTOR_FOUND_NAME` | no constructor named <> found for class <> |
| [E4170](E4170.md) | `NO_DEFAULT_CTOR_MOVE_STRUCT` | type <> is an entity, but has no default ctor self() |
| [E4171](E4171.md) | `NO_PARAMETER_NAMED` | no parameter is named <> |
| [E4172](E4172.md) | `NO_SIZE_FORWARD_REF` | record or entity type <> has no size due to forward references |
| [E4173](E4173.md) | `NO_SUPER_CLASS` | class <> has no ancestor |
| [E4175](E4175.md) | `OPTION_HAS_NO_ERROR` | option of type <> has no error |
| [E4176](E4176.md) | `OPTION_HAS_NO_VALUE` | option of type <> has no value |
| [E4177](E4177.md) | `OPTION_MATCHER` | option matcher <> only applies to option values not <> |
| [E4178](E4178.md) | `OVERFLOW_CAPACITY` | overflow capacity for type <> = <>, maximum value is <> |
| [E4179](E4179.md) | `OVERFLOW_CAPACITY_ARRAY` | static array size <> exceeds limits <> |
| [E4180](E4180.md) | `OVERFLOW_CAPACITY_MIN` | overflow capacity for type <> = <>, minimum value is <> |
| [E4181](E4181.md) | `OVERRIDE_EMPTY` | method <> must have a body to override <> |
| [E4182](E4182.md) | `OVERRIDE_FIELD_NO_FIELD` | method <> must be a field method to override <> |
| [E4183](E4183.md) | `OVERRIDE_FINAL` | cannot override final method <> |
| [E4184](E4184.md) | `OVERRIDE_INCOMPATIBLE_RETURN_TYPE` | the return type of the overriding method <> is not compatible with the return type of the ancestor method <> |
| [E4185](E4185.md) | `OVERRIDE_MISMATCH_PROTECTION` | the protection <> of the overriding method <> does not match the definition in the ancestor class <> |
| [E4186](E4186.md) | `OVERRIDE_MISMATCH_THROWERS` | the throwers of the overriding method <> are not compatible with the throwers of the ancestor method <> |
| [E4187](E4187.md) | `OVERRIDE_MULTIPLE_TIMES_TRAIT` | trait method <> was already overridden |
| [E4188](E4188.md) | `OVERRIDE_NON_TRAIT_INSIDE` | cannot override a non trait method <> with <> inside impl |
| [E4189](E4189.md) | `OVERRIDE_NOTHING` | method <> overrides nothing |
| [E4190](E4190.md) | `OVERRIDE_NO_FIELD_BY_FIELD` | field method <> cannot override the non field method <> |
| [E4192](E4192.md) | `OVERRIDE_TRAIT_OUTSIDE` | cannot override trait method <> with <> outside impl |
| [E4193](E4193.md) | `PATTERN_IS_REFUTABLE` | the pattern <> with value <> is refutable |
| [E4195](E4195.md) | `RANGE_ON_ARRAY_NO_COPY` | the index operator on <> with a dynamic operand of type <> is allowed only in the context of a copy statement |
| [E4196](E4196.md) | `RECURSIVE_ANCESTOR` | ancestor cycle found when validating <> |
| [E4197](E4197.md) | `RETURN_NO_FUNCTION` | return statement is not within a function |
| [E4198](E4198.md) | `RETURN_SCOPE_GUARD` | cannot return inside a scope guard |
| [E4199](E4199.md) | `SHADOWING_DECL` | declaration of <> shadows another declaration |
| [E4200](E4200.md) | `SUPER_NO_SELF_CLASS` | the superclass proxy of <> is only accessible through self |
| [E4201](E4201.md) | `TEMPLATE_REST` | template validation is not complete, unresolved: {<>} |
| [E4202](E4202.md) | `TEMPLATE_SPECIALIZATION_FAILS` | template specialization for <> fails with <> |
| [E4203](E4203.md) | `TEMPLATE_SPECIALIZATION_FAILS_SIMPLE` | template specialization fails with <> |
| [E4204](E4204.md) | `TEMPLATE_TEST_FAILED` | the test of the template specialization failed |
| [E4205](E4205.md) | `THROWS_IN_LAMBDA` | a lambda function must be safe, but there are exceptions that are not caught |
| [E4206](E4206.md) | `THROWS_NOT_DECLARED` | the function <> might throw an exception of type <>, but that is not declared in its prototype |
| [E4207](E4207.md) | `THROWS_NOT_DECLARED_OVER` | the method might throw an exception of type <>, but that is not covered by the method of the ancestor class |
| [E4208](E4208.md) | `THROWS_NOT_USED` | the prototype of the function <> declares a possible throw of an exception of type <>, but the function never throws it |
| [E4209](E4209.md) | `THROW_NO_FUNCTION` | throw statement is not within a function |
| [E4210](E4210.md) | `THROW_SCOPE_GUARD` | cannot throw exception inside a scope guard |
| [E4211](E4211.md) | `THROW_SCOPE_GUARD_RETHROW` | rethrowing an exception of type <> inside a scope guard is forbidden |
| [E4212](E4212.md) | `TOO_FEW_PARAMETERS` | <> parameters <> expected, but <> <> provided |
| [E4213](E4213.md) | `TUPLE_AFFECT_OPERATOR` | tuple left affectation is only defined for the operator <> |
| [E4214](E4214.md) | `TUPLE_ARITY_OVERFLOW` | tuple access out of bound(<>), tuple arity is <> |
| [E4216](E4216.md) | `TUPLE_PATTERN` | pattern <> only matches tuple values, not <> |
| [E4217](E4217.md) | `TYPE_HAS_NO_FIELDINFO` | type <> has no fields |
| [E4218](E4218.md) | `TYPE_HAS_NO_SIZE` | temporary type <> has no size |
| [E4219](E4219.md) | `TYPE_HAS_NO_TYPEINFO` | temporary type <> has no type information |
| [E4220](E4220.md) | `TYPE_NO_FIELD` | type <> has no field named <> |
| [E4221](E4221.md) | `UNDEFINED_ATTRIBUTE` | attribute <> is not usable in this context |
| [E4222](E4222.md) | `UNDEFINED_BIN_ACC_OP` | undefined operator <> for type <> and field <> |
| [E4223](E4223.md) | `UNDEFINED_BIN_MOD_OP` | undefined module operator <> for <> and field <> |
| [E4224](E4224.md) | `UNDEFINED_BIN_OP` | undefined operator <> for types <> and <> |
| [E4225](E4225.md) | `UNDEFINED_BIN_OP_TOK` | undefined binary operator <> |
| [E4226](E4226.md) | `UNDEFINED_CALL_OP` | the call operator is not defined for <> and <> |
| [E4227](E4227.md) | `UNDEFINED_CAST_OP` | cannot cast value of type <> into a value of type <> |
| [E4228](E4228.md) | `UNDEFINED_CTOR_MACRO` | macro <> has no accessible constructors in that context |
| [E4229](E4229.md) | `UNDEFINED_DOLLAR_OP` | operator $ is not defined for type <> |
| [E4230](E4230.md) | `UNDEFINED_ESCAPE` | undefined escape sequence |
| [E4231](E4231.md) | `UNDEFINED_INDEX_OP` | the index operator is not defined for type <> and <> |
| [E4232](E4232.md) | `UNDEFINED_MACRO_CALL` | macro call is undefined for <> |
| [E4233](E4233.md) | `UNDEFINED_REDIRECT_CALL_CTOR` | no constructor is callable with the parameters <> |
| [E4234](E4234.md) | `UNDEFINED_RULE_MACRO` | macro symbol <> has no rule named <> |
| [E4236](E4236.md) | `UNDEFINED_TEMPLATE_CALL` | undefined template call for <> with <> |
| [E4237](E4237.md) | `UNDEFINED_UN_OP` | undefined operator <> for type <> |
| [E4238](E4238.md) | `UNDEFINED_UN_OP_TOK` | undefined unary operator <> |
| [E4239](E4239.md) | `UNDEF_CTE_FOR_LOOP_OPERATOR` | undefined cte for loop operator with <> iterator for type <> |
| [E4240](E4240.md) | `UNDEF_DECORATOR_HERE` | decorator <> is not applicable in that context |
| [E4242](E4242.md) | `UNDEF_DECORATOR_TYPE` | decorator <> is not applicable for types |
| [E4244](E4244.md) | `UNDEF_FOR_LOOP_OPERATOR` | undefined for loop operator with <> iterator for type <> |
| [E4245](E4245.md) | `UNDEF_VAR` | undefined symbol <> |
| [E4246](E4246.md) | `UNECESSARY_ADDRESS_METHOD` | the creation of a delegate from a method has no effect |
| [E4247](E4247.md) | `UNECESSARY_ALIAS` | aliasing the value of type <> to create a constant borrowing is prohibited |
| [E4248](E4248.md) | `UNECESSARY_ALIAS_CPTR_LOOP` | aliasing the value of type <> to call begin and end iterator constant methods is useless |
| [E4249](E4249.md) | `UNECESSARY_LAZY` | the construction of a lazy value has no effect |
| [E4250](E4250.md) | `UNECESSARY_LMBD_COPY` | copy the lambda closure has no effect, no values are enclosed |
| [E4251](E4251.md) | `UNECESSARY_MOVE` | the move has no effect |
| [E4252](E4252.md) | `UNECESSARY_REFERENCE` | referencing the value has no effect |
| [E4253](E4253.md) | `UNINIT_FIELD` | the field <> has no initial value |
| [E4256](E4256.md) | `UNKNOWN_AT_COMPILE_TIME` | value of type <> is needed but unknown at compilation time |
| [E4257](E4257.md) | `UNKNOWN_LENGTH_OF_EXPANSION` | unknown length of expansion for type <> |
| [E4258](E4258.md) | `UNKNOWN_PRAGMA` | unknown __pragma expression <> |
| [E4259](E4259.md) | `UNREACHABLE_MATCHER` | matcher expression is never evaluated |
| [E4260](E4260.md) | `UNREACHBLE_STATEMENT` | unreachable statement |
| [E4261](E4261.md) | `UNRESOLVED_TEMPLATE` | unresolved template |
| [E4262](E4262.md) | `UNSAFE_CALL` | call of unsafe function outside unsafe context |
| [E4263](E4263.md) | `UNSAFE_OPERATION` | unsafe operation outside unsafe context |
| [E4264](E4264.md) | `UNTERMINATED_ESCAPE` | unterminated escape sequence |
| [E4265](E4265.md) | `UNTERMINATED_FORMAT_EMBED` | unterminated interpolation, missing closing } |
| [E4266](E4266.md) | `USELESS_COND_FALSE` | conditional test is always evaluated to false, branch is never entered |
| [E4267](E4267.md) | `USELESS_OPTION_OR_ELSE` | operator <> is useless, the left operand of type <> always has a value |
| [E4268](E4268.md) | `USELESS_COND_TRUE` | conditional test is always evaluated to true, branch is always entered |
| [E4269](E4269.md) | `USELESS_RUNTIME_ASSERT` | useless runtime assertion for a test that is always true |
| [E4270](E4270.md) | `USE_AS_TYPE` | expression produces a value, but is used as a type |
| [E4271](E4271.md) | `USE_AS_TYPE_TEMPLATE` | template specialization expected a type not the value <> |
| [E4272](E4272.md) | `USE_AS_TYPE_VAL` | expression produces a value of type <>, but is used as a type |
| [E4273](E4273.md) | `USE_AS_VALUE` | expression produces a type, but is used as a value |
| [E4274](E4274.md) | `USE_AS_VALUE_TEMPLATE` | template specialization expected a value not the type <> |
| [E4275](E4275.md) | `USE_AS_VALUE_TYPE` | expression produces the type <>, but is used as a value |
| [E4276](E4276.md) | `VAR_DECL_WITHOUT_VALUE` | var declared without value, when necessary |
| [E4277](E4277.md) | `VAR_DECL_WITH_NOTHING` | var declaration must at least have a type or a value |
| [E4278](E4278.md) | `VOID_VALUE` | void expression cannot be used as a value |
| [E4280](E4280.md) | `WORKS_WITH_BOTH` | <> called with <> works with multiple candidates |
| [E4281](E4281.md) | `DECLARE_VARIABLE_NO_FUNCTION` | var declaration <> outside a function context |
| [E4282](E4282.md) | `NOT_SUPPORTED_IN` | not supported in version ymir <> |

## E5xxx -- lowering (YIL)

| Code | Name | Message |
|---|---|---|
| [E5001](E5001.md) | `FAILED_TO_CREATE_OUT_DIR` | failed to create YIL output directory <>, permission denied |
| [E5002](E5002.md) | `FAILED_TO_READ_BYTE_FILE` | failed to read YIL byte file <>, file not found or permission denied |
| [E5003](E5003.md) | `FAILED_TO_PARSE_BYTE_FILE` | failed to read YIL byte file <>, file format error |
| [E5004](E5004.md) | `FAILED_TO_WRITE_BYTE_FILE` | failed to write YIL byte file <>, permission denied |
| [E5005](E5005.md) | `MALFORMED_BYTECODE` | malformed bytecode |
| [E5006](E5006.md) | `MALFORMED_BYTECODE_TYPE_TABLE` | malformed bytecode, type table invalid |
| [E5007](E5007.md) | `MALFORMED_BYTECODE_STRING_TABLE` | malformed bytecode, string table invalid |
| [E5008](E5008.md) | `MALFORMED_BYTECODE_SYMBOL_TABLE` | malformed bytecode, symbol table invalid |
| [E5009](E5009.md) | `MALFORMED_BYTECODE_LOCATION_TABLE` | malformed bytecode, location table invalid |
| [E5010](E5010.md) | `MISMATCH_ARCH_POINTER_SIZE` | YIL byte file was created for a <> bits target, mismatch current target arch <> bits |

## Retired

These codes named messages that have since been deleted from the compiler.
Nothing raises them today. They are listed so a code printed by an older compiler
can still be looked up, and so neither the code nor the name is ever reused.

| Code | Name | Message it named |
|---|---|---|
| [E2003](E2003.md) | `MULTIPLE_AUX_CSTRS` | multiple constructor redirects are not permitted |
| [E2005](E2005.md) | `UNDEFINED_ATTRIBUTE` | undefined attribute <> |
| [E2010](E2010.md) | `UNTERMINATED_BLOCK` | unterminated block |
| [E2011](E2011.md) | `USED_AS_IDENTIFIER` | <> cannot be used as an identifier |
| [E4025](E4025.md) | `CONFLIT_DECORATORS` | conflicting decorators <> and <> |
| [E4032](E4032.md) | `CTE_IGNORED` | <> values contained in a block scope are ignored during compile time execution |
| [E4064](E4064.md) | `FIELD_METHOD_COLLISION` | field method <> cannot be overlapped by a method with the same name <> |
| [E4070](E4070.md) | `FORWARD_REFERENCE_VALUE` | the value cannot be computed, as it depends on a forward reference |
| [E4071](E4071.md) | `FORWARD_REFERENCE_VAR` | the type cannot be inferred, as it depends on a forward reference |
| [E4098](E4098.md) | `INCOMPLETE_TYPE_CLASS` | the type <> is not complete due to previous errors |
| [E4132](E4132.md) | `MULTIPLE_DECORATORS` | decorator <> is specified multiple times |
| [E4164](E4164.md) | `NOT_AN_UNION` | <> is not a union type |
| [E4174](E4174.md) | `ONE_ITER_LOOP` | do while loop test is always false, the loop is always entered exactly once, so the branching construct is useless |
| [E4191](E4191.md) | `OVERRIDE_PRIVATE` | cannot override private method <> |
| [E4194](E4194.md) | `PRAGMA_FIELD_NO_DEFAULT` | field <> from type <> has no default value |
| [E4215](E4215.md) | `TUPLE_MATCHER` | tuple matcher only applies to tuple values not <> |
| [E4235](E4235.md) | `UNDEFINED_SUPER_CALL_CTOR` | no constructor of the super class is callable with the parameters <> |
| [E4241](E4241.md) | `UNDEF_DECORATOR_TEMPLATE` | decorator <> is not applicable in template specialization |
| [E4243](E4243.md) | `UNDEF_DECORATOR_VALUE` | decorator <> is not applicable for values |
| [E4254](E4254.md) | `UNION_CTOR_MULTIPLE_FIELDS` | constructor of the union type <> initializes multiple fields <> |
| [E4255](E4255.md) | `UNION_CTOR_NO_FIELD` | constructor of the union type <> initializes no field |
| [E4279](E4279.md) | `VOID_VAR` | cannot create a variable of type void |

