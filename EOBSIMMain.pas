unit EOBSIMMain;

// Original simulation code: Copyright (c) J. Dempster, University of Strathclyde 2005.
// See THIRD_PARTY_NOTICES.md for provenance and licensing status.
// -----------------------------------------------
// EOSIM - Electronic Organ Bath Simulation
// EOBSIM V1.0 - 20.11.2026
// -----------------------------------------------
// V1.0  20.11.2026  EOSIM/EOBSIM initial release.
//                   Rebranded to EOSIM - Electronic Organ Bath Simulation.
//                   Modernised for Embarcadero Delphi 11 Alexandria /
//                   12 Athens (Win32 + Win64 candidates). Data files use .EOB
//                   extension. Help file is EOSIM-help.html.
//                   Requires SESComponents package (see README.md).
//                   Tissues: Guinea Pig Ileum, Chick Biventer,
//                   Rabbit Arterial Ring, Rabbit Jejunum.
//                   Simulation logic unchanged from organ bath
//                   pharmacology model (receptor EC50, nerve/muscle
//                   stimulation, reservoir/bath dilution, charting).

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, ScopeDisplay, ValidatedEdit, System.Math, Vcl.Menus,
  Vcl.ExtCtrls, HTMLLabel, System.StrUtils, Shared, Vcl.ComCtrls,
  Winapi.ShellAPI, System.UITypes, Vcl.Imaging.Jpeg, Vcl.Printers;

const
    MaxPoints = 10000000 ;
    MaxDisplayPoints = 2000 ;
    MaxDrugs = 100 ;
    MaxMarkers = 500 ;
    NumBytesPerMarker = 40 ;
    FileHeaderSize = (MaxMarkers+10)*NumBytesPerMarker ;
    DataFileExtension = '.EOB' ;

    StimulusInterval = 2.0 ;
    MaxSyringeVolume = 1.0 ;

    // Drug available for applying to tissue flags
    tGPIleum = 1 ;
    tChickBiventer = 2 ;
    tArterialRing = 4 ;
    tJejunum = 8 ;

    NormalSoln = 1 ;    // Normal K-H solution
    ZeroCaSoln = 2 ;    // Zero Ca K-H solution

    // Dilution formula result options
    DilVAdd = 0 ;
    DilFBC = 1 ;
    DilStockC = 2 ;
    DilVBath = 3 ;

