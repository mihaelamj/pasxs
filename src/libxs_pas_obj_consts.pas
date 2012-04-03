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

(* Constants and helpers for libxs_pas_obj.pas*)

unit libxs_pas_obj_consts;

interface
uses
   libxs_consts;

const
   //XS PAS class errors
   XS_ERR_CTX_OPTIONS      = 1;
   XS_ERR_CTX_NIL          = 2;
   XS_ERR_CTX_CTX_NIL      = 3;
   XS_ERR_SOCK_TYPE        = 4;
   XS_ERR_SOCK_NIL         = 5;
   XS_ERR_SOCK_SOCK_NIL    = 6;
   XS_ERR_TRANS_TYPE_UNKN  = 7;
   XS_ERR_TRANS_TYPE_NOIMP = 8;
   XS_ERR_SOCK_PAIR_MANY   = 9;
   XS_ERR_TRANS_NOADDR     = 10;
   XS_ERR_TRANS_NOPORT     = 11;

   cErrCtxOptions    = 'Cannot change options on context that has sockets';
   cErrCtxNil        = 'Context is not created';
   cErrCtxCtxNil     = 'Context is not initialized';
   cErrSockType      = 'Unknown socket type';
   cErrSockNil       = 'Socket is not created';
   cErrSockSockNil   = 'Socket is not initialized';
   cErrTransTypeUnkn = 'Unknown transport type';
   cErrTransTypeNoIm = 'Unimplemented transport type';
   cErrSockPairMany  = 'Socket of type pair can have just one connection';
   cErrTransNoAddr   = 'Cannot connect to empty address';
   cErrTransNoPort   = 'Cannot connect to empty port';
type
   //Transport types
   TXS_TansportType = (xttTCP, xttPGM, xttEPGM, xttIPC, xttINPROC);
   TXS_TansportTypeRec = record
      Name  : String[50];
      Value : String[10];
    end;

type
   //Socket Types
   TXS_SocketType = (xstPAIR, xstPUB, xstSUB, xstREQ, xstREP, xstXREQ, xstXREP,
                     xstPULL, xstPUSH, xstXPUB, xstXSUB, xstROUTER, xstDEALER);
   TXS_SocketTypeRec = record
      Name  : string[40];
      Value : integer;
    end;

type
//      FNonBlocking   : boolean;
//      FSendMore      : boolean;


(* Send/recv options. *)
//   XS_SR_OPT_DONTWAIT            = 1;
//   XS_SR_OPT_SNDMORE             = 2;

//if (flags_ & XS_DONTWAIT || options.sndtimeo == 0)
//    if (flags_ & XS_SNDMORE)
//        msg_->set_flags (msg_t::more);

//Sending/receiving options
   TXS_SndRcv_OptionsRec = record
      DontWait  : boolean;
      SendMore  : boolean;
   end;


type
   //Socket connection types
   TXS_Socket_ConnectionType = (xscCONNECT, xscBIND, xscNONE);


function GetErrorName(const aErrorNo : integer) : string;
function GetSocketTypeRec(aSocketType : TXS_SocketType): TXS_SocketTypeRec;
function GetTransportTypeRec(aTransportType : TXS_TansportType): TXS_TansportTypeRec;
function GetFullAddress(aTransport : TXS_TansportType; aAddress : AnsiString; aPort : integer) : AnsiString;
function GetConnectionTypeName(aConnType : TXS_Socket_ConnectionType):string;
function SocketTypeExists(aSocketType : TXS_SocketType) : boolean;
function TransportTypeExists(aTransportType : TXS_TansportType) : boolean;
procedure GetSndRcvIntFlags(aIntFlags : integer; out aDontWait, aSendMore : boolean);
function SetSndRcvIntFlags(aDontWait, aSendMore : boolean) : integer;

implementation

uses
  SysUtils;

