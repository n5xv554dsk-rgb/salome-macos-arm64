      subroutine eslnum ( idfmed, nomamd, degre,
     >                    nbnoto, nbelem,
     >                    nbmapo, nbsegm, nbtria, nbtetr,
     >                    nbquad, nbhexa, nbpent, nbpyra,
     >                    nunoex, nuelex,
     >                    numano, numael,
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
c  Entree-Sortie - Lecture des NUMerotations
c  -      -        -           ---
c  Par defaut, on part du principe que les elements externes sont
c  numerotes dans cet ordre :
c             tetraedres, triangles, segments, mailles-points,
c             quadrangles, hexaedres, pyramides, pentaedres
c  Voir eslmm2 pour confirmation.
c
c  Si la table de renumerotation est fournie, on ecrase la
c  correspondance.
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . unite logique du maillage d'entree         .
c . nomamd . e   . char64 . nom du maillage MED                        .
c . degre  . e   .   1    . degre du maillage                          .
c . nbnoto . e   .   1    . nombre de noeuds dans le maillage          .
c . nbelem . e   .   1    . nombre d'elements dans le maillage         .
c . nbmapo . e   .   1    . nombre de mailles-points                   .
c . nbsegm . e   .   1    . nombre de segments                         .
c . nbtria . e   .   1    . nombre de triangles                        .
c . nbtetr . e   .   1    . nombre de tetraedres                       .
c . nbhexa . e   .   1    . nombre d'hexaedres                         .
c . nbpyra . e   .   1    . nombre de pyramides                        .
c . nbpent . e   .   1    . nombre de pentaedres                       .
c . nuelex .  s  . nbelem . numerotation des elements en exterieur     .
c . nunoex .  s  . nbnoto . numerotation des noeuds en exterieur       .
c . numano .  s  .   1    . numero maximum des noeuds                  .
c . numael .  s  .   1    . numero maximum des elements                .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
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
      parameter ( nompro = 'ESLNUM' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
      integer degre
      integer nbnoto, nbelem
      integer nbmapo, nbsegm, nbtria, nbtetr
      integer nbquad, nbhexa, nbpent, nbpyra
      integer nunoex(nbnoto), nuelex(nbelem)
      integer numano, numael
c
      character*64 nomamd
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer iaux, jaux
      integer typnoe, typseg, typtri, typqua
      integer typtet, typhex, typpyr, typpen
      integer ibtetr, ibtria, ibsegm, ibmapo
      integer ibquad , ibhexa, ibpyra, ibpent
      integer codre1, codre2, codre3, codre4, codre5
      integer codre6, codre7, codre8, codre9
      integer codre0
      integer ntabno, ntabpo, ntabse, ntabtr, ntabqu
      integer ntabte, ntabhe, ntabpy, ntabpe
      integer numdt, numit
      integer datype, chgt, tsf
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
c 1.1. ==> les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
c====
c 2. grandeurs de base
c====
c
      typnoe = 0
      if ( degre.eq.1 ) then
        typseg = edseg2
        typtri = edtri3
        typqua = edqua4
        typtet = edtet4
        typhex = edhex8
        typpyr = edpyr5
        typpen = edpen6
      else
        typseg = edseg3
        typtri = edtri6
        typqua = edqua8
        typtet = edte10
        typhex = edhe20
        typpyr = edpy13
        typpen = edpe15
      endif
c
      ibtetr = 1
      ibtria = nbtetr + 1
      ibsegm = nbtetr + nbtria + 1
      ibmapo = nbtetr + nbtria + nbsegm + 1
      ibquad = nbtetr + nbtria + nbsegm + nbmapo + 1
      ibhexa = nbtetr + nbtria + nbsegm + nbmapo + nbquad + 1
      ibpyra = nbtetr + nbtria + nbsegm + nbmapo + nbquad + nbhexa + 1
      ibpent = nbtetr + nbtria + nbsegm + nbmapo + nbquad + nbhexa
     >       + nbpyra + 1
c
      numdt = ednodt
      numit = ednoit
      datype = edda03
c
c====
c 3. les renumerotations
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. les renumerotations ; codret = ', codret
#endif
c
c 3.1. ==> initialisation a la non renumerotation
c
      if ( codret.eq.0 ) then
c
      do 311 , iaux = 1, nbnoto
        nunoex(iaux) = iaux
  311 continue
      do 312 , iaux = 1, nbelem
        nuelex(iaux) = iaux
  312 continue
      numano = nbnoto
      numael = nbelem
c
      endif
c
c 3.2. ==> le nombre de noeuds et de mailles a renumeroter
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMHNME_NO', nompro
#endif
      call mmhnme ( idfmed, nomamd, numdt, numit,
     >              ednoeu, typnoe, datype, ednoda, chgt, tsf,
     >              ntabno, codre1 )
      call mmhnme ( idfmed, nomamd, numdt, numit,
     >              edmail, edpoi1, datype, ednoda, chgt, tsf,
     >              ntabpo, codre2 )
      call mmhnme ( idfmed, nomamd, numdt, numit,
     >              edmail, typseg, datype, ednoda, chgt, tsf,
     >              ntabse, codre3 )
      call mmhnme ( idfmed, nomamd, numdt, numit,
     >              edmail, typtri, datype, ednoda, chgt, tsf,
     >              ntabtr, codre4 )
      call mmhnme ( idfmed, nomamd, numdt, numit,
     >              edmail, typqua, datype, ednoda, chgt, tsf,
     >              ntabqu, codre5 )
      call mmhnme ( idfmed, nomamd, numdt, numit,
     >              edmail, typtet, datype, ednoda, chgt, tsf,
     >              ntabte, codre6 )
      call mmhnme ( idfmed, nomamd, numdt, numit,
     >              edmail, typhex, datype, ednoda, chgt, tsf,
     >              ntabhe, codre7 )
      call mmhnme ( idfmed, nomamd, numdt, numit,
     >              edmail, typpyr, datype, ednoda, chgt, tsf,
     >              ntabpy, codre8 )
      call mmhnme ( idfmed, nomamd, numdt, numit,
     >              edmail, typpen, datype, ednoda, chgt, tsf,
     >              ntabpe, codre9 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7, codre8, codre9 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7, codre8, codre9 )
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
 1000 format(a,' = ',10i13)
      write (ulsort,1000) 'ntabno', ntabno
      write (ulsort,1000) 'ntabpo', ntabpo
      write (ulsort,1000) 'ntabse', ntabse
      write (ulsort,1000) 'ntabtr', ntabtr
      write (ulsort,1000) 'ntabqu', ntabqu
      write (ulsort,1000) 'ntabte', ntabte
      write (ulsort,1000) 'ntabhe', ntabhe
      write (ulsort,1000) 'ntabpy', ntabpy
      write (ulsort,1000) 'ntabpe', ntabpe
      else
      write (ulsort,1000) 'codrei',
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7, codre8, codre9
      endif
#endif
c
c 3.3. ==> les tables de renumerotation
c
c 3.3.1. ==> les noeuds
c
      if ( codret.eq.0 ) then
      if ( nbnoto.gt.0 .and. ntabno.eq.nbnoto ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMHENR_NO', nompro
#endif
        call mmhenr ( idfmed, nomamd, numdt, numit,
     >                ednoeu, typnoe, nunoex,
     >                codret )
        if ( codret.eq.0 ) then
          do 331 , iaux = 1, nbnoto
            numano = max(numano,nunoex(iaux))
  331     continue
        endif
      endif
      endif
c
c 3.3.2. ==> les mailles-points
c
      if ( codret.eq.0 ) then
      if ( nbmapo.gt.0 .and. ntabpo.eq.nbmapo ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMHENR_MP', nompro
#endif
        call mmhenr ( idfmed, nomamd, numdt, numit,
     >                edmail, edpoi1, nuelex(ibmapo),
     >                codret )
        if ( codret.eq.0 ) then
          jaux = ibmapo + nbmapo - 1
          do 332 , iaux = ibmapo , jaux
            numael = max(numael,nuelex(iaux))
  332     continue
        endif
      endif
      endif
c
c 3.3.3. ==> les segments
c
      if ( codret.eq.0 ) then
      if ( nbsegm.gt.0 .and. ntabse.eq.nbsegm ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMHENR_AR', nompro
#endif
        call mmhenr ( idfmed, nomamd, numdt, numit,
     >                edmail, typseg, nuelex(ibsegm),
     >                codret )
        if ( codret.eq.0 ) then
          jaux = ibsegm + nbsegm - 1
          do 333 , iaux = ibsegm , jaux
            numael = max(numael,nuelex(iaux))
  333     continue
        endif
      endif
      endif
c
c 3.3.4. ==> les triangles
c
      if ( codret.eq.0 ) then
      if ( nbtria.gt.0 .and. ntabtr.eq.nbtria ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMHENR_TR', nompro
#endif
        call mmhenr ( idfmed, nomamd, numdt, numit,
     >                edmail, typtri, nuelex(ibtria),
     >                codret )
        if ( codret.eq.0 ) then
          jaux = ibtria + nbtria - 1
          do 334 , iaux = ibtria, jaux
            numael = max(numael,nuelex(iaux))
  334     continue
        endif
      endif
      endif
c
c 3.3.5. ==> les tetraedres
c
      if ( codret.eq.0 ) then
      if ( nbtetr.gt.0 .and. ntabte.eq.nbtetr ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMHENR_TE', nompro
#endif
        call mmhenr ( idfmed, nomamd, numdt, numit,
     >                edmail, typtet, nuelex(ibtetr),
     >                codret )
        if ( codret.eq.0 ) then
          jaux = ibtetr + nbtetr - 1
          do 335 , iaux = ibtetr, jaux
            numael = max(numael,nuelex(iaux))
  335     continue
        endif
      endif
      endif
c
c 3.3.6. ==> les quadrangles
c
      if ( codret.eq.0 ) then
      if ( nbquad.gt.0 .and. ntabqu.eq.nbquad ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMHENR_QU', nompro
#endif
        call mmhenr ( idfmed, nomamd, numdt, numit,
     >                edmail, typqua, nuelex(ibquad),
     >                codret )
        if ( codret.eq.0 ) then
          jaux = ibquad + nbquad - 1
          do 336 , iaux = ibquad, jaux
            numael = max(numael,nuelex(iaux))
  336     continue
        endif
      endif
      endif
c
c 3.3.7. ==> les hexaedres
c
      if ( codret.eq.0 ) then
      if ( nbhexa.gt.0 .and. ntabhe.eq.nbhexa ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMHENR_HE', nompro
#endif
        call mmhenr ( idfmed, nomamd, numdt, numit,
     >                edmail, typhex, nuelex(ibhexa),
     >                codret )
        if ( codret.eq.0 ) then
          jaux = ibhexa + nbhexa - 1
          do 337 , iaux = ibhexa, jaux
            numael = max(numael,nuelex(iaux))
  337     continue
        endif
      endif
      endif
c
c 3.3.8. ==> les pyramides
c
      if ( codret.eq.0 ) then
      if ( nbpyra.gt.0 .and. ntabpy.eq.nbpyra ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMHENR_PY', nompro
#endif
        call mmhenr ( idfmed, nomamd, numdt, numit,
     >                edmail, typpyr, nuelex(ibpyra),
     >                codret )
        if ( codret.eq.0 ) then
          jaux = ibpyra + nbpyra - 1
          do 338 , iaux = ibpyra, jaux
            numael = max(numael,nuelex(iaux))
  338     continue
        endif
      endif
      endif
c
c 3.3.9. ==> les pentaedres
c
      if ( codret.eq.0 ) then
      if ( nbpent.gt.0 .and. ntabpe.eq.nbpent ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMHENR_PE', nompro
#endif
        call mmhenr ( idfmed, nomamd, numdt, numit,
     >                edmail, typpen, nuelex(ibpent),
     >                codret )
        if ( codret.eq.0 ) then
          jaux = ibpent + nbpent - 1
          do 339 , iaux = ibpent, jaux
            numael = max(numael,nuelex(iaux))
  339     continue
        endif
      endif
      endif
c
c====
c 4. la fin
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
