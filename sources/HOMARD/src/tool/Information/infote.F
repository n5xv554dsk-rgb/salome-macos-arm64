      subroutine infote ( choix,  letetr,
     >                    tritet, cotrte, aretet,
     >                    hettet, filtet, pertet, pthepe,
     >                    famtet,
     >                    ntetho, ntetca, ntetcs,
     >                    hetare, somare, np2are, coonoe,
     >                    hettri, aretri, nivtri,
     >                    nivqua,
     >                    hethex, quahex, filhex, fhpyte,
     >                    hetpyr, npyrca,
     >                    hetpen, facpen, filpen, fppyte,
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
c   INFOrmation : TEtraedre
c   ----          --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . choix  . e   .  ch2   . choix                                      .
c . letetr . e   .   1    . numero du tetraedre a analyser             .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . e   .nbtecf*4. code des 4 triangles des tetraedres        .
c . aretet . e   .nbteca*6. numeros des 6 aretes des tetraedres        .
c . hettet . e   . nbteto . historique de l'etat des tetraedres        .
c . filtet . e   . nbteto . premier fils des tetraedres                .
c . pertet . e   . nbteto . pere des tetraedres                        .
c .        .     .        . si pertet(i) > 0 : numero du tetraedre     .
c .        .     .        . si pertet(i) < 0 : -numero dans pthepe     .
c . pthepe . e   .    *   . si i <= nbheco : numero de l'hexaedre      .
c .        .     .        . si non : numero du pentaedre               .
c . famtet . e   . nbteto . famille des tetraedres                     .
c . ntetho . e   . reteac . numero des tetraedres dans HOMARD          .
c . ntetca . e   .   *    . numero des tetraedres dans le calcul       .
c . ntetcs . e   .   *    . nro des tetra. du calcul pour la solution  .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . np2are . e   . nbarto . numero du noeud p2 milieu de l'arete       .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . nivtri . e   . nbtrto . niveau dans le raffinement/deraffinement   .
c . nivqua . e   . nbquto . niveau dans le raffinement/deraffinement   .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . filhex . e   . nbheto . premier fils des hexaedres                 .
c . fhpyte . e   .2*nbheco. fhpyte(1,j) = numero de la 1ere pyramide   .
c .        .     .        . fille de l'hexaedre k tel que filhex(k) =-j.
c .        .     .        . fhpyte(2,j) = numero du 1er tetraedre      .
c .        .     .        . fils de l'hexaedre k tel que filhex(k) = -j.
c . hetpyr . e   . nbpyto . historique de l'etat des pyramides         .
c . hetpen . e   . nbpeto . historique de l'etat des pentaedres        .
c . facpen . e   .nbpecf*5. numeros des 5 faces des pentaedres         .
c . filpen . e   . nbpeto . premier fils des hexaedres                 .
c . fppyte . e   .2*nbpeco. fppyte(1,j) = numero de la 1ere pyramide   .
c .        .     .        . fille du pentaedre k tel que filpen(k) = -j.
c .        .     .        . fppyte(2,j) = numero du 1er tetraedre      .
c .        .     .        . fils du pentaedre k tel que filpen(k) = -j .
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
      parameter ( nompro = 'INFOTE' )
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
c
#include "envada.h"
#include "envca1.h"
c
c 0.3. ==> arguments
c
      character*2 choix
c
      integer letetr
c
      integer tritet(nbtecf,4), cotrte(nbtecf,4), aretet(nbteca,6)
      integer hettet(nbteto)
      integer filtet(nbteto), pertet(nbteto), pthepe(*)
      integer famtet(nbteto)
      integer ntetho(reteac), ntetca(*), ntetcs(*)
      integer hetare(nbarto), somare(2,nbarto), np2are(nbarto)
      integer hettri(nbtrto), aretri(nbtrto,3), nivtri(nbtrto)
      integer nivqua(nbquto)
      integer hethex(nbheto), quahex(nbhecf,6)
      integer filhex(nbheto), fhpyte(2,nbheco)
      integer hetpyr(nbpyto), npyrca(*)
      integer hetpen(nbpeto), facpen(nbpecf,5)
      integer filpen(nbheto), fppyte(2,nbpeco)
      integer voltri(2,nbtrto), pypetr(2,*)
      integer volqua(2,nbquto), pypequ(2,*)
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
      parameter ( nbfa = 4, nbar = 6, nbso = 4 )
c
      integer iaux, jaux, kaux
      integer numcal
      integer etat00, etat01, etatpe
      integer niveau, lafac1, lafac2, lafac3, lafac4, lafac5, lafac6
      integer laface, lecode
      integer nbface
      integer freain, larete, lepere
      integer nbfipy, filspy
      integer nbfite, filste
      integer nbfihe
      integer listar(nbar), listso(nbso), volint(4,0:5)
      integer uldeb, ulfin, ulpas, ulecr
c
      integer trav1a(tbdim), trav2a(tbdim)
c
      character*40 taux40
c
      double precision qualit, qualij, volume, diamet
      double precision vn(3)
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
c 2. numero du tetraedre dans HOMARD
c====
c
      if ( choix.eq.'TE' ) then
        iaux = letetr
        if ( letetr.gt.0 .and. letetr.le.reteac ) then
          letetr = ntetho(iaux)
        else
          letetr = 0
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
c 3.1. ==> numero de tetraedre impossible
c
      if ( letetr.le.0 .or. letetr.gt.nbteto ) then
c
        if ( choix.eq.'TE' ) then
          write (ulecr,40010) iaux
        else
          write (ulecr,40020) letetr
        endif
        write (ulecr,40030)
c
c 3.2. ==> numero de tetraedre correct
c
      else
c
        numcal = ntetca(letetr)
        if ( numcal.ne.0 ) then
          write (ulecr,40020) letetr
          write (ulecr,40010) numcal
        else
          write (ulecr,40020) letetr
          write (ulecr,40040)
        endif
c
c 3.2.1. ==> Niveau
c
        if ( letetr.le.nbtema ) then
          write (ulecr,41000)
        else
c
          if ( letetr.le.nbtecf ) then
            lafac1 = tritet(letetr,1)
            lafac2 = tritet(letetr,2)
            lafac3 = tritet(letetr,3)
            lafac4 = tritet(letetr,4)
            niveau = max(nivtri(lafac1),nivtri(lafac2),
     >                   nivtri(lafac3),nivtri(lafac4))
          else
            iaux = pertet(letetr)
            lepere = pthepe(-iaux)
            if ( -iaux.le.nbheco ) then
              lafac1 = quahex(lepere,1)
              lafac2 = quahex(lepere,2)
              lafac3 = quahex(lepere,3)
              lafac4 = quahex(lepere,4)
              lafac5 = quahex(lepere,5)
              lafac6 = quahex(lepere,6)
              niveau = max(nivqua(lafac1),nivqua(lafac2),
     >                     nivqua(lafac3),nivqua(lafac4),
     >                     nivqua(lafac5),nivqua(lafac6)) + 1
            else
              lafac1 = facpen(lepere,1)
              lafac2 = facpen(lepere,2)
              lafac3 = facpen(lepere,3)
              lafac4 = facpen(lepere,4)
              lafac5 = facpen(lepere,5)
              niveau = max(nivtri(lafac1),nivtri(lafac2),
     >                     nivqua(lafac3),nivqua(lafac4),
     >                     nivqua(lafac5)) + 1
            endif
          endif
          if ( letetr.le.nbtepe ) then
            write (ulecr,41010) niveau
          else
            write (ulecr,41011) niveau-1
          endif
c
        endif
c
c 3.2.2. ==> caracteristiques
c
        write (ulecr,42000) famtet(letetr)
c
c 3.2.3. ==> les faces, les aretes et les noeuds
c 3.2.3.1. ==> les faces
c
        if ( letetr.le.nbtecf ) then
c
          write (ulecr,43310)
          do 3231 , iaux = 1 , nbfa
            laface = tritet(letetr,iaux)
            lecode = cotrte(letetr,iaux)
            taux40 = texttr(mod(hettri(laface),10))
            write (ulecr,43320) laface, lecode, taux40
 3231     continue
c
        endif
c
c 3.2.3.2. ==> les aretes et les sommets
c
        call utaste ( letetr,
     >                nbtrto, nbtecf, nbteca,
     >                somare, aretri,
     >                tritet, cotrte, aretet,
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
        write (ulecr,50004) (listso(iaux),iaux=1,nbso)
c
c 3.2.3.3. ==> les noeuds au milieu des aretes
c
        if ( degre.eq.2 ) then
c
          write (ulecr,43050)
          write (ulecr,50006) (np2are(listar(iaux)),iaux=1,nbar)
c
        endif
c
c 3.2.4. ==> etat
c
        etat01 = mod(hettet(letetr),100)
        etat00 = (hettet(letetr)-etat01) / 100
c
        taux40 = textte(etat01)
        write (ulecr,44010)
        write (ulecr,40001) taux40
        if ( nbiter.ge.1 ) then
          taux40 = textte(etat00)
          write (ulecr,44020)
          write (ulecr,40001) taux40
        endif
c
c 3.2.5. ==> la parente
c 3.2.5.1. ==> les fils
c
        if ( etat01.ne.0 ) then
          if ( etat01.le.26 ) then
            iaux = 1
          elseif ( etat01.le.47 ) then
            iaux = 3
          else
            iaux = 7
          endif
          write (ulecr,45010) mess14(langst,3,3)
          freain = filtet(letetr)
          do 3251 , jaux = 0 , iaux
            kaux = freain+jaux
            if ( ntetca(kaux).eq.0 ) then
              write (ulecr,45070) kaux
            else
              write (ulecr,45080) kaux, ntetca(kaux)
            endif
 3251     continue
        endif
c
c 3.2.5.2. ==> pere
c
        iaux = pertet(letetr)
        if ( iaux.ne.0 ) then
c
c 3.2.5.2.1. ==> issu d'un decoupage standard d'un tetraedre
c
          if ( iaux.gt.0 ) then
c
            write (ulecr,45040) mess14(langst,1,3), iaux
            etatpe = mod(hettet(iaux),100)
            if ( etatpe.le.26 ) then
              nbfite = 1
            elseif ( etatpe.le.47 ) then
              nbfite = 3
            else
              nbfite = 7
            endif
            if ( nbfite.eq.1 ) then
              write (ulecr,45051) mess14(langst,1,3)
            else
              write (ulecr,45050) mess14(langst,3,3)
            endif
            freain = filtet(iaux)
            do 3252 , jaux = 0 , nbfite
              kaux = freain+jaux
              if ( kaux.ne.letetr ) then
                if ( ntetca(kaux).eq.0 ) then
                  write (ulecr,45070) kaux
                else
                  write (ulecr,45080) kaux, ntetca(kaux)
                endif
              endif
 3252       continue
c
c 3.2.5.2.2. ==> issu d'un decoupage de conformite d'un hexaedre
c
          elseif ( -iaux.le.nbheco ) then
c
            lepere = pthepe(-iaux)
            write (ulecr,45041) mess14(langst,1,6), lepere
            etatpe = mod(hethex(lepere),1000)
            jaux = chbiet(etatpe)
            nbfihe = chnhe(jaux)-1
            nbfipy = chnpy(jaux)-1
            nbfite = chnte(jaux)-1
            kaux = filhex(lepere)
            filspy = fhpyte(1,-kaux)
            filste = fhpyte(2,-kaux)
            if ( nbfipy.ge.0 ) then
              write (ulecr,45050) mess14(langst,3,5)
              do 3253 , jaux = 0 , nbfipy
                kaux = filspy+jaux
                write (ulecr,45080) kaux, npyrca(kaux)
 3253         continue
            endif
            if ( nbfite.ge.0 ) then
              write (ulecr,45050) mess14(langst,3,3)
              do 3254 , jaux = 0 , nbfite
                kaux = filste+jaux
                if ( kaux.ne.letetr ) then
                  write (ulecr,45080) kaux, ntetca(kaux)
                endif
 3254         continue
            endif
c
c 3.2.5.2.3. ==> issu d'un decoupage de conformite d'un pentaedre
c
          else
c
            lepere = pthepe(-iaux)
            write (ulecr,45040) mess14(langst,1,7), lepere
            etatpe = mod(hetpen(lepere),100)
            kaux = filpen(lepere)
            filspy = fppyte(1,-kaux)
            filste = fppyte(2,-kaux)
            if ( etatpe.ge.1 .and. etatpe.le.6 ) then
              nbfipy = 1
              nbfite = 0
            elseif ( etatpe.ge.17 .and. etatpe.le.19 ) then
              nbfipy = 0
              nbfite = 1
            elseif ( etatpe.ge.21 .and. etatpe.le.26 ) then
              nbfipy = 0
              nbfite = 5
            elseif ( etatpe.ge.31 .and. etatpe.le.36 ) then
              nbfipy = 0
              nbfite = 9
            elseif ( etatpe.ge.43 .and. etatpe.le.45 ) then
              nbfipy = 3
              nbfite = 1
            elseif ( etatpe.ge.51 .and. etatpe.le.52 ) then
              nbfipy = -1
              nbfite = 10
            else
              nbfipy = -1
              nbfite = -1
            endif
            if ( nbfipy.ge.0 ) then
              write (ulecr,45050) mess14(langst,3,5)
              do 3255 , jaux = 0 , nbfipy
                kaux = filspy+jaux
                write (ulecr,45080) kaux, npyrca(kaux)
 3255         continue
            endif
            if ( nbfite.gt.0 ) then
              write (ulecr,45050) mess14(langst,3,3)
              do 3256 , jaux = 0 , nbfite
                kaux = filste+jaux
                if ( kaux.ne.letetr ) then
                  write (ulecr,45080) kaux, ntetca(kaux)
                endif
 3256         continue
            endif
          endif
c
        endif
c
c 3.2.6. ==> les volumes voisins
c
        if ( letetr.le.nbtecf ) then
c
c 3.2.6.1. ==> on commence par dresser la liste de tous les tetraedres
c              qui bordent les faces du tetraedre courant mais qui ne
c              peuvent pas etre consideres comme des volumes voisins :
c              lui-meme et ses fils dans les cas de conformite en 2 et
c              2 fois 2.
c
          iaux = 1
          volint(1,iaux) = letetr
          if ( etat01.ge.21 .and. etat01.le.26 ) then
            iaux = iaux + 1
            volint(1,iaux) = filtet(letetr)
            iaux = iaux + 1
            volint(1,iaux) = filtet(letetr) + 1
          elseif ( etat01.ge.45 .and. etat01.le.47 ) then
            iaux = iaux + 1
            volint(1,iaux) = filtet(letetr)
            iaux = iaux + 1
            volint(1,iaux) = filtet(letetr) + 1
            iaux = iaux + 1
            volint(1,iaux) = filtet(letetr) + 2
            iaux = iaux + 1
            volint(1,iaux) = filtet(letetr) + 3
          endif
          volint(1,0) = iaux
          volint(2,0) = 0
          volint(3,0) = 0
          volint(4,0) = 0
c
c 3.2.6.2. ==> liste des faces a examiner
c
          nbface = 0
c
          do 3262 , iaux = 1 , 4
            if ( voltri(2,tritet(letetr,iaux)).ne.0 ) then
              nbface = nbface + 1
              trav2a(nbface) = tritet(letetr,iaux)
            endif
 3262    continue
c
c 3.2.6.3. ==> impression
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFOVO', nompro
#endif
          iaux = 40
          kaux = ulecr
          call infovo ( iaux, 1, nbface, volint,
     >                  voltri, pypetr,
     >                  volqua, pypequ,
     >                  hettet, hetpyr, hethex, hetpen,
     >                  trav1a, trav2a,
     >                  kaux,
     >                  ulsort, langue, codret )
c
        endif
c
c 3.2.7. ==> le centre de gravite
c
        do 327 , iaux = 1 , sdim
          vn(iaux) = unsqu * ( coonoe(listso(1),iaux) +
     >                         coonoe(listso(2),iaux) +
     >                         coonoe(listso(3),iaux) +
     >                         coonoe(listso(4),iaux) )
  327   continue
c
        write (ulecr,49003) (vn(iaux), iaux = 1 , sdim)
c
c 3.2.8. ==> volume, qualite et diametre
c
        call utqtet ( letetr, qualit, qualij, volume,
     >                coonoe, somare, aretri,
     >                tritet, cotrte, aretet )
c
        write (ulecr,49030) volume
c
        write (ulecr,49143) qualit
c
        write (ulecr,49041) qualij
c
        call utdtet ( letetr, diamet,
     >                coonoe, somare, aretri,
     >                tritet, cotrte, aretet )
c
        write (ulecr,49050) diamet
c
c 3.2.9. ==> les valeurs des fonctions
c
        if ( nbpafo.ne.0 .and. numcal.ne.0 ) then
c
          if ( degre.eq.1 ) then
            iaux = edtet4
          else
            iaux = edte10
          endif
          jaux = ntetcs(numcal)
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
     >  '* Tetraedre numero :',i10,   ' dans HOMARD                  *')
c
41000 format(
     >  '* . C''est un tetraedre du maillage initial.                 ',
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
