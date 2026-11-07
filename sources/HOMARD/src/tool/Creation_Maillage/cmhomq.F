      subroutine cmhomq ( noehom, arehom, trihom, quahom,
     >                    somare, aretri,
     >                    arequa, filqua, hetqua,
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
c    Creation du Maillage - HOMologues - les Quadrangles
c    -           -          ---              -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . noehom . es  . nbnoto . ensemble des noeuds homologues             .
c . arehom . es  . nbarto . ensemble des aretes homologues             .
c . trihom . es  . nbtrto . ensemble des triangles homologues          .
c . quahom . es  . nbquto . ensemble des quadrangles homologues        .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . filqua . e   . nbquto . premier fils des quadrangles               .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
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
      parameter ( nompro = 'CMHOMQ' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "ope1a4.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer noehom(nbnoto), arehom(nbarto)
      integer trihom(nbtrto), quahom(nbquto)
      integer somare(2,nbarto), aretri(nbtrto,3)
      integer arequa(nbquto,4), filqua(nbquto), hetqua(nbquto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer lequad
      integer fach
      integer hist, etafac
      integer a2(4), n2f1(4), a2nin0(4), n20
      integer a1(4), n1f1(4), a1nin0(4), n10
      integer perma1, perma2
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Etat du '',a,i10,'' : '',i4)'
      texte(1,5) = '(/,''Les deux '',a,'' homologues'',2i10)'
      texte(1,6) = '(''devraient etre coupes en 3.'')'
      texte(1,7) = '(''Il faudrait l''''arete'',i10,'' ou '',i10)'
      texte(1,9) = '(''Arete'',i10,'' de sommets'',2i10)'
      texte(1,10) = '(5x,''Erreur sur les '',a,'' homologues.'')'
c
      texte(2,4) = '(''State of '',a,'' #'',i10,'' : '',i4)'
      texte(2,5) = '(/,''The two homologous '',a,'' #'',i10)'
      texte(2,6) = '(''should be cut into 3.'')'
      texte(2,7) = '(''It should be edge #'',i10,'' or #'',i10)'
      texte(2,9) = '(''Edge #'',i10,'' with vertices #'',2i10)'
      texte(2,10) = '(5x,''Error for homologous '',a)'
c
cgn 1788   format(a,i6,' : ',10i6)
cgn 1789   format(10i6)
cgn      write(ulsort,*)'hetqua'
cgn      write(ulsort,1789)hetqua
cgn      write(ulsort,*)'filqua'
cgn      write(ulsort,1789)filqua
cgn      write(ulsort,*)'noehom'
cgn      write(ulsort,1789)noehom
cgn      write(ulsort,*)'arehom'
cgn      write(ulsort,1789)arehom
cgn      write(ulsort,*)'trihom'
cgn      write(ulsort,1789)trihom
cgn      write(ulsort,*)'quahom'
cgn      write(ulsort,1789)quahom
c====
c 2. on boucle uniquement sur les quadrangles de la face periodique 2
c    qui viennent d'etre decoupes en 2 ou en 4 quadrangles ou en
c    3 triangles
c    on se rapportera a cmrdqu pour les conventions
c====
c
      do 21, lequad = 1, nbqupe
c
        if ( codret.eq.0 ) then
c
        if ( quahom(lequad).gt.0 ) then
c
          fach = abs(quahom(lequad))
c
          hist = hetqua(lequad)
          etafac = mod ( hist, 100 )
cgn      write(ulsort,*)'lequad, hist, etafac = ',lequad, hist,etafac
c
          if ( etafac.eq.4 ) then
c
c 2.1. ==> le quadrangle vient d'etre decoupe en 4
c
c 2.1.1. ==> infos sur lequad et ses fils
c
            a2(1) = arequa(lequad,1)
            a2(2) = arequa(lequad,2)
            a2(3) = arequa(lequad,3)
            a2(4) = arequa(lequad,4)
c
            n2f1(1) = filqua(lequad)
            n2f1(2) = n2f1(1) + 1
            n2f1(3) = n2f1(2) + 1
            n2f1(4) = n2f1(3) + 1
            a2nin0(1) = arequa(n2f1(1),2)
            a2nin0(2) = arequa(n2f1(2),2)
            a2nin0(3) = arequa(n2f1(3),2)
            a2nin0(4) = arequa(n2f1(4),2)
            n20 = somare(2,a2nin0(1))
c
c 2.1.2. ==> infos sur l'homologue de lequad et ses fils
c
            a1(1) = arequa(fach,1)
            a1(2) = arequa(fach,2)
            a1(3) = arequa(fach,3)
            a1(4) = arequa(fach,4)
c
            n1f1(1) = filqua(fach)
            n1f1(2) = n1f1(1) + 1
            n1f1(3) = n1f1(2) + 1
            n1f1(4) = n1f1(3) + 1
            a1nin0(1) = arequa(n1f1(1),2)
            a1nin0(2) = arequa(n1f1(2),2)
            a1nin0(3) = arequa(n1f1(3),2)
            a1nin0(4) = arequa(n1f1(4),2)
            n10 = somare(2,a1nin0(1))
c
cgn      write(ulsort,*) 'face 2'
cgn      write(ulsort,1789) a2(1), a2(2), a2(3), a2(4)
cgn      write(ulsort,1789) n2f1
cgn      write(ulsort,1789) a2nin0
cgn      write(ulsort,1789) n20
cgn      write(ulsort,*) 'face 1'
cgn      write(ulsort,1789) a1(1), a1(2), a1(3), a1(4)
cgn      write(ulsort,1789) n1f1
cgn      write(ulsort,1789) a1nin0
cgn      write(ulsort,1789) n10
c
c 2.1.3.  ==> reperage des homologues
c
c 2.1.3.1. ==> recherche du positionnement relatif des deux quadrangles
c              peres homologues
c        perma1 : numero de la permutation sur les aretes a1(1) et a1(3)
c        perma2 : numero de la permutation sur les aretes a1(2) et a1(4)
c
c                 a1(4)                     a2(4)
c             .________.              .________.
c             .        .              .        .
c             .        .              .        .
c          a1(1).        .a1(3)        a2(1).        .a2(3)
c             .        .              .        .
c             .________.              .________.
c                 a1(2)                     a2(2)
c
            perma1 = 100
            perma2 = 100
c
            if ( arehom(a2(1)).eq.a1(1) ) then
              perma1 = 0
              if ( arehom(a2(2)).eq.a1(2) ) then
                perma2 = 0
              elseif ( arehom(a2(2)).eq.a1(4) ) then
                perma2 = 2
              endif
c
            elseif ( arehom(a2(1)).eq.a1(2) ) then
              perma1 = 1
              if ( arehom(a2(2)).eq.a1(3) ) then
                perma2 = 1
              elseif ( arehom(a2(2)).eq.a1(1) ) then
                perma2 = 3
              endif
c
            elseif ( arehom(a2(1)).eq.a1(3) ) then
              perma1 = 2
              if ( arehom(a2(2)).eq.a1(4) ) then
                perma2 = 2
              elseif ( arehom(a2(2)).eq.a1(2) ) then
                perma2 = 4
              endif
c
            elseif ( arehom(a2(1)).eq.a1(4) ) then
              perma1 = 3
              if ( arehom(a2(2)).eq.a1(1) ) then
                perma2 = 3
              elseif ( arehom(a2(2)).eq.a1(3) ) then
                perma2 = 1
              endif
c
            endif
c
            if ( perma1.eq.100 .or. perma2.eq.100 ) then
c
              write (ulsort,texte(langue,5)) mess14(langue,3,4),
     >                                       lequad, fach
              write (ulsort,texte(langue,9)) a2(1),
     >                              somare(1,a2(1)), somare(2,a2(1))
              write (ulsort,texte(langue,9)) a2(1), arehom(a2(1))
              codret = 2
c
            endif
cgn      write(ulsort,*)'perma1, perma2',perma1, perma2
c
c 2.1.3.2. ==> remplissage des tables
c
            if ( codret.eq.0 ) then
c
            iaux = per1a4(perma1,1)
            quahom(n2f1(1)) = n1f1(iaux)
            quahom(n1f1(iaux)) = -n2f1(1)
            arehom(a2nin0(1)) = a1nin0(iaux)
            arehom(a1nin0(iaux)) = -a2nin0(1)
c
            iaux = per1a4(perma2,2)
            quahom(n2f1(2)) = n1f1(iaux)
            quahom(n1f1(iaux)) = -n2f1(2)
            arehom(a2nin0(2)) = a1nin0(iaux)
            arehom(a1nin0(iaux)) = -a2nin0(2)
c
            iaux = per1a4(perma1,3)
            quahom(n2f1(3)) = n1f1(iaux)
            quahom(n1f1(iaux)) = -n2f1(3)
            arehom(a2nin0(3)) = a1nin0(iaux)
            arehom(a1nin0(iaux)) = -a2nin0(3)
c
            iaux = per1a4(perma2,4)
            quahom(n2f1(4)) = n1f1(iaux)
            quahom(n1f1(iaux)) = -n2f1(4)
            arehom(a2nin0(4)) = a1nin0(iaux)
            arehom(a1nin0(iaux)) = -a2nin0(4)
c
            noehom(n20) = n10
            noehom(n10) = -n20
c
            endif
c
          elseif ( etafac.eq.31 .or. etafac.eq.32 .or.
     >             etafac.eq.33 .or. etafac.eq.34 ) then
c
c 2.2. ==> le quadrangle vient d'etre decoupe en 3 triangles
c
c 2.2.1. ==> infos sur lequad et ses fils
c
            n2f1(1) = -filqua(lequad)
            n2f1(2) = n2f1(1) + 1
            n2f1(3) = n2f1(2) + 1
            a2nin0(1) = aretri(n2f1(1),1)
            a2nin0(2) = aretri(n2f1(1),3)
            a2nin0(3) = aretri(n2f1(2),1)
c
c 2.2.2. ==> infos sur l'homologue de lequad et ses fils
c
            n1f1(1) = -filqua(fach)
            n1f1(2) = n1f1(1) + 1
            n1f1(3) = n1f1(2) + 1
            a1nin0(1) = aretri(n1f1(1),1)
            a1nin0(2) = aretri(n1f1(1),3)
            a1nin0(3) = aretri(n1f1(2),1)
            a1nin0(4) = aretri(n1f1(3),1)
c
cgn      write(ulsort,*) 'face 2'
cgn      write(ulsort,1788) 'fils de ',lequad,n2f1(1), n2f1(2), n2f1(3)
cgn      write(ulsort,1788) 'aretes des fils de ',lequad,
cgn     >                   a2nin0(1), a2nin0(2), a2nin0(3)
cgn      write(ulsort,*) 'face 1'
cgn      write(ulsort,1788) 'fils de ',fach,n1f1(1), n1f1(2), n1f1(3)
cgn      write(ulsort,1788) 'aretes des fils de ',fach,
cgn     >                   a1nin0
cgn      write(ulsort,1789) arehom(a2nin0(3))
c
c 2.2.3.  ==> reperage des homologues
c
            trihom(n2f1(1)) = n1f1(1)
            trihom(n1f1(1)) = -n2f1(1)
c
            if ( arehom(a2nin0(3)).eq.a1nin0(3) ) then
c
              arehom(a2nin0(1)) = a1nin0(1)
              arehom(a1nin0(1)) = -a2nin0(1)
              arehom(a2nin0(2)) = a1nin0(2)
              arehom(a1nin0(2)) = -a2nin0(2)
              trihom(n2f1(2)) = n1f1(2)
              trihom(n1f1(2)) = -n2f1(2)
              trihom(n2f1(3)) = n1f1(3)
              trihom(n1f1(3)) = -n2f1(3)
c
            elseif ( arehom(a2nin0(3)).eq.a1nin0(4) ) then
c
              arehom(a2nin0(1)) = a1nin0(2)
              arehom(a1nin0(2)) = -a2nin0(1)
              arehom(a2nin0(2)) = a1nin0(1)
              arehom(a1nin0(1)) = -a2nin0(2)
              trihom(n2f1(2)) = n1f1(3)
              trihom(n1f1(3)) = -n2f1(2)
              trihom(n2f1(3)) = n1f1(2)
              trihom(n1f1(2)) = -n2f1(3)
c
            else
c
              write (ulsort,texte(langue,5)) mess14(langue,3,4),
     >                                       lequad, fach
              write (ulsort,texte(langue,6))
              write (ulsort,texte(langue,4)) mess14(langue,1,4),
     >                                       lequad, hetqua(lequad)
              write (ulsort,texte(langue,4)) mess14(langue,1,4),
     >                                       fach, hetqua(fach)
              codret = 2
c
            endif
c
          endif
c
        endif
c
        endif
c
   21 continue
c
c====
c 3. la fin
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
cgn      write(ulsort,*)'noehom'
cgn      write(ulsort,1789)noehom
cgn      write(ulsort,*)'arehom'
cgn      write(ulsort,1789)arehom
cgn      write(ulsort,*)'trihom'
cgn      write(ulsort,1789)trihom
cgn      write(ulsort,*)'quahom'
cgn      write(ulsort,1789)quahom
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
