ESX = exports["es_extended"]:getSharedObject()
local using_bennys = {}

ESX.RegisterServerCallback('nation:checkPermission',function(source, cb)
    local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.job.name == config.permissao then
        cb(true)
    elseif config.mechaniconly then
        cb(false)
        TriggerClientEvent("Notify",source,"Negative","Only Mechanic can access ",7000)
    elseif not config.mechaniconly then
        cb(true)
    end
end)

ESX.RegisterServerCallback('nation:checkPayment',function(source, cb, amount)
    local source = source
	local xPlayer = ESX.GetPlayerFromId(source)

    if config.mechaniconly then 
        if config.societymoney then
            local societyAccount = nil
            TriggerEvent(
            "esx_addonaccount:getSharedAccount",
            config.society_name,
            function(account)
                societyAccount = account
            end)
            if societyAccount.money >= amount then
                societyAccount.removeMoney(amount)
                TriggerClientEvent("Notify",source,"sucesso","Upgrade <b>Succeess </b><br>Total Cost <b>$"..tonumber(amount).." $ <b>.",7000)
                cb(true)
            else
                TriggerClientEfent("Notify", source,"Failed","There is not enough money in the job ")
                cb(false)
            end
        end
    end
end)

RegisterServerEvent("nation:removeVehicle")
AddEventHandler("nation:removeVehicle",function(vehicle)
    using_bennys[vehicle] = nil
    return true
end)

ESX.RegisterServerCallback('nation:checkVehicle',function(source, cb, vehicle)
    if using_bennys[vehicle] then
        cb(false)
    else
    using_bennys[vehicle] = true
        cb(true)
    end
end)

AddEventHandler('playerDropped', function (reason)
    print('Player ' .. GetPlayerName(source) .. ' dropped (Reason: ' .. reason .. ')')
end)
  
RegisterServerEvent('saveVehicle')
AddEventHandler('saveVehicle', function(plate,props)
    local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
    if props.plate == nil then
    props.plate = plate
    end
	MySQL.Async.fetchAll('SELECT vehicle FROM owned_vehicles WHERE plate = @plate', {
		['@plate'] = props.plate
	}, function(result)
		if result[1] ~= nil and result[1].vehicle then
            local vehicle = json.decode(result[1].vehicle)
			if props.model == vehicle.model then
				MySQL.Async.execute('UPDATE owned_vehicles SET vehicle = @vehicle WHERE plate = @plate', {
					['@plate'] = props.plate,
					['@vehicle'] = json.encode(props)
				})
			else
				print(('zxcoder: %s attempted to upgrade vehicle with mismatching vehicle model!'):format(xPlayer.identifier))
			end
		end
	end)
end)


RegisterServerEvent("nation:syncApplyMods")
AddEventHandler("nation:syncApplyMods",function(vehicle_tuning,vehicle)
    TriggerClientEvent("nation:applymods_sync",-1,vehicle_tuning,vehicle)
end)