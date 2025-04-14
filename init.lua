minetest.register_chatcommand("fov", {
    description = "Adjust the player's FOV using a scrollbar (70 to 170)",
    func = function(name)
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "Player not found."
        end

        local fov_min = 45
        local fov_max = 170
        local current_fov = player:get_fov()
        local slider_value = 0
        if current_fov >= fov_min and current_fov <= fov_max then
            slider_value = math.floor((current_fov - fov_min) * 1000 / (fov_max - fov_min))
        end

        local formspec =
			"formspec_version[7]" ..
			"size[6,2,false]" ..
			"no_prepend[]" ..
            "label[0.5,0.5;Current FOV: " .. current_fov .. "]" ..
            "scrollbar[0.5,1;5,0.4;horizontal;new_fov;" .. slider_value .. "]" ..
            "button_exit[1,2.5;4,1;exit;Quit]"

        minetest.show_formspec(name, "fov:main", formspec)
        return true
    end
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "fov:main" then
        return
    end

    local fov_min = 45
    local fov_max = 170
    if fields.new_fov then
        local raw_value = fields.new_fov
        if raw_value:sub(1, 4) == "CHG:" then
            local sanitized_value = raw_value:gsub("^CHG:", ""):gsub("^VAL:", "")
            local number_value = tonumber(sanitized_value)
            if number_value then
                local norm = number_value / 1000
                local new_fov = fov_min + norm * (fov_max - fov_min)
                new_fov = math.floor(new_fov + 0.5)
                player:set_fov(new_fov, false, 0)
            end
        end
    end

    if fields.exit then
        minetest.close_formspec(player:get_player_name(), "fov:main")
    end
end)
