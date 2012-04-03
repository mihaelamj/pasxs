(*
   Crossroads I/O 1.0.1 example program - Basic Server 3
   Using Request-reply pattern

   Server is using XS_REP to receive requests from and send replies to a client.
   Allows alternating sequence of receiving and  sending messages.
   Each request received is fair-queued from among all clients,
   and each reply sent is routed to the client that issued the last request.
   If the original requester doesn't exist any more the reply is silently discarded.

   It's using TXS_Context and TXS_Socket objects from
   libxs_pas_obj.pas

   Server will run until it receives "squit" string from
   one of it's client.
   It will then close that client.

   It will echo what was sent to it on the console

   libxs.dll must be placed in the same directory with the exe

   Mihaela Mihaljevic Jakic (mihaela@token.hr)
*)

program server_3;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  uUtil_3 in 'uUtil_3.pas',
  libxs_consts in '..\..\src\libxs_consts.pas',
  libxs_lib in '..\..\src\libxs_lib.pas',
  libxs_pas in '..\..\src\libxs_pas.pas',
  libxs_pas_obj in '..\..\src\libxs_pas_obj.pas',
  libxs_pas_obj_consts in '..\..\src\libxs_pas_obj_consts.pas';

var
  aContext       : TXS_Context;
  aServerSocket  : TXS_Socket;
  recBytes,
  sndBytes        : integer;
  recMsg,
  sndMsg          : AnsiString;
  DoRun           : boolean;
begin
   aContext       := nil;
   aServerSocket  := nil;
   Writeln('Starting Crossroads I/O server!');
   try
      aContext := TXS_Context.Create;
   except
      on E : Exception do begin
         WriteLn(Format('Error creating context : %s', [E.Message]));
         Finish(aContext, aServerSocket);
      end;
   end;
   WriteLn('Created context');

   try
      aServerSocket := TXS_Socket.Create(aContext, xstREP);
   except
      on E : Exception do begin
         WriteLn(Format('Error creating socket : %s', [E.Message]));
         Finish(aContext, aServerSocket);
      end;
   end;
   WriteLn(Format('Created socket: %s', [aServerSocket.SocketTypeName]));

   try
      DoRun := aServerSocket.Bind(xttTCP, '*', 5555) ;
   except
      on E : Exception do begin
         WriteLn(Format('Error binding socket: %s', [E.Message]));
         Finish(aContext, aServerSocket);
      end;
   end;

   if DoRun then
      WriteLn(aServerSocket.Connections[0].Description)
   else
      WriteLn('Connection Failed!');
   WriteLn('');
   while DoRun do begin
      recBytes := aServerSocket.ReceiveString(recMsg);
      if recBytes > 0 then begin
         Writeln(Format('Recv : %s (%d bytes)', [recMsg, recBytes]));
         sndMsg   := recMsg;
         sndBytes := aServerSocket.SendString(sndMsg);
         Writeln(Format('Sent : %s (%d bytes)', [sndMsg, sndBytes]));
         WriteLn('');
         DoRun    := recMsg <> cQuitServer;
      end;
   end;
   WriteLn('Server terminating!');
   Finish(aContext, aServerSocket);
end.

