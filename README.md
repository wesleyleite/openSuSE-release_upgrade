# openSuSE-release_upgrade
openSuSE shell para atualização de release em modo interativo.

Pode ser que não faça qualquer diferença, mas todos os meus testes foram feitos em versão server, 
contando apenas com repositórios oficiais e um número limitado de pacotes.

## Como ele funciona?

Ao rodar o script em linha de comando, o mesmo conecta-se ao repositório oficial 
capturando todos os releases disponíveis superiores ao instalado no equipamento (**não foi 
possível testar com versões inferiores do repositório oficial para entender seu funcionamento**) 
todos são listados e fica a seu critório escolher um, após selecionado uma mensagem falando 
do processo será exibida durante 30 sec, basta aguardar e confirmar ou não algum eventual problema.

## Conciderações

O script irá desativar todos os repositórios, pois, é uma boa pratica, caso seja necessário após finalizado 
ative-os manualmente ajustando dados de versão como demonstro baixo:

neste caso irei atualizar da versão 13.1 no repositório do windwmanagers para 13.2
```bash
$ cat X11\:windowmanagers.repo
[X11:windowmanagers]
name=X11:windowmanagers-13.1
enabled=1
autorefresh=1
baseurl=http://download.opensuse.org/repositories/X11:/windowmanagers/openSUSE_13.1/
type=rpm-md
keeppackages=0

$ sed -i 's/13.1/13.2/g' X11\:windowmanagers.repo

$ cat X11\:windowmanagers.repo
[X11:windowmanagers]
name=X11:windowmanagers-13.2
enabled=1
autorefresh=1
baseurl=http://download.opensuse.org/repositories/X11:/windowmanagers/openSUSE_13.2/
type=rpm-md
keeppackages=0
```
você pode ativa-lo via zypper ou yast fica a seu critério.

## Requisitos
  * openSuSE
  * wget (será instalado pelo script caso não exista)
  * lsb_release (será instalado pelo script caso não exista)
  * Conexão com a internet
  
## Não funcionou?

Deixe-me saber, abra uma issue aqui neste link [ISSUE](https://github.com/wesleyleite/openSuSE-release_upgrade/issues)
