# Function that builds out side panel
# Keaton Wilson
# keatonwilson@me.com
# 2021-06-02

# Packages
require(shiny)
require(bslib)
require(shinydashboard)
require(shinydashboardPlus)
require(shinythemes)
require(shinyWidgets)
require(leaflet)
require(leaflethex)
require(shinycssloaders)

# Function

build_side_panel = function() {
  sidebarPanel(width = 3,
               fluidRow(
                 column(width = 12,
                        h4("Instructions"), 
                        HTML("<p><strong>Step 1:</strong> Select a location from the selection map<br>
                                                    <br>
                                                    <strong>Step 2:</strong> Select a depth for particle release<br>
                                                    <br>
                                                    <strong>Step 3:</strong> Select what time of year particles are released<br>
                                                    <br>
                                                    <strong>Step 4:</strong> Select how long particles stay in the water column<br>
                                                    <br>
                                                    <strong>Step 5:</strong> Once selections are complete, 
                                                    move to the simulation and density map tabs to view outputs<br>
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
                        HTML("<a href = 'https://twitter.com/ecostructure_'><i class = 'fa fa-twitter-square fa-3x'></i></a>"),
                        HTML("<a href = 'https://www.facebook.com/ecostructureproject'><i class = 'fa fa-facebook-square fa-3x'></i></a>"),
                        HTML("<a href = 'https://www.linkedin.com/company/64623160'><i class = 'fa fa-linkedin-square fa-3x'></i></a>"),
                        HTML("<a href = 'https://www.youtube.com/channel/UCCFH19O7-CjQxMjnzXdh4pg'><i class = 'fa fa-youtube-square fa-3x'></i></a>"),
                        hr(),
                        h4("Funding"),
                        img(src = "image001.png", 
                            width = "100%", 
                            height = "auto",
                            style = "margin-right: auto; margin-left: auto;")
                 )
               )
  )
}