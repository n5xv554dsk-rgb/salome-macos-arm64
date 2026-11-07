      subroutine pcfaa1 ( nbblqu,
     >                    nbattr, nbfold, nbfn00, nbfnew, nbfq00,
     >                    perqua, nivqua,
     >                    famqua, cfaqua,
     >                    ptabol, ptabne,
     >                    vattol, vattne,
     >                    nufmol, nufmne,
     >                    nofmol, nofmne,
     >                    descol, descne,
     >                    tabaux, lapile,
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
c    aPres adaptation - Conversion - FAmilles pour ATHENA - Phase 1
c     -                 -            --            -              -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbblqu . e   .   1    . nombre de blocs                            .
c . nbattr . e   .   1    . nombre d'attributs decrivant les familles  .
c . nbfn00 . e   .   1    . nouveau nombre de familles MED (estimation).
c . nbfnew .   s .   1    . nouveau nombre de familles MED             .
c . nbfold . e   .   1    . ancien nombre de familles MED              .
c . nbfq00 . e   .   1    . nouveau nombre de familles HOMARD pour     .
c .        .     .        . les quadrangles (estimation)               .
c . perqua . e   . nbquto . pere des quadrangles                       .
c . nivqua . e   . nbquto . niveau des quadrangles                     .
c . famqua . e   . nbquto . famille des quadrangles                    .
c . cfaqua . e   . nctfqu*. codes des familles des quadrangles         .
c .        .     . nbfqua .   1 : famille MED                          .
c .        .     .        .   2 : type de quadrangle                   .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        .   5 : famille des triangles de conformite  .
c .        .     .        .   6 : famille de sf active/inactive        .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . ptabol . e   .   *    . pointeur dans tables d'attributs (ancien)  .
c . ptabne .   s .   *    . pointeur dans tables d'attributs (nouveau) .
c . vattol . e   .   *    . table des valeurs des attributs (ancien)   .
c . vattne .   s .   *    . table des valeurs des attributs (nouveau)  .
c . nufmol . e   .   *    . numero de la famille MED (ancien)          .
c . nufmne .   s .   *    . numero de la famille MED (nouveau)         .
c . nofmol . e   .   *    . nom de la famille MED (ancien)             .
c . nofmne .   s .   *    . nom de la famille MED (nouveau)            .
c . descol . e   .   *    . description des attributs (ancien)         .
c . descne .   s .   *    . description des attributs (nouveau)        .
c . tabaux .  a  .   *    . tableau de travail                         .
c . lapile .  a  .   *    . tableau de travail                         .
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
      parameter ( nompro = 'PCFAA1' )
c
#include "nblang.h"
#include "coftex.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nbfami.h"
#include "nombqu.h"
#include "envada.h"
c
#include "dicfen.h"
c
c 0.3. ==> arguments
c
      integer nbblqu
      integer nbattr, nbfold, nbfn00, nbfnew, nbfq00
c
      integer perqua(nbquto), nivqua(nbquto)
c
      integer famqua(nbquto), cfaqua(nctfqu,nbfq00)
c
      integer ptabol(0:nbfold), ptabne(0:nbfn00)
      integer vattol(*), vattne(*)
      integer nufmol(nbfold), nufmne(nbfn00)
c
      integer tabaux(-nbquto:*), lapile(*)
c
      character*8 nofmol(*), nofmne(*)
      character*8 descol(*), descne(*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer lequad, lequ00
      integer lgpile
      integer iaux, jaux, kaux
      integer adrold, adrnew
      integer nubloc, niveau
      integer numfam, numfa0, nivboi, numboi, nuboim
      integer nfmed0, nromat
      integer fahope, fahoqu
      integer attri(4)
c
      logical cpcamf, prem, noufam
c
#ifdef _DEBUG_HOMARD_
      character*8 saux08
      character*64 saux64
#endif
      character*200 bla200
      character*200 descri(4)
c
      integer nbmess
      parameter ( nbmess = 20 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
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
      texte(1,4) = '(/,a14,'' : nombre de familles crees : '',i6)'
      texte(1,5) = '(/,''. Famille MED numero :'',i6,/,22(''-''))'
      texte(1,6) = '(/,60(''=''),/,''. Niveau numero'',i6,/,21(''-''))'
      texte(1,7) = '(''Ce nombre est superieur au maximum :'',i6)'
      texte(1,9) = '(/,''.. Bloc numero'',i6,/)'
      texte(1,10) = '(''Impossible de trouver la famille du pere'')'
      texte(1,11) = '(''Impossible de trouver le materiau du pere'')'
      texte(1,18) =
     >'(a,'' de la'',i6''-ieme famille MED, de numero'',i6)'
      texte(1,19) = '(/,''Nombre de familles MED crees : '',i6)'
      texte(1,20) = '(''Modifier le programme PCFAAT'',/)'
c
      texte(2,4) = '(/,a14,'' : number of created families : '',i6)'
      texte(2,5) = '(/,''. MED family #'',i6,/,14(''-''))'
      texte(2,6) = '(/,60(''=''),/,''. Level #'',i6,/,15(''-''))'
      texte(2,7) = '(''This number is greater than maximum :'',i6)'
      texte(2,9) = '(/,''.. Block #'',i6,/)'
      texte(2,10) = '(''Father family cannot be found.'')'
      texte(2,11) = '(''Father material cannot be found.'')'
      texte(2,18) =
     >'(a,'' of the'',i6,''th MED family, with #'',i6)'
      texte(2,19) = '(/,''Number of created MED families : '',i6)'
      texte(2,20) = '(''Modify PCFAAT program.'',/)'
c
cgn 1000 format(20i6)
cgn 1004 format(4i6)
cgn 2000 format('.... ',a,' = ',10i6)
c
      do 11 , iaux = 1 , 200
        bla200(iaux:iaux) = ' '
   11 continue
c
c====
c 2. les familles inchangees
c====
cgn      write (ulsort,1000) (ptabol(iaux),iaux=0,nbfold)
cgn      write (ulsort,1000) (vattol(iaux),iaux=1,nbattr*nbfold)
cgn      write (ulsort,*) (nofmol(iaux),iaux=1,4*nbfold)
cgn      write (ulsort,*) (descol(iaux),iaux=1,nbattr * 25 * (nbfold-1))
c
      nbfnew = 0
      ptabne(0) = 0
      prem = .true.
      numfa0 = 0
c
      if ( codret.eq.0 ) then
c
      do 21 , iaux = 1 , nbfold
c
        if ( codret.eq.0 ) then
c
        cpcamf = .false.
c
        numfam = nufmol(iaux)
c
#ifdef _DEBUG_HOMARD_
        write(ulsort,texte(langue,5)) numfam
#endif
c
c 2.1. ==> la famille nulle
c
        if ( numfam.eq.0 ) then
c
          nbfnew = nbfnew + 1
          ptabne(nbfnew) = ptabne(nbfnew-1)
          cpcamf = .true.
c
c 2.2. ==> une famille correspondant a une boite de niveau 0
c
        else
c
          nivboi = vattol(ptabol(iaux-1)+2)
          if ( nivboi.eq.0 ) then
            nbfnew = nbfnew + 1
            ptabne(nbfnew) = ptabne(nbfnew-1) + nbattr
            do 221 , jaux = 1 , nbattr
              vattne(ptabne(nbfnew-1)+jaux) =vattol(ptabol(iaux-1)+jaux)
              adrold = 25*(ptabol(iaux-1)+jaux-1)
              adrnew = 25*(ptabne(nbfnew-1)+jaux-1)
              do 222 , kaux = 1 , 25
                descne(adrnew+kaux) = descol(adrold+kaux)
  222         continue
  221       continue
            cpcamf = .true.
cgn            print *,vattol(ptabol(iaux-1)+3)
            if ( prem ) then
              numboi = vattol(ptabol(iaux-1)+3)
              prem = .false.
            else
              numboi = max(numboi,vattol(ptabol(iaux-1)+3))
            endif
          endif
c
        endif
c
c 2.3. ==> copie des caracteristiques de la famille
c
        if ( cpcamf ) then
c
#ifdef _DEBUG_HOMARD_
          write(ulsort,texte(langue,18)) 'Reproduction', nbfnew, numfam
#endif
          nofmne(10*(nbfnew-1)+1) = nofmol(10*(iaux-1)+1)
          nofmne(10*(nbfnew-1)+2) = nofmol(10*(iaux-1)+2)
          nofmne(10*(nbfnew-1)+3) = nofmol(10*(iaux-1)+3)
          nofmne(10*(nbfnew-1)+4) = nofmol(10*(iaux-1)+4)
          nofmne(10*(nbfnew-1)+5) = nofmol(10*(iaux-1)+5)
          nofmne(10*(nbfnew-1)+6) = nofmol(10*(iaux-1)+6)
          nofmne(10*(nbfnew-1)+7) = nofmol(10*(iaux-1)+7)
          nofmne(10*(nbfnew-1)+8) = nofmol(10*(iaux-1)+8)
          nufmne(nbfnew) = numfam
          numfa0 = max(numfa0,abs(numfam))
c
#ifdef _DEBUG_HOMARD_
c
          if ( codret.eq.0 ) then
c
          saux64 = nofmne(10*(nbfnew-1)+1)//nofmne(10*(nbfnew-1)+2)//
     >             nofmne(10*(nbfnew-1)+3)//nofmne(10*(nbfnew-1)+4)//
     >             nofmne(10*(nbfnew-1)+5)//nofmne(10*(nbfnew-1)+6)//
     >             nofmne(10*(nbfnew-1)+7)//nofmne(10*(nbfnew-1)+8)
          call utinfm ( numfam, saux64,
     >                  0, saux08,
     >                  -1, -1,
     >                  ulsort, langue, codret )
c
          endif
#endif
c
        endif
c
        endif
c
   21 continue
c
      numfam = -numfa0
c
      endif
cgn        write(ulsort,2000) '.. vattne apres copie du depart'
cgn        write(ulsort,1004) (vattne(iaux),iaux=1,nbattr*(nbfnew-1))
c
c====
c 3. creation des nouvelles boites, en allant des niveaux inferieurs
c    vers les niveaux superieurs
c    Il est fondamental d'aller dans cet ordre pour memoriser les
c    parentes des boites
c    un bloc equivaut a une boite. mais cette boite peut etre repartie
c    sur plusieurs familles med si elle recouvre des materiaux
c    differents
c    Remarque : si on est parti d'un macro-maillage non conforme,
c               certains quadrangles ont des peres adoptifs de numero
c               negatif. on ne court pas le risque d'utiliser un tel
c               pere car on ne s'interesse qu'a des peres de quadrangles
c               de niveau au moins egal a 1
c====
c
      if ( codret.eq.0 ) then
c
      do 30 , niveau = 1 , nivsup
c
#ifdef _DEBUG_HOMARD_
        write(ulsort,texte(langue,6)) niveau
#endif
c
        do 300 , nubloc = 1, nbblqu
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,texte(langue,9)) nubloc
#endif
c
c 3.1. ==> Le bloc est-il du bon niveau ?
c          On repere le premier quadrangle concerne
c
        do 31 , lequad = 1 , nbquto
c
          if ( tabaux(-lequad).eq.nubloc .and.
     >         nivqua(lequad).eq.niveau ) then
            lequ00 = lequad
cgn        write(ulsort,2000) 'lequ00', lequ00
            goto 320
          endif
c
   31   continue
c
        goto 300
c
c 3.2. ==> Ce bloc est une nouvelle boite
c
  320   continue
c
        nivboi = niveau
        numboi = numboi + 1
c
cgn        write(ulsort,2000) 'numboi', numboi
cgn        write(ulsort,2000) 'nivboi', nivboi
c
c 3.2.1. ==> recherche de la boite mere : c'est la boite du pere du
c            premier quadrangle. C'est ici qu'il est important de monter
c            dans les niveaux pour avoir des numeros de boite a jour.
c
        fahope = famqua(perqua(lequ00))
cgn        write(ulsort,2000) 'fahope', fahope
        jaux = cfaqua(cofamd,fahope)
cgn        write(ulsort,2000) 'jaux', jaux
        do 321 , iaux = 1 , nbfnew
          if ( nufmne(iaux).eq.jaux ) then
            nuboim = vattne(ptabne(iaux-1)+3)
            goto 3210
          endif
  321   continue
c
        write (ulsort,texte(langue,10))
        codret = 5
        goto 40
c
 3210   continue
c
cgn        write(ulsort,2000) 'nuboim', nuboim
c
c 3.2.2. ==> les caracteristiques immuables
c
        do 322 , iaux = 1 , nbattr
          descri(iaux) = bla200
#ifdef _DEBUG_HOMARD_
          descri(iaux)(198:200) = 'FIN'
#endif
  322   continue
c                          123456789012345678
        descri(1)(1:18) = 'Numero du materiau'
        descri(2)(1:18) = 'Niveau de la boite'
        attri(2) = nivboi
c                          123456789012345678
        descri(3)(1:18) = 'Numero de la boite'
        attri(3) = numboi
c                          12345678901234567890123
        descri(4)(1:23) = 'Numero de la boite mere'
        attri(4) = nuboim
c
c 3.2.3. ==> on parcourt tous les quadrangles de ce bloc
c            par heritage du raffinement, chaque quadrangle est deja
c            dans une famille HOMARD. On en deduit les caracteristiques
c            de la famille MED associ�e.
c
        lgpile = 0
c
        do 323 , lequad = lequ00 , nbquto
c
          if ( codret.eq.0 ) then
c
          if ( tabaux(-lequad).eq.nubloc ) then
c
cgn        write(ulsort,*) '********************************'
cgn        write(ulsort,2000) 'quadrangle', lequad
c
c 3.2.3.1. ==> par heritage du raffinement, ce quadrangle lequad est de
c              la meme famille homard que son pere. On utilise sa
c              famille MED initiale pour retrouver le materiau.
c
cgn        write(ulsort,2000) 'perqua(lequad)', perqua(lequad)
cgn        write(ulsort,2000) 'famqua(..)', famqua(perqua(lequad))
            fahope = famqua(perqua(lequad))
            nfmed0 = cfaqua(cofamd,fahope)
cgn        write(ulsort,2000) 'nfmed0', nfmed0
cgn        write(ulsort,2000) '.. vattne'
cgn        write(ulsort,1004) (vattne(iaux),iaux=1,nbattr*(nbfnew-1))
            do 32311 , iaux = 1 , nbfnew
              if ( nufmne(iaux).eq.nfmed0 ) then
                nromat = vattne(ptabne(iaux-1)+1)
                goto 32312
              endif
32311       continue
c
            write (ulsort,texte(langue,11))
            codret = 5
            goto 40
c
32312       continue
cgn        write(ulsort,2000) 'nromat', nromat
c
c 3.2.3.2. ==> On recherche dans les nouvelles familles MED creees s'il
c              en existe une avec les memes caracteristiques que celle
c              voulue pour ce quadrangle
c              Attention, l'orientation est importante pour HOMARD,
c              mais sans interet pour les boites.
c
            noufam = .true.
c
cgn        write(ulsort,1007) (lapile(iaux),iaux=1,lgpile * (nctfqu+3))
cgn        write(ulsort,2000) 'mate voulu',nromat
cgn        write(ulsort,2000) 'boit voulu',numboi
cgn        write(ulsort,2000) 'cara voulu',
cgn     > (cfaqua(jaux,fahope),jaux=1,nctfqu)
c
            do 32321 , iaux = 1 , lgpile
c
cgn        write(ulsort,2000) '.. Famille',iaux
              kaux = (iaux-1) * (nctfqu+3)
c
c             controle du materiau et du numero de boite
cgn        write(ulsort,2000) '.... materiau',lapile(kaux+2)
cgn        write(ulsort,2000) '.... boite   ',lapile(kaux+3)
              if ( lapile(kaux+2).ne.nromat .or.
     >             lapile(kaux+3).ne.numboi ) then
                goto 32321
              endif
c
c             controle des caracteristiques HOMARD
              do 32322 , jaux = 1 , nctfqu
cgn        write(ulsort,2000) '.... cara  ',lapile(kaux+3+jaux)
                if ( jaux.ne.cofamd ) then
                  if ( lapile(kaux+3+jaux).ne.cfaqua(jaux,fahope) ) then
                    goto 32321
                  endif
                endif
32322         continue
c
              noufam = .false.
c
c             c'est la bonne famille MED, on repere le numero de la
c             famille homard et on passe a l'element suivant.
c
              fahoqu = lapile(kaux+1)
              goto 3235
c
32321       continue
c
c 3.2.3.3. ==> creation d'une nouvelle famille med
c
            if ( codret.eq.0 ) then
c
            if ( noufam ) then
c
              call pcfaa3 ( nbblqu, nbfold, nbfnew, numfam,
     >                      nromat, numboi, nbattr, attri, descri,
     >                      ptabne, vattne,
     >                      nufmne, nofmne, descne,
     >                      ulsort, langue, codret )
c
            endif
c
            endif
c
c 3.2.3.4. ==> creation d'une nouvelle famille homard
c
            if ( codret.eq.0 ) then
c
              call pcfaa2 ( fahope, numfam, nromat, numboi,
     >                      cfaqua, lgpile, lapile,
     >                      ulsort, langue, codret )
c
            endif
c
            if ( codret.eq.0 ) then
c
              fahoqu = nbfqua
c
            endif
c
c 3.2.3.5. ==> affectation du numero de famille homard au quadrangle
c
 3235       continue
c
cgn            write(ulsort,2000) '===> fahoqu', fahoqu
cgn               if ( lequad.eq.15001 ) then
cgn            write(ulsort,2000) '===> fahoqu', fahoqu
cgn               endif
            famqua(lequad) = fahoqu
c
          endif
c
          endif
c
  323   continue
c
  300   continue
c
   30 continue
c
      endif
cgn      write(ulsort,2000) 'famqua(..)', famqua(    1)
cgn      write(ulsort,2000) 'nbquto', nbquto
cgn      write(ulsort,2000) 'famqua(..)', famqua(nbquto)
c
c====
c 4. la fin
c====
c
   40 continue
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
