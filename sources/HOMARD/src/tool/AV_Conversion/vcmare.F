      subroutine vcmare ( areele, somare, np2are,
     >                    hetare, filare, merare,
     >                    coexar, arenoe, insoar,
     >                    nnosho, nnosca, narsho,
     >                    narsca, fameel, noeele,
     >                    typele, povoso, voisom,
     >                    preare,
     >                    arsref, dearef, dejavu,
     >                    trav2a,
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
c    aVant adaptation - Conversion de Maillage - AREtes
c     -                 -             -          ---
c ______________________________________________________________________
c
c but : etablit la table de connectivite des mailles par arete
c       initialisation des tableaux lies aux aretes
c       Si l'estimation nbar00 est trop petite, on retourne une
c       valeur negative pour nbarto.
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . areele .  s  . nbelem . aretes des elements                        .
c .        .     .*nbmaae .                                            .
c . somare .  s  .2*nbar00. numeros des extremites d'arete             .
c . np2are .  s  . nbar00 . noeud milieux des aretes                   .
c . hetare .  s  . rbar00 . historique de l'etat des aretes            .
c . filare .  s  . rbar00 . premiere fille des aretes                  .
c . merare .  s  . rbar00 . mere des aretes                            .
c . coexar .  s  . nbar00*. codes externes sur les aretes              .
c .        .     . nctfar .   1 : famille MED                          .
c .        .     .        .   2 : type de segment                      .
c . arenoe . es  . nbnoto . 0 pour un sommet, le numero de l'arete pour.
c .        .     .        . un noeud milieu                            .
c . insoar .  s  . nbar00 . information sur les sommets des aretes     .
c .        .     .        .  0 : ses deux sommets appartiennent        .
c .        .     .        .      exclusivement a un element soumis a   .
c .        .     .        .      l'adaptation                          .
c .        .     .        . -1 : son 1er sommet appartient a un element.
c .        .     .        .      ignore                                .
c .        .     .        .      le 2nd sommet appartient exclusivement.
c .        .     .        .      a un element soumis a l'adaptation    .
c .        .     .        . -2 : son 2nd sommet appartient a un element.
c .        .     .        .      ignore                                .
c .        .     .        .      le 1er sommet appartient exclusivement.
c .        .     .        .      a un element soumis a l'adaptation
c .        .     .        .  2 : ses deux sommets appartiennent a un   .
c .        .     .        .      element ignore                        .
c . nnosho . e   . rsnoac . numero des noeuds dans HOMARD              .
c . nnosca . e   . rsnoto . numero des noeuds dans le calcul           .
c . narsho .  s  . rsarac . numero des aretes dans HOMARD              .
c . narsca .  s  . rbar00 . numero des aretes du calcul                .
c . fameel . e   . nbelem . famille med des elements                   .
c . noeele . e   . nbelem . noeuds des elements                        .
c .        .     .*nbmane .                                            .
c . typele . e   . nbelem . type des elements pour le code de calcul   .
c . povoso . e   .0:nbnoto. pointeur des voisins par sommet            .
c . voisom . e   . nvosom . voisins des sommets en stockage morse      .
c . preare .  a  . nbnoto . premiere arete partant d'un sommet         .
c . arsref . e   .0:tehmax. numero local de l'arete reliee a un sommet .
c .        .     . *10*3  . 1er champ : type de l'element de reference .
c .        .     .        . 2e champ : numero local du sommet concerne .
c .        .     .        . 3e champ : rang de l'arete envisagee       .
c . dearef . e   .0:tehmax. description des aretes par les numeros     .
c .        .     .  *6*3  . locaux des noeuds sans se preoccuper       .
c .        .     .        . d'orientation                              .
c .        .     .        .1er champ : type de l'element de reference  .
c .        .     .        .2e champ : numero local de l'arete envisagee.
c .        .     .        .3e champ : 1 et 2 pour chaque extremite,    .
c .        .     .        .           3 pour le milieu                 .
c . dejavu .  a  . rbar00 . controle des doublons                      .
c . trav2a . e   . nbnoto . tableau de travail numero 2                .
c .        .     .        . 1, pour un noeud appartenant a au moins un .
c .        .     .        .    element ignore
c .        .     .        . 0, sinon
c .        .     .        . Il servira dans vcmare                     .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 2313 : maille double                       .
c .        .     .        . 232 : noeud bizarre                        .
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
      parameter ( nompro = 'VCMARE' )
c
#include "coftex.h"
#include "referx.h"
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "dicfen.h"
#include "envca1.h"
#include "nbutil.h"
#include "nombno.h"
#include "refere.h"
#include "refert.h"
#include "nombar.h"
#include "nombsr.h"
#include "nomest.h"
#include "rftmed.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer areele(nbelem,nbmaae)
      integer somare(2,nbar00)
      integer np2are(nbar00)
      integer nnosho(rsnoac), nnosca(rsnoto)
      integer narsho(rsarac), narsca(rbar00)
      integer hetare(nbar00), filare(nbar00), insoar(nbar00)
      integer merare(nbar00)
      integer coexar(nbar00,nctfar)
      integer arenoe(nbnoto)
      integer fameel(nbelem), noeele(nbelem,nbmane), typele(nbelem)
      integer arsref(0:tehmax,10,3), dearef(0:tehmax,12,3)
      integer voisom(nvosom), povoso(0:nbnoto), preare(nbnoto)
      integer dejavu(nbar00)
      integer trav2a(rsnoto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer poinde, poinfi, point, nucode
      integer mloc, n, nbas, nbnd, nloc, mglo, sommet, milieu
      integer aloc, ar, larete, nuar, elem, typhom
#ifdef _DEBUG_HOMARD_
      integer glop
#endif
c
      integer nbmess
      parameter ( nbmess = 20 )
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
      texte(1,4) = '(/,''Les deux elements suivants sont doubles :'')'
      texte(1,5) = '(''Numero dans le calcul   : '',i10)'
      texte(1,6) = '(''Famille MED : '',i4,'' ; type : '',i4)'
      texte(1,7) =
     >'(''  Ses noeuds (numerotation du calcul) : '',/,10i10)'
      texte(1,8) =
     >'(''  Ses noeuds (numerotation HOMARD) : '',/,10i10)'
      texte(1,9) = '(''Le noeud'',i10,'' apparait plusieurs fois.'')'
      texte(1,10) =
     >'(''. Element voisin (numero du calcul)'',i10,'' ('',a,'')'')'
      texte(1,11) = '(''Estimation du nombre d''''aretes :'',i10)'
      texte(1,12) = '(''Ce nombre est trop petit.'')'
c
      texte(2,4) = '(/,''The following two elements are double:'')'
      texte(2,5) = '(''# in calculation    : '',i10)'
      texte(2,6) = '(''MED family : '',i4,'' ; type : '',i4)'
      texte(2,7) =
     > '(''  Its nodes (with calculation #) : '',/,10i10)'
      texte(2,8) =
     > '(''  Its nodes (with HOMARD #) : '',/,10i10)'
      texte(2,9) = '(''Node'',i10,'' is present several times.'')'
      texte(2,10) =
     >'(''. Neighbour element (calculation #)'',i10,'' ('',a,'')'')'
      texte(2,11) = '(''Estimation of the number of edges:'',i10)'
      texte(2,12) = '(''This number is too low.'')'
c
#include "impr03.h"
c
c 1.2. ==> mise a zero
c
      codret = 0
c
      do 11 , sommet = 1 , nbnoto
        preare(sommet) = 0
        arenoe(sommet) = 0
   11 continue
c
      do 12 , larete = 1 , rsarac
        narsho(larete) = 0
   12 continue
c
      do 13 , nucode = 1 , nctfar
        do 131 , larete = 1 , nbar00
          coexar(larete,nucode) = 0
  131   continue
   13 continue
c
      do 14 , larete = 1 , rbar00
        dejavu(larete) = 0
   14 continue
c
      nbarto = 0
c
c====
c 2. on passe en revue chaque sommet
c     remarque : l'exploration se fait dans la numerotation HOMARD
c     ses elements voisins sont dans le tableau voisom, aux places
c     comprises entre povoso(somm-1)+1 et povoso(somm), somm etant le
c     numero dans le calcul correspondant au numero sommet dans
c     homard
c     remarque : si on ne tenait pas compte de certains elements, les
c     quadrangles par exemple, cela est automatiquement traite avec
c     les tableaux povoso/voisom.
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. chaque sommet ; codret', codret
#endif
c
      do 21 , sommet = 1 , nbnoto
c
#ifdef _DEBUG_HOMARD_
        if ( sommet.le.0 ) then
          glop = 1
        else
          glop = 0
        endif
#endif
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,*) ' '
        write (ulsort,90002) mess14(langue,2,-1), sommet
        endif
#endif
c
        poinde = povoso(nnosca(sommet)-1) + 1
        poinfi = povoso(nnosca(sommet))

cgn        write(ulsort,90002) 'pointeur debut et fin', poinde, poinfi
c
        do 22 , point = poinde , poinfi
c
c 2.1. ==> caracterisation de l'element
c         elem : son numero global
c         typhom : son type dans HOMARD
c         nbnd : son nombre de noeuds
c
          elem = voisom(point)
          typhom = medtrf(typele(elem))
          nbnd = nbnref(typhom,1)
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        iaux = typhom + mod(typhom,2)
        iaux = iaux / 2
        write (ulsort,texte(langue,10)) elem, mess14(langue,1,iaux)
        write (ulsort,texte(langue,7)) (noeele(elem,n),n=1,nbnd)
        write (ulsort,texte(langue,8)) (nnosho(noeele(elem,n)),n=1,nbnd)
        endif
#endif
c
c 2.2. ==> recherche de nloc, numero local du sommet en cours d'examen
c          vis-a-vis de la description de l'element de reference
c
          do 221 , n = 1 , nbnd
            if ( sommet.eq.nnosho(noeele(elem,n)) ) then
              nloc = n
              goto 2211
            endif
  221     continue
 2211     continue
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
            write(*,*) '. pour no =',sommet, ', nloc =',nloc
        endif
#endif
c
c 2.3. ==> on explore toutes les aretes qui partent de ce sommet de
c         numero local nloc
c         nbas : le nombre d'aretes qui partent de chaque sommet
c         aloc : numero local de la a-eme arete envisagee
c         mloc : numero local de l'autre extremite
c         mglo : numero global de l'autre extremite, dans la
c                numerotation homard
c
          nbas = nasref(typhom)
c  ATTENTION : verrue pour le  dernier noeud de la pyramide
c
          if ( typhom.eq.tyhpy1 .or. typhom.eq.tyhpy2 ) then
            if ( nloc.eq.5 ) then
              nbas = nbas + 1
            endif
          endif
c
          do 223 , iaux = 1 , nbas
c
            aloc = arsref(typhom,nloc,iaux)
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
            write(*,*) '.. iaux =',iaux,', aloc =',aloc
        endif
#endif
            if ( dearef(typhom,aloc,1).eq.nloc ) then
              mloc = dearef(typhom,aloc,2)
            else
              mloc = dearef(typhom,aloc,1)
            endif
            mglo = nnosho(noeele(elem,mloc))
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
            write(*,*) '.. mglo =',mglo
        endif
#endif
c
c 2.3.1. ==> . si la seconde extremite a un numero global plus grand que
c            le sommet en cours d'examen, il faut chercher si l'arete
c            de sommet vers somm2 a deja ete cree.
c            la recherche de cette arete ne se fait pas parmi toutes les
c            aretes deja creees, mais seulement parmi celles qui partent
c            du sommet en cours. la premiere d'entre elles, si elle
c            existe, est numerotee nuar=preare(sommet). Ce sont les
c            dernieres aretes qui viennent d'etre creees, donc la
c            recherche est rapide car elle ne porte que sur quelques
c            aretes : au pire toutes celles partant du sommet en cours.
c            . si la seconde extremite a un numero global egal a celui
c            du sommet en cours d'examen, c'est qu'il y a un probleme
c            dans le maillage de depart.
c            . si la seconde extremite a un numero global plus petit que
c            le sommet en cours d'examen, rien n'est a faire, car le
c            traitement a deja ete fait lors de l'exploration de mglo.
c
            if ( sommet.lt.mglo ) then
c
c 2.3.1.1. ==> recherche d'une eventuelle arete qui aurait deja ete
c              creee entre sommet et mglo
c
              larete = 0
              nuar = preare(sommet)
              if ( nuar.ne.0 ) then
                do 2231 , ar = nuar , nbarto
                  if ( somare(2,ar).eq.mglo ) then
                    larete = ar
                    goto 2232
                  endif
 2231           continue
              endif
 2232         continue
c
c 2.3.1.2. ==> Lorsque l'arete n'a pas ete trouvee, il faut la creer ;
c              . elle est definie par ses deux extremites ;
c              . on memorise le noeud milieu si on est en degre 2 ;
c              . si l'arete n'est pas un element au sens du code de
c                calcul, la caracteristique est nulle et il n'y a pas
c                de probleme pour la renumerotation.
c              Si aucune arete ne partait deja du sommet, on la
c              memorise dans preare
c              remarque : il ne faut pas oublier de tenir compte d'une
c              eventuelle renumerotation des noeuds ; c'est fait
c              auparavant pour les deux extremites, sommet et mglo, et
c              il faut le faire pour le milieu eventuel.
c
              if ( larete.eq.0 ) then
                nbarto = nbarto + 1
                if ( nbarto.gt.nbar00 ) then
                  nbarto = - nbarto
                  goto 29
                endif
                larete = nbarto
                somare(1,larete) = sommet
                somare(2,larete) = mglo
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
          write(*,*) '... Creation de l''arete de ', sommet,' a ',mglo
          write(*,*) '... Elle a pour numero',larete
        endif
#endif
                if ( degre.eq.2 ) then
                  milieu = nnosho(noeele(elem,dearef(typhom,aloc,3)))
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
             write(*,*) '... Noeud milieu',milieu
        endif
#endif
                  np2are(larete) = milieu
                  arenoe(milieu) = larete
                endif
                if ( typhom.ne.tyhse1 .and. typhom.ne.tyhse2 ) then
                  coexar(larete,cofamd) = 0
                  coexar(larete,cotyel) = 0
                  if ( rbar00.ne.0 ) then
                    narsca(larete) = 0
                  endif
                endif
                if ( preare(sommet).eq.0 ) then
                  preare(sommet) = larete
                endif
              endif
c
c 2.3.1.3. ==> si l'arete est un element au sens du calcul, il faut
c              se souvenir de son type (linear beam, tapered beam, ...)
c              et de sa famille MED.
c              attention : il faut se poser la question a chaque fois,
c              car l'arete a pu etre definie auparavant comme un cote
c              de face et donc aura ete mise avec des caracteristiques
c              nulles.
c              en revanche, si on y est deja passe pour un autre
c              element, il y a malaise : c'est un element double !
c
              if ( typhom.eq.tyhse1 .or. typhom.eq.tyhse2 ) then
c
                if ( dejavu(larete).ne.0 .and.
     >               dejavu(larete).ne.elem ) then
c
                  write(ulsort,texte(langue,4))
                  write(ulsort,texte(langue,5)) elem
                  write(ulsort,texte(langue,6)) fameel(elem),
     >                                          typele(elem)
                  write(ulsort,texte(langue,7))
     >                              (noeele(elem,n),n=1,nbnd)
                  write(ulsort,texte(langue,8))
     >                              (nnosho(noeele(elem,n)),n=1,nbnd)
                  write(ulsort,texte(langue,5)) dejavu(larete)
                  write(ulsort,texte(langue,6)) fameel(dejavu(larete)),
     >                                          typele(dejavu(larete))
                  write(ulsort,texte(langue,8))
     >                              (noeele(dejavu(larete),n),n=1,nbnd)
                  write(ulsort,texte(langue,7))
     >                       (nnosho(noeele(dejavu(larete),n)),n=1,nbnd)
                  codret = 2313
c
                else
c
                  coexar(larete,cofamd) = fameel(elem)
                  coexar(larete,cotyel) = typele(elem)
                  narsho(elem) = larete
                  narsca(larete) = elem
                  dejavu(larete) = elem
c
                endif
c
              endif
c
c 2.3.1.4. ==> on stocke le numero de l'arete dans la connectivite
c              descendante de l'element
c
ccc         write(*,*) 'elem =',elem,', aloc =',aloc,', larete =',larete
              areele(elem,aloc) = larete
c
c 2.3.2. ==> probleme car le noeud apparait plusieurs fois
c
            elseif ( sommet.eq.mglo ) then
c
              write (ulsort,90002) mess14(langue,2,13), elem
              write(ulsort,texte(langue,9)) sommet
              write(ulsort,texte(langue,7)) (noeele(elem,n),n=1,nbnd)
              write(ulsort,texte(langue,7))
     >                  (nnosho(noeele(elem,n)),n=1,nbnd)
              write(ulsort,*) ' '
              codret = 232
              goto 22
c
            endif
c
  223     continue
c
   22   continue
c
   21 continue
c
   29 continue
c
c====
c 3. consequences
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. consequences ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbarto', nbarto
#endif
c
c 3.1. ==> initialisations :
c
c     . on suppose que l'on part d'un macro-maillage
c     . la premiere caracteristique a ete initialisee, les autres sont
c       initialisees a 0
c     . l'etat vaut 0
c     . il n'y a ni fille, ni mere
c
      nbarac = nbarto
      nbarma = nbarto
      nbarpe = nbarto
      nbarde = 0
      nbart2 = 0
      nbarq2 = 0
      nbarq3 = 0
      nbarq5 = 0
      nbarin = 0
c
      do 32 , larete = 1 , nbarto
        hetare(larete) = 0
        filare(larete) = 0
        merare(larete) = 0
   32 continue
c
c 3.2. ==> nombres propres a la renumerotation des aretes
c
      if ( rbar00 .ne. 0 ) then
        rsarto = nbarto
      else
        rsarto = 0
      endif
c
      endif
c
c====
c 4. Quand des elements sont ignores :
c     informations supplementaires sur les aretes
c            2 : ses deux sommets appartiennent a un element ignore
c           -1 : son 1er sommet appartient a un element ignore
c                le 2nd appartient exclusivement a un element soumis
c                a adaptation
c           -2 : son 2nd sommet appartient a un element ignore
c                le 1er appartient exclusivement a un element soumis
c                a adaptation
c            0 : ses deux sommets appartiennent exclusivement a un
c                element soumis a l'adaptation
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. ignores ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbelig.ne.0 ) then
c
        do 41 , larete = 1 , nbarto
c
          if ( trav2a(nnosca(somare(1,larete))).eq.1 ) then
            if ( trav2a(nnosca(somare(2,larete))).eq.1 ) then
              insoar(larete) = 2
            else
              insoar(larete) = -1
            endif
          elseif ( trav2a(nnosca(somare(2,larete))).eq.1 ) then
            insoar(larete) = -2
          else
            insoar(larete) = 0
          endif
cgn          print 1789,larete,nnosca(somare(1,larete)),
cgn     >        nnosca(somare(2,larete)),insoar(larete)
cgn 1789  format(4i5)
c
   41   continue
c
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( nbarto.lt.0 ) then
        write (ulsort,texte(langue,11)) nbar00
        write (ulsort,texte(langue,12))
      endif
#endif
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
