if ES and CLIENT then --ExclServer support
    hook.Add("ESSupressCustomVoice", "JB.SupressESVoice", function() return true end)
end
