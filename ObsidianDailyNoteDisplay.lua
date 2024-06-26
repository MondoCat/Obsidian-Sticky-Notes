function Initialize()
    local date = os.date("*t")
    local formattedDate = string.format("%04d-%02d-%02d", date.year, date.month, date.day)
    obsidianPathIni = SELF:GetOption('obsidianPath')
    obsidianPathIni = string.gsub(obsidianPathIni, "\\", "\\\\")
    obsidianPath = obsidianPathIni .. ""
    sFileToRead = obsidianPath .. formattedDate .. ".md"
end

function Update()
    -- Update file on new day
    local date = os.date("*t")
    local formattedDate = string.format("%04d-%02d-%02d", date.year, date.month, date.day)
    sFileToRead = obsidianPath .. ".md"

    -- Read file
    local hReadingFile = io.open(sFileToRead, "r")
    local sAllText = "\n"

    -- Error handling
    if obsidianPathIni == "" then
        print("Error: File path is not present")
        return " Left click skin to input file path."
    end
    if not hReadingFile then
        print("Error: Unable to open file " .. sFileToRead)
        return " NO NOTE MATCHING TODAY'S DATE \n Create a note for today or re-enter file path. We're looking for:" .. sFileToRead
    end

    -- Process file if it is successfully opened
    for line in hReadingFile:lines() do
        -- Replace tab characters with spaces
        line = string.gsub(line, "\t", "    ")

        -- Insert unicode characters to reflect checkboxes
        line = string.gsub(line, "- %[%s%]", "⬜")
        line = string.gsub(line, "- %[x%]", "■")

        -- Insert unicode character replacement for bullet points
        line = string.gsub(line, "^(%s*)%-", "%1•")

        -- Remove text inside parentheses if it comes directly after text within brackets (for links)
        line = string.gsub(line, "(%[.-%])%b()", "%1")

        -- Check if the line is longer than 50 characters and process if necessary
        if string.len(line) > 50 then
            local newLines = {}
            local spaceCount = #string.match(line, "^(%s*)") -- Count leading spaces

            while string.len(line) > 50 do
                local cutOff = 50
                -- Find the position of the last space before the cutoff
                for i = 50, 1, -1 do
                    if string.sub(line, i, i) == " " then
                        cutOff = i
                        break
                    end
                end

                -- Extract the kept text
                local keptText = string.sub(line, 1, cutOff)
                table.insert(newLines, keptText)

                -- Prepare the next line with leading spaces
                line = string.rep(" ", spaceCount) .. "     " .. string.sub(line, cutOff + 1)
            end

            -- Add any remaining part of the line
            if string.len(line) > 0 then
                table.insert(newLines, line)
            end

            -- Combine the lines into one string with newlines
            line = table.concat(newLines, "\n")
        end

        -- Add a "-" character to lines not starting with "#" and not empty to bring them in line with heading objects.
        if not string.match(line, "^#") and line ~= "" then
            line = "-  " .. line
        end

        -- Append the processed line to the rest of the text
        sAllText = sAllText .. line .. "\n"
    end

    -- Close the file
    hReadingFile:close()

    -- Relative font sizes for headings and other settings...
    local desiredFontSize = 12 
    SKIN:Bang('!SetOption', 'MeterDisplay', 'FontSize', desiredFontSize)
    -- Heading 1
    SKIN:Bang('!SetOption', 'MeterDisplay', 'InlineSetting2', 'Size | ' .. desiredFontSize * 2)
    SKIN:Bang('!SetOption', 'MeterDisplay', 'InlineSetting26', 'Size | ' .. desiredFontSize * 2)
    -- Heading 2
    SKIN:Bang('!SetOption', 'MeterDisplay', 'InlineSetting6', 'Size | ' .. desiredFontSize * 1.6)
    -- Heading 3
    SKIN:Bang('!SetOption', 'MeterDisplay', 'InlineSetting9', 'Size | ' .. desiredFontSize * 1.5)

    return sAllText
end