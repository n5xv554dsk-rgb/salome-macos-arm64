# coding: utf-8

from Accas import *
class DateJJMMAAAA:
  def __init__(self):
    self.ntuple=3

  def __convert__(self,valeur):
    if type(valeur) == types.StringType: return None
    if len(valeur) != self.ntuple: return None
    return valeur

  def info(self):
    return "Date : jj/mm/aaaa "

  __repr__=info
  __str__=info

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



JdC = JDC_CATA (code = 'TELEMAC',
                execmodul = None,
                )
# ======================================================================
# Catalog entry for the MAP function : c_pre_interfaceBody_mesh
# ======================================================================

# -----------------------------------------------------------------------
INITIALIZATION = PROC(nom = "INITIALIZATION",op = None,
# -----------------------------------------------------------------------

     fr = "Initialisation des fichiers d'entrée et de sortie",
     ang = "Input and Output files initialization",
     UIinfo = { "groupes" : ( "CACHE", )},
     #UIinfo = { "groupes" : ( "iiii", )},

#    ------------------------------------
     Title = SIMP( statut = 'o',typ = 'TXM',
#    ------------------------------------
          fr = 'Titre du cas etudie. Ce titre figurera sur les dessins.',
          ang = 'Title of the case being considered. This title shall be marked on the drawings.'),
     #Working_Directory = SIMP( statut='o',typ='Repertoire',defaut='/tmp'),

#    ------------------------------------
     Input_Files = FACT(statut='o',
#    ------------------------------------

       #  Dictionary = SIMP( statut='o', typ = ('Fichier', 'Dico (*.dico);;All Files (*)',), 
       #                    defaut='telemac2d.dico', 
       #                    fr='Dictionnaire des mots cles.', ang='Key word dictionary.',),
# PN : le mot cle doit etre dans le dictionnaire et repris du catalogue mais n 
# est pas modifiable

#        ------------------------------------
         Geometry_File_Format = SIMP( statut = 'o', typ = 'TXM',
#        ------------------------------------
             into = ['Serafin', 'MED', 'SerafinD'], 
             defaut = 'Serafin',
             fr = 'Format du fichier de geometrie. Les valeurs possibles sont : \n \
     - SERAFIN : format standard simple precision pour Telemac;   \n \
     - SERAFIND: format standard double precision pour Telemac;   \n \
     - MED     : format MED base sur HDF5',
             ang = 'Results file format. Possible values are: \n\
     - SERAFIN : classical single precision format in Telemac;\n\
     - SERAFIND: classical double precision format in Telemac;\n\
     - MED     : MED format based on HDF5',) ,

      b_geofile_med = BLOC (condition = "Geometry_File_Format == 'MED'",
#        ------------------------------------
         Geometry_File = SIMP( statut = 'o', 
#        ------------------------------------
# PNPNPN Question Soizic --> pourqoi Geo Files
# idem pour Bottom_Topography_File
             typ = ('Fichier',' Med Files (*.med);;All Files (*)',),
             fr = 'Nom du fichier contenant le maillage du calcul a realiser.',
             ang = 'Name of the file containing the mesh. \n\
This file may also contain the topography and the friction coefficients.'),

      ),
      b_geofile_serafin = BLOC (condition = "Geometry_File_Format in ( 'Serafin','SerafinD')",
#        ------------------------------------
         Geometry_File = SIMP( statut = 'o', 
#        ------------------------------------
# PNPNPN Question Soizic --> pourqoi Geo Files
# idem pour Bottom_Topography_File
             typ = ('Fichier', 'Geo Files (*.geo);;All Files (*)',),
             fr = 'Nom du fichier contenant le maillage du calcul a realiser.',
             ang = 'Name of the file containing the mesh. \n\
This file may also contain the topography and the friction coefficients.'),

      ),
          #Steering_File = SIMP( statut = 'o', typ = ('Fichier', 'Steering Files (*.cas);;All Files (*)',),),


#        ------------------------------------
         Fortran_File = SIMP(statut = 'f',
#        ------------------------------------
             typ = ('Fichier', 'Fortran files (*.f);;All Files (*)'),
             fr = 'Nom du fichier a soumettre',
             ang = 'Name of FORTRAN file to be submitted',),

#        ------------------------------------
         Bottom_Topography_File = SIMP( statut = 'f', 
#        ------------------------------------
              typ = ('Fichier', 'Geo Files (*.geo);;All Files (*)',),
              fr = "Nom du fichier eventuel contenant la bathymetrie associee au maillage. \
Si ce mot-cle est utilise; c'est cette bathymetrie qui sera utilisee pour le calcul.",
              ang = 'Name of the possible file containing the bathymetric data.\
Where this keyword is used, these bathymetric data shall be used in the computation.',
         ),

#         ------------------------------------
          Bottom_Smoothings = SIMP( statut = 'o',typ = 'I', defaut = 0 ,
#         ------------------------------------
              fr = 'Nombre de lissages effectues sur la topographie.  chaque lissage, effectue a l aide dune matrice de masse, est conservatif.\n\
Utilise lorsque les donnees de bathymetrie donnent des resultats trop irreguliers apres interpolation.',
              ang = 'Number of smoothings on bottom topography.  each smoothing is mass conservative.  \n\
to be used when interpolation of bathymetry on the mesh gives very rough results.',),

#        ------------------------------------
          Boundary_Conditions_File = SIMP( statut = 'o', 
#        ------------------------------------
              typ = ('Fichier', 'Boundary Condition (*.cli);;All Files (*)',),
              fr = 'Nom du fichier contenant les types de conditions aux limites. Ce fichier est rempli de facon automatique\n\
par le mailleur au moyen de couleurs affectees aux noeuds des frontieres du domaine de calcul.',
              ang = 'Name of the file containing the types of boundary conditions. This file is filled automatically\n\
by the mesh generator through through colours that are assigned to the boundary nodes.',),


#        ------------------------------------
         Validation = FACT( statut = 'f',
#        ------------------------------------
#PNPN--> creer le Mot_clef simple Validation si ce fact existe

#            ------------------------------------
             Reference_File_Format = SIMP( statut = 'o',
#            ------------------------------------
                 typ = 'TXM', 
                 into = ['Serafin','MED','SerafinD'], 
                 defaut = 'Serafin',
                 fr = 'Format du fichier de resultats. Les valeurs possibles sont : \n\
     - SERAFIN : format standard simple precision pour Telemac;  \n\
     - SERAFIND: format standard double precision pour Telemac; \n\
     - MED     : format MED base sur HDF5' ,
                 ang = 'Results file format. Possible values are:\n \
     - SERAFIN : classical single precision format in Telemac;\n\
     - SERAFIND: classical double precision format in Telemac; \n\
     - MED     : MED format based on HDF5' ,),

#            ------------------------------------
             Reference_File = SIMP( statut = 'o', 
#            ------------------------------------
                 typ = ('Fichier', 'Reference File (*.ref);;All Files (*)',), 
                 fr = 'Fichier de resultats de reference pour la validation. Les resultats a placer dans ce fichier seront a ecrire sur le canal 22.',
                 ang = 'Binary-coded result file for validation. The results to be entered into this file shall be written on channel 22.',),

         ),  # Fin de Validation

#        ------------------------------------
         Formatted_And_Binary_Files = FACT( statut = 'f',
#        ------------------------------------

#            ------------------------------------
             Formatted_Data_File_1 = SIMP( statut = 'f', typ = ('Fichier', 'formated File (*.txt);;All Files (*)',),
#            ------------------------------------
                  fr = "Fichier de donnees formate mis a la disposition de l''utilisateur.  \n\
Les donnees de ce fichier seront a lire sur le canal 26.",
                  ang = 'Formatted data file made available to the user.\n\
The data in this file shall be read on channel 26.',),

#            ------------------------------------
             Formatted_Data_File_2 = SIMP( statut = 'f', typ = ('Fichier', 'formated File (*.txt);;All Files (*)',),
#            ------------------------------------
                  fr = "Fichier de donnees formate mis a la disposition de l'utilisateur. \n\
Les donnees de ce fichier seront a lire sur le canal 27.",
                  ang = "Formatted data file made available to the user.\n\
The data in this file shall be read on channel 27.",),

#            ------------------------------------
             Binary_Data_File_1 = SIMP( statut = 'f', typ = ('Fichier', 'All Files (*)',),
#            ------------------------------------
                  fr = 'Fichier de donnees code en binaire mis a la disposition de l utilisateur. \n\
Les donnees de ce fichier seront a lire sur le canal 24.',
                  ang = 'Binary-coded data file made available to the user.\n\
The data in this file shall be read on channel 24.',),

#            ------------------------------------
             Binary_Data_File_2 = SIMP( statut = 'f', typ = ('Fichier', 'All Files (*)',),
#            ------------------------------------
                  fr = 'Fichier de donnees code en binaire mis a la disposition de l utilisateur.\n\
Les donnees de ce fichier seront a lire sur le canal 25.',
                   ang = 'Binary-coded data file made available to the user. \n\
The data in this file shall be read on channel 25.',),

         ),  # fin Formatted_And_Binary_Files

     ), # Fin de InputFile 

    # -----------------------------------------------------------------------
    Initial_State = FACT(statut='o',
    # -----------------------------------------------------------------------

#    ------------------------------------
     Initial_Conditions = SIMP(statut = 'o',typ = 'TXM',
#    ------------------------------------
          into = ['Zero elevation','Constant elevation','Zero depth','Constant depth','Special','TPXO satellite altimetry'],
          defaut = 'Zero elevation',
          fr = "Permet de definir les conditions initiales sur les hauteurs d'eau. Les valeurs possibles sont :\n\
    - COTE NULLE. Initialise la cote de surface libre a 0. \nLes hauteurs d'eau initiales sont alors retrouvees en faisant la difference entre les cotes de surface libre et du fond. \n\
    - COTE CONSTANTE . Initialise la cote de surface libre a la valeur donnee par le mot-cle COTE INITIALE. Les hauteurs d'eau initiales sont calculees comme precedemment.\n\
   - HAUTEUR NULLE .Initialise les hauteurs d'eau a 0. \n\
   - HAUTEUR CONSTANTE. Initialise les hauteurs d'eau a la valeur donnee par le mot-cle HAUTEUR INITIALE. \n\
   - PARTICULIERES. Les conditions initiales sur la hauteur d'eau doivent etre precisees dans le sous-programme CONDIN. \n\
   - ALTIMETRIE SATELLITE TPXO. Les conditions initiales sur la hauteur  d'eau et les vitesses sont etablies sur \n\
      la base des donnees satellite TPXO dont les 8 premiers constistuents ont ete extraits et sauves dans le fichier\n\
      BASE DE DONNEES DE MAREE." ,
         ang = 'Makes it possible to define the initial conditions with the water depth. The possible values are : \n\
   - ZERO ELEVATION. Initializes the free surface elevation to 0. \n The initial water depths are then found by computing the difference between the free surface and the bottom.  \n\
   - CONSTANT ELEVATION. Initializes the water elevation to the value given by the keyword \n\
   - INITIAL ELEVATION. The initial water depths are computed as in the previous case. \n\
   - ZERO DEPTH. Initializes the water depths to 0. \n\
   - CONSTANT DEPTH. Initializes the water depths to the value givenby the key-word  INITIAL DEPTH. \n\
   - SPECIAL. The initial conditions with the water depth should be stated in the CONDIN subroutine. \n\
   - TPXO SATELITE ALTIMETRY. The initial conditions on the free surface and velocities are established from the TPXO satellite program data,\n the harmonic constituents of which are stored in the TIDE DATA BASE file.', ),
 
#    ------------------------------------
     b_initial_elevation = BLOC (condition = "Initial_Conditions == 'Constant elevation'",
#    ------------------------------------
#        ------------------------------------
         Initial_Elevation = SIMP(statut = 'o',typ = 'R',
#        ------------------------------------
             fr = 'Valeur utilisee avec l''option :  CONDITIONS INITIALES - COTE CONSTANTE',
             ang = 'Value to be used with the option : INITIAL CONDITIONS  -CONSTANT ELEVATION' ),
     ) , # fin b_initial_elevation

#    ------------------------------------
     b_initial_depth = BLOC (condition = "Initial_Conditions == 'Constant depth'",
#    ------------------------------------
#        ------------------------------------
         Initial_Depth = SIMP(statut = 'o',typ = 'R',
#        ------------------------------------
             fr = 'Valeur utilisee avec l''option : CONDITIONS INITIALES :-HAUTEUR CONSTANTE-',
             ang = 'Value to be used along with the option: INITIAL CONDITIONS -CONSTANT DEPTH-' ),
         ),# fin b_initial_depth
 
#    ------------------------------------
     b_special = BLOC (condition = "Initial_Conditions == 'Special'",
#    ------------------------------------
#        ------------------------------------
         Consigne = SIMP(statut = "o",homo = 'information',typ = "TXM",
#        ------------------------------------
             defaut = "The initial conditions with the water depth should be stated in the CONDIN subroutine"),
      ), # fin b_special

#PNPN il faut changer la condition pour que cela soit dans maree. il faut une position = global_jdc et remonter # cela
#    ------------------------------------
     b_initial_TPXO = BLOC (condition = "Initial_Conditions == 'TPXO satellite altimetry'",
#    ------------------------------------
#        ------------------------------------
         Ascii_Database_For_Tide = SIMP( statut = 'o', 
#        ------------------------------------
             typ = ('Fichier', 'All Files (*)',), 
             fr = 'Base de donnees de constantes harmoniques tirees du fichier du modele de maree',
             ang = 'Tide data base of harmonic constituents extracted from the tidal model file',),
         ), # fin b_initial_TPXO

    ), # fin Initial_State 


#    ------------------------------------
     Computation_Continued = SIMP( statut = 'o',typ = bool,defaut = False,position = "global_jdc"),
#    ------------------------------------

#    ------------------------------------
     b_comput_con = BLOC(condition = 'Computation_Continued == True',
     Computation_Continued_Settings = FACT(statut = 'o',

#        ------------------------------------
         Previous_Computation_File_Format = SIMP( statut = 'o',typ = 'TXM',
#        ------------------------------------
              into = ['Serafin','MED','SerafinD'],
              defaut = 'Serafin',
              fr = 'Format du fichier de resultats du calcul precedent. Les valeurs possibles sont : \n\
         - SERAFIN : format standard simple precision pour Telemac;  \n\
         - SERAFIND: format standard double precision pour Telemac; \n\
         - MED     : format MED base sur HDF5',
              ang = 'Previous computation results file format. Possible values are: \n\
         - SERAFIN : classical single precision format in Telemac;  \n\
         - SERAFIND: classical double precision format in Telemac; \n\
         - MED     : MED format based on HDF5',),

#        ------------------------------------
         Previous_Computation_File = SIMP( statut = 'o', 
#        ------------------------------------
             typ = ('Fichier', 'Computation File (*.res);;All Files (*)',),
             fr = "Nom d'un fichier contenant les resultats d'un calcul precedent realise sur le meme maillage \n\
 et dont le dernier pas de temps enregistre va fournir les conditions initiales pour une suite de de calcul.",
             ang = 'Name of a file containing the results of an earlier computation which was made on the same mesh.\n\
 The last recorded time step will provid the initial conditions for the new computation.',
                    ),
#        ------------------------------------
          Initial_Time_Set_To_Zero = SIMP(typ = bool, statut = 'o',
#        ------------------------------------
             fr = 'Remet le temps a zero en cas de suite de calcul',
             ang = 'Initial time set to zero in case of restart',
             defaut = "False"),

#        ------------------------------------
          Record_Number_For_Restart = SIMP(typ = 'I', statut = 'o', defaut = 0,
#        ------------------------------------
              fr = "numero de l'enregistrement de depart dans le fichier du calcul precedent. 0 signifie qu'on prend le dernier enregistrement", 
              ang = "record number to start from in the previous computation file, 0 for last record" ),

        ),
     ),# fin BLOC b_comput_con 

#    ------------------------------------
     Coupling = FACT( statut = 'o',
#    ------------------------------------
# PNPNPN Attention 1 seul choix possible
        fr = 'Liste des codes avec lesquels on couple Telemac-2D',
        ang = 'List of codes to be coupled with Telemac-2D',

#        ------------------------------------
         Sisyphe = SIMP(statut = 'o',typ = bool,defaut = False ,
#        ------------------------------------
             fr = 'couplage interne avec Sisyphe', 
             ang = 'internal coupling with Sisyphe'),

#        ------------------------------------
         Tomawac = SIMP(statut = 'o',typ = bool,defaut = False,
#        ------------------------------------
             fr = 'couplage interne avec Tomawac', 
             ang = 'internal coupling with Tomawac'),

#        ------------------------------------
         Delwacq = SIMP(statut = 'o',typ = bool,defaut = False,
#        ------------------------------------
             fr = 'couplage interne avec Delwacq', 
             ang = 'internal coupling with Delwacq'),
# PNPNPN Attention : il faut des mots cles si Delwacq. a voir avec Soizic 
# On verra apres

        ), # fin Coupling

#    ------------------------------------
      Parallel_Computation = SIMP(statut = 'o',typ = 'TXM',
#    ------------------------------------
#    Ce mot clef n existe pas dans le dico
         into = ['Sequentiel','Parallel'],
         defaut = 'Sequentiel',),

#    ------------------------------------
      b_para = BLOC(condition = 'Parallel_Computation == "Parallel"',
#    ------------------------------------
#        ------------------------------------
         Parallel_Processors = SIMP(statut = 'o',typ = 'I',
#        ------------------------------------
             val_min = 0,defaut = 1,
             fr = 'NOMBRE DE PROCESSEURS EN CALCUL PARALLELE \n\
0 : 1 machine, compilation sans bibliotheque de parallelisme \n\
1 : 1 machine, compilation avec bibliotheque de parallelisme \n\
2 : 2 processeurs ou machines en parallele etc... ',
             ang = 'NUMBER OF PROCESSORS FOR PARALLEL PROCESSING \n\
0 : 1 machine, compiling without parallel library \n\
1 : 1 machine, compiling with a parallel library \n\
2 : 2 processors or machines in parallel'),
         ), # fin b_para

)# INITIALISATION

