# -*- coding: utf-8 -*-

"""Definition of the data model used by the integration bench.

Warnings
--------
EFICAS will import this file as Python module with the ``__import__`` special
function so, this module must not use relative import.
"""
# TODO: Create a main object that point on the different subobjects and force its name

# EFICAS
from Accas import OPER, BLOC, FACT, SIMP, ASSD, JDC_CATA, VerifTypeTuple, Matrice  # pylint: disable=import-error
from Accas import Tuple as _Tuple  # pylint: disable=import-error
from Accas.extensions.eficas_translation import tr  # pylint: disable=import-error

# Warning: The names of these variables are defined by EFICAS
JdC = JDC_CATA(code="IB")
VERSION_CATALOGUE = "V_0"

# Define the minimum and the maximum number of elements (reflectors and fuel
# assemblies) on the core's side
NMIP_CORE_FUEL_ELTS = 1
NMAX_CORE_FUEL_ELTS = 18

# Available absorbing material type in the rod clusters
ROD_COMPOSITIONS = (
    "Black",   # Full AIC rods
    "Grey",    # Mix between AIC and steel rods
    "B4C",     # Full B4C rods
)

# Available options for the core elements rotation
ASSEMBLY_ROTATIONS = (
    ".",   # identity
    "R1",  # 90° counter-clock
    "R2",  # 180°
    "R3",  # 270° counter-clock
    "UD",  # up-down
    "LR",  # left-right
    "TR",  # transpose x/y
    "RT",  # transpose x/-y
)

class Tuple(_Tuple):
    """Organize the data into a fixed size tuple.

    Warnings
    --------
    This class respect the EFICAS conventions.
    """

    def __convert__(self, valeur):
        if len(valeur) != self.ntuple:
            return None
        return valeur


class VerifPostTreatment(VerifTypeTuple):
    """Validate the data comming from ``Scenario_data.post_processing``.

    Warnings
    --------
    This class respect the EFICAS conventions.
    """
    # pylint: disable=invalid-name
    # pylint: disable=missing-function-docstring
    # pylint: disable=no-self-use

    PHYSICS = ("Neutronics", "Thermalhydraulics", "System")
    FORMATS = ("MED", "SUM", "MIN", "MAX", "MEAN", "VALUE")

    def __init__(self):
        super().__init__(("TXM", "TXM", "TXM"))
        self.cata_info = ""

    def info(self):
        return tr(": vérifie les \ntypes dans un tuple")

    def infoErreurListe(self):
        return tr("Les types entres ne sont pas permis")

    def default(self, valeur):
        return valeur

    def isList(self):
        return 1

    def convertItem(self, valeur):
        if len(valeur) != len(self.typeDesTuples):
            raise ValueError(
                tr("%s devrait être de type  %s ") % (valeur, self.typeDesTuples))
        ok = self.verifType(valeur)
        if ok == 0:
            raise ValueError(
                tr("%s devrait être de type  %s (%d)") % (valeur, self.typeDesTuples, ok))
        if ok == -1:
            raise ValueError(
                tr("%s devrait être dans %s ") % (valeur[1], self.PHYSICS))
        if ok == -2:
            raise ValueError(
                tr("%s devrait être dans %s ") % (valeur[2], self.FORMATS))
        return valeur

    def verifItem(self, valeur):
        try:
            if len(valeur) != len(self.typeDesTuples):
                return 0
            ok = self.verifType(valeur)
            if ok != 1:
                return 0
        except:
            return 0
        return 1

    def verifType(self, valeur):
        ok = 0
        for v in valeur:
            if isinstance(v, (bytes, str)):
                ok += 1
        if ok == len(self.typeDesTuples):
            if valeur[1] not in self.PHYSICS:
                return -1
            if valeur[2] not in self.FORMATS:
                return -2
            return 1
        return 0

    def verif(self, valeur):
        if type(valeur) in (list, tuple):
            liste = list(valeur)
            for val in liste:
                if self.verifItem(val) != 1:
                    return 0
            return 1
        return 0


class _Assembly(ASSD):
    pass


class _TechnoData(ASSD):
    pass


class _RodBank(ASSD):
    pass


class _ModelData(ASSD):
    pass


class _ScenarioData(ASSD):
    pass


class _IandCFunction(ASSD):
    pass


class _Program(ASSD):
    pass


