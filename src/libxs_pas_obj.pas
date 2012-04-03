unit libxs_pas_obj;

interface

uses
   SysUtils,
   Classes,
   libxs_lib,
   libxs_pas_obj_consts;

type

//   EXS_Generic_Exception = class(Exception)
//   private
//      FErrorNo     : Integer;
//      FErrorWhat   : string;
//   public
//      property ErrorNo    : Integer read FErrorNo;
//      property ErrorWhat  : string read FErrorWhat;
//   end;

   EXS_Exception = class(Exception)
   private
      FErrorNo     : Integer;
      FErrorWhat   : string;
   public
      constructor Create;
      property ErrorNo    : Integer read FErrorNo;
      property ErrorWhat  : string read FErrorWhat;
  end;

   EXS_Pas_Exception = class(Exception)
   private
      FErrorNo     : Integer;
      FErrorWhat   : string;
   public
      constructor Create(const aErrorNo : integer);
      property ErrorNo    : Integer read FErrorNo;
      property ErrorWhat  : string read FErrorWhat;
   end;

   TXS_Context = class
   private
      FPContext      : Pointer;
      FMaxNoSockets  : integer;
      FMaxNoThreads  : integer;
      FNoOfSockets   : integer;
      procedure SetMaxNoSockets(const Value: integer);
      procedure SetMaxNoThreads(const Value: integer);
      function SetCtxOptInternal(const aOptionName, aOptionValue : integer) : boolean;
   public
      constructor Create; overload;
      destructor Destroy; override;

      property Context        : Pointer read FPContext;
      property MaxNoSockets   : integer read FMaxNoSockets write SetMaxNoSockets;
      property MaxNoThreads   : integer read FMaxNoThreads write SetMaxNoThreads;
   end;

   TXS_SocketConnectionList = class;
   TXS_Socket = class
   private
      FXS_Context    : TXS_Context;
      FPSocket       : Pointer;
      FSocketType    : TXS_SocketType;
      FConnections   : TXS_SocketConnectionList;
      function GetSocketTypeName: string;
      function GetSocketTypeValue: integer;
   public
      constructor Create(aContext: TXS_Context; aType: TXS_SocketType);
      destructor Destroy; override;
      function Close : boolean;
      function Connect(aTransportType : TXS_TansportType; aAddress : AnsiString; aPort : integer): boolean;
      function Bind(aTransportType : TXS_TansportType; aAddress : AnsiString; aPort : integer) : boolean;

      function SendString(const aStr : AnsiString; aDontWait : boolean = False; aSendMore : boolean = False) : integer;
      function ReceiveString(var aStr: AnsiString; aDontWait : boolean = False; aSendMore : boolean = False): integer;
      //function ReceiveString(var aStr: AnsiString; MessageLen: size_t; aDontWait : boolean = False; aSendMore : boolean = False): integer;

      property XS_Contect        : TXS_Context read FXS_Context;
      property Socket            : Pointer read FPSocket;
      property SocketType        : TXS_SocketType read FSocketType;
      property SocketTypeName    : string read GetSocketTypeName;
      property SocketTypeValue   : integer read GetSocketTypeValue;
      property Connections       : TXS_SocketConnectionList read FConnections;
   end;

   TXS_SocketConnection = class
   private
      FTransportType    : TXS_TansportType;  //xttTCP, xttPGM, xttEPGM, xttIPC, xttINPROC, xttNone
      FConnectionType   : TXS_Socket_ConnectionType;  //xscCONNECT, xscBIND, xscNONE
      FAddress          : AnsiString;
      FPort             : integer;
      FParent           : TXS_SocketConnectionList;
      function GetFullAddress: AnsiString;
      function GetConnectionTypeName: string;
      function GetTransportTypeName: string;
      function GetDescription: String;
   public
      constructor Create(aParent: TXS_SocketConnectionList;
                         aTransportType : TXS_TansportType;
                         aConnectionType : TXS_Socket_ConnectionType;
                         aAddress : AnsiString;
                         aPort : integer);
      destructor Destroy; override;

      property TransportType        : TXS_TansportType read FTransportType;
      property ConnectionType       : TXS_Socket_ConnectionType read FConnectionType;
      property TransportTypeName    : string read GetTransportTypeName;
      property ConnectionTypeName   : string read GetConnectionTypeName;
      property Address              : AnsiString read FAddress;
      property Port                 : integer read FPort;
      property Parent               : TXS_SocketConnectionList read FParent;
      property FullAddress          : AnsiString read GetFullAddress;
      property Description          : String read GetDescription;
   end;

   TXS_SocketConnectionList = class
   private
      FItems      : TList;
      FXS_Socket  : TXS_Socket;
      function GetCount: Integer;
      function GetItem(Index: Integer): TXS_SocketConnection;
   public
      constructor Create(aXS_Socket : TXS_Socket);  reintroduce;
      destructor Destroy; override;
      procedure Clear;

      function Add(aBind : boolean;
                   aTransportType: TXS_TansportType;
                   aAddress: AnsiString; aPort: integer = 0): TXS_SocketConnection;

      function ConnectBindSocket(aBind : boolean; aTransportType : TXS_TansportType; aAddress : AnsiString; aPort : integer = 0):boolean;

      property Items[Index: Integer]: TXS_SocketConnection read GetItem; default;
      property Count                : Integer read GetCount;
      property XS_Socket            : TXS_Socket read FXS_Socket;

   end;

