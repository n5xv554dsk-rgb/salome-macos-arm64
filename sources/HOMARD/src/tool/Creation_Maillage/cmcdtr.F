      subroutine cmcdtr ( indare, indtri, decfac,
     >                    hetare, somare,
     >                    filare, merare, famare,
     >                    hettri, aretri,
     >                    filtri, pertri, famtri,
     >                    nivtri,
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
c    Creation du Maillage - Conformite - Decoupage des TRiangles
c    -           -          -            -             --
c ______________________________________________________________________
c
c but : decoupage des triangles en 2 pour mise en conformite du maillage
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . indare . es  . 1      . indice de la derniere arete creee          .
c . indtri . es  . 1      . indice du dernier triangle cree            .
c . decfac . es  . -nbquto. decision sur les faces (quad. + tri.)      .
c .        .     . :nbtrto.                                            .
c . hetare . es  . nouvar . historique de l'etat des aretes            .
c . somare . es  .2*nouvar. numeros des extremites d'arete             .
c . filare . es  . nouvar . premiere fille des aretes                  .
c . merare . es  . nouvar . mere des aretes                            .
c . famare . es  . nouvar . caracteristiques des aretes                .
c . hettri . es  . nouvtr . historique de l'etat des triangles         .
c . aretri . es  .nouvtr*3. numeros des 3 aretes des triangles         .
c . filtri . es  . nouvtr . premier fils des triangles                 .
c . pertri . es  . nouvtr . pere des triangles                         .
c . famtri . es  . nouvtr . famille des triangles                      .
c . nivtri . es  . nouvtr . niveau des triangles                       .
c . cfatri . e   . nctftr*. codes des familles des triangles           .
c .        .     . nbftri .   1 : famille MED                          .
c .        .     .        .   2 : type de triangle                     .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
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
      parameter ( nompro = 'CMCDTR' )
c
#include "nblang.h"
#include "cofatq.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "demitr.h"
#include "nouvnb.h"
#include "dicfen.h"
#include "nbfami.h"
c
c 0.3. ==> arguments
c
      integer indare, indtri
      integer decfac(-permqu:permtr)
      integer hetare(nouvar), somare(2,nouvar)
      integer filare(nouvar), merare(nouvar), famare(nouvar)
      integer hettri(nouvtr), aretri(nouvtr,3)
      integer filtri(nouvtr), pertri(nouvtr), famtri(nouvtr)
      integer nivtri(nouvtr)
      integer cfatri(nctftr,nbftri)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer letria
      integer s1, s2, s3
      integer as1s2, as1s3, as2s3, arinte, nf1, nf2, niv
      integer as1n2, as1n3, as2n1, as2n3, as3n1, as3n2
#ifdef _DEBUG_HOMARD_
      integer glop
#endif
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
      texte(1,5) ='(''triangle numero'',i10,'' sont incoherentes :'')'
      texte(1,6) ='(''Arete'',i2,'' :'',i10,'' et historique :'',i10)'
      texte(1,10) ='(i10,'' problemes ...'')'
c
      texte(2,4) ='(''Decisions for the edges of the'')'
      texte(2,5) ='(''triangle #'',i10,''do not match:'')'
      texte(2,6) ='(''Edge #'',i2,'':'',i10,'' state:'',i10)'
      texte(2,10) ='(i10,'' problems ...'')'
c
#include "impr03.h"
c
      codret = 0
c
c====
c 2. decoupage en 2 des triangles de decision 2
c====
c
      do 200 , letria = 1 , permtr
#ifdef _DEBUG_HOMARD_
        if ( letria.eq.830 ) then
          glop = 1
        else
          glop = 0
        endif
#endif
c
#ifdef _DEBUG_HOMARD_
        if ( glop .eq. 1 ) then
          write (ulsort,*) '. Triangle ', letria,
     >                     ', de decision ',decfac(letria),
     >                     ', d''etat ',hettri(letria)
          do 222 , iaux =1,3
          write (ulsort,*) '. Arete ', aretri(letria,iaux),
     >                     ', d''etat ',hetare(aretri(letria,iaux))
  222     continue
        endif
#endif
        if ( decfac(letria).eq.2 ) then
cgn             write(ulsort,*) ' '
cgn           write(ulsort,*) 'letria =',letria, nompro
c
c 2.1. ==> determination des numeros d'aretes
c
          as2s3 = aretri(letria,1)
          as1s3 = aretri(letria,2)
          as1s2 = aretri(letria,3)
c
c 2.2. ==> determination des sommets du triangle
c
          call utsotr ( somare, as2s3, as1s3, as1s2, s3, s1, s2 )
c
c 2.3. ==> decoupage du triangle en fonction de l'arete coupee
c          la determination des aretes filles est celle de utaftr
c
          indtri = indtri + 1
c
          if ( mod(hetare(as1s2),10).eq.2 ) then
c
c 2.3.1.    l'arete numero 3 du triplet est coupee
c
            iaux = filare(as1s2)
            if ( somare(1,iaux).eq.s1 ) then
              as1n3 = iaux
              as2n3 = iaux + 1
            else
              as1n3 = iaux + 1
              as2n3 = iaux
            endif
cgn      write(1,30000) 'as1n3', as1n3, somare(1,as1n3), somare(2,as1n3)
cgn      write(1,30000) 'as2n3', as2n3, somare(1,as2n3), somare(2,as2n3)
30000 format('arete ',a5,' :',i3,' de',i3,' a',i3)
c
c 2.3.1.1.  creation de l'arete interne
c
            arinte = indare + 1
            indare = arinte
            somare(1,arinte) = s3
            somare(2,arinte) = somare(2,as1n3)
c
c 2.3.1.2.  creation de l'un des deux triangles fils
c
            nf1 = indtri + nutrde(3,2)
            aretri(nf1,1) = arinte
            aretri(nf1,2) = as1s3
            aretri(nf1,3) = as1n3
c
c 2.3.1.3.  creation de l'autre des deux triangles fils
c
            nf2 = indtri + nutrde(3,1)
            aretri(nf2,1) = as2s3
            aretri(nf2,2) = arinte
            aretri(nf2,3) = as2n3
c
            hettri(letria) = hettri(letria) + 3
c
          elseif ( mod(hetare(as1s3),10).eq.2 ) then
c
c 2.3.2.    l'arete numero 2 du triplet est coupee
c
            iaux = filare(as1s3)
            if ( somare(1,iaux).eq.s1 ) then
              as1n2 = iaux
              as3n2 = iaux + 1
            else
              as1n2 = iaux + 1
              as3n2 = iaux
            endif
c
c 2.3.2.1.  creation de l'arete interne
c
            arinte = indare + 1
            indare = arinte
            somare(1,arinte) = s2
            somare(2,arinte) = somare(2,as1n2)
c
c 2.3.2.2.  creation de l'un des deux triangles fils
c
            nf1 = indtri + nutrde(2,1)
            aretri(nf1,1) = as2s3
            aretri(nf1,2) = as3n2
            aretri(nf1,3) = arinte
c
c 2.3.2.3.  creation de l'autre des deux triangles fils
c
            nf2 = indtri + nutrde(2,3)
            aretri(nf2,1) = arinte
            aretri(nf2,2) = as1n2
            aretri(nf2,3) = as1s2
c
            hettri(letria) = hettri(letria) + 2
c
          elseif ( mod(hetare(as2s3),10).eq.2 ) then
c
c 2.3.3.    l'arete numero 1 du triplet est coupee
c
            iaux = filare(as2s3)
            if ( somare(1,iaux).eq.s2 ) then
              as2n1 = iaux
              as3n1 = iaux + 1
            else
              as2n1 = iaux + 1
              as3n1 = iaux
            endif
c
c 2.3.3.1.  creation de l'arete interne
c
            arinte = indare + 1
            indare = arinte
            somare(1,arinte) = s1
            somare(2,arinte) = somare(2,as2n1)
c
c 2.3.3.2.  creation de l'un des deux triangles fils
c
            nf1 = indtri + nutrde(1,2)
            aretri(nf1,1) = as3n1
            aretri(nf1,2) = as1s3
            aretri(nf1,3) = arinte
c
c 2.3.3.3.  creation de l'autre des deux triangles fils
c
            nf2 = indtri + nutrde(1,3)
            aretri(nf2,1) = as2n1
            aretri(nf2,2) = arinte
            aretri(nf2,3) = as1s2
c
            hettri(letria) = hettri(letria) + 1
c
          else
c
            write (ulsort,texte(langue,4))
            write (ulsort,texte(langue,5)) letria
            write (ulsort,texte(langue,6)) 1, as1s2, hetare(as1s2)
            write (ulsort,texte(langue,6)) 2, as1s3, hetare(as1s3)
            write (ulsort,texte(langue,6)) 3, as2s3, hetare(as2s3)
c
            codret = codret + 1
c
          endif
c
c 2.4. ==> mise a jour des autres proprietes de la nouvelle arete
c
          jaux = cfatri(cofafa,famtri(letria))
          famare(arinte) = jaux
          hetare(arinte) = 50
          merare(arinte) = 0
          filare(arinte) = 0
c
c 2.5. ==> mise a jour des autres proprietes des deux triangles fils
c
          famtri(nf1)  = famtri(letria)
          famtri(nf2)  = famtri(letria)
          hettri(nf1) = 50
          hettri(nf2) = 50
          filtri(nf1) = 0
          filtri(nf2) = 0
          pertri(nf1) = letria
          pertri(nf2) = letria
          niv = nivtri(letria) + 1
          nivtri(nf1) = niv
          nivtri(nf2) = niv
c
c 2.6. ==> mise a jour du triangle pere
c
          filtri(letria) = indtri
          indtri = indtri + 1
c
        endif
c
  200 continue
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
      write (ulsort,texte(langue,10)) codret
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
