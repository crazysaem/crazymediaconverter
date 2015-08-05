unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, JvExControls, JvSpecialProgress, ComCtrls, JvExComCtrls,
  JvProgressBar, QProgBar, shellapi, StdCtrls, JvExStdCtrls, JvHtControls,
  Menus, pngextra, pngimage, ExtCtrls, PopupListEx, TLHelp32;

type
  TForm2 = class(TForm)
    QProgressBar1: TQProgressBar;
    JvHTListBox1: TJvHTListBox;
    PopupMenu1: TPopupMenu;
    Delete1: TMenuItem;
    PNGButton1: TPNGButton;
    Label1: TLabel;
    Label2: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure JvHTListBox1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure PNGButton1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    procedure CM_MenuClosed(var msg: TMessage) ; message CM_MENU_CLOSED;
    procedure WMDROPFILES(var Msg: TMessage); message WM_DROPFILES;
  public
    { Public declarations }
  end;

type
  TThreadConvert = class(TThread)
  private
    lauf:integer;
    ffcl:boolean;
  protected
    procedure ffclose;
    procedure Start;
    procedure Finish;
    procedure Refresh;
    procedure SetFokus;
    procedure Execute; override;
  end;

var
  Form2: TForm2;
  PNGB1T,ProgT,F2H,F2L1T:integer;
  programmpfad:string;
  conversion,abort:boolean;

implementation

uses Unit1;

{$R *.dfm}

function DeleteFolder(const Path: string; AllowUndo: Boolean = False;
  ShowProgress: Boolean = False): Boolean;
var
  fo: TSHFileOpStruct;
  cPath: string;
begin
  if not DirectoryExists(Path) then
  begin
    Result := False;
    Exit;
  end;
  FillChar(fo, SizeOf(fo), 0);
  fo.Wnd := Application.Handle;
  fo.wFunc := FO_DELETE;
  cPath := Path + #0;
  fo.pFrom := PChar(cPath);
  fo.fFlags := FOF_NOCONFIRMATION;
  if AllowUndo then fo.fFlags := fo.fFlags or FOF_ALLOWUNDO;
  if not ShowProgress then fo.fFlags := fo.fFlags or FOF_SILENT;
  Result := (SHFileOperation(fo) = 0) and (not fo.fAnyOperationsAborted);
end;


procedure TForm2.WMDROPFILES(var Msg: TMessage);
var i, anzahl, size: Integer;
    Dateiname: PChar;
    ch1,ch2:string;
begin
  //form2.JvHTListBox1.Clear;
  inherited;
  anzahl := DragQueryFile(Msg.WParam, DF_NUMBEROFFILES, Dateiname, 255);
  for i := 0 to (anzahl - 1) do
  begin
    size := DragQueryFile(Msg.WParam, i, nil, 0) + 1;
    Dateiname := StrAlloc(size);
    DragQueryFile(Msg.WParam, i, Dateiname, size);
    form2.JvHTListBox1.Items.Add(StrPas(Dateiname));
    ch1:=ExtractFilePath(Dateiname);
    ch2:=programmpfad+'Converted Media\';
      if (ch1=ch2) then begin
        showmessage('You cant convert Files, which are already in the'+#13#10+
                    programmpfad+'Converted Media'+' Folder.');
        form2.JvHTListBox1.Clear;
        exit;
      end;
    StrDispose(Dateiname);
  end;
  DragFinish(Msg.WParam);
  form2.JvHTListBox1.ItemIndex:=-1;
end;

procedure RunAndWaitShell(Executable, Parameter: STRING; ShowParameter: INTEGER);
var
  Info: TShellExecuteInfo;
  pInfo: PShellExecuteInfo;
  exitCode: DWord;
