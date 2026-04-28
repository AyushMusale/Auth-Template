# Auth-Template

Auth-Template is a full-stack authentication demo with a Node.js/Express backend and a Flutter frontend.

It supports:
- Email OTP authentication via Resend email service
- Google OAuth login using Passport.js
- JWT access and refresh token flow
- Upstash Redis for OTP storage
- PostgreSQL via Prisma ORM
- Flutter app state management with BLoC and secure token storage

## Architecture

### Backend
- `backend/server.js` — Express server entrypoint
- `backend/src/configure/` — database and Passport configuration
- `backend/src/services/auth/` — auth controllers, routes, middleware
- `backend/prisma/schema.prisma` — PostgreSQL user/session schema
- Uses `dotenv` to load environment variables

### Frontend
- `frontend/klyr/lib/main.dart` — Flutter app entrypoint
- `frontend/klyr/lib/router/app_router.dart` — app navigation
- `frontend/klyr/lib/network/authclient.dart` — Dio HTTP client with JWT interceptor
- `frontend/klyr/lib/presentation/auth/` — auth UI pages
- `frontend/klyr/lib/data/` — local storage, repository, and Google auth service

## Features

- Request OTP by email and verify it
- Google sign-in through backend OAuth callback
- Secure local refresh token storage with `flutter_secure_storage`
- Automatic access token refresh on 401/expired token responses
- User creation and login persistence via PostgreSQL and Prisma

## Backend Setup

1. Install dependencies:
   ```bash
   cd backend
   npm install
   ```

2. Create a `.env` file in `backend/` with the following keys:
   ```env
   SERVER_PORT=3003
   DATABASE_URL=postgresql://USER:PASSWORD@HOST:PORT/DATABASE
   JWT_ACCESS_SECRET=your_access_secret
   JWT_REFRESH_SECRET=your_refresh_secret
   RESEND_API=your_resend_api_key
   UPSTASH_REDIS_REST_URL=your_upstash_redis_rest_url
   UPSTASH_REDIS_REST_TOKEN=your_upstash_redis_rest_token
   GOOGLE_CLIENT_ID_ANDROID=your_android_google_client_id
   GOOGLE_CLIENT_ID_WEBAPP=your_web_google_client_id
   GOOGLE_CLIENT_SECRET=your_google_client_secret
   SESSION_SECRET=your_session_secret
   ```

3. Initialize Prisma and run migrations:
   ```bash
   npx prisma migrate dev --name init
   ```

4. Start the server:
   ```bash
   npm start
   ```

## Frontend Setup

1. Install Flutter dependencies:
   ```bash
   cd frontend/klyr
   flutter pub get
   ```

2. Run the Flutter app:
   ```bash
   flutter run
   ```

> The Flutter app is currently configured to use `http://10.0.2.2:3003/your-url` as the backend base URL, which works with Android emulators.

## API Endpoints

- `POST /your-url/auth/get-otp` — request OTP by email
- `POST /your-url/auth/verify` — verify submitted OTP
- `GET /your-url/auth/google` — start Google OAuth
- `GET /your-url/auth/google/callback` — Google OAuth callback endpoint
- `POST /your-url/auth/refresh` — refresh access token

## Notes

- Ensure you have updated the backend port number and frontend URL in all appropriate places before running the app.

## License

This project is provided as-is for demonstration and learning purposes.

