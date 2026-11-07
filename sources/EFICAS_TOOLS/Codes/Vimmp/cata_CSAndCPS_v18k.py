from Accas import *
VERSION_CATALOGUE='VimmpV16'

class composant(ASSD):pass
class mapper(ASSD):pass
class converter(mapper):pass
class interpolator(mapper):pass
class modeleNumDuCompo(UserASSD):pass
class especeChimique(UserASSD):pass
class userParticle(UserASSDMultiple) :pass
class userAtom(userParticle) :pass
class userMolecule(userParticle) :pass
class userDiscrete(userParticle) :pass
class userDPD(userParticle) :pass

class spatialRegion(UserASSD):pass
class meshIdentifier(spatialRegion):pass
#class meshGroup(spatialRegion,UserASSDMultiple):pass
class meshGroup(UserASSDMultiple):pass
class systemGeometryId(spatialRegion):pass
class shapeIdentifier(UserASSDMultiple):pass

class simulatedTime(UserASSD):pass
class constitutiveRelation(UserASSD):pass
class interaction(UserASSD):pass
class transferId(UserASSD):pass
class fileId(transferId):pass
class memoryId(transferId):pass
class corbaId(transferId):pass

class stateVariable(UserASSDMultiple) : pass
class scalar(stateVariable):pass
class dynamicVariable(stateVariable):pass
class dynamicVariableParticle(stateVariable):pass
class wallInteractionId(UserASSD):pass


dictTypModNumModNum = {
    ('Continuum system','Particle_based')          : ('SPH' , 'Lagrangian one-fluid-particle pdf'), #TODO 'Particle_based --> Particle_based
    ('Continuum system','Field_based')             : ('FV'  , 'FEM', 'Spectral method'),
    ('Classical particle system','Particle_based') : ('MD'  , 'DPD', 'SDPD','SPH','CFD_Discrete_Particle_based'),
    ('Classical particle system','Field_based')    : ('LBM' ,),
    ('Quantum system','Particle_based')            : ('Particle method',),
    ('Quantum system','Field_based')               : ('Wave',),
}

dictCodeModeleNumerique = { 
    'Code_Saturne' : ('Lagrangian one-fluid-particle pdf', 'FV', 'CFD_Discrete_Particle_based',),
    'Fluent'       : ('FV',),
    'Culgi Package': (),
    'DEM_SD'       : ('Lagrangian one-fluid-particle pdf', 'FV', 'CFD_Discrete_Particle_based',),
    'DFTB+'        : ('density functional tight binding method',),
    'DL_MESO_DPD'  : ('Lagrangian one-fluid-particle pdf', 'FV', 'CFD_Discrete_Particle_based',),
    'DL_MESO_LBE'  : ('Lagrangian one-fluid-particle pdf', 'FV', 'CFD_Discrete_Particle_based',),
    'DL_POLY_4'    : ('Lagrangian one-fluid-particle pdf', 'FV', 'CFD_Discrete_Particle_based',),
    'GROMACS'      : ('Lagrangian one-fluid-particle pdf', 'FV', 'CFD_Discrete_Particle_based',),
    'GROMACS_LS'   : ('Lagrangian one-fluid-particle pdf', 'FV', 'CFD_Discrete_Particle_based',),
    'LAMMPS'       : ('Lagrangian one-fluid-particle pdf', 'FV', 'CFD_Discrete_Particle_based', 'DPD',),
    'NWChem'       : ('Lagrangian one-fluid-particle pdf', 'FV', 'CFD_Discrete_Particle_based',),
    'OpenFOAM'     : ('Lagrangian one-fluid-particle pdf', 'FV', 'CFD_Discrete_Particle_based',),
    'Quantum EXPRESSO'   : ('Particle method', 'Wave',),
    'RHEO_AGGRATE' : ('Particle method', 'Wave',),
    'RHEO_DROP'    : ('Particle method', 'Wave',),
    'STAR_CCM+'    : ('FV', 'Particles',),
    'Code Nill'    : ('Spectral method', ),
}
# Le Code Nill est ajouté en dur au Solver

dictCodeFormat =    {
    'Code_Saturne' : ('Med', 'cgns', 'msh', 'des', 'unv',  ),
    'Culgi Package': ('cof',),
    'DEM_SD'       : ('geo', 'ascii'),
    'DFTB+'        : ('geo', 'ascii'),
    'Fluent'       : ('FluentFormat', ),
    'OpenFOAM'     : ('OpenFoamFormat', 'Med', ),
}

listeFormatGenerique =['Med', 'Cgns', 'msh','geo', 'ascii' ]

dictInterpolatorFormat =    {
    'Med Coupling' : ('Med',),
}
dictConvertorFormat =    {
    'Gmsh'         : ('Med', 'OpenFoamFormat'),
}

dictTermeLE = {
    ('Fields','Particles') : ('Fluid_Velocity_Field', 
                              'Fluid_Temperature_Field', 
			      'Fluid_Species_Mass_Fraction_Fluid',),
    ('Particles','Fields') : ('Fluid_Particle_Momentum_Exchange_Field', 
                              'Fluid_Particle_Thermal_Exchange_Field', 
                              'Lagrangian one-particle pdfFluid_Particle_Mass_Source_Field', 
                              'Particle_Volumetric_Concentration_Modified_Fluid_Viscosity',
                              'Particle_Extra_Stress_Tensor'),
    ('Particles','Particles') : ('Pas encore fait'),
    ('Fields','Fields') : ('Pas encore fait'),
}

dictCodeConvertisseur = {
    ('Saturne', 'OpenFOAM') : ('gmsh', 'Saturne2CDM  and CDM2OpenFoam'),
    ('Saturne', 'Fluent')   : ('Saturne2CDM and CDM2Fluent'),
    ('Fluent', 'OpenFOAM')  : ('Fluent2CDM and CDM2OpenFoam'),
}

listeFormatGenerique =['Med', 'Cgns', 'Gmsh', ]

#----------------------------------------
def prepareBlocSystemType(systemType) :
#----------------------------------------
    condition   = "SystemType == '" + systemType + "'"
    Identifier  = SIMP(statut='o', typ=(modeleNumDuCompo,'createObject'),ang='Provide a name to identify the numerical model within the CDM')
    SimulatedTimeLapse = SIMP(statut ='o', typ = simulatedTime,ang='Define the timelapse to be simulated. \n Requires TemporalAspects to be defined in order to choose one.')
    ChoiceOfApproach  = SIMP(statut='o', typ='TXM', into=['Field_based', 'Particle_based'], position='inGetAttribut',ang='Choose the approach to be used.\n Current choice includes Field-based and Particle-based approaches.')

    dicoArgs={}
    dicoComment_NumericalMethod={}
    dicoComment_NumericalMethod['Field_based'] = 'Choose the type of Field-Based approach. \nCurrent choice includes Lattice-Boltzmann Method (LBM)'
    dicoComment_NumericalMethod['Particle_based'] = 'Choose the type of Particle-Based approach. \nCurrent choice includes Molecular Dynamics (MD), (Smoothed) Dissipative Particle Dynamics (DPD or SDPD), Smoothed Particle Hydrodynamics (SPH), CFD particle tracking.'

    for typeMod in ('Field_based', 'Particle_based'):
        conditionType   = "ChoiceOfApproach == '" + typeMod + "'" 
        NumericalMethod = SIMP(statut='o',typ='TXM', into=dictTypModNumModNum[systemType, typeMod], 
                               position='global', intoXSD=allValueInDict(dictTypModNumModNum),ang=dicoComment_NumericalMethod[typeMod])
        dicoBloc = {}
        for modeleNumerique in list(dictTypModNumModNum[systemType,typeMod]):
            conditionNum = "NumericalMethod == '" + modeleNumerique + "'"
            setCode = set()
            for code in dictCodeModeleNumerique.keys():
                if modeleNumerique in dictCodeModeleNumerique[code]: setCode.add(code)
            # print('------------- conditionType                            -------->',conditionType)
            if setCode ==set(): setCode.add('Code Nill')
            Solver = SIMP(statut='o', typ='TXM', into=list(setCode), intoXSD=list(dictCodeModeleNumerique.keys()), ang='Choose the solver to be used (among the list)')
            monNomBloc = 'bloc_ModelName_' + modeleNumerique.replace(' ','_') #les noms de blocs ne peuvent pas avoir de blanc ! 
            if setCode !=set(): dicoBloc[monNomBloc]=BLOC(condition=conditionNum, nomXSD='b_ModelName',Solver=Solver)
        dicoArgs['blocModelType'+typeMod] = BLOC(condition=conditionType, NumericalMethod=NumericalMethod, **dicoBloc)
        
    blocMeshRef = BLOC(condition = '( (ChoiceOfApproach == "Field_based") and (NumericalMethod == "FV") ) or '
                                   '( (ChoiceOfApproach == "Particle_based") and (NumericalMethod == "CFD_Discrete_Particle_based") )',
        MeshIdentifiers = SIMP(statut ='o', max ='**', typ = meshIdentifier, ang='Choose the mesh to be used.\n Requires at least one spatial discrezisation defined in SpatialAspects.',
                               metAJour=(('ApplyOn',
                                          'self.etape.getChild("BoundaryConditions").getChild("BoundaryCondition")'),),
                               ),)
    dicoArgs['blocMeshRef'] = blocMeshRef
    
    blocSysGeoRef = BLOC(condition =  '( (ChoiceOfApproach == "Particle_based") and (NumericalMethod != "CFD_Discrete_Particle_based") )',
        SysGeoIdentifiers = SIMP(statut ='o', max ='**', typ = systemGeometryId, ang='Choose the system geometry to be used.\n Requires at least one SystemGeometry defined in SpatialAspects.',
                               metAJour=(('ApplyOn',
                                          'self.etape.getChild("BoundaryConditions").getChild("BoundaryCondition")'),),
                               ),)
    dicoArgs['blocSysGeoRef'] = blocSysGeoRef
    NumericalModel = FACT(statut='o', max= '**', Identifier=Identifier, ChoiceOfApproach=ChoiceOfApproach, ang='Define the numerical model for the component',
                          SimulatedTimeLapse=SimulatedTimeLapse, **dicoArgs)
    return BLOC(condition=condition, nomXSD='b_systemType', NumericalModel=NumericalModel)


#-----------------------------------
def calculCommun(key1, key2, dico):
#-----------------------------------
# retourne la liste des valeurs communes a dico[key1] et dico[key2]
    monSet=set()
    if not key1 in dico: return ()
    if not key2 in dico: return ()
    for val in dico[key1]:
        if val in dico[key2]:
            monSet.add(val)
    if monSet == set() : monSet.add ('No common format')
    return list(monSet)

#-------------------------
def allValueInDict(dico):
#-------------------------
# retourne la liste de toutes les valeurs possibles dans dico 
    monSet=set()
    for clef in dico :
        for val in dico[clef] : monSet.add(val)
    return monSet

#--------------------------------------------------------------------------------------------------
def creeBlocPourLesFichiers(laCondition, Prefixe='Empty', ListeFormats=[], FieldName=None):
#---------------------------------------------------------------------------------------------------
# il faut reflechir pour parametrer NomDuFichier
# et le type (existing... du fichier)
# et utiliser le creeBlocPourLesFichiers
    SIMPFormatFichier = SIMP(statut='o', typ = 'TXM', into = tuple(ListeFormats) + ('All',), defaut='All' ,ang='Provide the file format')
    dicoDesBlocs = {}
    NomDuFichier = Prefixe+'FileName'
    formatName   = Prefixe+'FileFormat'
    dicoDesBlocs[formatName] = SIMPFormatFichier
    ListeFormatsboucle       = tuple(ListeFormats) + ('All',) 
    for formatFich in ListeFormatsboucle :
        dicoArgs={}
        nomBloc         = 'blocFormatFichier' + str(formatFich)
        typeDesFichiers = ('Fichier', formatFich + " Files (*." + formatFich + ");;All Files (*)",'Sauvegarde')
        blocCondition   = formatName + " == '" + formatFich + "'"
        dicoArgs[NomDuFichier] = SIMP(statut='o', typ = typeDesFichiers, nomXSD=NomDuFichier ,ang='Provide the file name')
        dicoDesBlocs[nomBloc]  = BLOC(condition = blocCondition, **dicoArgs)
    if FieldName:
        SIMPFieldName = SIMP(statut='o', typ = 'TXM',)
        dicoDesBlocs[FieldName] = SIMPFieldName 
    return BLOC(condition=laCondition, **dicoDesBlocs)

#---------------------------------------------------------------------
def prepareBlocAmbiantMediaField(condition, nomDuFact, nomDelaContante, FactComment, FieldComment) :
#---------------------------------------------------------------------
    dicoDesBlocs = {}
    dicoDuFact   = {}
    dicoDuFact[nomDelaContante] = SIMP(typ='TXM', statut='o', defaut = nomDelaContante, homo='constant', ang=FieldComment)
    monFact = FACT ( statut ='o', ang=FactComment,
       **dicoDuFact,
       SteadyState      = SIMP(typ=bool, statut ='o', defaut = True,ang='Precise if the ambient field is a steady state'),
       blocSteadyState  = BLOC(condition = 'SteadyState == True',
         FieldOrigin    = SIMP(statut='o', into =['File', 'Value','Interaction'], typ ='TXM',ang='Define the origin of the field.\n Current choice includes an external File, a given Value or an Interaction (with a component)'),
         blocValue      = BLOC(condition = 'FieldOrigin == "Value"',
            ConstantValue = SIMP(statut ='o', typ='R',ang='Give the value of the field'),
         ),
         blocFile       = creeBlocPourLesFichiers('FieldOrigin == "File"', 'Position', ('Med', 'cgns' ), ''),
         blocInteraction = BLOC(condition = 'FieldOrigin == "Interaction"',
            InteractionName = SIMP(typ=interaction,statut='o',ang='Choose the component in interaction.\n Requires at least another component.'),
            Consigne = SIMP(statut="o", homo="information", typ="TXM", defaut='Create and choose suitable interaction'),
         ),
       ),
        blocConsigne = BLOC(condition = 'SteadyState == False',
          Consigne = SIMP(statut="o", homo="information", typ="TXM", defaut='Not implemented yet. Will ask for a range of calculation steps.'),
        ), #BlocNotSteady                                       
       FieldAppliesOnAllSpecies = SIMP(statut='o', typ=bool, defaut=True,ang='Precise if the field applies on all species (i.e. all types of particles defined in this Classical-Particle-System component)'),
       blocPorteEspece = BLOC(condition = 'FieldAppliesOnAllSpecies == False ',
         AppliesToSpecies = SIMP(statut='o', typ=userParticle, max= '**', homo='SansOrdreNiDoublon'),     # faire un typ = "espece"
       ),
    )
    dicoDesBlocs[nomDuFact] = monFact 
    return BLOC(condition=condition,**dicoDesBlocs)

#------------------------------
def prepareTermeSource(condition):
#------------------------------
   return BLOC (condition=condition, 
      OriginOfSourceTerm = SIMP(statut='o', typ='TXM',into=['Interaction', 'Chemical Reaction', 'Other Scalar'],ang='Choose the origin of the source term. \n Current choice includes Interaction (i.e. with another component), Chemical Reaction, Other Scalars'),
      blocOriginOfSourceTermInteraction = BLOC(condition = 'OriginOfSourceTerm == "Interaction"',
        SourceTermInteraction = SIMP(typ=interaction,statut='o'),
        Consigne = SIMP(statut="o", homo="information", typ="TXM", defaut='Create and choose suitable interaction'),
      ),
      blocOriginOfSourceTermOtherScalar = BLOC(condition = 'OriginOfSourceTerm == "Other Scalar"',
        TakenFrom =  SIMP (statut ='o', typ=scalar,  ), #PNPN A FAIRE : fenetreIhm='menuDeroulant'
      ),
   )

#----------------------------------------
def prepareTermeSourceParticle(condition):
#---------------------------------------
# les differences avec prepareTermeSource sont 
#     le type de TakenFrom
#     le into
# il est possible de factoriser les 2 fonctions en utilisant un intoXSD mais cela
# affaiblit la possibilite de controle du XSD

   return BLOC (condition=condition, 
      OriginOfSourceTerm = SIMP(statut='o', typ='TXM',into=['Interaction', 'Other Particle'],ang='Choose the origin of the source term. \n Current choice includes Interaction (i.e. with another component), Other Particle (i.e. with another particle within this Classical-Particle-System component).'),
      blocOriginOfSourceTermInteraction = BLOC(condition = 'OriginOfSourceTerm == "Interaction"',
        SourceTermInteraction = SIMP(typ=interaction,statut='o'),
        Consigne = SIMP(statut="o", homo="information", typ="TXM", defaut='Create and choose suitable interaction'),
      ),
      blocOriginOfSourceTermOtherScalar = BLOC(condition = 'OriginOfSourceTerm == "Other Particle"',
        TakenFrom =  SIMP (statut ='o', typ=userParticle,  ), #PNPN A FAIRE : fenetreIhm='menuDeroulant'
   ),
   )

