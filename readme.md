# Chocolatey #

Chocolatey (http://chocolatey.org/) est un gestionnaire de packages utilisable simplement sous Windows. Il s'appuie sur le système de gestion de packages NuGet mis au point par Microsoft pour l'échange de composants .NET et il utilise PowerShell pour implémenter les commandes.

Chocolatey utilise l'infrastructure Nuget de Microsoft pour le packaging des composants .NET : http://docs.nuget.org/ et permet la récupération de packages logiciels dans un serveur NuGet ou dans des partages de fichiers.

Pour nos besoins d'installation, un simple partage de fichiers sera très facile à utiliser au sein de notre réseau local; par contre, il faudra envisager la mise en plage d'un serveur NuGet pour des besoins d'installation lorsque les bornes sont déployées dans un autre réseau ... [[logiciels:dev:serveur_nuget|voir cette page pour le serveur NuGet]].


## Installation ##

Chocolatey impose la présence du framework .NET en version 4.0.

Pour installer, il faut utiliser ces fichiers dans le repository des packages installables :

- http://ipm-dev-srv/packages/Chocolatey/dotNetFx40_Full_setup.exe
- http://ipm-dev-srv/packages/Chocolatey/chocolatey.x.x.x.x-yyyy.nupkg
- http://ipm-dev-srv/packages/Chocolatey/installChocolatey.cmd
- http://ipm-dev-srv/packages/Chocolatey/InstallChocolatey.ps1


> La version des scripts d'installation présents dans ce répertoire est une version légèrement modifiée par rapport à la version originale disponible sur le site de Chocolatey : 
>   création et activation des sources pour les packages en fonction d'un mode ... voir plus loin.
> 


> Pour une installation sur une machine virtuelle, il suffit de créer un partage avec la machine hôte puis de dérouler : 
>   net use x: \\vboxsrv\Shared
>   récupérer les fichiers sur http://ipm-dev-srv/packages/chocolatey et les recopier dans le partage


En ligne de commande (droits administrateur) :
  
- net use z: \\\ipm-dev-srv\packages mnt_acc-Win7 /user:maintenance /p:no
- z:
- cd z:\chocolatey
- installChocolatey.cmd''
- confirmer l'exécution du script car, par défaut, PowerShell demande une confirmation de lancement ... [[logiciels:dev:powershell|voir PowerShell]].
- fermer la console Windows et la réouvrir (pour mise à jour des variables d'environnement ...)
- chocolatey sources list'' permet de lister les sources disponibles
- clist'' permet de lister les packages disponibles dans les sources configurées


> Pour un PC de développement, il faut lancer ''installChocolatey.cmd /dev'' pour installer les sources de développement. Par défaut, l'installeur installe Chocolatey pour la réalisation d'une borne à mettre en production ...


> On peut créer une variable d'environnement ''ChocolateyInstall'' pour spécifier le chemin où s'installera Chocolatey. Sinon, par défaut, il s'installe dans ''c:\chocolatey'', ce qui est le meilleur choix d'installation. Pour les curieux, de la lecture : https://github.com/chocolatey/chocolatey/wiki/DefaultChocolateyInstallReasoning


> Problèmes connus :
>  
>   * les outils utilisés ne valorisent pas la variable système Errorlevel ... en cours de correction. J'ai une version patchée sur ma machine ... mais ce n'est pas top ! Par contre, il y a une release officielle prévue avec cette correction ... en attente !

## Configuration ##

Chocolatey récupère les packages à installer dans différentes "sources". Il est possible de spécifier la source de recherche d'un package en ligne de commande lors de l'installation, mais ça devient vite pénible quand on recherche toujours les packages dans le même repository ou quand on veut se créer son propre repository.

Les sources principales (utilisables pour toute la machine) sont définies dans le fichier ''C:\Chocolatey\chocolateyinstall\chocolatey.config''. Il est possible d'éditer ce fichier "à la main" pour modifier les sources utilisées, mais ça posera des problèmes lors de mises à jour de Chocolatey. Chocolatey utilise une configuration utilisateur pour les sources (//c:\users\ipm\Chocolatey.config//) et on peut y ajouter de nouvelles sources, activer ou désactiver des sources.

 Pour nos environnements de test et de production, le script d'installation de Chocolatey configure les sources en local sur le PC de développement. Pour voir la configuration : ''chocolatey sources list''.

 Après ces commandes, il ne reste que le repository contenant les packages à tester. Cette configuration convient bien pour une borne en test. La source //kiosks-fab// sera activé pour la mise en production et la source //kiosks-prod// sera activé pour le déploiement terrain.

On peut consulter les sources disponibles en tapant :

    chocolatey sources list

et tous les packages disponibles en tapant :

    chocolatey list

## Utilisation avec les dépôts standard ##

Chocolatey permet l'installation très simple de tout un tas de logiciels standard !

 
En ligne de commande : 


    cinst notepadplusplus


en spécifiant un //feed// particulier : 


    cinst notepadplusplus -source http://somewhere/packages
    cinst notepadplusplus -source 'c:\local packages'

pour mettre à jour un package : 

    cup notepadplusplus


pour mettre à jour tous les packages installés : 

    cup all

pour lister tous les packages installés en local : 

    cver all -lo

pour installer tous les packages d'un repository : 

    cinst all -source http://somewhere/packages

pour installer tous les packages listés dans un fichier : 

    cinst packages.config
    
    <?xml version="1.0" encoding="utf-8"?>
    <packages>
      <package id="apackage" />
      <package id="anotherPackage" version="1.1" />
      <package id="iisexpress" version="8.0" source="webpi" />
      <package id="arubygem" source="ruby" />
      <package id="cruisecontrol.net" />
    </packages>
    </xml>


## Utilisation pour les bornes IPM France ##


En ayant activé uniquement les dépôts IPM France (voir au dessus ...), Chocolatey permet l'installation très simple de tous les packages logiciel qu'on a développé et, en plus, des packages standard qu'on aura sélectionné ! L'application de Maintenance de la borne gère les sources Chocolatey pour installer les packages nécessaires.

**Rappel** : pour utiliser les rouces par défaut de Chocolatey, il faut :
 
- ''chocolatey sources enable -name nuget'', pour activer la source nuget par défaut
- ''chocolatey sources enable -name chocolatey'', pour activer la source Chocolatey par défaut

Le serveur ''ipm-dev-srv'' est utilisé comme un dépôt pour les packages. Pour déposer les packages installables sur le serveur, il suffit d'y accéder en partage de fichiers en utilisant le compte maintenance / mnt_acc-Win7 et de transférer les packages au format ''.nupkg'' (fichier Zip) dans le répertoire correspondant à la source. C'est ce que fait, entre autres, l'utilitaire [[logiciels:dev:makepackage|makePackage]].

Pour les packages de logiciel standard, il est très simple de les récupérer sur le dépôt Chocolatey (http://chocolatey.org/packages) en choisissant un package, puis en demandant son téléchargement. Le fichier téléchargé est un fichier ''.nupkg'' qu'il suffit alors de transférer vers le dépôt IPM.

Ensuite, l'installation des packages se fait en ligne de commande : 

    cinst package


## Création des packages ##

Pour mettre en ligne un package installable, il faut : 
  * un package ''nupkg'' décrivant le package
  * un installeur ou un fichier zip pour les constituants du package à installer sur la machine cible.

### Création de l'installeur ou du zip ###
L'installeur ou le Zip contient les fichiers à installer pour le package. Ce n'est pas toujours nécessaire de construire un tel fichier car il est possible d'embarquer des fichiers à installer directement dans le fichier ''.nupkg''.

La création du Zip peut se faire très facilement avec l'utilitaire 7Zip (http://www.7-zip.org/). L'installation de 7zip sur le poste de travail est très simple par l'intermédiaire de Chocolatey : ''cinst 7zip-commandline'' et on choisit la version //command line// car on va l'utiliser dans les fichiers de commande pour automatiser la préparation des packages. 

Pour créer un exécutable d'installation (ce qui ne devrait pas être le cas pour nous ...), on utilisera de préférence NSIS (http://nsis.sourceforge.net/Main_Page). NSIS est également installable par Chocolatey ''cinst nsis''. 


### Création du package NuGet ###

[[logiciels:dev:makepackage|L'utilitaire ''makePackage'']] prend en charge toutes les opérations de création d'un package. 

Il est également possible d'utiliser un outil graphique : http://docs.nuget.org/docs/creating-packages/using-a-gui-to-build-packages. Cet outil est installable facilement : ''cinst NugetPacketExplorer''. Par contre, en utilisant cet outil, le package réalisé ne sera pas compatible avec les choix d'installation / désinstallation fait pour les bornes !
## Mise à disposition du package ##

Pour pousser des packages vers le dépôt, il faut, au préalable avoir généré une clef de dialogue avec le serveur : 

    \Chocolatey\chocolateyinstall\nuget setApiKey developer:ipmEXTfrance -source http://ipm-dev-srv:8080/nuget/kiosks
    \Chocolatey\chocolateyinstall\nuget setApiKey developer:ipmEXTfrance -source http://ipm-dev-srv:8080/nuget/dev-tests
    \Chocolatey\chocolateyinstall\nuget setApiKey developer:ipmEXTfrance -source http://ipm-dev-srv:8080/nuget/dev

## Et nous, on en fait quoi ? ##
### Tester l'accès au serveur de packages ###
Pour tester l'accès, demander la liste des packages disponibles dans le serveur : ''clist''

### Fonctionnalités Windows ###
Pour gérer les fonctionnalités installées dans Windows : 
''clist -source windowsfeatures'', pour lister les fonctionnalités et leur état activé/désactivé


### Packages de base ###


Installer Java : 
  * ''cinst javaruntime''

Installer Adobe Pdf reader : 
  * ''cinst adobereader''

Installer Adobe Flash plugins : 
  * ''cinst flashplayerplugin''

Installer teamviewer : 
  * ''cinst teamviewer''

Installer IE10 : 
  * ''cinst ie10''


### Packages IPM ###


Installer setKiosk : 
  * ''cinst setKiosk''


### Applications ###
clist -source windowsfeatures

## Modifications de Chocolatey ##

Pour regénérer une version installable de Chocolatey, il faut d'abord récupérer le dépôt Git : https://github.com/chocolatey/chocolatey et le cloner en local.

Le répertoire //chocolateyInstall// contient les fichier qu'il faudra copier pour lancer une installation, on n'y touche pas !

Le répertoire //src// contient le code source de Chocolatey. Tous ces fichiers devront être présents dans le package généré dans un sous répertoire //tools/chocolateyInstall//.

Pour regénérer un package de Chocolatey, il faut lancer ''build Package'' en ligne de commande. On récupère un fichier NuPkg dans le sous répertoire //_packaged_output// Ce fichier peut ensuite être installé en utilisant l'installeur de Chocolatey