Assembly = OPER(
    nom="Assembly",
    sd_prod=_Assembly,
    fr="Description d'un élément du cœur",
    ang="Core element description",
    assembly_type=SIMP(
        fr="Type d'élément cœur (assemblage combustible ou réflecteur",
        ang="Type of the core element (fuel assembly or reflector",
        statut="o",
        typ="TXM",
        into=("UOX", "MOX", "REF")),
    description=BLOC(
        condition="assembly_type != 'REF'",
        fr="Description d'un assemblage combustible",
        ang="Fuel assembly description",
        assembly_width=SIMP(
            fr="Pas inter-assemblage dans le cœur",
            ang="Fuel assembly pitch in the core",
            unite="m",
            statut="o",
            typ="R"),
        fuel_density=SIMP(
            fr=("Ratio entre masse volumique nominale et la masse volumique "
                "théorique des pastilles combustible"),
            ang=("Ratio between the nominal density and the theoretical "
                 "density of the fuel pellets"),
            unite="g/cm3",
            statut="o",
            typ="R",
            defaut=0.95),
        radial_description=FACT(
            fr="Description radiale de l'assemblage combustible",
            ang="Fuel assembly radial description",
            statut="o",
            clad_outer_radius=SIMP(
                fr="Rayon externe de la gaine des crayons combustible",
                ang="Clad external radius of the fuel pins",
                unite="m",
                statut="o",
                typ="R"),
            guide_tube_outer_radius=SIMP(
                fr="Rayon externe des tubes guides",
                ang="Clad external radius of the guide tubes",
                unite="m",
                statut="o",
                typ="R"),
            fuel_rod_pitch=SIMP(
                fr="Pas inter-crayon dans l'assemblage",
                ang="Fuel pin pitch in the assembly",
                unite="m",
                statut="o",
                typ="R"),
            nfuel_rods=SIMP(
                fr="Nombre de crayons combustibles dans l'assemblage",
                ang="Number of fuel pins in the assembly",
                statut="o",
                typ="I")),
        axial_description=FACT(
            fr="Description axiale de l'assemblage combustible",
            ang="Fuel assembly axial description",
            statut="o",
            active_length_start=SIMP(
                fr="Altitude basse de la partie active",
                ang="Lower altitude of the active part",
                unite="m",
                statut="o",
                typ="R"),
            active_length_end=SIMP(
                fr="Altitude haute de la partie active",
                ang="Upper altitude of the active part",
                unite="m",
                statut="o",
                typ="R")),
        grids=FACT(
            fr="Description des grilles",
            ang="Grids description",
            statut="o",
            mixing=FACT(
                fr="Description des grilles de mélange",
                ang="Mixing grids description",
                statut="o",
                positions=SIMP(
                    fr="Altitude basse de la grille",
                    ang="Grid lower altitude",
                    unite="m",
                    statut="f",
                    typ="R",
                    max="**"),
                size=SIMP(
                    fr="Hauteur de la grille",
                    ang="Grid height",
                    unite="m",
                    statut="o",
                    typ="R")),
            non_mixing=FACT(
                fr="Description des grilles de maintien",
                ang="Holding grids description",
                statut="o",
                positions=SIMP(
                    fr="Altitude basse de la grille",
                    ang="Grid lower altitude",
                    unite="m",
                    statut="f",
                    typ="R",
                    max="**"),
                size=SIMP(
                    fr="Hauteur de la grille",
                    ang="Grid height",
                    unite="m",
                    statut="o",
                    typ="R")))))


