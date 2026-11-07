      subroutine cmrdqu ( coonoe, hetnoe, arenoe,
     >                    somare, hetare, filare, merare,
     >                    arequa, hetqua, filqua, perqua,
     >                    nivqua, ninqua, decfac,
     >                    famnoe, famare, famqua,
     >                    indnoe, indare, indqua,
     >                    cfaqua,
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
c    Creation du Maillage - Raffinement - Decoupage des QUadrangles
c    -           -          -             -             --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . coonoe . es  .nouvno*3. coordonnees des noeuds                     .
c . hetnoe . es  . nouvno . historique de l'etat des noeuds            .
c . arenoe . es  . nouvno . arete liee a un nouveau noeud              .
c . somare . es  .2*nouvar. numeros des extremites d'arete             .
c . hetare . es  . nouvar . historique de l'etat des aretes            .
c . filare . es  . nouvar . premiere fille des aretes                  .
c . merare . es  . nouvar . mere des aretes                            .
c . arequa . es  .nouvqu*4. numeros des 4 aretes des quadrangles       .
c . hetqua . es  . nouvqu . historique de l'etat des quadrangles       .
c . filqua . es  . nouvqu . premier fils des quadrangles               .
c . perqua . es  . nouvqu . pere des quadrangles                       .
c . nivqua . es  . nouvqu . niveau des quadrangles                     .
c . ninqua . es  . nouvqu . noeud interne au quadrangle                .
c . decfac . es  . -nouvqu. decision sur les faces (quad. + tri.)      .
c .        .     . :nouvqu.                                            .
c . famnoe .     . nouvno . famille des noeuds                         .
c . famare .     . nouvar . famille des aretes                         .
c . famqua . es  . nouvqu . famille des quadrangles                    .
c . indnoe . es  . 1      . indice du derniere noeud cree              .
c . indare . es  . 1      . indice de la derniere arete creee          .
c . indqua . es  . 1      . indice du dernier quadrangle cree          .
c . cfaqua . e   . nctfqu*. codes des familles des quadrangles         .
c .        .     . nbfqua .   1 : famille MED                          .
c .        .     .        .   2 : type de quadrangle                   .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        .   5 : famille des triangles de conformite  .
c .        .     .        .   6 : famille de sf active/inactive        .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
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
      parameter ( nompro = 'CMRDQU' )
c
#include "nblang.h"
#include "fractc.h"
#include "cofatq.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "envca1.h"
#include "nombqu.h"
#include "nouvnb.h"
#include "dicfen.h"
#include "nbfami.h"
c
c 0.3. ==> arguments
c
      double precision coonoe(nouvno,sdim)
c
      integer hetnoe(nouvno), arenoe(nouvno)
c
      integer decfac(-nouvqu:nouvtr)
      integer somare(2,nouvar), hetare(nouvar), filare(nouvar)
      integer merare(nouvar)
      integer arequa(nouvqu,4), hetqua(nouvqu)
      integer filqua(nouvqu), perqua(nouvqu), nivqua(nouvqu)
      integer ninqua(nouvqu)
      integer famnoe(nouvno), famare(nouvar), famqua(nouvqu)
      integer indnoe, indare, indqua
      integer cfaqua(nctfqu,nbfqua)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer a1, a2, a3, a4
      integer sa1a2, sa2a3, sa3a4, sa4a1
      integer n0, n1, n2, n3, n4
      integer a1f1, a1f2, a2f1, a2f2, a3f1, a3f2, a4f1, a4f2
      integer an1n0, an2n0, an3n0, an4n0
      integer nf1, nf2, nf3, nf4
      integer etat, niv, lepere
      integer lequad
c
      logical noinma
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. preliminaires
c====
c
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Decoupage du quadrangle'',i10)'
      texte(1,5) = '(''.. Noeud milieu'',i10,'', coor :'',3g15.7)'
      texte(1,6) = '(''.. Arete interne'',i10,'', de'',i10,'' a'',i10)'
      texte(1,7) = '(''.. Quad fils'',i10,'', aretes :'',4i10)'
c
      texte(2,4) = '(''Splitting of quadrangle #'',i10)'
      texte(2,5) = '(''.. Central node'',i10,'', coor:'',3g15.7)'
      texte(2,6) =
     > '(''.. Internal edge'',i10,'', from'',i10,'' to'',i10)'
      texte(2,7) = '(''.. Quad son'',i10,'', edges:'',4i10)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,*) 'entree de ',nompro
        do 1101 , iaux = 1 , min(nouvar,1)
          write (ulsort,90001) 'arete', iaux,
     >    somare(1,iaux), somare(2,iaux)
 1101   continue
        do 1105 , lequad = 1 , min(nouvqu,1)
          write (ulsort,90001) 'quadrangle', lequad,
     >    arequa(lequad,1), arequa(lequad,2),
     >    arequa(lequad,3), arequa(lequad,4)
 1105   continue
             lequad = 1
          write (ulsort,90001) 'fils du quadrangle', lequad,
     >    filqua(lequad)
      call dmflsh (iaux)
