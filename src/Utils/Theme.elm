module Utils.Theme exposing (Theme, lightTheme, darkTheme, getTheme)


type alias Theme =
    { toolbarBg : String
    , toolbarDeleteBg : String
    , toolbarBorderColor : String
    , btnSecondaryBg : String
    , btnDisabledBg : String
    , btnDisabledText : String
    , btnPrimary : String
    , btnGuide : String
    , btnConvert : String
    , btnDelete : String
    , btnBuildActive : String
    , btnAutoRunActive : String
    , canvasBg : String
    , rightPanelBg : String
    , rightPanelBorder : String
    , inputBg : String
    , inputText : String
    , inputBorder : String
    , overlayBorder : String
    , overlayHint : String
    , textPrimary : String
    , textSecondary : String
    , textMuted : String
    , textOnDark : String
    , dividerColor : String
    , separatorColor : String
    , consoleBg : String
    , consoleText : String
    , consoleHeaderBg : String
    , modalBg : String
    , modalTabBg : String
    , modalTabActiveBg : String
    , modalTabActiveBorder : String
    , modalSectionTitle : String
    , modalText : String
    , modalBorder : String
    , modalCodeBg : String
    , modalCodeText : String
    , modalNoteBg : String
    , modalNoteText : String
    , modalErrorBg : String
    , exampleCardBg : String
    , exampleCardBorder : String
    , resultAcceptBg : String
    , resultAcceptText : String
    , resultRejectBg : String
    , resultRejectText : String
    , convStepDescBg : String
    , convSectionHeaderBg : String
    , convTableHeaderBg : String
    , settingsBg : String
    , settingsBorder : String
    , automatonTypeDfa : String
    , automatonTypeNfa : String
    , automatonDefTitle : String
    , automatonDefBorder : String
    , readingHeadConsumedBg : String
    , readingHeadConsumedText : String
    , tabActiveBg : String
    , tabText : String
    , edgeColor : String
    , edgeLabelColor : String
    , convTableRowHighlight : String
    , convTableCellHighlight : String
    , convTableColHighlight : String
    , convTableColHeaderHighlight : String
    , copyBtnBg : String
    }


lightTheme : Theme
lightTheme =
    { toolbarBg = "#1a2f4a"
    , toolbarDeleteBg = "#4a1a1a"
    , toolbarBorderColor = "#263238"
    , btnSecondaryBg = "#546e7a"
    , btnDisabledBg = "#78909c"
    , btnDisabledText = "#b0bec5"
    , btnPrimary = "#0277bd"
    , btnGuide = "#00796b"
    , btnConvert = "#6a1b9a"
    , btnDelete = "#c62828"
    , btnBuildActive = "#1565c0"
    , btnAutoRunActive = "#00897b"
    , canvasBg = "#ecf0f1"
    , rightPanelBg = "#f8f9fa"
    , rightPanelBorder = "#34495e"
    , inputBg = "white"
    , inputText = "#212121"
    , inputBorder = "#bdc3c7"
    , overlayBorder = "#3498db"
    , overlayHint = "#666"
    , textPrimary = "#212121"
    , textSecondary = "#424242"
    , textMuted = "#546e7a"
    , textOnDark = "white"
    , dividerColor = "#b0bec5"
    , separatorColor = "#ccc"
    , consoleBg = "#000000"
    , consoleText = "#d4d4d4"
    , consoleHeaderBg = "#1a2f4a"
    , modalBg = "white"
    , modalTabBg = "#263238"
    , modalTabActiveBg = "#37474f"
    , modalTabActiveBorder = "#4fc3f7"
    , modalSectionTitle = "#1a2f4a"
    , modalText = "#424242"
    , modalBorder = "#cfd8dc"
    , modalCodeBg = "#f5f5f5"
    , modalCodeText = "#c62828"
    , modalNoteBg = "#e8f5e9"
    , modalNoteText = "#1b5e20"
    , modalErrorBg = "#fff8f8"
    , exampleCardBg = "#fafafa"
    , exampleCardBorder = "#cfd8dc"
    , resultAcceptBg = "#e8f5e9"
    , resultAcceptText = "#2e7d32"
    , resultRejectBg = "#ffebee"
    , resultRejectText = "#c62828"
    , convStepDescBg = "#fffde7"
    , convSectionHeaderBg = "#e8eaf6"
    , convTableHeaderBg = "#ccc"
    , settingsBg = "#1e3a50"
    , settingsBorder = "#263238"
    , automatonTypeDfa = "#358cc7"
    , automatonTypeNfa = "#ec7c1a"
    , automatonDefTitle = "#273646"
    , automatonDefBorder = "#359ee4"
    , readingHeadConsumedBg = "#eceff1"
    , readingHeadConsumedText = "#b0bec5"
    , tabActiveBg = "#546e7a"
    , tabText = "white"
    , edgeColor = "#222"
    , edgeLabelColor = "black"
    , convTableRowHighlight = "#fff9c4"
    , convTableCellHighlight = "#fff176"
    , convTableColHighlight = "#e3f2fd"
    , convTableColHeaderHighlight = "#90caf9"
    , copyBtnBg = "#7aa8c7"
    }


