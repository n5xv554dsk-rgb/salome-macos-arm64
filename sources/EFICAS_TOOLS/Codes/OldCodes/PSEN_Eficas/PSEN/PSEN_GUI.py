# -*- coding: cp1252 -*-
# ======================== PSEN graphic interface ========================
# This Python script creates a graphical interface to parameter and launch PSEN

# ============== Import useful modules =================
from Tkinter import *
from ttk import Combobox
import tkFileDialog, os
import subprocess
from time import sleep
import numpy as np

# ============== Initialize some variables  =================
config=[]
for i in range (60) : # config[] will be used as a list of preferences for PSEN study
    config.append('')

root = Tk() # Creates the main window
root.wm_withdraw() # The main window is withdrawn/hidden

CIST=PhotoImage(file="lib\CISTlogo.gif") # Load images
header=PhotoImage(file="lib\header.gif")
WTcurve=PhotoImage(file="lib\WTcurve.gif")

# ============== Define functions  =================

# browse_PSSe function is used to get the .SAV file path from the user.
# tkFileDialog.askopenfilename offers a browsing interface to the user
def browse_PSSe() :
    global savAdress
    savAdress = tkFileDialog.askopenfilename(parent=fenPref,title='Open PSSe SAV file',filetypes=[('SAV files', '.sav')])
    savAdressD.set(savAdress)
    fenPref.update_idletasks() # this updates the values in the fenPref window (defined in preferences())
    print 'Added: '+str(savAdress)
    return savAdress

# browse_ENR function is used to get a .CSV file path from the user
# The CSV file contains a list of machines and their type (PV, Wind, Interconnexion)
# tkFileDialog.askopenfilename offers a browsing interface to the user
def browse_ENR() :
    global ENRpath
    ENRpath = tkFileDialog.askopenfilename(parent=fenPref,title='Open ENR configuration',filetypes=[('CSV files', '.csv'),('All files', '.*')])
    ENRpathD.set(ENRpath)
    fenPref.update_idletasks() # this updates the values in the fenPref window (defined in preferences())
    print 'Added: '+str(ENRpath)
    return ENRpath    

# browse_folder function is used to get a folder path from the user
# This folder is used to save all study files (.sav, .csv, ...)
# tkFileDialog.askdirectory offers a browsing interface to the user    
def browse_folder() :
    global folderPATH
    folderPATH = tkFileDialog.askdirectory(parent=fenPref,title='Choose working folder')
    folderPATHD.set(folderPATH)
    fenPref.update_idletasks()  # this updates the values in the fenPref window (defined in preferences())
    print 'Added: '+str(folderPATH)
    return folderPATH

# savePref function is used to save preferences input in fenPref window (defined in preferences())
def savePref() :
    global Vcin, Vrate, Vcout, Rho, lossrate # These variables are global because they are used in savePSEN()
    try : # Test if the user has defined all the requested variables
        savAdress
        folderPATH
        ENRpath
        VcinD
        VrateD
        VcoutD
        RhoD
        lossrateD
    except NameError : # If not a new window pops up and explains the data is missing
        fenetre2 = Tk()
        champ_label = Label(fenetre2, text="ERROR\nNo file and/or folder selected", fg="red", font=("Century Gothic",16))
        champ_label.pack(side=TOP, fill=BOTH, expand=YES)
    else : # If it's OK it gets the data from the fields and save it into config[]
        config[9]=VcinD.get(); config[10]=VrateD.get(); config[11]=VcoutD.get(); config[12]=RhoD.get(); config[13]=lossrateD.get(); config[2]=ENRpathD.get(); config[1]=folderPATHD.get(); config[0]=savAdressD.get()
        Vcin=VcinD.get()
        Vrate=VrateD.get()
        Vcout=VcoutD.get()
        Rho=RhoD.get()
        lossrate=lossrateD.get()
        f=open("lib\pref.psen", "w") # Creates a config file with values to give to PSSEWrapper.py
        f.write(str(savAdress)+";"+str(folderPATH)+";"+str(ENRpath)+";"+str(Vcin)+";"+str(Vrate)+";"+str(Vcout)+";"+str(Rho)+";"+str(lossrate)+";0\n")
        f.close()
    try : 
        fenPref
    except NameError :
        pass
    else :
        fenPref.destroy()
        print 'Preferences saved'
   
# refresh_pref function is used to refresh fields value in fenPref window (defined in preferences())
def refresh_pref () :
        try :
            saved
        except NameError : # if saved hasn't been created yet there is no data to update
            pass
            print 'No configuration yet'
        else : # if it has been created we set fields variables and update the window with update_idletasks()
            print 'Update values'
            global continpath
            global model_Path
            global PSSEfolder
            VcinD.set(config[9])
            VrateD.set(config[10])
            VcoutD.set(config[11])
            RhoD.set(config[12])
            lossrateD.set(config[13])
            ENRpathD.set(ENRpath)
            folderPATHD.set(folderPATH)
            savAdressD.set(savAdress)
            fenPref.update_idletasks() 

# savePSEN function is used to create a .PSEN file containing all users parameters and preferences        
def savePSEN() :
    global savePATH
    global saved
    saved=1

    # === We get all the fields data ===    
    
    MCS_num=var_MCS.get()
    N_1_opt=N_1.get()
    PV_opt=PV.get()
    Wind1_opt=Wind1.get()
    Wind2_opt=Wind1.get()
    Load_opt=Load.get()

    load_type=choix_load.get()
    load1=var_loadn1.get()
    load2=var_loadn2.get()
    load3=var_loadn3.get()
    load4=var_loadn4.get()
    loadPath=loadPathD.get()

    wind11_type=choix_wind11.get()
    wind11=var_windn11.get()
    wind12=var_windn12.get()
    wind13=var_windn13.get()
    wind14=var_windn14.get()
    wind1Path=wind1PathD.get()
    
    wind21_type=choix_wind21.get()
    wind21=var_windn21.get()
    wind22=var_windn22.get()
    wind23=var_windn23.get()
    wind24=var_windn24.get()
    wind2Path=wind2PathD.get()
    
    pv_type=choix_pv.get()
    pv1=var_pvn1.get()
    pv2=var_pvn2.get()
    pv3=var_pvn3.get()
    pv4=var_pvn4.get()
    pvPath=pvPathD.get()
    
    C01=C01D.get()
    C02=C02D.get()
    C03=C03D.get()
    C04=C04D.get()
    C12=C12D.get()
    C14=C14D.get()
    C13=C13D.get()
    C23=C23D.get()
    C24=C24D.get()
    C34=C34D.get()
    
    fuel_cost_opt = fuel_cost.get()
    bus_shunt_opt = bus_shunt.get()
    bus_loads_opt = bus_loads.get()
    
    rate_choice = rate_choiceD.get()
    
    try :
        contin_lines_Path
        contin_groups_Path
    except NameError : # If the user hasn't choose a path for the contingency CSV file, we create it as blank to save the data
        contin_lines_Path=''
        contin_groups_Path=''
    
    # We ask the user the name and path of the file
    savePATH = tkFileDialog.asksaveasfilename(parent=fenetre,title='Save the file as ...',defaultextension='.psen',filetypes=[('PSEN file', '.psen')])
    try :
        len(savePATH)>0
    except NameError :
        pass
    else : # Writing all the variables in a specific order (could be improved with XML file for instance)
        f=open(savePATH,'w')
        f.write(str(savAdress)+";"+str(folderPATH)+";"+str(ENRpath)+";"
            +str(contin_lines_Path)+";"+str(contin_groups_Path)+";"+str(model_Path)+";"+str(PSSEfolder)+";"+str(orange_Path)+";"+str(python_Path)+";"
            +str(Vcin)+";"+str(Vrate)+";"+str(Vcout)+";"+str(Rho)+";"+str(lossrate)+";"
            +str(MCS_num)+";"+str(N_1_opt)+";"+str(PV_opt)+";"+str(Wind1_opt)+";"+str(Wind2_opt)+";"+str(Load_opt)+";"
            +str(load_type)+";"+str(load1)+";"+str(load2)+";"+str(load3)+";"+str(load4)+";"+str(loadPath)+";"
            +str(wind11_type)+";"+str(wind11)+";"+str(wind12)+";"+str(wind13)+";"+str(wind14)+";"+str(wind1Path)+";"
            +str(wind21_type)+";"+str(wind21)+";"+str(wind22)+";"+str(wind23)+";"+str(wind24)+";"+str(wind2Path)+";"
            +str(pv_type)+";"+str(pv1)+";"+str(pv2)+";"+str(pv3)+";"+str(pv4)+";"+str(pvPath)+";"
            +str(C01)+";"+str(C02)+";"+str(C03)+";"+str(C04)+";"+str(C12)+";"+str(C13)+";"+str(C14)+";"+str(C23)+";"+str(C24)+";"+str(C34)+";"
            +str(fuel_cost_opt)+";"+str(bus_shunt_opt)+";"+str(bus_loads_opt)+";"
            +str(rate_choice)+";0\n")
        f.close()
        print 'Successfuly saved case study'