#endif
c
      if ( mod(mailet,3).eq.0 ) then
        noinma = .true.
      else
        noinma = .false.
      endif
c
c====
c 1. decoupage en 4 des quadrangles de decision 4
c====
c
c   Quadrangle pere :
c     ak = numero de la k-eme arete du quadrangle pere
c     sajak = numero du noeud commun aux aretes aj et ak
c
c       sa4a1                       a4                        sa3a4
c           ._________________________________________________.
c           .                                                 .
c           .                                                 .
c           .                                                 .
c           .                                                 .
c           .                                                 .
c           .                                                 .
c        a1 .                                                 . a3
c           .                                                 .
c           .                                                 .
c           .                                                 .
c           .                                                 .
c           .                                                 .
c           .                                                 .
c           ._________________________________________________.
c       sa1a2                       a2                        sa2a3
c
c   Remarque : on appelle ici le sens standard celui correspondant
c              a l'enchainement (a1,a2,a3,a4)
c
c   Quadrangles fils :
c     n0 = numero du noeud barycentre des 4 sommets du quadrangle pere
c     nk = numero du noeud milieu de la k-eme arete du quadrangle pere
c     akf1/2 = numero des filles de la k-eme arete du quadrangle pere
c              akf1 : la premiere dans le sens standard
c              akf2 : la seconde dans le sens standard
c     nfk = numero du k-eme quadrangle fils : celui qui contient la
c           premiere (au sens standard) des filles de l'arete ak
c     ankn0 = numero de l'arete qui va de nk a n0. (Par construction,
c             n0>nk). Elle est commune aux filles nfk et nf(k+1).
c
c       sa4a1          a4f2        a4/n4        a4f1          sa3a4
c           .________________________.________________________.
c           .                        .                        .
c           .                        .                        .
c           .                        .an4n0                   .
c      a1f1 .          nf1           .          nf4           . a3f2
c           .                        .                        .
c           .                        .                        .
c     a1/n1 .________________________.________________________. a3/n3
c           .         an1n0          .n0       an3n0          .
c           .                        .                        .
c           .                        .an2n0                   .
c      a1f2 .          nf2           .          nf3           . a3f1
c           .                        .                        .
c           .                        .                        .
c           .________________________.________________________.
c       sa1a2         a2f1         a2/n2        a2f2          sa2a3
c
c
      do 100 , lequad = 1 , nbqupe
c
cgn      write (ulsort,90002)'decision', decfac(-lequad)
        if ( decfac(-lequad) .eq. 4 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) lequad
#endif
c
c 1.1. ==> determination des numeros d'aretes
c
          a1 = arequa(lequad,1)
          a2 = arequa(lequad,2)
          a3 = arequa(lequad,3)
          a4 = arequa(lequad,4)
cgn      write (ulsort,90002)'.. indqua',indqua
cgn      write (ulsort,90002)'.. indare',indare
cgn      write (ulsort,90002)'.. aretes     ',a1, a2, a3, a4
cgn      write (ulsort,90002)'.. de filles  ',filare(a1), filare(a2),
cgn     >                                filare(a3), filare(a4)
c
c 1.2. ==> determination des 4 sommets
c
          call utsoqu ( somare, a1, a2, a3, a4,
     >                  sa1a2, sa2a3, sa3a4, sa4a1 )
cgn      write (ulsort,90002)'.. sommets',sa1a2, sa2a3, sa3a4, sa4a1
c
c 1.3. ==> determination des 8 demi-aretes filles des precedentes
c
          call utafqu ( somare, filare, a1, a2, a3, a4,
     >                  a1f1, a1f2,
     >                  a2f1, a2f2,
     >                  a3f1, a3f2,
     >                  a4f1, a4f2 )
cgn      write (ulsort,90002)'.. a1f1/2',a1f1,a1f2
cgn      write (ulsort,90002)'.. a2f1/2',a2f1,a2f2
cgn      write (ulsort,90002)'.. a3f1/2',a3f1,a3f2
cgn      write (ulsort,90002)'.. a4f1/2',a4f1,a4f2
c
c 1.4. ==> determination des noeuds milieux
c
          n1 = somare(2,a1f1)
          n2 = somare(2,a2f1)
          n3 = somare(2,a3f1)
          n4 = somare(2,a4f1)
