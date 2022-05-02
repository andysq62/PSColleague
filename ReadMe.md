# Functions for Use With Ellucian Colleague ERP

This module contains useful functions for administering and maintaining the Colleague ERP system.

It was developed with the system in place at American University.  Our architecture is made up of one application server, and 4 SQL servers.  The code at this point will need to be adapted to the local architecture.

I've created several helper functions in a private folder which generate private data specific to American University.  Items such as returning the location of the LPR, service account names, notification email addresses etc.  
I would like to add functions to build these items in a config file for a local architecture.  It would require some refactoring of this module.

There are still a few hard-coded paths, although, if one uses the typical default location for Colleague environments, i.e. d:\Ellucian\<environmentName>, you shouldn't need to change them.  Nonetheless, I plan to make these generic and added to a config.

Bringing DMI listeners up and down is very fast because it does not go through the daemon.

<andy@stellarfire.net>
