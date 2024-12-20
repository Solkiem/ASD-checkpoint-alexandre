# ASD-checkpoint-alexandre  

(I USE PARENTHESIS TO AVOID THE COMMENTS IN FILE TO BE TRANSFORMED IN H1 BECAUSE OF THE MARKDOWN)  

## 1.1 Manipulation : Develop a bash script  

I did create the bash script under the name `lxc_container_create.sh` to create the container then I did another script to add Networks to the container `addNetworksToTheContainer.sh`  
Pay attention because `lxc_container_create.sh` needs multiple environnement variables named PROXMOX_TOKEN= / PROXMOX_SECRET= / CONTAINER_PASSWORD= (And VMID= but it will be created with the execution of `lxc_container_create.sh`) so you need to fill those variables before executing the script
So you have to use `lxc_container_create.sh` first then `addNetworksToTheContainer.sh`  

## 1.2 Managing users, groups and permissions  

### Créer un compte utilisateur portant le nom "wilder", pour lequel le répertoire de travail est /home/wilder/, faisant partie du groupe "wilder" et n'ayant pas de super privilèges  

root@checkpoint1-alexandre-152:~# adduser wilder  
Adding user `wilder' ...  
Adding new group `wilder' (1000) ...  
Adding new user `wilder' (1000) with group `wilder (1000)' ...  
Creating home directory `/home/wilder' ...  
Copying files from `/etc/skel' ...  
New password:  
Retype new password:  
passwd: password updated successfully  
Changing the user information for wilder  
Enter the new value, or press ENTER for the default  
        Full Name []: Alex  
        Room Number []: 1  
        Work Phone []:  
        Home Phone []:  
        Other []:  
Is the information correct? [Y/n] y  
Adding new user `wilder' to supplemental / extra groups `users' ...  
Adding user `wilder' to group `users' ...  

### Créer un répertoire "/home/share" et donner les droits à l'utilisateur "wilder" en lecture, écriture et exécution

root@checkpoint1-alexandre-152:~# cd /home/  
root@checkpoint1-alexandre-152:/home# mkdir share  
root@checkpoint1-alexandre-152:/home# ls  
share  wilder  
root@checkpoint1-alexandre-152:/home# chown -R wilder /home/share  
root@checkpoint1-alexandre-152:/home# chmod -R u+rwx /home/share  

### Créer un fichier "passwords.txt" dans /home/share" en passant par le biais du compte "wilder". Sans faire de chown, l'utilisateur "wilder" doit pouvoir avoir accès au fichier en lecture et écriture

root@checkpoint1-alexandre-152:/home# su - wilder  
wilder@checkpoint1-alexandre-152:~$  
wilder@checkpoint1-alexandre-152:~$ cd /home/share/  
wilder@checkpoint1-alexandre-152:/home/share$ touch password.txt  
wilder@checkpoint1-alexandre-152:/home/share$ ls  
password.txt  

### Créer un groupe "share"

wilder@checkpoint1-alexandre-152:/home/share$ su - root  
Password:  
root@checkpoint1-alexandre-152:~#  
root@checkpoint1-alexandre-152:~# groupadd -g 1005 share  

### Ajouter l'utilisateur "wilder" au groupe "share"

root@checkpoint1-alexandre-152:~# usermod -aG share wilder  
root@checkpoint1-alexandre-152:~# groups wilder  
wilder : wilder users share  

### Ajouter le groupe "share" à ton propre compte utilisateur (celui sur lequel tu es connecté)

root@checkpoint1-alexandre-152:~# usermod -aG share root  
root@checkpoint1-alexandre-152:~# groups root  
root : root share  

### Mettre les droits du groupe "share" en écriture et lecture sur le répertoire "/home/share" ainsi que tous les fichiers et sous répertoires qui se trouvent à l'intérieur

root@checkpoint1-alexandre-152:~# chown -R :share /home/share  
root@checkpoint1-alexandre-152:~# chmod -R g+rw /home/share  

