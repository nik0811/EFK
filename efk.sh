#!/bin/bash
set -e
function main 
{
     init "$@"
     if [[ "$#" -eq 2 ]]; then
	     func=(create_kind_cluster nginx_ingress_kind elasticsearch set_elastic_search_passwd kibana app set_ingress_path fluentd) 
	     if [[ "$action" == "deploy" ]]; then
		     for main_func in ${func[@]}; do
			     if [[ $main_func == set_ingress_path ]]; then
				     while true; do
					     a=$(kubectl get pods -n ingress-nginx | grep "Running" | awk '{printf $2}')
					     if [[ "$a" == "1/1" ]]; then
						     break 
					     else    
						     sleep 10 &  
						     PID=$!
						     i=1
						     sp="****"
						     echo -n ' '
						     while [ -d /proc/$PID ]
						     do
							       printf "\b${sp:i++%${#sp}:1}"
						     done
					     fi
				     done
			     fi
			     echo ""
			     $main_func
		     done
             elif [[ "$action" == "destroy" ]]; then
		     destroy_kind_cluster
	     else
	             usage
             fi
     else
	     usage
     fi
} 
function sleep_time 
{
  sleep 10
}
function app 
{
   kubectl apply -f app.yaml
}

function  create_kind_cluster 
{   
    r=$(( $RANDOM % 10 ))
    cat <<EOF | kind create cluster --name kind-cluser-$r --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
EOF
}

function nginx_ingress_kind 
{
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml
}

function set_elastic_search_passwd 
{
     elastic_pass=$(kubectl exec -it $(kubectl get pods | grep elasticsearch-master-0 | sed -n 1p | awk '{print $1}') -- bin/elasticsearch-setup-passwords auto -b | grep "PASSWORD elastic = " | awk '{printf $4}')
     kubectl create secret generic elasticsearch-pw-elastic --from-literal password=$elastic_pass
}
	

function set_ingress_path
{
   arr_yaml=(elastic_ingress.yaml)
   for yaml in ${arr_yaml[@]}; do
	  kubectl apply -f $yaml 
   done
}

function elasticsearch 
{
   helm install --name-template elasticsearch elastic/elasticsearch --set imageTag=7.10.1-SNAPSHOT --set replicas=1 -f elasticsearch.yaml
}

function kibana 
{
   helm install --name-template kibana elastic/kibana --set imageTag=7.10.1-SNAPSHOT --set replicas=1 --set elasticsearchHosts=http://elasticsearch-master:9200 --set healthCheckPath=/kibana/app/kibana -f custom_kibana.yaml
}
function fluentd 
{
kubectl apply -f fluentd.yaml
}
function destroy_kind_cluster
{
	kind delete cluster --name $(kind get clusters)
}
function fix_docker_issue_affter_node_reboot
{
	sudo systemctl restart docker.service
}

function usage
{
    cat <<EOF
    Usage:
        -h help
        -a action  #Value=deploy/destroy
    Example:
        ./efk.sh -a deploy/destroy
EOF
}

function init
{
action=""
while getopts h:a: option;
do 
	case "${option}" in
        h) usage "";exit 1
		;;
	a) action=$OPTARG
		;;
	\?) usage ""; exit 1
		;;
        esac
done
}
main "$@"
