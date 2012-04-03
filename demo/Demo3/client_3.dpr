(*
   Crossroads I/O 1.0.1 example program - Basic Client 3
   Using Request-reply pattern

   Client is using XS_REQ to send requests to and receive replies from a service.
   Allows only an alternating sequence of sending and receiving messages.
   Each request sent is load-balanced among all services,
   and each reply received is matched with the last issued request.

   It's using TXS_Context and TXS_Socket objects from
   libxs_pas_obj.pas

   Client will connect to the server running tcp on the port 5555

   It will loop reading the input from the console until it receives the
   cquit command, or squit command from the server

   It will prompt the user to enter the string, and recive the  message from
   the server and echo it.

   libxs.dll must be placed in the same directory with the exe

   Mihaela Mihaljevic Jakic (mihaela@token.hr)
*)

program client_3;

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
  aClientSocket  : TXS_Socket;
  recBytes,
  sndBytes        : integer;
  readStr         : AnsiString;
  recMsg          : AnsiString;
  DoRun           : boolean;
begin
   aContext       := nil;
   aClientSocket  := nil;
   Writeln('Starting Crossroads I/O client!');
   try
      aContext      := TXS_Context.Create;
   except
      on E : Exception do begin
         WriteLn(Format('Error creating context : %s', [E.Message]));
         Finish(aContext, aClientSocket);
      end;
   end;
   WriteLn('Created context');

   try
      aClientSocket := TXS_Socket.Create(aContext, xstREQ);
   except
      on E : Exception do begin
         WriteLn(Format('Error creating socket : %s', [E.Message]));
         Finish(aContext, aClientSocket);
      end;
   end;
   WriteLn(Format('Created socket: %s', [aClientSocket.SocketTypeName]));

   try
      DoRun := aClientSocket.Connect(xttTCP, 'localhost', 5555) ;
   except
      on E : Exception do begin
         WriteLn(Format('Error connecting socket: %s', [E.Message]));
         Finish(aContext, aClientSocket);
      end;
   end;

   if DoRun then
      WriteLn(aClientSocket.Connections[0].Description)
   else
      WriteLn('Connecting Socket Failed!');
   WriteLn('');
   while DoRun do begin
      WriteLn('Enter message to send to the server');
      Readln(readStr);
      sndBytes := aClientSocket.SendString(readStr);
      Writeln(Format('Sent : %s (%d bytes)', [readStr, sndBytes]));
      recBytes := aClientSocket.ReceiveString(recMsg);
      Writeln(Format('Recv : %s (%d bytes)', [recMsg, recBytes]));
      WriteLn('');
      DoRun  := (readStr <> cQuitClient) and
                (recMsg <> cQuitServer);
   end;

   WriteLn('Client terminated');
   Finish(aContext, aClientSocket);
end.