#---------------------------------------------------------------------------------
def prepareFactTurbulence(statut, ajout=None , position=None, positionChoice=None):
#---------------------------------------------------------------------------------
   listInto  = ['Fully resolved (DNS)', 'Spatial filtering (LES)', 'One-point moment', 'One-point PDF']
   if ajout != None : listInto.append(ajout)
   return FACT(statut=statut, ang='Define how turbulence is simulated.',
       TurbulenceModellingType = SIMP(typ='TXM', statut='o', into =listInto, position=position ,ang='Choose the model used for turbulence.\n Current choice includes DNS (Direct Numerical Simulation), LES (Large-Eddy Simulation), One-point moment and One-point PDF'),

#      --------------- One-point moment ------------------ 
       blocOnePoint   = BLOC(condition= "TurbulenceModellingType == 'One-point moment'",
          RANSModel   = SIMP(statut="o", typ="TXM", position='global',
                             into=['Turbulent-Viscosity Model (TVM)', 'Reynolds Stress Model (RSM)'],ang='Choose the type of One-point moment model for turbulence.\n Current choice includes Turbulent-Viscosity Model and Reynolds-Stress Model'),
          blocTVM     = BLOC(condition= "RANSModel == 'Turbulent-Viscosity Model (TVM)'",
            TVMChoice = SIMP(typ='TXM', statut='o', into=['K-Epsilon', 'K-Omega'] , position=positionChoice, ang='Choose the type of Turbulent-Viscosity model for turbulence.\n Current choice includes K-Epsilon and K-Omega models.'), ##PN PN : parametre vs reCalculeEtape
          ), # fin blocTVM
          blocRSM      = BLOC(condition = "RANSModel == 'Reynolds Stress Model (RSM)'",
            RSMChoice  = SIMP(typ='TXM', statut='o', into=['Rotta', 'LRR-IP','LRR-QI','SSG'], position=positionChoice,ang='Choose the type of Reynolds-Stress model for turbulence.\n Current choice includes Rotta, LRR-IP, LRR-IQ and SSG models.'),
          ), # fin blocRSM
       ), # fin bloc_one_point

#      --------------- Spatial filtering (LES) ------------------ 
       blocSpatialFiltering    = BLOC(condition = "TurbulenceModellingType == 'Spatial filtering (LES)'",
          ChoiceOfDescription  = SIMP(typ='TXM', statut='o', into=['One-point filtered variables', 'Filtered Density Function (FDF)'],ang='Choose the type of LES model for turbulence.\n Current choice includes One-point filtered variables models and Filtered-Density Function (FDF) models.'),
          blocOnePoint         = BLOC(condition = "ChoiceOfDescription == 'One-point filtered variables'", 
            SubgridScaleModel = SIMP(typ='TXM', statut='o', into=['No SGS', 'Smagorinsky','Dynamical model', 'SGS Transport Equations'],ang='Choose the type of One-point filtered variables model for turbulence.\n Current choice includes No SGS (Sub-Grid Scale), Smagorinsky, Dynamical model or SGS Transport Equations.'),
          ),# fin bloc_OnePoint
          blocFDF     = BLOC(condition = "ChoiceOfDescription == 'Filtered Density Function (FDF)'", 
            SubgridScaleModel = SIMP(typ='TXM', statut='o', into=['SLM model for SGS', 'Viscous SLM model for SGS'],ang='Choose the type of FDF model for turbulence.\n Current choice includes SLM model for SGS (Simple Langevin Model) and Viscous SLM model for SGS'),
          ),# fin bloc_FDF
       ), # fin bloc_one_spatial

#      --------------- One-point PDF ------------------ 
       blocOnePointPdf       = BLOC(condition = "TurbulenceModellingType == 'One-point PDF'",
          ChoiceOfDescription   = SIMP(typ='TXM', statut='o', into=['Velocity PDF', 'Velocity frequency PDF'],ang='Choose the type of One-point PDF model for turbulence.\n Current choice includes Velocity PDF and Velocity Frequency PDF'),
          blocVPdf  = BLOC(condition = "ChoiceOfDescription == 'Velocity PDF'",
             StochasticModel = SIMP(typ='TXM', statut='o', into=['SLM','GLM'], defaut='SLM',ang='Choose the type of Velocity PDF model for turbulence.\n Current choice includes SLM (Standard Langevin Model) and GLM (Generalized Langevin Model)'),
          ), # fin blocVPdf
          blocVFPdf  = BLOC(condition = "ChoiceOfDescription == 'Velocity frequency PDF'",
             StochasticModel = SIMP(typ='TXM', statut='o', into=['Log-normal model','Gamma model','User-defined form'], defaut='SLM',ang='Choose the type of Velocity-Frequency PDF model for turbulence.\n Current choice includes Log-normal model, Gamma model and User-defined forms.'),
          ), # fin blocVFPdf
       ), # fin bloc_one_point_pdf

#      --------------- Fully resolved (DNS) ------------------ 
       # blocNoModel          = BLOC(condition = "TurbulenceModellingType == 'Fully resolved (DNS)'",
       #    ChoiceOfApproach  = SIMP(statut='o', typ='TXM', into=['Field_based (DNS)', 'Particle_based']),
       #    blocField         = BLOC(condition = "ChoiceOfApproach == 'Field_based (DNS)'", 
       #      NumericalMethod = SIMP(statut='o', typ='TXM', into=['FV', 'Spectral Method'], 
       #                        intoXSD=['FV', 'Spectral Method','SPH', 'Vortex Method']),
       #    ),# fin bloc_Field
       #    blocNParticle     = BLOC(condition = "ChoiceOfApproach == 'Particle_based'", 
       #      NumericalMethod = SIMP(statut='o', typ='TXM', into=['SPH', 'Vortex Method'],
       #                        intoXSD=['FV', 'Spectral Method','SPH', 'Vortex Method']),
       #    ),# fin bloc_N_particle
       # ), # fin bloc_no_model
   ) # fin du return de la fonction factTurbulence

#--------------------------------------
def prepareFactTurbulenceForParticule():
#--------------------------------------
   listInto  = ['Fully resolved (DNS)', 'Spatial filtering (LES)', 'One-point moment', 'One-point PDF']
   return FACT(statut='o', 
     NatureOfFlow    = SIMP(typ='TXM', statut='o', into =['Laminar', 'Turbulent'], position='global',ang='Choose the type of flow.\n Current choice includes laminar or turbulent.'),
     blocTurbulent = BLOC( condition = 'NatureOfFlow == "Turbulent"',
       TurbulenceModellingType = SIMP(typ='TXM', statut='o', into =listInto, position ='global', ang='Choose the model used for the turbulent flow.\n Current choice includes DNS (Direct Numerical Simulation), LES (Large-Eddy Simulation), One-point moment and One-point PDF'),
#      --------------- One-point moment ------------------ 
       blocOnePoint   = BLOC(condition= "TurbulenceModellingType == 'One-point moment'",
          RANSModel   = SIMP(statut="o", typ="TXM", into=['Turbulent-Viscosity Model (TVM)', 'Reynolds Stress Model (RSM)'],ang='Choose the type of One-point moment model for the turbulent flow.\n Current choice includes Turbulent-Viscosity Model and Reynolds-Stress Model'),
       ), # fin bloc_one_point

#      --------------- Spatial filtering (LES) ------------------ 
       blocOneSpatial       = BLOC(condition = "TurbulenceModellingType == 'Spatial filtering (LES)'",
          ChoiceOfDescription  = SIMP(typ='TXM', statut='o', into=['One-point filtered variables', 'Filtered Density Function (FDF)'],ang='Choose the type of LES model for the turbulent flow.\n Current choice includes One-point filtered variables models and Filtered-Density Function (FDF) models.'),
       ), # fin bloc_one_spatial

#      --------------- One-point PDF ------------------ 
       blocOnePointPdf       = BLOC(condition = "TurbulenceModellingType == 'One-point PDF'",
          ChoiceOfDescription   = SIMP(typ='TXM', statut='o', into=['Velocity PDF', 'Velocity frequency PDF'],ang='Choose the type of One-point PDF model for the turbulent flow.\n Current choice includes Velocity PDF and Velocity Frequency PDF'),
       ), # fin bloc_one_point_pdf
       #TypeOfHydroDynamicForce
       blocTMD = BLOC(condition ='NatureOfFlow == "Turbulent" and  TypeOfHydroDynamicForce != None and "Drag" in TypeOfHydroDynamicForce',
           TurbulenceModelDispersion = SIMP (statut ='o', typ='TXM', into = ['Langevin'],ang='Choose the type of model for particle turbulent dispersion.\n Current choice includes Langevin model.'),
           BlocInitialisationLangevin = BLOC(condition ='TurbulenceModelDispersion == "Langevin"',
               InitialisationType = SIMP(statut='o', into =['ByInteraction', 'ByFile' ], typ ='TXM', ang='Choose how the turbulent field is initialized.\n Current choice includes by Interaction (with another component) or by File.'),
               blocByFile  = creeBlocPourLesFichiers('OrigineType == "ByFile"', '', ListeFormats = 'all', FieldName=None),
               blocByInteraction = BLOC(condition = 'InitialisationType == "ByInteraction"',
                  Consigne = SIMP(statut="o", homo="information", typ="TXM", defaut='Create and choose suitable interactions'),
                  InteractionNameForPressure = SIMP(typ=interaction,statut='o', ang='Choose the origin of the pressure field.\n Requires another continuum component.',
                   filtre=( '(set(("Pressure",)).intersection(set(self.getEficasAttribut("InvolvedStateVariable"))) != set())',
                            ()), # Pressure en dur
                            ),
                  InteractionNameForVelocity = SIMP(typ=interaction,statut='o', ang='Choose the origin of the velocity field. \n Requires another continuum component.'),
                  InteractionNameForEpsilon  = SIMP(typ=interaction,statut='o', ang='Choose the origin of the turbulent dissipation field. \n Requires another continuum component.'),
                  InteractionNameForRij      = SIMP(typ=interaction,statut='o', ang='Choose the origin of the Reynolds Stress field. \n Requires another continuum component.'),
               ),
           ),
       ),
    ),# fin bloc Turbulent
   ) # fin du return de la fonction factTurbulence

#--------------------------------------------------------
def prepareFactTurbulenceScalaire(statut, position=None):
#-------------------------------------------------------
   listInto  = ['Fully resolved (DNS)', 'Spatial filtering (LES)', 'One-point moment', 'One-point PDF']
   return FACT(statut=statut, 
       TurbulenceModellingType = SIMP(typ='TXM', statut='o', into =listInto, position=position, ang='Choose the model used for the turbulent transport of the scalar.\n Current choice includes DNS (Direct Numerical Simulation), LES (Large-Eddy Simulation), One-point moment and One-point PDF'),

#      --------------- One-point moment ------------------ 
       blocOnePoint   = BLOC(condition= "TurbulenceModellingType == 'One-point moment'",
          RANSModel   = SIMP(statut="o", typ="TXM", ang='Choose the type of One-point moment model for the turbulent transport of the scalar.\n Current choice includes Algebraic flux models, Turbulent diffusivity models and Scalar-flux transport equations',
                            into=['Algebraic flux models','Turbulent diffusivity models', 'Scalar-flux transport equations']),
          # Ce bloc consigne ne passe pas dans la projection XSD 
          # blocAlgebraic     = BLOC(condition= "RANSModel == 'Algebraic flux models'",
           blocConsigne = BLOC(condition= "RANSModel == 'Algebraic flux models'",
               Consigne = SIMP(statut="o", homo="information", typ="TXM", defaut='Not implemented yet'),
           ), # fin blocAlgebraic
          blocTDM      = BLOC(condition = "RANSModel == 'Turbulent diffusivity models'",
            TDMChoice  = SIMP(typ='TXM', statut='o', into=['SGDH', 'GGDH',],ang='Choose the type of turbulent-diffusivity models for the scalar.\n Current choice includes SGDH (standard gradient diffusion hypothesis) and GGDH (generalized gradient diffusion hypothesis)'),
          ), # fin blocTDM
          blocSFTE      = BLOC(condition = "RANSModel == 'Scalar-flux transport equations'",
            SFTEChoice  = SIMP(typ='TXM', statut='o', into=['Pressure-scrambling model', 'EB-DFM',]),
          ), # fin blocSFTE
       ), # fin bloc_one_point

#      --------------- Spatial filtering (LES) ------------------ 
       blocOneSpatial       = BLOC(condition = "TurbulenceModellingType == 'Spatial filtering (LES)'",
          ChoiceOfDescription  = SIMP(typ='TXM', statut='o', into=['One-point filtered variables', 'Filtered Density Function (FDF)'],ang='Choose the type of LES model for the turbulent transport of the scalar.\n Current choice includes One-point filtered variables, Filtered Density Function (FDF)'),
          blocOnePoint         = BLOC(condition = "ChoiceOfDescription == 'One-point filtered variables'", 
            SubgridScaleModel = SIMP(typ='TXM', statut='o', into=['No SGS model', 'SGS diffusivity', 'Transport eqs. for SGS scalar fluxes'],ang='Choose the type of One-point filtered variables model for the turbulent transport of the scalar.\n Current choice includes No SGS (Sub-Grid Scale), Smagorinsky, Dynamical model or SGS Transport Equations.'),
          ),# fin bloc_OnePoint
          blocFDF     = BLOC(condition = "ChoiceOfDescription == 'Filtered Density Function (FDF)'", 
            SubgridScaleModel = SIMP(typ='TXM', statut='o', into=['Composition FDF', 'Scalar-velocity FDF', 'Micro-mixing model'],ang='Choose the type of FDF model for the turbulent transport of the scalar.\n Current choice includes Composition FDF, Scalar-velocity FDF and Micro-mixig models'),
          ),# fin bloc_FDF
       ), # fin bloc_one_spatial

#      --------------- One-point PDF ------------------ 
       blocOnePointPdf       = BLOC(condition = "TurbulenceModellingType == 'One-point PDF'",
          ChoiceOfDescription   = SIMP(typ='TXM', statut='o', into=['Composition PDF','Velocity PDF', 'Micro-mixing models'],ang='Choose the type of One-point PDF model for the turbulent transport of the scalar.\n Current choice includes Composition PDF, Velocity PDF and Micro-mixing models'),
          # blocCPdf  = BLOC(condition = "(ChoiceOfDescription == 'Composition PDF') or (ChoiceOfDescription == 'Velocity PDF')",
          # blocConsigne  = BLOC(condition = "(ChoiceOfDescription == 'Composition PDF') or (ChoiceOfDescription == 'Velocity PDF')",
          #    Consigne = SIMP(statut="o", homo="information", typ="TXM", defaut='Not implemented yet.'),
          # ), # fin blocCPdf
          # blocVPdf  = BLOC(condition = "ChoiceOfDescription == 'Velocity PDF'",
          # ), # fin blocVPdf
          blocMMMPdf  = BLOC(condition = "ChoiceOfDescription == 'Micro-mixing models'",
             ChoiceOfModel = SIMP(typ='TXM', statut='o', into=['IEM/CIEM','Curl model','Mapping','EMST'],ang='Choose the type of Micro-mixing model for the turbulent transport of the scalar.\n Current choice includes IEM/CIEM (Interaction by exchange with the mean), Curl model, Mapping and EMST (Euclidean minimum spanning tree).'),
          ), # fin blocMMMdf
       ), # fin bloc_one_point_pdf

#      --------------- Fully resolved (DNS) ------------------ 
       # blocNoModel          = BLOC(condition = "TurbulenceModellingType == 'Fully resolved (DNS)'",
       #    ChoiceOfApproach  = SIMP(statut='o', typ='TXM', into=['Field_based (DNS)', 'Particle_based']),
       #    blocField         = BLOC(condition = "ChoiceOfApproach == 'Field_based (DNS)'", 
       #      NumericalMethod = SIMP(statut='o', typ='TXM', into=['FV', 'Spectral Method'], 
       #                        intoXSD=['FV', 'Spectral Method','SPH', 'Vortex Method']),
       #    ),# fin bloc_Field
       #    blocNParticle     = BLOC(condition = "ChoiceOfApproach == 'Particle_based'", 
       #      NumericalMethod = SIMP(statut='o', typ='TXM', into=['SPH', 'Vortex Method'],
       #                        intoXSD=['FV', 'Spectral Method','SPH', 'Vortex Method']),
       #    ),# fin bloc_N_particle
       # ), # fin bloc_no_model
   ) # fin du return de la fonction factTurbulence