# preferences function is a new window to update some PSEN parameters
def preferences () :   
    global fenPref
    global savAdressD
    global folderPATHD
    global ENRpathD
    global VcinD
    global VrateD
    global VcoutD
    global RhoD
    global lossrateD
    global config        
        
    fenPref = Toplevel(root) # Creating a new window
    fenPref.wm_iconbitmap('lib\PSEN.ico') # Window icon
    fenPref.wm_title('PSEN - Probabilistic Studies of Electrical Networks') # Window title
    
    f0p=Frame(fenPref, height=70, width=500, bd=2, relief=RIDGE)
    f0p.pack_propagate(0) # don't shrink
    f0p.pack()
    
    Label(f0p, text="PSSe .SAV file", fg="black", justify=LEFT, font=("Century Gothic",12)).pack(anchor=NW, padx=10, expand=YES)
    savAdressD=StringVar()
    Entry(f0p, textvariable=savAdressD, width=50).pack(side=LEFT, padx=15, expand=YES)
    Button(f0p, text="Load SAV file", command=browse_PSSe, height=15, width=30).pack(side=LEFT, fill=BOTH, expand=1, padx=5, pady=3)
    
    fline=Frame(fenPref, height=2, width=500, bg="grey")
    fline.pack_propagate(0) # don't shrink
    fline.pack(expand=1)
    
    f1p=Frame(fenPref, height=70, width=500, bd=2, relief=RIDGE)
    f1p.pack_propagate(0) # don't shrink
    f1p.pack()    
    
    Label(f1p, text="Working folder adress :", fg="black", justify=LEFT, font=("Century Gothic",12)).pack(anchor=NW, padx=10, expand=YES)
    folderPATHD=StringVar()
    Entry(f1p, textvariable=folderPATHD, width=50).pack(side=LEFT, padx=15, expand=YES)
    Button(f1p, text="Browse to working folder", command=browse_folder, height=15, width=30).pack(side=LEFT, fill=BOTH, expand=1, padx=5, pady=3)
    
    fline=Frame(fenPref, height=5, width=500, bg="grey")
    fline.pack_propagate(0) # don't shrink
    fline.pack(expand=1)
    
    f3p=Frame(fenPref, height=100, width=500, bd=2, relief=RIDGE)
    f3p.pack_propagate(0) # don't shrink
    f3p.pack()    
    
    Label(f3p, text="Machines configuration :", fg="black", justify=LEFT, font=("Century Gothic",12)).pack(anchor=NW, padx=10, expand=YES)
    Label(f3p, text="N.B. Use the PSSe machine tab, insert a new column in first and write PV for PV, W1 for wind 1, W2 for wind 2 or do nothing for non-ENR. Save as CSV", fg="black", justify=LEFT, wraplength=450).pack(anchor=NW, padx=10, expand=YES)
    ENRpathD=StringVar()
    Entry(f3p, textvariable=ENRpathD, width=50).pack(side=LEFT, padx=15, expand=YES)
    Button(f3p, text="Browse to ENR CSV file", command=browse_ENR, height=15, width=30).pack(side=LEFT, fill=BOTH, expand=1, padx=5, pady=3)
    
    fline=Frame(fenPref, height=5, width=500, bg="grey")
    fline.pack_propagate(0) # don't shrink
    fline.pack(expand=1)
    
    f4p=Frame(fenPref, height=120, width=500, bd=2, relief=RIDGE)
    f4p.pack_propagate(0) # don't shrink
    f4p.pack()    
    
    # Creates 5 entry for wind turbines characteristics    
    Label(f4p, text="Wind 1 & 2 characteristics :", fg="black", justify=LEFT, font=("Century Gothic",12)).pack(anchor=NW, padx=10, expand=YES)
    Label(f4p, text="If wind law, enter the following parameters : \nVcin, Vrate, Vcout, rho (air density kg.m-3, base is 1.225), lossrate (base is 0.05)\nIf power law: Vcin=0, Vrate=1, Vcout>=1. Law must take values between 0 and 1.", fg="black", justify=LEFT, wraplength=450).pack(anchor=NW, padx=10, expand=YES)
    VcinD = StringVar()
    Entry(f4p, textvariable=VcinD, width=13).pack(side=LEFT, padx=5, pady=5) 
    VrateD = StringVar()
    Entry(f4p, textvariable=VrateD, width=13).pack(side=LEFT, padx=5, pady=5)
    VcoutD = StringVar()
    Entry(f4p, textvariable=VcoutD, width=13).pack(side=LEFT, padx=5, pady=5)
    RhoD = StringVar()
    Entry(f4p, textvariable=RhoD, width=13).pack(side=LEFT, padx=5, pady=5)
    lossrateD = StringVar()
    Entry(f4p, textvariable=lossrateD, width=13).pack(side=LEFT, padx=5, pady=5)
    
    fline=Frame(fenPref, height=2, width=500, bg="grey")
    fline.pack_propagate(0) # don't shrink
    fline.pack(expand=1)
    
    f2p=Frame(fenPref, height=40, width=500, bd=2, relief=RIDGE)
    f2p.pack_propagate(0) # don't shrink
    f2p.pack()    
    
    Button(f2p, text="Save and quit", command=savePref, height=1, width=30).pack(anchor=N, fill=BOTH, expand=1, padx=5, pady=3)
    
    # Refresh the window data
    refresh_pref ()
    
