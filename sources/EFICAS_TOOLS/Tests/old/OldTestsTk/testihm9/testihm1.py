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

version='v9'

class TestCase(unittest.TestCase):
    def setUp(self):
        self.root = Tkinter.Tk()
        images.update_cache()
        # Analyse des arguments de la ligne de commande
        options=session.parse([])
        options.cata=version
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

        panel=create_param("P1",9.8,panel)
        panel=create_param("P2",8.8,panel)
        panel=create_param("P3",7,panel)
        panel=create_param("P4","[2,3,4]",panel)
        panel=create_param("P5","P3*P1",panel)
        panel=create_param(None,"P1-3",panel)
        panel=create_comment("Pas trouve                shellpanel",panel)

        #commnde LIRE_MAILLAGE
        panel=create_command("LIRE_MAILLAGE",panel)
        command=panel.node
        panel=nomme_concept("MAILLA2",panel)
        panel=select_node(command)
        panel=create_mocle("UNITE",panel)
        panel=set_valeur("P4[1]",panel)
        command.collapse()
        panel=select_node(command)
        #FORMULE
        panel=create_formule("az","a,z","a+z",panel)
        #commande AFFE_MODELE
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
        command.collapse()
        #fin commande AFFE_MODELE
        panel=copier_coller()
        command=panel.node
        panel=create_mocle("AFFE",panel)
        panel=select_node(command)
        panel=create_mocle("AFFE",panel)
        panel=select_mcf("AFFE",1,command)
        parent=panel.node
        panel=create_mocle("GROUP_NO",panel)
        add_valeur("'GNP3','GNP5','GNP6','GNP7','GNP8','GNP9','GNP10','GNP11','GNP12'",panel)
        valider_valeur(panel)
        panel=select_child("PHENOMENE",parent)
        choose_valeur("ACOUSTIQUE",panel)
        panel=select_child("b_acoustique",parent)
        panel=select_child("MODELISATION",panel.node)
        add_valeur_into("PLAN",panel)
        valider_valeur(panel)

        panel=select_mcf("AFFE",2,command)
        parent=panel.node
        panel=create_mocle("GROUP_MA",panel)
        add_valeur("MASSES",panel)
        valider_valeur(panel)
        panel=select_child("PHENOMENE",parent)
        choose_valeur("THERMIQUE",panel)
        panel=select_child("b_thermique",parent)
        panel=select_child("MODELISATION",panel.node)
        add_valeur_into("COQUE",panel)
        valider_valeur(panel)

        panel=select_node(command)
        panel=nomme_concept("AFFE1",panel)
        command.collapse()
        #fin commande AFFE_MODELE
        #commande AFFE_CARA_ELEM
        panel=create_command("AFFE_CARA_ELEM",panel)
        command=panel.node
        panel=select_node(command)
        panel=create_mocle("POUTRE",panel)
        parent=panel.node
        panel=select_child("SECTION",parent)
        choose_valeur("CERCLE",panel)
        panel=select_child("b_cercle",parent)
        panel=select_child("b_constant",panel.node)
        p=panel.node
        panel=select_child("CARA",p)
        add_valeur_into("R",panel)
        add_valeur_into("EP",panel)
        valider_valeur(panel)
        panel=select_child("VALE",p)
        add_valeur("1,2",panel)
        valider_valeur(panel)
        panel=select_node(parent)
        panel=create_mocle("GROUP_MA",panel)
        add_valeur("GR1,GR2",panel)
        valider_valeur(panel)
        panel=select_child("MODELE",command)
        choose_assd("MO",panel)
        panel=select_node(command)
        panel=nomme_concept("CARA",panel)
        command.collapse()
        #fin commande AFFE_CARA_ELEM
        panel=create_command("DEFI_FONCTION",panel)
        command=panel.node
        panel=create_mocle("VALE",panel)
        add_valeur("5.0,3.0",panel)
        add_valeur("P4[1],P3",panel)
        valider_valeur(panel)
        panel=select_child("NOM_PARA",command)
        choose_valeur("DX",panel)
        panel=select_node(command)
        panel=nomme_concept("F1",panel)
        command.collapse()
        #fin DEFI_FONCTION
        panel=create_command("DEFI_FONCTION",panel)
        command=panel.node
        panel=create_mocle("VALE_C",panel)
        add_valeur("5.0,7.0,9.0",panel)
        add_valeur("9.0,8.0,7.0",panel)
        valider_valeur(panel)
        panel=select_child("NOM_PARA",command)
        choose_valeur("DRX",panel)
        panel=select_node(command)
        panel=nomme_concept("F3",panel)
        command.collapse()
        #fin DEFI_FONCTION
