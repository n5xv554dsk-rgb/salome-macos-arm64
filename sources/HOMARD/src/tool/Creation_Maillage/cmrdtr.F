      subroutine cmrdtr ( somare, hetare, filare, merare,
     >                    aretri, hettri, filtri, pertri,
     >                    nivtri, decfac,
     >                    famare, famtri,
     >                    indare, indtri,
     >                    cfatri,
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
c    Creation du Maillage - Raffinement - Decoupage des TRiangles
c    -           -          -             -             --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . somare . es  .2*nouvar. numeros des extremites d'arete             .
c . hetare . es  . nouvar . historique de l'etat des aretes            .
c . filare . es  . nouvar . premiere fille des aretes                  .
c . merare . es  . nouvar . mere des aretes                            .
c . aretri . es  .nouvtr*3. numeros des 3 aretes des triangles         .
c . hettri . es  . nouvtr . historique de l'etat des triangles         .
c . filtri . es  . nouvtr . premier fils des triangles                 .
c . pertri . es  . nouvtr . pere des triangles                         .
c . nivtri . es  . nouvtr . niveau des triangles                       .
c . decfac . es  . -nouvqu. decision sur les faces (quad. + tri.)      .
c .        .     . :nouvtr.                                            .
c . famare .     . nouvar . famille des aretes                         .
c . famtri . es  . nouvtr . famille des triangles                      .
c . indare . es  . 1      . indice de la derniere arete creee          .
c . indtri . es  . 1      . indice du dernier triangle cree            .
c . cfatri . e   . nctftr*. codes des familles des triangles           .
c .        .     . nbftri .   1 : famille MED                          .
c .        .     .        .   2 : type de triangle                     .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        . + l : appartenance a l'equivalence l       .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
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
      parameter ( nompro = 'CMRDTR' )
c
#include "nblang.h"
#include "cofatq.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "nombtr.h"
#include "nouvnb.h"
#include "dicfen.h"
#include "nbfami.h"
c
c 0.3. ==> arguments
c
      integer decfac(-nouvqu:nouvtr)
      integer somare(2,nouvar), hetare(nouvar), filare(nouvar)
      integer merare(nouvar), aretri(nouvtr,3), hettri(nouvtr)
      integer filtri(nouvtr), pertri(nouvtr), nivtri(nouvtr)
      integer famare(nouvar), famtri(nouvtr)
      integer indare, indtri
      integer cfatri(nctftr,nbftri)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer fammer, letria
      integer n1, n2, n3, as1s2, as1s3, as2s3
      integer as1n2, as1n3, as2n1, as2n3, as3n1, as3n2
      integer af1, af2, af3, etat, nf, nf1, nf2, nf3, niv
      integer lepere
      integer iaux
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
      texte(1,4) = '(''Decoupage du triangle'',i10)'
c
      texte(2,4) = '(''Splitting of triangle #'',i10)'
c
#include "impr03.h"
c
c====
c 1. decoupage en 4 des triangles de decision 4
c====
c
cgn      print *,'indtri',indtri
cgn      print *,'indare',indare
      do 100 , letria = 1 , nbtrpe
cgn      print *,letria,decfac(letria)
c
        if ( decfac(letria).eq.4 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) letria
#endif
c
c 1.1. ==> determination des numeros d'aretes
c
          as2s3 = aretri(letria,1)
          as1s3 = aretri(letria,2)
          as1s2 = aretri(letria,3)
cgn      write (ulsort,90002)'.. indqua',indqua
cgn      write (ulsort,90002)'.. indare',indare
cgn      write (ulsort,90002)'.. aretes     ',as2s3,as1s3,as1s2
cgn      write (ulsort,90002)'.. de filles  ',filare(as2s3),
cgn     >                    filare(as1s3),filare(as1s2)
c
c 1.2. ==> determination des 6 demi-aretes filles des precedentes
c
          call utaftr ( somare, filare, as2s3, as1s3, as1s2,
     >                  as2n1, as3n1,
     >                  as3n2, as1n2,
     >                  as1n3, as2n3 )
c
c 1.3. ==> determination des noeuds milieux
c
          n1 = somare(2,as2n1)
          n2 = somare(2,as1n2)
          n3 = somare(2,as1n3)
c
c 1.4. ==> creation des aretes internes
c
c 1.4.1. ==> leurs numeros
c
          af1 = indare + 1
          af2 = indare + 2
          af3 = indare + 3
          indare = af3
c
c 1.4.2. ==> les numeros de leurs sommets avec la convention ad'hoc
c
          somare(1,af1) = min ( n2 , n3 )
          somare(2,af1) = max ( n2 , n3 )
          somare(1,af2) = min ( n1 , n3 )
          somare(2,af2) = max ( n1 , n3 )
          somare(1,af3) = min ( n1 , n2 )
          somare(2,af3) = max ( n1 , n2 )
c
c 1.4.3. ==> leur famille
c
cgn      write(ulsort,90002) 'famtri(letria)',famtri(letria)
cgn      write(ulsort,90002) 'avec cfatri',
cgn     >(cfatri(iaux,famtri(letria)),iaux=1,nctftr)
cgn      write(ulsort,90002) '==> famare', cfatri(cofafa,famtri(letria))
          iaux = cfatri(cofafa,famtri(letria))
          famare(af1) = iaux
          famare(af2) = iaux
          famare(af3) = iaux
c
c 1.4.4. ==> la parente
c
          hetare(af1) = 50
          hetare(af2) = 50
          hetare(af3) = 50
          merare(af1) = 0
          merare(af2) = 0
          merare(af3) = 0
          filare(af1) = 0
          filare(af2) = 0
          filare(af3) = 0
c
c 1.5. ==> creation des 4 triangles fils
c
c         triangle central : nf
c
          nf = indtri + 1
          aretri(nf,1) = af1
          aretri(nf,2) = af2
          aretri(nf,3) = af3
c
c         triangle : nf + 1
c
          nf1 = nf + 1
          aretri(nf1,1) = af1
          aretri(nf1,2) = as1n2
          aretri(nf1,3) = as1n3
c
c         triangle : nf + 2
c
          nf2 = nf + 2
          aretri(nf2,1) = as2n1
          aretri(nf2,2) = af2
          aretri(nf2,3) = as2n3
c
c         triangle : nf + 3
c
          nf3 = nf + 3
          aretri(nf3,1) = as3n1
          aretri(nf3,2) = as3n2
          aretri(nf3,3) = af3
c
          indtri = nf + 3
c
c 1.6. ==> mise a jour de la famille des 4 triangles fils
c
          fammer = famtri(letria)
          famtri(nf)  = fammer
          famtri(nf1) = fammer
          famtri(nf2) = fammer
          famtri(nf3) = fammer
c
          hettri(nf)  = 50
          hettri(nf1) = 50
          hettri(nf2) = 50
          hettri(nf3) = 50
          filtri(nf)  = 0
          filtri(nf1) = 0
          filtri(nf2) = 0
          filtri(nf3) = 0
          pertri(nf)  = letria
          pertri(nf1) = letria
          pertri(nf2) = letria
          pertri(nf3) = letria
          niv = nivtri(letria) + 1
          nivtri(nf)  = niv
          nivtri(nf1) = niv
          nivtri(nf2) = niv
          nivtri(nf3) = niv
c
c 1.7. ==> mise a jour du pere et du grand-pere eventuel
c Remarque : si on est parti d'un macro-maillage non conforme,
c            certains triangles ont des peres adoptifs de numero
c            negatif. Il ne faut pas changer leur etat
c            Le cas des peres negatif parce que quadrangle de conformite
c            n'existe plus a ce stade : ces triangles ont ete detruits
c            en amont
c
          filtri(letria) = nf
          hettri(letria) = hettri(letria) + 4
          lepere = pertri(letria)
          if ( lepere.gt.0 ) then
            etat = hettri(lepere)
            hettri(lepere) = etat - mod(etat,10) + 9
          endif
c
        endif
c
  100 continue
cgn      print *,'indtri',indtri
cgn      print *,'indare',indare
c
c====
c 2. la fin
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
