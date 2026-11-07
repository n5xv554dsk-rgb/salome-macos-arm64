      subroutine uttfi2 ( sss, ttt,
     >                    v1, v2, v3, v4, vn )
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
c    UTilitaire - TFI - option 2
c    --           ---          -
c ______________________________________________________________________
c
c Creation d'un noeud par methode TFI a l'interieur d'un quadrangle
c programme en dimension 2
c
c         Conventions d'orientation :
c
c              4 .--------------------. 3
c                .                    .
c                .                    .
c                .                    .
c              1 .--------------------. 2
c
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . sss    . e   . 1      . abscisse curviligne selon 12/43            .
c . ttt    . e   . 1      . abscisse curviligne selon 14/23            .
c . v1     . e   .   2    . coordonnees du sommet 1 du quadrangle      .
c . v2     . e   .   2    . coordonnees du sommet 2 du quadrangle      .
c . v3     . e   .   2    . coordonnees du sommet 3 du quadrangle      .
c . v4     . e   .   2    . coordonnees du sommet 4 du quadrangle      .
c . vn     .  s  .   2    . coordonnees du noeud cree                  .
c .____________________________________________________________________.
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
cgn      character*6 nompro
cgn      parameter ( nompro = 'UTTFI2' )
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      double precision v1(2), v2(2), v3(2), v4(2), vn(2)
      double precision sss, ttt
c
c 0.4. ==> variables locales
c
      integer iaux
c
      double precision v12(2), v43(2), v14(2), v23(2)
      double precision unmsss, unmttt

c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. abscisses curvilignes
c====
c
      unmsss = 1.d0 - sss
      unmttt = 1.d0 - ttt
cgn      print 1789 ,'........ sss = ',sss
cgn      print 1789 ,'........ ttt = ',ttt
cgn      print 1789 ,'........ v1 = ',v1
cgn      print 1789 ,'........ v2 = ',v2
cgn      print 1789 ,'........ v3 = ',v3
cgn      print 1789 ,'........ v4 = ',v4
c
c====
c 2. noeuds de bord
c====
c
      do 20 , iaux = 1 , 2
c
        v12(iaux) = v1(iaux) + sss*(v2(iaux)-v1(iaux))
        v43(iaux) = v4(iaux) + sss*(v3(iaux)-v4(iaux))
        v14(iaux) = v1(iaux) + ttt*(v4(iaux)-v1(iaux))
        v23(iaux) = v2(iaux) + ttt*(v3(iaux)-v2(iaux))
c
   20 continue
cgn      print 1789,'v12 =',v12
cgn      print 1789,'v43 =',v43
cgn      print 1789,'v14 =',v14
cgn      print 1789,'v23 =',v23
cgn 1789 format(a,2g14.7)
c
c====
c 3. Calcul
c====
c
      do 30 , iaux = 1 , 2
c
        vn(iaux) = unmttt * v12(iaux)
     >           + ttt * v43(iaux)
     >           + unmsss * v14(iaux)
     >           + sss * v23(iaux)
     >           - unmsss * unmttt * v1(iaux)
     >           - unmsss * ttt * v4(iaux)
     >           - sss * unmttt * v2(iaux)
     >           - sss * ttt * v3(iaux)
c
   30 continue
cgn      print 1789 ,'........ vn = ',vn
cgn      print 1789 ,'........ pv = ',
cgn     >         vn(2)*(v4(1)-v1(1)) - vn(1)*(v4(2)-v1(2))
c
      end
