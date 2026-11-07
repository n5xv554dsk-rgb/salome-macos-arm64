      subroutine pppma4 ( rangfa, nbfast,
     >                    nbtrvi, nbquvi,
     >                    nntrvi, nnquvi,
     >                    coopro,
     >                    posini, xyzfac, tabaux,
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
c     Post-Processeur - Preparation du MAillage - phase 4
c     -    -            -              --               -
c ______________________________________________________________________
c
c On place la rangfa-ieme face par rapport aux autres
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . rangfa . e   .   1    . rang dans la liste initiale de la face a   .
c .        .     .        . classer                                    .
c . nbfast . es  .   1    . nombre de faces deja classees              .
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
c . coopro . e   .  sdim* . coordonnees projetees de :                 .
c .        .     .nbnot+12. le triedre : -8:O ; -9:I ; -10:J ; -11:K   .
c .        .     .        . la fenetre de zoom : de -7 a 0 en 3D ou    .
c .        .     .        .                      de -3 a 0 en 2D       .
c .        .     .        . les noeuds de 1 a nbnoto                   .
c . posini . aux . nbquvi . tableau auxiliaire de renumerotation des   .
c .        .     .+nbtrvi . faces en fonction de l'affichage           .
c . xyzfac .  e  .nbtrvi+ . coordonnees des noeuds des faces           .
c .        .     .nbtrvi,9.                                            .
c . tabaux . e/s . nbquvi . tabaux(i) = 1 : la face i est stockee      .
c .        .     .+nbtrvi . tabaux(i) = 0 : la face i n'est pas stockee.
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
      parameter ( nompro = 'PPPMA4' )
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
      integer rangfa, nbfast
      integer nbtrvi, nbquvi
      integer nntrvi(10,nbtrvi)
      integer nnquvi(12,nbquvi)
      integer posini(nbtrvi+nbquvi)
      integer tabaux(nbtrvi+nbquvi)
c
      double precision coopro(sdim,-11:nbnoto)
      double precision xyzfac(nbtrvi+nbquvi,9)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer indpos, lerang
      integer numfac, rangqu
      integer nufast, rgfast, rgqust
      integer nbnfac, nbnfst
      integer iaux, jaux
      integer glop, glop1
c
      double precision daux
      double precision dzmini
      double precision xminfa, xmaxfa
      double precision yminfa, ymaxfa
      double precision zvuefa, zvuefs
      double precision v1(3), v2(3), v3(3), v4(3)
      double precision w1(3), w2(3), w3(3), w4(3), wn(2)
c
      logical prem
      logical dedans
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
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
#ifdef _DEBUG_HOMARD_
cgn      write (ulsort,1795) '. nbtrvi', nbtrvi, 'nbquvi', nbquvi
      write (ulsort,1795) '. rangfa', rangfa, 'nbfast', nbfast
#endif
c
      dzmini = 1.0d-4
c
      codret = 0
c
 1794 format(3(a,' =',f12.5,' , '))
 1795 format(3(a,' =',i5,' , '))
 1796 format(a,6f12.5)
 1797 format(i5,' *',6f12.5)
c
c 1.2. ==> Caracteristiques
c
      if ( rangfa.gt.nbtrvi ) then
        rangqu = rangfa - nbtrvi
      endif
      if ( rangfa.le.nbtrvi ) then
        numfac = nntrvi(2,rangfa)
      else
        numfac = -nnquvi(2,rangqu)
      endif
c
c 1.3. ==> A priori, on va mettre la face devant toutes les autres
c
      lerang = nbfast + 1
c
c====
c 2. On commence par s'assurer que la face a classer n'est pas
c    parallele a l'axe de vision. Si c'est le cas, on la range dans la
c    place la plus eloignee car l'ordre d'affichage n'a pas
c    d'importance : on ne verra qu'une tranche !
c====
c
      daux = sqrt( abs(xyzfac(rangfa,7))**2
     >     +       abs(xyzfac(rangfa,8))**2
     >     +       abs(xyzfac(rangfa,9))**2 )
      if ( abs(xyzfac(rangfa,9))/daux.le.dzmini ) then
cgn        write(*,*)'rang',rangfa,', face',numfac
cgn        write(*,1794)'Nx',xyzfac(rangfa,7),'Ny',xyzfac(rangfa,8),
cgn     >               'Nz',xyzfac(rangfa,9)
cgn        write(*,1794)'norme',daux,
cgn     >               'Nz/norme',abs(xyzfac(rangfa,9))/daux
cgn        write(*,*)'La face a classer est parallele a la vision'
        tabaux(rangfa) = 1
        lerang = 1
        goto 50
      endif
c
c====
c 3. Suite des caracteristiques
c====
c
      prem = .true.
c
      xminfa = xyzfac(rangfa,1)
      xmaxfa = xyzfac(rangfa,2)
      yminfa = xyzfac(rangfa,3)
      ymaxfa = xyzfac(rangfa,4)
c
      glop = 0
cgn      if ( numfac.eq.-25 .or. numfac.eq.-21 ) then
cgn        glop = 1
cgn      endif
      if ( glop.ne.0) then
      write(*,*)'*************************************************'
      write(*,*)'Examen de la face',numfac,' (rangfa =', rangfa,')'
      endif
      if ( glop.ne.0 ) then
        write(*,*)'....... Face a classer',numfac,' ==> noeuds :'
        if ( rangfa.le.nbtrvi ) then
          jaux = nntrvi(3,rangfa)
          write(*,1797) jaux, (coopro(iaux,jaux),iaux=1,3)
          jaux = nntrvi(4,rangfa)
          write(*,1797) jaux, (coopro(iaux,jaux),iaux=1,3)
          jaux = nntrvi(5,rangfa)
          write(*,1797) jaux, (coopro(iaux,jaux),iaux=1,3)
        else
          jaux = nnquvi(3,rangqu)
          write(*,1797) jaux, (coopro(iaux,jaux),iaux=1,3)
          jaux = nnquvi(4,rangqu)
          write(*,1797) jaux, (coopro(iaux,jaux),iaux=1,3)
          jaux = nnquvi(5,rangqu)
          write(*,1797) jaux, (coopro(iaux,jaux),iaux=1,3)
          jaux = nnquvi(6,rangqu)
          write(*,1797) jaux, (coopro(iaux,jaux),iaux=1,3)
        endif
        write(*,1796)'normale',(xyzfac(rangfa,iaux),iaux=7,9)
      endif
c
c====
c 4. On parcourt toutes les faces deja stockees
c    posini(indpos) est la position de la indpos-eme face stockee,
c    dans la suite generale des faces a visualiser.
c    . Si posini(indpos) est inferieur a nbtrvi, c'est que la face
c    stockee est un triangle. Son indice dans les triangles a tracer
c    est posini(indpos).
c    . Si posini(indpos) est superieur a nbtrvi, c'est un quadrangle
c    dont l'indice dans les quadrangles est posini(indpos)-nbtrvi
c    Attention a ne pas comparer une face a elle-meme ! Cela peut
c    arriver quand on fait une seconde passe pour replacer une face
c    qui n'avait aucun point commun avec les autres.
c====
c
      do 40 , indpos = 1 , nbfast
c
c 4.1. ==> caracteristique de la face stockee
c
        rgfast = posini(indpos)
c
        if ( rgfast.eq.rangfa ) then
          if ( glop.ne.0 ) then
            write(*,*)'Ne pas tester une face par rapport a elle-meme'
          endif
          goto 40
        endif
        if ( rgfast.le.nbtrvi ) then
          nufast = nntrvi(2,rgfast)
        else
          rgqust = rgfast - nbtrvi
          nufast = -nnquvi(2,rgqust)
        endif
        glop1 = 0
cgn          if ( nufast.eq.2098 ) then
cgn            glop1 = 1
cgn          endif
        if ( glop.ne.0 .or. glop1.ne.0 ) then
          write(*,*)'.... Face stockee', nufast,', (rang',rgfast,')'
        endif
c
c 4.2. ==> On commence par s'assurer que la face stockee n'est pas
c          parallele a l'axe de vision. Si c'est le cas, leur ordre
c          de trace relatif n'a aucune importance. On passe donc a la
c          face stockee suivante.
c
        daux = sqrt( abs(xyzfac(rgfast,7))**2
     >       +       abs(xyzfac(rgfast,8))**2
     >       +       abs(xyzfac(rgfast,9))**2 )
        if ( abs(xyzfac(rgfast,9))/daux.le.dzmini ) then
          if ( glop.ne.0 .or. glop1.ne.0 ) then
            write(*,1794)'Nx',xyzfac(rgfast,7),'Ny',xyzfac(rgfast,8),
     >                   'Nz',xyzfac(rgfast,9)
            write(*,1794)'norme',daux,
     >                   'Nz/norme',abs(xyzfac(rgfast,9))/daux
            write(*,*)'La face stockee est parallele a la vision'
          endif
          goto 40
        endif
c
c 4.3. ==> Si le quadrangle enveloppe de la face stockee n'a pas de
c          recouvrement avec la face a classer, leur ordre de trace
c          relatif n'a aucune importance. On passe donc a la face
c          stockee suivante.
c
        if ( xyzfac(rgfast,1).ge.xmaxfa ) then
cgn          write(*,*) '==> xyzfac > xmaxfa'
          goto 40
        endif
        if ( xyzfac(rgfast,2).le.xminfa ) then
cgn          write(*,*) '==> xyzfac < xminfa'
          goto 40
        endif
        if ( xyzfac(rgfast,3).ge.ymaxfa ) then
cgn          write(*,*) '==> xyzfac > ymaxfa'
          goto 40
        endif
        if ( xyzfac(rgfast,4).le.yminfa ) then
cgn          write(*,*) '==> xyzfac < yminfa'
          goto 40
        endif
c
c 4.4. ==> Les deux quadrangles enveloppes des faces se recouvrent,
c          mais pas forcement les faces.
c          On cherche a savoir si les deux faces partagent une
c          surface non vide. C'est de la methode arlequin ;=)
c          On va chercher si un point interne a la face stockee est
c          strictement interne a la face a classer.
c          Si on en trouve un, on calculera ses distances.
c
        if ( glop.ne.0 .or. glop1.ne.0 ) then
          write(*,*)'....... Point commun aux deux faces ?'
        endif
c
c 4.4.1. ==> Transfert des coordonnees des noeuds de la face a classer
c            Remarque : on ne le fait qu'une fois
c
        if ( prem ) then
          if ( rangfa.le.nbtrvi ) then
            v1(1) = coopro(1,nntrvi(3,rangfa))
            v1(2) = coopro(2,nntrvi(3,rangfa))
            v2(1) = coopro(1,nntrvi(4,rangfa))
            v2(2) = coopro(2,nntrvi(4,rangfa))
            v3(1) = coopro(1,nntrvi(5,rangfa))
            v3(2) = coopro(2,nntrvi(5,rangfa))
            nbnfac = 3
          else
            v1(1) = coopro(1,nnquvi(3,rangqu))
            v1(2) = coopro(2,nnquvi(3,rangqu))
            v2(1) = coopro(1,nnquvi(4,rangqu))
            v2(2) = coopro(2,nnquvi(4,rangqu))
            v3(1) = coopro(1,nnquvi(5,rangqu))
            v3(2) = coopro(2,nnquvi(5,rangqu))
            v4(1) = coopro(1,nnquvi(6,rangqu))
            v4(2) = coopro(2,nnquvi(6,rangqu))
            nbnfac = 4
          endif
          prem = .false.
        endif
c
c 4.4.2. ==> Transfert des coordonnees des noeuds de la face stockee
c
        if ( rgfast.le.nbtrvi ) then
          w1(1) = coopro(1,nntrvi(3,rgfast))
          w1(2) = coopro(2,nntrvi(3,rgfast))
          w2(1) = coopro(1,nntrvi(4,rgfast))
          w2(2) = coopro(2,nntrvi(4,rgfast))
          w3(1) = coopro(1,nntrvi(5,rgfast))
          w3(2) = coopro(2,nntrvi(5,rgfast))
          nbnfst = 3
        else
          w1(1) = coopro(1,nnquvi(3,rgqust))
          w1(2) = coopro(2,nnquvi(3,rgqust))
          w2(1) = coopro(1,nnquvi(4,rgqust))
          w2(2) = coopro(2,nnquvi(4,rgqust))
          w3(1) = coopro(1,nnquvi(5,rgqust))
          w3(2) = coopro(2,nnquvi(5,rgqust))
          w4(1) = coopro(1,nnquvi(6,rgqust))
          w4(2) = coopro(2,nnquvi(6,rgqust))
          nbnfst = 4
        endif
        if ( glop1.ne.0 ) then
          write(*,*)'....... Noeuds de la face stockee'
          if ( rgfast.le.nbtrvi ) then
            write(*,1797) nntrvi(3,rgfast), (w1(iaux),iaux=1,2)
            write(*,1797) nntrvi(4,rgfast), (w2(iaux),iaux=1,2)
            write(*,1797) nntrvi(5,rgfast), (w3(iaux),iaux=1,2)
          else
            write(*,1797) nnquvi(3,rgqust), (w1(iaux),iaux=1,2)
            write(*,1797) nnquvi(4,rgqust), (w2(iaux),iaux=1,2)
            write(*,1797) nnquvi(5,rgqust), (w3(iaux),iaux=1,2)
            write(*,1797) nnquvi(6,rgqust), (w4(iaux),iaux=1,2)
          endif
          write(*,1796)'normale',(xyzfac(rgfast,iaux),iaux=7,9)
        endif
c
c 4.4.3. ==> Un point de la face a classer est-il dans la face stockee ?
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PPPMA5', nompro
#endif
        call pppma5 ( dedans, wn,
     >                nbnfst, w1, w2, w3, w4,
     >                nbnfac, v1, v2, v3, v4,
     >                ulsort, langue, codret )
c
        if ( dedans ) then
          if ( glop.ne.0 .or. glop1.ne.0 ) then
            write(*,*)'..... Un point de',numfac,' est dans', nufast
            write(*,*)'..... modif pour',numfac,', rang', rangfa
          endif
          tabaux(rangfa) = 1
          goto 457
        endif
c
c 4.4.4. ==> Un point de la face stockee est-il dans la face a classer ?
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PPPMA5', nompro
#endif
        call pppma5 ( dedans, wn,
     >                nbnfac, v1, v2, v3, v4,
     >                nbnfst, w1, w2, w3, w4,
     >                ulsort, langue, codret )
c
        if ( dedans ) then
          if ( glop.ne.0 .or. glop1.ne.0 ) then
            write(*,*)'..... Un point de', nufast,' est dans',numfac
            write(*,*)'..... modif pour',numfac,'(rangfa =', rangfa,')'
          endif
          tabaux(rangfa) = 1
          goto 457
        endif
c
        endif
c
c 4.4.5. ==> Sortie prematuree
c
        if ( codret.ne.0 ) then
          goto 59
        endif
c
c 4.4.5. ==> Si on arrive ici c'est qu'on a n'a pas reussi a mettre
c            un point dans la zone commune aux 2 faces.
c            On passe a la suite
c
        if ( glop.ne.0 .or. glop1.ne.0 ) then
          write(*,*) 'Impossible de trier les faces',numfac,' et',nufast
        endif
c              if ( glop1.ne.0 ) then
c                stop
c              endif
        goto 40
c
c 4.4.7. ==> Test des profondeurs du point vis-a-vis des 2 faces
c
  457   continue
c
c 4.4.7.1. ==> Face a classer
c
        if ( rangfa.le.nbtrvi ) then
          zvuefa = coopro(3,nntrvi(3,rangfa))
        else
          zvuefa = coopro(3,nnquvi(3,rangqu))
        endif
        zvuefa = zvuefa
     > - ( (wn(1)-v1(1))*xyzfac(rangfa,7)
     >   + (wn(2)-v1(2))*xyzfac(rangfa,8) ) / xyzfac(rangfa,9)
c
c 4.4.7.2. ==> Face stokee
c
        if ( rgfast.le.nbtrvi ) then
          zvuefs = coopro(3,nntrvi(3,rgfast))
        else
          zvuefs = coopro(3,nnquvi(3,rgqust))
        endif
        zvuefs = zvuefs
     > - ( (wn(1)-w1(1))*xyzfac(rgfast,7)
     >   + (wn(2)-w1(2))*xyzfac(rgfast,8) ) / xyzfac(rgfast,9)
c
cgn          if ( glop.ne.0 ) then
cgn            write(*,1796)'... point commun', wn
cgn            write(*,*)'....... zvuefs = ',zvuefs
cgn            write(*,*)'....... zvuefa = ',zvuefa
cgn          endif
c
c 4.4.7.3. ==> Comparaison :
c              Si la face a classer est derriere la face a stocker,
c              il faut l'inserer a cet endroit, sinon, on ne fait rien
c
        if ( zvuefa.le.zvuefs ) then
c
          lerang = indpos
          if ( glop.ne.0 ) then
          write(*,*)'La face',numfac,'est derriere la face', nufast
          endif
c
          goto 50
#ifdef _DEBUG_HOMARD_
        else
          if ( glop.ne.0 ) then
          write(*,*)'La face',nufast,'est derriere la face', numfac
          endif
#endif
c
        endif
c
   40 continue
c
      if ( tabaux(rangfa).eq.0 ) then
        if ( glop.ne.0 ) then
          write(*,*) 'Impossible de placer la face',numfac
        endif
        goto 59
      endif
c
c====
c 5. On insere la face a la position lerang
c====
c
   50 continue
c
      if ( glop.ne.0 ) then
        write(*,*) '==> On insere la face',numfac,' en', lerang
      endif
c
      nbfast = nbfast + 1
      do 51 , indpos = nbfast , lerang+1, -1
cgn        write(ulsort,*)'indpos =',indpos
        posini(indpos) = posini(indpos-1)
   51 continue
      posini(lerang) = rangfa
c
      if ( glop.ne.0 ) then
        do 501 , iaux = 1 , nbfast
          if ( posini(iaux).le.nbtrvi ) then
            jaux = nntrvi(2,posini(iaux))
          else
            jaux = -nnquvi(2,posini(iaux)-nbtrvi)
          endif
          write (*,*) iaux,posini(iaux),'-eme face :',jaux
  501   continue
      endif
c
   59 continue
c
      if ( glop.ne.0 ) then
        if ( posini(1).le.nbtrvi ) then
          iaux = nntrvi(2,posini(1))
        else
          iaux = -nnquvi(2,posini(1)-nbtrvi)
        endif
        write(*,*)'Face la plus eloignee :', iaux
        if ( posini(nbfast).le.nbtrvi ) then
          iaux = nntrvi(2,posini(nbfast))
        else
          iaux = -nnquvi(2,posini(nbfast)-nbtrvi)
        endif
        write(*,*)'Face la plus proche   :', iaux
      endif
cgn          stop
c
c====
c 6. la fin
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
