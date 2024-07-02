local async = require('openmw.async')
local aux_util = require('openmw_aux.util')
local camera = require('openmw.camera')
local core = require('openmw.core')
local input = require('openmw.input')
local I = require("openmw.interfaces")
local MWUI = require('openmw.interfaces').MWUI
local self = require('openmw.self') as core.GameObject
local storage = require('openmw.storage')
local types = require('openmw.types')
local ui = require('openmw.ui')
local util = require('openmw.util')

local v2 = util.vector2

local Actor = types.Actor
local Armor = types.Armor
local Clothing = types.Clothing
local GameObject = core.GameObject
local Enchantment = core.Enchantment
local Player = types.Player
local Spell = core.Spell
local Weapon = types.Weapon

I.Settings.registerPage {
    key = 'QuickActionPage',
    l10n = 'QuickActionPage',
    name = 'Quick Action',
    description = 'Add customizable "quick" actions to the HUD',
}

I.Settings.registerGroup {
    key = 'SettingsQuickAction',
    page = 'QuickActionPage',
    l10n = 'QuickAction',
    name = 'Quick Action',
    description = 'Quick Action Settings',
    permanentStorage = false,
    settings = {
        {
            key = 'toggle',
            name = 'Toggle Widget',
            description = 'Toggle Quick Action HUD Widget',
            renderer = 'textLine',
            default = 'x',
        },
        {
            key = 'addAction',
            name = 'Add Action',
            description = 'Add Action to current listing',
            renderer = 'textLine',
            default = 'n',
        },
        {
            key = 'delAction',
            name = 'Delete Action',
            description = 'Delete the selected Action from current listing',
            renderer = 'textLine',
            default = 'delete',
        },
        {
            key = 'moveUpAction',
            name = 'Move Action Up',
            description = 'Move the selected Action up (counterclockwise)',
            renderer = 'textLine',
            default = '\\',
        },
        {
            key = 'moveDownAction',
            name = 'Move Action Down',
            description = 'Move the selected Action down (clockwise)',
            renderer = 'textLine',
            default = ']',
        },
        {
            key = 'addListing',
            name = 'Add Listing',
            description = 'Add a new listing',
            renderer = 'textLine',
            default = 'm',
        },
        {
            key = 'nextListing',
            name = 'Next Listing',
            description = 'Switch to the next listing',
            renderer = 'textLine',
            default = 'z',
        },
        {
            key = 'delListing',
            name = 'Delete Listing',
            description = 'Delete the current listing',
            renderer = 'textLine',
            default = 'end',
        },
        {
            key = 'positionX',
            name = 'Position X',
            description = 'The x position of the Widget center relative to the screen',
            renderer = 'number',
            default = 0.5,
            argument = {
                min = 0.0,
                max = 1.0,
            }
        },
        {
            key = 'positionY',
            name = 'Position Y',
            description = 'The y position of the Widget center relative to the screen',
            renderer = 'number',
            default = 0.5,
            argument = {
                min = 0.0,
                max = 1.0,
            }
        },
        {
            key = 'radiusMul',
            name = 'Radius',
            description = 'The radius of the Widget from the center is going to be this number * min(screen.x, screen.y)',
            renderer = 'number',
            default = 0.15,
        },
        {
            key = 'enableInfoBox',
            name = 'Enable Info Box',
            description = 'Enable the info box under the actions that show name of the listing, name of the action and keys',
            renderer = 'checkbox',
            default = true,
        },
        {
            key = 'enableInfoBoxKeys',
            name = 'Enable Info Box Keys',
            description = 'Shows the keys in the Info Box',
            renderer = 'checkbox',
            default = true,
        },
    }
}

local settings = storage.playerSection('SettingsQuickAction')

local function checkbox(settingKey: string): boolean
    return settings:get(settingKey) as boolean
end

local function keyBindingFor(settingKey: string): string
    return settings:get(settingKey) as string
end

local function infoBoxHelper(): string
    return keyBindingFor('addAction') .. ': add action  ' ..
        keyBindingFor('delAction') .. ': del action  ' ..
        keyBindingFor('addListing') .. ': add list  ' ..
        keyBindingFor('delListing') .. ': del list  ' ..
        keyBindingFor('nextListing') .. ': next list'
