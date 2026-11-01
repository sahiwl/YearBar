--!nonstrict
-- Port of core/src/time.ts — Monday-based weeks, local time.

local time = {}

local function startOfYear(ts)
	local t = os.date("*t", ts)
	return os.time({ year = t.year, month = 1, day = 1, hour = 0, min = 0, sec = 0 })
end

local function startOfMonth(ts)
	local t = os.date("*t", ts)
	return os.time({ year = t.year, month = t.month, day = 1, hour = 0, min = 0, sec = 0 })
end

local function startOfWeek(ts)
	local t = os.date("*t", ts)
	-- Lua wday: 1=Sunday .. 7=Saturday → Monday-based offset
	local mondayOffset
	if t.wday == 1 then
		mondayOffset = -6
	else
		mondayOffset = 2 - t.wday
	end
	return os.time({
		year = t.year,
		month = t.month,
		day = t.day + mondayOffset,
		hour = 0,
		min = 0,
		sec = 0,
	})
end

local function ratio(elapsed, total)
	if total <= 0 then
		return 0
	end
	return (elapsed / total) * 100
end

function time.yearProgress(ts)
	local now = ts or os.time()
	local start = startOfYear(now)
	local t = os.date("*t", now)
	local ending = os.time({ year = t.year + 1, month = 1, day = 1, hour = 0, min = 0, sec = 0 })
	return ratio(now - start, ending - start)
end

function time.monthProgress(ts)
	local now = ts or os.time()
	local start = startOfMonth(now)
	local t = os.date("*t", now)
	local ending = os.time({ year = t.year, month = t.month + 1, day = 1, hour = 0, min = 0, sec = 0 })
	return ratio(now - start, ending - start)
end

function time.weekProgress(ts)
	local now = ts or os.time()
	local start = startOfWeek(now)
	local ending = start + 7 * 24 * 60 * 60
	return ratio(now - start, ending - start)
end

function time.progress(mode, ts)
	if mode == "month" then
		return time.monthProgress(ts)
	elseif mode == "week" then
		return time.weekProgress(ts)
	end
	return time.yearProgress(ts)
end

local function wholeDays(from, to)
	return math.floor((to - from) / 86400)
end

function time.yearDayCounts(ts)
	local now = ts or os.time()
	local start = startOfYear(now)
	local t = os.date("*t", now)
	local ending = os.time({ year = t.year + 1, month = 1, day = 1, hour = 0, min = 0, sec = 0 })
	local spent = wholeDays(start, now)
	local total = wholeDays(start, ending)
	return spent, total - spent
end

function time.monthDayCounts(ts)
	local now = ts or os.time()
	local t = os.date("*t", now)
	local spent = t.day
	local ending = os.time({ year = t.year, month = t.month + 1, day = 1, hour = 0, min = 0, sec = 0 })
	local start = startOfMonth(now)
	local total = wholeDays(start, ending)
	return spent, total - spent
end

function time.weekDayCounts(ts)
	local now = ts or os.time()
	local start = startOfWeek(now)
	local ending = start + 7 * 24 * 60 * 60
	local spent = wholeDays(start, now)
	local total = wholeDays(start, ending)
	return spent, total - spent
end

function time.dayCounts(mode, ts)
	if mode == "month" then
		return time.monthDayCounts(ts)
	elseif mode == "week" then
		return time.weekDayCounts(ts)
	end
	return time.yearDayCounts(ts)
end

function time.formatPercent(value, decimals)
	local d = decimals or 1
	return string.format("%." .. tostring(d) .. "f%%", value)
end

return time