begin
  sleep(1);
  {Pointer to Info}
  pInfo := @Info;
  {Fill info}
  with Info do
  begin
    cbSize := SizeOf(Info);
    fMask  := SEE_MASK_NOCLOSEPROCESS;
    wnd    := application.Handle;
    lpVerb := NIL;
    lpFile := PChar(Executable);
    {Parametros al ejecutable}
    {Executable parameters}
    lpParameters := PChar(Parameter + #0);
    lpDirectory  := NIL;
    //nShow        := ShowParameter;
    case ShowParameter of
    //0:nShow := SW_FORCEMINIMIZE;
    1:nShow := SW_HIDE;
    2:nShow := SW_MAXIMIZE;
    3:nShow := SW_MINIMIZE;
    4:nShow := SW_RESTORE;
    5:nShow := SW_SHOW;
    6:nShow := SW_SHOWDEFAULT;
    7:nShow := SW_SHOWMAXIMIZED;
    8:nShow := SW_SHOWMINIMIZED;
    9:nShow := SW_SHOWNORMAL;
    end;

    hInstApp     := 0;
  end;
  {Execute}
  ShellExecuteEx(pInfo);

  {Wait to finish}
  repeat
    exitCode := WaitForSingleObject(Info.hProcess, 500);
    Application.ProcessMessages;
  until (exitCode <> WAIT_TIMEOUT);
end;

function LoadPNG(PNGlocation:string):TPNGObject;
var PNG:TPNGObject;
begin
  //PNG:=TPNGObject.create;
  LoadPNG:=TPNGObject.create;
  LoadPNG.LoadFromFile(PNGlocation);
  //LoadIcon:=png;
end;

procedure TForm2.CM_MenuClosed(var msg: TMessage) ;
begin
  form1.Timer1.Enabled:=true;
end;

procedure middle;
begin
  form2.PNGButton1.Left:=trunc(form2.ClientWidth/2-form2.PNGButton1.Width/2);
  form2.QProgressBar1.Left:=trunc(form2.ClientWidth/2-form2.QProgressBar1.Width/2);
  form2.Label1.Left:=trunc(form2.ClientWidth/2-form2.Label1.Width/2);

  form2.PNGButton1.Top:=PNGB1T-F2H+form2.Height;
  form2.QProgressBar1.Top:=ProgT-F2H+form2.Height;
  form2.Label1.Top:=F2L1T-F2H+form2.Height;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  //FormStyle := fsStayOnTop;
  form2.JvHTListBox1.ItemIndex:=-1;
  programmpfad:=ExtractFilePath(Application.ExeName);

  form2.PNGButton1.ImageNormal:=LoadPNG(programmpfad+'Files\conv.png');
  PNGB1T:=form2.PNGButton1.Top;
  ProgT:=form2.QProgressBar1.Top;
  F2H:=form2.Height;
  F2L1T:=form2.Label1.Top;
  middle;

  DragAcceptFiles(form2.JvHTListBox1.Handle, true);
  conversion:=false;
  abort:=false;

  Form2.Constraints.MinHeight:=form2.Height;
  form2.Constraints.MinWidth:=form2.Width;
  form2.Left:=trunc(screen.Width/2-form2.Width/2);
  form2.Top:=trunc(screen.Height/2-form2.Height/2);
end;

procedure TForm2.Delete1Click(Sender: TObject);
var
  ii : integer;
begin
  with form2.JvHTListBox1 do
  begin
    for ii := -1 + Items.Count downto 0 do
    if Selected[ii] then Items.Delete(ii) ;
  end;
  form2.JvHTListBox1.ItemIndex:=-1;
end;

procedure TForm2.JvHTListBox1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = 46) then form2.Delete1Click(nil);
end;

procedure TForm2.FormResize(Sender: TObject);
begin
  middle;
end;

