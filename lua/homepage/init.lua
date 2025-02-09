local M = {}

-- Function to create a fully padded screen
local function create_fullscreen_buffer(ascii_art, welcome_message)
    local width = vim.api.nvim_win_get_width(0)   -- Get window width
    local height = vim.api.nvim_win_get_height(0) -- Get window height

    local total_content_height = #ascii_art + 2 + #welcome_message  -- Total height including ASCII and spacing
    local pad_top = math.floor((height - total_content_height) / 2)  -- Calculate vertical centering

    local padded_lines = {}

    -- Fill the buffer with empty lines first (ensures line numbers extend fully)
    for _ = 1, height do
        table.insert(padded_lines, "")
    end

    -- Place ASCII art at the correct vertical position
    for i, line in ipairs(ascii_art) do
        local padding = math.floor((width - #line) / 2)
        padded_lines[pad_top + i] = string.rep(" ", math.max(0, padding)) .. line
    end

    -- Add spacing between ASCII and welcome message
    padded_lines[pad_top + #ascii_art + 1] = ""
    padded_lines[pad_top + #ascii_art + 2] = ""

    -- Center the welcome message
    for i, line in ipairs(welcome_message) do
        local padding = math.floor((width - #line) / 2)
        padded_lines[pad_top + #ascii_art + 2 + i] = string.rep(" ", math.max(0, padding)) .. line
    end

    return padded_lines
end

function M.open_homepage()
    vim.cmd("enew")
    vim.bo[0].buftype = "nofile"
    vim.bo[0].bufhidden = "wipe"
    vim.bo[0].swapfile = false
    vim.bo[0].buflisted = false

    -- Define ASCII art
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

    -- Define a simple welcome message
    local welcome_message = {
        "One must imagine Sisyphus happy.",
        "- Albert Camus",
    }

    -- Generate a fully padded screen with ASCII art and a welcome message
    local padded_lines = create_fullscreen_buffer(ascii_art, welcome_message)

    -- Set buffer content
    vim.api.nvim_buf_set_lines(0, 0, -1, false, padded_lines)

    -- Get the current buffer
    local buf = vim.api.nvim_get_current_buf()

    -- Define highlight groups (Run :highlight in Neovim to see available groups)
    vim.cmd("highlight MyAsciiArt guifg=#00aaff")  -- Blue ASCII Art
    vim.cmd("highlight MyHighlightWord guifg=#ff0000 gui=bold")  -- Red for "Sisyphus"

    -- Highlight ASCII Art
    for i = 1, #ascii_art do
        vim.api.nvim_buf_add_highlight(buf, 0, "MyAsciiArt", i - 1, 0, -1)
    end

    -- Find "Sisyphus" in the welcome message and highlight it
    local message_index = #ascii_art + 2 + 1  -- Adjusted position for message
    local message_line = padded_lines[message_index]

    local start_col, end_col = message_line:find("Sisyphus")
    if start_col and end_col then
        vim.api.nvim_buf_set_extmark(buf, vim.api.nvim_create_namespace(""), message_index - 1, start_col - 1, {
            end_col = end_col,
            hl_group = "MyHighlightWord"
        })
    end
end

-- Function to trigger on startup
function M.setup()
    vim.api.nvim_create_autocmd("VimEnter", {
        pattern = "*",
        callback = function()
            if vim.fn.argc() == 0 then  -- Only if no files were opened
                M.open_homepage()
            end
        end
    })
end

return M
