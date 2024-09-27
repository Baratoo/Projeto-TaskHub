unit TestuTarefas;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit 
  being tested.

}

interface

uses
  TestFramework, FMX.Styles.Objects, FMX.Types, FMX.Objects, FireDAC.DApt.Intf,
  FireDAC.DatS, FireDAC.Stan.Def, FMX.Controls, System.UITypes, FMX.ListView.Types,
  FireDAC.Stan.Option, System.SysUtils, FMX.Edit, System.Classes, FMX.DateTimeCtrls,
  FMX.ListView.Adapters.Base, uTarefas, FireDAC.Stan.Param, FireDAC.Stan.Intf,
  FMX.ListView, System.Variants, FireDAC.Stan.Error, FMX.Graphics, FireDAC.Phys.Intf,
  FireDAC.Comp.Client, FMX.TabControl, FMX.Layouts, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys, FireDAC.Stan.Pool,
  FireDAC.Phys.SQLite, FMX.Dialogs, FireDAC.Stan.Async, FireDAC.DApt,
  FMX.ListView.Appearances, FireDAC.UI.Intf, System.Types, FMX.Forms, Data.DB,
  FMX.StdCtrls, FireDAC.FMXUI.Wait, FireDAC.Comp.DataSet, FMX.Controls.Presentation,
  FMX.ListBox, FireDAC.Phys.SQLiteWrapper.Stat;

type
  // Test methods for class Tfrm_tarefas
  TestTfrm_tarefas = class(TTestCase)
  strict private
    Ffrm_tarefas: Tfrm_tarefas;
    FDConnection: TFDConnection;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestinsereTasknoBanco;
    procedure TestexcluiTaskdoBanco;
    procedure TestbuscaTasknoBanco;
    procedure TestatualizaTarefaNoBanco;
  end;

implementation

procedure TestTfrm_tarefas.SetUp;
begin
  FDConnection := TFDConnection.Create(nil);
  FDConnection.Params.DriverID := 'SQLite';
  FDConnection.Params.Database := 'D:\Usu�rios\Barato\Documents\TaskHub Teste Final\Banco\TaskHub';
  FDConnection.Connected := True;

  Ffrm_tarefas := Tfrm_tarefas.Create(nil);
  Ffrm_tarefas.FDConnection1 := FDConnection;
  Ffrm_tarefas.UsuarioID := 1;
end;

procedure TestTfrm_tarefas.TearDown;
begin
  Ffrm_tarefas.Free;
  FDConnection.Free;
end;

procedure TestTfrm_tarefas.TestinsereTasknoBanco;
var
  task: TTask;
begin
  task.ID := 0;
  task.Titulo := 'Teste adicionar';
  task.Descricao := 'Descri��o';
  task.Prioridade := 'Alta';
  task.Categoria := 'Teste';
  task.Prazo := Now;
  task.IdUsuario := Ffrm_tarefas.UsuarioID;
  task.hora := Now;

  Ffrm_tarefas.insereTasknoBanco(task);


  Ffrm_tarefas.FDQ_Tarefas.Close;
  Ffrm_tarefas.FDQ_Tarefas.SQL.Clear;
  Ffrm_tarefas.FDQ_Tarefas.SQL.Add('SELECT * FROM tarefa WHERE titulo = :titulo');
  Ffrm_tarefas.FDQ_Tarefas.ParamByName('titulo').AsString := task.Titulo;
  Ffrm_tarefas.FDQ_Tarefas.Open;

  CheckFalse(Ffrm_tarefas.FDQ_Tarefas.IsEmpty, 'A tarefa n�o foi inserida.');

  Ffrm_tarefas.excluiTaskdoBanco(Ffrm_tarefas.FDQ_Tarefas.FieldByName('id_tarefa').AsInteger);

end;

procedure TestTfrm_tarefas.TestexcluiTaskdoBanco;
var
  task: TTask;
begin

  task.ID := 0;
  task.Titulo := 'Teste excluir';
  task.Descricao := 'Descri��o';
  task.Prioridade := 'Alta';
  task.Categoria := 'Teste';
  task.Prazo := Date;
  task.IdUsuario := Ffrm_tarefas.UsuarioID;
  task.hora := Time;
  Ffrm_tarefas.insereTasknoBanco(task);

  Ffrm_tarefas.FDQ_Tarefas.Close;
  Ffrm_tarefas.FDQ_Tarefas.SQL.Text := 'SELECT * FROM tarefa WHERE titulo = :titulo';
  Ffrm_tarefas.FDQ_Tarefas.ParamByName('titulo').AsString := task.Titulo;
  Ffrm_tarefas.FDQ_Tarefas.Open;
  CheckFalse(Ffrm_tarefas.FDQ_Tarefas.IsEmpty, 'Task was not inserted for deletion test');
  task.ID := Ffrm_tarefas.FDQ_Tarefas.FieldByName('id_tarefa').AsInteger;

  Ffrm_tarefas.excluiTaskdoBanco(task.ID);

  Ffrm_tarefas.FDQ_Tarefas.Close;
  Ffrm_tarefas.FDQ_Tarefas.SQL.Text := 'SELECT * FROM tarefa WHERE id_tarefa = :id';
  Ffrm_tarefas.FDQ_Tarefas.ParamByName('id').AsInteger := task.ID;
  Ffrm_tarefas.FDQ_Tarefas.Open;
  CheckTrue(Ffrm_tarefas.FDQ_Tarefas.IsEmpty, 'A tarefa n�o foi excluida');
