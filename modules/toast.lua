local Addon = select(2, ...)

local TOAST = {}
Addon.TOAST = TOAST

local AceGUI = LibStub("AceGUI-3.0")

-- Function to create a toast with the given text
function TOAST.showToast(text)
    local toast = AceGUI:Create("Frame")
    toast:SetTitle("")
    toast:SetLayout("Fill")
    toast:SetWidth(300)
    toast:SetHeight(50)
    toast.frame:SetBackdropColor(0, 0, 0, 1)
    toast.frame:SetBackdropBorderColor(0, 0, 0, 1)

    local toastText = AceGUI:Create("Label")
    toastText:SetText(text)
    toastText:SetFont(GameFontNormal:GetFont(), 12)
    toastText:SetColor(1, 1, 1)
    toastText:SetFullWidth(true)
    toastText:SetFullHeight(true)
    toast:AddChild(toastText)

    AceGUI:Release(toast)
end