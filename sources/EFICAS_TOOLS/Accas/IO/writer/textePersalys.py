# ----------------------------------
# headerScriptPersalys
# Parametres pour format :
# nom de l etude, nom de l etude, nom de l etude, path pour wrapper, wrapper, nom de la fonction
# sys.path[:0]=[{}]

headerScriptPersalys = """#! /usr/bin/env python3
# coding: utf-8
#  --------------------------------------------------------------------------
# Script Eficas genere pour lancement Etude Probabiliste
# ---------------------------------------------------------------------------
# Exemple d'utilisation standalone avec salome :
# ~/salome/appli_V9_7_0_package/salome start -k -t python3 mon_fichier_uq_genere.py
# ou
# ~/salome/appli_V9_7_0_package/salome start -k -t
# ~/salome/appli_V9_7_0_package/salome shell python3 mon_fichier_uq_genere.py

# Chargement du module systeme
import sys
import os

# Chargement du module OpenTURNS #TODO : Parametrer OpenTurns/Uranie
import openturns as ot 
import persalys

"""

# def run_case(self):
#    """
#    Launch the calculation once the case files are ready.
#    """
#    command = './run.sh '
#    command += './syrthes.py -n ' + str(self.nproc) + ' -d ' + self.comm_file
#    command += ' >' + os.path.join(self.workdir, "std.log")
#    command += ' 2>' + os.path.join(self.workdir, "err.log")
#    os.system(command)
#    pass


# ----------------------------------
# etudeScript
etudeScript = """
class Study:
    import os
    import subprocess

    def __init__(self, {chaineDesVariablesInput}):
        {chaineInitDesVariablesInput}

    def do_sh(self, command, execdir=os.getcwd()):
        print('Execution directory is : ', execdir)
        import subprocess
        sh = subprocess.Popen(command, shell=True, cwd=execdir,
                              stdout=subprocess.PIPE,
                              stderr=subprocess.STDOUT)
        out, err = sh.communicate()
        return out, err, sh.poll()

    #TODO : Définir un décorateur pour sélectionner la fonction voulue
    def define_workdirectory(self):
        from incertainty_tools import value_repr_name
        self.workdir = value_repr_name([{chaineSelfDesVariablesInput}])

    def case_exists(self):
        ok = True
        if os.path.isdir(self.workdir):
            try:
                ok = False #TODO
            except:
                ok = False
        else:
             ok = False
        return ok

    def prepare_case(self):
        from incertainty_tools import replace_data
        import shutil

        if not os.path.isdir(self.workdir):
           os.mkdir(self.workdir)

        #section spécifique au code de calcul
        comm_file_balise = '{commFileBalise}'

        self.nproc = {nproc} # La présence de cette variable dépend 
                                          # du mode de lancement MPI
                                          # S'il est géré par le script appelé à partir du MDD, il est inutile de le stocker 
        self.comm_file_balise = os.path.join(self.workdir, comm_file_balise)
        shutil.copy(comm_file_balise, self.comm_file_balise)

        self.comm_file = os.path.join(self.workdir, '{commFile}')
        replace_data(self.comm_file_balise, {{ {replaceDataList}  }} , self.comm_file)
        #TODO: Lancer la validation du fichier généré avant tout lancement : Le banc le fait

        pass

    def get_result_from_csv(self,postProcessedVar, aggregationFctList):
       from post_csv_rn import get_result_from_csv
       #TODO:  Fonctions a implementer dans un fichier post_csv provenant
       #  de la mise en donnée pour définir la façon d'aggréger les valeurs
       from post_csv_rn import vInitialTime, vHalfTime, vFinalTime, vMean, vSum, vMin, vMax

       savdir=os.getcwd()
       os.chdir(self.workdir)
       results = get_result_from_csv(postProcessedVar, aggregationFctList)
       os.chdir(savdir)
       return  results

    def run_case(self):
        #os.chdir(self.workdir)
        # Si lancement mpi externe à ib_test.sh il faut utiliser self.nproc : mpiexec -n self.nproc ib_test.sh
        #o,e,c = self.do_sh(command="ib_test.sh", execdir=self.workdir)
        command="{uncertaintyScript} {uncertaintyScriptParameters}"
        o,e,c = self.do_sh(command=command, execdir=self.workdir)
        if o != None : print(o.decode())
        if e != None : print(e.decode())
        if c != 0:
            raise Exception(' Study::run_case : Execution error : cd ' +
                                     os.path.join('{workDirectory}',self.workdir) + 
                                      ' && '+ os.path.join('../','{uncertaintyScript}') +
                                      ' '+ '{uncertaintyScriptParameters}')

"""