type


  TDrug = record
          Name : String ;
          ShortName : String ;
          FinalBathConcentration : single ;
          DisplayBathConcentration : single ;
          BathConcentration : single ;
          Conc : single ;
          EC50_HistR : single ;          // Histamine H1
          EC50_HistR_NC : single ;       //
          EC50_nAchR : single ;          // Nicotonic
          EC50_AchEsterase : single ;      // Cholinesterase inhibition
          EC50_mAchR : single ;
          EC50_mAchR_NC : single ;
          EC50_OpR : Single ;
          EC50_Alpha_AdrenR : Single ;
          EC50_Alpha2_AdrenR : Single ;
          EC50_Beta_AdrenR : Single ;
          EC50_PLC_Inhibition : Single ;
          EC50_IP3R : Single ;
          EC50_CaI : Single ;
          EC50_CaChannelV : Single ;
          EC50_CaChannelR : Single ;
          EC50_CaStore : Single ;
          EC50_BTXB : Single ;
          EC50_BTXE : Single ;

          Antagonist : Boolean ;
          Unknown : Boolean ;
          Tissue : Integer ;
          Units : String ;
          end ;

  TMainFrm = class(TForm)
    ControlsGrp: TGroupBox;
    TissueGrp: TGroupBox;
    GroupBox4: TGroupBox;
    bNewExperiment: TButton;
    GroupBox6: TGroupBox;
    bStimulationOn: TButton;
    bStimulationOff: TButton;
    StimulationTypeGrp: TGroupBox;
    rbMuscle: TRadioButton;
    rbNerve: TRadioButton;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    mnLoadExperiment: TMenuItem;
    mnSaveExperiment: TMenuItem;
    N1: TMenuItem;
    mnExit: TMenuItem;
    Timer: TTimer;
    mnEdit: TMenuItem;
    mnCopyData: TMenuItem;
    mnCopyImage: TMenuItem;
    N2: TMenuItem;
    mnPrint: TMenuItem;
    PrinterSetupDialog: TPrinterSetupDialog;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    bFreshReservoir: TButton;
    bFlushReservoirToBath: TButton;
    DisplayGrp: TGroupBox;
    DisplayPage: TPageControl;
    ChartPage: TTabSheet;
    ExperimentPage: TTabSheet;
    bRecord: TButton;
    bStop: TButton;
    GPIleumSetup: TImage;
    ChickBiventerSetup: TImage;
    mnHelp: TMenuItem;
    mnContents: TMenuItem;
    Label5: TLabel;
    cbSolution: TComboBox;
    ArterialRingSetup: TImage;
    JejunumStimGrp: TGroupBox;
    edStimFrequency: TValidatedEdit;
    edTissueType: TEdit;
    JejunumSetup: TImage;
    scDisplay: TScopeDisplay;
    PageControl1: TPageControl;
    AgonistsTab: TTabSheet;
    AntagonistsTab: TTabSheet;
    UnknownsTab: TTabSheet;
    cbAgonist: TComboBox;
    cbAgonistStockConc: TComboBox;
    edAgonistVolume: TValidatedEdit;
    bAddAgonist: TButton;
    Label1: TLabel;
    Label2: TLabel;
    cbAntagonist: TComboBox;
    Label3: TLabel;
    cbAntagonistStockConc: TComboBox;
    Label4: TLabel;
    edAntagonistVolume: TValidatedEdit;
    bAddAntagonist: TButton;
    cbAddAntagonistTo: TComboBox;
    cbUnknown: TComboBox;
    Label6: TLabel;
    cbUnknownStockConc: TComboBox;
    Label7: TLabel;
    edUnknownVolume: TValidatedEdit;
    bAddUnknown: TButton;
    cbAddUnknownTo: TComboBox;
    DilutionTab: TTabSheet;
    GroupBox1: TGroupBox;
    cbDilutionResult: TComboBox;
    edDilResult: TEdit;
    edDilNum1: TValidatedEdit;
    edDilNum2: TValidatedEdit;
    Shape1: TShape;
    edDilDen: TValidatedEdit;
    lbDilForm: TLabel;
    lbDilutionEqnNum2: TLabel;
    lbDilutionEqnDen: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    bCalculate: TButton;
    LbDilutionEqnNum1: TLabel;
    Label11: TLabel;
    TDisplayPanel: TPanel;
    lbTDisplay: TLabel;
    lbStartTime: TLabel;
    edTDisplay: TValidatedEdit;
    bTDisplayDouble: TButton;
    bTDisplayHalf: TButton;
    edStartTime: TValidatedEdit;
    sbDisplay: TScrollBar;
    mnNewExperiment: TMenuItem;
    Image2: TImage;
    procedure FormShow(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure bRecordClick(Sender: TObject);
    procedure bStopClick(Sender: TObject);
    procedure bAddAgonistClick(Sender: TObject);
    procedure bFlushReservoirToBathClick(Sender: TObject);
    procedure FormResize(Sender: TObject);

    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure mnExitClick(Sender: TObject);
    procedure bAddAntagonistClick(Sender: TObject);
    procedure mnCopyDataClick(Sender: TObject);
    procedure mnPrintClick(Sender: TObject);
    procedure mnCopyImageClick(Sender: TObject);
    procedure mnLoadExperimentClick(Sender: TObject);
    procedure bStimulationOnClick(Sender: TObject);
    procedure bStimulationOffClick(Sender: TObject);
    procedure bNewExperimentClick(Sender: TObject);
    procedure bFreshReservoirClick(Sender: TObject);
    procedure mnSaveExperimentClick(Sender: TObject);
    procedure mnContentsClick(Sender: TObject);
    procedure mnSearchClick(Sender: TObject);
    procedure cbAgonistChange(Sender: TObject);
    procedure cbAntagonistChange(Sender: TObject);
    procedure edStimFrequencyKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure bAddUnknownClick(Sender: TObject);
    procedure rbMuscleClick(Sender: TObject);
    procedure Label5Click(Sender: TObject);
    procedure rbNerveClick(Sender: TObject);
    procedure cbDilutionResultChange(Sender: TObject);
    procedure bCalculateClick(Sender: TObject);
    procedure edTDisplayKeyPress(Sender: TObject; var Key: Char);
    procedure bTDisplayDoubleClick(Sender: TObject);
    procedure bTDisplayHalfClick(Sender: TObject);
    procedure edStartTimeKeyPress(Sender: TObject; var Key: Char);
    procedure mnNewExperimentClick(Sender: TObject);
    procedure cbUnknownChange(Sender: TObject);
    procedure scDisplayCursorChange(Sender: TObject);
  private
    { Private declarations }
    ADC : Array[0..MaxPoints-1] of SmallInt ;
    NumPointsInBuf : Integer ;   // No. of data points in buffer
    StartPoint : Integer ;
    NumPointsDisplayed : Integer ;

    // Nerve stimulus
    StimulusStartedAt : Integer ;
    NextStimulusAt : Integer ;
    mAch_EC50 : Single ;           // Muscarinic Ach receptor EC50
    nAch_EC50 : Single ;           // Nicotinic Ach receptor EC50
    MaxReleasedAch : Single ;
    BTXBFreeFraction : single ;     // Fraction of botulinum toxin free release sites
    BTXEFreeFraction : single ;     // Fraction of botulinum toxin free release sites

    Drugs : Array[0..MaxDrugs-1] of TDrug ;    // Drug properties array
    ReservoirDrugs : Array[0..MaxDrugs-1] of TDrug ;    // Drug properties array
    NumDrugs : Integer ;                     // No. of drugs available
    iCaBath : Integer ;                      // Index of bath Ca concentration

    // Jejunum simulation
    NerveReleasedNorAdrenaline : Single ;     // Noradrenaline released by mesenteric nerve
    StimFrequency : Single ;
    idxNoradrenaline : Integer ;

    Desensitisation : Single ;

    MarkerList : TStringList ;   // Chart annotation list

    RMax : Single ;      // Maximal response in current use
    NextRMax : Single ;  // RMax after next agonist application
    Force : Single ;     // Contractile force of preparation

    UnsavedData : Boolean ;  // Un-saved data flag

    procedure NewExperiment ;
    function DoGPIleumSimulationStep(
             CyclicNerveReleasedAch : single
             ) : single;
    function DoChickBiventerSimulationStep : Single ;
    function DoArterialRingSimulationStep : Single ;
    function DoJejunumSimulationStep : Single ;

    procedure UpdateDisplay( NewPoint : Single ) ;
    procedure AddChartAnnotations ;
    procedure AddDrugMarker( ChartAnnotation : String ) ;
    procedure LoadFromFile( FileName : String ) ;
    procedure SaveToFile( FileName : String ) ;
    procedure SetStockConcentrationList(
              iDrug : Integer ;
              ComboBox : TComboBox ) ;

    procedure SetDilutionEquation ;
    procedure UpdateDisplayDuration ;
  public
    { Public declarations }
    TissueType : Integer ;       // Type of tissue in use
    InitialMixing : Cardinal ;
  end;

var
  MainFrm: TMainFrm;

implementation

uses PrintUnit, NewExperimentUnit;

{$R *.dfm}


const
    MaxADCValue = 2047 ;
    MinADCValue = -2048 ;
    NoiseStDev = 10 ;
    MaxDisplayForce = 20.0 ;
    BackgroundNoiseStDev = 0.1 ;  // Background noise (gms)
    ForceStDev = 0.05 ;
    MaxMixingRate = 0.5 ;
    MeanRMax = 15.0 ;
    RMaxStDev = 0.05 ;
    BathVolume = 10.0 ;          // Organ bath volume (ml)
    ReservoirVolume = 1000.0 ;   // Krebs solution reservoir volume (ml)
    dt = 0.05 ;


// Preserve the original 32-bit IEEE-754 value without treating it as a
// 32-bit pointer; TObject slots are pointer-sized on both target platforms.
function EncodeConcentration(const Value: Single): TObject;
var Bits: Cardinal;
begin
  Move(Value, Bits, SizeOf(Bits));
  Result := TObject(NativeUInt(Bits));
end;

function DecodeConcentration(Value: TObject): Single;
var Bits: Cardinal;
begin
  Bits := Cardinal(NativeUInt(Value));
  Move(Bits, Result, SizeOf(Bits));
end;


procedure TMainFrm.FormShow(Sender: TObject);
// ------------------------------------------------
// Initialise controls when form is first displayed
// ------------------------------------------------
var
    FileName : String ;
    i : Integer ;
begin

     Application.HelpFile := ExtractFilePath(ParamStr(0)) + 'EOSIM-help.html';

     // Create annotation list
     MarkerList := TStringList.Create ;

     { Setuo chart display }
     scDisplay.MaxADCValue :=  MaxADCValue ;
     scDisplay.MinADCValue := MinADCValue ;
     scDisplay.DisplayGrid := True ;

     scDisplay.MaxPoints := MaxDisplayPoints ;
     scDisplay.NumPoints := 0 ;
     scDisplay.NumChannels := 1 ;

     { Set channel information }
     scDisplay.ChanOffsets[0] := 0 ;
     scDisplay.ChanUnits[0] := 'gms' ;
     scDisplay.ChanName[0] := 'F' ;
     scDisplay.ChanScale[0] := MaxDisplayForce / MaxADCValue ;
     scDisplay.yMin[0] := MinADCValue div 10 ;
     scDisplay.yMax[0] := MaxADCValue ;
     scDisplay.ChanVisible[0] := True ;

     scDisplay.xMin := 0 ;
     scDisplay.xMax := scDisplay.MaxPoints-1 ;
     scDisplay.xOffset := 0 ;
     scDisplay.TScale := 1/20.0 ;
     edTDisplay.LoLimit := 1.0/scDisplay.TScale ;
     edTDisplay.HiLimit := 1E5 ;
     edTDisplay.Scale := scDisplay.TScale ;
     edStartTime.Scale := scDisplay.TScale ;
     edTDisplay.Value := scDisplay.MaxPoints ;

     { Create a set of zero level cursors }
     scDisplay.ClearHorizontalCursors ;
     scDisplay.AddHorizontalCursor( 0, clRed, True, '' ) ;
     scDisplay.HorizontalCursors[0] := 0 ;

     // Vertical readout cursor
     scDisplay.ClearVerticalCursors ;
     scDisplay.AddVerticalCursor(-1,clGreen, '?y') ;
     scDisplay.VerticalCursors[0] := scDisplay.MaxPoints div 2 ;

     // Dilution calculator

     cbDilutionResult.Clear ;
     cbDilutionResult.Items.Add('Volume to Add');
     cbDilutionResult.Items.Add('Final Bath Conc.');
     cbDilutionResult.Items.Add('Stock Solution Conc.');
     cbDilutionResult.Items.Add('Bath Volume');

     cbDilutionResult.ItemIndex := 0 ;
     SetDilutionEquation ;

     // Start new experiment
     TissueType := tGPIleum ;
     NewExperiment ;

     // Load file named in parameter string

     FileName :=  '' ;
     for i := 1 to ParamCount do begin
         if i > 1 then FileName := FileName + ' ' ;
         FileName := FileName + ParamStr(i) ;
         end ;

     if SameText(ExtractFileExt(FileName), DataFileExtension) then begin
        if FileExists(FileName) then LoadFromFile( FileName ) ;
        end ;

     Timer.Enabled := True ;
     InitialMixing := 0 ;

     end;


procedure TMainFrm.NewExperiment ;
// ------------------------------------
// Start new experiment with new tissue
// ------------------------------------
var
    i : Integer ;
begin

     // Configure experiment options
     Case TissueType of
        tGPIleum : begin
           edTissueType.Text := 'Guinea Pig Ileum ' ;
           rbNerve.Caption := 'Nerve (10V, 1ms)' ;
           rbNerve.Checked := True ;
           rbNerve.Enabled := True ;
           JejunumStimGrp.Visible := False ;
           StimulationTypeGrp.Visible := True ;
           rbMuscle.Caption := 'Muscle (20V, 10ms)' ;
           rbMuscle.Checked := False ;
           rbMuscle.Enabled := True ;
           GPIleumSetup.Visible := True ;
           ChickBiventerSetup.Visible := False ;
           ArterialRingSetup.Visible := False ;
           JejunumSetup.Visible := False ;
           ExperimentPage.Caption := ' Experimental Setup (Guinea Pig Ileum) ' ;
           end ;
        tChickBiventer : begin
           edTissueType.Text := 'Chick Biventer' ;
           rbNerve.Caption := 'Nerve' ;
           rbNerve.Checked := True ;
           rbNerve.Enabled := True ;
           rbMuscle.Caption := 'Muscle' ;
           rbMuscle.Enabled := True ;
           JejunumStimGrp.Visible := False ;
           StimulationTypeGrp.Visible := True ;
           GPIleumSetup.Visible := False ;
           ChickBiventerSetup.Visible := True ;
           ArterialRingSetup.Visible := False ;
           JejunumSetup.Visible := False ;
           ExperimentPage.Caption := ' Experimental Setup (Chick Biventer Cervicis) ' ;
           end ;
        tArterialRing : begin
           edTissueType.Text := 'Rabbit Arterial Ring' ;
           rbNerve.Checked := False ;
           rbNerve.Enabled := False ;
           rbMuscle.Enabled := False ;
           JejunumStimGrp.Visible := False ;
           StimulationTypeGrp.Visible := True ;
           GPIleumSetup.Visible := False ;
           ChickBiventerSetup.Visible := False ;
           ArterialRingSetup.Visible := True ;
           JejunumSetup.Visible := False ;
           ExperimentPage.Caption := ' Experimental Setup (Rabbit Arterial Ring) ' ;
           end ;
        tJejunum : begin
           edTissueType.Text := 'Rabbit Jejunum' ;
           JejunumStimGrp.Visible := True ;
           StimulationTypeGrp.Visible := False ;
           GPIleumSetup.Visible := False ;
           ChickBiventerSetup.Visible := False ;
           ArterialRingSetup.Visible := False ;
           JejunumSetup.Visible := True ;
           ExperimentPage.Caption := ' Experimental Setup (Rabbit Jejunum) ' ;
           end ;
        end ;

     // Solutions list
     cbSolution.Clear ;
     cbSolution.Items.AddObject( 'Krebs-Henseleit (normal)', TObject(NativeInt(NormalSoln))) ;
     if TissueType = tArterialRing then begin
        cbSolution.Items.AddObject( 'Krebs-Henseleit (0 Ca)', TObject(NativeInt(ZeroCaSoln))) ;
        end ;
     cbSolution.ItemIndex := 0 ;

     // Create list of drugs
     // --------------------

     // Initialise drug EC50 list to no effect
     for i := 0 to High(Drugs) do begin
          Drugs[i].EC50_HistR := 1E30 ;
          Drugs[i].EC50_HistR_NC := 1E30 ;
          Drugs[i].EC50_nAchR := 1E30 ;
          Drugs[i].EC50_AchEsterase := 1E30 ;
          Drugs[i].EC50_mAchR := 1E30 ;
          Drugs[i].EC50_mAchR_NC := 1E30 ;
          Drugs[i].EC50_OpR := 1E30 ;
          Drugs[i].EC50_Alpha_AdrenR := 1E30 ;
          Drugs[i].EC50_Alpha2_AdrenR := 1E30 ;
          Drugs[i].EC50_Beta_AdrenR := 1E30 ;
          Drugs[i].EC50_PLC_Inhibition := 1E30 ;
          Drugs[i].EC50_IP3R := 1E30 ;
          //Drugs[i].EC50_CaI := 1E30 ;
          Drugs[i].EC50_CaChannelV := 1E30 ;
          Drugs[i].EC50_CaChannelR := 1E30 ;
          Drugs[i].EC50_CaStore := 1E30 ;
          Drugs[i].EC50_BTXB := 1E30 ;
          Drugs[i].EC50_BTXE := 1E30 ;
          Drugs[i].Tissue := 0 ;
          Drugs[i].Units := 'M' ;
          Drugs[i].Unknown := False ;
          Drugs[i].FinalBathConcentration := 0.0 ;
          Drugs[i].DisplayBathConcentration := 0.0 ;
          Drugs[i].BathConcentration := 0.0 ;
          end ;

     NumDrugs := 0 ;

     Drugs[NumDrugs].Name := 'Histamine' ;
     Drugs[NumDrugs].ShortName := 'His' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_HistR := 2E-7*RandG(1.0,0.05) ;
     //Drugs[NumDrugs].EC50_mAchR := 1E-3*RandG(1.0,0.05) ; Removed V2.1
     Drugs[NumDrugs].Antagonist := false ;
     Drugs[NumDrugs].Tissue := tGPIleum ;
     Inc(NumDrugs) ;

     Drugs[NumDrugs].Name := 'Mepyramine' ;
     Drugs[NumDrugs].ShortName := 'Mep' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_HistR := 2E-10*RandG(1.0,0.05) ;
     Drugs[NumDrugs].EC50_mAchR := 1.5E-5*RandG(1.0,0.05) ;
     Drugs[NumDrugs].Antagonist := True ;
     Drugs[NumDrugs].Tissue := tGPIleum ;
     Inc(NumDrugs) ;

     Drugs[NumDrugs].Name := 'Carbachol' ;
     Drugs[NumDrugs].ShortName := 'Cch' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_nAchR := 2.7E-6*RandG(1.0,0.05) ;
     Drugs[NumDrugs].EC50_mAchR := 5E-8*RandG(1.0,0.05) ;
     Drugs[NumDrugs].Tissue := tGPIleum + tChickBiventer + tJejunum ;
     Drugs[NumDrugs].Antagonist := False ;
     Inc(NumDrugs) ;

     Drugs[NumDrugs].Name := 'Atropine' ;
     Drugs[NumDrugs].ShortName := 'Atr' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_HistR := 2E-6*RandG(1.0,0.05) ;
     Drugs[NumDrugs].EC50_mAchR := 1E-9*RandG(1.0,0.05) ;
     Drugs[NumDrugs].Antagonist := True ;
     Drugs[NumDrugs].Tissue := tGPIleum + tChickBiventer + tJejunum ;
     Inc(NumDrugs) ;

     Drugs[NumDrugs].Name := 'Tubocurarine' ;
     Drugs[NumDrugs].ShortName := 'Tub' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_nAchR := 1E-6*RandG(1.0,0.05) ;
     Drugs[NumDrugs].Antagonist := True ;
     Drugs[NumDrugs].Tissue := tGPIleum + tChickBiventer ;
     Inc(NumDrugs) ;

     Drugs[NumDrugs].Name := 'Morphine' ;
     Drugs[NumDrugs].ShortName := 'Mor' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_OpR := 4.0E-8*RandG(1.0,0.05) ; {21/8/18 3.5E-8->4.0E-8}
     Drugs[NumDrugs].Antagonist := False ;
     Drugs[NumDrugs].Tissue := tGPIleum ;
     Inc(NumDrugs) ;

     Drugs[NumDrugs].Name := 'Loperamide' ;
     Drugs[NumDrugs].ShortName := 'Lop' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_OpR := 1E-7*RandG(1.0,0.05) ; ;
     Drugs[NumDrugs].Antagonist := False ;
     Drugs[NumDrugs].Tissue := tGPIleum ;
     Inc(NumDrugs) ;

     Drugs[NumDrugs].Name := 'Naloxone' ;
     Drugs[NumDrugs].ShortName := 'Nal' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_OpR := 1.5E-6*RandG(1.0,0.05) ;
     Drugs[NumDrugs].Antagonist := True ;
     Drugs[NumDrugs].Tissue := tGPIleum  ;
     Inc(NumDrugs) ;

     Drugs[NumDrugs].Name := 'KCL' ;
     Drugs[NumDrugs].ShortName := 'KCL' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_CaChannelV := 4E-2 ;
     Drugs[NumDrugs].Antagonist := False ;
     Drugs[NumDrugs].Tissue := tArterialRing ;
     Inc(NumDrugs) ;

     idxNoradrenaline := NumDrugs ;
     Drugs[NumDrugs].Name := 'Noradrenaline/Norepinephrine' ; // Alpha + beta adrenoceptor agonist
     Drugs[NumDrugs].ShortName := 'Nor' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_Alpha_AdrenR := 5E-6*RandG(1.0,0.05) ;
     Drugs[NumDrugs].EC50_Alpha2_AdrenR := 5E-6*RandG(1.0,0.05) ;
     Drugs[NumDrugs].EC50_Beta_AdrenR := 1E-5*RandG(1.0,0.05) ;
     Drugs[NumDrugs].Antagonist := False ;
     Drugs[NumDrugs].Tissue := tArterialRing + tJejunum ;
     Inc(NumDrugs) ;

     Drugs[NumDrugs].Name := 'Phenylephrine' ; // alpha-adrenoceptor agonist (jejunum)
     Drugs[NumDrugs].ShortName := 'Phe' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_Alpha_AdrenR := 2E-6*RandG(1.0,0.05) ;
     Drugs[NumDrugs].Antagonist := False ;
     Drugs[NumDrugs].Tissue := tGPIleum + tJejunum ;
     Inc(NumDrugs) ;

     Drugs[NumDrugs].Name := 'U73122' ;
     Drugs[NumDrugs].ShortName := 'U73' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_PLC_Inhibition := 1E-8 ;
     Drugs[NumDrugs].Antagonist := True ;
     Drugs[NumDrugs].Tissue := tArterialRing ;
     Inc(NumDrugs) ;

     Drugs[NumDrugs].Name := 'Heparin' ;
     Drugs[NumDrugs].ShortName := 'Hep' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_IP3R := 0.01 ;
     Drugs[NumDrugs].Antagonist := True ;
     Drugs[NumDrugs].Tissue := tArterialRing ;
     Drugs[NumDrugs].Units := 'mg/ml' ;
     Inc(NumDrugs) ;

     Drugs[NumDrugs].Name := 'Ca' ;
     Drugs[NumDrugs].ShortName := 'Ca' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].Antagonist := False ;
     Drugs[NumDrugs].Tissue := 0 ;
     iCaBath := NumDrugs ;
     Inc(NumDrugs) ;

     Drugs[NumDrugs].Name := 'Prazosin' ; // Alpha-adrenoceptor antagonist
     Drugs[NumDrugs].ShortName := 'Pra' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_Alpha_AdrenR := 3E-8*RandG(1.0,0.05) ;
     Drugs[NumDrugs].Antagonist := True ;
     Drugs[NumDrugs].Tissue := tJejunum + tArterialRing ;
     Inc(NumDrugs) ;

     Drugs[NumDrugs].Name := 'Propranolol' ; // Beta-adrenoceptor antagonist (jejunum)
     Drugs[NumDrugs].ShortName := 'Pro' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_Beta_AdrenR := 1E-7*RandG(1.0,0.05) ;
     Drugs[NumDrugs].Antagonist := True ;
     Drugs[NumDrugs].Tissue := tJejunum + tArterialRing ;
     Inc(NumDrugs) ;

     // Yohimbine (alpha-2 adrenoceptors antagonist)
     Drugs[NumDrugs].Name := 'Yohimbine' ;
     Drugs[NumDrugs].ShortName := 'Yoh' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_Alpha2_AdrenR := 5E-6*RandG(1.0,0.05) ;
     Drugs[NumDrugs].Antagonist := True ; ;
     Drugs[NumDrugs].Tissue := tGPIleum ;
     Drugs[NumDrugs].Unknown := False ;
     Inc(NumDrugs) ;

     Drugs[NumDrugs].Name := 'Isoprenaline' ; // Beta-adrenoceptor antagonist (jejunum)
     Drugs[NumDrugs].ShortName := 'Iso' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_Beta_AdrenR := 2E-6*RandG(1.0,0.05) ;
     Drugs[NumDrugs].Antagonist := False ;
     Drugs[NumDrugs].Tissue := tJejunum ;
     Inc(NumDrugs) ;

     Drugs[NumDrugs].Name := 'Nifedipine' ; // Calcium channel blocker
     Drugs[NumDrugs].ShortName := 'Nif' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_CaChannelV := 1E-7*RandG(1.0,0.05) ;
     Drugs[NumDrugs].Antagonist := True ;
     Drugs[NumDrugs].Tissue := tArterialRing ;
     Inc(NumDrugs) ;

     Drugs[NumDrugs].Name := 'Thapsigargin' ; // SR Calcium uptake pump blocker
     Drugs[NumDrugs].ShortName := 'Tha' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_CaStore := 1E-7*RandG(1.0,0.05) ;  // Note thapsigargin is NOT an IP3R antagonist
     Drugs[NumDrugs].Antagonist := True ;                 // but no distinction is made in current model
     Drugs[NumDrugs].Tissue := tArterialRing ;            // between block of release from stores by IP3
     Inc(NumDrugs) ;                                      // depletion of stores

     Drugs[NumDrugs].Name := 'SKF96365' ; // SR channel blocker
     Drugs[NumDrugs].ShortName := 'SKF' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_CaChannelR := 5E-5*RandG(1.0,0.05) ;
     Drugs[NumDrugs].Antagonist := True ;
     Drugs[NumDrugs].Tissue := tArterialRing ;
     Inc(NumDrugs) ;

     Drugs[NumDrugs].Name := 'Acetylcholine' ; // Cholinoceptor agonist
     Drugs[NumDrugs].ShortName := 'Ach' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_nAchR := 1E-5*RandG(1.0,0.05) ;
     Drugs[NumDrugs].EC50_mAchR := 4.2E-7*RandG(1.0,0.05) ; {21/8/18 4.2E-8->4.2E-7 Ach less potent on mAChr}
     Drugs[NumDrugs].Antagonist := False ;
     Drugs[NumDrugs].Tissue := tGPIleum + tChickBiventer + tJejunum ;
     Inc(NumDrugs) ;

     Drugs[NumDrugs].Name := 'Neostigmine' ; // Cholinesterase inhibitor
     Drugs[NumDrugs].ShortName := 'Neo' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_AchEsterase := 1E-6*RandG(1.0,0.05) ;
     Drugs[NumDrugs].Antagonist := True ;
     Drugs[NumDrugs].Tissue := tChickBiventer ;
     Inc(NumDrugs) ;

     Drugs[NumDrugs].Name := 'Suxamethonium' ; // Depolarizing neuromuscular blocker / Nicotinic agonist
     Drugs[NumDrugs].ShortName := 'Sux' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_nAchR := 1E-6*RandG(1.0,0.05) ;
     Drugs[NumDrugs].Antagonist := False ;
     Drugs[NumDrugs].Tissue := tChickBiventer ;
     Inc(NumDrugs) ;

     Drugs[NumDrugs].Name := 'Pilocarpine' ; // Cholinoceptor agonist
     Drugs[NumDrugs].ShortName := 'Pil' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_nAchR := 1E-5*RandG(1.0,0.05) ;
     Drugs[NumDrugs].EC50_mAchR := 1.65E-6*RandG(1.0,0.05) ;
     Drugs[NumDrugs].Antagonist := False ;
     Drugs[NumDrugs].Tissue := tGPIleum + tJejunum ;
     Inc(NumDrugs) ;

     Drugs[NumDrugs].Name := 'Hyoscine' ; // Cholinoceptor antagonist
     Drugs[NumDrugs].ShortName := 'Hyo' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_nAchR := 2E-6*RandG(1.0,0.05) ;
     Drugs[NumDrugs].EC50_mAchR := 1E-7*RandG(1.0,0.05) ; {21/8/18 1E-10 > 1E-7M Hyoscine less potent}
     Drugs[NumDrugs].Tissue := tGPIleum ;
     Drugs[NumDrugs].Antagonist := True ;
     Inc(NumDrugs) ;

     Drugs[NumDrugs].Name := 'Adrenaline/Epinephrine' ; // Alpha + beta adrenoceptor agonist
     Drugs[NumDrugs].ShortName := 'Adr' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_Alpha_AdrenR := 1E-5*RandG(1.0,0.05) ;
     Drugs[NumDrugs].EC50_Alpha2_AdrenR := 1E-5*RandG(1.0,0.05) ;
     Drugs[NumDrugs].EC50_Beta_AdrenR := 5E-6*RandG(1.0,0.05) ;
     Drugs[NumDrugs].Antagonist := False ;
     Drugs[NumDrugs].Tissue := tArterialRing + tJejunum ;
     Inc(NumDrugs) ;

     // Unknown drugs

     // MP220: Oxybutynin: Muscarinic antagonist
     Drugs[NumDrugs].Name := 'MP220' ;
     Drugs[NumDrugs].ShortName := 'MP220' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_HistR := 2E-6*RandG(1.0,0.05) ;
     Drugs[NumDrugs].EC50_mAchR := 1E-9*RandG(1.0,0.05) ;
     Drugs[NumDrugs].Antagonist := True ;
     Drugs[NumDrugs].Tissue := tGPIleum ;
     Drugs[NumDrugs].Unknown := True ;
     Inc(NumDrugs) ;

     Drugs[NumDrugs].Name := 'Drug 1' ; // Histamine antagonist / weak musc.
     Drugs[NumDrugs].ShortName := 'Dr1' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     // V1.8 2011-12
     // Drugs[NumDrugs].EC50_HistR := 1E30 ; // Mep=2E-10M
     //Drugs[NumDrugs].EC50_HistR_NC := 2E-9*RandG(1.0,0.05) ; // Low affinity, non-competitive action
     // V2.2 2012-13
     //Drugs[NumDrugs].EC50_HistR := 1E-8 ; // Mep=2E-10M    comp. ant 100X less potent than mepyramine
     //Drugs[NumDrugs].EC50_mAchR := 8E-6*RandG(1.0,0.05) ;

     // V2.3 2013-14
     //Drugs[NumDrugs].EC50_HistR := 1E30 ; // Mep=2E-10M    comp. ant 100X less potent than mepyramine
     //Drugs[NumDrugs].EC50_HistR_NC := 1E-9*RandG(1.0,0.05) ; // Non-comp ant slightly less potent than mepyramine
     //Drugs[NumDrugs].EC50_mAchR := 8E-6*RandG(1.0,0.05) ;

     // V2.5 2014-15
     Drugs[NumDrugs].EC50_HistR := 1.5E-11*RandG(1.0,0.05) ; // Mep=2E-10M competitive antagonist X10 more potent than mep
     Drugs[NumDrugs].EC50_HistR_NC := 1E30;//*RandG(1.0,0.05)
     Drugs[NumDrugs].EC50_mAchR := 8E-6*RandG(1.0,0.05) ;

     Drugs[NumDrugs].Antagonist := True ;
     Drugs[NumDrugs].Unknown := True ;
     Drugs[NumDrugs].Tissue := tGPIleum ;
     Inc(NumDrugs) ;

     Drugs[NumDrugs].Name := 'Drug 2' ; //
     Drugs[NumDrugs].ShortName := 'Dr2' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     // V1.8 2011-12 Muscarinic antagonist / weak hist.
     // Drugs[NumDrugs].EC50_HistR := 1E-6*RandG(1.0,0.05) ;
     // Drugs[NumDrugs].EC50_mAchR := 1E-10*RandG(1.0,0.05) ; // Atr=1E-9
     // V2.2 2012-13 Muscarinic antagonist (less potent than atropine)/ weak hist.
     //Drugs[NumDrugs].EC50_HistR := 1E-5*RandG(1.0,0.05) ;
     //Drugs[NumDrugs].EC50_mAchR := 1E30 ;
     //Drugs[NumDrugs].EC50_mAchR_NC := 5E-9*RandG(1.0,0.05) ; // non-comp. ant.

     //V2.3 2013 (Competitive antagonist (more potent that atropine)
     //Drugs[NumDrugs].EC50_HistR := 1E-5*RandG(1.0,0.05) ;
     //Drugs[NumDrugs].EC50_mAchR := 8E-11*RandG(1.0,0.05) ;
     //Drugs[NumDrugs].EC50_mAchR_NC := 1E30 ;//

     //V2.5 2014 (non-competitive antagonist (100X less potent that atropine)
     Drugs[NumDrugs].EC50_HistR := 1E-5*RandG(1.0,0.05) ;
     Drugs[NumDrugs].EC50_mAchR := 1E30 ;//8E-11*RandG(1.0,0.05) ;
     Drugs[NumDrugs].EC50_mAchR_NC := 1E-7*RandG(1.0,0.06) ;//

     Drugs[NumDrugs].Antagonist := True ;
     Drugs[NumDrugs].Tissue := tGPIleum ;
     Drugs[NumDrugs].Unknown := True ;
     Inc(NumDrugs) ;

     // Drug A: (mu-opioid agonist) (10X more potent than morphine)
     Drugs[NumDrugs].Name := 'Drug A' ;
     Drugs[NumDrugs].ShortName := 'DrA' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_OpR := 5E-9*RandG(1.0,0.05) ; // Decreased from 1E-7 16.01.19
     Drugs[NumDrugs].Antagonist := False ;
     Drugs[NumDrugs].Tissue := tGPIleum ;
     Drugs[NumDrugs].Unknown := True ;
     Inc(NumDrugs) ;

     // Drug B: Clonidine: alpha 2 agonist
     Drugs[NumDrugs].Name := 'Drug B' ;
     Drugs[NumDrugs].ShortName := 'DrB' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_Alpha2_AdrenR := 5E-7*RandG(1.0,0.05) ; //Increased from 2E-6 16.01.19
     Drugs[NumDrugs].Antagonist := False ;
     Drugs[NumDrugs].Tissue := tGPIleum ;
     Drugs[NumDrugs].Unknown := True ;
     Inc(NumDrugs) ;

     // Drug C: Verapamil (Ca channel blocker)
     Drugs[NumDrugs].Name := 'Drug C' ;
     Drugs[NumDrugs].ShortName := 'DrC' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_CaChannelV := 1E-7*RandG(1.0,0.05) ;
     Drugs[NumDrugs].Antagonist := True ;
     Drugs[NumDrugs].Tissue := tGPIleum ;
     Drugs[NumDrugs].Unknown := True ;
     Inc(NumDrugs) ;

     // Drug D: Oxybutynin: Muscarinic antagonist
     Drugs[NumDrugs].Name := 'Drug D' ;
     Drugs[NumDrugs].ShortName := 'DrD' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_HistR := 2E-6*RandG(1.0,0.05) ;
     Drugs[NumDrugs].EC50_mAchR := 1E-9*RandG(1.0,0.05) ;
     Drugs[NumDrugs].Antagonist := True ;
     Drugs[NumDrugs].Tissue := tGPIleum ;
     Drugs[NumDrugs].Unknown := True ;
     Inc(NumDrugs) ;

     // Drug E: Mepyramine: H1 receptor antagonist
     Drugs[NumDrugs].Name := 'Drug E' ;
     Drugs[NumDrugs].ShortName := 'DrE' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_HistR := 2E-10*RandG(1.0,0.05) ;
     Drugs[NumDrugs].EC50_mAchR := 1.5E-5*RandG(1.0,0.05) ;
     Drugs[NumDrugs].Antagonist := True ;
     Drugs[NumDrugs].Tissue := tGPIleum ;
     Drugs[NumDrugs].Unknown := True ;
     Inc(NumDrugs) ;

     // Botulinum toxin B
     Drugs[NumDrugs].Name := 'Botulinum Toxin B' ;
     Drugs[NumDrugs].ShortName := 'BTXB' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_BTXB := 1e-2 ;
     Drugs[NumDrugs].Antagonist := False ;
     Drugs[NumDrugs].Tissue := tGPIleum ;
     Drugs[NumDrugs].Unknown := True ;
     Drugs[NumDrugs].Units := 'ml' ;
     Inc(NumDrugs) ;

     // Botulinum toxin B + Anti-B antibody
     Drugs[NumDrugs].Name := 'Botulinum Tox. A+B Antibody' ;
     Drugs[NumDrugs].ShortName := 'BTX-AB' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_BTXB := 1e-10 ;
     Drugs[NumDrugs].Antagonist := True ;
     Drugs[NumDrugs].Tissue := tGPIleum ;
     Drugs[NumDrugs].Unknown := True ;
     Drugs[NumDrugs].Units := 'ml' ;
     Inc(NumDrugs) ;

     // Sample A (Botulinum toxin B)
     Drugs[NumDrugs].Name := 'Sample A' ;
     Drugs[NumDrugs].ShortName := 'SamA' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_BTXB := 1e-2 ;
     Drugs[NumDrugs].Antagonist := False ;
     Drugs[NumDrugs].Tissue := tGPIleum ;
     Drugs[NumDrugs].Unknown := True ;
     Drugs[NumDrugs].Units := 'ml' ;
     Inc(NumDrugs) ;

     // Sample B (Botulinum toxin B)
     Drugs[NumDrugs].Name := 'Sample B' ;
     Drugs[NumDrugs].ShortName := 'SamB' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_BTXB := 1e-2 ;
     Drugs[NumDrugs].Antagonist := False ;
     Drugs[NumDrugs].Tissue := tGPIleum ;
     Drugs[NumDrugs].Unknown := True ;
     Drugs[NumDrugs].Units := 'ml' ;
     Inc(NumDrugs) ;

     // Sample C (Botulinum toxin E)
     Drugs[NumDrugs].Name := 'Sample C' ;
     Drugs[NumDrugs].ShortName := 'SamC' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_BTXE := 1e-2 ;
     Drugs[NumDrugs].Antagonist := False ;
     Drugs[NumDrugs].Tissue := tGPIleum ;
     Drugs[NumDrugs].Unknown := True ;
     Drugs[NumDrugs].Units := 'ml' ;
     Inc(NumDrugs) ;

     Drugs[NumDrugs].Name := 'Drug 1' ;
     Drugs[NumDrugs].ShortName := 'Dr1' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_nAchR := 5E-6*RandG(1.0,0.05) ;
     Drugs[NumDrugs].Tissue := tChickBiventer ;
     Drugs[NumDrugs].Antagonist := False ;
     Drugs[NumDrugs].Unknown := True ;
     Inc(NumDrugs) ;

     Drugs[NumDrugs].Name := 'Drug 2' ;
     Drugs[NumDrugs].ShortName := 'Dr2' ;
     Drugs[NumDrugs].FinalBathConcentration := 0.0 ;
     Drugs[NumDrugs].BathConcentration := 0.0 ;
     Drugs[NumDrugs].EC50_nAchR := 5E-6*RandG(1.0,0.05) ;
     Drugs[NumDrugs].Antagonist := True ;
     Drugs[NumDrugs].Tissue := tChickBiventer ;
     Drugs[NumDrugs].Unknown := True ;
     Inc(NumDrugs) ;


     // Copy set of drugs into reservoir
     for i:= 0 to NumDrugs-1 do ReservoirDrugs[i] := Drugs[i] ;

     // Create list of agonists
     cbAgonist.Clear ;
     for i := 0 to NumDrugs-1 do
         if (not Drugs[i].Antagonist) and (not Drugs[i].Unknown) then begin
         if (Drugs[i].Tissue and TissueType) <> 0 then
            cbAgonist.Items.AddObject( Drugs[i].Name, TObject(NativeInt(i))) ;
         end ;
     if cbAntagonist.Items.Count > 0 then
        begin
        cbAgonist.ItemIndex := 0 ;
        // Set up stock soln. concentration list
        SetStockConcentrationList( NativeInt(cbAgonist.Items.Objects[cbAgonist.ItemIndex]),
                                   cbAgonistStockConc ) ;
        end ;

     // Create list of antagonists
     cbAntagonist.Clear ;
     for i := 0 to NumDrugs-1 do
         if (Drugs[i].Antagonist) and (not Drugs[i].Unknown) then begin
         if (Drugs[i].Tissue and TissueType) <> 0 then
            cbAntagonist.Items.AddObject( Drugs[i].Name, TObject(NativeInt(i))) ;
         end ;
     if cbAntagonist.Items.Count > 0 then
        begin
        cbAntagonist.ItemIndex := 0 ;
        SetStockConcentrationList( NativeInt(cbAntagonist.Items.Objects[cbAntagonist.ItemIndex]),
                                   cbAntagonistStockConc ) ;
        end ;

     // Create list of unknowns
     cbUnknown.Clear ;
     for i := 0 to NumDrugs-1 do if Drugs[i].Unknown then begin
         if (Drugs[i].Tissue and TissueType) <> 0 then
            cbUnknown.Items.AddObject( Drugs[i].Name, TObject(NativeInt(i))) ;
         end ;
     if cbUnknown.Items.Count > 0 then
        begin
        cbUnknown.ItemIndex := 0 ;
        SetStockConcentrationList( NativeInt(cbUnknown.Items.Objects[cbUnknown.ItemIndex]),
                                   cbUnknownStockConc ) ;
        end;

     mAch_EC50 := 1E-6 ;
     nAch_EC50 := 2E-6 ;
     MaxReleasedAch := mAch_EC50*4.0 ;

     // Randomly vary maximal response of next agonist application
     NextRMax := MeanRMax*RandG( 1.0, RMaxStDev ) ;

     // Clear all drugs from organ bath & reservoir
     for i := 0 to NumDrugs-1 do begin
         Drugs[i].FinalBathConcentration := 0.0 ;
         Drugs[i].DisplayBathConcentration := 0.0 ;
         Drugs[i].BathConcentration := 0.0 ;
         ReservoirDrugs[i].FinalBathConcentration := 0.0 ;
         ReservoirDrugs[i].DisplayBathConcentration := 0.0 ;
         ReservoirDrugs[i].BathConcentration := 0.0 ;
         end ;

     // Set salt solution Ca concentration
     if NativeInt(cbSolution.Items.Objects[cbSolution.ItemIndex]) = ZeroCaSoln then begin
        Drugs[iCaBath].FinalBathConcentration := 0.0 ;
        Drugs[iCaBath].DisplayBathConcentration := 0.0 ;
        end
     else begin
        Drugs[iCaBath].FinalBathConcentration := 2.5E-3 ;
        Drugs[iCaBath].DisplayBathConcentration := 2.5E-3 ;
        end ;

     // Set desensitisation to none ;
     Desensitisation := 0.0 ;

     // Set botulinum toxin binding to none
     BTXBFreeFraction := 1.0 ;
     BTXEFreeFraction := 1.0 ;

     // Clear stimulus frequency
     StimFrequency := 0.0 ;

     { Clear buffer  }
     for i := 0 to MaxPoints-1 do ADC[i] := 0 ;
     StartPoint :=  0 ;
     scDisplay.SetDataBuf( @ADC[StartPoint] ) ;
     scDisplay.XOffset := -1 ;
     Force := 0.0 ;
     NumPointsDisplayed := 0 ;
     NumPointsInBuf := 0 ;

     // Clear chart annotation
     MarkerList.Clear ;

     bRecord.Enabled := True ;
     bStop.Enabled := False ;

     sbDisplay.Max := scDisplay.MaxPoints ;
     sbDisplay.Enabled := False ;
     sbDisplay.Position := 0 ;

     bAddAgonist.Enabled := False ;
     bAddAntagonist.Enabled := False ;
     bFlushReservoirToBath.Enabled := False ;

     bStop.Click ;

     UnSavedData := False ;

     end ;



