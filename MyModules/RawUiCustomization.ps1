#
# Console customizations
# Note that we cannot easily control the font-family nor font-size
# in script. Rather, we set those through properties. The 'Properties'
# apply per shortcut and override the 'Defaults'. My favorites are:
#   Size: 20
#   Font: Lucida Console
#   Cursor Size: Medium
# See windowsitpro.com/powershell/powershell-basics-console-configuration
# -------------------------

# Customize the prompt
function prompt
{
   Write-Host ("Shaun>") -nonewline -foregroundcolor Yellow
   return " "
}

# customize shell - note: it's hard to make this cooperate with git colors
# $ui = $HOST.UI.RawUI;
# $ui.ForegroundColor = 'Yellow';

# $size = $ui.WindowSize
# $size.Width = 105;
# $size.Height = 35;
# $ui.WindowSize = $size;

# the buffer size must exceed the window size
# $buffer = $ui.BufferSize;
# $buffer.Width = 105;
# $buffer.Height = 2000;
# $ui.BufferSize = $buffer;

# $ui.WindowPosition.x = 0;
# $ui.WindowPosition.y = 0;
