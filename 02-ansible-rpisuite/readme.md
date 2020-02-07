# Remote bulk Raspberry Pi initilization with Ansible
2020.02.06

## Purpose
Ansible playbook for initialization and lockdown one or a set of Raspberry Pi with Ubuntu image with common tasks like setup hostname and static IP.

The playbook also serve as Ansible code sample of various tasks like j2 template and file editing.

## Tested environment
- Raspberry Pi 4 4GB
    - Ubuntu 19.10.1 64-bit image
- Ansible 2.9.3 on Mac OS 10.15.3 Catalina
    - Python 3.8.1

## Details and usage
Behavior of the stock Ubuntu 19.10 image on Raspberry Pi 4:
- eth0 set to dhcp
- default login ubuntu/ubuntu with no password sudo
- require password change at first login

Content in main.yaml is self-explanatory on what the playbook will do.
Basically:
- set static ip address & hostname
- create new user and deploy ssh key
- delete default ubuntu user
- disable SSH password authentication

There are tasks needed to be done before running the playbook:
- Get MAC address for each LAN interface of Raspberry Pi. On Mac OS this can be done with nmap in sudo. Like so:

        ❯ sudo nmap -sn 192.168.1.0/24 | grep -B2 'Raspberry'
        Nmap scan report for 192.168.1.28
        Host is up (0.00042s latency).
        MAC Address: DC:A6:32:XX:XX:XX (Raspberry Pi Trading)
        --
        Nmap scan report for ubuntu.lan (192.168.1.29)
        Host is up (0.00038s latency).
        MAC Address: DC:A6:32:XX:XX:XX (Raspberry Pi Trading)
        --
        Nmap scan report for 192.168.1.30
        Host is up (0.00026s latency).
        MAC Address: DC:A6:32:XX:XX:XX (Raspberry Pi Trading)

- Rename *sample-vars.yaml* to *vars.yaml*, populate these MAC address in lowercase\* and static IP you want to specify to each host in this file

> \* Because facts gathered by Ansible from each host comes in lowercase.

- Rename *sample-inventory.yaml* to *inventory.yaml*, populate the file with the current address of Raspberry Pi from result of nmap output above

- SSH to each host with user ubuntu to change the password at first login (required by ubuntu image)

- Copy SSH key to each host

        > ssh-copy-id ubuntu@192.168.1.x

- See if you have ssh key file ready in ~/.ssh directory. The playbook is hard-coded to ~/.ssh/id_ed25519.pub.

- Then run the playbook:

        > ansible-playbook -i inventory.yaml main.yaml

- IP address change won't take effect until reboot. This is a design choice to prevent lockout in case there's something wrong with user or ssh key 

- You can then reboot all the nodes:

        > ansible all -i inventory.yaml -m shell -a "sleep 1s; shutdown -r now" -b -B 60 -P 0

TODO: may look into image customization or cloud_init in the future.