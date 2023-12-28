function Initialize()
    sFileToRead = SELF:GetOption('FileToRead')
end

function Update()
    local hReadingFile = io.open(sFileToRead, "r")
    if not hReadingFile then
        print('ObsidianDailyNoteDisplay: unable to open file at ' .. sFileToRead)
        return ""
    end

    local sAllText = "\n"
    for line in hReadingFile:lines() do
        -- Replace tab characters with spaces
        line = string.gsub(line, "\t", "    ")
		
		-- Add extra space between brackets in the specific pattern "[ ]" to make the checkbox appear more square
        line = string.gsub(line, "%[%s%]", "⬜")
		
		-- Capitalize the "x" generated by Obsidian on checked boxes to make the checkbox appear fuller
        line = string.gsub(line, "%[x%]", "■")
		
		-- Remove text inside parentheses if it comes directly after text within brackets
        line = string.gsub(line, "(%[.-%])%b()", "%1")
		
        -- Check if the line is longer than 50 characters and truncate if necessary
        if string.len(line) > 60 then
            line = string.sub(line, 1, 60) .. "..."
        end
		
        -- Add a "-" character to lines not starting with "#" and not empty to bring them in line with heading objects.
        if not string.match(line, "^#") and line ~= "" then
            line = "-  " .. line
        end

        -- Append the processed line to the rest of the text
        sAllText = sAllText .. line .. "\n"
    end

    hReadingFile:close()

    return sAllText
end
