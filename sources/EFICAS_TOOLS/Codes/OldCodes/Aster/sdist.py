# -*- coding: utf-8 -*-
"""
     Ce module sert à construire les distributions d'EFICAS en fonction
     du tag CVS courant
     Les distributions sont :
      - un tar.gz pour UNIX ne contenant pas mxTextTools
      - un zip pour Windows contenant mx TextTools préinstallé
     L'utilisation de ce module est la suivante :
      1- Se mettre dans un répertoire de travail
      2- Configurer son environnement pour utiliser le référentiel CVS EFICAS
      3- Exporter les sources d'EficasV1 par la commande :
            cvs export -r TAG -d Eficas_export EficasV1
         ou TAG est le tag CVS de la version que l'on veut distribuer (par exemple V1_1p1)
      4- Copier le répertoire fourni par Aster (ACCAS6.2.0) au meme niveau que Eficas_export
      5- Aller dans le répertoire Eficas_export
      6- Executer le script sdist.py
             python sdist.py
         Ce qui a pour effet de creer un repertoire dist contenant les 2 distributions
         et de les copier dans le répertoire indiqué par dir_download s'il est accessible

"""
import os,shutil,glob,sys
import types

version="$Name: V7_main $"[7:-2] or 'Test1_4'
# ==========Path du processing fourni par Aster====================
path_Noyau="../../AccasAster"
# ============================================================
nom_distrib="Eficas"+version
path_distrib=os.path.join("dist",nom_distrib)
path_TextTools="/home/eficas/pkg/mxTools/egenix2.0.2pourWindows/mx/TextTools"
dir_download= "/home/eficas/WWW/telechargement/eficas"

