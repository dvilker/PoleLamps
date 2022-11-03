local poleLamp = table.deepcopy(data.raw["lamp"]["small-lamp"])
poleLamp.name = "pole-lamp"
poleLamp.minable = nil
poleLamp.next_upgrade = nil
poleLamp.flags = { "not-blueprintable", "not-deconstructable", "placeable-off-grid", "not-on-map"}
poleLamp.selectable_in_game = false
poleLamp.collision_box = { { -0.1, -0.1}, { 0.1, 0.1}}
poleLamp.selection_box = { { -0.4, -0.4}, { 0.4, 0.4}}
poleLamp.collision_mask = { "resource-layer" }
poleLamp.energy_usage_per_tick = "1kW"
data:extend({ poleLamp })
