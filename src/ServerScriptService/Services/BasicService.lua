local RepStorage = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")

local Ragdoll = require(script.Parent.Parent.Classes.Ragdoll)

local Knit = require(RepStorage.Packages.Knit)
local Signal = require(RepStorage.Packages.Signal)

local BasicService = Knit.CreateService {
    Name = "BasicService",
    Client = {
        PlayAnim = Knit.CreateSignal()
    }
}

function BasicService.Client:SprintToggle(plr, toggle)
    if not plr.Character then return end
    
    if toggle then
        plr.Character.Humanoid.WalkSpeed = self.Server.SprintWalkSpeed
    else
        plr.Character.Humanoid.WalkSpeed = game.StarterPlayer.CharacterWalkSpeed
    end
end

function BasicService:DisableLayeredClothing()
    local disabledLayeredClothing = {
        Enum.AccessoryType.Jacket,
        Enum.AccessoryType.Shorts,
        Enum.AccessoryType.Eyebrow,
        Enum.AccessoryType.Pants,
        Enum.AccessoryType.Shirt,
        Enum.AccessoryType.TShirt,
        Enum.AccessoryType.Eyelash,
        Enum.AccessoryType.Sweater,
        Enum.AccessoryType.Unknown,
        Enum.AccessoryType.LeftShoe,
        Enum.AccessoryType.RightShoe,
        Enum.AccessoryType.TeeShirt,
        Enum.AccessoryType.DressSkirt        
    }

    game.Players.PlayerAdded:Connect(function(plr)
        plr.CharacterAdded:Connect(function(chr)
            for _, acc in ipairs(chr:GetChildren()) do
                if acc:IsA("Accessory") and table.find(disabledLayeredClothing, acc.AccessoryType) then
                    acc:Destroy()
                end
            end
        end)
    end)
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

function BasicService:PlayAnim(plr, id, animProperties)
    self.Client.PlayAnim:Fire(plr, id, animProperties)
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
    self:DisableLayeredClothing()
end

return BasicService