--!strict
local Players = game:GetService("Players")

local Signal = require(script.Parent.roblox_packages.Signal)
local Trove = require(script.Parent.roblox_packages.Trove)

local TOLERANCE = 0.05

type ProtectedPromptImpl = {
	__index: ProtectedPromptImpl,
	Destroy: (self: ProtectedPrompt) -> (),
	new: (prompt: ProximityPrompt) -> ProtectedPrompt,
	_handleTriggered: (self: ProtectedPrompt, player: Player) -> ()
}

export type ProtectedPrompt = typeof(setmetatable(
	{} :: {
		_trove: Trove.Trove,
		_previousTimes: {[Player]: number},
		_prompt: ProximityPrompt,

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
		_prompt = prompt,

		Triggered = trove:Construct(Signal)
	}, ProtectedPrompt)

	trove:Add(prompt.Triggered:Connect(function(player)
		self:_handleTriggered(player)
	end))

	trove:Add(Players.PlayerRemoving:Connect(function(player)
		self._previousTimes[player] = nil
	end))

	trove:AttachToInstance(prompt) -- Cleans up object when instance is removed from the DataModel

	return self
end

function ProtectedPrompt:_handleTriggered(player)
		local currentTime = time()
		local previousTime = self._previousTimes[player] or 0
		local timeBetweenPresses = (currentTime - previousTime)

		local successful = false
		if timeBetweenPresses >= (self._prompt.HoldDuration - TOLERANCE) then
			successful = true
			self._previousTimes[player] = currentTime
		end

		self.Triggered:Fire(player, successful)
end

function ProtectedPrompt:Destroy()
	self._trove:Destroy()
end

return ProtectedPrompt