end

------------------------

local enum ActionType
    "EQUIP_TO_RIGHT_HAND"
    "EQUIP_SPELL"
    "EQUIP_ENCHANTED_ITEM"
 
    "SHOW_EQUIP_ENCHANTED_ACTIONS"
    "ADD_EQUIP_ENCHANTED_ACTION"
    "SHOW_EQUIP_SPELL_ACTIONS"
    "ADD_EQUIP_SPELL_ACTION"
    "SHOW_EQUIP_WEAPON_ACTIONS"
    "ADD_EQUIP_WEAPON_ACTION"
    "ADD_ENTRY"
end

local record Action
    type: ActionType
    page: string | nil
    args: any
end

local record Item
    name: string
    texturePath: string
    action: Action
    listingTitle: string
end

local record Listing
    isModifiable: boolean
    items: {Item}
end

function Listing:modifiable(items: {Item}): Listing
    return { isModifiable = true, items = items }
end

function Listing:unmodifiable(items: {Item}): Listing
    return { isModifiable = false, items = items }
end

local record State
    -- title -> List of Items
    listings: {string: Listing}
    -- List of all the titles for listings
    listingsTitles: {string}
    -- The title of the current listing
    currentId: string
    -- The index of the currently selected item
    selectedItemIndex: integer
end

function State:new(): State
    local self: State = setmetatable({}, { __index = State })
    self.listings = {}
    self.currentId = '1'
    self.listings[self.currentId] = Listing:modifiable({})
    self.listingsTitles = {}
    table.insert(self.listingsTitles, '1')
    self.selectedItemIndex = 1
    return self
end

function State:from(state: State): State
    local self = State:new()
    self.listingsTitles = state.listingsTitles
    self.listings = state.listings
    self.currentId = state.currentId
    self.selectedItemIndex = state.selectedItemIndex
    return self
end

function State:newListing(title: string, listing: Listing)
    self.listings[title] = listing
    if self.listings[title].isModifiable then
        table.insert(self.listingsTitles, title)
    end
end

function State:setListing(id: string)
    self.currentId = id
    self.selectedItemIndex = 1
end

function State:setFirstListing()
    self:setListing(self.listingsTitles[1])
end

function State:newAndSetListing(title: string, listing: Listing)
    self:newListing(title, listing)
    self:setListing(title)
end