# -----------------------------------------------------------------------
TIDE_PARAMETERS = PROC(nom = "TIDE_PARAMETERS",op = None,
# -----------------------------------------------------------------------
#    ------------------------------------
     Inputs_Outputs_For_Tide = FACT( statut = 'o',
#    ------------------------------------

#       ------------------------------------
        Harmonic_Constants_File = SIMP( statut = 'o',
#       ------------------------------------
            typ = ('Fichier', 'All Files (*)',),
            fr = 'Constantes harmoniques extraites du fichier du modele de maree',
            ang = 'Harmonic constants extracted from the tidalmodel file',),

#       ------------------------------------
        Tidal_Model_File = SIMP( statut = 'o',
#       ------------------------------------
            typ = ('Fichier', 'All Files (*)',),
            fr = 'Fichier de geometrie du modele dont sont extraites les constantes harmoniques',
            ang = 'Geometry file of the model from which harmonic constituents are extracted',),

      ), # Fin Inputs_Outputs_For_Tide

#    ------------------------------------
     Location = FACT( statut = 'o',
#    ------------------------------------
#       ------------------------------------
        Geographic_System = SIMP(statut = 'o',typ = 'TXM',
#       ------------------------------------
            into = ["Defined by user", "WGS84 longitude/latitude in real degrees", "WGS84 nothern UTM",\
                      "WGS84 southern UTM","Lambert", "Mercator",],
            defaut = "Defined by user",
            fr = 'Systeme de coordonnees geographiques dans lequel est construit le modele numerique.',
            ang = 'Geographic coordinates system in which the numerical model is built.',),

#       ------------------------------------
        b_geo_plan = BLOC(condition = "Geographic_System in ['WGS84 nothern UTM','WGS84 southern UTM','Lambert']",
#       ------------------------------------

#          ------------------------------------
           Zone_Number_In_Geographic_System = SIMP(statut = 'f',typ = 'TXM',
#          ------------------------------------
               into = [ 'Lambert 1 north', 'Lambert 2 center', 'Lambert 3 south', \
                        'Lambert 4 corsica', 'Lambert 2 extended', 'UTM zone,E.G.'],
               fr = "Numero de zone (fuseau ou type de projection) lors de l'utilisation d'une projection plane.\n \
Indiquer le systeme geographique dans lequel est construit le modele numerique avec le mot-cle SYSTEME GEOGRAPHIQUE",
               ang = 'Number of zone when using a plane projection. \n\
Indicate the geographic system in which the numerical model is built with the keyword GEOGRAPHIC SYSTEM'),
           ), # Fin b_geo_plan
       ), # Fin Location

#    ------------------------------------
     Physical_Parameters = FACT(statut = 'o',
#    ------------------------------------

#       ------------------------------------
        Tide_Generating_Force = SIMP(statut = 'o',
#       ------------------------------------
           typ = bool, defaut = False),

#       ------------------------------------
        b_Tide = BLOC(condition = "Tide_Generating_Force == True",
#       ------------------------------------
#           ------------------------------------
            Longitude_Of_Origin_Point = SIMP(typ = 'R',
#           ------------------------------------
                statut = 'o', defaut = 48.,
                fr = 'Fixe la valeur de la longitude du point origine du modele, lors de l utilisation de la force generatrice de la maree.',
                ang = 'Give the value of the longitude of the origin point of the model, when taking into account of the tide generator force.',),

#           ------------------------------------
            Tidal_Data_Base = SIMP(statut = 'o',typ = 'TXM',
#           ------------------------------------
# Soizic . Il faudrait une consigne ? avec des blocs ?
# en suspens pour JMJ
                 into = [ "JMJ", "TPXO", "Miscellaneous (LEGOS-NEA, FES20XX, PREVIMER...)",],
                 fr = 'Pour JMJ, renseigner la localisation du fichier bdd_jmj et geofin dans les mots-cles BASE DE DONNEES DE MAREE \n\
et FICHIER DU MODELE DE MAREE.  Pour TPXO, LEGOS-NEA, FES20XX et PREVIMER, l utilisateur doit telecharger les fichiers \n\
de constantes harmoniques sur internet',
                 ang = 'For JMJ, indicate the location of the files bdd_jmj and geofin with keywords TIDE DATA BASE and TIDAL MODEL FILE.\n\
For TPXO, LEGOS-NEA, FES20XX and PREVIMER, the user has to download files of harmonic constituents on the internet',),

#           ------------------------------------
            b_tpxo = BLOC(condition = "Tidal_Data_Base == 'TPXO'",
#           ------------------------------------

#              ------------------------------------
               Minor_Constituents_Inference = SIMP( statut = 'o',typ = bool,
#              ------------------------------------
                  defaut = False ,
                  fr = 'Interpolation de composantes harmoniques mineures a partir de celles lues dans les \n\
fichiers d entrees lies aux mots-cles BASE BINAIRE 1 DE DONNEES DE MAREE et BASE BINAIRE 2 DE DONNEES DE MAREE',
                  ang = 'Inference of minor constituents from the one read in input files linked to \n\
keywords BINARY DATABASE 1 FOR TIDE and BINARY DATABASE 2 FOR TIDE',),



#           ------------------------------------
              Binary_Database_1_For_Tide = SIMP( statut = 'o',
#           ------------------------------------
                typ = ('Fichier', '(All Files (*),)',),
                fr = 'Base de donnees binaire 1 tiree du fichier du modele de maree.\n\
Dans le cas des donnees satellitaires de TPXO, ce fichier correspond aux donnees de niveau d''eau, par exemple h_tpxo7.2',
                ang = 'Binary database 1 extracted from the tidal model file.\n\
In the case of the TPXO satellite altimetry model, this file should be for free surface level, for instance h_tpxo7.2',),

#           ------------------------------------
              Binary_Database_2_For_Tide = SIMP( statut = 'o',
#           ------------------------------------
                typ = ('Fichier', '(All Files (*),)',),
                fr= 'Base de donnees binaire 2 tiree du fichier du modele de maree.\n\
Dans le cas des donnees satellitaires de TPXO, ce fichier correspond aux donnees de vitesse de marrees, par exemple u_tpxo7.2',
                ang = 'Binary database 2 extracted from the tidal model file.\n\
In the case of the TPXO satellite altimetry model, this file should be for tidal velocities, for instance u_tpxo7.2' ),

            ),#fin du bloc b_tpxo
         ), # Fin du Bloc b_Tide

#       ------------------------------------
        Option_For_Tidal_Boundary_Conditions = SIMP( statut = 'o',
#       ------------------------------------
           typ = 'TXM', defaut = 'No tide',
           into = ['No tide', 'Real tide (recommended methodology)', 'Astronomical tide', \
                   'Mean spring tide', 'Mean tide', 'Mean neap tide', \
                   'Astronomical neap tide', 'Real tide (methodology before 2010)'],),

#       ------------------------------------
        b_Option_B = BLOC(condition = 'Option_For_Tidal_Boundary_Conditions!= "No tide"',
#       ------------------------------------
#           ------------------------------------
            Coefficient_To_Calibrate_Tidal_Range = SIMP(statut = 'o',
#           ------------------------------------
                typ = 'R', defaut = 1.,
                fr = 'Coefficient pour ajuster le marnage de l''onde de maree aux frontieres maritimes',
                ang = 'Coefficient to calibrate the tidal range of tidal wave at tidal open boundary conditions'),

#           ------------------------------------
            Coefficient_To_Calibrate_Tidal_Velocities = SIMP(statut = 'o',
#           ------------------------------------
                typ = 'R', defaut = 999999,
                fr = 'Coefficient pour ajuster les composantes de vitesse de l''onde de maree aux frontieres maritimes.\n\
La valeur par defaut 999999. signifie que c''est la racine carree du Coefficient_De_Calage_Du_Marnage qui est prise',
                ang = 'Coefficient to calibrate the tidal velocities of tidal wave at tidal open boundary conditions.\n\
                Default value 999999. means that the square root of Coefficient_To_Calibrate_Tidal_Range is taken'),

#           ------------------------------------
              Coefficient_To_Calibrate_Sea_Level = SIMP(statut = 'o',typ = 'R',
#           ------------------------------------
                 defaut = 0.,
                 fr = 'Coefficient pour ajuster le niveau de mer',
                 ang = 'Coefficient to calibrate the sea level'),
          ), # fin b_Option_B

       ), #fin Physical_Parameters
) # Fin TIDE_PARAMETERS

# -----------------------------------------------------------------------
BOUNDARY_CONDITIONS = PROC(nom = "BOUNDARY_CONDITIONS",op = None,
# -----------------------------------------------------------------------
            fr = 'On donne un ensemble de conditions par frontiere liquide',
            ang = 'One condition set per liquid boundary is given',
            UIinfo = { "groupes" : ( "CACHE", )},
            #UIinfo = { "groupes" : ( "iiii", )},
 # Dans l ideal il faut aller regarder selon les groupes dans le fichier med
 # en sortie il faut aller chercher le .cli qui va bien 
            #Liquid_Boundaries = FACT(statut = 'f',max = '**',
            #    Options = SIMP(statut = 'f',typ = 'I',into = ['classical boundary conditions','Thompson method based on characteristics'])
            #    Prescribed_Flowrates = SIMP(statut = 'f',typ = 'R'),
            #    Prescribed_Elevations = SIMP(statut = 'f',typ = 'R'),
            #    Prescribed_Velocity = SIMP(statut = 'f',typ = 'R'),
      # ),

# Il va falloir une "traduction dans le langage du dico"
# Il faut seulement l un des 3

#    ------------------------------------
     Liquid_Boundaries = FACT(statut = 'o',max = '**',
#    ------------------------------------
                
#        ------------------------------------
         Options = SIMP(statut = 'f',typ = 'I',
#        ------------------------------------
            into = ['Classical boundary conditions','Thompson method based on characteristics'],
            fr = 'On donne 1 entier par frontiere liquide',
            ang = 'One integer per liquid boundary is given',),

#        ------------------------------------
         Type_Condition = SIMP(statut = 'o',typ = 'TXM',
# On ajoute le type pour rendre l 'ihm plus lisible
# mais ce mot-cle n existe pas dans le dico
#        ------------------------------------
            into = ['Prescribed Flowrates', 'Prescribed Elevations', 'Prescribed Velocity'],),

#        ------------------------------------
         b_Flowrates = BLOC (condition = "Type_Condition == 'Prescribed Flowrates'",
#        ------------------------------------
#            ------------------------------------
             Prescribed_Flowrates = SIMP(statut = 'o',
#            ------------------------------------
                  typ = 'R',
                  fr = ' Valeurs des debits imposes aux frontieres liquides entrantes.\n\
Lire la partie du mode d''emploi consacree aux conditions aux limites',
                  ang = 'Values of prescribed flowrates at the inflow boundaries.\n\
The section about boundary conditions is to be read in the manual'),
             ), # fin b_Flowrates

#        ------------------------------------
         b_Elevations = BLOC (condition = "Type_Condition == 'Prescribed Elevations'",
#        ------------------------------------
#            ------------------------------------
             Prescribed_Elevations = SIMP(statut = 'o',typ = 'R',
#            ------------------------------------
                 fr = 'Valeurs des cotes imposees aux frontieres liquides entrantes.\n\
Lire la partie du mode d''emploi consacree aux conditions aux limites',
                 ang = 'Values of prescribed elevations at the inflow boundaries.\n\
The section about boundary conditions is to be read in the manual'),
             ), # fin b_Elevations

#        ------------------------------------
         b_Velocity = BLOC (condition = "Type_Condition == 'Prescribed Velocity'",
#        ------------------------------------
#            ------------------------------------
             Prescribed_Velocities = SIMP(statut = 'o',typ = 'R',
#            ------------------------------------
                 fr = 'Valeurs des vitesses imposees aux frontieres liquides entrantes.\n\
Lire la partie du mode d''emploi consacree aux conditions aux limites',
                 ang = 'Values of prescribed velocities at the liquid inflow boundaries.\n\
Refer to the section dealing with the boundary conditions'),
             ), # fin b_Velocity

       ), # fin des Liquid_Boundaries

#      ------------------------------------
       Liquid_Boundaries_File = SIMP( statut = 'f', 
#      ------------------------------------
         typ = ('Fichier', 'All Files (*)',),
         fr = 'Fichier de variations en temps des conditions aux limites.\n\
Les donnees de ce fichier seront a lire sur le canal 12.',
         ang = 'Variations in time of boundary conditions. Data of this file are read on channel 12.',
      ),
   

#PNPN Attention dans le Dico STAGE-DISCHARGE CURVES
#PNPN regarder le document de reference pour changer non programme
#      ------------------------------------
       Stage_Discharge_Curves = SIMP(statut = 'f',typ = 'TXM',
#      ------------------------------------
           into = ["No one","Z(Q)","Q(Z)"],
           fr = 'Indique si une courbe de tarage doit etre utilisee pour une frontiere',
           ang = 'Says if a discharge-elevation curve must be used for a given boundary',),

#      ------------------------------------
       b_discharge_curve = BLOC (condition = "Stage_Discharge_Curves != 'no'",
#      ------------------------------------
#            ------------------------------------
             Stage_Discharge_Curves_File = SIMP( statut = 'f', 
#            ------------------------------------
                typ = ('Fichier', 'All Files (*)',),
                fr = 'Nom du fichier contenant les courbes de tarage',
                ang = 'Name of the file containing stage-discharge curves',),
        ), # fin b_discharge_curve

#      ------------------------------------
       Elements_Masked_By_User = SIMP(statut = 'o',typ = bool,
#      ------------------------------------
           defaut = False,
           fr = 'Si oui remplir le sous-programme maskob',
           ang = 'if yes rewrite subroutine maskob',),

#      ------------------------------------
      maskob = BLOC (condition = 'Elements_Masked_By_User == True',
#      ------------------------------------
#            ------------------------------------
              Consigne = SIMP(statut = "o",homo = 'information',typ = "TXM", 
#            ------------------------------------
              defaut = "Remplir le sous-programme maskob"),
      ) # fin maskob

) # fin Boundary_Conditions

