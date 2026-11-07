      subroutine vcequi ( nunoex, nuelex,
     >                    coexno, nnosho, eqnoeu,
     >                    coexar, narsho, eqaret,
     >                    coextr, ntrsho, eqtria,
     >                    coexqu, nqusho, eqquad,
     >                    eqpntr,
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
c    aVant adaptation Conversion - EQUIvalence
c     -               -            ----
c ______________________________________________________________________
c
c but : prise en compte pour chaque entite de l'appartenance a une
c       equivalence
c       on a 1 si l'entite appartient a l'equivalence, 0 sinon.
c
c       les numeros d'entites stockes dans les listes des equivalences
c       de noeuds ou d'elements sont exprimes dans la numerotation
c       originale du maillage et non pas la numerotation compactee
c       de 1 a N de la structure Maillage de Calcul. on doit donc faire
c       appel aux renumerotations pour etablir les codes des familles
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nuelex . e   . nbelem . numerotation des elements en exterieur     .
c . nunoex . e   . nbnoto . numerotation des noeuds en exterieur       .
c . coexno . es  . nbnoto*. codes de conditions aux limites portants   .
c .        .     . nctfno . sur les noeuds                             .
c . nnosho . e   . rsnoac . numero des noeuds dans HOMARD              .
c . eqnoeu . e   .2*nbeqno. ensemble des noeuds homologues ; leurs     .
c .        .     .        . numeros sont dans la numerotation du code  .
c .        .     .        . de calcul                                  .
c . coexar . es  . nbarto*. codes de conditions aux limites portants   .
c .        .     . nctfar . sur les aretes                             .
c . narsho . e   . rsarac . numero des aretes dans HOMARD              .
c . eqaret . e   .2*nbeqar. ensemble des aretes homologues ; leurs     .
c .        .     .        . numeros sont dans la numerotation du code  .
c .        .     .        . de calcul                                  .
c . coextr . es  . nbtrto*. codes de conditions aux limites portants   .
c .        .     . nctftr . sur les triangles                          .
c . ntrsho . e   . rstrac . numero des triangles dans HOMARD           .
c . eqtria . e   .2*nbeqtr. ensemble des triangles homologues ; leurs  .
c .        .     .        . numeros sont dans la numerotation du code  .
c .        .     .        . de calcul                                  .
c . coexqu . es  . nbquto*. codes de conditions aux limites portants   .
c .        .     . nctfqu . sur les quadrangles                        .
c . nqusho . e   . rsquac . numero des quadrangles dans HOMARD         .
c . eqquad . e   .2*nbeqqu. ensemble des quadrangles homologues ; leurs.
c .        .     .        . numeros sont dans la numerotation du code  .
c .        .     .        . de calcul                                  .
c . eqpntr . e   .5*nbequi. 5i-4 : nombre de paires de noeuds pour     .
c .        .     .        .        l'equivalence i                     .
c .        .     .        . 5i-3 : idem pour les mailles-points        .
c .        .     .        . 5i-2 : idem pour les aretes                .
c .        .     .        . 5i-1 : idem pour les triangles             .
c .        .     .        . 5i   : idem pour les quadrangles           .
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
      parameter ( nompro = 'VCEQUI' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "dicfen.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombsr.h"
#include "nbutil.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer nunoex(nbnoto), nuelex(nbelem)
      integer coexno(nbnoto,nctfno), nnosho(rsnoac), eqnoeu(2*nbeqno)
      integer coexar(nbarto,nctfar), narsho(rsarac), eqaret(2*nbeqar)
      integer coextr(nbtrto,nctftr), ntrsho(rstrac), eqtria(2*nbeqtr)
      integer coexqu(nbquto,nctfqu), nqusho(rsquac), eqquad(2*nbeqqu)
      integer eqpntr(5*nbequi)
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer ibtria, ibsegm, ibquad
      integer ideb, ifin
      integer iaux, jaux, kaux, laux
      integer iaux1, iaux2, iaux3, iaux4
      integer debcon, debcoa, debcot, debcoq
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(/,''Equivalence numero '',i4)'
      texte(1,5) = '(''. il y a'',i10,'' paires de '',a)'
c
      texte(1,4) = '(/,''Equivalence # '',i4)'
      texte(2,5) = '(''. with'',i10,'' pairs of '',a)'
c
      codret = 0
c
c 1.2. ==> reperage dans la numerotation contigue des elements
c
      ibtria = nbtetr
      ibsegm = nbtetr + nbtria
      ibquad = nbtetr + nbtria + nbsegm + nbmapo
c
c====
c 3. a priori, les entites ne font partie d'aucune equivalence
c====
c
c 3.1. ==> noeuds
c
      ifin = nctfno
      debcon = ifin - ncefno + 1
      do 31 , iaux = debcon , ifin
        do 311 , jaux = 1 , nbnoto
          coexno(jaux,iaux) = 0
  311   continue
   31 continue
c
c 3.2. ==> aretes
c
      ifin = nctfar
      debcoa = ifin - ncefar + 1
      do 32 , iaux = debcoa, ifin
        do 321 , jaux = 1 , nbarto
          coexar(jaux,iaux) = 0
  321   continue
   32 continue
c
c 3.3. ==> triangles
c
      ifin = nctftr
      debcot = ifin - nceftr + 1
cgn      print *,debcot, ifin
      do 33 , iaux =  debcot, ifin
        do 331 , jaux = 1 , nbtrto
          coextr(jaux,iaux) = 0
  331   continue
   33 continue
c
c 3.4. ==> quadrangles
c
      ifin = nctfqu
      debcoq = ifin - ncefqu + 1
cgn      print *,debcoq, ifin
      do 34 , iaux =  debcoq, ifin
        do 341 , jaux = 1 , nbquto
          coexqu(jaux,iaux) = 0
  341   continue
   34 continue
c
c====
c 4. on passe en revue toutes les equivalences
c====
c
      iaux1 = -1
      iaux2 = -1
      iaux3 = -1
      iaux4 = -1
c
      do 40 , jaux = 1 , nbequi
c
#ifdef _DEBUG_HOMARD_
        write(ulsort,texte(langue,4)) jaux
#endif
c
c 4.1. ==> les noeuds
c
        laux = eqpntr(5*jaux-4)
c
        if ( laux.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
          write(ulsort,texte(langue,5)) laux, mess14(langue,3,-1)
#endif
          ideb = iaux1 + 2
          iaux1 = iaux1 + 2*laux
          kaux = debcon - 1 + jaux
          do 401 , iaux = ideb, iaux1, 2
            coexno(nnosho(nunoex(eqnoeu(iaux))),kaux) = 1
            coexno(nnosho(nunoex(eqnoeu(iaux+1))),kaux) = 1
  401     continue
c
        endif
c
c 4.2. ==> les aretes
c
        laux = eqpntr(5*jaux-2)
c
        if ( laux.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
          write(ulsort,texte(langue,5)) laux, mess14(langue,3,1)
#endif
          ideb = iaux2 + 2
          iaux2 = iaux2 + 2*laux
          kaux = debcoa - 1 + jaux
          do 402 , iaux = ideb, iaux2, 2
            coexar(narsho(nuelex(ibsegm+eqaret(iaux))),kaux) = 1
            coexar(narsho(nuelex(ibsegm+eqaret(iaux+1))),kaux) = 1
  402     continue
c
        endif
c
c 4.3. ==> les triangles
c
        laux = eqpntr(5*jaux-1)
c
        if ( laux.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
          write(ulsort,texte(langue,5)) laux, mess14(langue,3,2)
#endif
          ideb = iaux3 + 2
          iaux3 = iaux3 + 2*laux
          kaux = debcot - 1 + jaux
          do 403 , iaux = ideb, iaux3, 2
            coextr(ntrsho(nuelex(ibtria+eqtria(iaux))),kaux) = 1
            coextr(ntrsho(nuelex(ibtria+eqtria(iaux+1))),kaux) = 1
  403     continue
c
        endif
c
c 4.4. ==> les quadrangles
c
        laux = eqpntr(5*jaux)
c
        if ( laux.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
          write(ulsort,texte(langue,5)) laux, mess14(langue,3,4)
#endif
          ideb = iaux4 + 2
          iaux4 = iaux4 + 2*laux
          kaux = debcoq - 1 + jaux
          do 404 , iaux = ideb, iaux4, 2
            coexqu(nqusho(nuelex(ibquad+eqquad(iaux))),kaux) = 1
            coexqu(nqusho(nuelex(ibquad+eqquad(iaux+1))),kaux) = 1
  404     continue
c
        endif
c
   40 continue
c
c====
c 5. la fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1))
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
