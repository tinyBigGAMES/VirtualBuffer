![VirtualBuffer](media/virtualbuffer.jpg)  
[![Chat on Discord](https://img.shields.io/discord/754884471324672040?style=for-the-badge)](https://discord.gg/tPWjMwK)
[![Follow on Bluesky](https://img.shields.io/badge/Bluesky-tinyBigGAMES-blue?style=for-the-badge&logo=bluesky)](https://bsky.app/profile/tinybiggames.com)    

**VirtualBuffer** is a generic, high-performance memory buffer class for Delphi, implemented using memory-mapped files with built-in thread safety. It provides fast, in-memory, stream-like access to typed data with locking, serialization, and disk persistence — ideal for use cases like custom file formats, virtual storage, runtime serialization, and memory-bound computation.

## 🔧 Features

* Generic type support (`TVirtualBuffer<T>`)
* Backed by memory-mapped files (`CreateFileMapping`)
* Thread-safe read/write access with `TCriticalSection`
* Stream-style I/O: position tracking, `Read`, `Write`, `Eos`
* String read/write with length-prefix encoding
* Save/load entire buffer contents to/from disk
* Bounds-checked index access via `Item[]`
* Clean API with robust error handling

## 🚀 Use Cases

* Fast, memory-resident data processing
* In-memory storage of structured records
* Virtual file or asset systems
* Custom serialization pipelines
* Preloading large binary datasets
* Inter-thread or inter-module shared buffers

## 🛠️ Installation

Just add `VirtualBuffer` to your Delphi project `uses` section. No external dependencies required.

Tested on **Delphi 12.3** and **Windows 64-bit**.

## 📦 Usage Example

```pascal
type
  TMyRecord = packed record
    ID: Integer;
    Value: Double;
  end;

var
  Buffer: TVirtualBuffer<TMyRecord>;
  Rec: TMyRecord;
begin
  Buffer := TVirtualBuffer<TMyRecord>.Create(1000); // 1000 records
  try
    Rec.ID := 42;
    Rec.Value := 3.14159;
    Buffer[0] := Rec; // Index-based assignment

    Buffer.Position := 0;
    Buffer.WriteString('Hello Virtual World');

    Buffer.Position := 0;
    Writeln(Buffer.ReadString); // Outputs: Hello Virtual World

    Buffer.SaveToFile('buffer.bin');
  finally
    Buffer.Free;
  end;
end;
```

## 🧠 API Overview

### Constructor

```pascal
constructor Create(aSize: UInt64);
```

Allocates memory for `ASize` elements of type `T`.

### Properties

| Property      | Description                              |
| ------------- | ---------------------------------------- |
| `Item[Index]` | Typed access to item at index            |
| `Capacity`    | Total number of items                    |
| `Size`        | Total size in bytes                      |
| `Position`    | Current read/write position              |
| `Memory`      | Raw pointer to buffer                    |
| `Name`        | OS memory map name (auto-generated GUID) |

### Methods

#### Basic I/O

```pascal
function Write(const ABuffer; const ACount: UInt64): UInt64;
function Read(var ABuffer; const ACount: UInt64): UInt64;
```

#### Byte array support

```pascal
function Write(const ABuffer: TBytes; const AOffset, ACount: UInt64): UInt64;
function Read(var ABuffer: TBytes; const AOffset, ACount: UInt64): UInt64;
```

#### Strings

```pascal
procedure WriteString(const AValue: string);
function ReadString: string;
```

#### File Persistence

```pascal
procedure SaveToFile(const AFilename: string);
class function LoadFromFile(const AFilename: string): TVirtualBuffer<T>;
```

#### Other

```pascal
function Eos(): Boolean; // End of stream
```

## 🔒 Thread Safety

All read/write operations and position changes are protected with a `TCriticalSection`, making the buffer safe for concurrent access across threads.

## 📂 File Format

Buffers saved using `SaveToFile()` are raw binary dumps of memory content. They can be reloaded with `LoadFromFile()` as long as the file size is divisible by `SizeOf(T)`.


> 🚧️ **This repository is currently under construction.**
>  
> VirtualBuffer is actively being developed. Features, APIs, and internal structure are subject to change.  
>  
> Contributions, feedback, and issue reports are welcome as the project evolves.


## 🛠️ Support and Resources

- 🐞 **Report issues** via the [Issue Tracker](https://github.com/tinyBigGAMES/VirtualBuffer/issues).
- 💬 **Engage in discussions** on the [Forum](https://github.com/tinyBigGAMES/VirtualBuffer/discussions) and [Discord](https://discord.gg/tPWjMwK).
- 📚 **Learn more** at [Learn Delphi](https://learndelphi.org).

## 🤝 Contributing  

Contributions to **✨ VirtualBuffer** are highly encouraged! 🌟  
- 🐛 **Report Issues:** Submit issues if you encounter bugs or need help.  
- 💡 **Suggest Features:** Share your ideas to make **VirtualBuffer** even better.  
- 🔧 **Create Pull Requests:** Help expand the capabilities and robustness of the library.  

Your contributions make a difference! 🙌✨

#### Contributors 👥🤝
<br/>

<a href="https://github.com/tinyBigGAMES/VirtualBuffer/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=tinyBigGAMES/VirtualBuffer&max=250&columns=20&anon=1" />
</a>

## 📜 Licensing

**VirtualBuffer** is distributed under the **🆓 BSD-3-Clause License**, allowing for redistribution and use in both source and binary forms, with or without modification, under specific conditions.  
See the [📜 LICENSE](https://github.com/tinyBigGAMES/VirtualBuffer?tab=BSD-3-Clause-1-ov-file#BSD-3-Clause-1-ov-file) file for more details.

---

🔒🧠 Thread-Safe, Generic Virtual Memory Buffer for Delphi — ⚡ Fast. 🧵 Safe. 🧰 Powerful.

<p align="center">
<img src="media/delphi.png" alt="Delphi">
</p>
<h5 align="center">
  
Made with ❤️ in Delphi  