#--------------------
def prepareBlocCPS():
#--------------------
  return BLOC(condition = 'SystemType == "Classical particle system"',
   Particles = prepareParticles(),

#   -----------------------------   AmbiantMediaInteraction ----------------------------------
   AmbiantMediaInteraction = FACT(statut='o', ang='Define particle-ambient media interactions (when necessary)',
      MomentumExchange = FACT(statut='o',
         withMomentumExchange = SIMP(statut='o', typ=bool, defaut=False,ang='Activate if the ambient media interacts with particles via momentum exchange'),
         blocMomentum = BLOC(condition = 'withMomentumExchange == True',                               
            MomentumFieldType = SIMP(statut='o', typ='TXM', into=['Gravitational','Electric','Magnetic', 'Hydrodynamic'], max='**', homo='SansOrdreNiDoublon',position='reCalculeEtape'),
         blocElectric = prepareBlocAmbiantMediaField('MomentumFieldType != None and "Electric" in MomentumFieldType', 'DefineElectricForce', 'E','Provide information on the ambient electric field','Define the value of the electric field') ,
         blocMagnetic = prepareBlocAmbiantMediaField('MomentumFieldType != None and "Magnetic" in MomentumFieldType', 'DefineMagneticForce', 'B','Provide information on the ambient magnetic field','Define the value of the magnetic field') ,
         blocGravite = BLOC(condition = 'MomentumFieldType != None and "Gravitational" in MomentumFieldType',
            DefineGravityForce = FACT (statut='o',
               InitialisationType = SIMP(statut='o', into =['ByValue', 'ByFile' ], typ ='TXM', defaut='ByValue',ang='Choose how the gravity field is initialized'),
               blocInitValue=  BLOC(condition = 'InitialisationType == "ByValue"',
                  G = SIMP(statut='o', typ='R', defaut=9.81,ang='Value of the gravitational acceleration (in m/s^2)'),
                  Direction = FACT (statut ='o',
                     GX = SIMP(statut='o', typ='R', ),
                     GY = SIMP(statut='o', typ='R', ),
                     GZ = SIMP(statut='o', typ='R', ),
                  ),
               ), # fin blocInitValue
               #PN : a completer pour fichier
               FieldAppliesOnAllSpecies = SIMP(statut='o', typ=bool, defaut=True,ang='Precise if the field applies on all species (i.e. all types of particles defined in this Classical-Particle-System component)'),
               blocPorteEspece = BLOC(condition = 'FieldAppliesOnAllSpecies == False ',
                 AppliesToSpecies = SIMP(statut='o', typ=userParticle, max= '**', homo='SansOrdreNiDoublon'),     # faire un typ = "espece"
               ),
             ), # Fact  Gravite
           ), # bloc Gravite
         blocHydro = BLOC(condition = 'MomentumFieldType != None and "Hydrodynamic" in MomentumFieldType',
            DefineForceOnParticle = FACT (statut='o', ang='Define how the ambient media acts on the particle',
               TypeOfHydroDynamicForce = SIMP(statut='o', max='**', typ='TXM', into=['Drag', 'Lift', 'Fluid Pressure Gradient', 'ThermoPhoresis', 'Brownian Motion'], homo='SansOrdreNiDoublon', position='global',ang='Choose the type of hydrodynamic force acting on a particle. \n Current choice includes Drag force, Lift force, Fluid Pressure Gradient, Thermophoresis and Brownian motion.'),
               
               FieldAppliesOnAllSpecies = SIMP(statut='o', typ=bool, defaut=True,ang='Precise if the field applies on all species (i.e. all types of particles defined in this Classical-Particle-System component)'),
               blocPorteEspece = BLOC(condition = 'FieldAppliesOnAllSpecies == False ',
                 AppliesToSpecies = SIMP(statut='o', typ=userParticle, max= '**', homo='SansOrdreNiDoublon'),     # faire un typ = "espece"
               ),
               NatureOfFluidFlow = prepareFactTurbulenceForParticule()
            ),
         ),
         ), # fin blocMomentum
      ), #  fin MomentumExchange
      MassExchange = FACT(statut='o',
         withMassExchange = SIMP(statut='o', typ=bool, defaut=False,ang='Activate if the ambient media interacts with particles via mass exchange',),                                         
         blocMassExchange = BLOC(condition = 'withMassExchange == True',                               
            MassExchangeFieldType = SIMP(statut='o', typ='TXM', into=['Evaporation','Condensation','Precipitation'], max='**', homo='SansOrdreNiDoublon',ang='Choose the type of mass exchange interaction with the particle. \n Current choice includes Evaporation, Condensation and Precipitation.'),
         ), # fin blocMassExchange                   
      ), # fin MassExchange
      EnergyExchange = FACT(statut='o',
         withEnergyExchange = SIMP(statut='o', typ=bool, defaut=False,ang='Activate if the ambient media interacts with particles via energy exchange'),                                         
         blocEnergyExchange = BLOC(condition = 'withEnergyExchange == True',                               
            EnergyExchangeFieldType = SIMP(statut='o', typ='TXM', into=['HeatTransfer','Radiation','Combustion'], max='**', homo='SansOrdreNiDoublon',ang='Choose the type of energy exchange interaction with the particle. \n Current choice includes Heat Transfer, Radiation and Combustion.'),
         ), # fin blocMassExchange                   
      ), # fin EnergyExchange
      AmbientInducedProcesses = FACT(statut='o',
         withAmbientInducedProcesses = SIMP(statut='o', typ=bool, defaut=False,ang='Activate if the ambient media interacts with particles via specific induced processes'),                                         
         blocAmbientInducedProcesses = BLOC(condition = 'withAmbientInducedProcesses == True',                               
             AmbientInducedProcessesType= SIMP(statut='o', typ='TXM', into=['Fragmentation',], max='**', homo='SansOrdreNiDoublon',ang='Choose the type of ambient induced processes acting on the particle. \n Current choice include Fragmentation.'),
             bAmbientInducedProcessesType = BLOC(condition = '(AmbientInducedProcessesType != None) and ("Fragmentation" in AmbientInducedProcessesType)',
               #PN : pb dans les locaux et l operateur in
                LevelOfDescription= SIMP(statut='o', typ='TXM', into=['Fully-resolved','Mean-field approaches'],ang='Choose the level of description for the fragmentation of particles. \n Current choice includes Fully-resolved approaches (direct simulations of aggregates fragmentation) and Mean-field approaches (Population Balance Equation)'),
                bMeanField = BLOC(condition = "LevelOfDescription == 'Mean-field approaches'",
                  FragmentationRate        = SIMP(statut='o', typ='R',ang='Define the fragmentation rate (for PBE models)'),
                  DaughterSizeDistribution = SIMP(statut='o', typ='R',ang='Define the daughter size distribution (for PBE models)'),
                ),
             ),
         ), # fin AmbientInducedProcesses                   
      ), # fin EnergyExchange
      AdditionalSamplingOfAmbientMedia = FACT(statut='o',
         withAdditionalSamplingOfAmbientMedia = SIMP(statut='o', typ=bool, defaut=False,ang='Activate if additional sampling of the ambient media by particles'),
         blocAdditionalSamplingOfAmbientMedia = BLOC(condition = 'withAdditionalSamplingOfAmbientMedia == True',
            FluidProperties = FACT(statut='o',
               VelocityGradient = SIMP(statut='o', typ = bool, defaut=False,ang='Activate sampling of the velocity gradient along particle trajectories'),
               PressureGradient = SIMP(statut='o', typ = bool, defaut=False,ang='Activate sampling of the pressure gradient along particle trajectories'),
            ),
         ), # fin blocblocAdditionalSamplingOfAmbientMedia                   
      ), # fin AdditionalSamplingOfAmbientMedia
   ), # fin AmbiantMediaInteraction

    ParticleParticleInteraction = FACT(statut='o', max = "**",ang='Define particle-particle interactions (when necessary)',
    # -------------------------------------------------------#
        BondedInteractions = prepareBondedInteractions(),
        ActionsAtDistance  = prepareActionsAtDistance(),
        ContactPhenomena   = prepareContactPhenomena(),
    ), # fin ParticleParticleInteraction 

    ParticleWallInteraction  = FACT(statut='o', max = "**",ang='Define particle-wall interactions (when necessary)',
        withParticleWallInteraction = SIMP(statut='o', typ =bool, defaut=False,ang='Activate particle-wall interactions'),
        bwithParticleWallInteraction = BLOC (condition = 'withParticleWallInteraction == True',
           ParticleWallInteractionId= SIMP(typ=(wallInteractionId,'createObject'), statut='o',ang='Define a name for the type of particle-wall interaction (to be used within the CDM)'),
           TypeOfWall  = FACT(statut='o',
              Dynamics = SIMP(statut='o', typ='TXM', into = ('Fixed position','Moving wall'),ang='Choose the type of wall dynamics.\n Current choice includes a Fixed wall and a Moving wall.'),
              LevelOfDescription = SIMP(statut='o', typ='TXM', into = ('Discretized particles','Continuum'),ang='Choose the level of description of the wall.\n Current choice includes Discretized particles (i.e. microscopic description) and Continuum level (i.e. macroscopic description).'),
              bContinuum = BLOC(condition = 'LevelOfDescription == "Continuum"',
                SurfaceTexture = SIMP(statut='o', typ='TXM', into = ('Smooth','Rough'),ang='Choose the type of surface texture.\n Current choice includes a Smooth or a Rough wall.'),
              ),
              bDiscretized = BLOC(condition = 'LevelOfDescription == "Discretized particles"',
               BondedInteractions = prepareBondedInteractions(True),
              ),
            ), 
            ActionsAtDistance  = prepareActionsAtDistanceForWall(),
            ContactPhenomena   = prepareContactPhenomenaWall(),
        ), 
    ),# fin ParticleWallInteraction 

   ConstraintsAndReducedStatisticalDescription = FACT(statut='o', 
      Constraint= FACT(statut='o', 
       TypeOfConstraint = SIMP( typ='TXM', statut='o', into=['Quasi static methods','Brownian dynamics','Presumed transport','Time marching equilibrium','Time marching non equilibrium'],defaut=['Time marching non equilibrium',], max ='**', position='reCalculeEtape', homo='SansOrdreNiDoublon',ang='Choose the type of constraints on the classical particle system.\n Current choice includes Quasi-static methods (e.g. Geometric optimisation or Monte-Carlo equilibrium), Brownian Dynamics (overdamped limit), Presumed Transport (i.e. particle motion are known), Time-marching equilibrium (e.g. canonical distribution) and Time-marching non-equilibrium (e.g. unsteady particle-tracking in time).'),
      ),
   ),
   
# transparents 163 et 164
# si brownian Diameter mass et position
# Presumed transport
#       No particle transport --> 
#       givencenter-of-mass transport __> position sera presente  mais given transport 

   StateVector = FACT(statut ='o',ang='Define the state vector for the particle (i.e. the variables attached to the particles).',
     ParticleDiameter = FACT(statut ='o',ang='Activate the particle diameter in the State Vector',
         Diameter                = SIMP(typ=(dynamicVariable,'createObject'), statut='o', defaut ='Diameter', homo='constant'),
         ToSimulate              = SIMP(typ=bool, statut ='o', defaut = True,ang='Choose to track the evolution of the particle diameter'),
         blocSimulatedDiameter   = prepareBlocInitialisationParticle(condition = 'ToSimulate == True', termeSource=True),
     ),
     ParticleMass = FACT(statut ='o',ang='Activate the particle mass in the State Vector',
         Mass                 = SIMP(typ=(dynamicVariable,'createObject'), statut='o', defaut ='Mass', homo='constant'),
         ToSimulate           = SIMP(typ=bool, statut ='o', defaut = True,ang='Choose to track the evolution of the particle mass'),
         blocSimulatedMass    = prepareBlocInitialisationParticle(condition = 'ToSimulate == True', termeSource=True),
     ),
     blocNonAggreateDescription  = BLOC(condition = 'ParticleNature != "Discrete Particle" or (ParticleNature == "Discrete Particle" and TypeOfDiscreteParticle != "Solid") or (ParticleNature == "Discrete Particle" and TypeOfDiscreteParticle == "Solid" and PrimaryOrAggregate != "Assemblage / Aggregate")' ,
         ParticlePosition = FACT(statut ='o',ang='Activate the particle position in the State Vector',
             Position                 = SIMP(typ=(dynamicVariable,'createObject'), statut='o', defaut ='Position', homo='constant'),
             ToSimulate               = SIMP(typ=bool, statut ='o', defaut = True,ang='Choose to track the evolution of the particle position'),
             blocSimulatedPosition    = prepareBlocInitialisationParticle(condition = 'ToSimulate == True', termeSource=False),
             blocNoSimulatedPosition  = prepareBlocOrigine(condition = 'ToSimulate == False')
         ), 
        blocNoBrownianDynamics = BLOC(condition = '(TypeOfConstraint != None) and not("Brownian dynamics" in TypeOfConstraint)', 
            ParticleVelocity = FACT(statut ='o',ang='Activate the particle velocity in the State Vector',
                Velocity                 = SIMP(typ=(dynamicVariable,'createObject'), statut='o', defaut ='Velocity', homo='constant'),
                ToSimulate               = SIMP(typ=bool, statut ='o', defaut = True,ang='Choose to track the evolution of the particle velocity'),
                blocSimulatedVelocity    = prepareBlocInitialisationParticle(condition = 'ToSimulate == True', termeSource=True),
                blocNotSimulatedVelocity = prepareBlocOrigine(condition = 'ToSimulate == False',),
            ), #fin VelocityDefinition
            #blocHydrodynamic = BLOC(condition = '"Hydrodynamic" in MomentumFieldType and TurbulenceModellingType !="Fully resolved (DNS)"', 
            #   FluidVelocitySeenByParticles = FACT(statut ='o',ang='Activate the fluid velocity seen in the State Vector',
            #   FluidSeenVelocity           = SIMP(typ=(dynamicVariable,'createObject'), statut='o', defaut ='FluidSeenVelocity', homo='constant'),
            #   ToSimulate                  = SIMP(typ=bool, statut ='o', defaut = True,ang='Choose to track the evolution of the fluid velocity seen'),
            #  blocHydrodynamicVelocity    = prepareBlocInitialisationParticle(condition = 'ToSimulate == True', termeSource=True),
            #) ,
           #) ,
        ), #blocNoBrownianDynamics
      ),# blocNotAgregateDescription
     blocCoarseGrainedAgregateDescription = BLOC(condition = ' AgregateDescription == "Coarse Grained"',
         AggregatePosition = FACT(statut ='o',ang='Activate the particle position in the State Vector',
             Position                 = SIMP(typ=(dynamicVariable,'createObject'), statut='o', defaut ='Position', homo='constant'),
             ToSimulate               = SIMP(typ=bool, statut ='o', defaut = True,ang='Choose to track the evolution of the particle position'),
             blocSimulatedPosition    = prepareBlocInitialisationParticle(condition = 'ToSimulate == True', termeSource=False),
             blocNoSimulatedPosition  = prepareBlocOrigine(condition = 'ToSimulate == False')
         ), 
        blocNoBrownianDynamics = BLOC(condition = '(TypeOfConstraint != None) and not("Brownian dynamics" in TypeOfConstraint)', 
            AggregateVelocity = FACT(statut ='o',ang='Activate the particle velocity in the State Vector',
                Velocity                 = SIMP(typ=(dynamicVariable,'createObject'), statut='o', defaut ='Velocity', homo='constant'),
                ToSimulate               = SIMP(typ=bool, statut ='o', defaut = True,ang='Choose to track the evolution of the particle velocity'),
                blocSimulatedVelocity    = prepareBlocInitialisationParticle(condition = 'ToSimulate == True', termeSource=True),
                blocNotSimulatedVelocity = prepareBlocOrigine(condition = 'ToSimulate == False',),
            ), #fin VelocityDefinition
            #blocHydrodynamic = BLOC(condition = '"Hydrodynamic" in MomentumFieldType and TurbulenceModellingType !="Fully resolved (DNS)"', 
            #   FluidVelocitySeenByParticles = FACT(statut ='o',ang='Activate the fluid velocity seen in the State Vector',
            #   FluidSeenVelocity           = SIMP(typ=(dynamicVariable,'createObject'), statut='o', defaut ='FluidSeenVelocity', homo='constant'),
            #   ToSimulate                  = SIMP(typ=bool, statut ='o', defaut = True,ang='Choose to track the evolution of the fluid velocity seen'),
            #  blocHydrodynamicVelocity    = prepareBlocInitialisationParticle(condition = 'ToSimulate == True', termeSource=True),
            #  ) ,
            #) ,
        ), #blocNoBrownianDynamics
         Morphologie = FACT(statut ='o',ang='Activate the particle velocity in the State Vector',
                AggregateMorphology     = SIMP(typ=(dynamicVariable,'createObject'), statut='o', defaut ='Velocity', homo='constant'),
                ToSimulate               = SIMP(typ=bool, statut ='o', defaut = True,ang='Choose to track the evolution of the particle velocity'),
                blocSimulatedVelocity    = prepareBlocInitialisationParticle(condition = 'ToSimulate == True', termeSource=True),
                blocNotSimulatedVelocity = prepareBlocOrigine(condition = 'ToSimulate == False',),
            ) ,
      ),# blocCOarseAgregateDescription
     blocFineGrainedAgregateDescription = BLOC(condition = 'AgregateDescription == "Fine Grained"',
         PrimaryParticlePosition = FACT(statut ='o',ang='Activate the particle position in the State Vector',
             Position                 = SIMP(typ=(dynamicVariable,'createObject'), statut='o', defaut ='Position', homo='constant'),
             ToSimulate               = SIMP(typ=bool, statut ='o', defaut = True,ang='Choose to track the evolution of the particle position'),
             blocSimulatedPosition    = prepareBlocInitialisationParticle(condition = 'ToSimulate == True', termeSource=False),
             blocNoSimulatedPosition  = prepareBlocOrigine(condition = 'ToSimulate == False')
         ), 
        blocNoBrownianDynamics = BLOC(condition = '(TypeOfConstraint != None) and not("Brownian dynamics" in TypeOfConstraint)', 
            PrimaryParticleVelocity = FACT(statut ='o',ang='Activate the particle velocity in the State Vector',
                Velocity                 = SIMP(typ=(dynamicVariable,'createObject'), statut='o', defaut ='Velocity', homo='constant'),
                ToSimulate               = SIMP(typ=bool, statut ='o', defaut = True,ang='Choose to track the evolution of the particle velocity'),
                blocSimulatedVelocity    = prepareBlocInitialisationParticle(condition = 'ToSimulate == True', termeSource=True),
                blocNotSimulatedVelocity = prepareBlocOrigine(condition = 'ToSimulate == False',),
            ), #fin VelocityDefinition
            #blocHydrodynamic = BLOC(condition = '"Hydrodynamic" in MomentumFieldType and TurbulenceModellingType !="Fully resolved (DNS)"', 
            #   FluidVelocitySeenByParticles = FACT(statut ='o',ang='Activate the fluid velocity seen in the State Vector',
            #   FluidSeenVelocity           = SIMP(typ=(dynamicVariable,'createObject'), statut='o', defaut ='FluidSeenVelocity', homo='constant'),
            #   ToSimulate                  = SIMP(typ=bool, statut ='o', defaut = True,ang='Choose to track the evolution of the fluid velocity seen'),
            #   blocHydrodynamicVelocity    = prepareBlocInitialisationParticle(condition = 'ToSimulate == True', termeSource=True),
            #   ) ,
            # ) ,
         ), #blocNoBrownianDynamics   
         PrimaryParticleConnectivity = FACT(statut ='o',ang='Activate the particle velocity in the State Vector',
                ParticleConnectivity     = SIMP(typ=(dynamicVariable,'createObject'), statut='o', defaut ='Velocity', homo='constant'),
                ToSimulate               = SIMP(typ=bool, statut ='o', defaut = True,ang='Choose to track the evolution of the particle velocity'),
                blocSimulatedVelocity    = prepareBlocInitialisationParticle(condition = 'ToSimulate == True', termeSource=True),
                blocNotSimulatedVelocity = prepareBlocOrigine(condition = 'ToSimulate == False',),
          ) ,
      ),# blocNotAgregateDescription
      # hydro
     blocHydroCondition1erNiveau  = BLOC(condition = '(    ParticleNature != "Discrete Particle" '\
                                         '             or (ParticleNature == "Discrete Particle" and TypeOfDiscreteParticle != "Solid")'\
                                         '             or (ParticleNature == "Discrete Particle" and TypeOfDiscreteParticle == "Solid" and PrimaryOrAggregate != "Assemblage / Aggregate"))'\
                                         'or (AgregateDescription == "Coarse Grained") or (AgregateDescription == "Fine Grained")',
        blocNoBrownianDynamics2 = BLOC(condition = '(TypeOfConstraint != None) and not("Brownian dynamics" in TypeOfConstraint)', 
            blocHydrodynamic      = BLOC(condition = '"Hydrodynamic" in MomentumFieldType and TurbulenceModellingType !="Fully resolved (DNS)"', 
               FluidVelocitySeenByParticles = FACT(statut ='o',ang='Activate the fluid velocity seen in the State Vector',
               FluidSeenVelocity           = SIMP(typ=(dynamicVariable,'createObject'), statut='o', defaut ='FluidSeenVelocity', homo='constant'),
               ToSimulate                  = SIMP(typ=bool, statut ='o', defaut = True,ang='Choose to track the evolution of the fluid velocity seen'),
              blocHydrodynamicVelocity    = prepareBlocInitialisationParticle(condition = 'ToSimulate == True', termeSource=True),
            ) ,
           ) ,
        ),
      ),
    ), #fin StateVector
   )# fin du prepareBlocCps

