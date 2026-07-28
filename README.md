# Atividade Docker + CI — Edson Felipe

Aluno(a): Edson Felipe Rocha Constancio

Turma: Iteam - Noturno

Data: 24/07/2026

Aplicação usada: docker/getting-started-app — To-Do em Node.js
# 1. Como executar este projeto
```
git clone https://github.com/OEdsonFelipe/meu-projeto-docker.git
cd meu-projeto-docker
cp .env.example .env
docker compose up -d --build
```
- Acesse: http://localhost:3000
- Para derrubar: docker compose down (mantém dados) ou docker compose down -v (apaga dados).

# 2. Imagem e Dockerfile multi-stage

Estágios utilizados: builder (instala dependências, incluindo desenvolvimento) e estágio de produção (runtime enxuto).

Imagem base: node:20-alpine

Usuário de execução: node (não-root)

Tamanho final da imagem: 67.9 MB

- Por que o multi-stage ajuda?

O multi-stage build descarta todo o ambiente de compilação, cache do gerenciador de pacotes e ferramentas residuais do primeiro estágio, enviando para a imagem final estritamente o código compilado e as bibliotecas essenciais para rodar a aplicação, o que reduz drasticamente o tamanho e a superfície de ataque da imagem final.

# Print 1 -  build + docker images
<img width="1917" height="788" alt="Captura de tela 2026-07-24 215631" src="https://github.com/user-attachments/assets/f6484ece-bfe0-4d82-bd7a-a8163ed5a04f" />

# Print 2 -  aplicação rodando com tarefas cadastradas
<img width="1917" height="890" alt="Captura de tela 2026-07-24 221429" src="https://github.com/user-attachments/assets/0c546bc8-4fd7-44a9-9514-5cfde8d41d93" />


# 3. Volumes e persistência

Volume usado: todo-mysql-data → montado em /var/lib/mysql dentro do container (para o MySQL).

# Print 3 - SEM volume: dados perdidos ao recriar o container
<img width="1917" height="885" alt="Captura de tela 2026-07-24 221103" src="https://github.com/user-attachments/assets/f41f2913-5530-4e8b-8ad1-1deb23619ce6" />

# Print 4 -  COM volume: dados preservados
<img width="1917" height="890" alt="Captura de tela 2026-07-24 221429" src="https://github.com/user-attachments/assets/0e8591df-18d6-4dcf-b4ba-5aad42f98efd" />

Diferença entre docker compose down e docker compose down -v :

O comando docker compose down destrói apenas os containers e redes (preservando o disco/volume intacto), enquanto a flag -v é destrutiva, pois apaga também os volumes, causando a perda definitiva dos dados.

# 4. Rede
Rede criada: todo-net

Serviços conectados: app e db

A porta do banco está exposta ao host?

Não — A porta 3306 não foi publicada para a máquina host por segurança, pois apenas a aplicação (que já está dentro da rede isolada do Docker) precisa acessá-lo.

Por que o app consegue chamar o host mysql / db sem saber o IP?

Porque o Docker possui um servidor de DNS embutido nas redes customizadas (bridge) que resolve automaticamente o nome do container/serviço para o endereço de IP interno correto.
# Print 5 — docker network inspect
<img width="1865" height="930" alt="Captura de tela 2026-07-24 231220" src="https://github.com/user-attachments/assets/d8f01791-ba1c-4b1b-99c2-7a4aa5a40b7b" />
# Print 6 -  dados dentro do MySQL (select * from todo_items;)
<img width="1607" height="643" alt="Captura de tela 2026-07-24 231350" src="https://github.com/user-attachments/assets/1a17daa8-18a2-4211-ac34-ba9d43f3eec3" />

# 5. Docker Compose
  Serviços: app, db

  Rede: todo-net

  Volume: todo-mysql-data

  Healthcheck em: db

  depends_on com: condition: service_healthy

  Variáveis sensíveis: carregadas via .env (não versionado). Modelo em .env.example.

# Print 7 — docker compose ps
<img width="1891" height="142" alt="Captura de tela 2026-07-25 005310" src="https://github.com/user-attachments/assets/cc6222fa-e15c-49fe-8946-fae1f9503fa3" />

# teste de persistencia: 
<img width="1917" height="711" alt="Captura de tela 2026-07-24 233101" src="https://github.com/user-attachments/assets/a00b0b3e-0398-4361-b635-6dd1b364b9e3" />
<img width="1902" height="671" alt="Captura de tela 2026-07-24 233217" src="https://github.com/user-attachments/assets/fb52f225-5516-4f89-8e04-64164c2ab19d" />

# 6. Integração Contínua (GitHub Actions)
Arquivo do workflow: .github/workflows/ci.yml

Gatilhos: push e pull_request

O que o pipeline faz:
1 - Valida a sintaxe e as variáveis do compose.yaml (docker compose config)

