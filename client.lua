ESX = nil

local PlayerData              = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

RegisterNetEvent("trackmyfvkingphone:checkTargetPhone")
AddEventHandler("trackmyfvkingphone:checkTargetPhone", function(source, target, phonenumber)
	local hasitem = exports['__inventory']:SearchItems({'phone'})
	--print(hasitem)
	TriggerServerEvent('trackmyfvkingphone:checkTargetPhoneServ', hasitem, source, target, phonenumber)
end)

RegisterNetEvent("trackmyfvkingphone:getTargetCoords")
AddEventHandler("trackmyfvkingphone:getTargetCoords", function(target, phonenumber)
	local targetPed = GetPlayerPed(GetPlayerFromServerId(target))
	local targetPedCoords = GetEntityCoords(targetPed)
	
	exports['__progbar']:Progress({
		name = "30000",
		duration = 7000,
		label = 'Tracing Phone Number...',
		useWhileDead = false,
		canCancel = false,
		controlDisables = {
			disableMovement = false,
			disableCarMovement = false,
			disableMouse = false,
			disableCombat = true,
		},
		animation = {
			animDict = "anim@heists@prison_heiststation@cop_reactions",
			anim = "cop_b_idle",
			flags = 49,
		},
	}, function(cancelled)
		local started = GetGameTimer()
       	local blip = AddBlipForCoord(targetPedCoords.x, targetPedCoords.y, targetPedCoords.z)

		SetBlipSprite(blip, 459)
		SetBlipDisplay(blip, 4)
		SetBlipScale(blip, 1.5)
		SetBlipColour(blip, 4)
		SetBlipAsShortRange(blip, false)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Tracked Phone - " .. phonenumber)
		EndTextCommandSetBlipName(blip)

		exports['mythic_notify']:DoCustomHudText ('inform', 'Last position where the phone was traced has been added into your blips.', 10000)
        while true do
        	Citizen.Wait(500)
        	if ( GetGameTimer() - started ) > 30000 then
        		if DoesBlipExist(blip) then
        			RemoveBlip(blip)
        		end
        		return
        	end
        end
	end)
end)

local TracingStations = {
	{ pos = vector3(1272.66, -1714.86, 54.77), allowed = 'all', text = '[E] to track a phone number' }
	--{ pos = vector3(441.29, -996.61, 34.97), allowed = 'police', text = '[E] to track a phone number' }
}

Citizen.CreateThread(function()
	while true do
		local sleep = 500
		local pedCoords = GetEntityCoords(PlayerPedId())

		for i = 1, #TracingStations, 1 do
			local dist = GetDistanceBetweenCoords(pedCoords, TracingStations[i].pos, 1)

			if dist < 3.0 and (ESX.PlayerData.job.name == TracingStations[i].allowed or TracingStations[i].allowed == 'all') then
				sleep = 1
				Draw3DText(TracingStations[i].pos.x, TracingStations[i].pos.y, TracingStations[i].pos.z, TracingStations[i].text)

				if IsControlJustReleased(0, 38) and dist < 1.0 then
					InputPhoneNumber(TracingStations[i].allowed, TracingStations[i])					
					Citizen.Wait(1000)
				end
			end

		end

		Citizen.Wait(sleep)
	end
end)

function InputPhoneNumber(allowed)
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'trace_phone', {
        title    = 'Track Phone Number',
        align    = 'top-right',
        elements = elements
    }, function(data, menu)
        local phone = math.ceil(tonumber(data.value))

        if phone ~= nil and phone > 0 then
        	menu.close()
        	loadAnimDict("anim@heists@prison_heiststation@cop_reactions")
            TaskPlayAnim(GetPlayerPed(-1), "anim@heists@prison_heiststation@cop_reactions", 'cop_b_idle', 2.0, 2.0, -1, 48, 0, 0, 0, 0)   

            for i = 1, 3, 1 do
			    local finished = exports['yourskillbarhere']:skillBar(3000, math.random(5, 7))
			    if finished <= 0 then
			      exports['mythic_notify']:DoLongHudText('error', 'Failed.')
			      ClearPedTasks(PlayerPedId())
			      return
			    end 
			end 

		    ClearPedTasks(PlayerPedId())
		    Citizen.Wait(1000)              
        	TriggerServerEvent('trackmyfvkingphone:TracePhone', phone, allowed)
        end

    end, function(data, menu)
        menu.close()
    end)
end

function loadAnimDict( dict )
    RequestAnimDict( dict )
    while ( not HasAnimDictLoaded( dict ) ) do
        
        Citizen.Wait( 1 )
    end
end

function Draw3DText(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)

    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end
