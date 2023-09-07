Config = {}

Config.UseTarget = GetConvar('UseTarget', 'false') == 'true'

Config.PedModel = 's_m_y_airworker' -- NPC model

Config.Zones = {
    ['bennys'] = {  -- job name
        plate = "BENNY",    -- Custom Plate Letter
        blip = {
            scale = 0.8,
            sprite = 50,
            color = 3,
        },
        vehicles = {
            {name = 'flatbed', label = '平板車'--[[, livery = 0, extras = {}]]}
        },
        garages = {
            {
                icon = 'fas fa-truck-pickup',
                label = '平板拖車',
                pedPos = vec4(-331.81, -115.23, 38.01, 161.88),
                spawnPos = vector4(-340.2, -114.91, 39.1, 70.12),
                blip = false,   -- show blip
            }
        }
    }
}

if not IsDuplicityVersion() then
    function SetFuel(veh, fuel)
        exports['LegacyFuel']:SetFuel(veh, fuel)
        --exports['cdn-fuel']:SetFuel(veh, fuel)
    end
end