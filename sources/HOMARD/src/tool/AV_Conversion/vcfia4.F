      subroutine vcfia4 ( diammi,
     >                    typenh, nbento, nctfen, nbfenm,
     >                    fament, cfaent,
     >                    coonoe, somare,
     >                    aretri, arequa,
     >                    tritet, cotrte, aretet,
     >                    quahex, coquhe, arehex,
     >                    facpyr, cofapy, arepyr,
     >                    facpen, cofape, arepen,
     >                    volfac,
     >                    tabmem,
     >                    tabmea, tabmet, tabmeq,
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
c    aVant adaptation - FIltrage de l'Adaptation - phase 4
c     -                 --            -                  -
c    On ne s'interesse qu'aux mailles :
c    . qui sont des elements de calcul
c    . qui sont actives
c    . qui ne sont pas des mailles de bord
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . diammi . e   .   1    . diametre minimal voulu                     .
c . typenh . e   .   1    . code des entites au sens homard            .
c . nbento . e   .   1    . nombre d'entites                           .
c . nctfen . e   .    1   . nombre total de caracteristiques           .
c . nbfenm . e   .    1   . nombre maximum de familles                 .
c . fament . e   . nbento . famille des entites                        .
c . cfaent . e   . nctfen*. codes des familles des entites             .
c .        .     . nbfent .                                            .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . e   .nbtecf*4. code des 4 triangles des tetraedres        .
c . aretet . e   .nbteca*6. numeros des 6 aretes des tetraedres        .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nbhecf*6. codes des 6 quadrangles des hexaedres      .
c . arehex . e   .nbheca12. numeros des 12 aretes des hexaedres        .
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . cofapy . e   .nbpycf*5. codes des faces des pyramides              .
c . arepyr . e   .nbpyca*8. numeros des 8 aretes des pyramides         .
c . facpen . e   .nbpecf*5. numeros des 5 faces des pentaedres         .
c . cofape . e   .nbpecf*5. code des 5 faces des pentaedres            .
c . arepen . e   .nbpeca*9. numeros des 9 aretes des pentaedres        .
c . cofape . e   .nbpecf*5. codes des faces des pentaedres             .
c . volfac . e   .2*nbfato. numeros des 2 volumes par face)             .
c .        .     .        . volfac(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : hexaedre/tetraedre j                 .
c .        .     .        . j<0 : pyramide/pentaedre dans pypefa(1/2,j).
c . tabmem .  s  . nbento . memorisation du filtrage                   .
c .        .     .        . Pour l'entite i :                          .
c .        .     .        .   0 : l'entite est retiree                 .
c .        .     .        .   1 : l'entite est gardee pour l'adaptation.
c . tabmea . e   . nbarto . memorisation du filtrage pour les aretes   .
c . tabmet . e   . nbtrto . memorisation du filtrage pour les triangles.
c . tabmeq . e   . nbquto . memorisation du filtrage pour les quads.   .
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
      parameter ( nompro = 'VCFIA4' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "envca1.h"
#include "coftex.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombpy.h"
#include "nombhe.h"
#include "nombpe.h"
c
#include "impr02.h"
c
c 0.3. ==> arguments
c
      double precision diammi
c
      integer typenh, nbento, nctfen, nbfenm
      integer cfaent(nctfen,nbfenm), fament(nbento)
      integer somare(2,nbarto)
      integer aretri(nbtrto,3)
      integer arequa(nbquto,4)
      integer tritet(nbtecf,4), cotrte(nbtecf,4), aretet(nbteca,6)
      integer quahex(nbhecf,6), coquhe(nbhecf,6), arehex(nbheca,12)
      integer facpyr(nbpycf,5), cofapy(nbpycf,5), arepyr(nbpyca,8)
      integer facpen(nbpecf,5), cofape(nbpecf,5), arepen(nbpeca,9)
      integer volfac(2,*)
      integer tabmem(nbento)
      integer tabmea(nbarto), tabmet(nbtrto), tabmeq(nbquto)
c
      double precision coonoe(nbnoto,sdim)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer nument
      integer listar(12)
c
      double precision daux, vn(3)
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
      texte(1,4) = '(''Prise en compte du filtrage sur les '',i10,1x,a)'
      texte(1,5) = '(''Diametre minimal :'',g15.6)'
c
      texte(2,4) = '(''Influence over the'',i10,1x,a)'
      texte(2,5) = '(''Minimal diameter:'',g15.6)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbento, mess14(langue,3,typenh)
      write (ulsort,texte(langue,5)) diammi
#endif
c
#include "impr03.h"
c
      codret = 0
c
c====
c 2. Reperage des entites soumises a adaptation
c    A priori, aucune entite n'est retiree
c====
c
      do 21 , iaux = 1 , nbento
c
        tabmem(iaux) = 0
c
   21 continue
c
c====
c 3. Prise en compte du diametre minimal selon le type de mailles
c    On ne s'interesse qu'aux mailles qui sont des elements de calcul
c    et qui sont actives
c====
c 3.1.==> Aretes, longueur minimale
c
      if ( typenh.eq.1 ) then
c
        do 31 , iaux = 1 , nbento
c
          if ( cfaent(cotyel,fament(iaux)).ne.0 ) then
c
            jaux = somare(1,iaux)
            kaux = somare(2,iaux)
            vn(1) = coonoe(kaux,1) - coonoe(jaux,1)
            vn(2) = coonoe(kaux,2) - coonoe(jaux,2)
            daux = sqrt ( vn(1)*vn(1) + vn(2)*vn(2) )
c
cgn            write(ulsort,*)'.. arete', iaux, daux
            if ( daux.le.diammi ) then
              tabmem(iaux) = 1
cgn            write(ulsort,*)'    .. pas glop'
            endif
c
          endif
c
   31   continue
c
c 3.2. ==> Triangles
c
      elseif ( typenh.eq.2 ) then
c
c 3.2.1. ==> En l'absence de mailles volumiques
c
        if ( nbteto.eq.0 .and. nbheto.eq.0 .and.
     >       nbpeto.eq.0 .and. nbpyto.eq.0 ) then
c
          do 321 , iaux = 1 , nbento
c
            if ( cfaent(cotyel,fament(iaux)).ne.0 ) then
c
              nument = iaux
              call utdtri ( nument, daux, coonoe, somare, aretri )
cgn            write(ulsort,*)'.. triangle', iaux, daux
c
              if ( daux.le.diammi ) then
                tabmem(iaux) = 1
                do 3211 , jaux = 1 , 3
                  tabmea(aretri(iaux,jaux)) = 1
 3211           continue
cgn            write(ulsort,*)'.... aretes', (aretri(iaux,jaux),jaux=1,3)
cgn            write(ulsort,*)'    .. pas glop'
              endif
c
            endif
c
  321     continue
c
c 3.2.2. ==> Avec au moins une maille volumique
c
        else
c
          do 322 , iaux = 1 , nbento
c
            if ( cfaent(cotyel,fament(iaux)).ne.0 ) then
c
            if ( volfac(1,iaux).eq.0 ) then
c
              nument = iaux
              call utdtri ( nument, daux, coonoe, somare, aretri )
cgn            write(ulsort,*)'.. triangle', iaux, daux
c
              if ( daux.le.diammi ) then
                tabmem(iaux) = 1
                do 3221 , jaux = 1 , 3
                  tabmea(aretri(iaux,jaux)) = 1
 3221           continue
              endif
c
            endif
c
            endif
c
  322     continue
c
        endif
c
c 3.3. ==> Tetraedres
c
      elseif ( typenh.eq.3 ) then
c
        do 33 , iaux = 1 , nbento
c
          if ( cfaent(cotyel,fament(iaux)).ne.0 ) then
c
            nument = iaux
            call utdtet ( nument, daux,
     >                    coonoe, somare, aretri,
     >                    tritet, cotrte, aretet )
cgn            write(ulsort,*)'.. tetraedre', iaux, daux
c
            if ( daux.le.diammi ) then
cgn            write(ulsort,*)'.... enregistrement pour tr =',
cgn     >(tritet(iaux,jaux), jaux = 1 , 4)
              tabmem(iaux) = 1
              if ( nument.le.nbtecf ) then
                do 331 , jaux = 1 , 4
                  tabmet(tritet(iaux,jaux)) = 1
  331           continue
                call utarte ( nument,
     >                        nbtrto, nbtecf,
     >                        aretri, tritet, cotrte,
     >                        listar )
              else
                do 332 , jaux = 1 , 6
                  listar(jaux) = aretet(nument-nbtecf,jaux)
  332           continue
              endif
              do 333 , jaux = 1 , 6
                tabmea(listar(jaux)) = 1
  333         continue
            endif
c
          endif
c
   33   continue
c
c 3.4. ==> Quadrangles
c
      elseif ( typenh.eq.4 ) then
c
c 3.4.1. ==> En l'absence de mailles volumiques
c
        if ( nbteto.eq.0 .and. nbheto.eq.0 .and.
     >       nbpeto.eq.0 .and. nbpyto.eq.0 ) then
c
          do 341 , iaux = 1 , nbento
c
            if ( cfaent(cotyel,fament(iaux)).ne.0 ) then
c
              nument = iaux
              call utdqua ( nument, daux, coonoe, somare, arequa )
c
cgn              write(ulsort,*)'.. quadrangle', iaux, daux
              if ( daux.le.diammi ) then
                tabmem(iaux) = 1
                do 3411 , jaux = 1 , 4
                  tabmea(arequa(iaux,jaux)) = 1
 3411           continue
              endif
c
            endif
c
  341     continue
c
c 3.4.2. ==> Avec au moins une maille volumique
c
        else
c
          do 342 , iaux = 1 , nbento
c
            if ( cfaent(cotyel,fament(iaux)).ne.0 ) then
c
            if ( volfac(1,iaux).eq.0 ) then
c
              nument = iaux
              call utdqua ( nument, daux, coonoe, somare, arequa )
cgn              write(ulsort,*)'.. quadrangle', iaux, daux
c
              if ( daux.le.diammi ) then
                tabmem(iaux) = 1
                do 3421 , jaux = 1 , 4
                  tabmea(arequa(iaux,jaux)) = 1
 3421           continue
              endif
c
            endif
c
            endif
c
  342     continue
c
        endif
c
c 3.5. ==> Pyramides
c
      elseif ( typenh.eq.5 ) then
c
        do 35 , iaux = 1 , nbento
c
          if ( cfaent(cotyel,fament(iaux)).ne.0 ) then
c
            nument = iaux
            call utdpyr ( nument, daux,
     >                    coonoe, somare, aretri,
     >                    facpyr, cofapy, arepyr )
cgn            write(ulsort,*)'.. pyramide', iaux, daux
c
            if ( daux.le.diammi ) then
              tabmem(iaux) = 1
              if ( nument.le.nbpycf ) then
                do 351 , jaux = 1 , 4
                  tabmet(facpyr(iaux,jaux)) = 1
  351           continue
                tabmeq(facpyr(iaux,5)) = 1
                call utarpy ( nument,
     >                        nbtrto, nbpycf,
     >                        aretri, facpyr, cofapy,
     >                        listar )
              else
                do 352 , jaux = 1 , 8
                  listar(jaux) = arepyr(nument-nbpycf,jaux)
  352          continue
              endif
              do 353 , jaux = 1 , 8
                tabmea(listar(jaux)) = 1
  353         continue
            endif
c
          endif
c
   35   continue
c
c 3.6. ==> Hexaedres
c
      elseif ( typenh.eq.6 ) then
c
        do 36 , iaux = 1 , nbento
c
          if ( cfaent(cotyel,fament(iaux)).ne.0 ) then
c
            nument = iaux
            call utdhex ( nument, daux,
     >                    coonoe, somare, arequa,
     >                    quahex, coquhe, arehex )
cgn            write(ulsort,*)'.. hexaedre', iaux, daux
c
            if ( daux.le.diammi ) then
              tabmem(iaux) = 1
              if ( nument.le.nbhecf ) then
                do 361 , jaux = 1 , 6
                  tabmeq(quahex(iaux,jaux)) = 1
  361           continue
                call utarhe ( nument,
     >                        nbquto, nbhecf,
     >                        arequa, quahex, coquhe,
     >                        listar )
              else
                do 362 , jaux = 1 , 12
                  listar(jaux) = arehex(nument-nbhecf,jaux)
  362           continue
              endif
              do 363 , jaux = 1 , 12
                tabmea(listar(jaux)) = 1
  363         continue
            endif
c
          endif
c
   36   continue
c
c 3.7. ==> Pentaedres
c
      elseif ( typenh.eq.7 ) then
c
        do 37 , iaux = 1 , nbento
c
          if ( cfaent(cotyel,fament(iaux)).ne.0 ) then
c
            nument = iaux
            call utdpen ( nument, daux,
     >                    coonoe, somare, arequa,
     >                    facpen, cofape, arepen )
cgn            write(ulsort,*)'.. pentaedre', iaux, daux
c
            if ( daux.le.diammi ) then
              tabmem(iaux) = 1
              if ( nument.le.nbpecf ) then
                do 3711 , jaux = 1 , 3
                  tabmeq(facpen(iaux,jaux)) = 1
 3711           continue
                do 3712 , jaux = 4 , 5
                  tabmet(facpen(iaux,jaux)) = 1
 3712           continue
                call utarpe ( nument,
     >                        nbquto, nbpeto,
     >                        arequa, facpen, cofape,
     >                        listar )
              else
                do 372 , jaux = 1 , 9
                  listar(jaux) = arepen(nument-nbpecf,jaux)
  372           continue
              endif
              do 373 , jaux = 1 , 9
                tabmea(listar(jaux)) = 1
  373         continue
            endif
c
          endif
c
   37   continue
c
      endif
c
c====
c 4. Sauvegarde du tableau pour les aretes, les triangles,
c    les quadrangles
c====
c
      if ( typenh.eq.1 ) then
c
        do 41 , iaux = 1 , nbarto
c
          tabmea(iaux) = tabmem(iaux)
c
   41   continue
c
      elseif ( typenh.eq.2 ) then
c
        do 42 , iaux = 1 , nbtrto
c
          tabmet(iaux) = tabmem(iaux)
c
   42   continue
c
      elseif ( typenh.eq.4 ) then
c
        do 43 , iaux = 1 , nbquto
c
          tabmeq(iaux) = tabmem(iaux)
c
   43   continue
c
      endif
c
c====
c 5. la fin
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
