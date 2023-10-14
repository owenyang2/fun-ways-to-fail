local Piranhas = {}
Piranhas.__index = Piranhas

local RepStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")

local Trove = require(RepStorage.Packages.Trove)
local TableUtil = require(RepStorage.Packages.TableUtil)

local PiranhaComponent = require(script.Parent.Parent.Parent.Components.PiranhaComponent)
local Ragdoll = require(ServerScriptService.Server.Classes.Ragdoll)

Piranhas.AvailableInstances = {
    game.Workspace.PlaceModels:FindFirstChild("Piranhas")
}

function Piranhas:SetupUpdateSignal()
    self._trove:Connect(self.SendPSignal, function(plr, cf, cmd)
        for _, pComponent in ipairs(self.Piranhas) do
            if pComponent.FollowBehaviour.FollowingPlr == plr then
                pComponent:UpdateSvInstance(cf, cmd)
            end
        end
    end)
end

function Piranhas:SpawnPiranhas(amt)
    for i = 1, amt do
        local inst = RepStorage.Assets.Piranha:Clone()
        inst.Parent = self.Instance.Fish
    
        CollectionService:AddTag(inst, "Piranha")
    
        PiranhaComponent:WaitForInstance(inst):await() -- wait for component to fully load

        table.insert(self.Piranhas, PiranhaComponent:FromInstance(inst))
        print(self.Piranhas)

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
        StartPAmount = 1,

        _trove = Trove.new()
    }), Piranhas)

    self.SendPSignal = self.MachineFuncs.CreateGlobalSignal("MoveRepl", "SendPiranha")

    self:SetupUpdateSignal()

    return self
end

return Piranhas