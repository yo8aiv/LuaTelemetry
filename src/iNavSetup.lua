local SMLCD = LCD_W < 212
local HORUS = LCD_W >= 480 or LCD_H >= 480
local complete = false
local results = {}

local sensors = {
	-- S.Port telemetry (X-Series receivers)
	{ o = "0420",  n = "Dist", d = 0x420, i = 28, p = 0 },
	{ o = "0430",  n = "Ptch", d = 0x430, i = 28, p = 0 },
	{ o = "0440",  n = "Roll", d = 0x440, i = 28, p = 0 },
	{ o = "0450",  n = "FPV",  d = 0x450, i = 28, p = 0 },

	-- FrSky telemetry (D-Series receivers)
	{ o = "0007",  n = "Dist", d = 0x007, i = 28, p = 0 },
	{ o = "0008",  n = "Ptch", d = 0x008, i = 28, p = 0 },
	{ o = "0020",  n = "Roll", d = 0x020, i = 28, p = 0 },

	-- Crossfire telemetry
	{ o = "BtRx",  n = "RxBt", d = 0x008, i = 0,  p = 1 },
}

local function getTelemetryId(n)
	local field = getFieldInfo(n)
	return field and field.id or false
end

local function getTelemetryUnit(n)
	local field = getFieldInfo(n)
	return (field and field.unit <= 10) and field.unit or 0
end

local function renameSensor(sensor)
	if getTelemetryId(sensor.o) then
		local old =  getFieldInfo(sensor.o)
		local unit = old == nil and 1 or (old.unit == nil and 1 or old.unit)
		setTelemetryValue(sensor.d, 0, sensor.i, 0, unit, sensor.p, sensor.n)
		results[#results + 1] = sensor.o .. " renamed " .. sensor.n
	end
end

local function run(event)
	-- Clear screen
	if HORUS then
		lcd.setColor(CUSTOM_COLOR, 0)
		lcd.clear(CUSTOM_COLOR)
		lcd.setColor(CUSTOM_COLOR, YELLOW)
	else
		lcd.clear()
	end

	-- Rename sensors
	if not complete then
		for i = 1, #sensors do
			renameSensor(sensors[i])
		end
		complete = true
	end

	-- Output results
	if #results == 0 then
		lcd.drawText(10, 10, "Nothing to change", SMLSIZE + CUSTOM_COLOR)
	else
		for i = 1, #results do
			lcd.drawText(10, 13 * i, results[i], SMLSIZE + CUSTOM_COLOR)
		end
	end

	return 0
end

return { run = run }