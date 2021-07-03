library(anytime)
library(tscount)
library(SAPP)
library(lubridate)
library(fitdistrplus)
source('~/SEPP_Fcn.R')
math_overflow <- read.table('~/sx-mathoverflow.txt', header = F)
math_overflow <- math_overflow[order(math_overflow$V3),]
math_tstp <- math_overflow$V3

math_iet_hrs <- (diff(math_tstp)/3600)
math_days <- cumsum(math_iet_hrs)/24
CDT = 'America/Chicago'

delta = 1/24/12
p = 150
c = 0
x = ((1:p)-0.5)*delta
len = 500

start_day <- min(which(as.Date(anytime(math_tstp)) >= '2009-10-01'))
end_day <- max(which(as.Date(anytime(math_tstp)) < '2010-03-01')) 

ker_coef_math_mat <- c()
nls_coef_math_mat <- c()
k0_vec <- c()
k_vec <- c()
Trans_Time_math_list <- rep(list(0),2)
param_est_list <- rep(list(0),2)
wrong_K <- c()
wrong_NLS <- c()

SEPP_exp_est <- function(tstp, tz, delta, p, c, x, i,len,bin_len){
  coef_CLS <- est_fcn(i,p,tz,delta,len,bin_len,tstp)
  coef_exp <- exp_ker_est(coef_CLS[-c(1,length(coef_CLS))], x)
  NLS_est <- c(coef_CLS[1], coef_CLS[length(coef_CLS)]*(coef_exp[1]),c,
               coef_exp[1])
  list(ker_NLS = NLS_est)
}

Lambda_t <- function(t,original_t,exp_coef){
  exp_coef[1]*(t-original_t[1]) + 
    exp_coef[2]/exp_coef[4]*sum((1-exp(-exp_coef[4]*(t-original_t)))*ifelse(t >original_t,1,0),na.rm = TRUE)
}

for (m in 2:250){
  i = start_day-1+len*(m-1)
  if(i > end_day){break}
  math_sepp <- try(SEPP_exp_est(math_tstp, CDT, delta, p,c,x,i,len,'5 min'))
  if ('try-error' %in% class(math_sepp)) next
  if(math_sepp$ker_NLS[2]<0){wrong_K <- c(wrong_K,m)}
  if(math_sepp$ker_NLS[4]<0){wrong_NLS <- c(wrong_NLS, m)}
  nls_coef_math_mat = cbind(ker_coef_math_mat, abs(math_sepp$ker_NLS))
  original_t_math <- c(0,math_days[i-(len:1)])
  Trans_Time_math <- sapply(original_t_math, 
                          function(t)Lambda_t(t,original_t_math, abs(math_sepp$ker_NLS)))
  #colnames(Trans_Time_nl) <- c('NLS')#c('LS', 'NLS','MLE_LS','MLE_NLS')
  Trans_Time_math_list[[m]] <- Trans_Time_math
  param_est_list[[m]] <- cbind(#ker_LS = fb_sepp$ker_LS, 
    ker_NLS = math_sepp$ker_NLS)
  #MLE_LS = all_fit_fb$mle_ker_est,
  #MLE_NLS = all_fit_nl$mle_nls_est)
  print(m)
}

saveRDS(list(
  wrong = wrong_NLS, wrongK = wrong_K,
  delta = delta, p=p, c=c, x=x,len=len,
  param = param_est_list, 
  k0 = k0_vec, k = k_vec,
  Trans_Time = Trans_Time_math_list), 
  file = 'math_exp_sepp_fst.rds')




