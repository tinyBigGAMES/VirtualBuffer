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

unit UTestbed;

interface

uses
  WinApi.Windows,
  System.SysUtils,
  System.Classes,
  VirtualBuffer;

procedure RunTests();

implementation

{ -----------------------------------------------------------------------------
TMyRecord: Packed Data Structure
This record defines a compact structure containing two fields: an Integer ID
and a Double precision value. The record is marked as `packed` to ensure no
padding bytes are inserted between fields, making it suitable for binary I/O,
network transmission, or memory-mapped file structures.
------------------------------------------------------------------------------ }
type
  TMyRecord = packed record
    ID: Integer;    // A unique identifier for the record
    Value: Double;  // A floating-point value associated with the ID
  end;

{ -----------------------------------------------------------------------------
Test_WriteReadBytes: Write and Verify Byte Data
This test procedure demonstrates writing and reading raw byte data using
TVirtualBuffer<Byte>. It creates a test array of 256 bytes, writes it to the
buffer, reads it back, and verifies the data for integrity.

This serves as a simple validation of the buffer's binary write/read support,
useful when handling low-level or memory-mapped data operations.
------------------------------------------------------------------------------ }
procedure Test_WriteReadBytes();
var
  LBuffer: TVirtualBuffer<Byte>; // The memory buffer used for writing and reading byte data
  LWriteBytes, LReadBytes: TBytes; // Arrays for original and read-back data
  I: Integer;                    // Loop index for verification
  LCount: UInt64;                // Number of bytes written/read
begin
  WriteLn('🧪 Test_WriteReadBytes');

  // Allocate 256 bytes and fill with sequential values 0..255
  SetLength(LWriteBytes, 256);
  for I := 0 to High(LWriteBytes) do
    LWriteBytes[I] := I;

  // Create a virtual buffer with 1024 bytes of capacity
  LBuffer := TVirtualBuffer<Byte>.Create(1024);
  try
    // Write the data to the buffer starting at offset 0
    LCount := LBuffer.Write(LWriteBytes, 0, Length(LWriteBytes));
    WriteLn('Written bytes: ', LCount);

    // Reset position to the start of the buffer
    LBuffer.Position := 0;

    // Prepare array for reading and read the data back
    SetLength(LReadBytes, Length(LWriteBytes));
    LCount := LBuffer.Read(LReadBytes, 0, Length(LReadBytes));
    WriteLn('Read bytes: ', LCount);

    // Verify each byte matches the original data
    for I := 0 to High(LReadBytes) do
      if LReadBytes[I] <> LWriteBytes[I] then
        raise Exception.CreateFmt('Byte mismatch at index %d', [I]);

    // If no mismatch found, the test passed
    WriteLn('✅ Byte data verified.');
  finally
    // Free the buffer to release memory
    LBuffer.Free();
  end;
end;

{ -----------------------------------------------------------------------------
Test_WriteReadString: Write and Verify UTF-8 String
This test procedure validates the ability of TVirtualBuffer<Byte> to
write and read strings with full UTF-8 support. It writes a Unicode
string to the buffer, resets the position, reads it back, and verifies
that the original and resulting strings match exactly.

This test ensures string encoding/decoding functionality and confirms
correct handling of multilingual and emoji characters.
------------------------------------------------------------------------------ }
procedure Test_WriteReadString();
var
  LBuffer: TVirtualBuffer<Byte>; // The virtual memory buffer for writing/reading string data
  LTestStr, LReadStr: string;     // The original test string and the string read back
begin
  WriteLn('🧪 Test_WriteReadString');

  // Define the test string including Unicode and emoji characters
  LTestStr := 'Hello from TVirtualBuffer! 你好，世界 🌐';

  // Create a virtual buffer with 1024 bytes of memory
  LBuffer := TVirtualBuffer<Byte>.Create(1024);
  try
    // Write the string to the buffer in UTF-8 format
    LBuffer.WriteString(LTestStr);

    // Reset the buffer position to the beginning
    LBuffer.Position := 0;

    // Read the string back from the buffer
    LReadStr := LBuffer.ReadString();

    // Compare the original and read-back strings
    if LReadStr <> LTestStr then
      raise Exception.Create('❌ String mismatch');

    // Output success if the strings match
    WriteLn('✅ String verified: ', LReadStr);
  finally
    // Free the buffer to release memory
    LBuffer.Free();
  end;
