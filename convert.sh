#!/bin/bash

# --- PARAMETER CHECK ---
if [ -z "$1" ]; then
    echo "Error: Please provide the input directory path."
    echo "Usage: $0 /path/to/your/images/"
    exit 1
fi

# Define Input and Output Directories
INPUT_DIR="$1"
OUTPUT_DIR="./tmp/"

echo "Processing images in: $INPUT_DIR"
echo "Saving transparent PNGs to: $OUTPUT_DIR"

# 1. Clean and Create the output directory
if [ -d "$OUTPUT_DIR" ]; then
    echo "Cleaning existing $OUTPUT_DIR folder..."
    rm -rf "$OUTPUT_DIR"
fi
mkdir -p "$OUTPUT_DIR"

# 2. Loop through all specified image file types
for file in "$INPUT_DIR"*.{png,jpg,jpeg}; do
    # Check if a file was actually found
    if [ -e "$file" ]; then
        filename=$(basename "$file")
        # Get the filename WITHOUT the extension
        name_no_ext="${filename%.*}"
        
        # The Core ImageMagick Command: using 'magick' and forcing PNG output
        magick "$file" -fuzz 5% -transparent black "$OUTPUT_DIR$name_no_ext.png"
        
        echo "Processed: $filename -> $name_no_ext.png"
    fi
done

echo ""
echo "✅ Finished batch process! New assets are in the ./tmp/ folder."