#===============================================================================
#   PSEN SCRIPT FOR PROBABILISTIC STUDIES OF ELECTICAL NETWORKS
#===============================================================================
from openturns import *
from pylab import *
from math import*
import os, random
import numpy as np
from time import gmtime, strftime
from array import *
from support_functions import *

# Ouverture du fichier de configuration et recupecation des valeurs sous forme de listes
f=open("C:\B31272\Documents\PSEN\PSENdev\lib\config.psen","r")
lines=f.readlines()
data_config=lines[0].split(";")
data_load2 = getUserLaw(lines[1].split(";"))[0]
data_wind1=getUserLaw(lines[2].split(";"))[0]
data_wind2=getUserLaw(lines[3].split(";"))[0]
data_corr=lines[4].split(";")
data_PV=getUserLaw(lines[5].split(";"))[0]
data_OPF=lines[6].split(";")
Irate_num=int(lines[7].split(";")[0])
f.close()

# Definition des variables pour les series temporelles : getUserLaw(lines[1].split(";"))[1][0] doit valoir 1
# pour que le programme etudie les series temporelles
time_serie_file=[]
time_serie_mat=[]
for i in ([1,2,3,5]) :
    TSoptions = getUserLaw(lines[i].split(";"))[1]
    if TSoptions[0] == 1 :
        time_serie=1
        f=open(TSoptions[1],"r")
        linesTS=f.readlines()
        f.close()
        tsm=[]
        for j in range (len(linesTS)) :
            try :
                float(linesTS[j])
            except ValueError :
                linesTS[j] = commaToPoint(linesTS[j])
            else :
                pass
            tsm.append(float(linesTS[j]))
        time_serie_mat.append(tsm)
        time_serie_file.append(TSoptions[1])
        """time_serie_SS = TSoptions[2]
        time_serie_TH = TSoptions[3]"""
    else :
        time_serie_file.append(-1)
time_serie_mat=zip(*time_serie_mat)

# Ouverture du fichier de preferences et recuperation des donnees
f=open("C:\B31272\Documents\PSEN\PSENdev\lib\pref.psen","r")
lines=f.readlines()
f.close()
paths=lines[0].split(";")
WTconfig=[]
for i in range (3,8):
    try :
        paths[i]
    except :
        print "Error in defining wind turbines characteristics"
        WTconfig=[3.,5.,25.,1.225,0.05]
    else :
        WTconfig.append(float(paths[i]))

# Ouverture du fichier d'analyse de N-1 et recuperation des donnees
f=open("C:\B31272\Documents\PSEN\PSENdev\lib\contin.psen","r")
lines=f.readlines()
path_config_contin=lines[0].split(";")
f.close()

# Definition des lois des cinq variables aleatoires
N_1=int(data_config[1]) # N_1=1 to do N-1 studies 
wind_var1=int(data_config[3]) # To take wind1 variability into account
wind_var2=int(data_config[4]) # To take wind2 variability into account
PV_var=int(data_config[2]) # To take PV variability into account
load_var=int(data_config[5]) # To take load variability into account

# Creation variable nom dossier N-1
if N_1 == 1 :
    folderN_1 = '1_'
else :
    folderN_1 = '_'

# Recuperation des chemins du dossier d'installation de PSSE, .SAV de l'etude et nom du rapport
folder=paths[1]
doc_base= paths[0]
exec_file="report.txt"

# Definition des groupes de production PV, eoliennes, des intercos et des lignes en N-1
ENR=config_ENR(paths[2])
windTurbines1 = ENR[1] # Buses with wind turbines 1
windTurbines2 = ENR[2] # Buses with wind turbines 2
solarPV = ENR[0] # Buses with solar PV plant
intercos=ENR[3] # Buses with interconnexions
# Lines with contingency
try :
    config_contingency(path_config_contin)
except IOError :  # Si le fichier n'est pas dans un bon format on traite l'exception
    nb_lines=1
    print 'Error with contingency input file'
else :
    continAll = config_contingency(path_config_contin)
    continLines = continAll[0]
    continGroups = continAll[1]
    continVal = continAll[2]
    continProb = continAll[3]
    
    
# Probabilistic study information
#==============================================================================
# Create the marginal distributions
distributionX0 = data_load2 
distributionX1 = getUserDefined(continVal,continProb)
distributionX2 = data_wind1 
distributionX3 = data_wind2
distributionX4 = data_PV 

