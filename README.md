# PharmStarLauncher
## Description générale
PharmStarLauncher est un pipeline destiné à l'analyse pharmacogénétique sur un panel de pharmacogènes définis par l'outil PharmCAT. Le pipeline inclut l'analyse de l'outil PharmCAT ainsi qu'une possibilité de liftover (conversion depuis la version GRCH37 vers la version GRCh38) avec l'outil CrossMap. Ce pipeline utilise également dialog pour une utilisation interfacée qui améliore et facilite l'expérience utilisateur. 

Le pipeline utilise la version **0.6.4** de **CrossMap** et la version **2.4.0** de **PharmCAT**.


## Dépendances:
Pour fonctionner, le pipeline a impérativement besoin des versions des outils suivants:

**Java = 17**

**Python >= 3.10.12**

**Dialog = 1.794**

**Git = 2.41.0**


## Installation 
Ouvrez un terminal à l'endroit où vous souhaitez placer le pipeline (création d'un répertoire en amont nécessaire) puis tapez :
```bash
git clone https://github.com/JC-Delmas/PharmStarLauncher.git
```

## Configuration de PharmStarLauncher (*optionnelle si on ne veut plus de dépendance locale pour lancer l'outil*)

Pour lancer le pipeline depuis n'importe quelle instance du terminale, veuillez suivre les étapes suivantes :

- Rendre le script exécutable depuis le terminale :
```bash
chmod +x /chemin/vers/PharmStarLauncher.sh
```

- Créer un raccourci du script dans un répertorie déjà présent dans le PATH (ou le créer puis le déplacer) :
```bash
sudo ln -s /chemin/vers/PharmStarLauncher.sh /usr/local/bin/PharmStarLauncher
```

- Ajouter ensuite ce répertoire au PATH :
	- pour macOS arm64 :
```bash
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
```
	
	- pour Linux (système Ubuntu) :
 ```bash
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
 ```

- Rechargez le shell :
	 - pour MacOS arm64 :
  ```bash
	 source ~/.zshrc
  ```
	 
	 - pour Linux (système Ubuntu) :
 ```bash
	 source ~/.bashrc
  ```

## Exécution
- Si vous avez suivi les étapes de configuration, ouvrez un terminal à partir de n'importe quel endroit puis tapez :
```bash
PharmStarLauncher
```

- Sinon, vous pouvez lancer l'outil uniquement depuis le répertoire où il se situe avec la commande suivante :
```bash
bash PharmStarLauncher.sh
```
ou
```bash
./PharmStarLauncher.sh
```

## Output
Un répertoire crossmap-log sera généré dans le répertoire courant du script et contiendra un fichier log par fichier VCF qui indique le traitement réalisé par CrossMap dans le cas où un liftover (GRCh37 vers GRCh38) est réalisé. Cela indique également le nombre de positions qui n'ont pas pu être repositionnées pendant la conversion.

Les résultats seront stockés dans un répertoire "results_$datetime" dans le répertoire courant où se situe le script PharmStarLauncher.sh.
Les rapports en format HTML seront présents pour chaque VCF, ainsi qu'un fichier log par fichier VCF traité qui récapitule les commandes et traitements par l'outil PharmCAT.

## Support
En cas de problèmes rencontrés, veuillez utiliser l'onglet "Issues" du github : https://github.com/JC-Delmas/PharmStarLauncher

Veuillez bien renseigner les étapes qui ont été réalisées avec les choix faits et fournir :
- Les fichiers logs de CrossMap s'il y a eu une opération de liftover.
- Les fichiers logs présents dans le répertoire des résultats