2 - Builda a imagem da aplicação (docker compose build)

3 - Sobe a stack completa em background (docker compose up -d)

4 - Aguarda a aplicação responder via Healthcheck simulado e faz o Smoke test (cria e consulta uma tarefa via requisições HTTP da API)

5 - Derruba a stack limpando o ambiente (docker compose down -v)

# Print 8 — execução verde ✅

<img width="1907" height="842" alt="Captura de tela 2026-07-25 000435" src="https://github.com/user-attachments/assets/d08fa6b0-eb70-4abd-a4ad-5911740fbf26" />
<img width="1432" height="328" alt="Captura de tela 2026-07-25 000556" src="https://github.com/user-attachments/assets/c05711c7-3f3b-4607-bfd9-87eefee6d4d0" />


# 7. Quebra proposital do CI

O que eu quebrei: Alternei a URL da API no passo de teste (comando curl) de /items para uma rota inexistente chamada /itemsss.

Erro que apareceu no log: Erro 22 no cURL informando falha ao acessar a rota.

Como o CI reagiu: O pipeline falhou exatamente no step "Smoke test do CRUD", e o fluxo do Pull Request ficou vermelho (bloqueado).

Como eu corrigi: Ajustei o arquivo ci.yml na mesma branch, desfazendo o erro e voltando a rota para o correto /items, efetuando um novo commit e push.

Link do Pull Request: [Cole aqui a URL do seu Pull Request do GitHub]

# Print 9 — execução vermelha ❌ + log do erro
<img width="1907" height="987" alt="Captura de tela 2026-07-25 001202" src="https://github.com/user-attachments/assets/8683eace-8a29-4ee8-a9ca-a45e29f0c662" />

# 8. Dificuldades e aprendizados
- Foi uma experiência incrível, adquiri aprendizados gigantescos, e errei muitas vezes e aprendi com esses erros!
# 9. Checklist de autoavaliação

    [x] Dockerfile multi-stage funcionando

    [x] .dockerignore presente

    [x] Container não roda como root

    [x] Volume nomeado + persistência demonstrada

    [x] Rede nomeada + banco não exposto ao host

    [x] compose.yaml sobe tudo com um comando

    [x] .env no .gitignore e .env.example versionado

    [x] CI verde

    [x] PR com CI vermelho documentado

    [x] Todos os 9 prints no README
    
# CD — Publicação no Docker Hub

- Aluno(a): Edson Felipe Rocha Constancio Turma: ITEAM-Noturno
- Usuário do Docker Hub: OEdsonFelipe
- Imagem publicada: oedsonfelipe/meu-projeto-docker:latest
- Link da imagem no Docker Hub: https://hub.docker.com/r/oedsonfelipe/meu-projeto-docker
- Dispara quando: push na branch main
- Arquivo do workflow: .github/workflows/cd.yml

# Print 1 — token criado no Docker Hub 
<img width="1915" height="547" alt="Print 1 - CD" src="https://github.com/user-attachments/assets/1df5abf6-4b84-4758-9c61-5b8f7aea9b1e" />

# Print 2 — Secrets cadastrados no GitHub (DOCKERHUB_USERNAME e
DOCKERHUB_TOKEN)
<img width="1915" height="902" alt="Print 2 - CD" src="https://github.com/user-attachments/assets/24d3d1cc-21e8-4f44-b5d8-2b3c1f6fb404" />

# Print 3 — workflow de CD verde na aba Actions
<img width="1905" height="655" alt="Print 3 - CD em ação" src="https://github.com/user-attachments/assets/909a6303-4353-4535-85a3-56eabd97c48c" />

# Print 4 - imagem publicada no Docker Hub
<img width="1917" height="707" alt="Print 4 - Hub Docker" src="https://github.com/user-attachments/assets/957da6c7-a81f-4e3f-8fd7-8290ba704002" />

# Print 5 - docker pull baixando a imagem publicada
<img width="1475" height="282" alt="Captura de tela 2026-07-28 001445" src="https://github.com/user-attachments/assets/e89c904d-bd34-4e1e-97f7-9ea843422e63" />
<img width="1908" height="898" alt="Captura de tela 2026-07-28 002011" src="https://github.com/user-attachments/assets/c460f6bc-a1bc-45c2-91ce-cf52f47e4662" />

# Respostas
1. O que é o Docker Hub? Serve para compartilhar e baixar as imagens de containers na nuvem.
2. Diferença entre CI e CD: CI automatiza a junção e os testes do código. Já o CD ele pega esse código testado e o leva automaticamente para ambientes de produção ou servidores de forma rápida e segura.
3. Por que usar token e Secrets em vez de escrever usuário e senha no cd.yml ? Por privacidade e boas práticas.
4. O que significa a tag latest ? É um nome padrão aplicado a imagem do container, usa-se quando não tem nenhuma outra versão.





