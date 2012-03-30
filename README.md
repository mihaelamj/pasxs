# pasxs &mdash; Crossroads I/O bindings for Delphi Pascal
*(Fork of Pascal (Delphi) Bindings for 0MQ; [paszmq](https://github.com/colinj/paszmq))*

This project aims to provide the full functionality of the underlying [Crossroads I/O](http://www.crossroads.io/) API to [Delphi Pascal](http://www.embarcadero.com/products/delphi) developers.

Bundled libxs version: **1.0.1** (32 and 64 bit, compiled with VS 10, nodebug)

## Getting Started

The quickest way to get started with pasxs is cloning the [pasxs project](https://github.com/mihaelamj/pasxs). There is a demo folder, just compile and run. Make sure that libxs.dll (32 or 64 bit) in the same folder as your exe.

### Example server/client

#### Initialize context
```pxsContext        := xs_init();```
#### Create server socket
```pxsServerSocket   := xs_socket(pxsContext, XS_SOCK_TYPE_REP);```
#### Bind server to the transport ://address
```xs_bind(pxsServerSocket, 'tcp://*:5555');```


#### Create client socket
```pxsClientSocket   := xs_socket(pxsContext, XS_SOCK_TYPE_REQ);```
#### Connect client to the server
```xs_connect(pxsClientSocket, 'tcp://localhost:5555');```
#### Receive messages
```xs_msg_init(xsClientMessage);
recBytes := pas_xs_recv(pxsServerSocket, recMsg, 256, 0);
Writeln(recMsg);
xs_msg_close(xsClientMessage);
```
#### Send message
```
sendMsg := 'Message to send';
xs_msg_init_size(xsServerMessage, Length(sendMsg));
sndBytes := pas_xs_send(pxsServerSocket, sendMsg, 0);
xs_msg_close(xsServerMessage);
```
#### Variable types
```
pxsContext      : Pointer;
pxsClientSocket : Pointer;
xsServerMessage : TXS_Msg;
xsClientMessage : TXS_Msg;
recBytes,
sndBytes        : integer;
readStr         : AnsiString;
recMsg          : AnsiString;
```

There is a demonstartion project with server and client implementations.


## Included units

### libxs_consts.pas
Crossroads I/O constants 


### libxs_lib.pas
C function declarations and basic types 


### libxs_pas.pas
Wrappers around C functions in libxs_lib

##To Be Done
Wrapp all the units, ake more exaples and make object model based on C++ XS object model.

