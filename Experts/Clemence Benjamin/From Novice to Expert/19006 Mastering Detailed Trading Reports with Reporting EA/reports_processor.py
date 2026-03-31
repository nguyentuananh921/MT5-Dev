#!/usr/bin/env python
# reports_processor.py
__version__ = "1.0.1" 
import sys
import os
import traceback
import argparse
import glob
from datetime import datetime, timedelta
import logging

# core data libs
import pandas as pd
import numpy as np

# templating & plotting
from jinja2 import Environment, FileSystemLoader
import matplotlib.pyplot as plt

# optional libraries: import safely
WEASY_AVAILABLE = False
PDFKIT_AVAILABLE = False
FPDF_AVAILABLE = False
YAGMAIL_AVAILABLE = False

try:
    from weasyprint import HTML          # may fail if native libs aren't installed
    WEASY_AVAILABLE = True
except Exception:
    WEASY_AVAILABLE = False

try:
    import pdfkit                       # wrapper for wkhtmltopdf
    PDFKIT_AVAILABLE = True
except Exception:
    PDFKIT_AVAILABLE = False

try:
    from fpdf import FPDF               # pure-python PDF writer (no native deps)
    FPDF_AVAILABLE = True
except Exception:
    FPDF_AVAILABLE = False

try:
    import yagmail
    YAGMAIL_AVAILABLE = True
except Exception:
    YAGMAIL_AVAILABLE = False

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# ---------------------------------------------------------------------
def parse_args():
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(description="Generate trading reports (HTML/PDF) from CSV.")
    parser.add_argument("csv_path", help="Path to the trades CSV file or a folder to search for History_*.csv")
    parser.add_argument("-f", "--formats", nargs="+", choices=["html", "pdf"], default=["pdf"],
                        help="Report formats to generate (html, pdf, or both)")
    parser.add_argument("-o", "--outdir", default=".", help="Directory to write report files")
    parser.add_argument("--email", action="store_true", help="Send report via email")
    parser.add_argument("--pdf-backend", choices=["weasyprint","wkhtmltopdf","fpdf"],
                        default="fpdf",
                        help="PDF backend to use. 'weasyprint', 'wkhtmltopdf', or 'fpdf' (no native deps). Default: fpdf")
    return parser.parse_args()

# ---------------------------------------------------------------------
def resolve_csv_path(csv_path):
    """
    Ensure csv_path points to an existing file. If not, try to locate the
    most recent History_*.csv in the same directory or the provided folder.
    Returns resolved path or raises FileNotFoundError.
    """
    # If csv_path is a directory -> look there
    if os.path.isdir(csv_path):
        search_dir = csv_path
    else:
        # If path exists as file -> return
        if os.path.isfile(csv_path):
            return csv_path
        # otherwise, take parent directory to search
        search_dir = os.path.dirname(csv_path) or "."

    pattern = os.path.join(search_dir, "History_*.csv")
    candidates = glob.glob(pattern)
    if not candidates:
        # also allow any .csv if no History_*.csv found
        candidates = glob.glob(os.path.join(search_dir, "*.csv"))
    if not candidates:
        raise FileNotFoundError(f"No CSV files found in {search_dir} (tried {pattern})")

    # pick the newest file by modification time
    candidates.sort(key=os.path.getmtime, reverse=True)
    chosen = candidates[0]
    logging.info(f"Resolved CSV path: {chosen} (searched: {search_dir})")
    return chosen