# -----------------------------------------------------------------------
NUMERICAL_PARAMETERS = PROC(nom = "NUMERICAL_PARAMETERS",op = None,
# -----------------------------------------------------------------------

        UIinfo = { "groupes" : ( "CACHE", )},
        #UIinfo = { "groupes" : ( "iiii", )},
 
#     ------------------------------------
      Equations = SIMP(statut = 'o',typ = 'TXM',
#     ------------------------------------
         into = ['Saint-Venant EF','Saint-Venant VF','Boussinesq'],
         defaut = 'Saint-Venant EF',
         fr = 'Choix des equations a resoudre',
         ang = 'Choice of equations to solve',),

#     ------------------------------------
      Treatment_Of_The_Linear_System = SIMP(statut = 'o', typ = 'TXM',
#     ------------------------------------
         into = ["Coupled", "Wave equation"],
         defaut = "Coupled",),

#     ------------------------------------
      Finite_Volume_Scheme = SIMP( statut = 'o',typ = 'TXM',
#     ------------------------------------
         into = [ "Roe scheme", "Kinetic order 1", "Kinetic order 2", "Zokagoa scheme order 1",\
                "Tchamen scheme order 1", "HLLC scheme order 1", "WAF scheme order 2"],
         defaut = "Kinetic order 1",),

#      ------------------------------------
       Solver_Definition = FACT(statut = 'o',
#      ------------------------------------

#         ------------------------------------
          Solver = SIMP(statut = 'o',typ = 'TXM',
#         ------------------------------------
             into = ["Conjugate gradient", "Conjugate residual","Conjugate gradient on a normal equation",\
                     "Minimum error", "CGSTAB", "GMRES", "Direct",],
             fr = 'Permet de choisir le solveur utilise pour la resolution de l''etape de propagation. \n\
Toutes les methodes proposees actuellement s''apparentent au Gradient Conjugue. Ce sont :\n\
  1 : gradient conjugue 2 : residu conjugue       3 : gradient conjugue sur equation normale \n\
  4 : erreur minimale   5 : gradient conjugue carre (non programme) 6 : gradient conjugue carre stabilise (cgstab)\n\
  7 : gmres (voir aussi option du solveur) 8 : direct',
             ang = 'Makes it possible to select the solver used for solving the propagation step.\n\
All the currently available methods are variations of the Conjugate Gradient method. They are as follows: \n\
1: conjugate gradient 2: conjugate residual 3: conjugate gradient on a normal equation\n\
4: minimum error 5: conjugate gradient squared (not implemented) 6: conjugate gradient squared stabilised (cgstab) \n\
7: gmres (see option for solver) 8: direct',),

#         ------------------------------------
          b_gmres = BLOC (condition = "Solver == 'GMRES'",
#         ------------------------------------
#            ------------------------------------
             Solver_Option = SIMP(statut = 'o',typ = 'I', defaut = 2, val_min = 2,val_max = 15,
#            ------------------------------------
                 fr = 'la dimension de l''espace de KRILOV',
                 ang = 'dimension of the KRYLOV space',),
          ), # fin b_gmres

#         ------------------------------------
          Solver_Accuracy = SIMP(statut = 'o',typ = 'R', defaut = 1e-4,
#         ------------------------------------
             fr = 'Precision demandee pour la resolution de l''etape de propagation (cf.  Note de principe).',
             ang = 'Required accuracy for solving the propagation step (refer to Principle note).',),

#         ------------------------------------
          Maximum_Number_Of_Iterations_For_Solver = SIMP(statut = 'o',typ = 'I', defaut = 100,
#         ------------------------------------
             fr = 'Les algorithmes utilises pour la resolution de l''etape de propagation etant iteratifs, \n\
il est necessaire de limiter le nombre d''iterations autorisees.\n\
Remarque : un maximum de 40 iterations par pas de temps semble raisonnable.',
             ang = 'Since the algorithms used for solving the propagation step are iterative, \
the allowed number of iterations should be limited.\n\
Note: a maximum number of 40 iterations per time step seems to be reasonable.',),

       ), # fin Solver

#      ------------------------------------
       Linearity = FACT(statut = 'f',
#      ------------------------------------
#          ------------------------------------
           Continuity_Correction = SIMP(typ = bool, statut = 'o',
#          ------------------------------------
             defaut = False,
             fr = 'Corrige les vitesses sur les points avec hauteur imposee ou l equation de continuite n a pas ete resolue',
             ang = 'Correction of the velocities on points with a prescribed elevation, where the continuity equation has not been solved',),

     ), # Fin Linearity

#      ------------------------------------
       Precondionning_setting = FACT(statut = 'f',
#      ------------------------------------

#         ------------------------------------
          Preconditioning = SIMP(statut = 'o',typ = 'TXM',max="**",
#         ------------------------------------
# PNPN Soizic ? Est ce que c'est une liste
# Comment fait-on  le into est faux : voir l aide
# PN Je propose qu 'on puisse faire +sieurs choix et qu on recalcule en sortie
# ou on propose des choix croisés parce que toutes les combinaisons ne sont pas possibles ?
# 
              into = [ "Diagonal", "No preconditioning", "Diagonal condensee", "Crout",  "Gauss-Seidel", ],
              defaut=("Diagonal",), homo="SansOrdreNiDoublon",
              fr='Permet de preconditionner le systeme de l etape de propagation afin d accelerer la convergence \n\
lors de sa resolution. Certains preconditionnements sont cumulables : (les diagonaux 2 ou 3 avec les autres)\n\
Pour cette raison on ne retient que les nombres premiers pour designer les preconditionnements. Si l on souhaite en cumuler\n\
plusieurs on formera le produit des options correspondantes.',
             ang='Choice of the preconditioning in the propagation step linear system that the convergence is speeded up\n\
when it is being solved.Some operations (either 2 or 3 diagonal preconditioning) can be performed concurrently with the others.\n\
Only prime numbers are therefore kept to denote the preconditioning operations. When several of them are to be performed concurrently,\n\
the product of relevant options shall be made.',
          ),
#         ------------------------------------
          C_U_Preconditioning = SIMP(typ = bool, statut = 'o', defaut=False,
#         ------------------------------------
             fr = 'Changement de variable de H en C dans le systeme lineaire final',
             ang = 'Change of variable from H to C in the final linear system'
           ),

   ),# fin Preconditionnement
     
#    ------------------------------------
     Matrix_Informations = FACT(statut = 'f',
#    ------------------------------------
#         ------------------------------------
          Matrix_Vector_Product = SIMP(statut = 'o',typ = 'TXM',
#         ------------------------------------
             into = ["Classic", "Frontal"],
             defaut='Classic',
             fr = 'attention, si frontal, il faut une numerotation speciale des points',
             ang = 'beware, with option 2, a special numbering of points is required',
          ),
#         ------------------------------------
          Matrix_Storage = SIMP(statut = 'o',typ = 'TXM',
#         ------------------------------------
             into = ["Classical EBE","Edge-based storage",],
             defaut='Edge-based storage',
          ),
     ),# fin Matrix_Informations


#    ------------------------------------
     Advection = FACT(statut = 'o',
#    ------------------------------------
 
#         ------------------------------------
          Type_Of_Advection = FACT(statut = 'o',
#         ------------------------------------

# PNPNPN recalcul
# Tres differents du dico  liste de 4
# PNPN eclaircir les choix SVP
# soizic. choix 3 et 4 et 13 et 14
#            Attention recalcul de Type_Of_Advection
#             ------------------------------------
              Advection_Of_U_And_V = SIMP(statut = 'o',typ = bool, defaut = True,
#             ------------------------------------
                  fr = 'Prise en compte ou non de la convection de U et V.',
                  ang = 'The advection of U and V is taken into account or ignored.'), 

#                 ------------------------------------
                  b_u_v = BLOC( condition = "Advection_Of_U_And_V == True",
#                  ------------------------------------
#                      ------------------------------------
                       Type_Of_Advection_U_And_V = SIMP(statut = 'o',typ = 'TXM',position = "global",
#                      ------------------------------------
                           into = ["Characteristics", "SUPG", "Conservative N-scheme",  'Conservative N-scheme',\
                           'Conservative PSI-scheme', 'Non conservative PSI scheme', 'Implicit non conservative N scheme',\
                           'Edge-based N-scheme'],
                             defaut = "Characteristics", ),

#                      ------------------------------------
                       b_upwind = BLOC(condition = "Type_Of_Advection_U_And_V == 'SUPG'",
#                      ------------------------------------
#                        ------------------------------------
                         Supg_Option_U_And_V = SIMP(statut = 'o', defaut = 'Modified SUPG', typ = 'TXM',
#                        ------------------------------------
                           into = ['No upwinding', 'Classical SUPG','Modified SUPG']),

#                          ------------------------------------
                           Upwind_Coefficients_Of_U_And_V = SIMP(statut = 'o',typ = 'R', defaut = 1.)
#                          ------------------------------------
                        ), # fin b_upwind
                  ),# fin b_u_v

#              ------------------------------------
               Advection_Of_H = SIMP(statut = 'o',typ = bool, defaut = True,
#              ------------------------------------
                      fr = 'Prise en compte ou non de la convection de H.',
                      ang = 'The advection of H is taken into account or ignored.'),

#                  ------------------------------------
                   b_h = BLOC( condition = "Advection_Of_H == True",
#                  ------------------------------------
#                      ------------------------------------
                       Type_Of_Advection_H = SIMP(statut = 'o',typ = 'TXM',position = "global",
#                      ------------------------------------
                           into = ["characteristics", "SUPG", "conservative N-scheme",  'conservative N-scheme',\
                              'conservative PSI-scheme', 'non conservative PSI scheme', 'implicit non conservative N scheme',\
                              'edge-based N-scheme'],
                           defaut = "conservative PSI-scheme",),
#                      ------------------------------------
                       b_upwind_H = BLOC(condition = "Type_Of_Advection_H == 'SUPG'",
#                      ------------------------------------
#                           ------------------------------------
                            Supg_Option_H = SIMP(statut = 'o', defaut = 'Modified SUPG', typ = 'TXM',
#                           ------------------------------------
                            into = ['No upwinding', 'Classical SUPG','Modified SUPG']),

#                          ------------------------------------
                           Upwind_Coefficients_Of_H = SIMP(statut = 'o',typ = 'R', defaut = 1.)
#                          ------------------------------------
                       ), # fin b_upwind_H
                    ),# fin b_h

#              ------------------------------------
               Advection_Of_K_And_Epsilon = SIMP(statut = 'o',typ = bool, defaut = True,
#              ------------------------------------
                    fr = 'Prise en compte ou non de la convection de Tracer.',
                    ang = 'The advection of Tracer is taken into account or ignored.'),

#                  ------------------------------------
                   b_k = BLOC( condition = "Advection_Of_K_And_Epsilon == True",
#                  ------------------------------------
#                      ------------------------------------
                       Type_Of_Advection_K_And_Epsilon = SIMP(statut = 'o',typ = 'TXM',position = "global",
#                      ------------------------------------
                           into = ["Characteristics", "SUPG", "Conservative N-scheme",  'Conservative N-scheme',\
                              'Conservative PSI-scheme', 'Non conservative PSI scheme', 'Implicit non conservative N scheme',\
                              'Edge-based N-scheme'],
                           defaut = "Characteristics",),
#                       ------------------------------------
                        b_upwind_k = BLOC(condition = "Type_Of_Advection_K_And_Epsilon == 'SUPG'",
#                       ------------------------------------
#                          ------------------------------------
                           Supg_Option_Tracers = SIMP(statut = 'o', defaut = 'Modified SUPG', typ = 'TXM',
#                          ------------------------------------
                             into = ['No upwinding', 'Classical SUPG','Modified SUPG']),

#                          ------------------------------------
                           Upwind_Coefficients_Of_K_And_Epsilon = SIMP(statut = 'o',typ = 'R', defaut = 1.)
#                          ------------------------------------
                         ),# fin b_upwind_k
                   ),# fin b_k

#              ------------------------------------
               Advection_Of_Tracers = SIMP(statut = 'o',typ = bool, defaut = True,
#              ------------------------------------
                    fr = 'Prise en compte ou non de la convection de Tracer.',
                    ang = 'The advection of Tracer is taken into account or ignored.'),

#                  ------------------------------------
                   b_tracers = BLOC( condition = "Advection_Of_Tracers == True",
#                  ------------------------------------
#                      ------------------------------------
                       Type_Of_Advection_Tracers = SIMP(statut = 'o',typ = 'TXM',position = "global",
#                      ------------------------------------
                           into = ["Characteristics", "SUPG", "Conservative N-scheme",  'Conservative N-scheme',\
                                'Conservative PSI-scheme', 'Non conservative PSI scheme', 'Implicit non conservative N scheme',\
                                'Edge-based N-scheme'],),
#                       ------------------------------------
                        b_upwind_Tracers = BLOC(condition = "Type_Of_Advection_Tracers == 'SUPG'",
#                       ------------------------------------
#                          ------------------------------------
                           Supg_Option_K_And_Epsilon = SIMP(statut = 'o', defaut = 'Modified SUPG', typ = 'TXM',
#                          ------------------------------------
                             into = ['No upwinding', 'Classical SUPG','Modified SUPG']),

#                          ------------------------------------
                           Upwind_Coefficients_Of_Tracers = SIMP(statut = 'o',typ = 'R', defaut = 1.)
#                          ------------------------------------
                        ), # fin b_upwind_Tracers
                    ), # fin b_Tracers

#              ------------------------------------
               b_max = BLOC( condition = "(Advection_Of_Tracers == True and Type_Of_Advection_Tracers == 'Edge-based N-scheme') or (Advection_Of_K_And_Epsilon == True and Type_Of_Advection_K_And_Epsilon == 'Edge-based N-scheme') or (Advection_Of_U_And_V == True and Type_Of_Advection_U_And_V == 'Edge-based N-scheme') or ( Advection_Of_H == True and Type_Of_Advection_H == 'Edge-based N-scheme')",
#              ------------------------------------
#                  ------------------------------------
                   Maximum_Number_Of_Iterations_For_Advection_Schemes = SIMP( statut = 'o',typ = 'I', defaut = 10 ,
#                  ------------------------------------
                       fr = 'Seulement pour schemes Edge-based N-scheme',
                       ang = 'Only for Edge-based N-scheme',),
                ), # fin b_max

#              ------------------------------------
               b_traitement = BLOC( condition = "(Advection_Of_Tracers == True and Type_Of_Advection_Tracers in ['Edge-based N-scheme','SUPG','Conservative N-scheme','Conservative PSI-scheme']) or (Advection_Of_K_And_Epsilon == True and Type_Of_Advection_K_And_Epsilon in ['Edge-based N-scheme','SUPG','Conservative N-scheme','Conservative PSI-scheme']) or (Advection_Of_U_And_V == True and Type_Of_Advection_U_And_V in ['Edge-based N-scheme','SUPG','Conservative N-scheme','Conservative PSI-scheme']) or ( Advection_Of_H == True and Type_Of_Advection_H in ['Edge-based N-scheme','SUPG','Conservative N-scheme','Conservative PSI-scheme'])",
#              ------------------------------------

#          ------------------------------------
           Treatment_Of_Fluxes_At_The_Boundaries = SIMP( statut = 'o',typ = 'TXM',
#          ------------------------------------
               into = ["Priority to prescribed values","Priority to fluxes"],
               fr = 'Utilise pour les schemas SUPG, PSI et N, \n\
si Priorité aux flux, on ne retrouve pas exactement les valeurs imposees des traceurs,mais le flux est correct',
             ang = 'Used so far only with the SUPG, PSI and N schemes.\n\
if Priority to fluxes, Dirichlet prescribed values are not obeyed,but the fluxes are correct',),

                ), # fin b_traitement
        ), # Fin Type_Of_Advection
 

#PNPNPN
# recalculer la liste de 4
# Attention bloc selon le type de convection
#         ------------------------------------
#          SUPG = FACT(statut = 'o',
#         ------------------------------------
#             ------------------------------------
#              Supg_Option_U_And_V = SIMP(statut = 'o', defaut = 'Modified SUPG', typ = 'TXM',
#             ------------------------------------
#                       into = ['No upwinding', 'Classical SUPG','Modified SUPG']),
#             ------------------------------------
#              Supg_Option_H = SIMP(statut = 'o', defaut = 'Modified SUPG', typ = 'TXM',
#             ------------------------------------
#                       into = ['No upwinding', 'Classical SUPG','Modified SUPG']),
#             ------------------------------------
#              Supg_Option_Tracers = SIMP(statut = 'o', defaut = 'Modified SUPG', typ = 'TXM',
#             ------------------------------------
#                       into = ['No upwinding', 'Classical SUPG','Modified SUPG']),
#             ------------------------------------
#              Supg_Option_K_And_Epsilon = SIMP(statut = 'o', defaut = 'Modified SUPG', typ = 'TXM',
#             ------------------------------------
#                       into = ['No upwinding', 'Classical SUPG','Modified SUPG']),
#            ), # Fin de SUPG

#         ------------------------------------
          Mass_Lumping_On_H = SIMP(statut = 'o',typ = 'R', defaut = 0,
#         ------------------------------------
            fr = 'TELEMAC offre la possibilite d''effectuer du mass-lumping sur H ou U.\n\
Ceci revient a ramener tout ou partie (suivant la valeur de ce coefficient) des matrices AM1 (h) ou AM2 (U) \n\
et AM3 (V) sur leur diagonale.  Cette technique permet d''accelerer le code dans des proportions tres\n\
importantes et de le rendre egalement beaucoup plus stable. Cependant les solutions obtenues se trouvent lissees.\n\
Ce parametre fixe le taux de mass-lumping effectue sur h.',
            ang = 'TELEMAC provides an opportunity to carry out mass-lumping either on C,H or on the velocity. \n\
This is equivalent to bringing the matrices AM1(h) or AM2(U) and AM3(V) wholly or partly, back onto their diagonal.\n\
Thanks to that technique, the code can be speeded up to a quite significant extent and it can also be made much \n\
more stable. The resulting solutions, however, become artificially smoothed. \n\
This parameter sets the extent of mass-lumping that is performed on h.'),

#         ------------------------------------
          Mass_Lumping_On_Velocity = SIMP(statut = 'o', typ = 'R', defaut = 0,
#         ------------------------------------
            fr = 'Fixe le taux de mass-lumping effectue sur la vitesse.',
            ang = 'Sets the amount of mass-lumping that is performed on the velocity.'),

#         ------------------------------------
          Mass_Lumping_For_Weak_Characteristics = SIMP(statut = 'o',typ = 'R',defaut = 0,
#         ------------------------------------
            fr = 'Applique a la matrice de masse',
            ang = 'To be applied to the mass matrix',),
#         ------------------------------------
          Free_Surface_Gradient_Compatibility = SIMP(statut = 'o',typ = 'R',defaut = 1.,
#         ------------------------------------
            fr = 'Des valeurs inferieures a 1 suppriment les oscillations parasites',
            ang = 'Values less than 1 suppress spurious oscillations'),

#          ------------------------------------
           Number_Of_Sub_Iterations_For_Non_Linearities = SIMP(statut = 'o',typ = 'I',
#          ------------------------------------
             defaut = 1,
             fr = 'Permet de reactualiser, pour un meme pas de temps, les champs convecteur et propagateur \n\
au cours de plusieurs sous-iterations.\n\
A la premiere sous-iteration, ces champs sont donnes par C et le champ de vitesses au pas de temps precedent.\n\
Aux iterations suivantes, ils sont pris egaux au champ de vitesse obtenu a la fin de la sous-iteration precedente. \n\
Cette technique permet d''ameliorer la prise en compte des non linearites.',
            ang = 'Used for updating, within one time step, the advection and propagation field.\n\
upon the first sub-iteration, \n\
these fields are given by C and the velocity field in the previous time step. At subsequent iterations, \n\
the results of the previous sub-iteration is used to update the advection and propagation field.\n\
The non-linearities can be taken into account through this technique.',),


     ), # fin Advection

#PNPNPN Il faut recalculer le MCSIMP Propagation
#    ------------------------------------
     Propagation = FACT(statut = 'o',
#    ------------------------------------
#         ------------------------------------
          Initial_Guess_For_H = SIMP(statut = 'o',typ = 'TXM',
#         ------------------------------------
              into = ['Zero', 'Previous', 'Extrapolation'],
              defaut = 'Previous',
              fr = 'Tir initial du solveur de l etape de propagation.  Offre la possibilite de modifier la valeur initiale de DH,\n\
accroissement de H, a chaque iteration, dans l etape de propagation en utilisant les valeurs finales de cette variable \n\
aux pas de temps precedents. Ceci peut permettre daccelerer la vitesse de convergence lors de la resolution du systeme.',
              ang = 'Initial guess for the solver in the propagation step.  Makes it possible to modify the initial value of H, \n\
upon each iteration in the propagation step, by using the ultimate values this variable had in the earlier time steps.\n\
Thus, the convergence can be speeded up when the system is being solved.',),


#         ------------------------------------
          Linearized_Propagation = SIMP(statut = 'o',typ = bool,defaut = False,
#         ------------------------------------
             fr = 'Permet de lineariser l''etape de propagation; \n\
par exemple lors de la realisation de cas tests pour lesquels on dispose d une solution analytique dans le cas linearise.',
             ang = 'Provided for linearizing the propagation step; \n\
e.g. when performing test-cases for which an analytical solution in the linearized case is available.' ),

#         ------------------------------------
          b_linear = BLOC(condition = "Linearized_Propagation == True ",
#         ------------------------------------
#             ------------------------------------
              Mean_Depth_For_Linearization = SIMP(statut = 'o',typ = 'R', defaut = 0.0, val_min = 0,
#             ------------------------------------
               fr = 'Fixe la hauteur d eau autour de laquelle s effectue la linearisation lorsque l option PROPAGATION LINEARISEE est choisie.',
               ang = 'Sets the water depth about which the linearization is made when the LINEARIZED PROPAGATION OPTION is selected.'),

#             ------------------------------------
              Initial_Guess_For_U = SIMP(statut = 'o',typ = 'TXM',
#             ------------------------------------
                into = ['Zero', 'Previous', 'Extrapolation'],
                defaut = 'Previous',
                fr = 'Tir initial du solveur de l etape de propagation.  Offre la possibilite de modifier la valeur initiale de DH,\n\
accroissement de U, a chaque iteration, dans l etape de propagation en utilisant les valeurs finales de cette variable \n\
aux pas de temps precedents. Ceci peut permettre daccelerer la vitesse de convergence lors de la resolution du systeme.',
                ang = 'Initial guess for the solver in the propagation step.  Makes it possible to modify the initial value of U, \n\
upon each iteration in the propagation step, by using the ultimate values this variable had in the earlier time steps.\n\
Thus, the convergence can be speeded up when the system is being solved.',),

          ), # fin b_linear

      ), # fin Propagation


#    ------------------------------------
     Diffusion = FACT(statut = 'o',
#    ------------------------------------

#         ------------------------------------
           Diffusion_Of_Velocity = SIMP( statut='o',typ=bool,
#         ------------------------------------
             defaut=False ,
             fr = 'Permet de decider si lon prend ou non en compte la diffusion des vitesses.',
             ang= 'Makes it possible to decide whether the diffusion of velocity (i.e. viscosity) is taken into account or not.',
          ),
#        ------------------------------------
         b_Diffu = BLOC(condition = 'Diffusion_Of_Velocity == True',
#        ------------------------------------
#            ------------------------------------
             Implicitation_For_Diffusion_Of_Velocity = SIMP(statut = 'o',typ = 'R',defaut = 0,
#            ------------------------------------
              fr = 'Fixe la valeur du coefficient d''implicitation sur les termes de diffusion des vitesses',
              ang = 'Sets the value of the implicitation coefficient for the diffusion of velocity',),

#            ------------------------------------
             Option_For_The_Diffusion_Of_Velocities = SIMP( statut='o',typ='TXM',
#            ------------------------------------
                  defaut=1 ,
                  into=['Diffusion in the form div( nu grad(U))','Diffusion in the form 1/h div ( h nu grad(U) )'],
                  fr = '1: Diffusion de la forme div( nu grad(U) )   2: Diffusion de la forme 1/h div ( h nu grad(U) )',
                  ang= '1: Diffusion in the form div( nu grad(U) )   2: Diffusion in the form 1/h div ( h nu grad(U) )',),

                ), # fin b_Diffu
     ), # fin Diffusion
#    ------------------------------------
     Discretization_Implicitation = FACT(statut = 'f',
#    ------------------------------------

#         ------------------------------------
          Discretizations_In_Space = SIMP(statut = 'o',typ = 'TXM', 
#         ------------------------------------
              into = ["Linear", "Quasi-bubble", "Quadratic"],
              defaut = "Linear",),

#         ------------------------------------
          Implicitation_For_Depth = SIMP(statut = 'o',typ = 'R',defaut = 0.55,
#         ------------------------------------
              fr = 'Fixe la valeur du coefficient d''implicitation sur C dans l''etape de propagation (cf.  Note de principe).\n\
Les valeurs inferieures a 0.5 donnent un schema instable.',
             ang = 'Sets the value of the implicitation coefficient for C (the celerity of waves) in the propagation step (refer to principle note).\n\
Values below 0.5 result in an unstable scheme.'),

#         ------------------------------------
          Implicitation_For_Velocity = SIMP(statut = 'o',typ = 'R',defaut = 0.55,
#         ------------------------------------
             fr = 'Fixe la valeur du coefficient d''implicitation sur la vitesse dans l''etape de propagation (cf.  Note de principe).\n\
Les valeurs inferieures a 0.5 donnent un schema instable.',
             ang = 'Sets the value of the implicitation coefficient for velocity in the propagation step (refer to principle note).\n\
Values below 0.5 result in an unstable condition.'),

      ), # fin Discretization_Implicitation
      

#    ------------------------------------
     Tidal=FACT(statut='f',
#    ------------------------------------
     Tidal_Flats = SIMP(statut = 'o',typ = bool,defaut = True,
#    ------------------------------------
         fr = 'permet de supprimer les tests sur les bancs decouvrants si on est certain qu''il n''y en aura pas, En cas de doute : oui',
         ang = 'When no,the specific treatments for tidal flats are by-passed. This spares time, but of course you must be sure that you have no tidal flats'),

#    ------------------------------------
     b_tidal_flats = BLOC(condition = 'Tidal_Flats == True',
#    ------------------------------------
#         ------------------------------------
          Option_For_The_Treatment_Of_Tidal_Flats = SIMP(statut = 'o',typ = 'TXM',
#         ------------------------------------
             into = ["Equations solved everywhere with correction on tidal flats", "Dry elements frozen", "1 but with porosity (defina method)",],
             defaut="Equations solved everywhere with correction on tidal flats",),

#             ------------------------------------
              b_option_tidal_flats = BLOC(condition = 'Option_For_The_Treatment_Of_Tidal_Flats == "Equations solved everywhere with correction on tidal flats"',
#             ------------------------------------
#                 ------------------------------------
                  Treatment_Of_Negative_Depths = SIMP( statut = 'o',typ = 'TXM',
#                 ------------------------------------
                     into = [ 'No treatment', 'Smoothing', 'Flux control'],
                     defaut = 'Smoothing' ,),
              ), # fin bloc b_option_tidal_flats

#         ------------------------------------
          Threshold_For_Negative_Depths = SIMP( statut = 'o',typ = 'R', defaut = 0.0 ,
#         ------------------------------------
             fr = 'En dessous du seuil, les hauteurs negatives sont lissees',
             ang = 'Below the threshold the negative depths are smoothed',),

#         ------------------------------------
          Threshold_Depth_For_Receding_Procedure = SIMP(statut = 'o',typ = 'R',defaut = 0 ,
#         ------------------------------------
              fr = 'Si > 0., declenche la procedure de ressuyage qui evite le franchissement parasite des digues mal discretisees',
             ang = 'If > 0., will trigger the receding procedure that avoids overwhelming of dykes which are too loosely discretised ',),

          
#         ------------------------------------
          H_Clipping = SIMP(statut = 'o',typ = bool,defaut = False,
#         ------------------------------------
             fr = 'Determine si on desire ou non limiter par valeur inferieure la hauteur d eau H (dans le cas des bancs decouvrants par exemple).',
             ang = 'Determines whether limiting the water depth H by a lower value desirable or not. (for instance in the case of tidal flats)\n\
This key-word may have an influence on mass conservation since the truncation of depth is equivalent to adding mass.',),

#             ------------------------------------
              b_clipping = BLOC(condition = 'H_Clipping == True',
#             ------------------------------------
#                 ------------------------------------
                  Minimum_Value_Of_Depth = SIMP( statut = 'o',typ = 'R', defaut = 0.0 ,
#                 ------------------------------------
                      fr = 'Fixe la valeur minimale de a lorsque loption CLIPPING DE H est activee.',
                      ang = 'Sets the minimum H value when option H CLIPPING is implemented. Not fully implemented.',),
              ), # fin b_clipping
    ), # fin bloc b_tidal_flats
    ), # fin bloc tidal

#    ------------------------------------
     Various = FACT(
#    ------------------------------------

#         ------------------------------------
         Newmark_Time_Integration_Coefficient = SIMP( statut = 'o',typ = 'TXM',
#         ------------------------------------
             defaut = "Euler explicite",
             into = ["Euler explicite","Order 2 in time"],),

#         ------------------------------------
          Option_For_Characteristics = SIMP( statut = 'o',typ = 'TXM',
#         ------------------------------------
            defaut = "Strong" ,
            into = ['Strong','Weak',],),

     ),# fin Various

   
)# fin NUMERICAL_PARAMETERS

