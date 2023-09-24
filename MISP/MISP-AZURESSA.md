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
- availability: no infrastructure redudancy needed (on test cases)

Real configuration things:
- OS: Ubuntu server 22.04 LTS - x64 gen2
- Size: Standard_D2as_v5 (71,07€/month)

# Misp activities

## Docker


## Misp on docker
Proceed with the steps mentioned here, ish:
- https://github.com/misp/misp-docker


### Fetch files

```
https://github.com/misp/misp-docker
cd misp-docker
cp template.env .env
vi .env
```

### Build container

```
docker-compose build
```

### Run container

```
docker-compose up
```

### Troubleshooting

- In case docker try to use url "localhost", then you have to configure .env file and rerun container