Contributing to the SALOME project with Git
===========================================

This short document indicates the process to be followed by anyone wishing to contribute code to the SALOME project using Git. If you read this document, you should have received the credentials allowing you to write your changes into the central repository.

Get your copy of the central repository
---------------------------------------

1. Clone the latest version of the repository for the module you want to modify::

    git clone ssh://<proper-url> 
  
  
  This retrieves a local copy of the module's repository onto your machine. The repository URL should have been given to you before you start.

2. If you were already given a branch name to work with, you can simply retrieve it and start working::

    git checkout -b <branch_name> origin/<branch_name>


  This creates a local copy of the branch, and sets it up to be a copy of the remote branch on the central server. You can jump directly to the next section (Workflow) telling how to commit and publish changes.

3. Otherwise you need to create and publish a new branch in which you will do your changes (you are not allowed to commit changes directly into the main branch 'master'). First create the local version of the new branch::

    git checkout master
    git checkout -b <xyz/short_desc>
  

  where <xyz> are you initials (John Smith gives 'jsh') and <short_desc> is a small string indicating what changes will be made. For example::
    
    jsh/new_viewer

  
  The last command creates the branch locally, and update your working directory (i.e. the source code) to match this branch: every change and commit you make from now on will be stored in this branch.

4. Publish your branch to the central repository for the first time::

    git push origin <xyz/short_desc>
  
  
  
Workflow
--------

1. If you didn't update your local copy for a while, update it with the following command. This retrieves from the central server all changes published by other people working on your branch. This step is not necessary if you just initialized your repository as described above::

    git checkout <xyz/short_desc>
    git pull origin <xyz/short_desc>
  
2. Do your changes, compile. 
3. Perform the appropriate tests to ensure the changes work as expected.
4. If you create a new source file, you need to make Git aware of it::

    git add <path/to/new/file>
  
5. When everything is ready you can commit all your changes into your local repository::

    git commit -a
  
  The "-a" option tells Git to automatically take all the changes you made for the current commit. You will be asked to enter a commit message. Please, *please*, write something sensible. A good format is::

    GLViewer: enhance ergonomy of the 3D view
  
    User can now zoom in and out using the mouse wheel. 
    Corresponding keyboard shortcuts have also been added.

  i.e. a first short line containing the class/code entity that was modified, and a short description of the change. Then a blank line, and a long description of the change. Remember that this message is mainly for other people to understand quickly what you did.
  
  
  At this point, the changes are just saved in your local repository. You can still revert them, amend the commits, and perform any other operation that re-writes the local history.
  
6. Once you feel everything is ready to be seen by the rest of the world, you can publish your work. The first step is to synchronize again with any potential change published in your branch on the central repository. This can happen while you were working locally::

    git pull origin <xyz/short_desc>
  
7. At this stage, two situations can arise. If nothing (or some unrelated stuff to your work) happened on the central repository, Git will not complain (or potentially do an automatic merge). You can inspect the latest changes committed by others with commands like::

    git log
    gitk 

  If you notice changes made by others that can affect what you're working on, it might be a good idea to recompile and retest what you have done, even if Git did the merge automatically. Once you are happy, you can directly go to step 9.

8. Conflict resolution. If a message saying "CONFLICT: automatic merge FAILED" appears, it means that some changes made by others are in conflict with what you committed locally (typically happens when the other person modified a file that you also changed). In that case, you need to integrate both changes: edit the file so that both changes work together (or so that only one version is retained). Conflicts are marked in the file like this::

    <<<<<<< HEAD:mergetest
    This is my third line
    =======
    This is a fourth line I am adding
    >>>>>>> 4e2b407f501b68f8588aa645acafffa0224b9b78:mergetest

  Once you resolved the conflict, re-compiled and re-tested the code, you need to tell Git that the file is no more in conflict::
  
    git add <the_file>

  You can then finish the merge operation by committing the whole thing::
  
    git commit -a
  
  In this peculiar case (conflict resolution) you will see that Git offers you a default message (merge message). You can complete this message to indicate for example how the conflict was solved. 
  
