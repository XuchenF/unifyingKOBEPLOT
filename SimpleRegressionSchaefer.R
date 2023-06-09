#After reading data
##################################################################
#Schaefer form
cpue<-anc[,4]
N<-length(cpue)
#please notice this, this number we need to use several times below
Y<-cpue[2:N]/cpue[1:N-1]-1
X1<-cpue[1:N-1]
effort<-anc[,2]/cpue
X2<-effort[-N]
PMLM<-lm(Y~X1+X2)
r<- coef(PMLM)[1]
q<--coef(PMLM)[3]
k<--r/coef(PMLM)[2]/q

#visual presentation
#See whether data approach normal distribution
opar <- par(no.readonly=TRUE)
par(mfrow=c(1,3))
qqnorm(Y, main="(CPUEt+1/CPUE)-1")
qqline(Y)
qqnorm(X1, main="CPUE")
qqline(X1)
qqnorm(X2, main="effort")
qqline(X2)

#summary(PMLM)
par(mfrow=c(1,2))
plot(X1, Y, xlab="CPUE", ylab="(CPUEt+1/CPUE)-1")
lines(X1, fitted(PMLM))
plot(X2, Y, xlab="effort", ylab="(CPUEt+1/CPUE)-1")
lines(X2, fitted(PMLM))

#comparison predictive CPUE and observed CPUE
par(opar)
catch<-anc[,2]
BiomassF<-function(r,k,C,Bt)
{
  Bt_1=Bt+r*Bt*(1-Bt/k)-C
}
B<-numeric(length(catch))
B[1]<-cpue[1]/q
for(i in 2:length(catch)){
B[i]=BiomassF(r, k, catch[i-1], B[i-1])  
}
plot(anc[,1], anc[,4], ylim=c(-0.5,1.3), xlab="year", ylab="CPUE")
points(anc[,1], q*B, pch=24)
legend("top", legend=c("prediction", "observation"), bty="n", pch=c(24, 1), horiz=T)