# Create the correlations between the distributions
corr10=float(data_corr[0])
corr20=float(data_corr[1])
corr30=float(data_corr[2])
corr40=float(data_corr[3])
corr21=float(data_corr[4])
corr31=float(data_corr[5])
corr41=float(data_corr[6])
corr32=float(data_corr[7])
corr42=float(data_corr[8])
corr43=float(data_corr[9])

# Probabilistic Study: central dispersion => Monte Carlo or LHS iterations
montecarlosize = int(data_config[0])

#Extension name for the folders and files
day=time.strftime("%Y%m%d", gmtime())
hour=time.strftime("%Hh%Mm%S", gmtime())

#===============================================================================
#    CHARGEMENT DE PSSE     -   LOADING OF PSSE
#===============================================================================
pssFolder=str(paths[3])
import sys
sys.path.append(pssFolder)#r"C:\Program Files\PTI\PSSE33\PSSBIN")
os.environ['PATH'] = pssFolder+":"+os.environ['PATH'] #r"C:\Program Files\PTI\PSSE33\PSSBIN;"+ os.environ['PATH']
os.chdir(folder)
import psspy
import pssarrays
import redirect
_i=psspy.getdefaultint()
_f=psspy.getdefaultreal()
_s=psspy.getdefaultchar()
redirect.psse2py()
#import pssdb
psspy.psseinit(80000)

# Silent execution of PSSe
islct=6 # 6=no output; 1=standard
psspy.progress_output(islct)

# Enregistrement de l'heure de debut de simulation
f=open(exec_file, 'a')
start_time=time.clock()
f.write("Starting time: %f;     Monte Carlo Size : %f;      " % (start_time, montecarlosize))
f.close()

