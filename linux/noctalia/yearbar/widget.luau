--!nonstrict
-- Bar capsule: donut glyph + active-mode % (sysmon-style). Hover = key/value tooltip.

local time = require("./lib/time.luau")

local mode = "year"
local yearP, monthP, weekP = 0, 0, 0

local function activeProgress()
	if mode == "month" then
		return monthP
	elseif mode == "week" then
		return weekP
	end
	return yearP
end

local function refreshTooltip()
	barWidget.setTooltip({
		{ key = "Year", value = time.formatPercent(yearP, 1) },
		{ key = "Month", value = time.formatPercent(monthP, 1) },
		{ key = "Week", value = time.formatPercent(weekP, 1) },
		{ key = "Mode", value = mode },
	})
end

local function render()
	local label = time.formatPercent(activeProgress(), 1)
	local children = {
		ui.glyph({ name = "chart-donut-3", size = 14 }),
		ui.label({ text = label, fontWeight = "bold" }),
	}
	if barWidget.isVertical() then
		barWidget.render(ui.column({ gap = 6, align = "center" }, children))
	else
		barWidget.render(ui.row({ gap = 6, align = "center" }, children))
	end
	refreshTooltip()
end

function update()
	noctalia.setUpdateInterval(60000)
	mode = noctalia.state.get("yearbar.mode") or "year"
	yearP = tonumber(noctalia.state.get("yearbar.year")) or time.yearProgress()
	monthP = tonumber(noctalia.state.get("yearbar.month")) or time.monthProgress()
	weekP = tonumber(noctalia.state.get("yearbar.week")) or time.weekProgress()
	render()
end

noctalia.state.watch("yearbar.year", function(value)
	yearP = tonumber(value) or yearP
	render()
end)

noctalia.state.watch("yearbar.month", function(value)
	monthP = tonumber(value) or monthP
	render()
end)

noctalia.state.watch("yearbar.week", function(value)
	weekP = tonumber(value) or weekP
	render()
end)

noctalia.state.watch("yearbar.mode", function(value)
	if value == "year" or value == "month" or value == "week" then
		mode = value
		render()
	end
end)

function onClick()
	noctalia.togglePanel("sahiwl/yearbar:panel")
end
