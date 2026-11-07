#!/usr/bin/env python
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
   Ce module sert a lancer EFICAS configure pour Code_Aster
"""
# Modules Python
# Modules Eficas

import sys,os
sys.path.append(os.path.join(os.path.abspath(os.path.dirname(__file__)),'..'))

from PyQt4.QtCore import *
from InterfaceQT4 import eficas_go

import prefs
import difflib

from PyQt4.QtGui  import *
from myMain import Ui_Eficas
from editorManager import MyTabview
from getVersion import getEficasVersion

from Accas.extensions.eficas_translation import tr
from Accas.extensions.eficas_exception import EficasException

from Editeur import session

import unittest
import HTMLTestRunner

class EficasEngineTestSuite(unittest.TestSuite):
    def __init__(self, testList):
        unittest.TestSuite.__init__(self)
        for test in testList:
            self.addTest(test)

class EficasEngineTestCase(unittest.TestCase):
    def setUp(self):
        from qtEficas import Appli
        from Editeur import session
        from Accas.extensions import localisation
        
        options = session.parse(sys.argv)
        if options.code!= None : code=options.code
        if options.ssCode!= None : ssCode=options.ssCode
        
        self.code=prefs.code
        self.Eficas=None
        self.editor=None
        
        self.app = QApplication(sys.argv)
        localisation.localise(self.app,'en')
        self.Eficas=Appli(code=self.code,ssCode=None,multi=False,langue='en')

    def tearDown(self):
        del self.Eficas
        self.Eficas = None
        del self.app
        self.app = None
        self.editor = None

    def close(self):
        if ( self.editor != None ):
            vm=self.Eficas.editorManager
            index=vm.myQtab.currentIndex()
            idx=index
            while idx < len(vm.dict_editors) -1 :
                vm.dict_editors[idx]=vm.dict_editors[idx+1]
                idx = idx + 1
            del vm.dict_editors[len (vm.dict_editors) -1]
            try :
                del vm.doubles[vm.dict_editors[index]]
            except :
                pass
            vm.myQtab.removeTab(index)
            self.editor = None

    def open_file(self, fileName):
        if ( self.Eficas == None ):
            return False

        result=True
        try:
            self.Eficas.editorManager.handleOpen(fileName)
            index=self.Eficas.editorManager.myQtab.currentIndex()
            self.editor=self.Eficas.editorManager.dict_editors[index]
        except:
            result=False
            pass

        return result

    def save_file(self, file):
        if ( self.editor == None ):
            return False

        try:
            os.remove(file)
        except:
            pass

        result=True
        
        try:
            self.editor.saveFileAs(fileName=file)
        except:
            result=False
            pass
        return result

    def search_object(self, name):
        obj=None
        if ( self.editor != None ):
            obj=self.editor.jdc
        return self.search_subobject(obj, name)
    
    def search_subobject(self, obj, name):
        if ( obj==None ):
            return None
    
        if ( hasattr( obj, 'get_sdname' ) and obj.get_sdname() == name ):
            return obj

        list=[]
        if ( hasattr(obj, 'etapes') ):
            list=obj.etapes
        elif ( hasattr(obj, 'mc_liste') ):
            list=obj.mc_liste

        o=None
        for i in list:
            o=self.search_subobject(i, name)
            if ( o != None ):
                break
            
        return o

    def search_param(self, obj, name):
        if ( obj == None ):
            return None

        if ( hasattr( obj, 'nom' ) and obj.nom == name ):
            return obj
         
        list=[]
        if ( hasattr(obj, 'etapes') ):
            list=obj.etapes
        elif ( hasattr(obj, 'mc_liste') ):
            list=obj.mc_liste

        o=None
        for i in list:
            o=self.search_param(i, name)
            if ( o != None ):
                break

        return o

    def remove_object(self, obj):
        if ( obj != None and hasattr( obj, 'parent' ) ):
            p=obj.parent
            if ( p != None ):
                p.suppentite(obj)

    def compare_files(self, orig, test):
        origlines = open(orig, 'U').readlines()
        testlines = open(test, 'U').readlines()

        diff = difflib.unified_diff(origlines, testlines, orig, test)

        result = 0;
        for str in diff:
            if ( len(str) == 0 ):
                continue
            elif ( str[0] != ' ' ):
                result=1
                print str

        return result

    def testCaseDataDir(self):
        return '/dn24/EFICAS/stv'
            
    def testCaseInputDataFile(self):
        return ""

    def testCasePatternDataFile(self):
        dataFile=self.testCaseInputDataFile()
        split=os.path.splitext(dataFile)
        return split[0] + '_ptrn' + split[1]

    def testCaseTestDataFile(self):
        dataFile=self.testCaseInputDataFile()
        split=os.path.splitext(dataFile)
        return split[0] + '_test' + split[1]

    def testCaseInputDataPath(self):
        return self.testCaseDataDir() + os.sep + self.testCaseInputDataFile()

    def testCasePatternDataPath(self):
        return self.testCaseDataDir() + os.sep + self.testCasePatternDataFile()

    def testCaseTestDataPath(self):
        return self.testCaseDataDir() + os.sep + self.testCaseTestDataFile()

    def runTest(self):
        inputFile=self.testCaseInputDataPath()

        self.assert_(self.open_file(inputFile), 'Can not open file: ' + inputFile)

        self.assert_(self.performTest(), 'Test not performed')

        testFile=self.testCaseTestDataPath()

        self.assert_(self.save_file(testFile), 'Can not save file: ' + testFile)

        patternFile=self.testCasePatternDataPath()
        cmp=self.compare_files(patternFile, testFile)

        self.assert_(cmp == 0, "Pattern file and test file are differs")

        self.close()

    def performTest(self):
        return True
    
def run_tests(reportFile, testSuit):
    print reportFile
    buf = file(reportFile, 'wb')
    runner = HTMLTestRunner.HTMLTestRunner(stream=buf, title='Test report', description='Result of tests')
    runner.run(testSuit)
