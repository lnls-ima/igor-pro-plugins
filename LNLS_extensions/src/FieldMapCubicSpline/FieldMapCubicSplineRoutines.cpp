#include <vector>
#include <set>
#include "XOPStandardHeaders.h"			
#include "FieldMapCubicSpline.h"
#include "alglib/linalg.h"
#include "alglib/interpolation.h"

bool FirstCall = true;
alglib::spline2dinterpolant Fieldx_interpolant;
alglib::spline2dinterpolant Fieldy_interpolant;
alglib::spline2dinterpolant Fieldz_interpolant;

extern "C" int
Calc2DSplineInterpolant(struct CalcInterpolantParams* p)
{
	double *xdPtr;				
	double *zdPtr;
	double *FieldxdPtr;
	double *FieldydPtr;
	double *FieldzdPtr;

	float  *xfPtr;
	float  *zfPtr;
	float  *FieldxfPtr;
	float  *FieldyfPtr;
	float  *FieldzfPtr;

	std::set<double> x_set;
	std::set<double> z_set;
	std::vector<double> x;
	std::vector<double> z;
	std::vector<double> Fieldx;
	std::vector<double> Fieldy;
	std::vector<double> Fieldz;

	if ((p->xHandle == NIL) || (p->zHandle == NIL) || (p->FieldxHandle == NIL) || (p->FieldyHandle == NIL) || (p->FieldzHandle == NIL)) {
		SetNaN64(&p->result);
		return NULL_WAVE_OP;
	}

	CountInt n;
	n  = WavePoints(p->xHandle);
	if ((WavePoints(p->zHandle) != n) || (WavePoints(p->FieldxHandle) != n) || (WavePoints(p->FieldyHandle) != n) || (WavePoints(p->FieldzHandle) != n)) {
		SetNaN64(&p->result);
		return WRONG_INPUT;
	}

	switch (WaveType(p->xHandle)) {
	case NT_FP32:
		xfPtr      = (float*)WaveData(p->xHandle);
		zfPtr      = (float*)WaveData(p->zHandle);
		FieldxfPtr = (float*)WaveData(p->FieldxHandle);
		FieldyfPtr = (float*)WaveData(p->FieldyHandle);
		FieldzfPtr = (float*)WaveData(p->FieldzHandle);

		for (int i = 0; i < n; i += 1) { 
			x_set.insert(xfPtr[i]); 
			z_set.insert(zfPtr[i]);
			Fieldx.push_back(FieldxfPtr[i]);
			Fieldy.push_back(FieldyfPtr[i]);
			Fieldz.push_back(FieldzfPtr[i]);
		}

		break;

	case NT_FP64:
		xdPtr      = (double*)WaveData(p->xHandle);
		zdPtr      = (double*)WaveData(p->zHandle);
		FieldxdPtr = (double*)WaveData(p->FieldxHandle);
		FieldydPtr = (double*)WaveData(p->FieldyHandle);
		FieldzdPtr = (double*)WaveData(p->FieldzHandle);

		for (int i = 0; i < n; i += 1) { 
			x_set.insert(xdPtr[i]);
			z_set.insert(zdPtr[i]);
			Fieldx.push_back(FieldxdPtr[i]);
			Fieldy.push_back(FieldydPtr[i]);
			Fieldz.push_back(FieldzdPtr[i]);
		}

		break;

	default:							
		SetNaN64(&p->result);
		return(REQUIRES_SP_OR_DP_WAVE);
	}

	x.assign(x_set.begin(), x_set.end());
	z.assign(z_set.begin(), z_set.end());

	int nx = x.size();
	int nz = z.size();
	if ((nx < 2) || (nz < 2)) {
		SetNaN64(&p->result);
		return WRONG_INPUT;
	}

	alglib::real_1d_array x_array;
	alglib::real_1d_array z_array;
	alglib::real_1d_array Fieldx_array;
	alglib::real_1d_array Fieldy_array;
	alglib::real_1d_array Fieldz_array;
	
	x_array.setcontent(nx, &x[0]);
	z_array.setcontent(nz, &z[0]);
	Fieldx_array.setcontent(n, &Fieldx[0]);
	Fieldy_array.setcontent(n, &Fieldy[0]);
	Fieldz_array.setcontent(n, &Fieldz[0]);
	
	alglib::spline2dbuildbicubicv(x_array, nx, z_array, nz, Fieldx_array, 1, Fieldx_interpolant);
	alglib::spline2dbuildbicubicv(x_array, nx, z_array, nz, Fieldy_array, 1, Fieldy_interpolant);
	alglib::spline2dbuildbicubicv(x_array, nx, z_array, nz, Fieldz_array, 1, Fieldz_interpolant);

	FirstCall = false;
	p->result = 1;

	return(0);
}

extern "C" int
GetFieldX(struct GetFieldParams* p)
{
	if (FirstCall) {
		SetNaN64(&p->result);
		return(MISSING_INTERPOLANT);
	}
	alglib::real_1d_array Fieldx;
	alglib::spline2dcalcv(Fieldx_interpolant, p->x, p->z, Fieldx);	
	p->result = Fieldx[0];
	return(0);
}

extern "C" int
GetFieldY(struct GetFieldParams* p)
{
	if (FirstCall) {
		SetNaN64(&p->result);
		return(MISSING_INTERPOLANT);
	}
	alglib::real_1d_array Fieldy;
	alglib::spline2dcalcv(Fieldy_interpolant, p->x, p->z, Fieldy);
	p->result = Fieldy[0];
	return(0);
}

extern "C" int
GetFieldZ(struct GetFieldParams* p)
{
	if (FirstCall) {
		SetNaN64(&p->result);
		return(MISSING_INTERPOLANT);
	}
	alglib::real_1d_array Fieldz;
	alglib::spline2dcalcv(Fieldz_interpolant, p->x, p->z, Fieldz);
	p->result = Fieldz[0];
	return(0);
}