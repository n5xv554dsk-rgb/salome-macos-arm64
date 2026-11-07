# -*- coding: utf-8 -*-
"""
Created on Mon Jun 03 15:31:42 2013

@author: B31272

Fonctions de support
"""
import os,sys,random,string
sys.path.append(r"C:\Program Files\PTI\PSSE33\PSSBIN")
os.environ['PATH'] = r"C:\Program Files\PTI\PSSE33\PSSBIN;"+ os.environ['PATH']
#os.chdir(folder)
import psspy
import pssarrays
import redirect
_i=psspy.getdefaultint()
_f=psspy.getdefaultreal()
_s=psspy.getdefaultchar()
redirect.psse2py()
#import pssdb
psspy.psseinit(80000)

import numpy as np
from math import*
from openturns import *

#===============================================================================
#    DEFINITION DES FONCTIONS   -   CREATION OF THE FUNCTIONS
#===============================================================================

#Fonction de transfert vent-puissance d'une eolienne
def eol(wind, WTconfig):
    Vcin = WTconfig [0]
    Vrate = WTconfig [1]
    Vcout = WTconfig [2]
    Rho = WTconfig [3]
    lossrate = WTconfig [4]
    if wind <= Vcin : 
        Pnorm=0
    elif wind < Vrate :
        Pnorm=wind*(1-lossrate)#((wind**2-Vcin**2)/(Vrate**2-Vcin**2)*Rho/1.225*(1-lossrate))
    elif wind < Vcout :
        Pnorm = 1*(1-lossrate)
    else : 
        Pnorm=0
    return Pnorm

