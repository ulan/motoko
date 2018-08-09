%{

open Syntax
open Source 

(* Error handling *)

exception SyntaxError of region * string

let error at msg = raise (SyntaxError (at, msg))

let parse_error msg =
  error Source.no_region
    (if msg = "syntax error" then "unexpected token" else msg)


(* Position handling *)

let position_to_pos position =
  { file = position.Lexing.pos_fname;
    line = position.Lexing.pos_lnum;
    column = position.Lexing.pos_cnum - position.Lexing.pos_bol
  }

let positions_to_region position1 position2 =
  { left = position_to_pos position1;
    right = position_to_pos position2
  }

let at(symbolstartpos,endpos) =
  positions_to_region (symbolstartpos) (endpos)

(* Literals *)

let literal f s =
  try f s with Failure _ -> error s.at "constant out of range"

let nat s at =
  try
    let _ = String.iter (function '0'..'9' -> () | _ -> failwith "non-numeric digit") s in
    let n = int_of_string s in
    if n >= 0 then n else raise (Failure "")
  with Failure _ -> error at "integer constant out of range"

(* 
let nat32 s at =
  try i32.of_string_u s with Failure _ -> error at "i32 constant out of range"


let name s at =
  try Utf8.decode s with Utf8.Utf8 -> error at "invalid UTF-8 encoding"

*)

let (@?) x region = {it = x; at = region; note = Type.AnyT}
let (@!) x region = {it = x; at = region; note = Type.ConstMut}

%}

%token EOF

%token LET VAR
%token LPAR RPAR LBRACKET RBRACKET LCURLY RCURLY
%token AWAIT ASYNC BREAK CASE CONTINUE LABEL IF IN IS ELSE SWITCH LOOP WHILE FOR LIKE RETURN 
%token ARROW ASSIGN
%token FUNC TYPE ACTOR CLASS PRIVATE
%token SEMICOLON COMMA COLON SUB DOT QUEST
%token AND OR NOT 
%token ASSERT
%token ADDOP SUBOP MULOP DIVOP MODOP
%token ANDOP OROP XOROP SHLOP SHROP ROTLOP ROTROP
%token EQOP NEQOP LEOP LTOP GTOP GEOP
%token CATOP
%token EQ LT GT
%token PLUSASSIGN MINUSASSIGN MULASSIGN DIVASSIGN MODASSIGN CATASSIGN
%token ANDASSIGN ORASSIGN XORASSIGN SHLASSIGN SHRASSIGN ROTLASSIGN ROTRASSIGN
%token NULL
%token<string> NAT
%token<string> INT
%token<float> FLOAT
%token<Value.unicode> CHAR
%token<bool> BOOL
%token<string> ID
%token<string> TEXT
// %token<string Source.phrase -> Ast.instr' * Values.value> CONST

%token<Type.prim> PRIM

%token UNDERSCORE

%nonassoc IFX
%nonassoc ELSE

%right ASSIGN PLUSASSIGN MINUSASSIGN MULASSIGN DIVASSIGN MODASSIGN CATASSIGN ANDASSIGN ORASSIGN XORASSIGN SHLASSIGN SHRASSIGN ROTLASSIGN ROTRASSIGN
%left IS COLON
%left OR
%left AND
%nonassoc EQOP NEQOP LEOP LTOP GTOP GEOP
%left ADDOP SUBOP CATOP
%left MULOP DIVOP MODOP
%left OROP
%left ANDOP
%left XOROP
%nonassoc SHLOP SHROP ROTLOP ROTROP
    
%type<Syntax.exp> exp exp_nullary
%start<Syntax.prog> prog

%%

(* Helpers *)

option(X) :
  | (* empty *) { None @@ at($symbolstartpos,$endpos) }
  | x=X { Some x @@ at($symbolstartpos,$endpos) } 


list(X) :
  | (* empty *) { [] @@ at($symbolstartpos,$endpos) }
  | x=X xs=list(X) { (x::xs.it) @@ at($symbolstartpos,$endpos) }

