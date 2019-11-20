load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"  ;加载wrf脚本
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/ut_string.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
begin


path = "/public/home/xueyu/wrf/fitow/GFSdata/data2/"
filenames = systemfunc("cd /public/home/xueyu/wrf/fitow/GFSdata/data2/;ls GFS_Global*.grib2")
nfiles = dimsizes(filenames)
print(nfiles)
pl = (/"20130620","20130702","20130708","20130714"/)


   do i=0,3
   print(filenames(i))
 
    fnl  = addfile(path+filenames(i),"r") ;open file
     printVarSummary(fnl)
    lev1 = fnl->lv_ISBL8
     lev = fnl->lv_ISBL0
     print(lev1)
     print(lev)
    ui := fnl->UGRD_P0_L100_GLL0({85000},:,:)  ; 850hPa
    vi := fnl->VGRD_P0_L100_GLL0({85000},:,:)  ; 850hPa
    hgt = fnl->HGT_P0_L100_GLL0({85000},:,:)   ; 850hPa
    vp= fnl->VVEL_P0_L100_GLL0({85000},:,:)   ; 850hPa
    rh = fnl->RH_P0_L100_GLL0({85000},:,:)    ; 850hPa
 tmp= fnl->TMP_P0_L100_GLL0({85000},:,:) 
  tmp1 = tmp-273.15
     tmp1!0 = "lat"
     tmp1!1= "lon"
     tmp1&lat=tmp&lat_0
     tmp1&lon=tmp&lon_0 



;******************* open a workspace *********
   wks  =  gsn_open_wks("png","vp 500hPa"+pl(i))


;******************caculate the vorticity *******************
ui@_FillValue=1e+20
vi@_FillValue=1e+20
wspd := ui
wspd = (/ sqrt(ui^2+vi^2) /)
ui = ui * 2.5
vi = vi * 2.5
wspd!0 = "lat"
wspd!1 = "lon"
wspd&lat=tmp&lat_0
wspd&lon=tmp&lon_0

   
ui!0 = "lat"
ui!1 = "lon"
ui@_FillValue = 9999
ui&lat = tmp&lat_0
ui&lon = tmp&lon_0
vi!0 = "lat"
vi!1 = "lon"
vi@_FillValue = 9999
vi&lat = tmp&lat_0
vi&lon = tmp&lon_0   


dv=uv2dv_cfd(ui,vi,tmp&lat_0,tmp&lon_0,0)*10000
  dv!1="lon"
  dv!0="lat"
  dv&lat=tmp&lat_0
  dv&lon=tmp&lon_0

    ;scale = 1.e05
    ;vrt= ui
    ; vrt= uv2vrG_Wrap(ui,vi)*1.e05
    ;vrt@long_name = "vorticity"
    ; vrt@unit      = "scaled"

 
    ; vrt!0 = "lat"
    ; vrt!1= "lon"
     ;vrt&lat=ui&lat_0
     ;vrt&lon=ui&lon_0


;***********************  set the parameter of pic  ***********

;***********************  draw  temperature(bar) ***********************
        res = True
        res@gsnDraw              = False              ; don't draw
        res@gsnFrame             = False
        res@gsnAddCyclic          = False
        res@gsnMaximize = False
     ;***************  set map  ******************
        res@gsnPaperOrientation   = "landscape"
        res@mpMinLatF             =  25
        res@mpMaxLatF             =  35
        res@mpMinLonF             =  115
        res@mpMaxLonF             =  125
        res@mpOutlineOn           =  True
        res@mpFillOn              =  False
       
        res@mpDataSetName         = "Earth..4"
        res@mpDataBaseVersion     = "MediumRes"
        res@mpOutlineOn           = True
        res@mpOutlineSpecifiers   = (/"China:states","Taiwan"/)
     ; ************ set the appearance ********
        ;res@tmXBLabelFontHeightF  = 0.015
        ;res@tmXBMajorLengthF      = 0.007
        ;res@tiMainString          = pl(i)
        res@tmYROn                = False   
        res@tmXTOn                = False
        res@gsnLeftString         = ""
        res@gsnRightString        = ""
        ;res@mpProjection        = "LambertConformal"
        ;res@mpLambertParallel1F = 25.
        ;res@mpLambertParallel2F = 45.
        ;res@mpLambertMeridianF  = 115.
        res@mpLimitMode = "LatLon"
        res@pmTickMarkDisplayMode = "Conditional"
        plot = gsn_csm_map(wks,res)
     ; *************** set contour ************
        res1 = True
        res1@gsnDraw              = False              ; don't draw
        res1@gsnFrame             = False
        res1@gsnAddCyclic          = False
        res1@gsnLeftString         = ""
        res1@gsnRightString        = ""

        res1@cnFillOn              = False
        res1@cnLineLabelsOn        = True
        res1@cnLineLabelBackgroundColor = -1
        res1@cnLinesOn             = True 
        res1@cnLineColor  = "red" 
        res1@cnLineThicknessF = 4
        res1@cnLevelSpacingF = 4
        res1@cnLevelSelectionMode  = "ManualLevels"
       ;res1@cnLevels=(/15,16,17,18,19,20,21,22,23,24,25/)
        res1@cnInfoLabelOn       = False
        res1@cnLineDashPattern =      2
        tmp1 = smth9(tmp1,0.5,0.25,False) 
      plot1 = gsn_csm_contour(wks,tmp1,res1)
      ;plot = gsn_csm_map(wks,res)
       ;plot6 = gsn_csm_contour(wks,wspd,res)
     ; *************** set barb ***************
     

         res6  =   True
         res6@gsnDraw              = False              ; don't draw
         res6@gsnFrame             = False
         res6@gsnAddCyclic          = False
         res6@gsnLeftString         = ""
         res6@gsnRightString        = ""
         res6@cnLineColor           = "Black"
         res6@cnLinesOn             = True
         res6@cnFillOn              = False
         res6@cnLineThicknessF      = 5
         res6@cnLineLabelsOn        = True
         res6@cnLevelSelectionMode ="ManualLevels"
         res6@gsnLeftString = ""
        res6@gsnRightString = ""
        res6@cnInfoLabelOn = False
         ;res@cnMinLevelValF =100.0
         ;res@cnMaxLevelValF =6000.0
         res6@cnLevelSpacingF= 20
         res6@cnInfoLabelOn         = False  
          
