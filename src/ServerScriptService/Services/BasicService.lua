local RepStorage = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")

local Ragdoll = require(script.Parent.Parent.Classes.Ragdoll)

local Knit = require(RepStorage.Packages.Knit)

local BasicService = Knit.CreateService {
    Name = "BasicService",
    Client = {}
}

function BasicService.Client:SprintToggle(plr, toggle)
    if not plr.Character then return end
    
    if toggle then
        plr.Character.Humanoid.WalkSpeed = self.Server.SprintWalkSpeed
    else
        plr.Character.Humanoid.WalkSpeed = game.StarterPlayer.CharacterWalkSpeed
    end
end

function BasicService:KnitStart()
    self.SprintWalkSpeed = 30
end

return BasicService