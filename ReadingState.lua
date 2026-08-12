






local ANCHOR_BYTES = 48
local BOOKMARK_EXCERPT_BYTES = 72
local BOOKMARK_LIMIT_PER_BOOK = 50
local SOFT_WRAP_MIN_CHARACTERS = 72
local L = ParchmentReader.L

local function Clamp(value, minimum, maximum)
    return math.max(minimum, math.min(value, maximum))
end

local function RoundMetric(value)
    return math.floor((tonumber(value) or 0) * 100 + 0.5) / 100
end

local function ContentHash(text)
    local hash = 5381
    for index = 1, #text do
        hash = (hash * 33 + text:byte(index)) % 2147483647
    end
    return hash
end

local function SnapUTF8Offset(text, rawOffset)
    local offset = Clamp(math.floor(tonumber(rawOffset) or 0), 0, #text)




    while offset > 0 do
        local nextByte = text:byte(offset + 1)
        if not nextByte or nextByte < 128 or nextByte >= 192 then
            break
        end
        offset = offset - 1
    end

    return offset
end

local function CountUTF8Characters(text)
    local count = 0
    for index = 1, #text do
        local byte = text:byte(index)
        if byte < 128 or byte >= 192 then
            count = count + 1
        end
    end
    return count
end

local function ReflowLongWrappedLines(text)
    local output = {}
    local lineStart = 1

    while true do
        local lineEnd = text:find("\n", lineStart, true)
        if not lineEnd then
            output[#output + 1] = text:sub(lineStart)
            break
        end

        local line = text:sub(lineStart, lineEnd - 1)
        local nextCharacter = text:sub(lineEnd + 1, lineEnd + 1)
        output[#output + 1] = line
        if nextCharacter ~= ""
            and nextCharacter ~= "\n"
            and CountUTF8Characters(line) >= SOFT_WRAP_MIN_CHARACTERS
        then

            output[#output + 1] = " "
        else
            output[#output + 1] = "\n"
        end
        lineStart = lineEnd + 1
    end

    return table.concat(output)
end

function ParchmentReader:NormalizeLayoutText(content)
    local text = type(content) == "string" and content or ""
    text = text:gsub("\r\n", "\n"):gsub("\r", "\n")
    return ReflowLongWrappedLines(text)
end

function ParchmentReader:SnapReadingOffset(content, offset)
    return SnapUTF8Offset(content, offset)
end

function ParchmentReader:GetContentRevision(book)
    local source = type(book.content) == "string" and book.content or ""

    if book._readingRevisionSource ~= source then
        book._readingRevisionSource = source
        book._readingRevision = string.format("%d:%d", ContentHash(source), #source)
    end

    return book._readingRevision
end

function ParchmentReader:BuildLayoutDescriptor(frame, book)
    local measureText = frame.readerMeasureText

    return {
        bookKey = self.currentBook or "",
        contentRevision = self:GetContentRevision(book),
        width = RoundMetric(frame.readerTextWidth or measureText:GetWidth()),
        height = RoundMetric(frame.contentScroll:GetHeight()),
        font = ParchmentReaderDB.fontName or "QuestFont",
        fontSize = tonumber(ParchmentReaderDB.fontSize) or 14,
        spacing = RoundMetric(measureText:GetSpacing()),
        scale = RoundMetric(frame:GetEffectiveScale()),
    }
end

function ParchmentReader:BuildLayoutSignature(descriptor)
    return table.concat({
        descriptor.contentRevision,
        descriptor.width,
        descriptor.height,
        descriptor.font,
        descriptor.fontSize,
        descriptor.spacing,
        descriptor.scale,
    }, "|")
end

function ParchmentReader:BuildLayoutKey(descriptor)
    return descriptor.bookKey .. "|" .. self:BuildLayoutSignature(descriptor)
end

function ParchmentReader:DescribeLayoutChange(previous, current)
    if not previous then return "initial-layout" end
    if previous.bookKey ~= current.bookKey then return "book-changed" end
    if previous.contentRevision ~= current.contentRevision then return "content-changed" end
    if previous.width ~= current.width then return "width-changed" end
    if previous.height ~= current.height then return "height-changed" end
    if previous.font ~= current.font then return "font-changed" end
    if previous.fontSize ~= current.fontSize then return "font-size-changed" end
    if previous.spacing ~= current.spacing then return "spacing-changed" end
    if previous.scale ~= current.scale then return "scale-changed" end
    return "unchanged"
end

local function BuildAnchor(content, offset)
    local startOffset = SnapUTF8Offset(content, math.max(0, offset - ANCHOR_BYTES))
    local endOffset = SnapUTF8Offset(content, math.min(#content, offset + ANCHOR_BYTES))

    return content:sub(startOffset + 1, offset),
        content:sub(offset + 1, endOffset),
        startOffset
end

local function BuildAnchoredPosition(content, offset)
    local safeOffset = SnapUTF8Offset(content, offset)
    local before, after = BuildAnchor(content, safeOffset)
    return {
        version = 1,
        offset = safeOffset,
        progress = #content > 0 and safeOffset / #content or 0,
        contentLength = #content,
        before = before,
        after = after,
    }
end

function ParchmentReader:SaveReadingPosition(
    bookKey,
    content,
    offset,
    page,
    totalPages,
    layoutSignature)
    if not ParchmentReaderDB or not bookKey then return end

    local safeOffset = SnapUTF8Offset(content, offset)
    ParchmentReaderDB.bookPositions = ParchmentReaderDB.bookPositions or {}
    local position = ParchmentReaderDB.bookPositions[bookKey]
    if type(position) == "table"
        and position.version == 1
        and position.offset == safeOffset
        and position.contentLength == #content
        and position.page == page
        and position.totalPages == totalPages
        and position.layoutSignature == layoutSignature
    then
        position.updatedAt = time()
        return
    end

    local anchoredPosition = BuildAnchoredPosition(content, safeOffset)
    if type(position) ~= "table" then
        position = {}
        ParchmentReaderDB.bookPositions[bookKey] = position
    end

    position.version = anchoredPosition.version
    position.offset = anchoredPosition.offset
    position.progress = anchoredPosition.progress
    position.contentLength = anchoredPosition.contentLength
    position.before = anchoredPosition.before
    position.after = anchoredPosition.after
    position.page = page
    position.totalPages = totalPages
    position.layoutSignature = layoutSignature
    position.updatedAt = time()
end

function ParchmentReader:ResolveReadingPosition(content, position)
    if type(position) ~= "table" or position.version ~= 1 then
        return nil
    end

    local fallbackOffset
    if type(position.offset) == "number" then
        fallbackOffset = position.offset
    elseif type(position.progress) == "number" then
        fallbackOffset = #content * Clamp(position.progress, 0, 1)
    else
        return nil
    end
    fallbackOffset = SnapUTF8Offset(content, fallbackOffset)

    local before = type(position.before) == "string" and position.before or ""
    local after = type(position.after) == "string" and position.after or ""
    local anchor = before .. after
    if anchor == "" then
        return fallbackOffset
    end

    local bestOffset
    local bestDistance
    local searchAt = 1
    while true do
        local matchStart = content:find(anchor, searchAt, true)
        if not matchStart then break end

        local candidate = SnapUTF8Offset(content, matchStart - 1 + #before)
        local distance = math.abs(candidate - fallbackOffset)
        if not bestDistance or distance < bestDistance then
            bestOffset = candidate
            bestDistance = distance
        end
        searchAt = matchStart + 1
    end

    return bestOffset or fallbackOffset
end

function ParchmentReader:GetSavedReadingPosition(bookKey)
    local positions = ParchmentReaderDB and ParchmentReaderDB.bookPositions
    if not positions then return nil end
    return positions[bookKey]
end

function ParchmentReader:GetSavedReadingOffset(bookKey, content)
    return self:ResolveReadingPosition(
        content,
        self:GetSavedReadingPosition(bookKey))
end

local function GetBookmarkList(bookKey, create)
    if not ParchmentReaderDB or not bookKey then return nil end
    if create then
        ParchmentReaderDB.bookmarks = ParchmentReaderDB.bookmarks or {}
    end

    local bookmarks = ParchmentReaderDB.bookmarks
    if not bookmarks then return nil end
    if create and type(bookmarks[bookKey]) ~= "table" then
        bookmarks[bookKey] = {}
    end
    return bookmarks[bookKey]
end

local function NextBookmarkName(bookmarks)
    local highest = 0
    for _, bookmark in ipairs(bookmarks) do
        local number = type(bookmark) == "table"
            and (bookmark.autoNameIndex
                or type(bookmark.name) == "string"
                    and bookmark.name:match("^Bookmark (%d+)$"))
        highest = math.max(highest, tonumber(number) or 0)
    end
    local index = highest + 1
    return string.format(L["Bookmark %d"], index), index
end

local function NextBookmarkId(bookmarks)
    local base = tostring(time())
    local candidate = base
    local suffix = 1

    while true do
        local available = true
        for _, bookmark in ipairs(bookmarks) do
            if type(bookmark) == "table" and bookmark.id == candidate then
                available = false
                break
            end
        end
        if available then return candidate end
        suffix = suffix + 1
        candidate = base .. "-" .. suffix
    end
end

local function FindBookmark(bookmarks, bookmarkId)
    for index, bookmark in ipairs(bookmarks or {}) do
        if type(bookmark) == "table" and bookmark.id == bookmarkId then
            return bookmark, index
        end
    end
end

function ParchmentReader:GetBookmarks(bookKey)
    return GetBookmarkList(bookKey, false) or {}
end

function ParchmentReader:GetBookmarkLimit()
    return BOOKMARK_LIMIT_PER_BOOK
end

function ParchmentReader:AddBookmark(bookKey, content, offset)
    if type(content) ~= "string" or content == "" then
        return nil, "empty"
    end

    local bookmarks = GetBookmarkList(bookKey, true)
    if not bookmarks then return nil, "unavailable" end
    if #bookmarks >= BOOKMARK_LIMIT_PER_BOOK then
        return nil, "limit"
    end

    local anchoredPosition = BuildAnchoredPosition(content, offset)
    anchoredPosition.id = NextBookmarkId(bookmarks)
    anchoredPosition.name, anchoredPosition.autoNameIndex =
        NextBookmarkName(bookmarks)
    anchoredPosition.createdAt = time()
    bookmarks[#bookmarks + 1] = anchoredPosition
    return anchoredPosition
end

function ParchmentReader:ResolveBookmarkOffset(content, bookmark)
    if type(bookmark) ~= "table" then return nil end

    if type(bookmark.progress) == "number"
        and type(bookmark.contentLength) == "number"
        and bookmark.contentLength ~= #content
    then
        return self:ResolveReadingPosition(content, {
            version = bookmark.version,
            progress = bookmark.progress,
            before = bookmark.before,
            after = bookmark.after,
        })
    end

    return self:ResolveReadingPosition(content, bookmark)
end

function ParchmentReader:RefreshBookmarkAnchor(content, bookmark, offset)
    if type(bookmark) ~= "table" then return end
    local anchoredPosition = BuildAnchoredPosition(content, offset)
    bookmark.version = anchoredPosition.version
    bookmark.offset = anchoredPosition.offset
    bookmark.progress = anchoredPosition.progress
    bookmark.contentLength = anchoredPosition.contentLength
    bookmark.before = anchoredPosition.before
    bookmark.after = anchoredPosition.after
    bookmark.updatedAt = time()
end

function ParchmentReader:GetBookmarkExcerpt(content, bookmark)
    local offset = self:ResolveBookmarkOffset(content, bookmark)
    if offset == nil then return "" end

    local excerptStart = offset
    local excerptEnd = SnapUTF8Offset(
        content,
        math.min(#content, offset + BOOKMARK_EXCERPT_BYTES))
    if excerptEnd <= excerptStart then
        excerptStart = SnapUTF8Offset(
            content,
            math.max(0, offset - BOOKMARK_EXCERPT_BYTES))
        excerptEnd = offset
    end

    local excerpt = content:sub(excerptStart + 1, excerptEnd)
    excerpt = strtrim(excerpt:gsub("%s+", " "))
    if excerpt == "" then return L["End of book"] end
    return excerpt
end

function ParchmentReader:RenameBookmark(bookKey, bookmarkId, name)
    local bookmarks = GetBookmarkList(bookKey, false)
    local bookmark = FindBookmark(bookmarks, bookmarkId)
    local safeName = type(name) == "string" and strtrim(name) or ""
    if not bookmark or safeName == "" then return false end

    bookmark.name = safeName
    bookmark.updatedAt = time()
    return true
end

function ParchmentReader:DeleteBookmark(bookKey, bookmarkId)
    local bookmarks = GetBookmarkList(bookKey, false)
    local bookmark, index = FindBookmark(bookmarks, bookmarkId)
    if not bookmark then return nil end

    table.remove(bookmarks, index)
    if #bookmarks == 0 and ParchmentReaderDB.bookmarks then
        ParchmentReaderDB.bookmarks[bookKey] = nil
    end
    return bookmark, index
end

function ParchmentReader:RestoreBookmark(bookKey, bookmark, index)
    if type(bookmark) ~= "table" then return false end
    local bookmarks = GetBookmarkList(bookKey, true)
    if not bookmarks then return false end
    if #bookmarks >= BOOKMARK_LIMIT_PER_BOOK then return false end

    local insertAt = Clamp(math.floor(tonumber(index) or (#bookmarks + 1)), 1, #bookmarks + 1)
    table.insert(bookmarks, insertAt, bookmark)
    return true
end

function ParchmentReader:MoveReadingPosition(oldKey, newKey)
    local positions = ParchmentReaderDB and ParchmentReaderDB.bookPositions
    if oldKey == newKey then return end

    if self.InvalidateReaderLayoutCache then
        self:InvalidateReaderLayoutCache(oldKey)
        self:InvalidateReaderLayoutCache(newKey)
    end
    if positions then
        positions[newKey] = positions[oldKey]
        positions[oldKey] = nil
    end

    local bookmarks = ParchmentReaderDB and ParchmentReaderDB.bookmarks
    if bookmarks then
        bookmarks[newKey] = bookmarks[oldKey]
        bookmarks[oldKey] = nil
    end
end

function ParchmentReader:DeleteReadingPosition(bookKey)
    if self.InvalidateReaderLayoutCache then
        self:InvalidateReaderLayoutCache(bookKey)
    end

    local positions = ParchmentReaderDB and ParchmentReaderDB.bookPositions
    if positions then
        positions[bookKey] = nil
    end

    local bookmarks = ParchmentReaderDB and ParchmentReaderDB.bookmarks
    if bookmarks then
        bookmarks[bookKey] = nil
    end
end