#===============================================================================
#    Fonction de wrappage     -   Wrapper function
#===============================================================================
def PSSEFunction(x):
    # Definition des variables globales
    global TStest
    global Xt
    global sizeY0
    global sizeY1
    global sizeY2
    global sizeY3
    global sizeY4
    global sizeY
    global wind_var
    global PV_var
    global N_1
    global load_var
    global logCSVfilename
    global logTXTfilename
    global ite
    global folder
    global day
    global folderN_1
    global fich
    global hour
    global montecarlosize
    global WTconfig
    global x2
    
    ite+=1 # incrementation du compteur
    
    # Load data from PSSe
    psspy.case(doc_base) #Launching of PSSE and opening the working file
    all_inputs_base=read_sav(doc_base) 
    buses_base=all_inputs_base[0]
    lines_base=all_inputs_base[1]
    transf_base=all_inputs_base[2]
    plants_base=all_inputs_base[3]
    loads_base=all_inputs_base[4]
    shunt_base=all_inputs_base[5]
    doci=folder+"\N"+folderN_1+day+"\CasNum"+str(ite)+".sav"  
    psspy.save(doci)
    
    # Total initial shunt on buses
    init_shunt = 0
    for i in range(len(shunt_base)) :
        init_shunt +=  float(shunt_base[i][2])
    
    # Configuration de l'OPF a partir des parametres de l'utilisateur
    nbeOPF=5 # Nombre de lancement max de l'OPF pour atteindre la convergence de l'algorithme
    psspy.report_output(6,"",[0,0])
    psspy.produce_opf_log_file(1,r"""DETAIL""")
    psspy.minimize_fuel_cost(int(data_OPF[0]))
    psspy.minimize_adj_bus_shunts(int(data_OPF[1]))
    psspy.minimize_load_adjustments(int(data_OPF[2]))
    psspy.initial_opf_barrier_coeff(100.0)
    psspy.opf_fix_all_generators(1)
    psspy.set_opf_report_subsystem(3,1)
    
    
    print "                     PSEN simulator, case number: "+str(ite)
    
    # 1. Affiche X
    nx = x.getSize()
    if TStest==1 :
        for i in range (len (Xt)) :
            if Xt[i] == -1 :
                if i == 0 and load_var==1 :
                    pass
                elif i == 1 and  N_1==1 :
                    x[i]=int(floor(x[i])) # Si on etudie le N-1 on arrondie la valeur tiree en floor : on obtient le numero de la ligne
                elif i == 2 and wind_var1==1 :
                   x[i]=eol(x[i],WTconfig)
                elif i == 3 and wind_var2==1 :
                   x[i]=eol(x[i],WTconfig)
                elif i == 4 and PV_var==1 :  # Si on etudie la variabilite de l'eolien on lui donne la valeur de production de l'eolienne a partir du vent
                   pass
                else :
                   x[i]=-1
            else :
                x[i]=float(Xt[i]) # Dans le cas d'une etude temporelle on lui donne la valeur de Xt
    else :
        if load_var==1 :
            pass # Sinon on donne la valeur tiree si on etudie la variabilite de x[0]
        else :
            x[0]=1 # Sinon on laisse la valeur de base
            
        if N_1==1 :
            x[1]=int(floor(x[1])) # Si on etudie le N-1 on arrondie la valeur tiree en floor : on obtient le numero de la ligne
        else :
            x[1]=-1 # Sinon on donne -1 comme marqueur

        if wind_var1==1:
            x[2]=eol(x[2],WTconfig) # Si on etudie la variabilite de l'eolien on lui donne la valeur de production de l'eolienne a partir du vent
        else :
            x[2]=0 # Sinon on considere qu'il n'y a pas d'eolien  
            
        if wind_var2==1:
            x[3]=eol(x[3],WTconfig) # Si on etudie la variabilite de l'eolien on lui donne la valeur de production de l'eolienne a partir du vent
        else :
            x[3]=0 # Sinon on considere qu'il n'y a pas d'eolien 
            
        if PV_var==1 : # Si on etudie la variabilite du PV on laisse sa valeur a la va
            pass
        else :
            x[4]=0 # Sinon on considere qu'il n'y a pas de PV
    for i in range(0,nx):
        print "x[%d]=%f" % (i,x[i])
    
    # 2. Fait le calcul avec PSSE
    #Editing some values in the PSSE .sav input file
    # Change the values of the different loads and treat large changes of load to help convergence
    if x[0] > 0.75 : 
        for i in range(0,np.array(loads_base).shape[0]) : # On change directement toutes les charges
            psspy.load_chng_4(int(loads_base[i][0]),r"""1""",[1,_i,_i,_i,_i,_i],[x[0]*loads_base[i][1],x[0]*loads_base[i][2],_f,_f,_f,_f])
    elif x[0] > 0.4 : 
        for i in range(0,np.array(loads_base).shape[0]) :  # On effectue un pretraitement en passant par une charge intermediaire
            psspy.load_chng_4(int(loads_base[i][0]),r"""1""",[1,_i,_i,_i,_i,_i],[(1+x[0])/2*loads_base[i][1],(1+x[0])/2*loads_base[i][2],_f,_f,_f,_f])
        psspy.fnsl([0,0,0,1,1,0,99,0]) # Load flow Newton Raphson
        psspy.bsys(3,0,[0.0,0.0],0,[],1,[1],0,[],0,[])
        psspy.set_opf_report_subsystem(3,0)
        psspy.nopf(0,1) # Lancement OPF
        for i in range(0,np.array(loads_base).shape[0]) : # On change toutes les charges
            psspy.load_chng_4(int(loads_base[i][0]),r"""1""",[1,_i,_i,_i,_i,_i],[x[0]*loads_base[i][1],x[0]*loads_base[i][2],_f,_f,_f,_f])
    else : 
        for i in range(0,np.array(loads_base).shape[0]) : # On effectue un pretraitement en passant par une charge intermediaire
            psspy.load_chng_4(int(loads_base[i][0]),r"""1""",[1,_i,_i,_i,_i,_i],[0.7*loads_base[i][1],0.7*loads_base[i][2],_f,_f,_f,_f])
        psspy.fnsl([0,0,0,1,1,0,99,0])
        psspy.bsys(3,0,[0.0,0.0],0,[],1,[1],0,[],0,[])
        psspy.set_opf_report_subsystem(3,0)
        psspy.nopf(0,1)
        for i in range(0,np.array(loads_base).shape[0]) : # On effectue un pretraitement en passant par une charge intermediaire
            psspy.load_chng_4(int(loads_base[i][0]),r"""1""",[1,_i,_i,_i,_i,_i],[0.4*loads_base[i][1],0.4*loads_base[i][2],_f,_f,_f,_f])
        psspy.fnsl([0,0,0,1,1,0,99,0])
        psspy.bsys(3,0,[0.0,0.0],0,[],1,[1],0,[],0,[])
        psspy.set_opf_report_subsystem(3,0)
        psspy.nopf(0,1)
        for i in range(0,np.array(loads_base).shape[0]) : # On change toutes les charges
            psspy.load_chng_4(int(loads_base[i][0]),r"""1""",[1,_i,_i,_i,_i,_i],[x[0]*loads_base[i][1],x[0]*loads_base[i][2],_f,_f,_f,_f])

    x2=[]
    for sz in range(0,nx):
        x2.append(float(x[sz]))

    if x[1]<0 :
        pass
    elif x[1] < len(continLines) : # L'element tire est une ligne
        line_num=int(x[1])
        from_bus=continLines[int(line_num)][0]
        to_bus=continLines[int(line_num)][1]
        br_id=continLines[int(line_num)][2]#.replace('@','')
        psspy.branch_chng(from_bus,to_bus,str(br_id),[0,_i,_i,_i,_i,_i],[ _f, _f, _f,_f,_f,_f,_f,_f,_f,_f,_f,_f,_f,_f,_f])  
        x2[1]='Line '+str(from_bus)+'-'+str(to_bus)+'#'+str(br_id)
    elif x[1] < (len(continLines)+len(continGroups)) :
        group_num = int(x[1])-len(continLines)
        bus_num = continGroups[int(group_num)][0]
        bus_id = continGroups[int(group_num)][1]
        psspy.machine_chng_2(int(bus_num),str(bus_id),[0,_i,_i,_i,_i,_i],[_f,_f,_f,_f,_f,_f,_f,_f,_f,_f,_f,_f,_f,_f,_f,_f,_f]) # Change Interconnection disponibility
        psspy.opf_gendsp_indv(int(bus_num),str(bus_id),_i,0.0)
        x2[1]='Group '+str(bus_num)+'#'+str(bus_id)
    #elif x[1] < len(intercos) :
        #mat_num=int(x[1])
        #psspy.machine_chng_2(int(intercos[mat_num][0]),str(intercos[mat_num][2]),[0,_i,_i,_i,_i,_i],[_f,_f,_f,_f,_f,_f,_f,_f,_f,_f,_f,_f,_f,_f,_f,_f,_f]) # Change Interconnection disponibility
        #psspy.opf_gendsp_indv(int(intercos[mat_num][0]),str(intercos[mat_num][2]),_i,0.0)
        #x[1]=-mat_num
    else : 
        pass
        # Change the bus that is not in service
        #intercos = []
        #line_num=int(x[1]-len(intercos))
        #from_bus=lines_con[int(line_num)-1][0]
        #to_bus=lines_con[int(line_num)-1][1]
        #br_id=lines_con[int(line_num)-1][2]#.replace('@','')
        #psspy.branch_chng(from_bus,to_bus,str(br_id),[0,_i,_i,_i,_i,_i],[ _f, _f, _f,_f,_f,_f,_f,_f,_f,_f,_f,_f,_f,_f,_f])
        #x[1]=line_num
    # Change the production of the wind turbines
    if np.matrix(windTurbines1).shape[1]>0 :
        for i in range(0,np.matrix(windTurbines1).shape[0]) :
            psspy.machine_chng_2(windTurbines1[i][0],str(windTurbines1[i][2]),[1,_i,_i,_i,_i,_i],[x[2]*plants_base[windTurbines1[i][1]][6],_f,_f,_f,_f,_f,_f,_f,_f,_f,_f,_f,_f,_f,_f,_f,_f])
            
    if np.matrix(windTurbines2).shape[1]>0 :
        for i in range(0,np.matrix(windTurbines2).shape[0]) :
            psspy.machine_chng_2(windTurbines2[i][0],str(windTurbines2[i][2]),[1,_i,_i,_i,_i,_i],[x[3]*plants_base[windTurbines2[i][1]][6],_f,_f,_f,_f,_f,_f,_f,_f,_f,_f,_f,_f,_f,_f,_f,_f])
            
    # Change the production of the PV stations
    if np.matrix(solarPV).shape[1]>0 :
        for i in range(0,np.matrix(solarPV).shape[0]) :
            psspy.machine_chng_2(solarPV[i][0],str(solarPV[i][2]),[1,_i,_i,_i,_i,_i],[x[4]*plants_base[solarPV[i][1]][6],_f,_f,_f,_f,_f,_f,_f,_f,_f,_f,_f,_f,_f,_f,_f,_f])
    
    psspy.save(doci) #Saving .sav modifications
    ok=1
    while nbeOPF>=0 :
        #for i in (zip(*buses_base)[0]) : psspy.bus_chng_3(i,[_i,_i,_i,_i],[_f, 1.05,_f,_f,_f,_f,_f],_s)
        psspy.fnsl([0,0,0,1,1,1,99,0])
        psspy.bsys(3,0,[0.0,0.0],0,[],1,[1],0,[],0,[])
        psspy.set_opf_report_subsystem(3,0)
        psspy.nopf(0,1)
        if psspy.solved()==7:
            print 'CONVERGENCE          CAS '+str(ite)
            ok=1
            break
        else :
            print '==================================================================='
            print 'NO CONVERGENCE'
            print '==================================================================='
            ok=0
            #for i in range (134) :    
                #psspy.opf_bus_indv(i,[_i,0],[_f, 0.7,_f,_f,_f])
        nbeOPF-=1
    psspy.save(doci)
    all_inputs=read_sav(doci)
    buses=all_inputs[0];lines=all_inputs[1];transf=all_inputs[2];plants=all_inputs[3];loads=all_inputs[4]; shunt=all_inputs_base[5]
    
    # 3. Affiche Y  
    sizeY4=np.matrix(shunt).shape[0]
    y=np.zeros(2*sizeY0+sizeY1+3*sizeY2+sizeY3+sizeY4)
    z=np.zeros(8)
    rate_mat_index=Irate_num+2
    if ok==1 : 
        # Creates the quantities of interest
        for i in range (sizeY2) :
            if lines [i][rate_mat_index]>100 :
                z[0]+=1 # Number of lines above 100% of their limits
        for i in range (sizeY1):
            if buses[i][2]>1.06 :
                z[1]+=1
            if buses[i][2]<0.9399 :
                z[1]+=1 # Number of buses outside of their voltage limits
        for i in range (sizeY0) :
            z[2]+=float(plants[i][3]) # Total active production
        for i in range (sizeY3) :
            z[3]+=float(loads[i][1]) # Total active consumption
        z[4]=(z[2]-z[3])/z[2]*100 # Active power losses
        for i in range (sizeY2) :
            if lines [i][3]>z[5] :
                z[5]=lines [i][rate_mat_index] # Max flow in lines
        for i in range (sizeY2) :
            if lines [i][rate_mat_index]>90 :
                z[6]+=1
        z[6]=z[6]-z[0] # Number of lines between 90% and 100% of their limits
        
        final_shunt=0
        for i in range (sizeY4) :
            final_shunt+=shunt[i][2]
        z[7]=final_shunt-init_shunt
           
       # Creates the output vectors
        for Pmach in range (sizeY0): 
            y[Pmach]=float(plants[Pmach][3])
        for Qmach in range (sizeY0): 
            y[Qmach+sizeY0]=float(plants[Qmach][4])
        for Vbus in range (sizeY1): 
            y[Vbus+2*sizeY0]=float(buses[Vbus][2])
        for Iline in range (sizeY2): 
            y[Iline+2*sizeY0+sizeY1]=float(lines[Iline][rate_mat_index])
        for Pline in range (sizeY2): 
            y[Pline+2*sizeY0+sizeY1+sizeY2]=float(lines[Pline][6])
        for Qline in range (sizeY2): 
            y[Qline+2*sizeY0+sizeY1+2*sizeY2]=float(lines[Qline][7])
        for Pload in range (sizeY3) :
            y[Pload+2*sizeY0+sizeY1+3*sizeY2]=float(loads[Pload][1])
        for Qshunt in range (sizeY4) :
            y[Qshunt+2*sizeY0+sizeY1+3*sizeY2+sizeY3]=float(shunt[Qshunt][2])
    
        #Ecris les sorties
        print "sorties:"
        nz = len(z)
        for i in range(0,nz):
            print "z[%d]=%f" % (i,z[i])
        MyLogger(x2,y,z,logCSVfilename,logTXTfilename,ite)
        #MyMultiLogger (x2, y, sizeY, z, ite, folder, day, fich, hour)
        return NumericalPoint(z)
    else : 
        MyLogger(x2,y,z,logCSVfilename,logTXTfilename,ite)
        #MyMultiLogger (x2, y, sizeY, z, ite, folder, day, fich, hour)
        return NumericalPoint(z)

