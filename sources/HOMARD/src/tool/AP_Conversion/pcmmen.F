      subroutine pcmmen ( nbmaid, nbmaif, nbmanw,
     >                    noeele, fameel, typele,
     >                    numfam,
     >                    grfmpo, grfmtl, grfmtb,
     >                    nrofam, tbiaux,
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
c    aPres adaptation - Conversion de Maillage - MENage
c     -                 -             -          ---
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbmaid . e   .   1    . nombre de mailles au debut                 .
c . nbmaif . e   .   1    . estimation du nombre de mailles a la fin   .
c . nbmanw .  s  .   1    . nombre de nouvelles mailles                .
c . noeele . es  . nbmaif . noeuds des elements                        .
c .        .     .*nbmane .                                            .
c . fameel . es  . nbmaif . famille med des elements                   .
c . typele . es  . nbmaif . type des elements pour le code de calcul   .
c . nrofam . a   .2*nbfmed. auxiliaire                                 .
c . tbiaux . a   . nbfmed . auxiliaire                                 .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 3 : probleme                               .
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
      parameter ( nompro = 'PCMMEN' )
c
#include "consts.h"
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envca1.h"
#include "nbutil.h"
#include "rftmed.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer nbmaid, nbmaif, nbmanw
      integer noeele(nbmaif,nbmane)
      integer fameel(nbmaif), typele(nbmaif)
      integer numfam(nbfmed), grfmpo(0:nbfmed), grfmtl(*)
      integer nrofam(2,nbfmed), tbiaux(nbfmed)
c
      character*8 grfmtb(*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer nbfami
      integer numf, numfb
      integer lamail, nbnoma
c
      integer nrocou
c
      character*80 nomgro
      character*80 nomfic
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. preliminaires
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Groupe : '',a)'
      texte(1,5) = '(''Famille a dupliquer                :'',i10)'
      texte(1,6) = '(''Famille resultat de la duplication :'',i10)'
c
      texte(2,4) = '(''Group: '',a)'
      texte(2,5) = '(''Family to duplicate         :'',i10)'
      texte(2,6) = '(''Family after the duplication:'',i10)'
c
#include "impr03.h"
c
      codret = 0
c
c====
c 2. Lecture du numero de la couche en cours
c====
c
      nomfic = 'nrc.dat'
      jaux = 7
c
      call guoufs ( nomfic, jaux, kaux, codret )
c
      if ( codret.eq.0 ) then
c
      read (kaux,*) nrocou
      call gufefi ( nomfic, jaux, codret )
c
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nrocou', nrocou
#endif
c
c====
c 3. On passe en revue chaque famille
c     Pour une couche donnee, on a nbfami familles de mailles
c     concernees.
c     La creation des mailles du futur groupe R_xx_b equivaut a
c     dupliquer les mailles du groupe ROCHE_20 et de tous les groupes
c     CAV_20, CAV_19, ..., CAV_(xx+1)
c     Pour chacune de ces situations :
c     nrofam(1,n) = numero de la famille d'un maille a dupliquer
c     nrofam(2,n) = numero de la famille du maille duplique
c    Remarque : on suppose qu'il n'y a qu'une famille par groupe
c====
c
c 3.1. ==> Famille du groupe 'ROCHE_20'
c
      nomgro = blan80
      nomgro(1:8) = 'ROCHE_20'
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nomgro
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTFMGR', nompro
#endif
      call utfmgr ( nomgro, jaux, tbiaux,
     >              nbfmed, numfam,
     >              grfmpo, grfmtl, grfmtb,
     >              ulsort, langue, codret )
c
      nrofam(1,1) = tbiaux(1)
c
c 3.2. ==> Famille du groupe 'R_20_b'
c
      if ( codret.eq.0 ) then
c
      nomgro = blan80
      nomgro(1:6) = 'R_20_b'
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nomgro
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTFMGR', nompro
#endif
      call utfmgr ( nomgro, jaux, tbiaux,
     >              nbfmed, numfam,
     >              grfmpo, grfmtl, grfmtb,
     >              ulsort, langue, codret )
c
      nrofam(2,1) = tbiaux(1)
c
      endif
c
c 3.3. ==> Familles des groupes 'CAV_xx' et 'CAV_xx_b'
c
      nbfami = 1
c
      do 33 , iaux = 20, nrocou+1, -1
c
        nbfami = nbfami + 1
c
c 3.3.1. ==> Familles des groupes 'CAV_xx'
c
        if ( codret.eq.0 ) then
c
        nomgro = blan80
        nomgro(1:6) = 'CAV_00'
        if ( iaux.le.9) then
          write(nomgro(6:6),'(i1)') iaux
        else
          write(nomgro(5:6),'(i2)') iaux
        endif
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,4)) nomgro
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTFMGR', nompro
#endif
        call utfmgr ( nomgro, jaux, tbiaux,
     >                nbfmed, numfam,
     >                grfmpo, grfmtl, grfmtb,
     >                ulsort, langue, codret )
