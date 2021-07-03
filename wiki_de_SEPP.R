library(anytime)
library(tscount)
library(SAPP)
library(lubridate)
library(fitdistrplus)
source('~/SEPP_Fcn.R')

wiki_de <- read.table('~/out_wiki_talk_de.txt',
                      header = F)
wiki_de <- wiki_de[order(wiki_de$V4),]
wiki_de_tstp <- wiki_de$V4

de_users <- read.table('~/de-user-group')
de_bots <- de_users[de_users[,2] == 1 | de_users[,2] == 2,]
de_msg_bots <- sapply(de_bots$V1, function(x) which(wiki_de$V1 == x))
de_msg_bots <- c(unlist(de_msg_bots),
                 unlist(sapply(de_bots$V1, function(x) which(wiki_de$V2 == x))))
wiki_de_tstp_nobots <- wiki_de_tstp[-de_msg_bots]
wiki_de_tstp <- wiki_de_tstp_nobots
wiki_de <- wiki_de[-de_msg_bots,]

de_counts_daily <- split(data.frame(wiki_de_tstp),
                         as.Date(cut(anytime(wiki_de_tstp, 
                                             tz = DE), "DSTday")))
de_list_names <- attributes(de_counts_daily)$names
end_de <- which(de_list_names == '2014-12-31')
de_counts_daily <- de_counts_daily[1:end_de]
wiki_de_tstp <- wiki_de_tstp[1:5863373]
save(wiki_de_tstp, de_counts_daily, wiki_de, file = 'wiki_de_tstp.RData')

load('wiki_de_tstp.RData')
wiki_de_tstp <- unique(wiki_de_tstp)

de_iet_hrs <- (diff(wiki_de_tstp)/3600)
wiki_de_days <- cumsum(de_iet_hrs)/24
DE = 'Europe/Berlin'

pdf('wiki_de_evo.pdf', width = 8, height = 4)
start_de <- min(which(as.Date(anytime(wiki_de_tstp,tz=DE)) >= as.Date('2003-01-01')))
end_de<- max(which(as.Date(anytime(wiki_de_tstp,tz=DE)) == as.Date('2013-12-31')))
par(mfrow=c(1,2))
plot(as.Date(anytime(wiki_de_tstp[start_de:end_de], tz=DE)),
          (start_de:end_de), type='s',
          xlab = '', ylab='Cumulative Number of Edges')
hist(anytime(wiki_de_tstp[start_de:end_de], tz=DE),
          freq=T, breaks = 'weeks', xlab = '', main='')
dev.off()


###########
wiki_de_exp_fst2 <- readRDS('de_exp_sepp_fst2.rds')
wrong_ind_fst2 <- c(27,39,83,117,163,166,174,175,179)
ks_fst2 <- ks_result_fcn(wiki_de_exp_fst2, 
                       2:length(wiki_de_exp_fst2$Trans_Time),
                       wrong_ind_fst2)
est_fst2 <- est_result_fcn(wiki_de_exp_fst2)

## Pass rate
mean(ks_fst2$ks_p[1:82][-26] > 0.01)
mean(ks_fst2$ks_p[1:82][-26] > 0.05)
mean(ks_fst2$ks_p > 0.01)
mean(ks_fst2$ks_p > 0.05)

eta_fst2 <- est_fst2$eta[-1]
K_fst2 <- est_fst2$K[-1]
beta_fst2 <- est_fst2$beta[-1]

start_day <- min(which(as.Date(anytime(wiki_de_tstp, DE)) >= '2003-01-01'))
end_day <- max(which(as.Date(anytime(wiki_de_tstp,DE)) < '2005-01-01')) 
time_idx <- seq(start_day, end_day, by = 500)
wiki_de_dates <- as.Date(anytime(wiki_de_tstp[time_idx],tz = DE))
wiki_de_wkdays <- weekdays(wiki_de_dates)
de_df_fst2 <- data.frame(days = setdiff(2:length(time_idx), wrong_ind_fst2), 
                         eta = eta_fst2, beta = beta_fst2, K = K_fst2,
                          wkday = wiki_de_wkdays[-c(1,wrong_ind_fst2)])


pdf('de_est_fst2.pdf', width = 10, height = 4)
par(mfrow = c(1,3))
plot(eta_fst2, type = 's', col=4, xlab = '',
     ylab = 'eta_hat')
abline(h = 0, lty=2, col=2)


plot(K_fst2, type = 's', col=4, xlab = '',
     ylab = 'K_hat')
abline(h=c(0,1), lty=2, col=2)

plot(beta_fst2, type = 's', col=4, xlab = '',
     ylab = 'beta_hat')
abline(h=0, lty=2, col=2)
dev.off()
#####

# Poisson growth
pois_test(de_counts_daily, '2004-07-01', '2004-12-31', DE, c(0,8))
pois_test(de_counts_daily, '2005-01-01', '2005-12-31', DE, c(0,8))
pois_test(de_counts_daily, '2006-01-01', '2006-12-31', DE, c(0,8))
pois_test(de_counts_daily, '2007-01-01', '2007-12-31', DE, c(0,8))
pois_test(de_counts_daily, '2008-01-01', '2008-12-31', DE, c(0,8))
pois_test(de_counts_daily, '2009-01-01', '2009-12-31', DE, c(0,8))
pois_test(de_counts_daily, '2010-01-01', '2010-12-31', DE, c(0,8))
pois_test(de_counts_daily, '2011-01-01', '2011-12-31', DE, c(0,8))
pois_test(de_counts_daily, '2012-01-01', '2012-12-31', DE, c(0,8))
pois_test(de_counts_daily, '2013-01-01', '2013-12-31', DE, c(0,8))



