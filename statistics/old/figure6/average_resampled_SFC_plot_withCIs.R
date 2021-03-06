# Ignore: For Alex Computer 
#processed_SFC_dir = "./processed_SFC/"
#resampled_SFC_dir = "./resampled_SFC/max/"

SFC_type = "increase" #increase, decrease, all
#Andy computer:
averaged_resampled_data_path = paste0("/Users/andyrevell/mount/USERS/arevell/papers/paper001/data_processed/figure6_data/average_SFC_ALL_PATIENTS/averaged_resampled_data/medians/", SFC_type, "/averaged_resampled_data.RData")
output_plot_path= paste0("/Users/andyrevell/mount/USERS/arevell/papers/paper001/paper001/figures/figure6/average_SFC_ALL_PATIENTS/averaged_resampled_data/medians/", SFC_type, "/")


#Borel:
#processed_SFC_dir = "/gdrive/public/USERS/arevell/papers/paper001/data_processed/figure5_data/structure_function_correlation/"
# change this to be either medians/up/downsample 
#resampled_SFC_dir = "/gdrive/public/USERS/arevell/papers/paper001/data_processed/figure6_data/average_SFC_ALL_PATIENTS/medians/"


#plot_averaged_resampled_data(averaged_resampled_data_path, output_plot_path)

