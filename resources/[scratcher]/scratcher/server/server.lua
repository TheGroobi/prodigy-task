RegisterNetEvent("scratcher:win", function(winAmount)
	local player = Ox.GetPlayer(source)

	if not player then
		print("[ERROR] player not found")
		return
	end

	local account = player.getAccount()
	if not account then
		print("[ERROR] Account not found or charId missing.")
		return
	end

	account.addBalance({ amount = winAmount, message = "Scratcher win" })
end)
