# -*- coding: utf-8 -*-
# Modules Python
import os
import unittest
import difflib
import compare
import sys
import Tkinter

# Modules Eficas
import prefs
from Editeur import session
from InterfaceTK import eficas_go,splash,eficas,images
from common import *


class TestCase(unittest.TestCase):
    def setUp(self):
        self.root = Tkinter.Tk()
        images.update_cache()
        # Analyse des arguments de la ligne de commande
        options=session.parse([])
        options.cata="v8"
        pass

    def tearDown(self):
        self.root.destroy()
        init_common(None,None)
        pass

    def test000(self):
        root=self.root
        code="ASTER"
        splash.init_splash(root,code=code,titre="Lancement d'EFICAS pour %s" %code)
        splash._splash.configure(text="Chargement d'EFICAS en cours.\n Veuillez patienter ...")
        app=eficas.EFICAS(root,code=code)
        j=app.bureau.newJDC()
        jdcdisplay=app.bureau.JDCDisplay_courant
        init_common(root,jdcdisplay)

        # commande DEBUT
        co=j.addentite("DEBUT",0)
        # commande FIN
        co=j.addentite("FIN",1)

        jdctree=jdcdisplay.tree.tree.children[0]
        panel=select_child("DEBUT",jdctree)
        panel=create_command("LIRE_MAILLAGE",panel)
        panel=nomme_concept("MA",panel)

        panel=create_command("AFFE_MODELE",panel)
        command=panel.node
        select_child("MAILLAGE",command)
        panel=select_node(command)
        panel=create_mocle("AFFE",panel)
        parent=panel.node
        panel=select_child("PHENOMENE",parent)
        choose_valeur("MECANIQUE",panel)
        panel=select_child("b_mecanique",parent)
        panel=select_child("MODELISATION",panel.node)
        add_valeur_into("3D",panel)
        add_valeur_into("3D_FLUIDE",panel)
        valider_valeur(panel)
        panel=select_node(parent)
        panel=create_mocle("TOUT",panel)
        choose_valeur("OUI",panel)
        panel=select_node(command)
        panel=nomme_concept("MO",panel)

        assert j.isvalid(),j.report()
