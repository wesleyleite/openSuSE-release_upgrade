#!/bin/bash 

[ $EUID -ne 0 ] && {
	echo 'apenas root deve fazer isso'
	exit
}

if ! WGET=$(which wget 2>/dev/null); then
	echo "wget será instalado agora"
	zypper in -y -n wget
	WGET=$(which wget)
fi

if ! LSB_RELEASE=$(which lsb_release 2>/dev/null); then
	echo "lsb_release será instalado agora"
	zypper in -y -n lsb-release 
	LSB_RELEASE=$(which lsb_release)
fi

openSuSERelease="$($LSB_RELEASE -r |
	sed 's/[[:alpha:]\.+:\t]//g; s/../&./')"

echo "-> Seu release atual é $openSuSERelease"
echo
if list_releases="$($WGET -q -O - 'http://download.opensuse.org/distribution/' | 
	sed "/$openSuSERelease/,/G/ s/^/--/g" |
	grep -E '^--' |
	grep -Ewo '>([0-9]){2}\.[0-9]\/' |
	sed 's/\W//g; s/../&./' |
	tr \\n ' ' |
	sed 's/ $//')" ; then

	array=(${list_releases//$openSuSERelease/})
	[ -z "$array" ] && {
		echo "Nao foi encontrado uma versão para upgrade"
		exit
	}
	echo "Escolha um release abaixo pelo decimal entre conchetes ou CTRL+C para cancelar"
	echo 

	for i in "${!array[@]}"
	do
		echo "[ $i ] ${array[$i]}"
	done

	echo
	echo -n "digite o decimal quando pronto precione enter :: "
	read
	echo
	echo "-> openSuSE-${array[$REPLY]} foi sua escolha, aguarde enquanto preparo o sistema"
	echo
	echo "Irei desativar todos os repositórios, em seguida adicionarei todos repositórios"
	echo "da versão escolhida ${array[$REPLY]}, para um upgrade é importante manter somente"
	echo "um numero limitado de repos e oficiais, dando continuidade ao processo"
	echo "irei atulizar a lista de pacotes para a nova versão e então submeter um teste de"
	echo "upgrade juntamente com o download de todos os pacotes, se tudo der certo um novo" 
	echo "upgrade será invocado basta confirmar o processo como fez no teste e ser feliz"
	echo
	echo "30 SEGUNDOS"
	sleep 30

	zypper mr --all --disable
	zypper ar --name "openSuSE-${array[$REPLY]} oss" \
		"http://download.opensuse.org/distribution/${array[$REPLY]}/repo/oss/" \
		"openSuSE-${array[$REPLY]}-oss"
	zypper ar --name "openSuSE-${array[$REPLY]} non-OSS" \
		"http://download.opensuse.org/distribution/${array[$REPLY]}/repo/non-oss/" \
		"openSuSE-${array[$REPLY]}-non-OSS"
	zypper ar --name "openSuSE-${array[$REPLY]} Update" \
		"http://download.opensuse.org/update/${array[$REPLY]}/" \
		"update-${array[$REPLY]}"
	zypper mr -e -r "update-${array[$REPLY]}"
	zypper mr -e -r "openSuSE-${array[$REPLY]}-oss"
	zypper mr -e -r "openSuSE-${array[$REPLY]}-non-oss"
	zypper ref
	zypper dup -d
	zypper dup
	echo
	echo

	validaRelease="$($LSB_RELEASE -r |
		sed 's/[[:alpha:]\.+:\t]//g; s/../&./')"
	if "$validaRelease" == "$openSuSERelease" ; then
		echo '\o/ Sucesso, Você atualizou seu sistema.'
		echo
		echo "openSuSE-$validaRelease"
		echo
	else
		echo "Algum problema no processo impediu o upgrade, deixe-me saber ;)"
		echo 
	fi

else
	echo "Aconteceu algum problema que não me permitiu baixar a lista de releases"
fi
