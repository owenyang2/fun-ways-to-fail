--creates a new quicksand obj
local RunService = game:GetService("RunService")
local RepStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")

local Component = require(RepStorage.Packages.Component)
local Trove = require(RepStorage.Packages.Trove)

local MachineFuncs = require(ServerScriptService.Server.Other.MachineFunctions)
local Ragdoll = require(script.Parent.Ragdoll)

local ServerComm = require(RepStorage.Packages.Comm).ServerComm
local serverComm = ServerComm.new(RepStorage, "Quicksand")

local Quicksand = {}
Quicksand.__index = Quicksand

function Quicksand:Sink(chr)
    if self.SinkingChrs[chr] then return end
        
    self.SinkingChrs[chr] = "temp" -- store a temp value to make sure it doesn't run again

    local ragdoll = Ragdoll.GlobalRagdolls[game.Players:GetPlayerFromCharacter(chr)]
    ragdoll:Toggle(false)
    ragdoll.CanRagdoll = false

    chr.Animate.Disabled = true

    for _, animTrack in ipairs(chr.Humanoid.Animator:GetPlayingAnimationTracks()) do
        animTrack:Stop()
    end

    chr.HumanoidRootPart.Anchored = true

    self.StartSinkSignal:Fire(game.Players:GetPlayerFromCharacter(chr))
    
    local chrHeight = (chr.Humanoid.HipHeight + chr.HumanoidRootPart.Size.Y / 2) * 2
    local targetCF = chr.HumanoidRootPart.CFrame - Vector3.new(0, chrHeight, 0)
    
    self.SinkingChrs[chr] = task.spawn(function()
        while math.abs(chr.HumanoidRootPart.Position.Y - targetCF.Position.Y) > 0.1 do
            chr.HumanoidRootPart.CFrame += Vector3.new(0, self.Config.SinkIncrement, 0)
            task.wait(self.Config.SinkDelay)
        end
    end)

    chr.Humanoid.Died:Connect(function()
        print("died")
        self.SinkingChrs[chr] = nil
    end)
end

function Quicksand:Escape(chr)
    if self.SinkingChrs[chr] then
        chr.HumanoidRootPart.Position += Vector3.new(0, 1, 0)
    end
end

function Quicksand:Enable()
    self._trove:Connect(RunService.Heartbeat, function(dt) -- if player touches quicksand, start sinking them
        local parts = game.Workspace:GetPartsInPart(self.Instance, MachineFuncs.GetHitboxParams())

        local doneChrs = {} -- characters who already updated stay length

        for _, part in ipairs(parts) do
            local chr = part.Parent
            local plr = game.Players:GetPlayerFromCharacter(chr)
            if not plr or table.find(doneChrs, chr) then return end
            
            table.insert(doneChrs, chr)

            task.spawn(function() -- prevent thread pausing
                self:Sink(chr)
            end)
        end
    end)

    self._trove:Connect(serverComm:CreateSignal("QuicksandEscape"), function(plr)
        self:Escape(plr.Character)
    end)
end

function Quicksand:Disable()
    self._trove:Clean()
end

function Quicksand.new(inst, config)
    local newQuicksand = setmetatable({
        Instance = inst,

        Config = config or {
            SinkIncrement = -0.05, -- how many studs to sink per heartbeat
            SinkDelay = 0, -- 0 is every heartbeat, how long to delay for each step
        },

        SinkingChrs = {},
        _trove = Trove.new(),
        StartSinkSignal = serverComm:CreateSignal("StartSinking")
    }, Quicksand)
        
    return newQuicksand
end

return Quicksand