#Fonction permettant de lire les donnees qui nous interessent et de les mettre dans une matrice
def read_sav(doc): 
    psspy.case(doc)
    # Select what to report
    if psspy.bsysisdef(0):
        sid = 0
    else:   # Select subsytem with all buses
        sid = -1    
    
    flag_bus     = 1    # in-service
    flag_plant   = 4    # in-service
    flag_load    = 1    # in-service
    flag_swsh    = 1    # in-service
    flag_brflow  = 1    # in-service
    owner_brflow = 1    # bus, ignored if sid is -ve
    ties_brflow  = 5    # ignored if sid is -ve
    entry = 1   # gives a single entry (each branch once)
    
    #Bus data (number, basekV, pu, name, ...) : PSSe has 3 functions one for integer data, one for real data and one for strings
    istrings = ['number']
    ierr, idata = psspy.abusint(sid, flag_bus, istrings)
    buses=idata
    
    rstrings = ['base','pu']
    ierr, rdata = psspy.abusreal(sid, flag_bus, rstrings)
    buses.append(rdata[0])
    buses.append(rdata[1])
    
    cstrings = ['name']
    ierr, cdata = psspy.abuschar(sid, flag_bus, cstrings)
    buses.append(cdata[0])
    
    buses=zip(*buses) # transpose the matrix
    
    del idata, rdata, istrings, rstrings
    
    #Lines data (from, to, amps, rate%a, ploss, qloss)
    flag=2 #All non-transformer branches    
    istrings = ['fromnumber','tonumber']
    ierr, idata = psspy.abrnint(sid, owner_brflow, ties_brflow, flag, entry, istrings)
    lines=idata
    
    rstrings=['amps','pctratea','pctrateb','pctratec','p','q']
    ierr, rdata = psspy.abrnreal(sid, owner_brflow, ties_brflow, flag, entry, rstrings)
    for rc in range (np.matrix(rdata).shape[0]) :
        lines.append(rdata[rc])
    
    cstrings=['fromname','toname','id']
    ierr, cdata = psspy.abrnchar(sid, owner_brflow, ties_brflow, flag, entry, cstrings)
    for rc in range (np.matrix(cdata).shape[0]) :
        lines.append(cdata[rc])
    
    lines=zip(*lines) # transpose the matrix
    
    del idata, rdata, istrings, rstrings

    #2 windings transformers data (from, to, amps, rate%a, ploss, qloss)
    flag=6 #All transformer branches    
    istrings = ['fromnumber','tonumber']
    ierr, idata = psspy.abrnint(sid, owner_brflow, ties_brflow, flag, entry, istrings)
    transf=idata
    
    rstrings=['amps','pctratea','ploss','qloss']
    ierr, rdata = psspy.abrnreal(sid, owner_brflow, ties_brflow, flag, entry, rstrings)
    for rc in range (np.matrix(rdata).shape[0]) :
        transf.append(rdata[rc])
    
    transf=zip(*transf) # transpose the matrix
    
    del idata, rdata, istrings, rstrings    
    
    #Machines data (bus, inservice, number, pgen, qgen, mvabase)
    istrings = ['number','status']
    ierr, idata = psspy.amachint(sid, flag_plant, istrings)
    plants=idata
    
    cstrings = ['id']
    ierr, cdata = psspy.amachchar(sid, flag_plant, cstrings)
    for rc in range (np.matrix(cdata).shape[0]) :
        plants.append(cdata[rc])   
    
    rstrings = ['pgen','qgen','mbase','pmax','qmax']
    ierr, rdata = psspy.amachreal(sid, flag_plant, rstrings)
    for rc in range (np.matrix(rdata).shape[0]) :
        plants.append(rdata[rc])
        
    cstrings = ['name']
    ierr, cdata = psspy.amachchar(sid, flag_plant, cstrings)
    plants.append(cdata[0])   
    
    nb_plants=np.matrix(plants).shape[1]
    for rc in range (0,nb_plants) :
        plants[3][rc]=float(plants[3][rc]*int(plants[1][rc])) # If the plant isn't in service its production is fixed to zero
        plants[4][rc]=float(plants[4][rc]*int(plants[1][rc])) # If the plant isn't in service its production is fixed to zero
    
    plants=zip(*plants) # transpose the matrix
        
    #Loads data (bus, active, reactive)
    istrings = ['number']
    ierr, idata = psspy.aloadint(sid, flag_load, istrings)
    loads=idata
    
    xstrings = ['mvaact']
    ierr, xdata = psspy.aloadcplx(sid, flag_load, xstrings)  
    loads.append(np.real(xdata)[0]) # Append the real part of the load
    loads.append(np.imag(xdata)[0]) #Append the imaginary part of the load
    
    istrings = ['status']
    ierr, idata = psspy.aloadint(sid, flag_load, istrings)
    loads.append(idata[0])
    
    cstrings = ['name']
    ierr, cdata = psspy.aloadchar(sid, flag_load, cstrings)
    loads.append(cdata[0])
    
    nb_loads=np.matrix(loads).shape[1]
    for rc in range (0,nb_loads) :
        loads[1][rc]=float(loads[1][rc]*int(loads[3][rc])) # If the load isn't in service its consumption is fixed to zero
        loads[2][rc]=float(loads[2][rc]*int(loads[3][rc])) # If the load isn't in service its consumption is fixed to zero
    
    loads=zip(*loads) # transpose the matrix
    
    #Fixed shunt data (number, MVAR, name, ...) 
    istrings = ['number','status']
    ierr, idata = psspy.afxshntbusint(sid, flag_bus, istrings)
    shunt=idata
    
    xstrings = ['shuntact']
    ierr, xdata = psspy.afxshntbuscplx(sid, flag_bus, xstrings)
    shunt.append(np.imag(xdata)[0]) #Append the imaginary part of the load
    
    cstrings = ['name']
    ierr, cdata = psspy.afxshntbuschar(sid, flag_bus, cstrings)
    shunt.append(cdata[0])
    
    shunt=zip(*shunt) # transpose the matrix
       
    return buses, lines, transf, plants, loads, shunt

