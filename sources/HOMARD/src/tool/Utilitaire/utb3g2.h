c
c 2.3.4. ==> face f1 : plan (s1,s2,s3)
c            prmito est le produit mixte du triedre base sur s1
c            prmilo est le produit mixte pointant sur le noeud a tester.
c            il faut que prmito et prmilo soient de meme signe pour que
c            le noeud soit du meme cote du plan (s1,s2,s3) que s4.
c            on teste le caractere strictement positif du produit
c            prmito x prmilo, pour pouvoir pieger les cas ou le
c            noeud est sur une face.
cgn      call gtdems (94)
c
            if ( logaux(7) ) then
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,*) '.... ', mess14(langue,2,-1), lenoeu
        endif
#endif
c
              daux1 = 0.d0
c
              if ( logaux(1) ) then
c
                v12(1) = v2(1)-v1(1)
                v12(2) = v2(2)-v1(2)
                v12(3) = v2(3)-v1(3)
c
                v13(1) = v3(1)-v1(1)
                v13(2) = v3(2)-v1(2)
                v13(3) = v3(3)-v1(3)
c
                v14(1) = v4(1)-v1(1)
                v14(2) = v4(2)-v1(2)
                v14(3) = v4(3)-v1(3)
c
c         v0(1,.) est le produit vectoriel s1s2 x s1s3.
c
                v0(1,1) = v12(2)*v13(3) - v12(3)*v13(2)
                v0(1,2) = v12(3)*v13(1) - v12(1)*v13(3)
                v0(1,3) = v12(1)*v13(2) - v12(2)*v13(1)
c
c         prmito est le produit mixte (s1s2,s1s3,s1s4)
c
                prmito = v0(1,1)*v14(1)
     >                 + v0(1,2)*v14(2)
     >                 + v0(1,3)*v14(3)
c
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,*) '.... v12', v12(1),v12(2),v12(3)
        write (ulsort,*) '.... v14', v14(1),v14(2),v14(3)
        write (ulsort,*) '.... v13', v13(1),v13(2),v13(3)
        write (ulsort,*) '.... v0(1,.)', v0(1,1),v0(1,2),v0(1,3)
        write (ulsort,*) '.... ==> prmito =', prmito
        endif
#endif
c         si le produit mixte est nul, c'est que le volume est nul
c         on ne controle donc rien
c
                if ( prmito.le.daux1 ) then
                  goto 20
                endif
c
                logaux(1) = .false.
c
              endif
c
c         prmilo est le produit mixte (s1s2,s1s3,s1sn)
c
              prmilo = v0(1,1)*(vn(1)-v1(1))
     >               + v0(1,2)*(vn(2)-v1(2))
     >               + v0(1,3)*(vn(3)-v1(3))
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
c        write (ulsort,*) '....    vn-v1 =',(vn(iaux)-v1(iaux),iaux=1,3)
        write (ulsort,*) '....  f1 prmilo =', prmilo
        endif
#endif
c
cgn      call gtfims (94)
              if ( prmito*prmilo.lt.daux1 ) then
                logaux(7) = .false.
              endif
c
            endif
c
c 2.3.5. ==> idem pour la face f2 : plan (s4,s5,s6)
cgn      call gtdems (95)
c
            if ( logaux(7) ) then
c
              if ( logaux(2) ) then
c
                v54(1) = v4(1)-v5(1)
                v54(2) = v4(2)-v5(2)
                v54(3) = v4(3)-v5(3)
c
                v56(1) = v6(1)-v5(1)
                v56(2) = v6(2)-v5(2)
                v56(3) = v6(3)-v5(3)
c
c         v0(2,.) est le produit vectoriel s5s4 x s5s6
c
                v0(2,1) = v54(2)*v56(3) - v54(3)*v56(2)
                v0(2,2) = v54(3)*v56(1) - v54(1)*v56(3)
                v0(2,3) = v54(1)*v56(2) - v54(2)*v56(1)
c
c         prmito a ete calcule comme le produit mixte (s1s2,s1s3,s1s4)
c         vu la definition des 6 sommets du pentaedre, c'est la
c         meme valeur que le produit mixte (s5s4,s5s6,s5s2)
c
                logaux(2) = .false.
c
              endif
c
c         prmilo est le produit mixte (s5s4,s5s6,s5sn)
c
              prmilo = v0(2,1)*(vn(1)-v5(1))
     >               + v0(2,2)*(vn(2)-v5(2))
     >               + v0(2,3)*(vn(3)-v5(3))
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
c        write (ulsort,*) '....     vn-v5 =',(vn(iaux)-v5(iaux),iaux=1,3)
        write (ulsort,*) '....  f2 prmilo =', prmilo
        endif
