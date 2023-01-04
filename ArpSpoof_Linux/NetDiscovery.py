import argparse
from logging import fatal
from scapy import packet
import scapy.all as Scapy
import sys


parser = argparse.ArgumentParser(description="Arp spoofing Tool")
parser.add_argument("-n","--network",required=True,type=str,help="Ip Address Of Target Machine/ network")

parser.add_argument('-i','--index',required=True,type=int,help='Index of interface')
args= parser.parse_args()



def Send_arp_req(ip_sub):
    arp = Scapy.ARP(hwlen=6,plen=4,pdst=ip_sub)
    Eth = Scapy.Ether(dst='FF:FF:FF:FF:FF:FF')

    #arp.show()
    #Eth.show()

    p = Eth / arp

    #p.show()

    ans = Scapy.srp(p,timeout=10,verbose=False,iface=Scapy.conf.ifaces.dev_from_index(args.index))[0]
    
    #print(ans.summary())
    for i in ans:
        print("{}\t{}".format(i[1].psrc,i[1].hwsrc))
        

#print("[!]Operating on interface: {}\n\n".format(Scapy.conf.ifaces.dev_from_index(args.index)))
Send_arp_req(args.network)