end;

procedure TestTfrm_tarefas.TestbuscaTasknoBanco;
var
  task: TTask;
  foundTask: TTask;
begin

  task.ID := 0;
  task.Titulo := 'Teste Busca';
  task.Descricao := 'Descri��o';
  task.Prioridade := 'Alta';
  task.Categoria := 'Teste';
  task.Prazo := Date;
  task.IdUsuario := Ffrm_tarefas.UsuarioID;
  task.hora := Time;
  Ffrm_tarefas.insereTasknoBanco(task);

  Ffrm_tarefas.FDQ_Tarefas.Close;
  Ffrm_tarefas.FDQ_Tarefas.SQL.Text := 'SELECT * FROM tarefa WHERE titulo = :titulo';
  Ffrm_tarefas.FDQ_Tarefas.ParamByName('titulo').AsString := task.Titulo;
  Ffrm_tarefas.FDQ_Tarefas.Open;
  CheckFalse(Ffrm_tarefas.FDQ_Tarefas.IsEmpty, 'A tarefa n�o foi inserida');
  task.ID := Ffrm_tarefas.FDQ_Tarefas.FieldByName('id_tarefa').AsInteger;

  foundTask := Ffrm_tarefas.buscaTasknoBanco(task.ID);

  CheckEquals(task.ID, foundTask.ID, 'ID n�o encontrado');
  CheckEquals(task.Titulo, foundTask.Titulo, 'Titulo n�o encontrado');
  CheckEquals(task.Descricao, foundTask.Descricao, 'Descricao n�o encontrado');
  CheckEquals(task.Prioridade, foundTask.Prioridade, 'Prioridade n�o encontrado');
  CheckEquals(task.Categoria, foundTask.Categoria, 'Categoria n�o encontrado');
  CheckEquals(task.Prazo, foundTask.Prazo, 'Prazo n�o encontrado');

  Ffrm_tarefas.excluiTaskdoBanco(task.ID);
end;

procedure TestTfrm_tarefas.TestatualizaTarefaNoBanco;
var
  task: TTask;
  updatedTask: TTask;
begin

  task.ID := 0;
  task.Titulo := 'Teste Atualiza��o';
  task.Descricao := 'Descri��o';
  task.Prioridade := 'Alta';
  task.Categoria := 'Teste';
  task.Prazo := Date;
  task.IdUsuario := Ffrm_tarefas.UsuarioID;
  task.hora := Time;
  Ffrm_tarefas.insereTasknoBanco(task);

  Ffrm_tarefas.FDQ_Tarefas.Close;
  Ffrm_tarefas.FDQ_Tarefas.SQL.Text := 'SELECT * FROM tarefa WHERE titulo = :titulo';
  Ffrm_tarefas.FDQ_Tarefas.ParamByName('titulo').AsString := task.Titulo;
  Ffrm_tarefas.FDQ_Tarefas.Open;
  CheckFalse(Ffrm_tarefas.FDQ_Tarefas.IsEmpty, 'A tarefa n�o foi inserida');
  task.ID := Ffrm_tarefas.FDQ_Tarefas.FieldByName('id_tarefa').AsInteger;

  updatedTask := task;
  updatedTask.Titulo := 'Titulo2';
  updatedTask.Descricao := 'Descri��o2';
  Ffrm_tarefas.atualizaTarefaNoBanco(updatedTask);

  Ffrm_tarefas.FDQ_Tarefas.Close;
  Ffrm_tarefas.FDQ_Tarefas.SQL.Text := 'SELECT * FROM tarefa WHERE id_tarefa = :id';
  Ffrm_tarefas.FDQ_Tarefas.ParamByName('id').AsInteger := updatedTask.ID;
  Ffrm_tarefas.FDQ_Tarefas.Open;
  CheckEquals(updatedTask.Titulo, Ffrm_tarefas.FDQ_Tarefas.FieldByName('titulo').AsString, 'O titulo n�o foi atualizado');
  CheckEquals(updatedTask.Descricao, Ffrm_tarefas.FDQ_Tarefas.FieldByName('descricao').AsString, 'A descri��o n�o foi atualizada');

  Ffrm_tarefas.excluiTaskdoBanco(task.ID);
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTfrm_tarefas.Suite);
end.

