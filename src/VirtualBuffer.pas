{===============================================================================
 __   ___     _             _ ___       __  __
 \ \ / (_)_ _| |_ _  _ __ _| | _ )_  _ / _|/ _|___ _ _™
  \ V /| | '_|  _| || / _` | | _ \ || |  _|  _/ -_) '_|
   \_/ |_|_|  \__|\_,_\__,_|_|___/\_,_|_| |_| \___|_|
 Thread-Safe, Generic Virtual Memory Buffer for Delphi

 Copyright © 2025-present tinyBigGAMES™ LLC
 All Rights Reserved.

 https://github.com/tinyBigGAMES/VirtualBuffer

 See LICENSE file for license information
===============================================================================}

unit VirtualBuffer;

{$Z4}
{$A8}

{$INLINE AUTO}

{$IFNDEF WIN64}
  {$MESSAGE Error 'Unsupported platform'}
{$ENDIF}

interface

uses
  WinApi.Windows,
  System.SysUtils,
  System.IOUtils,
  System.Classes,
  System.SyncObjs;

type

  /// <summary>
  ///   <c>TVirtualBuffer&lt;T&gt;</c> is a generic, thread-safe in-memory buffer class
  ///   that allows low-level reading, writing, and manipulation of binary or typed data.
  ///   It provides both raw memory access and type-safe indexed access to elements of type <c>T</c>.
  /// </summary>
  /// <remarks>
  ///   The buffer can be used for serialization, memory-mapped file emulation, streaming,
  ///   interop with unmanaged code, or as a foundation for high-performance memory operations.
  ///   It supports saving to and loading from files, string encoding, and end-of-stream detection.
  /// </remarks>
  /// <typeparam name="T">
  ///   The element type to be stored and accessed in the buffer, enabling structured access
  ///   via array-like indexing (<c>Item[]</c>).
  /// </typeparam>
  TVirtualBuffer<T> = class
  private
    FHandle: THandle;
    FName: string;
    FCriticalSection: TCriticalSection;
    FMemory: Pointer;
    FSize: UInt64;
    FPosition: UInt64;
    procedure Clear();
    function GetItem(AIndex: UInt64): T;
    procedure SetItem(AIndex: UInt64; AValue: T);
    function GetCapacity(): UInt64;
    procedure SetPosition(const Value: UInt64);
    procedure Lock();
    procedure Unlock();
  public
    /// <summary>
    ///   Creates a new instance of <c>TVirtualBuffer&lt;T&gt;</c> with a specified
    ///   initial size in bytes. Allocates internal memory and initializes buffer
    ///   state accordingly.
    /// </summary>
    /// <param name="ASize">
    ///   The number of bytes to allocate for the buffer. This defines the initial
    ///   capacity and size of the memory block available for reading and writing.
    /// </param>
    constructor Create(const ASize: UInt64);

    /// <summary>
    ///   Destroys the <c>TVirtualBuffer&lt;T&gt;</c> instance and releases all
    ///   internally allocated memory and resources. This includes the buffer memory
    ///   and any synchronization primitives used for thread safety.
    /// </summary>
    destructor Destroy(); override;

    /// <summary>
    ///   Returns the current version string of the <c>TVirtualBuffer&lt;T&gt;</c> class.
    ///   This can be used for logging, diagnostics, or compatibility checks.
    /// </summary>
    /// <returns>
    ///   A <c>string</c> representing the version of the buffer class, typically
    ///   in the format <c>'Major.Minor.Patch'</c> (e.g., <c>'1.0.0'</c>).
    /// </returns>
    class function GetVersion(): string; static;

    /// <summary>
    ///   Writes a specified number of bytes from a memory buffer into the virtual buffer
    ///   at the current position. The buffer position is automatically advanced by the
    ///   number of bytes written.
    /// </summary>
    /// <param name="ABuffer">
    ///   A reference to the source memory buffer containing the data to be written.
    /// </param>
    /// <param name="ACount">
    ///   The number of bytes to write from the source buffer into the virtual buffer.
    ///   If this exceeds the remaining capacity, the buffer may grow or truncate the input.
    /// </param>
    /// <returns>
    ///   The actual number of bytes written to the buffer.
    /// </returns>
    function Write(const ABuffer; const ACount: UInt64): UInt64; overload;

    /// <summary>
    ///   Writes a specified number of bytes from a <c>TBytes</c> array into the virtual buffer,
    ///   starting from the given offset in the array. The buffer position is automatically advanced.
    /// </summary>
    /// <param name="ABuffer">
    ///   The byte array containing the data to write.
    /// </param>
    /// <param name="AOffset">
    ///   The zero-based index in <c>ABuffer</c> at which to begin copying data.
    /// </param>
    /// <param name="ACount">
    ///   The number of bytes to write from <c>ABuffer</c> starting at <c>AOffset</c>.
    /// </param>
    /// <returns>
    ///   The actual number of bytes written to the buffer.
    /// </returns>
    function Write(const ABuffer: TBytes; const AOffset, ACount: UInt64): UInt64; overload;

    /// <summary>
    ///   Reads a specified number of bytes from the virtual buffer into a destination
    ///   memory location, starting at the current buffer position. The position is
    ///   automatically advanced by the number of bytes read.
    /// </summary>
    /// <param name="ABuffer">
    ///   A reference to the destination buffer where data will be copied.
    ///   This must point to a valid memory location with enough space to hold the data.
    /// </param>
    /// <param name="ACount">
    ///   The number of bytes to read from the virtual buffer. If this exceeds the remaining
    ///   size, the method reads only up to the end of the buffer.
    /// </param>
    /// <returns>
    ///   The actual number of bytes read from the buffer.
    /// </returns>
    function Read(var ABuffer; const ACount: UInt64): UInt64; overload;

    /// <summary>
    ///   Reads a specified number of bytes from the virtual buffer into a <c>TBytes</c> array,
    ///   starting at the current buffer position. The read begins at the specified offset in the array,
    ///   and the buffer position is advanced accordingly.
    /// </summary>
    /// <param name="ABuffer">
    ///   The destination byte array that will receive the data.
    /// </param>
    /// <param name="AOffset">
    ///   The zero-based index in <c>ABuffer</c> at which to begin writing the data.
    /// </param>
    /// <param name="ACount">
    ///   The number of bytes to read from the virtual buffer. This must not exceed the length
    ///   of <c>ABuffer</c> starting at <c>AOffset</c>.
    /// </param>
    /// <returns>
    ///   The actual number of bytes read into the array.
    /// </returns>
    function Read(var ABuffer: TBytes; const AOffset, ACount: UInt64): UInt64; overload;

    /// <summary>
    ///   Saves the entire contents of the virtual buffer to a file on disk.
    ///   This includes all data from the start of the buffer up to its current size.
    /// </summary>
    /// <param name="AFilename">
    ///   The fully qualified file path where the buffer contents will be written.
    ///   If the file already exists, it will be overwritten.
    /// </param>
    procedure SaveToFile(const AFilename: string);

    /// <summary>
    ///   Creates a new <c>TVirtualBuffer&lt;T&gt;</c> instance and populates it with data
    ///   loaded from the specified file. The buffer size and memory contents will match
    ///   the exact contents of the file.
    /// </summary>
    /// <param name="AFilename">
    ///   The path to the file to load. The file must exist and be readable.
    /// </param>
    /// <returns>
    ///   A new instance of <c>TVirtualBuffer&lt;T&gt;</c> containing the loaded data.
    /// </returns>
    class function LoadFromFile(const AFilename: string): TVirtualBuffer<T>;

    /// <summary>
    ///   Indicates whether the end of the buffer has been reached.
    ///   This is useful when reading from the buffer in a loop, similar to an end-of-stream check.
    /// </summary>
    /// <returns>
    ///   <c>True</c> if the current buffer position is greater than or equal to the total size of the buffer;
    ///   otherwise, <c>False</c>.
    /// </returns>
    function Eob(): Boolean;

    /// <summary>
    ///   Reads a length-prefixed UTF-16 string from the current buffer position.
    ///   The string must have been previously written using <c>WriteString</c>.
    ///   The method reads the length first, then reads the characters accordingly.
    /// </summary>
    /// <returns>
    ///   The <c>string</c> value read from the buffer.
    /// </returns>
    function ReadString(): string;

    /// <summary>
    ///   Writes a UTF-16 string to the buffer at the current position, prefixing
    ///   it with its length as a <c>UInt32</c>. This allows the string to be
    ///   properly restored using <c>ReadString</c>.
    /// </summary>
    /// <param name="AValue">
    ///   The <c>string</c> to write to the buffer.
    /// </param>
    procedure WriteString(const AValue: string);

    /// <summary>
    ///   Provides indexed access to the elements of the buffer as type <c>T</c>.
    ///   This allows the buffer to be used like an array, enabling typed reading
    ///   and writing at a specific element index.
    /// </summary>
    /// <param name="AIndex">
    ///   The zero-based index of the element to access. This is relative to
    ///   the type size of <c>T</c>, not raw bytes.
    /// </param>
    /// <returns>
    ///   The value of type <c>T</c> stored at the specified index.
    /// </returns>
    property Item[AIndex: UInt64]: T read GetItem write SetItem; default;

    /// <summary>
    ///   Gets the total number of typed elements (<c>T</c>) the buffer can hold,
    ///   based on the current allocated size of the memory block.
    /// </summary>
    /// <returns>
    ///   The number of <c>T</c>-sized elements that fit in the buffer's capacity.
    /// </returns>
    property Capacity: UInt64 read GetCapacity;

    /// <summary>
    ///   Returns a raw pointer to the internal memory block used by the buffer.
    ///   This allows for direct access or interop with APIs requiring raw memory.
    ///   Use with caution, as no bounds checking is performed.
    /// </summary>
    /// <returns>
    ///   A <c>Pointer</c> to the beginning of the allocated buffer memory.
    /// </returns>
    property Memory: Pointer read FMemory;

    /// <summary>
    ///   Returns the total size of the buffer in bytes, as initially allocated.
    ///   This value reflects the full memory capacity, not how much data has been written.
    /// </summary>
    /// <returns>
    ///   The number of bytes allocated in the buffer.
    /// </returns>
    property Size: UInt64 read FSize;

    /// <summary>
    ///   Gets or sets the current read/write position within the buffer.
    ///   This position is used by all read and write operations and is automatically
    ///   advanced as data is accessed.
    /// </summary>
    /// <returns>
    ///   The current zero-based byte offset into the buffer.
    /// </returns>
    property Position: UInt64 read FPosition write SetPosition;

    /// <summary>
    ///   Gets the internal name associated with this buffer instance, typically used
    ///   as the identifier in shared memory operations (e.g. via <c>CreateFileMapping</c>).
    ///   This is usually a globally unique identifier (GUID).
    /// </summary>
    /// <returns>
    ///   A <c>string</c> representing the system-wide unique name of the buffer.
    /// </returns>
    property Name: string read FName;
  end;

