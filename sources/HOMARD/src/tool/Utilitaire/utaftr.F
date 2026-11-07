      subroutine utaftr ( somare, filare, a1, a2, a3,
     >                    as2n1, as3n1,
     >                    as3n2, as1n2,
     >                    as1n3, as2n3 )
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
c    UTilitaire - Aretes Filles - TRiangle
c    --           -      -        --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . somare . e   .2*nbaret. numeros des extremites d'arete             .
c . filare . e   . nbaret . premiere fille des aretes                  .
c .a1,a2,a3. e   . 1      . les numeros des aretes du triangle         .
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
      integer a1, a2, a3
      integer as2n1, as3n1
      integer as3n2, as1n2
      integer as1n3, as2n3
c
c 0.4. ==> variables locales
c
      integer s1, s2, s3
      integer iaux
c
c====
c 1. on cherche les numeros des sommets du triangle defini par ses
c    aretes a1, a2 et a3 avec la convention :
c    le sommet si est en face de l'arete ai
c  remarque : utsotr et utaftr sont semblables
c====
c
cgn10000 format('arete a',i1,' :',i2,' de',i3,' a',i3)
cgn20000 format('sommet S',i1,' :',i3)
cgn      write(1,10000) 1, a1, somare(1,a1), somare(2,a1)
cgn      write(1,10000) 2, a2, somare(1,a2), somare(2,a2)
cgn      write(1,10000) 3, a3, somare(1,a3), somare(2,a3)
      s1 = 0
      if ( somare(1,a1).eq.somare(1,a3) ) then
        s2 = somare(1,a1)
        s1 = somare(2,a3)
      elseif ( somare(1,a1).eq.somare(2,a3) ) then
        s2 = somare(1,a1)
        s1 = somare(1,a3)
      endif
c
      if ( s1.eq.0 ) then
        if ( somare(2,a1).eq.somare(1,a3) ) then
          s2 = somare(2,a1)
          s1 = somare(2,a3)
        elseif ( somare(2,a1).eq.somare(2,a3) ) then
          s2 = somare(2,a1)
          s1 = somare(1,a3)
        endif
        s3  = somare(1,a1)
      else
        s3  = somare(2,a1)
      endif
cgn      write(1,20000) 1, s1
cgn      write(1,20000) 2, s2
cgn      write(1,20000) 3, s3
c
c====
c 2. Filles des aretes
c====
c
cgn30000 format('arete ',a5,' :',i3,' de',i3,' a',i3)
      iaux = filare(a1)
      if ( somare(1,iaux).eq.s2 ) then
        as2n1 = iaux
        as3n1 = iaux + 1
      else
        as2n1 = iaux + 1
        as3n1 = iaux
      endif
cgn      write(1,30000) 'as2n1', as2n1, somare(1,as2n1), somare(2,as2n1)
cgn      write(1,30000) 'as3n1', as3n1, somare(1,as3n1), somare(2,as3n1)
c
      iaux = filare(a2)
      if ( somare(1,iaux).eq.s1 ) then
        as1n2 = iaux
        as3n2 = iaux + 1
      else
        as1n2 = iaux + 1
        as3n2 = iaux
      endif
cgn      write(1,30000) 'as1n2', as1n2, somare(1,as1n2), somare(2,as1n2)
cgn      write(1,30000) 'as3n2', as3n2, somare(1,as3n2), somare(2,as3n2)
c
      iaux = filare(a3)
      if ( somare(1,iaux).eq.s1 ) then
        as1n3 = iaux
        as2n3 = iaux + 1
      else
        as1n3 = iaux + 1
        as2n3 = iaux
      endif
cgn      write(1,30000) 'as1n3', as1n3, somare(1,as1n3), somare(2,as1n3)
cgn      write(1,30000) 'as2n3', as2n3, somare(1,as2n3), somare(2,as2n3)
c
      end
