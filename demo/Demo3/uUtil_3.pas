unit uUtil_3;

interface

uses
   libxs_pas_obj;

const
   cQuitServer = 'squit';
   cQuitClient = 'cquit';

procedure Finish(aCtx : TXS_Context; aSock: TXS_Socket);

implementation

procedure Finish(aCtx : TXS_Context; aSock: TXS_Socket);
begin
   if aSock <> nil then
      aSock.Free;
   if aCtx <> nil then
      aCtx.Free;
   Halt;
end;

end.
