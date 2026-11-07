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
        options.cata="petit"
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
        panel=create_command("TESTS_VALID",panel)
        command=panel.node
        panel=select_child("LongStr",command)
        set_valeur("aaa",panel)
        panel=select_child("ListStr",command)
        add_valeur("aaa",panel)
        add_valeur("bbbb,ccc",panel)
        valider_valeur(panel)
        panel=select_child("PairVal",command)
        add_valeur(2,panel)
        add_valeur("4,6",panel)
        valider_valeur(panel)
        panel=select_child("RangeVal",command)
        set_valeur(4,panel)
        panel=select_child("CardVal",command)
        add_valeur("4,6,5,7",panel)
        valider_valeur(panel)
        panel=select_child("EnumVal",command)
        choose_valeur(3,panel)
        panel=select_child("OrdList",command)
        add_valeur("4,6,5,7",panel)
        valider_valeur(panel)
        panel=select_child("OrdList2",command)
        add_valeur_into(2,panel)
        valider_valeur(panel)
        panel=select_child("TypeVal",command)
        set_valeur(5,panel)
        panel=select_child("Compul",command)
        add_valeur("2",panel)
        add_valeur("1",panel)
        valider_valeur(panel)
        panel=select_child("CompulInto",command)
        add_valeur_into(2,panel)
        add_valeur_into(1,panel)
        valider_valeur(panel)
        panel=select_child("Norep",command)
        add_valeur("2",panel)
        valider_valeur(panel)
        panel=select_child("NorepInto",command)
        add_valeur_into(2,panel)
        valider_valeur(panel)

        panel=select_node(command)
        panel=nomme_concept("MA",panel)

        assert j.isvalid(),j.report()
