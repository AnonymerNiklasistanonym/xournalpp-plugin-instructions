local function getDocumentCenter()
    local docStructure = app.getDocumentStructure()
    local pageWidth =
        docStructure["pages"][docStructure["currentPage"]]["pageWidth"]
    local pageHeight =
        docStructure["pages"][docStructure["currentPage"]]["pageHeight"]
    return pageWidth / 2, pageHeight / 2
end

return getDocumentCenter
