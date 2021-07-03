# Supplementary Materials for "Common Growth Patterns for Regional Social Networks: A Point Process Approach" by T. Wang and S.I. Resnick
## SEPP_Fcn.R: Generic functions for fitting a SEPP with an exponential triggering function.
## Datasets: We include all four datasets discussed in the paper. They are downloaded from KONECT (http://konect.cc/networks/).
### 1. Facebook Wall Posts: Data available at http://konect.cc/networks/facebook-wosn-wall/.
#### fb_exp_rds.R: Fit the SEPP model to the Facebook data from 2005-01-01 to 2007-06-01, and compute the transformed times.
#### fb_SEPP.R: Run KS tests based on the fitted SEPP model.
#### fb_acf.pdf: ACF plots of transformed inter-event times. 
### 2. Dutch Wikipedia Talk: Raw data available at http://konect.cc/networks/wiki_talk_nl/.
#### wikiNoBotRl.RData: Cleaned data from Wan et al. (2017).
#### wiki_nl_expfit.R: Fit the SEPP model to the Dutch Wiki Talk data: (1) 2003-01-01 to 2005-12-31 and (2) 2006-01-01 to 2006-12-31, and compute the transformed times.
#### wiki_nl_SEPP.R: Run KS tests based on the fitted SEPP model.
#### nl_acf.pdf: ACF plots of transformed inter-event times in the first 46 time windows, i.e. from 2003-01-01 to 2005-02-09. 
### 3. German Wikipedia Talk: Raw data available at http://konect.cc/networks/wiki_talk_de/.
### 4. Math Overflow: Data available at http://konect.cc/networks/sx-mathoverflow/.