darkTheme : Theme
darkTheme =
    { toolbarBg = "#0d1a27"
    , toolbarDeleteBg = "#2a0d0d"
    , toolbarBorderColor = "#1a2530"
    , btnSecondaryBg = "#37474f"
    , btnDisabledBg = "#455a64"
    , btnDisabledText = "#607d8b"
    , btnPrimary = "#0288d1"
    , btnGuide = "#00897b"
    , btnConvert = "#7b1fa2"
    , btnDelete = "#d32f2f"
    , btnBuildActive = "#1976d2"
    , btnAutoRunActive = "#00897b"
    , canvasBg = "#1a1f24"
    , rightPanelBg = "#1e2530"
    , rightPanelBorder = "#2a3845"
    , inputBg = "#252d36"
    , inputText = "#ecf0f1"
    , inputBorder = "#455a64"
    , overlayBorder = "#1565c0"
    , overlayHint = "#78909c"
    , textPrimary = "#ecf0f1"
    , textSecondary = "#b0bec5"
    , textMuted = "#78909c"
    , textOnDark = "white"
    , dividerColor = "#37474f"
    , separatorColor = "#37474f"
    , consoleBg = "#0a0a0a"
    , consoleText = "#d4d4d4"
    , consoleHeaderBg = "#0d1a27"
    , modalBg = "#1e2530"
    , modalTabBg = "#161f28"
    , modalTabActiveBg = "#1e3040"
    , modalTabActiveBorder = "#29b6f6"
    , modalSectionTitle = "#4fc3f7"
    , modalText = "#b0bec5"
    , modalBorder = "#2e3a47"
    , modalCodeBg = "#2a3340"
    , modalCodeText = "#ef9a9a"
    , modalNoteBg = "#1b3a20"
    , modalNoteText = "#a5d6a7"
    , modalErrorBg = "#2a1515"
    , exampleCardBg = "#252d36"
    , exampleCardBorder = "#2e3a47"
    , resultAcceptBg = "#1b3a20"
    , resultAcceptText = "#a5d6a7"
    , resultRejectBg = "#2a1515"
    , resultRejectText = "#ef9a9a"
    , convStepDescBg = "#2a2500"
    , convSectionHeaderBg = "#1a1d35"
    , convTableHeaderBg = "#37474f"
    , settingsBg = "#0d1a27"
    , settingsBorder = "#1a2530"
    , automatonTypeDfa = "#4fc3f7"
    , automatonTypeNfa = "#ffa726"
    , automatonDefTitle = "#90caf9"
    , automatonDefBorder = "#1976d2"
    , readingHeadConsumedBg = "#2a3340"
    , readingHeadConsumedText = "#546e7a"
    , tabActiveBg = "#2a3845"
    , tabText = "#ecf0f1"
    , edgeColor = "#cfd8dc"
    , edgeLabelColor = "#ecf0f1"
    , convTableRowHighlight = "#4a4300"
    , convTableCellHighlight = "#5a5000"
    , convTableColHighlight = "#0d2a4a"
    , convTableColHeaderHighlight = "#1a3a6a"
    , copyBtnBg = "#4a6a82"
    }


getTheme : Bool -> Theme
getTheme isDark =
    if isDark then
        darkTheme

    else
        lightTheme
