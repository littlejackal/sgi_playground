# Softimage 4.0

### softimage400.sh

- Softimage 4.0 default env file from $SI_LOCATION, modified for SGUG bash (curr 5.0.7)
- Modified LD_LIBRARY_PATH to LD_LIBRARYN32_PATH. No idea what is going on here, why would this not be the default env var out of the box?
- Additional check for 1920x1080 screen dimensions to force SI UI to 1920x1080.
- License location hardcoded to **/usr/Softimage/Flexlm/licenses/softimage.lic**; Change as necessary
- Copy to $SI_LOCATION/.softimage400.sh, or ~/.softimage400.sh

### si_wrapper.sh

- Softimage 4.0 default launcher wrapper from $SI_LOCATION, modified for SGUG bash
- Will source above .softimage400.sh from either $SI_LOCATION or $HOME

### shortcuts

- Softimage 4.0 default toolchest shortcuts from $SI_LOCATION, modified to call bash si_wrapper.sh
- Overwrites $SI_LOCATION/.shortcuts so I guess we'd better hope everyone has bash as their default shell :3c
