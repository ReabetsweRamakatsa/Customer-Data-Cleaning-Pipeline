# Customer-Data-Cleaning-Pipeline
This MySQL cleaning pipeline uses a modular CTE architecture to transform "dirty" data into a reliable reporting layer. It standardizes mixed date formats, enforces a +27 phone prefix, and sanitizes age outliers. By trapping "invisible" empty strings, it converts blanks into clear "Not Provided" labels for production-ready analytics.

Customer Data Cleaning Pipeline: From Raw to Reliable 
# 🚀📖 Project Overview
Data in the real world is messy. It comes with inconsistent dates, impossible ages, and "invisible" empty strings that ruin analytics. This project demonstrates a robust, end-to-end SQL cleaning pipeline built in MySQL.I transformed a "dirty" dataset of retail customers into a polished, production-ready table using advanced SQL techniques like Common Table Expressions (CTEs), window functions, and complex string manipulation.

# 🛠 How I Solved It: Techniques & Strategic Insights
Cleaning data is about building a reliable process. Here is the logic behind the methods I used:

1. The "Waterfall" Pipeline (Modular CTEs)
     Instead of one giant, unreadable query, I built a linear pipeline using Common Table Expressions (CTEs).
The Insight: Think of it like a car wash. First, we scrub the names (Standardization), then we dry off the duplicates (Deduplication), and finally, we add the polish (Enrichment). This modular approach makes the code easy to read and even easier to debug.

3. Brute-Force Date Harmonization
   One of the biggest headaches was inconsistent date formats. I had rows looking like Nov 20, 2021, others like 30/11/2012, and some in standard YYYY-MM-DD.
The Method: I used a "brute-force" pattern matcher. Using CASE and LIKE, I identified the format of each row individually and forced it into a single ISO-standard date using STR_TO_DATE.
   The Benefit: This turns "text" back into "data," allowing for actual time-based analytics.

4. The "Golden Record" Strategy (Deduplication)
   When you find two entries for the same customer, which one do you keep?
The Method: I used the ROW_NUMBER() window function to partition the data by email and rank it by the registration date.
The Insight: I kept the most recent entry (the "Golden Record"). This ensures the business isn't looking at outdated contact details.

5. Hunting "Invisible" Dirty Data
   A common trap is assuming a cell is empty just because it looks empty. Often, it's full of spaces or "empty strings" that bypass standard IS NULL checks.
The Method: I used TRIM(column) = '' to catch these "invisible" errors.
The Result: This allowed me to accurately label missing data as "Not Provided" or "Unknown" rather than leaving confusing blanks in the final report.

6. Standardizing International Dialing Codes
   Phone numbers came in as 072..., 2772..., and +2772....
The Method: I built a logic gate that strips the leading 0, catches the 27 prefix, and forces everything into a unified +27 (South Africa) international format.
The Insight: This ensures that any automated CRM system can actually reach the customer.

7. Policing Outliers (Age Sanitization)
  Data entry errors often result in impossible ages like -5 or 150.
The Method: I set a strict boundary check. Anything outside the $0$ to $100$ range was automatically re-labeled as "Not Provided."
The Insight: By treating "impossible" data as "missing" data, I protected the integrity of the dataset's averages and trends.

13. Creating a "Human-Friendly"
    Reporting LayerMost databases are built for machines, but reports are built for people.
The Method: In the final step, I converted numeric fields to characters (CAST AS CHAR) so I could insert readable labels like "Unknown" for dates or "-" for missing calculations.