### Chiffrer le répertoire "/home/share" pour qu'il ne soit pas lisible autrement qu'en le déchiffrant par un mot de passe

root@checkpoint1-alexandre-152:~# tar -czf /home/share.tar.gz /home/share  
openssl enc -aes-256-cbc -pbkdf2 -in /home/share.tar.gz -out /home/share.tar.gz.enc -k some_password_but_not_this_one  
tar: Removing leading `/' from member names  
root@checkpoint1-alexandre-152:/home/share# ls -lh /home/share.tar.gz.enc  
-rw-r--r-- 1 root root 192 Dec 20 10:58 /home/share.tar.gz.enc  
(I had a hard time doing this.)  

### Customer la session de l'utilisateur "wilder" en lui ajoutant un message qui s'affiche une fois connecté sous la forme suivante  

GNU nano 7.2  /home/wilder/.bashrc  
if [ -f ~/.bash_aliases ]; then  
    . ~/.bash_aliases  
fi  

(# enable programmable completion features (you don't need to enable)  
(# this, if it's already enabled in /etc/bash.bashrc and /etc/profile)  
(# sources /etc/bash.bashrc).)  
if ! shopt -oq posix; then  
  if [ -f /usr/share/bash-completion/bash_completion ]; then  
    . /usr/share/bash-completion/bash_completion  
  elif [ -f /etc/bash_completion ]; then  
    . /etc/bash_completion  
  fi  
fi  

(# Welcoming message)  

echo "============================="  
echo " -- Bienvenue cher Wilder -- "  
echo "============================="  
echo " - Hostname............: $(hostname)"  
echo " - Disk Space..........: $(df -h / | awk 'NR==2 {print $4}')"  
echo " - Memory used.........: $(free -h | awk 'NR==2 {print $3}')"  
echo "============================="  

root@checkpoint1-alexandre-152:/home/share# su - wilder  
=============================  
 -- Bienvenue cher Wilder --   
=============================  
 - Hostname............: checkpoint1-alexandre-152  
 - Disk Space..........: 6.8G  
 - Memory used.........: 25Mi  
=============================  
wilder@checkpoint1-alexandre-152:~$  

### 2.2 Question : quelles sont les adresses ip propre au conteneur ?

wilder@checkpoint1-alexandre-152:~$ ip addr show  
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000  
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00  
    inet 127.0.0.1/8 scope host lo  
       valid_lft forever preferred_lft forever  
    inet6 ::1/128 scope host noprefixroute  
       valid_lft forever preferred_lft forever  
2: CTNetwork@if386: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000  
    link/ether bc:24:11:ab:ec:57 brd ff:ff:ff:ff:ff:ff link-netnsid 0  
    inet6 2a01:4f8:141:53ea::152/64 scope global  
       valid_lft forever preferred_lft forever  
    inet6 fe80::be24:11ff:feab:ec57/64 scope link  
       valid_lft forever preferred_lft forever  

## Partie 3 : Sécurité du conteneur et durcissement ssh

### 3.1 Manipulation : sécuriser l'environnement distant

#### Modifier le port d'accès SSH du conteneur et faire en sorte que ça ne soit plus le port 22

(I USE PARENTHESIS TO AVOID THE COMMENTS IN FILE TO BE TRANSFORMED IN H1 BECAUSE OF THE MARKDOWN)  

root@checkpoint1-alexandre-152:~# nano /etc/ssh/sshd_config  

(# This sshd was compiled with PATH=/usr/local/bin:/usr/bin:/bin:/usr/games)  

(# The strategy used for options in the default sshd_config shipped with)  
(# OpenSSH is to specify options with their default value where)  
(# possible, but leave them commented.  Uncommented options override the)  
(# default value.)  

Include /etc/ssh/sshd_config.d/*.conf  

Port 719  
#AddressFamily any  
#ListenAddress 0.0.0.0  
#ListenAddress ::  
...  

#### Bloquer tous les ports du conteneur à l'aide d'un pare-feu logiciel

root@checkpoint1-alexandre-152:~# apt-get update  
Get:1 http://deb.debian.org/debian bookworm InRelease [151 kB]  
Get:2 http://security.debian.org bookworm-security InRelease [48.0 kB]  
Get:3 http://deb.debian.org/debian bookworm-updates InRelease [55.4 kB]  
Get:4 http://security.debian.org bookworm-security/main amd64 Packages [236 kB]  
Get:5 http://security.debian.org bookworm-security/main Translation-en [139 kB]  
Get:6 http://deb.debian.org/debian bookworm/main amd64 Packages [8,789 kB]  
Get:7 http://deb.debian.org/debian bookworm-updates/main amd64 Packages.diff/Index [14.0 kB]  
Ign:7 http://deb.debian.org/debian bookworm-updates/main amd64 Packages.diff/Index  
Get:8 http://deb.debian.org/debian bookworm-updates/main Translation-en.diff/Index [14.0 kB]  
Ign:8 http://deb.debian.org/debian bookworm-updates/main Translation-en.diff/Index  
Get:9 http://deb.debian.org/debian bookworm/main Translation-en [6,109 kB]  
Get:10 http://deb.debian.org/debian bookworm/contrib amd64 Packages [54.1 kB]  
Get:11 http://deb.debian.org/debian bookworm/contrib Translation-en [48.8 kB]  
Get:12 http://deb.debian.org/debian bookworm-updates/main amd64 Packages [8,856 B]  
Get:13 http://deb.debian.org/debian bookworm-updates/main Translation-en [8,248 B]  
Fetched 15.7 MB in 1s (12.1 MB/s)  
Reading package lists... Done  
N: Repository 'http://deb.debian.org/debian bookworm InRelease' changed its 'Version' value from '12.5' to '12.8'  
root@checkpoint1-alexandre-152:~# apt-get install iptables  
Reading package lists... Done  
Building dependency tree... Done  
Reading state information... Done  
The following additional packages will be installed:  
  libip6tc2 libnetfilter-conntrack3 libnfnetlink0  
Suggested packages:  
  firewalld  
The following NEW packages will be installed:  
  iptables libip6tc2 libnetfilter-conntrack3 libnfnetlink0  
0 upgraded, 4 newly installed, 0 to remove and 57 not upgraded.  
Need to get 435 kB of archives.  
After this operation, 2,728 kB of additional disk space will be used.  
Do you want to continue? [Y/n] Y  
Get:1 http://deb.debian.org/debian bookworm/main amd64 libip6tc2 amd64 1.8.9-2 [19.4 kB]  
Get:2 http://deb.debian.org/debian bookworm/main amd64 libnfnetlink0 amd64 1.0.2-2 [15.1 kB]  
Get:3 http://deb.debian.org/debian bookworm/main amd64 libnetfilter-conntrack3 amd64 1.0.9-3 [40.7 kB]  
Get:4 http://deb.debian.org/debian bookworm/main amd64 iptables amd64 1.8.9-2 [360 kB]  
Fetched 435 kB in 0s (10.8 MB/s)  
Selecting previously unselected package libip6tc2:amd64.  
(Reading database ... 19150 files and directories currently installed.)  
Preparing to unpack .../libip6tc2_1.8.9-2_amd64.deb ...  
Unpacking libip6tc2:amd64 (1.8.9-2) ...  
Selecting previously unselected package libnfnetlink0:amd64.  
Preparing to unpack .../libnfnetlink0_1.0.2-2_amd64.deb ...  
Unpacking libnfnetlink0:amd64 (1.0.2-2) ...  
Selecting previously unselected package libnetfilter-conntrack3:amd64.  
Preparing to unpack .../libnetfilter-conntrack3_1.0.9-3_amd64.deb ...  
Unpacking libnetfilter-conntrack3:amd64 (1.0.9-3) ...  
Selecting previously unselected package iptables.  
Preparing to unpack .../iptables_1.8.9-2_amd64.deb ...  
Unpacking iptables (1.8.9-2) ...  
Setting up libip6tc2:amd64 (1.8.9-2) ...  
Setting up libnfnetlink0:amd64 (1.0.2-2) ...  
Setting up libnetfilter-conntrack3:amd64 (1.0.9-3) ...  
Setting up iptables (1.8.9-2) ...  
update-alternatives: using /usr/sbin/iptables-legacy to provide /usr/sbin/iptables (iptables) in auto mode  
update-alternatives: using /usr/sbin/ip6tables-legacy to provide /usr/sbin/ip6tables (ip6tables) in auto mode  
update-alternatives: using /usr/sbin/iptables-nft to provide /usr/sbin/iptables (iptables) in auto mode  
update-alternatives: using /usr/sbin/ip6tables-nft to provide /usr/sbin/ip6tables (ip6tables) in auto mode  
update-alternatives: using /usr/sbin/arptables-nft to provide /usr/sbin/arptables (arptables) in auto mode  
update-alternatives: using /usr/sbin/ebtables-nft to provide /usr/sbin/ebtables (ebtables) in auto mode  
Processing triggers for man-db (2.11.2-2) ...  
Processing triggers for libc-bin (2.36-9+deb12u4) ...  
root@checkpoint1-alexandre-152:~# iptables -A INPUT -i eth0 -j DROP  
root@checkpoint1-alexandre-152:~# iptables -A OUTPUT -o eth0 -j DROP  
root@checkpoint1-alexandre-152:~# mkdir -p /etc/iptables  
root@checkpoint1-alexandre-152:~# sh -c "ip6tables-save > /etc/iptables/rules.v6"  
root@checkpoint1-alexandre-152:~# ip6tables -L -v  
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)  
 pkts bytes target     prot opt in     out     source               destination  

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)  
 pkts bytes target     prot opt in     out     source               destination  

Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)  
 pkts bytes target     prot opt in     out     source               destination  

#### Autoriser l'accès depuis le port SSH que tu viens de définir précédemment à l'aide du pare-feu logiciel

root@checkpoint1-alexandre-152:~# iptables -A INPUT -p tcp --dport 719 -j ACCEPT  
root@checkpoint1-alexandre-152:~# iptables -L -v  
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)  
 pkts bytes target     prot opt in     out     source               destination  
    0     0 DROP       all  --  eth0   any     anywhere             anywhere  
    0     0 ACCEPT     tcp  --  any    any     anywhere             anywhere             tcp dpt:719  

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)  
 pkts bytes target     prot opt in     out     source               destination  

Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)  
 pkts bytes target     prot opt in     out     source               destination  
    0     0 DROP       all  --  any    eth0    anywhere             anywhere  
root@checkpoint1-alexandre-152:~# sh -c "iptables-save > /etc/iptables/rules.v6"  

### 3.2 Question : quel autre moyen simple peux-tu mettre en œuvre pour augmenter la sécurité du conteneur ?

I can change /etc/ssh/sshd_config on this line : `#PermitRootLogin prohibit-password` to this : `PermitRootLogin no`  
So root wont be accessible from outside.  

