
load('~/wikiNoBotRl.RData')
wiki_nl_tstp <- wikiNoBotRl[,3]
NL='Europe/Amsterdam'
start_tstp <- min(which(as.Date(anytime(wiki_nl_tstp,tz=NL)) >= as.Date('2003-01-01')))
end_tstp <- max(which(as.Date(anytime(wiki_nl_tstp,tz=NL))  == '2003-12-31')) 



nl_counts_daily <- split(data.frame(wiki_nl_tstp),
                         as.Date(cut(anytime(wiki_nl_tstp, 
                                             tz = NL), "DSTday")))
                                             
nl_list_names <- attributes(nl_counts_daily)$names                                             
                                             

pdf('wiki_nl_evo.pdf', width = 8, height = 4)
par(mfrow = c(1,2))
plot(as.Date(anytime(wiki_nl_tstp[start_tstp:end_tstp], tz=NL)),
     (start_tstp:end_tstp), type='s',
     xlab = '', ylab='Cumulative Number of Edges')
hist(anytime(wiki_nl_tstp[start_tstp:end_tstp], tz=NL),
     freq=T, breaks = 'weeks', xlab = '', main='')
dev.off()

ks_result_fcn <- function(model,index, wrong){
  ks_results <- sapply(setdiff(2:length(model$Trans_Time), wrong),
                       function(i) ks_fit(model$Trans_Time[[i]][-1]))
  ks_dist_NLS <- unlist(sapply(1:length(ks_results[1,]),
                               function(i) ks_results[,i][1]))
  ks_p_NLS <- unlist(sapply(1:length(ks_results[1,]),
                            function(i) ks_results[,i][2]))
  return(list(ks_dist = ks_dist_NLS, ks_p = ks_p_NLS))
}
est_result_fcn <- function(model){
  eta_hat <- unlist(sapply(1:length(model$param),
                            function(x) model$param[[x]][1]))
  K_hat <- unlist(sapply(1:length(model$param),
                  function(x) model$param[[x]][2]))
  beta_hat <- unlist(sapply(1:length(model$param),
                            function(x) model$param[[x]][4]))
  return(list(eta = eta_hat, K = K_hat/beta_hat, beta = beta_hat))
}
# From 2003-01-01 to 2005-12-31
wiki_nl_exp_fst3 <- readRDS('nl_exp_sepp_fst3.rds')
wrong_ind_fst3 <- 144
ks_fst3 <- ks_result_fcn(wiki_nl_exp_fst3, 
                         2:length(wiki_nl_exp_fst3$Trans_Time),
                         wrong_ind_fst3)
est_fst3 <- est_result_fcn(wiki_nl_exp_fst3)

## Pass rate
mean(ks_fst3$ks_p>0.05)
mean(ks_fst3$ks_p>0.01)

eta_fst3 <- est_fst3$eta
K_fst3 <- est_fst3$K
beta_fst3 <- est_fst3$beta

pdf('nl_est_fst3.pdf', width = 10, height = 4)
par(mfrow = c(1,3))
plot(eta_fst3[-1], type = 's', col=4, xlab = '',
     ylab = 'eta_hat')
abline(h=0, lty=2, col=2)

#lines(eta_fst3, type = 's', col=4)
#legend('topleft', c('beta', 'eta'), col = c(2,4),
#       lty = c(1,1))

plot(K_fst3[-1], type = 's', col=4, xlab = '',
     ylab = 'K_hat')
abline(h=c(0,1), lty=2, col=2)

plot(beta_fst3[-1], type = 's', col=4, xlab = '',
     ylab = 'beta_hat')
abline(h=0, lty=2, col=2)
dev.off()
#################

# From 2006-01-01 to 2006-12-31
wiki_nl_exp_06 <- readRDS('nl_exp_sepp_06.rds')
wrong_ind_06 <- c(40,82,89,107,195:199,207,233,235)
ks_06 <- ks_result_fcn(wiki_nl_exp_06, 
                       2:length(wiki_nl_exp_06$Trans_Time),
                       wrong_ind_06)
