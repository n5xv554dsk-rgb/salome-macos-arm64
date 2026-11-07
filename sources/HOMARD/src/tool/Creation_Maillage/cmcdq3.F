      subroutine cmcdq3 ( lequad,
     >                    indare, indtri,
     >                    hetare, somare,
     >                    filare, merare, famare,
     >                    hettri, aretri,
     >                    filtri, pertri, famtri,
     >                    nivtri,
     >                    hetqua, arequa,
     >                    filqua, famqua,
     >                    nivqua,
     >                    cfaqua,
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
c    Creation du Maillage - Conformite - Decoupage des Quadrangles
c    -           -          -            -             -
c                           en 3 triangles
c                              -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lequad . e   .   1    . quadrangle a decouper                      .
c . indare . es  . 1      . indice de la derniere arete creee          .
c . indtri . es  . 1      . indice du dernier triangle cree            .
c . hetare . es  . nouvar . historique de l'etat des aretes            .
c . somare . es  .2*nouvar. numeros des extremites d'arete             .
c . filare . es  . nouvar . premiere fille des aretes                  .
c . merare . es  . nouvar . mere des aretes                            .
c . famare . es  . nouvar . caracteristiques des aretes                .
c . hettri . es  . nouvtr . historique de l'etat des triangles         .
c . aretri . es  .nouvtr*3. numeros des 3 aretes des triangles         .
c . filtri . es  . nouvtr . premier fils des triangles                 .
c . pertri . es  . nouvtr . pere des triangles                         .
c . nivtri . es  . nouvtr . niveau des triangles                       .
c . famtri . es  . nouvtr . famille des triangles                      .
c . hetqua . es  . nouvqu . historique de l'etat des quadrangles       .
c . arequa . es  .nouvqu*3. numeros des 4 aretes des quadrangles       .
c . filqua . es  . nouvqu . premier fils des quadrangles               .
c . famqua . es  . nouvqu . famille des quadrangles                    .
c . nivqua . es  . nouvqu . niveau des quadrangles                     .
c . cfaqua . e   . nctfqu*. codes des familles des quadrangles         .
c .        .     . nbfqua .   1 : famille MED                          .
c .        .     .        .   2 : type de quadrangle                   .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        .   5 : famille des triangles de conformite  .
c .        .     .        .   6 : famille de sf active/inactive        .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
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
      parameter ( nompro = 'CMCDQ3' )
c
#include "nblang.h"
#include "coftfq.h"
#include "cofatq.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nouvnb.h"
#include "dicfen.h"
#include "nbfami.h"
c
c 0.3. ==> arguments
c
      integer lequad
      integer indare, indtri
      integer hetare(nouvar), somare(2,nouvar)
      integer filare(nouvar), merare(nouvar), famare(nouvar)
      integer hettri(nouvtr), aretri(nouvtr,3)
      integer filtri(nouvtr), pertri(nouvtr), famtri(nouvtr)
      integer nivtri(nouvtr)
      integer hetqua(nouvqu), arequa(nouvqu,4)
      integer filqua(nouvqu), famqua(nouvqu)
      integer nivqua(nouvqu)
      integer cfaqua(nctfqu,nbfqua)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer numdec
      integer a1, a2, a3, a4
      integer ai, aj, ak, al
      integer aifj, aifl
      integer saiaj, sajak, sakal, salai
      integer ni
      integer nf1, nf2, nf3
      integer anijk, anikl
      integer iaux, jaux, kaux
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
      texte(1,4) ='(''Les decisions de decoupage des aretes du'')'
      texte(1,5) ='(''quadrangle numero'',i10,'' sont incoherentes :'')'
      texte(1,6) ='(''Arete'',i2,'' :'',i10,'' et historique :'',i10)'
c
      texte(2,4) ='(''Decisions for the edges of the'')'
      texte(2,5) ='(''quadrangle #'',i10,''do not match :'')'
      texte(2,6) ='(''Edge #'',i2,'' :'',i10,'' state :'',i10)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'entree : indare', indare
      write (ulsort,90002) 'entree : indtri', indtri
      write (ulsort,90002) 'entree : nouvtr', nouvtr
#endif
c
      codret = 0
c
c====
c 2. decoupage en 3 des quadrangles de decision 3
c====
c
c   Quadrangle pere :
c     ak = numero de la k-eme arete du quadrangle pere
c     sajak = numero du noeud commun aux aretes aj et ak
c
c       sa4a1                       a4                        sa3a4
c           ._________________________________________________.
c           .                                                 .
c           .                                                 .
c           .                                                 .
c           .                                                 .
c           .                                                 .
c           .                                                 .
c        a1 .                                                 . a3
c           .                                                 .
c           .                                                 .
c           .                                                 .
c           .                                                 .
c           .                                                 .
c           .                                                 .
c           ._________________________________________________.
c       sa1a2                       a2                        sa2a3
c
c   Remarque : on appelle ici le sens standard celui correspondant
c              a l'enchainement (a1,a2,a3,a4)
c
c   Triangles fils apres decoupage de l'arete ai :
c     l'ordre (ai,aj,ak,al) est le meme que (a1,a2,a3,a4)
c     nfk = numero du k-eme triangle fils
c     la description des triangles doit se faire dans le meme sens
c     que le quadrangle
c     . le premier triangle est celui qui s'appuie sur le milieu
c       de l'arete coupee, ai/ni, et sur l'arete opposee, ak :
c       nf1 : (anijk,ak,anikl)
c     . le deuxieme triangle, nf2, est celui qui s'appuie sur la fille
c       de l'arete coupee allant vers saiaj et sur l'arete aj.
c       nf2 : (aifj,aj,anijk)
c     . le troisieme triangle, nf3, est celui qui s'appuie sur la fille
c       de l'arete coupee allant vers salai et sur l'arete al.
c       nf2 : (aifl,anikl,al)
c
c       saiaj         aifj       ai/ni       aifl         salai
c           ._____________________________________________.
c           .                      .                      .
c           .                     . .                     .
c           .                    .   .                    .
c           .                   .     .                   .
c           .                  .       .                  .
c           .                 .         .                 .
c           .       nf2      .           .       nf3      .
c           .               .             .               .
c           .              .               .              .
c           .             .                 .             .
c        aj .            .                   .            . al
c           .           .anijk           anikl.           .
c           .          .                       .          .
c           .         .                         .         .
c           .        .                           .        .
c           .       .                             .       .
c           .      .               nf1             .      .
c           .     .                                 .     .
c           .    .                                   .    .
c           .   .                                     .   .
c           .  .                                       .  .
c           . .                                         . .
c           ._____________________________________________.
c       sajak                       ak                    sakal
c
c 2.1. ==> determination des numeros d'aretes et de leurs numeros locaux
c
      a1 = arequa(lequad,1)
      a2 = arequa(lequad,2)
      a3 = arequa(lequad,3)
      a4 = arequa(lequad,4)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'arete 1', a1, hetare(a1)
      write (ulsort,90002) 'arete 2', a2, hetare(a2)
      write (ulsort,90002) 'arete 3', a3, hetare(a3)
      write (ulsort,90002) 'arete 4', a4, hetare(a4)
#endif
c
c 2.2. ==> determination des aretes et des sommets, relativement
c          au decoupage de l'arete
c
      call utcoq3 ( hetare, somare, filare, a1, a2, a3, a4,
     >              numdec, ai, aj, ak, al, aifj, aifl,
     >              saiaj, sajak, sakal, salai, ni,
     >              ulsort, langue, codret )
c
c 2.3. ==> decoupage du quadrangle en fonction de l'arete coupee
c 2.3.1. ==> creation des deux aretes interieures
c
      if ( codret.eq.0 ) then
c
cgn          print * ,ai, aj, ak, al
cgn          print *,saiaj, sajak, sakal, salai
cgn          print *,aifj, aifl
cgn          print *,ni
c
      indare = indare + 1
      anijk = indare
      somare(1,anijk) = min(sajak,ni)
      somare(2,anijk) = max(sajak,ni)
      jaux = cfaqua(cofafa,famqua(lequad))
      famare(anijk) = jaux
      hetare(anijk) = 50
      merare(anijk) = 0
      filare(anijk) = 0
c
      indare = indare + 1
      anikl = indare
      somare(1,anikl) = min(sakal,ni)
      somare(2,anikl) = max(sakal,ni)
      jaux = cfaqua(cofafa,famqua(lequad))
      famare(anikl) = jaux
      hetare(anikl) = 50
      merare(anikl) = 0
      filare(anikl) = 0
c
c 2.3.2. ==> creation des trois triangles
c
      nf1 = indtri + 1
      aretri(nf1,1) = anijk
      aretri(nf1,2) = ak
      aretri(nf1,3) = anikl
c
      nf2 = indtri + 2
      aretri(nf2,1) = aifj
      aretri(nf2,2) = aj
      aretri(nf2,3) = anijk
c
      nf3 = indtri + 3
      aretri(nf3,1) = aifl
      aretri(nf3,2) = anikl
      aretri(nf3,3) = al
cgn      write(ulsort,90002) 'Creation des triangles',nf1,nf2,nf3
cgn      write(ulsort,90002) 'famqua(lequad)',famqua(lequad)
cgn      write(ulsort,90002) 'avec cfaqua',
cgn     >(cfaqua(iaux,famqua(lequad)),iaux=1,nctfqu)
cgn      write(ulsort,90002) '==> famtri', cfaqua(coftfq,famqua(lequad))
c
      jaux = nivqua(lequad) + 1
      kaux = cfaqua(coftfq,famqua(lequad))
      do 232 , iaux = nf1 , nf3
        famtri(iaux) = kaux
        hettri(iaux) = 50
        filtri(iaux) = 0
        pertri(iaux) = -lequad
        nivtri(iaux) = jaux
  232 continue
c
c 2.3.3. ==> modification des parametres du quadrangle
c
      hetqua(lequad) = hetqua(lequad) + 30 + numdec
      filqua(lequad) = -nf1
c
      indtri = nf3
c
      else
c
        write (ulsort,texte(langue,4))
        write (ulsort,texte(langue,5)) lequad
        write (ulsort,texte(langue,6)) 1, a1, hetare(a1)
        write (ulsort,texte(langue,6)) 2, a2, hetare(a2)
        write (ulsort,texte(langue,6)) 3, a3, hetare(a3)
        write (ulsort,texte(langue,6)) 4, a4, hetare(a4)
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'Sortie : indare', indare
      write (ulsort,90002) 'Sortie : indtri', indtri
cgn      write (ulsort,*) 'Sortie : nivtri', nivtri
cgn      write (ulsort,*) 'Sortie : nivqua', nivqua
#endif
c
c====
c 3. la fin
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
