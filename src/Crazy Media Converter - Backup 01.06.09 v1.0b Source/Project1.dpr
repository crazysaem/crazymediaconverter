program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  Unit2 in 'Unit2.pas' {Form2},
  PopupListEx in 'Files\PopupListEx.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'CM Converter';
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
