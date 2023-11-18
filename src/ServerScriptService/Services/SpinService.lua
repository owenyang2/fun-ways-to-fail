local RepStorage = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")

local Ragdoll = require(script.Parent.Parent.Classes.Ragdoll)

local Knit = require(RepStorage.Packages.Knit)
local Signal = require(RepStorage.Packages.Signal)

local SpinService = Knit.CreateService {
    Name = "SpinService",
    Client = {}
}

function SpinService:KnitStart()
    
end

return SpinService