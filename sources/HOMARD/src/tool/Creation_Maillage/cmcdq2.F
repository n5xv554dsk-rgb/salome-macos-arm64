      subroutine cmcdq2 ( lequad,
     >                    indare, indqua,
     >                    hetare, somare,
     >                    filare, merare, famare,
     >                    hetqua, arequa,
     >                    filqua, perqua, famqua,
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
c                           en 2 quadrangles
c                              -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lequad . e   .   1    . quadrangle a decouper                      .
c . indare . es  . 1      . indice de la derniere arete creee          .
c . indqua . es  . 1      . indice du dernier quadrangle cree          .
c . hetare . es  . nouvar . historique de l'etat des aretes            .
c . somare . es  .2*nouvar. numeros des extremites d'arete             .
c . filare . es  . nouvar . premiere fille des aretes                  .
c . merare . es  . nouvar . mere des aretes                            .
c . famare . es  . nouvar . caracteristiques des aretes                .
c . hetqua . es  . nouvqu . historique de l'etat des quadrangles       .
c . arequa . es  .nouvqu*3. numeros des 4 aretes des quadrangles       .
c . filqua . es  . nouvqu . premier fils des quadrangles               .
c . perqua . es  . nouvqu . pere des quadrangles                       .
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
      parameter ( nompro = 'CMCDQ2' )
c
#include "nblang.h"
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
      integer indare, indqua
      integer hetare(nouvar), somare(2,nouvar)
      integer filare(nouvar), merare(nouvar), famare(nouvar)
      integer hetqua(nouvqu), arequa(nouvqu,4)
      integer filqua(nouvqu), perqua(nouvqu), famqua(nouvqu)
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
      integer aifj, aifl, ni
      integer akfj, akfl, nk
      integer saiaj, sajak, sakal, salai
      integer nf1, nf2
      integer anink
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
      write (ulsort,90002) 'indare', indare
      write (ulsort,90002) 'indqua', indqua
      write (ulsort,90002) 'nouvqu', nouvqu
#endif
c
      codret = 0
c
c====
c 2. decoupage en 2 quadrangles des quadrangles de decision 2
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
c
c Quadrangles fils apres decoupages des aretes ai et ak
c
c       saiaj         aifj       ai/ni       aifl         salai
c           ._____________________________________________.
c           .                      .                      .
c           .                      .                      .
c           .                      .                      .
c           .                      .                      .
c           .                      .                      .
c           .                      .                      .
c        aj .         nq1          .anink      nq2        . al
c           .                      .                      .
c           .                      .                      .
c           .                      .                      .
c           .                      .                      .
c           .                      .                      .
c           .                      .                      .
c           ._____________________________________________.
c       sajak        akfj        ak/nk       akfl         sakal
c
c 2.1. ==> determination des numeros d'aretes et de leurs numeros locaux
c
      a1 = arequa(lequad,1)
      a2 = arequa(lequad,2)
      a3 = arequa(lequad,3)
      a4 = arequa(lequad,4)
cgn      print *,a1, a2, a3, a4
c
c 2.2. ==> determination des aretes et des sommets, relativement
c          au decoupage de l'arete
c
      call utcoq2 ( hetare, somare, filare, a1, a2, a3, a4,
     >              numdec, ai, aj, ak, al,
     >              aifj, aifl, ni,
     >              akfj, akfl, nk,
     >              saiaj, sajak, sakal, salai,
     >              ulsort, langue, codret )
c
c 2.3. ==> decoupage du quadrangle en fonction des aretes coupees
c 2.3.1. ==> creation de l'arete interieure
c
      if ( codret.eq.0 ) then
c
cgn          print * ,ai, aj, ak, al
cgn          print *,saiaj, sajak, sakal, salai
cgn          print *,aifj, aifl
cgn          print *,ni
c
      indare = indare + 1
      anink = indare
      somare(1,anink) = min(ni,nk)
      somare(2,anink) = max(ni,nk)
      jaux = cfaqua(cofafa,famqua(lequad))
      famare(anink) = jaux
      hetare(anink) = 50
      merare(anink) = 0
      filare(anink) = 0
c
c 2.3.2. ==> creation des deux quadrangles
c
      nf1 = indqua + 1
      arequa(nf1,1) = aifj
      arequa(nf1,2) = aj
      arequa(nf1,3) = akfj
      arequa(nf1,4) = anink
c
      nf2 = indqua + 2
      arequa(nf2,1) = akfl
      arequa(nf2,2) = al
      arequa(nf2,3) = aifl
      arequa(nf2,4) = anink
c
      jaux = nivqua(lequad) + 1
      do 232 , iaux = nf1 , nf2
        famqua(iaux) = famqua(lequad)
        hetqua(iaux) = 5500
        filqua(iaux) = 0
        perqua(iaux) = lequad
        nivqua(iaux) = jaux
  232 continue
c
c 2.3.3. ==> modification des parametres du quadrangle
c
      hetqua(lequad) = hetqua(lequad) + 20 + numdec
      filqua(lequad) = nf1
c
      indqua = nf2
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
