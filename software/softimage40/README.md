# Softimage 4.0

### softimage400

- Softimage 4.0 default env file from $SI_LOCATION, modified for SGUG bash (curr 5.0.7).
- Modified LD_LIBRARY_PATH to LD_LIBRARYN32_PATH. No idea what is going on here, why would this not be the default env var out of the box?
- Additional check for 1920x1080 screen dimensions to force SI UI to 1920x1080.
- License location hardcoded to **/usr/Softimage/Flexlm/licenses/softimage.lic**; Change as necessary.
- Rename to ~/.softimage400 and source from your preferred login script.