# -----------------------------------------------------------------------
PHYSICAL_PARAMETERS = PROC(nom = "PHYSICAL_PARAMETERS",op = None,
# -----------------------------------------------------------------------
        UIinfo = { "groupes" : ( "CACHE", )},
#    ------------------------------------
     Friction_Setting = FACT(statut = 'o',
#    ------------------------------------
#         ------------------------------------
          Friction_Data_File = SIMP( statut = 'o',
#         ------------------------------------
               typ = ('Fichier', ';;All Files (*)'),
               fr = 'fichier de donnees pour le frottement',
               ang = 'friction data file',),

#         ------------------------------------
          Depth_In_Friction_Terms = SIMP( statut = 'o',typ = 'TXM',
#         ------------------------------------
               defaut = "Nodal" ,
               into = ("Nodal", "Average"),),

#         ------------------------------------
          Law_Of_Bottom_Friction = SIMP( statut = 'o',typ = 'TXM',
#         ------------------------------------
               defaut = 'No friction' ,
               into = ('No friction', 'Haaland', 'Chezy', 'Strickler', 'Manning', 'Nikuradse','Log law','Colebrooke_white'),
               fr = 'selectionne le type de formulation utilisee pour le calcul du frottement sur le fond.',
               ang = 'Selects the type of formulation used for the bottom friction.',),

#              ------------------------------------
               b_Law_Friction = BLOC(condition = "Law_Of_Bottom_Friction!= 'No friction'",
#              ------------------------------------
#                  ------------------------------------
                   Friction_Coefficient = SIMP( statut = 'o',typ = 'R',
#                  ------------------------------------
                         defaut = 50.0 ,
                         fr = 'Fixe la valeur du coefficient de frottement pour la formulation choisie.  \
Attention, la signification de ce chiffre varie suivant la formule choisie : \
1 : coefficient lineaire 2 : coefficient de Chezy 3 : coefficient de Strickler \
4 : coefficient de Manning 5 : hauteur de rugosite de Nikuradse',
                         ang = 'Sets the value of the friction coefficient for the selected formulation. \
It is noteworthy that the meaning of this figure changes according to the selected formula (Chezy, Strickler, etc.) : \
1 : linear coefficient 2 : Chezy coefficient 3 : Strickler coefficient 4 : Manning coefficient 5 : Nikuradse grain size',),
              ), # Fin b_Law_Friction

#              ------------------------------------
               b_Colebrooke_White = BLOC(condition = "Law_Of_Bottom_Friction == 'Colebrooke_white'",
#              ------------------------------------
#                  ------------------------------------
                   Manning_Default_Value_For_Colebrook_White_Law = SIMP( statut = 'o',typ = 'R',
#                  ------------------------------------
                       defaut = 0.02 ,
                       fr = 'valeur par defaut du manning pour la loi de frottement de  Colebrook-White ',
                       ang = 'Manning default value for the friction law of Colebrook-White ',),
               ), # Fin b_Colebrooke_White

#         ------------------------------------
          Non_Submerged_Vegetation_Friction = SIMP( statut = 'o',typ = bool,
#         ------------------------------------
              defaut = False ,
              fr = 'calcul du frottement du a la vegetation non submergee',
              ang = 'friction calculation of the non-submerged vegetation',),

#              ------------------------------------
               b_Non_Sub = BLOC(condition = ' Non_submerged_Vegetation_Friction == True',
#              ------------------------------------
#                  ------------------------------------
                   Diameter_Of_Roughness_Elements = SIMP( statut = 'o',typ = 'R',
#                  ------------------------------------
                       defaut = 0.006 ,
                       fr = 'diametre des elements de frottements',
                       ang = 'diameter of roughness element',),

#                  ------------------------------------
                   Spacing_Of_Roughness_Elements = SIMP( statut = 'o',typ = 'R',
#                  ------------------------------------
                      defaut = 0.14 ,
                      fr = 'espacement des elements de frottement',
                      ang = 'spacing of rouhness element',),
            ), # Fin b_Non_Sub

#         ------------------------------------
          Law_Of_Friction_On_Lateral_Boundaries = SIMP( statut = 'o',typ = 'TXM',
#         ------------------------------------
              defaut = "No friction" ,
              into = ("No friction", "Haaland", "Chezy", "Strickler",  "Manning", "Nikuradse", "Log law", "Colebrook-white"),
              fr = 'selectionne le type de formulation utilisee pour le calcul du frottement sur les parois laterales.',
              ang = 'Selects the type of formulation used for the friction on lateral boundaries.',),


#              ------------------------------------
               b_Fric = BLOC(condition = 'Law_Of_Friction_On_Lateral_Boundaries != "No friction"',
#              ------------------------------------

# PNPNPN soizic ?Ne faut-il pas un bloc sur Law_Of_Friction_On_Lateral_Boundaries
#                ------------------------------------
                 Roughness_Coefficient_Of_Boundaries = SIMP( statut = 'o',typ = 'R',
#                ------------------------------------
                    defaut = 100.0 ,
                    fr = 'Fixe la valeur du coefficient de frottement sur les frontieres solides avec un regime turbulent rugueux\n\
 sur les bords du domaine.  meme convention que pour le coefficient de frottement',
                     ang = 'Sets the value of the friction coefficient of the solid boundary with the bed roughness option. Same meaning than friction coefficient',),

#               ------------------------------------
                Maximum_Number_Of_Friction_Domains = SIMP( statut = 'o',typ = 'I',
#               ------------------------------------
                   defaut = 10 ,
                   fr = 'nombre maximal de zones pouvant etre definies pour le frottement. Peut etre augmente si necessaire',
                   ang = 'maximal number of zones defined for the friction.  Could be increased if needed',),
               ),

#         ------------------------------------
          Definition_Of_Zones = SIMP(typ = bool, statut = 'o', defaut = False,
#         ------------------------------------
               fr = 'Declenche l''appel a def_zones, pour donner un numero de zone a chaque point',
               ang = 'Triggers the call to def_zones to give a zone number to every point',),

#              ------------------------------------
               b_def_zone = BLOC (condition = 'Definition_Of_Zones == True',
#              ------------------------------------
#                  ------------------------------------
                   Consigne = SIMP(statut = "o",homo = 'information',typ = "TXM", defaut = "complete DEF_ZONES subroutine"),
#                  ------------------------------------
               ), # fin b_def_zone

     ), # Fin du bloc Friction
#    ------------------------------------
     Meteorology = FACT(statut = 'f',
#    ------------------------------------

#         ------------------------------------
          Wind = SIMP(statut = 'o',typ = bool,defaut = False,
#         ------------------------------------
             fr = 'Prise en compte ou non des effets du vent.',
             ang = 'Determines whether the wind effects are to be taken into account or not.'),

#         ------------------------------------
          b_Wind = BLOC(condition = "Wind == True",
#         ------------------------------------
#             ------------------------------------
              Wind_Velocity_Along_X = SIMP(statut = 'o',typ = 'R', defaut = 0.,
#             ------------------------------------
                 fr = 'Composante de la vitesse du vent suivant l''axe des x (m/s).',
                 ang = 'Wind velocity, component along x axis (m/s).',),

#             ------------------------------------
              Wind_Velocity_Along_Y = SIMP(statut = 'o',typ = 'R',defaut = 0.,
#             ------------------------------------
                 fr = 'Composante de la vitesse du vent suivant l''axe des y (m/s).',
                 ang = 'Wind velocity, component along y axis (m/s).',),

#             ------------------------------------
              Threshold_Depth_For_Wind = SIMP(statut = 'o',typ = 'R',defaut = 0.,
#             ------------------------------------
                 fr = 'Retire la force due au vent dans les petites profondeurs',
                 ang = 'Wind is not taken into account for small depths' ),

#             ------------------------------------
              Coefficient_Of_Wind_Influence = SIMP( statut = 'o',typ = 'R', defaut = 0.0 ,
#             ------------------------------------
                 fr = 'Fixe la valeur du coefficient d entrainement du vent (cf.  Note de principe).',
                 ang = 'Sets the value of the wind driving coefficient.  Refer to principle note.',),

#             ------------------------------------
              Option_For_Wind = SIMP( statut = 'o',typ = 'TXM', defaut = 0 ,
#             ------------------------------------
                 into = ["No wind","Constant in time and space","Variable in time","Variable in time and space"],
                 fr = 'donne les options pour introduire le vent',
                 ang = 'gives option for managing the wind'),

#             ------------------------------------
              file_For_wind = BLOC (condition = 'Option_For_Wind == "Variable in time" or Option_For_Wind == "Variable in time and space"',
#             ------------------------------------
#                  ------------------------------------
                   Consigne = SIMP(statut = "o",homo = 'information',typ = "TXM",
#                  ------------------------------------
                          defaut = "give formated file 3"),
              ), # fin bloc file_For_wind

#             ------------------------------------
              speed_For_wind = BLOC (condition = 'Option_For_Wind == "Constant in time and space"',
#             ------------------------------------
#                  ------------------------------------
                   Speed_And_Direction_Of_Wind = SIMP( statut = 'o', defaut = (0.0, 0.0) , 
#                  ------------------------------------
                      typ = Tuple(2),validators = VerifTypeTuple(('R','R')),
                      fr = 'Donne la vitesse et la direction (en degres de 0 a 360, 0 etant y = 0 et x = +inf) du vent',
                      ang = 'gives the speed and direction (degre (from 0 to 360), 0 given y = 0 anx x = +infinity)',),
              ), # speed_For_wind

          ), # fin b_Wind

#         ------------------------------------
          Air_Pressure = SIMP(statut = 'o',typ = bool, defaut = False,
#         ------------------------------------
                fr = 'Permet de decider si l''on prend ou non en compte l''influence d''un champ de pression.',
                ang = 'Provided to decide whether the influence of an atmosphere field is taken into account or not.'),

#         ------------------------------------
          b_air = BLOC(condition = "Air_Pressure == True",
#         ------------------------------------
#              ------------------------------------
               Value_Of_Atmospheric_Pressure = SIMP( statut = 'o',typ = 'R',
#              ------------------------------------
                  defaut = 100000.0 ,
                  fr = 'donne la valeur de la pression atmospherique lorsquelle est constante en temps et en espace',
                  ang = 'gives the value of atmospheric pressure when it is contant in time and space',),
           ), # fin b_air

#         ------------------------------------
          Rain_Or_Evaporation = SIMP(statut = 'o',typ = bool,
#         ------------------------------------
              defaut = False,
              fr  = 'Pour ajouter un apport ou une perte d''eau en surface.',
              ang = 'to add or remove water at the free surface. ',),

#         -----------------------------------
          b_Rain = BLOC(condition = "Rain_Or_Evaporation == True",
#         ------------------------------------
#              ------------------------------------
               Rain_Or_Evaporation_In_Mm_Per_Day = SIMP(statut = 'o',typ = 'I',defaut = 0.),
#              ------------------------------------
          ), # fin b_Rain

    ), # fin Meteorology

#    ------------------------------------
     Wave = FACT(statut = 'f',
#    ------------------------------------

#       ------------------------------------
        Wave_Driven_Currents = SIMP(statut = 'o',
#       ------------------------------------
            typ = bool, defaut = False,
            fr = 'Active la prise en compte des courants de houle',
            ang = 'Wave driven currents are taken into account.'),

#       ------------------------------------
        b_Wave = BLOC(condition = "Wave_Driven_Currents == True",
#       ------------------------------------
#           ------------------------------------
            Record_Number_In_Wave_File = SIMP(statut = 'o',typ = 'I', defaut = 1,
#           ------------------------------------
                fr = 'Numero d enregistrement dans le fichier des courants de houle',
                ang = 'Record number to read in the wave driven currents file'),
        ), # fin b_Wave
    ), # fin Wave



#    ------------------------------------
     Parameters_Estimation = FACT(statut = 'f',
#    ------------------------------------
#         ------------------------------------
          Parameter_Estimation = SIMP( statut = 'o',typ = 'TXM', into = ["Friction","Frottement","Steady"],
#         ------------------------------------
               fr = 'Liste des parametres a estimer', 
               ang = 'List of parameter to be estimated',),
         
#         ------------------------------------
          Identification_Method = SIMP( statut = 'o',typ = 'TXM',
#         ------------------------------------
               into = ["List of tests", "Gradient simple", "Conj gradient", "Lagrange interp."],
               defaut = 'GRadient simple',),

#         ------------------------------------
          Maximum_Number_Of_Iterations_For_Identification = SIMP(statut = 'o',typ = 'I',defaut = 20,
#         ------------------------------------
              fr = 'chaque iteration comprend au moins un calcul direct et un calcul adjoint',
              ang = 'every iteration implies at least a direct and an adjoint computation', ),

#         ------------------------------------
          Cost_Function = SIMP(statut = "f",typ = 'TXM', 
#         ------------------------------------
              defaut = 'Computed with h, u , v',
              into = ['Computed with h, u , v', 'Computed with c, u , v'],),

#         ------------------------------------
         Tolerances_For_Identification = FACT( statut = 'o',
#         ------------------------------------
# PNPNPN recalculer en liste de 4 reels 
#             ------------------------------------
              Tolerance_For_H = SIMP( statut = 'o',typ = 'R', defaut=1.E-3, 
#             ------------------------------------
                   fr  = "precision absolue sur H",
                   ang = "absolute precision on H",),
#             ------------------------------------
              Tolerance_For_U = SIMP( statut = 'o',typ = 'R', defaut=1.E-3, 
#             ------------------------------------
                   fr  = "precision absolue sur U",
                   ang = "absolute precision on U",),
#             ------------------------------------
              Tolerance_For_V = SIMP( statut = 'o',typ = 'R', defaut=1.E-3, 
#             ------------------------------------
                   fr  = "precision absolue sur V",
                   ang = "absolute precision on V",),
#             ------------------------------------
              Tolerance_For_cout = SIMP( statut = 'o',typ = 'R', defaut=1.E-4, 
#             ------------------------------------
                   fr  = "precision relative sur la fonction cout",
                   ang = "relative precision on the cost function",),
                ),# fin Tolerances_For_Identification

      ), #  fin fact Parameters_Estimation

#    ------------------------------------
     Sources = FACT( statut = 'f',
#    ------------------------------------
#    ------------------------------------
     Number_Of_Sources = SIMP( statut = 'o',typ = 'I', defaut = 0 ,),
#    ------------------------------------
# Attention a la sortie a reformatter. voir page 68 du user manuel V7

#       ------------------------------------
        sources_exists = BLOC(condition = "Number_Of_Sources!= 0",
#       ------------------------------------

#           ------------------------------------
            Sources_File = SIMP( statut = 'o',
#           ------------------------------------
                typ = ('Fichier', 'All Files (*)',),
                fr = 'Nom du fichier contenant les informations variables en temps des sources',
                ang = 'Name of the file containing time-dependent information on sources',),

#PNPNPNPN saisir autant de source que le nombre
#           ------------------------------------
            Source = FACT(statut = 'o',
#           ------------------------------------
                 max = "**",
#               ------------------------------------
                Abscissae_Of_Sources = SIMP( statut = 'o',
#               ------------------------------------
                    typ = Tuple(2),validators = VerifTypeTuple(('R','R')),
                    fr = 'Valeurs des abscisses des sources de debit et de traceur.',
                    ang = 'abscissae of sources of flowrate and/or tracer',),

#               ------------------------------------
                Ordinates_Of_Sources = SIMP( statut = 'o',
#               ------------------------------------
                   typ = Tuple(2),validators = VerifTypeTuple(('R','R')),
                   fr = 'Valeurs des ordonnees des sources de debit et de traceur.',
                   ang = 'ordinates of sources of flowrate and/or tracer',),

#               ------------------------------------
                Water_Discharge_Of_Sources = SIMP( statut = 'o',
#               ------------------------------------
                   typ = Tuple(2),validators = VerifTypeTuple(('R','R')),
                   fr = 'Valeurs des debits des sources.',
                   ang = 'values of water discharge of sources',),

#               ------------------------------------
                Velocities_Of_The_Sources_Along_X = SIMP( statut = 'f',
#               ------------------------------------
                   typ = Tuple(2),validators = VerifTypeTuple(('R','R')),
                   fr = 'Vitesses du courant a chacune des sources. Si elles ne sont pas donnees, on considere que la vitesse est celle du courant',
                   ang = 'Velocities at the sources. If they are not given, the velocity of the flow at this location is taken',),

#               ------------------------------------
                Velocities_Of_The_Sources_Along_Y = SIMP( statut = 'f',
#               ------------------------------------
                   typ = Tuple(2),validators = VerifTypeTuple(('R','R')),
                   fr = 'Vitesses du courant a chacune des sources',
                   ang = 'Velocities at the sources',),

        ), # Fin du Fact Source

#           ------------------------------------
            Type_Of_Sources = SIMP(statut = 'o',typ = 'TXM',into = ["Normal","Dirac"],
#           ------------------------------------
                   fr = 'Source portee par une base elements finis  Source portee  par une fonction de Dirac',
                   ang = 'Source term multiplied by a finite element basis,  Source term multiplied by a Dirac function',),

    ),#fin bloc source - exits
    ),#fin MC source - exits


#  ------------------------------------
   Coriolis_Settings = FACT(statut = 'f',
#  ------------------------------------
#      ------------------------------------
       Coriolis = SIMP( statut='o',typ=bool,
#      ------------------------------------
          defaut=False ,
          fr = 'Prise en compte ou non de la force de Coriolis.',
          ang= 'The Coriolis force is taken into account or ignored.',),

#     -------------------------------------------------------
      Coriolis_Coefficient = SIMP( statut='o',typ='R',
#     -------------------------------------------------------
            defaut=0.0 ,
            fr = 'Fixe la valeur du coefficient de la force de Coriolis.  Celui-ci doit etre calcule en fonction de la latitude l \n\
par la formule FCOR = 2w sin(l) , w etant la vitesse de rotation de la terre.  w = 7.27 10-5 rad/s \n\
Les composantes de la force de Coriolis sont alors : FU =   FCOR x V FV = - FCOR x U',
           ang= 'Sets the value of the Coriolis force coefficient, in cartesian coordinates.  This coefficient,\n\
denoted FCOR in the code, should be equal to 2 w sin(l)d  where w denotes the earth angular speed of rotation and l the latitude. \n\
w = 7.27 10-5 rad/sec The Coriolis force components are then: FU =  FCOR x V, FV = -FCOR x U In spherical coordinates, the latitudes are known',),
      ), #fin Coriolis_Settings



#    ------------------------------------
     Various = FACT( statut = 'f',
#    ------------------------------------
#      ------------------------------------
       Water_Density = SIMP(statut = 'o',typ = 'R',defaut = 1000.,
#      ------------------------------------
         fr = 'Fixe la valeur de la masse volumique de l eau.',
         ang = 'set the value of water density',
         ),

#       ------------------------------------
        Gravity_Acceleration = SIMP(statut = 'o',typ = 'R',defaut = 9.81,
#       ------------------------------------
        fr = 'Fixe la valeur de l acceleration de la pesanteur.',
        ang = 'Set the value of the acceleration due to gravity.',
         ),

#     ------------------------------------
      Vertical_Structures = SIMP(statut = 'o',typ = bool,defaut = False,
#     ------------------------------------
         fr = 'Prise en compte de la force de trainee de structures verticales',
         ang = 'drag forces from vertical structures are taken into account',),

#          ------------------------------------
           maskob = BLOC (condition = 'Vertical_Structures == True',
#          ------------------------------------
#              ------------------------------------
               Consigne = SIMP(statut = "o",homo = 'information',typ = "TXM",
#              ------------------------------------
               defaut = "subroutine DRAGFO must then be implemented"),
           ), # fin maskob
       ),

#    -----------------------------------------------------------------------
     Secondary_Currents_Settings = FACT( statut='f',
#    -----------------------------------------------------------------------
#    -----------------------------------------------------------------------
     Secondary_Currents = SIMP( statut='o',typ=bool,
#    -----------------------------------------------------------------------
         defaut=False ,
         fr = 'Pour prendre en compte les courants secondaires',
         ang= 'Using the parametrisation for secondary currents',
     ),

#        -----------------------------------------------------------------------
         b_currents_exists = BLOC(condition = "Secondary_Currents == True", 
#        -----------------------------------------------------------------------
#            -----------------------------------------------------------------------
             Production_Coefficient_For_Secondary_Currents = SIMP( statut='o',typ='R',
#            -----------------------------------------------------------------------
               defaut=7.071 ,
               fr = 'Une constante dans les termes de creation de Omega',
               ang= 'A constant in the production terms of Omega',),

#            -----------------------------------------------------------------------
             Dissipation_Coefficient_For_Secondary_Currents = SIMP( statut='o',typ='R',
#            -----------------------------------------------------------------------
               defaut=0.5 ,
               fr = 'Coefficient de dissipation de Omega',
               ang= 'Coefficient of dissipation term of Omega',),

         ), # fin b_currents_exists
         ), # fin Secondary_Currents_Settings

#  ------------------------------------
   Tsunami = FACT(statut = 'f',
#  ------------------------------------
#     -------------------------------------------------------
      Option_For_Tsunami_Generation = SIMP( statut='o',typ='I', defaut=0 ,
#     -------------------------------------------------------
        fr = '',
        ang= '',),

#     -------------------------------------------------------
      Physical_Characteristics_Of_The_Tsunami = SIMP( statut='o',typ='R',
#     -------------------------------------------------------
      min=10,max=10,
      defaut=(100.0, 210000.0, 75000.0, 13.6, 81.0, 41.0, 110.0, 0.0, 0.0, 3.0) ,
      fr = '',
      ang= '',),
      ), #fin Tsunami

)# fin PHYSICAL_PARAMETERS