procedure TMainFrm.rbMuscleClick(Sender: TObject);
begin
     if (not bStimulationOn.Enabled) and bStimulationOff.Enabled then AddDrugMarker( 'Stim(mu.)' ) ;
     end;

procedure TMainFrm.rbNerveClick(Sender: TObject);
begin
     if (not bStimulationOn.Enabled) and bStimulationOff.Enabled then AddDrugMarker( 'Stim(nv.)' ) ;
     end;

procedure TMainFrm.TimerTimer(Sender: TObject);
// ---------------------
// Timed event scheduler
// ---------------------
var
    NewPoint : Single ;
begin

     // Ensure that horizontal cursor remains at zero
     if scDisplay.HorizontalCursors[0] <> 0 then scDisplay.HorizontalCursors[0] := 0 ;

     if not bRecord.Enabled then begin
        case TissueType of
             tGPIleum : NewPoint := DoGPIleumSimulationStep(0.0) ;
             tChickBiventer : NewPoint := DoChickBiventerSimulationStep ;
             tArterialRing : NewPoint := DoArterialRingSimulationStep ;
             tJejunum : NewPoint := DoJejunumSimulationStep ;
             else NewPoint := 0.0 ;
             end ;
        UpdateDisplay( NewPoint ) ;
        InitialMixing := InitialMixing + 1 ;
        end
     else begin
        // Display
        if scDisplay.XOffset <> sbDisplay.Position then begin
           scDisplay.XOffset := sbDisplay.Position ;
           edStartTime.Value := scDisplay.XOffset ;
           scDisplay.SetDataBuf( @ADC[sbDisplay.Position] ) ;
           scDisplay.NumPoints := Min( scDisplay.MaxPoints,
                                       sbDisplay.Max - sbDisplay.Position) ;
           // Add annotations to chart
           AddChartAnnotations ;
           //scDisplay.Invalidate ;
           end ;
        end ;

     end;