# Fonction pour ecrire un fichier de sortie type csv
def MyLogger(x,y,z,logCSVfilename,logTXTfilename,ite):  
    f=open(logCSVfilename, 'a')
    f.write("%f;" % (ite))
    f.write(";")
    nx = len(x)
    for i in range(0,nx):
        f.write(str(x[i]))#f.write("%f;" % (x[i]))
        f.write(";")
    f.write(";")
    nz = len(z)
    for i in range(0,nz):
        f.write("%f;" % (z[i]))
    f.write(";")
    ny = len(y)
    for j in range(0,ny):
        f.write("%f;" % (y[j]))
    f.write("\n")
    f.close()
    
    f=open(logTXTfilename, 'a')
    f.write("%f\t" % (ite))
    nx = len(x)
    for i in range(0,nx):
        f.write(str(x[i]))#f.write("%f\t" % (x[i]))
        f.write("\t")
    nz = len(z)
    for i in range(0,nz):
        f.write("%f\t" % (z[i]))
    ny = len(y)
    for j in range(0,ny):
        f.write("%f\t" % (y[j]))
    f.write("\n")
    f.close()

    
# Fonction pour ecrire un fichier de sortie type csv pour chaque type de grandeur de sortie
def MyMultiLogger (x, y, sizeY, z, ite, folder, day, fich, hour):
    global ny
    y0=0
    for fich in range (np.size(sizeY,0)):
        multilogfilename=folder+"\N"+day+"\Y"+str(fich)+"simulationDClog"+hour+".csv"
        f=open(multilogfilename, 'a')
        f.write("%f;" % (ite))
        f.write(";")
        nx = len(x)
        for i in range(0,nx):
            f.write("%f;" % (x[i]))
        f.write(";")
        nz = len(z)
        for i in range(0,nz):
            f.write("%f;" % (z[i]))
        f.write(";")
        ny = sizeY[fich]
        for j in range(0,ny):
            f.write("%f;" % (y[j+y0]))
        f.write("\n")
        f.close()
        y0 += ny
    print "Fichiers "+str(ite)+" enregistres\n\n"
    
# Analyses graphiques
def graphical_out (inputSample, outputSampleAll, inputDim, outputDim, montecarlosize) :
    print "\n\n\n                     Writing graphical analysis files..."
    # A Pairwise scatter plot of the inputs
    myGraph = Graph()
    myPairs = Pairs(inputSample, 'Inputs relations', inputSample.getDescription(), "red", "bullet")
    myGraph.add(Drawable(myPairs))
    myGraph.draw("Input Samples",640,480,GraphImplementation.PDF)
    #View(myGraph.getBitmap())
    print 'Input pairwise scatterplot done...'
    
    # A Pairwise scatter plot of the outputs
    myGraph = Graph()
    myPairs = Pairs(outputSampleAll, 'Output relations', outputSampleAll.getDescription(), "red", "bullet")
    myGraph.add(Drawable(myPairs))
    myGraph.draw("Output Samples",640,480,GraphImplementation.PDF)
    #View(myGraph.getBitmap())
    print 'Output pairwise scatterplot done...'
    
    # A Pairwise scatter plot of the inputs/outputs
    # Draw all scatter plots yj vs xi
    for j in range(outputDim):
        outputSamplej=outputSampleAll.getMarginal(j)
        Ylabelstr=outputSamplej.getDescription()[0]
        for i in range(inputDim):
            inputSamplei=inputSample.getMarginal(i)
            Xlabelstr=inputSamplei.getDescription()[0]
            X=NumericalSample(montecarlosize,2)
            for k in range(montecarlosize):
                X[k,0]=inputSamplei[k][0]
                X[k,1]=outputSamplej[k][0]
            myGraph = Graph()
            myCloud=Cloud(X);
            mytitle=Ylabelstr+"vs"+Xlabelstr
            myGraph.add(Drawable(myCloud))
            myGraph.setAxes(1)
            myGraph.setXTitle(Xlabelstr)
            myGraph.setYTitle(Ylabelstr)
            myGraph.draw(mytitle,640,480,GraphImplementation.PDF)
            #ViewImage(myGraph.getBitmap())
    print 'Input/Output pairwise scatterplot done...'
    
    # An histogram of the inputs
    for i in range(inputDim):
        inputSamplei=inputSample.getMarginal(i)
        myGraph = VisualTest.DrawHistogram(inputSamplei)
        labelarray=inputSamplei.getDescription()
        labelstr=labelarray[0]
        myGraph.setTitle(labelstr)
        myGraph.setName(labelstr)
        myGraph.setXTitle(labelstr)
        myGraph.setYTitle("Frequency")
        myGraph.draw(labelstr,640,480,GraphImplementation.PDF)
        #View(myGraph.getBitmap())
    print 'Input histogram done...'
    
    # An histogram of the outputs
    for j in range(outputDim):
        outputSamplej=outputSampleAll.getMarginal(j)
        myGraph = VisualTest.DrawHistogram(outputSamplej)
        labelarray=outputSamplej.getDescription()
        labelstr=labelarray[0]
        myGraph.setTitle(labelstr)
        myGraph.setName(labelstr)
        myGraph.setXTitle(labelstr)
        myGraph.setYTitle("Frequency")
        myGraph.draw(labelstr,640,480,GraphImplementation.PDF)
        #View(myGraph.getBitmap())
    print 'Output histogram done'
    print 'Graphical output terminated'
    
