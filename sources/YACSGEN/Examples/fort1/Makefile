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

include ../makefile.inc

all:libcode1.so libcode2.so
libcode1.so:code1.o
	  $(FC) -shared -fPIC -o libcode1.so code1.o
code1.o:code1.f
	  $(FC) -c code1.f -fPIC -I$(KERNEL_ROOT_DIR)/include/salome -fexceptions
libcode2.so:code2.o bidul.o
	  $(FC) -shared -fPIC -o libcode2.so code2.o bidul.o
code2.o:code2.f
	  $(FC) -c code2.f -fPIC -I$(KERNEL_ROOT_DIR)/include/salome -fexceptions

bidul.o:bidul.f
	  $(FC) -c bidul.f -fPIC -I$(KERNEL_ROOT_DIR)/include/salome -fexceptions

clean:
	rm -rf *.o *.so fcompos_*  install appli traceExec_proc *.bak *.err *.log
