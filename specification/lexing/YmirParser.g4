parser grammar YmirParser;
options {
	tokenVocab = YmirLexer;
}

program: (module_root)? block_declaration;
module_root: MOD path SEMI_COL ;
path: ID (DCOLON ID)* ;


/**
 * ============================
 * DECLARATIONS
 * ============================
 */

block_declaration: protection_block
                   | version_block
                   | extern_block
                   | open_block_declaration
                   | declaration* ;

protection_block: (PUB | PRV) block_declaration ;
version_block: VERSION ID block_declaration (ELSE block_declaration)? ;
extern_block: EXTERN (LPAR C RPAR)? block_declaration;
open_block_declaration: LBRACK block_declaration RBRACK ;

declaration: aka
    | class
    | enum
    | function
    | global_var_decl
    | import_decl
    | macro
    | module
    | struct
    | trait
    | unittest
    ;

attributes: AT LBRACK ID (COMA ID)* RBRACK
            | AT ID
            ;


aka: AKA ID EQUAL any_expression SEMI_COL ;

import_decl: IMPORT single_import SEMI_COL ;
single_import: path (AKA ID)? ;

/**
 * ============================
 * ENUM
 * ============================
 */

enum: enum_template
    | enum_simple
    ;

enum_template: ENUM (IF any_expression)? enum_content SARROW ID template_param_list SEMI_COL ;
enum_simple: ENUM enum_content SARROW ID SEMI_COL ;
enum_content: (PIPE ID EQUAL any_expression)* ;

/**
 * ============================
 * ENUM
 * ============================
 */

global_var_decl: LET single_var_decl SEMI_COL ;

/**
 * ============================
 * MACRO
 * ============================
 */

macro: MACRO ID LBRACK macro_content* RBRACK ;
macro_content: PUB macro_content
    | VERSION ID macro_content (ELSE macro_content)?
    | import_decl
    | LBRACK macro_content* RBRACK
    | macro_rule
    | macro_ctor
    ;

macro_ctor: SELF macro_head_rule macro_body_rule ;
macro_rule: DEF ID macro_head_rule (macro_body_rule | SEMI_COL) ;

macro_head_rule: macro_inner_mult (SKIPS (string_lit (PIPE string_lit)*))? ;
macro_inner_mult: LPAR (macro_expression*) RPAR
    | LPAR (macro_expression PIPE macro_expression)* RPAR
    ;

macro_expression: macro_inner_mult (multiplicator)?
    | ID EQUAL macro_expression
    | string_lit
    | any_expression_10
    ;            

macro_body_rule: LBRACK ( ~(LBRACK | RBRACK) | macro_body_rule)* RBRACK ;
multiplicator: (STAR | ADD | EXCLAM) ;
  
/**
 * ============================
 * MODULE
 * ============================
 */

module: module_template
    | module_simple
    ;

module_template: MOD (IF any_expression) ID template_param_list block_declaration ;
module_simple: MOD ID block_declaration ;

/**
 * ============================
 * STRUCT
 * ============================
 */

struct: struct_template
    | struct_simple
    ;

struct_template: STRUCT (IF any_expression)?
        struct_field*
        SARROW ID template_param_list SEMI_COL
    ;

struct_simple: STRUCT struct_field* SARROW ID SEMI_COL ;
struct_field: PIPE single_var_decl ;


/**
 * ============================
 * TRAIT
 * ============================
 */


trait: trait_template
    | trait_simple
    ;

trait_template: TRAIT (IF any_expression)? ID
        template_param_list
        LBRACK
        class_content
        RBRACK
    ;

trait_simple: TRAIT ID LBRACK class_content RBRACK ;


/**
 * ============================
 * UNITTEST
 * ============================
 */

unittest: TEST any_expression ;

/**
 * ============================
 * FUNCTION
 * ============================
 */

function: function_template
    | function_simple
    ;

function_template: DEF (IF any_expression)? (attributes)? ID template_param_list
        function_param_list (SARROW any_expression)?
        (throws_decl)? any_expression ;

