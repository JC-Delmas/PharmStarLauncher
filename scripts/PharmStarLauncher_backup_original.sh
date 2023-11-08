#!/bin/bash

# Go to the specific folder for VCF folder selection
cd $(find ~ -type d -name "PharmStarLauncher" 2>/dev/null | head -1)

export PATH=/usr/local/bin:$PATH

# Locate the virtual environment path
VENV_PATH=$(find ~ -type d -path "*/PharmStarLauncher/src/pgx/bin" 2>/dev/null | head -1)

# Check if the path was found and activate the virtual environment
if [ ! -z "$VENV_PATH" ]; then
    # Activate the virtual environment
    source $VENV_PATH/activate
else
    echo "Virtual environment in 'PharmStarLauncher/src/pgx' not found."
fi

# Interruption function to exit the program cleanly
interrupt_program() {
    dialog --title "Interruption" --msgbox "\n\nVous quittez le programme." 10 60
    clear
    deactivate
    exit 0
}

# Trap Ctrl+C (SIGINT) and display a message before exiting
trap ctrl_c INT
function ctrl_c() {
	interrupt_program
}

# Variables
current_datetime=$(date '+%Y%m%d%H%M%S')
current_dir=$(pwd)
pharmcat_path=/Users/jean-christopheboyer/Desktop/PGx/PharmStarLauncher/src/PharmCAT/preprocessor/pharmcat_pipeline
output_dir="results_$current_datetime"
all_files=()
logfile="error-log_${current_datetime}.log"
crossmap_logs_dir="crossmap_logs"
mkdir -p "$crossmap_logs_dir"
crossmap_log="$crossmap_logs_dir/crossmap-log_${current_datetime}.log"
lifted_files=false # Flag for lifted files


### MAIN ###

dialog --title "PharmStarLauncher - CHU Nîmes - Laboratoire de Toxicologie" \
--msgbox "\n\nPipeline développé par Jean-Charles DELMAS.\n\nVersion 0.1 du pipeline.\n\nVous pouvez quitter le programme à tout moment en faisant Control + C\n\nPour continuer, appuyez sur la touche d'entrée." 15 60

dialog --title "Vérifiez les points suivants" --yesno "\n1. Les fichiers VCF doivent être alignés sur la version GRCh38. Si ce n'est pas le cas, le programme vous proposera un liftover mais des informations pourront être perdues (un dossier unmapped sera généré avec les positions qui n'ont pas pu être repositionnées dans un fichier VCF). \n\n2. Chaque VCF correspond à un seul échantillon. \n\n3. Le répertoire contenant les fichiers VCF est situé dans le répertoire courant où se situe le programme.\n\n4. Les fichiers VCF ne doivent pas contenir d'espaces dans leur nom, si c'est le cas le programme remplacera automatiquement tous les espaces dans les noms par des underscores '_'.\n\n\nVoulez-vous continuer?\n(Navigation : touches fléchées)" 23 80

# Check for No button press (which corresponds to Cancel)
if [ $? -eq 1 ]; then
	interrupt_program
fi

directories=$(ls -d */ | awk '{print NR " " $0}' | tr '\n' ' ')

vcf_dir=$(dialog --title "Choisissez le répertoire contenant les fichiers VCF" --menu "\n\nNavigation : touches fléchées\nConfirmation: touche d'entrée" 20 60 4 ${directories} 3>&1 1>&2 2>&3 3>&-)

# Check for cancel or exit button press
if [ $? -eq 1 ]; then
	interrupt_program
fi

vcf_dir=$(ls -d */ | sed -n "${vcf_dir}p")

dialog --title "Confirmation" --msgbox "\n\nRépertoire choisi : $vcf_dir" 10 60

echo 'Traitement des fichiers dans: $vcf_dir pour remplacer les espaces.'

# 1. Traitement des fichiers ayant des espaces dans leurs noms
find $vcf_dir/ -type f -name "* *" | while read -r file; do
  new_file="${file// /_}"
  if [ "$file" != "$new_file" ]; then
    echo "Renommage de $file en $new_file ..."
    mv "$file" "$new_file"
  fi
done

# 2. Vérification des fichiers VCF
vcf_files=$(find $vcf_dir/ -name '*.vcf' | grep -v lifted38)
for file in $vcf_files; do
  if [ ! -s "$file" ]; then
    echo "Erreur : Le fichier $file est vide ou n'existe pas."
    exit 1
  fi
done

echo "Tous les fichiers VCF sont présents et ne sont pas vides."

# VCF are empty ?
vcf_files=$(find "$vcf_dir" -name "*.vcf" | grep -v "lifted38")
for file in ${vcf_files[@]}; do
    if [ ! -s "$file" ]; then
        echo "Erreur : Le fichier $file est vide ou n'existe pas."
        exit 1
    fi
done

# Path to the CrossMap
CROSSMAP="CrossMap.py"

# Reference genome
REF="/Users/jean-christopheboyer/Desktop/PGx/Paramètres/hg38/hg38.fa"

# Chain file for CrossMap
CHAIN="/Users/jean-christopheboyer/Desktop/PGx/Paramètres/Crossmap_chain/hg19ToHg38.over.chain"