;res@cnLevels=(/1400,1420,1430,1440,1450,1460,1470,1480,1490,1500/)
        hgt = smth9(hgt,0.5,0.25,False)  
       ;plot6 = gsn_csm_contour(wks,hgt,res6)




tress   = True
tress@gsnDraw      =  False
tress@gsnFrame     =  False
tress@cnInfoLabelOn = False
tress@cnFillOpacityF = 60
tress@cnFillOn              =   True
cmaprh1  = read_colormap_file("BlueRed")
cmaprh2 = cmaprh1(128:238,:) 
cmaprh2(0,3) = 0.0
;res@cnLineColor           = "red"
tress@cnFillPalette = cmaprh2
tress@cnLinesOn             =   False
tress@gsnContourZeroLineThicknessF  = 5.
tress@gsnContourNegLineDashPattern  = 1
tress@cnLineThicknessF              = 5
;res@cnLevelSelectionMode  ="ManualLevels"
tress@cnMinLevelValF                = 0
tress@cnMaxLevelValF                = 10.0
tress@cnLevelSpacingF               = 2.0
tress@cnLevelSelectionMode  =  "ExplicitLevels"
tress@cnLevels              = (/2,4,6,8,10/)
tress@cnSmoothingOn  = True
tress@cnSmoothingTensionF = -0.0015
tress@cnSmoothingOn  = True 
tress@cnSmoothingDistanceF = 0.005
tress@cnSmoothingTensionF = 0.01
tress@cnConstFLabelOn         = False
tress@gsnLeftString         = ""
tress@gsnRightString        = "" 
tress@cnLineLabelsOn = False
tress@lbLabelBarOn           = False
tress@lbLabelFontHeightF      =0.015
tress@lbLabelBarOn = True  ;是否开刻度表
tress@lbOrientation            = "Vertical"     ; vertical label bar
tress@lbTitleDirection = "Across"
tress@lbTitleJust = "TopRight"   
;plot5 = gsn_csm_contour(wks,dv,tress) 
    
   
        res3 = True
        res3@gsnDraw               = False              ; don't draw
        res3@gsnFrame              = False
        res3@gsnAddCyclic          = False
        res3@gsnLeftString         = ""
        res3@gsnRightString        = ""
        res3@gsnLeftString         = ""
        res3@vcRefMagnitudeF       = 30.
        res3@vcRefLengthF          = 0.03
        res3@vcGlyphStyle          = "windBarb"
        res3@vcMinDistanceF        = 0.05
        res3@vcRefAnnoString1      = "12m/s"
        res3@vcRefAnnoOn           = False
        res3@vcWindBarbLineThicknessF= 4.0 
      ;plot11 = gsn_csm_vector(wks,ui(::2,::2),vi(::2,::2),res3)
     plot11 = gsn_csm_vector(wks,ui,vi,res3)
  
 