# -----------------------------------------------------------------------
OUTPUT_FILES = PROC(nom = "OUTPUT_FILES",op = None,
# -----------------------------------------------------------------------

#  ------------------------------------
   Graphic_And_Listing_Printouts = FACT(statut = 'f',
#  ------------------------------------
#       ------------------------------------
        Variables_For_Graphic_Printouts = SIMP(statut = 'o',max = "**", typ = 'TXM',
#       ------------------------------------
                into=[ "Velocity along X axis  (m/s)", "Velocity along Y axis  (m/s)", "Wave celerity  (m/s)", "Water depth  (m)",
                      "Free surface elevation  (m)", "Bottom elevation  (m)", "Froude number  ", "Scalar flowrate of fluid  (m2/s)", 
                      "Tracer 1 etc. ", "Turbulent kinetic energy in K-Epsilon model  (J/kg)", "Dissipation of turbulent energy  (W/kg)", 
                      "Turbulent viscosity of K-Epsilon model  (m2/s)", "Flowrate along X axis  (m2/s)", "Flowrate along Y axis  (m2/s)",
                      "Scalar velocity  (m/s)", "Wind along X axis  (m/s)", "Wind along Y axis  (m/s)", "Air pressure  (Pa)", 
                      "Friction coefficient", "Drift along X  (m)", "Drift along Y  (m)", "Courant number ", "Supplementary variable N ", 
                      "Supplementary variable O ", "Supplementary variable R ", "Supplementary variable Z  ", "Maximum elevation", 
                      "Time of maximum elevation ", "Maximum velocity", "Time of maximum velocity", "Friction velocity  "],
                ),
                #homo="SansOrdreNiDoublon"),

#       ------------------------------------
        Graphic_Printout_Period = SIMP(statut = 'o', typ = 'I',defaut = 1,
#       ------------------------------------
                    fr = 'Determine la periode en nombre de pas de temps d''impression des VARIABLES POUR LES SORTIES GRAPHIQUES \n\
                         dans le FICHIER DES RESULTATS.',
                    ang = 'Determines, in number of time steps, the printout period for the VARIABLES FOR GRAPHIC PRINTOUTS in the RESULTS FILE.' ,),

#       ------------------------------------
        Number_Of_First_Time_Step_For_Graphic_Printouts = SIMP(statut = 'o', typ = 'I',defaut = 1,
#       ------------------------------------
                   fr = 'Determine le nombre de pas de temps a partir duquel debute l''ecriture des resultats dans le listing.',
                   ang = 'Determines the number of time steps after which the results are first written into the listing.'),

 
#       ------------------------------------
        Results_File = SIMP( statut = 'o', 
#       ------------------------------------
               typ = ('Fichier', 'All Files (*)',),
               fr = 'Nom du fichier dans lequel sont ecrits les resultats du calcul avec la periodicite donnee  PERIODE POUR LES SORTIES GRAPHIQUES.', 
               ang = 'Name of the file into which the computation results shall be written, the periodicity being given by  GRAPHIC PRINTOUT PERIOD.',),

#       ------------------------------------
          Results_File_Format = SIMP( statut = 'o',typ = 'TXM',into = ['Serafin','MED','SerafinD'], defaut = 'Serafin',
#       ------------------------------------
                                fr = 'Format du fichier de resultats. Les valeurs possibles sont : \n\
     - SERAFIN : format standard simple precision pour Telemac;  \n\
     - SERAFIND: format standard double precision pour Telemac; \n\
     - MED     : format MED base sur HDF5' ,
                               ang = 'Results file format. Possible values are:\n \
     - SERAFIN : classical single precision format in Telemac;\n\
     - SERAFIND: classical double precision format in Telemac; \n\
     - MED     : MED format based on HDF5' ,
                                   ),

#       ------------------------------------
        Listing_Printout_Period = SIMP(statut = 'o', typ = 'I',defaut = 1,
#       ------------------------------------
          fr = 'Determine la periode en nombre de pas de temps d''impression des variables',
          ang = 'Determines, in number of time steps, the printout period for the variables',),

#       ------------------------------------
        Listing_Printout = SIMP( statut='o',typ=bool, defaut=True ,
#       ------------------------------------
           fr = 'Sortie des resultats sur support papier.  Si on met False, le listing ne contient que lentete et la mention FIN NORMALE DU PROGRAMME : La Valeur False est  a eviter',
            ang= 'Result printout on hard copy.  When NO is selected, the listing only includes the heading and the phrase "NORMAL END OF PROGRAM" In addition, the options MASS BALANCE and VALIDATION are inhibited. Value False  Not recommended for use.',
     ),

#       ------------------------------------
        Variables_To_Be_Printed = SIMP(statut = 'o',max = "**", typ = 'TXM',
#       ------------------------------------
            into = [ "Velocity along X axis (m/s)", "Velocity along Y axis (m/s)", "Wave celerity (m/s)", "Water depth (m)",
                   "Free surface elevation (m)", "Bottom elevation (m)", "Froude number", "Scalar flowrate of fluid (m2/s)",
                   "Tracer", "Turbulent kinetic energy in K-Epsilon model (J/kg)", "Dissipation of turbulent energy (W/kg)",
                   "Turbulent viscosity of K-Epsilon model (m2/s)", "Flowrate along x axis (m2/s)", "Flowrate along y axis (m2/s)",
                   "Scalar velocity (m/s)", "Wind along x axis (m/s)", "Wind along y axis (m/s)", "Air pressure (Pa)",
                   "Friction coefficient", "Drift along x  (m)", "Drift along y  (m)", "Courant number",
                   "Supplementary variable N", "Supplementary variable O", "Supplementary variable R", "Supplementary variable Z"]
,homo="SansOrdreNiDoublon"),

   ),# fin Listing_Graphic_Printouts

#  ------------------------------------
   Formatted_Results_File = SIMP( statut = 'f',
#  ------------------------------------
        typ = ('Fichier','All Files (*)',),
        fr = 'Fichier de resultats formate mis a la disposition de l utilisateur. \
Les resultats a placer dans ce fichier seront a ecrire sur le canal 29.',
       ang = 'Formatted file of results made available to the user.  \
The results to be entered into this file shall be written on channel 29.',),


#  ------------------------------------
   Binary_Results_File = SIMP( statut = 'f', 
#  ------------------------------------
         typ = ('Fichier', ';;All Files (*)',), 
         fr = "Fichier de resultats code en binaire mis a la disposition de l'utilisateur.\n\
Les resultats a placer dans ce fichier seront a ecrire sur le canal 28.",
         ang = "Additional binary-coded result file made available to the user. \n\
The results to be entered into this file shall be written on channel 28.",),


#  ------------------------------------
   Output_Of_Initial_Conditions = SIMP(typ = bool, statut = 'o', 
#  ------------------------------------
        defaut = True,
        fr = 'Si Vrai, impression des conditions initiales dans les resultats',
        ang = 'If True, output of initial conditions in the results'),

#  ------------------------------------
   Number_Of_Private_Arrays = SIMP( statut='o',typ='I',
#  ------------------------------------
    defaut=0 ,
    fr = 'Nombre de tableaux mis a disposition de l utilisateur',
    ang= 'Number of arrays for own user programming',
     ),


#  ------------------------------------
   Information_About_Solver = SIMP(typ = bool, statut = 'f',
#  ------------------------------------
       defaut = False,
       fr = "Si vrai, Donne a chaque pas de temps le nombre d'iterations necessaires a la convergence du solveur de l'etape de propagation.",
       ang = "if True, prints the number of iterations that have been necessary to get the solution of the linear system.",),

#  ------------------------------------
   Mass_Balance = SIMP( statut='o',typ=bool,
#  ------------------------------------
       defaut=False ,
       fr = 'Determine si l on effectue ou non le bilan de masse sur le domaine.  Cette procedure calcule a chaque pas de temps : \n\
- les flux aux entrees et sorties du domaine, - le flux global a travers lensemble des parois du domaine (liquides ou solides) \n\
- l erreur relative sur la masse pour ce pas de temps.\n\
En fin de listing, on trouve l erreur relative sur la masse pour l ensemble du calcul.\n\
Il ne sagit que dun calcul indicatif car il nexiste pas dexpression compatible du debit en formulation c,u,v.',

      ang= 'Determines whether a check of the mass-balance over the domain is mader or not.\n\
This procedures computes the following at each time step: the domain inflows and outflows, the overall flow across all the boundaries,\n\
the relative error in the mass for that time step.  The relative error in the mass over the whole computation can be found at the end of the listing.',
     ),

#  ------------------------------------
  Controls = FACT( statut='f',
#  ------------------------------------
#      ------------------------------------
       Control_Sections = SIMP(statut = 'f',typ = Tuple(2),validators = VerifTypeTuple(('I','I')),
#      ------------------------------------
            fr = 'Couples de points (numeros globaux dans le maillage) entre lesquels les debits instantanes et cumules seront donnes.',
            ang = 'Couples of points (global numbers in the mesh) defining sections where the instantaneous and cumulated discharges will be given',),

#      ------------------------------------
       Printing_Cumulated_Flowrates = SIMP( statut = 'o',typ = bool, defaut = False ,
#      ------------------------------------
            fr = 'impression du flux cumule a travers les sections de controle',
            ang = 'printing the cumulated flowrates through control sections',),

#      ------------------------------------
       Compatible_Computation_Of_Fluxes = SIMP( statut = 'o',typ = bool, defaut = False ,
#      ------------------------------------
           fr = 'flux a travers les sections de controle, calcul compatible avec l impermeabilite sous forme faible',
           ang = 'flowrates through control sections, computation compatible with the weak formulation of no-flux boundary condition',),

#      ------------------------------------
       Sections_Input_File = SIMP( statut = 'f', typ = ('Fichier', 'All Files (*)'),
#      ------------------------------------
          fr = 'sections input file, partitioned',
          ang = 'sections input file, partitioned',),

#      ------------------------------------
       Sections_Output_File = SIMP( statut = 'f', typ = ('Fichier', 'All Files (*)'),
#      ------------------------------------
          fr = 'sections output file, written by the master',
          ang = 'sections output file, written by the master',),

  ),# fin controls
#  ------------------------------------
  Fourier = FACT(statut = 'f',
#  ------------------------------------
#      ------------------------------------
       Fourier_Analysis_Periods = SIMP( statut='o',
#      ------------------------------------
       max='**', typ = 'R',
       fr = 'Liste des periodes que lon veut analyser',
       ang= 'List of periods to be analysed',),

#      ------------------------------------
       Time_Range_For_Fourier_Analysis = SIMP( statut='o',
#      ------------------------------------
       typ = Tuple(2), validators = VerifTypeTuple(('R','R')),
       defaut=(0.0, 0.0) ,
       fr = 'Pour le calcul du marnage et de la phase de la maree',
       ang= 'For computing tidal range and phase of tide',
        ),

#      ------------------------------------
       List_Of_Points = SIMP( statut='o',
#      ------------------------------------
       typ = Tuple(2), validators = VerifTypeTuple(('I','I')),
       fr = 'Liste de points remarquables pour les impressions',
       ang= 'List of remarkable points for printouts',),

#      ------------------------------------
       Names_Of_Points = SIMP( statut='o',typ='TXM',
#      ------------------------------------
       min=2,max=2 ,
       fr = 'Noms des points remarquables pour les impressions',
       ang= 'Names of remarkable points for printouts',
     ),

  ),# fin fourier
) # FIN OUTPUT_FILES


