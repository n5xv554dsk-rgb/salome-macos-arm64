SUBDIRS = src 
EXTRA_DIST = Readme.md Changlog.md Todo.md

AUTOMAKE_LIST=autom4te.cache \
config.h \
config.status \
configure \
install-sh \
missing \
Makefile \
Makefile.in \
aclocal.m4 \
config.h.in \
config.log \
stamp-h1 \
depcomp  \
.swp

all-local:
	@echo ""
	@echo "*============================================================*"
	@echo " 'make' finished now do 'make check'"
	@echo "*============================================================*"
	@echo ""

logo:
	@echo "*============================================================*"
	@echo "         ___                                            ___    " 
	@echo "        /  /               ___________                 /  /    "
	@echo "     __/  /_ ___    ___   /__  __  __/__    __ ____   /  /     " 
	@echo "    /_   __// _  \\ / _  \\   / / / /   \\ \\  / // _  \\ /  / " 
	@echo "     /  /_ / /_/ // /_/ /__/ /_/ /__   \\ \\/ // /_/ //  /__   " 
	@echo "     \\___/ \\____// ____//__________/    \\__/ \\____/ \\____/" 
	@echo "                / /                                            " 
	@echo "               /_/                                             "
	@echo "*============================================================*"

install-exec-local: logo
	@mkdir -p ${prefix}/share/topIIvol
	@mkdir -p ${prefix}/share/topIIvol/doc
	@cp  ./man/Readme.pdf    ${prefix}/share/topIIvol/doc/.
	@echo "*============================================================*"
	@echo ""	
	@echo " Finished installing topIIvol version $(VERSION)"	
	@echo ""
	@echo " # topIIvol tools  are now installed at:" 
	@echo "               -  ${prefix}/bin/topIIvol_PreProc"
	@echo "               -  ${prefix}/bin/topIIvol_Mesher"
	@echo "               -  ${prefix}/bin/topIIvol_ParMesher"
	@echo "               -  ${prefix}/bin/topIIvol_DistMesher"	
	@echo ""
	@echo " # topIIvol documentations will be present at :"
	@echo "               -  ${prefix}/share/topIIvol/doc/Readme.pdf"		
	@echo ""
	@echo " optionally do 'make tutorials' for basic topIIvol tutorials"
	@echo ""		
	@echo "*============================================================*"

tutorials:
	@mkdir -p $${HOME}/topIIvol-tutorials
	@mkdir -p $${HOME}/topIIvol-tutorials/doc
	@mkdir -p $${HOME}/topIIvol-tutorials/xyz
	@cp  ./demos/*.pdf   $${HOME}/topIIvol-tutorials/.
	@cp  ./man/Readme.pdf    $${HOME}/topIIvol-tutorials/doc/.
	@cp  ./data/DEM_10m.xyz  $${HOME}/topIIvol-tutorials/xyz/point-cloud-fine.xyz
	@cp  ./data/DEM_160m.xyz $${HOME}/topIIvol-tutorials/xyz/point-cloud-coarse.xyz
	@echo "*============================================================*"
	@echo ""
	@echo " # topIIvol tutorials are now present at:"
	@echo "               -  $${HOME}/topIIvol-tutorials"		
	@echo ""
	@echo "*============================================================*"	 	

	
check: logo
	@echo ""
	@echo "*============================================================*"
	@echo " 'make check' finished now do 'sudo make install'"
	@echo "*============================================================*"				

clean-local:
	@echo ""
	@echo "*============================================================*"
	@echo " Cleaning files in :"; pwd
	@echo "*============================================================*"
	rm  -f *~
	
clean-automake:
	@echo ""
	@echo "*============================================================*"
	@echo " Cleaning all automake files in :"; pwd
	@echo "*============================================================*"
	@echo ""
	rm  -rf ${AUTOMAKE_LIST} *~ 
	rm  -rf ./src/Makefile ./src/Makefile.in  ./src/*~  
	rm  -rf ./src/distributed-mesher/Makefile ./src/distributed-mesher/Makefile.in  ./src/distributed-mesher/*~
	rm  -rf ./src/par-mesher/Makefile ./src/par-mesher/Makefile.in  ./src/par-mesher/*~
	rm  -rf ./src/mesher/Makefile ./src/mesher/Makefile.in  ./src/mesher/*~
