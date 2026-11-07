c
c 2.3.3. ==> face f1 : plan (s1,s2,s3,s4)
c            prmito est le produit mixte du triedre base sur s1
c            prmilo est le produit mixte pointant sur le noeud a tester.
c            il faut que prmito et prmilo soient de meme signe pour que
c            le noeud soit du meme cote du plan (s1,s2,s3,s4) que s6.
c            on teste le caractere strictement positif du produit
c            prmito x prmilo, pour pouvoir pieger les cas ou le
c            noeud est sur une face.
cgn      call gtdems (94)
c
            if ( logaux(7) ) then
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,90002) mess14(langue,2,-1), lenoeu
        endif
#endif
c
              daux1 = 0.d0
c
              if ( logaux(1) ) then
c
                v14(1) = v4(1)-v1(1)
                v14(2) = v4(2)-v1(2)
                v14(3) = v4(3)-v1(3)
c
                v12(1) = v2(1)-v1(1)
                v12(2) = v2(2)-v1(2)
                v12(3) = v2(3)-v1(3)
c
                v16(1) = v6(1)-v1(1)
                v16(2) = v6(2)-v1(2)
                v16(3) = v6(3)-v1(3)
c
c         v0(1,.) est le produit vectoriel s1s4 x s1s2.
c
                v0(1,1) = v14(2)*v12(3) - v14(3)*v12(2)
                v0(1,2) = v14(3)*v12(1) - v14(1)*v12(3)
                v0(1,3) = v14(1)*v12(2) - v14(2)*v12(1)
c
c         prmito est le produit mixte (s1s4,s1s2,s1s6)
c
                prmito = v0(1,1)*v16(1)
     >                 + v0(1,2)*v16(2)
     >                 + v0(1,3)*v16(3)
c
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,90004) 'v14    ', v14(1),v14(2),v14(3)
        write (ulsort,90004) 'v12    ', v12(1),v12(2),v12(3)
        write (ulsort,90004) 'v16    ', v16(1),v16(2),v16(3)
        write (ulsort,90004) 'v0(1,.)', v0(1,1),v0(1,2),v0(1,3)
        write (ulsort,90004) 'prmito ', prmito
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
c         prmilo est le produit mixte (s1s4,s1s2,s1sn)
c
              prmilo = v0(1,1)*(vn(1)-v1(1))
     >               + v0(1,2)*(vn(2)-v1(2))
     >               + v0(1,3)*(vn(3)-v1(3))
c
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
c        write (ulsort,90004) 'vn-v1',(vn(iaux)-v1(iaux),iaux=1,3)
        write (ulsort,90004) 'f1 prmilo', prmilo
        endif
#endif
cgn      call gtfims (94)
              if ( prmito*prmilo.lt.daux1 ) then
                logaux(7) = .false.
              endif
c
            endif
c
c 2.3.4. ==> idem pour la face f2 : plan (s1,s2,s5,s6)
cgn      call gtdems (95)
c
            if ( logaux(7) ) then
c
              if ( logaux(2) ) then
c
c         v0(2,.) est le produit vectoriel s1s2 x s1s6
c
                v0(2,1) = v12(2)*v16(3) - v12(3)*v16(2)
                v0(2,2) = v12(3)*v16(1) - v12(1)*v16(3)
                v0(2,3) = v12(1)*v16(2) - v12(2)*v16(1)
c
c         prmito est le produit mixte (s1s4,s1s2,s1s6)
c                                   = (s1s2,s1s6,s1s4)
c
                logaux(2) = .false.
c
              endif
c
c         prmilo est le produit mixte (s1s2,s1s6,s1sn)
c
              prmilo = v0(2,1)*(vn(1)-v1(1))
     >               + v0(2,2)*(vn(2)-v1(2))
     >               + v0(2,3)*(vn(3)-v1(3))
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,90004) 'f2 prmilo', prmilo
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
c 2.3.5. ==> idem pour la face f3 : plan (s1,s6,s7,s4)
cgn      call gtdems (96)
c
            if ( logaux(7) ) then
c
              if ( logaux(3) ) then
c
c         v0(3,.) est le produit vectoriel s1s6 x s1s4
c
                v0(3,1) = v16(2)*v14(3) - v16(3)*v14(2)
                v0(3,2) = v16(3)*v14(1) - v16(1)*v14(3)
                v0(3,3) = v16(1)*v14(2) - v16(2)*v14(1)