## Partie 4 : Scripting Bash

### 4.1 Manipulation : script bash de connexion distante

GNU nano 7.2     /etc/systemd/system/sockets.target.wants/ssh.socket                                                    
[Unit]
Description=OpenBSD Secure Shell server socket
Before=sockets.target
ConditionPathExists=!/etc/ssh/sshd_not_to_be_run

[Socket]
ListenStream=719
Accept=no

[Install]
WantedBy=sockets.target
root@checkpoint1-alexandre-152:~# systemctl daemon-reload
root@checkpoint1-alexandre-152:~# systemctl restart ssh
root@checkpoint1-alexandre-152:~# systemctl status ssh
● ssh.service - OpenBSD Secure Shell server
     Loaded: loaded (/lib/systemd/system/ssh.service; enabled; preset: enabled)
     Active: active (running) since Fri 2024-12-20 12:21:06 CET; 3s ago
TriggeredBy: ● ssh.socket
       Docs: man:sshd(8)
             man:sshd_config(5)
    Process: 1832 ExecStartPre=/usr/sbin/sshd -t (code=exited, status=0/SUCCESS)
   Main PID: 1833 (sshd)
      Tasks: 1 (limit: 76989)
     Memory: 1.4M
        CPU: 16ms
     CGroup: /system.slice/ssh.service
             └─1833 "sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups"

