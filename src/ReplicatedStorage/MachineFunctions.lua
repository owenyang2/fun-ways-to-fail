-- machine handler that can be called for useful functions for all machines

local MachineFunctions = {}

function MachineFunctions.GetHitboxParams()
    local params = OverlapParams.new()
    params.FilterType = Enum.RaycastFilterType.Whitelist
    
    local filterDesc = {}

    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr.Character then
            table.insert(filterDesc, plr.Character)
        end
    end

    params.FilterDescendantsInstances = filterDesc

    return params
end

function MachineFunctions.GetAvailableInst(instTbl)
    local available = #instTbl

    if available == 0 then warn("No available hydraulic presses to set up.") return end

    local inst = instTbl[available]
    table.remove(instTbl, available)
    return inst
end

return MachineFunctions