#----------------------
def prepareParticles():
#----------------------
   return FACT(statut='o', max='**',  
   ParticleNature = SIMP(statut='o', typ='TXM', position = 'reCalculeEtape', ang='Choose the nature of the particle.\n Current choice includes Atom, Molecule, Dissipative Particle (for DPD), Fluid particle, Discrete Particle (e.g. solid, bubble, droplet).',
           into=['Atom', 'Molecule', 'Dissipative Particle', 'Fluid Particle', 'Discrete Particle']),
     blocAtomName   = BLOC(condition='ParticleNature == "Atom"', 
           ParticleName = SIMP(statut='o', typ=(userAtom,'createObject'), ang='Define the name of the atom (to be used for CDM).' ),
           InitialNumberOfParticles  = SIMP(statut='o', typ='I', val_min=0,ang='Define the number of atoms initially in the system'),
     ),

     blocMoleculeName   = BLOC(condition='ParticleNature == "Molecule"',
        ParticleName   = SIMP(statut='o', typ=(userMolecule,'createObject'),ang='Define the name of the molecule (used in the CDM).'),
        InitialNumberOfParticles  = SIMP(statut='o', typ='I', val_min=0,ang='Define the number of molecules initially in the system'),
     ),

     blocDissipativeName   = BLOC(condition='ParticleNature == "Dissipative Particle"',
        ParticleName    = SIMP(statut='o', typ=(userDPD,'createObject'),ang='Define the name of the DPD particle (used in the CDM).'),
        InitialNumberOfParticles  = SIMP(statut='o', typ='I', val_min=0,ang='Define the number of DPD initially in the system'),
     ),

     blocDiscreteName     = BLOC(condition='ParticleNature == "Discrete Particle"',
      ParticleName   = SIMP(statut='o', typ=(userDiscrete,'createObject'),ang='Define the name of the discrete particle (used in the CDM).'),
      InitialNumberOfParticles  = SIMP(statut='o', typ='I', val_min=0,ang='Define the number of discrete particle initially in the system'),
     ),

     blocAtom    = BLOC(condition='ParticleNature == "Atom"', 
           ChemicalSpecies = SIMP(statut='o', typ='TXM',ang='Define the type of the chemical atom'),
           ElectricCharge  = SIMP(statut='f', typ='R',ang='Define the electric charge of the atom (in Coulomb).'),
           MagneticMoment  = SIMP(statut='f', typ='R',ang='Define the magnetic moment of the atom (in A.m^2)'),
           Radius          = SIMP(statut='f', typ='R',ang='Define the radius of the atom (in m)'),  # relevant ?
           # ),# Atom
     ), # fin b_Atom
#   --------------- Molecules ------------------ 
     blocMolecule     = BLOC(condition='ParticleNature == "Molecule"',
        Shape           = SIMP(statut='o', typ='TXM', into=['Linear', 'Trigonal Planar', 'Angular', 'Tetrahedral', 'Octahedral', 'Trigonal pyramid', 'Other'],ang='Choose the shape of the molecule.\n Current choice includes Linear, Trigonal Planar, Angular, Tetrahedral, Octahedral, Trigonal Pyramid or Other.'),
        ElectricCharge  = SIMP(statut='f', typ='R',ang='Define the electric charge of the molecule (in Coulomb)'),
        MagneticMoment  = SIMP(statut='f', typ='R',ang='Define the magnetic moment of the molecule (in A.m^2)'),
        Radius          = SIMP(statut='f', typ='R',ang='Define the radius of the molecule (in m)'),  # relevant ?
     ), #fin b_Molecule
#   --------------- Dissipative ------------------ 
     blocDissipative   = BLOC(condition='ParticleNature == "Dissipative Particle"',
        BondedParticles = SIMP(statut="o", typ=bool, defaut=False,ang='Define the particles that are bonded together'),
    ), # b_Dissipative

#      --------------- Discrete Particle ------------------ 
     blocDiscrete     = BLOC(condition='ParticleNature == "Discrete Particle"',
       TypeOfDiscreteParticle = SIMP(statut='o', typ='TXM', position = 'reCalculeEtape', into=['Solid', 'Droplets', 'Bubbles','Bio Organism'],ang='Choose the type of discrete particles.\n Current choice includes Solid particles (e.g. colloids, aerosols or dust), Droplets, Bubbles and Bio-organisms (e.g. bacteria).'),
       blocTypeDPSolid  = BLOC(condition ='TypeOfDiscreteParticle == "Solid"',
         PrimaryOrAggregate    = SIMP(statut='o', position='reCalculeEtape', typ='TXM', into=['Primary Particle', 'Assemblage / Aggregate'], ang='Choose the type of solid particle. \n Current choice includes Primary particles (i.e. indivisible objects) and Assemblage/Aggregate (i.e. objects that can break into smaller elements).'),
            b_SolidAggregate = BLOC(condition='PrimaryOrAggregate == "Assemblage / Aggregate"',
              AgregateDescription = SIMP(statut='o', typ='TXM', into=['Coarse Grained', 'Fine Grained'], position = 'reCalculeEtape'),
              blocAgregateFineGrainedDescription = BLOC(condition='AgregateDescription == "Fine Grained"',
                 ParticulePrimaryProperties = FACT (statut ='o',
                    Geometry   = SIMP(statut='o', typ='TXM', into=['Sphere', 'Ellipsoids', 'Other Shape'], ang='Choose the shape of particles. \n Current choice includes Sphere, Ellipsoids and Other Shapes.'),
                   b_geom_Sphere = BLOC(condition = 'Geometry == "Sphere"',
                        ReferenceParticleRadius = SIMP(statut='o', typ ='R', val_min = 0, ang='Define a reference particle radius (in m).'),
                   ),
                   Weight = FACT(statut = 'o',ang='Define the weight of particles (either through a mass or a density). ',
                     Consigne = SIMP(statut="o", homo="information", typ="TXM", defaut='Choose between Mass or Density'),          
                     Mass = SIMP(statut='f', typ ='R', val_min = 0,ang='Define the mass of the particle (in kg).'),
                     Density = SIMP(statut='f', typ ='R', val_min = 0, ang='Define the density of the particle (in kg/m^3).'),
                   ),

                 ), # ParticulePrimaryProperties
              ), # blocAgregateFineGrainedDescription
              blocAgregateCoarseGrainedDescription = BLOC(condition='AgregateDescription == "Coarse Grained"',
                 AgregateProperties = FACT (statut ='o',
                    Consigne = SIMP(statut="o", homo="information", typ="TXM", defaut='Choose between GyrationRadius, HydrodynamicRadius, EnclosedSphereRadius'),          
                    GyrationRadius = SIMP(statut='f', typ ='R', val_min = 0),
                    EnclosedSphereRadius = SIMP(statut='f', typ ='R', val_min = 0),
                    HydrodynamicRadius = SIMP(statut='f', typ ='R', val_min = 0),
                    Weight = FACT(statut = 'o',#ang='Define the weight of particles (either through a mass or a density) ',
                       Consigne = SIMP(statut="o", homo="information", typ="TXM", defaut='Choose between Mass or Density'),          
                       Mass = SIMP(statut='f', typ ='R', val_min = 0,ang='Define the mass of the particle (in kg).'),
                       Density = SIMP(statut='f', typ ='R', val_min = 0, ang='Define the density of the particle (in kg/m^3).'),
                    ),
                    Morphology = FACT(statut='o',
                       Consigne = SIMP(statut="o", homo="information", typ="TXM", defaut='Choose between CoordinationNumber, FractalDimension or Porosity'),          
                       FractalDimension = SIMP(statut='f', typ='R', ang='Define the number of primary particles within an aggregate'),
                       Porosity  = SIMP(statut='f', typ='R', ang='Define the porosity of the aggregate'),
                       CoordinationNumber = SIMP(statut='f', typ='R', ang='Define the CoordinationNumber of the aggregate'),
                    ),
                    Cohesion = FACT(statut='o',
                       Consigne = SIMP(statut="o", homo="information", typ="TXM", defaut='Choose between Force and PotentialEnergy'),          
                       Force  = SIMP(statut='f', typ='R', ang='Define the porosity of the aggregate'),
                       PotentialEnergy = SIMP(statut='f', typ='R', ang='Define the CoordinationNumber of the aggregate'),
                    ),
                 ),
                 Consigne = SIMP(statut="o", homo="information", typ="TXM", defaut='Describe contituent particles if needed'),
                 ParticleCOnstituentProperties=FACT( statut='f', max='**',
                   name  = SIMP(statut='o', typ='TXM'),
                   numberOfPrimaryParticle = SIMP(statut='o', typ='I'),
                   Weight = FACT(statut = 'o',ang='Define the weight of particles (either through a mass or a density). ',
                       Consigne = SIMP(statut="o", homo="information", typ="TXM", defaut='Choose between Mass or Density'),          
                       Mass = SIMP(statut='f', typ ='R', val_min = 0,ang='Define the mass of the particle (in kg).'),
                       Density = SIMP(statut='f', typ ='R', val_min = 0, ang='Define the density of the particle (in kg/m^3).'),
                    ),
                 ),
              ), # blocAgregateCoarseGrainedDescription


                 #Consigne = SIMP(statut="o", homo="information", typ="TXM", defaut='Choose optional properties'),
                 #NumberOfPrimaryParticle = SIMP(statut ='f',typ='I', ang='Define the fractal dimension of the aggregate'),
                 #EquivalentRadius        = SIMP(statut='f', typ='R', ang='Define the equivalent radius of the aggregate (in m)'),
             ), # b_SolidAggregate
	), # blocTypeDPSolid
#      --------------- Bio Organism  ------------------ 
       blocTypeBioSolid    = BLOC(condition='TypeOfDiscreteParticle == "Bio Organism"',
           TypeOfOrganism  = SIMP(statut='o', typ='TXM', into=['Unicellular', 'Multicellular'], ang='Choose the type of bio-organism. \n Current choice includes Unicellular (i.e. indivisible elements) or Multicellular (i.e. composed of several elements) organisms.'),
           blocUnicellular = BLOC(condition ='TypeOfOrganism=="Unicellular"',
              Unicellular  = SIMP(statut='o', typ='TXM', into=["Bacteria"], defaut='Bacteria', ang='Choose the type of unicellular organism.\n Current choice includes Bacteria.')
             ),
            b_Multicellular = BLOC(condition ='TypeOfOrganism=="Multicellular"',
              Multicellular = SIMP(statut='o', typ='TXM', into=["Animal","Fungus","Plant"], ang='Choose the type of multicellular organism.\n Current choice includes Animal, Fungus and Plant.')
             ),
       ), # b_TypeBio_Solid

       blocNonAggreaat  = BLOC(condition ='TypeOfDiscreteParticle != "Solid" or PrimaryOrAggregate != "Assemblage / Aggregate"' ,
#      ---------------  Particule Properties ------------------ 
          Properties = FACT(statut ='o', ang='Define the properties of particles',
             Geometry   = SIMP(statut='o', typ='TXM', into=['Sphere', 'Ellipsoids', 'Other Shape'], ang='Choose the shape of particles. \n Current choice includes Sphere, Ellipsoids and Other Shapes.'),
             b_geom_Sphere = BLOC(condition = 'Geometry == "Sphere"',
                ReferenceParticleRadius = SIMP(statut='o', typ ='R', val_min = 0, ang='Define a reference particle radius (in m).'),
             ),
             Weight = FACT(statut = 'o',ang='Define the weight of particles (either through a mass or a density). ',
                Consigne = SIMP(statut="o", homo="information", typ="TXM", defaut='Choose between Mass or Density'),          
                Mass = SIMP(statut='f', typ ='R', val_min = 0,ang='Define the mass of the particle (in kg).'),
                Density = SIMP(statut='f', typ ='R', val_min = 0, ang='Define the density of the particle (in kg/m^3).'),
             ),
             Mechanical = SIMP(statut='o', typ='TXM', into=['Rigid', 'Flexible', 'Deformable'],ang='Choose the type of mechanical properties for particles. \n Current choice includes Rigid, Flexible and Deformable bodies.'),
          ElectroMagnetic = FACT(statut = 'f',
              ElectricCharge     = SIMP(statut='o', typ='R', ang='Define the electric charge of the aggregate (in Coulomb).'),
              MagneticMoment     = SIMP(statut='o', typ='R', ang='Define the magnetic moment of the aggregate (in A.m^2)'),
           ),
          ), # Properties
        ),# fin b_NonAgregate
     ), # b_Discrete
   ) # fin Particle

