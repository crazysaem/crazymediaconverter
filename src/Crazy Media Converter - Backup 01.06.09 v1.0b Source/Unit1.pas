unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, pngimage, ExtCtrls, JvExExtCtrls, JvImage, Menus, StdCtrls,
  CoolTrayIcon, inifiles;

type
  TForm1 = class(TForm)
    JvImage1: TJvImage;
    PopupMenu1: TPopupMenu;
    Beenden1: TMenuItem;
    Optionen1: TMenuItem;
    MP31: TMenuItem;
    AVI1: TMenuItem;
    CoolTrayIcon1: TCoolTrayIcon;
    Minimize1: TMenuItem;
    PopupMenu2: TPopupMenu;
    Maximize1: TMenuItem;
    Exit1: TMenuItem;
    Timer1: TTimer;
    Minimize2: TMenuItem;
    OwnSettings1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure JvImage1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure JvImage1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure JvImage1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Beenden1Click(Sender: TObject);
    procedure MP31Click(Sender: TObject);
    procedure AVI1Click(Sender: TObject);
    procedure Minimize1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Maximize1Click(Sender: TObject);
    procedure Minimize2Click(Sender: TObject);
    procedure CoolTrayIcon1Click(Sender: TObject);
    procedure JvImage1DblClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure OwnSettings1Click(Sender: TObject);
  protected
    procedure WMDROPFILES(var Msg: TMessage); message WM_DROPFILES;
  private
    { Private declarations }
  public

  end;

const   DF_NUMBEROFFILES = $FFFFFFFF;

var
  Form1: TForm1;
  mdown:boolean;
  x1,y1:integer;
  conv:string;
  DTBTestf:TextFile;

implementation

{$R *.dfm}
uses ShellAPI, Unit2;

procedure TForm1.WMDROPFILES(var Msg: TMessage);
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
                    '"'+programmpfad+'Converted Media'+'"-Folder.');
        form2.JvHTListBox1.Clear;
        exit;
      end;
    StrDispose(Dateiname);
  end;
  DragFinish(Msg.WParam);
  //form2.Visible:=true;
  form1.JvImage1DblClick(nil);
  form2.JvHTListBox1.ItemIndex:=-1;
end;

function DTBTest:boolean;
var datei:string;
begin
    datei:=ExtractFilePath(Application.Exename)+'test.DAT';
    try
      AssignFile(DTBTestf, datei);
      //if Fileexists(datei) then Append(DTBTestf) else ReWrite(DTBTestf);
      ReWrite(DTBTestf);
      Writeln(DTBTestf, 'test');
      Flush(DTBTestf);
    except
      //form1.Close;
      //showmessage('You already started this Program');
      DTBTest:=true;
      Application.Terminate;
      exit;
      //halt(1);
    end;
    DTBTest:=false;
end;