#MATER2=DEFI_MATERIAU(ELAS=_F(E=100000000000.0,
#                             NU=0.0,),
#                     ECRO_ASYM_LINE=_F(DC_SIGM_EPSI=0.0,
#                                       SY_C=200000000.0,
#                                       DT_SIGM_EPSI=0.0,
#                                       SY_T=50000000.0,),);

        panel=create_command("DEFI_MATERIAU",panel)
        command=panel.node
        panel=create_mocle("ELAS",panel)
        p=panel.node
        panel=select_child("E",p)
        set_valeur("100000000000.0",panel)
        panel=select_child("NU",p)
        set_valeur("0.0",panel)
        panel=select_node(command)
        panel=create_mocle("ECRO_ASYM_LINE",panel)
        p=panel.node
        panel=select_child("DC_SIGM_EPSI",p)
        set_valeur("0.0",panel)
        panel=select_child("SY_C",p)
        set_valeur("200000000.0",panel)
        panel=select_child("DT_SIGM_EPSI",p)
        set_valeur("0.0",panel)
        panel=select_child("SY_T",p)
        set_valeur("50000000.0",panel)
        panel=select_node(command)
        panel=nomme_concept("MATER2",panel)
        command.collapse()
        #fin DEFI_MATERIAU
        #PS1=DEFI_PARA_SENSI(VALE=1.0,);
        #PS2=DEFI_PARA_SENSI(VALE=1.0,);
        #PS3=DEFI_PARA_SENSI(VALE=1.0,);
        panel=create_command("DEFI_PARA_SENSI",panel)
        command=panel.node
        panel=select_child("VALE",command)
        set_valeur("1.0",panel)
        panel=select_node(command)
        panel=nomme_concept("PS1",panel)
        command.collapse()
        panel=create_command("DEFI_PARA_SENSI",panel)
        command=panel.node
        panel=select_child("VALE",command)
        set_valeur("1.0",panel)
        panel=select_node(command)
        panel=nomme_concept("PS2",panel)
        command.collapse()
        panel=create_command("DEFI_PARA_SENSI",panel)
        command=panel.node
        panel=select_child("VALE",command)
        set_valeur("1.0",panel)
        panel=select_node(command)
        panel=nomme_concept("PS3",panel)
        command.collapse()
#CHMAT2=AFFE_MATERIAU(MAILLAGE=MAIL,
#           AFFE=_F(TOUT='OUI',
#                    MATER=MATER2,),);
        panel=create_command("AFFE_MATERIAU",panel)
        command=panel.node
        panel=select_child("MAILLAGE",command)
        panel=select_child("AFFE",command)
        affe=panel.node
        panel=create_mocle("TOUT",panel)
        choose_valeur("OUI",panel)
        panel=select_child("MATER",affe)
        add_valeur_into("MATER2",panel)
        valider_valeur(panel)
        panel=select_node(command)
        panel=nomme_concept("CHMAT2",panel)
        command.collapse()
#AAAZ=AFFE_CHAR_THER(MODELE=AFFE1,
#                     TEMP_IMPO=_F(TOUT='OUI',
#                                   TEMP=0.0,),);
        panel=create_command("AFFE_CHAR_THER",panel)
        command=panel.node
        panel=create_mocle("TEMP_IMPO",panel)
        temp=panel.node
        panel=create_mocle("TOUT",panel)
        choose_valeur("OUI",panel)
        panel=select_node(temp)
        panel=create_mocle("TEMP",panel)
        panel=set_valeur("0.0",panel)
        panel=select_child("MODELE",command)
        choose_assd("AFFE1",panel)
        panel=select_node(command)
        panel=nomme_concept("AAAZ",panel)
        command.collapse()
#TH1=THER_LINEAIRE(MODELE=AFFE1,
#                  CHAM_MATER=CHMAT2,
#                  EXCIT=_F(CHARGE=AAAZ,),
#                  SENSIBILITE=(PS1,PS2,),);
        panel=create_command("THER_LINEAIRE",panel)
        command=panel.node
        panel=select_child("MODELE",command)
        choose_assd("AFFE1",panel)
        panel=select_child("CHAM_MATER",command)
        panel=select_child("EXCIT",command)
        panel=select_child("CHARGE",panel.node)
        panel=select_node(command)
        panel=create_mocle("SENSIBILITE",panel)
        add_valeur_into("PS1",panel)
        add_valeur_into("PS2",panel)
        valider_valeur(panel)
        panel=select_node(command)
        panel=nomme_concept("TH1",panel)
        command.collapse()
#ACA1=AFFE_CHAR_ACOU(MODELE=AFFE1,
#                    PRES_IMPO=_F(TOUT='OUI',
#                                 PRES=('RI',3.0,3.0,),),);
        panel=create_command("AFFE_CHAR_ACOU",panel)
        command=panel.node
        panel=create_mocle("PRES_IMPO",panel)
        pres=panel.node
        panel=create_mocle("TOUT",panel)
        choose_valeur("OUI",panel)
        panel=select_child("MODELE",command)
        choose_assd("AFFE1",panel)
        panel=select_child("PRES",pres)
        set_complexe("'RI',3.0,3.0",panel)
        panel=select_node(command)
        panel=nomme_concept("ACA1",panel)
        command.collapse()
#MACRO_MATR_ASSE(MODELE=AFFE1,
#                NUME_DDL=CO('DDL1'),
#                MATR_ASSE=_F(MATRICE=CO('MAT1'),
#                             OPTION='RIGI_THER',),);
        panel=create_command("MACRO_MATR_ASSE",panel)
        command=panel.node
        panel=select_child("NUME_DDL",command)
        set_sdco("DDL1",panel)
        panel=select_child("MODELE",command)
        choose_assd("AFFE1",panel)
        panel=select_child("MATR_ASSE",command)
        matr=panel.node
        panel=select_child("OPTION",matr)
        choose_valeur("RIGI_THER",panel)
        panel=select_child("MATRICE",matr)
        set_sdco("MAT1",panel)
        panel=select_node(command)
        command.collapse()
#MACRO_MATR_ASSE(MODELE=AFFE1,
#                NUME_DDL=DDL1,
#                MATR_ASSE=_F(MATRICE=MAT1,
#                             OPTION='RIGI_THER',),);
        panel=create_command("MACRO_MATR_ASSE",panel)
        command=panel.node
        panel=select_child("NUME_DDL",command)
        choose_sdco("DDL1",panel)
        panel=select_child("MODELE",command)
        choose_assd("AFFE1",panel)
        panel=select_child("MATR_ASSE",command)
        matr=panel.node
        panel=select_child("OPTION",matr)
        choose_valeur("RIGI_THER",panel)
        panel=select_child("MATRICE",matr)
        set_sdco("MAT2",panel)
        panel=select_node(command)
        command.collapse()

        assert j.isvalid(),j.report()
