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
            -- bought
        end
    end
end

function ShopService:Setup()
    MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(plr, passID, success)
        self:GamepassPurchased(plr, passID, success)
    end)
end

function ShopService.Client:GetGamepasses(plr)
    print(self.Server.Gamepasses)
    return self.Server.Gamepasses
end

function ShopService:SetupGamepassList(ids)
    for _, id in ipairs(ids) do
        table.insert(self.Gamepasses, MarketplaceService:GetProductInfo(id, Enum.InfoType.GamePass))
    end
end

function ShopService:KnitStart()
    self.ProfileManager = Knit.GetService("ProfileManager")

    self.Gamepasses = {}
    self:SetupGamepassList({
        663003959,
        663875014
    })

    self.UnclaimedRewards = {}
    
    self:Setup()
end

return ShopService