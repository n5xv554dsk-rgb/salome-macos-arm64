//////////////////////////////////////////////////////////////
// Copyright (C) 2013-2026 CEA/DES
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published
// by the Free Software Foundation, either version 3 of the License, or any
// later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.
//////////////////////////////////////////////////////////////

#ifndef __PMMLLIB_H__
#define __PMMLLIB_H__

struct _xmlDoc;
typedef struct _xmlDoc *xmlDocPtr;
struct _xmlNode;
typedef struct _xmlNode *xmlNodePtr;
typedef unsigned char xmlChar;

#include <map>
#include <set>
#include <sstream>
#include <string>
#include <vector>
#include <libxml/xpathInternals.h>

namespace PMMLlib {

template <typename T> std::string NumberToString(T Number) {
    std::ostringstream ss;
    ss << Number;
    return ss.str();
}
template <typename T> T StringToNumber(std::string const strValue) {
    T res;
    std::istringstream ss(strValue);
    ss >> res;
    return res;
}

/**
 * Enumeration to type the PMML file.
 * UNDEFINED: not yet defined
 * ANN: Artificial Neural Network
 * LR:  Linear Regression
 * GAUSS: Gaussian Process
 * BAYESIAN: Bayesian Network
 *
 * @see http://www.dmg.org/v4-2/GeneralStructure.html#xsdGroup_MODEL-ELEMENT
 */
enum PMMLType { kUNDEFINED, kANN, kLR, kGAUSS, kBAYESIAN };

/**
 * @see http://www.dmg.org/v4-2/NeuralNetwork.html#xsdType_ACTIVATION-FUNCTION
 */
enum PMMLActivationFunction { kIDENTITY, kTANH, kLOGISTIC };

/**
 * @see http://www.dmg.org/v4-2/GeneralStructure.html#xsdType_MINING-FUNCTION
 */
enum PMMLMiningFunction { kREGRESSION };

/**
 * @see
 * http://www.dmg.org/v4-3/GaussianProcess.html#xsdElement_GaussianProcessModel
 */
enum PMMLKernelType {
    kRadialBasis,
    kARDSquaredExponential,
    kAbsoluteExponential,
    kGeneralizedExponential
};

/**
 * Class PMMLlib
 */
class PMMLlib {

  private:
    bool _log;                     //!< Log Printing
    std::string _pmmlFile;         //!< Name of the associated PMML file
    xmlDocPtr _doc;                //!< Associated DOM documents
    xmlNodePtr _rootNode;          //!< Root node of the document
    xmlNodePtr _currentNode;       //!< Pointer to the current node
    int _nbModels;                 //!< Number of models (all kinds)
    std::string _currentModelName; //!< Name of the current model
    PMMLType _currentModelType;    //!< Type of the current model
    xmlNodePtr _currentModelNode;  //!< Pointer to the current model node

    /** @defgroup general General methods
     *  Common methods to all kinds of PMML files and models
     *  @{
     */
  public:
    PMMLlib(std::string file, bool log = false);
    PMMLlib(bool log = false);
    ~PMMLlib();

    void SearchForModel(PMMLType &modelType, std::string &modelName);

    void SetCurrentModel(std::string modelName, PMMLType type);
    void SetCurrentModel(std::string modelName);
    void SetCurrentModel();
    std::string makeLog() const;
    void printLog() const;

    void AddDataField(std::string name, std::string displayName,
                      std::string optype, std::string dataType,
                      std::string closure, double leftMargin,
                      double rightMargin, bool interval = false);
    void AddMiningSchema(std::string name, std::string usageType);
    void SetHeader(std::string copyright, std::string description,
                   std::string appName, std::string appVersion,
                   std::string annotation);
    void UnlinkNode();
    void BackupNode();
    int GetModelsNb();
    void Write();
    void Write(std::string file);
    PMMLType GetCurrentModelType();
    std::string GetCurrentModelName();

  private:
    xmlNodePtr GetChildByName(xmlNodePtr node, std::string nodename);
    xmlNodePtr GetPtr(int ann_index, std::string name);
    xmlNodePtr GetPtr(std::string ann_name, std::string name);

