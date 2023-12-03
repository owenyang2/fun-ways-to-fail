local RepStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local Knit = require(RepStorage.Packages.Knit)
local Signal = require(RepStorage.Packages.Signal)
local Trove = require(RepStorage.Packages.Trove)
local TableUtil = require(RepStorage.Packages.TableUtil)

local Ragdoll = require(script.Parent.Parent.Classes.Ragdoll)
local MachineFuncs = require(RepStorage.Common.MachineFunctions)

local ToolService = Knit.CreateService {
    Name = "ToolService",
    Client = {}
}

function ToolService:CheckHoldingToolWithTag(plr : Player, tag : string)
    local holdingTool = plr.Character:FindFirstChildOfClass("Tool") -- pretty sure can only have at most 1 tool in chr, the one holding
    if not holdingTool then return end

    if CollectionService:HasTag(holdingTool, tag) then return holdingTool end

    return
end

function ToolService:PushPlayer(target: Player, tool : string,  dir : Vector3)
    -- ragdoll target player
    local ragdoll = Ragdoll.GlobalRagdolls[target]

    if ragdoll.Ragdolled then -- already ragdolled, cant push again
        return
    end

    ragdoll:Toggle(true)
    ragdoll:EditCanRagdoll(false)

    dir = dir or target.Character.HumanoidRootPart.CFrame.LookVector.Unit

    task.spawn(function()
        local tempVelo = Instance.new("LinearVelocity")
        tempVelo.MaxForce = math.huge
        tempVelo.Attachment0 = target.Character.Head.FaceCenterAttachment
        tempVelo.VectorVelocity = dir * self.Settings[tool].FallForce
        tempVelo.Name = "PushForce"
        tempVelo.Parent = target.Character.HumanoidRootPart

        task.wait(0.2)

        tempVelo:Destroy()
    end)

    task.wait(self.Settings[tool].RagdollTime)

    ragdoll:EditCanRagdoll(true)
    ragdoll:Toggle(false)
end

function ToolService:GetPushToolParts(plr) -- push tool :GetPartsInPart
    local partsR = game.Workspace:GetPartsInPart(plr.Character.RightHand, MachineFuncs.GetHitboxParams())
    local partsL = game.Workspace:GetPartsInPart(plr.Character.LeftHand, MachineFuncs.GetHitboxParams())

    return TableUtil.Extend(partsR, partsL)
end

function ToolService:GetHammerParts(tool) -- hammer tool :GetPartsInPart
    return game.Workspace:GetPartsInPart(tool.Handle, MachineFuncs.GetHitboxParams())
end

function ToolService.Client:PushToolActivated(plr : Player, toolType : string)
    print("activate")
    local validPushingTools = {
        "Push",
        "BoinkHammer",
        "OPHammer"
    }

    if not table.find(validPushingTools, toolType) then
        return
    end

    local toolSettings = self.Server.Settings[toolType]
    local tool = self.Server:CheckHoldingToolWithTag(plr, self.Server:ToolToTag(toolType))

    -- check if can use
    if not plr.Character or not tool then return end

    -- check cooldown
    if self.Server.ToolDB[toolType][plr] ~= nil and os.time() - self.Server.ToolDB[toolType][plr] < toolSettings.Cooldown then return end
    
    self.Server.ToolDB[toolType][plr] = os.time()
    self.Server.BasicService:PlayAnim(plr, self.Server.Anims[toolType])

    local tempTrove = Trove.new()
    tempTrove:AttachToInstance(tool)
    tempTrove:Connect(RunService.Heartbeat, function(dt)
        if not plr.Character then return end
    
        local parts = {}

        if toolType == "Push" then
            parts = self.Server:GetPushToolParts(plr)
        elseif toolType == "BoinkHammer" or toolType == "OPHammer" then
            parts = self.Server:GetHammerParts(tool)
        else
            warn("Push Hitbox for " .. toolType .. " was not setup correctly!")
            return
        end
        
        local donePlrs = {}
    
        for _, part in ipairs(parts) do
            if not part then continue end
                
            local targetPlr = game.Players:GetPlayerFromCharacter(part:FindFirstAncestorOfClass("Model"))
    
            if not targetPlr or targetPlr == plr then continue end
    
            table.insert(donePlrs, targetPlr)
            self.Server:PushPlayer(targetPlr, toolType, plr.Character.HumanoidRootPart.CFrame.LookVector.Unit)
        end
    end)

    task.wait(toolSettings.Length)
    tempTrove:Destroy()
end

function ToolService:ToolToTag(tool)
    local toolToTag = {
        Push = "PushToolHitbox",
        BoinkHammer = "BoinkHammer",
        OPHammer = "OPHammer"
    }

    return toolToTag[tool]
end

function ToolService:KnitStart()
    self.RagdollService = Knit.GetService("RagdollService")
    self.BasicService = Knit.GetService("BasicService")

    self.Anims = {
        Push = "rbxassetid://15186940808",
        BoinkHammer = "rbxassetid://15393389805",
        OPHammer = "rbxassetid://15393389805"
    }

    self.Settings = {
        Push = {
            Cooldown = 1,
            RagdollTime = 1,
            FallForce = 15,
            Length = MachineFuncs.GetAnimLength(self.Anims.Push) + 1,
            HitboxParts = {}
        },

        BoinkHammer = {
            Cooldown = 3,
            RagdollTime = 2,
            FallForce = 30,
            Length = MachineFuncs.GetAnimLength(self.Anims.BoinkHammer) + 1    
        },

        OPHammer = {
            Cooldown = 5,
            RagdollTime = 4,
            FallForce = 60,
            Length = MachineFuncs.GetAnimLength(self.Anims.OPHammer) + 1    
        }
    }

    self.ToolDB = { -- keeps track of each player's last use
        Push = {},
        BoinkHammer = {},
        OPHammer = {}
    }
end

return ToolService