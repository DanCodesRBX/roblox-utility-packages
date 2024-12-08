--!strict

local Signal = require(script.Parent.Packages.Signal)
local Trove = require(script.Parent.Packages.Trove)

local TOLERANCE = 0.05

type ProtectedPromptImpl = {
	__index: ProtectedPromptImpl,
	Destroy: (self: ProtectedPrompt) -> (),
	new: (prompt: ProximityPrompt) -> ProtectedPrompt
}

export type ProtectedPrompt = typeof(setmetatable(
	{} :: {
		_trove: Trove.Trove,
		_previousTimes: {[Player]: number},

		Triggered: Signal.Signal<Player, boolean>,
	},
	
	{} :: ProtectedPromptImpl
))

local ProtectedPrompt: ProtectedPromptImpl = {} :: ProtectedPromptImpl
ProtectedPrompt.__index = ProtectedPrompt

function ProtectedPrompt.new(prompt: ProximityPrompt)
	local trove = Trove.new()
	
	local self = setmetatable({
		_trove = trove,
		_previousTimes = {},

		Triggered = trove:Construct(Signal)
	}, ProtectedPrompt)

	trove:Add(prompt.Triggered:Connect(function(player)
		local currentTime = time()
		local previousTime = self._previousTimes[player] or 0
		local timeBetweenPresses = (currentTime - previousTime)
		
		self._previousTimes[player] = currentTime

		-- For cleaning up disconnected players
		if not previousTime then
			local subTrove = trove:Extend()

			subTrove:Add(function()
				self._previousTimes[player] = nil
			end)

			subTrove:AttachToInstance(player)
		end

		local successful = false
		if timeBetweenPresses >= (prompt.HoldDuration - TOLERANCE) then
			successful = true
		end

		self.Triggered:Fire(player, successful)
	end))

	trove:AttachToInstance(prompt)

	return self
end

function ProtectedPrompt:Destroy()
	self._trove:Destroy()
end

return ProtectedPrompt

-- local Players = game:GetService("Players")
-- local PromptService = game:GetService("ProximityPromptService")
-- local CollectionService = game:GetService("CollectionService")

-- local ProtectedPrompt = {}
-- local times = {}

-- local function getPromptData(prompt: ProximityPrompt, player: Player)
-- 	local playerData = times[player]
	
-- 	if not playerData then
-- 		times[player] = {}
-- 		playerData = times[player]
-- 	end
	
-- 	local promptData = playerData[prompt]
	
-- 	if not promptData then
-- 		playerData[prompt] = {}
-- 		promptData = playerData[prompt]
		
-- 		prompt.Destroying:Once(function()
-- 			if playerData then playerData[prompt] = nil end
-- 		end)
-- 	end
	
-- 	return promptData
-- end

-- function promptProtection.CanTrigger(prompt: ProximityPrompt, player: Player)
-- 	assert(typeof(prompt) == "Instance" and prompt:IsA("ProximityPrompt"), "Did not pass a valid ProximityPrompt")
-- 	assert(typeof(player) == "Instance" and player:IsA("Player"), "Did not pass a valid Player")
	
-- 	if prompt.HoldDuration == 0 then return true end
	
-- 	local promptData = getPromptData(prompt, player)

-- 	if not promptData.Start then return end

-- 	local holdDuration = promptData.Finish - promptData.Start
-- 	promptData.Start = nil

-- 	return holdDuration >= prompt.HoldDuration - 0.05 -- Tolarance for time inaccuracy
-- end

-- PromptService.PromptButtonHoldBegan:Connect(function(prompt, player)
-- 	local promptData = getPromptData(prompt, player)
-- 	promptData.Start = time()
-- end)

-- PromptService.PromptButtonHoldEnded:Connect(function(prompt, player)
-- 	local promptData = getPromptData(prompt, player)
-- 	promptData.Finish = time()
-- end)

-- Players.PlayerRemoving:Connect(function(player)
-- 	times[player] = nil
-- end)

-- return promptProtection