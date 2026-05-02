  GNU nano 8.7.1                                                                                                                                                                                                                                                                                                                                                                                                                                                                     auto_update.sh                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
#!/bin/bash
# "#!/bin/bash" s'appelle le SHEBANG
# Il dit au système : "utilise bash pour lire ce script"
# Sans cette ligne, Linux ne sait pas comment interpréter le fichier


# ============================================================
# FONCTION ERROR_BANNER
# "ERROR_BANNER()" déclare une fonction — elle ne s'exécute pas
# toute seule, elle attend d'être APPELÉE plus bas dans le script
# "echo" affiche du texte dans le terminal
# ============================================================
ERROR_BANNER() {
    echo ">>===========================<<"
    echo ">=                           <="
    echo ">=   UNE ERREUR S'EST        <="
    echo ">=   PRODUITE LORS DE        <="
    echo ">=  L'EXECUTION DU SCRIPT    <="
    echo ">=                           <="
    echo ">>===========================<<"
}


# ============================================================
# CRÉATION DU DOSSIER LOG
# "mkdir"  = Make Directory = créer un dossier
# "-p"     = Parents = crée aussi les dossiers parents si besoin
#            et ne plante PAS si le dossier existe déjà
# ============================================================
sudo mkdir -p /var/.log/log-update


# ============================================================
# NOM DU FICHIER LOG
# On crée une variable LOG_FILE_NAME qui contient le chemin
# complet du fichier log
# "$(...)" = substitution de commande = exécute ce qu'il y a
#            dedans et insère le résultat
# "date"   = commande qui donne la date et l'heure actuelle
# "%d"     = jour   ex: 02
# "%m"     = mois   ex: 05
# "%y"     = année  ex: 26
# "%H"     = heure  ex: 14
# "%M"     = minute ex: 30
# ".nhgt"  = extension personnalisée du fichier (modifiable)
# Résultat : updt-0205261430.nhgt — nom unique à chaque exécution
# ============================================================
LOG_FILE_NAME=/var/.log/log-update/updt-$(date +'%d%m%y%H%M').nhgt


# ============================================================
# ENTÊTE DU FICHIER LOG
# ">>"     = redirige et AJOUTE la sortie dans le fichier log
#            (sans écraser ce qui est déjà dedans)
# "$(date) = insère la date et l'heure dans le message
# ============================================================
echo ">>----------( $(date) )----------<<" >> "$LOG_FILE_NAME"
echo ">>== DÉMARRAGE DU SCRIPT DE MISE À JOUR ==<<"


# ============================================================
# ÉTAPE 1 — RECHERCHE DES MISES À JOUR
# "apt update"  = met à jour la LISTE des paquets disponibles
#                 (ne télécharge rien, juste le catalogue)
# ">>"          = envoie la sortie normale dans le fichier log
# "2>&1"        = redirige les erreurs (2) vers la sortie
#                 normale (1), donc tout va dans le log
# "if ... then" = SI la commande réussit → on continue
# "else"        = SINON → on affiche l'erreur et on quitte
# "exit 1"      = termine le script avec le code d'erreur 1
# ============================================================
echo "[ 1/3 ] - Recherche des mises à jour disponibles" >> "$LOG_FILE_NAME"
echo ">>== [ 1/3 ] RECHERCHE DES MISES À JOUR ==<<"

if sudo apt update >> "$LOG_FILE_NAME" 2>&1; then
    echo "[ 1/3 ] - Recherche terminée avec succès" >> "$LOG_FILE_NAME"
    echo ">>== RECHERCHE TERMINÉE AVEC SUCCÈS ==<<"
else
    ERROR_BANNER
    exit 1
fi


# ============================================================
# RÉCUPÉRATION DE LA LISTE DES PAQUETS
# Cette ligne est APRÈS apt update pour avoir une liste fraîche
# "apt list --upgradable" = affiche les paquets pouvant être mis à jour
# "2>/dev/null"           = supprime les messages d'avertissement
#                           (les envoie dans /dev/null = la poubelle)
# "|"                     = PIPE = envoie la sortie vers la commande suivante
# "awk"                   = outil de traitement de texte ligne par ligne
# "-F/"                   = définit "/" comme séparateur de colonnes
# "NR>1"                  = ignore la 1ère ligne (ligne "Listing...")
# "{print $1}"            = affiche uniquement la 1ère colonne (le nom du paquet)
# "grep -c ."             = compte le nombre de lignes non vides
# ============================================================
PAQUETS=$(apt list --upgradable 2>/dev/null | awk -F/ 'NR>1 {print $1}')
NB=$(echo "$PAQUETS" | grep -c .)

