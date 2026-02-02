{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Build tools
    gnumake
    cmake
    ninja # Fast build system
    pkg-config
    autoconf
    automake
    libtool

    # Debug/Low-level tools
    nasm # Assembler

    # GDB configuration with exploit development frameworks
  ];

  home.file.".gdbinit".text = ''
    # PEDA - Python Exploit Development Assistance
    define init-peda
    source ~/peda/peda.py
    end
    document init-peda
    Initializes the PEDA framework
    end

    define init-peda-arm
    source ~/peda-arm/peda-arm.py
    end
    document init-peda-arm
    Initializes PEDA for ARM
    end

    define init-peda-intel
    source ~/peda-arm/peda-intel.py
    end
    document init-peda-intel
    Initializes PEDA for Intel
    end

    # PwnDBG
    define init-pwndbg
    source ~/pwndbg/gdbinit.py
    end
    document init-pwndbg
    Initializes PwnDBG
    end

    # GEF - GDB Enhanced Features
    define init-gef
    source ~/gef/gef.py
    end
    document init-gef
    Initializes GEF
    end
  '';
}
