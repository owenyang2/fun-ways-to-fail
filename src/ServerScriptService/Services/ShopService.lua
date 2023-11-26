local RepStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local Knit = require(RepStorage.Packages.Knit)

local ShopService = Knit.CreateService {
    Name = "ShopService",
    Client = {}
}

function ShopService:GamepassPurchased(plr, passID, success)
    for _, gp in ipairs(self.Gamepasses) do
        if gp.ID == passID and success then
            -- successfully bought
            self.BasicService:ConfirmGamepass(plr)
            self.BasicService:GiveGamepassPerks()
        end
    end
end

function ShopService:Setup()
    MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(plr, passID, success)
        self:GamepassPurchased(plr, passID, success)
    end)
end

function ShopService:GetGamepasses()
    return self.Gamepasses
end

function ShopService.Client:GetGamepasses()
    return self.Server:GetGamepasses()
end

function ShopService:SetupGamepassList(ids)
    for _, id in ipairs(ids) do
        table.insert(self.Gamepasses, MarketplaceService:GetProductInfo(id, Enum.InfoType.GamePass))
    end
end

function ShopService:KnitStart()
    self.ProfileManager = Knit.GetService("ProfileManager")
    self.BasicService = Knit.GetService("BasicService")
    
    self.Gamepasses = {}
    self:SetupGamepassList({
        663003959, -- sprint
        663875014 -- op hammer
    })

    self.UnclaimedRewards = {}
    
    self:Setup()
end

return ShopService