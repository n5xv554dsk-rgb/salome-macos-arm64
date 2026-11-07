      subroutine infoqu ( choix, lequad,
     >                    arequa, hetqua, volqua, pypequ,
     >                    nivqua, filqua, perqua, ninqua,
     >                    famqua,
     >                    nquaho, nquaca, nquacs,
     >                    quahom,
     >                    somare, np2are, hetare, posifa, facare,
     >                    coonoe,
     >                    hettri, nivtri, ntrica,
     >                    hetpyr, hethex, hetpen,
     >                    extrus, hexqua, nhenca,
     >                    nbpafo, nopafo,
     >                    ulsost,
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
c   INFOrmation : QUadrangle
c   ----          --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . choix  . e   .  ch2   . choix                                      .
c . lequad . e   .   1    . numero du quadrangle a analyser            .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . volqua . e   .nbquto*2. numeros des 2 volumes par quadrangle       .
c .        .     .        . volqua(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : hexaedre j                           .
c .        .     .        . j<0 : pyramide/pentaedre dans pypequ(1/2,j).
c . pypequ . 2   .2*lgpype. pypequ(1,j) = numero de la pyramide voisine.
c .        .     .        . du quadrangle k tel que volqua(k,1/2) = -j .
c .        .     .        . pypequ(2,j) = numero du pentaedre voisin   .
c .        .     .        . du quadrangle k tel que volqua(k,1/2) = -j .
c . nivqua . e   . nbquto . niveau des quadrangles                     .
c . filqua . e   . nbquto . premier fils des quadrangles               .
c . perqua . e   . nbquto . pere des quadrangles                       .
c . ninqua . e   . nbquto . noeud interne au quadrangle                .
c . famqua . e   . nbquto . famille des quadrangles                    .
c . nquaho . e   . requac . numero des quadrangles dans HOMARD         .
c . nquaca . e   .   *    . nro des quad. dans le calcul               .
c . nquacs . e   .   *    . nro des quad. du calcul pour la solution   .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . np2are . e   . nbarto . numero du noeud p2 milieu de l'arete       .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . posifa . e   . nbarto . pointeur sur tableau facare                .
c . facare . e   . nbfaar . liste des faces contenant une arete        .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . quahom . e   . nbquto . ensemble des quadrangles homologues        .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . nivtri . e   . nbtrto . niveau dans le raffinement/deraffinement   .
c . ntrica . e   .   *    . nro des triangles dans le calcul           .
c . hetpyr . e   . nbpyto . historique de l'etat des pyramides         .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . hetpen . e   . nbpeto . historique de l'etat des pentaedres        .
c . extrus . e   .    1   . prise en compte d'extrusion                .
c . hexqua . e   . nbquto . hexaedre sur un quadrangle de la face avant.
c . nhenca . e   .   *    . numero des hexaedres dans le calcul        .
c . nbpafo . e   .   1    . nombre de paquets de fonctions             .
c . nopafo . e   . nbpafo . nom des objets qui contiennent la          .
c .        .     .        . description de chaque paquet de fonctions  .
c . ulsost . e   .   1    . unite logique de la sortie standard        .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . non nul : probleme                         .
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
      parameter ( nompro = 'INFOQU' )
c
      integer langst
      parameter ( langst = 1 )
c
#include "nblang.h"
#include "consts.h"
#include "tbdim0.h"
#include "meddc0.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "inmess.h"
#include "impr02.h"
#include "indefi.h"
c
#include "nomber.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombpy.h"
#include "nombhe.h"
#include "nombpe.h"
#include "envada.h"
#include "envca1.h"
c
c 0.3. ==> arguments
c
      character*2 choix
c
      integer lequad
c
      integer hetqua(nbquto), arequa(nbquto,4)
      integer volqua(2,nbquto), pypequ(2,*)
      integer nivqua(nbquto), filqua(nbquto), perqua(nbquto)
      integer ninqua(nbquto)
      integer famqua(nbquto)
      integer nquaho(requac), nquaca(*), nquacs(*)
      integer quahom(nbquto)
      integer somare(2,nbarto), np2are(nbarto), hetare(nbarto)
      integer posifa(0:nbarto), facare(nbfaar)
      integer hettri(nbtrto), nivtri(nbtrto), ntrica(*)
      integer hetpyr(nbpyto)
      integer hethex(nbheto)
      integer hetpen(nbpeto)
      integer hexqua(nbquto), nhenca(*)
      integer nbpafo
c
      double precision coonoe(nbnoto,sdim)
c
      character*8 nopafo(*)
c
      logical extrus
c
      integer ulsost
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer nbar, nbso
      parameter ( nbar = 4, nbso = 4 )
c
      integer iaux, jaux, kaux, laux
      integer tbaux1(1), tbaux2(1)
      integer kdeb, kfin
      integer numcal
      integer etat00, etat01, etatpe
      integer lafac1
      integer a1, a2, a3, a4
      integer sa1a2, sa2a3, sa3a4, sa4a1
      integer nquniv, nquaut, ntrniv, ntraut
      integer niveau, freain
      integer nbfiqu, lifiqu(4)
      integer nbfitr, lifitr(4)
      integer hettet(1)
      integer volint(4,0:1)
      integer uldeb, ulfin, ulpas, ulecr
c
      integer trav1a(tbdim), trav2a(tbdim)
c
      character*40 taux40
c
      double precision vn(4)
      double precision surf, qualit, diamet, torsio
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
#include "fractc.h"
c ______________________________________________________________________
c
c====
c 1. initialisation
c====
c
#include "impr01.h"
#include "infoen.h"
#include "tbdim1.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "impr03.h"
c
      codret = 0
c
      uldeb = min(ulsost,ulsort)
      ulfin = max(ulsost,ulsort)
      ulpas = max ( 1 , ulfin-uldeb )
c
c====
c 2. numero du quadrangle dans HOMARD
c====
c
      if ( choix.eq.'QU' ) then
        iaux = lequad
        if ( lequad.gt.0 .and. lequad.le.requac ) then
          lequad = nquaho(iaux)
        else
          lequad = 0
        endif
      endif
c
c====
c 3. reponses
c====
c
      do 30 , ulecr = uldeb , ulfin, ulpas
c
      write (ulecr,40000)
c
c 3.1. ==> numero de quadrangle impossible
c
      if ( lequad.le.0 .or. lequad.gt.nbquto ) then
c
        if ( choix.eq.'QU' ) then
          write (ulecr,40010) iaux
        else
          write (ulecr,40020) lequad
        endif
        write (ulecr,40030)
c
c 3.2. ==> numero de quadrangle correct
c
      else
c
        if ( extrus ) then
          numcal = nhenca(hexqua(lequad))
          write (ulecr,40020) lequad
          write (ulecr,40050) numcal
        else
          if ( requac.ne.0 ) then
            numcal = nquaca(lequad)
            if ( numcal.ne.0 ) then
              write (ulecr,40020) lequad
              write (ulecr,40010) numcal
            else
              write (ulecr,40020) lequad
              write (ulecr,40040)
            endif
          else
            write (ulecr,40020) lequad
            write (ulecr,40040)
          endif
        endif
c
c 3.2.1. ==> Niveau
c
        if ( lequad.le.nbquma) then
          niveau = 0
          write (ulecr,41000)
        else
          niveau = nivqua(lequad)
          if ( lequad.le.nbqupe) then
            write (ulecr,41010) niveau
          else
            write (ulecr,41011) niveau-1
          endif
        endif
c
c 3.2.2. ==> caracteristiques
c
        write (ulecr,42000) famqua(lequad)
c
c 3.2.3. ==> ses aretes et ses noeuds
c
c 3.2.3.1. ==> ses aretes
c
        a1 = arequa(lequad,1)
        a2 = arequa(lequad,2)
        a3 = arequa(lequad,3)
        a4 = arequa(lequad,4)
c
        call utsoqu ( somare, a1, a2, a3, a4,
     >                sa1a2, sa2a3, sa3a4, sa4a1 )
c
        write (ulecr,43030)
        taux40 = textar(mod(hetare(a1),10))
        write (ulecr,43031) a1, taux40
        taux40 = textar(mod(hetare(a2),10))
        write (ulecr,43031) a2, taux40
        taux40 = textar(mod(hetare(a3),10))
        write (ulecr,43031) a3, taux40
        taux40 = textar(mod(hetare(a4),10))
        write (ulecr,43031) a4, taux40
c
c 3.2.3.2. ==> ses noeuds
c
        write (ulecr,43040)
        write (ulecr,50004) sa4a1, sa1a2, sa2a3, sa3a4
c
c 3.2.3.3. ==> les noeuds au milieu des aretes
c
        if ( degre.eq.2 ) then
          write (ulecr,43050)
          write (ulecr,50004) np2are(a1), np2are(a2),
     >                         np2are(a3), np2are(a4)
        endif
c
c 3.2.3.4. ==> le noeud central
c
        if ( mod(mailet,3).eq.0 ) then
          write (ulecr,43060) ninqua(lequad)
        endif
c
c 3.2.4. ==> etat
c
        etat01 = mod(hetqua(lequad),100)
        etat00 = (hetqua(lequad)-etat01) / 100
c
        taux40 = textqu(etat01)
        write (ulecr,44010)
        write (ulecr,40001) taux40
        if ( nbiter.ge.1 ) then
          taux40 = textqu(etat00)
          write (ulecr,44020)
          write (ulecr,40001) taux40
        endif
c
c 3.2.5. ==> la parente
c 3.2.5.1. ==> les fils
c
        nbfiqu = 0
        nbfitr = 0
c
        if ( etat01.ne.0 ) then
c
          if ( etat01.eq.4 .or. etat01.eq.99 .or.
     >         etat01.eq.21 .or. etat01.eq.22 .or.
     >         ( etat01.ge.41 .and. etat01.le.44 ) ) then
            write (ulecr,45010) mess14(langst,3,4)
            if ( etat01.eq.21 .or. etat01.eq.22 ) then
              iaux = 1
            elseif ( etat01.ge.41 .and. etat01.le.44 ) then
              iaux = 2
            else
              iaux = 3
            endif
            freain = filqua(lequad)
            do 3251 , jaux = 0 , iaux
              kaux = freain+jaux
              if ( requac.ne.0 ) then
                if ( nquaca(kaux).eq.0 ) then
                  write (ulecr,45070) kaux
                else
                  write (ulecr,45080) kaux, nquaca(kaux)
                endif
              else
                write (ulecr,45070) kaux
              endif
              nbfiqu = nbfiqu + 1
              lifiqu(nbfiqu) = kaux
 3251       continue
c
         elseif ( etat01.ge.31 .and. etat01.le.34 ) then
c
            write (ulecr,45010) mess14(langst,3,2)
            iaux = 2
            freain = -filqua(lequad)
            do 3252 , jaux = 0 , iaux
              kaux = freain+jaux
              if ( retrac.ne.0 ) then
                if ( ntrica(kaux).eq.0 ) then
                  write (ulecr,45070) kaux
                else
                  write (ulecr,45080) kaux, ntrica(kaux)
                endif
              else
                write (ulecr,45070) kaux
              endif
              nbfitr = nbfitr + 1
              lifitr(nbfitr) = kaux
 3252       continue
          endif
c
        endif
c
c 3.2.5.2 ==> pere
c
        if ( perqua(lequad).gt.0 ) then
          write (ulecr,45040) mess14(langst,1,4), perqua(lequad)
          etatpe = mod(hetqua(perqua(lequad)),100)
          if ( etatpe.eq.21 .or. etatpe.eq.22 ) then
            iaux = 1
          elseif ( etatpe.ge.41 .and. etatpe.le.44 ) then
            iaux = 2
          else
            iaux = 3
          endif
          freain = filqua(perqua(lequad))
          if ( iaux.eq.1 ) then
            write (ulecr,45051) mess14(langst,1,4)
          else
            write (ulecr,45050) mess14(langst,3,4)
          endif
          do 3253 , jaux = 0 , iaux
            kaux = freain+jaux
            if ( kaux.ne.lequad) then
              if ( requac.ne.0 ) then
                if ( nquaca(kaux).eq.0 ) then
                  write (ulecr,45070) kaux
                else
                  write (ulecr,45080) kaux, nquaca(kaux)
                endif
              else
                write (ulecr,45070) kaux
              endif
            endif
 3253     continue
        elseif ( perqua(lequad).lt.0 ) then
          write (ulecr,45091)
#ifdef _DEBUG_HOMARD_
          write (ulecr,45092) perqua(lequad)
#endif
        endif
c
c 3.2.6. ==> les faces voisines
c
        trav1a(1) = a1
        trav1a(2) = a2
        trav1a(3) = a3
        trav1a(4) = a4
c
c 3.2.6.1. ==> reperage ; attention a ne pas compter les fils !
c
        nquniv = 0
        ntrniv = 0
        nquaut = 0
        ntraut = 0
        do 3261 , iaux = 1 , nbar
          kdeb = posifa(trav1a(iaux)-1)+1
          kfin = posifa(trav1a(iaux))
          do 3262 , kaux = kdeb , kfin
            jaux = facare(kaux)
            if ( jaux.ne.perqua(lequad) ) then
              if ( jaux.gt.0 ) then
                if ( nivtri(jaux).eq.niveau ) then
                  ntrniv = ntrniv + 1
#include "tbdim4.h"
                  trav2a(ntrniv+nquniv) = jaux
                else
                  do 32621 , laux = 1 , nbfitr
                    if ( jaux.eq.lifitr(laux) ) then
                      goto 3262
                    endif
32621             continue
                  ntraut = ntraut + 1
#include "tbdim5.h"
                  trav1a(nbar+ntraut+nquaut) = jaux
                endif
              else
                if ( -jaux.ne.lequad ) then
                  if ( nivqua(-jaux).eq.niveau ) then
                    nquniv = nquniv + 1
#include "tbdim4.h"
                    trav2a(ntrniv+nquniv) = jaux
                  else
                    do 32622 , laux = 1 , nbfiqu
                      if ( jaux.eq.lifiqu(laux) ) then
                        goto 3262
                      endif
32622               continue
                    nquaut = nquaut + 1
#include "tbdim5.h"
                    trav1a(nbar+ntraut+nquaut) = jaux
                  endif
                endif
              endif
            endif
 3262     continue
 3261   continue
c
c 3.2.6.2. ==> quadrangles de meme niveau
c
        if ( nquniv.ne.0 ) then
          write (ulecr,46110)
          do 3263 , iaux = 1 , ntrniv+nquniv
            lafac1 = trav2a(iaux)
            if ( lafac1.lt.0 ) then
              taux40 = textqu(mod(hetqua(-lafac1),100))
              write (ulecr,46000) -lafac1, taux40
            endif
 3263     continue
        endif
c
c 3.2.6.3. ==> triangles de meme niveau
c
        if ( ntrniv.ne.0 ) then
          write (ulecr,46120)
          do 3264 , iaux = 1 , ntrniv+nquniv
            lafac1 = trav2a(iaux)
            if ( lafac1.gt.0 ) then
              taux40 = texttr(mod(hettri(lafac1),10))
              write (ulecr,46000) lafac1, taux40
            endif
 3264     continue
        endif
c
c 3.2.6.4. ==> quadrangles des autres niveaux
c
        if ( nquaut.ne.0 ) then
          write (ulecr,46130)
          do 3265 , iaux = 1 , ntraut+nquaut
            lafac1 = trav1a(nbar+iaux)
            if ( lafac1.lt.0 ) then
              taux40 = textqu(mod(hetqua(-lafac1),100))
              write (ulecr,46000) -lafac1, taux40
            endif
 3265     continue
        endif
c
c 3.2.6.5. ==> triangles des autres niveaux
c
        if ( ntraut.ne.0 ) then
          write (ulecr,46140)
          do 3266 , iaux = 1 , ntraut+nquaut
            lafac1 = trav1a(nbar+iaux)
            if ( lafac1.gt.0 ) then
              taux40 = textqu(mod(hettri(lafac1),10))
              write (ulecr,46000) lafac1, taux40
            endif
 3266     continue
        endif
c
c 3.2.7. ==> les voisins volumiques
c            Remarque : on met une valeur bidon au tableau hettet pour
c                       ne pas avoir de message avec ftnchek
c
        if ( nbheto.ne.0 .or. nbpyto.ne.0 .or. nbpeto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFOVO', nompro
#endif
          volint(1,0) = 0
          volint(2,0) = 0
          volint(3,0) = 0
          volint(4,0) = 0
          trav2a(1) = -lequad
          iaux = 0
          hettet(1) = iindef
          kaux = ulecr
          call infovo ( iaux, 1, 1, volint,
     >                  tbaux1, tbaux2,
     >                  volqua, pypequ,
     >                  hettet, hetpyr, hethex, hetpen,
     >                  trav1a, trav2a,
     >                  kaux,
     >                  ulsort, langue, codret )
c
        endif
c
c 3.2.8. ==> les homologues
c
        if ( homolo.ne.0 .and. sdim.eq.3 ) then
c
          if ( quahom(lequad).ne.0 ) then
            if ( quahom(lequad).ge.0 ) then
              iaux = 2
            else
              iaux = 1
            endif
            write (ulecr,48020) iaux
            write (ulecr,48024) abs(quahom(lequad))
          endif
c
        endif
c
c 3.2.9. ==> le centre de gravite
c
        do 329 , iaux = 1 , sdim
          vn(iaux) = unsqu * ( coonoe(sa1a2,iaux) +
     >                         coonoe(sa2a3,iaux) +
     >                         coonoe(sa3a4,iaux) +
     >                         coonoe(sa4a1,iaux) )
  329   continue
c
        if ( sdim.eq.2 ) then
          write (ulecr,49002) (vn(iaux), iaux = 1 , sdim)
        else
          write (ulecr,49003) (vn(iaux), iaux = 1 , sdim)
        endif
c
c 3.2.10. ==> normale
c
        if ( sdim.eq.3 ) then
c
          call utnqua ( lequad, vn,
     >                  nbnoto, nbquto,
     >                  coonoe, somare, arequa )
c
          write (ulecr,49004) (vn(iaux), iaux = 1 , sdim)
c
        endif
c
c 3.2.11. ==> surface, qualite, diametre et torsion
c
        call utqqua ( lequad, qualit, surf,
     >                coonoe, somare, arequa )
c
        write (ulecr,49020) surf
c
        write (ulecr,49040) qualit
c
        call utdqua ( lequad, diamet,
     >                coonoe, somare, arequa )
c
        write (ulecr,49050) diamet
c
        if ( sdim.eq.3 ) then
c
          call uttoqu ( sa1a2, sa2a3, sa3a4, sa4a1, coonoe, torsio )
c
          write (ulecr,49060) torsio
c
        endif
c
c 3.2.12. ==> les valeurs des fonctions
c
        if ( nbpafo.ne.0 .and. numcal.ne.0 ) then
c
          if ( degre.eq.1 ) then
            iaux = edqua4
          else
            iaux = edqua8
          endif
          jaux = nquacs(numcal)
          kaux = ulecr
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFOPF', nompro
#endif
          call infopf ( nbpafo, nopafo,
     >                    iaux,   jaux,
     >                    kaux,
     >                  ulsort, langue, codret )
c
        endif
c
      endif
c
      write (ulecr,40000)
c
   30 continue
c
c===
c 4. formats
c===
c
40020 format(
     >  '* Quadrangle numero :',i10,   ' dans HOMARD                 *')
40050 format(
     > '* Face de l''hexaedre extrude numero',i10,   ' dans le calcul*')
c
41000 format(
     >  '* . C''est un quadrangle du maillage initial.                ',
     >  '*')
c
45091 format(
     >  '* . C''est un quadrangle bordant une non-conformite initiale ',
     >  '*')
c
46110 format(
     >  '* . Il a des quadrangles voisins de meme niveau :           *')
46120 format(
     >  '* . Il a des triangles voisins de meme niveau :             *')
46130 format(
     >  '* . Il a des quadrangles voisins d''autre niveau :           ',
     >  '*')
46140 format(
     >  '* . Il a des triangles voisins d''autre niveau :             ',
     >  '*')
c
c====
c 5. La fin
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
