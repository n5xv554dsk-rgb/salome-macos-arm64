      subroutine infono ( choix,  lenoeu,
     >                    coonoe, hetnoe, arenoe, famnoe,
     >                    nnoeho, nnoeca,
     >                    noehom,
     >                    noempo,
     >                    somare, hetare, posifa, facare,
     >                    hettri, hetqua,
     >                    hettet, hetpyr, hethex, hetpen,
     >                    nbtear, pttear, tatear,
     >                    nbhear, pthear, tahear,
     >                    nbpyar, ptpyar, tapyar,
     >                    nbpear, ptpear, tapear,
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
c   INFOrmation : NOeud
c   ----          --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . choix  . e   .  ch2   . choix                                      .
c . lenoeu . e   .   1    . numero du noeud a analyser                 .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . hetnoe . e   . nbnoto . historique de l'etat des noeuds            .
c .        .     .        . 0 pour les noeuds isoles                   .
c .        .     .        . 1 pour les sommets                         .
c .        .     .        . 2 pour les noeuds milieux                  .
c .        .     .        . 3 pour les noeuds support de maille-point  .
c .        .     .        . 4 pour les noeuds internes aux mailles     .
c .        .     .        . 7 pour les noeuds n'appartenant qu'a des   .
c .        .     .        .   elements ignores                         .
c . arenoe . e   . nbnoto . arete liee a un nouveau noeud              .
c . famnoe . e   . nbnoto . famille des noeuds                         .
c . nnoeho . e   . renoac . numero des noeuds dans HOMARD              .
c . nnoeca . e   .   *    . numero des noeuds du code de calcul        .
c . nnoecs . e   .   *    . nro des noeuds du calcul pour la solution  .
c . noehom . e   . nbnoto . liste etendue des correspondances          .
c . noempo . e   . nbmpto . numeros des noeuds associes aux mailles    .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . posifa . e   . nbarto . pointeur sur tableau facare                .
c . facare . e   . nbfaar . liste des faces contenant une arete        .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . hettet . e   . nbteto . historique de l'etat des tetraedres        .
c . hetpyr . e   . nbpyto . historique de l'etat des pyramides         .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . hetpen . e   . nbpeto . historique de l'etat des pentaedres        .
c . nbtear . e   .    1   . nombre de tetraedres voisins d'aretes      .
c . pttear . e   .0:nbarto. nombre de tetraedres voisins par aretes    .
c . tatear . e   . nbtear . tetraedres voisins par aretes              .
c . nbhear . e   .    1   . nombre d'hexaedres voisins d'aretes        .
c . pthear . e   .0:nbarto. nombre d'hexaedres voisins par aretes      .
c . tahear . e   . nbhear . hexaedres voisins par aretes               .
c . nbpyar . e   .    1   . nombre de pyramides voisines d'aretes      .
c . ptpyar . e   .0:nbarto. nombre de pyramides voisines par aretes    .
c . tapyar . e   . nbpyar . pyramides voisines par aretes              .
c . nbpear . e   .    1   . nombre de pentaedres voisins d'aretes      .
c . ptpear . e   .0:nbarto. nombre de pentaedres voisins par aretes    .
c . tapear . e   . nbpear . pentaedres voisins par aretes              .
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
      parameter ( nompro = 'INFONO' )
c
#include "nblang.h"
#include "tbdim0.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "inmess.h"
c
#include "nomber.h"
#include "nombno.h"
#include "nombmp.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombpy.h"
#include "nombhe.h"
#include "nombpe.h"
#include "envca1.h"
#include "envada.h"
c
c 0.3. ==> arguments
c
      character*2 choix
c
      integer lenoeu
c
      integer hetnoe(nbnoto), arenoe(nbnoto), famnoe(nbnoto)
      integer nnoeho(renoac), nnoeca(renoto)
      integer noehom(nbnoto)
      integer noempo(nbmpto)
      integer somare(2,nbarto), hetare(nbarto)
      integer posifa(0:nbarto), facare(nbfaar)
      integer hettri(nbtrto)
      integer hetqua(nbquto)
      integer hettet(nbteto)
      integer hetpyr(nbpyto)
      integer hethex(nbheto)
      integer hetpen(nbpeto)
c
      integer nbtear, pttear(0:nbarto), tatear(nbtear)
      integer nbhear, pthear(0:nbarto), tahear(nbhear)
      integer nbpyar, ptpyar(0:nbarto), tapyar(nbpyar)
      integer nbpear, ptpear(0:nbarto), tapear(nbpear)
c
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
      integer iaux, jaux, kaux
      integer iaux1
      integer kdeb, kfin
      integer numcal
      integer nbares, nbfacm, nbfam1, nbface
      integer etat00, etat01
      integer larete, laretm, sommde, sommfi
      integer laface
      integer uldeb, ulfin, ulpas, ulecr
c
      integer trav1a(tbdim), trav2a(tbdim)
c
      logical logaux
c
      character*20 taux20
      character*40 taux40
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
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
c 1. initialisation
c====
c
      if ( choix.eq.'NO' ) then
        iaux = lenoeu
        if ( lenoeu.gt.0 .and. lenoeu.le.renoto ) then
          lenoeu = nnoeho(iaux)
        else
          lenoeu = 0
        endif
      endif
c
c====
c 2. reponses
c====
c
      do 30 , ulecr = uldeb , ulfin, ulpas
c
      write (ulecr,40000)
c
c 2.1. ==> numero de noeud impossible
c
      if ( lenoeu.le.0 .or. lenoeu.gt.nbnoto ) then
c
        if ( choix.eq.'NO' ) then
          write (ulecr,40012) iaux
        else
          write (ulecr,40022) lenoeu
        endif
        write (ulecr,40030)
c
c 2.2. ==> numero de noeud correct
c
      else
c
        numcal = nnoeca(lenoeu)
        write (ulecr,40022) lenoeu
        write (ulecr,40012) numcal
c
c 2.2.1. ==> maillage initial ?
c            Dans le maillage initial on a dans cet ordre (cf. vcmnoe) :
c            . les eventuels isoles
c            . les supports de maille-points
c            . les p1
c            . les p2
c
c            En degre 1 : son numero est inferieur au nombre de noeuds
c                         du macro-maillage
c            En degre 2 :
c              Si le noeud etait sommet dans le macro-maillage, son
c              numero est inferieur au nombre de noeuds du
c              macro-maillage moins l enombre d'
c
        logaux = .false.
        if ( degre.eq.1 ) then
          if ( lenoeu.le.nbnoma ) then
            logaux = .true.
          endif
        else
          if ( lenoeu.le.nbnoma ) then
            logaux = .true.
          endif
        endif
        if ( logaux ) then
          write (ulecr,41000)
        endif
c
c 2.2.2. ==> famille
c
        write (ulecr,42000) famnoe(lenoeu)
c
c 2.2.3. ==> coordonnees
c
        write (ulecr,43000) coonoe(lenoeu,1)
        if ( sdim.ge.2 ) then
          write (ulecr,43010) 'y', coonoe(lenoeu,2)
          if ( sdim.eq.3 ) then
            write (ulecr,43010) 'z', coonoe(lenoeu,3)
          endif
        endif
c
c 2.2.4. ==> etat : isole, element ignore, maille-point,
c                   sommet ou milieu d'arete
c
        etat01 = mod(hetnoe(lenoeu),10)
        etat00 = (hetnoe(lenoeu)-etat01) / 10
c
        taux40 = textno(etat01)
        write (ulecr,44010)
        write (ulecr,40001) taux40
        if ( nbiter.ge.1 ) then
          taux40 = textno(etat00)
          write (ulecr,44020)
          write (ulecr,40001) taux40
        endif
c
c 2.2.5. ==> mailles-points
c            remarque : si le noeud est un support pour une maille-point
c            on n'a pas d'autre solution pour le savoir que d'explorer
c            la liste de ces mailles, car le tableau reciproque n'existe
c            pas. Mais comme generalement le nombre de telles mailles
c            est tres faible, voire nul, ce n'est pas une operation
c            couteuse.
c
        if ( nbmpto.gt.0 ) then
c
          do 251 , iaux = 1 , nbmpto
            if ( noempo(iaux).eq.lenoeu ) then
              write (ulecr,45000) iaux
            endif
  251     continue
c
        endif
c
c 2.2.6. ==> aretes
c 2.2.6.1 ==> dont le noeud est milieu
c
        if ( ( etat01.eq.1 .and. lenoeu.gt.nbnoma ) .or.
     >         etat01.eq.2 ) then
          laretm = arenoe(lenoeu)
          if ( laretm.gt.0 ) then
            sommde = somare(1,laretm)
            sommfi = somare(2,laretm)
            taux20 = textar(mod(hetare(laretm),10))(1:20)
            write (ulecr,46010)
            write (ulecr,46021) laretm, sommde, sommfi, taux20
          endif
        else
          laretm = 0
        endif
c
c 2.2.6.2 ==> dont le noeud est extremite
c
        iaux = 0
        jaux = 0
c       on range dans trav2a les aretes qui demarrent sur ce noeud
c       on range dans trav1a les aretes qui finissent a ce noeud
        do 2261 , kaux = 1 , nbarto
          if ( somare(1,kaux).eq.lenoeu ) then
            jaux = jaux + 1
#include "tbdim3.h"
            trav2a(jaux) = kaux
          elseif ( somare(2,kaux).eq.lenoeu ) then
            iaux = iaux + 1
#include "tbdim2.h"
            trav1a(iaux) = kaux
          endif
 2261   continue
c
c       on imprime d'abord les aretes qui finissent a ce noeud (trav1a)
c       puis celles qui finissent a ce noeud (trav2a) que l'on inclut
c       dans trav1a
        if ( iaux+jaux.ne.0 ) then
          write (ulecr,46020)
          do 2262 , kaux = 1 , iaux
            larete = trav1a(kaux)
            sommde = somare(1,larete)
            taux20 = textar(mod(hetare(larete),10))(1:20)
            write (ulecr,46021) larete, sommde, lenoeu, taux20
 2262     continue
          do 2263 , kaux = 1 , jaux
            larete = trav2a(kaux)
            sommfi = somare(2,larete)
            taux20 = textar(mod(hetare(larete),10))(1:20)
            write (ulecr,46021) larete, lenoeu, sommfi, taux20
            iaux = iaux + 1
#include "tbdim2.h"
            trav1a(iaux) = larete
 2263     continue
        endif
c
c       nbares est le nombre total d'aretes ayant ce noeud pour sommet
        nbares = iaux
c
c 2.2.7. ==> les faces
c 2.2.7.1. ==> dont le noeud est le milieu d'un cote
c
        iaux = 0
c
        if ( laretm.ne.0 ) then
c
          kdeb = posifa(laretm-1)+1
          kfin = posifa(laretm)
          if ( kfin.ge.kdeb ) then
            write (ulecr,47010)
            do 2271 , kaux = kdeb , kfin
              laface = facare(kaux)
              if ( laface.gt.0 ) then
                taux40 = texttr(mod(hettri(laface),10))
              else
                taux40 = textqu(mod(hetqua(-laface),100))
              endif
              write (ulecr,47030) laface, taux40
              iaux = iaux + 1
#include "tbdim2.h"
              trav2a(iaux) = laface
 2271       continue
          endif
c
        endif
c
        nbfacm = iaux
        nbface = nbfacm
        nbfam1 = nbfacm + 1
c
c 2.2.7.2. ==> dont le noeud est l'un des sommets
c         trav1a de 1 a nbares = liste des nbares aretes dont le noeud
c         est sommet
c         trav2a de nbfacm+1 a nbface = liste des nbface-nbfacm faces
c         dont le noeud est sommet, en evitant les doublons
c         remarque : on repere d'abord s'il existe au moins une face
c                    dont le noeud est sommet, pour ne pas imprimer
c                    des en-tetes pour rien.
c
        if ( nbares.ne.0 ) then
c
          jaux = 0
          do 2272 , iaux1 = 1 , nbares
            larete = trav1a(iaux1)
            kdeb = posifa(larete-1)+1
            kfin = posifa(larete)
            if ( kfin.ge.kdeb ) then
              jaux = 1
              goto 2273
            endif
 2272     continue
 2273     continue
c
          if ( jaux.ne.0 ) then
c
            do 2274 , iaux1 = 1 , nbares
              larete = trav1a(iaux1)
              kdeb = posifa(larete-1)+1
              kfin = posifa(larete)
              do 2275 , kaux = kdeb , kfin
                laface = facare(kaux)
                do 2276 , jaux = nbfam1 , nbface
                  if ( laface.eq.trav2a(jaux) ) then
                    goto 2277
                  endif
 2276           continue
                nbface = nbface + 1
                iaux = nbface
#include "tbdim2.h"
                trav2a(iaux) = laface
 2277           continue
 2275         continue
 2274       continue
c
            write (ulecr,47020)
            do 2278 , iaux1 = nbfam1 , nbface
              laface = trav2a(iaux1)
              if ( laface.gt.0 ) then
                taux40 = texttr(mod(hettri(laface),10))
              else
                taux40 = textqu(mod(hetqua(-laface),100))
              endif
              write (ulecr,47030) laface, taux40
 2278       continue
c
          endif
c
        endif
c
c 2.2.8. ==> les voisins volumiques
c
        if ( nbteto.ne.0 .or. nbheto.ne.0 .or.
     >       nbpyto.ne.0 .or. nbpeto.ne.0 ) then
c
c 2.2.8.1. ==> dont le noeud est le milieu d'un cote
c
          if ( laretm.ne.0 ) then
c
            iaux = 30
            kaux = ulecr
            trav2a(1) = laretm
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFOVA - milieu', nompro
#endif
            call infova ( iaux, 1, trav2a,
     >                    nbtear, pttear, tatear,
     >                    nbhear, pthear, tahear,
     >                    nbpyar, ptpyar, tapyar,
     >                    nbpear, ptpear, tapear,
     >                    hettet, hetpyr, hethex, hetpen,
     >                    kaux,
     >                    ulsort, langue, codret )
c
          endif
c
c 2.2.8.2. ==> dont le noeud est l'un des sommets
c
          iaux = 20
          kaux = ulecr
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFOVA - sommets', nompro
#endif
          call infova ( iaux, nbares, trav1a,
     >                  nbtear, pttear, tatear,
     >                  nbhear, pthear, tahear,
     >                  nbpyar, ptpyar, tapyar,
     >                  nbpear, ptpear, tapear,
     >                  hettet, hetpyr, hethex, hetpen,
     >                  kaux,
     >                  ulsort, langue, codret )
c
        endif
c
c 2.2.9. les homologues
c
        if ( homolo.ne.0 ) then
c
          if ( noehom(lenoeu).ne.0 ) then
            if ( noehom(lenoeu).eq.lenoeu ) then
              write (ulecr,48010)
            else
              if ( noehom(lenoeu).ge.0 ) then
                iaux = 2
              else
                iaux = 1
              endif
              write (ulecr,48020) iaux
              write (ulecr,48022) abs(noehom(lenoeu))
            endif
          endif
c
        endif
c
c 2.2.10. ==> les valeurs des fonctions
c
        if ( nbpafo.ne.0 ) then
c
          iaux = 0
          jaux = numcal
          kaux = ulecr
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFOPF-sommet', nompro
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
c 3. formats
c===
c
40012 format(
     >  '*  Noeud numero :',i10,   ' dans le calcul                  *')
40022 format(
     >  '*  Noeud numero :',i10,   ' dans HOMARD                     *')
40032 format(
     >  '*  Noeud numero :',i10,   ' dans HOMARD                     *',
     >/,'*  Noeud numero :',i10,   ' dans le calcul                  *')
c
41000 format(
     >  '* . C''est un noeud du maillage initial.                     ',
     >  '*')
c
43000 format(
     >  '* . Coordonnees :                                           *',
     >/,'*   x = ', d24.15,             '                            *')
43010 format(
     >'*   ',a1,' = ', d24.15,          '                            *')
c
45000 format(
     >  '* . Il est le support de la maille-point ',i10,   '         *')
c
46010 format(
     >  '* . Il est le milieu d''une arete :                          ',
     >  '*')
46020 format(
     >  '* . Il est une extremite pour des aretes :                  *')
46021 format(
     >  '*',i10,   ' de',i10,   ' a ',i10,   ' : ',a20,             '*')
c
47010 format(
     >  '* . Il est le milieu d''un cote de faces :                   ',
     >  '*')
47020 format(
     >  '* . Il est un sommet pour des faces :                       *')
47030 format(
     >  '* ',i10,   ' : ',a40,                                 '     *')
c
c====
c 4. La fin
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