Dec 20 12:21:06 checkpoint1-alexandre-152 systemd[1]: Starting ssh.service - OpenBSD Secure Shell server...
Dec 20 12:21:06 checkpoint1-alexandre-152 sshd[1833]: Server listening on :: port 719.
Dec 20 12:21:06 checkpoint1-alexandre-152 systemd[1]: Started ssh.service - OpenBSD Secure Shell server.

Didn't succeed here i don't why my ipv6 adress isn't reachable.

### 4.2 Question : Qu'est censé faire le script Bash ci-dessous ?

It checks the CPU usage of the machine, then if the MAX (95 here) is exceeded it will send an email to : "wilder@email.sh"  

### 4.2 Question : Est-ce que l'utilisateur "wilder" va pouvoir installer des paquets logiciels tels que apache ou nginx ? Que la réponse soit oui ou non, expliquer pourquoi en quelques mots

wilder isn't a sudoers so he won't be able to install packages. If you want him to be able to you need to edit sudoers file and add him to the list.

## Partie 5 : 10 questions sur le thème DevOps

### 5.1 Qu'est-ce que l'infrastructure as code (IaC) ?

It's a process that ables you to help to configure infrastructure, it will allow you to do it faster, it helps automation. Some known tools : Terraform, OpenTofu, Ansible ...  

