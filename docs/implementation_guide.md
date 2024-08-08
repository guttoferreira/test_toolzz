# Terraform

### Este código Terraform configura a infraestrutura necessária para hospedar um WordPress em um ambiente AWS. Inclui a configuração de VPC, EC2, RDS, EKS e gerenciamento de segredos.

OBS: Não foram utilizados nenhum wrapper para o terraform, como Terragrunt, Pulumi, Atlantis dentre outros, ou seja, é um terraform "puro".

## Arquitetura

A arquiterura foi construída de forma híbrica, utilizando modulos da comunidade e recursos.

Recursos utilizados:

- 01 VPC "main" com 6 subnets públicas e 6 subnets privadas na região us-east-1
    - Tabelas de rotas publica e privada
    - Não foi criado NAT Gateway para subnets privadas
    - Criado Internet Gateway para subntes publicas
- EC2 
    01 EC2 utilizada como bastion host para acesso ao banco de dados
- EKS
    - 01 cluster EKS com 1 grupo de nós e 1 instância.
- CloudWatch 
    - Criado grupos de logs do EKS e RDS
- RDS 
    - 01 banco de dados MySQL MariaDB vinculado com wordpress
- Security Groups para os seguintes recursos:
    - VPC
    - EC2
    - RDS
- Route53
- Secrets Manager
    - Armazenado segredos do banco RDS e chave de acesso da EC2
- IAM
    - Criada role e policy de acesso ao EKS