cgn      write (ulsort,90002)'.. nk',n1, n2, n3, n4
c
c 1.5. ==> le sommet central
c          . on le cree au barycentre du quadrangle s'il n'existe pas
c          . on le recupere sinon
c
          if ( noinma ) then
c
            n0 = ninqua(lequad)
c
          else
c
            n0 = indnoe + 1
            arenoe(n0) = 0
            coonoe(n0,1) = ( coonoe(sa4a1,1) +
     >                       coonoe(sa1a2,1) +
     >                       coonoe(sa2a3,1) +
     >                       coonoe(sa3a4,1) ) * unsqu
            coonoe(n0,2) = ( coonoe(sa4a1,2) +
     >                       coonoe(sa1a2,2) +
     >                       coonoe(sa2a3,2) +
     >                       coonoe(sa3a4,2) ) * unsqu
            if ( sdim.eq.3 ) then
              coonoe(n0,3) = ( coonoe(sa4a1,3) +
     >                         coonoe(sa1a2,3) +
     >                         coonoe(sa2a3,3) +
     >                         coonoe(sa3a4,3) ) * unsqu
            endif
            famnoe(n0) = 1
            hetnoe(n0) = 51
            indnoe = n0
c
          endif
#ifdef _DEBUG_HOMARD_
          if ( sdim.eq.3 ) then
             write (ulsort,texte(langue,5)) n0,
     >                            coonoe(n0,1),coonoe(n0,2),coonoe(n0,3)
          else
             write (ulsort,texte(langue,5)) n0,
     >                            coonoe(n0,1),coonoe(n0,2)
          endif
#endif
cgn      write (ulsort,90002)'.. n0',n0
c
c 1.6. ==> creation des aretes internes
c 1.6.1. ==> leurs numeros
c
          an1n0 = indare + 1
          an2n0 = indare + 2
          an3n0 = indare + 3
          an4n0 = indare + 4
          indare = an4n0
cgn      write (ulsort,90002)'.. ankn0',an1n0,an2n0,an3n0,an4n0
c
c 1.6.2. ==> les numeros de leurs sommets avec la convention ad'hoc
c
          somare(1,an1n0) = n1
          somare(2,an1n0) = n0
          somare(1,an2n0) = n2
          somare(2,an2n0) = n0
          somare(1,an3n0) = n3
          somare(2,an3n0) = n0
          somare(1,an4n0) = n4
          somare(2,an4n0) = n0
#ifdef _DEBUG_HOMARD_
           write (ulsort,texte(langue,6)) an1n0, n1, n0
           write (ulsort,texte(langue,6)) an2n0, n2, n0
           write (ulsort,texte(langue,6)) an3n0, n3, n0
           write (ulsort,texte(langue,6)) an4n0, n4, n0
#endif
c
c 1.6.3. ==> leur famille
c
cgn      write(ulsort,90002) 'famqua(lequad)',famqua(lequad)
cgn      write(ulsort,90002) 'avec cfaqua',
cgn     >(cfaqua(iaux,famqua(lequad)),iaux=1,nctfqu)
cgn      write(ulsort,90002) '==> famare', cfaqua(cofafa,famqua(lequad))
          jaux = cfaqua(cofafa,famqua(lequad))
          famare(an1n0) = jaux
          famare(an2n0) = jaux
          famare(an3n0) = jaux
          famare(an4n0) = jaux
c
c 1.6.4. ==> la parente
c
          hetare(an1n0) = 50
          hetare(an2n0) = 50
          hetare(an3n0) = 50
          hetare(an4n0) = 50
          merare(an1n0) = 0
          merare(an2n0) = 0
          merare(an3n0) = 0
          merare(an4n0) = 0
          filare(an1n0) = 0
          filare(an2n0) = 0
          filare(an3n0) = 0
          filare(an4n0) = 0
c
c 1.7. ==> creation des 4 quadrangles fils
c 1.7.1. ==> connectivite
c            on prend soin de tourner dans le meme sens que le pere ...
c
          nf1 = indqua + 1
          arequa(nf1,1) = a1f1
          arequa(nf1,2) = an1n0
          arequa(nf1,3) = an4n0
          arequa(nf1,4) = a4f2
c
          nf2 = nf1 + 1
          arequa(nf2,1) = a2f1
          arequa(nf2,2) = an2n0
          arequa(nf2,3) = an1n0
          arequa(nf2,4) = a1f2
