Ammo_handler = Instantiatable_class:inherit({
    name = "Ammo_handler",
    construct = function(def)
        if def.instance then
            assert(def.gun, "no gun")
            def.itemstack = def.gun.itemstack
            def.handler = def.gun.handler
            def.inventory = def.handler.inventory
            local meta = def.gun.meta
            local gun = def.gun
            def.ammo = {}
            if gun.properties.magazine then
                if meta:get_string("guns4d_loaded_bullets") == "" then
                    meta:set_string("guns4d_loaded_mag", gun.properties.magazine.comes_with or "empty")
                    meta:set_string("guns4d_next_bullet", "empty")
                    meta:set_int("guns4d_total_bullets", 0)
                    meta:set_string("guns4d_loaded_bullets", minetest.serialize({}))
                    def.ammo.loaded_mag = "empty"
                    def.ammo.next_bullet = "empty"
                    def.ammo.total_bullets = 0
                    def.ammo.bullets = {}
                else
                    def.ammo.loaded_mag = meta:get_string("guns4d_loaded_mag")
                    def.ammo.bullets = minetest.deserialize(meta:get_string("guns4d_loaded_bullets"))
                    def.ammo.total_bullets = meta:get_int("guns4d_total_bullets")
                    def.ammo.next_bullet = meta:get_string("guns4d_next_bullet")
                end
            end
        end
    end
})
--spend the round, return false if impossible.
function Ammo_handler:spend_round()
    local bullet_spent = self.ammo.next_bullet
    local meta = self.gun.meta
    --subtract the bullet
    if self.ammo.total_bullets > 0 then
        self.ammo.bullets[bullet_spent] = self.ammo.bullets[bullet_spent]-1
        if self.ammo.bullets[bullet_spent] == 0 then self.ammo.bullets[bullet_spent] = nil end
        self.ammo.total_bullets = self.ammo.total_bullets - 1
        meta:set_string("guns4d_loaded_bullets", minetest.serialize(self.ammo.bullets))

        --set the new current bullet
        if next(self.ammo.bullets) then
            self.ammo.next_bullet = math.weighted_randoms(self.ammo.bullets)
            meta:set_string("guns4d_next_bullet", self.ammo.next_bullet)
        else
            self.ammo.next_bullet = "empty"
            meta:set_string("guns4d_next_bullet", "empty")
        end
    else
        return false
    end
end
function Ammo_handler:load_mag()
    local inv = self.inventory
    local magstack_index
    local highest_ammo = 0
    local gun = self.gun
    local gun_accepts = gun.accepted_ammo
    for i, v in pairs(inv:get_list("main")) do
        if gun_accepts[v:get_name()] then
            local meta = v:get_meta()
            if meta:get_int("guns4d_total_bullets") > highest_ammo then
                magstack_index = i
            end
        end
    end
    if magstack_index then
        local magstack = inv:get_stack("main", magstack_index)
        local magstack_meta = magstack:get_meta()
        --get the ammo stuff
        local meta = self.gun.meta

        self.ammo.loaded_mag = magstack:get_name()
        self.ammo.bullets = minetest.deserialize(magstack_meta:get_string("guns4d_loaded_bullets"))
        self.ammo.total_bullets = magstack_meta:get_int("guns4d_total_bullets")
        self.ammo.next_bullet = magstack_meta:get_string("guns4d_next_bullet")
        --
        meta:set_string("guns4d_loaded_mag", self.ammo.loaded_mag)
        meta:set_string("guns4d_loaded_bullets", magstack_meta:get_string("guns4d_loaded_bullets"))
        meta:set_int("guns4d_total_bullets", self.ammo.total_bullets)
        meta:set_string("guns4d_next_bullet", self.ammo.next_bullet)


        inv:set_stack("main", magstack_index, "")
        return
    end
end

function Ammo_handler:unload_mag()
end
function Ammo_handler:load_magless()
end
function Ammo_handler:unload_magless()
end
function Ammo_handler:load_fractional()
end
function Ammo_handler:unload_fractional()
end
function Ammo_handler:unload_chamber()
end