# ---------------------------------------------------------------------
def load_data(csv_path):
    """Load and validate CSV data, computing missing columns if necessary."""
    try:
        if not os.path.isfile(csv_path):
            logging.error(f"CSV file not found: {csv_path}")
            raise FileNotFoundError(f"CSV file not found: {csv_path}")
        # try parsing Time; if fails, read without parse and try to coerce later
        try:
            df = pd.read_csv(csv_path, parse_dates=["Time"])
        except Exception:
            df = pd.read_csv(csv_path)
            if "Time" in df.columns:
                df["Time"] = pd.to_datetime(df["Time"], errors="coerce")
        # Provide minimal defaults if columns missing
        if "Profit" not in df.columns:
            df["Profit"] = 0.0
        if "Symbol" not in df.columns:
            df["Symbol"] = "N/A"
        required_cols = ["Time", "Symbol", "Profit", "Balance", "Equity"]
        for col in required_cols:
            if col not in df.columns:
                logging.warning(f"Missing column: {col}. Attempting to compute.")
                if col == "Balance":
                    # create cumsum of profit + commission + swap if possible
                    df["Commission"] = df.get("Commission", 0)
                    df["Swap"] = df.get("Swap", 0)
                    df["Balance"] = (df["Profit"] + df["Commission"] + df["Swap"]).cumsum()
                elif col == "Equity":
                    df["Equity"] = df.get("Balance", df["Profit"].cumsum())
        # ensure Time column exists and is sorted
        if "Time" in df.columns:
            df = df.sort_values(by="Time")
        return df
    except Exception as e:
        logging.error(f"Error loading CSV: {e}")
        raise

# ---------------------------------------------------------------------
def compute_stats(df):
    """Compute trading statistics from the DataFrame."""
    try:
        top_symbol = None
        try:
            top_symbol = df.groupby("Symbol")["Profit"].sum().idxmax()
        except Exception:
            top_symbol = "N/A"
        eq = df.get("Equity")
        if eq is None:
            eq = df.get("Balance", df["Profit"].cumsum())
        max_dd = float((eq.cummax() - eq).max()) if len(eq) > 0 else 0.0
        sharpe = 0.0
        if len(df) > 1 and "Profit" in df.columns:
            dif = df["Profit"].diff().dropna()
            if dif.std() != 0:
                sharpe = float((dif.mean() / dif.std()) * np.sqrt(252))
        stats = {
            "date": datetime.now().strftime("%Y-%m-%d"),
            "net_profit": float(df["Profit"].sum()) if "Profit" in df.columns else 0.0,
            "trade_count": int(len(df)),
            "top_symbol": top_symbol,
            "max_drawdown": max_dd,
            "sharpe_ratio": sharpe
        }
        return stats
    except Exception as e:
        logging.error(f"Error computing stats: {e}")
        raise

# ---------------------------------------------------------------------
def render_html(df, stats, outpath, curve_image):
    """Render the HTML report using a Jinja2 template."""
    try:
        env = Environment(loader=FileSystemLoader(os.path.dirname(__file__)))
        tmpl_path = os.path.join(os.path.dirname(__file__), "report_template.html")
        if not os.path.isfile(tmpl_path):
            logging.error(f"Template not found: {tmpl_path}")
            raise FileNotFoundError(f"Missing template: {tmpl_path}")
        tmpl = env.get_template("report_template.html")
        html = tmpl.render(stats=stats, symbol_profits=df.groupby("Symbol")["Profit"].sum().to_dict(), curve_image=curve_image)
        os.makedirs(os.path.dirname(outpath), exist_ok=True)
        with open(outpath, "w", encoding="utf-8") as f:
            f.write(html)
        logging.info(f"HTML written: {outpath}")
    except Exception as e:
        logging.error(f"Error rendering HTML: {e}")
        raise

# ---------------------------------------------------------------------
def convert_pdf_weasy(html_path, pdf_path):
    """Convert HTML report to PDF using WeasyPrint backend."""
    if not WEASY_AVAILABLE:
        raise RuntimeError("WeasyPrint backend requested but weasyprint is not available.")
    try:
        os.makedirs(os.path.dirname(pdf_path), exist_ok=True)
        HTML(html_path).write_pdf(pdf_path)
        logging.info(f"PDF written: {pdf_path}")
    except Exception as e:
        logging.error(f"Error converting to PDF (WeasyPrint): {e}")
        raise

