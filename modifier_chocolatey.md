Modifications de Chocolatey

Pour regénérer une version installable de Chocolatey, il faut d'abord récupérer le dépôt Git : https://github.com/chocolatey/chocolatey et le cloner en local.

Il faut ensuite installer chocolatey ainsi que le package nuget.commandline au moyen du script setup.cmd dans le répertoire chocolatey local.
> Si chocolatey est déjà installé, il faut uniquement installer nuget.commandline avec la commande :
> cinst nuget.commandline -source http://chocolatey.org/api/v2

Le répertoire chocolateyInstall contient les fichier qu'il faudra copier pour lancer une installation, on n'y touche pas !

Le répertoire src contient le code source de Chocolatey. Tous ces fichiers devront être présents dans le package généré dans un sous répertoire tools/chocolateyInstall.

Pour regénérer un package de Chocolatey, il faut lancer **build Package** en ligne de commande. On récupère un fichier NuPkg dans le sous répertoire _packaged_output Ce fichier peut ensuite être installé en utilisant l'installeur de Chocolatey


> Modifier la version dans les fichiers chocolatey.nuspec et chocolatey.ps1.