echo ""
echo ">>== PAQUETS DISPONIBLES : $NB ==<<"
echo "[ 1/3 ] - $NB paquet(s) disponible(s) :" >> "$LOG_FILE_NAME"
echo "$PAQUETS" >> "$LOG_FILE_NAME"


# ============================================================
# ÉTAPE 2 — INSTALLATION DES MISES À JOUR
# "apt upgrade"  = télécharge et installe les mises à jour
# "-y"           = répond OUI automatiquement à toutes
#                  les questions (pas d'interaction manuelle)
# ">>"           = envoie la sortie dans le fichier log
# "2>&1"         = redirige aussi les erreurs dans le log
# ============================================================
echo "[ 2/3 ] - Installation des mises à jour" >> "$LOG_FILE_NAME"
echo ">>== [ 2/3 ] INSTALLATION DES MISES À JOUR EN COURS ==<<"

if sudo apt full-upgrade -y >> "$LOG_FILE_NAME" 2>&1; then
    echo "[ 2/3 ] - Installation terminée sans interruption" >> "$LOG_FILE_NAME"
    echo ">>== INSTALLATION TERMINÉE AVEC SUCCÈS ==<<"
else
    ERROR_BANNER
    exit 1
fi


# ============================================================
# ÉTAPE 3 — VÉRIFICATION SECONDAIRE
# On relance apt update + upgrade une 2ème fois
# pour s'assurer qu'il ne reste plus rien à mettre à jour
# Utile si certains paquets dépendent d'autres mis à jour
# juste avant et sont devenus disponibles seulement maintenant
# ============================================================
echo ""
echo "[ 3/3 ] - Vérification secondaire des mises à jour" >> "$LOG_FILE_NAME"
echo ">>== [ 3/3 ] VÉRIFICATION SECONDAIRE EN COURS ==<<"

if sudo apt update >> "$LOG_FILE_NAME" 2>&1; then
    echo "[ 3/3 ] - Vérification terminée" >> "$LOG_FILE_NAME"
else
    ERROR_BANNER
    exit 1
fi

if sudo apt full-upgrade -y >> "$LOG_FILE_NAME" 2>&1; then
    echo "[ 3/3 ] - Vérification secondaire terminée sans interruption" >> "$LOG_FILE_NAME"
    echo ">>== VÉRIFICATION SECONDAIRE TERMINÉE ==<<"
else
    ERROR_BANNER
    exit 1
fi


# ============================================================
# NETTOYAGE DES DÉPENDANCES INUTILES
# "apt autoremove" = supprime les paquets qui ne servent plus
#                   (installés automatiquement comme dépendances
#                   mais devenus orphelins après une désinstallation)
# "-y"             = répond OUI automatiquement
# ============================================================
echo ""
echo ">>== NETTOYAGE DES DÉPENDANCES INUTILES ==<<"
echo "[ + ] - Nettoyage des dépendances orphelines" >> "$LOG_FILE_NAME"

if sudo apt autoremove -y >> "$LOG_FILE_NAME" 2>&1; then
    echo "[ + ] - Nettoyage terminé avec succès" >> "$LOG_FILE_NAME"
    echo ">>== NETTOYAGE TERMINÉ ==<<"
else
    ERROR_BANNER
    exit 1
fi


# ============================================================
# FIN DU SCRIPT — RÉSUMÉ FINAL
# On affiche un message de succès dans le terminal ET dans le log
# "${LOG_FILE_NAME}" = affiche le contenu de la variable
#                      les {} protègent le nom de la variable
# ============================================================
echo ""
echo ">>== MISE À JOUR COMPLÈTE ET RÉUSSIE ==<<"
echo "[ FIN ] - Script terminé sans erreur"                      >> "$LOG_FILE_NAME"
echo "[ FIN ] - Fichier log disponible : $LOG_FILE_NAME"         >> "$LOG_FILE_NAME"
echo ">>----------( $(date) )----------<<"                        >> "$LOG_FILE_NAME"
echo ">>== FICHIER LOG : $LOG_FILE_NAME ==<<"
echo ">>== FIN DU SCRIPT - $(date) ==<<"















