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
   UQ pour EFICAS.

"""
from builtins import str

import traceback
import types, re, os
import Accas

from Accas.IO.writer.writer_python import PythonGenerator

# texteUranie   present dans le banc Reacteur Numerique
# textePresalys present hors le banc Reacteur Numerique
try:
    from Accas.IO.writer.texteUranie import SCRIPT_URANIE
except:
    pass

try:
    from Accas.IO.writer.textePersalys import (
        headerScriptPersalys,
        fonctionPersalys,
        etudeScript,
        codePersalys,
    )
    from Accas.IO.writer.textePersalys import mainPersalys, inputHeaderPersalys, outputHeaderPersalys
    from Accas.IO.writer.textePersalys import getResultCall, getResultCallAvoidPersalysBug
    from Accas.IO.writer.textePersalys import centralTendencyTaylor, resultTaylor
    from Accas.IO.writer.textePersalys import optionalResultTaylor, optionalPrintResultTaylor
    from Accas.IO.writer.textePersalys import centralTendencyMC, resultMC
    from Accas.IO.writer.textePersalys import critereArretMC, advancedParameterMC
    from Accas.IO.writer.textePersalys import optionalResultMC, optionalPrintResultMC
    from Accas.IO.writer.textePersalys import printResultMC, printResultTaylor
    from Accas.IO.writer.textePersalys import (
        yacsJobParameters,
        yacsJobClusterParameters,
        yacsJobClusterMultiJob,
    )

    genereScriptPersalys = True
except:
    genereScriptPersalys = False

genereScriptPersalys = False


def entryPoint():
    """
    Retourne les informations necessaires pour le chargeur de plugins

    Ces informations sont retournees dans un dictionnaire
    """
    return {
        # Le nom du plugin
        "name": "UQ",
        # La factory pour creer une instance du plugin
        "factory": UQGenerator,
    }


class UQGenerator(PythonGenerator):
    """
    Ce generateur parcourt un objet de type JDC et produit
    un texte au format eficas 'normal'
    un texte au format eficas avec balise
    un script python permettant de piloter Persalys

    """

    def gener(self, jdc, format="beautifie"):
        self.indent1 = "    "

        # On remet a jour les MCPath
        self.jdc = jdc
        self.recalculeMCPath()
        if jdc.nature != "JDC" or not jdc.isValid():
            ret, commentaire = self.sauveUniquementCommEt_UQComm(jdc)
            if not ret:
                return (ret, commentaire)
            self.commentaire = "Le JDC doit etre valide pour generer le script de lancement et le fichier à balises\n"
            self.commentaire += (
                "Seuls les fichiers _det.comm et .comm  ont été sauvegardés"
            )
            return 2
        ret, commentaire = self.analyseIncertitude()
        if not ret:
            self.commentaire = commentaire
            return ret
        self.inGenerUQ = True
        self.generDeterministe = False
        self.textUQ = PythonGenerator.gener(self, jdc, format)
        self.inGenerUQ = False
        self.generDeterministe = True
        self.text = PythonGenerator.gener(self, jdc, format)
        return self.text

    def creeNomsFichiers(self, fichier):
        self.cheminFichierComm = os.path.abspath(os.path.dirname(fichier))
        if fichier.endswith(".xml"):
            self.fichierSansSuffixe = os.path.basename(fichier[:-5])
        elif fichier.endswith(".comm"):
            self.fichierSansSuffixe = os.path.basename(fichier[:-5])
        else:
            self.commentaire = "Le nom du fichier doit finir par .comm ou .xml\n"
            return (
                0,
                "le fichier jeux de données |"
                + fichier
                + "| doit être suffixé par .comm",
            )
        self.fichierComm = self.fichierSansSuffixe + ".comm"
        self.fichierDetComm = self.fichierSansSuffixe + "_det.comm"
        self.fichierBalise = self.fichierSansSuffixe + "_@det.comm"
        self.fichierUQExe = self.fichierSansSuffixe + "_UQ.py"
        self.fichierUQModule = os.path.basename(self.fichierUQExe)[:-3]
        return (1, "")

    def sauveUniquementCommEt_UQComm(self, jdc):
        self.inGenerUQ = False
        self.generDeterministe = True
        self.text = PythonGenerator.gener(self, jdc, "beautifie")
        fichierDetComm = os.path.join(self.cheminFichierComm, self.fichierDetComm)
        if not self.writeFile(fichierDetComm):
            return (0, "impossible de sauvegarder le _det.comm")
        self.generDeterministe = False
        self.text = PythonGenerator.gener(self, jdc, "beautifie")
        fichierComm = os.path.join(self.cheminFichierComm, self.fichierComm)
        if not self.writeFile(fichierComm):
            return (0, "impossible de sauvegarder le .comm")
        return (1, "")

    def writeUQ(self, fichier):
        # il manque le checksum
        fichierBalise = os.path.join(self.cheminFichierComm, self.fichierBalise)
        fichierUQExe = os.path.join(self.cheminFichierComm, self.fichierUQExe)
        try:
            with open(fichierBalise, "w") as fp:
                fp.write(self.textUQ)
        except:
            return (0, "impossible de sauvegarder le _@det.py")
        try:
            # if 1 :
            with open(fichierUQExe, "w") as fp:
                fp.write(self.txtScript)
        except:
            if self.txtScript != "":
                return (0, "impossible de sauvegarder le .py")
        # a reecrire pour ne pas appeler trop de fois le gener
        retour, commentaire = self.sauveUniquementCommEt_UQComm(self.jdc)
        if not retour:
            return (retour, commentaire)
        return (1, None)

    def generPROC_ETAPE(self, obj):
        if not self.inGenerUQ:
            return PythonGenerator.generPROC_ETAPE(self, obj)
        if obj.nom == "ExpressionIncertitude" and self.inGenerUQ:
            return ""
        else:
            return PythonGenerator.generPROC_ETAPE(self, obj)
        # il faut remplacer @xxx@
        # DU coup qu est ce que xxx

    def generMCSIMP(self, obj):
        # inutile tant que FACT et BLOC ne sont pas surcharges
        if obj.nom == "Consigne":
            return
        if not self.inGenerUQ:
            return PythonGenerator.generMCSIMP(self, obj)
        if not obj in self.mcIncertains:
            return PythonGenerator.generMCSIMP(self, obj)
        else:
            # a refaire si on decide que les incertains sont sous des fact multiples
            # ce qui ne me parait pas possible mais ?
            if obj.etape.nature == "OPERATEUR":
                return "@ " + obj.etape.sd.nom + "__" + obj.nom + " @,"
            else:
                return "@ " + obj.nom + " @,"

    def recalculeMCPath(self):
        etapeIncertitude = self.jdc.getEtapesByName("ExpressionIncertitude")
        if len(etapeIncertitude) != 1:
            return
        etapeIncertitude = etapeIncertitude[0]
        self.lesVariablesInput = etapeIncertitude.getChild("Input")[
            0
        ].getChildOrChildInBloc("VariableProbabiliste")
        index = 0
        for mc in self.lesVariablesInput.data:
            itemMCPath = mc.getChild("MCPath")
            itemMCPath.setValeur(mc.variableDeterministe.getMCPath())

    def analyseIncertitude(self):
        from functools import reduce as reduce

        self.txtScriptPersalys = ""
        self.txtScript = ""
        etapeScenarioData = self.jdc.getEtapesByName("Scenario_data")
        if etapeScenarioData == []:
            return (
                0,
                "il faut au moins un mot-clef Scenario_data",
            )  # TODO : à Résorber après modification du catalogue
        if len(etapeScenarioData) != 1:
            return (
                0,
                "il faut au plus un mot-clef  Scenario_data",
            )  # TODO : à Résorber après modification du catalogue
        etapeScenarioData = etapeScenarioData[0]
        self.ScenarioType = etapeScenarioData.getChildOrChildInBloc(
            "scenario_type"
        ).valeur

        etapeIncertitude = self.jdc.getEtapesByName("ExpressionIncertitude")
        if etapeIncertitude == []:
            return (0, "il faut au moins un mot-clef ExpressionIncertitude")
        if len(etapeIncertitude) != 1:
            return (0, "il faut au plus un mot-clef  ExpressionIncertitude")
        etapeIncertitude = etapeIncertitude[0]

        incertitudeInput = etapeIncertitude.getChildOrChildInBloc("Input")
        self.lesVariablesInput = incertitudeInput[0].getChildOrChildInBloc(
            "VariableProbabiliste"
        )
        self.mcIncertains = []
        self.nomsDesVariablesInput = []
        self.chaineDesVariablesInput = ""
        for mc in self.lesVariablesInput:
            if mc.variableDeterministe.etape.nature == "OPERATEUR":
                self.chaineDesVariablesInput += (
                    mc.variableDeterministe.etape.sd.nom
                    + "__"
                    + mc.variableDeterministe.nom
                    + ", "
                )
                self.nomsDesVariablesInput.append(
                    mc.variableDeterministe.etape.sd.nom
                    + "__"
                    + mc.variableDeterministe.nom
                )
            else:
                self.chaineDesVariablesInput += mc.variableDeterministe.nom + ", "
                self.nomsDesVariablesInput.append(mc.variableDeterministe.nom)
            self.mcIncertains.append(mc.variableDeterministe)

        sectionOutput = etapeIncertitude.getChildOrChildInBloc("Output")[0]
        self.ScriptPosttraitement = sectionOutput.getChildOrChildInBloc(
            "ScriptPosttraitement"
        )
        # dans le cas du catalogue UQ gere dans le banc RN, ScriptPosttraitement n existe pas
        if self.ScriptPosttraitement:
            self.ScriptPosttraitement = sectionOutput.getChildOrChildInBloc(
                "ScriptPosttraitement"
            ).valeur
            if isinstance(self.ScriptPosttraitement, Accas.PARAMETRE):
                self.ScriptPosttraitement = self.ScriptPosttraitement.valeur
        self.chaineDesVariablesInput = self.chaineDesVariablesInput[0:-2]

        # Cas RN OpenTurns ScriptPosttraitement = None
        # on ne fait pas le return : la suite du traitement est necessaire a uranie
        sectionPropagation = etapeIncertitude.getChildOrChildInBloc("Propagation")[0]
        self.Methode = sectionPropagation.getChildOrChildInBloc("Methode").valeur
        if not sectionPropagation.getChildOrChildInBloc("Result"):
            self.Result = None
        else:
            self.Result = sectionPropagation.getChildOrChildInBloc("Result")[0]
        if self.Methode == "MonteCarlo":
            self.critereArret = sectionPropagation.getChildOrChildInBloc(
                "CritereArret"
            )[0]
            if sectionPropagation.getChildOrChildInBloc("EvaluationParameter"):
                sectionEvaluationParameter = sectionPropagation.getChildOrChildInBloc(
                    "EvaluationParameter"
                )[0]
                self.Blocksize = sectionEvaluationParameter.getChildOrChildInBloc(
                    "BlockSize"
                ).valeur
                self.advancedParameter = sectionPropagation.getChildOrChildInBloc(
                    "AdvancedParameter"
                )
                if self.advancedParameter != None:
                    self.advancedParameter = self.advancedParameter[0]
            # self.ComputeConfidenceIntervalAt  = self.advancedParameter.getChildOrChildInBloc('ComputeConfidenceIntervalAt')[0]
            # self.Seed  = self.advancedParameter.getChildOrChildInBloc('Seed')[0]
        self.lesVariablesOutput = sectionOutput.getChildOrChildInBloc(
            "VariableDeSortie"
        )
        self.chaineDesVariablesOutputEncodee = ""
        self.txtOutputVariableInitList = ""
        self.txtGetAllResults = ""
        # TODO? from cata_UQ import FonctionDAggregationDict
        fctAggPy = {
            "valeur à t=O": "vInitialTime",
            "valeur à mi-temps": "vHalfTime",
            "valeur à t final": "vFinalTime",
            "valeur moyenne": "vMean",
            "valeur cumulée": "vSum",
            "valeur minimale": "vMin",
            "valeur maximale": "vMax",
        }

        index = 0
        self.resultSkList = [0]
        for mc in self.lesVariablesOutput:
            nomShortVariableOutputList = ""
            nomFctAggPyList = ""
            nomOutputList = ""
            nomVar = mc.getChildOrChildInBloc("VariablePhysique").valeur
            nomVarEncode = nomVar.replace(" ", "__")  # TODO : function
            nomVarPostraite = mc.getChildOrChildInBloc(
                "VariablePosttraiteeAssociee"
            ).valeur
            nomFctAggList = mc.getChildOrChildInBloc("FonctionDAggregation").valeur
            for nomFctAgg in nomFctAggList:
                nomFctAggPy = fctAggPy[nomFctAgg]
                nomFctAggPyList += nomFctAggPy + ", "
                nomOutput = nomVarEncode + "_" + nomFctAggPy
                nomOutputList += nomOutput + ", "
                self.chaineDesVariablesOutputEncodee += nomOutput + ", "
                variablesOutputDesc = (
                    '("' + nomFctAgg + '","' + nomVarPostraite + '")'
                )  # TODO : Interdire ',' dans FctAgg et nomVarPost
                nomShortVariableOutputList += (
                    "a" + str(index) + ", "
                )  # Avoid a Persalys Bug
                index += 1
                self.txtOutputVariableInitList += (
                    self.indent1
                    + nomOutput
                    + " = persalys.Output('"
                    + nomVar
                    + " ("
                    + nomFctAgg
                    + ")"
                    + "', '"
                    + variablesOutputDesc
                    + "')\n"
                )
            # tmpGetResultCall = getResultCall.format(
            tmpGetResultCall = (
                getResultCallAvoidPersalysBug.format(  # Avoid a Persalys Bug
                    variableOutputList=nomOutputList[0:-2],
                    nomVarPostraite=nomVarPostraite,
                    fonctionAggregationList=nomFctAggPyList[0:-2],
                    shortVariableOutputList=nomShortVariableOutputList[
                        0:-2
                    ],  # Avoid a Persalys Bug
                )
            )
            self.txtGetAllResults += tmpGetResultCall
            self.resultSkList.append(index)

        self.chaineDesVariablesOutputEncodee = self.chaineDesVariablesOutputEncodee[
            0:-2
        ]
        self.chaineDesShortVariablesOutput = reduce(
            lambda x, y: x + y, ["a" + str(i) + ", " for i in range(index)]
        )[0:-2]

        sectionExecution = etapeIncertitude.getChildOrChildInBloc("Execution")[0]
        if (
            etapeIncertitude.getChildOrChildInBloc("UncertaintyTool").valeur
            == "Persalys"
        ):
            self.NbDeBranches = sectionExecution.getChildOrChildInBloc(
                "NbDeBranches"
            ).valeur
        if genereScriptPersalys:
            if sectionExecution.getChildOrChildInBloc("ExecutionMode") != None:
                self.ExecutionMode = sectionExecution.getChildOrChildInBloc(
                    "ExecutionMode"
                ).valeur
                self.JobName = sectionExecution.getChildOrChildInBloc("JobName").valeur
                self.ResourceName = sectionExecution.getChildOrChildInBloc(
                    "ResourceName"
                ).valeur
                self.Login = sectionExecution.getChildOrChildInBloc("Login").valeur
                self.WorkDirectory = sectionExecution.getChildOrChildInBloc(
                    "WorkDirectory"
                ).valeur
                self.ResultDirectory = sectionExecution.getChildOrChildInBloc(
                    "ResultDirectory"
                ).valeur
                self.UncertaintyScript = sectionExecution.getChildOrChildInBloc(
                    "UncertaintyScript"
                ).valeur
                if isinstance(self.UncertaintyScript, Accas.PARAMETRE):
                    self.UncertaintyScript = self.UncertaintyScript.valeur
                print("self.UncertaintyScript : ", self.UncertaintyScript)
                NbOfProcs = sectionExecution.getChildOrChildInBloc(
                    "NbOfProcs"
                )  # None si 'desktop', vérification à faire ds jobmanager
                MultiJobStudy = sectionExecution.getChildOrChildInBloc(
                    "MultiJobStudy"
                )  # None si 'desktop'
                if NbOfProcs != None:
                    self.NbOfProcs = NbOfProcs.valeur
                else:
                    self.NbOfProcs = None
                if MultiJobStudy != None:
                    self.MultiJobStudy = MultiJobStudy.valeur
                else:
                    self.MultiJobStudy = None
                self.creeScriptPersalys()
        if etapeIncertitude.getChildOrChildInBloc("UncertaintyTool").valeur == "Uranie":
            if (
                sectionExecution.getChildOrChildInBloc("ExecutionMode").valeur
                == "desktop"
            ):
                self.ExecutionMode = sectionExecution.getChildOrChildInBloc(
                    "ExecutionMode"
                ).valeur
                self.visualization = sectionExecution.getChildOrChildInBloc(
                    "visualization"
                ).valeur
                self.sample_size = sectionExecution.getChildOrChildInBloc(
                    "sample_size"
                ).valeur
                self.launcher_type = sectionExecution.getChildOrChildInBloc(
                    "launcher_type"
                ).valeur
                if self.launcher_type == "distrib":
                    self.parallel_execs = sectionExecution.getChildOrChildInBloc(
                        "parallel_executions"
                    ).valeur
                self.WorkDirectory = sectionExecution.getChildOrChildInBloc(
                    "UWorkDirectory"
                ).valeur
                self.ResultDirectory = sectionExecution.getChildOrChildInBloc(
                    "UResultDirectory"
                ).valeur
                self.cree_script_uranie()

            elif (
                sectionExecution.getChildOrChildInBloc("ExecutionMode").valeur
                == "cluster"
            ):
                self.ExecutionMode = sectionExecution.getChildOrChildInBloc(
                    "ExecutionMode"
                ).valeur
                self.sample_size = sectionExecution.getChildOrChildInBloc(
                    "sample_size"
                ).valeur
                self.parallel_execs = sectionExecution.getChildOrChildInBloc(
                    "parallel_executions"
                ).valeur
                self.WorkDirectory = sectionExecution.getChildOrChildInBloc(
                    "UWorkDirectory"
                ).valeur
                self.ResultDirectory = sectionExecution.getChildOrChildInBloc(
                    "UResultDirectory"
                ).valeur
                self.nb_of_tasks = sectionExecution.getChildOrChildInBloc(
                    "nb_of_tasks"
                ).valeur
                self.nb_of_cpu_per_task = sectionExecution.getChildOrChildInBloc(
                    "nb_of_cpu_per_task"
                ).valeur
                self.memory_per_cpu = sectionExecution.getChildOrChildInBloc(
                    "memory_per_cpu"
                ).valeur
                self.partitions = sectionExecution.getChildOrChildInBloc(
                    "partitions"
                ).valeur
                self.qos = sectionExecution.getChildOrChildInBloc("qos").valeur
                self.account = sectionExecution.getChildOrChildInBloc("account").valeur
                self.walltime = sectionExecution.getChildOrChildInBloc(
                    "walltime"
                ).valeur
                self.job_name = sectionExecution.getChildOrChildInBloc(
                    "job_name"
                ).valeur
                self.output_file = sectionExecution.getChildOrChildInBloc(
                    "output_file"
                ).valeur
                self.error_file = sectionExecution.getChildOrChildInBloc(
                    "error_file"
                ).valeur
                self.email = sectionExecution.getChildOrChildInBloc("email").valeur
                self.email_type = sectionExecution.getChildOrChildInBloc(
                    "email_type"
                ).valeur
                self.liste_of_nodes = sectionExecution.getChildOrChildInBloc(
                    "liste_of_nodes"
                ).valeur
                self.myscript_to_launch = sectionExecution.getChildOrChildInBloc(
                    "myscript_to_launch"
                ).valeur
                self.cree_script_uranie()

        return (1, "")

    def cree_script_uranie(self, debug: bool = False):
        import pickle
        import logging
        import shutil
        import uranie_interface.uncertainty_data as uncertainty_data
        import uranie_interface.serialize_data as serialize_data

        if debug:
            print("def cree_script_uranie(self, debug = True):")

        generatorDir = os.path.abspath(os.path.dirname(__file__))
        if debug:
            print("generatorDir: ", generatorDir)

        ## inputs ##
        u_inputs = uncertainty_data.Inputs()
        for mc in self.lesVariablesInput:
            if mc.variableDeterministe.etape.nature == "OPERATEUR":
                name = (
                    mc.variableDeterministe.etape.sd.nom
                    + "__"
                    + mc.variableDeterministe.nom
                )
            else:
                name = mc.variableDeterministe.nom
            balise = " @" + name + "@ "
            object_name = mc.variableDeterministe.etape.sd.nom
            model_variable = mc.variableDeterministe.nom

            distribution_info = u_inputs.Distribution()
            distribution = mc.getChildOrChildInBloc("Distribution").valeur
            if distribution == "Uniform":
                lower_bound = mc.getChildOrChildInBloc("A").valeur
                upper_bound = mc.getChildOrChildInBloc("B").valeur
                distribution_info.add_distribution_uniform(
                    distribution, lower_bound, upper_bound
                )
            elif distribution == "TruncatedNormal":
                lower_bound = mc.getChildOrChildInBloc("A").valeur
                upper_bound = mc.getChildOrChildInBloc("B").valeur
                standard_deviation = mc.getChildOrChildInBloc("SigmaN").valeur
                mean = mc.getChildOrChildInBloc("MuN").valeur
                distribution_info.add_distribution_truncated_normal(
                    distribution, lower_bound, upper_bound, mean, standard_deviation
                )
            else:
                values = mc.getChildOrChildInBloc("Values").valeur
                distribution_info.add_distribution_user_defined(distribution, values)

            if debug:
                print("balise = ", balise)
            flag = balise.replace(" ", "")
            if debug:
                print("flag   = ", flag)
            u_inputs.add_input(
                balise,
                object_name,
                model_variable,
                distribution_info.distribution_info,
                flag,
            )

        if debug:
            print("len(u_inputs.inputs) = ", len(u_inputs.inputs))
            for i in range(0, len(u_inputs.inputs)):
                print(f"u_inputs.inputs[{i}].balise = {u_inputs.inputs[i].balise}")
                print(
                    f"u_inputs.inputs[{i}].balise_flag = {u_inputs.inputs[i].balise_flag}"
                )
                print(
                    f"u_inputs.inputs[{i}].object_name = {u_inputs.inputs[i].object_name}"
                )
                print(
                    f"u_inputs.inputs[{i}].model_variable = {u_inputs.inputs[i].model_variable}"
                )
                if u_inputs.inputs[i].distribution_info[0].distribution == "Uniform":
                    print(
                        f"u_inputs.inputs[{i}].distribution_info[0].distribution = "
                        f"{u_inputs.inputs[i].distribution_info[0].distribution}"
                    )
                    print(
                        f"u_inputs.inputs[{i}].distribution_info[0].lower_bound = "
                        f"{u_inputs.inputs[i].distribution_info[0].lower_bound}"
                    )
                    print(
                        f"u_inputs.inputs[{i}].distribution_info[0].upper_bound = "
                        f"{u_inputs.inputs[i].distribution_info[0].upper_bound}"
                    )
                elif (
                    u_inputs.inputs[i].distribution_info[0].distribution
                    == "TruncatedNormal"
                ):
                    print(
                        f"u_inputs.inputs[{i}].distribution_info[0].distribution = "
                        f"{u_inputs.inputs[i].distribution_info[0].distribution}"
                    )
                    print(
                        f"u_inputs.inputs[{i}].distribution_info[0].lower_bound = "
                        f"{u_inputs.inputs[i].distribution_info[0].lower_bound}"
                    )
                    print(
                        f"u_inputs.inputs[{i}].distribution_info[0].upper_bound = "
                        f"{u_inputs.inputs[i].distribution_info[0].upper_bound}"
                    )
                    print(
                        f"u_inputs.inputs[{i}].distribution_info[0].standard_deviation = "
                        f"{u_inputs.inputs[i].distribution_info[0].standard_deviation}"
                    )
                    print(
                        f"u_inputs.inputs[{i}].distribution_info[0].mean = "
                        f"{u_inputs.inputs[i].distribution_info[0].mean}"
                    )
                elif (
                    u_inputs.inputs[i].distribution_info[0].distribution
                    == "UserDefined"
                ):
                    print(
                        f"u_inputs.inputs[{i}].distribution_info[0].distribution = "
                        f"{u_inputs.inputs[i].distribution_info[0].distribution}"
                    )
                    print(
                        f"u_inputs.inputs[{i}].distribution_info[0].values = "
                        f"{u_inputs.inputs[i].distribution_info[0].values}"
                    )

        file_balise_dot_comm = self.fichierBalise
        u_inputs.add_file_balise_dot_comm(file_balise_dot_comm)
        if debug:
            print("u_inputs.file_balise_dot_comm = ", u_inputs.file_balise_dot_comm)

        ## propagation ##
        u_propagation = uncertainty_data.Propagation()
        u_propagation.set_sampling_method(self.Methode)
        if debug:
            print("u_propagation.sampling_method = ", self.Methode)

        ## outputs ##
        u_outputs = uncertainty_data.Outputs()
        aggregation_functions = u_outputs.AggregationFunction()
        agg_fct_py = {
            "valeur_a_t=0": "vInitialTime",
            "valeur_a_mi_temps": "vHalfTime",
            "valeur_a_t_final": "vFinalTime",
            "valeur_moyenne": "vMean",
            "valeur_cumulee": "vSum",
            "valeur_minimale": "vMin",
            "valeur_maximale": "vMax",
        }
        if debug:
            print(
                "GENERATOR_UQ.PY: self.lesVariablesOutput = ", self.lesVariablesOutput
            )  # self.lesVariablesOutput.valeur
        for mc in self.lesVariablesOutput:
            type_of_physics = mc.getChildOrChildInBloc("Physique").valeur
            variable_physics = mc.getChildOrChildInBloc("VariablePhysique").valeur
            var_post_processed = mc.getChildOrChildInBloc(
                "VariablePosttraiteeAssociee"
            ).valeur
            nom_agg_fct_list = mc.getChildOrChildInBloc("FonctionDAggregation").valeur
            if debug:
                print("GENERATOR_UQ.PY: nom_agg_fct_list = ", nom_agg_fct_list)
            for nom_agg_fct in nom_agg_fct_list:
                nom_agg_fct = nom_agg_fct.replace(" ", "_")
                nom_agg_fct = nom_agg_fct.replace("-", "_")
                nom_agg_fct = nom_agg_fct.replace("O", "0")
                nom_agg_fct = nom_agg_fct.replace("à", "a")
                nom_agg_fct = nom_agg_fct.replace("é", "e")
                aggregation_functions.add_aggregation_function(
                    nom_agg_fct, agg_fct_py[nom_agg_fct]
                )
            if debug:
                print("GENERATOR_UQ.PY: nom_agg_fct_list = ", nom_agg_fct_list)

            u_outputs.add_output(
                type_of_physics,
                variable_physics,
                var_post_processed,
                aggregation_functions.aggregation_functions,
            )
            if debug:
                for i in range(0, len(u_outputs.outputs)):
                    print(
                        f"u_outputs.outputs[{i}].type_of_physics = "
                        f"{u_outputs.outputs[i].type_of_physics}"
                    )
                    print(
                        f"u_outputs.outputs[{i}].variable_physics = "
                        f"{u_outputs.outputs[i].variable_physics}"
                    )
                    print(
                        f"u_outputs.outputs[{i}].var_post_processed = "
                        f"{u_outputs.outputs[i].var_post_processed}"
                    )
                    print(
                        f"u_outputs.outputs[{i}].aggregation_functions = "
                        f"{u_outputs.outputs[i].aggregation_functions}"
                    )
                    for cle, valeur in u_outputs.outputs[
                        i
                    ].aggregation_functions.items():
                        print(
                            "nom_agg_fct = ", cle, ", aggregation_function = ", valeur
                        )

        ## execution ##
        u_execution = uncertainty_data.Execution()
        u_execution.set_execution_mode(self.ExecutionMode)
        if self.ExecutionMode == "desktop":
            u_execution.set_visualization(self.visualization)
            u_execution.set_sample_size(self.sample_size)
            u_execution.set_launcher_type(self.launcher_type)
            if self.launcher_type == "distrib":
                u_execution.set_parallel_execs(self.parallel_execs)
            u_execution.set_work_dir_name(self.WorkDirectory)
            u_execution.set_output_dir_name(self.ResultDirectory)

        elif self.ExecutionMode == "cluster":
            u_execution.set_sample_size(self.sample_size)
            u_execution.set_parallel_execs(self.parallel_execs)
            u_execution.set_work_dir_name(self.WorkDirectory)
            u_execution.set_output_dir_name(self.ResultDirectory)
            u_execution.set_nb_of_tasks(self.nb_of_tasks)
            u_execution.set_nb_of_cpu_per_task(self.nb_of_cpu_per_task)
            u_execution.set_memory_per_cpu(self.memory_per_cpu)
            u_execution.set_partitions(self.partitions)
            u_execution.set_qos(self.qos)
            u_execution.set_account(self.account)
            u_execution.set_walltime(self.walltime)
            u_execution.set_job_name(self.job_name)
            u_execution.set_output_file(self.output_file)
            u_execution.set_error_file(self.error_file)
            u_execution.set_email(self.email)
            u_execution.set_email_type(self.email_type)
            u_execution.set_liste_of_nodes(self.liste_of_nodes)
            u_execution.set_myscript_to_launch(self.myscript_to_launch)

        if debug:
            if self.ExecutionMode == "desktop":
                print("u_execution.visualization    = ", u_execution.visualization)
                print("u_execution.sample_size      = ", u_execution.sample_size)
                print("u_execution.launcher_type    = ", u_execution.launcher_type)
                if self.launcher_type == "distrib":
                    print("u_execution.parallel_execs   = ", u_execution.parallel_execs)
                print("u_execution.work_dir_name    = ", u_execution.work_dir_name)
                print("u_execution.output_dir_name  = ", u_execution.output_dir_name)

            elif self.ExecutionMode == "cluster":
                print("u_execution.sample_size          = ", u_execution.sample_size)
                print("u_execution.parallel_execs       = ", u_execution.parallel_execs)
                print("u_execution.work_dir_name        = ", u_execution.work_dir_name)
                print(
                    "u_execution.output_dir_name      = ", u_execution.output_dir_name
                )
                print("u_execution.nb_of_tasks          = ", u_execution.nb_of_tasks)
                print(
                    "u_execution.nb_of_cpu_per_task   = ",
                    u_execution.nb_of_cpu_per_task,
                )
                print("u_execution.memory_per_cpu       = ", u_execution.memory_per_cpu)
                print("u_execution.partitions           = ", u_execution.partitions)
                print("u_execution.qos                  = ", u_execution.qos)
                print("u_execution.account              = ", u_execution.account)
                print("u_execution.walltime             = ", u_execution.walltime)
                print("u_execution.job_name             = ", u_execution.job_name)
                print("u_execution.output_file          = ", u_execution.output_file)
                print("u_execution.error_file           = ", u_execution.error_file)
                print("u_execution.email                = ", u_execution.email)
                print("u_execution.email_type           = ", u_execution.email_type)
                print("u_execution.liste_of_nodes       = ", u_execution.liste_of_nodes)
                print(
                    "u_execution.myscript_to_launch   = ",
                    u_execution.myscript_to_launch,
                )

        # Creat the pickle_dir_name directory
        pickle_dir_name = "." + u_execution.output_dir_name + "_uncertainty_parameters"
        pickle_dir_name_path = os.path.join(u_execution.work_dir_name, pickle_dir_name)
        print("pickle_dir_name_path = ", pickle_dir_name_path)
        if os.path.exists(pickle_dir_name_path):
            choice = input(
                f"The output directory '{pickle_dir_name_path}' already exist."
                f" Do you want to overwrite it ? (y/n): "
            ).lower()
            yess = ["y", "yes"]
            nos = ["n", "no"]
            while choice not in yess and choice not in nos:
                choice = input("Please choose 'y' (yes) or 'n' (no)")
            if choice in yess:
                shutil.rmtree(pickle_dir_name_path)
                os.makedirs(pickle_dir_name_path, exist_ok=True)
                print("Overwriting of the directory... Done !")
            else:
                logging.log(
                    logging.WARNING, "Execution terminated. Directory is not removed."
                )
                return 1
        else:
            os.makedirs(pickle_dir_name_path, exist_ok=True)
            print("Writing of the directory... Done !")

        serialize_data.save(
            pickle_dir_name_path, u_inputs, u_propagation, u_outputs, u_execution
        )

        self.txtScript = SCRIPT_URANIE.format(pickle_dir=pickle_dir_name_path)

    def parseMcInputVariable(self, mc, indent):
        if mc.variableDeterministe.etape.nature == "OPERATEUR":
            nom = (
                mc.variableDeterministe.etape.sd.nom
                + "__"
                + mc.variableDeterministe.nom
            )
        else:
            nom = mc.variableDeterministe.nom
        loiDistribution = mc.getChildOrChildInBloc("Distribution").valeur

        # on cherche le bloc qui contient ce qui est necessaire a la loi
        # on est confiant !!!! sur l adequation du catalogue et des attributs des lois persalys
        # reflechir a cela
        chaineArgs = ""
        leBlocDesArgs = None
        for mc in mc.mcListe:
            if (mc.nom).find("b_Model_Variable_") == 0:
                for mcFils in mc.mcListe:
                    if mcFils.nom.find(loiDistribution) > 1:
                        leBlocDesArgs = mcFils
                        break
        if not leBlocDesArgs:
            print("souci pour dumper la loi")
            return ""
        for mcFils in leBlocDesArgs.mcListe:
            chaineArgs += str(mcFils.valeur) + ", "

        return nom, loiDistribution, chaineArgs[0:-2]

    def creeTexteInputVariables(self, indent):
        texte = ""
        for v in self.lesVariablesInput:
            nomVariableInput, loiDistribution, chaineArgs = self.parseMcInputVariable(
                v, indent
            )
            texte += "{}{} = persalys.Input('{}', ot.{}(".format(
                indent, nomVariableInput, nomVariableInput, loiDistribution
            )
            texte += chaineArgs + "))\n"

        return texte

    def creeTexteInputVariablesSummary(self, indent):
        texte = ""
        for v in self.lesVariablesInput:
            nomVariableInput, loiDistribution, chaineArgs = self.parseMcInputVariable(
                v, indent
            )
            texte += "{}'{}{} : {}({})\\n'\n".format(
                2 * indent, indent, nomVariableInput, loiDistribution, chaineArgs
            )
            # texte+=chaineArgs[0:-2]+'))\n'
            # texte+='\n'

        return texte[0:-1]

    def creeScriptPersalys(self, debug=True):
        from functools import reduce

        # chaineDesVariablesInput=reduce(lambda x,y:x+','+y,l)
        def getStrVarList(l, sep=","):
            return reduce(lambda x, y: str(x) + sep + str(y), l)

        def getStrVarStrList(l, sep=","):
            return reduce(
                lambda x, y: x + sep + y, map(lambda x: "'" + str(x) + "'", l)
            )

        def getStrInitList(l):
            return getStrVarList(
                map(lambda x: "self.{} = {}".format(x, x), l), "\n" + 2 * self.indent1
            )

        def getStrReplaceVarList(l):
            return getStrVarList(
                map(lambda x: "'@ {} @': repr(self.{})".format(x, x), l), ","
            )

        def getStrSelfVarList(l):
            return getStrVarList(map(lambda x: "self.{}".format(x), l), ",")

        generatorDir = os.path.abspath(os.path.dirname(__file__))
        nomEtude = "monEtude"  # TODO
        if debug:
            print("nomEtude : ", nomEtude, "generatorDir :", generatorDir)

        self.txtScriptPersalys += headerScriptPersalys

        # TODO: Résorber le cas particulier du HLO en mettant les options de lancement ds le catalog
        if self.ScenarioType == "HLO":
            txtUncertaintyScriptParameters = (
                self.fichierComm + " --cocagne-thermo-solver\ FaSTT"
            )
        else:
            txtUncertaintyScriptParameters = self.fichierComm

        print("self.nomsDesVariablesInput :", self.nomsDesVariablesInput)
        self.txtScriptPersalys += etudeScript.format(
            chaineDesVariablesInput=self.chaineDesVariablesInput,
            chaineSelfDesVariablesInput=getStrSelfVarList(self.nomsDesVariablesInput),
            chaineInitDesVariablesInput=getStrInitList(self.nomsDesVariablesInput),
            commFileBalise=self.fichierBalise,
            commFile=self.fichierComm,
            nproc=self.NbOfProcs,  # En local le nombre de procs est inutile
            # sauf si lancement mpi externe au script applicatif
            # auquel cas != NbOfTasks du jobmanager car
            # on ne compte pas les threads
            replaceDataList=getStrReplaceVarList(self.nomsDesVariablesInput),
            uncertaintyScript=os.path.basename(self.UncertaintyScript),
            uncertaintyScriptParameters=txtUncertaintyScriptParameters,
            workDirectory=self.WorkDirectory,
        )

        txtFonctionPersalys = fonctionPersalys.format(
            currentFile=self.fichierUQModule,
            chaineDesVariablesInput=self.chaineDesVariablesInput,
            getAllResults=self.txtGetAllResults,
            # chaineDesVariablesOutput = self.chaineDesVariablesOutputEncodee
            chaineDesVariablesOutput=self.chaineDesShortVariablesOutput,  # Avoid a Persalys Bug until v9.9
        )
        self.txtScriptPersalys += codePersalys.format(
            fonctionPersalys=txtFonctionPersalys
        )

        ## Propagation des incertitudes :
        ##  Choix de la méthode, de ses paramètres, et des résultats attendus
        if self.Methode == "Taylor":
            txtCentralTendencyPersalys = centralTendencyTaylor
            optionalResult = optionalResultTaylor
            optionalPrintResult = optionalPrintResultTaylor
            printResult = printResultTaylor
            txtResultCT = resultTaylor
        elif self.Methode == "MonteCarlo":
            critereArret = ""
            for mc in self.critereArret.mcListe:
                critereArret += (
                    self.indent1
                    + critereArretMC[mc.nom].format(**{mc.nom: mc.valeur})
                    + "\n"
                )

            txtAdvancedParameterMC = ""
            advancedParameter = ""
            if self.advancedParameter != None:
                for mc in self.advancedParameter.mcListe:
                    advancedParameter += (
                        self.indent1
                        + advancedParameterMC[mc.nom].format(**{mc.nom: mc.valeur})
                        + "\n"
                    )

            txtCentralTendencyPersalys = centralTendencyMC.format(
                critereArretMC=critereArret,
                advancedParameterMC=advancedParameter,
                BlockSize=self.Blocksize,
            )
            optionalResult = optionalResultMC
            optionalPrintResult = optionalPrintResultMC
            printResult = printResultMC
            txtResultCT = resultMC
        else:
            return (0, "Impossible de gérer la méthode :", self.Methode)

        result = ""
        optionalResultNames = []
        if self.Result:
            for mc in self.Result.mcListe:
                # print('mc : ',mc)
                # print('mc.nature : ',mc.nature)
                # print('mc.valeur : ',mc.valeur)
                if mc.nom == "EmpiricalQuantile" and mc.valeur == "yes":
                    mc_nom = (
                        mc.nom[0].lower() + mc.nom[1:]
                    )  ##TODO: Utiliser un nv dict commun des symboles avec optionalResult
                    optionalResultNames.append(mc_nom)
                    empiricalQuantile_Order = self.Result.getChildOrChildInBloc(
                        "EmpiricalQuantile_Order"
                    )
                    result += (
                        self.indent1
                        + optionalResult[mc.nom].format(
                            **{
                                empiricalQuantile_Order.nom: empiricalQuantile_Order.valeur
                            }
                        )
                        + "\n"
                    )
                    result += (
                        self.indent1
                        + optionalPrintResult["EmpiricalQuantile_Order"]
                        + "\n"
                    )
                    result += self.indent1 + optionalPrintResult[mc.nom] + "\n"
                elif mc.nature == "MCSIMP" and mc.valeur == "yes":
                    mc_nom = (
                        mc.nom[0].lower() + mc.nom[1:]
                    )  ##TODO: Utiliser un nv dict commun des symboles avec optionalResult
                    optionalResultNames.append(mc_nom)
                    result += self.indent1 + optionalResult[mc.nom] + "\n"
                    # result+= self.indent1+optionalPrintResult[mc.nom] + '\n'

        # print('result:',result)
        # print('txtResultCT:',txtResultCT)
        optionalResultList = getStrVarList(optionalResultNames)
        optionalResultStrList = getStrVarStrList(optionalResultNames)
        post_csv_rnScript = os.path.basename(self.ScriptPosttraitement).split(".")[0]
        post_csv_rnPath = os.path.dirname(self.ScriptPosttraitement)
        print(post_csv_rnScript)
        print(post_csv_rnPath)
        txtPrintResult = printResult.format(
            post_csv_rnScript=post_csv_rnScript,
            post_csv_rnPath=post_csv_rnPath,
            optionalResultList=optionalResultList,
            optionalResultStrList=optionalResultStrList,
            resultSkList=getStrVarList(self.resultSkList),
            Uncertain_inputs=self.creeTexteInputVariablesSummary(self.indent1),
        )
        txtResult = txtResultCT.format(optionalResult=result)
        txtResult += txtPrintResult

        # TODO ;: Tester si Cluster== Gaia, ajouter les champs suivants
        # resourceName = 'gaia'
        # login='C65845'
        # workDirectory = '/scratch/'+login+'/workingdir/persalys_light' #TODO: path.join
        # resultDirectory = '/tmp/result_0'
        wckey = "P11N0:SALOME"

        inFiles = []
        inFiles.append(os.path.join(generatorDir, "incertainty_tools.py"))
        pyFile = self.fichierUQExe
        inFiles.append(os.path.join(self.cheminFichierComm, pyFile))
        pyFile = self.fichierBalise
        inFiles.append(os.path.join(self.cheminFichierComm, pyFile))
        scriptFile = os.path.abspath(self.UncertaintyScript)
        inFiles.append(scriptFile)
        postFile = os.path.abspath(self.ScriptPosttraitement)
        inFiles.append(postFile)

        if self.ExecutionMode == "cluster":
            txtYacsJobClusterParameters = yacsJobClusterParameters.format(
                nprocs=self.NbOfProcs, wckey=wckey
            )
        else:
            txtYacsJobClusterParameters = ""

        txtYacsJobParameters = yacsJobParameters.format(
            nomEtude=self.JobName,
            workDirectory=self.WorkDirectory,
            resultDirectory=self.ResultDirectory,
            resourceName=self.ResourceName,
            nbBranches=self.NbDeBranches,
            inFiles=repr(inFiles),
        )
        txtYacsJobParameters += txtYacsJobClusterParameters
        if self.MultiJobStudy != None and self.MultiJobStudy == True:
            txtYacsJobParameters += yacsJobClusterMultiJob

        self.txtScriptPersalys += mainPersalys.format(
            nomEtude=nomEtude,
            inputVariableInitList=self.creeTexteInputVariables(self.indent1),
            outputVariableInitList=self.txtOutputVariableInitList,
            # outputVariableInitList = '#Not yet implemented',
            inputHeaderPersalys=inputHeaderPersalys.format(indent=self.indent1),
            chaineDesVariablesInput=self.chaineDesVariablesInput,
            outputHeaderPersalys=outputHeaderPersalys.format(indent=self.indent1),
            chaineDesVariablesOutput=self.chaineDesVariablesOutputEncodee,
            yacsJobParameters=txtYacsJobParameters,
            centralTendencyPersalys=txtCentralTendencyPersalys,
            scenarioType=self.ScenarioType,
            resultPersalys=txtResult,
        )
        self.txtScript = self.txtScriptPersalys
