# Customer-Data-Cleaning-Pipeline
This MySQL cleaning pipeline uses a modular CTE architecture to transform "dirty" data into a reliable reporting layer. It standardizes mixed date formats, enforces a +27 phone prefix, and sanitizes age outliers. By trapping "invisible" empty strings, it converts blanks into clear "Not Provided" labels for production-ready analytics.