# openPSEN function opens a .PSEN file with all PSEN parameters, read them and updates their value in the GUI
def openPSEN () :
    global openPATH
    global folderPATH
    global savAdress
    global ENRpath
    global contin_lines_Path
    global contin_groups_Path
    global model_Path
    global loadPath, wind1Path, wind2Path, pvPath
    global PSSEfolder
    global orange_Path
    global python_Path
    global config
    global Vcin; global Vrate; global Vcout; global Rho; global lossrate
    global PVpath
    
    openPATH = tkFileDialog.askopenfilename(parent=fenetre,title='Open PSEN file',filetypes=[('PSEN files', '.psen'),('All files', '.*'),])
    try :
        os.lstat(openPATH)
    except WindowsError : # If the user doesn't choose any file we don't open it
        pass 
    except NameError : # If the user doesn't choose any file we don't open it
        pass
    else :
        global saved # Create a saved variable : config list will be created
        saved=1
        f=open(openPATH,'r')
        lines=f.readlines()
        config=lines[0].split(";")
        savAdress=config[0]; folderPATH=config[1]; ENRpath=config[2];
        contin_lines_Path=config[3]; contin_groups_Path=config[4]; model_Path=config[5]; PSSEfolder=config[6]; orange_Path=config[7]; python_Path=config[8]; 
        Vcin=config[9]; Vrate=config[10]; Vcout=config[11]; Rho=config[12]; lossrate=config[13];
        loadPath=config[25]; wind1Path=config[31]; wind2Path=config[37]; pvPath=config[43]; 
        refresh(config)
        f=open("lib\pref.psen", "w")
        f.write(str(savAdress)+";"+str(folderPATH)+";"+str(ENRpath)+";"+str(Vcin)+";"+str(Vrate)+";"+str(Vcout)+";"+str(Rho)+";"+str(lossrate)+";0\n")
        f.close()
        print 'Successfuly opened '+str(openPATH)

# This function is not used yet
def numToName (num) :
    num=int(num)
    if num == 1 :
        name = "Normal(mean, stdev)"
    elif num == 2 :
        name = "Uniform(min, max)"
    elif num == 3 :
        name = "Exponential(lambda, gamma)"
    elif num == 4 :
        name = "Weibull(alpha, beta, gamma)"
    elif num == 5 :
        name = "TruncatedNormal(mean, stdev, min, max)"
    elif num == 6 :
        name = "Value list ([[v1,p1],[v2,p2],...])"
    elif num == 7 :
        name = "Histogram (steps, probabilities)"
    elif num == 10 :
        name = "PDF from file ()"
    elif num == 20 :
        name = "Time Serie from file (stepsize, number of points)"
    return name
        
# refresh function updates fields values in fenetre window
def refresh (config) :
    var_MCS.set(config[14])
    N_1.set(config[15])
    PV.set(config[16])
    Wind1.set(config[17])
    Wind2.set(config[18])
    Load.set(config[19])
    
    choix_load.set(config[20])
    var_loadn1.set(config[21])
    var_loadn2.set(config[22])
    var_loadn3.set(config[23])
    var_loadn4.set(config[24])
    loadPathD.set(config[25])
    
    choix_wind11.set(config[26])
    var_windn11.set(config[27])
    var_windn12.set(config[28])
    var_windn13.set(config[39])
    var_windn14.set(config[30])
    wind1PathD.set(config[31])
    
    choix_wind21.set(config[32])
    var_windn21.set(config[33])
    var_windn22.set(config[34])
    var_windn23.set(config[35])
    var_windn24.set(config[36])
    wind2PathD.set(config[37])
    
    choix_pv.set(config[38])
    var_pvn1.set(config[39])
    var_pvn2.set(config[40])
    var_pvn3.set(config[41])
    var_pvn4.set(config[42])
    pvPathD.set(config[43])

    C01D.set(config[44])
    C02D.set(config[45])
    C03D.set(config[46])
    C04D.set(config[47])
    C12D.set(config[48])
    C13D.set(config[49])
    C14D.set(config[50])
    C23D.set(config[51])
    C24D.set(config[52])
    C34D.set(config[53])
    
    fuel_cost.set(config[54])
    bus_shunt.set(config[55])
    bus_loads.set(config[56])

    rate_choiceD.set(config[57])

    fenetre.update_idletasks()

# PCpreferences function creates a window in which the user can choose some requested paths         
def PCpreferences ():
    global fenPrefPC
    global python_Path
    global orange_Path
    global PSSEfolder
    
    fenPrefPC = Tk()
    fenPrefPC.wm_iconbitmap('lib\PSEN.ico')
    fenPrefPC.wm_title('PSEN - Probabilistic Studies of Electrical Networks')
    
    Label(fenPrefPC, text="Configure PSEN for your computer : ", fg="black", justify=LEFT, font=("Century Gothic",12)).pack(anchor=NW, padx=10, expand=YES)
    Button(fenPrefPC, text="Path to Python 2.7.exe...", command=browse_Python, height=3, width=30).pack(side=LEFT, fill=BOTH, expand=1, padx=5, pady=3)
    Button(fenPrefPC, text="Path to orngCanvas.pyw...", command=browse_Orange, height=3, width=30).pack(side=LEFT, fill=BOTH, expand=1, padx=5, pady=3)
    Button(fenPrefPC, text="Path to PSSE33\PSSBIN...", command=browse_PSSEfolder, height=3, width=30).pack(side=LEFT, fill=BOTH, expand=1, padx=5, pady=3)
    Button(fenPrefPC, text="Save and close", command=closePCpref, height=3, width=15).pack(anchor=S, fill=BOTH, expand=1, padx=5, pady=10)
    
def closePCpref () :
    try : # Test if the user has defined all the requested variables
        python_Path
        orange_Path
        PSSEfolder
    except NameError : # If not a new window pops up and explains the data is missing
        fenetre2 = Tk()
        champ_label = Label(fenetre2, text="ERROR\nNo file and/or folder selected", fg="red", font=("Century Gothic",16))
        champ_label.pack(side=TOP, fill=BOTH, expand=YES)
    else : # If it's OK it gets the data from the fields and save it into config[]
        config[6]=PSSEfolder; config[7]=orange_Path; config[8]=python_Path 
    try : 
        fenPrefPC
    except NameError :
        pass
    else :
        fenPrefPC.destroy()
        print 'Data saved'

# PCpreferences function creates a window in which the user can choose some requested paths         
def ContinPreferences ():
    global fenPrefC
    global contin_lines_Path
    global contin_groups_Path
    
    fenPrefC = Tk()
    fenPrefC.wm_iconbitmap('lib\PSEN.ico')
    fenPrefC.wm_title('PSEN - Probabilistic Studies of Electrical Networks')
    
    Label(fenPrefC, text="Choose contingency files with probabilities : ", fg="black", justify=LEFT, font=("Century Gothic",12)).pack(anchor=NW, padx=10, expand=YES)
    Button(fenPrefC, text="Path to branches file", command=contin_lines, height=3, width=30).pack(side=LEFT, fill=BOTH, expand=1, padx=5, pady=3)
    Button(fenPrefC, text="Path to groups file", command=contin_groups, height=3, width=30).pack(side=LEFT, fill=BOTH, expand=1, padx=5, pady=3)
    Button(fenPrefC, text="Save and close", command=closeCpref, height=3, width=15).pack(anchor=S, fill=BOTH, expand=1, padx=5, pady=10)
    
def closeCpref () :
    try : # Test if the user has defined all the requested variables
        contin_lines_Path
        contin_groups_Path
    except NameError : # If not a new window pops up and explains the data is missing
        fenetre2 = Tk()
        champ_label = Label(fenetre2, text="ERROR\nNo file and/or folder selected", fg="red", font=("Century Gothic",16))
        champ_label.pack(side=TOP, fill=BOTH, expand=YES)
    else : # If it's OK it gets the data from the fields and save it into config[]
        config[3]=contin_lines_Path; config[4]=contin_lines_Path
        f=open("lib\contin.psen", "w")
        f.write(str(contin_lines_Path)+";"+str(contin_groups_Path)+";0\n")
        f.close()
    try : 
        fenPrefC
    except NameError :
        pass
    else :
        print 'Added :\n'+str(contin_lines_Path)+'\n'+str(contin_groups_Path)
        fenPrefC.destroy()    
        print 'Saved contingency data'
        
