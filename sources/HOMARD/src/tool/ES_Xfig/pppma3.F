      subroutine pppma3 ( nbtrvi, nbquvi,
     >                    nntrvi, nnquvi,
     >                    coopro,
     >                    posini, xyzfac, tabaux, nivsup,
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
c     Post-Processeur - Preparation du MAillage - phase 3
c     -    -            -              --               -
c ______________________________________________________________________
c
c but : recherche de l'ordre d'affichage des faces pour les cacher
c
c       par defaut, on affiche les objets vus par l'observateur avec
c       l'axe (oz+) dans l'oeil, donc regardant de z>0 vers z<0.
c       on utilise l'algorithme dit du peintre, ou encore du z-buffer
c       utilise par les affichages graphiques standards, consistant a
c       imprimer les objets dans l'ordre inverse de leur eloignement,
c       i.e. a imprimer en dernier, et donc par dessus le reste, les
c       objets les plus proches. (donc avec les z les plus grands)
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbtrvi . e   .   1    . nombre triangles visualisables             .
c . nbquvi . e   .   1    . nombre de quadrangles visualisables        .
c . nntrvi . e   .10nbtrvi. 1 : niveau du triangle a afficher          .
c .        .     .        . 2 : numero HOMARD du triangle              .
c .        .     .        . 3, 4, 5 : numeros des noeuds p1            .
c .        .     .        . 6 : famille du triangle                    .
c .        .     .        . 7, 8, 9 : numeros des noeuds p2            .
c .        .     .        . 10 : numero du noeud interne               .
c . nnquvi . e   .12nbquvi. 1 : niveau du quadrangle a afficher        .
c .        .     .        . 2 : numero HOMARD du quadrangle            .
c .        .     .        . 3, 4, 5, 6 : numeros des noeuds p1         .
c .        .     .        . 7 : famille du quadrangle                  .
c .        .     .        . 8, 9, 10, 11 : numeros des noeuds p2       .
c .        .     .        . 12 : numero du noeud interne               .
c . coopro . e   .   3*   . coordonnees projetees de :                 .
c .        .     .nbnot+12. le triedre : -8:O ; -9:I ; -10:J ; -11:K   .
c .        .     .        . la fenetre de zoom : de -7 a 0 en 3D ou    .
c .        .     .        .                      de -3 a 0 en 2D       .
c .        .     .        . les noeuds de 1 a nbnoto                   .
c . posini . aux . nbquvi . tableau auxiliaire de renumerotation des   .
c .        .     .+nbtrvi . faces en fonction de l'affichage           .
c . xyzfac .  /  .nbtrvi+ . tableau de travail reel                    .
c .        .     .nbtrvi,9.                                            .
c . tabaux . aux . nbquvi . tableau auxiliaire                         .
c .        .     .+nbtrvi .                                            .
c . nivsup . e   .   1    . niveau superieur present dans le maillage  .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c ._____________________________________________________________________
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
      parameter ( nompro = 'PPPMA3' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "envca1.h"
#include "nombno.h"
c
c 0.3. ==> arguments
c
      integer nivsup
      integer nbtrvi, nbquvi
      integer nntrvi(10,nbtrvi)
      integer nnquvi(12,nbquvi)
      integer posini(nbtrvi+nbquvi)
      integer tabaux(nbtrvi+nbquvi)
c
      double precision coopro(3,-11:nbnoto)
      double precision xyzfac(nbtrvi+nbquvi,9)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer nutrvi, nuquvi
      integer nbfavi
      integer rangfa, rangqu
      integer nbfast, nbfas0
      integer rangfd
      integer iaux, jaux
c
      double precision daux
      double precision borne
      double precision xminfa, xmaxfa
      double precision yminfa, ymaxfa
      double precision zminfa, zmaxfa
      double precision coface(2,3)
      double precision v1(3), v2(3), v3(3)
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c
      data borne / 1.d-8 /
c
c 0.5. ==> initialisations
c_______________________________________________________________________
c
c====
c 1. prealables
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbtrvi', nbtrvi
      write (ulsort,90002) 'nbquvi', nbquvi
      write (ulsort,90002) 'sdim  ', sdim
      write (ulsort,90002) 'nivsup', nivsup
#endif
c
      codret = 0
c
c====
c 2. En dimension 2, les faces sont reclassses par niveau croissant
c    A la fin de cette etape, posini(1) contient l'indice de la face a
c    tracer en premier, parce que la plus loin, posini(2) contient
c    l'indice de la suivante a tracer et ainsi de suite, jusqu'a
c    posini(nbfavi) qui contient l'indice de la derniere face
c    a tracer parce que la plus proche de l'observateur.
c    Attention : posini ne contient pas les numeros des faces mais une
c    indirection dans la liste des faces a traiter.
c====
cgn      do 34 , jaux = 1 , nbnoto
cgn        write(*,1797)jaux,(coopro(iaux,jaux),iaux=1,sdim)
cgn   34 continue
c
      if ( sdim.le.2 ) then
c
        jaux = 0
c
        do 21 , iaux = 0 , nivsup+1
c
          do 211 , nutrvi = 1 , nbtrvi
            if ( nntrvi(1,nutrvi).eq.iaux ) then
              jaux = jaux + 1
              posini(jaux) = nutrvi
            endif
  211     continue
c
          do 212 , nuquvi = 1 , nbquvi
            if ( nnquvi(1,nuquvi).eq.iaux ) then
              jaux = jaux + 1
              posini(jaux) = nbtrvi+nuquvi
            endif
  212     continue
c
   21   continue
c
c====
c 2. En dimension 3, on applique l'algorithme du z-buffer
c====
c
      else
c
c====
c 3. Calcul des dimensions extremes des faces et des vecteurs normaux
c====
c 3.1. ==> Extrema pour un triangle
c
      do 31 , nutrvi = 1 , nbtrvi
c
        xminfa = min(coopro(1,nntrvi(3,nutrvi)),
     >           coopro(1,nntrvi(4,nutrvi)),coopro(1,nntrvi(5,nutrvi)))
        xmaxfa = max(coopro(1,nntrvi(3,nutrvi)),
     >           coopro(1,nntrvi(4,nutrvi)),coopro(1,nntrvi(5,nutrvi)))
        xyzfac(nutrvi,1) = xminfa + borne * (xmaxfa - xminfa)
        xyzfac(nutrvi,2) = xmaxfa - borne * (xmaxfa - xminfa)
c
        yminfa = min(coopro(2,nntrvi(3,nutrvi)),
     >           coopro(2,nntrvi(4,nutrvi)),coopro(2,nntrvi(5,nutrvi)))
        ymaxfa = max(coopro(2,nntrvi(3,nutrvi)),
     >           coopro(2,nntrvi(4,nutrvi)),coopro(2,nntrvi(5,nutrvi)))
        xyzfac(nutrvi,3) = yminfa + borne * (ymaxfa - yminfa)
        xyzfac(nutrvi,4) = ymaxfa - borne * (ymaxfa - yminfa)
c
        zminfa = min(coopro(3,nntrvi(3,nutrvi)),
     >           coopro(3,nntrvi(4,nutrvi)),coopro(3,nntrvi(5,nutrvi)))
        zmaxfa = max(coopro(3,nntrvi(3,nutrvi)),
     >           coopro(3,nntrvi(4,nutrvi)),coopro(3,nntrvi(5,nutrvi)))
        xyzfac(nutrvi,5) = zminfa + borne * (zmaxfa - zminfa)
        xyzfac(nutrvi,6) = zmaxfa - borne * (zmaxfa - zminfa)
cgn      write(*,1798)nutrvi,(nntrvi(iaux,nutrvi),iaux=2,5),
cgn     > (xyzfac(nutrvi,iaux),iaux=1,6)
c
   31 continue
c
c 3.2. ==> Extrema pour un quadrangle
c
      do 32 , nuquvi = 1 , nbquvi
c
        xminfa = coopro(1,nnquvi(3,nuquvi))
        xmaxfa = xminfa
        yminfa = coopro(2,nnquvi(3,nuquvi))
        ymaxfa = yminfa
        zminfa = coopro(3,nnquvi(3,nuquvi))
        zmaxfa = zminfa
        do 321 , iaux = 4 , 6
          daux = coopro(1,nnquvi(iaux,nuquvi))
          xminfa = min ( daux , xminfa )
          xmaxfa = max ( daux , xmaxfa )
          daux = coopro(2,nnquvi(iaux,nuquvi))
          yminfa = min ( daux , yminfa )
          ymaxfa = max ( daux , ymaxfa )
          daux = coopro(3,nnquvi(iaux,nuquvi))
          zminfa = min ( daux , zminfa )
          zmaxfa = max ( daux , zmaxfa )
  321   continue
        rangfa = nbtrvi+nuquvi
        xyzfac(rangfa,1) = xminfa + borne * (xmaxfa - xminfa)
        xyzfac(rangfa,2) = xmaxfa - borne * (xmaxfa - xminfa)
        xyzfac(rangfa,3) = yminfa + borne * (ymaxfa - yminfa)
        xyzfac(rangfa,4) = ymaxfa - borne * (ymaxfa - yminfa)
        xyzfac(rangfa,5) = zminfa + borne * (zmaxfa - zminfa)
        xyzfac(rangfa,6) = zmaxfa - borne * (zmaxfa - zminfa)
cgn      write(*,1799)nuquvi,(nnquvi(iaux,nuquvi),iaux=2,6),
cgn     > (xyzfac(nuquvi,iaux),iaux=1,6)
c
   32 continue
c
c 3.3. ==> Vecteurs normaux
c
      nbfavi = nbtrvi + nbquvi
cgn      write (ulsort,1795) 'nbfavi', nbfavi
      do 33 , rangfa = 1 , nbfavi
c
        if ( rangfa.le.nbtrvi ) then
          v1(1) = coopro(1,nntrvi(3,rangfa))
          v1(2) = coopro(2,nntrvi(3,rangfa))
          v1(3) = coopro(3,nntrvi(3,rangfa))
          v2(1) = coopro(1,nntrvi(4,rangfa))
          v2(2) = coopro(2,nntrvi(4,rangfa))
          v2(3) = coopro(3,nntrvi(4,rangfa))
          v3(1) = coopro(1,nntrvi(5,rangfa))
          v3(2) = coopro(2,nntrvi(5,rangfa))
          v3(3) = coopro(3,nntrvi(5,rangfa))
        else
          rangqu = rangfa - nbtrvi
          v1(1) = coopro(1,nnquvi(3,rangqu))
          v1(2) = coopro(2,nnquvi(3,rangqu))
          v1(3) = coopro(3,nnquvi(3,rangqu))
          v2(1) = coopro(1,nnquvi(4,rangqu))
          v2(2) = coopro(2,nnquvi(4,rangqu))
          v2(3) = coopro(3,nnquvi(4,rangqu))
          v3(1) = coopro(1,nnquvi(5,rangqu))
          v3(2) = coopro(2,nnquvi(5,rangqu))
          v3(3) = coopro(3,nnquvi(5,rangqu))
        endif
cgn          write(*,1796)'v1',v1
cgn          write(*,1796)'v2',v2
cgn          write(*,1796)'v3',v3
c
        coface(1,1) = v2(1) - v1(1)
        coface(1,2) = v2(2) - v1(2)
        coface(1,3) = v2(3) - v1(3)
        coface(2,1) = v3(1) - v1(1)
        coface(2,2) = v3(2) - v1(2)
        coface(2,3) = v3(3) - v1(3)
cgn          write(*,1796)'v1',v1
cgn          write(*,1796)'v2',v2
cgn          write(*,1796)'v3',v3
c
        xyzfac(rangfa,7) = coface(1,2)*coface(2,3)
     >                   - coface(1,3)*coface(2,2)
        xyzfac(rangfa,8) = coface(1,3)*coface(2,1)
     >                   - coface(1,1)*coface(2,3)
        xyzfac(rangfa,9) = coface(1,1)*coface(2,2)
     >                   - coface(1,2)*coface(2,1)
cgn        write(*,1796)'normale',(xyzfac(rangfa,iaux),iaux=7,9)
c
   33 continue
c
 1795 format(3(a,' =',i5,' , '))
 1796 format(a,6f12.5)
 1797 format(i5,' *',6f12.5)
 1798 format(i4,' :',i5,' *',3i4,' *',6f12.5)
 1799 format(i4,' :',i5,' *',4i4,' *',6f12.5)
c
c====
c 4. On parcourt toutes les faces a afficher et on les range de la
c    plus eloignee a la plus proche du point de vue.
c    Groso modo, les plus proches sont avec les z les plus grands.
c    A la fin de cette etape, posini(1) contient l'indice de la face a
c    tracer en premier, parce que la plus loin, posini(2) contient
c    l'indice de la suivante a tracer et ainsi de suite, jusqu'a
c    posini(nbfavi) qui contient l'indice de la derniere face
c    a tracer parce que la plus proche de l'observateur.
c    Attention : posini ne contient pas les numeros des faces mais une
c    indirection dans la liste des faces a traiter.
c====
c
c 4.1. ==> A priori, les faces ne sont en contact avec aucune autre
c
      do 41 , rangfa = 1 , nbfavi
        tabaux(rangfa) = 0
   41 continue
c
c 4.2. ==> A priori, la 1ere face est en premiere position
c
      nbfast = 1
      posini(nbfast) = 1
      tabaux(nbfast) = 1
c
c 4.3. ==> On examine toutes les faces en ne classant que celles qui
c          ont une partie commune avec celles deja classees
c          On n'examine que les faces non encore stockees
c          On boucle jusqu'a ce qu'il n'y en ait plus
c          Role de tabaux :
c          . tabaux(i) = 1 : la face i est stockee
c          . tabaux(i) = 0 : la face i n'est pas stockee
c
      rangfd = nbfast + 1
c
  430 continue
c
cgn      write (ulsort,*) '---------- NOUVELLE SERIE ---------'
cgn      write (ulsort,1795) 'Depart avec rangfd', rangfd,'nbfast',nbfast
c
      nbfas0 = nbfast
c
      do 43 , rangfa = rangfd , nbfavi
c
        if ( codret.eq.0 ) then
c
        if ( tabaux(rangfa).eq.0 ) then
c
          iaux = rangfa
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PPPMA4', nompro
#endif
          call pppma4 ( iaux, nbfast,
     >                  nbtrvi, nbquvi,
     >                  nntrvi, nnquvi,
     >                  coopro,
     >                  posini, xyzfac, tabaux,
     >                  ulsort, langue, codret )
c
            if ( rangfa.eq.-70)  stop
        endif
c
        endif
c
   43 continue
c
c 4.4. ==> Bilan
c
        if ( codret.eq.0 ) then
c
cgn        write (ulsort,*) 'nbfas0, nbfast =', nbfas0, nbfast
cgn        if ( nbfast.eq.222 ) then
cgn         nbquvi=nbfast
cgn          goto 45
cgn        endif
c
c       . Si le nombre de faces stockees est egal au nombre de faces a
c         visualiser, c'est fini
c
cgn        write (ulsort,*) 'Bilan'
        if ( nbfast.eq.nbfavi ) then
cgn          write (ulsort,1795) 'Fin avec nbfast', nbfast
          goto 45
c
c          . Si le nombre de faces stockees a change, c'est que l'on
c            se trouve encore dans une suite de faces qui se superposent
c          . Sinon, c'est qu'il ne reste plus de faces se superposant
c            a l'une de la serie en cours. Il faut commencer une
c            autre serie.
c          Dans les deux cas, on va refaire un tour en partant de la
c          premiere face non superposee.
c
        else
cgn      do 998 , iaux = 1 , nbfavi
cgn        if ( iaux.le.nbtrvi ) then
cgn          jaux = nntrvi(2,iaux)
cgn        else
cgn          jaux = -nnquvi(2,iaux-nbtrvi)
cgn        endif
cgn        if ( tabaux(iaux).ne.0 ) then
cgn          write (*,1999) iaux,tabaux(iaux),jaux
cgn 1999 format('tabaux(',i5,') =',i5,', face',i5)
cgn        endif
cgn 998  continue
c
          do 44 , rangfa = rangfd , nbfavi
            if ( tabaux(rangfa).eq.0 ) then
              iaux = rangfa
              goto 441
            endif
   44     continue
  441     continue
          rangfd = iaux
c
cgn      write (ulsort,1795) 'nbfas0', nbfas0, 'nbfast', nbfast,
cgn     > 'rangfd', rangfd
          if ( nbfast.eq.nbfas0 ) then
cgn         write (ulsort,*) '---------- NOUVELLE SERIE ---------'
cgn         write (ulsort,*) '---------- FACE', -nnquvi(2,rangfd-nbtrvi)
            nbfast = nbfast + 1
cgn        write (ulsort,888)
cgn     > (rangfa,posini(rangfa),rangfa =1,nbtrvi+nbquvi)
cgn  888 format(5(i3,i4,' * '))
            posini(nbfast) = rangfd
            tabaux(rangfd) = 1
            rangfd = rangfd + 1
          endif
c
cgn            write (ulsort,*) 'goto 430   goto 430   goto 430'
          goto 430
c
        endif
c
        endif
c
c 4.5. ==> C'est fini
c
   45     continue
c
cgn              nbfavi=nbtrvi+nbquvi
cgn      do 999 , iaux = 1 , nbfast
cgn        if ( posini(iaux).le.nbtrvi ) then
cgn          jaux = nntrvi(2,posini(iaux))
cgn        else
cgn          jaux = -nnquvi(2,posini(iaux)-nbtrvi)
cgn        endif
cgn        write (*,*) iaux,posini(iaux),'-eme face :',jaux
cgn 999  continue
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