implementation

procedure TVirtualBuffer<T>.Lock();
begin
  FCriticalSection.Enter();
end;

procedure TVirtualBuffer<T>.Unlock();
begin
  FCriticalSection.Leave();
end;

procedure TVirtualBuffer<T>.Clear();
begin
  if FMemory <> nil then
    UnmapViewOfFile(FMemory);

  if FHandle <> 0 then
    CloseHandle(FHandle);

  FMemory := nil;
  FHandle := 0;
  FSize := 0;
  FPosition := 0;
end;

function TVirtualBuffer<T>.GetItem(AIndex: UInt64): T;
begin
  Lock();
  try
    if AIndex >= Capacity then
      raise EArgumentOutOfRangeException.Create('Index out of bounds');
    CopyMemory(@Result, Pointer(UIntPtr(FMemory) + UIntPtr(AIndex * UInt64(SizeOf(T)))), SizeOf(T));
  finally
    Unlock();
  end;
end;

procedure TVirtualBuffer<T>.SetItem(AIndex: UInt64; AValue: T);
begin
  Lock();
  try
    if AIndex >= Capacity then
      raise EArgumentOutOfRangeException.Create('Index out of bounds');
    CopyMemory(Pointer(UIntPtr(FMemory) + UIntPtr(AIndex * UInt64(SizeOf(T)))), @AValue, SizeOf(T));
  finally
    Unlock();
  end;
