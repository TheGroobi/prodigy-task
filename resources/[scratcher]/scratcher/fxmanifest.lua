-- Resource Metadata
fx_version("cerulean")
game({ "gta5" })

author("TheGrooby <23wilk.szymon@gmail.com>")
description("Scratcher script")
version("1.0.0")

-- What to run
client_scripts({
	"client/client.lua",
})

ui_page("web/dist/index.html")

files({
	"web/dist/index.html",
	"web/dist/assets/*.js",
	"web/dist/assets/*.css",
	"web/dist/assets/*.png",
	"web/dist/assets/*.jpg",
})

-- Extra data can be used as well
-- my_data 'one' { two = 42 }
-- my_data 'three' { four = 69 }

-- due to Lua syntax, the following works too:
-- my_data('nine')({ninety = "nein"})
