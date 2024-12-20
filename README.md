# ASD-checkpoint-alexandre  

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
