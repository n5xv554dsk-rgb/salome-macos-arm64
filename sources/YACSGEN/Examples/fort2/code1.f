C Copyright (C) 2009-2026  EDF
C
C This library is free software; you can redistribute it and/or
C modify it under the terms of the GNU Lesser General Public
C License as published by the Free Software Foundation; either
C version 2.1 of the License, or (at your option) any later version.
C
C This library is distributed in the hope that it will be useful,
C but WITHOUT ANY WARRANTY; without even the implied warranty of
C MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
C Lesser General Public License for more details.
C
C You should have received a copy of the GNU Lesser General Public
C License along with this library; if not, write to the Free Software
C Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
C
C See http://www.salome-platform.org/ or email : webmaster.salome@opencascade.com
C

       PROGRAM P
       CALL YACSINIT()
       END

       SUBROUTINE SERV1(compo,a,b,c)
       include 'calcium.hf'
       integer compo(2)
       real*8 tt,a,b,c
       write(6,*)a,b
       tt=125.45
       CALL cpeDB(compo,CP_ITERATION,0.,1,'PARAM',1,tt,info)
       write(6,*)'info=',info
       c=a+b
       return 
       end
