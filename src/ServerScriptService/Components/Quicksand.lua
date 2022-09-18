--creates a new quicksand obj
local RunService = game:GetService("RunService")
local RepStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")

local Component = require(RepStorage.Packages.Component)
local Trove = require(RepStorage.Packages.Trove)

local MachineFuncs = require(ServerScriptService.Server.Other.MachineFunctions)
local Ragdoll = require(ServerScriptService.Server.Classes.Ragdoll)

local Quicksand = Component.new {
    Tag = "Quicksand"
}

function Quicksand:Sink(chr)
    local ragdoll = Ragdoll.GlobalRagdolls[game.Players:GetPlayerFromCharacter(chr)]
    ragdoll:Toggle(false)
    ragdoll.CanRagdoll = false

    chr.Humanoid.WalkSpeed = 0
    chr.Humanoid.JumpHeight = 0

    local yPos = self.Instance.Position.Y + (self.Instance.Size.Y / 2) - chr.Humanoid.HipHeight + (chr.HumanoidRootPart.Size.Y / 2)

    local targetCF = CFrame.new(
        chr.HumanoidRootPart.Position.X, yPos, chr.HumanoidRootPart.Position.Z
    )

    local info = TweenInfo.new(self.Config.SinkTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    local tween = TweenService:Create(chr.HumanoidRootPart, info, {CFrame = targetCF})
    self.SinkingChrs[chr] = tween
    tween:Play()
end

function Quicksand:Enable()
    local chrTbl = {}

    self._trove:Connect(RunService.Heartbeat, function(dt) -- if player touches quicksand, start sinking them
        local parts = game.Workspace:GetPartsInPart(self.Instance, MachineFuncs.GetHitboxParams())

        local doneChrs = {} -- characters who already updated stay length

        for _, part in ipairs(parts) do
            local chr = part.Parent
            local plr = game.Players:GetPlayerFromCharacter(chr)
            if not plr or table.find(doneChrs, chr) then return end
            
            table.insert(doneChrs, chr)
            table.insert(chrTbl, chr)

            task.spawn(function() -- prevent thread pausing
                self:Sink(chr)
            end)
        end
    end)
end

function Quicksand:Disable()
    self._trove:Clean()
end

function Quicksand:Construct(config)
    self.Config = config or {
        SinkTime = 2 -- how many seconds for character to be completely submerged and die
    }
    
    self.SinkingChrs = {}
    self._trove = Trove.new()
end

return Quicksand