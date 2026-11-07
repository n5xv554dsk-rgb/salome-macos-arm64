      subroutine infami ( nomail, maext0,
     >                    ulsort, langue, codret )
c ______________________________________________________________________
c
c                             H O M A R D
c
c Outil de Maillage Adaptatif par Raffinement et Deraffinement d'EDF R&D
c
c Version originale enregistree le 18 juin 1996 sous le numero 96036
c aupres des huissiers de justice Simart et Lavoir a Clamart
c Version 11.2 enregistree le 13 fevrier 2015 sous le numero 2015/014
c aupres des huissiers de justice
c Lavoir, Silinski & Cherqui-Abrahmi a Clamart
c
c    HOMARD est une marque deposee d'Electricite de France
c
c Copyright EDF 1996
c Copyright EDF 1998
c Copyright EDF 2002
c Copyright EDF 2020
c ______________________________________________________________________
c
c   INformation : FAMIlles
c   --            ----
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   . char8  . nom de l'objet maillage homard iteration n .
c . maext0 . e   .   1    . maillage extrude                           .
c .        .     .        . 0 : non                                    .
c .        .     .        . 1 : selon X                                .
c .        .     .        . 2 : selon Y                                .
c .        .     .        . 3 : selon Z (cas de Saturne ou Neptune)    .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 2 : probleme dans les memoires             .
c .        .     .        . 3 : probleme dans les fichiers             .
c .        .     .        . 5 : probleme autre                         .
c ______________________________________________________________________
c
c====
c 0. declarations et dimensionnement
c====
c
c 0.1. ==> generalites
c
      implicit none
      save
c
      character*6 nompro
      parameter ( nompro = 'INFAMI' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
c
#include "meddc0.h"
#include "envca1.h"
#include "nombmp.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
#include "nbfami.h"
c
c 0.3. ==> arguments
c
      integer maext0
c
      character*8 nomail
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
c
      integer pfamno, pcfano
      integer pfammp, pcfamp
      integer pfamar, pcfaar
      integer pfamtr, pcfatr
      integer pfamqu, pcfaqu
      integer pfamte, pcfate
      integer pfamhe, pcfahe
      integer pfampy, pcfapy
      integer pfampe, pcfape
c
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. messages
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "impr03.h"
c
c====
c 2. recuperation des pointeurs
c====
c
c 2.1. ==> structure generale
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNOMH', nompro
#endif
      call utnomh ( nomail,
     >                sdim,   mdim,
     >               degre, maconf, homolo, hierar,
     >              rafdef, nbmane, typcca, typsfr, maextr,
     >              mailet,
     >              norenu,
     >              nhnoeu, nhmapo, nharet,
     >              nhtria, nhquad,
     >              nhtetr, nhhexa, nhpyra, nhpent,
     >              nhelig,
     >              nhvois, nhsupe, nhsups,
     >              ulsort, langue, codret)
c
      endif
c
c 2.2. ==> tableaux
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.2. tableaux ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD01', nompro
#endif
      iaux = 7
      call utad01 ( iaux, nhnoeu,
     >                jaux,
     >              pfamno, pcfano,   jaux,
     >                jaux,   jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      if ( nbmpto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_mp', nompro
#endif
        iaux = 259
        call utad02 (   iaux, nhmapo,
     >                  jaux,   jaux,   jaux,   jaux,
     >                pfammp, pcfamp,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_ar', nompro
#endif
      iaux = 259
      call utad02 (   iaux, nharet,
     >                jaux,   jaux,   jaux,   jaux,
     >              pfamar, pcfaar,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      if ( nbftri.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_tr', nompro
#endif
        iaux = 37
        if ( nbtrto.ne.0 ) then
          iaux = iaux*7
        endif
        call utad02 (   iaux, nhtria,
     >                  jaux,   jaux,   jaux,   jaux,
     >                pfamtr, pcfatr,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbfqua.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_qu', nompro
#endif
        iaux = 37
        if ( nbquto.ne.0 ) then
          iaux = iaux*7
        endif
        call utad02 (   iaux, nhquad,
     >                  jaux,   jaux,   jaux,   jaux,
     >                pfamqu, pcfaqu,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbftet.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_te', nompro
#endif
        iaux = 37
        if ( nbteto.ne.0 ) then
          iaux = iaux*7
        endif
        call utad02 (   iaux, nhtetr,
     >                  jaux,   jaux,   jaux,   jaux,
     >                pfamte, pcfate,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbfhex.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_he', nompro
#endif
        iaux = 37
        if ( nbheto.ne.0 ) then
          iaux = iaux*7
        endif
        call utad02 (   iaux, nhhexa,
     >                  jaux,   jaux,   jaux,   jaux,
     >                pfamhe, pcfahe,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbfpyr.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_py', nompro
#endif
        iaux = 37
        if ( nbpyto.ne.0 ) then
          iaux = iaux*7
        endif
        call utad02 (   iaux, nhpyra,
     >                  jaux,   jaux,   jaux,   jaux,
     >                pfampy, pcfapy,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbfpen.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_pe', nompro
#endif
        iaux = 37
        if ( nbpeto.ne.0 ) then
          iaux = iaux*7
        endif
        call utad02 (   iaux, nhpent,
     >                  jaux,   jaux,   jaux,   jaux,
     >                pfampe, pcfape,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 3. impression de la description des familles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. impressions familles ; codret', codret
#endif

      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTECFE', nompro
#endif
c
      call utecfe ( maext0,
     >              imem(pfamno), imem(pcfano),
     >              imem(pfammp), imem(pcfamp),
     >              imem(pfamar), imem(pcfaar),
     >              imem(pfamtr), imem(pcfatr),
     >              imem(pfamqu), imem(pcfaqu),
     >              imem(pfamte), imem(pcfate),
     >              imem(pfamhe), imem(pcfahe),
     >              imem(pfampy), imem(pcfapy),
     >              imem(pfampe), imem(pcfape),
     >              ulsort, langue, codret )
c
      endif
c
c====
c 4. fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