# TODO: Define the names of the possible compositions (Black, Grey, B4C, Hafnium and Pyrex)
RodBank = OPER(
    nom="RodBank",
    sd_prod=_RodBank,
    fr="Description d'un groupe de grappes absorbantes",
    ang="Rod bank description",
    rod_type=SIMP(
        fr="Type de grappes absorbantes",
        ang="Type of rod clusters",
        statut="o",
        typ="TXM",
        into=("homogeneous", "heterogeneous")),
    description_HOM=BLOC(
        condition="rod_type == 'homogeneous'",
        fr="Description d'un groupe de grappes absorbantes homogènes axialement",
        ang="Axially homogeneous rod bank description",
        rod_composition=SIMP(
            fr=("Type de matériau absorbant des grappes absorbantes (Types "
                "autorisés : {})").format(
                    ", ".join(ROD_COMPOSITIONS)),
            ang=("Absorbing material type of the rod clusters (Authorized "
                 "types: {})").format(
                     ", ".join(ROD_COMPOSITIONS)),
            statut="o",
            typ="TXM",
            into=ROD_COMPOSITIONS)),
    description_HET=BLOC(
        condition="rod_type == 'heterogeneous'",
        fr="Description d'un groupe de grappes absorbantes hétérogène axialement",
        ang="Axially heterogeneous rod bank description",
        bottom_composition=SIMP(
            fr=("Type de matériau absorbant dans la partie basse des grappes "
                "absorantes (Types autorisés : {})").format(
                    ", ".join(ROD_COMPOSITIONS)),
            ang=("Absorbing material type in the lower part of the rod "
                 "clusters (Authorized types: {})").format(
                     ", ".join(ROD_COMPOSITIONS)),
            statut="o",
            typ="TXM",
            into=ROD_COMPOSITIONS),
        splitting_heigh=SIMP(
            fr=("Altitude de séparation entre la partie haute et la partie "
                "basse des grappes absorbantes"),
            ang=("Splitting height between the upper part and the lower part "
                 "of the rod clusters"),
            unite="m",
            statut="o",
            typ="R"),
        upper_composition=SIMP(
            fr=("Type de matériau absorbant dans la partie haute des grappes "
                "absorantes (Types autorisés : {})").format(
                    ", ".join(ROD_COMPOSITIONS)),
            ang=("Absorbing material type in the upper part of the rod "
                 "clusters (Authorized types: {})").format(
                     ", ".join(ROD_COMPOSITIONS)),
            statut="o",
            typ="TXM",
            into=ROD_COMPOSITIONS)),
    step_height=SIMP(
        fr="Hauteur d'un pas",
        ang="Step height",
        unite="m",
        statut="o",
        typ="R"),
    nsteps=SIMP(
        fr="Nombre de pas du groupe de grappes",
        ang="Rod bank steps number",
        statut="o",
        typ="I"))


def gen_assembly_maps():
    """Generate all the possible maps (one for each possible core size) for the
    data cointained in ``Techno_data.radial_description.assembly_map``."""
    # Build the default axes names
    xsym_list = list("ABCDEFGHJKLNPRSTUVWXYZ")
    xsym_list.reverse()
    ysym_list = ["%02d" % i for i in range(NMIP_CORE_FUEL_ELTS, NMAX_CORE_FUEL_ELTS + 1)]
    ysym_list.reverse()
    def_xaxis = {}
    def_yaxis = {}
    for i in range(NMIP_CORE_FUEL_ELTS, NMAX_CORE_FUEL_ELTS + 1):
        def_xaxis[i] = ["RW"] + xsym_list[-i:] + ["RE"]
        def_yaxis[i] = ["RS"] + ysym_list[-i:] + ["RN"]

    dico = {}
    for i in range(NMIP_CORE_FUEL_ELTS, NMAX_CORE_FUEL_ELTS):
        dico["assembly_map_%d" % i] = BLOC(
            condition="nb_assembly == %d" % i,
            fr="Description radiale du cœur",
            ang="Core radial description",
            xaxis=SIMP(
                fr="Nom des repères radiaux du cœur suivant l'axe ouest-est",
                ang="Name of core radial marks following the west-east axis",
                statut="o",
                typ="TXM",
                min=i + 2,
                max=i + 2,
                defaut=def_xaxis[i]),
            yaxis=SIMP(
                fr="Nom des repères radiaux du cœur suivant l'axe nord-sud",
                ang="Name of core radial marks following the north-south axis",
                statut="o",
                typ="TXM",
                min=i + 2,
                max=i + 2,
                defaut=def_yaxis[i]),
            assembly_map=SIMP(
                fr=("Répartition radiale des assemblages combustibles et des "
                    "réflecteurs dans le cœur"),
                ang=("Radial repartition of the fuel assemblies and the "
                     "reflectors in the core"),
                statut="o",
                typ=Matrice(
                    nbLigs=i + 2,
                    nbCols=i + 2,
                    typElt=_Assembly,
                    listeHeaders=(
                        ("RW","S","R","P","N","L","K","J","H","G","F","E","D","C","B","A","RE",),
                        ("RS","15","14","13","12","11","10","09","08","07","06","05","04","03","02","01","RN",)),  # pylint: disable=line-too-long
                    defaut=(i + 2) * [(i + 2) * ["."]],
                    coloree=True)),
            rotation_map=SIMP(
                fr="Rotation des éléments du cœur. Valeur possibles : {}".format(
                    ", ".join([repr(elt) for elt in ASSEMBLY_ROTATIONS])),
                ang="Core elements rotation. Possible values : {}".format(
                    ", ".join([repr(elt) for elt in ASSEMBLY_ROTATIONS])),
                statut="o",
                typ=Matrice(
                    nbLigs=i + 2,
                    nbCols=i + 2,
                    typElt="TXM",
                    typEltInto=ASSEMBLY_ROTATIONS,
                    coloree=True),
                defaut=(i + 2) * [(i + 2) * ["."]]),
            rod_map=SIMP(
                fr="Répartition radiale des groupes de grappes dans le cœur",
                ang="Rod banks radial repartition in the core",
                statut="o",
                typ=Matrice(
                    nbLigs=i + 2,
                    nbCols=i + 2,
                    valSup=1,
                    valMin=-1,
                    typElt="TXM",
                    listeHeaders=None,
                    coloree=True),
                defaut=(i + 2) * [(i + 2) * ["."]]),
            BU_map=SIMP(
                fr="Taux de combustion moyen des assemblages combustibles en GW.j/t",
                ang="Average burnup of the fuel assemblies in GW.d/t",
                statut="o",
                typ=Matrice(
                    nbLigs=i + 2,
                    nbCols=i + 2,
                    valSup=90000.,
                    valMin=0.,
                    typElt="R",
                    listeHeaders=None,
                    coloree=True),
                defaut=(i + 2) * [(i + 2) * ["."]]))
    return dico