#---------------------------------
def prepareContactPhenomena(): 
#---------------------------------
    return  FACT(statut='o', max= "**",
       withContactPhenomena = SIMP(statut='o', typ=bool, defaut=False, ang='Activate contact forces between particles (i.e. inter-particle collision).'),
       bwithContact = BLOC(condition = 'withContactPhenomena == True',
        LevelOfDescription = SIMP(statut='o', typ='TXM', into=[ 'Microscopic', 'Macroscopic'], ang='Choose the level of description of contact forces between particles. \n Current choice includes Microscopic descriptions (with precise contact forces) and Macroscopic descriptions (at the continuum level).'),
        bMicroscopic = BLOC(condition = 'LevelOfDescription == "Microscopic"',
            DescriptionOfContact = SIMP(statut='o', typ='TXM', into=[ 'Contact distance (cutoff)', 'Adhesion theories'], ang='Choose how contact forces are described. \n Current choice includes Contact distance (i.e. force calculated with a cutoff distance) or Adhesion theories (e.g. JKR or DMT theories).'),
        ),
        bMacroscopic = BLOC(condition = 'LevelOfDescription == "Macroscopic"',
            OutcomeOfContact = SIMP(statut='o', typ='TXM', into=[ 'Sticky collision','Elastic collision','Inelastic collision', 'Mixed collisional event'], ang='Choose the macroscopic model for inter-particle contact. \n Current choice includes Sticky collisions (i.e. particles are stuck), Elastic collisions (i.e. rebound) or Inelastic collisions (i.e. rebound without energy conservation) or Mixed collisional events.'),
        ),
        TreatmentOfCollisions = SIMP(statut='o', typ='TXM', into=[ 'No collision', 'Binary/multiple particle collisions', 'Collision-induced fragmentation'], fenetreIhm = 'menuDeroulant', defaut = 'No collision', ang='Choose the treatment for the inter-particle collision. \n Current choice includes No collision (i.e. particles do not see each other), Binary/Multiple collision (i.e. with two or more particles) or Collision-induced fragmentation (i.e. breakup of the particle)'),
     ), #bwithActions
    )#FACT

#---------------------------------
def prepareContactPhenomenaWall(): 
#---------------------------------
    return  FACT(statut='o', max= "**",
       withContactPhenomena = SIMP(statut='o', typ=bool, defaut=False, ang='Activate contact forces between particle and wall (i.e. collision with a surface).'),
       bwithContact = BLOC(condition = 'withContactPhenomena == True',
        LevelOfDescription = SIMP(statut='o', typ='TXM', into=[ 'Microscopic', 'Macroscopic'], ang='Choose the level of description of contact forces between particles and surfaces. \n Current choice includes Microscopic descriptions (with precise contact forces) and Macroscopic descriptions (at the continuum level).'),
        bMicroscopic = BLOC(condition = 'LevelOfDescription == "Microscopic"',
            DescriptionOfContact = SIMP(statut='o', typ='TXM', into=[ 'Contact distance (cutoff)', 'Adhesion theories'], ang='Choose how particle-surface contact forces are described. \n Current choice includes Contact distance (i.e. force calculated with a cutoff distance) or Adhesion theories (e.g. JKR or DMT theories).'),
        ),
        bMacroscopic = BLOC(condition = 'LevelOfDescription == "Macroscopic"',
            OutcomeOfContact = SIMP(statut='o', typ='TXM', into=[ 'Sticky collision','Elastic collision','Inelastic collision', 'Mixed collisional event'], ang='Choose the macroscopic model for particle-surface contact. \n Current choice includes Sticky collisions (i.e. particle stick/deposit on surfaces), Elastic collisions (i.e. rebound) or Inelastic collisions (i.e. rebound without energy conservation) or Mixed collisional events.'),
        ),
     ), #bwithActions
    )#FACT

#---------------------------------
def prepareActionsAtDistance(): 
#---------------------------------
    return  FACT(statut='o', max= "**",
       withActionsAtDistance = SIMP(statut='o', typ=bool, defaut=False, ang='Activate short- and long- range inter-particle forces.'),
       bwithActions = BLOC(condition = 'withActionsAtDistance == True',
        TypeOfActionAtDistance = SIMP(statut='o', typ='TXM', into=[ 'electro_magnetic', 'Inter-surface forces', 'Fluid-like forces','Fluid-mediated forces',  'Biological forces','Radiative Effects'],  position='global',fenetreIhm='menuDeroulant', ang='Choose the type of short- or long-range inter-particle force. \n Current choice includes Electro-Magnetic forces, Inter-surface forces (e.g. van der Waals or Lennard-Jones forces), Fluid-like forces (for fluid particles only), Fluid-mediated forces (e.g. capillary forces, hydrophilic/hydrophobic, electrostatic double-layer forces), Biological forces, Radiative effects.'),

          blocElec = BLOC(condition = 'TypeOfActionAtDistance == "electro_magnetic"',
               Permittivity  = SIMP(statut='o', typ='R', ang='Define the particle relative permittivity'),
               Magnetic      = SIMP(statut='o', typ=bool, defaut=False, ang='Activate magnetic forces'),
               blocMagnetic = BLOC(condition = 'Magnetic == True',
                   Permeability = SIMP(statut='o', typ='R', ang='Define the particle permeability (in H/m)'),
               ), # bloc_magnetic
               Consigne = SIMP(statut="o", homo="information", typ="TXM", defaut='Enter ElectricCharge for Particle'),
               # Creation PN activation ElectricCharge
           ),# fin bloc_elec

           blocInterSurface = BLOC(condition = 'TypeOfActionAtDistance == "Inter-surface forces"',
              TypeInterSurfaceForce = SIMP(statut='o', typ='TXM', into = [ 'Lennard_Jones', 'Steric', 'Soft_Potential','van der Waals'], ang='Choose the type of inter-surface forces between particles. \n Current choice includes Lennard-Jones, Steric, van der Waals or Soft-potential forces.'),
              blocvanderWaals     = BLOC(condition = "TypeInterSurfaceForce == 'van der Waals'",
                 HamakerConstant  = SIMP(statut='o', typ='R', val_min=0, ang='Define the Hamaker constant between bodies (in J).'),
              ),
              blocLennard = BLOC(condition = "TypeInterSurfaceForce == 'Lennard_Jones'",
                 LennardJonesRadius       = SIMP(statut='o', typ='R', val_min=0, ang='Define the Lennard-Jones cut-off radius (in m).'),
                 DepthOfThePotentialWell  = SIMP(statut='o', typ='R', val_min=0, ang='Define the Lennard-Jones potential well (in J).'),
              ), # fin b_Lennard

              blocParamSoftPotential = BLOC(condition = "TypeInterSurfaceForce == 'Soft_Potential'",
                 GrootWarrenRepulsion = SIMP(statut='o', typ='R', defaut=25.0, val_min=0, ang='Define the maximum repulsion.'),
                 GrootWarrenCutoff    = SIMP(statut='o', typ='R', defaut=1.0, val_min=0, ang='Define the cut-off distance fro repulsion.'),
                 DragCoefficient      = SIMP(statut='o', typ='R', defaut=4.5, val_min=0, ang='Define the drag coefficient in the dissipative force.'),
                 DragForceCutoff      = SIMP(statut='o', typ='R', defaut=1.0, val_min=0, ang='Define cut-off distance for the dissipative and random forces.'),
              ), # b_Param_Soft_Potential
              # blocParamSoftPotentialOrLennard = BLOC(condition = "TypeInterSurfaceForce == 'Soft_Potential' or TypeInterSurfaceForce == 'Lennard_Jones'",
              #    ParticlesPairs       = SIMP(statut='o', max=2, typ=userParticle, ang='Choose the pair of particles involved.\n Requires at least one particle in the Classical Particle System.'),
              # ), # b_Param_Soft_PotentialOrLennard
              ParticlesPairs       = SIMP(statut='o', max=2, typ=userParticle, ang='Choose the pair of particles involved.\n Requires at least one particle in the Classical Particle System.'),
        ), # bloc_VdW
             
       ) # fin bloc 
       ) # fin prepareActionsAtADistance

#---------------------------------
def prepareActionsAtDistanceForWall(): 
#---------------------------------
    return  FACT(statut='o', max= "**",
       withActionsAtDistance = SIMP(statut='o', typ=bool, defaut=False, ang='Activate short- and long- range particle-wall forces.'),
       bwithActions = BLOC(condition = 'withActionsAtDistance == True',
        TypeOfActionAtDistance = SIMP(statut='o', typ='TXM', into=[ 'electro_magnetic', 'Inter-surface forces', 'Fluid-like forces','Fluid-mediated forces',  'Biological forces','Radiative Effects'],  position='global',fenetreIhm='menuDeroulant', ang='Choose the type of short- or long-range particle-wall force. \n Current choice includes Electro-Magnetic forces, Inter-surface forces (e.g. van der Waals or Lennard-Jones forces), Fluid-like forces (for fluid particles only), Fluid-mediated forces (e.g. capillary forces, hydrophilic/hydrophobic, electrostatic double-layer forces), Biological forces, Radiative effects.'),

          blocElec = BLOC(condition = 'TypeOfActionAtDistance == "electro_magnetic"',
               Permittivity  = SIMP(statut='o', typ='R', ang='Define the particle relative permittivity'),
               Magnetic      = SIMP(statut='o', typ=bool, defaut=False, ang='Activate magnetic forces'),
               blocMagnetic = BLOC(condition = 'Magnetic == True',
                   Permeability = SIMP(statut='o', typ='R', ang='Define the particle permeability (in H/m)'),
               ), # bloc_magnetic
               # Creation PN activation ElectricCharge
           ),# fin bloc_elec

          blocInterSurface = BLOC(condition = 'TypeOfActionAtDistance == "Inter-surface forces"',
              TypeInterSurfaceForce = SIMP(statut='o', typ='TXM', into = [ 'Lennard_Jones', 'Steric', 'Soft_Potential','van der Waals'], ang='Choose the type of inter-surface forces between particles and walls. \n Current choice includes Lennard-Jones, Steric, van der Waals or Soft-potential forces.'),
              blocvanderWaals     = BLOC(condition = "TypeInterSurfaceForce == 'van der Waals'",
                 HamakerConstant  = SIMP(statut='o', typ='R', val_min=0, ang='Define the Hamaker constant between bodies (in J).'),
              ),
              blocLennard = BLOC(condition = "TypeInterSurfaceForce == 'Lennard_Jones'",
                 LennardJonesRadius       = SIMP(statut='o', typ='R', val_min=0, ang='Define the Lennard-Jones cut-off radius (in m).'),
                 DepthOfThePotentialWell  = SIMP(statut='o', typ='R', val_min=0, ang='Define the Lennard-Jones potential well (in J).'),
              ), # fin b_Lennard

              blocParamSoftPotential = BLOC(condition = "TypeInterSurfaceForce == 'Soft_Potential'",
                 GrootWarrenRepulsion = SIMP(statut='o', typ='R', defaut=25.0, val_min=0, ang='Define the maximum repulsion.'),
                 GrootWarrenCutoff    = SIMP(statut='o', typ='R', defaut=1.0, val_min=0, ang='Define the cut-off distance fro repulsion.'),
                 DragCoefficient      = SIMP(statut='o', typ='R', defaut=4.5, val_min=0, ang='Define the drag coefficient in the dissipative force.'),
                 DragForceCutoff      = SIMP(statut='o', typ='R', defaut=1.0, val_min=0, ang='Define cut-off distance for the dissipative and random forces.'),
              ), # b_Param_Soft_Potential
        ), # bloc_VdW
             
        blocActionChoisie = BLOC (condition = 'TypeOfActionAtDistance !=None ',
           LevelOfDescriptionNearWalls= SIMP(statut='o', typ='TXM', into =('Full force-distance curve', 'Simplified treatment'),ang='CH1Stcomment\ntest\t espace'),
           blocSimplifed = BLOC (condition = 'LevelOfDescriptionNearWalls == "Simplified treatment" ',
              TypeOfSimplifiedTreatment =SIMP(statut='o', typ='TXM', into =('Energy-based Wall Model',)
           ),
          ),
        ) # fin blocActionChoisie 
       ) # fin bloc 
       ) # fin prepareActionsAtADistanceForWall

#--------------------------------------------
def prepareBondedInteractions(fromWall=False):
#---------------------------------
  intoHorsWall=[ 'Bond stretching', 'Angle bending', 'Torsional motion', 'Frozen or collective motion',]
  intoWall=[ 'Bond stretching', 'Angle bending', 'Torsional motion', 'Frozen or collective motion','Contact mechanics']
  if fromWall : 
     mesInto=intoWall
     #monBondedParticles = SIMP(statut='o', typ='TXM', defaut='True', into=['True',]) #PNPN
     monBondedParticles = SIMP(statut='o', typ=bool, defaut=1, ang='Activate bonded interactions between particles and walls.')
  else        : 
     mesInto=intoHorsWall
     monBondedParticles = SIMP(statut='o', typ=bool, defaut=False, ang='Activate bonded interactions between particles.')
 
  return FACT(statut='o', max = "**",
       BondedParticles = monBondedParticles,
       blocBonded = BLOC(condition = 'BondedParticles == True',
       DescribedWithTopologyFile = SIMP(statut='o', typ=bool, defaut=False, ang='Activate description with a topology file (otherwise, user-defined in the CDM).'),
       blocTopologyFile = BLOC (condition = 'DescribedWithTopologyFile == True',
           TopologyFile =SIMP(statut='o', typ=('Fichier', " Files (*.pdb );;All Files (*)",'Sauvegarde')),
       ),
       blocNoTopologyFile = BLOC (condition = 'DescribedWithTopologyFile == False',
           BondedInteraction = FACT (statut ='o', max ='**',
               NatureOfBondedInteraction = SIMP(statut='o', typ='TXM', into= mesInto, intoXSD = intoWall,ang='Choose the nature of bonded-interactions. \n Current choice includes bond-stretching, angle bending, torsional motion and frozen/collective motion.'),
               bBondStretching = BLOC ( condition = 'NatureOfBondedInteraction == "Bond stretching"',
                  TypeOfBondStretching = SIMP(statut='o', typ='TXM', into=[ 'Bond harmonic potential', 'FENE',],ang='Choose the type of bond stretching force. \n Current choice includes Bond harmonic potential or FENE model (Finitely-Extensible Non-linear Elastic).'),
#    ------------ FENE  ------------------ 
                   blocFENE = BLOC(condition = 'TypeOfBondStretching == "FENE"',
                     FENEParameters = FACT(statut='o', max="**",
                        SpringConstant_H = SIMP(statut='o', typ='R', val_min=0, ang='Define the value of the spring constant for the FENE model.'),
                        LMax             = SIMP(statut='o', typ='R', val_min=0, ang='Define the value of the maximal extension for the FENE model.'),
                        ListOfBondedParticles = SIMP(statut='o', max='**',  typ = Tuple(2), validators=VerifTypeTuple(('I','I'),),ang='Define the list of bonded particles (loop on particle pairs).'),
                    ), # fin FENE_Parameters
                   ), # fin blocFENE
#    ------------ Harmonic potential Parameters  ------------------ 
                   blocharmonic = BLOC(condition = 'TypeOfBondStretching == "Bond harmonic potential"',
                     BondHarmonicParameters = FACT(statut='o', max="**",
                        ListOfBondedParticles = SIMP(statut='o', max='**',  typ = Tuple(2), validators=VerifTypeTuple(('I','I'),),ang='Define the list of bonded particles (loop on particle pairs).'),
                    ), # fin BondHarmonicParameters
                   ), # fin blocharmonic
               ), # fin bBondStretching
           #TypeOfBondedInteraction = SIMP(statut='o', typ='TXM', into=[ 'Covalent Bond Length', 'FENE', 'Covalent Bond Angle', 'Dihedral Angles', 'Improper Dihedral ou Torsonial Motion ?', 'Frozen Motion', 'Angle bending'  ], defaut='NoOne'),

         #PNPN 114
           #La saisie de l'ensemble des liaisons d'un meme type peut se faire ds le meme bloc (soit ds un fichier, soit manuelle)
           #Une seule valeur de distante? est a saisir pour l'ensemble

#    ------------ Covalent Bond Length ------------------ 
          # blocCovalentLength = BLOC(condition = 'TypeOfBondedInteraction == "Covalent Bond Length"',
          #    InteractionLengthParameters = FACT(statut='o', max="**",
          #        SpringStifness          = SIMP(statut='o', typ='R', val_min=0),
          #        MeanBondLength          = SIMP(statut='o', typ='R', val_min=0),
          #        ListOfBondedParticles = SIMP(statut='o', max='**',  typ = Tuple(2), validators=VerifTypeTuple(('I','I'),)),
          #      ), # fin Interation_Length_Parameters 
          # ), # fin BondLengthParameters

#    ------------ Covalent Bond Angle ------------------ 
          # blocCovalentAngle = BLOC(condition = 'TypeOfBondedInteraction == "Covalent Bond Angle"',
          #    InteractionAnglesParameters = FACT(statut='o', max="**",
          #        ApplyToBondedParticles  = SIMP(statut='o', max='**', typ='TXM'),
          #        SpringStifness          = SIMP(statut='o', typ='R', val_min=0),
          #        MeanBondAngle           = SIMP(statut='o', typ='R', val_min=0),
          #        ListOfBondedParticles = SIMP(statut='o', max='**',  typ = Tuple(2), validators=VerifTypeTuple(('I','I'),)),
          #    ), # fin Interation_Angles_Parameters 
          # ), # fin bloccovalentlengthand_angle



#    ------------ Dihedral Angles  ------------------ 
          # blocDihedral = BLOC(condition = 'TypeOfBondedInteraction == "Dihedral Angles"',
          #    DihedralAnglesQueDemandeTon = SIMP(statut='o', typ='TXM'),
          # ),

#    ------------ Improper Dihedral  ------------------ 
          # blocImproperDihedral = BLOC(condition = 'TypeOfBondedInteraction == "Improper Dihedral"',
          #    ImproperDihedralQueDemandeTon = SIMP(statut='o', typ='TXM'),
          # ),
          # blocFrozen = BLOC(condition = 'TypeOfBondedInteraction == "Frozen Motion"',
          #    FrozenQueDemandeTon = SIMP(statut='o', typ='TXM'),
          # ),
       )# fin bondedInteraction
        ), # blocNoTopology
      ), # blocBondedInteractop,
    ) #  fin Bonded_Interaction         