# /home/C65845/VIMMP/Banc_integration.newer_odysee/environment/bin/python3 /home/C65845/VIMMP/Banc_integration.newer_odysee/environment/bin/ib-run --cocagne-neutro-solver SPN --cocagne-thermo-solver THERMOMI/TRMIC -- /home/C65845/VIMMP/Banc_integration.newer_odysee/integration_bench/tests/control_rod_ejection_small_core_cathare3_cocagne.comm /home/C65845/VIMMP/Banc_integration.newer_odysee/integration_bench/tests/control_rod_ejection_small_core_cathare3_cocagne_spn_thermomi-trmic_serial

getResultCall = """    {variableOutputList}, = study.get_result_from_csv( '{nomVarPostraite}', [{fonctionAggregationList}] )
    print( '{nomVarPostraite}: ({variableOutputList})',{variableOutputList})
"""

getResultCallAvoidPersalysBug = """    {variableOutputList}, = study.get_result_from_csv( '{nomVarPostraite}', [{fonctionAggregationList}] )

    print( '{nomVarPostraite}: ({variableOutputList})',{variableOutputList})

    #Contournement Bug Persalys sur la longueur de la chaine retour
    {shortVariableOutputList} = {variableOutputList}

"""

# -------------------------
# fonctionPersalys
# ------------------------
fonctionPersalys = """
def _exec({chaineDesVariablesInput}):
    from post_csv_rn import vInitialTime, vHalfTime, vFinalTime, vMean, vSum, vMin, vMax
    from {currentFile} import Study

    study = Study({chaineDesVariablesInput})
    study.define_workdirectory()
    if not study.case_exists():
        study.prepare_case()
    study.run_case()

{getAllResults}
    return {chaineDesVariablesOutput}
"""

# ------------------------
# codePersalys
# ------------------------
codePersalys = """
code = '''
{fonctionPersalys}
'''
"""

# ----------------------------
# inputHeaderPersalys
# ----------------------------
inputHeaderPersalys = """
{indent}# definition des Inputs
{indent}# ---------------------
"""

# inputPersalysUniform='{}{} = persalys.Input({}, {})'
# inputPersalys='{}{} = persalys.Input({}, {})'

# ------------------------------
# ouputHeaderPersalys
# ------------------------------
outputHeaderPersalys = """
{indent}# definition des Outputs
{indent}# ----------------------
"""

# ------------------
# mainPersalys
# ------------------
mainPersalys = """
# ------------------
# definition du main
# ------------------
if __name__ == '__main__':

    from datetime import datetime

    {nomEtude} = persalys.Study('{nomEtude}')
    persalys.Study.Add({nomEtude})

{inputVariableInitList}
{outputVariableInitList}

{inputHeaderPersalys}
    inputs = [{chaineDesVariablesInput}]
    nInputs = len(inputs)

{outputHeaderPersalys}
    outputs = [{chaineDesVariablesOutput}]
    nOutputs = len(outputs)

    yacsPhysicalModel = persalys.YACSPhysicalModel('PhysicalModel', inputs, outputs, code)
{yacsJobParameters}
    {nomEtude}.add(yacsPhysicalModel)

{centralTendencyPersalys}
    {nomEtude}.add(centralTendency)

################ CUT THE FILE HERE IF YOU WANT TO IMPORT IT IN THE SALOME PERSALYS MODULE ################

    head_study = str(datetime.now()) +" {scenarioType} "+""

    centralTendency.run()
{resultPersalys}

"""
#    a = persalys.Input('a', 0, '')
#    b =    persalys.Input('b', 0, '')
#    d = persalys.Output('d', '')
#    inputs = [a, b]
#    outputs = [d]

# empiricalMean = ot.Sample(result.getMean())[nInputs:]
# empiricalStandardDeviation = ot.Sample(result.getStandardDeviation())[nInputs:]
# resultNp.reshape(nbindex,nbsorties)

printResultMC = """    import numpy as np
    sys.path.append(os.path.abspath('{post_csv_rnPath}'))
    from {post_csv_rnScript} import write_result_from_persalys

    #Noms de lignes
    #index = ['meanFirstOrder', 'meanSecondOrderOrder', 'standardDeviationFirstOrder' ]
    indexNp = [ {optionalResultStrList} ]
    nResult = len(indexNp)

    #resultNp = np.array([meanFirstOrder, meanSecondOrderOrder, standardDeviationFirstOrder ])
    #Lignes de résultats demandés pour toutes les fcts d'aggrégation en colonne
    resultNp = np.array([ {optionalResultList} ])
    resultNp = resultNp.reshape(nResult, nOutputs)  #En MC à cause du ot.Sample( PointsCollection) il y a un niveau de liste en trop

    #Tableau skyline localisant les variables (hors fctAgg) dans le tableau de résultat global  
    # ex pour deux variables et respectivement 7 et 3 fcts aggrégation :  resultSk = [0,7,10]
    #nOutVar = len(resSk)-1
    resSk = [ {resultSkList} ]

    print('\\n\\n')
    print('*********************************************************************************\\n')
    print('                   UNCERTAINTY QUANTIFICATION RESULTS\\n')
   
    print(head_study,'\\n')

    print('Uncertain inputs list :','\\n')
    print(
{Uncertain_inputs}'\\n'
    )
    print('\\nElapsed Time : ', centralTendency.getElapsedTime(),'\\n') #Monte Carlo ou Taylor

    print('\\nDesign of Experiment :')
    print(result.getDesignOfExperiment().getInputSample(),'\\n') #TODO: générer un fichier csv

    print('\\nCoefficient of Variation :')
    print(ot.Sample(result.getCoefficientOfVariation())[nInputs:],'\\n') #TODO: générer un fichier csv
    write_result_from_persalys(resultNp, indexNp, resSk, outputs)

    print('\\n*********************************************************************************\\n')
"""