Techno_data = OPER(
    nom="Techno_data",
    sd_prod=_TechnoData,
    fr="Description technologique du cœur",
    ang="Core technological description",
    technology=SIMP(
        statut="o",
        typ="TXM",
        into=("DPY", "Other")),
    assembly_list=SIMP(
        fr="Sélection des assemblages combustible",
        ang="Fuel assemblies selection",
        statut="o",
        typ=_Assembly,
        min=1,
        max="**"),
    rodbank_list=SIMP(
        fr="Sélection des groupes de grappes",
        ang="Rod banks selection",
        statut="o",
        typ=_RodBank,
        min=0,
        max="**"),
    radial_description=FACT(
        fr="Description radiale du cœur",
        ang="Radial description of the core",
        statut="o",
        nb_assembly=SIMP(
            fr="Nombre d'éléments combustible sur la tranche du cœur",
            ang="Number of fuel elements on one side of the core",
            statut="o",
            typ="I",
            into=list(range(NMIP_CORE_FUEL_ELTS, NMAX_CORE_FUEL_ELTS))),
        **(gen_assembly_maps())),
    axial_description=FACT(
        fr="Description axiale du cœur",
        ang="Axial description of the core",
        statut="o",
        lower_refl_size=SIMP(
            fr="Hauteur du réflecteur axial bas",
            ang="Height of bottom axial reflector",
            unite="m",
            statut="o",
            typ="R"),
        upper_refl_size=SIMP(
            fr="Hauteur du réflecteur axial haut",
            ang="Height of top axial reflector",
            unite="m",
            statut="o",
            typ="R")),
    nominal_power=SIMP(
        fr="Puissance thermique nominale du cœur",
        ang="Nominal thermal power of the core",
        unite="W",
        statut="o",
        typ="R"),
    Fuel_power_fraction=SIMP(
        fr="Fraction de la puissance dissipée dans le combustible",
        ang="Power fraction dissipated in the fuel",
        statut="o",
        typ="R",
        defaut=0.974),
    by_pass=SIMP(
        fr="Fraction du débit de bypass cœur",
        ang="Bypass core flow fraction",
        statut="o",
        typ="R",
        defaut=0.07),
    core_volumic_flowrate=SIMP(
        fr="Débit volumique cœur",
        ang="Core volume flowrate",
        unite="m3/h",
        statut="o",
        typ="R"))


class _AssemblyDKLibFile(ASSD):
    """Manage informations about a fuel assembly DKLib file."""


class _ReflectorDKLibFile(ASSD):
    """Manage informations about a reflector DKLib file."""


AssemblyDKLibFile = OPER(
    nom="AssemblyDKLibFile",
    sd_prod=_AssemblyDKLibFile,
    fr="Description d'un fichier DKLib assemblage combustible",
    ang="Description of a fuel assembly DKLib file",
    filename=SIMP(
        fr="Nom du fichier DKLib",
        ang="DKLib filename",
        statut="o",
        typ=("Fichier", "DKLib Files (.dklib);;DKZip Files (.dkzip);;All Files ()", "Sauvegarde")),
    pattern=SIMP(
        fr="Nom du pattern à utiliser dans le fichier DKLib",
        ang="Name of the pattern to use in the DKLib file",
        statut="o",
        typ="TXM"),
    rod_bank_names=SIMP(
        fr=("Nom de la configuration de grappe dans la DKLib pour chaque type "
            "de matériaux absorbants disponibles dans le modèle sous la forme "
            "({{{}}}, nom dans la DKLib)").format(", ".join(ROD_COMPOSITIONS)),
        ang=("Name of the rod cluster configuration in the DKLib file for any "
             "type of absorbing materials available in the model under the form "
             "({{{}}}, name in the DKLib)").format(", ".join(ROD_COMPOSITIONS)),
        statut="o",
        typ=Tuple(2),
        # TODO: Check if the first string is ROD_COMPOSITIONS
        validators=VerifTypeTuple(("TXM", "TXM")),
        max="**"))


