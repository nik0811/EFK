## Elasticsearch/fluentd/kibana on kind cluster

This repository contains script which will help devops guy to setup quick development setup of `Elasticsearch, Fluentd and kibana` on `Kind Cluster`.

## Why to create Script?
If you are running the kind cluster on local development server on VMware/Workstation which requires to be shutdown in non-working hour then It will become hell for you to setup entire thing from scratch.

## How to run the Script ?

```
    $ ./efk.sh -- h
    Usage:
        -h help
        -a action  #Value=deploy/destroy

    Example:
       1. To Destroy the Kind Cluster

          `$ ./efk.sh -a destroy`

       2. To Deploy the Kind Cluster with EFK and Sample nodejs App

         `$ ./efk.sh -a deploy`
```
    
# To Access Different Services Use below URL's:

## Elasticsearch

`http://nodeIP/elastic`
    
## Kibana
 
 `http://nodeIP/kibana`

## NodeJs Sample App

`http://nodeIP/node`