function_simple: DEF (attributes)? ID function_param_list (SARROW any_expression)?
        (throws_decl)? any_expression ;

function_param_list: LPAR (single_var_decl (COMA single_var_decl)*)? RPAR ;
param_list: (single_var_decl (COMA single_var_decl)*)? ;

throws_decl: THROWS any_expression (COMA any_expression)* ;

/**
 * ============================
 * CLASS
 * ============================
 */

class: template_class
    | simple_class
    ; 

template_class: CLASS (IF any_expression)? (attributes)?
                ID template_param_list (OVER any_expression)?
                LBRACK class_content RBRACK ;

simple_class: CLASS (attributes)? ID (OVER any_expression)? LBRACK class_content RBRACK ;

class_content: (
          class_protection_block
        | class_version_block
        | class_cte_block
        | class_inner_declaration
        )*
    ;

class_inner_declaration: class_simple_inner_declaration
    | class_impl
    | import_decl
    | class_dtor
    ;

class_simple_inner_declaration: class_ctor
    | class_function
    | LET single_var_decl SEMI_COL
    ;

class_protection_block: (PUB | PROT | PRV) (class_simple_inner_declaration | (LBRACK class_simple_inner_declaration* RBRACK)) ;
class_version_block: VERSION ID class_content (ELSE class_content)? ;
class_cte_block: CTE IF any_expression LBRACK class_content RBRACK (ELSE LBRACK class_content RBRACK)? ;

class_ctor: class_ctor_template
    | class_ctor_simple
    ;

class_ctor_template: SELF (IF any_expression) (attributes)? template_param_list
        function_param_list
        (class_ctor_with)? (throws_decl)?
        any_expression
    ;

class_ctor_simple: SELF (attributes)? function_param_list
        (class_ctor_with)? (throws_decl)?
        any_expression
    ;

class_ctor_with: WITH ID EQUAL any_expression (COMA ID EQUAL any_expression)* ;

class_impl: IMPL any_expression LBRACK class_function_simple* RBRACK
    | IMPL any_expression (COMA any_expression)* SEMI_COL ;


class_function: class_function_template
    | class_function_simple
    ;

class_function_template: DEF (IF any_expression)? ID template_param_list
        class_function_param_list (SARROW any_expression)? (throws_decl)?
        any_expression
    ;

class_function_simple: (DEF | OVER) ID
        class_function_param_list (SARROW any_expression)? (throws_decl)?
        any_expression
    ;

class_function_param_list: LPAR (MUT)? SELF (COMA single_var_decl)* RPAR ;

class_dtor: DTOR LPAR MUT SELF RPAR any_expression ;

/**
 * ============================
 * FUNCTION
 * ============================
 */


/**
 * ============================
 * TEMPLATES
 * ============================
 */

template_checker: IS template_call template_param_list ;
template_call: NOT ((LBRACK call_list RBRACK) | operand_3) ;
template_param_list: LBRACK template_param (COMA template_param)* RBRACK ;

template_param: STRUCT ID
    | CLASS ID
    | TUPLE ID
    | ALIAS ID
    | template_var_param
    | operand_3
    ;

template_var_param: ID COLON any_expression_10 (EQUAL any_expression)?
    | ID EQUAL any_expression
    | ID TDOT
    | ID OVER any_expression
    | ID OF any_expression
    | ID IMPL any_expression
    ;

/**
 * ============================
 * EXPRESSIONS
 * ============================
 */

operator_0: (EQUAL | DIV_EQUAL | MINUS_EQUAL | ADD_EQUAL | STAR_EQUAL | MOD_EQUAL | TILDE_EQUAL | LEFTD_EQUAL | RIGHTD_EQUAL) ;
operator_1: DPIPE ;
operator_2: DAND ;
operator_3: LT | GT | LEQ | GEQ | DEQUAL | NOT_EQUAL | OF | IS | IN | NOT_OF | NOT_IS | NOT_IN ;
operator_4: TDOT | DDOT ;
operator_5: LEFTD | RIGHTD ;
operator_6: PIPE | XOR | AND ;
operator_7: ADD | MINUS | TILDE ;
operator_8: STAR | DIV | MODULO ;
operator_9: DXOR ;

