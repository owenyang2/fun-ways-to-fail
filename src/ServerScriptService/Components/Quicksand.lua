--creates a new quicksand obj
local RunService = game:GetService("RunService")
local RepStorage = game:GetService("ReplicatedStorage")

local Component = require(RepStorage.Packages.Component)
local Trove = require(RepStorage.Packages.Trove)

local MachineFuncs = require(script.Parent.Parent.Other.MachineFunctions)

local Quicksand = Component.new {
    Tag = "Quicksand"
}

function Quicksand:Sink(chr)
    chr.HumanoidRootPart.Anchored = 0
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

function Quicksand:Construct()
    self.SinkingChrs = {}
    self._trove = Trove.new()
end

return Quicksand