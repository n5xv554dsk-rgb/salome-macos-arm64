#! /usr/bin/env python
# -*- coding: utf-8 -*-
# This test executes the coupling.xml schema found in the current directory
# and verifies the execution state.
import unittest

import os
import sys

class TestCompo(unittest.TestCase):
  def setUp(self):
    # creat study and load catalogs
    from salome.yacs import SALOMERuntime
    SALOMERuntime.RuntimeSALOME_setRuntime()
    salome_runtime = SALOMERuntime.getSALOMERuntime()
    
    from salome.kernel import salome
    salome.salome_init()
    
    mc = salome.naming_service.Resolve('/Kernel/ModulCatalog')
    ior = salome.orb.object_to_string(mc)
    session_catalog = salome_runtime.loadCatalog("session", ior)
    salome_runtime.addCatalog(session_catalog)

  def test_exec_scheme(self):
    from salome.yacs import pilot
    from salome.yacs import loader

    xmlLoader = loader.YACSLoader()
    try:
      p = xmlLoader.load("coupling.xml")
    except IOError as ex:
      self.fail("IO exception:" + ex);
    self.assertTrue(p.isValid())
    e = pilot.ExecutorSwig()
    e.RunW(p)
    self.assertEqual(p.getEffectiveState(), pilot.DONE)
    
  def tearDown(self):
      pass
  
if __name__ == '__main__':
    unittest.main()