def contin_lines () :
    global contin_lines_Path
    contin_lines_Path =  tkFileDialog.askopenfilename(parent=fenetre,title='Choose contingency lines file',filetypes=[('CSV file', '.csv'),('All files', '.*')])
    return contin_lines_Path
    
def contin_groups () :
    global contin_groups_Path
    contin_groups_Path =  tkFileDialog.askopenfilename(parent=fenetre,title='Choose contingency groups file',filetypes=[('CSV file', '.csv'),('All files', '.*')])
    return contin_groups_Path
        
# Hide command window
if os.name == 'nt': # The functions only work with Windows OS
    try:
        import win32gui, win32console, win32con
        win32console.GetConsoleWindow() # do nothing, this is just a test
        def set_attached_console_visible():
            state=is_attached_console_visible()
            win32gui.ShowWindow(win32console.GetConsoleWindow(), win32con.SW_HIDE if state else win32con.SW_SHOW)
        def is_attached_console_visible():
            return win32gui.IsWindowVisible(win32console.GetConsoleWindow())
    except (ImportError, NotImplementedError):
        pass


# config_save function is used to save configuration for PSSEWrapper
def config_save():
    MCS_num=var_MCS.get()
    N_1_opt=N_1.get()
    PV_opt=PV.get()
    Wind1_opt=Wind1.get()
    Wind2_opt=Wind2.get()
    Load_opt=Load.get()

    load_type=choix_load.get()
    load1=var_loadn1.get()
    load2=var_loadn2.get()
    load3=var_loadn3.get()
    load4=var_loadn4.get()
    loadPath=loadPathD.get()
    
    wind11_type=choix_wind11.get()
    wind11=var_windn11.get()
    wind12=var_windn12.get()
    wind13=var_windn13.get()
    wind14=var_windn14.get()
    wind1Path=wind1PathD.get()
    
    wind21_type=choix_wind21.get()
    wind21=var_windn21.get()
    wind22=var_windn22.get()
    wind23=var_windn23.get()
    wind24=var_windn24.get()
    wind2Path=wind2PathD.get()
    
    pv_type=choix_pv.get()
    pv1=var_pvn1.get()
    pv2=var_pvn2.get()
    pv3=var_pvn3.get()
    pv4=var_pvn4.get()
    pvPath=pvPathD.get()
    
    C01=C01D.get()
    C02=C02D.get()
    C03=C03D.get()
    C04=C04D.get()
    C12=C12D.get()
    C13=C13D.get()
    C14=C14D.get()
    C23=C23D.get()
    C24=C24D.get()
    C34=C34D.get()
    
    fuel_cost_opt = fuel_cost.get()
    bus_shunt_opt = bus_shunt.get()
    bus_loads_opt = bus_loads.get()
    
    rate_choice=rate_choiceD.get()

    f=open("lib\config.psen", "w")
# Write probabilistic model data 
    f.write(str(MCS_num)+";"+str(N_1_opt)+";"+str(PV_opt)+";"+str(Wind1_opt)+";"+str(Wind2_opt)+";"+str(Load_opt)+";"+str(fuel_cost_opt)+";"+str(bus_shunt_opt)+";"+str(bus_loads_opt)+"\n")
    
# Write load probabilistic model data 
    if load_type == "Normal(mean, stdev)" :
        f.write('1;'+str(load1)+";"+str(load2)+';0')
    elif load_type == "Uniform(min, max)" :
        f.write('2;'+str(load1)+";"+str(load2)+';0')
    elif load_type == "Exponential(lambda, gamma)" :
        f.write('3;'+str(load1)+";"+str(load2)+';0')
    elif load_type == "Weibull(alpha, beta, gamma)" :
        f.write('4;'+str(load1)+";"+str(load2)+";"+str(load3)+';0')
    elif load_type == "TruncatedNormal(mean, stdev, min, max)" :
        f.write('5;'+str(load1)+";"+str(load2)+";"+str(load3)+";"+str(load4)+';0')
    elif load_type == "Value list (values, probabilities)" :
        f.write('6;'+str(load1)+";"+str(load2)+';0')
    elif load_type == 'Histogram (steps, probabilities)' :
        f.write('7;'+str(load1)+";"+str(load2)+';0')
    elif load_type== "PDF from file ()" :
        try :
            loadPath
        except NameError :
            fenetre2 = Tk()
            Label(fenetre2, text="ERROR\nNo file selected", fg="red", font=("Century Gothic",16)).pack(side=TOP, fill=BOTH, expand=YES)
        else :
            f.write('10;'+loadPath+';0')   
    elif load_type== "Time Serie from file (stepsize, number of points)" :
        try :
            loadPath
        except NameError :
            fenetre2 = Tk()
            Label(fenetre2, text="ERROR\nNo file selected", fg="red", font=("Century Gothic",16)).pack(side=TOP, fill=BOTH, expand=YES)
        else :
            f.write('20;'+loadPath+";"+str(load1)+";"+str(load2)+';0') 
    else :
        fenetre2 = Tk()
        Label(fenetre2, text="ERROR\nNo load model selected", fg="red", font=("Century Gothic",16)).pack(side=TOP, fill=BOTH, expand=YES)
    f.write("\n")
    
# Write wind 1 probabilistic model data 
    if wind11_type == "Normal(mean, stdev)" :
        f.write('1;'+str(wind11)+";"+str(wind12)+';0')
    elif wind11_type == "Uniform(min, max)" :
        f.write('2;'+str(wind11)+";"+str(wind12)+';0')
    elif wind11_type == "Exponential(lambda, gamma)" :
        f.write('3;'+str(wind11)+";"+str(wind12)+';0')
    elif wind11_type == "Weibull(alpha, beta, gamma)" :
        f.write('4;'+str(wind11)+";"+str(wind12)+";"+str(wind13)+';0')
    elif wind11_type == "TruncatedNormal(mean, stdev, min, max)" :
        f.write('5;'+str(wind11)+";"+str(wind12)+";"+str(wind13)+";"+str(wind14)+';0')
    elif wind11_type == "Value list (values, probabilities)" :
        f.write('6;'+str(wind11)+";"+str(wind12)+';0')
    elif wind11_type == 'Histogram (steps, probabilities)' :
        f.write('7;'+str(wind11)+";"+str(wind12)+';0')
    elif wind11_type== "PDF from file ()" :
        try :
            wind1Path
        except NameError :
            fenetre2 = Tk()
            Label(fenetre2, text="ERROR\nNo file selected", fg="red", font=("Century Gothic",16)).pack(side=TOP, fill=BOTH, expand=YES)
        else :
            f.write('10;'+wind1Path+';0')   
    elif wind11_type== "Time Serie from file (stepsize, number of points)" :
        try :
            wind1Path
        except NameError :
            fenetre2 = Tk()
            Label(fenetre2, text="ERROR\nNo file selected", fg="red", font=("Century Gothic",16)).pack(side=TOP, fill=BOTH, expand=YES)
        else :
            f.write('20;'+wind1Path+";"+str(wind11)+";"+str(wind12)+';0') 
    else :
        fenetre2 = Tk()
        Label(fenetre2, text="ERROR\nNo wind model selected", fg="red", font=("Century Gothic",16)).pack(side=TOP, fill=BOTH, expand=YES)
    f.write("\n")
    
