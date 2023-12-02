local RepStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local Knit = require(RepStorage.Packages.Knit)

local ShopService = Knit.CreateService {
    Name = "ShopService",
    Client = {}
}

function ShopService:SuccessfullyPurchasedGamepass(plr, passID)
    local data = self.ProfileManager:GetData(plr)
    local inDS = table.find(data.GamepassesOwned, passID)

    if not inDS then -- double check
        self.ProfileManager:InsertData(plr, "GamepassesOwned", passID)
    end
end

function ShopService:GamepassPurchased(plr, passID, success)
    for _, gp in ipairs(self.GamepassInfo) do
        if gp.TargetId == passID and success then
            -- successfully bought
            self:SuccessfullyPurchasedGamepass(plr, passID)
            self.BasicService:GiveSpawnPerks(plr)
        end
    end
end

function ShopService:Setup()
    MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(plr, passID, success)
        self:GamepassPurchased(plr, passID, success)
    end)
end

function ShopService:GetGamepasses()
    return self.GamepassInfo
end

function ShopService.Client:GetGamepasses()
    return self.Server:GetGamepasses()
end

function ShopService:GetGamepassNameToID(name)
    return self.gpNameToID[name]
end

function ShopService:SetupGamepassList(ids)
    for _, id in ipairs(ids) do
        table.insert(self.GamepassInfo, MarketplaceService:GetProductInfo(id, Enum.InfoType.GamePass))

        -- make sure each id has an appropriate key name assigned to it
        local found = false
        for name, checkId in pairs(self.gpNameToID) do -- kinda slow tbf, but im lazy and searching through a key paired dict efficiently is annoying
            if id == checkId then
                found = true
                break
            end
        end

        if not found then
            warn("No corresponding key name assigned to gamepass id: " .. tostring(id))
        end
    end
end

function ShopService:KnitStart()
    self.ProfileManager = Knit.GetService("ProfileManager")
    self.BasicService = Knit.GetService("BasicService")
    
    self.gpNameToID = { -- have to do it manually since gamepassids must be an ordered list
        Sprint = 663003959, -- sprint
        OPHammer = 663875014 -- op hammer
    }

    self.GamepassInfo = {}
    self:SetupGamepassList({
        663003959, -- sprint
        663875014 -- op hammer
    })


    self.UnclaimedRewards = {}
    
    self:Setup()
end

return ShopService