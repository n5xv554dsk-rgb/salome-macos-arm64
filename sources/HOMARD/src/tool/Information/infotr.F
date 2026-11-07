      subroutine infotr ( choix, letria,
     >                    aretri, hettri, voltri, pypetr,
     >                    nivtri, filtri, pertri, nintri,
     >                    famtri,
     >                    ntriho, ntrica, ntrics,
     >                    homtri,
     >                    somare, np2are, hetare, posifa, facare,
     >                    coonoe,
     >                    hetqua, nivqua, filqua,
     >                    hettet, hetpyr, hetpen,
     >                    extrus, pentri, npenca,
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
c   INFOrmation : TRiangle
c   ----          --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . choix  . e   .  ch2   . choix                                      .
c . letria . e   .   1    . numero du triangle a analyser              .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . voltri . e   .2*nbtrto. numeros des 2 volumes par triangle         .
c .        .     .        . voltri(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : tetraedre j                          .
c .        .     .        . j<0 : pyramide/pentaedre dans pypetr(1/2,j).
c . pypetr . a   .2*lgpype. pypetr(1,j) = numero de la pyramide voisine.
c .        .     .        . du triangle k tel que voltri(1/2,k) = -j   .
c .        .     .        . pypetr(2,j) = numero du pentaedre voisin   .
c .        .     .        . du triangle k tel que voltri(1/2,k) = -j   .
c . nivtri . e   . nbtrto . niveau dans le raffinement/deraffinement   .
c . filtri . e   . nbtrto . premier fils des triangles                 .
c . pertri . e   . nbtrto . pere des triangles                         .
c . nintri . e   . nbtrto . noeud interne au triangle                  .
c . famtri . e   . nbtrto . famille des triangles                      .
c . ntriho . e   . retrac . numero des triangles dans HOMARD           .
c . ntrica . e   .   *    . nro des triangles dans le calcul           .
c . ntrics . e   .   *    . nro des triangles du calcul pour la solutio.
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . np2are . e   . nbarto . numero du noeud p2 milieu de l'arete       .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . posifa . e   . nbarto . pointeur sur tableau facare                .
c . facare . e   . nbfaar . liste des faces contenant une arete        .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . homtri .  s  . nbtrto . ensemble des triangles homologues          .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . nivqua . e   . nbquto . niveau des quadrangles                     .
c . filqua . e   . nbquto . premier fils des quadrangles               .
c . hettet . e   . nbteto . historique de l'etat des tetraedres        .
c . hetpyr . e   . nbpyto . historique de l'etat des pyramides         .
c . hetpen . e   . nbpeto . historique de l'etat des pentaedres        .
c . extrus . e   .    1   . prise en compte d'extrusion                .
c . pentri . e   . nbtrto . pentaedre sur un triangle de la face avant .
c . npenca . e   .   *    . numero des pentaedres dans le calcul       .
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
      parameter ( nompro = 'INFOTR' )
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
#include "nombte.h"
#include "nombpy.h"
#include "nombpe.h"
#include "envada.h"
#include "envca1.h"
c
c 0.3. ==> arguments
c
      character*2 choix
c
      integer letria
c
      integer hettri(nbtrto), aretri(nbtrto,3)
      integer voltri(2,nbtrto), pypetr(2,*)
      integer nivtri(nbtrto), filtri(nbtrto), pertri(nbtrto)
      integer nintri(nbtrto)
      integer famtri(nbtrto)
      integer ntriho(retrac), ntrica(*), ntrics(*)
      integer homtri(nbtrto)
      integer somare(2,nbarto), np2are(nbarto), hetare(nbarto)
      integer posifa(0:nbarto), facare(nbfaar)
      integer hetqua(nbquto), nivqua(nbquto), filqua(nbquto)
      integer hettet(nbteto)
      integer hetpyr(nbpyto)
      integer hetpen(nbpeto)
      integer pentri(nbtrto), npenca(*)
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
      parameter ( nbar = 3, nbso = 3 )
c
      integer iaux, jaux, kaux, laux
      integer tbaux1(1), tbaux2(1)
      integer kdeb, kfin
      integer numcal
      integer etat00, etat01, etatpe
      integer a1, a2, a3
      integer sa1a2, sa2a3, sa3a1
      integer lafac1
      integer nquniv, nquaut, ntrniv, ntraut
      integer niveau, freain
      integer nbfitr, lifitr(4)
      integer volint(4,0:1)
      integer uldeb, ulfin, ulpas, ulecr
      integer hethex(1)
c
      integer trav1a(tbdim), trav2a(tbdim)
c
      character*40 taux40
c
      double precision vn(3)
      double precision surf, qualit, diamet
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
#include "fractb.h"
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
c 2. numero du triangle dans HOMARD
c====
c
      if ( choix.eq.'TR' ) then
        iaux = letria
        if ( letria.gt.0 .and. letria.le.retrac ) then
          letria = ntriho(iaux)
        else
          letria = 0
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
c 3.1. ==> numero de triangle impossible
c
      if ( letria.le.0 .or. letria.gt.nbtrto ) then
c
        if ( choix.eq.'TR' ) then
          write (ulecr,40010) iaux
        else
          write (ulecr,40020) letria
        endif
        write (ulecr,40030)
c
c 3.2. ==> numero de triangle correct
c
      else
c
        if ( extrus ) then
          numcal = npenca(pentri(letria))
          write (ulecr,40020) letria
          write (ulecr,40050) numcal
        else
          if ( retrac.ne.0 ) then
            numcal = ntrica(letria)
            if ( numcal.ne.0 ) then
              write (ulecr,40020) letria
              write (ulecr,40010) numcal
            else
              write (ulecr,40020) letria
              write (ulecr,40040)
            endif
          else
            write (ulecr,40020) letria
            write (ulecr,40040)
          endif
        endif
c
c 3.2.1. ==> Niveau
c
        if ( letria.le.nbtrma) then
          niveau = 0
          write (ulecr,41000)
        else
          niveau = nivtri(letria)
          if ( letria.le.nbtrpe) then
            write (ulecr,41010) niveau
          else
            write (ulecr,41011) niveau-1
          endif
        endif
c
c 3.2.2. ==> caracteristiques
c
        write (ulecr,42000) famtri(letria)
c
c 3.2.3. ==> ses aretes et ses noeuds
c
c 3.2.3.1. ==> ses aretes
c
        a1 = aretri(letria,1)
        a2 = aretri(letria,2)
        a3 = aretri(letria,3)
c
        call utsotr ( somare, a1, a2, a3,
     >                sa1a2, sa2a3, sa3a1 )
c
        write (ulecr,43030)
        taux40 = textar(mod(hetare(a1),10))
        write (ulecr,43031) a1, taux40
        taux40 = textar(mod(hetare(a2),10))
        write (ulecr,43031) a2, taux40
        taux40 = textar(mod(hetare(a3),10))
        write (ulecr,43031) a3, taux40
c
c 3.2.3.2. ==> ses noeuds
c
        write (ulecr,43040)
        write (ulecr,50003) sa3a1, sa1a2, sa2a3
c
c 3.2.3.3. ==> les noeuds au milieu des aretes
c
        if ( degre.eq.2 ) then
          write (ulecr,43050)
          write (ulecr,50003) np2are(a1), np2are(a2),
     >                         np2are(a3)
        endif
c
c 3.2.3.4. ==> le noeud central
c
        if ( mod(mailet,2).eq.0 ) then
          write (ulecr,43060) nintri(letria)
        endif
c
c 3.2.4. ==> etat
c
        etat01 = mod(hettri(letria),10)
        etat00 = (hettri(letria)-etat01) / 10
c
        taux40 = texttr(etat01)
        write (ulecr,44010)
        write (ulecr,40001) taux40
        if ( nbiter.ge.1 ) then
          taux40 = texttr(etat00)
          write (ulecr,44020)
          write (ulecr,40001) taux40
        endif
c
c 3.2.5. ==> la parente
c 3.2.5.1. ==> les fils
c
        nbfitr = 0
c
        if ( etat01.ne.0 ) then
c
          write (ulecr,45010) mess14(langst,3,2)
          if ( etat01.le.3 ) then
            iaux = 1
          else
            iaux = 3
          endif
          freain = filtri(letria)
          do 3251 , jaux = 0 , iaux
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
 3251     continue
c
        endif
c
c 3.2.5.2 ==> pere et freres
c
        if ( pertri(letria).gt.0 ) then
c
          write (ulecr,45040) mess14(langst,1,2), pertri(letria)
          etatpe = mod(hettri(pertri(letria)),10)
          if ( etatpe.le.3 ) then
            iaux = 1
          else
            iaux = 3
          endif
          if ( iaux.eq.1 ) then
            write (ulecr,45051) mess14(langst,1,2)
          else
            write (ulecr,45050) mess14(langst,3,2)
          endif
          freain = filtri(pertri(letria))
          do 3252 , jaux = 0 , iaux
            kaux = freain+jaux
            if ( kaux.ne.letria) then
              if ( retrac.ne.0 ) then
                if ( ntrica(kaux).eq.0 ) then
                  write (ulecr,45070) kaux
                else
                  write (ulecr,45080) kaux, ntrica(kaux)
                endif
              else
                write (ulecr,45070) kaux
              endif
            endif
 3252     continue
c
        elseif ( pertri(letria).lt.0 .and.
     >           pertri(letria).ge.-nbquto) then
c
          write (ulecr,45040) mess14(langst,1,4), -pertri(letria)
          freain = filqua(-pertri(letria))
          write (ulecr,45050) mess14(langst,3,2)
          do 3253 , jaux = 0 , 2
            kaux = -freain+jaux
            if ( kaux.ne.letria) then
              if ( retrac.ne.0 ) then
                if ( ntrica(kaux).eq.0 ) then
                  write (ulecr,45070) kaux
                else
                  write (ulecr,45080) kaux, ntrica(kaux)
                endif
              else
                write (ulecr,45070) kaux
              endif
            endif
 3253     continue
c
        elseif ( pertri(letria).lt.-nbquto) then
c
          write (ulecr,45091)
#ifdef _DEBUG_HOMARD_
          write (ulecr,45092) pertri(letria)
#endif
        endif
c
c 3.2.6. ==> les faces voisines
c
        trav1a(1) = a1
        trav1a(2) = a2
        trav1a(3) = a3
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
            if ( jaux.ne.pertri(letria) ) then
              if ( jaux.gt.0 ) then
                if ( jaux.ne.letria ) then
                  if ( nivtri(jaux).eq.niveau ) then
                    ntrniv = ntrniv + 1
#include "tbdim4.h"
                    trav2a(ntrniv+nquniv) = jaux
                  else
                    do 32621 , laux = 1 , nbfitr
                      if ( jaux.eq.lifitr(laux) ) then
                        goto 3262
                      endif
32621               continue
                    ntraut = ntraut + 1
#include "tbdim5.h"
                    trav1a(nbar+ntraut+nquaut) = jaux
                  endif
                endif
              else
                if ( nivqua(-jaux).eq.niveau ) then
                  nquniv = nquniv + 1
#include "tbdim4.h"
                  trav2a(ntrniv+nquniv) = jaux
                else
                  nquaut = nquaut + 1
#include "tbdim5.h"
                  trav1a(nbar+ntraut+nquaut) = jaux
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
              taux40 = texttr(mod(hettri(lafac1),10))
              write (ulecr,46000) lafac1, taux40
            endif
 3266     continue
        endif
c
c 3.2.7. ==> les voisins volumiques
c            Remarque : on met une valeur bidon au tableau hethex pour
c                       ne pas avoir de message avec ftnchek
c
        if ( nbteto.ne.0 .or. nbpyto.ne.0 .or. nbpeto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFOVO', nompro
#endif
          volint(1,0) = 0
          volint(2,0) = 0
          volint(3,0) = 0
          volint(4,0) = 0
          trav2a(1) = letria
          iaux = 0
          hethex(1) = iindef
          kaux = ulecr
          call infovo ( iaux, 1, 1, volint,
     >                  voltri, pypetr,
     >                  tbaux1, tbaux2,
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
          if ( homtri(letria).ne.0 ) then
            if ( homtri(letria).ge.0 ) then
              iaux = 2
            else
              iaux = 1
            endif
            write (ulecr,48020) iaux
            write (ulecr,48023) abs(homtri(letria))
          endif
c
        endif
c
c 3.2.9. ==> le centre de gravite
c
        do 329 , iaux = 1 , sdim
          vn(iaux) = unstr * ( coonoe(sa1a2,iaux) +
     >                         coonoe(sa2a3,iaux) +
     >                         coonoe(sa3a1,iaux) )
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
          call utntri ( letria, vn,
     >                  coonoe, somare, aretri )
c
          write (ulecr,49004) (vn(iaux), iaux = 1 , sdim)
c
        endif
c
c 3.2.11. ==> surface, qualite et diametre
c
        call utqtri ( letria, qualit, surf,
     >                coonoe, somare, aretri )
c
        write (ulecr,49020) surf
c
        write (ulecr,49040) qualit
c
        call utdtri ( letria, diamet,
     >                coonoe, somare, aretri )
c
        write (ulecr,49050) diamet
c
c 3.2.12. ==> les valeurs des fonctions
c
        if ( nbpafo.ne.0 .and. numcal.ne.0 ) then
c
          if ( degre.eq.1 ) then
            iaux = edtri3
          else
            iaux = edtri6
          endif
cgn      write (ulecr,90002) 'letria', letria
cgn      write (ulecr,90002) 'numcal', numcal
cgn      write (ulecr,90002) 'ntrics(numcal)', ntrics(numcal)
cgn      write (ulecr,90002) 'ntrica(letria)', ntrica(letria)
cgn      write (ulecr,90002) 'ntrics(ntrica(letria))',
cgn     > ntrics(ntrica(letria))
cgn          jaux = ntrics(ntrica(letria))
          jaux = ntrics(numcal)
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
     >  '* Triangle numero :',i10,   ' dans HOMARD                   *')
40050 format(
     >  '* Face du pentaedre extrude numero ',i10,   ' dans le calcul*')
c
41000 format(
     >  '* . C''est un triangle du maillage initial.                  ',
     >  '*')
c
43210 format(
     >  '* . Ses aretes et les numeros locaux de reference sont :    *')
c
45091 format(
     >  '* . C''est un triangle bordant une non-conformite initiale   ',
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
