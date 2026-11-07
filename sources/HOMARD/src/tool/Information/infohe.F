      subroutine infohe ( choix,  lehexa,
     >                    quahex, coquhe, arehex,
     >                    hethex, filhex, perhex, fhpyte,
     >                    famhex,
     >                    nhexho, nhexca, nhexcs,
     >                    hetare, somare, np2are, coonoe,
     >                    hetqua, arequa, nivqua,
     >                    hettet, ntetca,
     >                    hetpyr, npyrca,
     >                    hetpen,
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
c   INFOrmation : HExaedre
c   ----          --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . choix  . e   .  ch2   . choix                                      .
c . lehexa . e   .   1    . numero du hexaedre a analyser              .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nbhecf*6. codes des 6 quadrangles des hexaedres      .
c . arehex . e   .nbheca12. numeros des 12 aretes des hexaedres        .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . filhex . e   . nbheto . premier fils des hexaedres                 .
c . perhex . e   . nbheto . pere des hexaedres                         .
c .        .     .        . si perhex(i) > 0 : numero de l'hexaedre    .
c .        .     .        . si perhex(i) < 0 : -numero dans pthepe     .
c . fhpyte . e   .2*nbheco. fhpyte(1,j) = numero de la 1ere pyramide   .
c .        .     .        . fille de l'hexaedre k tel que filhex(k) =-j.
c .        .     .        . fhpyte(2,j) = numero du 1er tetraedre      .
c .        .     .        . fils de l'hexaedre k tel que filhex(k) = -j.
c . famhex . e   . nbheto . famille des hexaedres                      .
c . nhexho . e   . reheac . numero des hexaedres dans HOMARD           .
c . nhexca . e   .   *    . numero des hexaedres dans le calcul        .
c . nhexcs . e   .   *    . nro des hexa. du calcul pour la solution   .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . np2are . e   . nbarto . numero du noeud p2 milieu de l'arete       .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . nivqua . e   . nbquto . niveau dans le raffinement/deraffinement   .
c . hettet . e   . nbteto . historique de l'etat des tetraedres        .
c . ntetca . e   .   *    . numero des tetraedres dans le calcul       .
c . hetpyr . e   . nbpyto . historique de l'etat des pyramides         .
c . npyrca . e   .   *    . numero des pyramides dans le calcul        .
c . hetpen . e   . nbpeto . historique de l'etat des pentaedres        .
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
      parameter ( nompro = 'INFOHE' )
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
#include "hexcf0.h"
#include "hexcf1.h"
#include "envada.h"
#include "envca1.h"
c
c 0.3. ==> arguments
c
      character*2 choix
c
      integer lehexa
c
      integer quahex(nbhecf,6), coquhe(nbhecf,6), arehex(nbheca,12)
      integer hethex(nbheto)
      integer filhex(nbheto), perhex(nbheto)
      integer fhpyte(2,nbheco)
      integer famhex(nbheto)
      integer nhexho(reheac), nhexca(*), nhexcs(*)
      integer hetare(nbarto), somare(2,nbarto), np2are(nbarto)
      integer hetqua(nbquto), arequa(nbquto,4), nivqua(nbquto)
      integer hettet(nbteto), ntetca(*)
      integer hetpyr(nbpyto), npyrca(*)
      integer hetpen(nbpeto)
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
      parameter ( nbfa = 6, nbar = 12, nbso = 8 )
c
      integer iaux, jaux, kaux
      integer numcal
      integer etat00, etat01, bindec
      integer niveau, lafac1, lafac2, lafac3, lafac4, lafac5, lafac6
      integer laface, lecode
      integer nbface
      integer larete, lepere
      integer nbfihe, filshe
      integer nbfipy, filspy
      integer nbfite, filste
      integer listar(nbar), listso(nbso), volint(4,0:21)
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
#include "fractf.h"
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
#include "impr03.h"
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
c 2. numero de l'hexaedre dans HOMARD
c====
c
      if ( choix.eq.'HE' ) then
        iaux = lehexa
        if ( lehexa.gt.0 .and. lehexa.le.reheac ) then
          lehexa = nhexho(iaux)
        else
          lehexa = 0
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
c 3.1. ==> numero d'hexaedre impossible
c
      if ( lehexa.le.0 .or. lehexa.gt.nbheto ) then
c
        if ( choix.eq.'HE' ) then
          write (ulecr,40010) iaux
        else
          write (ulecr,40020) lehexa
        endif
        write (ulecr,40030)
c
c 3.2. ==> numero d'hexaedre correct
c
      else
c
        if ( reheac.gt.0 ) then
          numcal = nhexca(lehexa)
        else
          numcal = 0
        endif
        if ( numcal.ne.0 ) then
          write (ulecr,40020) lehexa
          write (ulecr,40010) numcal
        else
          write (ulecr,40020) lehexa
          write (ulecr,40040)
        endif
c
c 3.2.1. ==> Niveau
c
        if ( lehexa.le.nbhema ) then
          write (ulecr,41000)
        else
c
          if ( lehexa.le.nbhecf ) then
            lafac1 = quahex(lehexa,1)
            lafac2 = quahex(lehexa,2)
            lafac3 = quahex(lehexa,3)
            lafac4 = quahex(lehexa,4)
            lafac5 = quahex(lehexa,5)
            lafac6 = quahex(lehexa,6)
            niveau = max(nivqua(lafac1),nivqua(lafac2),
     >                   nivqua(lafac3),nivqua(lafac4),
     >                   nivqua(lafac5),nivqua(lafac6))
          else
            lepere = perhex(lehexa)
            lafac1 = quahex(lepere,1)
            lafac2 = quahex(lepere,2)
            lafac3 = quahex(lepere,3)
            lafac4 = quahex(lepere,4)
            lafac5 = quahex(lepere,5)
            lafac6 = quahex(lepere,6)
            niveau = max(nivqua(lafac1),nivqua(lafac2),
     >                   nivqua(lafac3),nivqua(lafac4),
     >                   nivqua(lafac5),nivqua(lafac6)) + 1
          endif
          if ( lehexa.le.nbhepe ) then
            write (ulecr,41010) niveau
          else
            write (ulecr,41011) niveau-1
          endif
c
        endif
c
c 3.2.2. ==> caracteristiques
c
        write (ulecr,42000) famhex(lehexa)
c
c 3.2.3. ==> les faces, les aretes et les noeuds
c 3.2.3.1. ==> les faces
c
        if ( lehexa.le.nbhecf ) then
c
          write (ulecr,43310)
          do 3231 , iaux = 1 , nbfa
            laface = quahex(lehexa,iaux)
            lecode = coquhe(lehexa,iaux)
            taux40 = textqu(mod(hetqua(laface),100))
            write (ulecr,43320) laface, lecode, taux40
 3231     continue
c
        endif
c
c 3.2.3.2. ==> les aretes et les sommets
c
        call utashe ( lehexa,
     >                nbquto, nbhecf, nbheca,
     >                somare, arequa,
     >                quahex, coquhe, arehex,
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
        write (ulecr,50008) (listso(iaux),iaux=1,nbso)
c
c 3.2.3.3. ==> les noeuds au milieu des aretes
c
        if ( degre.eq.2 ) then
c
          write (ulecr,43050)
          write (ulecr,50012) (np2are(listar(iaux)),iaux=1,nbar)
c
        endif
c
c 3.2.4. ==> etat
c
        etat01 = mod(hethex(lehexa),1000)
        etat00 = (hethex(lehexa)-etat01) / 1000
        bindec = chbiet(etat01)
#ifdef _DEBUG_HOMARD_
      write (ulsort,90015) 'etat', etat01, ' ==> code binaire', bindec
#endif
c
        write (ulecr,44010)
        if ( etat01.le.10 ) then
          taux40 = texthe(etat01)
          write (ulecr,40001) taux40
        else
          if ( etat01.le.22 ) then
            write (ulecr,44031) charde(bindec)
          elseif ( ( etat01.ge.285 ) .and. ( etat01.le.290 ) ) then
            taux40 = texthe(etat01-244)
            write (ulecr,40001) taux40
          else
            write (ulecr,44030) charde(bindec)
          endif
        endif
        if ( nbiter.ge.1 ) then
          taux40 = texthe(etat00)
          write (ulecr,44020)
          jaux = chbiet(etat00)
          if ( etat00.le.10 ) then
            write (ulecr,40001) taux40
          else
            if ( etat00.le.22 ) then
              write (ulecr,44031) charde(jaux)
            elseif ( ( etat00.ge.285 ) .and. ( etat00.le.290 ) ) then
              taux40 = texthe(etat00-244)
              write (ulecr,40001) taux40
            else
              write (ulecr,44030) charde(jaux)
            endif
          endif
        endif
c
c 3.2.5. ==> la parente
c
        call utfihe ( lehexa,
     >                hethex, filhex, fhpyte,
     >                nbfite, filste,
     >                nbfihe, filshe,
     >                nbfipy, filspy )
c
        if ( etat01.ne.0 ) then
c
c 3.2.5.1. ==> les fils
c 3.2.5.1.1. ==> fils pour le decoupage de conformite
c
          if ( etat01.ge.11 ) then
c
            if ( nbfipy.ge.1 ) then
              write (ulecr,45010) mess14(langst,3,5)
              do 3251 , jaux = 0 , nbfipy-1
                kaux = filspy+jaux
                write (ulecr,45080) kaux, npyrca(kaux)
 3251         continue
            endif
            if ( nbfite.ge.1 ) then
              write (ulecr,45010) mess14(langst,3,3)
              do 3252 , jaux = 0 , nbfite-1
                kaux = filste+jaux
                write (ulecr,45080) kaux, ntetca(kaux)
 3252         continue
            endif
            if ( nbfihe.ge.1 ) then
              write (ulecr,45010) mess14(langst,3,6)
              do 3253 , jaux = 0 , nbfihe-1
                kaux = filshe+jaux
                write (ulecr,45080) kaux, nhexca(kaux)
 3253         continue
            endif
c
c 3.2.5.1.2. ==> fils pour le decoupage standard
c
          else
c
            write (ulecr,45010) mess14(langst,3,6)
            do 3254 , jaux = 0 , nbfihe-1
              kaux = filshe+jaux
              if ( reheac.eq.0 .or. nhexca(kaux).eq.0 ) then
                write (ulecr,45070) kaux
              else
                write (ulecr,45080) kaux, nhexca(kaux)
              endif
 3254       continue
          endif
c
        endif
c
c 3.2.5.2 ==> pere
c
        if ( perhex(lehexa).ne.0 ) then
c
          write (ulecr,45041) mess14(langst,1,6), perhex(lehexa)
          call utfihe ( perhex(lehexa),
     >                  hethex, filhex, fhpyte,
     >                  nbfite, filste,
     >                  nbfihe, filshe,
     >                  nbfipy, filspy )
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbfihe', nbfihe
      write (ulsort,90002) 'nbfipy', nbfipy
      write (ulsort,90002) 'nbfite', nbfite
#endif
          write (ulecr,45050) mess14(langst,3,6)
          if ( nbfipy.ge.1 ) then
            write (ulecr,45010) mess14(langst,3,5)
            do 32521 , jaux = 0 , nbfipy-1
              kaux = filspy+jaux
              write (ulecr,45080) kaux, npyrca(kaux)
32521       continue
          endif
          if ( nbfite.ge.1 ) then
            write (ulecr,45010) mess14(langst,3,3)
            do 32522 , jaux = 0 , nbfite-1
              kaux = filste+jaux
              write (ulecr,45080) kaux, ntetca(kaux)
32522       continue
          endif
          if ( nbfihe.ge.1 ) then
            do 32523 , jaux = 0 , nbfihe-1
              kaux = filshe+jaux
              if ( kaux.ne.lehexa ) then
                if ( reheac.eq.0 ) then
                  write (ulecr,45070) kaux
                else
                  write (ulecr,45080) kaux, nhexca(kaux)
                endif
              endif
32523       continue
          endif
c
        endif
c
c 3.2.6. ==> les volumes voisins
c 3.2.6.1. ==> on commence par dresser la liste de tous les hexaedres
c              qui bordent les faces de l'hexaedre courant mais qui ne
c              peuvent pas etre consideres comme des volumes voisins :
c              lui-meme et ses fils dans les cas de conformite.
c              il suffit d'eliminer les pyramides dont la base est une
c              des faces quadrangulaires de l'hexaedre. Dans les autres
c              cas, le volume ne peut pas etre voisin de l'hexaedre.
c
        volint(1,0) = 0
        iaux = 1
        volint(2,iaux) = lehexa
        volint(2,0) = iaux
        iaux = 0
        if ( etat01.ge.11 ) then
          do 3261 , jaux = 1 , nbfipy
            iaux = iaux + 1
            volint(3,iaux) = fhpyte(1,-filhex(lehexa)) + jaux - 1
 3261     continue
        endif
        volint(3,0) = iaux
        volint(4,0) = 0
c
c 3.2.6.2. ==> liste des faces a examiner
c
        nbface = 0
        if ( lehexa.le.nbhecf ) then
c
          do 3262 , iaux = 1 , 6
            if ( volqua(2,quahex(lehexa,iaux)).ne.0 ) then
              nbface = nbface + 1
              trav2a(nbface) = -quahex(lehexa,iaux)
            endif
 3262    continue
c
        endif
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
          vn(iaux) = unshu * ( coonoe(listso(1),iaux) +
     >                         coonoe(listso(2),iaux) +
     >                         coonoe(listso(3),iaux) +
     >                         coonoe(listso(4),iaux) +
     >                         coonoe(listso(5),iaux) +
     >                         coonoe(listso(6),iaux) +
     >                         coonoe(listso(7),iaux) +
     >                         coonoe(listso(8),iaux) )
  327   continue
c
        write (ulecr,49003) (vn(iaux), iaux = 1 , sdim)
c
c 3.2.8. ==> volume, qualite, diametre et torsion
c
        call utqhex ( lehexa, qualit, qualij, volume,
     >                coonoe, somare, arequa,
     >                quahex, coquhe, arehex )
c
        write (ulecr,49030) volume
c
        write (ulecr,49146) qualit
c
        write (ulecr,49041) qualij
c
        call utdhex ( lehexa, diamet,
     >                coonoe, somare, arequa,
     >                quahex, coquhe, arehex )
c
        write (ulecr,49050) diamet
c
        call utthex ( lehexa, torsio,
     >                coonoe, somare, arequa,
     >                quahex, coquhe, arehex )
c
        write (ulecr,49060) torsio
c
c 3.2.9. ==> les valeurs des fonctions
c
        if ( nbpafo.ne.0 .and. numcal.ne.0 ) then
c
          if ( degre.eq.1 ) then
            iaux = edhex8
          else
            iaux = edhe20
          endif
          jaux = nhexcs(numcal)
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
     >  '* Hexaedre numero :',i10,   ' dans HOMARD                   *')
c
41000 format(
     >  '* . C''est un hexaedre du maillage initial.                  ',
     >  '*')
c
46110 format(
     >  '* . Il a un hexaedre voisin :                               *')
46120 format(
     >  '* . Il est le voisin de ',i10,   ' hexaedres :              *')
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
