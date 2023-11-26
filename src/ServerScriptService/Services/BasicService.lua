local RepStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local Knit = require(RepStorage.Packages.Knit)
local Trove = require(RepStorage.Packages.Trove)

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

function BasicService:GiveGamepassPerks(plr)
    local updatedData = self.ProfileManager:GetData(plr)
    if table.find(updatedData.GamepassesOwned, 663875014) then -- op hammer gamepass
        -- give op hammer
    end
end

function BasicService:ConfirmGamepasses(plr)
    local gamepasses = self.ShopService:GetGamepasses()
    local data = self.ProfileManager:GetData(plr)
    for _, gp in ipairs(gamepasses) do
        local hasPass = false

        local succ, msg = pcall(function() -- maybe check datastore instead of api call
            hasPass = MarketplaceService:UserOwnsGamePassAsync(plr.UserId, gp.ProductId)
        end)
    
        if not succ then
            warn("Error while checking if player has pass: " .. tostring(msg))
            return
        end

        print(data)
        local inDS = table.find(data.GamepassesOwned, gp.ProductId)

        if hasPass and not inDS then
            self.ProfileManager:InsertData(data.GamepassesOwned, gp.ProductId)
        elseif not hasPass and inDS then
            self.ProfileManager:RemoveData(data.GamepassesOwned, gp.ProductId)
        end
    end
end

function BasicService:SetupPlayerJoin()
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
        repeat task.wait(0.1) until self.ProfileManager:IsLoaded(plr)

        self.PlayerTroves[plr].PlaytimeTrove = Trove.new()

        -- setup player increase
        self.PlayerTroves[plr].PlaytimeTrove:Add(task.spawn(function()
            while true do
                self.ProfileManager:IncrementData(plr, "Playtime", 1)
                task.wait(1)
            end
        end))

        -- confirm gamepasses
        self:ConfirmGamepasses(plr)

        plr.CharacterAdded:Connect(function(chr)
            -- setup death counter
            chr.Humanoid.Died:Connect(function()
                self.ProfileManager:IncrementData(plr, "Deaths", 1)
            end)

            -- disable layered clothing
            for _, acc in ipairs(chr:GetChildren()) do
                if acc:IsA("Accessory") and table.find(disabledLayeredClothing, acc.AccessoryType) then
                    acc:Destroy()
                end
            end

            self:GiveGamepassPerks(plr)
        end)
    end)

    game.Players.PlayerRemoving:Connect(function(plr)
        self.PlayerTroves[plr].PlaytimeTrove:Destroy()
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

    self.ProfileManager = Knit.GetService("ProfileManager")
    self.ShopService = Knit.GetService("ShopService")

    self.PlayerTroves = {}

    self:SetupPlayerJoin()
end

return BasicService