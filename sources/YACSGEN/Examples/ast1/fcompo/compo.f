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

       SUBROUTINE S1(compo,A,B,C,D,E,F)
       include 'calcium.hf'
       integer compo
       real*8 a,d(*),tt,tp,t0,t1,ss,zz
       integer b,e,dep,np
       character*(*) c,f
       character*8 tch(2)
       real yd
       real tcp(2)
       integer tlo(3)

       open(UNIT=22,FILE='SORTIES')
       write(6,*)a,b,c,compo
       call flush(6)

       t0=0.
       t1=1.
       iter=1

       tt=1.5
       tp=2.3
       np=12
       yd=4.3
       tch(1)="coucou"
       tcp(1)=2.
       tcp(2)=4.
       tlo(1)=0
       tlo(2)=1
       tlo(3)=0
       CALL cpeDB(compo,CP_TEMPS,t0,1,'ba',1,tt,info)
       CALL cpeDB(compo,CP_ITERATION,t0,1,'bb',1,tp,info)
       CALL cpeen(compo,CP_ITERATION,t0,1,'bc',1,np,info)
       CALL cpere(compo,CP_ITERATION,t0,1,'bd',1,yd,info)
       CALL cpech(compo,CP_ITERATION,t0,1,'be',1,tch,info)
       CALL cpecp(compo,CP_ITERATION,t0,1,'bf',1,tcp,info)
       CALL cpelo(compo,CP_ITERATION,t0,1,'bg',3,tlo,info)

       ss=0.
       CALL cpldb(compo,CP_TEMPS,t0,t1,iter,'a',1,n,ss,info)
       write(6,*)"apres cpldb(a) ",info,ss
       call flush(6)

       zz=0.
       CALL cpldb(compo,CP_ITERATION,t0,t1,iter,'b',1,n,zz,info)
       write(6,*)"apres cpldb(b) ",info,zz
       call flush(6)

       d(1)=4.5
       e=3
       f="zzzzzzzzzzzzzzz"
       write(6,*)d(1),e,f
       call flush(6)
       write(22,*)d(1),e,f
       call flush(22)
       END

       SUBROUTINE S2(compo,A,B,C)
       integer compo
       real*8 a,b,c
       write(6,*)a,b
       call flush(6)
       c=a*b
       write(6,*)c
       call flush(6)
       END

       SUBROUTINE S3(compo)
       include 'calcium.hf'
       integer compo
       real*8 tt,tp,t0,t1,ss,zz
       integer iter,n,info,zn
      CHARACTER*8 tch(2)
      real tcp(2)
      integer tlo(3)

       t0=0.
       t1=1.
       tt=1.5
       tp=2.3

       CALL cpeDB(compo,CP_TEMPS,t0,1,'ba',1,tt,info)
       CALL cpeDB(compo,CP_ITERATION,t0,1,'bb',1,tp,info)
       call flush(6)
       t0=0.
       t1=1.
       iter=1


       ss=0.
       CALL cpldb(compo,CP_TEMPS,t0,t1,iter,'aa',1,n,ss,info)
       write(6,*)"apres cpldb(aa) ",info,ss
       call flush(6)

       zz=0.
       CALL cpldb(compo,CP_ITERATION,t0,t1,iter,'ab',1,n,zz,info)
       write(6,*)"apres cpldb(ab) ",info,zz
       call flush(6)

       CALL cplen(compo,CP_ITERATION,t0,t1,iter,'ac',1,n,zn,info)
       write(6,*)"apres cplen(ac) ",info,zn
       call flush(6)
       CALL cplre(compo,CP_ITERATION,t0,t1,iter,'ad',1,n,yr,info)
       write(6,*)"apres cplre(ad) ",info,yr
       call flush(6)
       CALL cplch(compo,CP_ITERATION,t0,t1,iter,'ae',1,n,tch,info)
       write(6,*)"apres cplch(ae) ",info,tch(1)
       call flush(6)
       CALL cplcp(compo,CP_ITERATION,t0,t1,iter,'af',1,n,tcp,info)
       write(6,*)"apres cplcp(af) ",info,tcp(1),tcp(2)
       call flush(6)
       CALL cpllo(compo,CP_ITERATION,t0,t1,iter,'ag',3,n,tlo,info)
       write(6,*)"apres cpllo(ag) ",info,tlo(1),tlo(2),tlo(3)
       call flush(6)

       END

