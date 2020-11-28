if not cellestiall then
    cellestiall = {status = "loading"}
    return cellestiall
end
if not cellestial then
    error("World of Life (cellestiall) depends on 3D Cellular Automata (cellestial)")
end
-- Unregister item removal chatcommands
minetest.unregister_chatcommand"pulverize"
minetest.unregister_chatcommand"clearinv"
-- No inventory actions
minetest.register_allow_player_inventory_action(function() return 0 end)
-- Hand item
local override = minetest.register_item
if minetest.registered_items[":"] then
    override = minetest.override_item
end
override(":", {
    type = "none",
    wield_image = "wieldhand.png",
    wield_scale = {x=1, y=1, z=2.5},
    tool_capabilities = {
        full_punch_interval = 0.9,
        max_drop_level = 0,
        groupcaps = {
            oddly_breakable_by_hand = {times={[1]=3.50,[2]=2.00,[3]=0.70}, uses=0}
        }
    }
})
cellestiall.status = "loaded"
cellestiall.after_cellestial_loaded = function()
    for _, item in pairs({ "cell", "wand" }) do
        minetest.override_item("cellestial:" .. item, { on_drop = function() end })
    end
end
minetest.override_item("air", { light_source = minetest.LIGHT_MAX })
cellestial.conf.creative = true
local textures = {}
local skybox = {}
for i = 1, 6 do
    textures[i] = "cellestial_cell.png"
    skybox[i] = "cellestial_border.png"
end
minetest.register_on_newplayer(function(player)
    cellestial.show_help(player:get_player_name())
end)
minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    player:set_properties{
        visual = "cube",
        visual_size = { x = 0.99, y = 0.99, z = 0.99 },
        collisionbox = { -0.5, -0.5, -0.5, 0.4, 0.4, 0.4 },
        pointable = false,
        textures = textures,
        eye_height = 0.1
    }
    player:set_hp(20)
    player:set_breath(10)
    player:hud_set_flags{
        hotbar = true,
        healthbar = false,
        crosshair = true,
        wielditem = true,
        breathbar = false,
        minimap = true,
        minimap_radar = true
    }
    player:set_properties{glow = 14}
    player:hud_set_hotbar_itemcount(2)
    local inv = player:get_inventory()
    local wand = inv:get_stack("main", 2)
    inv:set_lists{ main = { ItemStack("cellestial:cell"), (wand:get_name() == "cellestial:wand" and wand) or ItemStack("cellestial:wand") } }
    inv:set_width("main", 2)
    player:set_inventory_formspec(cellestial.help_formspec)
    player:hud_set_hotbar_image("gui_hotbar.png")
    player:hud_set_hotbar_selected_image("gui_hotbar_selected.png")
    player:set_formspec_prepend("background9[0,0;0,0;cellestial_border.png;true;1]")
    minetest.set_player_privs(name, modlib.table.add_all(minetest.get_player_privs(name), { fly = true, fast = true }))
    if player:get_meta():get_string("cellestial_arena_ids") == "" then
        local arena = cellestial.arena.create_free{owners = {name}}
        arena:teleport(player)
    end
    if player.get_stars then
        player:set_sky{
            type = "skybox",
            base_color = cellestial.colors.cell.fill,
            textures = skybox,
            clouds = false
        }
        player:set_sun{
            visible = true,
            sunrise_visible = false,
            texture = "cellestial_cell.png",
        }
        player:set_moon{
            visible = true,
            texture = "cellestial_cell.png",
        }
    else
        player:set_sky(cellestial.colors.cell.fill, "skybox", skybox, false)
    end
end)
-- disable damage
minetest.register_on_player_hpchange(function(player)
    local hp = player:get_hp()
    if hp < 20 then
        return 20 - hp
    end
    return 0
end, true)
-- constant high noon
minetest.register_globalstep(function()
    minetest.set_timeofday(0.5)
end)