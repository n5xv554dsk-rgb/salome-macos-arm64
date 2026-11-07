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

       SUBROUTINE SERV1(compo,a,b,c)
       include 'calcium.hf'
       integer compo(2)
       integer i, nval, info, z(10), l
       integer*8 lz(10)
       integer*4 z4(10),lo(10)

       real*8 dd(10),a,b,c,ti,tf,t
       real*4 u(20)
       real*4 tti,ttf,tt
       character*10 s(3)
       character*20 rs(3)
       character*64 instance

       write(6,*)a,b
       call cpcd(compo,instance,info)
       write(6,*)"instance name=",instance

C  write
       tt=0.
       t=0.
       dd(1)=125.45
       dd(2)=8.8
       i=1
       l=10
       CALL cpedb(compo,CP_TEMPS,t,i,'ba',l,dd,info)
       t=1.
       CALL cpedb(compo,CP_TEMPS,t,i,'ba',l,dd,info)
       t=2.
       CALL cpedb(compo,CP_TEMPS,t,i,'ba',l,dd,info)
       write(6,*)'info=',info
       call flush(6)

       s(1)="titi"
       s(2)="tututu"
       s(3)="tatatata"
       write(6,*)'s=',s
       l=3
       CALL cpech(compo,CP_TEMPS,tt,i,'bb',l,s,info)
       write(6,*)'info=',info
       call flush(6)

       z(1)=1
       z(2)=8
       z(3)=0
       write(6,*)'z=',z(1)
       write(6,*)'z=',z(2)
       write(6,*)'z=',z(3)
       l=10
       CALL cpeen(compo,CP_TEMPS,tt,i,'bc',l,z,info)
       write(6,*)'info=',info
       call flush(6)

       u(1)=1
       u(2)=8
       u(3)=4
       u(4)=4
       u(5)=5
       u(6)=5
       write(6,*)'u=',u(1)
       write(6,*)'u=',u(2)
       write(6,*)'u=',u(3)
       write(6,*)'u=',u(4)
       write(6,*)'u=',u(5)
       write(6,*)'u=',u(6)
       CALL cpecp(compo,CP_TEMPS,tt,i,'bd',l,u,info)
       write(6,*)'info=',info
       call flush(6)

       u(1)=1.1
       u(2)=8.8
       u(3)=4.4
       write(6,*)'u=',u(1)
       write(6,*)'u=',u(2)
       write(6,*)'u=',u(3)
       CALL cpere(compo,CP_TEMPS,tt,i,'be',l,u,info)
       write(6,*)'info=',info
       call flush(6)

       lo(1)=1
       lo(2)=0
       lo(3)=1
       write(6,*)'lo=',lo(1)
       write(6,*)'lo=',lo(2)
       write(6,*)'lo=',lo(3)
       CALL cpelo(compo,CP_TEMPS,tt,i,'bf',l,lo,info)
       write(6,*)'info=',info
       call flush(6)

       lz(1)=11
       lz(2)=22
       lz(3)=33
       write(6,*)'lz=',lz(1)
       write(6,*)'lz=',lz(2)
       write(6,*)'lz=',lz(3)
       CALL cpeln(compo,CP_TEMPS,tt,i,'bg',l,lz,info)
       write(6,*)'info=',info
       call flush(6)

       z4(1)=1
       z4(2)=8
       z4(3)=0
       write(6,*)'z4=',z4(1)
       write(6,*)'z4=',z4(2)
       write(6,*)'z4=',z4(3)
       CALL cpein(compo,CP_TEMPS,tt,i,'bh',l,z4,info)
       write(6,*)'info=',info
       call flush(6)

       lz(1)=11
       lz(2)=22
       lz(3)=2**30
       lz(3)=2**20*lz(3)
       write(6,*)'lz=',lz(1)
       write(6,*)'lz=',lz(2)
       write(6,*)'lz=',lz(3)
       CALL cpelg(compo,CP_TEMPS,tt,i,'bi',l,lz,info)
       write(6,*)'info=',info
       call flush(6)