def main():
   if os.path.isdir('dist'):shutil.rmtree('dist')

   copyfiles('.',path_distrib,['LICENSE.TERMS','INSTALL','NEWS'])

   copyfiles('../Editeur',os.path.join(path_distrib,'Editeur'),['*.py','faqs.txt'])
   copyfiles('../InterfaceTK',os.path.join(path_distrib,'InterfaceTK'),['*.py','faqs.txt'])
   copyfiles('../InterfaceQT4',os.path.join(path_distrib,'InterfaceQT4'),['*.py'])
   copyfiles('../UiQT4',os.path.join(path_distrib,'UiQT4'),['*.ui','makefile'])
   copyfiles('../Traducteur',os.path.join(path_distrib,'Traducteur'),['*.py'])
   copyfiles('../Ihm',os.path.join(path_distrib,'Ihm'),['*.py'])
   copyfiles('../extensions',os.path.join(path_distrib,'extensions'),['*.py'])
   copyfiles('../Misc',os.path.join(path_distrib,'Misc'),['*.py'])
   copyfiles('../Accas',os.path.join(path_distrib,'Accas'),['*.py'])
   # AIDE
   copyfiles('../Aide',os.path.join(path_distrib,'Aide'),['*_ASTER.adp'])
   copyfiles('../Aide/fichiers_ASTER',os.path.join(path_distrib,'Aide','fichiers_ASTER'),['*'])
   #pour Aster TK
   copyfiles('../AIDE',os.path.join(path_distrib,'AIDE'),['*.py'])
   copyfiles('../AIDE/fichiers',os.path.join(path_distrib,'AIDE','fichiers'),['*'])
   copyfiles('.',os.path.join(path_distrib,'AIDE','fichiers'),['INSTALL','NEWS'])
   copyfiles('../Editeur',os.path.join(path_distrib,'AIDE','fichiers'),['faqs.txt'])
   # Code_Aster
   copyfiles('../Aster',os.path.join(path_distrib,'Aster'),['prefs.py',
                                                            'prefs_ASTER.py',
                                                            'editeur.ini',
                                                            'editeur_salome.ini',
                                                            'eficas_aster.py',
                                                            'qtEficas_aster.py',
                                                            'configuration.py',
                                                            'configuration_ASTER.py',
							    'test_eficas.py',
							    'style.py',
                                                            '__init__.py'
                                                           ])

   # Les Catalogues, Macros, Materiaux et SD
   # copyfiles('Cata/Utilitai',os.path.join(path_distrib,'Aster','Cata','Utilitai'),['*.py'])
   # copyfiles('Cata/pre74',os.path.join(path_distrib,'Aster','Cata','pre74'),['*.py'])

   #copyfiles('Cata/cataSTA6',os.path.join(path_distrib,'Aster','Cata','cataSTA6'),['*.py'])
   #copyfiles('Cata/cataSTA6/Macro',os.path.join(path_distrib,'Aster','Cata','cataSTA6','Macro'),['*.py'])

   #copyfiles('Cata/cataSTA7',os.path.join(path_distrib,'Aster','Cata','cataSTA7'),['*.py'])
   #copyfiles('Cata/cataSTA7/Macro',os.path.join(path_distrib,'Aster','Cata','cataSTA7','Macro'),['*.py'])
   #copyfiles('Cata/cataSTA7/materiau',os.path.join(path_distrib,'Aster','Cata','cataSTA7/materiau'),['README.py'])

   copyfiles('Cata/cataSTA8',os.path.join(path_distrib,'Aster','Cata','cataSTA8'),['*.py'])
   copyfiles('Cata/cataSTA8/Macro',os.path.join(path_distrib,'Aster','Cata','cataSTA8/Macro'),['*.py'])
   copyfiles('Cata/cataSTA8/materiau',os.path.join(path_distrib,'Aster','Cata','cataSTA8/materiau'),['README.py'])

   copyfiles('Cata/cataSTA9',os.path.join(path_distrib,'Aster','Cata','cataSTA9'),['*.py'])
   copyfiles('Cata/cataSTA9/Macro',os.path.join(path_distrib,'Aster','Cata','cataSTA9/Macro'),['*.py'])
   copyfiles('Cata/cataSTA9/materiau',os.path.join(path_distrib,'Aster','Cata','cataSTA9/materiau'),['README.py'])
   copyfiles('Cata/cataSTA9/SD',os.path.join(path_distrib,'Aster','Cata','cataSTA9/SD'),['*.py'])

   copyfiles('Cata/cataSTA10',os.path.join(path_distrib,'Aster','Cata','cataSTA10'),['*.py'])
   copyfiles('Cata/cataSTA10/Macro',os.path.join(path_distrib,'Aster','Cata','cataSTA10/Macro'),['*.py'])
   #copyfiles('Cata/cataSTA10/materiau',os.path.join(path_distrib,'Aster','Cata','cataSTA10/materiau'),['README.py'])
   copyfiles('Cata/cataSTA10/SD',os.path.join(path_distrib,'Aster','Cata','cataSTA10/SD'),['*.py'])

   copyfiles('Cata',os.path.join(path_distrib,'Aster','Cata'),['*9c_clefs_docu'])
   copyfiles('../Aster/Cata',os.path.join(path_distrib,'Aster'),['aster.py',])

   #				______________________

   copyfiles('../convert',os.path.join(path_distrib,'convert'),['*.py'])
   copyfiles('../convert/Parserv5',os.path.join(path_distrib,'convert','Parserv5'),['*.py'])
   copyfiles('../generator',os.path.join(path_distrib,'generator'),['*.py'])
   copyfiles('../Editeur/icons',os.path.join(path_distrib,'Editeur','icons'),['*.gif','*.png'])
   copyfiles('../Editeur/Patrons',os.path.join(path_distrib,'Editeur','Patrons'),['*.com*'])
   copyfiles('../Editeur/Patrons/ASTER',os.path.join(path_distrib,'Editeur','Patrons','ASTER'),['*.com*'])

   copyfiles(os.path.join(path_Noyau,'Noyau'),os.path.join(path_distrib,'Noyau'),['*.py'])
   copyfiles(os.path.join(path_Noyau,'Validation'),os.path.join(path_distrib,'Validation'),['*.py'])
   copyfiles(os.path.join(path_Noyau,'Accas'),os.path.join(path_distrib,'Aster'),['properties.py'])
   copyfiles(os.path.join(path_Noyau,'Cata'),os.path.join(path_distrib,'Aster','Cata'),['__init__.py',])
   copyfiles(os.path.join(path_Noyau,'Macro'),os.path.join(path_distrib,'Aster','Cata','cataSTA9','Macro'),['.py'])
   #os.system("mv "+path_distrib+"/Aster/Cata/cata_STA9.py "+path_distrib+"/Aster/Cata/cataSTA9/cata.py")

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

   shutil.copy('prefs.py.win',os.path.join(path_distrib,'Aster','prefs.py'))
   shutil.copy('editeur.ini.win',os.path.join(path_distrib,'Aster','editeur.ini'))

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
         shutil.copy(file,dir_cible)


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