seplist(X, SEP) :
  | (* empty *) { [] @@ at($symbolstartpos,$endpos) }
  | x=X SEP xs=seplist(X, SEP) { (x::xs.it) @@ at($symbolstartpos,$endpos) } 
  | x=X { [x] @@ at($symbolstartpos,$endpos) }


(* Basics *)

%inline id :
  | id=ID { id @@ at($symbolstartpos,$endpos)}

%inline var_ref :
  | id=ID { id @! at($symbolstartpos,$endpos) }

%inline var :
  | VAR { Type.VarMut @@ at($symbolstartpos,$endpos) }

%inline var_opt :
  | (* empty *) { Type.ConstMut @@ at($symbolstartpos,$endpos) }
  | VAR { Type.VarMut @@ at($symbolstartpos,$endpos) }

%inline actor_opt :
  | (* empty *) { Type.Object @@ at($symbolstartpos,$endpos) }
  | ACTOR { Type.Actor @@ at($symbolstartpos,$endpos) }


(* Types *)

typ_nullary :
  | p=PRIM
    { PrimT(p) @@ at($symbolstartpos,$endpos) }
(*
  | x=id 
    { VarT(x, []) @@ at($symbolstartpos,$endpos) }  
  | x=id LT ts=seplist(typ, COMMA) GT
    { VarT(x, ts.it) @@ at($symbolstartpos,$endpos) }
*)
  | LPAR ts=seplist(typ_item, COMMA) RPAR
    { match ts.it with [t] -> t | ts -> TupT(ts) @@ at($symbolstartpos,$endpos) }
  | x=id tso=typ_args?
    {	VarT(x, Lib.Option.get tso.it []) @@ at($symbolstartpos,$endpos) }
  | a=actor_opt LCURLY tfs=seplist(typ_field, SEMICOLON) RCURLY
    { ObjT(a, tfs.it) @@ at($symbolstartpos,$endpos) }

typ_post :
  | t=typ_nullary
    { t }
  | t=typ_post LBRACKET RBRACKET
    { ArrayT(Type.ConstMut @@ no_region, t) @@ at($symbolstartpos,$endpos) }
  | t=typ_post QUEST
    { OptT(t) @@ at($symbolstartpos,$endpos) }

typ_pre :
  | t=typ_post
    { t }
  | ASYNC t=typ
    { AsyncT(t) @@ at($symbolstartpos, $endpos) }
  | LIKE t=typ
    { LikeT(t) @@ at($symbolstartpos, $endpos) }
  | mut=var t=typ_nullary LBRACKET RBRACKET
    { ArrayT(mut, t) @@ at($symbolstartpos,$endpos) }

typ :
  | t=typ_pre
    { t }
  | tps=typ_params_opt t1=typ_pre ARROW t2=typ 
    { FuncT(tps, t1, t2) @@ at($symbolstartpos,$endpos) }

typ_item :
  | id COLON t=typ { t }
  | t=typ { t }

typ_args :
  | LT ts=seplist(typ, COMMA) GT { ts.it }

%inline typ_params_opt :
  | (* empty *) { [] }
  | LT ts=seplist(typ_bind, COMMA) GT { ts.it }

typ_field :
  | mut=var_opt x=id COLON t=typ
    { {var = x; typ = t; mut} @@ at($symbolstartpos,$endpos) }
  | x=id tps=typ_params_opt t1=typ t2=return_typ 
    { let t = FuncT(tps, t1, t2) @@ span x.at t2.at in
      {var = x; typ = t; mut = Type.ConstMut @@ no_region} @@ at($symbolstartpos,$endpos) }

typ_bind :
  | x=id SUB t=typ
    { {var = x; bound = t} @@ at($symbolstartpos,$endpos) }
  | x=id
    { {var = x; bound = AnyT @@ at($symbolstartpos,$endpos)} @@ at($symbolstartpos,$endpos) }



(* Expressions *)

lit :
  | NULL { NullLit }
  | s=NAT { PreLit s }
  | s=INT { PreLit s }
  | b=BOOL { BoolLit b }
  | f=FLOAT { FloatLit (Value.Float.of_float f)}
  | c=CHAR { CharLit c }
  | t=TEXT { TextLit t }

