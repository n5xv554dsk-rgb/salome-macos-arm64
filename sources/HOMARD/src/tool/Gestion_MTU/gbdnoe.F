      subroutine gbdnoe (nome,objrep,objter,chater,codret)
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
c     decodage d'un nom etentu 'nome' pour determiner
c     l'objet-repertoire,l'objet-terminal et le champ-terminal
c     (contexte MC)
c     ...........................................................
c
c     entrees :
c       nome  : character*(*) : nom etendu a decoder
c
c     ...........................................................
c
c     sorties :
c     objrep  : character*8 : objet repertoire
c     objter  : character*8 : objet terminal
c     chater  : character*8 : champ terminal
c     codret  : code de retour :
c       -1    : erreur : nom etendu non valide
c        0    : OK     : nom etendu n'a qu'un element :
c                        objter = nome
c                        objrep = '        '
c                        chater = '        '
c        1    : OK     : objet-terminal non defini :
c                        aucun objet n'a ete attache au
c                        champ-terminal dans l'objet-repertoire ;
c                        objter = indefini
c        2    : OK     : objet-terminal defini mais non alloue
c        3    : OK     : objet-terminal defini et alloue
c
c     ...........................................................
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
      parameter ( nompro = 'GBDNOE' )
c
c 0.2. ==> communs
c
#include "gminds.h"
#include "gmcoer.h"
#ifdef _DEBUG_HOMARD_
#include "gmimpr.h"
#endif
c
c 0.3. ==> arguments
c
      character*(*) nome
      character*8   objrep,objter,chater
c
      integer codret
c
c 0.4. ==> variables locales
c
#include "gmnelx.h"
c
      character*1 sepa(4)
      character*8 nomfis
      character*80 elem(nelx)
c
      integer lelm(nelx),nelm,lgtot,ns
      integer ipart,i,iel,codref,ityp,codrel
c
c 0.5. ==> initialisations
c
      data sepa /'.' , ' ' , ' ' , ' '/
c ______________________________________________________________________
c
c====
c 1.  decomposition du nom-etendu
c====
c
c 1.1. ==> recherche des differents champs du nom etendu
c          seul le premier separateur, '.', est pris en compte
c
      ns = 1
      call gbpart(nome,elem,lelm,nelm,lgtot,sepa,ns,ipart)
c
      if (ipart.eq.-1) then
         codret = -1
         goto 9999
      endif
c
c 1.2. ==> longueur des noms de chacun des champs <= 8
c
      do 12 , i = 1,nelm
         if (lelm(i).gt.8) then
            codret = -1
            goto 9999
         endif
   12 continue
c
c 1.3. ==> c'est une tete
c
      if (nelm.eq.1) then
c
         objter = elem(1)(1:8)
         objrep = '        '
         chater = '        '
         codret = 0
c
      else
c
c 1.4. ==> reperage des noms des differents champs
c
         objrep = elem(1)(1:8)
         do 14 iel = 2,nelm-1
            call gbdnof(objrep,elem(iel),nomfis,codref)
            objrep = nomfis
            if (codref.lt.0) then
               codret = -1
               goto 9999
            endif
   14    continue
c
c 1.5. ==> pour le dernier champ
c
         chater = elem(nelm)(1:8)
         call gbdnof(objrep,elem(iel),objter,codref)
c
         if (codref.eq.-1) then
c
            objter = sindef
            codret = 1
c
         else if (codref.eq.0) then
c
            call gbobal(objter,ityp,codrel)
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'apres gbobal ; codrel = ', codrel
#endif
            if (codrel.ge.1) then
               codret = 3
            else
               codret = 2
            endif
c
         else
c
            codret = -1
c
         endif
c
      endif
c
c 1.6. ==> sortie
c
 9999 continue
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.-1 ) then
         write (ulsort,*) 'Probleme dans ', nompro, ' :'
         write (ulsort,*) 'Ce nom etendu est invalide : ', nome
      endif
#endif
c
      end
