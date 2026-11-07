      subroutine utafqu ( somare, filare, a1, a2, a3, a4,
     >                    as1n1, as2n1,
     >                    as2n2, as3n2,
     >                    as3n3, as4n3,
     >                    as4n4, as1n4 )
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
c    UTilitaire - Aretes Filles - QUadrangle
c    --           -      -        --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . somare . e   .2*nbaret. numeros des extremites d'arete             .
c . filare . e   . nbaret . premiere fille des aretes                  .
c .a1,..,a4. e   . 1      . les numeros des aretes du quadrangle       .
c . asinj  .  s  . 1      . arete entre le sommet i et le milieu de    .
c .        .     .        . l'arete j du triangle                      .
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
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      integer somare(2,*), filare(*)
      integer a1, a2, a3, a4
      integer as1n1, as2n1
      integer as2n2, as3n2
      integer as3n3, as4n3
      integer as4n4, as1n4
c
c 0.4. ==> variables locales
c
      integer s1, s2, s3, s4
      integer iaux
c
c====
c 1. on cherche les numeros des sommets du quadrangle defini par ses
c====
c
cgn10000 format('arete a',i1,' :',i2,' de',i3,' a',i3)
cgn20000 format('sommet S',i1,' :',i3)
cgn      write(1,10000) 1, a1, somare(1,a1), somare(2,a1)
cgn      write(1,10000) 2, a2, somare(1,a2), somare(2,a2)
cgn      write(1,10000) 3, a3, somare(1,a3), somare(2,a3)
cgn      write(1,10000) 4, a4, somare(1,a4), somare(2,a4)
      call utsoqu ( somare, a1, a2, a3, a4,
     >              s2, s3, s4, s1 )
cgn      write(1,20000) 1, s1
cgn      write(1,20000) 2, s2
cgn      write(1,20000) 3, s3
cgn      write(1,20000) 4, s4
c
c====
c 2. Filles des aretes
c    On s'appuie sur le fait que le second noeud des aretes filles
c    de ak est, par construction, le noeud au milieu de ak.
c    Donc le premier est l'un des 2 noeuds de ak.
c====
c
cgn30000 format('arete ',a5,' :',i3,' de',i3,' a',i3)
      iaux = filare(a1)
      if ( somare(1,iaux).eq.s1 ) then
        as1n1 = iaux
        as2n1 = iaux + 1
      else
        as1n1 = iaux + 1
        as2n1 = iaux
      endif
cgn      write(1,30000) 'as2n1', as2n1, somare(1,as2n1), somare(2,as2n1)
cgn      write(1,30000) 'as3n1', as3n1, somare(1,as3n1), somare(2,as3n1)
c
      iaux = filare(a2)
      if ( somare(1,iaux).eq.s2 ) then
        as2n2 = iaux
        as3n2 = iaux + 1
      else
        as2n2 = iaux + 1
        as3n2 = iaux
      endif
cgn      write(1,30000) 'as1n2', as1n2, somare(1,as1n2), somare(2,as1n2)
cgn      write(1,30000) 'as3n2', as3n2, somare(1,as3n2), somare(2,as3n2)
c
      iaux = filare(a3)
      if ( somare(1,iaux).eq.s3 ) then
        as3n3 = iaux
        as4n3 = iaux + 1
      else
        as3n3 = iaux + 1
        as4n3 = iaux
      endif
cgn      write(1,30000) 'as1n3', as1n3, somare(1,as1n3), somare(2,as1n3)
cgn      write(1,30000) 'as2n3', as2n3, somare(1,as2n3), somare(2,as2n3)
c
      iaux = filare(a4)
      if ( somare(1,iaux).eq.s4 ) then
        as4n4 = iaux
        as1n4 = iaux + 1
      else
        as4n4 = iaux + 1
        as1n4 = iaux
      endif
cgn      write(1,30000) 'as1n3', as1n3, somare(1,as1n3), somare(2,as1n3)
cgn      write(1,30000) 'as2n3', as2n3, somare(1,as2n3), somare(2,as2n3)
c
      end