# -----------------------------------------------------------------------
CONSTRUCTION_WORKS_MODELLING = PROC(nom = "CONSTRUCTION_WORKS_MODELLING",op = None,
# -----------------------------------------------------------------------

# Attention calculer le logique BREACH 

#      ------------------------------------
       Number_Of_Culverts = SIMP( statut = 'o',typ = 'I',
#      ------------------------------------
            defaut = 0 ,
            fr = 'Nombre de siphons traites comme des termes sources ou puits. Ces siphons doivent etre decrits comme des sources \
dans le fichier cas. Leurs caracteristiques sont donnees dans le fichier de donnees des siphons (voir la documentation ecrite)',
            ang = 'Number of culverts treated as source terms.  They must be described as sources in the domain\
 and their features are given in the culvert data file (see written documentation)',),
#           ------------------------------------
            culvert_exists = BLOC(condition = "Number_Of_Culverts!= 0",
#           ------------------------------------
#               ------------------------------------
                Culvert_Data_File = SIMP( statut = 'o',typ = ('Fichier', 'All Files (*)',),
#               ------------------------------------
                    fr = 'Fichier de description des siphons presents dans le modele',
                    ang = 'Description of culvert existing in the model',),
            ), # fin bloc culvert_exists

#      ------------------------------------
       Number_Of_Tubes = SIMP( statut = 'o',typ = 'I',
#      ------------------------------------
             defaut = 0 ,
             fr = 'Nombre de buses ou ponts traites comme des termes sources ou puits. Ces buses doivent etre decrits comme des sources\n\
dans le fichier cas. Leurs caracteristiques sont donnees dans le fichier de donnees des buses (voir la documentation ecrite)',
             ang = 'Number of tubes or bridges treated as source terms.  They must be described as sources in the domain \n\
and their features are given in the tubes data file (see written documentation)',), 
#          ------------------------------------
            b_Tubes = BLOC(condition = "Number_Of_Tubes!= 0",
#          ------------------------------------
#               ------------------------------------
                Tubes_Data_File = SIMP( statut = 'o',
#               ------------------------------------
                    typ = ('Fichier', 'All Files (*)',),
                    fr = 'Fichier de description des buses/ponts presents dans le modele',
                    ang = 'Description of tubes/bridges existing in the model',),
            ), # in bloc b_Tubes

#      ------------------------------------
       Number_Of_Weirs = SIMP(statut = 'o',typ = 'I',defaut = 0,
#      ------------------------------------
             fr = 'Nombre de seuils qui seront traites par des conditions aux limites. \n\
Ces seuils doivent etre decrits comme des frontieres du domaine de calcul',
             ang = 'Number of weirs that will be treated by boundary conditions.',
     ),
#          ------------------------------------
           b_Weirs = BLOC(condition = "Number_Of_Weirs!= 0",
#          ------------------------------------
#               ------------------------------------
                Weirs_Data_File = SIMP( statut = 'o',
#               ------------------------------------
                    typ = ('Fichier', 'All Files (*)',),
                    fr = 'Fichier de description des seuils presents dans le modele',
                    ang = 'Description of weirs existing in the model',),

#              ------------------------------------
               Type_Of_Weirs = SIMP( statut = 'o',typ = 'TXM',
#              ------------------------------------
                   into = ["Horizontal with same number of nodes upstream/downstream (Historical solution with bord)",
                       "General (New solution with sources points)"],
                   defaut = "Horizontal with same number of nodes upstream/downstream (Historical solution with bord)",
                   fr = 'Méthode de traitement des seuils ',
                   ang = 'Method for treatment of weirs',),
          ),# fin b_Weirs

#      ------------------------------------
      Breach = SIMP(statut = 'o',typ = bool,defaut = False,
#      ------------------------------------
         fr = 'Prise en compte de breches dans le calcul par modification altimetrique dans le maillage.',
         ang = 'Take in account some breaches during the computation by modifying the bottom level of the mesh.',),

#          ------------------------------------
           b_Breaches = BLOC (condition = 'Breach == True',
#          ------------------------------------
#              ------------------------------------
               Breaches_Data_File = SIMP( statut = 'o',typ = ('Fichier', 'All Files (*)',),
#              ------------------------------------
                   fr = 'Fichier de description des breches',
                   ang = 'Description of breaches',),
         ), # fin b_Breaches


) # Fin CONSTRUCTION_WORKS_MODELLING


