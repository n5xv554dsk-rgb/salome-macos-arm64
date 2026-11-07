import os

import pydefx

# Définition des paramètres de lancement
#########################################

# Charger les paramètres par défaut pour 'gaia' avec le nombre de coeurs qu'on
# veut utiliser en deuxième paramètre.
# Ceci permet une configuration rapide où le nombre de coeurs
# demandés est égal au nombre de branches parallèles d'avaluation.
#myParams = pydefx.Parameters("gaia", 4)
myParams = pydefx.Parameters("localhost", 4)

# myParams.salome_parameters contient les paramètres de soumission d'un job
# qu'il est possible de modifier.
# Voir la structure JobParameters dans idl/SALOME_Launcher.idl du module KERNEL
# pour la liste complète des paramètres.

# salome_parameters.work_directory a été rempli à la construction avec le
# répertoire de travail par défaut de la resource "gaia", défini dans le
# catalogue des resources de Salome (fichier CatalogResources.xml du dossier
# d'installation).

# Définir un répertoire de travail personnalisé sur gaia
myParams.salome_parameters.work_directory = os.path.join(
                                      myParams.salome_parameters.work_directory,
                                      "moncas")

# Définir un répertoire local de gestion des fichiers de travail
# Il est aussi possible de définir directement
# salome_parameters.result_directory avec un chemin de répertoire déjà créé.
myParams.createResultDirectory("/tmp")

# On peut indiquer une liste de chemins de fichiers nécessaires au calcul.
# Ils seront copiés dans le répertoire de travail à distance.
# Ce paramètre est vide par défaut.
myParams.salome_parameters.in_files = []

print("ressource de calcul:", myParams.salome_parameters.resource_required.name)
print("nombre d'évaluations parallèles:", myParams.nb_branches)
print("nombre de coeurs demandés:",
      myParams.salome_parameters.resource_required.nb_proc)
print("nombre de noeuds demandés:",
      myParams.salome_parameters.resource_required.nb_node)
print("répertoire de travail:", myParams.salome_parameters.work_directory)
print("répertoire local de gestion:",
      myParams.salome_parameters.result_directory)

# Définition de la fonction d'étude
####################################

# Le script à évaluer doit contenir une fonction "_exec" qui est la fonction
# d'étude.
myScript = pydefx.PyScript()
myScript.loadString("""
def _exec(x, y):
  d = x / y
  t = "{} / {} = {}".format(x, y, d)
  return d, t
""")

print("entrées:", myScript.getInputNames())
print("sorties:", myScript.getOutputNames())

# Définition du plan d'expérience
##################################

# Création d'un plan d'expériences vide pour le script à étudier
mySample = myScript.CreateEmptySample()
# les noms des paramètres en entrée sont identifiés
print("entrées:", mySample.getInputNames())
# les noms des paramètres en sortie sont identifiés
print("sorties:", mySample.getOutputNames())

# 
mySample.setInputValues({ "x":[ x // 10 for x in range(0,100)],
                          "y":[ x % 10 for x in range(0,100)]})

# Création de l'étude et lancement du job
##########################################

myStudy = pydefx.PyStudy()
myStudy.createNewJob(myScript, mySample, myParams)
myStudy.launch() # soumission du job

# Sauvegarder l'étude pour s'y connecter dans une autre session.
# Cette opération marche pour les jobs lancés sur un cluster avec slurm.
# Ca ne marche pas correctement pour des calculs lancés sur localhost.
with open("mystudy.txt", "w") as f:
  f.write(myStudy.dump())

# Il est possible de s'arrêter ici et traiter le résultat dans le script de
# reprise reconnect.py.
# Sinon, voici le code pour attendre la fin du calcul et récupérer le résultat

# voir l'avancement
print("Avancement:", myStudy.getProgress())
print("Etat:", myStudy.getJobState())

# Attendre la fin des calculs
myStudy.wait()

print("Avancement:", myStudy.getProgress())
print("Etat:", myStudy.getJobState())

# Récupérer les résultats - nécessaire pour remplir les listes de résultats.
# L'objet res contient des informations sur l'exécution globale du job.
res = myStudy.getResult()

# Y-a-t-il eu une erreur globale ?
# Les erreurs d'évaluation des points ne sont pas prises en compte ici.
# On ne considère que les erreurs globales, comme les erreurs dans la soumission
# du job ou des plantages du job.
print(res.hasErrors())

# Code de retour de l'exécution du job dans son ensemble.
# = code d'erreur du processus d'évaluation du schéma YACS (commande driver)
print(res.getExitCode())

# Message d'erreur de l'exécution du job (erreur de soumission par exemple)
print(res.getErrors())

# Résultat global utilisé pour des calculs insitu, quand on cherche une valeur
# globale cumulée pour l'ensemble des évaluations, sans garder les résultats de
# chaque point.
# Ce résultat est None s'il n'y a pas de calcul insitu.
print(res.getResult())

# Affichage de l'objet 'sample'
print(myStudy.sample)

# Afficher la représentation interne des paramètres d'entrée
print(myStudy.sample._input)

# Liste des valeurs pour un paramètre d'entrée
print(myStudy.sample.getInput("x"))
print(myStudy.sample.getInput("y"))

# Afficher la représentation interne des paramètres de sortie
print(myStudy.sample._output)

# Liste des résultats pour un paramètre de sortie
print(myStudy.sample.getOutput("d"))
print(myStudy.sample.getOutput("t"))

# Liste des messages d'erreur dans l'évaluation de chaque point
print(myStudy.sample.getMessages())
