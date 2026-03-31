#!/usr/bin/env python
import sys, os, traceback
import pandas as pd
from datetime import datetime, timedelta
from fpdf import FPDF

def main(csv_path):
    print(f"Processing CSV: {csv_path}")
    if not os.path.isfile(csv_path):
        raise FileNotFoundError(f"CSV not found: {csv_path}")

    # 1. Load & parse
    df = pd.read_csv(csv_path)
    df['Time'] = pd.to_datetime(df['Time'])

    # 2. Analytics
    report = {
        'date'       : datetime.now().strftime("%Y-%m-%d"),
        'net_profit' : df['Profit'].sum(),
        'trade_count': len(df),
        'top_symbol' : df.groupby('Symbol')['Profit'].sum().idxmax()
    }

    # 3. Generate PDF
    dirpath = os.path.dirname(csv_path)
    pdf_file = os.path.join(dirpath, f"Report_{report['date']}.pdf")
    generate_pdf(report, pdf_file)

    print(f"PDF written: {pdf_file}")
    return 0

def generate_pdf(report, output_path):
    pdf = FPDF()
    pdf.add_page()
    pdf.set_font("Arial", size=12)
    pdf.cell(0, 10, f"Report Date: {report['date']}", ln=True)
    pdf.cell(0, 10, f"Total Trades: {report['trade_count']}", ln=True)
    pdf.cell(0, 10, f"Net Profit:    ${report['net_profit']:.2f}", ln=True)
    pdf.cell(0, 10, f"Top Symbol:    {report['top_symbol']}", ln=True)
    pdf.output(output_path)

def clean_old_reports(days=30):
    now = datetime.now()
    cutoff = now - timedelta(days=days)
    dirpath = os.path.dirname(sys.argv[1])
    for fname in os.listdir(dirpath):
        if fname.startswith("Report_") and fname.endswith(".pdf"):
            full = os.path.join(dirpath, fname)
            if datetime.fromtimestamp(os.path.getmtime(full)) < cutoff:
                os.remove(full)
                print(f"Deleted old report: {full}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: processor.py <full_csv_path>")
        sys.exit(1)
    try:
        ret = main(sys.argv[1])
        # Optional maintenance
        if datetime.now().weekday() == 6:
            clean_old_reports(30)
        sys.exit(ret)
    except Exception as e:
        print("ERROR:", e)
        traceback.print_exc()
        sys.exit(1)