#===============================================================================
#   DEFINITION DU WRAPPER -  WRAPPER's DEFINITION
#===============================================================================
# Initialize size output
psspy.case(doc_base) 
all_inputs_base=read_sav(doc_base) 
buses_base=all_inputs_base[0]
lines_base=all_inputs_base[1]
trans_base=all_inputs_base[2]
plants_base=all_inputs_base[3]
loads_base=all_inputs_base[4]
shunt_base=all_inputs_base[5]
sizeY0=np.matrix(plants_base).shape[0]
sizeY1=np.matrix(buses_base).shape[0]
sizeY2=np.matrix(lines_base).shape[0]
sizeY3=np.matrix(loads_base).shape[0]
sizeY4=np.matrix(shunt_base).shape[0]
sizeY=[sizeY0,sizeY1,sizeY2,sizeY3,sizeY4]
sizeOutput=sizeY2


class PSSEWrapperClass(OpenTURNSPythonFunction) : 
  def __init__(self) : 
     OpenTURNSPythonFunction.__init__(self,5,8)
  def _exec(self,x) : 
      return PSSEFunction(x)

# Initialize the folder
newpath = folder+"\N"+folderN_1+day
if not os.path.exists(newpath): os.makedirs(newpath)

# Test the Num. Math. Function
pssefun = NumericalMathFunction(PSSEWrapperClass())

