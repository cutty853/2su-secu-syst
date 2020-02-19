#!/bin/bash

# usage: ./verify-signature.sh <data_file> <signature> <public_key>
#
# data_file: le fichier qui a été signé
# signature: la signature fournit par "l'adversaire"
# public_key: la clé avec laquelle on effectue la vérification de la signature

DATA_FILE=$1
SIGNATURE=$2
PUBKEY=$3

signature_digest=$(openssl rsautl -verify -inkey $PUBKEY -pubin -keyform PEM -in $SIGNATURE)
calculated_digest=$(openssl dgst -sha256 $DATA_FILE)

if [[ "$signature_digest" == "$calculated_digest" ]]; then
    echo "La signature est bonne, le fichier est bien celui décrit par la signature"
else
    echo "La signature est mauvaise, le fichier est corrompu / n'est pas celui attendu."
fi