    int CountOccurenceModel(std::string model);
    void CountModels();
    int CountNeuralNetModels();
    int CountRegressionModels();
    int CountGaussianProcessModels();
    int CountBayesianNetModels();
    void SetRootNode();
    std::string GetModelName(xmlNodePtr node);
    std::string GetTypeString();
    std::string GetTypeString(PMMLType modelType);
    void GetModelTypeList(std::vector<PMMLType> &ModelTypeList);

    /** @} */ // end of group general

    /** @defgroup ann Methods dedicated to neural networks
     *  Methods dedicated to neural networks
     *  @{
     */
  public:
    void AddNeuralNetwork(std::string modelName,
                          PMMLMiningFunction functionName);
    void AddNeuralInput(int id, std::string inputName, std::string optype,
                        std::string dataType, double orig1, double norm1,
                        double orig2, double norm2);
    void AddNeuralLayer(PMMLActivationFunction activationFunction);
    void AddNeuron(int id, double bias, int conNb, int firstFrom,
                   std::vector<double> weights);
    void AddNeuralOutput(int outputNeuron, std::string outputName,
                         std::string optype, std::string dataType, double orig1,
                         double norm1, double orig2, double norm2);
    int GetNbInputs();
    int GetNbOutputs();
    std::string GetNameInput(int input_index);
    std::string GetNameOutput(int output_index);
    int GetNormalizationType();
    void GetNormalisationInput(int input_index, double *dnorm);
    void GetNormalisationOutput(int output_index, double *dnorm);
    int GetNbHiddenLayers();
    int GetNbLayers();
    int GetNbNeuronsAtLayer(int layer_index);
    double GetNeuronBias(int layer_index, int neu_index);
    double GetPrecNeuronSynapse(int layer_index, int neu_index, int prec_index);
    void SetNeuralNetName(int ann_index, std::string ann_name);
    std::string ReadNetworkStructure();

  private:
    xmlNodePtr GetNeuralNetPtr(std::string ann_name);
    xmlNodePtr GetNeuralNetPtr(int ann_index);
    void CheckNeuralNetwork();
    /** @} */ // end of group ann

    /** @defgroup ln Methods dedicated to linear regression
     *  Methods dedicated to linear regression
     *  @{
     */
  public:
    void AddRegressionModel(std::string modelName,
                            PMMLMiningFunction functionName,
                            std::string targetFieldName);
    // void AddRegressionTable();
    void AddRegressionTable(double intercept = 0.0);
    void AddNumericPredictor(std::string neuronName, int exponent,
                             double coefficient);
    void AddPredictorTerm(double coefficient,
                          std::vector<std::string> fieldRef);
    bool HasIntercept();
    double GetRegressionTableIntercept();
    int GetNumericPredictorNb();
    int GetPredictorTermNb();
    std::string GetNumericPredictorName(int num_pred_index);
    std::string GetPredictorTermName(int num_pred_index);
    double GetNumericPredictorCoefficient(int num_pred_index);
    double GetPredictorTermCoefficient(int pred_term_index);
    int GetPredictorTermFieldRefNb(int pred_term_index);
    std::string GetPredictorTermFieldRefName(int pred_term_index,
                                             int field_index);
    std::string ReadRegressionStructure();

  private:
    xmlNodePtr GetRegressionPtr(int reg_index);
    xmlNodePtr GetRegressionPtr(std::string reg_name);
    void CheckRegression();

    /** @} */ // end of group ln

    /** @defgroup GAUSS Methods dedicated to Gaussian Process
     *  Methods dedicated to Gaussian Process
     *  @{
     */
  public:
    void importGaussianProcess(std::string modelName);

    std::string GetKernelTypeString(PMMLKernelType kernel);

    void AddGaussianProcess(std::string modelName,
                            PMMLMiningFunction functionName);
    void AddGaussianKernelType(PMMLKernelType kernel, double noiseVariance,
                               int n, double *lambda, double degre = 1);
    void AddTrainingInstances(int nS, int nX,
                              std::vector<std::string> inputNames,
                              std::string outputName, double *Xobs,
                              double *xNormParams, double *Yobs);

