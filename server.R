#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)
library(htmltools)

github_url <- a("GitHub Repo", href="https://github.com/db-bangs/Belle-Park-BioBlitz")
belle_park_url <- a("Belle Park Project", href="https://belleparkproject.com/events/bioblitz")


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



plotMap <- function(taxon_name = NULL,
                    dates = NULL){
    
    sf <- sf[sf$iconic_taxon_name %in% taxon_name,]
    sf <- sf[sf$observed_on >= min(dates) & sf$observed_on <= max(dates),]
    
    leaflet(sf) %>% 
        addTiles() %>% 
        # Code to keep map at current bounds with new input.
        #fitBounds(-76.46537339327705, 44.24732617607908, -76.4834351150543, 44.25501623280483) %>%
        addCircleMarkers(data = sf,
                         lng = ~longitude, lat = ~latitude,
                         popup = paste0("<p><b>", sf$common_name, "</b><br/>",
                                        "<i>", sf$scientific_name, "</i><br/>",
                                        "<i>", sf$iconic_taxon_name, "</i></p>",
                                        "<p>Observed: ", sf$observed_on, "<br/>",
                                        "User: ", sf$user_login, "<br/>",
                                        "Licence: ", sf$license, "</p",
                                        "<p><img src='", sf$image_url, "' style='width:100%;'/></p>"),
                         color = ~pal(iconic_taxon_name),
                         radius = 5)
}

shinyServer(function(input, output){
    
    
    output$map <- renderLeaflet({
        leaflet(sf) %>% addTiles()
        plotMap(input$taxon_name,
                input$dates)
    })
    
    output$table <- renderDataTable(sf_table)
    
    output$belle_park <- renderUI({
      tagList("Belle Park Project:", belle_park_url)
    
    })
    
    output$github <- renderUI({
      tagList("GitHub Repo:", github_url)
    
    })
}
)
