local scratcherOpen = false

SendNUIMessage({
	action = "userId",
	userId = Ox.GetPlayer().charId,
})

RegisterNuiCallback("scratcher:close", function()
	if scratcherOpen then
		SetNuiFocus(false, false)
		SendDiscordLogToUI("info", " Scratcher not dirty, not consuming scratcher", "client.lua - scratcher:close")

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
	SendDiscordLogToUI("info", " Scratcher has been opened", "client.lua - scratcher:close")

	SendNUIMessage({
		action = "openScratcher",
	})

	scratcherOpen = true
end)

RegisterNUICallback("scratcher:win", function(data)
	SetNuiFocus(false, false)

	TriggerServerEvent("scratcher:transfer-win", data.prize)

	SendDiscordLogToUI("info", ("User won $%s"):format(data.prize), "client.lua - scratcher:win")

	SetTimeout(5000, function()
		SendNUIMessage({
			action = "closeScratcher",
		})

		scratcherOpen = false
	end)

	lib.notify({
		title = ("You won $%s from the scratcher!"):format(data.prize),
		description = "The money has been transferred to your personal account",
		type = "success",
	})
end)

RegisterNUICallback("scratcher:lose", function()
	SetNuiFocus(false, false)

	SendDiscordLogToUI("info", "User did not win anything", "client.lua - scratcher:lose")

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
	SendDiscordLogToUI("info", " Scratcher dirty scratcher has been consumed", "client.lua - scratcher:consume")
end)

---@param method "info" | "warn" | "action" | "error"
---@param message string
---@param at string
function SendDiscordLogToUI(method, message, at)
	SendNUIMessage({
		action = "discordLog",

		logData = {
			ownerId = Ox.GetPlayer().charId,
			method = method,
			message = message,
			at = at,
		},
	})
end
