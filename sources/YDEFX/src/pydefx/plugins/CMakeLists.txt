SET(SCHEMA_FILES
  jobexecutor.py
  lightexecutor.py
  localexecutor.py
  srunexecutor.py
  mainjob.py
  pointeval.py
  )

INSTALL(FILES ${SCHEMA_FILES} DESTINATION ${SALOME_YDEFX_INSTALL_PYTHON}/pydefx/plugins)
