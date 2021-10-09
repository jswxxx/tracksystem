ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('trackmyfvkingphone:TracePhone')
AddEventHandler('trackmyfvkingphone:TracePhone', function(phoneNum, allowedJob)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	
	if xPlayer.job.name ~= allowedJob and not allowedJob == 'all' then
		return
	end
	
	if xPlayer.getAccount('black_money').money >= 500 or xPlayer.job.name == 'police' then
		MySQL.Async.fetchAll("SELECT * FROM users WHERE phone_number = @phone_number", { ['@phone_number'] = phoneNum }, function(result)
			if result[1] ~= nil then
				local xTarget = ESX.GetPlayerFromIdentifier(result[1].identifier)
				
				if xTarget then
					TriggerClientEvent('trackmyfvkingphone:checkTargetPhone', xTarget.source, xPlayer.source, xTarget.source, phoneNum)
					xPlayer.removeAccountMoney('black_money', 500)
				else
					TriggerClientEvent('mythic_notify:client:SendAlert', xPlayer.source, { type = 'error', text = 'Target phone number is not yet available.', length = 5000 })
				end
			else
				TriggerClientEvent('mythic_notify:client:SendAlert', xPlayer.source, { type = 'error', text = 'Phone number not found.', length = 5000 })
			end
		end)
	else
		TriggerClientEvent('mythic_notify:client:SendAlert', xPlayer.source, { type = 'error', text = 'You don\'t have enough dirty money. | $500 Dirty Required', length = 5000 })
	end
	
	
end)

RegisterServerEvent('trackmyfvkingphone:checkTargetPhoneServ')
AddEventHandler('trackmyfvkingphone:checkTargetPhoneServ', function(hasitem, oldsource, target, phonenumber)
	if hasitem then
		TriggerClientEvent('trackmyfvkingphone:getTargetCoords', oldsource, target, phonenumber)
	else
		TriggerClientEvent('mythic_notify:client:SendAlert', oldsource, { type = 'error', text = 'The target was not found.', length = 5000 })
	end
end)
