library(anytime)
library(tscount)
library(SAPP)
library(lubridate)

source('~/SEPP_Fcn.R')

fb <- read.table("~/facebook-wall.txt",
                 header = F)
fb <- fb[order(fb$V4),]
fb_tstp <- fb$V4
fb_iet_hrs <- (diff(fb_tstp)/3600)
fb_days <- cumsum(fb_iet_hrs)/24
CDT = 'America/Chicago'

###################
FB_exp0 <- readRDS('fb_new_exp_sepp0.rds')

beta_hat_NLS <- unlist(sapply(2:110,
                                function(x) FB_exp0$param[[x]][4]))
eta_hat_NLS <- unlist(sapply(2:110,
                                function(x) FB_exp0$param[[x]][1]))
K_hat_NLS <- unlist(sapply(2:110,
                           function(x) FB_exp0$param[[x]][2]))  
ind_del <- which(K_hat_NLS<0)
pdf('fb_exp_est.pdf', width = 10, height = 4)
par(mfrow = c(1,3))
plot(eta_hat_NLS, type = 's', col=4,
     xlab = '', ylab = 'eta_hat')
plot(K_hat_NLS/beta_hat_NLS, type = 's',
     xlab='', ylab = 'K_hat', col=4)
abline(h = 0, lty=2, col=2)
plot(beta_hat_NLS, type = 's',
     xlab='', ylab = 'beta_hat', col=4)
abline(h = 0, lty=2, col=2)
dev.off()

ks_results <- sapply(setdiff(2:110, c(51,90)),
                     function(i) ks_fit(FB_exp0$Trans_Time[[i]]))
ks_dist_NLS <- unlist(sapply(1:length(ks_results[1,]),
                             function(i) ks_results[,i][1]))
ks_p_NLS <- unlist(sapply(1:length(ks_results[1,]),
                          function(i) ks_results[,i][2]))
mean(ks_p_NLS>0.05)
mean(ks_p_NLS>0.01)

#######
fb_counts_daily <- split(data.frame(fb_tstp),
                         as.Date(cut(anytime(fb_tstp, 
                                             tz = CDT), "DSTday")))

pdf('sleep_fb_compare.pdf', width = 10, height = 4)
par(mfrow = c(1,3))
fb_0504_start <- which(attributes(fb_counts_daily)$names == '2005-04-10')
fb_0504_end <- which(attributes(fb_counts_daily)$names == '2005-04-20')
sleep(fb_counts_daily, fb_tstp, CDT, fb_0504_start, fb_0504_end, c(1,7))

fb_0605_start <- which(attributes(fb_counts_daily)$names == '2006-05-20')
fb_0605_end <- which(attributes(fb_counts_daily)$names == '2006-05-30')
sleep(fb_counts_daily, fb_tstp, CDT, fb_0605_start, fb_0511_end, c(1,7))

fb_0705_start <- which(attributes(fb_counts_daily)$names == '2007-05-10')
fb_0705_end <- which(attributes(fb_counts_daily)$names == '2007-05-20')
sleep(fb_counts_daily, fb_tstp, CDT, fb_0705_start, fb_0705_end, c(1,7))
dev.off()

pdf('fb_acf.pdf', width = 10, height = 8)
par(mfrow = c(5,5))
for(i in (1:length(FB$Trans_Time))){
  acf(diff(FB$Trans_Time[[i]][,2]), main='')
}
dev.off()


###

