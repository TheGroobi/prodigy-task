RegisterCommand("openui", function()
	SetNuiFocus(true, true)
	SendNUIMessage({
		action = "open",
	})
end, false)

RegisterNUICallback("close", function(data, cb)
	SetNuiFocus(false, false)
	cb({})
end)

exports("scratcher", function()
	print("scratcher scratched")
	SetNuiFocus(true, true)
	SendNUIMessage({
		action = "openScratcher",
	})
end)
