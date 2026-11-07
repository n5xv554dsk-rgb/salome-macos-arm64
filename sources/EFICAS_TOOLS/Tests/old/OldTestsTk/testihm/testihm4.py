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
        file=os.path.join(prefs.INSTALLDIR,"Tests/testelem/az.comm")
        j=app.bureau.openJDC(file=file)
        jdcdisplay=app.bureau.JDCDisplay_courant
        init_common(root,jdcdisplay)
        jdctree=jdcdisplay.tree.tree.children[0]
        #commentariser commande MACRO_MATR_ASSE
        panel=select_child("MACRO_MATR_ASSE",jdctree)
        panel=comment_command(panel)
        #decommentariser commande MACRO_MATR_ASSE
        panel=uncomment_command(panel)
        #creation commande commentée
        panel=create_command("LIRE_MAILLAGE",panel)
        panel=comment_command(panel)
        panel=change_commandcomm("mm=LIRE_MAILLAGE(INFO=2,UNITE=21)",panel)
        panel=uncomment_command(panel)
        panel=select_child("DEFI_FONCTION",jdctree)
        delete_node(panel)

        assert j.isvalid(),j.report()
