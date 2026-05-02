# 🔄 Auto-Update Script — Linux

> Script Bash personnel d'apprentissage permettant d'automatiser la mise à jour des paquets Linux,
> surveiller les paquets installés, journaliser toutes les actions système et nettoyer les dépendances inutiles.

---

## 📋 Fonctionnalités

- ✅ Mise à jour automatique de la liste des paquets (`apt update`)
- ✅ Installation des mises à jour disponibles (`apt full-upgrade`)
- ✅ Vérification secondaire pour ne rien manquer
- ✅ Nettoyage des dépendances orphelines (`apt autoremove`)
- ✅ Journalisation complète dans un fichier log horodaté
- ✅ Affichage d'une bannière d'erreur en cas de problème
- ✅ Nom de fichier log unique à chaque exécution (évite les doublons)

---

## 🖥️ Prérequis

- Système Linux Debian / Ubuntu
- Droits `sudo`
- Bash 4.0 ou supérieur

---

## 📁 Structure du projet

```
update-script/
│
├── update.sh          ← Script principal
├── README.md          ← Documentation du projet
├── LICENSE            ← Licence MIT
├── .gitignore         ← Fichiers ignorés par Git
└── logs/
    └── .gitkeep       ← Garde le dossier présent sur GitHub
```

---

## 🚀 Installation

```bash
# Cloner le dépôt
git clone https://github.com/votre-pseudo/update-script.git

# Aller dans le dossier
cd update-script

# Rendre le script exécutable
chmod +x update.sh
```

---

## ▶️ Utilisation

```bash
sudo bash update.sh
```

---

## 📄 Fichiers Log

Les logs sont automatiquement générés dans :

```
/var/log/log-update/
```

Format du nom de fichier :
```
updt-JJMMAAHHMI.nhgt
ex: updt-020526143​0.nhgt
```

Chaque exécution crée un nouveau fichier log unique horodaté.

---

## ⚙️ Fonctionnement détaillé

```
[ 1/3 ] Recherche des mises à jour     → apt update
[ 2/3 ] Installation des mises à jour  → apt full-upgrade -y
[ 3/3 ] Vérification secondaire        → apt update + full-upgrade
[  +  ] Nettoyage                      → apt autoremove -y
```

---

## 🔐 Sécurité

- Les erreurs sont redirigées vers le fichier log (`2>&1`)
- Le script s'arrête immédiatement en cas d'erreur (`exit 1`)
- Les avertissements inutiles sont supprimés (`2>/dev/null`)

---

## 📚 Ce que j'ai appris en faisant ce projet

- La gestion des variables et fonctions en Bash
- Les redirections stdout / stderr (`>>`, `2>&1`, `2>/dev/null`)
- L'utilisation de `awk` pour filtrer du texte
- La gestion des erreurs avec `if/else` et `exit`
- La substitution de commande avec `$()`
- L'utilisation de `tee` pour écrire et afficher en même temps

---

## 👤 Auteur

**Thomas**
> Projet personnel réalisé dans le cadre de mon apprentissage Linux et Bash

---

## 📜 Licence

Ce projet est sous licence **MIT** — libre d'utilisation, modification et partage.
