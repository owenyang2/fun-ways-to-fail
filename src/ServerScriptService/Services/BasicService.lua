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

function BasicService:SetupDeathCounter()
    game.Players.PlayerAdded:Connect(function(plr)
        plr.CharacterAdded:Connect(function(chr)
            chr.Humanoid.Died:Connect(function()
                plr:WaitForChild("leaderstats").Deaths.Value += 1
            end)
        end)
    end)
end

function BasicService.Client:GetLClothingSize(plr)
    local sizes = {}

    for _, clothing in ipairs(plr.Character:GetChildren()) do
        if clothing:IsA("Accessory") then
            sizes[clothing.Name] = clothing.Handle.Size
        end
    end

    return sizes
end

function BasicService:KnitStart()
    self.SprintWalkSpeed = 30
    self:SetupDeathCounter()
end

return BasicService