
color = rgb(1/255, 100/255, 200/255, alpha = 1)

# requires installation of library(grid).

######################################
####### value function TK92 ##########
######################################
vf_TK92 <- function(samples = samples, # JAGS output object name
                    color = rgb(1/255, 100/255, 200/255, alpha = 1), # color for lines
                    fontsize = 1, # controls font size of axis and tick labels
                    condition = "", # condition for title of plot
                       alpha_subj = "alpha", # individual parameter names
                       lambda_subj = "lambda",
                       beta_subj = "alpha", # by default, the function will assume no separate curvature parameter for the loss domain. if there is one, that can be specified here
                       alpha_mean = "mu.alpha", # parameter names of group_level means
                       lambda_mean = "mu.lambda",
                       beta_mean = "mu.alpha" # by default, the function will assume no separate curvature parameter for the loss domain. if there is one, that can be specified here
) {
  
  
  par(mfrow=c(1,1))
  a <- seq(-100, 100, by=0.1)
  
  # scale gaps to font size
  lab_gap   <- 0.6 * fontsize   # distance of tick labels from axis line
  title_gap <- 1.2 + 0.4*(fontsize - 1)  # distance of axis titles (mtext) from plot
  
  plot(a, a, type = "l", axes = FALSE, xlab = "", ylab = "",
       cex.axis = fontsize * 1.1, lty = 2, lwd = 1,
       ylim = c(-10, 10), xlim = c(-20, 20), col = "white")
  par(xpd = FALSE)
  title(paste0("Value function ", condition), cex.main = fontsize * 1.5, font.main = 1)
  
  axis(1, seq(-20, 20, by = 5), pos = 0,
       cex.axis = 0.9* fontsize, tck = -0.01, mgp = c(3, lab_gap, 0))
  axis(2, seq(-10, 10, by = 2), pos = 0,
       cex.axis = 0.9*fontsize, tck = -0.01, las = 1, mgp = c(3, lab_gap, 0))
  
  mtext(text = "Outcome",          side = 1, line = title_gap, cex = fontsize)
  mtext(text = "Subjective Value", side = 2, line = title_gap, cex = fontsize)
  
  
  
  # plot(a, a, "l", axes=FALSE, xlab='', ylab='', 
  #      cex.axis=fontsize*1.1, # .6, 
  #      lty=2, lwd=1, ylim=c(-10, 10), xlim=c(-20, 20), col="white")
  # par(xpd=FALSE)
  # title(paste("Value function"), cex.main=1.5, font.main=1)
  # axis(1, seq(from=-20, to=20, by=5), pos=0, 
  #      cex.axis= fontsize, # .6, 
  #      mgp=c(3, .1, 1), tck=-.01)
  # axis(2, seq(from=-10, to=10, by=2), pos=0, 
  #      cex.axis=fontsize, # .6, 
  #      tck=-.01, las=1, mgp=c(3, 0.6, 0))
  # mtext(side=1, text="Outcome", 
  #       cex = fontsize,
  #       line=1)
  # mtext(side=2, text="Subjective Value", 
  #       cex = fontsize,
  #       line=.5)
  
  # plot dashed line
  lines(a,a,col="black",lty=2,lwd=1)

  # if group-level estimate exists, plot group-level
  if(exists(alpha_mean, where = samples$BUGSoutput$mean)){
    alpha   <- c(samples$BUGSoutput$mean[[alpha_mean]]) # c(samples$BUGSoutput$mean$mu.alpha)
    lambda  <- c(samples$BUGSoutput$mean[[lambda_mean]]) # c(samples$BUGSoutput$mean$mu.lambda)
    beta    <- c(samples$BUGSoutput$mean[[beta_mean]])
    b       <- c(-lambda*(-a[1:1000])^beta, 
                 a[1001:2001]^alpha)
    lines(a, b, col=color, lty=1, lwd=2)
    
    color_subj <- grDevices::adjustcolor(color, alpha.f = 0.1)
    
    # if not, don't plot mean line
  } else {
    
    color_subj <- grDevices::adjustcolor(color, alpha.f = 0.5)
  }
  
  
  # if individual estimates exist, plot them
  if(exists(alpha_subj, where = samples$BUGSoutput$mean)){
    
    nSubj = length(samples$BUGSoutput$mean[[alpha_subj]])
    
    for (subj in 1:nSubj) { # get individual curves
      alpha <- c(samples$BUGSoutput$mean[[alpha_subj]][subj])
      lambda <- c(samples$BUGSoutput$mean[[lambda_subj]][subj])
      beta <- c(samples$BUGSoutput$mean[[beta_subj]][subj])
      b <- c(-lambda*(-a[1:1000])^beta, 
             a[1001:2001]^alpha)
      par(new=TRUE)
      lines(a, b, col=color_subj, lty=1, lwd=1)
    }
    
    # if hierarchical, plot legend also
    if(exists(alpha_mean, where = samples$BUGSoutput$mean)){
      
      legend(1, -2, inset=0, 
             legend = c(expression("Group-level estimate"), expression("Individual estimates")),
             cex = 0.9 * fontsize, 
             col = c(color, color_subj), horiz = F,bty = "n",
             lty = 1,  # Solid line
             lwd = 2   # Line width
      )
    } else {}
    
    # if not, don't plot individual lines
  } else {
  }
   
  # Record the plot and return it
  recordPlot()
  
} # v_fun_TK92 end

  
#########################################
##### weighting functions TK92 ##########
#########################################

  wf_TK92 <- function(samples = samples, 
                      color = rgb(1/255, 100/255, 200/255, alpha = 1), # color for lines
                      fontsize = 1, # controls font size of axis and tick labels
                      condition = "", # condition for title of plot
                         domain_separation = F, # indicate if model has fitted different parameters for gain vs. loss domains - default is no
                         gamma_subj = "gamma", # individual parameter names
                         gamma.loss_subj = "gamma",
                         gamma_mean = "mu.gamma", # parameter names of group_level means
                         gamma.loss_mean = "mu.gamma" # by default, the function will assume no separate curvature parameter for the loss domain. if there is one, that can be specified here 
                         ) {
    
    
  ##### if no domain-separation of weighting parameters exist, plot single weighting function
    if(!domain_separation) {
    # if(!exists("gamma.loss", where = samples$BUGSoutput$mean) && !exists("mu.gamma.loss", where = samples$BUGSoutput$mean) ){

    #par(mfrow=c(2,2)) # par(mfrow=c(2,1))
    
      #par(mfrow=c(1,1))
    par(mfrow = c(1,1),
          mar = c(4 + fontsize, 4 + fontsize, 2, 2))  # scale margins
    a <- c(seq(0, 1, by=.001))
    
    # scale gaps to font size
    lab_gap   <- 0.6 * fontsize   # distance of tick labels from axis line
    
    
    
  plot(a, a, type = "l", xlab = "", ylab = "",
       cex.axis = fontsize * 1.1, lty = 2, lwd = 1,
      # a,a,"l",xlab='',ylab='',
      #  cex.axis=.7,
      #  lty=1,lwd = 2, 
       col = "white",xpd = F, axes=F)
  # axis(1, las=1, cex.axis = .7)
  # axis(2, las=2, cex.axis = .7)
  # 
  # par(xpd = FALSE)
  
  axis(1, las=1, 
       cex.axis = 0.9* fontsize, tck = -0.01, mgp = c(3, lab_gap, 0))
  axis(2, las=2, 
       cex.axis = 0.9* fontsize, tck = -0.01, mgp = c(3, lab_gap, 0))
  
  # box()
  title(paste0("Probability weighting function ", condition),
        cex.main = fontsize * 1.5, font.main = 1)
  mtext(side = 1, text = substitute(paste("Probability (", italic("p"),")")), line = 2* fontsize, cex = fontsize)
  mtext(side = 2, text = substitute(paste("w(", italic("p"),")")), line = 2* fontsize, cex = fontsize)
  
  
  # plot dashed line
  lines(a,a,col="black",lty=2,lwd=1)
  
  # if group-level estimate exists, plot group-level
  if(exists(gamma_mean, where = samples$BUGSoutput$mean)){
    gamma <- c(samples$BUGSoutput$mean[[gamma_mean]])
    b <- (a^gamma)/((a^gamma+(1-a)^gamma)^(1/gamma)) # TK function
    lines(a,b,col= color ,lty=1,lwd =3)
    
    color_subj <- grDevices::adjustcolor(color, alpha.f = 0.1)
    
    # if not, don't plot mean line
  } else {
    color_subj <- grDevices::adjustcolor(color, alpha.f = 0.5)
  }
  
  
  
  
  # if individual estimates exist, plot them
  if(exists(gamma_subj, where = samples$BUGSoutput$mean)){
    
    nSubj = length(samples$BUGSoutput$mean[[gamma_subj]])
    
    for (subj in 1:nSubj) {
      gamma <- c(samples$BUGSoutput$mean[[gamma_subj]][subj])
      b <- (a^gamma)/((a^gamma+(1-a)^gamma)^(1/gamma)) # TK function
      par(new=T)
      lines(a,b,col=color_subj,lty=1,lwd=1)
    }
    
    # if hierarchical, plot legend also
    if(exists(gamma_mean, where = samples$BUGSoutput$mean)){
      
      legend(0.1, 1, inset=0, 
             legend = c(expression("Group-level estimate"), expression("Individual estimates")),
             cex = 0.9 * fontsize, 
             col = c(color, color_subj), horiz = F,bty = "n",
             lty = 1,  # Solid line
             lwd = 2   # Line width
      )
    } else {}
    
    # if not, don't plot individual lines
  } else {
  }
  
  
  ##### if domain-separated weigthing parameters exist, plot several lines
    } else {
      par(mfrow=c(1,2),  mar = c(4 + fontsize, 4 + fontsize, 2, 2))  # scale margins)
      
      ## plot Gain domain
      a <- c(seq(0, 1, by=.001))
      
      lab_gap   <- 0.6 * fontsize   # distance of tick labels from axis line 
      plot(a, a, type = "l", xlab = "", ylab = "",
           cex.axis = fontsize * 1.1, lty = 2, lwd = 1,
           col = "white",xpd = F, axes=F)
      axis(1, las=1, 
           cex.axis = 0.9* fontsize, tck = -0.01, mgp = c(3, lab_gap, 0))
      axis(2, las=2, 
           cex.axis = 0.9* fontsize, tck = -0.01, mgp = c(3, lab_gap, 0))
      
      title(paste0("Gain domain ", condition),
            cex.main = fontsize * 1.5, font.main = 1)
      mtext(side = 1, text = substitute(paste("Probability (", italic("p"),")")), line = 2* fontsize, cex = fontsize)
      mtext(side = 2, text = substitute(paste("w(", italic("p"),")")), line = 2* fontsize, cex = fontsize)
      
      
      # plot dashed line
      lines(a,a,col="black",lty=2,lwd=1)
      
      # if group-level estimate exists, plot group-level
      if(exists(gamma_mean, where = samples$BUGSoutput$mean)){
        gamma <- c(samples$BUGSoutput$mean[[gamma_mean]])
        b <- (a^gamma)/((a^gamma+(1-a)^gamma)^(1/gamma)) # TK function
        lines(a,b,col= color ,lty=1,lwd =3)
        
        color_subj <- grDevices::adjustcolor(color, alpha.f = 0.1)
        
        # if not, don't plot mean line
      } else {
        color_subj <- grDevices::adjustcolor(color, alpha.f = 0.5)
      }
      
      # if individual estimates exist, plot them
      if(exists(gamma_subj, where = samples$BUGSoutput$mean)){
        
        nSubj = length(samples$BUGSoutput$mean[[gamma_subj]])
        
        for (subj in 1:nSubj) {
          gamma <- c(samples$BUGSoutput$mean[[gamma_subj]][subj])
          b <- (a^gamma)/((a^gamma+(1-a)^gamma)^(1/gamma)) # TK function
          par(new=T)
          lines(a,b,col=color_subj,lty=1,lwd=1)
        }
        
        # if hierarchical, plot legend also
        if(exists(gamma_mean, where = samples$BUGSoutput$mean)){
          
          legend(0.1, 1, inset=0, 
                 legend = c(expression("Group-level estimate"), expression("Individual estimates")),
                 cex = 1.2, 
                 col = c(color, color_subj), horiz = F,bty = "n",
                 lty = 1,  # Solid line
                 lwd = 2   # Line width
          )
        } else {}
        
        # if not, don't plot individual lines
      } else {
      }
      
      
      
      ## plot Loss domain
      a <- c(seq(0, 1, by=.001))
      
      lab_gap   <- 0.6 * fontsize   # distance of tick labels from axis line 
      plot(a, a, type = "l", xlab = "", ylab = "",
           cex.axis = fontsize * 1.1, lty = 2, lwd = 1,
           col = "white",xpd = F, axes=F)
      axis(1, las=1, 
           cex.axis = 0.9* fontsize, tck = -0.01, mgp = c(3, lab_gap, 0))
      axis(2, las=2, 
           cex.axis = 0.9* fontsize, tck = -0.01, mgp = c(3, lab_gap, 0))
      
      title(paste0("Loss domain ", condition),
            cex.main = fontsize * 1.5, font.main = 1)
      mtext(side = 1, text = substitute(paste("Probability (", italic("p"),")")), line = 2* fontsize, cex = fontsize)
      mtext(side = 2, text = substitute(paste("w(", italic("p"),")")), line = 2* fontsize, cex = fontsize)
      
      # plot dashed line
      lines(a,a,col="black",lty=2,lwd=1)
      
      # if group-level estimate exists, plot group-level
      if(exists(gamma.loss_mean, where = samples$BUGSoutput$mean)){
        gamma <- c(samples$BUGSoutput$mean[[gamma.loss_mean]])
        b <- (a^gamma)/((a^gamma+(1-a)^gamma)^(1/gamma)) # TK function
        lines(a,b,col= color ,lty=1,lwd =3)
        
        color_subj <- grDevices::adjustcolor(color, alpha.f = 0.1)
        
        # if not, don't plot mean line
      } else {
        color_subj <- grDevices::adjustcolor(color, alpha.f = 0.5)
      }
      
      # if individual estimates exist, plot them
      if(exists(gamma.loss_subj, where = samples$BUGSoutput$mean)){
        
        nSubj = length(samples$BUGSoutput$mean[[gamma.loss_subj]])
        
        for (subj in 1:nSubj) {
          gamma <- c(samples$BUGSoutput$mean[[gamma.loss_subj]][subj])
          b <- (a^gamma)/((a^gamma+(1-a)^gamma)^(1/gamma)) # TK function
          par(new=T)
          lines(a,b,col=color_subj,lty=1,lwd=1)
        }
        
        # if hierarchical, plot legend also
        if(exists(gamma.loss_mean, where = samples$BUGSoutput$mean)){
          
          legend(0.1, 1, inset=0, 
                 legend = c(expression("Group-level estimate"), expression("Individual estimates")),
                 cex = 1.2, 
                 col = c(color, color_subj), horiz = F,bty = "n",
                 lty = 1,  # Solid line
                 lwd = 2   # Line width
          )
        } else {}
        
        # if not, don't plot individual lines
      } else {
      }
      
      

    }
    
    
    # Record the plot and return it
    recordPlot()
  
  } # w_fun_TK92 end
  
  
  
  #########################################
  ##### weighting functions GE87 ##########
  #########################################

