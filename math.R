math_overflow <- read.table('~/sx-mathoverflow.txt', header = F)
math_overflow <- math_overflow[order(math_overflow$V3),]
math_tstp <- math_overflow$V3
math_counts_daily <- split(data.frame(math_tstp),
                         as.Date(cut(anytime(math_tstp), "DSTday")))
math_exp_fst <- readRDS('math_exp_sepp_fst.rds')

ks_fst <- ks_result_fcn(math_exp_fst, 
                        2:length(math_exp_fst$Trans_Time),
                        c())
est_fst <- est_result_fcn(math_exp_fst)

## Pass rate
mean(ks_fst$ks_p > 0.01)
mean(ks_fst$ks_p > 0.05)

eta_fst <- est_fst$eta
K_fst <- est_fst$K
beta_fst <- est_fst$beta



pdf('math_est_fst.pdf', width = 10, height = 4)
par(mfrow = c(1,3))
plot(eta_fst[-1], type = 's', col=4, xlab = '',
     ylab = 'eta_hat')
     
abline( h =0, col=2, lty =2)

plot(K_fst[-1], type = 's', col=4, xlab = '',
     ylab = 'K_hat')
abline(h=c(0,1), lty=2, col=2)

plot(beta_fst[-1], type = 's', col=4, xlab = '',
     ylab = 'beta_hat')
abline(h=0, lty=2, col=2)
dev.off()

pdf('math_sepp_acf.pdf', width = 10, height = 25)
par(mfrow = c(14,5))
for(i in 2:length(math_exp_fst$Trans_Time)){
  acf(diff(math_exp_fst$Trans_Time[[i]][-1]), main='')
}
dev.off()


math_list_names <- attributes(math_counts_daily)$names
pdf('math_sleep.pdf', width = 10, height = 4)
par(mfrow = c(1,3))
sleep(math_counts_daily, math_tstp, CDT, 6, 
      10, c(0,8))
sleep(math_counts_daily, math_tstp, CDT, 371, 
      375, c(0,8))
sleep(math_counts_daily, math_tstp, CDT, 1141, 
      1145 , c(0,8))
dev.off()

pois_test(math_counts_daily, '2009-10-01', '2009-12-31', CDT, c(0,0))
pois_test(math_counts_daily, '2010-01-01', '2010-12-31', CDT, c(0,0))
pois_test(math_counts_daily, '2011-01-01', '2011-12-31', CDT, c(0,0))
pois_test(math_counts_daily, '2012-01-01', '2012-12-31', CDT, c(0,0))
pois_test(math_counts_daily, '2013-01-01', '2013-12-31', CDT, c(0,0))
pois_test(math_counts_daily, '2014-01-01', '2014-12-31', CDT, c(0,0))
pois_test(math_counts_daily, '2015-01-01', '2015-12-31', CDT, c(0,0))

a = which(math_list_names=='2011-01-01')
b = which(math_list_names=='2011-02-28')

pdf('math_nhpp_acf.pdf', width = 10, height = 20)
par(mfrow = c(12,5))
for (i in a:b){
  acf(diff(math_counts_daily[[i]]$math_tstp), main='')
}
dev.off()


#########################

