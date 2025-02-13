local M = {}

-- Function to get the plugin directory
local function get_plugin_path()
    local path = debug.getinfo(1, "S").source:sub(2):match("(.*/lua/)")
    return path and path .. "motd/resources/" or nil
end

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
            table.insert(ascii_entries, trimmed_entry)
        end
    end

    -- Pick a random ASCII art
    if #ascii_entries > 0 then
        return vim.split(ascii_entries[math.random(#ascii_entries)], "\n")
    end

    return { "Error: No ASCII art found in ascii.txt" }
end

-- Function to read a random quote from quotes.txt
local function read_quote()
    local file_path = get_plugin_path() .. "quotes.txt"
    local file = io.open(file_path, "r")
    if not file then return "Error: Could not read quotes.txt" end

    local quotes = {}
    for line in file:lines() do
        if line ~= "" then table.insert(quotes, line) end
    end
    file:close()

    -- Pick a random quote
    if #quotes > 0 then
        return quotes[math.random(#quotes)]
    end

    return "Error: No quotes found in quotes.txt"
end

-- Function to show MOTD only when no file is provided
function M.show_motd()
    -- If Neovim was opened with files, don't show the MOTD
    if vim.fn.argc() > 0 then return end

    -- Get the initial buffer (usually buffer 1)
    local initial_buf = vim.api.nvim_get_current_buf()

    -- Read ASCII art and quote
    local motd_ascii = read_ascii()
    local motd_quote = read_quote()

    -- Combine ASCII art and quote
    table.insert(motd_ascii, "")
    table.insert(motd_ascii, motd_quote)

    -- Create a new buffer
    local buf = vim.api.nvim_create_buf(false, true) -- No file, temporary buffer
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, motd_ascii)
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

