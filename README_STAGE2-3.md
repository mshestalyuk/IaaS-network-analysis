# Etap 2 + 3 — Generowanie i przechwytywanie ruchu sieciowego

Toolkit do wygenerowania reprezentatywnego ruchu sieciowego w środowisku IaaS
i przechwycenia go dwiema niezależnymi metodami: `tcpdump` (pełne pakiety, `.pcap`)
oraz VPC Flow Logs (metadane przepływów).

## Struktura

```
scripts/
├── traffic-gen/          # uruchamiane na BASTIONIE
│   ├── config.sh         # <-- uzupełnij IP przed uruchomieniem
│   ├── 01-http.sh        # ruch HTTP/HTTPS (curl, ApacheBench)
│   ├── 02-ssh.sh         # sesje SSH do web i db
│   ├── 03-dns.sh         # zapytania DNS
│   ├── 04-icmp.sh        # ping / traceroute
│   ├── 05-portscan.sh    # symulacja ruchu złośliwego (nmap)
│   └── run-all.sh        # uruchamia wszystkie po kolei + log
└── capture/              # przechwytywanie danych
    ├── start-capture.sh  # start tcpdump (na WEB serverze)
    ├── stop-capture.sh   # stop tcpdump
    └── fetch-flowlogs.sh # pobranie VPC Flow Logs (na WSL)
```

## Co która metoda widzi

Punkt przechwytywania to **web server**. To istotne dla interpretacji wyników:

- **tcpdump na web serverze** widzi tylko ruch do/z web servera: HTTP, SSH do web,
  ICMP do web, skanowanie web servera. Nie widzi ruchu DNS z bastionu ani ruchu
  bastion→db.
- **VPC Flow Logs** widzą **cały** ruch w VPC, włącznie z bastion→db oraz ruchem
  do internetu, wraz z decyzjami ACCEPT/REJECT. Nie rejestrują ruchu do
  wbudowanego resolvera DNS AWS.

Dwie metody są komplementarne — dokładnie tak, jak zakłada Etap 3 i 4 projektu.
Opcjonalnie można uruchomić `start-capture.sh` także na bastionie, aby mieć
`.pcap` z ruchem DNS i perspektywą klienta.

## Przebieg sesji (krok po kroku)

### 0. Przygotowanie

Z maszyny WSL pobierz adresy IP:

```bash
cd environments/lab/ec2 && terragrunt output
```

Wpisz `web_private_ip` i `db_private_ip` do `scripts/traffic-gen/config.sh`.

### 1. Skopiuj skrypty na instancje

```bash
BASTION=<bastion_public_ip>
WEB=<web_private_ip>

# traffic-gen -> bastion
scp -i ~/.ssh/id_ed25519 -r scripts/traffic-gen ec2-user@${BASTION}:~/

# capture -> web server (przez bastion jako jump host)
scp -i ~/.ssh/id_ed25519 -o ProxyJump=ec2-user@${BASTION} \
    -r scripts/capture ec2-user@${WEB}:~/
```

### 2. Start przechwytywania (web server)

```bash
ssh -A -i ~/.ssh/id_ed25519 ec2-user@${BASTION}      # -A = agent forwarding
ssh ec2-user@<web_private_ip>                        # skok z bastionu
chmod +x ~/capture/*.sh
./capture/start-capture.sh
```

Capture działa w tle. Zostaw tę sesję otwartą.

### 3. Generowanie ruchu (bastion)

W nowym terminalu:

```bash
ssh -A -i ~/.ssh/id_ed25519 ec2-user@${BASTION}
chmod +x ~/traffic-gen/*.sh
cd ~/traffic-gen
./run-all.sh
```

`run-all.sh` uruchamia wszystkie pięć typów ruchu i zapisuje log
`traffic-run-*.log` (dowód do dokumentacji Etap 5).

### 4. Stop przechwytywania (web server)

Wróć do sesji na web serverze:

```bash
./capture/stop-capture.sh
```

Wypisze ścieżkę `.pcap`, rozmiar i liczbę pakietów.

### 5. Pobranie danych do analizy

`.pcap` z web servera na WSL:

```bash
scp -i ~/.ssh/id_ed25519 -o ProxyJump=ec2-user@${BASTION} \
    ec2-user@<web_private_ip>:/tmp/capture-*.pcap ./
```

VPC Flow Logs (na WSL — używa lokalnych poświadczeń AWS):

```bash
chmod +x scripts/capture/fetch-flowlogs.sh
./scripts/capture/fetch-flowlogs.sh flowlogs.txt 60
```

## Co dalej — Etap 4

- `.pcap` otwórz w Wireshark — analiza protokołów, filtry, wykresy.
- `flowlogs.txt` — analiza statystyczna: rozkład protokołów, top talkers,
  porównanie ACCEPT vs REJECT. `fetch-flowlogs.sh` wypisuje już wstępne
  statystyki (liczba ACCEPT/REJECT, top porty docelowe).

## Uwagi

- Skrypty wymagają reguły ICMP w security groups (ruch ICMP z VPC CIDR) —
  bez niej ping między instancjami nie zadziała.
- `02-ssh.sh` wymaga forwardowania agenta SSH — łącz się z bastionem przez
  `ssh -A`.
- Po zakończonej sesji pamiętaj o `terragrunt run --all destroy`, aby nie
  zużywać godzin Free Tier. Cała infrastruktura odtwarza się przez `apply`.