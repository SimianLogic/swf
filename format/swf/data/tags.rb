class Tags
  TAG_END                   = 0
  SHOW_FRAME                = 1
  DEFINE_SHAPE              = 2
  FREE_CHARACTER            = 3
  PLACE_OBJECT              = 4
  REMOVE_OBJECT             = 5
  DEFINE_BITS               = 6
  DEFINE_BUTTON             = 7
  JPEG_TABLES               = 8
  SET_BACKGROUND_COLOR      = 9
                              
  DEFINE_FONT               = 10
  DEFINE_TEXT               = 11
  DO_ACTION                 = 12
  DEFINE_FONT_INFO          = 13
                              
  DEFINE_SOUND              = 14
  START_SOUND               = 15
  STOP_SOUND                = 16
                              
  DEFINE_BUTTON_SOUND       = 17
                              
  SOUND_STREAM_HEAD         = 18
  SOUND_STREAM_BLOCK        = 19
                              
  DEFINE_BITS_LOSSLESS      = 20
  DEFINE_BITS_JPEG2         = 21
                              
  DEFINE_SHAPE2             = 22
  DEFINE_BUTTON_CXFORM      = 23
                              
  PROTECT                   = 24
  PATHS_ARE_POSTSCRIPT      = 25
                              
  PLACE_OBJECT2             = 26
  C27                       = 27
  REMOVE_OBJECT2            = 28
                              
  SYNC_FRAME                = 29
  C30                       = 30
  FREE_ALL                  = 31
                              
  DEFINE_SHAPE3             = 32
  DEFINE_TEXT2              = 33
  DEFINE_BUTTON2            = 34
  DEFINE_BITS_JPEG3         = 35
  DEFINE_BITS_LOSSLESS2     = 36
  DEFINE_EDIT_TEXT          = 37
                              
  DEFINE_VIDEO              = 38
                              
  DEFINE_SPRITE             = 39
  NAME_CHARACTER            = 40
  PRODUCT_INFO              = 41
  DEFINE_TEXT_FORMAT        = 42
  FRAME_LABEL               = 43
  DEFINE_BEHAVIOR           = 44
  SOUND_STREAM_HEAD2        = 45
  DEFINE_MORPH_SHAPE        = 46
  FRAME_TAG                 = 47
  DEFINE_FONT2              = 48
  GEN_COMMAND               = 49
  DEFINE_COMMAND_OBJ        = 50
  CHARACTER_SET             = 51
  FONT_REF                  = 52
                              
  DEFINE_FUNCTION           = 53
  PLACE_FUNCTION            = 54
                              
  GEN_TAG_OBJECT            = 55
                              
  EXPORT_ASSETS             = 56
  IMPORT_ASSETS             = 57
                              
  ENABLE_DEBUGGER           = 58
                              
  DO_INIT_ACTION            = 59
  DEFINE_VIDEO_STREAM       = 60
  VIDEO_FRAME               = 61
                              
  DEFINE_FONT_INFO2         = 62
  DEBUG_ID                  = 63
  ENABLE_DEBUGGER2          = 64
  SCRIPT_LIMITS             = 65
                              
  SET_TAB_INDEX             = 66
                              
  DEFINE_SHAPE64            = 67
  C68                       = 68
                              
  FILE_ATTRIBUTES           = 69
                              
  PLACE_OBJECT3             = 70
  IMPORT_ASSET2             = 71
                              
  DO_ABC                    = 72
  DEFINE_FONT_ALIGN_ZONES   = 73
  CSM_TEXT_SETTINGS         = 74
  DEFINE_FONT3              = 75
  SYMBOL_CLASS              = 76
  META_DATA                 = 77
  DEFINE_SCALING_GRID       = 78
  C79                       = 79
  C80                       = 80
  C81                       = 81  
  DO_ABC2                   = 82
  DEFINE_SHAPE4             = 83
  DEFINE_MORPH_SHAPE2       = 84
  C85                       = 85
  DEFINE_SCENE_AND_FRAME_LABEL_DATA = 86
  DEFINE_BINARY_DATA        = 87
  DEFINE_FONT_NAME          = 88
  DEFINE_START_SOUND2       = 89
  LAST                      = 90
  
  def self.tags
    [
  		"End",               # 00
  		"ShowFrame",         # 01
  		"DefineShape",         # 02
  		"FreeCharacter",      # 03
  		"PlaceObject",         # 04
  		"RemoveObject",         # 05
  		"DefineBits",         # 06
  		"DefineButton",         # 07
  		"JPEGTables",         # 08
  		"SetBackgroundColor",   # 09

  		"DefineFont",         # 10
  		"DefineText",         # 11
  		"DoAction",            # 12
  		"DefineFontInfo",      # 13

  		"DefineSound",         # 14
  		"StartSound",         # 15
  		"StopSound",         # 16

  		"DefineButtonSound",   # 17

  		"SoundStreamHead",      # 18
  		"SoundStreamBlock",      # 19

  		"DefineBitsLossless",   # 20
  		"DefineBitsJPEG2",      # 21

  		"DefineShape2",         # 22
  		"DefineButtonCxform",   # 23

  		"Protect",            # 24

  		"PathsArePostScript",   # 25

  		"PlaceObject2",         # 26
  		"27 (invalid)",         # 27
  		"RemoveObject2",      # 28

  		"SyncFrame",         # 29
  		"30 (invalid)",         # 30
  		"FreeAll",            # 31

  		"DefineShape3",         # 32
  		"DefineText2",         # 33
  		"DefineButton2",      # 34
  		"DefineBitsJPEG3",      # 35
  		"DefineBitsLossless2",   # 36
  		"DefineEditText",      # 37

  		"DefineVideo",         # 38

  		"DefineSprite",         # 39
  		"NameCharacter",      # 40
  		"ProductInfo",         # 41
  		"DefineTextFormat",      # 42
  		"FrameLabel",         # 43
  		"DefineBehavior",      # 44
  		"SoundStreamHead2",      # 45
  		"DefineMorphShape",      # 46
  		"FrameTag",            # 47
  		"DefineFont2",         # 48
  		"GenCommand",         # 49
  		"DefineCommandObj",      # 50
  		"CharacterSet",         # 51
  		"FontRef",            # 52

  		"DefineFunction",      # 53
  		"PlaceFunction",      # 54

  		"GenTagObject",         # 55

  		"ExportAssets",         # 56
  		"ImportAssets",         # 57

  		"EnableDebugger",      # 58

  		"DoInitAction",         # 59
  		"DefineVideoStream",   # 60
  		"VideoFrame",         # 61

  		"DefineFontInfo2",      # 62
  		"DebugID",             # 63
  		"EnableDebugger2",       # 64
  		"ScriptLimits",       # 65

  		"SetTabIndex",          # 66

  		"DefineShape4",       # 67
  		"DefineMorphShape2",    # 68

  		"FileAttributes",       # 69

  		"PlaceObject3",       # 70
  		"ImportAssets2",       # 71

  		"DoABC",             # 72
  		"DefineFontAlignZones",         # 73
  		"CSMTextSettings",         # 74
  		"DefineFont3",         # 75
  		"SymbolClass",         # 76
  		"Metadata",         # 77
  		"DefineScalingGrid",         # 78
  		"79 (invalid)",         # 79
  		"80 (invalid)",         # 80
  		"81 (invalid)",         # 81
  		"DoABC2",               # 82
  		"DefineShape4",         # 83
  		"DefineMorphShape2",         # 84
  		"c85", # 85
  		"DefineSceneAndFrameLabelData", # 86
  		"DefineBinaryData", #  87
  		"DefineFontName", #  88
  		"StartSound2", # 89
  		"LAST", # 90
  	]
  end
  
  def self.string(which)
    tags[which]
  end
end
