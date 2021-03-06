#' Median of Multiple Persistence Silhouettes
#' 
#' @export
silhouette.median <- function(slist, weight=rep(1/length(slist), length(slist)), 
                              maxiter=496, abstol=1e-6, algorithm=c("asgd","sgd","weiszfeld"), 
                              sgd.C = 1, sgd.alpha = 0.75, print.progress=TRUE){
  #############################################
  # Preprocessing : checkers
  if (!check_list_silhouette(slist)){
    stop("* silhouette.median : an input 'slist' should be a list of silhouettes as 'kit.silhouette' objects. Consult with 'd2silhouette' function.")
  }
  if ((!is.vector(weight))||(length(weight)!=length(slist))){
    stop(paste0("* silhouette.medina : an input 'weight' should be a vector of length ",length(slist)))
  }
  
  #############################################
  # Transform for Vector-valued Computation
  # commonize
  mainout = adjust_list_silhouette(slist, as.list=FALSE) # $array (columns) and $tseq
  # some params
  myprog  = as.logical(print.progress)
  if (missing(algorithm)){
    algorithm = "weiszfeld"
  } else {
    alglist   = c("weiszfeld","sgd","asgd")
    algorithm = match.arg(tolower(algorithm), alglist)  
  }
  outvec  = switch(algorithm,
                   "weiszfeld" = compute_median_weiszfeld(mainout$array, mainout$tseq, 
                                                          weight, maxiter, abstol, "silhouette.median", print.progress = myprog),
                   "sgd"       = compute_median_sgd(mainout$array, mainout$tseq, 
                                                    weight, maxiter, abstol, "silhouette.median", print.progress = myprog,
                                                    sgd.C, sgd.alpha),
                   "asgd"      = compute_median_asgd(mainout$array, mainout$tseq, 
                                              weight, maxiter, abstol, "silhouette.median", print.progress = myprog,
                                              sgd.C, sgd.alpha))
  
  #############################################
  # Report the results
  output = list()
  output$lambda = outvec
  output$tseq   = mainout$tseq
  output$dimension = slist[[1]]$dimension
  class(output) = "kit.silhouette"
  return(output)
}

# # personal test -----------------------------------------------------------
# library(TDA)
# library(TDAkit)
# 
# # data generation
# slist = list()
# ntest = 100
# myp   = 1
# for (i in 1:ntest){
#   X = TDAkit::gen.2circles(n=50)
#   diagx = ripsDiag(X, maxdimension = 1, maxscale = Inf)$diagram
#   slist[[i]] = d2silhouette(diagx, dimension=1, p=myp)
# }
# XX = TDAkit::gen.2circles(n=500)
# diagx = ripsDiag(XX, maxdimension = 1, maxscale = Inf)$diagram
# diags = d2silhouette(diagx, dimension=1, p=myp)
# 
# # mean
# liststoc <- list()
# for (i in 1:5){
#   pX = XX[sample(1:500, 50),]
#   dX = ripsDiag(pX, maxdimension = 1, maxscale = Inf)$diagram
#   liststoc[[i]] = d2silhouette(dX, dimension=1, p=myp)
# }
# smeanst <- silhouette.mean(liststoc)
# smean   <- silhouette.mean(slist)
# smedian    <- silhouette.median(slist, print.progress = TRUE, abstol = 1e-15)
# smediansgd <- silhouette.median(slist, print.progress = TRUE, abstol = 1e-15, algorithm = "sgd", sgd.C=0.01)
# smedianasgd <- silhouette.median(slist, print.progress = TRUE, abstol = 1e-15, algorithm = "asgd", sgd.C=0.01)
# #smedian <- silhouette.median(liststoc, print.progress = TRUE, abstol = 1e-15)
# 
# # visualize
# ymax  <- 0.08
# opar  <- par(mfrow=c(2,4))
# for (i in 1:2){
#   plot(slist[[i]]$tseq, slist[[i]]$lambda, "l", main=paste0("Silhouette No. ",i), ylim=c(0,ymax))
# }
# plot(diags$tseq, diags$lambda, "l", main="Large Data", ylim=c(0,ymax))
# plot(smean$tseq, smean$lambda, "l", main="Stochastic Mean", ylim=c(0,ymax))
# plot(smeanst$tseq, smeanst$lambda, "l", main="mean Silhouette", ylim=c(0,ymax))
# plot(smedian$tseq, smedian$lambda, "l", main="median:Weiszfeld", ylim=c(0,ymax))
# plot(smediansgd$tseq, smediansgd$lambda, "l", main="median:SGD", ylim=c(0,ymax))
# plot(smedianasgd$tseq, smedianasgd$lambda, "l", main="median:ASGD", ylim=c(0,ymax))