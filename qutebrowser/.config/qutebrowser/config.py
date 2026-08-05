# load your autoconfig, use this, if the rest of your config is empty!
config.load_autoconfig()

import theme

theme.setup(c, "solarized-light", False)

# Always hide the tab bar.
c.tabs.show = "never"
