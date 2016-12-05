local Crafting = require "widgets/crafting"

local ItemCrafting = Class(Crafting, function(self)
    Crafting._ctor(self, 10)
    self.name = "ItemCrafting"
    self.inst.entity:SetName("ItemCrafting")

    self.deferupdate = true
    self.idle_count = 0

    self:SetOrientation(true)
    -- TODO calculate x to line up nicely with the item tab
    self.in_pos = Vector3(-50, 140, 0)
    self.out_pos = Vector3(-50, 0, 0)
    self.craftslots:EnablePopups()

    self:SetFilter(function(recipe_name)
        if ( self.item_type ) then
            local recipe = GetRecipe(recipe_name)
            if ( recipe ) then
                for k,v in pairs(recipe.ingredients) do
                    if ( v.type == self.item_type ) then
                        return true
                    end
                end
            end
        end
        return false
    end)

    self:StartUpdating()  -- FIXME do this in Open() and StopUpdating in Close
end)

function ItemCrafting:OnUpdate(dt)
    if ( ItemCrafting._base.OnUpdate ) then
        ItemCrafting._base.OnUpdate(dt)
    end
    
    if ( self.open ) then
        local pos = TheInput:GetScreenPosition()
        local w, h = TheSim:GetScreenSize()
        -- TODO match the actual dimensions here, though this is probably good enough
        if ( pos.x < 0.10*w or pos.x > 0.75*w or pos.y > 0.60*h ) then
            self:Close()
        end
    end

    if ( self.update_needed ) then
print("self.update needed.  du:"..tostring(self.deferupdate).."  open:"..tostring(self.open).."  idle_count:"..self.idle_count)
        if ( not self.deferupdate or self.open ) then
            self:DoUpdateRecipes()
        else
            -- for some reason this sometimes silently failed in the if()
            local idle = GetPlayer().components.playercontroller.inst.sg:HasStateTag("idle")
            if ( idle ) then
                if ( self.idle_count > 100 ) then
                    self:DoUpdateRecipes()
                    self.idle_count = 0
                else
                    self.idle_count = self.idle_count + 1
                end
            else
                self.idle_count = 0
            end
        end
    end
end

function ItemCrafting:DoUpdateRecipes()
    Crafting.UpdateRecipes(self)

    if ( #self.valid_recipes > 0 ) then
        for _, v in pairs(self.craftslots.slots) do
            if ( v.recipepopup ) then
                -- FIXME  ideally, intercept when these are set...
                v.recipepopup.bg:SetTexture("images/popup-down.xml", "popup-down.tex")
                v.recipepopup.bg:SetPosition(0, 260, 0)
                v.recipepopup.contents:SetPosition(-315, 274, 0)
            end
        end
        self.itemtab.recipecount:SetString(tostring(0 + #self.valid_recipes))
    else
        self.itemtab.recipecount:SetString("0")
    end

    self.update_needed = false
end

--function ItemCrafting:Open()
--        DoUpdateRecipes()
--end

-- moved the actual updating to OnUpdate so that the costly update doesn't happen while the tab is closed, and also because some events fire it multiple times
function ItemCrafting:UpdateRecipes()
    if ( not self.update_needed ) then
        if ( self.itemtab and self.itemtab.recipecount ) then
            self.itemtab.recipecount:SetString("?")
        end
        self.update_needed = true
    end
end

-- experimental replacements to try to speed scrolling up

--[[  only marginally faster
function ItemCrafting:SetSlotRecipes()
    for i = 1, self.num_slots do
        local rec_i = i + self.idx
        if ( rec_i == 0 or rec_i > #self.valid_recipes ) then
            self.craftslots.slots[i]:Clear()
        else
            self.craftslots.slots[i]:SetRecipe(self.valid_recipes[rec_i].name)
        end
    end
end
--]]

local myscroll = GetModConfigData("myscroll", KnownModIndex:GetModActualName("Craft by Item"))
print("myscroll: " .. tostring(myscroll))

if ( myscroll ) then

function ItemCrafting:ScrollUp()
    self.owner.SoundEmitter:PlaySound("dontstarve/HUD/craft_up")
    if ( self.idx == -1 ) then
        self.downbutton:Enable()
    end
    self.idx = self.idx + 1
    if ( self.idx + self.num_slots > #self.valid_recipes ) then
        self.upbutton:Disable()
    end

    -- shift the slots down, then move the bottom one to the top and reassign
    local slots = self.craftslots.slots
    local bumped = slots[1]
    local pos
    local next_pos = bumped:GetPosition()
    for i = 2, self.num_slots do
        pos = next_pos
        next_pos = slots[i]:GetPosition()
        slots[i-1] = slots[i]
        slots[i-1]:SetPosition(pos)
    end
    slots[self.num_slots] = bumped
    bumped:SetPosition(next_pos)

    if ( self.idx + self.num_slots > #self.valid_recipes ) then
        bumped:Clear()
    else
        bumped:SetRecipe(self.valid_recipes[self.idx + self.num_slots].name)
    end
end

function ItemCrafting:ScrollDown()
    self.owner.SoundEmitter:PlaySound("dontstarve/HUD/craft_down")
    if ( self.idx + self.num_slots == #self.valid_recipes ) then
        self.upbutton:Enable()
    end
    self.idx = self.idx - 1
    if ( self.idx == -1 ) then
        self.downbutton:Disable()
    end

    -- shift the slots up, then move the top one to the bottom and reassign
    local slots = self.craftslots.slots
    local bumped = slots[self.num_slots]
    local pos
    local next_pos = bumped:GetPosition()
    for i = self.num_slots-1, 1, -1 do
        pos = next_pos
        next_pos = slots[i]:GetPosition()
        slots[i+1] = slots[i]
        slots[i+1]:SetPosition(pos)
    end
    slots[1] = bumped
    bumped:SetPosition(next_pos)

    if ( self.idx <= -1 ) then
        bumped:Clear()
    else
        bumped:SetRecipe(self.valid_recipes[self.idx + self.num_slots].name)
    end
end

end -- if myscroll

return ItemCrafting

-- vim: ts=4:sw=4:et
