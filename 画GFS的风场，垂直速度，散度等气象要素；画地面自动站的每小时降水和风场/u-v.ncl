load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

path="/public/home/xueyu/wrf/fitow/zdz/out/"
f1 = addfile("/public/home/xueyu/wrf/fitow/moni/wrfout_d03_2013-10-06_00_00_00.nc", "r")
;画地形

hgt = wrf_user_getvar(f1, "HGT", 0)
;hgt@lat2d = lat2d
;hgt@lon2d = lon2d 
lat0 = f1->XLAT(0,:,:)
lon0 = f1->XLONG(0,:,:)
time = f1->Times
time_num = dimsizes(time(:,0))
hgt@lat2d = lat0
hgt@lon2d = lon0

istart = 12
iend = 15
minlat = 27.5
maxlat = 31.5
minlon = 119
maxlon = 123.5
oint = 0.1
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


;first = True
wks  = gsn_open_wks("png","stream")  
do i = istart,iend
filename = files(i)
print("reading  "+filename)
str := asciiread(path+filename,-1,"string")
lon := stringtofloat(str_get_field(str,2," "))
lat := stringtofloat(str_get_field(str,3," "))
;rainhr := stringtofloat(str_get_field(str,5," "))
;rainhr@_FillValue = 9999
 wdir = stringtofloat(str_get_field(str,17," "))
 wdir@_FillValue = 9999
 wspd = stringtofloat(str_get_field(str,18," "))
 wspd@_FillValue = 9999
 pi = 3.14159265
 u1 = wspd*cos((270-wdir)*pi/180.0)
 v1 = wspd*sin((270-wdir)*pi/180.0)



;rscan = (/0.3,0.2,0.1/)
;rscan = (/0.8,0.5,0.3/)
rscan = (/1,0.75,0.4/)
;rscan = (/0.7,0.45,0.25/)
;rscan = (/0.5,0.3,0.1/)
;orainhr = obj_anal_ic(lon,lat,rainhr,olon,olat,rscan,False)
;orainhr!0 = "lat"
;orainhr!1 = "lon"
;orainhr@_FillValue = 9999
u2 = obj_anal_ic(lon,lat,u1,olon,olat,rscan,False)
v2 = obj_anal_ic(lon,lat,v1,olon,olat,rscan,False)

u3 = u2
v3 = v2
do kp = 1,15
        u2 = smth9(u2,0.5,0.25,False)
        v2 = smth9(v2,0.5,0.25,False)
end do

      u = u3 - u2
      v = v3 - v2

u!0 = "lat"
u!1 = "lon"
u@_FillValue = 9999
u&lat = olat
u&lon = olon

v!0 = "lat"
v!1 = "lon"
v@_FillValue = 9999
v&lat = olat
v&lon = olon

;if (first) then
    ;rainall = orainhr
    ;first = False
;else 
    ;rainall = rainall+orainhr
 ;end if



map_res=True
    
map_res@mpMinLatF = minlat
map_res@mpMaxLatF = maxlat
map_res@mpMinLonF = minlon
map_res@mpMaxLonF = maxlon
    
map_res@mpGridAndLimbOn = True
map_res@mpGridSpacingF = 10.0
map_res@mpGridLineColor = "grey80"
map_res@mpGridLineDashPattern = "5"

map_res@mpGeophysicalLineThicknessF = 3

map_res@mpProvincialLineThicknessF= 2
;map_res@mpUSStateLineThicknessF = .5
map_res@mpNationalLineThicknessF = 3
;map_res@mpUSStateLineColor = "grey60"

map_res@mpDataSetName = "Earth..4"
map_res@mpDataBaseVersion = "Mediumres"

map_res@mpOutlineSpecifiers = (/"China:states","Taiwan"/)
map_res@mpOutlineOn = False

map_res@mpLandFillColor = -1
map_res@mpLimitMode = "LatLon"

map_res@mpFillOn              = True
map_res@mpOceanFillColor       = -1; (/24,116,205/)/255.0
;res@mpOceanFillColor       = (/0,0,0/)/255.0
map_res@mpLandFillColor        = -1
    
