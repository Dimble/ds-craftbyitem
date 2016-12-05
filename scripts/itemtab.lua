local Widget = require "widgets/widget"
local Image = require "widgets/image"
local Text = require "widgets/text"

local ItemTab = Class(Widget, function(self)
    Widget._ctor(self, "ItemTab")
end)  -- ItemTab

function ItemTab:AttachInventory()
    if ( self.inv_sep ) then return end
    local inv = GetPlayer().HUD.controls.inv

    inv.root:AddChild(self)
    inv.root:AddChild(self.crafting)
    self.crafting:MoveToBack()
    self.inv_tile = self:AddChild(Image(HUD_ATLAS, "craft_slot.tex"))
    self.inv_item = self:AddChild(Image(HUD_ATLAS, "craft_slot.tex"))
    self.inv_sep = self:AddChild(Image(HUD_ATLAS, "craft_sep_h.tex"))
    self.recipecount = self.inv_item:AddChild(Text(NUMBERFONT, 42))

    local tile_w, tile_h = self.inv_tile:GetSize()
    local sep_w, sep_h = self.inv_sep:GetSize()

    self.inv_tile:SetPosition(0, 0)
    self.inv_sep:SetPosition(tile_w/2 + sep_w/2, 0)
    -- place the number at the corner so it doesn't look exactly like a stack count
    self.recipecount:SetPosition(-20, 16, 0)

    local tab_w, tab_h = tile_w + sep_w, tile_h
    local bg_w, bg_h = inv.bg:GetSize()
    -- GetScale also applies parent scale, which we don't want here
    local bg_sx, bg_sy, bg_sz = inv.bg.inst.UITransform:GetScale()
    self:SetPosition(-((bg_w/2 * bg_sx) + (tab_w/2)), 0)

    self.inv_sep:Show()
    self.inv_item:Hide()
    self.inv_item:MoveToFront()
    self.inv_tile:Show()
    self:Show()
end

-- TODO have it slide into the inventory bar
function ItemTab:DetachInventory()
    if ( self.inv_sep ) then
        local inv = GetPlayer().HUD.controls.inv
        self:RemoveChild(self.inv_tile)
        self.inv_item:RemoveChild(self.recipecount)
        self:RemoveChild(self.inv_item)
        self:RemoveChild(self.inv_sep)
        inv.root:RemoveChild(self)
        self.inv_tile = nil
        self.inv_item = nil
        self.inv_sep = nil
        self.recipecount = nil
    end
end

function ItemTab:NewActiveItem(data)
    if ( data and data.item ) then
        local atlas = data.item.components.inventoryitem:GetAtlas()
        local image = data.item.components.inventoryitem:GetImage()
        self.inv_item:SetTexture(atlas, image)
        self.inv_item:Show()
        self.last_item = data.item
        -- (name is the visible name)
        self.crafting.item_type = data.item and  data.item.prefab or nil
        self.crafting:UpdateRecipes()
    end
end

-- TODO proper button mouseover/click responses
--      ideally use a button without recreating it constantly..
function ItemTab:OnControl(control, down)
    if ( down and control == CONTROL_ACCEPT ) then
        self.crafting:Open()
    end
end

return ItemTab

--[[
    on click down
        make the click sound
        set clicked
        highlight something?
        shift slightly?
    on click up
        if clicked still
        crafting:Open()
--]]

--[[
function ItemTab:OnGainFocus()
    ItemTab._base.OnGainFocus(self)
end

function ItemTab:OnLoseFocus()
    ItemTab._base.OnLoseFocus(self)
end
--]]

--[[ TODO
function ItemTab:AttachMouse()
end

function ItemTab:DetachMouse()
end

- force stack changes selected-item mouse primary to 'craft by'
- then opens up crafting bar at the mouse position
    - min/max positioning and figure whether popup is above or below)
--]]

-- vim: ts=4:sw=4:et