ReflectorDKLibFile = OPER(
    nom="ReflectorDKLibFile",
    sd_prod=_ReflectorDKLibFile,
    fr="Description d'un fichier DKLib réflecteur",
    ang="Description of a reflector DKLib file",
    filename=SIMP(
        fr="Nom du fichier DKLib",
        ang="DKLib filename",
        statut="o",
        typ=("Fichier", "DKLib Files (.dklib);;DKZip Files (.dkzip);;All Files ()","Sauvegarde")),
    radial_pattern=SIMP(
        fr="Nom du pattern contenant les données du réflecteur radial",
        ang="Name of the pattern containing the radial reflector data",
        statut="o",
        typ="TXM"),
    lower_pattern=SIMP(
        fr="Nom du pattern contenant les données du réflecteur axial bas",
        ang="Name of the pattern containing the lower reflector data",
        statut="o",
        typ="TXM"),
    upper_pattern=SIMP(
        fr="Nom du pattern contenant les données du réflecteur axial haut",
        ang="Name of the pattern containing the upper reflector data",
        statut="o",
        typ="TXM"))


IandCFunction = OPER(
    nom="IandCFunction",
    sd_prod=_IandCFunction,
    fr="Description d'une fonction de régulation",
    ang="IandC function description",
    parameter=SIMP(
        fr="Paramètre cible de la regulation",
        ang="Instrumentation and control function target parameter",
        statut="o",
        typ="TXM",
        into=("Core", "Pressurizer level", "Pressurizer pressure")),
    b_core=BLOC(
        condition="parameter == 'Core'",
        steering_mode=SIMP(
            statut="o",
            typ="TXM",
            into=("A", "G", "T"),
            fr="Mode de pilotage",
            ang="Steering mode"),
        b_steer_g=BLOC(
            condition="steering_mode == 'G'",
            r_group=SIMP(
                statut="o",
                typ=_RodBank,
                max="**",
                fr="Définition du groupe R",
                ang="R group definition"),
            g1_group=SIMP(
                statut="o",
                typ=_RodBank,
                max="**",
                fr="Définition du groupe G1",
                ang="G1 group definition"),
            g2_group=SIMP(
                statut="o",
                typ=_RodBank,
                max="**",
                fr="Définition du groupe G2",
                ang="G2 group definition"),
            n1_group=SIMP(
                statut="o",
                typ=_RodBank,
                max="**",
                fr="Définition du groupe N1",
                ang="N1 group definition"),
            n2_group=SIMP(
                statut="o",
                typ=_RodBank,
                max="**",
                fr="Définition du groupe N2",
                ang="N2 group definition"),
            limit_insertion=SIMP(
                statut="o",
                typ="I",
                defaut=190,
                unite="extracted steps"),
            fr="paramètres mode G",
            ang="G steering mode parameters"),
        fr="Paramètres de la régulation coeur",
        ang="Core iandc functions parameters"))


Program = OPER(
    nom="Program",
    sd_prod=_Program,
    labels=SIMP(
        statut="o",
        typ="TXM",
        min=1,
        max="**"),
    values=SIMP(
        statut="o",
        typ=Tuple(2),
        validators=VerifTypeTuple(("R", "R")),
        max="**",
        fr="Loi de variation du paramètre sous la forme (temps, value)",
        ang="Parameter variation law in the form (time, value)"))