# -----------------------------------------------------------------------
GENERAL_PARAMETERS = PROC(nom = "GENERAL_PARAMETERS",op = None,
# -----------------------------------------------------------------------
        UIinfo = { "groupes" : ( "CACHE", )},
#      ------------------------------------
       Location = FACT(statut = 'o',
#      ------------------------------------
#      ------------------------------------
       Origin_Coordinates = SIMP( statut='o',
#      ------------------------------------
          typ = Tuple(2),validators = VerifTypeTuple(('I','I')),defaut = (0,0),
          fr = 'Valeur en metres, utilise pour eviter les trop grands nombres, transmis dans le format Selafin mais pas d autre traitement pour l instant',
          ang= 'Value in metres, used to avoid large real numbers,  added in Selafin format, but so far no other treatment',),


#      ------------------------------------
       Spherical_Coordinates = SIMP(typ = bool,statut = 'o',defaut = False,
#      ------------------------------------
           fr = 'Choix des coordonnees spheriques pour la realisation du calcul ( pour les grands domaines de calcul).',
           ang = 'Selection of spherical coordinates to perform the computation (for large computation domains).'),

#      ------------------------------------
       b_Spher = BLOC(condition = 'Spherical_Coordinates == True',
#      ------------------------------------
#          ------------------------------------
           Latitude_Of_Origin_Point = SIMP(typ = 'R',statut = 'o',defaut = 48.,
#          ------------------------------------
               fr = 'Determine l origine utilisee pour le calcul de latitudes lorsque l on effectue un calcul en coordonnees spheriques.',
               ang = 'Determines the origin used for computing latitudes when a computation is made in spherical coordinates.this latitude\n\
is in particular used to compute the Coriolis force. In cartesian coordinates, Coriolis coefficient is considered constant.'),

#          ------------------------------------
            Spatial_Projection_Type = SIMP(statut = 'o',typ = 'TXM',
#          ------------------------------------
               into = ["Mercator","Latitude longitude"]),
       ), # fin b_Spher

#      ------------------------------------
       b_Spher_faux = BLOC(condition = 'Spherical_Coordinates == False',
#      ------------------------------------
#          ------------------------------------
           Spatial_Projection_Type = SIMP(statut = 'o',typ = 'TXM',
#          ------------------------------------
               into = ["Cartesian, not georeferenced","Mercator","Latitude longitude"],
               defaut = "Cartesian, not georeferenced",),
       ), # fin b_Spher_faux

       ), # Fin de Location
#      ------------------------------------
       Time = FACT(statut = 'o',
#      ------------------------------------
       regles = (AU_MOINS_UN('Number_Of_Time_Steps','Duration'),
                 EXCLUS('Number_Of_Time_Steps','Duration'),
               ),

#        -----------------------------------------------------------------------
         Consigne = SIMP(statut = "o",homo = 'information',typ = "TXM", 
#        -----------------------------------------------------------------------
           defaut = "Choose between Keywords 'Number_Of_Time_Steps' or 'Duration'"),

#          ------------------------------------
           Time_Step = SIMP(statut = 'o',
#          ------------------------------------
              typ = 'R', defaut = 1,
              fr = 'Definit le nombre de pas de temps effectues lors de l''execution du code.',
              ang = 'Specifies the number of time steps performed when running the code.'),

#          ------------------------------------
           Number_Of_Time_Steps = SIMP(statut = 'f',typ = 'I',
#          ------------------------------------
              fr = 'Definit le nombre de pas de temps effectues lors de l''execution du code.',
              ang = 'Specifies the number of time steps performed when running the code.'),

#          ------------------------------------
           Duration = SIMP(statut = 'f',typ = 'R',
#          ------------------------------------
              fr = 'duree de la simulation. alternative au parametre nombre de pas de temps. \n\
On en deduit le nombre de pas de temps en prenant l''entier le plus proche de (duree du calcul/pas de temps).\n\
Si le nombre de pas de temps est aussi donne, on prend la plus grande valeur',
              ang = 'duration of simulation. May be used instead of the parameter NUMBER OF TIME STEPS. \n\
The nearest integer to (duration/time step) is taken.  If NUMBER OF TIME STEPS is also given, the greater value is taken',),

# PNPN
# Attention, on laisse la règle mais il est possible d avoir les 2 en entrées --> attention au convert
#          ------------------------------------
           Variable_Time_Step = SIMP(statut = 'o',typ = bool, defaut=False,
#          ------------------------------------
              fr = 'Pas de temps variable pour avoir un nombre de courant souhaite',
              ang = 'Variable time-step to get a given Courant number'),

#          ------------------------------------
           b_var_time = BLOC(condition = "Variable_Time_Step == True" ,
#          ------------------------------------
#            ------------------------------------
             Desired_Courant_Number = SIMP(statut = 'o',typ = 'R',
#            ------------------------------------
             fr = 'Nombre de Courant souhaite ',
             ang = 'Desired Courant number',),
           ),

#          ------------------------------------
           Original_Date_Of_Time = FACT( statut = 'o',
#          ------------------------------------
              fr = "Permet de fixer la date d'origine des temps du modele lors de la prise en compte de la force generatrice de la maree.",
              ang = 'Give the date of the time origin of the model when taking into account the tide generating force.', 
               Year = SIMP(statut = 'o',typ = 'I',val_min = 1900, defaut = 1900),
               Month = SIMP(statut = 'o',typ = 'I',val_min = 1,val_max = 12,  defaut = 1),
               Day = SIMP(statut = 'o',typ = 'I',val_min = 1,val_max = 31,defaut = 1),),

#          ------------------------------------
           Original_Hour_Of_Time = FACT( statut = 'o',
#          ------------------------------------
               fr = "Permet de fixer l'heure d'origine des temps du modele lors de la prise en compte de la force generatrice de la maree.",
               ang = 'Give the time of the time origin of the model when taking into account the tide generating force.', 
               Hour = SIMP(statut = 'o',typ = 'I',val_min = 0,val_max = 24, defaut = 0),
               Minute = SIMP(statut = 'o',typ = 'I',val_min = 0,val_max = 60, defaut = 0),
               Second = SIMP(statut = 'o',typ = 'I',val_min = 0,val_max = 60, defaut = 0),
             ),

#          ------------------------------------
           Stop_If_A_Steady_State_Is_Reached = SIMP(statut = 'o',
#          ------------------------------------
               typ = bool,defaut = False),

#          ------------------------------------
           b_stop = BLOC(condition = "Stop_If_A_Steady_State_Is_Reached == True" ,
#          ------------------------------------
#              ------------------------------------
               Stop_Criteria = SIMP(statut = 'o',typ = Tuple(3),validators = VerifTypeTuple(('R','R','R')),
#              ------------------------------------
                 fr = "Criteres d'arret pour un ecoulement permanent. ces coefficients sont respectivement appliques a\n\
    1- U et V 2- H 3- T ",
                 ang = 'Stop criteria for a steady state These coefficients are applied respectively to\n\
        1- U and V 2- H 3-  T ',),
           ), # fin b_stop

#          ------------------------------------
           Control_Of_Limits = SIMP(statut = 'o',
#          ------------------------------------
               typ = bool, defaut = False,
               fr = 'Le programme s''arrete si les limites sur u,v,h ou t sont depassees',
               ang = 'The program is stopped if the limits on u,v,h, or t are trespassed',),

#          ------------------------------------
           b_limit = BLOC(condition = "Control_Of_Limit == True" ,
           Limit_Values = FACT(statut = 'o',
#            Attention : 1 seul MC ds Telemac
#          ------------------------------------
                fr = 'valeurs mini et maxi acceptables  min puis  max',
                ang = 'min and max acceptable values ',

#              ------------------------------------
               Limit_Values_H = SIMP(statut = 'o',typ = Tuple(2),
#              ------------------------------------
                    validators = VerifTypeTuple(('R','R')), defaut = (-1000,9000)),
#              ------------------------------------
               Limit_Values_U = SIMP(statut = 'o',typ = Tuple(2),
#              ------------------------------------
                    validators = VerifTypeTuple(('R','R')), defaut = (-1000,1000)),
#              ------------------------------------
               Limit_Values_V = SIMP(statut = 'o',typ = Tuple(2),
#              ------------------------------------
                    validators = VerifTypeTuple(('R','R')), defaut = (-1000,1000)),
#              ------------------------------------
               Limit_Values_T = SIMP(statut = 'o',typ = Tuple(2),
#              ------------------------------------
                    validators = VerifTypeTuple(('R','R')), defaut = (-1000,1000)),
            ),), # fin Fact et b_limit
       ), # Fin de Time

# Attention il faut recalculer en sortie : il faut 0 ou 1 et non un boolean
#  ------------------------------------
   Debugger = SIMP(typ = bool , statut = 'o', 
#  ------------------------------------
        defaut = False,
        fr= 'Pour imprimer la sequence des appels, mettre 1',
        ang = 'If 1, calls of subroutines will be printed in the listing',),

) # Fin GENERAL_PARAMETERS


# -----------------------------------------------------------------------
TURBULENCE = PROC(nom = "TURBULENCE",op = None,
# -----------------------------------------------------------------------

#    -----------------------------------------------------------------------
     Turbulence_Model = SIMP( statut = 'o',typ = 'TXM', defaut = "Constant Viscosity", 
#    -----------------------------------------------------------------------
          into = ("Constant Viscosity", "Elder", "K-Epsilon Model", "Smagorinski"),
          fr = 'Pour  Elder, il faut pas oublier d ajuster les deux valeurs du mot-cle : COEFFICIENTS ADIMENSIONNELS DE DISPERSION\n\
Pour K-Epsilon Model, ce meme parametre doit retrouver sa vraie valeur physique car elle est utilisee comme telle dans le modele de turbulence',
    ang = 'When Elder, the two values of key-word : NON-DIMENSIONAL DISPERSION COEFFICIENTS are used \n\
When K-Epsilon Model, this parameter should recover its true physical value, since it is used as such in the turbulence model.',),

#          ------------------------------------
           b_turbu_const = BLOC(condition = 'Turbulence_Model == "Constant Viscosity"',
#          ------------------------------------
#              ------------------------------------
               Velocity_Diffusivity = SIMP( statut = 'o',typ = 'R',
#              ------------------------------------
                   defaut = 1.E-6,
                   fr = 'Fixe de facon uniforme pour l ensemble du domaine la valeur du coefficient de diffusion de viscosite globale (dynamique + turbulente).\n\
Cette valeur peut avoir une influence non negligeable sur la forme et la taille des recirculations.',
                   ang = 'Sets, in an even way for the whole domain, the value of the coefficient of global (dynamic+turbulent) viscosity. \n\
this value may have a significant effect both on the shapes and sizes of recirculation zones.',),
            ), # fin b_turbu_const

#          ------------------------------------
           b_turbu_elder = BLOC(condition = 'Turbulence_Model == "Elder"',
#          ------------------------------------
#              ------------------------------------
               Non_Dimensional_Dispersion_Coefficients = SIMP (statut = 'o',
#              ------------------------------------
                   typ = Tuple(2),validators = VerifTypeTuple(('R','R')),defaut = (6.,0.6),
                   fr = 'coefficients longitudinal et transversal dans la formule de Elder.',
                   ang = 'Longitudinal and transversal coefficients in elder s formula.  Used only with turbulence model number 2',),
           ), # fin bloc b_turbu_elder

#    -----------------------------------------------------------------------
     Accuracy_Of_K = SIMP( statut = 'o',typ = 'R', defaut = 1e-09 ,
#    -----------------------------------------------------------------------
            fr = 'Fixe la precision demandee sur k pour le test d arret dans letape de diffusion et termes sources du modele k-epsilon.',
            ang = 'Sets the required accuracy for computing k in the diffusion and source terms step of the k-epsilon model.',),

#    -----------------------------------------------------------------------
     Accuracy_Of_Epsilon = SIMP( statut = 'o',typ = 'R', defaut = 1e-09 ,
#    -----------------------------------------------------------------------
            fr = 'Fixe la precision demandee sur epsilon pour le test darret dans letape de diffusion et termes sources de k et epsilon.',
            ang = 'Sets the required accuracy for computing epsilon in the diffusion and source-terms step of the k-epsilon model.',),

#    -----------------------------------------------------------------------
     Time_Step_Reduction_For_K_Epsilon_Model = SIMP( statut = 'f',typ = 'R', defaut = 1.0 ,
#    -----------------------------------------------------------------------
           fr = 'Coefficient reducteur du pas de temps pour le modele k-epsilon (qui est normalement identique a celui du systeme hydrodynamique).\n\
Utilisation deconseillee',
           ang = 'Time step reduction coefficient for k-epsilon model (which is normally same the same as that of the hydrodynamic system).\n\
Not recommended for use.',),

#    -----------------------------------------------------------------------
     Maximum_Number_Of_Iterations_For_K_And_Epsilon = SIMP( statut = 'o',typ = 'I',
#    -----------------------------------------------------------------------
           defaut = 50 ,
           fr = 'Fixe le nombre maximum diterations accepte lors de la resolution du systeme diffusion-termes sources du modele k-epsilon.',
           ang = 'Sets the maximum number of iterations that are acceptable when solving the diffusion source-terms step of the k-epsilon model.',),

#    -----------------------------------------------------------------------
     Turbulence_Model_For_Solid_Boundaries = SIMP( statut = 'o',typ = 'TXM',
#    -----------------------------------------------------------------------
           defaut = 'Rough' ,
           into = ('Smooth', 'Rough'),
           fr = 'Permet de choisir le regime de turbulence aux parois ',
           ang = 'Provided for selecting the type of friction on the walls',),

#    -----------------------------------------------------------------------
      Solver_For_K_Epsilon_Model = SIMP( statut = 'o',typ = 'TXM',
#    -----------------------------------------------------------------------
           defaut = "Conjugate gradient" ,
           into = ("Conjugate gradient", "Conjugate residuals", "Conjugate gradient on normal equation", 
                   "Minimum error", "Conjugate gradient squared", "Conjugate gradient squared stabilised (CGSTAB)",
                   "GMRES", "Direct"),
           fr = 'Permet de choisir le solveur utilise pour la resolution du systeme du modele k-epsilon',
           ang = 'Makes it possible to select the solver used for solving the system of the k-epsilon model.',),

#        -----------------------------------------------------------------------
         b_gmres = BLOC(condition = 'Solver_For_K_Epsilon_Model == "GMRES"',
#        -----------------------------------------------------------------------
#            -----------------------------------------------------------------------
             Option_For_The_Solver_For_K_Epsilon_Model = SIMP( statut = 'o',typ = 'I',
#            -----------------------------------------------------------------------
                  defaut = 2 ,val_min = 2,val_max = 15,
                  fr = 'le mot cle est la dimension de lespace de KRILOV (valeurs conseillees entre 2 et 7)',
                  ang = 'dimension of the krylov space try values between 2 and 7',),
         ), # fin bloc b_gmres

#    -----------------------------------------------------------------------
     Preconditioning_For_K_Epsilon_Model = SIMP( statut = 'o',typ = 'TXM',
#    -----------------------------------------------------------------------
         defaut = 'Diagonal' ,
         into = ("Diagonal", "No preconditioning", "Diagonal condensed", "Crout", "Diagonal and crout", "Diagonal condensed and crout"),
         fr = 'Permet de preconditionner le systeme relatif au modele k-epsilon',
         ang = 'Preconditioning of the linear system in the diffusion step of the k-epsilon model.',
     ),
#    -----------------------------------------------------------------------
     Information_About_K_Epsilon_Model = SIMP(statut = 'o',typ = bool,defaut = True,
#    -----------------------------------------------------------------------
        fr = 'Donne le nombre d iterations du solveur de l etape de diffusion et termes sources du modele k-epsilon.',
        ang = 'Gives the number of iterations of the solver in the diffusion and source terms step of the k-epsilon model.',
     ),
)# fin TURBULENCE




