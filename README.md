# Stata Economics Masterclass

[![YouTube Channel](https://img.shields.io/badge/YouTube-Subscribe-red?style=for-the-badge&logo=youtube)](https://youtube.com/@ssnudden)
[![Stata Version](https://img.shields.io/badge/Stata-15%2B-blue?style=for-the-badge)](https://www.stata.com/)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

**This is the introduction to Stata I wish I had.**

Suitable for all levels, this course is designed to make you a **better economist**. The goal is simple: improve your efficiency, save you hours of headaches, and eliminate errors through automation. Business students use Excel - economists use software (R/Stata/Python).

These scripts provide the hacks and workflows necessary to move from "manual" analysis to **replicable, professional code**.

---

## 📺 The Video Series (Watch & Code Along)

| Video Title | Skill Learned | Script |
| :--- | :--- | :--- |
| **1. Automated Import, Convert, Combine** ([Watch Here](https://youtu.be/5n0i6cCQZqo)) | Reproducible data loading | `01_Clean_Data_Automated.do` |
| **2. Debug Like a Pro** ([Watch Here](https://youtu.be/HCt52F8ESf4)) | Problem solving common coding errors | `02_Debug_Like_A_Pro.do` |
| **3. Stop Using Excel** (Video Coming Soon) | Professional analysis & visualization | `03_Stop_Using_Excel.do` |
| **4. The Spurious Trap** (Video Coming Soon) | Monte Carlo Simulations | `04_Spurious_Regression_Trap.do` |
| **5. The Copy-Paste Intervention** (Video Coming Soon) | Exporting Results to Word/Excel/LaTeX | `05_Copy_Paste_Intervention.do` |
---

## 🚀 Quick Start

1.  **Download** this repository (green "Code" button > Download ZIP).
2.  **Unzip** the folder. Keep all files in the same directory.
3.  **Open** any `.do` file by double clicking directly from the folder to set your working directory automatically (never set paths). 

---

## 🇨🇦 Data Source

The best economists **know the data**. 

The datasets used in this course (`CDataQ.csv`, `CDataM.csv`) are real Canadian macroeconomic data.

**Want to learn how to fetch this data yourself?**
I have a separate guide on how to build this exact dataset from scratch using official Statistics Canada sources.
* **[Watch the Video: StatsCan Economic Data Guide](https://youtu.be/YtObmeC5rYw)**
* **[Get the Data Guide & Raw Files](https://github.com/SSEconomics/statscan-econ-data-guide)**

---

## 🐛 The Golden Rules of Debugging

When your code crashes (and it will), do not panic. Follow this 3-step workflow from **Video 2** before trying to fix it:

1.  **Read the Error:** The Output window is your friend. Read the red text to understand *why* it failed. Click the blue error code (e.g., `r(109)`).
2.  **Find out where the error occurred:** Don't guess. Look at the line number. Run the code line by line to find the specific command that caused the stop.
3.  **Check the output after each command:** Code can run without crashing and still be wrong- always double check output and verify calculations in the data viewer. 

---

## 🏆 The "Better Economist" Standard

You should care deeply about the quality of your figures and tables. In this course, we adhere to the **Stand-Alone Principle**: A stranger should be able to pick up your graph or table and understand it perfectly without reading your text.

### 1. Code Hygiene
* **Clean Scripts:** Files include only the commands used and descriptions. 
* **No Raw Output:** Never show raw Stata output in a report. Everything must be summarized in words or formatted into a suitable table.

### 2. General Presentation Rules
* **Notes are Mandatory:** Must describe the data source, date range, transformations, and seasonal adjustments.
* **Titles:** It is best to handle titles and notes in LaTeX.
* **Real Names:** Always use the actual name of the series (e.g., "Real GDP Growth"), never the Stata syntax code (e.g., `dy_var`).

### 3. Guidelines for Figures
* **Axis Labels:** Use units only (e.g., "Percent", "Billions of Dollars").
* **Legends:** Label the series clearly without syntax.
* **No Borders:** Remove borders around legends and figures. 
* **Stationarity:** Graph what you are modelling. Non-stationary data only if showing trends.
* **Visuals:** No "Stata Blue" backgrounds. Format figures to look like they belong in a journal.

### 4. Guidelines for Tables
* **Relevance:** Only describe stationary data. Do not show variables that were not asked for.
* **Precision:** No more than **two significant digits** (e.g., `0.75`, not `0.75165`).

---

## 👤 Author
**Stephen Snudden, PhD**
* [YouTube Channel](https://youtube.com/@ssnudden)
* [Personal Website](https://stephensnudden.com/)
