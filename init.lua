if not cellestiall then
    cellestiall = {status = "loading"}
    return cellestiall
end
if not cellestial then
    error("World of Life (cellestiall) depends on 3D Cellular Automata (cellestial)")
end
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
    player:set_properties({
        visual = "cube",
        visual_size = { x = 1, y = 1, z = 1 },
        collisionbox = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
        pointable = false,
        textures = textures,
        eye_height = 0
    })
    player:set_hp(20)
    player:set_breath(10)
    player:hud_set_flags({
        hotbar = true,
        healthbar = false,
        crosshair = true,
        wielditem = true,
        breathbar = false,
        minimap = true,
        minimap_radar = true
    })
    player:hud_set_hotbar_itemcount(2)
    local inv = player:get_inventory()
    local wand = inv:get_stack("main", 2)
    inv:set_lists({ main = { ItemStack("cellestial:cell"), (wand:get_name() == "cellestial:wand" and wand) or ItemStack("cellestial:wand") } })
    inv:set_width("main", 2)
    player:set_inventory_formspec(cellestial.help_formspec)
    player:set_formspec_prepend("background9[0,0;0,0;cellestial_border.png;true;1]")
    minetest.set_player_privs(name, modlib.table.add_all(minetest.get_player_privs(name), { fly = true, fast = true }))
    if player:get_meta():get_string("cellestial_arena_ids") == "" then
        local arena = cellestial.arena.create_free({ owners = { name } })
        arena:teleport(player)
    end
    if player.get_stars then
        player:set_sky({
            type = "skybox",
            base_color = cellestial.colors.cell.fill,
            textures = skybox,
            clouds = false
        })
        local sun = {
            visible = true,
            texture = "cellestial_cell.png",
        }
        if player.set_sun then
            player:set_sun(sun)
        end
        if player.set_moon then
            player:set_moon(sun)
        end
        if player.set_stars then
            player:set_stars({
                count = 100,
                color = cellestial.colors.cell.fill
            })
        end
    else
        player:set_sky(cellestial.colors.cell.fill, "skybox", skybox, false)
    end
end)
-- disable damage
minetest.register_on_player_hpchange(function()
    return 0
end, true)