c
c 2.1. ==> les aretes et les sommets de cette pyramide active
c          vi(1->3) = coordonnees du sommet si
c
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,90002) mess14(langue,2,typenh), lapyra
cgn   write(ulsort,90112) 'faces',lapyra,(facpyr(lapyra,iaux),iaux=1,5)
        endif
#endif
c
          if ( lapyra.le.nbpycf ) then
c
            call utarpy ( lapyra,
     >                    nbtrto, nbpycf,
     >                    aretri, facpyr, cofapy,
     >                    listar )
c
          else
c
            do 210 , iaux = 1 , 8
              listar(iaux) = arepyr(lapyra-nbpycf,iaux)
  210       continue
c
          endif
c
          call utsopy ( somare, listar, sommet )
c
          if ( degre.eq.2 ) then
            do 211 , iaux = 1 , 8
              sommet(5+iaux) = np2are(listar(iaux))
  211       continue
          endif
c
c 2.2. ==> le parallelepipede enveloppe
c
          v1(1) = coonoe(sommet(1),1)
          v1(2) = coonoe(sommet(1),2)
          v1(3) = coonoe(sommet(1),3)
c
          v2(1) = coonoe(sommet(2),1)
          v2(2) = coonoe(sommet(2),2)
          v2(3) = coonoe(sommet(2),3)
c
          v3(1) = coonoe(sommet(3),1)
          v3(2) = coonoe(sommet(3),2)
          v3(3) = coonoe(sommet(3),3)
c
          v4(1) = coonoe(sommet(4),1)
          v4(2) = coonoe(sommet(4),2)
          v4(3) = coonoe(sommet(4),3)
c
          v5(1) = coonoe(sommet(5),1)
          v5(2) = coonoe(sommet(5),2)
          v5(3) = coonoe(sommet(5),3)
c
          xmin = min(v1(1),v2(1),v3(1),v4(1),v5(1))
          xmax = max(v1(1),v2(1),v3(1),v4(1),v5(1))
          ymin = min(v1(2),v2(2),v3(2),v4(2),v5(2))
          ymax = max(v1(2),v2(2),v3(2),v4(2),v5(2))
          zmin = min(v1(3),v2(3),v3(3),v4(3),v5(3))
          zmax = max(v1(3),v2(3),v3(3),v4(3),v5(3))
c
          logaux(1) = .true.
          logaux(2) = .true.
          logaux(3) = .true.
          logaux(4) = .true.
          logaux(5) = .true.
c
c 2.3. ==> on passe en revue tous les autres sommets qui ne sont pas des
c          sommets isoles.
c       . on ne s'interesse qu'a ceux qui sont contenus dans le
c         parallelepide enveloppe de la pyramide
c       . ensuite, on elimine les noeuds coincidents
c       . on recherche si le noeud est a l'interieur de la pyramide
c         cela est vrai si le noeud et un sommet sont du meme cote du
c         plan forme par les trois autres sommets. pour cela, on regarde
c         si les produits mixtes (ab,ac,ad) et (ab,ac,an) sont de meme
c         signe pour les quatre permutations circulaires sur (a,b,c,d)
c       . on elimine les cinq noeuds de la pyramide
c
c         Remarque hyper importante : il ne faut faire les affectations
c         de vn(2) et vn(3) que si c'est utile car elles coutent
c         tres cheres (30% du temps total !)
c         Remarque hyper importante : il vaut mieux mettre en dernier
c         le test sur l'identite de lenoeu avec les noeuds
c         de la pyramide car on gagne aussi 40% !
c         En revanche, inutile de deplier davantage les tests
c
cgn      call gtfims (93)
