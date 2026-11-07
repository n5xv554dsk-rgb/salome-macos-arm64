# Copyright (C) 2009-2026  EDF
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
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

include ../../makefile.inc

ASTER_INSTALL=$(ASTER_ROOT)/$(ASTER_VERSION)
ASTER_PUB=$(ASTER_ROOT)/public
ASTER_OUTILS=$(ASTER_ROOT)/outils

MUMPS=-L$(ASTER_PUB)/mumps-4.9.2/lib -ldmumps -lzmumps -lsmumps -lcmumps -lmumps_common -lpord -lmpiseq
METIS=-L$(ASTER_PUB)/metis-4.0/lib -lmetis


ASTER_LIBS = -L$(ASTER_INSTALL)/lib -laster \
	     $(MUMPS) $(METIS) \
             -L$(MED2HOME)/lib -lmed \
             -lferm -llapack -lhdf5

KERNEL_INCLUDES=-I$(KERNEL_ROOT_DIR)/include/salome
KERNEL_LIBS= -L$(KERNEL_ROOT_DIR)/lib/salome -lCalciumC -lSalomeDSCSuperv -lSalomeDSCContainer \
             -lSalomeDatastream -lSalomeDSCSupervBasic -Wl,--rpath -Wl,$(KERNEL_ROOT_DIR)/lib/salome

FC=gfortran
LD=gfortran
FFLAGS=-fopenmp -fdefault-double-8 -fdefault-integer-8 -fdefault-real-8
CC=gcc
SOURCES= src/op0078.f src/op0189.f src/op0181.f
OBJETS=op0078.o op0189.o op0181.o

CATAPY=catalo/ecrire_maillage.capy  catalo/lecture_force.capy catalo/yacs_init.capy

all:pyth cata astermodule

pyth:
	cp -rf $(ASTER_INSTALL)/bibpyt .

cata: commande/cata.py 
	cp -rf commande/cata.py* bibpyt/Cata

commande/cata.py:$(CATAPY)
	./make_cata $(ASTER_ROOT)/bin/as_run $(ASTER_VERSION)

astermodule:astermodule.so pyth
	cp -rf astermodule.so bibpyt

op0078.o:src/op0078.f
	$(FC) -c -fpic $(FFLAGS) $(KERNEL_INCLUDES) src/op0078.f
op0189.o:src/op0189.f
	$(FC) -c -fpic $(FFLAGS) $(KERNEL_INCLUDES) src/op0189.f
op0181.o:src/op0181.f
	$(FC) -c -fpic $(FFLAGS) $(KERNEL_INCLUDES) src/op0181.f
astermodule.so: $(OBJETS)
	$(LD) -shared $(FFLAGS) -o $@ $(OBJETS) $(KERNEL_LIBS) $(ASTER_LIBS)
clean:
	rm -rf *.o *.so bibpyt commande/cata.py* make-cmd commande
