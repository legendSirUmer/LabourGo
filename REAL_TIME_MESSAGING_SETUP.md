# Real-Time Messaging System with Daphne WebSockets

This documentation covers the implementation of real-time messaging between customers and service providers using Django Channels and Daphne.

## Backend Setup (Django)

### 1. Install Dependencies

```bash
cd backend
pip install -r requirements.txt
```

### 2. Create Messaging App Migrations

```bash
python manage.py makemigrations messaging
python manage.py migrate messaging
```

### 3. Register Messaging App (Already Done in settings.py)

The `messaging` app has been added to `INSTALLED_APPS` in `core/settings.py`.

### 4. Configure Channels

The `core/asgi.py` has been configured to handle WebSocket connections.

For development without Redis:
```python
# In core/settings.py, switch to InMemoryChannelLayer:
CHANNEL_LAYERS = {
    'default': {
        'BACKEND': 'channels.layers.InMemoryChannelLayer'
    }
}
```

For production with Redis:
```bash
# Install Redis (example for Ubuntu)
sudo apt-get install redis-server

# Or use Docker
docker run -d -p 6379:6379 redis:latest

# Keep settings using redis as shown in settings.py
```

### 5. Running the Development Server

Use Daphne instead of Django's built-in server:

```bash
# Install Daphne (already in requirements.txt)
daphne -b 0.0.0.0 -p 8000 core.asgi:application
```

Or with auto-reload for development:

```bash
# Install django-extensions
pip install django-extensions

# Run with auto-reload
python manage.py runserver_plus --nothreading
```

### 6. API Endpoints

#### Get Chat Rooms (Conversations)
- **Endpoint**: `GET /api/messaging/chat-rooms/my_chats/`
- **Response**: List of chat rooms with latest message and unread count

#### Get Messages by Booking
- **Endpoint**: `GET /api/messaging/messages/by_booking/?booking_id=<id>`
- **Response**: List of all messages for a booking

#### Mark Messages as Read
- **Endpoint**: `POST /api/messaging/messages/mark_as_read/`
- **Body**: `{ "booking_id": <id> }`

#### Create Message (REST)
- **Endpoint**: `POST /api/messaging/messages/`
- **Body**: `{ "booking": <booking_id>, "content": "<message>" }`

### 7. WebSocket Connection

**Endpoint**: `ws://localhost:8000/ws/chat/<booking_id>/?token=<jwt_token>`

**Message Format (from client to server)**:
```json
{
  "message": "Your message here"
}
```

**Message Format (from server to client)**:
```json
{
  "type": "message",
  "message_id": 1,
  "sender_id": 123,
  "sender_name": "John Doe",
  "sender_avatar": "https://...",
  "receiver_id": 456,
  "content": "Message content",
  "created_at": "2024-01-01T12:00:00Z",
  "is_read": false
}
```

## Frontend Setup (Flutter)

### 1. Add Dependencies to pubspec.yaml

```yaml
dependencies:
  web_socket_channel: ^2.4.0
```

### 2. Run Flutter Pub Get

```bash
cd labourgo_app
flutter pub get
```

### 3. WebSocket Service Configuration

Update the WebSocket service in `lib/services/websocket_service.dart`:

```dart
// Change localhost to your server URL
final wsUrl = Uri.parse(
  'ws://YOUR_SERVER_IP:8000/ws/chat/$_bookingId/?token=$_token',
);
```

For production, use a secure WebSocket:
```dart
final wsUrl = Uri.parse(
  'wss://YOUR_DOMAIN/ws/chat/$_bookingId/?token=$_token',
);
```

### 4. Usage in Screens

#### For Customers (my_bookings_screen.dart)
A "Message" button has been added to each booking card. Tapping it opens the chat screen for that booking.

#### For Providers (booking_checking_screen.dart)
A "Message Customer" button has been added to each booking card. Tapping it opens the chat screen.

#### View All Conversations
Navigate to the ChatListScreen to see all active conversations:

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const ChatListScreen()),
);
```

## Features

### Customer Side
- ✅ View all bookings with messaging capability
- ✅ Open chat with service provider from booking card
- ✅ Send and receive real-time messages
- ✅ See message read status
- ✅ View provider online/offline status

### Provider Side
- ✅ View customer booking requests with messaging
- ✅ Open chat with customer
- ✅ Send and receive real-time messages
- ✅ Integrated into booking acceptance flow

### General Features
- ✅ Real-time WebSocket communication
- ✅ Message history from REST API
- ✅ Unread message count
- ✅ User avatars in chat
- ✅ Timestamp formatting
- ✅ Auto-scroll to latest messages
- ✅ Responsive UI design

## Database Models

### Message Model
```python
- booking: ForeignKey to Booking
- sender: ForeignKey to User
- receiver: ForeignKey to User
- content: TextField
- is_read: BooleanField
- created_at: DateTimeField
- updated_at: DateTimeField
```

### ChatRoom Model
```python
- booking: OneToOneField to Booking
- customer: ForeignKey to User (role='customer')
- provider: ForeignKey to User (role='provider')
- created_at: DateTimeField
- updated_at: DateTimeField
```

## Deployment

### Using Docker

Update `docker-compose.yml`:
```yaml
services:
  redis:
    image: redis:latest
    ports:
      - "6379:6379"

  web:
    image: labourgo-backend
    command: daphne -b 0.0.0.0 -p 8000 core.asgi:application
    environment:
      - CHANNEL_LAYERS=redis
```

### Using Kubernetes

Apply the manifest in `k8s/`:
```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Troubleshooting

### WebSocket Connection Fails
1. Ensure Daphne is running: `ps aux | grep daphne`
2. Check firewall: `sudo ufw allow 8000`
3. Verify ASGI configuration in `core/asgi.py`
4. Check token validity in JWT settings

### Messages Not Sending
1. Verify WebSocket connection: Open browser DevTools → Network → WS
2. Check Django logs for consumer errors
3. Ensure booking ID is valid
4. Verify user has access to the booking

### Redis Connection Error
1. Start Redis: `redis-server`
2. Or switch to InMemoryChannelLayer for development
3. Check Redis port: `redis-cli ping` should return `PONG`

## Admin Panel

Access `/admin/` to:
- View all messages
- View all chat rooms
- Mark messages as read/unread
- Monitor user conversations

## Security Considerations

1. ✅ Messages are authenticated via JWT tokens
2. ✅ Users can only chat with customers/providers they have active bookings with
3. ✅ All WebSocket connections are authenticated via `AuthMiddlewareStack`
4. ✅ Messages are stored in database for history

## Next Steps

1. Add message notifications (Firebase Cloud Messaging)
2. Add typing indicators
3. Add message reactions/emojis
4. Add file/image sharing
5. Add call integration
6. Add message search functionality
7. Add message encryption for privacy

## Support

For issues or questions, refer to:
- Django Channels: https://channels.readthedocs.io/
- Daphne: https://github.com/django/daphne
- Flutter WebSocket: https://pub.dev/packages/web_socket_channel
