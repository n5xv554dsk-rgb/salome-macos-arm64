#/bin/bash
# execute a command within SALOME environment 

com=$*
SCRIPT_DIR=`dirname $0`

SALOME_APPLI_PATH=/home/I35256/salome/base/appli_DEV_package
$SALOME_APPLI_PATH/salome shell -- bash $SCRIPT_DIR/salome_env_exec.sh $com
exit $?