end;

function TVirtualBuffer<T>.GetCapacity: UInt64;
begin
  Result := FSize div UInt64(SizeOf(T));
end;

procedure TVirtualBuffer<T>.SetPosition(const Value: UInt64);
begin
  Lock();
  try
    if Value > FSize then
      raise EArgumentOutOfRangeException.Create('Position out of bounds');
    FPosition := Value;
  finally
    Unlock();
  end;
end;

constructor TVirtualBuffer<T>.Create(const ASize: UInt64);
var
  LSizeHigh, LSizeLow: DWORD;
begin
  inherited Create();

  FCriticalSection := TCriticalSection.Create;

  FSize := UInt64(SizeOf(T)) * ASize;
  LSizeLow := DWORD(FSize and $FFFFFFFF);
  LSizeHigh := DWORD(FSize shr 32);

  FName := TPath.GetGUIDFileName();
  FHandle := CreateFileMapping(INVALID_HANDLE_VALUE, nil, PAGE_READWRITE, LSizeHigh, LSizeLow, PChar(FName));
  if FHandle = 0 then
    raise Exception.Create('Error creating memory mapping');

  FMemory := MapViewOfFile(FHandle, FILE_MAP_ALL_ACCESS, 0, 0, 0);
  if FMemory = nil then
  begin
    CloseHandle(FHandle);
    raise Exception.Create('Error mapping view of file');
  end;

  FPosition := 0;
