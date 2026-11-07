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
  python traduitV11V12.py --infile=xxxx --outfile=yyyy
"""

import log
import optparse
import sys

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
    "AFFE_CHAR_MECA",
    "AFFE_CHAR_MECA_C",
    "AFFE_CHAR_MECA_F",
    "AFFE_CHAR_THER",
    "AFFE_MODELE",
    "ASSEMBLAGE",
    "CALC_ESSAI_GEOMECA",
    "CALC_EUROPLEXUS",
    "CALC_FATIGUE",
    "CALC_FERRAILLAGE",
    "CALC_FONCTION",
    "CALC_FORC_NONL",
    "CALC_G",
    "CALC_IFS_DNL",
    "CALC_MAC3COEUR",
    "CALC_MATR_ELEM",
    "CALC_META",
    "CALC_MISS",
    "CALC_MODAL",
    "CALC_PRECONT",
    "CALCUL",
    "CALC_VECT_ELEM",
    "CREA_MAILLAGE",
    "DEBUT",
    "DEFI_COMPOR",
    "DEFI_FISS_XFEM",
    "DEFI_LIST_INST",
    "DEFI_MATER_GC",
    "DEFI_MATERIAU",
    "DEFI_OBSTACLE",
    "DEFI_PART_PA_OPS",
    "DYNA_NON_LINE",
    "DYNA_TRAN_MODAL",
    "DYNA_VIBRA",
    "EXTR_TABLE",
    "FACTORISER",
    "GENE_ACCE_SEISME",
    "IMPR_MISS_3D",
    "IMPR_RESU",
    "INFO_FONCTION",
    "LIRE_MAILLAGE",
    "LIRE_MISS_3D",
    "LIRE_RESU",
    "MACR_ASCOUF_CALC",
    "MACR_ASCOUF_MAIL",
    "MACR_ASPIC_CALC",
    "MACR_ECREVISSE",
    "MACR_INFO_MAIL",
    "MACRO_BASCULE_SCHEMA",
    "MACRO_MISS_3D",
    "MACRO_MODE_MECA",
    "MECA_STATIQUE",
    "MODE_ITER_INV",
    "MODE_ITER_SIMULT",
    "MODI_MAILLAGE",
    "MODI_MODELE_XFEM",
    "POST_DYNA_ALEA",
    "POST_ELEM",
    "POST_FATIGUE",
    "POURSUITE",
    "RECU_FONCTION",
    "STAT_NON_LINE",
    "SIMU_POINT_MAT",
    "TEST_COMPOR",
    "THER_NON_LINE",
    "DEFI_PART_FETI",
)

dict_erreurs = {
    "AFFE_CHAR_MECA_F_ONDE_PLANE_DIRECTION": "Trois valeurs sont nécessaire pour définir la DIRECTION",
    "CREA_MAILLAGE_ECLA_PG": "Le mot-clé NOM_CHAM est obligatoire",
    "CALC_EUROPLEXUS_FONC_PARASOL": "Le mot-clé GROUP_MA est obligatoire dans le mot-clé facteur FONC_PARASOL "
    + "pour l'opérateur CALC_EUROPLEXUS",
    "CALC_FERRAILLAGE": "Certains mots clés de CALC_FERRAILLAGE / AFFE sont obligatoires. "
    + "Pour TYPE_COMB='ELU' : PIVA et PIVB et ES, ES doit être supérieur à 0. "
    + "Pour TYPE_COMB='ELS' : CEQUI.",
    "CALC_FONCTION_DSP_FREQ": "Le mot-clé FREQ n'est plus disponible remplacer par LIST_FREQ. La liste de réel \
                                            doit être obtenu avec DEFI_LIST_REEL",
    "CALC_MODAL": "La commande CALC_MODAL a été supprimé et remplacer par CALC_MODES",
    "CREA_MAILLAGE_DETR_GROUP_MA": "Le mot-clé DETR_GROUP_MA n'est plus disponible dans CREA_MAILLAGE. Utiliser la commande "
    + "DEFI_GROUP a la place, attention celle-ci est réentrante.",
    "DEFI_COMPOR_POLYCRISTAL": "Le mot-clé MU_LOCA est obligatoire.",
    "DEFI_FISS_XFEM": "Le mot-clé MAILLAGE est obligatoire",
    "DEFI_MATER_GC_MAZARS": "Les mot-clés EIJ, EPSI_C, FTJ du mot-clé facteur MAZARS sont obligatoire",
    "DEFI_MATERIAU_THER_FO": "Attention les mot-clés suivants ('THER','THER_FO','THER_ORTH','THER_NL','THER_HYDR', "
    + "'THER_COQUE','THER_COQUE_FO') ne peuvent être utilisé en même temps.",
    "DEFI_MATERIAU_THER_ORTH": "Attention les mot-clés suivants ('THER','THER_FO','THER_ORTH','THER_NL','THER_HYDR', "
    + "'THER_COQUE','THER_COQUE_FO') ne peuvent être utilisé en même temps.",
    "DEFI_MATERIAU_THER_NL": "Attention les mot-clés suivants ('THER','THER_FO','THER_ORTH','THER_NL','THER_HYDR', "
    + "'THER_COQUE','THER_COQUE_FO') ne peuvent être utilisé en même temps.",
    "DEFI_MATERIAU_THER_HYDR": "Attention les mot-clés suivants ('THER','THER_FO','THER_ORTH','THER_NL','THER_HYDR', "
    + "'THER_COQUE','THER_COQUE_FO') ne peuvent être utilisé en même temps.",
    "DEFI_MATERIAU_THER_COQUE": "Attention les mot-clés suivants ('THER','THER_FO','THER_ORTH','THER_NL','THER_HYDR', "
    + "'THER_COQUE','THER_COQUE_FO') ne peuvent être utilisé en même temps.",
    "DEFI_MATERIAU_THER_COQUE_FO": "Attention les mot-clés suivants ('THER','THER_FO','THER_ORTH','THER_NL','THER_HYDR', "
    + "'THER_COQUE','THER_COQUE_FO') ne peuvent être utilisé en même temps.",
    "DEFI_MATERIAU_DIS_VISC": "Les mot-clés C et PUIS_ALPHA du mot-clé facteur DIS_VISC sont obligatoire.",
    "GENE_ACCE_SEISME_MODULATION": "Le mot-clé DUREE_PHASE_FORTE est obligatoire.",
    "IMPR_MISS_3D": "Les commandes IMPR_MISS_3D, MACRO_MISS_3D et LIRE_MISS_3D ont été réunies dans la commande"
    + " CALC_MISS",
    "INFO_FONCTION_NOCI_SEISME": "Le mot-clé FREQ_FOND est obligatoire.",
    "LIRE_MISS_3D": "Les commandes IMPR_MISS_3D, MACRO_MISS_3D et LIRE_MISS_3D ont été réunies dans la commande"
    + " CALC_MISS",
    "MACRO_MISS_3D": "Les commandes IMPR_MISS_3D, MACRO_MISS_3D et LIRE_MISS_3D ont été réunies dans la commande"
    + " CALC_MISS",
    "RECU_FONCTION_TABLE": "Si la valeur de TABLE est obtenu par GENE_FONC_ALEA remplacer par le mot-clé "
    "INTE_SPEC",
    "TEST_COMPOR": "La commande TEST_COMPOR produit une table de sortie dans tous les cas.",
}

sys.dict_erreurs = dict_erreurs


def traduc(infile, outfile, flog=None):
    hdlr = log.initialise(flog)
    jdc = getJDC(infile, atraiter)
    root = jdc.root

    # Parse les mocles des commandes
    parseKeywords(root)

    ####   traitement de DEFI_PART_PA_OPS   ##############################
    genereErreurPourCommande(jdc, "DEFI_PART_PA_OPS")

    ####   traitement de AFFE_CARA_ELEM   ##############################
    changementValeurDsMCFSiRegle(
        jdc,
        "AFFE_CARA_ELEM",
        "POUTRE",
        "CARA",
        {"R1": "R_DEBUT", "R2": "R_FIN", "EP1": "EP_DEBUT", "EP2": "EP_FIN"},
        (
            (
                (
                    "POUTRE",
                    "MAILLE",
                ),
                "nexistepasMCsousMCF",
            ),
            (("POUTRE", "SECTION", "CERCLE", jdc), "MCsousMCFaPourValeur"),
            (("POUTRE", "VARI_SECT", "HOMOTHETIQUE", jdc), "MCsousMCFaPourValeur"),
        ),
    )

    ####   traitement de AFFE_CHAR_MECA   ##############################
    # Suppression du mot-clé METHODE
    removeMotCle(jdc, "AFFE_CHAR_MECA", "METHODE", pasDeRegle(), 0)
    # Suppression des mot-clés LIAISON_XFEM
    removeMotCle(jdc, "AFFE_CHAR_MECA", "LIAISON_XFEM", pasDeRegle(), 0)
    removeMotCle(jdc, "AFFE_CHAR_MECA", "CONTACT_XFEM", pasDeRegle(), 0)
    # Modification des parametres du mot-clé DDL_POUTRE
    renameMotCleInFact(
        jdc,
        "AFFE_CHAR_MECA",
        "DDL_POUTRE",
        "GROUP_MA",
        "GROUP_MA_REPE",
        pasDeRegle(),
        0,
    )
    renameMotCleInFact(
        jdc, "AFFE_CHAR_MECA", "DDL_POUTRE", "MAILLE", "MAILLE_REPE", pasDeRegle(), 0
    )

    # Résorption des mot-clés ANGLE_NAUT et CENTRE
    removeMotCleInFact(
        jdc, "AFFE_CHAR_MECA", "LIAISON_SOLIDE", "ANGL_NAUT", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "AFFE_CHAR_MECA", "LIAISON_SOLIDE", "CENTRE", pasDeRegle(), 0
    )

    ####   traitement de AFFE_CHAR_MECA_F   ##############################
    # Suppression du mot-clé METHODE
    removeMotCle(jdc, "AFFE_CHAR_MECA_F", "METHODE", pasDeRegle(), 0)
    # Résorption des mot-clés ANGLE_NAUT et CENTRE
    removeMotCleInFact(
        jdc, "AFFE_CHAR_MECA_F", "LIAISON_SOLIDE", "ANGL_NAUT", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "AFFE_CHAR_MECA_F", "LIAISON_SOLIDE", "CENTRE", pasDeRegle(), 0
    )

    genereErreurMotCleInFact(jdc, "AFFE_CHAR_MECA_F", "ONDE_PLANE", "DIRECTION")

    ####   traitement de AFFE_CHAR_THER   ##############################
    # Suppression du mot-clé METHODE
    removeMotCle(jdc, "AFFE_CHAR_THER", "METHODE", pasDeRegle(), 0)

    ####   traitement de AFFE_MODELE   ##############################
    # Suppression des mot-clés GRILLE et VERIF
    removeMotCle(jdc, "AFFE_MODELE", "GRILLE", pasDeRegle(), 0)
    removeMotCle(jdc, "AFFE_MODELE", "VERIF", pasDeRegle(), 0)

    d3DINCO = {
        "3D_INCO": "3D_INCO_UP",
        "3D_INCO_OSGS": "3D_INCO_UPO",
        "3D_INCO_GD": "3D_INCO_UPG",
        "3D_INCO_LOG": "3D_INCO_UPG",
        "3D_INCO_LUP": "3D_INCO_UP",
    }
    dAXIS = {
        "AXIS_INCO": "AXIS_INCO_UP",
        "AXIS_INCO_OSGS": "AXIS_INCO_UPO",
        "AXIS_INCO_GD": "AXIS_INCO_UPG",
        "AXIS_INCO_LOG": "AXIS_INCO_UPG",
        "AXIS_INCO_LUP": "AXIS_INCO_UP",
    }
    dDPLAN = {
        "D_PLAN_INCO": "D_PLAN_INCO_UP",
        "D_PLAN_INCO_OSGS": "D_PLAN_INCO_UPO",
        "D_PLAN_INCO_GD": "D_PLAN_INCO_UPG",
        "D_PLAN_INCO_LOG": "D_PLAN_INCO_UPG",
        "D_PLAN_INCO_LUP": "D_PLAN_INCO_UP",
    }
    dINCO = {}
    dINCO.update(d3DINCO)
    dINCO.update(dAXIS)
    dINCO.update(dDPLAN)
    changementValeurDsMCF(jdc, "AFFE_MODELE", "AFFE", "MODELISATION", dINCO)

    ####   traitement de ASSEMBLAGE   ##############################
    genereErreurValeurDsMCF(jdc, "ASSEMBLAGE", "MATR_ASSE", "OPTION", ("'MASS_THER'",))

    ####   traitement de CALC_ESSAI_GEOMECA   ##############################
    renameMotCleInFact(
        jdc,
        "CALC_ESSAI_GEOMECA",
        "ESSAI_CISA_C",
        "EPSI_IMPOSE",
        "GAMMA_IMPOSE",
        pasDeRegle(),
        0,
    )
    renameMotCleInFact(
        jdc,
        "CALC_ESSAI_GEOMECA",
        "ESSAI_CISA_C",
        "EPSI_ELAS",
        "GAMMA_ELAS",
        pasDeRegle(),
        0,
    )

    ####   traitement de CALC_EUROPLEXUS   ##############################
    removeMotCle(jdc, "CALC_EUROPLEXUS", "DIME", pasDeRegle(), 0)
    genereErreurMCF(jdc, "CALC_EUROPLEXUS", "FONC_PARASOL")
    removeMotCleInFact(jdc, "CALC_EUROPLEXUS", "ARCHIVAGE", "CONT_GENER")

    ####   traitement de CALC_FERRAILLAGE   ##############################
    genereErreurPourCommande(jdc, "CALC_FERRAILLAGE")

    ####   traitement de CALC_FONCTION   ##############################
    ajouteMotClefDansFacteur(
        jdc, "CALC_FONCTION", "CORR_ACCE", "METHODE='POLYNOME'", pasDeRegle(), 0
    )
    genereErreurMotCleInFact(jdc, "CALC_FONCTION", "DSP", "FREQ")

    ####   traitement de CALC_G   ##############################
    removeMotCleInFact(jdc, "CALC_G", "COMP_ELAS", "RESI_INTE_RELA", pasDeRegle(), 0)
    removeMotCleInFact(jdc, "CALC_G", "COMP_ELAS", "ITER_INTE_MAXI", pasDeRegle(), 0)

    ####   traitement de CALC_FATIGUE   ##############################
    changementValeur(
        jdc,
        "CALC_FATIGUE",
        "COURBE_GRD_VIE",
        {
            "MANSON_C": "MANSOP_COFFIN",
        },
    )

    ####   traitement de CALC_IFS_DNL   ##############################
    removeMotCle(jdc, "CALC_IFS_DNL", "ENERGIE", pasDeRegle(), 0)

    ####   traitement de CALC_MAC3COEUR   ##############################
    ajouteMotClefDansFacteur(
        jdc, "CALC_MAC3COEUR", "DEFORMATION", "ARCHIMEDE = 'OUI'", pasDeRegle()
    )

    ####   traitement de CALC_MATR_ELEM   ##############################
    genereErreurValeur(jdc, "CALC_MATR_ELEM", "OPTION", ("'MASS_THER'",))

    ####   traitement de CALC_MISS   ##############################
    genereErreurValeurDsMCF(jdc, "CALC_MISS", "PARAMETRE", "ISSF", ("'OUI'",))

    ####   traitement de CALC_MODAL   ##############################
    # renameCommande(jdc,"CALC_MODAL","CALC_MODES", )
    genereErreurPourCommande(jdc, "CALC_MODAL")

    ####   traitement de CALC_VECT_ELEM   ##############################
    genereErreurValeur(jdc, "CALC_VECT_ELEM", "OPTION", ("'FORC_NODA'",))

    ####   traitement de CREA_MAILLAGE   ##############################
    renameMotCle(jdc, "CREA_MAILLAGE", "CREA_GROUP_MA", "CREA_MAILLE")
    genereErreurMCF(jdc, "CREA_MAILLAGE", "ECLA_PG")

    lMCLEF = [
        "COQU_VOLU",
        "CREA_FISS",
        "CREA_GROUP_MA",
        "CREA_MAILLE",
        "CREA_POI1",
        "ECLA_PG",
        "HEXA20_27",
        "LINE_QUAD",
        "MODI_MAILLE",
        "QUAD_LINE",
        "REPERE",
        "RESTREINT",
        "PENTA15_18",
    ]
    genereErreurMCF(jdc, "CREA_MAILLAGE", "DETR_GROUP_MA")
    removeMotCleInFactSiRegle(
        jdc,
        "CREA_MAILLAGE",
        "DETR_GROUP_MA",
        "NB_MAILLE",
        ((lMCLEF, "nexistepasMCFParmi"),),
    )
    renameMotCleInFactSiRegle(
        jdc,
        "CREA_MAILLAGE",
        "DETR_GROUP_MA",
        "GROUP_MA",
        "NOM",
        ((lMCLEF, "nexistepasMCFParmi"),),
    )
    renameCommandeSiRegle(
        jdc, "CREA_MAILLAGE", "DEFI_GROUP", ((lMCLEF, "nexistepasMCFParmi"),)
    )

    ####   traitement de DEBUT   ##############################
    # genereErreurPourCommande(jdc,("DEBUT",))
    removeMotCleInFact(jdc, "DEBUT", "CODE", "NOM", pasDeRegle(), 0)

    ####   traitement de DEFI_COMPOR   ##############################
    genereErreurValeur(
        jdc,
        "DEFI_COMPOR",
        "LOCALISATION",
        [
            "'RL'",
        ],
    )
    genereErreurValeur(
        jdc,
        "DEFI_COMPOR",
        "RELATION_KIT",
        [
            "'RVMIS_ISOT_CINE'",
        ],
    )
    genereErreurValeurDsMCF(
        jdc, "DEFI_COMPOR", "MULTIFIBRE", "RELATION", ["'LABORD_1D'"]
    )
    genereErreurMCF(jdc, "DEFI_COMPOR", "POLYCRISTAL")

    ####   traitement de DEFI_FISS_XFEM   ##############################
    genereErreurPourCommande(jdc, ("DEFI_FISS_XFEM",))
    removeMotCle(jdc, "DEFI_FISS_XFEM", "MODELE", pasDeRegle(), 0)
    removeMotCle(jdc, "DEFI_FISS_XFEM", "MODELE_GRILLE", pasDeRegle(), 0)

    ####   traitement de DEFI_LIST_INST   ##############################
    changementValeurDsMCF(
        jdc, "DEFI_LIST_INST", "ECHEC", "ACTION", {"REAC_PRECOND": "DECOUPE"}
    )

    ####   traitement de DEFI_MATER_GC   ##############################
    ajouteMotClefDansFacteur(
        jdc, "DEFI_MATER_GC", "MAZARS", "CODIFICATION='ESSAI'", pasDeRegle(), 0
    )

    removeMotCleInFactSiRegle(
        jdc,
        "DEFI_MATER_GC",
        "MAZARS",
        "UNITE_LONGUEUR",
        (
            (
                ("MAZARS", "CODIFICATION", ["ESSAI"], jdc),
                "MCsousMCFaPourValeurDansListe",
            ),
        ),
    )
    renameMotCleInFact(
        jdc, "DEFI_MATER_GC", "MAZARS", "UNITE_LONGUEUR", "UNITE_CONTRAINTE"
    )
    changementValeurDsMCF(
        jdc, "DEFI_MATER_GC", "MAZARS", "UNITE_CONTRAINTE", {"MM": "MPa"}
    )
    changementValeurDsMCF(
        jdc, "DEFI_MATER_GC", "MAZARS", "UNITE_CONTRAINTE", {"M": "Pa"}
    )

    genereErreurMCF(jdc, "DEFI_MATER_GC", "MAZARS")

    ####   traitement de DEFI_MATERIAU   ##############################
    lMLA = [
        "F_MRR_RR",
        "C_MRR_RR",
        "F_MTT_TT",
        "C_MTT_TT",
        "F_MZZ_ZZ",
        "C_MZZ_ZZ",
        "F_MRT_RT",
        "C_MRT_RT",
        "F_MRZ_RZ",
        "C_MRZ_RZ",
        "F_MTZ_TZ",
        "C_MTZ_TZ",
    ]
    for param in lMLA:
        removeMotCleInFact(
            jdc, "DEFI_MATERIAU", "META_LEMA_ANI", param, pasDeRegle(), 0
        )
        removeMotCleInFact(
            jdc, "DEFI_MATERIAU", "META_LEMA_ANI_FO", param, pasDeRegle(), 0
        )

    lMDC = [
        "BETA",
        "DELTA1",
        "DELTA2",
        "DEPDT",
    ]
    for mcle in lMDC:
        removeMotCleInFact(jdc, "DEFI_MATERIAU", "MONO_DD_CC", mcle, pasDeRegle(), 0)
        removeMotCleInFact(
            jdc, "DEFI_MATERIAU", "MONO_DD_CC_IRRA", mcle, pasDeRegle(), 0
        )

    removeMotCleInFact(jdc, "DEFI_MATERIAU", "UMAT", "NB_VALE", pasDeRegle(), 0)
    removeMotCleInFact(jdc, "DEFI_MATERIAU", "UMAT_FO", "NB_VALE", pasDeRegle(), 0)
    listeMc = ["C" + str(i) for i in range(1, 198)]
    fusionMotCleInFact(jdc, "DEFI_MATERIAU", "UMAT", listeMc, "LISTE_COEF")
    fusionMotCleInFact(jdc, "DEFI_MATERIAU", "UMAT_FO", listeMc, "LISTE_COEF")

    removeMotCle(jdc, "DEFI_MATERIAU", "LABORD_1D", pasDeRegle(), 0)

    genereErreurMCF(jdc, "DEFI_MATERIAU", "DIS_VISC")
    lDISC = [
        "PUIS_DX",
        "PUIS_DY",
        "PUIS_DZ",
        "PUIS_RX",
        "PUIS_RY",
        "PUIS_RZ",
        "COEF_DX",
        "COEF_DY",
        "COEF_DZ",
        "COEF_RX",
        "COEF_RY",
        "COEF_RZ",
    ]
    for param in lDISC:
        removeMotCleInFact(jdc, "DEFI_MATERIAU", "DIS_VISC", param, pasDeRegle(), 0)

    lTHMD = [
        "PERMIN_X",
        "PERMIN_Y",
        "PERMIN_Z",
        "PERMINXY",
        "PERMINYZ",
        "PERMINZX",
    ]
    for param in lTHMD:
        removeMotCleInFact(jdc, "DEFI_MATERIAU", "THM_DIFFU", param, pasDeRegle(), 0)

    # lMONODD=["DELTA1", "DELTA2"]
    # for param in lMONODD:
    # removeMotCleInFact(jdc,"DEFI_MATERIAU","MONO_DD_CC",param,pasDeRegle(),0)
    # removeMotCleInFact(jdc,"DEFI_MATERIAU","MONO_DD_CC_IRRA",param,pasDeRegle(),0)

    removeMotCleInFact(jdc, "DEFI_MATERIAU", "GLRC_DM", "EF", pasDeRegle(), 0)
    removeMotCleInFact(jdc, "DEFI_MATERIAU", "GLRC_DM", "NUF", pasDeRegle(), 0)

    genereErreurMCF(jdc, "DEFI_MATERIAU", "THER_FO")
    genereErreurMCF(jdc, "DEFI_MATERIAU", "THER_NL")
    genereErreurMCF(jdc, "DEFI_MATERIAU", "THER_HYDR")
    genereErreurMCF(jdc, "DEFI_MATERIAU", "THER_COQUE")
    genereErreurMCF(jdc, "DEFI_MATERIAU", "THER_COQUE_FO")

    ####   traitement de DEFI_OBSTACLE   ##############################
    lMCLE = (
        "CRAYON_900",
        "CRAYON_1300",
        "GUID_A_CARTE_900",
        "GUID_B_CARTE_900",
        "GUID_C_CARTE_900",
        "GUID_D_CARTE_900",
        "GUID_E_CARTE_900",
        "GUID_F_CARTE_900",
        "GUID_A_CARTE_1300",
        "GUID_B_CARTE_1300",
        "GUID_C_CARTE_1300",
        "GUID_D_CARTE_1300",
        "GUID_E_CARTE_1300",
        "GUID_F_CARTE_1300",
        "GUID_A_CARSP_900",
        "GUID_B_CARSP_900",
        "GUID_C_CARSP_900",
        "GUID_D_CARSP_900",
        "GUID_E_CARSP_900",
        "GUID_F_CARSP_900",
        "GUID_A_CARSP_1300",
        "GUID_B_CARSP_1300",
        "GUID_C_CARSP_1300",
        "GUID_D_CARSP_1300",
        "GUID_E_CARSP_1300",
        "GUID_F_CARSP_1300",
        "GUID_A_GCONT_900",
        "GUID_B_GCONT_900",
        "GUID_C_GCONT_900",
        "GUID_D_GCONT_900",
        "GUID_E_GCONT_900",
        "GUID_F_GCONT_900",
        "GUID_A_GCONT_1300",
        "GUID_B_GCONT_1300",
        "GUID_C_GCONT_1300",
        "GUID_D_GCONT_1300",
        "GUID_E_GCONT_1300",
        "GUID_F_GCONT_1300",
        "GUID_A_GCOMB_900",
        "GUID_B_GCOMB_900",
        "GUID_C_GCOMB_900",
        "GUID_D_GCOMB_900",
        "GUID_E_GCOMB_900",
        "GUID_F_GCOMB_900",
        "GUID_A_GCOMB_1300",
        "GUID_B_GCOMB_1300",
        "GUID_C_GCOMB_1300",
        "GUID_D_GCOMB_1300",
        "GUID_E_GCOMB_1300",
        "GUID_F_GCOMB_1300",
    )
    genereErreurValeur(jdc, "DEFI_OBSTACLE", "TYPE", lMCLE)

    ####   traitement de DYNA_TRAN_MODAL   ##############################
    removeMotCle(jdc, "DYNA_TRAN_MODAL", "LAME_FLUIDE", pasDeRegle(), 0)
    removeMotCle(jdc, "DYNA_TRAN_MODAL", "PARA_LAME_FLUI", pasDeRegle(), 0)
    removeMotCle(jdc, "DYNA_TRAN_MODAL", "RELA_TRANSIS", pasDeRegle(), 0)

    ####   traitement de DYNA_VIBRA   ##############################
    removeMotCle(jdc, "DYNA_VIBRA", "LAME_FLUIDE", pasDeRegle(), 0)
    removeMotCle(jdc, "DYNA_VIBRA", "PARA_LAME_FLUI", pasDeRegle(), 0)
    removeMotCle(jdc, "DYNA_VIBRA", "RELA_TRANSIS", pasDeRegle(), 0)

    ####   traitement de EXTR_TABLE   ##############################
    changementValeurDsMCF(
        jdc, "EXTR_TABLE", "FILTRE", "VALE_K", {"MATR_ELEM": "MATR_TANG_ELEM"}
    )
    changementValeurDsMCF(
        jdc, "EXTR_TABLE", "FILTRE", "VALE_K", {"CODE_RETOUR": "CODE_RETOUR_INTE"}
    )

    ####   traitement de FACTORISER   ##############################
    renameMotCle(jdc, "FACTORISER", "ELIM_LAGR2", "ELIM_LAGR")
    changementValeur(
        jdc,
        "FACTORISER",
        "ELIM_LAGR",
        {
            "OUI": "LAGR2",
        },
    )

    ####   traitement de GENE_ACCE_SEISME   ##############################
    genereErreurMCF(jdc, "GENE_ACCE_SEISME", "MODULATION")
    moveMotCleFromFactToFather(
        jdc, "GENE_ACCE_SEISME", "MODULATION", "DUREE_PHASE_FORTE"
    )

    removeMotCleInFact(jdc, "GENE_ACCE_SEISME", "MODULATION", "PARA")
    removeMotCleInFactSiRegle(
        jdc,
        "GENE_ACCE_SEISME",
        "MODULATION",
        "INST_INI",
        (
            (
                ("MODULATION", "TYPE", ["GAMMA"], jdc),
                "MCsousMCFnaPasPourValeurDansListe",
            ),
        ),
    )

    removeMotCleInFact(jdc, "GENE_ACCE_SEISME", "DSP", "FREQ_PENTE")

    ####   traitement de IMPR_MISS_3D   ##############################
    genereErreurPourCommande(jdc, "IMPR_MISS_3D")
    # removeCommande(jdc,"IMPR_MISS_3D")

    ####   traitement de IMPR_RESU   ##############################
    removeMotCle(jdc, "IMPR_RESU", "RESTREINT", pasDeRegle(), 0)

    ####   traitement de INFO_FONCTION   ##############################
    genereErreurMCF(jdc, "INFO_FONCTION", "NOCI_SEISME")

    ####   traitement de LIRE_MAILLAGE   ##############################
    removeMotCle(jdc, "LIRE_MAILLAGE", "ABSC_CURV", pasDeRegle(), 0)

    ####   traitement de LIRE_MISS_3D   ##############################
    genereErreurPourCommande(jdc, "LIRE_MISS_3D")

    ####   traitement de MACR_ASCOUF_CALC   ##############################
    removeMotCle(jdc, "MACR_ASCOUF_CALC", "CL_BOL_P2_GV", pasDeRegle(), 0)
    # genereErreurMCF(jdc,"MACR_ASCOUF_CALC","COMP_ELAS")

    ####   traitement de MACR_ASCOUF_MAIL   ##############################
    genereErreurValeurDsMCF(jdc, "MACR_ASCOUF_MAIL", "COUDE", "BOL_P2", ("'GV'",))

    ####   traitement de MACR_ASPIC_CALC   ##############################
    # genereErreurMCF(jdc,"MACR_ASPIC_CALC","COMP_ELAS")

    ####   traitement de MACR_ECREVISSE   ##############################
    genereErreurMCF(jdc, "MACR_ECREVISSE", "COMP_INCR")

    ####   traitement de MACR_INFO_MAIL   ##############################
    changementValeur(jdc, "MACR_INFO_MAIL", "VERSION_HOMARD", {"V10_6": "V11_2"})
    changementValeur(jdc, "MACR_INFO_MAIL", "VERSION_HOMARD", {"V10_N": "V11_N"})
    changementValeur(
        jdc, "MACR_INFO_MAIL", "VERSION_HOMARD", {"V10_N_PERSO": "V11_N_PERSO"}
    )

    ####   traitement de MACRO_BASCULE_SCHEMA   ##############################
    renameMotCle(
        jdc, "MACRO_BASCULE_SCHEMA", "COMP_INCR_IMPL", "COMPORTEMENT_IMPL", pasDeRegle()
    )
    renameMotCle(
        jdc, "MACRO_BASCULE_SCHEMA", "COMP_INCR_EXPL", "COMPORTEMENT_EXPL", pasDeRegle()
    )

    ####   traitement de MACRO_MISS_3D   ##############################
    genereErreurPourCommande(jdc, "MACRO_MISS_3D")

    ####   traitement de MACRO_MODE_MECA   ##############################
    # insereMotCleDansCommande(jdc,"MACRO_MODE_MECA","TYPE_RESU='DYNAMIQUE'")
    chercheOperInsereFacteur(
        jdc,
        "MACRO_MODE_MECA",
        "SOLVEUR_MODAL",
    )
    chercheOperInsereFacteur(jdc, "MACRO_MODE_MECA", "OPTION='BANDE'", pasDeRegle(), 0)
    chercheOperInsereFacteurSiRegle(
        jdc, "MACRO_MODE_MECA", "NORM_MODE", ((("NORM_MODE",), "nexistepas"),), 1
    )

    lMCLE = ["PREC_SOREN", "NMAX_ITER_SOREN", "PARA_ORTHO_SOREN"]
    for mcle in lMCLE:
        moveMotClefInOperToFact(jdc, "MACRO_MODE_MECA", mcle, "SOLVEUR_MODAL")

    moveMotCleFromFactToFact(
        jdc, "MACRO_MODE_MECA", "CALC_FREQ", "COEF_DIM_ESPACE", "SOLVEUR_MODAL"
    )
    moveMotCleFromFactToFact(
        jdc, "MACRO_MODE_MECA", "CALC_FREQ", "DIM_SOUS_ESPACE", "SOLVEUR_MODAL"
    )
    renameCommande(
        jdc,
        "MACRO_MODE_MECA",
        "CALC_MODES",
    )

    ####   traitement de MODE_ITER_INV   ##############################
    chercheOperInsereFacteur(
        jdc,
        "MODE_ITER_INV",
        "SOLVEUR_MODAL",
    )
    moveMotCleFromFactToFather(jdc, "MODE_ITER_INV", "CALC_FREQ", "OPTION")
    moveMotCleFromFactToFather(jdc, "MODE_ITER_INV", "CALC_CHAR_CRIT", "OPTION")

    lINV = [
        "OPTION",
        "PREC",
        "NMAX_ITER",
    ]
    for mcle in lINV:
        renameMotCleInFact(
            jdc, "MODE_ITER_INV", "CALC_MODE", mcle, mcle + "_INV", pasDeRegle(), 0
        )
        moveMotCleFromFactToFact(
            jdc, "MODE_ITER_INV", "CALC_MODE", mcle + "_INV", "SOLVEUR_MODAL"
        )

    lMCLE = [
        "NMAX_ITER_AJUSTE",
        "PREC_AJUSTE",
    ]
    for mcle in lMCLE:
        moveMotCleFromFactToFact(
            jdc, "MODE_ITER_INV", "CALC_FREQ", mcle, "SOLVEUR_MODAL"
        )
    moveMotClefInOperToFact(jdc, "MODE_ITER_SIMULT", "PREC_JACOBI", "SOLVEUR_MODAL")
    moveMotClefInOperToFact(jdc, "MODE_ITER_SIMULT", "PREC_BATHE", "SOLVEUR_MODAL")

    removeMotCle(jdc, "MODE_ITER_INV", "CALC_MODE", pasDeRegle(), 0)

    chercheOperInsereMotCleSiRegle(
        jdc, "MODE_ITER_INV", "OPTION='AJUSTE'", ((("OPTION",), "nexistepas"),), 0
    )

    renameCommande(
        jdc,
        "MODE_ITER_INV",
        "CALC_MODES",
    )

    ####   traitement de MODE_ITER_SIMULT   ##############################
    chercheOperInsereFacteur(
        jdc,
        "MODE_ITER_SIMULT",
        "SOLVEUR_MODAL",
    )
    removeMotCleSiRegle(
        jdc,
        "MODE_ITER_SIMULT",
        "OPTION",
        ((("METHODE", "TRI_DIAG", jdc), "MCnaPasPourValeur"),),
    )
    removeMotCleSiRegle(
        jdc,
        "MODE_ITER_SIMULT",
        "OPTION",
        ((("OPTION", "SANS", jdc), "MCaPourValeur"),),
    )
    moveMotClefInOperToFact(jdc, "MODE_ITER_SIMULT", "OPTION", "SOLVEUR_MODAL")
    changementValeurDsMCF(
        jdc, "MODE_ITER_SIMULT", "SOLVEUR_MODAL", "OPTION", {"MODE_RIGIDE": "OUI"}
    )
    renameMotCleInFact(
        jdc, "MODE_ITER_SIMULT", "SOLVEUR_MODAL", "OPTION", "MODE_RIGIDE"
    )
    moveMotCleFromFactToFather(jdc, "MODE_ITER_SIMULT", "CALC_FREQ", "OPTION")
    moveMotCleFromFactToFather(jdc, "MODE_ITER_SIMULT", "CALC_CHAR_CRIT", "OPTION")

    # chercheOperInsereFacteurSiRegle(jdc,"MODE_ITER_SIMULT","SOLVEUR_MODAL",((("METHODE",),"existe"),),1)
    moveMotClefInOperToFact(jdc, "MODE_ITER_SIMULT", "METHODE", "SOLVEUR_MODAL")
    moveMotClefInOperToFact(jdc, "MODE_ITER_SIMULT", "TYPE_QZ", "SOLVEUR_MODAL")
    moveMotClefInOperToFact(jdc, "MODE_ITER_SIMULT", "NMAX_ITER_BATHE", "SOLVEUR_MODAL")
    moveMotCleFromFactToFact(
        jdc, "MODE_ITER_SIMULT", "CALC_FREQ", "COEF_DIM_ESPACE", "SOLVEUR_MODAL"
    )
    moveMotCleFromFactToFact(
        jdc, "MODE_ITER_SIMULT", "CALC_FREQ", "DIM_SOUS_ESPACE", "SOLVEUR_MODAL"
    )
    moveMotCleFromFactToFact(
        jdc, "MODE_ITER_SIMULT", "CALC_CHAR_CRIT", "COEF_DIM_ESPACE", "SOLVEUR_MODAL"
    )
    moveMotCleFromFactToFact(
        jdc, "MODE_ITER_SIMULT", "CALC_CHAR_CRIT", "DIM_SOUS_ESPACE", "SOLVEUR_MODAL"
    )

    removeMotCleInFactSiRegle(
        jdc,
        "MODE_ITER_SIMULT",
        "CALC_FREQ",
        "APPROCHE",
        (
            (
                ("SOLVEUR_MODAL", "METHODE", ["QZ"], jdc),
                "MCsousMCFnaPasPourValeurDansListe",
            )
            or (
                (
                    "SOLVEUR_MODAL",
                    "METHODE",
                ),
                "nexistepasMCsousMCF",
            ),
        ),
    )

    moveMotCleFromFactToFact(
        jdc, "MODE_ITER_SIMULT", "CALC_FREQ", "APPROCHE", "SOLVEUR_MODAL"
    )
    moveMotCleFromFactToFact(
        jdc, "MODE_ITER_SIMULT", "CALC_CHAR_CRIT", "APPROCHE", "SOLVEUR_MODAL"
    )

    lMCLE = ["PREC_SOREN", "NMAX_ITER_SOREN", "PARA_ORTHO_SOREN"]
    for mcle in lMCLE:
        moveMotClefInOperToFact(jdc, "MODE_ITER_SIMULT", mcle, "SOLVEUR_MODAL")

    lMCLE = ["NMAX_ITER_QR", "PREC_ORTHO", "NMAX_ITER_ORTHO", "PREC_LANCZOS"]
    for mcle in lMCLE:
        moveMotClefInOperToFact(jdc, "MODE_ITER_SIMULT", mcle, "SOLVEUR_MODAL")

    renameCommande(
        jdc,
        "MODE_ITER_SIMULT",
        "CALC_MODES",
    )

    ####   traitement de MODI_MAILLAGE   ##############################
    genereErreurValeurDsMCF(
        jdc, "MODI_MAILLAGE", "DEFORME", "OPTION", ("'TRAN_APPUI'",)
    )
    removeMotCleInFact(
        jdc, "MODI_MAILLAGE", "DEFORME", ["GROUP_NO_APPUI"], pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "MODI_MAILLAGE", "DEFORME", ["GROUP_NO_STRU"], pasDeRegle(), 0
    )

    ####   traitement de MODI_MODELE_XFEM   ##############################
    changementValeur(
        jdc,
        "MODI_MODELE_XFEM",
        "CONTACT",
        {
            "P1P1": "STANDARD",
        },
    )
    changementValeur(
        jdc,
        "MODI_MODELE_XFEM",
        "CONTACT",
        {
            "P2P1": "STANDARD",
        },
    )

    ####   traitement de POST_DYNA_ALEA   ##############################
    chercheOperInsereFacteurSiRegle(
        jdc, "POST_DYNA_ALEA", "INTERSPECTRE", ((("INTE_SPEC",), "existe"),), 1
    )
    lPDA = [
        "INTE_SPEC",
        "NUME_ORDRE_I",
        "NOEUD_I",
        "OPTION",
        "NUME_ORDRE_J",
        "NOEUD_J",
        "NOM_CMP_I",
        "NOM_CMP_J",
        "MOMENT",
        "DUREE",
    ]
    for mcle in lPDA:
        moveMotClefInOperToFact(jdc, "POST_DYNA_ALEA", mcle, "INTERSPECTRE")
    removeMotCle(jdc, "POST_DYNA_ALEA", "TOUT_ORDRE", pasDeRegle(), 0)

    ajouteMotClefDansFacteur(
        jdc, "POST_DYNA_ALEA", "FRAGILITE", "METHODE = 'EMV'", pasDeRegle()
    )

    ####   traitement de POST_ELEM   ##############################
    ajouteMotClefDansFacteurSiRegle(
        jdc,
        "POST_ELEM",
        "VOLUMOGRAMME",
        "NB_INTERV=5",
        (
            (
                (
                    "VOLUMOGRAMME",
                    "NB_INTERV",
                ),
                "nexistepasMCsousMCF",
            ),
        ),
    )

    ####   traitement de POST_FATIGUE   ##############################
    changementValeur(
        jdc,
        "POST_FATIGUE",
        "DOMMAGE",
        {
            "MANSON_C": "MANSOP_COFFIN",
        },
    )

    ####   traitement de POURSUITE   ##############################
    removeMotCle(
        jdc,
        "POURSUITE",
        "CODE",
    )  # "NOM",pasDeRegle(),0)

    ####   traitement de RECU_FONCTION   ##############################
    genereErreurMCF(jdc, "RECU_FONCTION", "TABLE")

    ####   traitement de C_COMP_INCR et C_COMP_ELAS   ##############################
    lCOM = [
        "CALCUL",
        "STAT_NON_LINE",
        "CALC_G",
        "CALC_PRECONT",
        "DYNA_NON_LINE",
        "CALC_META",
        "TEST_COMPOR",
        "SIMU_POINT_MAT",
        "CALC_ESSAI_GEOMECA",
        "CALC_FORC_NONL",
        "LIRE_RESU",
        "MACR_ASCOUF_CALC",
        "MACR_ASPIC_CALC",
        "CALC_EUROPLEXUS",
        "MACR_ECREVISSE",
    ]
    for com in lCOM:
        # chercheOperInsereFacteurSiRegle(jdc,com,"COMPORTEMENT",(((["COMPORTEMENT"],),"nexistepasMCFParmi"),),1)
        fusionMCFToMCF(jdc, com, ["COMP_ELAS", "COMP_INCR"], "COMPORTEMENT")
        # renameMotCle(jdc,com,"COMP_ELAS","COMPORTEMENT")
        # renameMotCle(jdc,com,"COMP_INCR","COMPORTEMENT")
        chercheOperInsereFacteurSiRegle(
            jdc,
            com,
            "ETAT_INIT",
            (
                (
                    (
                        "COMPORTEMENT",
                        "SIGM_INIT",
                    ),
                    "existeMCsousMCF",
                ),
            ),
            1,
        )
        moveMotCleFromFactToFact(jdc, com, "COMPORTEMENT", "SIGM_INIT", "ETAT_INIT")
        renameMotCleInFact(jdc, com, "ETAT_INIT", "SIGM_INIT", "SIGM", pasDeRegle(), 0)
        removeMotCleInFact(jdc, com, "COMPORTEMENT", "SIGM_INIT", pasDeRegle(), 0)

        changementValeur(jdc, com, "OPTION", {"FORC_INT_ELEM": "FORC_INTE_ELEM"})

        removeMotCleInFactSiRegle(
            jdc,
            com,
            "COMPORTEMENT",
            "NB_VARI",
            ((("COMPORTEMENT", "RELATION", "'MFRONT'", jdc), "MCsousMCFaPourValeur"),),
        )

    ####   traitement de TEST_COMPOR   ##############################
    genereErreurPourCommande(jdc, "TEST_COMPOR")

    ####   traitement de THER_NON_LINE   ##############################
    renameMotCle(jdc, "THER_NON_LINE", "COMP_THER_NL", "COMPORTEMENT")

    ####   traitement de C_SOLVEUR   ##############################
    lCOM = [
        "CALC_ERREUR",
        "CALC_FORC_AJOU",
        "CALC_IFS_DNL",
        "CALC_MATR_AJOU",
        "CALC_PRECONT",
        "CREA_ELEM_SSD",
        "DEFI_BASE_MODALE",
        "DYNA_LINE_HARM",
        "DYNA_LINE_TRAN",
        "DYNA_NON_LINE",
        "DYNA_TRAN_MODAL",
        "INFO_MODE",
        "MACR_ASCOUF_CALC",
        "MACR_ASPIC_CALC",
        "MACRO_BASCULE_SCHEMA",
        "MACRO_MATR_AJOU",
        "MECA_STATIQUE",
        "MODE_ITER_SIMULT",
        "MODE_ITER_INV",
        "MODE_STATIQUE",
        "STAT_NON_LINE",
        "THER_LINEAIRE",
        "THER_NON_LINE",
        "THER_NON_LINE_MO",
        "CALC_ERC_DYN",
        "CALC_MODES",
    ]
    for com in lCOM:
        # Suppression de ELIM_LAGR2
        changementValeurDsMCF(jdc, com, "SOLVEUR", "ELIM_LAGR2", {"OUI": "LAGR2"})
        removeMotCleInFactSiRegle(
            jdc,
            com,
            "SOLVEUR",
            "ELIM_LAGR2",
            ((("SOLVEUR", "ELIM_LAGR2", "NON", jdc), "MCsousMCFaPourValeur"),),
        )
        renameMotCleInFact(jdc, com, "SOLVEUR", "ELIM_LAGR2", "ELIM_LAGR")

        # Suppression de la méthode FETI
        genereErreurValeurDsMCF(jdc, com, "SOLVEUR", "METHODE", ["FETI"])
        lMCLE = ["NB_REORTHO_DD", "NMAX_ITER", "INFO_FETI", "RESI_RELA", "PARTITION"]
        for mocle in lMCLE:
            genereErreurMotCleInFact(jdc, com, "SOLVEUR", mocle)

    ####   traitement de DEFI_PART_FETI   ##############################
    genereErreurMCF(jdc, "DEFI_PART_FETI", "EXCIT")
    removeMotCle(jdc, "DEFI_PART_FETI", "EXCIT", pasDeRegle(), 0)
    removeMotCle(jdc, "DEFI_PART_FETI", "CORRECTIOP_CONNEX", pasDeRegle(), 0)
    genereErreurPourCommande(jdc, "DEFI_PART_FETI")
    renameCommande(
        jdc,
        "DEFI_PART_FETI",
        "DEFI_PARTITION",
    )

    #################################################################
    f = open(outfile, "w")
    f.write(jdc.getSource())
    f.close()

    log.ferme(hdlr)


def main():
    parser = optparse.Optionparser(usage=usage)

    parser.add_option(
        "-i",
        "--infile",
        dest="infile",
        default="toto.comm",
        help="Le fichier à traduire",
    )
    parser.add_option(
        "-o",
        "--outfile",
        dest="outfile",
        default="tutu.comm",
        help="Le fichier traduit",
    )

    options, args = parser.parse_args()
    traduc(options.infile, options.outfile)


if __name__ == "__main__":
    main()
