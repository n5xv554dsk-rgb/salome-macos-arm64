# -*- coding: utf-8 -*-
"""
     Ce module sert à construire les distributions de versions alpha d'EFICAS en fonction
     du tag CVS courant (Vx_yaz). Une version alpha est une version dont toutes les fonctionnalités
     ne sont pas implémentées. On utilise pour ces versions, les packages Noyau Validation Cata et Macro
     locaux.
     Les distributions sont :
      - un tar.gz pour UNIX ne contenant pas mxTextTools
      - un zip pour Windows contenant mx TextTools préinstallé
     L'utilisation de ce module est la suivante :
      1- Se mettre dans un répertoire de travail
      2- Configurer son environnement pour utiliser le référentiel CVS EFICAS
      3- Exporter les sources d'Eficas par la commande :
            cvs export -r TAG -d Eficas_export EficasV1_2
         ou TAG est le tag CVS de la version que l'on veut distribuer (par exemple V1_3a1)
      4- Aller dans le répertoire Eficas_export
      4- Executer le script alphasdist.py
             python alphasdist.py
         Ce qui a pour effet de creer un repertoire dist contenant les 2 distributions
         et de les copier dans le répertoire indiqué par dir_download s'il est accessible

"""
import os,shutil,glob,sys
import types

version="$Name: V7_main $"[7:-2] or 'Test1_4'
# ==========Path du processing local           ====================
path_Noyau=".."
# ============================================================
nom_distrib="Eficas"+version+"AsterSTA8"
path_distrib=os.path.join("dist",nom_distrib)
path_TextTools="/home/eficas/pkg/mxTools/egenix2.0.2pourWindows/mx/TextTools"
dir_download= "/home/eficas/WWW/telechargement/eficas"

def main():
   if os.path.isdir('dist'):shutil.rmtree('dist')

   copyfiles('.',path_distrib,['LICENSE.TERMS','INSTALL'])

   copyfiles('../Editeur',os.path.join(path_distrib,'Editeur'),['*.py','faqs.txt'])
   copyfiles('../Traducteur',os.path.join(path_distrib,'Traducteur'),['*.py'])
   copyfiles('../Ihm',os.path.join(path_distrib,'Ihm'),['*.py'])
   copyfiles('../extensions',os.path.join(path_distrib,'extensions'),['*.py'])
   copyfiles('../Misc',os.path.join(path_distrib,'Misc'),['*.py'])
   copyfiles('../Accas',os.path.join(path_distrib,'Accas'),['*.py'])
# Packages globaux (pour toutes les versions sauf surcharge)
   copyfiles('../Aster/Cata',os.path.join(path_distrib,'Aster','Cata'),['*.py', ])
   copyfiles('Cata/Utilitai',os.path.join(path_distrib,'Aster','Cata','Utilitai'),['*.py'])
   copyfiles('Cata/pre74',os.path.join(path_distrib,'Aster','Cata','pre74'),['*.py'])
# version 5
# On enleve la V5 a la demande d AMA
#   copyfiles('Cata/cataSTA5',os.path.join(path_distrib,'Aster','Cata','cataSTA5'),['*.py'])
#version 6
   copyfiles('Cata/cataSTA6',os.path.join(path_distrib,'Aster','Cata','cataSTA6'),['*.py'])
   copyfiles('Cata/cataSTA6/Macro',os.path.join(path_distrib,'Aster','Cata','cataSTA6','Macro'),['*.py'])
#version 7.3
#   copyfiles('Cata/cataSTA73',os.path.join(path_distrib,'Aster','Cata','cataSTA73'),['*.py'])
#   copyfiles('Cata/cataSTA73/Macro',os.path.join(path_distrib,'Aster','Cata','cataSTA73','Macro'),['*.py'])
#version 7.6
   copyfiles('Cata/cataSTA76',os.path.join(path_distrib,'Aster','Cata','cataSTA76'),['*.py'])
   copyfiles('Cata/cataSTA76/Macro',os.path.join(path_distrib,'Aster','Cata','cataSTA76','Macro'),['*.py'])