c
        nrofam(1,nbfami) = tbiaux(1)
c
        endif
c
c 3.3.2. ==> Familles des groupes 'CAV_xx_b'
c
        if ( codret.eq.0 ) then
c
        nomgro(7:8) = '_b'
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,4)) nomgro
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTFMGR', nompro
#endif
        call utfmgr ( nomgro, jaux, tbiaux,
     >                nbfmed, numfam,
     >                grfmpo, grfmtl, grfmtb,
     >                ulsort, langue, codret )
c
        nrofam(2,nbfami) = tbiaux(1)
c
        endif
c
   33 continue
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'nbfami', nbfami
      write(ulsort,91020) (nrofam(1,iaux),iaux=1,nbfami)
      write(ulsort,91020) (nrofam(2,iaux),iaux=1,nbfami)
#endif
c
c====
c 4. on passe en revue chaque famille a dupliquer
c====
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'nbmaid', nbmaid
#endif
c
      if ( codret.eq.0 ) then
c
      jaux = nbmaid
c
      do 41 , iaux = 1 , nbfami
c
c 4.1. ==> Le numero de la famille a dupliquer
c          Le numero de la famille des mailles apres duplication
c
        numf  = nrofam(1,iaux)
        numfb = nrofam(2,iaux)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) numf
      write (ulsort,texte(langue,6)) numfb
#endif
c
c 4.2. ==> On parcourt toutes les mailles
c
        do 42 , lamail = 1 , nbmaid
c
cgn        write (ulsort,texte(langue,6)) fameel(lamail), typele(lamail)
c
c       la famille de la maille est-elle celle a retenir ?
          if ( fameel(lamail).eq.numf ) then
c
c       On duplique
c
c         numero de la nouvelle maille
            jaux = jaux + 1
c
cgn      write(ulsort,90002) 'lamail/jaux', lamail,jaux
cgn      if ( jaux.eq.nbmaid + 1 .or. jaux.eq.nbmaif ) then
cgn      write(ulsort,90015) 'noeele(', lamail,')',
cgn     >(noeele(lamail,kaux), kaux = 1 , nbmane)
cgn        endif
            nbnoma = mednnm(typele(lamail))
            do 412 , kaux = 1 , nbnoma
              noeele(jaux,kaux) = noeele(lamail,kaux)
  412       continue
            fameel(jaux) = numfb
            typele(jaux) = typele(lamail)
c
          endif
c
   42   continue
c
   41 continue
cgn      write (ulsort,texte(langue,1)) 'Sortie', nompro
cgn      write(ulsort,90015) nompro//'noeele(',nbmaid + 1,')',
cgn     >(noeele(nbmaid + 1,iaux), iaux = 1 , nbmane)
cgn      write(ulsort,90015) nompro//'noeele(', nbmaif,')',
cgn     >(noeele(nbmaif,iaux), iaux = 1 , nbmane)
c
c     nombre de nouvelles mailles
      nbmanw = jaux - nbmaid
c
      endif
c
c====
c 5. la fin
c====
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'nbmanw', nbmanw
#endif
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
