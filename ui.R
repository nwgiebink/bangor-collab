# UI
# Keaton Wilson & Noah Giebink
# keatonwilson@me.com
# 2021-02-02


# packages ----------------------------------------------------------------

library(shiny)
library(bslib)
library(shinydashboard)
library(shinydashboardPlus)
library(shinythemes)
library(shinyWidgets)


# Shiny UI ---------------------------------------------------------------
# Define UI for application that draws a histogram
shinyUI(
    fluidPage(
      # Linking to custom css sheet
      tags$head(
        tags$link(rel = "stylesheet", type = "text/css", href = "styling.css")
      ),
        theme = bs_theme(bootswatch = 'spacelab'),
        navbarPage(title = "Ecostructure Larval Dispersal",
                   id = "navbar", 
                   header = tagList(
                     useShinydashboard()
                   ), 
                   windowTitle = "App Name",
                   

# Front Mapping Panel -----------------------------------------------------

                   tabPanel("Location & Parameter Selection", 
                            value = "tab1", 
                            fluid = TRUE, 
                            sidebarLayout(
                              sidebarPanel(width = 3,
                                           fluidRow(
                                             column(width = 12,
                                                    h4("Instructions"), 
                                                    HTML("<p><strong>Step 1:</strong> Select a Location from the Map<br>
                                                    <br>
                                                    <strong>Step 2:</strong> Select a depth for particle release<br>
                                                    <br>
                                                    <strong>Step 3:</strong> Select when particles are released<br>
                                                    <br>
                                                    <strong>Step 4:</strong> Select how long particles stay in the water<br>
                                                    <br>
                                                    <strong>Step 5:</strong> Once selections are complete, move to the simulation tab<br>
                                                         ")
                                             )
                                           ), 
                                           hr(), 
                                           fluidRow(
                                             column(width = 12,
                                                    h4("Contact Information"),
                                                    p("Dr. Peter Robins"),
                                                    HTML("<i class = 'fas fa-envelope'></i> <a href = 'p.robins@bangor.ac.uk'>p.robins@bangor.ac.uk</a>")
                                             )
                                           ), 
                                           hr(), 
                                           fluidRow(
                                             column(width = 12,
                                                    # style = "margin: 0px; padding: 0px; border: 0px",
                                                    h4("Overview"),
                                                    p(a("ECOSTRUCTURE", 
                                                        href = "http://http://www.ecostructureproject.eu/", 
                                                        target="_blank"), 
                                                      "will raise awareness of eco-engineering solutions to 
                                                       the challenge of climate change. We aim to provide developers 
                                                       and regulators with accessible tools and resources, based on 
                                                       research in the fields of ecology, engineering and socioeconomics."),
                                                    br(),
                                                    h4("Disclaimer"),
                                                    p("Ecostructure brings together five leading universities 
                                                     in Wales and Ireland to research and raise awareness of 
                                                     eco-engineering solutions to the challenge of coastal 
                                                     adaptation to climate change. Ecostructure aims to 
                                                     promote the incorporation of secondary ecological 
                                                     and societal benefits into coastal defence and 
                                                     renewable energy structures, with benefits to the 
                                                     environment, to coastal communities, and to the 
                                                     blue and green sectors of the Irish and Welsh economies."),
                                                    hr(),
                                                    h4("Connect"),
                                                    HTML("<a href = 'https://twitter.com/ecostructure_'><i class = 'fa fa-twitter fa-3x'></i></a>"),
                                                    HTML("<a href = 'https://www.facebook.com/ecostructureproject'><i class = 'fa fa-facebook fa-3x'></i></a>"),
                                                    HTML("<a href = 'https://www.linkedin.com/company/64623160'><i class = 'fa fa-linkedin fa-3x'></i></a>"),
                                                    HTML("<a href = 'https://www.youtube.com/channel/UCCFH19O7-CjQxMjnzXdh4pg'><i class = 'fa fa-youtube fa-3x'></i></a>"),
                                                    hr(),
                                                    h4("Funding"),
                                                    img(src = "image001.png", 
                                                        width = 100, 
                                                        height = 80,
                                                        style = "margin-right: auto; margin-left: auto;")
                                             )
                                           )
                              ), 
                              mainPanel(width = 9,
                                fluidRow(
                                    column(width = 8,
                                           style = "padding: 5px;",
                                              box(title = "Select a Location",
                                                  width = NULL,
                                                  status = "primary",
                                                  solidHeader = FALSE,
                                                  id = "location_box",
                                                  leafletOutput("selection_map", height = 700)
                                           )
                                           ), 
                                    column(width = 4,
                                           style = "padding: 5px;",
                                           box(title = "Select Simulation Parameters",
                                               width = NULL,
                                               style = "width: 100%;",
                                             selectInput("depth", 
                                                         label = "Choose a Depth:", 
                                                         choices = c("Surface", "Deep"), 
                                                         multiple = FALSE)
                                             )
                                           )
                                )
                                )
                                           
                            )
                       
                   ),

# Simulation Panel --------------------------------------------------------
tabPanel("Simulation", 
         value = "tab2", 
         fluid = TRUE, 
         sidebarLayout(
           sidebarPanel(width = 3,
                        fluidRow(
                          column(width = 12,
                                 h4("Instructions"), 
                                 HTML("<p><strong>Step 1:</strong> Select a Location from the Map<br>
                                                    <br>
                                                    <strong>Step 2:</strong> Select a depth for particle release<br>
                                                    <br>
                                                    <strong>Step 3:</strong> Select when particles are released<br>
                                                    <br>
                                                    <strong>Step 4:</strong> Select how long particles stay in the water<br>
                                                    <br>
                                                    <strong>Step 5:</strong> Once selections are complete, move to the simulation tab<br>
                                                         ")
                          )
                        ), 
                        hr(), 
                        fluidRow(
                          column(width = 12,
                                 h4("Contact Information"),
                                 p("Dr. Peter Robins"),
                                 HTML("<i class = 'fas fa-envelope'></i> <a href = 'p.robins@bangor.ac.uk'>p.robins@bangor.ac.uk</a>")
                          )
                        ), 
                        hr(), 
                        fluidRow(
                          column(width = 12,
                                 # style = "margin: 0px; padding: 0px; border: 0px",
                                 h4("Overview"),
                                 p(a("ECOSTRUCTURE", 
                                     href = "http://http://www.ecostructureproject.eu/", 
                                     target="_blank"), 
                                   "will raise awareness of eco-engineering solutions to 
                                                       the challenge of climate change. We aim to provide developers 
                                                       and regulators with accessible tools and resources, based on 
                                                       research in the fields of ecology, engineering and socioeconomics."),
                                 br(),
                                 h4("Disclaimer"),
                                 p("Ecostructure brings together five leading universities 
                                                     in Wales and Ireland to research and raise awareness of 
                                                     eco-engineering solutions to the challenge of coastal 
                                                     adaptation to climate change. Ecostructure aims to 
                                                     promote the incorporation of secondary ecological 
                                                     and societal benefits into coastal defence and 
                                                     renewable energy structures, with benefits to the 
                                                     environment, to coastal communities, and to the 
                                                     blue and green sectors of the Irish and Welsh economies."),
                                 hr(),
                                 h4("Connect"),
                                 HTML("<a href = 'https://twitter.com/ecostructure_'><i class = 'fa fa-twitter fa-3x'></i></a>"),
                                 HTML("<a href = 'https://www.facebook.com/ecostructureproject'><i class = 'fa fa-facebook fa-3x'></i></a>"),
                                 HTML("<a href = 'https://www.linkedin.com/company/64623160'><i class = 'fa fa-linkedin fa-3x'></i></a>"),
                                 HTML("<a href = 'https://www.youtube.com/channel/UCCFH19O7-CjQxMjnzXdh4pg'><i class = 'fa fa-youtube fa-3x'></i></a>"),
                                 hr(),
                                 h4("Funding"),
                                 img(src = "image001.png", 
                                     width = 100, 
                                     height = 80,
                                     style = "margin-right: auto; margin-left: auto;")
                          )
                        )
           ), 
           mainPanel(
             width = 9,
               fluidRow(
                  leafletOutput("simulation_map", height = 850) 
               )
           )
         )
         
)
                   )
    )
)
