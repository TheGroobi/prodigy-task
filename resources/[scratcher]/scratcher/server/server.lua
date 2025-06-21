RegisterNetEvent("scratcher:win", function(prize)
	local logEvent = " - (scratcher:win)"
	local player = Ox.GetPlayer(source)

	if not player then
		print("[ERROR] player not found" .. logEvent)
		return
	end

	local account = player.getAccount()
	if not account then
		print("[ERROR] Account not found" .. logEvent)
		return
	end

	account.addBalance({ amount = prize, message = "Scratcher win" })

	print(("[SUCCESS] Player %s has won %s"):format(player.username, prize) .. logEvent)
	print(
		("[SUCCESS] It has been transferred to account %s \n from balance %s to %s"):format(
			account.id,
			account.balance - prize,
			account.balance .. logEvent
		)
	)
end)

RegisterNetEvent("scratcher:consume", function()
	local logEvent = " - (scratcher:consume)"
	local player = Ox.GetPlayer(source)

	if not player then
		print("[ERROR] player not found" .. logEvent)
		return
	end

	if exports.ox_inventory:RemoveItem(source, "scratcher", 1) then
		print("[INFO] scratcher consumed" .. logEvent)
	end
end)
