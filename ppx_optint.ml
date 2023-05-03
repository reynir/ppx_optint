open Ppxlib
open Ast_helper

let mklid m lid =
  Exp.ident { Location.loc = !default_loc ;
              txt = Longident.Ldot (m, lid) }

let apply m f xs =
  Exp.(apply (mklid m f)
         (List.map (fun e -> Asttypes.Nolabel, e) xs))

let optint = Longident.Lident "Optint"

let optint s =
  let x = Optint.of_string s in
  if Optint.equal x Optint.zero then
    mklid optint "zero"
  else if Optint.equal x Optint.one then
    mklid optint "one"
  else if Optint.equal x Optint.minus_one then
    mklid optint "minus_one"
  else match Int32.of_string_opt s with
    | Some n ->
      (* XXX: We assume what works in the ppx will work in the resulting binary *)
      apply optint "of_unsigned_int32" [Exp.constant (Const.int32 n)]
    | None ->
      apply optint "of_string" [Exp.constant (Const.string s)]

let int63 = Longident.Ldot (Longident.Lident "Optint", "Int63")

let int63 s =
  let module Int63 = Optint.Int63 in
  let x = Int63.of_string s in
  if Int63.equal x Int63.zero then
    mklid int63 "zero"
  else if Int63.equal x Int63.one then
    mklid int63 "one"
  else if Int63.equal x Int63.minus_one then
    mklid int63 "minus_one"
  else match int_of_string_opt s with
    | Some n ->
      apply int63 "of_unsigned_int" [Exp.constant (Const.int n)]
    | None ->
      apply int63 "of_string" [Exp.constant (Const.string s)]

let expander m f loc s =
  with_default_loc loc @@ fun () ->
  try f s
  with Failure msg ->
    (* XXX: [msg] is often not very helpful *)
    let error s =
      Exp.extension ~loc
        (Location.Error.to_extension (Location.Error.make ~loc ~sub:[] s))
    in
    Format.kasprintf error "Bad %s integer literal. %s." m msg

let () =
  Driver.register_transformation
    "ppx_optint"
    ~rules:[
      Context_free.Rule.constant Integer 'i' (expander "Optint.t" optint);
      Context_free.Rule.constant Integer 'I' (expander "Optint.Int63.t" int63);
    ]
