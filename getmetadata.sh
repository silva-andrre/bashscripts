#!/bin/bash
#
DOMINIO="$1"
EXT="$2"
if [ "$1" == "" ]
then
        echo "Modo de Uso: $0 dominio.com"
        echo "Exemplo: $0 google.com"
else
lynx --dump "https://www.google.com/search?&q=site:$1+ext:$2" | grep ".$2" | cut -d "=" -f2 | egrep -v "site|google" | sed 's/...$//' > result
#
for url in $(cat result);
do
       wget -q $url;
done
exiftool *.$2
fi
