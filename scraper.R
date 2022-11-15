rm(list = ls())

library(tidyverse)
library(RSelenium)


chromeDr <- rsDriver(browser = "chrome", port = 4567L, chromever = "106.0.5249.61", # you will have to adjust this version
                     extraCapabilities = list(chromeOptions = list(args = c('--disable-gpu', '--window-size=1920,1080', '--headless'),
                                                                   prefs = list(
                                                                     "profile.default_content_settings.popups" = 0L,
                                                                     "download.prompt_for_download" = FALSE,
                                                                     "directory_upgrade" = TRUE
                                                                   ))))

remDr <- chromeDr[["client"]]

# start
unibe_gym <- data.frame()

while(TRUE){
  remDr$navigate("https://www.unibe.ch/universitaet/campus__und__infrastruktur/universitaetssport/sportangebot/fitnessraeume/index_ger.html")
  Sys.sleep(5)
  
  e <- remDr$findElement(value = "//*/div[contains(@class, 'go-stop-display_footer')]")
  sign_color <- unlist(str_split(unlist(str_split(e$getElementAttribute("class"), " "))[4], "_"))[2]
  occupants <- as.numeric(unlist(str_split(unlist(e$getElementText()), " von "))[1])
  
  unibe_gym <- rbind(unibe_gym, data.frame("timestamp" = Sys.time(),
                                           "sign_color" = sign_color,
                                           "occupants" = occupants))
  
  print(paste0("Successful snapshot at ", Sys.time()))
  
  save(unibe_gym, file = "unibe_gym.RData")
  Sys.sleep(294)
}

save(unibe_gym, file = "unibe_gym.RData")

# Close connection
remDr$close()
chromeDr[["server"]]$stop()
