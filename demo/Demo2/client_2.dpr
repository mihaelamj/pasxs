(*
   Crossroads I/O 1.0.1 example program - Basic Client 2

   It's using TXS_Msg record to send/receive messages (pas_xs_sendmsg and pas_xs_send)
   instead of plain AnsiStrings (pas_xs_send and pas_xs_recv)

   Client will connect to the server running tcp on the port 5555

   It will loop reading the input from the console until it receives the quit command

   It will prompt the user to enter the string, and recive the  message from
   the server and echo it.

   libxs.dll must be placed in the same directory with the exe
*)

program client_2;

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

  xsServerMessage : TXS_MsgRec;
  xsClientMessage : TXS_MsgRec;

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
      (*Init the new message to send to the server, with the message size, since we know it*)
      //xs_msg_init_size(xsClientMessage, Length(readStr));
      Writeln(Format('Sending %s ', [readStr]));
      (*Send the client message on the client socket, to the server, 0 -> no flags*)
      SetMessageData(xsClientMessage, readStr);
      sndBytes := pas_xs_sendmsg(pxsClientSocket, xsClientMessage);
      Writeln(Format('Sent %d bytes, waiting reply..', [sndBytes]));
      (*Close the sent client message*)
      xs_msg_close(xsClientMessage);


      (*Initialise an empty message to be received from the server*)
      xs_msg_init(xsServerMessage);
      (*Receive a xsServerMessage from our socket connected to the server, 0 -> no flags*)
      recBytes := pas_xs_recvmsg(pxsClientSocket, xsServerMessage);
      recMsg   := GetMessageData(xsServerMessage, recBytes);
      Writeln(Format('Received : %s (%d bytes)', [recMsg, recBytes]));
      (*Close the received message*)
      xs_msg_close(xsServerMessage);
   until readStr = cTerm ;
   WriteLn('Client terminated');
   (* CLose the client socket and terminate the context *)
   xs_close(pxsClientSocket);
   xs_term(pxsContext);
end.

