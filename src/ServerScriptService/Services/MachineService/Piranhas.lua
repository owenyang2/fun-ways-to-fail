local Piranhas = {}
Piranhas.__index = Piranhas

local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local Trove = require(RepStorage.Packages.Trove)
local TableUtil = require(RepStorage.Packages.TableUtil)

local PiranhaClass = require(ServerScriptService.Server.Classes.PiranhaClass)

Piranhas.AvailableInstances = {
    game.Workspace.PlaceModels:FindFirstChild("Piranhas")
}

function Piranhas:SpawnPiranhas()
    local template = RepStorage.Assets.Piranha

    for i = 1, self.PiranhasToSpawn do
        local inst = template:Clone()
        inst.Parent = self.Instance.Fish

        local p = PiranhaClass.new(inst, self.Instance)

        table.insert(self.Piranhas, p)
    end
end

function Piranhas:Start()
    self:SpawnPiranhas()
end

function Piranhas.new(baseTbl)
    local newInst = baseTbl.MachineFuncs.GetAvailableInst(Piranhas.AvailableInstances)
    if not newInst then return end

    local self = setmetatable(TableUtil.Assign(baseTbl, {
        Instance = newInst,
        Piranhas = {},
        PiranhasToSpawn = 30,

        _trove = Trove.new()
    }), Piranhas)

    return self
end

return Piranhas