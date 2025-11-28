#
# Softimage environment variables
# bash conv jackal 11/28/2025
#

export SI_LOCATION=/usr/Softimage/Soft3D_4.0
export MI_ROOT="$SI_LOCATION/3D/rsrc"
export MI_RAY2_SERVICE="mi-ray2Soft3D400"

glIsIGLOO=$(/bin/strings /usr/lib/libgl.so | /bin/grep -c IGLOO)
if [[ $glIsIGLOO -gt 0 ]]; then
  glext="OGL"
else
  glext="GL"
fi

if [[ -n "$HOME" ]]; then
  export SI_DBDIR="$HOME"
else
  export SI_DBDIR="/tmp"
fi

export SI_MAX_NB_POL=60000
export SI_IMAGE_PATH="$SI_LOCATION/3D/dso/sil"
export SI_CUSTOM_REFINE_TEMP_PATH="/usr/tmp"
export SI_CUSTOM_REFINE_MAX_OPT=5
export SI_CUSTOM_MOTION="$SI_LOCATION/3D/custom/motion"
export SI_CUSTOM_MODEL="$SI_LOCATION/3D/custom/model"
export SI_CUSTOM_MATTER="$SI_LOCATION/3D/custom/matter"
export SI_CUSTOM_ACTOR="$SI_LOCATION/3D/custom/actor"
export SI_CUSTOM_TOOLS="$SI_LOCATION/3D/custom/tools"
export SI_CHNLDRIVER="$SI_LOCATION/3D/chnlDriver/bin"
export SI_FONTS="$SI_LOCATION/3D/fonts"
export SI_VIDEOTAPE="/dev/ttyd1"
export SI_WACOM="/dev/ttyd2"

export SI_PAINT_FX="$SI_LOCATION/3D/pfx"
export SI_UDX_PATH="$SI_LOCATION/3D/custom/udx"
export EFFECTS_EDITOR='jot -f'

export LD_LIBRARYN32_PATH="$SI_LOCATION/3D/dso:$SI_LOCATION/3D/custom/bin:$SI_LOCATION/3D/custom/dso:$SI_LOCATION/Particle/dso:$SI_LOCATION/3D/dso/softGraphic${glext}:$LD_LIBRARYN32_PATH"

export SI_MI_PREVIEW="$SI_LOCATION/mental_ray/bin/mi_preview.so"
export SI_MI_SHADER_TOKEN="yes"
export SI_MI_TRACER2="$SI_LOCATION/mental_ray/bin/ray2"

# Defines the path where the "tmp" files are created when using the option:
# particle -a
export PARTICLE_TMPDIR="$HOME"

export LM_LICENSE_FILE="/usr/Softimage/Flexlm/licenses/softimage.lic"

# 1920x1080 UI Resolution
dispDim=$(xdpyinfo | grep -m 1 'dimensions:')
if [[ "$dispDim" == *"1920x1080"* ]]; then
  export SI_SCREENRES="SI_1920X1080"
fi

# Softimage's alias
#
alias soft="$SI_LOCATION/3D/bin/soft -f $MI_ROOT"
alias particle="LD_LIBRARY_PATH=\"$SI_LOCATION/Particle/dso:$SI_LOCATION/3D/dso/softGraphic${glext}\" $SI_LOCATION/Particle/bin/particle $SI_LOCATION/Particle/rsrc"

# Path for easy access to SOFTIMAGE
#
PATH="$SI_LOCATION/3D/bin:$SI_LOCATION/3D/dev/DKit/bin:$SI_LOCATION/3D/custom/bin:$SI_CHNLDRIVER/:$SI_LOCATION/mental_ray/bin:$SI_LOCATION/mental_ray/MR_Shaders/Shader_Lib/lib20/:$SI_LOCATION/Particle/bin:$PATH"
export PATH
