      subroutine cmhoma ( noehom, arehom,
     >                    somare, filare, hetare,
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
c    Creation du Maillage - HOMologues - les Aretes
c    -           -          ---              -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . noehom . es  . nbnoto . ensemble des noeuds homologues             .
c . arehom . es  . nbarto . ensemble des aretes homologues             .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . filare . e   . nbarto . premiere fille des aretes                  .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
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
      parameter ( nompro = 'CMHOMA' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombno.h"
#include "nombar.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer noehom(nbnoto), arehom(nbarto)
      integer somare(2,nbarto), filare(nbarto), hetare(nbarto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer a21, a22, a11, a12, s11, s12, s21, s22, s2m, s1m
      integer larete
      integer areh
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
      texte(1,4) = '(''Le noeud'',i10,'' est homologue du noeud'',i10)'
      texte(1,5) =
     > '(''Le '',a,i10,'' devrait etre homologue du '',a,i10)'
      texte(1,6) = '(''alors que les tables indiquent que :'')'
      texte(1,7) = '(''Arete'',i10,'' de sommets'',2i10)'
c
      texte(2,4) = '(''Node #'',i10,'' is homologous of node #'',i10)'
      texte(2,5) =
     >'(''The '',a,''#'',i10,'' should be homologous of '',a,''#'',i10)'
      texte(2,6) = '(''but tables indicate that :'')'
      texte(2,7) = '(''Edge #'',i10,'' with vertices #'',2i10)'
c
c====
c 2. on boucle uniquement sur les aretes de la face periodique 2
c    qui viennent d'etre decoupees en 2
c====
c
      do 21, larete = 1 , nbarpe
cgn                   print *,' '
cgn                   print *,'larete = ',larete
c
        if ( arehom(larete).gt.0 ) then
c
c         larete est sur la face periodique 2
c
          if ( hetare(larete).eq.2 ) then
cgn                   print *,'.. larete est coupee en 2'
c
c 2.1. ==> les entites liees a l'arete courante, larete :
c          . sommets de l'arete mere
c          . les aretes filles
c          . le nouveau noeud
c          . l'arete homologue de la mere
c
c               s21       larete        s22
c                x-----------.-----------x
c                    a21   s2m    a22
c
            s21 = somare(1,larete)
            s22 = somare(2,larete)
c
            a21 = filare(larete)
            a22 = a21 + 1
c
            s2m = somare(2,a21)
c
            areh = arehom(larete)
cgn                   if ( larete.eq.50)then
cgn                   print *,'.. sommets de larete : ',s21,s22
cgn                   print *,'.. filles de larete  : ',a21,a22
cgn                   print *,'.. homologue de larete : ',arehom(larete)
cgn                   endif
c
            if ( larete.eq.areh ) then
c
c 2.2. ==> si on est sur l'axe : les deux aretes filles et le nouveau
c          noeud sont homologues d'eux memes
c          par convention, ils sont notes positifs.
c
              if ( noehom(s2m).ne.0 ) then
                if ( abs(noehom(s2m)).ne.s2m ) then
c                 il y a un probleme : la table est deja remplie
                  write (ulsort,texte(langue,5)) mess14(langue,1,-1),
     >            s2m, mess14(langue,1,-1), s2m
                  write (ulsort,texte(langue,6))
                  write (ulsort,texte(langue,4)) s2m, noehom(s2m)
                  codret = 2
                endif
              endif
c
              noehom(s2m) = s2m
c
              arehom(a21) = a21
              arehom(a22) = a22
c
            else
c
c 2.3. ==> on n'est pas sur l'axe : il faut les entites liees a l'arete
c          homologue, areh :
c          . sommets de l'arete mere
c          . les aretes filles
c          . le nouveau noeud
c
c               s11        areh         s12
c                x-----------.-----------x
c                    a11    s1m    a12
c
              s11 = somare(1,areh)
              s12 = somare(2,areh)
c
              a11 = filare(areh)
              a12 = a11 + 1
c
              s1m = somare(2,a11)
c
c           les 2 nouveaux noeuds sommets doivent etre homologues
c           s2m est sur la meme face que "larete" c'est-a-dire la face 2
c           donc noehom(s2m) est positif.
c           s1m est sur l'autre face, donc noehom(s1m) est negatif
c
              if ( noehom(s2m).ne.0 ) then
                if ( abs(noehom(s2m)).ne.s1m ) then
c                 il y a un probleme : la table est deja remplie
                  write (ulsort,texte(langue,5)) mess14(langue,1,-1),
     >            s1m, mess14(langue,1,-1), s2m
                  write (ulsort,texte(langue,6))
                  write (ulsort,texte(langue,4)) s1m, noehom(s1m)
                  write (ulsort,texte(langue,4)) s2m, noehom(s2m)
                  codret = 2
                endif
              endif
c
              noehom(s2m) = s1m
              noehom(s1m) = -s2m
c
c             on repere les homologues des aretes
c             on utilise le fait que noehom(s21) > 0 car s21 est
c             sur la face 2
c
              if ( noehom(s21).eq.s11 ) then
c
c             la premiere fille de larete est homologue a
c             la premiere fille de areh
c
                arehom(a21) = a11
                arehom(a11) = -a21
                arehom(a22) = a12
                arehom(a12) = -a22
c
              elseif ( noehom(s21).eq.s12 ) then
c
c             la premiere fille de larete est homologue a
c             la deuxieme fille de areh
c
                arehom(a21) = a12
                arehom(a11) = -a22
                arehom(a22) = a11
                arehom(a12) = -a21
c
              else
c             il y a un probleme : la correspondance sur les noeuds
c             n'est pas coherente avec la correspondance sur les aretes
                write (ulsort,texte(langue,5)) mess14(langue,1,1),
     >          larete, mess14(langue,1,1), areh
                write (ulsort,texte(langue,7)) larete, s21, s22
                write (ulsort,texte(langue,7)) areh, s11, s12
                write (ulsort,texte(langue,4)) s21, noehom(s21)
                write (ulsort,texte(langue,4)) s22, noehom(s22)
                write (ulsort,texte(langue,4)) s11, noehom(s11)
                write (ulsort,texte(langue,4)) s12, noehom(s12)
                codret = 2
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
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
