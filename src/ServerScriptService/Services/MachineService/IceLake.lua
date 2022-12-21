local IceLake = {}
IceLake.__index = IceLake

local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ServerScriptService = game:GetService("ServerScriptService")

local Trove = require(RepStorage.Packages.Trove)
local TableUtil = require(RepStorage.Packages.TableUtil)

local Ragdoll = require(ServerScriptService.Server.Classes.Ragdoll)

IceLake.AvailableInstances = {
    game.Workspace.PlaceModels:FindFirstChild("Frozen Lake")
}

function IceLake:Start()

end

function IceLake.new(baseTbl)
    local newInst = baseTbl.MachineFuncs.GetAvailableInst(IceLake.AvailableInstances)
    if not newInst then return end

    local self = setmetatable(TableUtil.Assign(baseTbl, {
        Instance = newInst,
        
        _trove = Trove.new()
    }), IceLake)

    return self
end

return IceLake