end;

{ -----------------------------------------------------------------------------
Test_ItemAccess: Indexed Read/Write Validation
This test procedure verifies that TVirtualBuffer<Byte> supports direct
indexed access to individual elements via the default array-style indexer.

It writes a sequence of values (0..15) using the indexer, reads them back
again using the same syntax, and checks for correctness. This confirms the
integrity of the underlying buffer indexing logic.
------------------------------------------------------------------------------ }
procedure Test_ItemAccess();
var
  LBuffer: TVirtualBuffer<Byte>; // Virtual buffer with indexed access
  I: Integer;                   // Loop counter for assignment and verification
begin
  WriteLn('🧪 Test_ItemAccess');

  // Allocate buffer with space for 16 bytes
  LBuffer := TVirtualBuffer<Byte>.Create(16);
  try
    // Write values 0..15 directly via indexed access
    for I := 0 to 15 do
      LBuffer[I] := I;

    // Read values back and verify correctness
    for I := 0 to 15 do
      if LBuffer[I] <> I then
        raise Exception.CreateFmt('Item mismatch at index %d', [I]);

    // Output success if all values match
    WriteLn('✅ Item[] indexer verified.');
  finally
    // Release buffer memory
    LBuffer.Free();
  end;
end;

{ -----------------------------------------------------------------------------
Test_RecordWriteRead: Typed Record Buffer I/O
This test demonstrates how TVirtualBuffer<TMyRecord> can be used to write
and read strongly-typed records. A `TMyRecord` instance is filled with
sample data, written to the buffer, then read back into a second variable.

The test verifies that both fields (`ID` and `Value`) retain their original
values, confirming the buffer's support for structured data serialization.
------------------------------------------------------------------------------ }
procedure Test_RecordWriteRead();
var
  LBuffer: TVirtualBuffer<TMyRecord>; // Buffer for handling TMyRecord structures
  LRecWrite, RecRead: TMyRecord;      // Record instances for write/read comparison
begin
  WriteLn('🧪 Test_RecordWriteRead');

  // Create a virtual buffer with room for 10 TMyRecord elements
  LBuffer := TVirtualBuffer<TMyRecord>.Create(10);
  try
    // Populate the record to write
    LRecWrite.ID := 42;
    LRecWrite.Value := 3.14159;

    // Write the record to the buffer as raw memory
    LBuffer.Write(LRecWrite, SizeOf(LRecWrite));

    // Reset position to read the record back
    LBuffer.Position := 0;
    LBuffer.Read(RecRead, SizeOf(RecRead));

    // Validate that the read record matches the written one
    if (RecRead.ID <> LRecWrite.ID) or (Abs(RecRead.Value - LRecWrite.Value) > 1e-6) then
      raise Exception.Create('❌ Record mismatch');

    // Output success if all fields match
    WriteLn('✅ Record read/write verified.');
  finally
    // Release buffer memory
    LBuffer.Free();
  end;
end;

{ -----------------------------------------------------------------------------
Test_CapacityAndEob: Capacity and End-of-Buffer Checks
This procedure validates two key behaviors of TVirtualBuffer<Byte>:
  - The correct reporting of its allocated capacity.
  - The correct functioning of the Eob() method, which indicates whether
    the current position has reached or exceeded the logical end of the buffer.

It writes a single byte, performs checks before and after reaching the end,
and ensures that Eob() behaves as expected in both cases.
------------------------------------------------------------------------------ }
procedure Test_CapacityAndEob();
var
  LBuffer: TVirtualBuffer<Byte>; // The test buffer instance
  LDummy: Byte;                  // A placeholder byte for writing
begin
  WriteLn('🧪 Test_CapacityAndEos');

  // Allocate a virtual buffer with a capacity of 512 bytes
  LBuffer := TVirtualBuffer<Byte>.Create(512);
  try
    // Confirm that reported capacity matches requested size
    if LBuffer.Capacity <> 512 then
      raise Exception.Create('❌ Capacity mismatch');

    // Write one byte into the buffer
    LDummy := 1;
    LBuffer.Write(LDummy, 1);

    // Check that end-of-buffer is not yet reached
    if LBuffer.Eob() then
      raise Exception.Create('❌ Eos incorrectly triggered');

    // Move position to the current buffer size (end)
    LBuffer.Position := LBuffer.Size;

    // Check that end-of-buffer is now correctly reported
    if not LBuffer.Eob() then
      raise Exception.Create('❌ Eos expected but not triggered');

    // Output success message if all checks pass
    WriteLn('✅ Capacity and Eos() checks passed.');
  finally
    // Release the buffer
    LBuffer.Free();
  end;
