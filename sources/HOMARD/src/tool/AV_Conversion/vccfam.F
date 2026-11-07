      subroutine vccfam ( typenh,
     >                    nbento, nctfen, nbfenm,
     >                    codext, cfaent, tbaux1, tbaux2,
     >                    fament, nbfent,
     >                    nctfe1, nbfen1, cfaen1,
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
c    aVant adaptation - Creation des FAMilles
c                       -            ---
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . typenh . e   .    1   . variantes                                  .
c .        .     .        .  -1 : noeuds                               .
c .        .     .        .   0 : mailles-points                       .
c .        .     .        .   1 : aretes                               .
c .        .     .        .   2 : triangles                            .
c .        .     .        .   3 : tetraedres                           .
c .        .     .        .   4 : quadrangles                          .
c .        .     .        .   5 : pyramides                            .
c .        .     .        .   6 : hexaedres                            .
c .        .     .        .   7 : pentaedres                           .
c . nbento . e   .    1   . nombre d'entites total                     .
c . nctfen . e   .    1   . nombre total de caracteristiques           .
c . nbfenm . e   .    1   . nombre maximum de familles                 .
c . codext . e   . nbento*. codes externes des entites                 .
c .        .     . nctfen .                                            .
c . cfaent .  s  . nctfen*. codes des familles des entites             .
c .        .     . nbfent .                                            .
c .tbaux1,2.  t  .    *   . tableaux auxiliaires                       .
c . fament .  s  . nbento . famille des entites                        .
c . nbfent .  s  .   1    . nombre de familles d'entites               .
c . nctfe1 . e   .    1   . nombre total de caracteristiques annexes   .
c . nbfen1 . e   .    1   . nombre maximum de familles annexes         .
c . cfaen1 . e   . nctfe1*. codes des familles des entites annexes     .
c .        .     . nbfen1 .                                            .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
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
      parameter ( nompro = 'VCCFAM' )
c
#include "nblang.h"
c
#include "cofamp.h"
#include "cofaar.h"
#include "cofina.h"
#include "cofatq.h"
#include "coftex.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer typenh
      integer nbento, nctfen, nbfenm
      integer codext(nbento,nctfen)
      integer cfaent(nctfen,nbfenm)
      integer fament(nbento)
      integer tbaux1(*), tbaux2(*)
      integer nctfe1, nbfen1
      integer cfaen1(nctfe1,nbfen1)
      integer nbfent
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer lafami, famien
      integer entite, nucode, nufami
      integer nbfar1, nbfar2, nbfar3, nbfar4, nbfar5
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
      texte(1,4) = '(a14,'' : nombre de familles creees : '',i8,/)'
      texte(1,5) = '(a14,'' : creation de la famille '',i8,/)'
      texte(1,6) = '(''Ce nombre est superieur au maximum :'',i8)'
      texte(1,7) = '(''Modifier les programmes UTINCG et/ou VCCFAM'')'
c
      texte(2,4) = '(a14,'' : number of created families: '',i8,/)'
      texte(2,5) = '(a14,'' : creation of the family '',i8,/)'
      texte(2,6) = '(''This number is greater than maximum:'',i8)'
      texte(2,7) = '(''Modify the programs UTINCG and/or VCCFAM'')'
c
#include "impr03.h"
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'typenh', typenh
      write (ulsort,90002) 'nbento', nbento
      write (ulsort,90002) 'nctfen', nctfen
      write (ulsort,90002) 'nbfenm', nbfenm
#endif
c
c====
c 1. initialisations
c====
c 1.1. ==> on initialise tous les codes des familles :
c
      do 11, nucode = 1, nctfen
        do 10, nufami = 1, nbfenm
          cfaent(nucode,nufami) = 0
   10   continue
   11 continue
c
c 1.2. ==> on cree la premiere famille, dite 'famille libre' :
c 1.2.1. ==> le compteur
c
      nbfent = 1
c
c 1.2.2. ==> pour les aretes, on gere les orientations inverses de
c            cette famille libre : c'est elle-meme car aucune
c            orientation n'est definie
c
      if ( typenh.eq.1 ) then
c
        cfaent(cofifa,nbfent) = 1
        cfaent(cosfin,nbfent) = 0
c
      endif
c
c 1.2.3. ==> Pour une face, la famille des aretes qui seront tracees
c            dessus au cours du raffinement est la famille
c            libre par defaut
c
      if ( typenh.eq.2 .or. typenh.eq.4 ) then
c
        cfaent(cofafa,nbfent) = 1
c
      endif
c
c====
c 2. creation des autres familles
c====
c
      do 20 , entite = 1, nbento
c
c 2.1. ==> ajout conditionne
c 2.1.1. ==> pour une maille-point, on ajoute le code de la famille du
c            noeud sous-jacent
c
        if ( typenh.eq.0 ) then
c
          codext(entite,cofaso) = tbaux2(tbaux1(entite))
c
c 2.1.2. ==> Pour une face, numero de famille des aretes qui seront
c            tracees dessus au cours du raffinement
c            . Par defaut, c'est la famille libre
c            . Pour une surface, prise en compte du suivi de frontiere
c              on cherche la famille des aretes :
c              . non elements du calcul (i.e. type = 0)
c              . tracees sur la meme surface que la face en cours
c
        elseif ( typenh.eq.2 .or. typenh.eq.4 ) then
c
          jaux = 1
          kaux = codext(entite,cosfsu)
          if ( kaux.ne.0 ) then
            do 212 , iaux = 1 , nbfen1
              if ( cfaen1(cotyel,iaux).eq.0 ) then
                if ( cfaen1(cosfsa,iaux).eq.kaux ) then
                  jaux = iaux
                endif
              endif
  212       continue
          endif
          codext(entite,cofafa) = jaux
c
        endif
c
c 2.2. ==> on recherche si une famille avec les memes codes existe deja
c          . si oui, on stocke son numero pour l'entite en cours.
c          . si non, on cree une famille avec les codes de l'entite
c
        famien = 0
 2200   continue
c
c 2.2.1. ==> Comparaison des codes de la famille 'famien' et
c            de ceux de l'entite en cours
c
          famien = famien + 1
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,90002) '. examen de la famille famien', famien
#endif
c
          if ( famien.le.nbfent ) then
