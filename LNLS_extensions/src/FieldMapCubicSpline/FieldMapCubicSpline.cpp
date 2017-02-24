#include "XOPStandardHeaders.h"			// Include ANSI headers, Mac headers, IgorXOP.h, XOP.h and XOPSupport.h

#include "FieldMapCubicSpline.h"

/* Global Variables */
extern int hasFPU;					/* in XOPSupport.c */

static XOPIORecResult
RegisterFunction()
{
	int funcIndex;

	funcIndex = (int)GetXOPItem(0);		/* which function invoked ? */
	switch (funcIndex) {
		case 0:							
			return (XOPIORecResult)Calc2DSplineInterpolant;
			break;

		case 1:							
			return (XOPIORecResult)GetFieldX;
			break;

		case 2:
			return (XOPIORecResult)GetFieldY;
			break;

		case 3:
			return (XOPIORecResult)GetFieldZ;
			break;
	}
	return 0;
}

static int
DoFunction()
{
	int funcIndex;
	void *p;				/* pointer to structure containing function parameters and result */
	int err;

	funcIndex = (int)GetXOPItem(0);	/* which function invoked ? */
	p = (void*)GetXOPItem(1);		/* get pointer to params/result */
	switch (funcIndex) {
		case 0:						
			err = Calc2DSplineInterpolant((CalcInterpolantParams*)p);
			break;
		
		case 1:						
			err = GetFieldX((GetFieldParams*)p);
			break;

		case 2:
			err = GetFieldY((GetFieldParams*)p);
			break;
		
		case 3:
			err = GetFieldZ((GetFieldParams*)p);
			break;
	}
	return(err);
}

/*	XOPEntry()

	This is the entry point from the host application to the XOP for all messages after the
	INIT message.
*/
extern "C" void
XOPEntry(void)
{	
	XOPIORecResult result = 0;

	switch (GetXOPMessage()) {
		case FUNCTION:								/* our external function being invoked ? */
			result = DoFunction();
			break;
			
		case FUNCADDRS:
			result = RegisterFunction();
			break;
	}
	SetXOPResult(result);
}

/*	XOPMain(ioRecHandle)

	This is the initial entry point at which the host application calls XOP.
	The message sent by the host must be INIT.
	
	XOPMain does any necessary initialization and then sets the XOPEntry field of the
	ioRecHandle to the address to be called for future messages.
*/
HOST_IMPORT int
XOPMain(IORecHandle ioRecHandle)		// The use of XOPMain rather than main means this XOP requires Igor Pro 6.20 or later
{	
	XOPInit(ioRecHandle);				// Do standard XOP initialization
	SetXOPEntry(XOPEntry);				// Set entry point for future calls

	if (igorVersion < 620) {
		SetXOPResult(IGOR_OBSOLETE);
		return EXIT_FAILURE;
	}
	
	SetXOPResult(0);
	return EXIT_SUCCESS;
}