wf_GE87 <- function(samples = samples, 
                       color = rgb(1/255, 100/255, 200/255, alpha = 1), # color for lines
                       domain_separation = F, # indicate if model has fitted different parameters for gain vs. loss domains - default is no
                       gamma_subj = "gamma", # individual parameter names
                       gamma.loss_subj = "gamma",
                       delta_subj = "delta", 
                       delta.loss_subj = "delta",
                       gamma_mean = "mu.gamma", # parameter names of group_level means
                       gamma.loss_mean = "mu.gamma", # by default, the function will assume no separate curvature parameter for the loss domain. if there is one, that can be specified here 
                       delta_mean = "mu.delta", # parameter names of group_level means
                       delta.loss_mean = "mu.delta" # by default, the function will assume no separate curvature parameter for the loss domain. if there is one, that can be specified here 
) {
  
  
  ##### if no domain-separation of weighting parameters exist, plot single weighting function
  if(!domain_separation){

    par(mfrow=c(1,1))
    
    a <- c(seq(0, 1, by=.001))
    plot(a,a,"l",xlab='',ylab='',cex.axis=.7,lty=1,lwd = 2, col = "white",xpd = F, axes=F)
    axis(1, las=1, cex.axis = .7)
    axis(2, las=2, cex.axis = .7)
    box()
    title(paste("Probability weighting function"),cex.main = 1.5, font.main = 1)
    mtext(side = 1, text = substitute(paste("Probability (", italic("p"),")")), line = 2.5)
    mtext(side = 2, text = substitute(paste("w(", italic("p"),")")), line = 2.5)
    
    # plot dashed line
    lines(a,a,col="black",lty=2,lwd=1)
    
    # if group-level estimate exists, plot group-level
    if(exists(gamma_mean, where = samples$BUGSoutput$mean)){
      
      lines(a,a,col="black",lty=2,lwd =1)
      gamma <- c(samples$BUGSoutput$mean[[gamma_mean]])
      delta <- c(samples$BUGSoutput$mean[[delta_mean]])
      b <- (delta*a^gamma)/(delta*a^gamma+(1-a)^gamma) # GE function
      lines(a,b,col= color ,lty=1,lwd =3)
      
      color_subj <- grDevices::adjustcolor(color, alpha.f = 0.1)
      
      # if not, don't plot mean line
    } else {
      color_subj <- grDevices::adjustcolor(color, alpha.f = 0.5)
    }
    
    
    # if individual estimates exist, plot them
    if(exists(gamma_subj, where = samples$BUGSoutput$mean)){
      
      nSubj = length(samples$BUGSoutput$mean[[gamma_subj]])
      
      for (subj in 1:nSubj) {
        gamma <- c(samples$BUGSoutput$mean[[gamma_subj]][subj])
        delta <- c(samples$BUGSoutput$mean[[delta_subj]][subj])
        b <- c((delta*a^gamma)/(delta*a^gamma+(1-a)^gamma)) # GE function
        par(new=T)
        lines(a,b,col=color_subj,lty=1,lwd=1)
      }

      # if hierarchical, plot legend also
      if(exists(gamma_mean, where = samples$BUGSoutput$mean)){
        
        legend(0.1, 1, inset=0, 
               legend = c(expression("Group-level estimate"), expression("Individual estimates")),
               cex = 1.2, 
               col = c(color, color_subj), horiz = F,bty = "n",
               lty = 1,  # Solid line
               lwd = 2   # Line width
        )
      } else {}
      
      # if not, don't plot individual lines
    } else {
    }
    
    
    ##### if domain-separated weigthing parameters exist, plot several lines
  } else {
    par(mfrow=c(1,2))
    
    ## plot Gain domain
    a <- c(seq(0, 1, by=.001))
    plot(a,a,"l",xlab='',ylab='',cex.axis=.7,lty=1,lwd = 2, col = "white",xpd = F, axes=F)
    axis(1, las=1, cex.axis = .7)
    axis(2, las=2, cex.axis = .7)
    box()
    title(paste("Gain domain"),cex.main = 1.5, font.main = 1)
    mtext(side = 1, text = substitute(paste("Probability (", italic("p"),")")), line = 2.5)
    mtext(side = 2, text = substitute(paste("w(", italic("p"),")")), line = 2.5)
    
    # plot dashed line
    lines(a,a,col="black",lty=2,lwd=1)
    
    # if group-level estimate exists, plot group-level
    if(exists(gamma_mean, where = samples$BUGSoutput$mean)){
      lines(a,a,col="black",lty=2,lwd =1)
      gamma <- c(samples$BUGSoutput$mean[[gamma_mean]])
      delta <- c(samples$BUGSoutput$mean[[delta_mean]])
      b <- (delta*a^gamma)/(delta*a^gamma+(1-a)^gamma) # GE function
      lines(a,b,col= color ,lty=1,lwd =3)
      
      color_subj <- grDevices::adjustcolor(color, alpha.f = 0.1)
      
      # if not, don't plot mean line
    } else {
      color_subj <- grDevices::adjustcolor(color, alpha.f = 0.5)
    }
    
    # if individual estimates exist, plot them
    if(exists(gamma_subj, where = samples$BUGSoutput$mean)){
      
      nSubj = length(samples$BUGSoutput$mean[[gamma_subj]])
      
      for (subj in 1:nSubj) {
        gamma <- c(samples$BUGSoutput$mean[[gamma_subj]][subj])
        delta <- c(samples$BUGSoutput$mean[[delta_subj]][subj])
        b <- c((delta*a^gamma)/(delta*a^gamma+(1-a)^gamma)) # GE function
        par(new=T)
        lines(a,b,col=color_subj,lty=1,lwd=1)
      }

      
      # if hierarchical, plot legend also
      if(exists(gamma_mean, where = samples$BUGSoutput$mean)){
        
        legend(0.1, 1, inset=0, 
               legend = c(expression("Group-level estimate"), expression("Individual estimates")),
               cex = 1.2, 
               col = c(color, color_subj), horiz = F,bty = "n",
               lty = 1,  # Solid line
               lwd = 2   # Line width
        )
      } else {}
      
      # if not, don't plot individual lines
    } else {
    }
    
    
    
    ## plot Loss domain
    a <- c(seq(0, 1, by=.001))
    plot(a,a,"l",xlab='',ylab='',cex.axis=.7,lty=1,lwd = 2, col = "white",xpd = F, axes=F)
    axis(1, las=1, cex.axis = .7)
    axis(2, las=2, cex.axis = .7)
    box()
    title(paste("Loss domain"),cex.main = 1.5, font.main = 1)
    mtext(side = 1, text = substitute(paste("Probability (", italic("p"),")")), line = 2.5)
    mtext(side = 2, text = substitute(paste("w(", italic("p"),")")), line = 2.5)
    
    # plot dashed line
    lines(a,a,col="black",lty=2,lwd=1)
    
    # if group-level estimate exists, plot group-level
    if(exists(gamma.loss_mean, where = samples$BUGSoutput$mean) | exists(delta.loss_mean, where = samples$BUGSoutput$mean)){
      
      lines(a,a,col="black",lty=2,lwd =1)
      
      # if(!exists(gamma.loss_mean, where = samples$BUGSoutput$mean)){gamma <- c(samples$BUGSoutput$mean[[gamma_mean]])
      # } else {                                                      
        gamma <- c(samples$BUGSoutput$mean[[gamma.loss_mean]])
      # }
      
      # if(!exists(delta.loss_mean, where = samples$BUGSoutput$mean)){delta <- c(samples$BUGSoutput$mean[[delta_mean]])
      # } else {                                                      
        delta <- c(samples$BUGSoutput$mean[[delta.loss_mean]])
      # }
        
      b <- (delta*a^gamma)/(delta*a^gamma+(1-a)^gamma) # GE function
      lines(a,b,col= color ,lty=1,lwd =3)
      
      color_subj <- grDevices::adjustcolor(color, alpha.f = 0.1)
      
      # if not, don't plot mean line
    } else {
      color_subj <- grDevices::adjustcolor(color, alpha.f = 0.5)
    }
    
    # if individual estimates exist, plot them
    if(exists(gamma_subj, where = samples$BUGSoutput$mean)){
      
      
      # if(!exists(gamma.loss_subj, where = samples$BUGSoutput$mean)){   gamma <-  c(samples$BUGSoutput$mean[gamma_subj])
      # } else {                                                         
        gamma <- c(samples$BUGSoutput$mean[[gamma.loss_subj]])
      # }
      
      # if(!exists(delta.loss_subj, where = samples$BUGSoutput$mean)){  delta <- c(samples$BUGSoutput$mean[[delta_subj]])
      # } else {                                                     
        delta <- c(samples$BUGSoutput$mean[[delta.loss_subj]])
      # }
        
        nSubj = length(samples$BUGSoutput$mean[[gamma.loss_subj]])
      
      for (subj in 1:nSubj) {
        b <- c((delta[subj]*a^gamma[subj])/(delta[subj]*a^gamma[subj]+(1-a)^gamma[subj])) # GE function
        par(new=T)
        lines(a,b,col=color_subj,lty=1,lwd=1)
      }
      
      # if hierarchical, plot legend also
      if(exists(gamma.loss_mean, where = samples$BUGSoutput$mean)){
        
        legend(0.1, 1, inset=0, 
               legend = c(expression("Group-level estimate"), expression("Individual estimates")),
               cex = 1.2, 
               col = c(color, color_subj), horiz = F,bty = "n",
               lty = 1,  # Solid line
               lwd = 2   # Line width
        )
      } else {}
      
      # if not, don't plot individual lines
    } else {
    }
    
    
    
  }
  
  
  # Record the plot and return it
  recordPlot()
  
  
} # w_fun_GE87 end
    
  
  
  

