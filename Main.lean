import Mjrty
import Cli

open Cli

def runMjrtyCmd (p : Parsed) : IO UInt32 := do
  let stream ←
    match p.positionalArg? "FILE" |>.map (·.as! String) with
    | none | some "-" => IO.getStdin
    | some file =>
      let f ← IO.FS.Handle.mk ⟨file⟩ IO.FS.Mode.read
      pure (IO.FS.Stream.ofHandle f)

  let sep := p.flag? "separator" |>.map (·.as! String) |>.getD ","

  let s ← stream.readToEnd
  let majority := s.split sep |>.map toString |>.mjrty
  let stdout ← IO.getStdout
  stdout.putStr majority
  return 0

def mjrtyCmd : Cmd := `[Cli|
  mjrty VIA runMjrtyCmd; ["0.1.0"]
  "Identify the strict majority element from a list, if one exists."

  FLAGS:
    s, separator : String;   "Separator to use when splitting the input. ',' by default."

  ARGS:
    FILE : String;           "File to read from. When FILE is -, read standard input"
]

def main : List String → IO UInt32 :=
  mjrtyCmd.validate
