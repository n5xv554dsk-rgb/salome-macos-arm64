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
  python traduitV10V11.py --infile=xxxx --outfile=yyyy
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
    "AFFE_CHAR_MECA_F",
    "AFFE_CHAR_OPS011",
    "AFFE_CHAR_THER",
    "AFFE_CHAR_THER_F",
    "AFFE_MATERIAU",
    "AFFE_MODELE",
    "ASSE_ELEM_SSD",
    "ASSEMBLAGE",
    "CALC_CHAM_ELEM",
    "CALC_CHAMP",
    "CALC_ECREVISSE",
    "CALC_ELEM",
    "CALC_ERREUR",
    "CALC_ESSAI",
    "CALC_EUROPLEXUS",
    "CALC_FATIGUE",
    "CALC_FERRAILLAGE",
    "CALC_FONC_INTERP",
    "CALC_FONCTION",
    "CALC_FORC_AJOU",
    "CALC_G",
    "CALC_IFS_DNL",
    "CALC_INTE_SPEC",
    "CALC_MAC3COEUR",
    "CALC_MATR_AJOU",
    "CALC_MATR_ELEM",
    "CALC_META",
    "CALC_MISS",
    "CALC_MODAL",
    "CALC_MODE_ROTATION",
    "CALC_NO",
    "CALC_POINT_MAT",
    "CALC_PRECONT",
    "CALC_SENSI",
    "CALC_SPEC",
    "CALC_TABLE",
    "CALC_THETA",
    "COMB_FOURIER",
    "COMB_SISM_MODAL",
    "COPIER",
    "CREA_CHAMP",
    "CREA_ELEM_SSD",
    "CREA_MAILLAGE",
    "CREA_RESU",
    "CREA_TABLE",
    "DEBUT",
    "DEFI_BASE_MODALE",
    "DEFI_CABLE_BP",
    "DEFI_COMPOR",
    "DEFI_CONTACT",
    "DEFI_COQU_MULT",
    "DEFI_FICHIER",
    "DEFI_FISS_XFEM",
    "DEFI_FONC_ELEC",
    "DEFI_FOND_FISS",
    "DEFI_GLRC",
    "DEFI_GROUP",
    "DEFI_INTE_SPEC",
    "DEFI_LIST_INST",
    "DEFI_MATER_GC",
    "DEFI_MATERIAU",
    "DEFI_NAPPE",
    "DEFI_PARA_SENSI",
    "DEFI_PART_FETI",
    "DEFI_SOL_MISS",
    "DEFI_SPEC_TURB",
    "DETRUIRE",
    "DYNA_ALEA_MODAL",
    "DYNA_ISS_VARI",
    "DYNA_LINE_HARM",
    "DYNA_LINE_TRAN",
    "DYNA_NON_LINE",
    "DYNA_SPEC_MODAL",
    "DYNA_TRAN_MODAL",
    "DYNA_VIBRA",
    "EXEC_LOGICIEL",
    "EXTR_RESU",
    "EXTR_TABLE",
    "FACTORISER",
    "FORMULE",
    "GENE_ACCE_SEISME",
    "GENE_FONC_ALEA",
    "GENE_VARI_ALEA",
    "IMPR_CO",
    "IMPR_DIAG_CAMPBELL",
    "IMPR_FONCTION",
    "IMPR_GENE",
    "IMPR_OAR",
    "IMPR_RESU",
    "IMPR_STURM",
    "IMPR_TABLE",
    "INCLUDE",
    "INCLUDE_MATERIAU",
    "INFO_EXEC_ASTER",
    "INFO_FONCTION",
    "INFO_MODE",
    "LIRE_CHAMP",
    "LIRE_FONCTION",
    "LIRE_IMPE_MISS",
    "LIRE_INTE_SPEC",
    "LIRE_MAILLAGE",
    "LIRE_RESU",
    "LIRE_TABLE",
    "MACR_ADAP_MAIL",
    "MACR_ASCOUF_CALC",
    "MACR_ASCOUF_MAIL",
    "MACR_ASPIC_CALC",
    "MACR_ASPIC_MAIL",
    "MACR_CARA_POUTRE",
    "MACR_ECLA_PG",
    "MACR_ECRE_CALC",
    "MACR_ECREVISSE",
    "MACR_ELEM_DYNA",
    "MACR_FIABILITE",
    "MACR_FIAB_IMPR",
    "MACR_INFO_MAIL",
    "MACR_LIGP_COUPE",
    "MACRO_ELAS_MULT",
    "MACRO_EXPANS",
    "MACRO_MATR_AJOU",
    "MACRO_MATR_ASSE",
    "MACRO_MISS_3D",
    "MACRO_MODE_MECA",
    "MACRO_PROJ_BASE",
    "MACR_RECAL",
    "MACR_SPECTRE",
    "MECA_STATIQUE",
    "MODE_ITER_INV",
    "MODE_ITER_SIMULT",
    "MODE_STATIQUE",
    "MODI_MODELE_XFEM",
    "MODI_REPERE",
    "NORM_MODE",
    "NUME_DDL",
    "NUME_DDL_GENE",
    "OBSERVATION",
    "POST_BORDET",
    "POST_CHAMP",
    "POST_CHAM_XFEM",
    "POST_COQUE",
    "POST_DECOLLEMENT",
    "POST_DYNA_ALEA",
    "POST_ELEM",
    "POST_ENDO_FISS",
    "POST_FATIGUE",
    "POST_GP",
    "POST_K1_K2_K3",
    "POST_K_TRANS",
    "POST_MAC3COEUR",
    "POST_MAIL_XFEM",
    "POST_RCCM",
    "POST_RELEVE_T",
    "POST_RUPTURE",
    "POST_USURE",
    "POURSUITE",
    "PROJ_BASE",
    "PROJ_CHAMP",
    "PROJ_RESU_BASE",
    "PROJ_SPEC_BASE",
    "PROPA_FISS",
    "PROPA_XFEM",
    "RAFF_XFEM",
    "RECU_FONCTION",
    "RECU_GENE",
    "RESOUDRE",
    "REST_SPEC_PHYS",
    "SIMU_POINT_MAT",
    "STANLEY",
    "STAT_NON_LINE",
    "TEST_COMPOR",
    "TEST_FICHIER",
    "TEST_FONCTION",
    "TEST_RESU",
    "TEST_TABLE",
    "TEST_TEMPS",
    "THER_LINEAIRE",
    "THER_NON_LINE",
    "THER_NON_LINE_MO",
    "CALC_CHAMPNO",
    "CALC_METANO",
    "CALC_ERREURNO",
)

dict_erreurs = {
    "CALC_G_THETA_DTAN_ORIG": "La valeur de DTAN_ORIG est maintenant calculée automatiquement",
    "CALC_G_THETA_DTAN_EXTR": "La valeur de DTAN_EXTR est maintenant calculée automatiquement",
    "AFFE_CHAR_MECA_CONTACT": "Attention, modification de la définition du CONTACT : nommer DEFI_CONTACT,verifier les paramètres globaux et le mettre dans le calcul",
    "DEFI_COMPOR_MONOCRISTAL_FAMI_SYST_GLIS": "Famille de système de glissement supprimée : choisir une autre famille",
    "DEFI_COMPOR_MULTIFIBRE_DEFORMATION": "Il faut maintenant renseigner le mot-clé DEFORMATION dans STAT_NON_LINE ou DYNA_NON_LINE.",
    "DEFI_MATERIAU_ECRO_FLEJOU": "Le comportement ECRO_FLEJOU a été supprimé. Il faut maintenant utiliser un modèle de poutre multifibres avec une loi d'écrouissage'.",
    "DEFI_MATERIAU_VMIS_POUTRE": "Le comportement VMIS_POUTRE a été supprimé. Il faut maintenant utiliser un modèle de poutre multifibres avec une loi plastique.",
    "DEFI_MATERIAU_VMIS_POUTRE_FO": "Le comportement VMIS_POUTRE_FO a été supprimé. Il faut maintenant utiliser un modèle de poutre multifibres avec une loi plastique.",
    "DEFI_MATERIAU_LEMAITRE_IRRA_GRAN_A": "Les paramètres de la loi de grandissement se définissent maintenant par une fonction avec GRAN_FO.",
    "DEFI_MATERIAU_LEMAITRE_IRRA_GRAN_B": "Les paramètres de la loi de grandissement se définissent maintenant par une fonction avec GRAN_FO.",
    "DEFI_MATERIAU_LEMAITRE_IRRA_GRAN_S": "Les paramètres de la loi de grandissement se définissent maintenant par une fonction avec GRAN_FO.",
    "DEFI_MATERIAU_LMARC_IRRA_GRAN_A": "Les paramètres de la loi de grandissement se définissent maintenant par une fonction avec GRAN_FO.",
    "DEFI_MATERIAU_LMARC_IRRA_GRAN_B": "Les paramètres de la loi de grandissement se définissent maintenant par une fonction avec GRAN_FO.",
    "DEFI_MATERIAU_LMARC_IRRA_GRAN_S": "Les paramètres de la loi de grandissement se définissent maintenant par une fonction avec GRAN_FO.",
    "DEFI_MATERIAU_GRAN_IRRA_LOG_GRAN_A": "Les paramètres de la loi de grandissement se définissent maintenant par une fonction avec GRAN_FO.",
    "DEFI_MATERIAU_GRAN_IRRA_LOG_GRAN_B": "Les paramètres de la loi de grandissement se définissent maintenant par une fonction avec GRAN_FO.",
    "DEFI_MATERIAU_GRAN_IRRA_LOG_GRAN_S": "Les paramètres de la loi de grandissement se définissent maintenant par une fonction avec GRAN_FO.",
    "DEFI_MATERIAU_ENDO_SCALAIRE": "Les paramètres définissant la loi ENDO_SCALAIRE ont changé. Il faut renseigner les nouveaux paramètres.",
    "DEFI_MATERIAU_MAZARS": "Le paramètres BETA définissant la loi MAZARS a été supprimé. Il faut renseigner le nouveau paramètre K.",
    "DEFI_MATERIAU_MONO_VISC3": "Le comportement MONO_VISC3 a été supprimé.",
    "DEFI_MATERIAU_MONO_DD_CC": "Le comportement MONO_DD_CC a été supprimé.",
    "DYNA_LINE_TRAN_INCREMENT_FONC_INST": "Le mot-clé FONC_INST a été supprimé. Il faut maintenant utiliser ",
    "LIRE_RESU_TYPE_RESU": "Il n'est plus possible de lire un résultat de type HARM_GENE. Il faut choisir un autre type.",
    "MACRO_ELAS_MULT_CAS_CHARGE_OPTION": "Seule l'option SIEF_ELGA est permise pour MACRO_ELAS_MULT. Il faut calculer les autres options avec CALC_CHAMP.",
    "MODI_MODELE_XFEM_CONTACT": "La formulation du contact aux arêtes P1P1A a été supprimée. Il faut choisir une autre formulation.",
    "POST_GP": "La commande POST_GP a été supprimée. Il faut maintenant utiliser la commande CALC_GP.",
    "AFFE_CARA_ELEM_COQUE_EPAIS_F": "Il n'est plus possible de faire d'analyse de sensibilité.",
    "AFFE_CARA_ELEM_DISCRET_VALE_F": "Il n'est plus possible de faire d'analyse de sensibilité.",
    "AFFE_CARA_ELEM_DISCRET_2D_VALE_F": "Il n'est plus possible de faire d'analyse de sensibilité.",
    "CALC_CHAMP_REPE_COQUE": "Pour les éléments de structures, les résultats sont calculés sur tous les sous-points. Pour extraire un champ sur un seul sous-point, il faut utiliser POST_CHAMP.",
    "CALC_THETA_THETA_BANDE": "L'option THETA_BANDE n'existe plus, il faut choisir entre THETA_2D ou THETA_3D.",
}

sys.dict_erreurs = dict_erreurs


