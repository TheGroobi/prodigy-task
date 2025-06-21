RegisterNetEvent("scratcher:win", function(winAmount)
	local logEvent = " - at event (scratcher:win)"
	local player = Ox.GetPlayer(source)

	if not player then
		print("[ERROR] player not found" .. logEvent)
		return
	end

	local account = player.getAccount()
	if not account then
		print("[ERROR] Account not found")
		return
	end

	account.addBalance({ amount = winAmount, message = "Scratcher win" })
end)

RegisterNetEvent("scratcher:consume", function()
	local logEvent = " - at event (scratcher:consume)"
	local player = Ox.GetPlayer(source)

	if not player then
		print("[ERROR] player not found" .. logEvent)
		return
	end

	if exports.ox_inventory:RemoveItem(source, "scratcher", 1) then
		print("[SUCCESS] scratcher consumed" .. logEvent)
	end
end)
