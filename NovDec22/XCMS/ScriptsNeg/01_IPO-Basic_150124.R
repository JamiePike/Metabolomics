#IPO 22-6-2021 Banana all samples (D:/Jamie/IPO_All_NoBlanks_9-7-21) output for XCMS. 
#Positive mode data


setwd("/Volumes/Jamie_EXT/Projects/Metabolomics/NovDec22/XCMS/Neg/01_IPO-Basic")
datafiles <- list.files("/Volumes/Jamie_EXT/Projects/Metabolomics/NovDec22/XCMS/Neg/01_IPO-Basic", recursive = TRUE, full.names = TRUE)

library(xcms)
library(Rmpi)

#############################################
#Settings:

xset <- xcmsSet( 
  method = "centWave",
  peakwidth       = c(15.84, 75.5),
  ppm             = 43.25,
  noise           = 1000,
  snthresh        = 10,
  mzdiff          = -0.012,
  prefilter       = c(3, 100),
  mzCenterFun     = "wMean",
  integrate       = 1,
  fitgauss        = FALSE,
  verbose.columns = FALSE)
xset <- retcor( 
  xset,
  method         = "obiwarp",
  plottype       = "none",
  distFunc       = "cor_opt",
  profStep       = 0.91, # got error about dimensions of profile matries not mathcing - GitHub issue explained chainging the ProfStep method will help. https://github.com/sneumann/xcms/issues/194
  center         = 7, # was 47, but changed to match the same file (48_D9-3_neg) as was the 47th file in the IPO input.
  response       = 1,
  gapInit        = 0.48,
  gapExtend      = 2.7,
  factorDiag     = 2,
  factorGap      = 1,
  localAlignment = 0)
xset <- group( 
  xset,
  method  = "density",
  bw      = 12.4,
  mzwid   = 0.047,
  minfrac = 0.75,
  minsamp = 1,
  max     = 50)

xset <- fillPeaks(xset)
#############################################

levels(sampclass(xset))
reporttab <- diffreport(xset, c(levels(sampclass(xset))[1]), c(levels(sampclass(xset))[2]), "Panovafolder", sortpval=FALSE)

library("CAMERA")
#CAMERA processing
xsap <- xsAnnotate(xset)
xsaFp <- groupFWHM(xsap, perfwhm=0.1)
xsaCp <- groupCorr(xsaFp)
xsaFIp <- findIsotopes(xsaCp, intval="into", mzabs=0.015)
isolist <- getIsotopeCluster(xsaFIp)
# library(Rdisop)
# isotopes.decomposed <- lapply(isolist,function(x) {
#   decomposeIsotopes(x$peaks[,1],x$peaks[,2],z=x$charge, maxisotopes=3, ppm=1);
# }) 
# 
# isotopes.decomposed.df <- do.call(rbind, isotopes.decomposed)
# write.csv(isotopes.decomposed.df[, c("formula",	"score",	"exactmass",	"charge")],file="isotopes_decomposed3.csv") # why is it line wrapping?!
xsaFAp <- findAdducts(xsaFIp, polarity="positive")
peaklistp<-getPeaklist(xsaFAp)
#Writes the output from CAMERA
write.csv(getPeaklist(xsaFAp),file="result_CAMERA_pos_Basic_Param.raw.csv")
diffreportcamp <- annotateDiffreport(xset)
#The output from CAMERA combined with XCMS:
reporttabOpA.combine <- cbind(reporttab, peaklistp[, c("isotopes", "adduct", "pcgroup")])
write.csv(reporttabOpA.combine,file="result_CAMERA_xcms_pos_Basic_Param.raw.csv")

# #EICs of interest
# gt <- groups(xset)
# #groupidx1 <- which(gt[,"mzmed"] > 703.53 & gt[,"mzmed"] < 703.54)
# groupidx1 <- which(gt[,"mzmed"] > 555.23 & gt[,"mzmed"] < 555.24)
# #groupidx1 <- which(gt[,"mzmed"] > 384 & gt[,"mzmed"] < 386)
# eiccor <- getEIC(xset, groupidx = c(groupidx1), rt = "corrected")
# eicraw <- getEIC(xset, groupidx = c(groupidx1), rt = "raw")
# plot(eicraw, xset, groupidx = 1)plot(eiccor, xset, groupidx = 1)

#QC
plotQC(xset)