est_06 <- est_result_fcn(wiki_nl_exp_06)

## Pass rate
mean(ks_06$ks_p>0.05)
mean(ks_06$ks_p>0.01)

eta_06 <- est_06$eta[-1]
K_06 <- est_06$K[-1]
beta_06 <- est_06$beta[-1]

pdf('nl_est_06.pdf', width = 10, height = 4)
par(mfrow = c(1,3))
plot(eta_06, type = 's', col=4, xlab = '',
     ylab = 'eta_hat')
abline(h = 0, lty=2, col=2)
#lines(beta_06, type = 's', col=2)
#legend('bottomright', c('beta', 'eta'), col = c(2,4),
#       lty = c(1,1))

plot(K_06, type = 's', col=4, xlab = '',
     ylab = 'K_hat')
abline(h=c(0,1), lty=2, col=2)

plot(beta_06, type = 's', col=4, xlab = '',
     ylab = 'beta_hat')
abline(h=0, lty=2, col=2)
dev.off()
########

# Sleep cycles
pdf('nl_sleep.pdf', width = 10, height = 4)
par(mfrow = c(1,3))
start_nl <- min(which(nl_list_names >= as.Date('2003-10-11')))
end_nl <- max(which(nl_list_names  == '2003-10-18')) 
sleep(nl_counts_daily, wiki_nl_tstp, NL, start_nl, end_nl, c(0,8))

start_nl <- min(which(nl_list_names >= as.Date('2005-02-07')))
end_nl <- max(which(nl_list_names  == '2005-02-13')) 
sleep(nl_counts_daily, wiki_nl_tstp, NL, start_nl, end_nl, c(0,8))

start_nl <- min(which(nl_list_names >= as.Date('2006-05-16')))
end_nl <- max(which(nl_list_names  == '2006-05-22')) 
sleep(nl_counts_daily, wiki_nl_tstp, NL, start_nl, end_nl, c(0,8))
dev.off()
####

# ACFs

pdf('wiki_nl_acf.pdf', width = 15, height = 20)
par(mfrow = c(8,6))
for(i in (1:length(wiki_nl$Trans_Time))){
  acf(diff(wiki_nl$Trans_Time[[i]][,2]), main='')
}
dev.off()

#####




# Poisson growth
library(fitdistrplus)
pois_test <- function(counts, a, b, tz, hr){
  names <- attributes(counts)$names
  start = which(names == a)
  end = which(names == b)
  daily_nonsleep <- lapply(counts[start:end],
                           function(tstp) unlist(tstp)[non_sleep_hrs(unlist(tstp), tz, hr)])
  exp_fit <- unlist(lapply(daily_nonsleep,
                    function(x) fitdist(diff(x)/3600,'exp')$estimate[1]))
  pois_ks_p <- rep(0,365)
  for(i in 1:min(length(daily_nonsleep), 365)){
    pois_ks_p[i] <- ks.test(diff(daily_nonsleep[[i]])/3600, 'pexp', exp_fit[i])$p.value
  } 
  c(mean(pois_ks_p>=0.05), mean(pois_ks_p>=0.01))
}
pois_test(nl_counts_daily, '2005-01-01', '2005-12-31', NL, c(0,8))
pois_test(nl_counts_daily, '2006-01-01', '2006-12-31', NL, c(0,8))
pois_test(nl_counts_daily, '2007-01-01', '2007-12-31', NL, c(0,8))
pois_test(nl_counts_daily, '2008-01-01', '2008-12-31', NL, c(0,8))
pois_test(nl_counts_daily, '2009-01-01', '2009-12-31', NL, c(0,8))
pois_test(nl_counts_daily, '2010-01-01', '2010-12-31', NL, c(0,8))
pois_test(nl_counts_daily, '2011-01-01', '2011-12-31', NL, c(0,8))
pois_test(nl_counts_daily, '2012-01-01', '2012-12-31', NL, c(0,8))
pois_test(nl_counts_daily, '2013-01-01', '2013-12-31', NL, c(0,8))




