# stata-economics-masterclass
A complete guide to time-series analysis, debugging, and publication-quality graphing in Stata

# Stata for Economists: From Zero to Hero 📈

Welcome to the **Stata Masterclass**. This repository contains all the code and data files needed to follow along with the [YouTube Series](YOUR_PLAYLIST_LINK_HERE). 

By the end of this course, you will be able to take messy raw data, clean it, transform it, analyze it, and produce publication-quality graphs and tables.

## 📺 Video Course Index

| Part | Topic | Video Link | Key Concepts |
| :--- | :--- | :--- | :--- |
| **0** | **Prerequisite: Getting Data** | [Watch Here](https://youtu.be/YtObmeC5rYw) | *Automating data downloads from StatCan (Optional)* |
| **1** | **Setup & Wrangling** | [Coming Soon] | *`import delimited`, `tsset`, `collapse`, Frequency conversion* |
| **2** | **Debugging Like a Pro** | [Coming Soon] | *Common errors, `replace` logic, fixing broken code* |
| **3** | **Generating Variables** | [Coming Soon] | *Growth rates, Logs, Lags, Economic Identities* |
| **4** | **Economic Analysis** | [Coming Soon] | *`summarize`, `pwcorr`, Lead/Lag analysis, Volatility* |
| **5** | **Perfect Visualizations** | [Coming Soon] | *`tsline`, formatting axes, recession shading, exporting* |

---

## 🎓 For University Students (The Assignment)
If you are taking my Macroeconomics course, follow these steps to get started:

1.  **Download the Materials:**
    * Go to the **[Releases](../../releases)** page on the right sidebar.
    * Download the `Student_Materials.zip` file.
    * *Do not just download individual files—the zip ensures folders are set up correctly.*
2.  **Unzip the Folder:**
    * Right-click the zip file and select **"Extract All"**. 
    * **Important:** Do not try to open the Stata files while they are still inside the zip.
3.  **Start Coding:**
    * Open `code/01_setup_import.do` in Stata.
    * Follow the instructions in **Video 1**.

---

## 🌍 For YouTube Learners
If you found this via YouTube, you can clone this repo to follow along.

**Prerequisites:**
* Stata (Version 14 or higher recommended)
* No prior experience required (We start from scratch!)

**The Data:**
The raw data (`.csv` files) in the `data/` folder comes from Statistics Canada (National Accounts & Labour Force Survey). While we focus on Canadian data, the techniques (cleaning, merging, time-series operators) apply to **any economic dataset** (FRED, World Bank, etc.).

---

## 📂 Repository Structure

* `code/`: Contains the do-files corresponding to each video lesson.
    * *Note: `02_debug_practice.do` contains intentional errors for learning purposes.*
* `data/`: Contains the raw CSV files needed to start the project.

## 👨‍🏫 About the Author
**Stephen Snudden, PhD** * [YouTube Channel](https://youtube.com/@ssnudden)
* [Academic Website](https://stephensnudden.com/)
* [GitHub Profile](https://github.com/SSEconomics)

*Disclaimer: This material is for educational purposes. If you use this code for research, please verify all transformations.*
