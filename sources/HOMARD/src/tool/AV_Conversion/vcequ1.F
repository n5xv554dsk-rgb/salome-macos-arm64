      subroutine vcequ1 ( nunoex, nuelex,
     >                    noehom, nnosho, eqnoeu,
     >                    arehom, narsho, eqaret,
     >                    trihom, ntrsho, eqtria,
     >                    quahom, nqusho, eqquad,
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
c    aVant adaptation Conversion - EQUivalence - phase 1
c     -               -            ---                 -
c
c    remarque : ce traitement suppose qu'une entite ne possede pas plus
c               d'un homologue. Si des cas plus compliques apparaissent,
c               il faudra modifier la structure des equivalences
c
c    on fait une traduction bete des donnees en entree.
c    pour chaque couple d'entite (e1,e2) donnees comme homologue, on
c    note entequ(e1)=+-e2 et entequ(e2)=+-e1
c    on fait evidemment les changements de numerotation appropries.
c
c   remarque importante : reperage des elements homologues
c     on prend la convention de reperage suivante : lorsque
c     l'on a deux faces periodiques 1 et 2, on attribue un signe a
c     chacune des faces. pour un noeud "i", noehom(i) est alors egal
c     a la valeur suivante :
c     - "le numero du noeud correspondant par periodicite
c        si i est sur la face 2"
c     - "l'oppose du numero du noeud correspondant par periodicite
c        si i est sur la face 1"
c
c     Donc, on etend cette convention a toutes les entites noeuds,
c     aretes, triangles et quadrangles :
c     enthom(i) = abs(homologue(i)) ssi i est sur la face 2
c     enthom(i) = -abs(homologue(i)) ssi i est sur la face 1
c
c     pour une entite situee sur l'axe, on prend la convention positive
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nuelex . e   . nbelem . numerotation des elements en exterieur     .
c . nunoex . e   . nbnoto . numerotation des noeuds en exterieur       .
c . noehom .   s . nbnoto . liste etendue des homologues par noeuds    .
c . nnosho . e   . rsnoac . numero des noeuds dans HOMARD              .
c . eqnoeu . e   .2*nbeqno. ensemble des noeuds homologues ; leurs     .
c .        .     .        . numeros sont dans la numerotation du code  .
c .        .     .        . de calcul                                  .
c . arehom .   s . nbarto . liste etendue des homologues par aretes    .
c . narsho . e   . rsarac . numero des aretes dans HOMARD              .
c . eqaret . e   .2*nbeqar. ensemble des aretes homologues ; leurs     .
c .        .     .        . numeros sont dans la numerotation du code  .
c .        .     .        . de calcul                                  .
c . trihom .   s . nbtrto . ensemble des triangles homologues          .
c . ntrsho . e   . rstrac . numero des triangles dans HOMARD           .
c . eqtria . e   .2*nbeqtr. ensemble des triangles homologues ; leurs  .
c .        .     .        . numeros sont dans la numerotation du code  .
c .        .     .        . de calcul                                  .
c . quahom .   s . nbquto . ensemble des quadrangles homologues        .
c . nqusho . e   . rsquac . numero des quadrangles dans HOMARD         .
c . eqquad . e   .2*nbeqqu. ensemble des quadrangles homologues ; leurs.
c .        .     .        . numeros sont dans la numerotation du code  .
c .        .     .        . de calcul                                  .
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
      parameter ( nompro = 'VCEQU1' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombsr.h"
#include "nbutil.h"
c
c 0.3. ==> arguments
c
      integer nunoex(nbnoto), nuelex(nbelem)
      integer noehom(nbnoto), nnosho(rsnoac), eqnoeu(2*nbeqno)
      integer arehom(nbarto), narsho(rsarac), eqaret(2*nbeqar)
      integer trihom(nbtrto), ntrsho(rstrac), eqtria(2*nbeqtr)
      integer quahom(nbquto), nqusho(rsquac), eqquad(2*nbeqqu)
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
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
      codret = 0
c
c====
c 2. prise en compte des donnees sur les noeuds homologues
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2. noeuds ; codret = ', codret
#endif
c
      if ( nbeqar.ne.0 .or. nbeqtr.ne.0 .or. nbeqqu.ne.0 ) then
        do 21 , iaux = 1 , nbnoto
          noehom(iaux) = 0
   21   continue
      endif
c
      iaux = -1
      jaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCEQU3_no', nompro
#endif
      call vcequ3 ( iaux,
     >              nbnoto, nbeqno, jaux,
     >              nunoex, noehom, nnosho, eqnoeu,
     >              ulsort, langue, codret )
cgn           print *,nompro,' apres 2'
cgn           print *,'noehom'
cgn           print 1789,(noehom(iaux),iaux=1,27)
cgn 1787 format(4I4)
cgn 1788 format(8I4)
cgn 1789 format(10I4)
c
c====
c 3. prise en compte des donnees sur les aretes homologues
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. aretes ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbeqtr.ne.0 .or. nbeqqu.ne.0 ) then
        do 31 , iaux = 1 , nbarto
          arehom(iaux) = 0
   31   continue
      endif
c
      iaux = 1
      jaux = nbtetr + nbtria
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCEQU3_ar', nompro
#endif
      call vcequ3 ( iaux,
     >              nbarto, nbeqar, jaux,
     >              nuelex, arehom, narsho, eqaret,
     >              ulsort, langue, codret )
c
      endif
cgn           print *,nompro,' apres 3'
cgn           print *,'arehom'
cgn           print 1789,(arehom(iaux),iaux=1,50)
c
c====
c 4. prise en compte des donnees sur les triangles homologues
c    on complete la liste, en verifiant que si il y a deja un
c    homologue, c'est le bon !
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4. triangles ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = 2
      jaux = nbtetr
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCEQU3_tr', nompro
#endif
      call vcequ3 ( iaux,
     >              nbtrto, nbeqtr, jaux,
     >              nuelex, trihom, ntrsho, eqtria,
     >              ulsort, langue, codret )
c
      endif
cgn           print *,nompro,' apres 4'
cgn           print *,'trihom'
cgn           print 1788,(trihom(iaux),iaux=1,16)
c
c====
c 5. prise en compte des donnees sur les quadrangles homologues
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '5. quadrangles ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = 4
      jaux = nbtetr + nbtria + nbsegm + nbmapo
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCEQU3_qu', nompro
#endif
      call vcequ3 ( iaux,
     >              nbquto, nbeqqu, jaux,
     >              nuelex, quahom, nqusho, eqquad,
     >              ulsort, langue, codret )
c
      endif
cgn           print *,nompro,' apres 5'
cgn           print *,'quahom'
cgn           print 1787,(quahom(iaux),iaux=1,8)
c
c====
c 6. la fin
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