# ---------------------------------------------------------------------
def convert_pdf_wkhtml(html_path, pdf_path, wk_path=None):
    """Convert HTML to PDF using wkhtmltopdf via pdfkit."""
    if not PDFKIT_AVAILABLE:
        raise RuntimeError("wkhtmltopdf/pdfkit backend requested but pdfkit is not available.")
    try:
        config = None
        if wk_path and os.path.isfile(wk_path):
            config = pdfkit.configuration(wkhtmltopdf=wk_path)
        pdfkit.from_file(html_path, pdf_path, configuration=config)
        logging.info(f"PDF written: {pdf_path}")
    except Exception as e:
        logging.error(f"Error converting to PDF via wkhtmltopdf: {e}")
        raise

# ---------------------------------------------------------------------
def convert_pdf_with_fpdf(df, stats, curve_image_path, pdf_path):
    """
    Create a simple PDF report using fpdf (no HTML/CSS rendering).
    - df: pandas DataFrame of trades
    - stats: dict of computed stats
    - curve_image_path: path to the chart PNG created earlier
    - pdf_path: path to write the PDF
    """
    if not FPDF_AVAILABLE:
        raise RuntimeError("FPDF backend requested but fpdf is not installed.")
    try:
        pdf = FPDF(orientation='P', unit='mm', format='A4')
        pdf.set_auto_page_break(auto=True, margin=15)
        # page 1: title + stats + chart
        pdf.add_page()
        pdf.set_font("Arial", "B", 16)
        pdf.cell(0, 8, f"Trading Report - {stats.get('date','')}", ln=True, align='C')
        pdf.ln(4)

        pdf.set_font("Arial", "", 11)
        # key stats (two columns)
        left_col = [
            ("Net profit", f"{stats.get('net_profit',0):.2f}"),
            ("Trade count", f"{stats.get('trade_count',0)}"),
            ("Top symbol", f"{stats.get('top_symbol','')}")
        ]
        right_col = [
            ("Max drawdown", f"{stats.get('max_drawdown',0):.2f}"),
            ("Sharpe ratio", f"{stats.get('sharpe_ratio',0):.2f}"),
            ("Date", stats.get('date',''))
        ]
        col_width = 95
        for i in range(max(len(left_col), len(right_col))):
            left = left_col[i] if i < len(left_col) else ("","")
            right = right_col[i] if i < len(right_col) else ("","")
            pdf.cell(col_width, 6, f"{left[0]}: {left[1]}", border=0)
            pdf.cell(col_width, 6, f"{right[0]}: {right[1]}", ln=True)
        pdf.ln(6)

        # Insert equity curve image if present
        if curve_image_path and os.path.isfile(curve_image_path):
            try:
                pdf.image(curve_image_path, x=10, y=None, w=190)
            except Exception as e:
                logging.warning(f"Could not insert curve image into PDF: {e}")

        # next page: top symbol profits
        pdf.add_page()
        pdf.set_font("Arial", "B", 12)
        pdf.cell(0, 8, "Profit by Symbol (top 20)", ln=True)
        pdf.ln(2)
        pdf.set_font("Arial", "", 10)

        symbol_profits = df.groupby("Symbol")["Profit"].sum().sort_values(ascending=False)
        top = symbol_profits.head(20)
        pdf.set_fill_color(230,230,230)
        pdf.cell(120, 7, "Symbol", border=1, fill=True)
        pdf.cell(60, 7, "Profit", border=1, ln=True, fill=True)
        pdf.set_fill_color(255,255,255)
        for sym, val in top.items():
            pdf.cell(120, 6, str(sym), border=1)
            pdf.cell(60, 6, f"{val:.2f}", border=1, ln=True)

        # sample of recent trades
        pdf.add_page()
        pdf.set_font("Arial", "B", 12)
        pdf.cell(0, 8, "Recent trades (sample)", ln=True)
        pdf.ln(2)
        pdf.set_font("Arial", "", 9)
        headers = ["Ticket","Time","Type","Symbol","Volume","Price","Profit"]
        widths = [25,45,18,25,22,25,25]
        for h,w in zip(headers,widths):
            pdf.cell(w,6,h,border=1)
        pdf.ln()
        sample = df.tail(50).sort_values(by="Time", ascending=False)
        for idx,row in sample.iterrows():
            pdf.cell(widths[0],6,str(row.get("Ticket","")),border=1)
            time_str = row.get("Time")
            pdf.cell(widths[1],6,str(time_str),border=1)
            pdf.cell(widths[2],6,str(row.get("Type","")),border=1)
            pdf.cell(widths[3],6,str(row.get("Symbol","")),border=1)
            pdf.cell(widths[4],6,str(row.get("Volume","")),border=1)
            pdf.cell(widths[5],6,str(row.get("Price","")),border=1)
            pdf.cell(widths[6],6, f"{row.get('Profit',0):.2f}", border=1, ln=True)

        pdf.output(pdf_path)
        logging.info(f"PDF written: {pdf_path}")
    except Exception as e:
        logging.error(f"Error writing PDF with fpdf: {e}")
        raise

