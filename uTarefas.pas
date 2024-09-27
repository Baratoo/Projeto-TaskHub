unit uTarefas;

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
  FMX.Objects, FMX.ListBox, FMX.Styles.Objects;

type
  TTask = record
    ID: Integer;
    Titulo: string;
    Descricao: string;
    Prioridade: string;
    Categoria: string;
    Prazo: TDate;
    IdUsuario: Integer;
    hora: TTime;
  end;

  Tfrm_tarefas = class(TForm)
    Layout1: TLayout;
    Layout2: TLayout;
    Layout3: TLayout;
    Label1: TLabel;
    FDConnection1: TFDConnection;
    FDQ_Tarefas: TFDQuery;
    ListViewPrincipal: TListView;
    TabControl1: TTabControl;
    tbHome: TTabItem;
    tbNewTask: TTabItem;
    tbConcluidas: TTabItem;
    Layout4: TLayout;
    Label2: TLabel;
    Layout5: TLayout;
    Label6: TLabel;
    imgHome: TImage;
    Label3: TLabel;
    edt_titlulo: TEdit;
    Label4: TLabel;
    edt_descricao: TEdit;
    btn_salvar: TButton;
    Layout6: TLayout;
    Label7: TLabel;
    Label8: TLabel;
    ListViewConcluidas: TListView;
    Label5: TLabel;
    edt_categoria: TEdit;
    box_prioridade: TComboBox;
    p_baixa: TListBoxItem;
    p_alta: TListBoxItem;
    p_media: TListBoxItem;
    Label9: TLabel;
    Label10: TLabel;
    edt_prazo: TDateEdit;
    SpeedButton1: TSpeedButton;
    btn_excluir: TButton;
    btn_concluir: TButton;
    btn_buscarConcluidas: TSpeedButton;
    StyleTextObject1: TStyleTextObject;
    edt_hora: TTimeEdit;
{//////////////////////////////////////////////////////////////////////////////}
    procedure FormCreate(Sender: TObject);
    procedure insereTasknoBanco(task: TTask);
    procedure atualizaListaDeTarefas;
    procedure atualizaTarefasConcluidas;
    procedure insereTasknaLista(task: TTask);
    procedure insereTasknaListaConcluida(task: TTask);
    procedure excluiTaskdoBanco(taskID: Integer);
    procedure btn_salvarClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure ListViewPrincipalChange(Sender: TObject);
    procedure edt_prazoEnter(Sender: TObject);
    function buscaTasknoBanco(ID: integer): TTask;
    procedure ListViewPrincipalItemClick(const Sender: TObject;
      const AItem: TListViewItem);
    procedure btn_excluirClick(Sender: TObject);
    procedure btn_concluirClick(Sender: TObject);
    procedure tbNewTaskClick(Sender: TObject);
    procedure adicionarColunaConcluida;
    procedure btn_buscarConcluidasClick(Sender: TObject);
    procedure atualizaTarefaNoBanco(task: TTask);
{//////////////////////////////////////////////////////////////////////////////}

  private
    FUsuarioID: Integer;
    FSelectedTaskID: Integer;
  public
    property UsuarioID: Integer read FUsuarioID write FUsuarioID;
  end;

var
  frm_tarefas: Tfrm_tarefas;

implementation

{$R *.fmx}
{/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////}

procedure Tfrm_tarefas.FormCreate(Sender: TObject);
begin
  try
    FDConnection1.Params.Clear;
    FDConnection1.Params.DriverID := 'SQLite';
    FDConnection1.Params.Database := 'caminho_para_o_seu_banco_de_dados.sqlite';
    FDConnection1.Connected := True;
  except
    on E: Exception do
    begin
      ShowMessage('Erro ao conectar no banco de dados: ' + E.Message);
      Exit;
    end;
  end;

  adicionarColunaConcluida;
  atualizaListaDeTarefas;
  atualizaTarefasConcluidas;
end;

procedure Tfrm_tarefas.adicionarColunaConcluida;
var
  colunaExiste: Boolean;
begin
  // Verifica se a coluna 'concluida' j� existe
  colunaExiste := False;
  FDQ_Tarefas.Close;
  FDQ_Tarefas.SQL.Clear;
  FDQ_Tarefas.SQL.Add('PRAGMA table_info(tarefa)');
  FDQ_Tarefas.Open;

  while not FDQ_Tarefas.Eof do
  begin
    if FDQ_Tarefas.FieldByName('name').AsString = 'concluida' then
    begin
      colunaExiste := True;
      Break;
    end;
    FDQ_Tarefas.Next;
  end;

  FDQ_Tarefas.Close;

  // Adiciona a coluna 'concluida' se ela n�o existir
  if not colunaExiste then

  begin
    try
      FDQ_Tarefas.SQL.Clear;
      FDQ_Tarefas.SQL.Add('ALTER TABLE tarefa ADD COLUMN concluida INTEGER DEFAULT 0');
      FDQ_Tarefas.ExecSQL;
    except
      on E: Exception do
        ShowMessage('Erro ao adicionar coluna "concluida": ' + E.Message);
    end;
  end;
end;

{/////////////////////////BUSCA NO BANCO E INSERE NA LISTA//////////////////////////////////////////////}

procedure Tfrm_tarefas.atualizaListaDeTarefas;
var
  task: TTask;
begin
  // Consultar no banco e trazer tarefas
  FDQ_Tarefas.Close;
  FDQ_Tarefas.SQL.Clear;
  FDQ_Tarefas.SQL.Add('SELECT * FROM tarefa WHERE concluida = 0 AND id_usuario = :UsuarioID ORDER BY hora ASC');
  FDQ_Tarefas.ParamByName('UsuarioID').AsInteger := FUsuarioID;
  FDQ_Tarefas.Open;
  FDQ_Tarefas.First;

  ListViewPrincipal.Items.Clear;

  while not FDQ_Tarefas.Eof do
  begin
    task.ID := FDQ_Tarefas.FieldByName('id_tarefa').AsInteger;
    task.Titulo := FDQ_Tarefas.FieldByName('titulo').AsString;
    task.Descricao := FDQ_Tarefas.FieldByName('descricao').AsString;
    task.Prioridade := FDQ_Tarefas.FieldByName('prioridade').AsString;
    task.Categoria := FDQ_Tarefas.FieldByName('categoria').AsString;
    task.Prazo := FDQ_Tarefas.FieldByName('prazo').AsDateTime;

    task.IdUsuario := FUsuarioID;
    task.hora := FDQ_Tarefas.FieldByName('hora').AsDateTime;


    insereTasknaLista(task);
    FDQ_Tarefas.Next;
  end;
end;

procedure Tfrm_tarefas.atualizaTarefasConcluidas;
var
  task: TTask;
begin
  // Consultar no banco e trazer tarefas conclu�das
  FDQ_Tarefas.Close;
  FDQ_Tarefas.SQL.Clear;
  FDQ_Tarefas.SQL.Add('SELECT * FROM tarefa WHERE concluida = 1 AND id_usuario = :UsuarioID');
  FDQ_Tarefas.ParamByName('UsuarioID').AsInteger := FUsuarioID;
  FDQ_Tarefas.Open;
  FDQ_Tarefas.First;

  ListViewConcluidas.Items.Clear;

  while not FDQ_Tarefas.Eof do
  begin
    task.ID := FDQ_Tarefas.FieldByName('id_tarefa').AsInteger;
    task.Titulo := FDQ_Tarefas.FieldByName('titulo').AsString;
    task.Descricao := FDQ_Tarefas.FieldByName('descricao').AsString;
    task.Prioridade := FDQ_Tarefas.FieldByName('prioridade').AsString;
    task.Categoria := FDQ_Tarefas.FieldByName('categoria').AsString;
    task.Prazo := FDQ_Tarefas.FieldByName('prazo').AsDateTime;
    task.IdUsuario := FUsuarioID;

    insereTasknaListaConcluida(task);
    FDQ_Tarefas.Next;
  end;
end;

{/////////////////////////INSERE NO BANCO//////////////////////////////////////////////}

procedure Tfrm_tarefas.insereTasknoBanco(task: TTask);
begin
  FDQ_Tarefas.Close;
  FDQ_Tarefas.SQL.Clear;
  FDQ_Tarefas.SQL.Add('INSERT INTO tarefa (titulo, descricao, prioridade, categoria, prazo, id_usuario, concluida, hora) ' +
                      'VALUES (:titulo, :descricao, :prioridade, :categoria, :prazo, :id_usuario, 0, :hora)');
  FDQ_Tarefas.ParamByName('titulo').AsString := task.Titulo;
  FDQ_Tarefas.ParamByName('descricao').AsString := task.Descricao;
  FDQ_Tarefas.ParamByName('prioridade').AsString := task.Prioridade;
  FDQ_Tarefas.ParamByName('categoria').AsString := task.Categoria;
  FDQ_Tarefas.ParamByName('prazo').AsDate := task.Prazo;
  FDQ_Tarefas.ParamByName('id_usuario').AsInteger := task.IdUsuario;
    FDQ_Tarefas.ParamByName('hora').AsTime := task.hora;
  FDQ_Tarefas.ExecSQL;
end;

procedure Tfrm_tarefas.atualizaTarefaNoBanco(task: TTask);
begin
  FDQ_Tarefas.Close;
  FDQ_Tarefas.SQL.Clear;
  FDQ_Tarefas.SQL.Add('UPDATE tarefa SET titulo = :titulo, descricao = :descricao, prioridade = :prioridade, ' +
                      'categoria = :categoria, prazo = :prazo, hora = :hora WHERE id_tarefa = :id');
  FDQ_Tarefas.ParamByName('titulo').AsString := task.Titulo;
  FDQ_Tarefas.ParamByName('descricao').AsString := task.Descricao;
  FDQ_Tarefas.ParamByName('prioridade').AsString := task.Prioridade;
  FDQ_Tarefas.ParamByName('categoria').AsString := task.Categoria;
  FDQ_Tarefas.ParamByName('prazo').AsDate := task.Prazo;
  FDQ_Tarefas.ParamByName('id').AsInteger := task.ID;
    FDQ_Tarefas.ParamByName('hora').AsTime := task.hora;
  FDQ_Tarefas.ExecSQL;
end;

procedure Tfrm_tarefas.ListViewPrincipalChange(Sender: TObject);
begin
  ListViewPrincipal.Items.Clear;
end;

function Tfrm_tarefas.buscaTasknoBanco(ID: integer): TTask;
var
  vTask: TTask;
begin
  FDQ_Tarefas.Close;
  FDQ_Tarefas.SQL.Clear;
  FDQ_Tarefas.SQL.Add('SELECT * FROM tarefa WHERE id_tarefa = :ID');
  FDQ_Tarefas.ParamByName('ID').AsInteger := ID;
  FDQ_Tarefas.Open;

  if not FDQ_Tarefas.IsEmpty then
  begin
    vTask.ID := ID;
    vTask.Titulo := FDQ_Tarefas.FieldByName('titulo').AsString;
    vTask.Descricao := FDQ_Tarefas.FieldByName('descricao').AsString;
    vTask.Prioridade := FDQ_Tarefas.FieldByName('prioridade').AsString;
    vTask.Categoria := FDQ_Tarefas.FieldByName('categoria').AsString;
    vTask.Prazo := FDQ_Tarefas.FieldByName('prazo').AsDateTime;
  end;

  Result := vTask;
end;

{/////////////////////////BOT�O PARA CONCLUIR TAREFA//////////////////////////////////////////////}

procedure Tfrm_tarefas.ListViewPrincipalItemClick(const Sender: TObject;
  const AItem: TListViewItem);
var
  id_tarefa: Integer;
  task: TTask;
begin
  // Obt�m o ID da tarefa a partir do objeto desenh�vel 'TxtId' no item clicado
  id_tarefa := StrToInt(TListItemText(AItem.Objects.FindDrawable('TxtId')).Text);

  // Armazena o ID da tarefa selecionada
  FSelectedTaskID := id_tarefa;
  ShowMessage('Tarefa selecionada com ID: ' + IntToStr(FSelectedTaskID));

  // Busca a tarefa no banco de dados
  task := buscaTasknoBanco(id_tarefa);

  // Preenche os campos da tela com os detalhes da tarefa
  edt_titlulo.Text := task.Titulo;
  edt_descricao.Text := task.Descricao;
  edt_categoria.Text := task.Categoria;
  box_prioridade.ItemIndex := box_prioridade.Items.IndexOf(task.Prioridade);
  edt_prazo.Date := task.Prazo;

  // Alterna para a aba de edi��o
  TabControl1.TabIndex := 1;
end;

{/////////////////////////FIM BOT�O PARA CONCLUIR TAREFA//////////////////////////////////////////////}

{/////////////////////////BOT�O PARA ATUALIZAR TAREFAS//////////////////////////////////////////////}
procedure Tfrm_tarefas.SpeedButton1Click(Sender: TObject);
begin
  atualizaListaDeTarefas;
  atualizaTarefasConcluidas;
end;

{/////////////////////////INSERE NA LISTA//////////////////////////////////////////////}
procedure Tfrm_tarefas.insereTasknaLista(task: TTask);
var
  item: TListViewItem;
begin
  item := ListViewPrincipal.Items.Add;
  with item do
  begin
    TListItemText(Objects.FindDrawable('TxtId')).Text := IntToStr(task.ID);
    TListItemText(Objects.FindDrawable('TxtTitulo')).Text := task.Titulo;
    //TListItemText(Objects.FindDrawable('TxtDescricao')).Text := task.Descricao;
    TListItemText(Objects.FindDrawable('TxtPrioridade')).Text := task.Prioridade;
    TListItemText(Objects.FindDrawable('TxtCategoria')).Text := task.Categoria;
    TListItemText(Objects.FindDrawable('TxtPrazo')).Text := DateToStr(task.Prazo);
    TListItemText(Objects.FindDrawable('txtHora')).Text := TimeToStr(task.hora);
  end;
end;

procedure Tfrm_tarefas.insereTasknaListaConcluida(task: TTask);
var
  item: TListViewItem;
begin
  item := ListViewConcluidas.Items.Add;
  with item do
  begin
    TListItemText(Objects.FindDrawable('TxtId')).Text := IntToStr(task.ID);
    TListItemText(Objects.FindDrawable('TxtTitulo')).Text := task.Titulo;
    //TListItemText(Objects.FindDrawable('TxtDescricao')).Text := task.Descricao;
    //TListItemText(Objects.FindDrawable('TxtPrioridade')).Text := task.Prioridade;
    TListItemText(Objects.FindDrawable('TxtCategoria')).Text := task.Categoria;
    //TListItemText(Objects.FindDrawable('TxtPrazo')).Text := DateToStr(task.Prazo);
    //TListItemText(Objects.FindDrawable('TxtIdUsuario')).Text := IntToStr(task.IdUsuario);
  end;
end;

{/////////////////////////EXCLUI TASK DO BANCO//////////////////////////////////////////////}

procedure Tfrm_tarefas.edt_prazoEnter(Sender: TObject);
begin
  edt_prazo.Date := Date;
end;

procedure Tfrm_tarefas.excluiTaskdoBanco(taskID: Integer);
begin
  FDQ_Tarefas.Close;
  FDQ_Tarefas.SQL.Clear;
  FDQ_Tarefas.SQL.Add('DELETE FROM tarefa WHERE id_tarefa = :id');
  FDQ_Tarefas.ParamByName('id').AsInteger := taskID;
  FDQ_Tarefas.ExecSQL;
end;

{/////////////////////////BOT�O DE SALVAR TAREFA//////////////////////////////////////////////}

procedure Tfrm_tarefas.btn_excluirClick(Sender: TObject);
begin
  // Verifica se h� uma tarefa selecionada para exclus�o
  if FSelectedTaskID <> 0 then
  begin
    try
      ShowMessage('Excluindo tarefa com ID: ' + IntToStr(FSelectedTaskID));
      excluiTaskdoBanco(FSelectedTaskID);
      atualizaListaDeTarefas;
      FSelectedTaskID := 0; // Reseta a sele��o ap�s a exclus�o
      TabControl1.TabIndex := 0; // Volta para a aba principal
    except
      on E: Exception do
        ShowMessage('Erro ao excluir a tarefa: ' + E.Message);
    end;
  end
  else
  begin
    ShowMessage('Nenhuma tarefa selecionada para exclus�o.');
  end;
end;

procedure Tfrm_tarefas.btn_buscarConcluidasClick(Sender: TObject);
begin
  atualizaListaDeTarefas;
  atualizaTarefasConcluidas;
end;

procedure Tfrm_tarefas.btn_concluirClick(Sender: TObject);
begin
  // Verifica se h� uma tarefa selecionada para conclus�o
  if FSelectedTaskID <> 0 then
  begin
    try
      ShowMessage('Concluindo tarefa com ID: ' + IntToStr(FSelectedTaskID));

      FDQ_Tarefas.Close;
      FDQ_Tarefas.SQL.Clear;
      FDQ_Tarefas.SQL.Add('UPDATE tarefa SET concluida = 1 WHERE id_tarefa = :ID');
      FDQ_Tarefas.ParamByName('ID').AsInteger := FSelectedTaskID;
      FDQ_Tarefas.ExecSQL;

      atualizaListaDeTarefas;
      atualizaTarefasConcluidas;
      FSelectedTaskID := 0; // Reseta a sele��o ap�s a conclus�o
      TabControl1.TabIndex := 0; // Volta para a aba principal
    except
      on E: Exception do
        ShowMessage('Erro ao concluir a tarefa: ' + E.Message);
    end;
  end
  else
  begin
    ShowMessage('Nenhuma tarefa selecionada para conclus�o.');
  end;
end;

procedure Tfrm_tarefas.btn_salvarClick(Sender: TObject);
var
  vTask: TTask;
begin
  vTask.Titulo := edt_titlulo.Text;
  vTask.Descricao := edt_descricao.Text;
  vTask.Prioridade := box_prioridade.Selected.Text;
  vTask.Categoria := edt_categoria.Text;
  vTask.Prazo := edt_prazo.Date;
  vTask.IdUsuario := FUsuarioID;
  vTask.hora := edt_hora.Time; // Define o ID do usu�rio logado

  if FSelectedTaskID = 0 then
  begin
    insereTasknoBanco(vTask);
  end
  else
  begin
    vTask.ID := FSelectedTaskID;
    atualizaTarefaNoBanco(vTask);
  end;

  atualizaListaDeTarefas; // Atualiza a lista de tarefas ap�s inserir ou atualizar
  TabControl1.TabIndex := 0;
end;

procedure Tfrm_tarefas.tbNewTaskClick(Sender: TObject);
begin
  // Limpar os campos de entrada
  edt_titlulo.Text := '';
  edt_descricao.Text := '';
  edt_categoria.Text := '';
  box_prioridade.ItemIndex := -1;
  edt_prazo.Date := Now;

  // Resetar o ID da tarefa selecionada
  FSelectedTaskID := 0;

  // Alternar para a aba de nova tarefa
  TabControl1.TabIndex := tbNewTask.Index;
end;

{/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////}

end.

