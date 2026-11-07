// Copyright (C) 2019-2026 EDF
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
//
// See http://www.salome-platform.org/ or email : webmaster.salome@opencascade.com
//
#include "StudyGeneralTest.hxx"
#include "../Launcher.hxx" // possible conflict with KERNEL/Launcher/Launcher.hxx
#include <algorithm>
#include <ctime>
#include <iomanip>
#include <sstream>

void SampleTest::setUp()
{
}

void SampleTest::tearDown()
{
}

void SampleTest::cleanUp()
{
}

void SampleTest::fullStudy()
{
    std::list<std::string> resources = ydefx::JobParametersProxy::AvailableResources();
    CPPUNIT_ASSERT(resources.size() > 0);

    ydefx::JobParametersProxy jobParams;
    jobParams.configureResource("localhost");
    std::time_t t = std::time(nullptr);
    std::tm tm = *std::localtime(&t);
    std::stringstream ss;
    ss << jobParams.work_directory() << "/GeneralTest"
       << std::put_time(&tm, "%m%d%H%M%S");
    jobParams.work_directory(ss.str());
    jobParams.createResultDirectory("/tmp");
    std::string pyScript =
"def _exec(a, b):\n"
"  d = a / b\n"
"  t = ['object which needs pickel protocol']\n"
"  return d,t\n";

    ydefx::PyStudyFunction studyFunction;
    studyFunction.loadString(pyScript);
    CPPUNIT_ASSERT(studyFunction.isValid());
    const std::list<std::string>& inputs = studyFunction.inputNames();
    CPPUNIT_ASSERT(std::find(inputs.begin(), inputs.end(), "a")!=inputs.end());
    CPPUNIT_ASSERT(std::find(inputs.begin(), inputs.end(), "b")!=inputs.end());
    const std::list<std::string>& outputs = studyFunction.outputNames();
    CPPUNIT_ASSERT(std::find(outputs.begin(), outputs.end(), "d")
                                                              != outputs.end());
    CPPUNIT_ASSERT(std::find(outputs.begin(), outputs.end(), "t")
                                                              != outputs.end());

    ydefx::Sample<double, py2cpp::PyPtr > sample;
    std::vector<double> a_vals = {1.1, 4.4, 9, 4};
    std::vector<double> b_vals = {1.1, 2.2, 3, 1};
    sample.inputs<double>().set("a", a_vals);
    sample.inputs<double>().set("b", b_vals);
    sample.outputs<double>().addName("d");
    sample.outputs<py2cpp::PyPtr >().addName("t");

    ydefx::Launcher l;
    ydefx::Job* myJob = l.submitMonoPyJob(studyFunction, sample, jobParams);
    CPPUNIT_ASSERT(myJob);
    CPPUNIT_ASSERT(l.lastError().empty());
    std::string jobDump = myJob->dump();
    CPPUNIT_ASSERT(myJob->lastError().empty());
    std::string jobState = myJob->state();
    CPPUNIT_ASSERT(myJob->lastError().empty());
    CPPUNIT_ASSERT(jobState == "QUEUED" || jobState == "RUNNING"
                   || jobState == "FINISHED");
    double progress = myJob->progress();
    CPPUNIT_ASSERT(progress >= 0.0 && progress <= 1.0 );
    CPPUNIT_ASSERT(myJob->lastError().empty());
    bool ok = myJob->wait();
    CPPUNIT_ASSERT(ok);
    CPPUNIT_ASSERT(myJob->lastError().empty());
    jobState = myJob->state();
    CPPUNIT_ASSERT(jobState == "FINISHED");
    progress = myJob->progress();
    CPPUNIT_ASSERT(progress == 1.0);
    ok = myJob->fetch();
    CPPUNIT_ASSERT(ok);
    CPPUNIT_ASSERT(myJob->lastError().empty());
    std::vector<double> expectedResult = {1,2,3,4};
    const std::vector<double>& result = sample.outputs<double>().get("d");
    CPPUNIT_ASSERT(expectedResult == result);
    const std::vector<py2cpp::PyPtr>& pyobjResult
                                     = sample.outputs<py2cpp::PyPtr>().get("t");
    for(const py2cpp::PyPtr& obj : pyobjResult)
      CPPUNIT_ASSERT(obj.repr() == "['object which needs pickel protocol']");
    delete myJob;

    // test a case of error
    std::string wrongScript = "wrong 'script";
    ydefx::PyStudyFunction wrongStudy;
    wrongStudy.loadString(wrongScript);
    CPPUNIT_ASSERT(!wrongStudy.isValid());
    myJob = l.submitMonoPyJob(wrongStudy, sample, jobParams);
    CPPUNIT_ASSERT(myJob == nullptr);
    CPPUNIT_ASSERT(l.lastError().find("SyntaxError") != std::string::npos);
}

