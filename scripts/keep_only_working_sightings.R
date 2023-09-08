# Aim: Keep only sightings where vessels were observed working or where gear was deployed

vessel_sightings_dd_pts_sf <- vessel_sightings_dd_pts_sf %>% dplyr::filter(Working == "Y")
