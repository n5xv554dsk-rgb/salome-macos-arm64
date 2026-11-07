# -*- coding: utf-8 -*-
# Copyright (C) 2007-2026   EDF R&D
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
#
# See http://www.salome-platform.org/ or email : webmaster.salome@opencascade.com
#
"""
    Ce module contient des utilitaires divers
"""
import os,re
import glob
import traceback
import codecs,types

from Accas.extensions.eficas_translation import tr

def substractList(liste1,liste2):
    """
        Enleve tous les elements de liste2 presents dans liste1 et retourne liste1
    """
    for item in liste2:
        try:
            liste1.remove(item)
        except:
            pass
    return liste1

def read_file(file):
    """
        ouvre le fichier file et retourne son contenu
        si pbe retourne None
    """
    try :
        with open(file) as fd :
            text=fd.read()
        return text
    except:
        return None

def save_in_file(file,text,dir=None):
    """
        cree le fichier file (ou l'ecrase s'il existe) et ecrit text dedans
        retourne 1 si OK 0 sinon
    """
    try :
        if dir != None:
            os.chdir(dir)
        with open(file) as fd :
            fd.write(text)
        return 1
    except:
        return 0

def extension_fichier(pathAndFile):
    """ Return ext if path/filename.ext is given """
    return os.path.splitext(pathAndFile)[1][1:]

def stripPath(pathAndFile):
    """ Return filename.ext if path/filename.ext is given """
    return os.path.split(pathAndFile)[1]

def initRep_CataDev(fic_cata,rep_goal):
    """
        Initialise le repertoire des catalogues developpeurs (chemin d'acces donne
        dans le fichier eficas.ini cad :
          - le cree s'il n'existe pas encore
          - copie dedans les 3 fichiers necessaires :
            * __init__.py (pour que ce repertoire puisse etre interprete comme un package)
            * entete.py (pour realiser les import necessaires a l'interpretation des catalogues)
            * declaration_concepts.py (idem)
          - cree le fichier cata_developpeur.py qui sera par la suite importe
    """
    try :
        if not os.path.isdir(rep_goal) :
            os.mkdir(rep_goal)
        #texte_entete = getEnteteCata(fic_cata)
        texte_entete=""
        # rep_goal doit contenir les catalogues du developpeur sous la forme *.capy
        # il faut creer le catalogue developpeur par concatenation de entete,declaration_concepts
        # et de tous ces fichiers
        cur_dir = os.getcwd()
        os.chdir(rep_goal)
        l_cata_dev = glob.glob('*.capy')
        if os.path.isfile('cata_developpeur.py') : os.remove('cata_developpeur.py')
        if len(l_cata_dev) :
            # des catalogues developpeurs sont effectivement presents : on cree cata_dev.py dans rep_goal
            str = ''
            str = str + texte_entete+'\n'
            for file in l_cata_dev :
                str = str + open(file,'r').read() +'\n'
            open('cata_developpeur.py','w+').write(str)
        os.chdir(cur_dir)
    except:
        traceback.print_exc()
        print ( tr("Impossible de transferer les fichiers requis dans : %s", str(rep_goal)))

def getEnteteCata(fic_cata):
    """ Retrouve l'entete du catalogue """
    l_lignes = open(fic_cata,'r').readlines()
    txt = ''
    flag = 0
    for ligne in l_lignes :
        if re.match(u"# debut entete",ligne) : flag = 1
        if re.match(u"# fin entete",ligne) : break
        if not flag : continue
        txt = txt + ligne
    return txt