(*
int io_threads = 4;
rc = xs_setctxopt (context, XS_IO_THREADS, &io_threads, sizeof (io_threads));
*)

implementation

uses
  libxs_consts,
  libxs_pas;

{ EXS_Generic_Exception }

//constructor EXS_Generic_Exception.Create(const Msg: string);
//begin
//   FErrorNo    := -1;
//   FErrorWhat  := '';
//   inherited Create(FErrorWhat);
//end;

{ EXS_Exception }

constructor EXS_Exception.Create;
begin
   FErrorNo    := libxs_lib.xs_errno();
   FErrorWhat  := String(libxs_lib.xs_strerror(FErrorNo));
   inherited Create(FErrorWhat);
end;

{ EXS_Pas_Exception }

constructor EXS_Pas_Exception.Create(const aErrorNo: integer);
begin
   FErrorNo    := aErrorNo;
   FErrorWhat  := libxs_pas_obj_consts.GetErrorName(FErrorNo);
   inherited Create(FErrorWhat);
end;

{ TXS_Context }

constructor TXS_Context.Create;
begin
   FPContext := nil;
   //Assign default values that context is created with
   FMaxNoSockets  := libxs_consts.XS_CTX_DEF_SOCKETS;
   FMaxNoThreads  := libxs_consts.XS_CTX_DEF_THREADS;
   FNoOfSockets   := 0;
   FPContext      := libxs_lib.xs_init();
   if FPContext = nil then
      raise EXS_Exception.Create;
   inherited Create;
end;

destructor TXS_Context.Destroy;
begin
   if libxs_lib.xs_term(FPContext) <> 0 then
      raise EXS_Exception.Create;
   FPContext := nil;
   inherited Destroy;
end;


function TXS_Context.SetCtxOptInternal(const aOptionName, aOptionValue: integer): boolean;
begin
   //Cannot change options if context has any sockets
   result := FNoOfSockets = 0;
   if not result then
      raise EXS_Pas_Exception.Create(libxs_pas_obj_consts.XS_ERR_CTX_OPTIONS)
   else begin
      if libxs_lib.xs_setctxopt(FPContext, aOptionName, aOptionValue, SizeOf(aOptionValue)) <> 0 then
         raise EXS_Exception.Create
      else
         result := True;
   end;
end;

procedure TXS_Context.SetMaxNoSockets(const Value: integer);
begin
   if FMaxNoSockets <> Value then begin
      if SetCtxOptInternal(libxs_consts.XS_MAX_SOCKETS, Value) then
         FMaxNoSockets := Value;
   end;
end;

procedure TXS_Context.SetMaxNoThreads(const Value: integer);
begin
   if FMaxNoThreads <> Value then begin
      if SetCtxOptInternal( libxs_consts.XS_IO_THREADS, Value) then
         FMaxNoThreads := Value;
   end;
end;



{ TXS_Socket }

function TXS_Socket.Connect(aTransportType: TXS_TansportType;
                            aAddress: AnsiString;
                            aPort: integer): boolean;