#---------------------------------
def prepareBlocOrigine(condition):
#---------------------------------
   return BLOC(condition = condition,
       Origin = FACT(statut ='o',
         OriginType = SIMP(statut='o', into =['ByValue', 'ByFile', 'ByInteraction'], typ ='TXM', defaut='ByValue',ang='Choose the origin of the variable. \n Current choice includes by Value (user-given), by File or by Interaction (i.e. with another component).'),
         blocByFile  = creeBlocPourLesFichiers('OrigineType == "ByFile"', '', ListeFormats = listeFormatGenerique, FieldName='FieldName'),
         blocByInteraction = BLOC(condition = 'InitialisationType == "ByInteraction"',
           InteractionName = SIMP(typ=interaction,statut='o'),
           Consigne = SIMP(statut="o", homo="information", typ="TXM", defaut='Create and choose suitable interaction'),
         ),
         blocByValue = BLOC(condition = 'OriginType == "ByValue"',
           ConstantValue = SIMP (statut ='o', typ='R',ang='Define the value of the variable.'),
        ),
      ),
   )
#----------------------------------------
def prepareBlocInitialisation(condition):
#----------------------------------------
   monIntoType = ['ByValue', 'ByFile', 'ByInteraction']
   return BLOC(condition = condition,
       Initialisation = FACT(statut ='o',
         InitialisationType = SIMP(statut='o', into = monIntoType, typ ='TXM', defaut='ByValue',ang='Choose the type of initialization of the variable. \n Current choice includes by Value (user-given).'),
         blocByFile = creeBlocPourLesFichiers('InitialisationType == "ByFile"', '', ListeFormats = listeFormatGenerique, FieldName='FieldName'),
         blocByInteraction = BLOC(condition = 'InitialisationType == "ByInteraction"',
           InteractionName = SIMP(typ=interaction,statut='o'),
           Consigne = SIMP(statut="o", homo="information", typ="TXM", defaut='Create and choose suitable interaction'),
         ),
         blocByValue = BLOC(condition = 'InitialisationType == "ByValue"',
           Value = SIMP (statut ='o', typ='R',ang='Define the initial value of the variable.'),
        ),
       ),
       SourceTerm     = SIMP(typ=bool, statut='o', defaut=False),
       blocSourceTerm = prepareTermeSource('SourceTerm==True'),
     ) #blocSimulatedPressure

#-----------------------------------------------------------------
def prepareBlocInitialisationParticle(condition, termeSource=True):
#-----------------------------------------------------------------
   monIntoType = ['ByValue', 'ByFile', 'ByInteraction','Not needed' ]
   #dicoTermeSource = {}
   #if termeSource : 
   #    dicoTermeSource['SourceTerm']     = SIMP(typ=bool, statut='o', defaut=False),
   #    dicoTermeSource['blocSourceTerm'] = prepareTermeSourceParticle('SourceTerm==True')

   if termeSource  : 
    return BLOC(condition = condition,
       Initialisation = FACT(statut ='o',ang='Define how the state variable is initialized',
         InitialisationType = SIMP(statut='o', into =monIntoType, typ ='TXM', defaut='ByValue',ang='Choose the type of initialization. \n Current choice includes by Value (provided by the user), by File, by Interaction (with another component) or Not needed.'),
         blocNotNeeded = BLOC(condition = 'InitialisationType != "Not needed"',
            ParticleIdentifier=SIMP(statut='o', typ = userParticle,ang='Choose on which types of particles the initialization applies.\n Requires the definition of particles in the Classical Particle System.'),
         ),
         blocByFile = creeBlocPourLesFichiers('InitialisationType == "ByFile"', '', ListeFormats = listeFormatGenerique, FieldName='FieldName'),
         blocByInteraction = BLOC(condition = 'InitialisationType == "ByInteraction"',
           InteractionName = SIMP(typ=interaction,statut='o',ang='Choose the component for the interaction.\n Requires another component in the CDM.'),
           Consigne = SIMP(statut="o", homo="information", typ="TXM", defaut='Create and choose suitable interaction'),
         ),
         blocByValue = BLOC(condition = 'InitialisationType == "ByValue"',
           Value = SIMP (statut ='o', typ='R',ang='Define the initial value'),
        ),
        SourceTerm     = SIMP(typ=bool, statut='o', defaut=False,ang='Activate a source term for the variable.'),
        blocSourceTerm = prepareTermeSourceParticle('SourceTerm==True')
       ),
     ) #
   else:
    return BLOC(condition = condition,
       Initialisation = FACT(statut ='o',ang='Define how the state variable is initialized',
         InitialisationType = SIMP(statut='o', into =monIntoType, typ ='TXM', defaut='ByValue',ang='Choose the type of initialization. \n Current choice includes by Value (provided by the user), by File, by Interaction (with another component) or Not needed.'),
         blocNotNeeded = BLOC(condition = 'InitialisationType != "Not needed"',
            ParticleIdentifier=SIMP(statut='o', typ = userParticle,ang='Choose on which types of particles the initialization applies.\n Requires the definition of particles in the Classical Particle System.'),
         ),
         blocByFile = creeBlocPourLesFichiers('InitialisationType == "ByFile"', '', ListeFormats = listeFormatGenerique, FieldName='FieldName'),
         blocByInteraction = BLOC(condition = 'InitialisationType == "ByInteraction"',
           InteractionName = SIMP(typ=interaction,statut='o',ang='Choose the component for the interaction.\n Requires another component in the CDM.'),
           Consigne = SIMP(statut="o", homo="information", typ="TXM", defaut='Create and choose suitable interaction'),
         ),
         blocByValue = BLOC(condition = 'InitialisationType == "ByValue"',
           Value = SIMP (statut ='o', typ='R',ang='Define the initial value'),
         ),
       ),
     ) #

#---------------------------
def prepareBlocFluideMacro():
#---------------------------
   return BLOC(condition = 'SystemType == "Continuum system"',
     ComplexFluid = SIMP(typ=bool,  statut='o', defaut = False, position='global',ang='Activate the description of complex fluids (e.g. polymeric fluid, emulsions).'),
     FlowNature   = SIMP(typ='TXM', statut='o', into =['Laminar', 'Turbulent'], position='global',ang='Choose the nature of the flow. \n Current choice includes Laminar or Turbulent flow.'),

#    --------------------------- Density -------------
     DensityInitialisation = FACT(statut ='o',ang='Initialize the fluid density properties',
        DensityValueType   = SIMP(typ='TXM', statut ='o', into  = ['Value', 'Field'], defaut ='Value',ang='Choose the type of initialization for the fluid density. \n Current choice includes by Value of by Field.'),
        blocDensityValue   = BLOC(condition = 'DensityValueType == "Value"',
            Density = SIMP(typ='R', statut ='o',ang='Define the value of the initial fluid density (in kg/m^3).'),
        ),
        blocDensField= creeBlocPourLesFichiers('DensityValueType == "Field"', 'Density', ListeFormats=listeFormatGenerique, FieldName='DensityFieldName'),
     ),# DensityInitialisation

#    --------------------------- Viscosity -------------
     ViscosityInitialisation = FACT(statut ='o',ang='Initialize the fluid viscosity properties',
        ViscosityValueType   = SIMP(typ='TXM', statut ='o', into  = ['Value', 'Field'], defaut ='Value',ang='Choose the type of initialization for the fluid viscosity. \n Current choice includes by Value of by Field.'),
        blocViscosityValue   = BLOC(condition = 'ViscosityValueType == "Value"',
            Viscosity        = SIMP(typ='R', statut ='o',ang='Define the value of the initial fluid dynamic viscosity (in m^2/s).'),
        ),
        blocViscosityField = creeBlocPourLesFichiers('ViscosityValueType == "Field"', 'Viscosity', ListeFormats=listeFormatGenerique, FieldName='ViscosityFieldName'),
     ), #fin ViscosityityInitialisation

#    --------------------------- Turbulent  -------------
     blocFlowNatureTurbulent = BLOC(condition = ' FlowNature == "Turbulent"',
        TurbulenceForFlowDynamics = prepareFactTurbulence('o',position='global',positionChoice='reCalculeEtape'), 
     ), #fin bloc_FlowNature_Turbulent

     DynamicalVariables = FACT(statut ='o',ang='Define the dynamical variables inherent to the component (e.g. pressure, velocity and other turbulent variables).',
         VariablesSimulation = SIMP(statut='o', typ =bool, position='global',ang='Activate the simulation of dynamic variables.'),
         blocVariablesSimulation = BLOC(condition = 'VariablesSimulation == False',
           OriginOfDynamicalVariables = SIMP(statut='o', into =['Given', 'Interaction'], typ ='TXM', position='global'),
           blocGivenOrInteraction = BLOC(condition = 'OriginOfDynamicalVariables in ["Given", "Interaction",]',
             SteadyState = SIMP(typ=bool, statut ='o', defaut = True, position = 'global'),
             # blocNotSteady = BLOC(condition = 'SteadyState == False',
             # blocConsigne = BLOC(condition = 'SteadyState == False',
             #   Consigne = SIMP(statut="o", homo="information", typ="TXM", defaut='Not implemented yet. Will ask for a range of calculation steps.'),
             # ), #blocNotSteady                                       
             blocSteady = BLOC(condition = 'SteadyState == True',
              blocGiven = BLOC(condition = 'OriginOfDynamicalVariables == "Given"',
                InSameFile   = SIMP(typ=bool, statut ='o', defaut = True, position = 'reCalculeEtape'),
                blocSameFile = creeBlocPourLesFichiers('InSameFile == True', 'DynamicalVariables', ('Med', 'cgns' ), None),
              ), #blocGiven
             ),  #blocSteady
           ), #blocGivenOrInteraction
         ),
       PressureDefinition = FACT(statut ='o',ang='Define the fluid pressure (initialization and source term)',
           Pressure  = SIMP(typ=(dynamicVariable,'createObject'), statut='o', defaut ='Pressure', homo='constant'),
           blocSteadyState = BLOC(condition = 'SteadyState == True',
             blocFluidInSame = creeBlocPourLesFichiers('InSameFile == False', 'Pressure', ('Med', 'cgns' ), None),
             blocGivenPressure    = BLOC(condition = 'OriginOfDynamicalVariables == "Given"',
                PressureFieldName = SIMP(typ='TXM',statut='o'),
             ),
             blocInteractionPressure    = BLOC(condition = 'OriginOfDynamicalVariables == "Interaction"',
                InteractionName = SIMP(typ=interaction,statut='o'),
                Consigne = SIMP(statut="o", homo="information", typ="TXM", defaut='Create and choose suitable interaction'),
             ),
           ),
           blocSimulatedPressure    = prepareBlocInitialisation(condition = 'VariablesSimulation == True'),
       ),
       VelocityDefinition = FACT(statut ='o',ang='Define the fluid velocity (initialization and source term)',
          blocFlowNatureTurbulent        = BLOC(condition = 'FlowNature == "Turbulent"',
             #sousBlocFlowNatureTurbulent = BLOC(condition = 'TurbulenceModellingType != "Fully resolved (DNS)"',
               AverageVelocity           = SIMP(typ=(dynamicVariable,'createObject'), statut='o', defaut ='Average_Velocity', homo='constant'),
               blocSteadyGivenVelocity1        = BLOC(condition = 'OriginOfDynamicalVariables == "Given" and SteadyState == True ',
                   AverageVelocityValue  = SIMP(typ='R', statut='o' ),
               ),
             #),
          ),
          #blocFlowNatureLaminar     = BLOC(condition = ' FlowNature == "Laminar" or TurbulenceModellingType == "Fully resolved (DNS)"',
          blocFlowNatureLaminar     = BLOC(condition = 'FlowNature == "Laminar"',
              FluidVelocity         = SIMP(typ=(dynamicVariable,'createObject'), statut='o', defaut ='Fluid_Velocity', homo='constant'),
              blocSteady = BLOC(condition = 'SteadyState == True',
                blocVelocityInSame    = creeBlocPourLesFichiers('InSameFile == False', 'Velocity', ('Med', 'cgns' ), None),
                blocSteadyGivenVelocity2    = BLOC(condition = 'OriginOfDynamicalVariables == "Given"',
                    VelocityFieldName = SIMP(typ='TXM',statut='o'),
                ),
              ),
          ),
          blocSteady = BLOC(condition = 'SteadyState == True',
            blocInteractionVelocity    = BLOC(condition = 'OriginOfDynamicalVariables == "Interaction"',
               InteractionName = SIMP(typ=interaction,statut='o'),
               Consigne = SIMP(statut="o", homo="information", typ="TXM", defaut='Create and choose suitable interaction'),
            ),
          ),
          blocSimulatedVelocity    = prepareBlocInitialisation(condition = 'VariablesSimulation == True'),
       ),
       BFlowNatureTurbulent = BLOC(condition ='FlowNature == "Turbulent"',
       # K-epislon ou k-omega
            blocTurbulenceTWMChoice1 = BLOC(condition = 'TVMChoice == "K-Epsilon" or TVMChoice == "K-Omega"',
              KDefinition   = FACT(statut ='o',ang='Define the fluid turbulent kinetic energy "k" (initialization and source term)',
                Name        = SIMP(typ=(scalar,'createObject'), statut='o', defaut ='K', homo='constant'),
                blocSteady = BLOC(condition = 'SteadyState == True',
                  blocKInSame = creeBlocPourLesFichiers('InSameFile == False', 'K', ('Med', 'cgns' ), None),
                  blocKGiven  = BLOC(condition = 'OriginOfDynamicalVariables == "Given"',
                     KFieldName = SIMP(typ='TXM',statut='o', defaut='K'),
                  ),
                  blocKInteraction    = BLOC(condition = 'OriginOfDynamicalVariables == "Interaction"',
                  InteractionName = SIMP(typ=interaction,statut='o'),
                  Consigne = SIMP(statut="o", homo="information", typ="TXM", defaut='Create and choose suitable interaction'),
                  ),
                ),
                blocSimulatedKDefinition = prepareBlocInitialisation(condition = 'VariablesSimulation == True'),
              ), # KDefinition
            ),# fin blocTurbulenceTWMChoice1

            # REM : L'existence des mc TVMChoice et RSMChoice est exclusive, du coup une évaluation de condition
            # qui contient les deux renvoie forcément une exception, le bloc n'est alors pas evalué
            # sauf si le mc de la première condition existe (ordre évaluation du or)
            # blocTurbulenceTWMChoice2 = BLOC(condition = 'TVMChoice == "K-Epsilon" or RSMChoice != None',
            # blocTurbulenceTWMChoice2 = BLOC(condition = '(RSMChoice != None) or (TVMChoice == "K-Epsilon")',
            # blocTurbulenceTWMChoice2 = BLOC(condition = 'TVMChoice == "K-Epsilon"',
            blocTurbulenceTWMChoice2 = BLOC(condition = 'RANSModel == "Reynolds Stress Model (RSM)" or TVMChoice == "K-Epsilon"',
              EpsilonDefinition   = FACT(statut ='o',ang='Define the fluid turbulent kinetic energy "Epsilon" (initialization and source term)',
                Name              = SIMP(typ=(scalar,'createObject'), statut='o', defaut ='Epsilon', homo='constant'),
                blocSteady = BLOC(condition = 'SteadyState == True',
                  blocEpsilonInSame = creeBlocPourLesFichiers('InSameFile == False', 'Epsilon', ('Med', 'cgns' ), None),
                  blocEpsilonGiven  = BLOC(condition = 'OriginOfDynamicalVariables == "Given"',
                     EpsilonFieldName = SIMP(typ='TXM',statut='o'),
                  ),
                  blocEpsilonInteraction = BLOC(condition = 'OriginOfDynamicalVariables == "Interaction"',
                  InteractionName = SIMP(typ=interaction,statut='o'),
                  Consigne = SIMP(statut="o", homo="information", typ="TXM", defaut='Create and choose suitable interaction'),
                  ),                                  
                ),
                blocSimulatedEpsilonDefinition = prepareBlocInitialisation(condition = 'VariablesSimulation == True'),
              ), #EpsilonDefinition
            ), # bloc_Turbulence_TWMChoice2

            blocTurbulenceTWMChoice3 = BLOC(condition = 'TVMChoice == "K-Omega"',
             OmegaDefinition = FACT(statut ='o',ang='Define the fluid specific rate of dissipation "Omega" (initialization and source term)',
                Name              = SIMP(typ=(scalar,'createObject'), statut='o', defaut ='Omega', homo='constant'),
                blocSteady = BLOC(condition = 'SteadyState == True',
                  blocOmegaInSame   = creeBlocPourLesFichiers('InSameFile == False', 'Omega', ('Med', 'cgns' ), None),
                  blocOmegaGiven    = BLOC(condition = 'OriginOfDynamicalVariables == "Given"',
                     OmegaFieldName = SIMP(typ='TXM',statut='o'),
                  ),
                  blocOmegaInteraction = BLOC(condition = 'OriginOfDynamicalVariables == "Interaction"',
                  InteractionName = SIMP(typ=interaction,statut='o'),
                  Consigne = SIMP(statut="o", homo="information", typ="TXM", defaut='Create and choose suitable interaction'),
                  ),                                  
                ),
                blocSimulatedOmegaDefinition = prepareBlocInitialisation(condition = 'VariablesSimulation == True'),
             ),
            ), # blocTurbulenceTWMChoice3

            # blocTurbulenceRSMChoice1 = BLOC(condition = "(RANSModel == 'Reynolds Stress Model (RSM)') and (RSMChoice !=None)",
            blocTurbulenceRSMChoice1 = BLOC(condition = "RSMChoice !=None",
             RijDefinition = FACT(statut ='o',ang='Define the fluid Reynolds Stresses "Rij" (initialization and source term)',
                Name              = SIMP(typ=(scalar,'createObject'), statut='o', defaut ='Rij', homo='constant'),
                blocSteady = BLOC(condition = 'SteadyState == True',
                  blocRijInSame   = creeBlocPourLesFichiers('InSameFile == False', 'Rij', ('Med', 'cgns' ), None),
                  blocRijGiven    = BLOC(condition = 'OriginOfDynamicalVariables == "Given"',
                  RijFieldName    = SIMP(typ='TXM',statut='o'),
                  ),
                  blocRijInteraction = BLOC(condition = 'OriginOfDynamicalVariables == "Interaction"',
                  InteractionName = SIMP(typ=interaction,statut='o'),
                  Consigne = SIMP(statut="o", homo="information", typ="TXM", defaut='Create and choose suitable interaction'),
                  ),                                  
                ),
                blocSimulatedRijDefinition = prepareBlocInitialisation(condition = 'VariablesSimulation == True'),             
                ),             
            ), # blocTurbulenceRSMChoice1
          ), #BFlowNatureTurbulent
       ), # DynamicalVariables

# ---------------------- Effets thermiques
     Thermal = FACT(statut ='o',ang='Define the thermal properties of the component',
        ThermalEffects        = SIMP(typ='TXM', statut='o', into =['Non thermal', 'Thermal'] , defaut='Thermal', position='global' ,ang='Activate thermal effects on the component.'),
        blocNonThermalEffects = BLOC(condition = 'ThermalEffects == "Non thermal"',
            ReferenceTemperature = SIMP(typ='R', statut='o', val_min=0, ang='Define the reference temperature (in K)',),
        ), # fin bloc_NonThermal
        bloc_ThermalEffects_    = BLOC(condition = 'ThermalEffects == "Thermal"',
          ConductivityValueType = SIMP(typ='TXM', statut ='o', into  = ['Value', 'Field'], defaut ='Value',ang='Choose the type for conductivity. \n Current choice includes by Value or by Field.'),
          blocCondValue         = BLOC (condition = 'ConductivityValueType == "Value"',
              Conductivity = SIMP(typ='R', statut ='o',ang='Define the value of the conductivity (in kg.m^3/s^3/A^2)'),
           ),
          blocCondField = creeBlocPourLesFichiers('ConductivityValueType == "Field"', 'Conductivity', ListeFormats=listeFormatGenerique, FieldName='conductivityFieldName'),
          #ActiveOnFlowEffect = ActiveOnFlowEffect(),
        ),
    ),# fin Fact Thermal

# ---------------------- Scalaires

    blocScalarFluidTurbulentOrLaminar = BLOC(condition = "(ComplexFluid == False and FlowNature == 'Turbulent') or (ComplexFluid == False and FlowNature == 'Laminar')",
          Scalars = FACT(statut = 'o',ang='Define the scalars within the component (i.e. chemical species, temperature).',
              withScalars     = SIMP(statut='o', typ=bool, defaut=False,ang='Activate scalar within the component.'), 
              blocwithScalars = BLOC(condition = 'withScalars == True',
              blocFlowNatureTurbulentForScalars = BLOC(condition = ' FlowNature == "Turbulent"',
                   AsTurbulenceForFlowDynamics   = SIMP(statut='o', typ=bool, defaut=True,ang='Choose if the dynamics of scalars is the same as the dynamics of the turbulent flow (if not, define the turbulent dynamics for scalars).'),
                   blocAsTFFD = BLOC(condition  = "AsTurbulenceForFlowDynamics == False",
                        ScalarsTurbulenceModelling = prepareFactTurbulenceScalaire('o',),
                   ),
              ),
              blocThermalEffectsOn = BLOC(condition = ' ThermalEffects == "Thermal"',
               TemperatureScalar   = FACT(statut ='o',ang='Define scalar for temperature',
                   #Name       = SIMP(typ=(scalar,'createObject'), statut='o', defaut ='Temperature', homo='constant', position='reCalculeEtape'),
                   Name       = SIMP(typ=(scalar,'createObject'), statut='o', defaut ='Temperature', homo='constant'),
                   SourceTerm = SIMP(typ=bool, statut='o', defaut=False,ang='Activate source term for temperature scalar.'),
                   blocSourceTerm = prepareTermeSource('SourceTerm==True'),
                   TemperatureInitialisation = FACT(statut ='o',
                       OriginOfThermalFluxField = SIMP(statut='o', into =['Given', 'Interaction', 'to be simulated'], typ ='TXM',ang='Choose the origin of the thermal flux field. \n Current choice includes Given (by the user), by Interaction (with another component), or To be simulated (i.e. calculated by the component).'),
                       blocGiven = creeBlocPourLesFichiers('OriginOfThermalFluxField == "Given"', 'Temperature', ('Med', 'cgns' ), FieldName='FieldName'),
                    ),# fin TemperatureInitialisation
                ),# TemperatureScalar 
              ), # fin bloc_ThermalEffects_On
              Scalar = FACT(statut = 'o', max ='**',ang='Define scalar for the component',
                Name = SIMP(typ=(scalar,'createObject'), statut='o',),
                DiffusivityValueType = SIMP(typ='TXM', statut ='o', into  = ['Value', 'Field'], defaut ='Value',ang='Choose the type for diffusivity. \n Current choice includes by Value or by Field.'),
                blocDiffValue   = BLOC(condition = 'DiffusivityValueType == "Value"',
                    Diffusivity = SIMP(typ='R', statut ='o',ang='Define the value for the diffusivity (in m^2/s).'),
                ),
                blocDiffField = creeBlocPourLesFichiers('DiffusivityValueType == "Field"', 'Diffusivity', ListeFormats=listeFormatGenerique, FieldName='DiffusivityFieldName'),
                OriginOfScalar = SIMP(statut='o', into =['Given', 'Interaction', 'to be simulated'], typ ='TXM', defaut='to be simulated',ang='Choose the origin of the diffusivity field. \n Current choice includes Given (by the user), by Interaction (with another component), or To be simulated (i.e. calculated by the component).'),
                blocSimulatedScalar = BLOC(condition = 'OriginOfScalar == "to be simulated"',
                  SourceTerm = SIMP(typ=bool, statut='o', defaut=False,ang='Activate source terms for scalars.'),
                  blocSourceTerm = prepareTermeSource('SourceTerm==True'),
                  Initialisation = FACT(statut ='o',ang='Define the initialization for scalars',
                    InitialisationOfScalar = SIMP(statut='o', into =['ValueInit', 'FileInit', 'InteractionInit'], typ ='TXM', defaut='ValueInit',ang='Choose the initialization of scalars. \n Current choice includes by Value (i.e. by the user), by File or by Interaction (i.e. with another component).'),
                    blocFileInit = creeBlocPourLesFichiers('InitialisationOfScalar == "FileInit"', 'ScalarInit', ListeFormats = listeFormatGenerique, FieldName='ScalarInitField'),
                    blocInteractionInit    = BLOC(condition = 'InitialisationOfScalar == "InteractionInit"',
                      InteractionName = SIMP(typ=interaction,statut='o'),
                      Consigne = SIMP(statut="o", homo="information", typ="TXM", defaut='Create and choose suitable interaction'),
                    ),
                    blocValueInit    = BLOC(condition = 'InitialisationOfScalar == "ValueInit"',
                      ValueInit = SIMP (statut ='o', typ='R',ang='Define the initial value of the scalar'),
                   ),
                  ), #Initialisation
                ), #blocSimulatedScalar
                blocInteractionScalar    = BLOC(condition = 'OriginOfScalar == "Interaction"',
                  InteractionName = SIMP(typ=interaction,statut='o'),
                  Consigne = SIMP(statut="o", homo="information", typ="TXM", defaut='Create and choose suitable interaction'),
                ),
                blocGivenScalar = creeBlocPourLesFichiers('OriginOfScalar == "Given"', 'Scalar', ListeFormats = listeFormatGenerique, FieldName='ScalarField'),
                EffectOnFlowDynamic = SIMP(typ='TXM', statut='o',  into=[ 'Passive', 'Active'], defaut='Passive',  ),
                blocScalarActiveOnFlowDynamic = BLOC(condition = ' EffectOnFlowDynamic == "Active"',
                  ActiveOnFlowEffect = ActiveOnFlowEffect(),
                ),
                blocScalarFluidTurbulentAndNonComplexe = BLOC (condition = "FlowNature == 'Turbulent'",
                   ScalarFluxModel = prepareFactTurbulenceScalaire('f'),
                ), # bloc_scalar_FluidTurbulentandNonComplexe
               ),# Scalar 
             ),# blocwWithScalars 
          ),# Scalars 
      ), # fin FluidTurbulentandNonComplexe
     # il faut une validation de coherence entre l existence de tous les turbulencesModelling
   )# fin bloc_FluideMacro

