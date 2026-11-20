program EOBSIM;

uses
  Vcl.Forms,
  EOBSIMMain in 'EOBSIMMain.pas' {MainFrm},
  PrintUnit in 'PrintUnit.pas' {PrintFrm},
  Shared in 'Shared.pas',
  NewExperimentUnit in 'NewExperimentUnit.pas' {NewExperimentFrm};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'EOSIM - Electronic Organ Bath Simulation';
  Application.HelpFile := 'EOSIM-help.html';
  Application.CreateForm(TMainFrm, MainFrm);
  Application.CreateForm(TPrintFrm, PrintFrm);
  Application.CreateForm(TNewExperimentFrm, NewExperimentFrm);
  Application.Run;
end.
