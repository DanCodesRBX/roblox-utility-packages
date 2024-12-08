local Signal = require(script.Parent.roblox_packages.Signal)

local getTranslator = require(script.getTranslator)

local SOURCE_LOCALE = "en-us"

local playerTranslator
local sourceTranslator

export type KeyArguments = {[string]: string | number} | {[number]: string | number}

local TranslationHelper = {
	LocaleChanged = Signal.new()
}

local function init()
	local start = os.clock()

	playerTranslator = getTranslator()
	sourceTranslator = getTranslator(SOURCE_LOCALE)

	print(`Got translators in {os.clock() - start}s`)

	playerTranslator:GetPropertyChangedSignal("LocaleId"):Connect(function()
		TranslationHelper.LocaleChanged:Fire()
	end)
end

function TranslationHelper.translate(text: string, context: Instance?)
	if playerTranslator then
		return playerTranslator:Translate(context or game, text)
	elseif sourceTranslator then
		return sourceTranslator:Translate(context or game, text)
	else -- Handle odd case
		warn(`Failed to find translation for text: {text}`)
		return text
	end
end

function TranslationHelper.translateByKey(key: string, arguments: KeyArguments?)
	local translation = ""
	local foundTranslation = false

	if playerTranslator then
		foundTranslation = pcall(function()
			translation = playerTranslator:FormatByKey(key, arguments)
		end)
	end

	if sourceTranslator and not foundTranslation then
		foundTranslation = pcall(function()
			translation = sourceTranslator:FormatByKey(key, arguments)
		end)
	end

	if foundTranslation then
		return translation
	else
		warn(`Failed to find translation for key: {key}`)
		return false
	end
end

init()

return TranslationHelper