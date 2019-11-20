The first three scripts perform basically the same. 
wrf_Precip.ncl reads fields in time slices and keeps track of previous rainfall totals to calculate tendencies. 
wrf_Precip2.ncl reads all times in one step, eliminating the need to keep track of old rainfall totals in order to calculate tendencies. 
wrf_Precip3.ncl is similar to wrf_Precip2.ncl, but here we calculate 3 hourly tendencies rather than 6 hourly tendencies.
  
wrf_Precip_multi_files.ncl Reads multiple wrfout files and calculate tendencies and total precipitation. This script also calculate different tendeincies (e.g. 3 or 6 hourly with the setting of a single variable)

In these scripts also note:

The overwriting of the map background colors;
Calculation of rain tendencies;
Overwriting of contour levels and colors.