module Terminitor
  #
  # Thanks win32/autogui!
  #
  module Input

    # MSDN virtual key codes
    VK_LBUTTON = 0x01
    VK_RBUTTON = 0x02

    VK_CANCEL = 0x03
    VK_BACK = 0x08
    VK_TAB = 0x09
    VK_CLEAR = 0x0c
    VK_RETURN = 0x0d
    VK_SHIFT = 0x10
    VK_CONTROL = 0x11
    VK_MENU = 0x12
    VK_PAUSE = 0x13
    VK_ESCAPE = 0x1b
    VK_SPACE = 0x20
    VK_PRIOR = 0x21
    VK_NEXT = 0x22
    VK_END = 0x23
    VK_HOME = 0x24
    VK_LEFT = 0x25
    VK_UP = 0x26
    VK_RIGHT = 0x27
    VK_DOWN = 0x28
    VK_SELECT = 0x29
    VK_EXECUTE = 0x2b
    VK_SNAPSHOT = 0x2c
    VK_INSERT = 0x2d
    VK_DELETE = 0x2e
    VK_HELP = 0x2f

    VK_0 = 0x30
    VK_1 = 0x31
    VK_2 = 0x32
    VK_3 = 0x33
    VK_4 = 0x34
    VK_5 = 0x35
    VK_6 = 0x36
    VK_7 = 0x37
    VK_8 = 0x38
    VK_9 = 0x39
    VK_A = 0x41
    VK_B = 0x42
    VK_C = 0x43
    VK_D = 0x44
    VK_E = 0x45
    VK_F = 0x46
    VK_G = 0x47
    VK_H = 0x48
    VK_I = 0x49
    VK_J = 0x4a
    VK_K = 0x4b
    VK_L = 0x4c
    VK_M = 0x4d
    VK_N = 0x4e
    VK_O = 0x4f
    VK_P = 0x50
    VK_Q = 0x51
    VK_R = 0x52
    VK_S = 0x53
    VK_T = 0x54
    VK_U = 0x55
    VK_V = 0x56
    VK_W = 0x57
    VK_X = 0x58
    VK_Y = 0x59
    VK_Z = 0x5a

    VK_LWIN = 0x5b
    VK_RWIN = 0x5c
    VK_APPS = 0x5d

    VK_NUMPAD0 = 0x60
    VK_NUMPAD1 = 0x61
    VK_NUMPAD2 = 0x62
    VK_NUMPAD3 = 0x63
    VK_NUMPAD4 = 0x64
    VK_NUMPAD5 = 0x65
    VK_NUMPAD6 = 0x66
    VK_NUMPAD7 = 0x67
    VK_NUMPAD8 = 0x68
    VK_NUMPAD9 = 0x69
    VK_MULTIPLY = 0x6a
    VK_ADD = 0x6b
    VK_SEPARATOR = 0x6c
    VK_SUBTRACT = 0x6d
    VK_DECIMAL = 0x6e
    VK_DIVIDE = 0x6f

    VK_F1 = 0x70
    VK_F2 = 0x71
    VK_F3 = 0x72
    VK_F4 = 0x73
    VK_F5 = 0x74
    VK_F6 = 0x75
    VK_F7 = 0x76
    VK_F8 = 0x77
    VK_F9 = 0x78
    VK_F10 = 0x79
    VK_F11 = 0x7a
    VK_F12 = 0x7b

    VK_NUMLOCK = 0x90
    VK_SCROLL = 0x91
    VK_OEM_EQU = 0x92
    VK_LSHIFT = 0xa0
    VK_RSHIFT = 0xa1
    VK_LCONTROL = 0xa2
    VK_RCONTROL = 0xa3
    VK_LMENU = 0xa4
    VK_RMENU = 0xa5

    VK_OEM_1 = 0xba         # US ";:"
    VK_OEM_PLUS = 0xbb
    VK_OEM_COMMA = 0xbc
    VK_OEM_MINUS = 0xbd
    VK_OEM_PERIOD = 0xbe
    VK_OEM_2 = 0xbf         # US "/?"
    VK_OEM_3 = 0xc0         # US '`~'
    VK_OEM_4 = 0xdb         # US "[{"
    VK_OEM_5 = 0xdc         # US '\|'
    VK_OEM_6 = 0xdd         # US ']}'
    VK_OEM_7 = 0xde         # US quotes
    VK_OEM_8 = 0xdf         # none

    # delay in seconds between keystrokes
    KEYBD_KEYDELAY = 0

    # keybd_event
    KEYBD_EVENT_KEYUP = 2
    KEYBD_EVENT_KEYDOWN = 0

    Windows::API.auto_namespace = 'Terminitor::Input'
    Windows::API.auto_constant  = true
    Windows::API.auto_method    = true
    Windows::API.auto_unicode   = false

    Windows::API.new('keybd_event', 'IILL', 'V', 'user32')
    Windows::API.new('mouse_event', 'LLLLL', 'V', 'user32')

    # Send keystroke to the focused window, keystrokes are virtual keycodes
    #
    # @example send 2+2<CR>
    #
    #     keystroke(VK_2, VK_ADD, VK_2, VK_RETURN)
    #
    def keystroke(*keys)
      return if keys.empty?

      keybd_event keys.first, 0, KEYBD_EVENT_KEYDOWN, 0
      sleep KEYBD_KEYDELAY
      keystroke *keys[1..-1]
      sleep KEYBD_KEYDELAY
      keybd_event keys.first, 0, KEYBD_EVENT_KEYUP, 0
    end

    # String together keystrokes, simulates the user typing.
    #
    # Note: This method can be slow for large strings.  Consider using
    # the clipboard instead.
    #
    # @see Clipboard
    #
    # @example send 2+2<CR>
    #
    #     type_in("2+2\n")
    #
    # @param [String] string of characters to simulate typing
    def type_in(string)
      string.each_char do |char|
        keystroke(*char_to_virtual_keycode(char))
      end
    end

    private

    # convert a single character to a virtual keycode
    #
    # @param [Char] char is the character to convert
    #
    # @return [Array] of virtual keycodes
    def char_to_virtual_keycode(char)

      unless char.size == 1
        raise "virtual keycode conversion is for single characters only"
      end

      code = char.unpack('U')[0]

      case char
        when '0'..'9'
          [code - ?0 + 0x30]
        when 'A'..'Z'
          [VK_SHIFT, code]
        when 'a'..'z'
          [code - ?a + ?A]
        when ' '
          [code]
        when '+'
          [VK_ADD]
        when '='
          [VK_OEM_PLUS]
        when ','
          [VK_OEM_COMMA]
        when '.'
          [VK_OEM_PERIOD]
        when '-'
          [VK_OEM_MINUS]
        when '_'
          [VK_SHIFT, VK_OEM_MINUS]

        when ';'
          [VK_OEM_1]
        when ':'
          [VK_SHIFT, VK_OEM_1]
        when '/'
          [VK_OEM_2]
        when '?'
          [VK_SHIFT, VK_OEM_2]
        when '`'
          [VK_OEM_3]
        when '~'
          [VK_SHIFT, VK_OEM_3]
        when '['
          [VK_OEM_4]
        when '{'
          [VK_SHIFT, VK_OEM_4]
        when '\\'
          [VK_OEM_5]
        when '|'
          [VK_SHIFT, VK_OEM_5]
        when ']'
          [VK_OEM_6]
        when '}'
          [VK_SHIFT, VK_OEM_6]
        when "'"
          [VK_OEM_7]
        when '"'
          [VK_SHIFT, VK_OEM_7]

        when '!'
          [VK_SHIFT, VK_1]
        when '@'
          [VK_SHIFT, VK_2]
        when '#'
          [VK_SHIFT, VK_3]
        when '$'
          [VK_SHIFT, VK_4]
        when '%'
          [VK_SHIFT, VK_5]
        when '^'
          [VK_SHIFT, VK_6]
        when '&'
          [VK_SHIFT, VK_7]
        when '*'
          [VK_SHIFT, VK_8]
        when '('
          [VK_SHIFT, VK_9]
        when ')'
          [VK_SHIFT, VK_0]
        when "\n"
          [VK_RETURN]
        else
          raise "No conversion exists for character #{char}"
      end
    end
  end
end