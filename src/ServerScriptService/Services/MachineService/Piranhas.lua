local Piranhas = {}
Piranhas.__index = Piranhas

local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")

local Trove = require(RepStorage.Packages.Trove)
local TableUtil = require(RepStorage.Packages.TableUtil)
local Knit = require(RepStorage.Packages.Knit)

local Ragdoll = require(ServerScriptService.Server.Classes.Ragdoll)

Piranhas.AvailableInstances = {
    game.Workspace.PlaceModels:FindFirstChild("Piranhas")
}

function Piranhas:SpawnPiranhas(amt)
    for i = 1, amt do
        local inst = RepStorage.Assets.Piranha:Clone()
        inst.Parent = self.Instance.Fish
    
        CollectionService:AddTag(inst, "Piranha")
    
        table.insert(self.Piranhas, inst)    

        inst.Destroying:Connect(function()
            print("destorying, spawn new")
            self:SpawnPiranhas(1)
        end)
    end
end

function Piranhas:Start()
    self:SpawnPiranhas(self.StartPAmount)
end

function Piranhas.new(baseTbl)
    local newInst = baseTbl.MachineFuncs.GetAvailableInst(Piranhas.AvailableInstances)
    if not newInst then return end

    local self = setmetatable(TableUtil.Assign(baseTbl, {
        Instance = newInst,
        
        Piranhas = {},
        StartPAmount = 5,
        
        _trove = Trove.new()
    }), Piranhas)

    return self
end

return Piranhas