local Translations = {
    error = {
        not_society_vehicle = 'Not society vehicle',
        no_vehicle_nearby = 'No vehicle nearby',
        not_empty_pos = "No empty parking space",
    },
    label = {
        garage = "Garage",
    },
    header = {
        get_vehicles = 'Get job vehicle',
        put_vehicle = 'Store the vehicle',
    },
    desc = {
        get_vehicles_des = "Drive the vehicle out of the parking lot",
        put_vehicle_des = "Park the vehicle in the parking lot",
    }
}

if GetConvar("qb_locale", "en") == 'en' then
    Lang = Lang or Locale:new({
        phrases = Translations,
        warnOnMissing = true
    })
end