## Belle Park BioBlitz server.R
##
## Server functions for the R Shiny dashboard
##
## Leaflet map filtered by iNaturalist 'iconic_taxon_name'
##  and day-of-week slider controls
## 
## inat_obs_df.rds created from separate iNaturalist API query
##  via package 'rinat'
## 
## Created by: Donovan Bangs
## Last Updated: 08 June 2022

## Initialize Libraries
library(shiny)
library(shinyWidgets)
library(leaflet)
library(htmltools)

## Set link URLs
github_url <- a("GitHub Repo", href="https://github.com/db-bangs/Belle-Park-BioBlitz", target = "_blank")
belle_park_url <- a("Belle Park Project", href="https://belleparkproject.com/events/bioblitz", target = "_blank")

## Load iNat data RDS
load("inat_obs_df.rds")
sf <- inat_obs_df

sf$observed_on <- as.Date(sf$observed_on)


sf_table <- subset(sf,
                   select = c(
                     observed_on,
                     common_name,
                     scientific_name,
                     iconic_taxon_name,
                     user_login,
                     url,
                     license
                   ))

## Colour Palette
pal <- colorFactor(
    palette = c("Blue", # Actinopterygii
                "Dark Green",  # Amphibia
                "Brown",       # Animalia
                "Black",       # Arachnida
                "deepskyblue3", #Aves
                "goldenrod3",      # Fungi
                "lightcoral",       # Insecta
                "Brown",       # Mammalia
                "darkorange4",       # Mollusca
                "forestgreen", # Plantae
                "Darkgoldenrod3", # Protozoa
                "darkturquoise",       # Reptilia
                "Gray"),       # Unidentified
    domain = sf$iconic_taxon_name)





shinyServer(function(input, output){
  
  ### Reactive Filtering ####
  filteredData <- reactive({
    sf[sf$iconic_taxon_name %in% input$taxon_name & 
         sf$observed_on >= min(input$dates) &
         sf$observed_on <= max(input$dates),]
  })
  
  ### Base Map ####
  output$belle.map <- renderLeaflet({
    leaflet(sf, options = leafletOptions(minZoom = 12)) %>%
      addTiles() %>%
      fitBounds(~min(longitude), ~min(latitude), ~max(longitude), ~max(latitude)) %>%
      setMaxBounds(lng1 = ~max(longitude) + 0.15,
                   lat1 = ~max(latitude) + 0.1,
                   lng2 = ~min(longitude) - 0.25,
                   lat2 = ~min(latitude) - 0.1)
  })
  
  outputOptions(output, "belle.map", suspendWhenHidden = FALSE)
  
  ### Observer Map ####
  observe({
    leafletProxy("belle.map") %>%
      clearMarkers() %>%
      addCircleMarkers(data = filteredData(),
                       lng = ~longitude, lat = ~latitude,
                       popup = paste0("<p><b>", filteredData()$common_name, "</b><br/>",
                                      "<i>", filteredData()$scientific_name, "</i><br/>",
                                      "<i>", filteredData()$iconic_taxon_name, "</i></p>",
                                      "<p>Observed: ", filteredData()$observed_on, "<br/>",
                                      "User: ", filteredData()$user_login, "<br/>",
                                      "Licence: ", filteredData()$license, "</p",
                                      "<p><img src='", filteredData()$image_url, "' style='width:100%;'/></p>"),
                       color = ~pal(filteredData()$iconic_taxon_name),
                       opacity = 1.0,
                       radius = 5) %>%
      clearControls() %>%
      addLegend(position = "bottomright",
                pal = pal,
                values = filteredData()$iconic_taxon_name)
  },
  suspended = FALSE)
  
  ### Data Table ####
  output$belle.table <- renderDataTable(
    filteredData() %>%
      dplyr::select(common_name,
                    scientific_name,
                    iconic_taxon_name,
                    observed_on,
                    user_login,
                    license) %>%
      datatable(rownames = FALSE,
                colnames = c("Common Name" = "common_name",
                             "Scientific Name" = "scientific_name",
                             "Taxon" = "iconic_taxon_name",
                             "Date" = "observed_on",
                             "Participant" = "user_login",
                             "License" = "license"),
                options = list(lengthMenu = c(10,25,50), pageLength = 25,
                               dom = 'fltp'))
    
  )
  
  output$belle_park <- renderUI({
    tagList("Belle Park Project:", belle_park_url)
    
  })
  
  ### GitHub Tag ####
  output$github <- renderUI({
    tagList("GitHub Repo:", github_url)
    
  })
}
)
