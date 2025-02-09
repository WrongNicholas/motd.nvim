local M = {}

-- Function to get plugin path dynamically
local function get_plugin_path()
    -- Get the path of the current script (i.e., init.lua)
    local path = debug.getinfo(1, "S").source:sub(2):match("(.*/lua/)")
    return path and path .. "motd/motd.txt" or nil
end

-- Function to read ASCII art from motd.txt
local function read_motd()
    local file_path = get_plugin_path()
    if not file_path then
        return { "Error: Could not locate motd.txt" }
    end

    local file = io.open(file_path, "r")
    if not file then
        return { "Error: Could not read motd.txt" }
    end

    local lines = {}
    for line in file:lines() do
        table.insert(lines, line)
    end
    file:close()
    return lines
end

-- Function to show MOTD only when no file is provided
function M.show_motd()
    -- If Neovim was opened with files, don't show the MOTD
    if vim.fn.argc() > 0 then
        return
    end

    -- Create a new buffer
    local buf = vim.api.nvim_create_buf(false, true) -- No file, temporary buffer
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, read_motd())
    vim.api.nvim_buf_set_option(buf, "modifiable", false) -- Read-only buffer
    vim.api.nvim_buf_set_option(buf, "buftype", "nofile") -- Prevent saving
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe") -- Close automatically

    -- Set the buffer as the current window
    vim.api.nvim_set_current_buf(buf)

    vim.api.nvim_create_autocmd("BufEnter", {
        callback = function()
            if vim.api.nvim_get_current_buf() ~= buf then
                vim.cmd("BufferClose " .. buf) -- Barbar's command to close the buffer
            end
        end,
    })
  end

return M

