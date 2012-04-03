(*
   Crossroads I/O 1.0.1 example program - Basic Server 2

   It's using TXS_Msg record to send/receive messages (pas_xs_sendmsg and pas_xs_send)
   instead of plain AnsiStrings (pas_xs_send and pas_xs_recv)

   Server will run foreverer and will accept tcp connections on the port 5555

   It will echo what was sent to it on the console

   libxs.dll must be placed in the same directory with the exe
*)

program server_2;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  libxs_consts in '..\..\src\libxs_consts.pas',
  libxs_lib in '..\..\src\libxs_lib.pas',
  libxs_pas in '..\..\src\libxs_pas.pas';

var
  pxsContext      : Pointer;
  pxsServerSocket : Pointer;

  xsServerMessage : TXS_MsgRec;
  xsClientMessage : TXS_MsgRec;

  recBytes,
  sndBytes        : integer;

  recMsg,
  sendMsg         : AnsiString;

begin
   Writeln('Starting Crossroads I/O server!');
   (*Initialise Crossroads context -> context is thread safe and may be shared
   among as many application threads as necessary, without any additional locking
   required on the part of the caller.*)
   pxsContext        := xs_init();
   (*Create a server socket -> the individual sockets within a context are not thread safe
   applications may not use a single socket concurrently from multiple threads.
   XS_SOCK_TYPE_REP enables to receive requests from and send replies to a client*)
   pxsServerSocket   := xs_socket(pxsContext, XS_SOCK_TYPE_REP);
   (*Create an endpoint (transport ://address) for accepting connections
   and bind it to the socket*)
   xs_bind(pxsServerSocket, 'tcp://*:5555');

   while True do begin  //Forever :)
      recMsg := '';
      (*Initialise an empty message to be received from the client*)
      xs_msg_init(xsClientMessage);
      (*Receive a message/part from a socket -> block until a message is available
      to be received from the socket, 0 -> no flags*)
      recBytes := pas_xs_recvmsg(pxsServerSocket, xsClientMessage);
      recMsg   := GetMessageData(xsClientMessage, recBytes);
      Writeln(Format('Received : %s (%d bytes)', [recMsg, recBytes]));

      (*Close the received message*)
      xs_msg_close(xsClientMessage);

      (*Simulate some work*)
      Sleep (3);

      sendMsg := recMsg;
      xsServerMessage := NewMessageStr(sendMsg);
      //SetMessageData(xsServerMessage, sendMsg);
      (*Send the server message on the server socket, to the client, 0 -> no flags*)
      sndBytes := pas_xs_sendmsg(pxsServerSocket, xsServerMessage);
      Writeln(Format('Sent %s (%d bytes)', [sendMsg, sndBytes]));
      (*Close the sent message*)
      xs_msg_close(xsServerMessage);
   end;
   WriteLn('Server terminated!');
   (* CLose the server socket and terminate the context *)
   xs_close(pxsServerSocket);
   xs_term(pxsContext);
end.