# Definition of the function to use
inputDim = pssefun.getInputDimension()
outputDim = pssefun.getOutputDimension()

# Initialization of the distribution collection:
#aCollection = DistributionCollection()

# Create a collection of the marginal distributions
collectionMarginals = DistributionCollection(inputDim)
collectionMarginals[0] = Distribution(distributionX0) # Load distribution
collectionMarginals[1] = Distribution(distributionX1) # N-1 distribution
collectionMarginals[2] = Distribution(distributionX2) # Wind 1 distribution
collectionMarginals[3] = Distribution(distributionX3) # Wind 2 distribution
collectionMarginals[4] = Distribution(distributionX4) # PV distribution

#Create a correlation matrix as copulas
corr=CorrelationMatrix(inputDim)

corr[1,0]=corr10
corr[2,0]=corr20
corr[3,0]=corr30
corr[4,0]=corr40
corr[0,1]=corr10
corr[2,1]=corr21
corr[3,1]=corr31
corr[4,1]=corr41
corr[0,2]=corr20
corr[1,2]=corr21
corr[3,2]=corr32
corr[4,2]=corr42
corr[0,3]=corr30
corr[1,3]=corr31
corr[2,3]=corr32
corr[4,3]=corr43
corr[0,4]=corr40
corr[1,4]=corr41
corr[2,4]=corr42
corr[3,4]=corr43