# -----------------------------------------------------------------------
PARTICLE_TRANSPORT = PROC(nom = "PARTICLE_TRANSPORT",op = None,
# -----------------------------------------------------------------------
#    -----------------------------------------------------------------------
      Number_Of_Drogues = SIMP(statut = 'o',typ = 'I',defaut = 0,
#    -----------------------------------------------------------------------
      fr = 'Permet d''effectuer un suivi de flotteurs',
      ang = 'Number of drogues in the computation.',),

#    -----------------------------------------------------------------------
     Algae_Transport_Model = SIMP( statut = 'o',typ = bool, defaut = False ,
#    -----------------------------------------------------------------------
          fr = 'Si oui, les flotteurs seront des algues',
          ang = 'If yes, the floats or particles will be algae',),

#        -----------------------------------------------------------------------
         algae_exists = BLOC(condition = "Algae_Transport_Model == True", 
#        -----------------------------------------------------------------------
#            -----------------------------------------------------------------------
             Algae_Type = SIMP( statut = 'o',typ = 'TXM',
#            -----------------------------------------------------------------------
                 into = ["Sphere", "Iridaea flaccida (close to ulva)", "Pelvetiopsis limitata", "Gigartina leptorhynchos"],
                 defaut = "Sphere",
                 fr = 'Type des algues. Pour sphere les algues seront modelisees comme des spheres, pour les autres choix voir Gaylord et al.(1994)',
                 ang = 'Algae type. For sphere, the algae particles will be modeled as spheres, for the other choices see Gaylord et al.(1994)',),

#            -----------------------------------------------------------------------
             Diameter_Of_Algae = SIMP( statut = 'o',typ = 'R', defaut = 0.1 ,
#            -----------------------------------------------------------------------
                 fr = 'Diametre des algues en m',
                 ang = 'Diametre of algae in m',),

#            -----------------------------------------------------------------------
             Density_Of_Algae = SIMP( statut = 'o',typ = 'R', defaut = 1050.0 ,
#            -----------------------------------------------------------------------
                 fr = 'Masse volumique des algues en kg/m3',
                 ang = 'Density of algae in kg/m3',),

#            -----------------------------------------------------------------------
             Thickness_Of_Algae = SIMP( statut = 'o',typ = 'R', defaut = 0.01 ,
#            -----------------------------------------------------------------------
                 fr = 'Epaisseur des algues en m',
                 ang = 'Thickness of algae in m',),
      ), # fin algae


#    -----------------------------------------------------------------------
     Oil_Spill_Model = SIMP( statut = 'o',typ = bool, defaut = False ,
#    -----------------------------------------------------------------------
         fr = 'pour declencher le modele de derive de nappes, dans ce cas le fichier de commandes migrhycar est necessaire',
         ang = 'will trigger the oil spill model, in this case the migrhycar steering file is needed',),

#    -----------------------------------------------------------------------
     oil_exists = BLOC(condition = "Oil_Spill_Model == True", 
#    -----------------------------------------------------------------------
#        -----------------------------------------------------------------------
         Oil_Spill_Steering_File = SIMP( statut = 'o',typ = ('Fichier', 'All Files (*)',),
#        -----------------------------------------------------------------------
             fr = 'Contient les donnees pour le modele de derive de nappes',
             ang = 'Contains data for the oil spill model',),
     ), # fin oil_exists

#    -----------------------------------------------------------------------
     drogues_exists = BLOC(condition = "Number_Of_Drogues!= 0 or Algae_Transport_Model == True or Oil_Spill_Model == True",
#    -----------------------------------------------------------------------
#        -----------------------------------------------------------------------
         Drogues_File = SIMP( statut = 'o',typ = ('Fichier', 'All Files (*)',),
#        -----------------------------------------------------------------------
             fr = 'Fichier de resultat avec les positions des flotteurs',
             ang = 'Results file with positions of drogues',),

#        -----------------------------------------------------------------------
         Printout_Period_For_Drogues = SIMP(statut = 'o',typ = 'I',defaut = 1,
#        -----------------------------------------------------------------------
              fr = 'Nombre de pas de temps entre 2 sorties de positions de flotteurs dans le fichier des resultats binaire supplementaire\n\
N affecte pas la qualite du calcul de la trajectoire',
              ang = 'Number of time steps between 2 outputs of drogues positions in the binary file',),
     ),#fin drogues ou algae


#    -----------------------------------------------------------------------
     Stochastic_Diffusion_Model = SIMP( statut = 'o',typ = 'I', defaut = 0 ,
#    -----------------------------------------------------------------------
         fr = 'Pour les particules : flotteurs, algues, hydrocarbures',
         ang = 'Meant for particles: drogues, algae, oil spills',),

#    -----------------------------------------------------------------------
     Number_Of_Lagrangian_Drifts = SIMP( statut = 'o',typ = 'I', defaut = 0 ,
#    -----------------------------------------------------------------------
         fr = 'Permet deffectuer simultanement plusieurs calculs de derives lagrangiennes initiees a des pas differents',
         ang = 'Provided for performing several computations of lagrangian drifts starting at different times.',),

#    -----------------------------------------------------------------------
     b_cons = BLOC(condition = "Number_Of_Lagrangian_Drifts != 0",
#    -----------------------------------------------------------------------
#        -----------------------------------------------------------------------
         Consigne = SIMP(statut = "o",homo = 'information',typ = "TXM", 
#        -----------------------------------------------------------------------
             defaut = "Add A and G in the VARIABLES FOR GRAPHIC PRINTOUTS key-word in POST_PROCESSING SECTION"),
    ), # fin b_cons

)# fin PARTICULE
# -----------------------------------------------------------------------
TRACERS = PROC(nom = "TRACERS",op = None,
# -----------------------------------------------------------------------

#        -----------------------------------------------------------------------
         Tracers_Setting = FACT(statut = 'o',
#        -----------------------------------------------------------------------

#        -----------------------------------------------------------------------
         Number_Of_Tracers = SIMP( statut='o',typ='I',
#        -----------------------------------------------------------------------
      defaut=0 ,
      fr = 'Definit le nombre de traceurs.',
      ang= 'Defines the number of tracers',),
#PNPNPN Recalculer Names_Of_Tracers et Initial_Values_Of_Tracers comme des listes
# pour Names_Of_Tracers = Names_Of_Tracers+Names_Of_Unit
# il faut faire un validateur (la chaine doit faire 16 caracteres evtuellement complete par des blancs)

#        ------------------------------------
         Tracer = FACT(statut = 'o', max="**",
#        ------------------------------------
#            -----------------------------------------------------------------------
              Name_Of_Tracer = SIMP( statut='o',typ='TXM',
#             -----------------------------------------------------------------------
              fr = 'Noms des traceurs en 16 caracteres',
              ang= 'Name of tracers in 32 characters',),

#            -----------------------------------------------------------------------
              Name_Of_Unit = SIMP( statut='o',typ='TXM',
#             -----------------------------------------------------------------------
              fr = 'Noms de l unité en 16 caracteres',
              ang= 'Name of unit in 16 characters',),

        b_Computation_Continued = BLOC(condition = 'Computation_Continued == True',
#PNPNPN Attention: global_jdc ne fonctionne pas bien : pas de propagation si chgt de valeur de Computation_Continued
#            -----------------------------------------------------------------------
             Initial_Values_Of_Tracers = SIMP( statut='o',
#             -----------------------------------------------------------------------
              typ = Tuple(2),validators = VerifTypeTuple(('R','R')),
              defaut=(0.0, 0.0) ,
              fr = 'Fixe la valeur initiale du traceur.',
              ang= 'Sets the initial value of the tracer.',),

           ), # fin b_Computation_Continued
#             ------------------------------------
              Boundary_Conditions = FACT( statut = 'f', 
#            ------------------------------------
#            -----------------------------------------------------------------------
                  Prescribed_Tracers_Values = SIMP( statut='o',
#            -----------------------------------------------------------------------
                   typ = Tuple(2),validators = VerifTypeTuple(('R','R')),
                   fr = 'Valeurs du traceur imposees aux frontieres liquides entrantes. Lire la partie du manuel consacree aux conditions aux limites',
                   ang= 'Tracer values prescribed at the inflow boundaries. Read the manual section dealing with the boundary conditions',),
           ), # fin Boundary_Conditions
         ), # fin tracer

#        -----------------------------------------------------------------------
         Density_Effects = SIMP( statut='o',typ=bool,
#        -----------------------------------------------------------------------
         defaut=False ,
         fr = 'prise en compte du gradient horizontal de densite le traceur est alors la salinite',
         ang= 'the horizontal gradient of density is taken into account the tracer is then the salinity',),

#        -----------------------------------------------------------------------
         b_Density_Effects = BLOC(condition = 'Density_Effects == True',
#        -----------------------------------------------------------------------
#        ------------------------------------
         Consigne = SIMP(statut = "o",homo = 'information',typ = "TXM",
#        ------------------------------------
         defaut='the first Tracer must be the salinity expressed in kg/m3'),

#        -----------------------------------------------------------------------
             Mean_Temperature = SIMP( statut='o',typ='R',
#        -----------------------------------------------------------------------
             defaut=20.0 ,
             fr = 'temperature de reference pour le calcul des effets de densite ',
             ang= 'reference temperature for density effects',),

           ), # fin b_Density_Effects

    ), # fin b_Tracers_Settings
#    -----------------------------------------------------------------------
     Solving = FACT( statut='o',
#    -----------------------------------------------------------------------
#       -----------------------------------------------------------------------
        Solver_For_Diffusion_Of_Tracers = SIMP( statut='o',typ='TXM',
#       -----------------------------------------------------------------------
               defaut='1="conjugate gradient"' ,
               into =('1="conjugate gradient"', '2="conjugate residual"', '3="conjugate gradient on a normal equation"',
                      '4="minimum error"', '5="squared conjugate gradient"', '6="cgstab"', '7="gmres "', '8="direct"'),),

#       -----------------------------------------------------------------------
        Solver_Option_For_Tracers_Diffusion = SIMP( statut='o',typ='I',
#       -----------------------------------------------------------------------
            defaut=2 ,
            fr = 'si le solveur est GMRES (7) le mot cle est la dimension de lespace de KRILOV (valeurs conseillees entre 2 et 15)',
            ang= 'WHEN GMRES (7) IS CHOSEN, DIMENSION OF THE KRYLOV SPACE TRY VALUES BETWEEN 2 AND 15',),

#       -----------------------------------------------------------------------
        Preconditioning_For_Diffusion_Of_Tracers = SIMP( statut='o',typ='TXM',
#       -----------------------------------------------------------------------
         defaut='2="diagonal"' ,
         into =('2="diagonal"', '0="no preconditioning "', '3="diagonal condensed"', '7="crout"', '14="diagonal and crout"', '21="diagonal condensed and crout"'),
    fr = 'Permet de preconditionner le systeme relatif au traceur. Memes definition et possibilites que pour le mot-cle PRECONDITIONNEMENT.',
    ang= 'Preconditioning of the linear system in the tracer diffusion step.  Same definition and possibilities as for the keyword PRECONDITIONING',
     ),
     ), # fin_Solving

#    -----------------------------------------------------------------------
     Accuracy = FACT( statut='o',
#    -----------------------------------------------------------------------
#       -----------------------------------------------------------------------
        Accuracy_For_Diffusion_Of_Tracers = SIMP( statut='o',typ='R', defaut=1e-06 ,
#       -----------------------------------------------------------------------
          fr = 'Fixe la precision demandee pour le calcul de la diffusion du traceur.',
          ang= 'Sets the required accuracy for computing the tracer diffusion.',),

#       -----------------------------------------------------------------------
        Maximum_Number_Of_Iterations_For_Diffusion_Of_Tracers = SIMP( statut='o',typ='I', defaut=60 ,
#       -----------------------------------------------------------------------
          fr = 'Limite le nombre diterations du solveur a chaque pas de temps pour le calcul de la diffusion du traceur.',
          ang= 'Limits the number of solver iterations at each time step for the diffusion of tracer.',),

     ), # fin Accuracy
#    -----------------------------------------------------------------------
     Sources = FACT( statut='o',
#       -----------------------------------------------------------------------
#        ------------------------------------
         Consigne = SIMP(statut = "o",homo = 'information',typ = "TXM",
#        ------------------------------------
             defaut = "La longueur de la liste doit etre nb de source * nb de tracers"),
#       -----------------------------------------------------------------------
        Values_Of_The_Tracers_At_The_Sources = SIMP( statut='o',typ='R', max='**' ,
#       -----------------------------------------------------------------------
            fr = 'Valeurs des traceurs a chacune des sources',
            ang= 'Values of the tracers at the sources',),
     ), # fin Sources
#    -----------------------------------------------------------------------
     Metereology = FACT( statut='o',
#    -----------------------------------------------------------------------
# en fait, c'est une liste de Tuple de 2. Il faudrait caluler la taille en fonction du Nombre de sources
#       -----------------------------------------------------------------------
        Values_Of_Tracers_In_The_Rain = SIMP( 
#       -----------------------------------------------------------------------
          statut='o',typ='R',defaut=0, max=2 , fr = '', ang= '',),
     ), # fin Metereology

#    -----------------------------------------------------------------------
     Numerical = FACT( statut='o',
#    -----------------------------------------------------------------------

#       -----------------------------------------------------------------------
        Implicitation_Coefficient_Of_Tracers = SIMP( statut='o',typ='R',
#       -----------------------------------------------------------------------
           defaut=0.6 ,
           fr = 'Fixe la valeur du coefficient dimplicitation du traceur',
           ang= 'Sets the value of the implicitation coefficient for the tracer',),

#       -----------------------------------------------------------------------
        Diffusion_Of_Tracers = SIMP( statut='o',typ=bool,
#       -----------------------------------------------------------------------
           defaut=True ,
           fr = 'Prise en compte ou non de la diffusion du traceur passif.',
           ang= 'The diffusion of the passive tracer is taken into account or ignored.',), 

#      ------------------------------------
       b_Diffusion_Of_Tracers = BLOC(condition = 'Diffusion_Of_Tracers == True',
#      ------------------------------------
#           ------------------------------------
            Coefficient_For_Diffusion_Of_Tracers = SIMP( statut='o',typ='R',
#           ------------------------------------
            defaut=1e-06 ,
            fr = 'Fixe la valeur du coefficient de diffusion du traceur.  Linfluence de ce parametre sur levolution du traceur dans le temps est importante.',
            ang= 'Sets the value of the tracer diffusivity.',),
       
#           ------------------------------------
            Option_For_The_Diffusion_Of_Tracers = SIMP( statut='o',typ='TXM',
#           ------------------------------------
            defaut='Diffusion in the form div( nu grad(T))' ,
            into=[ 'Diffusion in the form div( nu grad(T))', 'Diffusion in the form 1/h div ( h nu grad(T))',],),
       ), # fin b_Diffusion_Of_Tracers

#      ------------------------------------
       Scheme_For_Advection_Of_Tracers = SIMP( statut='o',typ='TXM',
#      ------------------------------------
           defaut="CHARACTERISTICS" ,
           into =("NO ADVECTION", "CHARACTERISTICS", "EXPLICIT + SUPG", "EXPLICIT LEO POSTMA", "EXPLICIT + MURD SCHEME N", 
               "EXPLICIT + MURD SCHEME PSI", "LEO POSTMA FOR TIDAL FLATS", "N-SCHEME FOR TIDAL FLATS"),
           fr = 'Choix du schema de convection pour les traceurs, remplace FORME DE LA CONVECTION',
           ang= 'Choice of the advection scheme for the tracers, replaces TYPE OF ADVECTION',),

#      ------------------------------------
       Scheme_Option_For_Advection_Of_Tracers = SIMP( statut='o',typ='TXM',
#      ------------------------------------
           defaut='explicit' ,
           into=['explicit','predictor-corrector for tracers'],
           fr = 'Si present remplace et a priorite sur : OPTION POUR LES CARACTERISTIQUES OPTION DE SUPG Si schema PSI : 1=explicite 2=predicteur-correcteur pour les traceurs',
           ang= 'If present replaces and has priority over: OPTION FOR CHARACTERISTICS SUPG OPTION IF PSI SCHEME: 1=explicit 2=predictor-corrector for tracers',),

#      ------------------------------------
       Mass_Lumping_On_Tracers = SIMP ( statut='o',typ='R',
#      ------------------------------------
           defaut=0,
           fr = 'Fixe le taux de mass-lumping effectue sur le traceur.',
           ang = 'Sets the amount of mass-lumping that is performed on the tracer.',),

    ), # fin Numerical
#    -----------------------------------------------------------------------
     Degradation = FACT( statut='o',
#    -----------------------------------------------------------------------

# PN Attention, il faut recalculer Law_Of_Tracers_Degradation
# et les coefficients.
# Question : pourquoi 2 et pas selon le nb de tracer
# Est ce que ce $ va sous tracer ?
#        -----------------------------------------------------------------------
         Law1_Of_Tracers_Degradation = SIMP( statut='o',typ='TXM',
#        -----------------------------------------------------------------------
            into=["NO DEGRADATION","F(T90) LAW"],
            defaut="NO DEGRADATION",
            fr = 'Prise en compte dune loi de decroissance des traceurs',
            ang= 'Take in account a law for tracers decrease',),

#        -----------------------------------------------------------------------
         b_Law1 = BLOC(condition = 'Law1_Of_Tracers_Degradation == "F(T90) LAW"',
#        -----------------------------------------------------------------------
#            -----------------------------------------------------------------------
             Coefficient_1_For_Law_Of_Tracers_Degradation = SIMP( statut='o',typ='R',
#            -----------------------------------------------------------------------
                  fr = 'Coefficient 1 de la loi de decroissance des traceurs',
                   ang= 'Coefficient 1 of law for tracers decrease',),
         ),# fin b_Law1

#        -----------------------------------------------------------------------
         Law2_Of_Tracers_Degradation = SIMP( statut='o',typ='TXM',
#        -----------------------------------------------------------------------
            into=["NO DEGRADATION","F(T90) LAW"],
            defaut="NO DEGRADATION",
            fr = 'Prise en compte dune loi de decroissance des traceurs',
            ang= 'Take in account a law for tracers decrease',),

#        -----------------------------------------------------------------------
         b_Law2 = BLOC(condition = 'Law2_Of_Tracers_Degradation == "F(T90) LAW"',
#        -----------------------------------------------------------------------
#            -----------------------------------------------------------------------
             Coefficient_2_For_Law_Of_Tracers_Degradation = SIMP( statut='o',typ='R',
#            -----------------------------------------------------------------------
                  fr = 'Coefficient 2 de la loi de decroissance des traceurs',
                   ang= 'Coefficient 2 of law for tracers decrease',),
         ),# fin b_Law2
    ), # fin Degradation

)# fin TRACERS


Ordre_Des_Commandes = ( 'INITIALIZATION', 'BOUNDARY_CONDITIONS','GENERAL_PARAMETERS', 'PHYSICAL_PARAMETERS', 'NUMERICAL_PARAMETERS',
'TURBULENCE', 'TRACERS', 'PARTICLE_TRANSPORT', 'CONSTRUCTION_WORKS_MODELLING',  'TIDE_PARAMETERS', 'OUTPUT_FILES')
