# UI
# Keaton Wilson & Noah Giebink
# keatonwilson@me.com
# nwgiebink@gmail.com
# 2021-02-02


# packages ----------------------------------------------------------------

library(shiny)
library(bslib)
library(shinydashboard)
library(shinydashboardPlus)
library(shinythemes)
library(shinyWidgets)
library(leaflet)
library(leaflethex)
library(shinycssloaders)

# Sourcing Sidepanel Function----------------------------------------------
source("./scripts/build_side_panel.R")

# Shiny UI ---------------------------------------------------------------
# Define UI for application that draws a histogram
shinyUI(
    fluidPage(
      # Linking to custom css sheet
      tags$head(
        tags$link(rel = "stylesheet", type = "text/css", href = "styling.css"),
        tags$style(".fa-facebook-square {color:#3B5998}",
                   ".fa-twitter-square {color:#55ACEE}",
                   ".fa-linkedin-square {color:#0e76a8}",
                   ".fa-youtube-square {color:#FF0000}"),
        tags$style(
          type="text/css",
          "#image img {max-width: 100%; width: 100%; height: auto}"
        )
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
                              build_side_panel(), 
                              mainPanel(width = 9,
                                fluidRow(
                                    column(width = 8,
                                           style = "padding: 5px;",
                                              box(title = "Selection map: select a site",
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
                                                         choices = c("Surface", "Mid-water Depth"), 
                                                         multiple = FALSE),
                                             selectInput("season",
                                                         label = "Choose a Season:",
                                                         choices = c("Spring", "Summer", "Autumn"),
                                                         multiple = FALSE), 
                                             sliderInput("window", 
                                                         label = "Choose a duration in water column (days):", 
                                                         min = 10, 
                                                         max = 40, 
                                                         value = 20, 
                                                         step = 1
                                                         ),
                                             actionButton("load_data", "Load Data")
                                             )
                                           )
                                ), 
                                fluidRow(verbatimTextOutput("Click_text"))
                                )
                                           
                            )
                       
                   ),

# Simulation Panel --------------------------------------------------------
tabPanel("Simulation", 
         value = "tab2", 
         fluid = TRUE, 
         sidebarLayout(
           build_side_panel(), 
           mainPanel(
             width = 9,
               fluidRow(
                       uiOutput("date_selector")
               ),
               fluidRow(
                  leafletOutput("simulation_map", height = 850)
               )
           )
         )
         
),
# Density Maps --------------------------------------------------------
tabPanel("Density Maps", 
         value = "tab3", 
         fluid = TRUE, 
         sidebarLayout(
           build_side_panel(), 
           mainPanel(
             width = 9,
             fluidRow(
               leafletOutput("density_map", height = 850) 
             )
           )
         )
         
),
# Resources and Documentation --------------------------------------------------------
tabPanel("Resources", 
         value = "tab4", 
         fluid = TRUE, 
         sidebarLayout(
           build_side_panel(), 
           mainPanel(
             width = 9,
             h2("Description"), 
             p("This visualisation app is a prototype intended for early warning 
               and rapid response to marine invasive species in the Irish Sea. 
               The app has been developed within Ecostructure, an interdisciplinary 
               project which aims to raise awareness of, and provide guidance to, 
               developers and regulators on the potential for ecologically sensitive 
               engineering (eco-engineering) solutions for coastal infrastructure. 
               Ecostructure is a collaboration between five leading research-intensive 
               universities in Wales and Ireland: Aberystwyth University (Project Lead), 
               Bangor University, Swansea University, University College Cork and 
               University College Dublin. The project is part-funded by the 
               European Regional Development Fund (ERDF) through the Ireland-Wales 
               Cooperation Programme 2014-2020."), 
             br(), 
             p("The app simulates the potential spread of larvae from coastal 
               natural habitats and man-made structures. The larvae (‘particles’) 
               simulated within this app are transported from coastal ‘spawning’ 
               locations within the Irish Sea by simulated (modelled) ocean currents. 
               These simulations are based on a sophisticated hydrodynamic model 
               which predicts flows in three-dimensions, driven by the tide, 
               wind and heat inputs. The model uses data from 2014 and encompasses 
               the larval spawning season from April to October."), 
             br(), 
             p("The simulated ocean currents are coupled with a Particle Tracking 
               Model which ‘releases’ virtual particles (representing larvae) 
               from discrete locations at different times throughout the year. 
               These particles are then dispersed through the Irish Sea waters 
               according to the local simulated ocean currents. A range of 
               release (spawning) periods can be chosen to incorporate changes 
               in seasonal heat-driven flows. In addition, larvae particles 
               can be simulated in two scenarios: i) positioned in surface waters, 
               and ii) positioned in mid-waters. This represents two plausible 
               larval behavioural patterns, with surface-only larvae submitted 
               to tidal-, heat- and wind-driven currents, whereas larvae in 
               mid-waters are submitted to tidal- and heat-driven currents. ")
           )
         )
         
)

                   )
    )
)
