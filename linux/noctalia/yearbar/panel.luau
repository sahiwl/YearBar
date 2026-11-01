--!nonstrict
-- Click panel: Mac YearBar layout — title, 3 circular rings, day counts.

local time = require("./lib/time.luau")
local rings = require("./lib/rings.luau")

local mode = "year"
local yearP, monthP, weekP = 0, 0, 0
local ringsPath = ""

local function spentRemaining()
	local prefix = "yearbar." .. mode
	local spent = tonumber(noctalia.state.get(prefix .. "_spent"))
	local remaining = tonumber(noctalia.state.get(prefix .. "_remaining"))
	if spent and remaining then
		return spent, remaining
	end
	return time.dayCounts(mode)
end

local function ringPath(name)
	if ringsPath ~= "" then
		return ringsPath .. "/" .. name .. ".svg"
	end
	return noctalia.pluginDataDir() .. "/rings/" .. name .. ".svg"
end

local function activePercent()
	if mode == "month" then
		return monthP
	elseif mode == "week" then
		return weekP
	end
	return yearP
end

local function selectMode(id)
	mode = id
	noctalia.state.set("yearbar.mode", id)
	render()
end

local function modeChip(id, label, color)
	local selected = mode == id
	local weight = "medium"
	local labelColor = "outline"
	local dot = "#00000000"
	if selected then
		weight = "bold"
		labelColor = "on_surface"
		dot = color
	end
	return ui.column({
		key = "mode-" .. id,
		gap = 6,
		align = "center",
		onClick = function()
			selectMode(id)
		end,
	}, {
		ui.image({
			path = ringPath(id),
			width = 72,
			height = 72,
		}),
		ui.label({
			text = label,
			fontSize = 11,
			fontWeight = weight,
			color = labelColor,
		}),
		ui.box({
			width = 5,
			height = 5,
			radius = 3,
			fill = dot,
		}),
	})
end

function render()
	local spent, remaining = spentRemaining()
	panel.render(ui.column({ gap = 14, padding = 16 }, {
		ui.label({
			text = "Time Passed",
			fontSize = 15,
			fontWeight = "bold",
			color = "on_surface",
		}),
		ui.row({ gap = 16, justify = "center", align = "start" }, {
			modeChip("year", "Year", rings.color("year")),
			modeChip("month", "Month", rings.color("month")),
			modeChip("week", "Week", rings.color("week")),
		}),
		ui.column({ gap = 4, align = "start" }, {
			ui.label({
				text = "Remaining: " .. tostring(remaining) .. " days",
				fontSize = 12,
				fontWeight = "medium",
				color = "outline",
			}),
			ui.label({
				text = "Spent: " .. tostring(spent) .. " days",
				fontSize = 12,
				fontWeight = "medium",
				color = "outline",
			}),
		}),
		ui.separator({ spacing = 4 }),
		ui.label({
			text = "Active on bar: " .. mode .. " · " .. time.formatPercent(activePercent(), 1),
			fontSize = 11,
			color = "outline",
		}),
	}))
end

local function pullState()
	mode = noctalia.state.get("yearbar.mode") or "year"
	yearP = tonumber(noctalia.state.get("yearbar.year")) or time.yearProgress()
	monthP = tonumber(noctalia.state.get("yearbar.month")) or time.monthProgress()
	weekP = tonumber(noctalia.state.get("yearbar.week")) or time.weekProgress()
	ringsPath = noctalia.state.get("yearbar.rings_dir") or ""
end

function onOpen(_context)
	pullState()
	local dir = ringsPath
	if dir == "" then
		dir = noctalia.pluginDataDir() .. "/rings"
		ringsPath = dir
	end
	rings.writeAll(dir, yearP, monthP, weekP)
	render()
end

noctalia.state.watch("yearbar.rev", function(_value)
	pullState()
	render()
end)

noctalia.state.watch("yearbar.mode", function(value)
	if value == "year" or value == "month" or value == "week" then
		mode = value
		render()
	end
end)