c
            nucode = 0
 2210       continue
              nucode = nucode + 1
c
c             - dans le cas des aretes, on saute les codes :
c                   . de l'orientation inverse
c                   . de la frontiere inactive
c
              if ( typenh.eq.1 ) then
                if ( nucode.eq.cofifa .or. nucode.eq.cosfin ) then
                  goto 2210
                endif
c
c             - dans le cas des quadrangles, on saute les codes :
c                   . de la frontiere inactive
c
              elseif ( typenh.eq.4 ) then
                if ( nucode.eq.cosfin ) then
                  goto 2210
                endif
              endif
c
              if ( nucode.le.nctfen ) then
                if ( codext(entite,nucode).eq.
     >               cfaent(nucode,famien) ) then
c                 le code est le meme : on passe au suivant
                  goto 2210
                else
c                 le code est different : on passe a la famille suivante
                  goto 2200
                endif
              else
c               tous les codes sont les memes : la famille existe deja
                lafami = famien
              endif
c
          else
c
c 2.2.2. ==> la famille n'existe pas encore : on la cree
c
            nbfent = nbfent + 1
            lafami = nbfent
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,5)) mess14(langue,4,typenh), lafami
#endif
            do 222, nucode = 1, nctfen
              cfaent(nucode,nbfent) = codext(entite,nucode)
  222       continue
c
c 2.2.3. ==> Cas particulier des aretes :
c            a. prise en compte de l'orientation : il faut la famille
c               d'orientation inverse
c            b. prise en compte du suivi de frontiere
c               si l'arete est concernee par le suivi de frontiere, il
c               faut creer egalement la famille inactive, ie celle pour
c               laquelle le suivi de frontiere est inactif : toutes les
c               caracteristiques sont les memes a l'exception du numero
c               de ligne/surface que l'on met negatif. On memorise
c               l'association entre les deux familles dans la case
c               cosfin
c
            if ( typenh.eq.1 ) then
