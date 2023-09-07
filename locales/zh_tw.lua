local Translations = {
    error = {
        not_society_vehicle = '非公司車輛',
        no_vehicle_nearby = '附近無車輛',
        not_empty_pos = "無可用車位",
    },
    label = {
        garage = "公司車庫",
    },
    header = {
        get_vehicles = '領取車輛',
        put_vehicle = '停放車輛',
    },
    desc = {
        get_vehicles_des = "將車輛從公司車庫駛出",
        put_vehicle_des = "將車輛停入公司車庫",
    }
}

if GetConvar("qb_locale", "en") == 'zh_tw' then
    Lang = Lang or Locale:new({
        phrases = Translations,
        warnOnMissing = true
    })
end