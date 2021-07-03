library(anytime)
library(tscount)
library(SAPP)
library(lubridate)
library(fitdistrplus)
source('~/SEPP_Fcn.R')

load('~/wikiNoBotRl.RData')

wiki_nl_tstp <- wikiNoBotRl[,3]
wiki_nl_iet_hrs <- diff(wiki_nl_tstp)/3600
nl_days <- cumsum(wiki_nl_iet_hrs)/24
NL='Europe/Amsterdam'



delta = 1/24/12
p = 150
c = 0
x = ((1:p)-0.5)*delta
len = 500

start_day <- min(which(as.Date(anytime(wiki_nl_tstp, NL)) >= '2006-01-01'))
end_day <- max(which(as.Date(anytime(wiki_nl_tstp,NL)) < '2007-01-01')) 

ker_coef_nl_mat <- c()
nls_coef_nl_mat <- c()
k0_vec <- c()
k_vec <- c()
Trans_Time_nl_list <- rep(list(0),2)
param_est_list <- rep(list(0),2)
wrong_K <- c()
wrong_NLS <- c()

SEPP_exp_est <- function(tstp, tz, delta, p, c, x, i,len,bin_len){
  coef_CLS <- est_fcn(i,p,tz,delta,len,bin_len,tstp)
  coef_exp <- exp_ker_est(coef_CLS[-c(1,length(coef_CLS))], x)
  NLS_est <- c(coef_CLS[1], coef_CLS[length(coef_CLS)]*(coef_exp[1]),c,
               coef_exp[1])
  list(#start_tstp = k0, end_tstp = k,
    #ker_LS = LS_est, 
    ker_NLS = NLS_est)#, ker_exp = coef_exp)
}

Lambda_t <- function(t,original_t,exp_coef){
  exp_coef[1]*(t-original_t[1]) + 
    exp_coef[2]/exp_coef[4]*sum((1-exp(-exp_coef[4]*(t-original_t)))*ifelse(t >original_t,1,0),na.rm = TRUE)
}

for (m in 2:500){
  i = start_day-1+len*(m-1)
  if(i > end_day){break}
  nl_sepp <- try(SEPP_exp_est(wiki_nl_tstp, NL, delta, p,c,x,i,len,'5 min'))
  if ('try-error' %in% class(nl_sepp)) next
  if(nl_sepp$ker_NLS[2]<0){wrong_K <- c(wrong_K,m)}
  if(nl_sepp$ker_NLS[4]<0){wrong_NLS <- c(wrong_NLS, m)}
  nls_coef_nl_mat = cbind(ker_coef_nl_mat, abs(nl_sepp$ker_NLS))
  original_t_nl <- c(0,nl_days[i-(len:1)])
  Trans_Time_nl <- sapply(original_t_nl, 
                           function(t)Lambda_t(t,original_t_nl, abs(nl_sepp$ker_NLS)))
  Trans_Time_nl_list[[m]] <- Trans_Time_nl
  param_est_list[[m]] <- cbind(ker_NLS = nl_sepp$ker_NLS)
  print(m)
}

saveRDS(list(#counts = fb_counts_daily, #wrong1 =wrong_LS, 
  wrong = wrong_NLS, wrongK = wrong_K,
  delta = delta, p=p, c=c, x=x,len=len,
  param = param_est_list, 
  k0 = k0_vec, k = k_vec,
  Trans_Time = Trans_Time_nl_list), 
  file = 'nl_exp_sepp_06.rds')
