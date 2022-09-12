--creates a new quicksand obj
local RunService = game:GetService("RunService")
local RepStorage = game:GetService("ReplicatedStorage")

local Component = require(RepStorage.Packages.Component)

local MachineFuncs = require(script.Parent.Parent.Other.MachineFunctions)

local Quicksand = Component.new {
    Tag = "Quicksand"
}

function Quicksand:Sink(chr)
    
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

function Quicksand:Construct()
    self.SinkingChrs = {}
end

function Quicksand:Start()
    self:Enable()
end

return Quicksand