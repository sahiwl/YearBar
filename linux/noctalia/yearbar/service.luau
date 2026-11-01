--!nonstrict
-- Headless tick: compute progress, write ring SVGs, publish noctalia.state.

local time = require("./lib/time.luau")
local rings = require("./lib/rings.luau")

local function ringsDir()
	return noctalia.pluginDataDir() .. "/rings"
end

local function publish()
	local yearP = time.yearProgress()
	local monthP = time.monthProgress()
	local weekP = time.weekProgress()

	local ySpent, yRem = time.yearDayCounts()
	local mSpent, mRem = time.monthDayCounts()
	local wSpent, wRem = time.weekDayCounts()

	rings.writeAll(ringsDir(), yearP, monthP, weekP)

	noctalia.state.set("yearbar.year", yearP)
	noctalia.state.set("yearbar.month", monthP)
	noctalia.state.set("yearbar.week", weekP)
	noctalia.state.set("yearbar.year_spent", ySpent)
	noctalia.state.set("yearbar.year_remaining", yRem)
	noctalia.state.set("yearbar.month_spent", mSpent)
	noctalia.state.set("yearbar.month_remaining", mRem)
	noctalia.state.set("yearbar.week_spent", wSpent)
	noctalia.state.set("yearbar.week_remaining", wRem)
	noctalia.state.set("yearbar.rings_dir", ringsDir())
	noctalia.state.set("yearbar.rev", tostring(os.time()))

	local mode = noctalia.state.get("yearbar.mode")
	if mode ~= "year" and mode ~= "month" and mode ~= "week" then
		noctalia.state.set("yearbar.mode", "year")
	end
end

function update()
	noctalia.setUpdateInterval(60000)
	publish()
end

function onStart()
	publish()
end