map_res@tmXTOn = False
map_res@tmYROn = False
map_res@tmXBLabelFontHeightF = 0.015
map_res@tmXBMajorLengthF = 0.005
    
map_res@gsnDraw = False
map_res@gsnFrame = False
map_res@gsnAddCyclic  = False  
map_res@gsnMaximize = True
;map_res@gsnRightString = ""
;res@gsnLeftString   = leftstring
map_res@gsnPaperOrientation = "landscape"
   

char = stringtocharacter(filename)
date = charactertostring(char(0:11))
;map_res@gsnRightString = "100702" + " - " + "100705" ;设置绘图右肩标注，加上起止时间;+"UTC"
map_res@gsnRightString = date
map_res= wrf_map_resources(f1, map_res)
    

;res@pmTickMarkDisplayMode = "Always"
;res@mpProjection        = "CylindricalEquidistant"
;res@mpProjection        = "LambertConformal"
;res@mpLambertParallel1F = 25.
; res@mpLambertParallel2F = 45.
;res@mpLambertMeridianF  = 110.
map_res@cnFillOn = True
map_res@cnLinesOn = False
map_res@cnLineLabelsOn = False ;等值线数值是否显示
;res@cnFillPalette = "gsltod"
;res@cnFillPalette = "topo_15lev"    
map_res@cnLevelSelectionMode  = "ExplicitLevels"
map_res@cnLevels              = ispan(400,1600,400)   
cmap1 = read_colormap_file("gsltod") ;choose colormap
;res@cnFillPalette = "MPL_YlOrBr"
cmap2 = cmap1(2:25,:) 
cmap2(0,3) = 0.0
map_res@cnFillPalette         = cmap2
map_res@cnFillDrawOrder = "Predraw"
   
;res@cnFillMode = "RasterFill"
map_res@cnFillOpacityF = 1 ;填色透明度
    
map_res@tmXTOn = False
map_res@tmYROn = False
map_res@tmXBLabelFontHeightF = 0.015
map_res@tmXBMajorLengthF = 0.005
;res@tmXBMode              = "Explicit"
;res@tmXBValues            = fspan(118.5,123,5)
;res@tmXBLabels            = res@tmXBValues 
;res@tmXBLabels            = (/"120.5~S~o~N~E","120.7~S~o~N~E","120.9~S~o~N~E","121.1~S~o~N~E","121.3~S~o~N~E","121.3~S~o~N~E"/)  
map_res@tmYLLabelFontHeightF  = 0.02

map_res@lbLabelBarOn = True  ;是否开刻度表
; res@lbOrientation            = "Vertical"     ; vertical label bar
map_res@lbOrientation            = "Horizontal"     ; vertical label bar
map_res@lbTopMarginF = 0.0
map_res@lbBottomMarginF = 0.0
map_res@lbLabelFontHeightF = 0.01
map_res@lbTitlePosition = "Left"
map_res@lbTitleAngleF = 90
map_res@lbTitleFontHeightF = 0.01
map_res@lbTitleDirection = "Across"
map_res@lbTitleJust = "TopRight"

map_res@pmLabelBarWidthF = 0.6 ;default 0.15 ;宽度
map_res@pmTickMarkDisplayMode = "Conditional"
;res@pmTickMarkDisplayMode = "Always"
map_res@pmLabelBarOrthogonalPosF = 0.01
map_res@pmTickMarkDisplayMode = "Always"

    ;res@tmYLMode              = "Explicit"
    ;res@tmYLValues            = fspan(27,31.5,5)
   ;res@tmYLLabels            = res@tmYLValues
    ;res@tmYLLabels            = (/"28.5~S~o~N~N","28.7~S~o~N~N","28.9~S~o~N~N","29.1~S~o~N~N","29.3~S~o~N~N","29.3~S~o~N~N"/)
   

 ;plot_map = gsn_csm_map(wks, res)
