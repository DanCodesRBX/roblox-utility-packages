local LocalizationService = game:GetService("LocalizationService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local function getTranslator(sourceLocale: string?): Translator
    local success, translator

    if sourceLocale then
        success, translator = pcall(function()
            return LocalizationService:GetTranslatorForLocaleAsync(sourceLocale)
        end)
    else
        success, translator = pcall(function()
            return LocalizationService:GetTranslatorForPlayer(player)
        end)
    end

    if not success then
        warn(`Failed to get Translator for: {sourceLocale or "Player"}`)
    end

    return translator
end

return getTranslator
