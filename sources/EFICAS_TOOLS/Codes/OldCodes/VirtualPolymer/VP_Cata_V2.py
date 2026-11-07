# coding: utf-8
import types
from Accas import *

import lienDB
import listesDB

monDico= { 'Equation_Liste' : ('initiation', 'propagation', 'termination', 'stabilization'),
           'Modele_TechnicalUse' : ('cable', 'coating', 'pipes'),
           'Aging_Factor' : { 'predefinedSimulationTime' : ('40years BR top', '40years BR bottom')},
           'Boundary_Conditions' : ('flux_volume','flux_surface','constant_constration','convection_flux'),
           'postTraitement_Typ' : ('chimique','mecanique','physique'),
         }

monModele=listesDB.sModele().monModele
monPost=listesDB.sModele().monPost

import types
class Tuple:
    def __init__(self,ntuple):
        self.ntuple=ntuple

    def __convert__(self,valeur):
        if type(valeur) == types.StringType:
            return None
        if len(valeur) != self.ntuple:
            return None
        return valeur

    def info(self):
        return "Tuple de %s elements" % self.ntuple


JdC = JDC_CATA(code='VP',
               execmodul=None,
                )


#---------------------------------
Equation = PROC (nom="Equation",
      op=None,
#---------------------------------
      Equation_DB=SIMP(statut= 'o',typ= 'TXM', into=("Approved data base", "My data base") ),
      #b_suite = BLOC(condition = "Equation_DB ==  'My data base' ",
      Equation_Type = SIMP(statut= 'o',typ= 'TXM', into=("Show equation database", "Equation creation"),),
      #),
      #b_suite_2 = BLOC(condition = "Equation_DB ==  'Approved data base' ",
      #Equation_Type = SIMP(statut= 'o',typ= 'TXM', into=("Show equation database", ),),
      #),

#     ---------------------------------------------------------------------------
       b_type_show = BLOC(condition = " Equation_Type == 'Show equation database'",
#      ---------------------------------------------------------------------------
        Equation_Liste=SIMP(statut= 'o',typ= 'TXM', into=('reaction_type','aging_type')),

         b_reaction_type =  BLOC(condition = " Equation_Liste  == 'reaction_type'",
           Equation_reaction=SIMP(statut= 'o',typ= 'TXM', into=monDico['Equation_Liste'],siValide=lienDB.recupereDicoEquation),
         ), # Fin b_reaction_type

         b_aging_type =  BLOC(condition = " Equation_Liste  == 'aging_type'",
              Equation_reaction=SIMP(statut= 'o',typ= 'TXM', into=('All', 'thermo', 'radio'),siValide=lienDB.recupereDicoEquation),
         ), # Fin b_reaction_type

         ListeEquation = SIMP(statut='o', typ='TXM',  homo='SansOrdreNiDoublon',siValide=lienDB.afficheValeurEquation),
         #ListeEquation = SIMP(statut='o', typ='TXM',  homo='SansOrdreNiDoublon'),
         b_modification = BLOC(condition = " ListeEquation != None ",
           modification = SIMP(typ = bool, statut = 'o',defaut = False, fr='toto', ang='toto en anglais', siValide=lienDB.instancieChemicalFormulation),

           b_modif = BLOC(condition = "modification == True",
            Reaction_Type=SIMP(statut= 'o',typ= 'TXM', min=1,into=monDico['Equation_Liste'],),
            Aging_Type=SIMP(statut= 'o',typ= 'TXM', min=1,max='**', homo='SansOrdreNiDoublon', into=('All', 'thermo', 'radio'),),
            ChemicalFormulation = SIMP(statut='o', typ='TXM', defaut = 'POOH -> 2P'),

            OptionnelConstituant =  FACT ( statut = 'f',max = '**',
                Constituant = SIMP (statut = 'o', typ = 'TXM'),
                Differential_Equation =  SIMP(statut= 'o',typ= 'TXM'),
               ), # fin Const_Equa
            OptionnelleConstante  = FACT (statut = 'f', max = '**',
                  ConstanteName= SIMP (statut = 'o', typ = 'TXM',),
                  ConstanteType =  SIMP(statut= 'o',typ= 'TXM', min=1,into=('Arrhenius type','non Arrhenius type'),defaut='Arrhenius type'),
                  ),# fin ConstanteOptionnelle
            Commentaire =  SIMP (statut = 'f', typ = 'TXM', defaut = ' '),


           ),# fin b_modif

         ), # fin b_modification
       ), # Fin b_type_show


#     ---------------------------------------------------------------------------
      b_type_creation = BLOC(condition = " Equation_Type == 'Equation creation'",
#         ---------------------------------------------------------------------------
         Equation_Modification = FACT ( statut = 'o',

            ChemicalFormulation = SIMP(statut='o', typ='TXM', defaut = 'POOH -> 2P'),

            Reaction_Type=SIMP(statut= 'o',typ= 'TXM', min=1,into=monDico['Equation_Liste'],),
            Aging_Type=SIMP(statut= 'o',typ= 'TXM', min=1,max='**', homo='SansOrdreNiDoublon', into=('All', 'thermo', 'radio'),),

            Constituants = FACT ( statut = 'o',
               ConstituantPOOH = SIMP (statut = 'f', typ = 'TXM', into = ('POOH',)),
               b_pooh =  BLOC(condition = " ConstituantPOOH == 'POOH'" ,
                  Differential_Equation_POOH =  SIMP(statut= 'o',typ= 'TXM', defaut = '-ku1*POOH'),
               ), # Fin b_pooh
               #ConstituantP = SIMP (statut = 'f', typ = 'TXM', into = ('P',)),
               #b_p =  BLOC(condition = " ConstituantP == 'P'" ,
               #  Differential_Equation_P =  SIMP(statut= 'o',typ= 'TXM', defaut = '2*ku1*POOH'),
               #), # Fin b_p
               ConstituantP = FACT ( statut = 'f',
                  ConstituantP = SIMP (statut = 'f', typ = 'TXM', into = ('P',)),
                  Differential_Equation_P =  SIMP(statut= 'o',typ= 'TXM', defaut = '2*ku1*POOH'),
               ), # Fin ConstituantP

            OptionnelConstituant =  FACT ( statut = 'f',max = '**',
                Constituant = SIMP (statut = 'o', typ = 'TXM'),
                Differential_Equation =  SIMP(statut= 'o',typ= 'TXM'),
               ), # fin Const_Equa
            ),# Fin Constituants

            Constante = FACT ( statut = 'o',
               Constanteku1 = SIMP (statut = 'f', typ = 'TXM', into = ('ku1',), defaut= 'ku1'),
               b_cku1 =  BLOC(condition = "Constanteku1 == 'ku1'" ,
                  ConstanteType =  SIMP(statut= 'o',typ= 'TXM', into=('Arrhenius type','non Arrhenius type'),defaut='Arrhenius type'),
                  ),
               OptionnelleConstante  = FACT (statut = 'f', max = '**',
                  ConstanteName= SIMP (statut = 'o', typ = 'TXM',),
                  ConstanteType =  SIMP(statut= 'o',typ= 'TXM', min=1,into=('Arrhenius type','non Arrhenius type'),defaut='Arrhenius type'),
                  ),# fin ConstanteOptionnelle
            ), # fin constante
            Commentaire =  SIMP (statut = 'f', typ = 'TXM', defaut = ' '),

         ), # Fin Equation_Modification
        ),  # fin b_type_creation


) # Fin Equation

