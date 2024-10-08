unit uCadastro;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.UI.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.FMXUI.Wait,
  FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat;

type
   TUsuario = record
    ID: Integer;
    login, senha: string;
   end;

  Tfrm_cadastro = class(TForm)
    Layout1: TLayout;
    Label1: TLabel;
    Label2: TLabel;
    edt_criarLogin: TEdit;
    Label3: TLabel;
    edt_criarSenha: TEdit;
    btn_salvaConta: TButton;
    FDQ_Usuarios: TFDQuery;
    FDConnection1: TFDConnection;

    procedure insereUsuarioBanco(usuario : TUsuario);
    function BuscaUsuario(login : string; senha : string) : TUsuario;
    procedure btn_salvaContaClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frm_cadastro: Tfrm_cadastro;

implementation

{$R *.fmx}

procedure Tfrm_cadastro.insereUsuarioBanco(usuario: TUsuario);
begin
  FDQ_Usuarios.Close;
  FDQ_Usuarios.SQL.Clear;
  FDQ_Usuarios.SQL.Add('INSERT INTO usuario (login, senha) ' +
                      'VALUES (:login, :senha)');
  FDQ_Usuarios.ParamByName('login').AsString := usuario.login;
  FDQ_Usuarios.ParamByName('senha').AsString := usuario.senha;
  FDQ_Usuarios.ExecSQL;
end;

function Tfrm_cadastro.BuscaUsuario(login : string; senha : string): TUsuario;
var vUsuario :  TUsuario;
begin

   FDQ_Usuarios.Close;
   FDQ_Usuarios.SQL.Clear;
   FDQ_Usuarios.SQL.Add('select usu.id_usuario from usuario usu ');
   FDQ_Usuarios.SQL.Add('where usu.login = :login and usu.senha = :senha ');

   // Definindo explicitamente os tipos de dados dos parâmetros
   FDQ_Usuarios.ParamByName('login').DataType := ftString;
   FDQ_Usuarios.ParamByName('login').AsString := login;
   FDQ_Usuarios.ParamByName('senha').DataType := ftString;
   FDQ_Usuarios.ParamByName('senha').AsString := senha;

   FDQ_Usuarios.Open();

   if not FDQ_Usuarios.Eof then
   begin
     vUsuario.ID := FDQ_Usuarios.FieldByName('id_usuario').AsInteger;
     vUsuario.login := login;
     vUsuario.senha := senha;
   end
   else
   begin
     vUsuario.ID := -1; //ID inválida para indicar que não foi encontrado
   end;

   Result := vUsuario;

end;

procedure Tfrm_cadastro.btn_salvaContaClick(Sender: TObject);
var vUsuario : TUsuario;
begin

  vUsuario.login := edt_criarLogin.Text;
  vUsuario.senha := edt_criarSenha.Text;

  insereUsuarioBanco(vUsuario);
  frm_cadastro.Close;

end;

end.
