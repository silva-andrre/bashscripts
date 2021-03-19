#!/bin/bash
###############################################################################
#  FIREWALL: s1lv4                  BY: w3ll used by s1lv4
#
#  CREATED: 13/01/2012              UPDATED: 19/02/2012
#
#  VERSION: 0.1
###############################################################################
#
###############################################################################
#
#  .d8888.  .o88b.   j88D  d8888b. d8888b. 
#  88'  YP d8P  Y8  j8~88  88  `8D VP  `8D  
#  `8bo.   8P      j8' 88  88oobY'   oooY'
#    `Y8b. 8b      V88888D 88`8b     ~~~b.
#  db   8D Y8b  d8     88  88 `88. db   8D 
#  `8888Y'  `Y88P'     VP  88   YD Y8888P'
#
###############################################################################
#
###############################################################################
# Last Update by: S1lv4
###############################################################################

echo -e "\e[31;1m*******************************************************************\e[m"
echo -e "\e[31;1m* By s1lv4                                                        *\e[m"
echo -e "\e[31;1m*                                                                 *\e[m"
echo -e "\e[31;1m* FIREWALL Version 0.1 - s1lv4                                    *\e[m"
echo -e "\e[31;1m*                                                                 *\e[m"
echo -e "\e[31;1m* Created: 13/01/2012         Updated: 19/02/2012                 *\e[m"
echo -e "\e[31;1m*******************************************************************\e[m"

echo -e "\012"

#################
### VARIAVEIS ###
#################

### GENERICAS ###
FW=`which iptables`
FW6=`which ip6tables`
IF=`which ifconfig`
ROUTE=`which route`

### INTERFACES ###
if_net="wlan0"
if_net2="eth0"

### REDES ###
ip_net_wiki="192.168.74.1"

### ENDERECOS IP FIREWALL ###

### REDES DO FIREWALL ###
ANY="0/0"

##################
### SERVIDORES ###
################## 

#WIKI SERVIDOR DE DOCUMENTACAO (DOKUWIKI)
Wiki="192.168.74.133"

#ARGELIA  - SERVIDOR DE HOMOLOGACAO LINUX
Argelia="192.168.74.131"

###############
### SWITCHES ##
###############

###############

#IF_ALIASES()
#{
#
#}

TURN_ON()
{
        # BLOQUEIO DE SPOOFING
        echo 1 > /proc/sys/net/ipv4/conf/all/rp_filter

        # NAO RESPONDER A REQUISICOES DE BROADCAST
        echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts

        # CERTIFICANDO QUE PACOTES ROTEADOS NA ORIGEM FORAM DESCATADOS
        for PKT in /proc/sys/net/ipv4/conf/*/accept_source_route ;do
                echo 0 > "$PKT";
        done

        # TCP SYN COOKIE PROTECTION
        echo 1 > /proc/sys/net/ipv4/tcp_syncookies

        # DESABILITANDO O REDIRECIONAMENTO DE ICMP
        for PKT in /proc/sys/net/ipv4/conf/*/accept_redirects ;do
                echo 0 > "$PKT";
        done

        # ENABLE BAD ERRO PROTECTION
        echo 0 > /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses

        # PROTECT TO SYN FLOOD
        echo 30 > /proc/sys/net/ipv4/tcp_fin_timeout
        echo 1800 > /proc/sys/net/ipv4/tcp_keepalive_time
        echo 0 > /proc/sys/net/ipv4/tcp_window_scaling
        echo 0 > /proc/sys/net/ipv4/tcp_sack
        echo 0 > /proc/sys/net/ipv4/tcp_timestamps

        # HABILITANDO ROTEAMENTO
        echo 1 > /proc/sys/net/ipv4/ip_forward

        # VALOR DO TIME-TO-LIVE (TTL)
        echo 255 > /proc/sys/net/ipv4/ip_default_ttl

        echo -e "APLICANDO TURN DE KERNEL ..................................... \e[32;1m[OK]\e[m"
}

TURN_OFF()
{
        # VALORES DEFAULTS DE TURN DE KERNEL
        echo 0 > /proc/sys/net/ipv4/conf/all/rp_filter
        echo 0 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
        for PKT in /proc/sys/net/ipv4/conf/*/accept_source_route ;do
                echo 1 > "$PKT";
        done
        echo 0 > /proc/sys/net/ipv4/tcp_syncookies
        for PKT in /proc/sys/net/ipv4/conf/*/accept_redirects ;do
                echo 1 > "$PKT";
        done
        echo 1 > /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses
        echo 60 > /proc/sys/net/ipv4/tcp_fin_timeout
        echo 7200 > /proc/sys/net/ipv4/tcp_keepalive_time
        echo 1 > /proc/sys/net/ipv4/tcp_window_scaling
        echo 1 > /proc/sys/net/ipv4/tcp_sack
        echo 1 > /proc/sys/net/ipv4/tcp_timestamps
        echo 0 > /proc/sys/net/ipv4/ip_forward
        echo 64 > /proc/sys/net/ipv4/ip_default_ttl

        echo -e "REMOVENDO TURN DE KERNEL ..................................... \e[32;1m[OK]\e[m"
}

