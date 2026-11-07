c
90000 format(/,80('*'))
c Caracteres + Entiers
90001 format(a,i10,' : ',10i10)
90002 format('... ',a,' : ',10i10)
90012 format('... ',a,i10,' : ',10i10)
90022 format('... ',a,i10,' : ',20i10)
90032 format(/,'... ',a,' : ',10i10)
90112 format('... ',a,'(',i10,') : ',20i10)
90122 format('... ',a,'(',i10,',',i10,') : ',20i10)
90064 format('... ',i6,' : ',a,a)
90005 format('... ',a,' : ',20i10)
90015 format('... ',a,i10,a,20i10)
90016 format('... ',a,'(',i10,') : ',a)
90006 format(5(a,i10,', '))
90007 format(a,'(',i5,',',i5,') =',i10)
c Caracteres + Logiques
99001 format('... ',a,' :',10l2)
99002 format('... ',a,' : ',10(l1,', '))
c Caracteres + Reels
90004 format('... ',a,' : ',10g13.5)
90104 format(a,' : ',10g13.5)
90034 format('... ',5(a,' : ',g15.7,', '))
c Entiers + Reels
90014 format('... ',i6,' : ',10g13.5)
c Caracteres + Entiers + Reels
90024 format('... ',a,i10,' : ',10g13.5)
90044 format('... ',a,g13.5,a,i10)
90054 format('... ',a,i10,a,10g13.5)
90114 format('... ',a,'(',i10,') : ',10g13.5)
90124 format('... ',a,'(',i10,',',i10,') : ',10g13.5)
c Caracteres
90003 format('... ',a,' :',10(1x,a))
93010 format(10(a,', '))
93020 format('... ',a,' : ',10(a,', '))
93030 format('... ',a)
93080 format(10a8)
c Entiers
91010 format(10i10)
91011 format(10i2,' -',10i2)
91020 format(20i6)
91030 format(30i2)
91040 format(25i3)
91140 format(10(i5,' : ',i3))
91141 format(5(i5,' : ',i15))
c Reels
92010 format(10g16.8)
c
