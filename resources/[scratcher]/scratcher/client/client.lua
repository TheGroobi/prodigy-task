local scratcherOpen = false

RegisterNuiCallback("scratcher:close", function()
	if scratcherOpen then
		SetNuiFocus(false, false)
		print("[CLOSE] Scratcher not dirty, not consuming scratcher")

		SendNUIMessage({
			action = "closeScratcher",
		})

		scratcherOpen = false
	end
end)

exports("scratcher:open", function()
	if scratcherOpen == true then
		return
	end

	SetNuiFocus(true, true)

	SendNUIMessage({
		action = "openScratcher",
	})

	scratcherOpen = true
end)

RegisterNUICallback("scratcher:win", function(data)
	SetNuiFocus(false, false)

	TriggerServerEvent("scratcher:transfer-win", data.winAmount)

	SetTimeout(5000, function()
		SendNUIMessage({
			action = "closeScratcher",
		})

		scratcherOpen = false
	end)

	lib.notify({
		title = ("You won $%s from the scratcher!"):format(data.winAmount),
		description = "The money has been transferred to your personal account",
		type = "success",
	})
end)

RegisterNUICallback("scratcher:lose", function()
	SetNuiFocus(false, false)

	SetTimeout(3000, function()
		SendNUIMessage({
			action = "closeScratcher",
		})

		scratcherOpen = false
	end)

	lib.notify({
		title = "Better luck next time",
		description = "Remember, you can't win if you don't play",
		type = "success",
	})
end)

RegisterNuiCallback("scratcher:consume", function()
	TriggerServerEvent("scratcher:consume")
end)
