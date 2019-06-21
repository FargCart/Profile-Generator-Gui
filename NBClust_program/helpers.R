# Author: Leandro Corrêa ~@hscleandro
# Date: March 05 2018

# Install
# libcurll. For linux users: sudo apt-get install libcurl4-gnutls-dev
# libxml. For linux users: sudo apt-get install libxml2-dev

if("shiny" %in% rownames(installed.packages()) == FALSE){ install.packages("shiny") }
if("dendextend" %in% rownames(installed.packages()) == FALSE) {
  install.packages("dendextend") # If it doesn't work, run the commands below
  #install.packages.2('devtools')
  #install.packages.2('Rcpp')
  # make sure you have Rtools installed first! if not, then run:
  #devtools::install_github('talgalili/dendextend')
  #devtools::install_github('talgalili/dendextendRcpp')
}
if("WGCNA" %in% rownames(installed.packages()) == FALSE){
    # source("http://bioconductor.org/biocLite.R")
  BiocManager::install(c("AnnotationDbi", "impute", "GO.db", "preprocessCore"))
  install.packages("WGCNA") 
}
if("DT" %in% rownames(installed.packages()) == FALSE){ install.packages("DT") }
if("SANTA" %in% rownames(installed.packages()) == FALSE){ 
  # source("http://bioconductor.org/biocLite.R")
  BiocManager::install("SANTA") }
if("igraph" %in% rownames(installed.packages()) == FALSE){ install.packages("igraph") }
if("colourpicker" %in% rownames(installed.packages()) == FALSE){ install.packages("colourpicker") }
if("visNetwork" %in% rownames(installed.packages()) == FALSE){ install.packages("visNetwork") }
if("ggplot2" %in% rownames(installed.packages()) == FALSE){ install.packages("ggplot2") }
if("plotly" %in% rownames(installed.packages()) == FALSE){ install.packages("plotly") }
if("shinyjs" %in% rownames(installed.packages()) == FALSE){ install.packages("shinyjs") }
if("rmarkdown" %in% rownames(installed.packages()) == FALSE){ install.packages("rmarkdown") }
if("dendextend" %in% rownames(installed.packages()) == FALSE){ install.packages("dendextend") }
if("openxlsx" %in% rownames(installed.packages()) == FALSE){ install.packages("openxlsx") }
if("pvclust" %in% rownames(installed.packages()) == FALSE){ install.packages("pvclust") }
if("factoextra" %in% rownames(installed.packages()) == FALSE){ install.packages("factoextra") }
if("magrittr" %in% rownames(installed.packages()) == FALSE){ install.packages("magrittr") }

library(WGCNA)
library(igraph)
library(magrittr)
library(visNetwork)
library(ggplot2)
library(plotly)
library(shinyjs)
library(rmarkdown)
library(dendextend)
library(openxlsx)
library(pvclust)
library(DT)
library(SANTA)
#library(NbClust)
library(factoextra)
library(colourpicker)

# transforms the input table into a square matrix by adding elements to 
# rows and columns with index 0. Ex.: if a matrix A containg 4 collums and 3 rows
# such as colnames(A) = [a,b,c,d] and rownames(A) = [a,b,c], the standard_matrix add 
# a row with same name  (in this case 'd') with each index = 0 turn the matrix A 4x4.  
# rdim TRUE == add row; rdim FALSE == add col
stadard_matrix <- function(input_table, rdim){
  m_table <- as.matrix(input_table)
  m_table[which(m_table == " ")] <- 0
  
  if(rdim == TRUE){ size <- nrow(m_table)
  } else { size <- ncol(m_table) }
  
  for(i in 1:size){
    if(rdim == TRUE){
      if(length(which(rownames(m_table)[i] == colnames(m_table))) == 0){
        input <- rep(0,nrow(m_table))
        m_table <- cbind(input,m_table)
        colnames(m_table)[1] <- rownames(m_table)[i]
      }
    }else{ 
      if(length(which(colnames(m_table)[i] == rownames(m_table))) == 0){
        input <- rep(0,ncol(m_table))
        m_table <- rbind(input,m_table)
        rownames(m_table)[1] <- colnames(m_table)[i]
      }
    }
  }
  return(m_table)
}