printResultTaylor = """    import numpy as np
    sys.path.append(os.path.abspath('{post_csv_rnPath}'))
    from {post_csv_rnScript} import write_result_from_persalys

    #resultNp = np.array([meanFirstOrder, meanSecondOrderOrder, standardDeviationFirstOrder ])
    #Lignes de résultats demandés pour toutes les fcts d'aggrégation en colonne
    resultNp = np.array([ {optionalResultList} ])

    #Noms de lignes
    #index = ['meanFirstOrder', 'meanSecondOrderOrder', 'standardDeviationFirstOrder' ]
    #nResult = len(indexNp)
    indexNp = [ {optionalResultStrList} ]

    #nResult = len(indexNp)

    #Tableau skyline localisant les variables (hors fctAgg) dans le tableau de résultat global  
    # ex pour deux variables et respectivement 7 et 3 fcts aggrégation :  resultSk = [0,7,10]
    #nOutVar = len(resSk)-1
    resSk = [ {resultSkList} ]

    print('\\n\\n')
    print('*********************************************************************************\\n')
    print('                   UNCERTAINTY QUANTIFICATION RESULTS\\n')
   
    print(head_study,'\\n')

    print('Uncertain inputs list :','\\n')
    print(
{Uncertain_inputs}'\\n'
    )
    print('\\nElapsed Time : ', centralTendency.getElapsedTime(),'\\n') #Monte Carlo ou Taylor

    # print('\\nDesign of Experiment :')
    # print(result.getDesignOfExperiment().getInputSample(),'\\n') #TODO: Activer uniquement en MC + fichier csv

    # print('\\nCoefficient of Variation :')
    # print(result.getCoefficientOfVariation(),'\\n') #TODO: Activer uniquement en MC + fichier csv
    write_result_from_persalys(resultNp, indexNp, resSk, outputs)

    print('\\n*********************************************************************************\\n')
"""

## Tendance Centrale Taylor
centralTendencyTaylor = """
    centralTendency = persalys.TaylorExpansionMomentsAnalysis('centralTendencyTaylor', yacsPhysicalModel)
"""

# Le result est une liste de taille <nombre de variables de sortie>
resultTaylor = """
    result = centralTendency.getResult()
{optionalResult}

"""

optionalResultTaylor = {
    "MeanFirstOrder": "meanFirstOrder = result.getMeanFirstOrder()",
    "StandardDeviationFirstOrder": "standardDeviationFirstOrder = result.getStandardDeviation()",
    "MeanSecondOrder": "meanSecondOrder = result.getMeanSecondOrder()",
    "Variance": "variance = result.getVariance()",
}
optionalPrintResultTaylor = {
    "MeanFirstOrder": 'print("MeanFirstOrder : ",meanFirstOrder)',
    "StandardDeviationFirstOrder": 'print("StandardDeviationFirstOrder :",standardDeviationFirstOrder)',
    "MeanSecondOrder": 'print("MeanSecondOrder :",meanSecondOrder)',
    "Variance": 'print("Variance :",variance)',
}

## Tendance Centrale MC
centralTendencyMC = """
    centralTendency = persalys.MonteCarloAnalysis('centralTendencyMC', yacsPhysicalModel)
{critereArretMC}
{advancedParameterMC}
    centralTendency.setBlockSize({BlockSize})
"""

critereArretMC = {
    "SimulationsNumber": "centralTendency.setMaximumCalls({SimulationsNumber})",
    "MaximumElapsedTime": "centralTendency.setMaximumElapsedTime({MaximumElapsedTime})",
    "Accuracy": "centralTendency.setMaximumCoefficientOfVariation({Accuracy})",
}

advancedParameterMC = {
    "Seed": "centralTendency.setSeed({Seed})",  # TODO : A ajouter dans le catalogue
    "ComputeConfidenceIntervalAt": "centralTendency.setLevelConfidenceInterval({ComputeConfidenceIntervalAt})",
}

