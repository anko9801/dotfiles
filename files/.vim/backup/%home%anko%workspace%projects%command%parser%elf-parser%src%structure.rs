Vim�UnDo� M����A�������Q�c��1#���Wpܲ�                                     aƨ�    _�                             ����                                                                                                                                                                                                                                                                                                                                                             aƨJ     �                   5�_�                    �        ����                                                                                                                                                                                                                                                                                                                            �           �           V        aƨ�    �   �   �        mod header;�   �   �       
   pub use header::*;       mod section;   pub use section::*;       mod program_header;   pub use program_header::*;       	mod file;   pub use file::*;5�_�                    �        ����                                                                                                                                                                                                                                                                                                                            �           �           V        aƨ�     �   �   �      5�_�                            ����                                                                                                                                                                                                                                                                                                                            �           �           V        aƨ�    �              �                  }�              	        }�              &            _ => SectionType::Unknown,�  
            #            19 => SectionType::Num,�  	            +            18 => SectionType::SymTabShNdx,�    
          %            17 => SectionType::Group,�    	          ,            16 => SectionType::PreInitArray,�              )            15 => SectionType::FiniArray,�              )            14 => SectionType::InitArray,�              &            11 => SectionType::DynSym,�              %            10 => SectionType::ShLib,�              "            9 => SectionType::Rel,�              %            8 => SectionType::NoBits,�               #            7 => SectionType::Note,�   �            &            6 => SectionType::Dynamic,�   �             #            5 => SectionType::Hash,�   �   �          #            4 => SectionType::Rela,�   �   �          %            3 => SectionType::StrTab,�   �   �          %            2 => SectionType::SymTab,�   �   �          '            1 => SectionType::ProgBits,�   �   �          #            0 => SectionType::Null,�   �   �                  match v {�   �   �          $    fn from(v: u32) -> SectionType {�   �   �           impl From<u32> for SectionType {�   �   �           �   �   �          }�   �   �              Unknown,�   �   �              Num = 19,�   �   �              SymTabShNdx = 18,�   �   �              Group = 17,�   �   �              PreInitArray = 16,�   �   �              FiniArray = 15,�   �   �              InitArray = 14,�   �   �              DynSym = 11,�   �   �              ShLib = 10,�   �   �              Rel = 9,�   �   �              NoBits = 8,�   �   �              Note = 7,�   �   �              Dynamic = 6,�   �   �              Hash = 5,�   �   �              Rela = 4,�   �   �              StrTab = 3,�   �   �              SymTab = 2,�   �   �              ProgBits = 1,�   �   �              Null = 0,�   �   �          pub enum SectionType {�   �   �          #[repr(u32)]�   �   �          C#[derive(Debug, Clone, Hash, Copy, Eq, Ord, PartialEq, PartialOrd)]�   �   �           �   �   �          }�   �   �              pub entry_size: u64,�   �   �              pub addr_align: u64,�   �   �              pub info: u32,�   �   �              pub link: u32,�   �   �              pub size: u64,�   �   �              pub offset: u64,�   �   �              pub addr: u64,�   �   �              pub flags: u64,�   �   �              pub ty: SectionType,�   �   �              pub name_idx: u32,�   �   �          pub struct SectionHeader64 {�   �   �          0#[derive(PartialEq, Eq, PartialOrd, Ord, Debug)]�   �   �           �   �   �          }�   �   �               pub header: SectionHeader64,�   �   �              pub name: String,�   �   �          pub struct Section64 {�   �   �          0#[derive(PartialEq, Eq, PartialOrd, Ord, Debug)]�   �   �           �   �   �          }�   �   �              }�   �   �          	        }�   �   �          &            _ => SegmentType::Unknown,�   �   �          1            0x6474e552 => SegmentType::GNU_RELRO,�   �   �          1            0x6474e551 => SegmentType::GNU_Stack,�   �   �          4            0x6474e550 => SegmentType::GNU_EH_Frame,�   �   �          "            8 => SegmentType::Num,�   �   �          "            7 => SegmentType::TLS,�   �   �          #            6 => SegmentType::Phdr,�   �   �          $            5 => SegmentType::ShLib,�   �   �          #            4 => SegmentType::Note,�   �   �          %            3 => SegmentType::Interp,�   �   �          &            2 => SegmentType::Dynamic,�   �   �          #            1 => SegmentType::Load,�   �   �          #            0 => SegmentType::Null,�   �   �                  match v {�   �   �          $    fn from(v: u32) -> SegmentType {�   �   �           impl From<u32> for SegmentType {�   �   �           �   �   �          }�   �   �              Unknown,�   �   �          8    HIPROC = 0x7fffffff, /* End of processor-specific */�   �   �          :    LOPROC = 0x70000000, /* Start of processor-specific */�   �   �          1    HIOS = 0x6fffffff,   /* End of OS-specific */�   �   �              // HISUNW = 0x6fffffff,�   �   �          /    SUNWSTACK = 0x6ffffffb, /* Stack segment */�   �   �          6    SUNWBSS = 0x6ffffffa,   /* Sun Specific segment */�   �   �              // LOSUNW = 0x6ffffffa,�   �   �          ?    GNU_RELRO = 0x6474e552,    /* Read-only after relocation */�   �   �          B    GNU_Stack = 0x6474e551,    /* Indicates stack executability */�   �   �          >    GNU_EH_Frame = 0x6474e550, /* GCC .eh_frame_hdr segment */�   �   �          9    Logs = 0x60000000,         /* Start of OS-specific */�   �   �              Num = 8,�   �   �              TLS = 7,�   �   �              Phdr = 6,�   �   �              ShLib = 5,�   �   �              Note = 4,�   �   �              Interp = 3,�   �   �              Dynamic = 2,�   �   �              Load = 1,�   �   �              Null = 0,�   �   �          pub enum SegmentType {�   �   �          #[repr(u32)]�   �   �          0#[derive(Debug, PartialEq, Eq, PartialOrd, Ord)]�   �   �           �   �   �          }�   �   �              pub align: u64,�   �   �              pub size_in_mem: u64,�   �   �              pub size_in_file: u64,�   �   �              pub physical_addr: u64,�   �   �              pub virtual_addr: u64,�   �   �              pub offset: u64,�   �   �              pub flags: u32,�   �   �              pub ty: SegmentType,�   �   �          pub struct ProgramHeader64 {�   �   �          0#[derive(Debug, PartialEq, Eq, PartialOrd, Ord)]�   �   �           �   �   �          }�   �   �              }�   �   �          	        }�   �   �          #            _ => ElfOsAbi::Unknown,�   �   �                       97 => ElfOsAbi::Arm,�   �   �          %            64 => ElfOsAbi::ArmAeAbi,�   �   �          $            12 => ElfOsAbi::OpenBsd,�   �   �          $            11 => ElfOsAbi::Modesto,�   �   �          "            10 => ElfOsAbi::Tru64,�   �   �          #            9 => ElfOsAbi::FreeBsd,�   �   �                       8 => ElfOsAbi::Irix,�   �   �                      7 => ElfOsAbi::Aix,�   �   �          #            6 => ElfOsAbi::Solaris,�   �   �                      3 => ElfOsAbi::Gnu,�   �   �          "            2 => ElfOsAbi::NetBsd,�      �                       1 => ElfOsAbi::HpUx,�   ~   �                       0 => ElfOsAbi::SysV,�   }                     match b {�   |   ~               fn from(b: u8) -> ElfOsAbi {�   {   }          impl From<u8> for ElfOsAbi {�   z   |           �   y   {          impl ElfOsAbi {}�   x   z           �   w   y          }�   v   x              Unknown,�   u   w              Arm = 97,�   t   v              ArmAeAbi = 64,�   s   u              OpenBsd = 12,�   r   t              Modesto = 11,�   q   s              Tru64 = 10,�   p   r              FreeBsd = 9,�   o   q              Irix = 8,�   n   p              Aix = 7,�   m   o              Solaris = 6,�   l   n              Gnu = 3,�   k   m              NetBsd = 2,�   j   l              HpUx = 1,�   i   k              SysV = 0,�   h   j          pub enum ElfOsAbi {�   g   i          #[repr(u8)]�   f   h          0#[derive(PartialEq, Eq, PartialOrd, Ord, Debug)]�   e   g           �   d   f          }�   c   e              }�   b   d          	        }�   a   c          %            _ => ElfVersion::Unknown,�   `   b          %            1 => ElfVersion::Current,�   _   a                  match b {�   ^   `          "    fn from(b: u8) -> ElfVersion {�   ]   _          impl From<u8> for ElfVersion {�   \   ^           �   [   ]          impl ElfVersion {}�   Z   \           �   Y   [          }�   X   Z              Unknown,�   W   Y              Current = 1,�   V   X          pub enum ElfVersion {�   U   W          #[repr(u8)]�   T   V          0#[derive(PartialEq, Eq, PartialOrd, Ord, Debug)]�   S   U           �   R   T          }�   Q   S              }�   P   R          	        }�   O   Q          "            _ => ElfData::Unknown,�   N   P                      3 => ElfData::Num,�   M   O                      2 => ElfData::Msb,�   L   N                      1 => ElfData::Lsb,�   K   M                      0 => ElfData::None,�   J   L                  match b {�   I   K              fn from(b: u8) -> ElfData {�   H   J          impl From<u8> for ElfData {�   G   I           �   F   H          impl ElfData {}�   E   G           �   D   F          }�   C   E              Unknown,�   B   D              Num = 3,�   A   C              Msb = 2,�   @   B              Lsb = 1,�   ?   A              None = 0,�   >   @          pub enum ElfData {�   =   ?          #[repr(u8)]�   <   >          0#[derive(PartialEq, Eq, PartialOrd, Ord, Debug)]�   ;   =           �   :   <          }�   9   ;              }�   8   :          	        }�   7   9          #            _ => ElfClass::Unknown,�   6   8                      3 => ElfClass::Num,�   5   7          !            2 => ElfClass::Bit64,�   4   6          !            1 => ElfClass::Bit32,�   3   5                       0 => ElfClass::None,�   2   4                  match b {�   1   3               fn from(b: u8) -> ElfClass {�   0   2          impl From<u8> for ElfClass {�   /   1           �   .   0          impl ElfClass {}�   -   /           �   ,   .          }�   +   -              Unknown,�   *   ,              Num = 3,�   )   +              Bit64 = 2,�   (   *              Bit32 = 1,�   '   )              None = 0,�   &   (          pub enum ElfClass {�   %   '          #[repr(u8)]�   $   &          0#[derive(PartialEq, Eq, PartialOrd, Ord, Debug)]�   #   %           �   "   $          }�   !   #              pub abi_version: u8,�       "              pub osabi: ElfOsAbi,�      !              pub version: ElfVersion,�                     pub data: ElfData,�                    pub class: ElfClass,�                pub struct ElfIdentification {�                0#[derive(PartialEq, Eq, PartialOrd, Ord, Debug)]�                 �                }�                $    pub sht_string_table_index: u16,�                    pub sht_entries: u16,�                    pub sht_entry_size: u16,�                    pub pht_entries: u16,�                    pub pht_entry_size: u16,�                    pub size: u16,�                    pub flags: u32,�                    pub sht_offset: u64,�                    pub pht_offset: u64,�                    pub entry: u64,�                    pub version: u32,�                    pub machine: u16,�                    pub ty: u16,�                    pub id: ElfIdentification,�   
             pub struct ElfHeader64 {�   	             0#[derive(PartialEq, Eq, PartialOrd, Ord, Debug)]�      
           �      	          3pub static ELF_MAGIC_SIGNATURE: &[u8] = b"\x7fELF";�                 �                }�                "    pub pht: Vec<ProgramHeader64>,�                !    pub sections: Vec<Section64>,�                    pub header: ElfHeader64,�                pub struct Elf64 {�                 0#[derive(PartialEq, Eq, PartialOrd, Ord, Debug)]�              }�              �                  }�              	        }�              &            _ => SectionType::Unknown,�  
            #            19 => SectionType::Num,�  	            +            18 => SectionType::SymTabShNdx,�    
          %            17 => SectionType::Group,�    	          ,            16 => SectionType::PreInitArray,�              )            15 => SectionType::FiniArray,�              )            14 => SectionType::InitArray,�              &            11 => SectionType::DynSym,�              %            10 => SectionType::ShLib,�              "            9 => SectionType::Rel,�              %            8 => SectionType::NoBits,�               #            7 => SectionType::Note,�   �            &            6 => SectionType::Dynamic,�   �             #            5 => SectionType::Hash,�   �   �          #            4 => SectionType::Rela,�   �   �          %            3 => SectionType::StrTab,�   �   �          %            2 => SectionType::SymTab,�   �   �          '            1 => SectionType::ProgBits,�   �   �          #            0 => SectionType::Null,�   �   �                  match v {�   �   �          $    fn from(v: u32) -> SectionType {�   �   �           impl From<u32> for SectionType {�   �   �           �   �   �          }�   �   �              Unknown,�   �   �              Num = 19,�   �   �              SymTabShNdx = 18,�   �   �              Group = 17,�   �   �              PreInitArray = 16,�   �   �              FiniArray = 15,�   �   �              InitArray = 14,�   �   �              DynSym = 11,�   �   �              ShLib = 10,�   �   �              Rel = 9,�   �   �              NoBits = 8,�   �   �              Note = 7,�   �   �              Dynamic = 6,�   �   �              Hash = 5,�   �   �              Rela = 4,�   �   �              StrTab = 3,�   �   �              SymTab = 2,�   �   �              ProgBits = 1,�   �   �              Null = 0,�   �   �          pub enum SectionType {�   �   �          #[repr(u32)]�   �   �          C#[derive(Debug, Clone, Hash, Copy, Eq, Ord, PartialEq, PartialOrd)]�   �   �           �   �   �          }�   �   �              pub entry_size: u64,�   �   �              pub addr_align: u64,�   �   �              pub info: u32,�   �   �              pub link: u32,�   �   �              pub size: u64,�   �   �              pub offset: u64,�   �   �              pub addr: u64,�   �   �              pub flags: u64,�   �   �              pub ty: SectionType,�   �   �              pub name_idx: u32,�   �   �          pub struct SectionHeader64 {�   �   �          0#[derive(PartialEq, Eq, PartialOrd, Ord, Debug)]�   �   �           �   �   �          }�   �   �               pub header: SectionHeader64,�   �   �              pub name: String,�   �   �          pub struct Section64 {�   �   �          0#[derive(PartialEq, Eq, PartialOrd, Ord, Debug)]�   �   �           �   �   �          }�   �   �              }�   �   �          	        }�   �   �          &            _ => SegmentType::Unknown,�   �   �          1            0x6474e552 => SegmentType::GNU_RELRO,�   �   �          1            0x6474e551 => SegmentType::GNU_Stack,�   �   �          4            0x6474e550 => SegmentType::GNU_EH_Frame,�   �   �          "            8 => SegmentType::Num,�   �   �          "            7 => SegmentType::TLS,�   �   �          #            6 => SegmentType::Phdr,�   �   �          $            5 => SegmentType::ShLib,�   �   �          #            4 => SegmentType::Note,�   �   �          %            3 => SegmentType::Interp,�   �   �          &            2 => SegmentType::Dynamic,�   �   �          #            1 => SegmentType::Load,�   �   �          #            0 => SegmentType::Null,�   �   �                  match v {�   �   �          $    fn from(v: u32) -> SegmentType {�   �   �           impl From<u32> for SegmentType {�   �   �           �   �   �          }�   �   �              Unknown,�   �   �          8    HIPROC = 0x7fffffff, /* End of processor-specific */�   �   �          :    LOPROC = 0x70000000, /* Start of processor-specific */�   �   �          1    HIOS = 0x6fffffff,   /* End of OS-specific */�   �   �              // HISUNW = 0x6fffffff,�   �   �          /    SUNWSTACK = 0x6ffffffb, /* Stack segment */�   �   �          6    SUNWBSS = 0x6ffffffa,   /* Sun Specific segment */�   �   �              // LOSUNW = 0x6ffffffa,�   �   �          ?    GNU_RELRO = 0x6474e552,    /* Read-only after relocation */�   �   �          B    GNU_Stack = 0x6474e551,    /* Indicates stack executability */�   �   �          >    GNU_EH_Frame = 0x6474e550, /* GCC .eh_frame_hdr segment */�   �   �          9    Logs = 0x60000000,         /* Start of OS-specific */�   �   �              Num = 8,�   �   �              TLS = 7,�   �   �              Phdr = 6,�   �   �              ShLib = 5,�   �   �              Note = 4,�   �   �              Interp = 3,�   �   �              Dynamic = 2,�   �   �              Load = 1,�   �   �              Null = 0,�   �   �          pub enum SegmentType {�   �   �          #[repr(u32)]�   �   �          0#[derive(Debug, PartialEq, Eq, PartialOrd, Ord)]�   �   �           �   �   �          }�   �   �              pub align: u64,�   �   �              pub size_in_mem: u64,�   �   �              pub size_in_file: u64,�   �   �              pub physical_addr: u64,�   �   �              pub virtual_addr: u64,�   �   �              pub offset: u64,�   �   �              pub flags: u32,�   �   �              pub ty: SegmentType,�   �   �          pub struct ProgramHeader64 {�   �   �          0#[derive(Debug, PartialEq, Eq, PartialOrd, Ord)]�   �   �           �   �   �          }�   �   �              }�   �   �          	        }�   �   �          #            _ => ElfOsAbi::Unknown,�   �   �                       97 => ElfOsAbi::Arm,�   �   �          %            64 => ElfOsAbi::ArmAeAbi,�   �   �          $            12 => ElfOsAbi::OpenBsd,�   �   �          $            11 => ElfOsAbi::Modesto,�   �   �          "            10 => ElfOsAbi::Tru64,�   �   �          #            9 => ElfOsAbi::FreeBsd,�   �   �                       8 => ElfOsAbi::Irix,�   �   �                      7 => ElfOsAbi::Aix,�   �   �          #            6 => ElfOsAbi::Solaris,�   �   �                      3 => ElfOsAbi::Gnu,�   �   �          "            2 => ElfOsAbi::NetBsd,�      �                       1 => ElfOsAbi::HpUx,�   ~   �                       0 => ElfOsAbi::SysV,�   }                     match b {�   |   ~               fn from(b: u8) -> ElfOsAbi {�   {   }          impl From<u8> for ElfOsAbi {�   z   |           �   y   {          impl ElfOsAbi {}�   x   z           �   w   y          }�   v   x              Unknown,�   u   w              Arm = 97,�   t   v              ArmAeAbi = 64,�   s   u              OpenBsd = 12,�   r   t              Modesto = 11,�   q   s              Tru64 = 10,�   p   r              FreeBsd = 9,�   o   q              Irix = 8,�   n   p              Aix = 7,�   m   o              Solaris = 6,�   l   n              Gnu = 3,�   k   m              NetBsd = 2,�   j   l              HpUx = 1,�   i   k              SysV = 0,�   h   j          pub enum ElfOsAbi {�   g   i          #[repr(u8)]�   f   h          0#[derive(PartialEq, Eq, PartialOrd, Ord, Debug)]�   e   g           �   d   f          }�   c   e              }�   b   d          	        }�   a   c          %            _ => ElfVersion::Unknown,�   `   b          %            1 => ElfVersion::Current,�   _   a                  match b {�   ^   `          "    fn from(b: u8) -> ElfVersion {�   ]   _          impl From<u8> for ElfVersion {�   \   ^           �   [   ]          impl ElfVersion {}�   Z   \           �   Y   [          }�   X   Z              Unknown,�   W   Y              Current = 1,�   V   X          pub enum ElfVersion {�   U   W          #[repr(u8)]�   T   V          0#[derive(PartialEq, Eq, PartialOrd, Ord, Debug)]�   S   U           �   R   T          }�   Q   S              }�   P   R          	        }�   O   Q          "            _ => ElfData::Unknown,�   N   P                      3 => ElfData::Num,�   M   O                      2 => ElfData::Msb,�   L   N                      1 => ElfData::Lsb,�   K   M                      0 => ElfData::None,�   J   L                  match b {�   I   K              fn from(b: u8) -> ElfData {�   H   J          impl From<u8> for ElfData {�   G   I           �   F   H          impl ElfData {}�   E   G           �   D   F          }�   C   E              Unknown,�   B   D              Num = 3,�   A   C              Msb = 2,�   @   B              Lsb = 1,�   ?   A              None = 0,�   >   @          pub enum ElfData {�   =   ?          #[repr(u8)]�   <   >          0#[derive(PartialEq, Eq, PartialOrd, Ord, Debug)]�   ;   =           �   :   <          }�   9   ;              }�   8   :          	        }�   7   9          #            _ => ElfClass::Unknown,�   6   8                      3 => ElfClass::Num,�   5   7          !            2 => ElfClass::Bit64,�   4   6          !            1 => ElfClass::Bit32,�   3   5                       0 => ElfClass::None,�   2   4                  match b {�   1   3               fn from(b: u8) -> ElfClass {�   0   2          impl From<u8> for ElfClass {�   /   1           �   .   0          impl ElfClass {}�   -   /           �   ,   .          }�   +   -              Unknown,�   *   ,              Num = 3,�   )   +              Bit64 = 2,�   (   *              Bit32 = 1,�   '   )              None = 0,�   &   (          pub enum ElfClass {�   %   '          #[repr(u8)]�   $   &          0#[derive(PartialEq, Eq, PartialOrd, Ord, Debug)]�   #   %           �   "   $          }�   !   #              pub abi_version: u8,�       "              pub osabi: ElfOsAbi,�      !              pub version: ElfVersion,�                     pub data: ElfData,�                    pub class: ElfClass,�                pub struct ElfIdentification {�                0#[derive(PartialEq, Eq, PartialOrd, Ord, Debug)]�                 �                }�                $    pub sht_string_table_index: u16,�                    pub sht_entries: u16,�                    pub sht_entry_size: u16,�                    pub pht_entries: u16,�                    pub pht_entry_size: u16,�                    pub size: u16,�                    pub flags: u32,�                    pub sht_offset: u64,�                    pub pht_offset: u64,�                    pub entry: u64,�                    pub version: u32,�                    pub machine: u16,�                    pub ty: u16,�                    pub id: ElfIdentification,�   
             pub struct ElfHeader64 {�   	             0#[derive(PartialEq, Eq, PartialOrd, Ord, Debug)]�      
           �      	          3pub static ELF_MAGIC_SIGNATURE: &[u8] = b"\x7fELF";�                 �                }�                "    pub pht: Vec<ProgramHeader64>,�                !    pub sections: Vec<Section64>,�                    pub header: ElfHeader64,�                pub struct Elf64 {�                 0#[derive(PartialEq, Eq, PartialOrd, Ord, Debug)]�              }    �              5��