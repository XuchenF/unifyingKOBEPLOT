#same as what we did for sraplus  refered to R package ("datalimited2") cfree14/datalimited2
#we added overexploited(red), recovering(yellow), health(green), overfishing(orange) area with color marks for OCOM plot section.
#the adding context is in the final, others are the same as OCOM original codes.
# Plot OCOM results
plot_ocom <- function(output){
  
  # Unpack output
  ref_ts <- output[["ref_ts"]]
  ref_pts <- output[["ref_pts"]]
  krms_draws <- output[["krms_draws"]]
  yr1 <- min(ref_ts$year)
  yr2 <- max(ref_ts$year)
  bbmsy_final <- ref_ts$bbmsy[nrow(ref_ts)]
  ffmsy_final <- ref_ts$ffmsy[nrow(ref_ts)]
  
  # Plot settings
  par(mfrow=c(2,3), xpd=NA)
  
  # A. Catch
  #################################
  
  # Plot catch
  xmin <- floor(min(ref_ts$year) / 10) * 10
  xmax <- ceiling(max(ref_ts$year) / 10) * 10
  plot(catch ~ year, ref_ts, bty="n", las=1, type="n",
       xlim=c(xmin, xmax), xlab="", ylab="Catch", main="A. Catch")
  # Add MSY shading
  rect(xleft=xmin, xright=xmax,
       ybottom=ref_pts$q0.025[ref_pts$param=="msy"],
       ytop=ref_pts$q0.975[ref_pts$param=="msy"], col="grey80", border=F)
  # Add catch
  lines(ref_ts$year, ref_ts$catch, lwd=1.1)
  # Add MSY line and stats
  lines(x=c(xmin, xmax), y=rep(ref_pts$q0.5[ref_pts$param=="msy"], 2), lty=2)
  text(x=xmax-5, y=ref_pts$q0.5[ref_pts$param=="msy"], pos=c(3), labels="MSY", font=2)
  
  # B. Viable and best r/k pairs
  ##############################################################################
  
  # Plot viable r-k pairs
  plot(krms_draws$k, krms_draws$r, log="xy", bty="l", col="grey80", las=1,
       xlab="K", ylab='r', main="B. Viable r-k pairs")
  
  # Add best r-k pair
  r <- ref_pts$q0.5[ref_pts$param=="r"]
  r_hi <- ref_pts$q0.975[ref_pts$param=="r"]
  r_lo <- ref_pts$q0.025[ref_pts$param=="r"]
  k <- ref_pts$q0.5[ref_pts$param=="k"]
  k_hi <- ref_pts$q0.975[ref_pts$param=="k"]
  k_lo <- ref_pts$q0.025[ref_pts$param=="k"]
  points(k, r, pch=16, cex=1.3)
  lines(x=c(k_lo, k_hi), y=c(r,r))
  lines(x=c(k, k), y=c(r_lo,r_hi))
  
  
  # C. B/BMSY time series
  ##############################################################################
  
  # Setup empty plot
  xmin <- floor(min(ref_ts$year) / 10) * 10
  xmax <- ceiling(max(ref_ts$year) / 10) * 10
  plot(bbmsy ~ year, ref_ts, type="n", bty="n", las=1,
       xlim=c(xmin, xmax), ylim=c(0,2), xlab="", ylab=expression("B / B"["MSY"]),
       main=expression(bold("C. B/B"["MSY"])))
  # Add randomly selected trajectories
  # for(i in 1:ncol(bbmsy_trajs)){lines(x=ref_ts$year, y=bbmsy_trajs[,i], col="grey80")}
  polygon(x=c(ref_ts$year, rev(ref_ts$year)),
          y=c(ref_ts$bbmsy_lo, rev(ref_ts$bbmsy_hi)), col="grey80", border=F)
  # Add median and 95% CI trajectories
  lines(x=ref_ts$year, y=ref_ts$bbmsy, lwd=1.1)
  # Add overfished line (B/BMSY=0.5)
  lines(x=c(xmin, xmax), y=c(0.5, 0.5), lty=3)
  lines(x=c(xmin, xmax), y=c(1, 1), lty=2)
  # Label end year B/BMSY
  text(x=yr2, y=bbmsy_final, label=round(bbmsy_final,2), pos=4)
  
  # D. F/FMSY time series
  ##############################################################################
  
  # Setup empty plot
  xmin <- floor(min(ref_ts$year) / 10) * 10
  xmax <- ceiling(max(ref_ts$year) / 10) * 10
  ymax <- ceiling(max(ref_ts$ffmsy_hi) / 0.5) * 0.5
  plot(ffmsy ~ year, ref_ts, type="n", bty="n", las=1,
       xlim=c(xmin, xmax), ylim=c(0,ymax), xlab="", ylab=expression("F / F"["MSY"]),
       main=expression(bold("D. F/F"["MSY"])))
  # Add polygon and line
  polygon(x=c(ref_ts$year, rev(ref_ts$year)),
          y=c(ref_ts$ffmsy_lo, rev(ref_ts$ffmsy_hi)), col="grey70", border=F)
  lines(x=ref_ts$year, y=ref_ts$ffmsy, lwd=1.1)
  # Label end year F/FMSY
  lines(x=c(xmin, xmax), y=c(1, 1), lty=2)
  text(x=yr2, y=ffmsy_final, label=round(ffmsy_final,2), pos=4, xpd=NA)
  
  # E. Kobe plot
  ##############################################################################
  
  # Setup plot
  xmax <- ceiling(max(ref_ts$bbmsy) / 0.5) * 0.5
  ymax <- ceiling(max(ref_ts$ffmsy) / 0.5) * 0.5
  plot(ffmsy ~ bbmsy, ref_ts, bty="n", type="l", las=1,
       xlim=c(0,xmax), ylim=c(0,ymax), main="E. Kobe plot",
       xlab=expression("B / B"["MSY"]), ylab=expression("F / F"["MSY"]))
  lines(x=c(0, xmax), y=c(1,1), lty=2)
  lines(x=c(1, 1), y=c(0,ymax), lty=2)
  # Add start/end points
  points(x=ref_ts$bbmsy[1], y=ref_ts$ffmsy[1], pch=22, cex=1.4, bg="white")
  points(x=ref_ts$bbmsy[nrow(ref_ts)], y=ref_ts$ffmsy[nrow(ref_ts)], pch=22, cex=1.4, bg="grey70")
  # Add points legend
  legend("topright", bty="n", legend=c(yr1, yr2), pch=22, pt.bg=c("white", "grey70"), pt.cex=1.4)
  
  


#Kobe plot similar to the cmsy
plot(1000,1000,type="b", xlim=c(0,2), ylim=c(0,2),lty=3,xlab="",ylab=expression(F/F[MSY]), bty="l",  cex.main = 2, cex.lab = 1.35, cex.axis = 1.35,xaxs = "i",yaxs="i")
mtext(expression(B/B[MSY]),side=1, line=3, cex=0.9)
c1 <- c(0,2)
c2 <- c(1,1)
zb2 = c(0,1)
zf2  = c(1,2)
zb1 = c(1,2)
zf1  = c(0,1)
polygon(c(zb1,rev(zb1)),c(0,0,1,1),col="green",border=0)
polygon(c(zb2,rev(zb2)),c(0,0,1,1),col="yellow",border=0)
polygon(c(1,2,2,1),c(1,1,2,2),col="orange",border=0)
polygon(c(0,1,1,0),c(1,1,2,2),col="red",border=0)
points(ref_ts$bbmsy, ref_ts$ffmsy, col=1, bg="black", cex=1.1, pch=19)
lines(c1,c2,lty=3,lwd=0.7)
lines(c2,c1,lty=3,lwd=0.7)
lines(ref_ts$bbmsy,ref_ts$ffmsy, lty=1,lwd=1.)
points(x=ref_ts$bbmsy[1], y=ref_ts$ffmsy[1],col=1,pch=22,bg="white",cex=1.4)
points(x=ref_ts$bbmsy[nrow(ref_ts)], y=ref_ts$ffmsy[nrow(ref_ts)],col=1,pch=24,bg="white",cex=1.4)
legend("topright",bty="n", legend=c(yr1, yr2), pch=c(22,24), pt.bg="white", pt.cex=1.4)
}
