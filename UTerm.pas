unit UTerm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons, UDisp, LibString, IniFiles,
  ScktComp, Psock, NMsmtp;

type
  TforTerm = class(TForm)
    memMens: TMemo;
    Panel1: TPanel;
    cbPort: TComboBox;
    Label1: TLabel;
    botAbrPort: TBitBtn;
    Time: TTimer;
    botDel: TBitBtn;
    rgrTipByte: TRadioGroup;
    botMens: TBitBtn;
    botFunc: TBitBtn;
    notPortConf: TNotebook;
    Label2: TLabel;
    Label5: TLabel;
    cbVel: TComboBox;
    cbTamByte: TComboBox;
    Label3: TLabel;
    cbParity: TComboBox;
    Label4: TLabel;
    cbStopBits: TComboBox;
    Label6: TLabel;
    edPort: TEdit;
    labEnd: TLabel;
    edEnd: TEdit;
    ssk: TServerSocket;
    csk: TClientSocket;
    chkbLigRTS: TCheckBox;
    chkbLigDTR: TCheckBox;
    chkbASCII: TCheckBox;
    chkbLigRTSDTR: TCheckBox;
    Timer1: TTimer;
    cbEnum: TCheckBox;
    cbSaltar: TCheckBox;
    procedure botAbrPortClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TimeTimer(Sender: TObject);
    procedure memMensKeyPress(Sender: TObject; var Key: Char);
    procedure botDelClick(Sender: TObject);
    procedure botMensClick(Sender: TObject);
    procedure botFuncClick(Sender: TObject);
    procedure cbPortChange(Sender: TObject);
    procedure edPortKeyPress(Sender: TObject; var Key: Char);
    procedure sskClientConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure sskClientDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure sskClientRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure cskConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure cskDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure cskRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure cskError(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure chkbLigRTSClick(Sender: TObject);
    procedure chkbLigDTRClick(Sender: TObject);
    procedure rgrTipByteClick(Sender: TObject);
    procedure chkbLigRTSDTRClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    iCont : word;
    { Private declarations }
  public
    procedure ProsMens(Mens : string);
    { Public declarations }
  end;

var
  forTerm: TforTerm;

implementation

uses UMens, UEnvFunc;

Const Versao = '1.9.0';

{$R *.dfm}

procedure TforTerm.botAbrPortClick(Sender: TObject);
var
 TamByte, Parity, StopBits, Vel : cardinal;
 WinIni : TIniFile;
 Aux : integer;
begin
   case botAbrPort.Tag of
      0 : begin
             case cbPort.ItemIndex of
                0..3,6,7 : begin
                          // Verifica o tamanho do byte
                          case cbTamByte.ItemIndex of
                             0 : TamByte := 4;
                             1 : TamByte := 5;
                             2 : TamByte := 6;
                             3 : TamByte := 7;
                             4 : TamByte := 8;
                          end;
                          // Verifica  o tipo de Paridade
                          case cbParity.ItemIndex of
                             0 : Parity := EVENPARITY;
                             1 : Parity := ODDPARITY;
                             2 : Parity := NOPARITY;
                             3 : Parity := MARKPARITY;
                             4 : Parity := SPACEPARITY;
                          end;
                          // Verifica o tipo de stopbit
                          case cbStopBits.ItemIndex of
                             0 : StopBits := ONESTOPBIT;
                             1 : StopBits := ONE5STOPBITS;
                             2 : StopBits := TWOSTOPBITS;
                          end;
                          // Verifica a velocidade
                          case cbVel.ItemIndex of
                             0 : Vel := CBR_110;
                             1 : Vel := CBR_300;
                             2 : Vel := CBR_1200;
                             3 : Vel := CBR_2400;
                             4 : Vel := CBR_4800;
                             5 : Vel := CBR_9600;
                             6 : Vel := CBR_19200;
                             7 : Vel := CBR_38400;
                             8 : Vel := CBR_57600;
                             9 : Vel := CBR_115200;
                             10 : Vel := CBR_128000;
                             11 : Vel := CBR_256000;
                             12 : Vel := 460800;
                          end;
                          // Coloca a porta
                          case cbPort.ItemIndex of
                             6 : Aux := 1;
                             7 : Aux := 6;
                             else
                                Aux := cbPort.ItemIndex + 1;
                          end;
                          if Port.AbrPort(Aux,TamByte,Parity,StopBits,Vel) = 0 then
                          begin
                             Caption := 'OrbTerminal - versão ' + Versao + ' (' +
                                        cbPort.Text + ',' + cbVel.Text + ',' +
                             cbParity.Text + ',' + cbStopBits.Text + ',' + cbTamByte.Text + ')';
                             Time.Enabled := true;
                             botAbrPort.Tag := 1;
                             botAbrPort.Caption := '&Fechar Porta';
                             botMens.Enabled := true;
                             botFunc.Enabled := true;
                             chkbLigRTS.Enabled := true;
                             chkbLigDTR.Enabled := true;
                             chkbLigRTSDTR.Enabled := true;
                             WinIni := TIniFile.Create('OrbTerminal.INI');
                             WinIni.WriteInteger('Conf','Port',cbPort.ItemIndex);
                             WinIni.WriteInteger('Conf','Vel',cbVel.ItemIndex);
                             WinIni.WriteInteger('Conf','Parity',cbParity.ItemIndex);
                             WinIni.WriteInteger('Conf','StopBits',cbStopBits.ItemIndex);
                             WinIni.WriteInteger('Conf','TamByte',cbTamByte.ItemIndex);
                             WinIni.Free;
                          end
                          else
                             Application.MessageBox('Não foi possível abrir a porta selecionada !',
                                                    'Atenção', MB_OK + MB_IconError);
                          if cbPort.ItemIndex = 6 then
                          begin
                             if not Port2.AbrPort(2,TamByte,Parity,StopBits,Vel) = 0 then
                                Application.MessageBox('Não foi possível abrir a porta COM2 !',
                                                       'Atenção', MB_OK + MB_IconError);
                          end;
                       end;
                4 : begin
                       if Trim(edPort.Text) <> '' then
                       begin
                          ssk.Port := StrToInt(edPort.Text);
                          ssk.Active := true;
                          Caption := 'OrbTerminal - versão ' + Versao + ' (Soquete TCP/IP(Servidor) Porta : ' +
                                     edPort.Text + ')';
                          botAbrPort.Tag := 1;
                          botAbrPort.Caption := '&Fechar Porta';
                          botMens.Enabled := true;
                          WinIni := TIniFile.Create('OrbTerminal.INI');
                          WinIni.WriteInteger('Conf','Port',cbPort.ItemIndex);
                          WinIni.WriteString('Conf', 'PortTCP',edPort.Text);
                          WinIni.Free;
                       end
                       else
                          Application.MessageBox('Selecione uma porta !', 'Atenção',
                                                 MB_OK + MB_IconError);
                    end;
                5 : begin
                       if (Trim(edPort.Text) <> '') and (Trim(edEnd.Text) <> '') then
                       begin
                          csk.Port := StrToInt(edPort.Text);
                          csk.Address := Trim(edEnd.Text);
                          csk.Active := true;
                          Caption := 'OrbTerminal - versão ' + Versao + ' (Soquete TCP/IP Porta(Cliente) : ' +
                                     edPort.Text + ')';
                          botAbrPort.Tag := 1;
                          botAbrPort.Caption := '&Fechar Porta';
                          botMens.Enabled := true;
                          WinIni := TIniFile.Create('OrbTerminal.INI');
                          WinIni.WriteInteger('Conf','Port',cbPort.ItemIndex);
                          WinIni.WriteString('Conf', 'PortTCP',edPort.Text);
                          WinIni.WriteString('Conf','End',edEnd.Text);
                          WinIni.Free;
                       end
                       else
                          Application.MessageBox('Selecione uma porta e um endereço !',
                                                 'Atenção', MB_OK + MB_IconError);
                    end;
             end;
          end;
      1 : begin
             Port.FecPort;
             if cbPort.ItemIndex = 6 then
                Port2.FecPort;
             Caption := 'OrbTerminal - versão ' + Versao;
             Time.Enabled := false;
             botAbrPort.Tag := 0;
             botAbrPort.Caption := '&Abrir Porta';
             botMens.Enabled := false;
             botFunc.Enabled := false;
             chkbLigRTS.Enabled := false;
             chkbLigDTR.Enabled := false;
             chkbLigRTSDTR.Enabled := false;
             chkbLigRTS.Checked := false;
             chkbLigDTR.Checked := false;
             chkbLigRTSDTR.Checked := false;
             ssk.Active := false;
             csk.Active := false;
          end;
   end;
end;

procedure TforTerm.FormCreate(Sender: TObject);
var
 WinIni : TIniFile;
begin
   Port := TPort.Create;
   Port2 := TPort.Create;
   WinIni := TIniFile.Create('OrbTerminal.INI');
   cbPort.ItemIndex := WinIni.ReadInteger('Conf','Port',0);
   cbPortChange(cbPort);
   cbVel.ItemIndex := WinIni.ReadInteger('Conf','Vel',4);
   cbParity.ItemIndex := WinIni.ReadInteger('Conf','Parity',2);
   cbStopBits.ItemIndex := WinIni.ReadInteger('Conf','StopBits',0);
   cbTamByte.ItemIndex := WinIni.ReadInteger('Conf','TamByte',4);
   edPort.Text := WinIni.ReadString('Conf', 'PortTCP','');
   edEnd.Text := WinIni.ReadString('Conf','End', '');
   botDelClick(botDel);
   Caption := 'OrbTerminal - versão ' + Versao;
   WinIni.Free;
   iCont := 0;
end;

procedure TforTerm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   Port.Free;
   Port2.Free;
   ssk.Active := false;
   csk.Active := false;
end;

procedure TforTerm.TimeTimer(Sender: TObject);
var
 Aux : string;
begin
   Time.Enabled := false;
   Aux := Port.LerPort;
   if Aux <> '' then
   begin
      if cbPort.ItemIndex = 6 then
      begin
         memMens.Lines.Add('---< COM1 >---');
         memMens.Lines.Add('');
      end;
      ProsMens(Aux);
   end;
   if cbPort.ItemIndex = 6 then
   begin
      Aux := Port2.LerPort;
      if Aux <> '' then
      begin
         memMens.Lines.Add('---< COM2 >---');
         memMens.Lines.Add('');
         ProsMens(Aux);
      end;
   end;
   Time.Enabled := true;
end;

procedure TforTerm.memMensKeyPress(Sender: TObject; var Key: Char);
begin
   // Verifica se a porta serial está aberta
   if Time.Enabled then
   begin
      if Port.PortAbr then
      begin
         Time.Enabled := false;
         if not Port.EnvMens(Key) then
            Application.MessageBox('Não foi possível transmitir o caracter !','Atenção' ,
                                   MB_OK + MB_IconError);
         Time.Enabled := true;
      end
      else
      begin
         Application.MessageBox('A porta não foi aberta !', 'Atenção', MB_OK + MB_IconError);
         Key := #0;
      end;
   end
   else
   // Verifica se é a porta TCP de servidor está aberta
   if ssk.Active then
   begin
      if ssk.Socket.ActiveConnections > 0 then
         ssk.Socket.Connections[0].SendText(Key)
      else
      begin
         Application.MessageBox('Não existe nenhum cliente conectado !', 'Atenção',
                                MB_OK + MB_IconError);
         Key := #0;
      end;
   end
   else
   // Verifica se é a porta TCP de cliente que está aberta
   if csk.Active then
      csk.Socket.SendText(Key)
   else
   begin
      Application.MessageBox('Não existe nenhuma porta aberta !', 'Atenção',
                             MB_OK + MB_IconError);
      Key := #0
   end;
end;

procedure TforTerm.botDelClick(Sender: TObject);
var
 Aux : boolean;
begin
   Aux := Time.Enabled;
   Time.Enabled := false;
   memMens.Clear;
   memMens.Lines.Add('OrbTerminal versão ' + Versao);
   memMens.Lines.Add('Desenvolvido por : Wagner Carmo da Silva');
   memMens.Lines.Add('');
   Time.Enabled := Aux;
   iCont := 0;
end;

procedure TforTerm.botMensClick(Sender: TObject);
var
 AuxEnv : string;
begin
   forMens := TforMens.Create(Self);
   forMens.ShowModal;
   if (forMens.ModalResult = MROK) and (Trim(forMens.edMens.Text) <> '') then
   begin
      AuxEnv := forMens.edMens.Text;
      if ConvHexaDecBin(AuxEnv) then
      begin
         // Verifica se é para transmitir pela porta serial
         if Time.Enabled then
         begin
            if not Port.EnvMens(AuxEnv) then
               Application.MessageBox('Não foi possível enviar o a mensagem !', 'Atenção',
                                      MB_OK + MB_IconError);
         end
         else
         // Verifica se é para transmitir pelo TCP Servidor
         if ssk.Active then
            ssk.Socket.Connections[0].SendText(AuxEnv)
         else
         // Verifica se é para transmitir pelo TCP Cliente
         if csk.Active then
            csk.Socket.SendText(AuxEnv);
      end
      else
         Application.MessageBox('Texto inválido !', 'Atenção', MB_OK + MB_IconError);
   end;
   forMens.Free;
end;

procedure TforTerm.botFuncClick(Sender: TObject);
var
 Aux : string;
 iAux : integer;
begin
   forEnvFunc := TforEnvFunc.Create(Self);
   forEnvFunc.ShowModal;
   if forEnvFunc.ModalResult = MROK then
   begin
      botDelClick(botDel);
      botDel.Enabled := false;
      botAbrPort.Enabled := false;
      botMens.Enabled := false;
      botFunc.Enabled := false;
      memMens.ReadOnly := true;
      case forEnvFunc.pgcGPS.ActivePageIndex of
         0 : begin
                memMens.Lines.Add('Configurando Rikaline GPS - 6010');
                iAux := memMens.Lines.Add('#');
                // Configurando a linha GGA
                if Port.EnvMens(CheckSumNMEA('$PSRF103,00,00,' +
                                FormatFloat('00',forEnvFunc.speTempGGA.Value) +
                                ',01*') + #13 + #10) then
                begin
                   // Configurando a linha GLL
                   memMens.Lines.Strings[iAux] := '##';
                   Port.EnvMens(CheckSumNMEA('$PSRF103,01,00,' +
                                FormatFloat('00',forEnvFunc.speTempGLL.Value) +
                                ',01*') + #13 + #10);
                   // Configuramdo a linha GSA
                   memMens.Lines.Strings[iAux] := '###';
                   Port.EnvMens(CheckSumNMEA('$PSRF103,02,00,' +
                                FormatFloat('00',forEnvFunc.speTempGSA.Value) +
                                ',01*') + #13 + #10);
                   // Configurando a linha GSV
                   memMens.Lines.Strings[iAux] := '####';
                   Port.EnvMens(CheckSumNMEA('$PSRF103,03,00,' +
                                FormatFloat('00',forEnvFunc.speTempGSV.Value) +
                                ',01*') + #13 + #10);
                   // Configurando a linha RMC
                   memMens.Lines.Strings[iAux] := '#####';
                   Port.EnvMens(CheckSumNMEA('$PSRF103,04,00,' +
                                FormatFloat('00',forEnvFunc.speTempRMC.Value) +
                                ',01*') + #13 + #10);
                   // Configurando a linha VTG
                   memMens.Lines.Strings[iAux] := '######';
                   Port.EnvMens(CheckSumNMEA('$PSRF103,05,00,' +
                                FormatFloat('00',forEnvFunc.speTempVTG.Value) +
                                ',01*') + #13 + #10);
                   // Configurando propriedades do GPS
                   memMens.Lines.Strings[iAux] := '#######';
                   Aux := '$PSRF100,1,';
                   case forEnvFunc.cbGPSVel.ItemIndex of
                      0 : Aux := Aux + '4800,';
                      1 : Aux := Aux + '9600,';
                      2 : Aux := Aux + '19200,';
                      3 : Aux := Aux + '38400,';
                   end;
                   case forEnvFunc.cbGPSTamByte.ItemIndex of
                      0 : Aux := Aux + '7,';
                      1 : Aux := Aux + '8,';
                   end;
                   case forEnvFunc.cbGPSStopBits.ItemIndex of
                      0 : Aux := Aux + '0,';
                      1 : Aux := Aux + '1,';
                   end;
                   case forEnvFunc.cbGPSParity.ItemIndex of
                      0 : Aux := Aux + '0*';
                      1 : Aux := Aux + '2*';
                      2 : Aux := Aux + '1*';
                   end;
                   Port.EnvMens(CheckSumNMEA(Aux) + #13 + #10);
                   botDelClick(botDel);
                   Application.MessageBox('Operação terminada com sucesso !',
                                          'Atenção', MB_OK + MB_IconInformation);
                end
                else
                   Application.MessageBox('Não foi possível enviar o comando !',
                            'Atenção', MB_OK + MB_IconError);
             end;
         // Gravando ID do OrbStar
         1 : begin
                if Length(Trim(forEnvFunc.edIDOrbStar.Text)) > 0 then
                begin
                   memMens.Lines.Add('Enviando ID : ' + forEnvFunc.edIDOrbStar.Text +
                                     ' para o OrbStar');
                   memMens.Lines.Add('');
                   Port.EnvMens('$GPORBID,' + FormatFloat('00000',
                                StrToInt(forEnvFunc.edIDOrbStar.Text)) + #13);
                end
                else
                   Application.MessageBox('Não foi digitado nenhum ID !', 'Atenção',
                                          MB_OK + MB_IconError);
             end;
      end;
      botDel.Enabled := true;
      botAbrPort.Enabled := true;
      botMens.Enabled := true;
      botFunc.Enabled := true;
      memMens.ReadOnly := false;
   end;
   forEnvFunc.Free;
end;

procedure TforTerm.cbPortChange(Sender: TObject);
begin
   case cbPort.ItemIndex of
      0..3,6,7  : notPortConf.PageIndex := 0;
      4 : begin
             notPortConf.PageIndex := 1;
             labEnd.Visible := false;
             edEnd.Visible := false;
          end;
      5 : begin
             notPortConf.PageIndex := 1;
             labEnd.Visible := true;
             edEnd.Visible := true;
          end;
   end;
   // Verifica se a porta está aberta para fechar
   if botAbrPort.Tag = 1 then
      botAbrPortClick(botAbrPort);
end;

procedure TforTerm.edPortKeyPress(Sender: TObject; var Key: Char);
begin
   // Obriga o usuário digitar somente valores numéricos
   if not ((Key in ['0'..'9']) or (Key = #8)) then
   begin
      Application.MessageBox('Digite somente números !','Atenção',MB_OK + MB_IconError);
      Key := #0;
      edPort.SetFocus;
   end;
end;

procedure TforTerm.sskClientConnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   memMens.Lines.Add('Conectado : ' + Socket.RemoteHost + '(' +  Socket.RemoteAddress + ')');
   memMens.Lines.Add('');
end;

procedure TforTerm.sskClientDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   memMens.Lines.Add('Desconectado : ' + Socket.RemoteHost + '(' +
                     Socket.RemoteAddress + ')');
   memMens.Lines.Add('');
end;

procedure TforTerm.sskClientRead(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   ProsMens(Socket.ReceiveText + IntToStr(Socket.SocketHandle));
end;

procedure TforTerm.ProsMens(Mens : string);
var
 Loop : integer;
begin
   // Verifica se tem que numerar as linhas recebidas
   if cbEnum.Checked then
   begin
      Inc(iCont);
      memMens.Lines.Strings[memMens.Lines.Count - 1] := memMens.Lines.Strings[memMens.Lines.Count - 1] +
                                                        '(' +
                                                        IntToStr(iCont) +
                                                        ')';
   end;
   case rgrTipByte.ItemIndex of
      0 : begin

          end;
      1 : begin
             for Loop := 1 to Length(Mens) do
             begin
                memMens.Lines.Strings[memMens.Lines.Count - 1] :=
                memMens.Lines.Strings[memMens.Lines.Count - 1] + ' 0x' +
                IntToHex(integer(Mens[Loop]), 2);
                if chkbASCII.Checked then
                   memMens.Lines.Strings[memMens.Lines.Count - 1] :=
                   memMens.Lines.Strings[memMens.Lines.Count - 1] +
                   '-' + Mens[Loop];
             end;
          end;
      2 : begin
             for Loop := 1 to Length(Mens) do
             begin
                memMens.Lines.Strings[memMens.Lines.Count - 1] :=
                memMens.Lines.Strings[memMens.Lines.Count - 1] + ' ' +
                FormatFloat('000', integer(Mens[Loop]));
                if chkbASCII.Checked then
                   memMens.Lines.Strings[memMens.Lines.Count - 1] :=
                   memMens.Lines.Strings[memMens.Lines.Count - 1] +
                   '-' + Mens[Loop];
             end;
          end;
      3 : begin
             for Loop := 1 to Length(Mens) do
             begin
                memMens.Lines.Strings[memMens.Lines.Count - 1] :=
                memMens.Lines.Strings[memMens.Lines.Count - 1] + ' 0b' +
                CharToBin(Mens[Loop]);
                if chkbASCII.Checked then
                   memMens.Lines.Strings[memMens.Lines.Count - 1] :=
                   memMens.Lines.Strings[memMens.Lines.Count - 1] +
                   '-' + Mens[Loop];
             end;
          end;
   end;
   if cbSaltar.Checked then
      memMens.Lines.Add('');
end;

procedure TforTerm.cskConnect(Sender: TObject; Socket: TCustomWinSocket);
begin
   memMens.Lines.Add('Conectado ...');
   memMens.Lines.Add('');
end;

procedure TforTerm.cskDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   memMens.Lines.Add('Desconectado ...');
   memMens.Lines.Add('');
   Caption := 'OrbTerminal - versão ' + Versao;
   botAbrPort.Tag := 0;
   botAbrPort.Caption := '&Abrir Porta';
   botMens.Enabled := false;
   botFunc.Enabled := false;
end;

procedure TforTerm.cskRead(Sender: TObject; Socket: TCustomWinSocket);
begin
   ProsMens(Socket.ReceiveText);
end;

procedure TforTerm.cskError(Sender: TObject; Socket: TCustomWinSocket;
  ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
   if ErrorEvent = eeConnect then
   begin
      Application.MessageBox('Não foi possivel realizar a conexão !', 'Atenção',
                             MB_OK + MB_IconError);
      ErrorCode := 0;
      botAbrPortClick(botAbrPort);
   end;
end;

procedure TforTerm.chkbLigRTSClick(Sender: TObject);
begin
   if chkbLigRTS.Checked then
      Port.LigRTS
   else
      Port.DesRTS;
end;

procedure TforTerm.chkbLigDTRClick(Sender: TObject);
begin
   if chkbLigDTR.Checked then
      Port.LigDTR
   else
      Port.DesDTR;
end;

procedure TforTerm.rgrTipByteClick(Sender: TObject);
begin
   if rgrTipByte.ItemIndex = 0 then
      chkbASCII.Enabled := false
   else
      chkbASCII.Enabled := true;
end;

procedure TforTerm.chkbLigRTSDTRClick(Sender: TObject);
begin
   if chkbLigRTSDTR.Checked then
   begin
      Port.LigDTR;
      Port.LigRTS;
      chkbLigRTS.Checked := true;
      chkbLigDTR.Checked := true;
   end
   else
   begin
      Port.DesDTR;
      Port.DesRTS;
      chkbLigRTS.Checked := false;
      chkbLigDTR.Checked := false;
   end;
end;

procedure TforTerm.Timer1Timer(Sender: TObject);
begin
   if ssk.Socket.ActiveThreads > 0 then
   begin
      if ssk.Socket.Connections[0].ReceiveLength > 0 then
      begin
         ProsMens(ssk.Socket.Connections[0].ReceiveText);
         Application.ProcessMessages;
      end;
   end;
end;

procedure TforTerm.Button1Click(Sender: TObject);
var
 Loop : integer;
begin
   for Loop := 0 to ssk.Socket.ActiveConnections - 1 do
   begin
      memMens.Lines.Add(IntToStr(ssk.Socket.Connections[Loop].SocketHandle))
   end;
end;

end.
