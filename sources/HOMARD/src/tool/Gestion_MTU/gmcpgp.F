      subroutine gmcpgp ( nom1, nom2, codret )
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
c     copier le graphe de l'objet 'nom1' simple ou structure
c     a la place du graphe de l'objet 'nom2' :
c     - si nom1 est un objet simple on ecrit simplement cet 
c       objet
c     - l'ancien graphe de nom2 est supprime, un nouveau graphe
c       est cree avec des noms nouveaux (sauf la racine) pour
c       recevoir le graphe de nom2
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nom1   . e   . char(*). nom etendu source                          .
c . nom2   . e   .char(*) . nom etendu destinataire                    .
c . codret .  s  . ent    . code retour de l'operation                 .
c .        .     .        .  0 : OK                                    .
c .        .     .        . -1 : 'nom1' invalide ou non alloue         .
c .        .     .        . -2 : objets destinataire et source ne sont .
c .        .     .        .      pas de meme type                      .
c .        .     .        . -3 : nom etendu invalide                   .
c .        .     .        . -4 : premier caractere interdit            .
c .        .     .        . -5 : dimensionnement insuffisant           .
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
      character*6 nompro
      parameter ( nompro = 'GMCPGP' )
c
c
#include "genbla.h"
c
c 0.2. ==> communs
c
#include "gminds.h"
c
#include "gmcoer.h"
#include "gmimpr.h"
#include "gmlang.h"
c
c 0.3. ==> arguments
c
      integer       codret
      character*(*) nom1, nom2
c
c 0.4. ==> variables locales
c
#include "gmixjx.h"
c
      integer iaux, jaux
      integer       i,nbj,ide1,ioa1,ity1,ide2,isup,igrp
      integer impopt, nbchem,j,nj1,i2,iadr,long1,jc,ieco,iato
      integer lgchem(ix)
c
      integer nrotab
      character*8   chemin(ix,jx), objet
      character*8   obrep1,obter1,chter1,racine
      character*8   obrep2,obter2,chter2
      character*8   obj1(nbjx), obj2(nbjx)
      character*8   letype
      character*90  chaine
      character*40  mess
c
      integer nbmess
      parameter ( nbmess = 20 )
      character*80 texte(nblang,nbmess)
c
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. messages
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,20) = '(1x,''Copie du graphe de l''''objet '',a8)'
      texte(1,4) = '(1x,''a la place du graphe de l''''objet '',a8)'
      texte(1,11) = '(1x,''Le premier objet est invalide.'')'
      texte(1,12) = '(1x,''Les deux objets ne sont pas de meme type.'')'
      texte(1,13) = '(1x,''Le second objet est invalide.'')'
      texte(1,14) = '(1x,''Premier caractere du 2nd nom interdit.'')'
      texte(1,15) = '(1x,''Dimensionnement insuffisant.'')'
c
      texte(2,20) = '(1x,''Copy of the graph of the object '',a8)'
      texte(2,4) = '(1x,''to the graph of the object '',a8)'
      texte(2,11) = '(1x,''The first object is not valid.'')'
      texte(2,12) = '(1x,''The types of 2 objects are different.'')'
      texte(2,13) = '(1x,''The second object is not valid.'')'
      texte(2,14) = '(1x,''1st character of 2nd name is forbidden.'')'
      texte(2,15) = '(1x,''Lack of central memory.'')'
c
c 1.  initialisation
c
      do 10 i = 1, nbjx
         obj1(i) = sindef
         obj2(i) = sindef
   10 continue
      nbj = 0
c
c 2.  ecrire d'abord l'objet 'nom1'
c
      call gmcpoj (nom1,nom2,codret)
      if (codret.lt.0) then
        goto 91
      endif
c
c     si objet simple : fini
c
      call gbdnoe(nom1,obrep1,obter1,chter1,ide1)
      call gbobal(obter1,ity1,ioa1)
      if (ioa1.eq.2) then
        goto 91
      endif