# changing the input table indices to numeric format
as_numeric_matrix <- function(m_table){
  
  input_matrix <- matrix(data = 0, nrow = nrow(m_table), ncol = ncol(m_table))
  
  for(i in 1:nrow(m_table)){
    for(j in 1:ncol(m_table)){
      input_matrix[i,j] <- as.numeric(gsub(",",".",as.character(m_table[i,j])))
    }
  }
  
  colnames(input_matrix) <- colnames(m_table)
  rownames(input_matrix) <- rownames(m_table)
  
  return(input_matrix)  
}

# Ordering row and colnames
order_matrix <- function(m_table){
  index_col <- order(colnames(m_table), decreasing = FALSE)
  index_row <- order(rownames(m_table), decreasing = FALSE)
  m_table <- m_table[index_row,]
  m_table <- m_table[,index_col]
  
  return(m_table)
}

# running dynamic hybrid and dynamic tree methods
# The label2color function chooses the colors of the groups identified in each method
bestCutoffPoints <- function(hc, distt, minClusteRSize = 10, deepSplitt = 3){
  DetectedColors = NULL;
  
  DetectedColors = cbind(DetectedColors,
                         labels2colors(cutreeDynamic(dendro = hc,
                                                     cutHeight = NULL, minClusterSize =  minClusteRSize,
                                                     method = "tree", deepSplit = TRUE)));
  
  DetectedColors = cbind(DetectedColors,
                         labels2colors(cutreeDynamic(hc, cutHeight = NULL,
                                                     minClusterSize = 10,
                                                     method = "hybrid", deepSplit = deepSplitt,
                                                     pamStage = TRUE,  distM = as.matrix(distt), 
                                                     maxDistToLabel = 0,
                                                     verbose = 0)));
  return(DetectedColors)
}

########################################################################################################################################################
# Function that controls the color and position of the button "run analisys"
withBusyIndicator <- function(button, exp) {
  id <- button[['attribs']][['id']]
  tagList(
    button,
    span(
      class = "btn-loading-container",
      `data-for-btn` = id,
      hidden(
        img(src = paste(getwd(),"/www/ajax-loader-bar.gif"), class = "btn-loading-indicator"),
        icon("check", class = "btn-done-indicator")
      )
    )
  )
}

withBusyIndicatorUI <- function(button) {
  id <- button[['attribs']][['id']]
  div(
    `data-for-btn` = id,
    button,
    span(
      class = "btn-loading-container",
      hidden(
        img(id = "loading", src = "ajax-loader-bar.gif", class = "btn-loading-indicator"),
        icon("check", class = "btn-done-indicator")
      )
    ),
    hidden(
      div(class = "btn-err",
          div(icon("exclamation-circle"),
              tags$b("Error: "),
              span(class = "btn-err-msg")
          )
      )
    )
  )
}

# Call this function from the server with the button id that is clicked and the
# expression to run when the button is clicked
withBusyIndicatorServer <- function(buttonId, expr) {
  # UX stuff: show the "busy" message, hide the other messages, disable the button
  loadingEl <- sprintf("[data-for-btn=%s] .btn-loading-indicator", buttonId)
  doneEl <- sprintf("[data-for-btn=%s] .btn-done-indicator", buttonId)
  errEl <- sprintf("[data-for-btn=%s] .btn-err", buttonId)
  shinyjs::disable(buttonId)
  shinyjs::show(selector = loadingEl)
  shinyjs::hide(selector = doneEl)
  shinyjs::hide(selector = errEl)
  on.exit({
    shinyjs::enable(buttonId)
    shinyjs::hide(selector = loadingEl)
  })
  
  # Try to run the code when the button is clicked and show an error message if
  # an error occurs or a success message if it completes
  tryCatch({
    value <- expr
    shinyjs::show(selector = doneEl)
    shinyjs::delay(2000, shinyjs::hide(selector = doneEl, anim = TRUE, animType = "fade",
                                       time = 0.5))
    value
  }, error = function(err) { errorFunc(err, buttonId) })
}

# When an error happens after a button click, show the error
errorFunc <- function(err, buttonId) {
  errEl <- sprintf("[data-for-btn=%s] .btn-err", buttonId)
  errElMsg <- sprintf("[data-for-btn=%s] .btn-err-msg", buttonId)
  errMessage <- gsub("^ddpcr: (.*)", "\\1", err$message)
  shinyjs::html(html = errMessage, selector = errElMsg)
  shinyjs::show(selector = errEl, anim = TRUE, animType = "fade")
}

