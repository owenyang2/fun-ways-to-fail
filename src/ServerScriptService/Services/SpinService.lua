local RepStorage = game:GetService("ReplicatedStorage")

local Knit = require(RepStorage.Packages.Knit)

local SpinService = Knit.CreateService {
    Name = "SpinService",
    Client = {}
}

function SpinService.Client:GenReward(plr)
    if self.Server.UnclaimedRewards[plr] then return end -- player hasnt received reward from last spin
    local sectionNum = math.random(1, 100)

    local currBounds = 0

    for rewardNum, data in pairs(self.Server.Sections) do
        currBounds += data.Percent * 100
        if sectionNum <= currBounds then -- in the correct section, since within the bounds
            self.Server.UnclaimedRewards[plr] = rewardNum
            return rewardNum
        end
    end
end

function SpinService.Client:ClaimReward(plr)
    local rewardNum = self.Server.UnclaimedRewards[plr]
    self.Server.UnclaimedRewards[plr] = nil

    local reward = self.Server.Sections[rewardNum]
    if reward.Type == "Normal" then
        self.Server.ProfileManager:IncrementData(plr, reward.StatIncrease[1], reward.StatIncrease[2])
    elseif reward.Type == "Custom" then
        if reward.Reward == "UGC Item" then
            -- give ugc
        elseif reward.Reward == "Boink Hammer" then
            -- give hammer
            local updatedPermItems = self.Server.ProfileManager:GetData(plr).PermanentItems
            updatedPermItems.BoinkHammer = true

            self.Server.ProfileManager:WriteData(plr, "PermanentItems", updatedPermItems)
            
            self.Server.BasicService:GiveSpawnPerks(plr)
        end
    end
end

function SpinService.Client:GetSections(plr)
    return self.Server.Sections
end

function SpinService:KnitStart()
    self.ProfileManager = Knit.GetService("ProfileManager")
    self.BasicService = Knit.GetService("BasicService")

    self.Sections = {
        -- Types: Normal (edits datastore), Custom (make custom function to reward)
        -- must add up to 100%
        {Reward = "UGC Item", Percent = 0.01, Type = "Custom", Image = "http://www.roblox.com/asset/?id=15151374676"},
        {Reward = "Cartoony Boink Hammer", Percent = 0.05, Type = "Custom", Image = "rbxassetid://15525830232"},
        {Reward = "100 Deaths", Percent = 0.1, Type = "Normal", StatIncrease = {"Deaths", 100}, Image = "rbxassetid://15525753578"},
        {Reward = "50 Deaths", Percent = 0.15, Type = "Normal", StatIncrease = {"Deaths", 50}, Image = "rbxassetid://15525751671"},
        {Reward = "30 Deaths", Percent = 0.29, Type = "Normal", StatIncrease = {"Deaths", 30}, Image = "rbxassetid://15525750270"},
        {Reward = "10 Deaths", Percent = 0.40, Type = "Normal", StatIncrease = {"Deaths", 10}, Image = "rbxassetid://15525748283"}
    }

    self.UnclaimedRewards = {}
end

return SpinService