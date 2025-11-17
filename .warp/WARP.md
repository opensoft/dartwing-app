# Project Rules for appDartwing

## Environment Files (.env)

This project uses two separate `.env` files with distinct purposes:

1. **Root .env** (`/.env`): Application-level environment variables for the Flutter/Dart app runtime configuration
2. **DevContainer .env** (`.devcontainer/.env`): Environment variables specifically for building and configuring the development container

Both files serve different purposes and should be maintained separately. The root `.env` should not be moved to the `.devcontainer` folder as it is needed for application runtime, not container build-time.
