# Info

This document supposed to contain all necessary info how I build a misp instance in azure

# Preparations

- resource group
- virtual machine

## Resource group

- Activity: Create a new resource group, just pic a good name and add all resources to this newly created resource groups

- Why: to see the costs and to be able to delete test instance later on easily

## Virtual machine

Low priority settings:
- Name
- Region

Medium:
- availability: no infrastructure redudancy needed (on test cases, saving costs)

Real configuration things:
- OS: Ubuntu server 22.04 LTS - x64 gen2
- Size: Standard_D2as_v5 (71,07€/month)

Disk - standard SSD instead of premium SSD (local redudant storage, saving costs)

## Additional azure related actions

**NSG** - there is a *network security group* containing allow/deny rues for the network addresses - fix that.

- Allow SSH
- Allow HTTP
- Allow HTTPS

Initial installation contains SSH if you enabled so, reconfigure that from "any -> any" to "myip -> any".

# Misp activities

- This is assuming you have built everything as above mentioned (ie, running your docker in ubuntu instance that is in azure)



## Docker

- Assumption is that you run the environment on docker, as instructed on misp page

Starting with the official documentation
- https://docs.docker.com/engine/install/ubuntu/

```
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

```
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose
```

Test that everything works:
```
sudo docker run hello-world
```

## Misp on docker

**Once the docker itself is installed, proceed with MISP**

Proceed with the steps mentioned here, ish:
- https://github.com/misp/misp-docker


### Fetch files

```
git clone https://github.com/misp/misp-docker
cd misp-docker
cp template.env .env
vi .env
```

### Build container

```
docker-compose build
```

This build container part takes some time - ~720 seconds


### Run container

```
docker-compose up
```

### Troubleshooting

- In case docker try to use url "localhost", then you have to configure .env file and rerun container