#-----------------------------------------
def ActiveOnFlowEffect(inTemperature=True):
#-----------------------------------------
 return FACT(statut = 'o', max='**',ang='Define if the variable has an effect on the flow (e.g. Newtonian fluid).',
            RelationType  = SIMP(statut = 'o', into =['Equation Of State', 'Force-Flux Relation'], typ ='TXM',ang='Choose the type of relation for the effect of the variable on the flow. \n Current choice includes Equation of State (EoS) and Force-Flux relation (FFR).'),
            bloc_EOS = BLOC(condition = 'RelationType == "Equation Of State"',
                TypeOfEquationOfState = SIMP(statut='o', into =['variable density', 'compressible'], typ ='TXM',ang='Choose the type of Equation of State. \n Current choice includes Variable density or Compressible.'),
            ),
              bloc_NonEOSAndSimple=BLOC(condition = 'RelationType == "Force-Flux Relation" and ComplexFluid == False',
                TypeOfForceFluxRelation =  SIMP(statut='o', into =['Viscosity', 'Diffusivity', 'Thermal Conductivity'], intoXSD=['Viscosity', 'Diffusivity', 'Thermal Conductivity','Shear-stress closure', 'Scalar flux'], typ ='TXM', ang='Choose the type of Force-Flux Relation. \n Current choice includes Viscosity (e.g. viscous laws), Diffusivity or Thermal Conductivity.'),
                blocViscosity=BLOC(condition = 'TypeOfForceFluxRelation == "Viscosity" ',
                  ViscosityLaw=SIMP(typ='TXM', statut = 'o', into=['law1', 'law2']),
                ),
                blocDiffusivity=BLOC(condition = 'TypeOfForceFluxRelation == "Diffusivity"',
                  DiffusivityLaw=SIMP(typ='TXM', statut = 'o', into=['law1', 'law2']),
                ),
                blocConductivity=BLOC(condition = 'TypeOfForceFluxRelation == "Thermal Conductivity"',
                  ConductivityLaw=SIMP(typ='TXM', statut = 'o', into=['law1', 'law2']),
                ),
           ),
)

#------------------------------#
def prepareBoundaryCondition():
#------------------------------#
# on en fait 1 bloc seul pour CS and CPS
# pour pas de souci dans la projection XSD
  return FACT(statut='o',max = '**',    # max = nb de facette de bord
      TypeOfBoundaryCondition = SIMP(statut='o', typ='TXM', into=['Inlet', 'Outlet', 'Symmetry','Periodicity', 'Wall', 'Free Surface'], ang='Pick each type of boundary condition needed.\n Current choice includes Inlet, Outlet, Symmetry, Periodicity, Wall and Free surface.'),

      blocDesigneMesh = BLOC(condition = "SystemType == 'Continuum system'",
          ApplyOnGroups =  SIMP(statut ='o', typ=meshGroup, max='**', homo='SansOrdreNiDoublon', ang='Choose the surface elements (groups) on which the boundary condition applies. \n Requires the definition of boundary groups in SpatialAspects.',
                                    filtre=( '(set(MeshIdentifiers).intersection( set(self.getParentsWithId().getListeUserASSD("MeshId")) ) != set()) ',
                                              ( ('MeshIdentifiers', 'self.etape.getChild("blocModeleNumeriqueContinuum").getChild("NumericalModel")'), )
                                           ),
                                   ),
      ),
      blocDesigne_Shape = BLOC(condition = "SystemType == 'Classical particle system'",
         ApplyOnShapes =  SIMP (statut ='o', typ=shapeIdentifier, max='**', homo='SansOrdreNiDoublon', ang='Choose the shapes on which the boundary condition applies. \n Requires the definition of boundary shapes in SpatialAspects.',
                                    filtre=( '(set(SysGeoIdentifiers).intersection( set(self.getParentsWithId().getListeUserASSD("SystemGeometryId")) ) != set()) ',
                                              ( ('SysGeoIdentifiers', 'self.etape.getChild("blocModeleNumeriqueClassical").getChild("NumericalModel")'), )
                                           ),
                                  ),
     ),


      blocOnStateVariable  = BLOC(condition = "(TypeOfBoundaryCondition in ['Inlet', 'Symmetry','Periodicity',  'Free Surface'] and SystemType == 'Continuum system') or (SystemType == 'Classical particle system' and TypeOfBoundaryCondition not in ['Outlet','Inlet'])" ,
        ApplyOnStateVariable =  SIMP (statut ='o', typ=stateVariable, max='**', homo='SansOrdreNiDoublon', ang='Pick each State variable on which the boundary condition applies. \n Requires the definition of State variables for the component.',
                                      filtre=( 'etape in set(self.getEtapes()) ', (('etape', None),), ), #Il ne faut pas proposer les variables d'état des autres composants.
                                     ), #PNPN A FAIRE : fenetreIhm='menuDeroulant'
      ),

      blocPeriodique = BLOC(condition = "TypeOfBoundaryCondition == 'Periodicity'",
        Direction = SIMP(statut='o', typ='TXM', into=['X','Y','Z', 'XY', 'YZ', 'XZ', 'XYZ'],ang='Choose the direction for the periodic boundary condition. \n Current choice includes along X-direction, Y-direction, Z-direction or any combination of directions.'),
      ), # b_periodique

      blocInlet1 = BLOC(condition = "TypeOfBoundaryCondition == 'Inlet' and SystemType == 'Continuum system'",
         FormulationOfBoundary= SIMP(statut='o', typ='TXM', into=['Dirichlet','Neumann','Cauchy'], ang='Choose the type of inlet condition for the continuum system. \n Current choice includes Dirichlet (value of the variable at the boundary), Neumann (value of the normal derivative of the variable at the boundary) or Cauchy (values of the variable and its normal derivative at the boundary).',),
         blocDirichlet =   BLOC(condition = 'FormulationOfBoundary == "Dirichlet"',
             regles=(AU_MOINS_UN('InletProfile','IntegratedValue','IntegratedVectorValue',),
                  EXCLUS     ('InletProfile','IntegratedValue','IntegratedVectorValue',), ),
             Consigne = SIMP(statut ="o", homo="information", typ="TXM", defaut = "Choose between InletProfile,IntegratedValue,IntegratedVectorValue "),
             InletProfile = SIMP (statut ='f', typ='TXM',ang='Define the inlet profile for the variable'),
             IntegratedValue = SIMP (statut='f', typ='R',ang='Define the integrated value over the inlet for the variable'),
             IntegratedVectorValue = FACT(statut='f',
               U = SIMP (statut ='o', typ='R',ang='Define the integrated value for the variable along the X-direction (in m/s).'),
               V = SIMP (statut ='o', typ='R',ang='Define the integrated value for the variable along the Y-direction (in m/s).'),
               W = SIMP (statut ='o', typ='R',ang='Define the integrated value for the variable along the Z-direction (in m/s).'),
             ),
         ),# fin Dirichlet
         blocNeumann =   BLOC(condition = 'FormulationOfBoundary == "Neumann"',
            FluxFile = SIMP (statut ='o', typ=('Fichier', " ;;All Files (*)"),)
         ),
         blocCauchy =   BLOC(condition = 'FormulationOfBoundary == "Cauchy"',
            ImposedFlux      = SIMP (statut ='o', typ='TXM'),
            _IntegratedValue = SIMP (statut='o', typ='R'),
        ),
     ), # b_inlet1
     blocWall = BLOC(condition = "TypeOfBoundaryCondition == 'Wall' and SystemType == 'Continuum system'",
        VelocityAtBoundary = FACT(statut='o',ang='Define the velocity at the boundary (including the slip velocity and translational motion)',
            SlipVelocity = SIMP(statut='o', typ='R', defaut= 0.0,ang='Define the value of the slip velocity at the boundary (in m/s).'),
            WallMotion   = FACT(statut='o',ang='Define the translational motion of the wall (if necessary)',
              U = SIMP (statut ='o', typ='R',ang='Define the value of the translational wall motion along the X-direction (in m/s).'),
              V = SIMP (statut ='o', typ='R',ang='Define the value of the translational wall motion along the Y-direction (in m/s).'),
              W = SIMP (statut ='o', typ='R',ang='Define the value of the translational wall motion along the Z-direction (in m/s).'),
            ),
          ),
          LevelOfDescription   = FACT(statut='o',
            blocWallInside = BLOC(condition = "FlowNature == 'Turbulent'", ##JP+CH TODO : Choix des lois en fct du type du TurbulenceModelingType
              WallFunction = SIMP(statut ='o', typ='TXM',ang='Choose the model for the turbulent wall function at the boundary. \n Current choice includes No wall function (i.e. no model as in DNS) or log-law models (1-scale, 2-scale or scalable 2-scale models).',
                                  into=['No wall function','1-scale model (Log law)',
                                        '2-scale model (Log law)','Scalable 2-scale model (Log law)',
                                  ], defaut='No wall function', fenetreIhm='menuDeroulant'),
            ),
          ),
      ), # b_Wall

      blocWall2 = BLOC(condition = "TypeOfBoundaryCondition == 'Wall' and SystemType == 'Classical particle system'",
        ChoiceOfParticleWallInteraction = SIMP(statut='o', typ = wallInteractionId)
      ), # b_Wall

      blocInlet2 = BLOC(condition = "TypeOfBoundaryCondition == 'Inlet' and SystemType == 'Classical particle system'",
        TypeOfParticleInjected      = SIMP(statut='o', typ = userParticle,ang='Pick the type of particles injected. \n Requires the definition of at least one type of particles in the Classical-Particle system.'),
        NumberOfParticleInjected    = SIMP(statut='o', typ = 'I', val_min = 1,ang='Define the number of particles injected.'),
        InjectionEveryNTimeSteps    = SIMP(statut='o', typ = 'I', val_min = 0,ang='Define the frequency of injection of particles.'),
        DiameterOfParticleInjected  = SIMP(statut='o', typ = 'R', val_min = 0,ang='Define the diameter of the particles injected (in m).'),
        MassOfParticleInjected      = SIMP(statut='o', typ = 'R', val_min = 0,ang='Define the mass of the particles injected.'),

        PositionOfParticleInjected  = FACT(statut='o', 
           InitialisationMode   = SIMP(statut='o', into =['ByValue', 'ByFile', 'ByFormula' ], typ ='TXM', defaut='ByValue',ang='Choose the way the initial particle position is defined. \n Current choice includes by Value (i.e. user given), by File or by Formula.'),
           # A Rafiner
        ),
       blocNoBrownianDynamics = BLOC(condition = '(TypeOfConstraint != None) and not("Brownian dynamics" in TypeOfConstraint)', 
         ParticleVelocity = FACT(statut ='o',
           InitialisationMode   = SIMP(statut='o', into =['ByValue', 'ByFile', 'ByFormula' ], typ ='TXM', defaut='ByValue',ang='Choose the way the initial particle velocity is defined. \n Current choice includes by Value (i.e. user given), by File or by Formula.'),
           ), #fin VelocityDefinition
         blocHydrodynamic = BLOC(condition = '"Hydrodynamic" in MomentumFieldType', 
           FluidVelocitySeenByParticles = FACT(statut ='o',
              InitialisationMode   = SIMP(statut='o', into =['ByValue', 'ByFile', 'ByFormula' ], typ ='TXM', defaut='ByValue',ang='Choose the way the initial particle velocity is defined. \n Current choice includes by Value (i.e. user given), by File or by Formula.'),
            ),
          ),
        ),# blocNoBrownianDynamics
      ), # bInlet2

      blocApplyOnParticle = BLOC(condition = "SystemType == 'Classical particle system' and TypeOfBoundaryCondition != 'Inlet'" ,
         ApplyOnAllsParticle  = SIMP(typ=bool, statut ='o', defaut = True,ang='Precise if the field applies on all species (i.e. all types of particles defined in this Classical-Particle-System component)'),
         blocSpecifyParticle  = BLOC(condition = "ApplyOnAllsParticle == False" ,
             ApplyOnParticles = SIMP(statut ='o',max="**", typ = userParticle, homo='SansOrdreNiDoublon'),
         ),
      ),

  ) # Boundary_Conditions



