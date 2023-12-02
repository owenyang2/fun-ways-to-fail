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
    
    local origWalkSpeed = game.StarterPlayer.CharacterWalkSpeed
    local sprintWalkSpeed = self.Server.SprintWalkSpeed

    if self.Server.DoubleSprint[plr] then
        sprintWalkSpeed = self.Server.SprintWalkSpeed * 2
    end

    if toggle then
        plr.Character.Humanoid.WalkSpeed = sprintWalkSpeed
    else
        plr.Character.Humanoid.WalkSpeed = origWalkSpeed
    end
end

function BasicService:GiveSpawnPerks(plr)
    print("update!")
    local updatedData = self.ProfileManager:GetData(plr)
    if table.find(updatedData.GamepassesOwned, self.ShopService:GetGamepassNameToID("OPHammer")) then -- op hammer gamepass
        -- give op hammer
    end

    print(self.DoubleSprint, updatedData.GamepassesOwned)

    if not self.DoubleSprint[plr] and table.find(updatedData.GamepassesOwned, self.ShopService:GetGamepassNameToID("Sprint")) then -- sprint gamepass
        print("a")
        self.DoubleSprint[plr] = true
    end

    for name, owned in pairs(updatedData.PermanentItems) do
        if not owned then continue end

        if name == "BoinkHammer" then
            if not self.ToolService:CheckHoldingToolWithTag(plr, self.ToolService:ToolToTag("BoinkHammer")) then
                local newTool = RepStorage.Assets.Tools:FindFirstChild("Cartoony Boink Hammer"):Clone()
                newTool.Parent = plr.Backpack
            end
        end
    end
end

function BasicService:ConfirmGamepasses(plr)
    local gamepasses = self.ShopService:GetGamepasses()
    local data = self.ProfileManager:GetData(plr)
    for _, gp in ipairs(gamepasses) do
        local hasPass = false

        local succ, msg = pcall(function() -- maybe check datastore instead of api call
            hasPass = MarketplaceService:UserOwnsGamePassAsync(plr.UserId, gp.TargetId)
        end)
    
        if not succ then
            warn("Error while checking if player has pass: " .. tostring(msg))
            return
        end

        local inDS = table.find(data.GamepassesOwned, gp.TargetId)

        print("DEBUG: ", hasPass, inDS)

        if hasPass and not inDS then
            self.ProfileManager:InsertData(plr, "GamepassesOwned", gp.TargetId)
        elseif not hasPass and inDS then
            self.ProfileManager:RemoveData(plr, "GamepassesOwned", gp.TargetId)
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
        -- setup tables
        self.PlayerTroves[plr] = {}

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

            self:GiveSpawnPerks(plr)
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
    self.ToolService = Knit.GetService("ToolService")

    self.PlayerTroves = {}

    self.DoubleSprint = {}

    self:SetupPlayerJoin()
end

return BasicService