void SampleTest::genericStudy()
{
    std::list<std::string> resources = ydefx::JobParametersProxy::AvailableResources();
    CPPUNIT_ASSERT(resources.size() > 0);

    ydefx::JobParametersProxy jobParams;
    jobParams.configureResource("localhost");
    std::time_t t = std::time(nullptr);
    std::tm tm = *std::localtime(&t);
    std::stringstream ss;
    ss << jobParams.work_directory() << "/GenericTest"
       << std::put_time(&tm, "%m%d%H%M%S");
    jobParams.work_directory(ss.str());
    jobParams.createResultDirectory("/tmp");
    std::string pyScript =
"def _exec(a, b):\n"
"  d = a / b\n"
"  t = ['object which needs pickel protocol']\n"
"  return d,t\n";

    ydefx::PyStudyFunction studyFunction;
    studyFunction.loadString(pyScript);
    CPPUNIT_ASSERT(studyFunction.isValid());
    const std::list<std::string>& inputs = studyFunction.inputNames();
    CPPUNIT_ASSERT(std::find(inputs.begin(), inputs.end(), "a")!=inputs.end());
    CPPUNIT_ASSERT(std::find(inputs.begin(), inputs.end(), "b")!=inputs.end());
    const std::list<std::string>& outputs = studyFunction.outputNames();
    CPPUNIT_ASSERT(std::find(outputs.begin(), outputs.end(), "d")
                                                              != outputs.end());
    CPPUNIT_ASSERT(std::find(outputs.begin(), outputs.end(), "t")
                                                              != outputs.end());

    ydefx::Sample<double, py2cpp::PyPtr > sample;
    std::vector<double> a_vals = {1.1, 4.4, 9, 4};
    std::vector<double> b_vals = {1.1, 2.2, 3, 1};
    sample.inputs<double>().set("a", a_vals);
    sample.inputs<double>().set("b", b_vals);
    sample.outputs<double>().addName("d");
    sample.outputs<py2cpp::PyPtr >().addName("t");

    py2cpp::PyFunction objConstructor;
    objConstructor.loadExp("pydefx", "PyStudy");
    py2cpp::PyPtr pyStudy = objConstructor();

    ydefx::Launcher l;
    ydefx::Job* myJob = l.submitPyStudyJob(pyStudy, studyFunction, sample, jobParams);
    CPPUNIT_ASSERT(myJob);
    CPPUNIT_ASSERT(l.lastError().empty());
    std::string jobDump = myJob->dump();
    CPPUNIT_ASSERT(myJob->lastError().empty());
    std::string jobState = myJob->state();
    CPPUNIT_ASSERT(myJob->lastError().empty());
    CPPUNIT_ASSERT(jobState == "QUEUED" || jobState == "RUNNING"
                   || jobState == "FINISHED");
    double progress = myJob->progress();
    CPPUNIT_ASSERT(progress >= 0.0 && progress <= 1.0 );
    CPPUNIT_ASSERT(myJob->lastError().empty());
    bool ok = myJob->wait();
    CPPUNIT_ASSERT(ok);
    CPPUNIT_ASSERT(myJob->lastError().empty());
    jobState = myJob->state();
    CPPUNIT_ASSERT(jobState == "FINISHED");
    progress = myJob->progress();
    CPPUNIT_ASSERT(progress == 1.0);
    ok = myJob->fetch();
    CPPUNIT_ASSERT(ok);
    CPPUNIT_ASSERT(myJob->lastError().empty());
    std::vector<double> expectedResult = {1,2,3,4};
    const std::vector<double>& result = sample.outputs<double>().get("d");
    CPPUNIT_ASSERT(expectedResult == result);
    const std::vector<py2cpp::PyPtr>& pyobjResult
                                     = sample.outputs<py2cpp::PyPtr>().get("t");
    for(const py2cpp::PyPtr& obj : pyobjResult)
      CPPUNIT_ASSERT(obj.repr() == "['object which needs pickel protocol']");
    delete myJob;

    // test a case of error
    std::string wrongScript = "wrong 'script";
    ydefx::PyStudyFunction wrongStudy;
    wrongStudy.loadString(wrongScript);
    CPPUNIT_ASSERT(!wrongStudy.isValid());
    myJob = l.submitPyStudyJob(pyStudy, wrongStudy, sample, jobParams);
    CPPUNIT_ASSERT(myJob == nullptr);
    CPPUNIT_ASSERT(l.lastError().find("SyntaxError") != std::string::npos);
}

