# DSM-P5-G05-2025-2
Repositório do GRUPO 05 do Projeto Interdisciplinar do 5º semestre DSM 2025/2

![Status](https://img.shields.io/badge/Status-Concluído-green)
![Flutter](https://img.shields.io/badge/Mobile-Flutter-blue)
![Spring Boot](https://img.shields.io/badge/Backend-Spring%20Boot-green)
![Python](https://img.shields.io/badge/AI-Python-yellow)

## 📖 Sobre o Projeto

Este projeto consiste no desenvolvimento de uma **aplicação móvel de rede social**, projetada para integrar as facetas pessoal e profissional dos usuários. Diferente das soluções tradicionais, a plataforma permite definir categorias profissionais para networking sem perder a leveza do compartilhamento de momentos diários.

**Diferencial:** O foco central da aplicação é a **Saúde Mental Digital**. O sistema não funciona apenas como um feed, mas integra um módulo de Inteligência Artificial que monitora padrões de uso para identificar comportamentos excessivos e enviar alertas preventivos, promovendo o uso consciente da tecnologia.

### 🚀 Principais Funcionalidades

* **Rede Social híbrida:** Perfis com informações acadêmicas/profissionais e feed de interações sociais.
* **CRUD Completo:** Criação, leitura, atualização e remoção de postagens e interações.
* **Networking:** Filtros por categorias profissionais para facilitar conexões.
* **Smart Health Alerts:** Sistema baseado em IA que analisa o tempo de tela e notifica o usuário sobre possíveis padrões de vício.

---

## 🛠 Tecnologias Utilizadas

A arquitetura foi projetada para garantir escalabilidade e alta disponibilidade na nuvem.

| Camada | Tecnologia | Detalhes |
| :--- | :--- | :--- |
| **Frontend (Mobile)** | Flutter (Dart) | Gerenciamento de estado com Cubits (Bloc). |
| **Backend (API)** | Java (Spring Boot) | API RESTful robusta. |
| **Banco de Dados** | PostgreSQL | Hospedado na Oracle Cloud Infrastructure (OCI). |
| **Inteligência Artificial** | Python | Análise de dados e geração de alertas de saúde. |
| **Serviços Extras** | Firebase | Autenticação e Notificações. |

---

## ⚙️ Como Executar o Projeto

Siga as etapas abaixo para rodar a aplicação em seu ambiente local.

### Pré-requisitos

Certifique-se de ter instalado em sua máquina:
* [Flutter SDK](https://flutter.dev/docs/get-started/install)
* [Java JDK 17+](https://www.oracle.com/java/technologies/downloads/)
* [Python 3.8+](https://www.python.org/downloads/)
* [PostgreSQL](https://www.postgresql.org/download/) (ou acesso à instância OCI)

### 1. Clonar o Repositório

```bash
git clone [https://github.com/FatecFranca/DSM-P5-G05-2025-2.git]
cd .\DSM-P5-G05-2025-2\echo
```

### 2. Configuração do Banco de Dados
Crie um banco de dados PostgreSQL local ou configure as credenciais da OCI no arquivo de propriedades da API.

```bash
CREATE DATABASE rede_social_db;
```

### 3. Executando o Backend (Spring Boot)
Navegue até a pasta do backend e execute:

```bash
cd backend
./mvnw spring-boot:run
```
*O servidor iniciará geralmente em http://localhost:8080.*

### 4. Executando o Módulo de IA (Python)
Instale as dependências e inicie o serviço de análise:

```bash
cd ai-module
pip install -r requirements.txt
python main.py
```

### 5. Executando o App Mobile (Flutter)
Com o backend e a IA rodando, inicie o aplicativo:

```bash
cd mobile
flutter pub get
flutter run
```
---
