; Overlay information from 2 domains
; November 2009

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"

begin

  wks = gsn_open_wks("ps", "wrf_overlay_doms")  ; Open graphics file

  d1 = addfile("/public/home/xingshuqiang/run/19_1/met_em.d01.2010-06-18_12:00:00.nc", "r")
  d2 = addfile("/public/home/xingshuqiang/run/19_1/met_em.d02.2010-06-18_12:00:00.nc", "r")
  d3 = addfile("/public/home/xingshuqiang/run/19_1/met_em.d03.2010-06-18_12:00:00.nc", "r")

  var1 = wrf_user_getvar(d1,"HGT_M",0)
  lat1 = wrf_user_getvar(d1,"XLAT",0)
  lon1 = wrf_user_getvar(d1,"XLONG",0)
  var2 = wrf_user_getvar(d2,"HGT_M",0)
  lat2 = wrf_user_getvar(d2,"XLAT",0)
  lon2 = wrf_user_getvar(d2,"XLONG",0)
  var3 = wrf_user_getvar(d3,"HGT_M",0)
  lat3 = wrf_user_getvar(d3,"XLAT",0)
  lon3 = wrf_user_getvar(d3,"XLONG",0)
  var1@lat2d = lat1
  var1@lon2d = lon1
  var2@lat2d = lat2
  var2@lon2d = lon2
  var3@lat3d = lat3
  var3@lon3d = lon3
  dom_dims = dimsizes(var1)
  dom_rank = dimsizes(dom_dims)
  nx1 = dom_dims(dom_rank - 1) - 1
  ny1 = dom_dims(dom_rank - 2) - 1
  dom_dims = dimsizes(var2)
  dom_rank = dimsizes(dom_dims)
  nx2 = dom_dims(dom_rank - 1) - 1
  ny2 = dom_dims(dom_rank - 2) - 1
  dom_dims = dimsizes(var3)
  dom_rank = dimsizes(dom_dims)
  nx3 = dom_dims(dom_rank - 1) - 1
  ny3 = dom_dims(dom_rank - 2) - 1

  res                 = True

; Set some contouring resources.
  res@cnFillOn        = True
  res@cnLinesOn       = False
  res@cnLineLabelsOn  = False
  res@cnInfoLabelOn   = False
  ;res@gsnSpreadColors = True
  res@cnLevelSelectionMode = "ExplicitLevels"
  ;res@cnFillPalette = "gsltod" 
  res@cnLevels             = (/0, 10, 25, 50, 75, 125, 200, 350, 500, 750, \
                                1000, 1250, 1500, 1750, 2000, 2250, 3000/)
  res@gsnLeftString = ""
  res@gsnRightString = ""

  res@gsnDraw         = False
  res@gsnFrame        = False

  res2 = res

; Add map resources
  res@mpDataBaseVersion     = "MediumRes"          ; Default is LowRes
  res@mpOutlineDrawOrder    = "PostDraw"           ; Draw map outlines last
  res@mpGridAndLimbOn       = True                 ; Turn off lat/lon lines
  res@pmTickMarkDisplayMode = "Always"             ; Turn on map tickmarks
  res = set_mp_wrf_map_resources(d1,res)
  res@mpLimitMode        = "Corners"               ; Portion of map to zoom
  res@mpLeftCornerLatF   = lat1(0,0)
  res@mpLeftCornerLonF   = lon1(0,0)
  res@mpRightCornerLatF  = lat1(ny1,nx1)
  res@mpRightCornerLonF  = lon1(ny1,nx1)

; Add label bar resources
  res@lbLabelAutoStride = True
  res@gsnMaximize     = True    ; Maximize plot in frame


  res2@lbLabelBarOn = False  ; Labelbar already created in 1st plot
  res2@gsnMaximize  = False  ; Use maximization from original plot
res3 = res
    res3@lbLabelBarOn = False  ; Labelbar already created in 1st plot
  res3@gsnMaximize  = False  ; Use maximization from original plot
  
; we need these to later draw boxes for the location of the nest domain
  xbox_out = new(5,float)
  ybox_out = new(5,float)
  lnres = True
  lnres@gsLineThicknessF  = 2.5
  xbox2_out = new(5,float)
  ybox2_out = new(5,float)
  lnres2 = True
  lnres2@gsLineThicknessF  = 2.5
    xbox3_out = new(5,float)
  ybox3_out = new(5,float)
  lnres3 = True
  lnres3@gsLineThicknessF  = 2.5
  lnres3@gsLineDashPattern = 1
; make images
  map = gsn_csm_contour_map(wks, var1, res)
  plot = gsn_csm_contour(wks, var2, res2)
plot = gsn_csm_contour(wks, var3, res3)

; let's make 3 plots
; 1 - the mother domain only
; 2 - the mother and nest domains
; 3 - same as 2, but add a box around domain 2


; PLOT 1
;  draw(map)
 ; frame(wks)

; PLOT 2
 ; overlay (map, plot)
 ; draw(map)
 ; frame(wks)

; PLOT 3
  draw(map)   ; domain 2 already overlaid here - so just draw again
  xbox = (/lon2(0,0),lon2(0,nx2),lon2(ny2,nx2),lon2(ny2,0),lon2(0,0)/)
  ybox = (/lat2(0,0),lat2(0,nx2),lat2(ny2,nx2),lat2(ny2,0),lat2(0,0)/)
  datatondc(map, xbox, ybox, xbox_out, ybox_out)
  gsn_polyline_ndc(wks, xbox_out, ybox_out, lnres)
    xbox2 = (/lon3(0,0),lon3(0,nx3),lon3(ny3,nx3),lon3(ny3,0),lon3(0,0)/)
  ybox2 = (/lat3(0,0),lat3(0,nx3),lat3(ny3,nx3),lat3(ny3,0),lat3(0,0)/)
  datatondc(map, xbox2, ybox2, xbox2_out, ybox2_out)
  gsn_polyline_ndc(wks, xbox2_out, ybox2_out, lnres2)

  tres = True
  tres@txFontColor = "black"
  tres@txFontHeightF = 0.018
  tres@txFontThicknessF = 1
  gsn_text_ndc(wks, "d01", 0.21, 0.29, tres)
  gsn_text_ndc(wks, "d02", 0.395, 0.37, tres)
  gsn_text_ndc(wks, "d03", 0.52, 0.45, tres)
  ;    xbox3 = (/lon3(110,7),lon3(110,nx3-50),lon3(ny3-7,nx3-50),lon3(ny3-7,7),lon3(110,7)/)
  ;ybox3 = (/lat3(110,7),lat3(110,nx3-50),lat3(ny3-7,nx3-50),lat3(ny3-7,7),lat3(110,7)/)
  ;datatondc(map, xbox3, ybox3, xbox3_out, ybox3_out)
  ;gsn_polyline_ndc(wks, xbox3_out, ybox3_out, lnres3)
  frame(wks)

end