c
c 3.  supprimer le graphe de l'objet 'nom2' s'il existe
c
      if (nom2.eq.sindef) then
         codret = -3
         goto 91
      endif
      call gbdnoe(nom2,obrep2,obter2,chter2,ide2)
      call gasgmc(obter2,isup)
      if ((isup.ne.0).and.(isup.ne.-5)) then
         mess = ' gmcpgp -> gasgmc -> codret : '
         write(mess(29:30),'(i2)') isup
         write(ulsort,*) mess 
         call ugstop('gmcpgp',ulsort,1,1,1)
      endif
      racine = obter2
c
c 4   construction du graphe de 'nom1' 
c
#ifdef _DEBUG_HOMARD_
      impopt = 1
#else
      impopt = 0
#endif
c
      iaux = ix
      jaux = jx
      call gagpmc(obter1,iaux,jaux,chemin,lgchem,nbchem,impopt,igrp)
      if (igrp.lt.0) then
         mess = ' gmcpgp -> gagpmc -> codret : '
         write(mess(29:30),'(i2)') igrp
         write(ulsort,*) mess 
        call ugstop('gmcpgp',ulsort,1,1,1)
      endif
c
c 5.  ecrire le graphe de 'nom1' 
c
      do 50 i = 1, nbchem
         do 51 j = 3 , jx , 2
            if ( (chemin(i,j)(1:1).eq.'*') .or.
     >           (chemin(i,j)(1:1).eq.'=') .or.
     >           (chemin(i,j)(1:1).eq.'+') .or.
     >           (chemin(i,j)(1:1).eq.'-') .or.
     >           (chemin(i,j)(1:1).eq.'<')      ) then
              nj1 = j-1
              goto 20
            endif
   51    continue
         codret = -5
         goto 91
c
   20    continue
         i2  = 8
         chaine(1:i2) = racine
c 
         do 40 j = 2, nj1, 2
c 
            chaine = chaine(1:i2)//'.'//chemin(i,j-1)
            i2     = i2+9
            objet  = chemin(i,j)
c
            if (objet.eq.sindef) then
              goto 40
            else if (chemin(i,j+1)(1:1).eq.'=') then
              goto 40
            endif
            if (chemin(i,j+1)(1:1).eq.'*') then
               call gbcara(objet,nrotab,iadr,long1,letype)
               if (coergm.ne.0) then
                 goto 40
               endif
            endif
c
c           recherche si objet est deja ecrit
c
            do 41 jc = 1, nbj
               if (obj1(jc).eq.objet) then
                 jaux = jc
                 goto 30
               endif
   41       continue
c
c           si l'objet n'est pas ecrit : on l'ecrit
c
            call gmcpoj (objet,chaine(1:i2),ieco)
            if (ieco.lt.0) then
               mess = ' gmcpgp -> gmcpoj -> codret : '
               write(mess(29:30),'(i2)') ieco
               write(ulsort,*) mess 
               call ugstop('gmcpgp',ulsort,1,1,1)
            endif
c
c           mise a jour des tableaux obj1 et obj2
c
            call gbdnoe(chaine(1:i2),obrep2,obter2,chter2,ide2)
            nbj = nbj+1
            obj1(nbj) = objet
            obj2(nbj) = obter2
            goto 40
c
c           si l'objet est deja ecrit et si champ destinataire
c           est vide : y attacher l'objet disque deja ecrit 
c
   30       continue
            call gmatoj(chaine(1:i2),obj2(jaux),iato)
            if ((iato.ne.0).and.(iato.ne.-1)) then
               mess = ' gmcpgp -> gmatoj -> codret : '
               write(mess(29:30),'(i2)') iato
               write(ulsort,*) mess 
               call ugstop('gmcpgp',ulsort,1,1,1)
            endif
c
   40    continue
c
   50 continue
c
      codret = 0
c
c====
c 9. gestion des erreurs
c====
c
   91 continue
c
      if ( codret.ne.0 ) then
c
         iaux = 10+abs(codret)
c
         write (ulsort,90000)
        write (ulsort,texte(langue,1)) 'Sortie', nompro
         write (ulsort,texte(langue,20)) nom1
         write (ulsort,texte(langue,4)) nom2
         write (ulsort,texte(langue,iaux))
         write (ulsort,90000)
c
      endif
c
90000 format (1x,70('='))
c
      end
