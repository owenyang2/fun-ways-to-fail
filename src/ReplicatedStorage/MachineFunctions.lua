-- machine handler that can be called for useful functions for all machines

local RepStorage = game:GetService("ReplicatedStorage")
local ServerComm = require(RepStorage.Packages.Comm).ServerComm

local MachineFunctions = {
    ServerComms = {},
    Signals = {}
}

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

function MachineFunctions.GetAnimLength(id)
    local tempAnim = Instance.new("Animation")
    tempAnim.AnimationId = id
    
    local tempTrack = Instance.new("Animator", Instance.new("Humanoid", game.Workspace)):LoadAnimation(tempAnim)
    return tempTrack.Length
end

function MachineFunctions.GetAvailableInst(instTbl)
    local available = #instTbl

    if available == 0 then warn("No available hydraulic presses to set up.") return end

    local inst = instTbl[available]
    table.remove(instTbl, available)
    return inst
end

-- Comm Class Global Functions

function MachineFunctions.AddGlobalServerComm(namespace)
    MachineFunctions.ServerComms[namespace] = ServerComm.new(RepStorage, namespace)
end

function MachineFunctions.GetGlobalServerComm(name)
    return MachineFunctions.ServerComms[name]
end

function MachineFunctions.DestroyGlobalServerComm(name)
    if not MachineFunctions.ServerComms[name] then
        warn("ServerComm '" .. name .. "' cannot be destroyed as it does not exist.")
        return
    end

    MachineFunctions.ServerComms[name]:Destroy()
    MachineFunctions.ServerComms[name] = nil
end

function MachineFunctions.CreateGlobalSignal(globalServerComm, sigName)
    MachineFunctions.Signals[sigName] = MachineFunctions.ServerComms[globalServerComm]:CreateSignal(sigName)
    return MachineFunctions.Signals[sigName]
end

function MachineFunctions.GetGlobalSignal(sigName)
    return MachineFunctions.Signals[sigName]
end

function MachineFunctions.DestroyGlobalSignal(sigName)
    if not MachineFunctions.Signals[sigName] then
        warn("Signal '" .. sigName .. "' cannot be destroyed as it does not exist.")
        return
    end

    MachineFunctions.Signals[sigName]:Destroy()
    return MachineFunctions.Signals[sigName]
end

return MachineFunctions