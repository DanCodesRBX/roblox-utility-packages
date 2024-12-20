--!native

local RANDOM = Random.new(os.clock())

local Math = {}

--[[
	Maps a number from one range to another.

	The mapped value can be outside of the initial range,
	which is very useful for linear interpolation.
]]
function Math.map(value: number, fromMin: number, fromMax: number, toMin: number, toMax: number): number
	if fromMax == fromMin then
		error("Input range cannot be zero")
	end

	return (((value - fromMin) * (toMax - toMin)) / (fromMax - fromMin)) + toMin
end

--[[
	Returns a jittered value around the center with a random spread.
	
	Spread defaults to 50% of center.
]]
function Math.jitter(center: number, spread: number?): number
	local usedSpread = spread or 0.5 * center

	return center - 0.5 * usedSpread + RANDOM:NextNumber() * usedSpread
end

--[[
	Returns true if a number is NaN
]]
function Math.isNaN(num: number): boolean
	return num ~= num
end

--[=[
	Returns true if a number is finite
]=]
function Math.isFinite(num: number): boolean
	return num > -math.huge and num < math.huge
end

--[[
	Interpolates between two numbers based on a given percentage.
	The alpha parameter is a number between 0 and 1 that determines the
	interpolation factor between startValue and endValue.
]]
function Math.lerp(startValue: number, endValue: number, alpha: number): number
	return startValue + ((endValue - startValue) * alpha)
end

--[[
	Calculates the angle opposite side c in a triangle using the Law of Cosines.
]]
function Math.lawOfCosines(a: number, b: number, c: number): number?
	local cosTheta = (a^2 + b^2 - c^2) / (2*a*b)
	local theta = math.acos(cosTheta)

	if Math.isNaN(theta) then -- Check for NaN
		return nil
	end

	return theta
end

--[[
	Rounds the given number to a precision (if given)
]]
function Math.round(number: number, precision: number?): number
	if precision then
		return math.floor((number / precision) + 0.5) * precision
	else
		return math.floor(number + 0.5)
	end
end

--[[
	Rounds up to the given precision
]]
function Math.roundUp(number: number, precision: number): number
	return math.ceil(number / precision) * precision
end

--[[
	Rounds down to the given precision
]]
function Math.roundDown(number: number, precision: number): number
	return math.floor(number / precision) * precision
end

return Math