# Ask user if they want to lift over the VCF files
answer=$(dialog --title "Choix de l'opération de liftover" --yesno "\n\nVoulez-vous effectuer une opération de liftover pour convertir les fichiers VCF de la version GRCh37 à GRCh38 (des informations peuvent être perdues dans les fichiers convertis pendant cette opération) ?" 10 60 3>&1 1>&2 2>&3 3>&-)
answer=$?
	
# If user choose not to lift over the VCF files
if [ $answer -eq 1 ]; then
	vcf_files=$(find "$vcf_dir" -name "*.vcf" | grep -v "lifted38")
                if [ -z "$vcf_files" ]; then
                        dialog --title "Erreur" --msgbox "Aucun fichier VCF trouvé dans le répertoire spécifié. Le programme s'achève prématurément." 10 60
                        deactivate
                        exit 1
                fi
	mkdir -p "${vcf_dir}non_lifted"
	cp $(find "$vcf_dir" -name "*.vcf" | grep -v "lifted38") "${vcf_dir}non_lifted/"
	all_files=($(find "${vcf_dir}non_lifted" -name "*.vcf"))
	vcf_processing_dir="${vcf_dir}non_lifted"
	successful_files=("${all_files[@]}")
else

# If user chooses to lift over the VCF files
        if [ $answer -eq 0 ]; then
                vcf_files=$(find "$vcf_dir" -name "*.vcf" | grep -v "lifted38")
                if [ -z "$vcf_files" ]; then
                        dialog --title "Erreur" --msgbox "Aucun fichier VCF trouvé dans le répertoire spécifié. Le programme s'achève prématurément." 10 60
                        deactivate
                        exit 1
                fi
                successful_files=()
                count=0
                total_files=$(echo $vcf_files | wc -w)
                for file in ${vcf_files[@]}
                do
                        output_lifted_dir="$vcf_dir/lifted38"
                        mkdir -p "$output_lifted_dir"
                        output_lifted_file="$output_lifted_dir/$(basename $file .vcf)_lifted38.vcf"
                        crossmap_log_file="$crossmap_logs_dir/$(basename $file .vcf)_lifted38.log"
                        # Increase count
                        ((count++))
                        # Calculate percentage
                        percent=$((100*count/total_files))
                        if CrossMap.py vcf $CHAIN $file $REF $output_lifted_file >>$crossmap_log 2>&1
                        then
                                successful_files+=("$output_lifted_file")
                                lifted_files=true
                        else
                                dialog --title "Erreur" --msgbox "Une erreur est survenue lors de la conversion du fichier $file. Consultez le fichier $crossmap_log pour plus de détails." 10 60
		                deactivate
                                exit 1
                        fi
		        if [ ! -s "$output_lifted_file" ]; then
		                dialog --title "Erreur fatale" --msgbox "Le fichier lifté $output_lifted_file est vide. Vérifiez si le fichier VCF d'origine est vide.\nSi ce n'est pas le cas, contactez le développeur:\n\ndelmas.jeancharles@yahoo.fr" 10 60
		                deactivate
		                exit 1
                        fi

                        # Update the gauge
                        echo $percent | dialog --gauge "Veuillez patienter pendant la conversion des fichiers VCF..." 10 70 0
                done
                dialog --title "Succès" --msgbox "\n\nTous les fichiers VCF ont été convertis avec succès. Vous pouvez les trouver dans le répertoire $output_lifted_dir." 10 60
        fi
fi
options=()
count=0
for file in "${successful_files[@]}"; do
        options+=("$count" "$(basename "$file")" "off")
        ((count++))
done

# Déplacer les fichiers unmappés dans un répertoire spécifique
if [ $lifted_files = true ]; then
	mkdir $output_lifted_dir/lifted_unmapped
	lifted_unmapped="$output_lifted_dir/lifted_unmapped"
	find $output_lifted_dir -type f -name "*vcf.unmap" -exec mv {} "$lifted_unmapped" \;
else
	mkdir ${vcf_dir}non_lifted/non_lifted_unmapped
	non_lifted_unmapped="${vcf_dir}non_lifted/non_lifted_unmapped"
	find ${vcf_dir}non_lifted/ -type f -name "*vcf.unmap" -exec mv {} "$non_lifted_unmapped" \;
fi

# Display the dialog box for the first time and get the user's selection and exit code.
choices=$(dialog --title "Sélection des fichiers VCF à analyser" --output-fd 1 --separate-output --extra-button --extra-label 'Select All' --cancel-label 'Cancel' --checklist "\n\nNavigation: touches fléchées\nSélection/désélection: barre d'espace\nConfirmation: touche d'entrée" 0 0 0 "${options[@]}")
exit_code="$?"

# If the user pressed 'Cancel', then interrupt the program
if [ "$exit_code" -eq "1" ]; then
    interrupt_program
fi

