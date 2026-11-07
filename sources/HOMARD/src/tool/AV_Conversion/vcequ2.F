      subroutine vcequ2 ( noehom, arehom,
     >                    trihom, quahom,
     >                    somare, np2are,
     >                    aretri, arequa,
     >                    posifa, facare,
     >                    povoso, voisom,
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
c    aVant adaptation Conversion - EQUivalence - phase 2
c     -               -            ---                 -
c
c    remarque : ce traitement suppose qu'une entite ne possede pas plus
c               d'un homologue. Si des cas plus compliques apparaissent,
c               il faudra modifier la structure des equivalences
c
c    on enrichit la structure pour pouvoir passer l'algorithme et la
c    reconstruction future. pour chaque triangle homologue, on repere
c    les trois aretes et on les declare homologues. Idem pour les
c    aretes des quadrangles. Idem pour les noeuds des aretes.
c    si on ne fait pas cette operation, on est incapable d'associer les 
c    filles des entites homologues. On ne saura pas apparier dans le
c    bon sens.
c    attention, on ne fait pas le processus dans l'autre sens : deduire
c    des equivalences sur des aretes a partir d'equivalences sur les
c    noeuds reviendrait a extrapoler les informations donnees en entree.
c
c   remarque importante : reperage des elements homologues
c     on prend la convention de reperage suivante : lorsque
c     l'on a deux faces periodiques 1 et 2, on attribue un signe a
c     chacune des faces. pour un noeud "i", noehom(i) est alors egal
c     a la valeur suivante :
c     - "le numero du noeud correspondant par periodicite
c        si i est sur la face 2"
c     - "l'oppose du numero du noeud correspondant par periodicite
c        si i est sur la face 1"
c
c     Donc, on etend cette convention a toutes les entites noeuds,
c     aretes et triangles :
c     enthom(i) = abs(homologue(i)) ssi i est sur la face 2
c     enthom(i) = -abs(homologue(i)) ssi i est sur la face 1
c     pour une entite situee sur l'axe, on prend la convention positive.
c
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . noehom . es  . nbnoto . liste etendue des homologues par noeuds    .
c . arehom . es  . nbarto . liste etendue des homologues par aretes    .
c . trihom . es  . nbtrto . ensemble des triangles homologues          .
c . quahom . es  . nbquto . ensemble des quadrangles homologues        .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . np2are . e   . nbarto . numero du noeud milieu de l'arete          .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . posifa . e   . nbarto . pointeur sur tableau facare                .
c . facare . e   . nbfaar . liste des faces contenant une arete        .
c . povoso . e   .0:nbnoto. pointeur des voisins par sommet            .
c . voisom . e   . nvosom . elements 1d, 2d ou 3d voisins par sommet   .
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
      parameter ( nompro = 'VCEQU2' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nbutil.h"
#include "envca1.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer noehom(nbnoto), arehom(nbarto)
      integer trihom(nbtrto), quahom(nbquto)
      integer somare(2,nbarto), np2are(nbarto)
      integer aretri(nbtrto,3), arequa(nbquto,4)
      integer posifa(0:nbarto), facare(nbfaar) 
      integer povoso(0:nbnoto), voisom(nvosom)
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer entlo1, entlo2
      integer iaux, jaux
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
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,5) = '(''Infos donnees en numerotation HOMARD'')'
      texte(1,6) = '(a,i10,'' est homologue de'',i10)'
      texte(1,7) = '(/,''Equivalence sur les '',a)'
      texte(1,8) =
     > '(''. Nombre de '',a,''homologues enregistres :'',i2)'
      texte(1,9) = '(/,''. Analyse des '',a,i10,'' et'',i10)'
c
      texte(2,5) = '(''Infos given with HOMARD #'')'
      texte(2,6) = '(a,i10,'' is homologous with'',i10)'
      texte(2,7) = '(/,''Equivalence for '',a)'
      texte(2,8) = '(''. Number of known homologous '',a,'' :'',i2)'
      texte(2,9) = '(/,''. Analysis of '',a,i10,'' and'',i10)'
c
      codret = 0
c
c====
c 2. enrichissement de la structure sur les aretes a partir de la
c    donnee des triangles et quadrangles homologues
c====
c
      if ( homolo.ge.3 ) then
c
#ifdef _DEBUG_HOMARD_
        if ( nbeqtr.gt.0 ) then
        write (ulsort,texte(langue,7)) mess14(langue,3,2)
        write (ulsort,texte(langue,5))
        do 20001 , iaux = 1 , nbtrto
          if ( trihom(iaux).ne.0 ) then
            write (ulsort,texte(langue,6)) mess14(langue,2,2),
     >                                    iaux, trihom(iaux)
          endif
20001   continue
        endif
        if ( nbeqqu.gt.0 ) then
        write (ulsort,texte(langue,7)) mess14(langue,3,4)
        write (ulsort,texte(langue,5))
        do 20002 , iaux = 1 , nbquto
          if ( quahom(iaux).ne.0 ) then
            write (ulsort,texte(langue,6)) mess14(langue,2,4),
     >                                    iaux, quahom(iaux)
          endif
20002   continue
        endif
#endif
c
c 2.1. ==> on commence par traiter les triangles et les quadrangles
c          qui ne sont pas dans un coin de maillage. Autrement dit, il
c          ne faut pas que deux de leurs aretes soient au bord
c
c 2.1.1. ==> les triangles
c
        if ( nbeqtr.gt.0 ) then
c
          if ( codret.eq.0 ) then
c
          iaux = 2
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCEQU4_tr', nompro
#endif
          call vcequ4 ( iaux,
     >                  arehom,
     >                  trihom, quahom,
     >                  aretri, arequa,
     >                  posifa, facare,
     >                  ulsort, langue, codret )
cgn           print *,nompro,' apres 2.1.1'
cgn           print *,'arehom'
cgn           print 1789,(arehom(iaux),iaux=1,50)
c
          endif
c
        endif
cgn 1787 format(4I4)
cgn 1788 format(8I4)
cgn 1789 format(10I4)
c
c 2.1.2. ==> les quadrangles
c
        if ( nbeqqu.gt.0 ) then
c
          if ( codret.eq.0 ) then
c
          iaux = 4
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCEQU4_qu', nompro
#endif
          call vcequ4 ( iaux,
     >                  arehom,
     >                  trihom, quahom,
     >                  aretri, arequa,
     >                  posifa, facare,
     >                  ulsort, langue, codret )
c
cgn           print *,nompro,' apres 2.1.2'
cgn           print *,'arehom'
cgn           print 1789,(arehom(iaux),iaux=1,50)
          endif
c
        endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,7)) mess14(langue,3,1)
        write (ulsort,texte(langue,5))
        do 21000 , iaux = 1 , nbarto
          if ( arehom(iaux).ne.0 ) then
            write (ulsort,texte(langue,6)) mess14(langue,2,1),
     >                                    iaux, arehom(iaux)
          endif
