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

(* C function declarations and basic types *)

unit libxs_lib;

interface

uses
   libxs_consts;

type
  size_t = Cardinal;

(* Run-time API version detection
XS_EXPORT void xs_version (int *major, int *minor, int *patch);*)
procedure xs_version(var major, minor, patch: Integer); cdecl; external libxs_name;

(*  This function retrieves the errno as it is known to Crossroads library.   */
/*  The goal of this function is to make the code 100% portable, including    */
/*  where Crossroads are compiled with certain CRT library (on Windows) is    */
/*  linked to an application that uses different CRT library.                 */
XS_EXPORT int xs_errno (void); *)
function xs_errno: Integer; cdecl; external libxs_name;

(*  Resolves system errors and Crossroads errors to human-readable string.    */
XS_EXPORT const char *xs_strerror (int errnum); *)
function xs_strerror(errnum: Integer): PAnsiChar; cdecl; external libxs_name;

type
  PTXS_MsgRec = ^TXS_MsgRec;

  TXS_MsgRec = record
    content    : Pointer;
    flags      : Byte;
    vsm_size   : Byte;
    vsm_data   : array[0..XS_MAX_VSM_SIZE - 1] of Byte;
  end;

type
  TXS_Free_Func = procedure(data: Pointer; hint: Pointer); cdecl;

(* Message api *)
function xs_msg_close(var msg: TXS_MsgRec): Integer; cdecl; external libxs_name;
function xs_msg_copy(var dest: TXS_MsgRec; var src: TXS_MsgRec): Integer; cdecl; external libxs_name;
(* Returns the pointer to the message data (content):
   u.vsm.data if size <= XS_MAX_VSM_SIZE, on the stack, or
   u.lmsg.content->data otherwise, on the heap *)
function xs_msg_data(var msg: TXS_MsgRec): Pointer; cdecl; external libxs_name;
//sets all members to zero
function xs_msg_init(var msg: TXS_MsgRec): Integer; cdecl; external libxs_name;
(* allocates memory for message data
  if size > XS_MAX_VSM_SIZE then message if of type lmsg -> long message
  allocates memory to size + Sizeof(content_t) on the heap
  starts reference counting of message data*)
function xs_msg_init_size(var msg: TXS_MsgRec; size: size_t): Integer; cdecl; external libxs_name;
(*  does as xs_msg_init_size  with size > XS_MAX_VSM_SIZE *)
//int xs_msg_init_data (xs_msg_t *msg_, void *data_, size_t size_, xs_free_fn *ffn_, void *hint_)
(* allocates content_t
   assigns data to msg.data, data destructor to ffn and hint to hint
*)
function xs_msg_init_data(var msg: TXS_MsgRec; data: Pointer; size: size_t; var ffn: TXS_Free_Func; hint: Pointer): Integer; cdecl; external libxs_name;
function xs_msg_move(var dest: TXS_MsgRec; var src: TXS_MsgRec): Integer; cdecl; external libxs_name;
function xs_msg_size(var msg: TXS_MsgRec): size_t; cdecl; external libxs_name;

(*Context*)
function xs_init(): Pointer; cdecl; external libxs_name;
function xs_term(context: Pointer): Integer; cdecl; external libxs_name;
//function xs_setctxopt(s: Pointer; option: Integer; const optval: Pointer; optvallen: size_t): Integer; cdecl; external libxs_name;
//int xs_setctxopt (void *context, int option_name, const void *option_value, size_t option_len);
function xs_setctxopt(s: Pointer; option: Integer; const optval: integer; optvallen: size_t): Integer; cdecl; external libxs_name;

(* Socket api*)
function xs_socket(context: Pointer; type_: Integer): Pointer; cdecl; external libxs_name;
function xs_close(s: Pointer): Integer; cdecl; external libxs_name;
function xs_setsockopt(s: Pointer; option: Integer; const optval: Pointer; optvallen: size_t): Integer; cdecl; external libxs_name;
function xs_getsockopt(s: Pointer; option: Integer; var optval: Pointer; var optvallen: size_t): Integer; cdecl; external libxs_name;
function xs_bind(s: Pointer; const addr: PAnsiChar): Integer; cdecl; external libxs_name;
//int xs_connect (void *s_, const char *addr_)
function xs_connect(s: Pointer; const addr: PAnsiChar): Integer; cdecl; external libxs_name;

//int xs_sendmsg (void *s_, xs_msg_t *msg_, int flags_)
function xs_sendmsg(s: Pointer; var msg: TXS_MsgRec; flags: Integer): Integer; cdecl; external libxs_name;
//int xs_recvmsg (void *s_, xs_msg_t *msg_, int flags_)
function xs_recvmsg(s: Pointer; var msg: TXS_MsgRec; flags: Integer): Integer; cdecl; external libxs_name;

//int xs_send (void *s_, const void *buf_, size_t len_, int flags_)
function xs_send(s: Pointer; pBuf : PAnsiChar; len: size_t; flags: Integer): Integer; cdecl; external libxs_name;
//int xs_recv (void *socket, void *buf, size_t len, int flags);
function xs_recv(s: Pointer;  buf : AnsiString; len: size_t; flags: Integer): Integer; cdecl; external libxs_name;

(*I/O Multiplexing*)
(*typedef struct{
    void *socket;
    SOCKET fd;
     int fd;
    short events;
    short revents;} xs_pollitem_t;*)
type
  TXS_SocketRec = record
    socket     : Pointer;
    fd         : Integer;
    events     : SmallInt;
    revents    : SmallInt;
  end;

  PTXS_SocketRec = ^TXS_SocketRec;

(* Message buffer size for send/receive*)
type
   TMsgBuff = array [0..XS_MAX_MSG_BUF_SIZE - 1] of AnsiChar;
   PTMsgBuff = ^TMsgBuff;


//XS_EXPORT int xs_poll (xs_pollitem_t *items, int nitems, int timeout);
function xs_poll(const items: PTXS_SocketRec; nitems: Integer; timeout: Integer): Integer; cdecl; external libxs_name;


(*/******************************************************************************/
/*  The following utility functions are exported for use from language        */
/*  bindings in performance tests, for the purpose of consistent results in   */
/*  such tests.  They are not considered part of the core XS API per se,      */
/*  use at your own risk!                                                     */
/******************************************************************************/

/*  Starts the stopwatch. Returns the handle to the watch.                    */
XS_EXPORT void *xs_stopwatch_start (void);

/*  Stops the stopwatch. Returns the number of microseconds elapsed since the stopwatch was started.                                                */
XS_EXPORT unsigned long xs_stopwatch_stop (void *watch);*)

function xs_stopwatch_start(): Pointer; cdecl; external libxs_name;
function xs_stopwatch_stop(watch: Pointer): Cardinal; cdecl; external libxs_name;
//function xs_stopwatch_stop(watch: Pointer): LongWord; cdecl; external libxs_name;
implementation

end.