########################################################################################################################################################
# Data normalization function
minMax <- function(vet, min=0, max=1){
  cnames <- colnames(vet)
  rnames <- rownames(vet)
  tdim <- dim(vet)
  vet <- as.vector(vet)
  v_n <- NULL
  for(i in 1:length(vet)){
    v_n[i] <- min + (vet[i] - min(vet))/(max(vet) - min(vet)) *   (max-min)
    v_n[i] <- round(v_n[i], 3)
  }
  v_n <- as.vector(v_n)
  dim(v_n) <- tdim
  
  colnames(v_n) <- cnames
  rownames(v_n) <- rnames
  v_n <- as.data.frame(v_n)
  
  return(v_n)
}

# Function that returns the colors of each element sorted by pvclust clusters
pvclust_color <- function(rclusters, color_table){
  size_clusters <- length(rclusters); clusters_pvc <- NULL; aux_name <- NULL
  for(i in 1:size_clusters){
    clusters_pvc <- c(clusters_pvc,rep(i,length(rclusters[[i]])))
    aux_name <- c(aux_name, rclusters[[i]])
    
  }
  names(clusters_pvc) <- aux_name; 
  index <- NULL
  for(i in 1: length(color_table)){
  temp  <- which(names(clusters_pvc) == color_table[i])
  if(length(temp) > 0) { index[i] <- clusters_pvc[temp]}
  else{ index[i] <- 0}
  }
  pvclust <- labels2colors(index)
  names(pvclust) <- color_table
  
  return(pvclust)
}

# Function that returns the colors of each element sorted by nblust clusters
hc_color <- function(cutk, label_hc){
  index <- NULL
  for(i in 1:length(label_hc)){
    index[i] <- which(label_hc[i] == names(cutk))
  }
  cutk <- cutk[index]
  cutk <- labels2colors(cutk)
  
  return(cutk)
}

# Calculates the average connectivity between neighbors of each node
neighborhoodConnectivity <- function(g2){
  neighborhood_gg<-array()
  # For each vertex caluculate the neighborhood connectivity
  for (i in 1: vcount(g2)){
    neighbors<-neighbors(g2,i)
    if(length(neighbors) > 0){
      neighborhoodConnectivity <- 0
      for (j in 1: length(neighbors)){
        neighborhoodConnectivity <- as.numeric(degree(g2,neighbors[j])) + neighborhoodConnectivity
      }
      neighborhood_gg[i] <- neighborhoodConnectivity/length(neighbors)
    }
    else{
      neighborhood_gg[i] <- 0
    }
  }
  return(neighborhood_gg)
}

# Closeness vitality is a measure proposed in Brandes and Erlebach (2005), Section 3.6.2
closeness_vitality <- function(g) {
  a <- sum(igraph::distances(g))
  v <- sapply(1:igraph::vcount(g), function(v) {
    d <- igraph::distances(igraph::delete_vertices(g, v))
    a - sum(d[ !is.infinite(d) ])
  })
  names(v) <- V(g)$name
  v
}

# Compute information centrality (relative efficency when removed) for each node
# by TomKellyGenetics
info.centrality.vertex <- function(graph, net=NULL, verbose=F){
  if(is_igraph(graph)==F) warning("Please use a valid iGraph object")
  if(is.null(net)) net <- network.efficiency(graph)
  if(is.numeric(net)==F){
    warning("Please ensure net is a scalar numeric")
    net <- network.efficiency(graph)
  }
  count <- c()
  for(i in 1:length(V(graph))){
    count <- c(count, (net-network.efficiency(delete.vertices(graph, i)))/net)
    if(verbose){
      print(paste("node",i,"current\ info\ score", count[i], collapse="\t"))
    }
  }
  return(count)
}

# Compute efficiency of full graphs
network.efficiency <- function(graph){
  if(is_igraph(graph)==F) warning("Please use a valid iGraph object")
  dd <- 1/shortest.paths(graph)
  diag(dd) <- NA
  efficiency <- mean(dd, na.rm=T)
  #denom <- nrow(dd)*(ncol(dd)-1)
  #sum(dd, na.rm=T)/denom
  return(efficiency)
}

# Function that identifies negative elements in the array
isNegativeMatrix <- function(vet){
  vet <- as.vector(vet)
  for(v in vet){
    if(v < 0){ return(TRUE)}
  }
  return(FALSE)
}