procedure TMainFrm.AddChartAnnotations ;
// -------------------------------------
// Add drug annotations to chart display
// -------------------------------------
var
    i : Integer ;
    MarkerPosition : Integer ;
begin

     scDisplay.ClearMarkers ;
     for i := 0 to MarkerList.Count-1 do begin
         MarkerPosition := NativeInt(MarkerList.Objects[i]) - scDisplay.XOffset ;
         if (MarkerPosition > 0) and (MarkerPosition < scDisplay.MaxPoints) then begin
            scDisplay.AddMarker( MarkerPosition, MarkerList.Strings[i] ) ;
            end ;
         end ;
     end ;


function TMainFrm.DoGPIleumSimulationStep(
         CyclicNerveReleasedAch : single
         ) : single;
// ---------------------------------
// Compute next simulation time step
// ---------------------------------
const
    ReceptorReserve = 0.9 ;//0.997 ;
var
    i : Integer ;
    dConc : Single ;
    HisR : Single ;    // Histamine receptor activation
    mAchR : Single ;   // Muscarinic receptor activation
    OpR : Single ;     // Opioid receptor activation
    AlphaADR : Single ;  // Alpha adrenoceptor activation
    Sum : Single ;
    Efficacy : Single ;
    Occupancy : Single ;

    t : Single ;
    NerveReleasedAch : Single ;
    EndogenousOpiate : Single ;
    Activation50 : Single ;
    MaxDirectMuscleActivation,DirectMuscleActivation : single ;
    CaChannelOpenFraction : single ;
    MixingRate : Single ;
begin

    // Update drug bath concentrations
    MixingRate := (MaxMixingRate*InitialMixing) / ( 100.0 + InitialMixing) ;
    for i := 0 to NumDrugs-1 do begin
        dConc := (Drugs[i].FinalBathConcentration - Drugs[i].BathConcentration)*MixingRate*dt ;
        Drugs[i].BathConcentration := Max(Drugs[i].BathConcentration + dConc,0.0) ;
        end ;

    // Opioid receptors located on cholinergic nerve terminals (block transmitter release)

    EndogenousOpiate := 0.2 ;
    // Opioid receptor activation
    Sum := EndogenousOpiate ;
    for i := 0 to NumDrugs-1 do begin
        Sum := Sum + Drugs[i].BathConcentration/Drugs[i].EC50_OpR ;
        end ;
    Occupancy := Sum / ( 1. + Sum ) ;

    Efficacy := EndogenousOpiate ;
    for i := 0 to NumDrugs-1 do if not Drugs[i].Antagonist then begin
        Efficacy := Efficacy + Drugs[i].BathConcentration/Drugs[i].EC50_OpR ;
        end ;
    Efficacy := Efficacy / ( Sum + 0.001 ) ;
    OpR :=  Efficacy*Occupancy ;

    // Alpha2-adrenoceptors located on cholinergic nerve terminals (block transmitter release)

    Sum := 0.0 ;
    for i := 0 to NumDrugs-1 do begin
        Sum := Sum + Drugs[i].BathConcentration/Drugs[i].EC50_Alpha2_AdrenR ;
        end ;
    Occupancy := Sum / ( 1. + Sum ) ;

    Efficacy := 0.0 ;
    for i := 0 to NumDrugs-1 do if not Drugs[i].Antagonist then begin
        Efficacy := Efficacy + Drugs[i].BathConcentration/Drugs[i].EC50_Alpha2_AdrenR ;
        end ;
    Efficacy := Efficacy / ( Sum + 0.001 ) ;
    AlphaADR :=  Efficacy*Occupancy ;

    // Botulinum toxin B binding

    Sum := 0.0 ;
    for i := 0 to NumDrugs-1 do begin
        Sum := Sum + Drugs[i].BathConcentration/Drugs[i].EC50_BTXB ;
        end ;
    Occupancy := Sum / ( 1. + Sum ) ;

    Efficacy := 0.0 ;
    for i := 0 to NumDrugs-1 do if not Drugs[i].Antagonist then
        begin
        Efficacy := Efficacy + Drugs[i].BathConcentration/Drugs[i].EC50_BTXB ;
        end ;
    Efficacy := Efficacy / ( Sum + 0.001 ) ;
    BTXBFreeFraction := BTXBFreeFraction*(1.0 - Efficacy*Occupancy*0.01) ;

    // Botulinum toxin E binding

    Sum := 0.0 ;
    for i := 0 to NumDrugs-1 do
        begin
        Sum := Sum + Drugs[i].BathConcentration/Drugs[i].EC50_BTXE ;
        end ;
    Occupancy := Sum / ( 1. + Sum ) ;

    Efficacy := 0.0 ;
    for i := 0 to NumDrugs-1 do if not Drugs[i].Antagonist then
        begin
        Efficacy := Efficacy + Drugs[i].BathConcentration/Drugs[i].EC50_BTXE ;
        end ;
    Efficacy := Efficacy / ( Sum + 0.001 ) ;
    BTXEFreeFraction := BTXEFreeFraction*(1.0 - Efficacy*Occupancy*0.01) ;

    // Acetylcholine released from nerve
    // (blocked by Opioid receptor activation)
    // (Opioids can only achieve 90% block)

    MaxReleasedAch := (mAch_EC50*0.4*(0.02 + (1-OpR)*(1-AlphaADR)))
                       * BTXBFreeFraction*BTXEFreeFraction ;         // 0.25
    MaxDirectMuscleActivation := 1.0 ;
    RMax := NextRMax ;
    if not bStimulationOn.Enabled then begin
       if NumPointsInBuf >= NextStimulusAt then begin
          StimulusStartedAt := NumPointsInBuf ;
          NextStimulusAt := StimulusStartedAt + Round(StimulusInterval/dt) ;
          end ;
       t := (NumPointsInBuf - StimulusStartedAt)*dt ;
       if rbNerve.Checked then begin
          // Nerve released ACh
          NerveReleasedAch := MaxReleasedAch*(1.0 - exp(-t/0.1))*exp(-t/0.25) ;
          DirectMuscleActivation := 0.0 ;
          end
       else begin
          // Direct activation of smooth muscle
          NerveReleasedAch := 0.0 ;
          DirectMuscleActivation := MaxDirectMuscleActivation*(1.0 - exp(-t/0.1))*exp(-t/0.25) ;
          end;
       end
    else begin
       NerveReleasedAch := 0.0 ;
       DirectMuscleActivation := 0.0 ;
       end;
//    NerveReleasedAch := NerveReleasedAch + CyclicNerveReleasedAch*MaxReleasedAch ;

    // Histamine receptor activation
    Sum := 0.0 ;
    for i := 0 to NumDrugs-1 do begin
        Sum := Sum + Drugs[i].BathConcentration/Drugs[i].EC50_HistR ;
        end ;
    Occupancy := Sum / ( 1. + Sum ) ;

    Efficacy := 0.0 ;
    for i := 0 to NumDrugs-1 do if not Drugs[i].Antagonist then begin
        Efficacy := Efficacy + Drugs[i].BathConcentration/Drugs[i].EC50_HistR ;
        end ;
    Efficacy := Efficacy / ( Sum + 0.001 ) ;
    HisR :=  Efficacy*Occupancy ;

    // Histamine receptor activation -> contraction
    Activation50 := 1.0 - ReceptorReserve ;
    Sum := HisR/Activation50 ;
    for i := 0 to NumDrugs-1 do begin
        Sum := Sum + Drugs[i].BathConcentration/Drugs[i].EC50_HistR_NC ;
        end ;
    Occupancy := Sum /( 1.0 + Sum )  ;

    Efficacy := (HisR/Activation50) / ( Sum + 0.001 ) ;
    HisR :=  Efficacy*Occupancy ;

    // Muscarinic cholinoceptor receptor activation

    Sum := 0.0 ;
    for i := 0 to NumDrugs-1 do begin
        Sum := Sum + Drugs[i].BathConcentration/Drugs[i].EC50_mAchR ;
        end ;
    Sum := Sum + (NerveReleasedAch/mAch_EC50) ;
    Occupancy := Sum / ( 1. + Sum ) ;

    Efficacy := 0.0 ;
    for i := 0 to NumDrugs-1 do if not Drugs[i].Antagonist then begin
        Efficacy := Efficacy + Drugs[i].BathConcentration/Drugs[i].EC50_mAchR ;
        end ;
    Efficacy := (Efficacy + (NerveReleasedAch/mAch_EC50))/ ( Sum + 0.001 ) ;
    mAchR :=  Efficacy*Occupancy ;

    // Muscarinic receptor activation -> contraction
    Activation50 := 1.0 - ReceptorReserve ;
    Sum := mAchR/Activation50 ;
    for i := 0 to NumDrugs-1 do begin
        Sum := Sum + Drugs[i].BathConcentration/Drugs[i].EC50_mAchR_NC ;
        end ;
    Occupancy := Sum /( 1.0 + Sum )  ;

    Efficacy := (mAchR/Activation50) / ( Sum + 0.001 ) ;
    mAchR :=  Efficacy*Occupancy ;

    // Voltage operated trans membrane Ca channels (L type)
    // Fraction of channels unblocked
    Sum := 0.0 ;
    for i := 0 to NumDrugs-1 do begin
        Sum := Sum + Drugs[i].BathConcentration/Drugs[i].EC50_CaChannelV ;
        end ;
    Occupancy := Sum / ( 1. + Sum ) ;
    Efficacy := 0.0 ;
    for i := 0 to NumDrugs-1 do begin
        Efficacy := Efficacy + Drugs[i].BathConcentration/Drugs[i].EC50_CaChannelV ;
        end ;
    Efficacy := Efficacy/ ( Sum + 0.001 ) ;
    CaChannelOpenFraction :=  (1.0 - efficacy*occupancy) ;

    // Contraction
    Force := RandG( 0.0, BackgroundNoiseStDev ) ;
    Force := Force + RMax*CaChannelOpenFraction*Min(HisR + mAChR + DirectMuscleActivation,1.0) ;
    Result := Force ;

    end ;