c
          nf3 = nf2 + 1
          arequa(nf3,1) = a3f1
          arequa(nf3,2) = an3n0
          arequa(nf3,3) = an2n0
          arequa(nf3,4) = a2f2
c
          nf4 = nf3 + 1
          arequa(nf4,1) = a4f1
          arequa(nf4,2) = an4n0
          arequa(nf4,3) = an3n0
          arequa(nf4,4) = a3f2
c
          indqua = nf4
c
#ifdef _DEBUG_HOMARD_
           write (ulsort,texte(langue,7)) nf1, a1f1, an1n0, an4n0, a4f2
           write (ulsort,texte(langue,7)) nf2, a2f1, an2n0, an1n0, a1f2
           write (ulsort,texte(langue,7)) nf3, a3f1, an3n0, an2n0, a2f2
           write (ulsort,texte(langue,7)) nf4, a4f1, an4n0, an3n0, a3f2
#endif
cgn  cgn      write (ulsort,90002) '... nf1', nf1
cgn        do 171 , iaux = 1,4
cgn          write (ulsort,17)arequa(nf1,iaux),
cgn     <  somare(1,arequa(nf1,iaux)),somare(2,arequa(nf1,iaux))
cgn  171   continue
cgn  cgn      write (ulsort,90002) '... nf2', nf2
cgn        do 172 , iaux = 1,4
cgn          write (ulsort,17)arequa(nf2,iaux),
cgn     <  somare(1,arequa(nf2,iaux)),somare(2,arequa(nf2,iaux))
cgn  172   continue
cgn  cgn      write (ulsort,90002) '... nf3', nf3
cgn        do 173 , iaux = 1,4
cgn          write (ulsort,17)arequa(nf3,iaux),
cgn     <  somare(1,arequa(nf3,iaux)),somare(2,arequa(nf3,iaux))
cgn  173   continue
cgn  cgn      write (ulsort,90002) '... nf4', nf4
cgn        do 174 , iaux = 1,4
cgn          write (ulsort,17)arequa(nf4,iaux),
cgn     <  somare(1,arequa(nf4,iaux)),somare(2,arequa(nf4,iaux))
cgn  174   continue
cgn  17      format('.... arete ',i6,' de ',i6,' a ',i6)
c
c 1.7.2. ==> mise a jour de la famille des 4 quadrangles fils
c
          iaux = famqua(lequad)
          famqua(nf1) = iaux
          famqua(nf2) = iaux
          famqua(nf3) = iaux
          famqua(nf4) = iaux
c
          hetqua(nf1) = 5500
          hetqua(nf2) = 5500
          hetqua(nf3) = 5500
          hetqua(nf4) = 5500
c
          filqua(nf1) = 0
          filqua(nf2) = 0
          filqua(nf3) = 0
          filqua(nf4)  = 0
          perqua(nf1) = lequad
          perqua(nf2) = lequad
          perqua(nf3) = lequad
          perqua(nf4) = lequad
c
          niv = nivqua(lequad) + 1
          nivqua(nf1) = niv
          nivqua(nf2) = niv
          nivqua(nf3) = niv
          nivqua(nf4) = niv
c
c 1.8. ==> mise a jour du pere et du grand-pere eventuel
c    Remarque : si on est parti d'un macro-maillage non conforme,
c               certains quadrangles ont des peres adoptifs de numero
c               negatif. Il ne faut pas changer leur etat
c
          filqua(lequad) = nf1
          hetqua(lequad) = hetqua(lequad) + 4
          lepere = perqua(lequad)
          if ( lepere.gt.0 ) then
            etat = hetqua(lepere)
            hetqua(lepere) = etat - mod(etat,100) + 99
          endif
cgn      write (ulsort,90002)'.. indqua',indqua
cgn      write (ulsort,90002)'.. indare',indare
c
        endif
c
  100 continue
cgn      write (ulsort,*) 'indqua',indqua
cgn      write (ulsort,*) 'indare',indare
cgn      write (ulsort,*) 'indnoe',indnoe
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,*) 'sortie de ',nompro
        do 1102 , iaux = 1 , min(nouvar,1)
          write (ulsort,90001) 'arete', iaux,
     >    somare(1,iaux), somare(2,iaux)
 1102   continue
        do 1106 , lequad = 1 , min(nouvqu,1)
          write (ulsort,90001) 'quadrangle', lequad,
     >    arequa(lequad,1), arequa(lequad,2),
     >    arequa(lequad,3), arequa(lequad,4)
 1106   continue
          lequad = 1
          write (ulsort,90001) 'fils du quadrangle', lequad,
     >    filqua(lequad)
#endif
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
