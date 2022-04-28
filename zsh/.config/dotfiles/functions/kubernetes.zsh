function argocd-login {
    argocd login localhost:8080 --sso
}

function argocd-add {
    REMOTE=$(git config --get remote.origin.url)
    argocd repo add $REMOTE --ssh-private-key-path ~/.ssh/id_argocd_rsa --insecure-ignore-host-key --upsert 
}

function argocd-proxy {
    kubectl port-forward svc/argocd-server -n argocd 8080:443
}

# Set up kubernetes config
function eks-kube-conf {
    REGION=${AWS_REGION:-eu-central-1} # Region to use for kubeconf
    aws --region $REGION eks update-kubeconfig --name ${1:-$AWS_ENVIRONMENT}
}

# AKS Kube config
function aks-kube-conf {
    RESOURCE=${1:-$AZ_RESOURCE} 
    RESOURCE=${RESOURCE:-mo-develop}
    az aks get-credentials --name ${RESOURCE}-aks --resource-group ${RESOURCE}-resources
}

function proxy-vault {
    VAULT_POD=$(kubectl get pods -n infrastructure -l "app=vault" -o jsonpath="{.items[0].metadata.name}")
    kubectl port-forward -n infrastructure $VAULT_POD 8200
}

function proxy-consul {
    kubectl port-forward svc/consul -n infrastructure 8500
}

function proxy-kafka {
    kubectl port-forward svc/kafka -n infrastructure 9092
}

function kafka-list-topics {
    kubectl -n infrastructure exec ${KAFKA_TEST_POD} -- \
    /usr/bin/kafka-topics --zookeeper ${ZOOKEEPER_ADDR} --list
}

function kafka-describe-topic {
    kubectl -n infrastructure exec ${KAFKA_TEST_POD} -- \
    /usr/bin/kafka-topics --describe --zookeeper ${ZOOKEEPER_ADDR} --topic $1
}

function kafka-create-topic {
    kubectl -n infrastructure exec ${KAFKA_TEST_POD} -- \
    /usr/bin/kafka-topics --zookeeper ${ZOOKEEPER_ADDR} \
    --topic ${1} --create --partitions 1 --replication-factor 1
}

function kafka-delete-topic {
    kubectl -n infrastructure exec ${KAFKA_TEST_POD} -- \
    /usr/bin/kafka-topics --zookeeper ${ZOOKEEPER_ADDR} --delete \
    --topic ${1} 
}

function kafka-listen-topic {
    kubectl -n infrastructure exec -ti ${KAFKA_TEST_POD} -- \
    /usr/bin/kafka-console-consumer --bootstrap-server ${KAFKA_ADDR} \
    --topic $1 --from-beginning
}

function kproxy {
    # Available methods 
    # inject-tcp
    # vpn-tcp
    method=${METHOD:-"vpn-tcp"}
    telepresence --deployment $MO_USER --method $method $@ --run $SHELL 
}

function kforward {
    kproxy --expose $1
}
