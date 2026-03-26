#!/usr/bin/env bash

# 1. Define paths
TOKEN_DIR="$HOME/.local/share/tokens"
TOKEN_FILE="$TOKEN_DIR/github_token.gpg"

# 2. Create directory with secure permissions
mkdir -p -m 700 "$TOKEN_DIR"

# 3. Get your GPG Key ID (the one you just created)
# This grabs the ID of your first secret key
GPG_ID=$(gpg --list-secret-keys --with-colons | grep '^sec' | cut -d: -f5)

if [ -z "$GPG_ID" ]; then
    echo "Error: No GPG key found. Please create one first."
    exit 1
fi

# 4. Encrypt the token
echo "Enter your GitHub Classic Token:"
read -rs MY_TOKEN

echo "$MY_TOKEN" | gpg --encrypt --recipient "$GPG_ID" --output "$TOKEN_FILE"

if [ $? -eq 0 ]; then
    echo "Success! Token encrypted to $TOKEN_FILE"
else
    echo "Encryption failed."
fi
