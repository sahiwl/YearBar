--!nonstrict
-- Circular progress SVGs matching macOS CircularProgressView (72px rings).

local rings = {}

local CIRC = 2 * math.pi * 30 -- r=30 → ~188.4956

local COLORS = {
	year = "#0A84FF",
	month = "#FF9F0A",
	week = "#30D158",
}

function rings.color(mode)
	return COLORS[mode] or COLORS.year
end

function rings.svg(progress, color)
	local p = progress
	if p < 0 then
		p = 0
	elseif p > 100 then
		p = 100
	end
	local offset = CIRC * (1 - p / 100)
	local text = string.format("%.2f%%", p)
	return string.format(
		[[<svg xmlns="http://www.w3.org/2000/svg" width="72" height="72" viewBox="0 0 72 72">]]
			.. [[<circle cx="36" cy="36" r="30" fill="none" stroke="%s" stroke-opacity="0.15" stroke-width="6"/>]]
			.. [[<circle cx="36" cy="36" r="30" fill="none" stroke="%s" stroke-width="6" stroke-linecap="round" ]]
			.. [[stroke-dasharray="%.4f" stroke-dashoffset="%.4f" transform="rotate(-90 36 36)"/>]]
			.. [[<text x="36" y="40" text-anchor="middle" font-family="system-ui,sans-serif" font-size="11" font-weight="600" fill="%s">%s</text>]]
			.. [[</svg>]],
		color,
		color,
		CIRC,
		offset,
		color,
		text
	)
end

function rings.writeAll(dir, yearP, monthP, weekP)
	noctalia.mkdirAll(dir)
	noctalia.writeFile(dir .. "/year.svg", rings.svg(yearP, COLORS.year))
	noctalia.writeFile(dir .. "/month.svg", rings.svg(monthP, COLORS.month))
	noctalia.writeFile(dir .. "/week.svg", rings.svg(weekP, COLORS.week))
end

return rings