# Write wind 2 probabilistic model data    
    if wind21_type == "Normal(mean, stdev)" :
        f.write('1;'+str(wind21)+";"+str(wind22)+';0')
    elif wind21_type == "Uniform(min, max)" :
        f.write('2;'+str(wind21)+";"+str(wind22)+';0')
    elif wind21_type == "Exponential(lambda, gamma)" :
        f.write('3;'+str(wind21)+";"+str(wind22)+';0')
    elif wind21_type == "Weibull(alpha, beta, gamma)" :
        f.write('4;'+str(wind21)+";"+str(wind22)+";"+str(wind23)+';0')
    elif wind21_type == "TruncatedNormal(mean, stdev, min, max)" :
        f.write('5;'+str(wind21)+";"+str(wind22)+";"+str(wind23)+";"+str(wind24)+';0')
    elif wind21_type == "Value list (values, probabilities)" :
        f.write('6;'+str(wind21)+";"+str(wind22)+';0')
    elif wind21_type == 'Histogram (steps, probabilities)' :
        f.write('7;'+str(wind21)+";"+str(wind22)+';0')
    elif wind21_type== "PDF from file ()" :
        try :
            wind2Path
        except NameError :
            fenetre2 = Tk()
            Label(fenetre2, text="ERROR\nNo file selected", fg="red", font=("Century Gothic",16)).pack(side=TOP, fill=BOTH, expand=YES)
        else :
            f.write('10;'+wind2Path+';0')   
    elif wind21_type== "Time Serie from file (stepsize, number of points)" :
        try :
            wind2Path
        except NameError :
            fenetre2 = Tk()
            Label(fenetre2, text="ERROR\nNo file selected", fg="red", font=("Century Gothic",16)).pack(side=TOP, fill=BOTH, expand=YES)
        else :
            f.write('20;'+wind2Path+";"+str(wind21)+";"+str(wind22)+';0') 
    else :
        fenetre2 = Tk()
        Label(fenetre2, text="ERROR\nNo wind 2 model selected", fg="red", font=("Century Gothic",16)).pack(side=TOP, fill=BOTH, expand=YES)
    f.write("\n")

# Write correlation probabilistic model data     
    f.write(str(C01)+";"+str(C02)+";"+str(C03)+";"+str(C04)+";"+str(C12)+";"+str(C13)+";"+str(C14)+";"+str(C23)+";"+str(C24)+";"+str(C34)+";0")
    f.write("\n") 

# Write pv probabilistic model data     
    if pv_type == "Normal(mean, stdev)" :
        f.write('1;'+str(pv1)+";"+str(pv2)+';0')
    elif pv_type == "Uniform(min, max)" :
        f.write('2;'+str(pv1)+";"+str(pv2)+';0')
    elif pv_type == "Exponential(lambda, gamma)" :
        f.write('3;'+str(pv1)+";"+str(pv2)+';0')
    elif pv_type == "Weibull(alpha, beta, gamma)" :
        f.write('4;'+str(pv1)+";"+str(pv2)+";"+str(pv3)+';0')
    elif pv_type == "TruncatedNormal(mean, stdev, min, max)" :
        f.write('5;'+str(pv1)+";"+str(pv2)+";"+str(pv3)+";"+str(pv4)+';0')
    elif pv_type == "Value list (values, probabilities)" :
        f.write('6;'+str(pv1)+";"+str(pv2)+';0')
    elif pv_type == 'Histogram (steps, probabilities)' :
        f.write('7;'+str(pv1)+";"+str(pv2)+';0')
    elif pv_type== "PDF from file ()" :
        try :
            pvPath
        except NameError :
            fenetre2 = Tk()
            champ_label = Label(fenetre2, text="ERROR\nNo file selected", fg="red", font=("Century Gothic",16))
            champ_label.pack(side=TOP, fill=BOTH, expand=YES)
        else :
            f.write('10;'+pvPath+';0')   
    elif pv_type== "Time Serie from file (stepsize, number of points)" :
        try :
            pvPath
        except NameError :
            fenetre2 = Tk()
            champ_label = Label(fenetre2, text="ERROR\nNo file selected", fg="red", font=("Century Gothic",16))
            champ_label.pack(side=TOP, fill=BOTH, expand=YES)
        else :
            f.write('20;'+pvPath+";"+str(pv1)+";"+str(pv2)+';0') 
    else :
        fenetre2 = Tk()
        champ_label = Label(fenetre2, text="ERROR\nNo wind model selected", fg="red", font=("Century Gothic",16))
        champ_label.pack(side=TOP, fill=BOTH, expand=YES)
    f.write("\n")

# Write OPF data model     
    f.write(str(fuel_cost_opt) +";"+ str(bus_shunt_opt) +";"+ str(bus_loads_opt)+";0\n")

# Write Imap rate choice     
    f.write(str(rate_choice)+";0\n")

    f.close()
    
    print 'Successfuly saved case data'

# launch_PSEN function is used to run PSSEWrapper code with the configuration in the GUI
def launch_PSEN():
    config_save() # Current configuration is fist saved
    PSEN_Path='PSEN/PSSEWrapper.py'
    subprocess.Popen([python_Path,PSEN_Path])

# launch_orange function is used to launch Orange with the model file
def launch_Orange():
    subprocess.Popen([python_Path,orange_Path,model_Path])

# browse_load is used to select a .CSV file with a 1D array of load measures
def browse_load() :
    global loadPath
    loadPath = tkFileDialog.askopenfilename(parent=fenetre,title='Open file for load data estimation',filetypes=[('CSV files', '.csv'),('All files', '.*')])
    loadPathD.set(loadPath)
    fenetre.update_idletasks() # updates the fields paths
    return loadPath

# browse_wind is used to select a .CSV file with a 1D array of wind measures    
def browse_wind1() :
    global wind1Path
    wind1Path = tkFileDialog.askopenfilename(parent=fenetre,title='Open file for wind 1 data estimation',filetypes=[('CSV files', '.csv'),('All files', '.*')])
    wind1PathD.set(wind1Path)
    fenetre.update_idletasks() # updates the fields paths
    return wind1Path
    
# browse_wind is used to select a .CSV file with a 1D array of wind measures    
def browse_wind2() :
    global wind2Path
    wind2Path = tkFileDialog.askopenfilename(parent=fenetre,title='Open file for wind 2 data estimation',filetypes=[('CSV files', '.csv'),('All files', '.*')])
    wind2PathD.set(wind2Path)
    fenetre.update_idletasks() # updates the fields paths
    return wind2Path

# browse_pv is used to select a .CSV file with a 1D array of PV measures    
def browse_pv() :
    global pvPath
    pvPath = tkFileDialog.askopenfilename(parent=fenetre,title='Open file for PV data estimation',filetypes=[('CSV files', '.csv'),('All files', '.*')])
    pvPathD.set(pvPath)
    fenetre.update_idletasks() # updates the fields paths
    return pvPath    

# continload function is a browsing window returning the path to the contingency CSV file
def continload () :
    global continpath
    continpath = tkFileDialog.askopenfilename(parent=fenetre,title='Open contingency file',filetypes=[('CSV files', '.csv'),('All files', '.*')])
    try :
        continpath
    except NameError :
        pass
    else : # Saves the path into a file for PSSEWrapper.py
        f=open("lib\contin.psen", "w")
        f.write(str(continpath)+";0\n")
        f.close()
    return continpath

# orangeload function is a browsing window returning the path to the orange model file OWS
def orangeload () :
    global model_Path
    model_Path = tkFileDialog.askopenfilename(parent=fenetre,title='Open orange file...',filetypes=[('Orange Widget Scripts', '.ows')])
    
def browse_PSSEfolder () :
    global PSSEfolder
    if os.path.exists("C:\Program Files\PTI\PSSE33\PSSBIN") == True : 
        path="C:\Program Files\PTI\PSSE33\PSSBIN"
    else : 
        path="C:"
    PSSEfolder = tkFileDialog.askdirectory(parent=fenPrefPC,title='Choose PSSE/PSSBIN folder', initialdir=path)
    return PSSEfolder
    
