;*************************************************
; bar_16.ncl
;
; Concepts illustrated:
;   - Creating a blank plot
;   - Drawing stacked bar plots
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"

begin
  cities = (/"part1","part2","part3"/)

  ncities = dimsizes(cities)

  d1 = (/0.2467,0.1856,0.2853/)
  d2 = (/0.3675,0.3875,0.4683/)
  d3 = (/0.3850,0.4142,0.2434/)
  d4 = (/0.0008,0.0127,0.0031/)


  wks = gsn_open_wks("x11","bar")  ; send graphics to PNG file
;
; Set resources for blank plot. Be sure to set axes limits
; that represent d that will be added later via polygons.
;
  res                          = True

  res@gsnMaximize              = True    ; Maximize plot in frame
  res@gsnDraw                  = False   ; Don't draw
  res@gsnFrame                 = False   ; Don't advance frame

  res@vpWidthF                 = 0.3     ; Make long and
  res@vpHeightF                = 0.9     ; narrow

;---Set axes limits. Add extra space for X max.
  res@trYMinF                  = 0.0
  res@trYMaxF                  = 1.2  
  res@trXMinF                  = 0
  res@trXMaxF                  = ncities + 1


;---Put city labels on X axis
  res@tmXBMode                 = "Explicit"
  res@tmXBValues               = ispan(1,ncities,1)
  res@tmXBLabels               = cities
  res@tmXBLabelJust            = "BottomCenter"

  res@gsnScale                 = True    ; Make labels on axes same size


;--Turn off X axis tickmarks
  res@tmXBMajorLengthF         = 0.
  res@tmXBMajorOutwardLengthF  = 0.  
  res@tmYLMajorLengthF         = 0.01
  res@tmYLMajorOutwardLengthF  = 0.01

  res@tmXTOn                   = False   ; Turn off top tickmarks
  ;res@gsnYRefLine              = 1.0
  ;res@gsnYRefLineDashPattern   = 2


;---Create blank plot without Y grid lines
  plot_without_xgrid = gsn_csm_blank_plot(wks,res)

;---Create blank plot with Y grid lines
  res@tmYMajorGrid                = True    ; Turn on grid lines
  res@tmYMajorGridLineDashPattern = 2       ; Dashed lines
  res@tmYMajorGridThicknessF      = 1.0     ; default is 2 (?)
  res@tiMainString                = "vTFM"
  plot_with_xgrid = gsn_csm_blank_plot(wks,res)

;---Arrays to hold the bar values and the bars themselves.
  dum1 = new(ncities,graphic)
  dum2 = new(ncities,graphic)
  dum3 = new(ncities,graphic)
  dum4 = new(ncities,graphic)

;---Set some resources for the bars.
  bres           = True
  bres@gsEdgesOn = True      ; Outline the polygons (bars)
;
; Loop through each city and attach bar to plot that
; doesn't have grid lines.

  do i=1,ncities
    bres@gsFillColor           = "red"
      
    ybar      = (/0,d1(i-1),d1(i-1),0,0/)
    xbar      = (/i-0.25,i-0.25,i+0.25,i+0.25,i-0.25/)
    dum1(i-1) = gsn_add_polygon(wks,plot_without_xgrid,xbar,ybar,bres)

    bres@gsFillColor          = "blue"
    
    ybar      = (/d1(i-1),d2(i-1)+d1(i-1),d2(i-1)+d1(i-1),d1(i-1),d1(i-1)/)
    dum2(i-1) = gsn_add_polygon(wks,plot_without_xgrid,xbar,ybar,bres)
    
    bres@gsFillColor          = "green"

    ybar      = (/d1(i-1)+d2(i-1),d3(i-1)+d2(i-1)+d1(i-1),\
                  d3(i-1)+d2(i-1)+d1(i-1),d1(i-1)+d2(i-1),\
                  d1(i-1)+d2(i-1)/)
    dum3(i-1) = gsn_add_polygon(wks,plot_without_xgrid,xbar,ybar,bres)
 
    
    bres@gsFillColor          = "orange"

    ybar      = (/d1(i-1)+d2(i-1)+d3(i-1),d4(i-1)+d3(i-1)+d2(i-1)+d1(i-1),\
                  d4(i-1)+d3(i-1)+d2(i-1)+d1(i-1),d1(i-1)+d2(i-1)+d3(i-1),\
                  d1(i-1)+d2(i-1)+d3(i-1)/)
    dum4(i-1) = gsn_add_polygon(wks,plot_without_xgrid,xbar,ybar,bres)

end do
    cres           = True
    cres@gsEdgesOn = True 
    cres@gsFillColor           = "red"
    ybar      = (/1.14,1.16,1.16,1.14,1.14/)
    xbar      = (/0.3,0.3,1.3,1.3,0.3/)
    pm1 = gsn_add_polygon(wks,plot_without_xgrid,xbar,ybar,cres)
    txres = True
    txres@txFontHeightF = 0.010
    tx1 = gsn_add_text(wks, plot_without_xgrid, "hTFM", 1.75, 1.15, txres)

    cres@gsFillColor           = "blue"
    ybar      = (/1.14,1.16,1.16,1.14,1.14/)
    xbar      = (/2.3,2.3,3.3,3.3,2.3/)
    pm2 = gsn_add_polygon(wks,plot_without_xgrid,xbar,ybar,cres)
    tx2 = gsn_add_text(wks, plot_without_xgrid, "htFM", 3.75, 1.15, txres)

    cres@gsFillColor           = "green"
    ybar      = (/1.11,1.13,1.13,1.11,1.11/)
    xbar      = (/0.3,0.3,1.3,1.3,0.3/)
    pm3 = gsn_add_polygon(wks,plot_without_xgrid,xbar,ybar,cres)
    tx3 = gsn_add_text(wks, plot_without_xgrid, "hTfM", 1.75, 1.12, txres)

    cres@gsFillColor           = "orange"
    ybar      = (/1.11,1.13,1.13,1.11,1.11/)
    xbar      = (/2.3,2.3,3.3,3.3,2.3/)
    pm4 = gsn_add_polygon(wks,plot_without_xgrid,xbar,ybar,cres)
    tx4 = gsn_add_text(wks, plot_without_xgrid, "htfM", 3.75, 1.12, txres)

;
; Drawing the plot will draw all the attached bars. Have to draw
; the plot twice: one with the X grid lines and one without, in
; order to make sure the X grid lines are behind the bars.
;
; Couldn't see how else to do this.
;
  ;draw(plot_with_xgrid)
  draw(plot_without_xgrid)
  frame(wks)
end