#' Multidimensional Scaling for Persistence Landscapes
#' 
#' Given \eqn{N} persistence landscapes \eqn{\Lambda_1 (t), \Lambda_2 (t), \ldots, \Lambda_N (t)}, apply 
#' multidimensional scaling to get low-dimensional representation in Euclidean space. 
#' Usually, \code{ndim=2,3} are chosen for visualization.
#' 
#' @param dlist a length-\eqn{N} list of \code{'landscape'} objects from \code{\link{diag2landscape}}.
#' @param ndim an integer-valued target dimension (default: 2).
#' 
#' @return an \eqn{(n\times ndim)} matrix of embedding.
#' 
#' @examples 
#' # ---------------------------------------------------------------------------
#' #         Multidimensional Scaling for Multiple Landscapes
#' #
#' # We will compare dim=0 and 1 and top-5 landscape functions with 
#' # - Class 1 : 'iris' dataset with noise
#' # - Class 2 : samples from 'gen2holes()'
#' # - Class 3 : samples from 'gen2circles()'
#' # ---------------------------------------------------------------------------
#' ## Generate Data and Diagram from VR Filtration
#' ndata     = 10
#' list_rips = list()
#' for (i in 1:ndata){
#'   dat1 = as.matrix(iris[,1:4]) + matrix(rnorm(150*4), ncol=4)
#'   dat2 = gen2holes(n=100, sd=1)$data
#'   dat3 = gen2circles(n=100, sd=1)$data
#'   
#'   list_rips[[i]] = diagRips(dat1, maxdim=1)
#'   list_rips[[i+ndata]] = diagRips(dat2, maxdim=1)
#'   list_rips[[i+(2*ndata)]] = diagRips(dat3, maxdim=1)
#' }
#' 
#' ## Compute Persistence Landscapes from Each Diagram with k=5 Functions
#' list_land0 = list()
#' list_land1 = list()
#' for (i in 1:(3*ndata)){
#'   list_land0[[i]] = diag2landscape(list_rips[[i]], dimension=0, k=5)
#'   list_land1[[i]] = diag2landscape(list_rips[[i]], dimension=1, k=5)
#' }
#' list_lab = rep(c(1,2,3), each=ndata)
#' 
#' ## Run Multidimensional Scaling
#' mds_land0 = plmds(list_land0, ndim=2)
#' mds_land1 = plmds(list_land1, ndim=2)
#' 
#' ## Visualize
#' opar <- par(no.readonly=TRUE)
#' par(mfrow=c(1,2))
#' plot(mds_land0, pch=19, col=list_lab, main="embedding for dim=0")
#' plot(mds_land1, pch=19, col=list_lab, main="embedding for dim=1")
#' par(opar)
#' 
#' @concept landscape
#' @export
plmds <- function(dlist, ndim=2){
  ## PREPROCESSING
  if (!check_list_landscape(dlist)){
    stop("* plmds : 'dlist' should be a list of 'landscape' objects.")
  }
  mydim = max(1, round(ndim))
  
  ## COMPUTE PAIRWISE DISTANCE & RUN MDS
  dmat  = pldist(dlist, p=2, as.dist = FALSE)
  embed = routine_mds(dmat, mydim)
  return(embed)
}
