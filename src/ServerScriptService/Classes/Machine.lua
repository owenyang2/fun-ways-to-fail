-- machine class that can be inherited for useful functions for all machines

local Machine = {}
Machine.__index = Machine

function Machine:GetHitboxParams()
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

function Machine:GetAvailableInst(instTbl)
    local available = #instTbl

    if #available == 0 then warn("No available hydraulic presses to set up.") return end

    local inst = instTbl[#available]
    table.remove(instTbl, #available)
    return inst
end

function Machine.new(class)
    return setmetatable(class, Machine)
end

return Machine