# ---------------------------------------------------------------------
def send_email(files, stats):
    """Send the generated reports via email."""
    try:
        if not YAGMAIL_AVAILABLE:
            logging.error("yagmail not available; cannot send email. Install yagmail or remove --email flag.")
            return
        user = os.getenv("clemencebenjamin04@gmail.com")
        pw = os.getenv("smom moaa glvj qfer")
        if not user or not pw:
            logging.error("Email credentials not set in environment variables (YAGMAIL_USERNAME, YAGMAIL_PASSWORD).")
            return
        yag = yagmail.SMTP(user, pw)
        subject = f"Trading Report {stats['date']}"
        contents = [f"See attached report for {stats['date']}"] + files
        yag.send(to=user, subject=subject, contents=contents)
        logging.info("Email sent.")
    except Exception as e:
        logging.error(f"Error sending email: {e}")

# ---------------------------------------------------------------------

# ---------------------------------------------------------------------
def write_result_json(outdir, pdf_path=None, html_path=None, email_sent=False, exit_code=0):
    """Write a small JSON file with the report result so MQL5 can poll/verify."""
    import json, tempfile
    try:
        result = {
            "pdf_path": pdf_path or "",
            "html_path": html_path or "",
            "email_sent": bool(email_sent),
            "timestamp": datetime.now().isoformat(),
            "exit_code": int(exit_code)
        }
        os.makedirs(outdir, exist_ok=True)
        fname = os.path.join(outdir, f"report_result_{datetime.now().strftime('%Y-%m-%d')}.json")
        # atomic write
        fd, tmp = tempfile.mkstemp(prefix="._report_result_", dir=outdir, text=True)
        with os.fdopen(fd, "w", encoding="utf-8") as f:
            json.dump(result, f, indent=2)
        os.replace(tmp, fname)
        logging.info(f"Result JSON written: {fname}")
        return fname
    except Exception as e:
        logging.error(f"Failed to write result JSON: {e}")
        return None