c
c 2.2.3.1. ==> l'arete n'a pas d'orientation : la famille
c              d'orientation inverse est elle meme (cofifa)
c
              if ( codext(entite,coorfa).eq.0 ) then
c
                cfaent(cofifa,nbfent) = nbfent
c
c 2.2.3.1.1. ==> l'arete est concernee par une surface de sf
c
                if ( codext(entite,cosfsa).ne.0 ) then
c
                  nbfar1 = nbfent + 1
c
                  do 2231, nucode = 1, nctfen
                    cfaent(nucode,nbfar1) = codext(entite,nucode)
 2231             continue
c
                  cfaent(coorfa,nbfar1) = 0
c
                  cfaent(cofifa,nbfar1) = nbfar1
c
                  cfaent(cosfin,nbfent) = nbfar1
                  cfaent(cosfin,nbfar1) = nbfent
c
                  cfaent(cosfsa,nbfar1) = - codext(entite,cosfsa)
c
                  nbfent = nbfar1
c
c 2.2.3.1.2. ==> l'arete est concernee par une ligne de sf
c                remarque : cela ne devrait jamais arriver car si une
c                           arete est sur une ligne de SF c'est qu'elle
c                           est un element du calcul, donc avec une
c                           orientation
c
                elseif ( codext(entite,cosfli).ne.0 ) then
c
                  codret = 22312
c
                endif
c
c 2.2.3.2. ==> l'arete possede une orientation : on cree la famille
c              d'orientation inverse : toutes les
c              caracteristiques sont les memes a l'exception du code
c              d'orientation, coorfa. On memorise l'association entre
c              les deux familles dans la case cofifa
c
              else
c
c 2.2.3.2.1. ==> la famille n'est pas liee a une frontiere
c
                if ( codext(entite,cosfli).eq.0 .and.
     >               codext(entite,cosfsa).eq.0 ) then
c
                  cfaent(cosfin,nbfent) = 0
c
                  cfaent(cofifa,nbfent) = nbfent + 1
                  nbfent = nbfent + 1
                  do 2232, nucode = 1, nctfen
                    cfaent(nucode,nbfent) = codext(entite,nucode)
 2232             continue
                  cfaent(coorfa,nbfent) = - codext(entite,coorfa)
                  cfaent(cofifa,nbfent) = nbfent - 1
                  cfaent(cosfin,nbfent) = 0
c
c 2.2.3.2.2. ==> l'arete est concernee par une ligne de sf
c
                elseif ( codext(entite,cosfli).ne.0 ) then
c
                  nbfar1 = nbfent + 1
                  nbfar2 = nbfar1 + 1
                  nbfar3 = nbfar2 + 1
c
                  do 2233, nucode = 1, nctfen
                    cfaent(nucode,nbfar1) = codext(entite,nucode)
                    cfaent(nucode,nbfar2) = codext(entite,nucode)
                    cfaent(nucode,nbfar3) = codext(entite,nucode)
 2233             continue
c
                  cfaent(coorfa,nbfar1) = - codext(entite,coorfa)
                  cfaent(coorfa,nbfar3) = - codext(entite,coorfa)
c
                  cfaent(cofifa,nbfent) = nbfar1
                  cfaent(cofifa,nbfar1) = nbfent
                  cfaent(cofifa,nbfar2) = nbfar3
                  cfaent(cofifa,nbfar3) = nbfar2
c
                  cfaent(cosfli,nbfar2) = - codext(entite,cosfli)
                  cfaent(cosfli,nbfar3) = - codext(entite,cosfli)
c
                  cfaent(cosfin,nbfent) = nbfar2
                  cfaent(cosfin,nbfar1) = nbfar3
                  cfaent(cosfin,nbfar2) = nbfent
                  cfaent(cosfin,nbfar3) = nbfar1
c
                  nbfent = nbfar3
c
c 2.2.3.2.3. ==> l'arete est concernee par une surface de sf
c
                elseif ( codext(entite,cosfsa).ne.0 ) then
