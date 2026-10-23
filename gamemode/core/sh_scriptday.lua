JB.Scriptdays = {}

function JB:RegisterScriptday(id, definition)
    assert(isstring(id) and id ~= "", "Scriptday ID must be a non-empty string")
    assert(istable(definition), "Scriptday definition must be a table")
    assert(isstring(definition.Name) and definition.Name ~= "", "Scriptday must have a name")
    assert(isstring(definition.Description), "Scriptday must have a description")
    assert(isstring(definition.Icon) and definition.Icon ~= "", "Scriptday must have an icon")
    assert(not self.Scriptdays[id], "Duplicate Scriptday ID: " .. id)

    definition.ID = id
    self.Scriptdays[id] = definition
end

function JB:GetScriptday(id)
    return self.Scriptdays[id]
end

function JB:GetScriptdays()
    local scriptdays = {}
    for _, scriptday in pairs(self.Scriptdays) do
        scriptdays[#scriptdays + 1] = scriptday
    end

    table.sort(scriptdays, function(a, b)
        return a.Name < b.Name
    end)

    return scriptdays
end

function JB:GetActiveScriptday()
    if not IsValid(self.TRANSMITTER) then return nil end
    return self:GetScriptday(self.TRANSMITTER:GetJBScriptday())
end

function JB:GetTeamName(teamID)
    local name = teamID == TEAM_PRISONER and "Prisoners" or teamID == TEAM_GUARD and "Guards" or team.GetName(teamID) or ""
    local scriptday = self:GetActiveScriptday()
    local scriptdayID = scriptday and scriptday.ID or ""
    local hookName = hook.Call("JailBreakGetTeamName", self.Gamemode, teamID, name, scriptdayID)
    if isstring(hookName) and hookName ~= "" then return hookName end

    if scriptday and isfunction(scriptday.GetTeamName) then
        local scriptdayName = scriptday.GetTeamName(teamID, name)
        if isstring(scriptdayName) and scriptdayName ~= "" then return scriptdayName end
    end

    return name
end

function JB:GetRoundEndMessage(winner)
    local message = "Draw"
    if winner == TEAM_PRISONER or winner == TEAM_GUARD then
        message = self:GetTeamName(winner) .. " win"
    end

    local scriptday = self:GetActiveScriptday()
    if scriptday and isfunction(scriptday.GetRoundEndMessage) then
        local scriptdayMessage = scriptday.GetRoundEndMessage(winner, message)
        if isstring(scriptdayMessage) and scriptdayMessage ~= "" then
            message = scriptdayMessage
        end
    end

    local hookMessage = hook.Call("JailBreakGetRoundEndMessage", self.Gamemode, winner, message, scriptday and scriptday.ID or "")
    if isstring(hookMessage) and hookMessage ~= "" then return hookMessage end

    return message
end