# TODO: Split this class in two: neutronic and thermalhydraulic)
# TODO: Or split this class in N classes (one for each code)
Model_data = OPER(
    nom="Model_data",
    sd_prod=_ModelData,
    fr="Description de la modélisation physique",
    ang="Physical modeling description",
    physics=SIMP(
        fr="Sélection de la physique du modèle",
        ang="Physic model selection",
        statut="o",
        typ="TXM",
        into=("Neutronics", "Thermalhydraulics", "IandC")),
    scale=SIMP(
        fr="Sélection de l'échelle du modèle",
        ang="Scale model selection",
        statut="o",
        typ="TXM",
        into=("system", "component", "local")),
    b_iandc=BLOC(
        condition="physics == 'IandC'",
        functions=SIMP(
            statut="o",
            typ=_IandCFunction,
            min=1,
            max="**"),
        fr="Description de la modélisation des fonctions de régulation",
        ang="Instrumentation and control modeling description"),
    b_neutro_compo=BLOC(
        condition="physics == 'Neutronics' and scale == 'component'",
        fr="Description de la modélisation neutronique à l'échelle du composant",
        ang="Neutronic modeling description at the component scale",
        code=SIMP(
            fr="Sélection du code de neutronique cœur",
            ang="Core neutronic code selection",
            statut="o",
            typ="TXM",
            into=("COCAGNE", "APOLLO3")),
        cocagne_bloc=BLOC(
            condition="code == 'COCAGNE'",
            cocagne_options=FACT(
                fr="Options de modélisations spécifiques au code COCAGNE.",
                ang="COCAGNE specific modeling options",
                statut="o",
                n_threads=SIMP(
                    fr="Nombre de threads alloués aux solveurs",
                    ang="Number of threads allocated to the solvers",
                    statut="f",
                    typ="I",
                    val_min=1),
                core_elements_vs_dklib=SIMP(
                    fr=("Association des éléments du cœur aux bibliothèques neutroniques "
                        "sous la forme (assemblage combustible, DKLib)"),
                    ang=("Association between the core elements and the neutronic libraries "
                        "in the form (fuel assembly, DKLib)"),
                    statut="o",
                    typ=Tuple(2),
                    # TODO: Check if the attribute assembly_type of the
                    #       Assembly object is 'REF' then the type of the
                    #       DKLibFile must be ReflectorDKLibFile and, if not,
                    #       the type of the DKLibFile must be AssemblyDKLibFile
                    validators=VerifTypeTuple(
                        (_Assembly, (_AssemblyDKLibFile, _ReflectorDKLibFile))),
                    max="**"))),
        # TODO: Implement the *4x4* mesh
        radial_meshing=FACT(
            fr="Maillage radial du cœur",
            ang="Core radial meshing",
            statut="o",
            flux_solver=SIMP(
                fr="Type de maillage radial du solveur de flux",
                ang="Radial mesh type for the flux solver",
                statut="o",
                typ="TXM",
                into=("subdivision", "pin-by-pin")),
            b_flux_subdivision=BLOC(
                condition="flux_solver == 'subdivision'",
                fr=("Paramètres pour les maillages radiaux de type subdivisé "
                    "pour le solveur de flux"),
                ang=("Parameters for the subdivided radial meshes types for the "
                     "flux solver"),
                flux_subdivision=SIMP(
                    fr=("Nombre de sous-divisions à appliquer à chaque maille "
                        "radiale pour le solveur de flux"),
                    ang=("Subdivision number to apply to all radial meshes for "
                         "the flux solver"),
                    statut="o",
                    typ="I")),
            feedback_solver=SIMP(
                fr="Type de maillage radial du solveur de contre-réaction",
                ang="Radial mesh type for the feedback solver",
                statut="o",
                typ="TXM",
                into=("subdivision", "pin-by-pin")),
            b_feedback_subdivision=BLOC(
                condition="feedback_solver == 'subdivision'",
                fr=("Paramètres pour les maillages radiaux de type subdivisé "
                    "pour le solveur de contre-réaction"),
                ang=("Parameters for the subdivided radial meshes types for the "
                     "feedback solver"),
                feedback_subdivision=SIMP(
                    fr=("Nombre de sous-divisions à appliquer à chaque maille "
                        "radiale pour le solveur de contre-réaction"),
                    ang=("Subdivision number to apply to all radial meshes for "
                         "the feedback solver"),
                    statut="o",
                    typ="I")))),
    b_thermo_compo=BLOC(
        condition="physics == 'Thermalhydraulics' and scale == 'component'",
        fr="Description de la modélisation thermohydraulique à l'échelle du composant",
        ang="Thermalhydraulic modeling description at the component scale",
        code=SIMP(
            fr="Sélection du code de thermohydraulique cœur",
            ang="Core thermalhydraulic code selection",
            statut="o",
            typ="TXM",
            into=("THYC", "CATHARE3", "FLICA4", "THEDI")),
        thyc_bloc=BLOC(
            condition="code == 'THYC'",
            thyc_options=FACT(
                fr="Options de modélisations spécifiques au code THYC.",
                ang="THYC specific modeling options",
                statut="o",
                n_threads=SIMP(
                    fr="Nombre de threads alloués aux solveurs",
                    ang="Number of threads allocated to the solvers",
                    statut="f",
                    typ="I",
                    val_min=1))),
        radial_meshing=FACT(
            fr="Description du maillage radial thermohydraulique à l'échelle du composant",
            ang="Thermalhydraulic radial meshing description at the component scale",
            statut="o",
            fluid=SIMP(
                fr="Méthode de maillage radial",
                ang="Radial meshing method",
                statut="o",
                typ="TXM",
                into=("subdivision", "subchannel")),
            b_fluid_subdivision=BLOC(
                condition="fluid == 'subdivision'",
                fr="Données spécifiques au maillage radial par subdivision",
                ang="Specific data for the radial meshing by subdivision",
                fluid_subdivision=SIMP(
                    fr="Nombre de mailles radiales dans les assemblages combustibles",
                    ang="Radial mesh number in the fuel assemblies",
                    statut="o",
                    typ="I")),
            pellet=SIMP(
                fr="Nombre de mailles radiales dans la pastille combustible",
                ang="Radial mesh number in the fuel pellet",
                statut="o",
                typ="I"),
            clad=SIMP(
                fr="Nombre de mailles radiales dans la gaine des crayons combustibles",
                ang="Radial mesh number in the clad of the fuel pins",
                statut="o",
                typ="I"))),
    b_thermo_sys=BLOC(
        condition="physics == 'Thermalhydraulics' and scale == 'system'",
        code_sys=SIMP(
            statut="o",
            typ="TXM",
            into=("CATHARE3",),
            defaut="CATHARE3",
            fr="Sélection du code de thermohydraulique système",
            ang="System thermalhydraulic code selection"),
        b_cathare3_sys=BLOC(
            condition="code_sys == 'CATHARE3'",
            input_type=SIMP(
                statut="o",
                typ="TXM",
                into=("file", "model_data"),
                fr="Sélection de la mise en donnée CATHARE3",
                ang="CATHARE3 input data selection"),
            b_c3_input_file=BLOC(
                condition="input_type == 'file'",
                input_file=SIMP(
                    statut='o',
                    typ=("Fichier", "CATHARE3 Input Deck (.dat);;All Files ()", "Sauvegarde"),
                    fr='Chemin vers le jeu de données CATHARE3',
                    ang='Path to CATHARE3 input deck')),
            meshing=FACT(
                statut='o',
                nb_vessel_sectors=SIMP(
                    statut="o",
                    typ="I",
                    defaut=1,
                    fr="Nombre de secteurs pour la cuve",
                    ang="Number of vessel sectors"),
                nb_core_sectors=SIMP(
                    statut="o",
                    typ="I",
                    defaut=1,
                    fr="Nombre de secteurs pour le coeur",
                    ang="Number of core sectors"))),
        fr="Description de la modélisation thermohydraulique à l'échelle système",
        ang="Thermalhydraulic modeling description at system level"),
    b_scale_compo=BLOC(
        condition="scale == 'component'",
        fr="Description de la modélisation à l'échelle du composant",
        ang="Modeling description at the component scale",
        axial_meshing=FACT(
            fr="Maillage axial du cœur",
            ang="Core axial meshing",
            statut="o",
            lower_refl=SIMP(
                fr="Nombre de mailles axiales dans le réflecteur bas",
                ang="Axial mesh number in the lower reflector",
                statut="o",
                typ="I"),
            fuel=SIMP(
                fr="Nombre de mailles axiales dans la partie active de l'assemblage combustible",
                ang="Axial mesh number in the active part of the fuel assembly",
                statut="o",
                typ="I"),
            upper_refl=SIMP(
                fr="Nombre de mailles axiales dans le réflecteur haut",
                ang="Axial mesh number in the upper reflector",
                statut="o",
                typ="I"))),
    b_scale_local=BLOC(
        condition="scale == 'local'",
        fr="Description de la modélisation à l'échelle du locale",
        ang="Modeling description at the local scale",
        mesh_file=SIMP(
            fr="Nom du fichier décrivant le maillage",
            ang="Name of the file describing the mesh",
            statut="o",
            typ="Fichier")))