function TMainFrm.DoJejunumSimulationStep : single ;
// ------------------------------------------------------
// Jejunum Simulation - Compute next simulation time step
// ------------------------------------------------------
const
    TwoPi = 2.0*3.1415926535897932385 ;
    Period = 3.5 ;
    NerveNorAdrReleaseRate = 0.03*1E-6 ;
    NerveNorAdrUptakeRate  = 0.1 ;
    BackgroundNoiseStDev = 0.075 ;  // Background noise (gms)
var
    i : Integer ;
    dConc : Single ;
    Alpha_AdrenR : Single ; // Alpha adrenoceptor activation
    Beta_AdrenR : Single ; // Beta adrenoceptor activation
    Sum : Single ;
    Efficacy : Single ;
    Occupancy : Single ;
    t : Single ;
    CyclicContraction : Single ;
    A : Single ;
    dNorAdr : SIngle ;
    NerveNorAdrRelease : SIngle ;
    NerveReleasedAch : SIngle ;
    mAchR : SIngle ;
    MixingRate : Single ;
begin

    // Update drug bath concentrations
    MixingRate := (MaxMixingRate*InitialMixing) / ( 100.0 + InitialMixing) ;
    for i := 0 to NumDrugs-1 do begin
        dConc := (Drugs[i].FinalBathConcentration - Drugs[i].BathConcentration)*MixingRate*dt ;
        Drugs[i].BathConcentration := Max(Drugs[i].BathConcentration + dConc,0.0) ;
        end ;

 // Cyclic sympathetic nerve transmitter release

    // Mesenteric nerve stimulation
    if not bStimulationOn.Enabled then begin
       NerveNorAdrRelease := StimFrequency*NerveNorAdrReleaseRate ;
       end
    else NerveNorAdrRelease := 0.0 ;

    dNorAdr := NerveNorAdrRelease - NerveReleasedNorAdrenaline*NerveNorAdrUptakeRate ;
    NerveReleasedNorAdrenaline := Max(NerveReleasedNorAdrenaline + dNorAdr,0.0) ;

    // Alpha-adrenoceptor activation
    Sum := NerveReleasedNorAdrenaline/Drugs[idxNorAdrenaline].EC50_Alpha_AdrenR ;
    for i := 0 to NumDrugs-1 do begin
        Sum := Sum + Drugs[i].BathConcentration/Drugs[i].EC50_Alpha_AdrenR ;
        end ;
    Occupancy := Sum / ( 1. + Sum ) ;

    Efficacy := NerveReleasedNorAdrenaline/Drugs[idxNorAdrenaline].EC50_Alpha_AdrenR ;
    for i := 0 to NumDrugs-1 do if not Drugs[i].Antagonist then begin
        Efficacy := Efficacy + Drugs[i].BathConcentration/Drugs[i].EC50_Alpha_AdrenR ;
        end ;
    Efficacy := Efficacy / ( Sum + 0.001 ) ;
    Alpha_AdrenR :=  Efficacy*Occupancy ;

    // Beta-adrenoceptor activation
    Sum := NerveReleasedNorAdrenaline/Drugs[idxNorAdrenaline].EC50_Beta_AdrenR ;
    for i := 0 to NumDrugs-1 do begin
        Sum := Sum + Drugs[i].BathConcentration/Drugs[i].EC50_Beta_AdrenR ;
        end ;
    Occupancy := Sum / ( 1. + Sum ) ;

    Efficacy := NerveReleasedNorAdrenaline/Drugs[idxNorAdrenaline].EC50_Beta_AdrenR ;
    for i := 0 to NumDrugs-1 do if not Drugs[i].Antagonist then begin
        Efficacy := Efficacy + Drugs[i].BathConcentration/Drugs[i].EC50_Beta_AdrenR ;
        end ;
    Efficacy := Efficacy / ( Sum + 0.001 ) ;
    Beta_AdrenR :=  Efficacy*Occupancy ;

    // Cylic contractions
    // Inhibited by alpha- and beta-adrenoceptors by separate mechanisms

    t := NumPointsInBuf*dt ;
    A := sin((2*Pi*t)/Period) ;
    CyclicContraction := A*A*A*A*
                        Max( 1.0 - 2.0*(Alpha_AdrenR/(1.+Alpha_AdrenR)) - 2.0*(Beta_AdrenR/(1.+Beta_AdrenR)) ,0.0 ) ;

    NerveReleasedAch := CyclicContraction*mAch_EC50 ;

    // Muscarinic cholinoceptor receptor activation
    Sum := 0.0 ;
    for i := 0 to NumDrugs-1 do begin
        Sum := Sum + Drugs[i].BathConcentration/Drugs[i].EC50_mAchR ;
        end ;
    Sum := Sum + (NerveReleasedAch/mAch_EC50) ;
    Occupancy := Sum / ( 1. + Sum ) ;

    Efficacy := 0.0 ;
    for i := 0 to NumDrugs-1 do if not Drugs[i].Antagonist then begin
        Efficacy := Efficacy + Drugs[i].BathConcentration/Drugs[i].EC50_mAchR ;
        end ;
    Efficacy := (Efficacy + (NerveReleasedAch/mAch_EC50))/ ( Sum + 0.001 ) ;
    mAchR :=  Efficacy*Occupancy ;

    Force := RandG( 0.0, BackgroundNoiseStDev ) ;
    RMax := NextRMax ;
    Force := Force + Rmax*mAChR ;
    Result := Force ;

    end ;


procedure TMainFrm.UpdateDisplay(
           NewPoint : Single ) ;
// -------------------
// Update chart display
// -------------------
var
    StartPoints : Integer ;
begin

    if NumPointsDisplayed >= scDisplay.MaxPoints then begin
       StartPoints := scDisplay.MaxPoints div 10 ;
       NumPointsDisplayed := StartPoints ;
       sbDisplay.Position := NumPointsInBuf - StartPoints + 1 ;
       scDisplay.XOffset := sbDisplay.Position ;
       scDisplay.SetDataBuf( @ADC[sbDisplay.Position] ) ;
       sbDisplay.Max := sbDisplay.Max + scDisplay.MaxPoints ;
       edStartTime.HiLimit := sbDisplay.Max ;
       // Add annotations to chart
       AddChartAnnotations ;
       end ;

    ADC[NumPointsInBuf] := Round( NewPoint/scDisplay.ChanScale[0] ) ;
    Inc(NumPointsInBuf) ;
    Inc(NumPointsDisplayed) ;
    scDisplay.DisplayNewPoints( NumPointsInBuf - 1- scDisplay.XOffset ) ;
    outputdebugstring(pchar(format('%d',[scDisplay.XOffset])));

    end ;


function TMainFrm.DoChickBiventerSimulationStep : Single ;
// ------------------------------------------------
// Compute next Chick Biventer simulation time step
// ------------------------------------------------
//
const
    StimulusInterval = 1.0 ;
var
    i : Integer ;
    Conc,dConc : Single ;
    nAchR : Single ;
    AchEsterase : Single ;          // Cholinesterase inhibition
    nAchRDesensitization : Single ; // Nicotinic junctional receptor desensitization
    Sum : Single ;
    Efficacy : Single ;
    Occupancy : Single ;
    t : Single ;
    NerveReleasedAch : Single ;
    R : Single ;
    RNerve : Single ;
    MixingRate : single ;
begin

    // Update drug bath concentrations
    MixingRate := (MaxMixingRate*InitialMixing) / ( 100.0 + InitialMixing) ;
    for i := 0 to NumDrugs-1 do
        begin
        dConc := (Drugs[i].FinalBathConcentration - Drugs[i].BathConcentration)*MixingRate*dt ;
        Drugs[i].BathConcentration := Max(Drugs[i].BathConcentration + dConc,0.0) ;
        end ;


    // Cholinesterase inhibition (1=fully active, 0= inhibited)
    Sum := 0.0 ;
    for i := 0 to NumDrugs-1 do
        begin
        R := Drugs[i].BathConcentration/Drugs[i].EC50_AchEsterase ;
        Sum := Sum + R  ;
        end ;
    Occupancy := sum / ( 1. + sum ) ;

    Efficacy := 0.0 ;
    for i := 0 to NumDrugs-1 do
        begin
        R := Drugs[i].BathConcentration/Drugs[i].EC50_AchEsterase ;
        Efficacy := Efficacy + R ;
        end ;
    Efficacy := Efficacy / ( Sum + 0.001 ) ;
    AchEsterase :=  efficacy*occupancy ;

    // Nicotinic cholinoceptor receptor activation by agonists in bath

    Sum := 0.0 ;
    for i := 0 to NumDrugs-1 do
        begin
        Conc := Drugs[i].BathConcentration ;
        if ContainsText(Drugs[i].Name,'acetylcholine') then Conc := Conc*(1.0 + AchEsterase*10.0) ;
        R := Conc / Drugs[i].EC50_nAchR ;
        Sum := Sum + R*R  ;
        end ;
    Occupancy := sum / ( 1. + sum ) ;

    Efficacy := 0.0 ;
    for i := 0 to NumDrugs-1 do if not Drugs[i].Antagonist then
        begin
        Conc := Drugs[i].BathConcentration ;
        if ContainsText(Drugs[i].Name,'acetylcholine') then Conc := Conc*(1.0 + AchEsterase*10.0) ;
        R := Conc/Drugs[i].EC50_nAchR ;
        Efficacy := Efficacy + R*R ;
        end ;
    nAchR :=  efficacy*occupancy ;

    // Desensitization of junctional receptors after acivation by nicotinic agonists
    nAchRDesensitization := 1.0/(1.0 + (nAchR*nAChR)*5000.0) ;

    // Nerve stimulated transmitter release
    MaxReleasedAch := nAch_EC50*4.0 ;
    RMax := NextRMax ;
    if (not bStimulationOn.Enabled) and rbNerve.Checked then
       begin
       if NumPointsInBuf >= NextStimulusAt then
          begin
          StimulusStartedAt := NumPointsInBuf ;
          NextStimulusAt := StimulusStartedAt + Round(StimulusInterval/dt) ;
          end ;
       t := (NumPointsInBuf - StimulusStartedAt)*dt ;
       NerveReleasedAch := MaxReleasedAch*(1.0 - exp(-t/0.05))*exp(-t/0.1) ;
       end
    else NerveReleasedAch := 0.0 ;

    // Add nerve activated juntional nicotinic receptors to total
    R := (NerveReleasedAch*nAchRDesensitization*(1.0 + AchEsterase*10.0))/nAch_EC50 ;
    Sum := Sum + (R*R) ;
    Occupancy := sum / ( 1. + sum ) ;
    Efficacy := (Efficacy + (R*R))/ ( Sum + 0.001 ) ;
    nAchR :=  efficacy*occupancy ;

    Force := RandG( 0.0, BackgroundNoiseStDev ) ;
    Force := Force + RMax*nAchR ;

    // Direct muscle stimulation
    if (not bStimulationOn.Enabled) and rbMuscle.Checked then
       begin
       if NumPointsInBuf >= NextStimulusAt then
          begin
          StimulusStartedAt := NumPointsInBuf ;
          NextStimulusAt := StimulusStartedAt + Round(StimulusInterval/dt) ;
    //      RMax := MeanRMax*RandG( 1.0, 0.025 ) ;
          end ;
       t := (NumPointsInBuf - StimulusStartedAt)*dt ;
       Force := Force + RMax*(1.0 - exp(-t/0.004))*exp(-t/0.15) ;
       Force := Min(Force,RMax) ;

       end ;

    Result := Force ;

    end ;


function TMainFrm.DoArterialRingSimulationStep : Single ;
// ------------------------------------------------
// Compute next rabbit arterial ring simulation time step
// ------------------------------------------------
const
    StimulusInterval = 1.0 ;
    DesOnRate = 0.0015 ;
    DesOffRate = 1.5E-3 ; // was 1E-3
var
    i : Integer ;
    dConc : Single ;
    Sum : Single ;
    Efficacy : Single ;
    Occupancy : Single ;
    AdrenR : Single ;      // Adrenergic receptor activitation
    IP3R : Single ;        // IP3 receptor activation
    PLCActivity : Single ; // Phospholipase C enzyme activity
    CaI : Single ;         // Internal calcium activation
    CaO_Multiplier : Single ;         // External Ca
    CaChannelOpenFraction : Single ;  // Fraction of Ca plasma membrane voltage-activated channels open
    CaChannelROpenFraction : Single ; // Fraction of Ca plasma membrane receptor-operated channels open
    CaStore : Single ;                 // Ca store uptake pump activity
    CaS : Single ;                    // Ca released from internal stores
    R : Single ;
    MixingRate : single ;
