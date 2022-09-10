local Volcano = {}
Volcano.__index = Volcano

local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Trove = require(RepStorage.Packages.Trove)

Volcano.AvailableInstances = { -- available presses
    game.Workspace.PlaceModels:FindFirstChild("Volcano")
}

function Volcano:Burn(plr)
    table.insert(self.BurningPlrs, plr)

    for _, bodyColor in ipairs(self.BodyColors) do
        local tween = TweenService:Create(plr.Character["Body Colors"], self.Config.TurnRedInfo, {[bodyColor] = self.Config.TurnRedColor})
        tween:Play()
    end

    task.wait(self.Config.TurnRedInfo.Time + self.Config.ChangeInterval)

    for _, bodyColor in ipairs(self.BodyColors) do
        local tween = TweenService:Create(plr.Character["Body Colors"], self.Config.TurnBlackInfo, {[bodyColor] = self.Config.TurnBlackColor})
        tween:Play()
    end

    task.wait(self.Config.TurnBlackInfo.Time)

    plr.Character.Humanoid:TakeDamage(plr.Character.Humanoid.Health)
    table.remove(self.BurningPlrs, table.find(self.BurningPlrs, plr))
end

function Volcano:Enable()
    local chrTbl = {}

    self._trove:Connect(RunService.Heartbeat, function(dt)
        local parts = game.Workspace:GetPartsInPart(self.Instance.Lava, self:GetHitboxParams())

        local doneChrs = {} -- characters who already done action

        for _, part in ipairs(parts) do
            local chr = part.Parent
            local plr = game.Players:GetPlayerFromCharacter(chr)
            if not plr or table.find(doneChrs, chr) or table.find(self.BurningPlrs, plr) then return end
            
            table.insert(doneChrs, chr)

            if not chrTbl[chr] then chrTbl[chr] = {StayLength = 0} continue end

            chrTbl[chr].StayLength += dt

            if chrTbl[chr].StayLength > self.Config.BurnDelay then
                self:Burn(plr)
            end
        end

        for chr, _ in pairs(chrTbl) do -- if left volcano
            if not table.find(doneChrs, chr) then
                chrTbl[chr] = nil
            end
        end
    end)
end

function Volcano:Disable()
    self._trove:Clean()
end

function Volcano:Start()
    self:Enable()    
end

function Volcano.new()
    local newInst = Volcano:GetAvailableInst(Volcano.AvailableInstances)
    if not newInst then return end

    local Volcano = setmetatable({
        Instance = newInst,
        
        _trove = Trove.new(),

        Config = {
            BurnDelay = 1, -- how long until player starts burning
            
            ChangeInterval = 1,

            TurnRedInfo = TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
            TurnBlackInfo = TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),

            TurnRedColor = Color3.fromRGB(200, 0, 0),
            TurnBlackColor = Color3.fromRGB(0, 0, 0)
        },

        BodyColors = {
            "HeadColor3",
            "LeftArmColor3",
            "RightArmColor3",
            "LeftLegColor3",
            "RightLegColor3",
            "TorsoColor3"
        },

        BurningPlrs = {}
    }, Volcano)

    return Volcano
end

return Volcano