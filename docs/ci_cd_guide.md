# Pipeline CI/CD Github Actions

### A pipeline está dividida em 3 fases, build, test e deploy


1. Build
Constrói uma imagem Docker para o WordPress. Realiza o pull da imagem mais recente do Docker Hub.

2. Test
Executa um teste básico para verificar se a imagem Docker do WordPress está funcionando corretamente. Cria um container Docker temporário, verifica se o WordPress está acessível e depois limpa o container.

3. Deploy
Configura credenciais AWS e atualiza o kubeconfig para interagir com o cluster EKS. Faz o deploy do WordPress no EKS aplicando configurações de deployment e service definidas em arquivos YAML salvos no diretório eks.