c
                  nbfar1 = nbfent + 1
                  nbfar2 = nbfar1 + 1
                  nbfar3 = nbfar2 + 1
                  nbfar4 = nbfar3 + 1
                  nbfar5 = nbfar4 + 1
c
                  do 2234, nucode = 1, nctfen
                    cfaent(nucode,nbfar1) = codext(entite,nucode)
                    cfaent(nucode,nbfar2) = codext(entite,nucode)
                    cfaent(nucode,nbfar3) = codext(entite,nucode)
                    cfaent(nucode,nbfar4) = codext(entite,nucode)
                    cfaent(nucode,nbfar5) = codext(entite,nucode)
 2234             continue
c
                  cfaent(cofamd,nbfar4) = 0
                  cfaent(cofamd,nbfar5) = 0
c
                  cfaent(cotyel,nbfar4) = 0
                  cfaent(cotyel,nbfar5) = 0
c
                  cfaent(coorfa,nbfar1) = - codext(entite,coorfa)
                  cfaent(coorfa,nbfar3) = - codext(entite,coorfa)
                  cfaent(coorfa,nbfar4) = 0
                  cfaent(coorfa,nbfar5) = 0
c
                  cfaent(cofifa,nbfent) = nbfar1
                  cfaent(cofifa,nbfar1) = nbfent
                  cfaent(cofifa,nbfar2) = nbfar3
                  cfaent(cofifa,nbfar3) = nbfar2
                  cfaent(cofifa,nbfar4) = nbfar4
                  cfaent(cofifa,nbfar5) = nbfar5
c
                  cfaent(cosfsa,nbfar2) = - codext(entite,cosfsa)
                  cfaent(cosfsa,nbfar3) = - codext(entite,cosfsa)
                  cfaent(cosfsa,nbfar5) = - codext(entite,cosfsa)
c
                  cfaent(cosfin,nbfent) = nbfar2
                  cfaent(cosfin,nbfar1) = nbfar3
                  cfaent(cosfin,nbfar2) = nbfent
                  cfaent(cosfin,nbfar3) = nbfar1
                  cfaent(cosfin,nbfar4) = nbfar5
                  cfaent(cosfin,nbfar5) = nbfar4
c
                  nbfent = nbfar5
c
                else
c
                  codret = 2232
c
                endif
c
              endif
c
c 2.2.4. ==> Cas particulier des quadrangles pour le suivi de frontiere
c               si le quadrangle est concerne par le suivi de frontiere,
c               il faut creer egalement la famille inactive, ie celle
c               pour laquelle le suivi de frontiere est inactif : toutes
c               les caracteristiques sont les memes a l'exception du
c               numero de surface que l'on met negatif. On memorise
c               l'association entre les deux familles dans la case
c               cosfin
c
            elseif ( typenh.eq.4 ) then
c
c 2.2.4.1. ==> le quadrangle est concerne par le suivi de frontiere
c
              if ( codext(entite,cosfsu).ne.0 ) then
c
                nbfar1 = nbfent + 1
c
                do 2241, nucode = 1, nctfen
                  cfaent(nucode,nbfar1) = codext(entite,nucode)
 2241           continue
c
                cfaent(cosfin,nbfent) = nbfar1
                cfaent(cosfin,nbfar1) = nbfent
                cfaent(cosfsu,nbfar1) = -cfaent(cosfsu,nbfent)
c
                nbfent = nbfar1
c
              endif
c
            endif
c
          endif
c
c 2.3. ==> on affecte le numero de famille a l'entite
c
        fament(entite) = lafami
c
   20 continue
c
c 2.4. ==> controle
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,4,typenh), nbfent
#endif
c
      if ( nbfent.gt.nbfenm ) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) 'nbento', nbento
        write (ulsort,90002) 'nctfen', nctfen
        write (ulsort,90002) 'nbfenm', nbfenm
#endif
        write (ulsort,texte(langue,4)) mess14(langue,4,typenh), nbfent
        write (ulsort,texte(langue,6)) nbfenm
        write (ulsort,texte(langue,7)) nompro
        codret = 1
      endif
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