procedure TForm1.FormCreate(Sender: TObject);
var ini: TIniFile;
begin
  if DTBTest=true then begin
    showmessage('You already started this Program');
    exit;
  end;

  SetWindowLong(Application.Handle, GWL_EXSTYLE,GetWindowLong(Application.Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW and not WS_EX_APPWINDOW);
  SetWindowPos(form1.Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);

  //ShowWindow( Application.Handle,SW_HIDE);
  conv:='mp3';
  DragAcceptFiles(Form1.Handle, true);

  mdown:=false;
  //form1.JvImage1.Picture.LoadFromFile(ExtractFilePath(Application.Exename)+'Files\mixer.png');
  form1.JvImage1.Picture.LoadFromFile(ExtractFilePath(Application.Exename)+'Files\files60.png');
  form1.JvImage1.AutoSize:=true;
  form1.ClientWidth:=form1.JvImage1.Width;
  form1.clientheight:=form1.JvImage1.height;

  x1:=0;
  y1:=0;

  ini:=TIniFile.create(ExtractFilePath(ParamStr(0))+'settings.ini');
    conv:=ini.ReadString('CMsettings','Convert_To','mp3');
    form1.Left:=ini.Readinteger('CMsettings','FXL',trunc(screen.Width/2-form1.Width/2));
    form1.top:=ini.ReadInteger('CMsettings','FXT',trunc(screen.WorkAreaHeight/2-form1.Height/2));
  ini.free;

  if conv='mp3' then begin
    Form1.MP31.Checked:=true;
    Form1.AVI1.Checked:=false;
    form1.OwnSettings1.Checked:=false;
  end;

  if conv='avi' then begin
    Form1.MP31.Checked:=false;
    Form1.AVI1.Checked:=true;
    form1.OwnSettings1.Checked:=false;
  end;

  if (conv<>'avi') and (conv<>'mp3') then begin
    Form1.MP31.Checked:=false;
    Form1.AVI1.Checked:=false;
    form1.OwnSettings1.Checked:=true;
  end;

  if (Form1.Left=-1) and (Form1.top=-1) then begin
    Form1.Left:=trunc(screen.Width/2-form1.Width/2);
    form1.Top:=trunc(screen.WorkAreaHeight/2-form1.Height/2);
  end;

end;

procedure MoveForm(x,y:integer);
var pt: tpoint;
    newx,newy:integer;
begin
  GetCursorPos(pt);
  newx:=pt.x-x;
  newy:=pt.y-y;

  if newx<=0 then newx:=0;
  if (newx+form1.Width)>=screen.width then newx:=screen.width-form1.Width;

  if newy<=0 then newy:=0;
  if ((newy+form1.height)>=screen.height) then newy:=screen.height-form1.height;

    form1.Left:=newx;
    form1.Top:=newy;
end;

procedure TForm1.JvImage1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button=mbleft then mdown:=true;
  x1:=x;
  y1:=y;
end;

procedure TForm1.JvImage1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button=mbleft then mdown:=false;
  //if Button=mbright then form1.Timer1.Enabled:=true;
end;

procedure TForm1.JvImage1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
    if (mdown=true) then MoveForm(x1,y1);
end;

procedure TForm1.Beenden1Click(Sender: TObject);
begin
  form1.Close;
end;

procedure TForm1.MP31Click(Sender: TObject);
begin
  Form1.MP31.Checked:=true;
  Form1.AVI1.Checked:=false;
  form1.OwnSettings1.Checked:=false;

  conv:='mp3';
end;

procedure TForm1.AVI1Click(Sender: TObject);
begin
  Form1.MP31.Checked:=false;
  Form1.AVI1.Checked:=true;
  form1.OwnSettings1.Checked:=false;

  conv:='avi';
end;

procedure TForm1.Minimize1Click(Sender: TObject);
begin
  Application.Minimize;
end;

procedure TForm1.Exit1Click(Sender: TObject);
begin
  form1.Close;
end;

procedure TForm1.Maximize1Click(Sender: TObject);
begin
  application.Restore;
end;

procedure TForm1.Minimize2Click(Sender: TObject);
begin
  Application.Minimize;
end;

procedure TForm1.CoolTrayIcon1Click(Sender: TObject);
begin
  application.Restore;
end;

procedure TForm1.JvImage1DblClick(Sender: TObject);
begin
  form2.Close;
  form2.Visible:=true;
  ShowWindow(form2.Handle, SW_RESTORE);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if GetForeGroundWindow <> form1.Handle then SetWindowPos(form1.Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var ini: TIniFile;
begin
  ini:=TIniFile.create(ExtractFilePath(ParamStr(0))+'settings.ini');
    ini.WriteString('CMsettings','Convert_To',conv);
    ini.WriteInteger('CMsettings','FXL',form1.Left);
    ini.WriteInteger('CMsettings','FXT',form1.top);
  ini.free;
end;

procedure TForm1.OwnSettings1Click(Sender: TObject);
var  Rueckgabe: String;
begin
  Form1.MP31.Checked:=false;
  Form1.AVI1.Checked:=false;
  form1.OwnSettings1.Checked:=true;

  Rueckgabe := InputBox('Own Settings', 'Please insert your desired media-format:'+#13#10+'(e.g. "mp3", "wma", "aac" )', conv);
  //ShowMessage(Rueckgabe);
  conv:=Rueckgabe;

  if conv='mp3' then begin
    Form1.MP31.Checked:=true;
    Form1.AVI1.Checked:=false;
    form1.OwnSettings1.Checked:=false;
  end;

  if conv='avi' then begin
    Form1.MP31.Checked:=false;
    Form1.AVI1.Checked:=true;
    form1.OwnSettings1.Checked:=false;
  end;

  if (conv<>'avi') and (conv<>'mp3') then begin
    Form1.MP31.Checked:=false;
    Form1.AVI1.Checked:=false;
    form1.OwnSettings1.Checked:=true;
  end;
  
end;

end.
