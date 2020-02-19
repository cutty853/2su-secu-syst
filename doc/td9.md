# Création de la signature d'un fichier

- Fichier signé : *2SU_DevSecEmb.pdf*
- Clés publique utilisés pour la signature : *src/antoine-pubkey.pem*
- signature résultante : *out/signature-cours.*

Commandes utilisés pour signer :

```sh
openssl dgst -sha256 2SU_DevSecEmb.pdf > tmp/signature-cours.sha256
openssl rsautl -sign -inkey /etc/ssl/private/antoine/antoine-privkey.pem -keyform PEM -in tmp/signature-cours.sha256 > out/signature-cours
```

Pour vérifier la signature, vous pouvez utiliser le script se trouvant dans *src/verify.sh* de la manière suivante :

```sh
./src/verify-signature.sh 2SU_DevSecEmb.pdf out/signature-cours src/antoine-pubkey.pem
```

## Note sur la génération des clés

Afin de signer un document il faut au préalable générer une paire de clés publique et privée. Les commandes que j'ai utilisé sont les suivantes :

```sh
export RSA_KEY_SIZE=4096
export PRIVATE_KEY_FILE=/etc/ssl/private/antoine/antoine-privkey.pem
export PUBLIC_KEY_FILE=src/antoine-pubkey.pem
/usr/bin/openssl genrsa -out $PRIVATE_KEY_FILE $RSA_KEY_SIZE
/usr/bin/openssl rsa -in $PRIVATE_KEY_FILE -outform PEM -pubout -out $PUBLIC_KEY_FILE
```

**NOTE**: Le dossier */etc/ssl/private/antoine* à été crée au préalable, permet de stocker les clés ssl du compte antoine et n'est lisible par aucune autre personne.

## Questions

### Signature dans l'embarqué

> En quoi la signature peut protéger dans un contexte embarqué?

TODO

### Update d'un firmware

> Comment protéger l'update d'un firmware?

TODO
