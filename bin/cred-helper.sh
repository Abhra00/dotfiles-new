#!/usr/bin/env bash
echo "NEW_TOKEN_HERE" | gpg --quiet --encrypt --armor -r YOUR_GPG_KEY_ID > $HOME/.local/share/tokens/github_token.gpg