begin
   result := False;
   try
      result := FConnections.ConnectBindSocket(False, aTransportType, aAddress, aPort);
   except
      on E : EXS_Pas_Exception do
        raise E;
   end;
end;

function TXS_Socket.Bind(aTransportType: TXS_TansportType;
                         aAddress: AnsiString;
                         aPort: integer): boolean;
begin
   result := False;
   try
      result := FConnections.ConnectBindSocket(True, aTransportType, aAddress, aPort);
   except
      on E : EXS_Pas_Exception do
        raise E;
   end;
end;

constructor TXS_Socket.Create(aContext: TXS_Context; aType: TXS_SocketType);
begin
   FPSocket       := nil;

   if (aContext = nil) then
      raise EXS_Pas_Exception.Create(libxs_pas_obj_consts.XS_ERR_CTX_NIL);
   if (aContext.Context = nil) then
      raise EXS_Pas_Exception.Create(libxs_pas_obj_consts.XS_ERR_CTX_CTX_NIL);
   if not SocketTypeExists(aType) then
      raise EXS_Pas_Exception.Create(libxs_pas_obj_consts.XS_ERR_SOCK_TYPE);

   inherited Create;
   FXS_Context    := aContext;
   FSocketType    := aType;
   FPSocket       := libxs_lib.xs_socket(FXS_Context.Context, SocketTypeValue);
   FConnections   := TXS_SocketConnectionList.Create(Self);
   if FPSocket = nil then
      raise EXS_Exception.Create;
end;


function TXS_Socket.Close : boolean;
begin
   result := FPSocket = nil;
   if not result then begin
      if libxs_lib.xs_close(FPSocket) <> 0 then
         raise EXS_Exception.Create;
    FPSocket := nil;
  end;
end;

destructor TXS_Socket.Destroy;
begin
   Close;
   FConnections.Free;
   inherited Destroy;
end;


function TXS_Socket.GetSocketTypeName: string;
begin
   result := libxs_pas_obj_consts.GetSocketTypeRec(FSocketType).Name;
end;

function TXS_Socket.GetSocketTypeValue: integer;
begin
   result := libxs_pas_obj_consts.GetSocketTypeRec(FSocketType).Value;
end;

function TXS_Socket.ReceiveString(var aStr: AnsiString; aDontWait : boolean = False; aSendMore : boolean = False): integer;
begin
   result := libxs_pas.pas_xs_recv(Socket,
                                   aStr,
                                   libxs_consts.XS_MAX_MSG_BUF_SIZE,
                                   libxs_pas_obj_consts.SetSndRcvIntFlags(aDontWait, aSendMore));
//   if result < 0 then
//      raise EXS_Exception.Create;
end;

function TXS_Socket.SendString(const aStr : AnsiString; aDontWait : boolean = False; aSendMore : boolean = False) : integer;
begin
   result := libxs_pas.pas_xs_send(Socket,
                                   aStr,
                                   libxs_pas_obj_consts.SetSndRcvIntFlags(aDontWait, aSendMore));
//   if result < 0 then
//      raise EXS_Exception.Create;
end;

{ TXS_SocketConnectionList }

constructor TXS_SocketConnectionList.Create(aXS_Socket : TXS_Socket);
begin
   if aXS_Socket = nil then
      raise EXS_Pas_Exception.Create(libxs_pas_obj_consts.XS_ERR_SOCK_NIL)
   else if aXS_Socket.Socket = nil then
      raise EXS_Pas_Exception.Create(libxs_pas_obj_consts.XS_ERR_SOCK_SOCK_NIL);

   inherited Create;
   FXS_Socket  := aXS_Socket;
   FItems      := TList.Create;
end;

destructor TXS_SocketConnectionList.Destroy;
begin
   Clear;
   inherited Destroy;
end;

function TXS_SocketConnectionList.ConnectBindSocket(aBind : boolean;
                                                    aTransportType: TXS_TansportType;
                                                    aAddress: AnsiString;
                                                    aPort: integer = 0): boolean;
var
   rez : integer;

   aFullAddress : AnsiString;