any_expression: expression_0 | expression_no_close_0 ;
any_expression_10: expression_10 | expression_no_close_10 ;

expression_0: expression_1 (operator_0 expression_0)?;
expression_1: expression_2 (operator_1 expression_1)?;
expression_2: expression_3 (operator_2 expression_2)?;
expression_3: expression_4 (operator_3 expression_3)?;
expression_4: expression_5 (operator_4 expression_4)?;
expression_5: expression_6 (operator_5 expression_5)?;
expression_6: expression_7 (operator_6 expression_6)?;
expression_7: expression_8 (operator_7 expression_7)?;
expression_8: expression_9 (operator_8 expression_8)?;
expression_9: expression_10 (operator_9 expression_9)?;
expression_10: operand_0;

expression_no_close_0: expression_no_close_1 (operator_0 expression_no_close_0)?;
expression_no_close_1: expression_no_close_2 (operator_1 expression_no_close_1)?;
expression_no_close_2: expression_no_close_3 (operator_2 expression_no_close_2)?;
expression_no_close_3: expression_no_close_4 (operator_3 expression_no_close_3)?;
expression_no_close_4: expression_no_close_5 (operator_4 expression_no_close_4)?;
expression_no_close_5: expression_no_close_6 (operator_5 expression_no_close_5)?;
expression_no_close_6: expression_no_close_7 (operator_6 expression_no_close_6)?;
expression_no_close_7: expression_no_close_8 (operator_7 expression_no_close_7)?;
expression_no_close_8: expression_no_close_9 (operator_8 expression_no_close_8)?;
expression_no_close_9: expression_no_close_10 (operator_9 expression_no_close_9)?;
expression_no_close_10: operand_no_close_0;

/**
 * ============================
 * OPERANDS
 * ============================
 */

unary_operator: (MINUS | AND | NOT | STAR);
operand_no_close_0: (unary_operator)? operand_no_close_1 (EXCLAM)?;
operand_no_close_1: block
                    | if_expr
                    | while_expr
                    | dowhile_expr
                    | for_expr
                    | loop_expr
                    | match_expr
                    | version_expr
                    | with_expr
                    | atomic_expr 
                    ;


operand_0: (unary_operator)? operand_1 (EXCLAM)?;
operand_1: var_decl
            | assert_expr
            | return_expr
            | break_expr
            | function_type_expr
            | delegate_type_expr
            | pragma_expr
            | operand_2 (operand_follow)?
            ;

operand_2: operand_3 (DCOLON operand_2 (template_call)?)? ;

operand_3: cast_expr
    | template_checker
    | array_literal
    | tuple_literal
    | lambda_literal
    | intrinsic
    | decorated_expr
    | literal
    | LPAR any_expression RPAR
    | ID
    | IntName
    | IntNameNoSize
    ;

operand_follow: LPAR call_list RPAR (operand_follow)?
                | (LCRO | AND_LCRO) call_list RCRO (operand_follow)?
                | (DOT | AND_DOT) operand_3 (template_call)? (operand_follow)? 
                | macro_call (operand_follow)?
                ;

macro_call: MacroLiteralC MACRO_TEXT_C MACRO_RCRO
    | MacroLiteralB MACRO_TEXT_B MACRO_RBRACK
    | MacroLiteralP MACRO_TEXT_P MACRO_RPAR
    ;

call_list: (any_expression (COMA any_expression)*)? ;

block: LBRACK ((expression_0 SEMI_COL) | expression_no_close_0 SEMI_COL?)* (any_expression)? RBRACK ;

/**
 * Match simple control flows
 */
if_expr: IF any_expression if_body (ELSE any_expression)? ;
if_body: block
         | (expression_no_close_0 | (expression_0 SEMI_COL?)) ;

while_expr: WHILE expression_0 while_body ;
while_body: block
            | (expression_no_close_0 | (expression_0 SEMI_COL?)) ;