plot_map = gsn_csm_contour_map(wks, hgt, map_res)
;plot_map = gsn_csm_map(wks, map_res)
;plot_hgt = gsn_csm_contour(wks, data, map_res) 

    ;plot_rain = gsn_csm_contour(wks,orainhr,rain_res)
    ;overlay(plot_map,plot_rain)

    
    ;******************************************************************************
    ;set rain_res
    ;******************************************************************************
    ;rain_res = True
    rain_res = False

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
    
    rain_res@cnInfoLabelOn = False  ;等值线小文字不显示
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


   ; send graphics to PNG file




  res  = True                             ; plot mods desired
    res@gsnDraw = False
    res@gsnFrame = False
  ;res@mpMinLonF          = -150           ; choose a subregion
  ;res@mpMaxLonF          = 20.

  res@stMinArrowSpacingF = 0.01          ; arrow spacing.
  res@stArrowLengthF     = 0.005           ; changes the size of the arrows.
  res@stLineThicknessF   = 2           ; changes the line thickness
  res@stLineColor        = "black"       ; changes color
  res@stMinDistanceF       = 0.06
  plot = gsn_csm_streamline(wks,u,v,res)
;;;;draw the name of city   
    tres                        = True
    tres@txFontHeightF          = 0.015
    tres@txBackgroundFillColor  = -1
    tres@txFontColor            = "dimgray"
    ;plat = (/28.83,27.7,28.2,29.2,29,30,29.8,29.8,30.8,30.6/)
    ;plon = (/121,120.2,119.5,119.9,118.7,119.5,120.6,121.5,120,120.7/)
    ;times = (/"TaiZhou","WenZhou","LiShui","JinHua","QuZhou","HangZhou","ShaoXing","NingBo","HuZhou","JiaXing"/)
    ;do p=0,9
     ; gsn_text(wks,plot_map,times(p),plon(p),plat(p),tres)
   ; end do  
    a1 = gsn_add_text(wks, plot_map, "TaiZhou", 121, 28.83,  tres)
    a2 = gsn_add_text(wks, plot_map, "WenZhou", 120.2, 27.7,  tres)
    ;a3 = gsn_add_text(wks, plot_map, "LiShui", 119.5, 28.2,  tres)
    ;a4 = gsn_add_text(wks, plot_map, "JinHua", 119.9, 29.2,  tres)
    ;a5 = gsn_add_text(wks, plot_map, "QuZhou", 118.7, 29,  tres)
    a6 = gsn_add_text(wks, plot_map, "HangZhou", 119.5, 30,  tres)
    a7 = gsn_add_text(wks, plot_map, "ShaoXing", 120.6, 29.8,  tres)
    a8 = gsn_add_text(wks, plot_map, "NingBo", 121.5, 29.8,  tres)
    a9 = gsn_add_text(wks, plot_map, "HuZhou", 120, 30.8,  tres)
    b1 = gsn_add_text(wks, plot_map, "JiaXing", 120.7, 30.6, tres)

lnres = True
shp = "/public/home/xueyu/wrf/fitow/dixing/CHN_adm2.shp"
lnres@gsLineThicknessF = 3
lnres@gsLineColor = "grey60"
ditu = gsn_add_shapefile_polylines(wks, plot_map, shp, lnres)





    


;plot_rain = gsn_csm_contour(wks,orainhr,rain_res)
;plot_rain = gsn_csm_contour(wks,rainall,rain_res)




;plotrain = gsn_csm_contour_map(wks,orainhr,res)
;delete(res)
;draw(plotrain)
;frame(wks)



;plot_rain = gsn_csm_contour(wks,orainhr,rain_res)
;plot_rain = gsn_csm_contour(wks,rainall,rain_res)
overlay(plot_map,plot)
draw(plot_map)
frame(wks)


;plotrain = gsn_csm_contour_map(wks,orainhr,res)
;delete(res)
;draw(plotrain)
;frame(wks)

delete(str)
delete(lon)
delete(lat)
;delete(rainhr)
delete(wspd)
delete(wdir)
delete(u1)
delete(v1)

 end do


end
