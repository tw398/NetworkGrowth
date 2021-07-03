bin_counts <- function(tstp, tz, binsize){
  dates <- anytime(tstp, tz)
  total_time <- seq(from = floor_date(min(dates), binsize), to = 
                      ceiling_date(max(dates), binsize), by = binsize)
  sapply(total_time, function(x) {       
    sum(floor_date(dates,binsize) %in% x) })
}

est_fcn <- function(i,p,tz,delta,len,bin_len,tstp){
  dat <- tstp[i+1:len]
  dat_binned <- bin_counts(dat, tz, bin_len)
  dat_fit <- ar.ols(dat_binned, FALSE, order = p,
                    demean = FALSE, intercept = TRUE)
  K = sum(dat_fit$ar)
  y = as.vector(dat_fit$ar/delta/K)
  eta <- dat_fit$x.intercept/delta
  c(eta, y, K)
}


ker_est <- function(y, x){
  coef(lm(log(y)~log(x)))
}
nls_est <- function(y, x){
  summary(nls(y ~ (power-1)*(1+x)^(-power), data = data.frame(y,x), 
              start = list(power = 2), trace = F,
              #lower = list(power=1.0001),
              algorithm = 'port'))$parameter[,1]
}
exp_ker_est <- function(y,x){
  summary(nls(y ~ (rate*exp(-rate*x)), data = data.frame(y,x), 
              start = list(rate = .1), trace = F,
              algorithm = 'port'))$parameter[,1]
}

SEPP_est <- function(tstp, tz, delta, p, c, x, i,len,bin_len){
  coef_CLS <- est_fcn(i,p,tz,delta,len,bin_len,tstp)
  coef_nls <- nls_est(coef_CLS[-c(1,length(coef_CLS))], x)
  NLS_est <- c(coef_CLS[1], coef_CLS[length(coef_CLS)],
               1, coef_nls[1])
  list(ker_NLS = NLS_est)
}

ks_fit <- function(x){
  test <- ks.test(diff(x),
                  'pexp', 1)
  data.frame(ks_dist = test$statistic, p_value = test$p.value)
}

trajectory_plot <- function(k, all_fit){
  plot((1:k)~all_fit$power_nls$trans.time, type='n',
       xlab = 'Transformed Time', ylab = 'Cumulative Counts')
  abline(0, 1,lty=2, col=2, lwd=2)
  lines((1:k)~all_fit$mle_nls_init$trans.time, type='s',
        col = 'blue', lwd=1.5)
  lines((1:k)~all_fit$power_nls$trans.time, type='s',
        col = 'green', lwd=1.5)
  legend('topleft', c('Ker_LS','Ker_NLS','MLE_LS','MLE_NLS'),
         col = c('purple', 'green', 'brown', 'blue'),
         lwd = 2)
}

trajectory_plot_alt <- function(k, trans_time){
  plot((1:k)~trans_time[,1], type='n',
       xlab = 'Transformed Time', ylab = 'Cumulative Counts')
  abline(0, 1,lty=2, col=2, lwd=2)
  lines((1:k)~trans_time[,1], type='s',
        col = 'purple', lwd=2)
  lines((1:k)~trans_time[,2], type='s',
        col = 'green', lwd=1.5)
  legend('topleft', c('NLS','MLE_NLS'),
         col = c('purple', 'green'),
         lwd = 2)
}


sleep <- function(daily_dat, tstp, tz, start, end, hr){
  k0 <- length(unlist(lapply(1:start, 
                             function(x) unlist(daily_dat[[x]]))))
  k <- length(unlist(lapply((start+1):end, 
                            function(x) unlist(daily_dat[[x]]))))
  tstp_hrs <- hour(anytime(tstp[(k0+1):(k0+k)], tz = tz))
  ind_to_del <- which(tstp_hrs >= hr[1] & tstp_hrs<=hr[2])
  
  days <- ((tstp-tstp[1])/3600/24)[-1]
  plot(((k0+1):(k0+k))~days[(k0+1):(k0+k)], type='s',
       xlab = 'No. of Days', ylab = 'No. of Edges')
  for (i in 1:length(ind_to_del)){
    segments(days[k0+ind_to_del[i]-1], k0+ind_to_del[i]-1,
             days[k0+ind_to_del[i]], k0+ind_to_del[i]-1, 
             col='2', lwd=2)
  }
}














