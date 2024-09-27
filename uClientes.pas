unit uClientes;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Layouts, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.FMXUI.Wait, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, FMX.ListView, FMX.Edit, FMX.TabControl, FMX.DateTimeCtrls,
  FMX.Objects;

type

  TCliente = record
    codigo : integer;
    nome, endereco : string;
  end;

  Tfrm_clientes = class(TForm)
    Layout1: TLayout;
    Layout2: TLayout;
    Layout3: TLayout;
    Label1: TLabel;
    FDConnection1: TFDConnection;
    FDQ_Clientes: TFDQuery;
    ListViewPrincipal: TListView;
    TabControl1: TTabControl;
    tbHome: TTabItem;
    tbNewTask: TTabItem;
    tbConcluidas: TTabItem;
    Layout4: TLayout;
    Label2: TLabel;
    Layout5: TLayout;
    Label6: TLabel;
    DateEdit1: TDateEdit;
    imgHome: TImage;
    Label3: TLabel;
    edt_titlulo: TEdit;
    Label4: TLabel;
    edt_descricao: TEdit;
    Label5: TLabel;
    DateEdit2: TDateEdit;
    btn_salvar: TButton;
    Layout6: TLayout;
    Label7: TLabel;
    Label8: TLabel;
    DateEdit3: TDateEdit;
    ListViewConcluidas: TListView;
    procedure sbtn_pesquisarClick(Sender: TObject);

    procedure atualizaClientesdoBanco();

    //procedure insereClientenaLista(Cliente : TCliente);
    procedure btn_inserirClick(Sender: TObject);
    //procedure sbtnSalvarClick(Sender: TObject);
    procedure insereClientenoBanco(cliente : TCLiente);
    procedure SpeedButton1Click(Sender: TObject);


  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frm_clientes: Tfrm_clientes;

implementation

{$R *.fmx}



procedure Tfrm_clientes.atualizaClientesdoBanco;
var vCliente : TCLiente;

begin
  //Consultar no banco e trazer clientes
  FDQ_Clientes.Close;
  FDQ_Clientes.SQL.Clear;
  FDQ_Clientes.SQL.Add('select * from clientes');


  FDQ_Clientes.Open();

  FDQ_Clientes.First;

  //ListView1.Items.Clear;

  while not FDQ_Clientes.Eof do
  begin
    vCliente.codigo := FDQ_Clientes.FieldByName('codigo').AsInteger;
    vCliente.nome := FDQ_Clientes.FieldByName('nome').AsString;
    vCliente.endereco := FDQ_Clientes.FieldByName('endereco').AsString;

    //insereClientenaLista(vCLiente);


    FDQ_Clientes.Next;
  end;

end;
{
procedure Tfrm_clientes.insereClientenaLista(Cliente: TCliente);
begin
  with ListView1.Items.Add() do
  begin
    TListItemText(Objects.FindDrawable('TxtCodigo')).Text := inttoStr(cliente.codigo);
    TListItemText(Objects.FindDrawable('TxtNome')).Text := cliente.nome;

  end;

end;
 }
procedure Tfrm_clientes.insereClientenoBanco(cliente: TCLiente);
begin

  FDQ_Clientes.Close;
  FDQ_Clientes.SQL.Clear;
  FDQ_Clientes.SQL.Add('INSERT INTO CLIENTES (CODIGO, NOME, ENDERECO) VALUES(:CODIGO, :NOME, :ENDERECO)');
  FDQ_Clientes.ParamByName('codigo').AsInteger := cliente.codigo;
  FDQ_Clientes.ParamByName('nome').AsString := cliente.nome;
  FDQ_Clientes.ParamByName('endereco').AsString := cliente.endereco;
  FDQ_Clientes.ExecSQL;

end;

procedure Tfrm_clientes.btn_inserirClick(Sender: TObject);
begin

  TabControl1.TabIndex := 1;
end;
{
procedure Tfrm_clientes.sbtnSalvarClick(Sender: TObject);
var vCLiente : TCliente;
begin

  vCliente.codigo := StrToInt(edtCodigo.Text);
  vCliente.nome := edtNome.Text;
  vCLiente.endereco := edtEndereco.Text;


  //Chamar procedimento para inserir cliente no banco
  insereClientenoBanco(vCliente);


end;
    }
procedure Tfrm_clientes.sbtn_pesquisarClick(Sender: TObject);
begin
  //Chamar metodo de pesquisa

  atualizaClientesdoBanco;
end;

procedure Tfrm_clientes.SpeedButton1Click(Sender: TObject);
begin
  TabControl1.TabIndex := 0;
end;

end.
