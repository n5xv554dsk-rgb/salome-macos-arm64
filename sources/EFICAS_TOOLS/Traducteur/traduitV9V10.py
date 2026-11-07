#!/usr/bin/env python3
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
"""
usage = """usage: %prog [options]
Typical use is:
  python traduitV9V10.py --infile=xxxx --outfile=yyyy
"""

import argparse  # optparse deprecated since Python version 3.2
import sys

import Traducteur.log as log
from Traducteur.load import getJDC
from Traducteur.mocles import parseKeywords
from Traducteur.removemocle import *
from Traducteur.renamemocle import *
from Traducteur.renamemocle import *
from Traducteur.inseremocle import *
from Traducteur.changeValeur import *
from Traducteur.movemocle import *
from Traducteur.dictErreurs import *
from Traducteur.regles import pasDeRegle

atraiter = (
    "AFFE_CARA_ELEM",
    "AFFE_CHAR_CINE",
    "AFFE_CHAR_MECA",
    "AFFE_CHAR_MECA_F",
    "AFFE_MATERIAU",
    "AFFE_MODELE",
    "CALC_CHAM_ELEM",
    "CALC_ELEM",
    "CALC_G",
    "CALC_META",
    "CALC_MODAL",
    "CALC_PRECONT",
    "CALCUL",
    "CALC_MISS",
    "CALC_NO",
    "COMB_FOURIER",
    "COMB_SISM_MODAL",
    "CREA_CHAMP",
    "CREA_RESU",
    "DEFI_BASE_MODALE",
    "DEFI_COMPOR",
    "DEFI_CONTACT",
    "DEFI_GLRC",
    "DEFI_LIST_INST",
    "DEFI_MATERIAU",
    "DYNA_ISS_VARI",
    "DYNA_LINE_HARM",
    "DYNA_LINE_TRAN",
    "DYNA_NON_LINE",
    "DYNA_TRAN_MODAL",
    "EXTR_RESU",
    "IMPR_MACR_ELEM",
    "IMPR_MATRICE",
    "IMPR_RESU",
    "LIRE_RESU",
    "MACR_ADAP_MAIL",
    "MACR_ASCOUF_CALC",
    "MACR_ASPIC_CALC",
    "MACR_ECREVISSE",
    "MACR_INFO_MAIL",
    "MACR_LIGP_COUPE",
    "MACRO_ELAS_MULT",
    "MACRO_MATR_AJOU",
    "MACRO_MISS_3D",
    "MECA_STATIQUE",
    "MODE_ITER_INV",
    "MODE_ITER_SIMULT",
    "MODE_STATIQUE",
    "MODI_REPERE",
    "POST_CHAM_XFEM",
    "POST_ELEM",
    "POST_GP",
    "POST_K1_K2_K3",
    "POST_RCCM",
    "POST_RELEVE_T",
    "POST_ZAC",
    "PROJ_CHAMP",
    "PROJ_MESU_MODAL",
    "RECU_FONCTION",
    "REST_SOUS_STRUC",
    "REST_GENE_PHYS",
    "REST_SPEC_PHYS",
    "STAT_NON_LINE",
    "SIMU_POINT_MAT",
    "TEST_RESU",
    "THER_LINEAIRE",
    "THER_NON_LINE",
    "THER_NON_LINE_MO",
)

dict_erreurs = {
    # STA10
    #
    "AFFE_CHAR_MECA_CONTACT": "Attention, modification de la definition du CONTACT : nommer DEFI_CONTACT,verifier les parametres globaux et le mettre dans le calcul",
    "AFFE_CHAR_MECA_LIAISON_UNILATER": "Attention, modification de la definition du CONTACT : nommer DEFI_CONTACT,verifier les parametres globaux et le mettre dans le calcul",
    "AFFE_CHAR_MECA_F_LIAISON_UNILATER": "Attention, modification de la definition du CONTACT : nommer DEFI_CONTACT,verifier les parametres globaux et le mettre dans le calcul",
    "AFFE_CHAR_MECA_GRAPPE_FLUIDE": "Resorption de GRAPPE_FLUIDE en version 10",
    "DEFI_MATERIAU_LMARC": "Resorption loi LMARC en version 10",
    "DEFI_MATERIAU_LMARC_FO": "Resorption loi LMARC en version 10",
    "POST_ZAC": "Resorption POST_ZAC en version 10",
    "AFFE_CHAR_MECA_ARLEQUIN": "Resorption ARLEQUIN en version 10",
    "PROJ_CHAMP_CHAM_NO": "Attention, verifier pour PROJ_CHAMP la presence de MODELE1/MAILLAGE1 et MODELE2/MAILLAGE2",
    "COMB_SISM_MODAL_COMB_MULT_APPUI": "Attention, verifier GROUP_APPUI pour COMB_SISM_MODAL car on est dans le cas MULTI_APPUI=DECORRELE",
    "CALC_PRECONT_SOLVEUR_PARALLELISME": "Modification du PARALLELISME qui se definit au niveau de AFFE_MODELE ou MODI_MODELE",
    "CALC_PRECONT_SOLVEUR_PARTITION": "Modification de PARTITION qui se definit au niveau de AFFE_MODELE ou MODI_MODELE",
    "DYNA_LINE_HARM_SOLVEUR_PARALLELISME": "Modification du PARALLELISME qui se definit au niveau de AFFE_MODELE ou MODI_MODELE",
    "DYNA_LINE_HARM_SOLVEUR_PARTITION": "Modification de PARTITION qui se definit au niveau de AFFE_MODELE ou MODI_MODELE",
    "DYNA_LINE_TRAN_SOLVEUR_PARALLELISME": "Modification du PARALLELISME qui se definit au niveau de AFFE_MODELE ou MODI_MODELE",
    "DYNA_LINE_TRAN_SOLVEUR_PARTITION": "Modification de PARTITION qui se definit au niveau de AFFE_MODELE ou MODI_MODELE",
    "DYNA_TRAN_MODAL_SOLVEUR_PARALLELISME": "Modification du PARALLELISME qui se definit au niveau de AFFE_MODELE ou MODI_MODELE",
    "DYNA_TRAN_MODAL_SOLVEUR_PARTITION": "Modification de PARTITION qui se definit au niveau de AFFE_MODELE ou MODI_MODELE",
    "MACR_ASCOUF_CALC_SOLVEUR_PARALLELISME": "Modification du PARALLELISME qui se definit au niveau de AFFE_MODELE ou MODI_MODELE",
    "MACR_ASCOUF_CALC_SOLVEUR_PARTITION": "Modification de PARTITION qui se definit au niveau de AFFE_MODELE ou MODI_MODELE",
    "MACR_ASPIQ_CALC_SOLVEUR_PARALLELISME": "Modification du PARALLELISME qui se definit au niveau de AFFE_MODELE ou MODI_MODELE",
    "MACR_ASPIQ_CALC_SOLVEUR_PARTITION": "Modification de PARTITION qui se definit au niveau de AFFE_MODELE ou MODI_MODELE",
    "MACRO_MATR_AJOU_SOLVEUR_PARALLELISME": "Modification du PARALLELISME qui se definit au niveau de AFFE_MODELE ou MODI_MODELE",
    "MACRO_MATR_AJOU_SOLVEUR_PARTITION": "Modification de PARTITION qui se definit au niveau de AFFE_MODELE ou MODI_MODELE",
    "MECA_STATIQUE_SOLVEUR_PARALLELISME": "Modification du PARALLELISME qui se definit au niveau de AFFE_MODELE ou MODI_MODELE",
    "MECA_STATIQUE_SOLVEUR_PARTITION": "Modification de PARTITION qui se definit au niveau de AFFE_MODELE ou MODI_MODELE",
    "MODE_STATIQUE_SOLVEUR_PARALLELISME": "Modification du PARALLELISME qui se definit au niveau de AFFE_MODELE ou MODI_MODELE",
    "MODE_STATIQUE_SOLVEUR_PARTITION": "Modification de PARTITION qui se definit au niveau de AFFE_MODELE ou MODI_MODELE",
    "STAT_NON_LINE_SOLVEUR_PARALLELISME": "Modification du PARALLELISME qui se definit au niveau de AFFE_MODELE ou MODI_MODELE",
    "STAT_NON_LINE_SOLVEUR_PARTITION": "Modification de PARTITION qui se definit au niveau de AFFE_MODELE ou MODI_MODELE",
    "THER_LINEAIRE_SOLVEUR_PARALLELISME": "Modification du PARALLELISME qui se definit au niveau de AFFE_MODELE ou MODI_MODELE",
    "THER_LINEAIRE_SOLVEUR_PARTITION": "Modification de PARTITION qui se definit au niveau de AFFE_MODELE ou MODI_MODELE",
    "THER_NON_LINE_SOLVEUR_PARALLELISME": "Modification du PARALLELISME qui se definit au niveau de AFFE_MODELE ou MODI_MODELE",
    "THER_NON_LINE_SOLVEUR_PARTITION": "Modification de PARTITION qui se definit au niveau de AFFE_MODELE ou MODI_MODELE",
    "DYNA_NON_LINE_SOLVEUR_PARALLELISME": "Modification du PARALLELISME qui se definit au niveau de AFFE_MODELE ou MODI_MODELE",
    "DYNA_NON_LINE_SOLVEUR_PARTITION": "Modification de PARTITION qui se definit au niveau de AFFE_MODELE ou MODI_MODELE",
    "STAT_NON_LINE_INCREMENT": "Attention, modification de la subdivision des pas : nommer DEFI_LIST_INST et verifier son appel dans STAT_NON_LINE",
    "CALC_PRECONT_INCREMENT": "Attention, modification de la subdivision des pas : nommer DEFI_LIST_INST et verifier son appel dans CALC_PRECONT",
    "DYNA_NON_LINE_INCREMENT": "Attention, modification de la subdivision des pas : nommer DEFI_LIST_INST et verifier son appel dans DYNA_NON_LINE",
    "MACR_ASCOUF_CALC_INCREMENT": "Attention, modification de la subdivision des pas : nommer DEFI_LIST_INST et verifier son appel dans MACR_ASCOUF_CALC",
    "MACR_ASPIQ_CALC_INCREMENT": "Attention, modification de la subdivision des pas : nommer DEFI_LIST_INST et verifier son appel dans MACR_ASPIQ_CALC",
    "SIMU_POINT_MAT_INCREMENT": "Attention, modification de la subdivision des pas : nommer DEFI_LIST_INST et verifier son appel dans SIMU_POINT_MAT",
    "CALC_ELEM_SENSIBILITE": "Le post-traitement SENSIBILITE est a supprimer de CALC_ELEM et a faire via CALC_SENSI",
    "CALC_MISS_OPTION": "Attention, transfert MACRO_MISS_3D en CALC_MISS : utiliser un DEFI_SOL_MISS pour obtenir TABLE_SOL",
}

sys.dict_erreurs = dict_erreurs


def traduc(infile, outfile, flog=None):
    hdlr = log.initialise(flog)
    jdc = getJDC(infile, atraiter)
    root = jdc.root

    # Parse les mocles des commandes
    parseKeywords(root)

    ####################### initialisation et traitement des erreurs #########################

    #####RESORPTION

    genereErreurPourCommande(jdc, ("POST_ZAC",))
    genereErreurMCF(jdc, "AFFE_CHAR_MECA", "GRAPPE_FLUIDE")
    genereErreurMCF(jdc, "DEFI_MATERIAU", "LMARC")
    genereErreurMCF(jdc, "DEFI_MATERIAU", "LMARC_FO")
    genereErreurMCF(jdc, "AFFE_CHAR_MECA", "ARLEQUIN")

    #####SOLVEUR

    ####################### traitement MUMPS/PARALELLISME-PARTITION ##################
    # commandes concernes en plus : CALC_FORC_AJOU?,CALC_MATR_AJOU?
    # */SOLVEUR/CHARGE_PROCO_MA(SD)--> AFFE_MODELE (ou MODI_MODELE)/PARTITION/.
    # */SOLVEUR/PARALLELISME =CENTRALISE--> AFFE_MODELE (ou MODI_MODELE)/PARTITION/PARALLELISME = CENTRALISE
    # */SOLVEUR/PARALLELISME = "DISTRIBUE_MC/MD/SD"--> AFFE_MODELE/PARTITION/PARALLELISME = "MAIL_CONTIGU/MAIL_DISPERSE/SOUS_DOMAINE"
    # */SOLVEUR/PARTITION --> AFFE_MODELE (ou MODI_MODELE)/PARTITION/PARTITION

    genereErreurMotCleInFact(jdc, "CALC_PRECONT", "SOLVEUR", "PARALLELISME")
    genereErreurMotCleInFact(jdc, "CALC_PRECONT", "SOLVEUR", "PARTITION")
    genereErreurMotCleInFact(jdc, "DYNA_LINE_HARM", "SOLVEUR", "PARALLELISME")
    genereErreurMotCleInFact(jdc, "DYNA_LINE_HARM", "SOLVEUR", "PARTITION")
    genereErreurMotCleInFact(jdc, "DYNA_LINE_TRAN", "SOLVEUR", "PARALLELISME")
    genereErreurMotCleInFact(jdc, "DYNA_LINE_TRAN", "SOLVEUR", "PARTITION")
    genereErreurMotCleInFact(jdc, "DYNA_TRAN_MODAL", "SOLVEUR", "PARALLELISME")
    genereErreurMotCleInFact(jdc, "DYNA_TRAN_MODAL", "SOLVEUR", "PARTITION")
    genereErreurMotCleInFact(jdc, "MACR_ASCOUF_CALC", "SOLVEUR", "PARALLELISME")
    genereErreurMotCleInFact(jdc, "MACR_ASCOUF_CALC", "SOLVEUR", "PARTITION")
    genereErreurMotCleInFact(jdc, "MACR_ASPIQ_CALC", "SOLVEUR", "PARALLELISME")
    genereErreurMotCleInFact(jdc, "MACR_ASPIQ_CALC", "SOLVEUR", "PARTITION")
    genereErreurMotCleInFact(jdc, "MACRO_MATR_AJOU", "SOLVEUR", "PARALLELISME")
    genereErreurMotCleInFact(jdc, "MACRO_MATR_AJOU", "SOLVEUR", "PARTITION")
    genereErreurMotCleInFact(jdc, "MECA_STATIQUE", "SOLVEUR", "PARALLELISME")
    genereErreurMotCleInFact(jdc, "MECA_STATIQUE", "SOLVEUR", "PARTITION")
    genereErreurMotCleInFact(jdc, "MODE_STATIQUE", "SOLVEUR", "PARALLELISME")
    genereErreurMotCleInFact(jdc, "MODE_STATIQUE", "SOLVEUR", "PARTITION")
    genereErreurMotCleInFact(jdc, "STAT_NON_LINE", "SOLVEUR", "PARALLELISME")
    genereErreurMotCleInFact(jdc, "STAT_NON_LINE", "SOLVEUR", "PARTITION")
    genereErreurMotCleInFact(jdc, "THER_LINEAIRE", "SOLVEUR", "PARALLELISME")
    genereErreurMotCleInFact(jdc, "THER_LINEAIRE", "SOLVEUR", "PARTITION")
    genereErreurMotCleInFact(jdc, "THER_NON_LINE", "SOLVEUR", "PARALLELISME")
    genereErreurMotCleInFact(jdc, "THER_NON_LINE", "SOLVEUR", "PARTITION")
    genereErreurMotCleInFact(jdc, "THER_NON_LINE_MO", "SOLVEUR", "PARALLELISME")
    genereErreurMotCleInFact(jdc, "THER_NON_LINE_MO", "SOLVEUR", "PARTITION")
    genereErreurMotCleInFact(jdc, "DYNA_NON_LINE", "SOLVEUR", "PARALLELISME")
    genereErreurMotCleInFact(jdc, "DYNA_NON_LINE", "SOLVEUR", "PARTITION")

    ####################### traitement mot cle INCREMENT redecoupage en temps #######################
    renameMotCleSiRegle(
        jdc,
        "STAT_NON_LINE",
        "INCREMENT",
        "INCREMENT_NEW",
        ((("INCREMENT", "SUBD_METHODE"), "existeMCsousMCF"),),
        1,
    )
    moveMCFToCommand(jdc, "STAT_NON_LINE", "INCREMENT_NEW", "DEFI_LIST_INST", "ECHEC")
    removeMotCleInFact(
        jdc, "STAT_NON_LINE", "INCREMENT_NEW", "SUBD_COEF_PAS_1", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "STAT_NON_LINE", "INCREMENT_NEW", "SUBD_ITER_FIN", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "STAT_NON_LINE", "INCREMENT_NEW", "SUBD_ITER_IGNO", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "STAT_NON_LINE", "INCREMENT_NEW", "SUBD_ITER_PLUS", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "STAT_NON_LINE", "INCREMENT_NEW", "SUBD_METHODE", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "STAT_NON_LINE", "INCREMENT_NEW", "SUBD_NIVEAU", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "STAT_NON_LINE", "INCREMENT_NEW", "SUBD_OPTION", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "STAT_NON_LINE", "INCREMENT_NEW", "SUBD_PAS", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "STAT_NON_LINE", "INCREMENT_NEW", "SUBD_PAS_MINI", pasDeRegle(), 0
    )
    renameMotCle(jdc, "STAT_NON_LINE", "INCREMENT_NEW", "INCREMENT")

    renameMotCleSiRegle(
        jdc,
        "CALC_PRECONT",
        "INCREMENT",
        "INCREMENT_NEW",
        ((("INCREMENT", "SUBD_METHODE"), "existeMCsousMCF"),),
        1,
    )
    moveMCFToCommand(jdc, "CALC_PRECONT", "INCREMENT_NEW", "DEFI_LIST_INST", "ECHEC")
    removeMotCleInFact(
        jdc, "CALC_PRECONT", "INCREMENT_NEW", "SUBD_COEF_PAS_1", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "CALC_PRECONT", "INCREMENT_NEW", "SUBD_ITER_FIN", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "CALC_PRECONT", "INCREMENT_NEW", "SUBD_ITER_IGNO", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "CALC_PRECONT", "INCREMENT_NEW", "SUBD_ITER_PLUS", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "CALC_PRECONT", "INCREMENT_NEW", "SUBD_METHODE", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "CALC_PRECONT", "INCREMENT_NEW", "SUBD_NIVEAU", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "CALC_PRECONT", "INCREMENT_NEW", "SUBD_OPTION", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "CALC_PRECONT", "INCREMENT_NEW", "SUBD_PAS", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "CALC_PRECONT", "INCREMENT_NEW", "SUBD_PAS_MINI", pasDeRegle(), 0
    )
    renameMotCle(jdc, "CALC_PRECONT", "INCREMENT_NEW", "INCREMENT")

    renameMotCleSiRegle(
        jdc,
        "DYNA_NON_LINE",
        "INCREMENT",
        "INCREMENT_NEW",
        ((("INCREMENT", "SUBD_METHODE"), "existeMCsousMCF"),),
        1,
    )
    moveMCFToCommand(jdc, "DYNA_NON_LINE", "INCREMENT_NEW", "DEFI_LIST_INST", "ECHEC")
    removeMotCleInFact(
        jdc, "DYNA_NON_LINE", "INCREMENT_NEW", "SUBD_COEF_PAS_1", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "DYNA_NON_LINE", "INCREMENT_NEW", "SUBD_ITER_FIN", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "DYNA_NON_LINE", "INCREMENT_NEW", "SUBD_ITER_IGNO", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "DYNA_NON_LINE", "INCREMENT_NEW", "SUBD_ITER_PLUS", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "DYNA_NON_LINE", "INCREMENT_NEW", "SUBD_METHODE", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "DYNA_NON_LINE", "INCREMENT_NEW", "SUBD_NIVEAU", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "DYNA_NON_LINE", "INCREMENT_NEW", "SUBD_OPTION", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "DYNA_NON_LINE", "INCREMENT_NEW", "SUBD_PAS", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "DYNA_NON_LINE", "INCREMENT_NEW", "SUBD_PAS_MINI", pasDeRegle(), 0
    )
    renameMotCle(jdc, "DYNA_NON_LINE", "INCREMENT_NEW", "INCREMENT")

    renameMotCleSiRegle(
        jdc,
        "MACR_ASCOUF_CALC",
        "INCREMENT",
        "INCREMENT_NEW",
        ((("INCREMENT", "SUBD_METHODE"), "existeMCsousMCF"),),
        1,
    )
    moveMCFToCommand(
        jdc, "MACR_ASCOUF_CALC", "INCREMENT_NEW", "DEFI_LIST_INST", "ECHEC"
    )
    removeMotCleInFact(
        jdc, "MACR_ASCOUF_CALC", "INCREMENT_NEW", "SUBD_COEF_PAS_1", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "MACR_ASCOUF_CALC", "INCREMENT_NEW", "SUBD_ITER_FIN", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "MACR_ASCOUF_CALC", "INCREMENT_NEW", "SUBD_ITER_IGNO", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "MACR_ASCOUF_CALC", "INCREMENT_NEW", "SUBD_ITER_PLUS", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "MACR_ASCOUF_CALC", "INCREMENT_NEW", "SUBD_METHODE", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "MACR_ASCOUF_CALC", "INCREMENT_NEW", "SUBD_NIVEAU", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "MACR_ASCOUF_CALC", "INCREMENT_NEW", "SUBD_OPTION", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "MACR_ASCOUF_CALC", "INCREMENT_NEW", "SUBD_PAS", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "MACR_ASCOUF_CALC", "INCREMENT_NEW", "SUBD_PAS_MINI", pasDeRegle(), 0
    )
    renameMotCle(jdc, "MACR_ASCOUF_CALC", "INCREMENT_NEW", "INCREMENT")

    renameMotCleSiRegle(
        jdc,
        "MACR_ASPIQ_CALC",
        "INCREMENT",
        "INCREMENT_NEW",
        ((("INCREMENT", "SUBD_METHODE"), "existeMCsousMCF"),),
        1,
    )
    moveMCFToCommand(jdc, "MACR_ASPIQ_CALC", "INCREMENT_NEW", "DEFI_LIST_INST", "ECHEC")
    removeMotCleInFact(
        jdc, "MACR_ASPIQ_CALC", "INCREMENT_NEW", "SUBD_COEF_PAS_1", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "MACR_ASPIQ_CALC", "INCREMENT_NEW", "SUBD_ITER_FIN", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "MACR_ASPIQ_CALC", "INCREMENT_NEW", "SUBD_ITER_IGNO", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "MACR_ASPIQ_CALC", "INCREMENT_NEW", "SUBD_ITER_PLUS", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "MACR_ASPIQ_CALC", "INCREMENT_NEW", "SUBD_METHODE", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "MACR_ASPIQ_CALC", "INCREMENT_NEW", "SUBD_NIVEAU", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "MACR_ASPIQ_CALC", "INCREMENT_NEW", "SUBD_OPTION", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "MACR_ASPIQ_CALC", "INCREMENT_NEW", "SUBD_PAS", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "MACR_ASPIQ_CALC", "INCREMENT_NEW", "SUBD_PAS_MINI", pasDeRegle(), 0
    )
    renameMotCle(jdc, "MACR_ASPIQ_CALC", "INCREMENT_NEW", "INCREMENT")

    renameMotCleSiRegle(
        jdc,
        "SIMU_POINT_MAT",
        "INCREMENT",
        "INCREMENT_NEW",
        ((("INCREMENT", "SUBD_METHODE"), "existeMCsousMCF"),),
        1,
    )
    moveMCFToCommand(jdc, "SIMU_POINT_MAT", "INCREMENT_NEW", "DEFI_LIST_INST", "ECHEC")
    removeMotCleInFact(
        jdc, "SIMU_POINT_MAT", "INCREMENT_NEW", "SUBD_COEF_PAS_1", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "SIMU_POINT_MAT", "INCREMENT_NEW", "SUBD_ITER_FIN", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "SIMU_POINT_MAT", "INCREMENT_NEW", "SUBD_ITER_IGNO", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "SIMU_POINT_MAT", "INCREMENT_NEW", "SUBD_ITER_PLUS", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "SIMU_POINT_MAT", "INCREMENT_NEW", "SUBD_METHODE", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "SIMU_POINT_MAT", "INCREMENT_NEW", "SUBD_NIVEAU", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "SIMU_POINT_MAT", "INCREMENT_NEW", "SUBD_OPTION", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "SIMU_POINT_MAT", "INCREMENT_NEW", "SUBD_PAS", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "SIMU_POINT_MAT", "INCREMENT_NEW", "SUBD_PAS_MINI", pasDeRegle(), 0
    )
    renameMotCle(jdc, "SIMU_POINT_MAT", "INCREMENT_NEW", "INCREMENT")

    removeMotCleInFact(jdc, "DEFI_LIST_INST", "ECHEC", "INST_INIT")
    removeMotCleInFact(jdc, "DEFI_LIST_INST", "ECHEC", "INST_FIN")
    removeMotCleInFact(jdc, "DEFI_LIST_INST", "ECHEC", "NUME_INST_FIN")
    removeMotCleInFact(jdc, "DEFI_LIST_INST", "ECHEC", "NUME_INST_INIT")
    removeMotCleInFact(jdc, "DEFI_LIST_INST", "ECHEC", "PRECISION")
    chercheOperInsereFacteur(jdc, "DEFI_LIST_INST", "DEFI_LIST", pasDeRegle(), 1)
    moveMotCleFromFactToFact(jdc, "DEFI_LIST_INST", "ECHEC", "LIST_INST", "DEFI_LIST")
    removeMotCleInFact(jdc, "DEFI_LIST_INST", "ECHEC", "LIST_INST")

    ###################### traitement de NPREC_SOLVEUR ##########
    removeMotCleInFact(
        jdc, "MODE_ITER_SIMULT", "CALC_FREQ", "NPREC_SOLVEUR", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "MODE_ITER_INV", "CALC_FREQ", "NPREC_SOLVEUR", pasDeRegle(), 0
    )
    removeMotCleInFact(jdc, "CALC_MODAL", "CALC_FREQ", "NPREC_SOLVEUR", pasDeRegle(), 0)
    removeMotCle(jdc, "IMPR_STURM", "NPREC_SOLVEUR")
    removeMotCleInFact(
        jdc, "MACRO_MATR_AJOU", "CALC_FREQ", "NPREC_SOLVEUR", pasDeRegle(), 0
    )

    ###################### traitement CALC_MODAL SOLVEUR ############
    removeMotCle(jdc, "CALC_MODAL", "SOLVEUR", pasDeRegle())

    ##################### traitement DYNA_TRAN-MODAL ADAPT #################
    changementValeur(jdc, "DYNA_TRAN_MODAL", "METHODE", {"ADAPT": "ADAPT_ORDRE2"})

    #################### traitement STAT/DYNA_NON_LINE OBSERVATION SUIVI_DDL=NON ###########
    removeMotCleInFactCourantSiRegle(
        jdc,
        "STAT_NON_LINE",
        "OBSERVATION",
        "SUIVI_DDL",
        ((("SUIVI_DDL", "NON", jdc), "MCsousMCFcourantaPourValeur"),),
    )
    removeMotCleInFactCourantSiRegle(
        jdc,
        "DYNA_NON_LINE",
        "OBSERVATION",
        "SUIVI_DDL",
        ((("SUIVI_DDL", "NON", jdc), "MCsousMCFcourantaPourValeur"),),
    )

    ################### traitement STAT/DYNA_NON_LINE ARCH_ETAT_INIT ###########
    removeMotCleInFact(
        jdc, "STAT_NON_LINE", "ARCHIVAGE", "ARCH_ETAT_INIT", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "SIMU_POINT_MAT", "ARCHIVAGE", "ARCH_ETAT_INIT", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "DYNA_NON_LINE", "ARCHIVAGE", "ARCH_ETAT_INIT", pasDeRegle(), 0
    )

    ################### traitement STAT/DYNA_NON_LINE CRIT_FLAMB ###############
    removeMotCleInFactCourantSiRegle(
        jdc,
        "STAT_NON_LINE",
        "CRIT_FLAMB",
        "INST_CALCUL",
        ((("INST_CALCUL", "TOUT_PAS", jdc), "MCsousMCFcourantaPourValeur"),),
    )
    removeMotCleInFactCourantSiRegle(
        jdc,
        "DYNA_NON_LINE",
        "CRIT_FLAMB",
        "INST_CALCUL",
        ((("INST_CALCUL", "TOUT_PAS", jdc), "MCsousMCFcourantaPourValeur"),),
    )

    #####COMPORTEMENT/CARA

    ###################  traitement AFFE_MODELE/SHB8 ##########################
    changementValeurDsMCF(jdc, "AFFE_MODELE", "AFFE", "MODELISATION", {"SHB8": "SHB"})

    ###################  traitement COMP_ELAS et COMP_INCR  DEFORMATION = GREEN ##############"
    dGREEN = {
        "GREEN_GR": "GROT_GDEP",
        "GREEN": "GROT_GDEP",
        "REAC_GEOM": "GROT_GDEP",
        "EULER_ALMANSI": "GROT_GDEP",
        "COROTATIONNEL": "GDEF_HYPO_ELAS",
    }
    changementValeurDsMCF(jdc, "SIMU_POINT_MAT", "COMP_ELAS", "DEFORMATION", dGREEN)
    changementValeurDsMCF(jdc, "STAT_NON_LINE", "COMP_ELAS", "DEFORMATION", dGREEN)
    changementValeurDsMCF(jdc, "DYNA_NON_LINE", "COMP_ELAS", "DEFORMATION", dGREEN)
    changementValeurDsMCF(jdc, "CALCUL", "COMP_ELAS", "DEFORMATION", dGREEN)
    changementValeurDsMCF(jdc, "POST_GP", "COMP_ELAS", "DEFORMATION", dGREEN)
    changementValeurDsMCF(jdc, "CALC_G", "COMP_ELAS", "DEFORMATION", dGREEN)
    changementValeurDsMCF(jdc, "SIMU_POINT_MAT", "COMP_INCR", "DEFORMATION", dGREEN)
    changementValeurDsMCF(jdc, "STAT_NON_LINE", "COMP_INCR", "DEFORMATION", dGREEN)
    changementValeurDsMCF(jdc, "DYNA_NON_LINE", "COMP_INCR", "DEFORMATION", dGREEN)
    changementValeurDsMCF(jdc, "CALCUL", "COMP_INCR", "DEFORMATION", dGREEN)
    changementValeurDsMCF(jdc, "CALC_PRECONT", "COMP_INCR", "DEFORMATION", dGREEN)
    changementValeurDsMCF(jdc, "CALC_NO", "COMP_INCR", "DEFORMATION", dGREEN)
    changementValeurDsMCF(jdc, "LIRE_RESU", "COMP_INCR", "DEFORMATION", dGREEN)
    changementValeurDsMCF(jdc, "MACR_ECREVISSE", "COMP_INCR", "DEFORMATION", dGREEN)

    ###################### traitement COMP_INCR/COMP_ELAS RESO_INTE ##########
    dALGOI = {"RUNGE_KUTTA_2": "RUNGE_KUTTA", "RUNGE_KUTTA_4": "RUNGE_KUTTA"}
    removeMotCleInFactCourantSiRegle(
        jdc,
        "STAT_NON_LINE",
        "COMP_ELAS",
        "RESO_INTE",
        ((("RESO_INTE", "IMPLICITE", jdc), "MCsousMCFcourantaPourValeur"),),
    )
    removeMotCleInFactCourantSiRegle(
        jdc,
        "STAT_NON_LINE",
        "COMP_INCR",
        "RESO_INTE",
        ((("RESO_INTE", "IMPLICITE", jdc), "MCsousMCFcourantaPourValeur"),),
    )
    removeMotCleInFactCourantSiRegle(
        jdc,
        "DYNA_NON_LINE",
        "COMP_ELAS",
        "RESO_INTE",
        ((("RESO_INTE", "IMPLICITE", jdc), "MCsousMCFcourantaPourValeur"),),
    )
    removeMotCleInFactCourantSiRegle(
        jdc,
        "DYNA_NON_LINE",
        "COMP_INCR",
        "RESO_INTE",
        ((("RESO_INTE", "IMPLICITE", jdc), "MCsousMCFcourantaPourValeur"),),
    )
    removeMotCleInFactCourantSiRegle(
        jdc,
        "CALCUL",
        "COMP_ELAS",
        "RESO_INTE",
        ((("RESO_INTE", "IMPLICITE", jdc), "MCsousMCFcourantaPourValeur"),),
    )
    removeMotCleInFactCourantSiRegle(
        jdc,
        "CALCUL",
        "COMP_INCR",
        "RESO_INTE",
        ((("RESO_INTE", "IMPLICITE", jdc), "MCsousMCFcourantaPourValeur"),),
    )
    removeMotCleInFactCourantSiRegle(
        jdc,
        "MACR_ASCOUF_CALC",
        "COMP_ELAS",
        "RESO_INTE",
        ((("RESO_INTE", "IMPLICITE", jdc), "MCsousMCFcourantaPourValeur"),),
    )
    removeMotCleInFactCourantSiRegle(
        jdc,
        "MACR_ASCOUF_CALC",
        "COMP_INCR",
        "RESO_INTE",
        ((("RESO_INTE", "IMPLICITE", jdc), "MCsousMCFcourantaPourValeur"),),
    )
    removeMotCleInFactCourantSiRegle(
        jdc,
        "MACR_ASPIQ_CALC",
        "COMP_ELAS",
        "RESO_INTE",
        ((("RESO_INTE", "IMPLICITE", jdc), "MCsousMCFcourantaPourValeur"),),
    )
    removeMotCleInFactCourantSiRegle(
        jdc,
        "MACR_ASPIQ_CALC",
        "COMP_INCR",
        "RESO_INTE",
        ((("RESO_INTE", "IMPLICITE", jdc), "MCsousMCFcourantaPourValeur"),),
    )
    removeMotCleInFactCourantSiRegle(
        jdc,
        "SIMU_POINT_MAT",
        "COMP_INCR",
        "RESO_INTE",
        ((("RESO_INTE", "IMPLICITE", jdc), "MCsousMCFcourantaPourValeur"),),
    )
    removeMotCleInFactCourantSiRegle(
        jdc,
        "CALC_PRE_CONT",
        "COMP_INCR",
        "RESO_INTE",
        ((("RESO_INTE", "IMPLICITE", jdc), "MCsousMCFcourantaPourValeur"),),
    )
    removeMotCleInFactCourantSiRegle(
        jdc,
        "CALC_NO",
        "COMP_INCR",
        "RESO_INTE",
        ((("RESO_INTE", "IMPLICITE", jdc), "MCsousMCFcourantaPourValeur"),),
    )
    removeMotCleInFactCourantSiRegle(
        jdc,
        "LIRE_RESU",
        "COMP_INCR",
        "RESO_INTE",
        ((("RESO_INTE", "IMPLICITE", jdc), "MCsousMCFcourantaPourValeur"),),
    )
    removeMotCleInFactCourantSiRegle(
        jdc,
        "MACR_ECREVISSE",
        "COMP_INCR",
        "RESO_INTE",
        ((("RESO_INTE", "IMPLICITE", jdc), "MCsousMCFcourantaPourValeur"),),
    )

    changementValeurDsMCF(jdc, "STAT_NON_LINE", "COMP_ELAS", "RESO_INTE", dALGOI)
    changementValeurDsMCF(jdc, "STAT_NON_LINE", "COMP_INCR", "RESO_INTE", dALGOI)
    changementValeurDsMCF(jdc, "DYNA_NON_LINE", "COMP_ELAS", "RESO_INTE", dALGOI)
    changementValeurDsMCF(jdc, "DYNA_NON_LINE", "COMP_INCR", "RESO_INTE", dALGOI)
    changementValeurDsMCF(jdc, "CALCUL", "COMP_ELAS", "RESO_INTE", dALGOI)
    changementValeurDsMCF(jdc, "CALCUL", "COMP_INCR", "RESO_INTE", dALGOI)
    changementValeurDsMCF(jdc, "MACR_ASCOUF_CALC", "COMP_ELAS", "RESO_INTE", dALGOI)
    changementValeurDsMCF(jdc, "MACR_ASCOUF_CALC", "COMP_INCR", "RESO_INTE", dALGOI)
    changementValeurDsMCF(jdc, "MACR_ASPIQF_CALC", "COMP_ELAS", "RESO_INTE", dALGOI)
    changementValeurDsMCF(jdc, "MACR_ASPIQ_CALC", "COMP_INCR", "RESO_INTE", dALGOI)
    changementValeurDsMCF(jdc, "SIMU_POINT_MAT", "COMP_INCR", "RESO_INTE", dALGOI)
    changementValeurDsMCF(jdc, "CALC_PRECONT", "COMP_INCR", "RESO_INTE", dALGOI)
    changementValeurDsMCF(jdc, "CALC_NO", "COMP_INCR", "RESO_INTE", dALGOI)
    changementValeurDsMCF(jdc, "LIRE_RESU", "COMP_INCR", "RESO_INTE", dALGOI)
    changementValeurDsMCF(jdc, "MACR_ECREVISSE", "COMP_INCR", "RESO_INTE", dALGOI)

    renameMotCleInFact(jdc, "STAT_NON_LINE", "COMP_ELAS", "RESO_INTE", "ALGO_INTE")
    renameMotCleInFact(jdc, "STAT_NON_LINE", "COMP_INCR", "RESO_INTE", "ALGO_INTE")
    renameMotCleInFact(jdc, "DYNA_NON_LINE", "COMP_ELAS", "RESO_INTE", "ALGO_INTE")
    renameMotCleInFact(jdc, "DYNA_NON_LINE", "COMP_INCR", "RESO_INTE", "ALGO_INTE")
    renameMotCleInFact(jdc, "CALCUL", "COMP_ELAS", "RESO_INTE", "ALGO_INTE")
    renameMotCleInFact(jdc, "CALCUL", "COMP_INCR", "RESO_INTE", "ALGO_INTE")
    renameMotCleInFact(jdc, "MACR_ASCOUF_CALC", "COMP_ELAS", "RESO_INTE", "ALGO_INTE")
    renameMotCleInFact(jdc, "MACR_ASCOUF_CALC", "COMP_INCR", "RESO_INTE", "ALGO_INTE")
    renameMotCleInFact(jdc, "MACR_ASPIQF_CALC", "COMP_ELAS", "RESO_INTE", "ALGO_INTE")
    renameMotCleInFact(jdc, "MACR_ASPIQ_CALC", "COMP_INCR", "RESO_INTE", "ALGO_INTE")
    renameMotCleInFact(jdc, "SIMU_POINT_MAT", "COMP_INCR", "RESO_INTE", "ALGO_INTE")
    renameMotCleInFact(jdc, "CALC_PRECONT", "COMP_INCR", "RESO_INTE", "ALGO_INTE")
    renameMotCleInFact(jdc, "CALC_NO", "COMP_INCR", "RESO_INTE", "ALGO_INTE")
    renameMotCleInFact(jdc, "LIRE_RESU", "COMP_INCR", "RESO_INTE", "ALGO_INTE")
    renameMotCleInFact(jdc, "MACR_ECREVISSE", "COMP_INCR", "RESO_INTE", "ALGO_INTE")

    ###################### traitement COMP_ELAS/ITER_INTE_PAS ######
    removeMotCleInFact(jdc, "CALCUL", "COMP_ELAS", "ITER_INTE_PAS", pasDeRegle(), 0)
    removeMotCleInFact(
        jdc, "DYNA_NON_LINE", "COMP_ELAS", "ITER_INTE_PAS", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "STAT_NON_LINE", "COMP_ELAS", "ITER_INTE_PAS", pasDeRegle(), 0
    )

    ###################### traitement CALC_G/COMP_INCR/RELATION ELAS_VMIS_PUIS ####
    changementValeurDsMCF(
        jdc, "CALC_G", "COMP_INCR", "RELATION", {"ELAS_VMIS_PUIS": "VMIS_ISOT_PUIS"}
    )

    ########################" traitement DEFI_COMPOR/MULTIFIBRE/DEFORMATION=REAC_GEOM #########
    changementValeurDsMCF(jdc, "DEFI_COMPOR", "MULTIFIBRE", "DEFORMATION", dGREEN)

    ####################### traitement DEFI_COMPOR/MONOCRISTAL/ECOULEMENT #############
    dECOULEMENT = {
        "ECOU_VISC1": "MONO_VISC1",
        "ECOU_VISC2": "MONO_VISC2",
        "ECOU_VISC3": "MONO_VISC3",
        "KOCKS_RAUCH": "MONO_DD_KR",
    }
    changementValeurDsMCF(jdc, "DEFI_COMPOR", "MONOCRISTAL", "ECOULEMENT", dECOULEMENT)
    dISOT = {"ECRO_ISOT1": "MONO_ISOT1", "ECRO_ISOT2": "MONO_ISOT2"}
    dCINE = {"ECRO_CINE1": "MONO_CINE1", "ECRO_CINE2": "MONO_CINE2"}
    changementValeurDsMCF(jdc, "DEFI_COMPOR", "MONOCRISTAL", "ECRO_ISOT", dISOT)
    changementValeurDsMCF(jdc, "DEFI_COMPOR", "MONOCRISTAL", "ECRO_CINE", dCINE)

    ################### traitement DEFI_MATERIAU monocristallin #######
    renameMotCle(jdc, "DEFI_MATERIAU", "ECOU_VISC1", "MONO_VISC1")
    renameMotCle(jdc, "DEFI_MATERIAU", "ECOU_VISC2", "MONO_VISC2")
    renameMotCle(jdc, "DEFI_MATERIAU", "ECOU_VISC3", "MONO_VISC3")
    renameMotCle(jdc, "DEFI_MATERIAU", "ECRO_CINE1", "MONO_CINE1")
    renameMotCle(jdc, "DEFI_MATERIAU", "ECRO_CINE2", "MONO_CINE2")
    renameMotCle(jdc, "DEFI_MATERIAU", "ECRO_ISOT1", "MONO_ISOT1")
    renameMotCle(jdc, "DEFI_MATERIAU", "ECRO_ISOT2", "MONO_ISOT2")
    renameMotCle(jdc, "DEFI_MATERIAU", "KOCKS_RAUCH", "MONO_DD_KR")

    ################ traitement DEFI_MATERIAU/THER_HYDR #######
    removeMotCleInFact(jdc, "DEFI_MATERIAU", "THER_HYDR", "QSR_K")

    ##################### traitement AFFE_CARA_ELEM/DISCRET ###############"
    dDISCRET = {
        "K_T_N_NS": "K_T_N",
        "K_T_L_NS": "K_T_L",
        "K_TR_N_NS": "K_TR_N",
        "K_TR_L_NS": "K_TR_L",
        "M_T_N_NS": "M_T_N",
        "M_T_L_NS": "M_T_L",
        "M_TR_N_NS": "M_TR_N",
        "M_TR_L_NS": "M_TR_L",
        "A_T_N_NS": "A_T_N",
        "A_T_L_NS": "A_T_L",
        "A_TR_N_NS": "A_TR_N",
        "A_TR_L_NS": "A_TR_L",
    }
    dlist_DISCRET = [
        "K_T_N_NS",
        "K_T_L_NS",
        "K_TR_N_NS",
        "K_TR_L_NS",
        "M_T_N_NS",
        "M_T_L_NS",
        "M_TR_N_NS",
        "M_TR_L_NS",
        "A_T_N_NS",
        "A_T_L_NS",
        "A_TR_N_NS",
        "A_TR_L_NS",
    ]

    removeMotCleInFact(jdc, "AFFE_CARA_ELEM", "DISCRET_2D", "SYME")
    removeMotCleInFact(jdc, "AFFE_CARA_ELEM", "DISCRET", "SYME")
    ajouteMotClefDansFacteurCourantSiRegle(
        jdc,
        "AFFE_CARA_ELEM",
        "DISCRET",
        "SYME='NON'",
        ((("CARA", dlist_DISCRET, jdc), "MCsousMCFcourantaPourValeurDansListe"),),
    )
    ajouteMotClefDansFacteurCourantSiRegle(
        jdc,
        "AFFE_CARA_ELEM",
        "DISCRET_2D",
        "SYME='NON'",
        ((("CARA", dlist_DISCRET, jdc), "MCsousMCFcourantaPourValeurDansListe"),),
    )
    changementValeurDsMCF(jdc, "AFFE_CARA_ELEM", "DISCRET_2D", "CARA", dDISCRET)
    changementValeurDsMCF(jdc, "AFFE_CARA_ELEM", "DISCRET", "CARA", dDISCRET)

    #####CHARGEMENT

    ####################### traitement  CONTACT ###############################################

    renameMotCleInFact(
        jdc, "AFFE_CHAR_MECA", "CONTACT", "ITER_MULT_MAXI", "ITER_CONT_MULT"
    )
    renameMotCleInFact(jdc, "AFFE_CHAR_MECA", "CONTACT", "NB_REAC_GEOM", "NB_ITER_GEOM")
    ajouteMotClefDansFacteurCourantSiRegle(
        jdc,
        "AFFE_CHAR_MECA",
        "CONTACT",
        "RESOLUTION='NON'",
        ((("METHODE", "VERIF", jdc), "MCsousMCFcourantaPourValeur"),),
    )
    copyMotClefInOperToFact(jdc, "AFFE_CHAR_MECA", "MODELE", "CONTACT")
    moveMCFToCommand(jdc, "AFFE_CHAR_MECA", "CONTACT", "DEFI_CONTACT", "ZONE")
    removeMotCle(jdc, "AFFE_CHAR_MECA", "CONTACT", pasDeRegle(), 1)

    removeMotCleInFact(jdc, "AFFE_CHAR_MECA", "LIAISON_UNILATER", "METHODE")
    ajouteMotClefDansFacteur(
        jdc,
        "AFFE_CHAR_MECA",
        "LIAISON_UNILATER",
        "METHODE='LIAISON_UNIL'",
        pasDeRegle(),
    )
    copyMotClefInOperToFact(jdc, "AFFE_CHAR_MECA", "MODELE", "LIAISON_UNILATER")
    moveMCFToCommand(jdc, "AFFE_CHAR_MECA", "LIAISON_UNILATER", "DEFI_CONTACT", "ZONE")
    removeMotCle(jdc, "AFFE_CHAR_MECA", "LIAISON_UNILATER", pasDeRegle(), 1)

    removeMotCleInFact(jdc, "AFFE_CHAR_MECA_F", "LIAISON_UNILATER", "METHODE")
    ajouteMotClefDansFacteur(
        jdc,
        "AFFE_CHAR_MECA_F",
        "LIAISON_UNILATER",
        "METHODE='LIAISON_UNIL'",
        pasDeRegle(),
    )
    ajouteMotClefDansFacteur(
        jdc,
        "AFFE_CHAR_MECA_F",
        "LIAISON_UNILATER",
        "FORMULATION='LIAISON_UNIL'",
        pasDeRegle(),
    )
    copyMotClefInOperToFact(jdc, "AFFE_CHAR_MECA_F", "MODELE", "LIAISON_UNILATER")
    moveMCFToCommand(
        jdc, "AFFE_CHAR_MECA_F", "LIAISON_UNILATER", "DEFI_CONTACT", "ZONE"
    )
    removeMotCle(jdc, "AFFE_CHAR_MECA_F", "LIAISON_UNILATER", pasDeRegle(), 1)

    chercheOperInsereMotCleSiRegle(
        jdc,
        "DEFI_CONTACT",
        "FORMULATION='XFEM'",
        ((("ZONE", "METHODE", "XFEM", jdc), "MCsousMCFaPourValeur"),),
    )
    chercheOperInsereMotCleSiRegle(
        jdc,
        "DEFI_CONTACT",
        "FORMULATION='CONTINUE'",
        ((("ZONE", "METHODE", "CONTINUE", jdc), "MCsousMCFaPourValeur"),),
    )
    chercheOperInsereMotCleSiRegle(
        jdc,
        "DEFI_CONTACT",
        "FORMULATION='VERIF'",
        ((("ZONE", "METHODE", "VERIF", jdc), "MCsousMCFaPourValeur"),),
    )
    chercheOperInsereMotCleSiRegle(
        jdc,
        "DEFI_CONTACT",
        "FORMULATION='LIAISON_UNIL'",
        ((("ZONE", "METHODE", "LIAISON_UNIL", jdc), "MCsousMCFaPourValeur"),),
    )
    liste_meth_ZONE = ["GCP", "CONTRAINTE", "LAGRANGIEN", "PENALISATION"]
    chercheOperInsereMotCleSiRegle(
        jdc,
        "DEFI_CONTACT",
        "FORMULATION='DISCRETE'",
        ((("ZONE", "METHODE", liste_meth_ZONE, jdc), "MCsousMCFaPourValeurDansListe"),),
    )
    ajouteMotClefDansFacteurCourantSiRegle(
        jdc,
        "DEFI_CONTACT",
        "ZONE",
        "ALGO_CONT='LAGRANGIEN'",
        ((("METHODE", "LAGRANGIEN", jdc), "MCsousMCFcourantaPourValeur"),),
    )
    ajouteMotClefDansFacteurCourantSiRegle(
        jdc,
        "DEFI_CONTACT",
        "ZONE",
        "ALGO_FROT='LAGRANGIEN'",
        (
            (("METHODE", "LAGRANGIEN", jdc), "MCsousMCFcourantaPourValeur"),
            (("COULOMB",), "existeMCsousMCFcourant"),
        ),
    )
    ajouteMotClefDansFacteurCourantSiRegle(
        jdc,
        "DEFI_CONTACT",
        "ZONE",
        "ALGO_CONT='GCP'",
        ((("METHODE", "GCP", jdc), "MCsousMCFcourantaPourValeur"),),
    )
    ajouteMotClefDansFacteurCourantSiRegle(
        jdc,
        "DEFI_CONTACT",
        "ZONE",
        "ALGO_CONT='PENALISATION'",
        ((("METHODE", "PENALISATION", jdc), "MCsousMCFcourantaPourValeur"),),
    )
    ajouteMotClefDansFacteurCourantSiRegle(
        jdc,
        "DEFI_CONTACT",
        "ZONE",
        "ALGO_FROT='PENALISATION'",
        (
            (("METHODE", "PENALISATION", jdc), "MCsousMCFcourantaPourValeur"),
            (("COULOMB",), "existeMCsousMCFcourant"),
        ),
    )
    ajouteMotClefDansFacteurCourantSiRegle(
        jdc,
        "DEFI_CONTACT",
        "ZONE",
        "ALGO_CONT='CONTRAINTE'",
        ((("METHODE", "CONTRAINTE", jdc), "MCsousMCFcourantaPourValeur"),),
    )
    removeMotCleInFact(jdc, "DEFI_CONTACT", "ZONE", "METHODE")

    moveMotCleFromFactToFather(jdc, "DEFI_CONTACT", "ZONE", "COEF_RESI")
    moveMotCleFromFactToFather(jdc, "DEFI_CONTACT", "ZONE", "FROTTEMENT")
    moveMotCleFromFactToFather(jdc, "DEFI_CONTACT", "ZONE", "ITER_CONT_MAXI")
    moveMotCleFromFactToFather(jdc, "DEFI_CONTACT", "ZONE", "ITER_FROT_MAXI")
    moveMotCleFromFactToFather(jdc, "DEFI_CONTACT", "ZONE", "ITER_GCP_MAXI")
    moveMotCleFromFactToFather(jdc, "DEFI_CONTACT", "ZONE", "ITER_GEOM_MAXI")
    moveMotCleFromFactToFather(jdc, "DEFI_CONTACT", "ZONE", "LISSAGE")
    moveMotCleFromFactToFather(jdc, "DEFI_CONTACT", "ZONE", "NB_RESOL")
    moveMotCleFromFactToFather(jdc, "DEFI_CONTACT", "ZONE", "PRE_COND")
    moveMotCleFromFactToFather(jdc, "DEFI_CONTACT", "ZONE", "REAC_GEOM")
    moveMotCleFromFactToFather(jdc, "DEFI_CONTACT", "ZONE", "REAC_ITER")
    moveMotCleFromFactToFather(jdc, "DEFI_CONTACT", "ZONE", "RECH_LINEAIRE")
    moveMotCleFromFactToFather(jdc, "DEFI_CONTACT", "ZONE", "STOP_INTERP")
    moveMotCleFromFactToFather(jdc, "DEFI_CONTACT", "ZONE", "STOP_SINGULIER")
    moveMotCleFromFactToFather(jdc, "DEFI_CONTACT", "ZONE", "RESI_ABSO")
    moveMotCleFromFactToFather(jdc, "DEFI_CONTACT", "ZONE", "ITER_CONT_MULT")
    moveMotCleFromFactToFather(jdc, "DEFI_CONTACT", "ZONE", "ITER_PRE_MAXI")
    moveMotCleFromFactToFather(jdc, "DEFI_CONTACT", "ZONE", "NB_ITER_GEOM")
    moveMotCleFromFactToFather(jdc, "DEFI_CONTACT", "ZONE", "MODELE")

    # FORMULATION = DEPL/VITE
    # Si EXCL_FROT_1
    # Si EXCL_FROT_2

    ####################### traitement DCX/DCY/DCZ #############################
    dDC = {"DCX": "DX", "DCY": "DY", "DCZ": "DZ"}
    renameMotCleInFact(jdc, "AFFE_CHAR_MECA", "DDL_IMPO", "DCX", "DX")
    renameMotCleInFact(jdc, "AFFE_CHAR_MECA", "DDL_IMPO", "DCY", "DY")
    renameMotCleInFact(jdc, "AFFE_CHAR_MECA", "DDL_IMPO", "DCZ", "DZ")
    renameMotCleInFact(jdc, "AFFE_CHAR_MECA_F", "DDL_IMPO", "DCX", "DX")
    renameMotCleInFact(jdc, "AFFE_CHAR_MECA_F", "DDL_IMPO", "DCY", "DY")
    renameMotCleInFact(jdc, "AFFE_CHAR_MECA_F", "DDL_IMPO", "DCZ", "DZ")
    renameMotCleInFact(jdc, "AFFE_CHAR_CINE", "MECA_IMPO", "DCX", "DX")
    renameMotCleInFact(jdc, "AFFE_CHAR_CINE", "MECA_IMPO", "DCY", "DY")
    renameMotCleInFact(jdc, "AFFE_CHAR_CINE", "MECA_IMPO", "DCZ", "DZ")
    # QUESTION Non pris en compte : AFFE_CHAR_MECA/LIAISON_DDL","DDL",Liste de valeurs avec DC*)
    # peut_etre avec changeTouteValeur ?

    ######################### traitement COMB_SISM_MODAL APPUI #######################""
    # attention il faut traiter d'abord DECORRELE avant CORRELE sinon CORRELE apparait dans DECORELLE
    moveMotCleFromFactToFather(jdc, "COMB_SISM_MODAL", "EXCIT", "MONO_APPUI")
    moveMotCleFromFactToFather(jdc, "COMB_SISM_MODAL", "EXCIT", "MULTI_APPUI")
    removeMotCleInFactSiRegle(
        jdc,
        "COMB_SISM_MODAL",
        "COMB_MULT_APPUI",
        "TYPE_COMBI",
        ((("MULTI_APPUI", "DECORRELE", jdc), "MCaPourValeur"),),
    )
    renameMotCleSiRegle(
        jdc,
        "COMB_SISM_MODAL",
        "COMB_MULT_APPUI",
        "GROUP_APPUI",
        ((("MULTI_APPUI", "DECORRELE", jdc), "MCaPourValeur"),),
        1,
    )

    ########################  traitement DYNA_TRAN_MODAL ##################
    ajouteMotClefDansFacteurCourantSiRegle(
        jdc,
        "DYNA_TRAN_MODAL",
        "CHOC",
        "FROTTEMENT='COULOMB'",
        ((("COULOMB",), "existeMCsousMCFcourant"),),
    )

    ######################### traitement AFFE_CHAR_MECA PESANTEUR ROTATION#################
    eclaMotCleToFact(jdc, "AFFE_CHAR_MECA", "PESANTEUR", "GRAVITE", "DIRECTION")
    eclaMotCleToFact(jdc, "AFFE_CHAR_MECA", "ROTATION", "VITESSE", "AXE")
    moveMotClefInOperToFact(jdc, "AFFE_CHAR_MECA", "CENTRE", "ROTATION")

    ######################## traitement DEFI_BASE_MODALE ##############
    renameMotCleInFact(jdc, "DEFI_BASE_MODALE", "RITZ", "MODE_STAT", "MODE_INTF")
    renameMotCleInFact(jdc, "DEFI_BASE_MODALE", "RITZ", "MULT_ELAS", "MODE_INTF")

    ####################### traitement DYNA_ISS_VARI #################
    renameMotCle(jdc, "DYNA_ISS_VARI", "PAS", "FREQ_PAS")

    #####IMPRESSION

    #################### traitement IMPR_RESU  #######################
    removeMotCleInFact(jdc, "IMPR_RESU", "RESU", "INFO_RESU")

    ######################### traitement IMPR_MATRICE ####################
    removeCommande(jdc, "IMPR_MATRICE")

    #######################  traitement PROJ_CHAMP  #####################
    renameMotCle(jdc, "PROJ_CHAMP", "CHAM_NO", "CHAM_GD", 1, pasDeRegle())
    changementValeur(jdc, "PROJ_CHAMP", "METHODE", {"ELEM": "COLLOCATION"})

    ####################### traitement MACR_ADAP_MAIL ##############"
    changementValeur(
        jdc,
        "MACR_ADAP_MAIL",
        "TYPE_VALEUR_INDICA",
        {"V_ABSOLUE": "ABSOLU", "V_RELATIVE": "RELATIF"},
    )
    renameMotCle(jdc, "MACR_ADAP_MAIL", "INDICATEUR", "NOM_CHAM")
    renameMotCle(jdc, "MACR_ADAP_MAIL", "NOM_CMP_INDICA", "NOM_CMP")
    renameMotCle(jdc, "MACR_ADAP_MAIL", "TYPE_OPER_INDICA", "USAGE_CHAMP")
    renameMotCle(jdc, "MACR_ADAP_MAIL", "TYPE_VALEUR_INDICA", "USAGE_CMP")
    ajouteMotClefDansFacteurCourantSiRegle(
        jdc,
        "MACR_ADAP_MAIL",
        "ZONE",
        "TYPE='BOITE'",
        ((("RAYON",), "nexistepasMCsousMCFcourant"),),
    )
    ajouteMotClefDansFacteurCourantSiRegle(
        jdc,
        "MACR_ADAP_MAIL",
        "ZONE",
        "TYPE='SPHERE'",
        ((("RAYON",), "existeMCsousMCFcourant"),),
    )
    changementValeur(jdc, "MACR_ADAP_MAIL", "VERSION_HOMARD", {"V9_5": "V10_1"})
    changementValeur(jdc, "MACR_ADAP_MAIL", "VERSION_HOMARD", {"V9_N": "V10_1_N"})
    changementValeur(jdc, "MACR_INFO_MAIL", "VERSION_HOMARD", {"V9_5": "V10_1"})
    changementValeur(jdc, "MACR_INFO_MAIL", "VERSION_HOMARD", {"V9_N": "V10_1_N"})

    ###################### traitement de POST_CHAM_XFEM  #################
    removeMotCle(jdc, "POST_CHAM_XFEM", "MODELE", pasDeRegle(), 0)
    removeMotCle(jdc, "POST_CHAM_XFEM", "MAILLAGE_FISS", pasDeRegle(), 0)
    removeMotCle(jdc, "POST_CHAM_XFEM", "NOM_CHAM", pasDeRegle(), 0)

    ##################### traitement de SIMU_POINT_MAT/SUPPORT #############
    chercheOperInsereFacteur(jdc, "SIMU_POINT_MAT", "SUPPORT='POINT'", pasDeRegle(), 0)

    ######################  traitement AFFE_CARA_ELEM/UNITE_EUROPLEXUS ######
    renameMotCleInFact(
        jdc,
        "AFFE_CARA_ELEM",
        "RIGI_PARASOL",
        "UNITE_EUROPLEXUS",
        "UNITE",
        pasDeRegle(),
        0,
    )

    #################### traitement DEFI_GLRC/IMPRESSION #############
    removeMotCle(jdc, "DEFI_GLRC", "IMPRESSION", pasDeRegle(), 0)

    ################### traitement AFFICHAGE  #####
    removeMotCleInFact(jdc, "DYNA_NON_LINE", "AFFICHAGE", "LONG_I", pasDeRegle(), 0)
    removeMotCleInFact(jdc, "DYNA_NON_LINE", "AFFICHAGE", "LONG_R", pasDeRegle(), 0)
    removeMotCleInFact(
        jdc, "DYNA_NON_LINE", "AFFICHAGE", "NOM_COLONNE", pasDeRegle(), 0
    )
    removeMotCleInFact(jdc, "DYNA_NON_LINE", "AFFICHAGE", "PREC_R", pasDeRegle(), 0)
    removeMotCleInFact(jdc, "STAT_NON_LINE", "AFFICHAGE", "LONG_I", pasDeRegle(), 0)
    removeMotCleInFact(jdc, "STAT_NON_LINE", "AFFICHAGE", "LONG_R", pasDeRegle(), 0)
    removeMotCleInFact(
        jdc, "STAT_NON_LINE", "AFFICHAGE", "NOM_COLONNE", pasDeRegle(), 0
    )
    removeMotCleInFact(jdc, "STAT_NON_LINE", "AFFICHAGE", "PREC_R", pasDeRegle(), 0)

    ################### traitement CALC_NO *RESU #########
    removeMotCle(jdc, "CALC_NO", "GROUP_MA_RESU", pasDeRegle(), 0)
    removeMotCle(jdc, "CALC_NO", "MAILLE_RESU", pasDeRegle(), 0)
    removeMotCle(jdc, "CALC_NO", "GROUP_NO_RESU", pasDeRegle(), 0)
    removeMotCle(jdc, "CALC_NO", "NOEUD_RESU", pasDeRegle(), 0)

    ################## traitement POST_K1_K2_K3/MAILLAGE ######
    removeMotCleSiRegle(
        jdc, "POST_K1_K2_K3", "MAILLAGE", ((("RESULTAT"), "existeMCFParmi"),)
    )

    ######### traitement CALC_ELEM/TYPE_ESTI ####
    dESTI = {
        "ERRE_ELEM_SIGM": "ERME_ELEM",
        "ERZ1_ELEM_SIGM": "ERZ1_ELEM",
        "ERZ2_ELEM_SIGM": "ERZ2_ELEM",
        "QIRE_ELEM_SIGM": "QIRE_ELEM",
        "QIZ1_ELEM_SIGM": "QIZ1_ELEM",
        "QIZ2_ELEM_SIGM": "QIZ2_ELEM",
    }
    changementValeur(jdc, "CALC_ELEM", "TYPE_ESTI", dESTI)

    ######### suppression CALC_ELEM/NORME ######
    removeMotCle(jdc, "CALC_ELEM", "NORME", pasDeRegle(), 0)

    ########## traitement CALC_ELEM/CALC_NO OPTION
    # dSENSI={"DEDE_ELNO_DLDE":"DEDE_ELNO","DEDE_NOEU_DLDE":"DEDE_NOEU","DESI_ELNO_DLSI":"DESI_ELNO","DESI_NOEU_DLSI":"DESI_NOEU",
    #        "DETE_ELNO_DLTE":"DETE_ELNO","DETE_NOEU_DLTE":"DETE_NOEU"}
    dOPTION = {
        "DEDE_ELNO_DLDE": "DEDE_ELNO",
        "DEDE_NOEU_DLDE": "DEDE_NOEU",
        "DESI_ELNO_DLSI": "DESI_ELNO",
        "DESI_NOEU_DLSI": "DESI_NOEU",
        "DETE_ELNO_DLTE": "DETE_ELNO",
        "DETE_NOEU_DLTE": "DETE_NOEU",
        "INTE_ELNO_ACTI": "INTE_ELNO",
        "INTE_ELNO_REAC": "INTE_ELNO",
        "INTE_NOEU_ACTI": "INTE_NOEU",
        "INTE_NOEU_REAC": "INTE_NOEU",
        "PRES_DBEL_DEPL": "PRME_ELNO",
        "PRES_ELNO_IMAG": "PRAC_ELNO",
        "PRES_ELNO_REEL": "PRAC_ELNO",
        "PRES_NOEU_DBEL": "PRAC_NOEU",
        "PRES_NOEU_IMAG": "PRAC_NOEU",
        "PRES_NOEU_REEL": "PRAC_NOEU",
        "ARCO_ELNO_SIGM": "SIRO_ELEM",
        "ARCO_NOEU_SIGM": "SIRO_ELEM",
        "ENDO_ELNO_ELGA": "ENDO_ELNO",
        "ENDO_ELNO_SIGA": "ENDO_ELNO",
        "ENDO_ELNO_SINO": "ENDO_ELNO",
        "ENDO_NOEU_SINO": "ENDO_NOEU",
        "ERRE_ELEM_SIGM": "ERME_ELEM",
        "ERRE_ELEM_TEMP": "ERTH_ELEM",
        "CRIT_ELNO_RUPT": "CRIT_ELNO",
        "DEGE_ELNO_DEPL": "DEGE_ELNO",
        "DEGE_NOEU_DEPL": "DEGE_NOEU",
        "DURT_ELNO_META": "DURT_ELNO",
        "DURT_NOEU_META": "DURT_NOEU",
        "ECIN_ELEM_DEPL": "ECIN_ELEM",
        "ENEL_ELNO_ELGA": "ENEL_ELNO",
        "ENEL_NOEU_ELGA": "ENEL_NOEU",
        "EPEQ_ELNO_TUYO": "EPTQ_ELNO",
        "EPME_ELGA_DEPL": "EPME_ELGA",
        "EPME_ELNO_DEPL": "EPME_ELNO",
        "EPMG_ELGA_DEPL": "EPMG_ELGA",
        "EPMG_ELNO_DEPL": "EPMG_ELNO",
        "EPMG_NOEU_DEPL": "EPMG_NOEU",
        "EPOT_ELEM_DEPL": "EPOT_ELEM",
        "EPSG_ELGA_DEPL": "EPSG_ELGA",
        "EPSG_ELNO_DEPL": "EPSG_ELNO",
        "EPSG_NOEU_DEPL": "EPSG_NOEU",
        "EPSI_ELGA_DEPL": "EPSI_ELGA",
        "EPSI_NOEU_DEPL": "EPSI_NOEU",
        "EPSI_ELNO_DEPL": "EPSI_ELNO",
        "EPSI_ELNO_TUYO": "EPTU_ELNO",
        "ERZ1_ELEM_SIGM": "ERZ1_ELEM",
        "ERZ2_ELEM_SIGM": "ERZ2_ELEM",
        "ETOT_ELNO_ELGA": "ETOT_ELNO",
        "EXTR_ELGA_VARI": "VAEX_ELGA",
        "EXTR_ELNO_VARI": "VAEX_ELNO",
        "EXTR_NOEU_VARI": "VAEX_NOEU",
        "FLUX_ELGA_TEMP": "FLUX_ELGA",
        "FLUX_ELNO_TEMP": "FLUX_ELNO",
        "FLUX_NOEU_TEMP": "FLUX_NOEU",
        "HYDR_NOEU_ELGA": "HYDR_NOEU",
        "HYDR_ELNO_ELGA": "HYDR_ELNO",
        "META_ELNO_TEMP": "META_ELNO",
        "META_NOEU_TEMP": "META_NOEU",
        "PMPB_ELGA_SIEF": "PMPB_ELGA",
        "PMPB_ELNO_SIEF": "PMPB_ELNO",
        "PMPB_NOEU_SIEF": "PMPB_NOEU",
        "QIRE_ELEM_SIGM": "QIRE_ELEM",
        "QIRE_ELNO_ELEM": "QIRE_ELNO",
        "QIRE_NOEU_ELEM": "QIRE_NOEU",
        "QIZ1_ELEM_SIGM": "QIZ1_ELEM",
        "QIZ2_ELEM_SIGM": "QIZ2_ELEM",
        "SIEF_ELGA_DEPL": "SIEF_ELGA",
        "SIEF_ELNO_ELGA": "SIEF_ELNO",
        "SIEF_NOEU_ELGA": "SIEF_NOEU",
        "SIEQ_ELNO_TUYO": "SITQ_ELNO",
        "SING_ELNO_ELEM": "SING_ELNO",
        "SIPO_ELNO_DEPL": "SIPO_ELNO",
        "SIPO_NOEU_DEPL": "SIPO_NOEU",
        "SOUR_ELGA_ELEC": "SOUR_ELGA",
        "DCHA_ELGA_SIGM": "DERA_ELGA",
        "DCHA_ELNO_SIGM": "DERA_ELNO",
        "DCHA_NOEU_SIGM": "DERA_NOEU",
        "RADI_ELGA_SIGM": "DERA_ELGA",
        "RADI_ELNO_SIGM": "DERA_ELNO",
        "RADI_NOEU_SIGM": "DERA_NOEU",
        "EFGE_ELNO_CART": "EFCA_ELNO",
        "EFGE_NOEU_CART": "EFCA_NOEU",
        "EFGE_ELNO_DEPL": "EFGE_ELNO",
        "EFGE_NOEU_DEPL": "EFGE_NOEU",
        "EQUI_ELGA_EPME": "EPMQ_ELGA",
        "EQUI_ELNO_EPME": "EPMQ_ELNO",
        "EQUI_NOEU_EPME": "EPMQ_NOEU",
        "EQUI_ELGA_EPSI": "EPEQ_ELGA",
        "EQUI_ELNO_EPSI": "EPEQ_ELNO",
        "EQUI_NOEU_EPSI": "EPEQ_NOEU",
        "EQUI_ELGA_SIGM": "SIEQ_ELGA",
        "EQUI_ELNO_SIGM": "SIEQ_ELNO",
        "EQUI_NOEU_SIGM": "SIEQ_NOEU",
        "SIGM_ELNO_CART": "SICA_ELNO",
        "SIGM_NOEU_CART": "SICA_NOEU",
        "SIGM_ELNO_COQU": "SICO_ELNO",
        "SIGM_NOEU_COQU": "SICO_ELNO",
        "SIGM_ELNO_TUYO": "SITU_ELNO",
        "SIGM_ELNO_DEPL": "SIGM_ELNO",
        "SIGM_NOEU_DEPL": "SIGM_NOEU",
        "SIGM_NOZ1_ELGA": "SIZ1_ELGA",
        "SIGM_NOZ2_ELGA": "SIZ2_ELGA",
        "VALE_NCOU_MAXI": "SPMX_ELGA",
        "VARI_ELNO_COQU": "VACO_ELNO",
        "VARI_ELNO_TUYO": "VATU_ELNO",
        "VARI_NOEU_ELGA": "VARI_NOEU",
        "VARI_ELNO_ELGA": "VARI_ELNO",
        "INDI_LOCA_ELGA": "INDL_ELGA",
    }
    # "FORC_NODA":"FORC_NOEU","REAC_NODA":"REAC_NOEU"
    changementValeurDsMCF(jdc, "AFFE_MATERIAU", "AFFE_VARC", "NOM_CHAM", dOPTION)
    changementValeur(jdc, "COMB_FOURIER", "NOM_CHAM", dOPTION)
    changementValeur(jdc, "CREA_CHAMP", "NOM_CHAM", dOPTION)
    changementValeur(jdc, "CREA_RESU", "NOM_CHAM", dOPTION)
    changementValeurDsMCF(jdc, "EXTR_RESU", "ARCHIVAGE", "NOM_CHAM", dOPTION)
    changementValeurDsMCF(jdc, "IMPR_RESU", "RESU", "NOM_CHAM", dOPTION)
    changementValeurDsMCF(jdc, "LIRE_RESU", "FORMAT_MED", "NOM_CHAM", dOPTION)
    changementValeurDsMCF(jdc, "LIRE_RESU", "FORMAT_IDEAS", "NOM_CHAM", dOPTION)
    changementValeur(jdc, "LIRE_RESU", "NOM_CHAM", dOPTION)
    changementValeur(jdc, "MACR_ADAP_MAIL", "NOM_CHAM", dOPTION)
    changementValeurDsMCF(jdc, "MACR_ASPIC_CALC", "IMPRESSION", "NOM_CHAM", dOPTION)
    changementValeur(jdc, "MACR_LIGP_COUPE", "NOM_CHAM", dOPTION)
    changementValeurDsMCF(jdc, "MODI_REPERE", "MODI_CHAM", "NOM_CHAM", dOPTION)
    changementValeurDsMCF(jdc, "POST_ELEM", "INTEGRALE", "NOM_CHAM", dOPTION)
    changementValeurDsMCF(jdc, "POST_ELEM", "MINMAX", "NOM_CHAM", dOPTION)
    changementValeurDsMCF(jdc, "POST_RCCM", "RESU_MECA", "NOM_CHAM", dOPTION)
    changementValeurDsMCF(jdc, "POST_RELEVE_T", "ACTION", "NOM_CHAM", dOPTION)
    changementValeur(jdc, "PROJ_CHAMP", "NOM_CHAM", dOPTION)
    changementValeurDsMCF(jdc, "PROJ_MESU_MODAL", "MODELE_MESURE", "NOM_CHAM", dOPTION)
    changementValeur(jdc, "RECU_FONCTION", "NOM_CHAM", dOPTION)
    changementValeur(jdc, "REST_GENE_PHYS", "NOM_CHAM", dOPTION)
    changementValeur(jdc, "REST_SOUS_STRUC", "NOM_CHAM", dOPTION)
    changementValeur(jdc, "REST_SPEC_PHYS", "NOM_CHAM", dOPTION)
    changementValeurDsMCF(jdc, "TEST_RESU", "RESU", "NOM_CHAM", dOPTION)
    changementValeurDsMCF(jdc, "TEST_RESU", "GENE", "NOM_CHAM", dOPTION)

    changementValeur(jdc, "CALC_CHAM_ELEM", "OPTION", dOPTION)
    changementValeur(jdc, "CALC_ELEM", "OPTION", dOPTION)
    changementValeur(jdc, "CALC_META", "OPTION", dOPTION)
    changementValeur(jdc, "CALC_NO", "OPTION", dOPTION)
    changementValeur(jdc, "COMB_SISM_MODAL", "OPTION", dOPTION)
    changementValeur(jdc, "MECA_STATIQUE", "OPTION", dOPTION)
    changementValeurDsMCF(jdc, "MACRO_ELAS_MULT", "CAS_CHARGE", "OPTION", dOPTION)
    changementValeur(jdc, "THER_NON_LINE", "OPTION", dOPTION)

    ############ Message si suppressionValeurs ou Valeurs ambigue CALC_ELEM/OPTION
    rOPTION = (
        "'DEUL_ELGA_DEPL'",
        "'DEUL_ELGA_TEMP'",
        "'DURT_ELGA_META'",
        "'ERRE_ELNO_DEPL'",
        "'ERRE_NOEU_ELEM'",
        "'ERRE_ELNO_ELEM'",
        "'EPSP_NOEU_ZAC'",
        "'HYDR_ELNO_ELGA'",
        "'SIGM_NOEU_ZAC'",
        "'SIGM_ELNO_SIEF'",
        "'SIGM_NOEU_SIEF'",
        "'SIPO_ELNO_SIEF'",
        "'SIPO_NOEU_SIEF'",
        "'SIRE_ELNO_DEPL'",
        "'SIRE_NOEU_DEPL'",
        "'SIEF_NOEU'",
        "'PRES_ELNO_DBEL'",
        "'VARI_NOEU'",
    )
    # Options ambigue :  PRES_ELNO_DBEL --> prac_elno/prme_elno, ERRE* --> ERME_ELNO ou ERTH_ELNO selon PHENOMENE
    # En commentaires les commandes non concernees par rOPTION

    genereErreurValeurDsMCF(jdc, "AFFE_MATERIAU", "AFFE_VARC", "NOM_CHAM", rOPTION)
    # genereErreurValeur(jdc,"COMB_FOURIER","NOM_CHAM",rOPTION)
    genereErreurValeur(jdc, "CREA_CHAMP", "NOM_CHAM", rOPTION)
    genereErreurValeur(jdc, "CREA_RESU", "NOM_CHAM", rOPTION)
    genereErreurValeurDsMCF(jdc, "EXTR_RESU", "ARCHIVAGE", "NOM_CHAM", rOPTION)
    genereErreurValeurDsMCF(jdc, "IMPR_RESU", "RESU", "NOM_CHAM", rOPTION)
    genereErreurValeurDsMCF(jdc, "LIRE_RESU", "FORMAT_MED", "NOM_CHAM", rOPTION)
    genereErreurValeurDsMCF(jdc, "LIRE_RESU", "FORMAT_IDEAS", "NOM_CHAM", rOPTION)
    genereErreurValeur(jdc, "LIRE_RESU", "NOM_CHAM", rOPTION)
    genereErreurValeur(jdc, "MACR_ADAP_MAIL", "NOM_CHAM", rOPTION)
    # genereErreurDsMCF(jdc,"MACR_ASPIC_CALC","IMPRESSION","NOM_CHAM",rOPTION)
    genereErreurValeur(jdc, "MACR_LIGP_COUPE", "NOM_CHAM", rOPTION)
    genereErreurValeurDsMCF(jdc, "MODI_REPERE", "MODI_CHAM", "NOM_CHAM", rOPTION)
    # genereErreurValeurDsMCF(jdc,"POST_RCCM","RESU_MECA","NOM_CHAM",rOPTION)
    genereErreurValeurDsMCF(jdc, "POST_ELEM", "INTEGRALE", "NOM_CHAM", rOPTION)
    genereErreurValeurDsMCF(jdc, "POST_ELEM", "MINMAX", "NOM_CHAM", rOPTION)
    genereErreurValeurDsMCF(jdc, "POST_RELEVE_T", "ACTION", "NOM_CHAM", rOPTION)
    genereErreurValeur(jdc, "PROJ_CHAMP", "NOM_CHAM", rOPTION)
    # genereErreurValeurDsMCF(jdc,"PROJ_MESU_MODAL","MODELE_MESURE","NOM_CHAM",rOPTION)
    genereErreurValeur(jdc, "RECU_FONCTION", "NOM_CHAM", rOPTION)
    # genereErreurValeur(jdc,"REST_GENE_PHYS","NOM_CHAM",rOPTION)
    # genereErreurValeur(jdc,"REST_SOUS_STRUC","NOM_CHAM",rOPTION)
    # genereErreurValeur(jdc,"REST_SPEC_PHYS","NOM_CHAM",rOPTION)
    genereErreurValeurDsMCF(jdc, "TEST_RESU", "RESU", "NOM_CHAM", rOPTION)
    genereErreurValeurDsMCF(jdc, "TEST_RESU", "GENE", "NOM_CHAM", rOPTION)

    genereErreurValeur(jdc, "CALC_CHAM_ELEM", "OPTION", rOPTION)
    genereErreurValeur(jdc, "CALC_ELEM", "OPTION", rOPTION)
    # genereErreurValeur(jdc,"CALC_META","OPTION",rOPTION)
    genereErreurValeur(jdc, "CALC_NO", "OPTION", rOPTION)
    # genereErreurValeur(jdc,"COMB_SISM_MODAL","OPTION",rOPTION)
    # genereErreurValeur(jdc,"MECA_STATIQUE","OPTION",rOPTION)
    genereErreurValeurDsMCF(jdc, "MACRO_ELAS_MULT", "CAS_CHARGE", "OPTION", rOPTION)
    # genereErreurValeur(jdc,"THER_NON_LINE","OPTION",rOPTION)

    ########### Message si CALC_ELEM/SENSIBILITE
    genereErreurMCF(jdc, "CALC_ELEM", "SENSIBILITE")

    # non fait CALC_NO OPTION=FORC_NODA_NONL

    ########## traitement MACRO_MISS_3D --> CALC_MISS
    renameCommandeSiRegle(
        jdc,
        "MACRO_MISS_3D",
        "CALC_MISS",
        (
            (("OPTION", "MODULE", "MISS_IMPE", jdc), "MCsousMCFaPourValeur"),
            (("PARAMETRE", "ISSF"), "nexistepasMCsousMCF"),
            (("PARAMETRE", "DIRE_ONDE"), "nexistepasMCsousMCF"),
            (("PARAMETRE", "CONTR_LISTE"), "nexistepasMCsousMCF"),
            (("PARAMETRE", "CONTR_NB"), "nexistepasMCsousMCF"),
        ),
    )
    renameCommandeSiRegle(
        jdc,
        "MACRO_MISS_3D",
        "CALC_MISS",
        (
            (("OPTION", "MODULE", "MISS_IMPE", jdc), "MCsousMCFaPourValeur"),
            (("PARAMETRE", "ISSF", "NON", jdc), "MCsousMCFaPourValeur"),
            (("PARAMETRE", "DIRE_ONDE"), "nexistepasMCsousMCF"),
            (("PARAMETRE", "CONTR_LISTE"), "nexistepasMCsousMCF"),
            (("PARAMETRE", "CONTR_NB"), "nexistepasMCsousMCF"),
        ),
    )
    removeMotCleInFact(jdc, "CALC_MISS", "PARAMETRE", "FICH_RESU_IMPE", pasDeRegle(), 0)
    removeMotCleInFact(jdc, "CALC_MISS", "PARAMETRE", "FICH_RESU_FORC", pasDeRegle(), 0)
    removeMotCleInFact(jdc, "CALC_MISS", "PARAMETRE", "FICH_POST_TRAI", pasDeRegle(), 0)
    removeMotCle(jdc, "CALC_MISS", "UNITE_OPTI_MISS", pasDeRegle())
    removeMotCle(jdc, "CALC_MISS", "UNITE_MODELE_SOL", pasDeRegle())
    removeMotCle(jdc, "CALC_MISS", "OPTION", pasDeRegle(), 1)
    changementValeur(jdc, "CALC_MISS", "VERSION", {"V1_4": "V6.5"})
    changementValeur(jdc, "CALC_MISS", "VERSION", {"V1_5": "V6.6"})
    changementValeur(jdc, "CALC_MISS", "VERSION", {"V1_3": "V6.5"})

    macr = ""
    interf = ""
    amor = ""
    for c in jdc.root.childNodes:
        if c.name != "IMPR_MACR_ELEM":
            continue
        for mc in c.childNodes:
            if mc.name == "MACR_ELEM_DYNA":
                macr = mc.getText(jdc)
            if mc.name == "GROUP_MA_INTERF":
                interf = mc.getText(jdc)
            if mc.name == "AMOR_REDUIT":
                amor = mc.getText(jdc)
    if amor != "":
        chercheOperInsereFacteur(jdc, "CALC_MISS", amor, pasDeRegle(), 0)
    if interf != "":
        chercheOperInsereFacteur(jdc, "CALC_MISS", interf, pasDeRegle(), 0)
    if macr != "":
        chercheOperInsereFacteur(jdc, "CALC_MISS", macr, pasDeRegle(), 0)

    chercheOperInsereFacteur(jdc, "CALC_MISS", "TABLE_SOL=''", pasDeRegle(), 0)
    chercheOperInsereFacteur(jdc, "CALC_MISS", "TYPE_RESU='FICHIER'", pasDeRegle(), 0)

    #################################################################
    f = open(outfile, "w")
    f.write(jdc.getSource())
    f.close()

    log.ferme(hdlr)


def main():
    parser = argparse.ArgumentParser(usage=usage)

    parser.add_argument(
        "-i",
        "--infile",
        dest="infile",
        default="toto.comm",
        help="Le fichier COMM en entree, a traduire",
    )
    parser.add_argument(
        "-o",
        "--outfile",
        dest="outfile",
        default="tutu.comm",
        help="Le fichier COMM en sortie, traduit",
    )

    args = parser.parse_args()
    traduc(args.infile, args.outfile)


if __name__ == "__main__":
    main()
