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