begin
   result := False;
   //Check for supported transports on Windows
   if aTransportType = xttIPC then
      raise EXS_Pas_Exception.Create(libxs_pas_obj_consts.XS_ERR_TRANS_TYPE_NOIMP)
   else if FXS_Socket.SocketType = xstPAIR then begin
      if Count > 0 then
         raise EXS_Pas_Exception.Create(libxs_pas_obj_consts.XS_ERR_SOCK_PAIR_MANY);
   end //Check for empty address
   else if aAddress = '' then
      raise EXS_Pas_Exception.Create(libxs_pas_obj_consts.XS_ERR_TRANS_NOADDR)
//   else if aTransPortType in [xttPGM, xttEPGM]  then begin
//
//   end;
(*
    if ((protocol_ == "pgm" || protocol_ == "epgm") &&
          options.type != XS_PUB && options.type != XS_SUB &&
          options.type != XS_XPUB && options.type != XS_XSUB) {
        errno = ENOCOMPATPROTO;
        return -1;
    }
*)
   else begin
      result := True;
      //Check for ports
      if aTransPortType in [xttTCP, xttPGM, xttEPGM] then begin
         if aPort = 0 then begin
            result := False;
            raise EXS_Pas_Exception.Create(libxs_pas_obj_consts.XS_ERR_TRANS_NOPORT);
         end;
      end;
   end;


   if result then begin
      aFullAddress   := libxs_pas_obj_consts.GetFullAddress(aTransportType, aAddress, aPort);
      if aBind then
         rez := libxs_lib.xs_bind(FXS_Socket.Socket, PAnsiChar(aFullAddress))
      else
         rez := libxs_lib.xs_connect(FXS_Socket.Socket, PAnsiChar(aFullAddress));
   end;

   result := rez = 0;
   if result then
      Add(aBind, aTransportType, aAddress, aPort)
   else
      raise EXS_Exception.Create;
end;


function TXS_SocketConnectionList.Add(aBind : boolean;
                                      aTransportType: TXS_TansportType;
                                      aAddress: AnsiString;
                                      aPort: integer): TXS_SocketConnection;
var
   connType : TXS_Socket_ConnectionType;
begin
   connType := xscCONNECT;
   if aBind then
      connType := xscBIND;
   result := TXS_SocketConnection.Create(Self, aTransportType, connType, aAddress, aPort);
   FItems.Add(result);
end;

procedure TXS_SocketConnectionList.Clear;
var
   i : Integer;
begin
   for i := 0 to Count -1 do
      TXS_SocketConnection(FItems[i]).Free;
   FItems.Clear;
end;


function TXS_SocketConnectionList.GetCount: Integer;
begin
   result := FItems.Count;
end;

function TXS_SocketConnectionList.GetItem(Index: Integer): TXS_SocketConnection;
begin
   result := TXS_SocketConnection(FItems[Index]);
end;

{ TXS_SocketConnection }

constructor TXS_SocketConnection.Create(aParent: TXS_SocketConnectionList;
                                        aTransportType: TXS_TansportType;
                                        aConnectionType: TXS_Socket_ConnectionType;
                                        aAddress: AnsiString;
                                        aPort: integer);
begin
   if not libxs_pas_obj_consts.TransportTypeExists(aTransportType) then
      raise EXS_Pas_Exception.Create(libxs_pas_obj_consts.XS_ERR_TRANS_TYPE_UNKN);
   inherited Create;
   FParent           := aParent;
   FTransportType    := aTransportType;
   FConnectionType   := aConnectionType;
   FAddress          := aAddress;
   FPort             := aPort;
end;

destructor TXS_SocketConnection.Destroy;
begin
   //
   inherited Destroy;
end;

function TXS_SocketConnection.GetFullAddress: AnsiString;
begin
   result := libxs_pas_obj_consts.GetFullAddress(FTransportType, FAddress, FPort);
end;

function TXS_SocketConnection.GetTransportTypeName: string;
begin
   result := libxs_pas_obj_consts.GetTransportTypeRec(FTransportType).Name;


end;

function TXS_SocketConnection.GetConnectionTypeName: string;
begin
   result := libxs_pas_obj_consts.GetConnectionTypeName(FConnectionType);
end;

function TXS_SocketConnection.GetDescription: String;
begin
   result := Format('%s -> %s',
                    [libxs_pas_obj_consts.GetConnectionTypeName(FConnectionType),
                     FullAddress]);
end;



end.
