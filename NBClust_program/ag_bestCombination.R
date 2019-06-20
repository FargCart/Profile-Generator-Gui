
ag_bestCombination <- function(mtx, stop_generation, s_population){
  calc_features <- function(subject){
    temp <- NULL
    for(j in 1:ncol(subject)){
      x <- subject[1,j]; y <- subject[2,j]
      temp[j] <- mtx[x,y]
    }
    #cat(temp)
    features <- sum(temp)
    return(features)
  }
  
  dimension <- dim(mtx)
  index <- 1; break_interection <- 1
  population <- list(); features <- NULL
  
  if(dimension[1] >= 4){ group_siz <- 4 
  }else{ group_siz <- dimension[1] }
  
  # Creating the initial population
  while(break_interection < s_population){
    dx <- sample(x = dimension[1], replace = F, size = group_siz)
    dy <- sample(x = dimension[2], replace = F, size = group_siz)
    
    subject <- rbind(dx,dy)
    population[[index]] <- subject
    
    temp <- NULL
    for(j in 1:ncol(subject)){
      x <- subject[1,j]; y <- subject[2,j]
      temp[j] <- mtx[x,y]
    }
    
    features[index] <- sum(temp)
    
    index <- index +1
    break_interection <- break_interection +1
  }
  
  generation <- 1;
  while(stop_generation > generation){
    
    # Selecting the 4 best individuals
    best_subject_indexes <- order(features, decreasing = F)[1:6]
    worst_subject_indexes <- order(features, decreasing = T)[1:3]
    
    # Crossing the Best Individuals
    dad1 <- population[[best_subject_indexes[1]]]
    mon1 <- population[[best_subject_indexes[2]]]
    
    son1 <- rbind(dad1[1,], mon1[2,])
    
    dad2 <- population[[best_subject_indexes[3]]]
    mon2 <- population[[best_subject_indexes[4]]]
    
    son2 <- rbind(dad2[1,], mon2[2,])
    
    dad3 <- population[[best_subject_indexes[5]]]
    mon3 <- population[[best_subject_indexes[6]]]
    
    son3 <- rbind(dad3[1,], mon3[2,])
    
    #mutation
    mx1 <- setdiff(1:dimension[1],son3[1,])[1]
    if(!is.na(mx1)){
      modify <- sample(x = son3[1,], replace = F, size = 1)
      index_modify <- which(son3[1,] == modify)
      son3[1,index_modify] <- mx1
    }else{
      modify <- sample(x = son3[1,], replace = F, size = 2)
      index_modify <- which(son3[1,] %in% modify)
      temp <- son3[1,index_modify[1]]
      son3[1,index_modify[1]] <- son3[1,index_modify[2]]
      son3[1,index_modify[2]] <- temp
    }
    mx2 <- setdiff(1:dimension[2],son3[2,])[1]
    if(!is.na(mx2)){
      modify <- sample(x = son3[2,], replace = F, size = 1)
      index_modify <- which(son3[2,] == modify)
      son3[2,index_modify] <- mx2
    }else{
      modify <- sample(x = son3[2,], replace = F, size = 2)
      index_modify <- which(son3[2,] %in% modify)
      temp <- son3[2,index_modify[1]]
      son3[2,index_modify[1]] <- son3[2,index_modify[2]]
      son3[2,index_modify[2]] <- temp
    }
    
    #exchanging their children with the worst-off individuals
    population[[worst_subject_indexes[1]]] <- son1
    population[[worst_subject_indexes[2]]] <- son2
    population[[worst_subject_indexes[3]]] <- son3
    
    feature_son1 <- calc_features(son1)
    feature_son2 <- calc_features(son2)
    feature_son3 <- calc_features(son3)
    
    
    features[worst_subject_indexes[1]] <- feature_son1
    features[worst_subject_indexes[2]] <- feature_son2
    features[worst_subject_indexes[3]] <- feature_son3
    
    #cat("\nbest feature",min(features),"\n")
    #cat("\nfeatures:",features,"\n")
    #cat("\npopulation:\n")
    #print(population)
    #cat("\n")
    
    #browser()
    generation <- generation +1
  }
  
  index <- which(features == min(features))
  mtx_solution <- population[[index[1]]]
  
  return(mtx_solution)
}



