// FieldMapCubicSpline.h -- equates for FieldMapCubicSpline XOP

// FieldMapCubicSpline custom error codes
#define REQUIRES_SP_OR_DP_WAVE 1 + FIRST_XOP_ERR
#define MISSING_INTERPOLANT 2 + FIRST_XOP_ERR
#define WRONG_INPUT 3 + FIRST_XOP_ERR

#pragma pack(2)		
struct CalcInterpolantParams {
	waveHndl FieldzHandle;
	waveHndl FieldyHandle;
	waveHndl FieldxHandle;
	waveHndl zHandle;
	waveHndl xHandle;
	double result;
};
typedef struct CalcInterpolantParams CalcInterpolantParams;
typedef struct CalcInterpolantParams *CalcInterpolantParamsPtr;
#pragma pack()		

#pragma pack(2)		
struct GetFieldParams {
	double z;
	double x;
	UserFunctionThreadInfoPtr tp;
	double result;
};
typedef struct GetFieldParams GetFieldParams;
typedef struct GetFieldParams *GetFieldParamsPtr;
#pragma pack()		


// Prototypes
HOST_IMPORT int XOPMain(IORecHandle ioRecHandle);
extern "C" int Calc2DSplineInterpolant(struct CalcInterpolantParams* p);
extern "C" int GetFieldX(struct GetFieldParams* p);
extern "C" int GetFieldY(struct GetFieldParams* p);
extern "C" int GetFieldZ(struct GetFieldParams* p);
