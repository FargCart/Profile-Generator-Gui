# Author: Leandro Corrêa ~@hscleandro
# Date: March 05 2018

library(shiny)
# library(shinyalert)
source("helpers.R")

#devtools::install_github("shinyBS", "ebailey78", "menu-integration")

# Sets the maximum size of the input file
options(shiny.maxRequestSize = 700*1024^3)  

shinyServer(function(input, output, session) {
  
  # ============================Strat_Global_variables===========================================
  # Global variables executed during the program
  dataFiles <- reactiveValues( 
    control = FALSE,
    alfa = 0,
    standard = NULL, 
    weighted = TRUE,
    orientation = NULL,
    comm_All = NULL,
    dist_Metric = NULL,
    link_Algo = NULL,
    orphans = NULL,
    missingRowNames = NULL,
    missingColumnNames = NULL,
    group_color = list(),
    graph = NULL,
    graph_copy = NULL,
    method = NULL,
    sample_name = NULL,
    result = NULL,
    text = NULL,
    kt = NULL,
    dend = NULL,
    color.pv = NULL,
    result.label = NULL,
    input_data = NULL,
    table_metrics = NULL,
    metrics_groups = NULL,
    size_bar = -1,
    change_button = FALSE,
    nclusters = NULL,
    color_nbc = NULL,
    settings = NULL,
    options_1 = NULL, # Network metrics
    options_2 = NULL, # Vertexs metrics
    options_3 = NULL  # Intra-communities metrics
  )
  # ============================Ends_Global_variables===========================================
  
  # ============================Start_Control_buttons===========================================
  
  # Open or close Plots and Results sections
  output$openPlots <- reactive({ FALSE })
  outputOptions(output, 'openPlots', suspendWhenHidden = FALSE)
  
  # Controls the transition between the "Settings" tabs (Network and Clustering)
  output$controlSettings <- reactive({
    dataFiles$control_settings = 0
  })
  outputOptions(output, 'controlSettings', suspendWhenHidden = FALSE)
  
  # Control when the "input k" option appears (Nbclust section)
  output$controlr <- reactive({
    dataFiles$control
  })
  outputOptions(output, 'controlr', suspendWhenHidden = FALSE)
  
  #output$controlpopup <- reactive({
  #  dataFiles$popup
  #})
  #outputOptions(output, 'controlpopup', suspendWhenHidden = FALSE)

  # Button "Run analysis" inactive while there isn't upload
  observeEvent(input$uploadFile, ignoreNULL = FALSE, {
    toggleState("loadFileBtn", !is.null(input$uploadFile))
  })
  
  # Button "Download" inactive while there isn't "Run analysis"
  observeEvent(input$loadFileBtn, ignoreNULL = FALSE, {
    toggleState("downloadBtn", !is.null(input$loadFileBtn))
  })
  
  # Button "Run analysis" inactive while there isn't upload
  observeEvent(input$loadFileBtn, ignoreNULL = FALSE, {
    toggleState("runAnalysisBtn", (input$loadFileBtn > 0))
  })
  
  # Button "Change it" inactive while "Run analysis" is not cliked
  observeEvent(dataFiles$change_button, ignoreNULL = FALSE, {
    toggleState("loadGroupsBtn", (dataFiles$change_button))
  })
  # ============================End_Control_buttons===========================================
  
  # Change to Input tab after clicking the "upload data"
  observeEvent(input$loadFileBtn, {
    dataFiles$standard <- as.character(input$query)
    updateTabsetPanel(session, "resultsTab", "Input")
    
  })
  
  #-# Input section
  # Get the input file
  inputData <- reactive({
    
    file <- input$uploadFile
    
    # Identifies the extension of the input file (csv or xlsx) and copies it to the "data" directory
    extension<- strsplit(file$name, "[.]")[[1]][2]
    if(extension== "csv"){       newPath <- paste0(getwd(),"/data/input.csv") }
    else if(extension== "xls"){  newPath <- paste0(getwd(),"/data/input.xls") }
    else if(extension== "xlsx"){ newPath <- paste0(getwd(),"//data//input.xlsx") }
    comand <- paste0("cp ",file$datapath," ",newPath)
    system(comand)
    
    # Loads the input file as an R data frame
    PATH <- newPath
    if(extension== "csv")
    {
      input_data <- read.csv(file = PATH, header = FALSE, row.names = 1)
      input_data <- as.matrix(input_data)
      cnames <- as.character(input_data[1,])
      input_data <- input_data[-1,]
      
      colnames(input_data) <- paste0(" ",cnames)
      rownames(input_data) <- paste0(" ",rownames(input_data))
    }
    else{
      input_data <- read.xlsx(PATH, rowNames = T)
    }

    dataFiles$missingColumnNames <- setdiff(rownames(input_data),colnames(input_data))
    dataFiles$missingRowNames    <- setdiff(colnames(input_data),rownames(input_data))
    
    dataFiles$orphans  <- union(dataFiles$missingColumnNames, dataFiles$missingRowNames)
    
    # Transforms the input matrix into a square matrix with equal rows and columns 
    # (view this functions in helpers.R)
    input_data <- stadard_matrix(input_data, TRUE)
    input_data <- stadard_matrix(input_data, FALSE)
    input_data <- order_matrix(input_data)
    input_data <- as_numeric_matrix(input_data)
    input_data[is.na(input_data)] <- 0
    
    dataFiles$input_data <- input_data
    
    input_data
    
  })
  
  #-# Result section
  # this controls the color that appears next the selectInput of intra-community panel
  observeEvent(input$comm,{
    
    updateColourInput(session, "col", label = "", value = input$comm,
                      showColour = "background", allowTransparent = FALSE)
    
    # Information that appears bellow the table of intra-community panel
    group_vertexs <- dataFiles$group_color[[input$comm]]
    group_vertexs <- paste0("vertices contained in the group: ", group_vertexs)
    output$vertex_groups <- renderText({ group_vertexs })
  })
  
  #-# Result section
  # SelectInput of groups in the Intra-Community panel
  output$selectCommunity <- renderUI({
    if(is.null(dataFiles$nclusters)) { communities <- "white"}
    else{ communities <- dataFiles$nclusters }
    if("grey" %in% communities){
      arg.grey <-  which(communities == "grey")
      communities <- communities[-arg.grey]
    }
    
    selectInput(inputId = "comm", label = "", choices = communities) 
    
  })
  
  #-# Plots section
  # this controls the color that appears next the selectInput of Groups panel in the left side
  observeEvent(input$selgroup,{
    #cat("aqui (1):",input$selgroup,"\n")
    color <- input$selgroup
    if(color == "grey"){ color <- "#808080"}
    updateColourInput(session, "colgroups", label = "", value = color,
                      showColour = "background", allowTransparent = FALSE)
  })
  
  #-# Plots section
  # SelectInput of groups in the Groups panel (left side)
  output$selectGroups <- renderUI({
    if(is.null(dataFiles$nclusters)) { communities <- "white"}
    else{ communities <- dataFiles$nclusters }
    
    selectInput(inputId = "selgroup", label = "", choices = communities) 
    
  })
  
  #-# Plots section
  # this controls the color that appears next the selectInput of Groups panel in the right side
  observeEvent(input$chgroup,{
    #cat("aqui (2):",input$chgroup,"\n")
    color <- input$chgroup
    if(color == "grey"){ color <- "#808080"}
    updateColourInput(session, "colChangegroups", label = "", value = color,
                      showColour = "background", allowTransparent = FALSE)
  })
  
  #-# Plots section
  # SelectInput of groups in the Groups panel (right side)
  output$changegroup <- renderUI({
    if(is.null(dataFiles$nclusters)) { communities <- "white"}
    else{ communities <- dataFiles$nclusters }
    
    selectInput(inputId = "chgroup", label = "", choices = communities) 
    
  })
  
  #-# Settings section
  # button "control settings" to control which tab will be presented (grouping or network)
  observeEvent(input$control_settings, {
    if(dataFiles$control_settings == 0){
      show("settings_div_clustering")
      hide("settings_div_networking")
      dataFiles$control_settings <- 1
      #updateButton(session, "control_settings",label = "Go to Clustering settings", block = F, style = "success") 
    }else{
      show("settings_div_networking")
      hide("settings_div_clustering")
      dataFiles$control_settings <- 0
      #updateButton(session, "control_settings",label = "Go to Network settings", block = F, style = "success") 
    }
    
  })
  
  #-# Input section
  # Control of the data preprocessing functions shown in the left panel of the program
  getPreprocessing <- function(){
    
    preprocessing <- dataFiles$standard
    
    # Get the input table pre-processed
    input_table <- inputData()
    
    if(preprocessing == "scale"){ 
      
      input_table <- as.matrix(scale(input_table, center = FALSE)) 
      input_table[is.na(input_table)] <- 0
    }
    else if(preprocessing == "minmax"){    
      
      min <- as.numeric(input$min); max <- as.numeric(input$max)
      if(is.na(min)){min <- 0; max <- 1}
      if(is.na(max)){min <- 0; max <- 1}
      
      row_index <- NULL; col_index <- NULL; row_index <- NULL; r <-1; c <- 1
      for(i in 1:nrow(input_table)){
        if(sum(input_table[i,]) == 0){
          row_index[r] <- i
          r <- r + 1
        }
        if(sum(input_table[,i]) == 0){
          col_index[c] <- i
          c <- c + 1
        }
      }
      
      input_table <- minMax(input_table, min, max)
      if(length(row_index) > 0){ input_table[row_index,] <- 0 }
      if(length(col_index) > 0){ input_table[,col_index] <- 0 }
    }
    
    else if(preprocessing == "asymmetric"){
      
      input_table <- asymmetries(input_table,
                                 dataFiles$missingRowNames,
                                 dataFiles$missingColumnNames)
      input_table <- input_table[which(duplicated(rownames(input_table))==FALSE),
                                 which(duplicated(colnames(input_table))==FALSE)]
    }
    
    if(input$appClust == "Collum"){ input_table <- t(input_table) }
    
    return(input_table)
  }
  
  #-# Server 
  # Box that is located below the left panel of the program containing some general network metrics
  printInShinyBox <- function(phrase){
    foo <- function(message_teste) {
      message(message_teste)
      Sys.sleep(0.5)
    }
    
    withCallingHandlers({
      shinyjs::html("text", "")
      foo(phrase)
    },
    message = function(m) {
      shinyjs::html(id = "text", html = m$message, add = TRUE)
    })
  }
  
  #-# Input section
  # function responsible for the Input tab table
  observeEvent(input$loadFileBtn, {
    
    input_table <- getPreprocessing()
    #lapply(input_table, format, scientific = FALSE, big.mark = ",", drop0trailing = TRUE) 
    
    output$inputTable <- DT::renderDataTable({
      
      DT::datatable(
        input_table,
        rownames = rownames(input_table),
        class = 'cell-border stripe',
        colnames = colnames(input_table),
        extensions = "Buttons",
        options = list(
          searching = FALSE, paging = FALSE,
          scrollX = TRUE, scrollY = 500,
          #columnDefs = list(list(visible = FALSE, targets = metaColsHideIdx())),
          dom = 'C<"clear">Blftp',
          scrollCollapse = TRUE,
          buttons = I('colvis')
        ))
      
    })
    
  })
  
  #-# Plots section
  # Controls the selection table of group painel
  observeEvent(input$selgroup,{
    
    table_vgroups <- dataFiles$group_color[[input$selgroup]]
    if(!is.null(table_vgroups)){
      table_vgroups <- strsplit(table_vgroups,"; ")[[1]]
    }
    data <- as.data.frame(table_vgroups)

    output$dataTableGroups = DT::renderDataTable({
      #
      DT::datatable(
        data, escape = FALSE, 
        selection = 'multiple', 
        extensions = 'Responsive', 
        rownames = FALSE, 
        colnames = "",
        
        #formatStyle(0,target="row"),
        options = list(
          lengthChange = 10,
          searching = FALSE,
          paging = FALSE,
          scrollY = FALSE
          #initComplete = JS(
          #  "function(settings, json) {",
          #  "var headerBorder = [0,0];",
          #  "var header = $(this.api().table().header()).find('tr:first > th').filter(function(index) 
          #  {return $.inArray(index,headerBorder) > -1 ;}).addClass('cell-border-right');",
          #  "}"),columnDefs=list(list(className="dt-right cell-border-right",targets=1))
        #    preDrawCallback = JS('function() { Shiny.unbindAll(this.api().table().node()); }'),
        #    drawCallback = JS('function() { Shiny.bindAll(this.api().table().node()); } ')
        )
      )
    })
  })
  
  #-# Control parameters of pvcluster option
  dataModal <- function(failed = FALSE) {
    modalDialog(
      tags$head(tags$style(".modal-dialog{ width:400px}")),
      strong(span("Additional pvcluster parameters")),
      br(),
      bootstrapPage(
        div(style="display:inline-block", span("alfa factor:")),
        div(style="display:inline-block", numericInput("alfa", "", min=0, max=1, step=0.01, value = 0.95, width = "70px")),
        div(style="display:inline-block", checkboxInput("plotGroup", "optional clusters", FALSE))
      ),
      #checkboxInput("plotGroup", "optional clusters", FALSE),
      if (failed)
        div(tags$b("Invalid name of data object", style = "color: red;")),
      easyClose = TRUE,
      footer = tagList(
        modalButton("Cancel"),
        actionButton("ok", "OK")
      )
    )
    
  }
  
  observeEvent(input$ok, {
    print(input$alfa)
    # Check that data object exists and is data frame.
    if (!is.na(input$alfa)){
      removeModal()
    } else {
      showModal(dataModal(failed = TRUE))
    }
  })
  
  observeEvent(input$method, {
    if(input$method == "Pvclust Analysis"){
        showModal(dataModal())
    }
  })
  
  #-# Settings section
  # After "Run analysis" button event...
  observeEvent(input$runAnalysisBtn, {
    
    withBusyIndicatorServer("runAnalysisBtn", {
      
      # ============================Start_Variables_group_Analysis===========================================
      start.time <- Sys.time()
      dataFiles$options_1 <- input$nmetrics
      dataFiles$options_2 <- input$nvertexs
      dataFiles$options_3 <- input$nintracomm
      if (is.null(dataFiles$options_1)){dataFiles$options_1 <- ""}
      if (is.null(dataFiles$options_2)){dataFiles$options_2 <- ""}
      if (is.null(dataFiles$options_3)){dataFiles$options_3 <- ""}
      
      input_table <- getPreprocessing()
      if(nrow(input_table < 50)){dataFiles$size_bar < 0}
      else if(nrow(input_table < 100)){dataFiles$size_bar < -1}
      else if(nrow(input_table < 500)){ dataFiles$size_bar < -3}
      else { dataFiles$size_bar < -5}
      
      if(input$weighted == "FALSE"){ dataFiles$weighted <- FALSE }
      dataFiles$orientation <- as.character(input$orientation)
      dataFiles$comm_All    <- as.character(input$community_algorithms)
      dataFiles$dist_Metric <- as.character(input$distMetric)
      dataFiles$link_Algo   <- as.character(input$linkAlgo)
      
      # Gets the sample name from the file that was loaded
      file <- input$uploadFile
      sample_name <-  as.character(strsplit(as.character(file$name), "[.]")[[1]][1])
      
      # Transforms the preprocessed input table into an igraph R object (network)
      g1 <- graph.adjacency(as.matrix(input_table), weighted = dataFiles$weighted, mode = dataFiles$orientation)
      
      # Object g2 was created for methods that do not allow input of negative values
      input_table2 <- minMax(inputData(), 0, 1)
      if(input$appClust == "Collum"){ input_table2 <- t(input_table2) }
      g2 <- graph.adjacency(as.matrix(input_table2), weighted = dataFiles$weighted, mode = dataFiles$orientation)
      
      # Gets the dendogram (dend object) using the dendextend package method
      dend <- input_table %>% # data
        dist(method = dataFiles$dist_Metric) %>% # calculate a distance matrix, 
        hclust(method = dataFiles$link_Algo) %>% # Hierarchical clustering 
        as.dendrogram # Turn the object into a dendrogram.
      
      # Gets the dendogram (hc object) using the native R method
      distt <- dist(as.matrix(input_table), method = dataFiles$dist_Metric)
      hc <- hclust(distt, method = dataFiles$link_Algo)
      
      # gets subgroups
      community <- walktrap.community(g1)
      
      # ============================Start_Variables_Run_Analysis====================================== 
      
      if(dataFiles$control_settings == 1){
        # Identifies the method selected by the user  
        if(input$method == "Dynamic Tree cut"){ 
          
          # Gets the results of dynamic tree and dynamic hybrid methods 
          # (view this functions in helpers.R)
          DetectedColors <- bestCutoffPoints(hc,distt)
          methods <- c("Dynamic Tree", "Dynamic Hybrid")
          colnames(DetectedColors) <- methods
          rownames(DetectedColors) <- labels(dend)
          
          method <- "dtree" 
          V(g1)$color <- DetectedColors[,"Dynamic Tree"] 
          text <- " with Dynamic Tree analysis"
          community$membership <- index_colors(DetectedColors[,"Dynamic Tree"])
          
          dataFiles$change_button = TRUE
          
        }
        else if(input$method == "Dybamic Hybrid cut"){ 
          
          # Gets the results of dynamic tree and dynamic hybrid methods 
          # (view this functions in helpers.R)
          DetectedColors <- bestCutoffPoints(hc,distt)
          methods <- c("Dynamic Tree", "Dynamic Hybrid")
          colnames(DetectedColors) <- methods
          rownames(DetectedColors) <- labels(dend)
          
          method <- "dhyb" 
          V(g1)$color = DetectedColors[,"Dynamic Hybrid"] 
          text <- " with Dynamic Hybrid analysis"
          community$membership <- index_colors(DetectedColors[,"Dynamic Hybrid"])
          
          dataFiles$change_button = TRUE
          
        }
        else if(input$method == "Pvclust Analysis"){
          method <- "pvc" 
          text <- " with pvclust analysis"
          # using the pvclust R package
          result.pv <- pvclust(as.matrix(input_table), 
                               method.dist=dataFiles$dist_Metric, 
                               method.hclust=dataFiles$link_Algo, 
                               nboot=100)
          result.label <- labels(as.dendrogram(result.pv$hclust))
          results <- pvpick(result.pv, alpha = 0.95)
          
          # Function that colors the groups found by the pvclust package in the 
          # order of the elements arranged in the dendogram 
          # (view this functions in helpers.R)
          pvclust <- pvclust_color(results$clusters, result.label)
          
          # coloring the vertices of the network according to the result of the pvclust package
          vertexs <- get.vertex.attribute(g1)$name
          k <- 1; pvclust.col <- NULL
          for(i in vertexs){
            pvclust.col[k] <- as.character(pvclust[which(i == names(pvclust))])
            k <- k +1
          }
          pvclust.col <- as.data.frame(pvclust.col)
          rownames(pvclust.col) <- vertexs
          V(g1)$color = as.character(pvclust.col$pvclust.col)
          
          community$membership <- index_colors(pvclust.col$pvclust.col)
          
          dataFiles$change_button = TRUE
          
        }
        else if(input$method == "NbClust analysis"){
          
          method <- "nbc" 
          text <- " with NbClust analysis"
          
          # normalizing the data and removing possible data missing
          mydata = as.data.frame(unclass(input_table))
          myDataClean = na.omit(mydata)
          #scaled_data = as.matrix(scale(myDataClean))
          scaled_data = as.matrix(myDataClean)
          scaled_data[is.na(scaled_data)==TRUE] <- 0
          
          dataFiles$change_button = FALSE
          
        }
        
        settings  <- data.frame("Apply Clustering:" = input$appClust, 
                                "Distance Metric:"  = input$distMetric, 
                                "Type of analysis:" = input$method,
                                "Linkage Algorithm:"= input$linkAlgo)
        
        dataFiles$settings <- t(settings)
      }
      else{
        if(input$community_algorithms == "edge.betweenness.community"){
          method <- "edge.betweenness.community"
          community <- edge.betweenness.community(g1)
          color_dend <- labels2colors(community$membership)
          names(color_dend) <- community$names
          V(g1)$color <- color_dend
          text <- " with edge betweenness community"
          
          dataFiles$change_button = TRUE
        }
        if(input$community_algorithms == "fastgreedy.community"){
          g <- graph.adjacency(as.matrix(input_table), weighted = TRUE, mode = "undirected")
          method <- "fastgreedy.community"
          community <- fastgreedy.community(g)
          color_dend <- labels2colors(community$membership)
          names(color_dend) <- community$names
          V(g1)$color <- color_dend
          text <- " with fastgreedy community"
          
          dataFiles$change_button = TRUE
        }
        if(input$community_algorithms == "walktrap.community"){
          method <- "walktrap.community"
          community <- walktrap.community(g1)
          color_dend <- labels2colors(community$membership)
          names(color_dend) <- community$names
          V(g1)$color <- color_dend
          text <- " with walktrap community"
          
          dataFiles$change_button = TRUE
        }
        if(input$community_algorithms == "spinglass.community"){
          method <- "spinglass.community"
          community <- spinglass.community(g1)
          color_dend <- labels2colors(community$membership)
          names(color_dend) <- community$names
          V(g1)$color <- color_dend
          text <- " with spinglass community"
          
          dataFiles$change_button = TRUE
        }
        if(input$community_algorithms == "leading.eigenvector.community"){
          g <- graph.adjacency(as.matrix(input_table), weighted = TRUE, mode = "undirected")
          method <- "leading.eigenvector.community"
          community <- leading.eigenvector.community(g)
          color_dend <- labels2colors(community$membership)
          names(color_dend) <- community$names
          V(g1)$color <- color_dend
          text <- " with leading eigenvector community"
          
          dataFiles$change_button = TRUE
        }
        if(input$community_algorithms == "label.propagation.community"){
          g <- graph.adjacency(as.matrix(input_table), weighted = TRUE, mode = "undirected")
          method <- "label.propagation.community"
          community <- label.propagation.community(g)
          color_dend <- labels2colors(community$membership)
          names(color_dend) <- community$names
          V(g1)$color <- color_dend
          text <- " with label propagation community"
          
          dataFiles$change_button = TRUE
        }
        
        settings  <- data.frame("Community Algorithms:" = input$community_algorithms, 
                                "Graph orientation:"    = input$orientation, 
                                "Weighted:"             = input$weighted)
        
        dataFiles$settings <- t(settings)
        
      }
      colnames(dataFiles$settings) <- NULL
      V(g1)$shape = rep("circle",nrow(inputData()))
      if(length(dataFiles$orphans) > 0){
        for(i in 1:length(dataFiles$orphans)){ V(g1)[V(g1)$name==dataFiles$orphans[i]]$shape <- "square" }
      }
      
      dataFiles$nclusters <- unique(V(g1)$color)
      
      # ============================End_Variables_Run_Analysis===========================================
      updateColourInput(session, "col", label = "", value = dataFiles$nclusters[1],
                        showColour = "background", allowTransparent = FALSE)
      # ============================Start_intra_metrics======================================
      color <- dataFiles$nclusters
      metrics_groups <- list(); k <- 1
      for(col in color){
        #col <- "turquoise"
        g3 <- delete.vertices(g1, V(g1)[ V(g1)[color != as.character(col)] ])
        dataFiles$group_color[[k]] <- paste0(as.character(V(g3)$name), collapse = ";")
        
        table_intraMetrics <- c("not metric","no value")
        
        if("nintracomm_1" %in% dataFiles$options_3){ 
          # average shortest path length
          ap_length_g3 <- average.path.length(g3)
          
          table_intraMetrics <- rbind(table_intraMetrics, 
                                      c("average shortest path length", ap_length_g3))
          
        }
        if("nintracomm_2" %in% dataFiles$options_3){ 
          # graph clique number
          graph_clique_n_g3 <- length(largest_cliques(g3)[[1]])
          
          table_intraMetrics <- rbind(table_intraMetrics, 
                                      c("average shortest path length", graph_clique_n_g3))
          
        }
        if("nintracomm_3" %in% dataFiles$options_3){ 
          # radius; minimum eccentricity of the graph.
          radius_g3 <- radius(g3, mode = "all")
          
          table_intraMetrics <- rbind(table_intraMetrics, 
                                      c("Minimum eccentricity of the graph", radius_g3))
          
        }
        if("nintracomm_4" %in% dataFiles$options_3){ 
          # density
          edge_density_g3 <- edge_density(g3, loops = FALSE)
          
          table_intraMetrics <- rbind(table_intraMetrics, 
                                      c("Density", edge_density_g3))
          
        }
        if("nintracomm_5" %in% dataFiles$options_3){ 
          # graph number of cliques
          cliques_g3 <- length(cliques(g3, min = 2, max = NULL))
          
          table_intraMetrics <- rbind(table_intraMetrics, 
                                      c("Graph number of cliques", cliques_g3))
          
        }
        if("nintracomm_6" %in% dataFiles$options_3){ 
          # transitivity
          transitivity_g3 <- transitivity(g3, type="global")
          
          table_intraMetrics <- rbind(table_intraMetrics, 
                                      c("Transitivitys", transitivity_g3))
          
        }
        if("nintracomm_7" %in% dataFiles$options_3){ 
          # transitivity
          # Extract clustering coefficient
          clustering_coefficient_g3 <- transitivity(g3, type="local")
          mean_clustering_coefficient_g3 <- mean(clustering_coefficient_g3)
          
          table_intraMetrics <- rbind(table_intraMetrics, 
                                      c("Mean clustering coefficient", mean_clustering_coefficient_g3))
          
        }
        if("nintracomm_8" %in% dataFiles$options_3){ 
          # degree assortativity coefficient
          assortativity_degree_g3 <- assortativity_degree(g3, directed = "directed")
          
          table_intraMetrics <- rbind(table_intraMetrics, 
                                      c("Degree assortativity coefficient", assortativity_degree_g3))
          
        }
        if("nintracomm_9" %in% dataFiles$options_3){ 
          # compactness
          n.nodes <- length(V(g1))
          index <- which(V(g1)$color == color)
          weights <- rep(0, n.nodes)
          weights[index] <- 1
          g1 <- set.vertex.attribute(g1, "weights", value=weights)
          compactness_g1 <- Compactness(g1, nperm=100, vertex.attr="weights", verbose=F)$pval
          
          table_intraMetrics <- rbind(table_intraMetrics, 
                                      c("Compactness", compactness_g1))
          
        }
        if("nintracomm_10" %in% dataFiles$options_3){ 
          # degree pearson correlation coefficient
          assortativity_g3 <- assortativity_b(g3)
          table_intraMetrics <- rbind(table_intraMetrics, 
                                      c("Degree pearson correlation coefficient", assortativity_g3))
          
        }
        if("nintracomm_11" %in% dataFiles$options_3){ 
          # number of connected components
          result <- clusters(g3)
          connected_components_g3 <- result$no
          table_intraMetrics <- rbind(table_intraMetrics, 
                                      c("Number of connected components", connected_components_g3))
          
        }
        if("nintracomm_12" %in% dataFiles$options_3){ 
          if(dataFiles$orientation == "directed"){
            # number of strongly connected components
            result <- clusters(g3, mode="strong") 
            connected_strong_components_g3 <- result$no
          }
          else{ connected_strong_components_g3 <- 0 }
          
          table_intraMetrics <- rbind(table_intraMetrics, 
                                      c("Number of strongly connected components", connected_strong_components_g3))
          
        }
        if("nintracomm_13" %in% dataFiles$options_3){ 
          if(dataFiles$orientation == "directed"){
            # number of weakly connected components
            result <- clusters(g3, mode="weak") 
            connected_weak_components_g3 <- result$no
          }
          else{ connected_weak_components_g3 <- 0 }
          
          table_intraMetrics <- rbind(table_intraMetrics, 
                                      c("Number of weakly connected components", connected_weak_components_g3))
          
        }
        if("nintracomm_14" %in% dataFiles$options_3){ 
          if(dataFiles$orientation == "directed"){
            # number of attracting components
            cp1 <- canonical_permutation(g3)
            number_attracting_components_g3 <- cp1$info$nof_leaf_nodes
          }
          else{ number_attracting_components_g3 <- 0 }
          
          table_intraMetrics <- rbind(table_intraMetrics, 
                                      c("Number of attracting components", number_attracting_components_g3))
          
        }
        
        #colnames(table_intraMetrics) <- c("Metrics","Values")
        #if(nrow(table_intraMetrics) > 1){ table_intraMetrics <- table_intraMetrics[-1,] }
        metrics_groups[[k]] <- table_intraMetrics
        k <- k +1
      }
      names(metrics_groups) <- color
      dataFiles$metrics_groups <- metrics_groups
      names(dataFiles$group_color)  <- color
      # ============================End_intra_metrics=======================================
      
      # ============================Start_metrics_Network===================================
      table_metrics <- NULL; col_names <- NULL
      if("nvertexs_1" %in% dataFiles$options_2){
        degree_g1 <-  degree(g1,v=V(g1),mode="all")
        degree_g1_deg_dist <-  degree.distribution(g1,cumulative=T,mode="all")
        table_metrics <- cbind(table_metrics, degree_g1)
        col_names <- c(col_names, "Degree")
      }
      if("nvertexs_2" %in% dataFiles$options_2){ 
        indegree_g1_deg_dist <- degree.distribution(g1,cumulative=T,mode="in")
        indegree_g1 <- degree(g1,v=V(g1),mode="in")
        table_metrics <- cbind(table_metrics, indegree_g1)
        col_names <- c(col_names, "In-degree")
      }
      if("nvertexs_3" %in% dataFiles$options_2){ 
        outdegree_g1 <- degree(g1,v=V(g1),mode="out")
        outdegree_g1_deg_dist <- degree.distribution(g1,cumulative=T,mode="out")
        table_metrics <- cbind(table_metrics, outdegree_g1)
        col_names <- c(col_names, "Out-degree")
      }
      if("nvertexs_4" %in% dataFiles$options_2){ 
        # Calculating average neighbor degree
        # (view this functions in helpers.R)
        neighborhoodConnectivity_g1 <- neighborhoodConnectivity(g1)
        table_metrics <- cbind(table_metrics, neighborhoodConnectivity_g1)
        col_names <- c(col_names, "Average neighbor degree")
      }
      if("nvertexs_5" %in% dataFiles$options_2){ 
        # Extract clustering coefficient
        clustering_coefficient_g1 <- transitivity(g1, type="local")
        table_metrics <- cbind(table_metrics, clustering_coefficient_g1)
        col_names <- c(col_names, "Clustering coefficient")
      }
      if("nvertexs_6" %in% dataFiles$options_2){ 
        # calculating the Degree centrality ($res)
        degree_centr_g1 <- centr_degree(g1, mode = "all", loops = TRUE, normalized = FALSE)
        table_metrics <- cbind(table_metrics, degree_centr_g1$res)
        col_names <- c(col_names, "Degree centrality")
      }
      if("nvertexs_7" %in% dataFiles$options_2){ 
        # calculating the Degree centrality ($res)
        indegree_centr_g1 <- centr_degree(g1, mode = "in", loops = TRUE, normalized = FALSE)
        table_metrics <- cbind(table_metrics, indegree_centr_g1$res)
        col_names <- c(col_names, "In-degree centrality")
      }
      if("nvertexs_8" %in% dataFiles$options_2){ 
        # calculating the Degree centrality ($res)
        outdegree_centr_g1 <- centr_degree(g1, mode = "out", loops = TRUE, normalized = FALSE)
        table_metrics <- cbind(table_metrics, outdegree_centr_g1$res)
        col_names <- c(col_names, "Out-degree centrality")
      }
      if("nvertexs_9" %in% dataFiles$options_2){ 
        #Extract betweennes centrality
        bet_centrality_g2 <- betweenness(g2, v=V(g2), directed = TRUE, 
                                         nobigint = TRUE, normalized = FALSE)
        table_metrics <- cbind(table_metrics, bet_centrality_g2)
        col_names <- c(col_names, "Betweenness centrality")
      }
      if("nvertexs_10" %in% dataFiles$options_2){ 
        # Eigenvector centrality
        evcent_g1 <- evcent(g1, options = list(maxiter = 1000000))[[1]]
        table_metrics <- cbind(table_metrics, evcent_g1)
        col_names <- c(col_names, "Eigenvector centrality")
      }
      if("nvertexs_11" %in% dataFiles$options_2){ 
        # calculating the closeness vitality
        # (view this functions in helpers.R)
        closeness_vitality_g2 <- closeness_vitality(g2)
        table_metrics <- cbind(table_metrics, closeness_vitality_g2)
        col_names <- c(col_names, "Closeness vitality")
      }
      if("nvertexs_12" %in% dataFiles$options_2){ 
        # Calculating Core number
        core_number_g1 <- coreness(g1, mode = "all")
        table_metrics <- cbind(table_metrics, core_number_g1)
        col_names <- c(col_names, "Core number")
      }
      if("nvertexs_13" %in% dataFiles$options_2){ 
        # Calculating Information centrality
        Info_centrality_g2 <- info.centrality.vertex(g2)
        table_metrics <- cbind(table_metrics, Info_centrality_g2)
        col_names <- c(col_names, "Information centrality")
      }
      if("nvertexs_14" %in% dataFiles$options_2){ 
        # calculating the eccentricity
        eccentricity_g1 <- eccentricity(g1)
        table_metrics <- cbind(table_metrics, eccentricity_g1)
        col_names <- c(col_names, "Eccentricity")
      }
      if("nvertexs_15" %in% dataFiles$options_2){ 
        # calculating the Closeness Centrality
        closeness_g2 <- closeness(g2, vids = V(g2), mode = "all", normalized = FALSE)
        table_metrics <- cbind(table_metrics, closeness_g2)
        col_names <- c(col_names, "Closeness centrality")
      }
      
      if(!is.null(table_metrics)){
        colnames(table_metrics) <- col_names
        rownames(table_metrics) <- as.character(V(g1)$name)
        table_metrics <- as.data.frame(table_metrics)
      }
      dataFiles$table_metrics <- table_metrics
      # ============================End_metrics_Network===================================
      
      #-# Plots section
      # Plotting the dendograms
      #output$plot_dendo <- renderPlot({
      output$plot_dendo <- renderImage({
        png(paste0(sample_name,".png",sep=""), height=input$height_dendo, width=input$width_dendo, res=100, units="cm")  
        if(dataFiles$control_settings == 1){
          if(method == "pvc"){
            
            result.label <- labels(as.dendrogram(result.pv$hclust))
            results <- pvpick(result.pv, alpha = input$alfa)
            pvclust.col <- pvclust_color(results$clusters, result.label)
            pvclust.col <- as.data.frame(pvclust.col)
            
            dataFiles$result.label <- result.label
            dataFiles$color.pv <- pvclust.col$pvclust.col
            #png(paste0(sample_name,".png",sep=""), height=input$height_dendo, width=input$width_dendo, res=100, units="cm")  
            plot(result.pv, 
                 main = paste0("Input ", sample_name, text),
                 sub = "",
                 xlab = "")
            if(input$plotGroup == TRUE){ pvrect(result.pv, alpha=0.95) }
            colored_bars(dataFiles$color.pv, 
                         dend = as.dendrogram(result.pv$hclust),
                         add = T,
                         rowLabels = "pvcluster",
                         sort_by_labels_order = F, y_scale = dataFiles$size_bar)
            #dev.off()
            dataFiles$result = result.pv
            dataFiles$control = FALSE
            
          }
          else if(method == "nbc"){
            
            dataFiles$control = TRUE
            
            T1 <- fviz_nbclust(scaled_data, 
                               FUNcluster =  hcut, 
                               nstart = 25,  
                               method = c("silhouette"), 
                               nboot = 500)+
              labs(subtitle = "Silhouette statistic method")
            
            plot(T1)
            
          }
          else{
            
            rlabel <- gsub("with ","\\1",text)
            rlabel <- gsub(" analysis","\\1",rlabel)
            
            color <- V(g1)$color
            color <- as.data.frame(color)
            #png(paste0(sample_name,".png",sep=""), height=input$height_dendo, width=input$width_dendo, res=100, units="cm")  
            plot(dend, main = paste0("Input ", sample_name, text))
            colored_bars(colors = color, 
                         dend = dend,
                         rowLabels =  rlabel,
                         y_scale = dataFiles$size_bar)
            #dev.off()
            dataFiles$control = FALSE
          }
        }
        else{
          #png(paste0(sample_name,".png",sep=""), height=input$height_dendo, width=input$width_dendo, res=100, units="cm")  
          plot(dend, main = paste0("Input ", sample_name, text))
          colored_bars(colors = color_dend, dend = dend, y_scale = dataFiles$size_bar)
          #dev.off()
        }
        dev.off()
        #}, height= 700)
        return(list(src = paste0(sample_name,".png",sep=""),
                    contentType = "image/png",
                    width = round((as.numeric(input$width_dendo)*100)/2.54, 0),
                    height = round((as.numeric(input$height_dendo)*100)/2.54, 0),
                    alt = "plot"))
      },deleteFile=TRUE)
      
      #-# Plots section
      # Plotting igraph object
      output$graph_static <- reactivePlot(function() {
        #V(g1)$frame.color = "white"
        #V(g1)$label = Label
        #V(g1)$label.cex = input$vLabelFontSize
        #V(g1)$label.color = input$vfcolor
        
        #V(g1)$size = input$vSize
        
        #E(g1)$arrow.mode = 0
        #E(g1)$label = RelationLabel
        #E(g1)$label.cex = input$eLabelFontSize
        #E(g1)$label.color = input$efcolor
        #E(g1)$color = input$ecolor
        #E(g1)$width = input$eLWD
        #cat("Aqui (1):",community$membership,"\n")
        preprocessing <- dataFiles$standard
        if(preprocessing == "asymmetric"){
          E(g1)$lty=1   
          if(!is.null(E(g1)$weigth)){
            E(g1)[ weight == 1 ]$lty = 2 ## dashed lines for moLeg with values of 1
            E(g1)[ weight == 1 ]$color = "black"
            E(g1)[ weight > 1 ]$color = "black"
            E(g1)[ weight == 1 ]$width = 1
            E(g1)[ weight > 1 ]$width = 1
            
          }
        }
        V(g1)$frame.color = rep("black", length(V(g1)))
        #sapply(unique(membership(community)), function(g) {
        #  subg1<-induced.subgraph(g1, which(membership(community)==g)) #membership id differs for each cluster
        #  ecount(subg1)/ecount(g1)
        #})
        
        #cs <- data.frame(combn(unique(membership(community)),2))
        #cx <- sapply(cs, function(x) {
        #  es<-E(g1)[V(g1)[membership(community)==x[1]] %--% 
        #              V(g1)[membership(community)==x[2]]]    
        #  length(es)
        #})
        #cbind(t(cs),cx)
        
        plot(community, g1, layout = layout_with_fr)
        title(main = paste0(" Static Network", text," (",sample_name,")"), 
              cex.main = 2)
        title(sub = "Developed by Leandro Correa",
              cex.sub=0.8,col.sub="grey")
        
      }, height= 700 )
      
      #-# Plots section
      # Plotting with visNetwork R package
      output$network <- renderVisNetwork({
        
        g <- g1
        
        V(g)$shape = rep("dot",length(V(g1)))
        if(length(dataFiles$orphans) > 0){
          for(i in 1:length(dataFiles$orphans)){ V(g)[V(g)$name==dataFiles$orphans[i]]$shape <- "square" }
        }
        
        V(g)$label.cex <- 1
        V(g)$size <- 40
        E(g)$arrows <- 'to;from'
        E(g)$color <- "silver"
        data <- toVisNetworkData(g)
        nodes <- data[[1]]
        edges <- data[[2]]
        
        
        visNetwork(nodes, edges,
                   main = paste0("Interactive Network", text," (",sample_name,")")) %>%
          visOptions(selectedBy = "color", 
                     highlightNearest = list(enabled = TRUE, degree = 1,
                                             hover = FALSE)) %>%
          visIgraphLayout()
        
      })
      
      #-# Result section
      # Result table (Metrics) section 
      output$resultTable <- DT::renderDataTable({
        if(is.null(dataFiles$table_metrics)){
          m_empty <- matrix(data = "",ncol = 2,nrow = 2)
          m_empty <- as.data.frame(m_empty)
          colnames(m_empty) <- c("empty","empty")
          dataFiles$table_metrics <- m_empty
        }
        
        DT::datatable(
          dataFiles$table_metrics,
          rownames = rownames(dataFiles$table_metrics),
          class = 'cell-border stripe',
          colnames = colnames(dataFiles$table_metrics),
          extensions = "Buttons",
          options = list(
            searching = FALSE, paging = FALSE,
            scrollX = TRUE, scrollY = 500,
            #columnDefs = list(list(visible = FALSE, targets = metaColsHideIdx())),
            dom = 'C<"clear">Blftp',
            scrollCollapse = TRUE,
            buttons = I('colvis')
          ))
        
      })
      
      #-# Result section
      # Result table (asymmetries) section  
      output$asymetriesTable <- DT::renderDataTable({
        
        input_table3 <- asymmetries(inputData(),
                                    dataFiles$missingRowNames,
                                    dataFiles$missingColumnNames)
        
        g3 <- graph.adjacency(as.matrix(input_table3), weighted = TRUE, mode = "directed")
        
        table_asymmetries <- getAsymmetries(g3, input_table3, dataFiles$orphans)
        table_asymmetries <- as.data.frame(table_asymmetries)
        
        #rnames <- 1:nrow(table_asymmetries)
        #rownames(table_asymmetries) <- as.character(rnames)
        
        DT::datatable(
          table_asymmetries,
          rownames = NULL,
          class = 'cell-border stripe',
          colnames = c("ID","ID"),
          extensions = "Buttons",
          options = list(
            searching = FALSE, paging = FALSE,
            scrollX = TRUE, scrollY = 500,
            #columnDefs = list(list(visible = FALSE, targets = metaColsHideIdx())),
            #dom = 'C<"clear">Blftp',
            scrollCollapse = TRUE,
            buttons = I('colvis')
          ))
        
      })
      
      #-# Result section
      # Result of each community identified in the network
      output$intraTable <- DT::renderDataTable({
        
        color <- input$comm
        table_intraMetrics <- metrics_groups[[color]]
        
        if(class(table_intraMetrics) == "character"){
          if(table_intraMetrics[1] == "not metric"){
            m_empty <- matrix(data = "",ncol = 2,nrow = 2)
            m_empty <- as.data.frame(m_empty)
            colnames(m_empty) <- c(table_intraMetrics[1],table_intraMetrics[2])
            table_intraMetrics <- m_empty
          }
        }else{
          table_intraMetrics <- as.data.frame(table_intraMetrics)
          colnames(table_intraMetrics) <- c("Metrics","Values")
          table_intraMetrics <- table_intraMetrics[-1,]
          
        }
        
        DT::datatable(
          table_intraMetrics,
          rownames = NULL,
          class = 'cell-border stripe',
          colnames = colnames(table_intraMetrics),
          extensions = "Buttons",
          options = list(
            searching = FALSE, paging = FALSE,
            scrollX = TRUE, scrollY = 500,
            #columnDefs = list(list(visible = FALSE, targets = metaColsHideIdx())),
            #dom = 'C<"clear">Blftp',
            scrollCollapse = TRUE,
            buttons = I('colvis')
          ))
        
      })
      
      # Number of cliques
      if("nmetrics_1" %in% dataFiles$options_1){ cliques_g2 <- length(cliques(g2, min = 2, max = NULL)) }
      else{ cliques_g2 <- "NA" }
      
      # Number of triangles
      if("nmetrics_2" %in% dataFiles$options_1){ triangles_g2 <- length(cliques(g2, min = 3, max = 3)) }
      else{ triangles_g2 <- "NA"}
      
      # Squares clustering coefficient
      if("nmetrics_3" %in% dataFiles$options_1){ squares_g2 <- length(cliques(g2, min = 4, max = 4)) }
      else{ squares_g2 <- "NA" }
      
      end.time <- Sys.time()
      time.taken <- end.time - start.time
      message <- paste0("<b>Number of cliques: </b></br>", cliques_g2,"</br>")
      message <- paste0(message,"</br>","<b>Number of triangles: </b></br>", triangles_g2,"</br>")
      message <- paste0(message,"</br>","<b>Squares clustering coefficient: </b></br>", squares_g2,"</br>")
      printInShinyBox(message)
      
      time.taken <- round(time.taken, 2)
      rtime <- paste0("Runtime: ", time.taken," seconds")
      output$rtime <- renderText({ rtime })
      
      dataFiles$graph     = g1
      dataFiles$method    = method
      dataFiles$sample_name = sample_name
      
      dataFiles$text   = text
      dataFiles$dend   = dend
      
      #Sys.sleep(1000)
      output$openPlots <- reactive({ TRUE })
      updateTabsetPanel(session, "resultsTab", "Plots")
    })
    
  })
  
  
  #-# Result section
  fn_download <- function(){
    
    sample_name <- dataFiles$sample_name
    text <- dataFiles$text
    result.pv <- dataFiles$result
    dend <- dataFiles$dend 
    g1 <- dataFiles$graph
    kt <- dataFiles$kt
    
    if(dataFiles$control_settings == 1){
      png(paste0(sample_name,".png",sep=""), height=input$height_dendo, width=input$width_dendo, res=100, units="cm")  
      if(dataFiles$method == "pvc"){
        plot(result.pv, 
             main = paste0("Input ", sample_name, text),
             sub = "",
             xlab = "")
        pvrect(result.pv, alpha=0.95)
        colored_bars(dataFiles$color.pv, 
                     dend = as.dendrogram(result.pv$hclust),
                     add = T,
                     rowLabels = "pvcluster",
                     sort_by_labels_order = F, y_scale = dataFiles$size_bar)
      }
      else if(dataFiles$method == "nbc"){
        plot(x = dend, 
             hang = -1,
             sub = "",
             xlab = "",
             main = paste0("Input ", sample_name, " with branch cutting = ",kt)
        )
        colored_bars(dataFiles$color_nbc, 
                     dend = as.dendrogram(dend),
                     add = T,
                     rowLabels = paste0("k_", kt),
                     sort_by_labels_order = F, y_scale = dataFiles$size_bar)
      }
      else{
        rlabel <- gsub("with ","\\1",text)
        rlabel <- gsub(" analysis","\\1",rlabel)
        
        color <- V(g1)$color
        color <- as.data.frame(color)
        #png(paste0(sample_name,".png",sep=""), height=input$height_dendo, width=input$width_dendo, res=100, units="cm")  
        plot(dend, main = paste0("Input ", sample_name, text))
        colored_bars(colors = color, 
                     dend = dend,
                     rowLabels =  rlabel,
                     y_scale = dataFiles$size_bar)
      }
    }else{
      plot(dend, main = paste0("Input ", sample_name, text))
      colored_bars(colors = color_dend, dend = dend, y_scale = dataFiles$size_bar)
    }
    dev.off()
  }
  
  #-# Result section
  output$downloadBtn_dend <- downloadHandler(
    filename = paste0(dataFiles$sample_name,".png",sep=""),
    content = function(file) {
      fn_download()
      file.copy(paste0(dataFiles$sample_name,".png",sep=""), file, overwrite=T)
    }
  )
  
  #-# Settings section
  # Plot only in NbClust option
  observeEvent(input$subBestKBtn, {
    # ============================Start_Variables_NbClust====================================== 
    dataFiles$change_button = TRUE
    #cat("aqui (12):",dataFiles$change_button,"\n")
    input_table <- getPreprocessing()
    file <- input$uploadFile
    sample_name <-  as.character(strsplit(as.character(file$name), "[.]")[[1]][1])
    
    distt <- dist(as.matrix(input_table), method = dataFiles$dist_Metric)
    hc <- hclust(distt, method = dataFiles$link_Algo)
    
    kt <- input$caption
    if(is.na(as.numeric(kt))){ kt <- 1 }
    cutk <-  cutree(hc, k = kt)
    label_hc <- labels(hc)
    color <- hc_color(cutk, label_hc)
    
    g1 <- graph.adjacency(input_table, weighted = dataFiles$weighted, mode = dataFiles$orientation)
    
    net_color <- getDendoColor(V(g1)$name,label_hc,color)
    V(g1)$color = as.character(net_color)
    
    dataFiles$nclusters <- unique(V(g1)$color)
    
    # gets subgroups
    community <- walktrap.community(g1)
    community$membership <- net_color 
    # ============================End_Variables_NbClust====================================== 
    
    # ============================Start_intra_metrics======================================
    color2 <- dataFiles$nclusters
    metrics_groups <- list(); k <- 1
    for(col in color2){
      
      g3 <- delete.vertices(g1, V(g1)[ V(g1)[color != as.character(col)] ])
      dataFiles$group_color[[k]] <- paste0(as.character(V(g3)$name), collapse = ";")
      table_intraMetrics <- c("not metric","no value")
      
      if("nintracomm_1" %in% dataFiles$options_3){ 
        # average shortest path length
        ap_length_g3 <- average.path.length(g3)
        
        table_intraMetrics <- rbind(table_intraMetrics, 
                                    c("average shortest path length", ap_length_g3))
        
      }
      if("nintracomm_2" %in% dataFiles$options_3){ 
        # graph clique number
        graph_clique_n_g3 <- length(largest_cliques(g3)[[1]])
        
        table_intraMetrics <- rbind(table_intraMetrics, 
                                    c("average shortest path length", graph_clique_n_g3))
        
      }
      if("nintracomm_3" %in% dataFiles$options_3){ 
        # radius; minimum eccentricity of the graph.
        radius_g3 <- radius(g3, mode = "all")
        
        table_intraMetrics <- rbind(table_intraMetrics, 
                                    c("Minimum eccentricity of the graph", radius_g3))
        
      }
      if("nintracomm_4" %in% dataFiles$options_3){ 
        # density
        edge_density_g3 <- edge_density(g3, loops = FALSE)
        
        table_intraMetrics <- rbind(table_intraMetrics, 
                                    c("Density", edge_density_g3))
        
      }
      if("nintracomm_5" %in% dataFiles$options_3){ 
        # graph number of cliques
        cliques_g3 <- length(cliques(g3, min = 2, max = NULL))
        
        table_intraMetrics <- rbind(table_intraMetrics, 
                                    c("Graph number of cliques", cliques_g3))
        
      }
      if("nintracomm_6" %in% dataFiles$options_3){ 
        # transitivity
        transitivity_g3 <- transitivity(g3, type="global")
        
        table_intraMetrics <- rbind(table_intraMetrics, 
                                    c("Transitivities", transitivity_g3))
        
      }
      if("nintracomm_7" %in% dataFiles$options_3){ 
        # transitivity
        # Extract clustering coefficient
        clustering_coefficient_g3 <- transitivity(g3, type="local")
        mean_clustering_coefficient_g3 <- mean(clustering_coefficient_g3)
        
        table_intraMetrics <- rbind(table_intraMetrics, 
                                    c("Average clustering coefficient", mean_clustering_coefficient_g3))
        
      }
      if("nintracomm_8" %in% dataFiles$options_3){ 
        # degree assortativity coefficient
        assortativity_degree_g3 <- assortativity_degree(g3, directed = "directed")
        
        table_intraMetrics <- rbind(table_intraMetrics, 
                                    c("Degree assortativity coefficient", assortativity_degree_g3))
        
      }
      if("nintracomm_9" %in% dataFiles$options_3){ 
        # compactness
        n.nodes <- length(V(g1))
        index <- which(V(g1)$color == color)
        weights <- rep(0, n.nodes)
        weights[index] <- 1
        g1 <- set.vertex.attribute(g1, "weights", value=weights)
        compactness_g1 <- Compactness(g1, nperm=100, vertex.attr="weights", verbose=F)$pval
        
        table_intraMetrics <- rbind(table_intraMetrics, 
                                    c("Compactness", compactness_g1))
        
      }
      if("nintracomm_10" %in% dataFiles$options_3){ 
        # degree pearson correlation coefficient
        assortativity_g3 <- assortativity_b(g3)
        table_intraMetrics <- rbind(table_intraMetrics, 
                                    c("Degree pearson correlation coefficient", assortativity_g3))
        
      }
      if("nintracomm_11" %in% dataFiles$options_3){ 
        # number of connected components
        result <- clusters(g3)
        connected_components_g3 <- result$no
        table_intraMetrics <- rbind(table_intraMetrics, 
                                    c("Number of connected components", connected_components_g3))
        
      }
      if("nintracomm_12" %in% dataFiles$options_3){ 
        if(dataFiles$orientation == "directed"){
          # number of strongly connected components
          result <- clusters(g3, mode="strong") 
          connected_strong_components_g3 <- result$no
        }
        else{ connected_strong_components_g3 <- 0 }
        
        table_intraMetrics <- rbind(table_intraMetrics, 
                                    c("Number of strongly connected components", connected_strong_components_g3))
        
      }
      if("nintracomm_13" %in% dataFiles$options_3){ 
        if(dataFiles$orientation == "directed"){
          # number of weakly connected components
          result <- clusters(g3, mode="weak") 
          connected_weak_components_g3 <- result$no
        }
        else{ connected_weak_components_g3 <- 0 }
        
        table_intraMetrics <- rbind(table_intraMetrics, 
                                    c("Number of weakly connected components", connected_weak_components_g3))
        
      }
      if("nintracomm_14" %in% dataFiles$options_3){ 
        if(dataFiles$orientation == "directed"){
          # number of attracting components
          cp1 <- canonical_permutation(g3)
          number_attracting_components_g3 <- cp1$info$nof_leaf_nodes
        }
        else{ number_attracting_components_g3 <- 0 }
        
        table_intraMetrics <- rbind(table_intraMetrics, 
                                    c("Number of attracting components", number_attracting_components_g3))
        
      }
      
      #colnames(table_intraMetrics) <- c("Metrics","Values")
      #if(nrow(table_intraMetrics) > 0){ table_intraMetrics <- table_intraMetrics[-1,] }
      metrics_groups[[k]] <- table_intraMetrics
      k <- k +1
    }
    names(metrics_groups) <- color2
    dataFiles$metrics_groups <- metrics_groups
    names(dataFiles$group_color)  <- color2
    # ============================End_intra_metrics=======================================
    
    #-# Plots section
    # Plotting the dendograms
    output$plot_dendo <- renderImage({
      dataFiles$color_nbc <- color
      png(paste0(dataFiles$sample_name,".png",sep=""), height=input$height_dendo, width=input$width_dendo, res=100, units="cm")  
      plot(x = hc, 
           hang = -1,
           sub = "",
           xlab = "",
           main = paste0("Input ", sample_name, " with branch cutting = ",kt)
      )
      colored_bars(color, 
                   dend = as.dendrogram(hc),
                   add = T,
                   rowLabels = paste0("k_", kt),
                   sort_by_labels_order = F, y_scale = dataFiles$size_bar)
      dev.off()
      
      return(list(src = paste0(dataFiles$sample_name,".png",sep=""),
                  contentType = "image/png",
                  width = round((as.numeric(input$width_dendo)*100)/2.54, 0),
                  height = round((as.numeric(input$height_dendo)*100)/2.54, 0),
                  alt = "plot"))
    },deleteFile=TRUE)
    
    #-# Plots section
    # Plotting igraph object
    output$graph_static <- reactivePlot(function() {
      
      preprocessing <- dataFiles$standard
      if(preprocessing == "asymmetric"){
        E(g1)$lty=1   
        if(!is.null(E(g1)$weigth)){
          E(g1)[ weight == 1 ]$lty = 2 ## dashed lines for moLeg with values of 1
          E(g1)[ weight == 1 ]$color = "black"
          E(g1)[ weight > 1 ]$color = "black"
          E(g1)[ weight == 1 ]$width = 1
          E(g1)[ weight > 1 ]$width = 1
          
        }
      }
      V(g1)$frame.color = rep("black", nrow(input_table))
      
      plot(community, g1, layout = layout_with_fr)
      #plot(g1,layout = layout.auto)
      title(main = paste0("Static Network with branch cutting = ",kt," (",sample_name,")"), 
            cex.main = 2)
      title(sub = "Developed by Leandro Correa",
            cex.sub=0.8,col.sub="grey")
      
      
    }, height=700 )
    
    #-# Plots section
    # Plotting with visNetwork R package
    output$network <- renderVisNetwork({
      
      g <- g1
      
      V(g)$shape = rep("dot",nrow(inputData()))
      if(length(dataFiles$orphans) > 0){
        for(i in 1:length(dataFiles$orphans)){ V(g)[V(g)$name==dataFiles$orphans[i]]$shape <- "square" }
      }
      
      V(g)$label.cex <- 1
      V(g)$size <- 40
      E(g)$arrows <- 'to;from'
      E(g)$color <- "silver"
      data <- toVisNetworkData(g)
      nodes <- data[[1]]
      edges <- data[[2]]
      
      
      visNetwork(nodes, edges,
                 main = paste0("Interactive Network with branch cutting = ",kt," (",sample_name,")")) %>%
        visOptions(selectedBy = "color", 
                   highlightNearest = list(enabled = TRUE, degree = 1,
                                           hover = FALSE)) %>%
        visIgraphLayout()
      
    })
    
    #-# Result section
    # Result of each community identified in the network
    output$intraTable <- DT::renderDataTable({
      
      color <- input$comm
      table_intraMetrics <- metrics_groups[[color]]
      #g3 <- delete.vertices(g1, V(g1)[ V(g1)[color != color] ])
      
      if(class(table_intraMetrics) == "character"){
        if(table_intraMetrics[1] == "not metric"){
          m_empty <- matrix(data = "",ncol = 2,nrow = 2)
          m_empty <- as.data.frame(m_empty)
          colnames(m_empty) <- c(table_intraMetrics[1],table_intraMetrics[2])
          table_intraMetrics <- m_empty
        }
      }else{
        table_intraMetrics <- as.data.frame(table_intraMetrics)
        colnames(table_intraMetrics) <- c("Metrics","Values")
        table_intraMetrics <- table_intraMetrics[-1,]
        
      }
      
      DT::datatable(
        table_intraMetrics,
        rownames = NULL,
        class = 'cell-border stripe',
        colnames = colnames(table_intraMetrics),
        extensions = "Buttons",
        options = list(
          searching = FALSE, paging = FALSE,
          scrollX = TRUE, scrollY = 500,
          #columnDefs = list(list(visible = FALSE, targets = metaColsHideIdx())),
          #dom = 'C<"clear">Blftp',
          scrollCollapse = TRUE,
          buttons = I('colvis')
        ))
      
    })
    
    settings  <- data.frame("Apply Clustering:" = input$appClust, 
                            "Distance Metric:"  = input$distMetric, 
                            "Type of analysis:" = input$method,
                            "Linkage Algorithm:"= input$linkAlgo,
                            "cutting (k):"= kt)
    
    dataFiles$settings <- t(settings)
    
    dataFiles$graph     = g1
    dataFiles$community = community
    dataFiles$dend      = hc
    dataFiles$kt <- kt
    
  })
  
  #-# Plots section
  # Community settings
  observeEvent(input$loadGroupsBtn, {
    
    s = input$dataTableGroups_rows_selected
    new_group <- input$chgroup
    g1 <- dataFiles$graph
    
    color <- V(g1)$color
    names(color) <- V(g1)$name
    
    table_vgroups <- dataFiles$group_color[[input$selgroup]]
    
    if(!is.null(table_vgroups)){
      table_vgroups <- strsplit(table_vgroups,";")[[1]]
    }
    data <- as.data.frame(table_vgroups)

    if(!is.null(s)){
      selected <- as.character(data$table_vgroups[s])
      index <- which(names(color) %in% selected)
      color[index] <- rep(new_group, length(index)) 
      if(input$method == "Pvclust Analysis"){
        index <- which(dataFiles$result.label %in% selected)
        dataFiles$color.pv[index] <- rep(new_group, length(index)) 
        cat("vetror: ")
        print(dataFiles$result.label)
        cat("\nselected: ")
        print(selected)
        cat("\n")
      }
      
    }
    V(g1)$color <- color
    community <- walktrap.community(g1)
    community$membership <- index_colors(color)
    
    dataFiles$nclusters <- unique(V(g1)$color)
    
    color <- dataFiles$nclusters
    metrics_groups <- list(); k <- 1
    for(col in color){
      #col <- "turquoise"
      g3 <- delete.vertices(g1, V(g1)[ V(g1)[color != as.character(col)] ])
      dataFiles$group_color[[k]] <- paste0(as.character(V(g3)$name), collapse = ";")
      
      table_intraMetrics <- c("not metric","no value")
      
      if("nintracomm_1" %in% dataFiles$options_3){ 
        # average shortest path length
        ap_length_g3 <- average.path.length(g3)
        
        table_intraMetrics <- rbind(table_intraMetrics, 
                                    c("average shortest path length", ap_length_g3))
        
      }
      if("nintracomm_2" %in% dataFiles$options_3){ 
        # graph clique number
        graph_clique_n_g3 <- length(largest_cliques(g3)[[1]])
        
        table_intraMetrics <- rbind(table_intraMetrics, 
                                    c("average shortest path length", graph_clique_n_g3))
        
      }
      if("nintracomm_3" %in% dataFiles$options_3){ 
        # radius; minimum eccentricity of the graph.
        radius_g3 <- radius(g3, mode = "all")
        
        table_intraMetrics <- rbind(table_intraMetrics, 
                                    c("Minimum eccentricity of the graph", radius_g3))
        
      }
      if("nintracomm_4" %in% dataFiles$options_3){ 
        # density
        edge_density_g3 <- edge_density(g3, loops = FALSE)
        
        table_intraMetrics <- rbind(table_intraMetrics, 
                                    c("Density", edge_density_g3))
        
      }
      if("nintracomm_5" %in% dataFiles$options_3){ 
        # graph number of cliques
        cliques_g3 <- length(cliques(g3, min = 2, max = NULL))
        
        table_intraMetrics <- rbind(table_intraMetrics, 
                                    c("Graph number of cliques", cliques_g3))
        
      }
      if("nintracomm_6" %in% dataFiles$options_3){ 
        # transitivity
        transitivity_g3 <- transitivity(g3, type="global")
        
        table_intraMetrics <- rbind(table_intraMetrics, 
                                    c("Transitivitys", transitivity_g3))
        
      }
      if("nintracomm_7" %in% dataFiles$options_3){ 
        # transitivity
        # Extract clustering coefficient
        clustering_coefficient_g3 <- transitivity(g3, type="local")
        mean_clustering_coefficient_g3 <- mean(clustering_coefficient_g3)
        
        table_intraMetrics <- rbind(table_intraMetrics, 
                                    c("Mean clustering coefficient", mean_clustering_coefficient_g3))
        
      }
      if("nintracomm_8" %in% dataFiles$options_3){ 
        # degree assortativity coefficient
        assortativity_degree_g3 <- assortativity_degree(g3, directed = "directed")
        
        table_intraMetrics <- rbind(table_intraMetrics, 
                                    c("Degree assortativity coefficient", assortativity_degree_g3))
        
      }
      if("nintracomm_9" %in% dataFiles$options_3){ 
        # compactness
        n.nodes <- length(V(g1))
        index <- which(V(g1)$color == color)
        weights <- rep(0, n.nodes)
        weights[index] <- 1
        g1 <- set.vertex.attribute(g1, "weights", value=weights)
        compactness_g1 <- Compactness(g1, nperm=100, vertex.attr="weights", verbose=F)$pval
        
        table_intraMetrics <- rbind(table_intraMetrics, 
                                    c("Compactness", compactness_g1))
        
      }
      if("nintracomm_10" %in% dataFiles$options_3){ 
        # degree pearson correlation coefficient
        assortativity_g3 <- assortativity_b(g3)
        table_intraMetrics <- rbind(table_intraMetrics, 
                                    c("Degree pearson correlation coefficient", assortativity_g3))
        
      }
      if("nintracomm_11" %in% dataFiles$options_3){ 
        # number of connected components
        result <- clusters(g3)
        connected_components_g3 <- result$no
        table_intraMetrics <- rbind(table_intraMetrics, 
                                    c("Number of connected components", connected_components_g3))
        
      }
      if("nintracomm_12" %in% dataFiles$options_3){ 
        if(dataFiles$orientation == "directed"){
          # number of strongly connected components
          result <- clusters(g3, mode="strong") 
          connected_strong_components_g3 <- result$no
        }
        else{ connected_strong_components_g3 <- 0 }
        
        table_intraMetrics <- rbind(table_intraMetrics, 
                                    c("Number of strongly connected components", connected_strong_components_g3))
        
      }
      if("nintracomm_13" %in% dataFiles$options_3){ 
        if(dataFiles$orientation == "directed"){
          # number of weakly connected components
          result <- clusters(g3, mode="weak") 
          connected_weak_components_g3 <- result$no
        }
        else{ connected_weak_components_g3 <- 0 }
        
        table_intraMetrics <- rbind(table_intraMetrics, 
                                    c("Number of weakly connected components", connected_weak_components_g3))
        
      }
      if("nintracomm_14" %in% dataFiles$options_3){ 
        if(dataFiles$orientation == "directed"){
          # number of attracting components
          cp1 <- canonical_permutation(g3)
          number_attracting_components_g3 <- cp1$info$nof_leaf_nodes
        }
        else{ number_attracting_components_g3 <- 0 }
        
        table_intraMetrics <- rbind(table_intraMetrics, 
                                    c("Number of attracting components", number_attracting_components_g3))
        
      }
      
      #colnames(table_intraMetrics) <- c("Metrics","Values")
      #if(nrow(table_intraMetrics) > 1){ table_intraMetrics <- table_intraMetrics[-1,] }
      metrics_groups[[k]] <- table_intraMetrics
      k <- k +1
    }
    
    names(metrics_groups) <- color
    names(dataFiles$group_color)  <- color
    
    sample_name <- dataFiles$sample_name
    dend <- dataFiles$dend
    
    if(input$method != "Pvclust Analysis"){ 
      color <- V(g1)$color
      color <- as.data.frame(color)
    }
    else{ color <- dataFiles$color.pv }
    text <- dataFiles$text
    method <- dataFiles$method
    
    #-# Plots section
    # Plotting the dendograms
    output$plot_dendo <- renderPlot({
      
      if(method == "pvc"){
        result.pv <- dataFiles$result
        
        result.label <- labels(as.dendrogram(result.pv$hclust))
        
        plot(result.pv, 
             main = paste0("Input ", sample_name, text),
             sub = "",
             xlab = "")
        pvrect(result.pv, alpha=0.95)
        colored_bars(color, 
                     dend = as.dendrogram(result.pv$hclust),
                     add = T,
                     rowLabels = "pvcluster",
                     sort_by_labels_order = F, y_scale = dataFiles$size_bar)
        
      }
      else if(method == "nbc"){
        kt <- dataFiles$kt
        plot(x = dend, 
             hang = -1,
             sub = "",
             xlab = "",
             main = paste0("Input ", sample_name, " with branch cutting = ",kt)
        )
        colored_bars(color, 
                     dend = as.dendrogram(dend),
                     add = T,
                     rowLabels = paste0("k_", kt),
                     sort_by_labels_order = F, y_scale = dataFiles$size_bar)
        
      }
      else{
        rlabel <- gsub("with ","\\1",text)
        rlabel <- gsub(" analysis","\\1",rlabel)
        
        color <- V(g1)$color
        color <- as.data.frame(color)
        plot(dend, main = paste0("Input ", sample_name, text))
        colored_bars(colors = color, 
                     dend = dend, 
                     rowLabels =  rlabel,
                     y_scale = dataFiles$size_bar)
        
      }
    }, height= 700)
    
    #-# Plots section
    # Plotting igraph object
    output$graph_static <- reactivePlot(function() {
      #V(g1)$frame.color = "white"
      #V(g1)$label = Label
      #V(g1)$label.cex = input$vLabelFontSize
      #V(g1)$label.color = input$vfcolor
      
      #V(g1)$size = input$vSize
      
      #E(g1)$arrow.mode = 0
      #E(g1)$label = RelationLabel
      #E(g1)$label.cex = input$eLabelFontSize
      #E(g1)$label.color = input$efcolor
      #E(g1)$color = input$ecolor
      #E(g1)$width = input$eLWD
      #cat("Aqui (1):",community$membership,"\n")
      preprocessing <- dataFiles$standard
      if(preprocessing == "asymmetric"){
        E(g1)$lty=1   
        if(!is.null(E(g1)$weigth)){
          E(g1)[ weight == 1 ]$lty = 2 ## dashed lines for moLeg with values of 1
          E(g1)[ weight == 1 ]$color = "black"
          E(g1)[ weight > 1 ]$color = "black"
          E(g1)[ weight == 1 ]$width = 1
          E(g1)[ weight > 1 ]$width = 1
          
        }
      }
      V(g1)$frame.color = rep("black", length(V(g1)))
      #sapply(unique(membership(community)), function(g) {
      #  subg1<-induced.subgraph(g1, which(membership(community)==g)) #membership id differs for each cluster
      #  ecount(subg1)/ecount(g1)
      #})
      
      #cs <- data.frame(combn(unique(membership(community)),2))
      #cx <- sapply(cs, function(x) {
      #  es<-E(g1)[V(g1)[membership(community)==x[1]] %--% 
      #              V(g1)[membership(community)==x[2]]]    
      #  length(es)
      #})
      #cbind(t(cs),cx)
      
      plot(community, g1, layout = layout_with_fr)
      title(main = paste0(" Static Network", text," (",sample_name,")"), 
            cex.main = 2)
      title(sub = "Developed by Leandro Correa",
            cex.sub=0.8,col.sub="grey")
      
    }, height= 700 )
    
    #-# Plots section
    # Plotting with visNetwork R package
    output$network <- renderVisNetwork({
      
      g <- g1
      
      V(g)$shape = rep("dot",length(V(g1)))
      if(length(dataFiles$orphans) > 0){
        for(i in 1:length(dataFiles$orphans)){ V(g)[V(g)$name==dataFiles$orphans[i]]$shape <- "square" }
      }
      
      V(g)$label.cex <- 1
      V(g)$size <- 40
      E(g)$arrows <- 'to;from'
      E(g)$color <- "silver"
      data <- toVisNetworkData(g)
      nodes <- data[[1]]
      edges <- data[[2]]
      
      
      visNetwork(nodes, edges,
                 main = paste0("Interactive Network", text," (",sample_name,")")) %>%
        visOptions(selectedBy = "color", 
                   highlightNearest = list(enabled = TRUE, degree = 1,
                                           hover = FALSE)) %>%
        visIgraphLayout()
      
    })
    
    #-# Result section
    # Result of each community identified in the network
    output$intraTable <- DT::renderDataTable({
      
      color <- input$comm
      table_intraMetrics <- metrics_groups[[color]]
 
      if(class(table_intraMetrics) == "character"){
        if(table_intraMetrics[1] == "not metric"){
          m_empty <- matrix(data = "",ncol = 2,nrow = 2)
          m_empty <- as.data.frame(m_empty)
          colnames(m_empty) <- c(table_intraMetrics[1],table_intraMetrics[2])
          table_intraMetrics <- m_empty
        }
      }else{
        table_intraMetrics <- as.data.frame(table_intraMetrics)
        colnames(table_intraMetrics) <- c("Metrics","Values")
        table_intraMetrics <- table_intraMetrics[-1,]
        
      }
      
      DT::datatable(
        table_intraMetrics,
        rownames = NULL,
        class = 'cell-border stripe',
        colnames = colnames(table_intraMetrics),
        extensions = "Buttons",
        options = list(
          searching = FALSE, paging = FALSE,
          scrollX = TRUE, scrollY = 500,
          #columnDefs = list(list(visible = FALSE, targets = metaColsHideIdx())),
          #dom = 'C<"clear">Blftp',
          scrollCollapse = TRUE,
          buttons = I('colvis')
        ))
      
    })
    
    dataFiles$graph_copy <- dataFiles$graph
    dataFiles$graph <- g1
    
    if(is.null(dataFiles$nclusters)) { communities <- "white"}
    else{ communities <- dataFiles$nclusters }
    updateSelectInput(session = session, inputId = "selgroup", choices = communities, selected = new_group)

    updateTabsetPanel(session, "plotParamsTabs", "Dendogram")
    
  })
  
  #-# Result section 
  # Downloadable csv of selected dataset ----
  output$downloadBtn <- downloadHandler(
    filename = function() {
      paste(dataFiles$sample_name, ".xlsx", sep = "")
    },
    content = function(file) {
      if(input$method == "Pvclust Analysis"){
        Groups <- dataFiles$color.pv
      }
      else{
        g1 <- dataFiles$graph
        Groups <- V(g1)$color
      }
      table_metrics <- cbind(Groups, dataFiles$table_metrics)
      
      name_color <- names(dataFiles$metrics_groups);color <- NULL; metrics_groups <- NULL
      for(i in 1:length(dataFiles$metrics_groups)){
        temp <- dataFiles$metrics_groups[[i]]
        temp <- matrix(temp,nrow = length(temp)/2,ncol = 2)
        metrics_groups <- cbind(metrics_groups, temp[,2])
        color[i] <- name_color[i]
      }
      colnames(metrics_groups) <- color
      row_metrics <- temp[,1]
      rownames(metrics_groups) <- row_metrics
      
      colnames(dataFiles$settings) <- c("  ")
      
      list_of_datasets <- list("Input" = dataFiles$input_data, 
                               "Settings" = dataFiles$settings,
                               "Table metrics" = table_metrics,
                               "Intra-Communities" = metrics_groups)
      write.xlsx(list_of_datasets, file, row.names = TRUE)
    }
  ) 
  
  hide("loadingContent")
  show("allContent")
})