#endif
c
cgn      call gtfims (95)
              if ( prmito*prmilo.lt.daux1 ) then
                logaux(7) = .false.
              endif
c
            endif
c
c 2.3.6. ==> idem pour la face f3 : plan (s1,s3,s6,s4)
cgn      call gtdems (96)
c
            if ( logaux(7) ) then
c
              if ( logaux(3) ) then
c
c         v0(3,.) est le produit vectoriel s1s3 x s1s4
c
                v0(3,1) = v13(2)*v14(3) - v13(3)*v14(2)
                v0(3,2) = v13(3)*v14(1) - v13(1)*v14(3)
                v0(3,3) = v13(1)*v14(2) - v13(2)*v14(1)
c
c         prmito est le produit mixte (s1s2,s1s3,s1s4)
c                                   = (s1s3,s1s4,s1s2)
c
                logaux(3) = .false.
c
              endif
c
c         prmilo est le produit mixte (s1s3,s1s4,s1sn)
c
              prmilo = v0(3,1)*(vn(1)-v1(1))
     >               + v0(3,2)*(vn(2)-v1(2))
     >               + v0(3,3)*(vn(3)-v1(3))
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
c        write (ulsort,*) '....     vn-v1 =',(vn(iaux)-v1(iaux),iaux=1,3)
        write (ulsort,*) '....  f3 prmilo =', prmilo
        endif
#endif
c
cgn      call gtfims (96)
              if ( prmito*prmilo.lt.daux1 ) then
                logaux(7) = .false.
              endif
c
            endif
c
c 2.3.7. ==> idem pour la face f4 : plan (s1,s2,s5,s4)
cgn      call gtdems (97)
c
            if ( logaux(7) ) then
c
              if ( logaux(4) ) then
c
c         v0(4,.) est le produit vectoriel s1s4 x s1s2
c
                v0(4,1) = v14(2)*v12(3) - v14(3)*v12(2)
                v0(4,2) = v14(3)*v12(1) - v14(1)*v12(3)
                v0(4,3) = v14(1)*v12(2) - v14(2)*v12(1)
c
c         prmito est le produit mixte (s1s2,s1s3,s1s4)
c                                   = (s1s4,s1s2,s1s3)
c
                logaux(4) = .false.
c
              endif
c
c         prmilo est le produit mixte (s1s4,s1s2,s1sn)
c
              prmilo = v0(4,1)*(vn(1)-v1(1))
     >               + v0(4,2)*(vn(2)-v1(2))
     >               + v0(4,3)*(vn(3)-v1(3))
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
c        write (ulsort,*) '....     vn-v1 =',(vn(iaux)-v1(iaux),iaux=1,3)
        write (ulsort,*) '....  f4 prmilo =', prmilo
        endif
#endif
c
cgn      call gtfims (97)
              if ( prmito*prmilo.lt.daux1 ) then
                logaux(7) = .false.
              endif
c
            endif
c
c 2.3.8. ==> idem pour la face f5 : plan (s2,s3,s6,s5)
cgn      call gtdems (97)
c
            if ( logaux(7) ) then
c
              if ( logaux(5) ) then
c
                v52(1) = v2(1)-v5(1)
                v52(2) = v2(2)-v5(2)
                v52(3) = v2(3)-v5(3)
c
c         v0(5,.) est le produit vectoriel s5s6 x s5s2
c
                v0(5,1) = v56(2)*v52(3) - v56(3)*v52(2)
                v0(5,2) = v56(3)*v52(1) - v56(1)*v52(3)
                v0(5,3) = v56(1)*v52(2) - v56(2)*v52(1)
c
c         prmito est le produit mixte (s1s2,s1s3,s1s4)
c         vu la definition des 6 sommets du pentaedre, c'est la
c         meme valeur que le produit mixte (s5s4,s5s6,s5s2)
c                                        = (s5s6,s5s2,s5s4)
c
                logaux(5) = .false.
c
              endif
c
c         prmilo est le produit mixte (s5s6,s5s2,s5sn)
c
              prmilo = v0(5,1)*(vn(1)-v5(1))
     >               + v0(5,2)*(vn(2)-v5(2))
     >               + v0(5,3)*(vn(3)-v5(3))
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
c        write (ulsort,*) '....     vn-v5 =',(vn(iaux)-v5(iaux),iaux=1,3)
        write (ulsort,*) '....  f5 prmilo =', prmilo
        endif
#endif
c
cgn      call gtfims (97)
              if ( prmito*prmilo.lt.daux1 ) then
                logaux(7) = .false.
              endif
c
            endif
