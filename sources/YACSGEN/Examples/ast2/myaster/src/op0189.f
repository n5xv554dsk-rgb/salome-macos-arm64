      SUBROUTINE OP0189 ( IER )
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 17/06/2002   AUTEUR GNICOLAS G.NICOLAS
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
C (AT YOUR OPTION) ANY LATER VERSION.
C
C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.
C
C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C     COMMANDE:  LECTURE_FORCE
C
      IMPLICIT NONE
C
      INTEGER IER
C

C --------- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C
C -------------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ----------------
C 0.3. ==> VARIABLES LOCALES
C
      CHARACTER*6 NOMPRO
      PARAMETER ( NOMPRO = 'OP0198' )
C
      CHARACTER*8  MA,DM,NOMG,MODELE, NOMA
C
      INTEGER N1,NDIM
      CHARACTER*8  CHAR
      CHARACTER*16 GROUPE
      CHARACTER*16 TYPE, OPER
      CHARACTER*4         FONREE
      CHARACTER*19 LIGRCH, LIGRMO
      INTEGER      IGREL, INEMA, IRET, IATYPE,NBVAL
      LOGICAL    LIMPR, LINFO, GETEXM
      INTEGER*4 NIV,IFM,iter,info,n,zn
      INTEGER IAUX,IFL
      COMMON/YACS/IFL
      include 'calcium.hf'
      real*8 tt,tp,t0,t1,ss,zz
      real*4 yr
      CHARACTER*8 tch(2)
      real*4 tcp(2)
      integer*4 tlo(3)

      write(6,*) '--> OP196 '
      write(6,*)IFL
C
       t0=0.
       t1=1.
       iter=1


       ss=0.
       CALL cpldb(IFL,CP_TEMPS,t0,t1,iter,'aa',1,n,ss,info)
       write(6,*)"apres cpldb(aa) ",info,ss
       call flush(6)

       zz=0.
       CALL cpldb(IFL,CP_ITERATION,t0,t1,iter,'ab',1,n,zz,info)
       write(6,*)"apres cpldb(ab) ",info,zz
       call flush(6)
       CALL cplen(IFL,CP_ITERATION,t0,t1,iter,'ac',1,n,zn,info)
       write(6,*)"apres cplen(ac) ",info,zn
       call flush(6)
       CALL cplre(IFL,CP_ITERATION,t0,t1,iter,'ad',1,n,yr,info)
       write(6,*)"apres cplre(ad) ",info,yr
       call flush(6)
       CALL cplch(IFL,CP_ITERATION,t0,t1,iter,'ae',1,n,tch,info)
       write(6,*)"apres cplch(ae) ",info,tch(1)
       call flush(6)
       CALL cplcp(IFL,CP_ITERATION,t0,t1,iter,'af',1,n,tcp,info)
       write(6,*)"apres cplcp(af) ",info,tcp(1),tcp(2)
       call flush(6)
       CALL cpllo(IFL,CP_ITERATION,t0,t1,iter,'ag',3,n,tlo,info)
       write(6,*)"apres cpllo(ag) ",info,tlo(1),tlo(2),tlo(3)
       call flush(6)

C-----------------------------------------------------------------------
      END

