# ASD-checkpoint-alexandre  

## 1.1 Manipulation : Develop a bash script  

I did create the bash script under the name `lxc_container_create.sh` to create the container then I did another script to add Networks to the container `addNetworksToTheContainer.sh`  
Pay attention because `lxc_container_create.sh` needs multiple environnement variables named PROXMOX_TOKEN= / PROXMOX_SECRET= / CONTAINER_PASSWORD= (And VMID= but it will be created with the execution of `lxc_container_create.sh`) so you need to fill those variables before executing the script
So you have to use `lxc_container_create.sh` first then `addNetworksToTheContainer.sh`  