### Est-ce que Docker est une nécessité dans le milieu DevOps ? (Expliquer la réponse)

No it isn't MANDATORY, no tools are mandatory to do a task, but it can help a lot because docker is a very powerful and well maintained, have a huge community. It a nice tool to know how to use it, nice tool to use. But it isn't mandatory.

### 5.3 Qu'est-ce qu'une pipeline CI/CD ?

CI/CD stands for Continuous Integration / Continuous Deployment. So a pipleline CI/CD is a tool that allow you to run builds, tests etc ... to facilitate and ables you to automate those tasks. It will make the realease of your app a lot smoother, if you configure it well and will catch a lot of problems before the realease so you will not have them on your app when you realease it. Known tools : Gitlab CI/CD, Github actions etc ...

### 5.4 Quel outil (logiciel) utiliserais tu pour gérer des configurations serveurs à distance ?

openSSH

### 5.5 Que signifie le terme "scalabilité" pour le milieu DevOps ?

Le fait d'avoir un logiciel / app ... évolutive, qui peut s'adapter aux modifications, montées de charges etc ...

### 5.6 Quel est le principal rôle d'un administrateur système DevOps en entreprise ?

To be a facilitator for the system administration tasks performed in the company, in the sense that we will optimize, via scripts to automate, via tools (such as Docker, OpenTofu etc.), tasks that can be tedious, expensive (in money and/or time) if not optimize. He will have to monitor the optimization implemented and evolve it to meet the needs of the company.

### 5.7 Quel outil (plateforme) utiliserais tu pour créer une pipeline de déploiement logiciel ?

Github actions or Gitlab CI/CD

### 5.8 Quels types d'environnements mettrais tu en place avant une mise en production de logiciel ?

I would use a container for our app, for example using docker, to do isolated tests to verify that our app is working well.

### 5.9 Qu'est-ce que signifie exactement la notion d'intégration continue (CI) ?

It the fact that you are able to modify constantly our app, without being blocked by heavy process or working habits that blocked little features or hotfixes to be realeased. You are able to work with agile methodology with CI.

### 5.10 Que signifie la notion de "provisionning" pour un administrateur système DevOps ?

It is the process to setup an infrastructure and manage acess to the data. So you have to manage security acess, user creation and permissions.