21000   continue
#endif
c
c 2.2. ==> a partir de cette premiere mise en equivalence des aretes,
c          on reporte l'information sur les noeuds
c          on boucle uniquement sur les aretes de la face periodique 2
c
        if ( codret.eq.0 ) then
c
        do 22 , entlo2 = 1 , nbarto
c
          if ( codret.eq.0 ) then
c
          entlo1 = arehom(entlo2)
c
          if ( entlo1.gt.0 ) then
c
            jaux = entlo2
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCEQU5', nompro
#endif
            call vcequ5 ( entlo1, jaux,
     >                    noehom, arehom,
     >                    somare, np2are,
     >                    povoso, voisom,
     >                    ulsort, langue, codret )
c
          endif
c
          endif
c
   22   continue
cgn           print *,nompro,' apres 2.2'
cgn           print *,'noehom'
cgn           print 1789,(noehom(iaux),iaux=1,27)
c
        endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,7)) mess14(langue,3,-1)
        write (ulsort,texte(langue,5))
        do 22000 , iaux = 1 , nbnoto
          if ( noehom(iaux).ne.0 ) then
            write (ulsort,texte(langue,6)) mess14(langue,2,-1),
     >                                    iaux, noehom(iaux)
          endif
22000   continue
#endif
c
c 2.3. ==> maintenant que l'on a transfere l'information sur les noeuds,
c          on s'occupe des triangles ou quadrangles de coin
c
c 2.3.1. ==> les triangles
c
        if ( nbeqtr.gt.0 ) then
