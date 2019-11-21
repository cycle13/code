load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

path = "/public/home/xingshuqiang/data/SEVP/13~20/"
;filename = "SEVP_CLI_CHN_MERGE_CMP_PRE_HOUR_GRID_0.10-2010061513.grd"
files = systemfunc("ls -1 "+path); 204 datafiles
print(files)
    ;setfileoption("bin", "ReadByteOrder", "BigEndian")
dat = new((/204,440,700/), "float")
sdat = new((/440,700/), "float")
sdat = 0.
do i = 1,204
    dat0 = fbindirread(path+files(i-1), 0, (/2,440,700/), "float")
    dat0@_FillValue = -999.
    dat(i-1,:,:) = dat0(0,:,:)
    ;25-48
end do
    dat!0 = "time"
    dat!1 = "lat"
    dat!2 = "lon" 

;plot = new(84,graphic)
    dat&time = ispan(1, 204, 1)
    dat&lat = fspan(15.05, 15.05+439*0.1, 440)
    dat&lon = fspan(70.05, 70.05+699*0.1, 700)
    dat@_FillValue = -999.
    dat&lat@units = "degree_north"
    dat&lon@units = "degree_east"
    dat@units     = "units:mm"
do i = 156, 179
    sdat(:,:) = sdat(:,:)+dat(i,:,:)
end do
    ;
    sdat!0 = "lat"
    sdat!1 = "lon"

    sdat&lat = fspan(15.05, 15.05+439*0.1, 440)
    sdat&lon = fspan(70.05, 70.05+699*0.1, 700)
    sdat@_FillValue = -999.
    sdat&lat@units = "degree_north"
    sdat&lon@units = "degree_east"
    ;sdat@units     = "units:mm"
    ;-----------------------------------------------------
    

    f0 = addfile("/public/home/xingshuqiang/out/CTL/wrfout_d03_2010-06-18_18:00:00.nc","r")
    rain_exp = wrf_user_getvar(f0,"RAINNC",-1)
    rain_con = wrf_user_getvar(f0,"RAINC",-1)
    rain_tot = rain_exp + rain_con
    rain_tot_24 = rain_tot(30,:,:) - rain_tot(6,:,:)


    maxlat_region = 29
    minlat_region = 26
    maxlon_region = 121
    minlon_region = 116

    plot = new(2, graphic)
    print("now let's begin to draw")


    wks = gsn_open_wks("ps", "figure1")
    
    res = True

    res@gsnDraw   = False
    res@gsnFrame  = False
    res@gsnMaximize = True
    ;res@mpProjection = "LambertConformal"
    ;res@mpLambertMeridianF = 110.
    ;res@mpLimitMode = "LatLon"
    ;res@mpLambertParallel1F = .001      ;Default: .001 ;可以自己改一改
    ;res@mpLambertParallel2F = 89.999
    ;res@mpMaxLatF = 35
    ;res@mpMinLatF = 20
    ;res@mpMaxLonF = 125
    ;res@mpMinLonF = 110
    res = wrf_map_resources(f0, res)
    res@tfDoNDCOverlay = True ; necessary for correct overlay on map 
    res@mpOutlineBoundarySets = "AllBoundaries" 
    res@mpDataSetName = "Earth..4" ; Gives us provincial boundaries 
    res@mpGeophysicalLineThicknessF = 1.5 ; thickness of map outlines 
    res@mpProvincialLineThicknessF = 2. 
    res@mpProvincialLineColor = "Gray"
    res@mpGridAndLimbOn = True
    res@mpGridLatSpacingF = 10
    res@mpGridLonSpacingF = 10
    
    ;res@gsLineDashPattern = 1
    res@mpGridLineThicknessF = 1 
    res@pmTickMarkDisplayMode = "Always"
    res@tmXBLabelFontHeightF = 0.018 
    res@tmYLLabelFontHeightF = 0.018 
    res@tmYLLabelStride = 2 ; label every other tickmark 
    res@tmXBLabelStride = 2 ;---Point the tickmarks inward 
    res@tmYRMajorOutwardLengthF = 0 
    res@tmYLMajorOutwardLengthF = 0 
    res@tmXBMajorOutwardLengthF = 0 
    res@tmXBMinorOutwardLengthF = 0 
    res@tmXTOn = True 
    res@tmYROn = True 
    res@tmYRLabelsOn = False 
    res@tmXTLabelsOn = False


    res@cnFillOn = True
    cmap := read_colormap_file("BlAqGrYeOrReVi200") 
    cmap(0,:) = (/0,0,0,0/) ; make first color fully transparent
    res@cnFillPalette = cmap 
    res@cnLinesOn = False ; turn off contour lines 
    res@cnLineLabelsOn = False ; turn off contour labels 
    res@cnFillOpacityF = 1. ; .85 
    ;res@tfDoNDCOverlay = True ; necessary for correct overlay on map 
    res@cnLevelSelectionMode="ExplicitLevels"
    res@cnLevels            =(/0.1,5,10,25,50,75,100,125,150,175,200,250,300,350/)*1.0
    res@lbLabelBarOn = False
    ;res@cnInfoLabelOn = True 
    ;res@cnInfoLabelString = "Min= $ZMN$ Max= $ZMX$" 
    ;res@cnInfoLabelOrthogonalPosF = -0.104 ; move info label into plot 

    plot(0) = gsn_csm_contour_map(wks, sdat(48:200,397:550), res)
    plot(1) = gsn_csm_contour_map(wks, rain_tot_24, res)
    res_line = True
    res_line@gsLineColor = "black"
    res_line@gsLineDashPattern = 0
    res_line@gsLineThicknessF = 2
    line1 = gsn_add_polyline(wks, plot(0), (/116,116,121,121,116/), (/26,29,29,26,26/), res_line)
    line2 = gsn_add_polyline(wks, plot(1), (/116,116,121,121,116/), (/26,29,29,26,26/), res_line)
    ;*****************************************************************

    pres = True
    ;pres@lbOrientation = "Vertical"
    pres@pmLabelBarHeightF = 0.08 ; Make labelbar less thick 
    pres@lbLabelFontHeightF = 0.014 
    pres@pmLabelBarOrthogonalPosF = -0.008 
    pres@gsnPanelLabelBar = True
    pres@gsnPanelFigureStrings = (/"A","B"/)
    pres@amJust = "TopLeft"
    gsn_panel(wks, plot, (/1,2/), pres) 

end  