#plot_averaged_resampled_data <- function(averaged_resampled_data_path, output_plot_path){
  
  options(scipen=999)#prevent scientifuc notation. iEEG org times are very long, so helps when reading files to read the number string verbatim
  
  #dev.off(dev.list()["RStudioGD"])
  fname = paste0(output_plot_path, 'averaged_resampled_data', ".pdf")
  pdf(fname , width = 6, height = 8)
  load(averaged_resampled_data_path)
  
  m <- matrix(c(1,2,3,4,5,6,7,8,9,10,11,12),nrow = 6,ncol = 2,byrow = TRUE)
  
  layout(mat = m,heights = c(1,1,1,1,1,0.5,0.5))
  
  #par(mfrow = c(3,2))
  par(oma=c(1,3,4,2))
  
  #create filler data with NAs. Filler between interictal and preictal (becasue they are not continuous)
  filler =  rep(NA,  length(averaged_resampled_random_atlases$RA_N0010$ictal$mean$broadband) *0.20  )# X% of ictal length 
  
  #Make colors
  colors_interictal = '#cc0000'
  colors_preictal = '#00cc00'
  colors_ictal = '#0000cc'
  colors_postictal = '#cc00cc'
  
  
  frequency_names = names(averaged_resampled_random_atlases$RA_N0010$interictal$mean)
  frequency_names =c("Broadband", "Alpha/Theta", "Beta", "Low Gamma", 
                    "High Gamma")
  
  colors = c(rep(colors_interictal, length(averaged_resampled_random_atlases$RA_N0010$interictal$mean$broadband)),
             rep('#000000', length(filler)),
             rep(colors_preictal, length(averaged_resampled_random_atlases$RA_N0010$preictal$mean$broadband)),
             rep(colors_ictal, length(averaged_resampled_random_atlases$RA_N0010$ictal$mean$broadband)),
             rep(colors_postictal, length(averaged_resampled_random_atlases$RA_N0010$postictal$mean$broadband)))
  
  random_atlases=c('RA_N0010', 'RA_N0030', 'RA_N0050', 'RA_N0075','RA_N0100','RA_N0200','RA_N0300', 'RA_N0400', 'RA_N0500' , 'RA_N0750', 'RA_N1000', 'RA_N2000')
  standard_atlases=c('aal_res-1x1x1', 'AAL600', 'CPAC200_res-1x1x1', 'desikan_res-1x1x1','DK_res-1x1x1','JHU_res-1x1x1',
                     'Schaefer2018_100Parcels_17Networks_order_FSLMNI152_1mm', 'Schaefer2018_200Parcels_17Networks_order_FSLMNI152_1mm',
                     'Schaefer2018_300Parcels_17Networks_order_FSLMNI152_1mm' , 'Schaefer2018_400Parcels_17Networks_order_FSLMNI152_1mm', 
                     'Schaefer2018_1000Parcels_17Networks_order_FSLMNI152_1mm', 'Talairach_res-1x1x1', 'JHU_aal_combined_res-1x1x1')
  
  random_atlases_to_plot = c('RA_N0010', 'RA_N0030','RA_N0100','RA_N1000')
  standard_atlases_to_plot = c('aal_res-1x1x1',  'CPAC200_res-1x1x1',
                               'Schaefer2018_100Parcels_17Networks_order_FSLMNI152_1mm','Schaefer2018_1000Parcels_17Networks_order_FSLMNI152_1mm',
                               'JHU_aal_combined_res-1x1x1')
  
  standard_atlases_legend = c('AAL', 'CPAC', 'Schaefer 100', 'Schaefer 1000','AAL-JHU')
  random_atlases_legend = c('10', '30','100', '1000')
  #########
  #to caluclate moving average:
  ma <- function(x, n = 10){filter(x, rep(1 / n, n), sides = 2)}
  
  
  
  
  
  standard_atlas_colors = c(
    '#E61717E6',
    '#e6ad00E6',
    '#006400E6',
    '#178DE6E6',
    '#2F17E6E6'
  )
  
  #standard_atlas_colors = rainbow(length(standard_atlases_to_plot), s= 0.9,v=0.9,start = 0, end = 0.8, alpha = 0.9)
  random_atlas_colors = rainbow(length(random_atlases_to_plot), s= 0.9,v=0.9,start = 0.0, end = 0.8, alpha = 0.9)
  #random_atlas_colors = rep("#333333",  length(random_atlases_to_plot))
  
  
  
  
  add_siezure_colors <- function(bottom,f){
    
    #Adding seizure colors
    #interictal
    colors_interictal = '#ffffff'
    colors_preictal = '#6666ff'
    colors_ictal = '#ff6666'
    colors_postictal = '#ffffff'
    
    transparency = '33'
    interictal_x = c(0:length(data_interictal_broadband_movingAvg ))
    polygon(  x = c(interictal_x, rev(interictal_x)  ), 
              y = c( rep(par("usr")[4], length(interictal_x) ) , rep(bottom, length(interictal_x))   ),
              border = NA, col = paste0(colors_interictal, transparency))
    
    
    
    preictal_x_start = length(c(averaged_resampled_random_atlases$RA_N0010$interictal$mean$broadband,filler))+1  
    preictal_x_end = preictal_x_start+length(averaged_resampled_random_atlases$RA_N0010$preictal$mean$broadband)
    ictal_x_start = preictal_x_end + 1
    ictal_x_end = ictal_x_start+length(averaged_resampled_standard_atlases[[atlas_index]]$ictal$mean$broadband)
    postictal_x_start = ictal_x_end + 1
    postictal_x_end = length(y_moving_avg)
    
    polygon(  x = c(preictal_x_start:preictal_x_end, rev(preictal_x_start:preictal_x_end)  ), 
              y = c( rep(par("usr")[4], length(preictal_x_start:preictal_x_end) ) , rep(bottom, length(preictal_x_start:preictal_x_end))   ),
              border = NA, col = paste0(colors_preictal, transparency))
    polygon(  x = c(ictal_x_start:ictal_x_end, rev(ictal_x_start:ictal_x_end)  ), 
              y = c( rep(par("usr")[4], length(ictal_x_start:ictal_x_end) ) , rep(bottom, length(ictal_x_start:ictal_x_end))   ),
              border = NA, col = paste0(colors_ictal, transparency))
    polygon(  x = c(postictal_x_start:postictal_x_end, rev(postictal_x_start:postictal_x_end)  ), 
              y = c( rep(par("usr")[4], length(postictal_x_start:postictal_x_end) ) , rep(bottom, length(postictal_x_start:postictal_x_end))   ),
              border = NA, col = paste0(colors_postictal, transparency))
    
    if (f == 1){
    text(x = (preictal_x_start + ictal_x_start )/2,
         y = par("usr")[4]*0.9, labels = "Preictal")
    text(x = (ictal_x_start + ictal_x_end )/2,
         y = par("usr")[4]*0.9, labels = "Ictal")}
    
    
    
    
    
  }
  
  INDEX_FREQ = c(1:5)
  
  for (f in INDEX_FREQ){
    par(new = F)
    
    #plotting parameters
    
    ylim = c(-0, 0.4)
    standard_atlases_line_width = 2
    random_atlases_line_width = 2
    standard_atlas_colors_transparency = 'ff'
    CI95_color = "#99999966"
    
    mar_1 = 1
    mar_2 = 3
    mar_3 = 0
    mar_4 = 0
    #par(mfrow = c(2,1))
    mar = c(mar_1,mar_2,mar_3,mar_4)
    par(mar =mar)
    
    las = 1
    font_legend = 4
    cex_legend = 0.9
    cex_main = 1.2
    line_main = -1.0
    
    
    
    
    #Standard Atlases
    for (a in 1:length(standard_atlases_to_plot)){
      atlas_index = which(names(averaged_resampled_standard_atlases) == standard_atlases_to_plot[a])
      #create running mean (moving average, convolution)
      N = 20 #length of window
      data_interictal_broadband_movingAvg = ma(averaged_resampled_standard_atlases[[atlas_index]]$interictal$mean[[f]], N)
      data_other_broadband_movingAvg = ma( c(averaged_resampled_standard_atlases[[atlas_index]]$preictal$mean[[f]], 
                                             averaged_resampled_standard_atlases[[atlas_index]]$ictal$mean[[f]], 
                                             averaged_resampled_standard_atlases[[atlas_index]]$postictal$mean[[f]]  ), N  )
      
    
      
#####
      
      data_interictal_broadband_movingAvg = ma(averaged_resampled_standard_atlases[[atlas_index]]$interictal$mean[[f]], N)
      data_interictal_broadband_movingAvg_CI95_upper = ma(averaged_resampled_standard_atlases[[atlas_index]]$interictal$CI95_upper[[f]], N)
      data_interictal_broadband_movingAvg_CI95_lower = ma(averaged_resampled_standard_atlases[[atlas_index]]$interictal$CI95_lower[[f]], N)
      
      data_other_broadband_movingAvg = ma( c(averaged_resampled_standard_atlases[[atlas_index]]$preictal$mean[[f]], 
                                             averaged_resampled_standard_atlases[[atlas_index]]$ictal$mean[[f]], 
                                             averaged_resampled_standard_atlases[[atlas_index]]$postictal$mean[[f]]  ), N  )
      data_other_broadband_movingAvg_CI95_upper = ma( c(averaged_resampled_standard_atlases[[atlas_index]]$preictal$CI95_upper[[f]], 
                                                        averaged_resampled_standard_atlases[[atlas_index]]$ictal$CI95_upper[[f]], 
                                                        averaged_resampled_standard_atlases[[atlas_index]]$postictal$CI95_upper[[f]]  ), N  )
      data_other_broadband_movingAvg_CI95_lower = ma( c(averaged_resampled_standard_atlases[[atlas_index]]$preictal$CI95_lower[[f]], 
                                                        averaged_resampled_standard_atlases[[atlas_index]]$ictal$CI95_lower[[f]], 
                                                        averaged_resampled_standard_atlases[[atlas_index]]$postictal$CI95_lower[[f]]  ), N  )
      
      #Calculating pad for the running mean
      pad_data_interictal_broadband_movingAvg = length(which(is.na(data_interictal_broadband_movingAvg)))
      pad_data_other_broadband_movingAvg = length(which(is.na(data_other_broadband_movingAvg)))
      #removing NAs from the original moving average function
      data_interictal_broadband_movingAvg = data_interictal_broadband_movingAvg[!is.na(data_interictal_broadband_movingAvg)]
      data_interictal_broadband_movingAvg_CI95_upper = data_interictal_broadband_movingAvg_CI95_upper[!is.na(data_interictal_broadband_movingAvg_CI95_upper)]
      data_interictal_broadband_movingAvg_CI95_lower = data_interictal_broadband_movingAvg_CI95_lower[!is.na(data_interictal_broadband_movingAvg_CI95_lower)]
      data_other_broadband_movingAvg = data_other_broadband_movingAvg[!is.na(data_other_broadband_movingAvg)]
      data_other_broadband_movingAvg_CI95_upper = data_other_broadband_movingAvg_CI95_upper[!is.na(data_other_broadband_movingAvg_CI95_upper)]
      data_other_broadband_movingAvg_CI95_lower = data_other_broadband_movingAvg_CI95_lower[!is.na(data_other_broadband_movingAvg_CI95_lower)]
      
      data_interictal_broadband_movingAvg = c(  rep(NA, pad_data_interictal_broadband_movingAvg),data_interictal_broadband_movingAvg )
      data_interictal_broadband_movingAvg_CI95_upper = c(  rep(NA, pad_data_interictal_broadband_movingAvg),data_interictal_broadband_movingAvg_CI95_upper )
      data_interictal_broadband_movingAvg_CI95_lower = c(  rep(NA, pad_data_interictal_broadband_movingAvg),data_interictal_broadband_movingAvg_CI95_lower )
      data_other_broadband_movingAvg = c(  rep(NA, pad_data_other_broadband_movingAvg),data_other_broadband_movingAvg )
      data_other_broadband_movingAvg_CI95_upper = c(  rep(NA, pad_data_other_broadband_movingAvg),data_other_broadband_movingAvg_CI95_upper )
      data_other_broadband_movingAvg_CI95_lower = c(  rep(NA, pad_data_other_broadband_movingAvg),data_other_broadband_movingAvg_CI95_lower )
      
      
      
      
      
      #plotting
      y_moving_avg = c(data_interictal_broadband_movingAvg, filler, data_other_broadband_movingAvg)
      y_moving_avg_CI95_upper = c(data_interictal_broadband_movingAvg_CI95_upper, filler, data_other_broadband_movingAvg_CI95_upper)
      y_moving_avg_CI95_lower = c(data_interictal_broadband_movingAvg_CI95_lower, filler, data_other_broadband_movingAvg_CI95_lower)
      data_length = length(y_moving_avg)
      x = c(1:data_length)
      xlim = c(0, data_length)
      
      
      
      
      
      if (a == 1){par(new = F)}
      if (a > 1){par(new = T)}
      plot(x, y_moving_avg, xlim = xlim, ylim = ylim, bty="n", type = "l", lwd = standard_atlases_line_width, 
           col = standard_atlas_colors[a], ylab = "", xlab = "", xaxt = 'n', las = las)
      
      
      polygon(c(1:length(data_interictal_broadband_movingAvg_CI95_lower), rev(1:length(data_interictal_broadband_movingAvg_CI95_lower))), 
              c(data_interictal_broadband_movingAvg_CI95_lower, rev(data_interictal_broadband_movingAvg_CI95_upper)) ,
              border = CI95_color, col = CI95_color)
      polygon(  x = c((length(c(data_interictal_broadband_movingAvg,filler))+1):data_length, rev((length(c(data_interictal_broadband_movingAvg,filler))+1):data_length)), 
                y = c(data_other_broadband_movingAvg_CI95_lower, rev(data_other_broadband_movingAvg_CI95_upper)),
                border = CI95_color, col = CI95_color)
      

      par(xpd = F)

      
      interictal_x = c(0:length(data_interictal_broadband_movingAvg ))

      
    }
    add_siezure_colors(par("usr")[3],f)
    
    
    if (f == 1){
      mtext(text="Standard Atlases",side=3,line=0.5,outer=F,cex=cex_main)
    }
    

    if (f ==5  ){
      axis(1, at=c(preictal_x_start, ictal_x_start, ictal_x_end,postictal_x_end), 
           labels=c(preictal_x_start-ictal_x_start,0, ictal_x_end -ictal_x_start+1, ictal_x_end -ictal_x_start+1 +180 ), 
           pos=-0.1, lty=1, las=1, tck=-0.03, lwd = 2, font = 2)
      axis(1, at=pad_data_interictal_broadband_movingAvg, 
           labels=c("~6 hrs before" ), 
           pos=-0.1, lty=1, las=1, tck=-0.03, lwd = 2, font = 2, adj = 1)
    }
    abline(h = -0.1, lwd = 1)
   # if (f == 1){ plot(1, type = "n", axes=FALSE, xlab="", ylab="")
   # 
   # 
   #  legend("top", inset=c(-0.1,0), legend = rev( standard_atlases_legend), fill = rev( standard_atlas_colors), bty = 'n', bg ='n',horiz = F,
   #         xpd = NA, x.intersp=0.3,
   #         xjust=0, yjust=0, cex = 1.1)}
    #title(main = "Standard", line = line_main, cex.main = cex_main, font.main = 1)
    #mtext(text=paste0(" Standard Atlases"),side=3,line=-2,outer=F, cex = cex_main, font = 1, adj = c(0,0))
    par(xpd = T)
    #mtext(text="Structure-Function Correlation",side=3,line=-1.7,outer=TRUE,cex=2, font = 4)
    #mtext(text=paste0("Standard vs Random Atlases"),side=3,line=-3,outer=TRUE, cex=1.5, font = 3)
    
    
    # mtext(text=paste0("sub-", sub_ID, '_', iEEG_filename,  '_ICTAL_', ictal_start_time),
    #       side=1,line=-1,outer=TRUE, cex=0.9, font = 1, at = c(0),adj = 0)
    # 
    par(xpd = F)
    #plotting parameters
    
    #mar_1 = 3
    #mar_3 = 0
    mar = c(mar_1,mar_2,mar_3,mar_4)
    
    par(mar =mar)
    
    
    
    
    #Random Atlases
    for (a in 1:length(random_atlases_to_plot)){
      atlas_index = which(names(averaged_resampled_random_atlases) == random_atlases_to_plot[a])
      #create running mean (moving average, convolution)
      N = 20 #length of window
      data_interictal_broadband_movingAvg = ma(averaged_resampled_random_atlases[[atlas_index]]$interictal$mean[[f]], N)
      data_interictal_broadband_movingAvg_CI95_upper = ma(averaged_resampled_random_atlases[[atlas_index]]$interictal$CI95_upper[[f]], N)
      data_interictal_broadband_movingAvg_CI95_lower = ma(averaged_resampled_random_atlases[[atlas_index]]$interictal$CI95_lower[[f]], N)
      
      data_other_broadband_movingAvg = ma( c(averaged_resampled_random_atlases[[atlas_index]]$preictal$mean[[f]], 
                                             averaged_resampled_random_atlases[[atlas_index]]$ictal$mean[[f]], 
                                             averaged_resampled_random_atlases[[atlas_index]]$postictal$mean[[f]]  ), N  )
      data_other_broadband_movingAvg_CI95_upper = ma( c(averaged_resampled_random_atlases[[atlas_index]]$preictal$CI95_upper[[f]], 
                                                        averaged_resampled_random_atlases[[atlas_index]]$ictal$CI95_upper[[f]], 
                                                        averaged_resampled_random_atlases[[atlas_index]]$postictal$CI95_upper[[f]]  ), N  )
      data_other_broadband_movingAvg_CI95_lower = ma( c(averaged_resampled_random_atlases[[atlas_index]]$preictal$CI95_lower[[f]], 
                                                        averaged_resampled_random_atlases[[atlas_index]]$ictal$CI95_lower[[f]], 
                                                        averaged_resampled_random_atlases[[atlas_index]]$postictal$CI95_lower[[f]]  ), N  )
      
      #Calculating pad for the running mean
      pad_data_interictal_broadband_movingAvg = length(which(is.na(data_interictal_broadband_movingAvg)))
      pad_data_other_broadband_movingAvg = length(which(is.na(data_other_broadband_movingAvg)))
      #removing NAs from the original moving average function
      data_interictal_broadband_movingAvg = data_interictal_broadband_movingAvg[!is.na(data_interictal_broadband_movingAvg)]
      data_interictal_broadband_movingAvg_CI95_upper = data_interictal_broadband_movingAvg_CI95_upper[!is.na(data_interictal_broadband_movingAvg_CI95_upper)]
      data_interictal_broadband_movingAvg_CI95_lower = data_interictal_broadband_movingAvg_CI95_lower[!is.na(data_interictal_broadband_movingAvg_CI95_lower)]
      data_other_broadband_movingAvg = data_other_broadband_movingAvg[!is.na(data_other_broadband_movingAvg)]
      data_other_broadband_movingAvg_CI95_upper = data_other_broadband_movingAvg_CI95_upper[!is.na(data_other_broadband_movingAvg_CI95_upper)]
      data_other_broadband_movingAvg_CI95_lower = data_other_broadband_movingAvg_CI95_lower[!is.na(data_other_broadband_movingAvg_CI95_lower)]
      
      data_interictal_broadband_movingAvg = c(  rep(NA, pad_data_interictal_broadband_movingAvg),data_interictal_broadband_movingAvg )
      data_interictal_broadband_movingAvg_CI95_upper = c(  rep(NA, pad_data_interictal_broadband_movingAvg),data_interictal_broadband_movingAvg_CI95_upper )
      data_interictal_broadband_movingAvg_CI95_lower = c(  rep(NA, pad_data_interictal_broadband_movingAvg),data_interictal_broadband_movingAvg_CI95_lower )
      data_other_broadband_movingAvg = c(  rep(NA, pad_data_other_broadband_movingAvg),data_other_broadband_movingAvg )
      data_other_broadband_movingAvg_CI95_upper = c(  rep(NA, pad_data_other_broadband_movingAvg),data_other_broadband_movingAvg_CI95_upper )
      data_other_broadband_movingAvg_CI95_lower = c(  rep(NA, pad_data_other_broadband_movingAvg),data_other_broadband_movingAvg_CI95_lower )
      
      
      
      
      
      #plotting
      y_moving_avg = c(data_interictal_broadband_movingAvg, filler, data_other_broadband_movingAvg)
      y_moving_avg_CI95_upper = c(data_interictal_broadband_movingAvg_CI95_upper, filler, data_other_broadband_movingAvg_CI95_upper)
      y_moving_avg_CI95_lower = c(data_interictal_broadband_movingAvg_CI95_lower, filler, data_other_broadband_movingAvg_CI95_lower)
      data_length = length(y_moving_avg)
      x = c(1:data_length)
      xlim = c(0, data_length)
      
      
      
      
      if (a == 1){par(new = F)}
      if (a > 1){par(new = T)}
      plot(x, y_moving_avg, xlim = xlim, ylim = ylim, bty="n", type = "l", lwd = random_atlases_line_width, col = random_atlas_colors[a],
           las = las, xlab = "", ylab = "", xaxt = 'n')
      
      
      
      # text(  x = (length(data_interictal_broadband_movingAvg ) +length(filler) + pad_data_other_broadband_movingAvg)  ,  
      #        y = (data_other_broadband_movingAvg[pad_data_other_broadband_movingAvg+1]),
      #        labels = random_atlases_legend[a],adj = c(1,0.5), font = font_legend, cex = cex_legend, offset = 0.4, pos = 2)
      # text(  x = data_length  ,  
      #        y = (data_other_broadband_movingAvg[length(data_other_broadband_movingAvg)-10]),
      #        labels = paste0(random_atlases_legend[a], " Parcellations")   ,adj = c(1,0.5), font = font_legend, cex = cex_legend, offset = 0.6, pos = 4, xpd = NA)
      # #Adding 95% confidence intervals
      #interictal
      polygon(c(1:length(data_interictal_broadband_movingAvg_CI95_lower), rev(1:length(data_interictal_broadband_movingAvg_CI95_lower))), 
              c(data_interictal_broadband_movingAvg_CI95_lower, rev(data_interictal_broadband_movingAvg_CI95_upper)) ,
              border = CI95_color, col = CI95_color)
      #other
      polygon(  x = c((length(c(data_interictal_broadband_movingAvg,filler))+1):data_length, rev((length(c(data_interictal_broadband_movingAvg,filler))+1):data_length)), 
                y = c(data_other_broadband_movingAvg_CI95_lower, rev(data_other_broadband_movingAvg_CI95_upper)),
                border = CI95_color, col = CI95_color)
      
      
      
    }
    add_siezure_colors(ylim[1],f)
    
    #title(main = "Random", line = line_main, cex.main = cex_main, font.main = 1)
    #mtext(text=paste0(" Random Atlases"),side=3,line=-1,outer=F, cex = cex_main, font = 1, adj = c(0,0))
    # text(x = par("usr")[1],
    #      y = par("usr")[4]*0.9, labels = "  Random Atlases",adj = c(0,0.5), cex = cex_main, font = 1)
    # 
    if (f == 1){
      mtext(text="Random Atlases",side=3,line=0.5,outer=F,cex=cex_main)
    }
    
    
    interictal_start = 0 
    interictal_end = length(data_interictal_broadband_movingAvg )
    
    preictal_x_start = length(c(data_interictal_broadband_movingAvg,filler))+1
    preictal_x_end = preictal_x_start+length(averaged_resampled_standard_atlases[[atlas_index]]$preictal[[f]])
    ictal_x_start = preictal_x_end + 1
    ictal_x_end = ictal_x_start+length(averaged_resampled_standard_atlases[[atlas_index]]$ictal[[f]])
    postictal_x_start = ictal_x_end + 1
    postictal_x_end = length(y_moving_avg)
    
    if (f ==5  ){
     axis(1, at=c(preictal_x_start, ictal_x_start, ictal_x_end,postictal_x_end), 
          labels=c(preictal_x_start-ictal_x_start,0, ictal_x_end -ictal_x_start+1, ictal_x_end -ictal_x_start+1 +180 ), 
          pos=-0.1, lty=1, las=1, tck=-0.03, lwd = 2, font = 2)
     axis(1, at=pad_data_interictal_broadband_movingAvg, 
          labels=c("~6 hrs before" ), 
          pos=-0.1, lty=1, las=1, tck=-0.03, lwd = 2, font = 2, adj = 1)
    }
    abline(h = -0.1, lwd = 1)
    

    text(x = par("usr")[2]*1.03, y = (par("usr")[3] + par("usr")[4])/2, frequency_names[f], srt = 270, xpd = NA,cex=1.5)
    
    mtext(text="Spearman Rank Correlation",side=2,line=0.5,outer=TRUE,cex=1.2)
    mtext(text="Time Normalized to Median Seizure Length (s)",side=1,line=-4,outer=TRUE,cex=0.9)
    mtext(text=paste0("Average of All Patients by Frequency Bands (",SFC_type, " SFC)"),side=3,line=2,outer=TRUE,cex=1.2)
    

  
    #if (f == 1){ plot(1, type = "n", axes=FALSE, xlab="", ylab="")}
  }
  
  #mar_1 = 3
  mar_3 = 2
  mar = c(mar_1,mar_2,mar_3,mar_4)
  par(mar =mar)
   plot(1, type = "n", axes=FALSE, xlab="", ylab="")
   
   legend("bottomleft", inset=c(-0.1,-0.5), legend = rev( standard_atlases_legend), fill = rev( standard_atlas_colors), bty = 'n', bg ='n',horiz = F,
          xpd = NA, x.intersp=0.3, ncol = 3,
          xjust=0.5, yjust=0, cex = 1.1   )
   plot(1, type = "n", axes=FALSE, xlab="", ylab="")
   
   legend("bottomleft", inset=c(-0.05,-0.5), legend =  paste0(random_atlases_legend," Parcellations"), fill = random_atlas_colors, bty = 'n', bg ='n',horiz = F,
          xpd = NA, x.intersp=0.3, ncol = 3,
          xjust=0.5, yjust=0, cex = 1.1)
  dev.off()
#}