end;

destructor TVirtualBuffer<T>.Destroy();
begin
  Clear();
  FCriticalSection.Free();
  inherited;
end;

class function TVirtualBuffer<T>.GetVersion(): string;
begin
  Result := '0.1.0';
end;

function TVirtualBuffer<T>.Write(const ABuffer; const ACount: UInt64): UInt64;
begin
  Lock();
  try
    if FPosition + ACount > FSize then
      Exit(0);
    CopyMemory(Pointer(UIntPtr(FMemory) + UIntPtr(FPosition)), @ABuffer, ACount);
    Inc(FPosition, ACount);
    Result := ACount;
  finally
    Unlock();
  end;
end;

function TVirtualBuffer<T>.Write(const ABuffer: TBytes; const AOffset, ACount: UInt64): UInt64;
begin
  Lock();
  try
    if FPosition + ACount > FSize then
      Exit(0);
    CopyMemory(Pointer(UIntPtr(FMemory) + UIntPtr(FPosition)), @ABuffer[AOffset], ACount);
    Inc(FPosition, ACount);
    Result := ACount;
  finally
    Unlock();
  end;
end;

function TVirtualBuffer<T>.Read(var ABuffer; const ACount: UInt64): UInt64;
var
  LCount: UInt64;
begin
  Lock;
  try
    LCount := ACount;
    if FPosition + LCount > FSize then
      LCount := FSize - FPosition;
    CopyMemory(@ABuffer, Pointer(UIntPtr(FMemory) + UIntPtr(FPosition)), LCount);
    Inc(FPosition, LCount);
    Result := LCount;
  finally
    Unlock;
  end;
end;

function TVirtualBuffer<T>.Read(var ABuffer: TBytes; const AOffset, ACount: UInt64): UInt64;
var
  LCount: UInt64;
begin
  Lock;
  try
    if (AOffset + ACount > Length(ABuffer)) then
      raise EArgumentOutOfRangeException.Create('Buffer overflow in Read');

    LCount := ACount;
    if FPosition + LCount > FSize then
      LCount := FSize - FPosition;

    CopyMemory(@ABuffer[AOffset], Pointer(UIntPtr(FMemory) + UIntPtr(FPosition)), LCount);
    Inc(FPosition, LCount);
    Result := LCount;
  finally
    Unlock;
  end;
end;


procedure TVirtualBuffer<T>.SaveToFile(const AFilename: string);
var
  LFileStream: TFileStream;
begin
  LFileStream := TFileStream.Create(AFilename, fmCreate);
  try
    LFileStream.WriteBuffer(FMemory^, FSize);
  finally
    LFileStream.Free();
  end;
end;

class function TVirtualBuffer<T>.LoadFromFile(const AFilename: string): TVirtualBuffer<T>;
var
  LFileStream: TFileStream;
  LFileSize: Int64;
  LElements: UInt64;
begin
  LFileStream := TFileStream.Create(AFilename, fmOpenRead or fmShareDenyWrite);
  try
    LFileSize := LFileStream.Size;
    if LFileSize mod SizeOf(T) <> 0 then
      raise Exception.Create('File size is not aligned with element size');

    LElements := LFileSize div SizeOf(T);
    Result := TVirtualBuffer<T>.Create(LElements);
    LFileStream.ReadBuffer(Result.FMemory^, LFileSize);
    Result.FPosition := 0;
  finally
    LFileStream.Free();
  end;
end;

function TVirtualBuffer<T>.ReadString: string;
var
  LLen: UInt64;
begin
  Read(LLen, SizeOf(LLen));
  SetLength(Result, LLen);
  if LLen > 0 then
    Read(Result[1], LLen * SizeOf(Char));
end;

procedure TVirtualBuffer<T>.WriteString(const AValue: string);
var
  LLength: UInt64;
begin
  Lock();
  try
    LLength := Length(AValue);
    Write(LLength, SizeOf(LLength));
    if LLength > 0 then
      Write(PChar(AValue)^, LLength * SizeOf(Char));
  finally
    Unlock();
  end;
end;

function TVirtualBuffer<T>.Eob(): Boolean;
begin
  Result := FPosition >= FSize;
end;

end.

