local M = {}

local function get_plugin_path()
    local path = debug.getinfo(1, "S").source:sub(2):match("(.*/lua/)")
    return path and path .. "motd/resources/" or nil
end

local function read_ascii()
    local file_path = get_plugin_path() .. "ascii.txt"
    local file = io.open(file_path, "r")
    if not file then return { "Error: Could not read ascii.txt" } end

    local content = file:read("*all")
    file:close()

    -- Split ASCII art by "---"
    local ascii_entries = {}
    for entry in content:gmatch("[^%-]+") do
        local trimmed_entry = entry:gsub("^%s+", ""):gsub("%s+$", "")
        if trimmed_entry ~= "" then
            -- Preserve leading spaces by avoiding gsub on the entry itself
            table.insert(ascii_entries, entry)
        end
    end

    -- Pick a random ASCII art
    if #ascii_entries > 0 then
        return vim.split(ascii_entries[math.random(#ascii_entries)], "\n")
    end

    return { "Error: No ASCII art found in ascii.txt" }
end

function M.show_motd()
    if vim.fn.argc() > 0 then return end
    local initial_buf = vim.api.nvim_get_current_buf()
    local motd_ascii = read_ascii()
    table.insert(motd_ascii, "")

    local win_width = vim.o.columns
    local win_height = vim.o.lines

    local function center_line(line)
        local line_length = #line
        if line_length < win_width then
            local spaces_to_add = math.floor((win_width - line_length) / 2)
            return string.rep(" ", spaces_to_add) .. line
        else
            return line
        end
    end

    for i, line in ipairs(motd_ascii) do
        motd_ascii[i] = center_line(line)
    end

    local total_content_height = #motd_ascii
    local padding_top = math.floor((win_height - total_content_height) / 2)
    local padding_bottom = win_height - total_content_height - padding_top

    local padded_content = {}

    for i = 1, padding_top do
        table.insert(padded_content, "")
    end

    for _, line in ipairs(motd_ascii) do
        table.insert(padded_content, line)
    end

    for i = 1, padding_bottom do
        table.insert(padded_content, "")
    end

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, padded_content)
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
    vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
    vim.api.nvim_buf_set_option(buf, "buflisted", false)

    vim.api.nvim_set_current_buf(buf)

    if vim.api.nvim_buf_is_valid(initial_buf) and vim.bo[initial_buf].buflisted then
        vim.api.nvim_buf_delete(initial_buf, { force = true })
    end
end

return M

