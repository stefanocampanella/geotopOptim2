#!/usr/bin/env Rscript
# file appendSmetData.R
#
# This script is an examples of a GEOtop calibration via geotopOptim2
#
# author: Emanuele Cordano on 09-09-2015

#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.

###############################################################################



rm(list=ls())


library(zoo)
library(geotopOptim2)
set.seed(7988)

USE_RMPI <- FALSE 

if (USE_RMPI==TRUE) {
	library("parallel")

	library(Rmpi)
	require(snow)

	if (mpi.comm.rank(0) > 0) {
	    sink(file="/dev/null")
	#runMPIslave()
		slaveLoop(makeMPImaster())
		mpi.quit()
		
		
	}
	
	parallel <- "parallel"
    npart <- 16
	control <- list(maxit=5,npart=npart,parallel=parallel)
	
} else {
	
	parellel <- "none"
	npart <- 4
	control <- list(maxit=5,npart=npart)
	
}




####
#R <- '/home/ecor/Dropbox/R-packages/geotopOptim/R'
#lapply(X=list.files(R,pattern=".R",full.names=TRUE),FUN=source)
####

####obs <- '/home/lv70864/ecordano/Simulations/B2_BeG_017_DVM_001/obs/observation.RData' 

tz <- "Etc/GMT-1"

###load(obs)

####SWC <- observation$hour[,c("soil_moisture_content_50","soil_moisture_content_200")]

###names(SWC) <- c("z0005","z0020")
###index(SWC) <- as.POSIXct(index(SWC))
###index(SWC) <- as.POSIXlt(index(SWC),tz=tz)
###vars <- "SoilLiqContentProfileFile"

## REMOVE JDF

####ina <- which(as.numeric(as.character(index(SWC),format="%m")) %in% c(12,1,2))

###3SWC[ina,] <- NA

wpath <- '/home/lv70864/ecordano/Simulations/B2_BeG_017_DVM_001' ###/home/ecor/activity/2016/eurac2016/Incarico_EURAC/Simulations/B2/B2_BeG_017_DVM_001' 
wpath <- system.file('geotop-simulation/B2site',package="geotopOptim2")

###
#layer <- "z0005"
###
###simpath <- system.file("Muntatschini_pnt_1_225_B2_004",package="geotopOptim")
bin  <-  'geotop' #### 
bin  <-'/home/ecor/local/geotop/GEOtop/bin/geotop-2.0.0' 
##### '/Ubsers/ecor/local/bin/geotop_zh'
runpath <- "/home/lv70864/ecordano/temp/geotopOptim_tests"
runpath <- "/home/ecor/temp/geotopOptim_tests"
###vars <- "SoilLiqContentProfileFile"



### Use geotopGOF with an internal GEOtop simulation

## create a list with arguments for geotopGOF
#
#x <- param <- c(N=1.4,Alpha=0.0021,ThetaRes=0.05,LateralHydrConductivity=0.021,NormalHydrConductivity=0.021) 
#upper <- x*3
#
#upper["LateralHydrConductivity"] <- 0.1
#upper["NormalHydrConductivity"] <- 0.1
#
#lower <- x/3
#lower["N"] <- 1.1
#lower["LateralHydrConductivity"] <- 0
#lower["NormalHydrConductivity"] <- 0

## create a list with arguments for geotopGOF
### Use geotopGOF with an internal GEOtop simulation

geotop.soil.param.file <-  system.file('examples-script/param/param_pso_c001.csv',package="geotopOptim2") ###'/home/ecor/Dropbox/R-packages/geotopOptim/inst/examples_2rd/param/param_pso_test3.csv' 
geotop.soil.param <- read.table(geotop.soil.param.file,header=TRUE,sep=",",stringsAsFactors=FALSE)
lower <- geotop.soil.param$lower
upper <- geotop.soil.param$upper
names(lower) <- geotop.soil.param$name
names(upper) <- geotop.soil.param$name






###geotop.model <- list(bin=bin,simpath=wpath,runpath=runpath,
###		clean=TRUE,variable=vars,data.frame=TRUE,level=1,tz=tz,intern=TRUE)

 
#control=list(drty.out = cal_path, npart=48, maxit=iters,
#parallel="parallel", par.pkgs = c("gstat","caret","hydroGOF","sp"),
#		write2disk=TRUE,REPORT=100) )


#control <- list(maxit=5,npart=npart,parallel=parallel) ## Maximim 5iterations!! 

####pso <- geotopPSO(obs=SWC,geotop.model=geotop.model,layer=c("z0020"),gof.mes="RMSE",lower=lower,upper=upper,control=control,multiaggr=FALSE)

var <- 'soil_moisture_content_50'
x <- (upper+lower)/2

pso <- geotopPSO(par=x,run.geotop=TRUE,bin=bin,
		simpath=wpath,runpath=runpath,clean=TRUE,data.frame=TRUE,
		level=1,intern=TRUE,target=var,gof.mes="RMSE",lower=lower,upper=upper,control=control)


file_pso <-  '/home/lv70864/ecordano/pso_test3.rda'

save(pso,file=file_pso)


if (USE_RMPI==TRUE) mpi.finalize()