def browse_Python () :
    global python_Path
    if os.path.exists("C:\Python27") == True : 
        path="C:\Python27"
    else : 
        path="C:"
    python_Path =  tkFileDialog.askopenfilename(parent=fenetre,title='Choose python.exe',filetypes=[('Executables', '.exe'),('All files', '.*')], initialdir=path)
    return python_Path
    
def browse_Orange () :
    global orange_Path
    if os.path.exists("C:\Python27\Lib\site-packages\Orange\OrangeCanvas") == True : 
        path="C:\Python27\Lib\site-packages\Orange\OrangeCanvas"
    else : 
        path="C:"
    orange_Path = tkFileDialog.askopenfilename(parent=fenetre,title='Choose orngCanvas.pyw',filetypes=[('Python file', '.pyw'),('All files', '.*')], initialdir=path)
    return orange_Path
# On crée une fenêtre, racine de notre interface
def fenetre() :
    global fenetre,var_MCS,N_1,PV,Wind1,Wind2,Load,choix_load,var_loadn1,var_loadn2,var_loadn3,var_loadn4,loadPathD,choix_wind11,var_windn11,var_windn12,var_windn13,var_windn14,wind1PathD,choix_wind21,var_windn21,var_windn22,var_windn23,var_windn24,wind2PathD,choix_pv,var_pvn1,var_pvn2,var_pvn3,var_pvn4,pvPathD,C01D,C02D,C03D,C04D,C12D,C13D,C14D,C23D,C24D,C34D,fuel_cost,bus_shunt,bus_loads,rate_choiceD
    fenetre = Toplevel(root)
    fenetre.wm_iconbitmap('lib\PSEN.ico')
    fenetre.wm_title('PSEN - Probabilistic Studies of Electrical Networks')
    
    def openshort (event):
        openPSEN()
    def saveshort (event) : 
        savePSEN()
    def quitshort (event) : 
        fenetre.destroy()
    def orangeshort (event):
        launch_Orange()
    def runshort (event) : 
        launch_PSEN()
    def prefshort (event) : 
        preferences()    
    
    fenetre.bind_all("<Control-q>", quitshort)
    fenetre.bind_all("<Control-o>", openshort)
    fenetre.bind_all("<Control-s>", saveshort)
    fenetre.bind_all("<Control-a>", orangeshort)
    fenetre.bind_all("<Control-r>", runshort)
    fenetre.bind_all("<Control-p>", prefshort)    
    
    wd=500
    
    # Create a toplevel menu
    menubar=Menu(fenetre)
    
    filemenu = Menu(menubar, tearoff=0)
    filemenu.add_command(label="Open PSEN", command=openPSEN, accelerator="Ctrl+O")
    filemenu.add_command(label="Save PSEN", command=savePSEN, accelerator="Ctrl+S")
    filemenu.add_separator() 
    filemenu.add_command(label="Exit", command=fenetre.quit, accelerator="Ctrl+Q")
    menubar.add_cascade(label="File", menu=filemenu)
    
    editmenu = Menu(menubar, tearoff=0)
    editmenu.add_command(label="Computer preferences", command=PCpreferences)
    editmenu.add_separator() 
    editmenu.add_command(label="Study preferences", command=preferences, accelerator="Ctrl+P")
    menubar.add_cascade(label="Edit", menu=editmenu)
    
    exemenu = Menu(menubar, tearoff=0)
    exemenu.add_command(label="Run PSEN", command=preferences, accelerator="Ctrl+R")
    menubar.add_cascade(label="Execution", menu=exemenu)
    
    contmenu = Menu(menubar, tearoff=0)
    contmenu.add_command(label="Load contingency file", command=ContinPreferences)
    menubar.add_cascade(label="Contingency analysis", menu=contmenu)
    
    orangemenu = Menu(menubar, tearoff=0)
    orangemenu.add_command(label="Choose Orange model", command=orangeload)
    orangemenu.add_command(label="Open Orange", command=launch_Orange, accelerator="Ctrl+A")
    menubar.add_cascade(label="Orange analysis", menu=orangemenu)
    
    viewmenu = Menu(menubar, tearoff=0)
    viewmenu.add_command(label="Show/Hide cmd window", command=set_attached_console_visible)
    menubar.add_cascade(label="View", menu=viewmenu)
    
    # Display the menu
    fenetre.config(menu=menubar)
    
    ftop=Frame(fenetre, height=140, width=2*wd, bd=2, relief=RIDGE)
    ftop.pack_propagate(0) # don't shrink
    ftop.pack()
    
    fmid=Frame(fenetre, height=500, width=2*wd)
    fmid.pack_propagate(0) # don't shrink
    fmid.pack()
    
    fleft=Frame(fmid, height=500, width=wd, bd=2, relief=RIDGE)
    fleft.pack_propagate(0) # don't shrink
    fleft.pack(side=LEFT)
    
    fright=Frame(fmid, height=500, width=wd, bd=2, relief=RIDGE)
    fright.pack_propagate(0) # don't shrink
    fright.pack(side=RIGHT)
    
    #canvas=Canvas(fenetre, width=600, height=100, bg='ivory')
    Label(ftop, image=header).pack(side=TOP, fill=BOTH, expand=YES)
    #canvas.pack(side=TOP,padx=5,pady=5)

    fline=Frame(ftop, height=2, width=2*wd, bg="grey")
    fline.pack_propagate(0) # don't shrink
    fline.pack(expand=1)
    
    fl0=Frame(fleft, height=55, width=wd)
    fl0.pack_propagate(0) # don't shrink
    fl0.pack()
    
    Label(fl0, text="Simulation parameters", fg="black", justify=LEFT, font=("Century Gothic",14)).pack(anchor=NW, padx=10, expand=NO)
    
    # Change Monte Carlo samplings
    Label(fl0, text="Choose the number of samples:", fg="black").pack(side=LEFT, padx=10, expand=NO)
    
    var_MCS = StringVar()
    Entry(fl0, textvariable=var_MCS, width=15).pack(side=LEFT, padx=15, expand=NO)
    
    fl01=Frame(fleft, height=30, width=wd)
    fl01.pack_propagate(0) # don't shrink
    fl01.pack()
    
    # Change N-1 study or not
    N_1 = IntVar()
    Checkbutton(fl01, text="N-1 study ?", variable=N_1).pack(side=LEFT, padx=2)
    
    # Include Load ?
    Load = IntVar()
    Checkbutton(fl01, text="Load study ?", variable=Load).pack(side=LEFT, padx=2)
    
    # Include Wind 1 ?
    Wind1 = IntVar()
    Checkbutton(fl01, text="Wind 1 study ?", variable=Wind1).pack(side=LEFT, padx=2)
    
    # Include Wind 2 ?
    Wind2 = IntVar()
    Checkbutton(fl01, text="Wind 2 study ?", variable=Wind2).pack(side=LEFT, padx=2)
    
    # Include PV
    PV = IntVar()
    Checkbutton(fl01, text="PV study ?", variable=PV).pack(side=LEFT, padx=2)
    
    Frame(fleft, height=2, width=wd, bg="grey").pack(pady=10, expand=NO)
    
    fl1=Frame(fleft, height=152, width=wd)
    fl1.pack_propagate(0) # don't shrink
    fl1.pack(pady=0, expand=NO)
    
    champ_label = Label(fl1, text="Correlation upper matrix :", fg="black", justify=LEFT, font=("Century Gothic",14))
    champ_label.pack(anchor=NW, padx=10, expand=NO)
    
    champ_label = Label(fl1, text="Load                         N-1                    Wind1               Wind2                 Solar           ", fg="black")
    champ_label.pack(anchor=NE, padx=10)
    
    fl11=Frame(fl1, height=25, width=wd)
    fl11.pack_propagate(0) # don't shrink
    fl11.pack(padx=10, expand=NO)
    C04D = StringVar()
    Entry(fl11, textvariable=C04D, width=10).pack(side=RIGHT, padx=10, pady=5)
    C04D.set(0)
    C03D = StringVar()
    Entry(fl11, textvariable=C03D, width=10).pack(side=RIGHT, padx=10, pady=5)
    C03D.set(0)
    C02D = StringVar()
    Entry(fl11, textvariable=C02D, width=10).pack(side=RIGHT, padx=10, pady=5)
    C02D.set(0)
    C01D = StringVar()
    Entry(fl11, textvariable=C01D, width=10).pack(side=RIGHT, padx=10, pady=5)
    C01D.set(0)
    
    champ_label = Label(fl11, text="Load     ", fg="black")
    champ_label.pack(side=RIGHT, padx=10)
    
    fl12=Frame(fl1, height=25, width=wd)
    fl12.pack_propagate(0) # don't shrink
    fl12.pack(padx=10, expand=NO)
    C14D = StringVar()
    Entry(fl12, textvariable=C14D, width=10).pack(side=RIGHT, padx=10, pady=5)
    C14D.set(0)
    C13D = StringVar()
    Entry(fl12, textvariable=C13D, width=10).pack(side=RIGHT, padx=10, pady=5)
    C13D.set(0)
    C12D = StringVar()
    Entry(fl12, textvariable=C12D, width=10).pack(side=RIGHT, padx=10, pady=5)
    C12D.set(0)
    
    champ_label = Label(fl12, text="N-1    ", fg="black")
    champ_label.pack(side=RIGHT, padx=10)
    
    fl13=Frame(fl1, height=25, width=wd)
    fl13.pack_propagate(0) # don't shrink
    fl13.pack(padx=10, expand=NO)
    C24D = StringVar()
    Entry(fl13, textvariable=C24D, width=10).pack(side=RIGHT, padx=10, pady=5)
    C24D.set(0)
    C23D = StringVar()
    Entry(fl13, textvariable=C23D, width=10).pack(side=RIGHT, padx=10, pady=5)
    C23D.set(0)
    
    champ_label = Label(fl13, text="Wind1    ", fg="black")
    champ_label.pack(side=RIGHT, padx=10)
    
    fl14=Frame(fl1, height=25, width=wd)
    fl14.pack_propagate(0) # don't shrink
    fl14.pack(padx=10, expand=NO)
    C34D = StringVar()
    Entry(fl14, textvariable=C34D, width=10).pack(side=RIGHT, padx=10, pady=5)
    C34D.set(0)
    
    champ_label = Label(fl14, text="Wind2      ", fg="black")
    champ_label.pack(side=RIGHT, padx=10)
    
    fline=Frame(fleft, height=2, width=wd, bg="grey")
    fline.pack(pady=10, expand=NO)
    
    fl2=Frame(fleft, height=20, width=wd)
    fl2.pack_propagate(0) # don't shrink
    fl2.pack()
    
    champ_label = Label(fl2, text="PSSe OPF parameters", fg="black", justify=LEFT, font=("Century Gothic",14))
    champ_label.pack(anchor=NW, padx=10, expand=NO)
    
    fl21=Frame(fleft, height=30, width=wd)
    fl21.pack_propagate(0) # don't shrink
    fl21.pack()
    
    # "Minimize fuel cost"
    fuel_cost = IntVar()
    Checkbutton(fl21, text="Minimize fuel cost", variable=fuel_cost).pack(side=LEFT, padx=10)
    
    # "Minimize adj. bus shunts"
    bus_shunt = IntVar()
    Checkbutton(fl21, text="Minimize adj. bus shunts", variable=bus_shunt).pack(side=LEFT, padx=10)
    
    # "Minimize adj. bus loads"
    bus_loads = IntVar()
    Checkbutton(fl21, text="Minimize adj. bus loads", variable=bus_loads).pack(side=LEFT, padx=10)
    
    fline=Frame(fleft, height=2, width=wd, bg="grey")
    fline.pack(pady=10, expand=NO)
    
    fl3=Frame(fleft, height=20, width=wd)
    fl3.pack_propagate(0) # don't shrink
    fl3.pack()
    
    champ_label = Label(fl3, text="PSSe Irate choice :", fg="black", justify=LEFT, font=("Century Gothic",14))
    champ_label.pack(side=LEFT, padx=10, expand=NO)

    # "Minimize fuel cost"
    rate_choiceD = IntVar()
    Radiobutton(fl3, text="Rate A", variable=rate_choiceD, value=1).pack(side=LEFT, padx=20)
    Radiobutton(fl3, text="Rate B", variable=rate_choiceD, value=2).pack(side=LEFT, padx=10)
    Radiobutton(fl3, text="Rate C", variable=rate_choiceD, value=3).pack(side=LEFT, padx=10)
    
