(*
   Crossroads I/O bindings for Delphi Pascal
   Version 1.0.1

   Mihaela Mihaljevic Jakic
   mihaela@token.hr
   http://mihaelamj.com

   GitHub repo:
   https://github.com/mihaelamj/pasxs

   Fork of the ZeroMQ Pascal bindings (https://github.com/colinj/paszmq)
*)

(* Wrappers around C functions in libxs_lib *)

unit libxs_pas;

interface

uses
   SysUtils,
   Classes,
   libxs_consts,
   libxs_lib;

function pas_xs_send(pSocket: Pointer; MessageStr : AnsiString; MessageFlags: Integer): Integer;
function pas_xs_recv(pSocket: Pointer; var MessageStr : AnsiString; MessageLen: size_t; MessageFlags: Integer): Integer;

implementation

function pas_xs_send(pSocket: Pointer; MessageStr : AnsiString; MessageFlags: Integer): Integer;
var
   tmp   : PAnsiChar;
   aLen  : size_t;
begin
   aLen     := Length(MessageStr) + SizeOf(AnsiChar);
   tmp      := PAnsiChar(MessageStr + #0);
   result   := -1;
   result   := xs_send(pSocket, tmp, aLen, MessageFlags);
end;

function pas_xs_recv(pSocket: Pointer; var MessageStr : AnsiString; MessageLen: size_t; MessageFlags: Integer): Integer;
var
   tmp   : AnsiString;
   aLen  : size_t;
begin
   MessageStr  := '';
   SetLength(tmp, MessageLen);
   aLen        := MessageLen;
   result      := -1;
   result      := xs_recv(pSocket, tmp, aLen, MessageFlags);
   if (result > 0)  then
      MessageStr:= Copy(tmp, 1, result)
end;

end.