9. When all conflicts are solved (and the code has been compiled and tested again if needed) you can finally publish your work to the central repository::

    git push origin <xyz/short_desc>

  This makes your changes visible to others.

10. Once all your changes have been committed (potentially several commits) and you feel your modification is ready to be integrated in the main development line (i.e. to be considered for the next release), you can notify an administrator of the project to ask for your changes to be merged in the *master* branch. 


Special notes for EDF users
---------------------------

Working with YAMM
^^^^^^^^^^^^^^^^^

YAMM is the tool used at EDF to build SALOME platform. Among other things, it
can automatically fetch and compile SALOME sources. If you just need a
read-only access to Salome sources from a standard EDF computer (Calibre 7),
you just need to run YAMM with no specific configuration. The sources will be
fetched automatically and the compilation will proceed as usual.

If you need to develop and push changes in Salome sources, follow those steps:

1. Make sure you have a write access to Salome sources. If not, ask your project
   manager who will forward your request to Salome repository administrator.

2. Save your credentials on your local computer. For that, edit the file
   $HOME/.netrc (create it if it doesn't exist), and add the following lines::

    machine git.salome-platform.org
    login mylogin
    password mypassword

  Replace "mylogin" by your login on Salome repository and "mypassword" by
  your password on the repository. The password here is in clear, so make sure
  this file is only readable by yourself::
  
    $ chmod 600 ~/.netrc

3. Disable SSL verification for git. For that, edit the file $HOME/.bashrc and
   add the following line::

    export GIT_SSL_NO_VERIFY=true

   Alternatively, if you have a root access on your computer, you can install
   the right certificate and allow SSL verification. How to do so is out of the
   scope of this guide.

4. Configure YAMM to use your login to fetch Salome sources, for instance by
   adding the following lines in your YAMM project configuration file::

    # Configure the username for SALOME modules
    project.options.set_global_option("occ_username", "mylogin")
    
    # Eventually configure the username for other modules
    project.options.set_software_option("EFICAS", "occ_username", "myeficaslogin")
    project.options.set_software_option("EFICASV1", "occ_username", "myeficaslogin")

5. Launch YAMM to fetch and compile all Salome sources

6. Go to the directory containing the sources of the module you need to develop
   (for instance ~/salome/V7_main/modules/src/KERNEL).

7. Create a new development branch, following the instructions in the previous
   section. This development branch MUST track a remote branch so that the future
   updates work properly.

8. Edit your YAMM project to specify that you work on a new development branch,
   for instance by adding the following lines::

    softwares_user_version = {}
    softwares_user_version["KERNEL"] = "rbe/my-new-development"
    salome_project.options.set_global_option("softwares_user_version", softwares_user_version)

9. You can then develop the new requested features and commit them. Each time
   you run YAMM, it will merge the remote tracking branch in your local branch.
   When you are done, you can push your developments on the remote repository and
   ask an integrator to integrate them in the master branch, as explained in the
   previous section.

Proxy issues
^^^^^^^^^^^^

YAMM automatically configures the proxy settings for a standard usage at EDF
(Calibre 7 computer inside EDF network). In this case, you have nothing special
to do to access Salome repository. But if you are not in this standard
configuration, the following tips may be useful.

1. Non-standard computers: You have to authentify yourself to the proxy in order
   to fetch Salome sources. For that, get the script edf-proxy-agent-cli
   (available on every Calibre 7 computer in /usr/bin) that can be launched as a
   daemon with -d option. Launch this script manually and type your SESAME
   username and password (it must be done each time you log on your computer).
   Further accesses to Salome repository should work properly.

2. Computers outside EDF network: Set the variable "git_config_proxy" in your
   YAMM project configuration to False in order to deactivate proxy usage::

    salome_project.options.set_global_option("git_config_proxy", False)

  If your computer is a laptop that is sometimes used inside EDF network and
  sometimes outside, configure the proxy manually by adding those lines to your
  ~/.bashrc file::
  
    export http_proxy=http://proxypac.edf.fr:3128
    export https_proxy=http://proxypac.edf.fr:3128
    export no_proxy="localhost,.edf.fr"

  This configuration will work inside EDF network. Simply comment those three
  lines when you use YAMM outside EDF network.
