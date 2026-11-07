      subroutine sfliso ( numnoe, lignoe, abscno,
     >                    unst2x, epsid2,
     >                    coonoe,
     >                    somare, hetare, filare, np2are,
     >                    cfaare, famare,
     >                    geocoo, abscur,
     >                    somseg, seglig, segnoe,
     >                    ulsort, langue, codret)
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
c   Suivi de Frontiere - LIen des SOmmets
c   -        -           --       --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . numnoe .  s  . mcnvnf . liste des noeuds de calcul de frontiere    .
c . lignoe .  s  . mcnvnf . liste lignes pour ces noeuds               .
c . abscno .  s  . mcnvnf . abscisse curviligne de ces noeuds          .
c . unst2x . e   .   1    . inverse de la taille maximale au carre     .
c . epsid2 . e   .   1    . precision relative pour carre de distance  .
c . coonoe . es  . nbnoto . coordonnees des noeuds                     .
c .        .     . *sdim  .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . filare . e   . nbarto . premiere fille des aretes                  .
c . np2are . e   . nbarto . noeud milieux des aretes                   .
c . cfaare . e   . nctfar*. codes des familles des aretes              .
c .        .     . nbfare .   1 : famille MED                          .
c .        .     .        .   2 : type de segment                      .
c .        .     .        .   3 : orientation                          .
c .        .     .        .   4 : famille d'orientation inverse        .
c .        .     .        .   5 : numero de ligne de frontiere         .
c .        .     .        .  > 0 si concernee par le suivi de frontiere.
c .        .     .        . <= 0 si non concernee                      .
c .        .     .        .   6 : famille frontiere active/inactive    .
c .        .     .        .   7 : numero de surface de frontiere       .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . famare . es  . nbarto . famille des aretes                         .
c . geocoo . e   .sfnbso**. coordonnees des sommets de la frontiere    .
c . abscur . e   . sfnbse . abscisse curviligne des somm des segments  .
c . somseg . e   . sfnbse . liste des sommets des lignes separees par  .
c                           des 0                                      .
c . seglig . e   .0:sfnbli. pointeur dans le tableau somseg : les      .
c .        .     .        . segments de la ligne i sont aux places de  .
c .        .     .        . seglig(i-1)+1 a seglig(i)-1 inclus         .
c . segnoe . aux . nbnoto . segments lies aux noeuds                   .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . x : probleme                               .
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
      parameter ( nompro = 'SFLISO' )
c
#include "nblang.h"
#include "cofaar.h"
#include "cofina.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "envca1.h"
#include "front1.h"
#include "front2.h"
#include "dicfen.h"
#include "nbfami.h"
#include "nombno.h"
#include "nombar.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      double precision unst2x, epsid2
      double precision coonoe(nbnoto,sdim), geocoo(sfnbso,*)
      double precision abscno(mcnxnf)
      double precision abscur(sfnbse)
c
      integer numnoe(mcnxnf), lignoe(mcnxnf)
      integer seglig(0:sfnbli), somseg(sfnbse)
      integer segnoe(nbnoto)
      integer somare(2,nbarto), hetare(nbarto), filare(nbarto)
      integer np2are(nbarto)
      integer famare(nbarto), cfaare(nctfar,nbfare)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer lenoeu, larete
      integer seg, segm(3)
      integer lig, ligv
      integer nbsomm
      integer nbar00
#ifdef _DEBUG_HOMARD_
      integer glop
      common / tutu / glop
#endif
c
      double precision coop(3), acnoeu