#version 8 
   copyfiles('Cata/cataSTA8',os.path.join(path_distrib,'Aster','Cata','cataSTA8'),['*.py'])
   copyfiles('Cata/cataSTA8/Macro',os.path.join(path_distrib,'Aster','Cata','cataSTA8,'Macro'),['*.py'])

   copyfiles('../AIDE',os.path.join(path_distrib,'AIDE'),['*.py'])
   copyfiles('../AIDE/fichiers',os.path.join(path_distrib,'AIDE','fichiers'),['*'])
   copyfiles('../Aster',os.path.join(path_distrib,'Aster'),['prefs.py',
                                                            'editeur.ini',
                                                            'properties.py',
                                                            'eficas_aster.py',
							    'style.py',
                                                           ])
   copyfiles('../Aster/Cata',os.path.join(path_distrib,'Aster'),['aster.py',])
   copyfiles('../convert',os.path.join(path_distrib,'convert'),['*.py'])
   copyfiles('../convert/Parserv5',os.path.join(path_distrib,'convert','Parserv5'),['*.py'])

   copyfiles('../generator',os.path.join(path_distrib,'generator'),['*.py'])

   copyfiles('../Editeur/icons',os.path.join(path_distrib,'Editeur','icons'),['*.gif'])
   copyfiles('../Editeur/Patrons',os.path.join(path_distrib,'Editeur','Patrons'),['*.com*'])

   copyfiles(os.path.join(path_Noyau,'Noyau'),os.path.join(path_distrib,'Noyau'),['*.py'])
   copyfiles(os.path.join(path_Noyau,'Validation'),os.path.join(path_distrib,'Validation'),['*.py'])

   copyfiles('../Tools',os.path.join(path_distrib,'Tools'),['*.py'])
   copyfiles('../Tools/foztools',os.path.join(path_distrib,'Tools','foztools'),['*.py'])
   copyfiles('../Pmw',os.path.join(path_distrib,'Pmw'),['*.py'])
   copyfiles('../Pmw/Pmw_1_2',os.path.join(path_distrib,'Pmw','Pmw_1_2'),['*.py'])
   copyfiles('../Pmw/Pmw_1_2/lib',os.path.join(path_distrib,'Pmw','Pmw_1_2','lib'),['*.py','Pmw.def'])
   
   tarball= maketarball('dist',nom_distrib,nom_distrib)
   try:
      shutil.copy(tarball,dir_download)
   except:
      print "Repertoire de download inconnu : ",dir_download

   try:
      shutil.copytree(path_TextTools,os.path.join(path_distrib,'Tools','TextTools'))
   except:
      print "Impossible de recuperer mxTextTools : ",dir_download
      sys.exit(1)

   zipfile= makezipfile('dist',nom_distrib,nom_distrib)
   try:
      shutil.copy(zipfile,dir_download)
   except:
      print "Repertoire de download inconnu : ",dir_download

def make_dir(dir_cible):
   if type(dir_cible) is not types.StringType:
      raise "make_dir : dir_cible doit etre une string (%s)" % `dir_cible`
   head,tail=os.path.split(dir_cible)
   tails=[tail]
   while head and tail and not os.path.isdir(head):
      head,tail=os.path.split(head)
      tails.insert(0, tail)

   for d in tails:
      head = os.path.join(head, d)
      if not os.path.isdir(head):os.mkdir(head)


def copyfiles(dir_origin,dir_cible,listfiles):
   if not os.path.isdir(dir_cible):make_dir(dir_cible)
   for glob_files in listfiles:
      for file in glob.glob(os.path.join(dir_origin,glob_files)):
         if os.path.isfile(file):shutil.copy(file,dir_cible)

def maketarball(dir_trav,dir_cible,nom_tar):
   prev=os.getcwd()
   print prev
   os.chdir(dir_trav)
   os.system("tar -cf "+nom_tar+".tar "+dir_cible)
   os.system("gzip -f9 "+nom_tar+".tar ")
   os.chdir(prev)
   return os.path.join(dir_trav,nom_tar+".tar.gz")

def makezipfile(dir_trav,dir_cible,nom_tar):
   prev=os.getcwd()
   os.chdir(dir_trav)
   os.system("zip -rq "+nom_tar+".zip "+dir_cible)
   os.chdir(prev)
   return os.path.join(dir_trav,nom_tar+".zip")

main()