%inline unop :
  | ADDOP { PosOp }
  | SUBOP { NegOp }
  | XOROP { NotOp }

%inline binop :
  | ADDOP { AddOp }
  | SUBOP { SubOp }
  | MULOP { MulOp }
  | DIVOP { DivOp }
  | MODOP { ModOp }
  | ANDOP { AndOp }
  | OROP  { OrOp }
  | XOROP { XorOp }
  | SHLOP { ShiftLOp }
  | SHROP { ShiftROp }
  | ROTLOP { RotLOp }
  | ROTROP { RotROp }
  | CATOP { CatOp }

%inline relop :
  | EQOP  { EqOp }
  | NEQOP { NeqOp }
  | LTOP  { LtOp }
  | LEOP  { LeOp }
  | GTOP  { GtOp }
  | GEOP  { GeOp }

%inline unassign :
  | PLUSASSIGN { PosOp }
  | MINUSASSIGN { NegOp }
  | XORASSIGN { NotOp }

%inline binassign :
  | PLUSASSIGN { AddOp }
  | MINUSASSIGN { SubOp }
  | MULASSIGN { MulOp }
  | DIVASSIGN { DivOp }
  | MODASSIGN { ModOp }
  | ANDASSIGN { AndOp }
  | ORASSIGN { OrOp }
  | XORASSIGN { XorOp }
  | SHLASSIGN { ShiftLOp }
  | SHRASSIGN { ShiftROp }
  | ROTLASSIGN { RotLOp }
  | ROTRASSIGN { RotROp }
  | CATASSIGN { CatOp }


exp_nullary :
  | x=var_ref
    { VarE(x) @? at($symbolstartpos,$endpos) }
  | l=lit
    { LitE(ref l) @? at($symbolstartpos,$endpos) }
  | LPAR es = seplist(exp, COMMA) RPAR
    { match es.it with [e] -> e | es -> TupE(es) @? at($symbolstartpos,$endpos) }
  | LCURLY es=seplist(exp, SEMICOLON) RCURLY
    { BlockE(es.it) @? at($symbolstartpos,$endpos) }
  | a=actor_opt xo=id? LCURLY es=seplist(exp_field, SEMICOLON) RCURLY
    { ObjE(a, xo.it, es.it) @? at($symbolstartpos,$endpos) }

exp_post :
  | e=exp_nullary
    { e }
  | LBRACKET mut=var_opt es=seplist(exp, COMMA) RBRACKET
    { ArrayE(mut, es.it) @? at($symbolstartpos,$endpos) }
  | e1=exp_post LBRACKET e2=exp RBRACKET
    { IdxE(e1, e2) @? at($symbolstartpos,$endpos) }
  | e=exp_post DOT s=NAT
    { ProjE (e, Value.Nat.of_string s) @? at($symbolstartpos,$endpos) }
  | e=exp_post DOT x=var_ref
    { DotE(e, x) @? at($symbolstartpos,$endpos) }
  | e1=exp_post tso=typ_args? e2=exp_nullary
    { CallE(e1, Lib.Option.get tso.it [], e2) @? at($symbolstartpos,$endpos) }

exp_pre :
  | e=exp_post
    { e } 
  | op=unop e=exp_pre
    { UnE(op ,e) @? at($symbolstartpos,$endpos) }
  | op=unassign e=exp_pre
    (* TODO: this is incorrect, since it duplicates e *)
    { AssignE(e, UnE(op, e) @? at($symbolstartpos,$endpos)) @? at($symbolstartpos,$endpos) }
  | NOT e=exp_pre
    { NotE e @? at($symbolstartpos,$endpos) }

