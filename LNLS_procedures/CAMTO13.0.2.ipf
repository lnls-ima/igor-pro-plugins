// Code for Analysis of Multipoles, Trajectories and Others.
// Last Upgrade: 14/06/2018

#pragma rtGlobals = 1	
#pragma version = 13.0.2


Menu "CAMTO"
	"Initialize CAMTO", Execute "Initialize_CAMTO()"
	"Global Parameters", Execute "Global_Parameters()"
	"Field Specification", Execute "Field_Specification()"
	"Load Field Data", Execute "Load_Field_Data()"
	"Hall Probe Correction", Execute "Hall_Probe_Error_Correction()"
	"Integrals and Multipoles", Execute "Integrals_Multipoles()"
	"Particle Energy", Execute "Particle_Energy()"
	"Trajectories", Execute "Trajectories()"
	"Dynamic Multipoles", Execute "Dynamic_Multipoles()"
	"Find Peaks and Zeros", Execute "Find_Peaks()"
	"Phase Error", Execute "Phase_Error()"
	"Results", Execute "Results()"
	"Compare Results", Execute "Compare_Results()"
	"Insertion Devices Results", Execute "ID_Results()"
	"Load Line Scan", Execute "Load_Line_Scan()"
	"Help", Execute "Help()"
End


Function Help()
string TopicStr

	PathInfo Igor
	newpath/O/Q IgorUtiPath, S_path +"Igor Help Files"

	string HelpNotebookName = "CAMTO_Help.ihf"
	opennotebook/Z/R/P=IgorUtiPath/N=CAMTOHelpNotebook HelpNotebookName
	
	Header()
End


Function Header()
	Print(" ")
	Print("CAMTO - Code for Analysis of Multipoles, Trajectories and Others.")
	Print("Version 13.0.2")
	Print("Last Upgrade: June, 14th 2018")	
	Print("Creator: James Citadini")	
	Print("Co-Creators: Giancarlo Tosin, Priscila Palma Sanchez, Tiago Reis and Luana Vilela")
	Print("Acknowlegments to: Ximenes Rocha Resende and Liu Lin")
	Print("Brazilian Synchrotron Light Laboratory - LNLS")	
End


Function Initialize_CAMTO()

	if (DataFolderExists("root:varsCAMTO"))
		DoAlert 1, "Restart CAMTO?"
		if (V_flag == 2)
			return -1
		endif 
	endif

	Header()
	
	SetDataFolder root:
	
	KillAllTheWaves()
	KillFieldMapDirs()

	KillDataFolder/Z wavesCAMTO
	NewDataFolder/O wavesCAMTO
	
	KillDataFolder/Z varsCAMTO
	NewDataFolder/O varsCAMTO
       
   KillDataFolder/Z root:Nominal
          
	SetDataFolder root:varsCAMTO:
       
	Killvariables/A/Z
	KillStrings/A/Z
	
	string/G CAMTOVersion = "13.0.2"
		
	variable/G aux0
	variable/G aux1
	variable/G aux2
	variable/G aux3
	variable/G aux4	
	
	variable/G Charge = -1.602177E-19
	variable/G Mass = 9.109389E-31
	variable/G LightSpeed = 2.99792458E+08
	variable/G EnergyGev = 3.0
	variable/G TrajShift = 0.00001
	
	variable/G FieldMapCount = 0
	string/G   FieldMapDir
	string/G   FieldMapCopy
	string/G   NewFieldMap = "FieldMap"
	
	string/G FieldMapA
	string/G FieldMapB
	variable/G ReferenceFieldMap = 1

	variable/G LinePosX = 0

	variable/G ProfileStartX = 0
	variable/G ProfileEndX = 0
	variable/G ProfilePosYZ = 0
	
	variable/G MultipoleK = 0	
	variable/G DynMultipoleK = 0

	variable/G AddReferenceLines = 0	
	variable/G CheckDynMultipoles = 0
	variable/G CheckMultTwo = 0

	variable/G DistCenter = 0
	variable/G MainK = 0
	variable/G MainSkew = 1
		
	variable/G NrMultipoles = 1
	variable/G PrevNrMultipoles = 1
	variable/G NrSkewMultipoles = 0
	variable/G PrevNrSkewMultipoles = 0
	variable/G NrMultipoleErrors = 10
	variable/G PrevNrMultipoleErrors = 10
	
	SetDataFolder root:wavesCAMTO:
	
	Make/T FieldMapDirs
	Make/D EnergiesGeV
	Make/D/N=(1, 2) NormalMultipoles
	Make/D/N=(0, 2) SkewMultipoles
	Make/D/N=(10,5) MultipoleErrors
	
	SetDataFolder root:
End


Function InitializeFieldMapVariables()
	
	SVAR df = root:varsCAMTO:FieldMapDir 
	SetDataFolder root:$df	
	
	Killvariables/A/Z
	KillStrings/A/Z
	KillWaves/A/Z
	
	KillDataFolder/Z varsFieldMap
	NewDataFolder/O/S  varsFieldMap
       
	Killvariables/A/Z
	KillStrings/A/Z
	
	//Symmetries: 1 is none, 2 is even, 3 is odd
	variable/G SymmetryBxX = 1
	variable/G SymmetryBxY = 2
	variable/G SymmetryBxZ = 2
	variable/G SymmetryByX = 1
	variable/G SymmetryByY = 3
	variable/G SymmetryByZ = 2
	variable/G SymmetryBzX = 1
	variable/G SymmetryBzY = 2
	variable/G SymmetryBzZ = 3
	
	variable/G SymmetryAlongYZ = 2 //1 is true, 2 is false
	variable/G OtherSymmetryPlanes = 1
	variable/G Plane1Angle = 1
	variable/G Plane1Condition = 1 //Condition 1 is normal, 2 is tangential
	variable/G Plane2Angle = 1 //Angles, in degrees: 30, 45, 90
	variable/G Plane2Condition = 1
	
	variable/G SymmetryX = 1
	variable/G SymmetryY = 1
	variable/G SymmetryZ = 1
	variable/G SymmetryYZ = 1	
	
	variable/G BeamDirection = 2
	variable/G StaticTransient = 1

	variable/G StartX = 0
	variable/G EndX = 0
	variable/G StepsX = 1
	variable/G NPointsX = 1	

	variable/G StartY = 0
	variable/G EndY = 0
	variable/G StepsY = 1
	variable/G NPointsY = 1	
	
	variable/G StartZ = 0
	variable/G EndZ = 0
	variable/G StepsZ = 1
	variable/G NPointsZ = 1		

	variable/G StartYZ = 0
	variable/G EndYZ = 0
	variable/G StepsYZ = 1
	variable/G NPointsYZ = 1		
	
	variable/G StartXTraj = 0
	variable/G EndXTraj = 0
	variable/G StepsXTraj = 1
	variable/G NPointsXTraj = 1		
	
	variable/G StartYZTraj = 0	
	variable/G EndYZTraj = 0	

	variable/G FieldX
	variable/G FieldY	
	variable/G FieldZ
	
	variable/G FittingOrder = 15
	variable/G Distcenter = 10
	variable/G GridMin 
	variable/G GridMax 
	variable/G KNorm = 1
	variable/G NormComponent = 1
	string/G   NormalCoefs = "000000000000000"
	string/G   SkewCoefs = "000000000000000"
	string/G   ResNormalCoefs = "000000000000000"
	string/G   ResSkewCoefs = "000000000000000"
	
	variable/G FittingOrderTraj = 15
	variable/G DistcenterTraj = 10
	variable/G GridMinTraj = -10
	variable/G GridMaxTraj = 10
	variable/G GridNrptsTraj = 101
	variable/G MultipolesTrajShift = 0.001 
	variable/G DynKNorm = 1
	variable/G DynNormComponent = 1
	string/G   DynNormalCoefs = "000000000000000"
	string/G   DynSkewCoefs = "000000000000000"
	string/G 	 DynResNormalCoefs = "000000000000000"
	string/G 	 DynResSkewCoefs = "000000000000000"

	variable/G MultipoleK = 0
	variable/G DynMultipoleK = 0
			
	variable/G PosLongitudinal = 0 	            
	variable/G PosTransversal = 0
	variable/G EntranceAngle = 0	
	
	variable/G Single_Multi = 1		
	
	variable/G iTraj
	variable/G iTrajError

	variable/G iX = 0
	variable/G iYZ = 0

	variable/G Checkfield = 1
	variable/G CheckNegPosTraj = 0
	
	variable/G Out_of_Matrix_Error = 0
	
	variable/G PosXAux = 0
	variable/G PosYZAux = 0		

	variable/G FieldXAux = 0
	variable/G FieldYAux = 0
	variable/G FieldZAux = 0			

	variable/G StartXHom = 0
	variable/G EndXHom = 0
	variable/G PosYZHom = 0	

	variable/G HomogX = 0
	variable/G HomogY = 0
	variable/G HomogZ = 0	
	
	variable/G ErrAngXZ = 0 // 1.265	
	variable/G ErrAngYZ = 0 // 0.3937
	variable/G ErrAngXY = 0
	variable/G ErrAng = 0	
	
	variable/G ErrDisplacementX = 0
	variable/G ErrDisplacementYZ = 0
	variable/G ErrDisplacement = 0	
	
	variable/G Analitico_RungeKutta = 2
	
	variable/G GraphAppend = 1
	variable/G AddReferenceLines = 0

	string/G   FieldAxisPeakStr = "By"
	variable/G FieldAxisPeak = 2
	variable/G PeaksPosNeg = 3 
	variable/G NAmplPeaks = 5
	variable/G NAmplZeros = 5
	variable/G StepsYZPeaks = 1
	variable/G AvgPeriodPeaks = 0
	variable/G AvgPeriodZeros = 0
	variable/G PeaksSelected = 0

	variable/G SemiPeriodsPeaksZeros = 2	
	variable/G PeriodPeaksZerosNominal = 1
	variable/G IDPeriodNominal = 0
	variable/G IDPeriod = 0
	variable/G IDCutPeriods = 0
	variable/G IDPhaseError = inf
	
	variable/G IDFirstIntegral = inf
	variable/G IDSecondIntegral = inf
	
	string/G FMFilename = ""
	string/G FMPath = ""
		
	SetDataFolder root:$df	

	Make/T HeaderLines
End


Function KillAllTheWaves()
 
  string graphs=WinList("*",";","WIN:4183")
  variable i,j
  for(i=0;i<itemsinlist(graphs);i+=1)
    string graph=stringfromlist(i,graphs)
    KillWindow $graph
  endfor
  
  SetDataFolder root:
  KillWaves/A/Z

End


Function KillFieldMapDirs()

	Wave/T  FieldMapDirs  = root:wavesCAMTO:FieldMapDirs
	
	if (WaveExists(FieldMapDirs)!=0)
		UpdateFieldMapDirs()
		
		variable i
		for(i=0; i<numpnts(FieldMapDirs); i=i+1)
			KillDataFolder/Z $(FieldMapDirs[i])
		endfor
		
	endif

End


Window Global_Parameters() : Panel
	PauseUpdate; Silent 1		// building window...
	
	if (DataFolderExists("root:varsCAMTO")==0)
		DoAlert 1, "CAMTO variables not found. Initialize CAMTO?"
		if (V_flag == 1)
			Initialize_CAMTO()
		else
			return
		endif 
	endif
	
	//Procura Janela e se estiver aberta, fecha antes de abrir novamente.
	string PanelName
	PanelName = WinList("Global_Parameters",";","")	
	if (stringmatch(PanelName, "Global_Parameters;"))
		Killwindow Global_Parameters
	endif	
	
	NewPanel/K=1/W=(80,60,404,266)
	SetDrawLayer UserBack
	SetDrawEnv fillpat= 0
	DrawRect 5,3,318,166
	SetDrawEnv fillpat= 0
	DrawRect 5,166,318,200
	SetDrawEnv fillpat= 0
	DrawRect 5,38,318,166
	
	
	Button ParTraj,pos={175,171},size={100,26},proc=continue_ElecPar,title="change"
	Button ParTraj,fSize=15,fStyle=1
	TitleBox title3,pos={75,9},size={161,24},title="Global Parameters",fSize=18,fStyle=1
	TitleBox title3,frame=0
	
	variable/G root:varsCAMTO:aux0 = root:varsCAMTO:EnergyGev
	variable/G root:varsCAMTO:aux1 = root:varsCAMTO:Charge
	variable/G root:varsCAMTO:aux2 = root:varsCAMTO:Mass
	variable/G root:varsCAMTO:aux3 = root:varsCAMTO:LightSpeed
	variable/G root:varsCAMTO:aux4 = root:varsCAMTO:TrajShift
	
	SetVariable Lenergiagev,pos={13,44},size={207,16},title="Particle Energy (GeV)"
	SetVariable Lenergiagev,value= root:varsCAMTO:aux0
	SetVariable LCarga,pos={14,68},size={207,16},title="Particle Charge (c)"
	SetVariable LCarga,value= root:varsCAMTO:aux1
	SetVariable LMassaKg,pos={14,92},size={207,16},title="Mass (kg)",value= root:varsCAMTO:aux2
	SetVariable LVelLuz,pos={14,116},size={207,16},title="Speed of light (m/s)"
	SetVariable LVelLuz,value= root:varsCAMTO:aux3
	SetVariable LDeslocamento,pos={14,140},size={207,16},title="Displacement (m)"
	SetVariable LDeslocamento,value= root:varsCAMTO:aux4

	Button ParTraj_quit,pos={44,171},size={100,26},proc=quit_ElecPar,title="quit"
	Button ParTraj_quit,fSize=15,fStyle=1

	ValDisplay valdispEnergy,pos={224,44},size={87,14}
	ValDisplay valdispEnergy,limits={0,0,0},barmisc={0,1000},mode= 5
	ValDisplay valdispEnergy,value= #"root:varsCAMTO:EnergyGev"
	ValDisplay valdispCharge,pos={224,68},size={87,14}
	ValDisplay valdispCharge,limits={0,0,0},barmisc={0,1000},mode= 5
	ValDisplay valdispCharge,value= #"root:varsCAMTO:Charge"
	ValDisplay valdispMass,pos={224,92},size={87,14}
	ValDisplay valdispMass,limits={0,0,0},barmisc={0,1000},mode= 5
	ValDisplay valdispMass,value= #"root:varsCAMTO:Mass"
	ValDisplay valdispLightSpeed,pos={224,116},size={87,14}
	ValDisplay valdispLightSpeed,limits={0,0,0},barmisc={0,1000},mode= 5
	ValDisplay valdispLightSpeed,value= #"root:varsCAMTO:LightSpeed"
	ValDisplay valdispShift,pos={224,140},size={87,14}
	ValDisplay valdispShift,limits={0,0,0},barmisc={0,1000},mode= 5
	ValDisplay valdispShift,value= #"root:varsCAMTO:TrajShift"
EndMacro


Function quit_ElecPar(ctrlName) : ButtonControl
	String ctrlName
	Killwindow Global_Parameters
End


Function continue_ElecPar(ctrlName) : ButtonControl
	String ctrlName

	NVAR aux0 = root:varsCAMTO:aux0
	NVAR aux1 = root:varsCAMTO:aux1
	NVAR aux2 = root:varsCAMTO:aux2
	NVAR aux3 = root:varsCAMTO:aux3
	NVAR aux4 = root:varsCAMTO:aux4
	NVAR FieldMapCount = root:varsCAMTO:FieldMapCount

	variable/G root:varsCAMTO:EnergyGev = aux0
	variable/G root:varsCAMTO:Charge = aux1
	variable/G root:varsCAMTO:Mass = aux2
	variable/G root:varsCAMTO:LightSpeed = aux3
	variable/G root:varsCAMTO:TrajShift = aux4
	
	Wave/T FieldMapDirs = root:wavesCAMTO:FieldMapDirs
	Wave/Z EnergiesGeV = root:wavesCAMTO:EnergiesGeV

	variable i
	if (WaveExists(EnergiesGeV)==1)
		for (i=0; i<FieldMapCount; i++)
			EnergiesGeV[i] = aux0
		endfor
	endif	

End


Function GetFieldMapIndex()

	Wave/T FieldMapDirs = root:wavesCAMTO:FieldMapDirs
	SVAR FieldMapDir = root:varsCAMTO:FieldMapDir

	FindValue/Text=FieldMapDir/TXOP=4 FieldMapDirs		
			
	if (V_value == -1)			
		return -1
	else
		return V_value
	endif

End


Window Load_Field_Data() : Panel
	PauseUpdate; Silent 1		// building window...

	if (DataFolderExists("root:varsCAMTO")==0)
		DoAlert 1, "CAMTO variables not found. Initialize CAMTO?"
		if (V_flag == 1)
			Initialize_CAMTO()
		else
			return
		endif 
	endif

	//Procura Janela e se estiver aberta, fecha antes de abrir novamente.
	string PanelName
	PanelName = WinList("Load_Field_Data",";","")	
	if (stringmatch(PanelName, "Load_Field_Data;"))
		Killwindow Load_Field_Data
	endif
		
	NewPanel /K=1 /W=(740,60,1166,592)
	SetDrawLayer UserBack
	SetDrawEnv fillpat= 0
	DrawRect 5,3,421,62
	SetDrawEnv fillpat= 0
	DrawRect 5,62,421,96
	SetDrawEnv fillpat= 0
	DrawRect 5,96,421,240
	SetDrawEnv fillpat= 0
	DrawRect 5,240,147,394
	SetDrawEnv fillpat= 0
	DrawRect 147,240,284,394
	SetDrawEnv fillpat= 0
	DrawRect 284,240,421,394
	SetDrawEnv fillpat= 0
	DrawRect 5,394,421,457
	SetDrawEnv fillpat= 0
	DrawRect 5,457,421,527
		
	TitleBox FMdir,      pos={12,12},size={80,40},title="\t Select \r Directory ",fSize=14,fStyle=1,frame=0
	CheckBox NewDir     ,pos={100,12},size={110,16},title=" New Directory: "     ,value=1,mode=1,proc=SelectDirectory
	CheckBox ExistingDir,pos={100,37},size={110,16},title=" Existing Directory: ",value=0,mode=1,proc=SelectDirectory
	
	SetVariable NewFieldMapName,pos={225,12},size={115,18},title=" "
	SetVariable NewFieldMapName,value= root:varsCAMTO:NewFieldMap
	Button CreateDir,pos={345,11},size={70,20},fStyle=1,proc=CreateNewDirectory,title="Do It"
	
	PopupMenu FieldMapDir,pos={225,37},size={155,18},bodyWidth=150,mode=0,proc=ChangeDirectory,title=" "
	
	TitleBox title7,pos={180,100},size={81,16},title="Symmetries",fSize=14,frame=0,fStyle=1
	TitleBox title8,pos={66,160},size={52,16},title="Plane 1",fSize=14,frame=0,fStyle=1
	TitleBox title9,pos={271,160},size={52,16},title="Plane 2",fSize=14,frame=0,fStyle=1
	TitleBox LXAxis,pos={39,250},size={63,24},title="X - axis",fSize=20,frame=0
	TitleBox LYAxis,pos={181,250},size={61,24},disable=2,title="Y - axis",fSize=20,frame=0
	TitleBox LZAxis,pos={318,250},size={61,24},title="Z - axis",fSize=20,frame=0
	
	PopupMenu StaticTransient,pos={239,70},size={115,21},mode=0,proc=StaticTransient,title="Data Type :"
	PopupMenu StaticTransient,disable=2,value= #"\"Static;Transient\""
	PopupMenu BeamDirection,pos={38,70},size={139,21},mode=0,proc=BeamDirection,title="Beam Direction :"
	PopupMenu BeamDirection,disable=2,value= #"\"Y-Axis;Z-Axis\""
	PopupMenu SymYZ,pos={18,130},size={163,21},mode=0,proc=PopupSimetrias,title="Along beam direction :"
	PopupMenu SymYZ,disable=2,value= #"\"Yes;No\""
	PopupMenu OtherSym,pos={230,130},size={170,21},mode=0,proc=PopupSimetrias,title="Other symmetry planes :"
	PopupMenu OtherSym,disable=2,value= #"\"0;1;2\""
	PopupMenu Angle1,pos={53.5,185},size={71,21},mode=0,proc=PopupSimetrias,title="Angle :"
	PopupMenu Angle1,disable=2,value= #"\"0°;90°\""
	PopupMenu BC1,pos={11,210},size={156,21},mode=0,proc=PopupSimetrias,title="Boundary Condition :"
	PopupMenu BC1,disable=2,value= #"\"Normal;Tangential\""
	PopupMenu Angle2,pos={251.5,185},size={91,21},mode=0,proc=PopupSimetrias,title="Angle :"
	PopupMenu Angle2,disable=2,value= #"\"30°;45°;90°\""
	PopupMenu BC2,pos={219,210},size={156,21},mode=0,proc=PopupSimetrias,title="Boundary Condition :"
	PopupMenu BC2,disable=2,value= #"\"Normal;Tangential\""
	
	ValDisplay start_x,pos={21,291},size={109,14},title="Start"
	ValDisplay start_x,disable=2,limits={0,0,0},barmisc={0,1000}
	ValDisplay end_x,pos={21,326},size={109,14},title="End"
	ValDisplay end_x,disable=2,limits={0,0,0},barmisc={0,1000}
	ValDisplay steps_x,pos={21,361},size={109,14},title="Steps"
	ValDisplay steps_x,disable=2,limits={0,0,0},barmisc={0,1000}
	
	ValDisplay start_y,pos={161,291},size={109,14},title="Start"
	ValDisplay start_y,disable=2,limits={0,0,0},barmisc={0,1000}
	ValDisplay end_y,pos={161,326},size={109,14},title="End"
	ValDisplay end_y,disable=2,limits={0,0,0},barmisc={0,1000}
	ValDisplay steps_y,pos={161,361},size={109,14},title="Steps"
	ValDisplay steps_y,disable=2,limits={0,0,0},barmisc={0,1000}
	
	ValDisplay start_z,pos={298,291},size={109,14},title="Start"
	ValDisplay start_z,disable=2,limits={0,0,0},barmisc={0,1000}
	ValDisplay end_z,pos={298,326},size={109,14},title="End"
	ValDisplay end_z,disable=2,limits={0,0,0},barmisc={0,1000}
	ValDisplay steps_z,pos={298,361},size={109,14},title="Steps"
	ValDisplay steps_z,disable=2,limits={0,0,0},barmisc={0,1000}
	
	Button loadfield,pos={15,405},size={190,41},proc=Carrega_Resultados,title="Load Magnetic Field"
	Button loadfield,disable=2,fStyle=1
	Button clearfield,pos={220,405},size={190,41},proc=ClearField,title="Clear Field"
	Button clearfield,disable=2,fStyle=1
	
	TitleBox title10,pos={170,462},size={81,16},title="Export Field:",fSize=14,frame=0,fStyle=1
	Button exportfield,pos={15,485},size={190,36},proc=ExportField,title="MagNet Format"
	Button exportfield,disable=2,fStyle=1
	Button exportfieldspectra,pos={220,485},size={190,36},proc=ExportFieldSpectra,title="Spectra Format"
	Button exportfieldspectra,disable=2,fStyle=1
			
	if (strlen(root:varsCAMTO:FieldMapDir) > 0 && cmpstr(root:varsCAMTO:FieldMapDir, "_none_")!=0)
		FindValue/Text=root:varsCAMTO:FieldMapDir/TXOP=4 root:wavesCAMTO:FieldMapDirs
		PopupMenu FieldMapDir,mode=(V_value+1)	
	endif	
	
	UpdateLoadDataPanel()
			
EndMacro


Function UpdateLoadDataPanel()

	string PanelName
	PanelName = WinList("Load_Field_Data",";","")	
	if (stringmatch(PanelName, "Load_Field_Data;")==0)
		return -1
	endif
	
	UpdateFieldMapDirs()

	SVAR df = root:varsCAMTO:FieldMapDir
	NVAR FieldMapCount = root:varsCAMTO:FieldMapCount
	Wave/T FieldMapDirs = root:wavesCAMTO:FieldMapDirs
	
	if (FieldMapCount != 0)
		string FieldMapList = getFieldmapDirs()
		CheckBox ExistingDir,win=Load_Field_Data,value=1, disable=0 	
		PopupMenu FieldMapDir,win=Load_Field_Data,disable=0,value= #("\"" + FieldMapList + "\"")
		CheckBox NewDir,win=Load_Field_Data, value=0
		SetVariable NewFieldMapName,win=Load_Field_Data, disable=1
		Button CreateDir,win=Load_Field_Data,disable=1
	else
		CheckBox ExistingDir,win=Load_Field_Data,value=0, disable=2
		PopupMenu FieldMapDir,win=Load_Field_Data, mode=0, disable=1
		CheckBox NewDir,win=Load_Field_Data, value=1
		SetVariable NewFieldMapName,win=Load_Field_Data, disable=0
		Button CreateDir,win=Load_Field_Data,disable=0
	endif

	if (strlen(df) > 0 && cmpstr(df, "_none_")!=0)
					
		NVAR StaticTransient = root:$(df):varsFieldMap:StaticTransient
		NVAR BeamDirection   = root:$(df):varsFieldMap:BeamDirection
		NVAR SymmetryAlongYZ = root:$(df):varsFieldMap:SymmetryAlongYZ
		NVAR OtherSymmetryPlanes = root:$(df):varsFieldMap:OtherSymmetryPlanes
		NVAR Plane1Angle = root:$(df):varsFieldMap:Plane1Angle
		NVAR Plane1Condition = root:$(df):varsFieldMap:Plane1Condition
		NVAR Plane2Angle = root:$(df):varsFieldMap:Plane2Angle
		NVAR Plane2Condition = root:$(df):varsFieldMap:Plane2Condition
		
		PopupMenu StaticTransient,win=Load_Field_Data,mode=StaticTransient,disable=0
		PopupMenu BeamDirection,win=Load_Field_Data,mode=BeamDirection,disable=0
		PopupMenu SymYZ,win=Load_Field_Data,mode=SymmetryAlongYZ,disable=0
		PopupMenu OtherSym,win=Load_Field_Data,mode=OtherSymmetryPlanes,disable=0
		PopupMenu Angle1,win=Load_Field_Data,mode=Plane1Angle
		PopupMenu BC1,win=Load_Field_Data,mode=Plane1Condition
		PopupMenu Angle2,win=Load_Field_Data,mode=Plane2Angle
		PopupMenu BC2,win=Load_Field_Data,mode=Plane2Condition
		
		ValDisplay start_x,win=Load_Field_Data,value= #("root:"+ df + ":varsFieldMap:StartX" ),disable=0
		ValDisplay end_x,win=Load_Field_Data,value=#("root:"+ df + ":varsFieldMap:EndX"),disable=0
		ValDisplay steps_x,win=Load_Field_Data,value=#("root:"+ df + ":varsFieldMap:StepsX"),disable=0
		ValDisplay start_y,win=Load_Field_Data,value= #("root:"+df+":varsFieldMap:StartY")
		ValDisplay end_y,win=Load_Field_Data,value= #("root:"+df+":varsFieldMap:EndY")
		ValDisplay steps_y,win=Load_Field_Data,value= #("root:"+df+":varsFieldMap:StepsY")
		ValDisplay start_z,win=Load_Field_Data,value= #("root:"+df+":varsFieldMap:StartZ")
		ValDisplay end_z,win=Load_Field_Data,value= #("root:"+df+":varsFieldMap:EndZ")
		ValDisplay steps_z,win=Load_Field_Data,value= #("root:"+df+":varsFieldMap:StepsZ")
	
		if (BeamDirection == 1)
		 	TitleBox   LYAxis,win=Load_Field_Data, disable=0
		 	ValDisplay start_y,win=Load_Field_Data, disable=0
		 	ValDisplay end_y,win=Load_Field_Data, disable=0
		 	ValDisplay steps_y,win=Load_Field_Data, disable=0
		 	TitleBox   LZAxis,win=Load_Field_Data, disable=2
		 	ValDisplay start_z,win=Load_Field_Data, disable=2
		 	ValDisplay end_z,win=Load_Field_Data, disable=2
		 	ValDisplay steps_z,win=Load_Field_Data, disable=2
		else
		 	TitleBox   LYAxis,win=Load_Field_Data, disable=2
		 	ValDisplay start_y,win=Load_Field_Data, disable=2
		 	ValDisplay end_y,win=Load_Field_Data, disable=2
		 	ValDisplay steps_y,win=Load_Field_Data, disable=2
		 	TitleBox   LZAxis,win=Load_Field_Data, disable=0	 
		 	ValDisplay start_z,win=Load_Field_Data, disable=0
		 	ValDisplay end_z,win=Load_Field_Data, disable=0
		 	ValDisplay steps_z,win=Load_Field_Data, disable=0	
		endif
		
		if (OtherSymmetryPlanes == 1)
			PopupMenu Angle1,win=Load_Field_Data, disable=2
			PopupMenu BC1,win=Load_Field_Data, disable=2
			PopupMenu Angle2,win=Load_Field_Data, disable=2
			PopupMenu BC2,win=Load_Field_Data, disable=2
		elseif (OtherSymmetryPlanes == 2)
			PopupMenu Angle1,win=Load_Field_Data, disable=0
			PopupMenu BC1,win=Load_Field_Data, disable=0
			PopupMenu Angle2,win=Load_Field_Data, disable=2
			PopupMenu BC2,win=Load_Field_Data, disable=2
		else
			PopupMenu Angle1,win=Load_Field_Data, mode=Plane1Angle
			PopupMenu Angle1,win=Load_Field_Data, disable=0
			PopupMenu BC1,win=Load_Field_Data, disable=0
			PopupMenu Angle2,win=Load_Field_Data, disable=0
			PopupMenu BC2,win=Load_Field_Data, disable=0
		endif
		
		if (Plane1Angle == 2 && OtherSymmetryPlanes == 3)
			PopupMenu OtherSym,win=Load_Field_Data, mode=OtherSymmetryPlanes
			PopupMenu Angle2,win=Load_Field_Data, disable=2
			PopupMenu BC2,win=Load_Field_Data, disable=2
		endif
		
		Button loadfield,win=Load_Field_Data,   disable=0
		Button exportfield,win=Load_Field_Data, disable=0
		Button exportfieldspectra,win=Load_Field_Data,disable=0
		Button clearfield,win=Load_Field_Data, disable=0
		
	else
		Button loadfield,win=Load_Field_Data,   disable=2
		Button exportfield,win=Load_Field_Data, disable=2
		Button exportfieldspectra,win=Load_Field_Data,disable=2
		Button clearfield,win=Load_Field_Data,  disable=2
		PopupMenu BeamDirection,win=Load_Field_Data,disable=2
		PopupMenu StaticTransient,win=Load_Field_Data,disable=2
		PopupMenu SymYZ,win=Load_Field_Data,disable=2
		PopupMenu OtherSym,win=Load_Field_Data,disable=2
		PopupMenu Angle1,win=Load_Field_Data, disable=2
		PopupMenu BC1,win=Load_Field_Data, disable=2
		PopupMenu Angle2,win=Load_Field_Data, disable=2
		PopupMenu BC2,win=Load_Field_Data, disable=2
	endif


End


Function UpdateFieldMapDirs()

	DFREF   df = GetDataFolderDFR()
	NVAR    FieldMapCount = root:varsCAMTO:FieldMapCount
	SVAR    FieldMapDir   = root:varsCAMTO:FieldMapDir 
	Wave/T  FieldMapDirs  = root:wavesCAMTO:FieldMapDirs
	Wave/Z  EnergiesGeV   = root:wavesCAMTO:EnergiesGeV    

	Make/O/T/N=(FieldMapCount) NewFieldMapDirs
	
	if (WaveExists(EnergiesGeV)==1)
		Make/O/N=(FieldMapCount) NewEnergiesGeV
	endif
	
	variable newFieldMapCount = 0
	
	SetDataFolder root:
	string datafolders = DataFolderDir(1)
	SetDataFolder df
	
	SplitString/E=":.*;" datafolders
	S_value = S_value[1,strlen(S_value)-2]
	
	variable i	
	for (i=0; i<FieldMapCount; i=i+1)
		if (FindListItem(FieldMapDirs[i], S_value, ",") == -1 )
			if (cmpstr(FieldMapDirs[i], FieldMapDir)==0)
				FieldMapDir = ""
			endif
		else
			newFieldMapDirs[newFieldMapCount] = FieldMapDirs[i]
			
			if (WaveExists(EnergiesGeV)==1)
				newEnergiesGeV[newFieldMapCount] = EnergiesGeV[i]
			endif
			
			newFieldMapCount = newFieldMapCount + 1
		endif
	endfor 
	
	FieldMapCount = newFieldMapCount
	Redimension/N=(FieldMapCount) newFieldMapDirs
	Redimension/N=(FieldMapCount) FieldMapDirs
	FieldMapDirs[] = newFieldMapDirs[p]
	
	if (WaveExists(EnergiesGeV)==1)
		Redimension/N=(FieldMapCount) newEnergiesGeV
		Redimension/N=(FieldMapCount) EnergiesGeV
		EnergiesGeV[] = newEnergiesGeV[p]
	endif
	
	Killwaves/Z newFieldMapDirs, newEnergiesGeV

End


Function/S GetFieldMapDirs()
	NVAR    FieldMapCount = root:varsCAMTO:FieldMapCount 
	Wave/T  FieldMapDirs  = root:wavesCAMTO:FieldMapDirs
	
	UpdateFieldMapDirs()
	string fieldmaps=""
	variable i	
	for (i=0; i<FieldMapCount; i=i+1)
		fieldmaps = fieldmaps + FieldMapDirs[i] + ";"
	endfor 
			
	return fieldmaps
End


Function SelectDirectory(cb) : CheckBoxControl
	STRUCT WMCheckboxAction& cb
	
	UpdateFieldMapDirs()
	SVAR df = root:varsCAMTO:FieldMapDir
	NVAR FieldMapCount = root:varsCAMTO:FieldMapCount
	
	strswitch (cb.ctrlName)
		case "NewDir":
			CheckBox ExistingDir,win=Load_Field_Data,value=0
			PopupMenu FieldMapDir,win=Load_Field_Data,disable=1
			SetVariable NewFieldMapName,win=Load_Field_Data,disable=0
			Button CreateDir,win=Load_Field_Data,disable=0
			Button loadfield,win=Load_Field_Data,disable=2
			Button exportfield,win=Load_Field_Data,disable=2
			Button exportfieldspectra,win=Load_Field_Data,disable=2
			Button clearfield,win=Load_Field_Data,disable=2
			
			if (FieldMapCount == 0)
				CheckBox ExistingDir,win=Load_Field_Data,disable=2
			endif
			
			break
		case "ExistingDir":
			CheckBox NewDir,win=Load_Field_Data, value=0
			PopupMenu FieldMapDir,win=Load_Field_Data, disable=0
			SetVariable NewFieldMapName,win=Load_Field_Data, disable=1
			Button CreateDir,win=Load_Field_Data, disable=1

			string FieldMapList = GetFieldMapDirs()
			PopupMenu FieldMapDir,win=Load_Field_Data,disable=0,value= #("\"" + FieldMapList + "\"")
			
			if (strlen(df) > 0 && cmpstr(df, "_none_")!=0)
				Button loadfield, disable=0
				Button exportfield, disable=0
				Button exportfieldspectra, disable=0
				Button clearfield, disable=0
			endif
			
			break
	endswitch
	return 0
End


Function CreateNewDirectory(ctrlName) : ButtonControl
	String ctrlName
	
	UpdateFieldMapDirs()
	SVAR NewFieldMap    = root:varsCAMTO:NewFieldMap
	SVAR FieldMapDir    = root:varsCAMTO:FieldMapDir
	NVAR FieldMapCount  = root:varsCAMTO:FieldMapCount
	Wave/T FieldMapDirs = root:wavesCAMTO:FieldMapDirs
	
	if (strlen(NewFieldMap) == 0)
		DoAlert 0,"Invalid directory name"
		return -1
		
	elseif (strsearch(NewFieldMap, "-",0)!=-1 || strsearch(NewFieldMap, ".",0)!=-1 || strsearch(NewFieldMap, ":",0)!=-1)
		DoAlert 0,"Invalid directory name"
		return -1
		
	elseif (strsearch(NewFieldMap, "/",0)!=-1 || strsearch(NewFieldMap, "\\",0)!=-1 || strsearch(NewFieldMap, "|",0)!=-1 )
		DoAlert 0,"Invalid directory name"
		return -1
		
	elseif (GrepString(NewFieldMap[0],"[[:alpha:]]") ==0)
		DoAlert 0,"Invalid directory name"
		return -1
		
	else
		SetDataFolder root:
		
		CheckBox NewDir, value=0
		CheckBox ExistingDir, value=1, disable=0
		SetVariable NewFieldMapName, disable=1
		Button CreateDir, disable=1
								
		FindValue/Text=NewFieldMap/TXOP=4 FieldMapDirs		
		
		FieldMapDir = NewFieldMap	
		NewFieldMap = ""	
		
		if (V_value == -1)			
			FieldMapCount = FieldMapCount + 1
			Redimension/N=(FieldMapCount) FieldMapDirs
			FieldMapDirs[FieldMapCount-1] = FieldMapDir
			PopupMenu FieldMapDir,win=Load_Field_Data,disable=0,mode=(FieldMapCount)
			NewDataFolder/O/S  $FieldMapDir
			InitializeFieldMapVariables()	
		else
			PopupMenu FieldMapDir,win=Load_Field_Data,disable=0,mode=(V_value+1)
			SetDataFolder $FieldMapDir
			DoAlert 1, "Replace data folder?"
			if (V_flag==1)
				InitializeFieldMapVariables()		 
			endif
		endif
		
		UpdatePanels()
		UpdateCompareResultsPanel()
	
	endif
	
End


Function ChangeDirectory(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	UpdateFieldMapDirs()
	SVAR FieldMapDir= root:varsCAMTO:FieldMapDir
	Wave/T FieldMapDirs= root:wavesCAMTO:FieldMapDirs
	
	FindValue/Text=popStr/TXOP=4 FieldMapDirs
	
	if (strlen(popStr) > 0 && V_Value!=-1)
		FieldMapDir = popStr
		SetDataFolder root:$(FieldMapDir)
		PopupMenu FieldMapDir,win=Load_Field_Data,mode=popNum
	endif
	
	UpdatePanels()

End


Function UpdatePanels()
	UpdateLoadDataPanel()
	UpdateHallProbePanel()
	UpdateIntegralsMultipolesPanel()
	UpdateTrajectoriesPanel()
	UpdateDynMultipolesPanel()
	UpdateFindPeaksPanel()
	UpdateResultsPanel()
	UpdateCompareResultsPanel()
	UpdateFindPeaksPanel()
	UpdatePhaseErrorPanel()
End


Function CheckDataFolder()
	string current_df = GetDataFolder(0)
	SVAR df = root:varsCAMTO:FieldMapDir
	
	UpdateLoadDataPanel()
	
	variable dffound = 1 
	
	if (cmpstr(current_df, df)!=0)
		DoAlert 1,"Change current data folder?"
		if (V_flag==1)
			if (strlen(df) == 0)
				DoAlert 0,"Data folder not found."
				dffound = -1 
			else
				SetDataFolder root:$df
			endif		
		else
			dffound = -1 
		endif
	endif

	UpdateLoadDataPanel()
		
	return dffound
End


Function BeamDirection(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	if (CheckDataFolder() == -1)
		return -1
	endif
		
	NVAR BeamDirection = :varsFieldMap:BeamDirection
	BeamDirection = popNum
 	
	if (popNum ==1)
	 	TitleBox   LYAxis disable=0
	 	ValDisplay start_y disable=0
	 	ValDisplay end_y disable=0
	 	ValDisplay steps_y disable=0
	 	TitleBox   LZAxis disable=2
	 	ValDisplay start_z disable=2
	 	ValDisplay end_z disable=2
	 	ValDisplay steps_z disable=2
	else
	 	TitleBox   LYAxis disable=2
	 	ValDisplay start_y disable=2
	 	ValDisplay end_y disable=2
	 	ValDisplay steps_y disable=2
	 	TitleBox   LZAxis disable=0	 
	 	ValDisplay start_z disable=0
	 	ValDisplay end_z disable=0
	 	ValDisplay steps_z disable=0	
	endif
	
	PopupMenu BeamDirection,win=Load_Field_Data,mode=popNum
	
End


Function StaticTransient(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	if (CheckDataFolder() == -1)
		return -1
	endif
	
	NVAR StaticTransient = :varsFieldMap:StaticTransient 
	StaticTransient = popNum
	
	PopupMenu StaticTransient,win=Load_Field_Data,mode=popNum
End


Function PopupSimetrias(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	if (CheckDataFolder() == -1)
		return -1
	endif
	
	NVAR SymmetryAlongYZ 		= :varsFieldMap:SymmetryAlongYZ
	NVAR OtherSymmetryPlanes  = :varsFieldMap:OtherSymmetryPlanes
	NVAR Plane1Angle 			= :varsFieldMap:Plane1Angle
	NVAR Plane1Condition 		= :varsFieldMap:Plane1Condition
	NVAR Plane2Angle 			= :varsFieldMap:Plane2Angle
	NVAR Plane2Condition		= :varsFieldMap:Plane2Condition		
	
	if (stringmatch(ctrlName, "SymYZ"))
		SymmetryAlongYZ = popNum
	endif

	if (stringmatch(ctrlName, "OtherSym"))
		OtherSymmetryPlanes = popNum
		if (popNum == 1)
			PopupMenu Angle1 disable=2
			PopupMenu BC1 disable=2
			PopupMenu Angle2 disable=2
			PopupMenu BC2 disable=2
		elseif (popNum == 2)
			PopupMenu Angle1 disable=0
			PopupMenu BC1 disable=0
			PopupMenu Angle2 disable=2
			PopupMenu BC2 disable=2
		else
			Plane1Angle = 1
			PopupMenu Angle1 mode=Plane1Angle
			PopupMenu Angle1 disable=0
			PopupMenu BC1 disable=0
			PopupMenu Angle2 disable=0
			PopupMenu BC2 disable=0
		endif
	endif

	if (stringmatch(ctrlName, "Angle1"))
		Plane1Angle = popNum
		if (Plane1Angle == 2 && OtherSymmetryPlanes == 3)
			OtherSymmetryPlanes = 2
			PopupMenu OtherSym mode=OtherSymmetryPlanes
			PopupMenu Angle2 disable=2
			PopupMenu BC2 disable=2
		endif
	endif
	
	if (stringmatch(ctrlName, "BC1"))
		Plane1Condition = popNum
	endif
	
	if (stringmatch(ctrlName, "Angle2"))
		Plane2Angle = popNum
	endif
	
	if (stringmatch(ctrlName, "BC2"))
		Plane2Condition = popNum
	endif
	
	UpdateLoadDataPanel()
	
End


Function Carrega_Resultados(ctrlName) : ButtonControl
	String ctrlName

	if (CheckDataFolder() == -1)
		return -1
	endif
	
	if (WaveExists(C_PosX))
		DoAlert 1, "Overwrite field data?" 
		if (V_flag==1)
			Killvariables/A/Z
			KillStrings/A/Z
			KillWaves/A/Z
		else
			return -1
		endif
		
	endif
	
	variable i, j
	LoadWave/H/O/G/D/W/A ""

	if (V_flag==0) 
		return -1
	endif

	NVAR FieldMapCount = root:varsCAMTO:FieldMapCount
	NVAR EnergyGeV = root:varsCAMTO:EnergyGeV

	Wave/Z EnergiesGeV = root:wavesCAMTO:EnergiesGeV
	
	if (WaveExists(EnergiesGeV)==1)		
		variable idx = GetFieldMapIndex()
		if (idx == -1)			
			DoAlert 0, "Invalid directory."
			return -1
		else
			Redimension/N=(FieldMapCount) EnergiesGeV
			EnergiesGeV[idx] = EnergyGeV
		endif
	endif

	SVAR FMFilename = :varsFieldMap:FMFilename
	SVAR FMPath     = :varsFieldMap:FMPath
	FMFilename = S_fileName
	FMPath     = S_path

	Save_header_info()

	NVAR StaticTransient = :varsFieldMap:StaticTransient	
	NVAR BeamDirection   = :varsFieldMap:BeamDirection

	NVAR StartX   = :varsFieldMap:StartX
	NVAR EndX     = :varsFieldMap:EndX
	NVAR StepsX   = :varsFieldMap:StepsX
	NVAR NPointsX = :varsFieldMap:NPointsX

	NVAR StartY   = :varsFieldMap:StartY
	NVAR EndY     = :varsFieldMap:EndY
	NVAR StepsY   = :varsFieldMap:StepsY
	NVAR NPointsY = :varsFieldMap:NPointsY	
	
	NVAR StartZ   = :varsFieldMap:StartZ
	NVAR EndZ     = :varsFieldMap:EndZ
	NVAR StepsZ   = :varsFieldMap:StepsZ
	NVAR NPointsZ = :varsFieldMap:NPointsZ	
	
	NVAR StartYZ   = :varsFieldMap:StartYZ
	NVAR EndYZ     = :varsFieldMap:EndYZ
	NVAR StepsYZ   = :varsFieldMap:StepsYZ
	NVAR NPointsYZ = :varsFieldMap:NPointsYZ
	
	NVAR SymmetryBxX = :varsFieldMap:SymmetryBxX
	NVAR SymmetryBxY = :varsFieldMap:SymmetryBxY
	NVAR SymmetryBxZ = :varsFieldMap:SymmetryBxZ
	NVAR SymmetryByX = :varsFieldMap:SymmetryByX
	NVAR SymmetryByY = :varsFieldMap:SymmetryByY
	NVAR SymmetryByZ = :varsFieldMap:SymmetryByZ
	NVAR SymmetryBzX = :varsFieldMap:SymmetryBzX
	NVAR SymmetryBzY = :varsFieldMap:SymmetryBzY
	NVAR SymmetryBzZ = :varsFieldMap:SymmetryBzZ
	
	NVAR SymmetryAlongYZ     = :varsFieldMap:SymmetryAlongYZ
	NVAR OtherSymmetryPlanes = :varsFieldMap:OtherSymmetryPlanes
	NVAR Plane1Angle         = :varsFieldMap:Plane1Angle
	NVAR Plane1Condition     = :varsFieldMap:Plane1Condition
	NVAR Plane2Angle         = :varsFieldMap:Plane2Angle
	NVAR Plane2Condition     = :varsFieldMap:Plane2Condition

	//Carrega coluna das posições em X, procura min, max e steps e aplica simetrias
	WAVE wave0 // = PosX
	wavestats/Q wave0
	StartX = V_min
	EndX = V_max
	StepsX = abs(wave0[1] - StartX)
	if (StepsX == 0)
	   StepsX = 1
	endif
	EraseStatsVariables()	
	
	variable BoundCondAt90 = 0
	if (OtherSymmetryPlanes == 2 && Plane1Angle == 2)
		BoundCondAt90 = Plane1Condition
	elseif (OtherSymmetryPlanes == 3)
		if (Plane2Angle == 2)
			BoundCondAt90 = Plane1Condition
		else
			BoundCondAt90 = Plane2Condition
		endif
	endif
	
	if (BoundCondAt90 == 1)
		SymmetryBxX = 2
		SymmetryByX = 3
		SymmetryBzX = 3
	elseif (BoundCondAt90 == 2)
		SymmetryBxX = 3
		SymmetryByX = 2
		SymmetryBzX = 2
	endif
	
	NPointsX = (EndX-StartX)/StepsX + 1
	
	//Cria a wave de posiçãoX já com a simetria escolhida.
	Make/D/O/N=(NPointsX) C_PosX
	for (i=0;i<NPointsX;i+=1)
		C_PosX[i] = (StartX + StepsX*i) / 1000  // Converte para metros
	endfor

	//Verifica sentido do feixe Y ou Z e carrega as posições procurando min, max e steps
	WAVE wave1 // = PosY
	WAVE wave2 // = PosZ
	if (BeamDirection == 1)
		wavestats/Q wave1
		StartY = V_min
		EndY = V_max
		StepsY = abs(wave1[NPointsX] - StartY)
		EraseStatsVariables()	
		
		if ((SymmetryAlongYZ == 1) && (StartY == 0))
			StartY = EndY*-1
		else
			SymmetryBxY = 1
			SymmetryByY = 1
			SymmetryBzY = 1
		endif
		NPointsY = Round((EndY-StartY)/StepsY + 1)

		//Cria a wave de posiçãoYZ já com a simetria escolhida.
		Make/D/O/N=(NPointsY) C_PosYZ
		for (i=0;i<NPointsY;i+=1)
			C_PosYZ[i] = (StartY + StepsY*i) / 1000 // Converte para metros
		endfor
		
		StartYZ = StartY
		EndYZ = EndY
		StepsYZ = StepsY
		NPointsYZ = NPointsY	
		//SymmetryYZ = SymmetryY
		
		//Zera valores não utilizados
		StartZ = 0
		EndZ = 0
		StepsZ = 1
		NPointsZ = 0
	else
		wavestats/Q wave2
		StartZ = V_min
		EndZ = V_max
		StepsZ = abs(wave2[NPointsX] - StartZ)
		EraseStatsVariables()	
		
		if ((SymmetryAlongYZ == 1) && (StartZ == 0))
			StartZ = EndZ*-1
		else
			SymmetryBxZ = 1
			SymmetryByZ = 1
			SymmetryBzZ = 1
		endif
		NPointsZ = Round((EndZ-StartZ)/StepsZ + 1)		

		//Cria a wave de posiçãoYZ já com a simetria escolhida.
		Make/D/O/N=(NPointsZ) C_PosYZ
		for (i=0;i<NPointsZ;i+=1)
			C_PosYZ[i] = (StartZ + StepsZ*i) / 1000  // Converte para metros
		endfor

		StartYZ = StartZ
		EndYZ = EndZ
		StepsYZ = StepsZ
		NPointsYZ = NPointsZ	
		//SymmetryYZ = SymmetryZ

		//Zera valores não utilizados
		StartY = 0
		EndY = 0
		StepsY = 1
		NPointsY = 0
	endif
	
	String Raia
	String RaiaAux	
	
	//Cria wave de posição X de acordo com o número de iterações
	for (j=0;j<NPointsX;j+=1)
		Raia = "RaiaBx_X" + num2str(C_PosX[j])
		Make/D/O/N=(NPointsYZ) $Raia		
		
		Raia = "RaiaBy_X" + num2str(C_PosX[j])
		Make/D/O/N=(NPointsYZ) $Raia		

		Raia = "RaiaBz_X" + num2str(C_PosX[j])
		Make/D/O/N=(NPointsYZ) $Raia				
	endfor
		
	if (StaticTransient == 1)
		Wave Wave3 // = Bx
		Wave Wave4 // = By
		Wave Wave5 // = Bz	
	else
		Wave Wave3 // Time step
		Wave Wave4 // Bx
		Wave Wave5 // By		
		Wave Wave6 // Bz	
		
		Wave TmpTransient = Wave3
		Wave3 = Wave4
		Wave4 = Wave5
		Wave5 = Wave6
	endif
	
	variable NPointsSymmYZ
	
	if (BeamDirection == 1) //calculating Bx, By and Bz along Y (beam direction), using symmetries
		for(j=0;j<NPointsX;j+=1)
		
			Raia = "RaiaBx_X" + num2str(C_PosX[j])
			Wave Tmp = $Raia
			if (SymmetryBxY == 1)
				for(i=0;i<NPointsYZ;i+=1)
					Tmp[i] = Wave3[i*NPointsX+j]
				endfor
			else
				NPointsSymmYZ = (NPointsYZ+1)/2
				for(i=0;i<NPointsSymmYZ;i+=1)
					Tmp[NPointsSymmYZ-1-i] = Wave3[i*NPointsX+j]
					Tmp[NPointsSymmYZ-1+i] = Wave3[i*NPointsX+j]
				endfor
			endif
			
			Raia = "RaiaBy_X" + num2str(C_PosX[j])
			Wave Tmp = $Raia
			if (SymmetryByY == 1)
				for(i=0;i<NPointsYZ;i+=1)
					Tmp[i] = Wave4[i*NPointsX+j]
				endfor
			else
				NPointsSymmYZ = (NPointsYZ+1)/2
				for(i=0;i<NPointsSymmYZ;i+=1)
					Tmp[NPointsSymmYZ-1-i] = Wave4[i*NPointsX+j]*-1
					Tmp[NPointsSymmYZ-1+i] = Wave4[i*NPointsX+j]
				endfor
			endif
			
			Raia = "RaiaBz_X" + num2str(C_PosX[j])
			Wave Tmp = $Raia
			if (SymmetryBzY == 1)
				for(i=0;i<NPointsYZ;i+=1)
					Tmp[i] = Wave5[i*NPointsX+j]
				endfor
			else
				NPointsSymmYZ = (NPointsYZ+1)/2
				for(i=0;i<NPointsSymmYZ;i+=1)
					Tmp[NPointsSymmYZ-1-i] = Wave5[i*NPointsX+j]
					Tmp[NPointsSymmYZ-1+i] = Wave5[i*NPointsX+j]
				endfor
			endif
			
		endfor
	else //calculating Bx, By and Bz along Z (beam direction), using symmetries
		for(j=0;j<NPointsX;j+=1)
		
			Raia = "RaiaBx_X" + num2str(C_PosX[j])
			Wave Tmp = $Raia
			if (SymmetryBxZ == 1)
				for(i=0;i<NPointsYZ;i+=1)
					Tmp[i] = Wave3[i*NPointsX+j]
				endfor
			else
				NPointsSymmYZ = (NPointsYZ+1)/2
				for(i=0;i<NPointsSymmYZ;i+=1)
					Tmp[NPointsSymmYZ-1-i] = Wave3[i*NPointsX+j]
					Tmp[NPointsSymmYZ-1+i] = Wave3[i*NPointsX+j]
				endfor
			endif
			
			Raia = "RaiaBy_X" + num2str(C_PosX[j])
			Wave Tmp = $Raia
			if (SymmetryByZ == 1)
				for(i=0;i<NPointsYZ;i+=1)
					Tmp[i] = Wave4[i*NPointsX+j]
				endfor
			else
				NPointsSymmYZ = (NPointsYZ+1)/2
				for(i=0;i<NPointsSymmYZ;i+=1)
					Tmp[NPointsSymmYZ-1-i] = Wave4[i*NPointsX+j]
					Tmp[NPointsSymmYZ-1+i] = Wave4[i*NPointsX+j]
				endfor
			endif
			
			Raia = "RaiaBz_X" + num2str(C_PosX[j])
			Wave Tmp = $Raia
			if (SymmetryBzZ == 1)
				for(i=0;i<NPointsYZ;i+=1)
					Tmp[i] = Wave5[i*NPointsX+j]
				endfor
			else
				NPointsSymmYZ = (NPointsYZ+1)/2
				for(i=0;i<NPointsSymmYZ;i+=1)
					Tmp[NPointsSymmYZ-1-i] = Wave5[i*NPointsX+j]*-1
					Tmp[NPointsSymmYZ-1+i] = Wave5[i*NPointsX+j]
				endfor
			endif
			
		endfor
	endif
	
	if (BoundCondAt90 != 0)
		for(j=1;j<NPointsX;j+=1)
			Raia = "RaiaBx_X" + num2str(C_PosX[j])
			RaiaAux = "RaiaBx_X-" + num2str(C_PosX[j])
			make/D/O $RaiaAux
			Wave Tmp = $RaiaAux
			Duplicate/D/O $Raia, Tmp
			if (SymmetryBxX == 3)
				Tmp = -Tmp
			endif
			
			Raia = "RaiaBy_X" + num2str(C_PosX[j])
			RaiaAux = "RaiaBy_X-" + num2str(C_PosX[j])
			make/D/O $RaiaAux
			Wave Tmp = $RaiaAux
			Duplicate/D/O $Raia, Tmp
			if (SymmetryByX == 3)
				Tmp = -Tmp
			endif
			
			Raia = "RaiaBz_X" + num2str(C_PosX[j])
			RaiaAux = "RaiaBz_X-" + num2str(C_PosX[j])
			make/D/O $RaiaAux
			Wave Tmp = $RaiaAux
			Duplicate/D/O $Raia, Tmp
			if (SymmetryBzX == 3)
				Tmp = -Tmp
			endif
		endfor
		
		StartX = EndX*-1
		NPointsX = (EndX-StartX)/StepsX + 1
	
		Make/D/O/N=(NPointsX) C_PosX
		for (i=0;i<NPointsX;i+=1)
			C_PosX[i] = (StartX + StepsX*i) / 1000
		endfor
		
	endif
	
	variable/G varsFieldMap:ErrAng = 0	
	
	Killwaves/Z wave0
	Killwaves/Z wave1
	Killwaves/Z wave2
	Killwaves/Z wave3
	Killwaves/Z wave4
	Killwaves/Z wave5		
	
	if (StaticTransient == 2)
		Killwaves/Z wave6
	endif
	
	UpdateVariables()
	UpdatePanels()
			
End


Function Save_header_info()

	SVAR FMFilename = :varsFieldMap:FMFilename
	SVAR FMPath     = :varsFieldMap:FMPath
	
	Wave/T HeaderLines
	
	NewPath/O/Z SymPath FMPath
	
	variable refNum, count
	string str, strv
	
	Open/R/P=SymPath refNum as FMFileName

	count = 0
	do
		FReadLine refNum, str
		if (strsearch(str, "---------", 0) != -1 || strlen(str) == 0)
			break
		endif	
		
		Redimension/N=(count+1) HeaderLines
		HeaderLines[count] = str
		count = count + 1
	
	while (count < 100)
	
	Redimension/N=(count-1) HeaderLines
	
	Close/A 

End


Function UpdateVariables()

	NVAR StartX  = :varsFieldMap:StartX
	NVAR EndX    = :varsFieldMap:EndX
	NVAR StartYZ = :varsFieldMap:StartYZ
	NVAR EndYZ   = :varsFieldMap:EndYZ

	NVAR GridMin     = :varsFieldMap:GridMin
	NVAR GridMax 	 = :varsFieldMap:GridMax
	NVAR StartYZTraj = :varsFieldMap:StartYZTraj
	NVAR EndYZTraj   = :varsFieldMap:EndYZTraj 
	
	NVAR StepsYZ      = :varsFieldMap:StepsYZ
	NVAR StepsYZPeaks = :varsFieldMap:StepsYZPeaks 
	
	GridMin = StartX
	GridMax = EndX
	StartYZTraj = StartYZ
	EndYZTraj   = EndYZ
	StepsYZPeaks = StepsYZ
	
End


Function EraseStatsVariables()
   KillVariables/Z  V_npnts
   KillVariables/Z  V_numNaNs
   KillVariables/Z  V_numINFs
   KillVariables/Z  V_avg
   KillVariables/Z  V_Sum
   KillVariables/Z  V_sdev
   KillVariables/Z  V_rms
   KillVariables/Z  V_adev
   KillVariables/Z  V_skew
   KillVariables/Z  V_kurt
   KillVariables/Z  V_minloc
   KillVariables/Z  V_maxloc
   KillVariables/Z  V_min
   KillVariables/Z  V_max
   KillVariables/Z  V_startRow
   KillVariables/Z  V_endRow        
   KillVariables/Z  V_sem        
   KillVariables/Z  V_minRowLoc        
   KillVariables/Z  V_maxRowLoc                 
End


Function ExportField(ctrlName) : ButtonControl
	String ctrlName
	
	if (CheckDataFolder() == -1)
		return -1
	endif
	
	Export_Full_Data()

End


Function Export_Full_Data()

	NVAR BeamDirection = :varsFieldMap:BeamDirection

	NVAR StartX    = :varsFieldMap:StartX
	NVAR EndX      = :varsFieldMap:EndX
	NVAR StepsX    = :varsFieldMap:StepsX
	NVAR NPointsX  = :varsFieldMap:NPointsX

	NVAR StartYZ   = :varsFieldMap:StartYZ
	NVAR EndYZ     = :varsFieldMap:EndYZ
	NVAR StepsYZ   = :varsFieldMap:StepsYZ
	NVAR NPointsYZ = :varsFieldMap:NPointsYZ	
	
	SVAR FMPath 		= :varsFieldMap:FMPath
	
	string nome
	variable i, j, k
	
	make/D/o/n=(NPointsX*NPointsYZ) Exportwave0
	make/D/o/n=(NPointsX*NPointsYZ) Exportwave1
	make/D/o/n=(NPointsX*NPointsYZ) Exportwave2
	make/D/o/n=(NPointsX*NPointsYZ) Exportwave3
	make/D/o/n=(NPointsX*NPointsYZ) Exportwave4
	make/D/o/n=(NPointsX*NPointsYZ) Exportwave5
	
	k =0
	for (i=0;i<NPointsYZ;i=i+1)
		for (j=0;j<NpointsX;j=j+1)

			Exportwave0[k] = StartX + j*StepsX		

			if (BeamDirection == 1)
				Exportwave1[k] = StartYZ + i*StepsYZ
				Exportwave2[k] = 0
			else
				Exportwave1[k] = 0
				Exportwave2[k] = StartYZ + i*StepsYZ			
			endif
			
			nome = "RaiaBx_X" + num2str(Exportwave0[k]/1000)
			Wave Tmp = $nome
			Exportwave3[k] = Tmp[i]

			nome = "RaiaBy_X" + num2str(Exportwave0[k]/1000)
			Wave Tmp = $nome
			Exportwave4[k] = Tmp[i]

			nome = "RaiaBz_X" + num2str(Exportwave0[k]/1000)
			Wave Tmp = $nome
			Exportwave5[k] = Tmp[i]
			
			k = k + 1
		endfor
	endfor
	
	Edit/N=CompleteTable Exportwave0,Exportwave1,Exportwave2,Exportwave3,Exportwave4,Exportwave5
	ModifyTable sigDigits(Exportwave3)=16,sigDigits(Exportwave4)=16,sigDigits(Exportwave5)=16

	string NewFMFilename = GetDefaultFilename()	
	
	Open/D TablePath as FMPath+NewFMFilename
	if (!stringmatch(S_fileName,""))
		IncludeHeader(S_fileName)
		SaveTableCopy/A=2/O/T=1/W=CompleteTable/N=0 as S_fileName
	endif
	Close/A
		
	KillWindow/Z CompleteTable
	
	Killwaves/Z Exportwave0
	Killwaves/Z Exportwave1
	Killwaves/Z Exportwave2
	Killwaves/Z Exportwave3
	Killwaves/Z Exportwave4
	Killwaves/Z Exportwave5		
End


Function ExportFieldSpectra(ctrlName) : ButtonControl
	String ctrlName
	
	if (CheckDataFolder() == -1)
		return -1
	endif
	
	NVAR BeamDirection = :varsFieldMap:BeamDirection

	NVAR StartX    = :varsFieldMap:StartX
	NVAR EndX      = :varsFieldMap:EndX
	NVAR StepsX    = :varsFieldMap:StepsX
	NVAR NPointsX  = :varsFieldMap:NPointsX

	NVAR StartYZ   = :varsFieldMap:StartYZ
	NVAR EndYZ     = :varsFieldMap:EndYZ
	NVAR StepsYZ   = :varsFieldMap:StepsYZ
	NVAR NPointsYZ = :varsFieldMap:NPointsYZ	
	
	SVAR FMPath 		= :varsFieldMap:FMPath
	
	string nome
	variable i, j, l, k, xpos
	
	if (NPointsYZ < 4)
		DoAlert 0, "The number of points in the longitudinal direction must be greater than 4."
		return -1
	endif
		
	variable CorNpointsX, CorStepsX
	variable NpointsV = 2
	variable StepsV = 1
	
	make/D/o/n=(NPointsX*NpointsV*NPointsYZ) Exportwave0
	make/D/o/n=(NPointsX*NpointsV*NPointsYZ) Exportwave1
	make/D/o/n=(NPointsX*NpointsV*NPointsYZ) Exportwave2
	
	k=0
	for (j=0; j<NpointsX; j=j+1)
		xpos = StartX + j*StepsX		
		
		for (l=0; l<NpointsV; l=l+1)
			
			for (i=0; i<NPointsYZ; i=i+1)
						
				nome = "RaiaBx_X" + num2str(xpos/1000)
				Wave Tmp = $nome
				Exportwave0[k] = Tmp[i]
	
				nome = "RaiaBy_X" + num2str(xpos/1000)
				Wave Tmp = $nome
				Exportwave1[k] = Tmp[i]
	
				nome = "RaiaBz_X" + num2str(xpos/1000)
				Wave Tmp = $nome
				Exportwave2[k] = Tmp[i]
				
				k = k + 1
			
			endfor
		
		endfor
	
	endfor
	
	if (NpointsX == 1)
		CorNpointsX = 2
		CorStepsX = 1
		Concatenate/O/NP {Exportwave0, Exportwave0}, ConcatExportwave0
		Concatenate/O/NP {Exportwave1, Exportwave1}, ConcatExportwave1
		Concatenate/O/NP {Exportwave2, Exportwave2}, ConcatExportwave2
		Edit/N=CompleteTable ConcatExportwave0, ConcatExportwave1, ConcatExportwave2
		ModifyTable sigDigits(ConcatExportwave0)=16, sigDigits(ConcatExportwave1)=16, sigDigits(ConcatExportwave2)=16
		
	else
		CorNpointsX = NpointsX
		CorStepsX = StepsX
		Edit/N=CompleteTable Exportwave0, Exportwave1, Exportwave2
		ModifyTable sigDigits(Exportwave0)=16, sigDigits(Exportwave1)=16, sigDigits(Exportwave2)=16
	
	endif
	
	string NewFMFilename = GetDefaultFilename(Spectra=1)	
	string header_str
	sprintf header_str, "%g\t%g\t%g\t%g\t%g\t%g", CorStepsX, StepsV, StepsYZ, CorNpointsX, NpointsV, NPointsYZ

	Make/O/T/N=1 SpectraHeaderLines
	SpectraHeaderLines[0] = header_str
		
	Open/D TablePath as FMPath+NewFMFilename
	if (!stringmatch(S_fileName,""))
		Edit/N=Header SpectraHeaderLines
		SaveTableCopy/A=0/O/T=1/W=Header0/N=0 as S_fileName
		SaveTableCopy/A=2/O/T=1/W=CompleteTable/N=0 as S_fileName
	endif
	Close/A
		
	KillWindow/Z CompleteTable
	KillWindow/Z Header0
	KillWaves/Z HeaderLines	
	Killwaves/Z Exportwave0, Exportwave1, Exportwave2
	Killwaves/Z ConcatExportwave0, ConcatExportwave1, ConcatExportwave2

End


Function/S year()
	return StringFromList(0, Secs2Date(DateTime, -2), "-")
End
 
 
Function/S month()
	variable ret = str2num(StringFromList(1, Secs2Date(DateTime, -2), "-"))
	if (ret < 10) 
		return "0"+num2str(ret)
	else 
		return num2str(ret)
	endif
End

 
Function/S day()
	variable ret = str2num(StringFromList(2, Secs2Date(DateTime, -2), "-"))
	if (ret < 10) 
		return "0"+num2str(ret)
	else 
		return num2str(ret)
	endif
End

 
Function/S hour()
	variable ret = str2num(StringFromList(0, Secs2Time(DateTime, 3), ":"))
	if (ret < 10) 
		return "0"+num2str(ret)
	else 
		return num2str(ret)
	endif
End

 
Function/S minute()
	variable ret = str2num(StringFromList(1, Secs2Time(DateTime, 3), ":"))
	if (ret < 10) 
		return "0"+num2str(ret)
	else 
		return num2str(ret)
	endif
End
 
 
Function/S second()
	variable ret = str2num(StringFromList(2, Secs2Time(DateTime, 3), ":"))
	if (ret < 10) 
		return "0"+num2str(ret)
	else 
		return num2str(ret)
	endif
End


Function/S GetDefaultFilename([Spectra])
	variable Spectra
	
	if (ParamIsDefault(Spectra))
		Spectra = 0
	endif	
	
	SVAR FMFilename = :varsFieldMap:FMFilename
	
	NVAR StartX    = :varsFieldMap:StartX
	NVAR EndX      = :varsFieldMap:EndX
	NVAR StartY    = :varsFieldMap:StartY
	NVAR EndY      = :varsFieldMap:EndY
	NVAR StartZ    = :varsFieldMap:StartZ
	NVAR EndZ      = :varsFieldMap:EndZ

	string newfilename
	string cropfilename
	string old
	string new
	variable startidx, endidx
		
	newfilename = FMfilename
	
	startidx = strsearch(newfilename, "X=",0)
	if (startidx!=-1) 
		cropfilename = newfilename[startidx, strlen(newfilename)]
		endidx   = strsearch(cropfilename, "mm",0)
		old = cropfilename[0,endidx+1]
		
		sprintf new, "X=%g_%gmm", StartX, EndX
		newfilename = ReplaceString(old, newfilename, new)
	endif

	startidx = strsearch(newfilename, "Y=",0)
	if (startidx!=-1) 
		cropfilename = newfilename[startidx, strlen(newfilename)]
		endidx   = strsearch(cropfilename, "mm",0)
		old = cropfilename[0,endidx+1]
		
		sprintf new, "Y=%g_%gmm", StartY, EndY
		newfilename = ReplaceString(old, newfilename, new)
	endif

	startidx = strsearch(newfilename, "Z=",0)
	if (startidx!=-1) 
		cropfilename = newfilename[startidx, strlen(newfilename)]
		endidx   = strsearch(cropfilename, "mm",0)
		old = cropfilename[0,endidx+1]
		
		sprintf new, "Z=%g_%gmm", StartZ, EndZ
		newfilename = ReplaceString(old, newfilename, new)
	endif

	endidx = strsearch(newfilename, "_", 0)
	string oldtimestamp = newfilename[0, endidx-1]
	string expr="([[:digit:]]+)-([[:digit:]]+)-([[:digit:]]+)"
	string s1, s2, s3
	SplitString/E=(expr) oldtimestamp, s1, s2, s3 
	if (V_flag == 3)
		string newtimestamp = year() + "-" + month() + "-" + day()
		newfilename = ReplaceString(oldtimestamp, newfilename, newtimestamp)
	endif
	
	if (Spectra)
		SplitString/E=".*\." newfilename
		string tmp = S_value[0, strlen(S_value)-2] + "_spectra_format"
		SplitString/E="\..*" newfilename
		newfilename = tmp + S_value
	endif
	
	return newfilename

end 


Function IncludeHeader(fullPath)
	string fullPath
		
	Wave/T HeaderLines
	
	SplitString/E=".*:" fullPath
	string NewFilename = fullPath[strlen(S_value),strlen(fullPath)-1]
	string NewTimestamp = year() + "-" + month() + "-" + day() +  "_" + hour() + "-" + minute() + "-" + second()
	
	Duplicate/O/T HeaderLines NewHeaderLines
	
	variable i, size, replaced
	string str, strv
	
	size = numpnts(NewHeaderLines)
	replaced = 0
	
	for (i=0; i<size; i=i+1)
		
		str = NewHeaderLines[i]
		
		sscanf str, "timestamp: %s", strv
		if (strlen(strv) != 0)
			NewHeaderLines[i] =ReplaceString(strv, str, NewTimestamp)
			replaced = replaced + 1
		endif

		sscanf str, "filename: %s", strv
		if (strlen(strv) != 0)
			NewHeaderLines[i] = ReplaceString(strv, str, NewFilename)
			replaced = replaced + 1
		endif
		
		if (replaced == 2)
			break
		endif
	
	endfor
	
	Redimension/N=(size+2) NewHeaderLines
	NewHeaderLines[size] = "X[mm]	Y[mm]	Z[mm]	Bx	By	Bz	[T]"	
	NewHeaderLines[size+1] = "------------------------------------------------------------------------------------------------------------------------------------------------------------------"	
	
	Edit/N=Header NewHeaderLines
	SaveTableCopy/A=0/O/T=1/W=Header0/N=0 as fullPath
	KillWindow Header0
	KillWaves/Z NewHeaderLines
End


Function ClearField(ctrlName) : ButtonControl
	String ctrlName
	
	if (CheckDataFolder() == -1)
		return -1
	endif
	
	InitializeFieldMapVariables()	
	UpdatePanels()
End


Function SelectCopyDirectory(popNum,popStr)
	Variable popNum
	String popStr
	
	string FieldMapList = getFieldmapDirs()
	SVAR FieldMapCopy = root:varsCAMTO:FieldMapCopy
	Wave/T FieldMapDirs= root:wavesCAMTO:FieldMapDirs
	
	FindValue/Text=popStr/TXOP=4 FieldMapDirs
	PopupMenu copy_dir,value= #("\"" + FieldMapList + "\"")
	
	if (strlen(popStr) > 0 && V_Value!=-1)
		FieldMapCopy = popStr
	else
		FieldMapCopy = ""
	endif

End


Window Hall_Probe_Error_Correction() : Panel
	PauseUpdate; Silent 1		// building window...

	if (DataFolderExists("root:varsCAMTO")==0)
		DoAlert 0, "CAMTO variables not found."
		return 
	endif

	//Procura Janela e se estiver aberta, fecha antes de abrir novamente.
	string PanelName
	PanelName = WinList("Hall_Probe_Error_Correction",";","")	
	if (stringmatch(PanelName, "Hall_Probe_Error_Correction;"))
		Killwindow Hall_Probe_Error_Correction
	endif	

	NewPanel/K=1/W=(430,60,710,358)
	SetDrawEnv fillpat= 0
	DrawRect 2, 2, 278,113
	SetDrawEnv fillpat= 0
	DrawRect 2, 113, 278, 206
	SetDrawEnv fillpat= 0
	DrawRect 2, 206, 278, 295
	
	SetVariable ErrAngXZ,pos={26,8},size={228,18},title="Angular Error XZ (°)"
	SetVariable ErrAngYZ,pos={26,32},size={228,18},title="Angular Error YZ (°)"
	SetVariable ErrAngXY,pos={26,56},size={228,18},title="Angular Error XY (°)"
	Button AngularCorrection,pos={15,78},size={250,30},fSize=13,fStyle=1,proc=AngularErrorCorrection,title="Probes Angular Error Correction"
		
	SetVariable ErrDisplacementX,pos={26,126},size={228,18},title="Displacement Error X   (mm)"
	SetVariable ErrDisplacementYZ,pos={26,150},size={228,18},title="Displacement Error YZ (mm)"
	Button DisplacementCorrection,pos={15,172},size={250,30},fSize=13,fStyle=1,proc=DisplacementErrorCorrection,title="Probes Displacement Error Correction"
	
	SetVariable fieldmapdir,pos={15,215},size={255,18},title="Field Map Directory:"
	SetVariable fieldmapdir,noedit=1,value=root:varsCAMTO:FieldMapDir
	TitleBox copy_title,pos={15,242},size={145,18},frame=0,title="Copy Configuration from:"
	PopupMenu copy_dir,pos={160,240},size={110,18},bodyWidth=110,mode=0,proc=CopyHallProbeConfig,title=" "
	Button apply_to_all,pos={15,266},size={255,25},fStyle=1,proc=ApplyErrorCorrectionToAll,title="Apply Error Correction to All Field Maps"

	UpdateFieldMapDirs()
	UpdateHallProbePanel()
		
EndMacro


Function UpdateHallProbePanel()

	string PanelName
	PanelName = WinList("Hall_Probe_Error_Correction",";","")	
	if (stringmatch(PanelName, "Hall_Probe_Error_Correction;")==0)
		return -1
	endif
	
	SVAR df = root:varsCAMTO:FieldMapDir
		
	NVAR FieldMapCount = root:varsCAMTO:FieldMapCount
	
	if (FieldMapCount > 1)
		string FieldMapList = getFieldmapDirs()
		PopupMenu copy_dir,win=Hall_Probe_Error_Correction,disable=0,value= #("\"" + FieldMapList + "\"")
		Button apply_to_all,win=Hall_Probe_Error_Correction,disable=0
	else
		PopupMenu copy_dir,win=Hall_Probe_Error_Correction,disable=2
		Button apply_to_all,win=Hall_Probe_Error_Correction,disable=2
	endif
	
	if (strlen(df) > 0)		
		Button AngularCorrection,win=Hall_Probe_Error_Correction,disable=0
		SetVariable ErrAngXZ,win=Hall_Probe_Error_Correction,value= root:$(df):varsFieldMap:ErrAngXZ
		SetVariable ErrAngYZ,win=Hall_Probe_Error_Correction,value= root:$(df):varsFieldMap:ErrAngYZ
		SetVariable ErrAngXY,win=Hall_Probe_Error_Correction,value= root:$(df):varsFieldMap:ErrAngXY
		
		Button DisplacementCorrection,win=Hall_Probe_Error_Correction,disable=0
		SetVariable ErrDisplacementX ,win=Hall_Probe_Error_Correction,value= root:$(df):varsFieldMap:ErrDisplacementX
		SetVariable ErrDisplacementYZ,win=Hall_Probe_Error_Correction,value= root:$(df):varsFieldMap:ErrDisplacementYZ
	else
		Button AngularCorrection,win=Hall_Probe_Error_Correction,disable=2
		Button DisplacementCorrection,win=Hall_Probe_Error_Correction,disable=2
	endif
	
End


Function CopyHallProbeConfig(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	SelectCopyDirectory(popNum,popStr)
	
	SVAR dfc = root:varsCAMTO:FieldMapCopy
	CopyHallProbeConfig_(dfc)

	UpdateHallProbePanel()

End


Function CopyHallProbeConfig_(dfc)
	string dfc
	
	SVAR df  = root:varsCAMTO:FieldMapDir
	Wave/T FieldMapDirs= root:wavesCAMTO:FieldMapDirs
	
	UpdateFieldMapDirs()	
	FindValue/Text=dfc/TXOP=4 FieldMapDirs
	
	if (V_Value!=-1)
		NVAR temp_df  = root:$(df):varsFieldMap:ErrAngXZ
		NVAR temp_dfc = root:$(dfc):varsFieldMap:ErrAngXZ
		temp_df = temp_dfc
		
		NVAR temp_df  = root:$(df):varsFieldMap:ErrAngYZ
		NVAR temp_dfc = root:$(dfc):varsFieldMap:ErrAngYZ
		temp_df = temp_dfc
		
		NVAR temp_df  = root:$(df):varsFieldMap:ErrAngXY
		NVAR temp_dfc = root:$(dfc):varsFieldMap:ErrAngXY
		temp_df = temp_dfc
		
		NVAR temp_df  = root:$(df):varsFieldMap:ErrDisplacementX
		NVAR temp_dfc = root:$(dfc):varsFieldMap:ErrDisplacementX
		temp_df = temp_dfc		

		NVAR temp_df  = root:$(df):varsFieldMap:ErrDisplacementYZ
		NVAR temp_dfc = root:$(dfc):varsFieldMap:ErrDisplacementYZ
		temp_df = temp_dfc	
		
	else
		DoAlert 0, "Data folder not found."
	endif

End


Function AngularErrorCorrection(ctrlName) : ButtonControl
	String ctrlName

	NVAR NPointsX = :varsFieldMap:NPointsX
	NVAR ErrAngXZ = :varsFieldMap:ErrAngXZ
	NVAR ErrAngYZ = :varsFieldMap:ErrAngYZ
	NVAR ErrAngXY = :varsFieldMap:ErrAngXY	
	NVAR ErrAng   = :varsFieldMap:ErrAng	
		
	if (ErrAng == 0)
	
		print ("Correcting Hall Probe Angular Error")
	
		Wave C_PosX

		string NomeBx
		string NomeBy	
		string NomeBz	
		variable i
	
		for(i=0;i <NPointsX; i=i+1)
			NomeBx ="RaiaBx_X" + num2str(C_PosX[i])
			NomeBy ="RaiaBy_X" + num2str(C_PosX[i])
			NomeBz ="RaiaBz_X" + num2str(C_PosX[i])				

			if (i==0)
				Duplicate/O $NomeBx TmpAngXZ
				Duplicate/O $NomeBy TmpAngYZ
				Duplicate/O $NomeBx TmpAngXY				
			endif
		
			Wave TmpBz = $NomeBz
			Wave TmpBy = $NomeBy			
		
			//Bx - Erro Angular XZ
			TmpAngXZ = TmpBz * sin(ErrAngXZ*pi/180)
		
			//By Erro Angular YZ
			TmpAngYZ = TmpBz * sin(ErrAngYZ*pi/180)		
			
			//Bx Erro Angular XY
			TmpAngXY = TmpBy * sin(ErrAngXY*pi/180)		

			Wave TmpBx = $NomeBx
			Wave TmpBy = $NomeBy
		
			TmpBx = TmpBx - TmpAngXZ - TmpAngXY
			TmpBy = TmpBy - TmpAngYZ		
		endfor
			
		ErrAng = 1
	else
		DoAlert 0,"Hall Probes Angular Error is already corrected."	
	endif
End


Function DisplacementErrorCorrection(ctrlName) : ButtonControl
	string ctrlName

	NVAR StartX   = :varsFieldMap:StartX
	NVAR EndX     = :varsFieldMap:EndX
	NVAR StepsX   = :varsFieldMap:StepsX
	NVAR NPointsX = :varsFieldMap:NPointsX

	NVAR StartYZ   = :varsFieldMap:StartYZ
	NVAR EndYZ     = :varsFieldMap:EndYZ
	NVAR StepsYZ   = :varsFieldMap:StepsYZ
	NVAR NPointsYZ = :varsFieldMap:NPointsYZ	
	
	NVAR ErrDisplacementX  = :varsFieldMap:ErrDisplacementX
	NVAR ErrDisplacementYZ = :varsFieldMap:ErrDisplacementYZ
	NVAR ErrDisplacement   = :varsFieldMap:ErrDisplacement	

	if (ErrDisplacement == 0)
	
		print ("Correcting Hall Probe Displacement Error")
	
		StartX = StartX  + ErrDisplacementX
		EndX  = EndX   + ErrDisplacementX

		StartYZ = StartYZ  + ErrDisplacementYZ
		EndYZ  = EndYZ   + ErrDisplacementYZ
	
		variable i
		string OldNameBx, OldNameBy, OldNameBz
		string TmpNameBx, TmpNameBy, TmpNameBz		
		string NewNameBx, NewNameBy, NewNameBz		
		
		Wave C_PosX
		Duplicate C_PosX New_C_PosX
		for (i=0;i<NPointsX;i+=1)
			New_C_PosX[i] = (StartX + StepsX*i) / 1000 
		endfor
	
		wave C_PosYZ
		for (i=0;i<NPointsYZ;i+=1)
			C_PosYZ[i] = (StartYZ + StepsYZ*i) / 1000
		endfor
	
		for(i=0;i <NPointsX; i=i+1)
			OldNameBx ="RaiaBx_X" + num2str(C_PosX[i])
			OldNameBy ="RaiaBy_X" + num2str(C_PosX[i])
			OldNameBz ="RaiaBz_X" + num2str(C_PosX[i])				
	
			TmpNameBx ="TmpRaiaBx_X" + num2str(New_C_PosX[i])
			TmpNameBy ="TmpRaiaBy_X" + num2str(New_C_PosX[i])
			TmpNameBz ="TmpRaiaBz_X" + num2str(New_C_PosX[i])	
	
			Rename $OldNameBx $TmpNameBx
			Rename $OldNameBy $TmpNameBy
			Rename $OldNameBz $TmpNameBz
		endfor
		
		for(i=0;i <NPointsX; i=i+1)
			TmpNameBx ="TmpRaiaBx_X" + num2str(New_C_PosX[i])
			TmpNameBy ="TmpRaiaBy_X" + num2str(New_C_PosX[i])
			TmpNameBz ="TmpRaiaBz_X" + num2str(New_C_PosX[i])				
			
			NewNameBx ="RaiaBx_X" + num2str(New_C_PosX[i])
			NewNameBy ="RaiaBy_X" + num2str(New_C_PosX[i])
			NewNameBz ="RaiaBz_X" + num2str(New_C_PosX[i])	
	
			Rename $TmpNameBx $NewNameBx
			Rename $TmpNameBy $NewNameBy
			Rename $TmpNameBz $NewNameBz
		endfor
		
	
		C_PosX[] = New_C_PosX[p]
		Killwaves New_C_PosX
			
		ErrDisplacement = 1
		
	else
		DoAlert 0,"Hall Probes Displacement Error is already corrected."	
	endif
	
End


Function ApplyErrorCorrectionToAll(ctrlName) : ButtonControl
	String ctrlName
	
	DoAlert 1, "Apply current error correction to all fieldmaps?"
	if (V_flag != 1)
		return -1
	endif
	
	UpdateFieldMapDirs()
		
	Wave/T FieldMapDirs = root:wavesCAMTO:FieldMapDirs
	NVAR FieldMapCount  = root:varsCAMTO:FieldMapCount
	SVAR FieldMapDir= root:varsCAMTO:FieldMapDir
	
	DFREF df = GetDataFolderDFR()
	string dfc = GetDataFolder(0)
	
	variable i
	string tdf
	string empty = ""

	for (i=0; i < FieldMapCount; i=i+1)
		tdf = FieldMapDirs[i]
		FieldMapDir = tdf
		SetDataFolder root:$(tdf)
		CopyHallProbeConfig_(dfc)
		Print("Applying Hall Probe Error Correction to " + tdf + ":")
		AngularErrorCorrection(empty)
		DisplacementErrorCorrection(empty)
	endfor
	
	FieldMapDir = dfc
	SetDataFolder df

End


Window Integrals_Multipoles() : Panel
	PauseUpdate; Silent 1		// building window...

	if (DataFolderExists("root:varsCAMTO")==0)
		DoAlert 0, "CAMTO variables not found."
		return 
	endif

	//Procura Janela e se estiver aberta, fecha antes de abrir novamente.
	string PanelName
	PanelName = WinList("Integrals_Multipoles",";","")	
	if (stringmatch(PanelName, "Integrals_Multipoles;"))
		Killwindow Integrals_Multipoles
	endif	

	NewPanel/K=1/W=(80,250,407,762)
	SetDrawLayer UserBack
	SetDrawEnv fillpat= 0
	DrawRect 3,4,322,185
	SetDrawEnv fillpat= 0
	DrawRect 3,185,322,260
	SetDrawEnv fillpat= 0
	DrawRect 3,260,322,335
	SetDrawEnv fillpat= 0
	DrawRect 3,335,322,420
	SetDrawEnv fillpat= 0
	DrawRect 3,420,322,508

					
	TitleBox title,pos={60,10},size={127,16},fSize=14,fStyle=1,frame=0, title="Field Integrals and Multipoles"
	TitleBox subtitle,pos={86,30},size={127,16},fSize=14,frame=0, title="K0 to Kx (0 - On, 1 - Off)"

	SetVariable order,pos={10,60},size={220,16},title="Order of Multipolar Analysis:"
	SetVariable dist,pos={10,85},size={221,16},title="Distance for Multipolar Analysis:"	
	TitleBox dist_unit,pos={230,85},size={72,16},title=" mm from center",fSize=12,frame=0

	SetVariable norm_K,pos={10,110},size={220,16},title="Normalize Against K:"
	PopupMenu norm_comp,pos={10,135},size={241,16},proc=PopupMultComponent,title="Component:"
	PopupMenu norm_comp,value= #"\"Normal;Skew\""
	
	TitleBox    grid_title,pos={10, 160},size={90,18},frame=0,title="Horizontal Range:"
	SetVariable grid_min,pos={110,160},limits={-inf, inf, 0},size={95,18},title="Min [mm]:"
	SetVariable grid_max,pos={215,160},limits={-inf, inf, 0},size={95,18},title="Max [mm]:"

	TitleBox    mult_title,pos={10, 190},size={90,18},frame=0,title="Multipoles"
	SetVariable norm_ks,pos={20,210},size={285,16},title="Normal - Ks to Use:"
	SetVariable skew_ks,pos={20,235},size={285,16},title="\t Skew - Ks to Use:"

	TitleBox    res_title,pos={10, 265},size={90,18},frame=0,title="Residual Normalized Multipoles"
	SetVariable res_norm_ks,pos={20,285},size={285,16},title="Normal - Ks to Use:"
	SetVariable res_skew_ks,pos={20,310},size={285,16},title="\t Skew - Ks to Use:"

	Button int_button,pos={12,340},size={300,34},proc=CalcIntegrals,title="Calculate Field Integrals"
	Button int_button,fSize=15,fStyle=1
	Button mult_button,pos={12,380},size={300,34},proc=CalcMultipoles,title="Calculate Multipoles"
	Button mult_button,fSize=15,fStyle=1

	SetVariable fieldmap_dir,pos={10,425},size={300,18},title="Field Map Directory: "
	SetVariable fieldmap_dir,noedit=1,value=root:varsCAMTO:FieldMapDir
	TitleBox copy_title,pos={10,452},size={150,18},frame=0,title="Copy Configuration from:"
	PopupMenu copy_dir,pos={160,450},size={150,18},bodyWidth=145,mode=0,proc=CopyMultipolesConfig,title=" "
	Button apply_to_all,pos={10,476},size={300,25},fStyle=1,proc=CalcIntegralsMultipolesToAll,title="Calculate Integrals and Multipoles for All Field Maps"
	
	UpdateFieldMapDirs()
	UpdateIntegralsMultipolesPanel()
		
EndMacro


Function UpdateIntegralsMultipolesPanel()
	
	string PanelName
	PanelName = WinList("Integrals_Multipoles",";","")	
	if (stringmatch(PanelName, "Integrals_Multipoles;")==0)
		return -1
	endif

	SVAR df = root:varsCAMTO:FieldMapDir
	
	NVAR FieldMapCount = root:varsCAMTO:FieldMapCount
	
	string FieldMapList
	if (FieldMapCount > 1)
		FieldMapList = getFieldmapDirs()
		Button apply_to_all,win=Integrals_Multipoles,disable=0
	else
		FieldMapList = ""
		Button apply_to_all,win=Integrals_Multipoles,disable=2
	endif
	
	if (DataFolderExists("root:Nominal"))
		FieldMapList = "Field Specification;" + FieldMapList
	endif
	
	PopupMenu copy_dir,win=Integrals_Multipoles,disable=0,value= #("\"" + "Multipoles over trajectory;" + FieldMapList + "\"")
	
	if (strlen(df) > 0)
		NVAR FittingOrder = root:$(df):varsFieldMap:FittingOrder
		NVAR NormComponent = root:$(df):varsFieldMap:NormComponent
	
		SetVariable order,win=Integrals_Multipoles,value= root:$(df):varsFieldMap:FittingOrder
		SetVariable dist,win=Integrals_Multipoles,value= root:$(df):varsFieldMap:Distcenter
		SetVariable norm_k,win=Integrals_Multipoles,limits={0,(FittingOrder-1),1},value= root:$(df):varsFieldMap:KNorm
		PopupMenu norm_comp,win=Integrals_Multipoles,disable=0,mode=NormComponent
		
		SetVariable grid_min,win=Integrals_Multipoles,value= root:$(df):varsFieldMap:GridMin
		SetVariable grid_max,win=Integrals_Multipoles,value= root:$(df):varsFieldMap:GridMax
	
		SetVariable norm_ks,win=Integrals_Multipoles, value= root:$(df):varsFieldMap:NormalCoefs	
		SetVariable skew_ks,win=Integrals_Multipoles, value= root:$(df):varsFieldMap:SkewCoefs
				
		SetVariable res_norm_ks, win=Integrals_Multipoles, value= root:$(df):varsFieldMap:ResNormalCoefs
		SetVariable res_skew_ks, win=Integrals_Multipoles, value= root:$(df):varsFieldMap:ResSkewCoefs

		Button mult_button,win=Integrals_Multipoles,disable=0
	else
		PopupMenu norm_comp,win=Integrals_Multipoles,disable=2
		Button mult_button,win=Integrals_Multipoles,disable=2
	endif
	
End


Function CopyMultipolesConfig(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	SVAR df      = root:varsCAMTO:FieldMapDir
	SVAR copydir = root:varsCAMTO:FieldMapCopy
	
	if (cmpstr(popStr, "Multipoles over trajectory") == 0)
	
		NVAR temp_df  = root:$(df):varsFieldMap:FittingOrder
		NVAR temp_dfc = root:$(df):varsFieldMap:FittingOrderTraj
		temp_df = temp_dfc
		
		NVAR temp_df  = root:$(df):varsFieldMap:Distcenter
		NVAR temp_dfc = root:$(df):varsFieldMap:DistcenterTraj
		temp_df = temp_dfc
		
		NVAR temp_df  = root:$(df):varsFieldMap:GridMin
		NVAR temp_dfc = root:$(df):varsFieldMap:GridMinTraj
		temp_df = temp_dfc	

		NVAR temp_df  = root:$(df):varsFieldMap:GridMax
		NVAR temp_dfc = root:$(df):varsFieldMap:GridMaxTraj
		temp_df = temp_dfc	

		NVAR temp_df  = root:$(df):varsFieldMap:KNorm
		NVAR temp_dfc = root:$(df):varsFieldMap:DynKNorm
		temp_df = temp_dfc		

		NVAR temp_df  = root:$(df):varsFieldMap:NormComponent
		NVAR temp_dfc = root:$(df):varsFieldMap:DynNormComponent
		temp_df = temp_dfc	

		SVAR stemp_df  = root:$(df):varsFieldMap:NormalCoefs
		SVAR stemp_dfc = root:$(df):varsFieldMap:DynNormalCoefs
		stemp_df = stemp_dfc

		SVAR stemp_df  = root:$(df):varsFieldMap:SkewCoefs
		SVAR stemp_dfc = root:$(df):varsFieldMap:DynSkewCoefs
		stemp_df = stemp_dfc

		SVAR stemp_df  = root:$(df):varsFieldMap:ResNormalCoefs
		SVAR stemp_dfc = root:$(df):varsFieldMap:DynResNormalCoefs
		stemp_df = stemp_dfc

		SVAR stemp_df  = root:$(df):varsFieldMap:ResSkewCoefs
		SVAR stemp_dfc = root:$(df):varsFieldMap:DynResSkewCoefs
		stemp_df = stemp_dfc
	
	else
	
		string dfc
		if (cmpstr(popStr, "Field Specification") == 0)
			if (DataFolderExists("root:Nominal"))
				dfc = "Nominal"
			else
				DoAlert 0, "Data folder not found."
				return -1
			endif
		else
			SelectCopyDirectory(popNum,popStr)
		
			Wave/T FieldMapDirs= root:wavesCAMTO:FieldMapDirs
			
			UpdateFieldMapDirs()	
			FindValue/Text=copydir/TXOP=4 FieldMapDirs
			if (V_Value==-1)
				DoAlert 0, "Data folder not found."
				return -1
			endif
			
			dfc = copydir
		endif
		
		CopyMultipolesConfig_(dfc)
		
	endif
	
	UpdateIntegralsMultipolesPanel()

End


Function CopyMultipolesConfig_(dfc)
	string dfc
	
	SVAR df = root:varsCAMTO:FieldMapDir
	
	NVAR temp_df  = root:$(df):varsFieldMap:FittingOrder
	NVAR temp_dfc = root:$(dfc):varsFieldMap:FittingOrder
	temp_df = temp_dfc
	
	NVAR temp_df  = root:$(df):varsFieldMap:Distcenter
	NVAR temp_dfc = root:$(dfc):varsFieldMap:Distcenter
	temp_df = temp_dfc
	
	NVAR temp_df  = root:$(df):varsFieldMap:KNorm
	NVAR temp_dfc = root:$(dfc):varsFieldMap:KNorm
	temp_df = temp_dfc		

	NVAR temp_df  = root:$(df):varsFieldMap:NormComponent
	NVAR temp_dfc = root:$(dfc):varsFieldMap:NormComponent
	temp_df = temp_dfc	

	NVAR temp_df  = root:$(df):varsFieldMap:GridMin
	NVAR temp_dfc = root:$(dfc):varsFieldMap:GridMin
	temp_df = temp_dfc	

	NVAR temp_df  = root:$(df):varsFieldMap:GridMax
	NVAR temp_dfc = root:$(dfc):varsFieldMap:GridMax
	temp_df = temp_dfc	

	SVAR stemp_df  = root:$(df):varsFieldMap:NormalCoefs
	SVAR stemp_dfc = root:$(dfc):varsFieldMap:NormalCoefs
	stemp_df = stemp_dfc

	SVAR stemp_df  = root:$(df):varsFieldMap:SkewCoefs
	SVAR stemp_dfc = root:$(dfc):varsFieldMap:SkewCoefs
	stemp_df = stemp_dfc

	SVAR stemp_df  = root:$(df):varsFieldMap:ResNormalCoefs
	SVAR stemp_dfc = root:$(dfc):varsFieldMap:ResNormalCoefs
	stemp_df = stemp_dfc

	SVAR stemp_df  = root:$(df):varsFieldMap:ResSkewCoefs
	SVAR stemp_dfc = root:$(dfc):varsFieldMap:ResSkewCoefs
	stemp_df = stemp_dfc

End

Function PopupMultComponent(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	NVAR NormComponent = :varsFieldMap:NormComponent
	NormComponent = popNum
	
End


Function CalcIntegrals(ctrlName) : ButtonControl
	String ctrlName
	print ("Calculating Field Integrals")

	variable timerRefNum, calc_time
	timerRefNum = StartMSTimer

	IntegralsCalculation()
	UpdateResultsPanel()
	
	calc_time = StopMSTimer(timerRefNum)
	Print "Elapsed time :", calc_time*(10^(-6)), " seconds"
	
End


Function CalcMultipoles(ctrlName) : ButtonControl
	String ctrlName
	print ("Calculating Field Multipoles")

	variable timerRefNum, calc_time
	timerRefNum = StartMSTimer

	MultipolarFitting()
	ResidualMultipolesCalc()
	UpdateResultsPanel()
	
	calc_time = StopMSTimer(timerRefNum)
	Print "Elapsed time :", calc_time*(10^(-6)), " seconds"
	
End


Function IntegralsCalculation()

	SVAR df = root:varsCAMTO:FieldMapDir
      
	NVAR NPointsX = :varsFieldMap:NPointsX
	NVAR NPointsYZ = :varsFieldMap:NPointsYZ	

	variable i, j
	string Raia
 	string RaiaInt
 	
 	Wave C_PosX
 	
	Make/D/O/N=(NPointsX) IntBx_X	
	Make/D/O/N=(NPointsX) IntBy_X	
	Make/D/O/N=(NPointsX) IntBz_X	

	Make/D/O/N=(NPointsX) Int2Bx_X	
	Make/D/O/N=(NPointsX) Int2By_X	
	Make/D/O/N=(NPointsX) Int2Bz_X	
	
	//Primeira Integral
	for (j=0;j<NPointsX;j=j+1)
		Raia = "RaiaBx_X" + num2str(C_PosX[j]) 
		RaiaInt = "RaiaBx_X" + num2str(C_PosX[j]) + "_int"
		Wave Tmp = $Raia
		Integrate/METH=1 Tmp/X=C_PosYZ/D=$RaiaInt
		Wave Tmp = $RaiaInt		
		IntBx_X[j] = Tmp[NPointsYZ]
		
		Raia = "RaiaBy_X" + num2str(C_PosX[j])
		RaiaInt = "RaiaBy_X" + num2str(C_PosX[j]) + "_int"
		Wave Tmp = $Raia
		Integrate/METH=1 Tmp/X=C_PosYZ/D=$RaiaInt
		Wave Tmp = $RaiaInt				
		IntBy_X[j] = Tmp[NPointsYZ]				

		Raia = "RaiaBz_X" + num2str(C_PosX[j])
		RaiaInt = "RaiaBz_X" + num2str(C_PosX[j]) + "_int"
		Wave Tmp = $Raia
		Integrate/METH=1 Tmp/X=C_PosYZ/D=$RaiaInt		
		Wave Tmp = $RaiaInt				
		IntBz_X[j] = Tmp[NPointsYZ]		
	endfor	
	
	//Segunda Integral
	for (j=0;j<NPointsX;j=j+1)
		Raia = "RaiaBx_X" + num2str(C_PosX[j])  + "_int"
		RaiaInt = "RaiaBx_X" + num2str(C_PosX[j]) + "_int2"
		Wave Tmp = $Raia
		Integrate/METH=1 Tmp/X=C_PosYZ/D=$RaiaInt
		Wave Tmp = $RaiaInt	
		Int2Bx_X[j] = Tmp[NPointsYZ]	
		
		Raia = "RaiaBy_X" + num2str(C_PosX[j]) + "_int"
		RaiaInt = "RaiaBy_X" + num2str(C_PosX[j]) + "_int2"
		Wave Tmp = $Raia
		Integrate/METH=1 Tmp/X=C_PosYZ/D=$RaiaInt		
		Wave Tmp = $RaiaInt
		Int2By_X[j] = Tmp[NPointsYZ]

		Raia = "RaiaBz_X" + num2str(C_PosX[j]) + "_int"
		RaiaInt = "RaiaBz_X" + num2str(C_PosX[j]) + "_int2"
		Wave Tmp = $Raia
		Integrate/METH=1 Tmp/X=C_PosYZ/D=$RaiaInt					
		Wave Tmp = $RaiaInt		
		Int2Bz_X[j] = Tmp[NPointsYZ]						
	endfor	
	
End


Function EquallySpaced(w)
	Wave w
	
	variable i, tol
	variable step, prev_step, eq_step
	
	tol = 1e-10
	eq_step = 1
	prev_step = w(1) - w(0)
	
	for(i=1; i<numpnts(w)-1; i=i+1)
		step = w(i+1) - w(i)
		if (Abs(step - prev_step) > tol)
			eq_step = 0
			break
		endif
		prev_step = step
	endfor
	
	return eq_step
End


#if Exists("Calc2DSplineInterpolant")

	Function CalcFieldmapInterpolant()
		
		NVAR BeamDirection = :varsFieldMap:BeamDirection
		NVAR StartX    = :varsFieldMap:StartX
		NVAR EndX      = :varsFieldMap:EndX
		NVAR StepsX    = :varsFieldMap:StepsX
		NVAR NPointsX  = :varsFieldMap:NPointsX
		NVAR StartYZ   = :varsFieldMap:StartYZ
		NVAR EndYZ     = :varsFieldMap:EndYZ
		NVAR StepsYZ   = :varsFieldMap:StepsYZ
		NVAR NPointsYZ = :varsFieldMap:NPointsYZ	
		
		variable calc_interpolant_flag
		string nome
		variable i, j, k
	
		Wave C_PosX
		Wave C_PosYZ
		
		if (EquallySpaced(C_PosX) == 0)
			return 0
		endif
		
		if (EquallySpaced(C_PosYZ) == 0)
			return 0
		endif
	
		Make/D/O/N=(NPointsX*NPointsYZ) NewWave0, NewWave1, NewWave2, NewWave3, NewWave4, NewWave5
		
		k =0
		for (i=0;i<NPointsYZ;i=i+1)
			for (j=0;j<NpointsX;j=j+1)
	
				NewWave0[k] = StartX + j*StepsX		
				if (BeamDirection == 1)
					NewWave1[k] = StartYZ + i*StepsYZ
					NewWave2[k] = 0
				else
					NewWave1[k] = 0
					NewWave2[k] = StartYZ + i*StepsYZ			
				endif
				
				Wave Tmp = $"RaiaBx_X" + num2str(NewWave0[k]/1000)
				NewWave3[k] = Tmp[i]
	
				Wave Tmp = $"RaiaBy_X" + num2str(NewWave0[k]/1000)
				NewWave4[k] = Tmp[i]
	
				Wave Tmp = $"RaiaBz_X" + num2str(NewWave0[k]/1000)
				NewWave5[k] = Tmp[i]
				
				k = k + 1
			endfor
		endfor
		
		NewWave0[] = NewWave0[p]/1000
		NewWave1[] = NewWave1[p]/1000
	 	NewWave2[] = NewWave2[p]/1000
	
	 	if (BeamDirection == 1)
			calc_interpolant_flag = Calc2DSplineInterpolant(NewWave0, NewWave1, NewWave3, NewWave4, NewWave5)	
		else
			calc_interpolant_flag = Calc2DSplineInterpolant(NewWave0, NewWave2, NewWave3, NewWave4, NewWave5)		
		endif
	 			
		Killwaves/Z NewWave0
		Killwaves/Z NewWave1
		Killwaves/Z NewWave2
		Killwaves/Z NewWave3
		Killwaves/Z NewWave4
		Killwaves/Z NewWave5
					
		return calc_interpolant_flag		
	End

	
	ThreadSafe Function/Wave GetPerpendicularField(index, DeflectionAngle, PosX, PosYZ, GridX)
		Variable index, DeflectionAngle, PosX, PosYZ
		Wave GridX
		
		Make/D/O/N=3 MagField
		variable RotX, RotYZ
		
		RotX   = PosX   + GridX[index]*cos(DeflectionAngle)
		RotYZ = PosYZ + GridX[index]*sin(DeflectionAngle)
		MagField[0] = GetFieldX(RotX, RotYZ)
		MagField[1] = GetFieldY(RotX, RotYZ)
		MagField[2] = GetFieldZ(RotX, RotYZ)
		
		return MagField	
		
	End

#else

	Function CalcFieldmapInterpolant()
		return 0
	End Function
	
	
	ThreadSafe Function/Wave GetPerpendicularField(index, DeflectionAngle, PosX, PosYZ, GridX)
		Variable index, DeflectionAngle, PosX, PosYZ
		Wave GridX
		Make/D/O/N=3 MagField
		return MagField	
	End

#endif


Function/Wave GetPerpendicularFieldST(index, DeflectionAngle, PosX, PosYZ, GridX)
	Variable index, DeflectionAngle, PosX, PosYZ
	Wave GridX
	
	NVAR FieldX = :varsFieldMap:FieldX
	NVAR FieldY = :varsFieldMap:FieldY
	NVAR FieldZ = :varsFieldMap:FieldZ
	
	Make/D/O/N=3 MagField
	variable RotX, RotYZ
	
	RotX   = PosX   + GridX[index]*cos(DeflectionAngle)
	RotYZ = PosYZ + GridX[index]*sin(DeflectionAngle)

	Campo_espaco(RotX, RotYZ)
		
	MagField[0] = FieldX
	MagField[1] = FieldY
	MagField[2] = FieldZ
	
	return MagField	
	
End


Function MultipolarFitting([ReloadField])
   variable ReloadField
   
	Wave C_PosX
	Wave C_PosYZ
	
	NVAR NPointsX      = :varsFieldMap:NPointsX
	NVAR NPointsYZ     = :varsFieldMap:NPointsYZ	
	NVAR GridMin       = :varsFieldMap:GridMin
	NVAR GridMax       = :varsFieldMap:GridMax
	NVAR BeamDirection = :varsFieldMap:BeamDirection
	NVAR FittingOrder  = :varsFieldMap:FittingOrder
	NVAR Distcenter    = :varsFieldMap:Distcenter
	NVAR KNorm         = :varsFieldMap:KNorm
	NVAR NormComponent = :varsFieldMap:NormComponent
	SVAR NormalCoefs   = :varsFieldMap:NormalCoefs
	SVAR SkewCoefs     = :varsFieldMap:SkewCoefs
      
	variable i,j, n

	if (ParamIsDefault(ReloadField))
		ReloadField = 1
	endif	

	if (ReloadField)
		print ("Reloading Field Data...")
		variable spline_flag
		spline_flag = CalcFieldmapInterpolant()
		
		if(spline_flag == 1)
			print("Field data successfully reloaded.")
		else
			print("Problem with cubic spline XOP. Using single thread calculation.")
		endif
	endif
	
	variable imin = 0
	for (i=0; i<NPointsX; i=i+1)
		if (C_PosX[i] > GridMin/1000)
			break
		elseif (C_PosX[i] == GridMin/1000)
			imin = i
		else
			imin = i+1
		endif
	endfor
	
	variable imax = NPointsX	
	for (i=(NPointsX-1); i>=0; i=i-1)
		if (C_PosX[i] < GridMax/1000)
			break
		elseif (C_PosX[i] == GridMax/1000)
			imax = i
		else
			imax = i-1
		endif
	endfor

	Duplicate/O/R=(imin, imax) C_PosX Mult_Grid

	Make/O/D/N=(numpnts(Mult_Grid),3) Field_Perp	
	Make/O/D/N=(NPointsYZ) Temp
	Make/O/D/N=(NPointsYZ, FittingOrder) Mult_Normal, Mult_Skew
	Make/O/D/N=(FittingOrder) Mult_Normal_Int, Mult_Skew_Int
	Make/O/D/N=(FittingOrder) W_coef, W_sigma

	K0 = 0;K1 = 0;K2 = 0;K3 = 0;K4 = 0;K5 = 0;K6 = 0;K7 = 0;K8 = 0;K9 = 0;K10 = 0;
	K11 = 0;K12 = 0;K13 = 0;K14 = 0;K15 = 0;K16 = 0;K17 = 0;K18 = 0;K19 = 0 

	variable skew_idx = 0
	variable normal_idx
	
	if (BeamDirection == 1)
		normal_idx = 2
	else
		normal_idx = 1
	endif

	variable normal_on = 0
	for (j=0; j<FittingOrder; j=j+1)
		if (cmpstr(NormalCoefs[j],"0")==0)
			normal_on = 1
			break
		endif
	endfor

	variable skew_on = 0
	for (j=0; j<FittingOrder; j=j+1)
		if (cmpstr(SkewCoefs[j],"0")==0)
			skew_on = 1
			break
		endif
	endfor

	for (i=0; i<NPointsYZ; i=i+1)
		
		if (spline_flag == 1)
			Multithread Field_Perp[][] = GetPerpendicularField(x, 0, 0, C_PosYZ[i], Mult_Grid)(q)
		else
			Field_Perp[][] = GetPerpendicularFieldST(x, 0, 0, C_PosYZ[i], Mult_Grid)(q)
		endif
		
		K0 = 0;K1 = 0;K2 = 0;K3 = 0;K4 = 0;K5 = 0;K6 = 0;K7 = 0;K8 = 0;K9 = 0;K10 = 0;
		K11 = 0;K12 = 0;K13 = 0;K14 = 0;K15 = 0;K16 = 0;K17 = 0;K18 = 0;K19 = 0 
		
		W_coef[] = 0
		if (normal_on == 1)
			CurveFit/L=(NPointsX)/H=NormalCoefs/N=1/Q poly FittingOrder, Field_Perp[][normal_idx] /X=Mult_Grid/D
		endif
		Mult_Normal[i][] = W_coef[q]

		K0 = 0;K1 = 0;K2 = 0;K3 = 0;K4 = 0;K5 = 0;K6 = 0;K7 = 0;K8 = 0;K9 = 0;K10 = 0;
		K11 = 0;K12 = 0;K13 = 0;K14 = 0;K15 = 0;K16 = 0;K17 = 0;K18 = 0;K19 = 0 

		W_coef[] = 0
		if (skew_on == 1)
			CurveFit/L=(NPointsX)/H=SkewCoefs/N=1/Q poly FittingOrder, Field_Perp[][skew_idx] /X=Mult_Grid/D
		endif
		Mult_Skew[i][] = W_coef[q]
		
	endfor
	
	for (n=0; n<FittingOrder; n=n+1)
	   	Temp[] = Mult_Normal[p][n]
		Integrate/METH=1 Temp/X=C_PosYZ/D=Temp_Integral
		Mult_Normal_Int[n] = Temp_Integral[NPointsYZ]
		
		Temp[] = Mult_Skew[p][n]
		Integrate/METH=1 Temp/X=C_PosYZ/D=Temp_Integral
		Mult_Skew_Int[n] = Temp_Integral[NPointsYZ]
		
	endfor
		
	Duplicate/D/O Mult_Normal_Int Mult_Normal_Norm
	Duplicate/D/O Mult_Skew_Int   Mult_Skew_Norm

	if (NormComponent == 2) 
		for (n=0;n<FittingOrder;n=n+1)
			Mult_Normal_Norm[n] = ( ( Mult_Normal_Int[n] / Mult_Skew_Int[KNorm] ) * (Distcenter/1000)^(n-KNorm) )
			Mult_Skew_Norm[n]   = ( ( Mult_Skew_Int[n]   / Mult_Skew_Int[KNorm] ) * (Distcenter/1000)^(n-KNorm) )				
		endfor
	else
		for (n=0;n<FittingOrder;n=n+1)
			Mult_Normal_Norm[n] = ( ( Mult_Normal_Int[n] / Mult_Normal_Int[KNorm] ) * (Distcenter/1000)^(n-KNorm) )
			Mult_Skew_Norm[n]   = ( ( Mult_Skew_Int[n]   / Mult_Normal_Int[KNorm] ) * (Distcenter/1000)^(n-KNorm) )		
		endfor
	endif
		
	Killwaves/Z W_coef, W_sigma, W_ParamConfidenceInterval, fit_Field_Perp
	Killwaves/Z Field_Perp, Temp_Integral, Temp
		
End


Function ResidualMultipolesCalc()

   	NVAR BeamDirection 	= :varsFieldMap:BeamDirection
	NVAR NPointsX 		= :varsFieldMap:NPointsX
	NVAR GridMin			= :varsFieldMap:GridMin
	NVAR GridMax			= :varsFieldMap:GridMax
	NVAR FittingOrder 	= :varsFieldMap:FittingOrder
	NVAR NormComponent	= :varsFieldMap:NormComponent
	NVAR KNorm			= :varsFieldMap:KNorm
	SVAR ResNormalCoefs	= :varsFieldMap:ResNormalCoefs
	SVAR ResSkewCoefs  	= :varsFieldMap:ResSkewCoefs

	print ("Calculating Field Residual Multipoles")
	       
	Wave C_PosX
	Wave Mult_Normal_Int
	Wave Mult_Skew_Int  

	variable BNorm 
	if (NormComponent == 2)
		BNorm = Mult_Skew_Int[KNorm]
	else
		BNorm = Mult_Normal_Int[KNorm]
	endif

	Make/D/O/N=(NPointsX) Temp_Normal = 0
	Make/D/O/N=(NPointsX) Temp_Skew   = 0
	
	variable i		

	for(i=0;i<FittingOrder;i+=1)
	
		if (stringmatch(ResNormalCoefs[i], "0"))
			Temp_Normal += (Mult_Normal_Int[i]/BNorm)*(C_PosX ^ (i-KNorm))
		endif
		
		if (stringmatch(ResSkewCoefs[i], "0"))
			Temp_Skew += (Mult_Skew_Int[i]/BNorm)*(C_PosX ^ (i-KNorm))
		endif
	
	endfor			
	
	for (i=0; i<NPointsX; i=i+1)
		if (numtype(Temp_Normal[i]) == 1)
			Temp_Normal[i] = NaN
		endif
		
		if (numtype(Temp_Skew[i]) == 1)
			Temp_Skew[i] = NaN
		endif

	endfor
	
	variable imin = 0
	for (i=0; i<NPointsX; i=i+1)
		if (C_PosX[i] > GridMin/1000)
			break
		elseif (C_PosX[i] == GridMin/1000)
			imin = i
		else
			imin = i+1
		endif
	endfor
	
	variable imax = NPointsX	
	for (i=(NPointsX-1); i>=0; i=i-1)
		if (C_PosX[i] < GridMax/1000)
			break
		elseif (C_PosX[i] == GridMax/1000)
			imax = i
		else
			imax = i-1
		endif
	endfor

	Duplicate/O/R=(imin, imax) Temp_Normal Mult_Normal_Res
	Duplicate/O/R=(imin, imax) Temp_Skew   Mult_Skew_Res
	
	Killwaves/Z Temp_Normal
	Killwaves/Z Temp_Skew
	
End


Function CalcIntegralsMultipolesToAll(ctrlName) : ButtonControl
	String ctrlName
	
	DoAlert 1, "Calculate multipoles for all fieldmaps?"
	if (V_flag != 1)
		return -1
	endif
	
	UpdateFieldMapDirs()
		
	Wave/T FieldMapDirs = root:wavesCAMTO:FieldMapDirs
	NVAR FieldMapCount  = root:varsCAMTO:FieldMapCount
	SVAR FieldMapDir= root:varsCAMTO:FieldMapDir
		
	DFREF df = GetDataFolderDFR()
	string dfc = GetDataFolder(0)
	
	variable i
	string tdf
	string empty = ""

	for (i=0; i < FieldMapCount; i=i+1)
		tdf = FieldMapDirs[i]
		FieldMapDir = tdf
		SetDataFolder root:$(tdf)
		CopyMultipolesConfig_(dfc)
		Print("Calculating Integrals and Multipoles for " + tdf + ":")
		CalcIntegrals(empty)
		CalcMultipoles(empty)
	endfor

	FieldMapDir = dfc
	SetDataFolder df
	
End

Function Particle_Energy()
	
	NVAR EnergyGeV = root:varsCAMTO:EnergyGeV
	NVAR FieldMapCount = root:varsCAMTO:FieldMapCount
	
	Wave/T FieldMapDirs = root:wavesCAMTO:FieldMapDirs 
	Wave/Z EnergiesGeV = root:wavesCAMTO:EnergiesGeV
	
	if (WaveExists(EnergiesGeV) == 0)
		Make/O/N=(FieldMapCount) root:wavesCAMTO:EnergiesGeV = EnergyGeV
		Wave EnergiesGeV = root:wavesCAMTO:EnergiesGeV
	endif
	
	Edit/K=1 FieldMapDirs, EnergiesGeV
	
End


Window Trajectories() : Panel
	PauseUpdate; Silent 1		// building window...

	if (DataFolderExists("root:varsCAMTO")==0)
		DoAlert 0, "CAMTO variables not found."
		return 
	endif

	//Procura Janela e se estiver aberta, fecha antes de abrir novamente.
	string PanelName
	PanelName = WinList("Trajectories",";","")	
	if (stringmatch(PanelName, "Trajectories;"))
		Killwindow Trajectories
	endif		

	NewPanel/K=1/W=(440,250,750,700)
	SetDrawLayer UserBack
	SetDrawEnv fillpat= 0
	DrawRect 5,2,304,40
	SetDrawEnv fillpat= 0
	DrawRect 5,40,304,77
	SetDrawEnv fillpat= 0
	DrawRect 5,77,304,111
	SetDrawEnv fillpat= 0
	DrawRect 5,111,304,201
	SetDrawEnv fillpat= 0
	DrawRect 5,201,304,257
	SetDrawEnv fillpat= 0
	DrawRect 5,257,304,318
	SetDrawEnv fillpat= 0
	DrawRect 5,318,304,355
	SetDrawEnv fillpat= 0
	DrawRect 5,355,304,445
			
	PopupMenu popupSingleMulti,pos={38,11},size={224,23},proc=PopupSingleMulti,title="Number of Particles:"
	PopupMenu popupSingleMulti,mode=1,popvalue="Single-Particle",value= #"\"Single-Particle;Multi-Particles\""
		
	CheckBox check_field,pos={15,51},size={286,15},title="Use constant field if trajectory is out of field matrix"
	
	SetVariable trajstartx1,pos={26,86},size={250,18},title="Entrance Angle XY(Z) [°]:"
	SetVariable trajstartx,pos={26,122},size={250,18},title="Multi-Particle Start X [mm]:"
	SetVariable trajendx,pos={26,149},size={250,18},title="Multi-Particle End X [mm]:"
	SetVariable trajstepsx,pos={26,176},size={250,18},title="Multi-Particle Steps X [mm]:"
	
	SetVariable trajstartyz,pos={25,211},size={250,18},title="Start Particle YZ [mm]:"
	SetVariable trajendyz,pos={25,235},size={250,18},title="End Particle YZ [mm]:"

	PopupMenu popupAnalitico_RungeKutta,pos={38,264},size={220,23},proc=PopupAnalitico_RungeKutta,title="Calculation Method:"
	PopupMenu popupAnalitico_RungeKutta,mode=2,popvalue="Analytical",value= #"\"Analytical;Runge_Kutta_1º\""
	
	CheckBox check_negpostraj,pos={30,290},size={286,15},title="Calculate negative and positive trajectories"
	
	Button CalcTraj,pos={27,325},size={250,25},proc=TrajectoriesCalculationProc,title="Trajectories Calculation"
	Button CalcTraj,fSize=15,fStyle=1
			
	SetVariable fieldmapdir,pos={15,360},size={280,18},title="Field Map Directory: "
	SetVariable fieldmapdir,noedit=1,value=root:varsCAMTO:FieldMapDir
	TitleBox copy_title,pos={15,390},size={145,18},frame=0,title="Copy Configuration from:"
	PopupMenu copy_dir,pos={160,388},size={135,18},bodyWidth=135,mode=0,proc=CopyTrajectoriesConfig,title=" "
	Button apply_to_all,pos={15,414},size={280,25},fStyle=1,proc=CalcTrajectoriesToAll,title="Calculate Trajectories for All Field Maps"

	UpdateFieldMapDirs()
	UpdateTrajectoriesPanel()
	
EndMacro


Function UpdateTrajectoriesPanel()
	
	string PanelName
	PanelName = WinList("Trajectories",";","")	
	if (stringmatch(PanelName, "Trajectories;")==0)
		return -1
	endif
	
	SVAR df = root:varsCAMTO:FieldMapDir
	
	NVAR FieldMapCount = root:varsCAMTO:FieldMapCount
	if (FieldMapCount > 1)
		string FieldMapList = getFieldmapDirs()
		PopupMenu copy_dir,win=Trajectories,disable=0,value= #("\"" + FieldMapList + "\"")
		Button apply_to_all,win=Trajectories,disable=0
	else
		PopupMenu copy_dir,win=Trajectories,disable=2		
		Button apply_to_all,win=Trajectories,disable=2
	endif
		
	if (strlen(df) > 0)
	
		NVAR Single_Multi = root:$(df):varsFieldMap:Single_Multi
		NVAR Checkfield = root:$(df):varsFieldMap:Checkfield
		NVAR CheckNegPosTraj = root:$(df):varsFieldMap:CheckNegPosTraj
		NVAR Analitico_RungeKutta = root:$(df):varsFieldMap:Analitico_RungeKutta
				
		Button CalcTraj,win=Trajectories,disable=0
		
		PopupMenu popupSingleMulti,win=Trajectories,disable=0, mode=Single_Multi
		
		CheckBox check_field,win=Trajectories,disable=0, variable=root:$(df):varsFieldMap:Checkfield, value=Checkfield
		CheckBox check_negpostraj,win=Trajectories,disable=0, variable=root:$(df):varsFieldMap:CheckNegPosTraj, value=CheckNegPosTraj
		
		SetVariable trajstartx1,win=Trajectories,value= root:$(df):varsFieldMap:EntranceAngle
		SetVariable trajstartx,win=Trajectories, value= root:$(df):varsFieldMap:StartXTraj
		SetVariable trajendx,win=Trajectories,   value= root:$(df):varsFieldMap:EndXTraj
		SetVariable trajstepsx,win=Trajectories, value= root:$(df):varsFieldMap:StepsXTraj
		
		SetVariable trajstartyz,win=Trajectories,value= root:$(df):varsFieldMap:StartYZTraj
		SetVariable trajendyz,win=Trajectories,  value= root:$(df):varsFieldMap:EndYZTraj	
	
		PopupMenu popupAnalitico_RungeKutta,win=Trajectories,disable=0,mode=Analitico_RungeKutta

		if (Single_Multi == 1)
			SetVariable trajendx,win=Trajectories, disable = 2
			SetVariable trajstepsx,win=Trajectories, disable = 2
		else
			SetVariable trajendx,win=Trajectories, disable = 0
			SetVariable trajstepsx,win=Trajectories, disable = 0
		endif
	
	else
	
		PopupMenu popupSingleMulti,win=Trajectories,disable=2
		CheckBox check_field,win=Trajectories,disable=2
		CheckBox check_negpostraj,win=Trajectories,disable=2
		PopupMenu popupAnalitico_RungeKutta,win=Trajectories,disable=2
		Button CalcTraj,win=Trajectories,disable=2
		
	endif
		
End


Function CopyTrajectoriesConfig(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	SelectCopyDirectory(popNum,popStr)

	SVAR dfc = root:varsCAMTO:FieldMapCopy
	CopyTrajectoriesConfig_(dfc)
	
	UpdateTrajectoriesPanel()

End


Function CopyTrajectoriesConfig_(dfc)
	string dfc
	
	SVAR df  = root:varsCAMTO:FieldMapDir
	Wave/T FieldMapDirs= root:wavesCAMTO:FieldMapDirs
	
	UpdateFieldMapDirs()	
	FindValue/Text=dfc/TXOP=4 FieldMapDirs
	
	if (V_Value!=-1)	
		NVAR temp_df  = root:$(df):varsFieldMap:Single_Multi
		NVAR temp_dfc = root:$(dfc):varsFieldMap:Single_Multi
		temp_df = temp_dfc
		
		NVAR temp_df  = root:$(df):varsFieldMap:Checkfield
		NVAR temp_dfc = root:$(dfc):varsFieldMap:Checkfield
		temp_df = temp_dfc		

		NVAR temp_df  = root:$(df):varsFieldMap:CheckNegPosTraj
		NVAR temp_dfc = root:$(dfc):varsFieldMap:CheckNegPosTraj
		temp_df = temp_dfc	

		NVAR temp_df  = root:$(df):varsFieldMap:Analitico_RungeKutta
		NVAR temp_dfc = root:$(dfc):varsFieldMap:Analitico_RungeKutta
		temp_df = temp_dfc		
		
		NVAR temp_df  = root:$(df):varsFieldMap:EntranceAngle
		NVAR temp_dfc = root:$(dfc):varsFieldMap:EntranceAngle
		temp_df = temp_dfc		

		NVAR temp_df  = root:$(df):varsFieldMap:StartXTraj
		NVAR temp_dfc = root:$(dfc):varsFieldMap:StartXTraj
		temp_df = temp_dfc		
		
		NVAR temp_df  = root:$(df):varsFieldMap:EndXTraj
		NVAR temp_dfc = root:$(dfc):varsFieldMap:EndXTraj
		temp_df = temp_dfc		

		NVAR temp_df  = root:$(df):varsFieldMap:StepsXTraj
		NVAR temp_dfc = root:$(dfc):varsFieldMap:StepsXTraj
		temp_df = temp_dfc		
		
		NVAR temp_df  = root:$(df):varsFieldMap:StartYZTraj
		NVAR temp_dfc = root:$(dfc):varsFieldMap:StartYZTraj
		temp_df = temp_dfc		

		NVAR temp_df  = root:$(df):varsFieldMap:EndYZTraj	
		NVAR temp_dfc = root:$(dfc):varsFieldMap:EndYZTraj	
		temp_df = temp_dfc		
				
	else
		DoAlert 0, "Data folder not found."
	endif
		
End


Function PopupSingleMulti(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	NVAR Single_Multi = :varsFieldMap:Single_Multi
	Single_Multi = popNum
	
	if (popnum == 1)
		SetVariable trajendx disable = 2
		SetVariable trajstepsx disable = 2	
	else
		SetVariable trajendx disable = 0
		SetVariable trajstepsx disable = 0
	endif
End


Function PopupAnalitico_RungeKutta(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	NVAR Analitico_RungeKutta = :varsFieldMap:Analitico_RungeKutta
	Analitico_RungeKutta = popNum
	
End


Function MakeTrajNamesWave(pos_str)
	string pos_str
	
	Make/O/T/N=(9) TrajNames
	TrajNames[0] = "TrajX" + pos_str
	TrajNames[1] = "TrajY" + pos_str
	TrajNames[2] = "TrajZ" + pos_str
	TrajNames[3] = "Vel_X" + pos_str
	TrajNames[4] = "Vel_Y" + pos_str
	TrajNames[5] = "Vel_Z" + pos_str
	TrajNames[6] = "VetorCampoX" + pos_str
	TrajNames[7] = "VetorCampoY" + pos_str	
	TrajNames[8] = "VetorCampoZ" + pos_str
				
End


Function GetParticleEnergy()
	NVAR EnergyGev  = root:varsCAMTO:EnergyGev
	Wave/Z EnergiesGeV = root:wavesCAMTO:EnergiesGeV
	
	if (WaveExists(EnergiesGeV)==1)
		variable idx = GetFieldMapIndex()
		if (idx == -1)
			return EnergyGeV
		endif
		return EnergiesGeV[idx]
	
	else
		return EnergyGeV
	
	endif

End


Function TrajectoriesCalculationProc(ctrlName) : ButtonControl
	String ctrlName
   
   	NVAR Charge     = root:varsCAMTO:Charge
	NVAR Mass       = root:varsCAMTO:Mass
	NVAR LightSpeed = root:varsCAMTO:LightSpeed
	
	variable energy = GetParticleEnergy()

	variable TotalEnergy_J  = energy*1E9*abs(Charge)
	variable Gama  = TotalEnergy_J / (Mass * LightSpeed^2)
	variable ChargeVel = ((1 - 1/Gama^2)*LightSpeed^2)^0.5
   
   NVAR CheckNegPosTraj = :varsFieldMap:CheckNegPosTraj
	NVAR Single_Multi  = :varsFieldMap:Single_Multi   
	NVAR BeamDirection = :varsFieldMap:BeamDirection    	
	
	NVAR StartXTraj    = :varsFieldMap:StartXTraj 
	NVAR EndXTraj      = :varsFieldMap:EndXTraj 
	NVAR StepsXTraj    = :varsFieldMap:StepsXTraj 
	NVAR NPointsXTraj  = :varsFieldMap:NPointsXTraj

	NVAR StartYZTraj = :varsFieldMap:StartYZTraj 
	NVAR EndYZTraj   = :varsFieldMap:EndYZTraj
	NVAR iTraj       = :varsFieldMap:iTraj 	

	variable i, j, initial_endyz
	string pos_str, add_str_1, add_str_2
	string NameTraj, NameTrajInt, NameTrajInt2, NameTrajPos, NameTrajTmp1, NameTrajTmp2
	
	initial_endyz = EndYZTraj
	
	if (CheckNegPosTraj == 1)
		if (StartYZTraj != 0)
			DoAlert 0, "The initial longitudinal position must be zero."
			return -1
		endif
	
		add_str_1 = "_Tmp1"
		add_str_2 = "_Tmp2"
					
		TrajectoriesCalculation()
		wave PosXTraj

		for (j=0; j<NPointsXTraj; j+=1)				
			pos_str = num2str(PosXTraj[j])
			MakeTrajNamesWave(pos_str)
			Wave/T TrajNames
			
			for (i=0; i<numpnts(TrajNames); i+=1)
				NameTraj = TrajNames[i]
				NameTrajTmp1 = NameTraj + add_str_1		
				if (StartYZTraj > EndYZTraj)
					Duplicate/D/O/R=(1, numpnts($NameTraj)) $NameTraj $NameTrajTmp1	
					Reverse $NameTrajTmp1
				else
					Duplicate/D/O $NameTraj $NameTrajTmp1	
				endif
			endfor
			
		endfor

		EndYZTraj = -EndYZTraj
		TrajectoriesCalculation()
	
		for (j=0; j<NPointsXTraj; j+=1)		
			pos_str = num2str(PosXTraj[j])
			MakeTrajNamesWave(pos_str)
			Wave/T TrajNames
			
			for (i=0; i<numpnts(TrajNames); i+=1)
				NameTraj = TrajNames[i]
				NameTrajTmp2 = NameTraj + add_str_2		
				if (StartYZTraj > EndYZTraj)
					Duplicate/D/O/R=(1, numpnts($NameTraj)) $NameTraj $NameTrajTmp2	
					Reverse $NameTrajTmp2
				else
					Duplicate/D/O $NameTraj $NameTrajTmp2
				endif
			endfor				
			
		endfor
		
		for (j=0; j<NPointsXTraj; j+=1)
			pos_str = num2str(PosXTraj[j])
			MakeTrajNamesWave(pos_str)
			Wave/T TrajNames	
			
			for (i=0; i<numpnts(TrajNames); i+=1)
				NameTraj = TrajNames[i]
				NameTrajTmp1 = NameTraj + add_str_1
				NameTrajTmp2 = NameTraj + add_str_2
				if (StartYZTraj > EndYZTraj)
					Concatenate/NP/KILL/O {$NameTrajTmp2, $NameTrajTmp1}, $NameTraj
				else
					Concatenate/NP/KILL/O {$NameTrajTmp1, $NameTrajTmp2}, $NameTraj
				endif
			endfor
		
		endfor
		
		iTraj = 2*iTraj - 1
	else
		TrajectoriesCalculation()
		wave PosXTraj	
	endif

	Make/O/D/N=(NPointsXTraj)IntBx_X_Traj = 0
	Make/O/D/N=(NPointsXTraj)IntBy_X_Traj = 0
	Make/O/D/N=(NPointsXTraj)IntBz_X_Traj = 0		

	Make/O/D/N=(NPointsXTraj)Int2Bx_X_Traj = 0
	Make/O/D/N=(NPointsXTraj)Int2By_X_Traj = 0
	Make/O/D/N=(NPointsXTraj)Int2Bz_X_Traj = 0
	
	Make/O/D/N=(NPointsXTraj) Deflection_IntTraj_X = 0
	Make/O/D/N=(NPointsXTraj) Deflection_IntTraj_Y = 0
	Make/O/D/N=(NPointsXTraj) Deflection_IntTraj_Z = 0	

	Make/O/D/N=(NPointsXTraj) Deflection_X = 0
	Make/O/D/N=(NPointsXTraj) Deflection_Y = 0
	Make/O/D/N=(NPointsXTraj) Deflection_Z = 0	

	for (j=0; j<NPointsXTraj; j+=1)
		pos_str = num2str(PosXTraj[j])
		
		Wave Vel_X = $("Vel_X" + pos_str)
		Wave Vel_Y = $("Vel_Y" + pos_str)
		Wave Vel_Z = $("Vel_Z" + pos_str)

		if (BeamDirection == 1)
   			NameTrajPos = "TrajY" + pos_str
   		else
   			NameTrajPos = "TrajZ" + pos_str
		endif
		
		NameTraj = "VetorCampoX" + pos_str
		NameTrajInt = NameTraj + "_int"
		NameTrajInt2 = NameTraj + "_int2"	
		Integrate/METH=1 $NameTraj/X=$NameTrajPos/D=$NameTrajInt
		Integrate/METH=1 $NameTrajInt/X=$NameTrajPos/D=$NameTrajInt2	  

		Wave Tmp =  $NameTrajInt
		IntBx_X_Traj[j] = Tmp[iTraj]
		Wave Tmp =  $NameTrajInt2
		Int2Bx_X_Traj[j] = Tmp[iTraj]

		NameTraj = "VetorCampoY" + pos_str
		NameTrajInt = NameTraj + "_int"
		NameTrajInt2 = NameTraj + "_int2"	
		Integrate/METH=1 $NameTraj/X=$NameTrajPos/D=$NameTrajInt
		Integrate/METH=1 $NameTrajInt/X=$NameTrajPos/D=$NameTrajInt2	 

		Wave Tmp =  $NameTrajInt
		IntBy_X_Traj[j] = Tmp[iTraj]
		Wave Tmp =  $NameTrajInt2
		Int2By_X_Traj[j] = Tmp[iTraj]
		
		NameTraj = "VetorCampoZ" + pos_str
		NameTrajInt = NameTraj + "_int"
		NameTrajInt2 = NameTraj + "_int2"
		Integrate/METH=1 $NameTraj/X=$NameTrajPos/D=$NameTrajInt
		Integrate/METH=1 $NameTrajInt/X=$NameTrajPos/D=$NameTrajInt2	 
		
		Wave Tmp =  $NameTrajInt
		IntBz_X_Traj[j] = Tmp[iTraj]
		Wave Tmp =  $NameTrajInt2
		Int2Bz_X_Traj[j] = Tmp[iTraj]			
		
		if (BeamDirection == 1)	
			Deflection_X[j] = atan(Vel_X[iTraj]/Vel_Y[iTraj]) / pi * 180
			Deflection_Z[j] = atan(Vel_Z[iTraj]/Vel_Y[iTraj]) / pi * 180

			Deflection_IntTraj_X[j] = (atan(Vel_X[iTraj]/Vel_Y[iTraj]) - atan(Vel_X[0]/Vel_Y[0])) / pi * 180
			Deflection_IntTraj_Z[j] = (atan(Vel_Z[iTraj]/Vel_Y[iTraj]) - atan(Vel_Z[0]/Vel_Y[0]) ) / pi * 180
		else
			Deflection_X[j] = atan(Vel_X[iTraj]/Vel_Z[iTraj]) / pi * 180
			Deflection_Y[j] = atan(Vel_Y[iTraj]/Vel_Z[iTraj]) / pi * 180					
		
			Deflection_IntTraj_X[j] = (atan(Vel_X[iTraj]/Vel_Z[iTraj]) - atan(Vel_X[0]/Vel_Z[0])) / pi * 180
			Deflection_IntTraj_Y[j] = (atan(Vel_Y[iTraj]/Vel_Z[iTraj]) - atan(Vel_Y[0]/Vel_Z[0])) / pi * 180	
		endif

	endfor		

	EndYZTraj = initial_endyz
	UpdateResultsPanel()

End


Function TrajectoriesCalculation()

   	NVAR Charge     = root:varsCAMTO:Charge
	NVAR Mass       = root:varsCAMTO:Mass
	NVAR LightSpeed = root:varsCAMTO:LightSpeed
	NVAR TrajShift  = root:varsCAMTO:TrajShift

	variable energy = GetParticleEnergy()

	variable TotalEnergy_J  = energy*1E9*abs(Charge)
	variable Gama  = TotalEnergy_J / (Mass * LightSpeed^2)
	variable ChargeVel = ((1 - 1/Gama^2)*LightSpeed^2)^0.5
       
	NVAR Single_Multi  = :varsFieldMap:Single_Multi       	
	NVAR BeamDirection = :varsFieldMap:BeamDirection 
	
	NVAR StartXTraj    = :varsFieldMap:StartXTraj 
	NVAR EndXTraj      = :varsFieldMap:EndXTraj 
	NVAR StepsXTraj    = :varsFieldMap:StepsXTraj 
	NVAR NPointsXTraj  = :varsFieldMap:NPointsXTraj

	NVAR StartYZ		 = :varsFieldMap:StartYZ 
	NVAR EndYZ		 = :varsFieldMap:EndYZ	
	NVAR StartYZTraj = :varsFieldMap:StartYZTraj 
	NVAR EndYZTraj   = :varsFieldMap:EndYZTraj 	
	
	NVAR Analitico_RungeKutta = :varsFieldMap:Analitico_RungeKutta
	NVAR Out_of_Matrix_Error  = :varsFieldMap:Out_of_Matrix_Error
	Out_of_Matrix_Error = 0
	
	NVAR iTraj      = :varsFieldMap:iTraj
	NVAR iTrajError = :varsFieldMap:iTrajError

	string NomeTraj
	string NomeTrajPos
	string NomeTrajInt	
	string NomeTrajInt2	
	variable i, j

	if (StartYZTraj < StartYZ || StartYZTraj > EndYZ)
		DoAlert 0, "Initial longitudinal position out of range."
		return -1
	endif

	if (EndYZTraj < StartYZ || EndYZTraj > EndYZ)
		DoAlert 0, "Final longitudinal position out of range."
		return -1
	endif				
		
	if (Single_Multi==1)
		NPointsXTraj = 1
	else
		NPointsXTraj = ((EndXTraj - StartXTraj) / StepsXTraj) + 1	
	endif       
	
	Make/O/D/N=(NPointsXTraj) PosXTraj
	for (j=0;j<NPointsXTraj;j=j+1)
		PosXTraj[j] = (StartXTraj + j*StepsXTraj)/1000 // converte para metros
	endfor
	
	Make/O/D/N=(iTraj) PosYZTraj
	if (StartYZTraj <= EndYZTraj)
		for (i=0;i<iTraj;i=i+1)
		   PosYZTraj[i] = (StartYZTraj/1000 + i*TrajShift)
		endfor
	else
		for (i=0;i<iTraj;i=i+1)
		   PosYZTraj[i] = (StartYZTraj/1000 - i*TrajShift)
		endfor
	endif
	
	Wave C_PosX
	
	variable Out_of_Matrix_Local = 0
	
	for (j=0; j<NPointsXTraj; j+=1)
		print ("Calculating Trajectory X = " + num2str(PosXTraj[j]))
		iTraj = Abs(((EndYZTraj-StartYZTraj) / (TrajShift*1000))) + 1	

		Make/O/D/N=(iTraj) TrajX = 0
		Make/O/D/N=(iTraj) TrajY = 0
		Make/O/D/N=(iTraj) TrajZ = 0
		Make/O/D/N=(iTraj) Vel_X = 0
		Make/O/D/N=(iTraj) Vel_Y = 0
		Make/O/D/N=(iTraj) Vel_Z = 0
		Make/O/D/N=(iTraj)VetorCampoX = 0
		Make/O/D/N=(iTraj)VetorCampoY = 0
		Make/O/D/N=(iTraj)VetorCampoZ = 0		
		
		if (BeamDirection==1)
			if (Analitico_RungeKutta == 1)
				Analitico(PosXTraj[j],(StartYZTraj/1000),0)
			else
				Runge_Kutta(PosXTraj[j],(StartYZTraj/1000),0)
			endif
		else
			if (Analitico_RungeKutta == 1)
				Analitico(PosXTraj[j],0,(StartYZTraj/1000))					
			else
				Runge_Kutta(PosXTraj[j],0,(StartYZTraj/1000))
			endif
		endif
		
		if (Out_of_Matrix_Error !=0)
			Out_of_Matrix_Local = 1
		endif
		
		if (Out_of_Matrix_Error !=0)
 			DeletePoints iTrajError,(iTraj-iTrajError), TrajX
			DeletePoints iTrajError,(iTraj-iTrajError), TrajY
			DeletePoints iTrajError,(iTraj-iTrajError), TrajZ			

 			DeletePoints iTrajError,(iTraj-iTrajError), Vel_X
			DeletePoints iTrajError,(iTraj-iTrajError), Vel_Y
			DeletePoints iTrajError,(iTraj-iTrajError), Vel_Z			

 			DeletePoints iTrajError,(iTraj-iTrajError), VetorCampoX
			DeletePoints iTrajError,(iTraj-iTrajError), VetorCampoY
			DeletePoints iTrajError,(iTraj-iTrajError), VetorCampoZ			

			iTraj = iTrajError

			Out_of_Matrix_Error = 0			
		endif
			
		NomeTraj = "TrajX" + num2str(PosXTraj[j])
		Duplicate/D/O TrajX $NomeTraj
		
		NomeTraj = "TrajY" + num2str(PosXTraj[j])
		Duplicate/D/O TrajY $NomeTraj	
		
		NomeTraj = "TrajZ" + num2str(PosXTraj[j])
		Duplicate/D/O TrajZ $NomeTraj
	
		NomeTraj = "Vel_X" + num2str(PosXTraj[j])
		Duplicate/D/O Vel_X $NomeTraj
		
		NomeTraj = "Vel_Y" + num2str(PosXTraj[j])
		Duplicate/D/O Vel_Y $NomeTraj

		NomeTraj = "Vel_Z" + num2str(PosXTraj[j])
		Duplicate/D/O Vel_Z $NomeTraj
		
		if (BeamDirection == 1)
   			NomeTrajPos = "TrajY" + num2str(PosXTraj[j])
   		else
   			NomeTrajPos = "TrajZ" + num2str(PosXTraj[j])
		endif

		NomeTraj = "VetorCampoX" + num2str(PosXTraj[j])
		Duplicate/D/O VetorCampoX $NomeTraj		
	
		NomeTraj = "VetorCampoY" + num2str(PosXTraj[j])
		Duplicate/D/O VetorCampoY $NomeTraj		
	
		NomeTraj = "VetorCampoZ" + num2str(PosXTraj[j])
		Duplicate/D/O VetorCampoZ $NomeTraj		

		TrajX = 0
		TrajY = 0
		TrajZ = 0	
		
		Vel_X = 0			
		Vel_Y = 0
		Vel_Z = 0		
	endfor	
	
	if (Out_of_Matrix_Local != 0) 
		DoAlert 0,"At least one trajectory travelled out of the field matrix "
	endif
	
	Killwaves TrajX	   
	Killwaves TrajY	   
	Killwaves TrajZ	   
	Killwaves Vel_X	   
	Killwaves Vel_Y	   
	Killwaves Vel_Z	   						
	Killwaves VetorCampoX	   
	Killwaves VetorCampoY	   
	Killwaves VetorCampoZ	
End



Function CalcTrajectoriesToAll(ctrlName) : ButtonControl
	String ctrlName
	
	DoAlert 1, "Calculate trajectories for all fieldmaps?"
	if (V_flag != 1)
		return -1
	endif
	
	UpdateFieldMapDirs()
		
	Wave/T FieldMapDirs = root:wavesCAMTO:FieldMapDirs
	NVAR FieldMapCount  = root:varsCAMTO:FieldMapCount
	SVAR FieldMapDir= root:varsCAMTO:FieldMapDir
		
	DFREF df = GetDataFolderDFR()
	string dfc = GetDataFolder(0)
	
	variable i
	string tdf
	string empty = ""

	for (i=0; i < FieldMapCount; i=i+1)
		tdf = FieldMapDirs[i]
		FieldMapDir = tdf
		SetDataFolder root:$(tdf)
		CopyTrajectoriesConfig_(dfc)
		Print("Calculating Trajectories for " + tdf + ":")
		TrajectoriesCalculationProc(empty)
	endfor

	FieldMapDir = dfc
	SetDataFolder df
	
End


Function Runge_Kutta(px, py, pz)
	variable px, py, pz

	NVAR Charge     = root:varsCAMTO:Charge
	NVAR Mass       = root:varsCAMTO:Mass
	NVAR LightSpeed = root:varsCAMTO:LightSpeed
	NVAR TrajShift  = root:varsCAMTO:TrajShift  
	
	variable energy = GetParticleEnergy()
	
	variable TotalEnergy_J  = energy*1E9*abs(Charge)
	variable Gama  = TotalEnergy_J / (Mass * LightSpeed^2)
	variable ChargeVel = ((1 - 1/Gama^2)*LightSpeed^2)^0.5
		
	NVAR BeamDirection = :varsFieldMap:BeamDirection
	NVAR EntranceAngle = :varsFieldMap:EntranceAngle	
	NVAR CheckField    = :varsFieldMap:CheckField
	NVAR StartX        = :varsFieldMap:StartX
	NVAR EndX          = :varsFieldMap:EndX
	NVAR StartYZTraj = :varsFieldMap:StartYZTraj 
	NVAR EndYZTraj   = :varsFieldMap:EndYZTraj 	
	
	NVAR Out_of_Matrix_Error = :varsFieldMap:Out_of_Matrix_Error
		
	NVAR FieldX = :varsFieldMap:FieldX
	NVAR FieldY = :varsFieldMap:FieldY
	NVAR FieldZ = :varsFieldMap:FieldZ

	NVAR iTraj      = :varsFieldMap:iTraj
	NVAR iTrajError = :varsFieldMap:iTrajError

	variable i, j, k
	
	variable x_t, y_t, z_t
	variable vx_t, vy_t, vz_t	

	variable x_t_n, y_t_n, z_t_n
	variable vx_t_n, vy_t_n, vz_t_n	
	
	variable Fx_t, Fy_t, Fz_t	
	
	variable t
	if (StartYZTraj <= EndYZTraj)
		t = TrajShift/ChargeVel
	else
		t = -TrajShift/ChargeVel
	endif
	
	Wave C_PosYZ
		
	variable CorrVel
	
	Wave TrajX
	Wave TrajY
	Wave TrajZ		
	Wave Vel_X
	Wave Vel_Y
	Wave Vel_Z		
	
	Wave VetorCampoX
	Wave VetorCampoY
	Wave VetorCampoZ
	
	vx_t = sin(EntranceAngle*pi/180)*ChargeVel
	if (BeamDirection == 1)
		vy_t = cos(EntranceAngle*pi/180)*ChargeVel
		vz_t = 0
	else
		vy_t = 0
		vz_t = cos(EntranceAngle*pi/180)*ChargeVel	
	endif	
	
	//Inicia posições
	x_t = px
	y_t = py
	z_t = pz
	
	TrajX[0] = x_t
	TrajY[0] = y_t
	TrajZ[0] = z_t

	Vel_X[0] = vx_t
	Vel_Y[0] = vy_t
	Vel_Z[0] = vz_t
	
	Redimension/N=(2*iTraj) TrajX
	Redimension/N=(2*iTraj) TrajY
	Redimension/N=(2*iTraj) TrajZ
	Redimension/N=(2*iTraj) Vel_X
	Redimension/N=(2*iTraj) Vel_Y
	Redimension/N=(2*iTraj) Vel_Z
	Redimension/N=(2*iTraj) VetorCampoX
	Redimension/N=(2*iTraj) VetorCampoY
	Redimension/N=(2*iTraj) VetorCampoZ	
	
	variable yz 
	if (BeamDirection == 1)			
		yz = y_t
	else
		yz = z_t			
	endif
			
	for (k=1;k<2*iTraj;k=k+1) 
		//Procura o campo nas coordenadas X,Z desejadas.
		
		if (CheckField==1)
			if (x_t < (StartX/1000))
				if (BeamDirection == 1)			
					Campo_espaco(StartX/1000,y_t)
				else
					Campo_espaco(StartX/1000,z_t)				
				endif
			elseif (x_t > (EndX/1000))
				if (BeamDirection == 1)			
					Campo_espaco(EndX/1000,y_t)	
				else
					Campo_espaco(EndX/1000,z_t)				
				endif
			else
				if (BeamDirection == 1)		
					Campo_espaco(x_t,y_t)
				else
					Campo_espaco(x_t,z_t)				
				endif
			endif
		else
			if ((x_t < (StartX/1000)) || (x_t > (EndX/1000)))
				Out_of_Matrix_Error = 1
				iTrajError = k-1
			   	break
			 else
				if (BeamDirection == 1)		
					Campo_espaco(x_t,y_t)
					
				else
					Campo_espaco(x_t,z_t)				
				endif
			endif
		endif
		
		VetorCampoX[k-1] = FieldX
		VetorCampoY[k-1] = FieldY
		VetorCampoZ[k-1] = FieldZ
	
		Fx_t = Charge * ( (vy_t*FieldZ) - (vz_t*FieldY) )
		Fy_t = Charge * ( (vz_t*FieldX) - (vx_t*FieldZ) )
		Fz_t = Charge * ( (vx_t*FieldY) - (vy_t*FieldX) )

		vx_t_n = vx_t + Fx_t * t / (Mass*Gama)
		vy_t_n = vy_t + Fy_t * t / (Mass*Gama)
		vz_t_n = vz_t + Fz_t * t / (Mass*Gama)

		x_t_n = x_t +  (t*vx_t)
		y_t_n = y_t +  (t*vy_t)
		z_t_n = z_t +  (t*vz_t)
		
		x_t = x_t_n;
		y_t = y_t_n;
		z_t = z_t_n;				

		vx_t = vx_t_n;
		vy_t = vy_t_n;
		vz_t = vz_t_n;				
		
		TrajX[k] = x_t
		TrajY[k] = y_t
		TrajZ[k] = z_t

		Vel_X[k] = vx_t
		Vel_Y[k] = vy_t
		Vel_Z[k] = vz_t
		
		if (BeamDirection == 1)			
			yz = y_t
		else
			yz = z_t			
		endif
		
		if (t >= 0 && yz >= EndYZTraj/1000)
			break
		elseif (t < 0 && yz <= EndYZTraj/1000)
			break
		endif
	
	endfor

	iTraj = k
	Redimension/N=(iTraj) TrajX
	Redimension/N=(iTraj) TrajY
	Redimension/N=(iTraj) TrajZ
	Redimension/N=(iTraj) Vel_X
	Redimension/N=(iTraj) Vel_Y
	Redimension/N=(iTraj) Vel_Z
	Redimension/N=(iTraj) VetorCampoX
	Redimension/N=(iTraj) VetorCampoY
	Redimension/N=(iTraj) VetorCampoZ		
	
End


Function Analitico(px, py, pz)
	variable px, py, pz

	NVAR Charge     = root:varsCAMTO:Charge
	NVAR Mass       = root:varsCAMTO:Mass
	NVAR LightSpeed = root:varsCAMTO:LightSpeed
	NVAR TrajShift  = root:varsCAMTO:TrajShift  
	
	variable energy = GetParticleEnergy()

	variable TotalEnergy_J  = energy*1E9*abs(Charge)
	variable Gama  = TotalEnergy_J / (Mass * LightSpeed^2)
	variable ChargeVel = ((1 - 1/Gama^2)*LightSpeed^2)^0.5

	NVAR BeamDirection = :varsFieldMap:BeamDirection
	NVAR EntranceAngle = :varsFieldMap:EntranceAngle
	NVAR CheckField    = :varsFieldMap:CheckField
	NVAR StartX        = :varsFieldMap:StartX
	NVAR EndX          = :varsFieldMap:EndX 
	NVAR StartYZTraj = :varsFieldMap:StartYZTraj 
	NVAR EndYZTraj   = :varsFieldMap:EndYZTraj 	
	
	NVAR Out_of_Matrix_Error = :varsFieldMap:Out_of_Matrix_Error
	
	NVAR FieldX = :varsFieldMap:FieldX
	NVAR FieldY = :varsFieldMap:FieldY
	NVAR FieldZ = :varsFieldMap:FieldZ

	NVAR iTraj      = :varsFieldMap:iTraj
	NVAR iTrajError = :varsFieldMap:iTrajError	

	variable i, j, k
		
	variable ModField
	variable ConstFieldCharge
	variable x1_t, x2_t
	variable y1_t, y2_t
	variable z1_t, z2_t
	
	variable x_t, y_t, z_t
	variable x_t_n, y_t_n, z_t_n
		
	variable vx_t, vy_t, vz_t
	variable vx_t_n, vy_t_n, vz_t_n	
	
	variable Fx_t, Fy_t, Fz_t
	
	variable t
	if (StartYZTraj <= EndYZTraj)
		t = TrajShift/ChargeVel
	else
		t = -TrajShift/ChargeVel
	endif
	
	Wave C_PosYZ
		
	variable CorrVel 
	
	Wave TrajX
	Wave TrajY
	Wave TrajZ		
	Wave Vel_X
	Wave Vel_Y
	Wave Vel_Z		
	
	Wave VetorCampoX
	Wave VetorCampoY
	Wave VetorCampoZ
	
	vx_t = sin(EntranceAngle*pi/180) * ChargeVel
	if (BeamDirection == 1)
		vy_t = cos(EntranceAngle*pi/180)*ChargeVel
		vz_t = 0
	else
		vy_t = 0
		vz_t = cos(EntranceAngle*pi/180)*ChargeVel	
	endif	
	
	//Inicia posições
	x_t = px
	y_t = py
	z_t = pz
	
	TrajX[0] = x_t
	TrajY[0] = y_t
	TrajZ[0] = z_t

	Vel_X[0] = vx_t
	Vel_Y[0] = vy_t
	Vel_Z[0] = vz_t
	
	for (k=1;k<iTraj;k=k+1) 
		//Procura o campo nas coordenadas X,Z desejadas.
				
		if (CheckField==1)
			if (x_t < (StartX/1000))
				if (BeamDirection == 1)			
					Campo_espaco(StartX/1000,y_t)
				else
					Campo_espaco(StartX/1000,z_t)				
				endif
			elseif (x_t > (EndX/1000))
				if (BeamDirection == 1)			
					Campo_espaco(EndX/1000,y_t)	
				else
					Campo_espaco(EndX/1000,z_t)				
				endif
			else
				if (BeamDirection == 1)		
					Campo_espaco(x_t,y_t)
				else
					Campo_espaco(x_t,z_t)				
				endif
			endif
		else
			if ((x_t < (StartX/1000)) || (x_t > (EndX/1000)))
				Out_of_Matrix_Error = 1
				iTrajError = k-1
				break
			else
				if (BeamDirection == 1)		
					Campo_espaco(x_t,y_t)
							
				else
					Campo_espaco(x_t,z_t)				
				endif
			endif
		endif
		
		VetorCampoX[k-1] = FieldX
		VetorCampoY[k-1] = FieldY
		VetorCampoZ[k-1] = FieldZ
		
		ModField = Sqrt(FieldX^2 + FieldY^2 + FieldZ^2)
		ConstFieldCharge = (1 / ( (FieldX^2 + FieldY^2 + FieldZ^2)^(3/2) * abs(Charge))) 
		
		//x_t
		x1_t = ModField *(Gama*Mass*(-FieldZ* vy_t + FieldY*vz_t) + FieldX*abs(Charge)*t*(FieldY*vy_t + FieldZ*vz_t) + (FieldY^2 + FieldZ^2)*abs(Charge)*x_t + (FieldX^2)*abs(Charge)*(t*vx_t + x_t) )
		x2_t = Gama * ModField * Mass * (FieldZ*vy_t - FieldY*vz_t) * Cos (ModField * abs(Charge) * t / (Gama * Mass)) + Gama * Mass * (FieldY^2 * vx_t - FieldX*FieldY*vy_t + FieldZ *(FieldZ*vx_t - FieldX*vz_t)) * Sin(ModField * abs(Charge) * t / (Gama * Mass))
		x_t_n =((x1_t + x2_t) * ConstFieldCharge)
		
		//y_t
		y1_t = ModField * (Gama*Mass*(-FieldX* vz_t + FieldZ*vx_t) + FieldY*abs(Charge)*t*(FieldX*vx_t + FieldY*vy_t+FieldZ*vz_t) + (FieldX^2 + FieldY^2 + FieldZ^2)*abs(Charge)*y_t)
		y2_t = Gama * ModField * Mass * (FieldX*vz_t - FieldZ*vx_t) * Cos (ModField * abs(Charge) * t / (Gama * Mass)) + Gama * Mass * (-FieldX*FieldY*vx_t + FieldX^2*vy_t + FieldZ*(FieldZ*vy_t - FieldY*vz_t)) * Sin(ModField * abs(Charge) * t / (Gama * Mass))
		y_t_n = ((y1_t + y2_t) * ConstFieldCharge)
																														
		//z_t
		z1_t = ModField * (Gama*Mass*(-FieldY* vx_t + FieldX*vy_t) + FieldZ*abs(Charge)*t*(FieldX*vx_t + FieldY*vy_t +  FieldZ*vz_t) + (FieldX^2 + FieldY^2 + FieldZ^2)*abs(Charge)*z_t)
		z2_t = Gama * ModField * Mass * (FieldY*vx_t - FieldX*vy_t) * Cos (ModField * abs(Charge) * t / (Gama * Mass)) + Gama * Mass * (-FieldY*FieldZ*vy_t + FieldY^2*vz_t + FieldX*(FieldX*vz_t-FieldZ*vx_t)) * Sin(ModField * abs(Charge) * t / (Gama * Mass))
		z_t_n = ((z1_t + z2_t) * ConstFieldCharge)
		
		//vx_t
		vx_t_n = (( ConstFieldCharge * (ModField * (FieldX^2*abs(Charge)*vx_t + FieldX*abs(Charge)*(FieldY*vy_t + FieldZ*vz_t) )  + ModField*abs(Charge)* (FieldY^2*vx_t - FieldX*FieldY*vy_t + FieldZ*(FieldZ*vx_t - FieldX*vz_t)) *Cos (ModField * abs(Charge) * t / Gama / Mass) - (FieldX^2 + FieldY^2 + FieldZ^2)*abs(Charge)*(FieldZ*vy_t - FieldY*vz_t)*Sin(ModField * abs(Charge) * t / Gama / Mass))))
		
		//vy_t
		vy_t_n = (( ConstFieldCharge * (ModField * (FieldY^2*abs(Charge)*vy_t + FieldY*abs(Charge)*(FieldZ*vz_t + FieldX*vx_t) )  + ModField*abs(Charge)* (FieldZ^2*vy_t - FieldY*FieldZ*vz_t + FieldX*(FieldX*vy_t - FieldY*vx_t)) *Cos (ModField * abs(Charge) * t / Gama / Mass) - (FieldX^2 + FieldY^2 + FieldZ^2)*abs(Charge)*(FieldX*vz_t - FieldZ*vx_t)*Sin(ModField * abs(Charge) * t / Gama / Mass))))
	
		//vz_t				
		vz_t_n = (( ConstFieldCharge * (ModField * (FieldZ^2*abs(Charge)*vz_t + FieldZ*abs(Charge)*(FieldX*vx_t + FieldY*vy_t) )  + ModField*abs(Charge)* (FieldX^2*vz_t - FieldZ*FieldX*vx_t + FieldY*(FieldY*vz_t - FieldZ*vy_t)) *Cos (ModField * abs(Charge) * t / Gama / Mass) - (FieldX^2 + FieldY^2 + FieldZ^2)*abs(Charge)*(FieldY*vx_t - FieldX*vy_t)*Sin(ModField * abs(Charge) * t / Gama / Mass))))
		
		x_t = x_t_n
		y_t = y_t_n
		z_t = z_t_n				

		vx_t = vx_t_n
		vy_t = vy_t_n
		vz_t = vz_t_n				
		
		TrajX[k] = x_t
		TrajY[k] = y_t
		TrajZ[k] = z_t

		Vel_X[k] = vx_t
		Vel_Y[k] = vy_t
		Vel_Z[k] = vz_t
	endfor
End


Window Dynamic_Multipoles() : Panel
	PauseUpdate; Silent 1		// building window...

	if (DataFolderExists("root:varsCAMTO")==0)
		DoAlert 0, "CAMTO variables not found."
		return 
	endif

	//Procura Janela e se estiver aberta, fecha antes de abrir novamente.
	string PanelName
	PanelName = WinList("Dynamic_Multipoles",";","")	
	if (stringmatch(PanelName, "Dynamic_Multipoles;"))
		Killwindow Dynamic_Multipoles
	endif	
	
	NewPanel/K=1/W=(780,250,1103,825)
	SetDrawLayer UserBack
	SetDrawEnv fillpat= 0
	DrawRect 3,4,320,70
	SetDrawEnv fillpat= 0
	DrawRect 3,70,320,300	
	SetDrawEnv fillpat= 0
	DrawRect 3,300,320,370
	SetDrawEnv fillpat= 0
	DrawRect 3,370,320,440
	SetDrawEnv fillpat= 0
	DrawRect 3,440,320,480
	SetDrawEnv fillpat= 0
	DrawRect 3,480,320,570
				
	TitleBox    traj,pos={10,25},size={90,16},fSize=14,fStyle=1,frame=0,title="Trajectory"
	ValDisplay  traj_x,pos={110,10},size={200,18},title="Start X [mm]:    "
	ValDisplay  traj_angle,pos={110,30},size={200,18},title="Angle XY(Z) [°]:"
	ValDisplay  traj_yz,pos={110,50},size={200,18},title="Start YZ [mm]:  "

	TitleBox    title,pos={25,75},size={150,16},fSize=14,fStyle=1,frame=0,title="Integrals and Multipoles over Trajectory"
	TitleBox    subtitle,pos={86,100},size={127,16},fSize=14,frame=0, title="K0 to Kx (0 - On, 1 - Off)"
		
	SetVariable order,pos={10,125},size={220,18},title="Order of multipolar analysis:"
	
	SetVariable dist,pos={10,150},size={200,18},title="Dist. for multipolar analysis:"
	TitleBox    dist_unit,pos={210,150},size={87,15},frame=0,title=" mm from center",fSize=12
	SetVariable norm_k,pos={10,175},size={220,18},title="Normalize against K:"
	PopupMenu   norm_comp,pos={10,200},size={241,16},proc=PopupDynMultComponent,title="Component:"
	PopupMenu   norm_comp,value= #"\"Normal;Skew\""
	
	SetVariable shift pos={10,226},size={220,16},title="Calculation displacement [m]:"
	SetVariable shift,limits={root:varsCAMTO:TrajShift, 1, 0}

	TitleBox    grid_title,pos={10, 253},size={220,18},frame=0,title="Perpendicular grid:",fSize=12
	SetVariable grid_min,pos={10,275},limits={-inf, inf, 0},size={90,18},title="Min [mm]:"
	SetVariable grid_max,pos={109,275},limits={-inf, inf, 0}, size={90,18},title="Max [mm]:"
	SetVariable grid_nrpts,pos={209,275},limits={-inf, inf, 0},size={90,18},title="Nr points:"

	TitleBox    mult_title,pos={10, 305},size={220,18},frame=0,title="Dynamic Multipoles"
	SetVariable norm_ks,pos={20,325},size={285,18},title="Normal - Ks to use:"
	SetVariable skew_ks,pos={20,345},size={285,18},title="\t Skew - Ks to use:"
		
	TitleBox    res_title,pos={10, 375},size={220,18},frame=0,title="Residual Normalized Dynamic Multipoles"
	SetVariable res_norm_ks,pos={20,395},size={285,16},title="Normal - Ks to use:"
	SetVariable res_skew_ks,pos={20,415},size={285,16},title="\t Skew - Ks to use:"

	Button mult_button,pos={15,445},size={295,30},proc=CalcDynIntegralsMultipoles,title="Calculate Dynamic Multipoles"
	Button mult_button,fSize=15,fStyle=1

	SetVariable fieldmapdir,pos={15,488},size={290,18},title="Field Map Directory: "
	SetVariable fieldmapdir,noedit=1,value=root:varsCAMTO:FieldMapDir
	TitleBox copy_title,pos={15,515},size={145,18},frame=0,title="Copy Configuration from:"
	PopupMenu copy_dir,pos={160,513},size={145,18},bodyWidth=145,mode=0,proc=CopyDynMultipolesConfig,title=" "
	Button apply_to_all,pos={15,540},size={290,25},fStyle=1,proc=CalcDynIntegralsMultipolesToAll,title="Calculate Dynamic Multipoles for All Field Maps"
	
	UpdateFieldMapDirs()
	UpdateDynMultipolesPanel()

EndMacro


Function UpdateDynMultipolesPanel()
	
	string PanelName
	PanelName = WinList("Dynamic_Multipoles",";","")	
	if (stringmatch(PanelName, "Dynamic_Multipoles;")==0)
		return -1
	endif
	
	SVAR df = root:varsCAMTO:FieldMapDir
	
	NVAR FieldMapCount = root:varsCAMTO:FieldMapCount
	
	string FieldMapList
	if (FieldMapCount > 1)
		FieldMapList = getFieldmapDirs()
		Button apply_to_all,win=Dynamic_Multipoles, disable=0
	else
		FieldMapList = ""
		Button apply_to_all,win=Dynamic_Multipoles, disable=2
	endif
	
	if (DataFolderExists("root:Nominal"))
		FieldMapList = "Field Specification;" + FieldMapList
	endif

	PopupMenu copy_dir,win=Dynamic_Multipoles,disable=0,value= #("\"" + "Multipoles over line;" + FieldMapList + "\"")
	
	if (strlen(df) > 0)
		NVAR FittingOrderTraj = root:$(df):varsFieldMap:FittingOrderTraj
		NVAR DynNormComponent = root:$(df):varsFieldMap:DynNormComponent
		NVAR CheckNegPosTraj = root:$(df):varsFieldMap:CheckNegPosTraj

		ValDisplay traj_x,    win=Dynamic_Multipoles, value=#("root:"+ df + ":varsFieldMap:StartXTraj" )
		ValDisplay traj_angle,win=Dynamic_Multipoles,value=#("root:"+ df + ":varsFieldMap:EntranceAngle" )
		ValDisplay traj_yz,   win=Dynamic_Multipoles, value=#("root:"+ df + ":varsFieldMap:StartYZTraj" )
			
		SetVariable order,win=Dynamic_Multipoles, value= root:$(df):varsFieldMap:FittingOrderTraj
		SetVariable dist,win=Dynamic_Multipoles, value= root:$(df):varsFieldMap:DistcenterTraj
		SetVariable norm_k,win=Dynamic_Multipoles,limits={0,(FittingOrderTraj-1),1},value= root:$(df):varsFieldMap:DynKNorm
		PopupMenu   norm_comp,win=Dynamic_Multipoles,disable=0,mode=DynNormComponent

		SetVariable shift,win=Dynamic_Multipoles,    value= root:$(df):varsFieldMap:MultipolesTrajShift
		SetVariable grid_min,win=Dynamic_Multipoles,  value= root:$(df):varsFieldMap:GridMinTraj
		SetVariable grid_max,win=Dynamic_Multipoles,  value= root:$(df):varsFieldMap:GridMaxTraj
		SetVariable grid_nrpts,win=Dynamic_Multipoles,value= root:$(df):varsFieldMap:GridNrptsTraj

		SetVariable norm_ks,win=Dynamic_Multipoles, value= root:$(df):varsFieldMap:DynNormalCoefs	
		SetVariable skew_ks,win=Dynamic_Multipoles, value= root:$(df):varsFieldMap:DynSkewCoefs
				
		SetVariable res_norm_ks, win=Dynamic_Multipoles, value= root:$(df):varsFieldMap:DynResNormalCoefs
		SetVariable res_skew_ks, win=Dynamic_Multipoles, value= root:$(df):varsFieldMap:DynResSkewCoefs

		if (CheckNegPosTraj == 1)
			ValDisplay traj_x,    win=Dynamic_Multipoles, disable=2
			ValDisplay traj_angle,win=Dynamic_Multipoles, disable=2
			ValDisplay traj_yz,   win=Dynamic_Multipoles, disable=2
		else
			ValDisplay traj_x,    win=Dynamic_Multipoles, disable=0
			ValDisplay traj_angle,win=Dynamic_Multipoles, disable=0
			ValDisplay traj_yz,   win=Dynamic_Multipoles, disable=0		
		endif

		Button mult_button,win=Dynamic_Multipoles, disable=0
	else
		PopupMenu norm_comp,win=Dynamic_Multipoles,disable=2
		Button mult_button,win=Dynamic_Multipoles, disable=2
	endif
	
End


Function CopyDynMultipolesConfig(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	SVAR df  = root:varsCAMTO:FieldMapDir
	SVAR copydir = root:varsCAMTO:FieldMapCopy
	
	if (cmpstr(popStr, "Multipoles over line") == 0)
	
		NVAR temp_df  = root:$(df):varsFieldMap:FittingOrderTraj
		NVAR temp_dfc = root:$(df):varsFieldMap:FittingOrder
		temp_df = temp_dfc
		
		NVAR temp_df  = root:$(df):varsFieldMap:DistcenterTraj
		NVAR temp_dfc = root:$(df):varsFieldMap:Distcenter
		temp_df = temp_dfc

		NVAR temp_df  = root:$(df):varsFieldMap:GridMinTraj
		NVAR temp_dfc = root:$(df):varsFieldMap:GridMin
		temp_df = temp_dfc	

		NVAR temp_df  = root:$(df):varsFieldMap:GridMaxTraj
		NVAR temp_dfc = root:$(df):varsFieldMap:GridMax
		temp_df = temp_dfc	
		
		NVAR temp_df  = root:$(df):varsFieldMap:DynKNorm
		NVAR temp_dfc = root:$(df):varsFieldMap:KNorm
		temp_df = temp_dfc		

		NVAR temp_df  = root:$(df):varsFieldMap:DynNormComponent
		NVAR temp_dfc = root:$(df):varsFieldMap:NormComponent
		temp_df = temp_dfc	
		
		SVAR stemp_df  = root:$(df):varsFieldMap:DynNormalCoefs
		SVAR stemp_dfc = root:$(df):varsFieldMap:NormalCoefs
		stemp_df = stemp_dfc

		SVAR stemp_df  = root:$(df):varsFieldMap:DynSkewCoefs
		SVAR stemp_dfc = root:$(df):varsFieldMap:SkewCoefs
		stemp_df = stemp_dfc

		SVAR stemp_df  = root:$(df):varsFieldMap:DynResNormalCoefs
		SVAR stemp_dfc = root:$(df):varsFieldMap:ResNormalCoefs
		stemp_df = stemp_dfc

		SVAR stemp_df  = root:$(df):varsFieldMap:DynResSkewCoefs
		SVAR stemp_dfc = root:$(df):varsFieldMap:ResSkewCoefs
		stemp_df = stemp_dfc
		
	else
			
		string dfc
		if (cmpstr(popStr, "Field Specification") == 0)
			if (DataFolderExists("root:Nominal"))
				dfc = "Nominal"
			else
				DoAlert 0, "Data folder not found."
				return -1
			endif
		else
			SelectCopyDirectory(popNum,popStr)
		
			Wave/T FieldMapDirs= root:wavesCAMTO:FieldMapDirs
			
			UpdateFieldMapDirs()	
			FindValue/Text=copydir/TXOP=4 FieldMapDirs
			if (V_Value==-1)
				DoAlert 0, "Data folder not found."
				return -1
			endif
			
			dfc = copydir
		endif
							
		CopyDynMultipolesConfig_(dfc)
			
	endif
	
	UpdateDynMultipolesPanel()

End


Function CopyDynMultipolesConfig_(dfc)
	string dfc

	SVAR df  = root:varsCAMTO:FieldMapDir

	NVAR temp_df  = root:$(df):varsFieldMap:FittingOrderTraj
	NVAR temp_dfc = root:$(dfc):varsFieldMap:FittingOrderTraj
	temp_df = temp_dfc
	
	NVAR temp_df  = root:$(df):varsFieldMap:DistcenterTraj
	NVAR temp_dfc = root:$(dfc):varsFieldMap:DistcenterTraj
	temp_df = temp_dfc
	
	NVAR temp_df  = root:$(df):varsFieldMap:DynKNorm
	NVAR temp_dfc = root:$(dfc):varsFieldMap:DynKNorm
	temp_df = temp_dfc		

	NVAR temp_df  = root:$(df):varsFieldMap:DynNormComponent
	NVAR temp_dfc = root:$(dfc):varsFieldMap:DynNormComponent
	temp_df = temp_dfc	

	NVAR temp_df  = root:$(df):varsFieldMap:MultipolesTrajShift
	NVAR temp_dfc = root:$(dfc):varsFieldMap:MultipolesTrajShift 
	temp_df = temp_dfc	

	NVAR temp_df  = root:$(df):varsFieldMap:GridMinTraj
	NVAR temp_dfc = root:$(dfc):varsFieldMap:GridMinTraj
	temp_df = temp_dfc	

	NVAR temp_df  = root:$(df):varsFieldMap:GridMaxTraj
	NVAR temp_dfc = root:$(dfc):varsFieldMap:GridMaxTraj
	temp_df = temp_dfc	
	
	NVAR temp_df  = root:$(df):varsFieldMap:GridNrptsTraj
	NVAR temp_dfc = root:$(dfc):varsFieldMap:GridNrptsTraj
	temp_df = temp_dfc	
		
	SVAR stemp_df  = root:$(df):varsFieldMap:DynNormalCoefs
	SVAR stemp_dfc = root:$(dfc):varsFieldMap:DynNormalCoefs
	stemp_df = stemp_dfc

	SVAR stemp_df  = root:$(df):varsFieldMap:DynSkewCoefs
	SVAR stemp_dfc = root:$(dfc):varsFieldMap:DynSkewCoefs
	stemp_df = stemp_dfc

	SVAR stemp_df  = root:$(df):varsFieldMap:DynResNormalCoefs
	SVAR stemp_dfc = root:$(dfc):varsFieldMap:DynResNormalCoefs
	stemp_df = stemp_dfc

	SVAR stemp_df  = root:$(df):varsFieldMap:DynResSkewCoefs
	SVAR stemp_dfc = root:$(dfc):varsFieldMap:DynResSkewCoefs
	stemp_df = stemp_dfc

End


Function PopupDynMultComponent(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	NVAR DynNormComponent = :varsFieldMap:DynNormComponent
	DynNormComponent = popNum
	
End


Function CalcDynIntegralsMultipoles(ctrlName) : ButtonControl
	String ctrlName
	
	NVAR StartXTraj = :varsFieldMap:StartXTraj
	Wave/Z Traj = $"TrajX"+num2str(StartXTraj/1000)
	
	if (WaveExists(Traj))
		// Start timer
		variable timerRefNum, calc_time
		timerRefNum = StartMSTimer
	
		IntegralMultipoles_Traj()
		ResidualDynMultipolesCalc()
		UpdateResultsPanel()
		
		// Stop timer
		calc_time = StopMSTimer(timerRefNum)
		Print "Elapsed time :", calc_time*(10^(-6)), " seconds"
	else
		DoAlert 0, "Trajectory not found."
	endif
	
End


Function IntegralMultipoles_Traj([ReloadField])
	variable ReloadField

	NVAR TrajShift 		     	 = root:varsCAMTO:TrajShift

	NVAR BeamDirection 		    = :varsFieldMap:BeamDirection
	NVAR FittingOrder 		    = :varsFieldMap:FittingOrderTraj
	NVAR NormComponent  		 = :varsFieldMap:DynNormComponent
	NVAR KNorm					 = :varsFieldMap:DynKNorm   
	NVAR DistCenter				 = :varsFieldMap:DistcenterTraj
	NVAR StartXTraj            = :varsFieldMap:StartXTraj
	NVAR GridMin               = :varsFieldMap:GridMinTraj
	NVAR GridMax               = :varsFieldMap:GridMaxTraj
	NVAR GridNrpts           	 = :varsFieldMap:GridNrptsTraj
	NVAR MultipolesTrajShift	 = :varsFieldMap:MultipolesTrajShift
	SVAR NormalCoefs      		 = :varsFieldMap:DynNormalCoefs
	SVAR SkewCoefs      		 = :varsFieldMap:DynSkewCoefs
	
	print ("Calculating Multipoles over Trajectory X = " + num2str(StartXTraj/1000))

	if (ParamIsDefault(ReloadField))
		ReloadField = 1
	endif	

	if (ReloadField)
		print ("Reloading Field Data...")
		variable spline_flag
		spline_flag = CalcFieldmapInterpolant()
		
		if(spline_flag == 1)
			print("Field data successfully reloaded.")
		else
			print("Problem with cubic spline XOP. Using single thread calculation.")
		endif
	endif

	variable i, j, n, f
	variable PosNrpts, PosS, PosX, PosL

	Make/O/D/N=(GridNrpts) Dyn_Mult_Grid
	if (GridNrpts > 1)
		for (j=0; j<GridNrpts; j=j+1)
			Dyn_Mult_Grid[j] = GridMin/1000 + j*(GridMax/1000-GridMin/1000)/(GridNrpts-1)
		endfor
	else
		Dyn_Mult_Grid[0] = GridMin/1000 
	endif
	
	Wave TrajX = $"TrajX"+num2str(StartXTraj/1000)
	Wave VelX  = $"Vel_X"+num2str(StartXTraj/1000)

	variable skew_idx = 0
	variable normal_idx

	if (BeamDirection == 1)
		Wave TrajL = $"TrajY"+num2str(StartXTraj/1000)
		Wave VelL  = $"Vel_Y"+num2str(StartXTraj/1000)
		normal_idx = 2
	else
		Wave TrajL = $"TrajZ"+num2str(StartXTraj/1000)
		Wave VelL  = $"Vel_Z"+num2str(StartXTraj/1000)
		normal_idx = 1	
	endif
		
	f =  round(MultipolesTrajShift/TrajShift)
	if (f == 0)
		f = 1
	endif
	PosNrpts = round(numpnts(TrajX)/f)
	
	Make/D/O/N=(GridNrpts,3) Field_Perp	
	Make/O/D/N=(PosNrpts) Dyn_Mult_Ang , Dyn_Mult_Pos, Dyn_Mult_PosX, Dyn_Mult_PosYZ, Temp
	Make/O/D/N=(PosNrpts, FittingOrder) Dyn_Mult_Normal, Dyn_Mult_Skew
	Make/O/D/N=(FittingOrder) W_coef, W_sigma
	Make/O/D/N=(PosNrpts, GridNrpts) Bx, By, Bz
	
	
	variable normal_on = 0
	for (j=0; j<FittingOrder; j=j+1)
		if (cmpstr(NormalCoefs[j],"0")==0)
			normal_on = 1
			break
		endif
	endfor

	variable skew_on = 0
	for (j=0; j<FittingOrder; j=j+1)
		if (cmpstr(SkewCoefs[j],"0")==0)
			skew_on = 1
			break
		endif
	endfor
	
	PosS = 0
	PosX = TrajX[0]
	PosL = TrajL[0]
	for (i=0; i<PosNrpts; i=i+1)
	
		Dyn_Mult_Ang[i] = atan(VelX[i*f]/VelL[i*f])
		Dyn_Mult_Pos[i] = PosS + sqrt((TrajX[i*f]-PosX)^2  + (TrajL[i*f]-PosL)^2)	
		PosS = Dyn_Mult_Pos[i]
		PosX = TrajX[i*f]
		PosL = TrajL[i*f]
		Dyn_Mult_PosX[i] = PosX
		Dyn_Mult_PosYZ[i] = PosL
		
		if (spline_flag == 1)
			Multithread Field_Perp[][] = GetPerpendicularField(x, -Dyn_Mult_Ang[i], TrajX[i*f], TrajL[i*f], Dyn_Mult_Grid)(q)
		else
			Field_Perp[][] = GetPerpendicularFieldST(x, -Dyn_Mult_Ang[i], TrajX[i*f], TrajL[i*f], Dyn_Mult_Grid)(q)
		endif

		Bx[i][] = Field_Perp[q][0]
		By[i][] = Field_Perp[q][1]
		Bz[i][] = Field_Perp[q][2]		
	
		K0 = 0;K1 = 0;K2 = 0;K3 = 0;K4 = 0;K5 = 0;K6 = 0;K7 = 0;K8 = 0;K9 = 0;K10 = 0;
		K11 = 0;K12 = 0;K13 = 0;K14 = 0;K15 = 0;K16 = 0;K17 = 0;K18 = 0;K19 = 0 
			
		W_coef[] = 0
		if (normal_on == 1)
			CurveFit/L=(GridNrpts)/H=NormalCoefs/N=1/Q poly FittingOrder, Field_Perp[][normal_idx] /X=Dyn_Mult_Grid /D
		endif
		Dyn_Mult_Normal[i][] = W_coef[q]

		K0 = 0;K1 = 0;K2 = 0;K3 = 0;K4 = 0;K5 = 0;K6 = 0;K7 = 0;K8 = 0;K9 = 0;K10 = 0;
		K11 = 0;K12 = 0;K13 = 0;K14 = 0;K15 = 0;K16 = 0;K17 = 0;K18 = 0;K19 = 0 
	
		W_coef[] = 0
		if (skew_on == 1)
			CurveFit/L=(GridNrpts)/H=SkewCoefs/N=1/Q poly FittingOrder, Field_Perp[][skew_idx] /X=Dyn_Mult_Grid /D
		endif
		Dyn_Mult_Skew[i][] = W_coef[q]
	
	endfor

	Make/O/D/N=(FittingOrder) Dyn_Mult_Normal_Int, Dyn_Mult_Skew_Int

	for (n=0; n<FittingOrder; n=n+1)
	   	Temp[] = Dyn_Mult_Normal[p][n]
		Integrate/METH=1 Temp/X=Dyn_Mult_Pos/D=Temp_Integral
		Dyn_Mult_Normal_Int[n] = Temp_Integral[PosNrpts]
		
		Temp[] = Dyn_Mult_Skew[p][n]
		Integrate/METH=1 Temp/X=Dyn_Mult_Pos/D=Temp_Integral
		Dyn_Mult_Skew_Int[n] = Temp_Integral[PosNrpts]
	endfor
		
		
	Duplicate/D/O Dyn_Mult_Normal_Int Dyn_Mult_Normal_Norm
	Duplicate/D/O Dyn_Mult_Skew_Int   Dyn_Mult_Skew_Norm
	
	if (NormComponent == 2) 
		for (n=0;n<FittingOrder;n=n+1)
			Dyn_Mult_Normal_Norm[n] = ( ( Dyn_Mult_Normal_Int[n] / Dyn_Mult_Skew_Int[KNorm] ) * (Distcenter/1000)^(n-KNorm) )
			Dyn_Mult_Skew_Norm[n]   = ( ( Dyn_Mult_Skew_Int [n]  / Dyn_Mult_Skew_Int[KNorm] ) * (Distcenter/1000)^(n-KNorm) )		
		endfor
	else
		for (n=0;n<FittingOrder;n=n+1)
			Dyn_Mult_Normal_Norm[n] = ( ( Dyn_Mult_Normal_Int[n] / Dyn_Mult_Normal_Int[KNorm] ) * (Distcenter/1000)^(n-KNorm) )
			Dyn_Mult_Skew_Norm[n]   = ( ( Dyn_Mult_Skew_Int [n]  / Dyn_Mult_Normal_Int[KNorm] ) * (Distcenter/1000)^(n-KNorm) )		
		endfor
	endif
		
	Make/O/D/N=(GridNrpts) IntBx_X_TrajGrid,  IntBy_X_TrajGrid,  IntBz_X_TrajGrid
	
	for (j=0; j<GridNrpts; j=j+1)
		//Bx
		Temp[] = Bx[p][j]
		Integrate/METH=1 Temp/X=Dyn_Mult_Pos/D=Temp_Integral
		IntBx_X_TrajGrid[j] = Temp_Integral[PosNrpts]
		
		//By
		Temp[] = By[p][j]
		Integrate/METH=1 Temp/X=Dyn_Mult_Pos/D=Temp_Integral
		IntBy_X_TrajGrid[j] = Temp_Integral[PosNrpts]
		
		//Bz
		Temp[] = Bz[p][j]
		Integrate/METH=1 Temp/X=Dyn_Mult_Pos/D=Temp_Integral
		IntBz_X_TrajGrid[j] = Temp_Integral[PosNrpts]
		
	endfor

	Killwaves Bx, By, Bz
	Killwaves/Z W_coef, W_sigma, W_ParamConfidenceInterval, fit_Field_Perp
	Killwaves/Z Field_Perp, Temp_Integral, Temp
			
End


Function ResidualDynMultipolesCalc()
	     	
	NVAR StartXTraj        = :varsFieldMap:StartXTraj
	NVAR BeamDirection     = :varsFieldMap:BeamDirection
	NVAR FittingOrder	 	= :varsFieldMap:FittingOrderTraj
	NVAR NormComponent	 	= :varsFieldMap:DynNormComponent
	NVAR KNorm 				= :varsFieldMap:DynKNorm
	SVAR ResNormalCoefs    = :varsFieldMap:DynResNormalCoefs
	SVAR ResSkewCoefs      = :varsFieldMap:DynResSkewCoefs

	print ("Calculating Residual Multipoles over Trajectory X = " + num2str(StartXTraj/1000))
		
	Wave Dyn_Mult_Grid
	Wave Dyn_Mult_Normal_Int
	Wave Dyn_Mult_Skew_Int  
	
	variable BNorm 
	if (NormComponent == 2)
		BNorm = Dyn_Mult_Skew_Int[KNorm]
	else
		BNorm = Dyn_Mult_Normal_Int[KNorm]
	endif
	
	variable nrpts = numpnts(Dyn_Mult_Grid)

	Make/D/O/N=(nrpts) Dyn_Mult_Normal_Res = 0
	Make/D/O/N=(nrpts) Dyn_Mult_Skew_Res   = 0

	variable i
	for (i=0; i<FittingOrder; i=i+1)
		
		if (stringmatch(ResNormalCoefs[i], "0"))
			Dyn_Mult_Normal_Res += (Dyn_Mult_Normal_Int[i]/BNorm)*(Dyn_Mult_Grid ^ (i-KNorm))
		endif

		if (stringmatch(ResSkewCoefs[i], "0"))
			Dyn_Mult_Skew_Res += (Dyn_Mult_Skew_Int[i]/BNorm)*(Dyn_Mult_Grid ^ (i-KNorm))
		endif
		
	endfor
	
	for (i=0; i<nrpts; i=i+1)
		if (numtype(Dyn_Mult_Normal_Res[i]) == 1)
			Dyn_Mult_Normal_Res[i] = NaN
		endif
		
		if (numtype(Dyn_Mult_Skew_Res[i]) == 1)
			Dyn_Mult_Skew_Res[i] = NaN
		endif

	endfor
			
End


Function CalcDynIntegralsMultipolesToAll(ctrlName) : ButtonControl
	String ctrlName
	
	DoAlert 1, "Calculate dynamic multipoles for all fieldmaps?"
	if (V_flag != 1)
		return -1
	endif
	
	UpdateFieldMapDirs()
		
	Wave/T FieldMapDirs = root:wavesCAMTO:FieldMapDirs
	NVAR FieldMapCount  = root:varsCAMTO:FieldMapCount
	SVAR FieldMapDir= root:varsCAMTO:FieldMapDir
		
	DFREF df = GetDataFolderDFR()
	string dfc = GetDataFolder(0)
	
	variable i
	string tdf
	string empty = ""

	for (i=0; i < FieldMapCount; i=i+1)
		tdf = FieldMapDirs[i]
		FieldMapDir = tdf
		SetDataFolder root:$(tdf)
		CopyDynMultipolesConfig_(dfc)
		Print("Calculating Dynamic Integrals and Multipoles for " + tdf + ":")
		CalcDynIntegralsMultipoles(empty)
	endfor

	FieldMapDir = dfc
	SetDataFolder df
	
End


Window Find_Peaks() : Panel
	PauseUpdate; Silent 1		// building window...

	if (DataFolderExists("root:varsCAMTO")==0)
		DoAlert 0, "CAMTO variables not found."
		return 
	endif

	//Procura Janela e se estiver aberta, fecha antes de abrir novamente.
	string PanelName
	PanelName = WinList("Find_Peaks",";","")	
	if (stringmatch(PanelName, "Find_Peaks;"))
		Killwindow Find_Peaks
	endif	

	NewPanel/K=1/W=(1380,60,1703,527)
	
	SetDrawLayer UserBack
	SetDrawEnv fillpat= 0
	DrawRect 4,3,319,30
	SetDrawEnv fillpat= 0
	DrawRect 4,30,319,100
	SetDrawEnv fillpat= 0
	DrawRect 4,100,319,270
	SetDrawEnv fillpat= 0
	DrawRect 4,270,319,435
	SetDrawEnv fillpat= 0
	DrawRect 4,435,319,462
	
	TitleBox LXAxis,pos={65,4},size={63,22},title="Find Peaks and Zeros",fSize=19,frame=0,fStyle=1
	
	SetVariable PosXPeaks,pos={10,40},size={170,18},title="Position in X [mm] :"
		
	PopupMenu FieldAxisPeak, title = "Field Axis :", pos={200,40},size={106,21},proc=FieldAxisPeak
	PopupMenu FieldAxisPeak,disable=2,value= #"\"Bx;By;Bz\""

	SetVariable StepsYZPeaks,pos={10,70},size={280,18},title="Interpolation Step [mm] :"

	CheckBox CheckBoxPeaks, pos={10,113}, title="",mode=1,proc=SelectPeaksZeros

	PopupMenu PosNegPeak, pos={30,110},size={150,21},proc=PosNegPeaks,title = "Peaks :"
	PopupMenu PosNegPeak,disable=2,value= #"\"Positive Peaks;Negative Peaks;Both Peaks\""
	
	SetVariable NAmplPeaks,pos={10,140},size={305,18},title="Peak amplitude related to the maximum [%] :"
	SetVariable NAmplPeaks,limits={0,100,1}

	Button PeaksProc,pos={10,170},size={150,55},fSize=14,proc=FindPeaksProc,title="Find Peaks"
	Button PeaksProc,fStyle=1,disable=2
	TitleBox    AvgPeriodPeaksLabel,pos={180,170},size={120,18},frame=0,title="Average Period [mm]: "
	ValDisplay  AvgPeriodPeaks,pos={180,195},size={120,18}
	
	Button PeaksGraph,pos={15,235},size={140,24},proc=GraphPeaksProc,title="Show Peaks"
	Button PeaksGraph,fStyle=1,disable=2
	
	Button PeaksTable,pos={170,235},size={140,24},proc=TablePeaksProc,title="Show Table"
	Button PeaksTable,fStyle=1,disable=2

	CheckBox CheckBoxZeros, pos={10,278}, title="\tZeros:",mode=1,proc=SelectPeaksZeros

	SetVariable NAmplZeros,pos={10,305},size={305,18},title="Stop the search for amplitude lower than [%] :"
	SetVariable NAmplZeros,limits={0,100,1}

	Button ZerosProc,pos={10,335},size={150,55},fSize=14,proc=FindZerosProc,title="Find Zeros"
	Button ZerosProc,fStyle=1,disable=2
	TitleBox    AvgPeriodZerosLabel,pos={180,335},size={120,18},frame=0,title="Average Period [mm]: "
	ValDisplay  AvgPeriodZeros,pos={180,360},size={120,18}
	
	Button ZerosGraph,pos={15,400},size={140,24},proc=GraphZerosProc,title="Show Zeros"
	Button ZerosGraph,fStyle=1,disable=2
	
	Button ZerosTable,pos={170,400},size={140,24},proc=TableZerosProc,title="Show Table"
	Button ZerosTable,fStyle=1,disable=2
		
	SetVariable fieldmapdir,pos={17,440},size={290,18},title="FieldMap directory: "
	SetVariable fieldmapdir,noedit=1,value=root:varsCAMTO:FieldMapDir
	
	UpdateFieldMapDirs()
	UpdateFindPeaksPanel()
	
EndMacro


Function UpdateFindPeaksPanel()
	
	string PanelName
	PanelName = WinList("Find_Peaks",";","")	
	if (stringmatch(PanelName, "Find_Peaks;")==0)
		return -1
	endif
	
	SVAR df = root:varsCAMTO:FieldMapDir
	
	if (strlen(df) > 0)
		NVAR StartX = root:$(df):varsFieldMap:StartX
		NVAR EndX = root:$(df):varsFieldMap:EndX
		NVAR StepsX = root:$(df):varsFieldMap:StepsX
		NVAR FieldAxisPeak = root:$(df):varsFieldMap:FieldAxisPeak
		NVAR PeaksPosNeg = root:$(df):varsFieldMap:PeaksPosNeg
		NVAR PeaksSelected = root:$(df):varsFieldMap:PeaksSelected
	
		SetVariable PosXPeaks, win=Find_Peaks, value= root:$(df):varsFieldMap:PosXAux
		SetVariable PosXPeaks, win=Find_Peaks,limits={StartX, EndX, StepsX}
		PopupMenu FieldAxisPeak, win=Find_Peaks,disable=0, mode=FieldAxisPeak
		SetVariable StepsYZPeaks, win=Find_Peaks,value= root:$(df):varsFieldMap:StepsYZPeaks
		SetVariable StepsYZPeaks, win=Find_Peaks,limits={0,inf,0}

		PopupMenu PosNegPeak, win=Find_Peaks, mode=PeaksPosNeg		
		SetVariable NAmplPeaks, win=Find_Peaks,value= root:$(df):varsFieldMap:NAmplPeaks
		SetVariable NAmplZeros, win=Find_Peaks,value= root:$(df):varsFieldMap:NAmplZeros
		ValDisplay  AvgPeriodPeaks, win=Find_Peaks, value=#("root:"+ df + ":varsFieldMap:AvgPeriodPeaks" )
		ValDisplay  AvgPeriodZeros, win=Find_Peaks, value=#("root:"+ df + ":varsFieldMap:AvgPeriodZeros" )
		
		CheckBox CheckBoxPeaks, win=Find_Peaks, disable=0, value=0
		CheckBox CheckBoxZeros, win=Find_Peaks, disable=0, value=0
		
		if (PeaksSelected == 1)
			CheckBox CheckBoxPeaks, win=Find_Peaks, value=1		
			SetPeaksDisable(0)
			SetZerosDisable(2)
		else
			CheckBox CheckBoxZeros, win=Find_Peaks, value=1
			SetPeaksDisable(2)
			SetZerosDisable(0)
		endif
		
	else
		CheckBox CheckBoxPeaks, win=Find_Peaks, disable=2
		CheckBox CheckBoxZeros, win=Find_Peaks, disable=2
		SetPeaksDisable(2)
		SetZerosDisable(2)	
	endif
	
End


Function SelectPeaksZeros(cb) : CheckBoxControl
	STRUCT WMCheckboxAction& cb
	
	SVAR df = root:varsCAMTO:FieldMapDir
		
	if (cb.eventCode == -1)
		return 0
	endif
			
	strswitch (cb.ctrlName)
		case "CheckBoxPeaks":
			CheckBox CheckBoxZeros,win=Find_Peaks,value=0
			SetZerosDisable(2)
			
			if (strlen(df) > 0)
				NVAR PeaksSelected = root:$(df):varsFieldMap:PeaksSelected
				PeaksSelected = 1
				SetPeaksDisable(0)
			else
				SetPeaksDisable(2)
			endif
					
			break
		case "CheckBoxZeros":
			CheckBox CheckBoxPeaks,win=Find_Peaks,value=0
			SetPeaksDisable(2)
				
			if (strlen(df) > 0)
				NVAR PeaksSelected = root:$(df):varsFieldMap:PeaksSelected
				PeaksSelected = 0
				SetZerosDisable(0)
			else
				SetZerosDisable(2)
			endif
								
			break
	endswitch
	return 0
End


Function SetPeaksDisable(disable)
	variable disable
	PopupMenu PosNegPeak,win=Find_Peaks,disable=disable
	SetVariable NAmplPeaks,win=Find_Peaks,disable=disable
	ValDisplay AvgPeriodPeaks,win=Find_Peaks,disable=disable
	TitleBox AvgPeriodPeaksLabel,win=Find_Peaks,disable=disable
	Button PeaksProc, win=Find_Peaks, disable=disable
	Button PeaksGraph,win=Find_Peaks, disable=disable
	Button PeaksTable,win=Find_Peaks, disable=disable
End	


Function SetZerosDisable(disable)
	variable disable
	ValDisplay AvgPeriodZeros,win=Find_Peaks,disable=disable
	SetVariable NAmplZeros,win=Find_Peaks,disable=disable
	TitleBox AvgPeriodZerosLabel,win=Find_Peaks,disable=disable
	Button ZerosProc, win=Find_Peaks, disable=disable
	Button ZerosGraph,win=Find_Peaks, disable=disable
	Button ZerosTable,win=Find_Peaks, disable=disable
End


Function FieldAxisPeak(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	SVAR FieldAxisPeakStr = :varsFieldMap:FieldAxisPeakStr
	NVAR FieldAxisPeak    = :varsFieldMap:FieldAxisPeak 
	FieldAxisPeak = popNum
	
	if (FieldAxisPeak == 1)
		FieldAxisPeakStr = "Bx"
	elseif (FieldAxisPeak == 2) 
		FieldAxisPeakStr = "By"
	elseif (FieldAxisPeak == 3)
		FieldAxisPeakStr = "Bz"
	endif
	
End


Function PosNegPeaks(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	NVAR PeaksPosNeg = :varsFieldMap:PeaksPosNeg 
	PeaksPosNeg = popNum
End


Function FindPeaksProc(ctrlName)
	String ctrlName

	NVAR StartYZ        = :varsFieldMap:StartYZ
	NVAR EndYZ          = :varsFieldMap:EndYZ
	NVAR NPointsYZ      = :varsFieldMap:NPointsYZ
	NVAR PosXAux        = :varsFieldMap:PosXAux
	NVAR FieldAxisPeak  = :varsFieldMap:FieldAxisPeak	
	NVAR PeaksPosNeg    = :varsFieldMap:PeaksPosNeg
	NVAR NAmplPeaks     = :varsFieldMap:NAmplPeaks
	NVAR StepsYZPeaks   = :varsFieldMap:StepsYZPeaks
	NVAR AvgPeriodPeaks = :varsFieldMap:AvgPeriodPeaks
	
	variable NPointsYZPeak = ((EndYZ - StartYZ)/StepsYZPeaks) + 1
		
	variable i
	variable ii
	variable j	
	string Name
	variable valorpeak
	variable Maximum
	variable Minimum
	variable Baseline
	
	Killwaves/Z PositionPeaksNeg, ValuePeaksNeg, PositionPeaksPos, ValuePeaksPos
	if (PeaksPosNeg == 1)
		Make/D/O/N=(1) PositionPeaksPos
		Make/D/O/N=(1) ValuePeaksPos	
	elseif (PeaksPosNeg == 2)
		Make/D/O/N=(1) PositionPeaksNeg
		Make/D/O/N=(1) ValuePeaksNeg
	elseif (PeaksPosNeg == 3)
		Make/D/O/N=(1) PositionPeaksPos
		Make/D/O/N=(1) ValuePeaksPos	
		Make/D/O/N=(1) PositionPeaksNeg
		Make/D/O/N=(1) ValuePeaksNeg		
	endif

	if (FieldAxisPeak == 1)
		Name = "RaiaBx_X"+num2str(PosXAux/1000)
		
	elseif (FieldAxisPeak == 2)
		Name = "RaiaBy_X"+num2str(PosXAux/1000)	

	elseif (FieldAxisPeak == 3)	
		Name = "RaiaBz_X"+num2str(PosXAux/1000)	

	endif

	string Interp_Field_Name
	Interp_Field_Name = "Interp_" + Name
	
	Wave C_PosYZ	
	Wave Field = $Name
	
	if (NPointsYZPeak == NPointsYZ)
		Duplicate/O C_PosYZ, Interp_C_PosYZ
		Duplicate/O Field, $(Interp_Field_Name)
		Wave Interp_Field = $(Interp_Field_Name)
	else
		Interpolate2/T=2/N=(NPointsYZPeak)/X=Interp_C_PosYZ/Y=$(Interp_Field_Name) C_PosYZ, Field
		Wave Interp_Field = $(Interp_Field_Name)
	endif
	
	//Get Maximum and Minimun
	Maximum = WaveMax(Interp_Field)
	Minimum = WaveMin(Interp_Field)
	
	//Baseline
	if (PeaksPosNeg == 1 || PeaksPosNeg == 3)
		Baseline = (Maximum - Maximum * (NAmplPeaks/100))
			
		valorpeak = Baseline			
		j = 0

		//Find Peaks
		for (i=0; i<NPointsYZPeak; i=i+1)
			if (Interp_Field[i] > Baseline)
				if (valorpeak < Interp_Field[i])
					valorpeak = Interp_Field[i]
					PositionPeaksPos[j] = Interp_C_PosYZ[i]
					ValuePeaksPos[j] = Interp_Field[i]
				endif				
			else
				if (Interp_Field[i-1] > Baseline)
					valorpeak = Baseline
					j = j + 1
					InsertPoints j, 1, PositionPeaksPos
					InsertPoints j, 1, ValuePeaksPos					
				endif
			endif
		endfor			
		DeletePoints j, 1, PositionPeaksPos
		DeletePoints j, 1, ValuePeaksPos		
		
		wavestats/Q ValuePeaksPos
		Print(" ")
		Print("Positive Peaks")
		Print("Average : " + num2str(V_avg))
		Print("Standard Deviation : " + num2str(V_sdev))	
		Print("Error : "+ num2str(abs(V_sdev/V_avg*100)) + "%")
		EraseStatsVariables()	
		
		Make/O/N=(numpnts(PositionPeaksPos) - 1) PositionPeaksPosDiff
		
		for (i=0; i<numpnts(PositionPeaksPosDiff); i=i+1)
			PositionPeaksPosDiff[i] = PositionPeaksPos[i+1] - PositionPeaksPos[i]
		endfor
		
		variable AvgPeriodPeaksPos = Mean(PositionPeaksPosDiff)
		
		Killwaves/Z PositionPeaksPosDiff
		
	endif		
				
	if (PeaksPosNeg == 2 || PeaksPosNeg == 3)
		Baseline = (Minimum - Minimum * (NAmplPeaks/100))
			
		valorpeak = Baseline			
		j = 0

		//Find Peaks
		for (i=0; i<NPointsYZPeak; i=i+1)
			if (Interp_Field[i] < Baseline)
				if (valorpeak > Interp_Field[i])
					valorpeak = Interp_Field[i]
					PositionPeaksNeg[j] = Interp_C_PosYZ[i]
					ValuePeaksNeg[j] = Interp_Field[i]
				endif				
			else
				if (Interp_Field[i-1] < Baseline)
					valorpeak = Baseline
					j = j + 1
					InsertPoints j, 1, PositionPeaksNeg
					InsertPoints j, 1, ValuePeaksNeg					
				endif
			endif
		endfor			
		DeletePoints j, 1, PositionPeaksNeg
		DeletePoints j, 1, ValuePeaksNeg
		
		wavestats/Q ValuePeaksNeg
		Print(" ")
		Print("Negative Peaks")
		Print("Average : " + num2str(V_avg))
		Print("Standard Deviation : " + num2str(V_sdev))		
		Print("Error : "+ num2str(abs(V_sdev/V_avg*100)) + "%")
		EraseStatsVariables()	

		Make/O/N=(numpnts(PositionPeaksNeg) - 1) PositionPeaksNegDiff
	
		for (i=0; i<numpnts(PositionPeaksNegDiff); i=i+1)
			PositionPeaksNegDiff[i] = PositionPeaksNeg[i+1] - PositionPeaksNeg[i]
		endfor

		variable AvgPeriodPeaksNeg = Mean(PositionPeaksNegDiff)

		Killwaves/Z PositionPeaksNegDiff
		
	endif
	
	if (PeaksPosNeg == 1)
		AvgPeriodPeaks = 1000*(AvgPeriodPeaksPos)
		
	elseif (PeaksPosNeg == 2)
		AvgPeriodPeaks = 1000*(AvgPeriodPeaksNeg)
		
	elseif (PeaksPosNeg == 3)
		AvgPeriodPeaks = 1000*(AvgPeriodPeaksPos + AvgPeriodPeaksNeg)/2
		
	endif
	
End


Function GetAvgPositivePeaks(Field, Ampl)
	Wave Field
	variable Ampl
	
	variable i, j
	variable npts, maximum, minimum, baseline, valorpeak
	
	Make/D/O/N=(1)/FREE PeaksValues	
			
	//Get Maximum and Minimun
	maximum = WaveMax(Field)
	minimum = WaveMin(Field)
	
	npts = numpnts(Field)
	
	//Baseline
	baseline = (maximum - maximum * (Ampl/100))
	valorpeak = baseline			
	j = 0

	//Find Peaks
	for (i=0; i<npts; i=i+1)
		if (Field[i] > baseline)
			if (valorpeak < Field[i])
				valorpeak = Field[i]
				PeaksValues[j] = Field[i]
			endif				
		else
			if (Field[i-1] > baseline)
				valorpeak = baseline
				j = j + 1
				InsertPoints j, 1, PeaksValues					
			endif
		endif
	endfor			
	DeletePoints j, 1, PeaksValues	
		
	return Mean(PeaksValues)
End


Function GetAvgNegativePeaks(Field, Ampl)
	Wave Field
	variable Ampl
	
	variable i, j
	variable npts, maximum, minimum, baseline, valorpeak
	
	Make/D/O/N=(1) PeaksValues	
			
	//Get Maximum and Minimun
	maximum = WaveMax(Field)
	minimum = WaveMin(Field)
	
	npts = numpnts(Field)
	
	//Baseline
	baseline = (minimum - minimum * (Ampl/100))
	valorpeak = baseline			
	j = 0

	//Find Peaks
	for (i=0; i<npts; i=i+1)
		if (Field[i] < baseline)
			if (valorpeak > Field[i])
				valorpeak = Field[i]
				PeaksValues[j] = Field[i]
			endif				
		else
			if (Field[i-1] < baseline)
				valorpeak = baseline
				j = j + 1
				InsertPoints j, 1, PeaksValues					
			endif
		endif
	endfor			
	DeletePoints j, 1, PeaksValues	
		
	return Mean(PeaksValues)
End


Function GraphPeaksProc(ctrlName) : ButtonControl
	String ctrlName
		
	NVAR PosXAux       = :varsFieldMap:PosXAux
	NVAR FieldAxisPeak = :varsFieldMap:FieldAxisPeak	
	
	Wave Interp_C_PosYZ
	
	string Name
	
	if (FieldAxisPeak == 1)
		Name = "RaiaBx_X"+num2str(PosXAux/1000)
			
	elseif (FieldAxisPeak == 2)
		Name = "RaiaBy_X"+num2str(PosXAux/1000)	
	
	elseif (FieldAxisPeak == 3)	
		Name = "RaiaBz_X"+num2str(PosXAux/1000)	
	
	endif
	
	Wave Interp_Field = $("Interp_" + Name)
	
	string PanelName
	PanelName = WinList("PeaksGraph",";","")	
	if (stringmatch(PanelName, "PeaksGraph;"))
		Killwindow PeaksGraph
	endif
		
	if ((WaveExists(ValuePeaksPos)) || (WaveExists(ValuePeaksNeg)))	
		if (WaveExists(ValuePeaksPos))
			Display/N=PeaksGraph/K=1 ValuePeaksPos vs PositionPeaksPos
			if (WaveExists(ValuePeaksNeg))			
				Appendtograph/W=PeaksGraph ValuePeaksNeg vs PositionPeaksNeg
			endif
		elseif (WaveExists(ValuePeaksNeg))
			Display/N=PeaksGraph/K=1 ValuePeaksNeg vs PositionPeaksNeg
		endif
		
		Label bottom "\\Z12Longitudinal Position YZ [m]"
		if (FieldAxisPeak == 1)
			Label left "\\Z12Field Bx [T]"
		elseif (FieldAxisPeak == 2)
			Label left "\\Z12Field By [T]"
		elseif (FieldAxisPeak == 3)
			Label left "\\Z12Field Bz [T]"
		endif
		
		TextBox/W=PeaksGraph/C/N=text0/A=MC "PosX [mm] = "+ num2str(PosXAux)
		
		ModifyGraph/W=PeaksGraph mode=3,marker=19,msize=2
	
		if (WaveExists(ValuePeaksNeg))
			ModifyGraph/W=PeaksGraph rgb(ValuePeaksNeg)=(0,9472,39168)
		endif
		
		AppendToGraph/C=(0,0,0) Interp_Field vs Interp_C_PosYZ
		
	endif	
End


Function TablePeaksProc(ctrlName) : ButtonControl
	String ctrlName

	string PanelName
	PanelName = WinList("PeaksTable",";","")	
	if (stringmatch(PanelName, "PeaksTable;"))
		Killwindow PeaksTable
	endif
	
	if ((WaveExists(ValuePeaksPos)) || (WaveExists(ValuePeaksNeg)))	
		if (WaveExists(ValuePeaksPos))
			Edit/N=PeaksTable/K=1 PositionPeaksPos, ValuePeaksPos
			if (WaveExists(ValuePeaksNeg))			
				Appendtotable/W=PeaksTable PositionPeaksNeg, ValuePeaksNeg
			endif
		elseif (WaveExists(ValuePeaksNeg))
			Edit/N=PeaksTable/K=1 PositionPeaksNeg, ValuePeaksNeg
		endif
	endif
End


Function FindZerosProc(ctrlName)
	String ctrlName

	NVAR StartYZ        = :varsFieldMap:StartYZ
	NVAR EndYZ          = :varsFieldMap:EndYZ
	NVAR NPointsYZ      = :varsFieldMap:NPointsYZ
	NVAR PosXAux        = :varsFieldMap:PosXAux
	NVAR FieldAxisPeak  = :varsFieldMap:FieldAxisPeak	
	NVAR StepsYZPeaks   = :varsFieldMap:StepsYZPeaks
	NVAR NAmplZeros     = :varsFieldMap:NAmplZeros
	NVAR AvgPeriodZeros = :varsFieldMap:AvgPeriodZeros
	
	variable NPointsYZPeak = ((EndYZ - StartYZ)/StepsYZPeaks) + 1
	
	string Name
	variable i, idx0, idx1 
	variable Baseline, startx, endx
	variable pos0, pos1, field0, field1
	
	if (FieldAxisPeak == 1)
		Name = "RaiaBx_X"+num2str(PosXAux/1000)
		
	elseif (FieldAxisPeak == 2)
		Name = "RaiaBy_X"+num2str(PosXAux/1000)	

	elseif (FieldAxisPeak == 3)	
		Name = "RaiaBz_X"+num2str(PosXAux/1000)	

	endif

	string Interp_Field_Name
	Interp_Field_Name = "Interp_" + Name
	
	Wave C_PosYZ	
	Wave Field = $Name
	
	if (NPointsYZPeak == NPointsYZ)
		Duplicate/O C_PosYZ, Interp_C_PosYZ
		Duplicate/O Field, $(Interp_Field_Name)
		Wave Interp_Field = $(Interp_Field_Name)
	else
		Interpolate2/T=2/N=(NPointsYZPeak)/X=Interp_C_PosYZ/Y=$(Interp_Field_Name) C_PosYZ, Field
		Wave Interp_Field = $(Interp_Field_Name)
	endif

	Duplicate/O Interp_Field, Interp_Field_Abs
	for (i=0; i<NPointsYZPeak; i=i+1)
		Interp_Field_Abs[i] = Abs(Interp_Field_Abs[i])
	endfor
	
	// Search range
	Baseline = (NAmplZeros/100)*WaveMax(Interp_Field_Abs)
	FindLevels/EDGE=0/P/Q Interp_Field_Abs, Baseline
	Wave W_FindLevels
	if (numpnts(W_FindLevels) > 1)
		startx = Floor(W_FindLevels[0])
		endx = Ceil(W_FindLevels[numpnts(W_FindLevels)-1])
	else
		startx = 0
		endx = NPointsYZPeak-1
	endif
	Killwaves/Z W_FindLevels
		
	// Search for zeros
	FindLevels/EDGE=0/P/Q/R=(startx,endx) Interp_Field, 0
	Print(" ")
	Print("Find Zeros")
	Print("Number of zeros found : " + num2str(V_LevelsFound))
	
	Wave W_FindLevels
	Make/D/O/N=(numpnts(W_FindLevels)) PositionZeros	
	Make/D/O/N=(numpnts(W_FindLevels)) ValueZeros	
	
	for (i=0; i<numpnts(W_FindLevels); i=i+1)
		idx0 = Floor(W_FindLevels[i])
		idx1 = Ceil(W_FindLevels[i])
		pos0 = Interp_C_PosYZ[idx0]
		pos1 = Interp_C_PosYZ[idx1]
		field0 = Interp_Field[idx0]
		field1 = Interp_Field[idx1]
		PositionZeros[i] = pos0*(1 - (W_FindLevels[i] - idx0)/(idx1 -idx0)) + pos1*((W_FindLevels[i] - idx0)/(idx1 -idx0))
		ValueZeros[i] = field0*(1 - (W_FindLevels[i] - idx0)/(idx1 -idx0)) + field1*((W_FindLevels[i] - idx0)/(idx1 -idx0))
	endfor
	
	Killwaves/Z W_FindLevels
	
	Make/O/N=(numpnts(PositionZeros) - 1) PositionZerosDiff
	for (i=0; i<numpnts(PositionZerosDiff); i=i+1)
		PositionZerosDiff[i] = PositionZeros[i+1] - PositionZeros[i]
	endfor
	variable AvgPeriod = Mean(PositionZerosDiff)

	AvgPeriodZeros = 2*AvgPeriod*1000

	Killwaves/Z PositionZerosDiff
	
End


Function GraphZerosProc(ctrlName) : ButtonControl
	String ctrlName
		
	NVAR PosXAux       = :varsFieldMap:PosXAux
	NVAR FieldAxisPeak = :varsFieldMap:FieldAxisPeak	
	
	Wave Interp_C_PosYZ
	
	string Name
	
	if (FieldAxisPeak == 1)
		Name = "RaiaBx_X"+num2str(PosXAux/1000)
			
	elseif (FieldAxisPeak == 2)
		Name = "RaiaBy_X"+num2str(PosXAux/1000)	
	
	elseif (FieldAxisPeak == 3)	
		Name = "RaiaBz_X"+num2str(PosXAux/1000)	
	
	endif
	
	Wave Interp_Field = $("Interp_" + Name)
	
	string PanelName
	PanelName = WinList("ZerosGraph",";","")	
	if (stringmatch(PanelName, "ZerosGraph;"))
		Killwindow ZerosGraph
	endif
		
	if ((WaveExists(ValueZeros)) || (WaveExists(PositionZeros)))	
		Display/N=ZerosGraph/K=1 ValueZeros vs PositionZeros
		
		Label bottom "\\Z12Longitudinal Position YZ [m]"
		if (FieldAxisPeak == 1)
			Label left "\\Z12Field Bx [T]"
		elseif (FieldAxisPeak == 2)
			Label left "\\Z12Field By [T]"
		elseif (FieldAxisPeak == 3)
			Label left "\\Z12Field Bz [T]"
		endif
		
		TextBox/W=ZerosGraph/C/N=text0/A=MC "PosX [mm] = "+ num2str(PosXAux)
		
		ModifyGraph/W=ZerosGraph mode=3,marker=19,msize=1.5
			
		AppendToGraph/C=(0,0,0) Interp_Field vs Interp_C_PosYZ
		
	endif	
End


Function TableZerosProc(ctrlName) : ButtonControl
	String ctrlName

	string PanelName
	PanelName = WinList("ZerosTable",";","")	
	if (stringmatch(PanelName, "ZerosTable;"))
		Killwindow ZerosTable
	endif
	
	if ((WaveExists(ValueZeros)) || (WaveExists(PositionZeros)))	
		Edit/N=ZerosTable/K=1 PositionZeros, ValueZeros
	endif
End


Window Phase_Error() : Panel
	PauseUpdate; Silent 1
	
	if (DataFolderExists("root:varsCAMTO")==0)
		DoAlert 0, "CAMTO variables not found."
		return 
	endif

	string PanelName
	PanelName = WinList("Phase_Error",";","")	
	if (stringmatch(PanelName, "Phase_Error;"))
		Killwindow Phase_Error
	endif	
	
	NewPanel/K=1/W=(80,260,404,648)
	SetDrawLayer UserBack
	SetDrawEnv fillpat= 0
	DrawRect 3,3,320,75
	SetDrawEnv fillpat= 0
	DrawRect 3,75,320,155
	SetDrawEnv fillpat= 0
	DrawRect 3,155,320,315	
	SetDrawEnv fillpat= 0
	DrawRect 3,315,320,353
	SetDrawEnv fillpat= 0
	DrawRect 3,353,320,383
						
	TitleBox    traj,pos={10,25},size={90,16},fSize=14,fStyle=1,frame=0,title="Trajectory"
	ValDisplay  traj_x,pos={110,10},size={200,18},title="Start X [mm]:    "
	ValDisplay  traj_angle,pos={110,30},size={200,18},title="Angle XY(Z) [°]:"
	ValDisplay  traj_yz,pos={110,50},size={200,18},title="Start YZ [mm]:  "

	TitleBox    period,pos={10,105},size={90,16},fSize=14,fStyle=1,frame=0,title="ID Period"
	CheckBox    chb_period_peaks,pos={90,88}, title="",mode=1,proc=SelectIDPeriod
	ValDisplay  period_peaks,pos={110,88},size={200,18},title="Avg. from peaks [mm]:"
	CheckBox    chb_period_zeros,pos={90,108}, title="",mode=1,proc=SelectIDPeriod
	ValDisplay  period_zeros,pos={110,108},size={200,18},title="Avg. from  zeros [mm]:"
	CheckBox    chb_period_nominal,pos={90,128}, title="",mode=1,proc=SelectIDPeriod
	SetVariable period_nominal,pos={110,128},size={200,18},title="Nominal value [mm]:"
	SetVariable period_nominal, limits={0,inf,1}
	
	TitleBox title,pos={60,160},size={200,24},title="Insertion Device Phase Error",fSize=16,fStyle=1,frame=0

	SetVariable cut_periods,pos={20,185},size={280,16},title="Number of periods to skip at the endings: ", limits={0,1000,1}
	
	PopupMenu semi_period_pos,pos={20,210},size={100,20},proc=PopupSemiPeriodPos,title="Get semi-period positions from: "
	PopupMenu semi_period_pos,value= #"\"Peaks;Zeros\""
	
	Button calc_phase_error,pos={20,235},size={140,70},proc=CalcPhaseError,fSize=14,title="Calculate \nPhase Error"
	Button calc_phase_error,disable=2,fStyle=1
	TitleBox    phase_error_label,pos={180,245},size={120,18},frame=0,title="RMS Phase Error [°]: "
	ValDisplay  phase_error,pos={180,270},size={120,18}
	
	Button phase_error_graph,pos={20,322},size={140,24},proc=ShowPhaseError,title="Show Phase Error"
	Button phase_error_graph,fStyle=1,disable=2
	
	Button phase_error_table,pos={170,322},size={140,24},proc=TablePhaseError,title="Show Table"
	Button phase_error_table,fStyle=1,disable=2
	
	SetVariable fieldmapdir,pos={20,360},size={290,18},title="Field Map Directory: "
	SetVariable fieldmapdir,noedit=1,value=root:varsCAMTO:FieldMapDir
	
	UpdateFieldMapDirs()
	UpdatePhaseErrorPanel()
	
EndMacro


Function UpdatePhaseErrorPanel()

	string PanelName
	PanelName = WinList("Phase_Error",";","")	
	if (stringmatch(PanelName, "Phase_Error;")==0)
		return -1
	endif
	
	SVAR df = root:varsCAMTO:FieldMapDir
		
	if (strlen(df) > 0)
		NVAR PeriodPeaksZerosNominal = root:$(df):varsFieldMap:PeriodPeaksZerosNominal
		NVAR SemiPeriodsPeaksZeros = root:$(df):varsFieldMap:SemiPeriodsPeaksZeros
				
		ValDisplay traj_x, win=Phase_Error, value=#("root:"+ df + ":varsFieldMap:StartXTraj" )
		ValDisplay traj_angle,win=Phase_Error,value=#("root:"+ df + ":varsFieldMap:EntranceAngle" )
		ValDisplay traj_yz, win=Phase_Error, value=#("root:"+ df + ":varsFieldMap:StartYZTraj" )

		ValDisplay  period_peaks, win=Phase_Error, value=#("root:"+ df + ":varsFieldMap:AvgPeriodPeaks" )
		ValDisplay  period_zeros, win=Phase_Error, value=#("root:"+ df + ":varsFieldMap:AvgPeriodZeros" )
		SetVariable period_nominal, win=Phase_Error, value=root:$(df):varsFieldMap:IDPeriodNominal

		CheckBox chb_period_peaks,win=Phase_Error,disable=0
		CheckBox chb_period_zeros,win=Phase_Error,disable=0
		CheckBox chb_period_nominal,win=Phase_Error,disable=0

		SetVariable cut_periods, win=Phase_Error, value=root:$(df):varsFieldMap:IDCutPeriods
		PopupMenu semi_period_pos,win=Phase_Error,disable=0, mode=SemiPeriodsPeaksZeros
		
		Button calc_phase_error,win=Phase_Error,disable=0
		ValDisplay phase_error, win=Phase_Error, value=#("root:"+ df + ":varsFieldMap:IDPhaseError" )
		Button phase_error_graph,win=Phase_Error,disable=0
		Button phase_error_table,win=Phase_Error,disable=0

		if (PeriodPeaksZerosNominal == 0)
			CheckBox chb_period_peaks,win=Phase_Error,value=1
			CheckBox chb_period_zeros,win=Phase_Error,value=0
			CheckBox chb_period_nominal,win=Phase_Error,value=0
			ValDisplay  period_peaks, win=Phase_Error, disable=0
			ValDisplay  period_zeros, win=Phase_Error, disable=2
			SetVariable period_nominal, win=Phase_Error, disable=2
		elseif (PeriodPeaksZerosNominal == 1)
			CheckBox chb_period_peaks,win=Phase_Error,value=0
			CheckBox chb_period_zeros,win=Phase_Error,value=1
			CheckBox chb_period_nominal,win=Phase_Error,value=0
			ValDisplay  period_peaks, win=Phase_Error, disable=2
			ValDisplay  period_zeros, win=Phase_Error, disable=0
			SetVariable period_nominal, win=Phase_Error, disable=2
		else
			CheckBox chb_period_peaks,win=Phase_Error,value=0
			CheckBox chb_period_zeros,win=Phase_Error,value=0
			CheckBox chb_period_nominal,win=Phase_Error,value=1
			ValDisplay  period_peaks, win=Phase_Error, disable=2
			ValDisplay  period_zeros, win=Phase_Error, disable=2
			SetVariable period_nominal, win=Phase_Error, disable=0		
		endif

	else
		PopupMenu semi_period_pos,win=Phase_Error,disable=2
		Button calc_phase_error,win=Phase_Error,disable=2
		Button phase_error_graph,win=Phase_Error,disable=2
		Button phase_error_table,win=Phase_Error,disable=2
		CheckBox chb_period_peaks,win=Phase_Error,disable=2
		CheckBox chb_period_zeros,win=Phase_Error,disable=2
		CheckBox chb_period_nominal,win=Phase_Error,disable=2
		ValDisplay  period_peaks, win=Phase_Error, disable=2
		ValDisplay  period_zeros, win=Phase_Error, disable=2
		SetVariable period_nominal, win=Phase_Error, disable=2		
	endif
	
End


Function SelectIDPeriod(cb) : CheckBoxControl
	STRUCT WMCheckboxAction& cb
	
	SVAR df = root:varsCAMTO:FieldMapDir
		
	if (cb.eventCode == -1)
		return 0
	endif
			
	strswitch (cb.ctrlName)
		case "chb_period_peaks":
			CheckBox chb_period_zeros,win=Phase_Error,value=0
			CheckBox chb_period_nominal,win=Phase_Error,value=0
			ValDisplay  period_peaks, win=Phase_Error, disable=0
			ValDisplay  period_zeros, win=Phase_Error, disable=2
			SetVariable period_nominal, win=Phase_Error, disable=2
			
			if (strlen(df) > 0)
				NVAR PeriodPeaksZerosNominal = root:$(df):varsFieldMap:PeriodPeaksZerosNominal
				PeriodPeaksZerosNominal = 0
			endif
					
			break
		case "chb_period_zeros":
			CheckBox chb_period_peaks,win=Phase_Error,value=0
			CheckBox chb_period_nominal,win=Phase_Error,value=0
			ValDisplay  period_peaks, win=Phase_Error, disable=2
			ValDisplay  period_zeros, win=Phase_Error, disable=0
			SetVariable period_nominal, win=Phase_Error, disable=2
					
			if (strlen(df) > 0)
				NVAR PeriodPeaksZerosNominal = root:$(df):varsFieldMap:PeriodPeaksZerosNominal
				PeriodPeaksZerosNominal = 1
			endif
								
			break
		case "chb_period_nominal":
			CheckBox chb_period_peaks,win=Phase_Error,value=0
			CheckBox chb_period_zeros,win=Phase_Error,value=0
			ValDisplay  period_peaks, win=Phase_Error, disable=2
			ValDisplay  period_zeros, win=Phase_Error, disable=2
			SetVariable period_nominal, win=Phase_Error, disable=0
					
			if (strlen(df) > 0)
				NVAR PeriodPeaksZerosNominal = root:$(df):varsFieldMap:PeriodPeaksZerosNominal
				PeriodPeaksZerosNominal = 2
			endif
								
			break
	endswitch
	return 0
End


Function PopupSemiPeriodPos(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	NVAR SemiPeriodsPeaksZeros = :varsFieldMap:SemiPeriodsPeaksZeros
	SemiPeriodsPeaksZeros = popNum
	
End

Function CalcPhaseError(ctrlName) : ButtonControl
	String ctrlName

   	NVAR Charge     = root:varsCAMTO:Charge
	NVAR Mass       = root:varsCAMTO:Mass
	NVAR LightSpeed = root:varsCAMTO:LightSpeed
	NVAR TrajShift  = root:varsCAMTO:TrajShift

	NVAR StartXTraj = :varsFieldMap:StartXTraj
	NVAR BeamDirection = :varsFieldMap:BeamDirection
	
	NVAR FieldX = :varsFieldMap:FieldX
	NVAR FieldY = :varsFieldMap:FieldY
	NVAR FieldZ = :varsFieldMap:FieldZ
	
	NVAR NAmplPeaks     = :varsFieldMap:NAmplPeaks
	NVAR NAmplZeros     = :varsFieldMap:NAmplZeros

	NVAR SemiPeriodsPeaksZeros = :varsFieldMap:SemiPeriodsPeaksZeros	
	NVAR PeriodPeaksZerosNominal = :varsFieldMap:PeriodPeaksZerosNominal
	NVAR AvgPeriodPeaks = :varsFieldMap:AvgPeriodPeaks
	NVAR AvgPeriodZeros = :varsFieldMap:AvgPeriodZeros
	NVAR IDPeriodNominal = :varsFieldMap:IDPeriodNominal
	
	NVAR IDPeriod       = :varsFieldMap:IDPeriod
	NVAR IDCutPeriods   = :varsFieldMap:IDCutPeriods
	NVAR IDPhaseError   = :varsFieldMap:IDPhaseError
	
	Wave/Z TrajH = $"TrajX"+num2str(StartXTraj/1000)
	Wave/Z PositionPeaksPos
	Wave/Z PositionPeaksNeg

	if (WaveExists(TrajH) == 0)
		DoAlert 0,"Trajectory not found."
		return -1	
	endif

	if (PeriodPeaksZerosNominal == 0)
		IDPeriod = AvgPeriodPeaks
	elseif (PeriodPeaksZerosNominal == 1)
		IDPeriod = AvgPeriodZeros
	else
		IDPeriod = IDPeriodNominal
	endif

	if (IDPeriod == 0)
		DoAlert 0,"ID Period must be a non-zero positive value."
		return -1	
	endif

	if (BeamDirection == 1)
		Wave/Z TrajL = $"TrajY"+num2str(StartXTraj/1000)
		Wave/Z TrajV = $"TrajZ"+num2str(StartXTraj/1000)
	else
		Wave/Z TrajV = $"TrajY"+num2str(StartXTraj/1000)
		Wave/Z TrajL = $"TrajZ"+num2str(StartXTraj/1000)	
	endif
	
	variable energy = GetParticleEnergy()
	
	variable TotalEnergy_J  = energy*1E9*abs(Charge)
	variable Gama  = TotalEnergy_J / (Mass * LightSpeed^2)
	variable ChargeVel = ((1 - 1/Gama^2)*LightSpeed^2)^0.5
	variable Bt = ChargeVel/LightSpeed 

	variable i, j, n, idx, s, ci, hi, vi, li, ce, he, ve, le, nsp
	variable AvgPos, AvgNeg, AvgBx, AvgBy, AvgBz
	variable pos_init, prev_pos, pos
	variable Kv, Kh, K
	variable Lambda

	//Get semi-period positions
	if (SemiPeriodsPeaksZeros == 1)
		if (WaveExists(PositionPeaksPos) && WaveExists(PositionPeaksNeg))
			Concatenate/O/NP {PositionPeaksPos, PositionPeaksNeg}, PositionPeaks
			Wave PositionPeaks
			Sort PositionPeaks, PositionPeaks
		
			Duplicate/O PositionPeaks, PositionPeaksCut
		
			if (numpnts(PositionPeaksCut) > 4*IDCutPeriods+1)
				DeletePoints 0, 2*IDCutPeriods, PositionPeaksCut
				DeletePoints numpnts(PositionPeaksCut)-2*IDCutPeriods, 2*IDCutPeriods, PositionPeaksCut		
			endif
		
			Duplicate/O PositionPeaksCut, ID_SemiPeriod_Pos 
		
			for (i=1; i<numpnts(ID_SemiPeriod_Pos); i=i+1)
				ID_SemiPeriod_Pos[i] = PositionPeaksCut[0] + i*(IDPeriod/2/1000)
			endfor
			
			Killwaves/Z PositionPeaks, PositionPeaksCut
		else
			DoAlert 0,"Peak positions not found."
			return -1			
		endif

	else
		if (WaveExists(PositionZeros))
			Duplicate/O PositionZeros, PositionZerosCut
			
			if (numpnts(PositionZerosCut) > 4*IDCutPeriods+1)
				DeletePoints 0, 2*IDCutPeriods, PositionZerosCut
				DeletePoints numpnts(PositionZerosCut)-2*IDCutPeriods, 2*IDCutPeriods, PositionZerosCut		
			endif
			
			Duplicate/O PositionZerosCut, ID_SemiPeriod_Pos 
			
			for (i=1; i<numpnts(ID_SemiPeriod_Pos); i=i+1)
				ID_SemiPeriod_Pos[i] = PositionZerosCut[0] + i*(IDPeriod/2/1000)
			endfor
					
			Killwaves/Z PositionZerosCut
			
		else
			DoAlert 0,"Zero positions not found."
			return -1			
		endif
	
	endif
	
	nsp = numpnts(ID_SemiPeriod_Pos)

	Make/O/N=(nsp-1) Local_IDPhaseErrorPos
	for (i=0; i<numpnts(Local_IDPhaseErrorPos); i++)
		Local_IDPhaseErrorPos[i] = (ID_SemiPeriod_Pos[i+1] + ID_SemiPeriod_Pos[i])/2
	endfor

	// Calculate ID deflection parameter	
	Wave Bx = $("VetorCampoX" + num2str(StartXTraj/1000))
	AvgPos = GetAvgPositivePeaks(Bx, NAmplPeaks)
	AvgNeg = GetAvgNegativePeaks(Bx, NAmplPeaks)
	AvgBx = (Abs(AvgPos) + Abs(AvgNeg))/2
	Kv = 0.0934*AvgBx*IDPeriod
	
	if (BeamDirection == 1)
		Wave Bz = $("VetorCampoZ" + num2str(StartXTraj/1000))
		AvgPos = GetAvgPositivePeaks(Bz, NAmplPeaks)
		AvgNeg = GetAvgNegativePeaks(Bz, NAmplPeaks)
		AvgBz = (Abs(AvgPos) + Abs(AvgNeg))/2	
		Kh = 0.0934*AvgBz*IDPeriod
		
	else
		Wave By = $("VetorCampoY" + num2str(StartXTraj/1000))
		AvgPos = GetAvgPositivePeaks(By, NAmplPeaks)
		AvgNeg = GetAvgNegativePeaks(By, NAmplPeaks)
		AvgBy = (Abs(AvgPos) + Abs(AvgNeg))/2	
		Kh = 0.0934*AvgBy*IDPeriod
		
	endif
	
	K = sqrt(Kv^2 + Kh^2)

	// Calculate first radiation harmonic
	Lambda = (IDPeriod/(2*(Gama^2)))*(1 + (K^2)/2) //[mm]

	// Get trajectory length in each semi-period
	Make/O/D/N=(nsp-1) ID_TrajLength = 0
	Make/O/D/N=(nsp-1) ID_TrajDeviation = 0
	Make/O/D/N=(nsp-1) ID_TrajDeviationSqr = 0
	Make/O/D/N=(nsp-1) Local_IDPhaseError = 0

	j = 1	
	for (i=0; i < nsp - 1; i=i+1)			
		do 
			if (TrajL[j] > ID_SemiPeriod_Pos[i])
				break
			endif
			j = j + 1
		while (1)
		
		n = j
		do 
			if (TrajL[n] > ID_SemiPeriod_Pos[i+1])
				break
			endif
			n = n + 1
		while (1)
		
		ci = (ID_SemiPeriod_Pos[i] - TrajL[j-1])/(TrajL[j] - TrajL[j-1])
		hi = TrajH[j-1]*(1 - ci) + TrajH[j]*ci
		vi = TrajV[j-1]*(1 - ci) + TrajV[j]*ci
		li = ID_SemiPeriod_Pos[i]
		
		ce = (ID_SemiPeriod_Pos[i+1] - TrajL[n-2])/(TrajL[n-1] - TrajL[n-2])
		he = TrajH[n-2]*(1 - ce) + TrajH[n-1]*ce
		ve = TrajV[n-2]*(1 - ce) + TrajV[n-1]*ce
		le = ID_SemiPeriod_Pos[i+1]
		
		Duplicate/O/R=[j, n-1] TrajH, TrajHPer
		Duplicate/O/R=[j, n-1] TrajV, TrajVPer
		Duplicate/O/R=[j, n-1] TrajL, TrajLPer
			
		InsertPoints 0, 1, TrajHPer
		InsertPoints 0, 1, TrajVPer
		InsertPoints 0, 1, TrajLPer
		
		TrajHPer[0] = hi
		TrajVPer[0] = vi
		TrajLPer[0] = li
	
		InsertPoints numpnts(TrajHPer), 1, TrajHPer
		InsertPoints numpnts(TrajVPer), 1, TrajVPer
		InsertPoints numpnts(TrajLPer), 1, TrajLPer
			
		TrajHPer[numpnts(TrajHPer)] = he
		TrajVPer[numpnts(TrajVPer)] = ve
		TrajLPer[numpnts(TrajLPer)] = le
		
		TrajHPer = TrajHPer*1000 //[mm]
		TrajVPer = TrajVPer*1000 //[mm]
		TrajLPer = TrajLPer*1000 //[mm]
		
		s = 0
		for (idx=0; idx < numpnts(TrajLPer); idx=idx+1)	
			s = s + sqrt((TrajHPer[idx+1] - TrajHPer[idx])^2 + (TrajVPer[idx+1] - TrajVPer[idx])^2 + (TrajLPer[idx+1] - TrajLPer[idx])^2)
		endfor	
		ID_TrajLength[i] = s
		
		Killwaves/Z TrajHPer, TrajVPer, TrajLPer
	endfor
		
	ID_TrajDeviation = (ID_TrajLength - Mean(ID_TrajLength))/Lambda
		
	ID_TrajDeviationSqr = ID_TrajDeviation*ID_TrajDeviation
		
	//Calculate phase error
	Local_IDPhaseError = (2*Pi/Bt)*ID_TrajDeviation*180/Pi
	
	IDPhaseError = (2*Pi/Bt)*Sqrt(Sum(ID_TrajDeviationSqr)/numpnts(ID_TrajDeviationSqr))*180/Pi 	
	
	print "Insertion device phase error [°]: ", IDPhaseError
		
	Killwaves/Z PositionPeaks, ID_TrajLength, ID_TrajDeviation, ID_TrajDeviationSqr
	
End


Function ShowPhaseError(ctrlName) : ButtonControl
	String ctrlName
	
	//Procura Janela e se estiver aberta, fecha antes de abrir novamente.
	string PanelName
	PanelName = WinList("LocalPhaseError",";","")	
	if (stringmatch(PanelName, "LocalPhaseError;"))
		Killwindow LocalPhaseError
	endif

	NVAR PosXAux       = :varsFieldMap:PosXAux
	NVAR FieldAxisPeak = :varsFieldMap:FieldAxisPeak	

	string Name
	
	if (FieldAxisPeak == 1)
		Name = "RaiaBx_X"+num2str(PosXAux/1000)
	elseif (FieldAxisPeak == 2)
		Name = "RaiaBy_X"+num2str(PosXAux/1000)	
	elseif (FieldAxisPeak == 3)	
		Name = "RaiaBz_X"+num2str(PosXAux/1000)	
	endif
	
	Wave Interp_C_PosYZ
	Wave Interp_Field = $("Interp_" + Name)
	Display/N=LocalPhaseError/K=1/R Interp_Field vs Interp_C_PosYZ
	ModifyGraph rgb=(43000, 43000, 43000)

	if (FieldAxisPeak == 1)
		Label right "\\Z1Field Bx [T]"
	elseif (FieldAxisPeak == 2)
		Label right "\\Z12Field By [T]"
	elseif (FieldAxisPeak == 3)
		Label right "\\Z12Field Bz [T]"
	endif
	
	Wave Local_IDPhaseError
	Wave Local_IDPhaseErrorPos

	AppendToGraph Local_IDPhaseError vs Local_IDPhaseErrorPos
	ModifyGraph lsize(Local_IDPhaseError)=1.5
	Label bottom "\\Z12Longitudinal Position YZ [m]"
	Label left "\\Z12Local Phase Error [°]"	
		
End


Function TablePhaseError(ctrlName) : ButtonControl
	String ctrlName
		
	Wave Local_IDPhaseError
	Wave Local_IDPhaseErrorPos
	Edit/K=1 Local_IDPhaseErrorPos, Local_IDPhaseError
	
End


Function CalcPhaseErrorNominalValues(Period, NrPeriods, LongitudinalCenter)
	variable Period
	variable NrPeriods
	variable LongitudinalCenter

   	NVAR Charge     = root:varsCAMTO:Charge
	NVAR Mass       = root:varsCAMTO:Mass
	NVAR LightSpeed = root:varsCAMTO:LightSpeed
	NVAR TrajShift  = root:varsCAMTO:TrajShift

	NVAR StartXTraj = :varsFieldMap:StartXTraj
	NVAR BeamDirection = :varsFieldMap:BeamDirection
	
	NVAR FieldX = :varsFieldMap:FieldX
	NVAR FieldY = :varsFieldMap:FieldY
	NVAR FieldZ = :varsFieldMap:FieldZ
	
	Wave/Z TrajH = $"TrajX"+num2str(StartXTraj/1000)

	if (WaveExists(TrajH) == 0)
		DoAlert 0,"Trajectory not found."
		return -1	
	endif

	if (Period == 0)
		DoAlert 0, "Invalid period value."
		return -1	
	endif

	if (NrPeriods == 0)
		DoAlert 0, "Invalid number of periods."
		return -1	
	endif

	if (BeamDirection == 1)
		Wave/Z TrajL = $"TrajY"+num2str(StartXTraj/1000)
		Wave/Z TrajV = $"TrajZ"+num2str(StartXTraj/1000)
	else
		Wave/Z TrajV = $"TrajY"+num2str(StartXTraj/1000)
		Wave/Z TrajL = $"TrajZ"+num2str(StartXTraj/1000)	
	endif

	variable energy = GetParticleEnergy()
	
	variable TotalEnergy_J  = energy*1E9*abs(Charge)
	variable Gama  = TotalEnergy_J / (Mass * LightSpeed^2)
	variable ChargeVel = ((1 - 1/Gama^2)*LightSpeed^2)^0.5
	variable Bt = ChargeVel/LightSpeed 

	variable i, j, n, s, ci, hi, vi, ce, he, ve, cp
	variable pos_init, prev_pos, pos
	variable bx_peak, by_peak, bz_peak
	variable Kv, Kh, K
	variable Lambda

	bx_peak = 0
	by_peak = 0
	bz_peak = 0
	for (i=0; i<numpnts(TrajL); i=i+1)
		Campo_Espaco(0, TrajL[i])
		
		if (abs(FieldX) > bx_peak)
			bx_peak = abs(FieldX)
		endif

		if (abs(FieldY) > by_peak)
			by_peak = abs(FieldY)
		endif

		if (abs(FieldZ) > bz_peak)
			bz_peak = abs(FieldZ)
		endif
		
	endfor
	
	if (BeamDirection == 1)
		Kv = 0.0934*bx_peak*Period 
		Kh = 0.0934*bz_peak*Period
	else
		Kv = 0.0934*bx_peak*Period 
		Kh = 0.0934*by_peak*Period
	endif
	K = sqrt(Kv^2 + Kh^2)
	
	Lambda = (Period/(2*(Gama^2)))*(1 + (K^2)/2) //[mm]

	Make/O/D/N=(NrPeriods*2 + 1) ID_SemiPeriod_Pos = 0

	pos_init = (LongitudinalCenter - (NrPeriods/2)*Period)/1000	
	for (i=0; i<=NrPeriods*2; i=i+1)
		ID_SemiPeriod_Pos[i] = pos_init + i*(Period/2)/1000
	endfor

	cp = 2
	if (numpnts(ID_SemiPeriod_Pos) > 4*cp+1)
		DeletePoints 0, 2*cp, ID_SemiPeriod_Pos
		DeletePoints numpnts(ID_SemiPeriod_Pos)-2*cp, 2*cp, ID_SemiPeriod_Pos		
	endif

	Make/O/D/N=(numpnts(ID_SemiPeriod_Pos)-1) ID_TrajLength = 0

	j = 1	
	for (i=0; i< numpnts(ID_SemiPeriod_Pos) - 1; i=i+1)
		prev_pos = ID_SemiPeriod_Pos[i]
		pos = ID_SemiPeriod_Pos[i+1]
		s = 0
				
		do 
			if (TrajL[j] > prev_pos)
				break
			endif
			j = j + 1
		while (1)
		
		n = j
		do 
			if (TrajL[n] > pos)
				break
			endif
			n = n + 1
		while (1)
		
		ci = (prev_pos - TrajL[j-1])/(TrajL[j] - TrajL[j-1])
		hi = TrajH[j-1]*(1 - ci) + TrajH[j]*ci
		vi = TrajV[j-1]*(1 - ci) + TrajV[j]*ci
		s = s + sqrt((hi - TrajH[j])^2 + (vi - TrajV[j])^2 + (prev_pos - TrajL[j])^2)
		
		do
			if (j > n-2)
				break
			endif
			s = s + sqrt((TrajH[j+1] - TrajH[j])^2 + (TrajV[j+1] - TrajV[j])^2 + (TrajL[j+1] - TrajL[j])^2)
			j = j +1
		while (1)
		
		ce = (pos - TrajL[n-2])/(TrajL[n-1] - TrajL[n-2])
		he = TrajH[n-2]*(1 - ce) + TrajH[n-1]*ce
		ve = TrajV[n-2]*(1 - ce) + TrajV[n-1]*ce
		s = s + sqrt((he - TrajH[n-1])^2 + (ve - TrajV[n-1])^2 + (pos - TrajL[n-1])^2)
		
		ID_TrajLength[i] = 1000*s //[mm]
	endfor
	
	Display/K=1 ID_TrajLength

	Make/O/D/N=(numpnts(ID_TrajLength)) ID_TrajDeviation = 0
	ID_TrajDeviation = ID_TrajLength - Mean(ID_TrajLength)
	ID_TrajDeviation = (ID_TrajDeviation*ID_TrajDeviation)
	
	variable PhaseError = (2*Pi/Bt)*(1/Lambda)*Sqrt(Sum(ID_TrajDeviation)/numpnts(ID_TrajDeviation))*180/Pi 	

	Killwaves/Z ID_SemiPeriod_Pos, ID_TrajLength, ID_TrajDeviation 
	
	print "Insertion device phase error [°]: ", PhaseError
		
	return PhaseError
	
End


Function Campo_espaco(Px, Pyz)
	variable Px, Pyz
		
	NVAR FieldX = :varsFieldMap:FieldX
	NVAR FieldY = :varsFieldMap:FieldY
	NVAR FieldZ = :varsFieldMap:FieldZ
	
	NVAR StartX   = :varsFieldMap:StartX
	NVAR EndX     = :varsFieldMap:EndX
	NVAR StepsX   = :varsFieldMap:StepsX
	NVAR NPointsX = :varsFieldMap:NPointsX
	
	NVAR StartYZ   = :varsFieldMap:StartYZ
	NVAR EndYZ     = :varsFieldMap:EndYZ
	NVAR StepsYZ   = :varsFieldMap:StepsYZ
	NVAR NPointsYZ = :varsFieldMap:NPointsYZ		
	
	NVAR iX  = :varsFieldMap:iX
	NVAR iYZ = :varsFieldMap:iYZ	
	
	Wave C_PosX
	Wave C_PosYZ	

	variable i, j
	variable ii

	//Procura Raia em X
	if(px >= C_PosX[iX])
		ii = 1
	else
		ii = -1	
	endif
	
	if (NPointsX == 1)
		iX = 0
	else
		for(i=iX;i<NPointsX-1;i=i+ii)
			if (i < 0)
				ii = 1
				i = i + 1
			endif
	
			if ( (px >= C_PosX[i]) && (Px <= C_PosX[i+1]) && (C_PosX[i+1] > C_PosX[i])  )
				iX = i
				break
			endif
		endfor
	endif

	//Procura Raia em YZ
	if(pyz >= C_PosYZ[iYZ])
		ii = 1
	else
		ii = -1	
	endif
	
	for(i=iYZ;i<NPointsYZ-1;i=i+ii)
		if (i < 0)
		   ii = 1
		   i = i + 1
		endif
	
		if ( (pyz >= C_PosYZ[i]) && (pyz <= C_PosYZ[i+1]) && (C_PosYZ[i+1] > C_PosYZ[i]) )
			iYZ = i
			break
		endif
	endfor

	string NomeX1
	string NomeX2	
	variable AuxX1
	variable AuxX2	

	if (NPointsX == 1)
		// Find Field X
		NomeX1 = "RaiaBx_X" + num2str(C_PosX[iX]) 
		Wave TmpX1 = $NomeX1
		AuxX1 = ( (TmpX1[iYZ+1] - TmpX1[iYZ]) / (C_PosYZ[iYZ+1] - C_PosYZ[iYZ]) * (pyz - C_PosYZ[iYZ]) ) + TmpX1[iYZ]
		FieldX = AuxX1

		// Find Field Y
		NomeX1 = "RaiaBy_X" + num2str(C_PosX[iX]) 
		Wave TmpX1 = $NomeX1
		AuxX1 = ( (TmpX1[iYZ+1] - TmpX1[iYZ]) / (C_PosYZ[iYZ+1] - C_PosYZ[iYZ]) * (pyz - C_PosYZ[iYZ]) ) + TmpX1[iYZ]
		FieldY = AuxX1

		// Find Field Z
		NomeX1 = "RaiaBz_X" + num2str(C_PosX[iX]) 
		Wave TmpX1 = $NomeX1
		AuxX1 = ( (TmpX1[iYZ+1] - TmpX1[iYZ]) / (C_PosYZ[iYZ+1] - C_PosYZ[iYZ]) * (pyz - C_PosYZ[iYZ]) ) + TmpX1[iYZ]
		FieldZ = AuxX1
	else
		// Find Field X
		NomeX1 = "RaiaBx_X" + num2str(C_PosX[iX]) 
		Wave TmpX1 = $NomeX1
		NomeX2 = "RaiaBx_X" + num2str(C_PosX[iX+1]) 
		Wave TmpX2 = $NomeX2
		AuxX1 = ( (TmpX1[iYZ+1] - TmpX1[iYZ]) / (C_PosYZ[iYZ+1] - C_PosYZ[iYZ]) * (pyz - C_PosYZ[iYZ]) ) + TmpX1[iYZ]
		AuxX2 = ( (TmpX2[iYZ+1] - TmpX2[iYZ]) / (C_PosYZ[iYZ+1] - C_PosYZ[iYZ]) * (pyz - C_PosYZ[iYZ]) ) + TmpX2[iYZ]	
		FieldX = ( (AuxX2 - AuxX1) / (C_PosX[iX+1]-C_PosX[iX]) * (px-C_PosX[iX]) ) + AuxX1

		// Find Field Y
		NomeX1 = "RaiaBy_X" + num2str(C_PosX[iX]) 
		Wave TmpX1 = $NomeX1
		NomeX2 = "RaiaBy_X" + num2str(C_PosX[iX+1]) 
		Wave TmpX2 = $NomeX2
		AuxX1 = ( (TmpX1[iYZ+1] - TmpX1[iYZ]) / (C_PosYZ[iYZ+1] - C_PosYZ[iYZ]) * (pyz - C_PosYZ[iYZ]) ) + TmpX1[iYZ]
		AuxX2 = ( (TmpX2[iYZ+1] - TmpX2[iYZ]) / (C_PosYZ[iYZ+1] - C_PosYZ[iYZ]) * (pyz - C_PosYZ[iYZ]) ) + TmpX2[iYZ]	
		FieldY = ( (AuxX2 - AuxX1) / (C_PosX[iX+1]-C_PosX[iX]) * (px-C_PosX[iX]) ) + AuxX1

		// Find Field Z
		NomeX1 = "RaiaBz_X" + num2str(C_PosX[iX]) 
		Wave TmpX1 = $NomeX1
		NomeX2 = "RaiaBz_X" + num2str(C_PosX[iX+1]) 
		Wave TmpX2 = $NomeX2
		AuxX1 = ( (TmpX1[iYZ+1] - TmpX1[iYZ]) / (C_PosYZ[iYZ+1] - C_PosYZ[iYZ]) * (pyz - C_PosYZ[iYZ]) ) + TmpX1[iYZ]
		AuxX2 = ( (TmpX2[iYZ+1] - TmpX2[iYZ]) / (C_PosYZ[iYZ+1] - C_PosYZ[iYZ]) * (pyz - C_PosYZ[iYZ]) ) + TmpX2[iYZ]	
		FieldZ = ( (AuxX2 - AuxX1) / (C_PosX[iX+1]-C_PosX[iX]) * (px-C_PosX[iX]) ) + AuxX1
	endif
		
End


Window Results() : Panel
	PauseUpdate; Silent 1		// building window...

	if (DataFolderExists("root:varsCAMTO")==0)
		DoAlert 0, "CAMTO variables not found."
		return 
	endif

	//Procura Janela e se estiver aberta, fecha antes de abrir novamente.
	string PanelName
	PanelName = WinList("Results",";","")	
	if (stringmatch(PanelName, "Results;"))
		Killwindow Results
	endif

	NewPanel/K=1/W=(1235,60,1573,785)
	SetDrawEnv fillpat= 0
	DrawRect 3,5,333,125
	SetDrawEnv fillpat= 0
	DrawRect 3,125,333,158
	SetDrawEnv fillpat= 0
	DrawRect 3,158,333,275
	SetDrawEnv fillpat= 0
	DrawRect 3,275,333,310
	SetDrawEnv fillpat= 0
	DrawRect 3,310,333,345
	SetDrawEnv fillpat= 0
	DrawRect 3,345,333,445
	SetDrawEnv fillpat= 0		
	DrawRect 3,445,333,595
	SetDrawEnv fillpat= 0		
	DrawRect 3,595,333,690
	SetDrawEnv fillpat= 0		
	DrawRect 3,690,333,720
	
	TitleBox field_title,pos={120,10},size={127,16},fSize=16,fStyle=1,frame=0, title="Field Profile"
	
	SetVariable PosXField,pos={10,40},size={140,18},title="Pos X [mm]:"
	SetVariable PosYZField,pos={10,70},size={140,18},title="Pos YZ [mm]:"
			
	ValDisplay FieldinPointX,pos={160,32},size={165,17},title="Field X [T]:"
	ValDisplay FieldinPointX,limits={0,0,0},barmisc={0,1000}
	ValDisplay FieldinPointY,pos={160,55},size={165,17},title="Field Y  [T]:"
	ValDisplay FieldinPointY,limits={0,0,0},barmisc={0,1000}
	ValDisplay FieldinPointZ,pos={160,78},size={165,17},title="Field Z  [T]:"
	ValDisplay FieldinPointZ,limits={0,0,0},barmisc={0,1000}
			
	Button field_point,pos={16,97},size={306,24},proc=Field_in_Point,title="Calculate the field in a point"
	Button field_point,fStyle=1
	
	Button field_Xline,pos={16,130},size={110,24},proc=Field_in_X_Line,title="Show field in X ="
	Button field_Xline,fStyle=1
	SetVariable PosXFieldLine,pos={130,134},size={80,18},title="[mm]:"
	CheckBox graphappend, pos={220,136}, title="Append to Graph"
	
	SetVariable StartXProfile,pos={16,170},size={134,18},title="Start X [mm]:"
	SetVariable EndXProfile,pos={16,195},size={134,18},title="End X [mm]:"
	SetVariable PosYZProfile,pos={16,221},size={134,18},title="Pos YZ [mm]:"
		
	ValDisplay FieldHomX,pos={160,171},size={165,17},title="Homog. X [T]:"
	ValDisplay FieldHomX,limits={0,0,0},barmisc={0,1000}
	ValDisplay FieldinPointY1,pos={160,194},size={165,17},title="Homog. Y [T]:"
	ValDisplay FieldinPointY1,limits={0,0,0},barmisc={0,1000}
	ValDisplay FieldinPointZ1,pos={160,217},size={165,17},title="Homog. Z [T]:"
	ValDisplay FieldinPointZ1,limits={0,0,0},barmisc={0,1000}
		
	Button field_profile,pos={11,246},size={230,24},proc=Field_Profile,title="Show Field Profile and Homogeneity"
	Button field_profile,fStyle=1
	Button field_profile_table,pos={247,246},size={80,24},proc=Field_Profile_Table,title="Show Table"
	Button field_profile_table,fStyle=1
	
	Button show_integrals,pos={11,281},size={230,24},proc=ShowIntegrals,title="Show First Integrals over lines"
	Button show_integrals,fStyle=1
	Button show_integrals_table,pos={247,281},size={80,24},proc=show_integrals_Table,title="Show Table"
	Button show_integrals_table,fStyle=1	
	
	Button show_integrals2,pos={11,316},size={230,24},proc=ShowIntegrals2,title="Show Second Integrals over lines"
	Button show_integrals2,fStyle=1
	Button show_integrals2_table,pos={247,316},size={80,24},proc=show_integrals2_Table,title="Show Table"
	Button show_integrals2_table,fStyle=1
	
	Button show_multipoles,pos={11,351},size={316,24},proc=ShowMultipoles,title="Show Multipoles Table"
	Button show_multipoles,fStyle=1
	
	Button show_multipoleprofile,pos={11,384},size={230,24},proc=ShowMultipoleProfile,title="Show Multipole Profile: K = "
	Button show_multipoleprofile,fStyle=1
	SetVariable mnumber,pos={247,387},size={80,18},title=" "
	
	Button show_residmultipoles,pos={11,416},size={230,24},proc=ShowResidMultipoles,title="Show Residual Multipoles"
	Button show_residmultipoles,fStyle=1
	Button show_residmultipoles_table,pos={247,416},size={80,24},proc=ShowResidMultipoles_Table,title="Show Table"
	Button show_residmultipoles_table,fStyle=1
	
	TitleBox traj_title1,pos={100,451},size={127,16},fSize=16,fStyle=1,frame=0, title="Particle Trajectory"
	
	Button show_trajectories,pos={11,476},size={180,24},proc=ShowTrajectories,title="Show Trajectories"
	Button show_trajectories,fStyle=1
	CheckBox referencelines,pos={200,482},size={130,24},title=" Add Reference Lines"
	
	Button show_deflections,pos={11,506},size={230,24},proc=ShowDeflections,title="Show Deflections"
	Button show_deflections,fStyle=1
	Button show_deflections_Table,pos={247,506},size={80,24},proc=show_deflections_Table,title="Show Table"
	Button show_deflections_Table,fStyle=1	
	
	Button show_integralstraj,pos={11,536},size={230,24},proc=ShowIntegralsTraj,title="Show First Integrals over trajectory"
	Button show_integralstraj,fStyle=1
	Button show_integralstraj_Table,pos={247,536},size={80,24},proc=show_integralstraj_Table,title="Show Table"
	Button show_integralstraj_Table,fStyle=1	
	
	Button show_integrals2traj,pos={11,566},size={230,24},proc=ShowIntegrals2Traj,title="Show Second Integrals over trajectory"
	Button show_integrals2traj,fStyle=1
	Button show_integrals2traj_Table,pos={247,566},size={80,24},proc=show_integrals2traj_Table,title="Show Table"
	Button show_integrals2traj_Table,fStyle=1	
	
	Button show_dynmultipoles,pos={11,600},size={316,24},proc=ShowDynMultipoles,title="Show Dynamic Multipoles Table"
	Button show_dynmultipoles,fStyle=1
	
	Button show_dynmultipoleprofile,pos={11,630},size={230,24},proc=ShowDynMultipoleProfile,title="Show Dynamic Multipole Profile: K = "
	Button show_dynmultipoleprofile,fStyle=1
	SetVariable mtrajnumber,pos={247,633},size={80,18},title=" "
		
	Button show_residdynmultipoles,pos={11,660},size={230,24},proc=ShowResidDynMultipoles,title="Show Residual Dynamic Multipoles"
	Button show_residdynmultipoles,fStyle=1
	Button show_residdynmultipoles_table,pos={247,660},size={80,24},proc=ShowResidDynMultipoles_Table,title="Show Table"
	Button show_residdynmultipoles_table,fStyle=1

	SetVariable fieldmapdir,pos={20,697},size={300,18},fStyle=1,title="FieldMap directory: "
	SetVariable fieldmapdir,noedit=1,value=root:varsCAMTO:FieldMapDir
	
	UpdateFieldMapDirs()
	UpdateResultsPanel()
		 
EndMacro


Function UpdateResultsPanel()

	string PanelName
	PanelName = WinList("Results",";","")	
	if (stringmatch(PanelName, "Results;")==0)
		return -1
	endif
	
	SVAR df = root:varsCAMTO:FieldMapDir
	
	NVAR StartX  = root:$(df):varsFieldMap:StartX
	NVAR EndX    = root:$(df):varsFieldMap:EndX
	NVAR StepsX  = root:$(df):varsFieldMap:StepsX
	NVAR StartYZ = root:$(df):varsFieldMap:StartYZ
	NVAR EndYZ   = root:$(df):varsFieldMap:EndYZ
	NVAR StepsYZ = root:$(df):varsFieldMap:StepsYZ
	NVAR FittingOrder = root:$(df):varsFieldMap:FittingOrder
	NVAR FittingOrderTraj = root:$(df):varsFieldMap:FittingOrderTraj
	
	NVAR PosXAux  = root:$(df):varsFieldMap:PosXAux 
	NVAR PosYZAux = root:$(df):varsFieldMap:PosYZAux 
	NVAR StartXHom = root:$(df):varsFieldMap:StartXHom 
	NVAR EndXHom   = root:$(df):varsFieldMap:EndXHom    
	NVAR PosYZHom  = root:$(df):varsFieldMap:PosYZHom  
	
	Wave/Z C_PosX 				 = $("root:"+ df + ":C_PosX")
	Wave/Z IntBx_X 				 = $("root:"+ df + ":IntBx_X")
	Wave/Z Mult_Normal_Int		 = $("root:"+ df + ":Mult_Normal_Int")
	Wave/Z Temp_Traj				 = $("root:"+ df + ":PosXTraj")
	Wave/Z Dyn_Mult_Normal_Int = $("root:"+ df + ":Dyn_Mult_Normal_Int")
	
	if (strlen(df) > 0)		
		SetVariable PosXField, win=Results, value= root:$(df):varsFieldMap:PosXAux
		SetVariable PosXField, win=Results, limits={StartX,EndX,StepsX}
		SetVariable PosYZField,win=Results, value= root:$(df):varsFieldMap:PosYZAux
		SetVariable PosYZField,win=Results, limits={StartYZ,EndYZ,StepsYZ}
	
		ValDisplay FieldinPointX,win=Results,value= #("root:"+ df + ":varsFieldMap:FieldXAux")
		ValDisplay FieldinPointY,win=Results,value= #("root:"+ df + ":varsFieldMap:FieldYAux")
		ValDisplay FieldinPointZ,win=Results,value= #("root:"+ df + ":varsFieldMap:FieldZAux")
	
		SetVariable PosXFieldLine,win=Results, value= root:$(df):varsFieldMap:PosXAux
		SetVariable PosXFieldLine,win=Results, limits={StartX,EndX,StepsX}
	
		CheckBox graphappend,win=Results, disable=0, variable=root:$(df):varsFieldMap:GraphAppend	
	
		SetVariable StartXProfile,win=Results, value= root:$(df):varsFieldMap:StartXHom
		SetVariable StartXProfile,win=Results, limits={StartX,EndX,StepsX}
		SetVariable EndXProfile,  win=Results, value= root:$(df):varsFieldMap:EndXHom
		SetVariable EndXProfile,  win=Results, limits={StartX,EndX,StepsX}
		SetVariable PosYZProfile, win=Results, value= root:$(df):varsFieldMap:PosYZHom
		SetVariable PosYZProfile, win=Results, limits={StartYZ,EndYZ,StepsYZ}
		
		ValDisplay FieldHomX,win=Results,value= #("root:"+ df + ":varsFieldMap:HomogX") 
		ValDisplay FieldinPointY1,win=Results,value= #("root:"+ df + ":varsFieldMap:HomogY")
		ValDisplay FieldinPointZ1,win=Results,value= #("root:"+ df + ":varsFieldMap:HomogZ")
		
		variable disable_field = 2 
		if (WaveExists(C_PosX))
			disable_field = 0
		endif
		
		variable disable_int = 2 
		if (WaveExists(IntBx_X))
			disable_int = 0
		endif

		variable disable_mult = 2 
		if (WaveExists(Mult_Normal_Int))
			disable_mult = 0
		endif

		variable disable_traj = 2 
		if (WaveExists(Temp_Traj))
			disable_traj = 0
		endif

		variable disable_dynmult = 2 
		if (WaveExists(Dyn_Mult_Normal_Int))
			disable_dynmult = 0
		endif
					
		Button field_point,win=Results,disable=disable_field
		Button field_Xline,win=Results,disable=disable_field
		Button field_profile, win=Results,disable=disable_field
		Button field_profile_table,win=Results, disable=disable_field

		Button show_integrals,win=Results, disable=disable_int
		Button show_integrals_table,win=Results, disable=disable_int
		Button show_integrals2, win=Results,disable=disable_int
		Button show_integrals2_table,win=Results, disable=disable_int
		
		Button show_multipoles,win=Results, disable=disable_mult
		Button show_multipoleprofile,win=Results, disable=disable_mult
		Button show_residmultipoles,win=Results, disable=disable_mult
		Button show_residmultipoles_table,win=Results, disable=disable_mult
		
		SetVariable mnumber,win=Results,limits={0,(FittingOrder-1),1},value= root:$(df):varsFieldMap:MultipoleK
	
		Button show_trajectories,win=Results, disable=disable_traj
		Button show_deflections,win=Results, disable=disable_traj
		Button show_deflections_Table, win=Results,disable=disable_traj
		Button show_integralstraj,win=Results, disable=disable_traj
		Button show_integralstraj_Table, win=Results,disable=disable_traj
		Button show_integrals2traj,win=Results, disable=disable_traj
		Button show_integrals2traj_Table, win=Results,disable=disable_traj
		
		NVAR/Z AddReferenceLines = root:$(df):varsFieldMap:AddReferenceLines
		if (NVAR_EXists(AddReferenceLines)==0)
			variable/G root:$(df):varsFieldMap:AddReferenceLines = 0
		endif
		
		CheckBox referencelines,win=Results, disable=disable_traj,variable=root:$(df):varsFieldMap:AddReferenceLines
		
		Button show_dynmultipoles, win=Results,disable=disable_dynmult
		Button show_dynmultipoleprofile,win=Results, disable=disable_dynmult
		Button show_residdynmultipoles, win=Results,disable=disable_dynmult
		Button show_residdynmultipoles_table, win=Results,disable=disable_dynmult
		
		SetVariable mtrajnumber,win=Results,limits={0,(FittingOrderTraj-1),1},value= root:$(df):varsFieldMap:DynMultipoleK
		
		PosXAux  = StartX
		PosYZAux = StartYZ
		StartXHom = StartX
		EndXHom   = EndX	 
		PosYZHom  = StartYZ	 
		
	else
		
		Button field_point,win=Results,disable=2
		Button field_Xline,win=Results,disable=2
		CheckBox graphappend,win=Results,disable=2
		Button field_profile,win=Results,disable=2
		Button field_profile_table,win=Results,disable=2
		Button show_integrals,win=Results,disable=2
		Button show_integrals_table,win=Results,disable=2
		Button show_integrals2,win=Results,disable=2
		Button show_integrals2_table,win=Results,disable=2
		Button show_multipoles,win=Results,disable=2
		Button show_multipoleprofile,win=Results,disable=2
		Button show_residmultipoles,win=Results,disable=2
		Button show_residmultipoles_table,win=Results,disable=2
		Button show_integralstraj,win=Results,disable=2
		Button show_integralstraj_Table,win=Results,disable=2
		Button show_integrals2traj,win=Results,disable=2
		Button show_integrals2traj_Table,win=Results,disable=2
		Button show_trajectories,win=Results,disable=2
		CheckBox referencelines,win=Results, disable=2
		Button show_deflections,win=Results,disable=2
		Button show_deflections_Table,win=Results,disable=2	
		Button show_dynmultipoles,win=Results,disable=2
		Button show_dynmultipoleprofile,win=Results,disable=2
		Button show_residdynmultipoles,win=Results,disable=2
		Button show_residdynmultipoles_table,win=Results,disable=2
		
	endif
	
End


Function Field_in_Point(ctrlName) : ButtonControl
	String ctrlName
		
	NVAR PosXAux  = :varsFieldMap:PosXAux
	NVAR PosYZAux = :varsFieldMap:PosYZAux	
	
	NVAR FieldX = :varsFieldMap:FieldX
	NVAR FieldY = :varsFieldMap:FieldY
	NVAR FieldZ = :varsFieldMap:FieldZ

	NVAR FieldXAux = :varsFieldMap:FieldXAux
	NVAR FieldYAux = :varsFieldMap:FieldYAux
	NVAR FieldZAux = :varsFieldMap:FieldZAux
	
	Campo_Espaco(PosXAux/1000,PosYZAux/1000)

	FieldXAux = FieldX
	FieldYAux = FieldY
	FieldZAux = FieldZ
	
	Print("Field Bx = " + num2str(FieldX))
	Print("Field By = " + num2str(FieldY))
	Print("Field Bz = " + num2str(FieldZ))	
End


Function Field_in_X_Line(ctrlName) : ButtonControl
	String ctrlName

	NVAR PosXAux     = :varsFieldMap:PosXAux
	NVAR NPointsX    = :varsFieldMap:NPointsX
	NVAR GraphAppend = :varsFieldMap:GraphAppend
	
	Wave C_PosX
	Wave C_PosYZ	
	
	variable i
	variable iX = 0
	
	string NameLines
	string PanelName
	
	for (i=0;i<NPointsX;i=i+1)
		if (C_PosX[i] >= (PosXAux/1000))
			iX = i
			break
		endif
	endfor
		
	if (GraphAppend == 1)	
		PanelName = WinList("FieldInLineX",";","")	
		if (stringmatch(PanelName, "FieldInLineX;"))
			//Graph Bx
			NameLines = "RaiaBx_X"+num2str(C_PosX[iX])
			Wave Tmp = $NameLines	
			Appendtograph/W=FieldInLineX Tmp vs C_PosYZ
		else
			//Graph Bx
			NameLines = "RaiaBx_X"+num2str(C_PosX[iX])
			Wave Tmp = $NameLines	
			Display/N=FieldInLineX/K=1 Tmp vs C_PosYZ
			Label bottom "\\Z12Longitudinal Position YZ [m]"
			Label left "\\Z12Field Bx [T]"
		endif	
		
		PanelName = WinList("FieldInLineY",";","")	
		if (stringmatch(PanelName, "FieldInLineY;"))
			//Graph By
			NameLines = "RaiaBy_X"+num2str(C_PosX[iX])
			Wave Tmp = $NameLines	
			Appendtograph/W=FieldInLineY Tmp vs C_PosYZ
		else
			//Graph By
			NameLines = "RaiaBy_X"+num2str(C_PosX[iX])
			Wave Tmp = $NameLines	
			Display/N=FieldInLineY/K=1 Tmp vs C_PosYZ
			Label bottom "\\Z12Longitudinal Position YZ [m]"
			Label left "\\Z12Field By [T]"
		endif	
		
		PanelName = WinList("FieldInLineZ",";","")	
		if (stringmatch(PanelName, "FieldInLineZ;"))
			//Graph Bz
			NameLines = "RaiaBz_X"+num2str(C_PosX[iX])
			Wave Tmp = $NameLines	
			Appendtograph/W=FieldInLineZ Tmp vs C_PosYZ
		else
			//Graph Bx
			NameLines = "RaiaBz_X"+num2str(C_PosX[iX])
			Wave Tmp = $NameLines	
			Display/N=FieldInLineZ/K=1 Tmp vs C_PosYZ
			Label bottom "\\Z12Longitudinal Position YZ [m]"
			Label left "\\Z12Field Bz [T]"
		endif	
	else
		PanelName = WinList("FieldInLineX",";","")	
		if (stringmatch(PanelName, "FieldInLineX;"))
			//Graph Bx
		else
			//Graph Bx
			NameLines = "RaiaBx_X"+num2str(C_PosX[iX])
			Wave Tmp = $NameLines	
			Display/N=FieldInLineX/K=1 Tmp vs C_PosYZ
			Label bottom "\\Z12Longitudinal Position YZ [m]"
			Label left "\\Z12Field Bx [T]"
		endif	
		
		PanelName = WinList("FieldInLineY",";","")	
		if (stringmatch(PanelName, "FieldInLineY;"))
			//Graph By
		else
			//Graph By
			NameLines = "RaiaBy_X"+num2str(C_PosX[iX])
			Wave Tmp = $NameLines	
			Display/N=FieldInLineY/K=1 Tmp vs C_PosYZ
			Label bottom "\\Z12Longitudinal Position YZ [m]"
			Label left "\\Z12Field By [T]"
		endif	
		
		PanelName = WinList("FieldInLineZ",";","")	
		if (stringmatch(PanelName, "FieldInLineZ;"))
			//Graph Bz
		else
			//Graph Bx
			NameLines = "RaiaBz_X"+num2str(C_PosX[iX])
			Wave Tmp = $NameLines	
			Display/N=FieldInLineZ/K=1 Tmp vs C_PosYZ
			Label bottom "\\Z12Longitudinal Position YZ [m]"
			Label left "\\Z12Field Bz [T]"
		endif		
	endif
	
End


Function Field_Profile(ctrlName) : ButtonControl
	String ctrlName

	NVAR StepsX = :varsFieldMap:StepsX	

	NVAR StartXHom = :varsFieldMap:StartXHom
	NVAR EndXHom   = :varsFieldMap:EndXHom	
	NVAR PosYZHom  = :varsFieldMap:PosYZHom	
	
	NVAR FieldX = :varsFieldMap:FieldX
	NVAR FieldY = :varsFieldMap:FieldY
	NVAR FieldZ = :varsFieldMap:FieldZ

	NVAR HomogX = :varsFieldMap:HomogX
	NVAR HomogY = :varsFieldMap:HomogY
	NVAR HomogZ = :varsFieldMap:HomogZ
	
	variable i
	variable NpointsXHom
		
	NpointsXHom = ((EndXHom - StartXHom) / StepsX) +1
	Make/D/O/N=(NpointsXHom) ProfilePosX
	Make/D/O/N=(NpointsXHom) ProfileFieldX
	Make/D/O/N=(NpointsXHom) ProfileFieldY
	Make/D/O/N=(NpointsXHom) ProfileFieldZ		
	
	for (i=0;i<NpointsXHom;i=i+1)
		ProfilePosX[i] = ((StartXHom+i*StepsX)/1000)
		
		Campo_Espaco(ProfilePosX[i],(PosYZHom/1000))
		
		ProfileFieldX[i] = FieldX
		ProfileFieldY[i] = FieldY
		ProfileFieldZ[i] = FieldZ				
	endfor
	
	//Graph Bx
	Display/N=FieldProfileX/K=1 ProfileFieldX vs ProfilePosX
	TextBox/C/N=text0/A=MC "PosYZ [m] = "+	num2str(PosYZHom/1000)
	Label bottom "\\Z12Transversal Position X [m]"
	Label left "\\Z12Field Bx [T]"

	//Graph By
	Display/N=FieldProfileY/K=1 ProfileFieldY vs ProfilePosX
	TextBox/C/N=text0/A=MC "PosYZ [m] = "+	num2str(PosYZHom/1000)
	Label bottom "\\Z12Transversal Position X [m]"
	Label left "\\Z12Field By [T]"

	//Graph Bz
	Display/N=FieldProfileZ/K=1 ProfileFieldZ vs ProfilePosX
	TextBox/C/N=text0/A=MC "PosYZ [m] = "+	num2str(PosYZHom/1000)
	Label bottom "\\Z12Transversal Position X [m]"
	Label left "\\Z12Field Bz [T]"
	
	wavestats/Q ProfileFieldX
	if (V_Max != 0)
		HomogX = (V_max - V_min) / V_max
	else
		HomogX = 0
	endif
	EraseStatsVariables()	
	
	wavestats/Q ProfileFieldY
	if (V_Max != 0)
		HomogY = (V_max - V_min) / V_max
	else
		HomogY = 0
	endif	
	EraseStatsVariables()	

	wavestats/Q ProfileFieldZ
	if (V_Max != 0)
		HomogZ = (V_max - V_min) / V_max
	else
		HomogZ = 0
	endif
	EraseStatsVariables()	
	
	Print("")
	Print("************************************")	
	Print(" Field Homogeneity - " + "X-Axis: " + num2str(StartXHom) + " to " + num2str(EndXHom) + " YZ-Axis: " + num2str(PosYZHom) )	
	Print("")	
	Print("Homogeneity Bx = " + num2str(HomogX))
	Print("Homogeneity By = " + num2str(HomogY))
	Print("Homogeneity Bz = " + num2str(HomogZ))			
	Print("************************************")		
	Print("")		
		
End


Function Field_Profile_table(ctrlName) : ButtonControl
	String ctrlName

	Edit/K=1 ProfilePosX,ProfileFieldX,ProfileFieldY,ProfileFieldZ

End


Function ShowIntegrals(ctrlName) : ButtonControl
	String ctrlName
	
	Wave C_PosX
	Wave IntBx_X	
	Wave IntBy_X
	Wave IntBz_X		

	//Graph Bx
	Display/N=IntBx_X/K=1 IntBx_X vs C_PosX
	Label bottom "\\Z12Transversal Position X [m]"
	Label left "\\Z12First Integral Bx [T.m]"

	//Graph By
	Display/N=IntBy_X/K=1 IntBy_X vs C_PosX
	Label bottom "\\Z12Transversal Position X [m]"
	Label left "\\Z12First Integral By [T.m]"

	//Graph Bz
	Display/N=IntBz_X/K=1 IntBz_X vs C_PosX
	Label bottom "\\Z12Transversal Position X [m]"
	Label left "\\Z12First Integral Bz [T.m]"
End


Function show_integrals_Table(ctrlName) : ButtonControl
	String ctrlName
	
	Edit/K=1 C_PosX,IntBx_X,IntBy_X,IntBz_X
	
End


Function ShowIntegrals2(ctrlName) : ButtonControl
	String ctrlName
	
	Wave C_PosX
	Wave Int2Bx_X	
	Wave Int2By_X
	Wave Int2Bz_X		

	//Graph Bx
	Display/N=Int2Bx_X/K=1 Int2Bx_X vs C_PosX
	Label bottom "\\Z12Transversal Position X [m]"
	Label left "\\Z12Second Integral Bx [T.m2]"

	//Graph By
	Display/N=Int2By_X/K=1 Int2By_X vs C_PosX
	Label bottom "\\Z12Transversal Position X [m]"
	Label left "\\Z12Second Integral By [T.m2]"

	//Graph Bz
	Display/N=Int2Bz_X/K=1 Int2Bz_X vs C_PosX
	Label bottom "\\Z12Transversal Position X [m]"
	Label left "\\Z12Second Integral Bz [T.m2]"
End


Function show_integrals2_Table(ctrlName) : ButtonControl
	String ctrlName
	Edit/K=1 C_PosX,Int2Bx_X,Int2By_X,Int2Bz_X
	
End


Function ShowMultipoles(ctrlName) : ButtonControl
	String ctrlName
	Edit/K=1 Mult_Normal_Int, Mult_Skew_Int, Mult_Normal_Norm, Mult_Skew_Norm
End


Function ShowMultipoleProfile(ctrlName) : ButtonControl
	String ctrlName
	
	NVAR K = :varsFieldMap:MultipoleK
	
	wave C_PosYZ
	wave Mult_Normal
	wave Mult_Skew
	
	string name_normal = "Mult_Normal_k" + num2str(K)
	string name_skew = "Mult_Skew_k" + num2str(K)
	
	string graphlabel
	if (K == 0)
		graphlabel = "Dipolar field [T]"
	elseif (K == 1)
		graphlabel = "Quadrupolar field [T/m]"
	elseif (K == 2)
		graphlabel = "Sextupolar field [T/m²]"
	elseif (K == 3)
		graphlabel = "Octupolar field [T/m³]"
	else
		graphlabel = num2str(2*(K +1))+ "-polar field"
	endif
	
	Make/D/O/N=(numpnts(C_PosYZ)) $name_normal
	Wave Tmp_Normal = $name_normal
	Tmp_Normal[] = Mult_Normal[p][K]
	Display/N=Mult_Normal/K=1 Tmp_Normal vs C_PosYZ
	Label bottom "\\Z12Longitudinal Position YZ [m]"
	Label left  "\\Z12Normal " + graphlabel

	Make/D/O/N=(numpnts(C_PosYZ)) $name_skew
	Wave Tmp_Skew = $name_skew
	Tmp_Skew[] = Mult_Skew[p][K]
	Display/N=Mult_Skew/K=1 Tmp_Skew vs C_PosYZ
	Label bottom "\\Z12Longitudinal Position YZ [m]"
	Label left  "\\Z12Skew " + graphlabel
		
End


Function ShowResidMultipoles(ctrlName) : ButtonControl
	String ctrlName

	Wave Mult_Grid
	Wave Mult_Normal_Res
	Wave Mult_Skew_Res

	Display/N=Mult_Normal_Res/K=1 Mult_Normal_Res vs Mult_Grid
	Label bottom "\\Z12Transversal Position X [m]"
	Label left "\\Z12Normalized Residual \rNormal Multipoles"

	Display/N=Mult_Skew_Res/K=1 Mult_Skew_Res vs Mult_Grid
	Label bottom "\\Z12Transversal Position X [m]"
	Label left "\\Z12Normalized Residual \rSkew Multipoles"

End


Function ShowResidMultipoles_Table(ctrlName) : ButtonControl
	String ctrlName
	Edit/K=1 Mult_Grid,Mult_Normal_Res,Mult_Skew_Res
End


Function ShowIntegralsTraj(ctrlName) : ButtonControl
	String ctrlName
	
	Wave PosXTraj
	Wave IntBx_X_Traj	
	Wave IntBy_X_Traj	
	Wave IntBz_X_Traj		

	//Graph Bx
	Display/N=IntBx_X_Traj/K=1 IntBx_X_Traj vs PosXTraj
	Label bottom "\\Z12Transversal Position X [m]"
	Label left "\\Z12First Integral Bx over trajectory [T.m]"

	//Graph By
	Display/N=IntBy_X_Traj/K=1 IntBy_X_Traj vs PosXTraj
	Label bottom "\\Z12Transversal Position X [m]"
	Label left "\\Z12First Integral By over trajectory[T.m]"

	//Graph Bz
	Display/N=IntBz_X_Traj/K=1 IntBz_X_Traj vs PosXTraj
	Label bottom "\\Z12Transversal Position X [m]"
	Label left "\\Z12First Integral Bz over trajectory[T.m]"
End


Function show_integralstraj_Table(ctrlName) : ButtonControl
	String ctrlName
	Edit/K=1 PosXTraj,IntBx_X_Traj,IntBy_X_Traj,IntBz_X_Traj
End


Function ShowIntegrals2Traj(ctrlName) : ButtonControl
	String ctrlName
	
	Wave PosXTraj
	Wave Int2Bx_X_Traj	
	Wave Int2By_X_Traj	
	Wave Int2Bz_X_Traj		

	//Graph Bx
	Display/N=Int2Bx_X_Traj/K=1 Int2Bx_X_Traj vs PosXTraj
	Label bottom "\\Z12Transversal Position X [m]"
	Label left "\\Z12Second Integral Bx over trajectory [T.m2]"

	//Graph By
	Display/N=Int2By_X_Traj/K=1 Int2By_X_Traj vs PosXTraj
	Label bottom "\\Z12Transversal Position X [m]"
	Label left "\\Z12Second Integral By over trajectory[T.m2]"

	//Graph Bz
	Display/N=Int2Bz_X_Traj/K=1 Int2Bz_X_Traj vs PosXTraj
	Label bottom "\\Z12Transversal Position X [m]"
	Label left "\\Z12Second Integral Bz over trajectory[T.m2]"
End


Function show_integrals2traj_Table(ctrlName) : ButtonControl
	String ctrlName
	Edit/K=1 PosXTraj,Int2Bx_X_Traj,Int2By_X_Traj,Int2Bz_X_Traj
End


Function ShowTrajectories(ctrlName) : ButtonControl
	String ctrlName

	NVAR StartXTraj    		= :varsFieldMap:StartXTraj
	NVAR EndXTraj      		= :varsFieldMap:EndXTraj	
	NVAR StepsXTraj	   		= :varsFieldMap:StepsXTraj
	NVAR NPointsXTraj  		= :varsFieldMap:NPointsXTraj	
	NVAR BeamDirection 		= :varsFieldMap:BeamDirection
	NVAR/Z AddReferenceLines	= :varsFieldMap:AddReferenceLines		
	
	if (NVAR_EXists(AddReferenceLines)==0)
		variable/G :varsFieldMap:AddReferenceLines = 0
	endif
	
	variable i
	string AxisY
	string AxisX
	
	if (AddReferenceLines==1)
		CalcRefLinesCrossingPoint()
		Wave CrossingPointX
		Wave CrossingPointYZ
	endif
	
	for (i=0;i<NPointsXTraj;i=i+1)
		// Trajectory X
		AxisY = "TrajX" + num2str((StartXTraj + i*StepsXTraj)/1000)
		Wave TmpY = $AxisY

		if (BeamDirection == 1)
			AxisX = "TrajY" + num2str((StartXTraj + i*StepsXTraj)/1000)
		else
			AxisX = "TrajZ" + num2str((StartXTraj + i*StepsXTraj)/1000)		
		endif
		Wave TmpX = $AxisX
		
		if (i==0)
			Display/N=TrajectoriesX/K=1 TmpY vs TmpX
			if (BeamDirection == 1)
				Label bottom "\\Z12Longitudinal Position Y [m]"
			else
				Label bottom "\\Z12Longitudinal Position Z [m]"			
			endif

			Label left "\\Z12Trajectory X[m]"
		else
			Appendtograph/W=TrajectoriesX TmpY vs TmpX
		endif
		
		if (AddReferenceLines==1)
			string PosLineName, InitLineName, FinalLineName
			
			PosLineName = AxisY + "_PosRefLine"
			InitLineName = AxisY + "_InitRefLine"
			FinalLineName = AxisY + "_FinalRefLine"
			
			Wave/Z PosLine = $(PosLineName)
			Wave/Z InitLine = $(InitLineName)
			Wave/Z FinalLine = $(FinalLineName)
			
			if (WaveExists(PosLine) == 1 && WaveExists(InitLine) == 1 && WaveExists(FinalLine) == 1)
				Appendtograph/W=TrajectoriesX/C=(30000, 30000, 30000) InitLine/TN=$InitLineName vs PosLine
				Appendtograph/W=TrajectoriesX/C=(30000, 30000, 30000) FinalLine/TN=$FinalLineName vs PosLine
				ModifyGraph/W=TrajectoriesX lstyle($InitLineName)=3
				ModifyGraph/W=TrajectoriesX lstyle($FinalLineName)=3 
			endif
						
		endif
		
		// Trajectory YZ
		AxisY = "TrajX" + num2str((StartXTraj + i*StepsXTraj)/1000)
		Wave TmpY = $AxisY

		if (BeamDirection == 1)
			AxisY = "TrajZ" + num2str((StartXTraj + i*StepsXTraj)/1000)
			AxisX = "TrajY" + num2str((StartXTraj + i*StepsXTraj)/1000)
		else
			AxisY = "TrajY" + num2str((StartXTraj + i*StepsXTraj)/1000)		
			AxisX = "TrajZ" + num2str((StartXTraj + i*StepsXTraj)/1000)					
		endif
		Wave TmpY = $AxisY
		Wave TmpX = $AxisX
		
		if (i==0)
			Display/N=TrajectoriesYZ/K=1 TmpY vs TmpX
			if (BeamDirection == 1)
				Label bottom "\\Z12Longitudinal Position Y [m]"
				Label left "\\Z12Trajectory Z[m]"
			else
				Label bottom "\\Z12Longitudinal Position Z [m]"			
				Label left "\\Z12Trajectory Y[m]"				
			endif
		else
			Appendtograph/W=TrajectoriesYZ TmpY vs TmpX
		endif

	endfor
	
	if (AddReferenceLines==1)
		string tagtext, yzstr
		variable xval
		Appendtograph/W=TrajectoriesX/C=(30000, 30000, 30000) CrossingPointX/TN='CrossingPoint' vs CrossingPointYZ
		ModifyGraph/W=TrajectoriesX mode('CrossingPoint')=3, marker('CrossingPoint')=19, msize('CrossingPoint')=2
		
		for (i=0; i<NPointsXTraj; i=i+1)
			xval = pnt2x(CrossingPointYZ, i)
			if (BeamDirection == 1)
				yzstr = "Y"
			else
				yzstr = "Z"
			endif
			sprintf tagtext, "X = %.3f mm\n%s = %.3f mm", CrossingPointX[i]*1000, yzstr, CrossingPointYZ[i]*1000
			Tag/X=20/W=TrajectoriesX/F=2/L=2 'CrossingPoint', xval, tagtext
		endfor
		
	endif
	
End


Function CalcRefLinesCrossingPoint()

	NVAR StartXTraj    		= :varsFieldMap:StartXTraj
	NVAR EndXTraj      		= :varsFieldMap:EndXTraj	
	NVAR StepsXTraj	   		= :varsFieldMap:StepsXTraj
	NVAR NPointsXTraj  		= :varsFieldMap:NPointsXTraj
	NVAR BeamDirection 		= :varsFieldMap:BeamDirection

	variable i, npts, ai, bi, af, bf, initial_angle, final_angle
	string PosName, TrajName, InitLineName, FinalLineName, PosLineName

	Make/O/N=(NPointsXTraj) CrossingPointX
	Make/O/N=(NPointsXTraj) CrossingPointYZ

	for (i=0;i<NPointsXTraj;i=i+1)
		TrajName = "TrajX" + num2str((StartXTraj + i*StepsXTraj)/1000)
		Wave Traj = $TrajName

		if (BeamDirection == 1)
			PosName = "TrajY" + num2str((StartXTraj + i*StepsXTraj)/1000)
		else
			PosName = "TrajZ" + num2str((StartXTraj + i*StepsXTraj)/1000)		
		endif
		Wave Pos = $PosName
		
		npts = numpnts(Traj)
		if (npts < 4)
			DoAlert 0, "Invalid trajectory number of points."
			return -1
		endif
		
		ai = (Traj[1] - Traj[0])/(Pos[1] - Pos[0])
		af = (Traj[npts-1] - Traj[npts-2])/(Pos[npts-1] - Pos[npts-2])
		
		initial_angle = atan(ai)
		final_angle = atan(af) 
	
		PosLineName  = TrajName + "_PosRefLine"	
		InitLineName = TrajName + "_InitRefLine"
		FinalLineName = TrajName + "_FinalRefLine"
	
		Make/O/N=2 $(PosLineName)
		Make/O/N=2 $(InitLineName)
		Make/O/N=2 $(FinalLineName)
	
		Wave PosLine = $PosLineName
		Wave InitLine = $InitLineName
		Wave FinalLine = $FinalLineName
		
		PosLine[0] = Pos[0]
		PosLine[1] = Pos[npts-1]
		
		InitLine[0] = Traj[0]
		InitLine[1] = Traj[0] + tan(initial_angle)*(PosLine[1] - PosLine[0])
	
		FinalLine[0] = Traj[npts-1] - tan(final_angle)*(PosLine[1] - PosLine[0])
		FinalLine[1] = Traj[npts-1]
		
		bi = InitLine[0] - ai*PosLine[0]
		bf = FinalLine[0] - af*PosLine[0]
		
		CrossingPointYZ[i] = -(bf - bi)/(af-ai)
		CrossingPointX[i] = -(bf - bi)/(af-ai)*ai + bi
	
	endfor

End

Function ShowDeflections(ctrlName) : ButtonControl
	String ctrlName

	NVAR BeamDirection = :varsFieldMap:BeamDirection
	
	Wave PosXTraj
	Wave Deflection_X
	Wave Deflection_Y	
	Wave Deflection_Z	
	Wave Deflection_IntTraj_X	
	Wave Deflection_IntTraj_Y
	Wave Deflection_IntTraj_Z			

	Display/N=DeflectionX/K=1 Deflection_X vs PosXTraj
	AppendToGraph/R Deflection_IntTraj_X vs PosXTraj	
	ModifyGraph rgb(Deflection_IntTraj_X)=(0,9472,39168)	
	Label bottom "\\Z12Transversal Position X [m]"
	Label left "\\Z12Deflection Trajectories X [°]"
	Label right "\\Z12Deflection Integral Trajectories X [°]"	
	
	if (BeamDirection == 1)
		Display/N=DeflectionZ/K=1 Deflection_Z vs PosXTraj
		AppendToGraph/R Deflection_IntTraj_Z vs PosXTraj	
		ModifyGraph rgb(Deflection_IntTraj_Z)=(0,9472,39168)			
		Label bottom "\\Z12Transversal Position X [m]"
		Label left "\\Z12Deflection Trajectories Z [°]"
		Label right "\\Z12Deflection Integral Trajectories Z [°]"			
	else
		Display/N=DeflectionY/K=1 Deflection_Y vs PosXTraj
		AppendToGraph/R Deflection_IntTraj_Y vs PosXTraj	
		ModifyGraph rgb(Deflection_IntTraj_Y)=(0,9472,39168)					
		Label bottom "\\Z12Transversal Position X [m]"
		Label left "\\Z12Deflection Trajectories Y [°]"
		Label right "\\Z12Deflection Integral Trajectories Y [°]"			
	endif

End


Function show_deflections_Table(ctrlName) : ButtonControl
	String ctrlName
	
	NVAR BeamDirection = :varsFieldMap:BeamDirection
	
	Wave PosXTraj
	Wave Deflection_X
	Wave Deflection_Y	
	Wave Deflection_Z	
	
	if (BeamDirection == 1)
		Edit/K=1 PosXTraj,Deflection_X,Deflection_Z,Deflection_IntTraj_X,Deflection_IntTraj_Z
	else
		Edit/K=1 PosXTraj,Deflection_X,Deflection_Y,Deflection_IntTraj_X,Deflection_IntTraj_Y
	endif

End


Function ShowDynMultipoles(ctrlName) : ButtonControl
	String ctrlName

	Edit/K=1 Dyn_Mult_Normal_Int, Dyn_Mult_Skew_Int, Dyn_Mult_Normal_Norm, Dyn_Mult_Skew_Norm	
	
End


Function ShowDynMultipoleProfile(ctrlName) : ButtonControl
	String ctrlName

	NVAR K = :varsFieldMap:DynMultipoleK
	
	wave Dyn_Mult_PosYZ
	wave Dyn_Mult_Normal
	wave Dyn_Mult_Skew
	
	string name_normal = "Dyn_Mult_Normal_k" + num2str(K)
	string name_skew = "Dyn_Mult_Skew_k" + num2str(K)
	
	string graphlabel
	if (K == 0)
		graphlabel = "Dipolar field [T]"
	elseif (K == 1)
		graphlabel = "Quadrupolar field [T/m]"
	elseif (K == 2)
		graphlabel = "Sextupolar field [T/m²]"
	elseif (K == 3)
		graphlabel = "Octupolar field [T/m³]"
	else
		graphlabel = num2str(2*(K +1))+ "-polar field"
	endif
	
	Make/D/O/N=(numpnts(Dyn_Mult_PosYZ)) $name_normal
	Wave Tmp_Normal = $name_normal
	Tmp_Normal[] = Dyn_Mult_Normal[p][K]
	Display/N=Dyn_Mult_Normal/K=1 Tmp_Normal vs Dyn_Mult_PosYZ
	Label bottom "\\Z12Longitudinal Position YZ [m]"
	Label left  "\\Z12Normal " + graphlabel

	Make/D/O/N=(numpnts(Dyn_Mult_PosYZ)) $name_skew
	Wave Tmp_Skew = $name_skew
	Tmp_Skew[] = Dyn_Mult_Skew[p][K]
	Display/N=Dyn_Mult_Skew/K=1 Tmp_Skew vs Dyn_Mult_PosYZ
	Label bottom "\\Z12Longitudinal Position YZ [m]"
	Label left  "\\Z12Skew " + graphlabel
		
End


Function ShowResidDynMultipoles(ctrlName) : ButtonControl
	String ctrlName

	Wave Dyn_Mult_Grid
	Wave Dyn_Mult_Normal_Res
	Wave Dyn_Mult_Skew_Res

	Display/N=Dyn_Mult_Normal_Res/K=1 Dyn_Mult_Normal_Res vs Dyn_Mult_Grid
	Label bottom "\\Z12Transversal displacement from trajectory [m]"
	Label left "\\Z12Normalized Residual Dynamic \rNormal Multipoles"

	Display/N=Dyn_Mult_Skew_Res/K=1 Dyn_Mult_Skew_Res vs Dyn_Mult_Grid
	Label bottom "\\Z12Transversal displacement from trajectory [m]"
	Label left "\\Z12Normalized Residual Dynamic \rSkew Multipoles"

End


Function ShowResidDynMultipoles_Table(ctrlName) : ButtonControl
	String ctrlName
	Edit/K=1 Dyn_Mult_Grid,Dyn_Mult_Normal_Res,Dyn_Mult_Skew_Res
End


Window Field_Specification() : Panel
	PauseUpdate; Silent 1		

	if (DataFolderExists("root:varsCAMTO")==0)
		DoAlert 1, "CAMTO variables not found. Initialize CAMTO?"
		if (V_flag == 1)
			Initialize_CAMTO()
		else
			return
		endif 
	endif

	string PanelName
	PanelName = WinList("Field_Specification",";","")	
	if (stringmatch(PanelName, "Field_Specification;"))
		Killwindow Field_Specification
	endif	
	
	NewPanel/K=1/W=(240,60,615,550)

	TabControl MyTabControl,pos={5,5},size={370,440},tabLabel(0)="Main Parameters",value=0
	TabControl MyTabControl,proc=TabActionProc,tabLabel(1)="Multipole Errors"

	SetVariable tab0_maink,pos={20,45},size={140,20},title="Main Harmonic: "
	SetVariable tab0_maink,value=root:varsCAMTO:MainK,limits={0,15,1}

	PopupMenu tab0_mainskew,pos={170,45},size={100,20},proc=PopupFieldComponent,title=""
	PopupMenu tab0_mainskew,value= #"\"Normal;Skew\""

	TitleBox tab0_title, pos={20, 90},frame=0,fStyle=1,title="Normal Integrated Multipoles:",fSize=14
	SetVariable tab0_nr_multipoles,pos={260,90},size={80,14},title="rows:"
	SetVariable tab0_nr_multipoles,value= root:varsCAMTO:NrMultipoles,limits={0,3,1}
	SetVariable tab0_nr_multipoles,proc=ChangeMultipolesTable
	TitleBox tab0_header1, pos={20,115},size={130,18},frame=0,fStyle=1,title="n",fSize=12,anchor=MC
	TitleBox tab0_header2, pos={170,115},size={170,18},frame=0,fStyle=1,title="Integrated Bn",fSize=12,anchor=MC

	TitleBox tab0_skew_title, pos={20, 280},frame=0,fStyle=1,title="Skew Integrated Multipoles:",fSize=14
	SetVariable tab0_skew_nr_multipoles,pos={260,280},size={80,14},title="rows:"
	SetVariable tab0_skew_nr_multipoles,value= root:varsCAMTO:NrSkewMultipoles,limits={0,3,1}
	SetVariable tab0_skew_nr_multipoles,proc=ChangeSkewMultipolesTable
	TitleBox tab0_skew_header1, pos={20,305},size={130,18},frame=0,fStyle=1,title="n",fSize=12,anchor=MC
	TitleBox tab0_skew_header2, pos={170,305},size={170,18},frame=0,fStyle=1,title="Integrated Bn",fSize=12,anchor=MC
	
	SetVariable tab1_distnorm,pos={20,45},size={340,20},title="Distance for multipolar analysis [mm]: ", disable=1
	SetVariable tab1_distnorm,value=root:varsCAMTO:DistCenter,limits={0,inf,1}
	
	TitleBox tab1_title, pos={20,80},frame=0,fStyle=1,title="Norm. Integrated Multipole Errors:",fSize=14,disable=1
	
	SetVariable tab1_nr_multipole_errors,pos={270,80},size={80,14},title="rows:", disable=1
	SetVariable tab1_nr_multipole_errors,value= root:varsCAMTO:NrMultipoleErrors,limits={1,15,1}
	SetVariable tab1_nr_multipole_errors,proc=ChangeMultErrorsTable
	TitleBox tab1_header1, pos={20,100},size={60,40},disable=1,frame=0,fStyle=1,title="n",fSize=12,anchor=MC
	TitleBox tab1_header2, pos={90,100},size={60,40},disable=1,frame=0,fStyle=1,title="Systematic\nNormal",fSize=12,anchor=MC
	TitleBox tab1_header3, pos={160,100},size={60,40},disable=1,frame=0,fStyle=1,title="Systematic\nSkew",fSize=12,anchor=MC
	TitleBox tab1_header4, pos={230,100},size={60,40},disable=1,frame=0,fStyle=1,title="Random\nNormal",fSize=12,anchor=MC
	TitleBox tab1_header5, pos={300,100},size={60,40},disable=1,frame=0,fStyle=1,title="Random\nSkew",fSize=12,anchor=MC	
	
	Button fieldspec_button,pos={20,455},size={330,25},proc=Update_Field_Spec,title="Update Field Specification"
	Button fieldspec_button,fSize=15,fStyle=1

	UpdateMultipolesTable()
	UpdateSkewMultipolesTable()		

EndMacro


Function PopupFieldComponent(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	NVAR NormComponent = root:varsCAMTO:MainSkew
	NormComponent = popNum
	
End


Function TabActionProc(tc) : TabControl
	STRUCT WMTabControlAction& tc
	
	NVAR nr_multipoles = root:varsCAMTO:NrMultipoles
	NVAR nr_skew_multipoles = root:varsCAMTO:NrSkewMultipoles
	NVAR nr_multipole_errors = root:varsCAMTO:NrMultipoleErrors
	
	variable i
	string variable_name

	SetVariable tab0_maink, win=Field_Specification, disable=(tc.tab!=0)
	PopupMenu tab0_mainskew, win=Field_Specification, disable=(tc.tab!=0)
	
	TitleBox tab0_title, win=Field_Specification, disable=(tc.tab!=0)
	SetVariable tab0_nr_multipoles, win=Field_Specification, disable=(tc.tab!=0)

	TitleBox tab0_skew_title, win=Field_Specification, disable=(tc.tab!=0)
	SetVariable tab0_skew_nr_multipoles, win=Field_Specification, disable=(tc.tab!=0)

	for (i=0; i<nr_multipoles; i=i+1)
		TitleBox tab0_header1, win=Field_Specification, disable=(tc.tab!=0)
		TitleBox tab0_header2, win=Field_Specification, disable=(tc.tab!=0)
		variable_name = "tab0_row" + num2str(i) + "_monomial"
		SetVariable $(variable_name), win=Field_Specification, disable=(tc.tab!=0)
		variable_name = "tab0_row" + num2str(i) + "_int_field"
		SetVariable $(variable_name), win=Field_Specification, disable=(tc.tab!=0)
	endfor

	for (i=0; i<nr_skew_multipoles; i=i+1)
		TitleBox tab0_skew_header1, win=Field_Specification, disable=(tc.tab!=0)
		TitleBox tab0_skew_header2, win=Field_Specification, disable=(tc.tab!=0)
		variable_name = "tab0_row" + num2str(i) + "_skew_monomial"
		SetVariable $(variable_name), win=Field_Specification, disable=(tc.tab!=0)
		variable_name = "tab0_row" + num2str(i) + "_skew_int_field"
		SetVariable $(variable_name), win=Field_Specification, disable=(tc.tab!=0)
	endfor
	
	TitleBox tab1_title, win=Field_Specification, disable=(tc.tab!=1)
	SetVariable tab1_distnorm, win=Field_Specification, disable=(tc.tab!=1)
	SetVariable tab1_nr_multipole_errors, win=Field_Specification, disable=(tc.tab!=1)
	
	TitleBox tab1_header1, win=Field_Specification, disable=(tc.tab!=1)
	TitleBox tab1_header2, win=Field_Specification, disable=(tc.tab!=1)
	TitleBox tab1_header3, win=Field_Specification, disable=(tc.tab!=1)
	TitleBox tab1_header4, win=Field_Specification, disable=(tc.tab!=1)
	TitleBox tab1_header5, win=Field_Specification, disable=(tc.tab!=1)
	
	for (i=0; i<nr_multipole_errors; i=i+1)
		variable_name = "tab1_row" + num2str(i) + "_monomial"
		SetVariable $(variable_name), win=Field_Specification, disable=(tc.tab!=1)
		variable_name = "tab1_row" + num2str(i) + "_sys_normal"
		SetVariable $(variable_name), win=Field_Specification, disable=(tc.tab!=1)
		variable_name = "tab1_row" + num2str(i) + "_sys_skew"
		SetVariable $(variable_name), win=Field_Specification, disable=(tc.tab!=1)
		variable_name = "tab1_row" + num2str(i) + "_rnd_normal"
		SetVariable $(variable_name), win=Field_Specification, disable=(tc.tab!=1)
		variable_name = "tab1_row" + num2str(i) + "_rnd_skew"
		SetVariable $(variable_name), win=Field_Specification, disable=(tc.tab!=1)
	endfor
	
	if (tc.tab==0)
		UpdateMultipolesTable()
	elseif (tc.tab==1)
		UpdateMultErrorsTable()
	endif
	
	return 0
End


Function UpdateMultipolesTable()

	NVAR nr_multipoles = root:varsCAMTO:NrMultipoles
	NVAR prev_nr_multipoles = root:varsCAMTO:PrevNrMultipoles

	if (nr_multipoles == 0)
		TitleBox tab0_header1, win=Field_Specification, disable=1
		TitleBox tab0_header2, win=Field_Specification, disable=1
	else
		TitleBox tab0_header1, win=Field_Specification, disable=0
		TitleBox tab0_header2, win=Field_Specification, disable=0	
	endif
	
	Wave NormalMultipoles = root:wavesCAMTO:NormalMultipoles

	variable space = 40
	variable i
	string variable_name

	for (i=0; i<prev_nr_multipoles; i=i+1)
		variable_name = "tab0_row" + num2str(i) + "_monomial"
		SetVariable $(variable_name), win=Field_Specification, disable=1
		variable_name = "tab0_row" + num2str(i) + "_int_field"
		SetVariable $(variable_name), win=Field_Specification, disable=1
	endfor

	for (i=0; i<nr_multipoles; i=i+1)
		variable_name = "tab0_row" + num2str(i) + "_monomial"
		SetVariable $(variable_name), win=Field_Specification, pos={20,(140+i*space)},size={130,18},title=" ",disable=0
		SetVariable $(variable_name), win=Field_Specification, limits={0,inf,0}, value=NormalMultipoles[i][0]
		
		variable_name = "tab0_row" + num2str(i) + "_int_field"
		SetVariable $(variable_name), win=Field_Specification, pos={170,(140+i*space)},size={170,18},title=" ",disable=0
		SetVariable $(variable_name), win=Field_Specification, limits={-inf,inf,0},value=NormalMultipoles[i][1]
		
	endfor

	prev_nr_multipoles = nr_multipoles

End


Function UpdateSkewMultipolesTable()

	NVAR nr_skew_multipoles = root:varsCAMTO:NrSkewMultipoles
	NVAR prev_nr_skew_multipoles = root:varsCAMTO:PrevNrSkewMultipoles
	
	if (nr_skew_multipoles == 0)
		TitleBox tab0_skew_header1, win=Field_Specification, disable=1
		TitleBox tab0_skew_header2, win=Field_Specification, disable=1
	else
		TitleBox tab0_skew_header1, win=Field_Specification, disable=0
		TitleBox tab0_skew_header2, win=Field_Specification, disable=0	
	endif
	
	Wave SkewMultipoles = root:wavesCAMTO:SkewMultipoles

	variable space = 40
	variable i
	string variable_name

	for (i=0; i<prev_nr_skew_multipoles; i=i+1)
		variable_name = "tab0_row" + num2str(i) + "_skew_monomial"
		SetVariable $(variable_name), win=Field_Specification, disable=1
		variable_name = "tab0_row" + num2str(i) + "_skew_int_field"
		SetVariable $(variable_name), win=Field_Specification, disable=1
	endfor

	for (i=0; i<nr_skew_multipoles; i=i+1)
		variable_name = "tab0_row" + num2str(i) + "_skew_monomial"
		SetVariable $(variable_name), win=Field_Specification, pos={20,(330+i*space)},size={130,18},title=" ",disable=0
		SetVariable $(variable_name), win=Field_Specification, limits={0,inf,0}, value=SkewMultipoles[i][0]
		
		variable_name = "tab0_row" + num2str(i) + "_skew_int_field"
		SetVariable $(variable_name), win=Field_Specification,pos={170,(330+i*space)},size={170,18},title=" ",disable=0
		SetVariable $(variable_name), win=Field_Specification,limits={-inf,inf,0},value=SkewMultipoles[i][1]
		
	endfor

	prev_nr_skew_multipoles = nr_skew_multipoles

End


Function UpdateMultErrorsTable()

	NVAR nr_multipole_errors = root:varsCAMTO:NrMultipoleErrors
	NVAR prev_nr_multipole_errors = root:varsCAMTO:PrevNrMultipoleErrors

	Wave MultipoleErrors = root:wavesCAMTO:MultipoleErrors

	variable space = 20
	variable i
	string variable_name

	for (i=0; i<prev_nr_multipole_errors; i=i+1)
		variable_name = "tab1_row" + num2str(i) + "_monomial"
		SetVariable $(variable_name),win=Field_Specification,disable=1
		variable_name = "tab1_row" + num2str(i) + "_sys_normal"
		SetVariable $(variable_name),win=Field_Specification,disable=1
		variable_name = "tab1_row" + num2str(i) + "_sys_skew"
		SetVariable $(variable_name),win=Field_Specification,disable=1
		variable_name = "tab1_row" + num2str(i) + "_rnd_normal"
		SetVariable $(variable_name),win=Field_Specification,disable=1
		variable_name = "tab1_row" + num2str(i) + "_rnd_skew"
		SetVariable $(variable_name),win=Field_Specification,disable=1
	endfor

	for (i=0; i<nr_multipole_errors; i=i+1)
		variable_name = "tab1_row" + num2str(i) + "_monomial"
		SetVariable $(variable_name),win=Field_Specification,pos={20,(140+i*space)},size={60,18},title=" ",limits={0,inf,0},disable=0
		SetVariable $(variable_name),win=Field_Specification,value=MultipoleErrors[i][0]
		
		variable_name = "tab1_row" + num2str(i) + "_sys_normal"
		SetVariable $(variable_name),win=Field_Specification,pos={90,(140+i*space)},size={60,18},title=" ",limits={-inf,inf,0},disable=0
		if (MultipoleErrors[i][1] == 0)
			SetVariable $(variable_name),win=Field_Specification, format="%1.0f"
		else
			SetVariable $(variable_name),win=Field_Specification, format="% 2.1e"
		endif
		SetVariable $(variable_name),win=Field_Specification,value=MultipoleErrors[i][1], proc=SetTableFormat
		
		variable_name = "tab1_row" + num2str(i) + "_sys_skew"
		SetVariable $(variable_name),win=Field_Specification,pos={160,(140+i*space)},size={60,18},title=" ",limits={-inf,inf,0},disable=0
		if (MultipoleErrors[i][2] == 0)
			SetVariable $(variable_name),win=Field_Specification, format="%1.0f"
		else
			SetVariable $(variable_name),win=Field_Specification, format="% 2.1e"
		endif
		SetVariable $(variable_name),win=Field_Specification,value=MultipoleErrors[i][2], proc=SetTableFormat
		
		variable_name = "tab1_row" + num2str(i) + "_rnd_normal"
		SetVariable $(variable_name),win=Field_Specification,pos={230,(140+i*space)},size={60,18},title=" ",limits={-inf,inf,0},disable=0
		if (MultipoleErrors[i][3] == 0)
			SetVariable $(variable_name),win=Field_Specification, format="%1.0f"
		else
			SetVariable $(variable_name),win=Field_Specification, format="% 2.1e"
		endif
		SetVariable $(variable_name),win=Field_Specification, value=MultipoleErrors[i][3], proc=SetTableFormat
		
		variable_name = "tab1_row" + num2str(i) + "_rnd_skew"
		SetVariable $(variable_name),win=Field_Specification,pos={300,(140+i*space)},size={60,18},title=" ",limits={-inf,inf,0},disable=0
		if (MultipoleErrors[i][4] == 0)
			SetVariable $(variable_name),win=Field_Specification, format="%1.0f"
		else
			SetVariable $(variable_name),win=Field_Specification, format="% 2.1e"
		endif
		SetVariable $(variable_name),win=Field_Specification,value=MultipoleErrors[i][4], proc=SetTableFormat
		
	endfor

	prev_nr_multipole_errors = nr_multipole_errors

End


Function ChangeMultipolesTable(SV_Struct): SetVariableControl
	STRUCT WMSetVariableAction &SV_Struct
	
	NVAR nr_multipoles = root:varsCAMTO:NrMultipoles
	Wave NormalMultipoles = root:wavesCAMTO:NormalMultipoles
	
	Redimension/N=(nr_multipoles, 2) NormalMultipoles
	
	UpdateMultipolesTable()	
End


Function ChangeSkewMultipolesTable(SV_Struct): SetVariableControl
	STRUCT WMSetVariableAction &SV_Struct
	
	NVAR nr_skew_multipoles = root:varsCAMTO:NrSkewMultipoles
	Wave SkewMultipoles = root:wavesCAMTO:SkewMultipoles
	
	Redimension/N=(nr_skew_multipoles, 2) SkewMultipoles

	UpdateSkewMultipolesTable()	
End


Function ChangeMultErrorsTable(SV_Struct): SetVariableControl
	STRUCT WMSetVariableAction &SV_Struct
	
	NVAR nr_multipole_errors = root:varsCAMTO:NrMultipoleErrors
	Wave MultipoleErrors = root:wavesCAMTO:MultipoleErrors
	
	Redimension/N=(nr_multipole_errors, 5) MultipoleErrors
	
	UpdateMultErrorsTable()
End


Function SetTableFormat(SV_Struct): SetVariableControl
	STRUCT WMSetVariableAction &SV_Struct
	
	if (SV_Struct.dval == 0)
		SetVariable $(SV_Struct.ctrlName),win=Field_Specification, format="%1.0f"
	else
		SetVariable $(SV_Struct.ctrlName),win=Field_Specification, format="% 2.1e"
	endif
	
End


Function Update_Field_Spec(ctrlName) : ButtonControl
	string ctrlName
	CalcResFieldSpec()
	InitializeSpecVariables()
	UpdateIntegralsMultipolesPanel()
	UpdateDynMultipolesPanel()
	UpdateCompareResultsPanel()
	print "Field specification updated!"
End


Function CalcResFieldSpec()

	DFREF df = GetDataFolderDFR()
	
	SetDataFolder root:wavesCAMTO:

	NVAR r0     = root:varsCAMTO:DistCenter
	NVAR main_k = root:varsCAMTO:MainK

	Wave MultipoleErrors = root:wavesCAMTO:MultipoleErrors
	
	variable grid_min = -r0
	variable grid_max = r0
	variable grid_nrpts = 101
	variable i
	
	Make/D/O/N=(grid_nrpts) trans_pos_residue

	for (i=0; i<grid_nrpts; i=i+1)
		trans_pos_residue[i] = grid_min/1000 + i*(grid_max/1000 - grid_min/1000)/(grid_nrpts-1)
	endfor
	
	variable size =	DimSize(MultipoleErrors, 0)
	
	Make/O/N=(size) normal_sys_monomials
	Make/D/O/N=(size) normal_sys_multipoles
	Make/O/N=(size) normal_rms_monomials
	Make/D/O/N=(size) normal_rms_multipoles
	Make/O/N=(size) skew_sys_monomials
	Make/D/O/N=(size) skew_sys_multipoles
	Make/O/N=(size) skew_rms_monomials
	Make/D/O/N=(size) skew_rms_multipoles
	
	variable size_normal_sys = 0
	variable size_normal_rms = 0
	variable size_skew_sys = 0
	variable size_skew_rms = 0 

	
	for (i=0; i<size; i=i+1)
	
		if ( MultipoleErrors[i][1] != 0)
			normal_sys_monomials[size_normal_sys] = MultipoleErrors[i][0]
			normal_sys_multipoles[size_normal_sys] = MultipoleErrors[i][1]
			size_normal_sys = size_normal_sys + 1		
		endif

		if (MultipoleErrors[i][2] != 0)
			skew_sys_monomials[size_skew_sys] = MultipoleErrors[i][0]
			skew_sys_multipoles[size_skew_sys] = MultipoleErrors[i][2]
			size_skew_sys = size_skew_sys + 1		
		endif
		
		if ( MultipoleErrors[i][3] != 0)
			normal_rms_monomials[size_normal_rms] = MultipoleErrors[i][0]
			normal_rms_multipoles[size_normal_rms] = MultipoleErrors[i][3]
			size_normal_rms = size_normal_rms + 1		
		endif	
	
		if (MultipoleErrors[i][4] != 0)
			skew_rms_monomials[size_skew_rms] = MultipoleErrors[i][0]
			skew_rms_multipoles[size_skew_rms] = MultipoleErrors[i][4]
			size_skew_rms = size_skew_rms + 1		
		endif
		
	endfor	
	
	Redimension/N=(size_normal_sys) normal_sys_monomials
	Redimension/N=(size_normal_sys) normal_sys_multipoles 
	Redimension/N=(size_skew_sys) skew_sys_monomials
	Redimension/N=(size_skew_sys) skew_sys_multipoles 
	Redimension/N=(size_normal_rms) normal_rms_monomials
	Redimension/N=(size_normal_rms) normal_rms_multipoles 
	Redimension/N=(size_skew_rms) skew_rms_monomials
	Redimension/N=(size_skew_rms) skew_rms_multipoles 	
		
	CalcResFieldSpecAux("Normal", main_k, r0, trans_pos_residue, normal_sys_monomials, normal_sys_multipoles, normal_rms_monomials, normal_rms_multipoles)
	
	CalcResFieldSpecAux("Skew", main_k, r0, trans_pos_residue, skew_sys_monomials, skew_sys_multipoles, skew_rms_monomials, skew_rms_multipoles)
	
	SetDataFolder df
	
End


Function CalcResFieldSpecAux(graph_label, main_k, r0, vec_pos, sys_monomials, sys_relative_multipoles, rms_monomials, rms_relative_multipoles)
	string graph_label
	variable main_k
	variable r0
	Wave vec_pos
	Wave sys_monomials
	Wave sys_relative_multipoles
	Wave rms_monomials
	Wave rms_relative_multipoles

	variable nr_samples = 5000
	variable gauss_trunc = 1
	variable nx = numpnts(vec_pos)
	
	Make/D/O/N=(nx) sys_residue 
	Make/D/O/N=(nx) rms_residue 
	Make/D/O/N=(nx) residue_field
	
	sys_residue[] = 0
	rms_residue[] = 0
	residue_field[] = 0
	
	variable i
	for (i=0; i<numpnts(sys_monomials); i=i+1)
		sys_residue = sys_residue + sys_relative_multipoles[i]*(vec_pos/(r0/1000))^(sys_monomials[i]-main_k)
	endfor
	
	variable nm   = numpnts(rms_relative_multipoles)
	variable size = nm*nr_samples
	
	Make/D/O/N=(size) rnd_grid 
	variable randomgauss
	
	variable count = 0
	do
		randomgauss = gnoise(1)
		if (abs(randomgauss) <= gauss_trunc)
			rnd_grid[count] = randomgauss
			count = count + 1
		endif
   while (count <= size)

	Redimension/N=(nr_samples, nm) rnd_grid

	Duplicate/O sys_residue max_residue 
	Duplicate/O sys_residue min_residue
	
	Make/D/O/N=(nm) rnd_vector
	Make/D/O/N=(nm) rnd_relative_rms

	variable j

 	for (j=0; j< nr_samples;j=j+1)
 		rnd_vector[] = rnd_grid[j][p]
 		rnd_relative_rms = (rms_relative_multipoles)*rnd_vector
 		
 		rms_residue = 0
 		for (i=0; i< nm; i=i+1)
 			rms_residue = rms_residue + rnd_relative_rms[i]*(vec_pos/(r0/1000))^(rms_monomials[i]-main_k)
 		endfor
 		
 		residue_field = sys_residue + rms_residue
 		
 		for (i=0; i<nx; i=i+1)
 			max_residue[i] = Max(residue_field[i], max_residue[i])
 			min_residue[i] = Min(residue_field[i], min_residue[i])
 		endfor
 		
 	endfor
  	
  	if (cmpstr(graph_label, "Normal")==0)
  		Duplicate/O sys_residue normal_sys_residue 
  		Duplicate/O max_residue normal_max_residue 
  		Duplicate/O min_residue normal_min_residue
  	else
  		Duplicate/O sys_residue skew_sys_residue
  		Duplicate/O max_residue skew_max_residue 
  		Duplicate/O min_residue skew_min_residue
  	endif
 	
 	Killwaves/Z rnd_grid, rnd_vector, rnd_relative_rms
  	Killwaves/Z sys_residue, rms_residue, residue_field
  	Killwaves/Z max_residue, min_residue   

End


Function InitializeSpecVariables()
	
	DFREF df = GetDataFolderDFR()
	
	KillDataFolder/Z root:Nominal
	NewDataFolder/O/S root:Nominal
		
	Killvariables/A/Z
	KillStrings/A/Z
	KillWaves/A/Z
	
	KillDataFolder/Z varsFieldMap
	NewDataFolder/O/S varsFieldMap
       
	Killvariables/A/Z
	KillStrings/A/Z
	
	Wave Normal_Multipoles = root:wavesCAMTO:NormalMultipoles
	Wave Skew_Multipoles  	= root:wavesCAMTO:SkewMultipoles
	Wave Multipole_Errors 	= root:wavesCAMTO:MultipoleErrors
	Wave Normal_Sys 			= root:wavesCAMTO:normal_sys_monomials
	Wave Skew_Sys 			= root:wavesCAMTO:skew_sys_monomials
	Wave Normal_Rms 			= root:wavesCAMTO:normal_rms_monomials
	Wave Skew_Rms 			= root:wavesCAMTO:skew_rms_monomials
	
	NVAR spec_dist_center = root:varsCAMTO:DistCenter
	NVAR spec_knorm = root:varsCAMTO:MainK
	NVAR spec_normcomponent = root:varsCAMTO:MainSkew
	
	Make/O/N=(DimSize(Normal_Multipoles, 0)) Mon_Normal
	Mon_Normal[] = Normal_Multipoles[p][0]

	Make/O/N=(DimSize(Skew_Multipoles, 0)) Mon_Skew
	Mon_Skew[] = Skew_Multipoles[p][0]

	Make/O/N=(DimSize(Multipole_Errors, 0)) Mon_Errors
	Mon_Errors[] = Multipole_Errors[p][0]
	
	Concatenate/NP=0 {Mon_Normal, Mon_Skew, Mon_Errors}, Temp
	Sort Temp, Temp
	if (numpnts(Temp) > 1)
		FindDuplicates/RN=AllMonomials Temp
	else
		Duplicate/O Temp AllMonomials
	endif

	Killwaves/Z Temp

	variable spec_fitting_order = WaveMax(AllMonomials)+1	
	
	Concatenate {Mon_Normal, Normal_Sys, Normal_Rms}, Temp
	Sort Temp, Temp
	if (numpnts(Temp) > 1)
		FindDuplicates/RN=Normal_Monomials Temp
	Else
		Duplicate/O Temp Normal_Monomials		
	endif

	Killwaves/Z Temp

	Concatenate {Mon_Skew, Skew_Sys, Skew_Rms}, Temp
	Sort Temp, Temp
	if (numpnts(Temp) > 1)
		FindDuplicates/RN=Skew_Monomials Temp
	Else
		Duplicate/O Temp Skew_Monomials		
	endif
	
	Killwaves/Z Temp
	
	string spec_normal_coefs = ""
	string spec_res_normal_coefs = ""	
	string temp_normal_str = ""
	string spec_skew_coefs = ""
	string spec_res_skew_coefs = ""	
	string temp_skew_str = ""
		
	variable j
	for (j=0; j<spec_fitting_order; j=j+1)
	
		FindValue/V=(j) Normal_Monomials
		if (V_value == -1)
			spec_normal_coefs = spec_normal_coefs + "1"
		else
			spec_normal_coefs =spec_normal_coefs + "0"
		endif

		FindValue/V=(j) Skew_Monomials
		if (V_value == -1)
			spec_skew_coefs = spec_skew_coefs + "1"
		else
			spec_skew_coefs = spec_skew_coefs + "0"
		endif
	
		if (j<=spec_knorm)
			
			spec_res_normal_coefs = spec_res_normal_coefs + "1"
			spec_res_skew_coefs = spec_res_skew_coefs + "1"
			
		else
					
			FindValue/V=(j) Mon_Normal
			if (V_value == -1)
				temp_normal_str = temp_normal_str + "0"
			else
				temp_normal_str = temp_normal_str + "1"
			endif
			
			if (cmpstr(spec_normal_coefs[j],"1")==0 || cmpstr(temp_normal_str[j],"1")==0)
				spec_res_normal_coefs = spec_res_normal_coefs + "1"
			else
				spec_res_normal_coefs = spec_res_normal_coefs + "0"
			endif
	
			FindValue/V=(j) Mon_Skew
			if (V_value == -1)
				temp_skew_str = temp_skew_str + "0"
			else
				temp_skew_str = temp_skew_str + "1"
			endif
			
			if (cmpstr(spec_skew_coefs[j],"1")==0 || cmpstr(temp_skew_str[j],"1")==0)
				spec_res_skew_coefs = spec_res_skew_coefs + "1"
			else
				spec_res_skew_coefs = spec_res_skew_coefs + "0"
			endif	
				
		endif
			
	endfor

	variable normal_on = 0
	for (j=0; j<spec_fitting_order; j=j+1)
		if (cmpstr(spec_normal_coefs[j],"0")==0)
			normal_on = 1
			break
		endif
	endfor

	if (normal_on == 0)
		spec_normal_coefs = spec_skew_coefs
		spec_res_normal_coefs = spec_res_skew_coefs
	endif

	variable skew_on = 0
	for (j=0; j<spec_fitting_order; j=j+1)
		if (cmpstr(spec_skew_coefs[j],"0")==0)
			skew_on = 1
			break
		endif
	endfor

	if (skew_on == 0)
		spec_skew_coefs = spec_normal_coefs
		spec_res_skew_coefs = spec_res_normal_coefs
	endif
	
	variable/G FittingOrder = spec_fitting_order
	variable/G Distcenter = spec_dist_center
	variable/G GridMin = -spec_dist_center
	variable/G GridMax =  spec_dist_center
	variable/G KNorm = spec_knorm
	variable/G NormComponent = spec_normcomponent
	string/G   NormalCoefs = spec_normal_coefs
	string/G   SkewCoefs = spec_skew_coefs
	string/G   ResNormalCoefs = spec_res_normal_coefs
	string/G   ResSkewCoefs = spec_res_skew_coefs
	
	variable/G FittingOrderTraj = spec_fitting_order
	variable/G DistcenterTraj = spec_dist_center
	variable/G GridMinTraj = -spec_dist_center
	variable/G GridMaxTraj =  spec_dist_center
	variable/G GridNrptsTraj = 101
	variable/G MultipolesTrajShift = 0.001 
	variable/G DynKNorm = spec_knorm
	variable/G DynNormComponent = spec_normcomponent
	string/G   DynNormalCoefs = spec_normal_coefs
	string/G   DynSkewCoefs = spec_skew_coefs
	string/G   DynResNormalCoefs = spec_res_normal_coefs
	string/G   DynResSkewCoefs = spec_res_skew_coefs

	SetDataFolder df	
	
End


Window ID_Results() : Panel
	PauseUpdate; Silent 1
	
	if (DataFolderExists("root:varsCAMTO")==0)
		DoAlert 0, "CAMTO variables not found."
		return 
	endif

	string PanelName
	PanelName = WinList("ID_Results",";","")	
	if (stringmatch(PanelName, "ID_Results;"))
		Killwindow ID_Results
	endif	
	
	NewPanel/K=1/W=(380,260,704,475)
	SetDrawLayer UserBack
	SetDrawEnv fillpat= 0
	DrawRect 3,3,320,132
	SetDrawEnv fillpat= 0
	DrawRect 3,132,320,178	
	SetDrawEnv fillpat= 0
	DrawRect 3,178,320,210	
							
	TitleBox    id_label,pos={80,10},size={100,20},fSize=14,fStyle=1,frame=0,title="Insertion Devices Results"
	ValDisplay  first_int,pos={10,40},size={300,20},title="First Integral (x=0mm) [G.cm]:    "
	ValDisplay  second_int,pos={10,70},size={300,20},title="Second Integral (x=0mm) [kG.cm²]:"
	ValDisplay  phase_error,pos={10,100},size={300,20},title="RMS Phase Error [°]:  "
	
	Button update,pos={11,140},size={300,30},fSize=15,fStyle=1,proc=UpdateIDResultsProc,title="Update"
	
	SetVariable fieldmapdir,pos={20,185},size={290,18},title="Field Map Directory: "
	SetVariable fieldmapdir,noedit=1,value=root:varsCAMTO:FieldMapDir
	
	UpdateFieldMapDirs()
	UpdateIDResultsPanel()
	
EndMacro


Function UpdateIDResultsPanel()

	string PanelName
	PanelName = WinList("ID_Results",";","")	
	if (stringmatch(PanelName, "ID_Results;")==0)
		return -1
	endif
	
	SVAR df = root:varsCAMTO:FieldMapDir
		
	if (strlen(df) > 0)			
		ValDisplay first_int, win=ID_Results, value=#("root:"+ df + ":varsFieldMap:IDFirstIntegral" )
		ValDisplay second_int,win=ID_Results,value=#("root:"+ df + ":varsFieldMap:IDSecondIntegral" )
		ValDisplay phase_error, win=ID_Results, value=#("root:"+ df + ":varsFieldMap:IDPhaseError" )
		Button update,win=ID_Results,disable=0

		if (WaveExists(C_PosX))
			NVAR IDFirstIntegral = root:$(df):varsFieldMap:IDFirstIntegral
			NVAR IDSecondIntegral = root:$(df):varsFieldMap:IDSecondIntegral
			NVAR IDPhaseError = root:$(df):varsFieldMap:IDPhaseError
			
			IntegralsCalculation()
		
			Wave C_PosX		
			Wave IntBy_X
			Wave Int2By_X

			FindValue/T=1e-10/V=0 C_PosX
			if (V_value == -1)
				DoAlert 0, "Position x = 0 not found."
				return -1
			endif
			
			IDFirstIntegral = IntBy_X[V_value]*1e6
			IDSecondIntegral = Int2By_X[V_Value]*1e5

		endif
	
	else
		ValDisplay first_int, win=ID_Results, disable=2
		ValDisplay second_int,win=ID_Results, disable=2
		ValDisplay phase_error, win=ID_Results, disable=2	
		Button update,win=ID_Results,disable=2	
	endif
	
End


Function UpdateIDResultsProc(ctrlName) : ButtonControl
	String ctrlName
	UpdateIDResultsPanel()
End


Window Compare_Results() : Panel
	PauseUpdate; Silent 1		

	if (DataFolderExists("root:varsCAMTO")==0)
		DoAlert 0, "CAMTO variables not found."
		return 
	endif

	//Procura Janela e se estiver aberta, fecha antes de abrir novamente.
	string PanelName
	PanelName = WinList("Compare_Results",";","")	
	if (stringmatch(PanelName, "Compare_Results;"))
		Killwindow Compare_Results
	endif	

	NewPanel/K=1/W=(1010,60,1335,710)
	SetDrawLayer UserBack
	SetDrawEnv fillpat= 0
	DrawRect 3,4,320,55
	SetDrawEnv fillpat= 0
	DrawRect 3,55,320,90
	SetDrawEnv fillpat= 0
	DrawRect 3,90,320,173
	SetDrawEnv fillpat= 0
	DrawRect 3,173,320,300
	SetDrawEnv fillpat= 0
	DrawRect 3,300,320,565
	SetDrawEnv fillpat= 0
	DrawRect 3,565,320,645
	
	TitleBox TitleA,pos={10,12},size={70,18},frame=0,fStyle=1,title="FieldMap A: "
	PopupMenu FieldMapDirA,pos={80,10},size={120,18},bodyWidth=115,mode=0,proc=SelectFieldMapA,title=" "
	CheckBox ReferenceA,pos={210,12},size={100,15},title="Use as reference",value=1,mode=1,proc=SelectReference
	
	TitleBox TitleB,pos={10,32},size={70,18},frame=0,fStyle=1,title="FieldMap B: "	
	PopupMenu FieldMapDirB,pos={80,30},size={120,18},bodyWidth=115,mode=0,proc=SelectFieldMapB,title=" "
	CheckBox ReferenceB,pos={210,32},size={100,15},title="Use as reference",value=0,mode=1,proc=SelectReference		
		
	Button field_Xline,pos={10,61},size={200,24},proc=Compare_Field_In_Line,fStyle=1,title="Show field in X ="
	SetVariable PosXFieldLine,pos={220,63},size={80,18},title="[mm]:", value= root:varsCAMTO:LinePosX
	
	SetVariable StartXProfile,pos={16,97},size={134,18},title="Start X [mm]:",value= root:varsCAMTO:ProfileStartX
	SetVariable EndXProfile,pos={16,122},size={134,18},title="End X  [mm]:",value= root:varsCAMTO:ProfileEndX
	SetVariable PosYZProfile,pos={16,147},size={134,18},title="Pos YZ [mm]:",value= root:varsCAMTO:ProfilePosYZ			
	Button field_profile,pos={160,97},size={150,70},fStyle=1,proc=Compare_Field_Profile,title="Show Field Profile"
		
	TitleBox multipoles_title,pos={110,180},size={110,18},fSize=15,fStyle=1,frame=0,title="Field Multipoles"
	Button show_multipoles,pos={11,210},size={300,24},fStyle=1,proc=Compare_Multipoles,title="Show Multipoles Tables"
	Button show_multipoleprofile,pos={11,240},size={240,24},fStyle=1,proc=Compare_Multipole_Profile,title="Show Multipole Profile: K = "
	SetVariable mnumber,pos={260,243},size={50,20},title=" ",value= root:varsCAMTO:MultipoleK
	Button show_resfield,pos={11,270},size={300,24},fStyle=1,proc=Show_Residual_Multipoles,title="Show Residual Field"
	
	TitleBox trajectory_title,pos={100,305},size={110,18},fSize=15,fStyle=1,frame=0,title="Particle Trajectory"
	
	TitleBox    trajA_title,pos={40,330},size={80,18},frame=0,fSize=14,title="FieldMap A"
	ValDisplay  trajstartx_A,pos={10,360},size={140,18},title="Start X [mm]:    "
	ValDisplay  trajstartangx_A,pos={10,390},size={140,18},title="Angle XY(Z) [°]:"
	ValDisplay  trajstartyz_A,pos={10,420},size={140,18},title="Start YZ [mm]:  "

	TitleBox    trajB_title,pos={200,330},size={80,18},frame=0,fSize=14,title="FieldMap B"
	ValDisplay  trajstartx_B,pos={170,360},size={140,18},title="Start X [mm]:    "
	ValDisplay  trajstartangx_B,pos={170,390},size={140,18},title="Angle XY(Z) [°]:"
	ValDisplay  trajstartyz_B,pos={170,420},size={140,18},title="Start YZ [mm]:  "
	
	Button show_trajectories,pos={11,445},size={160,24},fStyle=1,proc=Compare_Trajectories,title="Show Trajectory"
	CheckBox reference_lines,pos={180,450},size={120,24},title="Add Reference Lines"
		
	Button show_dynmultipoles,pos={11,475},size={300,24},fStyle=1,proc=Compare_DynMultipoles,title="Show Dynamic Multipoles Tables"
	Button show_dynmultipoleprofile,pos={11,505},size={240,24},fStyle=1,proc=Compare_DynMultipole_Profile,title="Show Dynamic Multipole Profile: K = "
	SetVariable dynmnumber,pos={260,508},size={50,20},title=" ",value= root:varsCAMTO:DynMultipoleK
	Button show_dynresfield,pos={11,535},size={300,24},fStyle=1,proc=Show_Residual_Dyn_Multipoles,title="Show Residual Field"
	
	TitleBox rep_title,pos={110,570},size={110,18},fSize=15,fStyle=1,frame=0,title="Magnet Report"
	CheckBox rep_dynmult,pos={16,595},size={250,15},title="\tUse Dynamic Multipoles"
	CheckBox rep_multtwo,pos={266,595},size={30,15},title="\tx 2"
	Button rep_button,pos={11,615},size={300,25},fSize=15,fStyle=1,proc=Magnet_Report,title="Show Magnet Report"
	
	UpdateCompareResultsPanel()
	
EndMacro


Function UpdateCompareResultsPanel()

	string PanelName
	PanelName = WinList("Compare_Results",";","")	
	if (stringmatch(PanelName, "Compare_Results;")==0)
		return -1
	endif

	UpdateFieldMapDirs()
	UpdateFieldMapNames()

	NVAR FieldMapCount = root:varsCAMTO:FieldMapCount

	SVAR dfA = root:varsCAMTO:FieldMapA
	SVAR dfB = root:varsCAMTO:FieldMapB
	
	if (FieldMapCount != 0)
		string FieldMapList = getFieldmapDirs()
		
		if (DataFolderExists("root:Nominal"))
			FieldMapList = "Nominal;" + FieldMapList
		endif
		
		PopupMenu FieldMapDirA,win=Compare_Results,disable=0,value= #("\"" + FieldMapList + "\"")
		PopupMenu FieldMapDirB,win=Compare_Results,disable=0,value= #("\"" + FieldMapList + "\"")
		
		variable modeA, modeB
		modeA = WhichListItem(dfA, FieldMapList) 
		modeB = WhichListItem(dfB, FieldMapList) 
		
		if (modeA != -1)
			PopupMenu FieldMapDirA,win=Compare_Results,mode=modeA+1
		endif
		
		if (modeB !=-1)
			PopupMenu FieldMapDirB,win=Compare_Results,mode=modeB+1
		endif
		
	else
		PopupMenu FieldMapDirA,win=Compare_Results,disable=2
		PopupMenu FieldMapDirB,win=Compare_Results,disable=2
	endif
	
	if (FieldMapCount != 0 && strlen(dfA) > 0 && cmpstr(dfA, "_none_")!=0 && strlen(dfB) > 0 && cmpstr(dfB, "_none_")!=0)
	
		NVAR ProfileStartX  = root:varsCAMTO:ProfileStartX
		NVAR ProfileEndX    = root:varsCAMTO:ProfileEndX
		NVAR ProfileStartYZ = root:varsCAMTO:ProfilePosYZ
		
		NVAR/Z AddReferenceLines  = root:varsCAMTO:AddReferenceLines
		NVAR CheckDynMultipoles = root:varsCAMTO:CheckDynMultipoles
		NVAR CheckMultTwo       = root:varsCAMTO:CheckMultTwo
	
		NVAR StartX_A  = root:$(dfA):varsFieldMap:StartX
		NVAR EndX_A    = root:$(dfA):varsFieldMap:EndX
		NVAR StepsX_A  = root:$(dfA):varsFieldMap:StepsX
		NVAR StartYZ_A = root:$(dfA):varsFieldMap:StartYZ
		NVAR EndYZ_A   = root:$(dfA):varsFieldMap:EndYZ
		NVAR StepsYZ_A = root:$(dfA):varsFieldMap:StepsYZ
	
		NVAR StartX_B  = root:$(dfB):varsFieldMap:StartX
		NVAR EndX_B    = root:$(dfB):varsFieldMap:EndX
		NVAR StepsX_B  = root:$(dfB):varsFieldMap:StepsX
		NVAR StartYZ_B = root:$(dfB):varsFieldMap:StartYZ
		NVAR EndYZ_B   = root:$(dfB):varsFieldMap:EndYZ
		NVAR StepsYZ_B = root:$(dfB):varsFieldMap:StepsYZ
	
		NVAR FittingOrder_A     = root:$(dfA):varsFieldMap:FittingOrder
		NVAR FittingOrderTraj_A = root:$(dfA):varsFieldMap:FittingOrderTraj	
		NVAR FittingOrder_B     = root:$(dfB):varsFieldMap:FittingOrder
		NVAR FittingOrderTraj_B = root:$(dfB):varsFieldMap:FittingOrderTraj

		
		variable StartX, EndX, StepsX
		variable StartYZ, EndYZ, StepsYZ
		variable FittingOrder, FittingOrderTraj
	
		if ( numtype(Max(StartX_A, StartX_B))!= 0 )
			if (numtype(StartX_B) != 0)
				StartX  = StartX_A; EndX = EndX_A; StepsX = StepsX_A
				StartYZ = StartYZ_A; EndYZ = EndYZ_A; StepsYZ = StepsYZ_A
			else
				StartX  = StartX_B; EndX = EndX_B; StepsX = StepsX_B
				StartYZ = StartYZ_B; EndYZ = EndYZ_B; StepsYZ = StepsYZ_B	
			endif
		else
			StartX  = Max(StartX_A, StartX_B)
			EndX    = Min(EndX_A, EndX_B)
			StepsX  = Min(StepsX_A, StepsX_B)
			StartYZ = Max(StartYZ_A, StartYZ_B)
			EndYZ   = Min(EndYZ_A, EndYZ_B)
			StepsYZ = Min(StepsYZ_A, StepsYZ_B)
		endif
				
		SetVariable StartXProfile,win=Compare_Results, limits={StartX,  EndX,  StepsX}
		SetVariable EndXProfile,  win=Compare_Results, limits={StartX,  EndX,  StepsX}
		SetVariable PosYZProfile, win=Compare_Results, limits={StartYZ, EndYZ, StepsYZ} 
		
		CheckBox ReferenceA,win=Compare_Results, disable=0
		CheckBox ReferenceB,win=Compare_Results, disable=0
				
		ProfileStartX  = StartX
		ProfileEndX    = EndX	 
		ProfileStartYZ = 0	 
		
		ValDisplay trajstartx_A,win=Compare_Results,value= #("root:"+ dfA + ":varsFieldMap:StartXTraj" )
		ValDisplay trajstartangx_A,win=Compare_Results,value= #("root:"+ dfA + ":varsFieldMap:EntranceAngle" )
		ValDisplay trajstartyz_A,win=Compare_Results,value= #("root:"+ dfA + ":varsFieldMap:StartYZTraj" )

		ValDisplay trajstartx_B,win=Compare_Results,value= #("root:"+ dfB + ":varsFieldMap:StartXTraj" )
		ValDisplay trajstartangx_B,win=Compare_Results,value= #("root:"+ dfB + ":varsFieldMap:EntranceAngle" )
		ValDisplay trajstartyz_B,win=Compare_Results,value= #("root:"+ dfB + ":varsFieldMap:StartYZTraj" )
		
		if (NVAR_EXists(AddReferenceLines)==0)
			variable/G :varsFieldMap:AddReferenceLines = 0
		endif
		
		CheckBox reference_lines,win=Compare_Results,variable=AddReferenceLines, value=AddReferenceLines
		CheckBox rep_dynmult,win=Compare_Results,variable=CheckDynMultipoles, value=CheckDynMultipoles
		CheckBox rep_multtwo,win=Compare_Results,variable=CheckMultTwo, value=CheckMultTwo
		
		if (numtype(Min(FittingOrder_A, FittingOrder_B))!= 0 )
			if (numtype(FittingOrder_B) != 0)
				FittingOrderTraj = FittingOrderTraj_A
				FittingOrder = FittingOrder_A
			else
				FittingOrderTraj = FittingOrderTraj_B
				FittingOrder = FittingOrder_B	
			endif
		else
			FittingOrderTraj = Min(FittingOrderTraj_A, FittingOrderTraj_B)
			FittingOrder = Min(FittingOrder_A, FittingOrder_B)
		endif
		SetVariable mnumber,win=Compare_Results,limits={0,(FittingOrder-1),1}
		SetVariable dynmnumber,win=Compare_Results,limits={0,(FittingOrderTraj-1),1}
		
	else
		
		CheckBox ReferenceA,win=Compare_Results, disable=2
		CheckBox ReferenceB,win=Compare_Results, disable=2
			
	endif	
	
	UpdateFieldControls()
	UpdateMultipolesControls()
	UpdateTrajectoryControls()
	UpdateDynMultipolesControls()
	UpdateMagnetReportControls()

End


Function UpdateFieldControls()

	SVAR dfA = root:varsCAMTO:FieldMapA
	SVAR dfB = root:varsCAMTO:FieldMapB

	Wave/Z PosA = root:$(dfA):C_PosX
	Wave/Z PosB = root:$(dfB):C_PosX
	
	variable disable
	if (WaveExists(PosA) || WaveExists(PosB))
		if (strlen(dfA) > 0 && cmpstr(dfA, "_none_")!=0 && strlen(dfB) > 0 && cmpstr(dfB, "_none_")!=0)
			disable = 0 
		else
			disable = 2
		endif
	else
		disable = 2
	endif

	Button field_Xline, win=Compare_Results, disable=disable
	SetVariable PosXFieldLine, win=Compare_Results, disable=disable

	SetVariable StartXProfile, win=Compare_Results, disable=disable
	SetVariable EndXProfile, win=Compare_Results, disable=disable
	SetVariable PosYZProfile, win=Compare_Results, disable=disable
	Button field_profile, win=Compare_Results, disable=disable

End


Function UpdateMultipolesControls()

	SVAR dfA = root:varsCAMTO:FieldMapA
	SVAR dfB = root:varsCAMTO:FieldMapB

	Wave/Z MultA = root:$(dfA):Mult_Grid
	Wave/Z MultB = root:$(dfB):Mult_Grid
		
	variable disable
	if (WaveExists(MultA) || WaveExists(MultB))
		if (strlen(dfA) > 0 && cmpstr(dfA, "_none_")!=0 && strlen(dfB) > 0 && cmpstr(dfB, "_none_")!=0)
			disable = 0 
		else
			disable = 2
		endif
	else
		disable = 2
	endif

	TitleBox multipoles_title,win=Compare_Results, disable=disable
	Button show_multipoles,win=Compare_Results, disable=disable
	Button show_multipoleprofile,win=Compare_Results, disable=disable
	SetVariable mnumber,win=Compare_Results, disable=disable
	Button show_resfield,win=Compare_Results, disable=disable
End


Function UpdateTrajectoryControls()

	SVAR dfA = root:varsCAMTO:FieldMapA
	SVAR dfB = root:varsCAMTO:FieldMapB

	NVAR/Z StartXTraj_A = root:$(dfA):varsFieldMap:StartXTraj	
	NVAR/Z StartXTraj_B = root:$(dfB):varsFieldMap:StartXTraj	
	Wave/Z TrajA = root:$(dfA):$("TrajX" + num2str(StartXTraj_A/1000))
	Wave/Z TrajB = root:$(dfB):$("TrajX" + num2str(StartXTraj_B/1000))
		
	variable disable
	if (WaveExists(TrajA) || WaveExists(TrajB))
		if (strlen(dfA) > 0 && cmpstr(dfA, "_none_")!=0 && strlen(dfB) > 0 && cmpstr(dfB, "_none_")!=0)
			disable = 0 
		else
			disable = 2
		endif
	else
		disable = 2
	endif

	TitleBox trajectory_title,win=Compare_Results, disable=disable
	
	TitleBox trajA_title,win=Compare_Results, disable=disable
	ValDisplay trajstartx_A,win=Compare_Results, disable=disable
	ValDisplay trajstartangx_A,win=Compare_Results, disable=disable
	ValDisplay trajstartyz_A,win=Compare_Results, disable=disable

	TitleBox trajB_title,win=Compare_Results, disable=disable
	ValDisplay trajstartx_B,win=Compare_Results, disable=disable
	ValDisplay trajstartangx_B,win=Compare_Results, disable=disable
	ValDisplay trajstartyz_B,win=Compare_Results, disable=disable
	
	Button show_trajectories,win=Compare_Results, disable=disable
	CheckBox reference_lines,win=Compare_Results, disable=disable
	
End


Function UpdateDynMultipolesControls()

	SVAR dfA = root:varsCAMTO:FieldMapA
	SVAR dfB = root:varsCAMTO:FieldMapB

	Wave/Z DynMultA = root:$(dfA):Dyn_Mult_Grid
	Wave/Z DynMultB = root:$(dfB):Dyn_Mult_Grid
		
	variable disable
	if (WaveExists(DynMultA) || WaveExists(DynMultB))
		if (strlen(dfA) > 0 && cmpstr(dfA, "_none_")!=0 && strlen(dfB) > 0 && cmpstr(dfB, "_none_")!=0)
			disable = 0 
		else
			disable = 2
		endif
	else
		disable = 2
	endif

	Button show_dynmultipoles,win=Compare_Results, disable=disable
	Button show_dynmultipoleprofile,win=Compare_Results, disable=disable
	SetVariable dynmnumber,win=Compare_Results, disable=disable
	Button show_dynresfield,win=Compare_Results, disable=disable
	
End


Function UpdateMagnetReportControls()

	SVAR dfA = root:varsCAMTO:FieldMapA
	SVAR dfB = root:varsCAMTO:FieldMapB

	NVAR DynMultipoles = root:varsCAMTO:CheckDynMultipoles

	Wave/Z MultA = root:$(dfA):Mult_Grid
	Wave/Z MultB = root:$(dfB):Mult_Grid
	Wave/Z DynMultA = root:$(dfA):Dyn_Mult_Grid
	Wave/Z DynMultB = root:$(dfB):Dyn_Mult_Grid
		
	variable disable
	if (WaveExists(MultA) || WaveExists(MultB) || WaveExists(DynMultA) || WaveExists(DynMultB))
		
		if (strlen(dfA) > 0 && cmpstr(dfA, "_none_")!=0 && strlen(dfB) > 0 && cmpstr(dfB, "_none_")!=0)
			disable = 0 
		
			if (WaveExists(MultA) == 0 && WaveExists(MultB) == 0)
				DynMultipoles = 1
			elseif (WaveExists(DynMultA) == 0 && WaveExists(DynMultB) == 0)
				DynMultipoles = 0
			endif
		
		else
			disable = 2
		endif
				
	else
		disable = 2
	endif
	
	TitleBox rep_title,win=Compare_Results, disable=disable
	CheckBox rep_dynmult,win=Compare_Results, disable=disable
	CheckBox rep_multtwo,win=Compare_Results, disable=disable
	Button rep_button,win=Compare_Results, disable=disable

End


Function SelectFieldMapA(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	SVAR FieldMapA= root:varsCAMTO:FieldMapA
	NVAR ReferenceFieldMap = root:varsCAMTO:ReferenceFieldMap
	
	FieldMapA = popStr
	PopupMenu FieldMapDirA, win=Compare_Results, mode=popNum
	UpdateCompareResultsPanel()

	if (cmpstr(FieldMapA, "Nominal")==0 )
		ReferenceFieldMap = 1
		CheckBox ReferenceA,win=Compare_Results,value=1
		CheckBox ReferenceB,win=Compare_Results,value=0
	endif

End


Function SelectFieldMapB(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	SVAR FieldMapB = root:varsCAMTO:FieldMapB
	NVAR ReferenceFieldMap = root:varsCAMTO:ReferenceFieldMap
	
	FieldMapB = popStr
	PopupMenu FieldMapDirB, win=Compare_Results, mode=popNum
	UpdateCompareResultsPanel()

	if (cmpstr(FieldMapB, "Nominal")==0)
		ReferenceFieldMap = 2
		CheckBox ReferenceA,win=Compare_Results,value=0
		CheckBox ReferenceB,win=Compare_Results,value=1
	endif

End


Function SelectReference(cb) : CheckBoxControl
	STRUCT WMCheckboxAction& cb
	
	SVAR FieldMapA = root:varsCAMTO:FieldMapA
	SVAR FieldMapB = root:varsCAMTO:FieldMapB
	NVAR ReferenceFieldMap = root:varsCAMTO:ReferenceFieldMap
	
	strswitch (cb.ctrlName)
		case "ReferenceA":
			CheckBox ReferenceB,win=Compare_Results,value=0
			ReferenceFieldMap = 1 
			break
		case "ReferenceB":
			CheckBox ReferenceA,win=Compare_Results, value=0
			ReferenceFieldMap = 2
			break
	endswitch
	
	if (cmpstr(FieldMapA, "Nominal")==0 )
		ReferenceFieldMap = 1
		CheckBox ReferenceA,win=Compare_Results,value=1
		CheckBox ReferenceB,win=Compare_Results,value=0
	endif
	
	if (cmpstr(FieldMapB, "Nominal")==0)
		ReferenceFieldMap = 2
		CheckBox ReferenceA,win=Compare_Results,value=0
		CheckBox ReferenceB,win=Compare_Results,value=1
	endif
	
	return 0
End


Function UpdateFieldMapNames()

	DFREF   df = GetDataFolderDFR()
	SVAR    FieldMapA = root:varsCAMTO:FieldMapA
	SVAR    FieldMapB = root:varsCAMTO:FieldMapB

	SetDataFolder root:
	string datafolders = DataFolderDir(1)
	SetDataFolder df
	
	SplitString/E=":.*;" datafolders
	S_value = S_value[1,strlen(S_value)-2]
	
	if (FindListItem(FieldMapA, S_value, ",") == -1 )
		FieldMapA = ""
	endif
	
	if (FindListItem(FieldMapB, S_value, ",") == -1 )
		FieldMapB = ""
	endif
End


Function Compare_Field_In_Line(ctrlName) : ButtonControl
	String ctrlName
	Compare_Field_In_Line_()
End


Function Compare_Field_In_Line_([PosX, FieldComponent])
	variable PosX
	string FieldComponent

	DFREF df = GetDataFolderDFR()
	SVAR dfA = root:varsCAMTO:FieldMapA
	SVAR dfB = root:varsCAMTO:FieldMapB
	
	variable fieldmapA = 1	
	if (cmpstr(dfA, "Nominal")==0)
		fieldmapA = 0
	endif
	
	variable fieldmapB = 1	
	if (cmpstr(dfB, "Nominal")==0)
		fieldmapB = 0
	endif
	
	if (fieldmapA == 0 && fieldmapB == 0)
		return -1
	endif
		
	variable i
	
	NVAR LinePosX = root:varsCAMTO:LinePosX	

	if (ParamIsDefault(PosX))
		PosX = LinePosX
	endif
		
	if (ParamIsDefault(FieldComponent))
		FieldComponent = ""
	endif	

	if (fieldmapA)
		
		SetDataFolder root:wavesCAMTO:
	
		NVAR StartYZ_A = root:$(dfA):varsFieldMap:StartYZ
		NVAR EndYZ_A   = root:$(dfA):varsFieldMap:EndYZ
		NVAR StepsYZ_A = root:$(dfA):varsFieldMap:StepsYZ
		
		NVAR FieldX_A = root:$(dfA):varsFieldMap:FieldX
		NVAR FieldY_A = root:$(dfA):varsFieldMap:FieldY
		NVAR FieldZ_A = root:$(dfA):varsFieldMap:FieldZ	
		
		variable NpointsYZ_A = ((EndYZ_A - StartYZ_A) / StepsYZ_A) +1
		
		Make/D/O/N=(NpointsYZ_A) LinePosYZ_A
		Make/D/O/N=(NpointsYZ_A) LineFieldX_A
		Make/D/O/N=(NpointsYZ_A) LineFieldY_A
		Make/D/O/N=(NpointsYZ_A) LineFieldZ_A
		
		SetDataFolder root:$(dfA)
		for (i=0;i<NpointsYZ_A;i=i+1)
			LinePosYZ_A[i] = ((StartYZ_A +i*StepsYZ_A)/1000)
			
			Campo_Espaco((PosX/1000), LinePosYZ_A[i])
			
			LineFieldX_A[i] = FieldX_A
			LineFieldY_A[i] = FieldY_A
			LineFieldZ_A[i] = FieldZ_A			
		endfor
					
	endif
	
	if (fieldmapB)
		
		SetDataFolder root:wavesCAMTO:
	
		NVAR StartYZ_B = root:$(dfB):varsFieldMap:StartYZ
		NVAR EndYZ_B   = root:$(dfB):varsFieldMap:EndYZ
		NVAR StepsYZ_B = root:$(dfB):varsFieldMap:StepsYZ	
	
		NVAR FieldX_B = root:$(dfB):varsFieldMap:FieldX
		NVAR FieldY_B = root:$(dfB):varsFieldMap:FieldY
		NVAR FieldZ_B = root:$(dfB):varsFieldMap:FieldZ
		
		variable NpointsYZ_B = ((EndYZ_B - StartYZ_B) / StepsYZ_B) +1
		
		Make/D/O/N=(NpointsYZ_B) LinePosYZ_B
		Make/D/O/N=(NpointsYZ_B) LineFieldX_B
		Make/D/O/N=(NpointsYZ_B) LineFieldY_B
		Make/D/O/N=(NpointsYZ_B) LineFieldZ_B
		
		SetDataFolder root:$(dfB)
		for (i=0;i<NpointsYZ_B;i=i+1)
			LinePosYZ_B[i] = ((StartYZ_B +i*StepsYZ_B)/1000)
			
			Campo_Espaco((PosX/1000), LinePosYZ_B[i])
			
			LineFieldX_B[i] = FieldX_B
			LineFieldY_B[i] = FieldY_B
			LineFieldZ_B[i] = FieldZ_B				
		endfor
		
	endif
		
	SetDataFolder df
		
	String strpos = "PosX = "+	num2str(PosX/1000) + " m"
	string PanelName
	
	PanelName = WinList("CompareFieldInLine_Bx",";","")	
	if (stringmatch(PanelName, "CompareFieldInLine_Bx;"))
		KillWindow CompareFieldInLine_Bx
	endif
	
	PanelName = WinList("CompareFieldInLine_By",";","")	
	if (stringmatch(PanelName, "CompareFieldInLine_By;"))
		KillWindow CompareFieldInLine_By
	endif
	
	PanelName = WinList("CompareFieldInLine_Bz",";","")	
	if (stringmatch(PanelName, "CompareFieldInLine_Bz;"))
		KillWindow CompareFieldInLine_Bz
	endif
	
	if (cmpstr(FieldComponent, "Bx") == 0 || strlen(FieldComponent) == 0)
		
		if (fieldmapA && fieldmapB)
			Display/N=CompareFieldInLine_Bx/K=1 LineFieldX_A vs LinePosYZ_A
			AppendToGraph/W=CompareFieldInLine_Bx/C=(0,0,65535) LineFieldX_B vs LinePosYZ_B
			Legend/W=CompareFieldInLine_Bx "\s(#0) "+ dfA +  "\r\s(#1) " + dfB 
		elseif (fieldmapA)
			Display/N=CompareFieldInLine_Bx/K=1 LineFieldX_A vs LinePosYZ_A
			Legend/W=CompareFieldInLine_Bx "\s(#0) "+ dfA
		elseif (fieldmapB)
			Display/N=CompareFieldInLine_Bx/K=1 LineFieldX_B vs LinePosYZ_B
			Legend/W=CompareFieldInLine_Bx "\s(#0) "+ dfB
		endif
		
		Label bottom "\\Z12Longitudinal Position YZ [m]"
		Label left "\\Z12Field Bx [T] (" + strpos + ")"
	endif
	
	if (cmpstr(FieldComponent, "By") == 0 || strlen(FieldComponent) == 0)
		
		if (fieldmapA && fieldmapB)
			Display/N=CompareFieldInLine_By/K=1 LineFieldY_A vs LinePosYZ_A
			AppendToGraph/W=CompareFieldInLine_By/C=(0,0,65535) LineFieldY_B vs LinePosYZ_B
			Legend/W=CompareFieldInLine_By "\s(#0) "+ dfA + "\r\s(#1) " + dfB 
		elseif (fieldmapA)
			Display/N=CompareFieldInLine_By/K=1 LineFieldY_A vs LinePosYZ_A
			Legend/W=CompareFieldInLine_By "\s(#0) "+ dfA
		elseif (fieldmapB)
			Display/N=CompareFieldInLine_By/K=1 LineFieldY_B vs LinePosYZ_B
			Legend/W=CompareFieldInLine_By "\s(#0) "+ dfB
		endif
		
		Label bottom "\\Z12Longitudinal Position YZ [m]"
		Label left "\\Z12Field By [T] (" + strpos + ")"
	endif

	if (cmpstr(FieldComponent, "Bz") == 0 || strlen(FieldComponent) == 0)
		
		if (fieldmapA && fieldmapB)	
			Display/N=CompareFieldInLine_Bz/K=1 LineFieldZ_A vs LinePosYZ_A
			AppendToGraph/W=CompareFieldInLine_Bz/C=(0,0,65535) LineFieldZ_B vs LinePosYZ_B
			Legend/W=CompareFieldInLine_Bz "\s(#0) "+ dfA + "\r\s(#1) " + dfB 
		elseif (fieldmapA)
			Display/N=CompareFieldInLine_Bz/K=1 LineFieldZ_A vs LinePosYZ_A
			Legend/W=CompareFieldInLine_Bz "\s(#0) "+ dfA
		elseif (fieldmapB)
			Display/N=CompareFieldInLine_Bz/K=1 LineFieldZ_B vs LinePosYZ_B
			Legend/W=CompareFieldInLine_Bz "\s(#0) "+ dfB
		endif
		
		Label bottom "\\Z12Longitudinal Position YZ [m]"
		Label left "\\Z12Field Bz [T] (" + strpos + ")"
	endif
		
End


Function Compare_Field_Profile(ctrlName) : ButtonControl
	String ctrlName
	Compare_Field_Profile_()
End


Function Compare_Field_Profile_([PosYZ, FieldComponent])
	variable PosYZ
	string FieldComponent
	
	NVAR ProfileStartX = root:varsCAMTO:ProfileStartX
	NVAR ProfileEndX   = root:varsCAMTO:ProfileEndX	
	NVAR ProfilePosYZ  = root:varsCAMTO:ProfilePosYZ	

	DFREF df = GetDataFolderDFR()
	SVAR dfA = root:varsCAMTO:FieldMapA
	SVAR dfB = root:varsCAMTO:FieldMapB

	variable fieldmapA = 1	
	if (cmpstr(dfA, "Nominal")==0)
		fieldmapA = 0
	endif
	
	variable fieldmapB = 1	
	if (cmpstr(dfB, "Nominal")==0)
		fieldmapB = 0
	endif
	
	if (fieldmapA == 0 && fieldmapB == 0)
		return -1
	endif
	
	SetDataFolder root:wavesCAMTO:

	if (ParamIsDefault(PosYZ))
		PosYZ = ProfilePosYZ
	endif 	
	
	if (ParamIsDefault(FieldComponent))
		FieldComponent = ""
	endif

	variable i
	
	if (fieldmapA)
		NVAR StepsX_A = root:$(dfA):varsFieldMap:StepsX
		NVAR FieldX_A = root:$(dfA):varsFieldMap:FieldX
		NVAR FieldY_A = root:$(dfA):varsFieldMap:FieldY
		NVAR FieldZ_A = root:$(dfA):varsFieldMap:FieldZ
		
		variable NpointsX_A = ((ProfileEndX - ProfileStartX) / StepsX_A) +1
		
		Make/D/O/N=(NpointsX_A) ProfilePosX_A
		Make/D/O/N=(NpointsX_A) ProfileFieldX_A
		Make/D/O/N=(NpointsX_A) ProfileFieldY_A
		Make/D/O/N=(NpointsX_A) ProfileFieldZ_A
		
		SetDataFolder root:$(dfA)
		for (i=0;i<NpointsX_A;i=i+1)
			ProfilePosX_A[i] = ((ProfileStartX +i*StepsX_A)/1000)
			
			Campo_Espaco(ProfilePosX_A[i],(PosYZ/1000))
			
			ProfileFieldX_A[i] = FieldX_A
			ProfileFieldY_A[i] = FieldY_A
			ProfileFieldZ_A[i] = FieldZ_A			
		endfor
		
		
	endif

	if (fieldmapB)
		NVAR StepsX_B = root:$(dfB):varsFieldMap:StepsX	
		NVAR FieldX_B = root:$(dfB):varsFieldMap:FieldX
		NVAR FieldY_B = root:$(dfB):varsFieldMap:FieldY
		NVAR FieldZ_B = root:$(dfB):varsFieldMap:FieldZ

		variable NpointsX_B = ((ProfileEndX - ProfileStartX) / StepsX_B) +1
	
		Make/D/O/N=(NpointsX_B) ProfilePosX_B
		Make/D/O/N=(NpointsX_B) ProfileFieldX_B
		Make/D/O/N=(NpointsX_B) ProfileFieldY_B
		Make/D/O/N=(NpointsX_B) ProfileFieldZ_B
	
		SetDataFolder root:$(dfB)
		for (i=0;i<NpointsX_B;i=i+1)
			ProfilePosX_B[i] = ((ProfileStartX +i*StepsX_B)/1000)
			
			Campo_Espaco(ProfilePosX_B[i],(PosYZ/1000))
			
			ProfileFieldX_B[i] = FieldX_B
			ProfileFieldY_B[i] = FieldY_B
			ProfileFieldZ_B[i] = FieldZ_B				
		endfor
	
	endif
			
	SetDataFolder df
		
	String strpos = "PosYZ = "+	num2str(PosYZ/1000) + " m"
	string PanelName

	PanelName = WinList("CompareFieldProfile_Bx",";","")	
	if (stringmatch(PanelName, "CompareFieldProfile_Bx;"))
		KillWindow CompareFieldProfile_Bx
	endif

	PanelName = WinList("CompareFieldProfile_By",";","")	
	if (stringmatch(PanelName, "CompareFieldProfile_By;"))
		KillWindow CompareFieldProfile_By
	endif

	PanelName = WinList("CompareFieldProfile_Bz",";","")	
	if (stringmatch(PanelName, "CompareFieldProfile_Bz;"))
		KillWindow CompareFieldProfile_Bz
	endif
	
	if (cmpstr(FieldComponent, "Bx") == 0 || strlen(FieldComponent) == 0)
		
		if (fieldmapA && fieldmapB)	
			Display/N=CompareFieldProfile_Bx/K=1 ProfileFieldX_A vs ProfilePosX_A
			AppendToGraph/W=CompareFieldProfile_Bx/C=(0,0,65535) ProfileFieldX_B vs ProfilePosX_B
			Legend/W=CompareFieldProfile_Bx "\s(#0) "+ dfA + "\r\s(#1) " + dfB
		elseif (fieldmapA)
			Display/N=CompareFieldProfile_Bx/K=1 ProfileFieldX_A vs ProfilePosX_A
			Legend/W=CompareFieldProfile_Bx "\s(#0) "+ dfA
		elseif (fieldmapB)
			Display/N=CompareFieldProfile_Bx/K=1 ProfileFieldX_B vs ProfilePosX_B
			Legend/W=CompareFieldProfile_Bx "\s(#0) "+ dfB
		endif	
			
		Label bottom "\\Z12Transversal Position X [m]"
		Label left "\\Z12Field Bx [T] (" + strpos + ")"
	endif
	
	if (cmpstr(FieldComponent, "By") == 0 || strlen(FieldComponent) == 0)
	
		if (fieldmapA && fieldmapB)	
			Display/N=CompareFieldProfile_By/K=1 ProfileFieldY_A vs ProfilePosX_A
			AppendToGraph/W=CompareFieldProfile_By/C=(0,0,65535) ProfileFieldY_B vs ProfilePosX_B
			Legend/W=CompareFieldProfile_By "\s(#0) "+ dfA + "\r\s(#1) " + dfB 
		elseif (fieldmapA)
			Display/N=CompareFieldProfile_By/K=1 ProfileFieldY_A vs ProfilePosX_A
			Legend/W=CompareFieldProfile_By "\s(#0) "+ dfA
		elseif (fieldmapB)
			Display/N=CompareFieldProfile_By/K=1 ProfileFieldY_B vs ProfilePosX_B
			Legend/W=CompareFieldProfile_By "\s(#0) "+ dfB
		endif
		
		Label bottom "\\Z12Transversal Position X [m]"
		Label left "\\Z12Field By [T] (" + strpos + ")"
	endif

	if (cmpstr(FieldComponent, "Bz") == 0 || strlen(FieldComponent) == 0)
	
		if (fieldmapA && fieldmapB)	
			Display/N=CompareFieldProfile_Bz/K=1 ProfileFieldZ_A vs ProfilePosX_A
			AppendToGraph/W=CompareFieldProfile_Bz/C=(0,0,65535) ProfileFieldZ_B vs ProfilePosX_B
			Legend/W=CompareFieldProfile_Bz "\s(#0) "+ dfA + "\r\s(#1) " + dfB
		elseif (fieldmapA)
			Display/N=CompareFieldProfile_Bz/K=1 ProfileFieldZ_A vs ProfilePosX_A
			Legend/W=CompareFieldProfile_Bz "\s(#0) "+ dfA
		elseif (fieldmapB)
			Display/N=CompareFieldProfile_Bz/K=1 ProfileFieldZ_B vs ProfilePosX_B
			Legend/W=CompareFieldProfile_Bz "\s(#0) "+ dfB
		endif
		
		Label bottom "\\Z12Transversal Position X [m]"
		Label left "\\Z12Field Bz [T] (" + strpos + ")"
	endif
		
		
End


Function Compare_Multipoles(ctrlName) : ButtonControl
	String ctrlName
	Compare_Multipoles_(0)	
End


Function Compare_DynMultipoles(ctrlName) : ButtonControl
	String ctrlName
	Compare_Multipoles_(1)
End


Function Compare_Multipoles_(Dynamic)
	variable Dynamic
	
	SVAR dfA = root:varsCAMTO:FieldMapA
	SVAR dfB = root:varsCAMTO:FieldMapB

	variable fieldmapA = 1	
	if (cmpstr(dfA, "Nominal")==0)
		fieldmapA = 0
	endif
	
	variable fieldmapB = 1	
	if (cmpstr(dfB, "Nominal")==0)
		fieldmapB = 0
	endif
	
	if (fieldmapA == 0 && fieldmapB == 0)
		return -1
	endif

	string mult
	string str
	
	if (Dynamic)
		mult = "Dyn_Mult"
	else
		mult = "Mult"
	endif

	if (fieldmapA)
		str = "root:" + dfA + ":" + mult 
		Edit/N=$(dfA)/K=1 $(str +"_Normal_Int"), $(str +"_Skew_Int"), $(str +"_Normal_Norm"), $(str +"_Skew_Norm")
		if (Dynamic)
			DoWindow/T $(dfA),"Dynamic Field Multipoles - " + dfA
		else
			DoWindow/T $(dfA),"Field Multipoles - " + dfA
		endif
	endif

	if (fieldmapB)
		str = "root:" + dfb + ":" + mult 
		Edit/N=$(dfb)/K=1 $(str +"_Normal_Int"), $(str +"_Skew_Int"), $(str +"_Normal_Norm"), $(str +"_Skew_Norm")
		if (Dynamic)
			DoWindow/T $(dfB),"Dynamic Field Multipoles - " + dfB
		else
			DoWindow/T $(dfB),"Field Multipoles - " + dfB
		endif
	endif

End


Function Compare_Multipole_Profile(ctrlName) : ButtonControl
	String ctrlName
	Compare_Multipole_Profile_(0)
End


Function Compare_DynMultipole_Profile(ctrlName) : ButtonControl
	String ctrlName
	Compare_Multipole_Profile_(1)
End


Function Compare_Multipole_Profile_(Dynamic, [K, FieldComponent])
	variable Dynamic
	variable K
	string FieldComponent
	
	DFREF df = GetDataFolderDFR()
	SVAR dfA = root:varsCAMTO:FieldMapA
	SVAR dfB = root:varsCAMTO:FieldMapB
	
	SetDataFolder root:wavesCAMTO
	
	variable fieldmapA = 1	
	if (cmpstr(dfA, "Nominal")==0)
		fieldmapA = 0
	endif
	
	variable fieldmapB = 1	
	if (cmpstr(dfB, "Nominal")==0)
		fieldmapB = 0
	endif
	
	if (fieldmapA == 0 && fieldmapB == 0)
		return -1
	endif
		
	NVAR MultipoleK		 = root:varsCAMTO:MultipoleK
	NVAR DynMultipoleK	 = root:varsCAMTO:DynMultipoleK
		
	if (ParamIsDefault(K))
		if (Dynamic)
			K = DynMultipoleK
		else
			K = MultipoleK
		endif
	endif

	if (ParamIsDefault(FieldComponent))
		FieldComponent = ""
	endif
	
	string PanelName
	string graphlabel

	string mult_normal
	string mult_skew
	string pos
	string dyn_graphlabel
	string nwindow
	string swindow

	if (Dynamic)
		mult_normal = "Dyn_Mult_Normal"
		mult_skew = "Dyn_Mult_Skew"
		pos = "Dyn_Mult_PosYZ"
		dyn_graphlabel = "\rover trajectory"
		nwindow = "CompareDynMultNormal"
		swindow = "CompareDynMultSkew"
	else
		mult_normal = "Mult_Normal"
		mult_skew = "Mult_Skew"
		pos = "C_PosYZ"
		dyn_graphlabel = ""
		nwindow = "CompareMultNormal"
		swindow = "CompareMultSkew"
	endif
	
	if (K == 0)
		graphlabel = "Dipolar field" + dyn_graphlabel + " [T]"
	elseif (K == 1)
		graphlabel = "Quadrupolar field" + dyn_graphlabel + " [T/m]"
	elseif (K == 2)
		graphlabel = "Sextupolar field" + dyn_graphlabel + " [T/m²]"
	elseif (K == 3)
		graphlabel = "Octupolar field" + dyn_graphlabel + " [T/m³]"
	else
		graphlabel = num2str(2*(K +1))+ "-polar field" + dyn_graphlabel
	endif
	
	SetDataFolder root:wavesCAMTO:
	
	PanelName = WinList(nwindow,";","")	
	if (stringmatch(PanelName, nwindow + ";"))
		KillWindow $(nwindow)
	endif	

	PanelName = WinList(swindow,";","")	
	if (stringmatch(PanelName, swindow + ";"))
		KillWindow $(swindow)
	endif		
	
	if (cmpstr(FieldComponent, "Normal") == 0 || strlen(FieldComponent) == 0)		
	
		if (fieldmapA && fieldmapB)
			Display/N=$(nwindow)/K=1 root:$(dfA):$(mult_normal)[][K] vs root:$(dfA):$(pos)
			AppendToGraph/W=$(nwindow)/C=(0,0,65535) root:$(dfB):$(mult_normal)[][K] vs root:$(dfB):$(pos)
			Legend/W=$(nwindow) "\s(#0) "+ dfA + " \r\s(#1) " + dfB
			
		elseif (fieldmapA)
			Display/N=$(nwindow)/K=1 root:$(dfA):$(mult_normal)[][K] vs root:$(dfA):$(pos)
			Legend/W=$(nwindow) "\s(#0) "+ dfA
		
		elseif (fieldmapB)
			Display/N=$(nwindow)/K=1 root:$(dfB):$(mult_normal)[][K] vs root:$(dfB):$(pos)
			Legend/W=$(nwindow) "\s(#0) "+ dfB		
			
		endif
			
		Label bottom "\\Z12Longitudinal Position YZ [m]"
		Label left  "\\Z12Normal " + graphlabel
	endif

	if (cmpstr(FieldComponent, "Skew") == 0 || strlen(FieldComponent) == 0)

		if (fieldmapA && fieldmapB)			
			Display/N=$(swindow)/K=1 root:$(dfA):$(mult_skew)[][K] vs root:$(dfA):$(pos)
			AppendToGraph/W=$(swindow)/C=(0,0,65535) root:$(dfB):$(mult_skew)[][K] vs root:$(dfB):$(pos)
			Legend/W=$(swindow) "\s(#0) "+ dfA + " \r\s(#1) " + dfB	
			
		elseif (fieldmapA)
			Display/N=$(swindow)/K=1 root:$(dfA):$(mult_skew)[][K] vs root:$(dfA):$(pos)
			Legend/W=$(swindow) "\s(#0) "+ dfA
		
		elseif (fieldmapB)
			Display/N=$(swindow)/K=1 root:$(dfB):$(mult_skew)[][K] vs root:$(dfB):$(pos)
			Legend/W=$(swindow) "\s(#0) "+ dfB
				
		endif
		
		Label bottom "\\Z12Longitudinal Position YZ [m]"
		Label left  "\\Z12Skew " + graphlabel
	endif

	SetDataFolder df
	
End


Function Compare_Trajectories(ctrlName) : ButtonControl
	String ctrlName

	DFREF df = GetDataFolderDFR()
	SVAR dfA = root:varsCAMTO:FieldMapA
	SVAR dfB = root:varsCAMTO:FieldMapB
	NVAR/Z AddReferenceLines = root:varsCAMTO:AddReferenceLines

	if (NVAR_EXists(AddReferenceLines)==0)
		variable/G root:varsCAMTO:AddReferenceLines = 0
	endif

	variable i
	variable xval_A
	variable xval_B
	string TrajStart
	string PanelName
	string AxisY
	string AxisX
	string PosLineName
	string InitLineName
	string FinalLineName
	string tagtext
	string yzstr
	
	variable fieldmapA = 1	
	if (cmpstr(dfA, "Nominal")==0)
		fieldmapA = 0
	endif
	
	variable fieldmapB = 1	
	if (cmpstr(dfB, "Nominal")==0)
		fieldmapB = 0
	endif
	
	if (fieldmapA == 0 && fieldmapB == 0)
		return -1
	endif

	if (fieldmapA)
		NVAR BeamDirection_A = root:$(dfA):varsFieldMap:BeamDirection	
		NVAR StartXTraj_A    = root:$(dfA):varsFieldMap:StartXTraj	
		
		SetDataFolder root:$(dfA)
		TrajStart = num2str(StartXTraj_A/1000)
		
		// FieldMap A - Trajectory X 
		AxisY = "TrajX" + TrajStart
		Wave TmpY = $AxisY

		if (BeamDirection_A == 1)
			AxisX = "TrajY" + TrajStart
		else
			AxisX = "TrajZ" + TrajStart
		endif
		Wave TmpX = $AxisX
		
		PanelName = WinList("CompareTrajectoriesX",";","")	
		if (stringmatch(PanelName, "CompareTrajectoriesX;"))
			KillWindow CompareTrajectoriesX
		endif
		Display/N=CompareTrajectoriesX/K=1 TmpY/TN='TrajX_A' vs TmpX
		Label bottom "\\Z12Longitudinal Position [m]"			
		Label left "\\Z12Horizontal Trajectory [m]"	
	
		if (AddReferenceLines == 1)
			CalcRefLinesCrossingPoint()
			Wave CrossingPointX
			Wave CrossingPointYZ
			
			if (numpnts(CrossingPointX) == 1)
				PosLineName = AxisY + "_PosRefLine"
				InitLineName = AxisY + "_InitRefLine"
				FinalLineName = AxisY + "_FinalRefLine"
				
				Wave/Z PosLine = $(PosLineName)
				Wave/Z InitLine = $(InitLineName)
				Wave/Z FinalLine = $(FinalLineName)
				
				if (WaveExists(PosLine) == 1 && WaveExists(InitLine) == 1 && WaveExists(FinalLine) == 1)
					Appendtograph/W=CompareTrajectoriesX/C=(30000, 30000, 30000) InitLine/TN=$(InitLineName+"_A") vs PosLine
					Appendtograph/W=CompareTrajectoriesX/C=(30000, 30000, 30000) FinalLine/TN=$(FinalLineName+"_A") vs PosLine
					ModifyGraph/W=CompareTrajectoriesX lstyle($(InitLineName+"_A"))=3
					ModifyGraph/W=CompareTrajectoriesX lstyle($(FinalLineName+"_A"))=3 
				endif			
				
				Appendtograph/W=CompareTrajectoriesX/C=(30000, 30000, 30000) CrossingPointX/TN='CrossingPoint_A' vs CrossingPointYZ
				ModifyGraph/W=CompareTrajectoriesX mode('CrossingPoint_A')=3, marker('CrossingPoint_A')=19, msize('CrossingPoint_A')=2
				
				xval_A = pnt2x(CrossingPointYZ, 0)
				if (BeamDirection_A == 1)
					yzstr = "Y"
				else
					yzstr = "Z"
				endif
				sprintf tagtext, "%s:\nX = %.3f mm\n%s = %.3f mm", dfA, CrossingPointX[i]*1000, yzstr, CrossingPointYZ[i]*1000
				Tag/X=20/W=CompareTrajectoriesX/F=2/L=2 'CrossingPoint_A', xval_A, tagtext
			endif
			
		endif
	
		// FieldMap A - Trajectory YZ
		AxisY = "TrajX" + TrajStart
		Wave TmpY = $AxisY
	
		if (BeamDirection_A == 1)
			AxisY = "TrajZ" + TrajStart
			AxisX = "TrajY" + TrajStart
		else
			AxisY = "TrajY" + TrajStart		
			AxisX = "TrajZ" + TrajStart			
		endif
		Wave TmpY = $AxisY
		Wave TmpX = $AxisX
		
		PanelName = WinList("CompareTrajectoriesYZ",";","")	
		if (stringmatch(PanelName, "CompareTrajectoriesYZ;"))
			KillWindow CompareTrajectoriesYZ
		endif
		Display/N=CompareTrajectoriesYZ/K=1 TmpY/TN='TrajYZ_A' vs TmpX
		Label bottom "\\Z12Longitudinal Position [m]"			
		Label left "\\Z12Vertical Trajectory [m]"
				
	endif
	
	if (fieldmapB)
		NVAR BeamDirection_B = root:$(dfB):varsFieldMap:BeamDirection	
		NVAR StartXTraj_B    = root:$(dfB):varsFieldMap:StartXTraj	
		
		SetDataFolder root:$(dfB)
		TrajStart = num2str(StartXTraj_B/1000)
				
		// FieldMap B - Trajectory X 
		AxisY = "TrajX" + TrajStart
		Wave TmpY = $AxisY
	
		if (BeamDirection_B == 1)
			AxisX = "TrajY" + TrajStart
		else
			AxisX = "TrajZ" + TrajStart
		endif
		Wave TmpX = $AxisX
		
		PanelName = WinList("CompareTrajectoriesX",";","")	
		if (stringmatch(PanelName, "CompareTrajectoriesX;"))
			AppendToGraph/W=CompareTrajectoriesX/C=(0,0,65535) TmpY/TN='TrajX_B' vs TmpX	
		else
			Display/N=CompareTrajectoriesX/K=1 TmpY/TN='TrajX_B' vs TmpX
			Label bottom "\\Z12Longitudinal Position [m]"			
			Label left "\\Z12Horizontal Trajectory [m]"	
		endif

		if (AddReferenceLines == 1)
			CalcRefLinesCrossingPoint()
			Wave CrossingPointX
			Wave CrossingPointYZ
			
			if (numpnts(CrossingPointX) == 1)		
				PosLineName = AxisY + "_PosRefLine"
				InitLineName = AxisY + "_InitRefLine"
				FinalLineName = AxisY + "_FinalRefLine"
				
				Wave/Z PosLine = $(PosLineName)
				Wave/Z InitLine = $(InitLineName)
				Wave/Z FinalLine = $(FinalLineName)
				
				if (WaveExists(PosLine) == 1 && WaveExists(InitLine) == 1 && WaveExists(FinalLine) == 1)
					Appendtograph/W=CompareTrajectoriesX/C=(30000, 30000, 30000) InitLine/TN=$(InitLineName+"_B") vs PosLine
					Appendtograph/W=CompareTrajectoriesX/C=(30000, 30000, 30000) FinalLine/TN=$(FinalLineName+"_B") vs PosLine
					ModifyGraph/W=CompareTrajectoriesX lstyle($(InitLineName+"_B"))=3
					ModifyGraph/W=CompareTrajectoriesX lstyle($(FinalLineName+"_B"))=3
				endif
				
				Appendtograph/W=CompareTrajectoriesX/C=(30000, 30000, 30000) CrossingPointX/TN='CrossingPoint_B' vs CrossingPointYZ
				ModifyGraph/W=CompareTrajectoriesX mode('CrossingPoint_B')=3, marker('CrossingPoint_B')=19, msize('CrossingPoint_B')=2
				
				xval_B = pnt2x(CrossingPointYZ, 0)
				if (BeamDirection_B == 1)
					yzstr = "Y"
				else
					yzstr = "Z"
				endif
				sprintf tagtext, "%s:\nX = %.3f mm\n%s = %.3f mm", dfB, CrossingPointX[i]*1000, yzstr, CrossingPointYZ[i]*1000
				Tag/X=20/W=CompareTrajectoriesX/F=2/L=2 'CrossingPoint_B', xval_B, tagtext
			endif
			
		endif
		
		// FieldMap B - Trajectory YZ
		AxisY = "TrajX" + TrajStart
		Wave TmpY = $AxisY
	
		if (BeamDirection_B == 1)
			AxisY = "TrajZ" + TrajStart
			AxisX = "TrajY" + TrajStart
		else
			AxisY = "TrajY" + TrajStart		
			AxisX = "TrajZ" + TrajStart			
		endif
		Wave TmpY = $AxisY
		Wave TmpX = $AxisX
		
		PanelName = WinList("CompareTrajectoriesYZ",";","")	
		if (stringmatch(PanelName, "CompareTrajectoriesYZ;"))
			AppendToGraph/W=CompareTrajectoriesYZ/C=(0,0,65535) TmpY/TN='TrajYZ_B' vs TmpX
		else
			Display/N=CompareTrajectoriesYZ/K=1 TmpY/TN='TrajYZ_B' vs TmpX
			Label bottom "\\Z12Longitudinal Position [m]"			
			Label left "\\Z12Vertical Trajectory [m]"
		endif
		
	endif
	
	if (fieldmapA && fieldmapB)
		Legend/W=CompareTrajectoriesX "\s('TrajX_A') "+ dfA + " \r\s('TrajX_B') " + dfB
		Legend/W=CompareTrajectoriesYZ "\s('TrajYZ_A') "+ dfA + " \r\s('TrajYZ_B') " + dfB
	elseif (fieldmapA)	
		Legend/W=CompareTrajectoriesX "\s('TrajX_A') " + dfA
		Legend/W=CompareTrajectoriesYZ "\s('TrajYZ_A') "+ dfA
	elseif (fieldmapB)
		Legend/W=CompareTrajectoriesX "\s('TrajX_B') " + dfB
		Legend/W=CompareTrajectoriesYZ "\s('TrajYZ_B') "+ dfB	
	endif
	
	SetDataFolder df

End


Function Show_Residual_Multipoles(ctrlName) : ButtonControl
	String ctrlName
	Show_Residual_Field(0)
End


Function Show_Residual_Dyn_Multipoles(ctrlName) : ButtonControl
	String ctrlName
	Show_Residual_Field(1)
End


Function Show_Residual_Field(Dynamic)
	variable Dynamic

	DFREF df = GetDataFolderDFR()
	SVAR dfA = root:varsCAMTO:FieldMapA
	SVAR dfB = root:varsCAMTO:FieldMapB
	
	variable fieldmapA = 1	
	if (cmpstr(dfA, "Nominal")==0)
		fieldmapA = 0
	endif
	
	variable fieldmapB = 1	
	if (cmpstr(dfB, "Nominal")==0)
		fieldmapB = 0
	endif
	
	if (fieldmapA ==0 && fieldmapB == 0)
		return -1
	endif

  	string PanelName
  	string GraphLegend
	string mult
	string pos
	
	SetDataFolder root:wavesCAMTO:

	Wave/Z trans_pos_residue
	Wave/Z normal_max_residue
	Wave/Z normal_min_residue
	Wave/Z normal_sys_residue
	Wave/Z skew_max_residue
	Wave/Z skew_min_residue
	Wave/Z skew_sys_residue

	if (Dynamic == 1)
		mult = "Dyn_Mult"
		pos = "Dyn_Mult_Grid"
	else
		mult = "Mult"
		pos = "Mult_Grid"
	endif
	
	if (fieldmapA)
		NVAR BeamDirection_A  = root:$(dfA):varsFieldMap:BeamDirection
		Wave ResMult_Pos_A    = $"root:" + dfA + ":" + pos
		Wave ResMult_Normal_A = $"root:" + dfA + ":" + mult + "_Normal_Res"
		Wave ResMult_Skew_A   = $"root:" + dfA + ":" + mult + "_Skew_Res"		
	endif

	if (fieldmapB)
		NVAR BeamDirection_B  = root:$(dfB):varsFieldMap:BeamDirection
		Wave ResMult_Pos_B    = $"root:" + dfB + ":" + pos
		Wave ResMult_Normal_B = $"root:" + dfB + ":" + mult + "_Normal_Res"
		Wave ResMult_Skew_B   = $"root:" + dfB + ":" + mult + "_Skew_Res"		
	endif
		
	PanelName = WinList("NormalResidualField",";","")	
	if (stringmatch(PanelName, "NormalResidualField;"))
		KillWindow NormalResidualField
	endif
	
	if (fieldmapA && fieldmapB)
		Display/N=NormalResidualField/K=1 ResMult_Normal_A vs ResMult_Pos_A
		AppendToGraph/W=NormalResidualField/C=(0,0,0) ResMult_Normal_B vs ResMult_Pos_B
		GraphLegend = "\s(#0) "+ dfA + " \r\s(#1) " + dfB
	elseif (fieldmapA)
		Display/N=NormalResidualField/K=1 ResMult_Normal_A vs ResMult_Pos_A
		GraphLegend = "\s(#0) "+ dfA 	
	elseif (fieldmapB)
		Display/N=NormalResidualField/K=1 ResMult_Normal_B vs ResMult_Pos_B
		GraphLegend =  "\s(#0) "+ dfB	
	endif
	
	if (WaveExists(trans_pos_residue))
		AppendToGraph/W=NormalResidualField/C=(0,0,65535) normal_min_residue/TN='spec_min' vs trans_pos_residue
		AppendToGraph/W=NormalResidualField/C=(0,35000,0) normal_max_residue/TN='spec_max' vs trans_pos_residue
		ModifyGraph/W=NormalResidualField/Z lStyle('spec_min') = 3, lStyle('spec_max') = 3
		GraphLegend = GraphLegend + "\r\s(spec_min) Inferior Limit \r\s(spec_max) Upper Limit" 
	endif
	
	Label left  "\\Z12Normal Residual Integrated Field"
	Label bottom "\\Z12Transversal Position [m]"	
	Legend/A=MT/W=NormalResidualField GraphLegend
	
	PanelName = WinList("SkewResidualField",";","")	
	if (stringmatch(PanelName, "SkewResidualField;"))
		KillWindow SkewResidualField
	endif
	
	if (fieldmapA && fieldmapB)
		Display/N=SkewResidualField/K=1   ResMult_Skew_A vs ResMult_Pos_A
		AppendToGraph/W=SkewResidualField/C=(0,0,0)   ResMult_Skew_B vs ResMult_Pos_B
		GraphLegend = "\s(#0) "+ dfA + " \r\s(#1) " + dfB
	elseif (fieldmapA)
		Display/N=SkewResidualField/K=1   ResMult_Skew_A vs ResMult_Pos_A
		GraphLegend = "\s(#0) "+ dfA 
	elseif (fieldmapB)
		Display/N=SkewResidualField/K=1   ResMult_Skew_B vs ResMult_Pos_B
		GraphLegend = "\s(#0) "+ dfB 
	endif

	if (WaveExists(trans_pos_residue))
		AppendToGraph/W=SkewResidualField/C=(0,0,65535) skew_min_residue/TN='spec_min' vs trans_pos_residue
		AppendToGraph/W=SkewResidualField/C=(0,35000,0) skew_max_residue/TN='spec_max' vs trans_pos_residue
		ModifyGraph/W=SkewResidualField/Z lStyle('spec_min') = 3, lStyle('spec_max') = 3
		GraphLegend = GraphLegend + "\r\s(spec_min) Inferior Limit \r\s(spec_max) Upper Limit"	
	endif

	Label left  "\\Z12Skew Residual Integrated Field" 		
	Label bottom "\\Z12Transversal Position [m]"
	Legend/A=MT/W=SkewResidualField GraphLegend

	SetDataFolder df

End


Function Magnet_Report(ctrlName) : ButtonControl
	String ctrlName
	
	NVAR DynMultipoles = root:varsCAMTO:CheckDynMultipoles

	DFREF df = GetDataFolderDFR()
	
	SetDataFolder root:wavesCAMTO:
	
	Create_Report()
	
	if (DynMultipoles)
		Add_Deflections()	
	endif
	
	Add_Field_Profile()	
	
	Add_Multipoles_Info(DynMultipoles)
	
	Add_Multipoles_Error_Table()
	Add_Residual_Field_Profile(DynMultipoles)
	
	Add_Parameters(DynMultipoles)
	
	SetDataFolder df
	
End


Function Create_Report()

	SVAR dfA = root:varsCAMTO:FieldMapA
	SVAR dfB = root:varsCAMTO:FieldMapB
	NVAR ReferenceFieldMap = root:varsCAMTO:ReferenceFieldMap
	
	string mag
	if (ReferenceFieldMap == 1)
		mag = dfB
	else
		mag = dfA
	endif
	string Title = mag	

	DoWindow/F Report
	if (V_flag != 0)
		Killwindow/Z Report
	endif
	
	NewNotebook/W=(100,30,570,700)/F=1/N=Report as "Report"
	Notebook Report showRuler=0, userKillMode=1, writeProtect=0
	Notebook Report selection={startOfFile, endOfFile}, text="\r", selection={startOfFile, startOfFile} 

	Notebook Report newRuler=TitleRuler, justification=1, rulerDefaults={"Calibri", 16, 1, (0, 0, 0)}	

	Notebook Report newRuler=TableTitle,tabs={20}, justification=0, rulerDefaults={"Calibri", 14, 1, (0, 0, 0)}
	
	Notebook Report newRuler=Table0		 ,tabs={20, 70, 120, 170, 220, 270, 320, 370},justification=0, rulerDefaults={"Calibri", 12, 0, (0, 0, 0)}
	Notebook Report newRuler=TableHeader0,tabs={20, 70, 120, 170, 220, 270, 320, 370},justification=0, rulerDefaults={"Calibri", 12, 1, (0, 0, 0)}
	
	Notebook Report newRuler=Table1      ,tabs={20, 95, 170, 245, 320, 395},justification=0, rulerDefaults={"Calibri", 12, 0, (0, 0, 0)}
	Notebook Report newRuler=TableHeader1,tabs={20, 95, 170, 245, 320, 395},justification=0, rulerDefaults={"Calibri", 12, 1, (0, 0, 0)}
	
	Notebook Report newRuler=Table2      ,tabs={20, 80, 180, 280, 380},justification=0, rulerDefaults={"Calibri", 12, 0, (0, 0, 0)}
	Notebook Report newRuler=TableHeader2,tabs={20, 80, 180, 280, 380},justification=0, rulerDefaults={"Calibri", 12, 1, (0, 0, 0)}
	
	Notebook Report newRuler=Table3      ,tabs={20, 170, 320},justification=0, rulerDefaults={"Calibri", 12, 0, (0, 0, 0)}
	Notebook Report newRuler=TableHeader3,tabs={20, 170, 320},justification=0, rulerDefaults={"Calibri", 12, 1, (0, 0, 0)}
	
	Notebook Report newRuler=Table4      ,tabs={20, 180, 260, 340},justification=0, rulerDefaults={"Calibri", 12, 0, (0, 0, 0)}
	Notebook Report newRuler=TableHeader4,tabs={20, 180, 260, 340},justification=0, rulerDefaults={"Calibri", 12, 1, (0, 0, 0)}

	Notebook Report newRuler=Table5      ,tabs={20, 80, 200, 340},justification=0, rulerDefaults={"Calibri", 12, 0, (0, 0, 0)}
	Notebook Report newRuler=TableHeader5,tabs={20, 80, 200, 340},justification=0, rulerDefaults={"Calibri", 12, 1, (0, 0, 0)}

	Notebook Report newRuler=Table6      ,tabs={20, 180},justification=0, rulerDefaults={"Calibri", 12, 0, (0, 0, 0)}
	Notebook Report newRuler=TableHeader6,tabs={20, 180},justification=0, rulerDefaults={"Calibri", 12, 1, (0, 0, 0)}

	Notebook Report ruler=TitleRuler, text=Title + "\r\r"
	
End


Function Add_Deflections()

	SVAR dfA = root:varsCAMTO:FieldMapA
	SVAR dfB = root:varsCAMTO:FieldMapB
	NVAR ReferenceFieldMap = root:varsCAMTO:ReferenceFieldMap
	NVAR CheckMultTwo = root:varsCAMTO:CheckMultTwo
	
	if (ReferenceFieldMap == 1)
		Wave Deflection_IntTraj_X  = $("root:" + dfB + ":Deflection_IntTraj_X")
		Wave Deflection_IntTraj_Y  = $("root:" + dfB + ":Deflection_IntTraj_Y")
	else
		Wave Deflection_IntTraj_X  = $("root:" + dfA + ":Deflection_IntTraj_X")
		Wave Deflection_IntTraj_Y  = $("root:" + dfB + ":Deflection_IntTraj_Y")
	endif
	
	variable Deflection_Angle_X
	if (WaveExists(Deflection_IntTraj_X))
		Deflection_Angle_X = Deflection_IntTraj_X[0]
	else
		Deflection_Angle_X = NaN
	endif

	if (Abs(Deflection_Angle_X) < 1e-10)
		Deflection_Angle_X = 0
	endif

	variable Deflection_Angle_Y
	if (WaveExists(Deflection_IntTraj_Y))
		Deflection_Angle_Y = Deflection_IntTraj_Y[0]
	else
		Deflection_Angle_Y = NaN
	endif
	
	if (Abs(Deflection_Angle_Y) < 1e-10)
		Deflection_Angle_Y = 0
	endif
	
	if (CheckMultTwo)
		Deflection_Angle_X = Deflection_Angle_X*2
		Deflection_Angle_Y = Deflection_Angle_Y*2
	endif
	
	Make/O/T TableWave = {num2str(Deflection_Angle_X), num2str(Deflection_Angle_Y)}
	Make/O/T RowWave = {"Horizontal Deflection Angle [°]", "Vertical Deflection Angle     [°]"}
		
	Add_Table(TableWave, RowWave=RowWave, Title="Deflection Angles:", Spacing=4)
			
	Killwaves/Z TableWave, RowWave
		 
End


Function Add_Field_Profile()
	
	Wave NormalMultipoles = root:wavesCAMTO:NormalMultipoles
	Wave SkewMultipoles   = root:wavesCAMTO:SkewMultipoles
	
	string FieldComponent
	
	Notebook Report ruler=TableTitle, text="\tField Profile:\r\r"
	
	if (DimSize(NormalMultipoles, 0))	
		FieldComponent = "By"
		
		Compare_Field_In_Line_(FieldComponent=FieldComponent)
		Notebook Report, text="\t",scaling={110,110},picture={$("CompareFieldInLine_" + FieldComponent),0, 1, 8},text="\r"
		Killwindow/Z $("CompareFieldInLine_" + FieldComponent)

		Compare_Field_Profile_(FieldComponent=FieldComponent)
		Notebook Report, text="\t",scaling={110,110},picture={$("CompareFieldProfile_" + FieldComponent),0, 1, 8},text="\r"
		Killwindow/Z $("CompareFieldProfile_" + FieldComponent)
	endif

	if (DimSize(SkewMultipoles, 0))
		FieldComponent = "Bx"
		
		Compare_Field_In_Line_(FieldComponent=FieldComponent)
		Notebook Report, text="\t",scaling={110,110},picture={$("CompareFieldInLine_" + FieldComponent),0, 1, 8},text="\r"
		Killwindow/Z $("CompareFieldInLine_" + FieldComponent)

		Compare_Field_Profile_(FieldComponent=FieldComponent)
		Notebook Report, text="\t",scaling={110,110},picture={$("CompareFieldProfile_" + FieldComponent),0, 1, 8},text="\r"
		Killwindow/Z $("CompareFieldProfile_" + FieldComponent)
	endif
	
	Notebook Report specialChar={1, 0, ""}
End

Function Add_Multipoles_Info(Dynamic)
	variable Dynamic
	
	Wave NormalMultipoles = root:wavesCAMTO:NormalMultipoles
	Wave SkewMultipoles   = root:wavesCAMTO:SkewMultipoles
	
	variable i
	
	if (DimSize(NormalMultipoles, 0))
		Add_Multipoles_Table(Dynamic, "Normal")
	
		for (i=0; i<DimSize(NormalMultipoles,0); i=i+1)
			Add_Multipole_Profile(NormalMultipoles[i], "Normal", Dynamic)
		endfor
		
	endif
		
	if (DimSize(SkewMultipoles, 0))
		if (DimSize(NormalMultipoles, 0)> 1)
			Notebook Report specialChar={1, 0, ""}
		elseif (DimSize(NormalMultipoles, 0))
			Notebook Report, text="\r"	
		endif

		Add_Multipoles_Table(Dynamic, "Skew")

		for (i=0; i<DimSize(SkewMultipoles,0); i=i+1)
			Add_Multipole_Profile(SkewMultipoles[i], "Skew", Dynamic)
		endfor
	
	endif
	
	Notebook Report specialChar={1, 0, ""}	
		
End


Function Add_Multipoles_Table(Dynamic, FieldComponent)
	variable Dynamic
	string FieldComponent
	
	
	SVAR dfA = root:varsCAMTO:FieldMapA
	SVAR dfB = root:varsCAMTO:FieldMapB
	NVAR ReferenceFieldMap = root:varsCAMTO:ReferenceFieldMap
	NVAR CheckMultTwo = root:varsCAMTO:CheckMultTwo

	Wave Multipoles = root:wavesCAMTO:$(FieldComponent + "Multipoles")
	
	string multstr
	
	if (Dynamic == 1)
		multstr = "Dyn_Mult_" + FieldComponent + "_Int"
	else
		multstr = "Mult_" + FieldComponent + "_Int"
	endif
	
	variable size = DimSize(Multipoles, 0)
		
	Make/O/T/N=(size, 3) TableWave
	Make/O/T/N=(size) RowWave
	Make/O/T/N=3 ColWave
	
	if (ReferenceFieldMap == 1)
		ColWave = {dfA, dfB, "Error [%]"}
		Wave mult = $("root:" + dfb + ":" + multstr)
		if (cmpstr(dfA, "Nominal")!=0)
			Wave mult_ref = $("root:" + dfa + ":" + multstr)		
		endif	
				
	else
		ColWave = {dfB, dfA, "Error [%]"}
		Wave mult = $("root:" + dfa + ":" + multstr)
		if (cmpstr(dfB, "Nominal")!=0)
			Wave mult_ref = $("root:" + dfb + ":" + multstr)
		endif

	endif
	
	Duplicate/O mult temp_mult
	if (WaveExists(mult_ref))
		Duplicate/O mult_ref temp_mult_ref
	endif
	
	if (CheckMultTwo)
		temp_mult = 2*temp_mult
		if (WaveExists(temp_mult_ref))
			temp_mult_ref = 2*temp_mult_ref
		endif
	endif
	
	variable i, n
	string str
	for (i=0; i<size; i=i+1)
		n = Multipoles[i][0]
		
		sprintf str, "%2.0f", n
		RowWave[i] = str
		
		if (WaveExists(mult_ref))
			sprintf str, "% 8.4f", temp_mult_ref[n] 
		else
			sprintf str, "% 8.4f", Multipoles[i][1] 
		endif
		TableWave[i][0] = str
		
		sprintf str, "% 8.4f", temp_mult[n] 
		TableWave[i][1] = str
		
		if (WaveExists(temp_mult_ref))
			sprintf str, "% 5.4f", 100*(temp_mult[n] - temp_mult_ref[n])/temp_mult_ref[n] 
		else
			sprintf str, "% 5.4f", 100*(temp_mult[n] - Multipoles[i][1])/Multipoles[i][1]  
		endif
		TableWave[i][2] = str
		
	endfor
	
	Add_Table(TableWave, ColWave=ColWave, RowWave=RowWave, Title="Integrated " + FieldComponent + " Multipoles:", RowTitle="n", Spacing=5)
			
	Killwaves/Z TableWave, ColWave, RowWave
	Killwaves/Z temp_mult, temp_mult_ref
	
End


Function Add_Multipole_Profile(K, FieldComponent, Dynamic)
	variable K
	string FieldComponent
	variable Dynamic
	
	if (Dynamic)
		Compare_Multipole_Profile_(1, K=K, FieldComponent=FieldComponent)
		Notebook Report, text="\t",scaling={90,90}, picture={$("CompareDynMult" + FieldComponent),0, 1, 8},text="\r"
		Killwindow/Z $("CompareDynMult" + FieldComponent)
	else
		Compare_Multipole_Profile_(0, K=K, FieldComponent=FieldComponent)
		Notebook Report, text="\t",scaling={90,90}, picture={$("CompareMult" + FieldComponent),0, 1, 8},text="\r"
		Killwindow/Z $("CompareMult" + FieldComponent)	
	endif
	
End


Function Add_Multipoles_Error_Table()

	NVAR r0     = root:varsCAMTO:DistCenter
	NVAR main_k = root:varsCAMTO:MainK

	Wave/Z normal_sys_monomials
	Wave/Z normal_sys_multipoles
	Wave/Z normal_rms_monomials 
	Wave/Z normal_rms_multipoles
	Wave/Z skew_sys_monomials
	Wave/Z skew_sys_multipoles
	Wave/Z skew_rms_monomials
	Wave/Z skew_rms_multipoles

	if (WaveExists(normal_sys_monomials))
		Concatenate {normal_sys_monomials, skew_sys_monomials, normal_rms_monomials, skew_rms_monomials}, temp_monomials 
		Sort temp_monomials, temp_monomials
		if (numpnts(temp_monomials) > 1)	
			FindDuplicates/RN=monomials temp_monomials
		else
			Duplicate/O temp_monomials monomials
		endif
		
		if (numpnts(monomials) == 0)
			Killwaves/Z temp_monomials, monomials
			return -1
		endif 
	
		string TableTitle="Magnet Multipole Errors Specification @r = " + num2str(r0) +" mm:"
		string Bmain = "B" + num2str(main_k)
		
		Make/O/T ColWave = {"Sys Normal", "Sys Skew", "Rnd Normal", "Rnd Skew"}
		Make/O/T/N=(numpnts(monomials),4) TableWave 
		Make/O/T/N=(numpnts(monomials)) RowWave 
			
		variable i, k
		string str
		for (i=0; i<numpnts(monomials); i=i+1)
			k = monomials[i]
	
			RowWave[i] = "B" + num2str(k) + "/" + Bmain
			
			FindValue/V=(k) normal_sys_monomials
			if (V_value == -1)
				TableWave[i][0] = "--"
			else
				sprintf str, "% 2.1e", normal_sys_multipoles[V_value]
				TableWave[i][0] =  str
			endif
	
			FindValue/V=(k) skew_sys_monomials
			if (V_value == -1)
				TableWave[i][1] = "--"
			else
				sprintf str, "% 2.1e", skew_sys_multipoles[V_value]
				TableWave[i][1] = str
			endif
	
			FindValue/V=(k) normal_rms_monomials
			if (V_value == -1)
				TableWave[i][2] = "--"
			else
				sprintf str, "% 2.1e", normal_rms_multipoles[V_value]
				TableWave[i][2] =  str
			endif
	
			FindValue/V=(k) skew_rms_monomials
			if (V_value == -1)
				TableWave[i][3] = "--"
			else
				sprintf str, "% 2.1e", skew_rms_multipoles[V_value]
				TableWave[i][3] = str
			endif
			
		endfor
		
		Add_Table(TableWave, RowWave=RowWave, ColWave=ColWave, Title=TableTitle, RowTitle="Multipole", Spacing=1)
				
		Killwaves/Z TableWave, RowWave, ColWave
		Killwaves/Z temp_monomials, monomials
	endif

End


Function Add_Residual_Field_Profile(Dynamic)
	variable 	Dynamic
	
	Notebook Report ruler=TableTitle, text="\tResidual Field:\r\r"
	
	Show_Residual_Field(Dynamic)
	
	Notebook Report, text="\t", picture={$("NormalResidualField"),0, 1, 8}, text="\r\r"
	Killwindow/Z $("NormalResidualField")

	Notebook Report, text="\t", picture={$("SkewResidualField"),0, 1, 8}, text="\r\r"
	Killwindow/Z $("SkewResidualField")

	Notebook Report specialChar={1, 0, ""}
End


Function Add_Parameters(Dynamic)
	variable Dynamic
	
	SVAR CAMTOVersion   = root:varsCAMTO:CAMTOVersion 
	
	SVAR dfA = root:varsCAMTO:FieldMapA
	SVAR dfB = root:varsCAMTO:FieldMapB

	if (cmpstr(dfA, "Nominal")==0)
		Add_Calc_Parameters(dfB, Dynamic)
	elseif (cmpstr(dfB, "Nominal")==0)
		Add_Calc_Parameters(dfA, Dynamic)
	else
		Add_Calc_Parameters(dfA, Dynamic)
		Add_Calc_Parameters(dfB, Dynamic)
	endif
	
	Notebook Report text="\tCAMTO Version : " + CAMTOVersion + "\r"
		
End


Function Add_Calc_Parameters(df, Dynamic)
	string df
	variable Dynamic
	
	SetDataFolder root:$(df)
	
	NVAR TrajShift = root:varsCAMTO:TrajShift
	
	SVAR FMFilename = :varsFieldMap:FMFilename
		
	Wave/T HeaderLines
			
	if (Dynamic)
		NVAR GridMin			= :varsFieldMap:GridMinTraj
		NVAR GridMax			= :varsFieldMap:GridMaxTraj
		NVAR DistCenter		= :varsFieldMap:DistcenterTraj
		SVAR NormalCoefs 	= :varsFieldMap:DynNormalCoefs 
		SVAR SkewCoefs 	 	= :varsFieldMap:DynSkewCoefs
		
	else
		NVAR GridMin        = :varsFieldMap:GridMin
		NVAR GridMax        = :varsFieldMap:GridMax
		NVAR Distcenter     = :varsFieldMap:Distcenter
		SVAR NormalCoefs 	= :varsFieldMap:NormalCoefs 
		SVAR SkewCoefs 	 	= :varsFieldMap:SkewCoefs		
	endif

	variable energy = GetParticleEnergy()

	Notebook Report ruler=TableHeader6, text="\t" + df + ":\r\r"

	variable i
	string filename
		
	for (i=0; i< numpnts(HeaderLines); i=i+1)
		sscanf HeaderLines[i], "filename: %s", filename
		if (strlen(filename) != 0)
			Notebook Report ruler=Table6,text= "\tFilename:\r" 
			Notebook Report ruler=Table6,text= "\t"+ FMFilename + "\r"
			break
		endif
	endfor

	for (i=0; i< numpnts(HeaderLines); i=i+1)
		if (strlen(HeaderLines[i])>1)
			sscanf HeaderLines[i], "filename: %s", filename
			if (strlen(filename) != 0)
				continue
			endif
			Notebook Report ruler=Table6,text= "\t"+ HeaderLines[i]	
		endif
	endfor
		
	Make/O/T/N=(50, 2) TableWave

	i = 0
	if (Dynamic)
		TableWave[i][0] = "Particle energy"
		TableWave[i][1] = num2str(energy) + " Gev"
		TableWave[1+i][0] = "Trajectory step"
		TableWave[1+i][1] = num2str(1000*TrajShift) + " mm"
		TableWave[2+i][0] = "Trajectory x @z=0mm"
		TableWave[2+i][1] = num2str(GetTrajPosX(0)) + " mm"
		i=i+3
	endif

	TableWave[i][0] = "Multipoles grid"
	TableWave[i][1] = "[" + num2str(GridMin) + " mm, " + num2str(GridMax) + " mm]"

	TableWave[1+i][0] = "R0 relative multipoles"
	TableWave[1+i][1] = num2str(Distcenter) + " mm"

	TableWave[2+i][0] = "Normal multipoles:"
	TableWave[2+i][1] = NormalCoefs + "  (0 - On, 1 - Off)"

	TableWave[3+i][0] = "Skew multipoles:"
	TableWave[3+i][1] = SkewCoefs
		
	Redimension/N=(4+i, 2) TableWave
	Add_Table(TableWave, Spacing=6)
	
	Killwaves/Z TableWave

End


Function Add_Table(TableWave, [ColWave, RowWave, Title, RowTitle, Spacing])
	Wave/T TableWave
	Wave/T ColWave
	Wave/T RowWave
	String Title
	String RowTitle
	Variable Spacing
	
	
	if (ParamIsDefault(Spacing))
		Spacing = 0
	endif
	
	string table_ruler_name  = "Table" + num2str(Spacing)
	string header_ruler_name = "TableHeader" + num2str(Spacing)
	
	if (!ParamIsDefault(Title))
		Notebook Report ruler=TableTitle, text="\t" + Title  + "\r"
	endif
	
	variable i, j
	
	if (!ParamIsDefault(ColWave))
		if (!ParamIsDefault(RowWave))
			if (ParamIsDefault(RowTitle))
				Notebook Report ruler=$(header_ruler_name), text="\t"
			else
				Notebook Report ruler=$(header_ruler_name), text="\t" + RowTitle
			endif
		endif
		
		for (i=0; i<numpnts(ColWave); i=i+1)
			Notebook Report ruler=$(header_ruler_name), text="\t"+ColWave[i]
		endfor
		
		Notebook Report text="\r"
	endif
	
	for (j=0; j<DimSize(TableWave, 0); j=j+1)
		if (!ParamIsDefault(RowWave))
			Notebook Report ruler=$(table_ruler_name), text="\t"+RowWave[j]
		endif
		
		if (DimSize(TableWave, 1) != 0)
			for (i=0; i<DimSize(TableWave, 1); i=i+1)
				Notebook Report ruler=$(table_ruler_name), text="\t" + TableWave[j][i]
			endfor
		else
			Notebook Report ruler=$(table_ruler_name), text="\t" + TableWave[j]
		endif
		Notebook Report text="\r"
	endfor
	
	Notebook Report text="\r"

End


Window Load_Line_Scan() : Panel
	PauseUpdate; Silent 1

	string PanelName
	PanelName = WinList("Load_Line_Scan",";","")	
	if (stringmatch(PanelName, "Load_Line_Scan;"))
		Killwindow Load_Line_Scan
	endif
	
	CreateLabelVar()
		
	NewPanel /K=1 /W=(1240,60,1500,225)
	SetDrawLayer UserBack
	SetDrawEnv fillpat= 0
	DrawRect 5,3,255,160
			
	TitleBox FMdir,      pos={80,12},size={80,40},title="Load Line Scan",fSize=14,fStyle=1,frame=0
	SetVariable scanlabel, pos={20,60},size={220,18},title="Label:",value=root:ScanLabel
	Button loadscan,pos={20,100},size={220,41},proc=LoadLineScan,fStyle=1,title="Load"
				
EndMacro


Function CreateLabelVar()
	
	DFREF df = GetDataFolderDFR()
	
	SetDataFolder root:
	string/G ScanLabel=""

	SetDataFolder df

End

Function LoadLineScan(ctrlName) : ButtonControl
	String ctrlName
	
	SVAR ScanLabel = root:ScanLabel
	
	DFREF df = GetDataFolderDFR()

	SetDataFolder root:
	
	variable i, j
	LoadWave/H/O/G/D/W/A ""

	if (V_flag==0) 
		return -1
	endif

	string sl, fn
	variable idx
	
	fn = S_filename
	fn = RemoveEnding(fn, ".dat")
	fn = RemoveEnding(fn, ".txt")

	if (strlen(ScanLabel) == 0)
		idx = strsearch(fn, "ID=",0)
		if (idx!=-1) 
			sl = "_" + fn[idx, strlen(fn)]
		else
			sl = ""
		endif
	else
		sl = "_" + ScanLabel
	endif

	Wave wave0, wave1, wave2, wave3
	Wave/Z wave4, wave5, wave6
	
	Duplicate/O wave0, $("position" + sl)
	Duplicate/O wave1, $("bx" + sl)
	Duplicate/O wave2, $("by" + sl)
	Duplicate/O wave3, $("bz" + sl)
	
	if (Waveexists(wave4)==1 && Waveexists(wave5)==1 && Waveexists(wave6)==1)
		Duplicate/O wave4, $("std_bx" + sl)
		Duplicate/O wave5, $("std_by" + sl)
		Duplicate/O wave6, $("std_bz" + sl)
	endif
	
	Killwaves/Z wave0, wave1, wave2, wave3, wave4, wave5, wave6
	
	SetDataFolder df
End

Function GetTrajPosX(PosYZ)
	variable PosYZ
	
	NVAR TrajShift = root:varsCAMTO:TrajShift
	
	NVAR StartXTraj = :varsFieldMap:StartXTraj
	NVAR BeamDirection = :varsFieldMap:BeamDirection
	
	wave TrajX = $"TrajX" + num2str(StartXTraj/1000)
	wave TrajY = $"TrajY" + num2str(StartXTraj/1000)
	wave TrajZ = $"TrajZ"  + num2str(StartXTraj/1000)

	variable horizontal_pos	
	variable index, diff_up, diff_down
	
	if (BeamDirection == 1)
		Duplicate/O TrajY TrajL
	else
		Duplicate/O TrajZ TrajL
	endif
	
	FindValue/V=(PosYZ/1000) TrajL
	if (V_value == -1)
		FindValue/V=(PosYZ/1000)/T=(TrajShift) TrajL
	endif
	if (V_value == -1)
		return NaN
	else
		index = V_value
		
		if (TrajL[index] != PosYZ/1000)
			diff_up = Abs(PosYZ/1000 - TrajL[index+1])
			diff_down = Abs(PosYZ/1000 - TrajL[index-1])
					
			if (diff_up < diff_down && index != numpnts(TrajL)-1)
				horizontal_pos = TrajX[index] + (TrajX[index+1] - TrajX[index])*(PosYZ/1000 - TrajL[index])/(TrajL[index+1] - TrajL[index])
			else
				horizontal_pos = TrajX[index-1] + (TrajX[index] - TrajX[index-1])*(PosYZ/1000 - TrajL[index-1])/(TrajL[index] - TrajL[index-1])
			endif			
		
		else
			horizontal_pos = TrajX[index]
		
		endif
		
	endif
	
	Killwaves/Z TrajSearch
	
	return horizontal_pos*1000

End


Function GetTrajAngleX(PosYZ)
	variable PosYZ
	
	NVAR TrajShift = root:varsCAMTO:TrajShift
	
	NVAR StartXTraj = :varsFieldMap:StartXTraj
	NVAR BeamDirection = :varsFieldMap:BeamDirection

	Wave TrajX = $"TrajX"+num2str(StartXTraj/1000)
	Wave VelX  = $"Vel_X"+num2str(StartXTraj/1000)

	if (BeamDirection == 1)
		Wave TrajL = $"TrajY"+num2str(StartXTraj/1000)
		Wave VelL  = $"Vel_Y"+num2str(StartXTraj/1000)
	else
		Wave TrajL = $"TrajZ"+num2str(StartXTraj/1000)
		Wave VelL  = $"Vel_Z"+num2str(StartXTraj/1000)
	endif

	variable angle, index, diff_up, diff_down, vx, vl
	
	FindValue/V=(PosYZ/1000) TrajL
	if (V_value == -1)
		FindValue/V=(PosYZ/1000)/T=(TrajShift) TrajL
	endif
	
	if (V_value == -1)
		return NaN
	else
		index = V_value
		
		if (TrajL[index] != PosYZ/1000)
			diff_up = Abs(PosYZ/1000 - TrajL[index+1])
			diff_down = Abs(PosYZ/1000 - TrajL[index-1])
					
			if (diff_up < diff_down && index != numpnts(TrajL)-1)
				vx = VelX[index] + (VelX[index+1] - VelX[index])*(PosYZ/1000 - TrajL[index])/(TrajL[index+1] - TrajL[index])
				vl = VelL[index] + (VelL[index+1] - VelL[index])*(PosYZ/1000 - TrajL[index])/(TrajL[index+1] - TrajL[index])
			else
				vx = VelX[index-1] + (VelX[index] - VelX[index-1])*(PosYZ/1000 - TrajL[index-1])/(TrajL[index] - TrajL[index-1])
				vl = VelL[index-1] + (VelL[index] - VelL[index-1])*(PosYZ/1000 - TrajL[index-1])/(TrajL[index] - TrajL[index-1])
			endif			
		
		else
			vx = VelX[index]
			vl = VelL[index]
		
		endif
		
		angle = atan(vx/vl)*180/pi
		return angle
	endif

End


Function IntegratedMultipole(k, [skew])
	variable k
	variable skew
	
	if (ParamIsDefault(skew))
		skew = 0
	endif	
	
	DFREF cf = GetDataFolderDFR()
	
	SetDataFolder root:
		
	Wave/T FieldMapDirs = root:wavesCAMTO:FieldMapDirs
	NVAR   FieldMapCount = root:varsCAMTO:FieldMapCount
	
	string wn, nwn
	if (skew)
		wn = "Mult_Skew_Int"
	else
		wn = "Mult_Normal_Int"
	endif
	
	nwn = wn + "_" + num2str(k)	
	Make/D/O/N=(FieldmapCount) $nwn 
	Wave Mult_Int = $nwn
		
	variable i
	string df
	
	for (i=0; i<FieldMapCount; i=i+1)
		df = FieldMapDirs[i]
		Wave temp = root:$(df):$(wn)
		if (WaveExists(temp))
			Mult_Int[i] = temp[k]
		else
			Print("Multipoles wave not found for: " + df)
			break
		endif
	endfor
	
	SetDataFolder cf
	
End



Function IntegratedDynamicMultipole(k, [skew])
	variable k
	variable skew
	
	if (ParamIsDefault(skew))
		skew = 0
	endif	
	
	DFREF cf = GetDataFolderDFR()
	
	SetDataFolder root:
		
	Wave/T FieldMapDirs = root:wavesCAMTO:FieldMapDirs
	NVAR   FieldMapCount = root:varsCAMTO:FieldMapCount
	
	string wn, nwn
	
	if (skew)
		wn = "Dyn_Mult_Skew_Int"
	else
		wn = "Dyn_Mult_Normal_Int"
	endif
	
	nwn = wn + "_" + num2str(k)	
	Make/D/O/N=(FieldmapCount) $nwn
	Wave Dyn_Mult_Int = $nwn
		
	variable i
	string df
	
	for (i=0; i<FieldMapCount; i=i+1)
		df = FieldMapDirs[i]
		Wave temp = root:$(df):$(wn)
		if (WaveExists(temp))
			Dyn_Mult_Int[i] = temp[k]
		else
			Print("Multipoles wave not found for: " + df)
			KillWaves/Z Dyn_Mult_Int
			break
		endif				
	endfor
	
	SetDataFolder cf
	
End


Function FindDipoleX0(nominal_deflection, xa, xb, [tol, nmax])
	variable nominal_deflection, xa, xb, tol, nmax

	if (ParamIsDefault(tol))
		tol = 1e-3
	endif

	if (ParamIsDefault(nmax))
		nmax = 1000
	endif
	
	NVAR StartYZ = :varsFieldMap:StartYZ 
	NVAR EndYZ   = :varsFieldMap:EndYZ

	NVAR EntranceAngle = :varsFieldMap:EntranceAngle
	NVAR StartXTraj    = :varsFieldMap:StartXTraj 
	NVAR StartYZTraj = :varsFieldMap:StartYZTraj 
	NVAR EndYZTraj   = :varsFieldMap:EndYZTraj
	NVAR CheckField    = :varsFieldMap:CheckField
   NVAR CheckNegPosTraj = :varsFieldMap:CheckNegPosTraj
	NVAR Single_Multi  = :varsFieldMap:Single_Multi 
	NVAR Analitico_RungeKutta = :varsFieldMap:Analitico_RungeKutta  

	variable EntranceAngle_init
	variable StartXTraj_init
	variable StartYZTraj_init
	variable EndYZTraj_init
	variable CheckField_init
	variable CheckNegPosTraj_init
	variable Single_Multi_init
	variable Analitico_RungeKutta_init

	EntranceAngle_init = EntranceAngle
	StartXTraj_init = StartXTraj
	StartYZTraj_init = StartYZTraj
	EndYZTraj_init = EndYZTraj
	CheckField_init = CheckField
	CheckNegPosTraj_init = CheckNegPosTraj
	Single_Multi_init = Single_Multi
	Analitico_RungeKutta_init = Analitico_RungeKutta

	EntranceAngle = 0
	StartYZTraj = 0
	EndYZTraj =  Min(Abs(StartYZ), Abs(EndYZ))
	CheckField = 1
	CheckNegPosTraj = 1
	Single_Multi = 1
	Analitico_RungeKutta = 2

	variable n, xc, defc, diffc, diffa, x0
	string xc_str, defc_str

	StartXTraj = xa
	TrajectoriesCalculationProc("")
	wave Deflection_IntTraj_X
	diffa = nominal_deflection - Deflection_IntTraj_X[0]
	
	n = 1
	do
		xc = (xa + xb)/2
		StartXTraj = xc
		TrajectoriesCalculationProc("")
		wave Deflection_IntTraj_X
		defc = Deflection_IntTraj_X[0]
		
		sprintf xc_str, "%.10f", xc
		sprintf defc_str, "%.10f", defc
		Print/D "X0 [mm]: "  + xc_str
		Print/D "Deflection [°]: " + defc_str
		Print " "
		
		diffc = nominal_deflection - defc
		if (diffc == 0 || (xb-xa)/2 < tol)
			break
		endif

		if (sign(diffc) == sign(diffa))
			xa = xc
			diffa = diffc
		else
			xb = xc
		endif 

		n = n+1
	while (n < nmax)

	x0 = StartXTraj

	EntranceAngle = EntranceAngle_init
	StartXTraj = StartXTraj_init
	StartYZTraj = StartYZTraj_init
	EndYZTraj = EndYZTraj_init
	CheckField = CheckField_init
	CheckNegPosTraj = CheckNegPosTraj_init
	Single_Multi = Single_Multi_init
	Analitico_RungeKutta = Analitico_RungeKutta_init
	UpdateTrajectoriesPanel()

	return x0

End

// Alterações
//Versão 12.9.1  - Multipolos Normalizados não são mais expressos por seus módulos (pedido da Priscila)
//Versão 12.10.1 - Mudança no método de cálculo de simetrias, adição de rotinas para cálculo dos multipolos residuais normalizados e cabeçalho no arquivo exportado. Multipolos de todas as componentes são agora normalizados em relação ao mesmo termo.
//Versão 12.11.0 - Mudança no método de cálculo de multipolos sobre a trajetória. 
//Versão 13.0.0  - Mudança na estrutura de pastas para analisar mais de um mapa de campo no mesmo experimento.
//Versão 13.0.1  - Diferenciação dos coeficientes usados para calcular multipolos normal e skew.
//Versão 13.0.2  - Correção de bugs.