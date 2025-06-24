local M = {}

-- Function to get the plugin directory
local function get_plugin_path()
    local path = debug.getinfo(1, "S").source:sub(2):match("(.*/lua/)")
    return path and path .. "motd/resources/" or nil
end

-- Function to read ASCII art from ascii.txt
-- Function to read ASCII art from ascii.txt
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

-- Function to show MOTD centered both vertically and horizontally
function M.show_motd()
    -- If Neovim was opened with files, don't show the MOTD
    if vim.fn.argc() > 0 then return end

    -- Get the initial buffer (usually buffer 1)
    local initial_buf = vim.api.nvim_get_current_buf()

    -- Read ASCII art and quote
    local motd_ascii = read_ascii()

    -- Combine ASCII art and quote
    table.insert(motd_ascii)

    -- Get window width and height
    local win_width = vim.o.columns
    local win_height = vim.o.lines

    -- Function to center a line horizontally
    local function center_line(line)
        local line_length = #line
        if line_length < win_width then
            local spaces_to_add = math.floor((win_width - line_length) / 2)
            return string.rep(" ", spaces_to_add) .. line
        else
            return line  -- No centering if line is wider than the window
        end
    end

    -- Center each line horizontally
    for i, line in ipairs(motd_ascii) do
        motd_ascii[i] = center_line(line)
    end

    -- Calculate vertical padding (lines above and below content)
    local total_content_height = #motd_ascii
    local padding_top = math.floor((win_height - total_content_height) / 2)
    local padding_bottom = win_height - total_content_height - padding_top

    -- Create padding before and after content
    local padded_content = {}

    -- Add top padding
    for i = 1, padding_top do
        table.insert(padded_content, "")
    end

    -- Add centered content
    for _, line in ipairs(motd_ascii) do
        table.insert(padded_content, line)
    end

    -- Add bottom padding
    for i = 1, padding_bottom do
        table.insert(padded_content, "")
    end

    -- Create a new buffer
    local buf = vim.api.nvim_create_buf(false, true) -- No file, temporary buffer
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, padded_content)
    vim.api.nvim_buf_set_option(buf, "modifiable", false) -- Read-only buffer
    vim.api.nvim_buf_set_option(buf, "buftype", "nofile") -- Prevent saving
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe") -- Close automatically
    vim.api.nvim_buf_set_option(buf, "buflisted", false)

    -- Set the buffer as the current window
    vim.api.nvim_set_current_buf(buf)

    -- If the initial buffer was `[No Name]` and it's still open, delete it
    if vim.api.nvim_buf_is_valid(initial_buf) and vim.bo[initial_buf].buflisted then
        vim.api.nvim_buf_delete(initial_buf, { force = true })
    end
end

return M