JdC = JDC_CATA (
  #PN : TODO :  regles = (AU_PLUS_UN('DataTransfer_Aspects',),),
  code = 'Vimmp',
  # faire un validateur qui verifie que si on active reactions chimiques il faut que les masses molaires soient rentrees
)

Component = OPER(nom='Component', sd_prod=composant,
    SystemType  = SIMP(typ='TXM', into=['Quantum system', 'Classical particle system', 'Continuum system'], statut='o',position='global',ang='Choose the type of system to be simulated. \n Current choice includes Quantum system, Classical-Particle system and Continuum system.'),
    PhysicalDescription = FACT(statut = 'o',ang='Describe the physical system to be simulated.',
      blocFluideMacro   = prepareBlocFluideMacro(),
      blocCPS           = prepareBlocCPS(),
    ),
    blocModeleNumeriqueQuantum   = prepareBlocSystemType('Quantum system'),
    blocModeleNumeriqueClassical = prepareBlocSystemType('Classical particle system'),
    blocModeleNumeriqueContinuum = prepareBlocSystemType('Continuum system'),

    # Exemple de reecriture d'un BLOC_XOR pour eviter la generation d'un type xsd double
    # BCFluide = BLOC ( condition = 'SystemType == "Continuum system"',
    #    BoundaryConditions = FACT(statut = 'o',
    #       BoundaryCondition = prepareBoundaryCondition(), 
    #   ),
    # ),
    # BCParticle = BLOC ( condition = 'SystemType == "Classical particle system"',
    #    BoundaryConditions = FACT(statut = 'o',
    #       BoundaryCondition = prepareBoundaryConditionParticle(), 
    #   ),
    # ),
    BoundaryConditions = FACT(statut = 'o',                            
      BoundaryCondition = prepareBoundaryCondition(), 
    ),
)

Interpolator = OPER (nom= 'Interpolator',sd_prod=interpolator,
    InterpolatorType=SIMP(statut='o', typ='TXM', into = list(dictInterpolatorFormat.keys()),ang='Define the type of interpolation operator.'),
    blocMedCoupling= BLOC(condition="InterpolatorType == 'Med Coupling'",
      TargetMeshIdentifier = SIMP(statut ='o', typ = meshIdentifier,ang='Define the target mesh. \n Requires at least one mesh defined in SpatialAspects.'),
      InterpolationType    = SIMP(statut ='o', typ='TXM', into=['P0P0','P0P1','P1P1','P1P0'],ang='Choose the type of interpolator used. \n Current choice includes P0P0, P0P1, P1P1 or P1P0 (i.e. the order of the interpolation used).'),
      DefaultValueForUnmatchedMeshTargetEntity = SIMP(statut='o', typ ='R', defaut=-1),    
    ),
)
Converter = OPER (nom= 'Converter',sd_prod=converter)

Interactions = PROC(nom='Interactions',

    IOAspects = FACT(statut='o',ang='Define the inputs/outputs for the interaction.',
    #WorkingDirectory = SIMP(statut='o', typ='Repertoire', defaut='/tmp'),
       FileTransfer   = FACT(statut='f', max='**',
        TransferId    = SIMP(statut='o', typ=(fileId,'createObject'),),
        monBlocFormat = creeBlocPourLesFichiers('1', '', listeFormatGenerique, FieldName=None ),
       ),                      
       MemoryTransfer = FACT(statut='f', max='**',
        TransferId    = SIMP(statut='o', typ=(memoryId,'createObject'),),
       ),
       CorbaTransfer  = FACT(statut='f', max='**',
        TransferId    = SIMP(statut='o', typ=(corbaId,'createObject'),),
       ),
    ),

   Interaction = FACT(max = '**',ang='Define the type of interaction.',
      InteractionName  =  SIMP(statut='o', typ=(interaction,'createObject'),),
      From = SIMP(typ=modeleNumDuCompo, statut='o',ang='Choose the source for the interaction among existing components. \n Requires at least one component in the system.'),
      To   = SIMP(typ=modeleNumDuCompo, statut='o',ang='Choose the target for the interaction among existing components. \n Requires at least one component in the system.'),
      # ApplyOnStateVariable  = SIMP(statut ='o', typ=stateVariable), #PNPN A FAIRE : fenetreIhm='menuDeroulant'
      InvolvedStateVariable  = SIMP(statut ='o', typ=stateVariable,ang='Choose the State variable involved in the interaction. \n Requires at least one State Variable in the component.'), #PNPN A FAIRE : Seulement du composant d'origine From
      InteractionConfiguration = FACT(statut='o',ang='Configure the type of interaction.',
                                      
         OutputId = SIMP(statut='o',typ=(transferId,),),
         FieldName=SIMP(typ='TXM', statut='o'),
         CouplingMode =  SIMP(typ='TXM', statut='o', into =['Direct', 'DataProcessing'],ang='Choose the type of coupling. \n Current choice includes Direct (i.e. direct transfer of data) or DataProcessing (i.e. transfer of data that are processed).'),

         monBlocDataProcessing = BLOC (condition = "CouplingMode=='DataProcessing'",                         
            DataProcessingNode = FACT(min=1, max='**', statut ='o',ang='Define the type of data-processing used in the interaction.',
               Tool            = SIMP(typ=mapper, statut ='o'),
               OutputId        = SIMP(statut='o',typ=(transferId,),),
               FieldName       = SIMP(typ='TXM', statut='o'),
               monBlocInterpolator = BLOC (condition = "(Tool != None) and (isinstance(Tool,interpolator))",
                  FieldNature    = SIMP(typ='TXM', statut='o', into=['ExtensiveMaximum', 'IntensiveMaximum',
                                                                     'ExtensiveConservation', 'IntensiveConservation']), #PN: DICO pour le into avec key==Tool
               ),
            ),
          ), #fin monBlocDataProcessing
      ), #fin InteractionConfiguration
      ),
)

EnvironementAspects = PROC(nom ="EnvironementAspects",        
    WorkflowName     = SIMP(statut='o', typ='TXM', defaut='MyStudyCasename', ang='Define the name of the workflow simulated.'), #PN:  -> path
    WorkingDirectory = SIMP(statut='o', typ='Repertoire', defaut='/tmp', ang='Define the working directory for the simulation.'),
)


TemporalAspects = PROC(nom ="TemporalAspects",
    Simulated_Time_Laps = FACT(statut='o', max='**', ang='Define the system temporal characteristics.',
     name =  SIMP(statut='o', typ=(simulatedTime,'createObject'), ang='Define the name of the temporal characteristics.',),
     initialTime = SIMP(statut='o', typ='R', ang='Define the value of the initial time.'),
     finalTime   = SIMP(statut='o', typ='R', ang='Define the value of the final time.'),
     timeDiscretization = SIMP(statut ='o', typ = 'TXM', into = ['Constant Time Step', 'Varying Time Step'], ang='Choose the temporal discretization (i.e. time step).\n Current choice includes Constant time step or Varying time step.'),
     bloc_Constant = BLOC (condition = 'timeDiscretization == "Constant Time Step"',
          constantTimeStep = SIMP (statut ='o', typ = 'R', ang='Define the value of the time step (in s).'),
     ),
     bloc_Varying = BLOC (condition = 'timeDiscretization == "Varying Time Step"',
          CFLNumberCriteria     = SIMP (statut ='o', typ = 'R', ang='Define the value of the CFL criteria for the time step.'),
          FourierNumberCriteria = SIMP (statut ='o', typ = 'R', ang='Define the value of the Fourier criteria for the time step.'),
     ),
     ),
)

#
# -----------------------------------------
SpatialAspects = PROC(nom='SpatialAspects',
# -----------------------------------------
  regles = (AU_MOINS_UN('SystemGeometry', 'SpatialDiscretization'),),

  SystemGeometry = FACT(statut='f', max='**', ang='Define the system geometry.',
       SystemGeometryId = SIMP(statut='o', typ=(systemGeometryId, 'createObject'),ang='Define the name of the system geometry (used for CDM).'),
       Shape   = FACT(statut ='o', max='**', ang='Define the shape of the system.',
          ShapeIdentifier = SIMP(statut='o', typ=(shapeIdentifier,'createObject'),max='**',),
          ShapeNature     = SIMP(statut='o', typ='TXM', into=['Typical Geometry', 'CAD'], ang='Choose the nature of the system shape. \n Current choice includes Typical geometry (e.g. cube, cylinder) or CAD defined.'),

          blocShape  = BLOC(condition = 'ShapeNature == "Typical Geometry"',
            Box      = SIMP(statut='o', typ='TXM', into=['Cube', 'Sphere','Cylinder'], ang='Choose the typical geometry for the system. \n Current choice includes Cube, Sphere, Cylinder.' ),
            blocCube = BLOC(condition = 'Box == "Cube"',
             #Taille_Box_Englobante = SIMP(statut='o', typ='R', max=3, min =3)
             # derait etre un Tuple(3) mais a faire apres la projection
             #Size_Of_Bounding_Box = SIMP(statut='o', typ=Tuple(3), validators=VerifTypeTuple(('R','R','R'),),)
              Size_Of_Bounding_Box = SIMP(statut='o', typ='R', max=3, min=3, ),
            ), # fin blocCube
            blocBoule = BLOC(condition = 'Box == "Sphere"',
              Center  = SIMP(statut='o', typ='R', max=3, min =3),
            ),# fin b_Boule
            blocCylinder = BLOC(condition = 'Box == "Cylinder"',
              Heigth  = SIMP(statut="o", typ='R', val_min=0.0, ang='Nanotube length [m]'),
            ),# fin blocCylinder
            blocBouleOuCylinder = BLOC(condition = 'Box == "Sphere" or Box == "Cylinder"',
                Radius  = SIMP(statut='o', typ='R', val_min=0.0, ang='radius length [m]') ,
            ),# fin blocBouleOuCylinder
          ), # fin blocShape
          blocCAO = creeBlocPourLesFichiers("Shape_Nature == 'CAD'",'Domain', ['txt','I-deas', 'Gmsh', 'top',],None),
      ), # fin Shape
   ),# SystemGeometry

   SpatialDiscretization = FACT(statut='f', max="**", ang='Define the spatial discretization for the system (i.e. mesh).',
      MeshId    = SIMP(statut='o', typ=(meshIdentifier,'createObject'), ang='Define the id of the mesh (used in the CDM)'),
      MeshName  = SIMP(statut='o', typ='TXM', ang='Define the name of the mesh (used in the CDM)'),
      blocMeshFile = creeBlocPourLesFichiers("1 == 1",'Mesh',listeFormatGenerique,None),
      GroupIdentifier = SIMP(statut='o', typ=(meshGroup,'createObject'),max='**',),
   ),# SpatialDiscretization

   BoundaryConstraints = FACT(statut = 'f', ang='Define the boundary constraints for the system.',
       Motion = FACT(statut='f',
          MotionNature = SIMP(statut='o', typ='TXM', into=['Fixed boudary', 'Translational motion', 'Rotational motion', 'Scaling'], ang='Choose the type of motion for the boundary. \n Current choice includes Fixed boundary, Translational motion, Rotational motion and Scaling'),

          blocTranslationalMotion = BLOC(condition = 'MotionNature == "Translational motion"',
            TranslationVelocity   = SIMP(statut='o', typ='R', ang='Define the value of the translational velocity for the boundary.'),
            boundaries            = SIMP(statut='o', typ=spatialRegion,max='**', homo='SansOrdreNiDoublon' ),
          ),
          blocRotationalMotion = BLOC(condition = 'MotionNature == "Rotational motion"',
            RotationRate       = SIMP(statut='o', typ='R', ang='Define the value of the rotation rate for the boundary.'),
            boundaries         = SIMP(statut='o', typ=spatialRegion,max='**', homo='SansOrdreNiDoublon' ),
          ),
          blocFixed    = BLOC(condition = 'MotionNature == "Fixed boudary"',
            boundaries = SIMP(statut='o', typ=spatialRegion,max='**', homo='SansOrdreNiDoublon'),
          ),
       ),
#PN decrire page 28
       Mapping = FACT(statut='f',
       ),
     ), # Boundary_Constraints
) # fin Geometric_Domain

#Le dictionnaire dict_condition est un dictionnaire utilisé par eficas
# pour les position='global_jdc' et position='inGetAttribut'
dict_condition={
     'ChoiceOfApproach': ('Interactions', 'Component'),
     'Interactions'    : ( 'Component'),
}

#TEXTE_NEW_JDC = " "