def config_ENR(path_config_ENR) :
    PV=[]
    Wind1=[]
    Wind2=[]
    Interco=[]
    f=open(path_config_ENR,"r")
    lines=f.readlines()
    for i in range (len(lines)) :
        line = lines[i].split(";")
        if str(line[0]).upper() == 'PV' :
            PV.append([int(line[1]),i-1,int(line[3])])
        elif str(line[0]).upper() == 'W1' :
            Wind1.append([int(line[1]),i-1,int(line[3])])
        elif str(line[0]).upper() == 'W2' :
            Wind2.append([int(line[1]),i-1,int(line[3])])
        elif str(line[0]).upper() == 'I' :
            Interco.append([int(line[1]),i-1,int(line[3])])
        else :
            pass
    return PV, Wind1, Wind2, Interco
    
def config_contingency(path_config_contin) :
    lines_con=[]
    groups_con=[]
    # Loading of lines contingency configuration
    f=open(path_config_contin[0],"r")
    lines=f.readlines()
    f.close()
    for i in range (len(lines)) :
        line=lines[i].split(";")
        try :
            int(line[1])
        except ValueError :
            pass
        else :
            if line[0] == '' :
                line[0] = '0'
            lines_con.append([int(line[1]), int(line[3]), str(line[5]),float(line[0].replace(',','.'))])
            
    # Loading of groups contingency configuration
    f=open(path_config_contin[1],"r")
    lines=f.readlines()
    f.close()
    for i in range (len(lines)) :
        line=lines[i].split(";")
        try :
            int(line[1])
        except ValueError :
            pass
        else :
            if line[0] == '' :
                line[0] = '0'
            groups_con.append([int(line[1]), int(line[3]),float(line[0].replace(',','.'))])
            
    sizeLines = len(lines_con)
    sizeGroups = len(groups_con)
    val=[]
    prob=[]
    for i in range(sizeLines+sizeGroups) :
        val.append(int(i))
        
    for i in range (sizeLines) :
        prob.append(lines_con[i][3])
    for i in range (sizeGroups) :
        prob.append(groups_con[i][2])
        
    return lines_con, groups_con, val, prob
    
