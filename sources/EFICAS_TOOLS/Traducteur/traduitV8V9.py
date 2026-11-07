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
  python traduitV7V8.py --infile=xxxx --outfile=yyyy
"""

import argparse  # optparse deprecated since Python version 3.2
import sys

import Traducteur.log as log
from load import getJDC
from mocles import parseKeywords
from removemocle import *
from renamemocle import *
from renamemocle import *
from inseremocle import *
from changeValeur import *
from movemocle import *
from dictErreurs import genereErreurPourCommande, genereErreurMotCleInFact

import calcG


atraiter = (
    "DEFI_MAILLAGE",
    "CALC_VECT_ELEM",
    "DYNA_TRAN_EXPLI",
    "DYNA_NON_LINE",
    "STAT_NON_LINE",
    "FACT_LDLT",
    "FACT_GRAD",
    "RESO_LDLT",
    "RESO_GRAD",
    "DYNA_TRAN_MODAL",
    "NORM_MODE",
    "MACRO_MODE_MECA",
    "POST_RCCM",
    "THER_NON_LINE",
    "THER_NON_LINE_MO",
    "THER_LINEAIRE",
    "THER_NON_LINE_MO",
    "DEFI_CABLE_BP",
    "GENE_VARI_ALEA",
    "DEFI_MATERIAU",
    "IMPR_MATRICE",
    "CALC_G",
    "CALC_MATR_ELEM",
    "MACR_ADAP_MAIL",
    "MACR_INFO_MAIL",
    "REST_BASE_PHYS",
    "COMB_SISM_MODAL",
    "TEST_FICHIER",
    "MACR_ELEM_DYNA",
    "CREA_CHAMP",
    "AFFE_CHAR_MECA",
    "AFE_CHAR_MECA_F",
    "MODI_MAILLAGE",
    "DEFI_FISS_XFEM",
    "AFFE_MODELE",
    "POST_MAIL_XFEM",
    "CALC_NO",
    "LIRE_CHAMP",
    "AFFE_MATERIAU",
    "MACR_ASCOUF_CALC",
    "MACR_ASPIC_CALC",
    "CALC_PRECONT",
    "LIRE_INTE_SPEC",
    "MACR_CARA_POUTRE",
    "MACR_LIGP_COUPE",
)

dict_erreurs = {
    # STA9
    "POST_RCCM_SITUATION_NUME_PASSAGE": "Utilisation de NUME_PASSAGE pour le type TUYAUTERIE impossible en 9.2. On ne traite pour le moment que les chemins de passage simples.",
    "POST_RCCM_SITUATION_NB_CYCL_SEISME": "POST_RCCM : maintenant les SITUATIONS sismiques ont leur propre mot clef facteur SEISME, attention, traduction incomplete",
    "DEFI_MATERIAU_BAZANT_FD": "le materiau BAZANT_FD a ete supprime",
    "DEFI_MATERIAU_APPUI_ELAS": "le materiau APPUI_ELAS a ete supprime",
    "DEFI_MATERIAU_PORO_JOINT": "le materiau PORO_JOINT a ete supprime",
    "DEFI_MATERIAU_ZIRC_CYRA2": "le materiau ZIRC_CYRA2 a ete supprime",
    "DEFI_MATERIAU_ZIRC_EPRI": "le materiau ZIRC_EPRI a ete supprime",
    "IMPR_MATRICE_MATR_ELEM_FORMAT=RESULTAT": "IMPR_MATRICE au format RESULTAT a ete supprime",
    "IMPR_MATRICE_MATR_ASSE_FORMAT=RESULTAT": "IMPR_MATRICE au format RESULTAT a ete supprime",
    "CALC_G_OPTION=G_LAGR": "l'OPTION G_LAGR de CALC_G a ete supprimee",
    "CALC_G_OPTION=G_LAGR_GLOB": "l'OPTION G_LAGR_GLOB de CALC_G a ete supprimee",
    "CALC_MATR_ELEM_THETA": "l'OPTION RIGI_MECA_LAGR de CALC_MATR_ELEM a ete supprimee",
    "TEST_FICHIER_NB_CHIFFRE": "le fonctionnement de TEST_FICHIER a change entre la V8 et la V9, consultez la doc, en particulier pour entrer la bonne valeur de NB_VALE",
    "DYNA_NON_LINE_PILOTAGE": "le PILOTAGE n'est pas actif dans DYNA_NON_LINE ",
    "DYNA_NON_LINE_RECH_LINEAIRE": "la RECH_LINEAIRE n'est pas active dans DYNA_NON_LINE ",
    "DEFI_FISS_XFEM_CONTACT": "en v9, le contact pour XFEM est defini dans un AFFE_CHAR_MECA(CONTACT=_F) en propre",
    "POST_MAIL_XFEM": "dans POST_MAIL_XFEM il faut entrer le MODELE et le MAILLAGE_SAIN",
    "AFFE_MATERIAU_AFFE_TEMP_REF": "Passage aux variables de commande : definir un materiau dependant de la temperature 'AFFE_MATERIAU(AFFE_VARC=_F(...))' et supprimer TEMP_CALCULEE dans les chargements",
    "STAT_NON_LINE_LAGR_NON_LOCAL": "Le solveur NON_LOCAL a ete supprime",
    "STAT_NON_LINE_SOLV_NON_LOCAL": "Le solveur NON_LOCAL a ete supprime",
    "STAT_NON_LINE_ETAT_INIT_VARI_NON_LOCAL": "Le solveur NON_LOCAL a ete supprime",
    "DYNA_NON_LINE_LAGR_NON_LOCAL": "Le solveur NON_LOCAL a ete supprime",
    "DYNA_NON_LINE_SOLV_NON_LOCAL": "Le solveur NON_LOCAL a ete supprime",
    "DYNA_NON_LINE_ETAT_INIT_VARI_NON_LOCAL": "Le solveur NON_LOCAL a ete supprime",
    "CALC_PRECONT_LAGR_NON_LOCAL": "Le solveur NON_LOCAL a ete supprime",
    "CALC_PRECONT_SOLV_NON_LOCAL": "Le solveur NON_LOCAL a ete supprime",
    "CALC_PRECONT_ETAT_INIT_VARI_NON_LOCAL": "Le solveur NON_LOCAL a ete supprime",
}

sys.dict_erreurs = dict_erreurs


def traduc(infile, outfile, flog=None):
    hdlr = log.initialise(flog)
    jdc = getJDC(infile, atraiter)
    root = jdc.root

    # Parse les mocles des commandes
    parseKeywords(root)

    ####################### traitement erreurs ########################
    genereErreurPourCommande(
        jdc,
        (
            "POST_RCCM",
            "DEFI_MATERIAU",
            "TEST_FICHIER",
            "DYNA_NON_LINE",
            "DEFI_FISS_XFEM",
            "POST_MAIL_XFEM",
        ),
    )

    ####################### traitement Sous-Structuration  #######################
    renameMotCleInFact(
        jdc, "DEFI_MAILLAGE", "DEFI_SUPER_MAILLE", "MACR_ELEM_STAT", "MACR_ELEM"
    )
    renameMotCleInFact(jdc, "DYNA_NON_LINE", "SOUS_STRUC", "MAILLE", "SUPER_MAILLE")
    renameMotCleInFact(jdc, "STAT_NON_LINE", "SOUS_STRUC", "MAILLE", "SUPER_MAILLE")
    renameMotCleInFact(jdc, "CALC_VECT_ELEM", "SOUS_STRUC", "MAILLE", "SUPER_MAILLE")
    #########################################################################

    ####################### traitement MACR_ELEM_DYNA #######################
    removeMotCle(jdc, "MACR_ELEM_DYNA", "OPTION")
    #########################################################################

    ####################### traitement MODI_MAILLAGE #######################
    renameMotCle(jdc, "MODI_MAILLAGE", "ORIE_SHB8", "ORIE_SHB")
    #########################################################################

    ####################### traitement XFEM #######################
    dXFEM = {"3D_XFEM": "3D", "C_PLAN_X": "C_PLAN", "D_PLAN_X": "D_PLAN"}
    changementValeurDsMCF(jdc, "AFFE_MODELE", "AFFE", "MODELISATION", dXFEM)
    renameMotCleInFact(jdc, "DEFI_FISS_XFEM", "ORIE_FOND", "PT_ORIGIN", "POINT_ORIG")
    removeMotCleAvecErreur(jdc, "DEFI_FISS_XFEM", "CONTACT")
    #########################################################################

    ####################### traitement Resolution lineaire #####################
    renameMotCle(jdc, "RESO_LDLT", "MATR_FACT", "MATR")
    renameMotCle(jdc, "RESO_GRAD", "MATR_ASSE", "MATR")
    renameMotCle(jdc, "RESO_GRAD", "MATR_FACT", "MATR_PREC")
    renameOper(jdc, "RESO_LDLT", "RESOUDRE")
    renameOper(jdc, "RESO_GRAD", "RESOUDRE")
    renameOper(jdc, "FACT_LDLT", "FACTORISER")
    renameOper(jdc, "FACT_GRAD", "FACTORISER")
    #########################################################################

    ####################### traitement DYNA_TRAN_MODAL ######################
    removeMotCle(jdc, "DYNA_TRAN_MODAL", "NB_MODE_DIAG")
    #########################################################################

    ############# traitement MASS_INER dans NORM_MODE/MACRO_MODE_MECA ##########
    removeMotCle(jdc, "NORM_MODE", "MASS_INER")
    removeMotCleInFact(jdc, "MACRO_MODE_MECA", "NORM_MODE", "MASS_INER")
    #########################################################################

    ####################### traitement POST_RCCM ############################
    removeMotCleInFactSiRegleAvecErreur(
        jdc,
        "POST_RCCM",
        "SITUATION",
        "NUME_PASSAGE",
        ((("TYPE_RESU_MECA", "TUYAUTERIE", jdc), "MCaPourValeur"),),
    )
    chercheOperInsereFacteurSiRegle(
        jdc,
        "POST_RCCM",
        "SEISME",
        ((("SITUATION", "NB_CYCL_SEISME"), "existeMCsousMCF"),),
    )
    moveMotCleFromFactToFact(jdc, "POST_RCCM", "SITUATION", "NB_CYCL_SEISME", "SEISME")
    #    ajouteMotClefDansFacteurSiRegle(jdc,"POST_RCCM","SITUATION", "transferez_au_bloc_SEISME_CHAR_ETAT_NB_OCCUR,NUME_SITU,NUME_GROUP_et_eventuellement_NOM_SITU_et_NUME_RESU_THER",((("SITUATION","NB_CYCL_SEISME"),"existeMCsousMCF"),))
    ajouteMotClefDansFacteurSiRegle(
        jdc,
        "POST_RCCM",
        "SITUATION",
        "supprimez_a_la_main_ce_bloc",
        ((("SITUATION", "NB_CYCL_SEISME"), "existeMCsousMCF"),),
    )
    #    removeMotCleInFactSiRegleAvecErreur(jdc,"POST_RCCM","SITUATION","NB_CYCL_SEISME",((("SITUATION","NB_CYCL_SEISME"),"existeMCsousMCF"),))
    removeMotCleInFactSiRegle(
        jdc,
        "POST_RCCM",
        "SITUATION",
        "NB_CYCL_SEISME",
        ((("SITUATION", "NB_CYCL_SEISME"), "existeMCsousMCF"),),
    )
    removeMotCleInFact(
        jdc,
        "POST_RCCM",
        "CHAR_MECA",
        "TYPE_CHAR",
    )
    removeMotCleInFact(
        jdc,
        "POST_RCCM",
        "RESU_MECA",
        "TYPE_CHAR",
    )
    #########################################################################

    ####################### traitement THER_NON_LINE ############################
    renameMotCleInFact(jdc, "THER_NON_LINE", "TEMP_INIT", "NUME_INIT", "NUME_ORDRE")
    renameMotCle(
        jdc,
        "THER_NON_LINE",
        "TEMP_INIT",
        "ETAT_INIT",
    )
    renameMotCleInFact(jdc, "THER_NON_LINE", "INCREMENT", "NUME_INIT", "NUME_INST_INIT")
    renameMotCleInFact(jdc, "THER_NON_LINE", "INCREMENT", "NUME_FIN", "NUME_INST_FIN")

    renameMotCleInFact(jdc, "THER_NON_LINE_MO", "TEMP_INIT", "NUME_INIT", "NUME_ORDRE")
    renameMotCle(
        jdc,
        "THER_NON_LINE_MO",
        "TEMP_INIT",
        "ETAT_INIT",
    )
    #########################################################################

    ####################### traitement THER_LINEAIRE ############################
    renameMotCleInFact(jdc, "THER_LINEAIRE", "TEMP_INIT", "NUME_INIT", "NUME_ORDRE")
    renameMotCle(
        jdc,
        "THER_LINEAIRE",
        "TEMP_INIT",
        "ETAT_INIT",
    )
    renameMotCleInFact(jdc, "THER_LINEAIRE", "INCREMENT", "NUME_INIT", "NUME_INST_INIT")
    renameMotCleInFact(jdc, "THER_LINEAIRE", "INCREMENT", "NUME_FIN", "NUME_INST_FIN")
    renameMotCleInFact(jdc, "THER_LINEAIRE", "ARCHIVAGE", "LIST_ARCH", "LIST_INST")
    #########################################################################

    ####################### traitement THER_NON_LINE ############################
    renameMotCleInFact(jdc, "THER_NON_LINE", "TEMP_INIT", "NUME_INIT", "NUME_ORDRE")
    renameMotCle(
        jdc,
        "THER_NON_LINE",
        "TEMP_INIT",
        "ETAT_INIT",
    )
    #########################################################################

    ####################### traitement DEFI_CABLE_BP ######################
    removeMotCle(jdc, "DEFI_CABLE_BP", "MAILLAGE")
    #########################################################################

    ####################### traitement GENE_VARI_ALEA ######################
    removeMotCleSiRegle(
        jdc,
        "GENE_VARI_ALEA",
        "COEF_VAR",
        ((("TYPE", "EXPONENTIELLE", jdc), "MCaPourValeur"),),
    )
    #########################################################################

    ####################### traitement DEFI_MATERIAU ######################
    removeMotCleAvecErreur(jdc, "DEFI_MATERIAU", "BAZANT_FD")
    removeMotCleAvecErreur(jdc, "DEFI_MATERIAU", "PORO_JOINT")
    removeMotCleAvecErreur(jdc, "DEFI_MATERIAU", "APPUI_ELAS")
    removeMotCleAvecErreur(jdc, "DEFI_MATERIAU", "ZIRC_EPRI")
    removeMotCleAvecErreur(jdc, "DEFI_MATERIAU", "ZIRC_CYRA2")
    # BARCELONE
    moveMotCleFromFactToFact(jdc, "DEFI_MATERIAU", "CAM_CLAY", "MU", "BARCELONE")
    moveMotCleFromFactToFact(jdc, "DEFI_MATERIAU", "CAM_CLAY", "PORO", "BARCELONE")
    moveMotCleFromFactToFact(jdc, "DEFI_MATERIAU", "CAM_CLAY", "LAMBDA", "BARCELONE")
    moveMotCleFromFactToFact(jdc, "DEFI_MATERIAU", "CAM_CLAY", "KAPPA", "BARCELONE")
    moveMotCleFromFactToFact(jdc, "DEFI_MATERIAU", "CAM_CLAY", "M", "BARCELONE")
    moveMotCleFromFactToFact(jdc, "DEFI_MATERIAU", "CAM_CLAY", "PRES_CRIT", "BARCELONE")
    moveMotCleFromFactToFact(jdc, "DEFI_MATERIAU", "CAM_CLAY", "PA", "BARCELONE")
    renameMotCleInFact(jdc, "DEFI_MATERIAU", "CAM_CLAY", "PA", "KCAM")
    # CAM_CLAY
    #    ajouteMotClefDansFacteur(jdc,"DEFI_MATERIAU","CAM_CLAY","MU=xxx",)
    #    ajouteMotClefDansFacteurSiRegle(jdc,"DEFI_MATERIAU","CAM_CLAY","PTRAC=XXX",((("CAM_CLAY","KCAM"),"existeMCsousMCF"),))
    # VENDOCHAB
    renameMotCleInFact(jdc, "DEFI_MATERIAU", "VENDOCHAB", "S_VP", "S")
    renameMotCleInFact(jdc, "DEFI_MATERIAU", "VENDOCHAB", "N_VP", "N")
    renameMotCleInFact(jdc, "DEFI_MATERIAU", "VENDOCHAB", "M_VP", "UN_SUR_M", erreur=1)
    renameMotCleInFact(jdc, "DEFI_MATERIAU", "VENDOCHAB", "K_VP", "UN_SUR_K")
    renameMotCleInFact(jdc, "DEFI_MATERIAU", "VENDOCHAB", "SEDVP1", "ALPHA_D")
    renameMotCleInFact(jdc, "DEFI_MATERIAU", "VENDOCHAB", "SEDVP2", "BETA_D")
    renameMotCleInFact(jdc, "DEFI_MATERIAU", "VENDOCHAB_FO", "S_VP", "S")
    renameMotCleInFact(jdc, "DEFI_MATERIAU", "VENDOCHAB_FO", "N_VP", "N")
    renameMotCleInFact(
        jdc, "DEFI_MATERIAU", "VENDOCHAB_FO", "M_VP", "UN_SUR_M", erreur=1
    )
    renameMotCleInFact(jdc, "DEFI_MATERIAU", "VENDOCHAB_FO", "K_VP", "UN_SUR_K")
    renameMotCleInFact(jdc, "DEFI_MATERIAU", "VENDOCHAB_FO", "SEDVP1", "ALPHA_D")
    renameMotCleInFact(jdc, "DEFI_MATERIAU", "VENDOCHAB_FO", "SEDVP2", "BETA_D")
    # GLRC
    renameCommandeSiRegle(
        jdc,
        "DEFI_MATERIAU",
        "DEFI_GLRC",
        (
            (
                (
                    "GLRC_DAMAGE",
                    "GLRC_ACIER",
                ),
                "existeMCFParmi",
            ),
        ),
    )
    #########################################################################

    ####################### traitement IMPR_MATRICE ######################
    removeCommandeSiRegleAvecErreur(
        jdc,
        "IMPR_MATRICE",
        ((("MATR_ELEM", "FORMAT", "RESULTAT", jdc), "MCsousMCFaPourValeur"),),
    )
    removeCommandeSiRegleAvecErreur(
        jdc,
        "IMPR_MATRICE",
        ((("MATR_ASSE", "FORMAT", "RESULTAT", jdc), "MCsousMCFaPourValeur"),),
    )
    #########################################################################

    ####################### traitement MACR_ADAP/INFO_MAIL ######################
    dadap_mail = {"V8_5": "V9_5", "V8_N": "V9_N", "V8_N_PERSO": "V9_N_PERSO"}
    changementValeur(jdc, "MACR_ADAP_MAIL", "VERSION_HOMARD", dadap_mail)
    changementValeur(jdc, "MACR_INFO_MAIL", "VERSION_HOMARD", dadap_mail)
    #########################################################################

    ####################### traitement REST_BASE_PHYS ######################
    renameCommandeSiRegle(
        jdc,
        "REST_BASE_PHYS",
        "REST_SOUS_STRUC",
        (
            (
                (
                    "RESULTAT",
                    "SQUELETTE",
                    "SOUS_STRUC",
                    "BASE_MODALE",
                    "CYCLIQUE",
                    "SECTEUR",
                ),
                "existeMCFParmi",
            ),
        ),
    )
    renameCommandeSiRegle(
        jdc,
        "REST_BASE_PHYS",
        "REST_COND_TRAN",
        ((("MACR_ELEM_DYNA", "RESU_PHYS"), "existeMCFParmi"),),
    )
    renameCommande(
        jdc,
        "REST_BASE_PHYS",
        "REST_GENE_PHYS",
    )
    #########################################################################

    ####################### traitement CALC_G ######################
    removeMotCleSiRegleAvecErreur(
        jdc, "CALC_G", "OPTION", ((("OPTION", "G_LAGR", jdc), "MCaPourValeur"),)
    )
    removeMotCleSiRegleAvecErreur(
        jdc, "CALC_G", "OPTION", ((("OPTION", "G_LAGR_GLOB", jdc), "MCaPourValeur"),)
    )
    removeMotCle(jdc, "CALC_G", "PROPAGATION")
    removeMotCle(jdc, "CALC_G", "THETA_LAGR")
    removeMotCle(jdc, "CALC_G", "DIRE_THETA_LAGR")
    #########################################################################

    ####################### traitement COMB_SISM_MODAL ######################
    ajouteMotClefDansFacteurSiRegle(
        jdc,
        "COMB_SISM_MODAL",
        "EXCIT",
        "MULTI_APPUI='DECORRELE'",
        ((("EXCIT", "MONO_APPUI"), "nexistepasMCsousMCF"),),
    )
    #########################################################################

    ####################### traitement TEST_FICHIER ######################
    renameMotCleAvecErreur(jdc, "TEST_FICHIER", "NB_CHIFFRE", "NB_VALE")
    removeMotCle(jdc, "TEST_FICHIER", "EPSILON")
    #########################################################################

    ####################### traitement CALC_MATR_ELEM ######################
    removeMotCleSiRegle(
        jdc,
        "CALC_MATR_ELEM",
        "OPTION",
        ((("OPTION", "RIGI_MECA_LAGR", jdc), "MCaPourValeur"),),
    )
    removeMotCleAvecErreur(jdc, "CALC_MATR_ELEM", "PROPAGATION")
    removeMotCle(jdc, "CALC_MATR_ELEM", "THETA")
    #########################################################################

    ####################### traitement ITER_INTE_PAS ######################
    removeMotCleInFactSiRegle(
        jdc,
        "STAT_NON_LINE",
        "COMP_INCR",
        "ITER_INTE_PAS",
        ((("COMP_INCR", "DEFORMATION", "SIMO_MIEHE", jdc), "MCsousMCFaPourValeur"),),
    )
    removeMotCleInFactSiRegle(
        jdc,
        "DYNA_NON_LINE",
        "COMP_INCR",
        "ITER_INTE_PAS",
        ((("COMP_INCR", "DEFORMATION", "SIMO_MIEHE", jdc), "MCsousMCFaPourValeur"),),
    )
    #########################################################################

    ################## traitement RECH_LINEAIRE et PILOTAGE dans DYNA_NON_LINE #################
    removeMotCleAvecErreur(jdc, "DYNA_NON_LINE", "RECH_LINEAIRE")
    removeMotCleAvecErreur(jdc, "DYNA_NON_LINE", "PILOTAGE")
    #########################################################################

    ####################### traitement DYNA_TRAN_EXPLI ######################
    renameOper(jdc, "DYNA_TRAN_EXPLI", "DYNA_NON_LINE")
    ajouteMotClefDansFacteur(
        jdc, "DYNA_NON_LINE", "TCHAMWA", "FORMULATION='ACCELERATION'"
    )
    ajouteMotClefDansFacteur(
        jdc, "DYNA_NON_LINE", "DIFF_CENT", "FORMULATION='ACCELERATION'"
    )
    #########################################################################

    ####################### traitement SCHEMA_TEMPS dans DYNA_NON_LINE ######################
    ajouteMotClefDansFacteur(
        jdc, "DYNA_NON_LINE", "NEWMARK", "FORMULATION='DEPLACEMENT'"
    )
    ajouteMotClefDansFacteur(jdc, "DYNA_NON_LINE", "HHT", "FORMULATION='DEPLACEMENT'")
    ajouteMotClefDansFacteur(
        jdc, "DYNA_NON_LINE", "TETA_METHODE", "FORMULATION='DEPLACEMENT'"
    )
    renameMotCleInFact(
        jdc,
        "DYNA_NON_LINE",
        "NEWMARK",
        "ALPHA",
        "BETA",
    )
    renameMotCleInFact(
        jdc,
        "DYNA_NON_LINE",
        "NEWMARK",
        "DELTA",
        "GAMMA",
    )
    renameMotCleInFact(
        jdc,
        "DYNA_NON_LINE",
        "TETA_METHODE",
        "TETA",
        "THETA",
    )
    ajouteMotClefDansFacteurSiRegle(
        jdc,
        "DYNA_NON_LINE",
        "NEWMARK",
        "SCHEMA='NEWMARK'",
        ((("NEWMARK",), "existeMCFParmi"),),
    )
    ajouteMotClefDansFacteurSiRegle(
        jdc,
        "DYNA_NON_LINE",
        "TETA_METHODE",
        "SCHEMA='THETA_METHODE'",
        ((("TETA_METHODE",), "existeMCFParmi"),),
    )
    ajouteMotClefDansFacteurSiRegle(
        jdc, "DYNA_NON_LINE", "HHT", "SCHEMA='HHT'", ((("HHT",), "existeMCFParmi"),)
    )
    ajouteMotClefDansFacteurSiRegle(
        jdc,
        "DYNA_NON_LINE",
        "TCHAMWA",
        "SCHEMA='TCHAMWA'",
        ((("TCHAMWA",), "existeMCFParmi"),),
    )
    ajouteMotClefDansFacteurSiRegle(
        jdc,
        "DYNA_NON_LINE",
        "DIFF_CENT",
        "SCHEMA='DIFF_CENT'",
        ((("DIFF_CENT",), "existeMCFParmi"),),
    )
    renameMotCle(jdc, "DYNA_NON_LINE", "NEWMARK", "SCHEMA_TEMPS")
    renameMotCle(jdc, "DYNA_NON_LINE", "TETA_METHODE", "SCHEMA_TEMPS")
    renameMotCle(jdc, "DYNA_NON_LINE", "HHT", "SCHEMA_TEMPS")
    renameMotCle(jdc, "DYNA_NON_LINE", "DIFF_CENT", "SCHEMA_TEMPS")
    renameMotCle(jdc, "DYNA_NON_LINE", "TCHAMWA", "SCHEMA_TEMPS")
    removeMotCleInFact(jdc, "DYNA_NON_LINE", "INCREMENT", "EVOLUTION")
    moveMotClefInOperToFact(jdc, "DYNA_NON_LINE", "STOP_CFL", "SCHEMA_TEMPS")
    #########################################################################

    ####################### traitement CONTACT ######################
    removeMotCleInFact(jdc, "DEFI_MATERIAU", "DIS_CONTACT", "KT_ULTM")
    removeMotCleInFact(jdc, "DEFI_MATERIAU", "DIS_CONTACT", "EFFO_N_INIT")
    removeMotCleInFact(jdc, "DEFI_MATERIAU", "DIS_CONTACT", "RIGI_N_IRRA")
    removeMotCleInFact(jdc, "DEFI_MATERIAU", "DIS_CONTACT", "RIGI_N_FO")
    removeMotCleInFact(jdc, "DEFI_MATERIAU", "DIS_CONTACT", "RIGI_MZ")
    removeMotCleInFact(jdc, "DEFI_MATERIAU", "DIS_CONTACT", "ANGLE_1")
    removeMotCleInFact(jdc, "DEFI_MATERIAU", "DIS_CONTACT", "ANGLE_2")
    removeMotCleInFact(jdc, "DEFI_MATERIAU", "DIS_CONTACT", "ANGLE_3")
    removeMotCleInFact(jdc, "DEFI_MATERIAU", "DIS_CONTACT", "ANGLE_4")
    removeMotCleInFact(jdc, "DEFI_MATERIAU", "DIS_CONTACT", "MOMENT_1")
    removeMotCleInFact(jdc, "DEFI_MATERIAU", "DIS_CONTACT", "MOMENT_2")
    removeMotCleInFact(jdc, "DEFI_MATERIAU", "DIS_CONTACT", "MOMENT_3")
    removeMotCleInFact(jdc, "DEFI_MATERIAU", "DIS_CONTACT", "MOMENT_4")
    removeMotCleInFact(jdc, "DEFI_MATERIAU", "DIS_CONTACT", "C_PRAGER_MZ")
    dDis_Choc = {"DIS_CONTACT": "DIS_CHOC"}
    changementValeurDsMCF(jdc, "STAT_NON_LINE", "COMP_INCR", "RELATION", dDis_Choc)
    changementValeurDsMCF(jdc, "DYNA_NON_LINE", "COMP_INCR", "RELATION", dDis_Choc)
    renameMotCleInFact(jdc, "STAT_NON_LINE", "COMP_INCR", "DIS_CONTACT", "DIS_CHOC")
    renameMotCleInFact(jdc, "DYNA_NON_LINE", "COMP_INCR", "DIS_CONTACT", "DIS_CHOC")
    dGrilles = {"GRILLE_CRAYONS": "DIS_GRICRA"}
    changementValeurDsMCF(jdc, "STAT_NON_LINE", "COMP_INCR", "RELATION", dGrilles)
    changementValeurDsMCF(jdc, "DYNA_NON_LINE", "COMP_INCR", "RELATION", dGrilles)

    renameCommandeSiRegle(
        jdc, "AFFE_CHAR_MECA_F", "AFFE_CHAR_MECA", ((("CONTACT",), "existeMCFParmi"),)
    )
    removeMotCleInFact(jdc, "AFFE_CHAR_MECA", "CONTACT", "RECHERCHE")
    removeMotCleInFact(jdc, "AFFE_CHAR_MECA", "CONTACT", "PROJECTION")
    removeMotCleInFact(jdc, "AFFE_CHAR_MECA", "CONTACT", "VECT_Y")
    removeMotCleInFact(jdc, "AFFE_CHAR_MECA", "CONTACT", "VECT_ORIE_POU")
    removeMotCleInFact(jdc, "AFFE_CHAR_MECA", "CONTACT", "MODL_AXIS")
    dAppariement = {"MAIT_ESCL_SYME": "MAIT_ESCL"}
    changementValeurDsMCF(jdc, "AFFE_CHAR_MECA", "CONTACT", "APPARIEMENT", dAppariement)

    ajouteMotClefDansFacteurSiRegle(
        jdc,
        "AFFE_CHAR_MECA",
        "CONTACT",
        "TYPE_APPA='FIXE'",
        (
            (
                (
                    "CONTACT",
                    "DIRE_APPA",
                ),
                "existeMCsousMCF",
            ),
        ),
    )
    #########################################################################

    ####################### traitement CREA_CHAMP ######################
    chercheOperInsereFacteurSiRegle(
        jdc,
        "CREA_CHAMP",
        "PRECISION=1.E-3,",
        (
            (("PRECISION",), "nexistepas"),
            (("CRITERE",), "existe"),
        ),
        0,
    )
    dTypeChamp = {"ELEM_ERREUR": "ELEM_ERRE_R"}
    changementValeur(jdc, "CREA_CHAMP", "TYPE_CHAM", dTypeChamp)
    #########################################################################

    ####################### traitement CALC_NO ######################
    chercheOperInsereFacteurSiRegle(
        jdc,
        "CALC_NO",
        "PRECISION=1.E-3,",
        (
            (("PRECISION",), "nexistepas"),
            (("CRITERE",), "existe"),
        ),
        0,
    )
    #########################################################################

    ######### traitement variables de commandes TEMP_CALCULEE/TEMP_REF ##############
    genereErreurMotCleInFact(jdc, "AFFE_MATERIAU", "AFFE", "TEMP_REF")
    ################################################################################

    ################# traitement LIRE_CHAMP  #######################################
    #    dTypeChamp={"ELEM_ERREUR":"ELEM_ERRE_R"}
    changementValeur(jdc, "LIRE_CHAMP", "TYPE_CHAM", dTypeChamp)
    ################################################################################

    ######### traitement SUIVI_DDL #################################################
    # en pre-traitement il faudrait une methode qui separe tous les mots clefs facteurs en les dupliquant
    # par exemple ici mettre autant de mots clefs facteurs SUIVI_DDL qu'il a de _F
    ajouteMotClefDansFacteur(jdc, "STAT_NON_LINE", "SUIVI_DDL", "SUIVI_DDL='OUI'")
    renameMotCle(jdc, "STAT_NON_LINE", "SUIVI_DDL", "OBSERVATION")
    # en post-traitement il faudrait une methode qui fusionne tous les mots clefs facteurs en double
    # par exemple ici les OBSERVATION
    ################################################################################

    ######### traitement EVOLUTION in STAT/DYNA_NON_LINE ###########################
    removeMotCleInFact(jdc, "STAT_NON_LINE", "INCREMENT", "EVOLUTION")
    removeMotCleInFact(jdc, "DYNA_NON_LINE", "INCREMENT", "EVOLUTION")
    ################################################################################

    ######### traitement du MODELE GRILLE ##############################################
    dGrille = {"GRILLE": "GRILLE_EXCENTRE"}
    changementValeurDsMCF(jdc, "AFFE_MODELE", "AFFE", "MODELISATION", dGrille)
    ################################################################################

    ######### traitement de MACR_ASPIC/ASCOUF_CALC GRILLE ##########################
    removeMotCle(jdc, "MACR_ASCOUF_CALC", "CHARGE")
    removeMotCle(jdc, "MACR_ASPIC_CALC", "CHARGE")
    ################################################################################

    ############ suppression de NON_LOCAL ##########################################
    removeMotCleAvecErreur(jdc, "STAT_NON_LINE", "LAGR_NON_LOCAL")
    removeMotCleAvecErreur(jdc, "STAT_NON_LINE", "SOLV_NON_LOCAL")
    removeMotCleInFact(jdc, "STAT_NON_LINE", "ETAT_INIT", "VARI_NON_LOCAL", erreur=1)

    removeMotCleAvecErreur(jdc, "DYNA_NON_LINE", "LAGR_NON_LOCAL")
    removeMotCleAvecErreur(jdc, "DYNA_NON_LINE", "SOLV_NON_LOCAL")
    removeMotCleInFact(jdc, "DYNA_NON_LINE", "ETAT_INIT", "VARI_NON_LOCAL", erreur=1)

    removeMotCleAvecErreur(jdc, "CALC_PRECONT", "LAGR_NON_LOCAL")
    removeMotCleAvecErreur(jdc, "CALC_PRECONT", "SOLV_NON_LOCAL")
    removeMotCleInFact(jdc, "CALC_PRECONT", "ETAT_INIT", "VARI_NON_LOCAL", erreur=1)
    ################################################################################

    ######### traitement de LIRE_INTE_SPEC #########################################
    renameMotCle(jdc, "LIRE_INTE_SPEC", "FORMAT", "FORMAT_C")
    ################################################################################

    ######### traitement de MACR_CARA_POUTRE  ######################################
    chercheOperInsereFacteurSiRegle(
        jdc, "MACR_CARA_POUTRE", "FORMAT='ASTER'", ((("UNITE_MAILLAGE",), "existe"),), 0
    )
    renameMotCle(jdc, "MACR_CARA_POUTRE", "UNITE_MAILLAGE", "UNITE")
    ################################################################################

    ######### traitement de MACR_LIGP_COUPE  ######################################
    # il y a un probleme s'il y a plusieurs mots clefs facteurs LIGP_COUPE : la regle ne marche qu'une fois par commande
    ajouteMotClefDansFacteurSiRegle(
        jdc,
        "MACR_LIGP_COUPE",
        "LIGP_COUPE",
        "REPERE='LOCAL'",
        (
            (
                (
                    "LIGP_COUPE",
                    "VECT_Y",
                ),
                "existeMCsousMCF",
            ),
        ),
        0,
    )
    # autre probleme : s'il y a plusieurs mots clefs facteurs le traducteur peut, dans l'insertion, se tromper de mot clef facteur
    ajouteMotClefDansFacteurSiRegle(
        jdc,
        "MACR_LIGP_COUPE",
        "LIGP_COUPE",
        "TYPE='GROUP_NO'",
        (
            (
                (
                    "LIGP_COUPE",
                    "GROUP_NO",
                ),
                "existeMCsousMCF",
            ),
        ),
        0,
    )
    ajouteMotClefDansFacteurSiRegle(
        jdc,
        "MACR_LIGP_COUPE",
        "LIGP_COUPE",
        "TYPE='GROUP_MA'",
        (
            (
                (
                    "LIGP_COUPE",
                    "GROUP_MA",
                ),
                "existeMCsousMCF",
            ),
        ),
        0,
    )
    ################################################################################

    ####################### traitement DRUCKER_PRAGER #######################
    dPRAGER = {
        "DRUCKER_PRAGER": "DRUCK_PRAGER",
    }
    changementValeurDsMCF(jdc, "STAT_NON_LINE", "COMP_INCR", "RELATION", dPRAGER)
    changementValeurDsMCF(jdc, "DYNA_NON_LINE", "COMP_INCR", "RELATION", dPRAGER)
    changementValeurDsMCF(jdc, "SIMU_POINT_MAT", "COMP_INCR", "RELATION", dPRAGER)
    changementValeurDsMCF(jdc, "CALC_PRECONT", "COMP_INCR", "RELATION", dPRAGER)
    #########################################################################

    ####################### traitement RELATION_KIT #######################
    dKIT = {
        "ELAS_THER": "ELAS",
    }
    changementValeurDsMCF(jdc, "STAT_NON_LINE", "COMP_INCR", "RELATION_KIT", dKIT)
    changementValeurDsMCF(jdc, "DYNA_NON_LINE", "COMP_INCR", "RELATION_KIT", dKIT)
    changementValeurDsMCF(jdc, "SIMU_POINT_MAT", "COMP_INCR", "RELATION_KIT", dKIT)
    changementValeurDsMCF(jdc, "CALC_PRECONT", "COMP_INCR", "RELATION_KIT", dKIT)
    #########################################################################

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
