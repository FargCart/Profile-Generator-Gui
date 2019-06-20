# Author: Leandro Corrêa ~@hscleandro
# Date: March 05 2018

library(shiny)
library(shinyjs)
#library(shinyalert)
source("helpers.R")


fluidPage(
  useShinyjs(),
  # add custom JS and CSS
  singleton(
    tags$head(includeScript(file.path('www', 'message-handler.js')),
              includeScript(file.path('www', 'helper-script.js')),
              includeCSS(file.path('www', 'style.css'))
    )
    
  ),
  
  # enclose the header in its own section to style it nicer
  div(id = "headerSection",
      titlePanel("Brooks Project - R Programming on Network PLots"),
      
      # author info
      span(
        span("Created by "),
        a("Leandro Corrêa", href = "https://hscleandro.wixsite.com/professional")
      )
  ),
  
  # show a loading message initially
  div(
    id = "loadingContent",
    h2("Loading...")
  ),	
  
  # all content goes here, and is hidden initially until the page fully loads
  hidden(div(id = "allContent",
        
   sidebarLayout(
# ============================Left_panel======================================
     sidebarPanel(
      
       strong(span("Input data:")),
       div(id = "div_upload",
           fileInput(
             "uploadFile", 
             label = "",
             multiple = FALSE,
             accept = c(
               '.csv',
               '.xlsx'
             )
           )#,downloadLink("exampleDataFile", "Example data file")
           ),
       
       strong(span("Standardization method:")),
       radioButtons(inputId = "query",
                    label = "",
                    choices = c("not standarlization" = "nstd",
                                "scale"               = "scale",
                                "asymmetric matrix"   = "asymmetric",
                                "min-max"             = "minmax"),
                    inline = FALSE),
       conditionalPanel(
         condition = "input.query == 'minmax'",
         strong(span("Set the range:")),
         bootstrapPage(
           div(style="display:inline-block", span("Min:")),
           div(style="display:inline-block", textInput("min", "", "", width = "50px")),
           div(style="display:inline-block", span("Max:")),
           div(style="display:inline-block", textInput("max", "", "", width = "50px"))
         )
       ),
  
       withBusyIndicator(
         actionButton(
           "loadFileBtn",
           "Upload data",
           class = "btn-primary"
         )
       ),
       br(),br(),br(),br(),
       strong(span("Network metrics:")),
       HTML("<br><br>"),
       shinyjs::useShinyjs(),
       wellPanel(
         shiny::tags$head(shiny::tags$style(shiny::HTML(
           "#text {id: text; font-size: 14px; height: 170px; overflow: auto; margin-left: -14px;}"
         )),
         shiny::tags$script(src = 'URL.js')),
         
         div(id = "text")
       ),
       verbatimTextOutput("rtime")
     ),
# ============================Right_panel======================================     
     mainPanel(wellPanel(
       tabsetPanel(
         id = "resultsTab", type = "tabs",
         # ============================README======================================
         tabPanel(
           title = "README", 
           id    = "readme",
           includeMarkdown(file.path("text", "about.md")),
           br()
         ),
         # ============================INPUT======================================
         tabPanel(
           title = "Input", 
           id    = "input",
           br(),br(),
           DT::dataTableOutput("inputTable"),
           br()
         ),
         # ============================SETTINGS======================================
         tabPanel(
           title = "Settings", 
           id    = "settings",
           br(),
           div(id="div_control_settings",
           includeHTML("www/control_settings_button.html")),
           hidden(
             div(id="settings_div_clustering",
                 bootstrapPage(
                   div(style="display:inline-block", 
                       strong(span("Apply Clustering:")),
                       selectInput("appClust", 
                                   label = "",
                                   choices = c("Row", 
                                               "Collum"),
                                   #choices = "Both",
                                   width = '180px'
                       )
                   ),
                   div(id = "type_analysis", style="display:inline-block", 
                       strong(span("Type of analysis:")),
                       selectInput("method", 
                                   label = "",
                                   choices = c("Dynamic Tree cut", 
                                               "Dynamic Hybrid cut",
                                               "Pvclust Analysis",
                                               "NbClust analysis"),
                                   width = '180px'
                       )
                   )
                 ),
                 
                 br(), br(),
                 
                 bootstrapPage(
                   div(style="display:inline-block", 
                       strong(span("Distance Metric:")),
                       selectInput("distMetric", 
                                   label = "",
                                   #choices = c("Euclidean", 
                                   #            "Maximum", 
                                   #            "Manhatan",
                                   #            "Canberra",
                                   #            "Binary",
                                   #            "Minkowski"),
                                   #
                                   #
                                   choices = "euclidean",
                                   width = '180px'
                       )
                   ),
                   div(id = "link_algorithm", style="display:inline-block", 
                       strong(span("Linkage Algorithm:")),
                       selectInput("linkAlgo", 
                                   label = "",
                                   choices = c("ward.D2",
                                               "complete", 
                                               "single", 
                                               "average",
                                               "centroid",
                                               "median",
                                               "mcQuitty",
                                               "ward.D"),
                                   #choices = "ward.D2",
                                   width = '180px'
                       )
                   )
                 )
             )
           ),
           div(id="settings_div_networking",
               bootstrapPage(
                 div(id="community_algorithms_div", style="display:inline-block", 
                     strong(span("Community Algorithms:")),
                     selectInput("community_algorithms", 
                                 label = "",
                                 choices = c("edge.betweenness.community", 
                                             "fastgreedy.community",
                                             "walktrap.community",
                                             "spinglass.community",
                                             "leading.eigenvector.community",
                                             "label.propagation.community"
                                 ),
                                 
                                 #choices = "Both",
                                 width = '180px'
                     )
                 ),
                 div(id = "Graph_orientation", style="display:inline-block", 
                     strong(span("Graph orientation:")),
                     selectInput("orientation", 
                                 label = "",
                                 choices = c("directed", 
                                             "undirected"),
                                 width = '180px'
                     )
                 )
               ),
               
               br(), br(),
               
               bootstrapPage(
                 div(style="display:inline-block", 
                     strong(span("Weighted:")),
                     selectInput("weighted", 
                                 label = "",
                                 choices = c("TRUE",
                                             "FALSE"),
                                 width = '180px'
                     )
                 )
               )
           ),
           
           #========================Start_Choice_Metrics_=================================================
           br(),br(),br(),
           div(id = "net_div", style="display:inline-block", 
               
               column(6,
                      checkboxGroupInput("nmetrics", "Network metrics:",
                                         c("Number of cliques"             = "nmetrics_1",
                                           "Number of triangles"           = "nmetrics_2",
                                           "Squares clustering coefficient" = "nmetrics_3"), 
                                         
                                         #selected = c("nmetrics_1", "nmetrics_2", "nmetrics_3"),
                                         
                                         inline = FALSE),
                      
                      checkboxGroupInput("nvertexs", "Vertexs metrics:",
                                         c("Degree"                  = "nvertexs_1",
                                           "In-degree"               = "nvertexs_2",
                                           "Out-degree"              = "nvertexs_3",
                                           "Average neighbor degree" = "nvertexs_4",
                                           "Clustering coefficient"  = "nvertexs_5",
                                           "Degree centrality"       = "nvertexs_6",
                                           "In-degree centrality"    = "nvertexs_7",
                                           "Out-degree centrality"   = "nvertexs_8",
                                           "Betweenness centrality"  = "nvertexs_9",
                                           "Eigenvector centrality"  = "nvertexs_10",
                                           "Closeness vitality"      = "nvertexs_11",
                                           "Core number"             = "nvertexs_12",
                                           "Information centrality"  = "nvertexs_13",
                                           "Eccentricity"            = "nvertexs_14",
                                           "Closeness centrality"    = "nvertexs_15"),
                                         
                                         selected = c("nvertexs_1", "nvertexs_2", "nvertexs_3",
                                                       "nvertexs_4", "nvertexs_5", "nvertexs_6",
                                                       "nvertexs_7", "nvertexs_8", "nvertexs_9",
                                                       "nvertexs_10", "nvertexs_11", "nvertexs_12",
                                                       "nvertexs_13","nvertexs_14","nvertexs_15"),
                                         
                                         inline = FALSE)
               ),
               column(6,
                      checkboxGroupInput("nintracomm", "Intra-communities metrics:",
                                         c("Average shortest path length"            = "nintracomm_1",
                                           "Graph clique number"                     = "nintracomm_2",
                                           "radius"                                  = "nintracomm_3",
                                           "Density"                                 = "nintracomm_4",
                                           "Graph number of cliques"                 = "nintracomm_5",
                                           "Transitivity"                            = "nintracomm_6",
                                           "Average clustering coefficient"          = "nintracomm_7",
                                           "Degree assortativity coefficient"        = "nintracomm_8",
                                           "Compactness"                             = "nintracomm_9",
                                           "Degree pearson correlation coefficient"  = "nintracomm_10",
                                           "Number of connected components"          = "nintracomm_11",
                                           "Number of strongly connected components" = "nintracomm_12",
                                           "Number of weakly connected components"   = "nintracomm_13",
                                           "Number of attracting components"         = "nintracomm_14"), 
                                         
                                         selected = c("nintracomm_1", "nintracomm_3",
                                                       "nintracomm_4", "nintracomm_6",
                                                       "nintracomm_7", "nintracomm_8", "nintracomm_9",
                                                       "nintracomm_10", "nintracomm_11", "nintracomm_12",
                                                       "nintracomm_13", "nintracomm_14"),
                                         
                                         inline = FALSE)
                      
               )
           ),
           #========================End_Choice_Metrics_=================================================
            
           br(),br(),       
           withBusyIndicatorUI(
             actionButton(
               "runAnalysisBtn",
               "Run analysis",
               class = "btn-secondary"
             )
           )
           ,
           sidebarLayout(
              mainPanel(uiOutput("usertext")),        
              conditionalPanel(
                condition = "output.controlpopup", 
                wellPanel(style = "position: absolute; width: 30%; left: 35%; top: 40%; 
                          box-shadow: 10px 10px 15px grey;",
                          textInput("text", "Text Input:"),
                          actionButton("submit", "Submit"))
              )
           )
         ),
         # ============================PLOTS======================================
         tabPanel(
           title = "Plots", 
           id = "plots",
           conditionalPanel(
             condition = "output.openPlots",
             br(),
             div(id = "allPlots",
                 tabsetPanel(
                   id = "plotParamsTabs", type = "pills",  position = NULL,  
                   # ============================Dendogram======================================
                   tabPanel(
                     title = "Dendogram", 
                     id = "tableDend",
                     conditionalPanel(
                       condition = "output.controlr",
                       bootstrapPage(
                         div(style="display:inline-block", actionButton("subBestKBtn","Run")),
                         div(style="display:inline-block", textInput("caption", "", "Digit the best K value and press Run", width = "300px"))
                       ),
                       br()
                     ),
                     
                     plotOutput("plot_dendo", height = "100%"),
                     #imageOutput("plot_dendo"),
                     br(),
                     bootstrapPage(
                       div(style="display:inline-block", span("height:")),
                       div(style="display:inline-block", numericInput("height_dendo", "", min=5, max=300, step=1, value = 15, width = "100px")),
                       div(style="display:inline-block", span("width:")),
                       div(style="display:inline-block", numericInput("width_dendo", "", min=5, max=1000, step=1, value = 21, width = "100px")),
                       div(style="display:inline-block", div(style="display:inline-block", 
                                                             withBusyIndicatorUI(
                                                               downloadButton("downloadBtn_dend", 
                                                                              "Download", 
                                                                              class = "btn-secondary")
                                                             ))
                       )
                     ),
                    
                     br()
                    ),
                   # ============================Static_Network======================================
                   tabPanel(
                     title = "Static Network", id = "tableStatic",
                     plotOutput('graph_static', height = 700),
                     br()
                   ),
                   # ============================Interactive_Network======================================
                   tabPanel(
                     title = "Interactive network", id = "about",
                     br(),
                     visNetworkOutput("network",height = 700)
                   ),
                   # ============================Community_settings======================================
                   tabPanel(
                     title = "Community settings", id = "groups_c",
                     br(),
                     div(id = "group_div", style="display:inline-block", 
                         
                         column(6,
                                
                                strong(span("Select the target group:")),
                                # 
                                uiOutput("selectGroups"),
                                colourInput("colgroups", "", ""),
                                
                                strong(span("Select the fields you want to change:")),
                                #tags$head(
                                #  tags$style(HTML(".cell-border-right{border-right: 1px solid #000}"))),
                                DT::dataTableOutput('dataTableGroups', width = "87%")
                                
                         ),
                         column(6,
                                
                                strong(span("Select the new group:")),
                                #
                                uiOutput("changegroup"),
                                colourInput("colChangegroups", "", ""),
                                withBusyIndicator(
                                  actionButton(
                                    "loadGroupsBtn",
                                    "Change it"
                                  )
                                )
                         )
                     )
                     
                   )
                 )
             )
            )
           ),
         # ============================RESULTS======================================
         tabPanel(
           title = "Result", 
           id    = "result",
           conditionalPanel(
             condition = "output.openPlots",
             br(),
             div(id = "allResults",
                 tabsetPanel(
                   id = "resultParamsTabs", type = "pills",  position = NULL,
                   # ============================Metrics======================================
                   tabPanel(
                     title = "Metrics", id = "tableMetrics",
                     br(),
                     DT::dataTableOutput("resultTable"),
                     br()
                   ),
                   # ============================Asymmetries======================================
                   tabPanel(
                     title = "Asymmetries", id = "Asymt",
                     br(),
                     DT::dataTableOutput("asymetriesTable"),
                     br()
                   ),
                   # ============================Intra-community======================================
                   tabPanel(
                     title = "Intra-Communities", id = "intrC",
                     #strong(span("Select the community:")),
                     uiOutput("selectCommunity"),
                     colourInput("col", "Select colour", "white"),
                     br(),br(),
                     DT::dataTableOutput("intraTable"),
                     br(),
                     verbatimTextOutput("vertex_groups")
                   ),
                   tabPanel(
                     title = "Download", id = "downIt",
                     br(),br(),       
                     withBusyIndicatorUI(
                       downloadButton("downloadBtn", 
                                      "Download", 
                                      class = "btn-secondary")
                     )
                     #strong(span("Select the community:")),
                     #uiOutput("selectCommunity"),
                     #colourInput("col", "Select colour", "white"),
                     #br(),br(),
                     #DT::dataTableOutput("intraTable"),
                     #br(),
                     #verbatimTextOutput("vertex_groups")
                   )
                 )
             )
         ) )
       )
     ))
# ============================End_Right_panel====================================== 
   )
  ))
)
