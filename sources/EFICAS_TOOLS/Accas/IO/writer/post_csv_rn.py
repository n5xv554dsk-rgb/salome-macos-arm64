# Exemple de script pour lire la sortie csv du banc d'intégration odysee
#
# Lecture des valeurs dans le csv et renvoi de la valeur après application de la fonction d'agragation max,min et moy

# To get the history in python
# print('\n'.join([str(readline.get_history_item(i + 1)) for i in range(readline.get_current_history_length())]))


def vMax(arrayNx2):
    import numpy as np

    return np.apply_along_axis(max, 0, arrayNx2[:, 1]).item()


def vMin(arrayNx2):
    import numpy as np

    return np.apply_along_axis(min, 0, arrayNx2[:, 1]).item()


def vMean(arrayNx2):
    import numpy as np
    import statistics

    return np.apply_along_axis(statistics.mean, 0, arrayNx2[:, 1]).item()


def vSum(arrayNx2):
    import numpy as np

    return np.apply_along_axis(sum, 0, arrayNx2[:, 1]).item()


def vInitialTime(arrayNx2):
    import numpy as np

    # Dates on first column, Values on second one
    timeColumn = arrayNx2[:, 0]
    # Tmin=np.apply_along_axis(min, 0, timeColumn)
    # assert(arrayNx2[0,0]==Tmin)
    idxTmin = timeColumn.argmin()
    assert idxTmin == 0

    valTmin = arrayNx2[idxTmin][1].item()

    return valTmin


def vFinalTime(arrayNx2):
    import numpy as np

    # Dates on first column, Values on second one
    timeColumn = arrayNx2[:, 0]
    # Tmax=np.apply_along_axis(max, 0, timeColumn)
    # assert(arrayNx2[timeColumn.size,0]==Tmax)
    idxTmax = timeColumn.argmax()
    idxMax = timeColumn.size - 1
    assert idxTmax == idxMax

    valTmax = arrayNx2[idxTmax][1].item()

    return valTmax


def vHalfTime(arrayNx2):
    import numpy as np

    # Dates on first column, Values on second one
    timeColumn = arrayNx2[:, 0]
    Tmin = np.apply_along_axis(min, 0, timeColumn)
    Tmax = np.apply_along_axis(max, 0, timeColumn)

    Thalf = (Tmax - Tmin) / 2 + Tmin
    idxThalf = (np.abs(timeColumn - Thalf)).argmin()
    valThalf = arrayNx2[idxThalf][1].item()

    return valThalf


def get_result_from_csv(
    variableName: str, functionList, filename: str = None, delimiter=","
):
    from csv import reader
    import numpy as np

    transientName = "Transient duration"

    # ex: file_csv = "Fuel temperature@Thermalhydraulics@MAX.csv"
    if filename == None:
        filename = variableName + ".csv"

    with open(filename, "r") as csv_file:
        csv_reader = reader(csv_file, delimiter=delimiter)
        header = next(csv_reader)
        header_transient_name = header[1]
        header_variable_name = header[2]
        if header_variable_name != variableName:
            print(
                sys.stderr,
                "The variable name {} differs from the file's header one {}".format(
                    variableName, header_variable_name
                ),
            )
            return -1  # TODO Exception ?
        if header_transient_name != transientName:
            print(
                sys.stderr,
                "The transient duration name {} differs from the file's header one {}".format(
                    transientName, header_transient_name
                ),
            )
            return -1  # TODO Exception ?

    date_value_array = np.loadtxt(filename, delimiter=delimiter, skiprows=1)[:, 1:3]
    valList = []
    for func in functionList:
        valList.append(func(date_value_array))
    return valList


# Fuel-temperature_Thermalhydraulics_MAX
#                                    value at t_initial  value at t_mid  value at t_final     mean value  cumsum value   min value    max value
# MeanFirstOrder (°C):                      1113.040047     1009.112047        968.544065  207597.218716   1113.040047  968.544064  1032.821984
# StandardDeviationFirstOrder (°C):          203.302658      250.504351        255.172144   43724.195535    203.302658  256.008518   217.533311


def write_result_from_persalys(resultNp, indexNp, resSk, outputs):
    import numpy as np
    import pandas as pnd
    from functools import reduce

    # resultNp = np.array([meanFirstOrder, meanSecondOrderOrder, standardDeviationFirstOrder ])
    # Lignes de résultats demandés pour toutes les fcts d'aggrégation en colonne
    # resultNp = np.array([ {optionalResultList} ])
    # Noms de lignes
    # index = ['meanFirstOrder', 'meanSecondOrderOrder', 'standardDeviationFirstOrder' ]
    # indexNp = [ {optionalResultStrList} ]
    nResult = len(indexNp)
    # Tableau skyline localisant les variables (hors fctAgg) dans le tableau de résultat global
    # resultSk = [0,7,10]
    # resSk = [ {resultSkList} ]
    nOutVar = len(resSk) - 1

    print("\n")
    for i in range(nOutVar):
        # Récupère les couples (fctAggrégation,Nom de variable ss fct Agg)
        #  des champs de description des sorties.
        #  Les sorties concernées proviennent de la section de résultatNp
        #  qui doit correspondre à une même variable hors fct Agg
        fctAgg_outVarName = list(
            map(lambda o: eval(o.getDescription()), outputs[resSk[i] : resSk[i + 1]])
        )
        outVarName = fctAgg_outVarName[0][1]
        checkOutVarName = reduce(
            lambda n1, n2: n1 == n2,
            [True] + list(map(lambda o: o[1] == outVarName, fctAgg_outVarName)),
        )
        assert checkOutVarName == True
        print(outVarName)
        columns = list(map(lambda o1: o1[0], fctAgg_outVarName))
        resultDf = pnd.DataFrame(
            resultNp[:, resSk[i] : (resSk[i + 1])], index=indexNp, columns=columns
        )
        print(resultDf, "\n")
        # name_csv = str.replace(str.replace(outVarName,"@","_"),' ','-')
        name_csv = outVarName
        resultDf.to_csv(name_csv + "-uncertainty.csv")
