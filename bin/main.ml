(***************************************************************************)
(*  Copyright (c) 2022 Dhruv Makwana                                       *)
(*  All rights reserved.                                                   *)
(*                                                                         *)
(*  This software was developed by the University of Cambridge Computer    *)
(*  Laboratory as part of the Rigorous Engineering of Mainstream Systems   *)
(*  (REMS) project. This project has been partly funded by an EPSRC        *)
(*  Doctoral Training studentship. This project has been partly funded by  *)
(*  Google. This project has received funding from the European Research   *)
(*  Council (ERC) under the European Union's Horizon 2020 research and     *)
(*  innovation programme (grant agreement No 789108, Advanced Grant        *)
(*  ELVER).                                                                *)
(*                                                                         *)
(*  BSD 2-Clause License                                                   *)
(*                                                                         *)
(*  Redistribution and use in source and binary forms, with or without     *)
(*  modification, are permitted provided that the following conditions     *)
(*  are met:                                                               *)
(*  1. Redistributions of source code must retain the above copyright      *)
(*     notice, this list of conditions and the following disclaimer.       *)
(*  2. Redistributions in binary form must reproduce the above copyright   *)
(*     notice, this list of conditions and the following disclaimer in     *)
(*     the documentation and/or other materials provided with the          *)
(*     distribution.                                                       *)
(*                                                                         *)
(*  THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS''     *)
(*  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED      *)
(*  TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A        *)
(*  PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR    *)
(*  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,           *)
(*  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT       *)
(*  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF       *)
(*  USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND    *)
(*  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,     *)
(*  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT     *)
(*  OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF     *)
(*  SUCH DAMAGE.                                                           *)
(***************************************************************************)

open Shexp_process
module List = Stdlib.List

let ( let* ) x f = bind ~f x
let list_files dir = FileUtil.find Is_file dir (Fun.flip Stdlib.List.cons) []

let format_reason reason =
  Str.(reason
    |> Comment_simplifier.Lexer.show_err
    |> global_replace (regexp "Lexer\\.") ""
    |> global_replace (regexp "_") "")

let format_err reason (pos : Lexing.position) =
  Format.sprintf "error: %s in %s:%d:%d"
    (format_reason reason)
    pos.pos_fname
    pos.pos_lnum
    pos.pos_cnum

let comment_simplify file =
  with_temp_file ~prefix:"c-tree-carve-" ~suffix:".txt" (fun tmp_file ->
      match Comment_simplifier.from_file ~tmp_file file with
      | Result.Ok () ->  FileUtil.cp [ tmp_file ] file; return None
      | Result.Error (reason, pos) -> return (Some (format_err reason pos)))

let rec filter_map f = function
  | [] -> return []
  | x :: xs ->
    let* result = f x in
    match result with
    | None -> filter_map f xs
    | Some x ->
      let* xs = filter_map f xs in
      return (x :: xs)

let fixup output =
  Str.(
    global_replace
      (regexp "clang-tree-carve\\(\\.exe\\)?")
      "c-tree-carve" output)

let dir_exists dir =
  try FileUtil.test Is_dir dir with _ -> false

let prog =
  let args = Array.to_list Sys.argv in
  let* exit_code, output =
    run_exit_code "clang-tree-carve.exe" (Stdlib.List.tl args)
    |> capture [ Std_io.Stdout; Std_io.Stderr ]
  in
  if exit_code <> 0 then
    let* () = eprint @@ fixup output in
    return exit_code
  else if not @@ dir_exists output then
    let* () = echo ~n:() (fixup output) in
    return 0
  else
    let* errs = filter_map comment_simplify @@ list_files output in
    match errs with
    | [] ->
      let* () = echo ~n:() output in
      return 0
    | _ :: _ ->
      let* () = Shexp_process.List.iter ~f:echo errs in
      return 1

let () = exit @@ eval ~context:(Context.create ()) prog
