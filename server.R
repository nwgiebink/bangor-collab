# Server
# Keaton Wilson & Noah Giebink
# keatonwilson@me.com
# nwgiebink@gmail.com
# 2021-02-02

library(shiny)
library(leaflet)


# Sourcing Scripts --------------------------------------------------------
source("./scripts/make_selection_map.R")
source("./scripts/make_simulation_map.R")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {


# Map Panel to Make Location Selection ------------------------------------
output$selection_map = renderLeaflet({
  make_selection_map()
})


# Map Panel to View Simulation --------------------------------------------

output$simulation_map = renderLeaflet({
  make_simulation_map()
})

})
