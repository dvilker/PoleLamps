---@type table<string, true>
local excluded = {}
for name in string.gmatch(settings.global["polelamps_expluded"].value, '([^ ]+)') do
    excluded[name] = true
end

local function polePlaced(event)
    local entity = event.created_entity or event.entity
    if entity and entity.valid and entity.type == "electric-pole" and not excluded[entity.name] then
        local lamp = entity.surface.create_entity { name = "pole-lamp", position = entity.position, force = entity.force }
        lamp.destructible = false
        lamp.minable = false
    end
end

local function poleRemoved(event)
    local entity = event.entity
    if entity and entity.valid then
        local lamps = entity.surface.find_entities_filtered { name = "pole-lamp", position = entity.position }
        for _, lamp in pairs(lamps) do
            lamp.destroy()
        end
    end
end

local function poleMoved(event)
    local entity = event.moved_entity
    if entity and entity.valid and entity.type == "electric-pole" then
        local lamps = entity.surface.find_entities_filtered { name = "pole-lamp", position = event.start_pos }
        for _, lamp in pairs(lamps) do
            lamp.teleport(entity.position)
        end
    end
end

local function registerEvents()
    local poleFilter = { { filter = "type", type = "electric-pole" } }

    script.on_event(defines.events.on_built_entity, polePlaced, poleFilter)
    script.on_event(defines.events.on_robot_built_entity, polePlaced, poleFilter)
    script.on_event({ defines.events.script_raised_built, defines.events.script_raised_revive }, polePlaced)

    script.on_event(defines.events.on_pre_player_mined_item, poleRemoved, poleFilter)
    script.on_event(defines.events.on_entity_died, poleRemoved, poleFilter)
    script.on_event(defines.events.on_robot_pre_mined, poleRemoved, poleFilter)
    script.on_event(defines.events.script_raised_destroy, poleRemoved)

    if remote.interfaces["picker"] and remote.interfaces["picker"]["dolly_moved_entity_id"] then
        script.on_event(remote.call("picker", "dolly_moved_entity_id"), poleMoved)
    end
    if remote.interfaces["PickerDollies"] and remote.interfaces["PickerDollies"]["dolly_moved_entity_id"] then
        script.on_event(remote.call("PickerDollies", "dolly_moved_entity_id"), poleMoved)
    end
end


local function updateAllPoles()
    for _, surface in pairs(game.surfaces) do
        local lamps = surface.find_entities_filtered { name = "pole-lamp" }
        for _, lamp in pairs(lamps) do
            lamp.destroy()
        end
        local poles = surface.find_entities_filtered { type = "electric-pole" }
        for _, pole in pairs(poles) do
            if pole.valid and not excluded[pole.name] then
                local lamp = pole.surface.create_entity { name = "pole-lamp", position = pole.position, force = pole.force }
                lamp.destructible = false
                lamp.minable = false
            end
        end
    end
end

--script.on_load(function()
--    registerEvents()
--end)
--
--script.on_init(function()
--    registerEvents()
--end)

script.on_configuration_changed(function()
    updateAllPoles()
end)

registerEvents()
