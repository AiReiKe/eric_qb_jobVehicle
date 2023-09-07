local curVersion = GetResourceMetadata(GetCurrentResourceName(), "version")
local resourceName = "eric_qb_jobVehicle"

local GetRepoInformations = function()
    local repoVersion, repoURL, repoBody = nil, nil, nil

    PerformHttpRequest("https://api.github.com/repos/AiReiKe/eric_qb_jobVehicle/releases/latest", function(err, response, headers)
        if err == 200 then
            local data = json.decode(response)

            repoVersion = data.tag_name
            repoURL = data.html_url
            repoBody = data.body
        else
            repoVersion = curVersion
            repoURL = "https://github.com/AiReiKe/eric_qb_jobVehicle"
        end
    end, "GET")

    repeat
        Wait(50)
    until (repoVersion and repoURL and repoBody)

    return repoVersion, repoURL, repoBody
end

local CheckVersion = function(err, responseText, headers)
    local repoVersion, repoURL, repoBody = GetRepoInformations()

    CreateThread(function()
        if curVersion ~= repoVersion then
            print("^0[^3WARNING^0] " .. resourceName .. " is ^1NOT ^0up to date!")
            print("^0[^3WARNING^0] Your Version: ^1" .. curVersion .. "^0")
            print("^0[^3WARNING^0] Latest Version: ^2" .. repoVersion .. "^0")
            print("^0[^3WARNING^0] Get the latest Version from: ^2" .. repoURL .. "^0")
        else
            print("^0[^2INFO^0] " .. resourceName .. " is up to date! (^2" .. curVersion .. "^0)")
        end
    end)
end

CreateThread(function()
    if GetCurrentResourceName() ~= "eric_qb_jobVehicle" then
        resourceName = "eric_qb_jobVehicle (" .. GetCurrentResourceName() .. ")"
    end
    PerformHttpRequest("https://api.github.com/repos/AiReiKe/eric_qb_jobVehicle/releases/latest", CheckVersion, "GET")
end)