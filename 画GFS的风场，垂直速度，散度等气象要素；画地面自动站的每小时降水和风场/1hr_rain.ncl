load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

path="out/"

istart = 29
iend = 29
minlat = 27.0
maxlat = 31.5
minlon = 118.5
maxlon = 123.0
oint = 0.05
onlat = floattoint((maxlat-minlat)/oint+1)
print(onlat)
onlon = floattoint((maxlon-minlon)/oint+1)
print(onlon)

files=systemfunc("ls "+path)
nfiles = dimsizes(files)

olat = fspan(minlat,maxlat,onlat)
olon = fspan(minlon,maxlon,onlon)

  olon!0          = "lon"
  olon@units      = "degrees_east"
  olat!0          = "lat"
  olat@units      = "degrees_north"

wksfile = "feite_1hr_rain"

wks = gsn_open_wks("png", "1hrain")

;first = True
new1 = new((/iend+1/), "float")  ;"No_FillValue"  
do i = istart,iend
filename = files(i)
print("reading  "+filename)
str := asciiread(path+filename,-1,"string")
lon := stringtofloat(str_get_field(str,2," "))
lat := stringtofloat(str_get_field(str,3," "))
rainhr := stringtofloat(str_get_field(str,5," "))
rainhr@_FillValue = 9999
 wdir = stringtofloat(str_get_field(str,6," "))
 wspd = stringtofloat(str_get_field(str,7," "))
 pi = 3.14159265
 u = wspd*cos((270-wdir)*pi/180.0)
 v = wspd*sin((270-wdir)*pi/180.0)

rscan = (/0.3,0.2,0.1/)
orainhr = obj_anal_ic(lon,lat,rainhr,olon,olat,rscan,False)
orainhr!0 = "lat"
orainhr!1 = "lon"
orainhr@_FillValue = 9999
orainhr&lat = olat
orainhr&lon = olon

;if (first) then
    ;rainall = orainhr
    ;first = False
;else 
    ;rainall = rainall+orainhr
 ;end if
;do j = 0,1000
;if (abs(lon(j)- 121.37).lt.0.001 .and. abs(lat(j)-28.88).lt.0.001.and.rainhr(j).lt.500) 
   ; new1(i) = rainhr(j)
;end if 

;end do 

map_res=True
    
    map_res@mpMinLatF = minlat
    map_res@mpMaxLatF = maxlat
    map_res@mpMinLonF = minlon
    map_res@mpMaxLonF = maxlon
    
    map_res@mpGridAndLimbOn = True
    map_res@mpGridSpacingF = 10.0
    map_res@mpGridLineColor = "grey80"
    map_res@mpGridLineDashPattern = "5"
    map_res@mpGeophysicalLineThicknessF = 0.5
    map_res@mpUSStateLineThicknessF = .5
    map_res@mpNationalLineThicknessF = 0.5
    map_res@mpUSStateLineColor = "grey60"
    map_res@mpDataSetName = "Earth..4"
    map_res@mpDataBaseVersion = "Mediumres"
    map_res@mpOutlineSpecifiers = (/"China:states","Taiwan"/)
    map_res@mpOutlineOn = True
    map_res@mpLandFillColor = -1
    map_res@mpLimitMode = "LatLon"
    map_res@pmTickMarkDisplayMode = "Conditional"
    map_res@tmXTOn = False
    map_res@tmYROn = False
    map_res@tmXBLabelFontHeightF = 0.015
    map_res@tmXBMajorLengthF = 0.005
    
    map_res@gsnDraw = False
    map_res@gsnFrame = False

    char = stringtocharacter(filename)
    date = charactertostring(char(0:11))
    map_res@gsnLeftString = date
    
    ;******************************************************************************
    ;set rain_res
    ;******************************************************************************
    rain_res = True

    rain_res@cnLevelSelectionMode = "ExplicitLevels"

    ;rain_res@cnFillPalette = "WhBlGrYeRe"
    ;rain_res@cnFillDrawOrder = "PreDraw"
    cmaprh  = read_colormap_file("precip3_16lev")
    rain_res@cnFillPalette  := cmaprh
    rain_res@cnLevels   := (/0.2, 0.5, 1.0, 1.7, 2.5, 3.8, 5.0, 7.5, 10.0, 17.5, 25.0, 30.0, 45.0/)    ; set levels
    
    
    rain_res@cnSmoothingOn  = True
    rain_res@cnSmoothingTensionF = 0.0015

    rain_res@gsnLeftString = ""
    rain_res@gsnRightString = ""
    rain_res@gsnAddCyclic = False
    
    rain_res@cnInfoLabelOn = False
    
    rain_res@cnFillOn = True
    rain_res@cnFillOpacityF = 60
    rain_res@cnLinesOn = False

    
    rain_res@lbLabelBarOn = True
    rain_res@lbOrientation = "Vertical" 
    rain_res@lbLabelPosition = "Right"
    rain_res@pmLabelBarHeightF = 0.6
    rain_res@pmLabelBarWidthF = 0.05
    rain_res@lbLabelFontHeightF = 0.012
    rain_res@lbTitleOn = True
    rain_res@lbTitlePosition = "Top"
    rain_res@lbTitleString = "~F21~RAIN(mm)"
    rain_res@lbTitleFontThicknessF = 0.2
    rain_res@lbTitleFontHeightF = 0.018

    rain_res@gsnMaximize = True
    rain_res@gsnDraw = False
    rain_res@gsnFrame = False




plot_map = gsn_csm_map(wks, map_res)
plot_rain = gsn_csm_contour(wks,orainhr,rain_res)
;plot_rain = gsn_csm_contour(wks,rainall,rain_res)
overlay(plot_map,plot_rain)
                
        draw(plot_map)
        frame(wks)


;plotrain = gsn_csm_contour_map(wks,orainhr,res)
;delete(res)
;draw(plotrain)
;frame(wks)
;asciiwrite("a.txt", new1) 
asciiwrite("a.txt", lat) 
asciiwrite("b.txt", lon)
asciiwrite("c.txt", rainhr)
 delete(str)
 delete(lon)
 delete(lat)
 delete(rainhr)
delete(wspd)
delete(wdir)
delete(u)
delete(v)

 end do


end