function State:addNextListing(): string
    local nextTitle = tostring(#self.listingsTitles + 1)
    self:newAndSetListing(nextTitle, Listing:modifiable {})
    return nextTitle
end

function State:nextListing()
    local nextTitle = self.listingsTitles[1]
    for i, title in ipairs(self.listingsTitles) do
        if title == self.currentId and i + 1 <= #self.listingsTitles then
            nextTitle = self.listingsTitles[i + 1]
            break
        end
    end
    self:setListing(nextTitle)
end

function State:delListing()
    if not self.listings[self.currentId].isModifiable then return end
    local removedId = self.currentId
    self:nextListing()
    self.listings[removedId] = nil
    for i = 1, #self.listingsTitles do
        if self.listingsTitles[i] == removedId then
            table.remove(self.listingsTitles, i)
            break
        end
    end
end

local record Current
    title: string
    selectedItemIndex: integer
    listing: Listing
end

function Current:new(title: string,
                     selectedItemIndex: integer,
                     listing: Listing
                    ): Current
    local self: Current = setmetatable({}, { __index = Current })
    self.title = title
    self.selectedItemIndex = selectedItemIndex
    self.listing = listing
    return self
end

function Current:selectedItem(): Item
    if #self.listing.items < self.selectedItemIndex then
        return nil
    else
        return self.listing.items[self.selectedItemIndex]
    end
end

function State:current(): Current
    return Current:new(
        self.currentId,
        self.selectedItemIndex,
        self.listings[self.currentId]
    )
end

function State:select(selectedItemIndex: integer)
    local current = self:current()
    local numItems = #current.listing.items
    if selectedItemIndex < 1 or selectedItemIndex > numItems then
        error('selectedItemIndex:' .. tostring(selectedItemIndex) ..
              ' is outside the valid range [' .. tostring(1) ..
              ',' .. tostring(numItems) .. '] of listing ' ..
              current.title)
    end
    self.selectedItemIndex = selectedItemIndex
end

function State:addItemTo(title: string, item: Item)
    local listing = self.listings[title]
    if not listing then
        print('Warn: attempted to add an item to non existing listing ' .. title)
        return
    end
    if not listing.isModifiable then
        print('Warn: attempted to add an item to non modifiable listing ' .. title)
        return
    end
    table.insert(listing.items, item)
end

-- remove the selected item from the current listing if
-- the current listing is modifiable
function State:removeSelected(): Item
    local current = self:current()
    if not current.listing.isModifiable or
       #current.listing.items < current.selectedItemIndex then
        return nil
    end
    if #current.listing.items < current.selectedItemIndex then
        print(string.format('Warn: trying to remove ' ..
            'selectedItemIndex:%d from current listing which has only %d items',
            current.selectedItemIndex, #current.listing.items
        ))
        return nil
    end
    local removed = current.listing.items[current.selectedItemIndex]
    table.remove(current.listing.items, current.selectedItemIndex)
    if #current.listing.items < current.selectedItemIndex then
        self:select(1)
    end
    return removed
end

function State:moveCurrentUp()
    if not self.listings[self.currentId].isModifiable then return end
    local oldPosition = self.selectedItemIndex
    local removed = self:removeSelected()
    if removed == nil then return end
    
    local position = oldPosition - 1
    if position <= 0 then
        position = #self.listings[self.currentId].items + 1
    end
    table.insert(self.listings[self.currentId].items, position, removed)
    
    self:select(position)
end

function State:moveCurrentDown()
    if not self.listings[self.currentId].isModifiable then return end
    local oldPosition = self.selectedItemIndex
    local removed = self:removeSelected()
    if removed == nil then return end

    local position = oldPosition + 1
    if position > #self.listings[self.currentId].items + 1 then
        position = 1
    end
    table.insert(self.listings[self.currentId].items, position, removed)

    self:select(position)
end

------------------------

-- TODO Is there any reason you aren't using https://openmw.readthedocs.io/en/latest/reference/lua-scripting/openmw_input.html##(input).setControlSwitch ?

local textSize = MWUI.templates.textNormal.props.textSize as number
local iconSize = textSize * 2

local state = State:new()

local inputWidget: ui.Element = nil

input.bindAction('Zoom3rdPerson', async:callback(function(_, scroll: integer): integer
   if inputWidget then return 0 else return scroll end
end), {})

input.bindAction('Use', async:callback(function(_, use: boolean): boolean
   if inputWidget then return false else return use end
end), {})

local function closeQuickAction()
    if inputWidget then
        inputWidget:destroy()
        inputWidget = nil
        -- -- issue: this is centering the screen which is quite annoying
        -- Player.setControlSwitch(self, Player.CONTROL_SWITCH.Looking, true)
    end
end

local record BackgroundOptions
    alpha: number
    color: util.Color
end

local function background(options: BackgroundOptions): ui.Template
    return {
        type = ui.TYPE.Container,
        content = ui.content {
            {
                type = ui.TYPE.Image,
                props = {
                    alpha = options.alpha,
                    color = options.color,
                    resource = ui.texture { path = 'white' },
                    relativeSize = v2(1, 1),
                    size = v2(1, 1) * 2, -- see MWUI constants.border and borders
                },
            },
            {
                external = { slot = true },
                props = {
                    relativeSize = v2(1, 1),
                },
            },
        },
    }
end

local function padding(paddingSize: util.Vector2): ui.Template
    return {
        type = ui.TYPE.Container,
        content = ui.content {
            {
                props = {
                    size = paddingSize,
                },
            },
            {
                external = { slot = true },
                props = {
                    position = paddingSize,
                    relativeSize = util.vector2(1, 1),
                },
            },
            {
                props = {
                    position = paddingSize,
                    relativePosition = util.vector2(1, 1),
                    size = paddingSize,
                },
            },
        }
    }
end

local selectedItemBackgroundColor = MWUI.templates.textHeader.props.textColor as util.Color
local itemBackgroundColor = util.color.rgb(0, 0, 0)

local function showQuickAction()
    closeQuickAction()

    local current = state:current()
    -- print('showing:' .. current.title)

    local relativePosition = v2(settings:get('positionX') as number, settings:get('positionY') as number)
    local screenSize = ui.layers[ui.layers.indexOf("HUD") as integer].size
    -- print('center:(' .. string.format('%.2f', center.x) .. ',' .. string.format('%.2f', center.y) .. ')')
    local radius = math.min(screenSize.x, screenSize.y) * settings:get('radiusMul') as number
    local angle = 2 * math.pi / #current.listing.items
    local content = ui.content {}
    for i = 1, #current.listing.items do
        local iAngle = i * angle - angle / 2

        local boxContent = ui.content {}
        if current.listing.items[i].texturePath then
            boxContent:add {
                type = ui.TYPE.Image,
                props = {
                    alpha = 1,
                    color = util.color.rgb(1, 1, 1),
                    resource = ui.texture { path = current.listing.items[i].texturePath },
                    size = v2(iconSize, iconSize),
                },
            }
        else
            boxContent:add {
                type = ui.TYPE.Widget,
                props = {
                    size = v2(iconSize, iconSize)
                },
            }
        end

        local position = v2(radius * math.cos(iAngle), radius * math.sin(iAngle))
        local backgroundColor = i == current.selectedItemIndex and selectedItemBackgroundColor or itemBackgroundColor
        content:add {
            template = MWUI.templates.boxSolidThick,
            name = tostring(i),
            props = {
                anchor = v2(0.5, 0.5),
                position = position,
                relativePosition = relativePosition,
            },
            content = ui.content {
                {
                    template = background {
                        alpha = 0.5,
                        color = backgroundColor,
                    },
                    name = 'background',
                    content = ui.content {
                        {
                            template = padding(v2(5, 5)),
                            content = boxContent,
                        }
                    }
                },
            },
        }
    end

    local flexContent = ui.content {}
    flexContent:add {
        template = MWUI.templates.textNormal,
        props = {
            text = current.title,
            textAlignV = ui.ALIGNMENT.Center,
            textAlignH = ui.ALIGNMENT.Center,
        }
    }
    flexContent:add {
        template = MWUI.templates.horizontalLineThick,
    }
    local item = current:selectedItem()
    flexContent:add {
        name = 'text',
        template = MWUI.templates.textHeader,
        props = {
            text = item and item.name or " ",
            textAlignV = ui.ALIGNMENT.Center,
            textAlignH = ui.ALIGNMENT.Center,
        }
    }
    if current.listing.isModifiable and checkbox('enableInfoBoxKeys') then
        flexContent:add {
            template = MWUI.templates.horizontalLineThick,
        }
        flexContent:add {
            template = MWUI.templates.textNormal,
            props = {
                text = infoBoxHelper(),
                textAlignV = ui.ALIGNMENT.Center,
                textAlignH = ui.ALIGNMENT.Center,
            }
        }
    end

    if checkbox('enableInfoBox') then
        content:add {
            template = MWUI.templates.boxTransparentThick,
            name = 'infoBackground',
            props = {
                anchor = v2(0.5, 0.5),
                position = v2(0, radius + iconSize * 3),
                relativePosition = relativePosition,
            },
            content = ui.content {
                {
                    template = padding(v2(5, 5)),
                    name = 'padding',
                    content = ui.content {
                        {
                            type = ui.TYPE.Flex,
                            name = 'info',
                            content = flexContent,
                            props = {
                                align = ui.ALIGNMENT.Center,
                                arrange = ui.ALIGNMENT.Center,
                            },
                        },
                    },
                },
            },
        }
    end

    inputWidget = ui.create {
        layer = 'HUD',
        type = ui.TYPE.Widget,
        content = content,
        props = {
            relativeSize = v2(1, 1),
        },
    }

    -- -- issue: this is centering the screen which is quite annoying
    -- Player.setControlSwitch(self, Player.CONTROL_SWITCH.Looking, false)
end

local function lookupLayout(widget: ui.Element, names: {string}): ui.Layout
    local currentWidget: ui.Layout = widget.layout
    for _, name in ipairs(names) do
        if not currentWidget then break end
        currentWidget = currentWidget.content[name] as ui.Layout
    end
    return currentWidget
end

local function changeSelection(index: integer)
    if not inputWidget then return end
    local current = state:current()
    if #current.listing.items == 0 then return end
    if index > #current.listing.items then
        print(string.format('Cannot change selection to %d ' ..
              'because it is outside the valid range [1,%d]',
              index,
              #current.listing.items))
        return
    end

    local oldSelectedLayout = lookupLayout(inputWidget, {tostring(state.selectedItemIndex), 'background'})
    local selectedLayout = lookupLayout(inputWidget, {tostring(index), 'background'})

    oldSelectedLayout.template = background { alpha = 0.5, color = itemBackgroundColor }
    selectedLayout.template = background { alpha = 0.5, color = selectedItemBackgroundColor }

    state:select(index)
    current = state:current()

    if checkbox('enableInfoBox') then
        local textLayout = lookupLayout(inputWidget, {'infoBackground', 'padding', 'info', 'text'})
        textLayout.props.text = current.listing.items[current.selectedItemIndex].name
    end

    inputWidget:update()
end

local function toggleQuickAction()
    if inputWidget then
        closeQuickAction()
        state:setFirstListing()
    else
        showQuickAction()
    end
end

local function getWeaponsInSelfInvectory(): {Weapon}
    local res: {Weapon} = {}
    for _, weapon in ipairs(Actor.inventory(self):getAll(Weapon)) do
        local weapon_type = Weapon.record(weapon).type
        if weapon_type ~= Weapon.TYPE.Arrow and
           weapon_type ~= Weapon.TYPE.Bolt then
            table.insert(res, weapon as Weapon)
        end
    end
    return res
end

local function listAddEquipWeaponActions(listingTitle: string): {Item}
    local res = {}
    for _, weapon in ipairs(getWeaponsInSelfInvectory()) do
        table.insert(res, {
            name = Weapon.record(weapon).name,
            texturePath = Weapon.record(weapon).icon,
            action = { type = 'ADD_EQUIP_WEAPON_ACTION', args = Weapon.record(weapon).id },
            listingTitle = listingTitle,
        })
    end
    return res
end

local function listAddEquipSpellActions(listingTitle: string): {Item}
    local res = {}
    for _, spell in pairs(Actor.spells(self) as {any: Spell}) do
        if spell.type == core.magic.SPELL_TYPE.Power or
           spell.type == core.magic.SPELL_TYPE.Spell then
            table.insert(res, {
                name = spell.name,
                texturePath = spell.effects[1].effect.icon,
                action = { type = 'ADD_EQUIP_SPELL_ACTION', args = spell.id },
                listingTitle = listingTitle,
            })
        end
    end
    return res
end

local record NameAndEnchant
    name: string
    texturePath: string
    enchant: string
end

local function itemNameAndEnchant(item: GameObject): nil | NameAndEnchant
    if Armor.objectIsInstance(item) and Armor.record(item as Armor).enchant ~= "" then
        local armor = Armor.record(item as Armor)
        return {
            name = armor.name,
            texturePath = armor.icon,
            enchant = armor.enchant
        }
    elseif Clothing.objectIsInstance(item) and Clothing.record(item as Clothing).enchant ~= "" then
        local clothing = Clothing.record(item as Clothing)
        return {
            name = clothing.name,
            texturePath = clothing.icon,
            enchant = clothing.enchant
        }
    elseif Weapon.objectIsInstance(item) and Weapon.record(item as Weapon).enchant ~= "" then
        local weapon = Weapon.record(item as Weapon)
        return {
            name = weapon.name,
            texturePath = weapon.icon,
            enchant = weapon.enchant
        }
    else
        return nil
    end
end

local function listAddEquipEnchantedActions(listingTitle: string): {Item}
    local res = {}
    for _, item in ipairs(Actor.inventory(self):getAll()) do
        local name_and_enchant = itemNameAndEnchant(item)
        if name_and_enchant == nil then goto continue end
        name_and_enchant = name_and_enchant as NameAndEnchant
        local enchantment = (core.magic.enchantments.records as {string: Enchantment})[name_and_enchant.enchant]
        if enchantment.type == core.magic.ENCHANTMENT_TYPE.CastOnUse then
            table.insert(res, {
                name = '* ' .. name_and_enchant.name,
                texturePath = name_and_enchant.texturePath,
                action = { type = "ADD_EQUIP_ENCHANTED_ACTION", args = item.recordId },
                listingTitle = listingTitle,
            })
        end
        ::continue::
    end
    return res
end

local function listBasicActions(listingTitle: string): {Item}
    return {
        {
            name = 'add equip weapon action',
            texturePath = 'icons/w/tx_iron_longsword.dds',
            action = { type = "SHOW_EQUIP_WEAPON_ACTIONS", args = nil },
            listingTitle = listingTitle,
        },
        {
            name = 'add equip magic action',
            texturePath = 'icons/k/magicka.dds',
            action = { type = "SHOW_EQUIP_SPELL_ACTIONS", args = nil },
            listingTitle = listingTitle,
        },
        {
            name = 'add equip enchanted item action',
            texturePath = 'icons/k/magic_enchant.dds',
            action = { type = "SHOW_EQUIP_ENCHANTED_ACTIONS", args = nil },
            listingTitle = listingTitle,
        }
    }
end

local function onKeyPress(key: input.KeyboardEvent)

    local keyName = input.getKeyName(key.code):lower()

    if keyName == keyBindingFor('toggle') then
        toggleQuickAction()

    elseif inputWidget and state:current().listing.isModifiable and keyName == keyBindingFor('addAction') then
        local title = 'Select the action to add:'
        state:newAndSetListing(title, Listing:unmodifiable(listBasicActions(state:current().title)))
        showQuickAction()

    elseif inputWidget and keyName == keyBindingFor('delAction') then
        state:removeSelected()
        showQuickAction()

    elseif inputWidget and keyName == keyBindingFor('moveUpAction') then
        state:moveCurrentUp()
        showQuickAction()

    elseif inputWidget and keyName == keyBindingFor('moveDownAction') then
        state:moveCurrentDown()
        showQuickAction()

    elseif inputWidget and keyName == keyBindingFor('addListing') then
        state:addNextListing()
        showQuickAction()

    elseif inputWidget and keyName == keyBindingFor('nextListing') then
        state:nextListing()
        showQuickAction()

    elseif inputWidget and keyName == keyBindingFor('delListing') then
        state:delListing()
        showQuickAction()

    end
end

local function onMouseButtonRelease(button: number)
    if inputWidget == nil then return end
    if button == 1 then
        local current = state:current()
        local selectedItem = current:selectedItem()

        if selectedItem.action.type == "SHOW_EQUIP_WEAPON_ACTIONS" then
            local title = 'Select Weapon to add:'
            state:newAndSetListing(title, Listing:unmodifiable(listAddEquipWeaponActions(selectedItem.listingTitle)))
            showQuickAction()

        elseif selectedItem.action.type == "ADD_EQUIP_WEAPON_ACTION" then
            local weaponId = selectedItem.action.args as string
            state:addItemTo(selectedItem.listingTitle, {
                name = selectedItem.name,
                texturePath = selectedItem.texturePath,
                action = { type = "EQUIP_TO_RIGHT_HAND", args = weaponId },
            })
            state:setListing(selectedItem.listingTitle)
            showQuickAction()
        
        elseif selectedItem.action.type == "EQUIP_TO_RIGHT_HAND" then
            local weaponId = selectedItem.action.args as string
            local weapon = Actor.inventory(self):find(weaponId)

            if weapon == nil then
                print('Selected weapon ' .. selectedItem.name .. ' could not be found (id:' .. tostring(weaponId) .. ')')
            else
                local equipment = Actor.getEquipment(self) as types.EquipmentTable
                print('Equipping ' .. selectedItem.name)
                equipment[Actor.EQUIPMENT_SLOT.CarriedRight] = weapon
                Actor.setEquipment(self, equipment)
                Actor.setStance(self, Actor.STANCE.Weapon)
            end
            closeQuickAction()
            state:setFirstListing()

        elseif selectedItem.action.type == "SHOW_EQUIP_SPELL_ACTIONS" then
            local title = 'Select Spell to add:'
            state:newAndSetListing(title, Listing:unmodifiable(listAddEquipSpellActions(selectedItem.listingTitle)))
            showQuickAction()
            
        elseif selectedItem.action.type == "ADD_EQUIP_SPELL_ACTION" then
            local spellId = selectedItem.action.args as string
            state:addItemTo(selectedItem.listingTitle, {
                name = selectedItem.name,
                texturePath = selectedItem.texturePath,
                action = { type = "EQUIP_SPELL", args = spellId },
            })
            state:setListing(selectedItem.listingTitle)
            showQuickAction()

        elseif selectedItem.action.type == "EQUIP_SPELL" then
            local spellId = selectedItem.action.args as string
            local spell = (core.magic.spells.records as {string:Spell})[spellId]

            if spell == nil then
                print('Selected Spell ' .. selectedItem.name .. ' could not be found (spellId:' .. tostring(spellId) .. ')')
            else
                print('Equipping ' .. spell.name)
                Actor.clearSelectedCastable(self)
                Actor.setSelectedSpell(self, spell)
                -- TODO: for some reason there must be a delay in order to properly change stance to Spell
                async:newUnsavableGameTimer(10, function()
                    Actor.setStance(self, Actor.STANCE.Spell)
                end)
            end
            closeQuickAction()
            state:setFirstListing()

            
        elseif selectedItem.action.type == "SHOW_EQUIP_ENCHANTED_ACTIONS" then
            local title = 'Select Enchantment to add:'
            state:newAndSetListing(title, Listing:unmodifiable(listAddEquipEnchantedActions(selectedItem.listingTitle)))
            showQuickAction()

        elseif selectedItem.action.type == "ADD_EQUIP_ENCHANTED_ACTION" then
            local itemId = selectedItem.action.args as string
            state:addItemTo(selectedItem.listingTitle, {
                name = selectedItem.name,
                texturePath = selectedItem.texturePath,
                action = { type = "EQUIP_ENCHANTED_ITEM", args = itemId },
            })
            state:setListing(selectedItem.listingTitle)
            showQuickAction()

        elseif selectedItem.action.type == "EQUIP_ENCHANTED_ITEM" then
            local itemId = selectedItem.action.args as string
            local item = Actor.inventory(self):find(itemId)

            if item == nil then
                print('Selected Enchanted Item ' .. selectedItem.name .. ' could not be found (id:' .. tostring(itemId) .. ')')
            else
                Actor.clearSelectedCastable(self)
                Actor.setSelectedEnchantedItem(self, item)
                -- TODO: for some reason there must be a delay in order to properly change stance to Spell
                async:newUnsavableGameTimer(10, function()
                    Actor.setStance(self, Actor.STANCE.Spell)
                end)
            end
            closeQuickAction()
            state:setFirstListing()

        else
            error('Unknown action type ' .. tostring(selectedItem.action.type))
            closeQuickAction()
        end
    elseif button == 3 then
        closeQuickAction()
    end
end

local function onLoad(savedData: State, _)
    if savedData then
        state = State:from(savedData)
    end
end

local function onSave(): State
    if state then
        return state
    end
end

local function onFrame(_)
    if inputWidget then
        local current = state:current()
        local y = input.getMouseMoveY()
        local x = input.getMouseMoveX()
        if math.abs(x) + math.abs(y) <= 5 then return end
        local angle = 2 * math.pi / #current.listing.items
        local pointAngle = math.atan(y/x)
        if pointAngle < 0 then
            if y < 0 then
                pointAngle = 2 * math.pi + pointAngle
            else
                pointAngle = math.pi + pointAngle
            end
        elseif x < 0 and y < 0 then
            pointAngle = math.pi + pointAngle
        end
        changeSelection(1 + math.floor(pointAngle / angle))
    end
end

local function onMouseWheel(vertical: number, _)
    if not inputWidget then return end
    local current = state:current()
    local numItems = #current.listing.items
    vertical = math.max(math.min(vertical, 1), -1)
    local newSelected = math.fmod(current.selectedItemIndex + vertical, numItems + 1)
    if newSelected == 0 then
        if vertical < 0 then
            newSelected = numItems
        else
            newSelected = 1
        end
    end
    changeSelection(newSelected as integer)
end

return {
    engineHandlers = {
        onMouseButtonRelease = onMouseButtonRelease,
        onMouseWheel = onMouseWheel,
        onKeyPress = onKeyPress,
        onFrame = onFrame,
        onLoad = onLoad,
        onSave = onSave,
    }
}