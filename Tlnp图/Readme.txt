wrf_SkewT1.ncl
(wrf_SkewT2.ncl is similar, but i/j location is given and not calculated;
wrf_SkewT3.ncl, uses wrf_user_latlon_to_ij to calculate an array of lat/log points rather than one locations at a time)

Example script to plot skew-T's at given locations.

In this script note:

Must load the function $NCARG_ROOT/lib/ncarg/nclscripts/csm/skewt_func.ncl;
Use function wrf_user_getvar, to calculate "uvmet" (winds rotated to earth coordinates). 
where uvmet(0,:,:,:) is the u and uvmet(1,:,:,:) is the v component of the wind.
This is only needed for real data cases. For idealized cases, ua and va can be used;
skewt_bkgd is used to generate the background;
skewT_PlotData is used to plot sounding.
wrf_SkewT.ncl - uses wrf_user_ll_to_ij to locate the ij point corresponding to a given lon/lat.
Users need to make sure the point is within there model domain.
To use the return value as an NCL array point, 1 must be subtracted;
wrf_SkewT1.ncl (shown below) - uses wrf_user_ll_to_ij to locate the ij points corresponding to given lon/lat values.
Check to see if points are within there model domain.
To use the return value as an NCL array point, 1 must be subtracted;
wrf_SkewT2.ncl - create shew_T plots for a number of ij locations.
wrf_SkewT3.ncl - similar to wrf_SkewT1.ncl, but all ij points are calculated in one step;
wrf_SkewT4.ncl - similar to wrf_SkewT3.ncl, but a different method to check if ij points are withni the model domain;
wrf_SkewT5.ncl - similar to wrf_SkewT4.ncl, but all data is read in one step.