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


delta = 1/24/12
p = 150
c = 1
x = (1:p)*delta+delta*c
len = 200

start_day <- min(which(as.Date(anytime(fb_tstp)) >= '2005-01-01'))
end_day <- max(which(as.Date(anytime(fb_tstp)) < '2007-06-01')) 

ker_coef_fb_mat <- c()
nls_coef_fb_mat <- c()
k0_vec <- c()
k_vec <- c()
Trans_Time_fb_list <- rep(list(0),2)
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

for (m in 2:150){
  i = start_day-1+len*(m-1)
  if(i > end_day){break}
  fb_sepp <- try(SEPP_exp_est(fb_tstp, CDT, delta, p,c,x,i,len,'5 min'))
  if ('try-error' %in% class(fb_sepp)) next
  if(fb_sepp$ker_NLS[2]<0){wrong_K <- c(wrong_K,m)}
  if(fb_sepp$ker_NLS[4]<0){wrong_NLS <- c(wrong_NLS, m)}
  nls_coef_fb_mat = cbind(ker_coef_fb_mat, abs(fb_sepp$ker_NLS))
  original_t_fb <- fb_days[i-(len:1)]
  Trans_Time_fb <- sapply(original_t_fb, 
                          function(t)Lambda_t(t,original_t_fb, abs(fb_sepp$ker_NLS)))
  Trans_Time_fb_list[[m]] <- Trans_Time_fb
  param_est_list[[m]] <- cbind(#ker_LS = fb_sepp$ker_LS, 
    ker_NLS = fb_sepp$ker_NLS)
  print(m)
}

saveRDS(list(#counts = fb_counts_daily, #wrong1 =wrong_LS, 
  wrong = wrong_NLS, wrongK = wrong_K,
  delta = delta, p=p, c=c, x=x,len=len,
  param = param_est_list, 
  k0 = k0_vec, k = k_vec,
  Trans_Time = Trans_Time_fb_list), 
  file = 'fb_new_exp_sepp0.rds')
