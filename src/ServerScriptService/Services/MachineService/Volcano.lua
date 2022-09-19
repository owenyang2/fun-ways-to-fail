local Volcano = {}
Volcano.__index = Volcano

local RepStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

local Trove = require(RepStorage.Packages.Trove)
local TableUtil = require(RepStorage.Packages.TableUtil)
local Promise = require(RepStorage.Packages.Promise)

local Quicksand = require(ServerScriptService.Server.Components.Quicksand)

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
    if self.BurningChrs[chr].State ~= "TurningRed" and not string.find(self.BurningChrs[chr].State, "Paused") then print("no") return end

    self.BurningChrs[chr].State = "TurningBlack"
    self.BurningChrs[chr].TurnBlackTweens:CallFunc("Play")
end

function Volcano:TurnRed(chr)    
    if self.BurningChrs[chr].State ~= "NotBurning" and not string.find(self.BurningChrs[chr].State, "Paused") then return end

    self.BurningChrs[chr].State = "TurningRed"
    self.BurningChrs[chr].TurnRedTweens:CallFunc("Play")
end

function Volcano:Burn(chr)
    if self.BurningChrs[chr] and self.BurningChrs[chr].State == "Dead" then return end

    --  this function is mostly just setup
    if self.BurningChrs[chr] then
        if string.find(self.BurningChrs[chr].State, "Paused") then
            task.spawn(function()
                self:ResumeBurn(chr)
            end)    
        end
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

    self.BurningChrs[chr]._trove:Connect(chr.Humanoid.Died, function() -- should auto disconnect bc when character dies, humanoid is destroyed and gced
        self.BurningChrs[chr].State = "Dead"
    end)

    self.BurningChrs[chr]._trove:Connect(game.Players:GetPlayerFromCharacter(chr).CharacterAdded, function()
        self.BurningChrs[chr]._trove:Destroy() -- make sure all connections are properly cleaned up
        self.BurningChrs[chr] = nil -- all data should be auto gced once out of scope but just in case i guess
    end)

    for _, bodyColor in ipairs(self.BodyColors) do
        table.insert(self.BurningChrs[chr].TurnRedTweens,
            TweenService:Create(chr["Body Colors"], self.Config.TurnRedInfo, {[bodyColor] = self.Config.TurnRedColor})
        )

        table.insert(self.BurningChrs[chr].TurnBlackTweens,
            TweenService:Create(chr["Body Colors"], self.Config.TurnBlackInfo, {[bodyColor] = self.Config.TurnBlackColor})
        )
    end

    self.BurningChrs[chr]._trove:Connect(self.BurningChrs[chr].TurnRedTweens[1].Completed, function(playbackState) -- get random tween (since they all finish at the same time)
        if playbackState == Enum.PlaybackState.Completed then -- if not paused or cancelled
            task.wait(self.Config.ChangeInterval)
            self:TurnBlack(chr)
        end
    end)

    self.BurningChrs[chr]._trove:Connect(self.BurningChrs[chr].TurnBlackTweens[1].Completed, function(playbackState) -- get random tween (since they all finish at the same time)
        if playbackState == Enum.PlaybackState.Completed then -- if not paused or cancelled
            task.wait(self.Config.ChangeInterval)            
            for _, part in ipairs(chr:GetDescendants()) do
                if not part:IsA("BasePart") then continue end
                part.Anchored = true
            end
            chr.Head.Neck:Destroy()
            --chr.Humanoid:TakeDamage(chr.Humanoid.Health)
        end
    end)

    self:TurnRed(chr)
end

function Volcano:ResumeBurn(chr)
    if not self.BurningChrs[chr] or self.BurningChrs[chr].State == "Dead" then return end

    print("resume")

    if self.BurningChrs[chr].State == "PausedTurningRed" then
        self:TurnRed(chr)
    elseif self.BurningChrs[chr].State == "PausedTurningBlack" then
        self:TurnBlack(chr)
    end
end

function Volcano:StopBurn(chr)
    if not self.BurningChrs[chr] or self.BurningChrs[chr].State == "Dead" then return end
    if string.find(self.BurningChrs[chr].State, "Paused") then return end

    print("pause", self.BurningChrs[chr].State)

    if self.BurningChrs[chr].State == "TurningRed" then
        self.BurningChrs[chr].TurnRedTweens:CallFunc("Pause")
    elseif self.BurningChrs[chr].State == "TurningBlack" then
        self.BurningChrs[chr].TurnBlackTweens:CallFunc("Pause")
    end

    self.BurningChrs[chr].State = "Paused" .. self.BurningChrs[chr].State -- get an identifiyable key to know which stage to return to
end

function Volcano:Enable()
    local chrTbl = {}

    Quicksand:WaitForInstance(self.Instance.Lava):andThen(function(componentInst)
        componentInst:Enable()
    end):catch(function(err)
        warn(tostring(err))
    end)
    
    self._trove:Connect(RunService.Heartbeat, function(dt)
        local parts = game.Workspace:GetPartsInPart(self.Instance.Lava, self.MachineFuncs.GetHitboxParams())

        local doneChrs = {} -- characters who already updated stay length

        for _, part in ipairs(parts) do
            local chr = part.Parent
            local plr = game.Players:GetPlayerFromCharacter(chr)
            if not plr or table.find(doneChrs, chr) then return end
            
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

    Quicksand:WaitForInstance(self.Instance.Lava):andThen(function(componentInst)
        componentInst:Disable()
    end):catch(function(err)
        warn(tostring(err))
    end)
end

function Volcano:Start()
    self:Enable()
end

function Volcano.new(baseTbl)
    local newInst = baseTbl.MachineFuncs.GetAvailableInst(Volcano.AvailableInstances)
    if not newInst then return end

    local newVolcano = setmetatable(TableUtil.Assign(baseTbl, {
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
    }), Volcano)

    CollectionService:AddTag(newInst.Lava, Quicksand.Tag)

    return newVolcano
end

return Volcano