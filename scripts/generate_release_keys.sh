#!/usr/bin/env bash
set -e

# ==============================================================================
# FogOS Official Release Keys Generator
# Developer : Prince · VirgoYT (VirgoYT707)
# Purpose   : Generates private RSA release keys to replace AOSP test-keys
# ==============================================================================

KEY_DIR="$(pwd)/certs"
mkdir -p "$KEY_DIR"
SUBJECT="/C=IN/ST=India/L=FogOS/O=VirgoYT/OU=Gaming/CN=FogOS-Release/emailAddress=darkvirgoyt@gmail.com"

echo "[*] Generating official FogOS release-keys in $KEY_DIR..."

for KEY in releasekey platform shared media networkstack bluetooth sdk_sandbox; do
    if [ ! -f "$KEY_DIR/$KEY.pk8" ]; then
        echo "  -> Generating $KEY key..."
        openssl genrsa -out "$KEY_DIR/$KEY.key" 2048
        openssl req -new -x509 -key "$KEY_DIR/$KEY.key" -out "$KEY_DIR/$KEY.x509.pem" -days 10000 -subj "$SUBJECT"
        openssl pkcs8 -in "$KEY_DIR/$KEY.key" -topk8 -outform DER -out "$KEY_DIR/$KEY.pk8" -nocrypt
        rm -f "$KEY_DIR/$KEY.key"
    else
        echo "  [OK] $KEY already exists."
    fi
done

echo "=============================================================================="
echo "[SUCCESS] Official release keys generated successfully!"
echo "Use these keys during target-files signing to enforce 'ro.build.tags=release-keys'!"
echo "=============================================================================="