copula=Copula(NormalCopula(corr))


# Create the input probability distribution, args are the distributions, the correlation laws
inputDistribution = ComposedDistribution(collectionMarginals, copula)

# Create the input random vector
"""inputRandomVector = RandomVector(inputDistribution)

# Create the output variable of interest
outputVariableOfInterest =  RandomVector(pssefun, inputRandomVector)
outputVariableOfInterest.setDescription(pssefun.getOutputDescription())"""

#===============================================================================
#   ETUDE DE DISPERSION CENTRALE    -   CENTRAL DEVIATION STUDY
#===============================================================================
# Initialize the logger : write the headers 
logCSVfilename=folder+"\N"+folderN_1+day+"\simulationDClog"+hour+".csv" # Name of the file : global variable
f = open(logCSVfilename, "a")
f.write("Iteration;;X:Load(pu);X:lineOff#;XProdEolienne1%Pnom;XProdEolienne2%Pnom;X:ProdPV%Pnom;;Y:NbeTransit;Y:NbeTension;Y:PProdTot;Y:PConsoTot;Y:%Losses;Y:Max%A;Y:NbeTransit_0.9-1;Y:AddedMVAR;;")
# Names of the Output variables withConso the bus number
for name in range (sizeY0):
    f.write("Y:PMachine"+str(plants_base[name][0])+";")
for name in range (sizeY0):
    f.write("Y:QMachine"+str(plants_base[name][0])+";")
for name in range (sizeY1):
    f.write("Y:VBus"+str(buses_base[name][0])+";")
for name in range (sizeY2):
    f.write("Y"+str(name+1)+":%Rate "+str(lines_base[name][0])+"-"+str(lines_base[name][1])+";")
for name in range (sizeY2):
    f.write("Y"+str(name+1)+":P "+str(lines_base[name][0])+"-"+str(lines_base[name][1])+";")
for name in range (sizeY2):
    f.write("Y"+str(name+1)+":Q "+str(lines_base[name][0])+"-"+str(lines_base[name][1])+";")
for name in range (sizeY3):
    f.write("Y:Load "+str(loads_base[name][0])+";")
for name in range (sizeY4):
    f.write("Y:Shunt bus "+str(shunt_base[name][0])+";")
f.write("\n")
# Names of the Output variables with the bus names
f.write("#;;pu;line number;%Pnom;%Pnom;%Pnom;;Nbe;Nbe;MW;MW;%;%;Nbe;MVAR;;")
for name in range (sizeY0):
    f.write(str(plants_base[name][8])+";")