Scenario_data = OPER(
    nom="Scenario_data",
    sd_prod=_ScenarioData,
    fr="Description du transitoire",
    ang="Transient description",
    toto = FACT(max='**',
    titi = FACT(
        max=2,
    initial_power=SIMP(
        fr="Puissance thermique initiale du cœur",
        ang="Initial thermal power of the core",
        statut="o",
        typ="R",
        val_min=0.,
        defaut=100.),
    ), 
    ), 
    initial_power_unit=SIMP(
        fr="Unité de la puissance thermique initiale du cœur",
        ang="Unit of the initial thermal power of the core",
        statut="o",
        typ="TXM",
        into=("% Nominal power", "W"),
        defaut="% Nominal power"),
    initial_core_inlet_temperature=SIMP(
        fr="Température initiale de l'eau à l'entrée du cœur",
        ang="Initial water temperature at the inlet of the core",
        unite="°C",
        statut="o",
        typ="R",
        val_min=0.,
        defaut=280.),
    initial_boron_concentration=SIMP(
        fr="Concentration en bore initiale",
        ang="Initial boron concentration",
        unite="ppm",
        statut="o",
        typ="R",
        val_min=0.,
        defaut=1300.),
    initial_inlet_pressure=SIMP(
        fr="Pression initiale de l'eau à l'entrée du cœur",
        ang="Initial water pressure at the inlet of the core",
        unite="bar",
        statut="o",
        typ="R",
        val_min=0.,
        defaut=160.2),
    initial_outlet_pressure=SIMP(
        fr="Pression initiale de l'eau à la sortie du cœur",
        ang="Initial water pressure at the outlet of the core",
        unite="bar",
        statut="o",
        typ="R",
        val_min=0.,
        defaut=157.2),
    initial_rod_positions=SIMP(
        fr=("Position initiale des groupes de grappes et des grappes dans le "
            "cœur sous la forme (type@nom, position) "
            "(ex. (Rodbank@RB, 62) pour le groupe de grappe RB positionné à 62 "
            "pas extraits et (Rodcluster@H08, 0) pour la grappe H08 "
            "complètement insérée)"),
        ang=("Initial position of the rod banks and the rod clusters in the "
             "core in the form (type@name, position) "
             "(e.g. (Rodbank@RB, 62) for the RB rod bank placed at 62 "
             "extracted steps and (Rodcluster@H08, 0) for the rod cluster H08 "
             "completely inserted)"),
        unite="extracted steps",
        statut="o",
        typ=Tuple(2),  # TODO: Use a triplet (type, name, position) instead of a doublet
        validators=VerifTypeTuple(("TXM", "I")),
        max="**"),
    scenario_type=SIMP(
        fr="Type de transitoire à modéliser",
        ang="Type of transient to model",
        statut="o",
        typ="TXM",
        into=("RIA", "HLO")),
    b_ria=BLOC(
        condition="scenario_type == 'RIA'",
        fr="Données du transitoire 'accident de réactivité'",
        ang="Data of the 'Reactivity-initiated Accident' transient",
        ejected_rod=SIMP(
            fr="Nom de la grappe éjectée",
            ang="Name of the ejected rod cluster",
            statut="o",
            typ="TXM"),
        rod_position_program=SIMP(
            fr="Loi d'éjection à appliquer à la grappe sous la forme (temps, position)",
            ang="Ejection law to apply to the ejected rod cluster in the form (time, position)",
            unite="s, extracted steps",
            statut="o",
            typ=Tuple(2),
            validators=VerifTypeTuple(("R", "I")),
            max="**"),
        SCRAM=SIMP(
            fr="Activation/désactivation de l'arrêt automatique du réacteur",
            ang="Activation/deactivation of automatic reactor shutdown",
            statut="o",
            typ="TXM",
            into=("YES", "NO")),
        SCRAM_option=BLOC(
            condition="SCRAM == 'YES'",
            fr="Options relatives à l'arrêt automatique du réacteur",
            ang="Options relative to the automatic reactor shutdown",
            SCRAM_power=SIMP(
                fr=("Puissance thermique du cœur déclenchant un arrêt "
                    "automatique du réacteur"),
                ang="Core thermal power triggering an automatic reactor shutdown",
                unite="MW",
                statut="o",
                typ="R"),
            complete_SCRAM_time=SIMP(
                fr="Temps de chute des grappes",
                ang="Rod cluster fall time",
                unite="s",
                statut="o",
                typ="R"))),
    b_hlo=BLOC(
        condition="scenario_type == 'HLO'",
        programs=SIMP(
            statut="f",
            max="**",
            typ=_Program),
        fr="Données du transitoire 'ilotage'",
        ang="Data of the 'house-load operation' transient"),
    post_processing=SIMP(
        # TODO: Give all the possible parameters depending of the physics
        fr=("Données de sortie du calcul sous la forme (paramètre, physique, format). "
            "'physique' peut valoir {physics!r} et 'format' peut valoir {formats!r}".format(
                physics=VerifPostTreatment.PHYSICS,
                formats=VerifPostTreatment.FORMATS)),
        ang=("Output computed data in function of time in the form (parameter, physic, format). "
             "'physic' can be {physics!r} and 'format' can be {formats!r})".format(
                physics=VerifPostTreatment.PHYSICS,
                formats=VerifPostTreatment.FORMATS)),
        statut="f",
        typ=Tuple(3),
        validators=VerifPostTreatment(),
        max="**"))
