#!/bin/sh

##### CONFIGURE #####
#                   #
#####################
ipdeny_whitezones="cz sk"

### DO NOT MODIFY ###
#                   #
#####################
ipset_opts="hash:net --hashsize 2048"
ip6set_opts="hash:net family ipv6"  # with default "--hashsize 1024"

for zone in ${ipdeny_whitezones}
do
  # temporary ipsets for later swap
  tmp=tmp-${zone}
  ipset create "${tmp}"  ${ipset_opts}   # ipv4
  ipset create "${tmp}6" ${ip6set_opts}  # ipv6

  # fill the temporary ipsets with fresh blocks
  # ipv4 first
  wget -q -O - "http://www.ipdeny.com/ipblocks/data/aggregated/${zone}-aggregated.zone" |\
    while read -r line
    do
      ipset add "${tmp}" "${line}"
    done
  # ipv6 after
  wget -q -O - "http://www.ipdeny.com/ipv6/ipaddresses/aggregated/${zone}-aggregated.zone" |\
    while read -r line
    do
      ipset add "${tmp}6" "${line}"
    done

  # create actual ipsets if they don't exist yet 
  ipset create -exist "${zone}"  ${ipset_opts}
  ipset create -exist "${zone}6" ${ip6set_opts}

  # swap
  ipset swap "${tmp}" "${zone}"
  ipset swap "${tmp}6" "${zone}6"

  # destroy the temporary
  ipset destroy "${tmp}"
  ipset destroy "${tmp}6"

  # announce
  echo "ipsets with IPv4 [$(ipset list ${zone} | tail -n +8 | wc -l) blocks] & IPv6 [$(ipset list ${zone}6 | tail -n +8 | wc -l) blocks] for zone \"${zone}\" updated"
done

unset -v tmp line zone ipdeny_whitezones ipset_opts ip6set_opts

exit 0
######## END ########
#                   #
#####################

