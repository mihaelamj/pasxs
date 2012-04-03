# pasxs &mdash; Crossroads I/O bindings for Delphi Pascal
*(Fork of Pascal (Delphi) Bindings for 0MQ; [paszmq](https://github.com/colinj/paszmq))*

This project aims to provide the full functionality of the underlying [Crossroads I/O](http://www.crossroads.io/) API to [Delphi Pascal](http://www.embarcadero.com/products/delphi) developers.

Bundled libxs version: **1.0.1** (32 and 64 bit, compiled with VS 10, nodebug)

## Getting Started

The quickest way to get started with pasxs is cloning the [pasxs project](https://github.com/mihaelamj/pasxs). There is a demo folder, just compile and run. Make sure that libxs.dll (32 or 64 bit) is in the same folder as your exe.

### Example server/client

#### Initialize context
```aContext      := TXS_Context.Create;```
#### Create server socket
```aServerSocket := TXS_Socket.Create(aContext, xstREP);```
#### Bind server to the transport ://address
```DoRun := aServerSocket.Bind(xttTCP, '*', 5555);```


#### Create client socket
```aClientSocket := TXS_Socket.Create(aContext, xstREQ);```
#### Connect client to the server
```DoRun := aClientSocket.Connect(xttTCP, 'localhost', 5555);```
#### Receive messages
```recBytes := aClientSocket.ReceiveString(recMsg)```
#### Send message
```sndBytes := aClientSocket.SendString(readStr);```

There is a [demonstartion project](https://github.com/mihaelamj/pasxs/tree/master/demo/Demo3) with server and client implementations.


## Included units

### libxs_consts.pas
Crossroads I/O constants 

### libxs_lib.pas
C function declarations and basic types 

### libxs_pas.pas
Wrappers around C functions in libxs_lib

### libxs_pas_obj.pas
Pascal Object model for XS library

### libxs_pas_obj_consts.pas
Constants and helpers for libxs_pas_obj.pas

##To Be Done
Wrap all necessary functions, add more examples and finish object model based on C++ XS object model.

