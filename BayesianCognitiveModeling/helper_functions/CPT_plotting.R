
color = rgb(1/255, 100/255, 200/255, alpha = 1)

######################################
####### value function TK92 ##########
######################################
v_fun_TK92 <- function(samples = samples, color = rgb(1/255, 100/255, 200/255, alpha = 1)) {
  par(mfrow=c(1,1))
  a <- seq(-100, 100, by=0.1)
  plot(a, a, "l", axes=FALSE, xlab='', ylab='', cex.axis=.7, lty=2, lwd=1, ylim=c(-10, 10), xlim=c(-20, 20), col="white")
  par(xpd=FALSE)
  title(paste("Value function"), cex.main=1.5, font.main=1)
  axis(1, seq(from=-20, to=20, by=5), pos=0, cex.axis=.6, mgp=c(3, .1, 1), tck=-.01)
  axis(2, seq(from=-10, to=10, by=2), pos=0, cex.axis=.6, tck=-.01, las=1, mgp=c(3, 0.6, 0))
  mtext(side=1, text="Outcome", line=1)
  mtext(side=2, text="Subjective Value", line=.5)
  
  # plot dashed line
  lines(a,a,col="black",lty=2,lwd=1)

  # if group-level estimate exists, plot group-level
  if(exists("mu.alpha", where = samples$BUGSoutput$mean)){
    alpha   <- c(samples$BUGSoutput$mean$mu.alpha)
    lambda  <- c(samples$BUGSoutput$mean$mu.lambda)
    b       <- c(-lambda*(-a[1:1000])^alpha, 
                 a[1001:2001]^alpha)
    lines(a, b, col=color, lty=1, lwd=2)
    
    color_subj <- grDevices::adjustcolor(color, alpha.f = 0.1)
    
    # if not, don't plot mean line
  } else {
    
    color_subj <- grDevices::adjustcolor(color, alpha.f = 0.5)
  }
  
  
  # if individual estimates exist, plot them
  if(exists("alpha", where = samples$BUGSoutput$mean)){
    
    for (subj in 1:nSubj) { # get individual curves
      alpha <- c(samples$BUGSoutput$mean$alpha[subj])
      lambda <- c(samples$BUGSoutput$mean$lambda[subj])
      b <- c(-lambda*(-a[1:1000])^alpha, 
             a[1001:2001]^alpha)
      par(new=TRUE)
      lines(a, b, col=color_subj, lty=1, lwd=1)
    }
    
    # if hierarchical, plot legend also
    if(exists("mu.alpha", where = samples$BUGSoutput$mean)){
      
      legend(1, -2, inset=0, 
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
   
  # Record the plot and return it
  recordPlot()
  
} # v_fun_TK92 end

  
#########################################
##### weighting functions TK92 ##########
#########################################

  w_fun_TK92 <- function(samples = samples, color = rgb(1/255, 100/255, 200/255, alpha = 1)) {
    
    
  ##### if no domain-separation of weighting parameters exist, plot single weighting function
    if(!exists("gamma.loss", where = samples$BUGSoutput$mean) && !exists("mu.gamma.loss", where = samples$BUGSoutput$mean) ){

    #par(mfrow=c(2,2)) # par(mfrow=c(2,1))
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
  if(exists("mu.gamma", where = samples$BUGSoutput$mean)){
    gamma <- c(samples$BUGSoutput$mean$mu.gamma)
    b <- (a^gamma)/((a^gamma+(1-a)^gamma)^(1/gamma)) # TK function
    lines(a,b,col= color ,lty=1,lwd =3)
    
    color_subj <- grDevices::adjustcolor(color, alpha.f = 0.1)
    
    # if not, don't plot mean line
  } else {
    color_subj <- grDevices::adjustcolor(color, alpha.f = 0.5)
  }
  
  
  
  
  # if individual estimates exist, plot them
  if(exists("gamma", where = samples$BUGSoutput$mean)){
    
    for (subj in 1:nSubj) {
      gamma <- c(samples$BUGSoutput$mean$gamma[subj])
      b <- (a^gamma)/((a^gamma+(1-a)^gamma)^(1/gamma)) # TK function
      par(new=T)
      lines(a,b,col=color_subj,lty=1,lwd=1)
    }
    
    # if hierarchical, plot legend also
    if(exists("mu.alpha", where = samples$BUGSoutput$mean)){
      
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
      par(mfrow=c(2,2))
      
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
      if(exists("mu.gamma", where = samples$BUGSoutput$mean)){
        gamma <- c(samples$BUGSoutput$mean$mu.gamma)
        b <- (a^gamma)/((a^gamma+(1-a)^gamma)^(1/gamma)) # TK function
        lines(a,b,col= color ,lty=1,lwd =3)
        
        color_subj <- grDevices::adjustcolor(color, alpha.f = 0.1)
        
        # if not, don't plot mean line
      } else {
        color_subj <- grDevices::adjustcolor(color, alpha.f = 0.5)
      }
      
      # if individual estimates exist, plot them
      if(exists("gamma", where = samples$BUGSoutput$mean)){
        
        for (subj in 1:nSubj) {
          gamma <- c(samples$BUGSoutput$mean$gamma[subj])
          b <- (a^gamma)/((a^gamma+(1-a)^gamma)^(1/gamma)) # TK function
          par(new=T)
          lines(a,b,col=color_subj,lty=1,lwd=1)
        }
        
        # if hierarchical, plot legend also
        if(exists("mu.gamma", where = samples$BUGSoutput$mean)){
          
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
      if(exists("mu.gamma.loss", where = samples$BUGSoutput$mean)){
        gamma <- c(samples$BUGSoutput$mean$mu.gamma.loss)
        b <- (a^gamma)/((a^gamma+(1-a)^gamma)^(1/gamma)) # TK function
        lines(a,b,col= color ,lty=1,lwd =3)
        
        color_subj <- grDevices::adjustcolor(color, alpha.f = 0.1)
        
        # if not, don't plot mean line
      } else {
        color_subj <- grDevices::adjustcolor(color, alpha.f = 0.5)
      }
      
      # if individual estimates exist, plot them
      if(exists("gamma.loss", where = samples$BUGSoutput$mean)){
        
        for (subj in 1:nSubj) {
          gamma <- c(samples$BUGSoutput$mean$gamma.loss[subj])
          b <- (a^gamma)/((a^gamma+(1-a)^gamma)^(1/gamma)) # TK function
          par(new=T)
          lines(a,b,col=color_subj,lty=1,lwd=1)
        }
        
        # if hierarchical, plot legend also
        if(exists("mu.gamma.loss", where = samples$BUGSoutput$mean)){
          
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

w_fun_GE87 <- function(samples = samples, color = rgb(1/255, 100/255, 200/255, alpha = 1)) {
  
  
  ##### if no domain-separation of weighting parameters exist, plot single weighting function
  if(!exists("gamma.loss", where = samples$BUGSoutput$mean) && !exists("mu.gamma.loss", where = samples$BUGSoutput$mean) && !exists("delta.loss", where = samples$BUGSoutput$mean) && !exists("mu.delta.loss", where = samples$BUGSoutput$mean)){

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
    if(exists("mu.gamma", where = samples$BUGSoutput$mean)){
      
      lines(a,a,col="black",lty=2,lwd =1)
      gamma <- c(samples$BUGSoutput$mean$mu.gamma)
      delta <- c(samples$BUGSoutput$mean$mu.delta)
      b <- (delta*a^gamma)/(delta*a^gamma+(1-a)^gamma) # GE function
      lines(a,b,col= color ,lty=1,lwd =3)
      
      color_subj <- grDevices::adjustcolor(color, alpha.f = 0.1)
      
      # if not, don't plot mean line
    } else {
      color_subj <- grDevices::adjustcolor(color, alpha.f = 0.5)
    }
    
    
    # if individual estimates exist, plot them
    if(exists("gamma", where = samples$BUGSoutput$mean)){
      
      for (subj in 1:nSubj) {
        gamma <- c(samples$BUGSoutput$mean$gamma[subj])
        delta <- c(samples$BUGSoutput$mean$delta[subj])
        b <- c((delta*a^gamma)/(delta*a^gamma+(1-a)^gamma)) # GE function
        par(new=T)
        lines(a,b,col=color_subj,lty=1,lwd=1)
      }

      # if hierarchical, plot legend also
      if(exists("mu.alpha", where = samples$BUGSoutput$mean)){
        
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
    par(mfrow=c(2,2))
    
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
    if(exists("mu.gamma", where = samples$BUGSoutput$mean)){
      lines(a,a,col="black",lty=2,lwd =1)
      gamma <- c(samples$BUGSoutput$mean$mu.gamma)
      delta <- c(samples$BUGSoutput$mean$mu.delta)
      b <- (delta*a^gamma)/(delta*a^gamma+(1-a)^gamma) # GE function
      lines(a,b,col= color ,lty=1,lwd =3)
      
      color_subj <- grDevices::adjustcolor(color, alpha.f = 0.1)
      
      # if not, don't plot mean line
    } else {
      color_subj <- grDevices::adjustcolor(color, alpha.f = 0.5)
    }
    
    # if individual estimates exist, plot them
    if(exists("gamma", where = samples$BUGSoutput$mean)){
      
      for (subj in 1:nSubj) {
        gamma <- c(samples$BUGSoutput$mean$gamma[subj])
        delta <- c(samples$BUGSoutput$mean$delta[subj])
        b <- c((delta*a^gamma)/(delta*a^gamma+(1-a)^gamma)) # GE function
        par(new=T)
        lines(a,b,col=color_subj,lty=1,lwd=1)
      }

      
      # if hierarchical, plot legend also
      if(exists("mu.gamma", where = samples$BUGSoutput$mean)){
        
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
    if(exists("mu.gamma.loss", where = samples$BUGSoutput$mean) | exists("mu.delta.loss", where = samples$BUGSoutput$mean)){
      
      lines(a,a,col="black",lty=2,lwd =1)
      
      if(!exists("mu.gamma.loss", where = samples$BUGSoutput$mean)){gamma <- c(samples$BUGSoutput$mean$mu.gamma)
      } else {                                                      gamma <- c(samples$BUGSoutput$mean$mu.gamma.loss)
      }
      
      if(!exists("mu.delta.loss", where = samples$BUGSoutput$mean)){delta <- c(samples$BUGSoutput$mean$mu.delta)
      } else {                                                      delta <- c(samples$BUGSoutput$mean$mu.delta.loss)
      }
        
      b <- (delta*a^gamma)/(delta*a^gamma+(1-a)^gamma) # GE function
      lines(a,b,col= color ,lty=1,lwd =3)
      
      color_subj <- grDevices::adjustcolor(color, alpha.f = 0.1)
      
      # if not, don't plot mean line
    } else {
      color_subj <- grDevices::adjustcolor(color, alpha.f = 0.5)
    }
    
    # if individual estimates exist, plot them
    if(exists("gamma.loss", where = samples$BUGSoutput$mean)){
      
      
      if(!exists("gamma.loss", where = samples$BUGSoutput$mean)){   c(gamma <- samples$BUGSoutput$mean$gamma)
      } else {                                                      c(gamma <- samples$BUGSoutput$mean$gamma.loss)
      }
      
      if(!exists("delta.loss", where = samples$BUGSoutput$mean)){  c(delta <- samples$BUGSoutput$mean$delta)
      } else {                                                     c(delta <- samples$BUGSoutput$mean$delta.loss)
      }
      
      for (subj in 1:nSubj) {
        b <- c((delta[subj]*a^gamma[subj])/(delta[subj]*a^gamma[subj]+(1-a)^gamma[subj])) # GE function
        par(new=T)
        lines(a,b,col=color_subj,lty=1,lwd=1)
      }
      
      # if hierarchical, plot legend also
      if(exists("mu.gamma.loss", where = samples$BUGSoutput$mean)){
        
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
    
  
  
  

