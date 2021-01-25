Base EC2 2 node kubeadm cluster built on ubuntu with weave as cni

Will create sshkey.pem file in state directory, this code is meant for short term testing deployment

In any case EC2 instances will have SSM core enabled so shell can be opened on console. Will only allow communication from the External IP where the terrform was run, so over time your external IP may change and you will need to update.

Will also tag resources with your iam user name

S3 and ECR permisions are part of the instance profile in case you need to access admin bucket or pull images from ECR repo in your account

ssh -i sshkey.pem ubuntu@`tf output -raw -no-color External_IP`

Integrated a fair amount of the code from https://github.com/ams0/CKS/tree/main/kubeadm-containerd-multinode 