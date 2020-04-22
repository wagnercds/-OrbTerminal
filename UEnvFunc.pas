unit UEnvFunc;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, StdCtrls, Spin, Buttons, UTerm, Psock,
  NMsmtp, LibString;

type
  TforEnvFunc = class(TForm)
    Panel1: TPanel;
    pgcGPS: TPageControl;
    TabSheet1: TTabSheet;
    cbGPSVel: TRadioGroup;
    cbGPSTamByte: TRadioGroup;
    cbGPSStopBits: TRadioGroup;
    cbGPSParity: TRadioGroup;
    GroupBox1: TGroupBox;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    speTempGGA: TSpinEdit;
    GroupBox2: TGroupBox;
    Label2: TLabel;
    speTempGLL: TSpinEdit;
    GroupBox10: TGroupBox;
    Label3: TLabel;
    speTempGSA: TSpinEdit;
    GroupBox5: TGroupBox;
    Label4: TLabel;
    speTempGSV: TSpinEdit;
    GroupBox6: TGroupBox;
    Label5: TLabel;
    speTempRMC: TSpinEdit;
    GroupBox7: TGroupBox;
    Label6: TLabel;
    speTempVTG: TSpinEdit;
    GroupBox8: TGroupBox;
    Button1: TButton;
    Button2: TButton;
    botEnv: TBitBtn;
    BitBtn2: TBitBtn;
    TabSheet2: TTabSheet;
    rgrOrbModem: TRadioGroup;
    edLigCel: TEdit;
    edDTMF: TEdit;
    chkbFecFor: TCheckBox;
    Label7: TLabel;
    TabSheet3: TTabSheet;
    Label8: TLabel;
    edIDOrbStar: TEdit;
    TabSheet4: TTabSheet;
    Edit1: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure botEnvClick(Sender: TObject);
    procedure edLigCelKeyPress(Sender: TObject; var Key: Char);
    procedure rgrOrbModemClick(Sender: TObject);
    procedure edDTMFKeyPress(Sender: TObject; var Key: Char);
    procedure edIDOrbStarKeyPress(Sender: TObject; var Key: Char);
    procedure TabSheet1Enter(Sender: TObject);
    procedure TabSheet2Enter(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  forEnvFunc: TforEnvFunc;

implementation

uses UDisp;

{$R *.dfm}

procedure TforEnvFunc.Button1Click(Sender: TObject);
begin
   cbGPSVel.ItemIndex := 1;
   cbGPSTamByte.ItemIndex := 1;
   cbGPSStopBits.ItemIndex := 1;
   cbGPSParity.ItemIndex := 0;
   speTempGGA.Value := 1;
   speTempGLL.Value := 0;
   speTempGSA.Value := 0;
   speTempGSV.Value := 0;
   speTempRMC.Value := 1;
   speTempVTG.Value := 0;
end;

procedure TforEnvFunc.Button2Click(Sender: TObject);
begin
   cbGPSVel.ItemIndex := 1;
   cbGPSTamByte.ItemIndex := 1;
   cbGPSStopBits.ItemIndex := 1;
   cbGPSParity.ItemIndex := 0;
   speTempGGA.Value := 0;
   speTempGLL.Value := 0;
   speTempGSA.Value := 0;
   speTempGSV.Value := 0;
   speTempRMC.Value := 1;
   speTempVTG.Value := 0;
end;

procedure TforEnvFunc.botEnvClick(Sender: TObject);
var
 Aux, Aux2 : string;
 bAux : boolean;
begin
   case pgcGPS.ActivePageIndex of
      // Enviar comando para o OrbModem
      2 : begin
             forTerm.Time.Enabled := false;
             case rgrOrbModem.ItemIndex of
                // Discar
                0 : begin
                       if edLigCel.GetTextLen > 0 then
                       begin
                          forTerm.memMens.Lines.Add('Conectando a ' + edLigCel.Text + ' ...');
                          if forTerm.Port.LigCel(edLigCel.Text) then
                             forTerm.memMens.Lines.Add('Conectado !')
                          else
                          begin
                             Application.MessageBox('Não foi possível completar a ligação !',
                                                    'Atenção', MB_OK + Mb_IconInformation);
                             forTerm.memMens.Lines.Add('Desconectado');
                          end
                       end
                       else
                          Application.MessageBox('Digite um número de telefone !', 'Atenção', MB_OK + MB_IconError);
                    end;
                // Desligamento da base
                1 : begin
                       if forTerm.Port.DesCel then
                          forTerm.memMens.Lines.Add('Desconectado')
                       else
                          Application.MessageBox('Base não respondeu ao comando !',
                                                 'Atenção', MB_OK + MB_IconInformation);
                    end;
                // Enviar tom
                2 : begin
                       forTerm.memMens.Lines.Add('Enviando DTMF (' + edDTMF.Text + ')');
                       if not forTerm.Port.EnvDTMF(edDTMF.Text) then
                          Application.MessageBox('Não foi possivel enviar o DTMF !',
                                                 'Atenção', MB_OK + MB_IconInformation);
                    end;
             end;
             forTerm.Time.Enabled := true;
             if chkbFecFor.Checked then
                Close;
          end;
      3 : begin
             forTerm.memMens.Lines.Clear;
             forTerm.memMens.Lines.Add('Conexão PPP');
             botEnv.ModalResult := mrNone;
             forTerm.Time.Enabled := false;
             forTerm.memMens.Lines.Add('');
             forTerm.rgrTipByte.ItemIndex := 1;
             forTerm.chkbASCII.Checked := true;
             forTerm.memMens.Lines.Add('Desligando ECO...');
             forTerm.Port.EnvMens('ATE0' + #13 + #10);
             if forTerm.Port.EnvMensEspResp(10000,'OK') then
             begin
                forTerm.memMens.Lines.Add('OK');
                forTerm.memMens.Lines.Add('Conectando ...');
                forTerm.Port.EnvMens('ATDT #777' + #13 + #10);
                if forTerm.Port.EnvMensEspResp(30000, 'CONNECT') then
                begin
                   forTerm.memMens.Lines.Add('CONECTADO');
                   forTerm.memMens.Lines.Add('Linha 1');
                   forTerm.Port.EnvMens(#126 + #255 + #125 + #35 + #192 + #33 + #125 +
                                        #33 + #125 + #32 + #125 + #32 + #125 + #42 +
                                        #125 + #37 + #125 + #38 + #125 + #32 + #125 +
                                        #32 + #125 + #33 + #125 + #32 + #172 + #51 + #126);
                   forTerm.memMens.Lines.Add('Leitura 1');
                   forTerm.memMens.Lines.Add('');
                   Aux := forTerm.Port.LerPort;
                   while Aux = '' do
                   begin
                      Aux := forTerm.Port.LerPort;
                      Application.ProcessMessages;
                   end;
                   if Pos(#192 + #33 + #125 + #34, Aux) > 0 then
                   begin
                      while Pos(#192 + #33 + #125 + #33, Aux) = 0 do
                      begin
                         while Aux2 = '' do
                         begin
                            Aux2 := forTerm.Port.LerPort;
                            Application.ProcessMessages;
                         end;
                         Aux := Aux + Aux2;
                         Aux2 := '';
                      end;
                   end;
                   forTerm.ProsMens(Aux);
                   forTerm.memMens.Lines.Add('Linha 2');
                   forTerm.Port.EnvMens(#126 + #255 + #125 + #35 + #192 + #33 +
                                        #125 + #34 + #125 + #34 + #125 + #32 +
                                        #125 + #52 + #125 + #34 + #125 + #38 +
                                        #125 + #32 + #125 + #32 + #125 + #32 +
                                        #125 + #32 + #125 + #35 + #125 + #36 +
                                        #192 + #35 + #125 + #37 + #125 + #38 +
                                        #75 + #185 + #125 + #52 + #140 + #231 +
                                        #143 + #126);
                   Sleep(250);
                   forTerm.memMens.Lines.Add('Leitura 2');
                   forTerm.memMens.Lines.Add('');
                   Aux := forTerm.Port.LerPort;
                   forTerm.ProsMens(Aux);
                   forTerm.memMens.Lines.Add('Linha 3');
                   forTerm.Port.EnvMens(#126 + #255 + #125 + #35 + #192 + #35 +
                                        #125 + #33 + #125 + #32 + #125 + #32 +
                                        #42 + #125 + #59 + #49 + #51 + #57 + #55 +
                                        #49 + #54 + #56 + #52 + #51 + #54 + #64 +
                                        #118 + #112 + #110 + #99 + #97 + #114 +
                                        #115 + #121 + #115 + #116 + #101 + #109 +
                                        #46 + #99 + #111 + #109 + #125 + #41 +
                                        #101 + #115 + #112 + #101 + #114 + #97 +
                                        #110 + #99 + #97 + #50 + #60 + #126);
                   Sleep(2000);
                   forTerm.memMens.Lines.Add('Linha 3 +');
                   forTerm.Port.EnvMens(#126 + #255 + #125 + #35 + #192 + #35 +
                                        #125 + #33 + #125 + #32 + #125 + #32 +
                                        #42 + #125 + #59 + #49 + #51 + #57 + #55 +
                                        #49 + #54 + #56 + #52 + #51 + #54 + #64 +
                                        #118 + #112 + #110 + #99 + #97 + #114 +
                                        #115 + #121 + #115 + #116 + #101 + #109 +
                                        #46 + #99 + #111 + #109 + #125 + #41 +
                                        #101 + #115 + #112 + #101 + #114 + #97 +
                                        #110 + #99 + #97 + #50 + #60 + #126);
                   Sleep(250);
                   forTerm.memMens.Lines.Add('Leitura 3');
                   forTerm.memMens.Lines.Add('');
                   {Aux := forTerm.Port.LerPort;
                   forTerm.ProsMens(Aux);
                   forTerm.memMens.Lines.Add('Linha 4');
                   forTerm.Port.EnvMens(#126 + #255 + #125 + #35 + #128 + #33 +
                                        #125 + #33 + #125 + #32 + #125 + #32 +
                                        #125 + #54 + #125 + #35 + #125 + #38 +
                                        #125 + #32 + #125 + #32 + #125 + #32 +
                                        #125 + #32 + #129 + #125 + #38 + #125 +
                                        #32 + #125 + #32 + #125 + #32 + #125 +
                                        #32 + #131 + #125 + #38 + #125 + #32 +
                                        #125 + #32 + #125 + #32 + #125 + #32 +
                                        #125 + #34 + #236 + #126);
                   Sleep(1000);
                   forTerm.memMens.Lines.Add('Leitura 4');
                   forTerm.memMens.Lines.Add('');
                   Aux := forTerm.Port.LerPort;
                   forTerm.ProsMens(Aux);
                   forTerm.memMens.Lines.Add('Linha 5');
                   forTerm.Port.EnvMens(#126 + #255 + #125 + #35 + #128 + #33 +
                                        #125 + #36 + #186 + #125 + #32 + #125 +
                                        #42 + #125 + #37 + #125 + #38 + #125 +
                                        #42 + #125 + #32 + #125 + #32 + #125 +
                                        #38 + #85 + #128 + #126);
                   Sleep(1000);
                   forTerm.memMens.Lines.Add('Leitura 5');
                   forTerm.memMens.Lines.Add('');
                   Aux := forTerm.Port.LerPort;
                   forTerm.ProsMens(Aux);}
                   forTerm.memMens.Lines.Add('Final !');
                end
                else
                   forTerm.memMens.Lines.Add('Não conectou !');
             end
             else
                forTerm.memMens.Lines.Add('Não deligou o ECO !');
             forTerm.Time.Enabled := true;
          end;
   end;
end;

procedure TforEnvFunc.edLigCelKeyPress(Sender: TObject; var Key: Char);
begin
   if not ((Key in ['0'..'9']) or (Key = #8) or (Key = ',')) then
   begin
      Application.MessageBox('Digite somente números !','Atenção',MB_OK + MB_IconError);
      Key := #0;
      edLigCel.SetFocus;
   end;
end;

procedure TforEnvFunc.rgrOrbModemClick(Sender: TObject);
begin
   case rgrOrbModem.ItemIndex of
      0 : begin
             edLigCel.Enabled := true;
             edDTMF.Enabled := false;
          end;
      1 : begin
             edLigCel.Enabled := false;
             edDTMF.Enabled := false;
          end;
      2 : begin
             edLigCel.Enabled := false;
             edDTMF.Enabled := true;
          end;
   end;
end;

procedure TforEnvFunc.edDTMFKeyPress(Sender: TObject; var Key: Char);
begin
   if not ((Key in ['0'..'9']) or (Key = #8) or (Key in ['A'..'D'])) then
   begin
      Application.MessageBox('Digite somente números !','Atenção',MB_OK + MB_IconError);
      Key := #0;
      edLigCel.SetFocus;
   end;
end;

procedure TforEnvFunc.edIDOrbStarKeyPress(Sender: TObject; var Key: Char);
begin
   if not ((Key in ['0'..'9']) or (Key = #8)) then
   begin
      Application.MessageBox('Digite somente números !','Atenção',MB_OK + MB_IconError);
      Key := #0;
      edIDOrbStar.SetFocus;
   end;
end;

procedure TforEnvFunc.TabSheet1Enter(Sender: TObject);
begin
   botEnv.ModalResult := mrOK;
end;

procedure TforEnvFunc.TabSheet2Enter(Sender: TObject);
begin
   botEnv.ModalResult := mrNone;
end;

end.