procedure TForm2.FormActivate(Sender: TObject);
begin
  SetWindowPos(form1.Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
end;

procedure TForm2.PopupMenu1Popup(Sender: TObject);
begin
  form1.Timer1.Enabled:=false;
  
  form2.Delete1.Enabled:=true;
  if form2.JvHTListBox1.ItemIndex<=-1 then begin
    form2.Delete1.Enabled:=false;
    exit;
  end;
end;

procedure TThreadConvert.Start;
begin
  form2.PNGButton1.ImageNormal:=LoadPNG(programmpfad+'Files\stop.png');
  form2.PNGButton1.Hint:='Stop!';
  form2.Label1.Visible:=true;
  form2.QProgressBar1.position:=0;
end;

procedure TThreadConvert.Finish;
begin
  form2.QProgressBar1.position:=100;
  form2.QProgressBar1.caption:=inttostr(form2.QProgressBar1.position)+'%';
  ShellExecute(0, 'open', PChar(programmpfad+'Converted Media\'), nil, nil, SW_ShowNormal);
  form2.Label1.Visible:=false;
  form2.PNGButton1.ImageNormal:=LoadPNG(programmpfad+'Files\conv.png');
  form2.PNGButton1.Hint:='Convert!';
  form2.JvHTListBox1.Clear;
  conversion:=false;
  abort:=false;
  form2.JvHTListBox1.Enabled:=true;
end;

procedure TThreadConvert.SetFokus;
begin
  SetWindowPos(form2.Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
end;

procedure TThreadConvert.Refresh;
begin
  form2.QProgressBar1.position:=trunc((lauf/form2.JvHTListBox1.Items.Count)*100);
  form2.QProgressBar1.caption:=inttostr(form2.QProgressBar1.position)+'%';
  form2.JvHTListBox1.ItemIndex:=lauf;
end;

function KillTask(const AExeName: string): boolean;
var
  p: TProcessEntry32;
  h: THandle;
begin
  Result := false;
  p.dwSize := SizeOf(p);
  h := CreateToolHelp32Snapshot(TH32CS_SnapProcess, 0);
  try
    if Process32First(h, p) then
      repeat
        if AnsiLowerCase(p.szExeFile) = AnsiLowerCase(AExeName) then
          Result := TerminateProcess(OpenProcess(Process_Terminate,
                                                 false,
                                                 p.th32ProcessID),
                                     0);
      until (not Process32Next(h, p)) or Result;
  finally
    CloseHandle(h);
  end;
end;

procedure TThreadConvert.ffclose;
begin
  if MessageDlg('Do you really want to cancel the conversion?'+#13#10+'Your Current Progress will be lost.',mtConfirmation,[mbYes,mbNo],0) = IDYES {IDNO} then ffcl:=true;
end;

procedure TThreadConvert.Execute;
var ffcommand,videopfad,mp3pfad,mp3dat:string;
    laufloc,ShowParameter:integer;
    Info: TShellExecuteInfo;
    pInfo: PShellExecuteInfo;
    exitCode: DWord;
    Executable,Parameter:STRING;
begin
  Synchronize(Start);
  sleep(50);
  ffcl:=false;

  for laufloc:=0 to form2.JvHTListBox1.Items.Count-1 do begin
    if abort=true then break;
    lauf:=laufloc;
    Synchronize(Refresh);
    videopfad:=form2.JvHTListBox1.Items[lauf];
    mp3dat:=copy(videopfad,length(ExtractFilePath(videopfad))+1,length(videopfad));
    mp3dat:=copy(mp3dat,0,length(mp3dat)-3)+conv;
    mp3pfad:=programmpfad+'Converted Media\'+mp3dat;
    //ffcommand:=('ffmpeg.exe -i "'+videopfad+'" -ab 128000 "'+mp3pfad+'"');
    ffcommand:=('-y -i "'+videopfad+'"'+' "'+mp3pfad+'"');
    sleep(2);
    //RunAndWaitShell('ffmpeg.exe',ffcommand,0);//
    //RunAndWaitShell(Executable, Parameter: STRING; ShowParameter: INTEGER);//
    {*******************}
    Executable:='ffmpeg.exe';
    Parameter:=ffcommand;
    ShowParameter:=0;

    sleep(1);
    {Pointer to Info}
    pInfo := @Info;
    {Fill info}
    with Info do
    begin
    cbSize := SizeOf(Info);
    fMask  := SEE_MASK_NOCLOSEPROCESS;
    wnd    := application.Handle;
    lpVerb := NIL;
    lpFile := PChar(Executable);
    {Parametros al ejecutable}
    {Executable parameters}
    lpParameters := PChar(Parameter + #0);
    lpDirectory  := NIL;
    //nShow        := ShowParameter;
    case ShowParameter of
    //0:nShow := SW_FORCEMINIMIZE;
    1:nShow := SW_HIDE;
    2:nShow := SW_MAXIMIZE;
    3:nShow := SW_MINIMIZE;
    4:nShow := SW_RESTORE;
    5:nShow := SW_SHOW;
    6:nShow := SW_SHOWDEFAULT;
    7:nShow := SW_SHOWMAXIMIZED;
    8:nShow := SW_SHOWMINIMIZED;
    9:nShow := SW_SHOWNORMAL;
    end;

    hInstApp     := 0;
    end;
    {Execute}
    ShellExecuteEx(pInfo);

    sleep(2);

    Synchronize(SetFokus);

    {Wait to finish}
    repeat
      exitCode := WaitForSingleObject(Info.hProcess, 500);
      Application.ProcessMessages;
    until (exitCode <> WAIT_TIMEOUT) or (abort=true);

    {*******************}

    sleep(2);
  end;

  if (abort=true) then begin
    Synchronize(ffclose);
    if (ffcl=true) then begin
      KillTask('ffmpeg.exe');
    end;
  end;

  Synchronize(Finish);
end;

procedure TForm2.PNGButton1Click(Sender: TObject);
var RThread: TThreadConvert;
    test:string;
begin
  if conversion=true then begin
    abort:=true;
    exit;
  end;
  test:='';
  try
    test:=form2.JvHTListBox1.Items[0];
  except
    showmessage('The Listbox hast to contain atleast one File :)');
    exit;
  end;
  conversion:=true;
  form2.JvHTListBox1.Enabled:=false;
  DeleteFolder(programmpfad+'Converted Media');
  MkDir(programmpfad+'Converted Media');
  RThread:=TThreadConvert.Create(False);
end;

procedure TForm2.Button1Click(Sender: TObject);
begin
  //form2.FocusControl;
end;

end.
