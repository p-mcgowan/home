"""
Author: shadyabhi abhijeet.1989@gmail.com
For protocol description(not mine), check http://bittorrent.org/beps/bep_0015.html#udp-tracker-protocol
"""

import socket
import struct
from random import randrange #to generate random transaction_id
from urllib import urlopen
import re

tracker = "udp://open.demonii.com/announce"
port = 1337
torrent_hash = ["433479c6dfaa3b2df9bc932f4b3582b2fd76c84e"]
torrent_details = {}

def get_torrent_name(infohash):
    url = "http://torrentz.me/" + infohash
    p = urlopen(url)
    page = p.read()
    c = re.compile(r'<h2><span>(.*?)</span>')
    return c.search(page).group(1)

def pretty_show(infohash):
    print "Torrent Hash: ", infohash
    try:
        print "Torrent Name (from torrentz): ", get_torrent_name(infohash)
    except:
        print "Coundn'f find torrent name"
    print "Seeds, Leechers, Completed", torrent_details[infohash]
    print

#Create the socket
clisocket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
clisocket.connect((tracker, port))

#Protocol says to keep it that way
connection_id=0x41727101980
#We should get the same in response
transaction_id = randrange(1,65535)

packet=struct.pack(">QLL",connection_id, 0,transaction_id)
clisocket.send(packet)
res = clisocket.recv(16)
action,transaction_id,connection_id=struct.unpack(">LLQ",res)

packet_hashes = ""
for infohash in torrent_hash:
    packet_hashes = packet_hashes + infohash.decode('hex')

packet = struct.pack(">QLL", connection_id, 2, transaction_id) + packet_hashes

clisocket.send(packet)
res = clisocket.recv(8 + 12*len(torrent_hash))

index = 8
for infohash in torrent_hash:
    seeders, completed, leechers = struct.unpack(">LLL", res[index:index+12])
    torrent_details[infohash] = (seeders, leechers, completed)
    pretty_show(infohash)
    index = index + 12