begin

    // Update drug bath concentrations
    MixingRate := (MaxMixingRate*InitialMixing) / ( 100.0 + InitialMixing) ;
    for i := 0 to NumDrugs-1 do begin
        dConc := (Drugs[i].FinalBathConcentration - Drugs[i].BathConcentration)*MixingRate*dt ;
        Drugs[i].BathConcentration := Max(Drugs[i].BathConcentration + dConc,0.0) ;
        end ;

    // Adrenergic receptor activation
    Sum := 0.0 ;
    for i := 0 to NumDrugs-1 do begin
        Sum := Sum + Drugs[i].BathConcentration/Drugs[i].EC50_Alpha_AdrenR ;
        end ;
    Occupancy := Sum / ( 1. + Sum ) ;

    Efficacy := 0.0 ;
    for i := 0 to NumDrugs-1 do if not Drugs[i].Antagonist then begin
        Efficacy := Efficacy + Drugs[i].BathConcentration/Drugs[i].EC50_Alpha_AdrenR ;
        end ;
    Efficacy := Efficacy/ ( Sum + 0.001 ) ;
    AdrenR :=  efficacy*occupancy ;

    // Phospholipase C inhibition
    Sum := 0.0 ;
    for i := 0 to NumDrugs-1 do begin
        Sum := Sum + Drugs[i].BathConcentration/Drugs[i].EC50_PLC_Inhibition ;
        end ;
    Occupancy := Sum / ( 1. + Sum ) ;

    Efficacy := 0.0 ;
    for i := 0 to NumDrugs-1 do if Drugs[i].Antagonist then begin
        Efficacy := Efficacy + Drugs[i].BathConcentration/Drugs[i].EC50_PLC_Inhibition ;
        end ;
    Efficacy := Efficacy/ ( Sum + 0.001 ) ;
    PLCActivity :=  1.0 - (efficacy*occupancy) ;

    // IP3 receptor activation
    Sum := 0.0 ;
    for i := 0 to NumDrugs-1 do begin
        Sum := Sum + Drugs[i].BathConcentration/Drugs[i].EC50_IP3R ;
        end ;
    Sum := Sum + 2.0*PLCActivity*AdrenR ;
    Occupancy := Sum / ( 1. + Sum ) ;

    Efficacy := 0.0 ;
    for i := 0 to NumDrugs-1 do if not Drugs[i].Antagonist then begin
        Efficacy := Efficacy + Drugs[i].BathConcentration/Drugs[i].EC50_IP3R ;
        end ;
    Efficacy := Efficacy + 2.0*PLCActivity*AdrenR ;
    Efficacy := Efficacy/ ( Sum + 0.001 ) ;
    IP3R :=  efficacy*occupancy ;

    // Voltage operated trans membrane Ca channels (L type)
    // (Lets in external Ca to cell cytoplasm, opened by KCL, blocked by nifedipine)
    Sum := 0.0 ;
    for i := 0 to NumDrugs-1 do begin
        R := Drugs[i].BathConcentration/Drugs[i].EC50_CaChannelV ;
        Sum := Sum + R*R ;
        end ;
    Occupancy := Sum / ( 1. + Sum ) ;
    Efficacy := 0.0 ;
    for i := 0 to NumDrugs-1 do if not Drugs[i].Antagonist then begin
        R := Drugs[i].BathConcentration/Drugs[i].EC50_CaChannelV ;
        Efficacy := Efficacy + R*R ;
        end ;
    Efficacy := Efficacy/ ( Sum + 0.001 ) ;
    CaChannelOpenFraction :=  efficacy*occupancy ;

    // Ca internal stores (1=full, 0=empty)
    // Note depleted by thapsigargin
    Sum := 0.0 ;
    for i := 0 to NumDrugs-1 do begin
        R := Drugs[i].BathConcentration/(Drugs[i].EC50_CaStore) ;
        Sum := Sum + R ;
        end ;
    CaStore := 1.0 / ( 1.0 + Sum ) ;

    // Fraction of receptor operated Ca channels blocked
    Sum := 0.0 ;
    for i := 0 to NumDrugs-1 do begin
        R := Drugs[i].BathConcentration/(Drugs[i].EC50_CaChannelR) ;
        Sum := Sum + R ;
        end ;
    CaChannelROpenFraction :=  1./( 1. + Sum) ;

    // Internal Ca concentration


    // Ca influx via voltage operated Ca channels
    R := (CaChannelOpenFraction*Drugs[iCaBath].BathConcentration)/5E-4 ;
    Sum :=  R*R ;
    Occupancy := Sum / ( 1. + Sum ) ;
    Efficacy := R*R ;
    Efficacy := Efficacy/ ( Sum + 0.001 ) ;
    CaI :=  efficacy*occupancy ;

    // Calcium from Ca stores

    // Increased capacity of Ca stores via external Ca influx throught receptor operated channels
    R := (CaChannelROpenFraction*Drugs[iCaBath].BathConcentration)/2.5E-4 ;
    CaO_Multiplier := 1.0 + (R / (1.0 + R )) ;

    CaS := IP3R*CaStore*CaO_Multiplier ; ;

    Desensitisation := Desensitisation +
                       ((1.0-Desensitisation)*DesOnRate*CaS) - (Desensitisation*DesOffRate) ;
    CaS := CaS*(1.0 - Desensitisation) ;

    Force := RandG( 0.0, BackgroundNoiseStDev ) ;
    Force := Force +
             RMax*((1./(1. + exp(-8.*(CaI+CaS-0.5)))) - (1.0/(1.0 + exp(-8.0*(-0.5)))) ) ;
    // Tension relative to CaI & CaS = 0


    Result := Force ;

    end ;


procedure TMainFrm.bRecordClick(Sender: TObject);
// ----------------
// Start simulation
// ----------------
begin
     bRecord.Enabled := False ;
     bStop.Enabled := True ;
     sbDisplay.Enabled := False ;
     bAddAgonist.Enabled := True ;
     bAddAntagonist.Enabled := True ;
     bFlushReservoirToBath.Enabled := True ;
     bFreshReservoir.Enabled := True ;
     bNewExperiment.Enabled := False ;
     TissueGrp.Enabled := False ;
     bStimulationOff.Enabled := False ;
     bStimulationOn.Enabled := True ;

     UnSavedData := True ;

     NumPointsDisplayed := 0 ;
     sbDisplay.Position := NumPointsInBuf + 1 ;
     scDisplay.XOffset := sbDisplay.Position ;
     scDisplay.SetDataBuf( @ADC[sbDisplay.Position] ) ;
     sbDisplay.Max := sbDisplay.Max + scDisplay.MaxPoints ;
     // Add annotations to chart
     AddChartAnnotations ;

     end;


procedure TMainFrm.bStopClick(Sender: TObject);
// ----------------
// Stop simulation
// ----------------
begin
     bRecord.Enabled := True ;
     bStop.Enabled := False ;
     sbDisplay.Enabled := True ;
     bAddAgonist.Enabled := False ;
     bAddAntagonist.Enabled := False ;
     bFlushReservoirToBath.Enabled := False ;
     bFreshReservoir.Enabled := False ;
     bNewExperiment.Enabled := True ;
     TissueGrp.Enabled := True ;
     bStimulationOff.Enabled := False ;
     bStimulationOn.Enabled := False ;

     end;


procedure TMainFrm.bTDisplayDoubleClick(Sender: TObject);
// --------------------------------
// Increase display duration by 25%
// --------------------------------
begin
    edTDisplay.Value := edTDisplay.Value*1.25 ;
    UpdateDisplayDuration ;
    end;


procedure TMainFrm.bTDisplayHalfClick(Sender: TObject);
// --------------------------
// Decrease display duration
// --------------------------
begin
    edTDisplay.Value := edTDisplay.Value*(1.0/1.25) ;
    UpdateDisplayDuration ;
    end;

procedure TMainFrm.bAddAgonistClick(Sender: TObject);
// --------------------------------------------
// Add volume of agonist stock solution to bath
// --------------------------------------------
var
     StockConcentration : Single ;
     AddedConcentration : Single ;
     iDrug : Integer ;
     ChartAnnotation : String ;
begin

     if edAgonistVolume.Value > MaxSyringeVolume then
        begin
        ShowMessage( format('Syringe can only deliver %.1f ml',[MaxSyringeVolume])) ;
        Exit ;
        end ;

     // Add drug
     iDrug := NativeInt(cbAgonist.Items.Objects[cbAgonist.ItemIndex]) ;
     StockConcentration := DecodeConcentration(cbAgonistStockConc.Items.Objects[cbAgonistStockConc.ItemIndex]) ;

     // Calculate change in final bath concentration
     AddedConcentration :=  (StockConcentration*edAgonistVolume.Value) / BathVolume ;
     edAgonistVolume.Value := edAgonistVolume.Value ;

     // Update display bath concentration
     Drugs[iDrug].DisplayBathConcentration := Drugs[iDrug].DisplayBathConcentration
                                            + AddedConcentration ;

     // Update final bath concentration (with 10% C.V. random variability to simulation variation in response)
     Drugs[iDrug].FinalBathConcentration := Drugs[iDrug].FinalBathConcentration
                                            + AddedConcentration*RandG(1.0,0.1) ;

     RMax := NextRMax ;

     // Add chart annotation
     ChartAnnotation := format('%s %.3e %s',
                        [Drugs[iDrug].ShortName,
                         Drugs[iDrug].DisplayBathConcentration,
                         Drugs[iDrug].Units] ) ;
     AddDrugMarker( ChartAnnotation ) ;
     InitialMixing := 0 ;
     end;


procedure TMainFrm.bFlushReservoirToBathClick(Sender: TObject);
//  ----------------------------------
// Flush bath with reservoir solution
// ----------------------------------
var
    i : Integer ;
    ChartAnnotation : String ;
begin

     ChartAnnotation := 'Wash (' ;
     for i:= 0 to NumDrugs-1 do
         begin
         Drugs[i].FinalBathConcentration := ReservoirDrugs[i].FinalBathConcentration ;
         Drugs[i].DisplayBathConcentration := ReservoirDrugs[i].DisplayBathConcentration ;
         if (ReservoirDrugs[i].FinalBathConcentration > 0.0) and
            (i <> iCaBath) then begin
            ChartAnnotation := ChartAnnotation + ReservoirDrugs[i].ShortName + ' ' ;
            end ;
         end ;

     // Set salt solution Ca concentration
     if NativeInt(cbSolution.Items.Objects[cbSolution.ItemIndex])= ZeroCaSoln then
        begin
        Drugs[iCaBath].FinalBathConcentration := 0.0 ;
        Drugs[iCaBath].DisplayBathConcentration := 0.0 ;
        end
     else
        begin
        Drugs[iCaBath].FinalBathConcentration := 2.5E-3 ;
        Drugs[iCaBath].DisplayBathConcentration := 2.5E-3 ;
        end ;

     // Set type of solution in bath
     if NativeInt(cbSolution.Items.Objects[cbSolution.ItemIndex])= ZeroCaSoln then
        begin
        ChartAnnotation := ChartAnnotation + '0 Ca' ;
        end ;

     ChartAnnotation := ChartAnnotation + ')' ;

     AddDrugMarker( ChartAnnotation ) ;

     end;


procedure TMainFrm.FormResize(Sender: TObject);
// ------------------------------------------------------
// Set control size/locations when program window resized
// ------------------------------------------------------
begin

     ControlsGrp.Height := Max( ClientHeight - ControlsGrp.Top - 10,2 ) ; ;

     DisplayGrp.Height := Max( ClientHeight - DisplayGrp.Top - 10,2) ;
     DisplayGrp.Width := Max( ClientWidth - DisplayGrp.Left - 10,2) ;

     DisplayPage.Height := DisplayGrp.ClientHeight - DisplayPage.Top - 10 ;
     DisplayPage.Width := DisplayGrp.ClientWidth - DisplayPage.Left - 10 ;

     bRecord.Top := ChartPage.ClientHeight - bRecord.Height - 5 ;
     bStop.Top := bRecord.Top ;

//     lbCursor.Top :=  bRecord.Top - lbCursor.Height - 2 ;

    // sbDisplay.Top := bRecord.Top -  sbDisplay.Height - 2 ;
    // sbDisplay.Width := Max( ChartPage.ClientWidth - sbDisplay.Left - 10,2) ;

     scDisplay.Width := Max( ChartPage.ClientWidth - scDisplay.Left - 20,2) ;

     TDisplayPanel.Top :=  bRecord.Top -  TDisplayPanel.Height - 2 ;
     TDisplayPanel.Width := Max( scDisplay.Width + scDisplay.Left - TDisplayPanel.Left,2) ;
     bTDisplayDouble.Left := TDisplayPanel.Width - bTDisplayDouble.Width -1 ;
     edTDisplay.Left := bTDisplayDouble.Left -edTDisplay.Width - 1 ;
     bTDisplayHalf.Left := edTDisplay.Left - bTDisplayHalf.Width - 1 ;
     lbTDisplay.Left := bTDisplayHalf.Left - lbTDisplay.Width - 1 ;
     sbDisplay.Width :=  lbTDisplay.Left - sbDisplay.Left - 5 ;

     scDisplay.Height := Max( TDisplayPanel.Top - scDisplay.Top,2) ;


     // Centre experiment setup pictures on page

     GPIleumSetup.Left := Max( (ExperimentPage.ClientWidth - GPIleumSetup.Width) div 2,4) ;
     GPIleumSetup.Top := Max( (ExperimentPage.ClientHeight - GPIleumSetup.Height) div 2,4) ;

     ChickBiventerSetup.Left := Max( (ExperimentPage.ClientWidth - ChickBiventerSetup.Width) div 2,4) ;
     ChickBiventerSetup.Top := Max( (ExperimentPage.ClientHeight - ChickBiventerSetup.Height) div 2,4) ;

     ArterialRingSetup.Left := Max( (ExperimentPage.ClientWidth - ArterialRingSetup.Width) div 2,4) ;
     ArterialRingSetup.Top := Max( (ExperimentPage.ClientHeight - ArterialRingSetup.Height) div 2,4) ;

     JejunumSetup.Left := Max( (ExperimentPage.ClientWidth - JejunumSetup.Width) div 2,4) ;
     JejunumSetup.Top := Max( (ExperimentPage.ClientHeight - JejunumSetup.Height) div 2,4) ;

     end;


procedure TMainFrm.bAddAntagonistClick(Sender: TObject);
// ----------------------------------------------------
// Add volume of Antagonist stock solution to reservoir
// ----------------------------------------------------
var
     StockConcentration : Single ;
     AddedConcentration : Single ;
     iDrug : Integer ;
     ChartAnnotation : String ;