def main():
    """Main function to generate reports."""
    args = parse_args()
    try:
        # Ensure output directory exists
        os.makedirs(args.outdir, exist_ok=True)

        # Resolve csv_path in case a folder or variable-name was provided
        try:
            csv_path_resolved = resolve_csv_path(args.csv_path)
        except FileNotFoundError as e:
            logging.error(str(e))
            return 1

        # Load data and compute stats
        df = load_data(csv_path_resolved)
        stats = compute_stats(df)

        # Generate equity curve plot
        curve_image = os.path.join(args.outdir, f"equity_curve_{stats['date']}.png")
        plt.figure()
        # handle possibility of NaT in Time
        if "Time" in df.columns and not df["Time"].isnull().all():
            plt.plot(df["Time"], df["Balance"], label="Balance")
            plt.plot(df["Time"], df["Equity"], label="Equity")
        else:
            # fallback: plot index vs balance/equity
            plt.plot(df.index, df["Balance"], label="Balance")
            plt.plot(df.index, df["Equity"], label="Equity")
        plt.title("Balance & Equity Curve")
        plt.legend()
        plt.tight_layout()
        plt.savefig(curve_image)
        plt.close()
        logging.info(f"Equity curve saved: {curve_image}")

        base = os.path.join(args.outdir, f"Report_{stats['date']}")
        files_out = []

        # Generate HTML report (if requested or needed by PDF backend)
        html_path = base + ".html"
        if "html" in args.formats:
            render_html(df, stats, html_path, os.path.basename(curve_image))
            files_out.append(html_path)

        # Decide PDF backend
        backend = args.pdf_backend.lower() if hasattr(args, "pdf_backend") else "fpdf"
        logging.info(f"Selected PDF backend: {backend}")

        # Generate PDF (pdf-only or when requested)
        if "pdf" in args.formats:
            # Ensure HTML exists if the backend needs it
            if backend in ("weasyprint", "wkhtmltopdf"):
                if not os.path.isfile(html_path):
                    # Render HTML first
                    render_html(df, stats, html_path, os.path.basename(curve_image))

            pdf_path = base + ".pdf"

            if backend == "weasyprint":
                if not WEASY_AVAILABLE:
                    logging.error("WeasyPrint not available. Install weasyprint and native libs or choose a different backend.")
                    raise RuntimeError("WeasyPrint not available")
                convert_pdf_weasy(html_path, pdf_path)

            elif backend == "wkhtmltopdf":
                if not PDFKIT_AVAILABLE:
                    logging.error("pdfkit (wkhtmltopdf) not available. Install pdfkit and wkhtmltopdf binary or choose a different backend.")
                    raise RuntimeError("wkhtmltopdf backend not available")
                # Optionally allow env var WKHTMLTOPDF_PATH or default PATH
                wkpath = os.getenv("WKHTMLTOPDF_PATH")
                convert_pdf_wkhtml(html_path, pdf_path, wk_path=wkpath)

            elif backend == "fpdf":
                convert_pdf_with_fpdf(df, stats, curve_image, pdf_path)

            else:
                logging.error(f"Unknown PDF backend: {backend}")
                raise RuntimeError("Unknown PDF backend")

            files_out.append(pdf_path)

        # Send email if enabled
        if args.email:
            send_email(files_out, stats)

        # Clean up old reports (older than 30 days)
        cutoff = datetime.now() - timedelta(days=30)
        for f in os.listdir(args.outdir):
            if f.startswith("Report_") and f.endswith(tuple(args.formats)):
                full = os.path.join(args.outdir, f)
                if datetime.fromtimestamp(os.path.getmtime(full)) < cutoff:
                    os.remove(full)
                    logging.info(f"Deleted old file: {full}")
                    
                # Send email if enabled
        email_sent = False
        if args.email:
            send_email(files_out, stats)
            email_sent = True

        # --- NEW: write result JSON for MQL5 ---
        pdf_file = next((f for f in files_out if f.endswith(".pdf")), "")
        html_file = next((f for f in files_out if f.endswith(".html")), "")
        write_result_json(args.outdir, pdf_path=pdf_file, html_path=html_file,
                          email_sent=email_sent, exit_code=0)

        # Clean up old reports (older than 30 days)
        cutoff = datetime.now() - timedelta(days=30)
            

        return 0

    except Exception as e:
        logging.error(f"Main execution error: {e}")
        traceback.print_exc()
        # ensure a JSON is still written so MQL5 knows it failed
        try:
            write_result_json(args.outdir, exit_code=1)
        except:
            pass
        return 1

if __name__ == "__main__":
    sys.exit(main())
