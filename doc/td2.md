# Reverse avec binwalk

## Extraction du système de fichier

Après avoir téléchargé et exéctué une premiere fois la machine, on va utiliser `binwalk` pour essayer de trouver où se situe pingouin de la démo.

La commande suivante nous permet d'avoir l'offset à partir duquel commence le disque principal (hors noyau).

```sh
binwalk src/binwalk/vmlinuz-qemu-arm-2.6.20
```

On peut ensuite l'extraire avec la commande `dd`.

```sh
dd if=src/binwalk/vmlinuz-qemu-arm-2.6.20 of=src/binwalk/main_disk.gz skip=12720 bs=1 conv=notrunc
```

On dézippe le disque extrait. le `-9` est ici car binwalk nous a indiqué que le niveau de compression est le maximum.

```sh
gunzip -9 src/binwalk/main_disk.gz
```

On refait les tâches précédentes pour le système de fichier.

```sh
binwalk src/binwalk/main_disk
dd if=src/binwalk/main_disk of=src/binwalk/filesystem.gz bs=1 conv=notrunc skip=59360
gunzip -9 src/binwalk/filesystem.gz
```

## Extraction du pingouin

On obtient le fichier *src/binwalk/filesystem* sur lequel on peut lancer la commande binwalk afin de trouver les images disponibles sur ce systeme de fichier.

```sh=
binwalk src/binwalk/filesystem | grep -E "(jpg)|(png)"
```

On peut finalement lire la ligne suivante contenant l'offset et le chemin du fichier du pingouin:

```txt
2984412       0x2D89DC        ASCII cpio archive (SVR4 with no CRC), file name: "/usr/local/share/directfb-examples/tux.png", file name length: "0x0000002B", file size: "0x00006050"
```

Pour se simplifier la vie, on va utiliser l'option `-e` de binwalk qui va permettre d'extraire les fichiers du système de fichier.

```sh
binwalk -e src/binwalk/filesystem
mv _filesystem.extracted out/binwalk
```

On se retrouve ainsi avec le système de fichier de la machine, extrait et disponible au chemin *out/binwalk/cpio-root*. On accède alors au fichier du pingouin avec le chemin *out/binwalk/cpio-root/usr/local/share/directfb-examples/tux.png*.

## Sécurité des systèmes

Le fait de pouvoir fouiller sur le système de fichier de cette manière est un point à prendre en compte lorsqu'on conçoit un système embarqué. En effet, le côté "embarqué" de ces systèmes indique qu'ils seront disponible aux attaquants. Il faut donc éviter de stocker des données trop sensible comme des clés privées destiné à des signatures ou au chiffrements de connexions.

Dans le cas où des fichiers sensibles doivent nécessairement être installés sur le système il faut penser à sécuriser le matériel pour éviter leur extraction. On peut notamment les séparer du système de fichier en les plaçant dans un système sécurisé matériellement comme un TPM (pour les clés de chiffrement).
