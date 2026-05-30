local freecam = false
local cam = nil

local speed = 1.5
local minSpeed = 0.5
local maxSpeed = 10.0

local filters = {
    "default",

    -- Cinematic
    "NG_filmic01",
    "cinema",
    "cinema_001",
    "yell_tunnel_nodirect",
    "MP_corona_switch",

    -- Schwarz Weiß
    "CAMERA_BW",
    "Barry1_Stoned",
    "BarryFadeOut",

    -- VHS / Kamera
    "heliGunCam",
    "scanline_cam_cheap",
    "CAMERA_secuirity",
    "eyeINtheSky",

    -- Farben
    "RaceTurbo",
    "rply_saturation",
    "rply_contrast_neg",
    "rply_vignette",

    -- Drogen / Crazy
    "drug_drive_blend01",
    "Drunk",
    "spectator5",
    "spectator6",
    "Dont_tazeme_bro",

    -- Dunkel / Horror
    "Noir",
    "BlackOut",
    "NG_blackout",

    -- Helligkeit / Bloom
    "Bloom",
    "BloomLight",
    "Tunnel",
    "tunnel",

    -- Wärme / Orange
    "mp_lad_day",
    "Salton",
    "New_sewers",

    -- Kalt / Blau
    "underwater",
    "int_hospital2_dm",
    "CS1_railwayB_tunnel",

    -- Scharf / Klar
    "MP_Powerplay_blend",
    "michealspliff",
    "FocusIn",

    -- Random Fun
    "ExplosionJosh3",
    "Sniper",
    "REDMIST",
    "Glasses_BlackOut",
    "MenuMGHeistIn",
    "MenuMGSelectionIn"
}

local currentFilter = 1

RegisterNetEvent('freecam:toggle')
AddEventHandler('freecam:toggle', function(hasPermission)

    if not hasPermission then
        TriggerEvent('chat:addMessage', {
            args = { '^1SYSTEM', 'Keine Berechtigung.' }
        })
        return
    end

    freecam = not freecam

    local ped = PlayerPedId()

    if freecam then
        local coords = GetEntityCoords(ped)
        local heading = GetEntityHeading(ped)

        FreezeEntityPosition(ped, true)
        SetEntityCollision(ped, false, false)

        cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)

        SetCamCoord(cam, coords.x, coords.y, coords.z + 1.0)
        SetCamRot(cam, 0.0, 0.0, heading, 2)

        SetCamActive(cam, true)
        RenderScriptCams(true, false, 0, true, true)

        CreateThread(function()
            while freecam do
                Wait(0)

                DisableAllControlActions(0)

                local camCoords = GetCamCoord(cam)
                local rot = GetCamRot(cam, 2)

                local forward = RotationToDirection(rot)

                -- Mausrad hoch = schneller
                if IsDisabledControlJustPressed(0, 241) then
                    speed = math.min(speed + 0.5, maxSpeed)
                end

                -- Mausrad runter = langsamer
                if IsDisabledControlJustPressed(0, 242) then
                    speed = math.max(speed - 0.5, minSpeed)
                end

                -- F = Filter wechseln
                if IsDisabledControlJustPressed(0, 23) then
                    currentFilter = currentFilter + 1

                    if currentFilter > #filters then
                        currentFilter = 1
                    end

                    local filter = filters[currentFilter]

                    if filter == "default" then
                        ClearTimecycleModifier()
                    else
                        SetTimecycleModifier(filter)
                    end
                end

                -- W
                if IsDisabledControlPressed(0, 32) then
                    camCoords = camCoords + (forward * speed)
                end

                -- S
                if IsDisabledControlPressed(0, 33) then
                    camCoords = camCoords - (forward * speed)
                end

                -- A
                if IsDisabledControlPressed(0, 34) then
                    local left = vector3(-forward.y, forward.x, 0.0)
                    camCoords = camCoords + (left * speed)
                end

                -- D
                if IsDisabledControlPressed(0, 35) then
                    local right = vector3(forward.y, -forward.x, 0.0)
                    camCoords = camCoords + (right * speed)
                end

                -- Q hoch
                if IsDisabledControlPressed(0, 44) then
                    camCoords = camCoords + vector3(0.0, 0.0, speed)
                end

                -- E runter
                if IsDisabledControlPressed(0, 38) then
                    camCoords = camCoords - vector3(0.0, 0.0, speed)
                end

                local rightAxisX = GetDisabledControlNormal(0, 220)
                local rightAxisY = GetDisabledControlNormal(0, 221)

                local newZ = rot.z - (rightAxisX * 5.0)
                local newX = math.max(math.min(89.0, rot.x - (rightAxisY * 5.0)), -89.0)

                SetCamRot(cam, newX, 0.0, newZ, 2)
                SetCamCoord(cam, camCoords.x, camCoords.y, camCoords.z)

                DrawTxt("Speed: " .. string.format("%.1f", speed), 0.5, 0.90)
                DrawTxt("Filter [" .. currentFilter .. "/" .. #filters .. "]: " .. filters[currentFilter], 0.5, 0.93)
                DrawTxt("Mausrad = Speed | F = Filter", 0.5, 0.96)
            end
        end)

    else
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(cam, false)

        ClearTimecycleModifier()

        FreezeEntityPosition(ped, false)
        SetEntityCollision(ped, true, true)
    end
end)

RegisterCommand("freecam", function()
    TriggerServerEvent("freecam:checkPermission")
end)

function RotationToDirection(rotation)
    local adjustedRotation =
    {
        x = (math.pi / 180) * rotation.x,
        y = (math.pi / 180) * rotation.y,
        z = (math.pi / 180) * rotation.z
    }

    local direction =
    {
        x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        z = math.sin(adjustedRotation.x)
    }

    return vector3(direction.x, direction.y, direction.z)
end

function DrawTxt(text, x, y)
    SetTextFont(4)
    SetTextScale(0.4, 0.4)
    SetTextColour(255, 255, 255, 255)
    SetTextOutline()
    SetTextCentre(true)

    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
end
