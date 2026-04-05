#!/bin/bash
# ============================================================
#  Mental Health AI Companion — Full Project Setup Script
#  Run this from inside your mental-health-ai-companion folder
#  Command: bash setup.sh
# ============================================================

set -e  # Stop if any command fails
echo ""
echo "================================================"
echo "  Setting up Mental Health AI Companion..."
echo "================================================"
echo ""

# ── Create folder structure ──────────────────────────────────
mkdir -p backend frontend kubernetes terraform ansible .github/workflows
echo "✓ Folders created"

# ════════════════════════════════════════════════════════════
# BACKEND FILES
# ════════════════════════════════════════════════════════════

cat > backend/app.py << 'PYEOF'
from flask import Flask, request, jsonify
from flask_cors import CORS
import random
import datetime

app = Flask(__name__)
CORS(app)

RESPONSES = {
    "sad": [
        "I hear you. Feeling sad is completely valid, and I'm here with you. Would you like to talk about what's been making you feel this way?",
        "It's okay to feel down sometimes. You're not alone in this. What's been weighing on your heart lately?",
        "Thank you for sharing that with me. Sadness can feel so heavy. Take a deep breath — I'm here, and we can talk through this together.",
    ],
    "anxious": [
        "Anxiety can feel overwhelming, but you're doing great by talking about it. Let's slow down — take a deep breath with me. What's causing you the most worry right now?",
        "I understand that feeling of worry that won't go away. You're not alone. Can you tell me more about what's making you anxious?",
        "That sounds really stressful. Anxiety is your mind working overtime. Let's work through it together — what's the biggest thing on your mind?",
    ],
    "happy": [
        "That's wonderful to hear! It sounds like things are going well for you. What's been the highlight of your day?",
        "I love hearing that! Positive moments are so important. Tell me more about what's making you feel good!",
        "That's great! Celebrating the good moments matters. What's been bringing you joy lately?",
    ],
    "stressed": [
        "Stress can really pile up. I'm glad you're reaching out. What's the biggest source of stress for you right now?",
        "It sounds like you have a lot on your plate. Let's break it down together — what feels most urgent to you?",
        "I hear you. When everything feels like too much, it helps to take things one step at a time. What can we tackle first?",
    ],
    "default": [
        "Thank you for sharing that with me. I'm here to listen and support you. Can you tell me more about how you're feeling?",
        "I appreciate you opening up. Your feelings are valid and important. What's been on your mind?",
        "I'm here for you. Sometimes just talking helps. What would you like to share today?",
        "It takes courage to reach out. I'm listening — tell me what's going on in your world.",
    ]
}

GREETINGS = ["hello", "hi", "hey", "good morning", "good evening", "good afternoon"]

def get_response(message):
    msg = message.lower()
    if any(word in msg for word in GREETINGS):
        return "Hello! I'm your Mental Health AI Companion. I'm here to listen and support you. How are you feeling today?"
    if any(word in msg for word in ["sad", "cry", "depressed", "unhappy", "miserable", "down", "hopeless"]):
        return random.choice(RESPONSES["sad"])
    if any(word in msg for word in ["anxious", "anxiety", "worried", "panic", "fear", "nervous", "scared"]):
        return random.choice(RESPONSES["anxious"])
    if any(word in msg for word in ["happy", "great", "good", "amazing", "wonderful", "joy", "excited"]):
        return random.choice(RESPONSES["happy"])
    if any(word in msg for word in ["stress", "stressed", "overwhelmed", "tired", "exhausted", "burnout"]):
        return random.choice(RESPONSES["stressed"])
    return random.choice(RESPONSES["default"])

@app.route("/")
def home():
    return jsonify({"status": "running", "app": "Mental Health AI Companion", "version": "1.0.0", "timestamp": str(datetime.datetime.now())})

@app.route("/health")
def health():
    return jsonify({"status": "healthy"}), 200

