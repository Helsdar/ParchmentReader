


ParchmentReader = ParchmentReader or {}

local RECENT_LIMIT = 20
local VALID_VIEWS = {
    all = true,
    favorites = true,
    recent = true,
}
local currentView = "all"

local function NormalizeView(view)
    return VALID_VIEWS[view] and view or "all"
end

local function ExistingBook(books, bookKey)
    return type(bookKey) == "string"
        and type(books) == "table"
        and books[bookKey] ~= nil
end

local function OrderedRecentValues(recentBooks)
    local indices = {}
    for index in pairs(recentBooks) do
        if type(index) == "number" and index >= 1 and index % 1 == 0 then
            indices[#indices + 1] = index
        end
    end
    table.sort(indices)

    local values = {}
    for _, index in ipairs(indices) do
        values[#values + 1] = recentBooks[index]
    end
    return values
end

local function NormalizeRecent(values, books)
    local normalized = {}
    local seen = {}
    for _, storedKey in ipairs(values) do
        local bookKey = storedKey
        if ExistingBook(books, bookKey) and not seen[bookKey] then
            normalized[#normalized + 1] = bookKey
            seen[bookKey] = true
            if #normalized == RECENT_LIMIT then break end
        end
    end
    return normalized
end

function ParchmentReader:InitializeLibraryViewData(books)
    local library = type(books) == "table" and books or {}
    local storedFavorites = type(ParchmentReaderDB.favoriteBooks) == "table"
        and ParchmentReaderDB.favoriteBooks or {}
    local favorites = {}
    for bookKey, favorite in pairs(storedFavorites) do
        if favorite == true and ExistingBook(library, bookKey) then
            favorites[bookKey] = true
        end
    end

    local storedRecent = type(ParchmentReaderDB.recentBooks) == "table"
        and ParchmentReaderDB.recentBooks or {}
    ParchmentReaderDB.favoriteBooks = favorites
    ParchmentReaderDB.recentBooks = NormalizeRecent(
        OrderedRecentValues(storedRecent), library)
    currentView = NormalizeView(currentView)
end

function ParchmentReader:SetLibraryView(view)
    currentView = NormalizeView(view)
    return currentView
end

function ParchmentReader:GetLibraryView()
    return currentView
end

function ParchmentReader:IsFavoriteBook(bookKey)
    return type(ParchmentReaderDB.favoriteBooks) == "table"
        and ParchmentReaderDB.favoriteBooks[bookKey] == true
end

function ParchmentReader:SetFavoriteBook(bookKey, favorite)
    if not ExistingBook(self.books, bookKey) then return false end
    if type(ParchmentReaderDB.favoriteBooks) ~= "table" then
        ParchmentReaderDB.favoriteBooks = {}
    end
    ParchmentReaderDB.favoriteBooks[bookKey] = favorite == true and true or nil
    return ParchmentReaderDB.favoriteBooks[bookKey] == true
end

function ParchmentReader:ToggleFavoriteBook(bookKey)
    return self:SetFavoriteBook(bookKey, not self:IsFavoriteBook(bookKey))
end

function ParchmentReader:GetRecentBookKeys()
    if type(ParchmentReaderDB.recentBooks) ~= "table" then
        ParchmentReaderDB.recentBooks = {}
    end
    return ParchmentReaderDB.recentBooks
end

function ParchmentReader:RecordRecentBook(bookKey)
    if not ExistingBook(self.books, bookKey) then return false end
    local previous = type(ParchmentReaderDB.recentBooks) == "table"
        and OrderedRecentValues(ParchmentReaderDB.recentBooks) or {}
    local recent = {bookKey}
    local seen = {[bookKey] = true}
    for _, storedKey in ipairs(previous) do
        if not seen[storedKey] and ExistingBook(self.books, storedKey) then
            recent[#recent + 1] = storedKey
            seen[storedKey] = true
            if #recent == RECENT_LIMIT then break end
        end
    end
    ParchmentReaderDB.recentBooks = recent
    return true
end

function ParchmentReader:ClearRecentBooks()
    ParchmentReaderDB.recentBooks = {}
end

function ParchmentReader:RekeyLibraryViewBook(oldKey, newKey)
    if type(oldKey) ~= "string" or type(newKey) ~= "string"
        or oldKey == newKey
    then
        return
    end

    local favorites = ParchmentReaderDB.favoriteBooks
    if type(favorites) == "table" then
        if favorites[oldKey] == true then favorites[newKey] = true end
        favorites[oldKey] = nil
    end

    local recent = ParchmentReaderDB.recentBooks
    if type(recent) == "table" then
        local rekeyed = {}
        local seen = {}
        for _, storedKey in ipairs(OrderedRecentValues(recent)) do
            local bookKey = storedKey == oldKey and newKey or storedKey
            if type(bookKey) == "string" and not seen[bookKey] then
                rekeyed[#rekeyed + 1] = bookKey
                seen[bookKey] = true
                if #rekeyed == RECENT_LIMIT then break end
            end
        end
        ParchmentReaderDB.recentBooks = rekeyed
    end
end

function ParchmentReader:DeleteLibraryViewBook(bookKey)
    local favorites = ParchmentReaderDB.favoriteBooks
    if type(favorites) == "table" then favorites[bookKey] = nil end

    local recent = ParchmentReaderDB.recentBooks
    if type(recent) == "table" then
        local kept = {}
        for _, storedKey in ipairs(OrderedRecentValues(recent)) do
            if storedKey ~= bookKey then kept[#kept + 1] = storedKey end
        end
        ParchmentReaderDB.recentBooks = kept
    end
end

function ParchmentReader:IsBookInLibraryView(bookKey, view)
    local normalized = NormalizeView(view)
    if normalized == "all" then
        return ExistingBook(self.books, bookKey)
    end
    if normalized == "favorites" then
        return self:IsFavoriteBook(bookKey)
    end
    for _, recentKey in ipairs(self:GetRecentBookKeys()) do
        if recentKey == bookKey then return true end
    end
    return false
end

function ParchmentReader:HasBooksInLibraryView(view)
    local normalized = NormalizeView(view)
    if normalized == "all" then
        return type(self.books) == "table" and next(self.books) ~= nil
    end
    if normalized == "favorites" then
        local favorites = ParchmentReaderDB.favoriteBooks
        if type(favorites) ~= "table" then return false end
        for bookKey, favorite in pairs(favorites) do
            if favorite == true and ExistingBook(self.books, bookKey) then
                return true
            end
        end
        return false
    end
    for _, bookKey in ipairs(self:GetRecentBookKeys()) do
        if ExistingBook(self.books, bookKey) then return true end
    end
    return false
end

function ParchmentReader:ActivateLibraryBook(bookKey)
    if not ExistingBook(self.books, bookKey) then return false end
    self:RecordRecentBook(bookKey)
    return self:LoadBook(bookKey) == true
end