void SampleTest::emptyError()
/// Test the case of an error with an empty description.
{
    std::list<std::string> resources = ydefx::JobParametersProxy::AvailableResources();
    CPPUNIT_ASSERT(resources.size() > 0);

    ydefx::JobParametersProxy jobParams;
    jobParams.configureResource("localhost");
    std::time_t t = std::time(nullptr);
    std::tm tm = *std::localtime(&t);
    std::stringstream ss;
    ss << jobParams.work_directory() << "/ErrorTest"
       << std::put_time(&tm, "%m%d%H%M%S");
    jobParams.work_directory(ss.str());
    jobParams.createResultDirectory("/tmp");
    std::string pyScript =
"def _exec(x):\n"
"  if x==0:\n"
"    raise RuntimeError("")\n" // error with an empty description
"  y = x * x\n"
"  return y\n";

    ydefx::PyStudyFunction studyFunction;
    studyFunction.loadString(pyScript);
    CPPUNIT_ASSERT(studyFunction.isValid());

    ydefx::Sample<double, py2cpp::PyPtr > sample;
    // set default value for not computed and failed points
    sample.outputs<double>().setDefault(std::nan(""));
    std::vector<double> x_vals = {0., 1., 2., 3.};
    sample.inputs<double>().set("x", x_vals);
    sample.outputs<double>().addName("y");

    py2cpp::PyFunction objConstructor;
    objConstructor.loadExp("pydefx", "PyStudy");
    py2cpp::PyPtr pyStudy = objConstructor();

    ydefx::Launcher l;
    ydefx::Job* myJob = l.submitPyStudyJob(pyStudy, studyFunction, sample, jobParams);
    CPPUNIT_ASSERT(myJob);
    bool ok = myJob->wait();
    CPPUNIT_ASSERT(ok);
    CPPUNIT_ASSERT(myJob->lastError().empty());
    std::string jobState = myJob->state();
    CPPUNIT_ASSERT(jobState == "FINISHED");
    ok = myJob->fetch();
    CPPUNIT_ASSERT(ok);
    CPPUNIT_ASSERT(myJob->lastError().empty());
    CPPUNIT_ASSERT(sample.pointState(0) == ydefx::ExecutionState::ERROR);
    const std::vector<double>& result = sample.outputs<double>().get("y");
    CPPUNIT_ASSERT(std::isnan(result[0]));
    CPPUNIT_ASSERT(1. == result[1]);
    CPPUNIT_ASSERT(4. == result[2]);
    CPPUNIT_ASSERT(9. == result[3]);
    CPPUNIT_ASSERT(!sample.getError(0).empty());
    delete myJob;
}

void SampleTest::cancelStudy()
/// Test cancel on a running study.
{
    std::list<std::string> resources = ydefx::JobParametersProxy::AvailableResources();
    CPPUNIT_ASSERT(resources.size() > 0);

    ydefx::JobParametersProxy jobParams;
    jobParams.configureResource("localhost");
    std::time_t t = std::time(nullptr);
    std::tm tm = *std::localtime(&t);
    std::stringstream ss;
    ss << jobParams.work_directory() << "/CancelTest"
       << std::put_time(&tm, "%m%d%H%M%S");
    jobParams.work_directory(ss.str());
    jobParams.createResultDirectory("/tmp");
    std::string pyScript =
"import time\n"
"def _exec(a):\n"
"  time.sleep(5)\n"
"  r = a\n"
"  return r\n";

    ydefx::PyStudyFunction studyFunction;
    studyFunction.loadString(pyScript);
    CPPUNIT_ASSERT(studyFunction.isValid());
    const std::list<std::string>& inputs = studyFunction.inputNames();
    CPPUNIT_ASSERT(std::find(inputs.begin(), inputs.end(), "a")!=inputs.end());
    const std::list<std::string>& outputs = studyFunction.outputNames();
    CPPUNIT_ASSERT(std::find(outputs.begin(), outputs.end(), "r")
                                                              != outputs.end());

    ydefx::Sample<double, py2cpp::PyPtr > sample;
    std::vector<double> a_vals = {1.1, 4.4, 9, 4};
    sample.inputs<double>().set("a", a_vals);
    sample.outputs<double>().addName("r");

    py2cpp::PyFunction objConstructor;
    objConstructor.loadExp("pydefx", "PyStudy");
    py2cpp::PyPtr pyStudy = objConstructor();

    ydefx::Launcher l;
    ydefx::Job* myJob = l.submitPyStudyJob(pyStudy, studyFunction, sample, jobParams);
    CPPUNIT_ASSERT(myJob);
    CPPUNIT_ASSERT(l.lastError().empty());
    bool ok;
    ok = myJob->cancel();
    CPPUNIT_ASSERT(ok);
    std::string jobState = myJob->state();
    CPPUNIT_ASSERT(jobState == "FAILED");
}

CPPUNIT_TEST_SUITE_REGISTRATION( SampleTest );
#include "PyTestMain.cxx"