assert_expr: ASSERT LPAR expression_0 (COMA expression_0)? RPAR ;
break_expr: BREAK (expression_0)? ;
return_expr: RETURN (expression_0)? ;
dowhile_expr: DO any_expression WHILE any_expression ;
loop_expr: LOOP while_body ;
throw_expr: THROW any_expression ;
version_expr: VERSION ID any_expression (ELSE any_expression)? ;
pragma_expr: PRAGMA NOT ID LPAR any_expression RPAR ;

/**
 * Match a for loop
 */
for_expr: FOR for_loop_decl for_loop_body ;
for_loop_decl: single_var_decl_no_value (COMA single_var_decl_no_value)* IN any_expression ;
for_loop_body: block
               | (expression_no_close_0 | (expression_0 SEMI_COL?)) ;


/**
 * Pattern matching
 */
match_expr: MATCH any_expression LBRACK (inner_matcher_expr DARROW any_expression_10)+ RBRACK;
inner_matcher_expr: single_var_decl_match
                    | calling_match
                    | par_match
                    | cro_match
                    | UNDER
                    | any_expression ;

decorator: DMUT | REF | MUT | LAZY | CTE | PURE | CONST ;
single_var_decl_match: (decorator)* (ID | UNDER) COLON (UNDER | any_expression_10) (EQUAL inner_matcher_expr)? ;
calling_match: (ID | UNDER) (DCOLON ID)* (template_call)? ((LPAR inner_matcher_expr RPAR) | (SARROW inner_matcher_expr)) ;

par_match: LPAR inner_matcher_expr (COMA inner_matcher_expr)* RPAR ;
cro_match: LCRO inner_matcher_expr (COMA inner_matcher_expr)* RCRO ;

/**
 * FPTRS
 */

function_type_expr: FN function_type_prototype (SARROW any_expression_10)? ;
delegate_type_expr: DG function_type_prototype (SARROW any_expression_10)? ;

function_type_prototype: LPAR (any_expression_10 (COMA any_expression_10)*)? RPAR ;

/**
 * Variable declaration
 */
var_decl: LET single_var_decl (COMA single_var_decl)*
          | LET destruct_decl ;

single_var_decl_no_value: (decorator)* (ID | UNDER) (COLON (expression_10 | expression_no_close_10))? ;
single_var_decl: single_var_decl_no_value (EQUAL any_expression)? ;
destruct_decl: LPAR single_var_decl_no_value (COMA single_var_decl_no_value)* RPAR EQUAL any_expression ;


/**
 * WITH expression
 */

with_expr: WITH single_var_decl (COMA single_var_decl)* with_body ;
with_body: block
            | ((expression_0 SEMI_COL) | (expression_no_close_0 SEMI_COL? ))
            ;

/**
 * ATOMIC expression
 */

atomic_expr: ATOMIC (any_expression)? atomic_body ;
atomic_body: block
             | ((expression_0 SEMI_COL) | (expression_no_close_0 SEMI_COL? ))
             ; 


/**
 * Operand 3
 */

cast_expr: CAST NOT ((LBRACK any_expression RBRACK) | operand_3) LPAR any_expression RPAR ;

array_literal: LCRO call_list RCRO ;
tuple_literal: LPAR ((any_expression COMA call_list)?) RPAR;
lambda_literal: PIPE param_list PIPE (SARROW any_expression_10)? (DARROW)? lambda_body ;
lambda_body: block
             | ((expression_0 SEMI_COL) | (expression_no_close_0 SEMI_COL? ))
             ;

intrinsic: intrinsic_keys (any_expression_10 | (LPAR any_expression RPAR)) ;
intrinsic_keys: COPY | EXPAND | TYPEOF | SIZEOF | ALIAS | DCOPY;

decorated_expr: decorator (any_expression_10 | (LPAR any_expression RPAR)) ; 
literal: IntegerLiteral
    | BooleanLiteral
    | FloatLiteral 
    | string_lit
    | CharLiteral CHAR_TEXT CHAR_LIT_END (C8 | C16 | C32)?
    | NULL
    | DOLLAR
    ;

string_lit: StringLiteral STRING_TEXT STRING_LIT_END (S8 | S16 | S32)? ;