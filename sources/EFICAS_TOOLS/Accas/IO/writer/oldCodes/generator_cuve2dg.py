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
    Ce module contient le plugin generateur de fichier au format 
    DefaillCUVE pour EFICAS.

"""
import traceback
import types,string,re

from Accas.processing import P_CR
from Accas import MCSIMP
from generator_python import PythonGenerator

def entryPoint():
   """
       Retourne les informations nécessaires pour le chargeur de plugins

       Ces informations sont retournées dans un dictionnaire
   """
   return {
        # Le nom du plugin
          'name' : 'cuve2dg',
        # La factory pour créer une instance du plugin
          'factory' : Cuve2dgGenerator,
          }


class Cuve2dgGenerator(PythonGenerator):
   """
       Ce generateur parcourt un objet de type JDC et produit
       un texte au format eficas et 
       un texte au format DefaillCUVE

   """
   # Les extensions de fichier préconisées
   extensions=('.comm',)

   def __init__(self,cr=None):
      # Si l'objet compte-rendu n'est pas fourni, on utilise le compte-rendu standard
      if cr :
         self.cr=cr
      else:
         self.cr=P_CR.CR(debut='CR generateur format DefaillCUVE pour DefaillCUVE',
                         fin='fin CR format DefaillCUVE pour DefaillCUVE')
      # Le texte au format DefaillCUVE est stocké dans l'attribut textCuve
      self.textCuve=''

      # Ce dictionnaire liste le nom des variables utilisees dans le script
      self.variable = {
         "NiveauImpression" : "MESSAGE_LEVEL",
	 "FichierDataIn"    : "DATARESUME_FILE",
	 "FichierTempSigma" : "TEMPSIG_FILE",
	 "FichierCSV"       : "CSV_FILE",
	 "FichierRESTART" : "RESTART_FILE",
	 "FichierEXTR" : "EXTR_FILE",
	 "ChoixPlugin" : "CHOIPLUG",
	 "GrandeurEvaluee" : "GRANDEUR",
	 "IncrementTemporel" : "INCRTPS",
	 "IncrementMaxTemperature" : "DTPREC",
	 "ChoixExtractionTransitoires" : "CHOIEXTR",
	 "IncrementMaxTempsAffichage" : "DTARCH",
	 "traitementGeometrie" : "TYPEGEOM",
	 "RayonInterne" : "RINT",
	 "RayonInterne_mess" : "RINT_MESSAGE",
	 "RayonExterne" : "REXT",
	 "RayonExterne_mess" : "REXT_MESSAGE",
	 "EpaisseurRevetement" : "LREV",
	 "EpaisseurRevetement_mess" : "LREV_MESSAGE",
	 "LigamentExterneMin" : "LIGMIN",
	 "LigamentExterneMin_mess" : "LIGMIN_MESSAGE",
	 "NombreNoeudsMaillage" : "NBNO",
	 "TypeInitial" : "TYPEDEF",
	 "Orientation" : "ORIEDEF",
	 "Position" : "POSDEF",
	 "ProfondeurRadiale" : "PROFDEF",
	 "ProfondeurRadiale_mess" : "PROFDEF_MESSAGE",
	 "ModeCalculLongueur" : "OPTLONG",
	 "Longueur" : "LONGDEF",
	 "Longueur_mess" : "LONGDEF_MESSAGE",
	 "CoefDirecteur" : "PROFSURLONG",
	 "CoefDirecteur_mess" : "PROFSURLONG_MESSAGE",
	 "Constante" : "LONGCONST",
	 "ModeCalculDecalage" : "DECATYP",
	 "DecalageNormalise" : "DECANOR",
	 "DecalageNormalise_mess" : "DECANOR_MESSAGE",
	 "DecalageRadial" : "DECADEF",
	 "DecalageRadial_mess" : "DECADEF_MESSAGE",
	 "Azimut" : "ANGLDEF",
	 "Azimut_mess" : "ANGLDEF_MESSAGE",
	 "Altitude_mess" : "ANGLDEF_MESSAGE",
	 "Altitude" : "ALTIDEF",
	 "Altitude_mess" : "ALTIDEF_MESSAGE",
	 "Pointe" : "POINDEF",
	 "ModeleFluence" : "MODELFLUENCE",
	 "ZoneActiveCoeur_AltitudeSup" : "H1COEUR",
	 "ZoneActiveCoeur_AltitudeInf" : "H2COEUR",
	 "FluenceMax" : "fmax",
	 "KPFrance" : "KPFRANCE",
	 "KPUS" : "KPUS",
	 "Azimut_0deg" : "COEFFLUENCE1",
	 "Azimut_5deg" : "COEFFLUENCE2",
	 "Azimut_10deg" : "COEFFLUENCE3",
	 "Azimut_15deg" : "COEFFLUENCE4",
	 "Azimut_20deg" : "COEFFLUENCE5",
	 "Azimut_25deg" : "COEFFLUENCE6",
	 "Azimut_30deg" : "COEFFLUENCE7",
	 "Azimut_35deg" : "COEFFLUENCE8",
	 "Azimut_40deg" : "COEFFLUENCE9",
	 "Azimut_45deg" : "COEFFLUENCE10",
	 "TypeIrradiation" : "TYPEIRR",
	 "RTNDT" : "RTNDT",
	 "ModeleIrradiation" : "MODELIRR",
	 "TeneurCuivre" : "CU",
	 "TeneurCuivre_mess" : "CU_MESSAGE",
	 "TeneurNickel" : "NI",
	 "TeneurNickel_mess" : "NI_MESSAGE",
	 "TeneurPhosphore" : "P",
	 "TeneurPhosphore_mess" : "P_MESSAGE",
	 "MoyenneRTndt" : "RTimoy",
	 "MoyenneRTndt_mess" : "RTimoy_MESSAGE",
	 "CoefVariationRTndt" : "RTicov",
	 "CoefVariationRTndt_mess" : "RTicov_MESSAGE",
	 "EcartTypeRTndt" : "USectDRT",
	 "EcartTypeRTndt_mess" : "USectDRT_MESSAGE",
	 "NombreEcartTypeRTndt" : "nbectDRTNDT",
	 "NombreEcartTypeRTndt_mess" : "nbectDRTNDT_MESSAGE",
	 "ModeleTenacite" : "MODELKIC",
	 "NombreCaracteristique" : "NBCARAC",
	 "NbEcartType_MoyKIc" : "nbectKIc",
	 "NbEcartType_MoyKIc_mess" : "nbectKIc_MESSAGE",
	 "PalierDuctile_KIc" : "KICPAL",
	 "CoefficientVariation_KIc" : "KICCDV",
	 "Fractile_KIc" : "fractKIc",
	 "Fractile_KIc_mess" : "fractKIc_MESSAGE",
	 "Temperature_KIc100" : "T0WALLIN",
	 "A1" : "A1",
	 "A2" : "A2",
	 "A3" : "A3",
	 "B1" : "B1",
	 "B2" : "B2",
	 "B3" : "B3",
	 "C1" : "C1",
	 "C2" : "C2",
	 "C3" : "C3",
	 "ChoixCorrectionLongueur" : "CHOIXCL",
	 "AttnCorrBeta" : "ATTNCORRBETA",
	 "CorrIrwin" : "CORRIRWIN",
	 "ArretDeFissure" : "ARRETFISSURE",
	 "IncrementTailleFissure" : "INCRDEF",
	 "IncrementTailleFissure_mess" : "INCRDEF_MESSAGE",
	 "NbEcartType_MoyKIa" : "nbectKIa",
	 "PalierDuctile_KIa" : "KIAPAL",
	 "CoefficientVariation_KIa" : "KIACDV",
	 "ChoixCoefficientChargement" : "CHOIXSIGM",
	 "CoefficientDuctile" : "COEFSIGM1",
	 "CoefficientFragile" : "COEFSIGM2",
	 "InstantInitialisation" : "INSTINIT",
	 "ConditionLimiteThermiqueREV" : "KTHREV",
	 "TemperatureDeformationNulleREV" : "TREFREV",
	 "TemperaturePourCoefDilatThermREV" : "TDETREV",
	 "CoefficientPoissonREV" : "NUREV",
	 "ConditionLimiteThermiqueMDB" : "KTHMDB",
	 "TemperatureDeformationNulleMDB" : "TREFMDB",
	 "TemperaturePourCoefDilatThermMDB" : "TDETMDB",
	 "CoefficientPoissonMDB" : "NUMDB",
	 "TypeConditionLimiteThermique" : "TYPCLTH",
	 "Instant_1" : "INSTANT1",
	 "Instant_2" : "INSTANT2",
	 "Instant_3" : "INSTANT3",
	 "DebitAccumule" : "QACCU",
	 "DebitInjectionSecurite" : "QIS",
	 "TempInjectionSecurite" : "TIS",
	 "TempInjectionSecurite_mess" : "TIS_MESSAGE",
	 "DiametreHydraulique" : "DH",
	 "DiametreHydraulique_mess" : "DH_MESSAGE",
	 "SectionEspaceAnnulaire" : "SECTION",
	 "SectionEspaceAnnulaire_mess" : "SECTION_MESSAGE",
	 "HauteurCaracConvectionNaturelle" : "DELTA",
	 "HauteurCaracConvectionNaturelle_mess" : "DELTA_MESSAGE",
	 "CritereConvergenceRelative" : "EPS",
	 "CoefficientsVestale" : "COEFVESTALE",
	 "VolumeMelange_CREARE" : "VMTAB",
	 "TemperatureInitiale_CREARE" : "T0",
	 "TemperatureInitiale_CREARE_mess" : "T0_MESSAGE",
	 "SurfaceEchange_FluideStructure" : "SE",
	 "SurfaceEchange_FluideStructure_mess" : "SE_MESSAGE",
	 "InstantPerteCirculationNaturelle" : "INST_PCN",
         }

      # Ce dictionnaire liste le nom des valeurs proposées utilisees dans le script
      self.valeurproposee = {
         "Aucune impression" : "0",
         "Temps total" : "1",
         "Temps intermediaires" : "2",
	 "Facteur de marge KIc/KCP" : "FM_KICSURKCP",
	 "Marge KIc-KI" : "MARGE_KI",
	 "Marge KIc-KCP" : "MARGE_KCP",
	 "Topologie" : "GEOMETRIE",
	 "Maillage" : "MAILLAGE",
	 "Defaut Sous Revetement" : "DSR",
	 "Defaut Decale" : "DECALE",
	 "Defaut Debouchant" : "DEBOUCHANT",
	 "Longitudinale" : "LONGITUD",
	 "Circonferentielle" : "CIRCONF",
	 "Virole" : "VIROLE",
	 "Joint soude" : "JSOUDE",
	 "Valeur" : "VALEUR",
	 "Fonction affine de la profondeur" : "FCTAFFINE",
	 "Valeur normalisee" : "NORMALISE",
	 "A" : "A",
	 "B" : "B",
	 "A et B" : "BOTH",
	 "Exponentiel sans revetement k=9.7 (Reglementaire)" : "Reglementaire",
	 "Exponentiel sans revetement k=12.7 (France)" : "France",
	 "Exponentiel sans revetement k=0. (ValeurImposee)" : "ValeurImposee",
	 "Donnees francaises du palier CPY (SDM)" : "SDM",
	 "Regulatory Guide 1.99 rev 2 (USNRC)" : "USNRC",
	 "Dossier 900 MWe AP9701 rev 2 (REV_2)" : "REV_2",
	 "Lissage du modele ajuste (SDM_Lissage)" : "SDM_Lissage",
	 "Donnees francaises du palier CPY ajustees par secteur angulaire (GrandeDev)" : "GrandeDev",
	 "Grand developpement (GD_Cuve)" : "GD_Cuve",
	 "Exponentiel sans revetement k=9.7 (Reglementaire CUVE1D)" : "Cuve1D",
	 "RTndt de la cuve a l instant de l analyse" : "RTNDT",
	 "Modele d irradiation" : "FLUENCE",
	 "Formule de FIM/FIS Lefebvre modifiee" : "LEFEBnew",
	 "Metal de Base : formule de FIM/FIS Houssin" : "HOUSSIN",
	 "Metal de Base : formule de FIM/FIS Persoz" : "PERSOZ",
	 "Metal de Base : formule de FIM/FIS Lefebvre" : "LEFEBVRE",
	 "Metal de Base : Regulatory Guide 1.00 rev 2" : "USNRCmdb",
	 "Joint Soude : formulation de FIM/FIS Brillaud" : "BRILLAUD",
	 "Joint Soude : Regulatory Guide 1.00 rev 2" : "USNRCsoud",
	 "RCC-M/ASME coefficient=2" : "RCC-M",
	 "RCC-M/ASME coefficient=2 CUVE1D" : "RCC-M_simpl",
	 "RCC-M/ASME coefficient=2.33 (Houssin)" : "Houssin_RC",
	 "RCC-M/ASME avec KI=KIpalier" : "RCC-M_pal",
	 "RCC-M/ASME avec KI~exponentiel" : "RCC-M_exp",
	 "Weibull basee sur la master cuve" : "Wallin",
	 "Weibull basee sur la master cuve (REME)" : "REME",
	 "Weibull n\xb01 (etude ORNL)" : "ORNL",
	 "Weibull n\xb02" : "WEIB2",
	 "Weibull n\xb03" : "WEIB3",
	 "Weibull generalisee" : "WEIB-GEN",
	 "Exponentielle n\xb01 (Frama)" : "Frama",
	 "Exponentielle n\xb02 (LOGWOLF)" : "LOGWOLF",
	 "Quantile" : "QUANTILE",
	 "Ordre" : "ORDRE",
	 "Enthalpie" : "ENTHALPIE",
	 "Chaleur" : "CHALEUR",
	 "Temperature imposee en paroi" : "TEMP_IMPO",
	 "Flux de chaleur impose en paroi" : "FLUX_REP",
	 "Temperature imposee du fluide et coefficient echange" : "ECHANGE",
	 "Debit massique et temperature d injection de securite" : "DEBIT",
	 "Temperature imposee du fluide et debit d injection de securite" : "TEMP_FLU",
	 "Courbe APRP" : "APRP",
	 "Calcul TEMPFLU puis DEBIT" : "TFDEBIT",
         }

      # Ce dictionnaire liste le commentaire des variables utilisees dans le script
      self.comment = {
         "NiveauImpression" : "Niveau d impression des messages a l ecran (=0 : rien, =1 : temps calcul total, =2 : temps intermediaires)",
	 "FichierDataIn"    : "sortie du fichier recapitulatif des donnees d entree {OUI ; NON}",
	 "FichierTempSigma" : "sortie des fichiers temperature et contraintes {OUI ; NON}",
	 "FichierCSV" : "sortie du fichier resultat template_DEFAILLCUVE.CSV {OUI ; NON}",
	 "FichierRESTART" : "sortie du fichier de re-demarrage",
	 "FichierEXTR" : "sortie du fichier d extraction des transitoires",
	 "ChoixPlugin" : "choix d'un repertoire de plug-in",
	 "GrandeurEvaluee" : "choix de la grandeur sous critere evaluee {FM_KICSURKCP ; MARGE_KI ; MARGE_KCP}",
	 "IncrementTemporel" : "increment temporel pour l analyse PROBABILISTE (si DETERMINISTE, fixer a 1)",
	 "IncrementMaxTemperature" : "increment max de temp/noeud/instant (degC)",
	 "ChoixExtractionTransitoires" : "choix d'extraction de transitoires de temp et contraintes",
	 "IncrementMaxTempsAffichage" : "increment max de temps pour affichage (s)",
	 "traitementGeometrie" : "traitement de la geometrie de la cuve : {GEOMETRIE, MAILLAGE}",
	 "RayonInterne" : "rayon interne (m)",
	 "RayonInterne_mess" : "affichage ecran du rayon interne (m)",
	 "RayonExterne" : "rayon externe (m)",
	 "RayonExterne_mess" : "affichage ecran du rayon externe (m)",
	 "EpaisseurRevetement" : "epaisseur revetement (m)",
	 "EpaisseurRevetement_mess" : "affichage ecran de l epaisseur revetement (m)",
	 "LigamentExterneMin" : "ligament externe minimal avant rupture (% de l'epaisseur de cuve)",
	 "LigamentExterneMin_mess" : "affichage ecran du ligament externe minimal avant rupture (% de l'epaisseur de cuve)",
	 "NombreNoeudsMaillage" : "nbre de noeuds dans l'epaisseur de la cuve",
	 "TypeInitial" : "type initial du defaut : DEBOUCHANT=Defaut Debouchant, DSR=Defaut Sous Revetement, DECALE=Defaut Decale",
	 "Orientation" : "orientation (LONGITUD / CIRCONF)",
	 "Position" : "Position du defaut (VIROLE / JSOUDE)",
	 "ProfondeurRadiale" : "profondeur radiale ou encore hauteur (m)",
	 "ProfondeurRadiale_mess" : "affichage ecran de la profondeur radiale ou encore hauteur (m)",
	 "ModeCalculLongueur" : "option pour definir la longueur du defaut (VALEUR pour une valeur fixe, FCTAFFINE pour une fct affine de la profondeur)",
	 "Longueur" : "longueur (m) pour defaut Sous Revetement",
	 "Longueur_mess" : "affichage ecran de la longueur (m) pour defaut Sous Revetement",
	 "CoefDirecteur" : "pente de la fonction affine l = h/profsurlong + a0",
	 "CoefDirecteur_mess" : "affichage ecran de la pente de la fonction affine l = h/profsurlong + a0",
	 "Constante" : "constante de la fonction affine a0",
	 "ModeCalculDecalage" : "type de decalage : normalise (NORMALISE) ou reel (VALEUR)",
	 "DecalageNormalise" : "decalage radial normalise (valeur comprise entre 0. et 1.) pour defaut Sous Revetement",
	 "DecalageNormalise_mess" : "affichage ecran du decalage radial normalise (valeur comprise entre 0. et 1.) pour defaut Sous Revetement",
	 "DecalageRadial" : "decalage radial reel (m) pour defaut decale",
	 "DecalageRadial_mess" : "affichage ecran du decalage radial reel (m) pour defaut decale",
	 "Azimut" : "coordonnee angulaire (degre)",
	 "Azimut_mess" : "affichage ecran de la coordonnee angulaire (degre)",
	 "Altitude" : "altitude (m) : valeur negative",
	 "Altitude_mess" : "affichage ecran de l altitude (m) : valeur negative",
	 "Pointe" : "choix du(des) point(s) du defaut considere {'A','B','BOTH'} pour DSR et DECALE (pour DEBOUCHANT : automatiquement 'B')",
	 "ModeleFluence" : "modele de fluence : {Reglementaire, France, ValeurImposee, SDM, USNRC, REV_2, SDM_Lissage, GrandeDev, GD_Cuve, Cuve1D}",
	 "ZoneActiveCoeur_AltitudeSup" : "cote superieure de la zone active de coeur (ici pour cuve palier 900Mw)",
	 "ZoneActiveCoeur_AltitudeInf" : "cote inferieure de la zone active de coeur (ici pour cuve palier 900Mw)",
	 "FluenceMax" : "fluence maximale assimilee par la cuve (n/cm2)",
	 "KPFrance" : "parametre exponentiel du modele France",
	 "KPUS" : "parametre exponentiel du modele US",
	 "Azimut_0deg" : "fluence a l'azimut 0 (10^19 n/cm)",
	 "Azimut_5deg" : "fluence a l'azimut 5 (10^19 n/cm)",
	 "Azimut_10deg" : "fluence a l'azimut 10 (10^19 n/cm)",
	 "Azimut_15deg" : "fluence a l'azimut 15 (10^19 n/cm)",
	 "Azimut_20deg" : "fluence a l'azimut 20 (10^19 n/cm)",
	 "Azimut_25deg" : "fluence a l'azimut 25 (10^19 n/cm)",
	 "Azimut_30deg" : "fluence a l'azimut 30 (10^19 n/cm)",
	 "Azimut_35deg" : "fluence a l'azimut 35 (10^19 n/cm)",
	 "Azimut_40deg" : "fluence a l'azimut 40 (10^19 n/cm)",
	 "Azimut_45deg" : "fluence a l'azimut 45 (10^19 n/cm)",
	 "TypeIrradiation" : "type irradiation : {RTNDT, FLUENCE}",
	 "RTNDT" : "RTNDT finale (degC)",
	 "ModeleIrradiation" : "modele d irradiation : LEFEBnew, ou {HOUSSIN, PERSOZ, LEFEBVRE, USNRCmdb} pour virole et {BRILLAUD,USNRCsoud} pour jointsoude",
	 "TeneurCuivre" : "teneur en cuivre (%)",
	 "TeneurCuivre_mess" : "affichage ecran de la teneur en cuivre (%)",
	 "TeneurNickel" : "teneur en nickel (%)",
	 "TeneurNickel_mess" : "affichage ecran de la teneur en nickel (%)",
	 "TeneurPhosphore" : "teneur en phosphore (%)",
	 "TeneurPhosphore_mess" : "affichage ecran de la teneur en phosphore (%)",
	 "MoyenneRTndt" : "moyenne de la RTNDT initiale : virole C1 de cuve Chinon : mdb=>-17.degC et js=>42.degC (HT-56/05/038 : p.52)",
	 "MoyenneRTndt_mess" : "affichage ecran de la moyenne de la RTNDT initiale",
	 "CoefVariationRTndt" : "coef de variation de la RTNDT initiale",
	 "CoefVariationRTndt_mess" : "affichage ecran du coef de variation de la RTNDT initiale",
	 "EcartTypeRTndt" : "pour modeles USNRCsoud ou USNRCmdb, ecart-type du decalage de RTNDT (°F) (28. pour js et 17. pour mdb)",
	 "EcartTypeRTndt_mess" : "affichage ecran, pour modeles USNRCsoud ou USNRCmdb, ecart-type du decalage de RTNDT (°F) (28. pour js et 17. pour mdb)",
	 "NombreEcartTypeRTndt" : "Nbre d ecart-type par rapport a la moyenne de DRTNDT si analyse PROBABILISTE (en DETERMINISTE, fixer a 2.)",
	 "NombreEcartTypeRTndt_mess" : "affichage ecran du nbre d ecart-type par rapport a la moyenne de DRTNDT si analyse PROBABILISTE",
	 "ModeleTenacite" : "modele de tenacite : {RCC-M, RCC-M_pal, RCC-M_exp, RCC-M_simpl, Houssin_RC, Wallin, REME, ORNL, Frama, WEIB3, WEIB2, LOGWOLF, WEIB-GEN}",
	 "NombreCaracteristique" : "Nb caracteristique : ORDRE ou QUANTILE",
	 "NbEcartType_MoyKIc" : "Nbre d ecart-type par rapport a la moyenne de KIc si analyse PROBABILISTE (en DETERMINISTE, fixer a -2.)",
	 "NbEcartType_MoyKIc_mess" : "affichage ecran du nbre d ecart-type par rapport a la moyenne de KIc si analyse PROBABILISTE",
	 "PalierDuctile_KIc" : "palier deterministe de K1c (MPa(m^0.5))",
	 "CoefficientVariation_KIc" : "coef de variation de la loi normale de K1c",
	 "Fractile_KIc" : "valeur caracteristique de KIc exprimee en ordre de fractile (%)",
	 "Fractile_KIc_mess" : "affichage ecran de la valeur caracteristique de KIc exprimee en ordre de fractile (%)",
	 "Temperature_KIc100" : "parametre T0 du modele Wallin (degC)",
	 "A1" : "coef des coefs d une WEIBULL generale",
	 "A2" : "",
	 "A3" : "",
	 "B1" : "",
	 "B2" : "",
	 "B3" : "",
	 "C1" : "",
	 "C2" : "",
	 "C3" : "",
	 "ChoixCorrectionLongueur" : "Activation ou non de la correction de longueur {OUI ; NON}",
	 "AttnCorrBeta" : "Attenuation de la correction plastique : {OUI, NON} ==> uniquement pour DSR ou DECALE",
	 "CorrIrwin" : "Correction plastique IRWIN : {OUI, NON} ==> uniquement pour DEBOUCHANT",
	 "ArretDeFissure" : "prise en compte de l arret de fissure {OUI, NON} (en PROBABILISTE, fixer a NON)",
	 "IncrementTailleFissure" : "increment de la taille de fissure (m)",
	 "IncrementTailleFissure_mess" : "affichage ecran de l increment de la taille de fissure (m)",
	 "NbEcartType_MoyKIa" : "Nbre d ecart-type par rapport a la moyenne de KIa (nb sigma)",
	 "PalierDuctile_KIa" : "palier deterministe de K1a quand modele RCC-M  (MPa(m^0.5))",
	 "CoefficientVariation_KIa" : "coef de variation de la loi normale de K1a",
	 "ChoixCoefficientChargement" : "prise en compte de coefficients sur le chargement (OUI/NON)",
	 "CoefficientDuctile" : "coefficient multiplicateur pour rupture ductile",
	 "CoefficientFragile" : "coefficient multiplicateur pour rupture fragile",
	 "InstantInitialisation" : "instant initial (s)",
	 "ConditionLimiteThermiqueREV" : "Option 'ENTHALPIE' ou 'CHALEUR'",
	 "TemperatureDeformationNulleREV" : "temperature de deformation nulle (degC)",
	 "TemperaturePourCoefDilatThermREV" : "temperature de definition du coefficient de dilatation thermique (degC)",
	 "CoefficientPoissonREV" : "coefficient de Poisson",
	 "ConditionLimiteThermiqueMDB" : "Option 'ENTHALPIE' ou 'CHALEUR'",
	 "TemperatureDeformationNulleMDB" : "temperature de deformation nulle (degC)",
	 "TemperaturePourCoefDilatThermMDB" : "temperature de definition du coefficient de dilatation thermique (degC)",
	 "CoefficientPoissonMDB" : "coefficient de Poisson",
	 "TypeConditionLimiteThermique" : "Type de condition thermique en paroi interne {TEMP_IMPO,FLUX_REP,ECHANGE,DEBIT,TEMP_FLU,APRP}",
	 "Instant_1" : "Borne superieure de l intervalle de temps du 1er palier TACCU",
	 "Instant_2" : "Borne superieure de l intervalle de temps du 2nd palier T1",
	 "Instant_3" : "Borne superieure de l intervalle de temps du 3eme palier TIS",
	 "DebitAccumule" : "Debit accumule (en m3/h)",
	 "DebitInjectionSecurite" : "Debit injection de securite (en m3/h)",
	 "TempInjectionSecurite" : "Temperature injection de securite (en degC)",
	 "TempInjectionSecurite_mess" : "affichage ecran de la temperature injection de securite",
	 "DiametreHydraulique" : "Diametre hydraulique (m)",
	 "DiametreHydraulique_mess" : "affichage ecran du diametre hydraulique (m)",
	 "SectionEspaceAnnulaire" : "Section espace annulaire (m2)",
	 "SectionEspaceAnnulaire_mess" : "affichage ecran de la section espace annulaire (m2)",
	 "HauteurCaracConvectionNaturelle" : "Hauteur caracteristique convection naturelle (m)",
	 "HauteurCaracConvectionNaturelle_mess" : "affichage ecran de la hauteur caracteristique convection naturelle (m)",
	 "CritereConvergenceRelative" : "Critere convergence relative (-)",
	 "CoefficientsVestale" : "Application des coefs de Vestale {OUI;NON}",
	 "VolumeMelange_CREARE" : "Transitoire de volume de melange CREARE (m3)",
	 "TemperatureInitiale_CREARE" : "Temperature initiale CREARE (degC)",
	 "TemperatureInitiale_CREARE_mess" : "affichage ecran de la temperature initiale CREARE (degC)",
	 "SurfaceEchange_FluideStructure" : "Surface d'echange fluide/structure (m2)",
	 "SurfaceEchange_FluideStructure_mess" : "affichage ecran de la surface d'echange fluide/structure (m2)",
	 "InstantPerteCirculationNaturelle" : "Instant de perte de circulation naturelle",
         }

      # Ce dictionnaire liste la valeur par defaut des variables utilisees dans le script
      self.default = {
         "NiveauImpression" : "1",
	 "FichierDataIn" : "NON",
	 "FichierTempSigma" : "NON",
	 "FichierCSV" : "NON",
	 "FichierRESTART" : "NON",
	 "FichierEXTR" : "NON",
	 "ChoixPlugin" : "NON",
	 "GrandeurEvaluee" : "FM_KICSURKCP",
	 "IncrementTemporel" : "1",
	 "IncrementMaxTemperature" : "0.1",
	 "ChoixExtractionTransitoires" : "NON",
	 "IncrementMaxTempsAffichage" : "1000.",
	 "traitementGeometrie" : "GEOMETRIE",
	 "RayonInterne" : "1.994",
	 "RayonInterne_mess" : "NON",
	 "RayonExterne" : "2.2015",
	 "RayonExterne_mess" : "NON",
	 "EpaisseurRevetement" : "0.0075",
	 "EpaisseurRevetement_mess" : "NON",
	 "LigamentExterneMin" : "0.75",
	 "LigamentExterneMin_mess" : "NON",
	 "NombreNoeudsMaillage" : "300",
	 "TypeInitial" : "DSR",
	 "Position" : "VIROLE",
	 "ProfondeurRadiale" : "0.006",
	 "ProfondeurRadiale_mess" : "NON",
	 "ModeCalculLongueur" : "VALEUR",
	 "Longueur" : "0.060",
	 "Longueur_mess" : "NON",
	 "CoefDirecteur" : "10.",
	 "CoefDirecteur_mess" : "NON",
	 "Constante" : "0.",
	 "ModeCalculDecalage" : "VALEUR",
	 "DecalageNormalise" : "0.1",
	 "DecalageNormalise_mess" : "NON",
	 "DecalageRadial" : "0.",
	 "DecalageRadial_mess" : "NON",
	 "Azimut" : "0.",
	 "Azimut_mess" : "NON",
	 "Altitude" : "-4.",
	 "Altitude_mess" : "NON",
	 "Pointe" : "B",
	 "ModeleFluence" : "Reglementaire",
	 "ZoneActiveCoeur_AltitudeSup" : "-3.536",
	 "ZoneActiveCoeur_AltitudeInf" : "-7.194",
	 "FluenceMax" : "6.5",
	 "KPFrance" : "12.7",
	 "KPUS" : "9.4488",
	 "Azimut_0deg" : "5.8",
	 "Azimut_5deg" : "5.48",
	 "Azimut_10deg" : "4.46",
	 "Azimut_15deg" : "3.41",
	 "Azimut_20deg" : "3.37",
	 "Azimut_25deg" : "3.16",
	 "Azimut_30deg" : "2.74",
	 "Azimut_35deg" : "2.25",
	 "Azimut_40deg" : "1.89",
	 "Azimut_45deg" : "1.78",
	 "TypeIrradiation" : "RTNDT",
	 "RTNDT" : "64.",
	 "ModeleIrradiation" : "HOUSSIN",
	 "TeneurCuivre" : "0.0972",
	 "TeneurCuivre_mess" : "NON",
	 "TeneurNickel" : "0.72",
	 "TeneurNickel_mess" : "NON",
	 "TeneurPhosphore" : "0.00912",
	 "TeneurPhosphore_mess" : "NON",
	 "MoyenneRTndt" : "-12.0",
	 "MoyenneRTndt_mess" : "NON",
	 "CoefVariationRTndt" : "0.1",
	 "CoefVariationRTndt_mess" : "NON",
	 "EcartTypeRTndt" : "-2.",
	 "EcartTypeRTndt_mess" : "NON",
	 "NombreEcartTypeRTndt" : "2.",
	 "NombreEcartTypeRTndt_mess" : "NON",
	 "ModeleTenacite" : "RCC-M",
	 "NombreCaracteristique" : "Quantile",
	 "NbEcartType_MoyKIc" : "-2.",
	 "NbEcartType_MoyKIc_mess" : "NON",
	 "PalierDuctile_KIc" : "195.",
	 "CoefficientVariation_KIc" : "0.15",
	 "Fractile_KIc" : "5.",
	 "Fractile_KIc_mess" : "NON",
	 "Temperature_KIc100" : "-27.",
	 "A1" : "21.263",
	 "A2" : "9.159",
	 "A3" : "0.04057",
	 "B1" : "17.153",
	 "B2" : "55.089",
	 "B3" : "0.0144",
	 "C1" : "4.",
	 "C2" : "0.",
	 "C3" : "0.",
	 "ChoixCorrectionLongueur" : "OUI",
	 "AttnCorrBeta" : "NON",
	 "CorrIrwin" : "NON",
	 "ArretDeFissure" : "NON",
	 "IncrementTailleFissure" : "0.",
	 "IncrementTailleFissure_mess" : "NON",
	 "NbEcartType_MoyKIa" : "0.",
	 "PalierDuctile_KIa" : "0.",
	 "CoefficientVariation_KIa" : "0.",
	 "ChoixCoefficientChargement" : "NON",
	 "CoefficientDuctile" : "1.0",
	 "CoefficientFragile" : "1.0",
	 "InstantInitialisation" : "-1.",
	 "ConditionLimiteThermiqueREV" : "CHALEUR",
	 "TemperatureDeformationNulleREV" : "20.",
	 "TemperaturePourCoefDilatThermREV" : "287.",
	 "CoefficientPoissonREV" : "0.3",
	 "ConditionLimiteThermiqueMDB" : "CHALEUR",
	 "TemperatureDeformationNulleMDB" : "20.",
	 "TemperaturePourCoefDilatThermMDB" : "287.",
	 "CoefficientPoissonMDB" : "0.3",
	 "TypeConditionLimiteThermique" : "TEMP_IMPO",
	 "Instant_1" : "21.",
	 "Instant_2" : "45.",
	 "Instant_3" : "5870.",
	 "DebitAccumule" : "2.3",
	 "DebitInjectionSecurite" : "0.375",
	 "TempInjectionSecurite" : "9.",
	 "TempInjectionSecurite_mess" : "NON",
	 "DiametreHydraulique" : "0.3816",
	 "DiametreHydraulique_mess" : "NON",
	 "SectionEspaceAnnulaire" : "0.21712",
	 "SectionEspaceAnnulaire_mess" : "NON",
	 "HauteurCaracConvectionNaturelle" : "6.",
	 "HauteurCaracConvectionNaturelle_mess" : "NON",
	 "CritereConvergenceRelative" : "0.00001",
	 "CoefficientsVestale" : "NON",
#	 "VolumeMelange_CREARE" : "14.9",
	 "TemperatureInitiale_CREARE" : "250.",
	 "TemperatureInitiale_CREARE_mess" : "NON",
	 "SurfaceEchange_FluideStructure" : "0.",
	 "SurfaceEchange_FluideStructure_mess" : "NON",
	 "InstantPerteCirculationNaturelle" : "400.",
         }

      # Ce dictionnaire liste la rubrique d'appartenance des variables utilisees dans le script
      self.bloc = {
         "NiveauImpression" : "OPTIONS",
	 "FichierDataIn" : "OPTIONS",
	 "FichierTempSigma" : "OPTIONS",
	 "FichierCSV" : "OPTIONS",
	 "FichierRESTART" : "OPTIONS",
	 "FichierEXTR" : "OPTIONS",
	 "ChoixPlugin" : "OPTIONS",
	 "GrandeurEvaluee" : "OPTIONS",
	 "IncrementTemporel" : "OPTIONS",
	 "IncrementMaxTemperature" : "OPTIONS",
	 "ChoixExtractionTransitoires" : "OPTIONS",
	 "IncrementMaxTempsAffichage" : "OPTIONS",
	 "traitementGeometrie" : "DONNEES DE LA CUVE",
	 "RayonInterne" : "DONNEES DE LA CUVE",
	 "RayonInterne_mess" : "DONNEES DE LA CUVE",
	 "RayonExterne" : "DONNEES DE LA CUVE",
	 "RayonExterne_mess" : "DONNEES DE LA CUVE",
	 "EpaisseurRevetement" : "DONNEES DE LA CUVE",
	 "EpaisseurRevetement_mess" : "DONNEES DE LA CUVE",
	 "LigamentExterneMin" : "DONNEES DE LA CUVE",
	 "LigamentExterneMin_mess" : "DONNEES DE LA CUVE",
	 "NombreNoeudsMaillage" : "DONNEES DE LA CUVE",
	 "TypeInitial" : "CARACTERISTIQUES DU DEFAUT",
	 "Orientation" : "CARACTERISTIQUES DU DEFAUT",
	 "Position" : "CARACTERISTIQUES DU DEFAUT",
	 "ProfondeurRadiale" : "CARACTERISTIQUES DU DEFAUT",
	 "ProfondeurRadiale_mess" : "CARACTERISTIQUES DU DEFAUT",
	 "ModeCalculLongueur" : "CARACTERISTIQUES DU DEFAUT",
	 "Longueur" : "CARACTERISTIQUES DU DEFAUT",
	 "Longueur_mess" : "CARACTERISTIQUES DU DEFAUT",
	 "CoefDirecteur" : "CARACTERISTIQUES DU DEFAUT",
	 "CoefDirecteur_mess" : "CARACTERISTIQUES DU DEFAUT",
	 "Constante" : "CARACTERISTIQUES DU DEFAUT",
	 "ModeCalculDecalage" : "CARACTERISTIQUES DU DEFAUT",
	 "DecalageNormalise" : "CARACTERISTIQUES DU DEFAUT",
	 "DecalageNormalise_mess" : "CARACTERISTIQUES DU DEFAUT",
	 "DecalageRadial" : "CARACTERISTIQUES DU DEFAUT",
	 "DecalageRadial_mess" : "CARACTERISTIQUES DU DEFAUT",
	 "Azimut" : "CARACTERISTIQUES DU DEFAUT",
	 "Azimut_mess" : "CARACTERISTIQUES DU DEFAUT",
	 "Altitude" : "CARACTERISTIQUES DU DEFAUT",
	 "Altitude_mess" : "CARACTERISTIQUES DU DEFAUT",
	 "Pointe" : "CARACTERISTIQUES DU DEFAUT",
	 "ModeleFluence" : "MODELES",
	 "ZoneActiveCoeur_AltitudeSup" : "MODELES",
	 "ZoneActiveCoeur_AltitudeInf" : "MODELES",
	 "FluenceMax" : "MODELES",
	 "KPFrance" : "MODELES",
	 "KPUS" : "MODELES",
	 "Azimut_0deg" : "MODELES",
	 "Azimut_5deg" : "MODELES",
	 "Azimut_10deg" : "MODELES",
	 "Azimut_15deg" : "MODELES",
	 "Azimut_20deg" : "MODELES",
	 "Azimut_25deg" : "MODELES",
	 "Azimut_30deg" : "MODELES",
	 "Azimut_35deg" : "MODELES",
	 "Azimut_40deg" : "MODELES",
	 "Azimut_45deg" : "MODELES",
	 "TypeIrradiation" : "MODELES",
	 "RTNDT" : "MODELES",
	 "ModeleIrradiation" : "MODELES",
	 "TeneurCuivre" : "MODELES",
	 "TeneurCuivre_mess" : "MODELES",
	 "TeneurNickel" : "MODELES",
	 "TeneurNickel_mess" : "MODELES",
	 "TeneurPhosphore" : "MODELES",
	 "TeneurPhosphore_mess" : "MODELES",
	 "MoyenneRTndt" : "MODELES",
	 "MoyenneRTndt_mess" : "MODELES",
	 "CoefVariationRTndt" : "MODELES",
	 "CoefVariationRTndt_mess" : "MODELES",
	 "EcartTypeRTndt" : "MODELES",
	 "EcartTypeRTndt_mess" : "MODELES",
	 "NombreEcartTypeRTndt" : "MODELES",
	 "NombreEcartTypeRTndt_mess" : "MODELES",
	 "ModeleTenacite" : "MODELES",
	 "NombreCaracteristique" : "MODELES",
	 "NbEcartType_MoyKIc" : "MODELES",
	 "NbEcartType_MoyKIc_mess" : "MODELES",
	 "PalierDuctile_KIc" : "MODELES",
	 "CoefficientVariation_KIc" : "MODELES",
	 "Fractile_KIc" : "MODELES",
	 "Fractile_KIc_mess" : "MODELES",
	 "Temperature_KIc100" : "MODELES",
	 "A1" : "MODELES",
	 "A2" : "MODELES",
	 "A3" : "MODELES",
	 "B1" : "MODELES",
	 "B2" : "MODELES",
	 "B3" : "MODELES",
	 "C1" : "MODELES",
	 "C2" : "MODELES",
	 "C3" : "MODELES",
	 "ChoixCorrectionLongueur" : "MODELES",
	 "AttnCorrBeta" : "MODELES",
	 "CorrIrwin" : "MODELES",
	 "ArretDeFissure" : "MODELES",
	 "IncrementTailleFissure" : "MODELES",
	 "IncrementTailleFissure_mess" : "MODELES",
	 "NbEcartType_MoyKIa" : "MODELES",
	 "PalierDuctile_KIa" : "MODELES",
	 "CoefficientVariation_KIa" : "MODELES",
	 "ChoixCoefficientChargement" : "ETAT INITIAL",
	 "CoefficientDuctile" : "ETAT INITIAL",
	 "CoefficientFragile" : "ETAT INITIAL",
	 "InstantInitialisation" : "ETAT INITIAL",
	 "ConditionLimiteThermiqueREV" : "CARACTERISTIQUES DU REVETEMENT",
	 "TemperatureDeformationNulleREV" : "CARACTERISTIQUES DU REVETEMENT",
	 "TemperaturePourCoefDilatThermREV" : "CARACTERISTIQUES DU REVETEMENT",
	 "CoefficientPoissonREV" : "CARACTERISTIQUES DU REVETEMENT",
	 "ConditionLimiteThermiqueMDB" : "CARACTERISTIQUES DU MDB",
	 "TemperatureDeformationNulleMDB" : "CARACTERISTIQUES DU MDB",
	 "TemperaturePourCoefDilatThermMDB" : "CARACTERISTIQUES DU MDB",
	 "CoefficientPoissonMDB" : "CARACTERISTIQUES DU MDB",
	 "TypeConditionLimiteThermique" : "TRANSITOIRE",
	 "Instant_1" : "TRANSITOIRE",
	 "Instant_2" : "TRANSITOIRE",
	 "Instant_3" : "TRANSITOIRE",
	 "DebitAccumule" : "TRANSITOIRE",
	 "DebitInjectionSecurite" : "TRANSITOIRE",
	 "TempInjectionSecurite" : "TRANSITOIRE",
	 "TempInjectionSecurite_mess" : "TRANSITOIRE",
	 "DiametreHydraulique" : "TRANSITOIRE",
	 "DiametreHydraulique_mess" : "TRANSITOIRE",
	 "SectionEspaceAnnulaire" : "TRANSITOIRE",
	 "SectionEspaceAnnulaire_mess" : "TRANSITOIRE",
	 "HauteurCaracConvectionNaturelle" : "TRANSITOIRE",
	 "HauteurCaracConvectionNaturelle_mess" : "TRANSITOIRE",
	 "CritereConvergenceRelative" : "TRANSITOIRE",
	 "CoefficientsVestale" : "TRANSITOIRE",
	 "VolumeMelange_CREARE" : "TRANSITOIRE",
	 "TemperatureInitiale_CREARE" : "TRANSITOIRE",
	 "TemperatureInitiale_CREARE_mess" : "TRANSITOIRE",
	 "SurfaceEchange_FluideStructure" : "TRANSITOIRE",
	 "SurfaceEchange_FluideStructure_mess" : "TRANSITOIRE",
	 "InstantPerteCirculationNaturelle" : "TRANSITOIRE",
         }

   def gener(self,obj,format='brut'):
      self.text=''
      self.textCuve=''
      self.texteTFDEBIT=''
      self.dico_mot={}
      self.dico_genea={}
      self.text=PythonGenerator.gener(self,obj,format)
      return self.text

   def generMCSIMP(self,obj) :
       self.dico_mot[obj.nom]=obj.valeur
       clef=""
       for i in obj.getGenealogie() :
           clef=clef+"_"+i
       self.dico_genea[clef]=obj.valeur
       s=PythonGenerator.generMCSIMP(self,obj)
       return s

   def writeCuve2DG(self, filename, file2):
      print "je passe dans writeCuve2DG"
      self.genereTexteCuve()
      f = open( filename, 'wb')
      print self.texteCuve
      f.write( self.texteCuve )
      f.close()
      ftmp = open( "/tmp/data_template", 'wb')
      ftmp.write( self.texteCuve )
      ftmp.close()

      self.genereTexteTFDEBIT()
      f2 = open( file2, 'wb')
      print self.texteTFDEBIT
      f2.write( self.texteTFDEBIT )
      f2.close()


   def entete(self):
      '''
      Ecrit l'entete du fichier data_template
      '''
      texte  = "############################################################################################"+"\n"
      texte += "#"+"\n"
      texte += "#                OUTIL D'ANALYSE PROBABILISTE DE LA DUREE DE VIE DES CUVES REP"+"\n"
      texte += "#                                     ---------------"+"\n"
      texte += "#                               FICHIER DE MISE EN DONNEES"+"\n"
      texte += "#"+"\n"
      texte += "# SI CALCUL DETERMINISTE :"+"\n"
      texte += "#       - fixer INCRTPS=1, nbectDRTNDT=2., nbectKIc=-2."+"\n"
      texte += "#       - les calculs ne sont possibles qu'en une seule pointe du defaut (POINDEF<>BOTH)"+"\n"
      texte += "# SI CALCUL PROBABILISTE :"+"\n"
      texte += "#       - fixer ARRETFISSURE=NON"+"\n"
      texte += "#"+"\n"
      texte += "############################################################################################"+"\n"
      texte += "#"+"\n"
      return texte

   def rubrique(self, titre):
      '''
      Rubrique 
      '''
      texte  = "#"+"\n"
      texte += "############################################################################################"+"\n"
      texte += "# " + titre + "\n"
      texte += "############################################################################################"+"\n"
      texte += "#"+"\n"
      return texte

   def sousRubrique(self, soustitre, numtitre):
      '''
      Sous-rubrique 
      '''
      texte  = "#"+"\n"
      texte += "# " + numtitre + soustitre + "\n"
      texte += "#==========================================================================================="+"\n"
      texte += "#"+"\n"
      return texte

   def ecritLigne(self, variablelue):
      '''
      Ecrit l'affectation d'une valeur a sa variable, suivie d'un commentaire
      '''
      texte = "%s = %s   # %s\n" % (self.variable[variablelue], str(self.dico_mot[variablelue]), self.comment[variablelue])
      return texte

   def affecteValeurDefaut(self, variablelue):
      '''
      Affecte une valeur par defaut a une variable, suivie d'un commentaire
      '''
      print "Warning ==> Dans la rubrique",self.bloc[variablelue],", valeur par defaut pour ",variablelue," = ",self.default[variablelue]
      texte = "%s = %s   # %s\n" % (self.variable[variablelue], self.default[variablelue], self.comment[variablelue])
      return texte

   def affecteValeur(self, variablelue, valeuraffectee):
      '''
      Affecte une valeur a une variable, suivie d'un commentaire
      '''
      texte = "%s = %s   # %s\n" % (self.variable[variablelue], valeuraffectee, self.comment[variablelue])
      return texte

   def ecritVariable(self, variablelue):
      if self.dico_mot.has_key(variablelue):
         texte = self.ecritLigne(variablelue)
      else :
         texte = self.affecteValeurDefaut(variablelue)
      return texte

   def amontAval(self, amont, aval):
      if str(self.dico_mot[amont])=='Continu':
         if str(self.dico_mot[aval])=='Continu':
            texte = 'CC'+"\n"
	 if str(self.dico_mot[aval])=='Lineaire':
            texte = 'CL'+"\n"
	 if str(self.dico_mot[aval])=='Exclu':
            texte = 'CE'+"\n"
      if str(self.dico_mot[amont])=='Lineaire':
         if str(self.dico_mot[aval])=='Continu':
            texte = 'LC'+"\n"
	 if str(self.dico_mot[aval])=='Lineaire':
            texte = 'LL'+"\n"
	 if str(self.dico_mot[aval])=='Exclu':
            texte = 'LE'+"\n"
      if str(self.dico_mot[amont])=='Exclu':
         if str(self.dico_mot[aval])=='Continu':
            texte = 'EC'+"\n"
	 if str(self.dico_mot[aval])=='Lineaire':
            texte = 'EL'+"\n"
	 if str(self.dico_mot[aval])=='Exclu':
            texte = 'EE'+"\n"
      return texte

   def genereTexteCuve(self):
      self.texteCuve  = ""
      self.texteCuve += self.entete()

      # Rubrique OPTIONS
      self.texteCuve += self.rubrique('OPTIONS')

      self.texteCuve += self.sousRubrique('Impression a l ecran', '')
      if self.dico_mot.has_key('NiveauImpression'):
         self.texteCuve += self.affecteValeur('NiveauImpression', self.valeurproposee[str(self.dico_mot["NiveauImpression"])])

      self.texteCuve += self.sousRubrique('Generation de fichiers', '')
      self.texteCuve += self.ecritVariable('FichierDataIn')
      self.texteCuve += self.ecritVariable('FichierTempSigma')
      self.texteCuve += self.ecritVariable('FichierCSV')
      self.texteCuve += self.ecritVariable('FichierRESTART')
      self.texteCuve += self.ecritVariable('FichierEXTR')
      self.texteCuve += self.ecritVariable('ChoixPlugin')

      self.texteCuve += self.sousRubrique('Grandeur evaluee', '')
      if self.dico_mot.has_key('GrandeurEvaluee'):
         self.texteCuve += self.affecteValeur('GrandeurEvaluee', self.valeurproposee[str(self.dico_mot["GrandeurEvaluee"])])

      self.texteCuve += self.sousRubrique('Divers', '')
      self.texteCuve += self.ecritVariable('IncrementTemporel')
      self.texteCuve += self.ecritVariable('IncrementMaxTemperature')

      #self.texteCuve += self.ecritVariable('ChoixExtractionTransitoires')
      if self.dico_mot.has_key('ChoixExtractionTransitoires'):
         self.texteCuve += self.ecritVariable('ChoixExtractionTransitoires')
         if str(self.dico_mot["ChoixExtractionTransitoires"])=='OUI':
            if self.dico_mot.has_key('ListeAbscisses'):
               self.texteCuve += "# liste des abscisses pour ecriture des transitoires de T et SIG (5 ou moins)"+"\n"
               self.imprime(1,(self.dico_mot["ListeAbscisses"]))
               self.texteCuve+="#"+"\n"
            else :
               print "Warning ==> Dans la rubrique OPTIONS, fournir ListeAbscisses."
               self.texteCuve += "# liste des abscisses pour ecriture des transitoires de T et SIG (5 ou moins)"+"\n"
               self.texteCuve += "  1.994\n"
               self.texteCuve += "  2.000\n"
               self.texteCuve+="#"+"\n"
         else :
            self.texteCuve+="#"+"\n"

      self.texteCuve += self.ecritVariable('IncrementMaxTempsAffichage')
      if self.dico_mot.has_key('ListeInstants'):
         self.texteCuve += "# liste des instants pour ecriture des resultats (s)"+"\n"
         if str(self.dico_mot["TypeConditionLimiteThermique"])=='Calcul TEMPFLU puis DEBIT':
            self.texteCuve+="#BLOC_TFDEBIT"+"\n"
         self.imprime(1,(self.dico_mot["ListeInstants"]))
         if str(self.dico_mot["TypeConditionLimiteThermique"])=='Calcul TEMPFLU puis DEBIT':
            self.texteCuve+="#BLOC_TFDEBIT"+"\n"
         self.texteCuve+="#"+"\n"
      else :
         print "Warning ==> Dans la rubrique OPTIONS, fournir ListeInstants."
         self.texteCuve += "# liste des instants pour ecriture des resultats (s)"+"\n"
         self.texteCuve += "  0.\n"
         self.texteCuve += "  1.\n"
         self.texteCuve+="#"+"\n"


      # Rubrique DONNEES DE LA CUVE
      self.texteCuve += self.rubrique('DONNEES DE LA CUVE')
      if self.dico_mot.has_key('traitementGeometrie'):
         self.texteCuve += self.affecteValeur('traitementGeometrie', self.valeurproposee[str(self.dico_mot["traitementGeometrie"])])
         if str(self.dico_mot["traitementGeometrie"])=='Topologie':
            self.texteCuve+="# - si MAILLAGE, fournir NBNO et liste des abscisses (m)"+"\n"
            self.texteCuve+="# - si GEOMETRIE, fournir (RINT, RINT_MESSAGE),"+"\n"
            self.texteCuve+="#                         (REXT, REXT_MESSAGE),"+"\n"
            self.texteCuve+="#                         (LREV, LREV_MESSAGE),"+"\n"
            self.texteCuve+="#                         (LIGMIN, LIGMIN_MESSAGE),"+"\n"
            self.texteCuve+="#                         NBNO"+"\n"
            self.texteCuve+="#"+"\n"
            self.texteCuve += self.ecritVariable('RayonInterne')
            self.texteCuve += self.ecritVariable('RayonInterne_mess')
            self.texteCuve += self.ecritVariable('RayonExterne')
            self.texteCuve += self.ecritVariable('RayonExterne_mess')
            self.texteCuve += self.ecritVariable('EpaisseurRevetement')
            self.texteCuve += self.ecritVariable('EpaisseurRevetement_mess')
            self.texteCuve+="#"+"\n"
            self.texteCuve += self.ecritVariable('LigamentExterneMin')
            self.texteCuve += self.ecritVariable('LigamentExterneMin_mess')
            self.texteCuve+="#"+"\n"
            self.texteCuve += self.ecritVariable('NombreNoeudsMaillage')
         if str(self.dico_mot["traitementGeometrie"])=='Maillage':
            self.texteCuve+="# - si MAILLAGE, fournir NBNO et liste des abscisses (m)"+"\n"
            self.texteCuve+="# - si GEOMETRIE, fournir (RINT, RINT_MESSAGE),"+"\n"
            self.texteCuve+="#                         (REXT, REXT_MESSAGE),"+"\n"
            self.texteCuve+="#                         (LREV, LREV_MESSAGE),"+"\n"
            self.texteCuve+="#                         (LIGMIN, LIGMIN_MESSAGE),"+"\n"
            self.texteCuve+="#                         NBNO"+"\n"
            self.texteCuve+="#"+"\n"
            self.texteCuve += self.ecritVariable('NombreNoeudsMaillage')
            self.imprime(1,(self.dico_mot["ListeAbscisses"]))
      else :
         self.texteCuve += self.affecteValeurDefaut('traitementGeometrie')
         self.texteCuve+="# - si MAILLAGE, fournir NBNO et liste des abscisses (m)"+"\n"
         self.texteCuve+="# - si GEOMETRIE, fournir (RINT, RINT_MESSAGE),"+"\n"
         self.texteCuve+="#                         (REXT, REXT_MESSAGE),"+"\n"
         self.texteCuve+="#                         (LREV, LREV_MESSAGE),"+"\n"
         self.texteCuve+="#                         (LIGMIN, LIGMIN_MESSAGE),"+"\n"
         self.texteCuve+="#                         NBNO"+"\n"
         self.texteCuve+="#"+"\n"
         self.texteCuve += self.affecteValeurDefaut('RayonInterne')
         self.texteCuve += self.affecteValeurDefaut('RayonInterne_mess')
         self.texteCuve += self.affecteValeurDefaut('RayonExterne')
         self.texteCuve += self.affecteValeurDefaut('RayonExterne_mess')
         self.texteCuve += self.affecteValeurDefaut('EpaisseurRevetement')
         self.texteCuve += self.affecteValeurDefaut('EpaisseurRevetement_mess')
         self.texteCuve+="#"+"\n"
         self.texteCuve += self.affecteValeurDefaut('LigamentExterneMin')
         self.texteCuve += self.affecteValeurDefaut('LigamentExterneMin_mess')
         self.texteCuve+="#"+"\n"
         self.texteCuve += self.affecteValeurDefaut('NombreNoeudsMaillage')


      # Rubrique CARACTERISTIQUES DU DEFAUT
      self.texteCuve += self.rubrique('CARACTERISTIQUES DU DEFAUT')

      if self.dico_mot.has_key('TypeInitial'):
         self.texteCuve += self.affecteValeur('TypeInitial', self.valeurproposee[str(self.dico_mot["TypeInitial"])])
      else :
         self.texteCuve += self.affecteValeurDefaut('TypeInitial')

      self.texteCuve+="# Fournir ORIEDEF, (PROFDEF, PROFDEF_MESSAGE)"+"\n"
      self.texteCuve+="# - Si DSR, fournir OPTLONG, (LONGDEF,LONGDEF_MESSAGE) ou (PROFSURLONG,PROFSURLONG_MESSAGE,LONGCONST)"+"\n"
      self.texteCuve+="# - Si DECALE, fournir OPTLONG, (LONGDEF,LONGDEF_MESSAGE) ou (PROFSURLONG,PROFSURLONG_MESSAGE,LONGCONST), DECATYP, (DECANOR,DECANOR_MESSAGE) ou (DECADEF,DECADEF_MESSAGE)"+"\n"
      self.texteCuve+="# - Si DEBOUCHANT, fournir IRWIN"+"\n"
      self.texteCuve+="# Fournir (ANGLDEF, ANGLDEF_MESSAGE), (ALTIDEF, ALTIDEF_MESSAGE)"+"\n"
      self.texteCuve+="# - Si DSR ou DECALE, fournir POINDEF"+"\n"
      self.texteCuve+="#"+"\n"
      self.texteCuve+="# Remarque :"+"\n"
      self.texteCuve+="# - si DSR ou DECALE, dans la rubrique 'Modele de tenacite', fournir ATTNCORRBETA (ne pas fournir CORRIRWIN)"+"\n"
      self.texteCuve+="# - si DEBOUCHANT,    dans la rubrique 'Modele de tenacite', fournir CORRIRWIN    (ne pas fournir ATTNCORRBETA)"+"\n"

      self.texteCuve+="#"+"\n"

      if self.dico_mot.has_key('Orientation'):
         self.texteCuve += self.affecteValeur('Orientation', self.valeurproposee[str(self.dico_mot["Orientation"])])
      else :
         self.texteCuve += self.affecteValeurDefaut('Orientation')
	 
      if self.dico_mot.has_key('Position'):
         self.texteCuve += self.affecteValeur('Position', self.valeurproposee[str(self.dico_mot["Position"])])
      else :
         self.texteCuve += self.affecteValeurDefaut('Position')
	 
      self.texteCuve+="#"+"\n"
      self.texteCuve += self.ecritVariable('ProfondeurRadiale')
      self.texteCuve += self.ecritVariable('ProfondeurRadiale_mess')

      self.texteCuve+="#"+"\n"
      if self.dico_mot.has_key('TypeInitial'):
         if str(self.dico_mot["TypeInitial"])!='Defaut Debouchant':
            if self.dico_mot.has_key('ModeCalculLongueur'):
               self.texteCuve += self.affecteValeur('ModeCalculLongueur', self.valeurproposee[str(self.dico_mot["ModeCalculLongueur"])])
               if str(self.dico_mot["ModeCalculLongueur"])=='Valeur':
                  self.texteCuve+="# - Si VALEUR,    fournir (LONGDEF, LONGDEF_MESSAGE)"+"\n"
                  self.texteCuve+="# - Si FCTAFFINE, fournir (PROFSURLONG, PROFSURLONG_MESSAGE) et LONGCONST : LONGDEF=PROFDEF/PROFSURLONG + LONGCONST"+"\n"
                  self.texteCuve += self.ecritVariable('Longueur')
                  self.texteCuve += self.ecritVariable('Longueur_mess')
               if str(self.dico_mot["ModeCalculLongueur"])=='Fonction affine de la profondeur':
                  self.texteCuve+="# - Si VALEUR,    fournir (LONGDEF, LONGDEF_MESSAGE)"+"\n"
                  self.texteCuve+="# - Si FCTAFFINE, fournir (PROFSURLONG, PROFSURLONG_MESSAGE) et LONGCONST : LONGDEF=PROFDEF/PROFSURLONG + LONGCONST"+"\n"
                  self.texteCuve += self.ecritVariable('CoefDirecteur')
                  self.texteCuve += self.ecritVariable('CoefDirecteur_mess')
                  self.texteCuve += self.ecritVariable('Constante')
            else :
               self.texteCuve += self.affecteValeurDefaut('ModeCalculLongueur')
               self.texteCuve+="# - Si VALEUR,    fournir (LONGDEF, LONGDEF_MESSAGE)"+"\n"
               self.texteCuve+="# - Si FCTAFFINE, fournir (PROFSURLONG, PROFSURLONG_MESSAGE) et LONGCONST : LONGDEF=PROFDEF/PROFSURLONG + LONGCONST"+"\n"
               self.texteCuve += self.affecteValeurDefaut('Longueur')
               self.texteCuve += self.affecteValeurDefaut('Longueur_mess')

      if self.dico_mot.has_key('TypeInitial'):
         if str(self.dico_mot["TypeInitial"])=='Defaut Decale':
            self.texteCuve+="#"+"\n"
            if self.dico_mot.has_key('ModeCalculDecalage'):
               self.texteCuve += self.affecteValeur('ModeCalculDecalage', self.valeurproposee[str(self.dico_mot["ModeCalculDecalage"])])
               if str(self.dico_mot["ModeCalculDecalage"])=='Valeur normalisee':
                  self.texteCuve+="# - Si NORMALISE, fournir (DECANOR, DECANOR_MESSAGE)"+"\n"
                  self.texteCuve+="# - Si VALEUR,    fournir (DECADEF, DECADEF_MESSAGE)"+"\n"
                  self.texteCuve += self.ecritVariable('DecalageNormalise')
                  self.texteCuve += self.ecritVariable('DecalageNormalise_mess')
               if str(self.dico_mot["ModeCalculDecalage"])=='Valeur':
                  self.texteCuve+="# - Si NORMALISE, fournir (DECANOR, DECANOR_MESSAGE)"+"\n"
                  self.texteCuve+="# - Si VALEUR,    fournir (DECADEF, DECADEF_MESSAGE)"+"\n"
                  self.texteCuve += self.ecritVariable('DecalageRadial')
                  self.texteCuve += self.ecritVariable('DecalageRadial_mess')
            else :
               self.texteCuve += self.affecteValeurDefaut('ModeCalculDecalage')
               self.texteCuve+="# - Si NORMALISE, fournir (DECANOR, DECANOR_MESSAGE)"+"\n"
               self.texteCuve+="# - Si VALEUR, fournir (DECADEF, DECADEF_MESSAGE)"+"\n"
               self.texteCuve += self.affecteValeurDefaut('DecalageRadial')
               self.texteCuve += self.affecteValeurDefaut('DecalageRadial_mess')

      self.texteCuve+="#"+"\n"
      self.texteCuve += self.ecritVariable('Azimut')
      self.texteCuve += self.ecritVariable('Azimut_mess')
      self.texteCuve+="#"+"\n"
      self.texteCuve += self.ecritVariable('Altitude')
      self.texteCuve += self.ecritVariable('Altitude_mess')
      self.texteCuve+="#"+"\n"
      if self.dico_mot.has_key('Pointe'):
         self.texteCuve += self.affecteValeur('Pointe', self.valeurproposee[str(self.dico_mot["Pointe"])])
      #else :
      #   self.texteCuve += self.affecteValeurDefaut('Pointe')

      # Rubrique MODELES FLUENCE, IRRADIATION, TENACITE
      self.texteCuve += self.rubrique('MODELES FLUENCE, IRRADIATION, TENACITE')
      self.texteCuve += self.sousRubrique('Modele d attenuation de la fluence dans l epaisseur','A.')

      if self.dico_mot.has_key('ModeleFluence'):
         self.texteCuve += self.affecteValeur('ModeleFluence', self.valeurproposee[str(self.dico_mot["ModeleFluence"])])
      else :
         self.texteCuve += self.affecteValeurDefaut('ModeleFluence')

      self.texteCuve+="# - si France,          fournir KPFRANCE"+"\n"
      self.texteCuve+="# - si USNRC,           fournir KPUS"+"\n"
      self.texteCuve+="# - si modele GD_Cuve,  fournir COEFFLUENCE1, COEFFLUENCE2, ..., COEFFLUENCE9, COEFFLUENCE10"+"\n"
      self.texteCuve+="#"+"\n"

      self.texteCuve += self.ecritVariable('ZoneActiveCoeur_AltitudeSup')
      self.texteCuve += self.ecritVariable('ZoneActiveCoeur_AltitudeInf')
      self.texteCuve += self.ecritVariable('FluenceMax')
      if self.dico_mot.has_key('ModeleFluence'):
         if str(self.dico_mot["ModeleFluence"])=='Exponentiel sans revetement k=12.7 (France)':
            self.texteCuve += self.ecritVariable('KPFrance')
         if str(self.dico_mot["ModeleFluence"])=='Regulatory Guide 1.99 rev 2 (USNRC)':
            self.texteCuve += self.ecritVariable('KPUS')
         if str(self.dico_mot["ModeleFluence"])=='Grand developpement (GD_Cuve)':
            self.texteCuve += self.ecritVariable('Azimut_0deg')
            self.texteCuve += self.ecritVariable('Azimut_5deg')
            self.texteCuve += self.ecritVariable('Azimut_10deg')
            self.texteCuve += self.ecritVariable('Azimut_15deg')
            self.texteCuve += self.ecritVariable('Azimut_20deg')
            self.texteCuve += self.ecritVariable('Azimut_25deg')
            self.texteCuve += self.ecritVariable('Azimut_30deg')
            self.texteCuve += self.ecritVariable('Azimut_35deg')
            self.texteCuve += self.ecritVariable('Azimut_40deg')
            self.texteCuve += self.ecritVariable('Azimut_45deg')

      self.texteCuve += self.sousRubrique('Irradiation','B.')

      if self.dico_mot.has_key('TypeIrradiation'):
         self.texteCuve += self.affecteValeur('TypeIrradiation', self.valeurproposee[str(self.dico_mot["TypeIrradiation"])])

         if str(self.dico_mot["TypeIrradiation"])=='RTndt de la cuve a l instant de l analyse':
            self.texteCuve+="# - si RTNDT, fournir RTNDT"+"\n"
            self.texteCuve+="# - si FLUENCE, fournir MODELIRR, et autres parametres selon MODELIRR (voir ci-dessous)"+"\n"
            self.texteCuve+="#"+"\n"
            self.texteCuve += self.ecritVariable('RTNDT')

         if str(self.dico_mot["TypeIrradiation"])=='Modele d irradiation':
            self.texteCuve+="# - si RTNDT, fournir RTNDT"+"\n"
            self.texteCuve+="# - si FLUENCE, fournir MODELIRR, et autres parametres selon MODELIRR (voir ci-dessous)"+"\n"
            self.texteCuve+="#"+"\n"
            if self.dico_mot.has_key('ModeleIrradiation'):
               self.texteCuve += self.affecteValeur('ModeleIrradiation', self.valeurproposee[str(self.dico_mot["ModeleIrradiation"])])
            else :
              self.texteCuve += self.affecteValeurDefaut('ModeleIrradiation')
            self.texteCuve+="# - pour tout modele,                                 fournir (CU, CU_MESSAGE),"+"\n"
            self.texteCuve+="#                                                             (NI, NI_MESSAGE),"+"\n"
            self.texteCuve+="# - si HOUSSIN, PERSOZ, LEFEBVRE, BRILLAUD, LEFEBnew, fournir (P, P_MESSAGE)"+"\n"
            self.texteCuve+="# - pour tout modele,                                 fournir (RTimoy, RTimoy_MESSAGE),"+"\n"
            self.texteCuve+="# - si USNRCsoud ou USNRCmdb,                         fournir (RTicov, RTicov_MESSAGE)"+"\n"
            self.texteCuve+="#                                                             (USectDRT, USectDRT_MESSAGE)"+"\n"
            self.texteCuve+="# - pour tout modele,                                 fournir (nbectDRTNDT, nbectDRTNDT_MESSAGE)"+"\n"
            self.texteCuve+="#"+"\n"
            self.texteCuve += self.ecritVariable('TeneurCuivre')
            self.texteCuve += self.ecritVariable('TeneurCuivre_mess')
            self.texteCuve += self.ecritVariable('TeneurNickel')
            self.texteCuve += self.ecritVariable('TeneurNickel_mess')
            if str(self.dico_mot["ModeleIrradiation"])=='Metal de Base : formule de FIM/FIS Houssin' or str(self.dico_mot["ModeleIrradiation"])=='Metal de Base : formule de FIM/FIS Persoz' or str(self.dico_mot["ModeleIrradiation"])=='Metal de Base : formule de FIM/FIS Lefebvre' or str(self.dico_mot["ModeleIrradiation"])=='Joint Soude : formulation de FIM/FIS Brillaud' or str(self.dico_mot["ModeleIrradiation"])=='Formule de FIM/FIS Lefebvre modifiee':
               self.texteCuve += self.ecritVariable('TeneurPhosphore')
               self.texteCuve += self.ecritVariable('TeneurPhosphore_mess')
            self.texteCuve += self.ecritVariable('MoyenneRTndt')
            self.texteCuve += self.ecritVariable('MoyenneRTndt_mess')
            if str(self.dico_mot["ModeleIrradiation"])=='Metal de Base : Regulatory Guide 1.00 rev 2' or str(self.dico_mot["ModeleIrradiation"])=='Joint Soude : Regulatory Guide 1.00 rev 2':
               self.texteCuve += self.ecritVariable('CoefVariationRTndt')
               self.texteCuve += self.ecritVariable('CoefVariationRTndt_mess')
               self.texteCuve += self.ecritVariable('EcartTypeRTndt')
               self.texteCuve += self.ecritVariable('EcartTypeRTndt_mess')
            self.texteCuve += self.ecritVariable('NombreEcartTypeRTndt')
            self.texteCuve += self.ecritVariable('NombreEcartTypeRTndt_mess')
      else :
         self.texteCuve += self.affecteValeurDefaut('TypeIrradiation')
         self.texteCuve+="# - si RTNDT, fournir RTNDT"+"\n"
         self.texteCuve+="# - si FLUENCE, fournir MODELIRR, et autres parametres selon MODELIRR (voir ci-dessous)"+"\n"
         self.texteCuve+="#"+"\n"
         self.texteCuve += self.affecteValeurDefaut('RTNDT')

      self.texteCuve += self.sousRubrique('Modele de tenacite','C.')
      self.texteCuve+="# tenacite d amorcage"+"\n"

      if self.dico_mot.has_key('ModeleTenacite'):
         self.texteCuve += self.affecteValeur('ModeleTenacite', self.valeurproposee[str(self.dico_mot["ModeleTenacite"])])
      else :
         self.texteCuve += self.affecteValeurDefaut('ModeleTenacite')
      self.texteCuve+="# - si RCC-M, RCC-M_pal, Houssin_RC, fournir (nbectKIc, nbectKIc_MESSAGE), KICPAL, KICCDV"+"\n"
      self.texteCuve+="# - si RCC-M_exp,                    fournir (nbectKIc, nbectKIc_MESSAGE), KICCDV"+"\n"
      self.texteCuve+="# - si RCC-M_simpl,                  ne rien fournir"+"\n"
      self.texteCuve+="# - si Frama, LOGWOLF,               fournir (nbectKIc, nbectKIc_MESSAGE)"+"\n"
      self.texteCuve+="# - si REME, ORNL, WEIB3, WEIB2,     fournir NBCARAC, puis (nbectKIc, nbectKIc_MESSAGE) ou (fractKIc, fractKIc_MESSAGE) selon valeur de NBCARAC"+"\n"
      self.texteCuve+="# - si Wallin,                       fournir NBCARAC, puis (nbectKIc, nbectKIc_MESSAGE) ou (fractKIc, fractKIc_MESSAGE) selon valeur de NBCARAC,"+"\n"
      self.texteCuve+="#                                                     puis T0WALLIN"+"\n"
      self.texteCuve+="# - si WEIB-GEN,                     fournir NBCARAC, puis (nbectKIc, nbectKIc_MESSAGE) ou (fractKIc, fractKIc_MESSAGE) selon valeur de NBCARAC,"+"\n"
      self.texteCuve+="#                                                     puis A1, A2, A3, B1, B2, B3, C1, C2, C3"+"\n"
      self.texteCuve+="#   loi de Weibull P(K<x) = 1 - exp{-[ (x-a(T)) / b(T) ]^c(T) }"+"\n"
      self.texteCuve+="#   avec        a(T) = A1 + A2*exp[A3*(T-RTNDT)]"+"\n"
      self.texteCuve+="#               b(T) = B1 + B2*exp[B3*(T-RTNDT)]"+"\n"
      self.texteCuve+="#               c(T) = C1 + C2*exp[C3*(T-RTNDT)]"+"\n"
      self.texteCuve+="#"+"\n"
      self.texteCuve+="# Correction de la longueur"+"\n"
      self.texteCuve += self.ecritVariable('ChoixCorrectionLongueur')
      self.texteCuve+="#"+"\n"
      if self.dico_mot.has_key('ModeleTenacite'):
         if str(self.dico_mot["ModeleTenacite"])=='Weibull basee sur la master cuve' or str(self.dico_mot["ModeleTenacite"])=='Weibull basee sur la master cuve (REME)' or str(self.dico_mot["ModeleTenacite"])=='Weibull n\xb01 (etude ORNL)' or str(self.dico_mot["ModeleTenacite"])=='Weibull n\xb03' or str(self.dico_mot["ModeleTenacite"])=='Weibull n\xb02' or str(self.dico_mot["ModeleTenacite"])=='Weibull generalisee' :
            if self.dico_mot.has_key('NombreCaracteristique'):
               self.texteCuve += self.affecteValeur('NombreCaracteristique', self.valeurproposee[str(self.dico_mot["NombreCaracteristique"])])
            else :
               self.texteCuve += self.affecteValeurDefaut('NombreCaracteristique')
            self.texteCuve+="# - Si NBCARAC = QUANTILE, fournir (nbectKIc, nbectKIc_MESSAGE)"+"\n"
            self.texteCuve+="# - Si NBCARAC = ORDRE,    fournir (fractKIc, fractKIc_MESSAGE)"+"\n"

         if str(self.dico_mot["ModeleTenacite"])=='RCC-M/ASME coefficient=2' or str(self.dico_mot["ModeleTenacite"])=='RCC-M/ASME avec KI=KIpalier' or str(self.dico_mot["ModeleTenacite"])=='RCC-M/ASME coefficient=2.33 (Houssin)' :
            self.texteCuve += self.ecritVariable('NbEcartType_MoyKIc')
            self.texteCuve += self.ecritVariable('NbEcartType_MoyKIc_mess')
            self.texteCuve += self.ecritVariable('PalierDuctile_KIc')
            self.texteCuve += self.ecritVariable('CoefficientVariation_KIc')

         if str(self.dico_mot["ModeleTenacite"])=='Exponentielle n\xb01 (Frama)' or str(self.dico_mot["ModeleTenacite"])=='Exponentielle n\xb02 (LOGWOLF)' :
            self.texteCuve += self.ecritVariable('NbEcartType_MoyKIc')
            self.texteCuve += self.ecritVariable('NbEcartType_MoyKIc_mess')

         if str(self.dico_mot["ModeleTenacite"])=='Weibull basee sur la master cuve (REME)' or str(self.dico_mot["ModeleTenacite"])=='Weibull n\xb01 (etude ORNL)' or str(self.dico_mot["ModeleTenacite"])=='Weibull n\xb03' or str(self.dico_mot["ModeleTenacite"])=='Weibull n\xb02' or str(self.dico_mot["ModeleTenacite"])=='Weibull basee sur la master cuve' or str(self.dico_mot["ModeleTenacite"])=='Weibull generalisee':
            if str(self.dico_mot["NombreCaracteristique"])=='Quantile' :
               self.texteCuve += self.ecritVariable('NbEcartType_MoyKIc')
               self.texteCuve += self.ecritVariable('NbEcartType_MoyKIc_mess')
            if str(self.dico_mot["NombreCaracteristique"])=='Ordre' :
               self.texteCuve += self.ecritVariable('Fractile_KIc')
               self.texteCuve += self.ecritVariable('Fractile_KIc_mess')

            if str(self.dico_mot["ModeleTenacite"])=='Weibull basee sur la master cuve' :
               self.texteCuve += self.ecritVariable('Temperature_KIc100')

            if str(self.dico_mot["ModeleTenacite"])=='Weibull generalisee' :
               self.texteCuve += self.ecritVariable('A1')
               self.texteCuve += self.ecritVariable('A2')
               self.texteCuve += self.ecritVariable('A3')
               self.texteCuve += self.ecritVariable('B1')
               self.texteCuve += self.ecritVariable('B2')
               self.texteCuve += self.ecritVariable('B3')
               self.texteCuve += self.ecritVariable('C1')
               self.texteCuve += self.ecritVariable('C2')
               self.texteCuve += self.ecritVariable('C3')
      else :
         self.texteCuve += self.affecteValeurDefaut('NbEcartType_MoyKIc')
         self.texteCuve += self.affecteValeurDefaut('NbEcartType_MoyKIc_mess')
         self.texteCuve += self.affecteValeurDefaut('PalierDuctile_KIc')
         self.texteCuve += self.affecteValeurDefaut('CoefficientVariation_KIc')

      self.texteCuve+="#"+"\n"
      self.texteCuve+="# Correction plastique"+"\n"

      #DTV if self.dico_mot.has_key('TypeInitial'):
      #DTV    if str(self.dico_mot["TypeInitial"])!='Defaut Debouchant':
      if self.dico_mot.has_key('CorrectionPlastique'):
         if str(self.dico_mot["CorrectionPlastique"])=='Correction plastique BETA (pour DSR et defaut decale)':
            self.texteCuve += self.affecteValeur('AttnCorrBeta','NON')
         if str(self.dico_mot["CorrectionPlastique"])=='Correction plastique BETA attenuee (pour DSR et defaut decale)':
            self.texteCuve += self.affecteValeur('AttnCorrBeta','OUI')
         if str(self.dico_mot["CorrectionPlastique"])=='Correction plastique IRWIN (pour defaut debouchant)':
            self.texteCuve += self.affecteValeur('CorrIrwin','OUI')
      else :
         self.texteCuve += self.affecteValeurDefaut('AttnCorrBeta')

      self.texteCuve+="#"+"\n"
      self.texteCuve+="# Prise en compte de l'arret de fissure si DETERMINISTE"+"\n"

      self.texteCuve += self.ecritVariable('ArretDeFissure')
      self.texteCuve+="# - si ARRETFISSURE=OUI, fournir (INCRDEF, INCRDEF_MESSAGE), nbectKIa, KIAPAL, KIACDV"+"\n"
      if self.dico_mot.has_key('ArretDeFissure'):
         if str(self.dico_mot["ArretDeFissure"])=='OUI':
            self.texteCuve+="#"+"\n"
            self.texteCuve += self.ecritVariable('IncrementTailleFissure')
            self.texteCuve += self.ecritVariable('IncrementTailleFissure_mess')
            self.texteCuve+="#"+"\n"
            self.texteCuve+="# Parametres pour le calcul de la tenacite a l arret"+"\n"
            self.texteCuve += self.ecritVariable('NbEcartType_MoyKIa')
            self.texteCuve += self.ecritVariable('PalierDuctile_KIa')
            self.texteCuve += self.ecritVariable('CoefficientVariation_KIa')

      # Rubrique Etat initial
      self.texteCuve += self.rubrique('ETAT INITIAL')

      self.texteCuve+="# Profil radial de la temperature initiale dans la cuve"+"\n"
      self.texteCuve+="# abscisse (m) / temp initiale dans la cuve"+"\n"
      self.texteCuve+="# Prolongation aux frontieres amont et aval: C = constant / E = exclu / L = lineaire"+"\n"
      if str(self.dico_mot["TypeConditionLimiteThermique"])=='Calcul TEMPFLU puis DEBIT':
         self.texteCuve+="#BLOC_TFDEBIT"+"\n"
      if self.dico_mot.has_key('ProfilRadial_TemperatureInitiale'):
         self.imprime(2,(self.dico_mot["ProfilRadial_TemperatureInitiale"]))
         self.texteCuve += self.amontAval('Amont_TemperatureInitiale','Aval_TemperatureInitiale')
      else :
         self.texteCuve+="    1.9940    287."+"\n"
         self.texteCuve+="CC"+"\n"
      if str(self.dico_mot["TypeConditionLimiteThermique"])=='Calcul TEMPFLU puis DEBIT':
         self.texteCuve+="#BLOC_TFDEBIT"+"\n"

      self.texteCuve+="#"+"\n"
      self.texteCuve+="# Profils radiaux des contraintes residuelles dans la cuve"+"\n"
      self.texteCuve+="# abscisse (m) / sigma rr / sigma tt / sigma zz"+"\n"
      self.texteCuve+="# Prolongation aux frontieres amont et aval: C = constant / E = exclu / L = lineaire"+"\n"
      if self.dico_mot.has_key('ProfilRadial_ContraintesInitiales'):
         self.imprime(4,(self.dico_mot["ProfilRadial_ContraintesInitiales"]))
         self.texteCuve += self.amontAval('Amont_ContraintesInitiales','Aval_ContraintesInitiales')
      else :
         self.texteCuve+="1.994     0. 0.  0."+"\n"
         self.texteCuve+="CC"+"\n"

      self.texteCuve+="#"+"\n"
      self.texteCuve+="# Prise en compte de coefficients sur les contraintes"+"\n"
      self.texteCuve += self.ecritVariable('ChoixCoefficientChargement')
      if str(self.dico_mot["ChoixCoefficientChargement"])=='OUI':
         self.texteCuve += self.ecritVariable('CoefficientDuctile')
         self.texteCuve += self.ecritVariable('CoefficientFragile')
      else :
         self.texteCuve+="#"+"\n"

      self.texteCuve+="#"+"\n"
      self.texteCuve+="# Instant initial"+"\n"
      self.texteCuve += self.ecritVariable('InstantInitialisation')

      # Rubrique CARACTERISTIQUES DU REVETEMENT
      self.texteCuve += self.rubrique('CARACTERISTIQUES DU REVETEMENT')

      if self.dico_mot.has_key('ConditionLimiteThermiqueREV'):
         self.texteCuve += self.affecteValeur('ConditionLimiteThermiqueREV', self.valeurproposee[str(self.dico_mot["ConditionLimiteThermiqueREV"])])
      else :
         self.texteCuve += self.affecteValeurDefaut('ConditionLimiteThermiqueREV')
      self.texteCuve+="# - si CHALEUR,   fournir Temperature (degC) / chaleur volumique (J/kg/K)"+"\n"
      self.texteCuve+="# - si ENTHALPIE, fournir Temperature (degC) / enthalpie (J/kg)"+"\n"
      self.texteCuve+="# Finir chacune des listes par la prolongation aux frontieres amont et aval: C = constant / E = exclu / L = lineaire"+"\n"
      self.texteCuve+="#"+"\n"
      if self.dico_mot.has_key('ChaleurREV_Fct_Temperature'):
         self.texteCuve+="# Temperature (degC) / chaleur volumique (J/kg/K)"+"\n"
         self.imprime(2,(self.dico_mot["ChaleurREV_Fct_Temperature"]))
         self.texteCuve += self.amontAval('Amont_ChaleurREV','Aval_ChaleurREV')
      elif self.dico_mot.has_key('EnthalpieREV_Fct_Temperature'):
         self.texteCuve+="# Temperature (degC) / enthalpie (J/kg)"+"\n"
         self.imprime(2,(self.dico_mot["EnthalpieREV_Fct_Temperature"]))
         self.texteCuve += self.amontAval('Amont_EnthalpieREV','Aval_EnthalpieREV')
      else :
         self.texteCuve+="# Temperature (degC) / chaleur volumique (J/kg/K)"+"\n"
         self.texteCuve+="0.    36.03E5 "+"\n"
         self.texteCuve+="20.   36.03E5 "+"\n"
         self.texteCuve+="200.  41.65E5 "+"\n"
         self.texteCuve+="350.  43.47E5 "+"\n"
         self.texteCuve+="CC"+"\n"

      self.texteCuve+="#"+"\n"
      self.texteCuve+="# Temperature (degC) / conductivite thermique (W/m/degC)"+"\n"
      if self.dico_mot.has_key('ConductiviteREV_Fct_Temperature'):
         self.imprime(2,(self.dico_mot["ConductiviteREV_Fct_Temperature"]))
         self.texteCuve += self.amontAval('Amont_ConductiviteREV','Aval_ConductiviteREV')
      else :
         self.texteCuve+="0.    14.7 "+"\n"
         self.texteCuve+="20.   14.7 "+"\n"
         self.texteCuve+="200.  17.2 "+"\n"
         self.texteCuve+="350.  19.3 "+"\n"
         self.texteCuve+="CC"+"\n"

      self.texteCuve+="#"+"\n"
      self.texteCuve+="# Temperature (degC) / module d'Young (MPa)"+"\n"
      if self.dico_mot.has_key('ModuleYoungREV_Fct_Temperature'):
         self.imprime(2,(self.dico_mot["ModuleYoungREV_Fct_Temperature"]))
         self.texteCuve += self.amontAval('Amont_ModuleYoungREV','Aval_ModuleYoungREV')
      else :
         self.texteCuve+="0.    198500. "+"\n"
         self.texteCuve+="20.   197000. "+"\n"
         self.texteCuve+="200.  184000. "+"\n"
         self.texteCuve+="350.  172000. "+"\n"
         self.texteCuve+="CC"+"\n"

      self.texteCuve+="#"+"\n"
      self.texteCuve+="# Temperature (degC) / coefficient de dilatation thermique (degC-1)"+"\n"
      if self.dico_mot.has_key('CoeffDilatThermREV_Fct_Temperature'):
         self.imprime(2,(self.dico_mot["CoeffDilatThermREV_Fct_Temperature"]))
         self.texteCuve += self.amontAval('Amont_CoeffDilatThermREV','Aval_CoeffDilatThermREV')
      else :
         self.texteCuve+="0.    16.40E-6 "+"\n"
         self.texteCuve+="20.   16.40E-6 "+"\n"
         self.texteCuve+="200.  17.20E-6 "+"\n"
         self.texteCuve+="350.  17.77E-6 "+"\n"
         self.texteCuve+="CC"+"\n"

      self.texteCuve+="#"+"\n"
      self.texteCuve+="# Temperature (degC) / limite d'elasticite (MPa)"+"\n"
      if self.dico_mot.has_key('LimiteElasticiteREV_Fct_Temperature'):
         self.imprime(2,(self.dico_mot["LimiteElasticiteREV_Fct_Temperature"]))
         self.texteCuve += self.amontAval('Amont_LimiteElasticiteREV','Aval_LimiteElasticiteREV')
      else :
         self.texteCuve+="0.    380. "+"\n"
         self.texteCuve+="20.   370. "+"\n"
         self.texteCuve+="100.  330. "+"\n"
         self.texteCuve+="300.  270. "+"\n"
         self.texteCuve+="LL"+"\n"

      self.texteCuve+="#"+"\n"
      self.texteCuve += self.ecritVariable('TemperatureDeformationNulleREV')
      self.texteCuve += self.ecritVariable('TemperaturePourCoefDilatThermREV')
      self.texteCuve += self.ecritVariable('CoefficientPoissonREV')

      # Rubrique CARACTERISTIQUES DU METAL DE BASE
      self.texteCuve += self.rubrique('CARACTERISTIQUES DU METAL DE BASE')

      if self.dico_mot.has_key('ConditionLimiteThermiqueMDB'):
         self.texteCuve += self.affecteValeur('ConditionLimiteThermiqueMDB', self.valeurproposee[str(self.dico_mot["ConditionLimiteThermiqueMDB"])])
      else :
         self.texteCuve += self.affecteValeurDefaut('ConditionLimiteThermiqueMDB')

      self.texteCuve+="# - si CHALEUR,   fournir Temperature (degC) / chaleur volumique (J/kg/K)"+"\n"
      self.texteCuve+="# - si ENTHALPIE, fournir Temperature (degC) / enthalpie (J/kg)"+"\n"
      self.texteCuve+="# Finir chacune des listes par la prolongation aux frontieres amont et aval: C = constant / E = exclu / L = lineaire"+"\n"
      self.texteCuve+="#"+"\n"

      if self.dico_mot.has_key('ChaleurMDB_Fct_Temperature'):
         self.texteCuve+="# Temperature (degC) / chaleur volumique (J/kg/K)"+"\n"
         self.imprime(2,(self.dico_mot["ChaleurMDB_Fct_Temperature"]))
         self.texteCuve += self.amontAval('Amont_ChaleurMDB','Aval_ChaleurMDB')
      elif self.dico_mot.has_key('EnthalpieMDB_Fct_Temperature'):
         self.texteCuve+="# Temperature (degC) / enthalpie (J/kg)"+"\n"
         self.imprime(2,(self.dico_mot["EnthalpieMDB_Fct_Temperature"]))
         self.texteCuve += self.amontAval('Amont_EnthalpieMDB','Aval_EnthalpieMDB')
      else :
         self.texteCuve+="# Temperature (degC) / chaleur volumique (J/kg/K)"+"\n"
         self.texteCuve+="0.    34.88E+05 "+"\n"
         self.texteCuve+="20.   34.88E+05 "+"\n"
         self.texteCuve+="200.  40.87E+05 "+"\n"
         self.texteCuve+="350.  46.02E+05 "+"\n"
         self.texteCuve+="CC"+"\n"

      self.texteCuve+="#"+"\n"
      self.texteCuve+="# Temperature (degC) / conductivite thermique (W/m/degC)"+"\n"
      if self.dico_mot.has_key('ConductiviteMDB_Fct_Temperature'):
         self.imprime(2,(self.dico_mot["ConductiviteMDB_Fct_Temperature"]))
         self.texteCuve += self.amontAval('Amont_ConductiviteMDB','Aval_ConductiviteMDB')
      else :
         self.texteCuve+="0.    37.7 "+"\n"
         self.texteCuve+="20.   37.7 "+"\n"
         self.texteCuve+="200.  40.5 "+"\n"
         self.texteCuve+="350.  38.7 "+"\n"
         self.texteCuve+="CC"+"\n"

      self.texteCuve+="#"+"\n"
      self.texteCuve+="# Temperature (degC) / module d'Young (MPa)"+"\n"
      if self.dico_mot.has_key('ModuleYoungMDB_Fct_Temperature'):
         self.imprime(2,(self.dico_mot["ModuleYoungMDB_Fct_Temperature"]))
         self.texteCuve += self.amontAval('Aval_ModuleYoungMDB','Aval_ModuleYoungMDB')
      else :
         self.texteCuve+="0.    205000. "+"\n"
         self.texteCuve+="20.   204000. "+"\n"
         self.texteCuve+="200.  193000. "+"\n"
         self.texteCuve+="350.  180000. "+"\n"
         self.texteCuve+="CC"+"\n"

      self.texteCuve+="#"+"\n"
      self.texteCuve+="# Temperature (degC) / coefficient de dilatation thermique (degC-1)"+"\n"
      if self.dico_mot.has_key('CoeffDilatThermMDB_Fct_Temperature'):
         self.imprime(2,(self.dico_mot["CoeffDilatThermMDB_Fct_Temperature"]))
         self.texteCuve += self.amontAval('Amont_CoeffDilatThermMDB','Aval_CoeffDilatThermMDB')
      else :
         self.texteCuve+="0.    11.22E-6 "+"\n"
         self.texteCuve+="20.   11.22E-6 "+"\n"
         self.texteCuve+="200.  12.47E-6 "+"\n"
         self.texteCuve+="350.  13.08E-6 "+"\n"
         self.texteCuve+="CC"+"\n"

      self.texteCuve+="#"+"\n"
      self.texteCuve += self.ecritVariable('TemperatureDeformationNulleMDB')
      self.texteCuve += self.ecritVariable('TemperaturePourCoefDilatThermMDB')
      self.texteCuve += self.ecritVariable('CoefficientPoissonMDB')

      # Rubrique CARACTERISTIQUES DU TRANSITOIRE MECANIQUE-THERMOHYDRAULIQUE
      self.texteCuve += self.rubrique('CARACTERISTIQUES DU TRANSITOIRE MECANIQUE-THERMOHYDRAULIQUE')
      self.texteCuve += self.sousRubrique('Chargement mecanique : transitoire de pression','')

      self.texteCuve+="# instant (s) / pression (MPa)"+"\n"
      self.texteCuve+="# Prolongation aux frontieres amont et aval: C = constant / E = exclu / L = lineaire"+"\n"
      if str(self.dico_mot["TypeConditionLimiteThermique"])=='Calcul TEMPFLU puis DEBIT':
         self.texteCuve+="#BLOC_TFDEBIT"+"\n"
      if self.dico_mot.has_key('ProfilTemporel_Pression'):
         self.imprime(2,(self.dico_mot["ProfilTemporel_Pression"]))
         self.texteCuve += self.amontAval('Amont_Pression','Aval_Pression')
      else :
         self.texteCuve+="0.    15.5 "+"\n"
         self.texteCuve+="20.   0.1 "+"\n"
         self.texteCuve+="200.  0.1 "+"\n"
         self.texteCuve+="1000. 0.1 "+"\n"
         self.texteCuve+="CC"+"\n"
      if str(self.dico_mot["TypeConditionLimiteThermique"])=='Calcul TEMPFLU puis DEBIT':
         self.texteCuve+="#BLOC_TFDEBIT"+"\n"

      self.texteCuve += self.sousRubrique('Chargement thermo-hydraulique','')
      if self.dico_mot.has_key('TypeConditionLimiteThermique'):
         if str(self.dico_mot["TypeConditionLimiteThermique"])=='Calcul TEMPFLU puis DEBIT':
            self.texteCuve+="#BLOC_TFDEBIT"+"\n"
         self.texteCuve += self.affecteValeur('TypeConditionLimiteThermique', self.valeurproposee[str(self.dico_mot["TypeConditionLimiteThermique"])])
         if str(self.dico_mot["TypeConditionLimiteThermique"])=='Calcul TEMPFLU puis DEBIT':
            self.texteCuve+="#BLOC_TFDEBIT"+"\n"
      else :
         self.texteCuve += self.affecteValeurDefaut('TypeConditionLimiteThermique')

      self.texteCuve+="# - si TEMP_IMPO, fournir Instant (s) / Temperature imposee (degC)"+"\n"
      self.texteCuve+="# - si FLUX_REP,  fournir Instant (s) / Flux de chaleur impose (W/m2)"+"\n"
      self.texteCuve+="# - si ECHANGE,   fournir Instant (s) / Temperature impose (degC)"+"\n"
      self.texteCuve+="#                    puis Instant (s) / Coefficient d echange (W/m2/K)"+"\n"
      self.texteCuve+="# - si DEBIT,     fournir Instant (s) / Debit massique (kg/s)"+"\n"
      self.texteCuve+="#                    puis Instant (s) / Temperature d injection de securite  (degC)"+"\n"
      self.texteCuve+="#                    puis Modele VESTALE : (DH, DH_MESSAGE), (SECTION, SECTION_MESSAGE), (DELTA, DELTA_MESSAGE), EPS, COEFVESTALE"+"\n"
      self.texteCuve+="#                    puis Modele CREARE  : "+"\n"
      self.texteCuve+="#                        Instants(s) / Volume de melange CREARE (m3)"+"\n"
      self.texteCuve+="#                        puis (T0, T0_MESSAGE), (SE, SE_MESSAGE)"+"\n"
      self.texteCuve+="# - si TEMP_FLU,  fournir Instant (s) / Temperature du fluide (degC)"+"\n"
      self.texteCuve+="#                    puis Instant (s) / Debit d injection de securite  (kg/s)"+"\n"
      self.texteCuve+="#                    puis Modele VESTALE : (DH, DH_MESSAGE), (SECTION, SECTION_MESSAGE), (DELTA, DELTA_MESSAGE), EPS, COEFVESTALE"+"\n"
      self.texteCuve+="# - si TFDEBIT,   fournir INST_PCN et TIS"+"\n"
      self.texteCuve+="#                 fournir Instant (s) / Temperature du fluide (degC)"+"\n"
      self.texteCuve+="#                    puis Instant (s) / Debit d injection de securite  (kg/s)"+"\n"
      self.texteCuve+="#                    puis Modele VESTALE : (DH, DH_MESSAGE), (SECTION, SECTION_MESSAGE), (DELTA, DELTA_MESSAGE), EPS, COEFVESTALE"+"\n"
      self.texteCuve+="#                    puis Modele CREARE  : "+"\n"
      self.texteCuve+="#                        Instants(s) / Volume de melange CREARE (m3)"+"\n"
      self.texteCuve+="#                        puis (T0, T0_MESSAGE), (SE, SE_MESSAGE)"+"\n"
      self.texteCuve+="# - si APRP,      fournir INSTANT1, INSTANT2, INSTANT3, QACCU, QIS, (TIS, TIS_MESSAGE)"+"\n"
      self.texteCuve+="#                    puis Instant (s) / Temperature du fluide (degC) tel que dans l'exemple ci-dessous"+"\n"
      self.texteCuve+="#                         0.    286."+"\n"
      self.texteCuve+="#                         12.   20.             # 1er palier à T=TACCU"+"\n"
      self.texteCuve+="#                         20.   20.             # idem que ci-dessus : T=TACCU"+"\n"
      self.texteCuve+="#                         21.   999999.         # 2nd palier à T=T1 : sera remplace par nouvelle valeur calculee par fonction idoine"+"\n"
      self.texteCuve+="#                         45.   999999.         # idem que ci-dessus : T=T1"+"\n"
      self.texteCuve+="#                         46.   9.              # 3eme palier à T=TIS, temperature d injection de securite : sa valeur est reactualisee avec la donnee de TIS ci-dessous"+"\n"
      self.texteCuve+="#                         1870. 9.              # idem que ci-dessus : T=TIS"+"\n"
      self.texteCuve+="#                         1871. 80."+"\n"
      self.texteCuve+="#                         3871. 80."+"\n"
      self.texteCuve+="#                         CC                    # C pour Constant, E pour Exclu, L pour Lineaire"+"\n"
      self.texteCuve+="#                    puis Instant (s) / Debit d injection de securite  (kg/s)"+"\n"
      self.texteCuve+="#                    puis Modele VESTALE : (DH, DH_MESSAGE), (SECTION, SECTION_MESSAGE), (DELTA, DELTA_MESSAGE), EPS, COEFVESTALE"+"\n"
      self.texteCuve+="# Finir chacune des listes par la prolongation aux frontieres amont et aval: C = constant / E = exclu / L = lineaire"+"\n"
      self.texteCuve+="#"+"\n"

      if self.dico_mot.has_key('TypeConditionLimiteThermique'):

         if str(self.dico_mot["TypeConditionLimiteThermique"])=='Calcul TEMPFLU puis DEBIT':
            self.texteCuve+="#"+"\n"
            self.texteCuve+="#BLOC_TFDEBIT"+"\n"
            self.texteCuve += self.ecritVariable('InstantPerteCirculationNaturelle')
            self.texteCuve += self.ecritVariable('TempInjectionSecurite')
            self.texteCuve+="#BLOC_TFDEBIT"+"\n"

         if str(self.dico_mot["TypeConditionLimiteThermique"])=='Courbe APRP':
            self.texteCuve+="#"+"\n"
            self.texteCuve+="# Definition de parametres pour le cas d un transitoire APRP"+"\n"
            self.texteCuve += self.ecritVariable('Instant_1')
            self.texteCuve += self.ecritVariable('Instant_2')
            self.texteCuve += self.ecritVariable('Instant_3')
            self.texteCuve += self.ecritVariable('DebitAccumule')
            self.texteCuve += self.ecritVariable('DebitInjectionSecurite')
            self.texteCuve += self.ecritVariable('TempInjectionSecurite')
            self.texteCuve += self.ecritVariable('TempInjectionSecurite_mess')

         if str(self.dico_mot["TypeConditionLimiteThermique"])=='Temperature imposee en paroi' or str(self.dico_mot["TypeConditionLimiteThermique"])=='Temperature imposee du fluide et coefficient echange' or str(self.dico_mot["TypeConditionLimiteThermique"])=='Temperature imposee du fluide et debit d injection de securite' or str(self.dico_mot["TypeConditionLimiteThermique"])=='Calcul TEMPFLU puis DEBIT' or str(self.dico_mot["TypeConditionLimiteThermique"])=='Courbe APRP' :
            self.texteCuve+="#"+"\n"
            self.texteCuve+="# instant (s) / temperature imposee du fluide (degC)"+"\n"
            if str(self.dico_mot["TypeConditionLimiteThermique"])=='Calcul TEMPFLU puis DEBIT':
               self.texteCuve+="#BLOC_TFDEBIT"+"\n"
            if self.dico_mot.has_key('ProfilTemporel_TemperatureImposeeFluide'):
               self.imprime(2,(self.dico_mot["ProfilTemporel_TemperatureImposeeFluide"]))
               self.texteCuve += self.amontAval('Amont_TemperatureImposeeFluide','Aval_TemperatureImposeeFluide')
	    else :
               self.texteCuve+="0.    286. "+"\n"
               self.texteCuve+="20.   20. "+"\n"
               self.texteCuve+="200.  7. "+"\n"
               self.texteCuve+="1000. 80. "+"\n"
               self.texteCuve+="CC"+"\n"
            if str(self.dico_mot["TypeConditionLimiteThermique"])=='Calcul TEMPFLU puis DEBIT':
               self.texteCuve+="#BLOC_TFDEBIT"+"\n"

         if str(self.dico_mot["TypeConditionLimiteThermique"])=='Flux de chaleur impose en paroi':
            self.texteCuve+="#"+"\n"
            self.texteCuve+="# instant (s) / flux de chaleur impose (W/m2)"+"\n"
            if self.dico_mot.has_key('ProfilTemporel_FluxChaleur'):
               self.imprime(2,(self.dico_mot["ProfilTemporel_FluxChaleur"]))
               self.texteCuve += self.amontAval('Amont_FluxChaleur','Aval_FluxChaleur')
               self.texteCuve+="#"+"\n"
	    else :
               self.texteCuve+="0.    -0. "+"\n"
               self.texteCuve+="20.   -366290. "+"\n"
               self.texteCuve+="200.  -121076. "+"\n"
               self.texteCuve+="1000.  -56372."+"\n"
               self.texteCuve+="CC"+"\n"

         if str(self.dico_mot["TypeConditionLimiteThermique"])=='Temperature imposee du fluide et debit d injection de securite' or str(self.dico_mot["TypeConditionLimiteThermique"])=='Calcul TEMPFLU puis DEBIT' or str(self.dico_mot["TypeConditionLimiteThermique"])=='Courbe APRP':
            self.texteCuve+="#"+"\n"
            self.texteCuve+="# instant (s) / Debit d injection de securite  (kg/s)"+"\n"
            if str(self.dico_mot["TypeConditionLimiteThermique"])=='Calcul TEMPFLU puis DEBIT':
               self.texteCuve+="#BLOC_TFDEBIT"+"\n"
            if self.dico_mot.has_key('ProfilTemporel_DebitInjection'):
               self.imprime(2,(self.dico_mot["ProfilTemporel_DebitInjection"]))
               self.texteCuve += self.amontAval('Amont_DebitInjection','Aval_DebitInjection')
	    else :
               self.texteCuve+="0.    4590. "+"\n"
               self.texteCuve+="20.   4590. "+"\n"
               self.texteCuve+="200.  340. "+"\n"
               self.texteCuve+="1000. 31.1 "+"\n"
               self.texteCuve+="CC"+"\n"
            if str(self.dico_mot["TypeConditionLimiteThermique"])=='Calcul TEMPFLU puis DEBIT':
               self.texteCuve+="#BLOC_TFDEBIT"+"\n"

         if str(self.dico_mot["TypeConditionLimiteThermique"])=='Temperature imposee du fluide et coefficient echange' :
            self.texteCuve+="#"+"\n"
            self.texteCuve+="# instant (s) / Coefficient d echange (W/m2/K)"+"\n"
            if self.dico_mot.has_key('ProfilTemporel_CoefficientEchange'):
               self.imprime(2,(self.dico_mot["ProfilTemporel_CoefficientEchange"]))
               self.texteCuve += self.amontAval('Amont_CoefficientEchange','Aval_CoefficientEchange')
	    else :
               self.texteCuve+="0.    138454. "+"\n"
               self.texteCuve+="20.   19972. "+"\n"
               self.texteCuve+="200.  2668. "+"\n"
               self.texteCuve+="1000. 2668. "+"\n"
               self.texteCuve+="CC"+"\n"

         if str(self.dico_mot["TypeConditionLimiteThermique"])=='Debit massique et temperature d injection de securite' :
            self.texteCuve+="#"+"\n"
            self.texteCuve+="# instant (s) / Debit massique (kg/s)"+"\n"
            if self.dico_mot.has_key('ProfilTemporel_DebitMassique'):
               self.imprime(2,(self.dico_mot["ProfilTemporel_DebitMassique"]))
               self.texteCuve += self.amontAval('Amont_DebitMassique','Aval_DebitMassique')
	    else :
               self.texteCuve+="0.    18.4 "+"\n"
               self.texteCuve+="20.   18.4 "+"\n"
               self.texteCuve+="200.  31.1 "+"\n"
               self.texteCuve+="1000. 31.1 "+"\n"
               self.texteCuve+="CC"+"\n"

            self.texteCuve+="#"+"\n"
            self.texteCuve+="# instant (s) / Temperature d injection de securite  (degC)"+"\n"
            if self.dico_mot.has_key('ProfilTemporel_TemperatureInjection'):
               self.imprime(2,(self.dico_mot["ProfilTemporel_TemperatureInjection"]))
               self.texteCuve += self.amontAval('Amont_TemperatureInjection','Aval_TemperatureInjection')
	    else :
               self.texteCuve+="0.    7.0 "+"\n"
               self.texteCuve+="20.   7.0 "+"\n"
               self.texteCuve+="200.  7.0 "+"\n"
               self.texteCuve+="1000. 7.0 "+"\n"
               self.texteCuve+="CC"+"\n"

         if str(self.dico_mot["TypeConditionLimiteThermique"])=='Debit massique et temperature d injection de securite' or str(self.dico_mot["TypeConditionLimiteThermique"])=='Temperature imposee du fluide et debit d injection de securite' or str(self.dico_mot["TypeConditionLimiteThermique"])=='Calcul TEMPFLU puis DEBIT' or str(self.dico_mot["TypeConditionLimiteThermique"])=='Courbe APRP' :
            self.texteCuve+="#"+"\n"
            self.texteCuve+="# Transitoire des coefficients d echange : modele VESTALE"+"\n"
            self.texteCuve+="#"+"\n"
            if str(self.dico_mot["TypeConditionLimiteThermique"])=='Calcul TEMPFLU puis DEBIT':
               self.texteCuve+="#BLOC_TFDEBIT"+"\n"
            self.texteCuve += self.ecritVariable('DiametreHydraulique')
            self.texteCuve += self.ecritVariable('DiametreHydraulique_mess')
            self.texteCuve+="#"+"\n"
            self.texteCuve += self.ecritVariable('SectionEspaceAnnulaire')
            self.texteCuve += self.ecritVariable('SectionEspaceAnnulaire_mess')
            self.texteCuve+="#"+"\n"
            self.texteCuve += self.ecritVariable('HauteurCaracConvectionNaturelle')
            self.texteCuve += self.ecritVariable('HauteurCaracConvectionNaturelle_mess')
            self.texteCuve+="#"+"\n"
            self.texteCuve += self.ecritVariable('CritereConvergenceRelative')
            self.texteCuve += self.ecritVariable('CoefficientsVestale')
            if str(self.dico_mot["TypeConditionLimiteThermique"])=='Calcul TEMPFLU puis DEBIT':
               self.texteCuve+="#BLOC_TFDEBIT"+"\n"

         if str(self.dico_mot["TypeConditionLimiteThermique"])=='Debit massique et temperature d injection de securite' or str(self.dico_mot["TypeConditionLimiteThermique"])=='Calcul TEMPFLU puis DEBIT' :
            self.texteCuve+="#"+"\n"
            self.texteCuve+="# Transitoire de temperature fluide locale : modele CREARE"+"\n"
            self.texteCuve+="#"+"\n"
            #self.texteCuve += self.ecritVariable('VolumeMelange_CREARE')
            self.texteCuve+="# instant (s) / Volume de melange CREARE  (m3)"+"\n"
            if str(self.dico_mot["TypeConditionLimiteThermique"])=='Calcul TEMPFLU puis DEBIT':
               self.texteCuve+="#BLOC_TFDEBIT"+"\n"
            if self.dico_mot.has_key('ProfilTemporel_VolumeMelange_CREARE'):
               self.imprime(2,(self.dico_mot["ProfilTemporel_VolumeMelange_CREARE"]))
               self.texteCuve += self.amontAval('Amont_VolumeMelange_CREARE','Aval_VolumeMelange_CREARE')
	    else :
               self.texteCuve+="0.    14.3 "+"\n"
               self.texteCuve+="20.   14.2 "+"\n"
               self.texteCuve+="CC"+"\n"
            if str(self.dico_mot["TypeConditionLimiteThermique"])=='Calcul TEMPFLU puis DEBIT':
               self.texteCuve+="#BLOC_TFDEBIT"+"\n"
            else :
               self.texteCuve+="#"+"\n"
            self.texteCuve += self.ecritVariable('TemperatureInitiale_CREARE')
            if str(self.dico_mot["TypeConditionLimiteThermique"])=='Calcul TEMPFLU puis DEBIT':
               self.texteCuve+="#BLOC_TFDEBIT"+"\n"
            self.texteCuve += self.ecritVariable('TemperatureInitiale_CREARE_mess')
            self.texteCuve+="#"+"\n"
            self.texteCuve += self.ecritVariable('SurfaceEchange_FluideStructure')
            self.texteCuve += self.ecritVariable('SurfaceEchange_FluideStructure_mess')
            if str(self.dico_mot["TypeConditionLimiteThermique"])=='Calcul TEMPFLU puis DEBIT':
               self.texteCuve+="#BLOC_TFDEBIT"+"\n"
      else :
         self.texteCuve+="#"+"\n"
         self.texteCuve+="# instant (s) / temperature imposee du fluide (degC)"+"\n"
         self.texteCuve+="0.    286. "+"\n"
         self.texteCuve+="20.   20. "+"\n"
         self.texteCuve+="200.  7. "+"\n"
         self.texteCuve+="1000. 80. "+"\n"
         self.texteCuve+="CC"+"\n"
      self.texteCuve+="#"+"\n"
      self.texteCuve+="############################################################################################"+"\n"


   def genereTexteTFDEBIT(self):

      self.texteTFDEBIT = ""

      if self.dico_mot.has_key('TypeConditionLimiteThermique'):
         if str(self.dico_mot["TypeConditionLimiteThermique"])=='Calcul TEMPFLU puis DEBIT' :
            self.texteTFDEBIT+="# instant (s) / pression (MPa)"+"\n"
            self.texteTFDEBIT+=" "+"\n"
            self.imprime2(2,(self.dico_mot["ProfilTemporel_Pression"]))
            self.texteTFDEBIT += self.amontAval('Amont_Pression','Aval_Pression')

       #     self.texteTFDEBIT+=" "+"\n"
       #     self.texteTFDEBIT += self.affecteValeur('TypeConditionLimiteThermique', self.valeurproposee[str(self.dico_mot["TypeConditionLimiteThermique"])])

            self.texteTFDEBIT+=" "+"\n"
            self.imprime2(2,(self.dico_mot["ProfilTemporel_TemperatureImposeeFluide"]))
            self.texteTFDEBIT += self.amontAval('Amont_TemperatureImposeeFluide','Aval_TemperatureImposeeFluide')

            self.texteTFDEBIT+=" "+"\n"
            self.imprime2(2,(self.dico_mot["ProfilTemporel_DebitInjection"]))
            self.texteTFDEBIT += self.amontAval('Amont_DebitInjection','Aval_DebitInjection')

            self.texteTFDEBIT+=" "+"\n"
            self.texteTFDEBIT += self.ecritVariable('DiametreHydraulique')
            self.texteTFDEBIT += self.ecritVariable('DiametreHydraulique_mess')
            self.texteTFDEBIT+="#"+"\n"
            self.texteTFDEBIT += self.ecritVariable('SectionEspaceAnnulaire')
            self.texteTFDEBIT += self.ecritVariable('SectionEspaceAnnulaire_mess')
            self.texteTFDEBIT+="#"+"\n"
            self.texteTFDEBIT += self.ecritVariable('HauteurCaracConvectionNaturelle')
            self.texteTFDEBIT += self.ecritVariable('HauteurCaracConvectionNaturelle_mess')
            self.texteTFDEBIT+="#"+"\n"
            self.texteTFDEBIT += self.ecritVariable('CritereConvergenceRelative')
            self.texteTFDEBIT += self.ecritVariable('CoefficientsVestale')

            self.texteTFDEBIT+=" "+"\n"
            self.imprime2(2,(self.dico_mot["ProfilTemporel_VolumeMelange_CREARE"]))
            self.texteTFDEBIT += self.amontAval('Amont_VolumeMelange_CREARE','Aval_VolumeMelange_CREARE')

            self.texteTFDEBIT+=" "+"\n"
            self.texteTFDEBIT += self.ecritVariable('SurfaceEchange_FluideStructure')
            self.texteTFDEBIT += self.ecritVariable('SurfaceEchange_FluideStructure_mess')
            self.texteTFDEBIT += self.ecritVariable('InstantPerteCirculationNaturelle')
            self.texteTFDEBIT += self.ecritVariable('TempInjectionSecurite')
         else :
            self.texteTFDEBIT+="Fichier inutile"+"\n"


   def imprime(self,nbdeColonnes,valeur):
      self.liste=[]
      self.transforme(valeur)
      i=0
      while i < len(self.liste):
          for k in range(nbdeColonnes) :
              self.texteCuve+=str(self.liste[i+k]) +"  "
          self.texteCuve+="\n"
          i=i+k+1
               
   def imprime2(self,nbdeColonnes,valeur):
      self.liste=[]
      self.transforme(valeur)
      i=0
      while i < len(self.liste):
          for k in range(nbdeColonnes) :
              self.texteTFDEBIT+=str(self.liste[i+k]) +"  "
          self.texteTFDEBIT+="\n"
          i=i+k+1
               

   def transforme(self,valeur):
      for i in valeur :
          if type(i) == tuple :
             self.transforme(i)
          else :
             self.liste.append(i)
          



