c                   .                         .
c                  ...                       . .
c                 . . .                     .   .
c                .  .  .                   . +i  .
c             j .   .   . k    ===>     j ......... k
c              .    .    .               . .     . .
c             . +a  . +b  .             .   .+0 .   .
c            .      .      .           . +k  . . +j  .
c           .................         .................
c                   i                        i
c
          elseif ( etanp1.eq.4 .or.
     >             etanp1.eq.6 .or. etanp1.eq.7 .or. etanp1.eq.8 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', 'pcstr2_3'
      write (ulsort,*) 'etanp1 = ',etanp1
      write (ulsort,*) 'etan   = ',etan
#endif
            f1hp = filtri(trhnp1)
            f1cp = ntrsca(f1hp)
            f2cp = ntrsca(f1hp+1)
            f3cp = ntrsca(f1hp+2)
            f4cp = ntrsca(f1hp+3)
            prfcap(f1cp) = 1
cgn            print *,'triangle fils NF = ',f1hp
cgn            print *,'triangle fils en calcul 1 = ',f1cp
cgn            print *,'triangle fils en calcul 2 = ',f2cp
cgn            print *,'triangle fils en calcul 3 = ',f3cp
cgn            print *,'triangle fils en calcul 4 = ',f4cp

c        Decoupage en 4 d'un triangle predecoupe en 2 par l'arete a1
c
            if ( etan.eq.1 ) then
c
            do 23411 , nrofon = 1 , nbfonc
c
c           Pour le fils aine (centre)
c
              vafott(nrofon,q1,f1cp) =
     >        unsde*(vafoen(nrofon,q2,prf1cn)+vafoen(nrofon,q3,prf2cn))
c
              vafott(nrofon,q2,f1cp) = vafoen(nrofon,q6,prf1cn)
c
              vafott(nrofon,q3,f1cp) = vafoen(nrofon,q4,prf2cn)
c
              vafott(nrofon,q4,f1cp) = 
     >        -unshu*(vafoen(nrofon,q1,prf1cn)+
     >                vafoen(nrofon,q3,prf1cn))+
     >         unsde*(vafoen(nrofon,q4,prf1cn)+
     >                vafoen(nrofon,q5,prf1cn))+
     >         unsqu*vafoen(nrofon,q6,prf1cn)
c
              vafott(nrofon,q5,f1cp) =
     >         unsde*(vafoen(nrofon,q4,prf1cn)+
     >                vafoen(nrofon,q6,prf2cn))
c
              vafott(nrofon,q6,f1cp) =
     >        -unshu*(vafoen(nrofon,q1,prf2cn)+
     >                vafoen(nrofon,q2,prf2cn))+
     >         unsde*(vafoen(nrofon,q5,prf2cn)+
     >                vafoen(nrofon,q6,prf2cn))+
     >         unsqu*vafoen(nrofon,q4,prf2cn)
c
c           Pour le triangle fils NF+1
c
              prfcap(f2cp) = 1
c
              vafott(nrofon,q1,f2cp) =
     >        unsde*(vafoen(nrofon,q1,prf1cn)+vafoen(nrofon,q1,prf2cn))
c
              vafott(nrofon,q2,f2cp) = vafoen(nrofon,q4,prf2cn)
c
              vafott(nrofon,q3,f2cp) = vafoen(nrofon,q6,prf1cn)
c
              vafott(nrofon,q4,f2cp) =
     >         trshu*vafoen(nrofon,q1,prf2cn)-
     >         unshu*vafoen(nrofon,q2,prf2cn)+
     >         trsqu*vafoen(nrofon,q4,prf2cn)
c
              vafott(nrofon,q5,f2cp) = vafott(nrofon,q5,f1cp)
c
              vafott(nrofon,q6,f2cp) =
     >         trshu*vafoen(nrofon,q1,prf1cn)-
     >         unshu*vafoen(nrofon,q3,prf1cn)+
     >         trsqu*vafoen(nrofon,q6,prf1cn)     
c
c           Pour le triangle fils NF+2 (eventuellement redecoupe en 2)
c
              if ( mod(hettri(f1hp+2),10).eq.0 ) then
c
                prfcap(f3cp) = 1
c
                vafott(nrofon,q1,f3cp) = vafoen(nrofon,q4,prf2cn)
c
                vafott(nrofon,q2,f3cp) = vafoen(nrofon,q2,prf2cn)
c
                vafott(nrofon,q3,f3cp) = vafoen(nrofon,q3,prf2cn)
c
                vafott(nrofon,q4,f3cp) =
     >          -unshu*vafoen(nrofon,q1,prf2cn)+
     >           trshu*vafoen(nrofon,q2,prf2cn)+
     >           trsqu*vafoen(nrofon,q4,prf2cn)     
c
                vafott(nrofon,q5,f3cp) = vafoen(nrofon,q5,prf2cn)
c
                vafott(nrofon,q6,f3cp) = vafott(nrofon,q6,f1cp)
c
              elseif ( mod(hettri(f1hp+2),10).eq.etan ) then
c
                fihp = filtri(f1hp+2)
                g2 = ntrsca(fihp)
                g1 = ntrsca(fihp+1)
                prfcap(g1) = 1
                prfcap(g2) = 1
cgn            print *,'triangle petit-fils en calcul g1 = ',g1
cgn            print *,'triangle petit-fils en calcul g2 = ',g2
c
c           Pour le fils G1
c            
                vafott(nrofon,q1,g1) = vafoen(nrofon,q4,prf2cn)
c
                vafott(nrofon,q2,g1) = vafoen(nrofon,q2,prf2cn)
c
                vafott(nrofon,q3,g1) = vafoen(nrofon,q5,prf2cn)
c
                vafott(nrofon,q4,g1) = 
     >           trshu*vafoen(nrofon,q2,prf2cn)
     >          -unshu*vafoen(nrofon,q1,prf2cn)
     >          +trsqu*vafoen(nrofon,q4,prf2cn) 
c
                vafott(nrofon,q5,g1) =
     >           trshu*vafoen(nrofon,q2,prf2cn)
     >          -unshu*vafoen(nrofon,q3,prf2cn)
     >          +trsqu*vafoen(nrofon,q5,prf2cn) 
c
                vafott(nrofon,q6,g1) =
     >        -unshu*(vafoen(nrofon,q1,prf2cn)+vafoen(nrofon,q3,prf2cn))
     >        +unsde*(vafoen(nrofon,q4,prf2cn)+vafoen(nrofon,q5,prf2cn))
     >        +unsqu*vafoen(nrofon,q6,prf2cn)
c
c           Pour le fils G2
c                        
                vafott(nrofon,q1,g2) = vafoen(nrofon,q4,prf2cn)
c
                vafott(nrofon,q2,g2) = vafoen(nrofon,q5,prf2cn)
c
                vafott(nrofon,q3,g2) = vafoen(nrofon,q3,prf2cn)
c
                vafott(nrofon,q4,g2) = vafott(nrofon,q6,g1)
c
                vafott(nrofon,q5,g2) =
     >           trshu*vafoen(nrofon,q3,prf2cn)
     >          -unshu*vafoen(nrofon,q2,prf2cn)
     >          +trsqu*vafoen(nrofon,q5,prf2cn) 
c
                vafott(nrofon,q6,g2) =
     >        -unshu*(vafoen(nrofon,q1,prf2cn)+vafoen(nrofon,q2,prf2cn))
     >        +unsde*(vafoen(nrofon,q5,prf2cn)+vafoen(nrofon,q6,prf2cn))
     >        +unsqu*vafoen(nrofon,q4,prf2cn)
c
              else
c
                codret = codret + 1
                write (ulsort,texte(langue,4)) 'n+1', f1hp+2
                write (ulsort,texte(langue,5)) 'n+1', hettri(f1hp+2)
c
              endif
c
c           Pour le triangle fils NF+3 (eventuellement redecoupe en 2)
c
cgn              print *,'triangle fils NF+3 = ',f1hp+3
cgn              print *,'  Etat = ',hettri(f1hp+3)
              if ( mod(hettri(f1hp+3),10).eq.0 ) then
c
                prfcap(f4cp) = 1
c
                vafott(nrofon,q1,f4cp) = vafoen(nrofon,q6,prf1cn)
c
                vafott(nrofon,q2,f4cp) = vafoen(nrofon,q2,prf1cn)
c
                vafott(nrofon,q3,f4cp) = vafoen(nrofon,q3,prf1cn)
c
                vafott(nrofon,q4,f4cp) = vafott(nrofon,q4,f1cp)
c
                vafott(nrofon,q5,f4cp) = vafoen(nrofon,q5,prf1cn)
c
                vafott(nrofon,q6,f4cp) = 
     >            trshu*vafoen(nrofon,q3,prf1cn)
     >           -unshu*vafoen(nrofon,q1,prf1cn)+
     >            trsqu*vafoen(nrofon,q6,prf1cn)
c
              elseif ( mod(hettri(f1hp+3),10).eq.etan ) then
c
                fihp = filtri(f1hp+3)
                d2 = ntrsca(fihp)
                d1 = ntrsca(fihp+1)
                prfcap(d1) = 1
                prfcap(d2) = 1
cgn              print *,'  Fils HOMARD = ',fihp, ' et ',fihp+1
cgn              print *,'  Fils Calcul = ',d2, ' et ',d1
cgn              print *,' q1, q2, q3, q4, q5, q6 = ',q1,q2,q3,q4,q5,q6
c
c           Pour le fils D1            
c
                vafott(nrofon,q1,d1) = vafoen(nrofon,q6,prf1cn)
c
                vafott(nrofon,q2,d1) = vafoen(nrofon,q2,prf1cn)
c
                vafott(nrofon,q3,d1) = vafoen(nrofon,q5,prf1cn)
c
                vafott(nrofon,q4,d1) = 
     >        -unshu*(vafoen(nrofon,q1,prf1cn)+vafoen(nrofon,q3,prf1cn))
     >        +unsde*(vafoen(nrofon,q4,prf1cn)+vafoen(nrofon,q5,prf1cn))
     >        +unsqu*vafoen(nrofon,q6,prf1cn)              
c
                vafott(nrofon,q5,d1) =
     >           trshu*vafoen(nrofon,q2,prf1cn)
     >          -unshu*vafoen(nrofon,q3,prf1cn)
     >          +trsqu*vafoen(nrofon,q5,prf1cn) 
c
                vafott(nrofon,q6,d1) =
     >        -unshu*(vafoen(nrofon,q1,prf1cn)+vafoen(nrofon,q2,prf1cn))
     >        +unsde*(vafoen(nrofon,q5,prf1cn)+vafoen(nrofon,q6,prf1cn))
     >        +unsqu*vafoen(nrofon,q4,prf1cn)
cgn            print *,'vafott(nrofon,',q1,',',d1,')=',vafott(nrofon,q1,d1)
cgn            print *,'vafott(nrofon,',q2,',',d1,')=',vafott(nrofon,q2,d1)
cgn            print *,'vafott(nrofon,',q3,',',d1,')=',vafott(nrofon,q3,d1)
cgn            print *,'vafott(nrofon,',q4,',',d1,')=',vafott(nrofon,q4,d1)
cgn            print *,'vafott(nrofon,',q5,',',d1,')=',vafott(nrofon,q5,d1)
cgn            print *,'vafott(nrofon,',q6,',',d1,')=',vafott(nrofon,q6,d1)
c            
c           Pour le fils D2            
c
                vafott(nrofon,q1,d2) = vafoen(nrofon,q6,prf1cn)
c
                vafott(nrofon,q2,d2) = vafoen(nrofon,q5,prf1cn)
c
                vafott(nrofon,q3,d2) = vafoen(nrofon,q3,prf1cn)
c
                vafott(nrofon,q4,d2) = vafott(nrofon,q6,d1)
c
                vafott(nrofon,q5,d2) =
     >           trshu*vafoen(nrofon,q3,prf1cn)
     >          -unshu*vafoen(nrofon,q2,prf1cn)
     >          +trsqu*vafoen(nrofon,q5,prf1cn) 
c
                vafott(nrofon,q6,d2) =
     >           trshu*vafoen(nrofon,q3,prf1cn)
     >          -unshu*vafoen(nrofon,q1,prf1cn)
     >          +trsqu*vafoen(nrofon,q6,prf1cn) 
cgn            print *,'vafott(nrofon,',q1,',',d2,')=',vafott(nrofon,q1,d2)
cgn            print *,'vafott(nrofon,',q2,',',d2,')=',vafott(nrofon,q2,d2)
cgn            print *,'vafott(nrofon,',q3,',',d2,')=',vafott(nrofon,q3,d2)
cgn            print *,'vafott(nrofon,',q4,',',d2,')=',vafott(nrofon,q4,d2)
cgn            print *,'vafott(nrofon,',q5,',',d2,')=',vafott(nrofon,q5,d2)
cgn            print *,'vafott(nrofon,',q6,',',d2,')=',vafott(nrofon,q6,d2)
c
              else
c
                codret = codret + 1
                write (ulsort,texte(langue,4)) 'n+1', f1hp+3
                write (ulsort,texte(langue,5)) 'n+1', hettri(f1hp+3)
c
              endif
c
23411       continue
c
            elseif ( etan.eq.2 ) then
c
            do 23412 , nrofon = 1 , nbfonc            
c
c        Decoupage en 4 d'un triangle predecoupe en 2 par l'arete a2
c
c           Pour le fils aine NF (centre)
c
                vafott(nrofon,q1,f1cp) = vafoen(nrofon,q5,prf1cn)
c
              vafott(nrofon,q2,f1cp) = 
     >        unsde*(vafoen(nrofon,q1,prf1cn)+vafoen(nrofon,q3,prf2cn))
c
              vafott(nrofon,q3,f1cp) =  vafoen(nrofon,q4,prf2cn)
c
              vafott(nrofon,q4,f1cp) = 
     >        -unshu*(vafoen(nrofon,q2,prf1cn)+
     >                vafoen(nrofon,q3,prf1cn))+
     >         unsde*(vafoen(nrofon,q4,prf1cn)+
     >                vafoen(nrofon,q6,prf1cn))+
     >         unsqu*vafoen(nrofon,q5,prf1cn)
c
              vafott(nrofon,q5,f1cp) =
     >        -unshu*(vafoen(nrofon,q1,prf2cn)+
     >                vafoen(nrofon,q2,prf2cn))+
     >         unsde*(vafoen(nrofon,q5,prf2cn)+
     >                vafoen(nrofon,q6,prf2cn))+
     >         unsqu*vafoen(nrofon,q4,prf2cn)
c
              vafott(nrofon,q6,f1cp) =
     >         unsde*(vafoen(nrofon,q4,prf1cn)+
     >                vafoen(nrofon,q5,prf2cn))
c
c           Pour le triangle fils NF+1    (eventuellement redecoupe en 2)
c
              if ( mod(hettri(f1hp+1),10).eq.0 ) then
c
              prfcap(f2cp) = 1
c
              vafott(nrofon,q1,f2cp) = vafoen(nrofon,q1,prf2cn)
c
              vafott(nrofon,q2,f2cp) = vafoen(nrofon,q4,prf2cn)
c
              vafott(nrofon,q3,f2cp) = vafoen(nrofon,q3,prf2cn)
c
              vafott(nrofon,q4,f2cp) =
     >         trshu*vafoen(nrofon,q1,prf2cn)-
     >         unshu*vafoen(nrofon,q2,prf2cn)+
     >         trsqu*vafoen(nrofon,q4,prf2cn)
c
              vafott(nrofon,q5,f2cp) = vafott(nrofon,q5,f1cp)
c
              vafott(nrofon,q6,f2cp) = vafoen(nrofon,q6,prf2cn)     
c
              elseif ( mod(hettri(f1hp+1),10).eq.etan ) then
c
                fihp = filtri(f1hp+1)
                d2 = ntrsca(fihp+1)
                d1 = ntrsca(fihp)
                prfcap(d1) = 1
                prfcap(d2) = 1
c
c
c           Pour le fils D1            
c
              vafott(nrofon,q1,d1) = vafoen(nrofon,q6,prf2cn)
c
              vafott(nrofon,q2,d1) = vafoen(nrofon,q4,prf2cn)
c
              vafott(nrofon,q3,d1) = vafoen(nrofon,q3,prf2cn)
c
              vafott(nrofon,q4,d1) = 
     >        -unshu*(vafoen(nrofon,q2,prf2cn)+vafoen(nrofon,q3,prf2cn))
     >        +unsde*(vafoen(nrofon,q4,prf2cn)+vafoen(nrofon,q6,prf2cn))
     >        +unsqu*vafoen(nrofon,q5,prf2cn)
c
              vafott(nrofon,q5,d1) =
     >        -unshu*(vafoen(nrofon,q1,prf2cn)+vafoen(nrofon,q2,prf2cn))
     >        +unsde*(vafoen(nrofon,q5,prf2cn)+vafoen(nrofon,q6,prf2cn))
     >        +unsqu*vafoen(nrofon,q4,prf2cn)
c
              vafott(nrofon,q6,d1) =
     >         trshu*vafoen(nrofon,q3,prf2cn)
     >        -unshu*vafoen(nrofon,q1,prf2cn)
     >        +trsqu*vafoen(nrofon,q6,prf2cn)                         
c            
c           Pour le fils D2            
c
              vafott(nrofon,q1,d2) = vafoen(nrofon,q1,prf2cn)
c
              vafott(nrofon,q2,d2) = vafoen(nrofon,q4,prf2cn)
c
              vafott(nrofon,q3,d2) = vafoen(nrofon,q6,prf2cn)
c
              vafott(nrofon,q4,d2) = 
     >         trshu*vafoen(nrofon,q1,prf2cn)
     >        -unshu*vafoen(nrofon,q2,prf2cn)
     >        +trsqu*vafoen(nrofon,q4,prf2cn)                         
c
              vafott(nrofon,q5,d2) = vafott(nrofon,q4,d1)
c
              vafott(nrofon,q6,d2) =
     >         trshu*vafoen(nrofon,q1,prf2cn)
     >        -unshu*vafoen(nrofon,q3,prf2cn)
     >        +trsqu*vafoen(nrofon,q6,prf2cn)                         
c            
              else
c
                codret = codret + 1
                write (ulsort,texte(langue,4)) 'n+1', f1hp+1
                write (ulsort,texte(langue,5)) 'n+1', hettri(f1hp+1)
c
              endif

c           Pour le triangle fils NF+2
c
              prfcap(f3cp) = 1
c
              vafott(nrofon,q1,f3cp) = vafoen(nrofon,q4,prf2cn)
c
              vafott(nrofon,q2,f3cp) = 
     >         unsde*(vafoen(nrofon,q2,prf1cn)+
     >                vafoen(nrofon,q2,prf2cn))
c
              vafott(nrofon,q3,f3cp) = vafoen(nrofon,q5,prf1cn)
c
              vafott(nrofon,q4,f3cp) =
     >        -unshu*vafoen(nrofon,q1,prf2cn)+
     >         trshu*vafoen(nrofon,q2,prf2cn)+
     >         trsqu*vafoen(nrofon,q4,prf2cn)
c    
              vafott(nrofon,q5,f3cp) =
     >        -unshu*vafoen(nrofon,q3,prf1cn)+
     >         trshu*vafoen(nrofon,q2,prf1cn)+
     >         trsqu*vafoen(nrofon,q5,prf1cn)
c
              vafott(nrofon,q6,f3cp) = vafott(nrofon,q6,f1cp)
c
c           Pour le triangle fils NF+3  (eventuellement redecoupe en 2)
c
              if ( mod(hettri(f1hp+3),10).eq.0 ) then
c
              prfcap(f4cp) = 1
c
              vafott(nrofon,q1,f4cp) = vafoen(nrofon,q1,prf1cn)
c
              vafott(nrofon,q2,f4cp) = vafoen(nrofon,q5,prf1cn)
c
              vafott(nrofon,q3,f4cp) = vafoen(nrofon,q3,prf1cn)
c
              vafott(nrofon,q4,f4cp) = vafott(nrofon,q4,f1cp)
c
              vafott(nrofon,q5,f4cp) =
     >          trshu*vafoen(nrofon,q3,prf1cn)
     >         -unshu*vafoen(nrofon,q2,prf1cn)+
     >          trsqu*vafoen(nrofon,q5,prf1cn)
c
              vafott(nrofon,q6,f4cp) = vafoen(nrofon,q6,prf1cn)
c
              elseif ( mod(hettri(f1hp+3),10).eq.etan ) then
c
                fihp = filtri(f1hp+3)
                g2 = ntrsca(fihp+1)
                g1 = ntrsca(fihp)
                prfcap(g1) = 1
                prfcap(g2) = 1
c
c           Pour le fils G1 
c           
              vafott(nrofon,q1,g1) = vafoen(nrofon,q6,prf1cn)
c
              vafott(nrofon,q2,g1) = vafoen(nrofon,q5,prf1cn)
c
              vafott(nrofon,q3,g1) = vafoen(nrofon,q3,prf1cn)
c
              vafott(nrofon,q4,g1) = 
     >        -unshu*(vafoen(nrofon,q1,prf1cn)+vafoen(nrofon,q2,prf1cn))
     >        +unsde*(vafoen(nrofon,q5,prf1cn)+vafoen(nrofon,q6,prf1cn))
     >        +unsqu*vafoen(nrofon,q4,prf1cn)
c
              vafott(nrofon,q5,g1) =
     >         trshu*vafoen(nrofon,q3,prf1cn)
     >        -unshu*vafoen(nrofon,q2,prf1cn)
     >        +trsqu*vafoen(nrofon,q5,prf1cn) 
c
              vafott(nrofon,q6,g1) =
     >         trshu*vafoen(nrofon,q3,prf1cn)
     >        -unshu*vafoen(nrofon,q1,prf1cn)
     >        +trsqu*vafoen(nrofon,q6,prf1cn)                         
c
c           Pour le fils G2                        
c           
              vafott(nrofon,q1,g2) = vafoen(nrofon,q1,prf1cn)
c
              vafott(nrofon,q2,g2) = vafoen(nrofon,q5,prf1cn)
c
              vafott(nrofon,q3,g2) = vafoen(nrofon,q6,prf1cn)
c
              vafott(nrofon,q4,g2) = 
     >        -unshu*(vafoen(nrofon,q2,prf1cn)+vafoen(nrofon,q3,prf1cn))
     >        +unsde*(vafoen(nrofon,q4,prf1cn)+vafoen(nrofon,q6,prf1cn))
     >        +unsqu*vafoen(nrofon,q5,prf1cn)
c
              vafott(nrofon,q5,g2) = vafott(nrofon,q4,g1)
c
              vafott(nrofon,q6,g2) =
     >         trshu*vafoen(nrofon,q1,prf1cn)
     >        -unshu*vafoen(nrofon,q3,prf1cn)
     >        +trsqu*vafoen(nrofon,q6,prf1cn)                         
c
              else
c
                codret = codret + 1
                write (ulsort,texte(langue,4)) 'n+1', f1hp+3
                write (ulsort,texte(langue,5)) 'n+1', hettri(f1hp+3)
c
              endif
     
23412       continue
c
            elseif ( etan.eq.3 ) then
c
            do 23413 , nrofon = 1 , nbfonc            
c
c
c        Decoupage en 4 d'un triangle predecoupe en 2 par l'arete a3
c
c           Pour le fils aine (centre)
c
              vafott(nrofon,q1,f1cp) = vafoen(nrofon,q5,prf1cn)
c
              vafott(nrofon,q2,f1cp) = vafoen(nrofon,q6,prf2cn)
c
              vafott(nrofon,q3,f1cp) = 
     >        unsde*(vafoen(nrofon,q1,prf1cn)+
     >               vafoen(nrofon,q2,prf2cn))
c
              vafott(nrofon,q4,f1cp) = 
     >         unsde*(vafoen(nrofon,q6,prf1cn)+
     >                vafoen(nrofon,q5,prf2cn))
c
              vafott(nrofon,q5,f1cp) =
     >        -unshu*(vafoen(nrofon,q1,prf2cn)+
     >                vafoen(nrofon,q3,prf2cn))+
     >         unsde*(vafoen(nrofon,q4,prf2cn)+
     >                vafoen(nrofon,q5,prf2cn))+
     >         unsqu*vafoen(nrofon,q6,prf2cn)
c
              vafott(nrofon,q6,f1cp) =
     >        -unshu*(vafoen(nrofon,q2,prf1cn)+
     >                vafoen(nrofon,q3,prf1cn))+
     >         unsde*(vafoen(nrofon,q4,prf1cn)+
     >                vafoen(nrofon,q6,prf1cn))+
     >         unsqu*vafoen(nrofon,q5,prf1cn)
c
c           Pour le triangle fils NF+1   (eventuellement redecoupe en 2)
cgn              print *,'triangle fils NF+1 = ',f1hp+1
cgn              print *,'  Etat = ',hettri(f1hp+1)
cgn              print *,' q1, q2, q3, q4, q5, q6 = ',q1,q2,q3,q4,q5,q6
c
              if ( mod(hettri(f1hp+1),10).eq.0 ) then
c
              prfcap(f2cp) = 1
c
              vafott(nrofon,q1,f2cp) = vafoen(nrofon,q1,prf2cn)
c
              vafott(nrofon,q2,f2cp) = vafoen(nrofon,q2,prf2cn)
c
              vafott(nrofon,q3,f2cp) = vafoen(nrofon,q6,prf2cn)
c
              vafott(nrofon,q4,f2cp) = vafoen(nrofon,q4,prf2cn)
c
              vafott(nrofon,q5,f2cp) = vafott(nrofon,q5,f1cp)
c
              vafott(nrofon,q6,f2cp) =
     >        -unshu*vafoen(nrofon,q3,prf2cn)+    
     >         trshu*vafoen(nrofon,q1,prf2cn)+
     >         trsqu*vafoen(nrofon,q6,prf2cn)     
c
              elseif ( mod(hettri(f1hp+1),10).eq.etan ) then
c
                fihp = filtri(f1hp+1)
                g2 = ntrsca(fihp)
                g1 = ntrsca(fihp+1)
                prfcap(g1) = 1
                prfcap(g2) = 1
cgn              print *,'   --> fils g1 = ',g1
cgn              print *,'   --> fils g2 = ',g2
c
c           Pour le fils G1            
c           
              vafott(nrofon,q1,g1) = vafoen(nrofon,q1,prf2cn)
c
              vafott(nrofon,q2,g1) = vafoen(nrofon,q4,prf2cn)
c
              vafott(nrofon,q3,g1) = vafoen(nrofon,q6,prf2cn)
c
              vafott(nrofon,q4,g1) = 
     >         trshu*vafoen(nrofon,q1,prf2cn)
     >        -unshu*vafoen(nrofon,q2,prf2cn)
     >        +trsqu*vafoen(nrofon,q4,prf2cn)                         
c
              vafott(nrofon,q5,g1) =
     >        -unshu*(vafoen(nrofon,q2,prf2cn)+vafoen(nrofon,q3,prf2cn))
     >        +unsde*(vafoen(nrofon,q4,prf2cn)+vafoen(nrofon,q6,prf2cn))
     >        +unsqu*vafoen(nrofon,q5,prf2cn)
c
              vafott(nrofon,q6,g1) =
     >         trshu*vafoen(nrofon,q1,prf2cn)
     >        -unshu*vafoen(nrofon,q3,prf2cn)
     >        +trsqu*vafoen(nrofon,q6,prf2cn)                         
cgn            print *,'vafott(nrofon,',q1,',',g1,')=',vafott(nrofon,q1,g1)
cgn            print *,'vafott(nrofon,',q2,',',g1,')=',vafott(nrofon,q2,g1)
cgn            print *,'vafott(nrofon,',q3,',',g1,')=',vafott(nrofon,q3,g1)
cgn            print *,'vafott(nrofon,',q4,',',g1,')=',vafott(nrofon,q4,g1)
cgn            print *,'vafott(nrofon,',q5,',',g1,')=',vafott(nrofon,q5,g1)
cgn            print *,'vafott(nrofon,',q6,',',g1,')=',vafott(nrofon,q6,g1)
c
c           Pour le fils G2                        
c
              vafott(nrofon,q1,g2) = vafoen(nrofon,q4,prf2cn)
c
              vafott(nrofon,q2,g2) = vafoen(nrofon,q2,prf2cn)
c
              vafott(nrofon,q3,g2) = vafoen(nrofon,q6,prf2cn)
c
              vafott(nrofon,q4,g2) = 
     >         trshu*vafoen(nrofon,q2,prf2cn)
     >        -unshu*vafoen(nrofon,q1,prf2cn)
     >        +trsqu*vafoen(nrofon,q4,prf2cn)                         
c
              vafott(nrofon,q5,g2) =
     >        -unshu*(vafoen(nrofon,q1,prf2cn)+vafoen(nrofon,q3,prf2cn))
     >        +unsde*(vafoen(nrofon,q4,prf2cn)+vafoen(nrofon,q5,prf2cn))
     >        +unsqu*vafoen(nrofon,q6,prf2cn)
c
              vafott(nrofon,q6,g2) = vafott(nrofon,q5,g1)
cgn            print *,'vafott(nrofon,',q1,',',g2,')=',vafott(nrofon,q1,g2)
cgn            print *,'vafott(nrofon,',q2,',',g2,')=',vafott(nrofon,q2,g2)
cgn            print *,'vafott(nrofon,',q3,',',g2,')=',vafott(nrofon,q3,g2)
cgn            print *,'vafott(nrofon,',q4,',',g2,')=',vafott(nrofon,q4,g2)
cgn            print *,'vafott(nrofon,',q5,',',g2,')=',vafott(nrofon,q5,g2)
cgn            print *,'vafott(nrofon,',q6,',',g2,')=',vafott(nrofon,q6,g2)
c
              else
c
                codret = codret + 1
                write (ulsort,texte(langue,4)) 'n+1', f1hp+1
                write (ulsort,texte(langue,5)) 'n+1', hettri(f1hp+1)
c
              endif
c
c           Pour le triangle fils NF+2   (eventuellement redecoupe en 2)
cgn              print *,'triangle fils NF+2 = ',f1hp+2
cgn              print *,'  Etat = ',hettri(f1hp+2)
c
              if ( mod(hettri(f1hp+2),10).eq.0 ) then
c
              prfcap(f3cp) = 1
c
              vafott(nrofon,q1,f3cp) = vafoen(nrofon,q1,prf1cn)
c
              vafott(nrofon,q2,f3cp) = vafoen(nrofon,q2,prf1cn)
c
              vafott(nrofon,q3,f3cp) = vafoen(nrofon,q5,prf1cn)
c
              vafott(nrofon,q4,f3cp) = vafoen(nrofon,q4,prf1cn)
     
              vafott(nrofon,q5,f3cp) =
     >        -unshu*vafoen(nrofon,q3,prf1cn)+
     >         trshu*vafoen(nrofon,q2,prf1cn)+
     >         trsqu*vafoen(nrofon,q5,prf1cn)     

              vafott(nrofon,q6,f3cp) = vafott(nrofon,q6,f1cp)
c
              elseif ( mod(hettri(f1hp+2),10).eq.etan ) then
c
                fihp = filtri(f1hp+2)
                d2 = ntrsca(fihp)
                d1 = ntrsca(fihp+1)
                prfcap(d1) = 1
                prfcap(d2) = 1
c
c           Pour le fils D1            
c
              vafott(nrofon,q1,d1) = vafoen(nrofon,q1,prf1cn)
c
              vafott(nrofon,q2,d1) = vafoen(nrofon,q4,prf1cn)
c
              vafott(nrofon,q3,d1) = vafoen(nrofon,q5,prf1cn)
c
              vafott(nrofon,q4,d1) = 
     >         trshu*vafoen(nrofon,q1,prf1cn)
     >        -unshu*vafoen(nrofon,q2,prf1cn)
     >        +trsqu*vafoen(nrofon,q4,prf1cn)                         
c
              vafott(nrofon,q5,d1) =
     >        -unshu*(vafoen(nrofon,q1,prf1cn)+vafoen(nrofon,q3,prf1cn))
     >        +unsde*(vafoen(nrofon,q4,prf1cn)+vafoen(nrofon,q5,prf1cn))
     >        +unsqu*vafoen(nrofon,q6,prf1cn)
c
              vafott(nrofon,q6,d1) = 
     >        -unshu*(vafoen(nrofon,q2,prf1cn)+vafoen(nrofon,q3,prf1cn))
     >        +unsde*(vafoen(nrofon,q4,prf1cn)+vafoen(nrofon,q6,prf1cn))
     >        +unsqu*vafoen(nrofon,q5,prf1cn)
c            
c           Pour le fils D2            
c
              vafott(nrofon,q1,d2) = vafoen(nrofon,q4,prf1cn)
c
              vafott(nrofon,q2,d2) = vafoen(nrofon,q2,prf1cn)
c
              vafott(nrofon,q3,d2) = vafoen(nrofon,q5,prf1cn)
c
              vafott(nrofon,q4,d2) = 
     >         trshu*vafoen(nrofon,q2,prf1cn)
     >        -unshu*vafoen(nrofon,q1,prf1cn)
     >        +trsqu*vafoen(nrofon,q4,prf1cn)                         
c
              vafott(nrofon,q5,d2) =
     >         trshu*vafoen(nrofon,q2,prf1cn)
     >        -unshu*vafoen(nrofon,q3,prf1cn)
     >        +trsqu*vafoen(nrofon,q5,prf1cn)                         
c
              vafott(nrofon,q6,d2) = vafott(nrofon,q5,d1) 
c                                    
c
              else
c
                codret = codret + 1
                write (ulsort,texte(langue,4)) 'n+1', f1hp+2
                write (ulsort,texte(langue,5)) 'n+1', hettri(f1hp+2)
c
              endif
c
c           Pour le triangle fils NF+3
c
              prfcap(f4cp) = 1
c
              vafott(nrofon,q1,f4cp) = vafoen(nrofon,q6,prf2cn)
c
              vafott(nrofon,q2,f4cp) = vafoen(nrofon,q5,prf1cn)
c
              vafott(nrofon,q3,f4cp) = 
     >         unsde*(vafoen(nrofon,q3,prf1cn)+
     >                vafoen(nrofon,q3,prf2cn))
c     
              vafott(nrofon,q4,f4cp) = vafott(nrofon,q4,f1cp)
c
              vafott(nrofon,q5,f4cp) =
     >          trshu*vafoen(nrofon,q3,prf1cn)
     >         -unshu*vafoen(nrofon,q2,prf1cn)+
     >          trsqu*vafoen(nrofon,q5,prf1cn)
c
              vafott(nrofon,q6,f4cp) =
     >          trshu*vafoen(nrofon,q3,prf2cn)
     >         -unshu*vafoen(nrofon,q1,prf2cn)+
     >          trsqu*vafoen(nrofon,q6,prf2cn)
c
23413       continue
c
            endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', 'pcstr2_3'
#endif
