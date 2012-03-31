(*
   Crossroads I/O 1.0.1 example program - Basic Client 1

   Client will connect to the server running tcp on the port 5555

   It will loop reading the input from the console until it receives the quit command

   It will prompt the user to enter the string, and recive the  message from
   the server and echo it.

   libxs.dll must be placed in the same directory with the exe
*)

program client_1;

{$APPTYPE CONSOLE}
uses
  SysUtils,
  libxs_consts in '..\..\src\libxs_consts.pas',
  libxs_lib in '..\..\src\libxs_lib.pas',
  libxs_pas in '..\..\src\libxs_pas.pas';

const
   cTerm = 'quit';

var
  pxsContext      : Pointer;
  pxsClientSocket : Pointer;

  recBytes,
  sndBytes        : integer;

  readStr         : AnsiString;
  recMsg          : AnsiString;
begin

   Writeln('Connecting to Crossroads I/O server');
   (*Initialise Crossroads context *)
   pxsContext        := xs_init();
   (*create a Crossroads socket within the specified context and
   return an opaque handle to the newly created socket
   XS_SOCK_TYPE_REQ -> used by a client to send requests to and
   receive replies from a service*)
   pxsClientSocket   := xs_socket(pxsContext, XS_SOCK_TYPE_REQ);
   (*connect the pxsClientSocket  to the endpoint (transport ://address) *)
   xs_connect(pxsClientSocket, 'tcp://localhost:5555');
   readStr := '';
   repeat
      WriteLn('Enter message to send to the server');
      Readln(readStr);
      Writeln(Format('Sending %s ', [readStr]));
      (*Send the client message on the client socket, to the server, 0 -> no flags*)
      sndBytes := pas_xs_send(pxsClientSocket, readStr, 0);
      Writeln(Format('Sent %d bytes, waiting reply..', [sndBytes]));
      recMsg   := '';
      (*Receive a xsServerMessage from our socket connected to the server, 0 -> no flags*)
      recBytes := pas_xs_recv(pxsClientSocket, recMsg, 256, 0);
      Writeln(Format('Received : %s (%d bytes)', [recMsg, recBytes]));
   until readStr = cTerm ;
   WriteLn('Client terminated');
   (* CLose the client socket and terminate the context *)
   xs_close(pxsClientSocket);
   xs_term(pxsContext);
end.

