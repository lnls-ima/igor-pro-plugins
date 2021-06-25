#include <vector>
#include <set>
#include "XOPStandardHeaders.h"			
#include "FieldMapTrilinearSpline.h"
#include "alglib/linalg.h"
#include "alglib/interpolation.h"

bool FirstCall = true;
alglib::spline3dinterpolant Fieldx_interpolant;
alglib::spline3dinterpolant Fieldy_interpolant;
alglib::spline3dinterpolant Fieldz_interpolant;

extern "C" int
Calc3DSplineInterpolant(struct Calc3DInterpolantParams* p)
{
	double* xdPtr;
	double* ydPtr;
	double* zdPtr;
	double* FieldxdPtr;
	double* FieldydPtr;
	double* FieldzdPtr;

	float* xfPtr;
	float* yfPtr;
	float* zfPtr;
	float* FieldxfPtr;
	float* FieldyfPtr;
	float* FieldzfPtr;

	std::set<double> x_set;
	std::set<double> y_set;
	std::set<double> z_set;
	std::vector<double> x;
	std::vector<double> y;
	std::vector<double> z;
	std::vector<double> Fieldx;
	std::vector<double> Fieldy;
	std::vector<double> Fieldz;

	if ((p->xHandle == NIL) || (p->yHandle == NIL) || (p->zHandle == NIL) || (p->FieldxHandle == NIL) || (p->FieldyHandle == NIL) || (p->FieldzHandle == NIL)) {
		SetNaN64(&p->result);
		return NULL_WAVE_OP;
	}

	CountInt n;
	n = WavePoints(p->xHandle);
	if ((WavePoints(p->zHandle) != n) || (WavePoints(p->yHandle) != n) || (WavePoints(p->FieldxHandle) != n) || (WavePoints(p->FieldyHandle) != n) || (WavePoints(p->FieldzHandle) != n)) {
		SetNaN64(&p->result);
		return WRONG_INPUT;
	}

	switch (WaveType(p->xHandle)) {
	case NT_FP32:
		xfPtr = (float*)WaveData(p->xHandle);
		yfPtr = (float*)WaveData(p->yHandle);
		zfPtr = (float*)WaveData(p->zHandle);
		FieldxfPtr = (float*)WaveData(p->FieldxHandle);
		FieldyfPtr = (float*)WaveData(p->FieldyHandle);
		FieldzfPtr = (float*)WaveData(p->FieldzHandle);

		for (int i = 0; i < n; i += 1) {
			x_set.insert(xfPtr[i]);
			y_set.insert(yfPtr[i]);
			z_set.insert(zfPtr[i]);
			Fieldx.push_back(FieldxfPtr[i]);
			Fieldy.push_back(FieldyfPtr[i]);
			Fieldz.push_back(FieldzfPtr[i]);
		}

		break;

	case NT_FP64:
		xdPtr = (double*)WaveData(p->xHandle);
		ydPtr = (double*)WaveData(p->yHandle);
		zdPtr = (double*)WaveData(p->zHandle);
		FieldxdPtr = (double*)WaveData(p->FieldxHandle);
		FieldydPtr = (double*)WaveData(p->FieldyHandle);
		FieldzdPtr = (double*)WaveData(p->FieldzHandle);

		for (int i = 0; i < n; i += 1) {
			x_set.insert(xdPtr[i]);
			y_set.insert(ydPtr[i]);
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
	y.assign(y_set.begin(), y_set.end());
	z.assign(z_set.begin(), z_set.end());

	int nx = x.size();
	int ny = y.size();
	int nz = z.size();
	if ((nx < 2) || (ny < 2) || (nz < 2)) {
		SetNaN64(&p->result);
		return WRONG_INPUT;
	}

	alglib::real_1d_array x_array;
	alglib::real_1d_array y_array;
	alglib::real_1d_array z_array;
	alglib::real_1d_array Fieldx_array;
	alglib::real_1d_array Fieldy_array;
	alglib::real_1d_array Fieldz_array;

	x_array.setcontent(nx, &x[0]);
	y_array.setcontent(ny, &y[0]);
	z_array.setcontent(nz, &z[0]);
	Fieldx_array.setcontent(n, &Fieldx[0]);
	Fieldy_array.setcontent(n, &Fieldy[0]);
	Fieldz_array.setcontent(n, &Fieldz[0]);

	alglib::spline3dbuildtrilinearv(x_array, nx, y_array, ny, z_array, nz, Fieldx_array, 1, Fieldx_interpolant);
	alglib::spline3dbuildtrilinearv(x_array, nx, y_array, ny, z_array, nz, Fieldy_array, 1, Fieldy_interpolant);
	alglib::spline3dbuildtrilinearv(x_array, nx, y_array, ny, z_array, nz, Fieldz_array, 1, Fieldz_interpolant);

	FirstCall = false;
	p->result = 1;

	return(0);
}

extern "C" int
Get3DFieldX(struct Get3DFieldParams* p)
{
	if (FirstCall) {
		SetNaN64(&p->result);
		return(MISSING_INTERPOLANT);
	}
	alglib::real_1d_array Fieldx;
	alglib::spline3dcalcv(Fieldx_interpolant, p->x, p->y, p->z, Fieldx);
	p->result = Fieldx[0];
	return(0);
}

extern "C" int
Get3DFieldY(struct Get3DFieldParams* p)
{
	if (FirstCall) {
		SetNaN64(&p->result);
		return(MISSING_INTERPOLANT);
	}
	alglib::real_1d_array Fieldy;
	alglib::spline3dcalcv(Fieldy_interpolant, p->x, p->y, p->z, Fieldy);
	p->result = Fieldy[0];
	return(0);
}

extern "C" int
Get3DFieldZ(struct Get3DFieldParams* p)
{
	if (FirstCall) {
		SetNaN64(&p->result);
		return(MISSING_INTERPOLANT);
	}
	alglib::real_1d_array Fieldz;
	alglib::spline3dcalcv(Fieldz_interpolant, p->x, p->y, p->z, Fieldz);
	p->result = Fieldz[0];
	return(0);
}