const
   cSockTypeArr : array[TXS_SocketType] of TXS_SocketTypeRec =
   (
      (Name : 'Exclusive pair';              Value : XS_SOCK_TYPE_PAIR),
      (Name : 'Publish';                     Value : XS_SOCK_TYPE_PUB),
      (Name : 'Subscribe';                   Value : XS_SOCK_TYPE_SUB),
      (Name : 'Request (ordered)';           Value : XS_SOCK_TYPE_REQ),
      (Name : 'Reply (ordered)';             Value : XS_SOCK_TYPE_REP),
      (Name : 'Request (unordered)';         Value : XS_SOCK_TYPE_XREQ),
      (Name : 'Reply (unordered)';           Value : XS_SOCK_TYPE_XREP),
      (Name : 'Push (pipeline)';             Value : XS_SOCK_TYPE_PULL),
      (Name : 'Pull (pipeline)';             Value : XS_SOCK_TYPE_PUSH),
      (Name : 'Publish (subscription)';      Value : XS_SOCK_TYPE_XPUB),
      (Name : 'Subscribe (subscription)';    Value : XS_SOCK_TYPE_XSUB),
      (Name : 'Router';                      Value : XS_SOCK_TYPE_ROUTER),
      (Name : 'Dealer';                      Value : XS_SOCK_TYPE_DEALER)
   );

   cTransportTypeArr : array[TXS_TansportType] of TXS_TansportTypeRec =
   (
      (Name : 'TCP';                                              Value : 'tcp://'),
      (Name : 'PGM (Pragmatic General Multicast)';                Value : 'pgm://'),
      (Name : 'EPGM (Encapsulated Pragmatic General Multicas)';   Value : 'epgm://'),
      (Name : 'IPC (inter-process only on NIX platforms)';        Value : 'ipc://'),
      (Name : 'INPROC (between threads in ctx)';                  Value : 'inproc://')
   );

function GetErrorName(const aErrorNo : integer) : string;
begin
   result := '';
   case aErrorNo of
      XS_ERR_CTX_OPTIONS      : result := cErrCtxOptions;
      XS_ERR_CTX_NIL          : result := cErrCtxNil;
      XS_ERR_CTX_CTX_NIL      : result := cErrCtxCtxNil;
      XS_ERR_SOCK_TYPE        : result := cErrSockType;
      XS_ERR_SOCK_NIL         : result := cErrSockNil;
      XS_ERR_SOCK_SOCK_NIL    : result := cErrSockSockNil;
      XS_ERR_TRANS_TYPE_UNKN  : result := cErrTransTypeUnkn;
      XS_ERR_TRANS_TYPE_NOIMP : result := cErrTransTypeNoIm;
      XS_ERR_SOCK_PAIR_MANY   : result := cErrSockPairMany;
      XS_ERR_TRANS_NOADDR     : result := cErrTransNoAddr;
   end;
end;

function SocketTypeExists(aSocketType : TXS_SocketType) : boolean;
begin
   result := (aSocketType >= Low(TXS_SocketType)) and
             (aSocketType <= High(TXS_SocketType));
end;

function TransportTypeExists(aTransportType : TXS_TansportType) : boolean;
begin
   result := (aTransportType >= Low(TXS_TansportType)) and
             (aTransportType <= High(TXS_TansportType));
end;

function GetSocketTypeRec(aSocketType : TXS_SocketType): TXS_SocketTypeRec;
begin
   if SocketTypeExists(aSocketType)  then
      result := cSockTypeArr[aSocketType]
   else begin
      result.Name    := 'None';
      result.Value   := -1;
   end;
end;

function GetTransportTypeRec(aTransportType : TXS_TansportType): TXS_TansportTypeRec;
var
   aTransTypeSet : set of TXS_TansportType;
begin
   if TransportTypeExists(aTransportType) then
      result := cTransportTypeArr[aTransportType]
   else begin
      result.Name    := 'None';
      result.Value   := '';
   end;
end;

function GetConnectionTypeName(aConnType : TXS_Socket_ConnectionType):string;
begin
   case aConnType of
      xscCONNECT  : result := 'Connect';
      xscBIND     : result := 'Bind'
   else
      result :='None';
   end;
end;

function GetFullAddress(aTransport : TXS_TansportType; aAddress : AnsiString; aPort : integer) : AnsiString;
begin
   result := GetTransportTypeRec(aTransport).Value + aAddress;
   result := Format('%s%s', [GetTransportTypeRec(aTransport).Value, aAddress]);
   if aPort > 0 then
      result := Format('%s:%d', [result, aPort]);
end;


function SetSndRcvIntFlags(aDontWait, aSendMore : boolean) : integer;
begin
   result := 0;
   if aDontWait then
      result := result or (1 shl XS_SR_OPT_DONTWAIT);
   if aSendMore then
      result := result or (1 shl XS_SR_OPT_SNDMORE);
end;

procedure GetSndRcvIntFlags(aIntFlags : integer; out aDontWait, aSendMore : boolean);
begin
   aDontWait   := (aIntFlags and (1 shl XS_SR_OPT_DONTWAIT)) <> 0;
   aSendMore   := (aIntFlags and (1 shl XS_SR_OPT_SNDMORE)) <> 0;
end;

end.
