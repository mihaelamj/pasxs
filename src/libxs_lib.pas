unit libxs_lib;

interface

uses
   libxs_consts;

type
  size_t = Cardinal;
//  short_t = SmallInt;
//  uns_long_t = LongWord;

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

(*Used for casting pointers back to the struct
    class Msg < FFI::Struct
      layout   :content, :pointer,
               :flags, :uint8,
               :vsm_size, :uint8,
               :vsm_data, [:uint8, 30]
    end # class Msg
*)
type
  PTXS_Msg = ^TXS_Msg;

  TXS_Msg = record
    content    : Pointer;
    flags      : Byte;
    vsm_size   : Byte;
    vsm_data   : array[0..XS_MAX_VSM_SIZE - 1] of Byte;
  end;

type
  TXS_Free_Func = procedure(data: Pointer; hint: Pointer); cdecl;

(* Message api *)
function xs_msg_close(var msg: TXS_Msg): Integer; cdecl; external libxs_name;
function xs_msg_copy(var dest: TXS_Msg; var src: TXS_Msg): Integer; cdecl; external libxs_name;
function xs_msg_data(var msg: TXS_Msg): Pointer; cdecl; external libxs_name;
function xs_msg_init(var msg: TXS_Msg): Integer; cdecl; external libxs_name;
function xs_msg_init_size(var msg: TXS_Msg; size: size_t): Integer; cdecl; external libxs_name;
function xs_msg_init_data(var msg: TXS_Msg; data: Pointer; size: size_t; var ffn: TXS_Free_Func; hint: Pointer): Integer; cdecl; external libxs_name;
function xs_msg_move(var dest: TXS_Msg; var src: TXS_Msg): Integer; cdecl; external libxs_name;
function xs_msg_size(var msg: TXS_Msg): size_t; cdecl; external libxs_name;

(*Context*)
function xs_init(): Pointer; cdecl; external libxs_name;
function xs_term(context: Pointer): Integer; cdecl; external libxs_name;
function xs_setctxopt(s: Pointer; option: Integer; const optval: Pointer; optvallen: size_t): Integer; cdecl; external libxs_name;

(* Socket api*)
function xs_socket(context: Pointer; type_: Integer): Pointer; cdecl; external libxs_name;
function xs_close(s: Pointer): Integer; cdecl; external libxs_name;
function xs_setsockopt(s: Pointer; option: Integer; const optval: Pointer; optvallen: size_t): Integer; cdecl; external libxs_name;
function xs_getsockopt(s: Pointer; option: Integer; var optval: Pointer; var optvallen: size_t): Integer; cdecl; external libxs_name;
function xs_bind(s: Pointer; const addr: PAnsiChar): Integer; cdecl; external libxs_name;
function xs_connect(s: Pointer; const addr: PAnsiChar): Integer; cdecl; external libxs_name;
function xs_send(s: Pointer; var msg: TXS_Msg; len: size_t; flags: Integer): Integer; cdecl; external libxs_name;
function xs_recv(s: Pointer; var msg: TXS_Msg; len: size_t; flags: Integer): Integer; cdecl; external libxs_name;
function xs_sendmsg(s: Pointer; var msg: TXS_Msg; flags: Integer): Integer; cdecl; external libxs_name;
function xs_recvmsg(s: Pointer; var msg: TXS_Msg; flags: Integer): Integer; cdecl; external libxs_name;

(*I/O Multiplexing*)
(*typedef struct{
    void *socket;
    SOCKET fd;
     int fd;
    short events;
    short revents;} xs_pollitem_t;*)
type
  TXS_Socket = record
    socket     : Pointer;
    fd         : Integer;
    events     : SmallInt;
    revents    : SmallInt;
  end;

  PTXS_Socket = ^TXS_Socket;

//XS_EXPORT int xs_poll (xs_pollitem_t *items, int nitems, int timeout);
function xs_poll(const items: PTXS_Socket; nitems: Integer; timeout: Integer): Integer; cdecl; external libxs_name;


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