# Code for standarlization input matrix passed by Mr brooks
asymmetries <- function(m, missingRowNames, missingColumnNames){

  # adding blank matrix to add in missing columns
  missingColumns <- matrix( nrow = nrow(m), 
                            ncol = length(missingColumnNames), 
                            byrow = TRUE, 
                            dimnames = list(rownames(m),missingColumnNames))
  
  
  ######### End of New Code for missing columns
  
  m = cbind(m, missingColumns)
  
  # adding blank matrix for missing rows
  missingRows <- matrix(nrow = length(missingRowNames), 
                        ncol = ncol(m), 
                        byrow = TRUE, 
                        dimnames = list(missingRowNames,colnames(m)))
  
  m=rbind(m, missingRows)
  #ordering new square matrix so columns and rows are in same order
  m = m[row.names(m),row.names(m)]  
  
  m[m > 0] = 5
  m[!is.finite(m)] = 2  # sets all NAs within the newly added rows and columns to 2 
  
  m = m + t(m) #add transpose to itself to highlight Asymmetries, etc.
  
  m[m < 5] = 0
  m[m == 5] = 1 # these will become the Asymmetries
  m[m > 5] = 2 
  
  m[!is.finite(m)] = 0
  
  return(m)
}

# Code for find asymetiric table passed by Mr brooks
getAsymmetries <- function(gL, m, orphans){
  
  # BIN ALLOCATION
  
  ### use mo to make list of Asymmetries - a matrix (2 columns) of Ab pairs that are asymmetrical, to be shown on bin allocation along with Bins and Orphans
  ### use mo to make list of Orphans - a matrix (single column) to be displayed on the bin allocation tab
  het=E(gL)$weight==1
  het=(E(gL)[het])
  het_loc=as.matrix(get.edges(gL,het))
  Asymmetries=matrix(nrow=length(het),ncol=2,byrow = TRUE, dimnames=list(NULL,c("ID","ID"))) # create empty matrix
  names=rownames(m) 
  
  # fill in the Asymmetries matrix from the edge list
  # only attempt if there are Asymmetries...
  if(length(het)>0){
    for (k in 1:length(het))
    {
      Asymmetries[k,1]=names[het_loc[k,1]]
      Asymmetries[k,2]=names[het_loc[k,2]]
    }
  }
  
  # remove the orphans from the Asymmetries list (they can't be asymmetric since only have one direction information)
  if(nrow(Asymmetries)){
    for (j in 1:nrow(Asymmetries)){
      match_test=match(Asymmetries[j,],orphans)
      match_test[!is.finite(match_test)]=0
      if(sum(match_test>0))
      {
        Asymmetries[j,]=NA
      }
    }
  }
  
  df=as.data.frame(Asymmetries)
  df=na.omit(df)
  Asymmetries=as.matrix(df)
  rownames(Asymmetries)=NULL
  
  return(Asymmetries)
}

#
index_colors <- function(vt_groups){
  unique_colors <- unique(vt_groups)
  index <- NULL
  for(i in 1:length(vt_groups)){
    index[i] <- which(unique_colors == vt_groups[i])
  }
  names(index) <- names(vt_groups)
  return(index)
}

#
assortativity <- function(graph){
  graph <- g1
  deg <- degree(graph)
  deg.sq <- deg^2
  m <- ecount(graph)
  num1 <- 0; num2 <- 0; den <- 0
  edges <- get.edgelist(graph, names=FALSE)
  num1 <- sum(deg[edges[,1]] * deg[edges[,2]]) / m
  num2 <- (sum(deg[edges[,1]] + deg[edges[,2]]) / (2 * m))^2
  den <- sum(deg.sq[edges[,1]] + deg.sq[edges[,2]]) / (2 * m)
  
  return((num1-num2)/(den-num2))
}

#
assortativity_b <- function(graph){
  deg <- degree(graph)
  if(sum(deg) == 0){
    return(0)
  }
  edges <- get.edgelist(graph, names=FALSE)
  return(cor(deg[edges[,1]],deg[edges[,2]], method="pearson"))
}

#
getDendoColor <- function(label, net_name, net_color){
  color <- rep("",length(label))

  for(i in 1:length(net_name)){
    index <- which(label == net_name[i])
    #color[index] <- as.character(net_name[i])
    color[index] <- net_color[i]
  }
  
  return(color)
}
