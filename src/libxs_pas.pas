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

(* Sends an AnsiString message on the existing socket, with optional flags,
   returns the number of sent bytes *)
function pas_xs_send(pSocket: Pointer; MessageStr : AnsiString; MessageFlags: Integer = 0): Integer;
(* Receives an AnsiString message on the existing socket, with optional flags,
   returns the message in MessageStr parameter, and the number of received bytes *)
function pas_xs_recv(pSocket: Pointer; var MessageStr : AnsiString; MessageLen: size_t; MessageFlags: Integer = 0): Integer;

//function xs_sendmsg(s: Pointer; var msg: TXS_Msg; flags: Integer): Integer; cdecl; external libxs_name;
function pas_xs_sendmsg(pSocket: Pointer; var xsMessage: TXS_Msg; MessageFlags: Integer = 0): Integer;

//function xs_recvmsg(s: Pointer; var msg: TXS_Msg; flags: Integer): Integer; cdecl; external libxs_name;
function pas_xs_recvmsg(pSocket: Pointer; var xsMessage: TXS_Msg; MessageFlags: Integer = 0): Integer;

function GetMessageData(var xsMessage: TXS_Msg; MessageLen : integer):AnsiString;
function SetMessageData(var xsMessage: TXS_Msg; MessageStr  : AnsiString): boolean;
function NewMessageStr(MessageStr  : AnsiString): TXS_Msg;


implementation

//Socket.SendStr(MessageStr : AnsiString; MessageFlags: Integer)
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

////int xs_recv (  void *socket, void *buf,        size_t len,  int flags);
//function xs_recv(s: Pointer;   buf : AnsiString; len: size_t; flags: Integer)

//Socket.ReceiveStr(var MessageStr : AnsiString; MessageFlags: Integer)
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

function pas_xs_sendmsg(pSocket: Pointer; var xsMessage: TXS_Msg; MessageFlags: Integer = 0): Integer;
begin
   result := xs_sendmsg(pSocket, xsMessage, MessageFlags);
end;

function pas_xs_recvmsg(pSocket: Pointer; var xsMessage: TXS_Msg; MessageFlags: Integer = 0): Integer;
begin
   result := xs_recvmsg(pSocket, xsMessage, MessageFlags);
end;


function GetMessageData(var xsMessage: TXS_Msg; MessageLen : integer):AnsiString;
var
  pMsgData        : Pointer;
  tmp             : AnsiString;
begin
   result   := '';
   tmp      := '';
   if MessageLen < 1 then Exit;
   pMsgData := xs_msg_data(xsMessage);
   SetLength(tmp, MessageLen);
   StrLCopy(PAnsiChar(tmp), pMsgData, MessageLen);
   result := Copy(tmp, 1, MessageLen - SizeOf(AnsiChar));
end;

function SetMessageData(var xsMessage: TXS_Msg; MessageStr  : AnsiString): boolean;
var
  pMsgData        : Pointer;
  aLen            : size_t;
  tmp             : PAnsiChar;
begin
   result := False;
   if Length(MessageStr) = 0 then Exit;
   tmp      := '';
   aLen     := Length(MessageStr) + SizeOf(AnsiChar);
   (*Init xsMessage, with the message size*)
   xs_msg_init_size(xsMessage, aLen);
   //sending C strings
   tmp      := PAnsiChar(MessageStr + #0);
   pMsgData := xs_msg_data(xsMessage);
   StrLCopy(pMsgData, tmp, aLen);
   result := True;
end;

function NewMessageStr(MessageStr : AnsiString): TXS_Msg;
begin
   SetMessageData(result, MessageStr);
end;

end.

