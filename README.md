# PharmStarLauncher
## Description générale
PharmStarLauncher est un pipeline destiné à l'analyse pharmacogénétique sur un panel de pharmacogènes définis par l'outil PharmCAT. Le pipeline inclut l'analyse de l'outil PharmCAT ainsi qu'une possibilité de liftover (conversion depuis la version GRCh37 vers la version GRCh38) avec l'outil CrossMap. Ce pipeline utilise également dialog pour une utilisation interfacée qui améliore et facilite l'expérience utilisateur. Le pipeline, développé pour l'haplotypage de patients pour le Laboratoire de Toxicologie du CHU de Nîmes, est actuellement à la version 0.1.

Le pipeline a été testé avec les versions **0.6.4** de **CrossMap** et **2.4.0** de **PharmCAT**.


## Dépendances
Pour fonctionner, le pipeline a impérativement besoin des versions des outils suivants :

**Python >= 3.10.12**

**Dialog >= 1.794**

**CrossMap >= 0.6.4**

**PharmCAT >= 2.4.0**

**Git >= 2.41.0**

**Java = 17.0.8**

*Le pipeline ne fonctionne pas avec les versions plus récentes de Java, une adaptation est en cours. Un environnement virtuel est fortement recommandé si vous souhaitez utiliser le pipeline pour l'instant.*


## Installation 
Ouvrez un terminal à l'endroit où vous souhaitez placer le pipeline (création d'un répertoire en amont nécessaire) puis tapez :
```bash
git clone https://github.com/JC-Delmas/PharmStarLauncher.git
```

Pour installer PharmStarLauncher, ouvrez un terminal, placez-vous dans le répertoire où se situe le script d'installation **install.sh** (situé dans le dossier scripts de PharmStarLauncher) puis tapez :
```bash
./ install.sh
```
**ou**
```bash
bash install.sh
```

Cette commande permet d'ajouter PharmStarLauncher dans votre PATH et de créer un raccourci directement sur le bureau pouvant être double-cliquable.

## Exécution
- **Si vous avez correctement installé l'outil, vous pouvez simplement double-cliquer dessus pour qu'il s'exécute.**
  **Sinon, ouvrez un terminal à partir de n'importe quel endroit puis tapez :**
```bash
PharmStarLauncher
```

- **Vous pouvez également lancer l'outil uniquement depuis le répertoire où il se situe avec la commande suivante :**
```bash
./ PharmStarLauncher.sh
```
**ou**
```bash
bash PharmStarLauncher.sh
```

## Sortie
Un répertoire **crossmap-log** sera généré dans le répertoire courant du script et contiendra un fichier log par fichier VCF qui indique le traitement réalisé par CrossMap dans le cas où un liftover (GRCh37 vers GRCh38) est réalisé. Cela indique également le nombre de positions qui n'ont pas pu être repositionnées pendant la conversion.

Les résultats seront stockés dans un répertoire **"results_$datetime"** dans le répertoire courant où se situe le script PharmStarLauncher.sh.
Les rapports en format HTML seront présents pour chaque VCF, ainsi qu'un fichier log par fichier VCF traité qui récapitule les commandes et traitements par l'outil PharmCAT.

## Support
En cas de problèmes rencontrés, veuillez utiliser l'onglet *"Issues"* du github : https://github.com/JC-Delmas/PharmStarLauncher/issues

Veuillez bien renseigner les étapes qui ont été réalisées avec les choix faits et fournir :
- Les fichiers logs de CrossMap s'il y a eu une opération de liftover.
- Les fichiers logs présents dans le répertoire des résultats.
