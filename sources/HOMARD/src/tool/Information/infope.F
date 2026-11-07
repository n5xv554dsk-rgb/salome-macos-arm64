      subroutine infope ( choix,  lepent,
     >                    facpen, cofape, arepen,
     >                    hetpen, filpen, perpen, fppyte,
     >                    fampen,
     >                    npenho, npenca, npencs,
     >                    hetare, somare, np2are, coonoe,
     >                    hettri, nivtri,
     >                    hetqua, arequa, nivqua,
     >                    hettet, ntetca,
     >                    hethex,
     >                    hetpyr, npyrca,
     >                    voltri, pypetr,
     >                    volqua, pypequ,
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
c   INFOrmation : PEntaedre
c   ----          --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . choix  . e   .  ch2   . choix                                      .
c . lepent . e   .   1    . numero du pentaedre a analyser             .
c . facpen . e   .nbpecf*5. numeros des 5 faces des pentaedres         .
c . cofape . e   .nbpecf*5. code des 5 faces des pentaedres            .
c . arepen . e   .nbpeca*9. numeros des 9 aretes des pentaedres        .
c . hetpen . e   . nbpeto . historique de l'etat des pentaedres        .
c . filpen . e   . nbpeto . premier fils des pentaedres                .
c . perpen . e   . nbpeto . pere des pentaedres                        .
c . fppyte . e   .2*nbpeco. fppyte(1,j) = numero de la 1ere pyramide   .
c .        .     .        . fille du pentaedre k tel que filpen(k) = -j.
c .        .     .        . fppyte(2,j) = numero du 1er tetraedre      .
c .        .     .        . fils du pentaedre k tel que filpen(k) = -j .
c . fampen . e   . nbpeto . famille des pentaedres                     .
c . npenho . e   . repeac . numero des pentaedres dans HOMARD          .
c . npenca . e   .   *    . numero des pentaedres dans le calcul       .
c . npencs . e   .   *    . nro des pent. du calcul pour la solution   .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . np2are . e   . nbarto . numero du noeud p2 milieu de l'arete       .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . nivtri . e   . nbtrto . niveau dans le raffinement/deraffinement   .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . nivqua . e   . nbquto . niveau dans le raffinement/deraffinement   .
c . hettet . e   . nbteto . historique de l'etat des tetraedres        .
c . ntetca . e   .   *    . numero des tetraedres dans le calcul       .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . hetpyr . e   . nbpyto . historique de l'etat des pyramides         .
c . npyrca . e   .   *    . numero des pyramides dans le calcul        .
c . voltri . e   .2*nbtrto. numeros des 2 volumes par triangle         .
c .        .     .        . voltri(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : tetraedre j                          .
c .        .     .        . j<0 : pyramide/pentaedre dans pypetr(1/2,j).
c . pypetr . a   .2*lgpype. pypetr(1,j) = numero de la pyramide voisine.
c .        .     .        . du triangle k tel que voltri(1/2,k) = -j   .
c .        .     .        . pypetr(2,j) = numero du pentaedre voisin   .
c .        .     .        . du triangle k tel que voltri(1/2,k) = -j   .
c . volqua . e   .2*nbquto. numeros des 2 volumes par quadrangle       .
c .        .     .        . volqua(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : hexaedre j                           .
c .        .     .        . j<0 : pyramide/pentaedre dans pypequ(1/2,j).
c . pypequ . 2   .2*lgpype. pypequ(1,j) = numero de la pyramide voisine.
c .        .     .        . du quadrangle k tel que volqua(1/2,k) = -j .
c .        .     .        . pypequ(2,j) = numero du pentaedre voisin   .
c .        .     .        . du quadrangle k tel que volqua(1/2,k) = -j .
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
      parameter ( nompro = 'INFOPE' )
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
c
#include "nomber.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
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
      integer lepent
c
      integer facpen(nbpecf,5), cofape(nbpecf,5), arepen(nbpeca,9)
      integer hetpen(nbpeto)
      integer filpen(nbpeto), perpen(nbpeto), fppyte(2,nbpeco)
      integer fampen(nbpeto)
      integer npenho(repeac), npenca(*), npencs(*)
      integer hetare(nbarto), somare(2,nbarto), np2are(nbarto)
      integer hettri(nbtrto), nivtri(nbtrto)
      integer hetqua(nbquto), arequa(nbquto,4), nivqua(nbquto)
      integer hettet(nbteto), ntetca(*)
      integer hethex(nbheto)
      integer hetpyr(nbpyto), npyrca(*)
      integer volqua(2,nbquto), pypequ(2,*)
      integer voltri(2,nbtrto), pypetr(2,*)
      integer nbpafo
c
      double precision coonoe(nbnoto,sdim)
c
      character*8 nopafo(*)
c
      integer ulsost
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer nbfa, nbar, nbso
      parameter ( nbfa = 5, nbar = 9, nbso = 6 )
c
      integer iaux, jaux, kaux
      integer numcal
      integer etat00, etat01, etatpe
      integer niveau, lafac1, lafac2, lafac3, lafac4, lafac5
      integer laface, lecode
      integer nbface
      integer freain, larete
      integer nbfipy, filspy
      integer nbfite, filste
      integer nbfipe
      integer listar(nbar), listso(nbso), volint(4,0:5)
      integer uldeb, ulfin, ulpas, ulecr
c
      integer trav1a(tbdim), trav2a(tbdim)
c
      character*40 taux40
c
      double precision qualit, qualij, volume, diamet, torsio
      double precision vn(4)
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
#include "fracte.h"
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
      codret = 0
c
      uldeb = min(ulsost,ulsort)
      ulfin = max(ulsost,ulsort)
      ulpas = max ( 1 , ulfin-uldeb )
c
c====
c 2. numero du pentaedre dans HOMARD
c====
c
      if ( choix.eq.'PE' ) then
        iaux = lepent
        if ( lepent.gt.0 .and. lepent.le.repeac ) then
          lepent = npenho(iaux)
        else
          lepent = 0
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
c 3.1. ==> numero de pentaedre impossible
c
      if ( lepent.le.0 .or. lepent.gt.nbpeto ) then
c
        if ( choix.eq.'PE' ) then
          write (ulecr,40010) iaux
        else
          write (ulecr,40020) lepent
        endif
        write (ulecr,40030)
c
c 3.2. ==> numero de pentaedre correct
c
      else
c
        if ( repeac.gt.0 ) then
          numcal = npenca(lepent)
        else
          numcal = 0
        endif
        if ( numcal.ne.0 ) then
          write (ulecr,40020) lepent
          write (ulecr,40010) numcal
        else
          write (ulecr,40020) lepent
          write (ulecr,40040)
        endif
c
c 3.2.1. ==> Niveau
c
        if ( lepent.le.nbpema ) then
          write (ulecr,41000)
        else
          if ( lepent.le.nbpecf ) then
            lafac1 = facpen(lepent,1)
            lafac2 = facpen(lepent,2)
            lafac3 = facpen(lepent,3)
            lafac4 = facpen(lepent,4)
            lafac5 = facpen(lepent,5)
            niveau = max(nivtri(lafac1),nivtri(lafac2),
     >                   nivqua(lafac3),nivqua(lafac4),nivqua(lafac5))
          endif
          if ( lepent.le.nbpepe ) then
            write (ulecr,41010) niveau
          else
            write (ulecr,41011) niveau-1
          endif
c
        endif
c
c 3.2.2. ==> caracteristiques
c
        write (ulecr,42000) fampen(lepent)
c
c 3.2.3. ==> les faces, les aretes et les noeuds
c 3.2.3.1. ==> les faces
c
        if ( lepent.le.nbpecf ) then
c
          write (ulecr,43310)
          do 3231 , iaux = 1 , nbfa
            laface = facpen(lepent,iaux)
            lecode = cofape(lepent,iaux)
            if ( iaux.le.2 ) then
              taux40 = texttr(mod(hettri(laface),10))
            else
              taux40 = textqu(mod(hetqua(laface),100))
              laface = -laface
            endif
            write (ulecr,43320) laface, lecode, taux40
 3231     continue
c
        endif
c
c 3.2.3.2. ==> les aretes et les sommets
c
        call utaspe ( lepent,
     >                nbquto, nbpecf, nbpeca,
     >                somare, arequa,
     >                facpen, cofape, arepen,
     >                listar, listso )
c
        write (ulecr,43030)
        do 3232 , iaux = 1 , nbar
          larete = listar(iaux)
          taux40 = textar(mod(hetare(larete),10))
          write (ulecr,43031) larete, taux40
 3232   continue
c
        write (ulecr,43040)
        write (ulecr,50006) (listso(iaux),iaux=1,nbso)
c
c 3.2.3.3. ==> les noeuds au milieu des aretes
c
        if ( degre.eq.2 ) then
c
          write (ulecr,43050)
          write (ulecr,50009) (np2are(listar(iaux)),iaux=1,nbar)
c
        endif
c
c 3.2.4. ==> etat
c
        etat01 = mod(hetpen(lepent),100)
        etat00 = (hetpen(lepent)-etat01) / 100
c
        taux40 = textpe(etat01)
        write (ulecr,44010)
        write (ulecr,40001) taux40
        if ( nbiter.ge.1 ) then
          taux40 = textpe(etat00)
          write (ulecr,44020)
          write (ulecr,40001) taux40
        endif
c
c 3.2.5. ==> la parente
c 3.2.5.1. ==> les fils
c
        if ( etat01.ne.0 ) then
c
          freain = filpen(lepent)
c
c 3.2.5.1. ==> les fils
c 3.2.5.1.1. ==> fils pour le decoupage de conformite
c
          if ( ( etat01.ge. 1 .and. etat01.le. 6 ) .or.
     >         ( etat01.ge.17 .and. etat01.le.19 ) .or.
     >         ( etat01.ge.21 .and. etat01.le.26 ) .or.
     >         ( etat01.ge.31 .and. etat01.le.36 ) .or.
     >         ( etat01.ge.43 .and. etat01.le.45 ) .or.
     >         ( etat01.ge.51 .and. etat01.le.52 ) ) then
c
            freain = -freain
            filspy = fppyte(1,freain)
            filste = fppyte(2,freain)
            if ( etat01.ge.1 .and. etat01.le.6 ) then
              nbfipy = 1
              nbfite = 0
            elseif ( etat01.ge.17 .and. etat01.le.19 ) then
              nbfipy = 0
              nbfite = 1
            elseif ( etat01.ge.21 .and. etat01.le.26 ) then
              nbfipy = -1
              nbfite = 5
            elseif ( etat01.ge.31 .and. etat01.le.36 ) then
              nbfipy = 0
              nbfite = 9
            elseif ( etat01.ge.43 .and. etat01.le.45 ) then
              nbfipy = 3
              nbfite = 1
            elseif ( etat01.ge.51 .and. etat01.le.52 ) then
              nbfipy = -1
              nbfite = 10
            else
              nbfipy = -1
              nbfite = -1
            endif
            if ( nbfipy.ge.0 ) then
              write (ulecr,45010) mess14(langst,3,5)
              do 3251 , jaux = 0 , nbfipy
                kaux = filspy+jaux
                write (ulecr,45080) kaux, npyrca(kaux)
 3251         continue
            endif
            if ( nbfite.ge.0 ) then
              write (ulecr,45010) mess14(langst,3,3)
              do 3252 , jaux = 0 , nbfite
                kaux = filste+jaux
                write (ulecr,45080) kaux, ntetca(kaux)
 3252         continue
            endif
c
c 3.2.5.1.2. ==> fils pour le decoupage standard
c
          else
c
            write (ulecr,45010) mess14(langst,3,7)
            nbfipe = 7
            do 3253 , jaux = 0 , nbfipe
              kaux = freain+jaux
              if ( repeac.eq.0 .or. npenca(kaux).eq.0 ) then
                write (ulecr,45070) kaux
              else
                write (ulecr,45080) kaux, npenca(kaux)
              endif
 3253       continue
          endif
c
        endif
c
c 3.2.5.2 ==> pere
c
        if ( perpen(lepent).ne.0 ) then
c
          write (ulecr,45040) mess14(langst,1,7), perpen(lepent)
          etatpe = mod(hetpen(perpen(lepent)),100)
          if ( etatpe.eq.80 .or. etatpe.eq.99 ) then
            iaux = 7
          else
            codret = 3252
            goto 30
          endif
          freain = filpen(perpen(lepent))
          write (ulecr,45050) mess14(langst,3,7)
          do 3254 , jaux = 0 , iaux
            kaux = freain+jaux
            if ( kaux.ne.lepent ) then
              if ( repeac.eq.0 ) then
                write (ulecr,45070) kaux
              else
                write (ulecr,45080) kaux, npenca(kaux)
              endif
            endif
 3254     continue
c
        endif
c
c 3.2.6. ==> les volumes voisins
c 3.2.6.1. ==> on commence par dresser la liste de tous les pentaedres
c              qui bordent les faces du pentaedre courant mais qui ne
c              peuvent pas etre consideres comme des volumes voisins :
c              lui-meme et ses fils dans les cas de conformite.
c              il suffit d'eliminer les pyramides dont la base est une
c              des faces quadrangulaires de l'hexaedre et les tetraedres
c              s'appuyant sur une face triangulaire non decoupee.
c              Dans les autres cas, le volume ne peut pas etre voisin
c              du pentaedre.
c              voir cmcdpe pour les conventions sur les fils
c
        iaux = 0
        if ( etat01.ge.1 .and. etat01.le.9 ) then
          iaux = iaux + 1
          volint(1,iaux) = fppyte(2,-filpen(lepent))
        elseif ( etat01.ge.7 .and. etat01.le.9 ) then
          iaux = iaux + 1
          volint(1,iaux) = fppyte(2,-filpen(lepent))
          iaux = iaux + 1
          volint(1,iaux) = fppyte(2,-filpen(lepent)) + 1
        elseif ( etat01.ge.11 .and. etat01.le.16 ) then
          iaux = iaux + 1
          volint(1,iaux) = fppyte(2,-filpen(lepent))
        elseif ( etat01.ge.31 .and. etat01.le.32 ) then
          iaux = iaux + 1
          volint(1,iaux) = fppyte(2,-filpen(lepent)) + 10
        endif
        volint(1,0) = iaux
        volint(2,0) = 0
        iaux = 1
        if ( etat01.ge.1 .and. etat01.le.9 ) then
          iaux = iaux + 1
          volint(3,iaux) = fppyte(1,-filpen(lepent))
          iaux = iaux + 1
          volint(3,iaux) = fppyte(1,-filpen(lepent)) + 1
        elseif ( etat01.ge.7 .and. etat01.le.9 ) then
          iaux = iaux + 1
          volint(3,iaux) = fppyte(1,-filpen(lepent))
        elseif ( etat01.ge.21 .and. etat01.le.23 ) then
          iaux = iaux + 1
          volint(3,iaux) = fppyte(2,-filpen(lepent))
        endif
        volint(3,0) = iaux
        volint(4,iaux) = lepent
        volint(4,0) = iaux
c
c 3.2.6.2. ==> liste des faces a examiner
c
        nbface = 0
c
c 3.2.6.2.1. ==> voisinage par les triangles
c
        do 32621 , iaux = 1, 2
          if ( voltri(2,facpen(lepent,iaux)).ne.0 ) then
            nbface = nbface + 1
            trav2a(nbface) = facpen(lepent,iaux)
          endif
32621   continue
c
c 3.2.6.2.2. ==> voisinage par les quadrangles
c
        do 32622 , iaux = 3, 5
          if ( volqua(2,facpen(lepent,iaux)).ne.0 ) then
            nbface = nbface + 1
            trav2a(nbface) = -facpen(lepent,iaux)
          endif
32622   continue
c
c 3.2.6.3. ==> impression
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFOVO', nompro
#endif
        iaux = 40
        kaux = ulecr
        call infovo ( iaux, 1, nbface, volint,
     >                voltri, pypetr,
     >                volqua, pypequ,
     >                hettet, hetpyr, hethex, hetpen,
     >                trav1a, trav2a,
     >                kaux,
     >                ulsort, langue, codret )
c
c 3.2.7. ==> le centre de gravite
c
        do 327 , iaux = 1 , sdim
          vn(iaux) = unssix * ( coonoe(listso(1),iaux) +
     >                          coonoe(listso(2),iaux) +
     >                          coonoe(listso(3),iaux) +
     >                          coonoe(listso(4),iaux) +
     >                          coonoe(listso(5),iaux) +
     >                          coonoe(listso(6),iaux) )
  327   continue
c
        write (ulecr,49003) (vn(iaux), iaux = 1 , sdim)
c
c 3.2.8. ==> volume, qualite, diametre et torsion
c
        call utqpen ( lepent, qualit, qualij, volume,
     >                coonoe, somare, arequa,
     >                facpen, cofape, arepen )
c
        write (ulecr,49030) volume
c
        write (ulecr,49041) qualij
c
        call utdpen ( lepent, diamet,
     >                coonoe, somare, arequa,
     >                facpen, cofape, arepen )
c
        write (ulecr,49050) diamet
c
        call uttpen ( lepent, torsio,
     >                coonoe, somare, arequa,
     >                facpen, cofape, arepen )
c
        write (ulecr,49060) torsio
c
c 3.2.9. ==> les valeurs des fonctions
c
        if ( nbpafo.ne.0 .and. numcal.ne.0 ) then
c
          if ( degre.eq.1 ) then
            iaux = edpen6
          else
            iaux = edpe15
          endif
          jaux = npencs(numcal)
          kaux = ulecr
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFOPF', nompro
#endif
          call infopf ( nbpafo, nopafo,
     >                  iaux, jaux,
     >                  kaux,
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
     >  '* Pentaedre numero :',i10,   ' dans HOMARD                  *')
c
41000 format(
     >  '* . C''est un pentaedre du maillage initial.                 ',
     >  '*')
c
46110 format(
     >  '* . Il a un pentaedre voisin :                              *')
46120 format(
     >  '* . Il est le voisin de ',i10,   ' pentaedres :             *')
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
