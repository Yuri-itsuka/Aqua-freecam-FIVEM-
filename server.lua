ESX = exports["es_extended"]:getSharedObject()

local allowedGroups = {
    admin = true,
    superadmin = true,
    mod = true
}

RegisterServerEvent("freecam:checkPermission")
AddEventHandler("freecam:checkPermission", function()

    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then
        return
    end

    local group = xPlayer.getGroup()

    if allowedGroups[group] then
        TriggerClientEvent("freecam:toggle", src, true)
    else
        TriggerClientEvent("freecam:toggle", src, false)
    end
end)
