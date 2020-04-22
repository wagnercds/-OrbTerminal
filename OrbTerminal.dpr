program OrbTerminal;

uses
  Forms,
  UTerm in 'UTerm.pas' {forTerm},
  UMens in 'UMens.pas' {forMens},
  UEnvFunc in 'UEnvFunc.pas' {forEnvFunc},
  UDisp in '..\..\LibOrb\UDisp.pas',
  LibString in '..\..\LibOrb\LibString.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'OrbTerminal';
  Application.CreateForm(TforTerm, forTerm);
  Application.Run;
end.