# As long as the user doesn't confirm their selection with 'OK', this loop continues.
while [[ $exit_code -ne 0 ]]; do
    case $exit_code in
        1) # The user pressed 'Cancel'
           interrupt_program;;
        3) # The user pressed 'Select All'
           options=("${options[@]/off/on}") # Change all "off" to "on"
           choices=$(dialog --output-fd 1 --separate-output --extra-button --extra-label 'Select All' --title 'Confirmation de la sélection totale' --checklist "\n\nNavigation: touches fléchées\nSélection/désélection: barre d'espace\nConfirmation: touche d'entrée" 0 0 0 "${options[@]}");;
    esac
    exit_code="$?"
done

# After confirming the selection, the selected files are added to an array.
selected_files=()
for choice in $choices; do
        selected_files+=("${successful_files[$choice]}")
done
        
all_files=("${selected_files[@]}")


# Convertir le tableau en chaîne, séparée par un espace
all_files_str="${all_files[*]}"

# Run PharmCAT on each file
if [ $lifted_files = true ]; then
        vcf_processing_dir="$output_lifted_dir"
else
        vcf_processing_dir="$vcf_dir"
fi

# Appel du script Python et de PharmCAT
output_dir="/Users/jean-christopheboyer/Desktop/PGx/PharmStarLauncher/results_$current_datetime"
pycommand="/Users/jean-christopheboyer/Desktop/PGx/PharmStarLauncher/src/PharmCAT/PGX_vcf.py"
mkdir $output_dir

# Pour chaque fichier dans la liste
for file in ${all_files[*]}
do
        python3 $pycommand $file $output_dir
done

# Conditions si aucun fichier non mappé n'a été généré
if [ $lifted_files = true ]; then
	unmap_count=$(ls $output_lifted_dir/lifted_unmapped/*.unmap 2> /dev/null | wc -l)
	if [ "$unmap_count" -eq "0" ]; then
    		echo "Aucun fichier unmapped n'a été généré pendant l'opération." > "$output_lifted_dir/lifted_unmapped/no_unmapped_files.txt"
	fi
else
	unmap_count=$(ls ${vcf_dir}non_lifted/non_lifted_unmapped/*.unmap 2> /dev/null | wc -l)
	if [ "$unmap_count" -eq "0" ]; then
    		echo "Aucun fichier unmapped n'a été généré pendant l'opération." > "${vcf_dir}non_lifted/non_lifted_unmapped/no_unmapped_files.txt"
	fi
fi

# Déplacer les fichiers report.html dans le répertoire des résultats
if [ $lifted_files = true ]; then
	mkdir results_$current_datetime
	find $output_lifted_dir -type f -name "*report.html" -exec mv {} "results_$current_datetime" \;
else
	mkdir results_$current_datetime
	find ${vcf_dir}non_lifted/ -type f -name "*report.html" -exec mv {} "results_$current_datetime" \;
fi

# Suppression des fichiers intermédiaires inutiles
if [ $lifted_files = true ]; then
	find $output_lifted_dir -type f -name "*.vcf.bgz.csi" -exec rm -f {} \;
	find $output_lifted_dir -type f -name "*missing*" -exec rm -f {} \;
	find $output_lifted_dir -type f -name "*match*" -exec rm -f {} \;
	find $output_lifted_dir -type f -name "*phenotype*" -exec rm -f {} \;
	find $output_lifted_dir -type f -name "*preprocessed*" -exec rm -f {} \;
else
	find ${vcf_dir}non_lifted -type f -name "*.vcf.bgz.csi" -exec rm -f {} \;
	find ${vcf_dir}non_lifted -type f -name "*match*" -exec rm -f {} \;
	find ${vcf_dir}non_lifted -type f -name "*phenotype*" -exec rm -f {} \;
	find ${vcf_dir}non_lifted -type f -name "*preprocessed*" -exec rm -f {} \;
	find ${vcf_dir}non_lifted -type f -name "*missing*" -exec rm -f {} \;
fi

# Trouver et compter les fichiers report.html dans le répertoire source
count_source=0
count_dest=0
if [ $lifted_files = true ]; then
    count_source=$(find "$output_lifted_dir" -name '*.report.html' | wc -l)
else
    count_source=$(find "$vcf_dir" -name '*.report.html' | wc -l)
fi
count_dest=$(find "$output_dir" -name '*.report.html' | wc -l)
if [ $count_source -eq 0 ] && [ $count_dest -eq $count_dest ]; then
    echo "Les fichiers report.html ont été déplacés dans results_$current_datetime"
else
	echo "Erreur critique : certains fichiers report.html n'ont pas été déplacés correctement. Veuillez contacter le développeur à l'adresse : delmas.jeancharles@yahoo.fr"
	dialog --title "ERREUR FATALE" --msgbox "Certains report.html sont manquants.\n\nVeuillez contacter le développeur : delmas.jeancharles@yahoo.fr" 10 60
	deactivate
	exit 1
fi

# That's all folks !
dialog --title "Succès" --msgbox "\n\nL'analyse est terminée.\n\nVous pouvez trouver les résultats dans le répertoire $output_dir situé dans le répertoire courant du script.\n\nMerci d'avoir utilisé ce pipeline !\n\nContact : delmas.jeancharles@yahoo.fr\n\n©Août 2023" 20 60