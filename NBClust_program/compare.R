library(openxlsx)
source("ag_bestCombination.R")

# Put the address of the comparison file here
original <- "/home/leandro/R/brooks/data/Metrics.xlsx"
orig_file <- read.xlsx(xlsxFile = original, sheet = "gD2-285")

# Put the directory containing the results of the analyzes here
dir <- "/home/leandro/R/brooks/data/GD2-285/"

orig_groups <- unique(orig_file$cluster)
files <- list.files(path = dir)
results <- list(); parc_results <- list(); index <- 1; results_names <- NULL

for (f in files) {
  #f <- files[42]
  temp <- read.xlsx(xlsxFile = paste0(dir, f), sheet = "Table metrics")  
  groups <- unique(temp$Groups)
  #cat("Name of file:",f,"\n")
  #cat("Total elements:",length(orig_file$cluster),"\n")
  score <- matrix(NA, length(groups), length(orig_groups))
  colnames(score) <- orig_groups
  rownames(score) <- groups
  for (orig_class in orig_groups) {
    #orig_class <- orig_groups[1]
    orig_index <- which(orig_file$cluster == orig_class)
    #cat("\n\n")
    #cat(orig_class,":\n\n")
    
    for(temp_class in groups){
      m_match <- 0; n_match <- 0; match <- 0; mismatch <- 0
      #temp_class <- groups[1]
      temp_index <- which(temp$Groups == temp_class)
      n_match <- intersect(orig_file$mAb[orig_index], 
                           gsub(" ","",temp[temp_index,1]))
      temp_size <- length(gsub(" ","",temp[temp_index,1]))
      match <- length(n_match) 
      mismatch <- temp_size - match
      
      
      m <- length(orig_index)
      n <- nrow(orig_file) - m
      k <- mismatch + match
      
      #cat(orig_class,"(",length(orig_index),") -", temp_class,"(",match+mismatch,") -> match:", match, "; mismatch:", mismatch,"\n")
      #cat("dhyper(",match,",",m,",",n,",", k,"):")
      
      if(match > 0){ prob <- dhyper(match, m, n, k) }
      else{ prob <- 1 }
      #cat(prob,"\n\n")
      score[temp_class,orig_class] <- prob
      #m <- 10; n <- 7; k <- 8
      #x <- 0:(k+1)
      #browser()
    }
    
  }
  
  best_score <- ag_bestCombination(score,200,10)
  results[[index]] <- best_score
  results_names <- c(results_names, f)
  parc_results[[index]] <- score
  index <- index + 1
  #browser()
}

names(results) <- results_names
names(parc_results) <- results_names
valid_list <- list(); valid_index <- NULL

for(i in 1:length(results)){
  sel_result <- results[[i]]
  sel_parc_result <- parc_results[[i]]
  temp <- NULL; group_teste <- NULL; group_valid <- NULL 
  for(j in 1:ncol(sel_result)){
    x <- sel_result[1,j]; y <- sel_result[2,j]
    temp[j] <- sel_parc_result[x,y]
    group_teste[j] <- rownames(sel_parc_result)[x]
    group_valid[j] <- colnames(sel_parc_result)[y]
  }
  valid_list[[i]] <- cbind(group_valid, group_teste)
  valid_index[i] <- sum(temp) + (length(orig_groups) - nrow(valid_list[[i]]))
  #valid_index[i] <- prod(temp) + (length(orig_groups) - nrow(valid_list[[i]]))
}

names(valid_list) <- results_names
min_indexes <- which(valid_index == min(valid_index))

cat("## Best strategies identified:\n\n")
for(i in 1:length(min_indexes)){
  f <- files[min_indexes[i]]
  cat("## Name of file:",f,"\n")
  temp <- read.xlsx(xlsxFile = paste0(dir, f), sheet = "Settings")
  apply_clust <- gsub("[.]"," ",temp[1,1])
  apply_clust <- substr(apply_clust,1,nchar(apply_clust)-1)
  cat(apply_clust,": ",temp[1,2],"\n")
  dist_metric <- gsub("[.]"," ",temp[2,1])
  dist_metric <- substr(dist_metric,1,nchar(dist_metric)-1)
  cat(dist_metric,": ",temp[2,2],"\n")
  type_analise <- gsub("[.]"," ",temp[3,1])
  type_analise <- substr(type_analise,1,nchar(type_analise)-1)
  cat(type_analise,": ",temp[3,2],"\n")
  algorithm <- gsub("[.]"," ",temp[4,1])
  algorithm <- substr(algorithm,1,nchar(algorithm)-1)
  cat(algorithm,": ",temp[4,2],"\n")
  if(nrow(temp) > 4){
    cutting <- type_analise <- gsub("[.]"," ",temp[5,1])
    cutting <- substr(cutting,1,nchar(cutting)-2)
    cat(cutting,": ",temp[5,2],"\n")
  }
  cat("\nGroups identified in the validation sample and the corresponding groups identified in the test sample.\n\n")
  print(valid_list[[min_indexes[i]]])
  cat("\nHit rate : ",valid_index[min_indexes[i]])
  cat("\n\n")
}

color <- rep("gray",length(valid_list))
color[min_indexes] <- rep("red",length(min_indexes))
names(valid_index) <- results_names
par(mar=c(10,7,2,1)+0.6,mgp=c(5,1,0))
barplot(valid_index, 
        main="Ratios",
        ylab="sum of probabilities",
        xlab="",
        col = color,
        las=2)