#---- Choose the probability laws ---
    #---- Load model ----
    fr0=Frame(fright, height=55, width=wd)
    fr0.pack_propagate(0) # don't shrink
    fr0.pack(expand=NO, anchor=NW)
    
    champ_label = Label(fr0, text="Load model :", fg="black", justify=LEFT, font=("Century Gothic",14))
    champ_label.pack(anchor=NW, padx=10, expand=NO)
    
    choix_load=StringVar()
    laws_choice = ('Normal(mean, stdev)','Uniform(min, max)','Exponential(lambda, gamma)','Weibull(alpha, beta, gamma)', 'TruncatedNormal(mean, stdev, min, max)', 'Value list (values, probabilities)', 'Histogram (steps, probabilities)', 'PDF from file ()', 'Time Serie from file (stepsize, number of points)' )
    Combobox(fr0, textvariable = choix_load, values = laws_choice, state = 'readonly', width=50).pack(side=LEFT, padx=10, expand=NO)
    choix_load.set('Choose your load model')
    
    fr01=Frame(fright, height=30, width=wd)
    fr01.pack_propagate(0) # don't shrink
    fr01.pack(expand=NO)
    champ_label = Label(fr01, text="Parameters :", fg="black").pack(side=LEFT, padx=10, pady=0)
    
    var_loadn1 = StringVar()
    Entry(fr01, textvariable=var_loadn1, width=12).pack(side=LEFT, padx=10, pady=5)
    var_loadn2 = StringVar()
    Entry(fr01, textvariable=var_loadn2, width=12).pack(side=LEFT, padx=10, pady=5)
    var_loadn3 = StringVar()
    Entry(fr01, textvariable=var_loadn3, width=12).pack(side=LEFT, padx=10, pady=5)
    var_loadn4 = StringVar()
    Entry(fr01, textvariable=var_loadn4, width=12).pack(side=LEFT, padx=10, pady=5)
    
    fr011=Frame(fright, height=35, width=wd)
    fr011.pack_propagate(0) # don't shrink
    fr011.pack(expand=NO)
    
    # We create the browse button
    loadPathD=StringVar()
    Entry(fr011, textvariable=loadPathD, width=50).pack(side=LEFT, padx=15, expand=YES)
    
    Button(fr011, text="Load data", command=browse_load).pack(side=LEFT, fill=BOTH, expand=1, padx=5, pady=3)
    
    fline=Frame(fright, height=2, width=wd, bg="grey")
    fline.pack(pady=2, expand=NO)
    
    #---- Wind 1 model ----
    fr1=Frame(fright, height=55, width=wd)
    fr1.pack_propagate(0) # don't shrink
    fr1.pack(expand=NO, pady=0)
    
    champ_label = Label(fr1, text="Wind 1 distribution model :", fg="black", justify=LEFT, font=("Century Gothic",14))
    champ_label.pack(anchor=NW, padx=10, expand=NO)
    
    choix_wind11=StringVar()
    laws_choice = ('Normal(mean, stdev)','Uniform(min, max)','Exponential(lambda, gamma)','Weibull(alpha, beta, gamma)', 'TruncatedNormal(mean, stdev, min, max)', 'Value list (values, probabilities)', 'Histogram (steps, probabilities)', 'PDF from file ()', 'Time Serie from file (stepsize, number of points)' )
    Combobox(fr1, textvariable = choix_wind11, values = laws_choice, state = 'readonly', width=50).pack(side=LEFT, padx=10, expand=NO)
    choix_wind11.set('Choose your wind model')
    
    fr11=Frame(fright, height=30, width=wd)
    fr11.pack_propagate(0) # don't shrink
    fr11.pack(expand=NO)
    Label(fr11, text="Parameters :", fg="black").pack(side=LEFT, padx=10, pady=0)
    
    var_windn11 = StringVar()
    Entry(fr11, textvariable=var_windn11, width=12).pack(side=LEFT, padx=10, pady=5)
    var_windn12 = StringVar()
    Entry(fr11, textvariable=var_windn12, width=12).pack(side=LEFT, padx=10, pady=5)
    var_windn13 = StringVar()
    Entry(fr11, textvariable=var_windn13, width=12).pack(side=LEFT, padx=10, pady=5)
    var_windn14 = StringVar()
    Entry(fr11, textvariable=var_windn14, width=12).pack(side=LEFT, padx=10, pady=5)
    
    fr111=Frame(fright, height=35, width=wd)
    fr111.pack_propagate(0) # don't shrink
    fr111.pack(expand=NO)
    
    # We create the browse button
    wind1PathD=StringVar()
    Entry(fr111, textvariable=wind1PathD, width=50).pack(side=LEFT, padx=15, expand=YES)
    
    Button(fr111, text="Wind 1 data", command=browse_wind1).pack(side=LEFT, fill=BOTH, expand=1, padx=5, pady=3)
    
    fline=Frame(fright, height=2, width=wd, bg="grey")
    fline.pack(pady=2, expand=NO)
    
    #---- Wind 2 model ----
    fr2=Frame(fright, height=55, width=wd)
    fr2.pack_propagate(0) # don't shrink
    fr2.pack(expand=NO, pady=0)
    
    champ_label = Label(fr2, text="Wind 2 distribution model :", fg="black", justify=LEFT, font=("Century Gothic",14))
    champ_label.pack(anchor=NW, padx=10, expand=NO)
    
    choix_wind21=StringVar()
    laws_choice = ('Normal(mean, stdev)','Uniform(min, max)','Exponential(lambda, gamma)','Weibull(alpha, beta, gamma)', 'TruncatedNormal(mean, stdev, min, max)', 'Value list (values, probabilities)', 'Histogram (steps, probabilities)', 'PDF from file ()', 'Time Serie from file (stepsize, number of points)' )
    Combobox(fr2, textvariable = choix_wind21, values = laws_choice, state = 'readonly', width=50).pack(side=LEFT, padx=10, expand=NO)
    choix_wind21.set('Choose your wind model')
    
    fr21=Frame(fright, height=30, width=wd)
    fr21.pack_propagate(0) # don't shrink
    fr21.pack(expand=NO)
    Label(fr21, text="Parameters :", fg="black").pack(side=LEFT, padx=10, pady=0)
    
    var_windn21 = StringVar()
    Entry(fr21, textvariable=var_windn21, width=12).pack(side=LEFT, padx=10, pady=5)
    var_windn22 = StringVar()
    Entry(fr21, textvariable=var_windn22, width=12).pack(side=LEFT, padx=10, pady=5)
    var_windn23 = StringVar()
    Entry(fr21, textvariable=var_windn23, width=12).pack(side=LEFT, padx=10, pady=5)
    var_windn24 = StringVar()
    Entry(fr21, textvariable=var_windn24, width=12).pack(side=LEFT, padx=10, pady=5)
    
    fr211=Frame(fright, height=35, width=wd)
    fr211.pack_propagate(0) # don't shrink
    fr211.pack(expand=NO)
    
    # We create the browse button
    wind2PathD=StringVar()
    Entry(fr211, textvariable=wind2PathD, width=50).pack(side=LEFT, padx=15, expand=YES)
    
    Button(fr211, text="Wind 2 data", command=browse_wind2).pack(side=LEFT, fill=BOTH, expand=1, padx=5, pady=3)
    
    fline=Frame(fright, height=2, width=wd, bg="grey")
    fline.pack(pady=2, expand=NO)
    
    #---- PV model ----    
    fr3=Frame(fright, height=55, width=wd)
    fr3.pack_propagate(0) # don't shrink
    fr3.pack(expand=NO, pady=0)
    
    champ_label = Label(fr3, text="Photovoltaic distribution model :", fg="black", justify=LEFT, font=("Century Gothic",14))
    champ_label.pack(anchor=NW, padx=10, expand=NO)
    
    choix_pv=StringVar()
    laws_choice = ('Normal(mean, stdev)','Uniform(min, max)','Exponential(lambda, gamma)','Weibull(alpha, beta, gamma)', 'TruncatedNormal(mean, stdev, min, max)', 'Value list (values, probabilities)', 'Histogram (steps, probabilities)', 'PDF from file ()', 'Time Serie from file (stepsize, number of points)' )
    Combobox(fr3, textvariable = choix_pv, values = laws_choice, state = 'readonly', width=50).pack(side=LEFT, padx=10, expand=NO)
    choix_pv.set('Choose your PV model')
    
    fr31=Frame(fright, height=30, width=wd)
    fr31.pack_propagate(0) # don't shrink
    fr31.pack(expand=NO)
    Label(fr31, text="Parameters :", fg="black").pack(side=LEFT, padx=10, pady=0)
    
    var_pvn1 = StringVar()
    Entry(fr31, textvariable=var_pvn1, width=12).pack(side=LEFT, padx=10, pady=5)
    var_pvn2 = StringVar()
    Entry(fr31, textvariable=var_pvn2, width=12).pack(side=LEFT, padx=10, pady=5)
    var_pvn3 = StringVar()
    Entry(fr31, textvariable=var_pvn3, width=12).pack(side=LEFT, padx=10, pady=5)
    var_pvn4 = StringVar()
    Entry(fr31, textvariable=var_pvn4, width=12).pack(side=LEFT, padx=10, pady=5)
    
    fr311=Frame(fright, height=35, width=wd)
    fr311.pack_propagate(0) # don't shrink
    fr311.pack(expand=NO)
    
    # We create the browse button
    pvPathD=StringVar()
    Entry(fr311, textvariable=pvPathD, width=50).pack(side=LEFT, padx=15, expand=YES)
    
    Button(fr311, text="PV data", command=browse_pv).pack(side=LEFT, fill=BOTH, expand=1, padx=5, pady=3)
    
    fb=Frame(fenetre, height=50, width=2*wd, bd=2, relief=RIDGE)
    fb.pack_propagate(0) # don't shrink
    fb.pack()
    
    Frame(fb, height=2, width=2*wd, bg="grey").pack(expand=1)
    
    # We create the launch button
    Button(fb, text="Run PSEN", command=launch_PSEN, height=1, width=20, underline=YES).pack(expand=NO, padx=5, pady=3)
    
# On démarre la boucle Tkinter qui s'interompt quand on ferme la fenêtre
fenetre()
root.mainloop()