def LoadARMA(time_serie_file, time_serie_SS, time_serie_TH) :
    f=open(time_serie_file,"r")
    lines=f.readlines()
    N=len(lines)
    Xt=[]
    for i in range(N) :
        Xt.append([float(lines[i])])
    
    myTG=RegularGrid(0,float(time_serie_SS),N)
    TS=TimeSeries(myTG,NumericalSample(Xt))
    myWN=WhiteNoise(Distribution(Normal(0,1)),myTG)
    myState=ARMAState(TS.getSample(),NumericalSample())
    p=12
    q=0
    d=1
    myFactory = ARMALikelihoodFactory ( p , q , d )
    myARMA = myFactory.build(TS)
    
    myARMA.setState(myState)
    
    AR = myARMA.getARCoefficients()
    MA = myARMA.getMACoefficients()
    
    ts = myARMA.getRealization()
    ts.setName('A realization')
    myTSGraph=ts.drawMarginal(0)
    myTSGraph.draw('Realization'+str(p)+","+str(q),640,480,GraphImplementation.PDF)
    myARMAState=myARMA.getState()
    
    #Make a prediction of the future on next Nit instants
    Nit = int(time_serie_TH)
    myARMA2=ARMA(AR,MA,myWN,myARMAState)
    possibleFuture=myARMA2.getFuture(Nit)
    possibleFuture.setName('Possible future')
    
    Xt2=[]
    for i in range (len(possibleFuture)):
        Xt2.append(possibleFuture.getValueAtIndex(i)[0])
    Max=float(max(Xt2))
    Min=float(min(Xt2))
    h=float(Max-Min)
    for i in range (len(possibleFuture)):
        value= (Xt2[i]-Min+h/3)/(Max-Min+h/3)
        possibleFuture.setValueAtIndex(i,NumericalPoint(1,value))
        
    myFG=possibleFuture.drawMarginal(0)
    myFG.draw('Future'+str(Nit),640,480,GraphImplementation.PDF)
    
    return possibleFuture
    
def LoadTS(time_serie_file) :
    TS=[]
    for i in range(len(time_serie_file)) :
        if time_serie_file[i] == -1 :
            pass
        else :
            f=open(time_serie_file[i],"r")
            lines=f.readlines()
            N=len(lines)
            Xt=[]
            for j in range(N) :
                try :
                    float(lines[i])
                except ValueError :
                    lines[i] = commaToPoint(lines[i])
                else :
                    pass
                Xt.append([float(lines[j])])
            TS.append(Xt)
    return TS


def KSDist(filename) :
    f=open(filename,"r")
    print "Creating Kernel Smoothing distribution from: "+str(filename)
    lines=f.readlines()
    N=len(lines)
    Xt=[]
    for i in range(N) :
        if lines[i] == "\n" :
            print "End of file"
            break
        else :
            try :
                float(lines[i])
            except ValueError :
                lines[i] = commaToPoint(lines[i])
            else :
                pass
            Xt.append([float(lines[i])])
    NS=NumericalSample(Xt)
    kernel=KernelSmoothing(Uniform())
    myBandwith = kernel.computeSilvermanBandwidth(NS)
    KS=kernel.build(NS,myBandwith,1)
    return KS
    
def threshold (inputRandomVector, outputVariableOfInterest,pssefun,inputDistribution) :
    # We create a quadraticCumul algorithm
    myQuadraticCumul = QuadraticCumul(outputVariableOfInterest)
    
    # We compute the several elements provided by the quadratic cumul algorithm
    # and evaluate the number of calculus needed
    nbBefr = pssefun.getEvaluationCallsNumber()
    
    # Mean first order
    meanFirstOrder = myQuadraticCumul.getMeanFirstOrder()[0]
    nbAfter1 = pssefun.getEvaluationCallsNumber()
    
    # Mean second order
    meanSecondOrder = myQuadraticCumul.getMeanSecondOrder()[0]
    nbAfter2 = pssefun.getEvaluationCallsNumber()
    
    # Standard deviation
    stdDeviation = sqrt(myQuadraticCumul.getCovariance()[0,0])
    nbAfter3 = pssefun.getEvaluationCallsNumber()
    
    print "First order mean=", myQuadraticCumul.getMeanFirstOrder()[0]
    print "Evaluation calls number = ", nbAfter1 - nbBefr
    print "Second order mean=", myQuadraticCumul.getMeanSecondOrder()[0]
    print "Evaluation calls number = ", nbAfter2 - nbAfter1
    print "Standard deviation=", sqrt(myQuadraticCumul.getCovariance()[0,0])
    print "Evaluation calls number = ", nbAfter3 - nbAfter2
    
    print  "Importance factors="
    for i in range(inputRandomVector.getDimension()) :
      print inputDistribution.getDescription()[i], " = ", myQuadraticCumul.getImportanceFactors()[i]
    print ""
    
