# Projeto de Teste: WordPress no EKS

Este projeto configura e gerencia um cluster Amazon EKS (Elastic Kubernetes Service) para a implantação de um aplicativo WordPress. O objetivo é demonstrar a configuração de infraestrutura e o processo de CI/CD (Integração Contínua e Entrega Contínua) usando Terraform e GitHub Actions.

## Estrutura do Projeto

O projeto está organizado da seguinte forma:

- `.github/workflows/main.yml`: Arquivo de workflow do GitHub Actions para automação do pipeline.

- **docs/**: Contém documentação adicional.
  - `README.md`: Este arquivo.
  - `implementation_guide.md`: Guia de implementação da infraestrutura.
  - `ci_cd_guide.md`: Guia para o pipeline CI/CD.

- **eks/**: Contém os arquivos deployment.yaml, service.yaml e secrets.yaml utilizados para configurar o EKS
  - `deployment.yaml`: Define um Deployment no Kubernetes
  - `service.yaml`: Define um Service no Kubernetes.
  - `secrets`: Define o secrets no Kubernetes, não incluso no diretorio público por questões de segurança.

- **terraform/**: Contém os arquivos de configuração do Terraform para definir e provisionar a infraestrutura.
  - `main.tf`: Arquivo principal com a configuração do Terraform.
  - `modules/`: Diretório com módulos Terraform reutilizáveis para configurar a infraestrutura.
  - `variables/`: Diretório com as variáveis do terraform.

- **video/**: Contém um vídeo explicativo do projeto.
  - `video_explicativo.mp4`: Vídeo com uma explicação detalhada do projeto.

## Configuração da Infraestrutura

### Arquivo `main.tf`

O arquivo `main.tf` define a infraestrutura do projeto usando o Terraform. As principais configurações incluem:

1. **Provider AWS**:
   - Configura a região e o perfil do projeto.

2. **VPC**:
   - Cria uma Virtual Private Cloud (VPC) com subnets públicas e privadas.

3. **EC2**:
   - Provisiona uma instância EC2 com um grupo de segurança configurado para permitir acesso SSH.

4. **RDS**:
   - Configura um banco de dados MariaDB usando Amazon RDS.

5. **EKS**:
   - Cria um cluster EKS com um grupo de nós gerenciados.
   - Configura o acesso ao cluster e as permissões necessárias.

6. **Secrets Manager**:
   - Armazena e gerencia a chave pública para a instância EC2 e RDS

7. **Security Groups**:
   - Define grupos de segurança para EC2 e RDS.

## Pipeline CI/CD

### Arquivo `.github/workflows/main.yml`

O pipeline CI/CD é configurado usando GitHub Actions e é dividido em três etapas principais:

1. **Build**:
   - Constrói a imagem Docker do WordPress e puxa a versão mais recente do Docker Hub.

2. **Test**:
   - Executa um teste básico para verificar se o WordPress pode ser iniciado e acessado.

3. **Deploy**:
   - Configura as credenciais da AWS.
   - Atualiza o kubeconfig para acessar o cluster EKS.
   - Aplica os arquivos de configuração do Kubernetes para implantar o WordPress no EKS.

## Uso

1. **Configuração Inicial**:
   - Clone o repositório e navegue para o diretório `terraform/`.
   - Execute `terraform init` para inicializar o Terraform.
   - Execute `terraform apply` para provisionar a infraestrutura.

2. **Pipeline CI/CD**:
   - O pipeline é acionado automaticamente em push para o branch `main`.
   - Certifique-se de que as credenciais da AWS estejam configuradas nos secrets do repositório GitHub.

## Conclusão

Este projeto demonstra como configurar um ambiente EKS para a execução de um aplicativo WordPress e como automatizar o processo de CI/CD usando GitHub Actions. Para mais detalhes, consulte os arquivos `implementation_guide.md` e `ci_cd_guide.md` na pasta `docs/`.
