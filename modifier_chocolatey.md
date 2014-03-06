# Modifications de Chocolatey #

Pour regénérer une version installable de Chocolatey, il faut d'abord récupérer le dépôt Git : https://github.com/chocolatey/chocolatey et le cloner en local.

Il faut ensuite installer chocolatey pour récupérer le package nuget.
Ce package est récupéré et installé par la commande suivante
cinst nuget.commandline -source "https://chocolatey.org/api/v2/"

package qui sera utilisé pour construire le package chocolatey de la façon suivante :

Le répertoire chocolateyInstall contient les fichier qu'il faudra copier pour lancer une installation, on n'y touche pas !

Le répertoire src contient le code source de Chocolatey. Tous ces fichiers devront être présents dans le package généré dans un sous répertoire tools/chocolateyInstall.

Pour regénérer un package de Chocolatey, il faut lancer build Package en ligne de commande. On récupère un fichier NuPkg dans le sous répertoire _packaged_output Ce fichier peut ensuite être installé en utilisant l'installeur de Chocolatey