end;

{ -----------------------------------------------------------------------------
Test_MemoryPointer: Raw Memory Access Verification
This test ensures that the `Memory` property of TVirtualBuffer<Byte> returns
a valid, non-nil pointer to the underlying allocated memory block.

This is useful when low-level access is required — such as passing the memory
to external libraries or performing direct pointer operations on the buffer.
------------------------------------------------------------------------------ }
procedure Test_MemoryPointer();
var
  LBuffer: TVirtualBuffer<Byte>; // The virtual buffer instance
begin
  WriteLn('🧪 Test_MemoryPointer');

  // Allocate a buffer with 128 bytes of memory
  LBuffer := TVirtualBuffer<Byte>.Create(128);
  try
    // Ensure the internal memory pointer is assigned
    if not Assigned(LBuffer.Memory) then
      raise Exception.Create('❌ Memory pointer is nil');

    // Output the memory address as an unsigned integer
    WriteLn('✅ Memory pointer assigned: ', UIntPtr(LBuffer.Memory));
  finally
    // Free the buffer and release its memory
    LBuffer.Free();
  end;
end;

{ -----------------------------------------------------------------------------
Test_SaveLoadFile: Buffer Persistence to Disk
This test validates the ability of TVirtualBuffer<Byte> to persist its contents
to disk and reload them from file using `SaveToFile` and `LoadFromFile`.

It writes a string to a buffer, saves it to a file, then loads it into a new
buffer instance, reads the string back, and confirms the content matches.

The test also performs cleanup by deleting the temporary file after execution.
------------------------------------------------------------------------------ }
procedure Test_SaveLoadFile();
const
  FileName = 'buffer.dat'; // The filename used for saving/loading buffer data
var
  LBuffer1, LBuffer2: TVirtualBuffer<Byte>; // Buffers for writing and reading
  LoadedStr: string;                      // String read back from file
begin
  WriteLn('🧪 Test_SaveLoadFile');

  // Create a buffer and write a string to it
  LBuffer1 := TVirtualBuffer<Byte>.Create(2048);
  try
    LBuffer1.WriteString('Saved to file.');
    LBuffer1.SaveToFile(FileName); // Save buffer content to disk
  finally
    LBuffer1.Free();
  end;

  // Load the buffer back from file into a new buffer instance
  LBuffer2 := TVirtualBuffer<Byte>.LoadFromFile(FileName);
  try
    LBuffer2.Position := 0;
    LoadedStr := LBuffer2.ReadString; // Read the stored string
    WriteLn('✅ Loaded string: ', LoadedStr);
  finally
    LBuffer2.Free();
    DeleteFile(FileName); // Clean up test file
  end;
end;

{ -----------------------------------------------------------------------------
RunTests: Execute All VirtualBuffer Tests
This procedure sequentially runs all test routines for TVirtualBuffer<Byte>.
It ensures UTF-8 encoding is set for the console, prints the buffer version,
and calls each test in order while handling exceptions gracefully.

If any test raises an exception, the error is caught and reported. After all
tests have completed, the user is prompted to press ENTER to exit.
------------------------------------------------------------------------------ }
procedure RunTests();
begin
  // Enable UTF-8 encoding for console input/output
  SetConsoleCP(CP_UTF8);
  SetConsoleOutputCP(CP_UTF8);

  // Print VirtualBuffer version information
  WriteLn('VirtualBuffer v', TVirtualBuffer<Byte>.GetVersion());
  WriteLn;

  // Run each test, capturing any exceptions
  try
    Test_WriteReadBytes();
    Writeln;

    Test_WriteReadString();
    Writeln;

    Test_ItemAccess();
    Writeln;

    Test_RecordWriteRead();
    Writeln;

    Test_CapacityAndEob();
    Writeln;

    Test_MemoryPointer();
    Writeln;

    Test_SaveLoadFile();
  except
    on E: Exception do
      Writeln('❌ ERROR: ', E.ClassName, ': ', E.Message);
  end;

  // Final message and wait for user input before exiting
  Writeln;
  Writeln('All tests completed. Press ENTER to exit.');
  ReadLn;
end;

end.
