function Write-Introduction {
    Write-Host @"
#########################################################################
#                     Bienvenue dans notre application                    #
#########################################################################

Cette application est con�ue pour vous aider � g�rer vos projets.
Suivez les instructions � l'�cran pour continuer.

"@
}

function Write-MenuPrincipal {
    Write-Host @"
Menu Principal :
1. Cr�er un nouveau projet
2. Ouvrir un projet existant
3. G�rer les param�tres
4. Aide
5. Quitter

Faites votre choix (1-5) :
"@
}

function Write-AideSection1 {
    Write-Host @"
Guide d'utilisation - Section 1 : Cr�ation de projet
------------------------------------------------

Pour cr�er un nouveau projet, suivez ces �tapes :
1. S�lectionnez "Cr�er un nouveau projet" dans le menu principal
2. Entrez le nom de votre projet
3. Choisissez un emplacement pour votre projet
4. S�lectionnez un mod�le de projet

Les mod�les disponibles sont :
- Application Web React
- Application Node.js
- Script PowerShell
- Projet Hybride
"@
}

function Write-AideSection2 {
    Write-Host @"
Guide d'utilisation - Section 2 : Gestion de projet
------------------------------------------------

Pour g�rer un projet existant :
1. S�lectionnez "Ouvrir un projet existant"
2. Naviguez jusqu'au dossier du projet
3. S�lectionnez le fichier de configuration

Options disponibles :
- Modifier les param�tres
- Ajouter des composants
- Supprimer des composants
- Mettre � jour les d�pendances
"@
}

function Write-AideSection3 {
    Write-Host @"
Guide d'utilisation - Section 3 : Param�tres
------------------------------------------

Les param�tres configurables incluent :
1. Environnement de d�veloppement
   - Node.js
   - npm/yarn
   - Git
   - Visual Studio Code

2. Chemins d'acc�s
   - Dossier des projets
   - Dossier des mod�les
   - Dossier des sauvegardes

3. Options de d�ploiement
   - Serveur de d�veloppement
   - Serveur de production
   - Options de build
"@
}

function Write-AideSection4 {
    Write-Host @"
Guide d'utilisation - Section 4 : D�pannage
-----------------------------------------

Probl�mes courants et solutions :

1. Erreur de cr�ation de projet
   - V�rifiez les permissions
   - Assurez-vous d'avoir assez d'espace
   - Validez le nom du projet

2. Erreur d'ouverture de projet
   - V�rifiez le chemin d'acc�s
   - Validez le fichier de configuration
   - Contr�lez les d�pendances

3. Probl�mes de d�pendances
   - Mettez � jour npm/yarn
   - Nettoyez le cache
   - R�installez les modules
"@
}

function Write-AideSection5 {
    Write-Host @"
Guide d'utilisation - Section 5 : Bonnes pratiques
-----------------------------------------------

Recommandations pour vos projets :

1. Structure de projet
   - Organisez vos fichiers logiquement
   - Utilisez des noms descriptifs
   - Maintenez une documentation � jour

2. Gestion de version
   - Committez r�guli�rement
   - �crivez des messages clairs
   - Utilisez des branches

3. Tests
   - �crivez des tests unitaires
   - Automatisez les tests
   - Validez avant de d�ployer
"@
}

function Write-AideSection6 {
    Write-Host @"
Guide d'utilisation - Section 6 : S�curit�
----------------------------------------

Conseils de s�curit� importants :

1. Gestion des secrets
   - Utilisez des variables d'environnement
   - Ne committez jamais de secrets
   - Utilisez un gestionnaire de secrets

2. Permissions
   - Appliquez le principe du moindre privil�ge
   - V�rifiez les permissions des fichiers
   - Utilisez des r�les et groupes

3. Mises � jour
   - Gardez les d�pendances � jour
   - Surveillez les alertes de s�curit�
   - Appliquez les correctifs rapidement
"@
}

function Write-AideSection7 {
    Write-Host @"
Guide d'utilisation - Section 7 : D�ploiement
------------------------------------------

Processus de d�ploiement :

1. Pr�paration
   - V�rifiez la configuration
   - Testez localement
   - Pr�parez les ressources

2. D�ploiement
   - Choisissez l'environnement
   - Validez les param�tres
   - Lancez le d�ploiement

3. V�rification
   - Testez l'application
   - V�rifiez les logs
   - Surveillez les performances
"@
}

function Write-Conclusion {
    Write-Host @"
#########################################################################
#                          Fin du programme                               #
#########################################################################

Merci d'avoir utilis� notre application.
N'oubliez pas de sauvegarder vos modifications avant de quitter.

Pour plus d'aide, consultez notre documentation en ligne
ou contactez notre support technique.

Au revoir !
"@
}

# Point d'entr�e du script
Write-Introduction
Write-MenuPrincipal
Write-AideSection1
Write-AideSection2
Write-AideSection3
Write-AideSection4
Write-AideSection5
Write-AideSection6
Write-AideSection7
Write-Conclusion

# Définir le chemin du projet
$projectRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent

# Importer les modules nécessaires
. "$projectRoot\modules_control\width_modules\file_analyzer.ps1"
. "$projectRoot\modules_control\width_modules\file_splitter.ps1"
. "$projectRoot\modules_control\width_modules\file_logger.ps1"
. "$projectRoot\modules_control\width_modules\file_control.ps1"
. "$projectRoot\logs_files.ps1"