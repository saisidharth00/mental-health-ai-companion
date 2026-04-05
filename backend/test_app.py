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
