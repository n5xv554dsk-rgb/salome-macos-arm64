def pilotyacsCS(runxmlfile) :
   import sys
   from salome.yacs import pilot
   from salome.yacs import SALOMERuntime
   from salome.yacs import loader
   SALOMERuntime.RuntimeSALOME_setRuntime()

   xmlLoader = loader.YACSLoader()

   try:
     p = xmlLoader.load(runxmlfile)
   except IOError,ex:
     print "IO exception:",ex
     sys.exit(1)

   logger=p.getLogger("parser")
   if not logger.isEmpty():
     print "The imported file has errors :"
     print logger.getStr()
     sys.exit(1)

   if not p.isValid():
     print "The schema is not valid and can not be executed"
     print p.getErrorReport()
     sys.exit(1)

   info=pilot.LinkInfo(pilot.LinkInfo.ALL_DONT_STOP)
   p.checkConsistency(info)
   if info.areWarningsOrErrors():
     print "The schema is not consistent and can not be executed"
     print info.getGlobalRepr()
     sys.exit(1)
   executor = pilot.ExecutorSwig()
   executor.RunPy(p)

if __name__ == '__main__' :

   import sys
   if sys.argv <> None :
       pilotyacsCS(sys.argv[1])