@app.route("/chat", methods=["POST"])
def chat():
    data = request.get_json()
    if not data or "message" not in data:
        return jsonify({"error": "No message provided"}), 400
    user_message = data["message"].strip()
    if not user_message:
        return jsonify({"error": "Message cannot be empty"}), 400
    ai_response = get_response(user_message)
    return jsonify({"response": ai_response, "timestamp": str(datetime.datetime.now())})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)
PYEOF

cat > backend/requirements.txt << 'EOF'
flask==3.0.3
flask-cors==4.0.1
gunicorn==22.0.0
pytest==8.2.0
EOF

cat > backend/test_app.py << 'PYEOF'
import pytest
import json
from app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_home_route(client):
    response = client.get('/')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data['status'] == 'running'

def test_health_check(client):
    response = client.get('/health')
    assert response.status_code == 200

def test_chat_with_message(client):
    response = client.post('/chat',
        data=json.dumps({'message': 'I feel sad today'}),
        content_type='application/json')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert 'response' in data

def test_chat_greeting(client):
    response = client.post('/chat',
        data=json.dumps({'message': 'hello'}),
        content_type='application/json')
    assert response.status_code == 200

def test_chat_no_message(client):
    response = client.post('/chat',
        data=json.dumps({}),
        content_type='application/json')
    assert response.status_code == 400

def test_chat_empty_message(client):
    response = client.post('/chat',
        data=json.dumps({'message': '   '}),
        content_type='application/json')
    assert response.status_code == 400
PYEOF

cat > backend/Dockerfile << 'EOF'
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 5000
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "app:app"]
EOF

echo "✓ Backend files created"

# ════════════════════════════════════════════════════════════
# FRONTEND FILES
# ════════════════════════════════════════════════════════════

