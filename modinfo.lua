name = "Craft by Item"
description = "Adds a crafting bar that shows recipes for the last selected item. (mouse)"

author = "Dimblemace"
forumthread = ""

version = "0.20"
api_version = 6
--priority = ?

--icon_atlas = "modicon.xml"
--icon = "modicon.tex"

dont_starve_compatible = true
reign_of_giants_compatible = true
shipwrecked_compatible = true

configuration_options =
{
    {
        name = "myscroll",
        label = "Scrolling",
        options =
        {
            { description = "Modded", data = true },
            { description = "Normal", data = false },
        },
        default = false
    },
    {
        name = "defer update",
        label = "Update Bar (slow)",
        options =
        {
            { description = "Always", data = false },
            { description = "When Needed", data = true },
        },
        default = true
    },
}

