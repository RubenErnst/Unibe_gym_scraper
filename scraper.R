rm(list = ls())

library(tidyverse)
library(RSelenium)


chromeDr <- rsDriver(browser = "chrome", port = 4571L, chromever = "106.0.5249.61", # you will have to adjust this version
                     extraCapabilities = list(chromeOptions = list(args = c('--disable-gpu', '--window-size=1920,1080', '--headless'),
                                                                   prefs = list(
                                                                     "profile.default_content_settings.popups" = 0L,
                                                                     "download.prompt_for_download" = FALSE,
                                                                     "directory_upgrade" = TRUE
                                                                   ))))

remDr <- chromeDr[["client"]]

url <- "https://www.unibe.ch/universitaet/campus__und__infrastruktur/universitaetssport/sportangebot/fitnessraeume/index_ger.html"

# start
load(file = "unibe_gym.RData")
counter <- 0

while(TRUE){
  if (counter > 10){
    remDr$close()
    chromeDr[["server"]]$stop()
    
    chromeDr <- rsDriver(browser = "chrome", port = 4571L, chromever = "106.0.5249.61", # you will have to adjust this version
                         extraCapabilities = list(chromeOptions = list(args = c('--disable-gpu', '--window-size=1920,1080', '--headless'),
                                                                       prefs = list(
                                                                         "profile.default_content_settings.popups" = 0L,
                                                                         "download.prompt_for_download" = FALSE,
                                                                         "directory_upgrade" = TRUE
                                                                       ))))
    
    remDr <- chromeDr[["client"]]
    counter <- 0
  }
  
  error_occ <- TRUE
  tryCatch(
    expr = {
      suppressMessages({
        remDr$navigate(url)
        Sys.sleep(10)
        error_occ <- FALSE
      })
    },
    error = function(err){
      return(1)
    }
  )
  
  if (error_occ){
    remDr$close()
    chromeDr[["server"]]$stop()
    
    chromeDr <- rsDriver(browser = "chrome", port = 4571L, chromever = "106.0.5249.61", # you will have to adjust this version
                         extraCapabilities = list(chromeOptions = list(args = c('--disable-gpu', '--window-size=1920,1080', '--headless'),
                                                                       prefs = list(
                                                                         "profile.default_content_settings.popups" = 0L,
                                                                         "download.prompt_for_download" = FALSE,
                                                                         "directory_upgrade" = TRUE
                                                                       ))))
    
    remDr <- chromeDr[["client"]]
    counter <- 0
    
    tryCatch(
      expr = {
        suppressMessages({
          remDr$navigate(url)
          Sys.sleep(10)
        })
      },
      error = function(err){
        return(1)
      }
    )
  }
  
  sign_color <- NA
  occupants <- NA
  
  tryCatch(
    expr = {
      suppressMessages({
        e <- remDr$findElement(value = "//*/div[contains(@class, 'go-stop-display_footer')]")
        sign_color <- unlist(str_split(unlist(str_split(e$getElementAttribute("class"), " "))[4], "_"))[2]
        occupants <- as.numeric(unlist(str_split(unlist(e$getElementText()), " von "))[1])
      })
    },
    error = function(err){
      return(1)
    })
  
  unibe_gym <- rbind(unibe_gym, data.frame("timestamp" = Sys.time(),
                                           "sign_color" = sign_color,
                                           "occupants" = occupants))
  
  print(paste0("Took snapshot at ", Sys.time()))
  
  save(unibe_gym, file = "unibe_gym.RData")
  counter <- counter + 1
  Sys.sleep(289)
}

save(unibe_gym, file = "unibe_gym.RData")

# Close connection
remDr$close()
chromeDr[["server"]]$stop()
