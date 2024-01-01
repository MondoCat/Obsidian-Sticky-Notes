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
		
		-- Insert unicode characters to reflect checkboxes
		line = string.gsub(line, "- %[%s%]", "⬜")
        line = string.gsub(line, "- %[x%]", "■")

        -- Insert unicode character replacement for bullet points
        line = string.gsub(line, "^(%s*)%-", "%1•")
		
		-- Remove text inside parentheses if it comes directly after text within brackets
        line = string.gsub(line, "(%[.-%])%b()", "%1")
		
        -- Check if the line is longer than 50 characters and truncate if necessary
        if string.len(line) > 50 then
            local cutOff = 50
            -- Find the position of the last space before the cutoff
            for i = 50, 1, -1 do
                if string.sub(line, i, i) == " " then
                    cutOff = i
                    break
                end
            end

            -- Extract the kept and removed text
            local keptText = string.sub(line, 1, cutOff)
            local removedText = string.sub(line, cutOff + 1)

            -- Closing bracket cutoff check
            local lastOpenBracket = keptText:match(".*%[")
            local lastCloseBracket = keptText:match(".*%]")
            local addClosingBracket = false
            if lastOpenBracket and (not lastCloseBracket or lastOpenBracket > lastCloseBracket) then
                addClosingBracket = string.find(removedText, "]")
            end

            -- Bold tag cutoff check
            local boldTagCount = 0
            for _ in string.gmatch(keptText, "%*%*") do
                boldTagCount = boldTagCount + 1
            end
            
            -- Strikethrough tag cutoff check
            local strikethroughTagCount = 0
            for _ in string.gmatch(keptText, "%~%~") do
                strikethroughTagCount = strikethroughTagCount + 1
            end

            -- Truncate the line and add ellipses
            line = keptText

            -- Closing bracket cutoff fix
            if addClosingBracket then
                line = line .. "]"
            end
            
            -- Bold tag cutoff fix
            if boldTagCount % 2 == 1 then
                line = line .. "**"
            end

            -- Strikthrough cutoff fix
            if strikethroughTagCount % 2 == 1 then
                line = line .. "~~"
            end

            line = line .. "..."
        end

        -- Add a "-" character to lines not starting with "#" and not empty to bring them in line with heading objects.
        if not string.match(line, "^#") and line ~= "" then
            line = "-  " .. line
        end

        -- Append the processed line to the rest of the text
        sAllText = sAllText .. line .. "\n"
    end

    hReadingFile:close()

    --Relative font sizes for headings
    local desiredFontSize = 12 
    SKIN:Bang('!SetOption', 'MeterDisplay', 'FontSize', desiredFontSize)
    --Heading 1
    SKIN:Bang('!SetOption', 'MeterDisplay', 'InlineSetting2', 'Size | ' .. desiredFontSize*2)
    --Heading 2
    SKIN:Bang('!SetOption', 'MeterDisplay', 'InlineSetting6', 'Size | ' .. desiredFontSize*1.6)
    --Heading 3
    SKIN:Bang('!SetOption', 'MeterDisplay', 'InlineSetting9', 'Size | ' .. desiredFontSize*1.5)

    return sAllText

end