    void GetDataDictionary(int &nbFields, std::vector<std::string> &fieldNames,
                           std::vector<bool> &intervalstatus,
                           std::vector<double> &varMin,
                           std::vector<double> &varMax);
    void GetMiningSchema(std::set<std::string> &InputNames,
                         std::set<std::string> &OutputNames);
    void GetGaussianKernelType(PMMLKernelType &kernel, double &noiseVariance,
                               int &n, std::vector<double> &lambda,
                               double &degre);
    void GetTrainingInstances(std::map<std::string, std::vector<double>> &table,
                              int &recordCount);

    void GetGaussianProcess(std::vector<std::string> fieldNames,
                            std::set<std::string> &InputNames,
                            std::set<std::string> &OutputNames,
                            PMMLKernelType &kernel, int &ndimE,
                            double &noiseVariance, std::vector<double> &lambda,
                            int &recordCount,
                            std::map<std::string, std::vector<double>> &table);

  private:
    xmlNodePtr GetGaussianProcessPtr(std::string gp_name);
    xmlNodePtr GetGaussianProcessPtr(int gp_index);
    void CheckGaussianProcess();
    void GetKernelList(std::vector<PMMLKernelType> &kernelList);
    /** @} */ // end of group gaussian process

    /** @defgroup BAYESIAN Methods dedicated to Bayesian Network
     *  Methods dedicated to bayesian network
     *  @{
     */
  public:
  private:
    xmlNodePtr GetBayesianNetPtr(std::string gp_name);
    xmlNodePtr GetBayesianNetPtr(int gp_index);
    void CheckBayesianNetwork();
    /** @} */ // end of group gaussian process

    /** @defgroup export Methods dedicated to file export
     *  Methods dedicated to file export
     *  @{
     */
  private:
    void fillVectorsForExport(int nInput, int nOutput, int nHidden,
                              int normType, std::vector<double> &minInput,
                              std::vector<double> &maxInput,
                              std::vector<double> &minOutput,
                              std::vector<double> &maxOutput,
                              std::vector<double> &valW);

  public:
    void ExportCpp(std::string file, std::string functionName,
                   std::string header);
    void ExportFortran(std::string file, std::string functionName,
                       std::string header);
    void ExportPython(std::string file, std::string functionName,
                      std::string header);
    std::string ExportPyStr(std::string functionName, std::string header);

  private:
    void ExportNeuralNetworkCpp(std::string file, std::string functionName,
                                std::string header);
    void ExportNeuralNetworkFortran(std::string file, std::string functionName,
                                    std::string header);
    void ExportNeuralNetworkPython(std::string file, std::string functionName,
                                   std::string header);
    std::string ExportNeuralNetworkPyStr(std::string functionName,
                                         std::string header);

    void ExportLinearRegressionCpp(std::string, std::string, std::string);
    void ExportLinearRegressionFortran(std::string, std::string, std::string);
    void ExportLinearRegressionPython(std::string, std::string, std::string);
    std::string ExportLinearRegressionPyStr(std::string functionName,
                                            std::string header);
    /** @} */ // end of group export
  private:
    /*!     * Conversion from a libxml2 string (xmlChar *) to a standard C++
     * string.
     *
     *    \param xs a constant libxml string.
     *    \return a C++ std::string (contains the same text as xs).
     */
    std::string _xmlCharToString(const xmlChar *xs) const;
    /*!
     * Conversion from a standard C++ string to a libxml2 string (xmlChar *)
     *
     *    \param s a constant C++ std::string.
     *    \return a libxml string (contains the same text as s)
     *
     * The caller of this function must free the result when it's not needed
     * anymore (using xmlFree)
     */
    xmlChar *_stringToXmlChar(const std::string &s) const;

    std::string _getProp(const xmlNodePtr node, std::string const &prop) const;
};
}

#endif //__PMMLLIB_H__
