# Mental Health AI Companion
### DevOps Project — 24CS2018 | Karunya Institute of Technology

A mental health support chatbot deployed using a full DevOps pipeline.

## Stack
- **Backend**: Python + Flask
- **Frontend**: HTML/CSS/JS + Nginx
- **Containers**: Docker + Docker Hub
- **Orchestration**: Kubernetes
- **CI/CD**: GitHub Actions
- **IaC**: Terraform + Ansible

## Quick Start
```bash
docker-compose up --build
# Frontend: http://localhost:8080
# Backend:  http://localhost:5000
```

## Folder Structure
```
├── backend/          Flask API + tests
├── frontend/         Chat UI
├── kubernetes/       K8s manifests
├── terraform/        Infrastructure as Code
├── ansible/          Deployment automation
├── .github/workflows CI/CD pipeline
└── docker-compose.yml
```