def getUserDefined (val, prob):
    try :
        val = val.split(',')
        prob = prob.split(',')
    except AttributeError :
        pass
    dim = len (val)
    coll = UserDefinedPairCollection()
    for i in range (dim) :
        UDpair=UserDefinedPair(NumericalPoint(1,float(val[i])),float(prob[i]))
        coll.add(UDpair)
    return UserDefined(coll)
    
def getHistogram (step, prob) :
    try :
        step = step.split(',')
        prob = prob.split(',')
    except AttributeError :
        pass
    dim = len (step)
    myHistogram = HistogramPairCollection(dim)
    for i in range (dim) :
        myHistogram[i]=HistogramPair(float(step[i]),float(prob[i]))
    return myHistogram
    
def getUserLaw (description) :
    law_num=int(description[0])
    time_serie=0
    time_serie_file=''
    time_serie_SS=0
    time_serie_TH=0    
    if law_num == 1 :
        law=Normal(float(description[1]),float(description[2]))
    elif law_num == 2 :
        law=Uniform(float(description[1]),float(description[2]))
    elif law_num == 3 :
        law=Exponential(float(description[1]),float(description[2]))
    elif law_num == 4 :
        law=Weibull(float(description[1]),float(description[2]),float(description[3]))
    elif law_num == 5 :
        law=TruncatedNormal(float(description[1]),float(description[2]),float(description[3]),float(description[4]))
    elif law_num == 6 :
        law=UserDefined(getUserDefined (description[1], description[2]))
    elif law_num == 7 :
        law=Histogram(0.0, getHistogram (description[1], description[2]))
    elif law_num == 10 :
        law=KSDist(description[1])
    elif law_num == 20 :
        law = Uniform(0.999999,1)
        time_serie=1
        time_serie_file=description[1]
        """time_serie_SS=description[2]
        time_serie_TH=description[3]"""
    else :
        law = Uniform(0.999999,1)
    return law, [time_serie, time_serie_file] #[time_serie, time_serie_file, time_serie_SS, time_serie_TH]
    
def contingency_automatic (dfxPath, acccPath, rate) :
    psspy.accc_with_dsp_3( 0.5,[0,0,0,1,1,2,0,0,0,0,0],r"""ALL""",dfxPath,acccPath,"","","")
    psspy.accc_single_run_report_4([1,int(rate),int(rate),1,1,0,1,0,0,0,0,0],[0,0,0,0,6000],[ 0.5, 5.0, 100.0,0.0,0.0,0.0, 99999.],acccPath)
    
    rslt_summary=pssarrays.accc_summary(acccPath)
    if int(rate) == 1 :
        rate = rslt_summary.rating.a
    elif int(rate) == 2 :
        rate = rslt_summary.rating.b
    elif int(rate) == 3 :
        rate = rslt_summary.rating.c
    else :
        print "NO RATE CHOOSEN"
        
    Labels=rlst.colabel
    contin_load=[]
    for label in Labels :
        t=[]
        rslt=pssarrays.accc_solution(acccPath,contingency,label,0.5,5.0)
        ampFlow=rslt.ampflow
        for i in range (len(rA)) : 
            t.append(ampFlow[i]/rate[i])
        contin_load.append(t)
    return contin_load
    
def commaToPoint (string) :
    stringReplaced = string.replace(',','.')
    return stringReplaced