def traduc(infile, outfile, flog=None):
    hdlr = log.initialise(flog)
    jdc = getJDC(infile, atraiter)
    root = jdc.root

    # Parse les mocles des commandes
    parseKeywords(root)

    genereErreurPourCommande(jdc, ("CALC_SENSI",))

    ####  traitement des cas particuliers   ##############################
    #  On ne traite pas les commandes TEST*
    removeCommande(jdc, "TEST_COMPOR")
    removeCommande(jdc, "TEST_FICHIER")
    removeCommande(jdc, "TEST_FONCTION")
    removeCommande(jdc, "TEST_RESU")
    removeCommande(jdc, "TEST_TABLE")
    removeCommande(jdc, "TEST_TEMPS")

    ####   traitement de AFFE_CARA_ELEM   ##############################
    # Déplacement de PREC_AIRE et PREC_INERTIE dans MULTIFIBRE
    moveMotCleFromFactToFact(jdc, "AFFE_CARA_ELEM", "POUTRE", "PREC_AIRE", "MULTIFIBRE")
    removeMotCleInFact(jdc, "AFFE_CARA_ELEM", "POUTRE", "PREC_AIRE", pasDeRegle(), 0)
    moveMotCleFromFactToFact(
        jdc, "AFFE_CARA_ELEM", "POUTRE", "PREC_INERTIE", "MULTIFIBRE"
    )
    removeMotCleInFact(jdc, "AFFE_CARA_ELEM", "POUTRE", "PREC_INERTIE", pasDeRegle(), 0)
    # Résorption de la sensibilité
    genereErreurMotCleInFact(jdc, "AFFE_CARA_ELEM", "COQUE", "EPAIS_F")
    genereErreurMotCleInFact(jdc, "AFFE_CARA_ELEM", "DISCRET", "VALE_F")
    genereErreurMotCleInFact(jdc, "AFFE_CARA_ELEM", "DISCRET_2D", "VALE_F")
    # Suppression de GRILLE_NCOU
    removeMotCleInFact(jdc, "AFFE_CARA_ELEM", "GRILLE", "GRILLE_NCOU", pasDeRegle(), 0)
    # Suppression de ORIG_AXE
    removeMotCleInFact(jdc, "AFFE_CARA_ELEM", "GRILLE", "ORIG_AXE", pasDeRegle(), 0)

    ####   traitement de AFFE_CHAR_MECA/_F  ##############################
    renameMotCle(jdc, "AFFE_CHAR_MECA", "SIGM_INTERNE", "PRE_SIGM")
    renameMotCle(jdc, "AFFE_CHAR_MECA", "EPSI_INIT", "PRE_EPSI")
    renameMotCle(jdc, "AFFE_CHAR_MECA_F", "SIGM_INTERNE", "PRE_SIGM")
    renameMotCle(jdc, "AFFE_CHAR_MECA_F", "EPSI_INIT", "PRE_EPSI")

    ####   traitement de AFFE_CHAR_OPS011   ##############################
    genereErreurPourCommande(jdc, ("AFFE_CHAR_OPS011",))

    ####   traitement de AFFE_CHAR_THER/_F  ##############################
    renameMotCle(jdc, "AFFE_CHAR_THER", "GRAD_TEMP_INIT", "PRE_GRAD_TEMP")
    renameMotCle(jdc, "AFFE_CHAR_THER_F", "GRAD_TEMP_INIT", "PRE_GRAD_TEMP")

    ####   traitement de AFFE_MATERIAU   ##############################
    # VALE_REF obligatoire si NOM_VARC in ('TEMP', 'SECH')
    lNOMVARC = ["CORR", "IRRA", "HYDR", "EPSA", "M_ACIER", "M_ZIRC", "NEUT1", "NEUT2"]
    removeMotCleInFactSiRegle(
        jdc,
        "AFFE_MATERIAU",
        "AFFE_VARC",
        "VALE_REF",
        ((("NOM_VARC", lNOMVARC, jdc), "MCsousMCFcourantaPourValeurDansListe"),),
    )
    # renommage CHAMP_GD en CHAM_GD
    renameMotCleInFact(
        jdc, "AFFE_MATERIAU", "AFFE_VARC", "CHAMP_GD", "CHAM_GD", pasDeRegle(), 0
    )

    ####   traitement de AFFE_MODELE   ##############################
    dXFEMCONT = {
        "3D_XFEM_CONT": "3D",
        "C_PLAN_XFEM_CONT": "C_PLAN",
        "D_PLAN_XFEM_CONT": "D_PLAN",
    }
    changementValeurDsMCF(jdc, "AFFE_MODELE", "AFFE", "MODELISATION", dXFEMCONT)

    ####   traitement de ASSE_ELEM_SSD   ##############################
    # Rien à faire

    ####   traitement de ASSEMBLAGE   ##############################
    # Rien à faire, n'existe pas en 10

    ####   traitement de C_COMP_INCR   ##############################
    # Suppression de ALGO_C_PLAN et ALGO_1D
    lCOMMANDE = [
        "CALC_FORC_NONL",
        "CALC_IFS_DNL",
        "CALC_POINT_MAT",
        "CALC_PRECONT",
        "CALCUL",
        "DYNA_NON_LINE",
        "LIRE_RESU",
        "MACR_ECREVISSE",
        "SIMU_POINT_MAT",
        "STAT_NON_LINE",
        "TEST_COMPOR",
    ]
    for com in lCOMMANDE:
        removeMotCleInFact(jdc, com, "COMP_INCR", "ALGO_C_PLAN", pasDeRegle(), 0)
        removeMotCleInFact(jdc, com, "COMP_INCR", "ALGO_1D", pasDeRegle(), 0)
        renameMotCleInFact(
            jdc, com, "COMP_INCR", "RESI_DEBO_MAXI", "RESI_CPLAN_MAXI", pasDeRegle(), 0
        )
        renameMotCleInFact(
            jdc, com, "COMP_INCR", "RESI_DEBO_RELA", "RESI_CPLAN_RELA", pasDeRegle(), 0
        )
        renameMotCleInFact(
            jdc,
            com,
            "COMP_INCR",
            "ITER_MAXI_DEBORST",
            "ITER_CPLAN_MAXI",
            pasDeRegle(),
            0,
        )

    ####   traitement de C_NEWTON   ##############################
    # Renommage de EXTRAPOL en EXTRAPOLE
    lCOMMANDE = [
        "CALC_IFS_DNL",
        "CALC_POINT_MAT",
        "CALC_PRECONT",
        "DYNA_NON_LINE",
        "MACR_ASCOUF_CALC",
        "MACR_ASPIC_CALC",
        "SIMU_POINT_MAT",
        "STAT_NON_LINE",
        "TEST_COMPOR",
    ]
    dPRED = {"EXTRAPOL": "EXTRAPOLE"}
    for com in lCOMMANDE:
        changementValeurDsMCF(jdc, com, "NEWTON", "PREDICTION", dPRED)

    ####   traitement de C_SOLVEUR   ##############################
    # Renommage de EXTRAPOL en EXTRAPOLE
    lCOMMANDE = [
        "CALC_ELEM",
        "CALC_FORC_AJOU",
        "CALC_IFS_DNL",
        "CALC_MATR_AJOU",
        "CALC_PRECONT",
        "CREA_ELEM_SSD",
        "DEFI_BASE_MODALE",
        "DYNA_LINE_HARM",
        "DYNA_LINE_HARM",
        "DYNA_LINE_TRAN",
        "DYNA_NON_LINE",
        "DYNA_TRAN_MODAL",
        "IMPR_STURM",
        "MACR_ASCOUF_CALC",
        "MACR_ASPIC_CALC",
        "MACRO_ELAS_MULT",
        "MACRO_MATR_AJOU",
        "MACRO_MATR_ASSE",
        "MECA_STATIQUE",
        "MODE_ITER_INV",
        "MODE_ITER_INV",
        "MODE_ITER_SIMULT",
        "MODE_ITER_SIMULT",
        "MODE_STATIQUE",
        "STAT_NON_LINE",
        "THER_LINEAIRE",
        "THER_NON_LINE",
        "THER_NON_LINE_MO",
    ]
    dPRED = {"EXTRAPOL": "EXTRAPOLE"}
    for com in lCOMMANDE:
        removeMotCleInFact(jdc, com, "SOLVEUR", "OUT_OF_CORE", pasDeRegle(), 0)
        removeMotCleInFact(jdc, com, "SOLVEUR", "LIBERE_MEMOIRE", pasDeRegle(), 0)

    ####   traitement de CALC_CHAMP   ##############################
    # Rien à faire, n'existe pas en 10

    ####   traitement de CALC_ECREVISSE   ##############################
    # Rien à faire

    ####   traitement de CALC_ELEM   ##############################
    # renommage de la commande
    renameCommande(
        jdc,
        "CALC_ELEM",
        "CALC_CHAMP",
    )
    # Suppression des types de charges
    removeMotCleInFact(jdc, "CALC_CHAMP", "EXCIT", "TYPE_CHARGE", pasDeRegle(), 0)
    # Suppression des types d'option'
    removeMotCle(jdc, "CALC_CHAMP", "TYPE_OPTION", pasDeRegle(), 0)
    # Redistribution des options de calcul
    ## dictionnaire contenant les options
    lTOUT = [
        "SIEF_ELNO",
        "SIGM_ELNO",
        "SIEF_ELGA",
        "SIPO_ELNO",
        "EFGE_ELNO",
        "EFCA_ELNO",
        "SICA_ELNO",
        "SIRO_ELEM",
        "SIPM_ELNO",
        "SIRO_ELEM",
        "EFCA_ELNO",
        "SIPO_ELNO",
        "SIPM_ELNO",
        "EPTU_ELNO",
        "SITU_ELNO",
        "SICO_ELNO",
        "EPSI_ELNO",
        "EPSI_ELGA",
        "EPSG_ELNO",
        "EPSG_ELGA",
        "EPME_ELNO",
        "EPME_ELGA",
        "EPMG_ELNO",
        "EPMG_ELGA",
        "DEGE_ELNO",
        "EPTU_ELNO",
        "EPSP_ELNO",
        "EPSP_ELGA",
        "EPFD_ELNO",
        "EPFD_ELGA",
        "EPVC_ELNO",
        "EPVC_ELGA",
        "EPFP_ELNO",
        "EPFP_ELGA",
        "EPOT_ELEM",
        "ECIN_ELEM",
        "ENEL_ELGA",
        "ENEL_ELNO",
        "ETOT_ELGA",
        "ETOT_ELNO",
        "ETOT_ELEM",
        "DISS_ELGA",
        "DISS_ELNO",
        "SIEQ_ELNO",
        "SIEQ_ELGA",
        "CRIT_ELNO",
        "EPEQ_ELNO",
        "EPEQ_ELGA",
        "EPMQ_ELNO",
        "EPMQ_ELGA",
        "ENDO_ELGA",
        "ENDO_ELNO",
        "SITQ_ELNO",
        "EPTQ_ELNO",
        "INDL_ELGA",
        "DERA_ELNO",
        "DERA_ELGA",
        "SITQ_ELNO",
        "EPTQ_ELNO",
        "VARI_ELNO",
        "VATU_ELNO",
        "VACO_ELNO",
        "VARC_ELGA",
        "VAEX_ELGA",
        "VAEX_ELNO",
        "FLHN_ELGA",
        "FLUX_ELGA",
        "FLUX_ELNO",
        "SOUR_ELGA",
        "INTE_ELNO",
        "PRAC_ELNO",
        "SIZ1_NOEU",
        "ERZ1_ELEM",
        "SIZ2_NOEU",
        "ERZ2_ELEM",
        "ERME_ELEM",
        "ERME_ELNO",
        "ERTH_ELEM",
        "ERTH_ELNO",
        "QIRE_ELEM",
        "QIRE_ELNO",
        "QIZ1_ELEM",
        "QIZ2_ELEM",
        "SING_ELEM",
        "SING_ELNO",
        "DURT_ELNO",
    ]
    lCONTRAINTE = [
        "SIEF_ELNO",
        "SIGM_ELNO",
        "SIEF_ELGA",
        "SIPO_ELNO",
        "EFGE_ELNO",
        "EFCA_ELNO",
        "SICA_ELNO",
        "SIRO_ELEM",
        "SIPM_ELNO",
        "SIRO_ELEM",
        "EFCA_ELNO",
        "SIPO_ELNO",
        "SIPM_ELNO",
        "EPTU_ELNO",
        "SITU_ELNO",
        "SICO_ELNO",
    ]
    lDEFORMATION = [
        "EPSI_ELNO",
        "EPSI_ELGA",
        "EPSG_ELNO",
        "EPSG_ELGA",
        "EPME_ELNO",
        "EPME_ELGA",
        "EPMG_ELNO",
        "EPMG_ELGA",
        "DEGE_ELNO",
        "EPTU_ELNO",
        "EPSP_ELNO",
        "EPSP_ELGA",
        "EPFD_ELNO",
        "EPFD_ELGA",
        "EPVC_ELNO",
        "EPVC_ELGA",
        "EPFP_ELNO",
        "EPFP_ELGA",
    ]
    lENERGIE = [
        "EPOT_ELEM",
        "ECIN_ELEM",
        "ENEL_ELGA",
        "ENEL_ELNO",
        "ETOT_ELGA",
        "ETOT_ELNO",
        "ETOT_ELEM",
        "DISS_ELGA",
        "DISS_ELNO",
    ]
    lCRITERES = [
        "SIEQ_ELNO",
        "SIEQ_ELGA",
        "CRIT_ELNO",
        "EPEQ_ELNO",
        "EPEQ_ELGA",
        "EPMQ_ELNO",
        "EPMQ_ELGA",
        "ENDO_ELGA",
        "ENDO_ELNO",
        "SITQ_ELNO",
        "EPTQ_ELNO",
        "INDL_ELGA",
        "DERA_ELNO",
        "DERA_ELGA",
        "SITQ_ELNO",
        "EPTQ_ELNO",
    ]
    lVARI_INTERNE = [
        "VARI_ELNO",
        "VATU_ELNO",
        "VACO_ELNO",
        "VARC_ELGA",
        "VAEX_ELGA",
        "VAEX_ELNO",
    ]
    lHYDRAULIQUE = [
        "FLHN_ELGA",
    ]
    lTHERMIQUE = [
        "FLUX_ELGA",
        "FLUX_ELNO",
        "SOUR_ELGA",
    ]
    lACOUSTIQUE = ["INTE_ELNO", "PRAC_ELNO"]
    lERREUR = [
        "SIZ1_NOEU",
        "ERZ1_ELEM",
        "SIZ2_NOEU",
        "ERZ2_ELEM",
        "ERME_ELEM",
        "ERME_ELNO",
        "ERTH_ELEM",
        "ERTH_ELNO",
        "QIRE_ELEM",
        "QIRE_ELNO",
        "QIZ1_ELEM",
        "QIZ2_ELEM",
        "SING_ELEM",
        "SING_ELNO",
    ]
    lMETA = ["DURT_ELNO"]
    # SPMX_ELGA / NOM_CHAM / NOM_CMP
    ## Erreur pour les options supprimées
    genereErreurValeur(
        jdc,
        "CALC_ELEM",
        "OPTION",
        (
            "'SICA_ELNO'",
            "'EFCA_ELNO'",
            "'PMPB_ELNO'",
            "'PMPB_ELGA'",
        ),
    )
    lCHANOPT = {
        "SICO_ELNO": "SIGM_ELNO",
        "EPTU_ELNO": "EPSI_ELNO",
        "SITU_ELNO": "SIGM_ELNO",
        "SITQ_ELNO": "SIGM_ELNO",
        "EPTQ_ELNO": "EPSI_ELNO",
    }
    changementValeur(jdc, "CALC_ELEM", "OPTION", lCHANOPT)
    ## copie de OPTION dans MCF TEMPORAIRE pour chaque type
    chercheOperInsereFacteur(jdc, "CALC_CHAMP", "TEMPORAIRE")
    copyMotClefInOperToFact(jdc, "CALC_CHAMP", "OPTION", "TEMPORAIRE")
    renameMotCleInFact(
        jdc, "CALC_CHAMP", "TEMPORAIRE", "OPTION", "CONTRAINTE", pasDeRegle(), 0
    )
    copyMotClefInOperToFact(jdc, "CALC_CHAMP", "OPTION", "TEMPORAIRE")
    renameMotCleInFact(
        jdc, "CALC_CHAMP", "TEMPORAIRE", "OPTION", "DEFORMATION", pasDeRegle(), 0
    )
    copyMotClefInOperToFact(jdc, "CALC_CHAMP", "OPTION", "TEMPORAIRE")
    renameMotCleInFact(
        jdc, "CALC_CHAMP", "TEMPORAIRE", "OPTION", "ENERGIE", pasDeRegle(), 0
    )
    copyMotClefInOperToFact(jdc, "CALC_CHAMP", "OPTION", "TEMPORAIRE")
    renameMotCleInFact(
        jdc, "CALC_CHAMP", "TEMPORAIRE", "OPTION", "CRITERES", pasDeRegle(), 0
    )
    copyMotClefInOperToFact(jdc, "CALC_CHAMP", "OPTION", "TEMPORAIRE")
    renameMotCleInFact(
        jdc, "CALC_CHAMP", "TEMPORAIRE", "OPTION", "VARI_INTERNE", pasDeRegle(), 0
    )
    copyMotClefInOperToFact(jdc, "CALC_CHAMP", "OPTION", "TEMPORAIRE")
    renameMotCleInFact(
        jdc, "CALC_CHAMP", "TEMPORAIRE", "OPTION", "HYDRAULIQUE", pasDeRegle(), 0
    )
    copyMotClefInOperToFact(jdc, "CALC_CHAMP", "OPTION", "TEMPORAIRE")
    renameMotCleInFact(
        jdc, "CALC_CHAMP", "TEMPORAIRE", "OPTION", "THERMIQUE", pasDeRegle(), 0
    )
    copyMotClefInOperToFact(jdc, "CALC_CHAMP", "OPTION", "TEMPORAIRE")
    renameMotCleInFact(
        jdc, "CALC_CHAMP", "TEMPORAIRE", "OPTION", "ACOUSTIQUE", pasDeRegle(), 0
    )
    copyMotClefInOperToFact(jdc, "CALC_CHAMP", "OPTION", "TEMPORAIRE")
    renameMotCleInFact(
        jdc, "CALC_CHAMP", "TEMPORAIRE", "OPTION", "ERREUR", pasDeRegle(), 0
    )
    copyMotClefInOperToFact(jdc, "CALC_CHAMP", "OPTION", "TEMPORAIRE")
    renameMotCleInFact(
        jdc, "CALC_CHAMP", "TEMPORAIRE", "OPTION", "META", pasDeRegle(), 0
    )
    removeMotCle(jdc, "CALC_CHAMP", "OPTION", pasDeRegle(), 0)
    ## déplacement au premier niveau de mot-clés
    moveMotCleFromFactToFather(jdc, "CALC_CHAMP", "TEMPORAIRE", "CONTRAINTE")
    moveMotCleFromFactToFather(jdc, "CALC_CHAMP", "TEMPORAIRE", "DEFORMATION")
    moveMotCleFromFactToFather(jdc, "CALC_CHAMP", "TEMPORAIRE", "ENERGIE")
    moveMotCleFromFactToFather(jdc, "CALC_CHAMP", "TEMPORAIRE", "CRITERES")
    moveMotCleFromFactToFather(jdc, "CALC_CHAMP", "TEMPORAIRE", "VARI_INTERNE")
    moveMotCleFromFactToFather(jdc, "CALC_CHAMP", "TEMPORAIRE", "HYDRAULIQUE")
    moveMotCleFromFactToFather(jdc, "CALC_CHAMP", "TEMPORAIRE", "THERMIQUE")
    moveMotCleFromFactToFather(jdc, "CALC_CHAMP", "TEMPORAIRE", "ACOUSTIQUE")
    moveMotCleFromFactToFather(jdc, "CALC_CHAMP", "TEMPORAIRE", "ERREUR")
    moveMotCleFromFactToFather(jdc, "CALC_CHAMP", "TEMPORAIRE", "META")
    ## suppression des mot-clés s'ils ne contiennent pas d'options à traiter
    removeMotCleSiRegle(
        jdc,
        "CALC_CHAMP",
        "CONTRAINTE",
        ((("CONTRAINTE", lCONTRAINTE, jdc), "MCnaPasPourValeurDansListe"),),
    )
    removeMotCleSiRegle(
        jdc,
        "CALC_CHAMP",
        "DEFORMATION",
        ((("DEFORMATION", lDEFORMATION, jdc), "MCnaPasPourValeurDansListe"),),
    )
    removeMotCleSiRegle(
        jdc,
        "CALC_CHAMP",
        "ENERGIE",
        ((("ENERGIE", lENERGIE, jdc), "MCnaPasPourValeurDansListe"),),
    )
    removeMotCleSiRegle(
        jdc,
        "CALC_CHAMP",
        "CRITERES",
        ((("CRITERES", lCRITERES, jdc), "MCnaPasPourValeurDansListe"),),
    )
    removeMotCleSiRegle(
        jdc,
        "CALC_CHAMP",
        "VARI_INTERNE",
        ((("VARI_INTERNE", lVARI_INTERNE, jdc), "MCnaPasPourValeurDansListe"),),
    )
    removeMotCleSiRegle(
        jdc,
        "CALC_CHAMP",
        "HYDRAULIQUE",
        ((("HYDRAULIQUE", lHYDRAULIQUE, jdc), "MCnaPasPourValeurDansListe"),),
    )
    removeMotCleSiRegle(
        jdc,
        "CALC_CHAMP",
        "THERMIQUE",
        ((("THERMIQUE", lTHERMIQUE, jdc), "MCnaPasPourValeurDansListe"),),
    )
    removeMotCleSiRegle(
        jdc,
        "CALC_CHAMP",
        "ACOUSTIQUE",
        ((("ACOUSTIQUE", lACOUSTIQUE, jdc), "MCnaPasPourValeurDansListe"),),
    )
    removeMotCleSiRegle(
        jdc,
        "CALC_CHAMP",
        "ERREUR",
        ((("ERREUR", lERREUR, jdc), "MCnaPasPourValeurDansListe"),),
    )
    removeMotCleSiRegle(
        jdc,
        "CALC_CHAMP",
        "META",
        ((("META", lMETA, jdc), "MCnaPasPourValeurDansListe"),),
    )
    ## suppression des valeurs non-licites
    suppressionValeurs(
        jdc, "CALC_CHAMP", "CONTRAINTE", list(set(lTOUT) - set(lCONTRAINTE))
    )
    suppressionValeurs(
        jdc, "CALC_CHAMP", "DEFORMATION", list(set(lTOUT) - set(lDEFORMATION))
    )
    suppressionValeurs(jdc, "CALC_CHAMP", "ENERGIE", list(set(lTOUT) - set(lENERGIE)))
    suppressionValeurs(jdc, "CALC_CHAMP", "CRITERES", list(set(lTOUT) - set(lCRITERES)))
    suppressionValeurs(
        jdc, "CALC_CHAMP", "VARI_INTERNE", list(set(lTOUT) - set(lVARI_INTERNE))
    )
    suppressionValeurs(
        jdc, "CALC_CHAMP", "HYDRAULIQUE", list(set(lTOUT) - set(lHYDRAULIQUE))
    )
    suppressionValeurs(
        jdc, "CALC_CHAMP", "THERMIQUE", list(set(lTOUT) - set(lTHERMIQUE))
    )
    suppressionValeurs(
        jdc, "CALC_CHAMP", "ACOUSTIQUE", list(set(lTOUT) - set(lACOUSTIQUE))
    )
    suppressionValeurs(jdc, "CALC_CHAMP", "ERREUR", list(set(lTOUT) - set(lERREUR)))
    suppressionValeurs(jdc, "CALC_CHAMP", "META", list(set(lTOUT) - set(lMETA)))
    ## ajout CALC_META ou CALC_ERREUR
    lMOTCLE = []
    lMOTCLE = [
        "reuse",
        "RESULTAT",
        "TOUT_ORDRE",
        "NUME_ORDRE",
        "NUME_MODE",
        "NOEUD_CMP",
        "NOM_CAS",
        "INST",
        "FREQ",
        "LIST_INST",
        "LIST_FREQ",
        "LIST_ORDRE",
        "CRITERE",
        "PRECISION",
        "EXCIT",
    ]
    ### traitement métallurgie
    llistMETA = []
    llistMETA = list(lMOTCLE)
    llistMETA.extend(
        [
            "META",
        ]
    )
    for mc in llistMETA:
        copyMotClefInOperToFact(jdc, "CALC_CHAMP", mc, "TEMPORAIRE")
    moveMCFToCommand(jdc, "CALC_CHAMP", "TEMPORAIRE", "CALC_META", "TEMPORAIRE")
    for mc in llistMETA:
        moveMotCleFromFactToFather(jdc, "CALC_META", "TEMPORAIRE", mc)
    removeCommandeSiRegle(
        jdc, "CALC_META", ((("META", "COMP_INCR", "ETAT_INIT"), "nexistepasMCFParmi"),)
    )
    renameMotCle(jdc, "CALC_META", "META", "OPTION")
    removeMotCle(jdc, "CALC_META", "TEMPORAIRE", pasDeRegle(), 0)
    removeMotCle(jdc, "CALC_CHAMP", "TEMPORAIRE", pasDeRegle(), 0)
    ### traitement calcul d'erreur
    llistERREUR = []
    llistERREUR = list(lMOTCLE)
    llistERREUR.extend(["ERREUR", "SOLVEUR", "RESU_DUAL", "PREC_ESTI", "TYPE_ESTI"])
    for mc in llistERREUR:
        copyMotClefInOperToFact(jdc, "CALC_CHAMP", mc, "TEMPORAIRE")
    moveMCFToCommand(jdc, "CALC_CHAMP", "TEMPORAIRE", "CALC_ERREUR", "TEMPORAIRE")
    for mc in llistERREUR:
        moveMotCleFromFactToFather(jdc, "CALC_ERREUR", "TEMPORAIRE", mc)
    removeCommandeSiRegle(jdc, "CALC_ERREUR", ((("ERREUR"), "nexistepasMCFParmi"),))
    renameMotCle(jdc, "CALC_ERREUR", "ERREUR", "OPTION")
    removeMotCle(jdc, "CALC_ERREUR", "TEMPORAIRE", pasDeRegle(), 0)
    removeMotCle(jdc, "CALC_CHAMP", "TEMPORAIRE", pasDeRegle(), 0)
    ### traitement de REPE_COQUE
    removeMotCle(jdc, "CALC_CHAMP", "REPE_COQUE", pasDeRegle(), 1)
    ## ménage final
    removeCommandeSiRegle(
        jdc,
        "CALC_CHAMP",
        (
            (
                (
                    "CONTRAINTE",
                    "DEFORMATION",
                    "ENERGIE",
                    "CRITERES",
                    "VARI_INTERNE",
                    "HYDRAULIQUE",
                    "THERMIQUE",
                    "ACOUSTIQUE",
                ),
                "nexistepasMCFParmi",
            ),
        ),
    )
    removeMotCle(jdc, "CALC_CHAMP", "META", pasDeRegle(), 0)
    removeMotCle(jdc, "CALC_CHAMP", "ERREUR", pasDeRegle(), 0)

    ####   traitement de CALC_ERREUR   ##############################
    # Rien à faire, n'existe pas en 10

    ####   traitement de CALC_ESSAI   ##############################
    # Rien à faire

    ####   traitement de CALC_EUROPLEXUS   ##############################
    # Rien à faire

    ####   traitement de CALC_FATIGUE   ##############################
    # Rien à faire

    ####   traitement de CALC_FERRAILLAGE   ##############################
    # Rien à faire

    ####   traitement de CALC_FONCTION   ##############################
    # Rien à faire

    ####   traitement de CALC_FORC_AJOU   ##############################
    # Rien à faire

    ####   traitement de CALC_G   ##############################
    # Suppression SYME_CHAR
    removeMotCle(jdc, "CALC_G", "SYME_CHAR", pasDeRegle(), 0)
    # Règle sur DEGRE
    removeMotCleInFactSiRegle(
        jdc,
        "CALC_G",
        "LISSAGE",
        "DEGRE",
        (
            (("LISSAGE_THETA", "LEGENDRE", jdc), "MCnaPasPourValeur")
            or (("LISSAGE_G", "LEGENDRE", jdc), "MCnaPasPourValeur"),
        ),
    )
    # Suppression de DTAN_ORIG et DTAN_EXTR pour calcul automatique
    removeMotCleInFact(jdc, "CALC_G", "THETA", "DTAN_ORIG", pasDeRegle(), 1)
    removeMotCleInFact(jdc, "CALC_G", "THETA", "DTAN_EXTR", pasDeRegle(), 1)
    # Résorption de la sensibilité
    removeMotCle(jdc, "CALC_G", "SENSIBILITE", pasDeRegle(), 0)
    # Restriction de ETAT_INIT à SIGM_INIT sous COMP_INCR
    moveMotCleFromFactToFact(jdc, "CALC_G", "ETAT_INIT", "SIGM", "COMP_INCR")
    renameMotCleInFact(jdc, "CALC_G", "COMP_INCR", "SIGM", "SIGM_INIT", pasDeRegle(), 0)
    removeMotCleInFactSiRegle(
        jdc,
        "CALC_G",
        "COMP_INCR",
        "SIGM_INIT",
        ((("RELATION", "ELAS", jdc), "MCnaPasPourValeur"),),
    )
    removeMotCle(jdc, "CALC_G", "ETAT_INIT", pasDeRegle(), 0)
    # Renommage de l'option K_G_MODA en CALC_K_G
    changementValeur(
        jdc,
        "CALC_G",
        "OPTION",
        {
            "K_G_MODA": "CALC_K_G",
        },
    )
    # Suppression de EXCIT dans le cas elas_mult
    removeMotCleSiRegle(jdc, "CALC_G", "EXCIT", ((("NOM_CAS",), "existe"),))
    # Ajout règle UN_PARMI('THETA','FOND_FISS','FISSURE')
    removeMotCleInFactSiRegle(
        jdc,
        "CALC_G",
        "THETA",
        "THETA",
        (
            (
                (
                    "THETA",
                    "FOND_FISS",
                ),
                "existeMCsousMCF",
            ),
        ),
    )
    removeMotCleInFactSiRegle(
        jdc,
        "CALC_G",
        "THETA",
        "THETA",
        (
            (
                (
                    "THETA",
                    "FISSURE",
                ),
                "existeMCsousMCF",
            ),
        ),
    )

    ####   traitement de CALC_IFS_DNL   ##############################
    # Renommage CRIT_FLAMB en CRIT_STAB
    renameMotCle(jdc, "CALC_IFS_DNL", "CRIT_FLAMB", "CRIT_STAB")
    removeMotCleInFact(
        jdc, "CALC_IFS_DNL", "CRIT_FLAMB", "INST_CALCUL", pasDeRegle(), 1
    )
    # Résorption de la sensibilité
    removeMotCle(jdc, "CALC_IFS_DNL", "SENSIBILITE", pasDeRegle(), 0)
    # Suppression de ARCHIVAGE/DETR_NUME_SUIV
    removeMotCleInFact(
        jdc, "CALC_IFS_DNL", "ARCHIVAGE", "DETR_NUME_SUIV", pasDeRegle(), 0
    )

    ####   traitement de CALC_INTE_SPEC   ##############################
    # Rien à faire

    ####   traitement de CALC_MAC3COEUR   ##############################
    # Rien à faire, n'existe pas en 10

    ####   traitement de CALC_MATR_AJOU   ##############################
    # Suppression d'algo pour PETSc
    removeMotCleSiRegle(
        jdc,
        "RESOUDRE",
        "ALGORITHME",
        (
            (
                (
                    "BCGS",
                    "BICG",
                    "TFQMR",
                ),
                "MCaPourValeur",
            ),
        ),
    )

    ####   traitement de CALC_MATR_ELEM   ##############################
    # Rien à faire

    ####   traitement de CALC_META   ##############################
    # OPTION est obligatoire
    chercheOperInsereFacteurSiRegle(
        jdc, "CALC_META", "OPTION='META_ELNO'", ((("OPTION",), "nexistepas"),), 0
    )

    ####   traitement de CALC_MISS   ##############################
    # Suppression de TYPE_CHARGE
    removeMotCle(jdc, "CALC_MISS", "TYPE_CHARGE", pasDeRegle(), 0)

    ####   traitement de CALC_MODAL   ##############################
    # renommage de STOP_FREQ_VIDE
    renameMotCle(jdc, "CALC_MODAL", "STOP_FREQ_VIDE", "STOP_BANDE_VIDE")

    ####   traitement de CALC_MODE_ROTATION   ##############################
    # renommage de MATR_A et MATR_B
    renameMotCle(jdc, "CALC_MODE_ROTATION", "MATR_A", "MATR_RIGI")
    renameMotCle(jdc, "CALC_MODE_ROTATION", "MATR_B", "MATR_MASS")

    ####   traitement de CALC_NO   ##############################
    # renommage de la commande
    renameCommande(
        jdc,
        "CALC_NO",
        "CALC_CHAMPNO",
    )
    # Suppression des types de charges
    removeMotCleInFact(jdc, "CALC_CHAMPNO", "EXCIT", "TYPE_CHARGE", pasDeRegle(), 0)
    # Redistribution des options de calcul
    ## dictionnaire contenant les options
    lTOUT = [
        "FORC_NODA",
        "REAC_NODA",
        "DERA_NOEU",
        "DURT_NOEU",
        "EFCA_NOEU",
        "EFGE_NOEU",
        "ENDO_NOEU",
        "ENEL_NOEU",
        "EPMG_NOEU",
        "EPSG_NOEU",
        "EPSI_NOEU",
        "EPSP_NOEU",
        "EPVC_NOEU",
        "EPFD_NOEU",
        "EPFP_NOEU",
        "EPMQ_NOEU",
        "EPEQ_NOEU",
        "SIEQ_NOEU",
        "ERME_NOEU",
        "ERTH_NOEU",
        "QIRE_NOEU",
        "FLUX_NOEU",
        "HYDR_NOEU",
        "INTE_NOEU",
        "META_NOEU",
        "PMPB_NOEU",
        "PRAC_NOEU",
        "SIEF_NOEU",
        "SICA_NOEU",
        "SICO_NOEU",
        "SIGM_NOEU",
        "SIPO_NOEU",
        "VAEX_NOEU",
        "VARI_NOEU",
        "DISS_NOEU",
    ]
    lCONTRAINTE = [
        "EFCA_NOEU",
        "EFGE_NOEU",
        "SIEF_NOEU",
        "SICA_NOEU",
        "SICO_NOEU",
        "SIGM_NOEU",
        "SIPO_NOEU",
    ]
    lDEFORMATION = [
        "EPMG_NOEU",
        "EPSG_NOEU",
        "EPSI_NOEU",
        "EPSP_NOEU",
        "EPVC_NOEU",
        "EPFD_NOEU",
        "EPFP_NOEU",
    ]
    lENERGIE = [
        "ENEL_NOEU",
        "DISS_NOEU",
    ]
    lCRITERES = [
        "DERA_NOEU",
        "ENDO_NOEU",
        "EPEQ_NOEU",
        "EPMQ_NOEU",
        "SIEQ_NOEU",
        "PMPB_NOEU",
    ]
    lVARI_INTERNE = [
        "VAEX_NOEU",
        "VARI_NOEU",
    ]
    lTHERMIQUE = [
        "FLUX_NOEU",
        "HYDR_NOEU",
    ]
    lACOUSTIQUE = [
        "INTE_NOEU",
        "PRAC_NOEU",
    ]
    lFORCE = [
        "FORC_NODA",
        "REAC_NODA",
    ]
    lERREUR = [
        "ERME_NOEU",
        "ERTH_NOEU",
        "QIRE_NOEU",
    ]
    lMETA = [
        "DURT_NOEU",
        "META_NOEU",
    ]
    ## Erreur pour les options supprimées
    genereErreurValeur(
        jdc,
        "CALC_CHAMPNO",
        "OPTION",
        (
            "'SICA_NOEU'",
            "'EFCA_NOEU'",
            "'PMPB_NOEU'",
        ),
    )
    changementValeur(
        jdc,
        "CALC_CHAMPNO",
        "OPTION",
        {
            "SICO_NOEU": "SIGM_NOEU",
        },
    )
    ## copie de OPTION dans MCF TEMPORAIRE pour chaque type
    chercheOperInsereFacteur(jdc, "CALC_CHAMPNO", "TEMPORAIRE")
    copyMotClefInOperToFact(jdc, "CALC_CHAMPNO", "OPTION", "TEMPORAIRE")
    renameMotCleInFact(
        jdc, "CALC_CHAMPNO", "TEMPORAIRE", "OPTION", "CONTRAINTE", pasDeRegle(), 0
    )
    copyMotClefInOperToFact(jdc, "CALC_CHAMPNO", "OPTION", "TEMPORAIRE")
    renameMotCleInFact(
        jdc, "CALC_CHAMPNO", "TEMPORAIRE", "OPTION", "DEFORMATION", pasDeRegle(), 0
    )
    copyMotClefInOperToFact(jdc, "CALC_CHAMPNO", "OPTION", "TEMPORAIRE")
    renameMotCleInFact(
        jdc, "CALC_CHAMPNO", "TEMPORAIRE", "OPTION", "ENERGIE", pasDeRegle(), 0
    )
    copyMotClefInOperToFact(jdc, "CALC_CHAMPNO", "OPTION", "TEMPORAIRE")
    renameMotCleInFact(
        jdc, "CALC_CHAMPNO", "TEMPORAIRE", "OPTION", "CRITERES", pasDeRegle(), 0
    )
    copyMotClefInOperToFact(jdc, "CALC_CHAMPNO", "OPTION", "TEMPORAIRE")
    renameMotCleInFact(
        jdc, "CALC_CHAMPNO", "TEMPORAIRE", "OPTION", "VARI_INTERNE", pasDeRegle(), 0
    )
    copyMotClefInOperToFact(jdc, "CALC_CHAMPNO", "OPTION", "TEMPORAIRE")
    renameMotCleInFact(
        jdc, "CALC_CHAMPNO", "TEMPORAIRE", "OPTION", "THERMIQUE", pasDeRegle(), 0
    )
    copyMotClefInOperToFact(jdc, "CALC_CHAMPNO", "OPTION", "TEMPORAIRE")
    renameMotCleInFact(
        jdc, "CALC_CHAMPNO", "TEMPORAIRE", "OPTION", "ACOUSTIQUE", pasDeRegle(), 0
    )
    copyMotClefInOperToFact(jdc, "CALC_CHAMPNO", "OPTION", "TEMPORAIRE")
    renameMotCleInFact(
        jdc, "CALC_CHAMPNO", "TEMPORAIRE", "OPTION", "FORCE", pasDeRegle(), 0
    )
    copyMotClefInOperToFact(jdc, "CALC_CHAMPNO", "OPTION", "TEMPORAIRE")
    renameMotCleInFact(
        jdc, "CALC_CHAMPNO", "TEMPORAIRE", "OPTION", "ERREUR", pasDeRegle(), 0
    )
    copyMotClefInOperToFact(jdc, "CALC_CHAMPNO", "OPTION", "TEMPORAIRE")
    renameMotCleInFact(
        jdc, "CALC_CHAMPNO", "TEMPORAIRE", "OPTION", "META", pasDeRegle(), 0
    )
    removeMotCle(jdc, "CALC_CHAMPNO", "OPTION", pasDeRegle(), 0)
    ## déplacement au premier niveau de mot-clés
    moveMotCleFromFactToFather(jdc, "CALC_CHAMPNO", "TEMPORAIRE", "CONTRAINTE")
    moveMotCleFromFactToFather(jdc, "CALC_CHAMPNO", "TEMPORAIRE", "DEFORMATION")
    moveMotCleFromFactToFather(jdc, "CALC_CHAMPNO", "TEMPORAIRE", "ENERGIE")
    moveMotCleFromFactToFather(jdc, "CALC_CHAMPNO", "TEMPORAIRE", "CRITERES")
    moveMotCleFromFactToFather(jdc, "CALC_CHAMPNO", "TEMPORAIRE", "VARI_INTERNE")
    moveMotCleFromFactToFather(jdc, "CALC_CHAMPNO", "TEMPORAIRE", "THERMIQUE")
    moveMotCleFromFactToFather(jdc, "CALC_CHAMPNO", "TEMPORAIRE", "ACOUSTIQUE")
    moveMotCleFromFactToFather(jdc, "CALC_CHAMPNO", "TEMPORAIRE", "FORCE")
    moveMotCleFromFactToFather(jdc, "CALC_CHAMPNO", "TEMPORAIRE", "ERREUR")
    moveMotCleFromFactToFather(jdc, "CALC_CHAMPNO", "TEMPORAIRE", "META")
    ## suppression des mot-clés s'ils ne contiennent pas d'options à traiter
    removeMotCleSiRegle(
        jdc,
        "CALC_CHAMPNO",
        "CONTRAINTE",
        ((("CONTRAINTE", lCONTRAINTE, jdc), "MCnaPasPourValeurDansListe"),),
    )
    removeMotCleSiRegle(
        jdc,
        "CALC_CHAMPNO",
        "DEFORMATION",
        ((("DEFORMATION", lDEFORMATION, jdc), "MCnaPasPourValeurDansListe"),),
    )
    removeMotCleSiRegle(
        jdc,
        "CALC_CHAMPNO",
        "ENERGIE",
        ((("ENERGIE", lENERGIE, jdc), "MCnaPasPourValeurDansListe"),),
    )
    removeMotCleSiRegle(
        jdc,
        "CALC_CHAMPNO",
        "CRITERES",
        ((("CRITERES", lCRITERES, jdc), "MCnaPasPourValeurDansListe"),),
    )
    removeMotCleSiRegle(
        jdc,
        "CALC_CHAMPNO",
        "VARI_INTERNE",
        ((("VARI_INTERNE", lVARI_INTERNE, jdc), "MCnaPasPourValeurDansListe"),),
    )
    removeMotCleSiRegle(
        jdc,
        "CALC_CHAMPNO",
        "THERMIQUE",
        ((("THERMIQUE", lTHERMIQUE, jdc), "MCnaPasPourValeurDansListe"),),
    )
    removeMotCleSiRegle(
        jdc,
        "CALC_CHAMPNO",
        "ACOUSTIQUE",
        ((("ACOUSTIQUE", lACOUSTIQUE, jdc), "MCnaPasPourValeurDansListe"),),
    )
    removeMotCleSiRegle(
        jdc,
        "CALC_CHAMPNO",
        "FORCE",
        ((("FORCE", lFORCE, jdc), "MCnaPasPourValeurDansListe"),),
    )
    removeMotCleSiRegle(
        jdc,
        "CALC_CHAMPNO",
        "ERREUR",
        ((("ERREUR", lERREUR, jdc), "MCnaPasPourValeurDansListe"),),
    )
    removeMotCleSiRegle(
        jdc,
        "CALC_CHAMPNO",
        "META",
        ((("META", lMETA, jdc), "MCnaPasPourValeurDansListe"),),
    )
    ## suppression des valeurs non-licites
    suppressionValeurs(
        jdc, "CALC_CHAMPNO", "CONTRAINTE", list(set(lTOUT) - set(lCONTRAINTE))
    )
    suppressionValeurs(
        jdc, "CALC_CHAMPNO", "DEFORMATION", list(set(lTOUT) - set(lDEFORMATION))
    )
    suppressionValeurs(jdc, "CALC_CHAMPNO", "ENERGIE", list(set(lTOUT) - set(lENERGIE)))
    suppressionValeurs(
        jdc, "CALC_CHAMPNO", "CRITERES", list(set(lTOUT) - set(lCRITERES))
    )
    suppressionValeurs(
        jdc, "CALC_CHAMPNO", "VARI_INTERNE", list(set(lTOUT) - set(lVARI_INTERNE))
    )
    suppressionValeurs(
        jdc, "CALC_CHAMPNO", "THERMIQUE", list(set(lTOUT) - set(lTHERMIQUE))
    )
    suppressionValeurs(
        jdc, "CALC_CHAMPNO", "ACOUSTIQUE", list(set(lTOUT) - set(lACOUSTIQUE))
    )
    suppressionValeurs(jdc, "CALC_CHAMPNO", "FORCE", list(set(lTOUT) - set(lFORCE)))
    suppressionValeurs(jdc, "CALC_CHAMPNO", "ERREUR", list(set(lTOUT) - set(lERREUR)))
    suppressionValeurs(jdc, "CALC_CHAMPNO", "META", list(set(lTOUT) - set(lMETA)))
    ## ajout CALC_METANO ou CALC_ERREURNO
    lMOTCLE = []
    lMOTCLE = [
        "reuse",
        "RESULTAT",
        "TOUT_ORDRE",
        "NUME_ORDRE",
        "NUME_MODE",
        "NOEUD_CMP",
        "NOM_CAS",
        "INST",
        "FREQ",
        "LIST_INST",
        "LIST_FREQ",
        "LIST_ORDRE",
        "CRITERE",
        "PRECISION",
        "EXCIT",
    ]
    ### traitement métallurgie
    llistMETA = []
    llistMETA = list(lMOTCLE)
    llistMETA.append("META")
    for mc in llistMETA:
        copyMotClefInOperToFact(jdc, "CALC_CHAMPNO", mc, "TEMPORAIRE")
    moveMCFToCommand(jdc, "CALC_CHAMPNO", "TEMPORAIRE", "CALC_METANO", "TEMPORAIRE")
    for mc in llistMETA:
        moveMotCleFromFactToFather(jdc, "CALC_METANO", "TEMPORAIRE", mc)
    removeCommandeSiRegle(jdc, "CALC_METANO", ((("META"), "nexistepasMCFParmi"),))
    renameMotCle(jdc, "CALC_METANO", "META", "OPTION")
    removeMotCle(jdc, "CALC_METANO", "TEMPORAIRE", pasDeRegle(), 0)
    removeMotCle(jdc, "CALC_CHAMPNO", "TEMPORAIRE", pasDeRegle(), 0)
    ### traitement calcul d'erreur
    llistERREUR = []
    llistERREUR = list(lMOTCLE)
    llistERREUR.append("ERREUR")
    for mc in llistERREUR:
        copyMotClefInOperToFact(jdc, "CALC_CHAMPNO", mc, "TEMPORAIRE")
    moveMCFToCommand(jdc, "CALC_CHAMPNO", "TEMPORAIRE", "CALC_ERREURNO", "TEMPORAIRE")
    for mc in llistERREUR:
        moveMotCleFromFactToFather(jdc, "CALC_ERREURNO", "TEMPORAIRE", mc)
    removeCommandeSiRegle(jdc, "CALC_ERREURNO", ((("ERREUR"), "nexistepasMCFParmi"),))
    renameMotCle(jdc, "CALC_ERREURNO", "ERREUR", "OPTION")
    removeMotCle(jdc, "CALC_ERREURNO", "TEMPORAIRE", pasDeRegle(), 0)
    removeMotCle(jdc, "CALC_CHAMPNO", "TEMPORAIRE", pasDeRegle(), 0)
    ## ménage final
    removeCommandeSiRegle(
        jdc,
        "CALC_CHAMPNO",
        (
            (
                (
                    "CONTRAINTE",
                    "DEFORMATION",
                    "ENERGIE",
                    "CRITERES",
                    "VARI_INTERNE",
                    "THERMIQUE",
                    "ACOUSTIQUE",
                    "FORCE",
                ),
                "nexistepasMCFParmi",
            ),
        ),
    )
    renameCommande(jdc, "CALC_CHAMPNO", "CALC_CHAMP")
    renameCommande(jdc, "CALC_METANO", "CALC_META")
    renameCommande(jdc, "CALC_ERREURNO", "CALC_ERREUR")
    removeMotCle(jdc, "CALC_CHAMP", "METANO", pasDeRegle(), 0)
    removeMotCle(jdc, "CALC_CHAMP", "ERREURNO", pasDeRegle(), 0)

    ####   traitement de CALC_POINT_MAT   ##############################
    # Rien à faire

    ####   traitement de CALC_PRECONT   ##############################
    # Renommage de IMPLEX
    changementValeur(jdc, "CALC_PRECONT", "METHODE", {"IMPL_EX": "IMPLEX"})
    removeMotCle(jdc, "CALC_PRECONT", "IMPL_EX", pasDeRegle(), 0)

    ####   traitement de CALC_SENSI   ##############################
    # Résorption de la sensibilité
    removeCommande(jdc, "CALC_SENSI")
    # genereErreurPourCommande(jdc,("CALC_SENSI",))

    ####   traitement de CALC_SPEC   ##############################
    # Déplacement d'un mot-clé facteur facteur
    moveMotCleFromFactToFather(jdc, "CALC_SPEC", "TAB_ECHANT", "LONGUEUR_ECH")
    moveMotCleFromFactToFather(jdc, "CALC_SPEC", "LONGUEUR_ECH", "DUREE")
    moveMotCleFromFactToFather(jdc, "CALC_SPEC", "LONGUEUR_ECH", "POURCENT")
    moveMotCleFromFactToFather(jdc, "CALC_SPEC", "LONGUEUR_ECH", "NB_PTS")
    removeMotCle(jdc, "CALC_SPEC", "LONGUEUR_ECH", pasDeRegle(), 0)
    renameMotCle(jdc, "CALC_SPEC", "DUREE", "LONGUEUR_DUREE")
    renameMotCle(jdc, "CALC_SPEC", "POURCENT", "LONGUEUR_POURCENT")
    renameMotCle(jdc, "CALC_SPEC", "NB_PTS", "LONGUEUR_NB_PTS")
    moveMotClefInOperToFact(jdc, "CALC_SPEC", "LONGUEUR_DUREE", "TAB_ECHANT")
    moveMotClefInOperToFact(jdc, "CALC_SPEC", "POURCENT_DUREE", "TAB_ECHANT")
    moveMotClefInOperToFact(jdc, "CALC_SPEC", "LONGUEUR_NB_PTS", "TAB_ECHANT")
    moveMotCleFromFactToFather(jdc, "CALC_SPEC", "TAB_ECHANT", "RECOUVREMENT")
    moveMotCleFromFactToFather(jdc, "CALC_SPEC", "RECOUVREMENT", "DUREE")
    moveMotCleFromFactToFather(jdc, "CALC_SPEC", "RECOUVREMENT", "POURCENT")
    moveMotCleFromFactToFather(jdc, "CALC_SPEC", "RECOUVREMENT", "NB_PTS")
    removeMotCle(jdc, "CALC_SPEC", "RECOUVREMENT", pasDeRegle(), 0)
    renameMotCle(jdc, "CALC_SPEC", "DUREE", "RECOUVREMENT_DUREE")
    renameMotCle(jdc, "CALC_SPEC", "POURCENT", "RECOUVREMENT_POURCENT")
    renameMotCle(jdc, "CALC_SPEC", "NB_PTS", "RECOUVREMENT_NB_PTS")
    moveMotClefInOperToFact(jdc, "CALC_SPEC", "RECOUVREMENT_DUREE", "TAB_ECHANT")
    moveMotClefInOperToFact(jdc, "CALC_SPEC", "RECOUVREMENT_POURCENT", "TAB_ECHANT")
    moveMotClefInOperToFact(jdc, "CALC_SPEC", "RECOUVREMENT_NB_PTS", "TAB_ECHANT")

    ####   traitement de CALC_TABLE   ##############################
    # Renommage de AJOUT en AJOUT_LIGNE
    dOPE = {
        "AJOUT": "AJOUT_LIGNE",
    }
    changementValeurDsMCF(jdc, "CALC_TABLE", "ACTION", "OPERATION", dOPE)
    # Résorption de la sensibilité
    removeMotCle(jdc, "CALC_TABLE", "SENSIBILITE", pasDeRegle(), 0)
    # Renommage critere table
    dCRIT = {"ABS_MAXI": "MAXI_ABS", "ABS_MINI": "MINI_ABS"}
    changementValeurDsMCF(jdc, "CALC_TABLE", "FILTRE", "CRIT_COMP", dCRIT)

    ####   traitement de CALC_THETA   ##############################
    # Résorption de la sensibilité
    removeMotCle(jdc, "CALC_THETA", "OPTION", pasDeRegle(), 0)
    removeMotCle(jdc, "CALC_THETA", "THETA_BANDE", pasDeRegle(), 1)
    removeMotCle(jdc, "CALC_THETA", "GRAD_NOEU_THETA", pasDeRegle(), 0)

    ####   traitement de COMB_FOURIER  ##############################
    # Homogénéisation de ANGLE
    renameMotCle(jdc, "COMB_FOURIER", "ANGL", "ANGLE")

    ####   traitement de COMB_SISM_MODAL   ##############################
    genereErreurValeur(jdc, "COMB_SISM_MODAL", "OPTION", ("'EFCA_ELNO'",))

    ####   traitement de CREA_CHAMP   ##############################
    removeMotCle(jdc, "CREA_CHAMP", "SENSIBILITE", pasDeRegle(), 0)
    removeMotCle(jdc, "CREA_CHAMP", "PROL_ZERO", pasDeRegle(), 0)

    ####   traitement de CREA_ELEM_SSD   ##############################
    # Rien à faire

    ####   traitement de CREA_MAILLAGE   ##############################
    # Suppression de la possibilité de copier un maillage
    lFACTEUR = [
        "COQU_VOLU",
        "CREA_FISS",
        "CREA_GROUP_MA",
        "CREA_MAILLE",
        "CREA_POI1",
        "DETR_GROUP_MA",
        "ECLA_PG",
        "HEXA20_27",
        "LINE_QUAD",
        "MODI_MAILLE",
        "QUAD_LINE",
        "REPERE",
        "RESTREINT",
        "PENTA15_18",
        "GEOM_FIBRE",
    ]
    renameCommandeSiRegle(
        jdc, "CREA_MAILLAGE", "COPIER", (((lFACTEUR), "nexistepasMCFParmi"),)
    )
    renameMotCle(jdc, "COPIER", "MAILLAGE", "CONCEPT")

    ####   traitement de CREA_RESU   ##############################
    # Rien à faire

    ####   traitement de CREA_TABLE   ##############################
    removeMotCle(jdc, "CREA_TABLE", "SENSIBILITE", pasDeRegle(), 0)

    ####   traitement de DEBUT   ##############################
    # Suppression du mot-clé TITRE
    removeMotCleInFact(jdc, "DEBUT", "CATALOGUE", "TITRE", pasDeRegle(), 0)
    # Suppression du mot-clé IMPRESSION
    removeMotCle(jdc, "DEBUT", "IMPRESSION", pasDeRegle(), 0)
    # Suppression des mots-clés mémoire dynamique
    removeMotCleInFact(jdc, "DEBUT", "MEMOIRE", "GESTION", pasDeRegle(), 0)
    removeMotCleInFact(jdc, "DEBUT", "MEMOIRE", "TYPE_ALLOCATION", pasDeRegle(), 0)
    removeMotCleInFact(jdc, "DEBUT", "MEMOIRE", "TAILLE", pasDeRegle(), 0)
    removeMotCleInFact(jdc, "DEBUT", "MEMOIRE", "PARTITION", pasDeRegle(), 0)
    removeMotCleInFact(jdc, "DEBUT", "MEMOIRE", "DYNAMIQUE", pasDeRegle(), 0)

    ####   traitement de DEFI_BASE_MODALE   ##############################
    # Rien à faire

    ####   traitement de DEFI_CABLE_BP   ##############################
    # Rien à faire

    ####   traitement de DEFI_COMPOR   ##############################
    # Suppression famille de sytèmes de glissement
    lFAMGLIS = [
        "'BASAL'",
        "'PRISMATIQUE'",
        "'PYRAMIDAL1'",
        "'PYRAMIDAL2'",
        "'MACLAGE'",
    ]
    genereErreurValeurDsMCF(
        jdc, "DEFI_COMPOR", "MONOCRISTAL", "FAMI_SYST_GLIS", lFAMGLIS
    )
    # Suppression famille de sytèmes de glissement
    genereErreurValeurDsMCF(
        jdc, "DEFI_COMPOR", "MONOCRISTAL", "ECOULEMENT", ("'MONO_VISC3'",)
    )
    # Suppression de ALGO_1D
    removeMotCleInFact(jdc, "DEFI_COMPOR", "MULTIFIBRE", "ALGO_1D", pasDeRegle(), 0)
    # Suppression de DEFORMATION
    genereErreurMotCleInFact(jdc, "DEFI_COMPOR", "MULTIFIBRE", "DEFORMATION")

    ####   traitement de DEFI_CONTACT  ##############################
    genereErreurValeurDsMCF(jdc, "DEFI_CONTACT", "ZONE", "ALGO_CONT", ("'AVANCE'",))
    genereErreurValeurDsMCF(jdc, "DEFI_CONTACT", "ZONE", "ALGO_FROT", ("'AVANCE'",))
    # résorption de RACCORD_LINE_QUAD et éléments de Barsoum
    genereErreurMCF(jdc, "DEFI_CONTACT", "FOND_FISSURE")
    genereErreurMCF(jdc, "DEFI_CONTACT", "NOEUD_FOND")
    genereErreurMCF(jdc, "DEFI_CONTACT", "GROUP_NO_FOND")
    genereErreurMCF(jdc, "DEFI_CONTACT", "MAILLE_FOND")
    genereErreurMCF(jdc, "DEFI_CONTACT", "GROUP_MA_FOND")
    genereErreurMCF(jdc, "DEFI_CONTACT", "RACCORD_LINE_QUAD")
    genereErreurMCF(jdc, "DEFI_CONTACT", "NOEUD_RACC")
    genereErreurMCF(jdc, "DEFI_CONTACT", "GROUP_NO_RACC")
    genereErreurMCF(jdc, "DEFI_CONTACT", "EXCLUSION_PIV_NUL")
    genereErreurMCF(jdc, "DEFI_CONTACT", "COEF_ECHELLE")
    # résorption de COMPLIANCE
    genereErreurMCF(jdc, "DEFI_CONTACT", "COMPLIANCE")
    genereErreurMCF(jdc, "DEFI_CONTACT", "ASPERITE")
    genereErreurMCF(jdc, "DEFI_CONTACT", "E_N")
    genereErreurMCF(jdc, "DEFI_CONTACT", "E_V")
    # résorption de l'usure
    genereErreurMCF(jdc, "DEFI_CONTACT", "USURE")
    genereErreurMCF(jdc, "DEFI_CONTACT", "K")
    genereErreurMCF(jdc, "DEFI_CONTACT", "H")
    # Suppression de schémas d'inégration pour XFEM
    lSCHEMA = ["FPG2", "FPG3", "FPG4", "FPG6", "FPG7", "SIMPSON1", "NCOTES1", "NCOTES2"]
    removeMotCleInFactSiRegle(
        jdc,
        "DEFI_CONTACT",
        "ZONE",
        "INTEGRATION",
        (
            (("FORMULATION", "XFEM", jdc), "MCaPourValeur")
            and (
                ("ZONE", "INTEGRATION", lSCHEMA, jdc),
                "MCsousMCFaPourValeurDansListe",
            ),
        ),
    )
    # règles sur relation
    removeMotCleInFactSiRegle(
        jdc,
        "DEFI_CONTACT",
        "ZONE",
        "RELATION",
        ((("ZONE", "RELATION", "NON", jdc), "MCsousMCFaPourValeur"),),
    )
    # Suppression de schémas d'inégration pour méthode CONTINUE
    lSCHEMA = ["NOEUD", "SIMPSON1", "SIMPSON2", "NCOTES1", "NCOTES2"]
    removeMotCleInFactSiRegle(
        jdc,
        "DEFI_CONTACT",
        "ZONE",
        "INTEGRATION",
        (
            (("FORMULATION", "CONTINUE", jdc), "MCaPourValeur")
            and (
                ("ZONE", "INTEGRATION", lSCHEMA, jdc),
                "MCsousMCFaPourValeurDansListe",
            ),
        ),
    )
    # Ajout règle sur REAC_GEOM
    removeMotCleSiRegle(
        jdc,
        "DEFI_CONTACT",
        "REAC_GEOM",
        ((("ALGO_RESO_GEOM", "NEWTON", jdc), "MCaPourValeur"),),
    )

    ####   traitement de DEFI_COQU_MULT   ##############################
    renameCommande(
        jdc,
        "DEFI_COQU_MULT",
        "DEFI_COMPOSITE",
    )

    ####   traitement de DEFI_FICHIER   ##############################
    # Rien à faire

    ####   traitement de DEFI_FISS_XFEM   ##############################
    # Suppression de ORIE_FOND
    removeMotCle(jdc, "DEFI_FISS_XFEM", "ORIE_FOND", pasDeRegle(), 0)
    # Fusion FORM_FISS='ELLIPSE' et FORM_FISS='INCLUSION'
    dFORME = {
        "INCLUSION": "ELLIPSE",
    }
    changementValeurDsMCF(jdc, "DEFI_FISS_XFEM", "DEFI_FISS", "FORM_FISS", dOPE)

    ####   traitement de DEFI_FONC_ELEC   ##############################
    # Rien à faire

    ####   traitement de DEFI_FOND_FISS   ##############################
    renameMotCle(jdc, "DEFI_FOND_FISS", "FOND_FISS", "FONDFISS")
    # Cas FOND OUVERT
    ajouteMotClefDansFacteurCourantSiRegle(
        jdc,
        "DEFI_FOND_FISS",
        "FONDFISS",
        "TYPE_FOND='OUVERT'",
        ((("FONDFISS",), "existe"),),
    )
    # Cas FOND FERME
    chercheOperInsereFacteurSiRegle(
        jdc, "DEFI_FOND_FISS", "TYPE_FOND='FERME'", ((("FOND_FERME",), "existe"),), 0
    )
    renameMotCle(jdc, "DEFI_FOND_FISS", "FOND_FERME", "FONDFISS")
    moveMotClefInOperToFact(jdc, "DEFI_FOND_FISS", "TYPE_FOND", "FONDFISS")
    # Cas FOND INF
    chercheOperInsereFacteurSiRegle(
        jdc, "DEFI_FOND_FISS", "TYPE_FOND='INF'", ((("FOND_INF",), "existe"),), 0
    )
    renameMotCle(jdc, "DEFI_FOND_FISS", "FOND_SUP", "FONDFISS")
    moveMotClefInOperToFact(jdc, "DEFI_FOND_FISS", "TYPE_FOND", "FONDFISS")
    # Cas FOND SUP
    chercheOperInsereFacteurSiRegle(
        jdc, "DEFI_FOND_FISS", "TYPE_FOND='SUP'", ((("FOND_SUP",), "existe"),), 0
    )
    renameMotCle(jdc, "DEFI_FOND_FISS", "FOND_SUP", "FONDFISS")
    moveMotClefInOperToFact(jdc, "DEFI_FOND_FISS", "TYPE_FOND", "FONDFISS")
    # Autres mots-clés
    moveMotClefInOperToFact(jdc, "DEFI_FOND_FISS", "DTAN_ORIG", "FONDFISS")
    moveMotClefInOperToFact(jdc, "DEFI_FOND_FISS", "DTAN_EXTR", "FONDFISS")
    moveMotClefInOperToFact(jdc, "DEFI_FOND_FISS", "VECT_GRNO_ORIG", "FONDFISS")
    moveMotClefInOperToFact(jdc, "DEFI_FOND_FISS", "VECT_GRNO_EXTR", "FONDFISS")
    removeMotCle(jdc, "DEFI_FOND_FISS", "NORMALE", pasDeRegle(), 0)
    #
    renameMotCle(jdc, "DEFI_FOND_FISS", "FONDFISS", "FOND_FISS")

    ####   traitement de DEFI_GLRC   ##############################
    # Renommage de mot-clés
    renameMotCle(jdc, "DEFI_GLRC", "GC", "GAMMA_C")
    renameMotCle(jdc, "DEFI_GLRC", "SYC", "NYC")
    renameMotCle(jdc, "DEFI_GLRC", "EPSI_FLEX", "KAPPA_FLEX")

    ####   traitement de DEFI_GROUPE   ##############################
    # Rien à faire

    ####   traitement de DEFI_INTE_SPEC   ##############################
    # Rien à faire

    ####   traitement de DEFI_LIST_INST   ##############################
    dMETHODE = {"UNIFORME": "MANUEL", "EXTRAPOLE": "MANUEL", "AUCUNE": "AUTO"}
    changementValeurDsMCF(jdc, "DEFI_LIST_INST", "ECHEC", "SUBD_METHODE", dMETHODE)
    removeMotCleInFact(
        jdc, "DEFI_LIST_INST", "ECHEC", "SUBD_COEF_PAS_1", pasDeRegle(), 0
    )

    ####   traitement de DEFI_MATER_GC   ##############################
    # Rien à faire, n'existe pas en 10

    ####   traitement de DEFI_MATERIAU   ##############################
    # Suppression des critères pour les poutres
    genereErreurMCF(jdc, "DEFI_MATERIAU", "ECRO_FLEJOU")
    genereErreurMCF(jdc, "DEFI_MATERIAU", "VMIS_POUTRE")
    genereErreurMCF(jdc, "DEFI_MATERIAU", "VMIS_POUTRE_FO")
    # Modification de la loi de grandissement
    genereErreurMotCleInFact(jdc, "DEFI_MATERIAU", "LEMAITRE_IRRA", "GRAN_A")
    genereErreurMotCleInFact(jdc, "DEFI_MATERIAU", "LEMAITRE_IRRA", "GRAN_B")
    genereErreurMotCleInFact(jdc, "DEFI_MATERIAU", "LEMAITRE_IRRA", "GRAN_S")
    genereErreurMotCleInFact(jdc, "DEFI_MATERIAU", "LMARC_IRRA", "GRAN_A")
    genereErreurMotCleInFact(jdc, "DEFI_MATERIAU", "LMARC_IRRA", "GRAN_B")
    genereErreurMotCleInFact(jdc, "DEFI_MATERIAU", "LMARC_IRRA", "GRAN_S")
    genereErreurMotCleInFact(jdc, "DEFI_MATERIAU", "GRAN_IRRA_LOG", "GRAN_A")
    genereErreurMotCleInFact(jdc, "DEFI_MATERIAU", "GRAN_IRRA_LOG", "GRAN_B")
    genereErreurMotCleInFact(jdc, "DEFI_MATERIAU", "GRAN_IRRA_LOG", "GRAN_S")
    # Modification des paramètres de la loi ENDO_SCALAIRE
    genereErreurMCF(jdc, "DEFI_MATERIAU", "ENDO_SCALAIRE")
    # Modification des paramètres de la loi MAZARS
    genereErreurMCF(jdc, "DEFI_MATERIAU", "MAZARS")
    genereErreurMCF(jdc, "DEFI_MATERIAU", "MAZARS_FO")
    # Modification des paramètres de la loi GLRC_DM
    renameMotCleInFact(jdc, "DEFI_MATERIAU", "GLRC_DM", "SYT", "NYT", pasDeRegle(), 0)
    renameMotCleInFact(jdc, "DEFI_MATERIAU", "GLRC_DM", "SYC", "NYC", pasDeRegle(), 0)
    renameMotCleInFact(jdc, "DEFI_MATERIAU", "GLRC_DM", "SYF", "NYF", pasDeRegle(), 0)
    # Suppression de la loi MONO_VISC3
    genereErreurMCF(jdc, "DEFI_MATERIAU", "MONO_VISC3")
    # Suppression de la loi MONO_DD_CC
    genereErreurMCF(jdc, "DEFI_MATERIAU", "MONO_DD_CC")

    ####   traitement de DEFI_NAPPE   ##############################
    # Rien à faire

    ####   traitement de DEFI_PARA_SENSI   ##############################
    # Résorption de la sensibilité
    removeCommande(jdc, "DEFI_PARA_SENSI")
    # genereErreurPourCommande(jdc,("DEFI_PARA_SENSI",))

    ####   traitement de DEFI_PART_FETI   ##############################
    # Rien à faire

    ####   traitement de DEFI_SOL_MISS   ##############################
    # Rien à faire

    ####   traitement de DEFI_SPEC_TURB  ##############################
    # Homogénéisation de ANGLE
    renameMotCleInFact(
        jdc, "DEFI_SPEC_TURB", "SPEC_EXCI_POINT", "ANGL", "ANGLE", pasDeRegle(), 0
    )

    ####   traitement de DETRUIRE  ##############################
    # Résorption de la sensibilité
    removeMotCleInFact(jdc, "DETRUIRE", "CONCEPT", "SENSIBILITE", pasDeRegle(), 0)
    # Suppression mot-clé ALARME
    removeMotCle(jdc, "DETRUIRE", "ALARME", pasDeRegle(), 0)

    ####   traitement de DYNA_ALEA_MODAL   ##############################
    # Rien à faire

    ####   traitement de DYNA_ISS_VARI   ##############################
    ajouteMotClefDansFacteurCourantSiRegle(
        jdc,
        "DYNA_ISS_VARI",
        "MATR_COHE",
        "TYPE='MITA_LUCO'",
        ((("MATR_COHE",), "existe"),),
    )

    ####   traitement de DYNA_LINE_HARM   ##############################
    # Résorption de la sensibilité
    removeMotCle(jdc, "DYNA_LINE_HARM", "SENSIBILITE", pasDeRegle(), 0)
    # Suppression mot-clé TYPE_CHARGE
    removeMotCleInFact(jdc, "DYNA_LINE_HARM", "EXCIT", "TYPE_CHARGE", pasDeRegle(), 0)
    # Ajout AMOR_MODAL
    chercheOperInsereFacteurSiRegle(
        jdc,
        "DYNA_LINE_HARM",
        "AMOR_MODAL",
        (
            (
                (
                    "AMOR_REDUIT",
                    "LIST_AMOR",
                ),
                "existeMCFParmi",
            ),
        ),
        1,
    )
    moveMotClefInOperToFact(jdc, "DYNA_LINE_HARM", "AMOR_REDUIT", "AMOR_MODAL")
    moveMotClefInOperToFact(jdc, "DYNA_LINE_HARM", "LIST_AMOR", "AMOR_MODAL")

    ####   traitement de DYNA_LINE_TRAN   ##############################
    # Résorption de la sensibilité
    removeMotCle(jdc, "DYNA_LINE_TRAN", "SENSIBILITE", pasDeRegle(), 0)
    # Ajout SCHEMA_TEMPS
    chercheOperInsereFacteurSiRegle(
        jdc,
        "DYNA_LINE_TRAN",
        "SCHEMA_TEMPS",
        (
            (
                (
                    "NEWMARK",
                    "WILSON",
                    "DIFF_CENTRE",
                    "ADAPT",
                ),
                "existeMCFParmi",
            ),
        ),
        1,
    )
    ajouteMotClefDansFacteurSiRegle(
        jdc,
        "DYNA_LINE_TRAN",
        "SCHEMA_TEMPS",
        "SCHEMA='NEWMARK'",
        ((("NEWMARK",), "existeMCFParmi"),),
    )
    moveMotCleFromFactToFact(jdc, "DYNA_LINE_TRAN", "NEWMARK", "ALPHA", "SCHEMA_TEMPS")
    moveMotCleFromFactToFact(jdc, "DYNA_LINE_TRAN", "NEWMARK", "DELTA", "SCHEMA_TEMPS")
    renameMotCleInFact(
        jdc, "DYNA_LINE_TRAN", "SCHEMA_TEMPS", "ALPHA", "BETA", pasDeRegle(), 0
    )
    renameMotCleInFact(
        jdc, "DYNA_LINE_TRAN", "SCHEMA_TEMPS", "DELTA", "GAMMA", pasDeRegle(), 0
    )
    removeMotCle(jdc, "DYNA_LINE_TRAN", "NEWMARK", pasDeRegle(), 0)
    ajouteMotClefDansFacteurSiRegle(
        jdc,
        "DYNA_LINE_TRAN",
        "SCHEMA_TEMPS",
        "SCHEMA='WILSON'",
        ((("WILSON",), "existeMCFParmi"),),
    )
    moveMotCleFromFactToFact(jdc, "DYNA_LINE_TRAN", "WILSON", "THETA", "SCHEMA_TEMPS")
    removeMotCle(jdc, "DYNA_LINE_TRAN", "WILSON", pasDeRegle(), 0)
    ajouteMotClefDansFacteurSiRegle(
        jdc,
        "DYNA_LINE_TRAN",
        "SCHEMA_TEMPS",
        "SCHEMA='DIFF_CENTRE'",
        ((("DIFF_CENTRE",), "existeMCFParmi"),),
    )
    removeMotCle(jdc, "DYNA_LINE_TRAN", "DIFF_CENTRE", pasDeRegle(), 0)
    ajouteMotClefDansFacteurSiRegle(
        jdc,
        "DYNA_LINE_TRAN",
        "SCHEMA_TEMPS",
        "SCHEMA='ADAPT_ORDRE2'",
        ((("ADAPT",), "existeMCFParmi"),),
    )
    removeMotCle(jdc, "DYNA_LINE_TRAN", "ADAPT", pasDeRegle(), 0)
    # Renommage dans ETAT_INIT
    renameMotCleInFact(
        jdc, "DYNA_LINE_TRAN", "ETAT_INIT", "DYNA_TRANS", "RESULTAT", pasDeRegle(), 0
    )
    renameMotCleInFact(
        jdc, "DYNA_LINE_TRAN", "ETAT_INIT", "DEPL_INIT", "DEPL", pasDeRegle(), 0
    )
    renameMotCleInFact(
        jdc, "DYNA_LINE_TRAN", "ETAT_INIT", "ACCE_INIT", "ACCE", pasDeRegle(), 0
    )
    renameMotCleInFact(
        jdc, "DYNA_LINE_TRAN", "ETAT_INIT", "VITE_INIT", "VITE", pasDeRegle(), 0
    )
    renameMotCleInFact(
        jdc, "DYNA_LINE_TRAN", "ETAT_INIT", "NUME_INIT", "NUME_ORDRE", pasDeRegle(), 0
    )
    # Suppression mot-clé TYPE_CHARGE
    removeMotCleInFact(jdc, "DYNA_LINE_TRAN", "EXCIT", "TYPE_CHARGE", pasDeRegle(), 0)
    # Suppression mot-clé FONC_INST
    genereErreurMotCleInFact(jdc, "DYNA_LINE_TRAN", "INCREMENT", "FONC_INST")
    # Suppression mot-clé PAS_CALCUL
    removeMotCleInFact(
        jdc, "DYNA_LINE_TRAN", "INCREMENT", "PAS_CALCUL", pasDeRegle(), 0
    )
    # Renommage dans ARCHIVAGE
    renameMotCleInFact(
        jdc, "DYNA_LINE_TRAN", "ARCHIVAGE", "LIST_ARCH", "LIST_INST", pasDeRegle(), 0
    )

    ####   traitement de DYNA_NON_LINE   ##############################
    # Renommage CRIT_FLAMB en CRIT_STAB
    renameMotCle(jdc, "DYNA_NON_LINE", "CRIT_FLAMB", "CRIT_STAB")
    # Résorption de la sensibilité
    removeMotCle(jdc, "DYNA_NON_LINE", "SENSIBILITE", pasDeRegle(), 0)
    # Suppression de ARCHIVAGE/DETR_NUME_SUIV
    removeMotCleInFact(
        jdc, "DYNA_NON_LINE", "ARCHIVAGE", "DETR_NUME_SUIV", pasDeRegle(), 0
    )

    ####   traitement de DYNA_SPEC_MODAL   ##############################
    # Rien à faire

    ####   traitement de DYNA_TRAN_MODAL   ##############################
    # Ajout SCHEMA_TEMPS
    chercheOperInsereFacteur(jdc, "DYNA_TRAN_MODAL", "SCHEMA_TEMPS")
    chercheOperInsereMotCleSiRegle(
        jdc,
        "DYNA_TRAN_MODAL",
        "METHODE='EULER'",
        ((("METHODE",), "nexistepas"),),
    )
    moveMotClefInOperToFact(jdc, "DYNA_TRAN_MODAL", "METHODE", "SCHEMA_TEMPS")
    renameMotCleInFact(
        jdc, "DYNA_TRAN_MODAL", "SCHEMA_TEMPS", "METHODE", "SCHEMA", pasDeRegle(), 0
    )
    moveMotClefInOperToFact(jdc, "DYNA_TRAN_MODAL", "BASE_ELAS_FLUI", "SCHEMA_TEMPS")
    moveMotClefInOperToFact(jdc, "DYNA_TRAN_MODAL", "NUME_VITE_FLUI", "SCHEMA_TEMPS")
    moveMotClefInOperToFact(jdc, "DYNA_TRAN_MODAL", "ETAT_STAT", "SCHEMA_TEMPS")
    moveMotClefInOperToFact(jdc, "DYNA_TRAN_MODAL", "PREC_DUREE", "SCHEMA_TEMPS")
    moveMotClefInOperToFact(jdc, "DYNA_TRAN_MODAL", "CHOC_FLUI", "SCHEMA_TEMPS")
    moveMotClefInOperToFact(jdc, "DYNA_TRAN_MODAL", "NB_MODE", "SCHEMA_TEMPS")
    moveMotClefInOperToFact(jdc, "DYNA_TRAN_MODAL", "NB_MODE_FLUI", "SCHEMA_TEMPS")
    moveMotClefInOperToFact(jdc, "DYNA_TRAN_MODAL", "TS_REG_ETAB", "SCHEMA_TEMPS")
    # Renommage des matrices
    renameMotCle(jdc, "DYNA_TRAN_MODAL", "MASS_GENE", "MATR_MASS")
    renameMotCle(jdc, "DYNA_TRAN_MODAL", "RIGI_GENE", "MATR_RIGI")
    renameMotCle(jdc, "DYNA_TRAN_MODAL", "AMOR_GENE", "MATR_AMOR")
    # Ajout AMOR_MODAL
    chercheOperInsereFacteurSiRegle(
        jdc,
        "DYNA_TRAN_MODAL",
        "AMOR_MODAL",
        (
            (
                (
                    "AMOR_REDUIT",
                    "LIST_AMOR",
                ),
                "existeMCFParmi",
            ),
        ),
        1,
    )
    moveMotClefInOperToFact(jdc, "DYNA_TRAN_MODAL", "AMOR_REDUIT", "AMOR_MODAL")
    moveMotClefInOperToFact(jdc, "DYNA_TRAN_MODAL", "LIST_AMOR", "AMOR_MODAL")
    # couplage
    chercheOperInsereFacteurSiRegle(
        jdc,
        "DYNA_TRAN_MODAL",
        "VITESSE_VARIABLE='NON'",
        ((("COUPLAGE_EDYOS"), "existe"),),
        1,
    )
    moveMotCleFromFactToFather(jdc, "DYNA_TRAN_MODAL", "COUPLAGE_EDYOS", "VITE_ROTA")
    # Renommage dans ETAT_INIT
    renameMotCleInFact(
        jdc, "DYNA_TRAN_MODAL", "ETAT_INIT", "RESU_GENE", "RESULTAT", pasDeRegle(), 0
    )
    renameMotCleInFact(
        jdc, "DYNA_TRAN_MODAL", "ETAT_INIT", "INIT_GENE", "DEPL", pasDeRegle(), 0
    )
    renameMotCleInFact(
        jdc, "DYNA_TRAN_MODAL", "ETAT_INIT", "DEPL_INIT_GENE", "DEPL", pasDeRegle(), 0
    )
    renameMotCleInFact(
        jdc, "DYNA_TRAN_MODAL", "ETAT_INIT", "VITE_INIT_GENE", "VITE", pasDeRegle(), 0
    )
    # Renommage dans ARCHIVAGE
    renameMotCleInFact(
        jdc, "DYNA_LINE_TRAN", "ARCHIVAGE", "LIST_ARCH", "LIST_INST", pasDeRegle(), 0
    )
    # Paramètres LAME_FLUIDE
    chercheOperInsereFacteurSiRegle(
        jdc,
        "DYNA_TRAN_MODAL",
        "PARA_LAMEFLUI",
        ((("NMAX_ITER", "RESI_RELA", "LAMBDA"), "existeMCFParmi"),),
        1,
    )
    moveMotClefInOperToFact(jdc, "DYNA_TRAN_MODAL", "NMAX_ITER", "PARA_LAMEFLUI")
    moveMotClefInOperToFact(jdc, "DYNA_TRAN_MODAL", "RESI_RELA", "PARA_LAMEFLUI")
    moveMotClefInOperToFact(jdc, "DYNA_TRAN_MODAL", "LAMBDA", "PARA_LAMEFLUI")
    renameMotCle(jdc, "DYNA_TRAN_MODAL", "PARA_LAMEFLUI", "PARA_LAME_FLUI")

    ####   traitement de DYNA_VIBRA   ##############################
    # Rien à faire, n'existe pas en 10

    ####   traitement de EXEC_LOGICIEL   ##############################
    # Rien à faire

    ####   traitement de EXTR_RESU   ##############################
    # Résorption de la sensibilité
    removeMotCle(jdc, "EXTR_RESU", "SENSIBILITE", pasDeRegle(), 0)

    ####   traitement de EXTR_TABLE   ##############################
    # Renommage critere table
    dCRIT = {"ABS_MAXI": "MAXI_ABS", "ABS_MINI": "MINI_ABS"}
    changementValeurDsMCF(jdc, "RECU_TABLE", "FILTRE", "CRIT_COMP", dCRIT)

    ####   traitement de FACTORISER   ##############################
    # Suppression de RENUM
    removeMotCleSiRegle(
        jdc, "FACTORISER", "RENUM", ((("PRE_COND", "LDLT_INC", jdc), "MCaPourValeur"),)
    )
    removeMotCleSiRegle(
        jdc, "FACTORISER", "RENUM", ((("PRE_COND", "LDLT_SP", jdc), "MCaPourValeur"),)
    )
    # Modification mot-clés liés à la mémoire
    removeMotCle(jdc, "FACTORISER", "LIBERE_MEMOIRE", pasDeRegle(), 0)
    renameMotCle(jdc, "FACTORISER", "OUT_OF_CORE", "GESTION_MEMOIRE")
    dMEM = {"OUI": "OUT_OF_CORE", "NON": "IP_CORE"}
    changementValeur(jdc, "FACTORISER", "GESTION_MEMOIRE", dCRIT)

    ####   traitement de FORMULE   ##############################
    # Rien à faire

    ####   traitement de GENE_ACCE_SEISME   ##############################
    # Rien à faire, n'existe pas en 10

    ####   traitement de GENE_FONC_ALEA   ##############################
    # Rien à faire

    ####   traitement de GENE_VARI_ALEA   ##############################
    # Rien à faire

    ####   traitement de IMPR_CO  ##############################
    # Résorption de la sensibilité
    removeMotCleInFact(jdc, "IMPR_CO", "CONCEPT", "SENSIBILITE", pasDeRegle(), 0)

    ####   traitement de IMPR_DIAG_CAMPBELL   ##############################
    # Rien à faire

    ####   traitement de IMPR_FONCTION   ##############################
    # Rien à faire

    ####   traitement de IMPR_GENE   ##############################
    # Rien à faire

    ####   traitement de IMPR_OAR   ##############################
    # Rien à faire

    ####   traitement de IMPR_RESU   ##############################
    # Résorption de la sensibilité
    removeMotCleInFact(jdc, "IMPR_RESU", "RESU", "SENSIBILITE", pasDeRegle(), 0)
    # Suppression de l'écriture au format ENSIGHT
    genereErreurValeur(jdc, "IMPR_RESU", "FORMAT", ("'ENSIGHT'",))
    # Homogénéisation de ANGLE
    renameMotCleInFact(jdc, "IMPR_RESU", "FORMAT", "ANGL", "ANGLE", pasDeRegle(), 0)
    # Suppression mot-clé MODELE
    removeMotCle(jdc, "IMPR_RESU", "MODELE", pasDeRegle(), 0)

    ####   traitement de IMPR_STURM   ##############################
    renameMotCle(jdc, "IMPR_STURM", "TYPE_RESU", "TYPE_MODE")
    # renommage de MATR_A, MATR_B et MATR_C
    renameMotCleSiRegle(
        jdc,
        "IMPR_STURM",
        "MATR_A",
        "MATR_RIGI",
        ((("TYPE_MODE", "DYNAMIQUE", jdc), "MCaPourValeur"),),
        1,
    )
    renameMotCleSiRegle(
        jdc,
        "IMPR_STURM",
        "MATR_B",
        "MATR_MASS",
        ((("TYPE_MODE", "DYNAMIQUE", jdc), "MCaPourValeur"),),
        1,
    )
    renameMotCleSiRegle(
        jdc,
        "IMPR_STURM",
        "MATR_A",
        "MATR_RIGI",
        ((("TYPE_MODE", "MODE_FLAMB", jdc), "MCaPourValeur"),),
        1,
    )
    renameMotCleSiRegle(
        jdc,
        "IMPR_STURM",
        "MATR_B",
        "MATR_RIGI_GEOM",
        ((("TYPE_MODE", "MODE_FLAMB", jdc), "MCaPourValeur"),),
        1,
    )
    renameMotCle(jdc, "IMPR_STURM", "MATR_A", "MATR_RIGI")
    renameMotCle(jdc, "IMPR_STURM", "MATR_B", "MATR_MASS")
    #
    chercheOperInsereMotCleSiRegle(
        jdc,
        "IMPR_STURM",
        "FREQ_MIN=0.",
        ((("FREQ_MIN",), "nexistepas") and (("FREQ_MAX",), "existeMCFParmi"),),
    )
    fusionMotCleToFact(jdc, "IMPR_STURM", ("FREQ_MIN", "FREQ_MAX"), "FREQ")
    fusionMotCleToFact(
        jdc, "IMPR_STURM", ("CHAR_CRIT_MIN", "CHAR_CRIT_MAX"), "CHAR_CRIT"
    )
    # Ajout COMPTAGE
    chercheOperInsereFacteurSiRegle(
        jdc,
        "IMPR_STURM",
        "COMPTAGE",
        ((("NMAX_ITER_SHIFT", "PREC_SHIFT", "SEUIL_FREQ"), "existeMCFParmi"),),
        1,
    )
    moveMotClefInOperToFact(jdc, "IMPR_STURM", "NMAX_ITER_SHIFT", "COMPTAGE")
    moveMotClefInOperToFact(jdc, "IMPR_STURM", "PREC_SHIFT", "COMPTAGE")
    moveMotClefInOperToFact(jdc, "IMPR_STURM", "SEUIL_FREQ", "COMPTAGE")
    renameMotCleInFactSiRegle(
        jdc,
        "IMPR_STURM",
        "COMPTAGE",
        "SEUIL_FREQ",
        "SEUIL_CHAR_CRIT",
        ((("TYPE_MODE", "MODE_FLAMB", jdc), "MCaPourValeur"),),
    )
    # Suppression UNITE
    removeMotCle(jdc, "IMPR_STURM", "UNITE", pasDeRegle(), 0)
    # Renommage de la commande
    renameCommande(
        jdc,
        "IMPR_STURM",
        "INFO_MODE",
    )

    ####   traitement de IMPR_TABLE   ##############################
    # Résorption de la sensibilité
    removeMotCle(jdc, "IMPR_TABLE", "SENSIBILITE", pasDeRegle(), 0)
    # Renommage critere table
    dCRIT = {"ABS_MAXI": "MAXI_ABS", "ABS_MINI": "MINI_ABS"}
    changementValeurDsMCF(jdc, "IMPR_TABLE", "FILTRE", "CRIT_COMP", dCRIT)
    # Suppression de FORMAT_C
    genereErreurMCF(jdc, "IMPR_TABLE", "FORMAT_C")

    ####   traitement de INCLUDE   ##############################
    # Rien à faire

    ####   traitement de INCLUDE_MATERIAU   ##############################
    # Rien à faire

    ####   traitement de INFO_EXEC_ASTER   ##############################
    # Rien à faire

    ####   traitement de INFO_FONCTION   ##############################
    # Rien à faire

    ####   traitement de INFO_MODE   ##############################
    # Rien à faire, n'existe pas en 10

    ####   traitement de LIRE_CHAMP   ##############################
    # Rien à faire

    ####   traitement de LIRE_FONCTION   ##############################
    # Rien à faire

    ####   traitement de LIRE_IMPE_MISS   ##############################
    # Rien à faire

    ####   traitement de LIRE_INTE_SPEC   ##############################
    # Rien à faire

    ####   traitement de LIRE_MAILLAGE   ##############################
    # Rien à faire

    ####   traitement de LIRE_RESU   ##############################
    # Suppression du type HARM_GENE
    genereErreurValeur(jdc, "LIRE_RESU", "TYPE_RESU", ("'HARM_GENE'",))
    # renommage de MATR_A et MATR_B
    renameMotCle(jdc, "LIRE_RESU", "MATR_A", "MATR_RIGI")
    renameMotCle(jdc, "LIRE_RESU", "MATR_B", "MATR_MASS")
    removeMotCle(jdc, "LIRE_RESU", "NUME_DDL", pasDeRegle(), 0)
    # Suppression de certains champ
    lSUPCHAMPS = [
        "'EFCA_ELNO'",
        "'EFCA_NOEU'",
        "'EPTQ_ELNO'",
        "'EPTU_ELNO'",
        "'PMPB_ELNO'",
        "'PMPB_NOEU'",
        "'SITQ_ELNO'",
        "'SICA_ELNO'",
        "'SICO_ELNO'",
        "'SITU_ELNO'",
        "'SICA_NOEU'",
        "'SICO_NOEU'",
        "'SPMX_ELGA'",
        "'VACO_ELNO'",
        "'VATU_ELNO'",
    ]
    genereErreurValeurDsMCF(jdc, "LIRE_RESU", "FORMAT_IDEAS", "NOM_CHAM", lSUPCHAMPS)
    genereErreurValeurDsMCF(jdc, "LIRE_RESU", "FORMAT_MED", "NOM_CHAM", lSUPCHAMPS)
    genereErreurValeur(jdc, "LIRE_RESU", "NOM_CHAM", lSUPCHAMPS)

    ####   traitement de LIRE_TABLE   ##############################
    # Rien à faire

    ####   traitement de MACR_ADAP_MAIL   ##############################
    # Résorption de la sensibilité
    removeMotCle(jdc, "MACR_ADAP_MAIL", "SENSIBILITE", pasDeRegle(), 0)
    # Changement de version
    changementValeur(jdc, "MACR_ADAP_MAIL", "VERSION_HOMARD", {"V10_1": "V10_6"})
    # Changement d'adaptation
    changementValeur(
        jdc, "MACR_ADAP_MAIL", "ADAPTATION", {"RAFFINEMENT_ZONE": "RAFF_DERA_ZONE"}
    )
    # Renommage du mot-clé ELEMENTS_NON_HOMARD
    renameMotCle(jdc, "MACR_ADAP_MAIL", "ELEMENTS_NON_HOMARD", "ELEMENTS_ACCEPTES")
    changementValeur(
        jdc,
        "MACR_ADAP_MAIL",
        "ELEMENTS_ACCEPTES",
        {"REFUSER": "HOMARD", "IGNORER": "IGNORE_PYRA"},
    )

    ####   traitement de MACR_ASCOUF_CALC   ##############################
    # Rien à faire

    ####   traitement de MACR_ASCOUF_MAIL   ##############################
    # Rien à faire

    ####   traitement de MACR_ASPIC_CALC   ##############################
    # Rien à faire

    ####   traitement de MACR_ASPIC_MAIL   ##############################
    # Rien à faire

    ####   traitement de MACR_CARA_POUTRE   ##############################
    renameMotCle(jdc, "MACR_CARA_POUTRE", "SYME_Y", "SYME_ZZ")
    renameMotCle(jdc, "MACR_CARA_POUTRE", "SYME_X", "SYME_Y")
    renameMotCle(jdc, "MACR_CARA_POUTRE", "SYME_ZZ", "SYME_Z")

    ####   traitement de MACR_ECLA_PG   ##############################
    # Rien à faire

    ####   traitement de MACR_ECRE_CALC   ##############################
    # Changement de version
    changementValeur(
        jdc,
        "MACR_ECRE_CALC",
        "VERSION",
        {"3.1.1": "3.2.1", "3.1.2": "3.2.1", "3.2": "3.2.1"},
    )

    ####   traitement de MACR_ECREVISSE   ##############################
    # Changement de version
    changementValeur(
        jdc,
        "MACR_ECRE_CALC",
        "VERSION",
        {"3.1.1": "3.2.1", "3.1.2": "3.2.1", "3.2": "3.2.1"},
    )

    ####   traitement de MACR_ELEM_DYNA   ##############################
    # Rien à faire

    ####   traitement de MACR_FIABILITE   ##############################
    genereErreurPourCommande(jdc, ("MACR_FIABILITE",))

    ####   traitement de MACR_FIAB_IMPR   ##############################
    genereErreurPourCommande(jdc, ("MACR_FIAB_IMPR",))

    ####   traitement de MACR_INFO_MAIL   ##############################
    # Changement de version
    changementValeur(jdc, "MACR_INFO_MAIL", "VERSION_HOMARD", {"V10_1": "V10_6"})
    # Renommage du mot-clé ELEMENTS_NON_HOMARD
    renameMotCle(jdc, "MACR_INFO_MAIL", "ELEMENTS_NON_HOMARD", "ELEMENTS_ACCEPTES")
    changementValeur(
        jdc,
        "MACR_INFO_MAIL",
        "ELEMENTS_ACCEPTES",
        {"REFUSER": "HOMARD", "IGNORER": "IGNORE_PYRA"},
    )

    ####   traitement de MACR_LIGP_COUPE   ##############################
    # Rien à faire

    ####   traitement de MACRO_ELAS_MULT   ##############################
    # Résorption de NUME_COUCHE NIVE_COUCHE
    removeMotCleInFact(
        jdc, "MACRO_ELAS_MULT", "CAS_CHARGE", "NUME_COUCHE", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "MACRO_ELAS_MULT", "CAS_CHARGE", "NIVE_COUCHE", pasDeRegle(), 0
    )
    # Réduction de la liste des options calculables
    lOPT = [
        "'EFGE_ELNO'",
        "'EPOT_ELEM'",
        "'SIGM_ELNO'",
        "'SICA_ELNO'",
        "'EFCA_ELNO'",
        "'DEGE_ELNO'",
        "'EPSI_ELNO'",
        "'EPSI_ELGA'",
        "'EPSG_ELNO'",
        "'EPSG_ELGA'",
        "'EPSP_ELNO'",
        "'EPSP_ELGA'",
        "'ECIN_ELEM'",
        "'FLUX_ELGA'",
        "'FLUX_ELNO'",
        "'SOUR_ELGA'",
        "'PRAC_ELNO'",
        "'INTE_ELNO'",
        "'SIZ1_NOEU'",
        "'ERZ1_ELEM'",
        "'SIZ2_NOEU'",
        "'ERZ2_ELEM'",
        "'VNOR_ELEM_DEPL'",
        "'ERME_ELNO'",
        "'ERME_ELEM'",
        "'SIEQ_ELNO'",
        "'SIEQ_ELGA'",
        "'EPEQ_ELNO'",
        "'QIRE_ELEM'",
        "'QIRE_ELNO'",
        "'QIZ1_ELEM'",
        "'QIZ2_ELEM'",
        "'EPEQ_ELGA'",
        "'FORC_NODA'",
        "'REAC_NODA'",
        "'EPSI_NOEU'",
        "'SIGM_NOEU'",
        "'EFGE_NOEU'",
        "'SIEQ_NOEU'",
        "'EPEQ_NOEU'",
        "'FLUX_NOEU'",
    ]
    genereErreurValeurDsMCF(jdc, "MACRO_ELAS_MULT", "CAS_CHARGE", "OPTION", lOPT)

    ####   traitement de MACRO_EXPANS   ##############################
    # Rien à faire

    ####   traitement de MACRO_MATR_AJOU   ##############################
    # Rien à faire

    ####   traitement de MACRO_MATR_ASSE   ##############################
    # Suppression de paramètres mémoire
    removeMotCleInFact(
        jdc, "MACRO_MATR_ASSE", "SOLVEUR", "OUT_OF_CORE", pasDeRegle(), 0
    )
    removeMotCleInFact(
        jdc, "MACRO_MATR_ASSE", "SOLVEUR", "LIBERE_MEMOIRE", pasDeRegle(), 0
    )
    # Suppression de RIGI_MECA_LAGR
    genereErreurValeurDsMCF(
        jdc, "MACRO_MATR_ASSE", "MATR_ASSE", "OPTION", ("'RIGI_MECA_LAGR'",)
    )
    genereErreurMotCleInFact(jdc, "MACRO_MATR_ASSE", "MATR_ASSE", "THETA")
    genereErreurMotCleInFact(jdc, "MACRO_MATR_ASSE", "MATR_ASSE", "PROPAGATION")
    # Renommage de la commande
    renameCommande(
        jdc,
        "MACRO_MATR_ASSE",
        "ASSEMBLAGE",
    )

    ####   traitement de MACRO_MISS_3D   ##############################
    # Rien à faire

    ####   traitement de MACRO_MODE_MECA   ##############################
    # renommage de MATR_A et MATR_B
    renameMotCle(jdc, "MACRO_MODE_MECA", "MATR_A", "MATR_RIGI")
    renameMotCle(jdc, "MACRO_MODE_MECA", "MATR_B", "MATR_MASS")
    # Suppression des mot-clés FREQ_*
    renameMotCle(jdc, "MACRO_MODE_MECA", "CALC_FREQ", "CALCFREQ")
    moveMotCleFromFactToFather(jdc, "MACRO_MODE_MECA", "CALCFREQ", "FREQ_MIN")
    moveMotCleFromFactToFather(jdc, "MACRO_MODE_MECA", "CALCFREQ", "FREQ_MAX")
    fusionMotCleToFact(jdc, "MACRO_MODE_MECA", ("FREQ_MIN", "FREQ_MAX"), "FREQ")
    moveMotClefInOperToFact(
        jdc,
        "MACRO_MODE_MECA",
        "FREQ",
        "CALCFREQ",
    )
    renameMotCle(jdc, "MACRO_MODE_MECA", "CALCFREQ", "CALC_FREQ")
    removeMotCleInFact(
        jdc, "MACRO_MODE_MECA", "CALC_FREQ", "NB_BLOC_FREQ", pasDeRegle(), 0
    )
    renameMotCleInFact(
        jdc,
        "MACRO_MODE_MECA",
        "CALC_FREQ",
        "STOP_FREQ_VIDE",
        "STOP_BANDE_VIDE",
        pasDeRegle(),
        0,
    )
    # Renommage critere de Sturm
    changementValeurDsMCF(
        jdc,
        "MACRO_MODE_MECA",
        "VERI_MODE",
        "STURM",
        {
            "OUI": "GLOBAL",
        },
    )

    ####   traitement de MACRO_PROJ_BASE   ##############################
    renameMotCle(jdc, "MACRO_PROJ_BASE", "PROFIL", "STOCKAGE")
    # Renommage de la commande
    renameCommande(
        jdc,
        "MACRO_PROJ_BASE",
        "PROJ_BASE",
    )

    ####   traitement de MACR_RECAL   ##############################
    renameMotCle(jdc, "MACR_RECAL", "POIDS", "LIST_POIDS")

    ####   traitement de MACR_SPECTRE   ##############################
    # Rien à faire

    ####   traitement de MECA_STATIQUE   ##############################
    # Résorption de la sensibilité
    removeMotCle(jdc, "MECA_STATIQUE", "SENSIBILITE", pasDeRegle(), 0)

    ####   traitement de MODE_ITER_INV   ##############################
    # Résorption de la sensibilité
    removeMotCle(jdc, "MODE_ITER_INV", "SENSIBILITE", pasDeRegle(), 0)
    # renommage de MATR_A, MATR_B et MATR_C
    renameMotCleSiRegle(
        jdc,
        "MODE_ITER_INV",
        "MATR_A",
        "MATR_RIGI",
        ((("TYPE_RESU", "DYNAMIQUE", jdc), "MCaPourValeur"),),
        1,
    )
    renameMotCleSiRegle(
        jdc,
        "MODE_ITER_INV",
        "MATR_B",
        "MATR_MASS",
        ((("TYPE_RESU", "DYNAMIQUE", jdc), "MCaPourValeur"),),
        1,
    )
    renameMotCle(jdc, "MODE_ITER_INV", "MATR_C", "MATR_AMOR")
    renameMotCleSiRegle(
        jdc,
        "MODE_ITER_INV",
        "MATR_A",
        "MATR_RIGI",
        ((("TYPE_RESU", "MODE_FLAMB", jdc), "MCaPourValeur"),),
        1,
    )
    renameMotCleSiRegle(
        jdc,
        "MODE_ITER_INV",
        "MATR_B",
        "MATR_RIGI_GEOM",
        ((("TYPE_RESU", "MODE_FLAMB", jdc), "MCaPourValeur"),),
        1,
    )
    renameMotCleSiRegle(
        jdc,
        "MODE_ITER_INV",
        "CALC_FREQ",
        "CALC_CHAR_CRIT",
        (
            (("TYPE_RESU", "MODE_FLAMB", jdc), "MCaPourValeur")
            or (("TYPE_RESU", "GENERAL", jdc), "MCaPourValeur"),
        ),
        1,
    )
    renameMotCleInFact(
        jdc,
        "MODE_ITER_INV",
        "CALC_CHAR_CRIT",
        "NMAX_FREQ",
        "NMAX_CHAR_CRIT",
        pasDeRegle(),
        0,
    )
    renameMotCleInFact(
        jdc,
        "MODE_ITER_INV",
        "CALC_CHAR_CRIT",
        "SEUIL_FREQ",
        "SEUIL_CHAR_CRIT",
        pasDeRegle(),
        0,
    )
    renameMotCle(jdc, "MODE_ITER_INV", "MATR_A", "MATR_RIGI")
    renameMotCle(jdc, "MODE_ITER_INV", "MATR_B", "MATR_MASS")

    ####   traitement de MODE_ITER_SIMULT   ##############################
    # Résorption de la sensibilité
    removeMotCle(jdc, "MODE_ITER_SIMULT", "SENSIBILITE", pasDeRegle(), 0)
    # renommage de MATR_A, MATR_B et MATR_C
    renameMotCleSiRegle(
        jdc,
        "MODE_ITER_SIMULT",
        "MATR_A",
        "MATR_RIGI",
        ((("TYPE_RESU", "DYNAMIQUE", jdc), "MCaPourValeur"),),
        1,
    )
    renameMotCleSiRegle(
        jdc,
        "MODE_ITER_SIMULT",
        "MATR_B",
        "MATR_MASS",
        ((("TYPE_RESU", "DYNAMIQUE", jdc), "MCaPourValeur"),),
        1,
    )
    renameMotCle(jdc, "MODE_ITER_SIMULT", "MATR_C", "MATR_AMOR")
    renameMotCleSiRegle(
        jdc,
        "MODE_ITER_SIMULT",
        "MATR_A",
        "MATR_RIGI",
        ((("TYPE_RESU", "MODE_FLAMB", jdc), "MCaPourValeur"),),
        1,
    )
    renameMotCleSiRegle(
        jdc,
        "MODE_ITER_SIMULT",
        "MATR_B",
        "MATR_RIGI_GEOM",
        ((("TYPE_RESU", "MODE_FLAMB", jdc), "MCaPourValeur"),),
        1,
    )
    renameMotCleSiRegle(
        jdc,
        "MODE_ITER_SIMULT",
        "CALC_FREQ",
        "CALC_CHAR_CRIT",
        (
            (("TYPE_RESU", "MODE_FLAMB", jdc), "MCaPourValeur")
            or (("TYPE_RESU", "GENERAL", jdc), "MCaPourValeur"),
        ),
        1,
    )
    renameMotCleInFact(
        jdc,
        "MODE_ITER_SIMULT",
        "CALC_CHAR_CRIT",
        "NMAX_FREQ",
        "NMAX_CHAR_CRIT",
        pasDeRegle(),
        0,
    )
    renameMotCleInFact(
        jdc,
        "MODE_ITER_SIMULT",
        "CALC_CHAR_CRIT",
        "SEUIL_FREQ",
        "SEUIL_CHAR_CRIT",
        pasDeRegle(),
        0,
    )
    renameMotCle(jdc, "MODE_ITER_SIMULT", "MATR_A", "MATR_RIGI")
    renameMotCle(jdc, "MODE_ITER_SIMULT", "MATR_B", "MATR_MASS")
    # renommage STOP_FREQ_VIDE
    renameMotCle(jdc, "MODE_ITER_SIMULT", "STOP_FREQ_VIDE", "STOP_BANDE_VIDE")

    ####   traitement de MODE_STATIQUE   ##############################
    # renommage du mot-clé FREQ
    renameMotCleInFact(
        jdc, "MODE_STATIQUE", "MODE_INTERF", "FREQ", "SHIFT", pasDeRegle(), 0
    )

    ####   traitement de MODI_MODELE_XFEM   ##############################
    genereErreurValeur(jdc, "MODI_MODELE_XFEM", "CONTACT", ("'P1P1A'",))

    ####   traitement de MODI_REPERE   ##############################
    # renommage de DEFI_REPERE
    renameMotCle(jdc, "MODI_REPERE", "DEFI_REPERE", "AFFE")
    moveMotCleFromFactToFather(jdc, "MODI_REPERE", "AFFE", "REPERE")
    # localisation dans AFFE
    moveMotClefInOperToFact(
        jdc,
        "MODI_REPERE",
        "GROUP_MA",
        "AFFE",
    )
    moveMotClefInOperToFact(
        jdc,
        "MODI_REPERE",
        "GROUP_NO",
        "AFFE",
    )
    moveMotClefInOperToFact(
        jdc,
        "MODI_REPERE",
        "MAILLE",
        "AFFE",
    )
    moveMotClefInOperToFact(
        jdc,
        "MODI_REPERE",
        "NOEUD",
        "AFFE",
    )

    ####   traitement de NORM_MODE   ##############################
    removeMotCle(jdc, "NORM_MODE", "SENSIBILITE", pasDeRegle(), 0)

    ####   traitement de NUME_DDL   ##############################
    # Rien à faire

    ####   traitement de NUME_DDL_GENE   ##############################
    # Rien à faire

    ####   traitement de OBSERVATION   ##############################
    # renommage de MATR_A et MATR_B
    renameMotCle(jdc, "OBSERVATION", "MATR_A", "MATR_RIGI")
    renameMotCle(jdc, "OBSERVATION", "MATR_B", "MATR_MASS")

    ####   traitement de POST_BORDET   ##############################
    # Rien à faire

    ####   traitement de POST_CHAMP   ##############################
    # Rien à faire, n'existe pas en 10

    ####   traitement de POST_CHAM_XFEM   ##############################
    # Suppression mot-clé MAILLAGE_SAIN
    removeMotCle(jdc, "POST_CHAM_XFEM", "MAILLAGE_SAIN", pasDeRegle(), 0)

    ####   traitement de POST_COQUE   ##############################
    # Rien à faire

    ####   traitement de POST_DECOLLEMENT   ##############################
    # Rien à faire

    ####   traitement de POST_DYNA_ALEA   ##############################
    # Suppression du mot-clé NUME_VITE_FLUI
    removeMotCle(jdc, "POST_DYNA_ALEA", "NUME_VITE_FLUI", pasDeRegle(), 0)

    ####   traitement de POST_ELEM   ##############################
    # Rien à faire

    ####   traitement de POST_ENDO_FISS   ##############################
    # Suppression du mot-clé MODELE
    removeMotCle(jdc, "POST_ENDO_FISS", "MODELE", pasDeRegle(), 0)
    # Renommage de SEUIL
    renameMotCleInFact(
        jdc, "POST_ENDO_FISS", "RECHERCHE", "SEUIL", "BORNE_MIN", pasDeRegle(), 0
    )

    ####   traitement de POST_FATIGUE   ##############################
    # Suppression du chargement periodique
    genereErreurValeur(jdc, "POST_FATIGUE", "CHARGEMENT", ("'PERIODIQUE'",))

    ####   traitement de POST_GP   ##############################
    # Suppression de POST_GP au profit de CALC_GP
    genereErreurPourCommande(jdc, ("POST_GP",))

    ####   traitement de POST_K1_K2_K3   ##############################
    # Suppression de VECT_K1
    removeMotCle(jdc, "POST_K1_K2_K3", "VECT_K1", pasDeRegle(), 0)
    # Suppression de SYME_CHAR
    removeMotCle(jdc, "POST_K1_K2_K3", "SYME_CHAR", pasDeRegle(), 0)
    # Suppression de TABL_DEPL
    removeMotCle(jdc, "POST_K1_K2_K3", "TABL_DEPL_SUP", pasDeRegle(), 0)
    removeMotCle(jdc, "POST_K1_K2_K3", "TABL_DEPL_INF", pasDeRegle(), 0)
    # Suppression de MAILLAGE
    removeMotCle(jdc, "POST_K1_K2_K3", "MAILLAGE", pasDeRegle(), 0)
    # Suppression de DTAN
    removeMotCle(jdc, "POST_K1_K2_K3", "DTAN_ORIG", pasDeRegle(), 0)
    removeMotCle(jdc, "POST_K1_K2_K3", "DTAN_EXTR", pasDeRegle(), 0)

    ####   traitement de POST_K_TRANS   ##############################
    # Suppression de la possibilité de donner un mode_meca
    genereErreurMotCleInFact(jdc, "POST_K_TRANS", "K_MODAL", "RESU_MODA")

    ####   traitement de POST_MAC3COEUR   ##############################
    # Rien à faire, n'existe pas en 10

    ####   traitement de POST_MAIL_XFEM   ##############################
    # Suppression du mot-clé MAILLAGE_SAIN
    removeMotCle(jdc, "POST_MAIL_XFEM", "MAILLAGE_SAIN", pasDeRegle(), 0)

    ####   traitement de POST_RCCM   ##############################
    # Rien à faire

    ####   traitement de POST_RELEVE_T   ##############################
    # Résorption de la sensibilité
    removeMotCle(jdc, "POST_RELEVE_T", "SENSIBILITE", pasDeRegle(), 0)

    ####   traitement de POST_RUPTURE   ##############################
    # Rien à faire, n'existe pas en 10

    ####   traitement de POST_USURE   ##############################
    # Rien à faire

    ####   traitement de POURSUITE   ##############################
    # Suppression du mot-clé TITRE
    removeMotCleInFact(jdc, "POURSUITE", "CATALOGUE", "TITRE", pasDeRegle(), 0)
    removeMotCle(jdc, "POURSUITE", "IMPRESSION", pasDeRegle(), 0)
    # Suppression des mots-clés mémoire dynamique
    removeMotCleInFact(jdc, "POURSUITE", "MEMOIRE", "GESTION", pasDeRegle(), 0)
    removeMotCleInFact(jdc, "POURSUITE", "MEMOIRE", "TYPE_ALLOCATION", pasDeRegle(), 0)
    removeMotCleInFact(jdc, "POURSUITE", "MEMOIRE", "TAILLE", pasDeRegle(), 0)
    removeMotCleInFact(jdc, "POURSUITE", "MEMOIRE", "PARTITION", pasDeRegle(), 0)
    removeMotCleInFact(jdc, "POURSUITE", "MEMOIRE", "DYNAMIQUE", pasDeRegle(), 0)

    ####   traitement de PROJ_BASE   ##############################
    # Suppression de RESU_GENE pour défaut de validation
    genereErreurMCF(jdc, "PROJ_BASE", "RESU_GENE")

    ####   traitement de PROJ_CHAMP   ##############################
    # Résorption de la sensibilité
    removeMotCle(jdc, "PROJ_CHAMP", "SENSIBILITE", pasDeRegle(), 0)

    ####   traitement de PROJ_RESU_BASE   ##############################
    # Suppression de RESU_GENE pour défaut de validation
    genereErreurMCF(jdc, "PROJ_RESU_BASE", "RESU_GENE")

    ####   traitement de PROJ_SPEC_BASE   ##############################
    # Rien à faire

    ####   traitement de PROPA_FISS   ##############################
    # Suppression de DTAN_ORIG et DTAN_EXTR pour calcul automatique
    removeMotCleInFact(jdc, "PROPA_FISS", "FISSURE", "DTAN_ORIG", pasDeRegle(), 0)
    removeMotCleInFact(jdc, "PROPA_FISS", "FISSURE", "DTAN_EXTR", pasDeRegle(), 0)

    ####   traitement de PROPA_XFEM   ##############################
    # Suppression paramètres Loi de Paris
    removeMotCle(jdc, "PROPA_XFEM", "NB_POINT_FOND", pasDeRegle(), 0)
    removeMotCle(jdc, "PROPA_XFEM", "TABLE", pasDeRegle(), 0)
    removeMotCle(jdc, "PROPA_XFEM", "LOI_PROPA", pasDeRegle(), 0)
    removeMotCle(jdc, "PROPA_XFEM", "COMP_LINE", pasDeRegle(), 0)

    ####   traitement de RAFF_XFEM   ##############################
    # Rien à faire

    ####   traitement de RECU_FONCTION   ##############################
    # Résorption de la sensibilité
    removeMotCle(jdc, "RECU_FONCTION", "SENSIBILITE", pasDeRegle(), 0)
    # Renommage critere table
    dCRIT = {"ABS_MAXI": "MAXI_ABS", "ABS_MINI": "MINI_ABS"}
    changementValeurDsMCF(jdc, "RECU_FONCTION", "FILTRE", "CRIT_COMP", dCRIT)

    ####   traitement de RECU_GENE   ##############################
    # Rien à faire

    ####   traitement de RESOUDRE   ##############################
    # Suppression d'algo pour PETSc
    removeMotCleSiRegle(
        jdc,
        "RESOUDRE",
        "ALGORITHME",
        (
            (
                (
                    "BCGS",
                    "BICG",
                    "TFQMR",
                ),
                "MCaPourValeur",
            ),
        ),
    )

    ####   traitement de REST_SPEC_PHYS   ##############################
    # Rien à faire

    ####   traitement de SIMU_POINT_MAT   ##############################
    # VALE_REF obligatoire si NOM_VARC in ('TEMP', 'SECH')
    lNOMVARC = ["CORR", "IRRA", "HYDR", "EPSA", "M_ACIER", "M_ZIRC", "NEUT1", "NEUT2"]
    removeMotCleInFactSiRegle(
        jdc,
        "SIMU_POINT_MAT",
        "AFFE_VARC",
        "VALE_REF",
        ((("NOM_VARC", lNOMVARC, jdc), "MCsousMCFcourantaPourValeurDansListe"),),
    )
    # Suppression de ARCHIVAGE/DETR_NUME_SUIV
    removeMotCleInFact(
        jdc, "SIMU_POINT_MAT", "ARCHIVAGE", "DETR_NUME_SUIV", pasDeRegle(), 0
    )

    ####   traitement de STANLEY   ##############################
    # Rien à faire

    ####   traitement de STAT_NON_LINE   ##############################
    # Renommage de IMPLEX
    changementValeur(jdc, "STAT_NON_LINE", "METHODE", {"IMPL_EX": "IMPLEX"})
    removeMotCle(jdc, "STAT_NON_LINE", "IMPL_EX", pasDeRegle(), 0)
    # Renommage CRIT_FLAMB en CRIT_STAB
    renameMotCle(jdc, "STAT_NON_LINE", "CRIT_FLAMB", "CRIT_STAB")
    # Résorption de la sensibilité
    removeMotCle(jdc, "STAT_NON_LINE", "SENSIBILITE", pasDeRegle(), 0)
    # Déplacement du calcul d'erreur en temps ERRE_TEMPS
    chercheOperInsereFacteurSiRegle(
        jdc,
        "STAT_NON_LINE",
        "CRIT_QUALITE",
        ((("INCREMENT", "ERRE_TEMPS"), "existeMCsousMCF"),),
        1,
    )
    moveMotCleFromFactToFact(
        jdc, "STAT_NON_LINE", "INCREMENT", "ERRE_TEMPS", "CRIT_QUALITE"
    )
    renameMotCleInFact(
        jdc,
        "STAT_NON_LINE",
        "CRIT_QUALITE",
        "ERRE_TEMPS",
        "ERRE_TEMPS_THM",
        pasDeRegle(),
        0,
    )
    removeMotCleInFact(jdc, "STAT_NON_LINE", "INCREMENT", "ERRE_TEMPS", pasDeRegle(), 0)
    # Suppression de ARCHIVAGE/DETR_NUME_SUIV
    removeMotCleInFact(
        jdc, "STAT_NON_LINE", "ARCHIVAGE", "DETR_NUME_SUIV", pasDeRegle(), 0
    )

    ####   traitement de THER_LINEAIRE   ##############################
    # Résorption de la sensibilité
    removeMotCle(jdc, "THER_LINEAIRE", "SENSIBILITE", pasDeRegle(), 0)
    removeMotCle(jdc, "THER_LINEAIRE", "SENS_INIT", pasDeRegle(), 0)
    # Suppression de ARCHIVAGE/DETR_NUME_SUIV
    removeMotCleInFact(
        jdc, "THER_LINEAIRE", "ARCHIVAGE", "DETR_NUME_SUIV", pasDeRegle(), 0
    )

    ####   traitement de THER_NON_LINE   ##############################
    # Résorption de la sensibilité
    removeMotCle(jdc, "THER_NON_LINE", "SENSIBILITE", pasDeRegle(), 0)
    # Suppression du mot clé OPTION   ######################################
    moveMCFToCommand(jdc, "THER_NON_LINE", "OPTION", "CALC_CHAMP", "THERMIQUE")
    # Suppression de ARCHIVAGE/DETR_NUME_SUIV
    removeMotCleInFact(
        jdc, "THER_NON_LINE", "ARCHIVAGE", "DETR_NUME_SUIV", pasDeRegle(), 0
    )

    ####   traitement de THER_NON_LINE_MO   ##############################
    # Rien à faire

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