begin

     if edAntagonistVolume.Value > MaxSyringeVolume then begin
        ShowMessage( format('Syringe can only deliver %.1f ml',[MaxSyringeVolume])) ;
        Exit ;
        end ;
     edAntagonistVolume.Value := edAntagonistVolume.Value ;

     // Add drug
     iDrug := NativeInt(cbAntagonist.Items.Objects[cbAntagonist.ItemIndex]) ;
     StockConcentration := DecodeConcentration(cbAntagonistStockConc.Items.Objects[cbAntagonistStockConc.ItemIndex]) ;

     if cbAddAntagonistTo.ItemIndex = 0 then begin
          // Add to bath
          // -----------
         // Calculate change in final bath concentration
         AddedConcentration :=  (StockConcentration*edAntagonistVolume.Value) / BathVolume ;

         // Add drug to display conc.
         Drugs[iDrug].DisplayBathConcentration := Drugs[iDrug].DisplayBathConcentration
                                                + AddedConcentration ;

         // Add drug to final conc. (with 10% C.V. variability)
         Drugs[iDrug].FinalBathConcentration := Drugs[iDrug].FinalBathConcentration
                                                + AddedConcentration*RandG(1.0,0.1) ;

         // Add chart annotation
         ChartAnnotation := format('%s %.3e %s',
                            [Drugs[iDrug].ShortName,
                            Drugs[iDrug].DisplayBathConcentration,
                            Drugs[iDrug].Units] ) ;
         AddDrugMarker( ChartAnnotation ) ;

         end
     else begin
          // Add to reservoir

          // Calculate change in reservoir concentration
          AddedConcentration :=  (StockConcentration*edAntagonistVolume.Value) / ReservoirVolume ;
         // Update reservoir display conc.
         ReservoirDrugs[iDrug].DisplayBathConcentration := ReservoirDrugs[iDrug].DisplayBathConcentration
                                                         + AddedConcentration ;
         // Update reservoir (with 10% C.V. variability)
         ReservoirDrugs[iDrug].FinalBathConcentration := ReservoirDrugs[iDrug].FinalBathConcentration
                                                         + AddedConcentration*RandG(1.0,0.1) ;
         // Add chart annotation
         ChartAnnotation := format('%s %.3g %s (RES)',
                        [ReservoirDrugs[iDrug].ShortName,
                         ReservoirDrugs[iDrug].DisplayBathConcentration,
                         ReservoirDrugs[iDrug].Units]) ;

         AddDrugMarker( ChartAnnotation ) ;
         end ;
     InitialMixing := 0 ;
     end;


procedure TMainFrm.bAddUnknownClick(Sender: TObject);
// -----------------------------------------------------------
// Add volume of unknown drug stock solution to bath/reservoir
// -----------------------------------------------------------
var
     StockConcentration : Single ;
     AddedConcentration : Single ;
     iDrug : Integer ;
     ChartAnnotation : String ;
begin

     if cbUnknown.Items.Count < 1 then Exit ;

     if edUnknownVolume.Value > MaxSyringeVolume then
        begin
        ShowMessage( format('Syringe can only deliver %.1f ml',[MaxSyringeVolume])) ;
        Exit ;
        end ;
     edUnknownVolume.Value := edUnknownVolume.Value ;

     // Add drug
     iDrug := NativeInt(cbUnknown.Items.Objects[cbUnknown.ItemIndex]) ;
     StockConcentration := DecodeConcentration(cbUnknownStockConc.Items.Objects[cbUnknownStockConc.ItemIndex]) ;

     if cbAddUnknownTo.ItemIndex = 0 then
        begin
          // Add to bath
          // -----------
         // Calculate change in final bath concentration
         AddedConcentration :=  (StockConcentration*edUnknownVolume.Value) / BathVolume ;

         // Add to display conc. in bath
        Drugs[iDrug].DisplayBathConcentration := Drugs[iDrug].DisplayBathConcentration
                                                 + AddedConcentration ;

         // Add to final conc. in bath
         Drugs[iDrug].FinalBathConcentration := Drugs[iDrug].FinalBathConcentration
                                                + AddedConcentration*RandG(1.0,0.1) ;

         // Add chart annotation
         ChartAnnotation := format('%s %.3e %s',
                            [Drugs[iDrug].ShortName,
                            Drugs[iDrug].DisplayBathConcentration,
                            Drugs[iDrug].Units] ) ;
         AddDrugMarker( ChartAnnotation ) ;

         end
     else
        begin
        // Add to reservoir

        // Calculate change in reservoir concentration
        AddedConcentration :=  (StockConcentration*edUnknownVolume.Value) / ReservoirVolume ;
        // Update reservoir display conc.
        ReservoirDrugs[iDrug].DisplayBathConcentration := ReservoirDrugs[iDrug].DisplayBathConcentration
                                                         + AddedConcentration ;
        // Update reservoir final conc.
        ReservoirDrugs[iDrug].FinalBathConcentration := ReservoirDrugs[iDrug].FinalBathConcentration
                                                         + AddedConcentration*RandG(1.0,0.1) ;
        // Add chart annotation
        ChartAnnotation := format('%s %.3g %s (RES)',
                        [ReservoirDrugs[iDrug].ShortName,
                         ReservoirDrugs[iDrug].DisplayBathConcentration,
                         ReservoirDrugs[iDrug].Units]) ;
        AddDrugMarker( ChartAnnotation ) ;
        end ;

     InitialMixing := 0 ;
     end;


procedure TMainFrm.bCalculateClick(Sender: TObject);
// ----------------------------------
// Calculate selected dilution result
// ----------------------------------
var
    Units : string ;
    Result : single ;
begin

    case cbDilutionResult.ItemIndex of
      DilFBC : Units := 'M' ;
      DilStockC : Units := 'M' ;
      DilVAdd : Units := 'ml' ;
      DilVBath : Units := 'ml' ;
      end;

    if edDilDen.Value <> 0.0 then begin
       Result := (edDilNum1.Value * edDilNum2.Value ) / edDilDen.Value ;
       edDilResult.Text := format('%.4g %s',[Result,Units]);
       end
    else edDilResult.Text := 'Error:Divide by 0' ;
    end ;


procedure TMainFrm.AddDrugMarker(
          ChartAnnotation : String
          ) ;
// ------------------------------
// Add drug addition/wash marker
// ------------------------------
begin
     if MarkerList.Count < MaxMarkers then begin
        ChartAnnotation := AnsiReplaceStr( ChartAnnotation, '-00', '-' ) ;
        ChartAnnotation := AnsiReplaceStr( ChartAnnotation, '00E', '0E' ) ;
        MarkerList.AddObject( ChartAnnotation, TObject(NativeInt(NumPointsInBuf)) ) ;
        scDisplay.AddMarker( NumPointsInBuf - scDisplay.XOffset, ChartAnnotation ) ;
        end ;
     end ;


procedure TMainFrm.mnCopyDataClick(Sender: TObject);
// ----------------------------------------------------
// Copy sample values of displayed signals to clipboard
// ----------------------------------------------------
begin
     scDisplay.CopyDataToClipboard ;
     end;


procedure TMainFrm.mnPrintClick(Sender: TObject);
// ---------------------------
// Print displayed chart trace
// ---------------------------
begin
     PrintFrm.Left := Left + 50 ;
     PrintFrm.Top := Top + 50 ;
     PrintFrm.ShowModal ;
     if PrintFrm.ModalResult = mrOK then begin
        scDisplay.PrinterLeftMargin := 25 ;
        scDisplay.PrinterRightMargin := 25 ;
        scDisplay.PrinterTopMargin := 25 ;
        scDisplay.PrinterBottomMargin := 25 ;
        scDisplay.ChanCalBar[0] :=  scDisplay.ChanGridSpacing[0] ;
        scDisplay.TCalBar := scDisplay.TimeGridSpacing/scDisplay.TScale ;
        scDisplay.PrinterFontName := 'Arial' ;
        scDisplay.PrinterFontSize := 10 ;
        scDisplay.PrinterPenWidth := 2 ;
        scDisplay.Print ;
        end ;
     end;


procedure TMainFrm.SaveToFile(
          FileName : String
          ) ;
// ----------------------------
// Save chart recording to file
// ----------------------------
var
   Header : array[1..FileHeaderSize] of ansichar ;
   i : Integer ;
   FileHandle : Integer ;
begin

     FileHandle := FileCreate( FileName ) ;
     if FileHandle < 0 then Exit ;

     { Initialise empty header buffer with zero bytes }
     for i := 1 to sizeof(Header) do Header[i] := #0 ;


     AppendInt( Header, 'NPOINTS=', NumPointsInBuf ) ;
     AppendInt( Header, 'TISTYPE=', Integer(TissueType) ) ;

     AppendFloat( Header, 'NEXTRMAX=', NextRMax ) ;

     // Save drug EC50 settings
     for i := 0 to NumDrugs-1 do begin
          AppendFloat( Header, format('DRG%d_HIST=',[i]), Drugs[i].EC50_HistR ) ;
          AppendFloat( Header, format('DRG%dEC50_HISTNC=',[i]),Drugs[i].EC50_HistR_NC);
          AppendFloat( Header, format('DRG%d_N_ACH=',[i]), Drugs[i].EC50_nAchR ) ;
          AppendFloat( Header, format('DRG%d_M_ACH=',[i]), Drugs[i].EC50_mAchR ) ;
          AppendFloat( Header, format('DRG%dEC50_M_ACHNC=',[i]),Drugs[i].EC50_mAchR_NC);
          AppendFloat( Header, format('DRG%d_OP=',[i]), Drugs[i].EC50_OpR ) ;
          AppendFloat( Header, format('DRG%d_A_ADR=',[i]), Drugs[i].EC50_Alpha_AdrenR  ) ;
          AppendFloat( Header, format('DRG%d_B_ADR=',[i]), Drugs[i].EC50_Beta_AdrenR ) ;
          AppendFloat( Header, format('DRG%d_PLC=',[i]), Drugs[i].EC50_PLC_Inhibition ) ;
          AppendFloat( Header, format('DRG%d_IPS=',[i]), Drugs[i].EC50_IP3R ) ;
//          AppendFloat( Header, format('DRG%d_CAI=',[i]), Drugs[i].EC50_CaI ) ;
          AppendFloat( Header, format('DRG%d_CAS=',[i]), Drugs[i].EC50_CaStore ) ;
          AppendFloat( Header, format('DRG%d_CAV=',[i]), Drugs[i].EC50_CaChannelV ) ;
          AppendFloat( Header, format('DRG%d_CAR=',[i]), Drugs[i].EC50_CaChannelR ) ;
          end ;

     AppendInt( Header, 'NMARKERS=', MarkerList.Count ) ;
     for i := 0 to MarkerList.Count-1 do begin
         AppendInt( Header, format('MKP%d=',[i]), NativeInt(MarkerList.Objects[i])) ;
         AppendString( Header, format('MKT%d=',[i]), MarkerList.Strings[i] ) ;
         end ;

     // Write header
     FileWrite( FileHandle, Header, SizeOf(Header)) ;
     // Write chart data
     FileWrite( FileHandle, ADC, NumPointsInBuf*2 ) ;
     // Close file
     FileClose( FileHandle ) ;

     UnSavedData := False ;
     end ;


procedure TMainFrm.scDisplayCursorChange(Sender: TObject);
// --------------------------------------------
// Display cursor moved or display zoom changed
// --------------------------------------------
var
    ch : Integer ;
begin
     // Ensure that horizontal cursor remains at zero
     for ch := 0 to scDisplay.NumChannels-1 do
         if scDisplay.YMin[ch] < (MinADCValue div 10) then
            begin
            scDisplay.YMin[ch] := MinADCValue div 10 ;
            scDisplay.Invalidate ;
            end;

end;

procedure TMainFrm.Label5Click(Sender: TObject);
begin
     if not bStimulationOn.Enabled then AddDrugMarker( 'Stim(mu.)' ) ;
end;

procedure TMainFrm.LoadFromFile(
          FileName : String
          ) ;
// ----------------------------
// Load chart recording from file
// ----------------------------
var
   Header : array[1..FileHeaderSize] of ansichar ;
   i : Integer ;
   FileHandle : Integer ;
   NumMarkers : Integer ;
   MarkerPoint : Integer ;
   MarkerText : String ;
   DataStart : Integer ;
begin

     NumPointsInBuf := 0 ;

     FileHandle := FileOpen( FileName, fmOpenRead ) ;
     if FileHandle < 0 then Exit ;

     FileSeek( FileHandle, 0, 0 ) ;

     // Clear header
     for i := 1 to High(Header) do Header[i] := #0 ;

     // Read header
     FileRead(FileHandle, Header, Sizeof(Header)) ;

     // Get tissue type
     ReadInt( Header, 'TISTYPE=', TissueType ) ;

     NewExperiment ;

     NumPointsInBuf := 0 ;
     ReadInt( Header, 'NPOINTS=', NumPointsInBuf ) ;

     ReadFloat( Header, 'NEXTRMAX=', NextRMax ) ;

     // Read drug EC50 settings
     for i := 0 to NumDrugs-1 do begin
          ReadFloat( Header, format('DRG%d_HIST=',[i]), Drugs[i].EC50_HistR ) ;
          AppendFloat( Header, format('DRG%dEC50_HISTNC=',[i]),Drugs[i].EC50_HistR_NC);
          ReadFloat( Header, format('DRG%d_N_ACH=',[i]), Drugs[i].EC50_nAchR ) ;
          ReadFloat( Header, format('DRG%d_M_ACH=',[i]), Drugs[i].EC50_mAchR ) ;
          ReadFloat( Header, format('DRG%d_OP=',[i]), Drugs[i].EC50_OpR ) ;
          ReadFloat( Header, format('DRG%d_A_ADR=',[i]), Drugs[i].EC50_Alpha_AdrenR  ) ;
          ReadFloat( Header, format('DRG%d_B_ADR=',[i]), Drugs[i].EC50_Beta_AdrenR ) ;
          ReadFloat( Header, format('DRG%d_PLC=',[i]), Drugs[i].EC50_PLC_Inhibition ) ;
          ReadFloat( Header, format('DRG%d_IPS=',[i]), Drugs[i].EC50_IP3R ) ;
          ReadFloat( Header, format('DRG%d_CAS=',[i]), Drugs[i].EC50_CaStore ) ;
          ReadFloat( Header, format('DRG%d_CAV=',[i]), Drugs[i].EC50_CaChannelV ) ;
          ReadFloat( Header, format('DRG%d_CAR=',[i]), Drugs[i].EC50_CaChannelR ) ;
          end ;

     ReadInt( Header, 'NMARKERS=', NumMarkers ) ;
     MarkerList.Clear ;
     for i := 0 to NumMarkers-1 do begin
            ReadInt( Header, format('MKPOINT%d=',[i]), MarkerPoint) ;
            ReadInt( Header, format('MKP%d=',[i]), MarkerPoint) ;
            ReadString( Header, format('MKTEXT%d=',[i]), MarkerText ) ;
            ReadString( Header, format('MKT%d=',[i]), MarkerText ) ;
            MarkerList.AddObject( MarkerText, TObject(NativeInt(MarkerPoint))) ;
            end ;

     if NumPointsInBuf > 0 then begin
        DataStart := FileSeek( FileHandle, 0,2 ) - NumPointsInBuf*2 ;
        FileSeek( FileHandle, DataStart, 0 );
        FileRead( FileHandle, ADC, NumPointsInBuf*2 ) ;
        end ;

     // Close data file
     FileClose( FileHandle ) ;

     UnsavedData := False ;
     scDisplay.XOffset := -1 ;
     sbDisplay.Position := 0 ;
     sbDisplay.Max := NumPointsInBuf ;
     scDisplay.Invalidate ;

     end ;


