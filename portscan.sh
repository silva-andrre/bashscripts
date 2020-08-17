#!/bin/bash
for ip in {1..254};do ping -c2 192.168.0.$ip >> opened.txt;done
less opened.txt | grep "64 bytes" | cut -d ":" -f1 | cut -d " " -f4 | uniq | sort -u >> maquinas.txt
for addr in $(cat maquinas.txt);
do
	for port in $(cat portas.txt);do nc -vnz $addr $port;done
done

rm -rf opened.txt
rm -rf maquinas.txt