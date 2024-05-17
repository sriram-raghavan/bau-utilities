#!/bin/bash
# This Shell script does the following - 
# 1. Will take directory path as an argument
# 2. Read all the csv files in the directory
# 3. Copy the contents of all the csv files into an Excel sheet.
# 4. Each csv file contents will be copied to a separate sheet in the Excel sheet.

# Define log file path
LOG_FILE="/c/tmp/csv_to_excel.log"

# Function to log messages
log_message() {
    local type=$1
    local message=$2
    echo "$(date) [$type] - $message" >> "$LOG_FILE"
}

# Check if directory path is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <directory_path>"
    exit 1
fi

# Check if directory exists
if [ ! -d "$1" ]; then
    echo "Error: Directory $1 does not exist."
    exit 1
fi

# Create new Excel file
EXCEL_FILE="$1/csv_files.xlsx"

# Remove Excel file if it already exists
if [ -f "$EXCEL_FILE" ]; then
    rm "$EXCEL_FILE"
fi

# Log start of process
log_message "INFO" "Starting CSV to Excel conversion process for directory $1"

# Loop through CSV files in the directory
for csv_file in "$1"/*.csv; do
    # Extract filename without extension and truncate if necessary
    filename=$(basename -- "$csv_file")
    filename_without_extension="${filename%.*}"
    filename_without_extension_truncated="${filename_without_extension:0:30}" # Truncate to 30 characters

    # Convert CSV to Excel sheet using PowerShell
    log_message "INFO" "Converting $csv_file to Excel sheet"
    powershell -Command "Import-Csv '$csv_file' | Export-Excel -Path '$EXCEL_FILE' -WorksheetName '$filename_without_extension_truncated' -AutoSize -NoLegend; exit" \
        || log_message "ERROR" "Error converting $csv_file to Excel sheet"
done

# Log end of process
log_message "INFO" "CSV to Excel conversion process completed successfully."

exit 0
