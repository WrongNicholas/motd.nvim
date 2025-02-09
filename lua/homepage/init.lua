local M = {}

-- Helper function to center text within a given width
local function center_text(text, width)
    local padding = math.floor((width - #text) / 2)
    return string.rep(" ", math.max(0, padding)) .. text
end

-- Function to create a fully padded screen
local function create_fullscreen_buffer(ascii_art, welcome_message)
    local width, height = vim.api.nvim_win_get_width(0), vim.api.nvim_win_get_height(0)
    local total_content_height = #ascii_art + 2 + #welcome_message
    local pad_top = math.floor((height - total_content_height) / 2)
    local padded_lines = {}

    -- Fill the buffer with empty lines
    for _ = 1, height do
        table.insert(padded_lines, "")
    end

    -- Add ASCII art
    for i, line in ipairs(ascii_art) do
        padded_lines[pad_top + i] = center_text(line, width)
    end

    -- Add spacing
    padded_lines[pad_top + #ascii_art + 1] = ""
    padded_lines[pad_top + #ascii_art + 2] = ""

    -- Add welcome message
    for i, line in ipairs(welcome_message) do
        padded_lines[pad_top + #ascii_art + 2 + i] = center_text(line, width)
    end

    return padded_lines
end

function M.open_homepage()
    vim.cmd("enew")
    local buf = vim.api.nvim_get_current_buf()
    vim.bo[buf].buftype, vim.bo[buf].bufhidden, vim.bo[buf].swapfile, vim.bo[buf].buflisted = "nofile", "wipe", false, false

    local ascii_art = {
        "  _____                   _____            ____  ____ ",
        " |\\    \\   _____     ____|\\    \\          |    ||    |",
        " | |    | /    /|   /     /\\    \\         |    ||    |",
        " \\/     / |    ||  /     /  \\    \\        |    ||    |",
        " /     /_  \\   \\/ |     |    |    | ____  |    ||    |",
        "|     // \\  \\   \\ |     |    |    ||    | |    ||    |",
        "|    |/   \\ |    ||\\     \\  /    /||    | |    ||    |",
        "|\\ ___/\\   \\|   /|| \\_____\\/____/ ||\\____\\|____||____|",
        "| |   | \\______/ | \\ |    ||    | /| |    |    ||    |",
        " \\|___|/\\ |    | |  \\|____||____|/  \\|____|____||____|",
        "    \\(   \\|____|/      \\(    )/        \\(   )/    \\(  ",
        "     '      )/          '    '          '   '      '  ",
        "            '                                         ",
    }

    local welcome_message = {
        "One must imagine Sisyphus happy.",
        "-Albert Camus",
    }

    local padded_lines = create_fullscreen_buffer(ascii_art, welcome_message)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, padded_lines)
end

function M.setup()
    vim.api.nvim_create_autocmd("VimEnter", {
        pattern = "*",
        callback = function()
            if vim.fn.argc() == 0 then
                M.open_homepage()
            end
        end
    })
end

return M

