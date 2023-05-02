local RepStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

local Knit = require(RepStorage.Packages.Knit)
local Trove = require(RepStorage.Packages.Trove)

local ClientComm = require(RepStorage.Packages.Comm).ClientComm
local clientComm = ClientComm.new(RepStorage, false, "Food")
local comm = clientComm:BuildObject()

local PiranhaController = Knit.CreateController {
    Name = "PiranhaController"
}

function PiranhaController:SpawnPiranhas()
    local template = RepStorage.Assets.Piranha

    for i = 1, self.PiranhasToSpawn do
        local inst = template:Clone()
        inst.Parent = self.Instance.Fish

        CollectionService:AddTag(inst, "Piranha")

        --local p = PiranhaClass.new(inst, self.Instance)

        table.insert(self.Piranhas, inst)
    end
end

function PiranhaController:KnitStart()
    self.Player = game.Players.LocalPlayer
    self._trove = Trove.new()
    self.Instance = game.Workspace.PlaceModels.Piranhas

    self.Piranhas = {}
    self.PiranhasToSpawn = 30

    self:SpawnPiranhas()
end

return PiranhaController