c
      integer nbmess
      parameter ( nbmess = 20 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. messages
c====
c 1.1. ==> les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''. Nombre de '',a,'' du maillage :'',i10)'
      texte(1,5) = '(''Boucle sur les aretes'')'
      texte(1,6) = '(/,''Arete'',i10,'', sur la ligne'',i10)'
      texte(1,7) =
     >'(/,'' .. Examen du noeud du cote'',i2,'' :'',i10,'', seg ='',i5)'
      texte(1,9) = '(6x,''Une arete est de longueur'')'
      texte(1,10) = '(i5,'' aretes sont de longueur'')'
      texte(1,11) =
     > '(6x,''inferieure a la discretisation de la frontiere'')'
      texte(1,12) = '(a,'' Inhibition du sf sur l''''arete'',i10)'
      texte(1,20) =
     >'(5x,''Examen des noeuds situes sur des extremites de ligne'')'
c
      texte(2,4) = '(''. Number of '',a,'' in mesh :'',i10)'
      texte(2,5) = '(''Loop over edges'')'
      texte(2,6) = '(/,''Edge #'',i10,'', on line'',i10)'
      texte(2,7) =
     > '(/,'' .. Examination of node #'',i2,'' #'',i10,'', seg ='',i5)'
      texte(2,9) = '(6x,''One edge is with length'')'
      texte(2,10) = '(i5,'' edges are with length'')'
      texte(2,11) =
     > '(6x,''lower than the discretization of the boundary'')'
      texte(2,12) = '(a,'' Inhibition of bf for the edge #'',i10)'
      texte(2,20) = '(5x,''Examination of nodes located on lines'')'
c
#include "impr03.h"
c
c 1.2. ==> a priori, aucun segment n'est attache a un noeud
c
      do 12 , lenoeu = 1 , nbnoto
        segnoe(lenoeu) = 0
   12 continue
c
      if ( typsfr.le.2 ) then
        nbsomm = 2
      else
        nbsomm = 3
      endif
c
      nbar00 = 0
c
      mcnvnf = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,-1), nbnoto
      write (ulsort,texte(langue,4)) mess14(langue,3,1), nbarto
#endif
c
cgn        write(ulsort,90002) 'somseg', somseg
#ifdef _DEBUG_HOMARD_
      do 13 , iaux = 1, sfnbli
        write(ulsort,90002) 'somseg pour la ligne numero', iaux
        jaux = 0
        do 131 , seg = seglig(iaux-1)+1, seglig(iaux)-1
          jaux = jaux + 1
          write(ulsort,90012) '.. sommet numero', jaux, somseg(seg)
  131   continue
   13 continue
#endif
c
c====
c 2. Boucle sur les aretes qui sont actives et positionnees sur
c    une ligne de frontiere
c    On va situer les sommets sur la ligne
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2. boucle sur les aretes ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5))
#endif
c
      do 20 , larete = 1 , nbarto
c
#ifdef _DEBUG_HOMARD_
c          if ( larete.le.0 .or.
c     >         ( larete.eq.1 .or. larete.eq.8  .or.
c     >           larete.eq.9  ) ) then
          if ( larete.le.0 ) then
            glop = 1
          else
            glop = 0
          endif
#endif
c
        lig = cfaare(cosfli,famare(larete))
#ifdef _DEBUG_HOMARD_
          if ( glop.ne.0 ) then
      write (ulsort,texte(langue,6)) larete, lig
            endif
#endif
c
        if ( lig.gt.0 ) then
c
        if ( hetare(larete).ne.50 ) then
#ifdef _DEBUG_HOMARD_
          if ( glop.ne.0 ) then
      iaux = seglig(lig-1) + 1
      jaux = seglig(lig)
      write (ulsort,90002) 'Sommets extremites de cette ligne',
     >somseg(iaux), somseg(jaux-1)
            endif
#endif
c
c On parcourt les noeuds de l'arete
c
          do 200 , jaux = 1 , nbsomm
c
c 2.1. ==> Le noeud et son segment initial
c
            if ( codret.eq.0 ) then
c
            if ( jaux.le.2 ) then
              lenoeu = somare(jaux,larete)
            else
              lenoeu = np2are(larete)
            endif
            seg = segnoe(lenoeu)
#ifdef _DEBUG_HOMARD_
          if ( glop.ne.0 ) then
            write (ulsort,texte(langue,7)) jaux, lenoeu, seg
            if ( seg.lt.0 ) then
              write (ulsort,90002)
     >        'Le noeud est une extremite de la ligne', lig
            elseif ( seg.eq.0 ) then
              write (ulsort,*) '... Ce noeud n''est pas encore place.'
            else
              write (ulsort,90002)
     >        'Le noeud a deja ete place sur le segment', seg
            endif
          endif
#endif
c
c 2.2. ==> Le noeud est une extremite de ligne ou n'a pas ete place
c
            if ( seg.le.0 ) then
c
              do 221 , iaux = 1 , sdim
                coop(iaux) = coonoe(lenoeu,iaux)
  221         continue
c
#ifdef _DEBUG_HOMARD_
              if ( glop.ne.0 ) then
      write (ulsort,90024) 'apres 221, coop du noeud',
     >                     lenoeu, (coop(iaux),iaux=1,sdim)
              endif
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFSENO', nompro
#endif
              call sfseno ( coop, lig, unst2x, epsid2,
     >                      seglig, somseg, geocoo, abscur,
     >                      seg, acnoeu )
c
#ifdef _DEBUG_HOMARD_
              if ( glop.ne.0 ) then
      write (ulsort,90024) 'apres appel a sfseno, coop du noeud',
     >                     lenoeu, (coop(iaux),iaux=1,sdim)
      write (ulsort,90004) '==> acnoeu', acnoeu
      write (ulsort,90002) 'Ce noeud a ete mis sur le segment', seg
              endif
#endif
              segm(jaux) = seg
c
              if ( seg.ne.0 ) then
c
                do 222 , iaux = 1 , mcnvnf
                  if ( numnoe(iaux).eq.lenoeu ) then
                    if ( lignoe(iaux).eq.lig ) then
cgn       write (ulsort,*) '     enregistrement deja fait'
                     goto 200
                    endif
                  endif
  222           continue
c
                segnoe(lenoeu) = seg
c
                mcnvnf = mcnvnf + 1
cgn      write (ulsort,90002) '   enregistrement a la position', mcnvnf
                numnoe(mcnvnf) = lenoeu
                lignoe(mcnvnf) = lig
                abscno(mcnvnf) = acnoeu
c               les noeuds sont forces sur la frontiere
cgn                acnoeu=0.d0
cgn                do 2222 , iaux = 1 , sdim
cgn                acnoeu = acnoeu+(coonoe(lenoeu,iaux)-coop(iaux))**2
cgn 2222           continue
cgn                write (ulsort,*) 223, lenoeu,acnoeu
#ifdef _DEBUG_HOMARD_
          if ( glop.ne.0 .or. lenoeu.eq.-102 ) then
      write (ulsort,90024) 'avant 222, coonoe du noeud',
     >                     lenoeu, (coonoe(lenoeu,iaux),iaux=1,sdim)
         endif
#endif
                do 223 , iaux = 1 , sdim
cgn               write (ulsort,*) iaux,coonoe(lenoeu,iaux),coop(iaux)
                  coonoe(lenoeu,iaux) = coop(iaux)
  223           continue
#ifdef _DEBUG_HOMARD_
          if ( glop.ne.0 .or. lenoeu.eq.-102 ) then
      write (ulsort,90024) 'apres 223, coonoe du noeud',
     >                     lenoeu, (coonoe(lenoeu,iaux),iaux=1,sdim)
         endif
#endif
#ifdef _DEBUG_HOMARD_
c
              else
c
                codret = codret + 1
#endif
c
              endif
c
c 2.3. ==> Le noeud est deja situe sur un segment interieur
c          De quelle ligne ?
c
            else
#ifdef _DEBUG_HOMARD_
          if ( glop.ne.0 .or. lenoeu.eq.-102 ) then
      write (ulsort,90024) ' .... Noeud',
     >                     lenoeu,(coonoe(lenoeu,iaux),iaux=1,sdim)
      write (ulsort,*) 'deja sur le segment ',seg
              endif
#endif
c
              call sflise( ligv, seg, seglig,
     >                     ulsort, langue, codret)
c
              if ( codret.eq.0 ) then
c
              if ( ligv.eq.lig ) then
c
c 2.3.1 ==> meme ligne : pas de probleme
c
                segm(jaux) = seg
c
              else
c
c 2.3.2 ==> autre ligne : on le retire
c
                segm(jaux) = 0
c
              endif
c
              endif
c
            endif
c
            endif
c
  200     continue
c
c 2.4. ==> Combien de noeuds de l'arete pointent sur la ligne ?
c
          if ( codret.eq.0 ) then
c
          if ( segm(1).eq.0 .and. segm(2).eq.0 ) then
c
c 2.4.1. ==> Aucun : impression, et prohibition du sf
c
20100 format(7x,'Arete',i10,' (',2i10,') ->',i4,': ',
     > 'un sommet n''est pas situe')
             write(ulsort,20100)
     >       larete,(somare(iaux,larete),iaux=1,2),lig
             iaux = cfaare(cosfin,famare(larete))
             famare(larete) = iaux
#ifdef _DEBUG_HOMARD_
             if ( glop.ne.0 ) then
             write(ulsort,texte(langue,12)) '2.4.1', larete
             endif
#endif
             if ( mod(hetare(larete),10).eq.2 ) then
               do 241 , iaux = 0 , 1
                 jaux = cfaare(cosfin,famare(filare(larete)+iaux))
                 famare(filare(larete)+iaux) = jaux
#ifdef _DEBUG_HOMARD_
             if ( glop.ne.0 ) then
             write(ulsort,texte(langue,12)) '2.4.1',filare(larete)+iaux
             endif
#endif
  241          continue
             endif
c
          elseif ( abs(segm(1)).eq.abs(segm(2)) ) then
c
c 2.4.2. ==> Les deux ; et ils pointent vers le meme segment
c            Il ne sert plus a rien de suivre la frontiere pour
c            cette arete : on a atteint la discretisation minimale
c
#ifdef _DEBUG_HOMARD_
             if ( glop.ne.0 ) then
20200 format(7x,'Arete',i10,' (',2i10,') ->',i4,': ',
     > 'meme segment',i10)
             write(ulsort,20200)
     >       larete,(somare(iaux,larete),iaux=1,2),lig,abs(segm(1))
             write(ulsort,texte(langue,12)) '2.4.2', larete
             endif
#endif
             nbar00 = nbar00 + 1
             iaux = cfaare(cosfin,famare(larete))
             famare(larete) = iaux
             if ( mod(hetare(larete),10).eq.2 ) then
               do 242 , iaux = 0 , 1
                 jaux = cfaare(cosfin,famare(filare(larete)+iaux))
                 famare(filare(larete)+iaux) = jaux
#ifdef _DEBUG_HOMARD_
             if ( glop.ne.0 ) then
             write(ulsort,texte(langue,12)) '2.4.2',filare(larete)+iaux
             endif
#endif
  242          continue
             endif
c
          endif
c
          endif
c
        endif
c
        endif
c
   20 continue
c
      endif
c
c====
c 3. impressions
c====
#ifdef _DEBUG_HOMARD_
      write(ulsort,*) '3. impressions, codret =', codret
#endif
c
      if ( nbar00.ne.0 ) then
        if ( nbar00.eq.1 ) then
          write (ulsort,texte(langue,9))
        else
          write (ulsort,texte(langue,10)) nbar00
        endif
        write (ulsort,texte(langue,11))
      endif
c
c====
c 4. la fin
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