c
c         prmito est le produit mixte (s1s4,s1s2,s1s6)
c                                   = (s1s6,s1s4,s1s2)
c
                logaux(3) = .false.
c
              endif
c
c         prmilo est le produit mixte (s1s6,s1s4,s1sn)
c
              prmilo = v0(3,1)*(vn(1)-v1(1))
     >               + v0(3,2)*(vn(2)-v1(2))
     >               + v0(3,3)*(vn(3)-v1(3))
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,90004) 'f3 prmilo', prmilo
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
c 2.3.6. ==> idem pour la face f4 : plan (s2,s3,s8,s5)
cgn      call gtdems (97)
c
            if ( logaux(7) ) then
c
              if ( logaux(4) ) then
c
                v85(1) = v5(1)-v8(1)
                v85(2) = v5(2)-v8(2)
                v85(3) = v5(3)-v8(3)
c
                v83(1) = v3(1)-v8(1)
                v83(2) = v3(2)-v8(2)
                v83(3) = v3(3)-v8(3)
c
c         v0(4,.) est le produit vectoriel s8s5 x s8s3
c
                v0(4,1) = v85(2)*v83(3) - v85(3)*v83(2)
                v0(4,2) = v85(3)*v83(1) - v85(1)*v83(3)
                v0(4,3) = v85(1)*v83(2) - v85(2)*v83(1)
c
c         prmito est le produit mixte (s1s4,s1s2,s1s6)
c         vu la definition des 8 sommets de l'hexaedre, c'est la
c         meme valeur que le produit mixte (s8s5,s8s3,s8s7)
c
                logaux(4) = .false.
c
              endif
c
c         prmilo est le produit mixte (s8s5,s8s3,s8sn)
c
              prmilo = v0(4,1)*(vn(1)-v8(1))
     >               + v0(4,2)*(vn(2)-v8(2))
     >               + v0(4,3)*(vn(3)-v8(3))
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,90004) 'f4 prmilo', prmilo
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
c 2.3.7. ==> idem pour la face f5 : plan (s3,s4,s7,s8)
cgn      call gtdems (98)
c
            if ( logaux(7) ) then
c
              if ( logaux(5) ) then
c
                v87(1) = v7(1)-v8(1)
                v87(2) = v7(2)-v8(2)
                v87(3) = v7(3)-v8(3)
c
c         v0(5,.) est le produit vectoriel s8s3 x s8s7
c
                v0(5,1) = v83(2)*v87(3) - v83(3)*v87(2)
                v0(5,2) = v83(3)*v87(1) - v83(1)*v87(3)
                v0(5,3) = v83(1)*v87(2) - v83(2)*v87(1)
c
c         prmito est le produit mixte (s8s5,s8s3,s8s7)
c                                   = (s8s3,s8s7,s8s5)
c
                logaux(5) = .false.
c
              endif
c
c         prmilo est le produit mixte (s8s7,s8s3,s8sn)
c
              prmilo = v0(5,1)*(vn(1)-v8(1))
     >               + v0(5,2)*(vn(2)-v8(2))
     >               + v0(5,3)*(vn(3)-v8(3))
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,90004) 'f5 prmilo', prmilo
        endif
#endif
c
cgn      call gtfims (98)
              if ( prmito*prmilo.lt.daux1 ) then
                logaux(7) = .false.
              endif
c
            endif
c
c 2.3.8. ==> idem pour la face f6 : plan (s5,s8,s7,s6)
cgn      call gtdems (99)
c
            if ( logaux(7) ) then
c
              if ( logaux(6) ) then
c
c         v0(6,.) est le produit vectoriel s8s7 x s8s5
c
                v0(6,1) = v87(2)*v85(3) - v87(3)*v85(2)
                v0(6,2) = v87(3)*v85(1) - v87(1)*v85(3)
                v0(6,3) = v87(1)*v85(2) - v87(2)*v85(1)
c
c         prmito est le produit mixte (s8s5,s8s3,s8s7)
c                                   = (s8s7,s8s5,s8s3)
c
                logaux(6) = .false.
c
              endif
c
c         prmilo est le produit mixte (s8s7,s8s5,s8sn)
c
              prmilo = v0(6,1)*(vn(1)-v8(1))
     >               + v0(6,2)*(vn(2)-v8(2))
     >               + v0(6,3)*(vn(3)-v8(3))
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,90004) 'f6 prmilo', prmilo
        endif
#endif
c
cgn      call gtfims (99)
              if ( prmito*prmilo.lt.daux1 ) then
                logaux(7) = .false.
              endif
c
            endif
