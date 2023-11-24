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

function ToolService:CheckHoldingTool(plr : Player, tag : string)
    local holdingTool = plr.Character:FindFirstChildOfClass("Tool") -- pretty sure can only have at most 1 tool in chr, the one holding
    if not holdingTool then return end

    if CollectionService:HasTag(holdingTool, tag) then return holdingTool end

    return
end

function ToolService:PushPlayer(target: Player, dir : Vector3)
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
        tempVelo.VectorVelocity = dir * self.Settings.FallForce
        tempVelo.Name = "PushForce"
        tempVelo.Parent = target.Character.HumanoidRootPart

        task.wait(0.2)

        tempVelo:Destroy()
    end)

    task.wait(self.Settings.RagdollTime)

    ragdoll:EditCanRagdoll(true)
    ragdoll:Toggle(false)
end

function ToolService.Client:PushTargetHitbox(plr : Player)
    local toolSettings = self.Server.Settings.Push

    -- check if can push
    if not plr.Character or not self.Server:CheckHoldingTool(plr, "PushToolHitbox") then return end

    -- check cooldown
    if self.Server.LastPush[plr] ~= nil and os.time() - self.Server.LastPush[plr] < toolSettings.Cooldown then return end
    self.Server.LastPush[plr] = os.time()

    --self.Server.BasicService:PlayAnim(plr, self.Server.Anims.PushAnimID, {Looped = false})
    self.Server.BasicService:PlayAnim(plr, self.Server.Anims.PushAnimID)

    local tempTrove = Trove.new()
    tempTrove:Connect(RunService.Heartbeat, function(dt)
        if not plr.Character then return end
    
        local partsR = game.Workspace:GetPartsInPart(plr.Character.RightHand, MachineFuncs.GetHitboxParams())
        local partsL = game.Workspace:GetPartsInPart(plr.Character.LeftHand, MachineFuncs.GetHitboxParams())
    
        local donePlrs = {}
    
        for _, part in ipairs(TableUtil.Extend(partsR, partsL)) do
            print(part)
            if not part then continue end
                
            local targetPlr = game.Players:GetPlayerFromCharacter(part:FindFirstAncestorOfClass("Model"))
    
            if not targetPlr or targetPlr == plr then continue end
    
            table.insert(donePlrs, targetPlr)
            self.Server:PushPlayer(targetPlr, plr.Character.HumanoidRootPart.CFrame.LookVector.Unit)
        end
    end)

    task.wait(toolSettings.Length)
    tempTrove:Destroy()
end

function ToolService.Client:SwingBoinkHammer(plr : Player)
    local toolSettings = self.Server.Settings.BoinkHammer
    local tool = self.Server:CheckHoldingTool(plr, "BoinkHammer")

    if not plr.Character or not tool then return end
    if self.Server.LastSwingBoink[plr] ~= nil and os.time() - self.Server.LastSwingBoink[plr] < toolSettings.Cooldown then return end
    
    self.Server.LastSwingBoink[plr] = os.time()
    self.Server.BasicService:PlayAnim(plr, self.Server.Anims.SwingAnimID)

    local tempTrove = Trove.new()
    tempTrove:Connect(RunService.Heartbeat, function(dt)
        if not plr.Character then return end
    
        local parts = game.Workspace:GetPartsInPart(tool.Handle, MachineFuncs.GetHitboxParams())
    
        local donePlrs = {}
    
        for _, part in ipairs(parts) do
            if not part then continue end
                
            local targetPlr = game.Players:GetPlayerFromCharacter(part:FindFirstAncestorOfClass("Model"))
    
            if not targetPlr or targetPlr == plr then continue end
    
            table.insert(donePlrs, targetPlr)
            self.Server:PushPlayer(targetPlr, plr.Character.HumanoidRootPart.CFrame.LookVector.Unit)
        end
    end)

    task.wait(toolSettings.Length)
    tempTrove:Destroy()
end

function ToolService:KnitStart()
    self.RagdollService = Knit.GetService("RagdollService")
    self.BasicService = Knit.GetService("BasicService")

    self.Anims = {
        PushAnimID = "rbxassetid://15186940808",
        SwingAnimID = "rbxassetid://15393389805"
    }

    self.Settings = {
        Push = {
            Cooldown = 3,
            RagdollTime = 3,
            FallForce = 15,
            Length = MachineFuncs.GetAnimLength(self.Anims.PushAnimID) + 1    
        },

        BoinkHammer = {
            Cooldown = 5,
            RagdollTime = 5,
            FallForce = 50,
            Length = MachineFuncs.GetAnimLength(self.Anims.SwingAnimID) + 1    
        }
    }

    self.LastPush = {} -- keeps track of each player's last push
    self.LastSwingBoink = {} -- keeps track of each player's last swing (boink hammer)
end

return ToolService