// FieldMapTrilinearSpline.h -- equates for FieldMapTrilinearSpline XOP

// FieldMapTrilinearSpline custom error codes
#define REQUIRES_SP_OR_DP_WAVE 1 + FIRST_XOP_ERR
#define MISSING_INTERPOLANT 2 + FIRST_XOP_ERR
#define WRONG_INPUT 3 + FIRST_XOP_ERR

#pragma pack(2)		
struct Calc3DInterpolantParams {
	waveHndl FieldzHandle;
	waveHndl FieldyHandle;
	waveHndl FieldxHandle;
	waveHndl zHandle;
	waveHndl yHandle;
	waveHndl xHandle;
	double result;
};
typedef struct Calc3DInterpolantParams Calc3DInterpolantParams;
typedef struct Calc3DInterpolantParams* Calc3DInterpolantParamsPtr;
#pragma pack()		

#pragma pack(2)		
struct Get3DFieldParams {
	double z;
	double y;
	double x;
	UserFunctionThreadInfoPtr tp;
	double result;
};
typedef struct Get3DFieldParams Get3DFieldParams;
typedef struct Get3DFieldParams* Get3DFieldParamsPtr;
#pragma pack()		


// Prototypes
HOST_IMPORT int XOPMain(IORecHandle ioRecHandle);
extern "C" int Calc3DSplineInterpolant(struct Calc3DInterpolantParams* p);
extern "C" int Get3DFieldX(struct Get3DFieldParams* p);
extern "C" int Get3DFieldY(struct Get3DFieldParams* p);
extern "C" int Get3DFieldZ(struct Get3DFieldParams* p);