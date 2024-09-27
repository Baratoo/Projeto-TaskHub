program pPrincipal;

uses
  System.StartUpCopy,
  FMX.Forms,
  uPrincipal in 'uPrincipal.pas' {frm_caption},
  uCadastro in 'uCadastro.pas' {frm_cadastro},
  uTarefas in 'uTarefas.pas' {frm_tarefas};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(Tfrm_login, frm_login);
  Application.CreateForm(Tfrm_cadastro, frm_cadastro);
  Application.CreateForm(Tfrm_tarefas, frm_tarefas);
  Application.Run;
end.
