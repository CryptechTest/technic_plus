
local S = technic.getter
local mat = technic.materials
local mesecons_materials = minetest.get_modpath("mesecons_materials")

local function drop_raw_latex(pointed_thing, user)
	if minetest.get_modpath("mcl_core") then
		minetest.add_item(user:get_pos(), "technic:raw_latex")
	else
		minetest.handle_node_drops(pointed_thing.above, {"technic:raw_latex"}, user)
	end
end

minetest.register_tool("technic:treetap", {
	description = S("Tree Tap"),
	inventory_image = "technic_tree_tap.png",
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		local pos = pointed_thing.under
		if minetest.is_protected(pos, user:get_player_name()) then
			minetest.record_protection_violation(pos, user:get_player_name())
			return
		end
		local node = minetest.get_node(pos)
		local node_name = node.name
		if node_name ~= "moretrees:rubber_tree_trunk" then
			return
		end
		node.name = "moretrees:rubber_tree_trunk_empty"
		minetest.swap_node(pos, node)
		drop_raw_latex(pointed_thing, user)
		if not technic.creative_mode then
			local item_wear = tonumber(itemstack:get_wear())
			item_wear = item_wear + 819
			if item_wear > 65535 then
				itemstack:clear()
				return itemstack
			end
			itemstack:set_wear(item_wear)
		end
		return itemstack
	end,
})

minetest.register_craft({
	output = "technic:treetap",
	recipe = {
		{"pipeworks:tube_1", "group:wood",    mat.stick},
		{"",               mat.stick, mat.stick}
	},
})

minetest.register_craftitem("technic:raw_latex", {
	description = S("Raw Latex"),
	inventory_image = "technic_raw_latex.png",
})

if mesecons_materials then
	minetest.register_craft({
		type = "cooking",
		recipe = "technic:raw_latex",
		output = "mesecons_materials:glue",
	})
end

minetest.register_craftitem("technic:rubber", {
	description = S("Rubber Fiber"),
	inventory_image = "technic_rubber.png",
})

minetest.register_abm({
	label = "Tools: tree tap",
	nodenames = {"moretrees:rubber_tree_trunk_empty"},
	interval = 60,
	chance = 15,
	action = function(pos, node)
		local radius = (moretrees and moretrees.leafdecay_radius) or 5
		local nodes = minetest.find_node_near(pos, radius, {"moretrees:rubber_tree_leaves"})
		if nodes then
			node.name = "moretrees:rubber_tree_trunk"
			minetest.swap_node(pos, node)
		end
	end
})