c
          if ( codret.eq.0 ) then
c
          iaux = 2
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCEQU6_tr', nompro
#endif
          call vcequ6 ( iaux,
     >                  noehom, arehom,
     >                  trihom, quahom,
     >                  somare, aretri, arequa,
     >                  ulsort, langue, codret )
c
cgn           print *,nompro,' apres 2.3.1'
cgn           print *,'arehom'
cgn           print 1789,(arehom(iaux),iaux=1,50)
c
          endif
c
        endif
c
c 2.3.2. ==> les quadrangles
c
        if ( nbeqqu.gt.0 ) then
c
          if ( codret.eq.0 ) then
c
          iaux = 4
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCEQU6_qu', nompro
#endif
          call vcequ6 ( iaux,
     >                  noehom, arehom,
     >                  trihom, quahom,
     >                  somare, aretri, arequa,
     >                  ulsort, langue, codret )
c
cgn           print *,nompro,' apres 2.3.2'
cgn           print *,'arehom'
cgn           print 1789,(arehom(iaux),iaux=1,50)
c
          endif
c
        endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,7)) mess14(langue,3,1)
        write (ulsort,texte(langue,5))
        do 23000 , iaux = 1 , nbarto
          if ( arehom(iaux).ne.0 ) then
            write (ulsort,texte(langue,6)) mess14(langue,2,1),
     >                                    iaux, arehom(iaux)
          endif
23000   continue
#endif
c
c 2.4. ==> on verifie que toutes les aretes bordant des triangles
c          ou des quadrangles ont bien ete enregistrees
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCEQU7', nompro
#endif
        call vcequ7 ( arehom,
     >                trihom, quahom,
     >                aretri, arequa,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c====
c 3. enrichissement de la structure sur les noeuds a partir de la
c    donnee des aretes homologues. cette donnee est soit issue du
c    maillage a analyser, soit creee/enrichie par le traitement des
c    triangles et des quadrangles homologues.
c    il faut faire cette etape apres celle sur les triangles et les
c    quadrangles, sinon on oublie de l'information
c====
c
      if ( codret.eq.0 ) then
c
      if ( homolo.ge.2 ) then
c
        do 31 , entlo2 = 1 , nbarto
c
          entlo1 = arehom(entlo2)
c
          if ( entlo1.gt.0 ) then
c
            jaux = entlo2
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCEQU5', nompro
#endif
            call vcequ5 ( entlo1, jaux,
     >                    noehom, arehom,
     >                    somare, np2are,
     >                    povoso, voisom,
     >                    ulsort, langue, codret )
c
          endif
c
   31   continue
c
cgn        print *,nompro,' apres 3'
cgn        print *,'noehom'
cgn        print 1789,(noehom(iaux),iaux=1,27)
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,7)) mess14(langue,3,-1)
        write (ulsort,texte(langue,5))
        do 30000 , iaux = 1 , nbnoto
          if ( noehom(iaux).ne.0 ) then
            write (ulsort,texte(langue,6)) mess14(langue,2,-1),
     >                                    iaux, noehom(iaux)
          endif
30000   continue
#endif
c
      endif
c
      endif
c
c====
c 4. decompte du nombre de paires d'entites homologues
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTHONH', nompro
#endif
      call uthonh ( noehom, arehom,
     >              trihom, quahom,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 5. la fin
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
