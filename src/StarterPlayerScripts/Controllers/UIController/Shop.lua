local Shop = {}
Shop.__index = Shop

local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Trove = require(RepStorage.Packages.Trove)
local TableUtil = require(RepStorage.Packages.TableUtil)

function Shop:SetupShopUI()
    self.shopUI.Close.Activated:Connect(function()
        self.shopUI.Visible = false
    end)
end

function Shop:SetupAnims()
    self.UIFuncs.ApplyButtonClickAnim(self.shopUI.Close)

    for _, button in ipairs(self.shopUI.ScrollingFrame:GetDescendants()) do
        if button:IsA("ImageButton") or button:IsA("TextButton") then
            self.UIFuncs.ApplyButtonClickAnim(button, nil, 1.05, 1.05)
        end
    end
end

function Shop:Start()
    self:SetupAnims()
    self:SetupShopUI()
end

function Shop.new(baseTbl)
    --[[ 
    baseTbl comes with:
        UIFuncs : ModuleScript
        MainUI : ScreenGui
        Player : Player
    --]]

    local self = setmetatable(TableUtil.Assign(baseTbl, {
        shopUI = baseTbl.MainUI.Menus.ShopFrame,

        _trove = Trove.new()
    }), Shop)

    return self
end

return Shop