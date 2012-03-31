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

(* Sends an AnsiString message on the existing socket, with optional flags
   returns the number of sent bytes *)
function pas_xs_send(pSocket: Pointer; MessageStr : AnsiString; MessageFlags: Integer = 0): Integer;

(* Receives an AnsiString message on the existing socket, with optional flags,
   returns the message in MessageStr parameter, and the number of received bytes*)
function pas_xs_recv(pSocket: Pointer; var MessageStr : AnsiString; MessageLen: size_t; MessageFlags: Integer = 0): Integer;

implementation

function pas_xs_send(pSocket: Pointer; MessageStr : AnsiString; MessageFlags: Integer): Integer;
var
   tmp   : PAnsiChar;
   aLen  : size_t;
begin
   aLen     := Length(MessageStr) + SizeOf(AnsiChar);
   //sending C strings
   tmp      := PAnsiChar(MessageStr + #0);
   result   := -1;
   result   := xs_send(pSocket, tmp, aLen, MessageFlags);
end;

function pas_xs_recv(pSocket: Pointer; var MessageStr : AnsiString; MessageLen: size_t; MessageFlags: Integer = 0): Integer;
var
   tmp   : AnsiString;
   aLen  : size_t;
begin
   MessageStr  := '';
   SetLength(tmp, MessageLen);
   aLen        := MessageLen;
   result      := -1;
   result      := xs_recv(pSocket, tmp, aLen, MessageFlags);

   if (result > 0)  then  begin
      //strip the #0 from the received string
      Dec(result);
      MessageStr:= Copy(tmp, 1, result);
   end;
end;

end.