# TODO:  Gérer les unités
resultMC = """
    result = centralTendency.getResult()
{optionalResult}
"""

optionalResultMC = {
    "EmpiricalMean": "empiricalMean = ot.Sample(result.getMean())[nInputs:]",  # En MC les inputs apparaissent en début de résultat !
    "Variance": "variance = ot.Sample(result.getVariance())[nInputs:]",  # et on utilise ot.Sample pour accéder aux valeurs des Points
    "EmpiricalStandardDeviation": "empiricalStandardDeviation = ot.Sample(result.getStandardDeviation())[nInputs:]",  # Idem.
    "EmpiricalQuantile": """
    designOfExperiment=result.getDesignOfExperiment()
    outputSample=designOfExperiment.getOutputSample()
    empiricalQuantile_Order = {EmpiricalQuantile_Order}
    empiricalQuantile=outputSample.computeQuantile(empiricalQuantile_Order)
    """,
}

optionalPrintResultMC = {
    "EmpiricalMean": 'print("EmpiricalMean : ", empiricalMean)',
    "Variance": 'print("Variance : ", variance)',
    "EmpiricalStandardDeviation": 'print("EmpiricalStandardDeviation : ",empiricalStandardDeviation)',
    "EmpiricalQuantile": 'print("EmpiricalQuantile : ",empiricalQuantile)',
    "EmpiricalQuantile_Order": 'print("EmpiricalQuantile_Order : ",empiricalQuantile_Order)',
}


# designOfExperiment=result.getDesignOfExperiment()
# outputSample=designOfExperiment.getOutputSample()
# computeQuantile=outputSample.computeQuantile(empiricalQuantile_Order)
# ##isample=designOfExperiment.getSample()
# ##computeQuantile=sample.computeQuantile(0.95)
# ##nputSample=designOfExperiment.getInputSample()
# ##computeQuantile=inputSample.computeQuantile(0.95)


# En local le nombre de procs est inutile
# TODO: S'il on peut récupérer les fichiers .csv des tirages,
#            il faut ajouter une ligne out_files
yacsJobParameters = """
    yacsPhysicalModel.jobParameters().salome_parameters.resource_required.name = '{resourceName}'
    yacsPhysicalModel.jobParameters().salome_parameters.job_name = '{nomEtude}'
    yacsPhysicalModel.jobParameters().salome_parameters.work_directory = '{workDirectory}'
    yacsPhysicalModel.jobParameters().salome_parameters.result_directory = '{resultDirectory}'
    yacsPhysicalModel.jobParameters().salome_parameters.in_files = {inFiles} # Chemins des fichiers locaux à copier dans work_directory
    yacsPhysicalModel.jobParameters().nb_branches = {nbBranches} # nombre de jobs parallèles
"""

# Le nombre de procs du job manager est uniquement utile pour les clusters
yacsJobClusterParameters = """
    yacsPhysicalModel.jobParameters().salome_parameters.resource_required.nb_proc = {nprocs}
    yacsPhysicalModel.jobParameters().salome_parameters.wckey = '{wckey}'
"""

# Ces 3 lignes permettent de modifier le mode d'évaluation par défaut qui est
# d'avoir toutes les évaluations dans un seul job.
# Ici <nb_branches> jobs seront crées dynamiquement pour lancer chaque évaluation
#  chaque job demandera la réservation de nprocs processus.
yacsJobClusterMultiJob = """
    import pydefx
    multiJobModel = pydefx.MultiJobStudy() # mode un job par évaluation
    yacsPhysicalModel.setJobModel(multiJobModel)
"""

# yacsJobParametersRef="""
# yacsPhysicalModel.jobParameters().salome_parameters.job_name = '{nomEtude}_idefix_job'
# yacsPhysicalModel.jobParameters().salome_parameters.work_directory = '/scratch/C65845/workingdir/persalys_light'
# yacsPhysicalModel.jobParameters().salome_parameters.result_directory = '/tmp/local_result'
# yacsPhysicalModel.jobParameters().salome_parameters.resource_required.name = 'gaia'
# yacsPhysicalModel.jobParameters().salome_parameters.resource_required.nb_proc = 1
# yacsPhysicalModel.jobParameters().salome_parameters.wckey = 'P11N0:SALOME'
# yacsPhysicalModel.jobParameters().salome_parameters.in_files = [] # Chemins des fichiers locaux à copier dans work_directory
# yacsPhysicalModel.jobParameters().nb_branches = 3 # nombre de jobs parallèles

# # Ces 4 lignes permettent de modifier le mode d'évaluation par défaut qui est
# # d'avoir toutes les évaluations dans un seul job.
# import pydefx
# import os
# myModel = pydefx.MultiJobStudy() # mode un job par évaluation

# PhysicalModel.setJobModel(myModel)
# """


if __name__ == "__main__":
    pass