FLUSH_RULES()
{
        # LIMPANDO AS REGRAS
        for TABLES in filter nat mangle ;do
                $FW -F -t $TABLES
        done

        echo -e "LIMPANDO AS REGRAS ........................................... \e[32;1m[OK]\e[m"
}

POLICY_START()
{
        # POLITICAS DE SEGURANCA
        for CHAINS in INPUT OUTPUT FORWARD ;do
                $FW -t filter -P $CHAINS DROP
                $FW6 -t filter -P $CHAINS DROP
        done

        echo -e "POLITICAS DE SEGURANCA ....................................... \e[32;1m[OK]\e[m"
}

POLICY_STOP()
{
        # POLITICAS DE SEGURANCA
        for CHAINS in INPUT OUTPUT FORWARD ;do
                $FW -t filter -P $CHAINS ACCEPT
                $FW6 -t filter -P $CHAINS ACCEPT
        done

        echo -e "POLITICAS DE SEGURANCA ....................................... \e[32;1m[OK]\e[m"
}

STATEFULL()
{
        # REGRAS DE STATEFULL (TCP)
        for CHAINS in INPUT OUTPUT FORWARD ;do
                $FW -A $CHAINS -m state --state ESTABLISHED,RELATED -j ACCEPT
        done

        echo -e "REGRAS DE STATEFULL .......................................... \e[32;1m[OK]\e[m"
}

LOOPBACK()
{
        # REGRAS DE LOOPBACK
        $FW -A INPUT -i lo -j ACCEPT
        $FW -A OUTPUT -o lo -j ACCEPT

        echo -e "REGRAS DE LOOPBACK ........................................... \e[32;1m[OK]\e[m"
}

#BiNAT()
#{
#
#}

#NAT()
#{
#
#}

Log()
{
        # LOG DOS BLOQUEIOS PELA REGRA DEFAULT
        for CHAINS in INPUT OUTPUT FORWARD ;do
                $FW -A $CHAINS -j LOG --log-prefix "BLOCK_DEFAULT: "
        done

        echo -e "REGRAS DE LOG ................................................ \e[32;1m[OK]\e[m"
}

GENERIC()
{
        # TESTE DE CONECTIVIDADE AS REDES (ICMP)
        for CHAINS in INPUT OUTPUT FORWARD ;do
                 $FW -A $CHAINS -p icmp -s $ANY -d $ANY -j ACCEPT
        done

        # ACESSO SSH EXTERNO 
        for TESTE in $(cat /etc/fwall/teste | grep -v ^#) ;do
                 $FW -A FORWARD -p tcp -s $TESTE -d $ANY --dport 22 -j ACCEPT
        done
        # ACESSO DE DNS AS REDES
        for TESTE in $(cat /etc/fwall/teste | grep -v ^#) ;do
                for CHAINS in INPUT OUTPUT FORWARD ;do
                        $FW -A $CHAINS -p tcp -s $TESTE -d $ANY --dport 53 -j ACCEPT
                done
        done
        echo -e "REGRAS GENERICA .............................................. \e[32;1m[OK]\e[m"
}
WEB()
{
        #LIBERACAO DE CONECTIVIDADE WEB
	$FW -A OUTPUT -p tcp -s 192.168.0.0/255.255.255.0 -j ACCEPT
        $FW -A OUTPUT -p udp -s 192.168.0.0/255.255.255.0 -j ACCEPT
        $FW -A OUTPUT -p tcp -s 10.2.4.0/255.255.255.0 -j ACCEPT
        $FW -A OUTPUT -p udp -s 10.2.4.0/255.255.255.0 -j ACCEPT
	echo -e "REGRAS WEB ................................................... \e[32;1m[OK]\e[m"
}
WIKI()
{
	#REGRA DE ACESSO WEB PARA O SERVIDOR DE DOCUMENTACAO
	$FW -A OUTPUT -p tcp -s $ip_net_wiki -d $Wiki --dport 80 -j ACCEPT
	
	#ACESSO SSH PARA O SERVIDOR DE DOCUMENTACAO
	$FW -A OUTPUT -p tcp -s $ip_net_wiki -d $Wiki --dport 22 -j ACCEPT
}
	
ARGELIA()
{
	#REGRA DE ACESSO WEB PARA O SERVIDOR DE HOMOLOGACAO
	$FW -A OUTPUT -p tcp -s $ip_net_wiki -d $Argelia --dport 80 -j ACCEPT
	
	#ACESSO SSH PARA O SERVIDOR DE HOMOLOGACAO
	$FW -A OUTPUT -p tcp -s $ip_net_wiki -d $Argelia --dport 22 -j ACCEPT
}
case $1 in
   start)
      #IF_ALIASES
      TURN_ON
      FLUSH_RULES
      POLICY_START
      STATEFULL
      LOOPBACK
      #BiNAT
      #NAT
      GENERIC
      Log
      ARGELIA
      WEB
      WIKI
   ;;
   stop)
      TURN_OFF
      FLUSH_RULES
      POLICY_STOP
   ;;
   *)
      echo "AVISO: Use $0 {start|stop}"
   ;;
esac
exit 0
