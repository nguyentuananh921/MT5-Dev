import pandas as pd

def process_csv(input_file, output_file, encoding='utf-16'):
    # Define the column names (assuming the order in the CSV is consistent)
    column_names = ['Open', 'Close', 'Change', 'Duration']
    
    try:
        # Read the CSV file without headers using UTF-16 encoding
        df = pd.read_csv(input_file, header=None, names=column_names, encoding=encoding)
        
        # Strip leading/trailing whitespace from column data
        df = df.applymap(lambda x: x.strip() if isinstance(x, str) else x)
        
        # Remove any rows that are duplicates of the header (e.g., if it appears twice)
        df = df[df['Open'] != 'Open']
        
        # Display the processed data
        print("Processed Data:")
        print(df.head())
        
        # Save the processed data to a new CSV file with column names
        df.to_csv(output_file, index=False)
        print(f"Processed data saved to {output_file}")
    
    except UnicodeDecodeError as e:
        print(f"Error reading the file: {e}")
        print("Try using a different encoding like 'ISO-8859-1' or 'windows-1252'.")
    except pd.errors.EmptyDataError as e:
        print(f"No data: {e}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")

# Prompt the user for input and output file names and encoding
input_file = input("Enter the input CSV file name (e.g., 'PriceData.csv'): ")
output_file = input("Enter the desired output CSV file name (e.g., 'ProcessedPriceData.csv'): ")
encoding = input("Enter the file encoding (default is 'utf-16'): ") or 'utf-16'

# Call the function with the provided file names and encoding
process_csv(input_file, output_file, encoding)
