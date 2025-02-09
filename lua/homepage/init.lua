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

    -- Get window dimensions
    local width = vim.api.nvim_win_get_width(0)
    local height = vim.api.nvim_win_get_height(0)

    -- Center ASCII art and text vertically
    local total_content_height = #ascii_art + 2 + #welcome_message
    local pad_top = math.floor((height - total_content_height) / 2)

    -- Set the ASCII art in the buffer
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {})

    local ns_id = vim.api.nvim_create_namespace("ascii_ns")

    -- Define highlight groups
    vim.api.nvim_set_hl(0, "AsciiBlue",  { fg = "#00AFFF", bold = true })   -- Bright Blue
    vim.api.nvim_set_hl(0, "AsciiWhite", { fg = "#FFFFFF", bold = true })   -- Normal White

    -- Center ASCII horizontally
    for i, line in ipairs(ascii_art) do
        local padding = math.floor((width - #line) / 2)
        local padded_line = string.rep(" ", math.max(0, padding)) .. line
        vim.api.nvim_buf_set_lines(0, i - 1, i, false, { padded_line })

        -- Split ASCII horizontally (color left half blue, right half white)
        local mid_col = math.floor(#padded_line / 2)

        -- Apply blue highlight to the first half
        vim.api.nvim_buf_add_highlight(0, ns_id, "AsciiBlue", i - 1, padding, padding + mid_col)

        -- Apply white highlight to the second half
        vim.api.nvim_buf_add_highlight(0, ns_id, "AsciiWhite", i - 1, padding + mid_col, padding + #padded_line)
    end

    -- Define a highlight group for "Sisyphus"
    vim.api.nvim_set_hl(0, "SisyphusHighlight", { fg = "#FF5733", bold = true })

    -- Center and highlight "Sisyphus" in the quote
    local quote_line = pad_top + #ascii_art + 2
    local quote_text = "One must imagine Sisyphus happy."
    vim.api.nvim_buf_set_lines(0, quote_line, quote_line + 1, false, { quote_text, "- Albert Camus" })

    -- Find "Sisyphus" and highlight it
    local start_col, end_col = string.find(quote_text, "Sisyphus")
    if start_col and end_col then
        vim.api.nvim_buf_add_highlight(0, ns_id, "SisyphusHighlight", quote_line, start_col - 1, end_col)
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

