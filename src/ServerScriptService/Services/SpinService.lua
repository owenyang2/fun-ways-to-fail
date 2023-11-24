local RepStorage = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")

local Ragdoll = require(script.Parent.Parent.Classes.Ragdoll)

local Knit = require(RepStorage.Packages.Knit)
local Signal = require(RepStorage.Packages.Signal)

local SpinService = Knit.CreateService {
    Name = "SpinService",
    Client = {}
}

function SpinService.Client:GenReward(plr)
    if self.Server.UnclaimedRewards[plr] then return end -- player hasnt received reward from last spin
    local sectionNum = math.random(1, 100)

    local currBounds = 0

    for rewardNum, data in ipairs(self.Sections) do
        currBounds += data.Percent * 100
        if sectionNum <= currBounds then -- in the correct section, since within the bounds
            self.Server.UnclaimedRewards[plr] = rewardNum
            return data.Reward
        end
    end
end

function SpinService.Client:GetReward(plr)
    local rewardNum = self.Server.UnclaimedRewards[plr]
    self.Server.UnclaimedRewards[plr] = nil

    local reward = self.Sections[rewardNum]
    if reward.Type == "Normal" then
        self.Server.ProfileManager:IncrementData(plr, reward.StatIncrease[1], reward.StatIncrease[2])
    elseif reward.Type == "Custom" then
        if reward.Reward == "UGC Item" then
            -- give ugc
        elseif reward.Reward == "Boink Hammer" then
            -- give hammer
        end
    end
end

function SpinService.Client:GetSections(plr)
    return self.Server.Sections
end

function SpinService:KnitStart()
    self.ProfileManager = Knit.GetService("ProfileManager")

    self.Sections = {
        -- Types: Normal (edits datastore), Custom (make custom function to reward)
        -- must add up to 100%
        {Reward = "UGC Item", Percent = 0.01, Type = "Custom"},
        {Reward = "Cartoony Boink Hammer", Percent = 0.05, Type = "Custom"},
        {Reward = "100 Deaths", Percent = 0.1, Type = "Normal", StatIncrease = {"Deaths", 100}},
        {Reward = "50 Deaths", Percent = 0.15, Type = "Normal", StatIncrease = {"Deaths", 50}},
        {Reward = "30 Deaths", Percent = 0.19, Type = "Normal", StatIncrease = {"Deaths", 30}},
        {Reward = "10 Deaths", Percent = 0.5, Type = "Normal", StatIncrease = {"Deaths", 10}}
    }

    self.UnclaimedRewards = {}
end

return SpinService