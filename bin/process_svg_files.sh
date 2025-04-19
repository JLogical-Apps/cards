#!/bin/bash

# Use the current directory (where the script is executed from)
# This assumes you're running it from your project root

# Process all SVG files in the assets/ directory
for svg_file in assets/*/*.svg; do
  # Check if the file exists and is a regular file
  if [ -f "$svg_file" ]; then
    echo "Processing: $svg_file"
    # Run the vector_graphics_compiler command for each SVG file
    dart run vector_graphics_compiler -i "$svg_file" -o "$svg_file.vec"
    # Check if the command was successful
    if [ $? -eq 0 ]; then
      echo "Successfully processed: $svg_file"
    else
      echo "Error processing: $svg_file"
    fi
  fi
done

echo "All SVG files processed!"