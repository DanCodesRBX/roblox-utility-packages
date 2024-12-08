--!strict

local TIMEOUT = 3

export type AnimationTable = {[string]: AnimationTrack}

local AnimationLoader = {}
local loadedAnimations: {[Model]: AnimationTable} = {}

local function unloadAnimations(model: Model)	
	loadedAnimations[model] = nil
end

local function cleanupConnections(connections: {RBXScriptConnection})
	for _, connection in connections do
		connection:Disconnect()
	end
end

function AnimationLoader.load(model: Model, animationFolder: Folder): AnimationTable
	assert(typeof(model) == "Instance" and model:IsA("Model"), "Expected parameter 1 to be a Model!")
	assert(typeof(animationFolder) == "Instance" and animationFolder:IsA("Folder"), "Expected parameter 2 to be a Folder!")

	if loadedAnimations[model] then
		warn("Animations were already loaded for this model!")
		return loadedAnimations[model]
	end

	local animatorHolder = assert(
		model:FindFirstChildOfClass("Humanoid") or
		model:FindFirstChildOfClass("AnimationController"),
		"The model requires a Humanoid or AnimationController!"
	)

	local animator = assert(
		animatorHolder:FindFirstChildOfClass("Animator"),
		"The Humanoid or AnimationController does not contain an Animator!"
	)

	local animations: AnimationTable = {}
	local hasAnimations = false -- You can't get the length of a dictionary
	local nonAnimations = 0

	for _, animation in animationFolder:GetChildren() do
		if not animation:IsA("Animation") then 
			nonAnimations += 1
		else
			animations[animation.Name] = animator:LoadAnimation(animation)
			hasAnimations = true
		end
	end

	if not hasAnimations then
		warn("No animations found inside the animation folder!")
	end

	if nonAnimations > 0 then
		warn(`Found {nonAnimations} non-animation instance(s) inside of the animation folder!`)
	end

	loadedAnimations[model] = animations
	
	local connections = {} -- If more connections are ever needed

	table.insert(connections,
		model.AncestryChanged:Connect(function()
			if not model:IsDescendantOf(game) then
				unloadAnimations(model)
				cleanupConnections(connections)
			end
		end)
	)

	return animations
end

function AnimationLoader.get(model: Model): AnimationTable
	local start = time()

	while not loadedAnimations[model] do
		task.wait()

		if time() - start >= TIMEOUT then
			error("Timeout waiting for animations to load!")
		end
	end

	return loadedAnimations[model]
end

return AnimationLoader
