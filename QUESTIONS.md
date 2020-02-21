# Réponses aux questions de cours

## Les signatures dans les systèmes embarqués

> Quels sont les chemins d'attaque possibles sur la signature d'un système embarqué ?

Afin de comprendre la surface d'attaque d'un système de signature dans le monde de l'embarqué il faut d'abord comprendre le **processus de signature**. Les signatures se basent sur le **chiffrement asymétrique** (*RSA* et *ECC* principalement), il y a donc deux clés en jeux : une publique et une privée.

Afin de "signer" des données, le pocesseur de la clé privée effectue en premier lieu un **hash** des données à signer, puis il **chiffre ce hash** asymétriquement avec sa **clé privée**. Ainsi, toute personne possédant la clé publique du signataire (globalement tout le monde, car cette clé n'est pas censée subir trop de contraintes de sécurité (cas particulier : ECC)) pourra déchiffrer le hash et le comparer au hash des données qu'il a reçu pour s'assurer qu'il à bien reçu les données de la "bonne" personne.

Une signature, apposée à une donnée, permet **d'authentifier** ce contenu, car on se base sur le fait que **seule la personne à authentifier possède la clé privée** qui à servie à chiffrer.

Grâce à cette définition, on peut identifier les différents points chauds de cette procédure :

1. la clé privée doit rester privée et ne pas être altérable : Un attaquant peut chercher à mettre la main sur la clé privée pour se faire passer pour le signataire.
2. la récupération de la clé publique du signataire doit être sécurisé: si le système embarqué communique (sur un canal non sécurisé) avec le signataire pour récupérer sa clé publique, l'attaquant peut chercher à faire un man-in-the-middle afin d'envoyer sa propre clé publique sur le système embarqué.
3. le stockage de la clé publique doit être sûr: L'attaquant peut chercher à récupérer la clé publique, soit mettre la sienne, soit trouver une vulnérabilité sur la clé elle meme.
4. La génération du jeux de clés: si la génération des clés utilise une procédure trop faible voir meme carrément corrompu par l'attaquant, les clés qui en résultent reste faibles.
5. Il faut que le système qui fera la vérification de la signature soit sûr, il fait partie de la base de confiance. Si il peut etre compromis, alors la signature à vérifier pourra (surement) etre modifiée par un attaquant. Cela à notamment été mis en avant dans [cette vidéo de Micode](https://www.youtube.com/watch?v=AzhnqtQKKHM), ici le téléphone faisait partie de la base de confiance de l'application Uber Eats (l'application cherchait surtout à se protéger des petits malins qui se mettent entre les deux à l'insu de l'utilisateur).

## Chaine de confiance

> A quoi sert la chaine de confiance? Pourquoi est-elle nécessaire?

Nos systèmes sont construits en couches, cela permet de ne pas réinventer la roue. Pourtant cela implique de faire complètement confiance à la couche N-1. Il y a tout de même plusieurs points à vérifier lorsque l'on fait ce choix. L'un de ces points concerne l'authenticité de la couche inférieure : on s'assure que la couche du dessous est bien celle que l'on croit être avant de l'utiliser. Il existe pour cela le principe de signature.

Ainsi afin de vérifier qu'on parle à la bonne personne ou qu'on exécuté le bon binaire on cherche à vérifier la signature qu'il nous fournit en la comparant à celle qu'on attendait.

Le principe de chaine de confiance est une extension de ce principe le fait ressortir sur toute une chaine. Les bootloader ou encore la chaine de confiance des certificats SSL montre qu'il faut, au final se baser sur une signature qui sera toujours écrite en dur sur une machine que l'on maitrise, le tout est de choisir la base de confiance (Root of Trust) la plus maitrisée et maitrisable possible, celle présentant le risque le plus faible.

## Modèle d'attaque et méthode

> Décrire la méthode pour aborder la sécurité sur un produit embarqué. Pourquoi établir un modèle d'attaquant est-il important?

1. Il faut d'abord s'assurer qu'on comprend bien ce qu'on cherche à sécuriser. Que renferme ce service / produit ?
2. Une fois la premiere étape effectué il faut **modéliser les menaces**. C'est à dire caractériser par des chiffres ou des catégories les différentes composantes de notre produit : qui peut l'attaquer, quel est l'impact si tel ou tel composant est compromis.
3. Afin de caractériser les problèmes on va chercher à effectuer des phases de pentest, reverse engineering, exploiter des vulnérabilités (faire des PoC), etc... Cela permet de valider que le besoin de sécurité existe.
4. On cherche ensuite à prévoir les différents coûts des différentes mesures. Cela permet de placer des priorités et mettre en perspectives tous les problèmes qui peuvent arriver. Ces priorités sont un compromis entre la modélisation de la menace (étape 2), la caractérisation des problèmes (étape 3) et le coût que leur résolution implique. Ce dernier étant, le plus souvent, limité il s'agit de rendre le travail d'un attaque le plus difficile possible (revient à rendre plus difficile l'étape 3).
5. Finalement, il faut continuer à tester régulièrement les points déjà mis en place (pour éviter la régression) et tester les nouvelles vulnérabilités avec les nouveaux outils (le contexte change toujours).

Établir le modèle d'un attaquant est important car c'est ce qui détermine l'efficacité de chacune des étapes ci dessus.

- L'étape 1 fait état du contenu récupérable par un attaquant, si il devient plus intéressant de le récupérer, il faudra mettre à jour le plan de sécurisation.
- L'étape 2 consiste à savoir ce qu'on cherche à protéger et ce qu'on peut réellement protéger (ce qu'on maitrise = ce sur quoi l'attaquant n'a pas la main)
- L'étape 3 permet de se rendre compte ce qu'il est possible de faire avec les outils qu'un attaquant possède, il faut donc savoir ce qui est disponible à un attaquant pour effectuer cette étape
- L'étape 4 va permettre de confronter le coût investit par rapport au pertes produites par un attaquant tout en sachant combien, lui, va perdre. On ne s'embete pas à sécuriser ce qui va demander à l'attaquant beaucoup d'efforts en comparaison du gain
- L'étape 5 rappelle que le profil et les possibilités d'un attaquant évolu toujours (de nouveaux outils, un accès facilité, etc..)

## Debug dans l'emarqué

> Trouver un moyen rapide de faire du debug embarqué (par exemple sur cible ARM)? Expliquer les avantages

Il est possible d'émuler globalement n'importe quel jeu d'instructions sur nos machines actuelles. Cela peut etre judicieusement utilisé pour debugger le logiciel d'un système embarqué. En effet grâce à l'émulation on peut facilement visualiser l'espace mémoire (et inspecter les valeurs des différentes variables), mettre des points d'arrêt ou juste tester le fonctionnement nominale d'un programme.

Cependant pour les tests un peu plus poussés (en condition réelles) et les bugs liés au hardware il convient de tester directement sur le système embarqué via des ports JTAG et autre debugger branchable sur le système. Cela permet notamment de s'assurer que le programme fonctionne correctement en système contraint en mémoire et en CPU (contraintes qui n'existe pas vraiment dans l'émulation)

## BugList

> Lister les catégories de bug possibles et comment les exploiter et les défendre

TODO: bufferoverflow, connexion port JTAG tout ça tout ça, fuzzer, analyseur de code (statique), reverse, etc...

## Idées d'amélioration de la sécurité dans l'embarqué

> Quelles idées pour améliorer la sécurité en embarqué? (IA, Anti-debug, Obfuscation, Crypto ...) Choisissez une idée, chercher si elle existe et développer en quelques phrases quel avantage elle apporte et ses limites

Je suis plutot partisan de l'utilisation de système permettant de rendre les attaques compliqués pour l'attaquant, car les vulnérabilités sont toujours là. Pourtant, je voudrais mettre en avant que ces vulnérabilités sont assez souvent dû à l'erreur humaine et qu'il serait possible de parfois les éviter via l'utilisation d'outil de vérification automatique.

L'un des plus puissants des outils d'analyse statique du code est FramaC. Cette plateforme est composée de plusieurs greffons et un des principaux s'appuie sur de la vérification (statique) formelle. Ce logiciel open-source permet de définir des règles / propriétés qui doivent être vérifiés par le code. Un ensemble de règles basées sur des propriétés de sécurité peuvent être ainsi vérifié à chaque commit, notamment en couplant l'exécution de FramaC à une Pipeline gitlab par exemple.

Pour appuyer mon propos l'ANSSI a énoncée [une offre de stage](https://www.ssi.gouv.fr/uploads/2019/10/s3043_developpement-d-un-greffon-frama-c-pour-la-genertion-automatique-d-annotation-acsl.pdf) partant de ce principe.
