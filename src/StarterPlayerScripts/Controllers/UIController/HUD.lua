local HUD = {}
HUD.__index = HUD

local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Trove = require(RepStorage.Packages.Trove)
local TableUtil = require(RepStorage.Packages.TableUtil)

function HUD:SetupDeaths()
    local deathsUI = self.hudUI.Left.DeathCount.Deaths.Value
    local deathsServer = self.Player:WaitForChild("leaderstats").Deaths

    deathsUI.Text = self.UIFuncs.AbbreviateNumber(deathsServer.Value) -- init when first join

    deathsServer.Changed:Connect(function(newValue)
        deathsUI.Text = self.UIFuncs.AbbreviateNumber(newValue)
    end)
end

function HUD:SetupMenus()
    local menus = self.MainUI.Menus
    local buttons = self.hudUI.Left.Button

    local menuMappings = {
        [buttons.Shop] = menus.ShopFrame,
        [buttons.Spin] = menus.SpinFrame,
        [buttons.UGC] = menus.UgcFrame
    }

    local openUI = nil

    for button, frame in pairs(menuMappings) do
        button.Activated:Connect(function()
            if openUI then
                openUI.Visible = false
            end

            if openUI ~= frame then
                frame.Visible = true
                openUI = frame
            else
                openUI = nil
            end
        end)
    end
end

function HUD:SetupAnims()
    for _, button in ipairs(self.hudUI:GetDescendants()) do
        if button:IsA("ImageButton") or button:IsA("TextButton") then
            self.UIFuncs.ApplyButtonClickAnim(button)
        end
    end
end

function HUD:Start()
    print("started hud")
    self:SetupDeaths()
    self:SetupAnims()
    self:SetupMenus()
end

function HUD.new(baseTbl)
    --[[ 
    baseTbl comes with:
        UIFuncs : ModuleScript
        MainUI : ScreenGui
        Player : Player
    --]]

    local self = setmetatable(TableUtil.Assign(baseTbl, {
        hudUI = baseTbl.MainUI.HUD,

        _trove = Trove.new()
    }), HUD)

    return self
end

return HUD