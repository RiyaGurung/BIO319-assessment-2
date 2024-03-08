install.packages('tidyr')
install.packages('dplyr')

library(tidyr)
library(dplyr)

spotifydf <- read.table(file ='Spotify_Messy_210455733.txt', sep = '\t', header = TRUE)

spotifydf <- spotifydf %>%  pivot_longer(cols = c('pop','rap','r.b','edm','rock'), names_to = 'playlist_genre', values_to = 'playlist_subgenre') 
# the genre names were columns, so i used pivot longer to assign them under one column named       'playlist genre' and the subgenres were moved to another column called 'playlist subgenre'

spotifydf <- spotifydf %>% filter(!is.na(playlist_subgenre))
# the sub genre column had a lot of NAs and so filter was used to only include the rows without NAs
# although this removed a lot of rows, it was necessary due to the large number of repeats in our      data 

spotifydf <- spotifydf %>% rename(track_name = TTrack_nameff5) %>% separate_wider_delim(cols = danceability.energy, delim = '_', names = c('danceability', 'energy')) %>% relocate(playlist_genre, .after = playlist_id) %>% relocate(playlist_subgenre, .before = danceability)
# This whole code was to fix up the columns
# 1) the track name column needed to be renamed 
# 2) the danceability.energy column had to split up into 2 
# 3) i thought it would be easier to look at if the playlist genre and subgenre columns were next to      the other playlist columns

spotifydf <- spotifydf %>% mutate(track_artist = gsub('Bad Sunny', 'Bad Bunny', track_artist)) %>% mutate(playlist_genre = gsub('r.b', 'r&b',playlist_genre))
# The artist's name was wrong and I just wanted to fix r&b for my own satisfaction. 

spotifydf <- spotifydf %>% mutate('track_album_release_date' = gsub('75-', '2019-', track_album_release_date)) %>% mutate('mode' = as.numeric(gsub('[^0-1]','',mode))) 
# 1) the year for albums with 75 was incorrect
# 2) the mode column had random letters and so this was removed as well as changing its class to          numeric 

spotifydf <- spotifydf %>% mutate(danceability = as.numeric(danceability)) %>% mutate(energy = as.numeric(energy))
# the classes for danceability and energy were changed from characters to numerical so it is easier    to work with and they are not seen as strings

spotifydf <- spotifydf %>% mutate(valence = round(spotifydf$valence, digits = 3)) %>% mutate(liveness = round(spotifydf$valence, digits = 3)) %>% mutate(acousticness = round(spotifydf$acousticness, digits = 4))
# valence and liveness were rounded to 3 decimal points just for easier viewing, same with             acousticness to 4 decimal points to match the column next to it 

spotifydf <- spotifydf %>% mutate(instrumentalness = ifelse(instrumentalness > 1, NA, instrumentalness))
# instrumentalness had incorrect values that were larger than 1, so I used ifelse to make those NA,    while leaving the rest of the values alone

write.table(spotifydf, '210455733_Clean_data.txt', quote = FALSE, sep = '\t', col.names = TRUE, row.names = FALSE)

