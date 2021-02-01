#pragma TextEncoding = "UTF-8"
// Code for Analysis of Multipoles, Trajectories and Others.
// Last Update: 27/03/2020

#pragma rtGlobals = 3	
#pragma version = 14.0.0


Menu "CAMTO 14.0.0"
	"Initialize CAMTO", CAMTO_Init()
	"Global Parameters", CAMTO_Params_Panel()
	"Field Specification", CAMTO_Spec_Panel()
	"Load Fieldmap", CAMTO_Load_Panel()
	"Export Field Data", CAMTO_Export_Panel()
	"View Magnetic Field", CAMTO_ViewField_Panel()
//	"Hall Probe Correction", CAMTO_HallProbe()
	"Trajectories", CAMTO_Traj_Panel()
//	"Integrals and Multipoles", CAMTO_Multipoles()
//	"Dynamic Multipoles", CAMTO_DynMultipoles()
	"Results", CAMTO_Results_Panel()
	"Find Peaks and Zeros", CAMTO_Peaks_Panel()
//	"Phase Error", CAMTO_PhaseError()
//	"Insertion Devices Results", CAMTO_ID()
//	"Compare Results", CAMTO_Compare()
//	"Get Variable From Fieldmaps", CAMTO_GetVariable()
//	"Load Scan", CAMTO_Scan()
	"Help", CAMTO_Help()
End


Function CAMTO_Help()
	PathInfo Igor
	NewPath/O/Q IgorUtiPath, S_path + "Igor Help Files"
	OpenNotebook/Z/R/P=IgorUtiPath/N=CAMTOHelpNotebook "CAMTO_Help.ihf"
	PrintCamtoHeader()
	
	return 0
End


Function CAMTO_Init()

	if (DataFolderExists("root:varsCAMTO"))
		DoAlert 1, "Restart CAMTO?"
		if (V_flag == 2)
			return -1
		endif 
	endif

	SetDataFolder root:

	PrintCamtoHeader()	
	KillAllWaves()
	KillFieldmapFolders()

	KillDataFolder/Z wavesCAMTO
	NewDataFolder/O wavesCAMTO
	
	KillDataFolder/Z varsCAMTO
	NewDataFolder/O varsCAMTO
           
	SetDataFolder root:varsCAMTO:
       
	Killvariables/A/Z
	KillStrings/A/Z
	
	string/G CAMTO_VERSION = "14.0.0"

	variable/G PARTICLE_CHARGE = -1.602177E-19
	variable/G PARTICLE_MASS = 9.109389E-31
	variable/G LIGHT_SPEED = 2.99792458E+08
	variable/G TRAJECTORY_STEP = 0.00001
	
	variable/G POSITION_TOLERANCE = 1e-10
	
	variable/G FIELDMAP_COUNT = 0
	variable/G FIELDMAP_REFERENCE = 1
	string/G FIELDMAP_NEW_FOLDER = "Fieldmap"
	string/G FIELDMAP_FOLDER
	string/G FIELDMAP_COPY
	string/G FIELDMAP_A
	string/G FIELDMAP_B

	variable/G SPEC_REFERENCE_RADIUS = 0
	variable/G SPEC_MAIN_MULTIPOLE = 0
	variable/G SPEC_SKEW = 1
	variable/G SPEC_NR_NORMAL_MULTIPOLES = 1
	variable/G SPEC_NR_SKEW_MULTIPOLES = 0
	variable/G SPEC_NR_MULTIPOLE_ERRORS = 10

	variable/G LOAD_STATIC_TRANSIENT = 1
	variable/G LOAD_SYMMETRY_LONGITUDINAL = 0
	variable/G LOAD_SYMMETRY_HORIZONTAL = 0
	variable/G LOAD_BEAM_DIRECTION = 2 // 1: Y-Axis, 2: Z-Axis
	variable/G LOAD_SYMMETRY_LONGITUDINAL_BC = 2 // 1: Normal, 2: Tangencial
	variable/G LOAD_SYMMETRY_HORIZONTAL_BC = 1 // 1: Normal, 2: Tangencial

//	variable/G COMPARE_POS_H = 0
//	variable/G COMPARE_POS_START_H = 0
//	variable/G COMPARE_POS_END_H = 0
//	variable/G COMPARE_POS_L = 0
//	variable/G COMPARE_MULTIPOLE = 0	
//	variable/G COMPARE_DYN_MULTIPOLE = 0
//	variable/G COMPARE_CHECK_REFERENCE_LINES = 0	
//	variable/G COMPARE_CHECK_DYN_MULTIPOLE = 0
//	variable/G COMPARE_CHECK_MULTIPLE_BY_TWO = 0

	SetDataFolder root:wavesCAMTO:
	
	Make/T/N=0 fieldmapFolders
	Make/D/N=(1, 2) normalMultipoles
	Make/D/N=(0, 2) skewMultipoles
	Make/D/N=(10,5) multipoleErrors
	Make/N=3 colorH = {0, 0, 65000}
	Make/N=3 colorV = {65000, 0, 0}
	Make/N=3 colorL = {0, 40000, 0}
	Make/N=3 colorGrid = {35000, 35000, 35000}
	
	SetDataFolder root:

	return 0
End


Static Function PrintCamtoHeader()
	Print(" ")
	Print("CAMTO - Code for Analysis of Multipoles, Trajectories and Others.")
	Print("Version 14.0.0")
	Print("Last Upgrade: March, 27th 2020")	
	Print("Creator: James Citadini")	
	Print("Co-Creators: Giancarlo Tosin, Priscila Palma Sanchez, Tiago Reis and Luana Vilela")
	Print("Acknowlegments to: Ximenes Rocha Resende and Liu Lin")
	Print("Brazilian Synchrotron Light Laboratory - LNLS")	
	
	return 0
End


Static Function KillAllWaves()
 
 	string graphs=WinList("*",";","WIN:4183")
  
  	variable i
  	for(i=0; i<ItemsInList(graphs); i+=1)
  		string graph=StringFromList(i,graphs)
    	KillWindow $graph
  	endfor
  
  	SetDataFolder root:
  	KillWaves/A/Z

	return 0
End


Static Function KillFieldmapFolders()

	Wave/T fieldmapFolders = root:wavesCAMTO:fieldmapFolders
	
	if (WaveExists(fieldmapFolders)!=0)
		UpdateFieldmapFolders()
		
		variable i
		for(i=0; i<numpnts(fieldmapFolders); i=i+1)
			KillDataFolder/Z $(fieldmapFolders[i])
		endfor
		
	endif
	
	return 0

End


Static Function UpdateFieldmapFolders()

	DFREF df = GetDataFolderDFR()
	NVAR fieldmapCount = root:varsCAMTO:FIELDMAP_COUNT
	SVAR fieldmapFolder = root:varsCAMTO:FIELDMAP_FOLDER
	WAVE/T fieldmapFolders = root:wavesCAMTO:fieldmapFolders

	Make/O/T/N=(fieldmapCount) auxFieldmapFolders
	
	variable auxFieldmapCount = 0
	
	SetDataFolder root:
	string dataFolders = DataFolderDir(1)
	SetDataFolder df
	
	SplitString/E=":.*;" dataFolders
	S_value = S_value[1, strlen(S_value)-2]
	
	variable i	
	for (i=0; i<fieldmapCount; i=i+1)
		if (FindListItem(fieldmapFolders[i], S_value, ",") == -1 )
			if (CmpStr(fieldmapFolders[i], fieldmapFolder)==0)
				fieldmapFolder = ""
			endif
		
		else
			auxFieldmapFolders[auxFieldmapCount] = fieldmapFolders[i]		
			auxFieldmapCount = auxFieldmapCount + 1
		endif
	endfor 
	
	fieldmapCount = auxFieldmapCount
	Redimension/N=(fieldmapCount) auxFieldmapFolders
	Redimension/N=(fieldmapCount) fieldmapFolders
	fieldmapFolders = auxFieldmapFolders
	
	Killwaves/Z auxFieldmapFolders

	return 0

End


Function CAMTO_Params_Panel() : Panel
	
	string windowName = "Params"
	string windowTitle = "Global Parameters"
	
	if (DataFolderExists("root:varsCAMTO")==0)
		DoAlert 1, "CAMTO variables not found. Initialize CAMTO?"
		if (V_flag == 1)
			CAMTO_Init()
		else
			return -1
		endif 
	endif
	
	DoWindow/K $windowName
	NewPanel/K=1/N=$windowName/W=(80,60,405,250) as windowTitle
	SetDrawLayer UserBack

	NVAR particleCharge = root:varsCAMTO:PARTICLE_CHARGE
	NVAR particleMass = root:varsCAMTO:PARTICLE_MASS
	NVAR lightSpeed = root:varsCAMTO:LIGHT_SPEED
	NVAR trajectoryStep = root:varsCAMTO:TRAJECTORY_STEP
	
	variable m, h, h1, l1, l2 
	m = 20	
	h = 10
	h1 = 5	
	l1 = 5
	l2 = 320

	TitleBox tbxTitle, pos={0,h}, size={320,25}, anchor=MT, fsize=18, fstyle=1, frame=0, title="Global Parameters"
	h += 35

	SetDrawEnv fillpat=0
	DrawRect l1,h1,l2,h-5
	h1 = h-5
	
	SetVariable svarParticleCharge, pos={m,h}, size={210,20}, value=_NUM:particleCharge, title="Particle Charge [C]"
	ValDisplay vdispParticleCharge, pos={m+220,h}, size={100,20}, limits={0,0,0}, barmisc={0,1000}, mode=5
	ValDisplay vdispParticleCharge, value=#"root:varsCAMTO:PARTICLE_CHARGE"
	h += 25
	
	SetVariable svarParticleMass, pos={m,h}, size={210,20}, value=_NUM:particleMass, title="Particle Mass [Kg]"
	ValDisplay vdispParticleMass, pos={m+220,h}, size={100,20}, limits={0,0,0}, barmisc={0,1000}, mode=5
	ValDisplay vdispParticleMass, value=#"root:varsCAMTO:PARTICLE_MASS"
	h += 25
	
	SetVariable svarLightSpeed, pos={m,h}, size={210,20}, value=_NUM:lightSpeed, title="Speed of Light [m/s]"
	ValDisplay vdispLightSpeed, pos={m+220,h}, size={100,20}, limits={0,0,0}, barmisc={0,1000}, mode=5
	ValDisplay vdispLightSpeed, value= #"root:varsCAMTO:LIGHT_SPEED"
	h += 25
	
	SetVariable svarTrajectoryStep, pos={m,h}, size={210,20}, value=_NUM:trajectoryStep, title="Trajectory Step [m]"
	ValDisplay vdispTrajectoryStep, pos={m+220,h}, size={100,20}, limits={0,0,0}, barmisc={0,1000}, mode=5
	ValDisplay vdispTrajectoryStep, value=#"root:varsCAMTO:TRAJECTORY_STEP"
	h += 30

	SetDrawEnv fillpat=0
	DrawRect l1,h1,l2,h-5
	h1 = h-5

	Button btnQuit, pos={45,h}, size={100,30}, fsize=14, fstyle=1, proc=CAMTO_Params_BtnQuit, title="Quit"
	Button btnChange, pos={175,h}, size={100,30}, fsize=14, fstyle=1, proc=CAMTO_Params_BtnChange, title="Change"
	h += 40

	SetDrawEnv fillpat=0
	DrawRect l1,h1,l2,h-5

	return 0

End


Function CAMTO_Params_BtnQuit(ba) : ButtonControl
	struct WMButtonAction &ba
	
	switch(ba.eventCode)
		case 2:
			Killwindow/Z $(ba.win)
			break
	endswitch
	
	return 0
End


Function CAMTO_Params_BtnChange(ba) : ButtonControl
	struct WMButtonAction &ba

	NVAR particleCharge = root:varsCAMTO:PARTICLE_CHARGE
	NVAR particleMass = root:varsCAMTO:PARTICLE_MASS
	NVAR lightSpeed = root:varsCAMTO:LIGHT_SPEED
	NVAR trajectoryStep = root:varsCAMTO:TRAJECTORY_STEP
	NVAR fieldmapCount = root:varsCAMTO:FIELDMAP_COUNT

	switch(ba.eventCode)
		case 2:	
    		ControlInfo/W=$ba.win svarParticleCharge
    		particleCharge = V_Value
    		  
    		ControlInfo/W=$ba.win svarParticleMass
    		particleMass = V_Value
    		
    		ControlInfo/W=$ba.win svarLightSpeed
    		lightSpeed = V_Value
    		
    		ControlInfo/W=$ba.win svarTrajectoryStep
    		trajectoryStep = V_Value

			break
	endswitch
	
	return 0

End


Function CAMTO_Spec_Panel() : Panel

	string windowName = "Spec"
	string windowTitle = "Field Specification"

	if (DataFolderExists("root:varsCAMTO")==0)
		DoAlert 1, "CAMTO variables not found. Initialize CAMTO?"
		if (V_flag == 1)
			CAMTO_Init()
		else
			return -1
		endif 
	endif
	
	DoWindow/K $windowName
	NewPanel/K=1/N=$windowName/W=(240,60,1000,555) as windowTitle
	SetDrawLayer UserBack

	NVAR skew = root:varsCAMTO:SPEC_SKEW

	variable m, h, h1, l1, l2 
	m = 20	
	h = 10
	h1 = 5	
	l1 = 5
	l2 = 755

	TitleBox tbxTitle1, pos={0,h}, size={380,25}, anchor=MT, fsize=18, fstyle=1, frame=0, title="Main Parameters"
	TitleBox tbxTitle2, pos={380,h}, size={380,25}, anchor=MT, fsize=18, fstyle=1, frame=0, title="Multipole Errors"
	h += 35

	SetDrawEnv fillpat=0
	DrawRect l1,h1,l2/2,h-5
	SetDrawEnv fillpat=0
	DrawRect l2/2,h1,l2,h-5
	h1 = h-5

	SetVariable svarMainMultipole, pos={m,h+4}, size={170,20}, limits={0,15,1}, title="Main Harmonic"
	SetVariable svarMainMultipole, value=root:varsCAMTO:SPEC_MAIN_MULTIPOLE
	PopupMenu popupSkew, pos={m+180,h+5}, size={120,20}, proc=CAMTO_Spec_PopupMainComponent, title=""
	PopupMenu popupSkew, value= #"\"Normal;Skew\"", mode=skew
	h += 40

	TitleBox tbxTitle3, pos={m,h}, fsize=14, fstyle=1, frame=0, title="Normal Integrated Multipoles"
	SetVariable svarNumberMultipoles, pos={m+240,h}, size={80,20}, limits={0,4,1}, proc=CAMTO_Spec_SvarRowsNormal, title="rows"
	SetVariable svarNumberMultipoles, value=root:varsCAMTO:SPEC_NR_NORMAL_MULTIPOLES
	h += 25
	
	TitleBox tbxTitleNormalN, pos={m,h}, size={130,20}, anchor=MC, frame=0, title="n"
	TitleBox tbxTitleNormalBn, pos={m+150,h}, size={170,20}, anchor=MC, frame=0, title="Integrated Bn"
	h += 165

	TitleBox tbxTitle6, pos={m,h}, fsize=14, fstyle=1, frame=0, title="Skew Integrated Multipoles"
	SetVariable svarNumberSkewMultipoles, pos={m+240,h}, size={80,20}, limits={0,4,1}, proc=CAMTO_Spec_SvarRowsSkew, title="rows"
	SetVariable svarNumberSkewMultipoles, value=root:varsCAMTO:SPEC_NR_SKEW_MULTIPOLES
	h += 25
	
	TitleBox tbxTitleSkewN, pos={m,h}, size={130,20}, anchor=MC, frame=0, title="n"
	TitleBox tbxTitleSkewAn, pos={m+150,h}, size={170,20}, anchor=MC, frame=0, title="Integrated An"
	
	h = 50
	SetVariable svarReferenceRadius, pos={m+380,h}, size={250,20}, limits={0,inf,1}, title="Reference Radius [mm]"
	SetVariable svarReferenceRadius, value=root:varsCAMTO:SPEC_REFERENCE_RADIUS
	h += 30
	
	TitleBox tbxTitle9, pos={m+380,h}, fsize=14, fstyle=1, frame=0, title="Norm. Integrated Multipole Errors"
	SetVariable svarNumberMultipoleErrors, pos={m+380+240,h}, size={80,20}, limits={1,15,1}, proc=CAMTO_Spec_SvarRowsErrors, title="rows"
	SetVariable svarNumberMultipoleErrors, value=root:varsCAMTO:SPEC_NR_MULTIPOLE_ERRORS
	h += 20
	
	TitleBox tbxTitle10, pos={m+380,h}, size={60,40}, anchor=MC, frame=0, title="n"
	TitleBox tbxTitle11, pos={m+380+70,h}, size={60,40}, anchor=MC, frame=0, title="Systematic\nNormal"
	TitleBox tbxTitle12, pos={m+380+140,h}, size={60,40}, anchor=MC, frame=0, title="Systematic\nSkew"
	TitleBox tbxTitle13, pos={m+380+210,h}, size={60,40}, anchor=MC, frame=0, title="Random\nNormal"
	TitleBox tbxTitle14, pos={m+380+280,h}, size={60,40}, anchor=MC, frame=0, title="Random\nSkew"
	h = 455
	
	SetDrawEnv fillpat=0
	DrawRect l1,h1,l2/2,h-5
	SetDrawEnv fillpat=0
	DrawRect l2/2,h1,l2,h-5
	h1 = h-5
	
	Button btnUpdateSpec, pos={m+110,h}, size={500,30}, fsize=14, fstyle=1, title="Update Field Specification"
	Button btnUpdateSpec, proc=CAMTO_Spec_BtnUpdateSpec
	h += 40
	
	SetDrawEnv fillpat=0
	DrawRect l1,h1,l2,h-5

	UpdateSpecNormal()
	UpdateSpecSkew()		
	UpdateSpecErrors()
	
	return 0

EndMacro


Function CAMTO_Spec_PopupMainComponent(pa) : PopupMenuControl
	struct WMPopupAction &pa
	
	NVAR skew = root:varsCAMTO:SKEW
	
	switch(pa.eventCode)
		case 2:
			skew = pa.popNum
			break
	endswitch
	
	return 0
End


Function CAMTO_Spec_SvarRowsNormal(sa): SetVariableControl
	struct WMSetVariableAction &sa
	
	UpdateSpecNormal(nrRows=sa.dval)
	
	return 0
	
End


Function CAMTO_Spec_SvarRowsSkew(sa): SetVariableControl
	struct WMSetVariableAction &sa
	
	UpdateSpecSkew(nrRows=sa.dval)
	
	return 0
		
End


Function CAMTO_Spec_SvarRowsErrors(sa): SetVariableControl
	struct WMSetVariableAction &sa
	
	UpdateSpecErrors(nrRows=sa.dval)
	
	return 0

End


Function CAMTO_Spec_BtnUpdateSpec(ba) : ButtonControl
	struct WMButtonAction &ba

	switch(ba.eventCode)
		case 2:
			CalcResFieldSpec()
			print "Field specification updated!"
			break
	endswitch
	
	return 0

End


Function CAMTO_Spec_SvarTableFormat(sa): SetVariableControl
	struct WMSetVariableAction &sa
	
	if (sa.dval == 0)
		SetVariable $(sa.ctrlName), win=$sa.win, format="%1.0f"
	else
		SetVariable $(sa.ctrlName), win=$sa.win, format="% 2.1e"
	endif
	
	return 0
	
End


Static Function UpdateSpecNormal([nrRows])
	variable nrRows

	variable i, space, prevNrRows
	string variableName, windowName

	WAVE multipoles = root:wavesCAMTO:normalMultipoles

	windowName = "Spec"
	space = 30
	prevNrRows = DimSize(multipoles, 0)
	
	if (!ParamIsDefault(nrRows))
		Redimension/N=(nrRows, 2) multipoles
	else
		nrRows = prevNrRows
	endif

	if (nrRows == 0)
		TitleBox tbxTitleNormalN, win=$windowName, disable=1
		TitleBox tbxTitleNormalBn, win=$windowName, disable=1
	else
		TitleBox tbxTitleNormalN, win=$windowName, disable=0
		TitleBox tbxTitleNormalBn, win=$windowName, disable=0	
	endif
	
	for (i=0; i<prevNrRows; i=i+1)
		variableName = "svar_multipoles_" + num2str(i) + "_monomial"
		SetVariable $(variableName), win=$windowName, disable=1
		variableName = "svar_multipoles_" + num2str(i) + "_value"
		SetVariable $(variableName), win=$windowName, disable=1
	endfor

	for (i=0; i<nrRows; i=i+1)
		variableName = "svar_multipoles_" + num2str(i) + "_monomial"
		SetVariable $(variableName), win=$windowName, pos={20,(140+i*space)}, size={130,20}, title=" ", disable=0
		SetVariable $(variableName), win=$windowName, limits={0,inf,0}, value=multipoles[i][0]
		
		variableName = "svar_multipoles_" + num2str(i) + "_value"
		SetVariable $(variableName), win=$windowName, pos={170,(140+i*space)}, size={170,20}, title=" ", disable=0
		SetVariable $(variableName), win=$windowName, limits={-inf,inf,0}, value=multipoles[i][1]
		
	endfor
	
	return 0

End


Static Function UpdateSpecSkew([nrRows])
	variable nrRows

	variable i, space, prevNrRows
	string variableName, windowName

	WAVE multipoles = root:wavesCAMTO:skewMultipoles

	windowName = "Spec"
	space = 30
	prevNrRows = DimSize(multipoles, 0)
	
	if (!ParamIsDefault(nrRows))
		Redimension/N=(nrRows, 2) multipoles
	else
		nrRows = prevNrRows
	endif

	if (nrRows == 0)
		TitleBox tbxTitleSkewN, win=$windowName, disable=1
		TitleBox tbxTitleSkewAn, win=$windowName, disable=1
	else
		TitleBox tbxTitleSkewN, win=$windowName, disable=0
		TitleBox tbxTitleSkewAn, win=$windowName, disable=0	
	endif
	
	for (i=0; i<prevNrRows; i=i+1)
		variableName = "svar_skew_" + num2str(i) + "_monomial"
		SetVariable $(variableName), win=$windowName, disable=1
		variableName = "svar_skew_" + num2str(i) + "_value"
		SetVariable $(variableName), win=$windowName, disable=1
	endfor

	for (i=0; i<nrRows; i=i+1)
		variableName = "svar_skew_" + num2str(i) + "_monomial"
		SetVariable $(variableName), win=$windowName, pos={20,(330+i*space)}, size={130,20}, title=" ", disable=0
		SetVariable $(variableName), win=$windowName, limits={0,inf,0}, value=multipoles[i][0]
		
		variableName = "svar_skew_" + num2str(i) + "_value"
		SetVariable $(variableName), win=$windowName, pos={170,(330+i*space)}, size={170,20}, title=" ", disable=0
		SetVariable $(variableName), win=$windowName, limits={-inf,inf,0}, value=multipoles[i][1]
		
	endfor

	return 0

End


Static Function UpdateSpecErrors([nrRows])
	variable nrRows

	variable i, space, prevNrRows
	string variableName, windowName

	WAVE multipoleErrors = root:wavesCAMTO:multipoleErrors

	windowName = "Spec"
	space = 20
	prevNrRows = DimSize(multipoleErrors, 0)
	
	if (!ParamIsDefault(nrRows))
		Redimension/N=(nrRows, 5) multipoleErrors
	else
		nrRows = prevNrRows
	endif

	for (i=0; i<prevNrRows; i=i+1)
		variableName = "svar_errors_" + num2str(i) + "_monomial"
		SetVariable $(variableName), win=$windowName, disable=1
		variableName = "svar_errors_" + num2str(i) + "_sys_normal"
		SetVariable $(variableName), win=$windowName, disable=1
		variableName = "svar_errors_" + num2str(i) + "_sys_skew"
		SetVariable $(variableName), win=$windowName, disable=1
		variableName = "svar_errors_" + num2str(i) + "_rnd_normal"
		SetVariable $(variableName), win=$windowName, disable=1
		variableName = "svar_errors_" + num2str(i) + "_rnd_skew"
		SetVariable $(variableName), win=$windowName, disable=1
	endfor

	for (i=0; i<nrRows; i=i+1)
		variableName = "svar_errors_" + num2str(i) + "_monomial"
		SetVariable $(variableName), win=$windowName, pos={20+380,(140+i*space)}, size={60,20}, title=" ", limits={0,inf,0}, disable=0
		SetVariable $(variableName), win=$windowName, value=multipoleErrors[i][0]
		
		variableName = "svar_errors_" + num2str(i) + "_sys_normal"
		SetVariable $(variableName), win=$windowName, pos={90+380,(140+i*space)}, size={60,20}, title=" ", limits={-inf,inf,0}, disable=0
		if (multipoleErrors[i][1] == 0)
			SetVariable $(variableName), win=$windowName, format="%1.0f"
		else
			SetVariable $(variableName), win=$windowName, format="% 2.1e"
		endif
		SetVariable $(variableName), win=$windowName, value=multipoleErrors[i][1], proc=CAMTO_Spec_SvarTableFormat
		
		variableName = "svar_errors_" + num2str(i) + "_sys_skew"
		SetVariable $(variableName), win=$windowName, pos={160+380,(140+i*space)}, size={60,20}, title=" ", limits={-inf,inf,0}, disable=0
		if (multipoleErrors[i][2] == 0)
			SetVariable $(variableName), win=$windowName, format="%1.0f"
		else
			SetVariable $(variableName), win=$windowName, format="% 2.1e"
		endif
		SetVariable $(variableName), win=$windowName, value=multipoleErrors[i][2], proc=CAMTO_Spec_SvarTableFormat
		
		variableName = "svar_errors_" + num2str(i) + "_rnd_normal"
		SetVariable $(variableName), win=$windowName, pos={230+380,(140+i*space)}, size={60,20}, title=" ", limits={-inf,inf,0}, disable=0
		if (multipoleErrors[i][3] == 0)
			SetVariable $(variableName), win=$windowName, format="%1.0f"
		else
			SetVariable $(variableName), win=$windowName, format="% 2.1e"
		endif
		SetVariable $(variableName), win=$windowName, value=multipoleErrors[i][3], proc=CAMTO_Spec_SvarTableFormat
		
		variableName = "svar_errors_" + num2str(i) + "_rnd_skew"
		SetVariable $(variableName), win=$windowName, pos={300+380,(140+i*space)}, size={60,20}, title=" ", limits={-inf,inf,0}, disable=0
		if (multipoleErrors[i][4] == 0)
			SetVariable $(variableName), win=$windowName, format="%1.0f"
		else
			SetVariable $(variableName), win=$windowName, format="% 2.1e"
		endif
		SetVariable $(variableName), win=$windowName, value=multipoleErrors[i][4], proc=CAMTO_Spec_SvarTableFormat
		
	endfor
	
	return 0

End


Static Function CalcResFieldSpec()

	NVAR r0 = root:varsCAMTO:SPEC_REFERENCE_RADIUS
	NVAR main = root:varsCAMTO:SPEC_MAIN_MULTIPOLE
	WAVE multipoleErrors = root:wavesCAMTO:multipoleErrors

	variable i	
	variable gridMin = -r0/1000
	variable gridMax = r0/1000
	variable gridNrPts = 101
	variable sizeNormalSys = 0
	variable sizeNormalRms = 0
	variable sizeSkewSys = 0
	variable sizeSkewRms = 0 
	variable size =	DimSize(multipoleErrors, 0)

	DFREF df = GetDataFolderDFR()
	
	SetDataFolder root:wavesCAMTO:
	
	Make/D/O/N=(gridNrPts) residualPos
	residualPos = gridMin + p*(gridMax - gridMin)/(gridNrPts-1)
	
	Make/O/N=(size) normalSysMonomials
	Make/D/O/N=(size) normalSysMultipoles
	Make/O/N=(size) normalRmsMonomials
	Make/D/O/N=(size) normalRmsMultipoles
	Make/O/N=(size) skewSysMonomials
	Make/D/O/N=(size) skewSysMultipoles
	Make/O/N=(size) skewRmsMonomials
	Make/D/O/N=(size) skewRmsMultipoles
	
	for (i=0; i<size; i=i+1)
	
		if (multipoleErrors[i][1] != 0)
			normalSysMonomials[sizeNormalSys] = multipoleErrors[i][0]
			normalSysMultipoles[sizeNormalSys] = multipoleErrors[i][1]
			sizeNormalSys += 1		
		endif

		if (multipoleErrors[i][2] != 0)
			skewSysMonomials[sizeSkewSys] = multipoleErrors[i][0]
			skewSysMultipoles[sizeSkewSys] = multipoleErrors[i][2]
			sizeSkewSys += 1		
		endif
		
		if (multipoleErrors[i][3] != 0)
			normalRmsMonomials[sizeNormalRms] = multipoleErrors[i][0]
			normalRmsMultipoles[sizeNormalRms] = multipoleErrors[i][3]
			sizeNormalRms += 1		
		endif	
	
		if (multipoleErrors[i][4] != 0)
			skewRmsMonomials[sizeSkewRms] = multipoleErrors[i][0]
			skewRmsMultipoles[sizeSkewRms] = multipoleErrors[i][4]
			sizeSkewRms += 1		
		endif
		
	endfor	
	
	Redimension/N=(sizeNormalSys) normalSysMonomials
	Redimension/N=(sizeNormalSys) normalSysMultipoles 
	Redimension/N=(sizeSkewSys) skewSysMonomials
	Redimension/N=(sizeSkewSys) skewSysMultipoles 
	Redimension/N=(sizeNormalRms) normalRmsMonomials
	Redimension/N=(sizeNormalRms) normalRmsMultipoles 
	Redimension/N=(sizeSkewRms) skewRmsMonomials
	Redimension/N=(sizeSkewRms) skewRmsMultipoles 	
		
	CalcResFieldSpecAux("Normal", main, r0, residualPos, normalSysMonomials, normalSysMultipoles, normalRmsMonomials, normalRmsMultipoles)
	
	CalcResFieldSpecAux("Skew", main, r0, residualPos, skewSysMonomials, skewSysMultipoles, skewRmsMonomials, skewRmsMultipoles)
	
	Killwaves/Z normalSysMonomials, normalSysMultipoles, normalRmsMonomials, normalRmsMultipoles
	Killwaves/Z skewSysMonomials, skewSysMultipoles, skewRmsMonomials, skewRmsMultipoles
	
	SetDataFolder df
	
	return 0
	
End


Static Function CalcResFieldSpecAux(component, main, r0, pos, sysMonomials, sysMultipoles, rmsMonomials, rmsMultipoles)
	string component
	variable main, r0
	WAVE pos, sysMonomials, sysMultipoles, rmsMonomials, rmsMultipoles

	variable i, j
	variable randomgauss, nm, size
	variable count = 0
	variable nr_samples = 5000
	variable gauss_trunc = 1
	variable nx = numpnts(pos)
	
	Make/D/O/N=(nx) sysResidue = 0
	Make/D/O/N=(nx) rmsResidue = 0
	Make/D/O/N=(nx) fieldResidue = 0
	
	for (i=0; i<numpnts(sysMonomials); i=i+1)
		sysResidue = sysResidue + sysMultipoles[i]*(pos/(r0/1000))^(sysMonomials[i]-main)
	endfor
	
	Duplicate/O sysResidue maxResidue 
	Duplicate/O sysResidue minResidue
	
	nm = numpnts(rmsMultipoles)
	size = nm*nr_samples
	
	if (size != 0)
		Make/D/O/N=(size) rndGrid = 0

		do
			randomgauss = gnoise(1)
			if (abs(randomgauss) <= gauss_trunc)
				rndGrid[count] = randomgauss
				count = count + 1
			endif
	   while (count < size)

		Redimension/N=(nr_samples, nm) rndGrid
	
		Make/D/O/N=(nm) rndVector
		Make/D/O/N=(nm) rndRelativeRms
	
	 	for (j=0; j< nr_samples;j=j+1)
	 		rndVector[] = rndGrid[j][p]
	 		rndRelativeRms = (rmsMultipoles)*rndVector
	 		
	 		rmsResidue = 0
	 		for (i=0; i< nm; i=i+1)
	 			rmsResidue = rmsResidue + rndRelativeRms[i]*(pos/(r0/1000))^(rmsMonomials[i]-main)
	 		endfor
	 		
	 		fieldResidue = sysResidue + rmsResidue
	 		
	 		maxResidue = Max(fieldResidue[p], maxResidue[p])
	 		minResidue = Min(fieldResidue[p], minResidue[p])
	 		
	 	endfor

	endif
  	
  	if (cmpstr(component, "Normal")==0)
  		Duplicate/O sysResidue residualNormalSys 
  		Duplicate/O maxResidue residualNormalMax 
  		Duplicate/O minResidue residualNormalMin
  	else
  		Duplicate/O sysResidue residualSkewSys
  		Duplicate/O maxResidue residualSkewMax 
  		Duplicate/O minResidue residualSkewMin
  	endif
 	
 	Killwaves/Z rndGrid, rndVector, rndRelativeRms
  	Killwaves/Z sysResidue, rmsResidue, fieldResidue, maxResidue, minResidue 

	return 0

End


Function CAMTO_Load_Panel() : Panel
	
	string windowName = "Load"
	string windowTitle = "Load Fieldmap"
	
	if (DataFolderExists("root:varsCAMTO")==0)
		DoAlert 1, "CAMTO variables not found. Initialize CAMTO?"
		if (V_flag == 1)
			CAMTO_Init()
		else
			return -1
		endif 
	endif
	
	DoWindow/K $windowName
	NewPanel/K=1/N=$windowName/W=(750,60,1190,605) as windowTitle
	SetDrawLayer UserBack
	
	variable m, h, h1, l1, l2 
	m = 20	
	h = 10
	h1 = 5	
	l1 = 5
	l2 = 435

	TitleBox tbxTitle1, pos={0,h}, size={430,25}, anchor=MT, fsize=18, fstyle=1, frame=0, title="Load Fieldmap"
	h += 35

	SetDrawEnv fillpat=0
	DrawRect l1,h1,l2,h-5
	h1 = h-5

	TitleBox tbxTitle2, pos={m,h+20}, size={80,40}, fsize=14, fstyle=1, frame=0, title="\t Select \r \tFolder"
	CheckBox chbAutomaticFolderName, pos={m+80,h}, size={120,20}, value=1, mode=1, proc=CAMTO_Load_ChbSelectFolder, title=" Automatic"
	h +=30

	CheckBox chbNewFolderName, pos={m+80,h}, size={120,20}, value=0, mode=1, proc=CAMTO_Load_ChbSelectFolder, title=" New Folder"
	SetVariable svarNewFolderName, pos={m+210,h}, size={170,20}, disable=1, value=root:varsCAMTO:FIELDMAP_NEW_FOLDER, title=" "
	h +=30
	
	CheckBox chbExistingFolderName, pos={m+80,h}, size={120,20}, value=0, mode=1, proc=CAMTO_Load_ChbSelectFolder, title=" Existing Folder"
	PopupMenu popupFieldmapFolder, pos={m+210,h-2}, size={170,20}, bodyWidth=150, mode=0, disable=1, proc=CAMTO_Load_PopupChangeDir, title=" "
	h += 30

	SetDrawEnv fillpat=0
	DrawRect l1,h1,l2,h-5
	h1 = h-5

	TitleBox tbxTitle3, pos={0,h}, size={440,20}, fsize=14, frame=0, fstyle=1, anchor=MC, title="Rename Selected Folder"
	h += 30
	
	SetVariable svarRename, pos={m,h}, size={290,20}, value=_STR:"", title="New Name"
	Button btnRename, pos={m+300,h-1}, size={80,20}, fstyle=1, proc=CAMTO_Load_BtnRename, title="Do it"
	h += 30
	
	SetDrawEnv fillpat=0
	DrawRect l1,h1,l2,h-5
	h1 = h-5

	TitleBox tbxTitle4, pos={0,h}, size={440,20}, fsize=14, frame=0, fstyle=1, anchor=MC, title="Fieldmap"
	h += 30

	PopupMenu popupBeamDirection, pos={m,h}, size={140,25}, mode=0, proc=CAMTO_Load_PopupBeamDirection, title="Beam Direction"
	PopupMenu popupBeamDirection, value=#"\"Y-Axis;Z-Axis\""
	PopupMenu popupStaticTransient, pos={m+220,h}, size={115,25}, mode=0, proc=CAMTO_Load_PopupStaticTransient, title="Data Type"
	PopupMenu popupStaticTransient, value=#"\"Static;Transient\""
	h += 30

	SetDrawEnv fillpat=0
	DrawRect l1,h1,l2,h-5
	h1 = h-5

	TitleBox tbxTitle5, pos={0,h}, size={440,20}, fsize=14, frame=0, fstyle=1, anchor=MC, title="Symmetries"
	h += 30

	CheckBox chbSymLongitudinal, pos={m,h}, size={170,20}, value=0, proc=CAMTO_Load_PopupSymLongitudinal, title=" Along Beam Direction"
	PopupMenu popupSymLongitudinalBC, pos={m+180,h-2}, size={160,20}, proc=CAMTO_Load_PopupSymLongitudinalBC, title="Boundary Condition"
	PopupMenu popupSymLongitudinalBC,  value=#"\"Normal;Tangential\"", mode=2
	h += 30

	CheckBox chbSymHorizontal, pos={m,h}, size={170,20}, value=0, proc=CAMTO_Load_PopupSymHorizontal, title=" Along Horizontal Direction"
	PopupMenu popupSymHorizontalBC, pos={m+180,h-2}, size={160,20}, proc=CAMTO_Load_PopupSymHorizontalBC, title="Boundary Condition At 90°"
	PopupMenu popupSymHorizontalBC, value=#"\"Normal;Tangential\"", mode=0
	h += 30

	SetDrawEnv fillpat=0
	DrawRect l1,h1,l2,h-5
	h1 = h-5

	TitleBox tbxTitleX, pos={m+30,h}, size={60,25}, fsize=20, frame=0, title="X - axis"
	TitleBox tbxTitleY, pos={m+170,h}, size={60,25}, fsize=20, frame=0, title="Y - axis"
	TitleBox tbxTitleZ, pos={m+310,h}, size={60,25}, fsize=20, frame=0, title="Z - axis"
	h += 40
	
	ValDisplay vdispStartX, pos={m,h}, size={110,20}, limits={0,0,0}, barmisc={0,1000}, title="Start"
	ValDisplay vdispStartY, pos={m+140,h}, size={110,20}, limits={0,0,0}, barmisc={0,1000}, title="Start"
	ValDisplay vdispStartZ, pos={m+280,h}, size={110,20}, limits={0,0,0}, barmisc={0,1000}, title="Start"
	h += 40
	
	ValDisplay vdispEndX, pos={m,h}, size={110,20}, limits={0,0,0}, barmisc={0,1000}, title="End"
	ValDisplay vdispEndY, pos={m+140,h}, size={110,20}, limits={0,0,0}, barmisc={0,1000}, title="End"
	ValDisplay vdispEndZ, pos={m+280,h}, size={110,20}, limits={0,0,0}, barmisc={0,1000}, title="End"
	h += 40
	
	ValDisplay vdispStepX, pos={m,h}, size={110,20}, limits={0,0,0}, barmisc={0,1000}, title="Step"
	ValDisplay vdispStepY, pos={m+140,h}, size={110,20}, limits={0,0,0}, barmisc={0,1000}, title="Step"
	ValDisplay vdispStepZ, pos={m+280,h}, size={110,20}, limits={0,0,0}, barmisc={0,1000}, title="Step"
	h += 40
	
	SetDrawEnv fillpat=0
	DrawRect l1,h1,l2/3,h-5
	SetDrawEnv fillpat=0
	DrawRect l2/3,h1,2*l2/3,h-5
	SetDrawEnv fillpat=0
	DrawRect 2*l2/3,h1,l2,h-5
	h1 = h-5

	Button btnLoad, pos={m,h}, size={190,30}, fsize=14, fstyle=1, proc=CAMTO_Load_BtnLoadFieldmap, title="Load Magnetic Field"
	Button btnClear, pos={m+210,h}, size={190,30}, fsize=14, fstyle=1, proc=CAMTO_Load_BtnClearFieldmap, title="Clear Field"
	h += 40

	SetDrawEnv fillpat=0
	DrawRect l1,h1,l2,h-5
	h1 = h-5
	
	UpdatePanelLoad()
	
	return 0
			
End


Static Function UpdatePanelLoad()

	SVAR df = root:varsCAMTO:FIELDMAP_FOLDER
	NVAR fieldmapCount = root:varsCAMTO:FIELDMAP_COUNT
	NVAR staticTransient = root:varsCAMTO:LOAD_STATIC_TRANSIENT
	NVAR beamDirection   = root:varsCAMTO:LOAD_BEAM_DIRECTION
	NVAR symmetryLongitudinal = root:varsCAMTO:LOAD_SYMMETRY_LONGITUDINAL
	NVAR symmetryLongitudinalBC = root:varsCAMTO:LOAD_SYMMETRY_LONGITUDINAL_BC
	NVAR symmetryHorizontal = root:varsCAMTO:LOAD_SYMMETRY_HORIZONTAL
	NVAR symmetryHorizontalBC = root:varsCAMTO:LOAD_SYMMETRY_HORIZONTAL_BC

	WAVE/T fieldmapFolders = root:wavesCAMTO:fieldmapFolders
	
	string windowName = "Load"

	if (WinType(windowName)==0)
		return -1
	endif
	
	if (fieldmapCount != 0)	
		CheckBox chbAutomaticFolderName, win=$windowName, value=0
		CheckBox chbNewFolderName, win=$windowName, value=0
		CheckBox chbExistingFolderName, win=$windowName, value=1, disable=0

		string fieldmapList = GetfieldmapFolders()
		PopupMenu popupFieldmapFolder, win=$windowName, value=#("\"" + fieldmapList + "\""), disable=0
		SetVariable svarNewFolderName, win=$windowName, disable=1
		SetVariable svarRename, win=$windowName, disable=0
		Button btnRename, win=$windowName, disable=0	
		Button btnClear, win=$windowName, disable=0
	
		if (strlen(df) > 0 && cmpstr(df, "_none_") != 0)
			FindValue/Text=df/TXOP=4 fieldmapFolders
			PopupMenu popupFieldmapFolder, win=$windowName, mode=(V_value+1)	
		endif
		
	else
		CheckBox chbAutomaticFolderName, win=$windowName, value=1
		CheckBox chbExistingFolderName, win=$windowName, value=0, disable=2
		CheckBox chbNewFolderName, win=$windowName, value=0
		PopupMenu popupFieldmapFolder, win=$windowName, mode=0, disable=1
		SetVariable svarNewFolderName, win=$windowName, disable=1
		SetVariable svarRename, win=$windowName, disable=2
		Button btnRename, win=$windowName, disable=2
		Button btnClear, win=$windowName, disable=2

	endif

	if (strlen(df) > 0 && cmpstr(df, "_none_")!=0)
		NVAR dataLoaded = root:$(df):varsFieldmap:DATA_LOADED
		NVAR localBeamDirection = root:$(df):varsFieldmap:LOAD_BEAM_DIRECTION
		NVAR localStaticTransient = root:$(df):varsFieldmap:LOAD_STATIC_TRANSIENT
		NVAR localSymmetryLongitudinal = root:$(df):varsFieldmap:LOAD_SYMMETRY_LONGITUDINAL
		NVAR localSymmetryLongitudinalBC = root:$(df):varsFieldmap:LOAD_SYMMETRY_LONGITUDINAL_BC
		NVAR localSymmetryHorizontal = root:$(df):varsFieldmap:LOAD_SYMMETRY_HORIZONTAL
		NVAR localSymmetryHorizontalBC = root:$(df):varsFieldmap:LOAD_SYMMETRY_HORIZONTAL_BC

		if (dataLoaded)
			localBeamDirection = localBeamDirection		
			staticTransient = localStaticTransient
			symmetryLongitudinal = localSymmetryLongitudinal
			symmetryLongitudinalBC = SymmetryLongitudinalBC
			symmetryHorizontal = localSymmetryHorizontal
			symmetryHorizontalBC = localSymmetryHorizontalBC
		endif

		ValDisplay vdispStartX, win=$windowName, value=#("root:" + df + ":varsFieldmap:LOAD_START_X" )
		ValDisplay vdispEndX, win=$windowName, value=#("root:" + df + ":varsFieldmap:LOAD_END_X")
		ValDisplay vdispStepX, win=$windowName, value=#("root:" + df + ":varsFieldmap:LOAD_STEP_X")
		ValDisplay vdispStartY, win=$windowName, value=#("root:" + df + ":varsFieldmap:LOAD_START_Y")
		ValDisplay vdispEndY, win=$windowName, value=#("root:" + df + ":varsFieldmap:LOAD_END_Y")
		ValDisplay vdispStepY, win=$windowName, value=#("root:" + df + ":varsFieldmap:LOAD_STEP_Y")
		ValDisplay vdispStartZ, win=$windowName, value=#("root:" + df + ":varsFieldmap:LOAD_START_Z")
		ValDisplay vdispEndZ, win=$windowName, value=#("root:" + df + ":varsFieldmap:LOAD_END_Z")
		ValDisplay vdispStepZ, win=$windowName, value=#("root:" + df + ":varsFieldmap:LOAD_STEP_Z")
	
		if (beamDirection == 1)
		 	TitleBox tbxTitleY, win=$windowName, disable=0
		 	ValDisplay vdispStartY, win=$windowName, disable=0
		 	ValDisplay vdispEndY, win=$windowName, disable=0
		 	ValDisplay vdispStepY, win=$windowName, disable=0
		 	TitleBox tbxTitleZ, win=$windowName, disable=2
		 	ValDisplay vdispStartZ, win=$windowName, disable=2
		 	ValDisplay vdispEndZ, win=$windowName, disable=2
		 	ValDisplay vdispStepZ, win=$windowName, disable=2
		
		else
		 	TitleBox tbxTitleY, win=$windowName, disable=2
		 	ValDisplay vdispStartY, win=$windowName, disable=2
		 	ValDisplay vdispEndY, win=$windowName, disable=2
		 	ValDisplay vdispStepY, win=$windowName, disable=2
		 	TitleBox tbxTitleZ, win=$windowName, disable=0	 
		 	ValDisplay vdispStartZ, win=$windowName, disable=0
		 	ValDisplay vdispEndZ, win=$windowName, disable=0
		 	ValDisplay vdispStepZ, win=$windowName, disable=0	
		
		endif

	else
		ValDisplay vdispStartX, win=$windowName, value=_NUM:0
		ValDisplay vdispEndX, win=$windowName, value=_NUM:0
		ValDisplay vdispStepX, win=$windowName, value=_NUM:1
		ValDisplay vdispStartY, win=$windowName, value=_NUM:0
		ValDisplay vdispEndY, win=$windowName, value=_NUM:0
		ValDisplay vdispStepY, win=$windowName, value=_NUM:1
		ValDisplay vdispStartZ, win=$windowName, value=_NUM:0
		ValDisplay vdispEndZ, win=$windowName, value=_NUM:0
		ValDisplay vdispStepZ, win=$windowName, value=_NUM:1
	endif
		
	PopupMenu popupStaticTransient, win=$windowName, mode=StaticTransient
	PopupMenu popupBeamDirection, win=$windowName, mode=BeamDirection

	CheckBox chbSymLongitudinal, win=$windowName, variable=symmetryLongitudinal
	CheckBox chbSymHorizontal, win=$windowName, variable=symmetryHorizontal
	
	if (symmetryLongitudinal)
		PopupMenu popupSymLongitudinalBC, win=$windowName, mode=symmetryLongitudinalBC, disable=0
	else
		PopupMenu popupSymLongitudinalBC, win=$windowName, mode=symmetryLongitudinalBC, disable=2
	endif
	
	if (symmetryHorizontal)
		PopupMenu popupSymHorizontalBC, win=$windowName, mode=symmetryHorizontalBC, disable=0
	else
		PopupMenu popupSymHorizontalBC, win=$windowName, mode=0, disable=2
	endif
	
	return 0

End


Function CAMTO_Load_ChbSelectFolder(ca) : CheckBoxControl
	STRUCT WMCheckboxAction& ca
	
	string fieldmapList

	switch(ca.eventCode)
		case 2:

			strswitch (ca.ctrlName)
				case "chbAutomaticFolderName":
					CheckBox chbAutomaticFolderName, win=$ca.win, value=1
					CheckBox chbNewFolderName, win=$ca.win, value=0
					CheckBox chbExistingFolderName, win=$ca.win, value=0
					SetVariable svarNewFolderName, win=$ca.win, disable=1
					PopupMenu popupFieldmapFolder, win=$ca.win, disable=1
					SetVariable svarRename, win=$ca.win, disable=2
					Button btnRename, win=$ca.win, disable=2
					Button btnClear, win=$ca.win, disable=2

					ValDisplay vdispStartX, win=$ca.win, value=_NUM:0
					ValDisplay vdispEndX, win=$ca.win, value=_NUM:0
					ValDisplay vdispStepX, win=$ca.win, value=_NUM:1
					ValDisplay vdispStartY, win=$ca.win, value=_NUM:0
					ValDisplay vdispEndY, win=$ca.win, value=_NUM:0
					ValDisplay vdispStepY, win=$ca.win, value=_NUM:1
					ValDisplay vdispStartZ, win=$ca.win, value=_NUM:0
					ValDisplay vdispEndZ, win=$ca.win, value=_NUM:0
					ValDisplay vdispStepZ, win=$ca.win, value=_NUM:1

					break
			
				case "chbNewFolderName":
					CheckBox chbAutomaticFolderName, win=$ca.win, value=0
					CheckBox chbExistingFolderName, win=$ca.win, value=0
					PopupMenu popupFieldmapFolder, win=$ca.win, disable=1
					SetVariable svarNewFolderName, win=$ca.win, disable=0
					SetVariable svarRename, win=$ca.win, disable=2
					Button btnRename, win=$ca.win, disable=2
					Button btnClear, win=$ca.win, disable=2

					ValDisplay vdispStartX, win=$ca.win, value=_NUM:0
					ValDisplay vdispEndX, win=$ca.win, value=_NUM:0
					ValDisplay vdispStepX, win=$ca.win, value=_NUM:1
					ValDisplay vdispStartY, win=$ca.win, value=_NUM:0
					ValDisplay vdispEndY, win=$ca.win, value=_NUM:0
					ValDisplay vdispStepY, win=$ca.win, value=_NUM:1
					ValDisplay vdispStartZ, win=$ca.win, value=_NUM:0
					ValDisplay vdispEndZ, win=$ca.win, value=_NUM:0
					ValDisplay vdispStepZ, win=$ca.win, value=_NUM:1

					break
				
				case "chbExistingFolderName":
					CheckBox chbAutomaticFolderName, win=$ca.win, value=0					
					CheckBox chbNewFolderName, win=$ca.win, value=0
					SetVariable svarNewFolderName, win=$ca.win, disable=1
					SetVariable svarRename, win=$ca.win, disable=0
					Button btnRename, win=$ca.win, disable=0
					Button btnClear, win=$ca.win, disable=0
	
					fieldmapList = GetfieldmapFolders()
					PopupMenu popupFieldmapFolder, win=$ca.win, disable=0, value=#("\"" + fieldmapList + "\"")
					
					UpdatePanelLoad()
						
					break
		
			endswitch

			break
	
	endswitch

	return 0

End


Function CAMTO_Load_PopupChangeDir(pa) : PopupMenuControl
	struct WMPopupAction &pa

	SVAR fieldmapFolder= root:varsCAMTO:FIELDMAP_FOLDER
	WAVE/T fieldmapFolders= root:wavesCAMTO:fieldmapFolders

	switch(pa.eventCode)
		case 2:
			UpdateFieldmapFolders()
			
			FindValue/Text=pa.popStr/TXOP=4 fieldmapFolders
			
			if (strlen(pa.popStr) > 0 && V_Value!=-1)
				fieldmapFolder = pa.popStr
				SetDataFolder root:$(fieldmapFolder)
				PopupMenu popupFieldmapFolder, win=$pa.win, mode=pa.popNum
			endif
			
			UpdatePanels()
		
			break
	
	endswitch

	return 0

End


Function CAMTO_Load_PopupBeamDirection(pa) : PopupMenuControl
	struct WMPopupAction &pa

	NVAR beamDirection = root:varsCAMTO:LOAD_BEAM_DIRECTION

	switch(pa.eventCode)
		case 2:
			
			beamDirection = pa.popNum
			
			if (pa.popNum == 1)
			 	TitleBox tbxTitleY, win=$pa.win, disable=0
			 	ValDisplay vdispStartY, win=$pa.win, disable=0
			 	ValDisplay vdispEndY, win=$pa.win, disable=0
			 	ValDisplay vdispStepY, win=$pa.win, disable=0
			 	TitleBox tbxTitleZ, win=$pa.win, disable=2
			 	ValDisplay vdispStartZ, win=$pa.win, disable=2
			 	ValDisplay vdispEndZ, win=$pa.win, disable=2
			 	ValDisplay vdispStepZ, win=$pa.win, disable=2
			
			else
			 	TitleBox tbxTitleY, win=$pa.win, disable=2
			 	ValDisplay vdispStartY, win=$pa.win, disable=2
			 	ValDisplay vdispEndY, win=$pa.win, disable=2
			 	ValDisplay vdispStepY, win=$pa.win, disable=2
			 	TitleBox tbxTitleZ, win=$pa.win, disable=0	 
			 	ValDisplay vdispStartZ, win=$pa.win, disable=0
			 	ValDisplay vdispEndZ, win=$pa.win, disable=0
			 	ValDisplay vdispStepZ, win=$pa.win, disable=0	
			endif
			
			PopupMenu popupBeamDirection, win=$pa.win, mode=pa.popNum

			break
	
	endswitch

	return 0
	
End


Function CAMTO_Load_PopupStaticTransient(pa) : PopupMenuControl
	struct WMPopupAction &pa

	NVAR staticTransient = root:varsCAMTO:LOAD_STATIC_TRANSIENT

	switch(pa.eventCode)
		case 2:				 
			staticTransient = pa.popNum
			PopupMenu popupStaticTransient, win=$pa.win, mode=pa.popNum

			break
	
	endswitch

	return 0

End


Function CAMTO_Load_PopupSymLongitudinal(ca) : CheckBoxControl
	STRUCT WMCheckboxAction& ca
	
	switch(ca.eventCode)
		case 2:
			if (ca.checked)
				PopupMenu popupSymLongitudinalBC, win=$ca.win, disable=0			
			else
				PopupMenu popupSymLongitudinalBC, win=$ca.win, disable=2
			endif

			break
	
	endswitch

	return 0

End


Function CAMTO_Load_PopupSymHorizontal(ca) : CheckBoxControl
	STRUCT WMCheckboxAction& ca
	
	switch(ca.eventCode)
		case 2:
			if (ca.checked)
				PopupMenu popupSymHorizontalBC, win=$ca.win, disable=0
			else
				PopupMenu popupSymHorizontalBC, win=$ca.win, disable=2
			endif

			break
	
	endswitch

	return 0

End


Function CAMTO_Load_PopupSymLongitudinalBC(pa) : PopupMenuControl
	struct WMPopupAction &pa

	NVAR symLongitudinalBC = root:varsCAMTO:LOAD_SYMMETRY_LONGITUDINAL_BC

	switch(pa.eventCode)
		case 2:					 
			symLongitudinalBC = pa.popNum
			PopupMenu popupSymLongitudinalBC, win=$pa.win, mode=pa.popNum

			break
	
	endswitch

	return 0

End


Function CAMTO_Load_PopupSymHorizontalBC(pa) : PopupMenuControl
	struct WMPopupAction &pa

	NVAR symHorizontalBC = root:varsCAMTO:LOAD_SYMMETRY_HORIZONTAL_BC

	switch(pa.eventCode)
		case 2:
				 
			symHorizontalBC = pa.popNum
			PopupMenu popupSymHorizontalBC, win=$pa.win, mode=pa.popNum

			break
	
	endswitch

	return 0

End


Function CAMTO_Load_BtnRename(ba) : ButtonControl
	struct WMButtonAction &ba
	
	SVAR fieldmapFolder = root:varsCAMTO:FIELDMAP_FOLDER
	WAVE/T fieldmapFolders = root:wavesCAMTO:fieldmapFolders
	
	variable index
	string newName
	
	switch(ba.eventCode)
		case 2:
			ControlInfo/W=$ba.win svarRename
			newName = S_Value
			if (IsValidFolderName(newName) == -1)
				DoAlert 0,"Invalid folder name"
				return -1				
			endif
		
			FindValue/Text=fieldmapFolder/TXOP=4 fieldmapFolders
			index = V_Value
			if (index == -1)			
				return -1
			else
				RenameDataFolder root:$(fieldmapFolder), $(newName)
				fieldmapFolders[index] = newName
				fieldmapFolder = newName
			endif		

			UpdatePanels()
			
			break
	endswitch
	
	return 0
End


Function CAMTO_Load_BtnLoadFieldmap(ba) : ButtonControl
	struct WMButtonAction &ba
	
	SVAR fieldmapNewFolder = root:varsCAMTO:FIELDMAP_NEW_FOLDER
	
	variable refNum, i
	string filename, outputPaths, message, defaultFolderName
		
	switch(ba.eventCode)
		case 2:		

			UpdateFieldmapFolders()
			
			ControlInfo/W=$ba.win chbAutomaticFolderName
			if (V_Value)
				message = "Select fieldmap files"
			
				Open/D/R/MULT=1/M=message refNum
				outputPaths = S_fileName
	
				if (strlen(outputPaths) == 0)
					return 0
				endif
	
				for(i=0; i<ItemsInList(outputPaths, "\r"); i+=1)
					filename = StringFromList(i, outputPaths, "\r")
					defaultFolderName = GetDefaultFieldmapFolderName(filename)
					CreateFieldmapFolder(defaultFolderName, replace=1)
					LoadFieldmap(filename=filename, overwrite=1)
				endfor	
			
			else
				ControlInfo/W=$ba.win chbNewFolderName
				if (V_Value)	
					if (IsValidFolderName(fieldmapNewFolder) == -1)
						DoAlert 0,"Invalid folder name"
						return -1				
					endif
					CreateFieldmapFolder(fieldmapNewFolder, replace=0)
				endif
				
				filename = ""
				LoadFieldmap(filename=filename, overwrite=0)

			endif
					
			UpdatePanels()
			
			break
	endswitch
	
	return 0
End


Function CAMTO_Load_BtnClearFieldmap(ba) : ButtonControl
	struct WMButtonAction &ba

	NVAR beamDirection = root:varsCAMTO:LOAD_BEAM_DIRECTION
	NVAR staticTransient = root:varsCAMTO:LOAD_STATIC_TRANSIENT
	NVAR symmetryLongitudinal = root:varsCAMTO:LOAD_SYMMETRY_LONGITUDINAL
	NVAR symmetryHorizontal = root:varsCAMTO:LOAD_SYMMETRY_HORIZONTAL
	NVAR symmetryLongitudinalBC = root:varsCAMTO:LOAD_SYMMETRY_LONGITUDINAL_BC
	NVAR symmetryHorizontalBC = root:varsCAMTO:LOAD_SYMMETRY_HORIZONTAL_BC
	
	switch(ba.eventCode)
		case 2:		
			if (IsCorrectFolder() == -1)
				return -1
			endif

			beamDirection = 2
			staticTransient = 1
			symmetryLongitudinal = 0
			symmetryHorizontal = 0
			symmetryLongitudinalBC = 2
			symmetryHorizontalBC = 1 

			InitializeFieldmapVariables()	
			UpdatePanels()
			
			break
	endswitch
	
	return 0
End


Static Function CreateFieldmapFolder(folderName, [replace])
	string folderName
	variable replace
	
	if (ParamIsDefault(replace))
		replace = 0
	endif

	SVAR fieldmapFolder = root:varsCAMTO:FIELDMAP_FOLDER
	NVAR fieldmapCount = root:varsCAMTO:FIELDMAP_COUNT
	WAVE/T fieldmapFolders = root:wavesCAMTO:fieldmapFolders

	SetDataFolder root:
		
	FindValue/Text=folderName/TXOP=4 fieldmapFolders		
	
	fieldmapFolder = folderName	
	
	if (V_value == -1)			
		fieldmapCount = fieldmapCount + 1
		Redimension/N=(fieldmapCount) fieldmapFolders
		fieldmapFolders[fieldmapCount-1] = fieldmapFolder
		NewDataFolder/O/S  $fieldmapFolder
	
	else
		SetDataFolder $fieldmapFolder
		if (!replace)
			DoAlert 1, "Replace data folder?"
			if (V_flag == 2)
				return 0	 
			endif
		endif
	
	endif

	InitializeFieldmapVariables()	
	
	return 0

End


Static Function IsValidFolderName(folderName)
	string folderName

	if (strlen(folderName) == 0)
		return -1
		
	elseif (strsearch(folderName, "-",0)!=-1 || strsearch(folderName, ".",0)!=-1 || strsearch(folderName, ":",0)!=-1)
		return -1
		
	elseif (strsearch(folderName, "/",0)!=-1 || strsearch(folderName, "\\",0)!=-1 || strsearch(folderName, "|",0)!=-1 )
		return -1
		
	elseif (GrepString(folderName[0],"[[:alpha:]]") == 0)
		return -1
	
	else
		return 1
	
	endif	

End


Static Function/S GetFieldmapFolders()
	NVAR fieldmapCount = root:varsCAMTO:FIELDMAP_COUNT 
	WAVE/T fieldmapFolders = root:wavesCAMTO:fieldmapFolders
	
	UpdateFieldmapFolders()
	string fieldmaps = ""
	variable i	
	for (i=0; i<fieldmapCount; i=i+1)
		fieldmaps = fieldmaps + fieldmapFolders[i] + ";"
	endfor 
			
	return fieldmaps
End 


Static Function UpdatePanels()
	UpdatePanelLoad()
	UpdatePanelExport()
	UpdatePanelViewField()
	UpdatePanelTraj()
	UpdatePanelResults()
//	UpdateHallProbePanel()
//	UpdateIntegralsMultipolesPanel()
//	UpdateDynMultipolesPanel()
//	UpdateFindPeaksPanel()
//	UpdateCompareResultsPanel()
	UpdatePanelPeaks()
//	UpdatePhaseErrorPanel()

	return 0
End


Static Function IsCorrectFolder()
	
	string currentDf = GetDataFolder(0)
	
	SVAR df = root:varsCAMTO:FIELDMAP_FOLDER
	
	variable dfFound = 1 
	
	if (cmpstr(currentDf, df)!=0)
		DoAlert 1,"Change current data folder?"
		if (V_flag==1)
			if (strlen(df) == 0)
				DoAlert 0,"Data folder not found."
				dfFound = -1 
			else
				SetDataFolder root:$df
			endif		
		else
			dfFound = -1 
		endif
	endif
		
	return dfFound

End


Static Function InitializeFieldmapVariables()
	
	SVAR df = root:varsCAMTO:FIELDMAP_FOLDER 
	
	SetDataFolder root:$df	
	
	Killvariables/A/Z
	KillStrings/A/Z
	KillWaves/A/Z
	
	KillDataFolder/Z varsFieldmap
	NewDataFolder/O/S  varsFieldmap
       
	Killvariables/A/Z
	KillStrings/A/Z
	
	string/G FIELDMAP_FILENAME = ""
	string/G FIELDMAP_FILEPATH = ""
	
	variable/G DATA_LOADED = 0
	variable/G IRREGULAR_GRID = 0
	
	variable/G LOAD_TIME_INSTANT = 0
	variable/G LOAD_BEAM_DIRECTION
	variable/G LOAD_STATIC_TRANSIENT
	variable/G LOAD_SYMMETRY_LONGITUDINAL
	variable/G LOAD_SYMMETRY_HORIZONTAL
	variable/G LOAD_SYMMETRY_LONGITUDINAL_BC
	variable/G LOAD_SYMMETRY_HORIZONTAL_BC
	
	variable/G LOAD_START_X = 0
	variable/G LOAD_END_X = 0
	variable/G LOAD_STEP_X = 1
	variable/G LOAD_NPTS_X = 1	

	variable/G LOAD_START_Y = 0
	variable/G LOAD_END_Y = 0
	variable/G LOAD_STEP_Y = 1
	variable/G LOAD_NPTS_Y = 1	
	
	variable/G LOAD_START_Z = 0
	variable/G LOAD_END_Z = 0
	variable/G LOAD_STEP_Z = 1
	variable/G LOAD_NPTS_Z = 1

	variable/G LOAD_START_L = 0
	variable/G LOAD_END_L = 0
	variable/G LOAD_STEP_L = 1
	variable/G LOAD_NPTS_L = 1

	variable/G EXPORT_BX = 1
	variable/G EXPORT_BY = 1
	variable/G EXPORT_BZ = 1

	variable/G EXPORT_START_X = 0
	variable/G EXPORT_END_X = 0
	variable/G EXPORT_STEP_X = 1	

	variable/G EXPORT_START_Y = 0
	variable/G EXPORT_END_Y = 0
	variable/G EXPORT_STEP_Y = 1
	
	variable/G EXPORT_START_Z = 0
	variable/G EXPORT_END_Z = 0
	variable/G EXPORT_STEP_Z = 1

	variable/G FIELD_X
	variable/G FIELD_Y
	variable/G FIELD_Z

	variable/G INDEX_X
	variable/G INDEX_L

	variable/G VIEW_POS_X
	variable/G VIEW_POS_L
	variable/G VIEW_PLOT_X
	variable/G VIEW_PLOT_START_X
	variable/G VIEW_PLOT_END_X
	variable/G VIEW_PLOT_STEP_X
	variable/G VIEW_PLOT_L
	variable/G VIEW_FIELD_X
	variable/G VIEW_FIELD_Y
	variable/G VIEW_FIELD_Z
	variable/G VIEW_HOM_X
	variable/G VIEW_HOM_Y
	variable/G VIEW_HOM_Z
	variable/G VIEW_APPEND_FIELD = 0

	variable/G TRAJ_PARTICLE_ENERGY = 3.0	// [GeV]
	variable/G TRAJ_CALC_METHOD = 2 // 1: Analytical, 2: Runge-Kutta
	variable/G TRAJ_SINGLE_MULTI = 1 // 1: Single Particle, 2: Multi Particle
	variable/G TRAJ_IGNORE_OUT_MATRIX = 1
	variable/G TRAJ_OUT_MATRIX_ERROR = 0
	variable/G TRAJ_NEGATIVE_DIRECTION = 0
	variable/G TRAJ_START_X
	variable/G TRAJ_END_X
	variable/G TRAJ_STEP_X
	variable/G TRAJ_START_L
	variable/G TRAJ_END_L
	variable/G TRAJ_HORIZONTAL_ANGLE
	variable/G TRAJ_VERTICAL_ANGLE
	
	string/G   PEAK_FIELD_AXIS_STR = "By"
	variable/G PEAK_FIELD_AXIS = 2
	variable/G PEAK_POS_NEG = 3 
	variable/G PEAK_PEAKS_AMPL = 5
	variable/G PEAK_ZEROS_AMPL = 5
	variable/G PEAK_AVG_PERIOD_PEAKS = 0
	variable/G PEAK_AVG_PERIOD_ZEROS = 0
	variable/G PEAK_SELECTED = 0
	
	variable/G PEAK_START_YZ
	variable/G PEAK_END_YZ
	variable/G PEAK_STEP_YZ
	variable/G PEAK_START_X
	variable/G PEAK_END_X
	variable/G PEAK_STEP_X
	variable/G PEAK_NPOINTS_YZ = 1
	variable/G PEAK_POS_X_AUX = 0

//	variable/G StartYZ = 0
//	variable/G EndYZ = 0
//	variable/G StepsYZ = 1
//	variable/G NPointsYZ = 1		
//	
//	variable/G StartXTraj = 0
//	variable/G EndXTraj = 0
//	variable/G StepsXTraj = 1
//	variable/G NPointsXTraj = 1		
//	
//	variable/G StartYZTraj = 0	
//	variable/G EndYZTraj = 0	
//
//	variable/G FieldX
//	variable/G FieldY	
//	variable/G FieldZ
//	
//	variable/G FittingOrder = 15
//	variable/G Distcenter = 10
//	variable/G GridMin 
//	variable/G GridMax 
//	variable/G KNorm = 1
//	variable/G NormComponent = 1
//	string/G   NormalCoefs = "000000000000000"
//	string/G   SkewCoefs = "000000000000000"
//	string/G   ResNormalCoefs = "000000000000000"
//	string/G   ResSkewCoefs = "000000000000000"
//	
//	variable/G FittingOrderTraj = 15
//	variable/G DistcenterTraj = 10
//	variable/G GridMinTraj = -10
//	variable/G GridMaxTraj = 10
//	variable/G GridNrptsTraj = 101
//	variable/G MultipolesTrajShift = 0.001 
//	variable/G DynKNorm = 1
//	variable/G DynNormComponent = 1
//	string/G   DynNormalCoefs = "000000000000000"
//	string/G   DynSkewCoefs = "000000000000000"
//	string/G 	 DynResNormalCoefs = "000000000000000"
//	string/G 	 DynResSkewCoefs = "000000000000000"
//
//	variable/G MultipoleK = 0
//	variable/G DynMultipoleK = 0
//			
//	variable/G PosLongitudinal = 0 	            
//	variable/G PosTransversal = 0
//	variable/G EntranceAngle = 0	
//	
//	variable/G Single_Multi = 1		
//	
//	variable/G iTraj
//	variable/G iTrajError
//
//	variable/G iX = 0
//	variable/G iYZ = 0
//
//	variable/G Checkfield = 1
//	variable/G CheckNegPosTraj = 0
//	
//	variable/G Out_of_Matrix_Error = 0
//	
//	variable/G PosXAux = 0
//	variable/G PosYZAux = 0		
//
//	variable/G FieldXAux = 0
//	variable/G FieldYAux = 0
//	variable/G FieldZAux = 0			
//
//	variable/G StartXHom = 0
//	variable/G EndXHom = 0
//	variable/G PosYZHom = 0	
//
//	variable/G HomogX = 0
//	variable/G HomogY = 0
//	variable/G HomogZ = 0	
//	
//	variable/G ErrAngXZ = 0	
//	variable/G ErrAngYZ = 0
//	variable/G ErrAngXY = 0
//	variable/G ErrAng = 0	
//	
//	variable/G ErrDisplacementX = 0
//	variable/G ErrDisplacementYZ = 0
//	variable/G ErrDisplacement = 0	
//	
//	variable/G Analitico_RungeKutta = 2
//	
//	variable/G GraphAppend = 1
//	variable/G AddReferenceLines = 0
//
//	string/G   FieldAxisPeakStr = "By"
//	variable/G FieldAxisPeak = 2
//	variable/G PeaksPosNeg = 3 
//	variable/G NAmplPeaks = 5
//	variable/G NAmplZeros = 5
//	variable/G StepsYZPeaks = 1
//	variable/G AvgPeriodPeaks = 0
//	variable/G AvgPeriodZeros = 0
//	variable/G PeaksSelected = 0
//
//	variable/G SemiPeriodsPeaksZeros = 2	
//	variable/G PeriodPeaksZerosNominal = 1
//	variable/G IDPeriodNominal = 0
//	variable/G IDPeriod = 0
//	variable/G IDCutPeriods = 0
//	variable/G IDPhaseError = inf
//	
//	variable/G IDFirstIntegral = inf
//	variable/G IDSecondIntegral = inf
	
	SetDataFolder root:$df	
	
	return 0

End


Static Function/S GetDefaultFieldmapFolderName(filename)
	string filename
	
	WAVE/T fieldmapFolders = root:wavesCAMTO:fieldmapFolders
	
	string folderName = "Fieldmap"
	variable index = 0
	
	SplitString/E="ID=([[:digit:]]+)" filename
	if (strlen(S_value) != 0)
		folderName = ReplaceString("=", S_value, "_")
	else
		do
			index += 1
			FindValue/Text=(folderName + "_" + num2str(index))/TXOP=4 fieldmapFolders
		while(V_value != -1 && index < 100)
	
		folderName = folderName + "_" + num2str(index)
		
	endif

	return folderName

End


Static Function GetFieldmapIndex()

	SVAR fieldmapFolder = root:varsCAMTO:FIELDMAP_FOLDER
	WAVE/T fieldmapFolders = root:wavesCAMTO:fieldmapFolders

	FindValue/Text=fieldmapFolder/TXOP=4 fieldmapFolders		
			
	if (V_value == -1)			
		return -1
	else
		return V_value
	endif

End


Static Function SaveFieldmapHeader()

	SVAR fieldmapFilename = :varsFieldmap:FIELDMAP_FILENAME
	SVAR fieldmapFilepath = :varsFieldmap:FIELDMAP_FILEPATH
	
	Make/O/T/N=0 headerLines
	
	NewPath/O/Z symPath fieldmapFilepath
	
	variable refNum, count
	string str, strv
	
	Open/R/P=symPath refNum as fieldmapFilename

	count = 0
	do
		FReadLine refNum, str
		if (count == 0)
			SplitString/E="[[:alpha:]]" str[0]
			if(!cmpstr(S_value, ""))
				break
			endif
		endif
		
		if (strsearch(str, "---------", 0) != -1 || strlen(str) == 0)
			break
		endif	
		
		Redimension/N=(count+1) headerLines
		headerLines[count] = str[0, strlen(str)-2]
		count = count + 1
	
	while (count < 100)
	
	Redimension/N=(count-1) headerLines
	
	Close/A 
	
	return 0

End


Static Function UpdatePositionVariables()
	
	UpdatePositionVariablesExport()
	UpdatePositionVariablesViewField()
	UpdatePositionVariablesTraj()
	UpdatePositionVariablesPeak()

//	NVAR GridMin     = :varsFieldmap:GridMin
//	NVAR GridMax 	 = :varsFieldmap:GridMax
//	NVAR StartYZTraj = :varsFieldmap:StartYZTraj
//	NVAR EndYZTraj   = :varsFieldmap:EndYZTraj 
//	
//	NVAR StepsYZ      = :varsFieldmap:StepsYZ
//	NVAR StepsYZPeaks = :varsFieldmap:StepsYZPeaks 
//	
//	GridMin = StartX
//	GridMax = EndX
//	StartYZTraj = StartYZ
//	EndYZTraj   = EndYZ
//	StepsYZPeaks = StepsYZ

	return 0
	
End


Static Function UpdatePositionVariablesExport()
	NVAR startX = :varsFieldmap:LOAD_START_X
	NVAR endX = :varsFieldmap:LOAD_END_X
	NVAR stepX = :varsFieldmap:LOAD_STEP_X

	NVAR startY = :varsFieldmap:LOAD_START_Y
	NVAR endY = :varsFieldmap:LOAD_END_Y
	NVAR stepY = :varsFieldmap:LOAD_STEP_Y

	NVAR startZ = :varsFieldmap:LOAD_START_Z
	NVAR endZ = :varsFieldmap:LOAD_END_Z
	NVAR stepZ = :varsFieldmap:LOAD_STEP_Z

	NVAR exportStartX = :varsFieldmap:EXPORT_START_X
	NVAR exportEndX = :varsFieldmap:EXPORT_END_X
	NVAR exportStepX = :varsFieldmap:EXPORT_STEP_X

	NVAR exportStartY = :varsFieldmap:EXPORT_START_Y
	NVAR exportEndY = :varsFieldmap:EXPORT_END_Y
	NVAR exportStepY = :varsFieldmap:EXPORT_STEP_Y

	NVAR exportStartZ = :varsFieldmap:EXPORT_START_Z
	NVAR exportEndZ = :varsFieldmap:EXPORT_END_Z
	NVAR exportStepZ = :varsFieldmap:EXPORT_STEP_Z

	exportStartX = startX
	exportEndX = endX
	exportStepX = stepX
	
	exportStartY = startY
	exportEndY = endY
	exportStepY = stepY

	exportStartZ = startZ
	exportEndZ = endZ
	exportStepZ = stepZ	
	
	return 0
	
End 


Static Function UpdatePositionVariablesViewField()
	NVAR tol = root:varsCAMTO:POSITION_TOLERANCE
	
	NVAR startX = :varsFieldmap:LOAD_START_X
	NVAR endX = :varsFieldmap:LOAD_END_X
	NVAR stepX = :varsFieldmap:LOAD_STEP_X

	NVAR viewposX = :varsFieldmap:VIEW_POS_X
	NVAR viewposL = :varsFieldmap:VIEW_POS_L
	NVAR plotX = :varsFieldmap:VIEW_PLOT_X
	NVAR plotL = :varsFieldmap:VIEW_PLOT_L
	NVAR plotStartX = :varsFieldmap:VIEW_PLOT_START_X
	NVAR plotEndX = :varsFieldmap:VIEW_PLOT_END_X
	NVAR plotStepX = :varsFieldmap:VIEW_PLOT_STEP_X
	
	WAVE posX, posL

	plotStartX = startX
	plotEndX = endX
	plotStepX = stepX
	
	FindValue/T=(tol)/V=0 posX
	if (V_Value != -1)
		viewposX = 0
		plotX = 0
	endif

	FindValue/T=(tol)/V=0 posL
	if (V_Value != -1)
		viewposL = 0
		plotL = 0
	endif

	return 0
	
End 


Static Function UpdatePositionVariablesTraj()
	NVAR tol = root:varsCAMTO:POSITION_TOLERANCE
	
	NVAR startX = :varsFieldmap:LOAD_START_X
	NVAR endX = :varsFieldmap:LOAD_END_X
	NVAR stepX = :varsFieldmap:LOAD_STEP_X
	NVAR startL = :varsFieldmap:LOAD_START_L
	NVAR endL = :varsFieldmap:LOAD_END_L

	NVAR trajStartX = :varsFieldmap:TRAJ_START_X
	NVAR trajEndX = :varsFieldmap:TRAJ_END_X
	NVAR trajStepX = :varsFieldmap:TRAJ_STEP_X
	NVAR trajStartL = :varsFieldmap:TRAJ_START_L
	NVAR trajEndL = :varsFieldmap:TRAJ_END_L

	WAVE posX

	trajStartX = startX
	trajEndX = endX
	trajStepX = stepX
	trajStartL = startL
	trajEndL = endL

	FindValue/T=(tol)/V=0 posX
	if (V_Value != -1)
		trajStartX = 0
	endif

	return 0
	
End 

Static Function UpdatePositionVariablesPeak()
	NVAR tol = root:varsCAMTO:POSITION_TOLERANCE
	
	NVAR startX = :varsFieldmap:LOAD_START_X
	NVAR endX = :varsFieldmap:LOAD_END_X
	NVAR stepX = :varsFieldmap:LOAD_STEP_X
	NVAR startL = :varsFieldmap:LOAD_START_L
	NVAR endL = :varsFieldmap:LOAD_END_L

	NVAR peakStartX = :varsFieldmap:PEAK_START_X
	NVAR peakEndX = :varsFieldmap:PEAK_END_X
	NVAR peakStepX = :varsFieldmap:PEAK_STEP_X
	NVAR peakStartL = :varsFieldmap:PEAK_START_YZ
	NVAR peakEndL = :varsFieldmap:PEAK_END_YZ

	WAVE posX

	peakStartX = startX
	peakEndX = endX
	peakStepX = stepX
	peakStartL = startL
	peakEndL = endL

	FindValue/T=(tol)/V=0 posX
	if (V_Value != -1)
		peakStartX = 0
	endif

	return 0
	
End


Static Function LoadFieldmap([filename, overwrite])
	string filename
	variable overwrite

	if (ParamIsDefault(filename))
		filename = ""
	endif

	if (ParamIsDefault(overwrite))
		overwrite = 0
	endif

	NVAR tol = root:varsCAMTO:POSITION_TOLERANCE
	NVAR beamDirection = root:varsCAMTO:LOAD_BEAM_DIRECTION
	NVAR staticTransient = root:varsCAMTO:LOAD_STATIC_TRANSIENT
	NVAR symmetryLongitudinal = root:varsCAMTO:LOAD_SYMMETRY_LONGITUDINAL
	NVAR symmetryHorizontal = root:varsCAMTO:LOAD_SYMMETRY_HORIZONTAL
	NVAR symmetryLongitudinalBC = root:varsCAMTO:LOAD_SYMMETRY_LONGITUDINAL_BC
	NVAR symmetryHorizontalBC = root:varsCAMTO:LOAD_SYMMETRY_HORIZONTAL_BC

	SVAR fieldmapFilename = :varsFieldmap:FIELDMAP_FILENAME
	SVAR fieldmapFilepath = :varsFieldmap:FIELDMAP_FILEPATH

	NVAR dataLoaded = :varsFieldmap:DATA_LOADED
	NVAR irregularGrid = :varsFieldmap:IRREGULAR_GRID
	NVAR timeInstant = :varsFieldmap:LOAD_TIME_INSTANT	
	NVAR localBeamDirection = :varsFieldmap:LOAD_BEAM_DIRECTION
	NVAR localStaticTransient = :varsFieldmap:LOAD_STATIC_TRANSIENT
	NVAR localSymmetryLongitudinal = :varsFieldmap:LOAD_SYMMETRY_LONGITUDINAL
	NVAR localSymmetryLongitudinalBC = :varsFieldmap:LOAD_SYMMETRY_LONGITUDINAL_BC
	NVAR localSymmetryHorizontal = :varsFieldmap:LOAD_SYMMETRY_HORIZONTAL
	NVAR localSymmetryHorizontalBC = :varsFieldmap:LOAD_SYMMETRY_HORIZONTAL_BC

	NVAR startX = :varsFieldmap:LOAD_START_X
	NVAR endX = :varsFieldmap:LOAD_END_X
	NVAR stepX = :varsFieldmap:LOAD_STEP_X
	NVAR nptsX = :varsFieldmap:LOAD_NPTS_X

	NVAR startY = :varsFieldmap:LOAD_START_Y
	NVAR endY = :varsFieldmap:LOAD_END_Y
	NVAR stepY = :varsFieldmap:LOAD_STEP_Y
	NVAR nptsY = :varsFieldmap:LOAD_NPTS_Y

	NVAR startZ = :varsFieldmap:LOAD_START_Z
	NVAR endZ = :varsFieldmap:LOAD_END_Z
	NVAR stepZ = :varsFieldmap:LOAD_STEP_Z
	NVAR nptsZ = :varsFieldmap:LOAD_NPTS_Z

	NVAR startL = :varsFieldmap:LOAD_START_L
	NVAR endL = :varsFieldmap:LOAD_END_L
	NVAR stepL = :varsFieldmap:LOAD_STEP_L
	NVAR nptsL = :varsFieldmap:LOAD_NPTS_L

	variable i
	variable symmetryBxL, symmetryByL, symmetryBzL
	variable symmetryBxX, symmetryByX, symmetryBzX
	string waveStr, waveStrAux, posXStr

	if (IsCorrectFolder() == -1)
		return -1
	endif

	if (dataLoaded)
		if (!overwrite)
			DoAlert 1, "Overwrite fieldmap?" 
			if (V_flag == 2)
				return -1
			endif
		endif

		Killvariables/A/Z
		KillStrings/A/Z
		KillWaves/A/Z

	endif

	localStaticTransient = staticTransient
	localBeamDirection = beamDirection
	localSymmetryLongitudinal = symmetryLongitudinal
	localSymmetryLongitudinalBC = symmetryLongitudinalBC
	localSymmetryHorizontal = symmetryHorizontal
	localSymmetryHorizontalBC = symmetryHorizontalBC
	
	LoadWave/H/O/G/D/W/A filename

	if (V_flag==0) 
		return -1
	endif

	WAVE wave0, wave1, wave2, wave3, wave4, wave5
	WAVE/Z wave6

	fieldmapFilename = S_fileName
	fieldmapFilepath = S_path

	SaveFieldmapHeader()

	// Change wave references for transient fieldmap
	if (staticTransient == 2)
		if (!WaveExists(wave6))
			DoAlert 0, "Inconsistent number of columns for transient fieldmap."
			Killwaves/Z wave0, wave1, wave2, wave3, wave4, wave5
			return -1
		endif
		timeInstant = wave3[0]
		wave3 = wave4
		wave4 = wave5
		wave5 = wave6
	endif

	// Load x start, end and step values
	FindDuplicates/TOL=(tol)/RN=waveXUnique wave0
	startX = WaveMin(wave0)
	endX = WaveMax(wave0)
	stepX = abs(wave0[1] - wave0[0])
	if (stepX == 0)
	   stepX = 1
	endif
	nptsX = Round((endX - startX)/stepX + 1)
	
	// Load y start, end and step values
	FindDuplicates/TOL=(tol)/RN=waveYUnique wave1
	startY = WaveMin(wave1)
	endY = WaveMax(wave1)
	stepY = abs(wave1[nptsX] - wave1[0])
	if (stepY == 0)
	   stepY = 1
	endif
	nptsY = Round((endY - startY)/stepY + 1)

	// Load z start, end and step values
	FindDuplicates/TOL=(tol)/RN=waveZUnique wave2
	startZ = WaveMin(wave2)
	endZ = WaveMax(wave2)
	stepZ = abs(wave2[nptsX] - wave2[0])
	if (stepZ == 0)
	   stepZ = 1
	endif
	nptsZ = Round((endZ - startZ)/stepZ + 1)
	
	// Set longitudinal position start, end, step and npts
	if (beamDirection == 1) // Y-axis
		startL = startY
		endL = endY 
		stepL = stepY
		nptsL = nptsY
		WAVE waveLUnique = waveYUnique
	
	else
		startL = startZ
		endL = endZ
		stepL = stepZ
		nptsL = nptsZ
		WAVE waveLUnique = waveZUnique
	
	endif

	// Check longitudinal symmetry 
	if (symmetryLongitudinal == 1)
		if (startL != 0)
			DoAlert 0, "Can't apply longitudinal symmetry. Non-zero initial position."
			Killwaves/Z wave0, wave1, wave2, wave3, wave4, wave5, wave6
			Killwaves/Z waveXUnique, waveYUnique, waveZUnique
			return -1
		endif
	
		if (beamDirection == 1) // Y-axis
			if (symmetryLongitudinalBC == 1)
				// Normal Boundary Condition
				symmetryBxL = -1
				symmetryByL = 1
				symmetryBzL = -1			
			else
				// Tangencial Boundary Condition
				symmetryBxL = 1 
				symmetryByL = -1
				symmetryBzL = 1			
			endif
		
		else
			if (symmetryLongitudinalBC == 1)
				// Normal Boundary Condition
				symmetryBxL = -1
				symmetryByL = -1
				symmetryBzL = 1
			else
				// Tangencial Boundary Condition
				symmetryBxL = 1
				symmetryByL = 1
				symmetryBzL = -1
			endif

		endif
	
	else
		symmetryBxL = 1
		symmetryByL = 1
		symmetryBzL = 1
	
	endif

	// Check horizontal symmetry 
	if (symmetryHorizontal == 1)
		if (startX != 0)
			DoAlert 0, "Can't apply horizontal symmetry. Non-zero initial position."
			Killwaves/Z wave0, wave1, wave2, wave3, wave4, wave5, wave6
			Killwaves/Z waveXUnique, waveYUnique, waveZUnique
			return -1
		endif
		
		if (symmetryHorizontalBC == 1)
			// Normal Boundary Condition
			symmetryBxX = 1
			symmetryByX = -1
			symmetryBzX = -1			
		else
			// Tangencial Boundary Condition
			symmetryBxX = -1
			symmetryByX = 1
			symmetryBzX = 1			
		endif
	
	else
		symmetryBxX = 1
		symmetryByX = 1
		symmetryBzX = 1
	
	endif

	// Make horizontal and longitudinal position waves (convert from millimeter to meter)
	Make/D/O posX
	if (numpnts(waveXUnique) != nptsX)
		Duplicate/O waveXUnique, posX
		posX = posX / 1000
		nptsX = numpnts(posX)
		irregularGrid = 1
	else
		Redimension/N=(nptsX) posX
		posX = (startX + stepX*p) / 1000
	endif  
	
	Make/D/O posL
	if (numpnts(waveLUnique) != nptsL)
		Duplicate/O waveLUnique, posL
		posL = posL / 1000
		nptsL = numpnts(posL)
		irregularGrid = 1
	else
		Redimension/N=(nptsL) posL
		posL = (startL + stepL*p) / 1000
	endif
	
	// Get Bx, By and Bz values
	for(i=0; i<nptsX; i+=1)
		
		posXStr = num2str(posX[i])
		
		waveStr = "Bx_X" + posXStr
		Make/D/O/N=(nptsL) $waveStr
		WAVE waveBx = $waveStr
		
		waveStr = "By_X" + posXStr
		Make/D/O/N=(nptsL) $waveStr
		WAVE waveBy = $waveStr

		waveStr = "Bz_X" + posXStr
		Make/D/O/N=(nptsL) $waveStr
		WAVE waveBz = $waveStr

		waveBx = wave3[p*nptsX + i]
		waveBy = wave4[p*nptsX + i]
		waveBz = wave5[p*nptsX + i]

		if (symmetryLongitudinal == 1)
			Duplicate/O waveBx, tmpWavePos
			Duplicate/O/R=[1, nptsL-1] waveBx, tmpWaveNeg
			Reverse tmpWaveNeg
			tmpWaveNeg = symmetryBxL*tmpWaveNeg
			Concatenate/KILL/NP/O {tmpWaveNeg, tmpWavePos}, $NameOfWave(waveBx)
		
			Duplicate/O waveBy, tmpWavePos
			Duplicate/O/R=[1, nptsL-1] waveBy, tmpWaveNeg
			Reverse tmpWaveNeg
			tmpWaveNeg = symmetryByL*tmpWaveNeg
			Concatenate/KILL/NP/O {tmpWaveNeg, tmpWavePos}, $NameOfWave(waveBy)

			Duplicate/O waveBz, tmpWavePos
			Duplicate/O/R=[1, nptsL-1] waveBz, tmpWaveNeg
			Reverse tmpWaveNeg
			tmpWaveNeg = symmetryBzL*tmpWaveNeg
			Concatenate/KILL/NP/O {tmpWaveNeg, tmpWavePos}, $NameOfWave(waveBz)

		endif
		
	endfor

	if (symmetryLongitudinal == 1)
		
		Duplicate/O posL, tmpWavePos
		Duplicate/O/R=[1, nptsL-1] posL, tmpWaveNeg
		Reverse tmpWaveNeg
		tmpWaveNeg = (-1)*tmpWaveNeg
		Concatenate/KILL/NP/O {tmpWaveNeg, tmpWavePos}, posL
		
		startL = posL[0]*1000
		nptsL = numpnts(posL)

		if (beamDirection == 1)
			startY = startL
			nptsY = nptsL
		else
			startZ = startL
			nptsZ = nptsL
		endif

	endif

	if (symmetryHorizontal == 1)

		for(i=0; i<nptsX; i+=1)
			
			posXStr = num2str(posX[i])
			
			waveStr = "Bx_X" + posXStr
			waveStrAux = "Bx_X-" + posXStr
			Duplicate/O $waveStr, $waveStrAux
			WAVE tmpWave = $waveStrAux
			tmpWave = symmetryBxX*tmpWave
	
			waveStr = "By_X" + posXStr
			waveStrAux = "By_X-" + posXStr
			Duplicate/O $waveStr, $waveStrAux
			WAVE tmpWave = $waveStrAux
			tmpWave = symmetryByX*tmpWave				

			waveStr = "Bz_X" + posXStr
			waveStrAux = "Bz_X-" + posXStr
			Duplicate/O $waveStr, $waveStrAux
			WAVE tmpWave = $waveStrAux
			tmpWave = symmetryBzX*tmpWave

		endfor

		Duplicate/O posX, tmpWavePos
		Duplicate/O/R=[1, nptsX-1] posX, tmpWaveNeg
		Reverse tmpWaveNeg
		tmpWaveNeg = (-1)*tmpWaveNeg
		Concatenate/KILL/NP/O {tmpWaveNeg, tmpWavePos}, posX
		startX = posX[0]*1000
		nptsX = numpnts(posX)

	endif
	
	Killwaves/Z wave0, wave1, wave2, wave3, wave4, wave5, wave6
	Killwaves/Z waveXUnique, waveYUnique, waveZUnique
	
	dataLoaded = 1
	CalcFieldIntegrals()
	UpdatePositionVariables()
	
	return 0
			
End


Static Function CalcFieldIntegrals()
 	WAVE posX, posL

 	variable i, nptsX	
 	string posXStr, wn, wnInt, wnInt2
 	
 	nptsX = numpnts(posX)
 	
	Make/D/O/N=(nptsX) Int_Bx	
	Make/D/O/N=(nptsX) Int_By	
	Make/D/O/N=(nptsX) Int_Bz	
	Make/D/O/N=(nptsX) Int2_Bx	
	Make/D/O/N=(nptsX) Int2_By
	Make/D/O/N=(nptsX) Int2_Bz	
	
	for (i=0; i<nptsX; i++)
		posXStr = num2str(posX[i])

		wn = "Bx_X" + posXstr
		wnInt = "Int_Bx_X" + posXstr
		wnInt2 = "Int2_Bx_X" + posXstr
		Integrate/METH=1 $wn/X=posL/D=$wnInt
		Integrate/METH=1 $wnInt/X=posL/D=$wnInt2
		WAVE waveBInt = $wnInt	
		WAVE waveBInt2 = $wnInt2		
		Int_Bx[i] = waveBInt[numpnts(waveBInt)-1]
		Int2_Bx[i] = waveBInt2[numpnts(waveBInt2)-1]
		
		wn = "By_X" + posXstr
		wnInt = "Int_By_X" + posXstr
		wnInt2 = "Int2_By_X" + posXstr
		Integrate/METH=1 $wn/X=posL/D=$wnInt
		Integrate/METH=1 $wnInt/X=posL/D=$wnInt2
		WAVE waveBInt = $wnInt	
		WAVE waveBInt2 = $wnInt2		
		Int_By[i] = waveBInt[numpnts(waveBInt)-1]
		Int2_By[i] = waveBInt2[numpnts(waveBInt2)-1]

		wn = "Bz_X" + posXstr
		wnInt = "Int_Bz_X" + posXstr
		wnInt2 = "Int2_Bz_X" + posXstr
		Integrate/METH=1 $wn/X=posL/D=$wnInt
		Integrate/METH=1 $wnInt/X=posL/D=$wnInt2
		WAVE waveBInt = $wnInt	
		WAVE waveBInt2 = $wnInt2		
		Int_Bz[i] = waveBInt[numpnts(waveBInt)-1]
		Int2_Bz[i] = waveBInt2[numpnts(waveBInt2)-1]

	endfor	
	
End


Static Function AddFieldmapOptions(windowName, h, l1, l2, [copyConfigProc, applyToAllProc])
	string windowName
	variable h, l1, l2
	string copyConfigProc, applyToAllProc

	if (ParamIsDefault(copyConfigProc))
		copyConfigProc = ""
	endif
	
	if (ParamIsDefault(applyToAllProc))
		applyToAllProc = ""
	endif

	variable m, h1, lb
	h1 = h
	m = l1 + 15
	lb = l2 - 2*m 
	
	h += 10
	SetVariable svarCurrentFieldmap, win=$windowName, pos={m, h}, size={lb,20}, noedit=1, title="Current Fieldmap "
	SetVariable svarCurrentFieldmap, win=$windowName, value=root:varsCAMTO:FIELDMAP_FOLDER
	h += 25
	
	if (strlen(copyConfigProc)!=0)
		TitleBox tbxCopyConfig, win=$windowName, pos={m,h}, size={140,20}, frame=0, title="Copy Configuration From "
		PopupMenu popupCopyConfig, win=$windowName, pos={m+150,h},size={lb-150,20}, bodyWidth=lb-150, mode=0, title=" "
		PopupMenu popupCopyConfig, proc=$copyConfigProc
		h += 25
	endif
	
	if (strlen(applyToAllProc)!=0)
		Button btnApplyToAll, win=$windowName, pos={m,h}, size={lb,25}, fsize=14, fstyle=1, title="Apply To All Fieldmaps"
		Button btnApplyToAll, proc=$applyToAllProc
		h += 30
	endif
	
	h += 5
	SetDrawEnv/W=$windowName fillpat=0
	DrawRect/W=$windowName l1,h1,l2,h-5
	
	return h

End


Static Function UpdateFieldmapOptions(windowName)
	string windowName

	NVAR fieldmapCount = root:varsCAMTO:FIELDMAP_COUNT

	string fieldmapList
	
	if (fieldmapCount > 1)
		fieldmapList = GetFieldmapFolders()
		
		ControlInfo/W=$windowName popupCopyConfig
		if (V_Flag != 0)
			PopupMenu popupCopyConfig, win=$windowName, disable=0, value= #("\"" + fieldmapList + "\"")
		endif
		
		ControlInfo/W=$windowName btnApplyToAll
		if (V_Flag != 0)
			Button btnApplyToAll, win=$windowName, disable=0
		endif
	
	else
		ControlInfo/W=$windowName popupCopyConfig
		if (V_Flag != 0)
			PopupMenu popupCopyConfig, win=$windowName, disable=2
		endif
		
		ControlInfo/W=$windowName btnApplyToAll
		if (V_Flag != 0)
			Button btnApplyToAll, win=$windowName, disable=2
		endif
	
	endif

	return 0

End


Function CAMTO_Export_Panel() : Panel
	
	string windowName = "Export"
	string windowTitle = "Export Field Data"
	
	if (DataFolderExists("root:varsCAMTO")==0)
		DoAlert 0, "CAMTO variables not found."
		return -1
	endif

	DoWindow/K $windowName
	NewPanel/K=1/N=$windowName/W=(1230,60,1670,400) as windowTitle
	SetDrawLayer UserBack
	
	variable m, h, h1, l1, l2, l 
	m = 20	
	h = 10
	h1 = 5	
	l1 = 5
	l2 = 435

	TitleBox tbxTitle1, pos={0,h}, size={440,20}, anchor=MT, fsize=18, frame=0, fstyle=1, title="Export Field"
	h += 35

	SetDrawEnv fillpat=0
	DrawRect l1,h1,l2,h-5
	h1 = h-5
	h += 5
	
	TitleBox  tbxTitle3, pos={m,h},size={120,20}, frame=0, title="Field Components "
	CheckBox chbExportBx, pos={m+120,h}, size={40,20}, title=" Bx "
	CheckBox chbExportBy, pos={m+170,h}, size={40,20}, title=" By "
	CheckBox chbExportBz, pos={m+220,h}, size={40,20}, title=" Bz "
	Button btnUpdatePositions, pos={m+270,h-1}, size={130,20}, fstyle=1, title="Update Positions"
	Button btnUpdatePositions, proc=CAMTO_Export_BtnUpdatePositions
	h += 30

	SetDrawEnv fillpat=0
	DrawRect l1,h1,l2,h-5
	h1 = h-5

	TitleBox tbxTitleX, pos={m+30,h}, size={60,25}, fsize=20, frame=0, title="X - axis"
	TitleBox tbxTitleY, pos={m+170,h}, size={60,25}, fsize=20, frame=0, title="Y - axis"
	TitleBox tbxTitleZ, pos={m+310,h}, size={60,25}, fsize=20, frame=0, title="Z - axis"
	h += 40
	
	SetVariable svarStartX, pos={m,h}, size={110,20}, limits={0,0,0}, title="Start"
	SetVariable svarStartY, pos={m+140,h}, size={110,20}, limits={0,0,0}, title="Start"
	SetVariable svarStartZ, pos={m+280,h}, size={110,20}, limits={0,0,0}, title="Start"
	h += 40
	
	SetVariable svarEndX, pos={m,h}, size={110,20}, limits={0,0,0}, title="End"
	SetVariable svarEndY, pos={m+140,h}, size={110,20}, limits={0,0,0}, title="End"
	SetVariable svarEndZ, pos={m+280,h}, size={110,20}, limits={0,0,0}, title="End"
	h += 40
	
	SetVariable svarStepX, pos={m,h}, size={110,20}, limits={0,0,0}, title="Step"
	SetVariable svarStepY, pos={m+140,h}, size={110,20}, limits={0,0,0}, title="Step"
	SetVariable svarStepZ, pos={m+280,h}, size={110,20}, limits={0,0,0}, title="Step"
	h += 40
		
	SetDrawEnv fillpat=0
	DrawRect l1,h1,l2/3,h-5
	SetDrawEnv fillpat=0
	DrawRect l2/3,h1,2*l2/3,h-5
	SetDrawEnv fillpat=0
	DrawRect 2*l2/3,h1,l2,h-5
	h1 = h-5

	Button btnExportFieldmap, pos={m-5,h}, size={195,30}, fsize=14, fstyle=1, title="Export in Fieldmap Format"
	Button btnExportFieldmap, proc=CAMTO_Export_BtnExportFieldmap
	Button btnExportSpectra, pos={m+210,h}, size={195,30}, fsize=14, fstyle=1, title="Export in Spectra Format"
	Button btnExportSpectra, proc=CAMTO_Export_BtnExportSpectra
	h += 40

	SetDrawEnv fillpat=0
	DrawRect l1,h1,l2,h-5
	h1 = h-5
	
	h = AddFieldmapOptions(windowName, h1, l1, l2, copyConfigProc="CAMTO_Export_PopupCopyConfig")

	UpdatePanelExport()

	return 0
			
End


Static Function UpdatePanelExport()

	SVAR df = root:varsCAMTO:FIELDMAP_FOLDER
	
	string windowName = "Export"

	if (WinType(windowName)==0)
		return -1
	endif

	UpdateFieldmapOptions(windowName)
	
	if (strlen(df) > 0 && cmpstr(df, "_none_")!=0)				
		NVAR beamDirection = root:$(df):varsFieldmap:LOAD_BEAM_DIRECTION
		NVAR startX = root:$(df):varsFieldmap:LOAD_START_X
		NVAR endX = root:$(df):varsFieldmap:LOAD_END_X
		NVAR startY = root:$(df):varsFieldmap:LOAD_START_Y
		NVAR endY = root:$(df):varsFieldmap:LOAD_END_Y
		NVAR startZ = root:$(df):varsFieldmap:LOAD_START_Z
		NVAR endZ = root:$(df):varsFieldmap:LOAD_END_Z

		NVAR exportStartX = root:$(df):varsFieldmap:EXPORT_START_X
		NVAR exportEndX = root:$(df):varsFieldmap:EXPORT_END_X
		NVAR exportStepX = root:$(df):varsFieldmap:EXPORT_STEP_X
		NVAR exportStartY = root:$(df):varsFieldmap:EXPORT_START_Y
		NVAR exportEndY = root:$(df):varsFieldmap:EXPORT_END_Y
		NVAR exportStepY = root:$(df):varsFieldmap:EXPORT_STEP_Y
		NVAR exportStartZ = root:$(df):varsFieldmap:EXPORT_START_Z
		NVAR exportEndZ = root:$(df):varsFieldmap:EXPORT_END_Z
		NVAR exportStepZ = root:$(df):varsFieldmap:EXPORT_STEP_Z
		NVAR exportBx = root:$(df):varsFieldmap:EXPORT_BX
		NVAR exportBy = root:$(df):varsFieldmap:EXPORT_BY
		NVAR exportBz = root:$(df):varsFieldmap:EXPORT_BZ
			
		SetVariable svarStartX, win=$windowName, value=exportStartX, limits={startX, endX, 1}
		SetVariable svarEndX, win=$windowName, value=exportEndX, limits={startX, endX, 1}
		SetVariable svarStepX, win=$windowName, value=exportStepX, limits={0, (endX - startX), 1}

		SetVariable svarStartY, win=$windowName, value=exportStartY, limits={startY, endY, 1}
		SetVariable svarEndY, win=$windowName, value=exportEndY, limits={startY, endY, 1}
		SetVariable svarStepY, win=$windowName, value=exportStepY, limits={0, (endY - startY), 1}

		SetVariable svarStartZ, win=$windowName, value=exportStartZ, limits={startZ, endZ, 1}
		SetVariable svarEndZ, win=$windowName, value=exportEndZ, limits={startZ, endZ, 1}
		SetVariable svarStepZ, win=$windowName, value=exportStepZ, limits={0, (endZ - startZ), 1}

		if (beamDirection == 1)
		 	TitleBox tbxTitleZ, win=$windowName, disable=2
		 	SetVariable svarStartZ, win=$windowName, disable=2
		 	SetVariable svarEndZ, win=$windowName, disable=2
		 	SetVariable svarStepZ, win=$windowName, disable=2
		 	TitleBox tbxTitleY, win=$windowName, disable=0
		 	SetVariable svarStartY, win=$windowName, disable=0
		 	SetVariable svarEndY, win=$windowName, disable=0
		 	SetVariable svarStepY, win=$windowName, disable=0
		else
		 	TitleBox tbxTitleY, win=$windowName, disable=2
		 	SetVariable svarStartY, win=$windowName, disable=2
		 	SetVariable svarEndY, win=$windowName, disable=2
		 	SetVariable svarStepY, win=$windowName, disable=2 
		 	TitleBox tbxTitleZ, win=$windowName, disable=0
		 	SetVariable svarStartZ, win=$windowName, disable=0
		 	SetVariable svarEndZ, win=$windowName, disable=0
		 	SetVariable svarStepZ, win=$windowName, disable=0
		endif

		CheckBox chbExportBx, win=$windowName, variable=exportBx, disable=0
		CheckBox chbExportBy, win=$windowName, variable=exportBy, disable=0
		CheckBox chbExportBz, win=$windowName, variable=exportBz, disable=0		
		Button btnUpdatePositions, win=$windowName, disable=0
		Button btnExportFieldmap, win=$windowName, disable=0
		Button btnExportSpectra, win=$windowName, disable=0
			
	else
		CheckBox chbExportBx, win=$windowName, disable=2
		CheckBox chbExportBy, win=$windowName, disable=2
		CheckBox chbExportBz, win=$windowName, disable=2
		Button btnUpdatePositions, win=$windowName, disable=2
		Button btnExportFieldmap, win=$windowName, disable=2
		Button btnExportSpectra, win=$windowName, disable=2
	
	endif
	
	return 0

End


Function CAMTO_Export_PopupCopyConfig(pa) : PopupMenuControl
	struct WMPopupAction &pa

	SVAR fieldmapCopy = root:varsCAMTO:FIELDMAP_COPY

	switch(pa.eventCode)
		case 2:
			if (IsCorrectFolder() == -1)
				return -1
			endif

			fieldmapCopy = pa.popStr
			
			CopyConfigExport(fieldmapCopy)
			UpdatePanelExport()
			
			break
	
	endswitch

	return 0

End


Static Function CopyConfigExport(dfc)
	string dfc

	WAVE/T fieldmapFolders= root:wavesCAMTO:fieldmapFolders
	
	UpdateFieldmapFolders()	
	FindValue/Text=dfc/TXOP=4 fieldmapFolders
	
	if (V_Value!=-1)
		NVAR temp_df = :varsFieldmap:EXPORT_START_X
		NVAR temp_dfc = root:$(dfc):varsFieldmap:EXPORT_START_X
		temp_df = temp_dfc

		NVAR temp_df = :varsFieldmap:EXPORT_END_X
		NVAR temp_dfc = root:$(dfc):varsFieldmap:EXPORT_END_X
		temp_df = temp_dfc

		NVAR temp_df = :varsFieldmap:EXPORT_STEP_X
		NVAR temp_dfc = root:$(dfc):varsFieldmap:EXPORT_STEP_X
		temp_df = temp_dfc
		
		NVAR temp_df = :varsFieldmap:EXPORT_START_Y
		NVAR temp_dfc = root:$(dfc):varsFieldmap:EXPORT_START_Y
		temp_df = temp_dfc

		NVAR temp_df = :varsFieldmap:EXPORT_END_Y
		NVAR temp_dfc = root:$(dfc):varsFieldmap:EXPORT_END_Y
		temp_df = temp_dfc

		NVAR temp_df = :varsFieldmap:EXPORT_STEP_Y
		NVAR temp_dfc = root:$(dfc):varsFieldmap:EXPORT_STEP_Y
		temp_df = temp_dfc

		NVAR temp_df = :varsFieldmap:EXPORT_START_Z
		NVAR temp_dfc = root:$(dfc):varsFieldmap:EXPORT_START_Z
		temp_df = temp_dfc

		NVAR temp_df = :varsFieldmap:EXPORT_END_Z
		NVAR temp_dfc = root:$(dfc):varsFieldmap:EXPORT_END_Z
		temp_df = temp_dfc

		NVAR temp_df = :varsFieldmap:EXPORT_STEP_Z
		NVAR temp_dfc = root:$(dfc):varsFieldmap:EXPORT_STEP_Z
		temp_df = temp_dfc

		NVAR temp_df = :varsFieldmap:EXPORT_BX
		NVAR temp_dfc = root:$(dfc):varsFieldmap:EXPORT_BX
		temp_df = temp_dfc

		NVAR temp_df = :varsFieldmap:EXPORT_BY
		NVAR temp_dfc = root:$(dfc):varsFieldmap:EXPORT_BY
		temp_df = temp_dfc

		NVAR temp_df = :varsFieldmap:EXPORT_BZ
		NVAR temp_dfc = root:$(dfc):varsFieldmap:EXPORT_BZ
		temp_df = temp_dfc

	else
		DoAlert 0, "Data folder not found."
		return -1
	endif
	
	return 0

End


Function CAMTO_Export_BtnUpdatePositions(ba) : ButtonControl
	struct WMButtonAction &ba

	switch(ba.eventCode)
		case 2:
			if (IsCorrectFolder() == -1)
				return -1
			endif
			
			UpdatePositionVariablesExport()		
			UpdatePanelExport()
			
			break
	endswitch
	
	return 0
End


Function CAMTO_Export_BtnExportFieldmap(ba) : ButtonControl
	struct WMButtonAction &ba
	
	switch(ba.eventCode)
		case 2:		
			if (IsCorrectFolder() == -1)
				return -1
			endif

			ExportFieldmap()
			
			break
	endswitch
	
	return 0

End


Function CAMTO_Export_BtnExportSpectra(ba) : ButtonControl
	struct WMButtonAction &ba
	
	switch(ba.eventCode)
		case 2:		
			if (IsCorrectFolder() == -1)
				return -1
			endif

			ExportSpectra()
			
			break
	endswitch
	
	return 0

End


Static Function CalcFieldAtPoint(px, pl)
	variable px, pl //horizontal and longitudinal positions in meters
	
	NVAR nptsX = :varsFieldmap:LOAD_NPTS_X
	NVAR nptsL = :varsFieldmap:LOAD_NPTS_L
		
	NVAR fieldX = :varsFieldmap:FIELD_X
	NVAR fieldY = :varsFieldmap:FIELD_Y
	NVAR fieldZ = :varsFieldmap:FIELD_Z
	
	NVAR iX = :varsFieldmap:INDEX_X
	NVAR iL = :varsFieldmap:INDEX_L
	
	WAVE posX, posL
	
	variable i, ii, field1, field2, limitX, limitL
	string posXStr1, posXStr2

	limitX = 0
	limitL = 0
	
	// Update horizontal index
	if (nptsX == 1 || px <= posX[0])
		iX = 0
		limitX = 1
	
	elseif (px >= posX[nptsX-1])
		iX = nptsX-1
		limitX = 1
	
	else
		if (px >= posX[iX])
			ii = 1
		else
			ii = -1
		endif
	
		for (i=iX; i<nptsX; i=i+ii)
			if (i < 0)
				ii = 1
				i = 0
			endif
		
			if (px >= posX[i] && px <= posX[i+1])
				iX = i
				break
			endif
		
		endfor	
	
	endif
	
	// Update longitudinal index
	if (nptsL == 1 || pl <= posL[0])
		iL = 0
		limitL = 1
	
	elseif (pl >= posl[nptsL-1])
		iL = nptsL-1
		limitL = 1
	
	else
		if (pl >= posL[iL])
			ii = 1
		else
			ii = -1
		endif
	
		for (i=iL; i<nptsL; i=i+ii)
			if (i < 0)
				ii = 1
				i = 0
			endif
			
			if (pl >= posL[i] && pl <= posL[i+1])
				iL = i
				break
			endif
	
		endfor	
	
	endif

	posXStr1 = num2str(posX[iX])
	Wave waveBx1 = $("Bx_X" + posXStr1)
	Wave waveBy1 = $("By_X" + posXStr1)
	Wave waveBz1 = $("Bz_X" + posXStr1)

	if (limitX && limitL)
		fieldX = waveBx1[iL]
		fieldY = waveBy1[iL]
		fieldZ = waveBz1[iL]
	
	elseif (limitX)
		fieldX = waveBx1[iL] + ((waveBx1[iL+1] - waveBx1[iL])/(posL[iL+1] - posL[iL]) * (pl - posL[iL]))
		fieldY = waveBy1[iL] + ((waveBy1[iL+1] - waveBy1[iL])/(posL[iL+1] - posL[iL]) * (pl - posL[iL]))
		fieldZ = waveBz1[iL] + ((waveBz1[iL+1] - waveBz1[iL])/(posL[iL+1] - posL[iL]) * (pl - posL[iL]))
		
	elseif (limitL)
		posXStr2 = num2str(posX[iX+1])
		Wave waveBx2 = $("Bx_X" + posXStr2)
		Wave waveBy2 = $("By_X" + posXStr2)
		Wave waveBz2 = $("Bz_X" + posXStr2)

		fieldX = waveBx1[iL] + ((waveBx2[iL] - waveBx1[iL])/(posX[iX+1] - posX[iX]) * (px - posX[iX]))
		fieldY = waveBy1[iL] + ((waveBy2[iL] - waveBy1[iL])/(posX[iX+1] - posX[iX]) * (px - posX[iX]))
		fieldZ = waveBz1[iL] + ((waveBz2[iL] - waveBz1[iL])/(posX[iX+1] - posX[iX]) * (px - posX[iX]))
		
	else
		posXStr2 = num2str(posX[iX+1])
		Wave waveBx2 = $("Bx_X" + posXStr2)
		Wave waveBy2 = $("By_X" + posXStr2)
		Wave waveBz2 = $("Bz_X" + posXStr2)

		// Find field X
		field1 = waveBx1[iL] + ((waveBx1[iL+1] - waveBx1[iL])/(posL[iL+1] - posL[iL]) * (pl - posL[iL]))
		field2 = waveBx2[iL] + ((waveBx2[iL+1] - waveBx2[iL])/(posL[iL+1] - posL[iL]) * (pl - posL[iL]))
		fieldX = field1 + ((field2 - field1)/(posX[iX+1] - posX[iX]) * (px - posX[iX]))

		// Find field Y
		field1 = waveBy1[iL] + ((waveBy1[iL+1] - waveBy1[iL])/(posL[iL+1] - posL[iL]) * (pl - posL[iL]))
		field2 = waveBy2[iL] + ((waveBy2[iL+1] - waveBy2[iL])/(posL[iL+1] - posL[iL]) * (pl - posL[iL]))
		fieldY = field1 + ((field2 - field1)/(posX[iX+1] - posX[iX]) * (px - posX[iX]))

		// Find field Z
		field1 = waveBz1[iL] + ((waveBz1[iL+1] - waveBz1[iL])/(posL[iL+1] - posL[iL]) * (pl - posL[iL]))
		field2 = waveBz2[iL] + ((waveBz2[iL+1] - waveBz2[iL])/(posL[iL+1] - posL[iL]) * (pl - posL[iL]))
		fieldZ = field1 + ((field2 - field1)/(posX[iX+1] - posX[iX]) * (px - posX[iX]))

	endif
	
	return 0
	
End


Static Function/S GetDefaultFieldmapFilename([spectra])
	variable spectra
	
	if (ParamIsDefault(spectra))
		spectra = 0
	endif	
	
	SVAR fieldmapFilename = :varsFieldmap:FIELDMAP_FILENAME
	
	NVAR startX = :varsFieldmap:EXPORT_START_X
	NVAR endX = :varsFieldmap:EXPORT_END_X
	NVAR startY = :varsFieldmap:EXPORT_START_Y
	NVAR endY = :varsFieldmap:EXPORT_END_Y
	NVAR startZ = :varsFieldmap:EXPORT_START_Z
	NVAR endZ = :varsFieldmap:EXPORT_END_Z
	
	string filename, auxStr	
	filename = fieldmapFilename
	
	SplitString/E="X=(.*?)mm" filename
	if (strlen(S_Value) != 0)
		if (startX != endX)
			sprintf auxStr, "X=%g_%gmm", startX, endX
		else
			auxStr = ""
		endif
		filename = ReplaceString(S_Value, filename, auxStr)
	endif

	SplitString/E="Y=(.*?)mm" filename
	if (strlen(S_Value) != 0)
		if (startY != endY)
			sprintf auxStr, "Y=%g_%gmm", startY, endY
		else
			auxStr = ""
		endif
		filename = ReplaceString(S_Value, filename, auxStr)
	endif

	SplitString/E="Z=(.*?)mm" filename
	if (strlen(S_Value) != 0)
		if (startZ != endZ)
			sprintf auxStr, "Z=%g_%gmm", startZ, endZ
		else
			auxStr = ""
		endif
		filename = ReplaceString(S_Value, filename, auxStr)
	endif

	SplitString/E="([[:digit:]]+)-([[:digit:]]+)-([[:digit:]]+)" filename
	if (strlen(S_Value) != 0)
		auxStr = Secs2Date(DateTime, -2)
		filename = ReplaceString(S_Value, filename, auxStr)
	endif
	
	if (spectra)
		SplitString/E="(.dat|.txt)" filename
		if (strlen(S_Value) != 0)
			auxStr = "_spectra" + S_Value
			filename = ReplaceString(S_Value, filename, auxStr)
		endif
	endif
	
	return filename

end


Static Function WriteFieldmapHeader(fullPath)
	string fullPath
		
	WAVE/T headerLines
	
	string filename, timestamp
	variable i, size, replaced
	string str, strv
		
	SplitString/E=".*:" fullPath
	filename = fullPath[strlen(S_value), strlen(fullPath)-1]
	timestamp = secs2Date(DateTime, -2) + "_" + ReplaceString(":", secs2Time(DateTime, 3), "-")
	
	Duplicate/O/T headerLines newHeaderLines
	
	size = numpnts(newHeaderLines)
	replaced = 0
	
	for (i=0; i<size; i=i+1)
		
		str = newHeaderLines[i]
		
		sscanf str, "timestamp: %s", strv
		if (strlen(strv) != 0)
			newHeaderLines[i] = ReplaceString(strv, str, timestamp)
			replaced = replaced + 1
		endif

		sscanf str, "filename: %s", strv
		if (strlen(strv) != 0)
			newHeaderLines[i] = ReplaceString(strv, str, filename)
			replaced = replaced + 1
		endif
		
		if (replaced == 2)
			Redimension/N=(size+2) newHeaderLines
			newHeaderLines[size] = "X[mm]	Y[mm]	Z[mm]	Bx	By	Bz	[T]"	
			newHeaderLines[size+1] = "------------------------------------------------------------------------------------------------------------------------------------------------------------------"	
			break
		endif
	
	endfor
	
	Edit/N=FieldmapHeader newHeaderLines
	SaveTableCopy/A=0/O/T=1/W=FieldmapHeader/N=0 as fullPath
	KillWindow/Z FieldmapHeader
	KillWaves/Z newHeaderLines
	
	return 0
	
End


Static Function ExportFieldmap()

	SVAR fieldmapFilepath = :varsFieldmap:FIELDMAP_FILEPATH
	NVAR beamDirection = :varsFieldmap:LOAD_BEAM_DIRECTION

	NVAR loadStartX = :varsFieldmap:LOAD_START_X
	NVAR loadEndX = :varsFieldmap:LOAD_END_X
	NVAR loadStepX = :varsFieldmap:LOAD_STEP_X
	
	NVAR loadStartY = :varsFieldmap:LOAD_START_Y
	NVAR loadEndY = :varsFieldmap:LOAD_END_Y
	NVAR loadStepY = :varsFieldmap:LOAD_STEP_Y
	
	NVAR loadStartZ = :varsFieldmap:LOAD_START_Z
	NVAR loadEndZ = :varsFieldmap:LOAD_END_Z
	NVAR loadStepZ = :varsFieldmap:LOAD_STEP_Z

	NVAR fieldX = :varsFieldmap:FIELD_X
	NVAR fieldY = :varsFieldmap:FIELD_Y
	NVAR fieldZ = :varsFieldmap:FIELD_Z

	NVAR startX = :varsFieldmap:EXPORT_START_X
	NVAR endX = :varsFieldmap:EXPORT_END_X
	NVAR stepX = :varsFieldmap:EXPORT_STEP_X
	
	NVAR startY = :varsFieldmap:EXPORT_START_Y
	NVAR endY = :varsFieldmap:EXPORT_END_Y
	NVAR stepY = :varsFieldmap:EXPORT_STEP_Y
	
	NVAR startZ = :varsFieldmap:EXPORT_START_Z
	NVAR endZ = :varsFieldmap:EXPORT_END_Z
	NVAR stepZ = :varsFieldmap:EXPORT_STEP_Z

	NVAR exportBx = :varsFieldmap:EXPORT_BX
	NVAR exportBy = :varsFieldmap:EXPORT_BY
	NVAR exportBz = :varsFieldmap:EXPORT_BZ

	string filename, posXStr
	variable allPositions, i, j, count
	variable nptsX, nptsY, nptsZ
	variable startL, endL, stepL, nptsL
	variable xpos, lpos

	allPositions = 0
	if (startX == loadStartX && endX == loadEndX && stepX == loadStepX)
		if (startY == loadStartY && endY == loadEndY && stepY == loadStepY)
			if (startZ == loadStartZ && endZ == loadEndZ && stepZ == loadStepZ)
				allPositions = 1
			endif
		endif
	endif
	
	if (allPositions)
		WAVE posX, posL
		
		nptsx = numpnts(posX)
		nptsl = numpnts(posL)
		
		make/D/O/N=(nptsX, nptsL) Px = 0
		make/D/O/N=(nptsX, nptsL) Py = 0
		make/D/O/N=(nptsX, nptsL) Pz = 0
		make/D/O/N=(nptsX, nptsL) Bx = 0
		make/D/O/N=(nptsX, nptsL) By = 0
		make/D/O/N=(nptsX, nptsL) Bz = 0
			
		for (i=0; i<nptsX; i=i+1)
			Px[i][] = posX[i]*1000
		
			if (beamDirection == 1)
				Py[i][] = posL[q]*1000
				Pz[i][] = startZ
			else
				Py[i][] = startY
				Pz[i][] = posL[q]*1000
			endif
		
			posXStr = num2str(posX[i])
	
			Wave waveBx = $("Bx_X" + posXStr)
			Bx[i][] = waveBx[q]
			
			Wave waveBy = $("By_X" + posXStr)
			By[i][] = waveBy[q]
	
			Wave waveBz = $("Bz_X" + posXStr)
			Bz[i][] = waveBz[q]
			
		endfor
		
		Redimension/N=(nptsX*nptsL) Px
		Redimension/N=(nptsX*nptsL) Py
		Redimension/N=(nptsX*nptsL) Pz
		Redimension/N=(nptsX*nptsL) Bx
		Redimension/N=(nptsX*nptsL) By
		Redimension/N=(nptsX*nptsL) Bz
	
	else
		if (stepX == 0 || stepY == 0 || stepZ == 0)
			DoAlert 0, "The step value must be greater than zero."
			return -1
		endif
	
		nptsX = (endX - startX)/stepX + 1
		nptsY = (endY - startY)/stepY + 1
		nptsZ = (endZ - startZ)/stepZ + 1
		
		if (beamDirection == 1)
			startL = startY
			endL = endY
			stepL = stepY
			nptsL	= nptsY
		else
			startL = startZ
			endL = endZ
			stepL = stepZ
			nptsL	= nptsZ
		endif

		make/D/O/N=(nptsX*nptsL) Px = 0
		make/D/O/N=(nptsX*nptsL) Py = 0
		make/D/O/N=(nptsX*nptsL) Pz = 0
		make/D/O/N=(nptsX*nptsL) Bx = 0
		make/D/O/N=(nptsX*nptsL) By = 0
		make/D/O/N=(nptsX*nptsL) Bz = 0

		count = 0
		for (j=0; j<nptsL; j=j+1)
			lpos = (startL + j*stepL)
				
			for (i=0; i<nptsX; i=i+1)
				xpos = (startX + i*stepX)

				CalcFieldAtPoint(xpos/1000, lpos/1000)
				
				Px[count] = xpos
				if (beamDirection == 1)
					Py[count] = lpos
					Pz[count] = startZ
				else
					Py[count] = startY
					Pz[count] = lpos
				endif
				
				Bx[count] = FieldX			
				By[count] = FieldY
				Bz[count] = FieldZ
				
				count +=1
			
			endfor
		endfor
	
	endif
	
	if (!exportBx)
		Bx = 0
	endif

	if (!exportBy)
		By = 0
	endif

	if (!exportBz)
		Bz = 0
	endif

	Edit/N=FieldmapTable Px, Py, Pz, Bx, By, Bz
	ModifyTable sigDigits(Bx)=16, sigDigits(By)=16, sigDigits(Bz)=16

	filename = GetDefaultFieldmapFilename()	
	
	Open/D tablePath as fieldmapFilepath + filename
	if (strlen(S_FileName) != 0)
		WriteFieldmapHeader(S_FileName)
		SaveTableCopy/A=2/T=1/W=FieldmapTable/N=0 as S_fileName
	endif
	Close/A
		
	KillWindow/Z FieldmapTable
	Killwaves/Z Px, Py, Pz, Bx, By, Bz
	
	return 0
	
End


Static Function ExportSpectra()
	
	SVAR fieldmapFilepath = :varsFieldmap:FIELDMAP_FILEPATH
	NVAR beamDirection = :varsFieldmap:LOAD_BEAM_DIRECTION

	NVAR startX = :varsFieldmap:EXPORT_START_X
	NVAR endX = :varsFieldmap:EXPORT_END_X
	NVAR stepX = :varsFieldmap:EXPORT_STEP_X
	
	NVAR startY = :varsFieldmap:EXPORT_START_Y
	NVAR endY = :varsFieldmap:EXPORT_END_Y
	NVAR stepY = :varsFieldmap:EXPORT_STEP_Y
	
	NVAR startZ = :varsFieldmap:EXPORT_START_Z
	NVAR endZ = :varsFieldmap:EXPORT_END_Z
	NVAR stepZ = :varsFieldmap:EXPORT_STEP_Z

	NVAR exportBx = :varsFieldmap:EXPORT_BX
	NVAR exportBy = :varsFieldmap:EXPORT_BY
	NVAR exportBz = :varsFieldmap:EXPORT_BZ

	NVAR fieldX = :varsFieldmap:FIELD_X
	NVAR fieldY = :varsFieldmap:FIELD_Y
	NVAR fieldZ = :varsFieldmap:FIELD_Z
	
	variable nptsX, nptsY, nptsZ
	variable startL, endL, stepL, nptsL

	if (stepX == 0 || stepY == 0 || stepZ == 0)
		DoAlert 0, "The step value must be greater than zero."
		return -1
	endif

	nptsX = (endX - startX)/stepX + 1
	nptsY = (endY - startY)/stepY + 1
	nptsZ = (endZ - startZ)/stepZ + 1
	
	If (beamDirection == 1)
		startL = startY
		endL = endY
		stepL = stepY
		nptsL	= nptsY
	Else
		startL = startZ
		endL = endZ
		stepL = stepZ
		nptsL	= nptsZ
	Endif

	if (nptsL < 4)
		DoAlert 0, "The number of points in the longitudinal direction must be greater than 4."
		return -1
	endif
	
	string filename, headerStr
	variable i, j, k, count, xpos, lpos
	variable nptsV = 2
	variable stepV = 1
	
	make/D/o/n=(nptsX*nptsV*nptsL) Bx = 0
	make/D/o/n=(nptsX*nptsV*nptsL) By = 0
	make/D/o/n=(nptsX*nptsV*nptsL) Bz = 0
	
	count = 0
	for (i=0; i<nptsX; i++)
		xpos = (startX + i*stepX)		
		
		for (k=0; k<nptsV; k++)
			
			for (j=0; j<nptsL; j++)
				lpos = (startL + j*stepL)
				
				CalcFieldAtPoint(xpos/1000, lpos/1000)
				
				Bx[count] = FieldX			
				By[count] = FieldY
				Bz[count] = FieldZ
				
				count += 1	
			endfor	
		
		endfor
	
	endfor

	if (!exportBx)
		Bx = 0
	endif

	if (!exportBy)
		By = 0
	endif

	if (!exportBz)
		Bz = 0
	endif

	if (nptsX == 1)
		nptsX = 2
		stepX = 1
		Concatenate/O/NP {Bx, Bx}, exportWave0 
		Concatenate/O/NP {By, By}, exportWave1 
		Concatenate/O/NP {Bz, Bz}, exportWave2
	else
		Duplicate/O Bx, exportWave0
		Duplicate/O By, exportWave1
		Duplicate/O Bz, exportWave2	
	endif
	
	Edit/N=FieldmapTable exportWave0, exportWave1, exportWave2
	ModifyTable sigDigits(exportWave0)=16, sigDigits(exportWave1)=16, sigDigits(exportWave2)=16
	
	filename = GetDefaultFieldmapFilename(spectra=1)	
	sprintf headerStr, "%g\t%g\t%g\t%g\t%g\t%g", stepX, stepV, stepL, nptsX, nptsV, nptsL

	Make/O/T/N=1 spectraHeaderLines
	spectraHeaderLines[0] = headerStr
		
	Open/D TablePath as fieldmapFilepath + filename
	if (strlen(S_FileName) != 0)
		Edit/N=FieldmapHeader spectraHeaderLines
		SaveTableCopy/A=0/O/T=1/W=FieldmapHeader/N=0 as S_fileName
		SaveTableCopy/A=2/T=1/W=FieldmapTable/N=0 as S_fileName
	endif
	Close/A
		
	KillWindow/Z FieldmapTable
	KillWindow/Z FieldmapHeader
	KillWaves/Z spectraHeaderLines	
	Killwaves/Z Bx, By, Bz, exportWave0, exportWave1, exportWave2
	
	return 0

End


Function CAMTO_ViewField_Panel() : Panel
	
	string windowName = "ViewField"
	string windowTitle = "View Magnetic Field"
	string graphName = "Graph"
	string annotationName = "FieldColors"
	string annotationStr = ""	
		
	if (DataFolderExists("root:varsCAMTO")==0)
		DoAlert 0, "CAMTO variables not found."
		return -1
	endif

	WAVE colorH = root:wavesCAMTO:colorH
	WAVE colorV = root:wavesCAMTO:colorV
	WAVE colorL = root:wavesCAMTO:colorL
	
	DoWindow/K $windowName
	NewPanel/K=1/N=$windowName/W=(200,150,1380,625) as windowTitle
	SetDrawLayer UserBack
		
	CAMTO_SubViewField_Panel(windowName, 0, 0)
	
	Display/W=(370,10,1170,465)/HOST=$windowName/N=$graphName	

	sprintf annotationStr, "%s\\K(%d,%d,%d) Horizontal \r", annotationStr, colorH[0], colorH[1], colorH[2]
	sprintf annotationStr, "%s\\K(%d,%d,%d) Vertical \r", annotationStr, colorV[0], colorV[1], colorV[2]
	sprintf annotationStr, "%s\\K(%d,%d,%d) Longitudinal", annotationStr, colorL[0], colorL[1], colorL[2]
	TextBox/W=$windowName#$graphName/A=LT/C/N=$annotationName annotationStr
	
	AddFieldmapOptions(windowName, 435, 5, 350)

	UpdatePanelViewField()

	return 0
			
End


Function CAMTO_SubViewField_Panel(windowName, startH, startV)
	string windowName
	variable startH, startV

	string subwindowName = "SubViewField"
	
	NewPanel/W=(startH, startV, startH+360, startV+435)/HOST=$windowName/N=$subwindowName
	SetDrawLayer UserBack
		
	variable m, h, h1, l1, l2, l 
	m = 20	
	h = 10
	h1 = 8
	l1 = 8
	l2 = 350

	TitleBox tbxTitle1, pos={0,h}, size={360,20}, fsize=14, frame=0, fstyle=1, anchor=MC, title="Field At Point"
	h += 25
	
	SetVariable svarPosX, pos={m,h+10}, size={140,20}, title="Pos X [mm]"
	SetVariable svarPosL, pos={m,h+40}, size={140,20}, title="Pos L [mm]"
	ValDisplay vdispFieldX, pos={m+150,h}, size={170,20}, limits={0,0,0}, barmisc={0,1000}, title="Field X [T]"
	ValDisplay vdispFieldY, pos={m+150,h+25}, size={170,20}, limits={0,0,0}, barmisc={0,1000}, title="Field Y [T]"
	ValDisplay vdispFieldZ, pos={m+150,h+50}, size={170,20}, limits={0,0,0}, barmisc={0,1000}, title="Field Z [T]"
	h += 75

	Button btnFieldAtPoint, pos={m,h}, size={320,25}, fstyle=1, title="Get Field at Point"
	Button btnFieldAtPoint, proc=CAMTO_SubViewField_BtnFieldAtPoint
	h += 35

	SetDrawEnv fillpat=0
	DrawRect l1,h1,l2,h-5
	h1 = h-5
	
	TitleBox tbxTitle2, pos={0,h}, size={360,20}, fsize=14, frame=0, fstyle=1, anchor=MC, title="Longitudinal Profile"
	h += 25
	
	Button btnLongitudinalProfile, pos={m,h}, size={150,25}, fstyle=1, title="Show field at X [mm] ="
	Button btnLongitudinalProfile, proc=CAMTO_SubViewField_BtnLProfile
	SetVariable svarPlotX, pos={m+160,h+4}, size={80,25}, title=" "
	CheckBox chbAppend, pos={m+250,h+5}, size={80,25}, title="Append"
	h += 35

	SetDrawEnv fillpat=0
	DrawRect l1,h1,l2,h-5
	h1 = h-5

	TitleBox tbxTitle3, pos={0,h}, size={360,20}, fsize=14, frame=0, fstyle=1, anchor=MC, title="Horizontal Profile"
	h += 25

	SetVariable svarPlotStartX, pos={m,h}, size={140,20}, title="Start X [mm]"
	ValDisplay vdispHomX, pos={m+150,h}, size={170,20}, limits={0,0,0}, barmisc={0,1000}, title="Homog. X [%]"
	h += 25
	
	SetVariable svarPlotEndX, pos={m,h}, size={140,20}, title="End X [mm]"
	ValDisplay vdispHomY, pos={m+150,h}, size={170,20}, limits={0,0,0}, barmisc={0,1000}, title="Homog. Y [%]"
	h += 25
	
	SetVariable svarPlotStepX, pos={m,h}, size={140,20}, title="Step X [mm]"
	ValDisplay vdispHomZ, pos={m+150,h}, size={170,20}, limits={0,0,0}, barmisc={0,1000}, title="Homog. Z [%]"	
	h += 25
	
	Button btnHorizontalProfile, pos={m,h}, size={240,25}, fstyle=1, title="Show field and homogeneity at L [mm] ="
	Button btnHorizontalProfile, proc=CAMTO_SubViewField_BtnXProfile
	SetVariable svarPlotL, pos={m+250,h+4}, size={70,25}, title=" "
	h += 35
	
	SetDrawEnv fillpat=0
	DrawRect l1,h1,l2,h-5
	h1 = h-5

	TitleBox tbxTitle4, pos={0,h}, size={360,20}, fsize=14, frame=0, fstyle=1, anchor=MC, title="Field Integrals"
	h += 25

	Button btnFirstInt, pos={m,h}, size={210,25}, fstyle=1, title="Show First Integrals over lines"
	Button btnFirstInt, proc=CAMTO_SubViewField_BtnFirstInt
	Button btnFirstIntTable, pos={m+220,h}, size={100,25}, fstyle=1, title="Show Table"
	Button btnFirstIntTable, proc=CAMTO_SubViewField_BtnFirstIntTable
	h += 30
	
	Button btnSecondInt, pos={m,h}, size={210,25}, fstyle=1, title="Show Second Integrals over lines"
	Button btnSecondInt, proc=CAMTO_SubViewField_BtnSecondInt
	Button btnSecondIntTable, pos={m+220,h}, size={100,25}, fstyle=1, title="Show Table"
	Button btnSecondIntTable, proc=CAMTO_SubViewField_BtnSecondIntTable
	h += 35

	SetDrawEnv fillpat=0
	DrawRect l1,h1,l2,h-5
	h1 = h-5

	return 0
	
End


Static Function UpdatePanelViewField()

	string windowName = "ViewField"

	if (WinType(windowName)==0)
		return -1
	endif
	
	UpdatePanelSubViewField(windowName)
	
	return 0

End


Static Function UpdatePanelSubViewField(windowName)
	string windowName

	string subwindowName = "SubViewField"

	SVAR df = root:varsCAMTO:FIELDMAP_FOLDER

	if (strlen(df) > 0 && cmpstr(df, "_none_")!=0)				
		NVAR startX = root:$(df):varsFieldmap:LOAD_START_X
		NVAR endX = root:$(df):varsFieldmap:LOAD_END_X
		NVAR stepX = root:$(df):varsFieldmap:LOAD_STEP_X
		NVAR startL = root:$(df):varsFieldmap:LOAD_START_L
		NVAR endL = root:$(df):varsFieldmap:LOAD_END_L
		NVAR stepL = root:$(df):varsFieldmap:LOAD_STEP_L
 
		NVAR posX = root:$(df):varsFieldmap:VIEW_POS_X
		NVAR posL = root:$(df):varsFieldmap:VIEW_POS_L	
		NVAR plotX = root:$(df):varsFieldmap:VIEW_PLOT_X
		NVAR appendField = root:$(df):varsFieldmap:VIEW_APPEND_FIELD
		NVAR plotStartX = root:$(df):varsFieldmap:VIEW_PLOT_START_X
		NVAR plotEndX = root:$(df):varsFieldmap:VIEW_PLOT_END_X
		NVAR plotStepX = root:$(df):varsFieldmap:VIEW_PLOT_STEP_X
		NVAR plotL = root:$(df):varsFieldmap:VIEW_PLOT_L
						
		SetVariable svarPosX, win=$windowName#$subwindowName, value=posX, limits={startX, endX, stepX}
		SetVariable svarPosL, win=$windowName#$subwindowName, value=posL, limits={startL, endL, stepL}
		SetVariable svarPlotX, win=$windowName#$subwindowName, value=plotX, limits={startX, endX, stepX}
		SetVariable svarPlotStartX, win=$windowName#$subwindowName, value=plotStartX, limits={startX, endX, stepX}
		SetVariable svarPlotEndX, win=$windowName#$subwindowName, value=plotEndX, limits={startX, endX, stepX}
		SetVariable svarPlotStepX, win=$windowName#$subwindowName, value=plotStepX, limits={0, (endX - startX), 1}
		SetVariable svarPlotL, win=$windowName#$subwindowName, value=plotL, limits={startL, endL, stepL}
		
		ValDisplay vdispFieldX, win=$windowName#$subwindowName, value=#("root:" + df + ":varsFieldmap:VIEW_FIELD_X")
		ValDisplay vdispFieldY, win=$windowName#$subwindowName, value=#("root:" + df + ":varsFieldmap:VIEW_FIELD_Y")
		ValDisplay vdispFieldZ, win=$windowName#$subwindowName, value=#("root:" + df + ":varsFieldmap:VIEW_FIELD_Z")
		ValDisplay vdispHomX, win=$windowName#$subwindowName, value=#("root:" + df + ":varsFieldmap:VIEW_HOM_X")
		ValDisplay vdispHomY, win=$windowName#$subwindowName, value=#("root:" + df + ":varsFieldmap:VIEW_HOM_Y")
		ValDisplay vdispHomZ, win=$windowName#$subwindowName, value=#("root:" + df + ":varsFieldmap:VIEW_HOM_Z")

		CheckBox chbAppend, win=$windowName#$subwindowName, variable=appendField, disable=0		
		Button btnFieldAtPoint, win=$windowName#$subwindowName, disable=0
		Button btnLongitudinalProfile, win=$windowName#$subwindowName, disable=0
		Button btnHorizontalProfile, win=$windowName#$subwindowName, disable=0
		Button btnFirstInt, win=$windowName#$subwindowName, disable=0
		Button btnFirstIntTable, win=$windowName#$subwindowName, disable=0
		Button btnSecondInt, win=$windowName#$subwindowName, disable=0
		Button btnSecondIntTable, win=$windowName#$subwindowName, disable=0
		
	else
		CheckBox chbAppend, win=$windowName#$subwindowName, disable=2
		Button btnFieldAtPoint, win=$windowName#$subwindowName, disable=2
		Button btnLongitudinalProfile, win=$windowName#$subwindowName, disable=2
		Button btnHorizontalProfile, win=$windowName#$subwindowName, disable=2
		Button btnFirstInt, win=$windowName#$subwindowName, disable=2
		Button btnFirstIntTable, win=$windowName#$subwindowName, disable=2
		Button btnSecondInt, win=$windowName#$subwindowName, disable=2
		Button btnSecondIntTable, win=$windowName#$subwindowName, disable=2
	
	endif

	return 0
	
End


Function CAMTO_SubViewField_BtnFieldAtPoint(ba) : ButtonControl
	struct WMButtonAction &ba

	switch(ba.eventCode)
		case 2:		
			if (IsCorrectFolder() == -1)
				return -1
			endif
		
			NVAR posX = :varsFieldmap:VIEW_POS_X
			NVAR posL = :varsFieldmap:VIEW_POS_L
			NVAR fieldX = :varsFieldmap:FIELD_X
			NVAR fieldY = :varsFieldmap:FIELD_Y
			NVAR fieldZ = :varsFieldmap:FIELD_Z			
			NVAR viewFieldX = :varsFieldmap:VIEW_FIELD_X
			NVAR viewFieldY = :varsFieldmap:VIEW_FIELD_Y
			NVAR viewFieldZ = :varsFieldmap:VIEW_FIELD_Z	
			
			CalcFieldAtPoint(posX/1000, posL/1000)
			
			viewFieldX = fieldX
			viewFieldY = fieldY
			viewFieldZ = fieldZ
			
			break
	endswitch
	
	return 0

End


Function CAMTO_SubViewField_BtnLProfile(ba) : ButtonControl
	struct WMButtonAction &ba

	switch(ba.eventCode)
		case 2:		
			if (IsCorrectFolder() == -1)
				return -1
			endif
			
			variable subwindow
			string windowName, subwindowName, graphXName, graphYName, graphZName	
			
			SplitString/E=("([[:alpha:]]+)#([[:alpha:]]+)") ba.win, windowName, subwindowName
			
			if (!cmpstr(windowName, "ViewField"))
				graphXName = windowName + "#Graph"
				graphYName = graphXName
				graphZName = graphXName
				subwindow = 1
			else
				graphXName = "LongitudinalProfileX"
				graphYName = "LongitudinalProfileY"
				graphZName = "LongitudinalProfileZ"
				subwindow = 0
			endif
						
			PlotFieldLongitudinalProfile(graphXName, graphYName, graphZName, subwindow)
			
			break
	endswitch
	
	return 0

End


Function CAMTO_SubViewField_BtnXProfile(ba) : ButtonControl
	struct WMButtonAction &ba

	switch(ba.eventCode)
		case 2:		
			if (IsCorrectFolder() == -1)
				return -1
			endif
			
			variable subwindow
			string windowName, subwindowName, graphXName, graphYName, graphZName	
			
			SplitString/E=("([[:alpha:]]+)#([[:alpha:]]+)") ba.win, windowName, subwindowName
			
			if (!cmpstr(windowName, "ViewField"))
				graphXName = windowName + "#Graph"
				graphYName = graphXName
				graphZName = graphXName
				subwindow = 1
			else
				graphXName = "HorizontalProfileX"
				graphYName = "HorizontalProfileY"
				graphZName = "HorizontalProfileZ"
				subwindow = 0
			endif
						
			PlotFieldHorizontalProfile(graphXName, graphYName, graphZName, subwindow)
			
			break
	endswitch
	
	return 0

End


Function CAMTO_SubViewField_BtnFirstInt(ba) : ButtonControl
	struct WMButtonAction &ba

	switch(ba.eventCode)
		case 2:		
			if (IsCorrectFolder() == -1)
				return -1
			endif
			
			variable subwindow
			string windowName, subwindowName, graphXName, graphYName, graphZName	
			
			SplitString/E=("([[:alpha:]]+)#([[:alpha:]]+)") ba.win, windowName, subwindowName
			
			if (!cmpstr(windowName, "ViewField"))
				graphXName = windowName + "#Graph"
				graphYName = graphXName
				graphZName = graphXName
				subwindow = 1
			else
				graphXName = "FirstIntegralX"
				graphYName = "FirstIntegralY"
				graphZName = "FirstIntegralZ"
				subwindow = 0
			endif
						
			PlotFieldIntegral(graphXName, graphYName, graphZName, subwindow, secondIntegral=0)
			
			break
	endswitch
	
	return 0

End


Function CAMTO_SubViewField_BtnSecondInt(ba) : ButtonControl
	struct WMButtonAction &ba

	switch(ba.eventCode)
		case 2:		
			if (IsCorrectFolder() == -1)
				return -1
			endif
			
			variable subwindow
			string windowName, subwindowName, graphXName, graphYName, graphZName	
			
			SplitString/E=("([[:alpha:]]+)#([[:alpha:]]+)") ba.win, windowName, subwindowName
			
			if (!cmpstr(windowName, "ViewField"))
				graphXName = windowName + "#Graph"
				graphYName = graphXName
				graphZName = graphXName
				subwindow = 1
			else
				graphXName = "FirstIntegralX"
				graphYName = "FirstIntegralY"
				graphZName = "FirstIntegralZ"
				subwindow = 0
			endif
						
			PlotFieldIntegral(graphXName, graphYName, graphZName, subwindow, secondIntegral=1)
			
			break
	endswitch
	
	return 0

End


Function CAMTO_SubViewField_BtnFirstIntTable(ba) : ButtonControl
	struct WMButtonAction &ba

	switch(ba.eventCode)
		case 2:		
			if (IsCorrectFolder() == -1)
				return -1
			endif
			
			WAVE posX, Int_Bx, Int_By, Int_Bz
			
			Edit/N=FirstIntegral/K=1 posX, Int_Bx, Int_By, Int_Bz
			
			break
	endswitch
	
	return 0

End


Function CAMTO_SubViewField_BtnSecondIntTable(ba) : ButtonControl
	struct WMButtonAction &ba

	switch(ba.eventCode)
		case 2:		
			if (IsCorrectFolder() == -1)
				return -1
			endif
			
			WAVE posX, Int2_Bx, Int2_By, Int2_Bz
			
			Edit/N=SecondIntegral/K=1 posX, Int2_Bx, Int2_By, Int2_Bz
			
			break
	endswitch
	
	return 0

End


Static Function DeleteTracesFromGraph(graphName)
	string graphName

	string allTraces, traceName
	variable i, nrTraces
	
	allTraces = TraceNameList(graphName, ";", 1)
	nrTraces = ItemsInList(allTraces, ";")
	
	for (i=nrTraces-1; i>=0; i=i-1)
		traceName = StringFromList(i, allTraces)
		RemoveFromGraph/W=$graphName $traceName
	endfor

	return 0

End


Static Function ConfigureGraph(graphName, xlabel, ylabel)
	string graphName, xlabel, ylabel
	
	WAVE colorGrid = root:wavesCAMTO:colorGrid	

	Label/W=$graphName bottom xlabel
	Label/W=$graphName left ylabel		
	ModifyGraph/W=$graphName grid=1
	ModifyGraph/W=$graphName gridRGB=(colorGrid[0], colorGrid[1], colorGrid[2])
	
	return 0

End


Static Function ChangeTraceColor(graphName, traceName, component)
	string graphName, traceName, component
	
	WAVE colorH = root:wavesCAMTO:colorH
	WAVE colorV = root:wavesCAMTO:colorV
	WAVE colorL = root:wavesCAMTO:colorL
	NVAR beamDirection = :varsFieldmap:LOAD_BEAM_DIRECTION

	strswitch(component)
		case "x":
			ModifyGraph/W=$graphName rgb($traceName)=(colorH[0], colorH[1], colorH[2])
			
			break
		
		case "y":
			if (beamDirection == 1)
				ModifyGraph/W=$graphName rgb($traceName)=(colorL[0], colorL[1], colorL[2])
			else
				ModifyGraph/W=$graphName rgb($traceName)=(colorV[0], colorV[1], colorV[2])
			endif
			
			break
		
		case "z":
			if (beamDirection == 1)
				ModifyGraph/W=$graphName rgb($traceName)=(colorV[0], colorV[1], colorV[2])
			else
				ModifyGraph/W=$graphName rgb($traceName)=(colorL[0], colorL[1], colorL[2])
			endif
			
			break
	
	endswitch
	
	return 0
	
End


Static Function PlotFieldLongitudinalProfile(graphXName, graphYName, graphZName, subwindow)
	string graphXName, graphYName, graphZName
	variable subwindow
	
	NVAR tol = root:varsCAMTO:POSITION_TOLERANCE

	NVAR plotX = :varsFieldmap:VIEW_PLOT_X
	NVAR appendField =:varsFieldmap:VIEW_APPEND_FIELD
	NVAR fieldX =:varsFieldmap:FIELD_X
	NVAR fieldY =:varsFieldmap:FIELD_Y
	NVAR fieldZ =:varsFieldmap:FIELD_Z

	WAVE posX, posL

	variable i
	string posXStr, posXStrmm, traceNames
	string tnX, tnY, tnZ, wnX, wnY, wnZ
	
	if (subwindow)
		traceNames = TraceNameList(graphXName, ";", 1)
		if (!appendField || strsearch(traceNames, "horizontalProfile_Bx", 0) != -1)
			DeleteTracesFromGraph(graphXName)
			DeleteTracesFromGraph(graphYName)
			DeleteTracesFromGraph(graphZName)
		endif
	
	else
		if (!appendField)
			DoWindow/K $graphXName
			DoWindow/K $graphYName
			DoWindow/K $graphZName
		endif
		
		DoWindow/F $graphXName
		DoWindow/F $graphYName
		DoWindow/F $graphZName
		
		if(V_Flag == 0)
			Display/N=$graphXName/K=1
			Display/N=$graphYName/K=1
			Display/N=$graphZName/K=1
		endif
			
	endif
	
	posXStrmm = num2str(plotX)
	tnX = "Bx x=" + posXStrmm + "mm"
	tnY = "By x=" + posXStrmm + "mm"
	tnZ = "Bz x=" + posXStrmm + "mm"
	
	traceNames = TraceNameList(graphXName, ";", 1)
	if (strsearch(traceNames, tnX, 0) != -1)
		return -1
	endif

	posXStr = num2str(plotX/1000)
	wnX = "Bx_X" + posXStr
	wnY = "By_X" + posXStr
	wnZ = "Bz_X" + posXStr
 	
 	FindValue/T=(tol)/V=(plotX/1000) posX
	if (V_Value != -1)
		WAVE waveBx = $wnX
		WAVE waveBy = $wnY
		WAVE waveBz = $wnZ
	
	else
		Make/O/N=(numpnts(posL)) $wnX
		Make/O/N=(numpnts(posL)) $wnY
		Make/O/N=(numpnts(posL)) $wnZ
		WAVE waveBx = $wnX
		WAVE waveBy = $wnY
		WAVE waveBz = $wnZ
		
		for(i=0; i<numpnts(posL); i++)
			CalcFieldAtPoint(plotX/1000, posL[i])
			waveBx[i] = fieldX
			waveBy[i] = fieldY
			waveBz[i] = fieldZ
		endfor	
	
	endif
	
	Appendtograph/W=$graphXName waveBx/TN=$tnX vs posL
	ChangeTraceColor(graphXName, tnX, "x")
	
	Appendtograph/W=$graphYName waveBy/TN=$tnY vs posL
	ChangeTraceColor(graphYName, tnY, "y")
	
	Appendtograph/W=$graphZName waveBz/TN=$tnZ vs posL
	ChangeTraceColor(graphZName, tnZ, "z")
	
	if (subwindow)
		ConfigureGraph(graphXName, "Longitudinal Position [m]", "Field [T]")
	
	else
		ConfigureGraph(graphXName, "Longitudinal Position [m]", "Field Bx[T]")
		ConfigureGraph(graphYName, "Longitudinal Position [m]", "Field By[T]")
		ConfigureGraph(graphZName, "Longitudinal Position [m]", "Field Bz[T]")
	endif

End


Static Function PlotFieldHorizontalProfile(graphXName, graphYName, graphZName, subwindow)
	string graphXName, graphYName, graphZName
	variable subwindow

	NVAR fieldX =:varsFieldmap:FIELD_X
	NVAR fieldY =:varsFieldmap:FIELD_Y
	NVAR fieldZ =:varsFieldmap:FIELD_Z

	NVAR startX = :varsFieldmap:LOAD_START_X
	NVAR endX = :varsFieldmap:LOAD_END_X
	NVAR stepX = :varsFieldmap:LOAD_STEP_X
	
	NVAR plotStartX = :varsFieldmap:VIEW_PLOT_START_X
	NVAR plotEndX = :varsFieldmap:VIEW_PLOT_END_X
	NVAR plotStepX = :varsFieldmap:VIEW_PLOT_STEP_X
	NVAR homX = :varsFieldmap:VIEW_HOM_X
	NVAR homY = :varsFieldmap:VIEW_HOM_Y
	NVAR homZ = :varsFieldmap:VIEW_HOM_Z
	NVAR plotL = :varsFieldmap:VIEW_PLOT_L

	variable i, nptsX
	string wnX, wnY, wnZ

	if (subwindow)
		DeleteTracesFromGraph(graphXName)
		DeleteTracesFromGraph(graphYName)
		DeleteTracesFromGraph(graphZName)
	
	else
		DoWindow/K $graphXName
		DoWindow/K $graphYName
		DoWindow/K $graphZName
		
		Display/N=$graphXName/K=1
		Display/N=$graphYName/K=1
		Display/N=$graphZName/K=1
		
	endif

	Make/D/O horizontalProfile_posX
	if (plotStartX == startX && plotEndX == endX && plotStepX == stepX)
		WAVE posX
		Duplicate/O posX, horizontalProfile_posX
		nptsX = numpnts(horizontalProfile_posX)
	
	else
		if (plotStepX == 0)
		   plotStepX = 1
		endif
		nptsX = Round((plotEndX - plotStartX)/plotStepX + 1)
		Redimension/N=(nptsX) horizontalProfile_posX
		horizontalProfile_posX = (plotStartX + plotStepX*p) / 1000
	
	endif

	wnX = "horizontalProfile_Bx"
	wnY = "horizontalProfile_By"
	wnZ = "horizontalProfile_Bz"
	Make/O/N=(nptsX) $wnX
	Make/O/N=(nptsX) $wnY
	Make/O/N=(nptsX) $wnZ
	WAVE waveBx = $wnX
	WAVE waveBy = $wnY
	WAVE waveBz = $wnZ

	for(i=0; i<nptsX; i++)
		CalcFieldAtPoint(horizontalProfile_posX[i], plotL/1000)
		waveBx[i] = fieldX
		waveBy[i] = fieldY
		waveBz[i] = fieldZ
	endfor	

	homX = 100*Abs((WaveMax(waveBx) - WaveMin(waveBx))/WaveMax(waveBx))
	homY = 100*Abs((WaveMax(waveBy) - WaveMin(waveBy))/WaveMax(waveBy))
	homZ = 100*Abs((WaveMax(waveBz) - WaveMin(waveBz))/WaveMax(waveBz))

	Appendtograph/W=$graphXName waveBx vs horizontalProfile_posX
	ChangeTraceColor(graphXName, wnX, "x")
	
	Appendtograph/W=$graphYName waveBy vs horizontalProfile_posX
	ChangeTraceColor(graphYName, wnY, "y")
	
	Appendtograph/W=$graphZName waveBz vs horizontalProfile_posX
	ChangeTraceColor(graphZName, wnZ, "z")
	
	if (subwindow)
		ConfigureGraph(graphXName, "Horizontal Position [m]", "Field [T]")
	
	else
		ConfigureGraph(graphXName, "Horizontal Position [m]", "Field Bx[T]")
		ConfigureGraph(graphYName, "Horizontal Position [m]", "Field By[T]")
		ConfigureGraph(graphZName, "Horizontal Position [m]", "Field Bz[T]")

	endif

End


Static Function PlotFieldIntegral(graphXName, graphYName, graphZName, subwindow, [secondIntegral])
	string graphXName, graphYName, graphZName
	variable subwindow, secondIntegral

	if (ParamIsDefault(secondIntegral))
		secondIntegral = 0
	endif

	WAVE posX
	
	string wnX, wnY, wnZ, ylabel, yunit
	
	if (subwindow)
		DeleteTracesFromGraph(graphXName)
		DeleteTracesFromGraph(graphYName)
		DeleteTracesFromGraph(graphZName)
	
	else
		DoWindow/K $graphXName
		DoWindow/K $graphYName
		DoWindow/K $graphZName
		
		Display/N=$graphXName/K=1
		Display/N=$graphYName/K=1
		Display/N=$graphZName/K=1
		
	endif

	if (secondIntegral)
		wnX = "Int2_Bx"
		wnY = "Int2_By"
		wnZ = "Int2_Bz"
		ylabel = "Second Integral"
		yunit = "[T.m²]"
	else
		wnX = "Int_Bx"
		wnY = "Int_By"
		wnZ = "Int_Bz"
		ylabel = "First Integral"	
		yunit = "[T.m]"
	endif
	
	WAVE waveBx = $wnX
	WAVE waveBy = $wnY
	WAVE waveBz = $wnZ

	Appendtograph/W=$graphXName waveBx vs posX
	ChangeTraceColor(graphXName, wnX, "x")
	
	Appendtograph/W=$graphYName waveBy vs posX
	ChangeTraceColor(graphYName, wnY, "y")
	
	Appendtograph/W=$graphZName waveBz vs posX
	ChangeTraceColor(graphZName, wnZ, "z")
	
	if (subwindow)
		ConfigureGraph(graphXName, "Horizontal Position [m]", (ylabel + " " + yunit))
	
	else
		ConfigureGraph(graphXName, "Horizontal Position [m]", (ylabel + " Bx " + yunit))
		ConfigureGraph(graphYName, "Horizontal Position [m]", (ylabel + " By " + yunit))
		ConfigureGraph(graphZName, "Horizontal Position [m]", (ylabel + " Bz " + yunit))

	endif

End


Function CAMTO_Traj_Panel() : Panel
	
	string windowName = "Traj"
	string windowTitle = "Trajectories"
	string graphName = "Graph"
	string annotationName = "TrajColors"
	string annotationStr = ""

	if (DataFolderExists("root:varsCAMTO")==0)
		DoAlert 0, "CAMTO variables not found."
		return -1
	endif

	WAVE colorH = root:wavesCAMTO:colorH
	WAVE colorV = root:wavesCAMTO:colorV

	DoWindow/K $windowName
	NewPanel/K=1/N=$windowName/W=(440,200,1590,755) as windowTitle
	SetDrawLayer UserBack

	variable m, h, h1, l1, l2, l 
	m = 20	
	h = 10
	h1 = 5	
	l1 = 5
	l2 = 320

	TitleBox tbxTitle1, pos={0,h}, size={320,25}, fsize=18, frame=0, fstyle=1, anchor=MT, title="Particle Trajectory"
	h += 35

	SetDrawEnv fillpat=0
	DrawRect l1,h1,l2,h-5
	h1 = h-5

	PopupMenu popupCalcMethod, pos={m,h}, size={280,20}, bodyWidth=160, title="Calculation Method "
	PopupMenu popupCalcMethod, mode=1, popvalue="Analytical", value=#"\"Analytical;Runge_Kutta\""
	PopupMenu popupCalcMethod, proc=CAMTO_Traj_PopupCalcMethod
	h += 25

	SetVariable svarEnergy, pos={m,h}, size={280,20}, title="Particle Eenergy [GeV] "
	h += 25
	
	CheckBox chbIgnoreOutMatrix, pos={m,h}, size={290,20}, title=" Use constant field if trajectory is out of field matrix"
	h += 30
	
	SetDrawEnv fillpat=0
	DrawRect l1,h1,l2,h-5
	h1 = h-5

	TitleBox tbxTitle2, pos={0,h}, size={320,20}, fsize=14, frame=0, fstyle=1, anchor=MC, title="Horizontal Position"
	h += 25

	PopupMenu popupSingleMulti, pos={m,h}, size={280,20}, bodyWidth=160, title="Number of Particles "
	PopupMenu popupSingleMulti, mode=1, popvalue="Single-Particle", value=#"\"Single-Particle;Multi-Particle\""
	PopupMenu popupSingleMulti, proc=CAMTO_Traj_PopupSingleMulti
	h += 25

	SetVariable svarStartX, pos={m,h}, size={290,20}, title="Start X [mm] "
	h += 25
	
	SetVariable svarEndX, pos={m,h}, size={290,20}, title="End X [mm] "
	h += 25
	
	SetVariable svarStepX, pos={m,h}, size={290,20}, title="Step X [mm] "
	h += 30

	SetDrawEnv fillpat=0
	DrawRect l1,h1,l2,h-5
	h1 = h-5
	
	TitleBox tbxTitle3, pos={0,h}, size={320,20}, fsize=14, frame=0, fstyle=1, anchor=MC, title="Longitudinal Position"
	h += 25
	
	SetVariable svarStartL, pos={m,h}, size={130,20}, title="Start L [mm]"
	SetVariable svarEndL, pos={m+160,h}, size={130,20}, title="End L [mm]"
	h += 25
	
	
	CheckBox chbNegativeDirection, pos={m,h}, size={290,20}, title=" Calculate negative and positive trajectories"
	CheckBox chbNegativeDirection, proc=CAMTO_Traj_ChbNegativeDirection
	h += 30

	SetDrawEnv fillpat=0
	DrawRect l1,h1,l2,h-5
	h1 = h-5
	
	TitleBox tbxTitle4, pos={0,h}, size={320,20}, fsize=14, frame=0, fstyle=1, anchor=MC, title="Initial Angles"
	h += 25
	
	SetVariable svarHorizontalAngle, pos={m,h}, size={130,20}, title="Horizontal [°]"
	SetVariable svarVerticalAngle, pos={m+160,h}, size={130,20}, title="Vertical [°]"
	h += 30

	SetDrawEnv fillpat=0
	DrawRect l1,h1,l2,h-5
	h1 = h-5
		
	Button btnCalcTraj, pos={m,h}, size={285,30}, fsize=14, fstyle=1, title="Calculate Trajectories"
	Button btnCalcTraj, proc=CAMTO_Traj_BtnCalcTrajectories
	h += 35

	Button btnShowTraj, pos={m,h}, size={140,30}, fsize=14, fstyle=1, title="Show Trajectories"
	Button btnShowTraj, proc=CAMTO_Traj_BtnShowTrajectories
	CheckBox chbRelativeDisplacement, pos={m+150,h+7}, size={100,20}, title=" Relative Displacement"
	h += 40

	SetDrawEnv fillpat=0
	DrawRect l1,h1,l2,h-5
	h1 = h-5
	
	h = AddFieldmapOptions(windowName, h1, l1, l2, copyConfigProc="CAMTO_Traj_PopupCopyConfig", applyToAllProc="CAMTO_Traj_BtnApplyToAll")

	Display/W=(340,10,1140,545)/HOST=$windowName/N=$graphName	
	sprintf annotationStr, "%s\\K(%d,%d,%d) Horizontal\r", annotationStr, colorH[0], colorH[1], colorH[2]
	sprintf annotationStr, "%s\\K(%d,%d,%d) Vertical", annotationStr, colorV[0], colorV[1], colorV[2]
	TextBox/W=$windowName#$graphName/A=LT/C/N=$annotationName annotationStr

	UpdatePanelTraj()

	return 0
			
End


Static Function UpdatePanelTraj()
	
	SVAR df = root:varsCAMTO:FIELDMAP_FOLDER

	string windowName = "Traj"

	if (WinType(windowName)==0)
		return -1
	endif
	
	UpdateFieldmapOptions(windowName)
	
	if (strlen(df) > 0)
		NVAR particleEnergy = root:$(df):varsFieldmap:TRAJ_PARTICLE_ENERGY
		NVAR calcMethod = root:$(df):varsFieldmap:TRAJ_CALC_METHOD
		NVAR singleMulti = root:$(df):varsFieldmap:TRAJ_SINGLE_MULTI
		NVAR ignoreOutMatrix = root:$(df):varsFieldmap:TRAJ_IGNORE_OUT_MATRIX
		NVAR negativeDirection = root:$(df):varsFieldmap:TRAJ_NEGATIVE_DIRECTION
		NVAR startX = root:$(df):varsFieldmap:TRAJ_START_X
		NVAR endX = root:$(df):varsFieldmap:TRAJ_END_X
		NVAR stepX = root:$(df):varsFieldmap:TRAJ_STEP_X
		NVAR startL = root:$(df):varsFieldmap:TRAJ_START_L
		NVAR endL = root:$(df):varsFieldmap:TRAJ_END_L
		NVAR horizontalAngle = root:$(df):varsFieldmap:TRAJ_HORIZONTAL_ANGLE
		NVAR verticalAngle = root:$(df):varsFieldmap:TRAJ_VERTICAL_ANGLE
	
		SetVariable svarEnergy, win=$windowName, value=particleEnergy
		SetVariable svarStartX, win=$windowName, value=startX
		SetVariable svarEndX, win=$windowName, value=endX
		SetVariable svarStepX, win=$windowName, value=stepX
		SetVariable svarStartL, win=$windowName, value=startL
		SetVariable svarEndL, win=$windowName, value=endL	
		SetVariable svarHorizontalAngle, win=$windowName, value=horizontalAngle
		SetVariable svarVerticalAngle, win=$windowName, value=verticalAngle, disable=2
	
		if (singleMulti == 1)
			SetVariable svarEndX, win=$windowName, disable=2
			SetVariable svarStepX, win=$windowName, disable=2
		else
			SetVariable svarEndX, win=$windowName, disable=0
			SetVariable svarStepX, win=$windowName, disable=0
		endif

		PopupMenu popupCalcMethod, win=$windowName, mode=calcMethod, disable=0
		PopupMenu popupSingleMulti, win=$windowName, mode=singleMulti, disable=0
		CheckBox chbIgnoreOutMatrix, win=$windowName, variable=outMatrix, disable=0
		CheckBox chbNegativeDirection, win=$windowName, variable=negativeDirection, disable=0				
		Button btnCalcTraj, win=$windowName, disable=0
		Button btnShowTraj, win=$windowName, disable=0
	
	else
	
		PopupMenu popupCalcMethod, win=$windowName, disable=2
		PopupMenu popupSingleMulti, win=$windowName, disable=2
		CheckBox chbIgnoreOutMatrix, win=$windowName, disable=2
		CheckBox chbNegativeDirection, win=$windowName, disable=2
		Button btnCalcTraj, win=$windowName, disable=2
		Button btnShowTraj, win=$windowName, disable=2
		
	endif
		
End


Function CAMTO_Traj_PopupCopyConfig(pa) : PopupMenuControl
	struct WMPopupAction &pa

	SVAR fieldmapCopy = root:varsCAMTO:FIELDMAP_COPY

	switch(pa.eventCode)
		case 2:
			if (IsCorrectFolder() == -1)
				return -1
			endif

			fieldmapCopy = pa.popStr
			
			CopyConfigTraj(fieldmapCopy)
			UpdatePanelTraj()
			
			break
	
	endswitch

	return 0

End


Static Function CopyConfigTraj(dfc)
	string dfc

	WAVE/T fieldmapFolders= root:wavesCAMTO:fieldmapFolders
	
	UpdateFieldmapFolders()	
	FindValue/Text=dfc/TXOP=4 fieldmapFolders
	
	if (V_Value!=-1)	
		NVAR temp_df = :varsFieldmap:TRAJ_PARTICLE_ENERGY
		NVAR temp_dfc = root:$(dfc):varsFieldmap:TRAJ_PARTICLE_ENERGY
		temp_df = temp_dfc

		NVAR temp_df = :varsFieldmap:TRAJ_SINGLE_MULTI
		NVAR temp_dfc = root:$(dfc):varsFieldmap:TRAJ_SINGLE_MULTI
		temp_df = temp_dfc
		
		NVAR temp_df = :varsFieldmap:TRAJ_IGNORE_OUT_MATRIX
		NVAR temp_dfc = root:$(dfc):varsFieldmap:TRAJ_IGNORE_OUT_MATRIX
		temp_df = temp_dfc		

		NVAR temp_df = :varsFieldmap:TRAJ_NEGATIVE_DIRECTION
		NVAR temp_dfc = root:$(dfc):varsFieldmap:TRAJ_NEGATIVE_DIRECTION
		temp_df = temp_dfc	

		NVAR temp_df = :varsFieldmap:TRAJ_CALC_METHOD
		NVAR temp_dfc = root:$(dfc):varsFieldmap:TRAJ_CALC_METHOD
		temp_df = temp_dfc		
		
		NVAR temp_df = :varsFieldmap:TRAJ_START_X
		NVAR temp_dfc = root:$(dfc):varsFieldmap:TRAJ_START_X
		temp_df = temp_dfc		
		
		NVAR temp_df = :varsFieldmap:TRAJ_END_X
		NVAR temp_dfc = root:$(dfc):varsFieldmap:TRAJ_END_X
		temp_df = temp_dfc		

		NVAR temp_df = :varsFieldmap:TRAJ_STEP_X
		NVAR temp_dfc = root:$(dfc):varsFieldmap:TRAJ_STEP_X
		temp_df = temp_dfc		
		
		NVAR temp_df = :varsFieldmap:TRAJ_START_L
		NVAR temp_dfc = root:$(dfc):varsFieldmap:TRAJ_START_L
		temp_df = temp_dfc		

		NVAR temp_df = :varsFieldmap:TRAJ_END_L
		NVAR temp_dfc = root:$(dfc):varsFieldmap:TRAJ_END_L
		temp_df = temp_dfc		

		NVAR temp_df = :varsFieldmap:TRAJ_HORIZONTAL_ANGLE
		NVAR temp_dfc = root:$(dfc):varsFieldmap:TRAJ_HORIZONTAL_ANGLE
		temp_df = temp_dfc		

		NVAR temp_df = :varsFieldmap:TRAJ_VERTICAL_ANGLE
		NVAR temp_dfc = root:$(dfc):varsFieldmap:TRAJ_VERTICAL_ANGLE
		temp_df = temp_dfc
				
	else
		DoAlert 0, "Data folder not found."
		return -1
	endif
	
	return 0
		
End


Function CAMTO_Traj_PopupSingleMulti(pa) : PopupMenuControl
	struct WMPopupAction &pa

	NVAR singleMulti = :varsFieldmap:TRAJ_SINGLE_MULTI

	switch(pa.eventCode)
		case 2:
			if (IsCorrectFolder() == -1)
				return -1
			endif

			singleMulti = pa.popNum
							
			if (pa.popNum == 1)
				SetVariable svarEndX, win=$pa.win, disable = 2
				SetVariable svarStepX, win=$pa.win, disable = 2
			else
				SetVariable svarEndX, win=$pa.win, disable = 0
				SetVariable svarStepX, win=$pa.win, disable = 0
			endif

			break
	
	endswitch

	return 0

End


Function CAMTO_Traj_PopupCalcMethod(pa) : PopupMenuControl
	struct WMPopupAction &pa

	NVAR calcMethod = :varsFieldmap:TRAJ_CALC_METHOD

	switch(pa.eventCode)
		case 2:
			if (IsCorrectFolder() == -1)
				return -1
			endif

			calcMethod = pa.popNum

			break
	
	endswitch

	return 0

End


Function CAMTO_Traj_ChbNegativeDirection(ca) : CheckBoxControl
	STRUCT WMCheckboxAction& ca
	
	NVAR startL = :varsFieldmap:TRAJ_START_L

	switch(ca.eventCode)
		case 2:
			if (IsCorrectFolder() == -1)
				return -1
			endif

			if (ca.checked)
				startL = 0
			endif
			
			break
	
	endswitch

	return 0

End


Function CAMTO_Traj_BtnCalcTrajectories(ba) : ButtonControl
	struct WMButtonAction &ba

	switch(ba.eventCode)
		case 2:		
			if (IsCorrectFolder() == -1)
				return -1
			endif
			
			CalcTrajectories()
			UpdateResultsPanel()
			
			break
	endswitch
	
	return 0

End


Function CAMTO_Traj_BtnShowTrajectories(ba) : ButtonControl
	struct WMButtonAction &ba

	switch(ba.eventCode)
		case 2:		
			if (IsCorrectFolder() == -1)
				return -1
			endif
			
			string graphName
			graphName = ba.win + "#Graph"
			
			ControlInfo/W=$ba.win chbRelativeDisplacement
			variable relativeDisplacement = V_Value
			
			ShowTrajectories(graphName, relativeDisplacement)
			
			break
	endswitch
	
	return 0

End


Function CAMTO_Traj_BtnApplyToAll(ba) : ButtonControl
	struct WMButtonAction &ba

	variable i
	string tdf

	switch(ba.eventCode)
		case 2:		
			
			DoAlert 1, "Calculate trajectories for all fieldmaps?"
			if (V_flag != 1)
				return -1
			endif
			
			UpdateFieldmapFolders()
				
			Wave/T fieldmapFolders = root:wavesCAMTO:fieldmapFolders
			NVAR fieldmapCount  = root:varsCAMTO:FIELDMAP_COUNT
			SVAR fieldmapFolder= root:varsCAMTO:FIELDMAP_FOLDER
				
			DFREF df = GetDataFolderDFR()
			string dfc = GetDataFolder(0)
		
			for (i=0; i < fieldmapCount; i=i+1)
				tdf = fieldmapFolders[i]
				fieldmapFolder = tdf
				SetDataFolder root:$(tdf)
				CopyConfigTraj(dfc)
				Print("Calculating Trajectories for " + tdf + ":")
				CalcTrajectories()
			endfor
		
			fieldmapFolder = dfc
			SetDataFolder df
			
			UpdateResultsPanel()
			
			break
	endswitch
	
	return 0

End


Static Function GetLorentzFactor(particleEnergy)
	variable particleEnergy

	NVAR particleCharge = root:varsCAMTO:PARTICLE_CHARGE
	NVAR particleMass = root:varsCAMTO:PARTICLE_MASS
	NVAR lightSpeed = root:varsCAMTO:LIGHT_SPEED

	return particleEnergy*1E9*abs(particleCharge)/(particleMass * lightSpeed^2)
End


Static Function GetParticleVelocity(particleEnergy)
	variable particleEnergy
	
	NVAR particleCharge = root:varsCAMTO:PARTICLE_CHARGE
	NVAR particleMass = root:varsCAMTO:PARTICLE_MASS
	NVAR lightSpeed = root:varsCAMTO:LIGHT_SPEED
	
	variable gama = GetLorentzFactor(particleEnergy)

	return Sqrt((1 - 1/gama^2)*lightSpeed^2)
End


Static Function CalcTrajectories()
	
	NVAR beamDirection = :varsFieldmap:LOAD_BEAM_DIRECTION
	NVAR singleMulti = :varsFieldmap:TRAJ_SINGLE_MULTI
	NVAR outMatrixError = :varsFieldmap:TRAJ_OUT_MATRIX_ERROR
	NVAR startX = :varsFieldmap:TRAJ_START_X
	NVAR endX = :varsFieldmap:TRAJ_END_X
	NVAR stepX = :varsFieldmap:TRAJ_STEP_X
	NVAR startL = :varsFieldmap:TRAJ_START_L
	NVAR endL = :varsFieldmap:TRAJ_END_L

	variable i, j
	variable nrTraj, nptsTraj, numWaves
	variable localOutMatrixError
	variable success
	string posXStr, wn, wnList

	localOutMatrixError = 0

	if (singleMulti==1)
		nrTraj = 1
	else
		nrTraj = (endX - startX)/stepX + 1
	endif       
	
	Make/O/D/N=(nrTraj) trajGridX
	trajGridX = (startX + p*stepX)/1000

	Make/O/D/N=(nrTraj) trajGridIntBx = 0
	Make/O/D/N=(nrTraj) trajGridIntBy = 0
	Make/O/D/N=(nrTraj) trajGridIntBz = 0		

	Make/O/D/N=(nrTraj) trajGridInt2Bx = 0
	Make/O/D/N=(nrTraj) trajGridInt2By = 0
	Make/O/D/N=(nrTraj) trajGridInt2Bz = 0

	Make/O/D/N=(nrTraj) trajGridDeflectionX = 0
	Make/O/D/N=(nrTraj) trajGridDeflectionY = 0
	Make/O/D/N=(nrTraj) trajGridDeflectionZ = 0	
	
	Make/O/D/N=(nrTraj) trajGridTotalDeflectionX = 0
	Make/O/D/N=(nrTraj) trajGridTotalDeflectionY = 0
	Make/O/D/N=(nrTraj) trajGridTotalDeflectionZ = 0	

	wnList = ""
	wnList = wnList + "trajX;trajY;trajZ;trajL;"
	wnList = wnList + "trajVx;trajVy;trajVz;"
	wnList = wnList + "trajBx;trajBy;trajBz;"
	wnList = wnList + "trajIntBx;trajIntBy;trajIntBz;"
	wnList = wnList + "trajInt2Bx;trajInt2By;trajInt2Bz;"
	
	numWaves = ItemsInList(wnList)		

	for (i=0; i<nrTraj; i++)
		// Calculate trajectory for each X position
		posXStr = num2str(trajGridX[i])
		print("Calculating Trajectory X [m] = " + posXStr)
		success = CalcTrajectory(trajGridX[i]*1000, startL, endL)

		if (success == -1)
			return -1
		endif

		if (outMatrixError == 1)
			localOutMatrixError = 1
		endif

		WAVE trajX, trajY, trajZ, trajL
		WAVE trajVx, trajVy, trajVz
		WAVE trajBx, trajBy, trajBz
	
		// Calculate field integrals over trajectory
		Integrate/METH=1 trajBx/X=trajL/D=tempWave
		Duplicate/O tempWave trajIntBx

		Integrate/METH=1 trajIntBx/X=trajL/D=tempWave	  
		Duplicate/O tempWave trajInt2Bx

		Integrate/METH=1 trajBy/X=trajL/D=tempWave
		Duplicate/O tempWave trajIntBy
		
		Integrate/METH=1 trajIntBy/X=trajL/D=tempWave
		Duplicate/O tempWave trajInt2By
		
		Integrate/METH=1 trajBz/X=trajL/D=tempWave
		Duplicate/O tempWave trajIntBz
		
		Integrate/METH=1 trajIntBz/X=trajL/D=tempWave
		Duplicate/O tempWave trajInt2Bz

		Killwaves/Z tempWave
		
		nptsTraj = numpnts(trajX)
		
		trajGridIntBx = trajIntBx[nptsTraj-1]
		trajGridIntBy = trajIntBy[nptsTraj-1]
		trajGridIntBz = trajIntBz[nptsTraj-1]
		
		trajGridInt2Bx = trajInt2Bx[nptsTraj-1]
		trajGridInt2By = trajInt2By[nptsTraj-1]
		trajGridInt2Bz = trajInt2Bz[nptsTraj-1]

		// Calculate deflection
		if (beamDirection == 1)	
			trajGridDeflectionX[i] = atan(trajVx[nptsTraj-1]/trajVy[nptsTraj-1])/pi * 180
			trajGridDeflectionZ[i] = atan(trajVz[nptsTraj-1]/trajVy[nptsTraj-1])/pi * 180
			trajGridTotalDeflectionX[i] = trajGridDeflectionX[i] - atan(trajVx[0]/trajVy[0])/pi * 180
			trajGridTotalDeflectionZ[i] = trajGridDeflectionZ[i] - atan(trajVz[0]/trajVy[0])/pi * 180
		else
			trajGridDeflectionX[i] = atan(trajVx[nptsTraj-1]/trajVz[nptsTraj-1])/pi * 180
			trajGridDeflectionY[i] = atan(trajVy[nptsTraj-1]/trajVz[nptsTraj-1])/pi * 180
			trajGridTotalDeflectionX[i] = trajGridDeflectionX[i] - atan(trajVx[0]/trajVz[0])/pi * 180
			trajGridTotalDeflectionY[i] = trajGridDeflectionY[i] - atan(trajVy[0]/trajVz[0])/pi * 180
		endif

		// Rename waves
		for(j=0; j<numWaves; j++)
    		wn = StringFromList(j, wnList)
    		WAVE w = $(wn)
    		Duplicate/D/O w $(wn + "_X" + posXStr)
    		Killwaves/Z w
		endfor

	endfor	
	
	// Check out of matrix error
	if (localOutMatrixError != 0) 
		DoAlert 0,"At least one trajectory travelled out of the field matrix "
		return -1
	endif

	return 0
	
End


Static Function ShowTrajectories(graphName, relativeDisplacement)
	string graphName 
	variable relativeDisplacement
	
	NVAR beamDirection = root:varsCAMTO:LOAD_BEAM_DIRECTION

	WAVE/Z trajGridX
	
	variable i
	string posXStr, posXStrmm, tnH, tnV
	
	DeleteTracesFromGraph(graphName)

	if (!WaveExists(trajGridX))
		return -1
	endif

	for (i=0; i<numpnts(trajGridX); i++)
		posXStr = num2str(trajGridX[i])
		posXStrmm = num2str(trajGridX[i]*1000)
		
		WAVE wx = $("trajX_X" + posXStr)
		WAVE wy = $("trajY_X" + posXStr)
		WAVE wz = $("trajZ_X" + posXStr)
	
		tnH = "Horizontal x=" + posXStrmm + "mm"
		tnV = "Vertical x=" + posXStrmm + "mm"
		
		if (beamDirection == 1)
			Appendtograph/W=$graphName wx/TN=$tnH vs wy
			Appendtograph/W=$graphName wz/TN=$tnV vs wy

			ChangeTraceColor(graphName, tnH, "x")
			ChangeTraceColor(graphName, tnV, "z")
			
		else
			Appendtograph/W=$graphName wx/TN=$tnH vs wz
			Appendtograph/W=$graphName wy/TN=$tnV vs wz
			
			ChangeTraceColor(graphName, tnH, "x")
			ChangeTraceColor(graphName, tnV, "y")
			
		endif
		
		if (relativeDisplacement)
			ModifyGraph/W=$graphName offset($tnH)={0,-trajGridX[i]}
		endif
		
	endfor
	
	if (relativeDisplacement)
		ConfigureGraph(graphName, "Longitudinal Position [m]", "Trajectory Variation [m]")
	else
		ConfigureGraph(graphName, "Longitudinal Position [m]", "Trajectory [m]")
	endif
	
	return 0
	
End


Static Function CalcTrajectory(startX, startL, endL)
	variable startX, startL, endL

	NVAR calcMethod = :varsFieldmap:TRAJ_CALC_METHOD
	NVAR negativeDirection = :varsFieldmap:TRAJ_NEGATIVE_DIRECTION

	variable i, numWaves
	variable localEndL
	variable success
	string wn, wnList

	wnList = "trajX;trajY;trajZ;trajL;trajVx;trajVy;trajVz;trajBx;trajBy;trajBz;"
	numWaves = ItemsInList(wnList)	

	if (negativeDirection == 1)
		if (startL != 0)
			DoAlert 0, "The initial longitudinal position must be zero."
			return -1
		endif
		localEndL = abs(endL)
	else	
		localEndL = endL
	endif

	if (calcMethod == 1)
		success = CalcTrajectoryAnalytical(startX, startL, localEndL)
	else
		success = CalcTrajectoryRungeKutta(startX, startL, localEndL)
	endif
	
	if (success == -1)
		return -1
	endif

	if (negativeDirection == 1)		
		for(i=0; i<numWaves; i++)
    		wn = StringFromList(i, wnList)
    		WAVE w = $(wn)
     		Duplicate/D/O w $(wn + "Pos")
     		Killwaves/Z w
		endfor

		if (calcMethod == 1)
			success = CalcTrajectoryAnalytical(startX, startL, -localEndL)
		else
			success = CalcTrajectoryRungeKutta(startX, startL, -localEndL)
		endif
		
		if (success == -1)
			for(i=0; i<numWaves; i++)
    			wn = StringFromList(i, wnList)
    			Killwaves/Z $(wn + "Pos")
			endfor
			return -1
		endif
		
		for(i=0; i<numWaves; i++)
    		wn = StringFromList(i, wnList)
    		WAVE w = $(wn)
    		Duplicate/D/O/R=(1, numpnts(w)-1) w $(wn + "Neg")
    		Killwaves/Z w
   		
    		WAVE wpos = $(wn + "Pos")
    		WAVE wneg = $(wn + "Neg")
    		Reverse wneg
    		Concatenate/NP/KILL/O {wneg, wpos}, $(wn)
		endfor

	endif
	
	return 0
	
End


Static Function CalcTrajectoryRungeKutta(startX, startL, endL)
	variable startX, startL, endL

	NVAR particleCharge = root:varsCAMTO:PARTICLE_CHARGE
	NVAR particleMass = root:varsCAMTO:PARTICLE_MASS
	NVAR trajectoryStep = root:varsCAMTO:TRAJECTORY_STEP

	NVAR fieldX = :varsFieldmap:FIELD_X
	NVAR fieldY = :varsFieldmap:FIELD_Y
	NVAR fieldZ = :varsFieldmap:FIELD_Z
	
	NVAR beamDirection = root:varsCAMTO:LOAD_BEAM_DIRECTION
	NVAR particleEnergy = :varsFieldmap:TRAJ_PARTICLE_ENERGY
	NVAR horizontalAngle = :varsFieldmap:TRAJ_HORIZONTAL_ANGLE
	NVAR verticalAngle = :varsFieldmap:TRAJ_VERTICAL_ANGLE
	NVAR ignoreOutMatrix = :varsFieldmap:TRAJ_IGNORE_OUT_MATRIX
	NVAR outMatrixError = :varsFieldmap:TRAJ_OUT_MATRIX_ERROR
		
	WAVE posX, posL

	variable gama = GetLorentzFactor(particleEnergy)
	variable particleVelocity = GetParticleVelocity(particleEnergy)
	
	variable px0, py0, pz0
	variable vx0, vy0, vz0
	variable i, k, nptsTraj
	variable px, py, pz
	variable vx, vy, vz
	variable pxmin, pxmax
	variable plmin, plmax
	variable pl
	variable fx, fy, fz
	variable timeStep
		
	px0 = startX/1000
	if (beamDirection==1)
		py0 = startL/1000
		pz0 = 0
	else
		py0 = 0
		pz0 = startL/1000
	endif

	vx0 = sin(horizontalAngle*pi/180)*particleVelocity
	if (beamDirection == 1)
		vy0 = cos(horizontalAngle*pi/180)*particleVelocity
		vz0 = 0
	else
		vy0 = 0
		vz0 = cos(horizontalAngle*pi/180)*particleVelocity
	endif	
	
	timeStep = trajectoryStep/particleVelocity
	if (startL > endL)
		timeStep = -1*timeStep
	endif

	pxmin = posX[0]
	pxmax = posX[numpnts(posX)-1]

	plmin = posL[0]
	plmax = posL[numpnts(posL)-1]

	if (startL/1000 < plmin || startL/1000 > plmax)
		DoAlert 0, "Initial longitudinal position out of range."
		return -1
	endif

	if (endL/1000 < plmin || endL/1000 > plmax)
		DoAlert 0, "Final longitudinal position out of range."
		return -1
	endif		

	nptsTraj = 2*abs((endL - startL)/1000/trajectoryStep) + 1	
	outMatrixError = 0

	Make/D/O/N=(nptsTraj) trajX = 0
	Make/D/O/N=(nptsTraj) trajY = 0
	Make/D/O/N=(nptsTraj) trajZ = 0
	Make/D/O/N=(nptsTraj) trajVx = 0
	Make/D/O/N=(nptsTraj) trajVy = 0
	Make/D/O/N=(nptsTraj) trajVz = 0
	Make/D/O/N=(nptsTraj) trajBx = 0
	Make/D/O/N=(nptsTraj) trajBy = 0
	Make/D/O/N=(nptsTraj) trajBz = 0

	px = px0
	py = py0
	pz = pz0
	vx = vx0
	vy = vy0
	vz = vz0

	trajX[0] = px
	trajY[0] = py
	trajZ[0] = pz
	trajVx[0] = vx
	trajVy[0] = vy
	trajVz[0] = vz
				
	for (k=1; k<nptsTraj; k++)
		if ((px < pxmin || px > pxmax) && ignoreOutMatrix==0)
			outMatrixError = 1
			break
		endif
		
		if (beamDirection == 1)			
			CalcFieldAtPoint(px, py)
		else
			CalcFieldAtPoint(px, pz)			
		endif
		trajBx[k-1] = fieldX
		trajBy[k-1] = fieldY
		trajBz[k-1] = fieldZ
	
		fx = particleCharge * (vy*fieldZ - vz*fieldY)
		fy = particleCharge * (vz*fieldX - vx*fieldZ)
		fz = particleCharge * (vx*fieldY - vy*fieldX)

		px = px + timeStep*vx
		py = py + timeStep*vy
		pz = pz + timeStep*vz
		
		vx = vx + fx * timeStep/(particleMass*gama)
		vy = vy + fy * timeStep/(particleMass*gama)
		vz = vz + fz * timeStep/(particleMass*gama)
		
		trajX[k] = px
		trajY[k] = py
		trajZ[k] = pz
		trajVx[k] = vx
		trajVy[k] = vy
		trajVz[k] = vz
		
		if (beamDirection == 1)			
			pl = py
		else
			pl = pz			
		endif
		
		if ((timeStep >= 0 && pl >= endL/1000) || (timeStep < 0 && pl <= endL/1000))
			break
		endif
	
	endfor

	nptsTraj = k
	Redimension/D/N=(nptsTraj) trajX
	Redimension/D/N=(nptsTraj) trajY
	Redimension/D/N=(nptsTraj) trajZ
	Redimension/D/N=(nptsTraj) trajVx
	Redimension/D/N=(nptsTraj) trajVy
	Redimension/D/N=(nptsTraj) trajVz
	Redimension/D/N=(nptsTraj) trajBx
	Redimension/D/N=(nptsTraj) trajBy
	Redimension/D/N=(nptsTraj) trajBz		
	
	if (beamDirection == 1)
   		Duplicate/O/D trajY, trajL
   	else
   		Duplicate/O/D trajZ, trajL
	endif
	
	return 0
	
End


Static Function CalcTrajectoryAnalytical(startX, startL, endL)
	variable startX, startL, endL

	NVAR particleCharge = root:varsCAMTO:PARTICLE_CHARGE
	NVAR particleMass = root:varsCAMTO:PARTICLE_MASS
	NVAR trajectoryStep = root:varsCAMTO:TRAJECTORY_STEP

	NVAR fieldX = :varsFieldmap:FIELD_X
	NVAR fieldY = :varsFieldmap:FIELD_Y
	NVAR fieldZ = :varsFieldmap:FIELD_Z
	
	NVAR beamDirection = root:varsCAMTO:LOAD_BEAM_DIRECTION
	NVAR particleEnergy = :varsFieldmap:TRAJ_PARTICLE_ENERGY
	NVAR horizontalAngle = :varsFieldmap:TRAJ_HORIZONTAL_ANGLE
	NVAR verticalAngle = :varsFieldmap:TRAJ_VERTICAL_ANGLE
	NVAR ignoreOutMatrix = :varsFieldmap:TRAJ_IGNORE_OUT_MATRIX
	NVAR outMatrixError = :varsFieldmap:TRAJ_OUT_MATRIX_ERROR
		
	WAVE posX, posL

	variable gama = GetLorentzFactor(particleEnergy)
	variable particleVelocity = GetParticleVelocity(particleEnergy)
	
	variable px0, py0, pz0
	variable vx0, vy0, vz0
	variable i, k, nptsTraj
	variable px, py, pz
	variable vx, vy, vz
	variable pxmin, pxmax
	variable plmin, plmax
	variable pl
	variable fx, fy, fz
	variable timeStep
		
	px0 = startX/1000
	if (beamDirection==1)
		py0 = startL/1000
		pz0 = 0
	else
		py0 = 0
		pz0 = startL/1000
	endif

	vx0 = sin(horizontalAngle*pi/180)*particleVelocity
	if (beamDirection == 1)
		vy0 = cos(horizontalAngle*pi/180)*particleVelocity
		vz0 = 0
	else
		vy0 = 0
		vz0 = cos(horizontalAngle*pi/180)*particleVelocity
	endif	
	
	timeStep = trajectoryStep/particleVelocity
	if (startL > endL)
		timeStep = -1*timeStep
	endif

	pxmin = posX[0]
	pxmax = posX[numpnts(posX)-1]

	plmin = posL[0]
	plmax = posL[numpnts(posL)-1]

	if (startL/1000 < plmin || startL/1000 > plmax)
		DoAlert 0, "Initial longitudinal position out of range."
		return -1
	endif

	if (endL/1000 < plmin || endL/1000 > plmax)
		DoAlert 0, "Final longitudinal position out of range."
		return -1
	endif		

	nptsTraj = 2*abs((endL - startL)/1000/trajectoryStep) + 1	
	outMatrixError = 0

	Make/D/O/N=(nptsTraj) trajX = 0
	Make/D/O/N=(nptsTraj) trajY = 0
	Make/D/O/N=(nptsTraj) trajZ = 0
	Make/D/O/N=(nptsTraj) trajVx = 0
	Make/D/O/N=(nptsTraj) trajVy = 0
	Make/D/O/N=(nptsTraj) trajVz = 0
	Make/D/O/N=(nptsTraj) trajBx = 0
	Make/D/O/N=(nptsTraj) trajBy = 0
	Make/D/O/N=(nptsTraj) trajBz = 0

	px = px0
	py = py0
	pz = pz0
	vx = vx0
	vy = vy0
	vz = vz0

	trajX[0] = px
	trajY[0] = py
	trajZ[0] = pz
	trajVx[0] = vx
	trajVy[0] = vy
	trajVz[0] = vz
	
	variable cte, field, sine, cossine, fieldVel
	cte = gama * particleMass/ particleCharge

	for (k=1; k<nptsTraj; k++)
		if ((px < pxmin || px > pxmax) && ignoreOutMatrix==0)
			outMatrixError = 1
			break
		endif
		
		if (beamDirection == 1)			
			CalcFieldAtPoint(px, py)
		else
			CalcFieldAtPoint(px, pz)			
		endif
		trajBx[k-1] = fieldX
		trajBy[k-1] = fieldY
		trajBz[k-1] = fieldZ
	
		field = Sqrt(fieldX^2 + fieldY^2 + fieldZ^2)
		fieldVel = fieldX*vx + fieldY*vy + fieldZ*vz
		sine = Sin(field * timeStep / cte)
		cossine = Cos(field * timeStep / cte)
		
		trajX[k] = px + (1/field^2) * ( fieldX*timeStep*fieldVel + cte*(1 - cossine)*(fieldZ*vy - fieldY*vz) + (cte*sine/field)*(vx*(fieldY^2 + fieldZ^2) - fieldX*(fieldY*vy + fieldZ*vz))) 
		
		trajY[k] = py + (1/field^2) * ( fieldY*timeStep*fieldVel + cte*(1 - cossine)*(fieldX*vz - fieldZ*vx) + (cte*sine/field)*(vy*(fieldX^2 + fieldZ^2) - fieldY*(fieldX*vx + fieldZ*vz))) 
		
		trajZ[k] = pz + (1/field^2) * ( fieldZ*timeStep*fieldVel + cte*(1 - cossine)*(fieldY*vx - fieldX*vy) + (cte*sine/field)*(vz*(fieldX^2 + fieldY^2) - fieldZ*(fieldX*vx + fieldY*vy)))
	
		trajVx[k] = (1/field^2) * ( fieldX*fieldVel + cossine*(vx*(fieldY^2 + fieldZ^2) - fieldX*(fieldY*vy + fieldZ*vz)) + field*sine*(fieldZ*vy - fieldY*vz))
		
		trajVy[k] = (1/field^2) * ( fieldY*fieldVel + cossine*(vy*(fieldX^2 + fieldZ^2) - fieldY*(fieldX*vx + fieldZ*vz)) + field*sine*(fieldX*vz - fieldZ*vx))
		
		trajVz[k] = (1/field^2) * ( fieldZ*fieldVel + cossine*(vz*(fieldX^2 + fieldY^2) - fieldZ*(fieldX*vx + fieldY*vy)) + field*sine*(fieldY*vx - fieldX*vy))

		px = trajX[k]
		py = trajY[k]
		pz = trajZ[k]
		vx = trajVx[k]
		vy = trajVy[k]
		vz = trajVz[k]
		
		if (beamDirection == 1)			
			pl = py
		else
			pl = pz			
		endif
		
		if ((timeStep >= 0 && pl >= endL/1000) || (timeStep < 0 && pl <= endL/1000))
			break
		endif
	
	endfor

	nptsTraj = k
	Redimension/D/N=(nptsTraj) trajX
	Redimension/D/N=(nptsTraj) trajY
	Redimension/D/N=(nptsTraj) trajZ
	Redimension/D/N=(nptsTraj) trajVx
	Redimension/D/N=(nptsTraj) trajVy
	Redimension/D/N=(nptsTraj) trajVz
	Redimension/D/N=(nptsTraj) trajBx
	Redimension/D/N=(nptsTraj) trajBy
	Redimension/D/N=(nptsTraj) trajBz		

	if (beamDirection == 1)
   		Duplicate/O/D trajY, trajL
   	else
   		Duplicate/O/D trajZ, trajL
	endif
	
	return 0
	
End


Function CAMTO_Results_Panel() : Panel
	
	string windowName = "Results"
	string windowTitle = "Results"

		
	if (DataFolderExists("root:varsCAMTO")==0)
		DoAlert 0, "CAMTO variables not found."
		return -1
	endif

	DoWindow/K $windowName
	NewPanel/K=1/N=$windowName/W=(1200,60,1560,785) as windowTitle
	SetDrawLayer UserBack
		
	CAMTO_SubViewField_Panel(windowName, 0, 0)
	
	UpdatePanelResults()
	
	return 0
			
End


Static Function UpdatePanelResults()

	string windowName = "Results"

	if (WinType(windowName)==0)
		return -1
	endif
	
	UpdatePanelSubViewField(windowName)
	
	return 0

End
// Ok até aqui

Function CAMTO_Peaks_Panel() : Panel

	string windowName = "Peaks"
	string windowTitle = "Find Peaks"
	
	
	if (DataFolderExists("root:varsCAMTO")==0)
		DoAlert 0, "CAMTO variables not found."
		return -1
	endif
	
	DoWindow/K $windowName
	NewPanel/K=1/N=$windowName/W=(1380,60,1703,527) as windowTitle
	SetDrawLayer UserBack

	variable m, h, h1, l1, l2, l 
	m = 10	
	h = 10
	h1 = 5	
	l1 = 5
	l2 = 320

	TitleBox tbxTitle1, pos={0,h}, size={350,25}, fsize=18, frame=0, fstyle=1, anchor=MT, title="Find Peaks and Zeros"
	h += 35
	
	SetDrawEnv fillpat=0
	DrawRect l1,h1,l2,h-5
	h1 = h-5
	
	SetVariable svarPosXPeaks, pos={m,h}, size={170,18}, title="Position in X [mm] "

	PopupMenu popupFieldAxisPeak, pos={m+200,h}, size={106,21}, title="Field Axis "
	PopupMenu popupFieldAxisPeak, mode=1, popvalue="Bx", value=#"\"Bx;By;Bz\""
	PopupMenu popupFieldAxisPeak, proc=CAMTO_PopupFieldAxisPeak
	h += 25
	
	SetVariable svarStepsYZPeaks, pos={m,h}, size={280,18}, title="Interpolation Step [mm]"
	h += 30
	
	SetDrawEnv fillpat=0
	DrawRect l1,h1,l2,h-5
	h1 = h-5
	
	CheckBox chbPeaks, pos={m,h}, size={280,20},mode=1, title=""
	CheckBox chbPeaks, proc=CAMTO_Peaks_ChbPeaks
	
	PopupMenu popupPosNegPeaks, pos={m+20,h}, size={150,21}, title="Peaks "
	PopupMenu popupPosNegPeaks, mode=1, popvalue="Both Peaks", value=#"\"Positive Peaks;Negative Peaks;Both Peaks\""
	PopupMenu popupPosNegPeaks, proc=CAMTO_Peaks_PopupPosNegPeaks
	h += 25
	
	SetVariable svarPeaksAmpl, pos={m,h}, size={305,18}, title="Peak amplitude related to the maximum [%]"
	SetVariable svarPeaksAmpl, limits={0,100,1}
	h += 25
	
	Button btnPeaks, pos={m,h}, size={150,55}, fsize=14, fstyle=1, disable=2, title="Find Peaks"
	Button btnPeaks, proc=CAMTO_Peaks_BtnFindPeaks
	
	TitleBox tbxTitle2, pos={m+180,h},size={120,18},frame=0,title="Average Period [mm] "
	ValDisplay vldAvgPeriodPeaks,pos={m+180,h+20},size={120,18}
	h += 60
	
	Button btnPeaksGraph, pos={m,h},size={140,24}, fstyle=1, disable=2, title="Show Peaks"
	Button btnPeaksGraph, proc=CAMTO_Peaks_BtnGraphPeaks
	
	Button btnPeaksTable, pos={m+170,h},size={140,24}, fstyle=1, disable=2, title="Show Table"
	Button btnPeaksTable, proc=CAMTO_Peaks_BtnTablePeaks
	h += 30
	
	SetDrawEnv fillpat=0
	DrawRect l1,h1,l2,h-5
	h1 = h-5
	
	CheckBox chbZeros, pos={m,h}, size={280,20},mode=1, title="\tZeros "
	CheckBox chbZeros, proc=CAMTO_Peaks_ChbZeros
	h += 25
	
	SetVariable svarZerosAmpl,pos={m,h},size={305,18},title="Stop the search for amplitude lower than [%]"
	SetVariable svarZerosAmpl,limits={0,100,1}
	h += 25
	
	Button btnZeros,pos={m,h},size={150,55},fsize=14,fstyle=1,disable=2,title="Find Zeros"
	Button btnZeros,proc=CAMTO_Peaks_BtnZeros
	
	TitleBox tbxTitle3, pos={m+180,h},size={120,18},frame=0,title="Average Period [mm] "
	ValDisplay vldAvgPeriodZeros,pos={m+180,h+20},size={120,18}
	h += 60
	
	Button btnZerosGraph, pos={m,h},size={140,24}, fstyle=1, disable=2, title="Show Zeros"
	Button btnZerosGraph, proc=CAMTO_Peaks_BtnGraphZeros
	
	Button btnZerosTable, pos={m+170,h},size={140,24}, fstyle=1, disable=2, title="Show Table"
	Button btnZerosTable, proc=CAMTO_Peaks_BtnTableZeros
	h += 30
	
	SetDrawEnv fillpat=0
	DrawRect l1,h1,l2,h-5
	h1 = h-5
	
	SetVariable svarCurrentFieldmap, win=$windowName, pos={m, h}, size={240,20}, noedit=1, title="Current Fieldmap "
	SetVariable svarCurrentFieldmap, win=$windowName, value=root:varsCAMTO:FIELDMAP_FOLDER
	h += 30
	
	SetDrawEnv fillpat=0
	DrawRect l1,h1,l2,h-5
	h1 = h-5
	
	UpdatePanelPeaks()
	
	return 0

End

Static Function UpdatePanelPeaks()

	SVAR df = root:varsCAMTO:FIELDMAP_FOLDER

	string windowName = "Peaks"

	if (WinType(windowName)==0)
		return -1
	endif
	
	UpdateFieldmapOptions(windowName)

	if(strlen(df)>0)
		NVAR startX = root:$(df):varsFieldmap:PEAK_START_X
		NVAR endX = root:$(df):varsFieldmap:PEAK_END_X
		NVAR stepX = root:$(df):varsFieldmap:PEAK_STEP_X
		NVAR stepYZ = root:$(df):varsFieldmap:PEAK_STEP_YZ
		NVAR fieldAxisPeak = root:$(df):varsFieldMap:PEAK_FIELD_AXIS
		NVAR peaksPosNeg = root:$(df):varsFieldMap:PEAK_POS_NEG
		NVAR peaksPeaksAmpl = root:$(df):varsFieldMap:PEAK_PEAKS_AMPL
		NVAR peaksZerosAmpl = root:$(df):varsFieldMap:PEAK_ZEROS_AMPL
		NVAR peaksSelected = root:$(df):varsFieldMap:PEAK_SELECTED

		SetVariable svarPosXPeaks, win=$windowName, value=startX
		SetVariable svarPosXPeaks, win=$windowName,limits={startX, endX, stepX}
		PopupMenu popupFieldAxisPeak, win=$windowName,disable=0, mode=fieldAxisPeak
		SetVariable svarStepsYZPeaks, win=$windowName,value=stepYZ
		SetVariable svarStepsYZPeaks, win=$windowName,limits={0,inf,0}

		PopupMenu popupPosNegPeak, win=$windowName, mode=peaksPosNeg		
		SetVariable svarPeaksAmpl, win=$windowName,value=peaksPeaksAmpl
		SetVariable svarZerosAmpl, win=$windowName,value=peaksZerosAmpl
		ValDisplay  vldAvgPeriodPeaks, win=$windowName, value=#("root:"+ df + ":varsFieldMap:PEAK_AVG_PERIOD_PEAKS" )
		ValDisplay  vldAvgPeriodZeros, win=$windowName, value=#("root:"+ df + ":varsFieldMap:PEAK_AVG_PERIOD_ZEROS" )
		
		CheckBox chbPeaks, win=$windowName, disable=0, value=0
		CheckBox chbZeros, win=$windowName, disable=0, value=0
		
		if (peaksSelected == 1)
			CheckBox chbPeaks, win=$windowName, value=1		
			PopupMenu popupPosNegPeak,win=$windowName,disable=0
			SetVariable svarAmplPeaks,win=$windowName,disable=0
			ValDisplay AvgPeriodPeaks,win=$windowName,disable=0
			TitleBox tbxTitle2,win=$windowName,disable=0
			Button btnPeaks, win=$windowName, disable=0
			Button btnPeaksGraph,win=$windowName, disable=0
			Button btnPeaksTable,win=$windowName, disable=0
			ValDisplay vldAvgPeriodZeros,win=$windowName,disable=2
			SetVariable svarAmplZeros,win=$windowName,disable=2
			TitleBox tbxTitle3,win=$windowName,disable=2
			Button btnZeros, win=$windowName, disable=2
			Button btnZerosGraph,win=$windowName, disable=2
			Button btnZerosTable,win=$windowName, disable=2
		else
			CheckBox chbZeros, win=$windowName, value=1
			PopupMenu popupPosNegPeak,win=$windowName,disable=2
			SetVariable svarAmplPeaks,win=$windowName,disable=2
			ValDisplay AvgPeriodPeaks,win=$windowName,disable=2
			TitleBox tbxTitle2,win=$windowName,disable=2
			Button btnPeaks, win=$windowName, disable=2
			Button btnPeaksGraph,win=$windowName, disable=2
			Button btnPeaksTable,win=$windowName, disable=2
			ValDisplay vldAvgPeriodZeros,win=$windowName,disable=0
			SetVariable svarAmplZeros,win=$windowName,disable=0
			TitleBox tbxTitle3,win=$windowName,disable=0
			Button btnZeros, win=$windowName, disable=0
			Button btnZerosGraph,win=$windowName, disable=0
			Button btnZerosTable,win=$windowName, disable=0
		endif
		
	else
		CheckBox chbPeaks, win=$windowName, disable=2
		CheckBox chbZeros, win=$windowName, disable=2
		PopupMenu popupPosNegPeak,win=$windowName,disable=2
		SetVariable svarAmplPeaks,win=$windowName,disable=2
		ValDisplay vldAvgPeriodPeaks,win=$windowName,disable=2
		TitleBox tbxTitle2,win=$windowName,disable=2
		Button btnPeaks, win=$windowName, disable=2
		Button btnPeaksGraph,win=$windowName, disable=2
		Button btnPeaksTable,win=$windowName, disable=2
		ValDisplay vldAvgPeriodZeros,win=$windowName,disable=2
		SetVariable svarAmplZeros,win=$windowName,disable=2
		TitleBox tbxTitle3,win=$windowName,disable=2
		Button btnZeros, win=$windowName, disable=2
		Button btnZerosGraph,win=$windowName, disable=2
		Button btnZerosTable,win=$windowName, disable=2
	endif
	
End

Function CAMTO_Peaks_ChbPeaks(ca) : CheckBoxControl
	STRUCT WMCheckboxAction& ca
	
	SVAR df = root:varsCAMTO:FIELDMAP_FOLDER
	
	NVAR peaksSelected = root:$(df):varsFieldMap:PEAK_SELECTED

	switch(ca.eventCode)
		case 2:
			if (IsCorrectFolder() == -1)
				return -1
			endif

			if (ca.checked)
				peaksSelected = 1
				UpdatePanelPeaks()
			endif
			
			break
	
	endswitch

	return 0

End

Function CAMTO_Peaks_ChbZeros(ca) : CheckBoxControl
	STRUCT WMCheckboxAction& ca
	
	SVAR df = root:varsCAMTO:FIELDMAP_FOLDER
	
	NVAR peaksSelected = root:$(df):varsFieldMap:PEAK_SELECTED

	switch(ca.eventCode)
		case 2:
			if (IsCorrectFolder() == -1)
				return -1
			endif

			if (ca.checked)
				peaksSelected = 0
				UpdatePanelPeaks()
			endif
			
			break
	
	endswitch

	return 0

End

Function CAMTO_PopupFieldAxisPeak(pa) : PopupMenuControl
	struct WMPopupAction &pa
	
	SVAR df = root:varsCAMTO:FIELDMAP_FOLDER

	SVAR fieldAxisPeakStr = root:$(df):varsFieldMap:PEAK_FIELD_AXIS_STR
	NVAR fieldAxisPeak    = root:$(df):varsFieldMap:PEAK_FIELD_AXIS 
	
	switch(pa.eventCode)
		case 2:
			if (IsCorrectFolder() == -1)
				return -1
			endif
			
			fieldAxisPeak = pa.popNum
			
			if (fieldAxisPeak == 1)
				fieldAxisPeakStr = "Bx"
			elseif (fieldAxisPeak == 2) 
				fieldAxisPeakStr = "By"
			elseif (fieldAxisPeak == 3)
				fieldAxisPeakStr = "Bz"
			endif

			break
	
	endswitch

	return 0

End

Function CAMTO_Peaks_PopupPosNegPeaks(pa) : PopupMenuControl
	struct WMPopupAction &pa
	
	SVAR df = root:varsCAMTO:FIELDMAP_FOLDER

	NVAR peaksPosNeg = root:$(df):varsFieldMap:PEAK_POS_NEG
	peaksPosNeg = pa.popNum
	
	switch(pa.eventCode)
		case 2:
			if (IsCorrectFolder() == -1)
				return -1
			endif
			
			peaksPosNeg = pa.popNum

			break
	
	endswitch

	return 0

End

Function CAMTO_Peaks_BtnFindPeaks(ba) : ButtonControl
	struct WMButtonAction &ba

	switch(ba.eventCode)
		case 2:		
			if (IsCorrectFolder() == -1)
				return -1
			endif
			
			FindPeaks()
			UpdatePanelPeaks()
			
			break
	endswitch
	
	return 0

End

Function CAMTO_Peaks_BtnZeros(ba) : ButtonControl
	struct WMButtonAction &ba

	switch(ba.eventCode)
		case 2:		
			if (IsCorrectFolder() == -1)
				return -1
			endif
			
			FindZeros()
			UpdatePanelPeaks()
			
			break
	endswitch
	
	return 0

End

Function CAMTO_Peaks_BtnGraphPeaks(ba) : ButtonControl
	struct WMButtonAction &ba

	switch(ba.eventCode)
		case 2:		
			if (IsCorrectFolder() == -1)
				return -1
			endif
			
			string graphName
			graphName = ba.win + "Graph"
			
			ShowPeaks(graphName)
			
			break
	endswitch
	
	return 0

End

Function CAMTO_Peaks_BtnGraphZeros(ba) : ButtonControl
	struct WMButtonAction &ba

	switch(ba.eventCode)
		case 2:		
			if (IsCorrectFolder() == -1)
				return -1
			endif
			
			string graphName
			graphName = ba.win + "Graph"
			
			ShowZeros(graphName)
			
			break
	endswitch
	
	return 0

End

Function CAMTO_Peaks_BtnTablePeaks(ba) : ButtonControl
	struct WMButtonAction &ba
	
		switch(ba.eventCode)
		case 2:		
			if (IsCorrectFolder() == -1)
				return -1
			endif
			
			ShowTablePeaks()
			
			break
	endswitch
	
	return 0

End

Function CAMTO_Peaks_BtnTableZeros(ba) : ButtonControl
	struct WMButtonAction &ba
	
		switch(ba.eventCode)
		case 2:		
			if (IsCorrectFolder() == -1)
				return -1
			endif
			
			ShowTableZeros()
			
			break
	endswitch
	
	return 0

End

//Window Results() : Panel
//	PauseUpdate; Silent 1		// building window...
//
//	if (DataFolderExists("root:varsCAMTO")==0)
//		DoAlert 0, "CAMTO variables not found."
//		return 
//	endif
//
//	CloseWindow("Results")
//
//	NewPanel/K=1/W=(1235,60,1573,785)
//	SetDrawEnv fillpat= 0
//	DrawRect 3,5,333,125
//	SetDrawEnv fillpat= 0
//	DrawRect 3,125,333,158
//	SetDrawEnv fillpat= 0
//	DrawRect 3,158,333,275
//	SetDrawEnv fillpat= 0
//	DrawRect 3,275,333,310
//	SetDrawEnv fillpat= 0
//	DrawRect 3,310,333,345
//	SetDrawEnv fillpat= 0
//	DrawRect 3,345,333,445
//	SetDrawEnv fillpat= 0		
//	DrawRect 3,445,333,595
//	SetDrawEnv fillpat= 0		
//	DrawRect 3,595,333,690
//	SetDrawEnv fillpat= 0		
//	DrawRect 3,690,333,720
//	
//	TitleBox field_title,pos={120,10},size={127,16},fsize=16,fstyle=1,frame=0, title="Field Profile"
//	
//	SetVariable PosXField,pos={10,40},size={140,18},title="Pos X [mm]:"
//	SetVariable PosYZField,pos={10,70},size={140,18},title="Pos YZ [mm]:"
//			
//	ValDisplay FieldinPointX,pos={160,32},size={165,17},title="Field X [T]:"
//	ValDisplay FieldinPointX,limits={0,0,0},barmisc={0,1000}
//	ValDisplay FieldinPointY,pos={160,55},size={165,17},title="Field Y  [T]:"
//	ValDisplay FieldinPointY,limits={0,0,0},barmisc={0,1000}
//	ValDisplay FieldinPointZ,pos={160,78},size={165,17},title="Field Z  [T]:"
//	ValDisplay FieldinPointZ,limits={0,0,0},barmisc={0,1000}
//			
//	Button field_point,pos={16,97},size={306,24},proc=Field_in_Point,title="Calculate the field in a point"
//	Button field_point,fstyle=1
//	
//	Button field_Xline,pos={16,130},size={110,24},proc=Field_in_X_Line,title="Show field in X ="
//	Button field_Xline,fstyle=1
//	SetVariable PosXFieldLine,pos={130,134},size={80,18},title="[mm]:"
//	CheckBox graphappend, pos={220,136}, title="Append to Graph"
//	
//	SetVariable StartXProfile,pos={16,170},size={134,18},title="Start X [mm]:"
//	SetVariable EndXProfile,pos={16,195},size={134,18},title="End X [mm]:"
//	SetVariable PosYZProfile,pos={16,221},size={134,18},title="Pos YZ [mm]:"
//		
//	ValDisplay FieldHomX,pos={160,171},size={165,17},title="Homog. X [T]:"
//	ValDisplay FieldHomX,limits={0,0,0},barmisc={0,1000}
//	ValDisplay FieldinPointY1,pos={160,194},size={165,17},title="Homog. Y [T]:"
//	ValDisplay FieldinPointY1,limits={0,0,0},barmisc={0,1000}
//	ValDisplay FieldinPointZ1,pos={160,217},size={165,17},title="Homog. Z [T]:"
//	ValDisplay FieldinPointZ1,limits={0,0,0},barmisc={0,1000}
//		
//	Button field_profile,pos={11,246},size={230,24},proc=Field_Profile,title="Show Field Profile and Homogeneity"
//	Button field_profile,fstyle=1
//	Button field_profile_table,pos={247,246},size={80,24},proc=Field_Profile_Table,title="Show Table"
//	Button field_profile_table,fstyle=1
//	
//	Button show_integrals,pos={11,281},size={230,24},proc=ShowIntegrals,title="Show First Integrals over lines"
//	Button show_integrals,fstyle=1
//	Button show_integrals_table,pos={247,281},size={80,24},proc=show_integrals_Table,title="Show Table"
//	Button show_integrals_table,fstyle=1	
//	
//	Button show_integrals2,pos={11,316},size={230,24},proc=ShowIntegrals2,title="Show Second Integrals over lines"
//	Button show_integrals2,fstyle=1
//	Button show_integrals2_table,pos={247,316},size={80,24},proc=show_integrals2_Table,title="Show Table"
//	Button show_integrals2_table,fstyle=1
//	
//	Button show_multipoles,pos={11,351},size={316,24},proc=ShowMultipoles,title="Show Multipoles Table"
//	Button show_multipoles,fstyle=1
//	
//	Button show_multipoleprofile,pos={11,384},size={230,24},proc=ShowMultipoleProfile,title="Show Multipole Profile: K = "
//	Button show_multipoleprofile,fstyle=1
//	SetVariable mnumber,pos={247,387},size={80,18},title=" "
//	
//	Button show_residmultipoles,pos={11,416},size={230,24},proc=ShowResidMultipoles,title="Show Residual Multipoles"
//	Button show_residmultipoles,fstyle=1
//	Button show_residmultipoles_table,pos={247,416},size={80,24},proc=ShowResidMultipoles_Table,title="Show Table"
//	Button show_residmultipoles_table,fstyle=1
//	
//	TitleBox traj_title1,pos={100,451},size={127,16},fsize=16,fstyle=1,frame=0, title="Particle Trajectory"
//	
//	Button show_trajectories,pos={11,476},size={180,24},proc=ShowTrajectories,title="Show Trajectories"
//	Button show_trajectories,fstyle=1
//	CheckBox referencelines,pos={200,482},size={130,24},title=" Add Reference Lines"
//	
//	Button show_deflections,pos={11,506},size={230,24},proc=ShowDeflections,title="Show Deflections"
//	Button show_deflections,fstyle=1
//	Button show_deflections_Table,pos={247,506},size={80,24},proc=show_deflections_Table,title="Show Table"
//	Button show_deflections_Table,fstyle=1	
//	
//	Button show_integralstraj,pos={11,536},size={230,24},proc=ShowIntegralsTraj,title="Show First Integrals over trajectory"
//	Button show_integralstraj,fstyle=1
//	Button show_integralstraj_Table,pos={247,536},size={80,24},proc=show_integralstraj_Table,title="Show Table"
//	Button show_integralstraj_Table,fstyle=1	
//	
//	Button show_integrals2traj,pos={11,566},size={230,24},proc=ShowIntegrals2Traj,title="Show Second Integrals over trajectory"
//	Button show_integrals2traj,fstyle=1
//	Button show_integrals2traj_Table,pos={247,566},size={80,24},proc=show_integrals2traj_Table,title="Show Table"
//	Button show_integrals2traj_Table,fstyle=1	
//	
//	Button show_dynmultipoles,pos={11,600},size={316,24},proc=ShowDynMultipoles,title="Show Dynamic Multipoles Table"
//	Button show_dynmultipoles,fstyle=1
//	
//	Button show_dynmultipoleprofile,pos={11,630},size={230,24},proc=ShowDynMultipoleProfile,title="Show Dynamic Multipole Profile: K = "
//	Button show_dynmultipoleprofile,fstyle=1
//	SetVariable mtrajnumber,pos={247,633},size={80,18},title=" "
//		
//	Button show_residdynmultipoles,pos={11,660},size={230,24},proc=ShowResidDynMultipoles,title="Show Residual Dynamic Multipoles"
//	Button show_residdynmultipoles,fstyle=1
//	Button show_residdynmultipoles_table,pos={247,660},size={80,24},proc=ShowResidDynMultipoles_Table,title="Show Table"
//	Button show_residdynmultipoles_table,fstyle=1
//
//	SetVariable fieldmapdir,pos={20,697},size={300,18},fstyle=1,title="Fieldmap directory: "
//	SetVariable fieldmapdir,noedit=1,value=root:varsCAMTO:FIELDMAP_FOLDER
//	
//	UpdateFieldmapFolders()
//	UpdateResultsPanel()
//		 
//EndMacro

//Window Integrals_Multipoles() : Panel
//	PauseUpdate; Silent 1		// building window...
//
//	if (DataFolderExists("root:varsCAMTO")==0)
//		DoAlert 0, "CAMTO variables not found."
//		return 
//	endif
//
//	CloseWindow("Integrals_Multipoles")
//
//	NewPanel/K=1/W=(80,250,407,792)
//	SetDrawLayer UserBack
//	SetDrawEnv fillpat= 0
//	DrawRect 3,4,322,185
//	SetDrawEnv fillpat= 0
//	DrawRect 3,185,322,260
//	SetDrawEnv fillpat= 0
//	DrawRect 3,260,322,335
//	SetDrawEnv fillpat= 0
//	DrawRect 3,335,322,420
//	SetDrawEnv fillpat= 0
//	DrawRect 3,420,322,538
//
//					
//	TitleBox title,pos={60,10},size={127,16},fsize=14,fstyle=1,frame=0, title="Field Integrals and Multipoles"
//	TitleBox subtitle,pos={86,30},size={127,16},fsize=14,frame=0, title="K0 to Kx (0 - On, 1 - Off)"
//
//	SetVariable order,pos={10,60},size={220,16},title="Order of Multipolar Analysis:"
//	SetVariable dist,pos={10,85},size={221,16},title="Distance for Multipolar Analysis:"	
//	TitleBox dist_unit,pos={230,85},size={72,16},title=" mm from center",fsize=12,frame=0
//
//	SetVariable norm_K,pos={10,110},size={220,16},title="Normalize Against K:"
//	PopupMenu norm_comp,pos={10,135},size={241,16},proc=PopupMultComponent,title="Component:"
//	PopupMenu norm_comp,value= #"\"Normal;Skew\""
//	
//	TitleBox    grid_title,pos={10, 160},size={90,18},frame=0,title="Horizontal Range:"
//	SetVariable grid_min,pos={110,160},limits={-inf, inf, 0},size={95,18},title="Min [mm]:"
//	SetVariable grid_max,pos={215,160},limits={-inf, inf, 0},size={95,18},title="Max [mm]:"
//
//	TitleBox    mult_title,pos={10, 190},size={90,18},frame=0,title="Multipoles"
//	SetVariable norm_ks,pos={20,210},size={285,16},title="Normal - Ks to Use:"
//	SetVariable skew_ks,pos={20,235},size={285,16},title="\t Skew - Ks to Use:"
//
//	TitleBox    res_title,pos={10, 265},size={90,18},frame=0,title="Residual Normalized Multipoles"
//	SetVariable res_norm_ks,pos={20,285},size={285,16},title="Normal - Ks to Use:"
//	SetVariable res_skew_ks,pos={20,310},size={285,16},title="\t Skew - Ks to Use:"
//
//	Button int_button,pos={12,340},size={300,34},proc=CalcIntegrals,title="Calculate Field Integrals"
//	Button int_button,fsize=15,fstyle=1
//	Button mult_button,pos={12,380},size={300,34},proc=CalcMultipoles,title="Calculate Multipoles"
//	Button mult_button,fsize=15,fstyle=1
//
//	SetVariable fieldmap_dir,pos={10,425},size={300,18},title="Field Map Directory: "
//	SetVariable fieldmap_dir,noedit=1,value=root:varsCAMTO:FIELDMAP_FOLDER
//	TitleBox copy_title,pos={10,452},size={150,18},frame=0,title="Copy Configuration from:"
//	PopupMenu copy_dir,pos={160,450},size={150,18},bodyWidth=145,mode=0,proc=CopyMultipolesConfig,title=" "
//	Button apply_to_all_integrals,pos={10,476},size={300,25},fstyle=1,proc=CalcIntegralsToAll,title="Calculate Integrals for All Field Maps"
//	Button apply_to_all_multipoles,pos={10,506},size={300,25},fstyle=1,proc=CalcMultipolesToAll,title="Calculate Multipoles for All Field Maps"
//	
//	UpdateFieldmapFolders()
//	UpdateIntegralsMultipolesPanel()
//		
//EndMacro
//
//
//Function UpdateIntegralsMultipolesPanel()
//	
//	string panel_name
//	panel_name = WinList("Integrals_Multipoles",";","")	
//	if (stringmatch(panel_name, "Integrals_Multipoles;")==0)
//		return -1
//	endif
//
//	SVAR df = root:varsCAMTO:FIELDMAP_FOLDER
//	
//	NVAR fieldmapCount = root:varsCAMTO:FIELDMAP_COUNT
//	
//	string FieldmapList
//	if (fieldmapCount > 1)
//		FieldmapList = getFieldmapDirs()
//		Button apply_to_all_integrals,win=Integrals_Multipoles,disable=0
//		Button apply_to_all_multipoles,win=Integrals_Multipoles,disable=0
//	else
//		FieldmapList = ""
//		Button apply_to_all_integrals,win=Integrals_Multipoles,disable=2
//		Button apply_to_all_multipoles,win=Integrals_Multipoles,disable=2
//	endif
//	
//	if (DataFolderExists("root:Nominal"))
//		FieldmapList = "Field Specification;" + FieldmapList
//	endif
//	
//	PopupMenu copy_dir,win=Integrals_Multipoles,disable=0,value= #("\"" + "Multipoles over trajectory;" + FieldmapList + "\"")
//	
//	if (strlen(df) > 0)
//		NVAR FittingOrder = root:$(df):varsFieldmap:FittingOrder
//		NVAR NormComponent = root:$(df):varsFieldmap:NormComponent
//	
//		SetVariable order,win=Integrals_Multipoles,value= root:$(df):varsFieldmap:FittingOrder
//		SetVariable dist,win=Integrals_Multipoles,value= root:$(df):varsFieldmap:Distcenter
//		SetVariable norm_k,win=Integrals_Multipoles,limits={0,(FittingOrder-1),1},value= root:$(df):varsFieldmap:KNorm
//		PopupMenu norm_comp,win=Integrals_Multipoles,disable=0,mode=NormComponent
//		
//		SetVariable grid_min,win=Integrals_Multipoles,value= root:$(df):varsFieldmap:GridMin
//		SetVariable grid_max,win=Integrals_Multipoles,value= root:$(df):varsFieldmap:GridMax
//	
//		SetVariable norm_ks,win=Integrals_Multipoles, value= root:$(df):varsFieldmap:NormalCoefs	
//		SetVariable skew_ks,win=Integrals_Multipoles, value= root:$(df):varsFieldmap:SkewCoefs
//				
//		SetVariable res_norm_ks, win=Integrals_Multipoles, value= root:$(df):varsFieldmap:ResNormalCoefs
//		SetVariable res_skew_ks, win=Integrals_Multipoles, value= root:$(df):varsFieldmap:ResSkewCoefs
//
//		Button mult_button,win=Integrals_Multipoles,disable=0
//	else
//		PopupMenu norm_comp,win=Integrals_Multipoles,disable=2
//		Button mult_button,win=Integrals_Multipoles,disable=2
//	endif
//	
//End


//Window Probe_Error_Correction() : Panel
//	PauseUpdate; Silent 1		// building window...
//
//	if (DataFolderExists("root:varsCAMTO")==0)
//		DoAlert 0, "CAMTO variables not found."
//		return 
//	endif
//
//	CloseWindow("Hall_Probe_Error_Correction")
//
//	NewPanel/K=1/W=(430,60,830,360)
//	SetDrawEnv fillpat= 0
//	DrawRect 2, 2, 396,200
//	SetDrawEnv fillpat= 0
//	DrawRect 2, 200, 396, 406
//	SetDrawEnv fillpat= 0
//	DrawRect 2, 406, 396, 695
//	
//	variable h
//	h = 10
//	
//	// Probe X
//	TitleBox px_title,pos={170,h},size={100,16},title="Probe X",fsize=16,frame=0,fstyle=1
//	h = h + 25
//	
//	SetVariable px_angy,pos={10,h},size={250,18},title="Angular Error Y (°)"
//	ValDisplay  px_angy_display,pos={270,h},size={120,18}
//	h = h + 25
//	
//	SetVariable px_angz,pos={10,h},size={250,18},title="Angular Error Z (°)"
//	ValDisplay  px_angz_display,pos={270,h},size={120,18}
//	h = h + 25
//		
//	SetVariable px_shiftx,pos={10,h},size={250,18},title="Displacement Error X (mm)"
//	ValDisplay  px_shiftx_display,pos={270,h},size={120,18}
//	h = h + 25
//	
//	SetVariable px_shiftyz,pos={10,h},size={250,18},title="Displacement Error YZ (mm)"
//	ValDisplay  px_shiftyz_display,pos={270,h},size={120,18}
//	h = h + 25
//	
//	SetVariable px_offset,pos={10,h},size={250,18},title="Offset (T)"
//	ValDisplay  px_offset_display,pos={270,h},size={120,18}
//	h = h + 25
//	
//	Button px_btn,pos={25,h},size={350,30},fsize=13,fstyle=1,proc=ProbeXCorrection,title="Apply Probe X Corrections"
//	h = h + 50
//
//	// Probe Y
//	TitleBox py_title,pos={170,h},size={100,16},title="Probe Y",fsize=16,frame=0,fstyle=1
//	h = h + 25
//	
//	SetVariable py_angx,pos={10,h},size={250,18},title="Angular Error X (°)"
//	ValDisplay  py_angx_display,pos={270,h},size={120,18}
//	h = h + 25
//	
//	SetVariable py_angz,pos={10,h},size={250,18},title="Angular Error Z (°)"
//	ValDisplay  py_angz_display,pos={270,h},size={120,18}
//	h = h + 25
//		
//	SetVariable py_shiftx,pos={10,h},size={250,18},title="Displacement Error X (mm)"
//	ValDisplay  py_shiftx_display,pos={270,h},size={120,18}
//	h = h + 25
//	
//	SetVariable py_shiftyz,pos={10,h},size={250,18},title="Displacement Error YZ (mm)"
//	ValDisplay  py_shiftyz_display,pos={270,h},size={120,18}
//	h = h + 25
//	
//	SetVariable py_offset,pos={10,h},size={250,18},title="Offset (T)"
//	ValDisplay  py_offset_display,pos={270,h},size={120,18}
//	h = h + 25
//	
//	Button py_btn,pos={25,h},size={350,30},fsize=13,fstyle=1,proc=ProbeYCorrection,title="Apply Probe Y Corrections"
//	h = h + 50
//
//	// Probe Z
//	TitleBox pz_title,pos={170,h},size={100,16},title="Probe Z",fsize=16,frame=0,fstyle=1
//	h = h + 25
//	
//	SetVariable pz_angx,pos={10,h},size={250,18},title="Angular Error X (°)"
//	ValDisplay  pz_angx_display,pos={270,h},size={120,18}
//	h = h + 25
//	
//	SetVariable pz_angy,pos={10,h},size={250,18},title="Angular Error Y (°)"
//	ValDisplay  pz_angy_display,pos={270,h},size={120,18}
//	h = h + 25
//		
//	SetVariable pz_shiftx,pos={10,h},size={250,18},title="Displacement Error X (mm)"
//	ValDisplay  pz_shiftx_display,pos={270,h},size={120,18}
//	h = h + 25
//	
//	SetVariable pz_shiftyz,pos={10,h},size={250,18},title="Displacement Error YZ (mm)"
//	ValDisplay  pz_shiftyz_display,pos={270,h},size={120,18}
//	h = h + 25
//	
//	SetVariable pz_offset,pos={10,h},size={250,18},title="Offset (T)"
//	ValDisplay  pz_offset_display,pos={270,h},size={120,18}
//	h = h + 25
//	
//	Button pz_btn,pos={25,h},size={350,30},fsize=13,fstyle=1,proc=ProbeZCorrection,title="Apply Probe Z Corrections"
//	h = h + 50
//	
//	//Copy configuration
//	SetVariable fieldmapdir,pos={20,h},size={355,18},title="Field Map Directory:"
//	SetVariable fieldmapdir,noedit=1,value=root:varsCAMTO:FIELDMAP_FOLDER
//	h = h + 25
//	
//	TitleBox copy_title,pos={20,h+2},size={145,18},frame=0,title="Copy Configuration from:"
//	PopupMenu copy_dir,pos={170,h},size={205,18},bodyWidth=205,mode=0,proc=CopyHallProbeConfig,title=" "
//	h = h + 25
//	
//	Button apply_to_all,pos={20,h},size={355,25},fstyle=1,proc=ApplyErrorCorrectionToAll,title="Apply Error Correction to All Field Maps"
//
//	UpdateFieldmapFolders()
//	UpdateHallProbePanel()
//		
//EndMacro
//
//
//Function UpdateHallProbePanel()
//
//	string panel_name
//	panel_name = WinList("Hall_Probe_Error_Correction",";","")	
//	if (stringmatch(panel_name, "Hall_Probe_Error_Correction;")==0)
//		return -1
//	endif
//	
//	SVAR df = root:varsCAMTO:FIELDMAP_FOLDER
//		
//	NVAR fieldmapCount = root:varsCAMTO:FIELDMAP_COUNT
//	
//	if (fieldmapCount > 1)
//		string FieldmapList = getFieldmapDirs()
//		PopupMenu copy_dir,win=Hall_Probe_Error_Correction,disable=0,value= #("\"" + FieldmapList + "\"")
//		Button apply_to_all,win=Hall_Probe_Error_Correction,disable=0
//	else
//		PopupMenu copy_dir,win=Hall_Probe_Error_Correction,disable=2
//		Button apply_to_all,win=Hall_Probe_Error_Correction,disable=2
//	endif
//	
//	if (strlen(df) > 0)		
//		Button AngularCorrection,win=Hall_Probe_Error_Correction,disable=0
//		SetVariable ErrAngXZ,win=Hall_Probe_Error_Correction,value= root:$(df):varsFieldmap:ErrAngXZ
//		SetVariable ErrAngYZ,win=Hall_Probe_Error_Correction,value= root:$(df):varsFieldmap:ErrAngYZ
//		SetVariable ErrAngXY,win=Hall_Probe_Error_Correction,value= root:$(df):varsFieldmap:ErrAngXY
//		
//		Button DisplacementCorrection,win=Hall_Probe_Error_Correction,disable=0
//		SetVariable ErrDisplacementX ,win=Hall_Probe_Error_Correction,value= root:$(df):varsFieldmap:ErrDisplacementX
//		SetVariable ErrDisplacementYZ,win=Hall_Probe_Error_Correction,value= root:$(df):varsFieldmap:ErrDisplacementYZ
//	else
//		Button AngularCorrection,win=Hall_Probe_Error_Correction,disable=2
//		Button DisplacementCorrection,win=Hall_Probe_Error_Correction,disable=2
//	endif
//	
//End
//
//
//Function CopyHallProbeConfig(ctrlName,popNum,popStr) : PopupMenuControl
//	String ctrlName
//	Variable popNum
//	String popStr
//	
//	SelectCopyDirectory(popNum,popStr)
//	
//	SVAR dfc = root:varsCAMTO:FieldmapCopy
//	CopyHallProbeConfig_(dfc)
//
//	UpdateHallProbePanel()
//
//End
//
//
//Function CopyHallProbeConfig_(dfc)
//	string dfc
//	
//	SVAR df  = root:varsCAMTO:FIELDMAP_FOLDER
//	Wave/T fieldmapFolders= root:wavesCAMTO:fieldmapFolders
//	
//	UpdateFieldmapFolders()	
//	FindValue/Text=dfc/TXOP=4 fieldmapFolders
//	
//	if (V_Value!=-1)
//		NVAR temp_df  = root:$(df):varsFieldmap:ErrAngXZ
//		NVAR temp_dfc = root:$(dfc):varsFieldmap:ErrAngXZ
//		temp_df = temp_dfc
//		
//		NVAR temp_df  = root:$(df):varsFieldmap:ErrAngYZ
//		NVAR temp_dfc = root:$(dfc):varsFieldmap:ErrAngYZ
//		temp_df = temp_dfc
//		
//		NVAR temp_df  = root:$(df):varsFieldmap:ErrAngXY
//		NVAR temp_dfc = root:$(dfc):varsFieldmap:ErrAngXY
//		temp_df = temp_dfc
//		
//		NVAR temp_df  = root:$(df):varsFieldmap:ErrDisplacementX
//		NVAR temp_dfc = root:$(dfc):varsFieldmap:ErrDisplacementX
//		temp_df = temp_dfc		
//
//		NVAR temp_df  = root:$(df):varsFieldmap:ErrDisplacementYZ
//		NVAR temp_dfc = root:$(dfc):varsFieldmap:ErrDisplacementYZ
//		temp_df = temp_dfc	
//		
//	else
//		DoAlert 0, "Data folder not found."
//	endif
//
//End
//
//
//Function AngularErrorCorrection(ctrlName) : ButtonControl
//	String ctrlName
//
//	NVAR NPointsX = :varsFieldmap:NPointsX
//	NVAR ErrAngXZ = :varsFieldmap:ErrAngXZ
//	NVAR ErrAngYZ = :varsFieldmap:ErrAngYZ
//	NVAR ErrAngXY = :varsFieldmap:ErrAngXY	
//	NVAR ErrAng   = :varsFieldmap:ErrAng	
//		
//	if (ErrAng == 0)
//	
//		print ("Correcting Hall Probe Angular Error")
//	
//		Wave C_PosX
//
//		string NomeBx
//		string NomeBy	
//		string NomeBz	
//		variable i
//	
//		for(i=0;i <NPointsX; i=i+1)
//			NomeBx ="RaiaBx_X" + num2str(C_PosX[i])
//			NomeBy ="RaiaBy_X" + num2str(C_PosX[i])
//			NomeBz ="RaiaBz_X" + num2str(C_PosX[i])				
//
//			if (i==0)
//				Duplicate/O $NomeBx TmpAngXZ
//				Duplicate/O $NomeBy TmpAngYZ
//				Duplicate/O $NomeBx TmpAngXY				
//			endif
//		
//			Wave TmpBz = $NomeBz
//			Wave TmpBy = $NomeBy			
//		
//			//Bx - Erro Angular XZ
//			TmpAngXZ = TmpBz * sin(ErrAngXZ*pi/180)
//		
//			//By Erro Angular YZ
//			TmpAngYZ = TmpBz * sin(ErrAngYZ*pi/180)		
//			
//			//Bx Erro Angular XY
//			TmpAngXY = TmpBy * sin(ErrAngXY*pi/180)		
//
//			Wave TmpBx = $NomeBx
//			Wave TmpBy = $NomeBy
//		
//			TmpBx = TmpBx - TmpAngXZ - TmpAngXY
//			TmpBy = TmpBy - TmpAngYZ		
//		endfor
//			
//		ErrAng = 1
//	else
//		DoAlert 0,"Hall Probes Angular Error is already corrected."	
//	endif
//End
//
//
//Function DisplacementErrorCorrection(ctrlName) : ButtonControl
//	string ctrlName
//
//	NVAR StartX   = :varsFieldmap:StartX
//	NVAR EndX     = :varsFieldmap:EndX
//	NVAR StepsX   = :varsFieldmap:StepsX
//	NVAR NPointsX = :varsFieldmap:NPointsX
//
//	NVAR StartYZ   = :varsFieldmap:StartYZ
//	NVAR EndYZ     = :varsFieldmap:EndYZ
//	NVAR StepsYZ   = :varsFieldmap:StepsYZ
//	NVAR NPointsYZ = :varsFieldmap:NPointsYZ	
//	
//	NVAR ErrDisplacementX  = :varsFieldmap:ErrDisplacementX
//	NVAR ErrDisplacementYZ = :varsFieldmap:ErrDisplacementYZ
//	NVAR ErrDisplacement   = :varsFieldmap:ErrDisplacement	
//
//	if (ErrDisplacement == 0)
//	
//		print ("Correcting Hall Probe Displacement Error")
//	
//		StartX = StartX  + ErrDisplacementX
//		EndX  = EndX   + ErrDisplacementX
//
//		StartYZ = StartYZ  + ErrDisplacementYZ
//		EndYZ  = EndYZ   + ErrDisplacementYZ
//	
//		variable i
//		string OldNameBx, OldNameBy, OldNameBz
//		string TmpNameBx, TmpNameBy, TmpNameBz		
//		string NewNameBx, NewNameBy, NewNameBz		
//		
//		Wave C_PosX
//		Duplicate C_PosX New_C_PosX
//		for (i=0;i<NPointsX;i+=1)
//			New_C_PosX[i] = (StartX + StepsX*i) / 1000 
//		endfor
//	
//		wave C_PosYZ
//		for (i=0;i<NPointsYZ;i+=1)
//			C_PosYZ[i] = (StartYZ + StepsYZ*i) / 1000
//		endfor
//	
//		for(i=0;i <NPointsX; i=i+1)
//			OldNameBx ="RaiaBx_X" + num2str(C_PosX[i])
//			OldNameBy ="RaiaBy_X" + num2str(C_PosX[i])
//			OldNameBz ="RaiaBz_X" + num2str(C_PosX[i])				
//	
//			TmpNameBx ="TmpRaiaBx_X" + num2str(New_C_PosX[i])
//			TmpNameBy ="TmpRaiaBy_X" + num2str(New_C_PosX[i])
//			TmpNameBz ="TmpRaiaBz_X" + num2str(New_C_PosX[i])	
//	
//			Rename $OldNameBx $TmpNameBx
//			Rename $OldNameBy $TmpNameBy
//			Rename $OldNameBz $TmpNameBz
//		endfor
//		
//		for(i=0;i <NPointsX; i=i+1)
//			TmpNameBx ="TmpRaiaBx_X" + num2str(New_C_PosX[i])
//			TmpNameBy ="TmpRaiaBy_X" + num2str(New_C_PosX[i])
//			TmpNameBz ="TmpRaiaBz_X" + num2str(New_C_PosX[i])				
//			
//			NewNameBx ="RaiaBx_X" + num2str(New_C_PosX[i])
//			NewNameBy ="RaiaBy_X" + num2str(New_C_PosX[i])
//			NewNameBz ="RaiaBz_X" + num2str(New_C_PosX[i])	
//	
//			Rename $TmpNameBx $NewNameBx
//			Rename $TmpNameBy $NewNameBy
//			Rename $TmpNameBz $NewNameBz
//		endfor
//		
//	
//		C_PosX[] = New_C_PosX[p]
//		Killwaves New_C_PosX
//			
//		ErrDisplacement = 1
//		
//	else
//		DoAlert 0,"Hall Probes Displacement Error is already corrected."	
//	endif
//	
//End
//
//
//Function ApplyErrorCorrectionToAll(ctrlName) : ButtonControl
//	String ctrlName
//	
//	DoAlert 1, "Apply current error correction to all fieldmaps?"
//	if (V_flag != 1)
//		return -1
//	endif
//	
//	UpdateFieldmapFolders()
//		
//	Wave/T fieldmapFolders = root:wavesCAMTO:fieldmapFolders
//	NVAR fieldmapCount  = root:varsCAMTO:FIELDMAP_COUNT
//	SVAR fieldmapFolder= root:varsCAMTO:FIELDMAP_FOLDER
//	
//	DFREF df = GetDataFolderDFR()
//	string dfc = GetDataFolder(0)
//	
//	variable i
//	string tdf
//	string empty = ""
//
//	for (i=0; i < fieldmapCount; i=i+1)
//		tdf = fieldmapFolders[i]
//		fieldmapFolder = tdf
//		SetDataFolder root:$(tdf)
//		CopyHallProbeConfig_(dfc)
//		Print("Applying Hall Probe Error Correction to " + tdf + ":")
//		AngularErrorCorrection(empty)
//		DisplacementErrorCorrection(empty)
//	endfor
//	
//	fieldmapFolder = dfc
//	SetDataFolder df
//
//End
//
//

//
//Function CopyMultipolesConfig(ctrlName,popNum,popStr) : PopupMenuControl
//	String ctrlName
//	Variable popNum
//	String popStr
//
//	SVAR df      = root:varsCAMTO:FIELDMAP_FOLDER
//	SVAR copydir = root:varsCAMTO:FieldmapCopy
//	
//	if (cmpstr(popStr, "Multipoles over trajectory") == 0)
//	
//		NVAR temp_df  = root:$(df):varsFieldmap:FittingOrder
//		NVAR temp_dfc = root:$(df):varsFieldmap:FittingOrderTraj
//		temp_df = temp_dfc
//		
//		NVAR temp_df  = root:$(df):varsFieldmap:Distcenter
//		NVAR temp_dfc = root:$(df):varsFieldmap:DistcenterTraj
//		temp_df = temp_dfc
//		
//		NVAR temp_df  = root:$(df):varsFieldmap:GridMin
//		NVAR temp_dfc = root:$(df):varsFieldmap:GridMinTraj
//		temp_df = temp_dfc	
//
//		NVAR temp_df  = root:$(df):varsFieldmap:GridMax
//		NVAR temp_dfc = root:$(df):varsFieldmap:GridMaxTraj
//		temp_df = temp_dfc	
//
//		NVAR temp_df  = root:$(df):varsFieldmap:KNorm
//		NVAR temp_dfc = root:$(df):varsFieldmap:DynKNorm
//		temp_df = temp_dfc		
//
//		NVAR temp_df  = root:$(df):varsFieldmap:NormComponent
//		NVAR temp_dfc = root:$(df):varsFieldmap:DynNormComponent
//		temp_df = temp_dfc	
//
//		SVAR stemp_df  = root:$(df):varsFieldmap:NormalCoefs
//		SVAR stemp_dfc = root:$(df):varsFieldmap:DynNormalCoefs
//		stemp_df = stemp_dfc
//
//		SVAR stemp_df  = root:$(df):varsFieldmap:SkewCoefs
//		SVAR stemp_dfc = root:$(df):varsFieldmap:DynSkewCoefs
//		stemp_df = stemp_dfc
//
//		SVAR stemp_df  = root:$(df):varsFieldmap:ResNormalCoefs
//		SVAR stemp_dfc = root:$(df):varsFieldmap:DynResNormalCoefs
//		stemp_df = stemp_dfc
//
//		SVAR stemp_df  = root:$(df):varsFieldmap:ResSkewCoefs
//		SVAR stemp_dfc = root:$(df):varsFieldmap:DynResSkewCoefs
//		stemp_df = stemp_dfc
//	
//	else
//	
//		string dfc
//		if (cmpstr(popStr, "Field Specification") == 0)
//			if (DataFolderExists("root:Nominal"))
//				dfc = "Nominal"
//			else
//				DoAlert 0, "Data folder not found."
//				return -1
//			endif
//		else
//			SelectCopyDirectory(popNum,popStr)
//		
//			Wave/T fieldmapFolders= root:wavesCAMTO:fieldmapFolders
//			
//			UpdateFieldmapFolders()	
//			FindValue/Text=copydir/TXOP=4 fieldmapFolders
//			if (V_Value==-1)
//				DoAlert 0, "Data folder not found."
//				return -1
//			endif
//			
//			dfc = copydir
//		endif
//		
//		CopyMultipolesConfig_(dfc)
//		
//	endif
//	
//	UpdateIntegralsMultipolesPanel()
//
//End
//
//
//Function CopyMultipolesConfig_(dfc)
//	string dfc
//	
//	SVAR df = root:varsCAMTO:FIELDMAP_FOLDER
//	
//	NVAR temp_df  = root:$(df):varsFieldmap:FittingOrder
//	NVAR temp_dfc = root:$(dfc):varsFieldmap:FittingOrder
//	temp_df = temp_dfc
//	
//	NVAR temp_df  = root:$(df):varsFieldmap:Distcenter
//	NVAR temp_dfc = root:$(dfc):varsFieldmap:Distcenter
//	temp_df = temp_dfc
//	
//	NVAR temp_df  = root:$(df):varsFieldmap:KNorm
//	NVAR temp_dfc = root:$(dfc):varsFieldmap:KNorm
//	temp_df = temp_dfc		
//
//	NVAR temp_df  = root:$(df):varsFieldmap:NormComponent
//	NVAR temp_dfc = root:$(dfc):varsFieldmap:NormComponent
//	temp_df = temp_dfc	
//
//	NVAR temp_df  = root:$(df):varsFieldmap:GridMin
//	NVAR temp_dfc = root:$(dfc):varsFieldmap:GridMin
//	temp_df = temp_dfc	
//
//	NVAR temp_df  = root:$(df):varsFieldmap:GridMax
//	NVAR temp_dfc = root:$(dfc):varsFieldmap:GridMax
//	temp_df = temp_dfc	
//
//	SVAR stemp_df  = root:$(df):varsFieldmap:NormalCoefs
//	SVAR stemp_dfc = root:$(dfc):varsFieldmap:NormalCoefs
//	stemp_df = stemp_dfc
//
//	SVAR stemp_df  = root:$(df):varsFieldmap:SkewCoefs
//	SVAR stemp_dfc = root:$(dfc):varsFieldmap:SkewCoefs
//	stemp_df = stemp_dfc
//
//	SVAR stemp_df  = root:$(df):varsFieldmap:ResNormalCoefs
//	SVAR stemp_dfc = root:$(dfc):varsFieldmap:ResNormalCoefs
//	stemp_df = stemp_dfc
//
//	SVAR stemp_df  = root:$(df):varsFieldmap:ResSkewCoefs
//	SVAR stemp_dfc = root:$(dfc):varsFieldmap:ResSkewCoefs
//	stemp_df = stemp_dfc
//
//End
//
//Function PopupMultComponent(ctrlName,popNum,popStr) : PopupMenuControl
//	String ctrlName
//	Variable popNum
//	String popStr
//
//	NVAR NormComponent = :varsFieldmap:NormComponent
//	NormComponent = popNum
//	
//End
//
//
//Function CalcIntegrals(ctrlName) : ButtonControl
//	String ctrlName
//	print ("Calculating Field Integrals")
//
//	variable timerRefNum, calc_time
//	timerRefNum = StartMSTimer
//
//	IntegralsCalculation()
//	UpdateResultsPanel()
//	
//	calc_time = StopMSTimer(timerRefNum)
//	Print "Elapsed time :", calc_time*(10^(-6)), " seconds"
//	
//End
//
//
//Function CalcMultipoles(ctrlName) : ButtonControl
//	String ctrlName
//	print ("Calculating Field Multipoles")
//
//	variable timerRefNum, calc_time
//	timerRefNum = StartMSTimer
//
//	MultipolarFitting()
//	ResidualMultipolesCalc()
//	UpdateResultsPanel()
//	
//	calc_time = StopMSTimer(timerRefNum)
//	Print "Elapsed time :", calc_time*(10^(-6)), " seconds"
//	
//End
//
//
//Function EquallySpaced(w)
//	Wave w
//	
//	variable i, tol
//	variable step, prev_step, eq_step
//	
//	tol = 1e-10
//	eq_step = 1
//	prev_step = w(1) - w(0)
//	
//	for(i=1; i<numpnts(w)-1; i=i+1)
//		step = w(i+1) - w(i)
//		if (Abs(step - prev_step) > tol)
//			eq_step = 0
//			break
//		endif
//		prev_step = step
//	endfor
//	
//	return eq_step
//End
//
//
//#if Exists("Calc2DSplineInterpolant")
//
//	Function CalcFieldmapInterpolant()
//		
//		NVAR BeamDirection = :varsFieldmap:BeamDirection
//		NVAR StartX    = :varsFieldmap:StartX
//		NVAR EndX      = :varsFieldmap:EndX
//		NVAR StepsX    = :varsFieldmap:StepsX
//		NVAR NPointsX  = :varsFieldmap:NPointsX
//		NVAR StartYZ   = :varsFieldmap:StartYZ
//		NVAR EndYZ     = :varsFieldmap:EndYZ
//		NVAR StepsYZ   = :varsFieldmap:StepsYZ
//		NVAR NPointsYZ = :varsFieldmap:NPointsYZ	
//		
//		variable calc_interpolant_flag
//		string nome
//		variable i, j, k
//	
//		Wave C_PosX
//		Wave C_PosYZ
//		
//		if (EquallySpaced(C_PosX) == 0)
//			return 0
//		endif
//		
//		if (EquallySpaced(C_PosYZ) == 0)
//			return 0
//		endif
//	
//		Make/D/O/N=(NPointsX*NPointsYZ) NewWave0, NewWave1, NewWave2, NewWave3, NewWave4, NewWave5
//		
//		k =0
//		for (i=0;i<NPointsYZ;i=i+1)
//			for (j=0;j<NpointsX;j=j+1)
//	
//				NewWave0[k] = StartX + j*StepsX		
//				if (BeamDirection == 1)
//					NewWave1[k] = StartYZ + i*StepsYZ
//					NewWave2[k] = 0
//				else
//					NewWave1[k] = 0
//					NewWave2[k] = StartYZ + i*StepsYZ			
//				endif
//				
//				Wave Tmp = $"RaiaBx_X" + num2str(NewWave0[k]/1000)
//				NewWave3[k] = Tmp[i]
//	
//				Wave Tmp = $"RaiaBy_X" + num2str(NewWave0[k]/1000)
//				NewWave4[k] = Tmp[i]
//	
//				Wave Tmp = $"RaiaBz_X" + num2str(NewWave0[k]/1000)
//				NewWave5[k] = Tmp[i]
//				
//				k = k + 1
//			endfor
//		endfor
//		
//		NewWave0[] = NewWave0[p]/1000
//		NewWave1[] = NewWave1[p]/1000
//	 	NewWave2[] = NewWave2[p]/1000
//	
//	 	if (BeamDirection == 1)
//			calc_interpolant_flag = Calc2DSplineInterpolant(NewWave0, NewWave1, NewWave3, NewWave4, NewWave5)	
//		else
//			calc_interpolant_flag = Calc2DSplineInterpolant(NewWave0, NewWave2, NewWave3, NewWave4, NewWave5)		
//		endif
//	 			
//		Killwaves/Z NewWave0
//		Killwaves/Z NewWave1
//		Killwaves/Z NewWave2
//		Killwaves/Z NewWave3
//		Killwaves/Z NewWave4
//		Killwaves/Z NewWave5
//					
//		return calc_interpolant_flag		
//	End
//
//	
//	ThreadSafe Function/Wave GetPerpendicularField(index, DeflectionAngle, PosX, PosYZ, GridX)
//		Variable index, DeflectionAngle, PosX, PosYZ
//		Wave GridX
//		
//		Make/D/O/N=3 MagField
//		variable RotX, RotYZ
//		
//		RotX   = PosX   + GridX[index]*cos(DeflectionAngle)
//		RotYZ = PosYZ + GridX[index]*sin(DeflectionAngle)
//		MagField[0] = GetFieldX(RotX, RotYZ)
//		MagField[1] = GetFieldY(RotX, RotYZ)
//		MagField[2] = GetFieldZ(RotX, RotYZ)
//		
//		return MagField	
//		
//	End
//
//#else
//
//	Function CalcFieldmapInterpolant()
//		return 0
//	End Function
//	
//	
//	ThreadSafe Function/Wave GetPerpendicularField(index, DeflectionAngle, PosX, PosYZ, GridX)
//		Variable index, DeflectionAngle, PosX, PosYZ
//		Wave GridX
//		Make/D/O/N=3 MagField
//		return MagField	
//	End
//
//#endif
//
//
//Function/Wave GetPerpendicularFieldST(index, DeflectionAngle, PosX, PosYZ, GridX)
//	Variable index, DeflectionAngle, PosX, PosYZ
//	Wave GridX
//	
//	NVAR FieldX = :varsFieldmap:FieldX
//	NVAR FieldY = :varsFieldmap:FieldY
//	NVAR FieldZ = :varsFieldmap:FieldZ
//	
//	Make/D/O/N=3 MagField
//	variable RotX, RotYZ
//	
//	RotX   = PosX   + GridX[index]*cos(DeflectionAngle)
//	RotYZ = PosYZ + GridX[index]*sin(DeflectionAngle)
//
//	Campo_espaco(RotX, RotYZ)
//		
//	MagField[0] = FieldX
//	MagField[1] = FieldY
//	MagField[2] = FieldZ
//	
//	return MagField	
//	
//End
//
//
//Function MultipolarFitting([ReloadField])
//   variable ReloadField
//   
//	Wave C_PosX
//	Wave C_PosYZ
//	
//	NVAR NPointsX      = :varsFieldmap:NPointsX
//	NVAR NPointsYZ     = :varsFieldmap:NPointsYZ	
//	NVAR GridMin       = :varsFieldmap:GridMin
//	NVAR GridMax       = :varsFieldmap:GridMax
//	NVAR BeamDirection = :varsFieldmap:BeamDirection
//	NVAR FittingOrder  = :varsFieldmap:FittingOrder
//	NVAR Distcenter    = :varsFieldmap:Distcenter
//	NVAR KNorm         = :varsFieldmap:KNorm
//	NVAR NormComponent = :varsFieldmap:NormComponent
//	SVAR NormalCoefs   = :varsFieldmap:NormalCoefs
//	SVAR SkewCoefs     = :varsFieldmap:SkewCoefs
//      
//	variable i,j, n
//
//	if (ParamIsDefault(ReloadField))
//		ReloadField = 1
//	endif	
//
//	if (ReloadField)
//		print ("Reloading Field Data...")
//		variable spline_flag
//		spline_flag = CalcFieldmapInterpolant()
//		
//		if(spline_flag == 1)
//			print("Field data successfully reloaded.")
//		else
//			print("Problem with cubic spline XOP. Using single thread calculation.")
//		endif
//	endif
//	
//	variable imin = 0
//	for (i=0; i<NPointsX; i=i+1)
//		if (C_PosX[i] > GridMin/1000)
//			break
//		elseif (C_PosX[i] == GridMin/1000)
//			imin = i
//		else
//			imin = i+1
//		endif
//	endfor
//	
//	variable imax = NPointsX	
//	for (i=(NPointsX-1); i>=0; i=i-1)
//		if (C_PosX[i] < GridMax/1000)
//			break
//		elseif (C_PosX[i] == GridMax/1000)
//			imax = i
//		else
//			imax = i-1
//		endif
//	endfor
//
//	Duplicate/O/R=(imin, imax) C_PosX Mult_Grid
//
//	Make/O/D/N=(numpnts(Mult_Grid),3) Field_Perp	
//	Make/O/D/N=(NPointsYZ) Temp
//	Make/O/D/N=(NPointsYZ, FittingOrder) Mult_Normal, Mult_Skew
//	Make/O/D/N=(FittingOrder) Mult_Normal_Int, Mult_Skew_Int
//	Make/O/D/N=(FittingOrder) W_coef, W_sigma
//
//	K0 = 0;K1 = 0;K2 = 0;K3 = 0;K4 = 0;K5 = 0;K6 = 0;K7 = 0;K8 = 0;K9 = 0;K10 = 0;
//	K11 = 0;K12 = 0;K13 = 0;K14 = 0;K15 = 0;K16 = 0;K17 = 0;K18 = 0;K19 = 0 
//
//	variable skew_idx = 0
//	variable normal_idx
//	
//	if (BeamDirection == 1)
//		normal_idx = 2
//	else
//		normal_idx = 1
//	endif
//
//	variable normal_on = 0
//	for (j=0; j<FittingOrder; j=j+1)
//		if (cmpstr(NormalCoefs[j],"0")==0)
//			normal_on = 1
//			break
//		endif
//	endfor
//
//	variable skew_on = 0
//	for (j=0; j<FittingOrder; j=j+1)
//		if (cmpstr(SkewCoefs[j],"0")==0)
//			skew_on = 1
//			break
//		endif
//	endfor
//
//	for (i=0; i<NPointsYZ; i=i+1)
//		
//		if (spline_flag == 1)
//			Multithread Field_Perp[][] = GetPerpendicularField(x, 0, 0, C_PosYZ[i], Mult_Grid)(q)
//		else
//			Field_Perp[][] = GetPerpendicularFieldST(x, 0, 0, C_PosYZ[i], Mult_Grid)(q)
//		endif
//		
//		K0 = 0;K1 = 0;K2 = 0;K3 = 0;K4 = 0;K5 = 0;K6 = 0;K7 = 0;K8 = 0;K9 = 0;K10 = 0;
//		K11 = 0;K12 = 0;K13 = 0;K14 = 0;K15 = 0;K16 = 0;K17 = 0;K18 = 0;K19 = 0 
//		
//		W_coef[] = 0
//		if (normal_on == 1)
//			CurveFit/L=(NPointsX)/H=NormalCoefs/N=1/Q poly FittingOrder, Field_Perp[][normal_idx] /X=Mult_Grid/D
//		endif
//		Mult_Normal[i][] = W_coef[q]
//
//		K0 = 0;K1 = 0;K2 = 0;K3 = 0;K4 = 0;K5 = 0;K6 = 0;K7 = 0;K8 = 0;K9 = 0;K10 = 0;
//		K11 = 0;K12 = 0;K13 = 0;K14 = 0;K15 = 0;K16 = 0;K17 = 0;K18 = 0;K19 = 0 
//
//		W_coef[] = 0
//		if (skew_on == 1)
//			CurveFit/L=(NPointsX)/H=SkewCoefs/N=1/Q poly FittingOrder, Field_Perp[][skew_idx] /X=Mult_Grid/D
//		endif
//		Mult_Skew[i][] = W_coef[q]
//		
//	endfor
//	
//	for (n=0; n<FittingOrder; n=n+1)
//	   	Temp[] = Mult_Normal[p][n]
//		Integrate/METH=1 Temp/X=C_PosYZ/D=Temp_Integral
//		Mult_Normal_Int[n] = Temp_Integral[NPointsYZ]
//		
//		Temp[] = Mult_Skew[p][n]
//		Integrate/METH=1 Temp/X=C_PosYZ/D=Temp_Integral
//		Mult_Skew_Int[n] = Temp_Integral[NPointsYZ]
//		
//	endfor
//		
//	Duplicate/D/O Mult_Normal_Int Mult_Normal_Norm
//	Duplicate/D/O Mult_Skew_Int   Mult_Skew_Norm
//
//	if (NormComponent == 2) 
//		for (n=0;n<FittingOrder;n=n+1)
//			Mult_Normal_Norm[n] = ( ( Mult_Normal_Int[n] / Mult_Skew_Int[KNorm] ) * (Distcenter/1000)^(n-KNorm) )
//			Mult_Skew_Norm[n]   = ( ( Mult_Skew_Int[n]   / Mult_Skew_Int[KNorm] ) * (Distcenter/1000)^(n-KNorm) )				
//		endfor
//	else
//		for (n=0;n<FittingOrder;n=n+1)
//			Mult_Normal_Norm[n] = ( ( Mult_Normal_Int[n] / Mult_Normal_Int[KNorm] ) * (Distcenter/1000)^(n-KNorm) )
//			Mult_Skew_Norm[n]   = ( ( Mult_Skew_Int[n]   / Mult_Normal_Int[KNorm] ) * (Distcenter/1000)^(n-KNorm) )		
//		endfor
//	endif
//		
//	Killwaves/Z W_coef, W_sigma, W_ParamConfidenceInterval, fit_Field_Perp
//	Killwaves/Z Field_Perp, Temp_Integral, Temp
//		
//End
//
//
//Function ResidualMultipolesCalc()
//
//   	NVAR BeamDirection 	= :varsFieldmap:BeamDirection
//	NVAR NPointsX 		= :varsFieldmap:NPointsX
//	NVAR GridMin			= :varsFieldmap:GridMin
//	NVAR GridMax			= :varsFieldmap:GridMax
//	NVAR FittingOrder 	= :varsFieldmap:FittingOrder
//	NVAR NormComponent	= :varsFieldmap:NormComponent
//	NVAR KNorm			= :varsFieldmap:KNorm
//	SVAR ResNormalCoefs	= :varsFieldmap:ResNormalCoefs
//	SVAR ResSkewCoefs  	= :varsFieldmap:ResSkewCoefs
//
//	print ("Calculating Field Residual Multipoles")
//	       
//	Wave C_PosX
//	Wave Mult_Normal_Int
//	Wave Mult_Skew_Int  
//
//	variable BNorm 
//	if (NormComponent == 2)
//		BNorm = Mult_Skew_Int[KNorm]
//	else
//		BNorm = Mult_Normal_Int[KNorm]
//	endif
//
//	Make/D/O/N=(NPointsX) Temp_Normal = 0
//	Make/D/O/N=(NPointsX) Temp_Skew   = 0
//	
//	variable i		
//
//	for(i=0;i<FittingOrder;i+=1)
//	
//		if (stringmatch(ResNormalCoefs[i], "0"))
//			Temp_Normal += (Mult_Normal_Int[i]/BNorm)*(C_PosX ^ (i-KNorm))
//		endif
//		
//		if (stringmatch(ResSkewCoefs[i], "0"))
//			Temp_Skew += (Mult_Skew_Int[i]/BNorm)*(C_PosX ^ (i-KNorm))
//		endif
//	
//	endfor			
//	
//	for (i=0; i<NPointsX; i=i+1)
//		if (numtype(Temp_Normal[i]) == 1)
//			Temp_Normal[i] = NaN
//		endif
//		
//		if (numtype(Temp_Skew[i]) == 1)
//			Temp_Skew[i] = NaN
//		endif
//
//	endfor
//	
//	variable imin = 0
//	for (i=0; i<NPointsX; i=i+1)
//		if (C_PosX[i] > GridMin/1000)
//			break
//		elseif (C_PosX[i] == GridMin/1000)
//			imin = i
//		else
//			imin = i+1
//		endif
//	endfor
//	
//	variable imax = NPointsX	
//	for (i=(NPointsX-1); i>=0; i=i-1)
//		if (C_PosX[i] < GridMax/1000)
//			break
//		elseif (C_PosX[i] == GridMax/1000)
//			imax = i
//		else
//			imax = i-1
//		endif
//	endfor
//
//	Duplicate/O/R=(imin, imax) Temp_Normal Mult_Normal_Res
//	Duplicate/O/R=(imin, imax) Temp_Skew   Mult_Skew_Res
//	
//	Killwaves/Z Temp_Normal
//	Killwaves/Z Temp_Skew
//	
//End
//
//
//Function CalcIntegralsToAll(ctrlName) : ButtonControl
//	String ctrlName
//	
//	DoAlert 1, "Calculate integrals for all fieldmaps?"
//	if (V_flag != 1)
//		return -1
//	endif
//	
//	UpdateFieldmapFolders()
//		
//	Wave/T fieldmapFolders = root:wavesCAMTO:fieldmapFolders
//	NVAR fieldmapCount  = root:varsCAMTO:FIELDMAP_COUNT
//	SVAR fieldmapFolder= root:varsCAMTO:FIELDMAP_FOLDER
//		
//	DFREF df = GetDataFolderDFR()
//	string dfc = GetDataFolder(0)
//	
//	variable i
//	string tdf
//	string empty = ""
//
//	for (i=0; i < fieldmapCount; i=i+1)
//		tdf = fieldmapFolders[i]
//		fieldmapFolder = tdf
//		SetDataFolder root:$(tdf)
//		CopyMultipolesConfig_(dfc)
//		Print("Calculating Integrals for " + tdf + ":")
//		CalcIntegrals(empty)
//	endfor
//
//	fieldmapFolder = dfc
//	SetDataFolder df
//	
//End
//
//
//Function CalcMultipolesToAll(ctrlName) : ButtonControl
//	String ctrlName
//	
//	DoAlert 1, "Calculate multipoles for all fieldmaps?"
//	if (V_flag != 1)
//		return -1
//	endif
//	
//	UpdateFieldmapFolders()
//		
//	Wave/T fieldmapFolders = root:wavesCAMTO:fieldmapFolders
//	NVAR fieldmapCount  = root:varsCAMTO:FIELDMAP_COUNT
//	SVAR fieldmapFolder= root:varsCAMTO:FIELDMAP_FOLDER
//		
//	DFREF df = GetDataFolderDFR()
//	string dfc = GetDataFolder(0)
//	
//	variable i
//	string tdf
//	string empty = ""
//
//	for (i=0; i < fieldmapCount; i=i+1)
//		tdf = fieldmapFolders[i]
//		fieldmapFolder = tdf
//		SetDataFolder root:$(tdf)
//		CopyMultipolesConfig_(dfc)
//		Print("Calculating Multipoles for " + tdf + ":")
//		CalcMultipoles(empty)
//	endfor
//
//	fieldmapFolder = dfc
//	SetDataFolder df
//	
//End
//
//Function MakeTrajNamesWave(pos_str)
//	string pos_str
//	
//	Make/O/T/N=(9) TrajNames
//	TrajNames[0] = "TrajX" + pos_str
//	TrajNames[1] = "TrajY" + pos_str
//	TrajNames[2] = "TrajZ" + pos_str
//	TrajNames[3] = "Vel_X" + pos_str
//	TrajNames[4] = "Vel_Y" + pos_str
//	TrajNames[5] = "Vel_Z" + pos_str
//	TrajNames[6] = "VetorCampoX" + pos_str
//	TrajNames[7] = "VetorCampoY" + pos_str	
//	TrajNames[8] = "VetorCampoZ" + pos_str
//				
//End
//
//
//
//

//
//Window Dynamic_Multipoles() : Panel
//	PauseUpdate; Silent 1		// building window...
//
//	if (DataFolderExists("root:varsCAMTO")==0)
//		DoAlert 0, "CAMTO variables not found."
//		return 
//	endif
//
//	CloseWindow("Dynamic_Multipoles")	
//	
//	NewPanel/K=1/W=(780,250,1103,825)
//	SetDrawLayer UserBack
//	SetDrawEnv fillpat= 0
//	DrawRect 3,4,320,70
//	SetDrawEnv fillpat= 0
//	DrawRect 3,70,320,300	
//	SetDrawEnv fillpat= 0
//	DrawRect 3,300,320,370
//	SetDrawEnv fillpat= 0
//	DrawRect 3,370,320,440
//	SetDrawEnv fillpat= 0
//	DrawRect 3,440,320,480
//	SetDrawEnv fillpat= 0
//	DrawRect 3,480,320,570
//				
//	TitleBox    traj,pos={10,25},size={90,16},fsize=14,fstyle=1,frame=0,title="Trajectory"
//	ValDisplay  traj_x,pos={110,10},size={200,18},title="Start X [mm]:    "
//	ValDisplay  traj_angle,pos={110,30},size={200,18},title="Angle XY(Z) [°]:"
//	ValDisplay  traj_yz,pos={110,50},size={200,18},title="Start YZ [mm]:  "
//
//	TitleBox    title,pos={25,75},size={150,16},fsize=14,fstyle=1,frame=0,title="Integrals and Multipoles over Trajectory"
//	TitleBox    subtitle,pos={86,100},size={127,16},fsize=14,frame=0, title="K0 to Kx (0 - On, 1 - Off)"
//		
//	SetVariable order,pos={10,125},size={220,18},title="Order of multipolar analysis:"
//	
//	SetVariable dist,pos={10,150},size={200,18},title="Dist. for multipolar analysis:"
//	TitleBox    dist_unit,pos={210,150},size={87,15},frame=0,title=" mm from center",fsize=12
//	SetVariable norm_k,pos={10,175},size={220,18},title="Normalize against K:"
//	PopupMenu   norm_comp,pos={10,200},size={241,16},proc=PopupDynMultComponent,title="Component:"
//	PopupMenu   norm_comp,value= #"\"Normal;Skew\""
//	
//	SetVariable shift pos={10,226},size={220,16},title="Calculation displacement [m]:"
//	SetVariable shift,limits={root:varsCAMTO:TrajShift, 1, 0}
//
//	TitleBox    grid_title,pos={10, 253},size={220,18},frame=0,title="Perpendicular grid:",fsize=12
//	SetVariable grid_min,pos={10,275},limits={-inf, inf, 0},size={90,18},title="Min [mm]:"
//	SetVariable grid_max,pos={109,275},limits={-inf, inf, 0}, size={90,18},title="Max [mm]:"
//	SetVariable grid_nrpts,pos={209,275},limits={-inf, inf, 0},size={90,18},title="Nr points:"
//
//	TitleBox    mult_title,pos={10, 305},size={220,18},frame=0,title="Dynamic Multipoles"
//	SetVariable norm_ks,pos={20,325},size={285,18},title="Normal - Ks to use:"
//	SetVariable skew_ks,pos={20,345},size={285,18},title="\t Skew - Ks to use:"
//		
//	TitleBox    res_title,pos={10, 375},size={220,18},frame=0,title="Residual Normalized Dynamic Multipoles"
//	SetVariable res_norm_ks,pos={20,395},size={285,16},title="Normal - Ks to use:"
//	SetVariable res_skew_ks,pos={20,415},size={285,16},title="\t Skew - Ks to use:"
//
//	Button mult_button,pos={15,445},size={295,30},proc=CalcDynIntegralsMultipoles,title="Calculate Dynamic Multipoles"
//	Button mult_button,fsize=15,fstyle=1
//
//	SetVariable fieldmapdir,pos={15,488},size={290,18},title="Field Map Directory: "
//	SetVariable fieldmapdir,noedit=1,value=root:varsCAMTO:FIELDMAP_FOLDER
//	TitleBox copy_title,pos={15,515},size={145,18},frame=0,title="Copy Configuration from:"
//	PopupMenu copy_dir,pos={160,513},size={145,18},bodyWidth=145,mode=0,proc=CopyDynMultipolesConfig,title=" "
//	Button apply_to_all,pos={15,540},size={290,25},fstyle=1,proc=CalcDynIntegralsMultipolesToAll,title="Calculate Dynamic Multipoles for All Field Maps"
//	
//	UpdateFieldmapFolders()
//	UpdateDynMultipolesPanel()
//
//EndMacro
//
//
//Function UpdateDynMultipolesPanel()
//	
//	string panel_name
//	panel_name = WinList("Dynamic_Multipoles",";","")	
//	if (stringmatch(panel_name, "Dynamic_Multipoles;")==0)
//		return -1
//	endif
//	
//	SVAR df = root:varsCAMTO:FIELDMAP_FOLDER
//	
//	NVAR fieldmapCount = root:varsCAMTO:FIELDMAP_COUNT
//	
//	string FieldmapList
//	if (fieldmapCount > 1)
//		FieldmapList = getFieldmapDirs()
//		Button apply_to_all,win=Dynamic_Multipoles, disable=0
//	else
//		FieldmapList = ""
//		Button apply_to_all,win=Dynamic_Multipoles, disable=2
//	endif
//	
//	if (DataFolderExists("root:Nominal"))
//		FieldmapList = "Field Specification;" + FieldmapList
//	endif
//
//	PopupMenu copy_dir,win=Dynamic_Multipoles,disable=0,value= #("\"" + "Multipoles over line;" + FieldmapList + "\"")
//	
//	if (strlen(df) > 0)
//		NVAR FittingOrderTraj = root:$(df):varsFieldmap:FittingOrderTraj
//		NVAR DynNormComponent = root:$(df):varsFieldmap:DynNormComponent
//		NVAR CheckNegPosTraj = root:$(df):varsFieldmap:CheckNegPosTraj
//
//		ValDisplay traj_x,    win=Dynamic_Multipoles, value=#("root:"+ df + ":varsFieldmap:StartXTraj" )
//		ValDisplay traj_angle,win=Dynamic_Multipoles,value=#("root:"+ df + ":varsFieldmap:EntranceAngle" )
//		ValDisplay traj_yz,   win=Dynamic_Multipoles, value=#("root:"+ df + ":varsFieldmap:StartYZTraj" )
//			
//		SetVariable order,win=Dynamic_Multipoles, value= root:$(df):varsFieldmap:FittingOrderTraj
//		SetVariable dist,win=Dynamic_Multipoles, value= root:$(df):varsFieldmap:DistcenterTraj
//		SetVariable norm_k,win=Dynamic_Multipoles,limits={0,(FittingOrderTraj-1),1},value= root:$(df):varsFieldmap:DynKNorm
//		PopupMenu   norm_comp,win=Dynamic_Multipoles,disable=0,mode=DynNormComponent
//
//		SetVariable shift,win=Dynamic_Multipoles,    value= root:$(df):varsFieldmap:MultipolesTrajShift
//		SetVariable grid_min,win=Dynamic_Multipoles,  value= root:$(df):varsFieldmap:GridMinTraj
//		SetVariable grid_max,win=Dynamic_Multipoles,  value= root:$(df):varsFieldmap:GridMaxTraj
//		SetVariable grid_nrpts,win=Dynamic_Multipoles,value= root:$(df):varsFieldmap:GridNrptsTraj
//
//		SetVariable norm_ks,win=Dynamic_Multipoles, value= root:$(df):varsFieldmap:DynNormalCoefs	
//		SetVariable skew_ks,win=Dynamic_Multipoles, value= root:$(df):varsFieldmap:DynSkewCoefs
//				
//		SetVariable res_norm_ks, win=Dynamic_Multipoles, value= root:$(df):varsFieldmap:DynResNormalCoefs
//		SetVariable res_skew_ks, win=Dynamic_Multipoles, value= root:$(df):varsFieldmap:DynResSkewCoefs
//
//		if (CheckNegPosTraj == 1)
//			ValDisplay traj_x,    win=Dynamic_Multipoles, disable=2
//			ValDisplay traj_angle,win=Dynamic_Multipoles, disable=2
//			ValDisplay traj_yz,   win=Dynamic_Multipoles, disable=2
//		else
//			ValDisplay traj_x,    win=Dynamic_Multipoles, disable=0
//			ValDisplay traj_angle,win=Dynamic_Multipoles, disable=0
//			ValDisplay traj_yz,   win=Dynamic_Multipoles, disable=0		
//		endif
//
//		Button mult_button,win=Dynamic_Multipoles, disable=0
//	else
//		PopupMenu norm_comp,win=Dynamic_Multipoles,disable=2
//		Button mult_button,win=Dynamic_Multipoles, disable=2
//	endif
//	
//End
//
//
//Function CopyDynMultipolesConfig(ctrlName,popNum,popStr) : PopupMenuControl
//	String ctrlName
//	Variable popNum
//	String popStr
//	
//	SVAR df  = root:varsCAMTO:FIELDMAP_FOLDER
//	SVAR copydir = root:varsCAMTO:FieldmapCopy
//	
//	if (cmpstr(popStr, "Multipoles over line") == 0)
//	
//		NVAR temp_df  = root:$(df):varsFieldmap:FittingOrderTraj
//		NVAR temp_dfc = root:$(df):varsFieldmap:FittingOrder
//		temp_df = temp_dfc
//		
//		NVAR temp_df  = root:$(df):varsFieldmap:DistcenterTraj
//		NVAR temp_dfc = root:$(df):varsFieldmap:Distcenter
//		temp_df = temp_dfc
//
//		NVAR temp_df  = root:$(df):varsFieldmap:GridMinTraj
//		NVAR temp_dfc = root:$(df):varsFieldmap:GridMin
//		temp_df = temp_dfc	
//
//		NVAR temp_df  = root:$(df):varsFieldmap:GridMaxTraj
//		NVAR temp_dfc = root:$(df):varsFieldmap:GridMax
//		temp_df = temp_dfc	
//		
//		NVAR temp_df  = root:$(df):varsFieldmap:DynKNorm
//		NVAR temp_dfc = root:$(df):varsFieldmap:KNorm
//		temp_df = temp_dfc		
//
//		NVAR temp_df  = root:$(df):varsFieldmap:DynNormComponent
//		NVAR temp_dfc = root:$(df):varsFieldmap:NormComponent
//		temp_df = temp_dfc	
//		
//		SVAR stemp_df  = root:$(df):varsFieldmap:DynNormalCoefs
//		SVAR stemp_dfc = root:$(df):varsFieldmap:NormalCoefs
//		stemp_df = stemp_dfc
//
//		SVAR stemp_df  = root:$(df):varsFieldmap:DynSkewCoefs
//		SVAR stemp_dfc = root:$(df):varsFieldmap:SkewCoefs
//		stemp_df = stemp_dfc
//
//		SVAR stemp_df  = root:$(df):varsFieldmap:DynResNormalCoefs
//		SVAR stemp_dfc = root:$(df):varsFieldmap:ResNormalCoefs
//		stemp_df = stemp_dfc
//
//		SVAR stemp_df  = root:$(df):varsFieldmap:DynResSkewCoefs
//		SVAR stemp_dfc = root:$(df):varsFieldmap:ResSkewCoefs
//		stemp_df = stemp_dfc
//		
//	else
//			
//		string dfc
//		if (cmpstr(popStr, "Field Specification") == 0)
//			if (DataFolderExists("root:Nominal"))
//				dfc = "Nominal"
//			else
//				DoAlert 0, "Data folder not found."
//				return -1
//			endif
//		else
//			SelectCopyDirectory(popNum,popStr)
//		
//			Wave/T fieldmapFolders= root:wavesCAMTO:fieldmapFolders
//			
//			UpdateFieldmapFolders()	
//			FindValue/Text=copydir/TXOP=4 fieldmapFolders
//			if (V_Value==-1)
//				DoAlert 0, "Data folder not found."
//				return -1
//			endif
//			
//			dfc = copydir
//		endif
//							
//		CopyDynMultipolesConfig_(dfc)
//			
//	endif
//	
//	UpdateDynMultipolesPanel()
//
//End
//
//
//Function CopyDynMultipolesConfig_(dfc)
//	string dfc
//
//	SVAR df  = root:varsCAMTO:FIELDMAP_FOLDER
//
//	NVAR temp_df  = root:$(df):varsFieldmap:FittingOrderTraj
//	NVAR temp_dfc = root:$(dfc):varsFieldmap:FittingOrderTraj
//	temp_df = temp_dfc
//	
//	NVAR temp_df  = root:$(df):varsFieldmap:DistcenterTraj
//	NVAR temp_dfc = root:$(dfc):varsFieldmap:DistcenterTraj
//	temp_df = temp_dfc
//	
//	NVAR temp_df  = root:$(df):varsFieldmap:DynKNorm
//	NVAR temp_dfc = root:$(dfc):varsFieldmap:DynKNorm
//	temp_df = temp_dfc		
//
//	NVAR temp_df  = root:$(df):varsFieldmap:DynNormComponent
//	NVAR temp_dfc = root:$(dfc):varsFieldmap:DynNormComponent
//	temp_df = temp_dfc	
//
//	NVAR temp_df  = root:$(df):varsFieldmap:MultipolesTrajShift
//	NVAR temp_dfc = root:$(dfc):varsFieldmap:MultipolesTrajShift 
//	temp_df = temp_dfc	
//
//	NVAR temp_df  = root:$(df):varsFieldmap:GridMinTraj
//	NVAR temp_dfc = root:$(dfc):varsFieldmap:GridMinTraj
//	temp_df = temp_dfc	
//
//	NVAR temp_df  = root:$(df):varsFieldmap:GridMaxTraj
//	NVAR temp_dfc = root:$(dfc):varsFieldmap:GridMaxTraj
//	temp_df = temp_dfc	
//	
//	NVAR temp_df  = root:$(df):varsFieldmap:GridNrptsTraj
//	NVAR temp_dfc = root:$(dfc):varsFieldmap:GridNrptsTraj
//	temp_df = temp_dfc	
//		
//	SVAR stemp_df  = root:$(df):varsFieldmap:DynNormalCoefs
//	SVAR stemp_dfc = root:$(dfc):varsFieldmap:DynNormalCoefs
//	stemp_df = stemp_dfc
//
//	SVAR stemp_df  = root:$(df):varsFieldmap:DynSkewCoefs
//	SVAR stemp_dfc = root:$(dfc):varsFieldmap:DynSkewCoefs
//	stemp_df = stemp_dfc
//
//	SVAR stemp_df  = root:$(df):varsFieldmap:DynResNormalCoefs
//	SVAR stemp_dfc = root:$(dfc):varsFieldmap:DynResNormalCoefs
//	stemp_df = stemp_dfc
//
//	SVAR stemp_df  = root:$(df):varsFieldmap:DynResSkewCoefs
//	SVAR stemp_dfc = root:$(dfc):varsFieldmap:DynResSkewCoefs
//	stemp_df = stemp_dfc
//
//End
//
//
//Function PopupDynMultComponent(ctrlName,popNum,popStr) : PopupMenuControl
//	String ctrlName
//	Variable popNum
//	String popStr
//
//	NVAR DynNormComponent = :varsFieldmap:DynNormComponent
//	DynNormComponent = popNum
//	
//End
//
//
//Function CalcDynIntegralsMultipoles(ctrlName) : ButtonControl
//	String ctrlName
//	
//	NVAR StartXTraj = :varsFieldmap:StartXTraj
//	Wave/Z Traj = $"TrajX"+num2str(StartXTraj/1000)
//	
//	if (WaveExists(Traj))
//		// Start timer
//		variable timerRefNum, calc_time
//		timerRefNum = StartMSTimer
//	
//		IntegralMultipoles_Traj()
//		ResidualDynMultipolesCalc()
//		UpdateResultsPanel()
//		
//		// Stop timer
//		calc_time = StopMSTimer(timerRefNum)
//		Print "Elapsed time :", calc_time*(10^(-6)), " seconds"
//	else
//		DoAlert 0, "Trajectory not found."
//	endif
//	
//End
//
//
//Function IntegralMultipoles_Traj([ReloadField])
//	variable ReloadField
//
//	NVAR TrajShift 		     	 = root:varsCAMTO:TrajShift
//
//	NVAR BeamDirection 		    = :varsFieldmap:BeamDirection
//	NVAR FittingOrder 		    = :varsFieldmap:FittingOrderTraj
//	NVAR NormComponent  		 = :varsFieldmap:DynNormComponent
//	NVAR KNorm					 = :varsFieldmap:DynKNorm   
//	NVAR DistCenter				 = :varsFieldmap:DistcenterTraj
//	NVAR StartXTraj            = :varsFieldmap:StartXTraj
//	NVAR GridMin               = :varsFieldmap:GridMinTraj
//	NVAR GridMax               = :varsFieldmap:GridMaxTraj
//	NVAR GridNrpts           	 = :varsFieldmap:GridNrptsTraj
//	NVAR MultipolesTrajShift	 = :varsFieldmap:MultipolesTrajShift
//	SVAR NormalCoefs      		 = :varsFieldmap:DynNormalCoefs
//	SVAR SkewCoefs      		 = :varsFieldmap:DynSkewCoefs
//	
//	print ("Calculating Multipoles over Trajectory X = " + num2str(StartXTraj/1000))
//
//	if (ParamIsDefault(ReloadField))
//		ReloadField = 1
//	endif	
//
//	if (ReloadField)
//		print ("Reloading Field Data...")
//		variable spline_flag
//		spline_flag = CalcFieldmapInterpolant()
//		
//		if(spline_flag == 1)
//			print("Field data successfully reloaded.")
//		else
//			print("Problem with cubic spline XOP. Using single thread calculation.")
//		endif
//	endif
//
//	variable i, j, n, f
//	variable PosNrpts, PosS, PosX, PosL
//
//	Make/O/D/N=(GridNrpts) Dyn_Mult_Grid
//	if (GridNrpts > 1)
//		for (j=0; j<GridNrpts; j=j+1)
//			Dyn_Mult_Grid[j] = GridMin/1000 + j*(GridMax/1000-GridMin/1000)/(GridNrpts-1)
//		endfor
//	else
//		Dyn_Mult_Grid[0] = GridMin/1000 
//	endif
//	
//	Wave TrajX = $"TrajX"+num2str(StartXTraj/1000)
//	Wave VelX  = $"Vel_X"+num2str(StartXTraj/1000)
//
//	variable skew_idx = 0
//	variable normal_idx
//
//	if (BeamDirection == 1)
//		Wave TrajL = $"TrajY"+num2str(StartXTraj/1000)
//		Wave VelL  = $"Vel_Y"+num2str(StartXTraj/1000)
//		normal_idx = 2
//	else
//		Wave TrajL = $"TrajZ"+num2str(StartXTraj/1000)
//		Wave VelL  = $"Vel_Z"+num2str(StartXTraj/1000)
//		normal_idx = 1	
//	endif
//		
//	f =  round(MultipolesTrajShift/TrajShift)
//	if (f == 0)
//		f = 1
//	endif
//	PosNrpts = round(numpnts(TrajX)/f)
//	
//	Make/D/O/N=(GridNrpts,3) Field_Perp	
//	Make/O/D/N=(PosNrpts) Dyn_Mult_Ang , Dyn_Mult_Pos, Dyn_Mult_PosX, Dyn_Mult_PosYZ, Temp
//	Make/O/D/N=(PosNrpts, FittingOrder) Dyn_Mult_Normal, Dyn_Mult_Skew
//	Make/O/D/N=(FittingOrder) W_coef, W_sigma
//	Make/O/D/N=(PosNrpts, GridNrpts) Bx, By, Bz
//	
//	
//	variable normal_on = 0
//	for (j=0; j<FittingOrder; j=j+1)
//		if (cmpstr(NormalCoefs[j],"0")==0)
//			normal_on = 1
//			break
//		endif
//	endfor
//
//	variable skew_on = 0
//	for (j=0; j<FittingOrder; j=j+1)
//		if (cmpstr(SkewCoefs[j],"0")==0)
//			skew_on = 1
//			break
//		endif
//	endfor
//	
//	PosS = 0
//	PosX = TrajX[0]
//	PosL = TrajL[0]
//	for (i=0; i<PosNrpts; i=i+1)
//	
//		Dyn_Mult_Ang[i] = atan(VelX[i*f]/VelL[i*f])
//		Dyn_Mult_Pos[i] = PosS + sqrt((TrajX[i*f]-PosX)^2  + (TrajL[i*f]-PosL)^2)	
//		PosS = Dyn_Mult_Pos[i]
//		PosX = TrajX[i*f]
//		PosL = TrajL[i*f]
//		Dyn_Mult_PosX[i] = PosX
//		Dyn_Mult_PosYZ[i] = PosL
//		
//		if (spline_flag == 1)
//			Multithread Field_Perp[][] = GetPerpendicularField(x, -Dyn_Mult_Ang[i], TrajX[i*f], TrajL[i*f], Dyn_Mult_Grid)(q)
//		else
//			Field_Perp[][] = GetPerpendicularFieldST(x, -Dyn_Mult_Ang[i], TrajX[i*f], TrajL[i*f], Dyn_Mult_Grid)(q)
//		endif
//
//		Bx[i][] = Field_Perp[q][0]
//		By[i][] = Field_Perp[q][1]
//		Bz[i][] = Field_Perp[q][2]		
//	
//		K0 = 0;K1 = 0;K2 = 0;K3 = 0;K4 = 0;K5 = 0;K6 = 0;K7 = 0;K8 = 0;K9 = 0;K10 = 0;
//		K11 = 0;K12 = 0;K13 = 0;K14 = 0;K15 = 0;K16 = 0;K17 = 0;K18 = 0;K19 = 0 
//			
//		W_coef[] = 0
//		if (normal_on == 1)
//			CurveFit/L=(GridNrpts)/H=NormalCoefs/N=1/Q poly FittingOrder, Field_Perp[][normal_idx] /X=Dyn_Mult_Grid /D
//		endif
//		Dyn_Mult_Normal[i][] = W_coef[q]
//
//		K0 = 0;K1 = 0;K2 = 0;K3 = 0;K4 = 0;K5 = 0;K6 = 0;K7 = 0;K8 = 0;K9 = 0;K10 = 0;
//		K11 = 0;K12 = 0;K13 = 0;K14 = 0;K15 = 0;K16 = 0;K17 = 0;K18 = 0;K19 = 0 
//	
//		W_coef[] = 0
//		if (skew_on == 1)
//			CurveFit/L=(GridNrpts)/H=SkewCoefs/N=1/Q poly FittingOrder, Field_Perp[][skew_idx] /X=Dyn_Mult_Grid /D
//		endif
//		Dyn_Mult_Skew[i][] = W_coef[q]
//	
//	endfor
//
//	Make/O/D/N=(FittingOrder) Dyn_Mult_Normal_Int, Dyn_Mult_Skew_Int
//
//	for (n=0; n<FittingOrder; n=n+1)
//	   	Temp[] = Dyn_Mult_Normal[p][n]
//		Integrate/METH=1 Temp/X=Dyn_Mult_Pos/D=Temp_Integral
//		Dyn_Mult_Normal_Int[n] = Temp_Integral[PosNrpts]
//		
//		Temp[] = Dyn_Mult_Skew[p][n]
//		Integrate/METH=1 Temp/X=Dyn_Mult_Pos/D=Temp_Integral
//		Dyn_Mult_Skew_Int[n] = Temp_Integral[PosNrpts]
//	endfor
//		
//		
//	Duplicate/D/O Dyn_Mult_Normal_Int Dyn_Mult_Normal_Norm
//	Duplicate/D/O Dyn_Mult_Skew_Int   Dyn_Mult_Skew_Norm
//	
//	if (NormComponent == 2) 
//		for (n=0;n<FittingOrder;n=n+1)
//			Dyn_Mult_Normal_Norm[n] = ( ( Dyn_Mult_Normal_Int[n] / Dyn_Mult_Skew_Int[KNorm] ) * (Distcenter/1000)^(n-KNorm) )
//			Dyn_Mult_Skew_Norm[n]   = ( ( Dyn_Mult_Skew_Int [n]  / Dyn_Mult_Skew_Int[KNorm] ) * (Distcenter/1000)^(n-KNorm) )		
//		endfor
//	else
//		for (n=0;n<FittingOrder;n=n+1)
//			Dyn_Mult_Normal_Norm[n] = ( ( Dyn_Mult_Normal_Int[n] / Dyn_Mult_Normal_Int[KNorm] ) * (Distcenter/1000)^(n-KNorm) )
//			Dyn_Mult_Skew_Norm[n]   = ( ( Dyn_Mult_Skew_Int [n]  / Dyn_Mult_Normal_Int[KNorm] ) * (Distcenter/1000)^(n-KNorm) )		
//		endfor
//	endif
//		
//	Make/O/D/N=(GridNrpts) IntBx_X_TrajGrid,  IntBy_X_TrajGrid,  IntBz_X_TrajGrid
//	
//	for (j=0; j<GridNrpts; j=j+1)
//		//Bx
//		Temp[] = Bx[p][j]
//		Integrate/METH=1 Temp/X=Dyn_Mult_Pos/D=Temp_Integral
//		IntBx_X_TrajGrid[j] = Temp_Integral[PosNrpts]
//		
//		//By
//		Temp[] = By[p][j]
//		Integrate/METH=1 Temp/X=Dyn_Mult_Pos/D=Temp_Integral
//		IntBy_X_TrajGrid[j] = Temp_Integral[PosNrpts]
//		
//		//Bz
//		Temp[] = Bz[p][j]
//		Integrate/METH=1 Temp/X=Dyn_Mult_Pos/D=Temp_Integral
//		IntBz_X_TrajGrid[j] = Temp_Integral[PosNrpts]
//		
//	endfor
//
//	Killwaves Bx, By, Bz
//	Killwaves/Z W_coef, W_sigma, W_ParamConfidenceInterval, fit_Field_Perp
//	Killwaves/Z Field_Perp, Temp_Integral, Temp
//			
//End
//
//
//Function ResidualDynMultipolesCalc()
//	     	
//	NVAR StartXTraj        = :varsFieldmap:StartXTraj
//	NVAR BeamDirection     = :varsFieldmap:BeamDirection
//	NVAR FittingOrder	 	= :varsFieldmap:FittingOrderTraj
//	NVAR NormComponent	 	= :varsFieldmap:DynNormComponent
//	NVAR KNorm 				= :varsFieldmap:DynKNorm
//	SVAR ResNormalCoefs    = :varsFieldmap:DynResNormalCoefs
//	SVAR ResSkewCoefs      = :varsFieldmap:DynResSkewCoefs
//
//	print ("Calculating Residual Multipoles over Trajectory X = " + num2str(StartXTraj/1000))
//		
//	Wave Dyn_Mult_Grid
//	Wave Dyn_Mult_Normal_Int
//	Wave Dyn_Mult_Skew_Int  
//	
//	variable BNorm 
//	if (NormComponent == 2)
//		BNorm = Dyn_Mult_Skew_Int[KNorm]
//	else
//		BNorm = Dyn_Mult_Normal_Int[KNorm]
//	endif
//	
//	variable nrpts = numpnts(Dyn_Mult_Grid)
//
//	Make/D/O/N=(nrpts) Dyn_Mult_Normal_Res = 0
//	Make/D/O/N=(nrpts) Dyn_Mult_Skew_Res   = 0
//
//	variable i
//	for (i=0; i<FittingOrder; i=i+1)
//		
//		if (stringmatch(ResNormalCoefs[i], "0"))
//			Dyn_Mult_Normal_Res += (Dyn_Mult_Normal_Int[i]/BNorm)*(Dyn_Mult_Grid ^ (i-KNorm))
//		endif
//
//		if (stringmatch(ResSkewCoefs[i], "0"))
//			Dyn_Mult_Skew_Res += (Dyn_Mult_Skew_Int[i]/BNorm)*(Dyn_Mult_Grid ^ (i-KNorm))
//		endif
//		
//	endfor
//	
//	for (i=0; i<nrpts; i=i+1)
//		if (numtype(Dyn_Mult_Normal_Res[i]) == 1)
//			Dyn_Mult_Normal_Res[i] = NaN
//		endif
//		
//		if (numtype(Dyn_Mult_Skew_Res[i]) == 1)
//			Dyn_Mult_Skew_Res[i] = NaN
//		endif
//
//	endfor
//			
//End
//
//
//Function CalcDynIntegralsMultipolesToAll(ctrlName) : ButtonControl
//	String ctrlName
//	
//	DoAlert 1, "Calculate dynamic multipoles for all fieldmaps?"
//	if (V_flag != 1)
//		return -1
//	endif
//	
//	UpdateFieldmapFolders()
//		
//	Wave/T fieldmapFolders = root:wavesCAMTO:fieldmapFolders
//	NVAR fieldmapCount  = root:varsCAMTO:FIELDMAP_COUNT
//	SVAR fieldmapFolder= root:varsCAMTO:FIELDMAP_FOLDER
//		
//	DFREF df = GetDataFolderDFR()
//	string dfc = GetDataFolder(0)
//	
//	variable i
//	string tdf
//	string empty = ""
//
//	for (i=0; i < fieldmapCount; i=i+1)
//		tdf = fieldmapFolders[i]
//		fieldmapFolder = tdf
//		SetDataFolder root:$(tdf)
//		CopyDynMultipolesConfig_(dfc)
//		Print("Calculating Dynamic Integrals and Multipoles for " + tdf + ":")
//		CalcDynIntegralsMultipoles(empty)
//	endfor
//
//	fieldmapFolder = dfc
//	SetDataFolder df
//	
//End
//
//
//Window Find_Peaks() : Panel
//	PauseUpdate; Silent 1		// building window...
//
//	if (DataFolderExists("root:varsCAMTO")==0)
//		DoAlert 0, "CAMTO variables not found."
//		return 
//	endif
//
//	CloseWindow("Find_Peaks")
//
//	NewPanel/K=1/W=(1380,60,1703,587)
//	
//	SetDrawLayer UserBack
//	SetDrawEnv fillpat= 0
//	DrawRect 4,3,319,30
//	SetDrawEnv fillpat= 0
//	DrawRect 4,30,319,100
//	SetDrawEnv fillpat= 0
//	DrawRect 4,100,319,270
//	SetDrawEnv fillpat= 0
//	DrawRect 4,270,319,435
//	SetDrawEnv fillpat= 0
//	DrawRect 4,435,319,522
//	
//	TitleBox LXAxis,pos={65,4},size={63,22},title="Find Peaks and Zeros",fsize=19,frame=0,fstyle=1
//	
//	SetVariable PosXPeaks,pos={10,40},size={170,18},title="Position in X [mm] :"
//		
//	PopupMenu FieldAxisPeak, title = "Field Axis :", pos={200,40},size={106,21},proc=FieldAxisPeak
//	PopupMenu FieldAxisPeak,disable=2,value= #"\"Bx;By;Bz\""
//
//	SetVariable StepsYZPeaks,pos={10,70},size={280,18},title="Interpolation Step [mm] :"
//
//	CheckBox CheckBoxPeaks, pos={10,113}, title="",mode=1,proc=SelectPeaksZeros
//
//	PopupMenu PosNegPeak, pos={30,110},size={150,21},proc=PosNegPeaks,title = "Peaks :"
//	PopupMenu PosNegPeak,disable=2,value= #"\"Positive Peaks;Negative Peaks;Both Peaks\""
//	
//	SetVariable NAmplPeaks,pos={10,140},size={305,18},title="Peak amplitude related to the maximum [%] :"
//	SetVariable NAmplPeaks,limits={0,100,1}
//
//	Button PeaksProc,pos={10,170},size={150,55},fsize=14,proc=FindPeaksProc,title="Find Peaks"
//	Button PeaksProc,fstyle=1,disable=2
//	TitleBox    AvgPeriodPeaksLabel,pos={180,170},size={120,18},frame=0,title="Average Period [mm]: "
//	ValDisplay  AvgPeriodPeaks,pos={180,195},size={120,18}
//	
//	Button PeaksGraph,pos={15,235},size={140,24},proc=GraphPeaksProc,title="Show Peaks"
//	Button PeaksGraph,fstyle=1,disable=2
//	
//	Button PeaksTable,pos={170,235},size={140,24},proc=TablePeaksProc,title="Show Table"
//	Button PeaksTable,fstyle=1,disable=2
//
//	CheckBox CheckBoxZeros, pos={10,278}, title="\tZeros:",mode=1,proc=SelectPeaksZeros
//
//	SetVariable NAmplZeros,pos={10,305},size={305,18},title="Stop the search for amplitude lower than [%] :"
//	SetVariable NAmplZeros,limits={0,100,1}
//
//	Button ZerosProc,pos={10,335},size={150,55},fsize=14,proc=FindZerosProc,title="Find Zeros"
//	Button ZerosProc,fstyle=1,disable=2
//	TitleBox    AvgPeriodZerosLabel,pos={180,335},size={120,18},frame=0,title="Average Period [mm]: "
//	ValDisplay  AvgPeriodZeros,pos={180,360},size={120,18}
//	
//	Button ZerosGraph,pos={15,400},size={140,24},proc=GraphZerosProc,title="Show Zeros"
//	Button ZerosGraph,fstyle=1,disable=2
//	
//	Button ZerosTable,pos={170,400},size={140,24},proc=TableZerosProc,title="Show Table"
//	Button ZerosTable,fstyle=1,disable=2
//		
//	SetVariable fieldmapdir,pos={17,440},size={290,18},title="Fieldmap directory: "
//	SetVariable fieldmapdir,noedit=1,value=root:varsCAMTO:FIELDMAP_FOLDER
//	TitleBox copy_title,pos={15,467},size={145,18},frame=0,title="Copy Configuration from:"
//	PopupMenu copy_dir,pos={160,465},size={145,18},bodyWidth=145,mode=0,proc=CopyFindPeaksConfig,title=" "
//	Button apply_to_all,pos={15,490},size={290,25},fstyle=1,proc=FindPeaksZerosToAll,title="Calculate for All Field Maps"	
//	
//	UpdateFieldmapFolders()
//	UpdateFindPeaksPanel()
//	
//EndMacro
//
//
//Function UpdateFindPeaksPanel()
//	
//	string panel_name
//	panel_name = WinList("Find_Peaks",";","")	
//	if (stringmatch(panel_name, "Find_Peaks;")==0)
//		return -1
//	endif
//	
//	SVAR df = root:varsCAMTO:FIELDMAP_FOLDER
//	
//	NVAR fieldmapCount = root:varsCAMTO:FIELDMAP_COUNT
//	if (fieldmapCount > 1)
//		string FieldmapList = getFieldmapDirs()
//		PopupMenu copy_dir,win=Find_Peaks,disable=0,value= #("\"" + FieldmapList + "\"")
//		Button apply_to_all,win=Find_Peaks,disable=0
//	else
//		PopupMenu copy_dir,win=Find_Peaks,disable=2		
//		Button apply_to_all,win=Find_Peaks,disable=2
//	endif
//	
//	if (strlen(df) > 0)
//		NVAR StartX = root:$(df):varsFieldmap:StartX
//		NVAR EndX = root:$(df):varsFieldmap:EndX
//		NVAR StepsX = root:$(df):varsFieldmap:StepsX
//		NVAR FieldAxisPeak = root:$(df):varsFieldmap:FieldAxisPeak
//		NVAR PeaksPosNeg = root:$(df):varsFieldmap:PeaksPosNeg
//		NVAR PeaksSelected = root:$(df):varsFieldmap:PeaksSelected
//	
//		SetVariable PosXPeaks, win=Find_Peaks, value= root:$(df):varsFieldmap:PosXAux
//		SetVariable PosXPeaks, win=Find_Peaks,limits={StartX, EndX, StepsX}
//		PopupMenu FieldAxisPeak, win=Find_Peaks,disable=0, mode=FieldAxisPeak
//		SetVariable StepsYZPeaks, win=Find_Peaks,value= root:$(df):varsFieldmap:StepsYZPeaks
//		SetVariable StepsYZPeaks, win=Find_Peaks,limits={0,inf,0}
//
//		PopupMenu PosNegPeak, win=Find_Peaks, mode=PeaksPosNeg		
//		SetVariable NAmplPeaks, win=Find_Peaks,value= root:$(df):varsFieldmap:NAmplPeaks
//		SetVariable NAmplZeros, win=Find_Peaks,value= root:$(df):varsFieldmap:NAmplZeros
//		ValDisplay  AvgPeriodPeaks, win=Find_Peaks, value=#("root:"+ df + ":varsFieldmap:AvgPeriodPeaks" )
//		ValDisplay  AvgPeriodZeros, win=Find_Peaks, value=#("root:"+ df + ":varsFieldmap:AvgPeriodZeros" )
//		
//		CheckBox CheckBoxPeaks, win=Find_Peaks, disable=0, value=0
//		CheckBox CheckBoxZeros, win=Find_Peaks, disable=0, value=0
//		
//		if (PeaksSelected == 1)
//			CheckBox CheckBoxPeaks, win=Find_Peaks, value=1		
//			SetPeaksDisable(0)
//			SetZerosDisable(2)
//		else
//			CheckBox CheckBoxZeros, win=Find_Peaks, value=1
//			SetPeaksDisable(2)
//			SetZerosDisable(0)
//		endif
//		
//	else
//		CheckBox CheckBoxPeaks, win=Find_Peaks, disable=2
//		CheckBox CheckBoxZeros, win=Find_Peaks, disable=2
//		SetPeaksDisable(2)
//		SetZerosDisable(2)	
//	endif
//	
//End
//
//
//Function CopyFindPeaksConfig(ctrlName,popNum,popStr) : PopupMenuControl
//	String ctrlName
//	Variable popNum
//	String popStr
//	
//	SelectCopyDirectory(popNum,popStr)
//
//	SVAR dfc = root:varsCAMTO:FieldmapCopy
//	CopyFindPeaksConfig_(dfc)
//	
//	UpdateFindPeaksPanel()
//
//End
//
//
//Function CopyFindPeaksConfig_(dfc)
//	string dfc
//	
//	SVAR df  = root:varsCAMTO:FIELDMAP_FOLDER
//	Wave/T fieldmapFolders= root:wavesCAMTO:fieldmapFolders
//	
//	UpdateFieldmapFolders()	
//	FindValue/Text=dfc/TXOP=4 fieldmapFolders
//	
//	if (V_Value!=-1)	
//		NVAR temp_df  = root:$(df):varsFieldmap:FieldAxisPeak
//		NVAR temp_dfc = root:$(dfc):varsFieldmap:FieldAxisPeak
//		temp_df = temp_dfc
//
//		NVAR temp_df  = root:$(df):varsFieldmap:PeaksPosNeg
//		NVAR temp_dfc = root:$(dfc):varsFieldmap:PeaksPosNeg
//		temp_df = temp_dfc
//
//		NVAR temp_df  = root:$(df):varsFieldmap:PeaksSelected
//		NVAR temp_dfc = root:$(dfc):varsFieldmap:PeaksSelected
//		temp_df = temp_dfc
//
//		NVAR temp_df  = root:$(df):varsFieldmap:PosXAux
//		NVAR temp_dfc = root:$(dfc):varsFieldmap:PosXAux
//		temp_df = temp_dfc
//
//		NVAR temp_df  = root:$(df):varsFieldmap:StepsYZPeaks
//		NVAR temp_dfc = root:$(dfc):varsFieldmap:StepsYZPeaks
//		temp_df = temp_dfc
//
//		NVAR temp_df  = root:$(df):varsFieldmap:NAmplPeaks
//		NVAR temp_dfc = root:$(dfc):varsFieldmap:NAmplPeaks
//		temp_df = temp_dfc
//
//		NVAR temp_df  = root:$(df):varsFieldmap:NAmplZeros
//		NVAR temp_dfc = root:$(dfc):varsFieldmap:NAmplZeros
//		temp_df = temp_dfc
//						
//	else
//		DoAlert 0, "Data folder not found."
//	endif
//		
//End
//
//
//Function SelectPeaksZeros(cb) : CheckBoxControl
//	STRUCT WMCheckboxAction& cb
//	
//	SVAR df = root:varsCAMTO:FIELDMAP_FOLDER
//		
//	if (cb.eventCode == -1)
//		return 0
//	endif
//			
//	strswitch (cb.ctrlName)
//		case "CheckBoxPeaks":
//			CheckBox CheckBoxZeros,win=Find_Peaks,value=0
//			SetZerosDisable(2)
//			
//			if (strlen(df) > 0)
//				NVAR PeaksSelected = root:$(df):varsFieldmap:PeaksSelected
//				PeaksSelected = 1
//				SetPeaksDisable(0)
//			else
//				SetPeaksDisable(2)
//			endif
//					
//			break
//		case "CheckBoxZeros":
//			CheckBox CheckBoxPeaks,win=Find_Peaks,value=0
//			SetPeaksDisable(2)
//				
//			if (strlen(df) > 0)
//				NVAR PeaksSelected = root:$(df):varsFieldmap:PeaksSelected
//				PeaksSelected = 0
//				SetZerosDisable(0)
//			else
//				SetZerosDisable(2)
//			endif
//								
//			break
//	endswitch
//	return 0
//End
//
//
//Function SetPeaksDisable(disable)
//	variable disable
//	PopupMenu PosNegPeak,win=Find_Peaks,disable=disable
//	SetVariable NAmplPeaks,win=Find_Peaks,disable=disable
//	ValDisplay AvgPeriodPeaks,win=Find_Peaks,disable=disable
//	TitleBox AvgPeriodPeaksLabel,win=Find_Peaks,disable=disable
//	Button PeaksProc, win=Find_Peaks, disable=disable
//	Button PeaksGraph,win=Find_Peaks, disable=disable
//	Button PeaksTable,win=Find_Peaks, disable=disable
//End	
//
//
//Function SetZerosDisable(disable)
//	variable disable
//	ValDisplay AvgPeriodZeros,win=Find_Peaks,disable=disable
//	SetVariable NAmplZeros,win=Find_Peaks,disable=disable
//	TitleBox AvgPeriodZerosLabel,win=Find_Peaks,disable=disable
//	Button ZerosProc, win=Find_Peaks, disable=disable
//	Button ZerosGraph,win=Find_Peaks, disable=disable
//	Button ZerosTable,win=Find_Peaks, disable=disable
//End
//
//
//Function FieldAxisPeak(ctrlName,popNum,popStr) : PopupMenuControl
//	String ctrlName
//	Variable popNum
//	String popStr
//
//	SVAR FieldAxisPeakStr = :varsFieldmap:FieldAxisPeakStr
//	NVAR FieldAxisPeak    = :varsFieldmap:FieldAxisPeak 
//	FieldAxisPeak = popNum
//	
//	if (FieldAxisPeak == 1)
//		FieldAxisPeakStr = "Bx"
//	elseif (FieldAxisPeak == 2) 
//		FieldAxisPeakStr = "By"
//	elseif (FieldAxisPeak == 3)
//		FieldAxisPeakStr = "Bz"
//	endif
//	
//End
//
//
//Function PosNegPeaks(ctrlName,popNum,popStr) : PopupMenuControl
//	String ctrlName
//	Variable popNum
//	String popStr
//
//	NVAR PeaksPosNeg = :varsFieldmap:PeaksPosNeg 
//	PeaksPosNeg = popNum
//End
//
//
//Function FindPeaksZerosToAll(ctrlName) : ButtonControl
//	String ctrlName
//	
//	DoAlert 1, "Calculate for all fieldmaps?"
//	if (V_flag != 1)
//		return -1
//	endif
//	
//	UpdateFieldmapFolders()
//		
//	Wave/T fieldmapFolders = root:wavesCAMTO:fieldmapFolders
//	NVAR fieldmapCount  = root:varsCAMTO:FIELDMAP_COUNT
//	SVAR fieldmapFolder= root:varsCAMTO:FIELDMAP_FOLDER
//		
//	DFREF df = GetDataFolderDFR()
//	string dfc = GetDataFolder(0)
//	
//	variable i
//	string tdf
//	string empty = ""
//
//	for (i=0; i < fieldmapCount; i=i+1)
//		tdf = fieldmapFolders[i]
//		fieldmapFolder = tdf
//		SetDataFolder root:$(tdf)
//		CopyFindPeaksConfig_(dfc)
//		
//		NVAR PeaksSelected = root:$(tdf):varsFieldmap:PeaksSelected
//		if(PeaksSelected==1)
//			Print(" ")
//			Print("Finding Peaks for " + tdf + ":")
//			FindPeaksProc(empty)
//		else
//			Print(" ")
//			Print("Finding Zeros for " + tdf + ":")
//			FindZerosProc(empty)
//		endif
//		
//	endfor
//
//	fieldmapFolder = dfc
//	SetDataFolder df
//	
//End
//
//
//Function FindPeaksProc(ctrlName)
//	String ctrlName
//
//	NVAR StartYZ        = :varsFieldmap:StartYZ
//	NVAR EndYZ          = :varsFieldmap:EndYZ
//	NVAR NPointsYZ      = :varsFieldmap:NPointsYZ
//	NVAR PosXAux        = :varsFieldmap:PosXAux
//	NVAR FieldAxisPeak  = :varsFieldmap:FieldAxisPeak	
//	NVAR PeaksPosNeg    = :varsFieldmap:PeaksPosNeg
//	NVAR NAmplPeaks     = :varsFieldmap:NAmplPeaks
//	NVAR StepsYZPeaks   = :varsFieldmap:StepsYZPeaks
//	NVAR AvgPeriodPeaks = :varsFieldmap:AvgPeriodPeaks
//	
//	variable NPointsYZPeak = ((EndYZ - StartYZ)/StepsYZPeaks) + 1
//		
//	variable i
//	variable ii
//	variable j	
//	string Name
//	variable valorpeak
//	variable Maximum
//	variable Minimum
//	variable Baseline
//	
//	Killwaves/Z PositionPeaksNeg, ValuePeaksNeg, PositionPeaksPos, ValuePeaksPos
//	if (PeaksPosNeg == 1)
//		Make/D/O/N=(1) PositionPeaksPos
//		Make/D/O/N=(1) ValuePeaksPos	
//	elseif (PeaksPosNeg == 2)
//		Make/D/O/N=(1) PositionPeaksNeg
//		Make/D/O/N=(1) ValuePeaksNeg
//	elseif (PeaksPosNeg == 3)
//		Make/D/O/N=(1) PositionPeaksPos
//		Make/D/O/N=(1) ValuePeaksPos	
//		Make/D/O/N=(1) PositionPeaksNeg
//		Make/D/O/N=(1) ValuePeaksNeg		
//	endif
//
//	if (FieldAxisPeak == 1)
//		Name = "RaiaBx_X"+num2str(PosXAux/1000)
//		
//	elseif (FieldAxisPeak == 2)
//		Name = "RaiaBy_X"+num2str(PosXAux/1000)	
//
//	elseif (FieldAxisPeak == 3)	
//		Name = "RaiaBz_X"+num2str(PosXAux/1000)	
//
//	endif
//
//	string Interp_Field_Name
//	Interp_Field_Name = "Interp_" + Name
//	
//	Wave C_PosYZ	
//	Wave Field = $Name
//	
//	if (NPointsYZPeak == NPointsYZ)
//		Duplicate/O C_PosYZ, Interp_C_PosYZ
//		Duplicate/O Field, $(Interp_Field_Name)
//		Wave Interp_Field = $(Interp_Field_Name)
//	else
//		Interpolate2/T=2/N=(NPointsYZPeak)/X=Interp_C_PosYZ/Y=$(Interp_Field_Name) C_PosYZ, Field
//		Wave Interp_Field = $(Interp_Field_Name)
//	endif
//	
//	//Get Maximum and Minimun
//	Maximum = WaveMax(Interp_Field)
//	Minimum = WaveMin(Interp_Field)
//	
//	//Baseline
//	if (PeaksPosNeg == 1 || PeaksPosNeg == 3)
//		Baseline = (Maximum - Maximum * (NAmplPeaks/100))
//			
//		valorpeak = Baseline			
//		j = 0
//
//		//Find Peaks
//		for (i=0; i<NPointsYZPeak; i=i+1)
//			if (Interp_Field[i] > Baseline)
//				if (valorpeak < Interp_Field[i])
//					valorpeak = Interp_Field[i]
//					PositionPeaksPos[j] = Interp_C_PosYZ[i]
//					ValuePeaksPos[j] = Interp_Field[i]
//				endif				
//			else
//				if (Interp_Field[i-1] > Baseline)
//					valorpeak = Baseline
//					j = j + 1
//					InsertPoints j, 1, PositionPeaksPos
//					InsertPoints j, 1, ValuePeaksPos					
//				endif
//			endif
//		endfor			
//		DeletePoints j, 1, PositionPeaksPos
//		DeletePoints j, 1, ValuePeaksPos		
//		
//		wavestats/Q ValuePeaksPos
//		Print("Positive Peaks")
//		Print("Average : " + num2str(V_avg))
//		Print("Standard Deviation : " + num2str(V_sdev))	
//		Print("Error : "+ num2str(abs(V_sdev/V_avg*100)) + "%")
//		EraseStatsVariables()	
//		
//		Make/O/N=(numpnts(PositionPeaksPos) - 1) PositionPeaksPosDiff
//		
//		for (i=0; i<numpnts(PositionPeaksPosDiff); i=i+1)
//			PositionPeaksPosDiff[i] = PositionPeaksPos[i+1] - PositionPeaksPos[i]
//		endfor
//		
//		variable AvgPeriodPeaksPos = Mean(PositionPeaksPosDiff)
//		
//		Killwaves/Z PositionPeaksPosDiff
//		
//	endif		
//				
//	if (PeaksPosNeg == 2 || PeaksPosNeg == 3)
//		Baseline = (Minimum - Minimum * (NAmplPeaks/100))
//			
//		valorpeak = Baseline			
//		j = 0
//
//		//Find Peaks
//		for (i=0; i<NPointsYZPeak; i=i+1)
//			if (Interp_Field[i] < Baseline)
//				if (valorpeak > Interp_Field[i])
//					valorpeak = Interp_Field[i]
//					PositionPeaksNeg[j] = Interp_C_PosYZ[i]
//					ValuePeaksNeg[j] = Interp_Field[i]
//				endif				
//			else
//				if (Interp_Field[i-1] < Baseline)
//					valorpeak = Baseline
//					j = j + 1
//					InsertPoints j, 1, PositionPeaksNeg
//					InsertPoints j, 1, ValuePeaksNeg					
//				endif
//			endif
//		endfor			
//		DeletePoints j, 1, PositionPeaksNeg
//		DeletePoints j, 1, ValuePeaksNeg
//		
//		wavestats/Q ValuePeaksNeg
//		Print("Negative Peaks")
//		Print("Average : " + num2str(V_avg))
//		Print("Standard Deviation : " + num2str(V_sdev))		
//		Print("Error : "+ num2str(abs(V_sdev/V_avg*100)) + "%")
//		EraseStatsVariables()	
//
//		Make/O/N=(numpnts(PositionPeaksNeg) - 1) PositionPeaksNegDiff
//	
//		for (i=0; i<numpnts(PositionPeaksNegDiff); i=i+1)
//			PositionPeaksNegDiff[i] = PositionPeaksNeg[i+1] - PositionPeaksNeg[i]
//		endfor
//
//		variable AvgPeriodPeaksNeg = Mean(PositionPeaksNegDiff)
//
//		Killwaves/Z PositionPeaksNegDiff
//		
//	endif
//	
//	if (PeaksPosNeg == 1)
//		AvgPeriodPeaks = 1000*(AvgPeriodPeaksPos)
//		
//	elseif (PeaksPosNeg == 2)
//		AvgPeriodPeaks = 1000*(AvgPeriodPeaksNeg)
//		
//	elseif (PeaksPosNeg == 3)
//		AvgPeriodPeaks = 1000*(AvgPeriodPeaksPos + AvgPeriodPeaksNeg)/2
//		
//	endif
//	
//End
//
//
//Function GetAvgPositivePeaks(Field, Ampl)
//	Wave Field
//	variable Ampl
//	
//	variable i, j
//	variable npts, maximum, minimum, baseline, valorpeak
//	
//	Make/D/O/N=(1)/FREE PeaksValues	
//			
//	//Get Maximum and Minimun
//	maximum = WaveMax(Field)
//	minimum = WaveMin(Field)
//	
//	npts = numpnts(Field)
//	
//	//Baseline
//	baseline = (maximum - maximum * (Ampl/100))
//	valorpeak = baseline			
//	j = 0
//
//	//Find Peaks
//	for (i=0; i<npts; i=i+1)
//		if (Field[i] > baseline)
//			if (valorpeak < Field[i])
//				valorpeak = Field[i]
//				PeaksValues[j] = Field[i]
//			endif				
//		else
//			if (Field[i-1] > baseline)
//				valorpeak = baseline
//				j = j + 1
//				InsertPoints j, 1, PeaksValues					
//			endif
//		endif
//	endfor			
//	DeletePoints j, 1, PeaksValues	
//		
//	return Mean(PeaksValues)
//End
//
//
//Function GetAvgNegativePeaks(Field, Ampl)
//	Wave Field
//	variable Ampl
//	
//	variable i, j
//	variable npts, maximum, minimum, baseline, valorpeak
//	
//	Make/D/O/N=(1) PeaksValues	
//			
//	//Get Maximum and Minimun
//	maximum = WaveMax(Field)
//	minimum = WaveMin(Field)
//	
//	npts = numpnts(Field)
//	
//	//Baseline
//	baseline = (minimum - minimum * (Ampl/100))
//	valorpeak = baseline			
//	j = 0
//
//	//Find Peaks
//	for (i=0; i<npts; i=i+1)
//		if (Field[i] < baseline)
//			if (valorpeak > Field[i])
//				valorpeak = Field[i]
//				PeaksValues[j] = Field[i]
//			endif				
//		else
//			if (Field[i-1] < baseline)
//				valorpeak = baseline
//				j = j + 1
//				InsertPoints j, 1, PeaksValues					
//			endif
//		endif
//	endfor			
//	DeletePoints j, 1, PeaksValues	
//		
//	return Mean(PeaksValues)
//End
//
//
//Function GraphPeaksProc(ctrlName) : ButtonControl
//	String ctrlName
//		
//	NVAR PosXAux       = :varsFieldmap:PosXAux
//	NVAR FieldAxisPeak = :varsFieldmap:FieldAxisPeak	
//	
//	Wave Interp_C_PosYZ
//	
//	string Name
//	
//	if (FieldAxisPeak == 1)
//		Name = "RaiaBx_X"+num2str(PosXAux/1000)
//			
//	elseif (FieldAxisPeak == 2)
//		Name = "RaiaBy_X"+num2str(PosXAux/1000)	
//	
//	elseif (FieldAxisPeak == 3)	
//		Name = "RaiaBz_X"+num2str(PosXAux/1000)	
//	
//	endif
//	
//	Wave Interp_Field = $("Interp_" + Name)
//	
//	CloseWindow("PeaksGraph")
//		
//	if ((WaveExists(ValuePeaksPos)) || (WaveExists(ValuePeaksNeg)))	
//		if (WaveExists(ValuePeaksPos))
//			Display/N=PeaksGraph/K=1 ValuePeaksPos vs PositionPeaksPos
//			if (WaveExists(ValuePeaksNeg))			
//				Appendtograph/W=PeaksGraph ValuePeaksNeg vs PositionPeaksNeg
//			endif
//		elseif (WaveExists(ValuePeaksNeg))
//			Display/N=PeaksGraph/K=1 ValuePeaksNeg vs PositionPeaksNeg
//		endif
//		
//		Label bottom "\\Z12Longitudinal Position YZ [m]"
//		if (FieldAxisPeak == 1)
//			Label left "\\Z12Field Bx [T]"
//		elseif (FieldAxisPeak == 2)
//			Label left "\\Z12Field By [T]"
//		elseif (FieldAxisPeak == 3)
//			Label left "\\Z12Field Bz [T]"
//		endif
//		
//		TextBox/W=PeaksGraph/C/N=text0/A=MC "PosX [mm] = "+ num2str(PosXAux)
//		
//		ModifyGraph/W=PeaksGraph mode=3,marker=19,msize=2
//	
//		if (WaveExists(ValuePeaksNeg))
//			ModifyGraph/W=PeaksGraph rgb(ValuePeaksNeg)=(0,9472,39168)
//		endif
//		
//		AppendToGraph/C=(0,0,0) Interp_Field vs Interp_C_PosYZ
//		
//	endif	
//End
//
//
//Function TablePeaksProc(ctrlName) : ButtonControl
//	String ctrlName
//
//	CloseWindow("PeaksTable")
//	
//	if ((WaveExists(ValuePeaksPos)) || (WaveExists(ValuePeaksNeg)))	
//		if (WaveExists(ValuePeaksPos))
//			Edit/N=PeaksTable/K=1 PositionPeaksPos, ValuePeaksPos
//			if (WaveExists(ValuePeaksNeg))			
//				Appendtotable/W=PeaksTable PositionPeaksNeg, ValuePeaksNeg
//			endif
//		elseif (WaveExists(ValuePeaksNeg))
//			Edit/N=PeaksTable/K=1 PositionPeaksNeg, ValuePeaksNeg
//		endif
//	endif
//End
//
//
//Function FindZerosProc(ctrlName)
//	String ctrlName
//
//	NVAR StartYZ        = :varsFieldmap:StartYZ
//	NVAR EndYZ          = :varsFieldmap:EndYZ
//	NVAR NPointsYZ      = :varsFieldmap:NPointsYZ
//	NVAR PosXAux        = :varsFieldmap:PosXAux
//	NVAR FieldAxisPeak  = :varsFieldmap:FieldAxisPeak	
//	NVAR StepsYZPeaks   = :varsFieldmap:StepsYZPeaks
//	NVAR NAmplZeros     = :varsFieldmap:NAmplZeros
//	NVAR AvgPeriodZeros = :varsFieldmap:AvgPeriodZeros
//	
//	variable NPointsYZPeak = ((EndYZ - StartYZ)/StepsYZPeaks) + 1
//	
//	string Name
//	variable i, idx0, idx1 
//	variable Baseline, startx, endx
//	variable pos0, pos1, field0, field1
//	
//	if (FieldAxisPeak == 1)
//		Name = "RaiaBx_X"+num2str(PosXAux/1000)
//		
//	elseif (FieldAxisPeak == 2)
//		Name = "RaiaBy_X"+num2str(PosXAux/1000)	
//
//	elseif (FieldAxisPeak == 3)	
//		Name = "RaiaBz_X"+num2str(PosXAux/1000)	
//
//	endif
//
//	string Interp_Field_Name
//	Interp_Field_Name = "Interp_" + Name
//	
//	Wave C_PosYZ	
//	Wave Field = $Name
//	
//	if (NPointsYZPeak == NPointsYZ)
//		Duplicate/O C_PosYZ, Interp_C_PosYZ
//		Duplicate/O Field, $(Interp_Field_Name)
//		Wave Interp_Field = $(Interp_Field_Name)
//	else
//		Interpolate2/T=2/N=(NPointsYZPeak)/X=Interp_C_PosYZ/Y=$(Interp_Field_Name) C_PosYZ, Field
//		Wave Interp_Field = $(Interp_Field_Name)
//	endif
//
//	Duplicate/O Interp_Field, Interp_Field_Abs
//	for (i=0; i<NPointsYZPeak; i=i+1)
//		Interp_Field_Abs[i] = Abs(Interp_Field_Abs[i])
//	endfor
//	
//	// Search range
//	Baseline = (NAmplZeros/100)*WaveMax(Interp_Field_Abs)
//	FindLevels/EDGE=0/P/Q Interp_Field_Abs, Baseline
//	Wave W_FindLevels
//	if (numpnts(W_FindLevels) > 1)
//		startx = Floor(W_FindLevels[0])
//		endx = Ceil(W_FindLevels[numpnts(W_FindLevels)-1])
//	else
//		startx = 0
//		endx = NPointsYZPeak-1
//	endif
//	Killwaves/Z W_FindLevels
//		
//	// Search for zeros
//	FindLevels/EDGE=0/P/Q/R=(startx,endx) Interp_Field, 0
//	Print("Find Zeros")
//	Print("Number of zeros found : " + num2str(V_LevelsFound))
//	
//	Wave W_FindLevels
//	Make/D/O/N=(numpnts(W_FindLevels)) PositionZeros	
//	Make/D/O/N=(numpnts(W_FindLevels)) ValueZeros	
//	
//	for (i=0; i<numpnts(W_FindLevels); i=i+1)
//		idx0 = Floor(W_FindLevels[i])
//		idx1 = Ceil(W_FindLevels[i])
//		pos0 = Interp_C_PosYZ[idx0]
//		pos1 = Interp_C_PosYZ[idx1]
//		field0 = Interp_Field[idx0]
//		field1 = Interp_Field[idx1]
//		PositionZeros[i] = pos0*(1 - (W_FindLevels[i] - idx0)/(idx1 -idx0)) + pos1*((W_FindLevels[i] - idx0)/(idx1 -idx0))
//		ValueZeros[i] = field0*(1 - (W_FindLevels[i] - idx0)/(idx1 -idx0)) + field1*((W_FindLevels[i] - idx0)/(idx1 -idx0))
//	endfor
//	
//	Killwaves/Z W_FindLevels
//	
//	Make/O/N=(numpnts(PositionZeros) - 1) PositionZerosDiff
//	for (i=0; i<numpnts(PositionZerosDiff); i=i+1)
//		PositionZerosDiff[i] = PositionZeros[i+1] - PositionZeros[i]
//	endfor
//	variable AvgPeriod = Mean(PositionZerosDiff)
//
//	AvgPeriodZeros = 2*AvgPeriod*1000
//
//	Killwaves/Z PositionZerosDiff
//	
//End
//
//
//Function GraphZerosProc(ctrlName) : ButtonControl
//	String ctrlName
//		
//	NVAR PosXAux       = :varsFieldmap:PosXAux
//	NVAR FieldAxisPeak = :varsFieldmap:FieldAxisPeak	
//	
//	Wave Interp_C_PosYZ
//	
//	string Name
//	
//	if (FieldAxisPeak == 1)
//		Name = "RaiaBx_X"+num2str(PosXAux/1000)
//			
//	elseif (FieldAxisPeak == 2)
//		Name = "RaiaBy_X"+num2str(PosXAux/1000)	
//	
//	elseif (FieldAxisPeak == 3)	
//		Name = "RaiaBz_X"+num2str(PosXAux/1000)	
//	
//	endif
//	
//	Wave Interp_Field = $("Interp_" + Name)
//	
//	string PanelName
//	PanelName = WinList("ZerosGraph",";","")	
//	if (stringmatch(PanelName, "ZerosGraph;"))
//		Killwindow ZerosGraph
//	endif
//		
//	if ((WaveExists(ValueZeros)) || (WaveExists(PositionZeros)))	
//		Display/N=ZerosGraph/K=1 ValueZeros vs PositionZeros
//		
//		Label bottom "\\Z12Longitudinal Position YZ [m]"
//		if (FieldAxisPeak == 1)
//			Label left "\\Z12Field Bx [T]"
//		elseif (FieldAxisPeak == 2)
//			Label left "\\Z12Field By [T]"
//		elseif (FieldAxisPeak == 3)
//			Label left "\\Z12Field Bz [T]"
//		endif
//		
//		TextBox/W=ZerosGraph/C/N=text0/A=MC "PosX [mm] = "+ num2str(PosXAux)
//		
//		ModifyGraph/W=ZerosGraph mode=3,marker=19,msize=1.5
//			
//		AppendToGraph/C=(0,0,0) Interp_Field vs Interp_C_PosYZ
//		
//	endif	
//End
//
//
//Function TableZerosProc(ctrlName) : ButtonControl
//	String ctrlName
//
//	CloseWindow("ZerosTable")
//	
//	if ((WaveExists(ValueZeros)) || (WaveExists(PositionZeros)))	
//		Edit/N=ZerosTable/K=1 PositionZeros, ValueZeros
//	endif
//End
//
//
//Window Phase_Error() : Panel
//	PauseUpdate; Silent 1
//	
//	if (DataFolderExists("root:varsCAMTO")==0)
//		DoAlert 0, "CAMTO variables not found."
//		return 
//	endif
//	
//	CloseWindow("Phase_Error")
//	
//	NewPanel/K=1/W=(80,260,404,703)
//	SetDrawLayer UserBack
//	SetDrawEnv fillpat= 0
//	DrawRect 3,3,320,75
//	SetDrawEnv fillpat= 0
//	DrawRect 3,75,320,155
//	SetDrawEnv fillpat= 0
//	DrawRect 3,155,320,315	
//	SetDrawEnv fillpat= 0
//	DrawRect 3,315,320,353
//	SetDrawEnv fillpat= 0
//	DrawRect 3,353,320,440
//						
//	TitleBox    traj,pos={10,25},size={90,16},fsize=14,fstyle=1,frame=0,title="Trajectory"
//	ValDisplay  traj_x,pos={110,10},size={200,18},title="Start X [mm]:    "
//	ValDisplay  traj_angle,pos={110,30},size={200,18},title="Angle XY(Z) [°]:"
//	ValDisplay  traj_yz,pos={110,50},size={200,18},title="Start YZ [mm]:  "
//
//	TitleBox    period,pos={10,105},size={90,16},fsize=14,fstyle=1,frame=0,title="ID Period"
//	CheckBox    chb_period_peaks,pos={90,88}, title="",mode=1,proc=SelectIDPeriod
//	ValDisplay  period_peaks,pos={110,88},size={200,18},title="Avg. from peaks [mm]:"
//	CheckBox    chb_period_zeros,pos={90,108}, title="",mode=1,proc=SelectIDPeriod
//	ValDisplay  period_zeros,pos={110,108},size={200,18},title="Avg. from  zeros [mm]:"
//	CheckBox    chb_period_nominal,pos={90,128}, title="",mode=1,proc=SelectIDPeriod
//	SetVariable period_nominal,pos={110,128},size={200,18},title="Nominal value [mm]:"
//	SetVariable period_nominal, limits={0,inf,1}
//	
//	TitleBox title,pos={60,160},size={200,24},title="Insertion Device Phase Error",fsize=16,fstyle=1,frame=0
//
//	SetVariable cut_periods,pos={20,185},size={280,16},title="Number of periods to skip at the endings: ", limits={0,1000,1}
//	
//	PopupMenu semi_period_pos,pos={20,210},size={100,20},proc=PopupSemiPeriodPos,title="Get semi-period positions from: "
//	PopupMenu semi_period_pos,value= #"\"Peaks;Zeros\""
//	
//	Button calc_phase_error,pos={20,235},size={140,70},proc=CalcPhaseError,fsize=14,title="Calculate \nPhase Error"
//	Button calc_phase_error,disable=2,fstyle=1
//	TitleBox    phase_error_label,pos={180,245},size={120,18},frame=0,title="RMS Phase Error [°]: "
//	ValDisplay  phase_error,pos={180,270},size={120,18}
//	
//	Button phase_error_graph,pos={20,322},size={140,24},proc=ShowPhaseError,title="Show Phase Error"
//	Button phase_error_graph,fstyle=1,disable=2
//	
//	Button phase_error_table,pos={170,322},size={140,24},proc=TablePhaseError,title="Show Table"
//	Button phase_error_table,fstyle=1,disable=2
//	
//	SetVariable fieldmapdir,pos={20,360},size={290,18},title="Field Map Directory: "
//	SetVariable fieldmapdir,noedit=1,value=root:varsCAMTO:FIELDMAP_FOLDER
//	TitleBox copy_title,pos={15,388},size={145,18},frame=0,title="Copy Configuration from:"
//	PopupMenu copy_dir,pos={160,385},size={145,18},bodyWidth=145,mode=0,proc=CopyPhaseErrorConfig,title=" "
//	Button apply_to_all,pos={15,410},size={290,25},fstyle=1,proc=CalcPhaseErrorToAll,title="Calculate Phase Error for All Field Maps"
//	
//	UpdateFieldmapFolders()
//	UpdatePhaseErrorPanel()
//	
//EndMacro
//
//
//Function UpdatePhaseErrorPanel()
//
//	string panel_name
//	panel_name = WinList("Phase_Error",";","")	
//	if (stringmatch(panel_name, "Phase_Error;")==0)
//		return -1
//	endif
//	
//	SVAR df = root:varsCAMTO:FIELDMAP_FOLDER
//
//	NVAR fieldmapCount = root:varsCAMTO:FIELDMAP_COUNT
//	if (fieldmapCount > 1)
//		string FieldmapList = getFieldmapDirs()
//		PopupMenu copy_dir,win=Phase_Error,disable=0,value= #("\"" + FieldmapList + "\"")
//		Button apply_to_all,win=Phase_Error,disable=0
//	else
//		PopupMenu copy_dir,win=Phase_Error,disable=2		
//		Button apply_to_all,win=Phase_Error,disable=2
//	endif
//		
//	if (strlen(df) > 0)
//		NVAR PeriodPeaksZerosNominal = root:$(df):varsFieldmap:PeriodPeaksZerosNominal
//		NVAR SemiPeriodsPeaksZeros = root:$(df):varsFieldmap:SemiPeriodsPeaksZeros
//				
//		ValDisplay traj_x, win=Phase_Error, value=#("root:"+ df + ":varsFieldmap:StartXTraj" )
//		ValDisplay traj_angle,win=Phase_Error,value=#("root:"+ df + ":varsFieldmap:EntranceAngle" )
//		ValDisplay traj_yz, win=Phase_Error, value=#("root:"+ df + ":varsFieldmap:StartYZTraj" )
//
//		ValDisplay  period_peaks, win=Phase_Error, value=#("root:"+ df + ":varsFieldmap:AvgPeriodPeaks" )
//		ValDisplay  period_zeros, win=Phase_Error, value=#("root:"+ df + ":varsFieldmap:AvgPeriodZeros" )
//		SetVariable period_nominal, win=Phase_Error, value=root:$(df):varsFieldmap:IDPeriodNominal
//
//		CheckBox chb_period_peaks,win=Phase_Error,disable=0
//		CheckBox chb_period_zeros,win=Phase_Error,disable=0
//		CheckBox chb_period_nominal,win=Phase_Error,disable=0
//
//		SetVariable cut_periods, win=Phase_Error, value=root:$(df):varsFieldmap:IDCutPeriods
//		PopupMenu semi_period_pos,win=Phase_Error,disable=0, mode=SemiPeriodsPeaksZeros
//		
//		Button calc_phase_error,win=Phase_Error,disable=0
//		ValDisplay phase_error, win=Phase_Error, value=#("root:"+ df + ":varsFieldmap:IDPhaseError" )
//		Button phase_error_graph,win=Phase_Error,disable=0
//		Button phase_error_table,win=Phase_Error,disable=0
//
//		if (PeriodPeaksZerosNominal == 0)
//			CheckBox chb_period_peaks,win=Phase_Error,value=1
//			CheckBox chb_period_zeros,win=Phase_Error,value=0
//			CheckBox chb_period_nominal,win=Phase_Error,value=0
//			ValDisplay  period_peaks, win=Phase_Error, disable=0
//			ValDisplay  period_zeros, win=Phase_Error, disable=2
//			SetVariable period_nominal, win=Phase_Error, disable=2
//		elseif (PeriodPeaksZerosNominal == 1)
//			CheckBox chb_period_peaks,win=Phase_Error,value=0
//			CheckBox chb_period_zeros,win=Phase_Error,value=1
//			CheckBox chb_period_nominal,win=Phase_Error,value=0
//			ValDisplay  period_peaks, win=Phase_Error, disable=2
//			ValDisplay  period_zeros, win=Phase_Error, disable=0
//			SetVariable period_nominal, win=Phase_Error, disable=2
//		else
//			CheckBox chb_period_peaks,win=Phase_Error,value=0
//			CheckBox chb_period_zeros,win=Phase_Error,value=0
//			CheckBox chb_period_nominal,win=Phase_Error,value=1
//			ValDisplay  period_peaks, win=Phase_Error, disable=2
//			ValDisplay  period_zeros, win=Phase_Error, disable=2
//			SetVariable period_nominal, win=Phase_Error, disable=0		
//		endif
//
//	else
//		PopupMenu semi_period_pos,win=Phase_Error,disable=2
//		Button calc_phase_error,win=Phase_Error,disable=2
//		Button phase_error_graph,win=Phase_Error,disable=2
//		Button phase_error_table,win=Phase_Error,disable=2
//		CheckBox chb_period_peaks,win=Phase_Error,disable=2
//		CheckBox chb_period_zeros,win=Phase_Error,disable=2
//		CheckBox chb_period_nominal,win=Phase_Error,disable=2
//		ValDisplay  period_peaks, win=Phase_Error, disable=2
//		ValDisplay  period_zeros, win=Phase_Error, disable=2
//		SetVariable period_nominal, win=Phase_Error, disable=2		
//	endif
//	
//End
//
//
//Function CopyPhaseErrorConfig(ctrlName,popNum,popStr) : PopupMenuControl
//	String ctrlName
//	Variable popNum
//	String popStr
//	
//	SelectCopyDirectory(popNum,popStr)
//
//	SVAR dfc = root:varsCAMTO:FieldmapCopy
//	CopyPhaseErrorConfig_(dfc)
//	
//	UpdatePhaseErrorPanel()
//
//End
//
//
//Function CopyPhaseErrorConfig_(dfc)
//	string dfc
//	
//	SVAR df  = root:varsCAMTO:FIELDMAP_FOLDER
//	Wave/T fieldmapFolders= root:wavesCAMTO:fieldmapFolders
//	
//	UpdateFieldmapFolders()	
//	FindValue/Text=dfc/TXOP=4 fieldmapFolders
//				
//	if (V_Value!=-1)	
//		NVAR temp_df  = root:$(df):varsFieldmap:PeriodPeaksZerosNominal
//		NVAR temp_dfc = root:$(dfc):varsFieldmap:PeriodPeaksZerosNominal
//		temp_df = temp_dfc
//
//		NVAR temp_df  = root:$(df):varsFieldmap:SemiPeriodsPeaksZeros
//		NVAR temp_dfc = root:$(dfc):varsFieldmap:SemiPeriodsPeaksZeros
//		temp_df = temp_dfc
//
//		NVAR temp_df  = root:$(df):varsFieldmap:IDPeriodNominal
//		NVAR temp_dfc = root:$(dfc):varsFieldmap:IDPeriodNominal
//		temp_df = temp_dfc
//		
//		NVAR temp_df  = root:$(df):varsFieldmap:IDCutPeriods
//		NVAR temp_dfc = root:$(dfc):varsFieldmap:IDCutPeriods
//		temp_df = temp_dfc
//				
//	else
//		DoAlert 0, "Data folder not found."
//	endif
//		
//End
//
//
//Function SelectIDPeriod(cb) : CheckBoxControl
//	STRUCT WMCheckboxAction& cb
//	
//	SVAR df = root:varsCAMTO:FIELDMAP_FOLDER
//		
//	if (cb.eventCode == -1)
//		return 0
//	endif
//			
//	strswitch (cb.ctrlName)
//		case "chb_period_peaks":
//			CheckBox chb_period_zeros,win=Phase_Error,value=0
//			CheckBox chb_period_nominal,win=Phase_Error,value=0
//			ValDisplay  period_peaks, win=Phase_Error, disable=0
//			ValDisplay  period_zeros, win=Phase_Error, disable=2
//			SetVariable period_nominal, win=Phase_Error, disable=2
//			
//			if (strlen(df) > 0)
//				NVAR PeriodPeaksZerosNominal = root:$(df):varsFieldmap:PeriodPeaksZerosNominal
//				PeriodPeaksZerosNominal = 0
//			endif
//					
//			break
//		case "chb_period_zeros":
//			CheckBox chb_period_peaks,win=Phase_Error,value=0
//			CheckBox chb_period_nominal,win=Phase_Error,value=0
//			ValDisplay  period_peaks, win=Phase_Error, disable=2
//			ValDisplay  period_zeros, win=Phase_Error, disable=0
//			SetVariable period_nominal, win=Phase_Error, disable=2
//					
//			if (strlen(df) > 0)
//				NVAR PeriodPeaksZerosNominal = root:$(df):varsFieldmap:PeriodPeaksZerosNominal
//				PeriodPeaksZerosNominal = 1
//			endif
//								
//			break
//		case "chb_period_nominal":
//			CheckBox chb_period_peaks,win=Phase_Error,value=0
//			CheckBox chb_period_zeros,win=Phase_Error,value=0
//			ValDisplay  period_peaks, win=Phase_Error, disable=2
//			ValDisplay  period_zeros, win=Phase_Error, disable=2
//			SetVariable period_nominal, win=Phase_Error, disable=0
//					
//			if (strlen(df) > 0)
//				NVAR PeriodPeaksZerosNominal = root:$(df):varsFieldmap:PeriodPeaksZerosNominal
//				PeriodPeaksZerosNominal = 2
//			endif
//								
//			break
//	endswitch
//	return 0
//End
//
//
//Function PopupSemiPeriodPos(ctrlName,popNum,popStr) : PopupMenuControl
//	String ctrlName
//	Variable popNum
//	String popStr
//
//	NVAR SemiPeriodsPeaksZeros = :varsFieldmap:SemiPeriodsPeaksZeros
//	SemiPeriodsPeaksZeros = popNum
//	
//End
//
//
//Function CalcPhaseErrorToAll(ctrlName) : ButtonControl
//	String ctrlName
//	
//	DoAlert 1, "Calculate phase error for all fieldmaps?"
//	if (V_flag != 1)
//		return -1
//	endif
//	
//	UpdateFieldmapFolders()
//		
//	Wave/T fieldmapFolders = root:wavesCAMTO:fieldmapFolders
//	NVAR fieldmapCount  = root:varsCAMTO:FIELDMAP_COUNT
//	SVAR fieldmapFolder= root:varsCAMTO:FIELDMAP_FOLDER
//		
//	DFREF df = GetDataFolderDFR()
//	string dfc = GetDataFolder(0)
//	
//	variable i
//	string tdf
//	string empty = ""
//
//	for (i=0; i < fieldmapCount; i=i+1)
//		tdf = fieldmapFolders[i]
//		fieldmapFolder = tdf
//		SetDataFolder root:$(tdf)
//		CopyPhaseErrorConfig_(dfc)	
//		Print("Calculationg Phase Error for " + tdf + ":")
//		CalcPhaseError(empty)		
//	endfor
//
//	fieldmapFolder = dfc
//	SetDataFolder df
//	
//End
//
//
//Function CalcPhaseError(ctrlName) : ButtonControl
//	String ctrlName
//
//   	NVAR Charge     = root:varsCAMTO:Charge
//	NVAR Mass       = root:varsCAMTO:Mass
//	NVAR LightSpeed = root:varsCAMTO:LightSpeed
//	NVAR TrajShift  = root:varsCAMTO:TrajShift
//
//	NVAR StartXTraj = :varsFieldmap:StartXTraj
//	NVAR BeamDirection = :varsFieldmap:BeamDirection
//	
//	NVAR FieldX = :varsFieldmap:FieldX
//	NVAR FieldY = :varsFieldmap:FieldY
//	NVAR FieldZ = :varsFieldmap:FieldZ
//	
//	NVAR NAmplPeaks     = :varsFieldmap:NAmplPeaks
//	NVAR NAmplZeros     = :varsFieldmap:NAmplZeros
//
//	NVAR SemiPeriodsPeaksZeros = :varsFieldmap:SemiPeriodsPeaksZeros	
//	NVAR PeriodPeaksZerosNominal = :varsFieldmap:PeriodPeaksZerosNominal
//	NVAR AvgPeriodPeaks = :varsFieldmap:AvgPeriodPeaks
//	NVAR AvgPeriodZeros = :varsFieldmap:AvgPeriodZeros
//	NVAR IDPeriodNominal = :varsFieldmap:IDPeriodNominal
//	
//	NVAR IDPeriod       = :varsFieldmap:IDPeriod
//	NVAR IDCutPeriods   = :varsFieldmap:IDCutPeriods
//	NVAR IDPhaseError   = :varsFieldmap:IDPhaseError
//	
//	Wave/Z TrajH = $"TrajX"+num2str(StartXTraj/1000)
//	Wave/Z PositionPeaksPos
//	Wave/Z PositionPeaksNeg
//
//	if (WaveExists(TrajH) == 0)
//		DoAlert 0,"Trajectory not found."
//		return -1	
//	endif
//
//	if (PeriodPeaksZerosNominal == 0)
//		IDPeriod = AvgPeriodPeaks
//	elseif (PeriodPeaksZerosNominal == 1)
//		IDPeriod = AvgPeriodZeros
//	else
//		IDPeriod = IDPeriodNominal
//	endif
//
//	if (IDPeriod == 0)
//		DoAlert 0,"ID Period must be a non-zero positive value."
//		return -1	
//	endif
//
//	if (BeamDirection == 1)
//		Wave/Z TrajL = $"TrajY"+num2str(StartXTraj/1000)
//		Wave/Z TrajV = $"TrajZ"+num2str(StartXTraj/1000)
//	else
//		Wave/Z TrajV = $"TrajY"+num2str(StartXTraj/1000)
//		Wave/Z TrajL = $"TrajZ"+num2str(StartXTraj/1000)	
//	endif
//	
//	variable energy = GetParticleEnergy()
//	
//	variable TotalEnergy_J  = energy*1E9*abs(Charge)
//	variable Gama  = TotalEnergy_J / (Mass * LightSpeed^2)
//	variable ChargeVel = ((1 - 1/Gama^2)*LightSpeed^2)^0.5
//	variable Bt = ChargeVel/LightSpeed 
//
//	variable i, j, n, idx, s, ci, hi, vi, li, ce, he, ve, le, nsp
//	variable AvgPos, AvgNeg, AvgBx, AvgBy, AvgBz
//	variable pos_init, prev_pos, pos
//	variable Kv, Kh, K
//	variable Lambda
//
//	//Get semi-period positions
//	if (SemiPeriodsPeaksZeros == 1)
//		if (WaveExists(PositionPeaksPos) && WaveExists(PositionPeaksNeg))
//			Concatenate/O/NP {PositionPeaksPos, PositionPeaksNeg}, PositionPeaks
//			Wave PositionPeaks
//			Sort PositionPeaks, PositionPeaks
//		
//			Duplicate/O PositionPeaks, PositionPeaksCut
//		
//			if (numpnts(PositionPeaksCut) > 4*IDCutPeriods+1)
//				DeletePoints 0, 2*IDCutPeriods, PositionPeaksCut
//				DeletePoints numpnts(PositionPeaksCut)-2*IDCutPeriods, 2*IDCutPeriods, PositionPeaksCut		
//			endif
//		
//			Duplicate/O PositionPeaksCut, ID_SemiPeriod_Pos 
//		
//			for (i=1; i<numpnts(ID_SemiPeriod_Pos); i=i+1)
//				ID_SemiPeriod_Pos[i] = PositionPeaksCut[0] + i*(IDPeriod/2/1000)
//			endfor
//			
//			Killwaves/Z PositionPeaks, PositionPeaksCut
//		else
//			DoAlert 0,"Peak positions not found."
//			return -1			
//		endif
//
//	else
//		if (WaveExists(PositionZeros))
//			Duplicate/O PositionZeros, PositionZerosCut
//			
//			if (numpnts(PositionZerosCut) > 4*IDCutPeriods+1)
//				DeletePoints 0, 2*IDCutPeriods, PositionZerosCut
//				DeletePoints numpnts(PositionZerosCut)-2*IDCutPeriods, 2*IDCutPeriods, PositionZerosCut		
//			endif
//			
//			Duplicate/O PositionZerosCut, ID_SemiPeriod_Pos 
//			
//			for (i=1; i<numpnts(ID_SemiPeriod_Pos); i=i+1)
//				ID_SemiPeriod_Pos[i] = PositionZerosCut[0] + i*(IDPeriod/2/1000)
//			endfor
//					
//			Killwaves/Z PositionZerosCut
//			
//		else
//			DoAlert 0,"Zero positions not found."
//			return -1			
//		endif
//	
//	endif
//	
//	nsp = numpnts(ID_SemiPeriod_Pos)
//
//	Make/O/N=(nsp-1) Local_IDPhaseErrorPos
//	for (i=0; i<numpnts(Local_IDPhaseErrorPos); i++)
//		Local_IDPhaseErrorPos[i] = (ID_SemiPeriod_Pos[i+1] + ID_SemiPeriod_Pos[i])/2
//	endfor
//
//	// Calculate ID deflection parameter	
//	Wave Bx = $("VetorCampoX" + num2str(StartXTraj/1000))
//	AvgPos = GetAvgPositivePeaks(Bx, NAmplPeaks)
//	AvgNeg = GetAvgNegativePeaks(Bx, NAmplPeaks)
//	AvgBx = (Abs(AvgPos) + Abs(AvgNeg))/2
//	Kv = 0.0934*AvgBx*IDPeriod
//	
//	if (BeamDirection == 1)
//		Wave Bz = $("VetorCampoZ" + num2str(StartXTraj/1000))
//		AvgPos = GetAvgPositivePeaks(Bz, NAmplPeaks)
//		AvgNeg = GetAvgNegativePeaks(Bz, NAmplPeaks)
//		AvgBz = (Abs(AvgPos) + Abs(AvgNeg))/2	
//		Kh = 0.0934*AvgBz*IDPeriod
//		
//	else
//		Wave By = $("VetorCampoY" + num2str(StartXTraj/1000))
//		AvgPos = GetAvgPositivePeaks(By, NAmplPeaks)
//		AvgNeg = GetAvgNegativePeaks(By, NAmplPeaks)
//		AvgBy = (Abs(AvgPos) + Abs(AvgNeg))/2	
//		Kh = 0.0934*AvgBy*IDPeriod
//		
//	endif
//	
//	K = sqrt(Kv^2 + Kh^2)
//
//	// Calculate first radiation harmonic
//	Lambda = (IDPeriod/(2*(Gama^2)))*(1 + (K^2)/2) //[mm]
//
//	// Get trajectory length in each semi-period
//	Make/O/D/N=(nsp-1) ID_TrajLength = 0
//	Make/O/D/N=(nsp-1) ID_TrajDeviation = 0
//	Make/O/D/N=(nsp-1) ID_TrajDeviationSqr = 0
//	Make/O/D/N=(nsp-1) Local_IDPhaseError = 0
//
//	j = 1	
//	for (i=0; i < nsp - 1; i=i+1)			
//		do 
//			if (TrajL[j] > ID_SemiPeriod_Pos[i])
//				break
//			endif
//			j = j + 1
//		while (1)
//		
//		n = j
//		do 
//			if (TrajL[n] > ID_SemiPeriod_Pos[i+1])
//				break
//			endif
//			n = n + 1
//		while (1)
//		
//		ci = (ID_SemiPeriod_Pos[i] - TrajL[j-1])/(TrajL[j] - TrajL[j-1])
//		hi = TrajH[j-1]*(1 - ci) + TrajH[j]*ci
//		vi = TrajV[j-1]*(1 - ci) + TrajV[j]*ci
//		li = ID_SemiPeriod_Pos[i]
//		
//		ce = (ID_SemiPeriod_Pos[i+1] - TrajL[n-2])/(TrajL[n-1] - TrajL[n-2])
//		he = TrajH[n-2]*(1 - ce) + TrajH[n-1]*ce
//		ve = TrajV[n-2]*(1 - ce) + TrajV[n-1]*ce
//		le = ID_SemiPeriod_Pos[i+1]
//		
//		Duplicate/O/R=[j, n-1] TrajH, TrajHPer
//		Duplicate/O/R=[j, n-1] TrajV, TrajVPer
//		Duplicate/O/R=[j, n-1] TrajL, TrajLPer
//			
//		InsertPoints 0, 1, TrajHPer
//		InsertPoints 0, 1, TrajVPer
//		InsertPoints 0, 1, TrajLPer
//		
//		TrajHPer[0] = hi
//		TrajVPer[0] = vi
//		TrajLPer[0] = li
//	
//		InsertPoints numpnts(TrajHPer), 1, TrajHPer
//		InsertPoints numpnts(TrajVPer), 1, TrajVPer
//		InsertPoints numpnts(TrajLPer), 1, TrajLPer
//			
//		TrajHPer[numpnts(TrajHPer)] = he
//		TrajVPer[numpnts(TrajVPer)] = ve
//		TrajLPer[numpnts(TrajLPer)] = le
//		
//		TrajHPer = TrajHPer*1000 //[mm]
//		TrajVPer = TrajVPer*1000 //[mm]
//		TrajLPer = TrajLPer*1000 //[mm]
//		
//		s = 0
//		for (idx=0; idx < numpnts(TrajLPer); idx=idx+1)	
//			s = s + sqrt((TrajHPer[idx+1] - TrajHPer[idx])^2 + (TrajVPer[idx+1] - TrajVPer[idx])^2 + (TrajLPer[idx+1] - TrajLPer[idx])^2)
//		endfor	
//		ID_TrajLength[i] = s
//		
//		Killwaves/Z TrajHPer, TrajVPer, TrajLPer
//	endfor
//		
//	ID_TrajDeviation = (ID_TrajLength - Mean(ID_TrajLength))/Lambda
//		
//	ID_TrajDeviationSqr = ID_TrajDeviation*ID_TrajDeviation
//		
//	//Calculate phase error
//	Local_IDPhaseError = (2*Pi/Bt)*ID_TrajDeviation*180/Pi
//	
//	IDPhaseError = (2*Pi/Bt)*Sqrt(Sum(ID_TrajDeviationSqr)/numpnts(ID_TrajDeviationSqr))*180/Pi 	
//	
//	print "Insertion device phase error [°]: ", IDPhaseError
//		
//	Killwaves/Z PositionPeaks, ID_TrajLength, ID_TrajDeviation, ID_TrajDeviationSqr
//	
//End
//
//
//Function ShowPhaseError(ctrlName) : ButtonControl
//	String ctrlName
//	
//	CloseWindow("LocalPhaseError")
//
//	NVAR PosXAux       = :varsFieldmap:PosXAux
//	NVAR FieldAxisPeak = :varsFieldmap:FieldAxisPeak	
//
//	string Name
//	
//	if (FieldAxisPeak == 1)
//		Name = "RaiaBx_X"+num2str(PosXAux/1000)
//	elseif (FieldAxisPeak == 2)
//		Name = "RaiaBy_X"+num2str(PosXAux/1000)	
//	elseif (FieldAxisPeak == 3)	
//		Name = "RaiaBz_X"+num2str(PosXAux/1000)	
//	endif
//	
//	Wave Interp_C_PosYZ
//	Wave Interp_Field = $("Interp_" + Name)
//	Display/N=LocalPhaseError/K=1/R Interp_Field vs Interp_C_PosYZ
//	ModifyGraph rgb=(43000, 43000, 43000)
//
//	if (FieldAxisPeak == 1)
//		Label right "\\Z1Field Bx [T]"
//	elseif (FieldAxisPeak == 2)
//		Label right "\\Z12Field By [T]"
//	elseif (FieldAxisPeak == 3)
//		Label right "\\Z12Field Bz [T]"
//	endif
//	
//	Wave Local_IDPhaseError
//	Wave Local_IDPhaseErrorPos
//
//	AppendToGraph Local_IDPhaseError vs Local_IDPhaseErrorPos
//	ModifyGraph lsize(Local_IDPhaseError)=1.5
//	Label bottom "\\Z12Longitudinal Position YZ [m]"
//	Label left "\\Z12Local Phase Error [°]"	
//		
//End
//
//
//Function TablePhaseError(ctrlName) : ButtonControl
//	String ctrlName
//		
//	Wave Local_IDPhaseError
//	Wave Local_IDPhaseErrorPos
//	Edit/K=1 Local_IDPhaseErrorPos, Local_IDPhaseError
//	
//End
//
//
//Function CalcPhaseErrorNominalValues(Period, NrPeriods, LongitudinalCenter)
//	variable Period
//	variable NrPeriods
//	variable LongitudinalCenter
//
//   	NVAR Charge     = root:varsCAMTO:Charge
//	NVAR Mass       = root:varsCAMTO:Mass
//	NVAR LightSpeed = root:varsCAMTO:LightSpeed
//	NVAR TrajShift  = root:varsCAMTO:TrajShift
//
//	NVAR StartXTraj = :varsFieldmap:StartXTraj
//	NVAR BeamDirection = :varsFieldmap:BeamDirection
//	
//	NVAR FieldX = :varsFieldmap:FieldX
//	NVAR FieldY = :varsFieldmap:FieldY
//	NVAR FieldZ = :varsFieldmap:FieldZ
//	
//	Wave/Z TrajH = $"TrajX"+num2str(StartXTraj/1000)
//
//	if (WaveExists(TrajH) == 0)
//		DoAlert 0,"Trajectory not found."
//		return -1	
//	endif
//
//	if (Period == 0)
//		DoAlert 0, "Invalid period value."
//		return -1	
//	endif
//
//	if (NrPeriods == 0)
//		DoAlert 0, "Invalid number of periods."
//		return -1	
//	endif
//
//	if (BeamDirection == 1)
//		Wave/Z TrajL = $"TrajY"+num2str(StartXTraj/1000)
//		Wave/Z TrajV = $"TrajZ"+num2str(StartXTraj/1000)
//	else
//		Wave/Z TrajV = $"TrajY"+num2str(StartXTraj/1000)
//		Wave/Z TrajL = $"TrajZ"+num2str(StartXTraj/1000)	
//	endif
//
//	variable energy = GetParticleEnergy()
//	
//	variable TotalEnergy_J  = energy*1E9*abs(Charge)
//	variable Gama  = TotalEnergy_J / (Mass * LightSpeed^2)
//	variable ChargeVel = ((1 - 1/Gama^2)*LightSpeed^2)^0.5
//	variable Bt = ChargeVel/LightSpeed 
//
//	variable i, j, n, s, ci, hi, vi, ce, he, ve, cp
//	variable pos_init, prev_pos, pos
//	variable bx_peak, by_peak, bz_peak
//	variable Kv, Kh, K
//	variable Lambda
//
//	bx_peak = 0
//	by_peak = 0
//	bz_peak = 0
//	for (i=0; i<numpnts(TrajL); i=i+1)
//		Campo_Espaco(0, TrajL[i])
//		
//		if (abs(FieldX) > bx_peak)
//			bx_peak = abs(FieldX)
//		endif
//
//		if (abs(FieldY) > by_peak)
//			by_peak = abs(FieldY)
//		endif
//
//		if (abs(FieldZ) > bz_peak)
//			bz_peak = abs(FieldZ)
//		endif
//		
//	endfor
//	
//	if (BeamDirection == 1)
//		Kv = 0.0934*bx_peak*Period 
//		Kh = 0.0934*bz_peak*Period
//	else
//		Kv = 0.0934*bx_peak*Period 
//		Kh = 0.0934*by_peak*Period
//	endif
//	K = sqrt(Kv^2 + Kh^2)
//	
//	Lambda = (Period/(2*(Gama^2)))*(1 + (K^2)/2) //[mm]
//
//	Make/O/D/N=(NrPeriods*2 + 1) ID_SemiPeriod_Pos = 0
//
//	pos_init = (LongitudinalCenter - (NrPeriods/2)*Period)/1000	
//	for (i=0; i<=NrPeriods*2; i=i+1)
//		ID_SemiPeriod_Pos[i] = pos_init + i*(Period/2)/1000
//	endfor
//
//	cp = 2
//	if (numpnts(ID_SemiPeriod_Pos) > 4*cp+1)
//		DeletePoints 0, 2*cp, ID_SemiPeriod_Pos
//		DeletePoints numpnts(ID_SemiPeriod_Pos)-2*cp, 2*cp, ID_SemiPeriod_Pos		
//	endif
//
//	Make/O/D/N=(numpnts(ID_SemiPeriod_Pos)-1) ID_TrajLength = 0
//
//	j = 1	
//	for (i=0; i< numpnts(ID_SemiPeriod_Pos) - 1; i=i+1)
//		prev_pos = ID_SemiPeriod_Pos[i]
//		pos = ID_SemiPeriod_Pos[i+1]
//		s = 0
//				
//		do 
//			if (TrajL[j] > prev_pos)
//				break
//			endif
//			j = j + 1
//		while (1)
//		
//		n = j
//		do 
//			if (TrajL[n] > pos)
//				break
//			endif
//			n = n + 1
//		while (1)
//		
//		ci = (prev_pos - TrajL[j-1])/(TrajL[j] - TrajL[j-1])
//		hi = TrajH[j-1]*(1 - ci) + TrajH[j]*ci
//		vi = TrajV[j-1]*(1 - ci) + TrajV[j]*ci
//		s = s + sqrt((hi - TrajH[j])^2 + (vi - TrajV[j])^2 + (prev_pos - TrajL[j])^2)
//		
//		do
//			if (j > n-2)
//				break
//			endif
//			s = s + sqrt((TrajH[j+1] - TrajH[j])^2 + (TrajV[j+1] - TrajV[j])^2 + (TrajL[j+1] - TrajL[j])^2)
//			j = j +1
//		while (1)
//		
//		ce = (pos - TrajL[n-2])/(TrajL[n-1] - TrajL[n-2])
//		he = TrajH[n-2]*(1 - ce) + TrajH[n-1]*ce
//		ve = TrajV[n-2]*(1 - ce) + TrajV[n-1]*ce
//		s = s + sqrt((he - TrajH[n-1])^2 + (ve - TrajV[n-1])^2 + (pos - TrajL[n-1])^2)
//		
//		ID_TrajLength[i] = 1000*s //[mm]
//	endfor
//	
//	Display/K=1 ID_TrajLength
//
//	Make/O/D/N=(numpnts(ID_TrajLength)) ID_TrajDeviation = 0
//	ID_TrajDeviation = ID_TrajLength - Mean(ID_TrajLength)
//	ID_TrajDeviation = (ID_TrajDeviation*ID_TrajDeviation)
//	
//	variable PhaseError = (2*Pi/Bt)*(1/Lambda)*Sqrt(Sum(ID_TrajDeviation)/numpnts(ID_TrajDeviation))*180/Pi 	
//
//	Killwaves/Z ID_SemiPeriod_Pos, ID_TrajLength, ID_TrajDeviation 
//	
//	print "Insertion device phase error [°]: ", PhaseError
//		
//	return PhaseError
//	
//End
//
//

//
//
//Window Results() : Panel
//	PauseUpdate; Silent 1		// building window...
//
//	if (DataFolderExists("root:varsCAMTO")==0)
//		DoAlert 0, "CAMTO variables not found."
//		return 
//	endif
//
//	CloseWindow("Results")
//
//	NewPanel/K=1/W=(1235,60,1573,785)
//	SetDrawEnv fillpat= 0
//	DrawRect 3,5,333,125
//	SetDrawEnv fillpat= 0
//	DrawRect 3,125,333,158
//	SetDrawEnv fillpat= 0
//	DrawRect 3,158,333,275
//	SetDrawEnv fillpat= 0
//	DrawRect 3,275,333,310
//	SetDrawEnv fillpat= 0
//	DrawRect 3,310,333,345
//	SetDrawEnv fillpat= 0
//	DrawRect 3,345,333,445
//	SetDrawEnv fillpat= 0		
//	DrawRect 3,445,333,595
//	SetDrawEnv fillpat= 0		
//	DrawRect 3,595,333,690
//	SetDrawEnv fillpat= 0		
//	DrawRect 3,690,333,720
//	
//	TitleBox field_title,pos={120,10},size={127,16},fsize=16,fstyle=1,frame=0, title="Field Profile"
//	
//	SetVariable PosXField,pos={10,40},size={140,18},title="Pos X [mm]:"
//	SetVariable PosYZField,pos={10,70},size={140,18},title="Pos YZ [mm]:"
//			
//	ValDisplay FieldinPointX,pos={160,32},size={165,17},title="Field X [T]:"
//	ValDisplay FieldinPointX,limits={0,0,0},barmisc={0,1000}
//	ValDisplay FieldinPointY,pos={160,55},size={165,17},title="Field Y  [T]:"
//	ValDisplay FieldinPointY,limits={0,0,0},barmisc={0,1000}
//	ValDisplay FieldinPointZ,pos={160,78},size={165,17},title="Field Z  [T]:"
//	ValDisplay FieldinPointZ,limits={0,0,0},barmisc={0,1000}
//			
//	Button field_point,pos={16,97},size={306,24},proc=Field_in_Point,title="Calculate the field in a point"
//	Button field_point,fstyle=1
//	
//	Button field_Xline,pos={16,130},size={110,24},proc=Field_in_X_Line,title="Show field in X ="
//	Button field_Xline,fstyle=1
//	SetVariable PosXFieldLine,pos={130,134},size={80,18},title="[mm]:"
//	CheckBox graphappend, pos={220,136}, title="Append to Graph"
//	
//	SetVariable StartXProfile,pos={16,170},size={134,18},title="Start X [mm]:"
//	SetVariable EndXProfile,pos={16,195},size={134,18},title="End X [mm]:"
//	SetVariable PosYZProfile,pos={16,221},size={134,18},title="Pos YZ [mm]:"
//		
//	ValDisplay FieldHomX,pos={160,171},size={165,17},title="Homog. X [T]:"
//	ValDisplay FieldHomX,limits={0,0,0},barmisc={0,1000}
//	ValDisplay FieldinPointY1,pos={160,194},size={165,17},title="Homog. Y [T]:"
//	ValDisplay FieldinPointY1,limits={0,0,0},barmisc={0,1000}
//	ValDisplay FieldinPointZ1,pos={160,217},size={165,17},title="Homog. Z [T]:"
//	ValDisplay FieldinPointZ1,limits={0,0,0},barmisc={0,1000}
//		
//	Button field_profile,pos={11,246},size={230,24},proc=Field_Profile,title="Show Field Profile and Homogeneity"
//	Button field_profile,fstyle=1
//	Button field_profile_table,pos={247,246},size={80,24},proc=Field_Profile_Table,title="Show Table"
//	Button field_profile_table,fstyle=1
//	
//	Button show_integrals,pos={11,281},size={230,24},proc=ShowIntegrals,title="Show First Integrals over lines"
//	Button show_integrals,fstyle=1
//	Button show_integrals_table,pos={247,281},size={80,24},proc=show_integrals_Table,title="Show Table"
//	Button show_integrals_table,fstyle=1	
//	
//	Button show_integrals2,pos={11,316},size={230,24},proc=ShowIntegrals2,title="Show Second Integrals over lines"
//	Button show_integrals2,fstyle=1
//	Button show_integrals2_table,pos={247,316},size={80,24},proc=show_integrals2_Table,title="Show Table"
//	Button show_integrals2_table,fstyle=1
//	
//	Button show_multipoles,pos={11,351},size={316,24},proc=ShowMultipoles,title="Show Multipoles Table"
//	Button show_multipoles,fstyle=1
//	
//	Button show_multipoleprofile,pos={11,384},size={230,24},proc=ShowMultipoleProfile,title="Show Multipole Profile: K = "
//	Button show_multipoleprofile,fstyle=1
//	SetVariable mnumber,pos={247,387},size={80,18},title=" "
//	
//	Button show_residmultipoles,pos={11,416},size={230,24},proc=ShowResidMultipoles,title="Show Residual Multipoles"
//	Button show_residmultipoles,fstyle=1
//	Button show_residmultipoles_table,pos={247,416},size={80,24},proc=ShowResidMultipoles_Table,title="Show Table"
//	Button show_residmultipoles_table,fstyle=1
//	
//	TitleBox traj_title1,pos={100,451},size={127,16},fsize=16,fstyle=1,frame=0, title="Particle Trajectory"
//	
//	Button show_trajectories,pos={11,476},size={180,24},proc=ShowTrajectories,title="Show Trajectories"
//	Button show_trajectories,fstyle=1
//	CheckBox referencelines,pos={200,482},size={130,24},title=" Add Reference Lines"
//	
//	Button show_deflections,pos={11,506},size={230,24},proc=ShowDeflections,title="Show Deflections"
//	Button show_deflections,fstyle=1
//	Button show_deflections_Table,pos={247,506},size={80,24},proc=show_deflections_Table,title="Show Table"
//	Button show_deflections_Table,fstyle=1	
//	
//	Button show_integralstraj,pos={11,536},size={230,24},proc=ShowIntegralsTraj,title="Show First Integrals over trajectory"
//	Button show_integralstraj,fstyle=1
//	Button show_integralstraj_Table,pos={247,536},size={80,24},proc=show_integralstraj_Table,title="Show Table"
//	Button show_integralstraj_Table,fstyle=1	
//	
//	Button show_integrals2traj,pos={11,566},size={230,24},proc=ShowIntegrals2Traj,title="Show Second Integrals over trajectory"
//	Button show_integrals2traj,fstyle=1
//	Button show_integrals2traj_Table,pos={247,566},size={80,24},proc=show_integrals2traj_Table,title="Show Table"
//	Button show_integrals2traj_Table,fstyle=1	
//	
//	Button show_dynmultipoles,pos={11,600},size={316,24},proc=ShowDynMultipoles,title="Show Dynamic Multipoles Table"
//	Button show_dynmultipoles,fstyle=1
//	
//	Button show_dynmultipoleprofile,pos={11,630},size={230,24},proc=ShowDynMultipoleProfile,title="Show Dynamic Multipole Profile: K = "
//	Button show_dynmultipoleprofile,fstyle=1
//	SetVariable mtrajnumber,pos={247,633},size={80,18},title=" "
//		
//	Button show_residdynmultipoles,pos={11,660},size={230,24},proc=ShowResidDynMultipoles,title="Show Residual Dynamic Multipoles"
//	Button show_residdynmultipoles,fstyle=1
//	Button show_residdynmultipoles_table,pos={247,660},size={80,24},proc=ShowResidDynMultipoles_Table,title="Show Table"
//	Button show_residdynmultipoles_table,fstyle=1
//
//	SetVariable fieldmapdir,pos={20,697},size={300,18},fstyle=1,title="Fieldmap directory: "
//	SetVariable fieldmapdir,noedit=1,value=root:varsCAMTO:FIELDMAP_FOLDER
//	
//	UpdateFieldmapFolders()
//	UpdateResultsPanel()
//		 
//EndMacro
//
//
//Function UpdateResultsPanel()
//
//	string panel_name
//	panel_name = WinList("Results",";","")	
//	if (stringmatch(panel_name, "Results;")==0)
//		return -1
//	endif
//	
//	SVAR df = root:varsCAMTO:FIELDMAP_FOLDER
//	
//	NVAR StartX  = root:$(df):varsFieldmap:StartX
//	NVAR EndX    = root:$(df):varsFieldmap:EndX
//	NVAR StepsX  = root:$(df):varsFieldmap:StepsX
//	NVAR StartYZ = root:$(df):varsFieldmap:StartYZ
//	NVAR EndYZ   = root:$(df):varsFieldmap:EndYZ
//	NVAR StepsYZ = root:$(df):varsFieldmap:StepsYZ
//	NVAR FittingOrder = root:$(df):varsFieldmap:FittingOrder
//	NVAR FittingOrderTraj = root:$(df):varsFieldmap:FittingOrderTraj
//	
//	NVAR PosXAux  = root:$(df):varsFieldmap:PosXAux 
//	NVAR PosYZAux = root:$(df):varsFieldmap:PosYZAux 
//	NVAR StartXHom = root:$(df):varsFieldmap:StartXHom 
//	NVAR EndXHom   = root:$(df):varsFieldmap:EndXHom    
//	NVAR PosYZHom  = root:$(df):varsFieldmap:PosYZHom  
//	
//	Wave/Z C_PosX 				 = $("root:"+ df + ":C_PosX")
//	Wave/Z IntBx_X 				 = $("root:"+ df + ":IntBx_X")
//	Wave/Z Mult_Normal_Int		 = $("root:"+ df + ":Mult_Normal_Int")
//	Wave/Z Temp_Traj				 = $("root:"+ df + ":PosXTraj")
//	Wave/Z Dyn_Mult_Normal_Int = $("root:"+ df + ":Dyn_Mult_Normal_Int")
//	
//	if (strlen(df) > 0)		
//		SetVariable PosXField, win=Results, value= root:$(df):varsFieldmap:PosXAux
//		SetVariable PosXField, win=Results, limits={StartX,EndX,StepsX}
//		SetVariable PosYZField,win=Results, value= root:$(df):varsFieldmap:PosYZAux
//		SetVariable PosYZField,win=Results, limits={StartYZ,EndYZ,StepsYZ}
//	
//		ValDisplay FieldinPointX,win=Results,value= #("root:"+ df + ":varsFieldmap:FieldXAux")
//		ValDisplay FieldinPointY,win=Results,value= #("root:"+ df + ":varsFieldmap:FieldYAux")
//		ValDisplay FieldinPointZ,win=Results,value= #("root:"+ df + ":varsFieldmap:FieldZAux")
//	
//		SetVariable PosXFieldLine,win=Results, value= root:$(df):varsFieldmap:PosXAux
//		SetVariable PosXFieldLine,win=Results, limits={StartX,EndX,StepsX}
//	
//		CheckBox graphappend,win=Results, disable=0, variable=root:$(df):varsFieldmap:GraphAppend	
//	
//		SetVariable StartXProfile,win=Results, value= root:$(df):varsFieldmap:StartXHom
//		SetVariable StartXProfile,win=Results, limits={StartX,EndX,StepsX}
//		SetVariable EndXProfile,  win=Results, value= root:$(df):varsFieldmap:EndXHom
//		SetVariable EndXProfile,  win=Results, limits={StartX,EndX,StepsX}
//		SetVariable PosYZProfile, win=Results, value= root:$(df):varsFieldmap:PosYZHom
//		SetVariable PosYZProfile, win=Results, limits={StartYZ,EndYZ,StepsYZ}
//		
//		ValDisplay FieldHomX,win=Results,value= #("root:"+ df + ":varsFieldmap:HomogX") 
//		ValDisplay FieldinPointY1,win=Results,value= #("root:"+ df + ":varsFieldmap:HomogY")
//		ValDisplay FieldinPointZ1,win=Results,value= #("root:"+ df + ":varsFieldmap:HomogZ")
//		
//		variable disable_field = 2 
//		if (WaveExists(C_PosX))
//			disable_field = 0
//		endif
//		
//		variable disable_int = 2 
//		if (WaveExists(IntBx_X))
//			disable_int = 0
//		endif
//
//		variable disable_mult = 2 
//		if (WaveExists(Mult_Normal_Int))
//			disable_mult = 0
//		endif
//
//		variable disable_traj = 2 
//		if (WaveExists(Temp_Traj))
//			disable_traj = 0
//		endif
//
//		variable disable_dynmult = 2 
//		if (WaveExists(Dyn_Mult_Normal_Int))
//			disable_dynmult = 0
//		endif
//					
//		Button field_point,win=Results,disable=disable_field
//		Button field_Xline,win=Results,disable=disable_field
//		Button field_profile, win=Results,disable=disable_field
//		Button field_profile_table,win=Results, disable=disable_field
//
//		Button show_integrals,win=Results, disable=disable_int
//		Button show_integrals_table,win=Results, disable=disable_int
//		Button show_integrals2, win=Results,disable=disable_int
//		Button show_integrals2_table,win=Results, disable=disable_int
//		
//		Button show_multipoles,win=Results, disable=disable_mult
//		Button show_multipoleprofile,win=Results, disable=disable_mult
//		Button show_residmultipoles,win=Results, disable=disable_mult
//		Button show_residmultipoles_table,win=Results, disable=disable_mult
//		
//		SetVariable mnumber,win=Results,limits={0,(FittingOrder-1),1},value= root:$(df):varsFieldmap:MultipoleK
//	
//		Button show_trajectories,win=Results, disable=disable_traj
//		Button show_deflections,win=Results, disable=disable_traj
//		Button show_deflections_Table, win=Results,disable=disable_traj
//		Button show_integralstraj,win=Results, disable=disable_traj
//		Button show_integralstraj_Table, win=Results,disable=disable_traj
//		Button show_integrals2traj,win=Results, disable=disable_traj
//		Button show_integrals2traj_Table, win=Results,disable=disable_traj
//		
//		NVAR/Z AddReferenceLines = root:$(df):varsFieldmap:AddReferenceLines
//		if (NVAR_EXists(AddReferenceLines)==0)
//			variable/G root:$(df):varsFieldmap:AddReferenceLines = 0
//		endif
//		
//		CheckBox referencelines,win=Results, disable=disable_traj,variable=root:$(df):varsFieldmap:AddReferenceLines
//		
//		Button show_dynmultipoles, win=Results,disable=disable_dynmult
//		Button show_dynmultipoleprofile,win=Results, disable=disable_dynmult
//		Button show_residdynmultipoles, win=Results,disable=disable_dynmult
//		Button show_residdynmultipoles_table, win=Results,disable=disable_dynmult
//		
//		SetVariable mtrajnumber,win=Results,limits={0,(FittingOrderTraj-1),1},value= root:$(df):varsFieldmap:DynMultipoleK
//		
//		PosXAux  = StartX
//		PosYZAux = StartYZ
//		StartXHom = StartX
//		EndXHom   = EndX	 
//		PosYZHom  = StartYZ	 
//		
//	else
//		
//		Button field_point,win=Results,disable=2
//		Button field_Xline,win=Results,disable=2
//		CheckBox graphappend,win=Results,disable=2
//		Button field_profile,win=Results,disable=2
//		Button field_profile_table,win=Results,disable=2
//		Button show_integrals,win=Results,disable=2
//		Button show_integrals_table,win=Results,disable=2
//		Button show_integrals2,win=Results,disable=2
//		Button show_integrals2_table,win=Results,disable=2
//		Button show_multipoles,win=Results,disable=2
//		Button show_multipoleprofile,win=Results,disable=2
//		Button show_residmultipoles,win=Results,disable=2
//		Button show_residmultipoles_table,win=Results,disable=2
//		Button show_integralstraj,win=Results,disable=2
//		Button show_integralstraj_Table,win=Results,disable=2
//		Button show_integrals2traj,win=Results,disable=2
//		Button show_integrals2traj_Table,win=Results,disable=2
//		Button show_trajectories,win=Results,disable=2
//		CheckBox referencelines,win=Results, disable=2
//		Button show_deflections,win=Results,disable=2
//		Button show_deflections_Table,win=Results,disable=2	
//		Button show_dynmultipoles,win=Results,disable=2
//		Button show_dynmultipoleprofile,win=Results,disable=2
//		Button show_residdynmultipoles,win=Results,disable=2
//		Button show_residdynmultipoles_table,win=Results,disable=2
//		
//	endif
//	
//End
//
//
//Function Field_in_Point(ctrlName) : ButtonControl
//	String ctrlName
//		
//	NVAR PosXAux  = :varsFieldmap:PosXAux
//	NVAR PosYZAux = :varsFieldmap:PosYZAux	
//	
//	NVAR FieldX = :varsFieldmap:FieldX
//	NVAR FieldY = :varsFieldmap:FieldY
//	NVAR FieldZ = :varsFieldmap:FieldZ
//
//	NVAR FieldXAux = :varsFieldmap:FieldXAux
//	NVAR FieldYAux = :varsFieldmap:FieldYAux
//	NVAR FieldZAux = :varsFieldmap:FieldZAux
//	
//	Campo_Espaco(PosXAux/1000,PosYZAux/1000)
//
//	FieldXAux = FieldX
//	FieldYAux = FieldY
//	FieldZAux = FieldZ
//	
//	Print("Field Bx = " + num2str(FieldX))
//	Print("Field By = " + num2str(FieldY))
//	Print("Field Bz = " + num2str(FieldZ))	
//End
//
//
//Function Field_in_X_Line(ctrlName) : ButtonControl
//	String ctrlName
//
//	NVAR PosXAux     = :varsFieldmap:PosXAux
//	NVAR NPointsX    = :varsFieldmap:NPointsX
//	NVAR GraphAppend = :varsFieldmap:GraphAppend
//	
//	Wave C_PosX
//	Wave C_PosYZ	
//	
//	variable i
//	variable iX = 0
//	
//	string NameLines
//	string PanelName
//	
//	for (i=0;i<NPointsX;i=i+1)
//		if (C_PosX[i] >= (PosXAux/1000))
//			iX = i
//			break
//		endif
//	endfor
//		
//	if (GraphAppend == 1)	
//		PanelName = WinList("FieldInLineX",";","")	
//		if (stringmatch(PanelName, "FieldInLineX;"))
//			//Graph Bx
//			NameLines = "RaiaBx_X"+num2str(C_PosX[iX])
//			Wave Tmp = $NameLines	
//			Appendtograph/W=FieldInLineX Tmp vs C_PosYZ
//		else
//			//Graph Bx
//			NameLines = "RaiaBx_X"+num2str(C_PosX[iX])
//			Wave Tmp = $NameLines	
//			Display/N=FieldInLineX/K=1 Tmp vs C_PosYZ
//			Label bottom "\\Z12Longitudinal Position YZ [m]"
//			Label left "\\Z12Field Bx [T]"
//		endif	
//		
//		PanelName = WinList("FieldInLineY",";","")	
//		if (stringmatch(PanelName, "FieldInLineY;"))
//			//Graph By
//			NameLines = "RaiaBy_X"+num2str(C_PosX[iX])
//			Wave Tmp = $NameLines	
//			Appendtograph/W=FieldInLineY Tmp vs C_PosYZ
//		else
//			//Graph By
//			NameLines = "RaiaBy_X"+num2str(C_PosX[iX])
//			Wave Tmp = $NameLines	
//			Display/N=FieldInLineY/K=1 Tmp vs C_PosYZ
//			Label bottom "\\Z12Longitudinal Position YZ [m]"
//			Label left "\\Z12Field By [T]"
//		endif	
//		
//		PanelName = WinList("FieldInLineZ",";","")	
//		if (stringmatch(PanelName, "FieldInLineZ;"))
//			//Graph Bz
//			NameLines = "RaiaBz_X"+num2str(C_PosX[iX])
//			Wave Tmp = $NameLines	
//			Appendtograph/W=FieldInLineZ Tmp vs C_PosYZ
//		else
//			//Graph Bx
//			NameLines = "RaiaBz_X"+num2str(C_PosX[iX])
//			Wave Tmp = $NameLines	
//			Display/N=FieldInLineZ/K=1 Tmp vs C_PosYZ
//			Label bottom "\\Z12Longitudinal Position YZ [m]"
//			Label left "\\Z12Field Bz [T]"
//		endif	
//	else
//		PanelName = WinList("FieldInLineX",";","")	
//		if (stringmatch(PanelName, "FieldInLineX;"))
//			//Graph Bx
//		else
//			//Graph Bx
//			NameLines = "RaiaBx_X"+num2str(C_PosX[iX])
//			Wave Tmp = $NameLines	
//			Display/N=FieldInLineX/K=1 Tmp vs C_PosYZ
//			Label bottom "\\Z12Longitudinal Position YZ [m]"
//			Label left "\\Z12Field Bx [T]"
//		endif	
//		
//		PanelName = WinList("FieldInLineY",";","")	
//		if (stringmatch(PanelName, "FieldInLineY;"))
//			//Graph By
//		else
//			//Graph By
//			NameLines = "RaiaBy_X"+num2str(C_PosX[iX])
//			Wave Tmp = $NameLines	
//			Display/N=FieldInLineY/K=1 Tmp vs C_PosYZ
//			Label bottom "\\Z12Longitudinal Position YZ [m]"
//			Label left "\\Z12Field By [T]"
//		endif	
//		
//		PanelName = WinList("FieldInLineZ",";","")	
//		if (stringmatch(PanelName, "FieldInLineZ;"))
//			//Graph Bz
//		else
//			//Graph Bx
//			NameLines = "RaiaBz_X"+num2str(C_PosX[iX])
//			Wave Tmp = $NameLines	
//			Display/N=FieldInLineZ/K=1 Tmp vs C_PosYZ
//			Label bottom "\\Z12Longitudinal Position YZ [m]"
//			Label left "\\Z12Field Bz [T]"
//		endif		
//	endif
//	
//End
//
//
//Function Field_Profile(ctrlName) : ButtonControl
//	String ctrlName
//
//	NVAR StepsX = :varsFieldmap:StepsX	
//
//	NVAR StartXHom = :varsFieldmap:StartXHom
//	NVAR EndXHom   = :varsFieldmap:EndXHom	
//	NVAR PosYZHom  = :varsFieldmap:PosYZHom	
//	
//	NVAR FieldX = :varsFieldmap:FieldX
//	NVAR FieldY = :varsFieldmap:FieldY
//	NVAR FieldZ = :varsFieldmap:FieldZ
//
//	NVAR HomogX = :varsFieldmap:HomogX
//	NVAR HomogY = :varsFieldmap:HomogY
//	NVAR HomogZ = :varsFieldmap:HomogZ
//	
//	variable i
//	variable NpointsXHom
//		
//	NpointsXHom = ((EndXHom - StartXHom) / StepsX) +1
//	Make/D/O/N=(NpointsXHom) ProfilePosX
//	Make/D/O/N=(NpointsXHom) ProfileFieldX
//	Make/D/O/N=(NpointsXHom) ProfileFieldY
//	Make/D/O/N=(NpointsXHom) ProfileFieldZ		
//	
//	for (i=0;i<NpointsXHom;i=i+1)
//		ProfilePosX[i] = ((StartXHom+i*StepsX)/1000)
//		
//		Campo_Espaco(ProfilePosX[i],(PosYZHom/1000))
//		
//		ProfileFieldX[i] = FieldX
//		ProfileFieldY[i] = FieldY
//		ProfileFieldZ[i] = FieldZ				
//	endfor
//	
//	//Graph Bx
//	Display/N=FieldProfileX/K=1 ProfileFieldX vs ProfilePosX
//	TextBox/C/N=text0/A=MC "PosYZ [m] = "+	num2str(PosYZHom/1000)
//	Label bottom "\\Z12Transversal Position X [m]"
//	Label left "\\Z12Field Bx [T]"
//
//	//Graph By
//	Display/N=FieldProfileY/K=1 ProfileFieldY vs ProfilePosX
//	TextBox/C/N=text0/A=MC "PosYZ [m] = "+	num2str(PosYZHom/1000)
//	Label bottom "\\Z12Transversal Position X [m]"
//	Label left "\\Z12Field By [T]"
//
//	//Graph Bz
//	Display/N=FieldProfileZ/K=1 ProfileFieldZ vs ProfilePosX
//	TextBox/C/N=text0/A=MC "PosYZ [m] = "+	num2str(PosYZHom/1000)
//	Label bottom "\\Z12Transversal Position X [m]"
//	Label left "\\Z12Field Bz [T]"
//	
//	wavestats/Q ProfileFieldX
//	if (V_Max != 0)
//		HomogX = (V_max - V_min) / V_max
//	else
//		HomogX = 0
//	endif
//	EraseStatsVariables()	
//	
//	wavestats/Q ProfileFieldY
//	if (V_Max != 0)
//		HomogY = (V_max - V_min) / V_max
//	else
//		HomogY = 0
//	endif	
//	EraseStatsVariables()	
//
//	wavestats/Q ProfileFieldZ
//	if (V_Max != 0)
//		HomogZ = (V_max - V_min) / V_max
//	else
//		HomogZ = 0
//	endif
//	EraseStatsVariables()	
//	
//	Print("")
//	Print("************************************")	
//	Print(" Field Homogeneity - " + "X-Axis: " + num2str(StartXHom) + " to " + num2str(EndXHom) + " YZ-Axis: " + num2str(PosYZHom) )	
//	Print("")	
//	Print("Homogeneity Bx = " + num2str(HomogX))
//	Print("Homogeneity By = " + num2str(HomogY))
//	Print("Homogeneity Bz = " + num2str(HomogZ))			
//	Print("************************************")		
//	Print("")		
//		
//End
//
//
//Function Field_Profile_table(ctrlName) : ButtonControl
//	String ctrlName
//
//	Edit/K=1 ProfilePosX,ProfileFieldX,ProfileFieldY,ProfileFieldZ
//
//End
//
//
//Function ShowIntegrals(ctrlName) : ButtonControl
//	String ctrlName
//	
//	Wave C_PosX
//	Wave IntBx_X	
//	Wave IntBy_X
//	Wave IntBz_X		
//
//	//Graph Bx
//	Display/N=IntBx_X/K=1 IntBx_X vs C_PosX
//	Label bottom "\\Z12Transversal Position X [m]"
//	Label left "\\Z12First Integral Bx [T.m]"
//
//	//Graph By
//	Display/N=IntBy_X/K=1 IntBy_X vs C_PosX
//	Label bottom "\\Z12Transversal Position X [m]"
//	Label left "\\Z12First Integral By [T.m]"
//
//	//Graph Bz
//	Display/N=IntBz_X/K=1 IntBz_X vs C_PosX
//	Label bottom "\\Z12Transversal Position X [m]"
//	Label left "\\Z12First Integral Bz [T.m]"
//End
//
//
//Function show_integrals_Table(ctrlName) : ButtonControl
//	String ctrlName
//	
//	Edit/K=1 C_PosX,IntBx_X,IntBy_X,IntBz_X
//	
//End
//
//
//Function ShowIntegrals2(ctrlName) : ButtonControl
//	String ctrlName
//	
//	Wave C_PosX
//	Wave Int2Bx_X	
//	Wave Int2By_X
//	Wave Int2Bz_X		
//
//	//Graph Bx
//	Display/N=Int2Bx_X/K=1 Int2Bx_X vs C_PosX
//	Label bottom "\\Z12Transversal Position X [m]"
//	Label left "\\Z12Second Integral Bx [T.m2]"
//
//	//Graph By
//	Display/N=Int2By_X/K=1 Int2By_X vs C_PosX
//	Label bottom "\\Z12Transversal Position X [m]"
//	Label left "\\Z12Second Integral By [T.m2]"
//
//	//Graph Bz
//	Display/N=Int2Bz_X/K=1 Int2Bz_X vs C_PosX
//	Label bottom "\\Z12Transversal Position X [m]"
//	Label left "\\Z12Second Integral Bz [T.m2]"
//End
//
//
//Function show_integrals2_Table(ctrlName) : ButtonControl
//	String ctrlName
//	Edit/K=1 C_PosX,Int2Bx_X,Int2By_X,Int2Bz_X
//	
//End
//
//
//Function ShowMultipoles(ctrlName) : ButtonControl
//	String ctrlName
//	Edit/K=1 Mult_Normal_Int, Mult_Skew_Int, Mult_Normal_Norm, Mult_Skew_Norm
//End
//
//
//Function ShowMultipoleProfile(ctrlName) : ButtonControl
//	String ctrlName
//	
//	NVAR K = :varsFieldmap:MultipoleK
//	
//	wave C_PosYZ
//	wave Mult_Normal
//	wave Mult_Skew
//	
//	string name_normal = "Mult_Normal_k" + num2str(K)
//	string name_skew = "Mult_Skew_k" + num2str(K)
//	
//	string graphlabel
//	if (K == 0)
//		graphlabel = "Dipolar field [T]"
//	elseif (K == 1)
//		graphlabel = "Quadrupolar field [T/m]"
//	elseif (K == 2)
//		graphlabel = "Sextupolar field [T/m²]"
//	elseif (K == 3)
//		graphlabel = "Octupolar field [T/m³]"
//	else
//		graphlabel = num2str(2*(K +1))+ "-polar field"
//	endif
//	
//	Make/D/O/N=(numpnts(C_PosYZ)) $name_normal
//	Wave Tmp_Normal = $name_normal
//	Tmp_Normal[] = Mult_Normal[p][K]
//	Display/N=Mult_Normal/K=1 Tmp_Normal vs C_PosYZ
//	Label bottom "\\Z12Longitudinal Position YZ [m]"
//	Label left  "\\Z12Normal " + graphlabel
//
//	Make/D/O/N=(numpnts(C_PosYZ)) $name_skew
//	Wave Tmp_Skew = $name_skew
//	Tmp_Skew[] = Mult_Skew[p][K]
//	Display/N=Mult_Skew/K=1 Tmp_Skew vs C_PosYZ
//	Label bottom "\\Z12Longitudinal Position YZ [m]"
//	Label left  "\\Z12Skew " + graphlabel
//		
//End
//
//
//Function ShowResidMultipoles(ctrlName) : ButtonControl
//	String ctrlName
//
//	Wave Mult_Grid
//	Wave Mult_Normal_Res
//	Wave Mult_Skew_Res
//
//	Display/N=Mult_Normal_Res/K=1 Mult_Normal_Res vs Mult_Grid
//	Label bottom "\\Z12Transversal Position X [m]"
//	Label left "\\Z12Normalized Residual \rNormal Multipoles"
//
//	Display/N=Mult_Skew_Res/K=1 Mult_Skew_Res vs Mult_Grid
//	Label bottom "\\Z12Transversal Position X [m]"
//	Label left "\\Z12Normalized Residual \rSkew Multipoles"
//
//End
//
//
//Function ShowResidMultipoles_Table(ctrlName) : ButtonControl
//	String ctrlName
//	Edit/K=1 Mult_Grid,Mult_Normal_Res,Mult_Skew_Res
//End
//
//
//Function ShowIntegralsTraj(ctrlName) : ButtonControl
//	String ctrlName
//	
//	Wave PosXTraj
//	Wave IntBx_X_Traj	
//	Wave IntBy_X_Traj	
//	Wave IntBz_X_Traj		
//
//	//Graph Bx
//	Display/N=IntBx_X_Traj/K=1 IntBx_X_Traj vs PosXTraj
//	Label bottom "\\Z12Transversal Position X [m]"
//	Label left "\\Z12First Integral Bx over trajectory [T.m]"
//
//	//Graph By
//	Display/N=IntBy_X_Traj/K=1 IntBy_X_Traj vs PosXTraj
//	Label bottom "\\Z12Transversal Position X [m]"
//	Label left "\\Z12First Integral By over trajectory[T.m]"
//
//	//Graph Bz
//	Display/N=IntBz_X_Traj/K=1 IntBz_X_Traj vs PosXTraj
//	Label bottom "\\Z12Transversal Position X [m]"
//	Label left "\\Z12First Integral Bz over trajectory[T.m]"
//End
//
//
//Function show_integralstraj_Table(ctrlName) : ButtonControl
//	String ctrlName
//	Edit/K=1 PosXTraj,IntBx_X_Traj,IntBy_X_Traj,IntBz_X_Traj
//End
//
//
//Function ShowIntegrals2Traj(ctrlName) : ButtonControl
//	String ctrlName
//	
//	Wave PosXTraj
//	Wave Int2Bx_X_Traj	
//	Wave Int2By_X_Traj	
//	Wave Int2Bz_X_Traj		
//
//	//Graph Bx
//	Display/N=Int2Bx_X_Traj/K=1 Int2Bx_X_Traj vs PosXTraj
//	Label bottom "\\Z12Transversal Position X [m]"
//	Label left "\\Z12Second Integral Bx over trajectory [T.m2]"
//
//	//Graph By
//	Display/N=Int2By_X_Traj/K=1 Int2By_X_Traj vs PosXTraj
//	Label bottom "\\Z12Transversal Position X [m]"
//	Label left "\\Z12Second Integral By over trajectory[T.m2]"
//
//	//Graph Bz
//	Display/N=Int2Bz_X_Traj/K=1 Int2Bz_X_Traj vs PosXTraj
//	Label bottom "\\Z12Transversal Position X [m]"
//	Label left "\\Z12Second Integral Bz over trajectory[T.m2]"
//End
//
//
//Function show_integrals2traj_Table(ctrlName) : ButtonControl
//	String ctrlName
//	Edit/K=1 PosXTraj,Int2Bx_X_Traj,Int2By_X_Traj,Int2Bz_X_Traj
//End
//
//
//Function ShowTrajectories(ctrlName) : ButtonControl
//	String ctrlName
//
//	NVAR StartXTraj    		= :varsFieldmap:StartXTraj
//	NVAR EndXTraj      		= :varsFieldmap:EndXTraj	
//	NVAR StepsXTraj	   		= :varsFieldmap:StepsXTraj
//	NVAR NPointsXTraj  		= :varsFieldmap:NPointsXTraj	
//	NVAR BeamDirection 		= :varsFieldmap:BeamDirection
//	NVAR/Z AddReferenceLines	= :varsFieldmap:AddReferenceLines		
//	
//	if (NVAR_EXists(AddReferenceLines)==0)
//		variable/G :varsFieldmap:AddReferenceLines = 0
//	endif
//	
//	variable i
//	string AxisY
//	string AxisX
//	
//	if (AddReferenceLines==1)
//		CalcRefLinesCrossingPoint()
//		Wave CrossingPointX
//		Wave CrossingPointYZ
//	endif
//	
//	for (i=0;i<NPointsXTraj;i=i+1)
//		// Trajectory X
//		AxisY = "TrajX" + num2str((StartXTraj + i*StepsXTraj)/1000)
//		Wave TmpY = $AxisY
//
//		if (BeamDirection == 1)
//			AxisX = "TrajY" + num2str((StartXTraj + i*StepsXTraj)/1000)
//		else
//			AxisX = "TrajZ" + num2str((StartXTraj + i*StepsXTraj)/1000)		
//		endif
//		Wave TmpX = $AxisX
//		
//		if (i==0)
//			Display/N=TrajectoriesX/K=1 TmpY vs TmpX
//			if (BeamDirection == 1)
//				Label bottom "\\Z12Longitudinal Position Y [m]"
//			else
//				Label bottom "\\Z12Longitudinal Position Z [m]"			
//			endif
//
//			Label left "\\Z12Trajectory X[m]"
//		else
//			Appendtograph/W=TrajectoriesX TmpY vs TmpX
//		endif
//		
//		if (AddReferenceLines==1)
//			string PosLineName, InitLineName, FinalLineName
//			
//			PosLineName = AxisY + "_PosRefLine"
//			InitLineName = AxisY + "_InitRefLine"
//			FinalLineName = AxisY + "_FinalRefLine"
//			
//			Wave/Z PosLine = $(PosLineName)
//			Wave/Z InitLine = $(InitLineName)
//			Wave/Z FinalLine = $(FinalLineName)
//			
//			if (WaveExists(PosLine) == 1 && WaveExists(InitLine) == 1 && WaveExists(FinalLine) == 1)
//				Appendtograph/W=TrajectoriesX/C=(30000, 30000, 30000) InitLine/TN=$InitLineName vs PosLine
//				Appendtograph/W=TrajectoriesX/C=(30000, 30000, 30000) FinalLine/TN=$FinalLineName vs PosLine
//				ModifyGraph/W=TrajectoriesX lstyle($InitLineName)=3
//				ModifyGraph/W=TrajectoriesX lstyle($FinalLineName)=3 
//			endif
//						
//		endif
//		
//		// Trajectory YZ
//		AxisY = "TrajX" + num2str((StartXTraj + i*StepsXTraj)/1000)
//		Wave TmpY = $AxisY
//
//		if (BeamDirection == 1)
//			AxisY = "TrajZ" + num2str((StartXTraj + i*StepsXTraj)/1000)
//			AxisX = "TrajY" + num2str((StartXTraj + i*StepsXTraj)/1000)
//		else
//			AxisY = "TrajY" + num2str((StartXTraj + i*StepsXTraj)/1000)		
//			AxisX = "TrajZ" + num2str((StartXTraj + i*StepsXTraj)/1000)					
//		endif
//		Wave TmpY = $AxisY
//		Wave TmpX = $AxisX
//		
//		if (i==0)
//			Display/N=TrajectoriesYZ/K=1 TmpY vs TmpX
//			if (BeamDirection == 1)
//				Label bottom "\\Z12Longitudinal Position Y [m]"
//				Label left "\\Z12Trajectory Z[m]"
//			else
//				Label bottom "\\Z12Longitudinal Position Z [m]"			
//				Label left "\\Z12Trajectory Y[m]"				
//			endif
//		else
//			Appendtograph/W=TrajectoriesYZ TmpY vs TmpX
//		endif
//
//	endfor
//	
//	if (AddReferenceLines==1)
//		string tagtext, yzstr
//		variable xval
//		Appendtograph/W=TrajectoriesX/C=(30000, 30000, 30000) CrossingPointX/TN='CrossingPoint' vs CrossingPointYZ
//		ModifyGraph/W=TrajectoriesX mode('CrossingPoint')=3, marker('CrossingPoint')=19, msize('CrossingPoint')=2
//		
//		for (i=0; i<NPointsXTraj; i=i+1)
//			xval = pnt2x(CrossingPointYZ, i)
//			if (BeamDirection == 1)
//				yzstr = "Y"
//			else
//				yzstr = "Z"
//			endif
//			sprintf tagtext, "X = %.3f mm\n%s = %.3f mm", CrossingPointX[i]*1000, yzstr, CrossingPointYZ[i]*1000
//			Tag/X=20/W=TrajectoriesX/F=2/L=2 'CrossingPoint', xval, tagtext
//		endfor
//		
//	endif
//	
//End
//
//
//Function CalcRefLinesCrossingPoint()
//
//	NVAR StartXTraj    		= :varsFieldmap:StartXTraj
//	NVAR EndXTraj      		= :varsFieldmap:EndXTraj	
//	NVAR StepsXTraj	   		= :varsFieldmap:StepsXTraj
//	NVAR NPointsXTraj  		= :varsFieldmap:NPointsXTraj
//	NVAR BeamDirection 		= :varsFieldmap:BeamDirection
//
//	variable i, npts, ai, bi, af, bf, initial_angle, final_angle
//	string PosName, TrajName, InitLineName, FinalLineName, PosLineName
//
//	Make/O/N=(NPointsXTraj) CrossingPointX
//	Make/O/N=(NPointsXTraj) CrossingPointYZ
//
//	for (i=0;i<NPointsXTraj;i=i+1)
//		TrajName = "TrajX" + num2str((StartXTraj + i*StepsXTraj)/1000)
//		Wave Traj = $TrajName
//
//		if (BeamDirection == 1)
//			PosName = "TrajY" + num2str((StartXTraj + i*StepsXTraj)/1000)
//		else
//			PosName = "TrajZ" + num2str((StartXTraj + i*StepsXTraj)/1000)		
//		endif
//		Wave Pos = $PosName
//		
//		npts = numpnts(Traj)
//		if (npts < 4)
//			DoAlert 0, "Invalid trajectory number of points."
//			return -1
//		endif
//		
//		ai = (Traj[1] - Traj[0])/(Pos[1] - Pos[0])
//		af = (Traj[npts-1] - Traj[npts-2])/(Pos[npts-1] - Pos[npts-2])
//		
//		initial_angle = atan(ai)
//		final_angle = atan(af) 
//	
//		PosLineName  = TrajName + "_PosRefLine"	
//		InitLineName = TrajName + "_InitRefLine"
//		FinalLineName = TrajName + "_FinalRefLine"
//	
//		Make/O/N=2 $(PosLineName)
//		Make/O/N=2 $(InitLineName)
//		Make/O/N=2 $(FinalLineName)
//	
//		Wave PosLine = $PosLineName
//		Wave InitLine = $InitLineName
//		Wave FinalLine = $FinalLineName
//		
//		PosLine[0] = Pos[0]
//		PosLine[1] = Pos[npts-1]
//		
//		InitLine[0] = Traj[0]
//		InitLine[1] = Traj[0] + tan(initial_angle)*(PosLine[1] - PosLine[0])
//	
//		FinalLine[0] = Traj[npts-1] - tan(final_angle)*(PosLine[1] - PosLine[0])
//		FinalLine[1] = Traj[npts-1]
//		
//		bi = InitLine[0] - ai*PosLine[0]
//		bf = FinalLine[0] - af*PosLine[0]
//		
//		CrossingPointYZ[i] = -(bf - bi)/(af-ai)
//		CrossingPointX[i] = -(bf - bi)/(af-ai)*ai + bi
//	
//	endfor
//
//End
//
//Function ShowDeflections(ctrlName) : ButtonControl
//	String ctrlName
//
//	NVAR BeamDirection = :varsFieldmap:BeamDirection
//	
//	Wave PosXTraj
//	Wave Deflection_X
//	Wave Deflection_Y	
//	Wave Deflection_Z	
//	Wave Deflection_IntTraj_X	
//	Wave Deflection_IntTraj_Y
//	Wave Deflection_IntTraj_Z			
//
//	Display/N=DeflectionX/K=1 Deflection_X vs PosXTraj
//	AppendToGraph/R Deflection_IntTraj_X vs PosXTraj	
//	ModifyGraph rgb(Deflection_IntTraj_X)=(0,9472,39168)	
//	Label bottom "\\Z12Transversal Position X [m]"
//	Label left "\\Z12Deflection Trajectories X [°]"
//	Label right "\\Z12Deflection Integral Trajectories X [°]"	
//	
//	if (BeamDirection == 1)
//		Display/N=DeflectionZ/K=1 Deflection_Z vs PosXTraj
//		AppendToGraph/R Deflection_IntTraj_Z vs PosXTraj	
//		ModifyGraph rgb(Deflection_IntTraj_Z)=(0,9472,39168)			
//		Label bottom "\\Z12Transversal Position X [m]"
//		Label left "\\Z12Deflection Trajectories Z [°]"
//		Label right "\\Z12Deflection Integral Trajectories Z [°]"			
//	else
//		Display/N=DeflectionY/K=1 Deflection_Y vs PosXTraj
//		AppendToGraph/R Deflection_IntTraj_Y vs PosXTraj	
//		ModifyGraph rgb(Deflection_IntTraj_Y)=(0,9472,39168)					
//		Label bottom "\\Z12Transversal Position X [m]"
//		Label left "\\Z12Deflection Trajectories Y [°]"
//		Label right "\\Z12Deflection Integral Trajectories Y [°]"			
//	endif
//
//End
//
//
//Function show_deflections_Table(ctrlName) : ButtonControl
//	String ctrlName
//	
//	NVAR BeamDirection = :varsFieldmap:BeamDirection
//	
//	Wave PosXTraj
//	Wave Deflection_X
//	Wave Deflection_Y	
//	Wave Deflection_Z	
//	
//	if (BeamDirection == 1)
//		Edit/K=1 PosXTraj,Deflection_X,Deflection_Z,Deflection_IntTraj_X,Deflection_IntTraj_Z
//	else
//		Edit/K=1 PosXTraj,Deflection_X,Deflection_Y,Deflection_IntTraj_X,Deflection_IntTraj_Y
//	endif
//
//End
//
//
//Function ShowDynMultipoles(ctrlName) : ButtonControl
//	String ctrlName
//
//	Edit/K=1 Dyn_Mult_Normal_Int, Dyn_Mult_Skew_Int, Dyn_Mult_Normal_Norm, Dyn_Mult_Skew_Norm	
//	
//End
//
//
//Function ShowDynMultipoleProfile(ctrlName) : ButtonControl
//	String ctrlName
//
//	NVAR K = :varsFieldmap:DynMultipoleK
//	
//	wave Dyn_Mult_PosYZ
//	wave Dyn_Mult_Normal
//	wave Dyn_Mult_Skew
//	
//	string name_normal = "Dyn_Mult_Normal_k" + num2str(K)
//	string name_skew = "Dyn_Mult_Skew_k" + num2str(K)
//	
//	string graphlabel
//	if (K == 0)
//		graphlabel = "Dipolar field [T]"
//	elseif (K == 1)
//		graphlabel = "Quadrupolar field [T/m]"
//	elseif (K == 2)
//		graphlabel = "Sextupolar field [T/m²]"
//	elseif (K == 3)
//		graphlabel = "Octupolar field [T/m³]"
//	else
//		graphlabel = num2str(2*(K +1))+ "-polar field"
//	endif
//	
//	Make/D/O/N=(numpnts(Dyn_Mult_PosYZ)) $name_normal
//	Wave Tmp_Normal = $name_normal
//	Tmp_Normal[] = Dyn_Mult_Normal[p][K]
//	Display/N=Dyn_Mult_Normal/K=1 Tmp_Normal vs Dyn_Mult_PosYZ
//	Label bottom "\\Z12Longitudinal Position YZ [m]"
//	Label left  "\\Z12Normal " + graphlabel
//
//	Make/D/O/N=(numpnts(Dyn_Mult_PosYZ)) $name_skew
//	Wave Tmp_Skew = $name_skew
//	Tmp_Skew[] = Dyn_Mult_Skew[p][K]
//	Display/N=Dyn_Mult_Skew/K=1 Tmp_Skew vs Dyn_Mult_PosYZ
//	Label bottom "\\Z12Longitudinal Position YZ [m]"
//	Label left  "\\Z12Skew " + graphlabel
//		
//End
//
//
//Function ShowResidDynMultipoles(ctrlName) : ButtonControl
//	String ctrlName
//
//	Wave Dyn_Mult_Grid
//	Wave Dyn_Mult_Normal_Res
//	Wave Dyn_Mult_Skew_Res
//
//	Display/N=Dyn_Mult_Normal_Res/K=1 Dyn_Mult_Normal_Res vs Dyn_Mult_Grid
//	Label bottom "\\Z12Transversal displacement from trajectory [m]"
//	Label left "\\Z12Normalized Residual Dynamic \rNormal Multipoles"
//
//	Display/N=Dyn_Mult_Skew_Res/K=1 Dyn_Mult_Skew_Res vs Dyn_Mult_Grid
//	Label bottom "\\Z12Transversal displacement from trajectory [m]"
//	Label left "\\Z12Normalized Residual Dynamic \rSkew Multipoles"
//
//End
//
//
//Function ShowResidDynMultipoles_Table(ctrlName) : ButtonControl
//	String ctrlName
//	Edit/K=1 Dyn_Mult_Grid,Dyn_Mult_Normal_Res,Dyn_Mult_Skew_Res
//End
//
//
//

//Window ID_Results() : Panel
//	PauseUpdate; Silent 1
//	
//	if (DataFolderExists("root:varsCAMTO")==0)
//		DoAlert 0, "CAMTO variables not found."
//		return 
//	endif
//
//	CloseWindow("ID_Results")
//	
//	NewPanel/K=1/W=(380,260,704,475)
//	SetDrawLayer UserBack
//	SetDrawEnv fillpat= 0
//	DrawRect 3,3,320,132
//	SetDrawEnv fillpat= 0
//	DrawRect 3,132,320,178	
//	SetDrawEnv fillpat= 0
//	DrawRect 3,178,320,210	
//							
//	TitleBox    id_label,pos={80,10},size={100,20},fsize=14,fstyle=1,frame=0,title="Insertion Devices Results"
//	ValDisplay  first_int,pos={10,40},size={300,20},title="First Integral (x=0mm) [G.cm]:    "
//	ValDisplay  second_int,pos={10,70},size={300,20},title="Second Integral (x=0mm) [kG.cm²]:"
//	ValDisplay  phase_error,pos={10,100},size={300,20},title="RMS Phase Error [°]:  "
//	
//	Button update,pos={11,140},size={300,30},fsize=15,fstyle=1,proc=UpdateIDResultsProc,title="Update"
//	
//	SetVariable fieldmapdir,pos={20,185},size={290,18},title="Field Map Directory: "
//	SetVariable fieldmapdir,noedit=1,value=root:varsCAMTO:FIELDMAP_FOLDER
//	
//	UpdateFieldmapFolders()
//	UpdateIDResultsPanel()
//	
//EndMacro
//
//
//Function UpdateIDResultsPanel()
//
//	string panel_name
//	panel_name = WinList("ID_Results",";","")	
//	if (stringmatch(panel_name, "ID_Results;")==0)
//		return -1
//	endif
//	
//	SVAR df = root:varsCAMTO:FIELDMAP_FOLDER
//		
//	if (strlen(df) > 0)			
//		ValDisplay first_int, win=ID_Results, value=#("root:"+ df + ":varsFieldmap:IDFirstIntegral" )
//		ValDisplay second_int,win=ID_Results,value=#("root:"+ df + ":varsFieldmap:IDSecondIntegral" )
//		ValDisplay phase_error, win=ID_Results, value=#("root:"+ df + ":varsFieldmap:IDPhaseError" )
//		Button update,win=ID_Results,disable=0
//
//		if (WaveExists(C_PosX))
//			NVAR IDFirstIntegral = root:$(df):varsFieldmap:IDFirstIntegral
//			NVAR IDSecondIntegral = root:$(df):varsFieldmap:IDSecondIntegral
//			NVAR IDPhaseError = root:$(df):varsFieldmap:IDPhaseError
//			
//			IntegralsCalculation()
//		
//			Wave C_PosX		
//			Wave IntBy_X
//			Wave Int2By_X
//
//			FindValue/T=1e-10/V=0 C_PosX
//			if (V_value == -1)
//				DoAlert 0, "Position x = 0 not found."
//				return -1
//			endif
//			
//			IDFirstIntegral = IntBy_X[V_value]*1e6
//			IDSecondIntegral = Int2By_X[V_Value]*1e5
//
//		endif
//	
//	else
//		ValDisplay first_int, win=ID_Results, disable=2
//		ValDisplay second_int,win=ID_Results, disable=2
//		ValDisplay phase_error, win=ID_Results, disable=2	
//		Button update,win=ID_Results,disable=2	
//	endif
//	
//End
//
//
//Function UpdateIDResultsProc(ctrlName) : ButtonControl
//	String ctrlName
//	UpdateIDResultsPanel()
//End
//
//
//Window Compare_Results() : Panel
//	PauseUpdate; Silent 1		
//
//	if (DataFolderExists("root:varsCAMTO")==0)
//		DoAlert 0, "CAMTO variables not found."
//		return 
//	endif
//
//	CloseWindow("Compare_Results")
//
//	NewPanel/K=1/W=(1010,60,1335,710)
//	SetDrawLayer UserBack
//	SetDrawEnv fillpat= 0
//	DrawRect 3,4,320,55
//	SetDrawEnv fillpat= 0
//	DrawRect 3,55,320,90
//	SetDrawEnv fillpat= 0
//	DrawRect 3,90,320,173
//	SetDrawEnv fillpat= 0
//	DrawRect 3,173,320,300
//	SetDrawEnv fillpat= 0
//	DrawRect 3,300,320,565
//	SetDrawEnv fillpat= 0
//	DrawRect 3,565,320,645
//	
//	TitleBox TitleA,pos={10,12},size={70,18},frame=0,fstyle=1,title="Fieldmap A: "
//	PopupMenu fieldmapFolderA,pos={80,10},size={120,18},bodyWidth=115,mode=0,proc=SelectFieldmapA,title=" "
//	CheckBox ReferenceA,pos={210,12},size={100,15},title="Use as reference",value=1,mode=1,proc=SelectReference
//	
//	TitleBox TitleB,pos={10,32},size={70,18},frame=0,fstyle=1,title="Fieldmap B: "	
//	PopupMenu fieldmapFolderB,pos={80,30},size={120,18},bodyWidth=115,mode=0,proc=SelectFieldmapB,title=" "
//	CheckBox ReferenceB,pos={210,32},size={100,15},title="Use as reference",value=0,mode=1,proc=SelectReference		
//		
//	Button field_Xline,pos={10,61},size={200,24},proc=Compare_Field_In_Line,fstyle=1,title="Show field in X ="
//	SetVariable PosXFieldLine,pos={220,63},size={80,18},title="[mm]:", value= root:varsCAMTO:LinePosX
//	
//	SetVariable StartXProfile,pos={16,97},size={134,18},title="Start X [mm]:",value= root:varsCAMTO:ProfileStartX
//	SetVariable EndXProfile,pos={16,122},size={134,18},title="End X  [mm]:",value= root:varsCAMTO:ProfileEndX
//	SetVariable PosYZProfile,pos={16,147},size={134,18},title="Pos YZ [mm]:",value= root:varsCAMTO:ProfilePosYZ			
//	Button field_profile,pos={160,97},size={150,70},fstyle=1,proc=Compare_Field_Profile,title="Show Field Profile"
//		
//	TitleBox multipoles_title,pos={110,180},size={110,18},fsize=15,fstyle=1,frame=0,title="Field Multipoles"
//	Button show_multipoles,pos={11,210},size={300,24},fstyle=1,proc=Compare_Multipoles,title="Show Multipoles Tables"
//	Button show_multipoleprofile,pos={11,240},size={240,24},fstyle=1,proc=Compare_Multipole_Profile,title="Show Multipole Profile: K = "
//	SetVariable mnumber,pos={260,243},size={50,20},title=" ",value= root:varsCAMTO:MultipoleK
//	Button show_resfield,pos={11,270},size={300,24},fstyle=1,proc=Show_Residual_Multipoles,title="Show Residual Field"
//	
//	TitleBox trajectory_title,pos={100,305},size={110,18},fsize=15,fstyle=1,frame=0,title="Particle Trajectory"
//	
//	TitleBox    trajA_title,pos={40,330},size={80,18},frame=0,fsize=14,title="Fieldmap A"
//	ValDisplay  trajstartx_A,pos={10,360},size={140,18},title="Start X [mm]:    "
//	ValDisplay  trajstartangx_A,pos={10,390},size={140,18},title="Angle XY(Z) [°]:"
//	ValDisplay  trajstartyz_A,pos={10,420},size={140,18},title="Start YZ [mm]:  "
//
//	TitleBox    trajB_title,pos={200,330},size={80,18},frame=0,fsize=14,title="Fieldmap B"
//	ValDisplay  trajstartx_B,pos={170,360},size={140,18},title="Start X [mm]:    "
//	ValDisplay  trajstartangx_B,pos={170,390},size={140,18},title="Angle XY(Z) [°]:"
//	ValDisplay  trajstartyz_B,pos={170,420},size={140,18},title="Start YZ [mm]:  "
//	
//	Button show_trajectories,pos={11,445},size={160,24},fstyle=1,proc=Compare_Trajectories,title="Show Trajectory"
//	CheckBox reference_lines,pos={180,450},size={120,24},title="Add Reference Lines"
//		
//	Button show_dynmultipoles,pos={11,475},size={300,24},fstyle=1,proc=Compare_DynMultipoles,title="Show Dynamic Multipoles Tables"
//	Button show_dynmultipoleprofile,pos={11,505},size={240,24},fstyle=1,proc=Compare_DynMultipole_Profile,title="Show Dynamic Multipole Profile: K = "
//	SetVariable dynmnumber,pos={260,508},size={50,20},title=" ",value= root:varsCAMTO:DynMultipoleK
//	Button show_dynresfield,pos={11,535},size={300,24},fstyle=1,proc=Show_Residual_Dyn_Multipoles,title="Show Residual Field"
//	
//	TitleBox rep_title,pos={110,570},size={110,18},fsize=15,fstyle=1,frame=0,title="Magnet Report"
//	CheckBox rep_dynmult,pos={16,595},size={250,15},title="\tUse Dynamic Multipoles"
//	CheckBox rep_multtwo,pos={266,595},size={30,15},title="\tx 2"
//	Button rep_button,pos={11,615},size={300,25},fsize=15,fstyle=1,proc=Magnet_Report,title="Show Magnet Report"
//	
//	UpdateCompareResultsPanel()
//	
//EndMacro
//
//
//Function UpdateCompareResultsPanel()
//
//	string panel_name
//	panel_name = WinList("Compare_Results",";","")	
//	if (stringmatch(panel_name, "Compare_Results;")==0)
//		return -1
//	endif
//
//	UpdateFieldmapFolders()
//	UpdateFieldmapNames()
//
//	NVAR fieldmapCount = root:varsCAMTO:FIELDMAP_COUNT
//
//	SVAR dfA = root:varsCAMTO:FieldmapA
//	SVAR dfB = root:varsCAMTO:FieldmapB
//	
//	if (fieldmapCount != 0)
//		string FieldmapList = getFieldmapDirs()
//		
//		if (DataFolderExists("root:Nominal"))
//			FieldmapList = "Nominal;" + FieldmapList
//		endif
//		
//		PopupMenu fieldmapFolderA,win=Compare_Results,disable=0,value= #("\"" + FieldmapList + "\"")
//		PopupMenu fieldmapFolderB,win=Compare_Results,disable=0,value= #("\"" + FieldmapList + "\"")
//		
//		variable modeA, modeB
//		modeA = WhichListItem(dfA, FieldmapList) 
//		modeB = WhichListItem(dfB, FieldmapList) 
//		
//		if (modeA != -1)
//			PopupMenu fieldmapFolderA,win=Compare_Results,mode=modeA+1
//		endif
//		
//		if (modeB !=-1)
//			PopupMenu fieldmapFolderB,win=Compare_Results,mode=modeB+1
//		endif
//		
//	else
//		PopupMenu fieldmapFolderA,win=Compare_Results,disable=2
//		PopupMenu fieldmapFolderB,win=Compare_Results,disable=2
//	endif
//	
//	if (fieldmapCount != 0 && strlen(dfA) > 0 && cmpstr(dfA, "_none_")!=0 && strlen(dfB) > 0 && cmpstr(dfB, "_none_")!=0)
//	
//		NVAR ProfileStartX  = root:varsCAMTO:ProfileStartX
//		NVAR ProfileEndX    = root:varsCAMTO:ProfileEndX
//		NVAR ProfileStartYZ = root:varsCAMTO:ProfilePosYZ
//		
//		NVAR/Z AddReferenceLines  = root:varsCAMTO:AddReferenceLines
//		NVAR CheckDynMultipoles = root:varsCAMTO:CheckDynMultipoles
//		NVAR CheckMultTwo       = root:varsCAMTO:CheckMultTwo
//	
//		NVAR StartX_A  = root:$(dfA):varsFieldmap:StartX
//		NVAR EndX_A    = root:$(dfA):varsFieldmap:EndX
//		NVAR StepsX_A  = root:$(dfA):varsFieldmap:StepsX
//		NVAR StartYZ_A = root:$(dfA):varsFieldmap:StartYZ
//		NVAR EndYZ_A   = root:$(dfA):varsFieldmap:EndYZ
//		NVAR StepsYZ_A = root:$(dfA):varsFieldmap:StepsYZ
//	
//		NVAR StartX_B  = root:$(dfB):varsFieldmap:StartX
//		NVAR EndX_B    = root:$(dfB):varsFieldmap:EndX
//		NVAR StepsX_B  = root:$(dfB):varsFieldmap:StepsX
//		NVAR StartYZ_B = root:$(dfB):varsFieldmap:StartYZ
//		NVAR EndYZ_B   = root:$(dfB):varsFieldmap:EndYZ
//		NVAR StepsYZ_B = root:$(dfB):varsFieldmap:StepsYZ
//	
//		NVAR FittingOrder_A     = root:$(dfA):varsFieldmap:FittingOrder
//		NVAR FittingOrderTraj_A = root:$(dfA):varsFieldmap:FittingOrderTraj	
//		NVAR FittingOrder_B     = root:$(dfB):varsFieldmap:FittingOrder
//		NVAR FittingOrderTraj_B = root:$(dfB):varsFieldmap:FittingOrderTraj
//
//		
//		variable StartX, EndX, StepsX
//		variable StartYZ, EndYZ, StepsYZ
//		variable FittingOrder, FittingOrderTraj
//	
//		if ( numtype(Max(StartX_A, StartX_B))!= 0 )
//			if (numtype(StartX_B) != 0)
//				StartX  = StartX_A; EndX = EndX_A; StepsX = StepsX_A
//				StartYZ = StartYZ_A; EndYZ = EndYZ_A; StepsYZ = StepsYZ_A
//			else
//				StartX  = StartX_B; EndX = EndX_B; StepsX = StepsX_B
//				StartYZ = StartYZ_B; EndYZ = EndYZ_B; StepsYZ = StepsYZ_B	
//			endif
//		else
//			StartX  = Max(StartX_A, StartX_B)
//			EndX    = Min(EndX_A, EndX_B)
//			StepsX  = Min(StepsX_A, StepsX_B)
//			StartYZ = Max(StartYZ_A, StartYZ_B)
//			EndYZ   = Min(EndYZ_A, EndYZ_B)
//			StepsYZ = Min(StepsYZ_A, StepsYZ_B)
//		endif
//				
//		SetVariable StartXProfile,win=Compare_Results, limits={StartX,  EndX,  StepsX}
//		SetVariable EndXProfile,  win=Compare_Results, limits={StartX,  EndX,  StepsX}
//		SetVariable PosYZProfile, win=Compare_Results, limits={StartYZ, EndYZ, StepsYZ} 
//		
//		CheckBox ReferenceA,win=Compare_Results, disable=0
//		CheckBox ReferenceB,win=Compare_Results, disable=0
//				
//		ProfileStartX  = StartX
//		ProfileEndX    = EndX	 
//		ProfileStartYZ = 0	 
//		
//		ValDisplay trajstartx_A,win=Compare_Results,value= #("root:"+ dfA + ":varsFieldmap:StartXTraj" )
//		ValDisplay trajstartangx_A,win=Compare_Results,value= #("root:"+ dfA + ":varsFieldmap:EntranceAngle" )
//		ValDisplay trajstartyz_A,win=Compare_Results,value= #("root:"+ dfA + ":varsFieldmap:StartYZTraj" )
//
//		ValDisplay trajstartx_B,win=Compare_Results,value= #("root:"+ dfB + ":varsFieldmap:StartXTraj" )
//		ValDisplay trajstartangx_B,win=Compare_Results,value= #("root:"+ dfB + ":varsFieldmap:EntranceAngle" )
//		ValDisplay trajstartyz_B,win=Compare_Results,value= #("root:"+ dfB + ":varsFieldmap:StartYZTraj" )
//		
//		if (NVAR_EXists(AddReferenceLines)==0)
//			variable/G :varsFieldmap:AddReferenceLines = 0
//		endif
//		
//		CheckBox reference_lines,win=Compare_Results,variable=AddReferenceLines, value=AddReferenceLines
//		CheckBox rep_dynmult,win=Compare_Results,variable=CheckDynMultipoles, value=CheckDynMultipoles
//		CheckBox rep_multtwo,win=Compare_Results,variable=CheckMultTwo, value=CheckMultTwo
//		
//		if (numtype(Min(FittingOrder_A, FittingOrder_B))!= 0 )
//			if (numtype(FittingOrder_B) != 0)
//				FittingOrderTraj = FittingOrderTraj_A
//				FittingOrder = FittingOrder_A
//			else
//				FittingOrderTraj = FittingOrderTraj_B
//				FittingOrder = FittingOrder_B	
//			endif
//		else
//			FittingOrderTraj = Min(FittingOrderTraj_A, FittingOrderTraj_B)
//			FittingOrder = Min(FittingOrder_A, FittingOrder_B)
//		endif
//		SetVariable mnumber,win=Compare_Results,limits={0,(FittingOrder-1),1}
//		SetVariable dynmnumber,win=Compare_Results,limits={0,(FittingOrderTraj-1),1}
//		
//	else
//		
//		CheckBox ReferenceA,win=Compare_Results, disable=2
//		CheckBox ReferenceB,win=Compare_Results, disable=2
//			
//	endif	
//	
//	UpdateFieldControls()
//	UpdateMultipolesControls()
//	UpdateTrajectoryControls()
//	UpdateDynMultipolesControls()
//	UpdateMagnetReportControls()
//
//End
//
//
//Function UpdateFieldControls()
//
//	SVAR dfA = root:varsCAMTO:FieldmapA
//	SVAR dfB = root:varsCAMTO:FieldmapB
//
//	Wave/Z PosA = root:$(dfA):C_PosX
//	Wave/Z PosB = root:$(dfB):C_PosX
//	
//	variable disable
//	if (WaveExists(PosA) || WaveExists(PosB))
//		if (strlen(dfA) > 0 && cmpstr(dfA, "_none_")!=0 && strlen(dfB) > 0 && cmpstr(dfB, "_none_")!=0)
//			disable = 0 
//		else
//			disable = 2
//		endif
//	else
//		disable = 2
//	endif
//
//	Button field_Xline, win=Compare_Results, disable=disable
//	SetVariable PosXFieldLine, win=Compare_Results, disable=disable
//
//	SetVariable StartXProfile, win=Compare_Results, disable=disable
//	SetVariable EndXProfile, win=Compare_Results, disable=disable
//	SetVariable PosYZProfile, win=Compare_Results, disable=disable
//	Button field_profile, win=Compare_Results, disable=disable
//
//End
//
//
//Function UpdateMultipolesControls()
//
//	SVAR dfA = root:varsCAMTO:FieldmapA
//	SVAR dfB = root:varsCAMTO:FieldmapB
//
//	Wave/Z MultA = root:$(dfA):Mult_Grid
//	Wave/Z MultB = root:$(dfB):Mult_Grid
//		
//	variable disable
//	if (WaveExists(MultA) || WaveExists(MultB))
//		if (strlen(dfA) > 0 && cmpstr(dfA, "_none_")!=0 && strlen(dfB) > 0 && cmpstr(dfB, "_none_")!=0)
//			disable = 0 
//		else
//			disable = 2
//		endif
//	else
//		disable = 2
//	endif
//
//	TitleBox multipoles_title,win=Compare_Results, disable=disable
//	Button show_multipoles,win=Compare_Results, disable=disable
//	Button show_multipoleprofile,win=Compare_Results, disable=disable
//	SetVariable mnumber,win=Compare_Results, disable=disable
//	Button show_resfield,win=Compare_Results, disable=disable
//End
//
//
//Function UpdateTrajectoryControls()
//
//	SVAR dfA = root:varsCAMTO:FieldmapA
//	SVAR dfB = root:varsCAMTO:FieldmapB
//
//	NVAR/Z StartXTraj_A = root:$(dfA):varsFieldmap:StartXTraj	
//	NVAR/Z StartXTraj_B = root:$(dfB):varsFieldmap:StartXTraj	
//	Wave/Z TrajA = root:$(dfA):$("TrajX" + num2str(StartXTraj_A/1000))
//	Wave/Z TrajB = root:$(dfB):$("TrajX" + num2str(StartXTraj_B/1000))
//		
//	variable disable
//	if (WaveExists(TrajA) || WaveExists(TrajB))
//		if (strlen(dfA) > 0 && cmpstr(dfA, "_none_")!=0 && strlen(dfB) > 0 && cmpstr(dfB, "_none_")!=0)
//			disable = 0 
//		else
//			disable = 2
//		endif
//	else
//		disable = 2
//	endif
//
//	TitleBox trajectory_title,win=Compare_Results, disable=disable
//	
//	TitleBox trajA_title,win=Compare_Results, disable=disable
//	ValDisplay trajstartx_A,win=Compare_Results, disable=disable
//	ValDisplay trajstartangx_A,win=Compare_Results, disable=disable
//	ValDisplay trajstartyz_A,win=Compare_Results, disable=disable
//
//	TitleBox trajB_title,win=Compare_Results, disable=disable
//	ValDisplay trajstartx_B,win=Compare_Results, disable=disable
//	ValDisplay trajstartangx_B,win=Compare_Results, disable=disable
//	ValDisplay trajstartyz_B,win=Compare_Results, disable=disable
//	
//	Button show_trajectories,win=Compare_Results, disable=disable
//	CheckBox reference_lines,win=Compare_Results, disable=disable
//	
//End
//
//
//Function UpdateDynMultipolesControls()
//
//	SVAR dfA = root:varsCAMTO:FieldmapA
//	SVAR dfB = root:varsCAMTO:FieldmapB
//
//	Wave/Z DynMultA = root:$(dfA):Dyn_Mult_Grid
//	Wave/Z DynMultB = root:$(dfB):Dyn_Mult_Grid
//		
//	variable disable
//	if (WaveExists(DynMultA) || WaveExists(DynMultB))
//		if (strlen(dfA) > 0 && cmpstr(dfA, "_none_")!=0 && strlen(dfB) > 0 && cmpstr(dfB, "_none_")!=0)
//			disable = 0 
//		else
//			disable = 2
//		endif
//	else
//		disable = 2
//	endif
//
//	Button show_dynmultipoles,win=Compare_Results, disable=disable
//	Button show_dynmultipoleprofile,win=Compare_Results, disable=disable
//	SetVariable dynmnumber,win=Compare_Results, disable=disable
//	Button show_dynresfield,win=Compare_Results, disable=disable
//	
//End
//
//
//Function UpdateMagnetReportControls()
//
//	SVAR dfA = root:varsCAMTO:FieldmapA
//	SVAR dfB = root:varsCAMTO:FieldmapB
//
//	NVAR DynMultipoles = root:varsCAMTO:CheckDynMultipoles
//
//	Wave/Z MultA = root:$(dfA):Mult_Grid
//	Wave/Z MultB = root:$(dfB):Mult_Grid
//	Wave/Z DynMultA = root:$(dfA):Dyn_Mult_Grid
//	Wave/Z DynMultB = root:$(dfB):Dyn_Mult_Grid
//		
//	variable disable
//	if (WaveExists(MultA) || WaveExists(MultB) || WaveExists(DynMultA) || WaveExists(DynMultB))
//		
//		if (strlen(dfA) > 0 && cmpstr(dfA, "_none_")!=0 && strlen(dfB) > 0 && cmpstr(dfB, "_none_")!=0)
//			disable = 0 
//		
//			if (WaveExists(MultA) == 0 && WaveExists(MultB) == 0)
//				DynMultipoles = 1
//			elseif (WaveExists(DynMultA) == 0 && WaveExists(DynMultB) == 0)
//				DynMultipoles = 0
//			endif
//		
//		else
//			disable = 2
//		endif
//				
//	else
//		disable = 2
//	endif
//	
//	TitleBox rep_title,win=Compare_Results, disable=disable
//	CheckBox rep_dynmult,win=Compare_Results, disable=disable
//	CheckBox rep_multtwo,win=Compare_Results, disable=disable
//	Button rep_button,win=Compare_Results, disable=disable
//
//End
//
//
//Function SelectFieldmapA(ctrlName,popNum,popStr) : PopupMenuControl
//	String ctrlName
//	Variable popNum
//	String popStr
//	
//	SVAR FieldmapA= root:varsCAMTO:FieldmapA
//	NVAR ReferenceFieldmap = root:varsCAMTO:ReferenceFieldmap
//	
//	FieldmapA = popStr
//	PopupMenu fieldmapFolderA, win=Compare_Results, mode=popNum
//	UpdateCompareResultsPanel()
//
//	if (cmpstr(FieldmapA, "Nominal")==0 )
//		ReferenceFieldmap = 1
//		CheckBox ReferenceA,win=Compare_Results,value=1
//		CheckBox ReferenceB,win=Compare_Results,value=0
//	endif
//
//End
//
//
//Function SelectFieldmapB(ctrlName,popNum,popStr) : PopupMenuControl
//	String ctrlName
//	Variable popNum
//	String popStr
//	
//	SVAR FieldmapB = root:varsCAMTO:FieldmapB
//	NVAR ReferenceFieldmap = root:varsCAMTO:ReferenceFieldmap
//	
//	FieldmapB = popStr
//	PopupMenu fieldmapFolderB, win=Compare_Results, mode=popNum
//	UpdateCompareResultsPanel()
//
//	if (cmpstr(FieldmapB, "Nominal")==0)
//		ReferenceFieldmap = 2
//		CheckBox ReferenceA,win=Compare_Results,value=0
//		CheckBox ReferenceB,win=Compare_Results,value=1
//	endif
//
//End
//
//
//Function SelectReference(cb) : CheckBoxControl
//	STRUCT WMCheckboxAction& cb
//	
//	SVAR FieldmapA = root:varsCAMTO:FieldmapA
//	SVAR FieldmapB = root:varsCAMTO:FieldmapB
//	NVAR ReferenceFieldmap = root:varsCAMTO:ReferenceFieldmap
//	
//	strswitch (cb.ctrlName)
//		case "ReferenceA":
//			CheckBox ReferenceB,win=Compare_Results,value=0
//			ReferenceFieldmap = 1 
//			break
//		case "ReferenceB":
//			CheckBox ReferenceA,win=Compare_Results, value=0
//			ReferenceFieldmap = 2
//			break
//	endswitch
//	
//	if (cmpstr(FieldmapA, "Nominal")==0 )
//		ReferenceFieldmap = 1
//		CheckBox ReferenceA,win=Compare_Results,value=1
//		CheckBox ReferenceB,win=Compare_Results,value=0
//	endif
//	
//	if (cmpstr(FieldmapB, "Nominal")==0)
//		ReferenceFieldmap = 2
//		CheckBox ReferenceA,win=Compare_Results,value=0
//		CheckBox ReferenceB,win=Compare_Results,value=1
//	endif
//	
//	return 0
//End
//
//
//Function UpdateFieldmapNames()
//
//	DFREF   df = GetDataFolderDFR()
//	SVAR    FieldmapA = root:varsCAMTO:FieldmapA
//	SVAR    FieldmapB = root:varsCAMTO:FieldmapB
//
//	SetDataFolder root:
//	string datafolders = DataFolderDir(1)
//	SetDataFolder df
//	
//	SplitString/E=":.*;" datafolders
//	S_value = S_value[1,strlen(S_value)-2]
//	
//	if (FindListItem(FieldmapA, S_value, ",") == -1 )
//		FieldmapA = ""
//	endif
//	
//	if (FindListItem(FieldmapB, S_value, ",") == -1 )
//		FieldmapB = ""
//	endif
//End
//
//
//Function Compare_Field_In_Line(ctrlName) : ButtonControl
//	String ctrlName
//	Compare_Field_In_Line_()
//End
//
//
//Function Compare_Field_In_Line_([PosX, FieldComponent])
//	variable PosX
//	string FieldComponent
//
//	DFREF df = GetDataFolderDFR()
//	SVAR dfA = root:varsCAMTO:FieldmapA
//	SVAR dfB = root:varsCAMTO:FieldmapB
//	
//	variable fieldmapA = 1	
//	if (cmpstr(dfA, "Nominal")==0)
//		fieldmapA = 0
//	endif
//	
//	variable fieldmapB = 1	
//	if (cmpstr(dfB, "Nominal")==0)
//		fieldmapB = 0
//	endif
//	
//	if (fieldmapA == 0 && fieldmapB == 0)
//		return -1
//	endif
//		
//	variable i
//	
//	NVAR LinePosX = root:varsCAMTO:LinePosX	
//
//	if (ParamIsDefault(PosX))
//		PosX = LinePosX
//	endif
//		
//	if (ParamIsDefault(FieldComponent))
//		FieldComponent = ""
//	endif	
//
//	if (fieldmapA)
//		
//		SetDataFolder root:wavesCAMTO:
//	
//		NVAR StartYZ_A = root:$(dfA):varsFieldmap:StartYZ
//		NVAR EndYZ_A   = root:$(dfA):varsFieldmap:EndYZ
//		NVAR StepsYZ_A = root:$(dfA):varsFieldmap:StepsYZ
//		
//		NVAR FieldX_A = root:$(dfA):varsFieldmap:FieldX
//		NVAR FieldY_A = root:$(dfA):varsFieldmap:FieldY
//		NVAR FieldZ_A = root:$(dfA):varsFieldmap:FieldZ	
//		
//		variable NpointsYZ_A = ((EndYZ_A - StartYZ_A) / StepsYZ_A) +1
//		
//		Make/D/O/N=(NpointsYZ_A) LinePosYZ_A
//		Make/D/O/N=(NpointsYZ_A) LineFieldX_A
//		Make/D/O/N=(NpointsYZ_A) LineFieldY_A
//		Make/D/O/N=(NpointsYZ_A) LineFieldZ_A
//		
//		SetDataFolder root:$(dfA)
//		for (i=0;i<NpointsYZ_A;i=i+1)
//			LinePosYZ_A[i] = ((StartYZ_A +i*StepsYZ_A)/1000)
//			
//			Campo_Espaco((PosX/1000), LinePosYZ_A[i])
//			
//			LineFieldX_A[i] = FieldX_A
//			LineFieldY_A[i] = FieldY_A
//			LineFieldZ_A[i] = FieldZ_A			
//		endfor
//					
//	endif
//	
//	if (fieldmapB)
//		
//		SetDataFolder root:wavesCAMTO:
//	
//		NVAR StartYZ_B = root:$(dfB):varsFieldmap:StartYZ
//		NVAR EndYZ_B   = root:$(dfB):varsFieldmap:EndYZ
//		NVAR StepsYZ_B = root:$(dfB):varsFieldmap:StepsYZ	
//	
//		NVAR FieldX_B = root:$(dfB):varsFieldmap:FieldX
//		NVAR FieldY_B = root:$(dfB):varsFieldmap:FieldY
//		NVAR FieldZ_B = root:$(dfB):varsFieldmap:FieldZ
//		
//		variable NpointsYZ_B = ((EndYZ_B - StartYZ_B) / StepsYZ_B) +1
//		
//		Make/D/O/N=(NpointsYZ_B) LinePosYZ_B
//		Make/D/O/N=(NpointsYZ_B) LineFieldX_B
//		Make/D/O/N=(NpointsYZ_B) LineFieldY_B
//		Make/D/O/N=(NpointsYZ_B) LineFieldZ_B
//		
//		SetDataFolder root:$(dfB)
//		for (i=0;i<NpointsYZ_B;i=i+1)
//			LinePosYZ_B[i] = ((StartYZ_B +i*StepsYZ_B)/1000)
//			
//			Campo_Espaco((PosX/1000), LinePosYZ_B[i])
//			
//			LineFieldX_B[i] = FieldX_B
//			LineFieldY_B[i] = FieldY_B
//			LineFieldZ_B[i] = FieldZ_B				
//		endfor
//		
//	endif
//		
//	SetDataFolder df
//		
//	String strpos = "PosX = "+	num2str(PosX/1000) + " m"
//	
//	CloseWindow("CompareFieldInLine_Bx")
//	CloseWindow("CompareFieldInLine_By")
//	CloseWindow("CompareFieldInLine_Bz")
//	
//	if (cmpstr(FieldComponent, "Bx") == 0 || strlen(FieldComponent) == 0)
//		
//		if (fieldmapA && fieldmapB)
//			Display/N=CompareFieldInLine_Bx/K=1 LineFieldX_A vs LinePosYZ_A
//			AppendToGraph/W=CompareFieldInLine_Bx/C=(0,0,65535) LineFieldX_B vs LinePosYZ_B
//			Legend/W=CompareFieldInLine_Bx "\s(#0) "+ dfA +  "\r\s(#1) " + dfB 
//		elseif (fieldmapA)
//			Display/N=CompareFieldInLine_Bx/K=1 LineFieldX_A vs LinePosYZ_A
//			Legend/W=CompareFieldInLine_Bx "\s(#0) "+ dfA
//		elseif (fieldmapB)
//			Display/N=CompareFieldInLine_Bx/K=1 LineFieldX_B vs LinePosYZ_B
//			Legend/W=CompareFieldInLine_Bx "\s(#0) "+ dfB
//		endif
//		
//		Label bottom "\\Z12Longitudinal Position YZ [m]"
//		Label left "\\Z12Field Bx [T] (" + strpos + ")"
//	endif
//	
//	if (cmpstr(FieldComponent, "By") == 0 || strlen(FieldComponent) == 0)
//		
//		if (fieldmapA && fieldmapB)
//			Display/N=CompareFieldInLine_By/K=1 LineFieldY_A vs LinePosYZ_A
//			AppendToGraph/W=CompareFieldInLine_By/C=(0,0,65535) LineFieldY_B vs LinePosYZ_B
//			Legend/W=CompareFieldInLine_By "\s(#0) "+ dfA + "\r\s(#1) " + dfB 
//		elseif (fieldmapA)
//			Display/N=CompareFieldInLine_By/K=1 LineFieldY_A vs LinePosYZ_A
//			Legend/W=CompareFieldInLine_By "\s(#0) "+ dfA
//		elseif (fieldmapB)
//			Display/N=CompareFieldInLine_By/K=1 LineFieldY_B vs LinePosYZ_B
//			Legend/W=CompareFieldInLine_By "\s(#0) "+ dfB
//		endif
//		
//		Label bottom "\\Z12Longitudinal Position YZ [m]"
//		Label left "\\Z12Field By [T] (" + strpos + ")"
//	endif
//
//	if (cmpstr(FieldComponent, "Bz") == 0 || strlen(FieldComponent) == 0)
//		
//		if (fieldmapA && fieldmapB)	
//			Display/N=CompareFieldInLine_Bz/K=1 LineFieldZ_A vs LinePosYZ_A
//			AppendToGraph/W=CompareFieldInLine_Bz/C=(0,0,65535) LineFieldZ_B vs LinePosYZ_B
//			Legend/W=CompareFieldInLine_Bz "\s(#0) "+ dfA + "\r\s(#1) " + dfB 
//		elseif (fieldmapA)
//			Display/N=CompareFieldInLine_Bz/K=1 LineFieldZ_A vs LinePosYZ_A
//			Legend/W=CompareFieldInLine_Bz "\s(#0) "+ dfA
//		elseif (fieldmapB)
//			Display/N=CompareFieldInLine_Bz/K=1 LineFieldZ_B vs LinePosYZ_B
//			Legend/W=CompareFieldInLine_Bz "\s(#0) "+ dfB
//		endif
//		
//		Label bottom "\\Z12Longitudinal Position YZ [m]"
//		Label left "\\Z12Field Bz [T] (" + strpos + ")"
//	endif
//		
//End
//
//
//Function Compare_Field_Profile(ctrlName) : ButtonControl
//	String ctrlName
//	Compare_Field_Profile_()
//End
//
//
//Function Compare_Field_Profile_([PosYZ, FieldComponent])
//	variable PosYZ
//	string FieldComponent
//	
//	NVAR ProfileStartX = root:varsCAMTO:ProfileStartX
//	NVAR ProfileEndX   = root:varsCAMTO:ProfileEndX	
//	NVAR ProfilePosYZ  = root:varsCAMTO:ProfilePosYZ	
//
//	DFREF df = GetDataFolderDFR()
//	SVAR dfA = root:varsCAMTO:FieldmapA
//	SVAR dfB = root:varsCAMTO:FieldmapB
//
//	variable fieldmapA = 1	
//	if (cmpstr(dfA, "Nominal")==0)
//		fieldmapA = 0
//	endif
//	
//	variable fieldmapB = 1	
//	if (cmpstr(dfB, "Nominal")==0)
//		fieldmapB = 0
//	endif
//	
//	if (fieldmapA == 0 && fieldmapB == 0)
//		return -1
//	endif
//	
//	SetDataFolder root:wavesCAMTO:
//
//	if (ParamIsDefault(PosYZ))
//		PosYZ = ProfilePosYZ
//	endif 	
//	
//	if (ParamIsDefault(FieldComponent))
//		FieldComponent = ""
//	endif
//
//	variable i
//	
//	if (fieldmapA)
//		NVAR StepsX_A = root:$(dfA):varsFieldmap:StepsX
//		NVAR FieldX_A = root:$(dfA):varsFieldmap:FieldX
//		NVAR FieldY_A = root:$(dfA):varsFieldmap:FieldY
//		NVAR FieldZ_A = root:$(dfA):varsFieldmap:FieldZ
//		
//		variable NpointsX_A = ((ProfileEndX - ProfileStartX) / StepsX_A) +1
//		
//		Make/D/O/N=(NpointsX_A) ProfilePosX_A
//		Make/D/O/N=(NpointsX_A) ProfileFieldX_A
//		Make/D/O/N=(NpointsX_A) ProfileFieldY_A
//		Make/D/O/N=(NpointsX_A) ProfileFieldZ_A
//		
//		SetDataFolder root:$(dfA)
//		for (i=0;i<NpointsX_A;i=i+1)
//			ProfilePosX_A[i] = ((ProfileStartX +i*StepsX_A)/1000)
//			
//			Campo_Espaco(ProfilePosX_A[i],(PosYZ/1000))
//			
//			ProfileFieldX_A[i] = FieldX_A
//			ProfileFieldY_A[i] = FieldY_A
//			ProfileFieldZ_A[i] = FieldZ_A			
//		endfor
//		
//		
//	endif
//
//	if (fieldmapB)
//		NVAR StepsX_B = root:$(dfB):varsFieldmap:StepsX	
//		NVAR FieldX_B = root:$(dfB):varsFieldmap:FieldX
//		NVAR FieldY_B = root:$(dfB):varsFieldmap:FieldY
//		NVAR FieldZ_B = root:$(dfB):varsFieldmap:FieldZ
//
//		variable NpointsX_B = ((ProfileEndX - ProfileStartX) / StepsX_B) +1
//	
//		Make/D/O/N=(NpointsX_B) ProfilePosX_B
//		Make/D/O/N=(NpointsX_B) ProfileFieldX_B
//		Make/D/O/N=(NpointsX_B) ProfileFieldY_B
//		Make/D/O/N=(NpointsX_B) ProfileFieldZ_B
//	
//		SetDataFolder root:$(dfB)
//		for (i=0;i<NpointsX_B;i=i+1)
//			ProfilePosX_B[i] = ((ProfileStartX +i*StepsX_B)/1000)
//			
//			Campo_Espaco(ProfilePosX_B[i],(PosYZ/1000))
//			
//			ProfileFieldX_B[i] = FieldX_B
//			ProfileFieldY_B[i] = FieldY_B
//			ProfileFieldZ_B[i] = FieldZ_B				
//		endfor
//	
//	endif
//			
//	SetDataFolder df
//		
//	String strpos = "PosYZ = "+	num2str(PosYZ/1000) + " m"
//
//	CloseWindow("CompareFieldProfile_Bx")
//	CloseWindow("CompareFieldProfile_By")
//	CloseWindow("CompareFieldProfile_Bz")
//	
//	if (cmpstr(FieldComponent, "Bx") == 0 || strlen(FieldComponent) == 0)
//		
//		if (fieldmapA && fieldmapB)	
//			Display/N=CompareFieldProfile_Bx/K=1 ProfileFieldX_A vs ProfilePosX_A
//			AppendToGraph/W=CompareFieldProfile_Bx/C=(0,0,65535) ProfileFieldX_B vs ProfilePosX_B
//			Legend/W=CompareFieldProfile_Bx "\s(#0) "+ dfA + "\r\s(#1) " + dfB
//		elseif (fieldmapA)
//			Display/N=CompareFieldProfile_Bx/K=1 ProfileFieldX_A vs ProfilePosX_A
//			Legend/W=CompareFieldProfile_Bx "\s(#0) "+ dfA
//		elseif (fieldmapB)
//			Display/N=CompareFieldProfile_Bx/K=1 ProfileFieldX_B vs ProfilePosX_B
//			Legend/W=CompareFieldProfile_Bx "\s(#0) "+ dfB
//		endif	
//			
//		Label bottom "\\Z12Transversal Position X [m]"
//		Label left "\\Z12Field Bx [T] (" + strpos + ")"
//	endif
//	
//	if (cmpstr(FieldComponent, "By") == 0 || strlen(FieldComponent) == 0)
//	
//		if (fieldmapA && fieldmapB)	
//			Display/N=CompareFieldProfile_By/K=1 ProfileFieldY_A vs ProfilePosX_A
//			AppendToGraph/W=CompareFieldProfile_By/C=(0,0,65535) ProfileFieldY_B vs ProfilePosX_B
//			Legend/W=CompareFieldProfile_By "\s(#0) "+ dfA + "\r\s(#1) " + dfB 
//		elseif (fieldmapA)
//			Display/N=CompareFieldProfile_By/K=1 ProfileFieldY_A vs ProfilePosX_A
//			Legend/W=CompareFieldProfile_By "\s(#0) "+ dfA
//		elseif (fieldmapB)
//			Display/N=CompareFieldProfile_By/K=1 ProfileFieldY_B vs ProfilePosX_B
//			Legend/W=CompareFieldProfile_By "\s(#0) "+ dfB
//		endif
//		
//		Label bottom "\\Z12Transversal Position X [m]"
//		Label left "\\Z12Field By [T] (" + strpos + ")"
//	endif
//
//	if (cmpstr(FieldComponent, "Bz") == 0 || strlen(FieldComponent) == 0)
//	
//		if (fieldmapA && fieldmapB)	
//			Display/N=CompareFieldProfile_Bz/K=1 ProfileFieldZ_A vs ProfilePosX_A
//			AppendToGraph/W=CompareFieldProfile_Bz/C=(0,0,65535) ProfileFieldZ_B vs ProfilePosX_B
//			Legend/W=CompareFieldProfile_Bz "\s(#0) "+ dfA + "\r\s(#1) " + dfB
//		elseif (fieldmapA)
//			Display/N=CompareFieldProfile_Bz/K=1 ProfileFieldZ_A vs ProfilePosX_A
//			Legend/W=CompareFieldProfile_Bz "\s(#0) "+ dfA
//		elseif (fieldmapB)
//			Display/N=CompareFieldProfile_Bz/K=1 ProfileFieldZ_B vs ProfilePosX_B
//			Legend/W=CompareFieldProfile_Bz "\s(#0) "+ dfB
//		endif
//		
//		Label bottom "\\Z12Transversal Position X [m]"
//		Label left "\\Z12Field Bz [T] (" + strpos + ")"
//	endif
//		
//		
//End
//
//
//Function Compare_Multipoles(ctrlName) : ButtonControl
//	String ctrlName
//	Compare_Multipoles_(0)	
//End
//
//
//Function Compare_DynMultipoles(ctrlName) : ButtonControl
//	String ctrlName
//	Compare_Multipoles_(1)
//End
//
//
//Function Compare_Multipoles_(Dynamic)
//	variable Dynamic
//	
//	SVAR dfA = root:varsCAMTO:FieldmapA
//	SVAR dfB = root:varsCAMTO:FieldmapB
//
//	variable fieldmapA = 1	
//	if (cmpstr(dfA, "Nominal")==0)
//		fieldmapA = 0
//	endif
//	
//	variable fieldmapB = 1	
//	if (cmpstr(dfB, "Nominal")==0)
//		fieldmapB = 0
//	endif
//	
//	if (fieldmapA == 0 && fieldmapB == 0)
//		return -1
//	endif
//
//	string mult
//	string str
//	
//	if (Dynamic)
//		mult = "Dyn_Mult"
//	else
//		mult = "Mult"
//	endif
//
//	if (fieldmapA)
//		str = "root:" + dfA + ":" + mult 
//		Edit/N=$(dfA)/K=1 $(str +"_Normal_Int"), $(str +"_Skew_Int"), $(str +"_Normal_Norm"), $(str +"_Skew_Norm")
//		if (Dynamic)
//			DoWindow/T $(dfA),"Dynamic Field Multipoles - " + dfA
//		else
//			DoWindow/T $(dfA),"Field Multipoles - " + dfA
//		endif
//	endif
//
//	if (fieldmapB)
//		str = "root:" + dfb + ":" + mult 
//		Edit/N=$(dfb)/K=1 $(str +"_Normal_Int"), $(str +"_Skew_Int"), $(str +"_Normal_Norm"), $(str +"_Skew_Norm")
//		if (Dynamic)
//			DoWindow/T $(dfB),"Dynamic Field Multipoles - " + dfB
//		else
//			DoWindow/T $(dfB),"Field Multipoles - " + dfB
//		endif
//	endif
//
//End
//
//
//Function Compare_Multipole_Profile(ctrlName) : ButtonControl
//	String ctrlName
//	Compare_Multipole_Profile_(0)
//End
//
//
//Function Compare_DynMultipole_Profile(ctrlName) : ButtonControl
//	String ctrlName
//	Compare_Multipole_Profile_(1)
//End
//
//
//Function Compare_Multipole_Profile_(Dynamic, [K, FieldComponent])
//	variable Dynamic
//	variable K
//	string FieldComponent
//	
//	DFREF df = GetDataFolderDFR()
//	SVAR dfA = root:varsCAMTO:FieldmapA
//	SVAR dfB = root:varsCAMTO:FieldmapB
//	
//	SetDataFolder root:wavesCAMTO
//	
//	variable fieldmapA = 1	
//	if (cmpstr(dfA, "Nominal")==0)
//		fieldmapA = 0
//	endif
//	
//	variable fieldmapB = 1	
//	if (cmpstr(dfB, "Nominal")==0)
//		fieldmapB = 0
//	endif
//	
//	if (fieldmapA == 0 && fieldmapB == 0)
//		return -1
//	endif
//		
//	NVAR MultipoleK		 = root:varsCAMTO:MultipoleK
//	NVAR DynMultipoleK	 = root:varsCAMTO:DynMultipoleK
//		
//	if (ParamIsDefault(K))
//		if (Dynamic)
//			K = DynMultipoleK
//		else
//			K = MultipoleK
//		endif
//	endif
//
//	if (ParamIsDefault(FieldComponent))
//		FieldComponent = ""
//	endif
//	
//	string PanelName
//	string graphlabel
//
//	string mult_normal
//	string mult_skew
//	string pos
//	string dyn_graphlabel
//	string nwindow
//	string swindow
//
//	if (Dynamic)
//		mult_normal = "Dyn_Mult_Normal"
//		mult_skew = "Dyn_Mult_Skew"
//		pos = "Dyn_Mult_PosYZ"
//		dyn_graphlabel = "\rover trajectory"
//		nwindow = "CompareDynMultNormal"
//		swindow = "CompareDynMultSkew"
//	else
//		mult_normal = "Mult_Normal"
//		mult_skew = "Mult_Skew"
//		pos = "C_PosYZ"
//		dyn_graphlabel = ""
//		nwindow = "CompareMultNormal"
//		swindow = "CompareMultSkew"
//	endif
//	
//	if (K == 0)
//		graphlabel = "Dipolar field" + dyn_graphlabel + " [T]"
//	elseif (K == 1)
//		graphlabel = "Quadrupolar field" + dyn_graphlabel + " [T/m]"
//	elseif (K == 2)
//		graphlabel = "Sextupolar field" + dyn_graphlabel + " [T/m²]"
//	elseif (K == 3)
//		graphlabel = "Octupolar field" + dyn_graphlabel + " [T/m³]"
//	else
//		graphlabel = num2str(2*(K +1))+ "-polar field" + dyn_graphlabel
//	endif
//	
//	SetDataFolder root:wavesCAMTO:
//	
//	CloseWindow(nwindow)
//	CloseWindow(swindow)
//	
//	if (cmpstr(FieldComponent, "Normal") == 0 || strlen(FieldComponent) == 0)		
//	
//		if (fieldmapA && fieldmapB)
//			Display/N=$(nwindow)/K=1 root:$(dfA):$(mult_normal)[][K] vs root:$(dfA):$(pos)
//			AppendToGraph/W=$(nwindow)/C=(0,0,65535) root:$(dfB):$(mult_normal)[][K] vs root:$(dfB):$(pos)
//			Legend/W=$(nwindow) "\s(#0) "+ dfA + " \r\s(#1) " + dfB
//			
//		elseif (fieldmapA)
//			Display/N=$(nwindow)/K=1 root:$(dfA):$(mult_normal)[][K] vs root:$(dfA):$(pos)
//			Legend/W=$(nwindow) "\s(#0) "+ dfA
//		
//		elseif (fieldmapB)
//			Display/N=$(nwindow)/K=1 root:$(dfB):$(mult_normal)[][K] vs root:$(dfB):$(pos)
//			Legend/W=$(nwindow) "\s(#0) "+ dfB		
//			
//		endif
//			
//		Label bottom "\\Z12Longitudinal Position YZ [m]"
//		Label left  "\\Z12Normal " + graphlabel
//	endif
//
//	if (cmpstr(FieldComponent, "Skew") == 0 || strlen(FieldComponent) == 0)
//
//		if (fieldmapA && fieldmapB)			
//			Display/N=$(swindow)/K=1 root:$(dfA):$(mult_skew)[][K] vs root:$(dfA):$(pos)
//			AppendToGraph/W=$(swindow)/C=(0,0,65535) root:$(dfB):$(mult_skew)[][K] vs root:$(dfB):$(pos)
//			Legend/W=$(swindow) "\s(#0) "+ dfA + " \r\s(#1) " + dfB	
//			
//		elseif (fieldmapA)
//			Display/N=$(swindow)/K=1 root:$(dfA):$(mult_skew)[][K] vs root:$(dfA):$(pos)
//			Legend/W=$(swindow) "\s(#0) "+ dfA
//		
//		elseif (fieldmapB)
//			Display/N=$(swindow)/K=1 root:$(dfB):$(mult_skew)[][K] vs root:$(dfB):$(pos)
//			Legend/W=$(swindow) "\s(#0) "+ dfB
//				
//		endif
//		
//		Label bottom "\\Z12Longitudinal Position YZ [m]"
//		Label left  "\\Z12Skew " + graphlabel
//	endif
//
//	SetDataFolder df
//	
//End
//
//
//Function Compare_Trajectories(ctrlName) : ButtonControl
//	String ctrlName
//
//	DFREF df = GetDataFolderDFR()
//	SVAR dfA = root:varsCAMTO:FieldmapA
//	SVAR dfB = root:varsCAMTO:FieldmapB
//	NVAR/Z AddReferenceLines = root:varsCAMTO:AddReferenceLines
//
//	if (NVAR_EXists(AddReferenceLines)==0)
//		variable/G root:varsCAMTO:AddReferenceLines = 0
//	endif
//
//	variable i
//	variable xval_A
//	variable xval_B
//	string TrajStart
//	string PanelName
//	string AxisY
//	string AxisX
//	string PosLineName
//	string InitLineName
//	string FinalLineName
//	string tagtext
//	string yzstr
//	
//	variable fieldmapA = 1	
//	if (cmpstr(dfA, "Nominal")==0)
//		fieldmapA = 0
//	endif
//	
//	variable fieldmapB = 1	
//	if (cmpstr(dfB, "Nominal")==0)
//		fieldmapB = 0
//	endif
//	
//	if (fieldmapA == 0 && fieldmapB == 0)
//		return -1
//	endif
//
//	if (fieldmapA)
//		NVAR BeamDirection_A = root:$(dfA):varsFieldmap:BeamDirection	
//		NVAR StartXTraj_A    = root:$(dfA):varsFieldmap:StartXTraj	
//		
//		SetDataFolder root:$(dfA)
//		TrajStart = num2str(StartXTraj_A/1000)
//		
//		// Fieldmap A - Trajectory X 
//		AxisY = "TrajX" + TrajStart
//		Wave TmpY = $AxisY
//
//		if (BeamDirection_A == 1)
//			AxisX = "TrajY" + TrajStart
//		else
//			AxisX = "TrajZ" + TrajStart
//		endif
//		Wave TmpX = $AxisX
//		
//		CloseWindow("CompareTrajectoriesX")
//		Display/N=CompareTrajectoriesX/K=1 TmpY/TN='TrajX_A' vs TmpX
//		Label bottom "\\Z12Longitudinal Position [m]"			
//		Label left "\\Z12Horizontal Trajectory [m]"	
//	
//		if (AddReferenceLines == 1)
//			CalcRefLinesCrossingPoint()
//			Wave CrossingPointX
//			Wave CrossingPointYZ
//			
//			if (numpnts(CrossingPointX) == 1)
//				PosLineName = AxisY + "_PosRefLine"
//				InitLineName = AxisY + "_InitRefLine"
//				FinalLineName = AxisY + "_FinalRefLine"
//				
//				Wave/Z PosLine = $(PosLineName)
//				Wave/Z InitLine = $(InitLineName)
//				Wave/Z FinalLine = $(FinalLineName)
//				
//				if (WaveExists(PosLine) == 1 && WaveExists(InitLine) == 1 && WaveExists(FinalLine) == 1)
//					Appendtograph/W=CompareTrajectoriesX/C=(30000, 30000, 30000) InitLine/TN=$(InitLineName+"_A") vs PosLine
//					Appendtograph/W=CompareTrajectoriesX/C=(30000, 30000, 30000) FinalLine/TN=$(FinalLineName+"_A") vs PosLine
//					ModifyGraph/W=CompareTrajectoriesX lstyle($(InitLineName+"_A"))=3
//					ModifyGraph/W=CompareTrajectoriesX lstyle($(FinalLineName+"_A"))=3 
//				endif			
//				
//				Appendtograph/W=CompareTrajectoriesX/C=(30000, 30000, 30000) CrossingPointX/TN='CrossingPoint_A' vs CrossingPointYZ
//				ModifyGraph/W=CompareTrajectoriesX mode('CrossingPoint_A')=3, marker('CrossingPoint_A')=19, msize('CrossingPoint_A')=2
//				
//				xval_A = pnt2x(CrossingPointYZ, 0)
//				if (BeamDirection_A == 1)
//					yzstr = "Y"
//				else
//					yzstr = "Z"
//				endif
//				sprintf tagtext, "%s:\nX = %.3f mm\n%s = %.3f mm", dfA, CrossingPointX[i]*1000, yzstr, CrossingPointYZ[i]*1000
//				Tag/X=20/W=CompareTrajectoriesX/F=2/L=2 'CrossingPoint_A', xval_A, tagtext
//			endif
//			
//		endif
//	
//		// Fieldmap A - Trajectory YZ
//		AxisY = "TrajX" + TrajStart
//		Wave TmpY = $AxisY
//	
//		if (BeamDirection_A == 1)
//			AxisY = "TrajZ" + TrajStart
//			AxisX = "TrajY" + TrajStart
//		else
//			AxisY = "TrajY" + TrajStart		
//			AxisX = "TrajZ" + TrajStart			
//		endif
//		Wave TmpY = $AxisY
//		Wave TmpX = $AxisX
//		
//		CloseWindow("CompareTrajectoriesYZ")
//		Display/N=CompareTrajectoriesYZ/K=1 TmpY/TN='TrajYZ_A' vs TmpX
//		Label bottom "\\Z12Longitudinal Position [m]"			
//		Label left "\\Z12Vertical Trajectory [m]"
//				
//	endif
//	
//	if (fieldmapB)
//		NVAR BeamDirection_B = root:$(dfB):varsFieldmap:BeamDirection	
//		NVAR StartXTraj_B    = root:$(dfB):varsFieldmap:StartXTraj	
//		
//		SetDataFolder root:$(dfB)
//		TrajStart = num2str(StartXTraj_B/1000)
//				
//		// Fieldmap B - Trajectory X 
//		AxisY = "TrajX" + TrajStart
//		Wave TmpY = $AxisY
//	
//		if (BeamDirection_B == 1)
//			AxisX = "TrajY" + TrajStart
//		else
//			AxisX = "TrajZ" + TrajStart
//		endif
//		Wave TmpX = $AxisX
//		
//		PanelName = WinList("CompareTrajectoriesX",";","")	
//		if (stringmatch(PanelName, "CompareTrajectoriesX;"))
//			AppendToGraph/W=CompareTrajectoriesX/C=(0,0,65535) TmpY/TN='TrajX_B' vs TmpX	
//		else
//			Display/N=CompareTrajectoriesX/K=1 TmpY/TN='TrajX_B' vs TmpX
//			Label bottom "\\Z12Longitudinal Position [m]"			
//			Label left "\\Z12Horizontal Trajectory [m]"	
//		endif
//
//		if (AddReferenceLines == 1)
//			CalcRefLinesCrossingPoint()
//			Wave CrossingPointX
//			Wave CrossingPointYZ
//			
//			if (numpnts(CrossingPointX) == 1)		
//				PosLineName = AxisY + "_PosRefLine"
//				InitLineName = AxisY + "_InitRefLine"
//				FinalLineName = AxisY + "_FinalRefLine"
//				
//				Wave/Z PosLine = $(PosLineName)
//				Wave/Z InitLine = $(InitLineName)
//				Wave/Z FinalLine = $(FinalLineName)
//				
//				if (WaveExists(PosLine) == 1 && WaveExists(InitLine) == 1 && WaveExists(FinalLine) == 1)
//					Appendtograph/W=CompareTrajectoriesX/C=(30000, 30000, 30000) InitLine/TN=$(InitLineName+"_B") vs PosLine
//					Appendtograph/W=CompareTrajectoriesX/C=(30000, 30000, 30000) FinalLine/TN=$(FinalLineName+"_B") vs PosLine
//					ModifyGraph/W=CompareTrajectoriesX lstyle($(InitLineName+"_B"))=3
//					ModifyGraph/W=CompareTrajectoriesX lstyle($(FinalLineName+"_B"))=3
//				endif
//				
//				Appendtograph/W=CompareTrajectoriesX/C=(30000, 30000, 30000) CrossingPointX/TN='CrossingPoint_B' vs CrossingPointYZ
//				ModifyGraph/W=CompareTrajectoriesX mode('CrossingPoint_B')=3, marker('CrossingPoint_B')=19, msize('CrossingPoint_B')=2
//				
//				xval_B = pnt2x(CrossingPointYZ, 0)
//				if (BeamDirection_B == 1)
//					yzstr = "Y"
//				else
//					yzstr = "Z"
//				endif
//				sprintf tagtext, "%s:\nX = %.3f mm\n%s = %.3f mm", dfB, CrossingPointX[i]*1000, yzstr, CrossingPointYZ[i]*1000
//				Tag/X=20/W=CompareTrajectoriesX/F=2/L=2 'CrossingPoint_B', xval_B, tagtext
//			endif
//			
//		endif
//		
//		// Fieldmap B - Trajectory YZ
//		AxisY = "TrajX" + TrajStart
//		Wave TmpY = $AxisY
//	
//		if (BeamDirection_B == 1)
//			AxisY = "TrajZ" + TrajStart
//			AxisX = "TrajY" + TrajStart
//		else
//			AxisY = "TrajY" + TrajStart		
//			AxisX = "TrajZ" + TrajStart			
//		endif
//		Wave TmpY = $AxisY
//		Wave TmpX = $AxisX
//		
//		PanelName = WinList("CompareTrajectoriesYZ",";","")	
//		if (stringmatch(PanelName, "CompareTrajectoriesYZ;"))
//			AppendToGraph/W=CompareTrajectoriesYZ/C=(0,0,65535) TmpY/TN='TrajYZ_B' vs TmpX
//		else
//			Display/N=CompareTrajectoriesYZ/K=1 TmpY/TN='TrajYZ_B' vs TmpX
//			Label bottom "\\Z12Longitudinal Position [m]"			
//			Label left "\\Z12Vertical Trajectory [m]"
//		endif
//		
//	endif
//	
//	if (fieldmapA && fieldmapB)
//		Legend/W=CompareTrajectoriesX "\s('TrajX_A') "+ dfA + " \r\s('TrajX_B') " + dfB
//		Legend/W=CompareTrajectoriesYZ "\s('TrajYZ_A') "+ dfA + " \r\s('TrajYZ_B') " + dfB
//	elseif (fieldmapA)	
//		Legend/W=CompareTrajectoriesX "\s('TrajX_A') " + dfA
//		Legend/W=CompareTrajectoriesYZ "\s('TrajYZ_A') "+ dfA
//	elseif (fieldmapB)
//		Legend/W=CompareTrajectoriesX "\s('TrajX_B') " + dfB
//		Legend/W=CompareTrajectoriesYZ "\s('TrajYZ_B') "+ dfB	
//	endif
//	
//	SetDataFolder df
//
//End
//
//
//Function Show_Residual_Multipoles(ctrlName) : ButtonControl
//	String ctrlName
//	Show_Residual_Field(0)
//End
//
//
//Function Show_Residual_Dyn_Multipoles(ctrlName) : ButtonControl
//	String ctrlName
//	Show_Residual_Field(1)
//End
//
//
//Function Show_Residual_Field(Dynamic)
//	variable Dynamic
//
//	DFREF df = GetDataFolderDFR()
//	SVAR dfA = root:varsCAMTO:FieldmapA
//	SVAR dfB = root:varsCAMTO:FieldmapB
//	
//	variable fieldmapA = 1	
//	if (cmpstr(dfA, "Nominal")==0)
//		fieldmapA = 0
//	endif
//	
//	variable fieldmapB = 1	
//	if (cmpstr(dfB, "Nominal")==0)
//		fieldmapB = 0
//	endif
//	
//	if (fieldmapA ==0 && fieldmapB == 0)
//		return -1
//	endif
//
//  	string PanelName
//  	string GraphLegend
//	string mult
//	string pos
//	
//	SetDataFolder root:wavesCAMTO:
//
//	Wave/Z trans_pos_residue
//	Wave/Z normal_max_residue
//	Wave/Z normal_min_residue
//	Wave/Z normal_sys_residue
//	Wave/Z skew_max_residue
//	Wave/Z skew_min_residue
//	Wave/Z skew_sys_residue
//
//	if (Dynamic == 1)
//		mult = "Dyn_Mult"
//		pos = "Dyn_Mult_Grid"
//	else
//		mult = "Mult"
//		pos = "Mult_Grid"
//	endif
//	
//	if (fieldmapA)
//		NVAR BeamDirection_A  = root:$(dfA):varsFieldmap:BeamDirection
//		Wave ResMult_Pos_A    = $"root:" + dfA + ":" + pos
//		Wave ResMult_Normal_A = $"root:" + dfA + ":" + mult + "_Normal_Res"
//		Wave ResMult_Skew_A   = $"root:" + dfA + ":" + mult + "_Skew_Res"		
//	endif
//
//	if (fieldmapB)
//		NVAR BeamDirection_B  = root:$(dfB):varsFieldmap:BeamDirection
//		Wave ResMult_Pos_B    = $"root:" + dfB + ":" + pos
//		Wave ResMult_Normal_B = $"root:" + dfB + ":" + mult + "_Normal_Res"
//		Wave ResMult_Skew_B   = $"root:" + dfB + ":" + mult + "_Skew_Res"		
//	endif
//		
//	CloseWindow("NormalResidualField")
//	
//	if (fieldmapA && fieldmapB)
//		Display/N=NormalResidualField/K=1 ResMult_Normal_A vs ResMult_Pos_A
//		AppendToGraph/W=NormalResidualField/C=(0,0,0) ResMult_Normal_B vs ResMult_Pos_B
//		GraphLegend = "\s(#0) "+ dfA + " \r\s(#1) " + dfB
//	elseif (fieldmapA)
//		Display/N=NormalResidualField/K=1 ResMult_Normal_A vs ResMult_Pos_A
//		GraphLegend = "\s(#0) "+ dfA 	
//	elseif (fieldmapB)
//		Display/N=NormalResidualField/K=1 ResMult_Normal_B vs ResMult_Pos_B
//		GraphLegend =  "\s(#0) "+ dfB	
//	endif
//	
//	if (WaveExists(trans_pos_residue))
//		AppendToGraph/W=NormalResidualField/C=(0,0,65535) normal_min_residue/TN='spec_min' vs trans_pos_residue
//		AppendToGraph/W=NormalResidualField/C=(0,35000,0) normal_max_residue/TN='spec_max' vs trans_pos_residue
//		ModifyGraph/W=NormalResidualField/Z lStyle('spec_min') = 3, lStyle('spec_max') = 3
//		GraphLegend = GraphLegend + "\r\s(spec_min) Inferior Limit \r\s(spec_max) Upper Limit" 
//	endif
//	
//	Label left  "\\Z12Normal Residual Integrated Field"
//	Label bottom "\\Z12Transversal Position [m]"	
//	Legend/A=MT/W=NormalResidualField GraphLegend
//	
//	CloseWindow("SkewResidualField")
//	
//	if (fieldmapA && fieldmapB)
//		Display/N=SkewResidualField/K=1   ResMult_Skew_A vs ResMult_Pos_A
//		AppendToGraph/W=SkewResidualField/C=(0,0,0)   ResMult_Skew_B vs ResMult_Pos_B
//		GraphLegend = "\s(#0) "+ dfA + " \r\s(#1) " + dfB
//	elseif (fieldmapA)
//		Display/N=SkewResidualField/K=1   ResMult_Skew_A vs ResMult_Pos_A
//		GraphLegend = "\s(#0) "+ dfA 
//	elseif (fieldmapB)
//		Display/N=SkewResidualField/K=1   ResMult_Skew_B vs ResMult_Pos_B
//		GraphLegend = "\s(#0) "+ dfB 
//	endif
//
//	if (WaveExists(trans_pos_residue))
//		AppendToGraph/W=SkewResidualField/C=(0,0,65535) skew_min_residue/TN='spec_min' vs trans_pos_residue
//		AppendToGraph/W=SkewResidualField/C=(0,35000,0) skew_max_residue/TN='spec_max' vs trans_pos_residue
//		ModifyGraph/W=SkewResidualField/Z lStyle('spec_min') = 3, lStyle('spec_max') = 3
//		GraphLegend = GraphLegend + "\r\s(spec_min) Inferior Limit \r\s(spec_max) Upper Limit"	
//	endif
//
//	Label left  "\\Z12Skew Residual Integrated Field" 		
//	Label bottom "\\Z12Transversal Position [m]"
//	Legend/A=MT/W=SkewResidualField GraphLegend
//
//	SetDataFolder df
//
//End
//
//
//Function Magnet_Report(ctrlName) : ButtonControl
//	String ctrlName
//	
//	NVAR DynMultipoles = root:varsCAMTO:CheckDynMultipoles
//
//	DFREF df = GetDataFolderDFR()
//	
//	SetDataFolder root:wavesCAMTO:
//	
//	Create_Report()
//	
//	if (DynMultipoles)
//		Add_Deflections()	
//	endif
//	
//	Add_Field_Profile()	
//	
//	Add_Multipoles_Info(DynMultipoles)
//	
//	Add_Multipoles_Error_Table()
//	Add_Residual_Field_Profile(DynMultipoles)
//	
//	Add_Parameters(DynMultipoles)
//	
//	SetDataFolder df
//	
//End
//
//
//Function Create_Report()
//
//	SVAR dfA = root:varsCAMTO:FieldmapA
//	SVAR dfB = root:varsCAMTO:FieldmapB
//	NVAR ReferenceFieldmap = root:varsCAMTO:ReferenceFieldmap
//	
//	string mag
//	if (ReferenceFieldmap == 1)
//		mag = dfB
//	else
//		mag = dfA
//	endif
//	string Title = mag	
//
//	DoWindow/F Report
//	if (V_flag != 0)
//		Killwindow/Z Report
//	endif
//	
//	NewNotebook/W=(100,30,570,700)/F=1/N=Report as "Report"
//	Notebook Report showRuler=0, userKillMode=1, writeProtect=0
//	Notebook Report selection={startOfFile, endOfFile}, text="\r", selection={startOfFile, startOfFile} 
//
//	Notebook Report newRuler=TitleRuler, justification=1, rulerDefaults={"Calibri", 16, 1, (0, 0, 0)}	
//
//	Notebook Report newRuler=TableTitle,tabs={20}, justification=0, rulerDefaults={"Calibri", 14, 1, (0, 0, 0)}
//	
//	Notebook Report newRuler=Table0		 ,tabs={20, 70, 120, 170, 220, 270, 320, 370},justification=0, rulerDefaults={"Calibri", 12, 0, (0, 0, 0)}
//	Notebook Report newRuler=TableHeader0,tabs={20, 70, 120, 170, 220, 270, 320, 370},justification=0, rulerDefaults={"Calibri", 12, 1, (0, 0, 0)}
//	
//	Notebook Report newRuler=Table1      ,tabs={20, 95, 170, 245, 320, 395},justification=0, rulerDefaults={"Calibri", 12, 0, (0, 0, 0)}
//	Notebook Report newRuler=TableHeader1,tabs={20, 95, 170, 245, 320, 395},justification=0, rulerDefaults={"Calibri", 12, 1, (0, 0, 0)}
//	
//	Notebook Report newRuler=Table2      ,tabs={20, 80, 180, 280, 380},justification=0, rulerDefaults={"Calibri", 12, 0, (0, 0, 0)}
//	Notebook Report newRuler=TableHeader2,tabs={20, 80, 180, 280, 380},justification=0, rulerDefaults={"Calibri", 12, 1, (0, 0, 0)}
//	
//	Notebook Report newRuler=Table3      ,tabs={20, 170, 320},justification=0, rulerDefaults={"Calibri", 12, 0, (0, 0, 0)}
//	Notebook Report newRuler=TableHeader3,tabs={20, 170, 320},justification=0, rulerDefaults={"Calibri", 12, 1, (0, 0, 0)}
//	
//	Notebook Report newRuler=Table4      ,tabs={20, 180, 260, 340},justification=0, rulerDefaults={"Calibri", 12, 0, (0, 0, 0)}
//	Notebook Report newRuler=TableHeader4,tabs={20, 180, 260, 340},justification=0, rulerDefaults={"Calibri", 12, 1, (0, 0, 0)}
//
//	Notebook Report newRuler=Table5      ,tabs={20, 80, 200, 340},justification=0, rulerDefaults={"Calibri", 12, 0, (0, 0, 0)}
//	Notebook Report newRuler=TableHeader5,tabs={20, 80, 200, 340},justification=0, rulerDefaults={"Calibri", 12, 1, (0, 0, 0)}
//
//	Notebook Report newRuler=Table6      ,tabs={20, 180},justification=0, rulerDefaults={"Calibri", 12, 0, (0, 0, 0)}
//	Notebook Report newRuler=TableHeader6,tabs={20, 180},justification=0, rulerDefaults={"Calibri", 12, 1, (0, 0, 0)}
//
//	Notebook Report ruler=TitleRuler, text=Title + "\r\r"
//	
//End
//
//
//Function Add_Deflections()
//
//	SVAR dfA = root:varsCAMTO:FieldmapA
//	SVAR dfB = root:varsCAMTO:FieldmapB
//	NVAR ReferenceFieldmap = root:varsCAMTO:ReferenceFieldmap
//	NVAR CheckMultTwo = root:varsCAMTO:CheckMultTwo
//	
//	if (ReferenceFieldmap == 1)
//		Wave Deflection_IntTraj_X  = $("root:" + dfB + ":Deflection_IntTraj_X")
//		Wave Deflection_IntTraj_Y  = $("root:" + dfB + ":Deflection_IntTraj_Y")
//	else
//		Wave Deflection_IntTraj_X  = $("root:" + dfA + ":Deflection_IntTraj_X")
//		Wave Deflection_IntTraj_Y  = $("root:" + dfB + ":Deflection_IntTraj_Y")
//	endif
//	
//	variable Deflection_Angle_X
//	if (WaveExists(Deflection_IntTraj_X))
//		Deflection_Angle_X = Deflection_IntTraj_X[0]
//	else
//		Deflection_Angle_X = NaN
//	endif
//
//	if (Abs(Deflection_Angle_X) < 1e-10)
//		Deflection_Angle_X = 0
//	endif
//
//	variable Deflection_Angle_Y
//	if (WaveExists(Deflection_IntTraj_Y))
//		Deflection_Angle_Y = Deflection_IntTraj_Y[0]
//	else
//		Deflection_Angle_Y = NaN
//	endif
//	
//	if (Abs(Deflection_Angle_Y) < 1e-10)
//		Deflection_Angle_Y = 0
//	endif
//	
//	if (CheckMultTwo)
//		Deflection_Angle_X = Deflection_Angle_X*2
//		Deflection_Angle_Y = Deflection_Angle_Y*2
//	endif
//	
//	Make/O/T TableWave = {num2str(Deflection_Angle_X), num2str(Deflection_Angle_Y)}
//	Make/O/T RowWave = {"Horizontal Deflection Angle [°]", "Vertical Deflection Angle     [°]"}
//		
//	Add_Table(TableWave, RowWave=RowWave, Title="Deflection Angles:", Spacing=4)
//			
//	Killwaves/Z TableWave, RowWave
//		 
//End
//
//
//Function Add_Field_Profile()
//	
//	Wave NormalMultipoles = root:wavesCAMTO:NormalMultipoles
//	Wave SkewMultipoles   = root:wavesCAMTO:SkewMultipoles
//	
//	string FieldComponent
//	
//	Notebook Report ruler=TableTitle, text="\tField Profile:\r\r"
//	
//	if (DimSize(NormalMultipoles, 0))	
//		FieldComponent = "By"
//		
//		Compare_Field_In_Line_(FieldComponent=FieldComponent)
//		Notebook Report, text="\t",scaling={110,110},picture={$("CompareFieldInLine_" + FieldComponent),0, 1, 8},text="\r"
//		Killwindow/Z $("CompareFieldInLine_" + FieldComponent)
//
//		Compare_Field_Profile_(FieldComponent=FieldComponent)
//		Notebook Report, text="\t",scaling={110,110},picture={$("CompareFieldProfile_" + FieldComponent),0, 1, 8},text="\r"
//		Killwindow/Z $("CompareFieldProfile_" + FieldComponent)
//	endif
//
//	if (DimSize(SkewMultipoles, 0))
//		FieldComponent = "Bx"
//		
//		Compare_Field_In_Line_(FieldComponent=FieldComponent)
//		Notebook Report, text="\t",scaling={110,110},picture={$("CompareFieldInLine_" + FieldComponent),0, 1, 8},text="\r"
//		Killwindow/Z $("CompareFieldInLine_" + FieldComponent)
//
//		Compare_Field_Profile_(FieldComponent=FieldComponent)
//		Notebook Report, text="\t",scaling={110,110},picture={$("CompareFieldProfile_" + FieldComponent),0, 1, 8},text="\r"
//		Killwindow/Z $("CompareFieldProfile_" + FieldComponent)
//	endif
//	
//	Notebook Report specialChar={1, 0, ""}
//End
//
//Function Add_Multipoles_Info(Dynamic)
//	variable Dynamic
//	
//	Wave NormalMultipoles = root:wavesCAMTO:NormalMultipoles
//	Wave SkewMultipoles   = root:wavesCAMTO:SkewMultipoles
//	
//	variable i
//	
//	if (DimSize(NormalMultipoles, 0))
//		Add_Multipoles_Table(Dynamic, "Normal")
//	
//		for (i=0; i<DimSize(NormalMultipoles,0); i=i+1)
//			Add_Multipole_Profile(NormalMultipoles[i], "Normal", Dynamic)
//		endfor
//		
//	endif
//		
//	if (DimSize(SkewMultipoles, 0))
//		if (DimSize(NormalMultipoles, 0)> 1)
//			Notebook Report specialChar={1, 0, ""}
//		elseif (DimSize(NormalMultipoles, 0))
//			Notebook Report, text="\r"	
//		endif
//
//		Add_Multipoles_Table(Dynamic, "Skew")
//
//		for (i=0; i<DimSize(SkewMultipoles,0); i=i+1)
//			Add_Multipole_Profile(SkewMultipoles[i], "Skew", Dynamic)
//		endfor
//	
//	endif
//	
//	Notebook Report specialChar={1, 0, ""}	
//		
//End
//
//
//Function Add_Multipoles_Table(Dynamic, FieldComponent)
//	variable Dynamic
//	string FieldComponent
//	
//	
//	SVAR dfA = root:varsCAMTO:FieldmapA
//	SVAR dfB = root:varsCAMTO:FieldmapB
//	NVAR ReferenceFieldmap = root:varsCAMTO:ReferenceFieldmap
//	NVAR CheckMultTwo = root:varsCAMTO:CheckMultTwo
//
//	Wave Multipoles = root:wavesCAMTO:$(FieldComponent + "Multipoles")
//	
//	string multstr
//	
//	if (Dynamic == 1)
//		multstr = "Dyn_Mult_" + FieldComponent + "_Int"
//	else
//		multstr = "Mult_" + FieldComponent + "_Int"
//	endif
//	
//	variable size = DimSize(Multipoles, 0)
//		
//	Make/O/T/N=(size, 3) TableWave
//	Make/O/T/N=(size) RowWave
//	Make/O/T/N=3 ColWave
//	
//	if (ReferenceFieldmap == 1)
//		ColWave = {dfA, dfB, "Error [%]"}
//		Wave mult = $("root:" + dfb + ":" + multstr)
//		if (cmpstr(dfA, "Nominal")!=0)
//			Wave mult_ref = $("root:" + dfa + ":" + multstr)		
//		endif	
//				
//	else
//		ColWave = {dfB, dfA, "Error [%]"}
//		Wave mult = $("root:" + dfa + ":" + multstr)
//		if (cmpstr(dfB, "Nominal")!=0)
//			Wave mult_ref = $("root:" + dfb + ":" + multstr)
//		endif
//
//	endif
//	
//	Duplicate/O mult temp_mult
//	if (WaveExists(mult_ref))
//		Duplicate/O mult_ref temp_mult_ref
//	endif
//	
//	if (CheckMultTwo)
//		temp_mult = 2*temp_mult
//		if (WaveExists(temp_mult_ref))
//			temp_mult_ref = 2*temp_mult_ref
//		endif
//	endif
//	
//	variable i, n
//	string str
//	for (i=0; i<size; i=i+1)
//		n = Multipoles[i][0]
//		
//		sprintf str, "%2.0f", n
//		RowWave[i] = str
//		
//		if (WaveExists(mult_ref))
//			sprintf str, "% 8.4f", temp_mult_ref[n] 
//		else
//			sprintf str, "% 8.4f", Multipoles[i][1] 
//		endif
//		TableWave[i][0] = str
//		
//		sprintf str, "% 8.4f", temp_mult[n] 
//		TableWave[i][1] = str
//		
//		if (WaveExists(temp_mult_ref))
//			sprintf str, "% 5.4f", 100*(temp_mult[n] - temp_mult_ref[n])/temp_mult_ref[n] 
//		else
//			sprintf str, "% 5.4f", 100*(temp_mult[n] - Multipoles[i][1])/Multipoles[i][1]  
//		endif
//		TableWave[i][2] = str
//		
//	endfor
//	
//	Add_Table(TableWave, ColWave=ColWave, RowWave=RowWave, Title="Integrated " + FieldComponent + " Multipoles:", RowTitle="n", Spacing=5)
//			
//	Killwaves/Z TableWave, ColWave, RowWave
//	Killwaves/Z temp_mult, temp_mult_ref
//	
//End
//
//
//Function Add_Multipole_Profile(K, FieldComponent, Dynamic)
//	variable K
//	string FieldComponent
//	variable Dynamic
//	
//	if (Dynamic)
//		Compare_Multipole_Profile_(1, K=K, FieldComponent=FieldComponent)
//		Notebook Report, text="\t",scaling={90,90}, picture={$("CompareDynMult" + FieldComponent),0, 1, 8},text="\r"
//		Killwindow/Z $("CompareDynMult" + FieldComponent)
//	else
//		Compare_Multipole_Profile_(0, K=K, FieldComponent=FieldComponent)
//		Notebook Report, text="\t",scaling={90,90}, picture={$("CompareMult" + FieldComponent),0, 1, 8},text="\r"
//		Killwindow/Z $("CompareMult" + FieldComponent)	
//	endif
//	
//End
//
//
//Function Add_Multipoles_Error_Table()
//
//	NVAR r0     = root:varsCAMTO:DistCenter
//	NVAR main_k = root:varsCAMTO:MainK
//
//	Wave/Z normal_sys_monomials
//	Wave/Z normal_sys_multipoles
//	Wave/Z normal_rms_monomials 
//	Wave/Z normal_rms_multipoles
//	Wave/Z skew_sys_monomials
//	Wave/Z skew_sys_multipoles
//	Wave/Z skew_rms_monomials
//	Wave/Z skew_rms_multipoles
//
//	if (WaveExists(normal_sys_monomials))
//		Concatenate {normal_sys_monomials, skew_sys_monomials, normal_rms_monomials, skew_rms_monomials}, temp_monomials 
//		Sort temp_monomials, temp_monomials
//		if (numpnts(temp_monomials) > 1)	
//			FindDuplicates/RN=monomials temp_monomials
//		else
//			Duplicate/O temp_monomials monomials
//		endif
//		
//		if (numpnts(monomials) == 0)
//			Killwaves/Z temp_monomials, monomials
//			return -1
//		endif 
//	
//		string TableTitle="Magnet Multipole Errors Specification @r = " + num2str(r0) +" mm:"
//		string Bmain = "B" + num2str(main_k)
//		
//		Make/O/T ColWave = {"Sys Normal", "Sys Skew", "Rnd Normal", "Rnd Skew"}
//		Make/O/T/N=(numpnts(monomials),4) TableWave 
//		Make/O/T/N=(numpnts(monomials)) RowWave 
//			
//		variable i, k
//		string str
//		for (i=0; i<numpnts(monomials); i=i+1)
//			k = monomials[i]
//	
//			RowWave[i] = "B" + num2str(k) + "/" + Bmain
//			
//			FindValue/V=(k) normal_sys_monomials
//			if (V_value == -1)
//				TableWave[i][0] = "--"
//			else
//				sprintf str, "% 2.1e", normal_sys_multipoles[V_value]
//				TableWave[i][0] =  str
//			endif
//	
//			FindValue/V=(k) skew_sys_monomials
//			if (V_value == -1)
//				TableWave[i][1] = "--"
//			else
//				sprintf str, "% 2.1e", skew_sys_multipoles[V_value]
//				TableWave[i][1] = str
//			endif
//	
//			FindValue/V=(k) normal_rms_monomials
//			if (V_value == -1)
//				TableWave[i][2] = "--"
//			else
//				sprintf str, "% 2.1e", normal_rms_multipoles[V_value]
//				TableWave[i][2] =  str
//			endif
//	
//			FindValue/V=(k) skew_rms_monomials
//			if (V_value == -1)
//				TableWave[i][3] = "--"
//			else
//				sprintf str, "% 2.1e", skew_rms_multipoles[V_value]
//				TableWave[i][3] = str
//			endif
//			
//		endfor
//		
//		Add_Table(TableWave, RowWave=RowWave, ColWave=ColWave, Title=TableTitle, RowTitle="Multipole", Spacing=1)
//				
//		Killwaves/Z TableWave, RowWave, ColWave
//		Killwaves/Z temp_monomials, monomials
//	endif
//
//End
//
//
//Function Add_Residual_Field_Profile(Dynamic)
//	variable 	Dynamic
//	
//	Notebook Report ruler=TableTitle, text="\tResidual Field:\r\r"
//	
//	Show_Residual_Field(Dynamic)
//	
//	Notebook Report, text="\t", picture={$("NormalResidualField"),0, 1, 8}, text="\r\r"
//	Killwindow/Z $("NormalResidualField")
//
//	Notebook Report, text="\t", picture={$("SkewResidualField"),0, 1, 8}, text="\r\r"
//	Killwindow/Z $("SkewResidualField")
//
//	Notebook Report specialChar={1, 0, ""}
//End
//
//
//Function Add_Parameters(Dynamic)
//	variable Dynamic
//	
//	SVAR CAMTOVersion   = root:varsCAMTO:CAMTOVersion 
//	
//	SVAR dfA = root:varsCAMTO:FieldmapA
//	SVAR dfB = root:varsCAMTO:FieldmapB
//
//	if (cmpstr(dfA, "Nominal")==0)
//		Add_Calc_Parameters(dfB, Dynamic)
//	elseif (cmpstr(dfB, "Nominal")==0)
//		Add_Calc_Parameters(dfA, Dynamic)
//	else
//		Add_Calc_Parameters(dfA, Dynamic)
//		Add_Calc_Parameters(dfB, Dynamic)
//	endif
//	
//	Notebook Report text="\tCAMTO Version : " + CAMTOVersion + "\r"
//		
//End
//
//
//Function Add_Calc_Parameters(df, Dynamic)
//	string df
//	variable Dynamic
//	
//	SetDataFolder root:$(df)
//	
//	NVAR TrajShift = root:varsCAMTO:TrajShift
//	
//	SVAR FMFilename = :varsFieldmap:FMFilename
//		
//	Wave/T HeaderLines
//			
//	if (Dynamic)
//		NVAR GridMin			= :varsFieldmap:GridMinTraj
//		NVAR GridMax			= :varsFieldmap:GridMaxTraj
//		NVAR DistCenter		= :varsFieldmap:DistcenterTraj
//		SVAR NormalCoefs 	= :varsFieldmap:DynNormalCoefs 
//		SVAR SkewCoefs 	 	= :varsFieldmap:DynSkewCoefs
//		
//	else
//		NVAR GridMin        = :varsFieldmap:GridMin
//		NVAR GridMax        = :varsFieldmap:GridMax
//		NVAR Distcenter     = :varsFieldmap:Distcenter
//		SVAR NormalCoefs 	= :varsFieldmap:NormalCoefs 
//		SVAR SkewCoefs 	 	= :varsFieldmap:SkewCoefs		
//	endif
//
//	variable energy = GetParticleEnergy()
//
//	Notebook Report ruler=TableHeader6, text="\t" + df + ":\r\r"
//
//	variable i
//	string filename
//		
//	for (i=0; i< numpnts(HeaderLines); i=i+1)
//		sscanf HeaderLines[i], "filename: %s", filename
//		if (strlen(filename) != 0)
//			Notebook Report ruler=Table6,text= "\tFilename:\r" 
//			Notebook Report ruler=Table6,text= "\t"+ FMFilename + "\r"
//			break
//		endif
//	endfor
//
//	for (i=0; i< numpnts(HeaderLines); i=i+1)
//		if (strlen(HeaderLines[i])>1)
//			sscanf HeaderLines[i], "filename: %s", filename
//			if (strlen(filename) != 0)
//				continue
//			endif
//			Notebook Report ruler=Table6,text= "\t"+ HeaderLines[i]	
//		endif
//	endfor
//		
//	Make/O/T/N=(50, 2) TableWave
//
//	i = 0
//	if (Dynamic)
//		TableWave[i][0] = "Particle energy"
//		TableWave[i][1] = num2str(energy) + " Gev"
//		TableWave[1+i][0] = "Trajectory step"
//		TableWave[1+i][1] = num2str(1000*TrajShift) + " mm"
//		TableWave[2+i][0] = "Trajectory x @z=0mm"
//		TableWave[2+i][1] = num2str(GetTrajPosX(0)) + " mm"
//		i=i+3
//	endif
//
//	TableWave[i][0] = "Multipoles grid"
//	TableWave[i][1] = "[" + num2str(GridMin) + " mm, " + num2str(GridMax) + " mm]"
//
//	TableWave[1+i][0] = "R0 relative multipoles"
//	TableWave[1+i][1] = num2str(Distcenter) + " mm"
//
//	TableWave[2+i][0] = "Normal multipoles:"
//	TableWave[2+i][1] = NormalCoefs + "  (0 - On, 1 - Off)"
//
//	TableWave[3+i][0] = "Skew multipoles:"
//	TableWave[3+i][1] = SkewCoefs
//		
//	Redimension/N=(4+i, 2) TableWave
//	Add_Table(TableWave, Spacing=6)
//	
//	Killwaves/Z TableWave
//
//End
//
//
//Function Add_Table(TableWave, [ColWave, RowWave, Title, RowTitle, Spacing])
//	Wave/T TableWave
//	Wave/T ColWave
//	Wave/T RowWave
//	String Title
//	String RowTitle
//	Variable Spacing
//	
//	
//	if (ParamIsDefault(Spacing))
//		Spacing = 0
//	endif
//	
//	string table_ruler_name  = "Table" + num2str(Spacing)
//	string header_ruler_name = "TableHeader" + num2str(Spacing)
//	
//	if (!ParamIsDefault(Title))
//		Notebook Report ruler=TableTitle, text="\t" + Title  + "\r"
//	endif
//	
//	variable i, j
//	
//	if (!ParamIsDefault(ColWave))
//		if (!ParamIsDefault(RowWave))
//			if (ParamIsDefault(RowTitle))
//				Notebook Report ruler=$(header_ruler_name), text="\t"
//			else
//				Notebook Report ruler=$(header_ruler_name), text="\t" + RowTitle
//			endif
//		endif
//		
//		for (i=0; i<numpnts(ColWave); i=i+1)
//			Notebook Report ruler=$(header_ruler_name), text="\t"+ColWave[i]
//		endfor
//		
//		Notebook Report text="\r"
//	endif
//	
//	for (j=0; j<DimSize(TableWave, 0); j=j+1)
//		if (!ParamIsDefault(RowWave))
//			Notebook Report ruler=$(table_ruler_name), text="\t"+RowWave[j]
//		endif
//		
//		if (DimSize(TableWave, 1) != 0)
//			for (i=0; i<DimSize(TableWave, 1); i=i+1)
//				Notebook Report ruler=$(table_ruler_name), text="\t" + TableWave[j][i]
//			endfor
//		else
//			Notebook Report ruler=$(table_ruler_name), text="\t" + TableWave[j]
//		endif
//		Notebook Report text="\r"
//	endfor
//	
//	Notebook Report text="\r"
//
//End
//
//
//Window Load_Line_Scan() : Panel
//	PauseUpdate; Silent 1
//
//	CloseWindow("Load_Line_Scan")
//	
//	CreateLoadScanVariables()
//		
//	NewPanel /K=1 /W=(1240,60,1500,310)
//	SetDrawLayer UserBack
//	SetDrawEnv fillpat= 0
//	DrawRect 5,3,255,245
//			
//	TitleBox FMdir,      pos={80,12},size={80,40},title="Load Line Scan",fsize=14,fstyle=1,frame=0
//	SetVariable scanlabel, pos={20,50},size={220,18},title="Label:",value=root:ScanLabel
//	
//	TitleBox LoadTxt, pos={20,80},size={80,40},title="Columns:",fsize=12,frame=0
//	CheckBox check_pos,pos={35,100},size={220,15},title=" Position",variable=root:LoadPos
//	CheckBox check_bx,pos={35,120},size={220,15},title=" Bx Average",variable=root:LoadBx
//	CheckBox check_by,pos={35,140},size={220,15},title=" By Average",variable=root:LoadBy
//	CheckBox check_bz,pos={35,160},size={220,15},title=" Bz Average",variable=root:LoadBz
//	CheckBox check_bx_std,pos={35,180},size={220,15},title=" Bx Std",variable=root:LoadBxStd
//	CheckBox check_by_std,pos={35,200},size={220,15},title=" By Std",variable=root:LoadByStd
//	CheckBox check_bz_std,pos={35,220},size={220,15},title=" Bz Std",variable=root:LoadBzStd
//	
//	Button loadscan,pos={135, 110},size={100,110},proc=LoadLineScan,fsize=14,fstyle=1,title="Load"
//				
//EndMacro
//
//
//Function CreateLoadScanVariables()
//	
//	DFREF df = GetDataFolderDFR()
//	
//	SetDataFolder root:
//	string/G ScanLabel=""
//
//	NVAR LoadPos = root:LoadPos
//
//	if (NVAR_Exists(LoadPos) == 0)
//		variable/G LoadPos = 1
//		variable/G LoadBx = 1
//		variable/G LoadBy = 1
//		variable/G LoadBz = 1
//		variable/G LoadBxStd = 1
//		variable/G LoadByStd = 1
//		variable/G LoadBzStd = 1
//	endif
//
//	SetDataFolder df
//
//End
//
//Function LoadLineScan(ctrlName) : ButtonControl
//	String ctrlName
//	
//	SVAR ScanLabel = root:ScanLabel
//	NVAR LoadPos = root:LoadPos
//	NVAR LoadBx = root:LoadBx
//	NVAR LoadBy = root:LoadBy
//	NVAR LoadBz = root:LoadBz
//	NVAR LoadBxStd = root:LoadBxStd
//	NVAR LoadByStd = root:LoadByStd
//	NVAR LoadBzStd = root:LoadBzStd
//	
//	DFREF df = GetDataFolderDFR()
//
//	SetDataFolder root:
//	
//	variable i, j
//	LoadWave/H/O/G/D/W/A ""
//
//	if (V_flag==0) 
//		return -1
//	endif
//
//	string sl, fn
//	variable idx
//	
//	fn = S_filename
//	fn = RemoveEnding(fn, ".dat")
//	fn = RemoveEnding(fn, ".txt")
//
//	if (strlen(ScanLabel) == 0)
//		idx = strsearch(fn, "ID=",0)
//		if (idx!=-1) 
//			sl = "_" + fn[idx, strlen(fn)]
//		else
//			sl = ""
//		endif
//	else
//		sl = "_" + ScanLabel
//	endif
//
//	Wave wave0, wave1, wave2, wave3
//	Wave/Z wave4, wave5, wave6
//	
//	if (LoadPos == 1)
//		Duplicate/O wave0, $("position" + sl)
//	else
//		Killwaves/Z $("position" + sl)
//	endif
//	
//	if (LoadBx == 1)
//		Duplicate/O wave1, $("bx" + sl)
//	else
//		Killwaves/Z $("bx" + sl)
//	endif
//	
//	if (LoadBy == 1)
//		Duplicate/O wave2, $("by" + sl)
//	else
//		Killwaves/Z $("by" + sl)
//	endif
//	
//	if (LoadBz == 1)
//		Duplicate/O wave3, $("bz" + sl)
//	else
//		Killwaves/Z $("bz" + sl)
//	endif
//	
//	if (Waveexists(wave4)==1 && Waveexists(wave5)==1 && Waveexists(wave6)==1)
//		if (LoadBxStd == 1)
//			Duplicate/O wave4, $("std_bx" + sl)
//		else
//			Killwaves/Z $("std_bx" + sl)
//		endif
//		
//		if (LoadByStd == 1)
//			Duplicate/O wave5, $("std_by" + sl)
//		else
//			Killwaves/Z $("std_by" + sl)
//		endif
//		
//		if (LoadBzStd == 1)
//			Duplicate/O wave6, $("std_bz" + sl)
//		else
//			Killwaves/Z $("std_bz" + sl)
//		endif
//	endif
//	
//	Killwaves/Z wave0, wave1, wave2, wave3, wave4, wave5, wave6
//	
//	SetDataFolder df
//End
//
//Function GetTrajPosX(PosYZ)
//	variable PosYZ
//	
//	NVAR TrajShift = root:varsCAMTO:TrajShift
//	
//	NVAR StartXTraj = :varsFieldmap:StartXTraj
//	NVAR BeamDirection = :varsFieldmap:BeamDirection
//	
//	wave TrajX = $"TrajX" + num2str(StartXTraj/1000)
//	wave TrajY = $"TrajY" + num2str(StartXTraj/1000)
//	wave TrajZ = $"TrajZ"  + num2str(StartXTraj/1000)
//
//	variable horizontal_pos	
//	variable index, diff_up, diff_down
//	
//	if (BeamDirection == 1)
//		Duplicate/O TrajY TrajL
//	else
//		Duplicate/O TrajZ TrajL
//	endif
//	
//	FindValue/V=(PosYZ/1000) TrajL
//	if (V_value == -1)
//		FindValue/V=(PosYZ/1000)/T=(TrajShift) TrajL
//	endif
//	if (V_value == -1)
//		return NaN
//	else
//		index = V_value
//		
//		if (TrajL[index] != PosYZ/1000)
//			diff_up = Abs(PosYZ/1000 - TrajL[index+1])
//			diff_down = Abs(PosYZ/1000 - TrajL[index-1])
//					
//			if (diff_up < diff_down && index != numpnts(TrajL)-1)
//				horizontal_pos = TrajX[index] + (TrajX[index+1] - TrajX[index])*(PosYZ/1000 - TrajL[index])/(TrajL[index+1] - TrajL[index])
//			else
//				horizontal_pos = TrajX[index-1] + (TrajX[index] - TrajX[index-1])*(PosYZ/1000 - TrajL[index-1])/(TrajL[index] - TrajL[index-1])
//			endif			
//		
//		else
//			horizontal_pos = TrajX[index]
//		
//		endif
//		
//	endif
//	
//	Killwaves/Z TrajSearch
//	
//	return horizontal_pos*1000
//
//End
//
//
//Function GetTrajAngleX(PosYZ)
//	variable PosYZ
//	
//	NVAR TrajShift = root:varsCAMTO:TrajShift
//	
//	NVAR StartXTraj = :varsFieldmap:StartXTraj
//	NVAR BeamDirection = :varsFieldmap:BeamDirection
//
//	Wave TrajX = $"TrajX"+num2str(StartXTraj/1000)
//	Wave VelX  = $"Vel_X"+num2str(StartXTraj/1000)
//
//	if (BeamDirection == 1)
//		Wave TrajL = $"TrajY"+num2str(StartXTraj/1000)
//		Wave VelL  = $"Vel_Y"+num2str(StartXTraj/1000)
//	else
//		Wave TrajL = $"TrajZ"+num2str(StartXTraj/1000)
//		Wave VelL  = $"Vel_Z"+num2str(StartXTraj/1000)
//	endif
//
//	variable angle, index, diff_up, diff_down, vx, vl
//	
//	FindValue/V=(PosYZ/1000) TrajL
//	if (V_value == -1)
//		FindValue/V=(PosYZ/1000)/T=(TrajShift) TrajL
//	endif
//	
//	if (V_value == -1)
//		return NaN
//	else
//		index = V_value
//		
//		if (TrajL[index] != PosYZ/1000)
//			diff_up = Abs(PosYZ/1000 - TrajL[index+1])
//			diff_down = Abs(PosYZ/1000 - TrajL[index-1])
//					
//			if (diff_up < diff_down && index != numpnts(TrajL)-1)
//				vx = VelX[index] + (VelX[index+1] - VelX[index])*(PosYZ/1000 - TrajL[index])/(TrajL[index+1] - TrajL[index])
//				vl = VelL[index] + (VelL[index+1] - VelL[index])*(PosYZ/1000 - TrajL[index])/(TrajL[index+1] - TrajL[index])
//			else
//				vx = VelX[index-1] + (VelX[index] - VelX[index-1])*(PosYZ/1000 - TrajL[index-1])/(TrajL[index] - TrajL[index-1])
//				vl = VelL[index-1] + (VelL[index] - VelL[index-1])*(PosYZ/1000 - TrajL[index-1])/(TrajL[index] - TrajL[index-1])
//			endif			
//		
//		else
//			vx = VelX[index]
//			vl = VelL[index]
//		
//		endif
//		
//		angle = atan(vx/vl)*180/pi
//		return angle
//	endif
//
//End
//
//
//Function IntegratedMultipole(k, [skew])
//	variable k
//	variable skew
//	
//	if (ParamIsDefault(skew))
//		skew = 0
//	endif	
//	
//	DFREF cf = GetDataFolderDFR()
//	
//	SetDataFolder root:
//		
//	Wave/T fieldmapFolders = root:wavesCAMTO:fieldmapFolders
//	NVAR   fieldmapCount = root:varsCAMTO:FIELDMAP_COUNT
//	
//	string wn, nwn
//	if (skew)
//		wn = "Mult_Skew_Int"
//	else
//		wn = "Mult_Normal_Int"
//	endif
//	
//	nwn = wn + "_" + num2str(k)	
//	Make/D/O/N=(FieldmapCount) $nwn 
//	Wave Mult_Int = $nwn
//		
//	variable i
//	string df
//	
//	for (i=0; i<fieldmapCount; i=i+1)
//		df = fieldmapFolders[i]
//		Wave temp = root:$(df):$(wn)
//		if (WaveExists(temp))
//			Mult_Int[i] = temp[k]
//		else
//			Print("Multipoles wave not found for: " + df)
//			break
//		endif
//	endfor
//	
//	SetDataFolder cf
//	
//End
//
//
//
//Function IntegratedDynamicMultipole(k, [skew])
//	variable k
//	variable skew
//	
//	if (ParamIsDefault(skew))
//		skew = 0
//	endif	
//	
//	DFREF cf = GetDataFolderDFR()
//	
//	SetDataFolder root:
//		
//	Wave/T fieldmapFolders = root:wavesCAMTO:fieldmapFolders
//	NVAR   fieldmapCount = root:varsCAMTO:FIELDMAP_COUNT
//	
//	string wn, nwn
//	
//	if (skew)
//		wn = "Dyn_Mult_Skew_Int"
//	else
//		wn = "Dyn_Mult_Normal_Int"
//	endif
//	
//	nwn = wn + "_" + num2str(k)	
//	Make/D/O/N=(FieldmapCount) $nwn
//	Wave Dyn_Mult_Int = $nwn
//		
//	variable i
//	string df
//	
//	for (i=0; i<fieldmapCount; i=i+1)
//		df = fieldmapFolders[i]
//		Wave temp = root:$(df):$(wn)
//		if (WaveExists(temp))
//			Dyn_Mult_Int[i] = temp[k]
//		else
//			Print("Multipoles wave not found for: " + df)
//			KillWaves/Z Dyn_Mult_Int
//			break
//		endif				
//	endfor
//	
//	SetDataFolder cf
//	
//End
//
//
//Function FindDipoleX0(nominal_deflection, xa, xb, [tol, nmax])
//	variable nominal_deflection, xa, xb, tol, nmax
//
//	if (ParamIsDefault(tol))
//		tol = 1e-3
//	endif
//
//	if (ParamIsDefault(nmax))
//		nmax = 1000
//	endif
//	
//	NVAR StartYZ = :varsFieldmap:StartYZ 
//	NVAR EndYZ   = :varsFieldmap:EndYZ
//
//	NVAR EntranceAngle = :varsFieldmap:EntranceAngle
//	NVAR StartXTraj    = :varsFieldmap:StartXTraj 
//	NVAR StartYZTraj = :varsFieldmap:StartYZTraj 
//	NVAR EndYZTraj   = :varsFieldmap:EndYZTraj
//	NVAR CheckField    = :varsFieldmap:CheckField
//   NVAR CheckNegPosTraj = :varsFieldmap:CheckNegPosTraj
//	NVAR Single_Multi  = :varsFieldmap:Single_Multi 
//	NVAR Analitico_RungeKutta = :varsFieldmap:Analitico_RungeKutta  
//
//	variable EntranceAngle_init
//	variable StartXTraj_init
//	variable StartYZTraj_init
//	variable EndYZTraj_init
//	variable CheckField_init
//	variable CheckNegPosTraj_init
//	variable Single_Multi_init
//	variable Analitico_RungeKutta_init
//
//	EntranceAngle_init = EntranceAngle
//	StartXTraj_init = StartXTraj
//	StartYZTraj_init = StartYZTraj
//	EndYZTraj_init = EndYZTraj
//	CheckField_init = CheckField
//	CheckNegPosTraj_init = CheckNegPosTraj
//	Single_Multi_init = Single_Multi
//	Analitico_RungeKutta_init = Analitico_RungeKutta
//
//	EntranceAngle = 0
//	StartYZTraj = 0
//	EndYZTraj =  Min(Abs(StartYZ), Abs(EndYZ))
//	CheckField = 1
//	CheckNegPosTraj = 1
//	Single_Multi = 1
//	Analitico_RungeKutta = 2
//
//	variable n, xc, defc, diffc, diffa, x0
//	string xc_str, defc_str
//
//	StartXTraj = xa
//	TrajectoriesCalculationProc("")
//	wave Deflection_IntTraj_X
//	diffa = nominal_deflection - Deflection_IntTraj_X[0]
//	
//	n = 1
//	do
//		xc = (xa + xb)/2
//		StartXTraj = xc
//		TrajectoriesCalculationProc("")
//		wave Deflection_IntTraj_X
//		defc = Deflection_IntTraj_X[0]
//		
//		sprintf xc_str, "%.10f", xc
//		sprintf defc_str, "%.10f", defc
//		Print/D "X0 [mm]: "  + xc_str
//		Print/D "Deflection [°]: " + defc_str
//		Print " "
//		
//		diffc = nominal_deflection - defc
//		if (diffc == 0 || (xb-xa)/2 < tol)
//			break
//		endif
//
//		if (sign(diffc) == sign(diffa))
//			xa = xc
//			diffa = diffc
//		else
//			xb = xc
//		endif 
//
//		n = n+1
//	while (n < nmax)
//
//	x0 = StartXTraj
//
//	EntranceAngle = EntranceAngle_init
//	StartXTraj = StartXTraj_init
//	StartYZTraj = StartYZTraj_init
//	EndYZTraj = EndYZTraj_init
//	CheckField = CheckField_init
//	CheckNegPosTraj = CheckNegPosTraj_init
//	Single_Multi = Single_Multi_init
//	Analitico_RungeKutta = Analitico_RungeKutta_init
//	UpdateTrajectoriesPanel()
//
//	return x0
//
//End
//
//// Alterações
////Versão 12.9.1  - Multipolos Normalizados não são mais expressos por seus módulos (pedido da Priscila)
////Versão 12.10.1 - Mudança no método de cálculo de simetrias, adição de rotinas para cálculo dos multipolos residuais normalizados e cabeçalho no arquivo exportado. Multipolos de todas as componentes são agora normalizados em relação ao mesmo termo.
////Versão 12.11.0 - Mudança no método de cálculo de multipolos sobre a trajetória. 
////Versão 13.0.0  - Mudança na estrutura de pastas para analisar mais de um mapa de campo no mesmo experimento.
////Versão 13.0.1  - Diferenciação dos coeficientes usados para calcular multipolos normal e skew.
////Versão 13.0.2  - Correção de bugs.