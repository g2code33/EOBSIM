unit NewExperimentUnit;
// ---------------------
// EOSIM - Select new experiment
// ---------------------

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls;

type
  TNewExperimentFrm = class(TForm)
    cbTissue: TComboBox;
    bOK: TButton;
    bCancel: TButton;
    procedure bOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  NewExperimentFrm: TNewExperimentFrm;

implementation

uses EOBSIMMain;

{$R *.dfm}


procedure TNewExperimentFrm.bOKClick(Sender: TObject);
// ------------------------
// New tissue type selected
// ------------------------
begin
     // Select type of tissue
     MainFrm.TissueType := NativeInt(cbTissue.Items.Objects[cbTissue.ItemIndex]) ;
     end;

procedure TNewExperimentFrm.FormShow(Sender: TObject);
// ------------------------------------------
// Initialise controls when form is displayed
// ------------------------------------------
begin
     // Available experimental tissues
     cbTissue.Clear ;
     cbTissue.Items.AddObject('Guinea Pig Ileum',TObject(NativeInt(tGPIleum))) ;
     cbTissue.Items.AddObject('Chick Biventer',TObject(NativeInt(tChickBiventer))) ;
     cbTissue.Items.AddObject('Rabbit Arterial Ring',TObject(NativeInt(tArterialRing))) ;
     cbTissue.Items.AddObject('Rabbit Jejunum',TObject(NativeInt(tJejunum))) ;
     cbTissue.ItemIndex := cbTissue.Items.IndexOfObject(TObject(NativeInt(MainFrm.TissueType))) ;

     end;

end.