exp_infix :
  | e=exp_pre
    { e } 
  | e1=exp_infix op=binop e2=exp_infix
    { BinE(e1, op, e2) @? at($symbolstartpos,$endpos) }
  | e1=exp_infix op=relop e2=exp_infix
    { RelE(e1, op, e2) @? at($symbolstartpos,$endpos) }
  | e1=exp_infix ASSIGN e2=exp_infix
    { AssignE(e1, e2) @? at($symbolstartpos,$endpos)}
  | e1=exp_infix op=binassign e2=exp_infix
    (* TODO: this is incorrect, since it duplicates e1 *)
    { AssignE(e1, BinE(e1, op, e2) @? at($symbolstartpos,$endpos)) @? at($symbolstartpos,$endpos) }
  | e1=exp_infix AND e2=exp_infix
    { AndE(e1, e2) @? at($symbolstartpos,$endpos) }
  | e1=exp_infix OR e2=exp_infix
    { OrE(e1, e2) @? at($symbolstartpos,$endpos) }
  | e=exp_infix IS t=typ
    { IsE(e, t) @? at($symbolstartpos,$endpos) }
  | e=exp_infix COLON t=typ
    { AnnotE(e, t) @? at($symbolstartpos,$endpos) }

exp :
  | e=exp_infix
    { e } 
  | LABEL x=id e=exp
    { let x' = ("continue " ^ x.it) @@ x.at in
      let e' =
        match e.it with
        | WhileE (e1, e2) -> WhileE (e1, LabelE (x', e2) @? e2.at) @? e.at
        | LoopE (e1, eo) -> LoopE (LabelE (x', e1) @? e1.at, eo) @? e.at
        | ForE (p, e1, e2) -> ForE (p, e1, LabelE (x', e2) @? e2.at) @? e.at
        | _ -> e
      in LabelE(x, e') @? at($symbolstartpos,$endpos) }
  | BREAK x=id eo=exp_nullary?
    { let e = Lib.Option.get eo.it (TupE([]) @? no_region) in
      BreakE(x, e) @? at($symbolstartpos,$endpos) }
  | CONTINUE x=id
    { let x' = ("continue " ^ x.it) @@ x.at in
      BreakE(x', TupE([]) @? no_region) @? at($symbolstartpos,$endpos) }
  | IF b=exp_nullary e1=exp %prec IFX
    { IfE(b, e1, TupE([]) @? no_region) @? at($symbolstartpos,$endpos) }
  | IF b=exp_nullary e1=exp ELSE e2=exp
    { IfE(b, e1, e2) @? at($symbolstartpos,$endpos) }
  | SWITCH e=exp_nullary cs=case+
    { SwitchE(e, cs) @? at($symbolstartpos,$endpos) }
  | WHILE e1=exp_nullary e2=exp
    { WhileE(e1, e2) @? at($symbolstartpos,$endpos) }
  | LOOP e=exp
    { LoopE(e, None) @? at($symbolstartpos,$endpos) }
  | LOOP e1=exp WHILE e2=exp
    { LoopE(e1, Some e2) @? at($symbolstartpos,$endpos) }
  | FOR p=pat IN e1=exp_nullary e2=exp
    { ForE(p, e1, e2) @? at($symbolstartpos,$endpos) }
  | RETURN eo=exp?
    { let e = Lib.Option.get eo.it (TupE([]) @? eo.at) in
    	RetE(e) @? at($symbolstartpos,$endpos) }
  | ASYNC e=exp 
    { AsyncE(e) @? at($symbolstartpos,$endpos) }
  | AWAIT e=exp
    { AwaitE(e) @? at($symbolstartpos,$endpos) }
  | ASSERT e=exp
    { AssertE(e) @? at($symbolstartpos,$endpos) }
  | d=dec
    { DecE(d) @? at($symbolstartpos,$endpos) }
      
    
case : 
  | CASE p=pat e=exp
    { {pat = p; exp = e} @@ at($symbolstartpos,$endpos) }

%inline private_opt :
  | (* empty *) { Public @@ at($symbolstartpos,$endpos) }
  | PRIVATE { Private @@ at($symbolstartpos,$endpos) }

exp_field :
  | p=private_opt m=var_opt x=id EQ e=exp
    { {var = x; mut = m; priv = p; exp = e} @@ at($symbolstartpos,$endpos) }
  | p=private_opt m=var_opt x=id COLON t=typ EQ e=exp
    { {var = x; mut = m; priv = p; exp = AnnotE(e, t) @? span t.at e.at}
	    @@ at($symbolstartpos,$endpos) }
  // TBR: should a func_def abbreviate a dec or block {dec;id}? *)
  | priv=private_opt fd=func_def
    { let (x, tps, p, t, e) = fd.it in
      let d = FuncD(x, tps, p, t, e) @@ fd.at in
      let e' = DecE(d) @? fd.at in  
        (* let e' = BlockE([DecE(d)@? fd.at;(VarE (x.it @! fd.at)) @? fd.at]) @? fd.at in  *)
      {var = x; mut = Type.ConstMut @@ no_region; priv; exp = e'}
      @@ at($symbolstartpos,$endpos) }

// TBR
param :
  | x=id COLON t=typ
    { AnnotP(VarP(x) @@ x.at, t) @@ at($symbolstartpos,$endpos) }

params :
  | LPAR ps=seplist(param, COMMA) RPAR
    { match ps.it with [p] -> p | ps -> TupP(ps) @@ at($symbolstartpos,$endpos) }


(* Patterns *)

pat :
  | p=pat COLON t=typ
    { AnnotP(p, t) @@ at($symbolstartpos,$endpos) }
  | l=lit
    { LitP(ref l) @@ at($symbolstartpos,$endpos) }
  | UNDERSCORE
    { WildP @@ at($symbolstartpos,$endpos) }
  | x=id
    { VarP(x) @@ at($symbolstartpos,$endpos) }
  | LPAR ps=seplist(pat, COMMA) RPAR
    { match ps.it with [p] -> p | ps -> TupP(ps) @@ at($symbolstartpos,$endpos) }

init :  
  | EQ e=exp { e }

return_typ :
  | COLON t=typ { t }

//TBR: do we want id _ ... d x ... or id (x,...).
// if t is NONE, should it default to unit or is it inferred from exp?
func_def :
  | x=id tps=typ_params_opt ps=params rt=return_typ? fb=func_body
    {	let t = Lib.Option.get rt.it (TupT([]) @@ rt.at) in
      (* This is a hack to support async method declarations. *)
	    let e = match fb with
	      | (false, e) -> e (* body declared as EQ e *)
	      | (true, e) -> (* body declared as immediate block *)
		      match t.it with
		      | AsyncT _ -> AsyncE(e) @? e.at
		      | _ -> e
	    in (x, tps, ps, t, e) @@ at($symbolstartpos,$endpos) }

func_body :
   | EQ e=exp { (false, e) }	  // acc. to grammar
   | e=exp { (true, e) } // acc. to example bank.as 


(* Declarations *)

dec :
  | LET p=pat EQ e=exp
    { LetD (p,e) @@ at($symbolstartpos,$endpos) }
  | VAR x=id COLON t=typ eo=init?
    { VarD(x, t, eo.it) @@ at($symbolstartpos,$endpos) } 
  | FUNC fd=func_def
    { let (id, tps, p, t, e) = fd.it in
      FuncD(id,tps,p,t,e) @@ at($symbolstartpos,$endpos) }
  | TYPE x=id tps=typ_params_opt EQ t=typ
    { TypD(x, tps, t) @@ at($symbolstartpos,$endpos) }
(* TBR: Syntax.md specifies EQ exp but the examples allow a exp_field* (sans EQ), shall we allow both?
  | a=actor_opt CLASS x=id tps=typ_params_opt p=pat EQ e=exp
    { ClassD(a, x, tps, p, e) @@ at($symbolstartpos,$endpos) }
*)
  | a=actor_opt CLASS x=id tps=typ_params_opt p=params
      LCURLY efs=seplist(exp_field, SEMICOLON) RCURLY
    { ClassD(a, x, tps, p, efs.it) @@ at($symbolstartpos,$endpos) }


(* Programs *)

prog :
  | es=seplist(exp, SEMICOLON) EOF
    { List.map (fun e ->
        match e.it with
        | DecE d -> d
        | _ -> LetD(WildP @@ e.at, e) @@ e.at
      ) es.it @@ es.at }

%%
