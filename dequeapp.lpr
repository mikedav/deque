program dequeappl;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp, udeque, crt
  { you can add units after this };

type

  { DequeApp }

  DequeApp = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
  end;

{ DequeApp }

procedure DequeApp.DoRun;
var
  ErrorMsg, query: String;
  history: array[1..10000] of String;
  hsize, curhindex:integer;
  k:char;
  m:deque;
  dict:array[1..6] of string = ('help', 'show', 'popback', 'popfront', 'pushback', 'pushfront');
  chopped:tstringarray;
  valprovided, legit:boolean;
  val, i:integer;
begin
  // quick check parameters
  ErrorMsg:=CheckOptions('h', 'help');
  if ErrorMsg<>'' then begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  // parse parameters
  if HasOption('h', 'help') then begin
    WriteHelp;
    Terminate;
    Exit;
  end;

   query:='';
   hsize:=0;

  repeat begin
        hsize:=hsize+1;
        history[hsize]:='';
        query:='';
        curhindex:=hsize;
        repeat begin
              clrscr;
              write(query);
               k:=readkey;
               if k=#13 then break
               else if (k=#9) then begin
        legit:=false;
        for i:=1 to 8 do begin
           if(leftstr(dict[i],length(query))=query) then begin
             legit:=true;
             break;
           end;
        end;
        if(legit) then query:=dict[i];
                 end
               else if k=#8 then query:=leftstr(query, length(query)-1)
               else if  k=#0 then begin
                 k:=readkey;
                 if (k=#80) and (curhindex<hsize) then begin
                           curhindex:=curhindex+1;
                           query:=history[curhindex];
                 end;
                 if (k=#72) and (curhindex>1) then begin
                           curhindex:=curhindex-1;
                           query:=history[curhindex];
                 end;
               end else query:=query+k;
               if curhindex=hsize then history[hsize]:=query;
        end until false;
        if query='' then continue;
        chopped:=query.split(' ');
        valprovided:=true;
        legit:=false;
        try
           val:=strtoint(chopped[1]);
        except
           valprovided:=false;
        end;
        if query[1]='q' then break;
        for i:=1 to 6 do begin
           if(leftstr(dict[i],length(chopped[0]))=chopped[0]) then begin
             legit:=true;
             break;
           end;
        end;
        if legit then begin
          writeln;
              if i=1 then begin write('help, show, popback, popfront, pushback [value], pushfront [value], q* to quit. Press Enter to continue.'); readln; end else
              if i=2 then begin show(m); write('Press Enter to continue');readln; end else
              if i=3 then pop_back(m) else
              if i=4 then pop_front(m) else
              if valprovided then begin
                 if i=5 then push_back(m, val) else push_front(m, val);
              end else begin write('Value to push wasn`t provided or couldnt be converted to integer. Press Enter to continue'); readln; end;
        end else begin
              writeln;
              write('Command '+chopped[0]+' not found. Try "help" and use lowercase. Press Enter to continue.'); readln;
        end;
  end until false;

  // stop program loop
  Terminate;
end;

constructor DequeApp.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor DequeApp.Destroy;
begin
  inherited Destroy;
end;

procedure DequeApp.WriteHelp;
begin
  { add your help code here }
  writeln('Usage: ', ExeName, ' -h');
end;

var
  Application: DequeApp;
begin
  Application:=DequeApp.Create(nil);
  Application.Title:='DoubleEndedQ';
  Application.Run;
  Application.Free;
end.