procedure TMainFrm.mnCopyImageClick(Sender: TObject);
// -----------------------------------------
// Copy image of displayed trace to clipboad
// -----------------------------------------
begin

     scDisplay.ChanCalBar[0] :=  scDisplay.ChanGridSpacing[0] ;
     scDisplay.TCalBar := scDisplay.TimeGridSpacing/scDisplay.TScale ;
     scDisplay.PrinterFontName := 'Arial' ;
     scDisplay.PrinterFontSize := 10 ;
     scDisplay.MetafileWidth := 1000 ;
     scDisplay.MetafileHeight := 600 ;
     scDisplay.PrinterPenWidth := 2 ;
     scDisplay.CopyImageToClipBoard ;

     end;


procedure TMainFrm.mnLoadExperimentClick(Sender: TObject);
// -------------------------
// Load experiment from file
// -------------------------
begin

    if UnSavedData then begin
        if MessageDlg('Existing experiment will be overwritten! Are you sure?', mtConfirmation,
           [mbYes,mbNo],0) = mrNo then Exit ;
        end ;

   OpenDialog.options := [ofPathMustExist] ;
   OpenDialog.FileName := '' ;

   OpenDialog.DefaultExt := DataFileExtension ;
   //OpenDialog.InitialDir := OpenDirectory ;
   OpenDialog.Filter := format( ' EOSIM Experiment (*%s)|*%s',
                                [DataFileExtension,DataFileExtension]) ;
   OpenDialog.Title := 'Load Experiment ' ;

   // Open selected data file
   if OpenDialog.execute then LoadFromFile( OpenDialog.FileName ) ;

   end;


procedure TMainFrm.mnNewExperimentClick(Sender: TObject);
// ---------------------
// Select new experiment
// ---------------------
begin

     // Let use select new experiment
     NewExperimentFrm.Left := MainFrm.Left + 40 ;
     NewExperimentFrm.Top := MainFrm.Top + 80 ;
     if NewExperimentFrm.ShowModal <> mrOK then Exit ;

     if UnSavedData then begin
        if MessageDlg('Existing experiment will be erased! Are you sure?', mtConfirmation,
           [mbYes,mbNo],0) = mrYes then NewExperiment ;
        end
     else NewExperiment ;
     end;


procedure TMainFrm.bStimulationOnClick(Sender: TObject);
// --------------------
// Start nerve stimulus
// --------------------
var
  ChartAnnotation : String ;
begin
     bStimulationOn.Enabled := False ;
     bStimulationOff.Enabled := True ;
     NextStimulusAt := NumPointsInBuf ;

     // Add chart annotation
     if TissueType = tJejunum then begin
        StimFrequency := edStimFrequency.Value ;
        ChartAnnotation := format('Stim %.3gHz',[edStimFrequency.Value]) ;
        AddDrugMarker( ChartAnnotation ) ;
        end
     else begin
        if rbNerve.Checked then AddDrugMarker( 'Stim(nv.):On' )
                           else AddDrugMarker( 'Stim(mu.):On' ) ;
        end;

     end;


procedure TMainFrm.bStimulationOffClick(Sender: TObject);
// --------------------
// Stop nerve stimulus
// --------------------
var
  ChartAnnotation : String ;

begin
     bStimulationOn.Enabled := True ;
     bStimulationOff.Enabled := False ;
     // Add chart annotation
     ChartAnnotation := 'Stim:Off' ;
     AddDrugMarker( ChartAnnotation ) ;

     end;


procedure TMainFrm.bNewExperimentClick(Sender: TObject);
// ---------------------
// Select new experiment
// ---------------------
begin

     // Let use select new experiment
     NewExperimentFrm.Left := MainFrm.Left + 40 ;
     NewExperimentFrm.Top := MainFrm.Top + 80 ;
     if NewExperimentFrm.ShowModal <> mrOK then Exit ;

     if UnSavedData then begin
        if MessageDlg('Existing experiment will be erased! Are you sure?', mtConfirmation,
           [mbYes,mbNo],0) = mrYes then NewExperiment ;
        end
     else NewExperiment ;
     end;


procedure TMainFrm.bFreshReservoirClick(Sender: TObject);
// -----------------------------------------------------------
// Replace solution in reservoir with fresh drug free solution
// -----------------------------------------------------------
var
    i : Integer ;
    ChartAnnotation : String ;
begin
     // Clear drugs
     for i := 0 to NumDrugs-1 do begin
         ReservoirDrugs[i].FinalBathConcentration := 0.0 ;
         ReservoirDrugs[i].DisplayBathConcentration := 0.0 ;
         //ReservoirDrugs[i].BathConcentration := 0.0 ;
         end ;

     // Set salt solution Ca concentration
          // Set salt solution Ca concentration
     if TissueType = tArterialRing then begin
        if NativeInt(cbSolution.Items.Objects[cbSolution.ItemIndex])= ZeroCaSoln then begin
           ReservoirDrugs[iCaBath].FinalBathConcentration := 0.0 ;
           ReservoirDrugs[iCaBath].DisplayBathConcentration := 0.0 ;
           end
        else begin
           ReservoirDrugs[iCaBath].FinalBathConcentration := 2.5E-3 ;
           ReservoirDrugs[iCaBath].DisplayBathConcentration := 2.5E-3 ;
           end ;
        end ;

     ChartAnnotation := 'New Res.' ;
     AddDrugMarker( ChartAnnotation ) ;

     end;


procedure TMainFrm.mnSaveExperimentClick(Sender: TObject);
// -----------------------
// Save experiment to file
// -----------------------
begin

     { Present user with standard Save File dialog box }
     SaveDialog.options := [ofHideReadOnly,ofPathMustExist] ;
     SaveDialog.FileName := '' ;
     SaveDialog.DefaultExt := DataFileExtension ;
     SaveDialog.Filter := format( ' EOSIM Experiment (*%s)|*%s',
                                  [DataFileExtension,DataFileExtension]) ;
     SaveDialog.Title := 'Save Experiment' ;

     if SaveDialog.Execute then SaveToFile( SaveDialog.FileName ) ;

     end ;


procedure TMainFrm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
// -----------------------------------------------
// Check whether user really wants to stop program
// -----------------------------------------------
begin
     if MessageDlg('Stop EOSIM Program! Are you sure?', mtConfirmation,
           [mbYes,mbNo],0) = mrYes then CanClose := True
                                   else CanClose := False ;
     end;


procedure TMainFrm.mnExitClick(Sender: TObject);
// ------------
// Stop Program
// ------------
begin
     Close ;
     end;


procedure TMainFrm.mnContentsClick(Sender: TObject);
// -----------------------
//  Help/Contents menu item
//  -----------------------
begin
     if FileExists(Application.HelpFile) then
        ShellExecute(Handle, 'open', PChar(Application.HelpFile), nil, nil, SW_SHOWNORMAL)
     else ShowMessage('Help file not found: ' + Application.HelpFile);

     end;

procedure TMainFrm.mnSearchClick(Sender: TObject);
// -----------------------
//  Help/Search menu item
//  -----------------------}
begin
     mnContentsClick(Sender);
     end;

procedure TMainFrm.cbAgonistChange(Sender: TObject);

begin
    SetStockConcentrationList( NativeInt(cbAgonist.Items.Objects[cbAgonist.ItemIndex]),
                               cbAgonistStockConc ) ;
    end ;


procedure TMainFrm.SetStockConcentrationList(
          iDrug : Integer ;
          ComboBox : TComboBox ) ;
// ------------------------------------------
// Set list of available stock concentrations
// ------------------------------------------
var
    i : Integer ;
    x : Single ;
begin

     if ComboBox.Items.Count < 1 then Exit ;

//     iDrug := NativeInt(cbAgonist.Items.Objects[cbAgonist.ItemIndex]) ;
     if Drugs[iDrug].Units = 'ml' then
        begin
        // Set up stock soln. concentration lists
        ComboBox.Clear ;
        x := 1.0 ;
        ComboBox.Items.AddObject('1/1 dilution',EncodeConcentration(x));
        x := 0.1 ;
        ComboBox.Items.AddObject('1/10 dilution',EncodeConcentration(x));
        ComboBox.ItemIndex := 0 ;
        end
     else if Drugs[iDrug].Units = 'mg/ml' then
        begin
        // Set up stock soln. concentration lists
        ComboBox.Clear ;
        x := 10000.0 ;
        for i := 4 Downto -3 do
            begin
            ComboBox.Items.AddObject(
            format( '1E%d mg/ml',[i]), EncodeConcentration(x) ) ;
            x := x/10.0 ;
            end ;
        ComboBox.ItemIndex := 3 ;
        end
     else begin
         // Set up stock soln. concentration lists
         ComboBox.Clear ;
         x := 1.0 ;
         for i := 0 Downto -8 do
            begin
            ComboBox.Items.AddObject(
            format( '1E%d M',[i]), EncodeConcentration(x) ) ;
            x := x/10.0 ;
            end ;
         ComboBox.ItemIndex := 3 ;
         end ;

     end;


procedure TMainFrm.cbAntagonistChange(Sender: TObject);
begin
    SetStockConcentrationList( NativeInt(cbAntagonist.Items.Objects[cbAntagonist.ItemIndex]),
                               cbAntagonistStockConc) ;
    end;

procedure TMainFrm.cbDilutionResultChange(Sender: TObject);
// ------------------------
// Dilution results changed
// ------------------------
begin
    SetDilutionEquation ;
    end;

procedure TMainFrm.cbUnknownChange(Sender: TObject);
begin
      SetStockConcentrationList( NativeInt(cbUnknown.Items.Objects[cbUnknown.ItemIndex]),
                                cbUnknownStockConc ) ;
      end;


procedure TMainFrm.edStartTimeKeyPress(Sender: TObject; var Key: Char);
// ------------------
// Start time changed
// ------------------
begin
    if Key = #13 then begin
       sbDisplay.Position := Round(edStartTime.Value) ;
       end;
    end;

procedure TMainFrm.edStimFrequencyKeyPress(Sender: TObject; var Key: Char);
var
  ChartAnnotation : String ;
begin
    if key = chr(13) then begin
       // Add chart annotation
       if TissueType = tJejunum then begin
          if (StimFrequency <> edStimFrequency.Value) and
             (not bStimulationOn.Enabled) then begin
             StimFrequency := edStimFrequency.Value ;
             ChartAnnotation := format('Stim %.3gHz',[edStimFrequency.Value]) ;
             AddDrugMarker( ChartAnnotation ) ;
             end ;
          end ;
       end ;
     end;

procedure TMainFrm.edTDisplayKeyPress(Sender: TObject; var Key: Char);
// -------------------------------
// Display window duration changed
// -------------------------------
begin
    if Key = #13 then UpdateDisplayDuration ;
    end;


procedure TMainFrm.UpdateDisplayDuration ;
// ------------------------------
// Update display window duration
// ------------------------------
begin
    scDisplay.MaxPoints :=  Round(edTDisplay.Value) ;
    scDisplay.XMax := scDisplay.MaxPoints -1 ;
    scDisplay.VerticalCursors[0] := scDisplay.MaxPoints div 2 ;
    if bStop.Enabled then scDisplay.XOffset := sbDisplay.Position
                     else scDisplay.XOffset := -1 ;
    scDisplay.invalidate ;
    end;


procedure TMainFrm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
     case key of
          VK_LEFT : scDisplay.MoveActiveVerticalCursor(-1) ;
          VK_RIGHT : scDisplay.MoveActiveVerticalCursor(1) ;
          end ;
     end;


procedure TMainFrm.SetDilutionEquation ;
begin
    case cbDilutionResult.ItemIndex of
      DilFBC : begin
          lbDilutionEqnNum1.Caption := 'Stock Soln. Conc. (M)';
          lbDilutionEqnNum2.Caption := 'Volume to Add (ml)';
          lbDilutionEqnDen.Caption := 'Bath Volume (ml)';
          edDilNum1.Units := 'M';
          edDilNum2.Units := 'ml';
          edDilDen.Units := 'ml';
          edDilResult.Text := '' ;
          end;
      DilStockC : begin
          lbDilutionEqnNum1.Caption := 'Final Bath Conc. (M)';
          lbDilutionEqnNum2.Caption := 'Bath Volume (ml)';
          lbDilutionEqnDen.Caption := 'Volume to Add (ml)';
          edDilNum1.Units := 'M';
          edDilNum2.Units := 'ml';
          edDilDen.Units := 'ml';
          edDilResult.Text := '' ;
          end;
      DilVAdd : begin
          lbDilutionEqnNum1.Caption := 'Final Bath Conc. (M)';
          lbDilutionEqnNum2.Caption := 'Bath Volume (ml)';
          lbDilutionEqnDen.Caption := 'Stock Soln. Conc. (M)';
          edDilNum1.Units := 'M';
          edDilNum2.Units := 'ml';
          edDilDen.Units := 'M';
          edDilResult.Text := '' ;
          end;
      DilVBath : begin
          lbDilutionEqnNum1.Caption := 'Stock Soln. Conc. (M)';
          lbDilutionEqnNum2.Caption := 'Volume to Add (ml)';
          lbDilutionEqnDen.Caption := 'Final Bath Conc. (M)';
          edDilNum1.Units := 'M';
          edDilNum2.Units := 'ml';
          edDilDen.Units := 'M';
          edDilResult.Text := '' ;
          end;

    end;
end;

end.