res2 =  True
res2@cnFillOn              =True
res2@cnLinesOn             = False
res2@cnLineColor = "red"
res2@cnLineThicknessF = 8
res2@gsnDraw               = False              ; don't draw
res2@gsnFrame              = False
res2@gsnAddCyclic          = False
res2@gsnLeftString         = ""
res2@gsnRightString        = ""     
res2@cnLineLabelsOn = False ;等值线数值是否显示
res2@cnInfoLabelOn = False  
;res2@cnLevelSelectionMode  = "ExplicitLevels"
res2@cnLevelSelectionMode  = "ManualLevels"
;res2@cnLevels = (/16.0/)
res2@cnMinLevelValF        = 15
;res2@cnMaxLevelValF        = 70.0
;res2@cnLevelSpacingF       = 4.0
;res@cnFillPalette         = "GreenYellow"
;res@cnLineColor           = "red"
cmap2=read_colormap_file("MPL_PuBuGn")
res2@cnFillPalette  = cmap2
cmap2(0,3) = 0.0
;cmaprh                    = read_colormap_file("/public/home/xueyu/wrf/fitow/cmorphzdzmix/mypr_ZJ500.rgb")
;res2@cnLineColor           = cmap2
res2@cnLineThicknessF      = 3
;plot3 = gsn_csm_contour(wks,wspd,res2)


;Speed_res = True                   ;风速场属性
;Speed_res@cnLevelSelectionMode = "ManualLevels"
;Speed_res@cnMinLevelValF = 20
;Speed_res@cnMaxLevelValF = 60
;Speed_res@cnLevelSpacingF = 4
;Speed_res@cnFillOn = True
;Speed_res@cnFillPalette = "MPL_Purples"
;Speed_res@cnLinesOn = False
;Speed_res@cnLineLabelsOn = False
;Speed_res@cnSmoothingTensionF = 0.001
;Speed_res@gsnLeftString = ""
;Speed_res@gsnRightString = ""
;Speed_res@cnInfoLabelOn = False
;Speed_res@lbLabelBarOn = True
;Speed_res@lbOrientation = "horizontal"
;Speed_res@lbLeftMarginF = 0.0
;Speed_res@lbRightMarginF = 0.0
;Speed_res@lbLabelFontHeightF = 0.01
;Speed_res@lbTitleString = "wind speed(m/s)"
;Speed_res@lbTitleFontHeightF = 0.01
;Speed_res@lbTitlePosition = "Bottom"
;Speed_res@lbTitleJust = "CenterRight"
;Speed_res@pmLabelBarOrthogonalPosF = 0.05
;Speed_res@gsnLeftString = ""
;Speed_res@gsnRightString = ""
;Speed_res@gsnAddCyclic = False
;Speed_res@gsnDraw = False
;Speed_res@gsnFrame = False
;plot_Speed = gsn_csm_contour(wks, wspd, Speed_res)



RH_res = True              
;RH_res@cnFillOn              = False
RH_res@cnLineLabelsOn        = False
RH_res@cnLinesOn             = False  
RH_res@cnLevelSelectionMode = "ManualLevels"
RH_res@cnMinLevelValF = -2.5
RH_res@cnMaxLevelValF = 0
RH_res@cnLevelSpacingF = 0.5
;RH_res@cnLineDashPattern = 3
;RH_res@cnLineThicknessF = 3.0
;RH_res@gsnContourZeroLineThicknessF = 8.0
;RH_res@cnLineLabelPlacementMode = "Computed"
;RH_res@cnLabelMasking = True
;RH_res@cnLineLabelFontColor = "blue"


RH_res@cnInfoLabelOn = False
RH_res@cnSmoothingOn  = True
RH_res@cnSmoothingTensionF = 0.0001
;RH_res@cnLineColor = "blue"

RH_res@gsnLeftString = ""
RH_res@gsnRightString = ""
RH_res@gsnAddCyclic = False
RH_res@gsnDraw = False
RH_res@gsnFrame = False
vp = smth9(vp,0.5,0.25,False) 

RH_res@cnFillOn = True
cmarph = read_colormap_file("precip3_16lev")

;cmarph(0,3) = 0
RH_res@cnFillPalette = cmarph

RH_res@lbLabelBarOn = True  ;是否开刻度表
RH_res@lbOrientation            = "Vertical"     ; vertical label bar
;RH_res@lbOrientation            = "Horizontal"     ; vertical label bar
;RH_res@lbTopMarginF = 0.0
;RH_res@lbBottomMarginF = 0.0
;RH_res@lbLabelFontHeightF = 0.01
;RH_res@lbTitlePosition = "Left"
;RH_res@lbTitleAngleF = 40
;RH_res@lbTitleFontHeightF = 0.01
;RH_res@lbTitleDirection = "Across"
RH_res@lbTitleJust = "TopRight"


 plot3 = gsn_csm_contour(wks,vp,RH_res)
overlay(plot,plot3)
;overlay(plot,plot6)
overlay(plot,plot11)
;overlay(plot,plot1)



draw(plot)
frame(wks)
end do

end
