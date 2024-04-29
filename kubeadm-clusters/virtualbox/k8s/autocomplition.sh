#!/bin/bash

# bash (Enable kubectl autocompletion on sysyem level)
# https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#enable-shell-autocompletion

sudo apt update

sudo apt install bash-completion -y

#type _init_completion

kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null

sudo chmod a+r /etc/bash_completion.d/kubectl

echo 'alias k=kubectl' >> ~/.bashrc
echo 'complete -o default -F __start_kubectl k' >> ~/.bashrc
source ~/.bashrc