for name in range (sizeY0):
    f.write(str(plants_base[name][8])+";")
for name in range (sizeY1):
    f.write(str(buses_base[name][3])+";")
for name in range (sizeY2):
    f.write(str(lines_base[name][8])+"-"+str(lines_base[name][9])+";")
for name in range (sizeY2):
    f.write(str(lines_base[name][8])+"-"+str(lines_base[name][9])+";")
for name in range (sizeY2):
    f.write(str(lines_base[name][8])+"-"+str(lines_base[name][9])+";")
for name in range (sizeY3):
    f.write(str(loads_base[name][4])+";")
for name in range (sizeY4):
    f.write(str(shunt_base[name][3])+";")
f.write("\n")
f.close()

logTXTfilename=folder+"\N"+folderN_1+day+"\simulationDClog"+hour+".txt" # Name of the file : global variable
f = open(logTXTfilename, "a")
f.write("Iteration\tX:Load(pu)\tX:lineOff#\tXProdEolienne1%Pnom\ttXProdEolienne2%Pnom\tX:ProdPV%Pnom\tY:NbeTransit\tY:NbeTension\tY:PProdTot\tY:PConsoTot\tY:%Losses\tY:Max%A\tY:NbeTransit_0.9-1\tY:AddedShunt\t")
# Names of the Output variables withConso the bus number
for name in range (sizeY0):
    f.write("Y:PMachine"+str(plants_base[name][0])+" - "+str(plants_base[name][8])+"\t")
for name in range (sizeY0):
    f.write("Y:QMachine"+str(plants_base[name][0])+" - "+str(plants_base[name][8])+"\t")
for name in range (sizeY1):
    f.write("Y:VBus"+str(buses_base[name][0])+" - "+str(buses_base[name][3])+"\t")
for name in range (sizeY2):
    f.write("Y"+str(name+1)+":%RateA "+str(lines_base[name][0])+"-"+str(lines_base[name][1])+" - "+str(lines_base[name][8])+"-"+str(lines_base[name][9])+"\t")
for name in range (sizeY2):
    f.write("Y"+str(name+1)+":P "+str(lines_base[name][0])+"-"+str(lines_base[name][1])+" - "+str(lines_base[name][8])+"-"+str(lines_base[name][9])+"\t")
for name in range (sizeY2):
    f.write("Y"+str(name+1)+":Q "+str(lines_base[name][0])+"-"+str(lines_base[name][1])+" - "+str(lines_base[name][8])+"-"+str(lines_base[name][9])+"\t")
for name in range (sizeY3):
    f.write("Y:Load "+str(loads_base[name][0])+" - "+str(loads_base[name][4])+"\t")
for name in range (sizeY4):
    f.write("Y:Shunt "+str(shunt_base[name][0])+" - "+str(shunt_base[name][3])+"\t")
f.write("\n")
f.close()

"""
# Initialize the multilogger : write the headers 
for fich in range (np.size(sizeY,0)):
    multilogfilename=folder+"\N"+day+"\Y"+str(fich)+"simulationDClog"+hour+".csv"
    f=open(multilogfilename, 'a')
    f.write("Iteration;;X:Load(pu);X:lineOff#;XProdEolienne1%Pnom;XProdEolienne2%Pnom;X:ProdPV%Pnom;;Y:NbeTransit;Y:NbeTension;Y:PProdTot;Y:PConsoTot;Y:Max%A;Y:NbeTransit_0.9-1;;")
    if fich == 0 :
        for name in range (sizeY[0]):
            f.write("Y:PMachine"+str(plants_base[name][0])+";")
        f.write("\n")
        f.write("#;;pu;line number;%Pnom;%Pnom;%Pnom;;Nbe;Nbe;MW;MW;%;%;Nbe;;")
        for name in range (sizeY[0]):
            f.write(str(plants_base[name][8])+";")
        f.write("\n")
        f.close()
    elif fich == 1 :
        for name in range (sizeY[1]):
            f.write("Y:VBus"+str(buses_base[name][0])+";")
        f.write("\n")
        f.write("#;;pu;line number;%Pnom;%Pnom;%Pnom;;Nbe;Nbe;MW;MW;%;%;Nbe;;")
        for name in range (sizeY[1]):
            f.write(str(buses_base[name][3])+";")
        f.write("\n")
        f.close()
    elif fich == 2 :
        for name in range (sizeY[2]):
            f.write("Y"+str(name+1)+":%RateA "+str(lines_base[name][0])+"-"+str(lines_base[name][1])+";")
        f.write("\n")
        f.write("#;;pu;line number;%Pnom;%Pnom;%Pnom;;Nbe;Nbe;MW;MW;%;%;Nbe;;")
        for name in range (sizeY[2]):
            f.write(str(lines_base[name][8])+"-"+str(lines_base[name][9])+";")
        f.write("\n")
        f.close()
    elif fich == 3 :
        for name in range (sizeY[3]):
            f.write("Y:Ploads "+str(loads_base[name][0])+";")
        f.write("\n")
        f.write("#;;pu;line number;%Pnom;%Pnom;%Pnom;;Nbe;Nbe;MW;MW;%;%;Nbe;;")
        for name in range (sizeY[3]):
            f.write(str(loads_base[name][4])+";")
        f.write("\n")
        f.close()

"""
# Start the simulations
ite=0
print "\n\n\n                     Starting PSEN "+str(montecarlosize)+" simulations"

