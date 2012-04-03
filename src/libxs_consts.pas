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

(* Crossroads I/O constants *)

unit libxs_consts;

interface

const
  libxs_name = 'libxs.dll';

(* On Windows platform some of the standard POSIX errnos are not defined.  *)
  XS_HAUSNUMERO                        = 156384712;

  ENOTSUP                             = (XS_HAUSNUMERO + 1);
  EPROTONOSUPPORT                     = (XS_HAUSNUMERO + 2);
  ENOBUFS                             = (XS_HAUSNUMERO + 3);
  ENETDOWN                            = (XS_HAUSNUMERO + 4);
  EADDRINUSE                          = (XS_HAUSNUMERO + 5);
  EADDRNOTAVAIL                       = (XS_HAUSNUMERO + 6);
  ECONNREFUSED                        = (XS_HAUSNUMERO + 7);
  EINPROGRESS                         = (XS_HAUSNUMERO + 8);
  ENOTSOCK                            = (XS_HAUSNUMERO + 9);
  EAFNOSUPPORT                        = (XS_HAUSNUMERO + 10);

(*  Native Crossroads error codes. *)
   EFSM                                = (XS_HAUSNUMERO + 51) ;
   ENOCOMPATPROTO                      = (XS_HAUSNUMERO + 52) ;
   ETERM                               = (XS_HAUSNUMERO + 53) ;
   EMTHREAD                            = (XS_HAUSNUMERO + 54) ;

const

(*  Size in bytes of the largest message that is still copied around
   rather than being reference-counted.
    enum {max_vsm_size = 29};     *)
  XS_MAX_VSM_SIZE                    = 30;

(*  Mesage flags.
        enum{
            more = 1,
            identity = 64,
            shared = 128};*)
  XS_FLAG_MORE                        = 1;
  XS_FLAG_IDENTITY                    = 64;
  XS_FLAG_SHARED                      = 128;

(*  Different message types.
        enum type_t{
            type_min = 101,
            type_vsm = 101,
            type_lmsg = 102,
            type_delimiter = 103,
            type_max = 103};*)

   XS_MSG_MIN                    = 101;
   XS_MSG_VSM                    = 101;
   XS_MSG_LMSG                   = 102;
   XS_MSG_DELIMITER              = 103;
   XS_MSG_MAX                    = 103;

(* Crossroads context definition. *)
   XS_MAX_SOCKETS = 1;
   XS_IO_THREADS =  2;

   //Context default parametars
   XS_CTX_DEF_SOCKETS = 512;
   XS_CTX_DEF_THREADS = 1;

(* Socket types.*)
   XS_SOCK_TYPE_PAIR      = 0;
   XS_SOCK_TYPE_PUB       = 1;
   XS_SOCK_TYPE_SUB       = 2;
   XS_SOCK_TYPE_REQ       = 3;
   XS_SOCK_TYPE_REP       = 4;
   XS_SOCK_TYPE_XREQ      = 5;
   XS_SOCK_TYPE_XREP      = 6;
   XS_SOCK_TYPE_PULL      = 7;
   XS_SOCK_TYPE_PUSH      = 8;
   XS_SOCK_TYPE_XPUB      = 9;
   XS_SOCK_TYPE_XSUB      = 10;
   XS_SOCK_TYPE_ROUTER    = XS_SOCK_TYPE_XREP;
   XS_SOCK_TYPE_DEALER    = XS_SOCK_TYPE_XREQ;

 (*  Socket options.  *)
   XS_SOCK_OPT_AFFINITY          = 4 ;
   XS_SOCK_OPT_IDENTITY          = 5 ;
   XS_SOCK_OPT_SUBSCRIBE         = 6 ;
   XS_SOCK_OPT_UNSUBSCRIBE       = 7 ;
   XS_SOCK_OPT_RATE              = 8 ;
   XS_SOCK_OPT_RECOVERY_IVL      = 9 ;
   XS_SOCK_OPT_SNDBUF            = 11 ;
   XS_SOCK_OPT_RCVBUF            = 12 ;
   XS_SOCK_OPT_RCVMORE           = 13 ;
   XS_SOCK_OPT_FD                = 14 ;
   XS_SOCK_OPT_EVENTS            = 15 ;
   XS_SOCK_OPT_TYPE              = 16 ;
   XS_SOCK_OPT_LINGER            = 17 ;
   XS_SOCK_OPT_RECONNECT_IVL     = 18 ;
   XS_SOCK_OPT_BACKLOG           = 19 ;
   XS_SOCK_OPT_RECONNECT_IVL_MAX = 21 ;
   XS_SOCK_OPT_MAXMSGSIZE        = 22 ;
   XS_SOCK_OPT_SNDHWM            = 23 ;
   XS_SOCK_OPT_RCVHWM            = 24 ;
   XS_SOCK_OPT_MULTICAST_HOPS    = 25 ;
   XS_SOCK_OPT_RCVTIMEO          = 27 ;
   XS_SOCK_OPT_SNDTIMEO          = 28 ;
   XS_SOCK_OPT_IPV4ONLY          = 31  ;
   XS_SOCK_OPT_KEEPALIVE         = 32  ;  //1.0.1

 (* Message options *)
   XS_MSG_OPT_MORE               = 1;

(* Send/recv options. *)
   XS_SR_OPT_DONTWAIT            = 1;
   XS_SR_OPT_SNDMORE             = 2;

(*  I/O multiplexing.*)
   XS_IOMUL_POLLIN               = 1;
   XS_IOMUL_POLLOUT              = 2;
   XS_IOMUL_POLLERR              = 4;

(* Message buffer size for send/receive*)
   XS_MAX_MSG_BUF_SIZE           = 256;

implementation

end.
