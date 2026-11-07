
To compile and launch SALOME, please follow the steps below. This assumes that Docker is already installed on your workstation. If it is not, please refer to the official Docker documentation for installation instructions at this [link](https://docs.docker.com/desktop).
  

1. Construct the docker image

  ```bash
     docker build -t "salome-ub24.04-x86_64:latest" -f SALOMEPlatform.Dockerfile.ub24.04-x86_64 .
  ```
  
2.  Launch one container from this image

  ```bash
     docker run --rm -it --volume $PWD:$PWD --workdir $PWD salome-ub24.04-x86_64:latest
  ```

3. Construct SALOME in that container
 
  ```bash
     # Define a workspace
     export SALOME_WORKSPACE=$PWD

     # retrieve SAT and SAT_SALOME sources
     git clone https://github.com/SalomePlatform/sat.git SAT
     git clone https://github.com/SalomePlatform/sat_salome.git SAT_SALOME

     # Expose SAT_SALOME to SAT
     SAT/sat init --add_project $PWD/SAT_SALOME/salome.pyconf

     # Ensure required system dependencies are present, and install the missing ones, if any.
     SAT/sat config SALOME-master-native --check_system

     # Retrieve all SALOME modules sources as well as all the external dependencies
     SAT/sat -o "APPLICATION.properties.git_server='github'"  prepare SALOME-master-native

     # Compile SALOME from scratch
     SAT/sat -o "APPLICATION.properties.git_server='github'" compile SALOME-master-native

     # Once the compilation done, cleanup some directories
     rm -rf SALOME-master-native-UB24.04/BUILD ARCHIVES

     # Generate a SALOME launcher
     SAT/sat launcher SALOME-master-native --use_mesa

     # you can also package SALOME binary distribution and share it
     SAT/sat package SALOME-master-native -b 
  ```

4. Run the docker on the constructed SALOME

  ```bash
 
     # grant permission to local root user
     xhost +local:root

     # launch Docker
     docker run --rm                                            \
                --net host                                      \
                --env DISPLAY=$DISPLAY                          \
                --volume /tmp/.X11-unix:/tmp/.X11-unix:ro       \
                --volume $HOME/.Xauthority:/root/.Xauthority:rw \
                --volume $PWD:$PWD                              \
                salome-ub24.04-x86_64:latest                    \
                $PWD/SALOME-master-native-UB24.04/salome
   ```

  Here:
  
  - ``--rm``: deletes container once SALOME is exited.
  
  - ``--env DISPLAY=$DISPLAY``: passes the ``DISPLAY`` environment variable to the container, this basically tells SALOME which screen it should display on.
  
  - ``--volume /tmp/.X11-unix:/tmp/.X11-unix:ro``: Mounts the X11 server socket (the communication point) into the container in read-only  mode.
  
  - ``--volume $HOME/.Xauthority:/root/.Xauthority:rw``: shares the X authority file to manage display permissions more securely.
  
  - ``--net host`` : in case CORBA or some network is required.


  To check that everything is working as it should, run in the python console
  
  ```python
     from salome.kernel import salome_test
  ```

  Please note that for releases prior to or equal to SALOME 9.16.0, the command line reads:
  
  ```python
     import salome_test
  ```

  
  You can also run one module test suit, e.g GEOM:

  ```bash
     docker run --rm                                            \
                --net host                                      \
                --env DISPLAY=$DISPLAY                          \
                --volume /tmp/.X11-unix:/tmp/.X11-unix:ro       \
                --volume $HOME/.Xauthority:/root/.Xauthority:rw \
                --volume $PWD:$PWD                              \
                salome-ub24.04-x86_64:latest                    \
                $PWD/SALOME-master-native-UB24.04/salome test -R GEOM
  ```
