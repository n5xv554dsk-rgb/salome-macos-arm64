# -*- coding: utf-8 -*-
"""
     Ce module sert à construire les distributions d'EFICAS pour Openturns
     en fonction du tag CVS courant
     Les distributions sont :
      - un tar.gz pour UNIX ne contenant pas mxTextTools
     L'utilisation de ce module est la suivante :
      1- Se mettre dans un répertoire de travail
      2- Configurer son environnement pour utiliser le référentiel CVS EFICAS
      3- Exporter les sources d'EficasV1 par la commande :
            cvs export -r TAG -d Eficas_export EficasV1
         ou TAG est le tag CVS de la version que l'on veut distribuer (par exemple V1_1p1)
      5- Aller dans le répertoire Eficas_export
      6- Executer le script sdist.py
             python sdist.py
         Ce qui a pour effet de creer un repertoire dist contenant la distribution
         et de la copier dans le répertoire indiqué par dir_download s'il est accessible

"""
import os,shutil,glob,sys
import types

nom_distrib="QTEficasOpenturns_V1_0"
path_distrib=os.path.join("dist",nom_distrib)
path_TextTools="/home/eficas/pkg/mxTools/egenix2.0.2pourWindows/mx/TextTools"
dir_download= "/home/eficas/WWW/telechargement/eficas"

def main():
   if os.path.isdir('dist'):shutil.rmtree('dist')

   copyfiles('.',path_distrib,['LICENSE.TERMS','INSTALL','NEWS'])

   copyfiles('../Editeur',os.path.join(path_distrib,'Editeur'),['*.py','faqs.txt'])
   copyfiles('../InterfaceTK',os.path.join(path_distrib,'InterfaceTK'),['*.py','faqs.txt'])
   copyfiles('../InterfaceQT',os.path.join(path_distrib,'InterfaceQT'),['*.py','faqs.txt'])
   copyfiles('../Ui',os.path.join(path_distrib,'Ui'),['*.ui','makefile'])
   copyfiles('../Openturns',os.path.join(path_distrib,'Openturns'),['*.py','*.ini'])
   copyfiles('../Ihm',os.path.join(path_distrib,'Ihm'),['*.py'])
   copyfiles('../extensions',os.path.join(path_distrib,'extensions'),['*.py'])
   copyfiles('../Misc',os.path.join(path_distrib,'Misc'),['*.py'])
   copyfiles('../Accas',os.path.join(path_distrib,'Accas'),['*.py'])
   copyfiles('../Accas',os.path.join(path_distrib,'Noyau'),['*.py'])
   copyfiles('../Accas',os.path.join(path_distrib,'Validation'),['*.py'])
   # AIDE
   copyfiles('../AIDE',os.path.join(path_distrib,'AIDE'),['*.py'])
   copyfiles('../AIDE/fichiers',os.path.join(path_distrib,'AIDE','fichiers'),['*'])
   copyfiles('.',os.path.join(path_distrib,'AIDE','fichiers'),['INSTALL','NEWS'])
   copyfiles('../Editeur',os.path.join(path_distrib,'AIDE','fichiers'),['faqs.txt'])
   #				______________________

   copyfiles('../convert',os.path.join(path_distrib,'convert'),['*.py'])
   copyfiles('../convert/Parserv5',os.path.join(path_distrib,'convert','Parserv5'),['*.py'])
   copyfiles('../generator',os.path.join(path_distrib,'generator'),['*.py'])
   copyfiles('../Editeur/icons',os.path.join(path_distrib,'Editeur','icons'),['*.gif'])
   copyfiles('../Editeur/icons',os.path.join(path_distrib,'Editeur','icons'),['*.png'])
   copyfiles('../Editeur/Patrons/',os.path.join(path_distrib,'Editeur','Patrons'),['*.com*'])
   copyfiles('../Editeur/Patrons/OPENTURNS',os.path.join(path_distrib,'Editeur','Patrons','OPENTURNS'),['*.com*'])

   copyfiles('../Noyau',os.path.join(path_distrib,'Noyau'),['*.py'])
   copyfiles('../Validation',os.path.join(path_distrib,'Validation'),['*.py'])

   
   tarball= maketarball('dist',nom_distrib,nom_distrib)
   try:
      shutil.copy(tarball,dir_download)
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


main()

