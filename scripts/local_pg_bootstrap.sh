#!/usr/bin/env bash

set -e

echo "======================================"
echo " AYRNOW - Local PostgreSQL Bootstrap"
echo "======================================"

# 1. Check if psql is installed
if ! command -v psql &> /dev/null; then
    echo "❌ Error: psql is not installed. Please install PostgreSQL (e.g., via Homebrew: brew install postgresql@14)"
    exit 1
fi
echo "✅ psql is installed."

# 2. Check if postgres service is running
if ! pg_isready &> /dev/null; then
    echo "⚠️ PostgreSQL is not responding. Attempting to start service..."
    # Attempt to start postgres via brew if on macOS
    if command -v brew &> /dev/null; then
        brew services start postgresql@14 || brew services start postgresql
        sleep 3
        if ! pg_isready &> /dev/null; then
            echo "❌ Error: Failed to start PostgreSQL. Please start it manually."
            exit 1
        fi
    else
        echo "❌ Error: PostgreSQL service is not running. Please start it manually."
        exit 1
    fi
fi
echo "✅ PostgreSQL service is running."

# DB settings
DB_NAME="ayrnow"
DB_USER="ayrnow"
DB_PASS="ayrnow"

# 3. Create user if it doesn't exist
echo "Checking for database user: $DB_USER..."
USER_EXISTS=$(psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='$DB_USER'")
if [ "$USER_EXISTS" != "1" ]; then
    echo "Creating user $DB_USER..."
    psql postgres -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASS' CREATEDB;"
else
    echo "✅ User $DB_USER already exists."
fi

# 4. Create database if it doesn't exist
echo "Checking for database: $DB_NAME..."
DB_EXISTS=$(psql postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'")
if [ "$DB_EXISTS" != "1" ]; then
    echo "Creating database $DB_NAME owned by $DB_USER..."
    psql postgres -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;"
else
    echo "✅ Database $DB_NAME already exists."
fi

echo "======================================"
echo "✅ Local PostgreSQL Bootstrapped Successfully!"
echo "Connection String: jdbc:postgresql://localhost:5432/$DB_NAME"
echo "User: $DB_USER"
echo "Password: $DB_PASS"
echo "======================================"