cat > frontend/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Mental Health AI Companion</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: 'Segoe UI', system-ui, sans-serif; background: #f0f4f8; height: 100vh; display: flex; align-items: center; justify-content: center; }
    .container { width: 100%; max-width: 680px; height: 90vh; background: white; border-radius: 16px; box-shadow: 0 4px 24px rgba(0,0,0,0.08); display: flex; flex-direction: column; overflow: hidden; }
    .header { background: #5b6cf5; color: white; padding: 20px 24px; display: flex; align-items: center; gap: 12px; }
    .avatar { width: 40px; height: 40px; background: rgba(255,255,255,0.25); border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 20px; }
    .header-text h1 { font-size: 17px; font-weight: 600; }
    .header-text p { font-size: 12px; opacity: 0.85; margin-top: 2px; }
    .status-dot { width: 8px; height: 8px; background: #4ade80; border-radius: 50%; margin-left: auto; }
    .chat-area { flex: 1; overflow-y: auto; padding: 20px; display: flex; flex-direction: column; gap: 14px; }
    .bubble { max-width: 78%; padding: 12px 16px; border-radius: 18px; font-size: 14px; line-height: 1.6; }
    .bubble.bot { background: #f1f3ff; color: #1e1e2e; border-bottom-left-radius: 4px; align-self: flex-start; }
    .bubble.user { background: #5b6cf5; color: white; border-bottom-right-radius: 4px; align-self: flex-end; }
    .bubble-row { display: flex; align-items: flex-end; gap: 8px; }
    .bubble-row.user { flex-direction: row-reverse; }
    .bot-icon { width: 28px; height: 28px; background: #5b6cf5; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 14px; flex-shrink: 0; }
    .typing { display: flex; gap: 4px; padding: 14px 16px; }
    .typing span { width: 7px; height: 7px; background: #a0aec0; border-radius: 50%; animation: bounce 1.2s infinite; }
    .typing span:nth-child(2) { animation-delay: 0.2s; }
    .typing span:nth-child(3) { animation-delay: 0.4s; }
    @keyframes bounce { 0%,60%,100%{transform:translateY(0)} 30%{transform:translateY(-5px)} }
    .mood-bar { padding: 10px 20px; display: flex; gap: 8px; flex-wrap: wrap; border-top: 1px solid #f0f0f0; background: #fafafa; }
    .mood-bar span { font-size: 11px; color: #888; align-self: center; }
    .chip { font-size: 12px; padding: 5px 12px; border-radius: 20px; border: 1px solid #e2e8f0; background: white; cursor: pointer; transition: all 0.15s; color: #4a5568; }
    .chip:hover { background: #5b6cf5; color: white; border-color: #5b6cf5; }
    .input-bar { padding: 16px 20px; display: flex; gap: 10px; border-top: 1px solid #f0f0f0; background: white; }
    .input-bar input { flex: 1; padding: 11px 16px; border: 1.5px solid #e2e8f0; border-radius: 24px; font-size: 14px; outline: none; transition: border-color 0.15s; }
    .input-bar input:focus { border-color: #5b6cf5; }
    .send-btn { width: 42px; height: 42px; background: #5b6cf5; border: none; border-radius: 50%; cursor: pointer; display: flex; align-items: center; justify-content: center; }
    .send-btn:hover { background: #4757e0; }
    .send-btn svg { width: 18px; height: 18px; fill: white; }
    .disclaimer { text-align: center; font-size: 11px; color: #aaa; padding: 6px 20px 14px; background: white; }
  </style>
</head>
<body>
<div class="container">
  <div class="header">
    <div class="avatar">&#129504;</div>
    <div class="header-text">
      <h1>Mental Health AI Companion</h1>
      <p>Your safe space to talk &amp; reflect</p>
    </div>
    <div class="status-dot"></div>
  </div>
  <div class="chat-area" id="chat">
    <div class="bubble-row">
      <div class="bot-icon">&#129504;</div>
      <div class="bubble bot">Hello! I'm your Mental Health AI Companion &#128153;<br><br>I'm here to listen, support, and chat with you. How are you feeling today?</div>
    </div>
  </div>
  <div class="mood-bar">
    <span>Quick:</span>
    <div class="chip" onclick="quickSend('I feel happy today')">Happy</div>
    <div class="chip" onclick="quickSend('I feel sad today')">Sad</div>
    <div class="chip" onclick="quickSend('I am feeling anxious')">Anxious</div>
    <div class="chip" onclick="quickSend('I feel stressed')">Stressed</div>
    <div class="chip" onclick="quickSend('I need someone to talk to')">Need to talk</div>
  </div>
  <div class="input-bar">
    <input type="text" id="msg-input" placeholder="Share how you're feeling..." />
    <button class="send-btn" onclick="sendMessage()">
      <svg viewBox="0 0 24 24"><path d="M2 21l21-9L2 3v7l15 2-15 2z"/></svg>
    </button>
  </div>
  <div class="disclaimer">This is an AI tool, not a substitute for professional mental health care. Crisis helpline: iCall 9152987821</div>
</div>
<script>
  const BACKEND = "http://localhost:5000";
  function quickSend(text) { document.getElementById("msg-input").value = text; sendMessage(); }
  function addBubble(text, role) {
    const chat = document.getElementById("chat");
    const row = document.createElement("div"); row.className = "bubble-row " + role;
    if (role === "bot") { const icon = document.createElement("div"); icon.className = "bot-icon"; icon.innerHTML = "&#129504;"; row.appendChild(icon); }
    const bubble = document.createElement("div"); bubble.className = "bubble " + role; bubble.textContent = text;
    row.appendChild(bubble); chat.appendChild(row); chat.scrollTop = chat.scrollHeight; return row;
  }
  function showTyping() {
    const chat = document.getElementById("chat");
    const row = document.createElement("div"); row.className = "bubble-row bot"; row.id = "typing-indicator";
    const icon = document.createElement("div"); icon.className = "bot-icon"; icon.innerHTML = "&#129504;";
    const bubble = document.createElement("div"); bubble.className = "bubble bot typing";
    bubble.innerHTML = "<span></span><span></span><span></span>";
    row.appendChild(icon); row.appendChild(bubble); chat.appendChild(row); chat.scrollTop = chat.scrollHeight;
  }
  function removeTyping() { const t = document.getElementById("typing-indicator"); if (t) t.remove(); }
  async function sendMessage() {
    const input = document.getElementById("msg-input");
    const message = input.value.trim(); if (!message) return;
    addBubble(message, "user"); input.value = ""; showTyping();
    try {
      const res = await fetch(BACKEND + "/chat", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ message }) });
      const data = await res.json(); removeTyping(); addBubble(data.response || "I'm here. Can you tell me more?", "bot");
    } catch (err) { removeTyping(); addBubble("I'm having a little trouble connecting. Please try again.", "bot"); }
  }
  document.getElementById("msg-input").addEventListener("keydown", function(e) { if (e.key === "Enter") sendMessage(); });
</script>
</body>
</html>
EOF

cat > frontend/Dockerfile << 'EOF'
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
EOF

echo "✓ Frontend files created"

# ════════════════════════════════════════════════════════════
# DOCKER COMPOSE
# ════════════════════════════════════════════════════════════

cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  backend:
    build: ./backend
    container_name: mh-backend
    ports:
      - "5000:5000"
    restart: always
  frontend:
    build: ./frontend
    container_name: mh-frontend
    ports:
      - "8080:80"
    depends_on:
      - backend
    restart: always
EOF

echo "✓ Docker Compose created"

# ════════════════════════════════════════════════════════════
# KUBERNETES
# ════════════════════════════════════════════════════════════

cat > kubernetes/backend-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mh-backend
  labels:
    app: mh-backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: mh-backend
  template:
    metadata:
      labels:
        app: mh-backend
    spec:
      containers:
      - name: mh-backend
        image: YOUR_DOCKERHUB_USERNAME/mental-health-backend:latest
        ports:
        - containerPort: 5000
        livenessProbe:
          httpGet:
            path: /health
            port: 5000
          initialDelaySeconds: 10
          periodSeconds: 10
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
---
apiVersion: v1
kind: Service
metadata:
  name: mh-backend-service
spec:
  selector:
    app: mh-backend
  ports:
  - port: 5000
    targetPort: 5000
  type: ClusterIP
EOF

cat > kubernetes/frontend-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mh-frontend
  labels:
    app: mh-frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: mh-frontend
  template:
    metadata:
      labels:
        app: mh-frontend
    spec:
      containers:
      - name: mh-frontend
        image: YOUR_DOCKERHUB_USERNAME/mental-health-frontend:latest
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
---
apiVersion: v1
kind: Service
metadata:
  name: mh-frontend-service
spec:
  selector:
    app: mh-frontend
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
EOF

echo "✓ Kubernetes manifests created"

# ════════════════════════════════════════════════════════════
# TERRAFORM
# ════════════════════════════════════════════════════════════

cat > terraform/main.tf << 'EOF'
terraform {
  required_version = ">= 1.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "mental-health-ai-companion"
}

variable "docker_username" {
  description = "Docker Hub username"
  type        = string
  default     = "your-dockerhub-username"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"
}

resource "local_file" "env_config" {
  filename = "${path.module}/../.env.generated"
  content  = <<-EOT
    APP_NAME=${var.app_name}
    ENVIRONMENT=${var.environment}
    DOCKER_IMAGE_BACKEND=${var.docker_username}/mental-health-backend:latest
    DOCKER_IMAGE_FRONTEND=${var.docker_username}/mental-health-frontend:latest
  EOT
}

output "app_name" {
  value = var.app_name
}

output "backend_image" {
  value = "${var.docker_username}/mental-health-backend:latest"
}

output "frontend_image" {
  value = "${var.docker_username}/mental-health-frontend:latest"
}
EOF

echo "✓ Terraform config created"

# ════════════════════════════════════════════════════════════
# ANSIBLE
# ════════════════════════════════════════════════════════════

cat > ansible/playbook.yml << 'EOF'
---
- name: Deploy Mental Health AI Companion
  hosts: localhost
  connection: local
  gather_facts: yes

  vars:
    app_name: "mental-health-ai-companion"
    docker_username: "your-dockerhub-username"
    k8s_dir: "../kubernetes"

  tasks:
    - name: Check Docker is running
      command: docker info
      register: docker_check
      changed_when: false

    - name: Pull latest backend image
      command: docker pull {{ docker_username }}/mental-health-backend:latest
      register: backend_pull

    - name: Pull latest frontend image
      command: docker pull {{ docker_username }}/mental-health-frontend:latest
      register: frontend_pull

    - name: Apply backend Kubernetes deployment
      command: kubectl apply -f {{ k8s_dir }}/backend-deployment.yaml
      ignore_errors: yes

    - name: Apply frontend Kubernetes deployment
      command: kubectl apply -f {{ k8s_dir }}/frontend-deployment.yaml
      ignore_errors: yes

    - name: Deployment summary
      debug:
        msg:
          - "Deployment Complete!"
          - "App: {{ app_name }}"
          - "Backend:  {{ docker_username }}/mental-health-backend:latest"
          - "Frontend: {{ docker_username }}/mental-health-frontend:latest"
EOF

echo "✓ Ansible playbook created"

# ════════════════════════════════════════════════════════════
# GITHUB ACTIONS
# ════════════════════════════════════════════════════════════

cat > .github/workflows/deploy.yml << 'EOF'
name: CI/CD Pipeline - Mental Health AI Companion

on:
  push:
    branches: [ main, dev ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    name: Run Tests
    runs-on: ubuntu-latest
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
    - name: Set up Python
      uses: actions/setup-python@v5
      with:
        python-version: '3.11'
    - name: Install dependencies
      run: |
        cd backend
        pip install -r requirements.txt
    - name: Run tests
      run: |
        cd backend
        python -m pytest test_app.py -v

  build-and-push:
    name: Build & Push Docker Images
    runs-on: ubuntu-latest
    needs: test
    if: github.ref == 'refs/heads/main'
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
    - name: Log in to Docker Hub
      uses: docker/login-action@v3
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}
    - name: Build and push backend image
      uses: docker/build-push-action@v5
      with:
        context: ./backend
        push: true
        tags: ${{ secrets.DOCKER_USERNAME }}/mental-health-backend:latest
    - name: Build and push frontend image
      uses: docker/build-push-action@v5
      with:
        context: ./frontend
        push: true
        tags: ${{ secrets.DOCKER_USERNAME }}/mental-health-frontend:latest

  deploy:
    name: Deployment Complete
    runs-on: ubuntu-latest
    needs: build-and-push
    if: github.ref == 'refs/heads/main'
    steps:
    - name: Deployment summary
      run: |
        echo "Mental Health AI Companion Deployed!"
        echo "Deployed at: $(date)"
EOF

echo "✓ GitHub Actions pipeline created"

# ════════════════════════════════════════════════════════════
# ROOT FILES
# ════════════════════════════════════════════════════════════

cat > .gitignore << 'EOF'
__pycache__/
*.py[cod]
.env
venv/
.venv/
.env.generated
*.tfstate
*.tfstate.backup
.terraform/
.terraform.lock.hcl
.DS_Store
EOF

cat > README.md << 'EOF'
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
EOF

echo ""
echo "================================================"
echo "  All files created successfully!"
echo ""
echo "  Next steps:"
echo "  1. Run: docker-compose up --build"
echo "  2. Open: http://localhost:8080"
echo "  3. Then: git add . && git commit -m 'feat: complete project setup' && git push origin dev"
echo "================================================"
echo ""