#---------------------------------
Modele = PROC (nom="Modele",
      op=None,
      Modele_DB=SIMP(statut= 'o',typ= 'TXM', into=("Approved data base", "My data base"),siValide=lienDB.recupereDicoModele ),
      Modele_Type = SIMP(statut= 'o',typ= 'TXM', into=("Show modele database", "Modele creation"),siValide=lienDB.creeListeEquation),
#     ---------------------------------------------------------------------------
      b_type_creation = BLOC(condition = " Modele_Type == 'Modele creation'",
#         ---------------------------------------------------------------------------
        ID=FACT(statut='o',
          technicalUse= SIMP(statut= 'o',typ= 'TXM',into=monDico['Modele_TechnicalUse'],defaut=monModele.technical_use ),
          modeleName=SIMP(statut='o',typ='TXM',defaut=monModele.nom,),
          material=SIMP(statut='o',typ='TXM',defaut=monModele.materiaux[0],),
          agingType=SIMP(statut= 'o',typ='TXM', min=1,max='**', homo='SansOrdreNiDoublon', into=('All', 'thermo', 'radio'), defaut=monModele.type_vieil),
          stabilizer = SIMP(typ = bool, statut = 'o',defaut = monModele.stabilise),
          material_thickness = SIMP(typ = 'TXM', statut = 'o',defaut = monModele.thickness, into = ['thin','thick']),
          # il faudrait que position=global_jdc fonctionne
          model_developed_by_for_EDF = SIMP(typ = bool, statut = 'o',defaut = monModele.dvt_EDF[0]),
          documentation=SIMP(statut='o',typ='TXM',defaut=monModele.reference,),

       ), # fin ID
       # ajouter la liste des equations et le remove (il faut garder ceux qu on a enlever)

      Chemical_Equation = FACT( statut='o',
       Initial_Equation_List=SIMP(statut='o',typ='TXM',max="**",homo='SansOrdreNiDoublon',into=[],defaut=[], siValide=lienDB.recupereModeleEquation),

       AjoutEquation=SIMP(statut= 'o',typ= bool, defaut=False, siValide=lienDB.recupereModeleEquation),
       b_ajout_equation = BLOC(condition = " AjoutEquation == True",
          listeEquation_initiation=SIMP(statut='o', typ='TXM',homo='SansOrdreNiDoublon', max='**', min=0, defaut=[],siValide=lienDB.ajoutDUneEquation ),
          listeEquation_propagation=SIMP(statut='o', typ='TXM',homo='SansOrdreNiDoublon', max='**', min=0, defaut=[],siValide=lienDB.ajoutDUneEquation ),
          listeEquation_termination=SIMP(statut='o', typ='TXM',homo='SansOrdreNiDoublon', max='**', min=0, defaut=[],siValide=lienDB.ajoutDUneEquation ),
          listeEquation_stabilization=SIMP(statut='o',typ='TXM', homo='SansOrdreNiDoublon', max='**', min=0, defaut=[],siValide=lienDB.ajoutDUneEquation ),
       ),# fin b_ajout_equation

      ), # fin Equation
        # coefficients monModele.coef = liste de dictionnaire mais il faut prendre que le 0
        # on enleve ceux qui commence par D, S et B(casse imprtante)
        # la clef est le coef, puis les valeurs


      #b_material_thickness =  BLOC(condition = "material_thickness == 'thick'",
      # si position=global fonctionne
        Transport = FACT( statut = 'o',
        #Diffusion = SIMP(typ = bool, statut = 'o',defaut = monModele.diffusion,siValide = lienDB.prepareDiffusion),
        Diffusion = SIMP(typ = bool, statut = 'o',defaut = False ,siValide = lienDB.prepareDiffusion),

        b_diffusion = BLOC(condition = " Diffusion == True",
           listeProduitPourLaDiffusion=SIMP(statut='o', typ='TXM', max='**', min=1,homo='SansOrdreNiDoublon', into = [],siValide=lienDB.ajouteDiffusion),
          ),  # fin b_diffusion

        Evaporation = SIMP(typ = bool, statut = 'o',defaut = False ,siValide = lienDB.prepareDiffusion),
        b_evaporation = BLOC(condition = " Evaporation == True",
           listeProduitPourLEvaporation=SIMP(statut='o', typ='TXM', max='**', min=1,homo='SansOrdreNiDoublon', into = [],siValide=lienDB.ajouteEvaporation),
         ),  # fin b_evaporation


         ),  # fin TRANSPORT
       #),  # fin b_material_thickness

      Coefficients = FACT( statut = 'o',
        Coef_k2  = SIMP (statut ='o', typ='R'),
        Coef_ku1 = SIMP (statut ='o', typ=Tuple(2),validators = VerifTypeTuple(('R','R')),),
      ),
      Parametres_Initiaux = FACT( statut = 'o',
        Param_POOH=SIMP (statut ='o', typ='R'),
        # La liste est la meme que le INTO des listeProduitsPourlaDiffusion
        # la valeur par defaut si elle existe est contenue dans modele.param_ini['POOH']
      ),


       #AjoutEquation=Fact(statut='f',
       #     Reaction_Type=SIMP(statut= 'o',typ= 'TXM', min=1,into=monDico['Equation_Liste'],siValide=lienDB.recupereModeleEquation),
       #), # fin AjoutEquation
      ), # fin Creation
#     ---------------------------------------------------------------------------
      b_type_modification = BLOC(condition = " Modele_Type == 'Show modele database'",
#         ---------------------------------------------------------------------------
          technicalUse= SIMP(statut= 'o',typ= 'TXM',into=monDico['Modele_TechnicalUse'],siValide=lienDB.creeListeMateriauxSelonModele),
          b_technicalUse = BLOC (condition = 'technicalUse != None and technicalUse != ""',
            material= SIMP (statut ='o', typ='TXM',siValide=lienDB.creeListeModelesPossibles),
            modele= SIMP (statut ='o', typ='TXM',siValide=lienDB.choisitModele),
            b_modele = BLOC (condition = 'modele != None and modele != ""',
              action = SIMP (statut ='o', typ='TXM',into = ['display','use','modify'], siValide=lienDB.choisitActionModele),
#     ---------------------------------------------------------------------------
           b_type_modify = BLOC(condition = " action == 'modify'",
#         ---------------------------------------------------------------------------
          ID=FACT(statut='o',
          modeleName=SIMP(statut='o',typ='TXM'),
          technicalUse= SIMP(statut= 'o',typ= 'TXM', into=monDico['Modele_TechnicalUse'] ),
          material=SIMP(statut='o',typ='TXM'),
          agingType=SIMP(statut= 'o',typ='TXM', min=1,max='**', homo='SansOrdreNiDoublon', into=('All', 'thermo', 'radio')),
          stabilizer = SIMP(typ = bool, statut = 'o',),
          material_thickness = SIMP(typ = 'TXM', statut = 'o', into = ['thin','thick']),
          # il faudrait que position=global_jdc fonctionne
          model_developed_by_for_EDF = SIMP(typ = bool, statut = 'o',),
          documentation=SIMP(statut='o',typ='TXM',),


# il faut recopier toute la suite en changeant eventuellement le nom du modele
# il faut cocher toutes les equations par defaut

              ), # fin ID
             ), # fin b_type_modify
#     ---------------------------------------------------------------------------
           b_type_use = BLOC(condition = " action == 'use'",
#         ---------------------------------------------------------------------------
             simulationName=SIMP(statut='o',typ='TXM'),
             outputFolder = SIMP(statut="o", typ="Repertoire",siValide=lienDB.creeCoefAModifier),
            ), # fin b_type_use
#     ---------------------------------------------------------------------------
           b_type_use2 = BLOC(condition = " action == 'use'",
#         ---------------------------------------------------------------------------
            Aging_Factor = FACT(statut='o',
                predefinedSimulationTime = SIMP(statut='o',typ='TXM',into=monDico['Aging_Factor']['predefinedSimulationTime'],siValide=lienDB.remplirAgingFactor),
                simulationTime=SIMP(statut='o',typ='R',),
                numberOfNodes=SIMP(statut='o',typ='I',val_min=3,siValide=lienDB.creeInitialParameter),
                sampleThickness=SIMP(statut='o',typ='R',),
                #debitOfDose=SIMP(statut='o',typ='R',),
                temperature=SIMP(statut='o',typ='R',),
                oxygenPressure=SIMP(statut='o',typ='R',),
                polymerConcentration=SIMP(statut='o',typ='R',),
                ),
            Initial_Parameter = FACT(statut='o',
                max='**',
                ),
            Boundary_Conditions_Param = FACT(statut='o',
                diffusionSpecies=SIMP(statut='o',typ='TXM',defaut='O2', into=['O2',]),
                nodeNumber = SIMP(statut='o',typ='I',defaut=1, into=[1]), # tjours1
                Boundary_Conditions_O2_1 = SIMP(statut='o',typ='TXM',into=monDico['Boundary_Conditions']),
                BC_Value_Espece_1=SIMP(statut='o',typ='R'),
                nodeNumber_Espece_4 = SIMP(statut='o',typ='I',defaut=4, into=[4]), # numberOfNodes+1
                Boundary_Conditions_Espece_4 = SIMP(statut='o',typ='TXM',into=monDico['Boundary_Conditions']),
                BC_Value_Espece_4=SIMP(statut='o',typ='R'),
                ),

            ), # fin b_type_use2
          ), # fin b_modele
        ), # fin b_technicalUse
      ), # fin modification

      Commentaire =  SIMP (statut = 'f', typ = 'TXM'),
) # Fin Modele
#---------------------------------
PostTraitement = PROC (nom="PostTraitement",
      op=None,
      postTraitement_DB=SIMP(statut= 'o',typ= 'TXM', into=("Approved data base", "My data base") ),
      postTraitement_Type = SIMP(statut= 'o',typ= 'TXM', into=("Show post-traitement database", "post-traitement creation"),),
#     ---------------------------------------------------------------------------
      b_post_creation = BLOC(condition = " postTraitement_Type == 'post-traitement creation'",
        postTraitement_Name=SIMP(statut= 'o',typ= 'TXM',defaut=monPost.nom,),
        generic=SIMP(statut= 'o',typ= bool,defaut=monPost.general,),
        postTraitement_Typ = SIMP(statut= 'o',typ= 'TXM', into=monDico['postTraitement_Typ'],homo='SansOrdreNiDoublon',max='**',defaut=monPost.type_post),
        calculation= FACT(statut='o',
        # il faut un fact horizontal
        calculation_results=SIMP(statut= 'o',typ= 'TXM', min=0,max='**', intoSug=monPost.calculation_results,defaut=monPost.calculation_results),
        results_units=SIMP(statut= 'o',typ= 'TXM', min=0,max='**', intoSug=monPost.results_units,defaut=monPost.results_units),
        #integrate=SIMP(statut= 'o',typ= 'TXM', min=0,max='**', intoSug=monPost.results_units,defaut=monPost.results_units),
        prerequisite=SIMP(statut= 'o',typ= 'TXM', min=0,max='**', intoSug=monPost.prerequisite,defaut=monPost.prerequisite),

        ),
        constituant=SIMP(statut= 'o',typ= 'TXM', min=0,max='**', intoSug=monPost.constituants,defaut=monPost.constituants)

      )# fin b_post_creation
#         ---------------------------------------------------------------------------
#---------------------------------
) #PostTraitement
