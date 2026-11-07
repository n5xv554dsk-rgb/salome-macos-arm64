      subroutine cmrdhe ( coonoe, hetnoe, arenoe,
     >                    somare, hetare, filare, merare,
     >                    arequa, hetqua,
     >                    filqua, perqua, nivqua,
     >                    quahex, coquhe, hethex,
     >                    filhex, perhex, ninhex,
     >                    famnoe, famare, famqua, famhex,
     >                    indnoe, indare, indqua, indhex,
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
c    Creation du Maillage - Raffinement - Decoupage des HExaedres
c    -           -          -             -             --
c ______________________________________________________________________
c       remarque : on est forcement en 3d
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . coonoe . e   .nouvno*3. coordonnees des noeuds                     .
c . hetnoe . es  . nouvno . historique de l'etat des noeuds            .
c . arenoe . es  . nouvno . arete liee a un nouveau noeud              .
c . somare . es  .2*nouvar. numeros des extremites d'arete             .
c . hetare . es  . nouvar . historique de l'etat des aretes            .
c . filare . es  . nouvar . premiere fille des aretes                  .
c . merare . es  . nouvar . mere des aretes                            .
c . arequa . e   .nouvqu*4. numeros des 4 aretes des quadrangles       .
c . hetqua . e   . nouvqu . historique de l'etat des quadrangles       .
c . filqua . e   . nouvqu . premier fils des quadrangles               .
c . perqua . e   . nouvqu . pere des quadrangles                       .
c . nivqua . e   . nouvqu . niveau des quadrangles                     .
c . quahex . e   .nouvhf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nouvhf*6. code des 6 quadrangles des hexaedres       .
c . hethex . es  . nouvhe . historique de l'etat des hexaedres         .
c . filhex . es  . nouvhe . premier fils des hexaedres                 .
c . perhex . e   . nouvhe . pere des hexaedres                         .
c . ninhex . es  . nouvhe . noeud interne a l'hexaedre                 .
c . famnoe .     . nouvno . famille des noeuds                         .
c . famare . es  . nouvar . famille des aretes                         .
c . famqua . es  . nouvqu . famille des quadrangles                    .
c . famhex . es  . nouvhe . famille des hexaedres                      .
c . indnoe . es  . 1      . indice du derniere noeud cree              .
c . indare . es  . 1      . indice de la derniere arete creee          .
c . indqua . es  . 1      . indice du dernier quadrangle cree          .
c . indhex . es  . 1      . indice du dernier hexaedre cree            .
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
      parameter ( nompro = 'CMRDHE' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "impr02.h"
#include "envca1.h"
#include "defiqu.h"
#include "nombhe.h"
#include "nouvnb.h"
#include "fracte.h"
#include "cofhex.h"
c
c 0.3. ==> arguments
c
      double precision coonoe(nouvno,sdim)
c
      integer hetnoe(nouvno), arenoe(nouvno)
      integer somare(2,nouvar), hetare(nouvar), filare(nouvar)
      integer merare(nouvar)
      integer arequa(nouvqu,4), hetqua(nouvqu)
      integer filqua(nouvqu), perqua(nouvqu), nivqua(nouvqu)
      integer quahex(nouvhf,6), coquhe(nouvhf,6)
      integer hethex(nouvhe), filhex(nouvhe), perhex(nouvhe)
      integer ninhex(nouvhe)
      integer famnoe(nouvno), famare(nouvar), famqua(nouvqu)
      integer famhex(nouvhe)
      integer indnoe, indare, indqua, indhex
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer nuhexa, dt, etat, lehexa, pere
      integer niveau, cf1, cf2, cf3, cf4, cf5, cf6
      integer f1, f2, f3, f4, f5, f6
      integer codefa

c     le noeud nfi est le milieu de la face fi
      integer nf1, nf2, nf3, nf4, nf5, nf6
c     le noeud central a l'hexaedre a pour nom ...
      integer n0
c
c     la face fisj est la fille de la face fi et qui contient sj.
c
      integer f1s1,f1s2, f1s3, f1s4
      integer f2s1,f2s2, f2s5, f2s6
      integer f3s1,f3s4, f3s6, f3s7
      integer f4s2,f4s3, f4s5, f4s8
      integer f5s3,f5s4, f5s7, f5s8
      integer f6s5,f6s6, f6s7, f6s8
c
c     Attention les noms des aretes internes aux faces de l'hexaedre
c     decoupe sont ANINJ quand elle relie le noeud ni au noeud nj,
c     dans la doc.
c     Ici pour rester a 6 lettres, on les appelera ninj.

      integer n1nf1, n2nf1, n3nf1, n4nf1
      integer n1nf2, n5nf2, n6nf2, n9nf2
      integer n2nf3, n5nf3, n7nf3, n10nf3
      integer n3nf4, n6nf4, n8nf4, n11nf4
      integer n4nf5, n7nf5, n8nf5, n12nf5
      integer n9nf6, n10nf6, n11nf6, n12nf6
c
c     Les aretes internes a l'hexaedre :
c     NfiN0 relie le noeud nfi(milieu de la face fi) au noeud central
      integer nf1n0, nf2n0, nf3n0, nf4n0, nf5n0, nf6n0
c
c     Les faces creees
c     La face pfinj est parallele a la face fi et contient le noeud nj
      integer pf1n5, pf1n6, pf1n7, pf1n8
      integer pf2n2, pf2n3, pf2n10, pf2n11
      integer pf3n1, pf3n4, pf3n9, pf3n12
c
      integer iaux, jaux
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
      texte(1,4) = '(''Decoupage de '',a,i10)'
      texte(1,5) =
     > '(''.. Face :'',i10,'', d''''aretes'',4i10,'', code'',i2)'
      texte(1,6) = '(''.. Noeuds milieux des faces'',6i10)'
      texte(1,7) = '(''.. Noeud milieu'',i10,'', coor :'',3g15.7)'
      texte(1,8) = '(''.. Creation des '',a,'' internes'')'
      texte(1,9) = '(''.. Creation des 8 hexaedres'')'
      texte(1,10) = '(''.. Hexaedre :'',i10,'', de faces'',6i10)'
c
      texte(2,4) = '(''Splitting of '',a,'' #'',i10)'
      texte(2,5) =
     > '(''.. Face :'',i10,'', with edges'',4i10,'', code'',i2)'
      texte(2,6) = '(''.. Center nodes for faces'',6i10)'
      texte(2,7) = '(''.. Central node'',i10,'', coor :'',3g15.7)'
      texte(2,8) = '(''.. Creation of internal '',a)'
      texte(2,9) = '(''.. Creation of 8 hexahedrons'')'
      texte(2,10) = '(''.. Hexahedron :'',i10,'', with faces'',6i10)'
c
      if ( mod(mailet,5).eq.0 ) then
        noinma = .true.
      else
        noinma = .false.
      endif
c
c====
c 2. decoupage en 8 des hexaedres dont les 6 faces sont coupees en 4
c====
c
      do 200 , lehexa = 1 , nbhepe
c
       if ( mod(hethex(lehexa),1000) .eq. 0 ) then
c
c 2.1. decoupage ?
c
        dt = 0
        do 21 , iaux = 1 , 6
          jaux = quahex(lehexa,iaux)
          if ( mod(hetqua(jaux),100).eq.4 .or.
     >         mod(hetqua(jaux),100).eq.99 ) then
            dt = dt + 1
          endif
   21   continue
c
        if ( dt.eq.6 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,1,6), lehexa
#endif
c
c 2.2. ==> description des 6 faces de l'hexaedre
c          quand le code cf vaut 1, on a defiqj(cf) = j-1
c          cela signifie que l'on presente ici les quadrangles dans
c          l'ordre de la filiation enregistree
c
c 2.2.1. ==> description de la face 1
c
          f1 = quahex(lehexa,1)
          cf1 = coquhe(lehexa,1)
c
c 2.2.1.1. ==> reperage des 4 quadrangles fils
c
          f1s2 = filqua(f1) + defiq1(cf1)
          f1s1 = filqua(f1) + defiq2(cf1)
          f1s4 = filqua(f1) + defiq3(cf1)
          f1s3 = filqua(f1) + defiq4(cf1)
#ifdef _DEBUG_HOMARD_
9998  format(a,i6,a,5i6)
9999  format(a,4i6)
      write (ulsort,9998) 'f1 = ', f1, ', cf1 = ', cf1
      write (ulsort,9999) 'defiq1(cf1) = ', defiq1(cf1)
      write (ulsort,9999) 'defiq2(cf1) = ', defiq2(cf1)
      write (ulsort,9999) 'defiq3(cf1) = ', defiq3(cf1)
      write (ulsort,9999) 'defiq4(cf1) = ', defiq4(cf1)
      write(ulsort,9999) 'f1s1, f1s2, f1s3, f1s4 ',f1s1,f1s2,f1s3,f1s4
#endif
c
c 2.2.1.2. ==> reperage des 4 aretes internes

          if ( cf1.lt.5 ) then
           n1nf1 = arequa(f1s2,2)
           n2nf1 = arequa(f1s1,2)
           n3nf1 = arequa(f1s3,2)
           n4nf1 = arequa(f1s4,2)
          else
           n1nf1 = arequa(f1s1,2)
           n2nf1 = arequa(f1s4,2)
           n3nf1 = arequa(f1s2,2)
           n4nf1 = arequa(f1s3,2)
          endif
c
c 2.2.2. ==> description de la face 2
c
          f2 = quahex(lehexa,2)
          cf2 = coquhe(lehexa,2)
c
c 2.2.2.1. ==> reperage des 4 quadrangles fils
c
          f2s1 = filqua(f2) + defiq1(cf2)
          f2s2 = filqua(f2) + defiq2(cf2)
          f2s5 = filqua(f2) + defiq3(cf2)
          f2s6 = filqua(f2) + defiq4(cf2)
#ifdef _DEBUG_HOMARD_
cgn        write(ulsort,*) 'f2s2, f2s1, f2s6, f2s5 ',f2s2,f2s1,f2s6,f2s5
        write(ulsort,9998) 'f2s2 : ',f2s2, ', aretes ',
     >  arequa(f2s2,1),arequa(f2s2,2),arequa(f2s2,3) ,arequa(f2s2,4)
        write(ulsort,9998) 'f2s1 : ',f2s1, ', aretes ',
     >  arequa(f2s1,1),arequa(f2s1,2),arequa(f2s1,3) ,arequa(f2s1,4)
        write(ulsort,9998) 'f2s6 : ',f2s6, ', aretes ',
     >  arequa(f2s6,1),arequa(f2s1,2),arequa(f2s6,3) ,arequa(f2s6,4)
        write(ulsort,9998) 'f2s5 : ',f2s5, ', aretes ',
     >  arequa(f2s5,1),arequa(f2s5,2),arequa(f2s5,3) ,arequa(f2s5,4)
#endif
c
c 2.2.2.2. ==> reperage des 4 aretes internes
c
          if ( cf2.lt.5 ) then
           n1nf2 = arequa(f2s1,2)
           n6nf2 = arequa(f2s2,2)
           n9nf2 = arequa(f2s5,2)
           n5nf2 = arequa(f2s6,2)
          else
           n1nf2 = arequa(f2s2,2)
           n6nf2 = arequa(f2s5,2)
           n9nf2 = arequa(f2s6,2)
           n5nf2 = arequa(f2s1,2)
          endif
#ifdef _DEBUG_HOMARD_
      write(ulsort,9999) 'n1nf2,n6nf2,n9nf2,n5nf2 ',
     >                    n1nf2,n6nf2,n9nf2,n5nf2
#endif
c
c 2.2.3. ==> description de la face 3
c
          f3 = quahex(lehexa,3)
          cf3 = coquhe(lehexa,3)
c
c 2.2.3.1. ==> reperage des 4 quadrangles fils
c
          f3s4 = filqua(f3) + defiq1(cf3)
          f3s1 = filqua(f3) + defiq2(cf3)
          f3s6 = filqua(f3) + defiq3(cf3)
          f3s7 = filqua(f3) + defiq4(cf3)
c        write(ulsort,*) 'f3s1, f3s4, f3s7, f3s6 ',f3s1,f3s4,f3s7,f3s6
c
c 2.2.3.2. ==> reperage des 4 aretes internes
c
         if ( cf3.lt.5 ) then
           n2nf3 = arequa(f3s4,2)
           n5nf3 = arequa(f3s1,2)
           n10nf3= arequa(f3s6,2)
           n7nf3 = arequa(f3s7,2)
          else
           n2nf3 = arequa(f3s1,2)
           n5nf3 = arequa(f3s6,2)
           n10nf3= arequa(f3s7,2)
           n7nf3 = arequa(f3s4,2)
          endif
c
c 2.2.4. ==> description de la face 4
c
          f4 = quahex(lehexa,4)
          cf4 = coquhe(lehexa,4)
c
c 2.2.4.1. ==> reperage des 4 quadrangles fils
c
          f4s2 = filqua(f4) + defiq1(cf4)
          f4s3 = filqua(f4) + defiq2(cf4)
          f4s8 = filqua(f4) + defiq3(cf4)
          f4s5 = filqua(f4) + defiq4(cf4)
c
c 2.2.4.2. ==> reperage des 4 aretes internes
c
         if ( cf4.lt.5 ) then
           n3nf4 = arequa(f4s2,2)
           n6nf4 = arequa(f4s5,2)
           n8nf4 = arequa(f4s3,2)
           n11nf4= arequa(f4s8,2)
         else
           n3nf4 = arequa(f4s3,2)
           n6nf4 = arequa(f4s2,2)
           n8nf4 = arequa(f4s8,2)
           n11nf4= arequa(f4s5,2)
          endif
c
c 2.2.5. ==> description de la face 5
c
          f5 = quahex(lehexa,5)
          cf5 = coquhe(lehexa,5)
c
c 2.2.5.1. ==> reperage des 4 quadrangles fils
c
          f5s3 = filqua(f5) + defiq1(cf5)
          f5s4 = filqua(f5) + defiq2(cf5)
          f5s7 = filqua(f5) + defiq3(cf5)
          f5s8 = filqua(f5) + defiq4(cf5)
c
c 2.2.5.2. ==> reperage des 4 aretes internes
c
         if ( cf5.lt.5 ) then
           n4nf5 = arequa(f5s3,2)
           n7nf5 = arequa(f5s4,2)
           n8nf5 = arequa(f5s8,2)
           n12nf5= arequa(f5s7,2)
         else
           n4nf5 = arequa(f5s4,2)
           n7nf5 = arequa(f5s7,2)
           n8nf5 = arequa(f5s3,2)
           n12nf5= arequa(f5s8,2)
          endif
c
c 2.2.6. ==> description de la face 6
c
          f6 = quahex(lehexa,6)
          cf6 = coquhe(lehexa,6)
c
c 2.2.6.1. ==> reperage des 4 quadrangles fils
c
          f6s6 = filqua(f6) + defiq1(cf6)
          f6s5 = filqua(f6) + defiq2(cf6)
          f6s8 = filqua(f6) + defiq3(cf6)
          f6s7 = filqua(f6) + defiq4(cf6)
c
c 2.2.6.2. ==> reperage des 4 aretes internes
c
         if ( cf6.lt.5 ) then
           n9nf6  = arequa(f6s6,2)
           n11nf6 = arequa(f6s5,2)
           n12nf6 = arequa(f6s8,2)
           n10nf6 = arequa(f6s7,2)
         else
           n9nf6  = arequa(f6s5,2)
           n11nf6 = arequa(f6s8,2)
           n12nf6 = arequa(f6s7,2)
           n10nf6 = arequa(f6s6,2)
          endif
c
#ifdef _DEBUG_HOMARD_
          write(ulsort,texte(langue,5)) f1,arequa(f1,1),arequa(f1,2)
     >         ,arequa(f1,3),arequa(f1,4),cf1
          write(ulsort,texte(langue,5)) f2,arequa(f2,1),arequa(f2,2)
     >         ,arequa(f2,3),arequa(f2,4),cf2
          write(ulsort,texte(langue,5)) f3,arequa(f3,1),arequa(f3,2)
     >         ,arequa(f3,3),arequa(f3,4),cf3
          write(ulsort,texte(langue,5)) f4,arequa(f4,1),arequa(f4,2)
     >         ,arequa(f4,3),arequa(f4,4),cf4
          write(ulsort,texte(langue,5)) f5,arequa(f5,1),arequa(f5,2)
     >         ,arequa(f5,3),arequa(f5,4),cf5
          write(ulsort,texte(langue,5)) f6,arequa(f6,1),arequa(f6,2)
     >         ,arequa(f6,3),arequa(f6,4),cf6
#endif
c
c 2.3. ==> noeuds milieux des faces de l'hexaedre
c
          nf1 = somare(2,n1nf1)
          nf2 = somare(2,n1nf2)
          nf3 = somare(2,n2nf3)
          nf4 = somare(2,n3nf4)
          nf5 = somare(2,n4nf5)
          nf6 = somare(2,n9nf6)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) nf1, nf2, nf3, nf4, nf5, nf6
#endif
c
c 2.4. ==> creation du noeud central
c          . on le cree au barycentre l'hexaedre s'il n'existe pas
c            en le calculant par le barycentre des milieux des faces.
c          . on le recupere sinon
c
          if ( noinma ) then
c
            n0 = ninhex(lehexa)
c
          else
c
            n0 = indnoe + 1
            arenoe(n0) = 0
            do 24 , iaux = 1 , 3
              coonoe(n0,iaux) = ( coonoe(nf1,iaux) +
     >                            coonoe(nf2,iaux) +
     >                            coonoe(nf3,iaux) +
     >                            coonoe(nf4,iaux) +
     >                            coonoe(nf5,iaux) +
     >                            coonoe(nf6,iaux) ) * unssix
   24       continue
            famnoe(n0) = 1
            hetnoe(n0) = 51
            indnoe = n0
c
          endif
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,7)) n0,
     >                         coonoe(n0,1),coonoe(n0,2),coonoe(n0,3)
#endif
c
c 2.5. ==> creation des aretes internes a l'hexaedre
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,8)) mess14(langue,3,1)
#endif
c
c 2.5.1. ==> leurs numeros
c
          nf1n0 = indare + 1
          nf2n0 = indare + 2
          nf3n0 = indare + 3
          nf4n0 = indare + 4
          nf5n0 = indare + 5
          nf6n0 = indare + 6
          indare = nf6n0
c
c 2.5.2. ==> les numeros de leurs sommets avec la convention ad'hoc
c
          somare(1,nf1n0) = nf1
          somare(2,nf1n0) = n0
          somare(1,nf2n0) = nf2
          somare(2,nf2n0) = n0
          somare(1,nf3n0) = nf3
          somare(2,nf3n0) = n0
          somare(1,nf4n0) = nf4
          somare(2,nf4n0) = n0
          somare(1,nf5n0) = nf5
          somare(2,nf5n0) = n0
          somare(1,nf6n0) = nf6
          somare(2,nf6n0) = n0
c
c 2.5.3. ==> leur famille : libre
c
          famare(nf1n0) = 1
          famare(nf2n0) = 1
          famare(nf3n0) = 1
          famare(nf4n0) = 1
          famare(nf5n0) = 1
          famare(nf6n0) = 1
c
c 2.5.4. ==> la parente
c
          hetare(nf1n0) = 50
          hetare(nf2n0) = 50
          hetare(nf3n0) = 50
          hetare(nf4n0) = 50
          hetare(nf5n0) = 50
          hetare(nf6n0) = 50
          merare(nf1n0) = 0
          merare(nf2n0) = 0
          merare(nf3n0) = 0
          merare(nf5n0) = 0
          merare(nf6n0) = 0
          merare(nf4n0) = 0
          filare(nf1n0) = 0
          filare(nf2n0) = 0
          filare(nf3n0) = 0
          filare(nf4n0) = 0
          filare(nf5n0) = 0
          filare(nf6n0) = 0
c
c 2.6. ==> creation des faces
c
c 2.6.1. ==> recuperation du niveau commun a tous les quadrangles fils
c
          niveau = nivqua(f1s1)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,8)) mess14(langue,3,4)
#endif
c
c 2.6.2. ==> creation des 12 faces
c         tous ces quadrangles sont crees avec le code arbitraire 1
c         et avec le meme niveau que les faces issues du decoupage
           codefa = 1
c
cgn           write(ulsort,*) 'indqua',indqua
cgn         write(ulsort,*) 'n5nf3, nf3n0, nf2n0, n5nf2 ',
cgn     >          n5nf3, nf3n0, nf2n0, n5nf2
c
          pf1n5 = indqua + 1
          call cmcqua ( arequa, famqua, hetqua, filqua, perqua, nivqua,
     >                  pf1n5, n5nf3, nf3n0, nf2n0, n5nf2
     >         , codefa, niveau )
c
          pf1n6 = indqua + 2
          call cmcqua ( arequa, famqua, hetqua, filqua, perqua, nivqua,
     >                  pf1n6, n6nf2, nf2n0, nf4n0, n6nf4
     >         , codefa, niveau )
c
          pf1n7 = indqua + 3
          call cmcqua ( arequa, famqua, hetqua, filqua, perqua, nivqua,
     >                  pf1n7, n7nf5, nf5n0, nf3n0, n7nf3
     >         , codefa, niveau )
c
          pf1n8 = indqua + 4
          call cmcqua ( arequa, famqua, hetqua, filqua, perqua, nivqua,
     >                  pf1n8, n8nf4, nf4n0, nf5n0, n8nf5
     >         , codefa, niveau )
c
          pf2n2 = indqua + 5
          call cmcqua ( arequa, famqua, hetqua, filqua, perqua, nivqua,
     >                  pf2n2, n2nf1, nf1n0, nf3n0, n2nf3
     >         , codefa, niveau )
c
          pf2n3 = indqua + 6
          call cmcqua ( arequa, famqua, hetqua, filqua, perqua, nivqua,
     >                  pf2n3, n3nf4, nf4n0, nf1n0, n3nf1
     >         , codefa, niveau )
c
          pf2n10 = indqua + 7
          call cmcqua ( arequa, famqua, hetqua, filqua, perqua, nivqua,
     >                  pf2n10, n10nf3, nf3n0, nf6n0, n10nf6
     >         , codefa, niveau )
c
          pf2n11 = indqua + 8
          call cmcqua ( arequa, famqua, hetqua, filqua, perqua, nivqua,
     >                  pf2n11, n11nf6, nf6n0, nf4n0, n11nf4
     >         , codefa, niveau )
c
          pf3n1 = indqua + 9
          call cmcqua ( arequa, famqua, hetqua, filqua, perqua, nivqua,
     >                  pf3n1, n1nf2, nf2n0, nf1n0, n1nf1
     >         , codefa, niveau )
c
          pf3n4 = indqua + 10
          call cmcqua ( arequa, famqua, hetqua, filqua, perqua, nivqua,
     >                  pf3n4, n4nf1, nf1n0, nf5n0, n4nf5
     >         , codefa, niveau )
c
          pf3n9 = indqua + 11
          call cmcqua ( arequa, famqua, hetqua, filqua, perqua, nivqua,
     >                  pf3n9, n9nf6, nf6n0, nf2n0, n9nf2
     >         , codefa, niveau )
c
          pf3n12 = indqua + 12
          call cmcqua ( arequa, famqua, hetqua, filqua, perqua, nivqua,
     >                  pf3n12, n12nf5, nf5n0, nf6n0, n12nf6
     >         , codefa, niveau )
c
          indqua = pf3n12
c
c 2.7. ==> creation des 8 hexaedres
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,9))
#endif
c
          iaux = famhex(lehexa)
c
cgn          write(ulsort,texte(langue,10)) indhex + 1,
cgn     >                    f1s1,   f2s1,   f3s1,
cgn     >                   pf3n1,  pf2n2,  pf1n5
          nuhexa = indhex + 1
          call cmchex ( quahex, coquhe, famhex,
     >                  hethex, filhex, perhex,
     >                    f1s1,   f2s1,   f3s1,
     >                   pf3n1,  pf2n2,  pf1n5,
     >                  cofh25(cf1), cofh18(cf2), cofh25(cf3),
     >                       8, 5, 8,
     >                  lehexa,   iaux, nuhexa )
c
cgn          write(ulsort,texte(langue,10)) indhex + 2,
cgn     >                    f1s2,   f2s2,  pf3n1,
cgn     >                    f4s2,  pf2n3,  pf1n6
          nuhexa = indhex + 2
          call cmchex ( quahex, coquhe, famhex,
     >                  hethex, filhex, perhex,
     >                    f1s2,   f2s2,  pf3n1,
     >                    f4s2,  pf2n3,  pf1n6,
     >                  cofh18(cf1), cofh25(cf2), 2,
     >                  cofh18(cf4), 8, 5,
     >                  lehexa,   iaux, nuhexa )
c
cgn          write(ulsort,texte(langue,10)) indhex + 3,
cgn     >                    f1s3,  pf2n3,  pf3n4,
cgn     >                    f4s3,   f5s3,  pf1n8
          nuhexa = indhex + 3
          call cmchex ( quahex, coquhe, famhex,
     >                  hethex, filhex, perhex,
     >                    f1s3,  pf2n3,  pf3n4,
     >                    f4s3,   f5s3,  pf1n8,
     >                  cofh47(cf1), 2, 1,
     >                  cofh25(cf4), cofh18(cf5), 6,
     >                  lehexa,   iaux, nuhexa )
c
cgn          write(ulsort,texte(langue,10)) indhex + 4,
cgn     >                    f1s4,  pf2n2,   f3s4,
cgn     >                   pf3n4,   f5s4,  pf1n7
          nuhexa = indhex + 4
          call cmchex ( quahex, coquhe, famhex,
     >                  hethex, filhex, perhex,
     >                    f1s4,  pf2n2,   f3s4,
     >                   pf3n4,   f5s4,  pf1n7,
     >                   cofh36(cf1), 1, cofh18(cf3),
     >                       5, cofh25(cf5), 7,
     >                  lehexa,   iaux, nuhexa )
c
cgn          write(ulsort,texte(langue,10)) indhex + 5,
cgn     >                   pf1n6,   f2s5,  pf3n9,
cgn     >                    f4s5, pf2n11,   f6s5
          nuhexa = indhex + 5
          call cmchex ( quahex, coquhe, famhex,
     >                  hethex, filhex, perhex,
     >                   pf1n6,   f2s5,  pf3n9,
     >                    f4s5, pf2n11,   f6s5,
     >                       1, cofh36(cf2), 3,
     >                  cofh47(cf4), 7, cofh25(cf6),
     >                  lehexa,   iaux, nuhexa )
c
cgn          write(ulsort,texte(langue,10)) indhex + 6,
cgn     >                   pf1n5,   f2s6,   f3s6,
cgn     >                   pf3n9, pf2n10,   f6s6
          nuhexa = indhex + 6
          call cmchex ( quahex, coquhe, famhex,
     >                  hethex, filhex, perhex,
     >                   pf1n5,   f2s6,   f3s6,
     >                   pf3n9, pf2n10,   f6s6,
     >                       2, cofh47(cf2), cofh36(cf3),
     >                       7, 6, cofh18(cf6),
     >                  lehexa,   iaux, nuhexa )
c
cgn          write(ulsort,texte(langue,10)) indhex + 7,
cgn     >                   pf1n7, pf2n10,   f3s7,
cgn     >                  pf3n12,   f5s7,   f6s7
          nuhexa = indhex + 7
          call cmchex ( quahex, coquhe, famhex,
     >                  hethex, filhex, perhex,
     >                   pf1n7, pf2n10,   f3s7,
     >                  pf3n12,   f5s7,   f6s7,
     >                       3, 4, cofh47(cf3),
     >                       6, cofh36(cf5), cofh47(cf6),
     >                  lehexa,   iaux, nuhexa )
c
cgn          write(ulsort,texte(langue,10)) indhex + 8,
cgn     >                   pf1n8, pf2n11, pf3n12,
cgn     >                    f4s8,   f5s8,   f6s8
          nuhexa = indhex + 8
          call cmchex ( quahex, coquhe, famhex,
     >                  hethex, filhex, perhex,
     >                   pf1n8, pf2n11, pf3n12,
     >                    f4s8,   f5s8,   f6s8,
     >                       4, 3, 4,
     >                  cofh36(cf4), cofh47(cf5), cofh36(cf6),
     >                  lehexa,   iaux, nuhexa )

          indhex = nuhexa

c 2.8. ==> mise a jour de l'hexaedre courant et de son pere eventuel
c
          filhex(lehexa) = indhex-7
          hethex(lehexa) = hethex(lehexa) + 8
          pere = perhex(lehexa)
          if ( pere .ne. 0 ) then
            etat = hethex(pere)
            hethex(pere) = etat - mod(etat,1000) + 9
          endif
cgn          stop
c
        endif
c
       endif
c
  200 continue
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