"""inputSample=inputRandomVector.getSample(montecarlosize)
inputSample.setDescription( ("X0","X1","X2","X3") )
inputSample.exportToCSVFile("InputSamples.csv")"""

if sum(corr) == 5 :
    myLHSE = LHSExperiment(inputDistribution,montecarlosize)
    inputSample = myLHSE.generate()
else :
    myMCE = MonteCarloExperiment(inputDistribution,montecarlosize)
    inputSample = myMCE.generate()

try :
    time_serie
except NameError :
    print 'Probabilistic'
    TStest=0
    outputSampleAll = pssefun(inputSample)#outputVariableOfInterest.getSample(montecarlosize)
else : 
    TStest=1
    for i in range (len(time_serie_mat)) :
        print 'Time serie'
        RandomGenerator.SetSeed(i)
        Xt=[]
        n=0
        for j in range (len(time_serie_file)) :
            if time_serie_file[j] == -1 :
                Xt.append(-1)
                n+=1
            else :
                Xt.append(time_serie_mat[i][j-n])
        Xt.insert(1,-1)
        try : 
            outputSampleAll
        except :
            outputSampleAll = pssefun(inputSample)
        else : 
            outputSampleAll.add(pssefun(inputSample))

outputDim=outputSampleAll.getDimension()
outputSize=outputSampleAll.getSize()

outputSample=NumericalSample(0,outputDim)
outputSampleMissed=NumericalSample(0,outputDim)

for i in range (outputSize):
    if outputSampleAll[i,5]==0 :
        outputSampleMissed.add(outputSampleAll[i])
    else :
        outputSample.add(outputSampleAll[i])

outputDescription=[]
for i in range (outputDim):
    outputDescription.append("Y"+str(i))
outputSample.setDescription( outputDescription )

# Get the empirical mean and standard deviations
empMeanX = inputSample.computeMean()
empSdX = inputSample.computeStandardDeviationPerComponent()
empiricalMean = outputSample.computeMean()
empiricalSd = outputSample.computeStandardDeviationPerComponent()

f=open(logCSVfilename, 'a')
f.write("\n")
f.write('Mean;;')
for i in range(0,inputDim):
    f.write("%f;" % (empMeanX[i]))
f.write(";")
for i in range(0,outputDim):
    f.write("%f;" % (empiricalMean[i]))
f.write(";")
f.write("\nStandard deviation;;")
for i in range(0,inputDim):
    f.write("%f;" % (empSdX[i]))
f.write(";")
for i in range(0,outputDim):
    f.write("%f;" % (empiricalSd[i]))
f.write(";")
f.close()
    
f=open(exec_file,'a')
#stop_time=100*times()[0]
stop_time=time.clock()
f.write("Stop time: %f;     Duration: %f;      Time per execution: %f; " % (stop_time, stop_time-start_time, (stop_time-start_time)/montecarlosize))
f.write("\n\n")
f.close()

print '\n\nSimulated '+str(montecarlosize)+' cases in '+ str(stop_time-start_time)+' seconds. Average '+str((stop_time-start_time)/montecarlosize)+'s per case.'

nMissed=int(outputSampleMissed.getSize())

print '\n\n             Non-convergence rate is '+str(round(nMissed*100/montecarlosize,3))+' % ('+str(outputSampleMissed.getSize())+' cases on '+str(montecarlosize)+')'

#graphical_out(inputSample, outputSampleAll, inputDim, outputDim, montecarlosize)
 