C  read 
       ti=0.
       tf=1.
       i=1
       dd(1)=0.
       dd(2)=0.
       dd(3)=0.
       l=3
       CALL cpldb(compo,CP_TEMPS,ti,tf,i,'aa',l,nval,dd,info)
       write(6,*)'info=',info
       write(6,*)'dd=',dd(1)
       write(6,*)'dd=',dd(2)
       write(6,*)'dd=',dd(3)
       write(6,*)'nval=',nval
       call flush(6)

       tti=0.
       ttf=1.
       i=1
       CALL cplch(compo,CP_TEMPS,tti,ttf,i,'ab',l,nval,rs,info)
       write(6,*)'info=',info
       write(6,*)'rs=',rs
       write(6,*)'nval=',nval
       call flush(6)

       z(1)=0
       z(2)=0
       z(3)=0
       CALL cplen(compo,CP_TEMPS,tti,ttf,i,'ac',l,nval,z,info)
       write(6,*)'info=',info
       write(6,*)'nval=',nval
       write(6,*)'z=',z(1)
       write(6,*)'z=',z(2)
       write(6,*)'z=',z(3)
       call flush(6)

       u(1)=0
       u(2)=0
       u(3)=0
       u(4)=0
       u(5)=0
       u(6)=0
       CALL cplcp(compo,CP_TEMPS,tti,ttf,i,'ad',l,nval,u,info)
       write(6,*)'info=',info
       write(6,*)'nval=',nval
       write(6,*)'u=',u(1)
       write(6,*)'u=',u(2)
       write(6,*)'u=',u(3)
       write(6,*)'u=',u(4)
       write(6,*)'u=',u(5)
       write(6,*)'u=',u(6)
       call flush(6)

       u(1)=0
       u(2)=0
       u(3)=0
       CALL cplre(compo,CP_TEMPS,tti,ttf,i,'ae',l,nval,u,info)
       write(6,*)'info=',info
       write(6,*)'nval=',nval
       write(6,*)'u=',u(1)
       write(6,*)'u=',u(2)
       write(6,*)'u=',u(3)
       call flush(6)

       lo(1)=0
       lo(2)=0
       lo(3)=0
       CALL cpllo(compo,CP_TEMPS,tti,ttf,i,'af',l,nval,lo,info)
       write(6,*)'info=',info
       write(6,*)'nval=',nval
       write(6,*)'lo=',lo(1)
       write(6,*)'lo=',lo(2)
       write(6,*)'lo=',lo(3)
       call flush(6)

       lz(1)=0
       lz(2)=0
       lz(3)=0
       CALL cplln(compo,CP_TEMPS,tti,ttf,i,'ag',l,nval,lz,info)
       write(6,*)'info=',info
       write(6,*)'nval=',nval
       write(6,*)'lz=',lz(1)
       write(6,*)'lz=',lz(2)
       write(6,*)'lz=',lz(3)
       call flush(6)

       z4(1)=0
       z4(2)=0
       z4(3)=0
       CALL cplin(compo,CP_TEMPS,tti,ttf,i,'ah',l,nval,z4,info)
       write(6,*)'info=',info
       write(6,*)'nval=',nval
       write(6,*)'z4=',z4(1)
       write(6,*)'z4=',z4(2)
       write(6,*)'z4=',z4(3)
       call flush(6)

       lz(1)=0
       lz(2)=0
       lz(3)=0
       CALL cpllg(compo,CP_TEMPS,tti,ttf,i,'ai',l,nval,lz,info)
       write(6,*)'info=',info
       write(6,*)'nval=',nval
       write(6,*)'lz=',lz(1)
       write(6,*)'lz=',lz(2)
       write(6,*)'lz=',lz(3)
       call flush(6)

       call cpfint(compo,'aa',0.5,info)
       write(6,*)'info=',info
       call flush(6)

       ti=0.
       tf=0.
       l=3
       CALL cpldb(compo,CP_TEMPS,ti,tf,i,'aa',l,nval,dd,info)
       write(6,*)'info=',info
       call flush(6)

       call cpefft(compo,'aa',1.5,info)
       write(6,*)'info=',info
       call flush(6)

       ti=2.
       tf=2.
       l=3
       CALL cpldb(compo,CP_TEMPS,ti,tf,i,'aa',l,nval,dd,info)
       write(6,*)'info=',info
       call flush(6)

       c=a+b
       return 
       end
