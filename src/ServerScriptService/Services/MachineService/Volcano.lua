local Volcano = {}
Volcano.__index = Volcano

local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Trove = require(RepStorage.Packages.Trove)

Volcano.AvailableInstances = { -- available presses
    game.Workspace.PlaceModels:FindFirstChild("Volcano")
}

local function callTweenFunc(self, func) -- call a function for all tweens in passed table
    for _, tween in ipairs(self) do
        if not tween:IsA("Tween") then continue end
        tween[func](tween) -- basically tween:func()
    end
end

function Volcano:TurnBlack(chr)
    local info = self.BurningChrs[chr]
    
    if info.State ~= "TurningRed" and not string.find(info.State, "Paused") then return end

    info.State = "TurningBlack"
    info[chr].TurnBlackTweens:CallFunc("Play")
end

function Volcano:TurnRed(chr)
    local info = self.BurningChrs[chr]
    
    if info.State ~= "NotBurning" and not string.find(info.State, "Paused") then return end

    info.State = "TurningRed"
    info[chr].TurnRedTweens:CallFunc("Play")
end

function Volcano:Burn(chr)
    local info = self.BurningChrs[chr]

    if info and string.find(info.State, "Paused") then
        task.spawn(function()
            self:ResumeBurn(chr)
        end)
        return
    end

    self.BurningChrs[chr] = {
        TurnRedTweens = {
            CallFunc = callTweenFunc,
        },
        
        TurnBlackTweens = {
            CallFunc = callTweenFunc
        },

        State = "NotBurning", -- NotBurning (start), TurningRed, TurningBlack, Paused
        _trove = Trove.new()
    }

    info._trove:Connect(chr.Humanoid.Died, function() -- should auto disconnect bc when character dies, humanoid is destroyed and gced
        info._trove:Destroy() -- make sure all connections are properly cleaned up
        self.BurningChrs[chr] = nil -- all data should be auto gced once out of scope but just in case i guess
    end)

    for _, bodyColor in ipairs(self.BodyColors) do
        table.insert(info.TurnRedTweens,
            TweenService:Create(chr.Character["Body Colors"], self.Config.TurnRedInfo, {[bodyColor] = self.Config.TurnRedColor})
        )

        table.insert(info.TurnBlackTweens,
            TweenService:Create(chr.Character["Body Colors"], self.Config.TurnBlackInfo, {[bodyColor] = self.Config.TurnBlackColor})
        )
    end

    info._trove:Connect(info.TurnRedTweens[1].Completed, function(playbackState) -- get random tween (since they all finish at the same time)
        if playbackState == Enum.PlaybackState.Completed then -- if not paused or cancelled
            task.wait(self.Config.ChangeInterval)
            self:TurnBlack(chr)
        end
    end)

    info._trove:Connect(info.TurnBlackTweens[1].Completed, function(playbackState) -- get random tween (since they all finish at the same time)
        if playbackState == Enum.PlaybackState.Completed then -- if not paused or cancelled
            task.wait(self.Config.ChangeInterval)
            chr.Character.Humanoid:TakeDamage(chr.Character.Humanoid.Health)
        end
    end)
end

function Volcano:ResumeBurn(chr)
    local info = self.BurningChrs[chr]

    if info.State == "PausedTurningRed" then
        self:TurnRed(chr)
    elseif info.State == "PausedTurningBlack" then
        self:TurnBlack(chr)
    end
end

function Volcano:StopBurn(chr)
    local info = self.BurningChrs[chr]

    if info.State == "TurningRed" then
        info.TurnRedTweens:CallFunc("Pause")
    elseif info.State == "TurningBlack" then
        info.TurnBlackTweens:CallFunc("Pause")
    end

    info.State = "Paused" .. info.State -- get an identifiyable key to know which stage to return to
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
                task.spawn(function() -- prevent thread pausing
                    self:Burn(chr)
                end)
            end
        end

        for chr, _ in pairs(chrTbl) do -- if left volcano
            if not table.find(doneChrs, chr) then
                chrTbl[chr] = nil
                task.spawn(function() -- prevent thread pausing
                    self:StopBurn(chr)
                end)
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

        BurningChrs = {}
    }, Volcano)

    return Volcano
end

return Volcano