#########################################
##### weighting functions Pr98 ##########
#########################################

wf_Pr98 <- function(samples = samples, 
                    color = rgb(1/255, 100/255, 200/255, alpha = 1), # color for lines
                    domain_separation = F, # indicate if model has fitted different parameters for gain vs. loss domains - default is no
                    gamma_subj = "gamma", # individual parameter names
                    gamma.loss_subj = "gamma",
                    delta_subj = "delta", 
                    delta.loss_subj = "delta",
                    gamma_mean = "mu.gamma", # parameter names of group_level means
                    gamma.loss_mean = "mu.gamma", # by default, the function will assume no separate curvature parameter for the loss domain. if there is one, that can be specified here 
                    delta_mean = "mu.delta", # parameter names of group_level means
                    delta.loss_mean = "mu.delta" # by default, the function will assume no separate curvature parameter for the loss domain. if there is one, that can be specified here 
) {
  
  
  ##### if no domain-separation of weighting parameters exist, plot single weighting function
  if(!domain_separation){
    
    par(mfrow=c(1,1))
    
    a <- c(seq(0, 1, by=.001))
    plot(a,a,"l",xlab='',ylab='',cex.axis=.7,lty=1,lwd = 2, col = "white",xpd = F, axes=F)
    axis(1, las=1, cex.axis = .7)
    axis(2, las=2, cex.axis = .7)
    box()
    title(paste("Probability weighting function"),cex.main = 1.5, font.main = 1)
    mtext(side = 1, text = substitute(paste("Probability (", italic("p"),")")), line = 2.5)
    mtext(side = 2, text = substitute(paste("w(", italic("p"),")")), line = 2.5)
    
    # plot dashed line
    lines(a,a,col="black",lty=2,lwd=1)
    
    # if group-level estimate exists, plot group-level
    if(exists(gamma_mean, where = samples$BUGSoutput$mean)){
      
      lines(a,a,col="black",lty=2,lwd =1)
      gamma <- c(samples$BUGSoutput$mean[[gamma_mean]])
      delta <- c(samples$BUGSoutput$mean[[delta_mean]])
      # b <- (delta*a^gamma)/(delta*a^gamma+(1-a)^gamma) # GE function
      b <- exp(-delta * ((-log(a)) ^ gamma)) # Prelec function
      lines(a,b,col= color ,lty=1,lwd =3)
      
      color_subj <- grDevices::adjustcolor(color, alpha.f = 0.1)
      
      # if not, don't plot mean line
    } else {
      color_subj <- grDevices::adjustcolor(color, alpha.f = 0.5)
    }
    
    
    # if individual estimates exist, plot them
    if(exists(gamma_subj, where = samples$BUGSoutput$mean)){
      
      nSubj = length(samples$BUGSoutput$mean[[gamma_subj]])
      
      for (subj in 1:nSubj) {
        gamma <- c(samples$BUGSoutput$mean[[gamma_subj]][subj])
        delta <- c(samples$BUGSoutput$mean[[delta_subj]][subj])
        b <- exp(-delta * ((-log(a)) ^ gamma)) # Prelec function
        par(new=T)
        lines(a,b,col=color_subj,lty=1,lwd=1)
      }
      
      # if hierarchical, plot legend also
      if(exists(gamma_mean, where = samples$BUGSoutput$mean)){
        
        legend(0.1, 1, inset=0, 
               legend = c(expression("Group-level estimate"), expression("Individual estimates")),
               cex = 1.2, 
               col = c(color, color_subj), horiz = F,bty = "n",
               lty = 1,  # Solid line
               lwd = 2   # Line width
        )
      } else {}
      
      # if not, don't plot individual lines
    } else {
    }
    
    
    ##### if domain-separated weigthing parameters exist, plot several lines
  } else {
    par(mfrow=c(1,2))
    
    ## plot Gain domain
    a <- c(seq(0, 1, by=.001))
    plot(a,a,"l",xlab='',ylab='',cex.axis=.7,lty=1,lwd = 2, col = "white",xpd = F, axes=F)
    axis(1, las=1, cex.axis = .7)
    axis(2, las=2, cex.axis = .7)
    box()
    title(paste("Gain domain"),cex.main = 1.5, font.main = 1)
    mtext(side = 1, text = substitute(paste("Probability (", italic("p"),")")), line = 2.5)
    mtext(side = 2, text = substitute(paste("w(", italic("p"),")")), line = 2.5)
    
    # plot dashed line
    lines(a,a,col="black",lty=2,lwd=1)
    
    # if group-level estimate exists, plot group-level
    if(exists(gamma_mean, where = samples$BUGSoutput$mean)){
      lines(a,a,col="black",lty=2,lwd =1)
      gamma <- c(samples$BUGSoutput$mean[[gamma_mean]])
      delta <- c(samples$BUGSoutput$mean[[delta_mean]])
      b <- exp(-delta * ((-log(a)) ^ gamma)) # Prelec function
      lines(a,b,col= color ,lty=1,lwd =3)
      
      color_subj <- grDevices::adjustcolor(color, alpha.f = 0.1)
      
      # if not, don't plot mean line
    } else {
      color_subj <- grDevices::adjustcolor(color, alpha.f = 0.5)
    }
    
    # if individual estimates exist, plot them
    if(exists(gamma_subj, where = samples$BUGSoutput$mean)){
      
      nSubj = length(samples$BUGSoutput$mean[[gamma_subj]])
      
      for (subj in 1:nSubj) {
        gamma <- c(samples$BUGSoutput$mean[[gamma_subj]][subj])
        delta <- c(samples$BUGSoutput$mean[[delta_subj]][subj])
        b <- exp(-delta * ((-log(a)) ^ gamma)) # Prelec function
        par(new=T)
        lines(a,b,col=color_subj,lty=1,lwd=1)
      }
      
      
      # if hierarchical, plot legend also
      if(exists(gamma_mean, where = samples$BUGSoutput$mean)){
        
        legend(0.1, 1, inset=0, 
               legend = c(expression("Group-level estimate"), expression("Individual estimates")),
               cex = 1.2, 
               col = c(color, color_subj), horiz = F,bty = "n",
               lty = 1,  # Solid line
               lwd = 2   # Line width
        )
      } else {}
      
      # if not, don't plot individual lines
    } else {
    }
    
    
    
    ## plot Loss domain
    a <- c(seq(0, 1, by=.001))
    plot(a,a,"l",xlab='',ylab='',cex.axis=.7,lty=1,lwd = 2, col = "white",xpd = F, axes=F)
    axis(1, las=1, cex.axis = .7)
    axis(2, las=2, cex.axis = .7)
    box()
    title(paste("Loss domain"),cex.main = 1.5, font.main = 1)
    mtext(side = 1, text = substitute(paste("Probability (", italic("p"),")")), line = 2.5)
    mtext(side = 2, text = substitute(paste("w(", italic("p"),")")), line = 2.5)
    
    # plot dashed line
    lines(a,a,col="black",lty=2,lwd=1)
    
    # if group-level estimate exists, plot group-level
    if(exists(gamma.loss_mean, where = samples$BUGSoutput$mean) | exists(delta.loss_mean, where = samples$BUGSoutput$mean)){
      
      lines(a,a,col="black",lty=2,lwd =1)
      
      # if(!exists(gamma.loss_mean, where = samples$BUGSoutput$mean)){gamma <- c(samples$BUGSoutput$mean[[gamma_mean]])
      # } else {                                                      
      gamma <- c(samples$BUGSoutput$mean[[gamma.loss_mean]])
      # }
      
      # if(!exists(delta.loss_mean, where = samples$BUGSoutput$mean)){delta <- c(samples$BUGSoutput$mean[[delta_mean]])
      # } else {                                                      
      delta <- c(samples$BUGSoutput$mean[[delta.loss_mean]])
      # }
      
      b <- exp(-delta * ((-log(a)) ^ gamma)) # Prelec function
      lines(a,b,col= color ,lty=1,lwd =3)
      
      color_subj <- grDevices::adjustcolor(color, alpha.f = 0.1)
      
      # if not, don't plot mean line
    } else {
      color_subj <- grDevices::adjustcolor(color, alpha.f = 0.5)
    }
    
    # if individual estimates exist, plot them
    if(exists(gamma_subj, where = samples$BUGSoutput$mean)){
      
      
      # if(!exists(gamma.loss_subj, where = samples$BUGSoutput$mean)){   gamma <-  c(samples$BUGSoutput$mean[gamma_subj])
      # } else {                                                         
      gamma <- c(samples$BUGSoutput$mean[[gamma.loss_subj]])
      # }
      
      # if(!exists(delta.loss_subj, where = samples$BUGSoutput$mean)){  delta <- c(samples$BUGSoutput$mean[[delta_subj]])
      # } else {                                                     
      delta <- c(samples$BUGSoutput$mean[[delta.loss_subj]])
      # }
      
      nSubj = length(samples$BUGSoutput$mean[[gamma.loss_subj]])
      
      for (subj in 1:nSubj) {
        b <- exp(-delta * ((-log(a)) ^ gamma)) # Prelec function
        par(new=T)
        lines(a,b,col=color_subj,lty=1,lwd=1)
      }
      
      # if hierarchical, plot legend also
      if(exists(gamma.loss_mean, where = samples$BUGSoutput$mean)){
        
        legend(0.1, 1, inset=0, 
               legend = c(expression("Group-level estimate"), expression("Individual estimates")),
               cex = 1.2, 
               col = c(color, color_subj), horiz = F,bty = "n",
               lty = 1,  # Solid line
               lwd = 2   # Line width
        )
      } else {}
      
      # if not, don't plot individual lines
    } else {
    }
    
    
    
  }
  
  
  # Record the plot and return it
  recordPlot()
  
  
} # wf_Pr98 end



