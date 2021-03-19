#!/bin/bash

#################################################################
# Titulo        : Portscanning                                  #
# Versao        : 0.2                                           #
# Data          : 19/03/2021                                    #
# Homepage      : https://github.com/silva-andrre/bashscripts   #
# Testado       : kali-rolling                                  #
#################################################################

if [ "$1" == "" ]
then
        echo "Modo de usar: $0 REDE"
        echo "Exemplo: $0 192.168.0"
	exit 1
else
	for ip in {1..254};
	do 
		ping -c2 192.168.0.$ip >> opened.txt;
	done
	
	less opened.txt | grep "64 bytes" | cut -d ":" -f1 | cut -d " " -f4 | uniq | sort -u >> maquinas.txt

	for addr in $(cat maquinas.txt);
	do
		for port in $(cat portas.txt);
		do 
			nc -vnz $addr $port;
		done
	done
fi
rm -rf opened.txt
rm -rf maquinas.txt
exit 0
