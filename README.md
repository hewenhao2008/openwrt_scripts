# OpenWRT scripts

## Scripts for OpenWRT's (busybox's) ash shell

 * geo_ipset.sh :: creates an ipsets (IPv4 & IPv6) depending on configured zones to use later in iptables ipset extension
   * thanks to :: [GentooWiki](https://wiki.gentoo.org/wiki/IPSet) and [IPdeny](http://www.ipdeny.com/ipblocks)

Typical user firewall in OpenWRT then could look like ::

    root@openwrt:~# cat /etc/firewall.user 
    # This file is interpreted as shell script.
    # Put your custom iptables rules here, they will
    # be executed with each firewall (re-)start.

    # Internal uci firewall chains are flushed and recreated on reload, so
    # put custom rules into the root chains e.g. INPUT or FORWARD or into the
    # special user chains, e.g. input_wan_rule or postrouting_lan_rule.

    # geoip4
    iptables -N countryfilter
    iptables -A input_wan_rule -j countryfilter
    iptables -A forwarding_wan_rule -j countryfilter
    # allow SMTP from anywhere to actually get mail normally
    iptables -A countryfilter -m tcp -p tcp --dport 25 -j RETURN
    # allow requests from Czech Republic
    iptables -A countryfilter -m set --match-set cz src -j RETURN
    # pretend we're not here with China
    iptables -A countryfilter -m set --match-set cn src -j DROP
    # kindly reject others
    iptables -A countryfilter -j REJECT
    
    # geoip6
    ip6tables -N countryfilter
    ip6tables -A input_wan_rule -j countryfilter
    ip6tables -A forwarding_wan_rule -j countryfilter
    # allow SMTP from anywhere to actually get mail normally also via IPv6
    ip6tables -A countryfilter -m tcp -p tcp --dport 25 -j RETURN
    # allow requests from Czech Republic
    ip6tables -A countryfilter -m set --match-set cz6 src -j RETURN
    # pretend we're not here with China
    ip6tables -A countryfilter -m set --match-set cn6 src -j DROP
    # kindly reject others
    ip6tables -A countryfilter -j REJECT

## License

Licensed under the [GNU Affero General Public License v3.0](https://www.gnu.org/licenses/agpl-3.0.html) (the "License").

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied. See the License for the
specific language governing permissions and limitations under the License.
